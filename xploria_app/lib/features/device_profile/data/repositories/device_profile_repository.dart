import '../../domain/repositories/i_device_profile_repository.dart';
import '../../../devices/domain/models/device_profile_model.dart';
import '../../../auth/data/services/auth_storage_service.dart';

class DeviceProfileRepository implements IDeviceProfileRepository {
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
}
