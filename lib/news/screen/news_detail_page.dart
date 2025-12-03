import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/news_model.dart';

class NewsDetailPage extends StatefulWidget {
  final NewsEntry news;

  const NewsDetailPage({Key? key, required this.news}) : super(key: key);

  @override
  State<NewsDetailPage> createState() => _NewsDetailPageState();
}

class _NewsDetailPageState extends State<NewsDetailPage> {
  late bool _isLiked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.news.isLiked;
    _likeCount = widget.news.totalLikes;
  }

  Future<void> _toggleLike() async {
    final request = context.read<CookieRequest>();
    // URL Django: localhost:8000/news/like/<id>/
    final url = 'http://localhost:8000/news/like/${widget.news.id}/';

    try {
      final response = await request.post(url, {});
      if (response['status'] == 'success') {
        setState(() {
          _isLiked = response['is_liked'];
          _likeCount = response['total_likes'];
          widget.news.isLiked = _isLiked;
          widget.news.totalLikes = _likeCount;
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

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM yyyy, HH:mm').format(date);
  }

  // Widget untuk menampilkan satu gambar dalam modal (Zoom)
  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Image.network(imageUrl, fit: BoxFit.contain),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final bool isLoggedIn = request.loggedIn;

    return Scaffold(
      appBar: AppBar(title: const Text("Detail Berita")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. JUDUL
            Text(
              widget.news.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // 2. META DATA
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildMetaRow(
                    Icons.calendar_today,
                    "Diterbitkan: ${_formatDate(widget.news.publishedDate)}",
                  ),
                  const SizedBox(height: 8),
                  _buildMetaRow(
                    Icons.person,
                    "Penulis: ${widget.news.username.toString().split('.').last}",
                  ),
                  const SizedBox(height: 8),
                  _buildMetaRow(
                    Icons.visibility,
                    "Dilihat: ${widget.news.newsViews} kali",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. TOMBOL LIKE
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: isLoggedIn
                      ? _toggleLike
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Silakan login untuk menyukai berita.",
                              ),
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isLiked ? Colors.red : Colors.white,
                    foregroundColor: _isLiked ? Colors.white : Colors.red,
                    side: const BorderSide(color: Colors.red),
                    elevation: 0,
                  ),
                  icon: Icon(
                    _isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  ),
                  label: Text("$_likeCount Likes"),
                ),
                if (!isLoggedIn)
                  const Padding(
                    padding: EdgeInsets.only(left: 8.0),
                    child: Text(
                      "(Login to like)",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // 4. THUMBNAIL UTAMA
            if (widget.news.pinnedThumbnail != null &&
                widget.news.pinnedThumbnail!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.news.pinnedThumbnail!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // 5. KONTEN BERITA
            Text(
              widget.news.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),

            // 6. GALERI GAMBAR TAMBAHAN (Sesuai show_news.html)
            if (widget.news.additionalImages != null &&
                widget.news.additionalImages!.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Galeri Foto",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              GridView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(), // Agar scroll menyatu dengan halaman utama
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 Kolom
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0, // Kotak
                ),
                itemCount: widget.news.additionalImages!.length,
                itemBuilder: (context, index) {
                  final imgUrl = widget.news.additionalImages![index];
                  return GestureDetector(
                    onTap: () => _showImageDialog(context, imgUrl),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ] else ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "Tidak ada gambar tambahan untuk berita ini.",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],

            const Divider(),

            // 7. TOMBOL KEMBALI
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text("Kembali ke Halaman Berita"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 14)),
      ],
    );
  }
}
