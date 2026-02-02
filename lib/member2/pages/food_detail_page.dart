import 'package:flutter/material.dart';
import '../data/food_data.dart';
import '../service/location_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../service/cart_service.dart';

class FoodDetailPage extends StatefulWidget {
  final String name;
  const FoodDetailPage({super.key, required this.name});

  @override
  State<FoodDetailPage> createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  String locationText = "กำลังหาตำแหน่ง...";
  String distanceText = "";
  late VideoPlayerController _controller;

  Color bgColor = const Color(0xFFF7F7F7);

  @override
  void initState() {
    super.initState();
    loadLocation();
    initVideo();
  }

  void initVideo() {
    final food = FoodData.foods[widget.name]!;
    _controller = VideoPlayerController.asset(food["video"])
      ..initialize().then((_) => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> loadLocation() async {
    final food = FoodData.foods[widget.name]!;
    final pos = await LocationService.getCurrentLocation();
    final dist = LocationService.distanceKm(
      pos.latitude,
      pos.longitude,
      food["lat"],
      food["lng"],
    );

    setState(() {
      locationText =
          "${pos.latitude.toStringAsFixed(5)}, ${pos.longitude.toStringAsFixed(5)}";
      distanceText = "${dist.toStringAsFixed(2)} กม.";
    });
  }

  @override
  Widget build(BuildContext context) {
    final food = FoodData.foods[widget.name]!;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(widget.name),
        elevation: 0,
        actions: [
          PopupMenuButton<Color>(
            icon: const Icon(Icons.color_lens),
            onSelected: (c) => setState(() => bgColor = c),
            itemBuilder: (_) => [
              _colorItem("ขาว", Colors.white),
              _colorItem("เทา", const Color(0xFFF2F2F2)),
              _colorItem("ฟ้า", const Color(0xFFE3F2FD)),
              _colorItem("เขียว", const Color(0xFFE8F5E9)),
              _colorItem("ชมพู", const Color(0xFFFCE4EC)),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [

            /// 🎥 VIDEO CARD
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_controller.value.isInitialized)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      ),
                    ),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.black54,
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                    child: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            /// 📍 LOCATION CARD
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.red),
                    const SizedBox(width: 6),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final uri = Uri.parse(
                            "https://www.google.com/maps/dir/?api=1&destination=${food["lat"]},${food["lng"]}",
                          );
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri,
                                mode: LaunchMode.externalApplication);
                          }
                        },
                        child: Text(
                          locationText,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    Text(distanceText),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// 🥬 INGREDIENTS & 🍳 STEPS
            Row(
              children: [
                _infoCard(
                  title: "🥬 วัตถุดิบ",
                  children: food["ingredients"]
                      .map<Widget>((i) => Text("• $i"))
                      .toList(),
                ),
                const SizedBox(width: 10),
                _infoCard(
                  title: "🍳 วิธีทำ",
                  children: food["steps"]
                      .asMap()
                      .entries
                      .map<Widget>(
                          (e) => Text("${e.key + 1}. ${e.value}"))
                      .toList(),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// 🧭 BUTTONS
            _gradientButton(
              text: "นำทางไปยังร้าน",
              icon: Icons.navigation,
              onTap: () async {
                final uri = Uri.parse(
                  "https://www.google.com/maps/dir/?api=1&destination=${food["lat"]},${food["lng"]}",
                );
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri,
                      mode: LaunchMode.externalApplication);
                }
              },
            ),

            const SizedBox(height: 10),

            _gradientButton(
              text: "เพิ่มลงตะกร้า",
              icon: Icons.shopping_cart,
              colors: const [Color.fromARGB(255, 92, 102, 105), Color.fromARGB(255, 100, 109, 116)],
              onTap: () {
                CartService.addItem(widget.name, food["price"]);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("เพิ่มลงตะกร้าแล้ว")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// ===== COMPONENTS =====

  Widget _infoCard({required String title, required List<Widget> children}) {
    return Expanded(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _gradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
    List<Color> colors = const [Color.fromARGB(255, 208, 234, 255), Color.fromARGB(255, 180, 208, 255)],
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(colors: colors),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<Color> _colorItem(String text, Color color) {
    return PopupMenuItem(
      value: color,
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color, radius: 10),
          const SizedBox(width: 8),
          Text(text),
        ],
      ),
    );
  }
}

