import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/news_model.dart';
import '../widgets/news_card.dart';
import 'news_form.dart';
import 'news_detail_page.dart';
import 'package:mounttrack_mobile/config.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  // --- PALET WARNA ALAM ---
  static const cafeNoir = Color(0xFF4C3019);
  static const kombuGreen = Color(0xFF354024);
  static const mossGreen = Color(0xFF889063);
  static const tan = Color(0xFFCFBB99);
  static const bone = Color(0xFFE5D7C4);
  static const sacramento = Color(0xFF102114);
  static const tangerine = Color(0xFFEB3D00);

  // --- STATE ---
  List<NewsEntry> _allNews = [];
  List<NewsEntry> _filteredNews = [];
  bool _isAdmin = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAdminStatus();
      _fetchNews();
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- LOGIKA BACKEND (TETAP SAMA) ---
  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        '${AppConfig.baseUrl}/news/user-status/',
      );
      setState(() {
        _isAdmin = response['is_admin'] ?? false;
      });
    } catch (e) {
      setState(() => _isAdmin = false);
    }
  }

  Future<void> _fetchNews() async {
    final request = context.read<CookieRequest>();
    setState(() => _isLoading = true);
    try {
      final response = await request.get('${AppConfig.baseUrl}/news/json/');
      List<NewsEntry> listData = [];
      for (var d in response) {
        if (d != null) {
          listData.add(NewsEntry.fromJson(d));
        }
      }
      setState(() {
        _allNews = listData;
        _filteredNews = listData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNews = _allNews.where((news) {
        return news.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _toggleLike(int index, String newsId) async {
    final request = context.read<CookieRequest>();
    final url = '${AppConfig.baseUrl}/news/like/$newsId/';

    try {
      final response = await request.post(url, {});
      if (response['status'] == 'success') {
        setState(() {
          _filteredNews[index].isLiked = response['is_liked'];
          _filteredNews[index].totalLikes = response['total_likes'];

          final originalIndex = _allNews.indexWhere(
            (n) => n.id == _filteredNews[index].id,
          );
          if (originalIndex != -1) {
            _allNews[originalIndex].isLiked = response['is_liked'];
            _allNews[originalIndex].totalLikes = response['total_likes'];
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal melakukan like.")));
      }
    }
  }

  Future<void> _deleteNews(String newsId) async {
    final request = context.read<CookieRequest>();
    final url = '${AppConfig.baseUrl}/news/delete/$newsId/';

    try {
      await request.post(url, {});
      setState(() {
        _allNews.removeWhere((element) => element.id == newsId);
        _filteredNews.removeWhere((element) => element.id == newsId);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Berita berhasil dihapus!"),
            backgroundColor: kombuGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menghapus berita."),
            backgroundColor: tangerine,
          ),
        );
      }
    }
  }

  void _navigateToEdit(NewsEntry news) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewsFormPage(news: news)),
    ).then((_) {
      _fetchNews();
    });
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isLoggedIn = request.loggedIn;

    return Scaffold(
      backgroundColor: bone, // Background utama
      appBar: AppBar(
        title: const Text(
          "MountTrack News",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: bone,
        foregroundColor: kombuGreen, // Warna teks & icon AppBar
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // Asumsi back ke menu utama
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNews,
            tooltip: "Refresh Berita",
          ),
          if (_isAdmin)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(Icons.add_circle, size: 28), // Icon lebih bold
                tooltip: "Buat Berita",
                color: tangerine, // Warna aksen mencolok untuk aksi utama
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewsFormPage(),
                    ),
                  ).then((_) {
                    _fetchNews();
                  });
                },
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // --- SEARCH BAR (Styled) ---
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            color: bone,
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: kombuGreen),
              decoration: InputDecoration(
                hintText: "Cari Berita...",
                hintStyle: TextStyle(color: kombuGreen.withOpacity(0.5)),
                prefixIcon: const Icon(Icons.search, color: kombuGreen),
                filled: true,
                fillColor: Colors.white.withOpacity(0.6),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(
                    30.0,
                  ), // Rounded pill shape
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- LIST NEWS ---
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kombuGreen),
                  )
                : _filteredNews.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.newspaper, size: 64, color: mossGreen),
                        const SizedBox(height: 16),
                        Text(
                          "Belum ada berita.",
                          style: TextStyle(
                            color: kombuGreen.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 20),
                    itemCount: _filteredNews.length,
                    itemBuilder: (context, index) {
                      final news = _filteredNews[index];

                      // Gesture detector untuk navigasi
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetailPage(news: news),
                            ),
                          ).then((_) {
                            setState(() {});
                          });
                        },
                        // Kirim context warna ke NewsCard jika perlu, atau NewsCard menyesuaikan sendiri
                        child: NewsCard(
                          newsItem: news,
                          isLoggedIn: isLoggedIn,
                          isAdmin: _isAdmin,
                          onLikePressed: () => _toggleLike(index, news.id),
                          onDeletePressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: bone,
                                title: const Text(
                                  'Hapus Berita',
                                  style: TextStyle(color: kombuGreen),
                                ),
                                content: const Text(
                                  'Apakah Anda yakin ingin menghapus berita ini?',
                                  style: TextStyle(color: kombuGreen),
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text(
                                      'Batal',
                                      style: TextStyle(color: kombuGreen),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: const Text(
                                      'Hapus',
                                      style: TextStyle(color: tangerine),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      _deleteNews(news.id);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          onEditPressed: () {
                            _navigateToEdit(news);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
