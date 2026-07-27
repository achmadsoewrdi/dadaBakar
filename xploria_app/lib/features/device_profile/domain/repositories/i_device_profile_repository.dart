import '../../../devices/domain/models/device_profile_model.dart';

abstract class IDeviceProfileRepository {
  Future<List<DeviceProfileModel>> getDeviceProfiles();
}
