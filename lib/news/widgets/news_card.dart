import 'package:flutter/material.dart';
import '../models/news_model.dart';

class NewsCard extends StatelessWidget {
  final NewsEntry newsItem;
  final bool isLoggedIn;
  final bool isAdmin;

  // Callback functions
  final VoidCallback? onLikePressed;
  final VoidCallback? onDeletePressed;
  final VoidCallback? onEditPressed;

  const NewsCard({
    Key? key,
    required this.newsItem,
    required this.isLoggedIn,
    required this.isAdmin,
    this.onLikePressed,
    this.onDeletePressed,
    this.onEditPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. BAGIAN GAMBAR (Thumbnail)
          if (newsItem.pinnedThumbnail != null &&
              newsItem.pinnedThumbnail!.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.network(
                newsItem.pinnedThumbnail!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
            ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. BAGIAN JUDUL
                Text(
                  newsItem.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // 3. BAGIAN INFO (Penulis & Tanggal)
                Row(
                  children: [
                    const Icon(Icons.person, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      newsItem.username
                          .toString()
                          .split('.')
                          .last, // Atau newsItem.username.name jika enum
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(newsItem.publishedDate),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // 4. BAGIAN KONTEN (Preview)
                Text(
                  newsItem.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),

                const Divider(height: 24),

                // 5. BAGIAN TOMBOL AKSI (Like & Admin)
                Row(
                  children: [
                    // --- TOMBOL LIKE ---
                    InkWell(
                      onTap: isLoggedIn
                          ? onLikePressed
                          : null, // Disable jika belum login
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8.0,
                          horizontal: 4.0,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              newsItem.isLiked
                                  ? Icons.thumb_up
                                  : Icons.thumb_up_outlined,
                              color: newsItem.isLiked
                                  ? Colors.blue
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${newsItem.totalLikes} Likes',
                              style: TextStyle(
                                color: newsItem.isLiked
                                    ? Colors.blue
                                    : Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    // --- TOMBOL ADMIN (Edit & Delete) ---
                    if (isAdmin)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            tooltip: 'Edit',
                            onPressed: onEditPressed,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Hapus',
                            onPressed: onDeletePressed,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    // Format tanggal sederhana manual agar tidak perlu import intl dulu jika belum siap
    return "${date.day}/${date.month}/${date.year}";
  }
}
