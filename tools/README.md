# Perintah PIDK

Semua perintah rutin ada di folder ini.

```bash
./tools/build.sh
./tools/status.sh
./tools/pull.sh
./tools/push.sh "pesan commit"
./tools/sync.sh "pesan commit"
```

## Alur harian yang disarankan

### Jika mengedit dari PC
1. Edit file di `Lembar_Kerja/` atau `Materi/Mxx/`.
2. Opsional: `./tools/build.sh`.
3. Jalankan `./tools/sync.sh "Revisi ..."`.
4. Di Overleaf: **Integrations > GitHub > Pull**.

### Jika mengedit dari Overleaf
1. Di Overleaf: **Integrations > GitHub > Push**.
2. Di PC: jalankan `./tools/sync.sh`.

GitHub menjadi titik temu antara PC dan Overleaf. Jangan mengedit baris yang sama secara bersamaan di PC dan Overleaf sebelum sinkronisasi selesai.
