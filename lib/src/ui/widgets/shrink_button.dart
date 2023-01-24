import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShrinkButton extends StatefulWidget {
  final int count;
  final VoidCallback onTap;
  final Color backgroundColor;
  final double height;
  final TextStyle? textStyle;
  final Duration duration;

  const ShrinkButton({
    super.key,
    required this.count,
    required this.onTap,
    required this.backgroundColor,
    this.height = 40,
    this.textStyle,
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  State<ShrinkButton> createState() => _ShrinkButtonState();
}

class _ShrinkButtonState extends State<ShrinkButton> with TickerProviderStateMixin {
  bool visible = true;

  late final AnimationController _controller = AnimationController(
    duration: widget.duration,
    vsync: this,
    value: 1.0,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInQuad,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      // scale: _animation,
      // alignment: Alignment.center,
      sizeFactor: _animation,
      child: MaterialButton(
        elevation: 0,
        onPressed: () {
          setState(() {
            if (visible) {
              _controller.reverse();
            } else {
              _controller.forward();
            }
            visible = !visible;
          });
          widget.onTap.call();
        },
        color: widget.backgroundColor,
        height: widget.height,
        shape: const StadiumBorder(),
        child: Wrap(
          children: [
            const Icon(CupertinoIcons.chevron_down, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text("${widget.count} New Message(s)", style: widget.textStyle),
          ],
        ),
      ),
    );
  }
}
