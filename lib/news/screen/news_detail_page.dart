import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/news_model.dart';
import 'package:mounttrack_mobile/config.dart';

class NewsDetailPage extends StatefulWidget {
  final NewsEntry news;

  const NewsDetailPage({super.key, required this.news});

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  // State Data
  late bool _isLiked;
  late int _likeCount;
  late int _newsViews;

  // State UI (Dark Mode Lokal)
  bool _isDarkMode = false; // Default Light Mode

  // --- PALET WARNA ALAM ---
  static const cafeNoir = Color(0xFF4C3019);
  static const kombuGreen = Color(0xFF354024);
  static const mossGreen = Color(0xFF889063);
  static const tan = Color(0xFFCFBB99);
  static const bone = Color(0xFFE5D7C4);
  static const sacramento = Color(0xFF102114);
  static const tangerine = Color(0xFFEB3D00);

  @override
  void initState() {
    super.initState();
    _isLiked = widget.news.isLiked;
    _likeCount = widget.news.totalLikes;
    _newsViews = widget.news.newsViews;

    // Panggil fungsi increment view saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _incrementView();
    });
  }

  // --- LOGIKA BACKEND (TETAP SAMA) ---

  Future<void> _toggleLike() async {
    final request = context.read<CookieRequest>();

    final url = '${AppConfig.baseUrl}/news/like/${widget.news.id}/';

    try {
      final response = await request.post(url, {});
      if (response['status'] == 'success') {
        setState(() {
          _isLiked = response['is_liked'];
          _likeCount = response['total_likes'];
          widget.news.isLiked = _isLiked;
          widget.news.totalLikes = _likeCount;
        });

        // Tampilkan Toast/SnackBar singkat
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isLiked ? "Berita disukai!" : "Batal menyukai."),
            // UPDATE: Warna snackbar saat light mode jadi hijau
            backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.green[700],
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      // Error handling silent
    }
  }

  Future<void> _incrementView() async {
    final request = context.read<CookieRequest>();
    final url = '${AppConfig.baseUrl}/news/increment-view/${widget.news.id}/';

    try {
      final response = await request.post(url, {});
      if (response['status'] == 'success') {
        setState(() {
          _newsViews = response['news_views'];
        });
      }
    } catch (e) {
      print("Gagal update view: $e");
    }
  }

  // UPDATE: Format Tanggal + Jam (Sesuai Web)
  String _formatDate(DateTime date) {
    return "${DateFormat('dd MMM yyyy').format(date)}";
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(imageUrl),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  // --- BUILD UI ---

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isLoggedIn = request.loggedIn;

    // Konfigurasi Warna berdasarkan Mode
    final Color backgroundColor = _isDarkMode ? const Color(0xFF121212) : bone;
    final Color primaryTextColor = _isDarkMode ? Colors.white : kombuGreen;
    final Color secondaryTextColor = _isDarkMode
        ? Colors.grey[400]!
        : kombuGreen.withOpacity(0.7);
    final Color cardColor = _isDarkMode
        ? const Color(0xFF1E1E1E)
        : Colors.white.withOpacity(0.6);
    final Color iconColor = _isDarkMode ? Colors.white : kombuGreen;

    return Theme(
      data: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: backgroundColor,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: iconColor),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            // Toggle Dark Mode
            IconButton(
              icon: Icon(
                _isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                color: iconColor,
              ),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. JUDUL & TOMBOL LIKE
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      widget.news.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                        height: 1.3,
                      ),
                    ),
                  ),
                  IconButton(
                    // UPDATE: Icon Thumbs Up (Filled vs Outlined)
                    icon: Icon(
                      _isLiked ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                      // UPDATE: Warna Hijau jika dilike (Sesuai Web)
                      color: _isLiked ? Colors.green[600] : iconColor,
                      size: 28,
                    ),
                    onPressed: isLoggedIn
                        ? _toggleLike
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Login dulu untuk like!"),
                              ),
                            );
                          },
                  ),
                ],
              ),

              // Jumlah Like kecil di bawah tombol
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "$_likeCount Likes",
                  style: TextStyle(
                    fontSize: 12,
                    // UPDATE: Warna teks hijau jika dilike
                    color: _isLiked ? Colors.green[600] : secondaryTextColor,
                    fontWeight: _isLiked ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 3. GAMBAR UTAMA (Rounded)
              if (widget.news.pinnedThumbnail != null &&
                  widget.news.pinnedThumbnail!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.news.pinnedThumbnail!,
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, st) => Container(
                      height: 220,
                      color: _isDarkMode
                          ? Colors.grey[800]
                          : tan.withOpacity(0.5),
                      child: Icon(
                        Icons.broken_image,
                        color: secondaryTextColor,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // 4. AUTHOR & INFO (ListTile Style)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _isDarkMode
                          ? Colors.grey[800]!
                          : kombuGreen.withOpacity(0.1),
                    ),
                    top: BorderSide(
                      color: _isDarkMode
                          ? Colors.grey[800]!
                          : kombuGreen.withOpacity(0.1),
                    ),
                  ),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: mossGreen,
                    child: Text(
                      widget.news.username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  title: Text(
                    "Oleh: ${widget.news.username}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  // UPDATE: Format Tanggal ada Jam-nya
                  subtitle: Text(
                    _formatDate(widget.news.publishedDate),
                    style: TextStyle(color: secondaryTextColor),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.visibility, // Ganti ke visibility biasa
                          size: 16,
                          color: secondaryTextColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "$_newsViews",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 5. ISI BERITA
              Text(
                widget.news.content,
                style: TextStyle(
                  fontSize: 16,
                  color: primaryTextColor.withOpacity(0.9),
                  height: 1.6, // Jarak antar baris agar nyaman dibaca
                ),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24),

              // 6. GALERI FOTO (Jika ada)
              if (widget.news.additionalImages != null &&
                  widget.news.additionalImages!.isNotEmpty) ...[
                Text(
                  "Gambar Tambahan",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
                const SizedBox(height: 12),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: widget.news.additionalImages!.length,
                  itemBuilder: (context, index) {
                    final imgUrl = widget.news.additionalImages![index];
                    return GestureDetector(
                      onTap: () => _showImageDialog(context, imgUrl),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imgUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: cardColor,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: mossGreen,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (ctx, err, stack) => Container(
                            color: cardColor,
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 30),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
