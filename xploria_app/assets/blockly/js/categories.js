/**
 * Block Categories Data Schema (mBlock Style)
 * Xploria v3 - Thematic Kits Architecture
 */
const BLOCK_CATEGORIES = [
    // ----------------------------------------------------
    // FUNDAMENTAL CATEGORIES (ALWAYS AVAILABLE)
    // ----------------------------------------------------
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
        name: 'Events',
        icon: '🏁',
        color: '#FFBF00',
        desc: 'Pemicu (Triggers)',
        blocks: [
            { name: 'Saat Dimulai', desc: 'Dijalankan saat mulai', xml: '<block type="event_when_start"></block>' }
        ]
    },
    {
        name: 'Control',
        icon: '⚙️',
        color: '#FFAB19',
        desc: 'Kontrol alur program',
        blocks: [
            { name: 'Ulangi Sebanyak', desc: 'Loop N kali', xml: '<block type="controls_repeat_ext"><value name="TIMES"><shadow type="math_number"><field name="NUM">10</field></shadow></value></block>' },
            { name: 'Ulangi Selama', desc: 'Loop While', xml: '<block type="controls_whileUntil"></block>' },
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
        color: '#FF8C1A',
        desc: 'Penyimpan nilai',
        blocks: [
            { name: 'Variabel (Built-in)', desc: 'Variabel Blockly', xml: '<block type="variables_get"></block>' }
            // Custom Variable Blocks are typically injected dynamically by the toolbox
        ]
    },
    
    // ----------------------------------------------------
    // THEMATIC KITS CATEGORIES (SHOWN CONDITIONALLY)
    // ----------------------------------------------------
    {
        name: 'Drone Tello',
        icon: '🚁',
        color: '#FF4D4D',
        desc: 'Terbangkan drone',
        moduleCategory: 'drone',
        blocks: [
            { name: 'Terbang', desc: 'Takeoff', xml: '<block type="drone_takeoff"></block>' },
            { name: 'Mendarat', desc: 'Land', xml: '<block type="drone_land"></block>' },
            { name: 'Maju', desc: 'Gerak maju (cm)', xml: '<block type="drone_move"></block>' }
        ]
    },
    {
        name: 'Smart City',
        icon: '🏙️',
        color: '#FFD700',
        desc: 'Infrastruktur kota publik',
        moduleCategory: 'smart_city',
        blocks: [
            { name: 'Atur Lampu Lalu Lintas', desc: 'Merah/Kuning/Hijau', xml: '<block type="city_traffic_light"></block>' },
            { name: 'Atur Lampu Jalan', desc: 'Auto/On/Off', xml: '<block type="city_street_light"></block>' },
            { name: 'Palang Parkir', desc: 'Buka/Tutup', xml: '<block type="city_parking_gate"></block>' },
            { name: 'Cek Kapasitas Tempat Sampah', desc: '% Penuh', xml: '<block type="city_trash_level"></block>' },
            { name: 'Cek Kualitas Udara', desc: 'Level Polusi', xml: '<block type="city_air_quality"></block>' }
        ]
    },
    {
        name: 'Smart Living',
        icon: '🏠',
        color: '#005CFF',
        desc: 'Otomatisasi rumah pintar',
        moduleCategory: 'smart_home',
        blocks: [
            { name: 'Nyalakan Lampu', desc: 'LED Toggle', xml: '<block type="iot_led_toggle"></block>' },
            { name: 'Apakah Ada Gerakan', desc: 'Sensor PIR', xml: '<block type="sensor_motion"></block>' }
            // Asumsikan ada blok pintu/alarm di custom_blocks / smart_home_blocks
        ]
    },
    {
        name: 'Smart Agriculture',
        icon: '🌾',
        color: '#2E8B57',
        desc: 'Otomatisasi perkebunan',
        moduleCategory: 'smart_agriculture',
        blocks: [
            { name: 'Baca Kelembapan Tanah', desc: 'Moisture (%)', xml: '<block type="agri_soil_moisture"></block>' },
            { name: 'Pompa Air', desc: 'Siram Tanaman', xml: '<block type="agri_water_pump"></block>' },
            { name: 'Lampu Tumbuh', desc: 'Grow Light', xml: '<block type="agri_grow_light"></block>' },
            { name: 'Baca Suhu', desc: 'Suhu (°C)', xml: '<block type="agri_greenhouse_temp"></block>' },
            { name: 'Baca Kelembapan Udara', desc: 'Humidity (%)', xml: '<block type="agri_greenhouse_humidity"></block>' }
        ]
    },
    {
        name: 'Smart Mobility',
        icon: '🚗',
        color: '#4169E1',
        desc: 'Kendaraan logistik cerdas',
        moduleCategory: 'smart_mobility',
        blocks: [
            { name: 'Jalankan Kendaraan', desc: 'Maju/Mundur', xml: '<block type="mobility_drive"></block>' },
            { name: 'Belok Kendaraan', desc: 'Kanan/Kiri', xml: '<block type="mobility_turn"></block>' },
            { name: 'Rem Darurat', desc: 'Stop Kendaraan', xml: '<block type="mobility_stop"></block>' },
            { name: 'Cek Garis Hitam', desc: 'Line Follower', xml: '<block type="mobility_check_line"></block>' },
            { name: 'Jarak Halangan', desc: 'Ultrasonik depan', xml: '<block type="mobility_obstacle_distance"></block>' }
        ]
    },
    {
        name: 'Smart Industry',
        icon: '🏭',
        color: '#708090',
        desc: 'Otomasi pabrik',
        moduleCategory: 'smart_industry',
        blocks: [
            { name: 'Ban Berjalan', desc: 'Conveyor Belt', xml: '<block type="industry_conveyor"></block>' },
            { name: 'Hitung Barang Lewat', desc: 'Item Counter', xml: '<block type="industry_item_counter"></block>' },
            { name: 'Cek Suhu Mesin', desc: 'Cegah Overheat', xml: '<block type="industry_machine_temp"></block>' },
            { name: 'Tombol Darurat', desc: 'Emergency Stop', xml: '<block type="industry_emergency_stop"></block>' },
            { name: 'Sirine Pabrik', desc: 'Alarm Pabrik', xml: '<block type="industry_siren"></block>' }
        ]
    },
    {
        name: 'Smart Society',
        icon: '🤝',
        color: '#FF4500',
        desc: 'Interaksi publik darurat',
        moduleCategory: 'smart_society',
        blocks: [
            { name: 'Tombol SOS', desc: 'Emergency Panic Button', xml: '<block type="society_sos_button"></block>' },
            { name: 'Siarkan Pesan', desc: 'Broadcast Informasi', xml: '<block type="society_broadcast_message"><value name="MESSAGE"><shadow type="text"><field name="TEXT">Waspada Bencana</field></shadow></value></block>' },
            { name: 'Cek Keramaian Area', desc: 'Crowd Detection', xml: '<block type="society_crowd_detection"></block>' }
        ]
    },
    
    // ----------------------------------------------------
    // HARDWARE RAW CATEGORIES (OPTIONAL/ADVANCED)
    // ----------------------------------------------------
    {
        name: 'Pin',
        icon: '🔌',
        color: '#FF6347',
        desc: 'Kontrol input/output dasar',
        moduleCategory: 'hardware',
        blocks: [
            { name: 'Nyalakan / Matikan Pin', desc: 'Nyala/Mati', xml: '<block type="pin_set_digital"></block>' },
            { name: 'Baca Status Pin', desc: 'Membaca tombol', xml: '<block type="pin_read_digital"></block>' },
            { name: 'Atur Kecerahan / Kecepatan', desc: 'PWM 0-255', xml: '<block type="pin_set_analog"><value name="VAL"><shadow type="math_number"><field name="NUM">255</field></shadow></value></block>' },
            { name: 'Baca Nilai Sensor', desc: 'Membaca potensiometer', xml: '<block type="pin_read_analog"></block>' },
            { name: 'Atur Pin sebagai Sensor', desc: 'Input Mode', xml: '<block type="pin_mode_input"></block>' },
            { name: 'Atur Pin sebagai Output', desc: 'Output Mode', xml: '<block type="pin_mode_output"></block>' }
        ]
    }
];

if (typeof module !== 'undefined' && module.exports) {
    module.exports = { BLOCK_CATEGORIES };
}
