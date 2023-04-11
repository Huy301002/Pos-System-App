import 'dart:core';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_apps/Widgets/Dialogs/other_dialogs/dialog.dart';
import 'package:pos_apps/Widgets/Dialogs/payment_dialogs/payment_dialog.dart';
import 'package:pos_apps/data/model/response/order_in_list.dart';
import 'package:pos_apps/data/model/response/order_response.dart';
import 'package:pos_apps/enums/index.dart';
import 'package:pos_apps/enums/order_enum.dart';
import 'package:pos_apps/routes/route_helper.dart';
import 'package:pos_apps/util/share_pref.dart';
import 'package:pos_apps/view_model/cart_view_model.dart';
import 'package:pos_apps/view_model/index.dart';
import 'package:pos_apps/view_model/login_view_model.dart';
import 'package:pos_apps/view_model/printer_view_model.dart';
import 'package:pos_apps/widgets/cart/choose_table_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Widgets/Dialogs/printer_dialogs/add_printer_dialog.dart';
import '../data/api/order_api.dart';
import '../data/api/payment_data.dart';
import '../data/model/index.dart';
import '../data/model/payment.dart';
import '../routes/routes_constrants.dart';

class OrderViewModel extends BaseViewModel {
  int selectedTable = 01;
  String deliveryType = DeliType().eatIn.type;
  Cart? currentCart;
  late OrderAPI api = OrderAPI();
  String? currentOrderId;
  OrderResponseModel? currentOrder;
  List<PaymentModel?> listPayment = [];
  PaymentModel? selectedPaymentMethod;
  PaymentData? paymentData;
  List<OrderInList> listOrder = [];

  OrderViewModel() {
    api = OrderAPI();
    paymentData = PaymentData();
  }

  void getListPayment() async {
    setState(ViewStatus.Loading);
    await paymentData!.getListPayment().then((value) {
      listPayment = value;
    });
    setState(ViewStatus.Completed);
  }

  void selectPayment(PaymentModel payment) {
    selectedPaymentMethod = payment;
    notifyListeners();
  }

  void chooseDeliveryType(String type) {
    deliveryType = type;
    hideDialog();

    notifyListeners();
  }

  void chooseTable(int table) {
    selectedTable = table;
    hideDialog();
    notifyListeners();
  }

  void placeOrder(OrderModel order) async {
    try {
      setState(ViewStatus.Loading);
      Account? userInfo = await getUserInfo();
      order.paymentId = listPayment[0]!.id;
      var res = api.placeOrder(order, userInfo!.storeId);
      res.then((value) =>
          {print(value.toString()), showPaymentBotomSheet(value.toString())});
      setState(ViewStatus.Completed);
    } catch (e) {
      setState(ViewStatus.Error, e.toString());
    }
  }

  void makePayment() async {
    try {
      setState(ViewStatus.Loading);
      Account? userInfo = await getUserInfo();
      if (currentOrder == null) {
        showAlertDialog(
            title: "Lỗi đơn hàng", content: "Không tìm thấy đơn hàng");
        setState(ViewStatus.Completed);
        return;
      }
      String url = await api.makePayment(currentOrder!);
      print(url);
      launchInBrowser(url);
      setState(ViewStatus.Completed);
    } catch (e) {
      setState(ViewStatus.Error, e.toString());
    }
  }

  void getListOrder(
      {bool isToday = true,
      bool isYesterday = false,
      int page = 1,
      String? orderStatus,
      String? orderType}) async {
    try {
      setState(ViewStatus.Loading);
      Account? userInfo = await getUserInfo();
      listOrder = await api.getListOrderOfStore(userInfo!.storeId,
          isToday: isToday,
          isYesterday: isYesterday,
          page: page,
          orderStatus: orderStatus,
          orderType: orderType);
      setState(ViewStatus.Completed);
    } catch (e) {
      setState(ViewStatus.Error, e.toString());
    }
  }

  void getOrderByStore(String orderId) async {
    try {
      setState(ViewStatus.Loading);
      Account? userInfo = await getUserInfo();
      // OrderResponseModel orderRes =
      //     await api.getOrderOfStore(userInfo!.storeId, orderId);
      api.getOrderOfStore(userInfo!.storeId, orderId).then(
          (value) => {currentOrder = value, setState(ViewStatus.Completed)});
    } catch (e) {
      showAlertDialog(title: "Lỗi đơn hàng", content: e.toString());
      setState(ViewStatus.Error);
    }
  }

  Future<void> completeOrder(
    String orderId,
  ) async {
    try {
      Account? userInfo = await getUserInfo();
      setState(ViewStatus.Loading);
      if (selectedPaymentMethod == null) {
        showAlertDialog(
            title: "Lỗi thanh toán",
            content: "Vui lòng chọn phương thức thanh toán");
        setState(ViewStatus.Completed);
        return;
      }
      if (Get.find<PrinterViewModel>().selectedBillPrinter != null) {
        api.updateOrder(userInfo!.storeId, orderId, OrderStatusEnum.PAID,
            selectedPaymentMethod!.id);
        Get.find<PrinterViewModel>().printBill(currentOrder!, selectedTable,
            selectedPaymentMethod!.name ?? "Tiền mặt");
        clearOrder();
        setState(ViewStatus.Completed);
        showAlertDialog(
            title: "Hoàn thành đơn hàng",
            content: "Hoàn thành đơn hàng thành công");
      } else {
        bool result = await showConfirmDialog(
          title: "Lỗi in hóa đơn",
          content: "Vui lòng chọn máy in hóa đơn",
          confirmText: "Tiếp tục hoàn thành đơn hàng",
          cancelText: "Chọn máy in",
        );
        if (!result) {
          showPrinterConfigDialog(PrinterTypeEnum.bill);
          setState(ViewStatus.Completed);
          return;
        } else {
          api.updateOrder(userInfo!.storeId, orderId, OrderStatusEnum.PAID,
              selectedPaymentMethod!.id);
          setState(ViewStatus.Completed);
          showAlertDialog(
              title: "Hoàn thành đơn hàng",
              content: "Hoàn thành đơn hàng thành công");
          clearOrder();
        }
      }
    } catch (e) {
      showAlertDialog(title: "Lỗi hoàn thành đơn hàng", content: e.toString());
      setState(ViewStatus.Error);
    }
  }

  Future<void> cancleOrder(
    String orderId,
    String payment,
  ) async {
    try {
      Account? userInfo = await getUserInfo();
      setState(ViewStatus.Loading);
      api.updateOrder(userInfo!.storeId, orderId, OrderStatusEnum.CANCELED,
          currentOrder?.payment!.id!);
      clearOrder();
      showAlertDialog(
          title: "Huỷ đơn hàng", content: "Huỷ đơn hàng thành công");
      setState(ViewStatus.Completed);
    } catch (e) {
      showAlertDialog(title: "Lỗi huỷ đơn hàng", content: e.toString());
      setState(ViewStatus.Error);
    }
  }

  void clearOrder() {
    hideBottomSheet();
    currentOrderId = null;
    currentOrder = null;
    selectedPaymentMethod = null;
    getListOrder();
  }

  Future<void> launchInWebViewOrVC() async {
    Uri url = Uri.parse('https://www.google.com/');
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
      webViewConfiguration: const WebViewConfiguration(
          headers: <String, String>{'my_header_key': 'my_header_value'}),
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> launchInBrowser(String value) async {
    Uri url = Uri.parse(value);
    if (!await launchUrl(
      url,
      mode: LaunchMode.inAppWebView,
    )) {
      throw Exception('Could not launch $url');
    }
  }
}
