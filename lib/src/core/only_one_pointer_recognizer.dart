import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class OnlyOnePointerRecognizer extends ScaleGestureRecognizer {
  OnlyOnePointerRecognizer({
    Object debugOwner,
    PointerDeviceKind kind,
  }) : super(debugOwner: debugOwner, kind: kind);

  int _p = 0;
  @override
  void addPointer(PointerDownEvent event) {
    if (_p == 0) {
      resolve(GestureDisposition.rejected);
      _p = event.pointer;
    } else {
      resolve(GestureDisposition.accepted);
    }

    super.addPointer(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (!event.down && event.pointer == _p) {
      _p = 0;
    }
    super.handleEvent(event);
  }
}
