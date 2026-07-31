import 'dart:async';

import 'package:flutter/foundation.dart';

/// Adapts a bloc/cubit [Stream] into a [Listenable] so `GoRouter` can use it as
/// its `refreshListenable` — every emission re-evaluates the redirect guard.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
