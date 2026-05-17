import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:invoxa/app/data/models/invoice_model.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../../../data/models/business_model.dart';
import '../../../../../../data/models/customer_model.dart';

/// Drop-in PDF generator.
/// Usage:
///   final bytes = await InvoicePdfGenerator.generate(invoiceModel);
///   await Printing.layoutPdf(onLayout: (_) => bytes);
class InvoicePdfGenerator {
  // ── Colour Palette ────────────────────────────────────────────────────────
  static const _navy = PdfColor.fromInt(0xFF1A237E);
  static const _navyLight = PdfColor.fromInt(0xFF283593);
  static const _stripe = PdfColor.fromInt(0xFFF0F4FF);
  static const _border = PdfColor.fromInt(0xFFBDBDBD);
  static const _textDark = PdfColor.fromInt(0xFF212121);
  static const _textMid = PdfColor.fromInt(0xFF616161);
  static const _white = PdfColors.white;

  // ── Formatters ────────────────────────────────────────────────────────────
  static final _money = NumberFormat('#,##0.00', 'en_IN');
  static final _date = DateFormat('dd-MMM-yyyy');

  // ── Public API ────────────────────────────────────────────────────────────

  /// Generates a 2-page PDF (Original + Duplicate) from [invoice].
  static Future<Uint8List> generate(InvoiceModel invoice) async {
    final pdf = pw.Document();
    pdf.addPage(_page(invoice, 'ORIGINAL FOR RECIPIENT'));
    pdf.addPage(_page(invoice, 'DUPLICATE FOR TRANSPORTER'));
    return pdf.save();
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  PAGE
  // ═════════════════════════════════════════════════════════════════════════

  static pw.Page _page(InvoiceModel inv, String copyLabel) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      build: (ctx) =>
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.stretch, children: [_header(inv, copyLabel), pw.SizedBox(height: 6), _partyRow(inv), pw.SizedBox(height: 6), _itemsTable(inv), pw.SizedBox(height: 6), _amountWords(inv), pw.SizedBox(height: 6), _footer(inv), pw.Spacer(), _watermark()]),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  HEADER
  // ═════════════════════════════════════════════════════════════════════════

  static pw.Widget _header(InvoiceModel inv, String copyLabel) {
    final seller = inv.sellerDetails;

    return _bordered(
      pw.Column(
        children: [
          // ── Title bar ──
          pw.Container(
            color: _navy,
            padding: const pw.EdgeInsets.symmetric(vertical: 5),
            child: pw.Center(child: _txt('Tax Invoice  ($copyLabel)', size: 10, bold: true, color: _white)),
          ),
          // ── Seller row ──
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Left: seller info
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _txt(seller?.businessName ?? '', size: 13, bold: true, color: _navy),
                      pw.SizedBox(height: 2),
                      if ((seller?.address?.street ?? '').isNotEmpty) _txt(seller?.address?.street ?? "", size: 8, color: _textMid),
                      if ((seller?.address?.city ?? '').isNotEmpty)
                        _txt(
                          '${seller?.address?.city ?? ''}'
                          '${seller?.address?.state != null ? ', ${seller?.address?.state}' : ''}'
                          '${seller?.address?.pincode != null ? ' - ${seller?.address?.pincode}' : ''}',
                          size: 8,
                          color: _textMid,
                        ),
                      if ((seller?.gstNumber ?? '').isNotEmpty) _txt('GSTIN/UIN : ${seller!.gstNumber}', size: 8),
                      if ((seller?.mobile ?? '').isNotEmpty) _txt('Contact : ${seller?.mobile}', size: 8),
                      if ((seller?.email ?? '').isNotEmpty) _txt('E-Mail : ${seller!.email}', size: 8),
                    ],
                  ),
                ),
                pw.SizedBox(width: 8),
                // Right: invoice meta box
                pw.Container(
                  width: 170,
                  decoration: pw.BoxDecoration(border: pw.Border.all(color: _border, width: 0.5)),
                  child: pw.Column(children: [_metaCell('Invoice No.', inv.invoiceNumber ?? '-'), _metaCell('Dated', inv.date != null ? _date.format(inv.date!) : '-'), _metaCell('Status', inv.status ?? '-'), if (inv.dueDate != null) _metaCell('Due Date', _date.format(inv.dueDate!))]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  PARTY ROW  (Buyer / Consignee)
  // ═════════════════════════════════════════════════════════════════════════

  static pw.Widget _partyRow(InvoiceModel inv) {
    final buyer = inv.buyerDetails;
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: _partyBox('Consignee (Ship to)', buyer ?? CustomerModel())),
        pw.SizedBox(width: 4),
        pw.Expanded(child: _partyBox('Buyer (Bill to)', buyer ?? CustomerModel())),
      ],
    );
  }

  static pw.Widget _partyBox(String title, CustomerModel party) {
    // party is CustomerModel
    return _bordered(
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            color: _navyLight,
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: _txt(title, size: 8, bold: true, color: _white),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _txt(party.name ?? '-', size: 9, bold: true),
                if ((party.address?.street ?? '').isNotEmpty) _txt(party.address?.street ?? "", size: 8, color: _textMid),
                if ((party.address?.city ?? '').isNotEmpty)
                  _txt(
                    '${party.address?.city ?? ''}'
                    '${party.address?.state != null ? ', ${party.address?.state}' : ''}'
                    '${party.address?.zipCode != null ? ' - ${party.address?.zipCode}' : ''}',
                    size: 8,
                    color: _textMid,
                  ),
                if ((party.gstNumber ?? '').isNotEmpty) _txt('GSTIN/UIN : ${party.gstNumber}', size: 8),
                if ((party?.mobile ?? '').isNotEmpty) _txt('Contact : ${party.mobile}', size: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  ITEMS TABLE
  // ═════════════════════════════════════════════════════════════════════════

  static pw.Widget _itemsTable(InvoiceModel inv) {
    final items = inv.items ?? [];

    // Decide which tax columns to show
    final showCGST = inv.hasCGST;
    final showSGST = inv.hasSGST;
    final showIGST = inv.hasIGST;

    // Build header labels dynamically
    final headers = <String>['Sl\nNo.', 'Description', 'HSN/SAC', 'Qty', 'Unit', 'Rate', 'Disc%', 'Amount'];
    if (showCGST) headers.add('CGST');
    if (showSGST) headers.add('SGST');
    if (showIGST) headers.add('IGST');
    headers.add('Total');

    // Column flex widths
    final flexes = <double>[0.4, 2.2, 0.8, 0.6, 0.5, 0.9, 0.5, 0.9, if (showCGST) 0.7, if (showSGST) 0.7, if (showIGST) 0.7, 1.0];

    pw.Widget cell(String text, {bool header = false, pw.TextAlign align = pw.TextAlign.center, bool stripe = false}) {
      return pw.Container(
        color: header ? _navy : (stripe ? _stripe : _white),
        padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
        child: _txt(text, size: 7.5, bold: header, color: header ? _white : _textDark, align: align),
      );
    }

    final colWidths = <int, pw.TableColumnWidth>{for (var i = 0; i < flexes.length; i++) i: pw.FlexColumnWidth(flexes[i])};

    double taxPerItem = inv.taxPercentage / (showCGST && showSGST ? 2 : 1);

    return pw.Table(
      border: pw.TableBorder.all(color: _border, width: 0.4),
      columnWidths: colWidths,
      children: [
        // ── Header row ──
        pw.TableRow(children: headers.map((h) => cell(h, header: true)).toList()),
        // ── Item rows ──
        ...items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final isStripe = i.isOdd;
          final taxBase = item.amount;
          final cgst = showCGST ? taxBase * taxPerItem / 100 : 0.0;
          final sgst = showSGST ? taxBase * taxPerItem / 100 : 0.0;
          final igst = showIGST ? taxBase * inv.taxPercentage / 100 : 0.0;
          final lineTotal = taxBase + cgst + sgst + igst;

          return pw.TableRow(
            children: [
              cell('${i + 1}', stripe: isStripe),
              cell([item.name, item.description].where((s) => s != null && s.isNotEmpty).join('\n'), align: pw.TextAlign.left, stripe: isStripe),
              cell(item.hsnCode ?? '', stripe: isStripe),
              cell(item.quantity.toStringAsFixed(2), stripe: isStripe),
              cell(item.unit ?? 'Pcs', stripe: isStripe),
              cell(_money.format(item.rate), stripe: isStripe),
              cell(item.discount > 0 ? '${item.discount}%' : '-', stripe: isStripe),
              cell(_money.format(item.amount), stripe: isStripe),
              if (showCGST) cell(_money.format(cgst), stripe: isStripe),
              if (showSGST) cell(_money.format(sgst), stripe: isStripe),
              if (showIGST) cell(_money.format(igst), stripe: isStripe),
              cell(_money.format(lineTotal), stripe: isStripe),
            ],
          );
        }),
        // ── Totals block ──
        _totalRow('Sub Total', inv.subTotal, flexes.length, skipCols: flexes.length - 2),
        if (inv.discountTotal > 0) _totalRow('Discount', -inv.discountTotal, flexes.length, skipCols: flexes.length - 2),
        if (showCGST) _totalRow('CGST (${(taxPerItem).toStringAsFixed(1)}%)', inv.taxTotal / (showCGST && showSGST ? 2 : 1), flexes.length, skipCols: flexes.length - 2),
        if (showSGST) _totalRow('SGST (${(taxPerItem).toStringAsFixed(1)}%)', inv.taxTotal / (showCGST && showSGST ? 2 : 1), flexes.length, skipCols: flexes.length - 2),
        if (showIGST) _totalRow('IGST (${inv.taxPercentage.toStringAsFixed(1)}%)', inv.taxTotal, flexes.length, skipCols: flexes.length - 2),
        // Grand Total row (full-width highlight)
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: _navy),
          children: [
            ...List.generate(flexes.length - 2, (index) => pw.Container()),

            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
              child: _txt('Grand Total', bold: true, color: _white, size: 9, align: pw.TextAlign.right),
            ),

            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
              child: _txt('₹ ${_money.format(inv.grandTotal)}', bold: true, color: _white, size: 9, align: pw.TextAlign.right),
            ),
          ],
        ),
      ],
    );
  }

  static pw.TableRow _totalRow(String label, double amount, int totalCols, {required int skipCols}) {
    return pw.TableRow(
      children: [
        // Empty columns
        ...List.generate(totalCols - 2, (index) => pw.Container()),

        // Label column
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: _txt(label, bold: true, size: 8, align: pw.TextAlign.right),
        ),

        // Amount column
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 3),
          child: _txt(_money.format(amount), size: 8, align: pw.TextAlign.right),
        ),
      ],
    );
  }
  // ═════════════════════════════════════════════════════════════════════════
  //  AMOUNT IN WORDS
  // ═════════════════════════════════════════════════════════════════════════

  static pw.Widget _amountWords(InvoiceModel inv) {
    return _bordered(
      pw.Padding(
        padding: const pw.EdgeInsets.all(7),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _txt('Amount Chargeable (in words)', size: 7.5, color: _navyLight),
            pw.SizedBox(height: 2),
            _txt('INR ${_toWords(inv.grandTotal)} Only', size: 9, bold: true),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  FOOTER  (declaration + bank + signatory)
  // ═════════════════════════════════════════════════════════════════════════

  static pw.Widget _footer(InvoiceModel inv) {
    final seller = inv.sellerDetails;

    return _bordered(
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Declaration
          pw.Expanded(
            flex: 3,
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _txt('Declaration', size: 8, bold: true, color: _navyLight),
                  pw.SizedBox(height: 3),
                  _txt(
                    'We declare that this invoice shows the actual price of the '
                    'goods described and that all particulars are true and correct.',
                    size: 7.5,
                    color: _textMid,
                  ),
                  pw.SizedBox(height: 4),
                  _txt('E. & O.E', size: 7.5, bold: true),
                  if ((inv.notes ?? '').isNotEmpty) ...[pw.SizedBox(height: 6), _txt('Notes:', size: 7.5, bold: true), _txt(inv.notes!, size: 7.5, color: _textMid)],
                ],
              ),
            ),
          ),
          // Bank Details (only if seller has bank info)
          if (_hasBankInfo(seller ?? BusinessModel()))
            pw.Expanded(
              flex: 3,
              child: pw.Container(
                decoration: const pw.BoxDecoration(
                  border: pw.Border(left: pw.BorderSide(color: _border, width: 0.5)),
                ),
                padding: const pw.EdgeInsets.all(8),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _txt("Company's Bank Details", size: 8, bold: true, color: _navyLight),
                    pw.SizedBox(height: 3),
                    if ((seller?.bankDetails?.bankName ?? '').isNotEmpty) _bankRow('Bank Name', seller?.bankDetails?.bankName ?? ""),
                    if ((seller?.bankDetails?.accountNumber ?? '').isNotEmpty) _bankRow('A/c No.', (seller?.bankDetails?.accountNumber ?? '')),
                    if ((seller?.bankDetails?.ifsc ?? '').isNotEmpty) _bankRow('IFSC Code', (seller?.bankDetails?.ifsc ?? '')),
                    if ((seller?.bankDetails?.branch ?? '').isNotEmpty) _bankRow('Branch', (seller?.bankDetails?.branch ?? '')),
                  ],
                ),
              ),
            ),
          // Signatory
          pw.Expanded(
            flex: 2,
            child: pw.Container(
              decoration: const pw.BoxDecoration(
                border: pw.Border(left: pw.BorderSide(color: _border, width: 0.5)),
              ),
              padding: const pw.EdgeInsets.all(8),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  _txt('for ${seller?.businessName ?? ''}', size: 8, bold: true, align: pw.TextAlign.center),
                  pw.SizedBox(height: 40),
                  _txt('Authorised Signatory', size: 7.5, align: pw.TextAlign.center),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _watermark() => pw.Center(child: _txt('This is a Computer Generated Invoice', size: 7, color: _textMid));

  // ═════════════════════════════════════════════════════════════════════════
  //  HELPERS
  // ═════════════════════════════════════════════════════════════════════════

  static pw.Widget _bordered(pw.Widget child) => pw.Container(
    decoration: pw.BoxDecoration(border: pw.Border.all(color: _border, width: 0.5)),
    child: child,
  );

  static pw.Widget _txt(String text, {double size = 8, bool bold = false, PdfColor color = _textDark, pw.TextAlign align = pw.TextAlign.left}) => pw.Text(
    text,
    textAlign: align,
    style: pw.TextStyle(fontSize: size, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color),
  );

  static pw.Widget _metaCell(String label, String value) => pw.Container(
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _border, width: 0.3)),
    ),
    padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _txt(label, size: 7, bold: true, color: _navyLight),
        _txt(value, size: 8),
      ],
    ),
  );

  static pw.Widget _bankRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: 62, child: _txt('$label :', size: 7.5, bold: true)),
        pw.Expanded(child: _txt(value, size: 7.5)),
      ],
    ),
  );

  static bool _hasBankInfo(BusinessModel seller) => seller != null && ((seller.bankDetails?.bankName ?? '').isNotEmpty || (seller.bankDetails?.accountNumber ?? '').isNotEmpty || (seller.bankDetails?.ifsc ?? '').isNotEmpty);

  // ─── Amount in Words (INR) ────────────────────────────────────────────────

  static const _ones = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
  static const _tens = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];

  static String _toWords(double amount) {
    final rupees = amount.toInt();
    final paise = ((amount - rupees) * 100).round();
    var w = _wordsFor(rupees);
    if (paise > 0) w += ' and ${_wordsFor(paise)} Paise';
    return w;
  }

  static String _wordsFor(int n) {
    if (n == 0) return 'Zero';
    var r = '';
    if (n >= 10000000) {
      r += '${_wordsFor(n ~/ 10000000)} Crore ';
      n %= 10000000;
    }
    if (n >= 100000) {
      r += '${_wordsFor(n ~/ 100000)} Lakh ';
      n %= 100000;
    }
    if (n >= 1000) {
      r += '${_wordsFor(n ~/ 1000)} Thousand ';
      n %= 1000;
    }
    if (n >= 100) {
      r += '${_ones[n ~/ 100]} Hundred ';
      n %= 100;
    }
    if (n >= 20) {
      r += '${_tens[n ~/ 10]} ';
      n %= 10;
    }
    if (n > 0) r += '${_ones[n]} ';
    return r.trim();
  }
}

class InvoicePreviewScreen extends StatelessWidget {
  final InvoiceModel invoice;
  const InvoicePreviewScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Invoice Preview',
      child: PdfPreview(
        build: (format) => InvoicePdfGenerator.generate(invoice),
        allowPrinting: true, // shows print button
        allowSharing: true, // shows share button
        canChangePageFormat: false,
        canChangeOrientation: false,
        initialPageFormat: PdfPageFormat.a4,
      ),
    );
  }
}
