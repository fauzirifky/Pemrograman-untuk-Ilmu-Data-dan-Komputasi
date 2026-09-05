# Pemrograman untuk Ilmu Data dan Komputasi

Repository bahan kuliah MA25-21008.

```text
Lembar_Kerja/
Materi/
  M01/
  M02/
  ...
generated/
tools/
```

Perintah rutin:

```bash
bash tools/build.sh
bash tools/sync.sh "Revisi materi"
bash tools/pull.sh
bash tools/push.sh "Pesan commit"
bash tools/status.sh
```

`generated/` berisi PDF hasil compile dan ikut disimpan di GitHub.
Setiap push ke `main`, termasuk push dari Overleaf, memicu GitHub Actions untuk compile ulang PDF dan memperbarui `generated/`.

Alur dua arah:

```text
PC <-> GitHub <-> Overleaf
```

Overleaf tetap membutuhkan tombol GitHub Pull/Push. GitHub Actions hanya menangani build otomatis setelah sebuah perubahan sudah masuk GitHub.
