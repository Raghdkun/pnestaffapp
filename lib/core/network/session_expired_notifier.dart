import 'dart:async';

import 'package:injectable/injectable.dart';

/// Broadcasts a "session is no longer valid" signal from the network layer
/// (the [AuthInterceptor], after a refresh fails) to the presentation layer
/// (the AuthBloc), keeping the two decoupled.
@lazySingleton
class SessionExpiredNotifier {
  final StreamController<void> _controller = StreamController<void>.broadcast();

  Stream<void> get onUnauthorized => _controller.stream;

  void notify() {
    if (!_controller.isClosed) _controller.add(null);
  }

  @disposeMethod
  void dispose() => _controller.close();
}
