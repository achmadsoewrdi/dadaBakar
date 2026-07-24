/**
 * Block Categories Data Schema (mBlock Style)
 */
const BLOCK_CATEGORIES = [
    {
        name: 'Audio',
        icon: '🔊',
        color: '#D65CD6',
        desc: 'Kontrol suara dan musik',
        blocks: [
            { name: 'Mainkan (Tunggu)', desc: 'Mainkan sampai selesai', xml: '<block type="audio_play_until_done"></block>' },
            { name: 'Mainkan Suara', desc: 'Mainkan efek suara', xml: '<block type="audio_play_sound"></block>' },
            { name: 'Mulai Merekam', desc: 'Mulai rekam suara', xml: '<block type="audio_start_recording"></block>' },
            { name: 'Berhenti Merekam', desc: 'Berhenti rekam', xml: '<block type="audio_stop_recording"></block>' },
            { name: 'Mainkan Rekaman (T)', desc: 'Mainkan rekaman (tunggu)', xml: '<block type="audio_play_recording_until_done"></block>' },
            { name: 'Mainkan Rekaman', desc: 'Mainkan hasil rekaman', xml: '<block type="audio_play_recording"></block>' },
            { name: 'Mainkan Nada', desc: 'Mainkan nada piano', xml: '<block type="audio_play_note"><value name="NOTE"><shadow type="math_number"><field name="NUM">60</field></shadow></value><value name="BEAT"><shadow type="math_number"><field name="NUM">0.25</field></shadow></value></block>' },
            { name: 'Mainkan Drum', desc: 'Mainkan instrumen drum', xml: '<block type="audio_play_drum"><value name="BEAT"><shadow type="math_number"><field name="NUM">0.25</field></shadow></value></block>' },
            { name: 'Tambah Kecepatan', desc: 'Tambah speed audio', xml: '<block type="audio_increase_speed"><value name="SPEED"><shadow type="math_number"><field name="NUM">10</field></shadow></value></block>' },
            { name: 'Atur Kecepatan', desc: 'Set speed audio', xml: '<block type="audio_set_speed"><value name="SPEED"><shadow type="math_number"><field name="NUM">100</field></shadow></value></block>' },
            { name: 'Kecepatan', desc: 'Nilai kecepatan', xml: '<block type="audio_speed_reporter"></block>' },
            { name: 'Tambah Volume', desc: 'Tambah volume', xml: '<block type="audio_increase_volume"><value name="VOL"><shadow type="math_number"><field name="NUM">10</field></shadow></value></block>' },
            { name: 'Atur Volume', desc: 'Set volume suara', xml: '<block type="audio_set_volume"><value name="VOL"><shadow type="math_number"><field name="NUM">30</field></shadow></value></block>' },
            { name: 'Volume (%)', desc: 'Nilai volume (%)', xml: '<block type="audio_volume_reporter"></block>' },
            { name: 'Suara Hz (Durasi)', desc: 'Frekuensi spesifik', xml: '<block type="audio_play_sound_hz_for"><value name="HZ"><shadow type="math_number"><field name="NUM">700</field></shadow></value><value name="SECS"><shadow type="math_number"><field name="NUM">1</field></shadow></value></block>' },
            { name: 'Suara Hz', desc: 'Frekuensi terus menerus', xml: '<block type="audio_play_sound_hz"><value name="HZ"><shadow type="math_number"><field name="NUM">700</field></shadow></value></block>' },
            { name: 'Hentikan Semua', desc: 'Stop semua suara', xml: '<block type="audio_stop_all"></block>' }
        ]
    },
    {
        name: 'LED',
        icon: '💡',
        color: '#8A2BE2',
        desc: 'Kontrol lampu dan warna',
        blocks: [
            { name: 'Mainkan Animasi', desc: 'Mainkan animasi LED', xml: '<block type="led_play_animation_until_done"></block>' },
            { name: 'Tampilkan Warna', desc: 'Tampilkan 5 warna LED', xml: '<block type="led_display_5"></block>' },
            { name: 'Geser LED', desc: 'Geser posisi LED', xml: '<block type="led_roll_right"><value name="NUM"><shadow type="math_number"><field name="NUM">1</field></shadow></value></block>' },
            { name: 'Tampilkan Warna (T)', desc: 'Tampilkan warna dengan durasi', xml: '<block type="led_display_color_for"><value name="SECS"><shadow type="math_number"><field name="NUM">1</field></shadow></value></block>' },
            { name: 'Tampilkan Warna ke', desc: 'Tampilkan warna terus menerus', xml: '<block type="led_display_color"></block>' },
            { name: 'Tampilkan RGB (T)', desc: 'Tampilkan RGB dengan durasi', xml: '<block type="led_display_rgb_for"><value name="R"><shadow type="math_number"><field name="NUM">255</field></shadow></value><value name="G"><shadow type="math_number"><field name="NUM">0</field></shadow></value><value name="B"><shadow type="math_number"><field name="NUM">0</field></shadow></value><value name="SECS"><shadow type="math_number"><field name="NUM">1</field></shadow></value></block>' },
            { name: 'Tampilkan RGB', desc: 'Tampilkan nilai RGB terus', xml: '<block type="led_display_rgb"><value name="R"><shadow type="math_number"><field name="NUM">255</field></shadow></value><value name="G"><shadow type="math_number"><field name="NUM">0</field></shadow></value><value name="B"><shadow type="math_number"><field name="NUM">0</field></shadow></value></block>' },
            { name: 'Tambah Kecerahan', desc: 'Tambah % kecerahan', xml: '<block type="led_increase_brightness"><value name="BRIGHTNESS"><shadow type="math_number"><field name="NUM">10</field></shadow></value></block>' },
            { name: 'Atur Kecerahan', desc: 'Set tingkat kecerahan', xml: '<block type="led_set_brightness"><value name="BRIGHTNESS"><shadow type="math_number"><field name="NUM">30</field></shadow></value></block>' },
            { name: 'Kecerahan (%)', desc: 'Nilai kecerahan saat ini', xml: '<block type="led_brightness_reporter"></block>' },
            { name: 'Matikan LED', desc: 'Matikan lampu LED target', xml: '<block type="led_turn_off"></block>' }
        ]
    },
    {
        name: 'Motion Sensing',
        icon: '🧭',
        color: '#4C97FF',
        desc: 'Sensor gerak dan orientasi',
        blocks: [
            { name: 'Apakah diguncang?', desc: 'Sensor guncangan', xml: '<block type="motion_is_shaking"></block>' }
        ]
    },
    {
        name: 'Pin',
        icon: '🔌',
        color: '#FF6347',
        desc: 'Kontrol input/output dasar',
        blocks: [
            { name: 'Setel Pin Digital', desc: 'Nyala/Mati', xml: '<block type="pin_set_digital"></block>' },
            { name: 'Setel Pin Analog', desc: 'PWM 0-255', xml: '<block type="pin_set_analog"><value name="VAL"><shadow type="math_number"><field name="NUM">255</field></shadow></value></block>' },
            { name: 'Baca Pin Digital', desc: 'Membaca tombol', xml: '<block type="pin_read_digital"></block>' },
            { name: 'Baca Pin Analog', desc: 'Membaca potensiometer', xml: '<block type="pin_read_analog"></block>' }
        ]
    },
    {
        name: 'Motor',
        icon: '⚙️',
        color: '#4169E1',
        desc: 'Penggerak robot',
        blocks: [
            { name: 'Putar Servo', desc: 'Derajat 0-180', xml: '<block type="motor_set_servo"><value name="DEGREE"><shadow type="math_number"><field name="NUM">90</field></shadow></value></block>' },
            { name: 'Motor DC', desc: 'Jalankan motor DC', xml: '<block type="motor_dc_speed"><value name="SPEED"><shadow type="math_number"><field name="NUM">100</field></shadow></value></block>' },
            { name: 'Hentikan Motor DC', desc: 'Stop motor', xml: '<block type="motor_dc_stop"></block>' }
        ]
    },
    {
        name: 'Sensor',
        icon: '🌡️',
        color: '#2E8B57',
        desc: 'Sensor lingkungan',
        blocks: [
            { name: 'Jarak Ultrasonik', desc: 'Jarak (cm)', xml: '<block type="sensor_ultrasonic"></block>' },
            { name: 'Sensor Garis', desc: 'Garis Hitam/Putih', xml: '<block type="sensor_line_follower"></block>' },
            { name: 'Intensitas Cahaya', desc: 'LDR (%)', xml: '<block type="sensor_light"></block>' },
            { name: 'Suhu', desc: 'DHT11 (°C)', xml: '<block type="sensor_temperature"></block>' }
        ]
    },
    {
        name: 'Display',
        icon: '📺',
        color: '#8B008B',
        desc: 'Layar LCD/OLED',
        blocks: [
            { name: 'Tampilkan Teks', desc: 'Print teks', xml: '<block type="display_print"><value name="TEXT"><shadow type="text"><field name="TEXT">Halo!</field></shadow></value></block>' },
            { name: 'Teks Ukuran', desc: 'Font size', xml: '<block type="display_print_size"><value name="TEXT"><shadow type="text"><field name="TEXT">Halo!</field></shadow></value></block>' },
            { name: 'Bersihkan Layar', desc: 'Hapus layar', xml: '<block type="display_clear"></block>' },
            { name: 'Grafik Data', desc: 'Plot grafik', xml: '<block type="display_graph"><value name="VAL"><shadow type="math_number"><field name="NUM">50</field></shadow></value></block>' }
        ]
    },
    {
        name: 'LAN',
        icon: '🌐',
        color: '#0FBD8C',
        desc: 'Komunikasi jaringan lokal',
        blocks: [
            { name: 'Kirim Pesan', desc: 'Kirim pesan ke jaringan', xml: '<block type="lan_send_message"><value name="MESSAGE"><shadow type="text"><field name="TEXT">Halo</field></shadow></value></block>' }
        ]
    },
    {
        name: 'AI',
        icon: '🤖',
        color: '#00C3DA',
        desc: 'Kecerdasan Buatan',
        blocks: [
            { name: 'Kenali Suara', desc: 'Speech to text', xml: '<block type="ai_recognize_speech"></block>' }
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
            { name: 'Tunggu (detik)', desc: 'Jeda program', xml: '<block type="delay_seconds"><value name="SECONDS"><shadow type="math_number"><field name="NUM">1</field></shadow></value></block>' },
            { name: 'Ulangi', desc: 'Loop N kali', xml: '<block type="controls_repeat_ext"><value name="TIMES"><shadow type="math_number"><field name="NUM">10</field></shadow></value></block>' },
            { name: 'Jika (If)', desc: 'Percabangan', xml: '<block type="controls_if"></block>' }
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
            { name: 'Angka', desc: 'Input angka', xml: '<block type="math_number"><field name="NUM">0</field></block>' },
            { name: 'Teks', desc: 'Input teks', xml: '<block type="text"><field name="TEXT"></field></block>' }
        ]
    },
    {
        name: 'Variabel',
        icon: '📦',
        color: '#FF8C1A',
        desc: 'Simpan data khusus',
        isVariableCategory: true,
        blocks: [] // Di-generate dinamis
    },
    {
        name: 'Blok Saya',
        icon: '🧱',
        color: '#FF6680',
        desc: 'Fungsi kustom buatanmu',
        isMyBlocksCategory: true,
        blocks: [] // Di-generate dinamis
    }
];
