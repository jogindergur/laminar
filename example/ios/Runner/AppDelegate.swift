import Flutter
import UIKit
import AVFoundation

@main
@objc class AppDelegate: FlutterAppDelegate {
  
  var videoExporter: NativeVideoExporter?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let exportChannel = FlutterMethodChannel(name: "com.laminar/export",
                                             binaryMessenger: controller.binaryMessenger)
    
    exportChannel.setMethodCallHandler({ [weak self]
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      
      switch call.method {
      case "initialize":
        guard let args = call.arguments as? [String: Any],
              let width = args["width"] as? Int,
              let height = args["height"] as? Int,
              let fps = args["fps"] as? Int else {
            result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
            return
        }
        self?.videoExporter = NativeVideoExporter(width: width, height: height, fps: fps)
        do {
            try self?.videoExporter?.initialize()
            result(nil)
        } catch {
            result(FlutterError(code: "INIT_FAILED", message: error.localizedDescription, details: nil))
        }
          
      case "addFrame":
        guard let args = call.arguments as? [String: Any],
              let bytesData = args["bytes"] as? FlutterStandardTypedData else {
            result(FlutterError(code: "INVALID_ARGS", message: nil, details: nil))
            return
        }
        do {
            try self?.videoExporter?.addFrame(bytes: bytesData.data)
            result(nil)
        } catch {
            result(FlutterError(code: "APPEND_FAILED", message: error.localizedDescription, details: nil))
        }

      case "finish":
        guard let exporter = self?.videoExporter else {
            result(FlutterError(code: "NOT_INIT", message: nil, details: nil))
            return
        }
        exporter.finish { path in
            self?.videoExporter = nil
            if let path = path {
                result(path)
            } else {
                result(FlutterError(code: "FINISH_FAILED", message: "Failed to create video file", details: nil))
            }
        }
          
      default:
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class NativeVideoExporter {
    let width: Int
    let height: Int
    let fps: Int
    
    var assetWriter: AVAssetWriter?
    var assetWriterInput: AVAssetWriterInput?
    var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    var frameCount: Int64 = 0
    var outputPath: String = ""
    
    init(width: Int, height: Int, fps: Int) {
        self.width = (width / 2) * 2
        self.height = (height / 2) * 2
        self.fps = fps
    }
    
    func initialize() throws {
        let tempDir = NSTemporaryDirectory()
        outputPath = (tempDir as NSString).appendingPathComponent("laminar_export_\(Date().timeIntervalSince1970).mp4")
        let url = URL(fileURLWithPath: outputPath)
        if FileManager.default.fileExists(atPath: outputPath) {
            try FileManager.default.removeItem(at: url)
        }
        
        assetWriter = try AVAssetWriter(outputURL: url, fileType: .mp4)
        
        let outputSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 8_000_000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ]
        ]
        
        assetWriterInput = AVAssetWriterInput(mediaType: .video, outputSettings: outputSettings)
        assetWriterInput?.expectsMediaDataInRealTime = false
        
        let sourcePixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferWidthKey as String: width,
            kCVPixelBufferHeightKey as String: height
        ]
        
        if let input = assetWriterInput {
            pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: input, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
            assetWriter?.add(input)
        }
        
        assetWriter?.startWriting()
        assetWriter?.startSession(atSourceTime: .zero)
        frameCount = 0
    }
    
    func addFrame(bytes: Data) throws {
        guard let adaptor = pixelBufferAdaptor, let input = assetWriterInput, input.isReadyForMoreMediaData else { return }
        
        var pixelBuffer: CVPixelBuffer?
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, adaptor.pixelBufferPool!, &pixelBuffer)
        
        guard let buffer = pixelBuffer else { return }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let pixelData = CVPixelBufferGetBaseAddress(buffer)
        
        let width = self.width
        let height = self.height
        let bytesPerRow = CVPixelBufferGetBytesPerRow(buffer)
        
        bytes.withUnsafeBytes { rawBufferPointer in
            guard let srcBase = rawBufferPointer.baseAddress?.assumingMemoryBound(to: UInt8.self), let dstBase = pixelData?.assumingMemoryBound(to: UInt8.self) else { return }
            
            for y in 0..<height {
                let srcRow = srcBase.advanced(by: y * width * 4)
                let dstRow = dstBase.advanced(by: y * bytesPerRow)
                
                for x in 0..<width {
                    // Flutter sends RGBA, CoreVideo wants BGRA
                    dstRow[x * 4 + 0] = srcRow[x * 4 + 2] // B
                    dstRow[x * 4 + 1] = srcRow[x * 4 + 1] // G
                    dstRow[x * 4 + 2] = srcRow[x * 4 + 0] // R
                    dstRow[x * 4 + 3] = srcRow[x * 4 + 3] // A
                }
            }
        }
        
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        let presentationTime = CMTime(value: frameCount, timescale: Int32(fps))
        adaptor.append(buffer, withPresentationTime: presentationTime)
        
        frameCount += 1
    }
    
    func finish(completion: @escaping (String?) -> Void) {
        assetWriterInput?.markAsFinished()
        assetWriter?.finishWriting { [weak self] in
            completion(self?.outputPath)
        }
    }
}
