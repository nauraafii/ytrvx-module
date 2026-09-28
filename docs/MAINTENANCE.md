# Pemeliharaan YTRVX

Ditinjau pada 28 September 2026. YTRVX tetap fork personal; builder berasal dari j-hc dan patch berasal dari Morphe. Perubahan di sini berfokus pada keandalan build dan kejelasan hasil.

## Bukti dan keputusan

| Temuan | Dasar | Keputusan |
| --- | --- | --- |
| Build 11 tidak mendapatkan APK YouTube 21.13.164, tetapi tetap menerbitkan Music. | [Log run 36422651695](https://github.com/nauraafii/ytrvx-module/actions/runs/36422651695): archive gagal, APKMirror 403, Uptodown 404. | Kegagalan target mengembalikan status gagal; publikasi memerlukan semua output. |
| APK versi tetap dapat hilang dari mirror. | URL archive 21.13.164 mengembalikan 404; [metadata archive](https://archive.org/metadata/jhc-apks) memuat 21.16.256 saat pemeriksaan. | Perbarui YouTube ke 21.16.256; jangan menganggap versi yang dikunci menjamin file selalu tersedia. |
| Dukungan stabil dan eksperimental berbeda. | [Morphe Patches v1.44.0](https://github.com/MorpheApp/morphe-patches/releases/tag/v1.44.0) menambahkan dukungan 21.16.256, sedangkan 21.38.123 ditandai eksperimental. | Pilih versi yang tidak ditandai eksperimental untuk konfigurasi rilis. Tetap lakukan uji perangkat. |
| Upstream membatasi build paralel karena masalah CLI. | [build.sh upstream](https://github.com/j-hc/revanced-magisk-module/blob/main/build.sh), diperiksa pada tanggal di atas. | Jalankan target berurutan; pertahankan `parallel-jobs = 1`. |
| File sementara unduhan gagal dapat menghambat fallback. | `_req` sebelumnya menunggu selama file sementara ada, sedangkan jalur gagal tidak membersihkannya. | Bersihkan file sementara pada kegagalan; pada builder berurutan, sisa unduhan terputus dapat dicoba ulang. |
| Pemeriksaan output cukup ringan untuk dijalankan tanpa patcher. | Python menyediakan `tomllib`, `pathlib`, `zipfile`, dan `unittest`. | Gunakan pustaka standar, tanpa paket tambahan. |

## Pilihan yang dibandingkan

- **Mengganti versi APK saja:** menyelesaikan input yang hilang saat ini, tetapi tidak mencegah rilis parsial berikutnya.
- **Menggunakan `auto` untuk semua aplikasi:** mengurangi pembaruan manual, tetapi pemilihan berbasis jumlah patch tidak menjamin ketersediaan APK atau membedakan dukungan eksperimental.
- **Menambah banyak mirror:** hanya berguna jika sumbernya dapat dipercaya dan formatnya terpelihara. Scraping tambahan membawa jalur kegagalan baru.
- **Versi eksplisit dan pemeriksaan rilis lengkap:** dipilih untuk perubahan ini. Trade-off: perlu review versi berkala, dan satu target gagal menahan seluruh rilis.

## Alur pembaruan

1. Baca release notes [Morphe Patches](https://github.com/MorpheApp/morphe-patches/releases) dan [Morphe Desktop](https://github.com/MorpheApp/morphe-desktop/releases). Bedakan versi stabil dan eksperimental.
2. Pastikan APK yang sesuai tersedia. HTTP 200 hanya menunjukkan endpoint merespons; tetap diperlukan pemeriksaan signature dan hasil patch.
3. Ubah konfigurasi dan jalankan `Check builder`. Untuk hasil yang dapat diulang, pin tag patch dan CLI bersama versi APK.
4. Jalankan build manual dari commit yang telah ditinjau. Build saat ini mengharapkan empat output Music dan dua output YouTube.
5. Uji instalasi/update, startup, login, dan pemutaran pada perangkat sebelum menyatakan rilis teruji. APK non-root dan modul root membutuhkan uji masing-masing.

## Prioritas berikutnya

Belum diimplementasikan karena membutuhkan validasi tambahan:

- **Input APK langsung dengan checksum dan verifikasi signature:** berguna jika mirror sering menghapus versi. Rujukan: [utils.sh upstream](https://github.com/j-hc/revanced-magisk-module/blob/main/utils.sh) kini memiliki sumber `direct`. Jangan sekadar mengunduh URL bebas tanpa memeriksa identitas APK.
- **Catatan input yang dapat direproduksi:** simpan versi patcher, bundle, SHA-256 APK sumber, dan commit dalam manifest rilis. Berguna setelah format keluaran CLI dan pemeriksaan identitas APK diuji.
- **Usulan pembaruan melalui pull request:** lebih terkontrol daripada mengganti `latest` otomatis. Memerlukan kebijakan versi stabil serta pemeriksaan kompatibilitas yang dapat diandalkan.

## Batas pemeriksaan

Tes offline memeriksa kebijakan rilis dan perilaku kegagalan unduhan; tes tersebut tidak menjalankan Morphe atau membuktikan APK berfungsi di Android. `zipfile.is_zipfile` memeriksa bentuk arsip dasar, bukan signature, integritas seluruh isi, atau perilaku aplikasi. Workflow build tetap harus dijalankan untuk validasi menyeluruh.

Referensi workflow: [GitHub job summaries](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-commands#adding-a-job-summary), [pemicu workflow](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow), dan [prasyarat Morphe Desktop](https://github.com/MorpheApp/morphe-desktop#prerequisites).
