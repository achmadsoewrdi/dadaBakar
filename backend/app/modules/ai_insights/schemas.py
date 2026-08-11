from pydantic import BaseModel, Field
from typing import Optional, List, Union


class AnomalyDetail(BaseModel):
    index: int = Field(..., description="Indeks posisi data pada array sensor")
    value: float = Field(..., description="Nilai sensor pada posisi tersebut")
    reason: str = Field(..., description="Penyebab terdeteksi sebagai anomali")


class MetricsSummary(BaseModel):
    count: int = Field(..., description="Jumlah data poin sensor")
    min: float = Field(..., description="Nilai minimum")
    max: float = Field(..., description="Nilai maksimum")
    mean: float = Field(..., description="Nilai rata-rata (mean)")
    median: float = Field(..., description="Nilai tengah (median)")
    std_dev: float = Field(..., description="Deviasi standar")
    range: float = Field(..., description="Rentang nilai (max - min)")


class SensorDataAnalysisRequest(BaseModel):
    data: List[float] = Field(..., min_length=1, description="Array angka sensor yang akan dianalisis")
    sensor_name: Optional[str] = Field(default=None, description="Nama atau tipe sensor (misal: Suhu, Kelembaban, Getaran)")
    unit: Optional[str] = Field(default=None, description="Satuan pengukuran (misal: °C, %, RPM, V)")
    threshold_min: Optional[Union[float, int]] = Field(default=None, description="Batas minimum aman untuk sensor")
    threshold_max: Optional[Union[float, int]] = Field(default=None, description="Batas maksimum aman untuk sensor")
    context: Optional[str] = Field(default=None, description="Konteks operasional atau deskripsi lingkungan sensor")
    stem_subject: Optional[str] = Field(default="Sistem Embedded & IoT", description="Nama mata pelajaran/praktikum STEM (misal: Fisika Dasar, Kimia Analitik, Robotika, Biologi Lingkungan)")



class SensorDataAnalysisResponse(BaseModel):
    status: str = Field(..., description="Status kondisi sensor ('normal', 'warning', atau 'critical')")
    summary: str = Field(..., description="Ringkasan hasil analisis data sensor")
    metrics: MetricsSummary = Field(..., description="Statistik deskriptif data sensor")
    anomalies: List[AnomalyDetail] = Field(default_factory=list, description="Daftar titik data yang terdeteksi anomali")
    recommendations: List[str] = Field(default_factory=list, description="Daftar rekomendasi atau tindakan lanjut")
