import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/widgets.dart';

class DragBackground extends PositionComponent with DragCallbacks {
  DragBackground() : super(anchor: Anchor.center);

  final _rectPaint = Paint()..color = const Color(0x88AC54BF);

  /// We will store all current circles into this map, keyed by the `pointerId`
  /// of the event that created the circle.
  final Map<int, Trail> _trails = {};

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size - Vector2(100, 75);
    if (this.size.x < 100 || this.size.y < 100) {
      this.size = size * 0.9;
    }
    position = size / 2;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _rectPaint);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    final trail = Trail(event.localPosition);
    _trails[event.pointerId] = trail;
    add(trail);

    print("---add trail: ${event.pointerId}------");
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    _trails[event.pointerId]!.addPoint(event.localEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _trails.remove(event.pointerId)!.end();
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _trails.remove(event.pointerId)!.cancel();
  }
}

class Trail extends Component {
  Trail(Vector2 origin)
      : _paths = [Path()..moveTo(origin.x, origin.y)],
        _opacities = [1],
        _lastPoint = origin.clone(),
        _color =
            HSLColor.fromAHSL(1, random.nextDouble() * 360, 1, 0.8).toColor();

  final List<Path> _paths;
  final List<double> _opacities;
  Color _color;
  late final _linePaint = Paint()..style = PaintingStyle.stroke;
  late final _circlePaint = Paint()..color = _color;
  bool _released = false;
  double _timer = 0;
  final _vanishInterval = 0.03;
  final Vector2 _lastPoint;

  static final random = Random();
  static const lineWidth = 10.0;

  @override
  void render(Canvas canvas) {
    assert(_paths.length == _opacities.length);
    for (var i = 0; i < _paths.length; i++) {
      final path = _paths[i];
      final opacity = _opacities[i];
      if (opacity > 0) {
        _linePaint.color = _color.withOpacity(opacity);
        _linePaint.strokeWidth = lineWidth * opacity;
        canvas.drawPath(path, _linePaint);
      }
    }
    canvas.drawCircle(
      _lastPoint.toOffset(),
      (lineWidth - 2) * _opacities.last + 2,
      _circlePaint,
    );
  }

  @override
  void update(double dt) {
    assert(_paths.length == _opacities.length);
    _timer += dt;
    while (_timer > _vanishInterval) {
      _timer -= _vanishInterval;
      for (var i = 0; i < _paths.length; i++) {
        _opacities[i] -= 0.01;
        if (_opacities[i] <= 0) {
          _paths[i].reset();
        }
      }
      if (!_released) {
        _paths.add(Path()..moveTo(_lastPoint.x, _lastPoint.y));
        _opacities.add(1);
      }
    }
    if (_opacities.last < 0) {
      removeFromParent();
    }
  }

  void addPoint(Vector2 point) {
    if (!point.x.isNaN) {
      for (final path in _paths) {
        path.lineTo(point.x, point.y);
      }
      _lastPoint.setFrom(point);
    }
  }

  void end() => _released = true;

  void cancel() {
    _released = true;
    _color = const Color(0xFFFFFFFF);
  }
}
