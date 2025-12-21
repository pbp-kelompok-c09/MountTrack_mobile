import 'package:flutter/material.dart';
import '../models/news_model.dart'; // Pastikan model memiliki field 'newsViews'

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
        color: Colors.white.withOpacity(0.8),
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
                    // UPDATE: Penulis (Menyesuaikan Web: "Penulis: User")
                    Text(
                      "${newsItem.username.toUpperCase()}",
                      style: const TextStyle(
                        color: mossGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 10, // Sedikit diperkecil agar muat
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Judul Berita
                    Text(
                      newsItem.title,
                      maxLines:
                          2, // Mengurangi maxLines agar tidak terlalu panjang
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: kombuGreen,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // UPDATE: Tanggal + Views (Menyesuaikan Web)
                    // Format: "20 Des 2025, 14:30 WIB | Dilihat: 100x"
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 11,
                          color: kombuGreen.withOpacity(0.6),
                          fontFamily:
                              'JakartaSans', // Sesuaikan font default Anda
                        ),
                        children: [
                          TextSpan(
                            text: _formatDateDetailed(newsItem.publishedDate),
                          ),
                          const TextSpan(text: " WIB | "),
                          const WidgetSpan(
                            child: Icon(
                              Icons.visibility,
                              size: 12,
                              color: mossGreen,
                            ),
                            alignment: PlaceholderAlignment.middle,
                          ),
                          // Pastikan newsItem punya property newsViews, jika tidak ganti 0
                          TextSpan(text: " ${newsItem.newsViews}x"),
                        ],
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
                      height: 80, // Sedikit disesuaikan
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 80,
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
                Expanded(
                  flex: 1,
                  child: Container(
                    height: 80,
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
                      // UPDATE: Icon Thumbs Up (Sesuai Web)
                      Icon(
                        newsItem.isLiked
                            ? Icons.thumb_up
                            : Icons.thumb_up_alt_outlined,
                        size: 18,
                        // UPDATE: Warna Hijau (btn-success web)
                        color: newsItem.isLiked
                            ? Colors.green[600]
                            : kombuGreen.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${newsItem.totalLikes}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          // UPDATE: Warna Teks Hijau jika dilike
                          color: newsItem.isLiked
                              ? Colors.green[600]
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

  // Helper Format Tanggal lebih detail (dd MMM yyyy, HH:mm)
  String _formatDateDetailed(DateTime date) {
    // List nama bulan singkat (Indonesia)
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Ags',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    String day = date.day.toString();
    String month = months[date.month - 1];
    String year = date.year.toString();
    String hour = date.hour.toString().padLeft(2, '0');
    String minute = date.minute.toString().padLeft(2, '0');

    return "$day $month $year, $hour:$minute";
  }
}
