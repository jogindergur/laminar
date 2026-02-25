window.laminarMuxer = {
  muxer: null,
  videoEncoder: null,
  frameCounter: 0,
  fps: 30,

  async initialize(width, height, fps) {
    this.fps = fps;
    this.frameCounter = 0;

    const w = Math.floor(width / 2) * 2;
    const h = Math.floor(height / 2) * 2;

    this.muxer = new Mp4Muxer.Muxer({
      target: new Mp4Muxer.ArrayBufferTarget(),
      video: {
        codec: 'avc',
        width: w,
        height: h,
      },
      fastStart: 'in-memory',
    });

    let configError = null;
    const errorCallback = (e) => {
      console.error('VideoEncoder error:', e);
      configError = e;
    };

    const tryConfigure = async (codecString) => {
      configError = null;
      let encoder = new VideoEncoder({
        output: (chunk, meta) => this.muxer.addVideoChunk(chunk, meta),
        error: errorCallback,
      });

      const config = {
        codec: codecString,
        width: w,
        height: h,
        bitrate: 8_000_000,
        hardwareAcceleration: 'prefer-hardware'
      };

      try {
        const support = await VideoEncoder.isConfigSupported(config);
        if (!support.supported) {
          encoder.close();
          return null;
        }

        encoder.configure(config);

        for (let i = 0; i < 20; i++) {
          if (encoder.state === 'configured') return encoder;
          if (encoder.state === 'closed') return null;
          await new Promise(resolve => setTimeout(resolve, 5));
        }

        if (encoder.state === 'configured') return encoder;
        encoder.close();
        return null;
      } catch (e) {
        if (encoder.state !== 'closed') encoder.close();
        return null;
      }
    };

    // A comprehensive list of H.264 profiles from High 5.2 down to Baseline 3.0
    // Different browsers / OS combinations support different sub-levels.
    const h264ProfilesToTry = [
      'avc1.640034', // High Profile, Level 5.2
      'avc1.640028', // High Profile, Level 4.0
      'avc1.4D4028', // Main Profile, Level 4.0
      'avc1.4D401F', // Main Profile, Level 3.1
      'avc1.42E028', // Baseline Profile, Level 4.0
      'avc1.42E01F', // Baseline Profile, Level 3.1
      'avc1.42001E', // Baseline Profile, Level 3.0
    ];

    for (const codec of h264ProfilesToTry) {
      console.log("Probing H.264 profile:", codec);
      const encoder = await tryConfigure(codec);
      if (encoder) {
        console.log("Successfully configured VideoEncoder with:", codec);
        this.videoEncoder = encoder;
        return;
      }
    }

    throw new Error("Failed to configure VideoEncoder with any H.264 profile on this browser.");
  },

  async addFrame(rgbaBytes, width, height) {
    if (!this.videoEncoder || this.videoEncoder.state === 'closed') {
      console.warn('Skipping frame: VideoEncoder is closed or missing.');
      return;
    }

    const w = Math.floor(width / 2) * 2;
    const h = Math.floor(height / 2) * 2;

    const frame = new VideoFrame(rgbaBytes, {
      format: 'RGBA',
      codedWidth: w,
      codedHeight: h,
      timestamp: (this.frameCounter * 1e6) / this.fps,
    });

    this.videoEncoder.encode(frame);
    frame.close();
    this.frameCounter++;
  },

  async finish(filename) {
    if (this.videoEncoder && this.videoEncoder.state !== 'closed') {
      await this.videoEncoder.flush();
      this.videoEncoder.close();
    }
    this.muxer.finalize();

    const buffer = this.muxer.target.buffer;
    const blob = new Blob([buffer], { type: 'video/mp4' });
    const url = URL.createObjectURL(blob);

    const a = document.createElement('a');
    a.href = url;
    a.download = filename || 'laminar_export.mp4';
    document.body.appendChild(a);
    a.click();

    setTimeout(() => {
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    }, 100);

    this.muxer = null;
    this.videoEncoder = null;
    return "Download Triggered Natively";
  }
};
