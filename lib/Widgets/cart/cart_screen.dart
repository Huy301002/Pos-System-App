import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:get/get.dart';
import 'package:pos_apps/data/model/index.dart';
import 'package:pos_apps/enums/index.dart';
import 'package:pos_apps/util/format.dart';
import 'package:pos_apps/view_model/index.dart';
import 'package:pos_apps/widgets/Dialogs/other_dialogs/dialog.dart';
import 'package:pos_apps/widgets/cart/choose_deli_type_dialog.dart';
import 'package:pos_apps/widgets/cart/choose_table_dialog.dart';
import 'package:scoped_model/scoped_model.dart';

import '../../data/model/payment.dart';
import '../../view_model/cart_view_model.dart';
import 'update_cart_item_dialog.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  Widget build(BuildContext context) {
    return ScopedModel<CartViewModel>(
      model: Get.find<CartViewModel>(),
      child: ScopedModelDescendant<CartViewModel>(
          builder: (context, child, model) {
        int selectedTable = Get.find<OrderViewModel>().selectedTable;
        String selectedDeliType = Get.find<OrderViewModel>().deliveryType;
        dynamic selectedDeliLable = showOrderType(selectedDeliType);
        if (model.status == ViewStatus.Loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return Container(
          decoration: BoxDecoration(
            color: Get.theme.colorScheme.onInverseSurface,
            // borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => chooseTableDialog(),
                              icon: Icon(
                                Icons.table_bar,
                                size: 32,
                              ),
                              label: Text(
                                'Bàn: $selectedTable',
                                style: Get.textTheme.bodyLarge,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => chooseDeliTypeDialog(),
                              icon: Icon(
                                selectedDeliLable.icon,
                                size: 32,
                              ),
                              label: Text(
                                ' ${selectedDeliLable.label}',
                                style: Get.textTheme.bodyLarge,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Get.theme.colorScheme.onSurface,
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 7,
                            child: Text(
                              'Tên',
                              style: Get.textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              'SL',
                              style: Get.textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                'Tổng',
                                style: Get.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      color: Get.theme.colorScheme.onSurface,
                      thickness: 1,
                    ),
                  ],
                ),
              ),
              Expanded(
                  flex: 7,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: model.cartList.length,
                    physics: ScrollPhysics(),
                    itemBuilder: (context, i) {
                      return cartItem(model.cartList[i], i);
                    },
                  )),
              Container(
                width: double.infinity,
                height: 140,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                  color: Get.theme.colorScheme.onInverseSurface,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Số lượng', style: Get.textTheme.titleMedium),
                          Text(model.quantity.toString(),
                              style: Get.textTheme.titleMedium),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tổng tiền', style: Get.textTheme.titleMedium),
                          Text(formatPrice(model.totalAmount),
                              style: Get.textTheme.titleLarge),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 1,
                            child: IconButton(
                                onPressed: () async {
                                  var result = await showConfirmDialog(
                                      title: 'Xác nhận',
                                      content:
                                          'Bạn có chắc chắn muốn xóa toàn bộ giỏ hàng không?');
                                  if (result) {
                                    model.clearCartData();
                                  }
                                  Get.back();
                                },
                                icon: Icon(
                                  Icons.delete_outlined,
                                  size: 32,
                                )),
                          ),
                          Expanded(
                            flex: 3,
                            child: FilledButton(
                              onPressed: () async {
                                // var result = await showConfirmDialog(
                                //     title: 'Xác nhận',
                                //     content: 'Xác nhận tạo đơn hàng');
                                // if (result) {
                                //   model.createOrder();
                                // }
                                model.createOrder();
                              },
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
                                child: Text(
                                  'Tạo đơn hàng',
                                  style: Get.textTheme.titleMedium?.copyWith(
                                      color: Get.theme.colorScheme.background),
                                ),
                              ),
                            ),
                          ),
                          // SizedBox(
                          //   width: 4,
                          // ),
                          // Expanded(
                          //   flex: 2,
                          //   child: PopupMenuButton<PaymentModel>(
                          //     initialValue: selectedPayment,
                          //     // icon: Icon(Icons.payment),
                          //     tooltip: 'Thanh toán',
                          //     child: Chip(
                          //       label: Text(
                          //         selectedPayment?.name ?? '',
                          //         style: Get.textTheme.bodyLarge,
                          //       ),
                          //     ),
                          //     itemBuilder: (context) => [
                          //       for (var item in listPayment)
                          //         PopupMenuItem(
                          //           value: item,
                          //           child: item?.id == selectedPayment?.id
                          //               ? Row(children: [
                          //                   Icon(Icons.check),
                          //                   SizedBox(
                          //                     width: 8,
                          //                   ),
                          //                   Text(item?.name ?? ''),
                          //                 ])
                          //               : Text(item?.name ?? ''),
                          //         ),
                          //     ],
                          //     onSelected: (value) {
                          //       Get.find<OrderViewModel>().selectPayment(value);
                          //       selectedPayment = value;
                          //     },
                          //   ),
                          // )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget cartItem(CartItem item, int index) {
    return InkWell(
      onTap: () =>
          {Get.dialog(UpdateCartItemDialog(cartItem: item, idx: index))},
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
        child: Column(
          children: [
            Row(
              textDirection: TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 7,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name!,
                        style: Get.textTheme.bodyLarge,
                        maxLines: 2,
                        overflow: TextOverflow.clip,
                      ),
                      Text(
                        formatPrice(item.product.sellingPrice!),
                        style: Get.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "${item.quantity}",
                        style: Get.textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Text(
                      formatPrice(item.totalAmount),
                      style: Get.textTheme.bodyLarge,
                    ),
                  ),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: item.extras?.length,
              physics: ScrollPhysics(),
              itemBuilder: (context, i) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 0, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: Text(
                          "+${item.extras![i].name!}",
                          style: Get.textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            formatPrice(item.extras![i].sellingPrice!),
                            style: Get.textTheme.bodyMedium,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Row(
                  children: [
                    if (item.attributes != null)
                      for (int i = 0; i < item.attributes!.length; i++)
                        Text("${item.attributes![i].value} ",
                            style: Get.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                    Text(item.note ?? '',
                        style: Get.textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
