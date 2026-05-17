import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:invoxa/app/data/models/invoice_model.dart';
import 'package:invoxa/app/presentation/widgets/base_view.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../../../../data/models/business_model.dart';
import '../../../../../../data/models/customer_model.dart';

class InvoicePdfGenerator {
  // ── Palette — Royal Midnight Navy & Steel ──────────────────────────────────
  static const _primary = PdfColor.fromInt(0xFF1A237E); // Gorgeous Midnight Navy
  static const _primaryDk = PdfColor.fromInt(0xFF0D1B60); // Very Dark Navy (accents)
  static const _primaryLt = PdfColor.fromInt(0xFFF0F4FA); // Soft Light Blue-Grey Background
  static const _accent = PdfColor.fromInt(0xFF283593); // Royal Blue Accent
  static const _border = PdfColor.fromInt(0xFFCFD8DC); // Sleek Border Grey-Blue
  static const _borderGrey = PdfColor.fromInt(0xFFECEFF1); // Very Light Grey Border
  static const _stripe = PdfColor.fromInt(0xFFF8F9FF); // Soft stripe white-blue
  static const _textDark = PdfColor.fromInt(0xFF1A1A2E);
  static const _textMid = PdfColor.fromInt(0xFF455A64);
  static const _textLight = PdfColor.fromInt(0xFF78909C);
  static const _white = PdfColors.white;
  static const _green = PdfColor.fromInt(0xFF2E7D32);
  static const _orange = PdfColor.fromInt(0xFFE65100);
  static const _red = PdfColor.fromInt(0xFFC62828);

  static final _money = NumberFormat('#,##0.00', 'en_IN');
  static final _date = DateFormat('dd-MMM-yyyy');

  // ── Capitalise helper ─────────────────────────────────────────────────────
  static String _cap(String? s) => (s ?? '').toUpperCase();
  // ── Unit shortener ────────────────────────────────────────────────────────
  static const _unitMap = <String, String>{
    // Pieces / Count
    'pieces': 'PCS', 'piece': 'PCS', 'pcs': 'PCS', 'pc': 'PCS',
    'numbers': 'NOS', 'number': 'NOS', 'nos': 'NOS', 'no': 'NOS',
    'units': 'UNT', 'unit': 'UNT',
    'sets': 'SET', 'set': 'SET',
    'pairs': 'PRS', 'pair': 'PRS',
    'dozen': 'DOZ', 'dozens': 'DOZ', 'doz': 'DOZ',
    // Weight
    'kilograms': 'KG', 'kilogram': 'KG', 'kgs': 'KG', 'kg': 'KG',
    'grams': 'GMS', 'gram': 'GMS', 'gms': 'GMS', 'gm': 'GMS', 'g': 'GMS',
    'tonnes': 'MT', 'tonne': 'MT', 'tons': 'MT', 'ton': 'MT', 'mt': 'MT',
    'milligrams': 'MG', 'mg': 'MG',
    'quintal': 'QTL', 'qtl': 'QTL',
    // Volume
    'liters': 'LTR', 'liter': 'LTR', 'litres': 'LTR', 'litre': 'LTR',
    'ltr': 'LTR', 'lt': 'LTR', 'l': 'LTR',
    'milliliters': 'ML', 'ml': 'ML',
    'kiloliters': 'KL', 'kl': 'KL',
    // Length
    'meters': 'MTR', 'meter': 'MTR', 'metres': 'MTR', 'mtr': 'MTR', 'm': 'MTR',
    'centimeters': 'CM', 'cm': 'CM',
    'millimeters': 'MM', 'mm': 'MM',
    'kilometers': 'KM', 'km': 'KM',
    'feet': 'FT', 'foot': 'FT', 'ft': 'FT',
    'inches': 'IN', 'inch': 'IN',
    'yards': 'YD', 'yard': 'YD', 'yd': 'YD',
    // Area
    'sqm': 'SQM', 'sqft': 'SQF',
    // Box / Packing
    'boxes': 'BOX', 'box': 'BOX',
    'cartons': 'CTN', 'carton': 'CTN', 'ctn': 'CTN',
    'packets': 'PKT', 'packet': 'PKT', 'pkt': 'PKT',
    'bags': 'BAG', 'bag': 'BAG',
    'bundles': 'BDL', 'bundle': 'BDL', 'bdl': 'BDL',
    'rolls': 'ROL', 'roll': 'ROL',
    'sheets': 'SHT', 'sheet': 'SHT',
    'bottles': 'BTL', 'bottle': 'BTL', 'btl': 'BTL',
    // Services / Time
    'hours': 'HRS', 'hour': 'HRS', 'hrs': 'HRS', 'hr': 'HRS',
    'days': 'DAY', 'day': 'DAY',
    'months': 'MON', 'month': 'MON',
    'years': 'YRS', 'year': 'YRS',
    'jobs': 'JOB', 'job': 'JOB',
    'lots': 'LOT', 'lot': 'LOT',
    'ls': 'LS',
  };

  static String _shortUnit(String? unit) {
    if (unit == null || unit.trim().isEmpty) return 'PCS';
    final startIndex = unit.indexOf('(');
    final endIndex = unit.indexOf(')');
    var cleanUnit = unit.trim().toLowerCase();
    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      cleanUnit = unit.substring(startIndex + 1, endIndex).trim().toLowerCase();
    }
    return _unitMap[cleanUnit] ?? cleanUnit.toUpperCase();
  }

  static Future<pw.ImageProvider?> _safeNetworkImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        return pw.MemoryImage(response.bodyBytes);
      }
    } catch (_) {}
    return null;
  }

  // ── Public API ────────────────────────────────────────────────────────────
  static Future<Uint8List> generate(InvoiceModel invoice) async {
    final pdf = pw.Document();

    pw.ImageProvider? signatureImage;
    pw.ImageProvider? logoImage;

    final sigUrl = invoice.sellerDetails?.signatureUrl;
    final logoUrl = invoice.sellerDetails?.logoUrl;

    if (sigUrl != null && sigUrl.isNotEmpty) {
      signatureImage = await _safeNetworkImage(sigUrl);
    }
    if (logoUrl != null && logoUrl.isNotEmpty) {
      logoImage = await _safeNetworkImage(logoUrl);
    }

    pdf.addPage(_page(invoice, 'ORIGINAL FOR RECIPIENT', signatureImage, logoImage));
    pdf.addPage(_page(invoice, 'DUPLICATE FOR TRANSPORTER', signatureImage, logoImage));
    return pdf.save();
  }

  // ── Page ──────────────────────────────────────────────────────────────────
  static pw.Page _page(InvoiceModel inv, String copyLabel, pw.ImageProvider? sig, pw.ImageProvider? logo) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.zero,
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // Top accent bar
          pw.Container(height: 5, color: _primary),
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.fromLTRB(28, 16, 28, 12),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _header(inv, copyLabel, logo),
                  pw.SizedBox(height: 10),
                  _divider(),
                  pw.SizedBox(height: 10),
                  _partySection(inv),
                  pw.SizedBox(height: 10),
                  _itemsTable(inv),
                  pw.SizedBox(height: 10),
                  _totalsSection(inv),
                  pw.SizedBox(height: 10),
                  _amountWords(inv),
                  pw.SizedBox(height: 10),
                  _footer(inv, sig),
                  pw.Spacer(),
                  _bottomBar(copyLabel),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  static pw.Widget _header(InvoiceModel inv, String copyLabel, pw.ImageProvider? logo) {
    final s = inv.sellerDetails;

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        // ── Left: Seller Identity ──
        pw.Expanded(
          flex: 6,
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (logo != null) ...[
                pw.Container(
                  width: 48,
                  height: 48,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: _borderGrey, width: 0.5),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.ClipRRect(horizontalRadius: 4, verticalRadius: 4, child: pw.Image(logo, fit: pw.BoxFit.contain)),
                ),
                pw.SizedBox(width: 10),
              ],
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _txt(_cap(s?.businessName ?? 'BUSINESS NAME'), size: 14, bold: true, color: _primary),
                    pw.SizedBox(height: 2),
                    if ((s?.address?.street ?? '').isNotEmpty) _txt(_cap(s!.address!.street!), size: 7.5, color: _textMid),
                    if ((s?.address?.city ?? '').isNotEmpty) _txt(_cap('${s?.address?.city ?? ""}${s?.address?.state != null ? ", ${s?.address?.state}" : ""}${s?.address?.pincode != null ? " - ${s?.address?.pincode}" : ""}'), size: 7.5, color: _textMid),
                    pw.SizedBox(height: 4),
                    pw.Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        if ((s?.gstNumber ?? '').isNotEmpty) _labelValue('GSTIN', _cap(s!.gstNumber!)),
                        if ((s?.mobile ?? '').isNotEmpty) _labelValue('Phone', s!.mobile!),
                        if ((s?.email ?? '').isNotEmpty) _labelValue('Email', s!.email!),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Right: Clean, Key-Value Invoice Info ──
        pw.Expanded(
          flex: 4,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              _txt('TAX INVOICE', size: 14, bold: true, color: _primary),
              pw.SizedBox(height: 4),
              _txt('INVOICE NO: ${inv.invoiceNumber ?? "-"}', size: 8, bold: true, color: _textDark),
              pw.SizedBox(height: 2),
              _txt('DATE: ${inv.date != null ? _date.format(inv.date!) : "-"}', size: 8, bold: true, color: _textDark),
              pw.SizedBox(height: 4),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: _primaryLt,
                  borderRadius: pw.BorderRadius.circular(2),
                ),
                child: _txt(copyLabel.toUpperCase(), size: 6, bold: true, color: _primary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Party Section ─────────────────────────────────────────────────────────
  static pw.Widget _partySection(InvoiceModel inv) {
    final buyer = inv.buyerDetails ?? CustomerModel();
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(child: _partyCard('BILL TO', buyer)),
        pw.SizedBox(width: 8),
        pw.Expanded(child: _partyCard('SHIP TO', buyer)),
      ],
    );
  }

  static pw.Widget _partyCard(String title, CustomerModel p) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _borderGrey, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const pw.BoxDecoration(color: _primaryLt),
            child: pw.Row(
              children: [
                pw.Container(width: 2, height: 9, color: _primary),
                pw.SizedBox(width: 5),
                _txt(title, size: 7.5, bold: true, color: _primaryDk),
              ],
            ),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _txt(_cap(p.name ?? '-'), size: 9.5, bold: true, color: _textDark),
                pw.SizedBox(height: 3),
                if ((p.address?.street ?? '').isNotEmpty) _txt(_cap(p.address!.street!), size: 8, color: _textMid),
                if ((p.address?.city ?? '').isNotEmpty) _txt(_cap('${p.address?.city ?? ""}${p.address?.state != null ? ", ${p.address?.state}" : ""}${p.address?.zipCode != null ? " - ${p.address?.zipCode}" : ""}'), size: 8, color: _textMid),
                if ((p.gstNumber ?? '').isNotEmpty) ...[pw.SizedBox(height: 3), _labelValue('GSTIN', _cap(p.gstNumber!))],
                if ((p.mobile ?? '').isNotEmpty) ...[pw.SizedBox(height: 2), _labelValue('Ph', p.mobile!)],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Items Table ───────────────────────────────────────────────────────────
  static pw.Widget _itemsTable(InvoiceModel inv) {
    final items = inv.items ?? [];
    final headers = ['#', 'ITEM & DESCRIPTION', 'HSN/SAC', 'QTY', 'UNIT', 'RATE (₹)', 'DISC%', 'AMOUNT (₹)'];
    final flexes = <double>[0.5, 3.2, 1.0, 0.7, 0.7, 1.2, 0.7, 1.4];

    final colWidths = <int, pw.TableColumnWidth>{for (var i = 0; i < flexes.length; i++) i: pw.FlexColumnWidth(flexes[i])};

    pw.Widget hCell(String t) => pw.Container(
      color: _primary,
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      child: _txt(t, size: 7, bold: true, color: _white, align: pw.TextAlign.center),
    );

    pw.Widget dCell(String t, {pw.TextAlign align = pw.TextAlign.center, bool stripe = false, bool bold = false, PdfColor? color}) => pw.Container(
      color: stripe ? _stripe : _white,
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 6),
      child: _txt(t, size: 8, bold: bold, color: color ?? _textDark, align: align),
    );

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _borderGrey, width: 0.6),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.ClipRRect(
        horizontalRadius: 4,
        verticalRadius: 4,
        child: pw.Table(
          border: pw.TableBorder(
            horizontalInside: pw.BorderSide(color: _borderGrey, width: 0.4),
            verticalInside: pw.BorderSide(color: _borderGrey, width: 0.4),
          ),
          columnWidths: colWidths,
          children: [
            pw.TableRow(children: headers.map(hCell).toList()),
            ...items.asMap().entries.map((e) {
              final i = e.key;
              final item = e.value;
              final s = i.isOdd;
              // Name and description always capitalised
              final name = _cap(item.name ?? '');
              final desc = _cap(item.description ?? '');
              final combined = [name, desc].where((x) => x.isNotEmpty).join('\n');

              return pw.TableRow(
                children: [
                  dCell('${i + 1}', stripe: s, color: _textMid),
                  dCell(combined, align: pw.TextAlign.left, stripe: s, bold: name.isNotEmpty),
                  dCell(_cap(item.hsnCode ?? ''), stripe: s),
                  dCell(item.quantity.toStringAsFixed(2), stripe: s),
                  dCell(_shortUnit(item.unit), stripe: s),
                  dCell(_money.format(item.rate), stripe: s),
                  dCell(item.discount > 0 ? '${item.discount}%' : '-', stripe: s),
                  dCell(_money.format(item.amount), stripe: s, bold: true, color: _primaryDk),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Totals Section ────────────────────────────────────────────────────────
  static pw.Widget _totalsSection(InvoiceModel inv) {
    final showCGST = inv.hasCGST;
    final showSGST = inv.hasSGST;
    final showIGST = inv.hasIGST;
    final taxPer = inv.taxPercentage / (showCGST && showSGST ? 2 : 1);
    final half = inv.taxTotal / (showCGST && showSGST ? 2 : 1);

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(flex: 5, child: pw.SizedBox()),
        pw.SizedBox(width: 8),
        pw.Expanded(
          flex: 4,
          child: pw.Container(
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: _borderGrey, width: 0.6),
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.ClipRRect(
              horizontalRadius: 4,
              verticalRadius: 4,
              child: pw.Column(
                children: [
                  // Header
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    color: _primaryLt,
                    child: pw.Row(
                      children: [
                        pw.Container(width: 2, height: 9, color: _primary),
                        pw.SizedBox(width: 4),
                        _txt('INVOICE SUMMARY', size: 7.5, bold: true, color: _primaryDk),
                      ],
                    ),
                  ),
                  _totRow('Sub Total', 'INR ${_money.format(inv.subTotal)}'),
                  if (inv.discountTotal > 0) _totRow('Discount', '- INR ${_money.format(inv.discountTotal)}', valueColor: _red),
                  if (showCGST) _totRow('CGST (${taxPer.toStringAsFixed(1)}%)', 'INR ${_money.format(half)}'),
                  if (showSGST) _totRow('SGST (${taxPer.toStringAsFixed(1)}%)', 'INR ${_money.format(half)}'),
                  if (showIGST) _totRow('IGST (${inv.taxPercentage.toStringAsFixed(1)}%)', 'INR ${_money.format(inv.taxTotal)}'),
                  // Grand total — light blue bg, dark text (not dark navy)
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    color: _primary,
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        _txt('GRAND TOTAL', size: 9, bold: true, color: _white),
                        _txt('INR ${_money.format(inv.grandTotal)}', size: 10, bold: true, color: _white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Amount in Words ───────────────────────────────────────────────────────
  static pw.Widget _amountWords(InvoiceModel inv) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: pw.BoxDecoration(
        color: _primaryLt,
        border: pw.Border.all(color: _border, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        children: [
          pw.Container(width: 3, height: 18, color: _primary),
          pw.SizedBox(width: 8),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _txt('AMOUNT IN WORDS', size: 6.5, bold: true, color: _textLight),
              pw.SizedBox(height: 2),
              _txt('INR ${toWords(inv.grandTotal)} Only', size: 8.5, bold: true, color: _primaryDk),
            ],
          ),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────
  static pw.Widget _footer(InvoiceModel inv, pw.ImageProvider? sig) {
    final seller = inv.sellerDetails;

    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _borderGrey, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Declaration
          pw.Expanded(
            flex: 4,
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _sectionLabel('DECLARATION'),
                  pw.SizedBox(height: 5),
                  _txt(
                    'We declare that this invoice shows the actual price of the goods '
                    'described and that all particulars are true and correct.',
                    size: 7.5,
                    color: _textMid,
                  ),
                  pw.SizedBox(height: 4),
                  _txt('E. & O.E', size: 7.5, bold: true, color: _textDark),
                  if ((inv.notes ?? '').isNotEmpty) ...[pw.SizedBox(height: 6), _sectionLabel('NOTES'), pw.SizedBox(height: 2), _txt(inv.notes!, size: 7.5, color: _textMid)],
                ],
              ),
            ),
          ),
          pw.Container(width: 0.5, color: _borderGrey),
          // Bank Details
          if (_hasBankInfo(seller ?? BusinessModel()))
            pw.Expanded(
              flex: 4,
              child: pw.Padding(
                padding: const pw.EdgeInsets.all(10),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('BANK DETAILS'),
                    pw.SizedBox(height: 6),
                    if ((seller?.bankDetails?.bankName ?? '').isNotEmpty) _bankRow('Bank', _cap(seller!.bankDetails!.bankName!)),
                    if ((seller?.bankDetails?.accountNumber ?? '').isNotEmpty) _bankRow('A/c No.', seller!.bankDetails!.accountNumber!),
                    if ((seller?.bankDetails?.ifsc ?? '').isNotEmpty) _bankRow('IFSC', _cap(seller!.bankDetails!.ifsc!)),
                    if ((seller?.bankDetails?.branch ?? '').isNotEmpty) _bankRow('Branch', _cap(seller!.bankDetails!.branch!)),
                  ],
                ),
              ),
            ),
          pw.Container(width: 0.5, color: _borderGrey),
          // Signatory
          pw.Expanded(
            flex: 3,
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  _sectionLabel('FOR ${_cap(seller?.businessName ?? "")}'),
                  pw.SizedBox(height: 6),
                  pw.Container(
                    height: 36,
                    width: 90,
                    decoration: pw.BoxDecoration(
                      border: pw.Border(bottom: pw.BorderSide(color: _borderGrey, width: 0.6)),
                    ),
                    child: sig != null ? pw.Image(sig, fit: pw.BoxFit.contain) : pw.SizedBox(),
                  ),
                  pw.SizedBox(height: 4),
                  _txt('AUTHORISED SIGNATORY', size: 6.5, color: _textLight, align: pw.TextAlign.center),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────
  static pw.Widget _bottomBar(String copyLabel) => pw.Column(
    children: [
      pw.Divider(color: _borderGrey, height: 1),
      pw.SizedBox(height: 4),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _txt('This is a Computer Generated Invoice', size: 6.5, color: _textLight),
          _txt(copyLabel, size: 6.5, bold: true, color: _primary),
        ],
      ),
      pw.SizedBox(height: 4),
      pw.Container(height: 4, color: _primary),
    ],
  );

  // ── Helpers ───────────────────────────────────────────────────────────────

  static pw.Widget _divider() => pw.Container(height: 0.5, color: _borderGrey);

  static pw.Widget _labelValue(String label, String value) => pw.Row(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      _txt('$label: ', size: 7.5, bold: true, color: _textMid),
      _txt(value, size: 7.5, color: _textDark),
    ],
  );

  static pw.Widget _metaBlock(String label, String value) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      _txt(label, size: 6.5, bold: true, color: _primary),
      pw.SizedBox(height: 1),
      _txt(value, size: 9, bold: true, color: _textDark),
    ],
  );

  static pw.Widget _statusBadge(String status) {
    final PdfColor bg;
    final PdfColor fg;
    if (status == 'Paid') {
      bg = const PdfColor.fromInt(0xFFE8F5E9);
      fg = _green;
    } else if (status == 'Pending') {
      bg = const PdfColor.fromInt(0xFFFFF3E0);
      fg = _orange;
    } else {
      bg = const PdfColor.fromInt(0xFFF5F5F5);
      fg = _textLight;
    }
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: pw.BoxDecoration(
        color: bg,
        border: pw.Border.all(color: fg, width: 0.5),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: _txt(_cap(status), size: 7.5, bold: true, color: fg),
    );
  }

  // totalRow: partial border only — NO borderRadius
  static pw.Widget _totRow(String label, String value, {PdfColor valueColor = _textDark}) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: _borderGrey, width: 0.4)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _txt(label, size: 8, color: _textMid),
        _txt(value, size: 8, bold: true, color: valueColor),
      ],
    ),
  );

  static pw.Widget _sectionLabel(String text) => pw.Row(
    children: [
      pw.Container(width: 2, height: 9, color: _primary),
      pw.SizedBox(width: 4),
      _txt(text, size: 7, bold: true, color: _primaryDk),
    ],
  );

  static pw.Widget _txt(String text, {double size = 8, bool bold = false, PdfColor color = _textDark, pw.TextAlign align = pw.TextAlign.left}) => pw.Text(
    text,
    textAlign: align,
    style: pw.TextStyle(fontSize: size, fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal, color: color),
  );

  static pw.Widget _bankRow(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: 48, child: _txt('$label :', size: 7.5, bold: true, color: _textMid)),
        pw.Expanded(child: _txt(value, size: 7.5, bold: true, color: _textDark)),
      ],
    ),
  );

  static bool _hasBankInfo(BusinessModel seller) => (seller.bankDetails?.bankName ?? '').isNotEmpty || (seller.bankDetails?.accountNumber ?? '').isNotEmpty || (seller.bankDetails?.ifsc ?? '').isNotEmpty;

  // ── Amount in Words ───────────────────────────────────────────────────────
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

// ── Preview Screen ────────────────────────────────────────────────────────────
class InvoicePreviewScreen extends StatelessWidget {
  final InvoiceModel invoice;
  const InvoicePreviewScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      title: 'Invoice Preview',
      child: PdfPreview(build: (format) => InvoicePdfGenerator.generate(invoice), allowPrinting: true, allowSharing: true, canChangePageFormat: false, canChangeOrientation: false, initialPageFormat: PdfPageFormat.a4),
    );
  }
}
