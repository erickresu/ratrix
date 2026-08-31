import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../../core/utils/money_formatting.dart';
import '../../../domain/entities/client.dart';
import '../../../domain/entities/rates_fk_ids.dart';
import '../../bloc/shipping_calculator_bloc.dart';

const _goldDeep = PdfColor.fromInt(0xFFB8890F);
const _textBody = PdfColor.fromInt(0xFF1A1F26);
const _textMuted = PdfColor.fromInt(0xFF6B7280);
const _border = PdfColor.fromInt(0xFFE2E5EA);
const _sectionBg = PdfColor.fromInt(0xFFF4F6F8);
const _white = PdfColor.fromInt(0xFFFFFFFF);
// Matches the logo asset's own canvas (regenerated navy, no alpha) and
// `RatesColors.dark.sidebarBg` — the header band needs to be the same navy
// for the logo to blend in rather than showing as a box.
const _brandNavy = PdfColor.fromInt(0xFF0F1B2E);

typedef _ChargeItem = ({String description, String rate, String qty, num total});

/// Builds and opens the print/save dialog (`Printing.layoutPdf`) for a
/// freight-breakdown invoice — colored header band, bill-to block, shipping
/// details, an itemized charges table, and the VAT/total + signature footer.
/// Pulls every figure from the same [ShippingCalculatorState]/[CalcResult]
/// the on-screen dialog renders, so the PDF can never disagree with what the
/// user saw before exporting. Anything the app has no real data for
/// (a persisted invoice sequence, payment/bank details) is either left out
/// or clearly labeled as a reference, not fabricated.
Future<void> generateInvoicePdf({
  required ShippingCalculatorState state,
  required Client client,
}) async {
  final result = state.calcResult;
  if (result == null || result.error != null) return;

  final logoBytes = await rootBundle.load('assets/images/ratrix_logo.png');
  final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());

  final doc = pw.Document();
  final now = DateTime.now();
  final dateLabel = '${now.month}/${now.day}/${now.year}';
  final timeLabel = _formatTime(now);
  final referenceNo = '${state.selectedChargeCode ?? 'NA'}-${_stamp(now)}';

  final pricingOptionId = state.selectedRate?.chargeOption?.id;
  final pricingLabel = pricingOptionId != null ? RatesFkIds.pricingOptionFromId[pricingOptionId]?.label ?? '-' : '-';

  final items = <_ChargeItem>[
    (
      description: 'Base Freight',
      rate: result.tierRate != null ? 'Php ${formatMoney(result.tierRate!)}/kg' : '-',
      qty: result.chargeableWeight != null ? '${result.chargeableWeight!.toStringAsFixed(2)} kg' : '-',
      total: result.baseFreight ?? 0,
    ),
    if (result.fuelSurcharge != null && result.fuelSurcharge != 0)
      (description: 'Fuel Surcharge', rate: '-', qty: '1', total: result.fuelSurcharge!),
    for (final entry in result.flatFees.entries) (description: entry.key, rate: '-', qty: '1', total: entry.value),
  ];

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _header(logo, referenceNo, dateLabel, timeLabel),
            pw.SizedBox(height: 18),
            _billTo(client, state),
            pw.SizedBox(height: 14),
            _section('SHIPPING DETAILS', [
              _fieldPair('Category', state.freightMode.label.toUpperCase(), 'Service Mode', state.serviceMode.label),
              _fieldPair('Origin', state.origin, 'Destination', state.destination),
              _fieldPair(
                'Dims',
                '${state.dimensions.map((d) => '${d.length}×${d.width}×${d.height}').join(', ')} cm',
                'Weight',
                '${state.weight} kg',
              ),
              _fieldPair('Pricing Model', pricingLabel, 'Rate Table', '${state.selectedChargeCode ?? '-'} (${state.rateType.label})'),
            ]),
            pw.SizedBox(height: 18),
            _itemTable(items),
            pw.SizedBox(height: 14),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.SizedBox(
                  width: 220,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                    children: [
                      _chargeRow(state.vatInclusive ? 'VATable Subtotal:' : 'Sub-Total:', result.subTotal),
                      if (state.vatMode == VatMode.standard)
                        _chargeRow('VAT (${(ShippingCalculatorState.vatRate * 100).toStringAsFixed(0)}%):', state.vatAmount)
                      else if (state.vatMode.saleLabel != null)
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(top: 2, bottom: 2),
                          child: pw.Text(
                            state.vatMode.saleLabel!,
                            style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, fontStyle: pw.FontStyle.italic, color: _goldDeep),
                          ),
                        ),
                      pw.SizedBox(height: 6),
                      pw.Divider(color: _border, thickness: 1),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('TOTAL:', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _textBody)),
                          pw.Text(
                            'Php ${formatMoney(state.roundedDisplay ? state.grandTotal.roundToDouble() : state.grandTotal)}',
                            style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold, color: _goldDeep),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 24),
            pw.Text('TERMS', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _textMuted, letterSpacing: 0.5)),
            pw.SizedBox(height: 4),
            pw.Text(
              'This is a computed freight breakdown, not a formal billing invoice - figures reflect the rate card and '
              'cargo details entered above. Please confirm final charges and payment arrangements with your CERRO '
              'RATRIX account handler before remitting payment.',
              style: pw.TextStyle(fontSize: 8, color: _textMuted, lineSpacing: 2),
            ),
            pw.SizedBox(height: 40),
            pw.Container(width: 180, height: 1, color: _border),
            pw.SizedBox(height: 4),
            pw.Text('Prepared by', style: pw.TextStyle(fontSize: 9, color: _textMuted)),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (_) => doc.save());
}

pw.Widget _header(pw.ImageProvider logo, String referenceNo, String date, String time) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(16),
    decoration: pw.BoxDecoration(
      color: _brandNavy,
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: 44, height: 44, child: pw.Image(logo, fit: pw.BoxFit.contain)),
        pw.SizedBox(width: 12),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('FREIGHT BREAKDOWN', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: _white)),
              pw.SizedBox(height: 4),
              pw.Text(
                'Reference #: $referenceNo',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(fontSize: 7, color: _white),
              ),
              pw.Text('Date: $date  $time', style: pw.TextStyle(fontSize: 8, color: _white)),
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _billTo(Client client, ShippingCalculatorState state) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(color: _sectionBg, borderRadius: pw.BorderRadius.circular(4)),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('BILL TO', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _textMuted, letterSpacing: 0.5)),
        pw.SizedBox(height: 6),
        pw.Text(client.name, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: _textBody)),
        pw.SizedBox(height: 6),
        _fieldPair('Account #', client.accountNumber, 'Email', client.email.isEmpty ? '-' : client.email),
        if ((client.phoneNumber != null && client.phoneNumber!.isNotEmpty) || client.officeAddress != null) ...[
          pw.SizedBox(height: 6),
          _fieldPair(
            'Phone',
            client.phoneNumber != null && client.phoneNumber!.isNotEmpty ? client.phoneNumber! : '-',
            'VAT Status',
            state.vatMode.saleLabel ?? (state.vatInclusive ? 'Inclusive' : 'Exclusive'),
          ),
        ] else ...[
          pw.SizedBox(height: 6),
          _fieldPair('VAT Status', state.vatMode.saleLabel ?? (state.vatInclusive ? 'Inclusive' : 'Exclusive'), '', ''),
        ],
        if (client.officeAddress != null && client.officeAddress!.isNotEmpty) ...[
          pw.SizedBox(height: 6),
          _field('Address', client.officeAddress!),
        ],
      ],
    ),
  );
}

pw.Widget _itemTable(List<_ChargeItem> items) {
  pw.Widget headerCell(String text, {pw.TextAlign align = pw.TextAlign.left}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: pw.Text(
          text,
          textAlign: align,
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _white, letterSpacing: 0.3),
        ),
      );

  pw.Widget cell(String text, {pw.TextAlign align = pw.TextAlign.left, bool bold = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: pw.Text(
          text,
          textAlign: align,
          style: pw.TextStyle(fontSize: 9, color: _textBody, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal),
        ),
      );

  return pw.Table(
    border: pw.TableBorder.all(color: _border, width: 0.5),
    columnWidths: const {
      0: pw.FlexColumnWidth(0.5),
      1: pw.FlexColumnWidth(2.4),
      2: pw.FlexColumnWidth(1.4),
      3: pw.FlexColumnWidth(1.1),
      4: pw.FlexColumnWidth(1.3),
    },
    children: [
      pw.TableRow(
        decoration: pw.BoxDecoration(color: _goldDeep),
        children: [
          headerCell('SL'),
          headerCell('DESCRIPTION'),
          headerCell('RATE'),
          headerCell('QTY'),
          headerCell('TOTAL', align: pw.TextAlign.right),
        ],
      ),
      for (var i = 0; i < items.length; i++)
        pw.TableRow(
          children: [
            cell('${i + 1}'),
            cell(items[i].description, bold: true),
            cell(items[i].rate),
            cell(items[i].qty),
            cell('Php ${formatMoney(items[i].total)}', align: pw.TextAlign.right),
          ],
        ),
    ],
  );
}

pw.Widget _section(String title, List<pw.Widget> rows) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(color: _sectionBg, borderRadius: pw.BorderRadius.circular(4)),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _textMuted, letterSpacing: 0.5)),
        pw.SizedBox(height: 8),
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) pw.SizedBox(height: 8),
          rows[i],
        ],
      ],
    ),
  );
}

pw.Widget _fieldPair(String label1, String value1, String label2, String value2) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(child: _field(label1, value1)),
      pw.SizedBox(width: 8),
      if (label2.isNotEmpty) pw.Expanded(child: _field(label2, value2)) else pw.Expanded(child: pw.SizedBox()),
    ],
  );
}

// The value can be arbitrarily long (rate/charge codes, addresses) — give it
// its own `Expanded` so it wraps onto more lines within the column instead
// of overflowing past it (a bare `Text` in a `Row` doesn't get clipped or
// wrapped by its parent's width).
pw.Widget _field(String label, String value) {
  if (label.isEmpty) return pw.SizedBox();
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text('$label: ', style: pw.TextStyle(fontSize: 9, color: _textMuted)),
      pw.Expanded(
        child: pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _textBody)),
      ),
    ],
  );
}

pw.Widget _chargeRow(String label, num? value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(fontSize: 10, color: _textBody)),
        pw.Text(
          value == null ? '-' : 'Php ${formatMoney(value)}',
          style: pw.TextStyle(fontSize: 10, color: _textBody),
        ),
      ],
    ),
  );
}

String _formatTime(DateTime dt) {
  final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final second = dt.second.toString().padLeft(2, '0');
  final period = dt.hour >= 12 ? 'PM' : 'AM';
  return '$hour12:$minute:$second $period';
}

/// Compact `yyyyMMddHHmmss` timestamp for [referenceNo] — deterministic from
/// the moment of generation, not a persisted/sequential invoice number (the
/// calculator doesn't save records anywhere).
String _stamp(DateTime dt) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${dt.year}${two(dt.month)}${two(dt.day)}${two(dt.hour)}${two(dt.minute)}${two(dt.second)}';
}
