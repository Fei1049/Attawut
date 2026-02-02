import 'package:flutter/material.dart';
import 'food_detail_page.dart';
import 'cart_page.dart';

class FoodListPage extends StatefulWidget {
  const FoodListPage({super.key});

  @override
  State<FoodListPage> createState() => _FoodListPageState();
}

class _FoodListPageState extends State<FoodListPage> {
  Color bgColor = const Color(0xFFFDF6FA);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColor,
        title: const Text(
          "รายการอาหาร",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // ปุ่มเปลี่ยนสีพื้นหลัง
          PopupMenuButton<Color>(
            icon: const Icon(Icons.color_lens),
            onSelected: (color) {
              setState(() {
                bgColor = color;
              });
            },
            itemBuilder: (context) => [
              _colorItem("ชมพูอ่อน", const Color(0xFFFDF6FA)),
              _colorItem("ขาว", Colors.white),
              _colorItem("เทาอ่อน", const Color(0xFFF2F2F2)),
              _colorItem("ฟ้าอ่อน", const Color(0xFFE3F2FD)),
              _colorItem("เขียวอ่อน", const Color(0xFFE8F5E9)),
            ],
          ),

          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          foodTile("ข้าวผัด", "assets/images/rich.jpg"),
          foodTile("กระเพราะหมูสับ", "assets/images/kaprom.jpg"),
          foodTile("ต้มยำกุ้ง", "assets/images/tomyumm.jpg"),
          foodTile("ราเมง", "assets/images/ramen.jpg"),
          foodTile("ขนมปัง", "assets/images/bread.jpg"),
          foodTile("บิงซู", "assets/images/bingsu.jpg"),
          foodTile("ไอศกรีม", "assets/images/ice.jpg"),
        ],
      ),
    );
  }

  PopupMenuItem<Color> _colorItem(String name, Color color) {
    return PopupMenuItem(
      value: color,
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color, radius: 10),
          const SizedBox(width: 10),
          Text(name),
        ],
      ),
    );
  }

  Widget foodTile(String name, String imagePath) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FoodDetailPage(name: name),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF5EFF7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}

