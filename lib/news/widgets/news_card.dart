import 'package:flutter/material.dart';
import '../models/news_model.dart';

class NewsCard extends StatelessWidget {
  final NewsEntry newsItem;
  final bool isLoggedIn;
  final bool isAdmin;

  final VoidCallback? onLikePressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onEditPressed;

  const NewsCard({
    super.key,
    required this.newsItem,
    required this.isLoggedIn,
    required this.isAdmin,
    this.onLikePressed,
    this.onDeletePressed,
    this.onEditPressed,
  });

  // --- PALET WARNA ALAM ---
  static const kombuGreen = Color(0xFF354024);
  static const mossGreen = Color(0xFF889063);
  static const bone = Color(0xFFE5D7C4);
  static const tangerine = Color(0xFFEB3D00);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(
          0.8,
        ), // Sedikit transparan agar menyatu dengan background bone
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kombuGreen.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: kombuGreen.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // BAGIAN ATAS: Teks (Kiri) & Gambar (Kanan)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TEKS INFO
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kategori/Penulis (Warna Aksen)
                    Text(
                      newsItem.username.toUpperCase(),
                      style: const TextStyle(
                        color: mossGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Judul Berita
                    Text(
                      newsItem.title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kombuGreen,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tanggal
                    Text(
                      _formatDate(newsItem.publishedDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: kombuGreen.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // 2. GAMBAR THUMBNAIL (Kanan)
              if (newsItem.pinnedThumbnail != null &&
                  newsItem.pinnedThumbnail!.isNotEmpty)
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      newsItem.pinnedThumbnail!,
                      height: 90,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 90,
                          color: bone,
                          child: const Icon(
                            Icons.broken_image,
                            color: mossGreen,
                          ),
                        );
                      },
                    ),
                  ),
                )
              else
                // Placeholder jika tidak ada gambar
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 90,
                    decoration: BoxDecoration(
                      color: bone,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.article,
                      color: mossGreen,
                      size: 30,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 8),

          // BAGIAN BAWAH: Action Buttons (Like & Admin)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Like Button
              InkWell(
                onTap: isLoggedIn ? onLikePressed : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        newsItem.isLiked
                            ? Icons.thumb_up
                            : Icons.thumb_up_alt_outlined,
                        size: 18,
                        color: newsItem.isLiked
                            ? Colors.blue
                            : kombuGreen.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${newsItem.totalLikes}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: newsItem.isLiked
                              ? Colors.blue
                              : kombuGreen.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Admin Actions (Edit/Delete)
              if (isAdmin)
                Row(
                  children: [
                    InkWell(
                      onTap: onEditPressed,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: kombuGreen.withOpacity(0.7),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: onDeletePressed,
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: tangerine,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
