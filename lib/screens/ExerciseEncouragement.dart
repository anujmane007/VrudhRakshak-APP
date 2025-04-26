import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vrudharakshak/screens/video.dart';

class Exerciseencouragement extends StatefulWidget {
  const Exerciseencouragement({super.key});

  @override
  State<Exerciseencouragement> createState() => _ExerciseencouragementState();
}

class _ExerciseencouragementState extends State<Exerciseencouragement> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  Timer? _timer;
  bool _isForward = true; 

  final List<String> imagePaths = [
    'images/eHand.png',
    'images/eHand.png',
    'images/eHand.png',
  ];

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
  if (_pageController.hasClients) {
    int nextPage;

    if (_isForward) {
      nextPage = _currentIndex + 1;
      if (nextPage >= imagePaths.length) {
        nextPage = _currentIndex - 1;
        _isForward = false;
      }
    } else {
      nextPage = _currentIndex - 1;
      if (nextPage < 0) {
        nextPage = _currentIndex + 1;
        _isForward = true;
      }
    }

    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    setState(() {
      _currentIndex = nextPage;
    });
  }
});

  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Exercise Encouragement")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Auto Sliding Image Carousel
            SizedBox(
              height: 300,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: imagePaths.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      imagePaths[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            // Modern Dot Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imagePaths.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 12 : 8,
                  height: _currentIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    color: _currentIndex == index
                        ? Colors.deepPurple
                        : Colors.deepPurple.shade100,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 30),
            const Text(
              "Exercise Encouragement",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 28),
              textAlign: TextAlign.center,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              child: Text(
                "Stay active and healthy by following guided physical activities. "
                "These exercises are designed to help you stay mobile, improve circulation, "
                "and promote well-being.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LocalVideoPlayer()),
              ),
              icon: const Icon(Icons.play_circle_fill),
              label: const Text("Watch Video Tutorial"),
              style: ElevatedButton.styleFrom(
                backgroundColor:const Color.fromARGB(255, 163, 141, 202),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
