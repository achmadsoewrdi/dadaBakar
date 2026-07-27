import '../../domain/repositories/i_dashboard_repository.dart';
import '../../../projects/domain/models/project_model.dart';
import '../../../device_profile/domain/models/device_profile_model.dart';
import '../../../content/domain/models/learning_module_model.dart';
import '../../../auth/data/data_sources/auth_storage_service.dart';

class DashboardRepository implements IDashboardRepository {
  @override
  Future<List<ProjectModel>> getRecentProjects() async {
    final user = AuthStorageService().currentUser;
    final userId = user?.id ?? 'uuid_demo_user';
    final now = DateTime.now();
    return [
      ProjectModel(
        id: 'proj_01',
        ownerId: userId,
        name: 'Kamera Pintar Robot',
        workspaceXml: '<xml><block type="rpi_camera"></block></xml>',
        generatedCode: 'import cv2\nprint("Raspberry Pi Camera Running")',
        deviceType: 'raspberry_pi',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      ProjectModel(
        id: 'proj_02',
        ownerId: userId,
        name: 'Kontrol Lampu Otomatis',
        workspaceXml: '<xml><block type="orangepi_gpio"></block></xml>',
        generatedCode: 'import OPi.GPIO as GPIO',
        deviceType: 'orange_pi',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      ProjectModel(
        id: 'proj_03',
        ownerId: userId,
        name: 'Smart Agriculture Prototype',
        workspaceXml: '<xml><block type="sensor_temp"></block></xml>',
        generatedCode: 'print("Smart Farm IoT")',
        deviceType: 'arduino',
        // blynkConfigJson: [],
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(minutes: 15)),
      ),
    ];
  }

  @override
  Future<List<DeviceProfileModel>> getDeviceProfiles() async {
    final user = AuthStorageService().currentUser;
    final userId = user?.id ?? 'uuid_demo_user';
    final now = DateTime.now();
    return [
      DeviceProfileModel(
        id: 'dev_01',
        ownerId: userId,
        label: 'Node Raspberry Pi Lab Utama',
        protocol: 'websocket',
        host: '192.168.1.105',
        port: 8080,
        useTls: false,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      DeviceProfileModel(
        id: 'dev_02',
        ownerId: userId,
        label: 'Sensor Robot BLE',
        protocol: 'bluetooth',
        macAddress: 'AA:BB:CC:DD:EE:FF',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }

  @override
  Future<List<LearningModuleModel>> getLearningModules() async {
    final now = DateTime.now();
    return [
      LearningModuleModel(
        id: 'mod_01',
        title: 'Dasar Pemrograman Robotik & IoT',
        description:
            'Pelajari dasar-dasar mengontrol pin GPIO, WiFi, dan sensor pada single board computer.',
        stepsJson: {'steps': 5, 'level': 'Pemula'},
        isPremiumOnly: false,
        createdAt: now.subtract(const Duration(days: 10)),
        imageAsset: 'assets/images/modules/robot.png',
        imageBgColor: '0xFFFFF3E0',
      ),
      LearningModuleModel(
        id: 'mod_02',
        title: 'Kamera AI & Robotik Raspberry Pi',
        description:
            'Membangun sistem pengenal wajah dan kontrol motor otomatis dengan Raspberry Pi.',
        stepsJson: {'steps': 8, 'level': 'Lanjutan'},
        isPremiumOnly: true,
        createdAt: now.subtract(const Duration(days: 7)),
        imageAsset: 'assets/images/modules/car.png',
        imageBgColor: '0xFFE0F7FA',
      ),
      LearningModuleModel(
        id: 'mod_03',
        title: 'Protokol Komunikasi WebSocket & BLE',
        description:
            'Koneksikan hardware secara langsung ke Flutter App menggunakan WebSocket & Bluetooth.',
        stepsJson: {'steps': 6, 'level': 'Menengah'},
        isPremiumOnly: false,
        createdAt: now.subtract(const Duration(days: 4)),
        imageAsset: 'assets/images/modules/board.png',
        imageBgColor: '0xFFE8F5E9',
      ),
    ];
  }
}

