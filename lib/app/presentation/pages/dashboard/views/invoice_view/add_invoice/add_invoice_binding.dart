import 'package:get/get.dart';
import 'add_invoice_controller.dart';

class AddInvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddInvoiceController>(() => AddInvoiceController());
  }
}
