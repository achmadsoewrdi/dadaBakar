/**
 * Block Categories Data Schema (Kid-Friendly Architecture)
 * Xploria v3 - Smart Home, Smart City, Smart Agriculture & Thematic Kit Definitions
 */
const BLOCK_CATEGORIES = [
    // ----------------------------------------------------
    // 1. FUNDAMENTAL CATEGORIES (ALWAYS AVAILABLE)
    // ----------------------------------------------------
    {
        name: 'Kejadian',
        icon: '🏁',
        color: '#FFBF00',
        desc: 'Pemicu awal program',
        blocks: [
            { name: 'Saat Program Dimulai', desc: 'Dijalankan pertama kali', xml: '<block type="event_when_start"></block>' }
        ]
    },
    {
        name: 'Dasar',
        icon: '🟢',
        color: '#32C36C',
        desc: 'Perintah dasar untuk pemula',
        blocks: [
            { name: 'Tampilkan Pesan', desc: 'Print teks', xml: '<block type="display_print"><value name="TEXT"><shadow type="text"><field name="TEXT">Halo!</field></shadow></value></block>' },
            { name: 'Tunggu (detik)', desc: 'Jeda program', xml: '<block type="delay_seconds"><value name="SECONDS"><shadow type="math_number"><field name="NUM">1</field></shadow></value></block>' },
            { name: 'Bersihkan Layar', desc: 'Hapus layar', xml: '<block type="display_clear"></block>' }
        ]
    },
    {
        name: 'Kontrol',
        icon: '⚙️',
        color: '#FFAB19',
        desc: 'Kontrol alur program',
        blocks: [
            { name: 'Tunggu (detik)', desc: 'Jeda program', xml: '<block type="delay_seconds"><value name="SECONDS"><shadow type="math_number"><field name="NUM">1</field></shadow></value></block>' },
            { name: 'Ulangi Sebanyak', desc: 'Loop N kali', xml: '<block type="controls_repeat_ext"><value name="TIMES"><shadow type="math_number"><field name="NUM">10</field></shadow></value></block>' },
            { name: 'Ulangi Selama', desc: 'Loop While', xml: '<block type="controls_whileUntil"></block>' },
            { name: 'Jika...Maka...Jika Tidak', desc: 'Percabangan', xml: '<block type="controls_if"></block>' },
            { name: 'Jika...Maka...Jika Tidak', desc: 'Percabangan', xml: '<block type="controls_if"></block>' }
        ]
    },
    {
        name: 'Operator',
        icon: '➕',
        color: '#5BA55B',
        desc: 'Matematika & Logika',
        blocks: [
            { name: 'Tambah (+)', desc: 'Operasi matematika', xml: '<block type="math_arithmetic"></block>' },
            { name: 'Bandingkan', desc: 'Lebih besar / kecil', xml: '<block type="logic_compare"></block>' },
            { name: 'Dan / Atau', desc: 'Logika boolean', xml: '<block type="logic_operation"></block>' },
            { name: 'Benar / Salah', desc: 'Nilai logika', xml: '<block type="logic_boolean"></block>' },
            { name: 'Angka Acak', desc: 'Randomizer', xml: '<block type="math_random_int"><value name="FROM"><shadow type="math_number"><field name="NUM">1</field></shadow></value><value name="TO"><shadow type="math_number"><field name="NUM">100</field></shadow></value></block>' }
        ]
    },
    {
        name: 'Variabel',
        icon: '🗃️',
        icon: '🗃️',
        color: '#FF8C1A',
        desc: 'Penyimpan nilai',
        isVariableCategory: true,
        blocks: []
    },

    // ----------------------------------------------------
    // 2. SMART HOME / SMART LIVING (KID-FRIENDLY KIT)
    // ----------------------------------------------------
    {
        name: 'Sensor Rumah',
        icon: '🌡️',
        color: '#2E8B57',
        desc: 'Pendeteksi gerakan, asap, suhu & cahaya',
        modes: ['smart_home', 'smart_living'],
        blocks: [
            { name: 'Ada Gerakan Orang?', desc: 'Mendeteksi gerakan orang', xml: '<block type="sh_sensor_motion"></block>', modes: ['smart_home', 'smart_living'] },
            { name: 'Deteksi Asap / Gas Bahaya', desc: 'Mendeteksi kebocoran gas/asap dapur', xml: '<block type="sh_sensor_gas"></block>', modes: ['smart_home', 'smart_living'] },
            { name: 'Suasana Rumah Gelap?', desc: 'Mendeteksi suasana malam/gelap', xml: '<block type="sh_sensor_dark"></block>', modes: ['smart_home', 'smart_living'] },
            { name: 'Suhu Ruangan (°C)', desc: 'Membaca derajat suhu rumah', xml: '<block type="sh_sensor_temperature"></block>', modes: ['smart_home', 'smart_living'] },
            { name: 'Status Pintu Rumah', desc: 'Mengecek pintu terbuka/terkunci', xml: '<block type="sh_sensor_door"></block>', modes: ['smart_home', 'smart_living'] }
        ]
    },
    {
        name: 'Lampu Rumah',
        icon: '💡',
        color: '#8A2BE2',
        desc: 'Kontrol lampu teras, kamar & lampu hias',
        modes: ['smart_home', 'smart_living'],
        blocks: [
            { name: 'Nyalakan / Matikan Lampu', desc: 'Sakelar lampu teras/kamar/dapur', xml: '<block type="sh_light_toggle"></block>', modes: ['smart_home', 'smart_living'] },
            { name: 'Ubah Warna Lampu Hias', desc: 'Warna lampu RGB kamar', xml: '<block type="sh_light_color"></block>', modes: ['smart_home', 'smart_living'] },
            { name: 'Atur Kecerahan Lampu', desc: 'Mengatur tingkat redup/terang lampu', xml: '<block type="sh_light_brightness"><value name="BRIGHTNESS"><shadow type="math_number"><field name="NUM">100</field></shadow></value></block>', modes: ['smart_home', 'smart_living'] },
            { name: 'Matikan Semua Lampu Rumah', desc: 'Mematikan seluruh lampu rumah', xml: '<block type="sh_light_turn_off_all"></block>', modes: ['smart_home', 'smart_living'] }
        ]
    },
    {
        name: 'Bunyi & Alarm',
        icon: '🔊',
        color: '#D65CD6',
        desc: 'Bel pintu & alarm sirine bahaya',
        modes: ['smart_home', 'smart_living'],
        blocks: [
            { name: 'Bunyikan Bel Pintu', desc: 'Suara bel pintu depan', xml: '<block type="sh_audio_doorbell"></block>', modes: ['smart_home', 'smart_living'] },
            { name: 'Bunyikan Alarm Bahaya', desc: 'Sirine peringatan bahaya', xml: '<block type="sh_audio_alarm"></block>', modes: ['smart_home', 'smart_living'] },
            { name: 'Matikan Semua Suara & Alarm', desc: 'Matikan bunyi bel dan alarm', xml: '<block type="sh_audio_stop"></block>', modes: ['smart_home', 'smart_living'] }
        ]
    },
    {
        name: 'Pintu, Gorden & Kipas',
        icon: '⚙️',
        color: '#4169E1',
        desc: 'Kunci pintu otomatis, gorden & kipas',
        modes: ['smart_home', 'smart_living'],
        blocks: [
            { name: 'Pintu Rumah (Buka / Kunci)', desc: 'Kunci pintu servo otomatis', xml: '<block type="sh_door_lock"></block>', modes: ['smart_home', 'smart_living'] },
            { name: 'Gorden Rumah (Buka / Tutup)', desc: 'Buka/Tutup gorden jendela', xml: '<block type="sh_curtain"></block>', modes: ['smart_home', 'smart_living'] },
            { name: 'Kipas Angin (Nyalakan / Matikan)', desc: 'Kontrol kipas angin otomatis', xml: '<block type="sh_fan_toggle"></block>', modes: ['smart_home', 'smart_living'] }
        ]
    },
    {
        name: 'Layar Display',
        icon: '📺',
        color: '#8B008B',
        desc: 'Tampilkan pesan dan tulisan di monitor',
        modes: ['smart_home', 'smart_living'],
        blocks: [
            { name: 'Tampilkan Pesan di Layar', desc: 'Print tulisan ke layar display', xml: '<block type="sh_display_print"><value name="TEXT"><shadow type="text"><field name="TEXT">Selamat Datang!</field></shadow></value></block>', modes: ['smart_home', 'smart_living'] },
            { name: 'Bersihkan Layar Display', desc: 'Kosongkan layar monitor', xml: '<block type="sh_display_clear"></block>', modes: ['smart_home', 'smart_living'] }
        ]
    },

    // ----------------------------------------------------
    // 3. SMART CITY (KID-FRIENDLY KIT)
    // ----------------------------------------------------
    {
        name: 'Lampu & Lalu Lintas',
        icon: '🚥',
        color: '#FFD700',
        desc: 'Lampu lalu lintas & penerangan jalan umum',
        modes: ['smart_city'],
        blocks: [
            { name: 'Atur Lampu Lalu Lintas', desc: 'Lampu lalu lintas Merah/Kuning/Hijau', xml: '<block type="sc_traffic_light"></block>', modes: ['smart_city'] },
            { name: 'Lampu Jalan Otomatis', desc: 'Lampu penerangan jalan utama', xml: '<block type="sc_street_light"></block>', modes: ['smart_city'] },
            { name: 'Warna Lampu Taman Kota', desc: 'Lampu hias taman kota', xml: '<block type="sc_park_light_color"></block>', modes: ['smart_city'] },
            { name: 'Suasana Jalanan Gelap?', desc: 'Mendeteksi apakah suasana malam/gelap', xml: '<block type="sc_sensor_dark"></block>', modes: ['smart_city'] }
        ]
    },
    {
        name: 'Parkir & Otomasi Kota',
        icon: '🅿️',
        color: '#FF8C00',
        desc: 'Palang pintu parkir & detektor mobil',
        modes: ['smart_city'],
        blocks: [
            { name: 'Palang Parkir Kota', desc: 'Buka / Tutup palang parkir', xml: '<block type="sc_parking_gate"></block>', modes: ['smart_city'] },
            { name: 'Ada Mobil Datang?', desc: 'Mendeteksi mobil mendekati parkir', xml: '<block type="sc_sensor_car"></block>', modes: ['smart_city'] },
            { name: 'Area Parkir Kosong?', desc: 'Mengecek ketersediaan tempat parkir', xml: '<block type="sc_parking_available"></block>', modes: ['smart_city'] }
        ]
    },
    {
        name: 'Kebersihan & Lingkungan',
        icon: '🗑️',
        color: '#2E8B57',
        desc: 'Tempat sampah pintar, polusi & deteksi banjir',
        modes: ['smart_city'],
        blocks: [
            { name: 'Tempat Sampah Penuh?', desc: 'Mendeteksi kapasitas tempat sampah', xml: '<block type="sc_trash_full"></block>', modes: ['smart_city'] },
            { name: 'Kualitas Udara Kota', desc: 'Cek tingkat polusi udara', xml: '<block type="sc_air_quality"></block>', modes: ['smart_city'] },
            { name: 'Deteksi Genangan Air / Hujan', desc: 'Mendeteksi banjir atau hujan deras', xml: '<block type="sc_sensor_flood"></block>', modes: ['smart_city'] }
        ]
    },
    {
        name: 'Keamanan & Sirine Kota',
        icon: '🚨',
        color: '#E53E3E',
        desc: 'Sirine darurat & lampu peringatan',
        modes: ['smart_city'],
        blocks: [
            { name: 'Bunyikan Sirine Darurat Kota', desc: 'Sirine darurat bencana/bahaya', xml: '<block type="sc_siren_start"></block>', modes: ['smart_city'] },
            { name: 'Nyalakan Lampu Darurat', desc: 'Lampu kilat merah darurat', xml: '<block type="sc_emergency_light"></block>', modes: ['smart_city'] },
            { name: 'Matikan Sirine & Peringatan', desc: 'Matikan alarm & lampu darurat', xml: '<block type="sc_siren_stop"></block>', modes: ['smart_city'] }
        ]
    },
    {
        name: 'Papan Pengumuman Kota',
        icon: '📢',
        color: '#8B008B',
        desc: 'Siarkan pengumuman publik di jalanan',
        modes: ['smart_city'],
        blocks: [
            { name: 'Siarkan Pengumuman di Layar Kota', desc: 'Tampilkan pesan ke layar publik', xml: '<block type="sc_display_announce"><value name="TEXT"><shadow type="text"><field name="TEXT">Lalu Lintas Lancar</field></shadow></value></block>', modes: ['smart_city'] },
            { name: 'Bersihkan Papan Pengumuman', desc: 'Kosongkan layar publik', xml: '<block type="sc_display_clear"></block>', modes: ['smart_city'] }
        ]
    },

    // ----------------------------------------------------
    // 4. SMART AGRICULTURE (KID-FRIENDLY KIT)
    // ----------------------------------------------------
    {
        name: 'Tanah & Penyiraman',
        icon: '🌱',
        color: '#2E8B57',
        desc: 'Penyiraman otomatis & sensor kebasahan tanah',
        modes: ['smart_agriculture'],
        blocks: [
            { name: 'Apakah Tanah Kering?', desc: 'Mendeteksi saat tanah butuh air', xml: '<block type="sa_soil_dry"></block>', modes: ['smart_agriculture'] },
            { name: 'Kelembapan Tanah (%)', desc: 'Membaca persen kebasahan tanah', xml: '<block type="sa_soil_moisture"></block>', modes: ['smart_agriculture'] },
            { name: 'Pompa Air (Siram Tanaman)', desc: 'Pompa penyiraman tanaman otomatis', xml: '<block type="sa_water_pump"></block>', modes: ['smart_agriculture'] }
        ]
    },
    {
        name: 'Cuaca & Rumah Kaca',
        icon: '☀️',
        color: '#3CB371',
        desc: 'Suhu, kelembapan udara & kipas pendingin',
        modes: ['smart_agriculture'],
        blocks: [
            { name: 'Suhu Rumah Kaca (°C)', desc: 'Membaca derajat panas green house', xml: '<block type="sa_temp"></block>', modes: ['smart_agriculture'] },
            { name: 'Kelembapan Udara (%)', desc: 'Membaca persen kelembapan udara', xml: '<block type="sa_humidity"></block>', modes: ['smart_agriculture'] },
            { name: 'Kipas Pendingin Kebun', desc: 'Nyalakan kipas pendingin greenhouse', xml: '<block type="sa_fan"></block>', modes: ['smart_agriculture'] },
            { name: 'Cuaca Mendung / Redup?', desc: 'Mendeteksi tingkat sinar matahari', xml: '<block type="sa_sensor_cloudy"></block>', modes: ['smart_agriculture'] }
        ]
    },
    {
        name: 'Lampu Tanaman',
        icon: '💡',
        color: '#8A2BE2',
        desc: 'Lampu tumbuh fotosintesis tanaman',
        modes: ['smart_agriculture'],
        blocks: [
            { name: 'Lampu Tumbuh (Grow Light)', desc: 'Nyalakan lampu khusus fotosintesis', xml: '<block type="sa_grow_light"></block>', modes: ['smart_agriculture'] },
            { name: 'Ubah Warna Lampu Tanaman', desc: 'Ubah spektrum warna lampu tanaman', xml: '<block type="sa_grow_light_color"></block>', modes: ['smart_agriculture'] },
            { name: 'Atur Kecerahan Lampu Tanaman', desc: 'Mengatur tingkat intensitas cahaya', xml: '<block type="sa_grow_light_brightness"><value name="BRIGHTNESS"><shadow type="math_number"><field name="NUM">100</field></shadow></value></block>', modes: ['smart_agriculture'] }
        ]
    },
    {
        name: 'Pengusir Hama & Alarm',
        icon: '🦝',
        color: '#E53E3E',
        desc: 'Suara pengusir hama & sirine kebun',
        modes: ['smart_agriculture'],
        blocks: [
            { name: 'Ada Hewan / Hama Masuk Kebun?', desc: 'Mendeteksi hewan liar/burung di kebun', xml: '<block type="sa_sensor_pest"></block>', modes: ['smart_agriculture'] },
            { name: 'Bunyikan Suara Pengusir Hama', desc: 'Suara khusus mengusir burung/hama', xml: '<block type="sa_pest_repeller"></block>', modes: ['smart_agriculture'] },
            { name: 'Bunyikan Sirine Kebun', desc: 'Sirine peringatan gangguan kebun', xml: '<block type="sa_alarm_start"></block>', modes: ['smart_agriculture'] },
            { name: 'Matikan Alarm Kebun', desc: 'Matikan suara pengusir hama/sirine', xml: '<block type="sa_alarm_stop"></block>', modes: ['smart_agriculture'] }
        ]
    },
    {
        name: 'Monitor Kebun',
        icon: '📺',
        color: '#8B008B',
        desc: 'Tampilkan pesan status kebun di layar',
        modes: ['smart_agriculture'],
        blocks: [
            { name: 'Tampilkan Status Kebun di Layar', desc: 'Print tulisan status ke monitor', xml: '<block type="sa_display_print"><value name="TEXT"><shadow type="text"><field name="TEXT">Tanah Lembap</field></shadow></value></block>', modes: ['smart_agriculture'] },
            { name: 'Bersihkan Layar Monitor Kebun', desc: 'Kosongkan layar status kebun', xml: '<block type="sa_display_clear"></block>', modes: ['smart_agriculture'] }
        ]
    },

    // ----------------------------------------------------
    // 5. OTHER MODES (DRONE)
    // ----------------------------------------------------
    {
        name: 'Drone Tello',
        icon: '🚁',
        color: '#FF4D4D',
        desc: 'Terbangkan & kendalikan drone',
        modes: ['drone'],
        blocks: [
            { name: 'Terbang', desc: 'Takeoff Drone', xml: '<block type="drone_takeoff"></block>', modes: ['drone'] },
            { name: 'Mendarat', desc: 'Land Drone', xml: '<block type="drone_land"></block>', modes: ['drone'] },
            { name: 'Berhenti & Hover', desc: 'Stop Drone', xml: '<block type="drone_stop"></block>', modes: ['drone'] },
            { name: 'Gerak Arah', desc: 'Gerak maju/mundur/kiri/kanan/naik/turun', xml: '<block type="drone_move_direction"></block>', modes: ['drone'] },
            { name: 'Rotasi', desc: 'Putar drone', xml: '<block type="drone_rotate"></block>', modes: ['drone'] },
            { name: 'Salto (Flip)', desc: 'Salto 3D', xml: '<block type="drone_flip"></block>', modes: ['drone'] }
        ]
    }
];

if (typeof module !== 'undefined' && module.exports) {
    module.exports = { BLOCK_CATEGORIES };
}
