import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/kitchen_ticket_model.dart';
import '../utils/date_time_formatter.dart';
import '../constants/translation_keys.dart';
import '../utils/order_helpers.dart';

/// KOT Receipt Widget — matches DineMetrics Manager KOT layout.
/// Rendered as an off-screen widget and captured as an image for Sunmi printing.
class KotReceiptWidget extends StatelessWidget {
  final KitchenTicket ticket;
  final double width;
  final String? timezone;

  const KotReceiptWidget({
    super.key,
    required this.ticket,
    this.width = 360,
    this.timezone,
  });

  // font sizes scale with paper width
  double get _headerFs => width > 400 ? 42.0 : 36.0;
  double get _metaFs => width > 400 ? 28.0 : 30.0;
  double get _itemFs => width > 400 ? 34.0 : 36.0;
  double get _subFs => width > 400 ? 24.0 : 26.0;
  double get _labelFs => width > 400 ? 22.0 : 24.0;

  @override
  Widget build(BuildContext context) {
    final order = ticket.order;
    final items = ticket.items;

    // ── Order number (matches DineMetrics: shows orderNumber + orderType)
    final orderNum = order?.formattedOrderNumber ??
        order?.orderNumber?.toString() ??
        ticket.kotNumber ??
        '';
    final orderTypeStr = (order?.orderType != null && order!.orderType!.isNotEmpty)
        ? ' (${formatOrderType(order.orderType)})'
        : '';
    final orderHeader = '${TranslationKeys.order.tr}: $orderNum$orderTypeStr';

    // ── Table
    final tableLabel = _tableLabel(order);

    // ── Date / Time in Restaurant Timezone
    final effectiveTz = (timezone != null && timezone!.trim().isNotEmpty)
        ? timezone!.trim()
        : DateTimeFormatter.restaurantTimezoneNameFromStorage();

    final createdAt = order?.createdAt ?? ticket.createdAt ?? '';
    final dateStr = createdAt.isNotEmpty
        ? DateTimeFormatter.formatDateOnly(createdAt, effectiveTz)
        : '';
    final timeStr = createdAt.isNotEmpty
        ? DateTimeFormatter.formatTimeOnly(createdAt, effectiveTz)
        : '';

    // ── Scheduled delivery/pickup time
    final orderType = order?.orderType?.toLowerCase() ?? '';
    final timeLabel = getTimeLabel(orderType);
    final dateTimeStr = order?.dateTime ?? '';
    final scheduledTime = (timeLabel != null && dateTimeStr.isNotEmpty)
        ? DateTimeFormatter.formatDateTime(dateTimeStr, timezoneName: effectiveTz)
        : null;

    // ── Order note
    final orderNote = ticket.note ?? order?.note ?? '';

    return Container(
      width: width,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── ORDER NUMBER + ORDER TYPE (bold, large — like DineMetrics header)
          Text(
            orderHeader,
            style: GoogleFonts.inter(
              fontSize: _headerFs,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              height: 1.15,
            ),
          ),

          // ── TABLE
          if (tableLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${TranslationKeys.table.tr}: $tableLabel',
              style: GoogleFonts.inter(
                fontSize: _headerFs,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                height: 1.15,
              ),
            ),
          ],

          const SizedBox(height: 10),
          _divider(),
          const SizedBox(height: 8),

          // ── CREATED AT
          if (dateStr.isNotEmpty || timeStr.isNotEmpty)
            _infoRow(
              '${TranslationKeys.date.tr}: $dateStr   ${TranslationKeys.time.tr}: $timeStr',
            ),

          // ── SCHEDULED TIME (pickup / delivery)
          if (scheduledTime != null && timeLabel != null)
            _infoRow('$timeLabel: $scheduledTime', bold: true),

          const SizedBox(height: 8),
          _divider(height: 2),
          const SizedBox(height: 6),

          // ── ITEMS COLUMN HEADERS
          Row(
            children: [
              Expanded(
                child: Text(
                  TranslationKeys.itemName.tr.toUpperCase(),
                  style: GoogleFonts.inter(
                    fontSize: _labelFs,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ),
              Text(
                TranslationKeys.qty.tr.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: _labelFs,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          _divider(),
          const SizedBox(height: 6),

          // ── ITEMS LIST
          if (items != null)
            for (final item in items) _buildItemRow(item),

          _divider(height: 2),

          // ── ORDER NOTE
          if (orderNote.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${TranslationKeys.note.tr}:',
                    style: GoogleFonts.inter(
                      fontSize: _metaFs,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    orderNote,
                    style: GoogleFonts.inter(
                      fontSize: _metaFs,
                      color: Colors.black,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── ITEM ROW ─────────────────────────────────────────────────────────────
  Widget _buildItemRow(KitchenTicketItem item) {
    final itemName = item.itemName ?? '';
    final qty = '${item.quantity ?? 1}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "Qty x ItemName" — bold, large (matches DineMetrics itemBold)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$qty x ',
                style: GoogleFonts.inter(
                  fontSize: _itemFs,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Text(
                  itemName,
                  style: GoogleFonts.inter(
                    fontSize: _itemFs,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),

          // Variation — "(Large)"
          if (item.variationName != null && item.variationName!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 2),
              child: Text(
                '(${item.variationName})',
                style: GoogleFonts.inter(
                  fontSize: _subFs,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          // Modifiers — "- Extra Cheese"
          if (item.modifiers != null)
            for (final mod in item.modifiers!)
              Padding(
                padding: const EdgeInsets.only(left: 28, top: 2),
                child: Text(
                  '- ${mod.name ?? ''}',
                  style: GoogleFonts.inter(
                    fontSize: _subFs,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

          // Item note
          if (item.note != null && item.note!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 28, top: 2),
              child: Text(
                '${TranslationKeys.note.tr}: ${item.note!}',
                style: GoogleFonts.inter(
                  fontSize: _subFs,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          const SizedBox(height: 4),
          _divider(),
        ],
      ),
    );
  }

  // ── INFO ROW ─────────────────────────────────────────────────────────────
  Widget _infoRow(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: _metaFs,
          color: Colors.black,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }

  // ── TABLE LABEL ──────────────────────────────────────────────────────────
  String _tableLabel(KitchenTicketOrder? order) {
    if (order == null) return '';
    if (order.table is Map) {
      return (order.table['table_code'] ?? order.table['name'] ?? '').toString();
    }
    return order.table?.toString() ?? '';
  }

  // ── DIVIDER ──────────────────────────────────────────────────────────────
  Widget _divider({double height = 1.0}) {
    return Container(width: width, height: height, color: Colors.black);
  }
}
