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
            { name: 'Mainkan Suara', desc: 'Mainkan efek suara', xml: '<block type="audio_play_sound"></block>' }
        ]
    },
    {
        name: 'LED',
        icon: '💡',
        color: '#8A2BE2',
        desc: 'Kontrol lampu dan warna',
        blocks: [
            { name: 'Nyalakan LED', desc: 'Set warna LED', xml: '<block type="led_set_color"></block>' }
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
