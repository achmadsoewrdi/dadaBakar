import statistics
from typing import List
from app.modules.ai_insights.schemas import (
    SensorDataAnalysisRequest,
    SensorDataAnalysisResponse,
    MetricsSummary,
    AnomalyDetail,
)


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

    # 4. Penyusunan Ringkasan & Rekomendasi
    unit_str = f" {request.unit}" if request.unit else ""
    sensor_name_str = request.sensor_name or "Sensor"

    if status == "normal":
        summary = (
            f"Data {sensor_name_str} sebanyak {count} titik pengukuran menunjukkan kondisi stabil "
            f"dengan rata-rata {metrics.mean}{unit_str} (min: {metrics.min}{unit_str}, max: {metrics.max}{unit_str}). "
            f"Tidak terdeteksi adanya anomali atau pelanggaran threshold."
        )
        recommendations = [
            f"Kondisi {sensor_name_str} dalam keadaan optimal.",
            "Lanjutkan pemantauan rutin secara berkala.",
        ]
    elif status == "warning":
        summary = (
            f"Terdeteksi {len(anomalies)} anomali / penyimpangan pada data {sensor_name_str}. "
            f"Nilai rata-rata saat ini adalah {metrics.mean}{unit_str} dengan rentang {metrics.range}{unit_str}."
        )
        recommendations = [
            f"Periksa kondisi operasional {sensor_name_str} dan koneksi kabel.",
            "Lakukan verifikasi batas threshold atau kalibrasi sensor jika diperlukan.",
        ]
        if t_max is not None and max_val > t_max:
            recommendations.append(f"Waspadai kenaikan nilai lonjakan yang melebihi {t_max}{unit_str}.")
    else: # critical
        summary = (
            f"KONDISI KRITIS: Terdeteksi {len(anomalies)} anomali signifikan pada {sensor_name_str}. "
            f"Nilai tertinggi mencapai {metrics.max}{unit_str} dan rata-rata {metrics.mean}{unit_str}."
        )
        recommendations = [
            f"SEGERA PERIKSA hardware dan lingkungan kerja {sensor_name_str}!",
            "Pertimbangkan untuk mematikan atau mengisolasi modul perangkat untuk mencegah kerusakan fisik.",
            "Lakukan inspeksi langsung pada sistem terkait.",
        ]

    return SensorDataAnalysisResponse(
        status=status,
        summary=summary,
        metrics=metrics,
        anomalies=anomalies,
        recommendations=recommendations,
    )
