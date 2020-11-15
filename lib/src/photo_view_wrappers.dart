import 'package:flutter/widgets.dart';

import '../photo_view.dart';
import 'core/photo_view_core.dart';
import 'photo_view_default_widgets.dart';
import 'utils/photo_view_utils.dart';

class ImageWrapper extends StatefulWidget {
  const ImageWrapper({
    Key key,
    this.imageProvider,
    this.loadingBuilder,
    this.loadFailedChild,
    this.backgroundDecoration,
    this.gaplessPlayback = false,
    this.heroAttributes,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.enableMoveOnMinScale = false,
    this.enableDoubleTap,
    this.controller,
    this.scaleStateController,
    this.maxScale,
    this.minScale,
    this.initialScale,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.outerSize,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
    this.disableGestures,
    this.errorBuilder,
  }) : super(key: key);

  final ImageProvider imageProvider;
  final LoadingBuilder loadingBuilder;
  final ImageErrorWidgetBuilder errorBuilder;
  final Widget loadFailedChild;
  final Decoration backgroundDecoration;
  final bool gaplessPlayback;
  final PhotoViewHeroAttributes heroAttributes;
  final ValueChanged<PhotoViewScaleState> scaleStateChangedCallback;
  final bool enableRotation;
  final bool enableMoveOnMinScale;
  final dynamic maxScale;
  final dynamic minScale;
  final dynamic initialScale;
  final PhotoViewControllerBase controller;
  final PhotoViewScaleStateController scaleStateController;
  final Alignment basePosition;
  final ScaleStateCycle scaleStateCycle;

  final PhotoViewImageTapUpCallback onTapUp;
  final PhotoViewImageTapDownCallback onTapDown;

  final Size outerSize;
  final HitTestBehavior gestureDetectorBehavior;
  final bool tightMode;
  final FilterQuality filterQuality;
  final bool disableGestures;
  final bool enableDoubleTap;

  @override
  _ImageWrapperState createState() => _ImageWrapperState();
}

class _ImageWrapperState extends State<ImageWrapper> {
  ImageStreamListener _imageStreamListener;
  ImageStream _stream;
  ImageChunkEvent _imageChunkEvent;
  ImageInfo _imageInfo;
  bool _loading = true;
  Size _imageSize;
  Object _lastException;
  StackTrace _stackTrace;

  // retrieve image from the provider
  void _getImage() {
    _stream = widget.imageProvider.resolve(
      const ImageConfiguration(),
    );

    void handleImageChunk(ImageChunkEvent event) {
      assert(widget.loadingBuilder != null);
      setState(() => _imageChunkEvent = event);
    }

    void handleImageFrame(ImageInfo info, bool synchronousCall) {
      final setupCB = () {
        _imageSize = Size(
          info.image.width.toDouble(),
          info.image.height.toDouble(),
        );
        _loading = false;
        _imageInfo = _imageInfo;

        _imageChunkEvent = null;
        _lastException = null;
        _stackTrace = null;
      };
      synchronousCall ? setupCB() : setState(setupCB);
    }

    void handleError(dynamic error, StackTrace stackTrace) {
      setState(() {
        _loading = false;
        _lastException = error;
        _stackTrace = stackTrace;
      });
    }

    _imageStreamListener = ImageStreamListener(
      handleImageFrame,
      onChunk: handleImageChunk,
      onError: handleError,
    );
    _stream.addListener(_imageStreamListener);
  }

  void _stopImageStream() {
    if (_stream != null) {
      _stream.removeListener(_imageStreamListener);
    }
  }

  @override
  void initState() {
    super.initState();
    _getImage();
  }

  @override
  void dispose() {
    super.dispose();
    _stopImageStream();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return _buildLoading(context);
    }

    if (_lastException != null) {
      return _buildError(context);
    }

    final scaleBoundaries = ScaleBoundaries(
      widget.minScale ?? 0.0,
      widget.maxScale ?? double.infinity,
      widget.initialScale ?? PhotoViewComputedScale.contained,
      widget.outerSize,
      _imageSize,
    );

    return PhotoViewCore(
      imageProvider: widget.imageProvider,
      backgroundDecoration: widget.backgroundDecoration,
      gaplessPlayback: widget.gaplessPlayback,
      enableRotation: widget.enableRotation,
      enableMoveOnMinScale: widget.enableMoveOnMinScale,
      heroAttributes: widget.heroAttributes,
      basePosition: widget.basePosition ?? Alignment.center,
      controller: widget.controller,
      scaleStateController: widget.scaleStateController,
      scaleStateCycle: widget.scaleStateCycle ?? defaultScaleStateCycle,
      scaleBoundaries: scaleBoundaries,
      onTapUp: widget.onTapUp,
      onTapDown: widget.onTapDown,
      gestureDetectorBehavior: widget.gestureDetectorBehavior,
      tightMode: widget.tightMode ?? false,
      filterQuality: widget.filterQuality ?? FilterQuality.none,
      disableGestures: widget.disableGestures ?? false,
      enableDoubleTap: widget.enableDoubleTap ?? true,
    );
  }

  Widget _buildLoading(BuildContext context) {
    if (widget.loadingBuilder != null) {
      return widget.loadingBuilder(context, _imageChunkEvent);
    }

    return PhotoViewDefaultLoading(
      event: _imageChunkEvent,
    );
  }

  Widget _buildError(
    BuildContext context,
  ) {
    if (widget.loadFailedChild != null) {
      return widget.loadFailedChild;
    }
    if (widget.errorBuilder != null) {
      return widget.errorBuilder(context, _lastException, _stackTrace);
    }
    return PhotoViewDefaultError();
  }
}

class CustomChildWrapper extends StatefulWidget {
  const CustomChildWrapper({
    Key key,
    this.child,
    this.childSize,
    this.backgroundDecoration,
    this.heroAttributes,
    this.scaleStateChangedCallback,
    this.enableRotation,
    this.enableMoveOnMinScale,
    this.controller,
    this.scaleStateController,
    this.maxScale,
    this.minScale,
    this.initialScale,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.outerSize,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
    this.disableGestures,
    this.enableDoubleTap,
  }) : super(key: key);

  final Widget child;
  final Size childSize;
  final Decoration backgroundDecoration;
  final PhotoViewHeroAttributes heroAttributes;
  final ValueChanged<PhotoViewScaleState> scaleStateChangedCallback;
  final bool enableRotation;
  final bool enableMoveOnMinScale;

  final PhotoViewControllerBase controller;
  final PhotoViewScaleStateController scaleStateController;

  final dynamic maxScale;
  final dynamic minScale;
  final dynamic initialScale;

  final Alignment basePosition;
  final ScaleStateCycle scaleStateCycle;
  final PhotoViewImageTapUpCallback onTapUp;
  final PhotoViewImageTapDownCallback onTapDown;
  final Size outerSize;
  final HitTestBehavior gestureDetectorBehavior;
  final bool tightMode;
  final FilterQuality filterQuality;
  final bool disableGestures;
  final bool enableDoubleTap;

  @override
  _CustomChildWrapperState createState() => _CustomChildWrapperState();
}

class _CustomChildWrapperState extends State<CustomChildWrapper> {
  @override
  Widget build(BuildContext context) {
    final scaleBoundaries = ScaleBoundaries(
      widget.minScale ?? 0.0,
      widget.maxScale ?? double.infinity,
      widget.initialScale ?? PhotoViewComputedScale.contained,
      widget.outerSize,
      widget.childSize ?? widget.outerSize,
    );

    return PhotoViewCore.customChild(
      customChild: widget.child,
      backgroundDecoration: widget.backgroundDecoration,
      enableRotation: widget.enableRotation,
      enableMoveOnMinScale: widget.enableMoveOnMinScale,
      heroAttributes: widget.heroAttributes,
      controller: widget.controller,
      scaleStateController: widget.scaleStateController,
      scaleStateCycle: widget.scaleStateCycle ?? defaultScaleStateCycle,
      basePosition: widget.basePosition ?? Alignment.center,
      scaleBoundaries: scaleBoundaries,
      onTapUp: widget.onTapUp,
      onTapDown: widget.onTapDown,
      gestureDetectorBehavior: widget.gestureDetectorBehavior,
      tightMode: widget.tightMode ?? false,
      filterQuality: widget.filterQuality ?? FilterQuality.none,
      disableGestures: widget.disableGestures ?? false,
      enableDoubleTap: widget.enableDoubleTap ?? true,
    );
  }
}
