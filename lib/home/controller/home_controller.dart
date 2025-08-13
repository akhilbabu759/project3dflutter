import 'package:get/get.dart';
import 'package:project3d/apiservice/api_service.dart';

class HomeController extends GetxController {
  var isLoading = true.obs;
  var modelList = <ModelDetails>[].obs;
  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    fetchModels();
    super.onInit();
  }

  void fetchModels() async {
    try {
      isLoading(true);
      var models = await _apiService.getAllModels();
      modelList.assignAll(models);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load models: $e');
      print('Error fetching models: $e');
    } finally {
      isLoading(false);
    }
  }
}
