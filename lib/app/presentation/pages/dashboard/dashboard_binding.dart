import 'package:get/get.dart';
import 'dashboard_controller.dart';
import 'views/home_view/home_controller.dart';
import 'views/invoice_view/invoice_controller.dart';
import 'views/customer_view/customer_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<InvoiceController>(() => InvoiceController());
    Get.lazyPut<CustomerController>(() => CustomerController());
  }
}
