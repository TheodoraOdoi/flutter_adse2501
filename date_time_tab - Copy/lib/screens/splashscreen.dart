// Our application's splash screen
// import the flutter material package
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
  }

  class _SplashScreenState extends State<SplashScreen>
      with SingleTickerProviderStateMixin {
    late final AnimationController _controller;
    late final Animation<double> _progress;

    @override
    void initState() {
      super.initState();

      // Animate the progress from 0 -> 1 over 4 seconds
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 4)
      );
      _progress = CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      );

      _controller.forward();

      // When the animation completes
      _controller.addStatusListener((status)
      {
        if (status == AnimationStatus.completed)
          {
            // Assumes your main screen is registered as '/home'
            Navigator.of(context).pushReplacementNamed('/home'); // will be added
          }
      });
    }

    @override
    void dispose() {
      _controller.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context)
    {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
            children: [
              // TODO: Add a background image from the images folder
              Image.asset(
                'assets/images/mocktail_01.png',
                fit: BoxFit.cover,
              ),
              // Image.network("https://pixabay.com/images/download/openclipart-vectors-car-158795_1920.png",
              //   fit: BoxFit.contain,
              // ),

              // Dark transparent overlay
              Container(color: Colors.black.withValues(alpha: .55),),

              // Centered content
              SafeArea(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24), 
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                        "Welcome to our app",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'edge_bold', // from pubspec.yaml
                          fontSize: 32,
                          color: Colors.white,
                          letterSpacing: 1.1,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedBuilder(animation: _progress,
                          builder: (context, _) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _progress.value, // 0 -> 1 over 4 seconds
                                minHeight: 8,
                                backgroundColor: Colors.white,
                                color: Colors.red, // Red progress bar
                              ),
                            );
                          }
                      ),
                        ],
                  ),
              ),
              )
            ),
            ],
          )
        );
    }
}