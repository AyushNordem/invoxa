import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';

import '../../../../../../core/utils/app_snackbar.dart';
import '../../../../../../data/models/invoice_model.dart';
import '../add_invoice/invoice_pdf_view.dart';

class InvoicePreviewController extends GetxController {
  final invoice = Rxn<InvoiceModel>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is InvoiceModel) {
      invoice.value = Get.arguments as InvoiceModel;
    }
  }

  Future<void> shareInvoice() async {
    final inv = invoice.value;
    if (inv == null) return;

    try {
      isLoading.value = true;
      final pdfBytes = await InvoicePdfGenerator.generate(inv);
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'invoice_${inv.invoiceNumber ?? "INV"}.pdf',
      );
    } catch (e) {
      AppSnackbar.showError(title: 'Error', message: 'Failed to share PDF: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> downloadInvoice() async {
    final inv = invoice.value;
    if (inv == null) return;

    try {
      isLoading.value = true;
      final pdfBytes = await InvoicePdfGenerator.generate(inv);

      String? targetPath;
      if (Platform.isAndroid) {
        // Standard Android Public Downloads Folder
        targetPath = '/storage/emulated/0/Download/Invoxa';
      } else {
        // iOS sandboxed Documents directory
        final dir = await getApplicationDocumentsDirectory();
        targetPath = '${dir.path}/Invoxa';
      }

      final directory = Directory(targetPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final fileName = 'invoice_${inv.invoiceNumber?.replaceAll('/', '_') ?? "INV"}.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pdfBytes);

      AppSnackbar.showSuccess(
        title: 'Download Successful',
        message: 'Saved as $fileName in Downloads/Invoxa folder!',
      );
    } catch (e) {
      // Resilient fallback: use system print layout dialog if file permissions fail
      try {
        final pdfBytes = await InvoicePdfGenerator.generate(inv);
        await Printing.layoutPdf(
          onLayout: (format) => pdfBytes,
          name: 'invoice_${inv.invoiceNumber?.replaceAll('/', '_') ?? "INV"}',
        );
      } catch (ex) {
        AppSnackbar.showError(title: 'Error', message: 'Failed to download PDF: $ex');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsPaid() async {
    final inv = invoice.value;
    if (inv == null || inv.id == null) return;

    try {
      isLoading.value = true;
      await FirebaseFirestore.instance.collection('invoices').doc(inv.id).update({'status': 'Paid'});
      
      // Update local state
      invoice.value = inv.copyWith(status: 'Paid');
      AppSnackbar.showSuccess(title: 'Success', message: 'Invoice marked as Paid');
    } catch (e) {
      AppSnackbar.showError(title: 'Error', message: 'Failed to update status: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
