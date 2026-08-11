# 📋 XPLORIA v3 — IMPLEMENTATION PLAN (Full Stack)
> Dokumen ini dibuat berdasarkan sesi diskusi mendalam antara tim dan AI assistant pada 11 Agustus 2026.
> Diperbarui dengan **analisis backend penuh** agar Frontend (Flutter) dan Backend (FastAPI/PostgreSQL) selaras.
> Tujuannya adalah sebagai **pedoman bersama (alignment document)** bagi seluruh anggota tim pengembang.

---

## 🧭 Latar Belakang & Arah Baru

Xploria v3 mengalami perubahan arah secara fundamental. Aplikasi ini tidak lagi berfokus pada gamifikasi dan ekosistem kelas (teacher-student), melainkan bergerak menjadi **platform pemrograman visual berbasis hardware** yang dirancang khusus untuk anak-anak dan pemula.

### Analogi Referensi

| Aspek | Referensi |
|-------|-----------|
| **Hardware side** | PLC Siemens — logika kontrol terprogram untuk hardware fisik |
| **Software side** | Aplikasi Xploria — visual coding environment (Blockly) sebagai tools untuk mengampu logika yang dibuat siswa |
| **Drone Block** | DroneBlocks (droneblocks.io) — block programming untuk drone |

### Filosofi Utama
> *"Anak-anak tidak perlu tahu cara menulis kode, mereka cukup tahu cara berpikir secara logis dan menyusun instruksi secara visual — lalu hardware yang menjalankannya."*

---

## 📊 Peta Perubahan (Ringkasan)

```
HAPUS          PERTAHANKAN & ADJUST          TAMBAH BARU
─────────      ──────────────────────        ─────────────────────────
✗ Gamifikasi   ✅ Dashboard (student only)   ✨ Drone Controller (Tello)
✗ Teacher DB   ✅ Lessons & Modules          ✨ Block Drone
✗ Assignments  ✅ Blockly Workspace          ✨ Block per Modul
✗ Splash       ✅ Projects                   ✨ Splash Premium Baru
✗ Classroom    ✅ Auth / Account
✗ AI Lab       🔧 Device (Unified)
               🔧 Block UX (Simplified)
```

---

## 🗄️ ANALISIS BACKEND — AUDIT LENGKAP

### Kondisi Saat Ini: 11 Backend Modules + 15 Database Tables

```
Backend Modules (app/modules/):           Database Tables:
├── users/          ✅ TETAP              ├── users
├── projects/       🔧 DIMODIFIKASI       ├── projects
├── devices/        🔧 DIMODIFIKASI       ├── device_profiles
├── content/        🔧 DIMODIFIKASI       ├── learning_modules
├── blocks/         🔧 DIMODIFIKASI       ├── block_definitions
├── hardware_types/ 🔧 DIMODIFIKASI       ├── hardware_types
├── subscriptions/  ✅ TETAP              ├── subscriptions
├── hardware_logs/  ✅ TETAP              ├── hardware_logs
├── gamification/   ✗ DIHAPUS            ├── badges              ✗
│                                         ├── user_badges         ✗
│                                         └── user_gamification   ✗
├── school/         ✗ DIHAPUS            ├── schools             ✗
│                                         ├── classrooms          ✗
│                                         └── enrollments         ✗
└── ai_insights/    ✗ DIHAPUS            (no table, pure computation)
```

### Keputusan Backend Per Module

| Module | Tables | Keputusan | Alasan |
|--------|--------|-----------|--------|
| `users` | `users` | ✅ TETAP (tapi ada kolom yang dihapus) | Auth tetap dipakai |
| `projects` | `projects` | 🔧 MODIFIKASI | Tambah `module_category` |
| `devices` | `device_profiles`, `hardware_logs` | 🔧 MODIFIKASI | Tambah support UDP/drone |
| `content` | `learning_modules`, `user_progress` | 🔧 MODIFIKASI | Tambah `block_category`, hapus `xp_reward` |
| `blocks` | `block_definitions` | 🔧 MODIFIKASI | Tambah generator drone, tambah `module_category` |
| `hardware_types` | `hardware_types` | 🔧 MODIFIKASI | Tambah entry `tello_drone` |
| `subscriptions` | `subscriptions` | ✅ TETAP | Premium access tetap dipakai |
| `hardware_logs` | `hardware_logs` | ✅ TETAP | Logging device tetap relevan |
| `gamification` | `badges`, `user_badges`, `user_gamification` | ✗ HAPUS | Gamifikasi dihapus dari v3 |
| `school` | `schools`, `classrooms`, `enrollments` | ✗ HAPUS | Teacher/classroom dihapus dari v3 |
| `ai_insights` | *(no table)* | ✗ HAPUS | AI Lab dihapus dari v3 |

---

## 🗑️ FASE 1 — PENGHAPUSAN (FRONTEND + BACKEND)

### 1A. Backend — Hapus Module Gamifikasi

**Tables yang di-DROP:**
```sql
-- Urutan penting karena ada foreign key constraints
DROP TABLE IF EXISTS user_badges CASCADE;
DROP TABLE IF EXISTS user_gamification CASCADE;
DROP TABLE IF EXISTS badges CASCADE;
```

**Files yang dihapus:**
```
backend/app/modules/gamification/        DELETE SELURUH FOLDER
  ├── models.py     (Badge, UserBadge, UserGamification)
  ├── router.py     (GET /gamification/me/{id}, POST /add-xp, GET /badges)
  ├── schemas.py
  └── service.py
```

**Files yang dimodifikasi:**
```
backend/app/main.py
  - Hapus: import app.modules.gamification.models
  - Hapus: from app.modules.gamification.router import router as gamification_router
  - Hapus: app.include_router(gamification_router, ...)

backend/app/modules/users/models.py
  - Hapus relationship: gamification (→ UserGamification)
  - Hapus relationship: user_badges (→ UserBadge)
```

**Alembic Migration:**
```python
# Buat migration baru: hapus tabel gamifikasi
def upgrade():
    op.drop_table('user_badges')
    op.drop_table('user_gamification')
    op.drop_table('badges')

def downgrade():
    # Buat ulang jika perlu rollback
    ...
```

---

### 1B. Backend — Hapus Module School (Classroom + Teacher)

**Tables yang di-DROP:**
```sql
-- Urutan penting karena ada foreign key constraints
DROP TABLE IF EXISTS enrollments CASCADE;
DROP TABLE IF EXISTS classrooms CASCADE;
DROP TABLE IF EXISTS schools CASCADE;

-- Hapus kolom dari tabel users
ALTER TABLE users DROP COLUMN IF EXISTS school_id;
ALTER TABLE users DROP COLUMN IF EXISTS onboarding_source;
```

**Files yang dihapus:**
```
backend/app/modules/school/              DELETE SELURUH FOLDER
  ├── models.py         (School, Classroom, Enrollment)
  ├── router.py         (POST /schools/verify-invite-token, POST /classrooms, POST /classrooms/join)
  ├── schemas.py
  ├── school_service.py
  └── classroom_service.py
```

**Files yang dimodifikasi:**
```
backend/app/main.py
  - Hapus: import app.modules.school.models
  - Hapus: from app.modules.school.router import router as school_router
  - Hapus: app.include_router(school_router, ...)

backend/app/modules/users/models.py
  - Hapus kolom: school_id (ForeignKey ke schools)
  - Hapus kolom: onboarding_source
  - Hapus relationship: school (→ School)
  - Hapus relationship: teaching_classrooms (→ Classroom)
  - Hapus relationship: enrollments (→ Enrollment)

backend/app/core/security.py (jika ada)
  - Hapus parameter school_id dari create_access_token()
  - Hapus parameter school_id dari create_refresh_token()
```

**Perhatikan kolom `role` di User:**
```python
# Saat ini: role bisa 'user' | 'siswa' | 'guru' | 'admin'
# Setelah v3: role disederhanakan menjadi 'user' | 'admin' saja
# Tidak perlu drop kolom, cukup update validasi di service layer
```

**Alembic Migration:**
```python
def upgrade():
    op.drop_table('enrollments')
    op.drop_table('classrooms')
    op.drop_table('schools')
    op.drop_column('users', 'school_id')
    op.drop_column('users', 'onboarding_source')

def downgrade():
    ...
```

---

### 1C. Backend — Hapus Module AI Insights

**Tables yang di-DROP:** *(tidak ada — ai_insights tidak punya tabel)*

**Files yang dihapus:**
```
backend/app/modules/ai_insights/         DELETE SELURUH FOLDER
  ├── router.py     (POST /ai-insights/analyze-sensor, POST /ai-insights/analyze)
  ├── schemas.py
  └── service.py
```

**Files yang dimodifikasi:**
```
backend/app/main.py
  - Hapus: from app.modules.ai_insights.router import router as ai_insights_router
  - Hapus: app.include_router(ai_insights_router, ...)
```

---

### 1D. Frontend — Hapus 6 Fitur Flutter

Ini sesuai dengan planv3 sebelumnya, tapi sekarang dengan konteks backend:

```
HAPUS DI FLUTTER:
├── lib/features/gamification/     (jika ada)
├── lib/features/ai_lab/           ← Juga remove call ke /ai-insights/*
├── lib/features/assignments/
├── lib/features/splash/           (lama)
├── lib/features/classroom/        ← Juga remove call ke /classrooms/*
└── lib/features/dashboard/teacher/ ← Teacher dashboard + widgets
```

**Juga update:**
```
xploria_app/lib/features/auth/data/data_sources/auth_storage_service.dart
  - Hapus logic untuk role 'guru' / 'siswa'
  - Hapus logic untuk school_id dalam JWT parsing
```

---

## 🔧 FASE 2 — ADJUSTMENT (BACKEND + FRONTEND)

### 2A. Backend — Update `device_profiles` Table

**Alasan:** Saat ini tabel hanya support `websocket` dan `bluetooth`. Untuk drone DJI Tello, perlu tambah support `udp` dan field `device_category`.

**Schema Update:**
```python
# backend/app/modules/devices/models.py — MODIFIKASI
class DeviceProfile(Base):
    __tablename__ = "device_profiles"
    
    # ... kolom yang sudah ada tetap ...
    
    protocol: Mapped[str] = mapped_column(String(20), nullable=False)
    # NILAI BARU: 'websocket' | 'bluetooth' | 'udp'  ← TAMBAH 'udp'
    
    # KOLOM BARU
    device_category: Mapped[str | None] = mapped_column(
        String(30), nullable=True
    )
    # Nilai: 'drone' | 'iot' | 'general' | None
    
    udp_port: Mapped[int | None] = mapped_column(Integer, nullable=True)
    # Untuk Tello: default 8889
```

**Alembic Migration:**
```python
def upgrade():
    op.add_column('device_profiles',
        sa.Column('device_category', sa.String(30), nullable=True)
    )
    op.add_column('device_profiles',
        sa.Column('udp_port', sa.Integer(), nullable=True)
    )
    # Update constraint/check untuk protocol
    # (opsional — bisa dilakukan di service layer)
```

**Update Schemas & Service:**
```python
# backend/app/modules/devices/schemas.py
class DeviceProfileCreate(BaseModel):
    # ...
    protocol: str  # 'websocket' | 'bluetooth' | 'udp'
    device_category: Optional[str] = None  # BARU
    udp_port: Optional[int] = None         # BARU

class DeviceProfileOut(BaseModel):
    # ...
    device_category: Optional[str] = None  # BARU
    udp_port: Optional[int] = None         # BARU
```

---

### 2B. Backend — Update `hardware_types` Table

**Alasan:** Saat ini `hardware_types` berisi entry untuk Raspberry Pi, Orange Pi, ESP32. Perlu tambah entry untuk DJI Tello sebagai hardware type.

**Data Seed Baru (bukan schema change):**
```sql
-- Insert hardware type baru untuk drone
INSERT INTO hardware_types (id, name, display_name, description, pin_map_json)
VALUES (
    gen_random_uuid(),
    'tello_drone',
    'DJI Tello',
    'Drone DJI Tello — dikontrol via UDP port 8889',
    '{"command_port": 8889, "state_port": 8890, "video_port": 11111, "default_ip": "192.168.10.1"}'
);
```

**Update Flutter's `DeviceProfileModel.deviceType`:**
- Nilai lama: `'raspberry_pi' | 'orange_pi'`
- Nilai baru: `'raspberry_pi' | 'orange_pi' | 'esp32' | 'tello_drone'`

---

### 2C. Backend — Update `block_definitions` Table

**Alasan:** `block_definitions` saat ini punya generator untuk `raspi`, `orangepi`, `esp32`. Perlu tambah generator untuk drone Tello + tambah field `module_category` untuk sistem unlock.

**Schema Update:**
```python
# backend/app/modules/blocks/models.py — MODIFIKASI
class BlockDefinition(Base):
    __tablename__ = "block_definitions"
    
    # Kolom yang sudah ada tetap:
    category: Mapped[str]        # 'gpio' | 'sensor' | 'motor' | dll
    block_type: Mapped[str]      # identifier unik, misal: 'drone_takeoff'
    label: Mapped[str]           # nama yang muncul di UI toolbox
    toolbox_json: Mapped[dict]   # definisi visual block Blockly
    generator_raspi: Mapped[str | None]
    generator_orangepi: Mapped[str | None]
    generator_esp32: Mapped[str | None]
    is_premium_only: Mapped[bool]
    order_index: Mapped[int]
    
    # KOLOM BARU
    generator_tello: Mapped[str | None] = mapped_column(Text, nullable=True)
    # Python UDP code generator untuk Tello drone
    
    module_category: Mapped[str | None] = mapped_column(String(50), nullable=True, index=True)
    # Untuk unlock system: 'drone' | 'smart_home' | 'smart_city' | 'agriculture' | None (= selalu tampil)
```

**Alembic Migration:**
```python
def upgrade():
    op.add_column('block_definitions',
        sa.Column('generator_tello', sa.Text(), nullable=True)
    )
    op.add_column('block_definitions',
        sa.Column('module_category', sa.String(50), nullable=True, index=True)
    )

def downgrade():
    op.drop_column('block_definitions', 'generator_tello')
    op.drop_column('block_definitions', 'module_category')
```

**Update Router — Tambah Filter by Module Category:**
```python
# backend/app/modules/blocks/router.py — MODIFIKASI
@router.get("/", response_model=list[BlockDefinitionSummary])
async def list_blocks(
    category: Optional[str] = None,
    module_category: Optional[str] = None,  # BARU: filter by modul
    db: AsyncSession = Depends(get_db)
):
    """List blok, bisa difilter per kategori hardware atau per modul."""
    return await service.get_all(db, category, module_category)
```

**Seed Data Block Drone (contoh):**
```sql
INSERT INTO block_definitions (id, category, block_type, label, toolbox_json, generator_tello, module_category, order_index)
VALUES
  (gen_random_uuid(), 'drone', 'drone_takeoff', 'Terbang (Takeoff)',
   '{"type":"drone_takeoff","message0":"✈️ Terbang","colour":230}',
   'send_cmd(''takeoff'')', 'drone', 1),

  (gen_random_uuid(), 'drone', 'drone_land', 'Mendarat (Land)',
   '{"type":"drone_land","message0":"🛬 Mendarat","colour":230}',
   'send_cmd(''land'')', 'drone', 2),

  (gen_random_uuid(), 'drone', 'drone_forward', 'Maju %1 cm',
   '{"type":"drone_forward","message0":"⬆️ Maju %1 cm","args0":[{"type":"field_number","name":"DIST","value":100}],"colour":230}',
   'send_cmd(f''forward {DIST}'')', 'drone', 3);
  -- dst...
```

---

### 2D. Backend — Update `learning_modules` Table + `user_progress`

**Alasan:** Saat ini `learning_modules` punya kolom `xp_reward` yang terkait dengan gamifikasi. Karena gamifikasi dihapus, kolom ini perlu dihapus. Juga perlu tambah `block_category` untuk unlock system.

**Schema Update:**
```python
# backend/app/modules/content/models.py — MODIFIKASI
class LearningModule(Base):
    __tablename__ = "learning_modules"
    
    # Tetap:
    id, title, description, order_index, category
    thumbnail_url, steps_json, is_premium_only, created_at
    
    # HAPUS kolom ini:
    # xp_reward  ← HAPUS (gamifikasi dihapus)
    
    # TAMBAH kolom baru:
    block_category: Mapped[str | None] = mapped_column(
        String(50), nullable=True, index=True
    )
    # Nilai: 'drone' | 'smart_home' | 'smart_city' | 'agriculture' | 'robotics' | None

class UserProgress(Base):
    __tablename__ = "user_progress"
    
    # Tetap:
    id, user_id, module_id, completed_steps, completed_at
    
    # HAPUS kolom ini:
    # xp_earned  ← HAPUS (gamifikasi dihapus)
```

**Alembic Migration:**
```python
def upgrade():
    # Hapus kolom gamifikasi dari content
    op.drop_column('learning_modules', 'xp_reward')
    op.drop_column('user_progress', 'xp_earned')
    
    # Tambah kolom baru
    op.add_column('learning_modules',
        sa.Column('block_category', sa.String(50), nullable=True, index=True)
    )

def downgrade():
    op.add_column('learning_modules', sa.Column('xp_reward', sa.Integer(), default=10))
    op.add_column('user_progress', sa.Column('xp_earned', sa.Integer(), default=0))
    op.drop_column('learning_modules', 'block_category')
```

**Update Schemas:**
```python
# backend/app/modules/content/schemas.py
class LearningModuleOut(BaseModel):
    id: UUID
    title: str
    description: Optional[str]
    order_index: int
    category: str
    # xp_reward: int  ← HAPUS
    thumbnail_url: Optional[str]
    steps_json: dict
    is_premium_only: bool
    block_category: Optional[str] = None  # BARU
    created_at: datetime

class UserProgressOut(BaseModel):
    id: UUID
    user_id: UUID
    module_id: UUID
    completed_steps: Optional[dict]
    completed_at: Optional[datetime]
    # xp_earned: int  ← HAPUS
```

**Update Content Service (hapus XP logic):**
```python
# backend/app/modules/content/service.py
# Hapus semua logic yang memanggil gamification service
# Hapus semua update xp_earned setelah complete module
```

---

### 2E. Backend — Update `projects` Table

**Alasan:** Project perlu tahu module context-nya untuk menentukan block toolbox mana yang dipakai saat buka Blockly.

**Schema Update:**
```python
# backend/app/modules/projects/models.py — MODIFIKASI
class Project(Base):
    __tablename__ = "projects"
    
    # Kolom yang sudah ada tetap...
    
    # HAPUS atau REPURPOSE kolom yang sudah tidak relevan:
    # target_hardware_type → TETAP (tapi sekarang bisa berisi 'tello_drone')
    # execution_target → TETAP ('hardware' | 'drone')
    # subject_context → RENAME logikanya → GANTI dengan module_category

    # TAMBAH kolom baru:
    module_category: Mapped[str | None] = mapped_column(
        String(50), nullable=True
    )
    # Nilai: 'drone' | 'smart_home' | 'smart_city' | dll
    # Ini MENGGANTIKAN fungsi subject_context yang sebelumnya = 'coding'
```

**Alembic Migration:**
```python
def upgrade():
    op.add_column('projects',
        sa.Column('module_category', sa.String(50), nullable=True)
    )
    # subject_context bisa dipertahankan untuk backward compat
    # atau di-drop jika sudah tidak dipakai Flutter

def downgrade():
    op.drop_column('projects', 'module_category')
```

**Update Schemas:**
```python
# backend/app/modules/projects/schemas.py
class ProjectCreate(BaseModel):
    name: str
    workspace_xml: str
    generated_code: Optional[dict] = None
    blynk_config_json: Optional[list] = None  # Pertimbangkan rename ke iot_config_json
    device_profile_id: Optional[UUID] = None
    target_hardware_type: Optional[str] = None
    execution_target: Optional[str] = "hardware"
    module_category: Optional[str] = None  # BARU

class ProjectOut(BaseModel):
    # ...same as before + tambah:
    module_category: Optional[str] = None  # BARU
```

---

## ✨ FASE 3 — PENAMBAHAN FITUR BARU (BACKEND + FRONTEND)

### 3A. Backend — Tambah Drone Session Logging (Opsional tapi Direkomendasikan)

**Alasan:** Perlu menyimpan log sesi penerbangan drone untuk keperluan debugging dan monitoring.

**Table Baru: `drone_sessions`**
```python
# backend/app/modules/devices/models.py — TAMBAH class baru

class DroneSession(Base):
    """Log sesi penerbangan drone per user per project."""
    __tablename__ = "drone_sessions"
    
    id: Mapped[uuid.UUID] = mapped_column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True
    )
    project_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("projects.id", ondelete="SET NULL"), nullable=True
    )
    device_profile_id: Mapped[uuid.UUID | None] = mapped_column(
        UUID(as_uuid=True), ForeignKey("device_profiles.id", ondelete="SET NULL"), nullable=True
    )
    mode: Mapped[str] = mapped_column(String(20), nullable=False)
    # 'manual' | 'auto'
    
    commands_sent: Mapped[list | None] = mapped_column(JSONB, nullable=True)
    # List command yang dikirim: ['takeoff', 'forward 100', 'land']
    
    started_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=datetime.utcnow)
    ended_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    
    # Status: 'completed' | 'aborted' | 'error'
    status: Mapped[str] = mapped_column(String(20), default="completed")
    error_message: Mapped[str | None] = mapped_column(String, nullable=True)
```

**Alembic Migration:**
```python
def upgrade():
    op.create_table('drone_sessions',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('users.id', ondelete='CASCADE'), nullable=False),
        sa.Column('project_id', postgresql.UUID(as_uuid=True), sa.ForeignKey('projects.id', ondelete='SET NULL'), nullable=True),
        sa.Column('device_profile_id', postgresql.UUID(as_uuid=True), nullable=True),
        sa.Column('mode', sa.String(20), nullable=False),
        sa.Column('commands_sent', postgresql.JSONB, nullable=True),
        sa.Column('started_at', sa.DateTime(timezone=True), default=datetime.utcnow),
        sa.Column('ended_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('status', sa.String(20), default='completed'),
        sa.Column('error_message', sa.String, nullable=True),
    )
    op.create_index('idx_drone_sessions_user', 'drone_sessions', ['user_id'])
```

**API Endpoints Baru:**
```python
# backend/app/modules/devices/router.py — TAMBAH
@router.post("/drone-sessions", response_model=DroneSessionOut, status_code=201)
async def log_drone_session(
    session_in: DroneSessionCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Log sesi penerbangan drone (dipanggil dari Flutter saat selesai terbang)."""
    ...

@router.get("/drone-sessions", response_model=list[DroneSessionOut])
async def list_drone_sessions(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Ambil semua sesi penerbangan drone milik user."""
    ...
```

---

### 3B. Backend — API Block per Modul (Unlock System)

**API Endpoint Baru untuk Blockly:**
```python
# backend/app/modules/blocks/router.py — TAMBAH endpoint baru
@router.get("/for-module/{module_category}", response_model=list[BlockDefinitionSummary])
async def get_blocks_for_module(
    module_category: str,
    db: AsyncSession = Depends(get_db)
):
    """
    Ambil semua block yang tersedia untuk modul tertentu.
    Menggabungkan block 'dasar' (module_category=None) 
    + block khusus modul (module_category=module_category).
    """
    return await service.get_blocks_for_module(db, module_category)
```

**Service Implementation:**
```python
# backend/app/modules/blocks/service.py
async def get_blocks_for_module(db: AsyncSession, module_category: str):
    """
    Return block definitions yang module_category IS NULL (block dasar)
    PLUS block definitions yang module_category = module_category.
    """
    result = await db.execute(
        select(BlockDefinition)
        .where(
            or_(
                BlockDefinition.module_category.is_(None),  # block dasar selalu ada
                BlockDefinition.module_category == module_category  # block khusus modul
            )
        )
        .order_by(BlockDefinition.order_index)
    )
    return result.scalars().all()
```

---

### 3C. Flutter — Drone Controller

Tetap seperti planv3 sebelumnya. Beberapa catatan tambahan dari sisi integrasi backend:

**Flutter memanggil backend untuk:**
1. `GET /api/v1/devices/` — ambil daftar device yang tersimpan (termasuk drone Tello)
2. `POST /api/v1/devices/` — simpan drone profile (IP, UDP port, label)
3. `GET /api/v1/blocks/for-module/drone` — ambil definisi block drone dari backend
4. `POST /api/v1/devices/drone-sessions` — log sesi terbang setelah selesai

**Flutter tidak perlu backend untuk:**
- Komunikasi UDP real-time ke Tello (langsung dari Flutter ke drone via WiFi)
- Joystick control (client-side only)

---

## 🏗️ ARSITEKTUR FINAL — FRONTEND + BACKEND

### Database Schema Final (Setelah v3)

```
TABLES YANG ADA DI v3:

users                  ← MODIFIKASI (hapus school_id, onboarding_source)
  id, email, hashed_password, google_sub, full_name, photo_url
  role ('user'|'admin'), is_premium, is_active
  created_at, updated_at

projects               ← MODIFIKASI (tambah module_category)
  id, owner_id, device_profile_id, name
  workspace_xml, generated_code, blynk_config_json
  target_hardware_type, execution_target, subject_context
  module_category (BARU)
  created_at, updated_at, deleted_at

device_profiles        ← MODIFIKASI (tambah device_category, udp_port)
  id, owner_id, hardware_type_id, label, hardware_variant
  protocol ('websocket'|'bluetooth'|'udp' BARU)
  host, port, use_tls, mac_address
  device_category (BARU), udp_port (BARU)
  created_at

hardware_logs          ← TETAP
  id, device_profile_id, log_level, log_message, created_at

hardware_types         ← TETAP + DATA BARU (tello_drone)
  id, name ('raspberry_pi'|'orange_pi'|'esp32'|'tello_drone' BARU)
  display_name, pin_map_json, description, created_at

learning_modules       ← MODIFIKASI (hapus xp_reward, tambah block_category)
  id, title, description, order_index, category
  thumbnail_url, steps_json, is_premium_only
  block_category (BARU)
  created_at

user_progress          ← MODIFIKASI (hapus xp_earned)
  id, user_id, module_id, completed_steps, completed_at

block_definitions      ← MODIFIKASI (tambah generator_tello, module_category)
  id, category, block_type, label, toolbox_json
  generator_raspi, generator_orangepi, generator_esp32
  generator_tello (BARU)
  module_category (BARU)
  is_premium_only, order_index, created_at, updated_at

subscriptions          ← TETAP
  id, user_id, tier, started_at, expires_at, is_active, created_at

drone_sessions         ← BARU
  id, user_id, project_id, device_profile_id
  mode ('manual'|'auto'), commands_sent (JSONB)
  started_at, ended_at, status, error_message


TABLES YANG DIHAPUS DI v3:
  ✗ badges
  ✗ user_badges
  ✗ user_gamification
  ✗ schools
  ✗ classrooms
  ✗ enrollments
```

### Backend Module Structure Final

```
backend/app/modules/
├── users/          ✅ TETAP (update model & JWT service)
├── projects/       🔧 MODIFIKASI (tambah module_category)
├── devices/        🔧 MODIFIKASI (tambah UDP support + drone_sessions)
├── content/        🔧 MODIFIKASI (hapus XP, tambah block_category)
├── blocks/         🔧 MODIFIKASI (tambah drone generator + module_category)
├── hardware_types/ ✅ TETAP (tambah data seed tello_drone)
├── subscriptions/  ✅ TETAP
├── hardware_logs/  ✅ TETAP
│
│── DIHAPUS ────────────────────────────
├── gamification/   ✗ DELETE
├── school/         ✗ DELETE
└── ai_insights/    ✗ DELETE
```

### Flutter Feature Structure Final

```
lib/features/
├── account/                    ✅ TETAP
├── auth/                       ✅ TETAP (update JWT parsing, hapus school/role logic)
├── blockly_workspace/          🔧 MODIFIKASI
│   └── (tambah module context, panggil GET /blocks/for-module/{cat})
├── content/                    ✅ TETAP (update model: hapus xp, tambah block_category)
├── dashboard/                  🔧 MODIFIKASI (hapus gamifikasi, tab Lab→Drone)
├── device/                     🔧 MODIFIKASI (UnifiedDeviceScreen + UDP)
├── device_profile/             🔧 MODIFIKASI (tambah UDP protocol support)
├── drone_controller/           ✨ BARU (TelloUdpService, Controller Screen)
├── iot_lab/                    ✅ TETAP
├── lessons_modules/            ✅ TETAP
├── projects/                   🔧 MODIFIKASI (tambah module_category)
├── splash/                     ✨ BARU (splash premium dibuat ulang)
├── subscriptions/              ✅ TETAP
│
│── DIHAPUS ──────────────────────────────────────
├── ai_lab/                     ✗ DELETE
├── assignments/                ✗ DELETE
└── classroom/                  ✗ DELETE
```

---

## 📐 FASE 4 — UPDATE ROUTING & NAVIGASI (FLUTTER)

### 4.1 Bottom Navigation Bar Baru
```
[Learn] [Projects] [Devices] [Drone] [Profile]
```

### 4.2 Routing Final — `app_router.dart`
**Dihapus:** `/teacher-dashboard`, `/classroom-mockup`, `/assignments-mockup`, `/ai-analysis-result`
**Ditambah:** `/drone-controller`, `/devices`
**Dimodifikasi:** `/` (splash baru), `/blockly` (tambah module_category)

---

## ✅ MASTER CHECKLIST — EKSEKUSI FULL STACK

### FASE 1: Penghapusan

**Backend:**
- [ ] Buat migration: DROP tables `user_badges`, `user_gamification`, `badges`
- [ ] Buat migration: DROP tables `enrollments`, `classrooms`, `schools`
- [ ] Buat migration: DROP columns `school_id`, `onboarding_source` dari `users`
- [ ] Delete folder `backend/app/modules/gamification/`
- [ ] Delete folder `backend/app/modules/school/`
- [ ] Delete folder `backend/app/modules/ai_insights/`
- [ ] Update `backend/app/main.py` — hapus semua import & router yang dihapus
- [ ] Update `backend/app/modules/users/models.py` — hapus relationship & kolom
- [ ] Update `backend/app/core/security.py` — hapus school_id dari JWT
- [ ] **Verifikasi**: `uvicorn app.main:app` berjalan tanpa error

**Flutter:**
- [ ] Grep dan hapus semua gamifikasi dari `dashboard_home_page.dart`
- [ ] Delete 6 file teacher dashboard
- [ ] Delete folder `lib/features/assignments/`
- [ ] Delete folder `lib/features/splash/` (lama)
- [ ] Delete folder `lib/features/classroom/`
- [ ] Delete folder `lib/features/ai_lab/`
- [ ] Update `app_router.dart` — bersihkan import & route
- [ ] Update `auth_storage_service.dart` — hapus school/role logic
- [ ] **Verifikasi**: `flutter build apk --debug` tidak error

### FASE 2: Adjustment

**Backend:**
- [ ] Buat migration: tambah `device_category`, `udp_port` ke `device_profiles`
- [ ] Buat migration: tambah `generator_tello`, `module_category` ke `block_definitions`
- [ ] Buat migration: hapus `xp_reward` dari `learning_modules`
- [ ] Buat migration: hapus `xp_earned` dari `user_progress`
- [ ] Buat migration: tambah `block_category` ke `learning_modules`
- [ ] Buat migration: tambah `module_category` ke `projects`
- [ ] Update schemas untuk semua model yang berubah
- [ ] Update content service — hapus XP logic
- [ ] Update blocks router — tambah filter `module_category`
- [ ] Tambah endpoint `GET /blocks/for-module/{module_category}`
- [ ] Seed data: insert `tello_drone` ke `hardware_types`
- [ ] **Verifikasi**: Semua API endpoint berjalan dengan benar (Swagger /docs)

**Flutter:**
- [ ] Buat `unified_device_screen.dart`
- [ ] Update `DeviceProfileModel` — tambah `udpPort`, `deviceCategory`
- [ ] Update `DeviceConnectionService` — tambah UDP socket support
- [ ] Modifikasi `assets/blockly/index.html` — nama block friendly
- [ ] Buat `assets/blockly/blocks/friendly_blocks.js`
- [ ] Buat `assets/blockly/blocks/drone_blocks.js`
- [ ] Buat `assets/blockly/blocks/smart_home_blocks.js`
- [ ] Update `ProjectModel` — tambah `moduleCategory`
- [ ] Update `LearningModuleModel` — tambah `blockCategory`, hapus `xpReward`
- [ ] **Verifikasi**: Blockly workspace masih berjalan normal

### FASE 3: Penambahan Fitur Baru

**Backend:**
- [ ] Buat migration: CREATE table `drone_sessions`
- [ ] Tambah endpoints: `POST /devices/drone-sessions`, `GET /devices/drone-sessions`
- [ ] Seed data: block drone ke `block_definitions` (14 block)
- [ ] **Verifikasi**: API drone sessions berfungsi

**Flutter:**
- [ ] Buat `new_splash_screen.dart` dengan animasi premium
- [ ] Buat `TelloUdpService` (UDP dart:io)
- [ ] Buat `DroneStateModel`
- [ ] Buat `drone_joystick_widget.dart`
- [ ] Buat `drone_status_bar.dart`
- [ ] Buat `drone_action_buttons.dart`
- [ ] Buat `drone_controller_screen.dart`
- [ ] Implementasi Mode Auto (parse Python → kirim UDP step by step)
- [ ] Integrasi: saat selesai terbang, POST ke `/devices/drone-sessions`
- [ ] Implementasi `setActiveModule()` di `index.html`
- [ ] Update `BlocklyWorkspaceScreen` — panggil `GET /blocks/for-module/{cat}`
- [ ] **Verifikasi**: Test drone controller dengan Tello fisik

### FASE 4: Routing & Navigasi

**Flutter:**
- [ ] Update `dashboard_bottom_navbar.dart` (tab Lab → Drone)
- [ ] Update `dashboard_screen.dart`
- [ ] Update `app_router.dart` — routing final
- [ ] **Full Integration Test**: Semua navigation flow berjalan
- [ ] **Physical Device Test**: Android + iOS

---

## 🗄️ RINGKASAN ALEMBIC MIGRATIONS (URUTAN EKSEKUSI)

```
URUTAN MIGRATION YANG HARUS DIBUAT DAN DIJALANKAN:

Migration 1: drop_gamification_tables
  - DROP: user_badges, user_gamification, badges

Migration 2: drop_school_tables
  - DROP: enrollments, classrooms, schools
  - DROP COLUMN: users.school_id, users.onboarding_source

Migration 3: update_device_profiles_for_drone
  - ADD COLUMN: device_profiles.device_category
  - ADD COLUMN: device_profiles.udp_port

Migration 4: update_block_definitions_for_drone
  - ADD COLUMN: block_definitions.generator_tello
  - ADD COLUMN: block_definitions.module_category

Migration 5: update_content_for_v3
  - DROP COLUMN: learning_modules.xp_reward
  - DROP COLUMN: user_progress.xp_earned
  - ADD COLUMN: learning_modules.block_category

Migration 6: update_projects_for_v3
  - ADD COLUMN: projects.module_category

Migration 7: create_drone_sessions
  - CREATE TABLE: drone_sessions
```

---

## 🚨 RISIKO & MITIGASI (FULL STACK)

| Risiko | Layer | Dampak | Mitigasi |
|--------|-------|--------|----------|
| Drop tabel gamifikasi memutus relasi di User model | Backend | App crash | Hapus relationship di model sebelum run migration |
| Flutter masih memanggil endpoint gamifikasi yang sudah dihapus | Frontend | 404 error di runtime | Grep semua calls ke `/gamification/*` di Flutter code |
| JWT token lama masih berisi `school_id` field | Backend | Token validation error | Graceful handling: ignore unknown JWT claims |
| `xp_reward` dan `xp_earned` masih ada di Flutter DTO | Frontend | Parse error | Update `LearningModuleModel` dan `UserProgressModel` di Flutter |
| Block unlock system butuh API call setiap buka Blockly | Full Stack | Latency | Cache block definitions di Flutter local storage |
| UDP timeout ke Tello | Frontend | Drone tidak merespon | Retry 3x + timeout handling di TelloUdpService |

---

## 📅 ESTIMASI WAKTU (FULL STACK)

| Fase | Backend | Frontend | Total |
|------|---------|----------|-------|
| **Fase 1**: Penghapusan | 1 hari | 1–2 hari | 2–3 hari |
| **Fase 2**: Adjustment | 2–3 hari | 3–5 hari | 5–8 hari |
| **Fase 3**: Fitur Baru | 2–3 hari | 7–10 hari | 9–13 hari |
| **Fase 4**: Routing+Testing | 0.5 hari | 2–3 hari | 2–3.5 hari |
| **Total** | **~6–7 hari** | **~13–20 hari** | **~3–4 minggu** |

---

## 🗣️ LOG KEPUTUSAN (DECISION LOG)

| # | Topik | Keputusan |
|---|-------|-----------|
| 1 | Drone target hardware | DJI Tello — protokol UDP port 8889 |
| 2 | Penyimpanan project | Block code disimpan ke database — siswa bisa save, load, delete |
| 3 | Lessons & Modules | DIPERTAHANKAN sebagai container utama modul (smart city, agriculture, dll adalah sub-modul) |
| 4 | Splash screen | Dihapus total dan dibuat ulang yang lebih premium |
| 5 | Teacher Dashboard | Dihapus — hanya satu dashboard untuk student |
| 6 | Urutan eksekusi | Hapus dulu (Fase 1) → adjust (Fase 2) → baru tambah fitur baru (Fase 3) |
| 7 | Block adjustment | Rename ke bahasa ramah anak + sederhanakan parameter dengan dropdown |
| 8 | Drone Controller UI | Bergaya Tello-like — kamera di atas, dual joystick di bawah, tombol action di tengah |
| 9 | Protokol drone | WiFi/UDP (bukan Bluetooth, MQTT, atau WebSocket) |
| 10 | Modul fokus awal | Drone + Smart Home — modul lain adalah roadmap |
| 11 | Backend gamifikasi | Hapus total 3 tabel: badges, user_badges, user_gamification |
| 12 | Backend school module | Hapus total 3 tabel: schools, classrooms, enrollments + kolom di users |
| 13 | Backend AI insights | Hapus modul (tidak ada tabel DB) |
| 14 | Role user | Disederhanakan dari 'user/siswa/guru/admin' menjadi 'user/admin' |
| 15 | Drone session logging | Tambah tabel drone_sessions untuk tracking history penerbangan |

---

*Dokumen ini dibuat oleh: Antigravity AI Assistant*
*Dibuat berdasarkan: Sesi diskusi + Audit codebase Flutter & FastAPI backend*
*Tanggal: 11 Agustus 2026*
*Status: **DRAFT — Menunggu Review & Persetujuan Tim***
