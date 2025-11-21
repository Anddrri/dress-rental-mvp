import 'dart:convert';
import 'package:flutter/foundation.dart'; // Для перевірки Web/Android
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <--- ПОТРІБНО ДЛЯ КОПІЮВАННЯ ТЕКСТУ
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

void main() {
  runApp(const DressRentalApp());
}

class DressRentalApp extends StatelessWidget {
  const DressRentalApp({super.key});

  static const Color colorElegance = Color(0xFF5D3E46);
  static const Color colorGold = Color(0xFFD8B371);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Бурхливі Оплески',
      theme: ThemeData(
        primaryColor: colorElegance,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorElegance,
          primary: colorElegance,
          secondary: colorGold,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: colorElegance, width: 2),
          ),
        ),
      ),
      home: const LookbookPage(),
    );
  }
}

// --- МОДЕЛЬ СУКНІ ---
class Dress {
  final int id;
  final String title;
  final List<String> imageUrls;
  final String ageRange;
  final double price;
  final double imageRatio;
  final String description;

  const Dress({
    required this.id,
    required this.title,
    required this.imageUrls,
    required this.ageRange,
    required this.price,
    this.imageRatio = 1.0,
    this.description = '',
  });

  factory Dress.fromJson(Map<String, dynamic> json) {
    List<String> photos = [];
    if (json['images'] != null) {
      for (var img in json['images']) {
        photos.add(img['image']);
      }
    }

    if (photos.isEmpty) {
      photos.add('https://via.placeholder.com/300x400.png?text=No+Image');
    }
    // Дублюємо фото, якщо їх мало (для дизайну картки)
    if (photos.length < 2) photos.add(photos[0]);
    if (photos.length < 3) photos.add(photos[0]);

    return Dress(
      id: json['id'],
      title: json['title'],
      imageUrls: photos,
      ageRange: json['age_range'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imageRatio: json['image_ratio'] ?? 1.0,
      description: json['description'] ?? '',
    );
  }
}

// --- API SERVICE ---
Future<List<Dress>> fetchDresses() async {
  String baseUrl;

  if (kIsWeb) {
    baseUrl = 'http://127.0.0.1:8000'; // Chrome
  } else {
    baseUrl = 'http://10.0.2.2:8000'; // Android Emulator
  }

  final String url = '$baseUrl/api/dresses/';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Dress.fromJson(item)).toList();
    } else {
      throw Exception('Помилка сервера: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Помилка з\'єднання: $e');
  }
}

// --- СТОРІНКА КАТЕГОРІЇ ---
class CategoryPage extends StatefulWidget {
  final String categoryTitle;
  const CategoryPage({super.key, required this.categoryTitle});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  String? selectedAge;
  late Future<List<Dress>> futureDresses;

  @override
  void initState() {
    super.initState();
    futureDresses = fetchDresses();
  }

  final List<String> ageOptions = [
    "2 роки", "3 роки", "4 роки", "5 років", "6 років",
    "8 років", "9 років", "10 років", "11 років", "12 років", "13 років"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: DressRentalApp.colorElegance,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              widget.categoryTitle,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: DressRentalApp.colorElegance.withOpacity(0.3), width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedAge,
                    hint: const Row(children: [
                      Icon(Icons.filter_list, size: 18, color: DressRentalApp.colorElegance),
                      SizedBox(width: 8),
                      Text("Оберіть вік", style: TextStyle(color: Colors.grey, fontSize: 14))
                    ]),
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: DressRentalApp.colorElegance),
                    borderRadius: BorderRadius.circular(12),
                    items: ageOptions.map((String age) => DropdownMenuItem(value: age, child: Text(age, style: const TextStyle(color: DressRentalApp.colorElegance, fontWeight: FontWeight.w500)))).toList(),
                    onChanged: (v) => setState(() => selectedAge = v),
                  ),
                ),
              ),
            ),
          ),
          
          FutureBuilder<List<Dress>>(
            future: futureDresses,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(50), child: CircularProgressIndicator(color: DressRentalApp.colorElegance))));
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(child: Center(child: Text("Помилка: ${snapshot.error}")));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(child: Center(child: Text("Суконь поки немає")));
              }

              return SliverPadding(
                padding: const EdgeInsets.all(12.0),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220.0,
                    mainAxisSpacing: 12.0,
                    crossAxisSpacing: 12.0,
                    childAspectRatio: 0.55,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return _buildThreePhotoCard(context, snapshot.data![index]);
                    },
                    childCount: snapshot.data!.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- ГОЛОВНА СТОРІНКА ---
class LookbookPage extends StatefulWidget {
  const LookbookPage({super.key});

  @override
  State<LookbookPage> createState() => _LookbookPageState();
}

class _LookbookPageState extends State<LookbookPage> {
  late Future<List<Dress>> futureDresses;

  @override
  void initState() {
    super.initState();
    futureDresses = fetchDresses();
  }
  
  final List<Map<String, String>> categoryData = const [
    {"title": "Дитячі", "img": "https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?auto=format&fit=crop&w=300&q=80"},
    {"title": "Дорослі", "img": "https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=300&q=80"},
    {"title": "Family Look", "img": "https://images.unsplash.com/photo-1609198092458-38a293c7ac4b?auto=format&fit=crop&w=300&q=80"},
    {"title": "Вишиванки", "img": "https://images.unsplash.com/photo-1526045612212-70caf35c14df?auto=format&fit=crop&w=300&q=80"},
    {"title": "Аксесуари", "img": "https://images.unsplash.com/photo-1576053139778-7e32f2ae3cfd?auto=format&fit=crop&w=300&q=80"},
    {"title": "Розпродаж", "img": "https://images.unsplash.com/photo-1483985988355-763728e1935b?auto=format&fit=crop&w=300&q=80"},
  ];

  void _showFilterModal(BuildContext context) {}
  void _showCartModal(BuildContext context) {}

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = (screenWidth / 250).floor().clamp(2, 4);
    final bool isMobile = screenWidth < 600;

    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: DressRentalApp.colorElegance),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                Icon(Icons.diamond_outlined, color: DressRentalApp.colorGold, size: 48),
                SizedBox(height: 10),
                Text("БУРХЛИВІ\nОПЛЕСКИ", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                Text("DRESS SALON", style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 2.0))
              ]),
            ),
            ListTile(leading: const Icon(Icons.home_filled, color: DressRentalApp.colorElegance), title: const Text("Головна сторінка"), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260.0,
            pinned: true,
            backgroundColor: DressRentalApp.colorElegance,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(icon: const Icon(Icons.tune), onPressed: () => _showFilterModal(context)),
              IconButton(icon: const Icon(Icons.shopping_bag_outlined), onPressed: () => _showCartModal(context)),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: const Text("БУРХЛИВІ\nОПЛЕСКИ", textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Serif', color: Colors.white, letterSpacing: 1.5, fontWeight: FontWeight.bold, fontSize: 16)),
              background: Stack(fit: StackFit.expand, children: [
                Image.network("https://images.unsplash.com/photo-1549486046-33f59c47da3e?q=80&w=2070&auto=format&fit=crop", fit: BoxFit.cover),
                Container(color: Colors.black45),
              ]),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                if (!isMobile) ...[
                  const Padding(padding: EdgeInsets.all(16), child: Text("Категорії", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DressRentalApp.colorElegance))),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Wrap(spacing: 30, runSpacing: 20, alignment: WrapAlignment.center, children: categoryData.map((c) => GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CategoryPage(categoryTitle: c['title']!))), child: Column(children: [
                          Container(height: 90, width: 90, decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), image: DecorationImage(image: NetworkImage(c['img']!), fit: BoxFit.cover))),
                          const SizedBox(height: 8),
                          Text(c['title']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DressRentalApp.colorElegance))
                        ]))).toList()),
                  ),
                ],
                const Padding(padding: EdgeInsets.all(16), child: Text("Всі пропозиції", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: DressRentalApp.colorElegance))),
              ],
            ),
          ),

          FutureBuilder<List<Dress>>(
            future: futureDresses,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                 return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: DressRentalApp.colorElegance)));
              } else if (snapshot.hasError) {
                 return SliverToBoxAdapter(child: Center(child: Text("Помилка: ${snapshot.error}")));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                 return const SliverToBoxAdapter(child: Center(child: Text("Немає суконь")));
              }

              return SliverPadding(
                padding: const EdgeInsets.all(12.0),
                sliver: SliverMasonryGrid.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12.0,
                  crossAxisSpacing: 12.0,
                  childCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    return _buildThreePhotoCard(context, snapshot.data![index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- ЗАГАЛЬНА ФУНКЦІЯ КАРТКИ ---
Widget _buildThreePhotoCard(BuildContext context, Dress dress) {
  String img1 = dress.imageUrls.isNotEmpty ? dress.imageUrls[0] : '';
  String img2 = dress.imageUrls.length > 1 ? dress.imageUrls[1] : img1;
  String img3 = dress.imageUrls.length > 2 ? dress.imageUrls[2] : img1;

  return Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade200)),
    clipBehavior: Clip.antiAlias,
    color: Colors.white,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectRatio(
          aspectRatio: 1 / (dress.imageRatio),
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(width: double.infinity, child: Image.network(img1, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.image_not_supported)))),
              ),
              const SizedBox(height: 2),
              Expanded(
                flex: 1,
                child: Row(children: [
                  Expanded(child: Image.network(img2, fit: BoxFit.cover, height: double.infinity, errorBuilder: (c, e, s) => const Icon(Icons.error))),
                  const SizedBox(width: 2),
                  Expanded(child: Image.network(img3, fit: BoxFit.cover, height: double.infinity, errorBuilder: (c, e, s) => const Icon(Icons.error))),
                ]),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(dress.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: DressRentalApp.colorElegance), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text("${dress.price.toStringAsFixed(0)} грн", style: const TextStyle(color: DressRentalApp.colorElegance, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(dress.ageRange, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
            ]),
            const SizedBox(height: 8),
            SizedBox(
                width: double.infinity,
                height: 32,
                child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductDetailsPage(dress: dress)),
                      );
                    },
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: DressRentalApp.colorElegance, width: 1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), padding: EdgeInsets.zero),
                    child: const Text("Детальніше", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: DressRentalApp.colorElegance))))
          ]),
        ),
      ],
    ),
  );
}

// --- СТОРІНКА ДЕТАЛЕЙ ТОВАРУ (МЕНЕДЖЕР) ---
class ProductDetailsPage extends StatelessWidget {
  final Dress dress;
  // ТУТ ВКАЖИ РЕАЛЬНИЙ НОМЕР МЕНЕДЖЕРА
  final String managerPhone = "+380 97 645 1303";

  const ProductDetailsPage({super.key, required this.dress});

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Оренда сукні", style: TextStyle(color: DressRentalApp.colorElegance)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Для бронювання та уточнення деталей, будь ласка, зв'яжіться з нашим менеджером:"),
            const SizedBox(height: 20),
            SelectableText(
              managerPhone,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: DressRentalApp.colorElegance),
            ),
            const SizedBox(height: 10),
            const Text("(Натисніть на номер, щоб скопіювати)", style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: managerPhone));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Номер скопійовано!")));
              Navigator.pop(context);
            },
            child: const Text("Скопіювати"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: DressRentalApp.colorElegance, foregroundColor: Colors.white),
            onPressed: () => Navigator.pop(context),
            child: const Text("Зрозуміло"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          // Галерея фото
          Expanded(
            flex: 5,
            child: PageView.builder(
              itemCount: dress.imageUrls.length,
              itemBuilder: (context, index) {
                return Image.network(
                  dress.imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey)),
                );
              },
            ),
          ),

          // Інформація
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          dress.title,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: DressRentalApp.colorElegance),
                        ),
                      ),
                      Text(
                        "${dress.price.toStringAsFixed(0)} грн",
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: DressRentalApp.colorGold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                    child: Text("Вік: ${dress.ageRange}", style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    dress.description.isNotEmpty ? dress.description : "Елегантна сукня для особливої події. Зателефонуйте нам, щоб дізнатися, чи вільна вона на вашу дату!",
                    style: const TextStyle(color: Colors.grey, height: 1.5),
                  ),

                  const Spacer(),

                  // КНОПКА ЗВ'ЯЗКУ
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => _showContactDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DressRentalApp.colorElegance,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 5,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.phone, size: 24),
                          SizedBox(width: 10),
                          Text("Зв'язатися з менеджером", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}