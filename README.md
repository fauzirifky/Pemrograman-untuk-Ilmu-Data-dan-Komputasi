# Pemrograman untuk Ilmu Data dan Komputasi

Repository bahan kuliah **MA25-21008**.

## Struktur

```text
.
├── Lembar_Kerja/
│   ├── lembar_kerja_PIDK.tex
│   └── itera_logo.png
├── Materi/
│   └── M01/
│       ├── slides_M01.tex
│       └── assets/
├── generated/
├── tools/
└── .github/workflows/
```

Untuk M02 dan seterusnya, gunakan pola sederhana:

```text
Materi/M02/slides_M02.tex
Materi/M03/slides_M03.tex
...
```

## Perintah utama

```bash
./tools/build.sh
./tools/sync.sh "pesan commit"
```

Semua perintah lain ada di `tools/README.md`.

## Overleaf

Repository ini dirancang dengan **GitHub sebagai hub**:

```text
PC <-> GitHub <-> Overleaf
```

Buat project Overleaf dengan **Import from GitHub** dari repository ini. Setelah terhubung:

- perubahan PC: jalankan `./tools/sync.sh`, lalu klik **Pull** pada integrasi GitHub di Overleaf;
- perubahan Overleaf: klik **Push** ke GitHub, lalu jalankan `./tools/sync.sh` di PC.

Overleaf GitHub Synchronization memang memerlukan trigger Pull/Push dari antarmuka Overleaf; tidak ada sinkronisasi real-time otomatis untuk edit yang belum dipush.
