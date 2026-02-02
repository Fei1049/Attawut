import 'package:flutter/material.dart';
import '../service/cart_service.dart';
import '../service/sale_service.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final items = CartService.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text("ตะกร้าสินค้า"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.green, // สีปุ่ม
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: items.isEmpty
                  ? null
                  : () async {
                      await SaleService.saveCart(items);
                      CartService.clear();
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    },
              child: const Text(
                "สั่งซื้อ",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),

      body: items.isEmpty
          ? const Center(
              child: Text("ตะกร้าว่าง"),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, i) {
                      final item = items[i];

                      return Container(
                        margin: const EdgeInsets.all(8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.name),
                                  Text("ราคา ${item.price} บาท"),
                                ],
                              ),
                            ),

                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  CartService.decrease(item.name);
                                });
                              },
                            ),

                            Text("${item.qty}"),

                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  CartService.increase(item.name);
                                });
                              },
                            ),

                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                setState(() {
                                  CartService.removeItem(item.name);
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // แสดงยอดรวมอย่างเดียว (ไม่มีปุ่มแล้ว)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    "รวมทั้งหมด: ${CartService.totalPrice} บาท",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
    );
  }
}

