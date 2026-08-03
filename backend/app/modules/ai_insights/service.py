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
    """Menggunakan Groq Cloud API dengan Persona Asisten Lab STEM dan Rate Limiter Protection."""
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
Kamu adalah Asisten Laboratorium {stem_subject} Senior. Tugas utamamu adalah membantu praktikan/mahasiswa dalam menginterpretasikan dan menarik kesimpulan teknis/ilmiah dari pembacaan data sensor.

**Konteks Sistem:**
Data yang kamu terima telah melalui tahap ekstraksi awal dari endpoint `analyze-sensor`. Tugasmu bukan menghitung data dari nol, melainkan memberikan wawasan analitis tingkat tinggi, mendeteksi pola teknis/fisis, dan membimbing praktikan memahami makna fisis dari data tersebut sesuai bidang {stem_subject}.

**Data Input Sensor:**
- Nama Sensor: {sensor_name}
- Satuan: {unit or 'tanpa satuan'}
- Konteks Pengujian: {context or f'Praktikum {stem_subject}'}
- Status Kondisi: {status.upper()}
- Statistik Data Agregasi:
  * Jumlah Sampel: {metrics.count}
  * Nilai Rata-rata: {metrics.mean}{unit_str}
  * Nilai Minimum: {metrics.min}{unit_str}
  * Nilai Maksimum: {metrics.max}{unit_str}
  * Rentang Nilai (Range): {metrics.range}{unit_str}
  * Deviasi Standar: {metrics.std_dev}{unit_str}
- Jumlah Anomali: {len(anomalies)}
- Detail Anomali Sampel: {json.dumps(anomaly_summary, ensure_ascii=False)}

**Instruksi Analisis (Wajib Sangat Detail & Komprehensif):**
1. **Ringkasan Metrik & Tren:** Evaluasi tren utama data, nilai puncak, dan stabilitas pembacaan.
2. **Korelasi Teori & Fenomena STEM:** Identifikasi penyebab anomali dan jelaskan fenomena di baliknya berdasarkan hukum/teori dasar bidang {stem_subject}.
3. **Nada Bicara:** Bahasa Indonesia yang profesional, analitis, teknis, mendalam, namun tetap suportif dan edukatif layaknya asisten lab senior kepada mahasiswa.

Format Balasan HARUS berupa JSON valid dengan struktur persis berikut:
{{
  "summary": "Tuliskan analisis teknis/ilmiah yang sangat detail dan mendalam (minimal 2-3 paragraf komprehensif) mencakup ringkasan metrik, tren data, dan korelasi teori {stem_subject}.",
  "recommendations": [
    "Langkah praktis 1 (pemeriksaan peralatan / instrumen / hardware)",
    "Langkah praktis 2 (penyesuaian prosedur praktikum / software / kalibrasi)",
    "Langkah praktis 3 (evaluasi ilmiah selanjutnya)"
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

    groq_result = _generate_groq_insights(
        sensor_name=sensor_name_str,
        unit=request.unit or "",
        status=status,
        metrics=metrics,
        anomalies=anomalies,
        context=request.context,
        stem_subject=request.stem_subject or "Sistem Embedded & IoT",
    )

    if groq_result is not None:
        summary, recommendations = groq_result
    else:
        # Fallback Rule-Based jika GROQ_API_KEY tidak diset, Rate Limit tercapai, atau Groq API error
        context_info = f" pada {request.context}" if request.context else ""
        if status == "normal":
            summary = (
                f"📊 [Analisis Asisten Lab - Fallback System]\n\n"
                f"Hasil pengujian pada {sensor_name_str}{context_info} menunjukkan kondisi operasional yang STABIL. "
                f"Dari total {count} sampel data yang diamati, nilai rata-rata tercatat {metrics.mean}{unit_str} dengan deviasi standar {metrics.std_dev}{unit_str}. "
                f"Rentang sinyal berada pada interval [{metrics.min}{unit_str} - {metrics.max}{unit_str}] tanpa adanya fluktuasi sinyal abnormal atau pelanggaran threshold."
            )
            recommendations = [
                f"Kondisi fisis {sensor_name_str} dalam keadaan optimal dan siap digunakan untuk pengujian berikutnya.",
                "Lanjutkan pemantauan rutin dan pastikan pembacaan disampingkan dari sumber interferensi elektromagnetik eksternal.",
            ]
        elif status == "warning":
            summary = (
                f"⚠️ [Analisis Asisten Lab - Fallback System]\n\n"
                f"Terdeteksi potensi penyimpangan sinyal pada {sensor_name_str}{context_info}. "
                f"Sebanyak {len(anomalies)} dari {count} titik data mengalami deviasi di luar batas normal operasional. "
                f"Rata-rata pengukuran tercatat {metrics.mean}{unit_str} dengan deviasi standar cukup tinggi ({metrics.std_dev}{unit_str}). "
                f"Kondisi ini umumnya disebabkan oleh noise sinyal pada jalur transmisi analog/digital atau penurunan kualitas sambungan fisik."
            )
            recommendations = [
                f"Periksa kestabilan koneksi fisik kabel jumper dan pin header pada {sensor_name_str}.",
                "Lakukan verifikasi tegangan suplai VCC/GND menggunakan multimeter untuk memastikan tidak terjadi ripple voltage.",
                "Pertimbangkan untuk menerapkan software filtering (seperti Moving Average Filter) pada program mikrokontroler.",
            ]
        else:  # critical
            summary = (
                f"🚨 [Analisis Asisten Lab - Fallback System]\n\n"
                f"PERHATIAN PRAKTIKAN: Terdeteksi KONDISI KRITIS pada {sensor_name_str}{context_info}! "
                f"Sebanyak {len(anomalies)} anomali signifikan teridentifikasi dengan nilai lonjakan tertinggi mencapai {metrics.max}{unit_str} (Rata-rata: {metrics.mean}{unit_str}). "
                f"Penyimpangan sebesar ini mengindikasikan adanya masalah fisis serius seperti bus-contention, drop tegangan suplai secara drastis, kelonggaran jalur ground (floating GND), atau komponen yang mengalami overheat."
            )
            recommendations = [
                f"SEGERA periksa fisik hardware dan putuskan sambungan daya jika terindikasi adanya komponen yang panas berlebih!",
                "Verifikasi konfigurasi pull-up/pull-down resistor serta keutuhan kabel komunikasi (I2C/SPI/UART).",
                "Periksa ulang skema wiring dan pastikan tidak ada korsleting (short circuit) pada board praktikum.",
            ]

    return SensorDataAnalysisResponse(
        status=status,
        summary=summary,
        metrics=metrics,
        anomalies=anomalies,
        recommendations=recommendations,
    )
