package dev.laminar.laminar_example

import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaFormat
import android.media.MediaMuxer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.nio.ByteBuffer
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.laminar/export"
    private var videoExporter: NativeVideoExporter? = null
    private val executor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "initialize" -> {
                    val width = call.argument<Int>("width") ?: 0
                    val height = call.argument<Int>("height") ?: 0
                    val fps = call.argument<Int>("fps") ?: 30
                    executor.execute {
                        try {
                            videoExporter = NativeVideoExporter(width, height, fps)
                            videoExporter?.initialize(requireContext().cacheDir.absolutePath)
                            runOnUiThread { result.success(null) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("INIT_FAILED", e.message, null) }
                        }
                    }
                }
                "addFrame" -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    if (bytes != null) {
                        executor.execute {
                            try {
                                videoExporter?.addFrame(bytes)
                                runOnUiThread { result.success(null) }
                            } catch (e: Exception) {
                                runOnUiThread { result.error("APPEND_FAILED", e.message, null) }
                            }
                        }
                    } else {
                        result.error("INVALID_ARGS", "bytes cannot be null", null)
                    }
                }
                "finish" -> {
                    executor.execute {
                        try {
                            val path = videoExporter?.finish()
                            videoExporter = null
                            runOnUiThread { result.success(path) }
                        } catch (e: Exception) {
                            runOnUiThread { result.error("FINISH_FAILED", e.message, null) }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}

class NativeVideoExporter(width: Int, height: Int, private val fps: Int) {
    private val width = (width / 2) * 2
    private val height = (height / 2) * 2
    
    private var mediaCodec: MediaCodec? = null
    private var mediaMuxer: MediaMuxer? = null
    private var trackIndex = -1
    private var muxerStarted = false
    private var frameCount = 0L
    private var outputPath = ""
    
    fun initialize(cacheDir: String) {
        outputPath = "$cacheDir/laminar_export_${System.currentTimeMillis()}.mp4"
        val file = File(outputPath)
        if (file.exists()) file.delete()
        
        val format = MediaFormat.createVideoFormat(MediaFormat.MIMETYPE_VIDEO_AVC, width, height)
        format.setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Flexible)
        format.setInteger(MediaFormat.KEY_BIT_RATE, 8000000)
        format.setInteger(MediaFormat.KEY_FRAME_RATE, fps)
        format.setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1)
        
        mediaCodec = MediaCodec.createEncoderByType(MediaFormat.MIMETYPE_VIDEO_AVC)
        mediaCodec?.configure(format, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
        mediaCodec?.start()
        
        mediaMuxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
        
        frameCount = 0
        muxerStarted = false
    }

    private fun rgbaToYuv420(rgba: ByteArray, width: Int, height: Int): ByteArray {
        val yuv = ByteArray(width * height * 3 / 2)
        var yIndex = 0
        var uIndex = width * height
        var vIndex = width * height + (width * height / 4)

        var argbIndex = 0
        for (j in 0 until height) {
            for (i in 0 until width) {
                val r = rgba[argbIndex].toInt() and 0xFF
                val g = rgba[argbIndex + 1].toInt() and 0xFF
                val b = rgba[argbIndex + 2].toInt() and 0xFF
                
                val y = ((66 * r + 129 * g + 25 * b + 128) shr 8) + 16
                val u = ((-38 * r - 74 * g + 112 * b + 128) shr 8) + 128
                val v = ((112 * r - 94 * g - 18 * b + 128) shr 8) + 128

                yuv[yIndex++] = y.coerceIn(0, 255).toByte()
                
                if (j % 2 == 0 && i % 2 == 0) {
                    yuv[uIndex++] = u.coerceIn(0, 255).toByte()
                    yuv[vIndex++] = v.coerceIn(0, 255).toByte()
                }
                argbIndex += 4
            }
        }
        return yuv
    }
    
    fun addFrame(rgbaBytes: ByteArray) {
        val codec = mediaCodec ?: return
        val yuvBytes = rgbaToYuv420(rgbaBytes, width, height)
        
        val inputBufferIndex = codec.dequeueInputBuffer(10000)
        if (inputBufferIndex >= 0) {
            val inputBuffer = codec.getInputBuffer(inputBufferIndex)
            inputBuffer?.clear()
            inputBuffer?.put(yuvBytes)
            
            val presentationTimeUs = (frameCount * 1000000L) / fps
            codec.queueInputBuffer(inputBufferIndex, 0, yuvBytes.size, presentationTimeUs, 0)
            frameCount++
        }
        
        drainEncoder(false)
    }
    
    private fun drainEncoder(endOfStream: Boolean) {
        val codec = mediaCodec ?: return
        val muxer = mediaMuxer ?: return
        
        if (endOfStream) {
            val inputBufferIndex = codec.dequeueInputBuffer(10000)
            if (inputBufferIndex >= 0) {
                codec.queueInputBuffer(inputBufferIndex, 0, 0, 0, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
            }
        }
        
        val bufferInfo = MediaCodec.BufferInfo()
        while (true) {
            val outputBufferIndex = codec.dequeueOutputBuffer(bufferInfo, 10000)
            if (outputBufferIndex == MediaCodec.INFO_TRY_AGAIN_LATER) {
                if (!endOfStream) break
            } else if (outputBufferIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                if (muxerStarted) throw RuntimeException("format changed twice")
                val newFormat = codec.outputFormat
                trackIndex = muxer.addTrack(newFormat)
                muxer.start()
                muxerStarted = true
            } else if (outputBufferIndex >= 0) {
                val outputBuffer = codec.getOutputBuffer(outputBufferIndex) ?: throw RuntimeException("encoderOutputBuffer null")
                
                if ((bufferInfo.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG) != 0) {
                    bufferInfo.size = 0
                }
                
                if (bufferInfo.size != 0) {
                    if (!muxerStarted) throw RuntimeException("muxer hasn't started")
                    outputBuffer.position(bufferInfo.offset)
                    outputBuffer.limit(bufferInfo.offset + bufferInfo.size)
                    muxer.writeSampleData(trackIndex, outputBuffer, bufferInfo)
                }
                
                codec.releaseOutputBuffer(outputBufferIndex, false)
                if ((bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
                    break
                }
            }
        }
    }
    
    fun finish(): String {
        drainEncoder(true)
        mediaCodec?.stop()
        mediaCodec?.release()
        
        if (muxerStarted) {
            mediaMuxer?.stop()
        }
        mediaMuxer?.release()
        
        return outputPath
    }
}
