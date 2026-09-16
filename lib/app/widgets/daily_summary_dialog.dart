import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/api_constants.dart';
import '../constants/color_constant.dart';
import '../constants/sizeConstant.dart';
import '../constants/translation_keys.dart';
import '../data/NetworkClient.dart';
import '../model/daily_sales_summary_model.dart';
import '../services/printer_service.dart';
import '../services/sunmi_invoice_printer_service.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_time_formatter.dart';
import '../utils/order_helpers.dart';
import '../widgets/app_toast.dart';

/// Full-screen dialog — opens instantly and shows a CupertinoActivityIndicator
/// while fetching data, then renders the report (same style as X/Z Report).
class DailySummaryDialog extends StatefulWidget {
  const DailySummaryDialog({super.key});

  /// Opens the dialog immediately; data is fetched inside.
  static void show(BuildContext context) {
    showDialog<void>(
      context: context,
      useSafeArea: false,
      barrierDismissible: true,
      builder: (_) => const DailySummaryDialog(),
    );
  }

  @override
  State<DailySummaryDialog> createState() => _DailySummaryDialogState();
}

class _DailySummaryDialogState extends State<DailySummaryDialog> {
  final NetworkClient _networkClient = NetworkClient();

  bool _isLoading = true;
  bool _isPrinting = false;
  DailySalesSummaryData? _data;

  double get _fontScale {
    if (!mounted) return 1.0;
    final size = MediaQuery.of(context).size;
    final isTablet = size.shortestSide >= 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (isTablet) {
      return isLandscape ? 1.35 : 1.25;
    }
    return 1.0;
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final response = await _networkClient.get(
        ArgumentConstant.dailySalesSummaryEndpoint,
      );
      if (response.data is Map<String, dynamic>) {
        final model = DailySalesSummaryModel.fromJson(
          response.data as Map<String, dynamic>,
        );
        if (mounted) {
          setState(() {
            _data = model.data;
            _isLoading = false;
          });
        }
      } else {
        _handleError();
      }
    } catch (_) {
      _handleError();
    }
  }

  void _handleError() {
    if (mounted) {
      Navigator.of(context).pop();
      AppToast.showError(TranslationKeys.somethingWentWrong.tr);
    }
  }

  Future<void> _onPrint() async {
    if (_isPrinting || _data == null) return;
    setState(() => _isPrinting = true);
    try {
      final isConnected =
          await Get.find<PrinterService>().checkPrinterConnectivity();
      if (!isConnected) {
        AppToast.showError(
          TranslationKeys.printerNotConnected.tr,
          title: TranslationKeys.error.tr,
        );
        return;
      }
      await SunmiInvoicePrinterService().printDailySalesSummary(_data!);
      AppToast.showSuccess(TranslationKeys.printSuccessful.tr);
    } catch (e) {
      AppToast.showError(
        TranslationKeys.somethingWentWrong.tr,
        title: TranslationKeys.error.tr,
      );
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }



  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    MySize().init(context);

    return Dialog.fullscreen(
      backgroundColor: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          bottom: false,
          child: _isLoading ? _buildLoader() : _buildContent(_data),
        ),
        bottomNavigationBar: _isLoading
            ? null
            : SafeArea(top: false, child: _buildFooter()),
      ),
    );
  }

  // ─── Loader (CupertinoActivityIndicator — same as rest of app) ───────────

  Widget _buildLoader() {
    return const Center(
      child: CupertinoActivityIndicator(
        radius: 16,
        color: ColorConstants.primaryColor,
      ),
    );
  }

  // ─── Footer ───────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: MySize.getWidth(16),
        vertical: MySize.getHeight(12),
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          // 1. Close Button (Left)
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                side: BorderSide(color: Colors.grey.shade300),
                padding: EdgeInsets.symmetric(
                  vertical: MySize.getHeight(14 * _fontScale),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                ),
              ),
              child: Text(
                TranslationKeys.close.tr,
                style: TextStyle(
                  fontSize: MySize.getHeight(16 * _fontScale),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          SizedBox(width: MySize.getWidth(12)),
          // 2. Print Button (Right)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isPrinting ? null : _onPrint,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    ColorConstants.primaryColor.withAlpha(120),
                padding: EdgeInsets.symmetric(
                  vertical: MySize.getHeight(14 * _fontScale),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(MySize.getHeight(8)),
                ),
              ),
              icon: _isPrinting
                  ? SizedBox(
                      width: MySize.getHeight(20 * _fontScale),
                      height: MySize.getHeight(20 * _fontScale),
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      Icons.print_outlined,
                      size: MySize.getHeight(22 * _fontScale),
                    ),
              label: Text(
                _isPrinting ? 'Printing...' : TranslationKeys.print.tr,
                style: TextStyle(
                  fontSize: MySize.getHeight(16 * _fontScale),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Main content (thermal receipt style — same as X/Z Report) ────────────

  Widget _buildContent(DailySalesSummaryData? d) {
    if (d == null) return const SizedBox.shrink();

    final period   = d.period;
    final orders   = d.orders;
    final sales    = d.sales;
    final payments = d.payments;
    final refunds  = d.refunds;
    final restaurantName = CurrencyFormatter.getRestaurantName();
    final branchName = CurrencyFormatter.getBranchName();
    final now      = DateTimeFormatter.nowInRestaurantTimezone(d.period?.timezone);

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: MySize.getWidth(16),
        vertical: MySize.getHeight(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header (Same layout as X/Z Report) ───────────────────────────
          Center(
            child: Column(
              children: [
                if (restaurantName.isNotEmpty)
                  Text(
                    restaurantName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MySize.getHeight(18 * _fontScale),
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                if (branchName.isNotEmpty) ...[
                  SizedBox(height: MySize.getHeight(2)),
                  Text(
                    branchName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: MySize.getHeight(13 * _fontScale),
                      fontWeight: FontWeight.w400,
                      color: Colors.black54,
                    ),
                  ),
                ],
                SizedBox(height: MySize.getHeight(10)),
                Text(
                  TranslationKeys.todaySummary.tr.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: MySize.getHeight(17 * _fontScale),
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: Colors.black,
                  ),
                ),
                if (period?.businessDate != null &&
                    period!.businessDate!.isNotEmpty) ...[
                  SizedBox(height: MySize.getHeight(2)),
                  Text(
                    period.businessDate!,
                    style: TextStyle(
                      fontSize: MySize.getHeight(13 * _fontScale),
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(height: MySize.getHeight(12)),
          _buildDashedLine(),
          SizedBox(height: MySize.getHeight(10)),



          // ── 2. ORDERS ────────────────────────────────────────────────────
          if (orders != null) ...[
            _buildSectionTitle(TranslationKeys.orders.tr.toUpperCase()),
            SizedBox(height: MySize.getHeight(6)),
            _buildRow(TranslationKeys.totalOrders.tr,   '${orders.totalOrders   ?? 0}'),
            _buildRow(TranslationKeys.paidOrders.tr,    '${orders.paidOrders    ?? 0}'),
            _buildRow(TranslationKeys.countedOrders.tr, '${orders.ordersCounted ?? 0}'),
            _buildRow(TranslationKeys.cancelledOrders.tr, '${orders.cancelledCount ?? 0}'),
            if (orders.ongoing != null && (orders.ongoing!.count ?? 0) > 0) ...[
              SizedBox(height: MySize.getHeight(4)),
              _buildRow(TranslationKeys.ongoing.tr,        '${orders.ongoing!.count}'),
              _buildRow(TranslationKeys.ongoingAmount.tr, _fmt(orders.ongoing!.amount)),
            ],
            if (orders.countByType != null && orders.countByType!.isNotEmpty) ...[
              SizedBox(height: MySize.getHeight(6)),
              _buildSubTitle(TranslationKeys.byOrderType.tr),
              ...orders.countByType!.entries
                  .map((e) => _buildRow(capitalizeWords(e.key), '${e.value}')),
            ],
            if (orders.countByStatus != null && orders.countByStatus!.isNotEmpty) ...[
              SizedBox(height: MySize.getHeight(6)),
              _buildSubTitle(TranslationKeys.byStatus.tr),
              ...orders.countByStatus!.entries
                  .map((e) => _buildRow(capitalizeWords(e.key), '${e.value}')),
            ],
            SizedBox(height: MySize.getHeight(10)),
            _buildDashedLine(),
            SizedBox(height: MySize.getHeight(10)),
          ],

          // ── 3. SALES ─────────────────────────────────────────────────────
          if (sales != null) ...[
            _buildSectionTitle(TranslationKeys.sales.tr.toUpperCase()),
            SizedBox(height: MySize.getHeight(6)),
            _buildRow(TranslationKeys.gross.tr,     _fmt(sales.gross)),
            _buildRow(TranslationKeys.subTotal.tr, _fmt(sales.subTotal)),
            if (sales.taxesByRate != null && sales.taxesByRate!.isNotEmpty) ...[
              SizedBox(height: MySize.getHeight(6)),
              _buildSubTitle(TranslationKeys.taxesByRate.tr),
              SizedBox(height: MySize.getHeight(4)),
              _buildTaxesTable(sales.taxesByRate!),
            ],
            SizedBox(height: MySize.getHeight(6)),
            _buildRow(TranslationKeys.totalTax.tr, _fmt(sales.totalTax), isBold: true),
            _buildRow(TranslationKeys.discounts.tr, _fmt(sales.discounts?.total ?? 0), isBold: true),
            _buildRow(TranslationKeys.tips.tr, _fmt(sales.tips?.total ?? 0), isBold: true),
            if (sales.byType != null && sales.byType!.isNotEmpty) ...[
              SizedBox(height: MySize.getHeight(6)),
              _buildSubTitle(TranslationKeys.salesByType.tr),
              SizedBox(height: MySize.getHeight(4)),
              _buildSalesByTypeTable(sales.byType!),
              SizedBox(height: MySize.getHeight(6)),
            ],
            _buildRow(TranslationKeys.net.tr, _fmt(sales.net), isBold: true),
            SizedBox(height: MySize.getHeight(10)),
            _buildDashedLine(),
            SizedBox(height: MySize.getHeight(10)),
          ],

          // ── 4. PAYMENTS ──────────────────────────────────────────────────
          if (payments != null) ...[
            _buildSectionTitle(TranslationKeys.payments.tr.toUpperCase()),
            if (payments.byMethod != null && payments.byMethod!.isNotEmpty) ...[
              SizedBox(height: MySize.getHeight(6)),
              _buildPaymentsTable(payments.byMethod!),
            ],
            SizedBox(height: MySize.getHeight(6)),
            _buildRow(TranslationKeys.totalCollected.tr, _fmt(payments.total), isBold: true),
            _buildRow(TranslationKeys.paymentDue.tr, _fmt(payments.dueOutstanding ?? payments.duePlaceholder ?? 0)),
            if (orders?.ongoing != null && (orders!.ongoing!.count ?? 0) > 0)
              _buildRow(
                '${TranslationKeys.ongoing.tr} (${orders.ongoing!.count})',
                _fmt(orders.ongoing!.amount),
              ),
            if (payments.awaitingVerification != null &&
                (payments.awaitingVerification!.count ?? 0) > 0)
              _buildRow(
                '${TranslationKeys.awaitingVerification.tr} (${payments.awaitingVerification!.count})',
                _fmt(payments.awaitingVerification!.amount),
              ),
            SizedBox(height: MySize.getHeight(10)),
            _buildDashedLine(),
            SizedBox(height: MySize.getHeight(10)),
          ],

          // ── 5. REFUNDS ───────────────────────────────────────────────────
          if (refunds != null) ...[
            _buildSectionTitle(TranslationKeys.refunds.tr.toUpperCase()),
            SizedBox(height: MySize.getHeight(6)),
            _buildRow(TranslationKeys.count.tr, '${refunds.count ?? 0}'),
            _buildRow(TranslationKeys.total.tr, _fmt(refunds.total), isBold: true),
            if (refunds.byMethod != null && refunds.byMethod!.isNotEmpty) ...[
              SizedBox(height: MySize.getHeight(6)),
              _buildSubTitle(TranslationKeys.byMethod.tr),
              SizedBox(height: MySize.getHeight(4)),
              _buildRefundsMethodTable(refunds.byMethod!),
            ],
            SizedBox(height: MySize.getHeight(16)),
          ],

          // ── Footer timestamp ──────────────────────────────────────────────
          Center(
            child: Text(
              '${TranslationKeys.printed.tr} ${DateTimeFormatter.formatReportDateTime(now)}',
              style: TextStyle(
                fontSize: MySize.getHeight(12 * _fontScale),
                color: Colors.black54,
              ),
            ),
          ),
          SizedBox(height: MySize.getHeight(16)),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // Section widgets — same style as business_day_report_dialog.dart
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildSectionTitle(String title) {
    return Text(title.toUpperCase(),
        style: TextStyle(
            fontSize: MySize.getHeight(14 * _fontScale),
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: Colors.black));
  }

  Widget _buildSubTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.getHeight(3)),
      child: Text(title,
          style: TextStyle(
              fontSize: MySize.getHeight(13 * _fontScale),
              fontWeight: FontWeight.w600,
              color: Colors.black87)),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: MySize.getHeight(3.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: MySize.getHeight(13.5 * _fontScale),
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w400,
                  color: Colors.black)),
          Text(value,
              style: TextStyle(
                  fontSize: MySize.getHeight(13.5 * _fontScale),
                  fontWeight: isBold ? FontWeight.w800 : FontWeight.w400,
                  color: Colors.black)),
        ],
      ),
    );
  }

  // ─── Taxes table: Name (Rate%) | Net | Tax ────────────────────────────────

  Widget _buildTaxesTable(List<TaxByRate> taxes) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: MySize.getHeight(3)),
          child: Row(children: [
            Expanded(
                flex: 5,
                child: Text(TranslationKeys.nameRate.tr,
                    style: TextStyle(
                        fontSize: MySize.getHeight(13.5 * _fontScale),
                        fontWeight: FontWeight.w700,
                        color: Colors.black))),
            Expanded(
                flex: 4,
                child: Text(TranslationKeys.net.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: MySize.getHeight(13.5 * _fontScale),
                        fontWeight: FontWeight.w700,
                        color: Colors.black))),
            Expanded(
                flex: 3,
                child: Text(TranslationKeys.tax.tr,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: MySize.getHeight(13.5 * _fontScale),
                        fontWeight: FontWeight.w700,
                        color: Colors.black))),
          ]),
        ),
        const Divider(height: 1, color: Colors.black, thickness: 1),
        SizedBox(height: MySize.getHeight(4)),
        ...taxes.map((t) {
          final pct = t.taxPercentage != null
              ? '${t.taxPercentage!.toStringAsFixed(2)}%'
              : '0.00%';
          final label = (t.name != null && t.name!.isNotEmpty)
              ? '${t.name} ($pct)'
              : pct;
          return Padding(
            padding: EdgeInsets.symmetric(vertical: MySize.getHeight(2.5)),
            child: Row(children: [
              Expanded(
                  flex: 5,
                  child: Text(label,
                      style: TextStyle(
                          fontSize: MySize.getHeight(13.5 * _fontScale),
                          color: Colors.black87))),
              Expanded(
                  flex: 4,
                  child: Text(_fmt(t.netAmount),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: MySize.getHeight(13.5 * _fontScale),
                          color: Colors.black87))),
              Expanded(
                  flex: 3,
                  child: Text(_fmt(t.taxAmount),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: MySize.getHeight(13.5 * _fontScale),
                          color: Colors.black87))),
            ]),
          );
        }),
      ],
    );
  }

  // ─── Sales by type: Type | Count | Amount — fully dynamic ─────────────────

  Widget _buildSalesByTypeTable(List<SalesByType> items) {
    return _buildSimpleTable(
      headers: [
        TranslationKeys.type.tr,
        TranslationKeys.count.tr,
        TranslationKeys.amount.tr,
      ],
      rows: items
          .map((t) => [
                capitalizeWords(t.type ?? '—'),
                '${t.count ?? 0}',
                _fmt(t.amount),
              ])
          .toList(),
    );
  }

  // ─── Payments by method: Method | Count | Tips | Amount ───────────

  Widget _buildPaymentsTable(List<PaymentByMethod> methods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: MySize.getHeight(3)),
          child: Row(children: [
            Expanded(
                flex: 4,
                child: Text(TranslationKeys.method.tr,
                    style: TextStyle(
                        fontSize: MySize.getHeight(13.5 * _fontScale),
                        fontWeight: FontWeight.w700,
                        color: Colors.black))),
            Expanded(
                flex: 2,
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(TranslationKeys.count.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: MySize.getHeight(13.5 * _fontScale),
                            fontWeight: FontWeight.w700,
                            color: Colors.black)))),
            Expanded(
                flex: 3,
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(TranslationKeys.tips.tr,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: MySize.getHeight(13.5 * _fontScale),
                            fontWeight: FontWeight.w700,
                            color: Colors.black)))),
            Expanded(
                flex: 3,
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(TranslationKeys.amount.tr,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: MySize.getHeight(13.5 * _fontScale),
                            fontWeight: FontWeight.w700,
                            color: Colors.black)))),
          ]),
        ),
        const Divider(height: 1, color: Colors.black, thickness: 1),
        SizedBox(height: MySize.getHeight(4)),
        ...methods.map((p) => Padding(
              padding: EdgeInsets.symmetric(vertical: MySize.getHeight(2.5)),
              child: Row(children: [
                Expanded(
                    flex: 4,
                    child: Text(capitalizeWords(p.method ?? '—'),
                        style: TextStyle(
                            fontSize: MySize.getHeight(13.5 * _fontScale),
                            color: Colors.black87))),
                Expanded(
                    flex: 2,
                    child: Text('${p.count ?? 0}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: MySize.getHeight(13.5 * _fontScale),
                            color: Colors.black87))),
                Expanded(
                    flex: 3,
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(_fmt(p.tips),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: MySize.getHeight(13.5 * _fontScale),
                                color: Colors.black87)))),
                Expanded(
                    flex: 3,
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(_fmt(p.amount),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: MySize.getHeight(13.5 * _fontScale),
                                color: Colors.black87)))),
              ]),
            )),
      ],
    );
  }

  // ─── Refunds by method: Method | Count | Amount — fully dynamic ───────────

  Widget _buildRefundsMethodTable(List<RefundByMethod> items) {
    return _buildSimpleTable(
      headers: [
        TranslationKeys.method.tr,
        TranslationKeys.count.tr,
        TranslationKeys.amount.tr,
      ],
      rows: items
          .map((m) => [
                capitalizeWords(m.method ?? '—'),
                '${m.count ?? 0}',
                _fmt(m.amount),
              ])
          .toList(),
    );
  }

  // ─── Generic 3-column table (Type/Method | Count | Amount) ───────────────
  // Used by sales-by-type and refunds-by-method.

  Widget _buildSimpleTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: MySize.getHeight(3)),
          child: Row(children: [
            Expanded(
                flex: 4,
                child: Text(headers[0],
                    style: TextStyle(
                        fontSize: MySize.getHeight(13.5 * _fontScale),
                        fontWeight: FontWeight.w700,
                        color: Colors.black))),
            Expanded(
                flex: 2,
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.center,
                    child: Text(headers[1],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: MySize.getHeight(13.5 * _fontScale),
                            fontWeight: FontWeight.w700,
                            color: Colors.black)))),
            Expanded(
                flex: 3,
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(headers[2],
                        textAlign: TextAlign.right,
                        style: TextStyle(
                            fontSize: MySize.getHeight(13.5 * _fontScale),
                            fontWeight: FontWeight.w700,
                            color: Colors.black)))),
          ]),
        ),
        const Divider(height: 1, color: Colors.black, thickness: 1),
        SizedBox(height: MySize.getHeight(4)),
        ...rows.map((r) => Padding(
              padding: EdgeInsets.symmetric(vertical: MySize.getHeight(2.5)),
              child: Row(children: [
                Expanded(
                    flex: 4,
                    child: Text(r[0],
                        style: TextStyle(
                            fontSize: MySize.getHeight(13.5 * _fontScale),
                            color: Colors.black87))),
                Expanded(
                    flex: 2,
                    child: Text(r[1],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: MySize.getHeight(13.5 * _fontScale),
                            color: Colors.black87))),
                Expanded(
                    flex: 3,
                    child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(r[2],
                            textAlign: TextAlign.right,
                            style: TextStyle(
                                fontSize: MySize.getHeight(13.5 * _fontScale),
                                color: Colors.black87)))),
              ]),
            )),
      ],
    );
  }

  // ─── Dashed separator line ────────────────────────────────────────────────

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 5.0;
        const dashSpace = 3.0;
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Flex(
          direction: Axis.horizontal,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(
            dashCount,
            (_) => SizedBox(
              width: dashWidth,
              height: 1,
              child: const DecoratedBox(
                  decoration: BoxDecoration(color: Colors.black54)),
            ),
          ),
        );
      },
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  String _fmt(num? v) {
    if (v == null) return '—';
    return CurrencyFormatter.formatPriceFromDouble(v.toDouble());
  }
}
