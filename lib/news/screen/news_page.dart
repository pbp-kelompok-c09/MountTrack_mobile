import 'package:flutter/material.dart';

class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Mengatur background menjadi warna putih
      backgroundColor: Colors.white,

      // Menampilkan tulisan di tengah halaman
      body: Center(
        child: Text(
          "ini page landing news",
          style: const TextStyle(
            fontSize: 18.0,
            color: Colors
                .black, // Warna teks hitam agar terlihat di background putih
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
