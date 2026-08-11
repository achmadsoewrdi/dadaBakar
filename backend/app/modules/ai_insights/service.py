import json
import logging
import statistics
from typing import List, Optional, Tuple

from app.core.config import settings
from app.modules.ai_insights.limiter import groq_limiter
from app.modules.ai_insights.schemas import (
    AnomalyDetail,
    MetricsSummary,
    SensorDataAnalysisRequest,
    SensorDataAnalysisResponse,
)

logger = logging.getLogger(__name__)


def _generate_groq_insights(
    sensor_name: str,
    unit: str,
    status: str,
    metrics: MetricsSummary,
    anomalies: List[AnomalyDetail],
    context: Optional[str] = None,
    stem_subject: str = "Sistem Embedded & IoT",
) -> Optional[Tuple[str, List[str]]]:
    """Menggunakan Groq Cloud API dengan Persona Asisten Lab STEM yang dispesialisasi berdasarkan disiplin ilmu."""
    if not settings.GROQ_API_KEY:
        return None

    # 1. Check Rate Limiter (Proteksi Kredit Free Tier)
    allowed, reason = groq_limiter.allow_request(
        max_rpm=settings.GROQ_MAX_REQUESTS_PER_MINUTE,
        max_rpd=settings.GROQ_MAX_REQUESTS_PER_DAY,
    )
    if not allowed:
        logger.warning(f"Groq Rate Limiter Active: {reason}")
        return None

    anomaly_summary = [f"Index {a.index}: Nilai={a.value} ({a.reason})" for a in anomalies[:10]]
    unit_str = f" {unit}" if unit else ""

    prompt = f"""
Kamu adalah Asisten Laboratorium {stem_subject} Senior yang berpengalaman, analitis, dan edukatif.
Tugas utamamu adalah membantu siswa/mahasiswa dalam menganalisis data sensor, menarik kesimpulan ilmiah mendalam, dan membimbing troubleshooting berbasis teori disiplin ilmu **{stem_subject}**.

**Konteks Sistem:**
Data yang kamu terima telah melalui agregasi statistik dasar dari router `analyze-sensor`. Tugasmu bukan sekadar mengulang angka, melainkan memberikan interpretasi analitis tingkat tinggi, mendeteksi pola saintifik, serta menjelaskan korelasi ilmiah nyata di balik data sesuai sudut pandang **{stem_subject}**.

**Data Input Sensor:**
- Nama Sensor: {sensor_name}
- Satuan: {unit or 'tanpa satuan'}
- Konteks Pengujian: {context or f'Praktikum {stem_subject}'}
- Status Kondisi: {status.upper()}
- Statistik Data Agregasi:
  * Jumlah Sampel: {metrics.count}
  * Nilai Rata-rata (Mean): {metrics.mean}{unit_str}
  * Nilai Minimum: {metrics.min}{unit_str}
  * Nilai Maksimum: {metrics.max}{unit_str}
  * Rentang Nilai (Range): {metrics.range}{unit_str}
  * Deviasi Standar: {metrics.std_dev}{unit_str}
  * Nilai Tengah (Median): {metrics.median}{unit_str}
- Jumlah Anomali Terdeteksi: {len(anomalies)}
- Detail Sampel Anomali: {json.dumps(anomaly_summary, ensure_ascii=False)}

**Panduan Analisis Khusus Berdasarkan Disiplin Ilmu {stem_subject}:**
- **Jika FISIKA**: Hubungkan fluktuasi/anomali data dengan hukum-hukum fisis (misal: Hukum Termodinamika, konduktivitas/resistivitas, transfer energi kalor, Hukum Ohm, gelombang/optik, gaya fisis, atau disipasi daya).
- **Jika MATEMATIKA**: Fokus pada interpretasi data kuantitatif & statistika (misal: perbandingan mean vs median untuk melihat kemencengan/skewness data, signifikansi deviasi standar terhadap dispersi, analisis pola tren linier/periodik, dan probabilitas outlier).
- **Jika BIOLOGI**: Hubungkan data sensor dengan proses biologis organisme & lingkungan (misal: laju fotosintesis, transpirasi stomata, respirasi seluler, aktivitas mikroba tanah, homeostasis, adaptasi lingkungan, atau faktor pembatas biotik/abiotik).
- **Jika KIMIA**: Hubungkan data dengan kinetika dan kesetimbangan kimia (misal: derajat keasaman pH / ion H+, reaksi eksoterm/endoterm, larutan penyangga/buffer, konsentrasi ion nutrisi NPK/EC, titrasi, atau laju oksidasi).
- **Jika SISTEM EMBEDDED / IOT / ROBOTIKA**: Hubungkan dengan integritas sinyal elektrik (noise ADC, drop tegangan baterai/voltage sag, latensi bus I2C/SPI, filter sinyal, ripple voltage, atau kalibrasi offset sensor).

**Instruksi Format Output (Wajib Terstruktur & Edukatif):**
1. **Summary (Minimal 2-3 Paragraf Mendalam)**:
   - Paragraf 1: Ringkasan metrik utama, tren stabilitas data, dan perbandingan nilai ekstrem.
   - Paragraf 2: Analisis mendalam mengenai *MENGAPA* fenomena tersebut terjadi berdasarkan hukum/teori ilmiah **{stem_subject}**.
   - Paragraf 3: Penjelasan spesifik mengenai penyebab dan implikasi anomali/outlier yang terdeteksi terhadap pengujian.
2. **Recommendations (3 Langkah Aksi Konkret)**:
   - Berikan rekomendasi langkah praktis yang dapat langsung dieksekusi siswa di laboratorium (misal: kalibrasi instrumen, koreksi variabel eksperimen, penyesuaian hardware/software, atau tindakan preventif).

Format Balasan HARUS berupa JSON valid dengan struktur persis berikut:
{{
  "summary": "Tuliskan ringkasan metrik dan analisis ilmiah mendalam (2-3 paragraf komprehensif) sesuai teori {stem_subject}.",
  "recommendations": [
    "Langkah 1: [Tindakan pemeriksaan peralatan / instrumen]",
    "Langkah 2: [Tindakan penyesuaian variabel praktikum / metode ilmiah]",
    "Langkah 3: [Tindakan evaluasi / pencegahan teknis]"
  ]
}}
"""

    # 2. Pemanggilan via SDK Groq jika terinstall
    try:
        from groq import Groq

        client = Groq(api_key=settings.GROQ_API_KEY)
        model_name = settings.GROQ_MODEL or "llama-3.3-70b-versatile"
        completion = client.chat.completions.create(
            model=model_name,
            messages=[{"role": "user", "content": prompt}],
            response_format={"type": "json_object"},
            temperature=0.2,
        )
        raw_text = completion.choices[0].message.content
        res_json = json.loads(raw_text)
        summary = res_json.get("summary")
        recommendations = res_json.get("recommendations", [])
        if summary and isinstance(recommendations, list):
            return summary, recommendations
    except Exception as e:
        logger.warning(f"Groq SDK Call Failed ({e}). Mencoba fallback HTTP REST API...")

    # 3. Fallback via HTTP REST API (OpenAI Compatible)
    try:
        import requests

        model_name = settings.GROQ_MODEL or "llama-3.3-70b-versatile"
        url = "https://api.groq.com/openai/v1/chat/completions"
        headers = {
            "Authorization": f"Bearer {settings.GROQ_API_KEY}",
            "Content-Type": "application/json",
        }
        payload = {
            "model": model_name,
            "messages": [{"role": "user", "content": prompt}],
            "response_format": {"type": "json_object"},
            "temperature": 0.2,
        }
        res = requests.post(url, headers=headers, json=payload, timeout=10)
        if res.status_code == 200:
            data = res.json()
            raw_text = data["choices"][0]["message"]["content"]
            res_json = json.loads(raw_text)
            summary = res_json.get("summary")
            recommendations = res_json.get("recommendations", [])
            if summary and isinstance(recommendations, list):
                return summary, recommendations
        else:
            logger.warning(f"Groq HTTP API Error {res.status_code}: {res.text}")
    except Exception as e:
        logger.warning(f"Groq HTTP Call Failed: {e}.")

    return None


def _get_fallback_stem_insights(
    stem_subject: str,
    sensor_name_str: str,
    unit_str: str,
    status: str,
    count: int,
    metrics: MetricsSummary,
    anomalies: List[AnomalyDetail],
    context_info: str,
) -> Tuple[str, List[str]]:
    """Menghasilkan analisis fallback rule-based yang disesuaikan dengan subjek STEM."""
    subject_lower = stem_subject.lower()

    if "kimia" in subject_lower:
        topic_desc = f"reaksi kimia dan kesetimbangan larutan pada {sensor_name_str}"
        rec_1 = "Lakukan kalibrasi ulang probe sensor kimia menggunakan larutan buffer standar."
        rec_2 = "Periksa konsentrasi larutan reaktan dan pastikan wadah reaksi dalam kondisi homogen."
        rec_3 = "Waspadai perubahan suhu lingkungan yang dapat menggeser kesetimbangan kimiawi."
    elif "biologi" in subject_lower:
        topic_desc = f"kondisi lingkungan biologis dan aktivitas metabolisme spesimen pada {sensor_name_str}"
        rec_1 = "Evaluasi faktor pembatas lingkungan (seperti aerasi, kelembapan, dan intensitas cahaya)."
        rec_2 = "Pastikan media tumbuh tanaman atau kultur mikroba terlindung dari stres lingkungan ekstrem."
        rec_3 = "Lakukan pencatatan berkala terhadap respon fisiologis spesimen terhadap fluktuasi sensor."
    elif "fisika" in subject_lower:
        topic_desc = f"fenomena fisis, transfer energi, dan karakteristik pengukuran {sensor_name_str}"
        rec_1 = "Periksa isolasi termal, hambatan koneksi, dan stabilitas instrumen fisis pengujian."
        rec_2 = "Verifikasi hukum-hukum fisis terkait (Hukum Ohm / Termodinamika) terhadap lonjakan nilai."
        rec_3 = "Pastikan sensor terlindung dari gangguan interferensi mekanik atau elektromagnetik."
    elif "matematika" in subject_lower:
        topic_desc = f"distribusi statistika, dispersi data, dan pola tren kuantitatif {sensor_name_str}"
        rec_1 = "Lakukan pembersihan data (data cleaning) terhadap titik pencilan (outlier) yang teridentifikasi."
        rec_2 = "Tingkatkan ukuran sampel (sample size) untuk meningkatkan derajat signifikansi statistika."
        rec_3 = "Gunakan metode Moving Average atau regresi untuk memodelkan tren data secara berkelanjutan."
    else:
        topic_desc = f"integritas sistem hardware dan akuisisi data sensor {sensor_name_str}"
        rec_1 = "Periksa sambungan kabel jumper, pin header, dan stabilitas tegangan suplai VCC/GND."
        rec_2 = "Lakukan verifikasi kalibrasi offset sensor pada firmware mikrokontroler."
        rec_3 = "Terapkan digital filtering (Moving Average Filter) pada program pembacaan sensor."

    if status == "normal":
        summary = (
            f"📊 [Analisis Asisten Lab {stem_subject} - Fallback System]\n\n"
            f"Berdasarkan pengujian {topic_desc}{context_info}, kondisi sistem terpantau STABIL dan berada pada batas aman operasional. "
            f"Dari total {count} sampel data, nilai rata-rata tercatat {metrics.mean}{unit_str} dengan median {metrics.median}{unit_str} "
            f"dan deviasi standar {metrics.std_dev}{unit_str}. Rentang data berada pada interval [{metrics.min}{unit_str} - {metrics.max}{unit_str}] "
            f"tanpa adanya penyimpangan signifikan."
        )
        recommendations = [
            f"Kondisi {sensor_name_str} dalam keadaan optimal untuk praktikum {stem_subject}.",
            rec_1,
            rec_3,
        ]
    elif status == "warning":
        summary = (
            f"⚠️ [Analisis Asisten Lab {stem_subject} - Fallback System]\n\n"
            f"Terdeteksi potensi penyimpangan pada {topic_desc}{context_info}. "
            f"Sebanyak {len(anomalies)} dari {count} titik data mengalami deviasi dari batas normal dengan nilai rata-rata {metrics.mean}{unit_str} "
            f"dan deviasi standar {metrics.std_dev}{unit_str}. Pola ini mengindikasikan adanya gangguan awal pada variabel praktikum {stem_subject}."
        )
        recommendations = [rec_1, rec_2, rec_3]
    else:  # critical
        summary = (
            f"🚨 [Analisis Asisten Lab {stem_subject} - Fallback System]\n\n"
            f"PERHATIAN SISWA: Terdeteksi KONDISI KRITIS pada {topic_desc}{context_info}! "
            f"Sebanyak {len(anomalies)} anomali signifikan teridentifikasi dengan nilai puncak mencapai {metrics.max}{unit_str} (Rata-rata: {metrics.mean}{unit_str}). "
            f"Penyimpangan ekstrem ini menunjukkan adanya anomali nyata yang memerlukan evaluasi segera sesuai prosedur laboratorium {stem_subject}."
        )
        recommendations = [
            f"SEGERA evaluasi eksperimen dan periksa kondisi fisik instrumen {sensor_name_str}!",
            rec_1,
            rec_2,
        ]

    return summary, recommendations


def analyze_sensor_data(request: SensorDataAnalysisRequest) -> SensorDataAnalysisResponse:
    """Menganalisis array angka dari sensor dan mengembalikan statistik, anomali, status, serta rekomendasi."""
    data = request.data
    count = len(data)

    min_val = float(min(data))
    max_val = float(max(data))
    mean_val = float(statistics.mean(data))
    median_val = float(statistics.median(data))
    std_dev_val = float(statistics.stdev(data)) if count > 1 else 0.0
    val_range = float(max_val - min_val)

    metrics = MetricsSummary(
        count=count,
        min=round(min_val, 4),
        max=round(max_val, 4),
        mean=round(mean_val, 4),
        median=round(median_val, 4),
        std_dev=round(std_dev_val, 4),
        range=round(val_range, 4),
    )

    anomalies: List[AnomalyDetail] = []
    threshold_violations = 0
    severe_violations = 0

    # 1. Evaluasi Threshold (jika ada)
    t_min = float(request.threshold_min) if request.threshold_min is not None else None
    t_max = float(request.threshold_max) if request.threshold_max is not None else None

    for i, val in enumerate(data):
        is_anomaly = False
        reasons = []

        if t_min is not None and val < t_min:
            is_anomaly = True
            threshold_violations += 1
            diff = t_min - val
            reasons.append(f"Di bawah threshold min ({t_min}) sebesar {round(diff, 2)}")
            if t_min != 0 and (diff / abs(t_min)) > 0.2:
                severe_violations += 1

        if t_max is not None and val > t_max:
            is_anomaly = True
            threshold_violations += 1
            diff = val - t_max
            reasons.append(f"Melebihi threshold max ({t_max}) sebesar {round(diff, 2)}")
            if t_max != 0 and (diff / abs(t_max)) > 0.2:
                severe_violations += 1

        # 2. Evaluasi Anomali Statistik (Z-score > 2.5)
        if std_dev_val > 0:
            z_score = abs(val - mean_val) / std_dev_val
            if z_score > 2.5:
                if not is_anomaly:
                    is_anomaly = True
                reasons.append(f"Outlier statistik (Z-score: {round(z_score, 2)})")

        if is_anomaly:
            anomalies.append(
                AnomalyDetail(
                    index=i,
                    value=round(float(val), 4),
                    reason="; ".join(reasons),
                )
            )

    # 3. Penentuan Status
    if severe_violations > 0 or len(anomalies) > (0.3 * count):
        status = "critical"
    elif len(anomalies) > 0 or threshold_violations > 0:
        status = "warning"
    else:
        status = "normal"

    # 4. Penyusunan Ringkasan & Rekomendasi (Groq API dengan Rate Limiter & Fallback)
    unit_str = f" {request.unit}" if request.unit else ""
    sensor_name_str = request.sensor_name or "Sensor"
    stem_subject_str = request.stem_subject or "Sistem Embedded & IoT"

    groq_result = _generate_groq_insights(
        sensor_name=sensor_name_str,
        unit=request.unit or "",
        status=status,
        metrics=metrics,
        anomalies=anomalies,
        context=request.context,
        stem_subject=stem_subject_str,
    )

    if groq_result is not None:
        summary, recommendations = groq_result
    else:
        # Fallback Rule-Based Khusus per Disiplin Ilmu STEM
        context_info = f" pada {request.context}" if request.context else ""
        summary, recommendations = _get_fallback_stem_insights(
            stem_subject=stem_subject_str,
            sensor_name_str=sensor_name_str,
            unit_str=unit_str,
            status=status,
            count=count,
            metrics=metrics,
            anomalies=anomalies,
            context_info=context_info,
        )

    return SensorDataAnalysisResponse(
        status=status,
        summary=summary,
        metrics=metrics,
        anomalies=anomalies,
        recommendations=recommendations,
    )
