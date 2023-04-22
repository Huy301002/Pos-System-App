import 'package:get/get.dart';

import 'view_model/index.dart';

import 'view_model/printer_view_model.dart';

void createRouteBindings() async {
  Get.put(ThemeViewModel());
  Get.put(StartUpViewModel());
  Get.put(RootViewModel());
  Get.put(LoginViewModel());
  Get.put(MenuViewModel());
  Get.put(CartViewModel());
  Get.put(OrderViewModel());
  Get.put(PrinterViewModel());
}
