# Pemrograman untuk Ilmu Data dan Komputasi

Repository bahan kuliah MA25-21008.

Struktur utama:

```text
Lembar_Kerja/
  lembar_kerja_PIDK.tex
  lembar_kerja_PIDK.pdf

Materi/
  M01/
    slides_M01.tex
    slides_M01.pdf
    assets/
  M02/
  M03/
  ...

tools/
  build.sh
  sync.sh
  pull.sh
  push.sh
  status.sh
```

PDF hasil compile selalu berada di folder yang sama dengan dokumen `.tex` utama.

Perintah rutin:

```bash
sh tools/build.sh
sh tools/sync.sh "Revisi materi"
sh tools/pull.sh
sh tools/push.sh "Pesan commit"
sh tools/status.sh
```

Alur sinkronisasi:

```text
PC <-> GitHub <-> Overleaf
```

Jika edit dilakukan di Overleaf: lakukan GitHub Push dari Overleaf. Setelah perubahan masuk GitHub, GitHub Actions otomatis compile dan memperbarui PDF di folder yang sama dengan `.tex`.

## Materi tambahan

- `Materi/M02/slides_M02.tex`: Pertemuan 2, Fungsi dan Struktur Kontrol.
- `Materi/M02/slides_M02.pdf`: hasil compile Pertemuan 2.
