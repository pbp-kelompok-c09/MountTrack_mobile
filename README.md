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
- **News**: Menyajikan berita terkini seputar gunung, kebijakan pendakian, kondisi jalur, hingga informasi menarik lainnya yang relevan bagi pendaki. (Ryan Gibran Purwcakra Sihaloho)
- **Community**: Informasi mengenai event pendaki gunung seperti melakukan pendakian bersama (open trip). (Dibrienna Rauseuky Ramadhan)

# Peran Pengguna
- **Belum Login**: Dapat melihat halaman homepage, berita, dan profile page dengan data yang terbatas.
- **Login sebagai User**: Dapat membuat booking pendakian, membuat post komunitas baru, melengkapi profil, melihat profil orang lain, melihat berita, dan melihat list informasi gunung.
- **Login sebagai Admin**: Dapat merubah status kesediaan gunung, membuat berita baru, dan akses admin portal.

# Alur Pengintegrasian dengan *web service*
## Autentikasi
**Login**
- Membuat sesi user: ```POST /userprofile/loginapp``` untuk mengautentikasi user dengan username dan password yang diisi pengguna.

**Register**
- Membuat akun baru: ```POST /userprofile/registerapp``` untuk mengirimkan data pengguna dan membuat akun baru.

**Logout**
- ```POST /userprofile/logoutapp``` untuk mengakhiri sesi pengguna.

## List Gunung
--

## Booking
--

## News
Fitur ini memungkinkan pengguna untuk mendapatkan informasi terkini seputar pendakian gunung. Pengguna dapat melihat daftar berita, membaca detail berita secara lengkap, dan memberikan apresiasi melalui tombol like. Admin memiliki kontrol penuh untuk mengelola konten berita yang ditampilkan.

Alur pengintegrasian dengan web service :

User (Pengguna Login):
1. Melihat Daftar Berita: GET /news/ untuk mengambil dan menampilkan seluruh daftar berita yang tersedia, lengkap dengan judul, thumbnail, tanggal, dan jumlah like.
2. Melihat Detail Berita: GET /news/{id}/ untuk masuk ke halaman detail dan membaca konten berita secara keseluruhan beserta gambar tambahannya.
3. Like Berita: POST /news/like/{id}/ untuk memberikan like pada berita yang disukai atau membatalkan like (unlike).

Admin:
1. Membuat Berita: POST /news/create-news/ untuk mengunggah berita baru dengan mengisi judul, konten, dan menyertakan gambar.
2. Edit Berita: POST /news/edit-news/{id}/ untuk memperbarui informasi pada berita yang sudah ada jika terjadi kesalahan atau pembaruan informasi.
3. Hapus Berita: POST /news/delete/{id}/ untuk menghapus berita yang sudah tidak relevan dari database.

## Community
--

# Link Design Figma
https://www.figma.com/design/b8m3mXxyvfu6rR8parXYCl/MountTrack?m=auto&t=dc2sdi3de19qInsX-6

