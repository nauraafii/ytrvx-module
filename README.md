# YTRVX

YTRVX adalah tempatku mengatur build YouTube dan YouTube Music dengan [Morphe Patches](https://github.com/MorpheApp/morphe-patches). Proyek ini berasal dari fork [j-hc/revanced-magisk-module](https://github.com/j-hc/revanced-magisk-module). Saya menyesuaikan konfigurasi untuk kebutuhan pribadi, merapikan dokumentasi, dan memperbaiki beberapa bagian alur build. Patcher dan template modulnya tetap berasal dari proyek asal.

## Hasil Build

File ada di halaman [Releases](https://github.com/nauraafii/ytrvx-module/releases). Pilih `.apk` untuk perangkat tanpa root atau `.zip` untuk modul Magisk/KernelSU. Cocokkan juga nama aplikasi dan arsitektur (`all`, `arm64-v8a`, atau `arm-v7a`) dengan perangkatmu.

APK tanpa root memerlukan [GmsCore](https://github.com/ReVanced/GmsCore/releases) atau [MicroG-RE](https://github.com/MorpheApp/MicroG-RE/releases) jika ingin login. Bila signature APK berbeda dari versi yang sudah terpasang, pembaruan tidak akan berhasil; cadangkan data sebelum menghapus aplikasi lama.

## Build Manual

Ubah [`config.toml`](config.toml), lalu jalankan workflow [Build Modules](https://github.com/nauraafii/ytrvx-module/actions/workflows/build.yml) dari branch `main`. Periksa log dan file rilis setelah build selesai. Repo ini memerlukan signing key milikmu sendiri; langkahnya ada di [panduan build](BUILDING.md).

Untuk opsi konfigurasi, lihat [CONFIG.md](CONFIG.md). Alasan perubahan dan catatan pemeliharaan ada di [MAINTENANCE.md](docs/MAINTENANCE.md).

Ini proyek pribadi, bukan aplikasi resmi Google, Morphe, atau j-hc.
