import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../widgets/app_footer.dart';

class ResultsPage extends StatefulWidget {
  final double bodyFatPercentage;
  final String imagePath;

  const ResultsPage({
    Key? key,
    required this.bodyFatPercentage,
    required this.imagePath,
  }) : super(key: key);

  @override
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _progressAnimation =
        Tween<double>(begin: 0.0, end: widget.bodyFatPercentage / 100).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );

    // بدء الأنيميشن
    Future.delayed(const Duration(milliseconds: 500), () {
      _progressController.forward();
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      _fadeController.forward();
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Color _getResultColor() {
    if (widget.bodyFatPercentage < 15) return Colors.green;
    if (widget.bodyFatPercentage < 25) return Colors.blue;
    if (widget.bodyFatPercentage < 30) return Colors.orange;
    return Colors.red;
  }

  String _getResultCategory() {
    if (widget.bodyFatPercentage < 14) return "Athlete";
    if (widget.bodyFatPercentage < 18) return "Fitness";
    if (widget.bodyFatPercentage < 25) return "Average";
    return "Obese";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const AppFooter(),

      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              "assets/images/resultBack.png",
              fit: BoxFit.cover,
            ),
          ),

          //  Main content on top
          Column(
            children: [
              // Top header image
              Container(
                height: 180,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/Header.png"),
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                  ),
                ),
              ),

              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildMainResult(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
              size: 24,
            ),
          ),
          const Expanded(
            child: Text(
              'Analysis Results',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // مشاركة النتائج
            },
            icon: const Icon(Icons.share, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildMainResult() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.13),
        const Text(
          'Result',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 30),
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            children: [
              // color: Colors.grey,
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(200, 200),
                    painter: CircularProgressPainter(
                      progress: _progressAnimation.value,
                      color: _getResultColor(),
                    ),
                  );
                },
              ),

              // النص في المنتصف
              Center(
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 30),
                        Text(
                          '${(_progressAnimation.value * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: _getResultColor(),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _getResultCategory(),
                          style: const TextStyle(
                            color: Colors.black12,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// رسام المخطط الدائري المخصص
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // رسم الخلفية
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.1)
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // رسم التقدم
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 15
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
