import 'dart:async';

import 'package:injectable/injectable.dart';

/// Decouples notification taps from the router. Notification services push a
/// route string here; the root widget listens and calls `GoRouter.go`. This
/// avoids a dependency cycle (notifications ⇄ router) and works for all three
/// launch states:
///
/// * foreground/background tap → [selectRoute] (stream)
/// * terminated launch (cold start) → [initialRoute], consumed once at startup
@lazySingleton
class NotificationRouter {
  final StreamController<String> _controller =
      StreamController<String>.broadcast();

  /// Route to open after a cold start triggered by a notification. Set by the
  /// local/push services during init; read once by the app on first frame.
  String? initialRoute;

  Stream<String> get onSelectRoute => _controller.stream;

  void selectRoute(String route) {
    if (route.isEmpty) return;
    _controller.add(route);
  }

  /// Returns and clears [initialRoute] so it is only ever navigated to once.
  String? consumeInitialRoute() {
    final route = initialRoute;
    initialRoute = null;
    return route;
  }

  @disposeMethod
  void dispose() => _controller.close();
}
