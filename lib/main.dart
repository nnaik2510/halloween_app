import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(SpookyHalloweenApp());
}

class SpookyHalloweenApp extends StatelessWidget {
  const SpookyHalloweenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpookyGameScreen(),
    );
  }
}

class SpookyGameScreen extends StatefulWidget {
  const SpookyGameScreen({super.key});

  @override
  _SpookyGameScreenState createState() => _SpookyGameScreenState();
}

class _SpookyGameScreenState extends State<SpookyGameScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // Play background music in a loop
    _audioPlayer.setReleaseMode(ReleaseMode.LOOP);
    _audioPlayer.play('assets/sounds/halloween_music.mp3', isLocal: true);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/spooky_background.png', fit: BoxFit.cover),
          ),
          // Generate multiple spooky items (4 traps and 1 winning element)
          ...List.generate(4, (index) => SpookyItem(isWinningItem: false)),
          SpookyItem(isWinningItem: true),
        ],
      ),
    );
  }
}

class SpookyItem extends StatefulWidget {
  final bool isWinningItem;
  
  const SpookyItem({super.key, required this.isWinningItem});

  @override
  _SpookyItemState createState() => _SpookyItemState();
}

class _SpookyItemState extends State<SpookyItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _leftAnimation;
  late Animation<double> _topAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  final Random _random = Random();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _randomizeAnimations();
    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _randomizeAnimations();
        _controller.forward(from: 0.0);
      }
    });
  }

  void _randomizeAnimations() {
    _leftAnimation = Tween<double>(
      begin: _random.nextDouble() * 300,
      end: _random.nextDouble() * 300,
    ).animate(_controller);

    _topAnimation = Tween<double>(
      begin: _random.nextDouble() * 600,
      end: _random.nextDouble() * 600,
    ).animate(_controller);

    _scaleAnimation = Tween<double>(
      begin: 0.5 + _random.nextDouble(),
      end: 0.5 + _random.nextDouble(),
    ).animate(_controller);

    _rotationAnimation = Tween<double>(
      begin: _random.nextDouble() * pi * 2,
      end: _random.nextDouble() * pi * 2,
    ).animate(_controller);
  }

  void _handleTap() {
    if (widget.isWinningItem) {
      // Play success sound and show message
      _audioPlayer.play('assets/sounds/success.mp3', isLocal: true);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("You Found It!"),
          content: const Text("Congratulations, you found the correct item!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      // Play jump scare sound for trap items
      _audioPlayer.play('assets/sounds/jumpscare.mp3', isLocal: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _leftAnimation.value,
          top: _topAnimation.value,
          child: GestureDetector(
            onTap: _handleTap,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: widget.isWinningItem
                    ? Image.asset('assets/images/correct_item.png', width: 50, height: 50)
                    : Image.asset('assets/images/ghost.png', width: 50, height: 50),
              ),
            ),
          ),
        );
      },
    );
  }
}
