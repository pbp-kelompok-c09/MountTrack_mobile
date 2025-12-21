# Anggota Kelompok
- 2406429834 - Dibrienna Rauseuky Ramadhan
- 2406406710 - Farrel Arrayyan Adrianshah
- 2406360413 - Muhammad Hamiz Ghani Ayusha
- 2406429885 - Nimaisya Gina Herapati
- 2406419833 - Ryan Gibran Purwacakra Sihaloho

# Deskripsi Aplikasi
MountTrack adalah platform informasi pendakian yang menghadirkan daftar gunung aktif untuk didaki, lengkap dengan ketinggian gunung dan kondisi jalur terkini. Selain itu, MountTrack juga menyajikan berita dan tren terbaru seputar dunia pecinta alam, sehingga pendaki dapat merencanakan perjalanan dengan aman dan terarah.

Tak hanya sebagai sumber informasi, MountTrack juga menyediakan fitur booking pendakian gunung yang memudahkan pengguna dalam melakukan reservasi jalur resmi secara langsung melalui aplikasi. Melalui fitur komunitas, pengguna juga dapat berinteraksi dan mengelola rencana pendakian, menciptakan ekosistem yang kolaboratif bagi para pecinta alam di seluruh Indonesia.

# Daftar Modul
- **Halaman Autentikasi, Profil dan Admin Portal**: Halaman login, register, profil, dan admin portal untuk mengelola pengguna. (Farrel Arrayyan Adrianshah)
- **List Gunung**: Menyajikan daftar gunung beserta detail informasi seperti lokasi, ketinggian, jalur pendakian, dan kondisi jalur terkini di daerah pendakian. (Muhammad Hamiz Ghani Ayusha)
- **About**: Menyajikan informasi mengenai aplikasi. (Muhammad Hamiz Ghani Ayusha)
- **Booking Pendakian**: Pengguna dapat menjadwalkan sesi pendakian mereka sesuai dengan ketersediaan gunung. (Nimaisya Gina Herapati)
- **News**: Menyajikan berita terkini seputar gunung, kebijakan pendakian, kondisi jalur, hingga informasi menarik lainnya yang relevan bagi pendaki. (Ryan Gibran Purwacakra Sihaloho)
- **Community**: Informasi mengenai event pendaki gunung seperti melakukan pendakian bersama (open trip). (Dibrienna Rauseuky Ramadhan)

# Peran Pengguna
- **Belum Login**: Dapat melihat halaman homepage dan berita.
- **Login sebagai User**: Dapat membuat booking pendakian, membuat post komunitas baru, melengkapi profil, melihat berita, dan melihat list informasi gunung.
- **Login sebagai Admin**: Dapat merubah status kesediaan gunung, membuat berita baru, dan akses admin portal.

# Alur Pengintegrasian dengan *web service*
## Aplikasi secara keseluruhan
1. Mengimplementasikan sebuah class *wrapper* dengan menggunakan library ```http``` dan ```pbp-django-auth``` untuk menerapkan fitur *cookie-based authentication* pada aplikasi
2. Mengimplementasikan REST API pada Django (pada ```views.py```) dengan menggunakan ```JsonResponse``` atau Django JSON Serializer.
3. Mengimplementasikan desain *front-end* untuk aplikasi berdasarkan desain dan tema warna website MountTrack yang telah dibuat sebelumnya.
4. Mengintegrasikan *front-end* aplikasi dengan *back-end* dengan menggunakan konsep *asynchronous HTTP*.

## Per modul
### Autentikasi, Profil, dan Admin Portal
**Login**

Membuat sesi user dengan menggunakan *request* ```POST /accounts/loginapp``` untuk mengautentikasi user dengan username dan password yang diisi pengguna.

**Register**

Membuat akun baru dengan menggunakan *request* ```POST /accounts/registerapp``` untuk mengirimkan data pengguna dan membuat akun baru.

**Logout**

Menggunakan *request* ```POST /accounts/logoutapp``` untuk mengakhiri sesi pengguna.

**Profil**
- Menggunakan *request* ```GET /accounts/profileapp``` untuk mendapatkan semua data pengguna.
- Menggunakan *request* ```POST /accounts/profileapp``` untuk mengirimkan perubahan data pengguna.

**Admin Portal**
- Menggunakan *request* ```GET /accounts/admin-portal/get-users``` untuk mendapatkan daftar pengguna.
- Menggunakan *request* ```POST /accounts/admin-portal/manage_user_app``` untuk mengubah status admin atau menghapus pengguna.
- Menggunakan *request* ```POST /accounts/admin-portal/add-user``` untuk menambah pengguna baru dari.

### Mountains
**Menampilkan Keseluruhan Gunung**

menggunakan *request* : ```GET /mountains/api/mountains/``` untuk mendapatkan semua data gunung untuk ditampilkan.

**Menampilkan Detail Gunung**

menggunakan *request* : ```GET /mountains/api/mountains/<int:mountain_id>/``` untuk mendapatkan detail satu data gunung untuk ditampilkan.

**Edit Detail Gunung**

menggunakan *request* : ```POST /mountains/api/edit/<int:mountain_id>/``` untuk melakukan _update_ data terkait detail pada suatu gunung. (ADMIN)

**Menghapus Gunung**

Menggunakan *request* : ```POST /mountains/api/delete/<int:mountain_id>/``` untuk melakukan _delete_ suatu pada suatu gunung. (ADMIN)

**Tambah Gunung**

Menggunakan *request* : ```POST /mountains/api/create/``` untuk menambahkan data gunung. (ADMIN)

### Booking
**Membuat Booking**

Menggunakan *request* : ```POST /booking/api/book/``` untuk mengirim data booking berisi gunung_id, pax, anggota (nama, umur, jenis_kelamin, tingkat_kesulitan), tanggal pendakian, dan pilihan porter untuk disimpan ke server.

**Melihat Detail Booking**

Menggunakan *request* : ```GET /booking/api/<int:booking_id>/``` untuk menampilkan detail pemesanan tertentu seperti nama gunung, tanggal, jumlah peserta, total biaya, anggota, dan status pembayaran.

**Melihat Riwayat Booking**

Menggunakan *request* : ```GET /booking/api/history/``` untuk mendapatkan daftar semua booking milik user yang login beserta detail lengkap setiap booking.

**Mengubah Booking**

Menggunakan *request* : ```PUT/PATCH /booking/api/<int:booking_id>/edit/``` untuk meng-update data booking yang sudah dibuat seperti anggota, tanggal pendakian, gunung, dan pilihan porter.

**Menghapus Booking**

Menggunakan *request* : ```POST /booking/api/delete/<int:booking_id>/``` untuk menghapus booking tertentu dari database.

**Membayar Booking**

Menggunakan *request* : ```POST /booking/api/payment/<int:booking_id>/``` untuk mengkonfirmasi pembayaran booking dan otomatis menambahkan gunung ke riwayat pendakian user.

**Mendapatkan Data Profil untuk Anggota**

Menggunakan *request* : ```GET /booking/api/profiles/``` untuk mendapatkan daftar profil user yang dapat ditambahkan sebagai anggota booking (dengan fitur search untuk mencari user berdasarkan username).

### News
**Daftar Berita** 

Menggunakan *request* GET `/news/json/` untuk mendapatkan seluruh daftar berita yang tersimpan di database untuk ditampilkan pada halaman utama.

**Status Pengguna**  

Menggunakan *request* GET `/news/user-status/` untuk memverifikasi apakah pengguna yang sedang login memiliki status Admin, guna memunculkan tombol akses khusus (tambah, edit, dan hapus).

**Like Berita**   

Menggunakan *request* POST `/news/like/<id>/` untuk memberikan like atau membatalkan like pada suatu berita berdasarkan ID-nya.

**Hapus Berita**  
Menggunakan *request* POST `/news/delete_flutter/<id>/` untuk menghapus berita tertentu dari database (mengembalikan respons JSON agar kompatibel dengan Flutter).

**Buat Berita**  

Menggunakan *request* POST `/news/create-flutter/` untuk mengirimkan data formulir berita baru dan menyimpannya ke database.

**Edit Berita**  

Menggunakan *request* POST `/news/edit-flutter/<id>/` untuk mengirimkan data perubahan pada berita yang sudah ada.

### Community
**Display Seluruh Event Community**

Mengambil daftar event menggunakan *request* ```GET /community/``` yang digunakan untuk menampilkan seluruh event pendakian yang tersedia.

**Display Detail Event**

Mengambil detail satu event berdasarkan ID menggunakan *request* ```GET /community/<int:pk>/``` untuk menampilkan informasi lengkap mengenai event tertentu.

**Create Event**

Membuat event baru menggunakan *request* ```POST /community/create/``` di mana pengguna mengirimkan data seperti judul, gunung, tanggal, kapasitas, dan informasi lain untuk membuat event pendakian.

**Edit Event**

Mengubah data event tertentu menggunakan *request* ```POST /community/<int:pk>/edit/``` yang digunakan untuk memperbarui informasi event, seperti tanggal, kapasitas, meeting point, atau status event.

# Link Design Figma
https://www.figma.com/design/b8m3mXxyvfu6rR8parXYCl/MountTrack?m=auto&t=dc2sdi3de19qInsX-6

# Download
[Download APK - Bitrise](https://app.bitrise.io/app/499ab3d3-61d0-4856-a336-573109b84659/installable-artifacts/cc8893c3cfcaf36f/public-install-page/33dd24afcf6d11ca4bf88c1e3d44809f) [![Build Status](https://app.bitrise.io/app/499ab3d3-61d0-4856-a336-573109b84659/status.svg?token=W1j_sA-FiDHVH2C576t0AA&branch=main)](https://app.bitrise.io/app/499ab3d3-61d0-4856-a336-573109b84659)

# Video Promosi
[Promosi MountTrack - YouTube](https://youtu.be/fRGn4gPK-HM)
