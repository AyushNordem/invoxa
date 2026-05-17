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

    pw.ImageProvider? signatureImage;
    final sigUrl = invoice.sellerDetails?.signatureUrl;
    if (sigUrl != null && sigUrl.isNotEmpty) {
      try {
        signatureImage = await networkImage(sigUrl);
      } catch (e) {
        print('Error loading signature image for PDF: $e');
      }
    }

    pdf.addPage(_page(invoice, 'ORIGINAL FOR RECIPIENT', signatureImage));
    pdf.addPage(_page(invoice, 'DUPLICATE FOR TRANSPORTER', signatureImage));
    return pdf.save();
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  PAGE
  // ═════════════════════════════════════════════════════════════════════════

  static pw.Page _page(InvoiceModel inv, String copyLabel, pw.ImageProvider? signatureImage) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [_header(inv, copyLabel), pw.SizedBox(height: 6), _partyRow(inv), pw.SizedBox(height: 6), _itemsTable(inv), pw.SizedBox(height: 6), _amountWords(inv), pw.SizedBox(height: 6), _footer(inv, signatureImage), pw.Spacer(), _watermark()],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  HEADER
  // ═════════════════════════════════════════════════════════════════════════

  static pw.Widget _header(InvoiceModel inv, String copyLabel) {
    final seller = inv.sellerDetails;

    return pw.Container(
      decoration: pw.BoxDecoration(border: pw.Border.all(color: _border, width: 0.5)),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // ── Top Title bar (Original/Duplicate label) ──
          pw.Container(
            color: _navy,
            padding: const pw.EdgeInsets.symmetric(vertical: 4),
            child: pw.Center(child: _txt('TAX INVOICE - $copyLabel', size: 9, bold: true, color: _white)),
          ),

          // ── Core Header Info ──
          pw.Padding(
            padding: const pw.EdgeInsets.all(10),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Left Column: Seller full corporate details
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _txt(seller?.businessName ?? 'Seller Business Name', size: 14, bold: true, color: _navy),
                      pw.SizedBox(height: 4),

                      // Street Address
                      if ((seller?.address?.street ?? '').isNotEmpty) _txt(seller!.address!.street!, size: 8.5, color: _textMid),

                      // City, State, Pincode
                      if ((seller?.address?.city ?? '').isNotEmpty || (seller?.address?.state ?? '').isNotEmpty)
                        _txt('${seller?.address?.city ?? ""}${seller?.address?.state != null ? ", ${seller?.address?.state}" : ""}${seller?.address?.pincode != null ? " - ${seller?.address?.pincode}" : ""}', size: 8.5, color: _textMid),

                      pw.SizedBox(height: 6),

                      // GSTIN (Bold label, high visibility)
                      pw.Row(
                        children: [
                          _txt('GSTIN/UIN: ', size: 8.5, bold: true, color: _textDark),
                          _txt(seller?.gstNumber ?? 'N/A', size: 8.5, bold: true, color: _navyLight),
                        ],
                      ),

                      pw.SizedBox(height: 4),

                      // Contact info
                      if ((seller?.mobile ?? '').isNotEmpty) _txt('Contact: ${seller!.mobile}', size: 8, color: _textMid),
                      if ((seller?.email ?? '').isNotEmpty) _txt('Email: ${seller!.email}', size: 8, color: _textMid),
                    ],
                  ),
                ),

                pw.SizedBox(width: 20),

                // Right Column: Clean, modern metadata block
                pw.Container(
                  width: 160,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: _stripe,
                    borderRadius: pw.BorderRadius.circular(4),
                    border: pw.Border.all(color: _navy, width: 0.5),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _txt('INVOICE NO.', size: 7.5, bold: true, color: _navy),
                      _txt(inv.invoiceNumber ?? 'INV-XXXXXX', size: 10, bold: true, color: _textDark),
                      pw.SizedBox(height: 8),
                      _txt('DATE OF ISSUE', size: 7.5, bold: true, color: _navy),
                      _txt(inv.date != null ? _date.format(inv.date!) : '-', size: 9, bold: true, color: _textDark),
                    ],
                  ),
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

    // Header labels (without CGST, SGST, IGST, or total row)
    final headers = <String>['Sl No.', 'Description', 'HSN/SAC', 'Qty', 'Unit', 'Rate', 'Disc%', 'Amount'];

    // Column flex widths (Total 8 columns)
    final flexes = <double>[0.6, 3.4, 0.9, 0.7, 0.7, 1.1, 0.7, 1.3];

    pw.Widget cell(String text, {bool header = false, pw.TextAlign align = pw.TextAlign.center, bool stripe = false}) {
      return pw.Container(
        color: header ? _navy : (stripe ? _stripe : _white),
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 5),
        child: _txt(text, size: 7.5, bold: header, color: header ? _white : _textDark, align: align),
      );
    }

    final colWidths = <int, pw.TableColumnWidth>{for (var i = 0; i < flexes.length; i++) i: pw.FlexColumnWidth(flexes[i])};

    final showCGST = inv.hasCGST;
    final showSGST = inv.hasSGST;
    final showIGST = inv.hasIGST;
    final taxPerItem = inv.taxPercentage / (showCGST && showSGST ? 2 : 1);

    // Beautiful styling helper for borderless left and aligned right cells
    pw.Widget calcCell(String text, {bool bold = false, bool isAmount = false, bool isLeftBorder = false, bool isBottomBorder = false}) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4.5),
        decoration: pw.BoxDecoration(
          color: isAmount && isBottomBorder ? _stripe : _white,
          border: pw.Border(
            left: isLeftBorder ? const pw.BorderSide(color: _border, width: 0.4) : pw.BorderSide.none,
            right: const pw.BorderSide(color: _border, width: 0.4),
            bottom: isBottomBorder ? const pw.BorderSide(color: _border, width: 0.4) : pw.BorderSide.none,
          ),
        ),
        child: _txt(text, size: 7.5, bold: bold, color: _textDark, align: isAmount ? pw.TextAlign.right : pw.TextAlign.left),
      );
    }

    return pw.Column(
      children: [
        // Main Product Table
        pw.Table(
          border: pw.TableBorder.all(color: _border, width: 0.4),
          columnWidths: colWidths,
          children: [
            // Header row
            pw.TableRow(children: headers.map((h) => cell(h, header: true)).toList()),
            // Item rows
            ...items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final isStripe = i.isOdd;

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
                ],
              );
            }),
          ],
        ),

        // Calculations Table (Physically attached beneath with zero padding/gap)
        pw.Table(
          columnWidths: colWidths,
          children: [
            // Sub Total Row
            pw.TableRow(children: [pw.Container(), pw.Container(), pw.Container(), pw.Container(), pw.Container(), pw.Container(), calcCell('Sub Total', bold: true, isLeftBorder: true), calcCell('INR ${_money.format(inv.subTotal)}', isAmount: true)]),
            // Discount Row
            if (inv.discountTotal > 0) pw.TableRow(children: [pw.Container(), pw.Container(), pw.Container(), pw.Container(), pw.Container(), pw.Container(), calcCell('Discount', bold: true, isLeftBorder: true), calcCell('- INR ${_money.format(inv.discountTotal)}', isAmount: true)]),
            // CGST Row
            if (showCGST) pw.TableRow(children: [pw.Container(), pw.Container(), pw.Container(), pw.Container(), pw.Container(), pw.Container(), calcCell('CGST (${taxPerItem.toStringAsFixed(1)}%)', bold: true, isLeftBorder: true), calcCell('INR ${_money.format(inv.taxTotal / 2)}', isAmount: true)]),
            // SGST Row
            if (showSGST) pw.TableRow(children: [pw.Container(), pw.Container(), pw.Container(), pw.Container(), pw.Container(), pw.Container(), calcCell('SGST (${taxPerItem.toStringAsFixed(1)}%)', bold: true, isLeftBorder: true), calcCell('INR ${_money.format(inv.taxTotal / 2)}', isAmount: true)]),
            // IGST Row
            if (showIGST)
              pw.TableRow(children: [pw.Container(), pw.Container(), pw.Container(), pw.Container(), pw.Container(), pw.Container(), calcCell('IGST (${inv.taxPercentage.toStringAsFixed(1)}%)', bold: true, isLeftBorder: true), calcCell('INR ${_money.format(inv.taxTotal)}', isAmount: true)]),
            // Grand Total Row
            pw.TableRow(
              children: [pw.Container(), pw.Container(), pw.Container(), pw.Container(), pw.Container(), pw.Container(), calcCell('Grand Total', bold: true, isLeftBorder: true, isBottomBorder: true), calcCell('INR ${_money.format(inv.grandTotal)}', bold: true, isAmount: true, isBottomBorder: true)],
            ),
          ],
        ),
      ],
    );
    // ═════════════════════════════════════════════════════════════════════════
    //  AMOUNT IN WORDS
    // ═════════════════════════════════════════════════════════════════════════
  }

  static pw.Widget _amountWords(InvoiceModel inv) {
    return _bordered(
      pw.Padding(
        padding: const pw.EdgeInsets.all(7),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _txt('Amount Chargeable (in words)', size: 7.5, color: _navyLight),
            pw.SizedBox(height: 2),
            _txt('INR ${toWords(inv.grandTotal)} Only', size: 9, bold: true),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════════════
  //  FOOTER  (declaration + bank + signatory)
  // ═════════════════════════════════════════════════════════════════════════

  static pw.Widget _footer(InvoiceModel inv, pw.ImageProvider? signatureImage) {
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
                  pw.SizedBox(height: 8),
                  if (signatureImage != null) pw.Container(height: 30, width: 80, child: pw.Image(signatureImage, fit: pw.BoxFit.contain)) else pw.SizedBox(height: 30),
                  pw.SizedBox(height: 8),
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

  static String toWords(double amount) {
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
