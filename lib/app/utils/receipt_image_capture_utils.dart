import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ReceiptCaptureUtils {
  /// Captures a widget as an image byte array.
  /// The widget is rendered off-screen at the specified width.
  static Future<Uint8List> captureWidget(Widget widget, {double width = 360}) async {
    final RenderRepaintBoundary boundary = RenderRepaintBoundary();
    
    final view = ui.PlatformDispatcher.instance.views.first;
    final double pixelRatio = view.devicePixelRatio;

    final RenderView renderView = RenderView(
      child: RenderPositionedBox(alignment: Alignment.topLeft, child: boundary),
      configuration: ViewConfiguration(
        logicalConstraints: BoxConstraints.tightFor(width: width), 
        devicePixelRatio: pixelRatio,
      ),
      view: view,
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: boundary,
      child: Material(
        color: Colors.white,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: widget,
        ),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    // After layout, we know the actual height
    final double actualHeight = boundary.size.height;
    
    // Re-render with exact height for clean capture
    renderView.configuration = ViewConfiguration(
       logicalConstraints: BoxConstraints.tight(Size(width, actualHeight)),
       devicePixelRatio: pixelRatio,
    );
    pipelineOwner.flushLayout();
    pipelineOwner.flushPaint();

    final ui.Image image = await boundary.toImage(pixelRatio: 1.0); // 1:1 for thermal printers
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }
}
