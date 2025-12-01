import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import '../models/news_model.dart';
import '../widgets/news_card.dart';
import 'news_detail_page.dart';
// import 'news_form.dart'; // Uncomment jika sudah buat

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  // Variabel untuk menyimpan data berita
  List<NewsEntry> _allNews = [];
  List<NewsEntry> _filteredNews = [];

  // Controller untuk search bar
  final TextEditingController _searchController = TextEditingController();

  // Status loading
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Panggil fungsi fetch saat halaman pertama kali dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchNews();
    });

    // Listener untuk search bar agar filter real-time
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- 1. LOGIKA FETCH DATA (GET) ---
  Future<void> _fetchNews() async {
    final request = context.read<CookieRequest>();
    setState(() => _isLoading = true);

    try {
      // GANTI URL INI sesuai endpoint Django Anda (localhost atau deploy)
      // Contoh local: 'http://127.0.0.1:8000/news/json/'
      final response = await request.get('http://localhost:8000/news/json/');

      // Konversi respon JSON ke List<NewsEntry>
      // Kita pakai manual map karena response pbp_django_auth sudah berupa decoded JSON (List dynamic)
      List<NewsEntry> listData = [];
      for (var d in response) {
        if (d != null) {
          listData.add(NewsEntry.fromJson(d));
        }
      }

      setState(() {
        _allNews = listData;
        _filteredNews = listData; // Awalnya filtered sama dengan all
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching news: $e");
      setState(() => _isLoading = false);
    }
  }

  // --- 2. LOGIKA SEARCH ---
  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredNews = _allNews.where((news) {
        return news.title.toLowerCase().contains(query);
      }).toList();
    });
  }

  // --- 3. LOGIKA LIKE (POST) ---
  Future<void> _toggleLike(int index, String newsId) async {
    final request = context.read<CookieRequest>();

    // Endpoint like sesuai urls.py Django
    final url = 'http://localhost:8000/news/like/$newsId/';

    try {
      final response = await request.post(url, {});

      // Cek status dari JSON response Django
      if (response['status'] == 'success') {
        setState(() {
          // Update data lokal berdasarkan respon dari server
          // Agar UI berubah tanpa perlu refresh halaman (fetch ulang)
          _filteredNews[index].isLiked = response['is_liked'];
          _filteredNews[index].totalLikes = response['total_likes'];

          // Jangan lupa update _allNews juga agar konsisten saat search dihapus
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
      print("Error pada Like: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal melakukan like.")));
    }
  }

  // --- 4. LOGIKA DELETE (POST/DELETE) ---
  Future<void> _deleteNews(String newsId) async {
    final request = context.read<CookieRequest>();
    // Ganti URL sesuai endpoint delete Anda
    final url = 'http://localhost:8000/news/delete/$newsId/';

    try {
      await request.post(url, {}); // Django Anda pakai @require_POST
      // Jika sukses, hapus dari list lokal
      setState(() {
        _allNews.removeWhere((element) => element.id == newsId);
        _filteredNews.removeWhere((element) => element.id == newsId);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Berita berhasil dihapus!")));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal menghapus berita.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    // Cek status login & admin dari CookieRequest (sesuaikan dengan logic login Anda)
    // Biasanya request.loggedIn bernilai true jika ada session
    final bool isLoggedIn = request.loggedIn;

    // TODO: Anda perlu cara untuk tahu user itu admin atau bukan.
    // Saran: Tambahkan field 'is_admin' di JSON response show_json atau endpoint login.
    // Untuk sekarang kita hardcode false atau true untuk testing.
    final bool isAdmin = false;

    return Scaffold(
      appBar: AppBar(
        title: const Text("MounTrack News"),
        actions: [
          // Tombol Refresh
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchNews),
          // Tombol Create (Hanya Admin)
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Navigator.push(...) ke NewsForm
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // --- SEARCH BAR ---
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

          // --- LIST BERITA ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredNews.isEmpty
                ? const Center(child: Text("Belum ada berita."))
                : ListView.builder(
                    itemCount: _filteredNews.length,
                    itemBuilder: (context, index) {
                      final news = _filteredNews[index];

                      return NewsCard(
                        newsItem: news,
                        isLoggedIn: isLoggedIn,
                        isAdmin: isAdmin,
                        onLikePressed: () {
                          _toggleLike(index, news.id);
                        },
                        onDeletePressed: () {
                          // Tampilkan dialog konfirmasi sebelum hapus
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
                          // Navigasi ke form edit
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
