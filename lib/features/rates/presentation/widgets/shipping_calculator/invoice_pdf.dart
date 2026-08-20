import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../domain/entities/rates_fk_ids.dart';
import '../../bloc/shipping_calculator_bloc.dart';

const _teal = PdfColor.fromInt(0xFF2CC6A6);
const _tealDeep = PdfColor.fromInt(0xFF1B7A65);
const _textBody = PdfColor.fromInt(0xFF1A1F26);
const _textMuted = PdfColor.fromInt(0xFF6B7280);
const _border = PdfColor.fromInt(0xFFE2E5EA);
const _sectionBg = PdfColor.fromInt(0xFFF4F6F8);

/// Builds and opens the print/save dialog (`Printing.layoutPdf`) for a
/// freight-breakdown invoice matching the reference design — logo header,
/// client/date block, shipping/dimension/calculation sections, itemized
/// charges, and the VAT/total footer. Pulls every figure from the same
/// [ShippingCalculatorState]/[CalcResult] the on-screen dialog renders, so
/// the PDF can never disagree with what the user saw before exporting.
Future<void> generateInvoicePdf({
  required ShippingCalculatorState state,
  required String clientName,
}) async {
  final result = state.calcResult;
  if (result == null || result.error != null) return;

  final doc = pw.Document();
  final now = DateTime.now();
  final dateLabel = '${now.month}/${now.day}/${now.year}';
  final timeLabel = _formatTime(now);

  final pricingOptionId = state.selectedRate?.chargeOption?.id;
  final pricingLabel = pricingOptionId != null ? RatesFkIds.pricingOptionFromId[pricingOptionId]?.label ?? '—' : '—';

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _header(dateLabel, timeLabel),
            pw.SizedBox(height: 16),
            _clientRow(clientName, state, dateLabel, timeLabel),
            pw.SizedBox(height: 16),
            _section('SHIPPING DETAILS', [
              _fieldPair('Category', state.freightMode.label.toUpperCase(), 'Service Mode', state.serviceMode.label),
              _fieldPair('Origin', state.origin, 'Destination', state.destination),
            ]),
            pw.SizedBox(height: 12),
            _section('DIMENSIONS & WEIGHT', [
              _fieldPair(
                'Dims',
                '${state.length} × ${state.width} × ${state.height} cm',
                'Vol Divisor',
                state.divisor,
              ),
              _fieldPair('Weight', '${state.weight} kg', 'Charge Basis', state.chargeBasis.label),
            ]),
            pw.SizedBox(height: 12),
            _section('CALCULATION BREAKDOWN', [
              _fieldPair(
                'Actual Weight',
                '${result.actualWeight?.toStringAsFixed(0) ?? '—'} kg',
                'Volumetric Wt',
                '${result.volumetricWeight?.toStringAsFixed(2) ?? '—'} kg',
              ),
              _fieldPair('CBM', result.cbm?.toStringAsFixed(3) ?? '—', '', ''),
              _fieldPair('Rate Table', '${state.selectedChargeCode ?? '—'} (${state.rateType.label})', '', ''),
              _fieldPair('Pricing Model', pricingLabel, '', ''),
            ]),
            pw.SizedBox(height: 16),
            _chargeRow('Base Freight:', result.baseFreight),
            if (result.fuelSurcharge != null && result.fuelSurcharge != 0) _chargeRow('Fuel Surcharge:', result.fuelSurcharge),
            for (final entry in result.flatFees.entries) _chargeRow('${entry.key}:', entry.value),
            pw.Spacer(),
            pw.Divider(color: _border, thickness: 1),
            pw.SizedBox(height: 8),
            _chargeRow(
              state.vatInclusive ? 'VATable Subtotal:' : 'Sub-Total:',
              result.subTotal,
            ),
            if (state.vatMode == VatMode.standard)
              _chargeRow('VAT (${(ShippingCalculatorState.vatRate * 100).toStringAsFixed(0)}%):', state.vatAmount),
            pw.SizedBox(height: 6),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL AMOUNT:', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _textBody)),
                pw.Text(
                  'Php ${(state.roundedDisplay ? state.grandTotal.roundToDouble() : state.grandTotal).toStringAsFixed(2)}',
                  style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: _tealDeep),
                ),
              ],
            ),
          ],
        );
      },
    ),
  );

  await Printing.layoutPdf(onLayout: (_) => doc.save());
}

pw.Widget _header(String date, String time) {
  return pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Row(
        children: [
          pw.Container(
            width: 22,
            height: 12,
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(16),
              border: pw.Border.all(color: _teal, width: 1.5),
            ),
          ),
          pw.SizedBox(width: 8),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('CERRO', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: _textMuted)),
              pw.Text('RATRIX', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, color: _textBody)),
            ],
          ),
        ],
      ),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Text('INVOICE', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: _textBody)),
          pw.Text('Generated by Ratrix Shipping Management', style: pw.TextStyle(fontSize: 8, color: _textMuted)),
        ],
      ),
    ],
  );
}

pw.Widget _clientRow(String clientName, ShippingCalculatorState state, String date, String time) {
  return pw.Column(
    children: [
      pw.Container(height: 2, color: _teal),
      pw.SizedBox(height: 10),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(children: [
                pw.Text('Client: ', style: pw.TextStyle(fontSize: 9, color: _textMuted)),
                pw.Text(clientName, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _textBody)),
              ]),
              pw.SizedBox(height: 2),
              pw.Row(children: [
                pw.Text('VAT Status: ', style: pw.TextStyle(fontSize: 9, color: _textMuted)),
                pw.Text(state.vatInclusive ? 'Inclusive' : 'Exclusive', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _textBody)),
              ]),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Row(children: [
                pw.Text('Date: ', style: pw.TextStyle(fontSize: 9, color: _textMuted)),
                pw.Text(date, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _textBody)),
              ]),
              pw.SizedBox(height: 2),
              pw.Row(children: [
                pw.Text('Time: ', style: pw.TextStyle(fontSize: 9, color: _textMuted)),
                pw.Text(time, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _textBody)),
              ]),
            ],
          ),
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
    children: [
      pw.Expanded(child: _field(label1, value1)),
      if (label2.isNotEmpty) pw.Expanded(child: _field(label2, value2)),
    ],
  );
}

pw.Widget _field(String label, String value) {
  if (label.isEmpty) return pw.SizedBox();
  return pw.Row(
    children: [
      pw.Text('$label: ', style: pw.TextStyle(fontSize: 9, color: _textMuted)),
      pw.Text(value, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: _textBody)),
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
          value == null ? '—' : 'Php ${value.toStringAsFixed(2)}',
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
