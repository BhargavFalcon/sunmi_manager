import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/translation_keys.dart';
import '../model/daily_sales_summary_model.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_time_formatter.dart';
import '../utils/order_helpers.dart';

class DailySummaryReceiptWidget extends StatelessWidget {
  final DailySalesSummaryData data;
  final double width;

  const DailySummaryReceiptWidget({
    super.key,
    required this.data,
    this.width = 360,
  });

  bool get _is80mm => width > 400;

  double get _titleSize => _is80mm ? 42 : 34;
  double get _subHeaderSize => _is80mm ? 26 : 22;
  double get _sectionTitleSize => _is80mm ? 30 : 26;
  double get _subTitleSize => _is80mm ? 26 : 22;
  double get _textSize => _is80mm ? 26 : 22;
  double get _tableTextSize => _is80mm ? 24 : 20;
  double get _totalTextSize => _is80mm ? 30 : 26;
  double get _footerTextSize => _is80mm ? 24 : 20;

  String _fmt(num? v) {
    if (v == null) return '—';
    return CurrencyFormatter.formatPriceFromDouble(v.toDouble());
  }

  Widget _divider({double height = 1.5, double verticalSpace = 10}) {
    return Column(
      children: [
        SizedBox(height: verticalSpace),
        Container(
          width: double.infinity,
          height: height,
          color: Colors.black,
        ),
        SizedBox(height: verticalSpace),
      ],
    );
  }

  Widget _dashedLine({double verticalSpace = 10}) {
    return Column(
      children: [
        SizedBox(height: verticalSpace),
        LayoutBuilder(
          builder: (context, constraints) {
            final boxWidth = constraints.constrainWidth();
            const dashWidth = 6.0;
            const dashSpace = 4.0;
            final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                dashCount,
                (_) => Container(
                  width: dashWidth,
                  height: 1.5,
                  color: Colors.black54,
                ),
              ),
            );
          },
        ),
        SizedBox(height: verticalSpace),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: _sectionTitleSize,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.8,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildSubTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: _subTitleSize,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: isBold ? _totalTextSize : _textSize,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: isBold ? _totalTextSize : _textSize,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final period = data.period;
    final orders = data.orders;
    final sales = data.sales;
    final payments = data.payments;
    final refunds = data.refunds;
    final restaurantName = CurrencyFormatter.getRestaurantName();
    final branchName = CurrencyFormatter.getBranchName();
    final now = DateTimeFormatter.nowInRestaurantTimezone(
      data.period?.timezone,
    );

    return Container(
      width: width,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Header ─────────────────────────────────────────
          Center(
            child: Column(
              children: [
                if (restaurantName.isNotEmpty)
                  Text(
                    restaurantName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: _titleSize,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      height: 1.1,
                    ),
                  ),
                if (branchName.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    branchName,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: _subHeaderSize,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                  TranslationKeys.todaySummary.tr.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: _titleSize * 0.85,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Colors.black,
                  ),
                ),
                if (period?.businessDate != null &&
                    period!.businessDate!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    period.businessDate!,
                    style: GoogleFonts.inter(
                      fontSize: _subHeaderSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
          ),

          _divider(height: 2),

          // ─── Orders Section ──────────────────────────────────
          if (orders != null) ...[
            _buildSectionTitle(TranslationKeys.orders.tr),
            _buildRow(TranslationKeys.totalOrders.tr, '${orders.totalOrders ?? 0}'),
            _buildRow(TranslationKeys.paidOrders.tr, '${orders.paidOrders ?? 0}'),
            _buildRow(TranslationKeys.countedOrders.tr, '${orders.ordersCounted ?? 0}'),
            _buildRow(TranslationKeys.cancelledOrders.tr, '${orders.cancelledCount ?? 0}'),
            if (orders.ongoing != null && (orders.ongoing!.count ?? 0) > 0) ...[
              const SizedBox(height: 4),
              _buildRow(TranslationKeys.ongoing.tr, '${orders.ongoing!.count}'),
              _buildRow(TranslationKeys.ongoingAmount.tr, _fmt(orders.ongoing!.amount)),
            ],
            if (orders.countByType != null && orders.countByType!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildSubTitle(TranslationKeys.byOrderType.tr),
              ...orders.countByType!.entries.map(
                (e) => _buildRow(capitalizeWords(e.key), '${e.value}'),
              ),
            ],
            if (orders.countByStatus != null && orders.countByStatus!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildSubTitle(TranslationKeys.byStatus.tr),
              ...orders.countByStatus!.entries.map(
                (e) => _buildRow(capitalizeWords(e.key), '${e.value}'),
              ),
            ],
            _dashedLine(),
          ],

          // ─── Sales Section ───────────────────────────────────
          if (sales != null) ...[
            _buildSectionTitle(TranslationKeys.sales.tr),
            _buildRow(TranslationKeys.gross.tr, _fmt(sales.gross)),
            _buildRow(TranslationKeys.subTotal.tr, _fmt(sales.subTotal)),
            if (sales.taxesByRate != null && sales.taxesByRate!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildSubTitle(TranslationKeys.taxesByRate.tr),
              const SizedBox(height: 4),
              _buildTaxesTable(sales.taxesByRate!),
              const SizedBox(height: 6),
            ],
            _buildRow(TranslationKeys.totalTax.tr, _fmt(sales.totalTax), isBold: true),
            _buildRow(
              TranslationKeys.discounts.tr,
              _fmt(sales.discounts?.total ?? 0),
              isBold: true,
            ),
            _buildRow(TranslationKeys.tips.tr, _fmt(sales.tips?.total ?? 0), isBold: true),
            if (sales.byType != null && sales.byType!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildSubTitle(TranslationKeys.salesByType.tr),
              const SizedBox(height: 4),
              _buildSalesByTypeTable(sales.byType!),
              const SizedBox(height: 6),
            ],
            _buildRow(TranslationKeys.net.tr, _fmt(sales.net), isBold: true),
            _dashedLine(),
          ],

          // ─── Payments Section ────────────────────────────────
          if (payments != null) ...[
            _buildSectionTitle(TranslationKeys.payments.tr),
            if (payments.byMethod != null && payments.byMethod!.isNotEmpty) ...[
              const SizedBox(height: 4),
              _buildPaymentsTable(payments.byMethod!),
              const SizedBox(height: 6),
            ],
            _buildRow(TranslationKeys.totalCollected.tr, _fmt(payments.total), isBold: true),
            _buildRow(
              TranslationKeys.paymentDue.tr,
              _fmt(payments.dueOutstanding ?? payments.duePlaceholder ?? 0),
            ),
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
            _dashedLine(),
          ],

          // ─── Refunds Section ─────────────────────────────────
          if (refunds != null) ...[
            _buildSectionTitle(TranslationKeys.refunds.tr),
            _buildRow(TranslationKeys.count.tr, '${refunds.count ?? 0}'),
            _buildRow(TranslationKeys.total.tr, _fmt(refunds.total), isBold: true),
            if (refunds.byMethod != null && refunds.byMethod!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildSubTitle(TranslationKeys.byMethod.tr),
              const SizedBox(height: 4),
              _buildRefundsMethodTable(refunds.byMethod!),
            ],
            _dashedLine(),
          ],

          // ─── Footer Timestamp ────────────────────────────────
          const SizedBox(height: 8),
          Center(
            child: Text(
              '${TranslationKeys.printed.tr} ${DateTimeFormatter.formatReportDateTime(now)}',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: _footerTextSize,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 25),
        ],
      ),
    );
  }

  // ─── Tables ──────────────────────────────────────────────────

  Widget _buildTaxesTable(List<TaxByRate> taxes) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Text(
                  TranslationKeys.nameRate.tr,
                  style: GoogleFonts.inter(
                    fontSize: _tableTextSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  TranslationKeys.net.tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: _tableTextSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  TranslationKeys.tax.tr,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: _tableTextSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: Colors.black),
        const SizedBox(height: 4),
        ...taxes.map((t) {
          final pct =
              t.taxPercentage != null
                  ? '${t.taxPercentage!.toStringAsFixed(2)}%'
                  : '0.00%';
          final label =
              (t.name != null && t.name!.isNotEmpty) ? '${t.name} ($pct)' : pct;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: _tableTextSize,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    _fmt(t.netAmount),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: _tableTextSize,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    _fmt(t.taxAmount),
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: _tableTextSize,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

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

  Widget _buildPaymentsTable(List<PaymentByMethod> methods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  TranslationKeys.method.tr,
                  style: GoogleFonts.inter(
                    fontSize: _tableTextSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  TranslationKeys.count.tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: _tableTextSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  TranslationKeys.tips.tr,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: _tableTextSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  TranslationKeys.amount.tr,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: _tableTextSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: Colors.black),
        const SizedBox(height: 4),
        ...methods.map(
          (p) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    capitalizeWords(p.method ?? '—'),
                    style: GoogleFonts.inter(
                      fontSize: _tableTextSize,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '${p.count ?? 0}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: _tableTextSize,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    _fmt(p.tips),
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: _tableTextSize,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    _fmt(p.amount),
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: _tableTextSize,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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

  Widget _buildSimpleTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  headers[0],
                  style: GoogleFonts.inter(
                    fontSize: _tableTextSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  headers[1],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: _tableTextSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  headers[2],
                  textAlign: TextAlign.right,
                  style: GoogleFonts.inter(
                    fontSize: _tableTextSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(height: 1, color: Colors.black),
        const SizedBox(height: 4),
        ...rows.map(
          (r) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Text(
                    r[0],
                    style: GoogleFonts.inter(
                      fontSize: _tableTextSize,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    r[1],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: _tableTextSize,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    r[2],
                    textAlign: TextAlign.right,
                    style: GoogleFonts.inter(
                      fontSize: _tableTextSize,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
