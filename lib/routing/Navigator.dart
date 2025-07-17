import 'package:flutter/material.dart';

enum TransitionType {
  fade,
  slide,
  scale,
  rotation,
  slideUp,
  slideDown,
  slideLeft,
  slideRight,
  scaleRotate,
  fadeSlide,
}

class SmoothNavigator {
  // Push with smooth transition
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Widget page, {
    TransitionType type = TransitionType.fade,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return Navigator.push<T>(
      context,
      SmoothPageRoute<T>(
        builder: (context) => page,
        transitionType: type,
        duration: duration,
        curve: curve,
      ),
    );
  }

  // Push and replace with smooth transition
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget page, {
    TransitionType type = TransitionType.fade,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
    TO? result,
  }) {
    return Navigator.pushReplacement<T, TO>(
      context,
      SmoothPageRoute<T>(
        builder: (context) => page,
        transitionType: type,
        duration: duration,
        curve: curve,
      ),
      result: result,
    );
  }

  // Push and remove until with smooth transition
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    Widget page,
    bool Function(Route<dynamic>) predicate, {
    TransitionType type = TransitionType.fade,
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      SmoothPageRoute<T>(
        builder: (context) => page,
        transitionType: type,
        duration: duration,
        curve: curve,
      ),
      predicate,
    );
  }
}

class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  final Widget Function(BuildContext) builder;
  final TransitionType transitionType;
  final Duration duration;
  final Curve curve;

  SmoothPageRoute({
    required this.builder,
    this.transitionType = TransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    RouteSettings? settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          settings: settings,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: curve,
    );

    switch (transitionType) {
      case TransitionType.fade:
        return FadeTransition(
          opacity: curvedAnimation,
          child: child,
        );

      case TransitionType.slide:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.scale:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(
            begin: 0.25,
            end: 0.0,
          ).animate(curvedAnimation),
          child: child,
        );

      case TransitionType.scaleRotate:
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(curvedAnimation),
          child: RotationTransition(
            turns: Tween<double>(
              begin: 0.25,
              end: 0.0,
            ).animate(curvedAnimation),
            child: child,
          ),
        );

      case TransitionType.fadeSlide:
        return FadeTransition(
          opacity: curvedAnimation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.3),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
    }
  }
}

// Custom transition widget for more control
class SmoothTransitionWidget extends StatelessWidget {
  final Widget child;
  final TransitionType type;
  final Duration duration;
  final Curve curve;
  final bool animate;

  const SmoothTransitionWidget({
    Key? key,
    required this.child,
    this.type = TransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.animate = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!animate) return child;

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: curve,
      switchOutCurve: curve,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return _buildTransition(child, animation);
      },
      child: child,
    );
  }

  Widget _buildTransition(Widget child, Animation<double> animation) {
    switch (type) {
      case TransitionType.fade:
        return FadeTransition(opacity: animation, child: child);

      case TransitionType.scale:
        return ScaleTransition(scale: animation, child: child);

      case TransitionType.slideUp:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 1.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case TransitionType.slideDown:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, -1.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case TransitionType.slideLeft:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case TransitionType.slideRight:
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );

      case TransitionType.rotation:
        return RotationTransition(
          turns: Tween<double>(begin: 0.25, end: 0.0).animate(animation),
          child: child,
        );

      case TransitionType.scaleRotate:
        return ScaleTransition(
          scale: animation,
          child: RotationTransition(
            turns: Tween<double>(begin: 0.25, end: 0.0).animate(animation),
            child: child,
          ),
        );

      case TransitionType.fadeSlide:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );

      default:
        return FadeTransition(opacity: animation, child: child);
    }
  }
}

// Example usage widget
class ExampleUsage extends StatefulWidget {
  @override
  _ExampleUsageState createState() => _ExampleUsageState();
}

class _ExampleUsageState extends State<ExampleUsage> {
  int _currentIndex = 0;
  TransitionType _currentTransition = TransitionType.fade;

  final List<Widget> _pages = [
    _buildPageContent(Colors.blue, "Page 1"),
    _buildPageContent(Colors.green, "Page 2"),
    _buildPageContent(Colors.orange, "Page 3"),
  ];

  final List<TransitionType> _transitions = [
    TransitionType.fade,
    TransitionType.slide,
    TransitionType.scale,
    TransitionType.slideUp,
    TransitionType.scaleRotate,
    TransitionType.fadeSlide,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smooth Navigator Demo'),
        actions: [
          PopupMenuButton<TransitionType>(
            onSelected: (type) {
              setState(() {
                _currentTransition = type;
              });
            },
            itemBuilder: (context) => _transitions.map((type) {
              return PopupMenuItem<TransitionType>(
                value: type,
                child: Text(type.toString().split('.').last),
              );
            }).toList(),
          ),
        ],
      ),
      body: SmoothTransitionWidget(
        key: ValueKey(_currentIndex),
        type: _currentTransition,
        duration: Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Example of navigating to a new page
          SmoothNavigator.push(
            context,
            _buildDetailPage(),
            type: _currentTransition,
            duration: Duration(milliseconds: 500),
            curve: Curves.elasticOut,
          );
        },
        child: Icon(Icons.navigate_next),
      ),
    );
  }

  static Widget _buildPageContent(Color color, String title) {
    return Container(
      color: color.withOpacity(0.1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star,
              size: 100,
              color: color,
            ),
            SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Page'),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        color: Colors.purple.withOpacity(0.1),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.details,
                size: 100,
                color: Colors.purple,
              ),
              SizedBox(height: 20),
              Text(
                'Detail Page',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  SmoothNavigator.pushReplacement(
                    context,
                    ExampleUsage(),
                    type: TransitionType.slideLeft,
                  );
                },
                child: Text('Replace with Main Page'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}