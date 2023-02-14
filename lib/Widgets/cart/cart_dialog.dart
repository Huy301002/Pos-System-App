import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos_apps/widgets/cart/cart_screen.dart';

void showCartDialog() {
  Get.dialog(Dialog.fullscreen(
    // shape: RoundedRectangleBorder(
    //   borderRadius: BorderRadius.circular(16),
    // ),
    // elevation: 0,
    backgroundColor: Colors.transparent,
    child: Container(
      width: Get.size.width,
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.onInverseSurface,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8), topRight: Radius.circular(8)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.shopping_cart),
              ),
              Expanded(
                  child: Center(
                      child:
                          Text("Giỏ hàng", style: Get.textTheme.titleLarge))),
              IconButton(
                  iconSize: 24,
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close))
            ],
          ),
          Expanded(child: CartScreen()),
        ],
      ),
    ),
  ));
}
