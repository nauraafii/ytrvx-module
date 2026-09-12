# Konfigurasi YTRVX

[`config.toml`](config.toml) adalah kontrak build YTRVX: ia menentukan aplikasi sumber, bundle patch, versi, ABI, dan jenis output. Builder membaca nilai global lebih dahulu, lalu nilai dalam tabel aplikasi; nilai per aplikasi akan menggantikan nilai global yang sama.

Gunakan [BUILDING.md](BUILDING.md) untuk lingkungan build dan signing. Dokumentasi ini hanya menjelaskan konfigurasi.

## Alur perubahan yang aman

1. Buat branch dan salin `config.toml` sebelum mengubah nilai.
2. Ubah satu kelompok kecil nilai, misalnya hanya `version` atau `build-mode`.
3. Untuk perubahan patch kustom, tetapkan versi aplikasi yang eksplisit dan cek [versi yang didukung upstream](https://github.com/MorpheApp/morphe-patches#-patches-list).
4. Jalankan build, baca `build.md` dan log workflow, lalu uji aset pada perangkat yang sesuai.
5. Baru gunakan konfigurasi tersebut untuk rilis berikutnya.

## Nilai global

Nilai ini dapat ditaruh di bagian paling atas `config.toml` dan menjadi default untuk semua tabel aplikasi.

| Opsi | Nilai / perilaku | Kapan diubah |
| --- | --- | --- |
| `enable-magisk-update` | `true` atau `false`. Saat build GitHub, URL update modul dibuat dari repository ini. Build lokal menonaktifkannya. | Matikan bila fork tidak ingin modul mengecek update. |
| `parallel-jobs` | Jumlah build paralel. | Gunakan `1` pada perangkat atau runner dengan RAM terbatas. |
| `module-author` | Nama pada metadata modul. | Untuk branding fork sendiri. |
| `rv-brand` | Brand pada nama output dan metadata. | Pertahankan brand yang berbeda dari upstream. |
| `patches-source` / `patches-version` | Repository dan tag/ref bundle Morphe `.mpp`. | Pin ke tag yang sudah Anda review; hindari bergerak ke `latest` tanpa pengujian. |
| `cli-source` / `cli-version` | Repository dan tag/ref JAR Morphe Desktop. | Ubah bersamaan dengan review kompatibilitas bundle patch. |
| `dpi` | Urutan DPI yang dicoba saat mengambil APK dari sumber tertentu. | Hanya bila sumber APK menyediakan varian DPI berbeda. |
| `compression-level` | Tingkat ZIP `0`–`9`. | Turunkan untuk build lebih cepat, naikkan untuk ZIP lebih kecil. |
| `remove-rv-integrations-checks` | Harus `false` untuk bundle Morphe `.mpp` yang dipakai fork ini. | Jangan aktifkan kecuali kode builder dan format bundle sudah berubah serta diuji. |

## Nilai per aplikasi

Setiap blok seperti `[YouTube-Extended]` atau `[Music-Extended]` adalah satu target build.

| Opsi | Nilai / perilaku | Catatan penting |
| --- | --- | --- |
| `enabled` | `true` atau `false`. | Hanya target aktif yang dibangun. |
| `app-name` | Nama yang dipakai pada output. | Tidak harus sama dengan nama tabel. |
| `build-mode` | `apk`, `module`, atau `both`. | `apk` untuk non-root; `module` untuk ZIP root; `both` membuat keduanya. |
| `version` | Versi eksplisit, `auto`, `latest`, atau `beta`. | Lihat bagian [Pemilihan versi](#pemilihan-versi). |
| `arch` | `all`, `arm64-v8a`, `arm-v7a`, atau `both`. | `both` menjalankan dua build ABI terpisah; `all` meminta build multi-ABI. |
| `uptodown-dlurl`, `apkmirror-dlurl`, `archive-dlurl` | URL sumber aplikasi. | Setidaknya satu diperlukan. Builder mencoba sumber yang tersedia bila satu sumber gagal. |
| `included-patches` / `excluded-patches` | Daftar nama patch yang dipaksa aktif/nonaktif. | Nama patch harus diapit tanda kutip; gunakan versi aplikasi eksplisit. |
| `exclusive-patches` | `true` hanya memakai patch yang dipilih. | Risiko tinggi: konfigurasi default yang diperlukan dapat tidak ikut. |
| `include-stock` | Menyertakan APK stok ke ZIP modul; default `true`. | Lebih tahan untuk pemasangan modul, tetapi ZIP lebih besar. |
| `module-author` | Override penulis khusus target. | Tidak mengubah target lain. |
| `riplib` | `false` mematikan penghapusan library ABI. | Builder hanya menggunakan optimasi ini bila CLI mendukung `rip-lib`. |
| `patcher-args` | Argumen tambahan yang diteruskan ke Morphe CLI. | Gunakan hanya setelah memeriksa dokumentasi CLI upstream. |
| `module-prop-name` | ID modul Magisk. | Jangan ganti setelah modul dipasang bila ingin jalur update tetap sama. |

## Pemilihan versi

| Nilai | Perilaku builder | Rekomendasi |
| --- | --- | --- |
| Versi eksplisit, misalnya `"21.13.164"` | Builder memaksa patcher menggunakan versi tersebut. | Pilihan paling dapat diulang untuk rilis. |
| `auto` | Memilih versi tertinggi yang didukung patch default. | Aman untuk konfigurasi tanpa pilihan patch khusus. |
| `latest` | Memilih versi stabil tertinggi dari sumber APK dan memaksa patching. | Hanya untuk eksperimen yang siap gagal bila belum kompatibel. |
| `beta` | Memilih versi beta tertinggi dari sumber APK dan memaksa patching. | Paling berisiko; bukan pilihan rilis rutin. |

`auto` sengaja ditolak bila `included-patches`, `excluded-patches`, atau `exclusive-patches` dipakai. Setel versi eksplisit yang muncul dalam daftar versi yang didukung upstream agar perubahan patch dapat direproduksi dan ditinjau.

## Contoh minimal

Contoh berikut membangun YouTube non-root saja, memakai versi eksplisit dan build multi-ABI:

```toml
[YouTube-Extended]
enabled = true
app-name = "YouTube"
build-mode = "apk"
version = "21.13.164"
arch = "all"
patches-source = "MorpheApp/morphe-patches"
patches-version = "v1.42.0"
cli-source = "MorpheApp/morphe-desktop"
cli-version = "v1.15.1"
apkmirror-dlurl = "https://www.apkmirror.com/apk/google-inc/youtube"
uptodown-dlurl = "https://youtube.en.uptodown.com/android"
archive-dlurl = "https://archive.org/download/jhc-apks/apks/com.google.android.youtube"
```

Contoh ini hanya menunjukkan bentuk konfigurasi. Sebelum memakai versi atau tag baru, konfirmasikan bahwa kombinasi aplikasi dan patch masih didukung oleh [Morphe Patches](https://github.com/MorpheApp/morphe-patches).

## Patch kustom

Nama patch diteruskan ke CLI, sehingga ejaan harus persis seperti daftar patch upstream. Jika nama mengandung tanda petik tunggal, tulis dua kali di TOML, misalnya `Hide ''Get Music Premium''`.

Mulai dari perubahan kecil: tetapkan satu patch, pin versi aplikasi dan bundle, build, lalu baca hasilnya. Jangan memasukkan atau mengecualikan patch GmsCore/microG secara manual; builder menentukan perlakuannya berbeda untuk mode non-root dan root.

## Referensi

- [Morphe Patches — daftar patch dan versi yang didukung](https://github.com/MorpheApp/morphe-patches#-patches-list)
- [Morphe Desktop — CLI, JAR, dan dokumentasi](https://github.com/MorpheApp/morphe-desktop)
- [Konfigurasi aktif di fork ini](config.toml)
