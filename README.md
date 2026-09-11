# YTRVX

[![Build Modules](https://github.com/nauraafii/ytrvx-module/actions/workflows/build.yml/badge.svg)](https://github.com/nauraafii/ytrvx-module/actions/workflows/build.yml)
[![Latest release](https://img.shields.io/github/v/release/nauraafii/ytrvx-module?label=release)](https://github.com/nauraafii/ytrvx-module/releases/latest)
[![License](https://img.shields.io/github/license/nauraafii/ytrvx-module)](LICENSE)

YTRVX adalah fork personal dari [j-hc/revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module) yang mengotomatiskan build YouTube dan YouTube Music dengan Morphe Patches. Dari satu konfigurasi, repositori ini menghasilkan APK non-root dan modul ZIP untuk Magisk atau KernelSU.

> YTRVX bukan aplikasi resmi YouTube, Google, Morphe, atau j-hc.

## Asal proyek dan cakupan perubahan

YTRVX dibuat untuk penggunaan pribadi. Perubahan saya berfokus pada konfigurasi build—seperti aplikasi, versi, arsitektur, dan mode build—serta dokumentasi dan penyesuaian workflow sederhana.

Proyek ini bukan patcher baru dan tidak bertujuan menggantikan proyek asal. Untuk perubahan inti builder, template modul, atau masalah umum patching, lihat [j-hc/revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module) dan dokumentasi upstream terkait.

| Komponen | Keterangan |
| --- | --- |
| [`config.toml`](config.toml) | Input build yang dikunci per aplikasi. |
| [`build.sh`](build.sh) dan [`utils.sh`](utils.sh) | Mengunduh input, menjalankan patcher, menandatangani APK, dan membuat modul. |
| [Build Modules](.github/workflows/build.yml) | Build rilis manual dan penerbitan asset GitHub Release. |
| [CI](.github/workflows/ci.yml) | Pemeriksaan terjadwal atas perubahan input upstream sebelum menjalankan build. |

## Unduh dan pasang

Ambil file hanya dari [Latest release](https://github.com/nauraafii/ytrvx-module/releases/latest).

| Kebutuhan | Pilih file | Catatan |
| --- | --- | --- |
| Perangkat tanpa root | Berkas `.apk` | Memerlukan implementasi GmsCore yang sesuai untuk login Google. Pakai [MicroG](https://github.com/ReVanced/GmsCore/releases) atau [MicroG-RE](https://github.com/MorpheApp/MicroG-RE/releases) |
| Perangkat dengan root | Berkas `-magisk-*.zip` | Pasang melalui manager root yang mendukung modul Magisk/KernelSU. |
| Kompatibilitas ABI | Nama berakhiran `all`, `arm64-v8a`, atau `arm-v7a` | `all` adalah build multi-ABI; `both` pada konfigurasi menghasilkan dua asset ABI terpisah. |

Sebelum memasang:

1. Cocokkan nama aplikasi, versi, dan ABI dengan perangkat serta kebutuhan Anda.
2. Jika rilis menyediakan `SHA256SUMS.txt`, bandingkan hash SHA-256 file yang diunduh dengan entri nama file yang sama. Di PowerShell gunakan `Get-FileHash .\nama-file.apk -Algorithm SHA256`; di Linux/Termux gunakan `sha256sum nama-file.apk`.
3. APK dengan signature berbeda tidak dapat menggantikan pemasangan yang sudah ada. Uninstall APK yang konflik hanya setelah mencadangkan data yang diperlukan, karena data aplikasi dapat ikut terhapus.

## Build dan konfigurasi

Konfigurasi harian dijelaskan di [CONFIG.md](CONFIG.md). Panduan build lokal, signing key, secret GitHub Actions, dan helper Termux tersedia di [BUILDING.md](BUILDING.md).

Untuk membuat rilis dari GitHub Actions:

1. Review perubahan pada [`config.toml`](config.toml), terutama versi aplikasi dan versi bundle patch.
2. Buka workflow [Build Modules](https://github.com/nauraafii/ytrvx-module/actions/workflows/build.yml), pilih branch `main`, lalu jalankan **Run workflow**.
3. Tinjau log build dan asset pada halaman Release sebelum dibagikan.

Workflow manual ini digunakan untuk rilis: prosesnya membutuhkan signing secret dan dapat membuat atau memperbarui GitHub Release. Gunakan branch `main` yang sudah ditinjau, bukan sebagai lingkungan eksperimen.

## Batasan dan dukungan

- Kompatibilitas tidak dijamin. Versi aplikasi yang didukung berubah mengikuti [daftar patch Morphe](https://github.com/MorpheApp/morphe-patches#-patches-list).
- Masalah pada patch tertentu, GmsCore, atau aplikasi upstream sebaiknya diperiksa lebih dulu melalui dokumentasi dan issue tracker upstream. Issue YTRVX digunakan untuk masalah builder, konfigurasi repositori, workflow, atau aset rilis.

## Referensi upstream

- [Morphe Desktop](https://github.com/MorpheApp/morphe-desktop): CLI/GUI patcher, kebutuhan Java 21+, dan format input patch.
- [Morphe Patches](https://github.com/MorpheApp/morphe-patches): bundle patch serta daftar aplikasi dan versi yang didukung.
- [MicroG-RE](https://github.com/MorpheApp/MicroG-RE): implementasi GmsCore yang digunakan oleh aplikasi hasil patch non-root.
- [j-hc/revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module): dasar builder dan template modul.
- [GitHub Docs — manually running a workflow](https://docs.github.com/actions/managing-workflow-runs/manually-running-a-workflow): cara menjalankan workflow secara manual.
