import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../model/get_order_model.dart' as order_model;
import '../model/receipt_order_response_model.dart' as api_model;


class ReceiptImageService {
  /// Renders a receipt widget to image bytes.
  /// [width] should be 384 for 58mm and 576 for 80mm.
  static Future<Uint8List> generateReceiptImage(
    order_model.Data data, {
    double width = 384,
  }) async {
    final repaintBoundary = RenderRepaintBoundary();

    final renderView = RenderView(
      child: RenderPadding(
        padding: const EdgeInsets.all(0),
        child: repaintBoundary,
      ),
      configuration: ViewConfiguration(
        size: Size(width, 2000), // Height is flexible
        devicePixelRatio: 1.0,
      ),
      window: ui.window,
    );

    final pipelineOwner = PipelineOwner();
    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final buildOwner = BuildOwner(focusManager: FocusManager());
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Roboto'), // Default system font
        home: Scaffold(
          backgroundColor: Colors.white,
          body: _ReceiptWidget(data: data, width: width),
        ),
      ),
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final ui.Image image = await repaintBoundary.toImage(pixelRatio: 2.0);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }

  static Future<Uint8List> generateReceiptImageFromApi(
    api_model.ReceiptOrderData data, {
    double width = 384,
  }) async {
    final repaintBoundary = RenderRepaintBoundary();
    final renderView = RenderView(
      child: RenderPadding(padding: const EdgeInsets.all(0), child: repaintBoundary),
      configuration: ViewConfiguration(size: Size(width, 2000), devicePixelRatio: 1.0),
      window: ui.window,
    );
    final pipelineOwner = PipelineOwner();
    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();
    final buildOwner = BuildOwner(focusManager: FocusManager());
    final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Roboto'),
        home: Scaffold(
          backgroundColor: Colors.white,
          body: _ReceiptWidgetFromApi(data: data, width: width),
        ),
      ),
    ).attachToRenderTree(buildOwner);
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();
    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();
    final ui.Image image = await repaintBoundary.toImage(pixelRatio: 2.0);
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}


class _ReceiptWidget extends StatelessWidget {
  final order_model.Data data;
  final double width;

  const _ReceiptWidget({
    required this.data,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        width: width,
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Name (Bold & Large)
            Center(
              child: Text(
                data.restaurant?.name ?? "Restaurant",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Branch Address
            if (data.branch?.address != null)
              Center(
                child: Text(
                  data.branch!.address!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
            const SizedBox(height: 20),
            const Divider(thickness: 2, color: Colors.black),
            const SizedBox(height: 10),
            
            // Order Details (Wolt Style)
            _buildInfoRow(Icons.access_time, data.order?.dateTime ?? ""),
            _buildInfoRow(Icons.person, data.order?.customer?.name ?? ""),
            _buildInfoRow(Icons.confirmation_number_outlined, "#${data.order?.orderNumber ?? ''}"),
            
            const SizedBox(height: 20),
            const Divider(thickness: 2, color: Colors.black),
            const SizedBox(height: 10),

            // Items List
            if (data.order?.items != null)
              for (var item in data.order!.items!)
                _buildItemRow(item),

            const SizedBox(height: 20),
            const Divider(thickness: 2, color: Colors.black),
            const SizedBox(height: 10),

            // Totals
            _buildTotalRow("Sub Total:", "${data.order?.totals?.subTotal ?? 0}"),
            if (data.order?.totals?.discountAmount != null && data.order!.totals!.discountAmount! > 0)
              _buildTotalRow("Discount:", "-${data.order!.totals!.discountAmount}"),
            
            const SizedBox(height: 12),
            _buildTotalRow(
              "TOTAL:",
              "${data.order?.totals?.total ?? 0}",
              isLarge: true,
            ),
            
            const SizedBox(height: 30),
            const Center(
              child: Text(
                "Thank you for your visit!",
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(dynamic item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${item.quantity} x ",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              Expanded(
                child: Text(
                  "${item.itemName}",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                "${item.amount}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          if (item.variationName != null)
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                "(${item.variationName})",
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 26 : 20,
              fontWeight: isLarge ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isLarge ? 26 : 20,
              fontWeight: isLarge ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptWidgetFromApi extends StatelessWidget {
  final api_model.ReceiptOrderData data;
  final double width;

  const _ReceiptWidgetFromApi({
    required this.data,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final order = data.order;
    return Container(
      width: width,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              data.restaurant?.name ?? "Restaurant",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black),
            ),
          ),
          const SizedBox(height: 8),
          if (data.branch?.address != null)
            Center(
              child: Text(
                data.branch!.address!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          const SizedBox(height: 20),
          const Divider(thickness: 2, color: Colors.black),
          const SizedBox(height: 10),
          _buildInfoRow(Icons.access_time, order?.dateTime ?? ""),
          _buildInfoRow(Icons.person, _receiptCustomerName(order?.customer)),
          _buildInfoRow(Icons.confirmation_number_outlined, "#${order?.orderNumber ?? ''}"),
          const SizedBox(height: 20),
          const Divider(thickness: 2, color: Colors.black),
          const SizedBox(height: 10),
          if (data.receiptItems != null)
            for (var item in data.receiptItems!) _buildItemRow(item),
          const SizedBox(height: 20),
          const Divider(thickness: 2, color: Colors.black),
          const SizedBox(height: 10),
          _buildTotalRow("Sub Total:", "${data.summary?.subTotal ?? 0}"),
          _buildTotalRow("TOTAL:", "${data.summary?.total ?? 0}", isLarge: true),
          const SizedBox(height: 30),
          const Center(
            child: Text("Thank you for your visit!", style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }

  String _receiptCustomerName(dynamic customer) {
    if (customer == null) return "";
    return "${customer.name ?? ''}".trim();
  }

  Widget _buildInfoRow(IconData icon, String text) {
    if (text.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.black),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildItemRow(api_model.ReceiptItems item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${item.quantity} x ", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              Expanded(child: Text("${item.itemName}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800))),
              Text("${item.amount}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ],
          ),
          if (item.displayVariationName != null)
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Text("(${item.displayVariationName})", style: const TextStyle(fontSize: 16, color: Colors.black87)),
            ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isLarge = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: isLarge ? 26 : 20, fontWeight: isLarge ? FontWeight.w900 : FontWeight.w600)),
          Text(value, style: TextStyle(fontSize: isLarge ? 26 : 20, fontWeight: isLarge ? FontWeight.w900 : FontWeight.w600)),
        ],
      ),
    );
  }
}
