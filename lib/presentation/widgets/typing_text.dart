import 'dart:async';
import 'package:flutter/material.dart';

class TypingText extends StatefulWidget {
  const TypingText({required this.text, super.key, this.style, this.speed = const Duration(milliseconds: 14)});
  final String text;
  final TextStyle? style;
  final Duration speed;

  @override
  State<TypingText> createState() => _TypingTextState();
}

class _TypingTextState extends State<TypingText> {
  Timer? _timer;
  int _visibleChars = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant TypingText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    _visibleChars = 0;
    _timer = Timer.periodic(widget.speed, (timer) {
      if (!mounted || _visibleChars >= widget.text.length) {
        timer.cancel();
        return;
      }
      setState(() => _visibleChars++);
    });
  }

  @override
  Widget build(BuildContext context) => Text(widget.text.substring(0, _visibleChars.clamp(0, widget.text.length)), style: widget.style);
}
