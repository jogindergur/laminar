import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:laminar/laminar.dart';

// Starbucks brand green
const _kGreen = Color(0xFF1E3932);

/// Starbucks Logo Composition — 5 s @ 30 fps (150 frames, looping).
///
/// The vector path is taken 1-to-1 from the official Starbucks SVG
/// (Wikipedia CC licence, viewBox 237.4 × 240.3).
///
/// Timeline
///   0  – 25  : fade-in + scale-up  (easeOutCubic)
///   30 – 90  : logo rotates a full 360° slowly
///   60 – 120 : pulsing outer glow
///  128 – 150 : fade-out + scale-down (easeInCubic)
class StarbucksLogoComposition extends StatelessWidget {
  const StarbucksLogoComposition({super.key});

  @override
  Widget build(BuildContext context) {
    final frame = useCurrentFrame(context);
    final config = useVideoConfig(context);
    final total = config.durationInFrames;

    // Opacity envelope
    final fadeIn = interpolate(
      frame,
      [0, 25],
      [0.0, 1.0],
      easing: LaminarEasing.easeOutCubic,
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );
    final fadeOut = interpolate(
      frame,
      [128, total],
      [1.0, 0.0],
      easing: LaminarEasing.easeInCubic,
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );
    final opacity = (fadeIn * fadeOut).clamp(0.0, 1.0);

    // Scale envelope
    final scaleIn = interpolate(
      frame,
      [0, 38],
      [0.35, 1.0],
      easing: LaminarEasing.easeOutCubic,
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );
    final scaleOut = interpolate(
      frame,
      [128, total],
      [1.0, 0.80],
      easing: LaminarEasing.easeInCubic,
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );
    final scale = scaleIn * scaleOut;

    // Slow rotation 0→360° during frames 30-120
    final rotation = interpolate(
      frame,
      [30, 120],
      [0.0, 2 * math.pi],
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );

    // Glow pulse during frames 60-120
    final glowT = interpolate(
      frame,
      [60, 120],
      [0.0, 1.0],
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );
    final glowRadius = 14.0 + 16.0 * math.sin(glowT * 2 * math.pi * 2.5);

    // Text slide-up
    final textSlide = interpolate(
      frame,
      [10, 42],
      [24.0, 0.0],
      easing: LaminarEasing.easeOutCubic,
      extrapolateLeft: Extrapolate.clamp,
      extrapolateRight: Extrapolate.clamp,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Mint background
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.3,
              colors: [Color(0xFFB2D8D0), Color(0xFFD4E9E2)],
            ),
          ),
        ),

        // Logo centred
        Center(
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo canvas — square, same as the SVG viewBox aspect (237.4:240.3 ≈ 1:1)
                  SizedBox(
                    width: 260,
                    height: 263,
                    child: CustomPaint(
                      painter: _StarbucksLogoPainter(rotation: rotation, glowRadius: glowRadius, opacity: opacity),
                    ),
                  ),

                  // Gap — logo and text never touch
                  const SizedBox(height: 36),

                  // Tagline
                  Transform.translate(
                    offset: Offset(0, textSlide),
                    child: Column(
                      children: [
                        Text(
                          'Starbucks Coffee',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Helvetica Neue',
                            fontFamilyFallback: const ['Helvetica', 'Arial'],
                            color: _kGreen.withValues(alpha: 0.90),
                            fontSize: 22,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 3.0,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'frame $frame / $total',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Helvetica Neue',
                            fontFamilyFallback: const ['Helvetica', 'Arial'],
                            color: _kGreen.withValues(alpha: 0.30),
                            fontSize: 11,
                            letterSpacing: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Starbucks logo painter
//
// The path coordinates are 1-to-1 from the official SVG, normalised by dividing
// every X by 237.4 and every Y by 240.3 (the SVG viewBox dimensions).
// The white circle (st0) is drawn first, then the green siren + detail (st1).
// ─────────────────────────────────────────────────────────────────────────────
class _StarbucksLogoPainter extends CustomPainter {
  final double rotation;
  final double glowRadius;
  final double opacity;

  const _StarbucksLogoPainter({required this.rotation, required this.glowRadius, required this.opacity});

  // Build white circle path (st0)
  Path _whitePath(double w, double h) {
    final p = Path();
    p.moveTo(w * 1.0, h * 0.49397);
    p.cubicTo(w * 1.0, h * 0.76696, w * 0.77591, h * 0.98793, w * 0.5, h * 0.98793);
    p.cubicTo(w * 0.22367, h * 0.98793, w * 0.0, h * 0.76654, w * 0.0, h * 0.49397);
    p.cubicTo(w * 0.0, h * 0.22097, w * 0.22409, h * 0.0, w * 0.5, h * 0.0);
    p.cubicTo(w * 0.77591, h * 0.0, w * 1.0, h * 0.22097, w * 1.0, h * 0.49397);
    return p;
  }

  // Build full green siren path (st1) — every sub-path in order
  Path _greenPath(double w, double h) {
    // ignore: non_constant_identifier_names
    double X(double n) => n * w;
    // ignore: non_constant_identifier_names
    double Y(double n) => n * h;
    final p = Path();

    // ── Crown / hair ornament at top ─────────────────────────────────────────
    p.moveTo(X(0.55013), Y(0.21348));
    p.cubicTo(X(0.54591), Y(0.21265), X(0.52485), Y(0.20932), X(0.5), Y(0.20932));
    p.cubicTo(X(0.47515), Y(0.20932), X(0.45409), Y(0.21265), X(0.44987), Y(0.21348));
    p.cubicTo(X(0.44735), Y(0.2139), X(0.4465), Y(0.2114), X(0.44819), Y(0.21015));
    p.cubicTo(X(0.44987), Y(0.20891), X(0.5), Y(0.17104), X(0.5), Y(0.17104));
    p.cubicTo(X(0.5), Y(0.17104), X(0.55013), Y(0.20891), X(0.55181), Y(0.21015));
    p.cubicTo(X(0.5535), Y(0.2114), X(0.55265), Y(0.2139), X(0.55013), Y(0.21348));

    // ── Small detail near mouth ───────────────────────────────────────────────
    p.moveTo(X(0.46335), Y(0.45818));
    p.cubicTo(X(0.46335), Y(0.45818), X(0.46083), Y(0.45901), X(0.45998), Y(0.46151));
    p.cubicTo(X(0.47051), Y(0.46941), X(0.47767), Y(0.48772), X(0.49958), Y(0.48772));
    p.cubicTo(X(0.52148), Y(0.48772), X(0.52864), Y(0.46941), X(0.53917), Y(0.46151));
    p.cubicTo(X(0.53833), Y(0.45901), X(0.5358), Y(0.45818), X(0.5358), Y(0.45818));
    p.cubicTo(X(0.5358), Y(0.45818), X(0.5219), Y(0.46151), X(0.49958), Y(0.46151));
    p.cubicTo(X(0.47725), Y(0.46151), X(0.46335), Y(0.45818), X(0.46335), Y(0.45818));

    // ── Nose / lip detail ────────────────────────────────────────────────────
    p.moveTo(X(0.49958), Y(0.4278));
    p.cubicTo(X(0.49368), Y(0.4278), X(0.492), Y(0.42572), X(0.48821), Y(0.42572));
    p.cubicTo(X(0.48441), Y(0.42572), X(0.47641), Y(0.42905), X(0.47473), Y(0.43154));
    p.cubicTo(X(0.47473), Y(0.43279), X(0.47557), Y(0.43404), X(0.47641), Y(0.43529));
    p.cubicTo(X(0.48526), Y(0.43654), X(0.48947), Y(0.44153), X(0.49958), Y(0.44153));
    p.cubicTo(X(0.50969), Y(0.44153), X(0.5139), Y(0.43654), X(0.52275), Y(0.43529));
    p.cubicTo(X(0.52401), Y(0.43404), X(0.52443), Y(0.43279), X(0.52443), Y(0.43154));
    p.cubicTo(X(0.52275), Y(0.42863), X(0.51516), Y(0.42572), X(0.51095), Y(0.42572));
    p.cubicTo(X(0.50716), Y(0.4253), X(0.5059), Y(0.4278), X(0.49958), Y(0.4278));

    // ── Main siren body + outer ring (the large compound path) ───────────────
    p.moveTo(X(0.99916), Y(0.52102));
    p.cubicTo(X(0.99832), Y(0.53267), X(0.99747), Y(0.54474), X(0.99621), Y(0.55597));
    p.cubicTo(X(0.93976), Y(0.56513), X(0.91955), Y(0.51561), X(0.86142), Y(0.51769));
    p.cubicTo(X(0.86479), Y(0.52975), X(0.86773), Y(0.54224), X(0.86984), Y(0.55472));
    p.cubicTo(X(0.91786), Y(0.55472), X(0.93682), Y(0.59883), X(0.99031), Y(0.59218));
    p.cubicTo(X(0.98736), Y(0.60549), X(0.98399), Y(0.61881), X(0.9802), Y(0.63213));
    p.cubicTo(X(0.93808), Y(0.63629), X(0.92334), Y(0.59509), X(0.87447), Y(0.59592));
    p.cubicTo(X(0.87489), Y(0.603), X(0.87489), Y(0.60965), X(0.87489), Y(0.61673));
    p.cubicTo(X(0.87489), Y(0.62047), X(0.87489), Y(0.62464), X(0.87447), Y(0.62838));
    p.cubicTo(X(0.91618), Y(0.62797), X(0.92965), Y(0.66583), X(0.96925), Y(0.66417));
    p.cubicTo(X(0.9642), Y(0.67749), X(0.95872), Y(0.69039), X(0.95282), Y(0.70329));
    p.cubicTo(X(0.92418), Y(0.70162), X(0.91449), Y(0.66583), X(0.87152), Y(0.66875));
    p.cubicTo(X(0.87026), Y(0.6779), X(0.86858), Y(0.68706), X(0.86647), Y(0.69621));
    p.cubicTo(X(0.90396), Y(0.69372), X(0.91196), Y(0.72784), X(0.93892), Y(0.73034));
    p.cubicTo(X(0.93218), Y(0.74282), X(0.9246), Y(0.75489), X(0.91702), Y(0.76654));
    p.cubicTo(X(0.90101), Y(0.75822), X(0.88711), Y(0.73283), X(0.8572), Y(0.73117));
    p.cubicTo(X(0.86015), Y(0.7216), X(0.8631), Y(0.71203), X(0.86521), Y(0.70246));
    p.cubicTo(X(0.83825), Y(0.70246), X(0.80792), Y(0.69205), X(0.78222), Y(0.66916));
    p.cubicTo(X(0.79065), Y(0.62214), X(0.71693), Y(0.5747), X(0.71693), Y(0.54016));
    p.cubicTo(X(0.71693), Y(0.50312), X(0.73589), Y(0.48231), X(0.73589), Y(0.43196));
    p.cubicTo(X(0.73589), Y(0.39451), X(0.71735), Y(0.35414), X(0.68997), Y(0.32667));
    p.cubicTo(X(0.6845), Y(0.32127), X(0.67902), Y(0.3171), X(0.6727), Y(0.31294));
    p.cubicTo(X(0.69798), Y(0.34415), X(0.71778), Y(0.38077), X(0.71778), Y(0.42364));
    p.cubicTo(X(0.71778), Y(0.47108), X(0.69545), Y(0.49605), X(0.69545), Y(0.53974));
    p.cubicTo(X(0.69545), Y(0.58344), X(0.76032), Y(0.62131), X(0.76032), Y(0.66625));
    p.cubicTo(X(0.76032), Y(0.68414), X(0.75442), Y(0.70121), X(0.73589), Y(0.73533));
    p.cubicTo(X(0.76495), Y(0.76404), X(0.80286), Y(0.77944), X(0.8273), Y(0.77944));
    p.cubicTo(X(0.8353), Y(0.77944), X(0.83951), Y(0.77695), X(0.84246), Y(0.77112));
    p.cubicTo(X(0.84499), Y(0.76571), X(0.84709), Y(0.7603), X(0.8492), Y(0.75489));
    p.cubicTo(X(0.87532), Y(0.75572), X(0.88753), Y(0.77944), X(0.90185), Y(0.78901));
    p.cubicTo(X(0.89385), Y(0.79942), X(0.88543), Y(0.80982), X(0.87658), Y(0.81981));
    p.cubicTo(X(0.86689), Y(0.80899), X(0.85383), Y(0.79109), X(0.83446), Y(0.7861));
    p.cubicTo(X(0.83109), Y(0.79276), X(0.8273), Y(0.799), X(0.8235), Y(0.80566));
    p.cubicTo(X(0.83993), Y(0.81024), X(0.85131), Y(0.82647), X(0.86015), Y(0.83729));
    p.cubicTo(X(0.85088), Y(0.84686), X(0.84078), Y(0.85601), X(0.83067), Y(0.86517));
    p.cubicTo(X(0.82435), Y(0.8556), X(0.81424), Y(0.84311), X(0.80329), Y(0.83604));
    p.cubicTo(X(0.79907), Y(0.84145), X(0.79486), Y(0.84686), X(0.79065), Y(0.85227));
    p.cubicTo(X(0.80034), Y(0.85851), X(0.80834), Y(0.87016), X(0.81382), Y(0.87932));
    p.cubicTo(X(0.80202), Y(0.88889), X(0.78981), Y(0.89763), X(0.77717), Y(0.90595));
    p.cubicTo(X(0.77085), Y(0.8556), X(0.70177), Y(0.82147), X(0.7203), Y(0.76321));
    p.cubicTo(X(0.71398), Y(0.77362), X(0.70682), Y(0.78652), X(0.70682), Y(0.80191));
    p.cubicTo(X(0.70682), Y(0.84395), X(0.75232), Y(0.87765), X(0.75569), Y(0.91927));
    p.cubicTo(X(0.74642), Y(0.92468), X(0.73673), Y(0.93009), X(0.72662), Y(0.93508));
    p.cubicTo(X(0.72494), Y(0.88889), X(0.67692), Y(0.83854), X(0.67692), Y(0.80108));
    p.cubicTo(X(0.67692), Y(0.75905), X(0.73294), Y(0.7166), X(0.73294), Y(0.66667));
    p.cubicTo(X(0.73294), Y(0.61673), X(0.66849), Y(0.58219), X(0.66849), Y(0.53849));
    p.cubicTo(X(0.66849), Y(0.4948), X(0.69587), Y(0.46983), X(0.69587), Y(0.41365));
    p.cubicTo(X(0.69587), Y(0.37245), X(0.67607), Y(0.33125), X(0.64575), Y(0.30462));
    p.cubicTo(X(0.64027), Y(0.30004), X(0.63521), Y(0.2963), X(0.62848), Y(0.29297));
    p.cubicTo(X(0.65712), Y(0.32709), X(0.67397), Y(0.35789), X(0.67397), Y(0.40491));
    p.cubicTo(X(0.67397), Y(0.45776), X(0.64238), Y(0.48689), X(0.64238), Y(0.53849));
    p.cubicTo(X(0.64238), Y(0.5901), X(0.70556), Y(0.61881), X(0.70556), Y(0.66667));
    p.cubicTo(X(0.70556), Y(0.71452), X(0.64659), Y(0.75531), X(0.64659), Y(0.80483));
    p.cubicTo(X(0.64659), Y(0.84977), X(0.6984), Y(0.89471), X(0.69924), Y(0.94798));
    p.cubicTo(X(0.68787), Y(0.95298), X(0.6765), Y(0.95755), X(0.6647), Y(0.9613));
    p.cubicTo(X(0.67144), Y(0.90762), X(0.61289), Y(0.85185), X(0.61289), Y(0.80774));
    p.cubicTo(X(0.61289), Y(0.75988), X(0.67397), Y(0.71827), X(0.67397), Y(0.66667));
    p.cubicTo(X(0.67397), Y(0.61506), X(0.61205), Y(0.59093), X(0.61205), Y(0.53766));
    p.cubicTo(X(0.61205), Y(0.48439), X(0.65038), Y(0.45485), X(0.65038), Y(0.39617));
    p.cubicTo(X(0.65038), Y(0.3504), X(0.62763), Y(0.3092), X(0.59393), Y(0.28381));
    p.cubicTo(X(0.59309), Y(0.2834), X(0.59267), Y(0.28256), X(0.59183), Y(0.28215));
    p.cubicTo(X(0.58888), Y(0.27965), X(0.58593), Y(0.28256), X(0.58846), Y(0.28548));
    p.cubicTo(X(0.61205), Y(0.31461), X(0.62468), Y(0.34415), X(0.62468), Y(0.38785));
    p.cubicTo(X(0.62468), Y(0.44153), X(0.58088), Y(0.48523), X(0.58088), Y(0.53725));
    p.cubicTo(X(0.58088), Y(0.59883), X(0.63985), Y(0.61631), X(0.63985), Y(0.66667));
    p.cubicTo(X(0.63985), Y(0.71702), X(0.57666), Y(0.75739), X(0.57666), Y(0.81107));
    p.cubicTo(X(0.57666), Y(0.86059), X(0.63648), Y(0.91594), X(0.62595), Y(0.97295));
    p.cubicTo(X(0.61415), Y(0.97586), X(0.60194), Y(0.97878), X(0.58972), Y(0.98086));
    p.cubicTo(X(0.6011), Y(0.9097), X(0.54254), Y(0.85809), X(0.54254), Y(0.81149));
    p.cubicTo(X(0.54254), Y(0.76113), X(0.60783), Y(0.71577), X(0.60783), Y(0.66667));
    p.cubicTo(X(0.60783), Y(0.62006), X(0.56108), Y(0.60508), X(0.55476), Y(0.55722));
    p.cubicTo(X(0.55392), Y(0.55056), X(0.54844), Y(0.54598), X(0.54128), Y(0.54723));
    p.cubicTo(X(0.53159), Y(0.5489), X(0.51938), Y(0.55514), X(0.50042), Y(0.55514));
    p.cubicTo(X(0.48104), Y(0.55514), X(0.46925), Y(0.5489), X(0.45956), Y(0.54723));
    p.cubicTo(X(0.4524), Y(0.54598), X(0.44693), Y(0.55098), X(0.44608), Y(0.55722));
    p.cubicTo(X(0.43976), Y(0.60508), X(0.39301), Y(0.62006), X(0.39301), Y(0.66667));
    p.cubicTo(X(0.39301), Y(0.71619), X(0.4583), Y(0.76113), X(0.4583), Y(0.81149));
    p.cubicTo(X(0.4583), Y(0.85809), X(0.39975), Y(0.90928), X(0.41112), Y(0.98086));
    p.cubicTo(X(0.3989), Y(0.97878), X(0.38669), Y(0.97586), X(0.37489), Y(0.97295));
    p.cubicTo(X(0.36479), Y(0.91552), X(0.42418), Y(0.86059), X(0.42418), Y(0.81107));
    p.cubicTo(X(0.42418), Y(0.75739), X(0.36099), Y(0.71702), X(0.36099), Y(0.66667));
    p.cubicTo(X(0.36099), Y(0.61631), X(0.41997), Y(0.59883), X(0.41997), Y(0.53725));
    p.cubicTo(X(0.41997), Y(0.48523), X(0.37616), Y(0.44153), X(0.37616), Y(0.38785));
    p.cubicTo(X(0.37616), Y(0.34415), X(0.3888), Y(0.31461), X(0.41238), Y(0.28548));
    p.cubicTo(X(0.41449), Y(0.28256), X(0.41196), Y(0.28007), X(0.40901), Y(0.28215));
    p.cubicTo(X(0.40817), Y(0.28256), X(0.40775), Y(0.2834), X(0.40691), Y(0.28381));
    p.cubicTo(X(0.37363), Y(0.3092), X(0.35046), Y(0.3504), X(0.35046), Y(0.39617));
    p.cubicTo(X(0.35046), Y(0.45485), X(0.3888), Y(0.48439), X(0.3888), Y(0.53766));
    p.cubicTo(X(0.3888), Y(0.59093), X(0.32687), Y(0.61506), X(0.32687), Y(0.66667));
    p.cubicTo(X(0.32687), Y(0.71827), X(0.38795), Y(0.75988), X(0.38795), Y(0.80774));
    p.cubicTo(X(0.38795), Y(0.85185), X(0.3294), Y(0.9072), X(0.33614), Y(0.9613));
    p.cubicTo(X(0.32435), Y(0.95714), X(0.31297), Y(0.95298), X(0.3016), Y(0.94798));
    p.cubicTo(X(0.30244), Y(0.89471), X(0.35425), Y(0.84977), X(0.35425), Y(0.80483));
    p.cubicTo(X(0.35425), Y(0.75531), X(0.29528), Y(0.71494), X(0.29528), Y(0.66667));
    p.cubicTo(X(0.29528), Y(0.61839), X(0.35847), Y(0.5901), X(0.35847), Y(0.53849));
    p.cubicTo(X(0.35847), Y(0.48689), X(0.32687), Y(0.45776), X(0.32687), Y(0.40491));
    p.cubicTo(X(0.32687), Y(0.35789), X(0.34372), Y(0.32709), X(0.37237), Y(0.29297));
    p.cubicTo(X(0.36605), Y(0.2963), X(0.36057), Y(0.30004), X(0.3551), Y(0.30462));
    p.cubicTo(X(0.32477), Y(0.33125), X(0.30497), Y(0.37287), X(0.30497), Y(0.41365));
    p.cubicTo(X(0.30497), Y(0.46983), X(0.33235), Y(0.4948), X(0.33235), Y(0.53849));
    p.cubicTo(X(0.33235), Y(0.58219), X(0.2679), Y(0.61673), X(0.2679), Y(0.66667));
    p.cubicTo(X(0.2679), Y(0.7166), X(0.32393), Y(0.75864), X(0.32393), Y(0.80108));
    p.cubicTo(X(0.32393), Y(0.83895), X(0.27591), Y(0.88931), X(0.27422), Y(0.93508));
    p.cubicTo(X(0.26453), Y(0.93009), X(0.25484), Y(0.92509), X(0.24516), Y(0.91927));
    p.cubicTo(X(0.24895), Y(0.87724), X(0.29444), Y(0.84395), X(0.29444), Y(0.80191));
    p.cubicTo(X(0.29444), Y(0.78652), X(0.28728), Y(0.77362), X(0.28096), Y(0.76321));
    p.cubicTo(X(0.29949), Y(0.82147), X(0.23041), Y(0.85601), X(0.22409), Y(0.90595));
    p.cubicTo(X(0.21146), Y(0.89763), X(0.19924), Y(0.88889), X(0.18745), Y(0.87932));
    p.cubicTo(X(0.19292), Y(0.87016), X(0.20135), Y(0.85851), X(0.21061), Y(0.85227));
    p.cubicTo(X(0.2064), Y(0.84686), X(0.20177), Y(0.84186), X(0.19798), Y(0.83604));
    p.cubicTo(X(0.1866), Y(0.8427), X(0.17692), Y(0.85518), X(0.1706), Y(0.86517));
    p.cubicTo(X(0.16049), Y(0.85643), X(0.15038), Y(0.84686), X(0.14111), Y(0.83729));
    p.cubicTo(X(0.14996), Y(0.82647), X(0.16133), Y(0.80982), X(0.17776), Y(0.80566));
    p.cubicTo(X(0.17397), Y(0.79942), X(0.17018), Y(0.79276), X(0.16681), Y(0.7861));
    p.cubicTo(X(0.14743), Y(0.79109), X(0.13437), Y(0.80899), X(0.12468), Y(0.81981));
    p.cubicTo(X(0.11584), Y(0.80982), X(0.10741), Y(0.79983), X(0.09941), Y(0.78901));
    p.cubicTo(X(0.11415), Y(0.77944), X(0.12595), Y(0.75614), X(0.15249), Y(0.75489));
    p.cubicTo(X(0.15459), Y(0.7603), X(0.15712), Y(0.76571), X(0.15922), Y(0.77112));
    p.cubicTo(X(0.16217), Y(0.77736), X(0.16639), Y(0.77944), X(0.17439), Y(0.77944));
    p.cubicTo(X(0.19882), Y(0.77944), X(0.23673), Y(0.76363), X(0.2658), Y(0.73533));
    p.cubicTo(X(0.24684), Y(0.70121), X(0.24136), Y(0.68414), X(0.24136), Y(0.66625));
    p.cubicTo(X(0.24136), Y(0.62131), X(0.30623), Y(0.58344), X(0.30623), Y(0.53974));
    p.cubicTo(X(0.30623), Y(0.49605), X(0.28391), Y(0.47108), X(0.28391), Y(0.42364));
    p.cubicTo(X(0.28391), Y(0.38077), X(0.30329), Y(0.34415), X(0.32898), Y(0.31294));
    p.cubicTo(X(0.32266), Y(0.31669), X(0.31719), Y(0.32127), X(0.31171), Y(0.32667));
    p.cubicTo(X(0.28391), Y(0.35414), X(0.2658), Y(0.39492), X(0.2658), Y(0.43196));
    p.cubicTo(X(0.2658), Y(0.48231), X(0.28475), Y(0.5027), X(0.28475), Y(0.54016));
    p.cubicTo(X(0.28475), Y(0.5747), X(0.21104), Y(0.62214), X(0.21946), Y(0.66916));
    p.cubicTo(X(0.19377), Y(0.69247), X(0.16302), Y(0.70246), X(0.13606), Y(0.70246));
    p.cubicTo(X(0.13858), Y(0.71203), X(0.14111), Y(0.7216), X(0.14406), Y(0.73117));
    p.cubicTo(X(0.11373), Y(0.73283), X(0.09983), Y(0.75822), X(0.08425), Y(0.76654));
    p.cubicTo(X(0.07624), Y(0.75489), X(0.06908), Y(0.74282), X(0.06234), Y(0.73034));
    p.cubicTo(X(0.0893), Y(0.72742), X(0.0973), Y(0.6933), X(0.13479), Y(0.69621));
    p.cubicTo(X(0.13269), Y(0.68706), X(0.131), Y(0.6779), X(0.12974), Y(0.66875));
    p.cubicTo(X(0.08635), Y(0.66583), X(0.07666), Y(0.70204), X(0.04844), Y(0.70329));
    p.cubicTo(X(0.04254), Y(0.69039), X(0.03707), Y(0.67749), X(0.03201), Y(0.66417));
    p.cubicTo(X(0.07161), Y(0.66583), X(0.08509), Y(0.62797), X(0.12637), Y(0.62838));
    p.cubicTo(X(0.12637), Y(0.62464), X(0.12637), Y(0.62089), X(0.12637), Y(0.61673));
    p.cubicTo(X(0.12637), Y(0.60965), X(0.12679), Y(0.603), X(0.12679), Y(0.59592));
    p.cubicTo(X(0.07793), Y(0.59467), X(0.06318), Y(0.63629), X(0.02106), Y(0.63213));
    p.cubicTo(X(0.01727), Y(0.61923), X(0.0139), Y(0.60591), X(0.01095), Y(0.59218));
    p.cubicTo(X(0.06403), Y(0.59883), X(0.0834), Y(0.55431), X(0.13142), Y(0.55472));
    p.cubicTo(X(0.13353), Y(0.54224), X(0.13648), Y(0.52975), X(0.13985), Y(0.51769));
    p.cubicTo(X(0.08172), Y(0.51519), X(0.0615), Y(0.56513), X(0.00505), Y(0.55597));
    p.cubicTo(X(0.00337), Y(0.54432), X(0.00253), Y(0.53267), X(0.00168), Y(0.52102));
    p.cubicTo(X(0.0674), Y(0.52809), X(0.09225), Y(0.47482), X(0.15206), Y(0.48148));
    p.cubicTo(X(0.15754), Y(0.46733), X(0.16428), Y(0.4536), X(0.17186), Y(0.44028));
    p.cubicTo(X(0.09688), Y(0.42738), X(0.07119), Y(0.48939), X(0.00126), Y(0.47982));
    p.cubicTo(X(0.00716), Y(0.21348), X(0.22831), Y(0.0), X(0.49958), Y(0.0));
    p.cubicTo(X(0.77127), Y(0.0), X(0.992), Y(0.21348), X(0.99958), Y(0.48023));
    p.cubicTo(X(0.92965), Y(0.4898), X(0.90396), Y(0.4278), X(0.82898), Y(0.4407));
    p.cubicTo(X(0.83656), Y(0.45402), X(0.84288), Y(0.46775), X(0.84878), Y(0.4819));
    p.cubicTo(X(0.90859), Y(0.47482), X(0.93302), Y(0.52851), X(0.99916), Y(0.52102));

    // ── Left side detail / fish tail ─────────────────────────────────────────
    p.moveTo(X(0.28475), Y(0.31377));
    p.cubicTo(X(0.2481), Y(0.29879), X(0.20345), Y(0.30254), X(0.16512), Y(0.32667));
    p.cubicTo(X(0.15922), Y(0.29172), X(0.13985), Y(0.26051), X(0.11247), Y(0.24178));
    p.cubicTo(X(0.10868), Y(0.23928), X(0.10489), Y(0.24178), X(0.10489), Y(0.24594));
    p.cubicTo(X(0.11078), Y(0.32002), X(0.06698), Y(0.3841), X(0.01306), Y(0.4407));
    p.cubicTo(X(0.06866), Y(0.45734), X(0.11584), Y(0.3866), X(0.18745), Y(0.41115));
    p.cubicTo(X(0.21398), Y(0.37328), X(0.24684), Y(0.33999), X(0.28475), Y(0.31377));

    // ── Face / head (siren) ───────────────────────────────────────────────────
    p.moveTo(X(0.49958), Y(0.26925));
    p.cubicTo(X(0.45324), Y(0.26925), X(0.41407), Y(0.29505), X(0.40396), Y(0.32876));
    p.cubicTo(X(0.40312), Y(0.33125), X(0.40438), Y(0.33292), X(0.40733), Y(0.33167));
    p.cubicTo(X(0.41575), Y(0.32792), X(0.42502), Y(0.32626), X(0.43555), Y(0.32626));
    p.cubicTo(X(0.45451), Y(0.32626), X(0.47136), Y(0.33333), X(0.48104), Y(0.34499));
    p.cubicTo(X(0.48526), Y(0.35913), X(0.48568), Y(0.37994), X(0.48062), Y(0.39159));
    p.cubicTo(X(0.47304), Y(0.38993), X(0.47009), Y(0.3841), X(0.46251), Y(0.3841));
    p.cubicTo(X(0.45493), Y(0.3841), X(0.44903), Y(0.38951), X(0.43597), Y(0.38951));
    p.cubicTo(X(0.42291), Y(0.38951), X(0.42165), Y(0.38327), X(0.41323), Y(0.38327));
    p.cubicTo(X(0.40312), Y(0.38327), X(0.40143), Y(0.39326), X(0.40143), Y(0.40491));
    p.cubicTo(X(0.40143), Y(0.4561), X(0.44903), Y(0.52643), X(0.49958), Y(0.52643));
    p.cubicTo(X(0.55013), Y(0.52643), X(0.59773), Y(0.4561), X(0.59773), Y(0.40491));
    p.cubicTo(X(0.59773), Y(0.39326), X(0.5952), Y(0.38369), X(0.58509), Y(0.38244));
    p.cubicTo(X(0.58003), Y(0.38618), X(0.57498), Y(0.38951), X(0.56318), Y(0.38951));
    p.cubicTo(X(0.55013), Y(0.38951), X(0.54676), Y(0.3841), X(0.53917), Y(0.3841));
    p.cubicTo(X(0.52991), Y(0.3841), X(0.53075), Y(0.40325), X(0.5198), Y(0.40449));
    p.cubicTo(X(0.51264), Y(0.38743), X(0.51222), Y(0.36496), X(0.51811), Y(0.3454));
    p.cubicTo(X(0.5278), Y(0.33333), X(0.54465), Y(0.32667), X(0.56361), Y(0.32667));
    p.cubicTo(X(0.57372), Y(0.32667), X(0.5834), Y(0.32834), X(0.59183), Y(0.33208));
    p.cubicTo(X(0.59478), Y(0.33333), X(0.59604), Y(0.33167), X(0.5952), Y(0.32917));
    p.cubicTo(X(0.58509), Y(0.29505), X(0.54591), Y(0.26925), X(0.49958), Y(0.26925));

    // ── Right eye detail ─────────────────────────────────────────────────────
    p.moveTo(X(0.57372), Y(0.34249));
    p.cubicTo(X(0.56234), Y(0.34249), X(0.54971), Y(0.34582), X(0.54128), Y(0.35497));
    p.cubicTo(X(0.54044), Y(0.35747), X(0.54044), Y(0.36122), X(0.5417), Y(0.3633));
    p.cubicTo(X(0.56192), Y(0.35664), X(0.57961), Y(0.35622), X(0.58846), Y(0.36579));
    p.cubicTo(X(0.59309), Y(0.36163), X(0.59436), Y(0.35789), X(0.59436), Y(0.35372));
    p.cubicTo(X(0.59436), Y(0.34707), X(0.58719), Y(0.34249), X(0.57372), Y(0.34249));

    // ── Left eye detail ──────────────────────────────────────────────────────
    p.moveTo(X(0.41112), Y(0.36579));
    p.cubicTo(X(0.42081), Y(0.35622), X(0.44145), Y(0.35664), X(0.46251), Y(0.36413));
    p.cubicTo(X(0.46335), Y(0.35372), X(0.4444), Y(0.34207), X(0.42544), Y(0.34207));
    p.cubicTo(X(0.41154), Y(0.34207), X(0.4048), Y(0.34665), X(0.4048), Y(0.35331));
    p.cubicTo(X(0.40522), Y(0.35789), X(0.40649), Y(0.36163), X(0.41112), Y(0.36579));

    // ── Crown / star detail ───────────────────────────────────────────────────
    p.moveTo(X(0.73126), Y(0.19268));
    p.cubicTo(X(0.69461), Y(0.19517), X(0.66259), Y(0.20766), X(0.6369), Y(0.22846));
    p.cubicTo(X(0.64785), Y(0.19767), X(0.66175), Y(0.17104), X(0.67944), Y(0.14524));
    p.cubicTo(X(0.63269), Y(0.15023), X(0.59393), Y(0.16687), X(0.56529), Y(0.196));
    p.lineTo(X(0.54297), Y(0.13816));
    p.lineTo(X(0.59225), Y(0.09488));
    p.lineTo(X(0.52612), Y(0.0903));
    p.lineTo(X(0.49958), Y(0.02955));
    p.lineTo(X(0.47304), Y(0.0903));
    p.lineTo(X(0.40691), Y(0.09488));
    p.lineTo(X(0.45619), Y(0.13816));
    p.lineTo(X(0.43387), Y(0.196));
    p.cubicTo(X(0.40522), Y(0.16729), X(0.36647), Y(0.15023), X(0.31971), Y(0.14524));
    p.cubicTo(X(0.33741), Y(0.17104), X(0.35131), Y(0.19809), X(0.36226), Y(0.22846));
    p.cubicTo(X(0.33656), Y(0.20766), X(0.30455), Y(0.19517), X(0.2679), Y(0.19268));
    p.cubicTo(X(0.28981), Y(0.22056), X(0.30918), Y(0.25052), X(0.32393), Y(0.28256));
    p.cubicTo(X(0.32561), Y(0.28631), X(0.32898), Y(0.28756), X(0.33277), Y(0.28548));
    p.cubicTo(X(0.3829), Y(0.26092), X(0.43934), Y(0.24677), X(0.49958), Y(0.24677));
    p.cubicTo(X(0.55939), Y(0.24677), X(0.61584), Y(0.26051), X(0.66639), Y(0.28548));
    p.cubicTo(X(0.67018), Y(0.28756), X(0.67355), Y(0.28631), X(0.67523), Y(0.28256));
    p.cubicTo(X(0.68955), Y(0.25052), X(0.70935), Y(0.22056), X(0.73126), Y(0.19268));

    // ── Right side detail / fish tail ────────────────────────────────────────
    p.moveTo(X(0.81129), Y(0.41115));
    p.cubicTo(X(0.88332), Y(0.3866), X(0.9305), Y(0.45693), X(0.9861), Y(0.4407));
    p.cubicTo(X(0.93218), Y(0.3841), X(0.88837), Y(0.32002), X(0.89427), Y(0.24594));
    p.cubicTo(X(0.89469), Y(0.24178), X(0.89048), Y(0.23928), X(0.88711), Y(0.24178));
    p.cubicTo(X(0.85973), Y(0.26051), X(0.84035), Y(0.29172), X(0.83446), Y(0.32667));
    p.cubicTo(X(0.79655), Y(0.30254), X(0.7519), Y(0.29921), X(0.71483), Y(0.31377));
    p.cubicTo(X(0.75274), Y(0.33999), X(0.78517), Y(0.37328), X(0.81129), Y(0.41115));

    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final cx = w / 2, cy = h / 2;

    // Apply slow rotation around the logo centre
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotation);
    canvas.translate(-cx, -cy);

    // White circle background
    final whitePath = _whitePath(w, h);
    canvas.drawShadow(whitePath, _kGreen.withValues(alpha: 0.4 * opacity), glowRadius, false);
    canvas.drawPath(
      whitePath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // Green siren
    final greenPath = _greenPath(w, h);
    canvas.drawPath(
      greenPath,
      Paint()
        ..color = _kGreen
        ..style = PaintingStyle.fill,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_StarbucksLogoPainter old) =>
      old.rotation != rotation || old.glowRadius != glowRadius || old.opacity != opacity;
}
