import 'package:flutter/material.dart';
import '../pages/food_detail_page.dart';

class FoodItem extends StatelessWidget {
  final String name;
  final String imagePath;

  const FoodItem({super.key, required this.name, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 6,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.orange.withOpacity(0.2),
        highlightColor: Colors.orange.withOpacity(0.1),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FoodDetailPage(name: name),
            ),
          );
        },
        child: Row(
          children: [
            // รูปอาหาร (ซ้าย)
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.asset(
                imagePath,
                width: 120,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),

            // ข้อมูล (ขวา)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'แตะเพื่อดูรายละเอียด',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ลูกศร (ขวาสุด)
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
