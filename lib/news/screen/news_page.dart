import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/news_model.dart';
import '../widgets/news_card.dart';
import 'news_form.dart';
import 'news_detail_page.dart'; // [IMPORT BARU] Jangan lupa import ini

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
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

  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();
    try {
      final response = await request.get(
        'http://localhost:8000/news/user-status/',
      );
      setState(() {
        _isAdmin = response['is_admin'] ?? false;
      });
    } catch (e) {
      print("Gagal cek status admin: $e");
      setState(() => _isAdmin = false);
    }
  }

  Future<void> _fetchNews() async {
    final request = context.read<CookieRequest>();
    setState(() => _isLoading = true);
    try {
      final response = await request.get('http://localhost:8000/news/json/');
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
      print("Error fetching news: $e");
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
    final url = 'http://localhost:8000/news/like/$newsId/';

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

  // --- [PERBAIKAN 1] URL DELETE ---
  Future<void> _deleteNews(String newsId) async {
    final request = context.read<CookieRequest>();

    final url = 'http://localhost:8000/news/delete/$newsId/';

    try {
      final response = await request.post(
        url,
        {},
      ); // Simpan response untuk debugging

      // Cek jika server mengembalikan error HTML (misal 404) bukan JSON
      if (response.toString().contains("Not Found") ||
          response.toString().contains("404")) {
        throw Exception("Endpoint delete tidak ditemukan (404). Cek urls.py");
      }

      setState(() {
        _allNews.removeWhere((element) => element.id == newsId);
        _filteredNews.removeWhere((element) => element.id == newsId);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berita berhasil dihapus!")),
        );
      }
    } catch (e) {
      print("Error delete: $e"); // Print error ke terminal agar mudah debug
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal menghapus berita. Cek terminal."),
          ),
        );
      }
    }
  }

  void _navigateToEdit(NewsEntry news) {
    // Navigasi ke NewsFormPage dengan membawa objek news
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsFormPage(news: news), // Kirim data berita
      ),
    ).then((_) {
      // Refresh list berita setelah kembali dari form edit
      _fetchNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isLoggedIn = request.loggedIn;

    return Scaffold(
      appBar: AppBar(
        title: const Text("MounTrack News"),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchNews),
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.add_box_outlined),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewsFormPage()),
                ).then((_) {
                  _fetchNews();
                });
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Cari Berita...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredNews.isEmpty
                ? const Center(child: Text("Belum ada berita."))
                : ListView.builder(
                    itemCount: _filteredNews.length,
                    itemBuilder: (context, index) {
                      final news = _filteredNews[index];

                      // --- [PERBAIKAN 2] NAVIGASI KE DETAIL ---
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetailPage(news: news),
                            ),
                          ).then((_) {
                            // Opsional: Refresh saat kembali, siapa tahu like berubah di detail page
                            setState(() {});
                          });
                        },
                        child: NewsCard(
                          newsItem: news,
                          isLoggedIn: isLoggedIn,
                          isAdmin: _isAdmin,
                          onLikePressed: () => _toggleLike(index, news.id),
                          onDeletePressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Hapus Berita'),
                                content: const Text('Apakah Anda yakin?'),
                                actions: [
                                  TextButton(
                                    child: const Text('Batal'),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: const Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
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
