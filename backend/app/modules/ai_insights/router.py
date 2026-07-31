from fastapi import APIRouter, HTTPException, status
from app.modules.ai_insights.schemas import (
    SensorDataAnalysisRequest,
    SensorDataAnalysisResponse,
)
from app.modules.ai_insights import service

router = APIRouter(prefix="/ai-insights", tags=["ai-insights"])


@router.post(
    "/analyze-sensor",
    response_model=SensorDataAnalysisResponse,
    status_code=status.HTTP_200_OK,
    summary="Menganalisis array angka dari sensor",
    description="Endpoint untuk menerima data array angka dari sensor (misal: suhu, kelembaban, getaran) "
                "dan mengembalikan analisis statistik, deteksi anomali, status kesehatan sensor, serta rekomendasi AI.",
)
async def analyze_sensor(payload: SensorDataAnalysisRequest) -> SensorDataAnalysisResponse:
    """Menerima array data sensor dan melakukan analisis statistik & anomali."""
    if not payload.data:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Array data sensor tidak boleh kosong.",
        )
    try:
        result = service.analyze_sensor_data(payload)
        return result
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Gagal memproses analisis data sensor: {str(e)}",
        )


@router.post(
    "/analyze",
    response_model=SensorDataAnalysisResponse,
    status_code=status.HTTP_200_OK,
    summary="Alias endpoint analisis sensor",
)
async def analyze_sensor_alias(payload: SensorDataAnalysisRequest) -> SensorDataAnalysisResponse:
    """Alias endpoint untuk /analyze-sensor."""
    return await analyze_sensor(payload)
