import 'package:flutter/material.dart';

abstract class AppColors {
  // --- ATURAN 60-30-10 ---

  // 60% - DOMINAN (Latar Belakang & Area Utama)
  static const Color background = Color(0xFFF8FAFC); // Slate 50 (Clean cool white)
  static const Color surface = Color(0xFFFFFFFF);    // Kartu, Modal, & Dialog

  // 30% - SEKUNDER / BRAND (Biru Cerah tapi Tetap Kontras)
  static const Color primary = Color(0xFF0284C7);      // Sky 600 (Aman untuk teks/ikon putih)
  static const Color primaryLight = Color(0xFFE0F2FE); // Sky 100 (Sangat cocok untuk chip/highlight)

  // 10% - AKSEN (Call-To-Action yang menonjol)
  static const Color accent = Color(0xFFF97316);       // Orange 500 (Kontras tinggi & hangat di atas biru)

  // --- WARNA NETRAL (Agar Visual Tidak Kaku/Tabrakan) ---
  static const Color textPrimary = Color(0xFF1E293B);   // Slate 800 (Lebih lembut dari hitam pekat)
  static const Color textSecondary = Color(0xFF64748B); // Slate 500 (Sub-title, caption, hint)
  static const Color textDisabled = Color(0xFF94A3B8);  // Slate 400 (Placeholder/tombol mati)
  static const Color border = Color(0xFFE2E8F0);        // Slate 200 (Garis pembatas halus)

  // --- WARNA PENDUKUNG / STATUS (Harmonis dengan Primary) ---
  static const Color success = Color(0xFF10B981); // Emerald 500 (Hijau zamrud, lebih menyatu dengan biru)
  static const Color warning = Color(0xFFF59E0B); // Amber 500 (Peringatan)
  static const Color danger = Color(0xFFEF4444);  // Red 500 (Error / Hapus)
  static const Color info = Color(0xFF3B82F6);    // Blue 500 (Informasi)
}
