import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ตัวแปรสำหรับเก็บรายการในตะกร้า
List<Map<String, dynamic>> userCart = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    // ทำการล็อกอินทันทีที่เปิดแอป
    await FirebaseAuth.instance.signInAnonymously();
    print("Firebase & Auth Initialized");
  } catch (e) {
    print("Error initializing Firebase: $e");
  }
  runApp(MyFoodApp());
}

class MyFoodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FoodHomePage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}

class FoodHomePage extends StatelessWidget {
  final List<Map<String, dynamic>> foods = [
    {
      "name": "ข้าวผัด",
      "price": 50,
      "image":
          "https://img.wongnai.com/p/1920x0/2019/12/19/d5537700a7274ac09964b6a51dd0a9f6.jpg",
      "ingredients": "ข้าวสวย, ไข่ไก่, กระเทียม, ต้นหอม, ซอสปรุงรส",
      "instructions":
          "1. เจียวกระเทียมให้หอม\n2. ใส่ไข่ลงไปผัด\n3. ใส่ข้าวสวยและปรุงรส\n4. โรยต้นหอมพร้อมเสิร์ฟ",
      "video": "assets/videos/fried_rice.mp4",
      "shopLocation": "18.28446594395072, 99.51069966427286",
    },
    {
      "name": "ผัดไทย",
      "price": 60,
      "image":
          "https://img.wongnai.com/p/1920x0/2021/08/09/f5ff71c37a2c4101b895432aae1ac01a.jpg",
      "ingredients":
          "เส้นเล็ก, เต้าหู้, กุ้งแห้ง, ถั่วงอก, ใบกุยช่าย, ซอสผัดไทย",
      "instructions":
          "1. ผัดเต้าหู้และกุ้งแห้ง\n2. ใส่เส้นและน้ำซอส\n3. ใส่ถั่วงอกและใบกุยช่าย",
      "video": "assets/videos/pad_thai.mp4",
      "shopLocation": "18.295466733944526, 99.4915431243531",
    },
    {
      "name": "ส้มตำ",
      "price": 40,
      "image":
          "https://www.unileverfoodsolutions.co.th/th/chef-inspiration/simple-tips-for-great-flavour/somtum-green-papaya-salad-recipes/jcr:content/parsys/content-aside-footer/tipsandadvice_953595_984236123/image.img.jpg/1695118740332.jpg",
      "ingredients":
          "มะละกอ, พริก, กระเทียม, มะเขือเทศ, ถั่วฝักยาว, น้ำปลา, มะนาว",
      "instructions":
          "1. ตำพริกและกระเทียม\n2. ปรุงรสด้วยน้ำปลา มะนาว\n3. ใส่มะละกอและคลุกเคล้า",
      "video": "assets/videos/som_tum.mp4",
      "shopLocation": "18.295267472242646, 99.49069289304421",
    },
    {
      "name": "ราเมน",
      "price": 85,
      "image":
          "https://res.cloudinary.com/jnto/image/upload/w_600,fl_lossy,f_auto,q_auto,c_scale/v1/media/filer_public/e0/3c/e03c7f75-06a7-45ed-920b-dc5d7ad6eb60/mar22_ramen_12_e4tdxz",
      "ingredients": "เส้นราเมน, น้ำซุป, หมูชาบู, ไข่ต้ม, สาหร่าย",
      "instructions":
          "1. ลวกเส้นราเมน\n2. เตรียมน้ำซุป\n3. จัดวางเครื่องเคียงและเสิร์ฟ",
      "video": "assets/videos/ramen.mp4",
      "shopLocation": "18.27680, 99.48970",
    },
  ];

  final List<Map<String, dynamic>> snacks = [
    {
      "name": "เค้ก",
      "price": 45,
      "image":
          "https://upload.wikimedia.org/wikipedia/commons/d/d6/Laika_strawberry_cake_%28cropped%29.jpg",
      "ingredients": "แป้งเค้ก, ไข่ไก่, น้ำตาล, เนย, นม",
      "instructions":
          "1. ตีส่วนผสมให้เข้ากัน\n2. อบในเตาอบ\n3. แต่งหน้าเค้กตามชอบ",
      "video": "assets/videos/cake.mp4",
      "shopLocation": "18.27850, 99.48600",
    },
    {
      "name": "ขนมปัง",
      "price": 25,
      "image":
          "https://www.sgethai.com/wp-content/uploads/2021/08/5-%E0%B8%AA%E0%B8%B9%E0%B8%95%E0%B8%A3-%E0%B9%80%E0%B8%A1%E0%B8%99%E0%B8%B9-%E0%B8%82%E0%B8%99%E0%B8%A1%E0%B8%9B%E0%B8%B1%E0%B8%87-%E0%B8%87%E0%B9%88%E0%B8%B2%E0%B8%A2%E0%B9%862021-1.webp",
      "ingredients": "แป้งขนมปัง, ยีสต์, น้ำตาล, เกลือ, น้ำ",
      "instructions":
          "1. นวดแป้งให้เนียน\n2. พักแป้งให้ขึ้นฟู\n3. อบให้สุกเหลือง",
      "video": "assets/videos/bread.mp4",
      "shopLocation": "18.28050, 99.50500",
    },
    {
      "name": "นักเก็ต",
      "price": 59,
      "image":
          "https://recipe.sgethai.com/wp-content/uploads/2025/05/cover-nugget_result.webp",
      "ingredients": "เนื้อไก่ bnd, แป้งทอดกรอบ, เกลือ, พริกไทย",
      "instructions":
          "1. ปรุงรสเนื้อไก่\n2. ปั้นเป็นก้อนและชุบแป้ง\n3. ทอดในน้ำมันร้อน",
      "video": "assets/videos/nugget.mp4",
      "shopLocation": "18.27680, 99.48970",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("แนะนำอาหารและของว่าง"),
          bottom: TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: "อาหารคาว", icon: Icon(Icons.restaurant)),
              Tab(text: "ของว่าง", icon: Icon(Icons.cake)),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CartPage()));
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.all(12),
                    child: _buildGrid(foods, context, 2, 0.85))),
            SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.all(12),
                    child: _buildGrid(snacks, context, 3, 0.75))),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<Map<String, dynamic>> items, BuildContext context,
      int crossAxisCount, double aspectRatio) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: items.length,
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
      ),
      itemBuilder: (context, index) => buildCard(context, items[index]),
    );
  }

  Widget buildCard(BuildContext context, Map<String, dynamic> item) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.all(6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => FoodDetailPage(item: item))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(item["image"], fit: BoxFit.cover),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${item["price"]} ฿",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item["name"],
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 14, color: Colors.amber),
                      SizedBox(width: 4),
                      Text("แนะนำ",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Spacer(),
                      Icon(Icons.add_circle, color: Colors.deepOrange),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodDetailPage extends StatefulWidget {
  final Map<String, dynamic> item;
  const FoodDetailPage({Key? key, required this.item}) : super(key: key);

  @override
  _FoodDetailPageState createState() => _FoodDetailPageState();
}

class _FoodDetailPageState extends State<FoodDetailPage> {
  String _currentPosition = "กำลังค้นหา...";
  String _distance = "";
  LatLng? _shopLocation;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _parseShopLocation();
    _getCurrentLocation();
  }

  void _parseShopLocation() {
    String? shopLocation = widget.item["shopLocation"];
    if (shopLocation == null) return;
    final RegExp regex = RegExp(r"([0-9]+\.[0-9]+),\s*([0-9]+\.[0-9]+)");
    final match = regex.firstMatch(shopLocation);
    if (match != null) {
      _shopLocation =
          LatLng(double.parse(match.group(1)!), double.parse(match.group(2)!));
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) setState(() => _currentPosition = "ปิดใช้งาน GPS");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) setState(() => _currentPosition = "สิทธิ์ถูกปฏิเสธ");
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _currentPosition =
              "${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}";
        });
        _calculateDistance(position);
      }
    } catch (e) {
      if (mounted) setState(() => _currentPosition = "ระบุตำแหน่งไม่ได้");
    }
  }

  void _calculateDistance(Position userPosition) {
    String? shopLocation = widget.item["shopLocation"];
    if (shopLocation == null) return;
    final RegExp regex = RegExp(r"([0-9]+\.[0-9]+),\s*([0-9]+\.[0-9]+)");
    final match = regex.firstMatch(shopLocation);
    if (match != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        userPosition.latitude,
        userPosition.longitude,
        double.parse(match.group(1)!),
        double.parse(match.group(2)!),
      );
      if (mounted) {
        setState(() => _distance =
            "ห่างจากคุณ: ${(distanceInMeters / 1000).toStringAsFixed(2)} กม.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          int index = userCart
              .indexWhere((element) => element['name'] == widget.item['name']);
          setState(() {
            if (index != -1) {
              userCart[index]['amount']++;
            } else {
              userCart.add({...widget.item, 'amount': 1});
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("เพิ่มลงตะกร้าแล้ว"),
              action: SnackBarAction(
                label: "ไปที่ตะกร้า",
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CartPage())),
              ),
            ),
          );
        },
        label: Text("เพิ่มลงตะกร้า"),
        icon: Icon(Icons.add_shopping_cart),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: Colors.deepOrange,
            iconTheme: IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.item["name"],
                  style: TextStyle(
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 5)])),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(widget.item["image"], fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("ราคา",
                          style: TextStyle(fontSize: 18, color: Colors.grey)),
                      Text("${widget.item["price"]} บาท",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange)),
                    ],
                  ),
                  Divider(height: 30),
                  _buildSectionHeader("ส่วนประกอบ", Icons.restaurant_menu),
                  Text(widget.item["ingredients"] ?? "ไม่ระบุ",
                      style: TextStyle(fontSize: 16, height: 1.5)),
                  SizedBox(height: 16),
                  _buildSectionHeader("วิธีทำ", Icons.list_alt),
                  Text(widget.item["instructions"] ?? "ไม่ระบุ",
                      style: TextStyle(fontSize: 16, height: 1.5)),
                  if (widget.item.containsKey("video")) ...[
                    SizedBox(height: 16),
                    _buildSectionHeader("วิดีโอสาธิต", Icons.play_circle_fill),
                    VideoPlayerItem(videoPath: widget.item["video"]),
                  ],
                  SizedBox(height: 16),
                  _buildSectionHeader("พิกัดร้าน", Icons.store),
                  Text("${widget.item["shopLocation"] ?? 'ไม่ระบุ'}",
                      style: TextStyle(fontSize: 16)),
                  SizedBox(height: 10),
                  _buildSectionHeader("พิกัดของคุณ", Icons.my_location),
                  Text("$_currentPosition",
                      style: TextStyle(fontSize: 16, color: Colors.blue)),
                  if (_distance.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(_distance,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                    ),
                  if (_shopLocation != null) ...[
                    SizedBox(height: 16),
                    _buildSectionHeader("แผนที่ร้านค้า", Icons.map),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: _shopLocation!,
                          initialZoom: 15.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.foodapp',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _shopLocation!,
                                width: 80,
                                height: 80,
                                child: Icon(Icons.location_on,
                                    color: Colors.red, size: 40),
                              ),
                              if (_userLocation != null)
                                Marker(
                                  point: _userLocation!,
                                  width: 80,
                                  height: 80,
                                  child: Icon(Icons.my_location,
                                      color: Colors.blue, size: 40),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepOrange, size: 20),
          SizedBox(width: 8),
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // ฟังก์ชันสั่งซื้อแบบ Debug Mode
  void _confirmOrder() async {
    if (userCart.isEmpty) return;

    // 1. เช็ค User
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("User is null, attempting to sign in...");
      await FirebaseAuth.instance.signInAnonymously();
      user = FirebaseAuth.instance.currentUser;
    }

    print("Ordering for User: ${user?.uid}");

    int totalAmount =
        userCart.fold(0, (sum, item) => sum + (item['amount'] as int));
    int totalPrice = userCart.fold(
        0,
        (sum, item) =>
            sum + ((item['price'] as int) * (item['amount'] as int)));

    List<Map<String, dynamic>> itemsToSave = userCart
        .map((item) => {
              'item': item['name'],
              'price': item['price'],
              'amount': item['amount'],
              'net_total': (item['price'] as int) * (item['amount'] as int),
              'shopLocation': item['shopLocation'],
            })
        .toList();

    try {
      print("Uploading to Firestore...");
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': user?.uid,
        'items': itemsToSave,
        'amount': totalAmount,
        'total': totalPrice,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Order success!");
      setState(() => userCart.clear());

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("สำเร็จ", style: TextStyle(color: Colors.green)),
          content: Text("สั่งอาหารเรียบร้อยแล้ว\nราคารวม: $totalPrice บาท"),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text("ตกลง")),
          ],
        ),
      );
    } catch (e) {
      print("Firebase Error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("ล้มเหลว: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPrice = userCart.fold(
        0,
        (sum, item) =>
            sum + ((item['price'] as int) * (item['amount'] as int)));
    return Scaffold(
      appBar: AppBar(
          title: Text("ตะกร้าสินค้า"), backgroundColor: Colors.deepOrange),
      body: userCart.isEmpty
          ? Center(child: Text("ไม่มีสินค้าในตะกร้า"))
          : ListView.builder(
              itemCount: userCart.length,
              padding: EdgeInsets.all(10),
              itemBuilder: (context, index) => Card(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(userCart[index]['image'],
                            width: 60, height: 60, fit: BoxFit.cover),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(userCart[index]['name'],
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text("${userCart[index]['price']} ฿",
                                style: TextStyle(
                                    color: Colors.deepOrange,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: Colors.grey),
                        onPressed: () => setState(() {
                          if (userCart[index]['amount'] > 1)
                            userCart[index]['amount']--;
                          else
                            userCart.removeAt(index);
                        }),
                      ),
                      Text("${userCart[index]['amount']}",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: Icon(Icons.add_circle, color: Colors.deepOrange),
                        onPressed: () =>
                            setState(() => userCart[index]['amount']++),
                      ),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: userCart.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(vertical: 15)),
                onPressed: _confirmOrder,
                child: Text("ยืนยันการสั่งซื้อ (รวม $totalPrice บาท)",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
    );
  }
}

class VideoPlayerItem extends StatefulWidget {
  final String videoPath;
  const VideoPlayerItem({Key? key, required this.videoPath}) : super(key: key);
  @override
  _VideoPlayerItemState createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        if (mounted) setState(() => _isInitialized = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) return Center(child: CircularProgressIndicator());
    return Column(
      children: [
        AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(_controller),
              IconButton(
                icon: Icon(
                    _controller.value.isPlaying
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    size: 50,
                    color: Colors.white70),
                onPressed: () => setState(() => _controller.value.isPlaying
                    ? _controller.pause()
                    : _controller.play()),
              ),
            ],
          ),
        ),
        VideoProgressIndicator(_controller, allowScrubbing: true),
      ],
    );
  }
}
