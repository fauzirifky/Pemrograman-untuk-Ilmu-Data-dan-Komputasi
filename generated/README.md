# generated

Folder ini adalah keluaran build lokal. Jalankan:

```bash
./tools/build.sh
```

Hasil akan muncul sebagai:

```text
generated/
├── Lembar_Kerja/
│   └── lembar_kerja_PIDK.pdf
└── Materi/
    ├── M01/
    │   └── slides_M01.pdf
    └── ...
```

PDF hasil build sengaja tidak di-commit ke Git agar repository dan sinkronisasi Overleaf tetap ringan. GitHub Actions juga menghasilkan PDF sebagai artifact setiap ada push.
