import 'package:connectapp/models/AllSpaces/enroll_in_space_model.dart';
import 'package:connectapp/models/AllSpaces/get_all_spaces_model.dart'
    as GetAllSpaces;
import 'package:connectapp/repository/AllSpaces/enroll_in_space_rpository.dart';
import 'package:connectapp/utils/utils.dart';
import 'package:connectapp/view_models/controller/allspaces/get_all_spaces_controller.dart';
import 'package:get/get.dart';
import '../../../data/response/status.dart';
import '../userPreferences/user_preferences_screen.dart';

class EnrollSpaceController extends GetxController {
  final _api = EnrollSpaceRepository();
  final _prefs = UserPreferencesViewmodel();
  final enrollmentStatus = <String, bool>{}.obs; // Tracks enrollment status
  final rxRequestStatus = <String, Status>{}.obs; // Tracks API request status
  final allSpacesController = Get.find<AllSpacesController>();
  bool _isEnrolling = false; // Debounce flag

  // Initialize enrollment status for a space
  void initializeEnrollment(String spaceId, List<dynamic>? members) async {
    if (!enrollmentStatus.containsKey(spaceId)) {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.user.id.isEmpty) {
        // log("initializeEnrollment: User not authenticated, cannot check enrollment status for spaceId: $spaceId");
        enrollmentStatus[spaceId] = false;
      } else {
        final isEnrolled =
            members?.any((member) => member['user'] == loginData.user.id) ??
                false;
        enrollmentStatus[spaceId] = isEnrolled;
        // log("initializeEnrollment: spaceId: $spaceId, userId: ${loginData.user.id}, isEnrolled: $isEnrolled, members: $members");
      }
      rxRequestStatus[spaceId] = Status.COMPLETED;
    }
  }

  // Get button text based on space status and enrollment
  String getButtonText(String spaceId, String spaceStatus) {
    // log("getButtonText: spaceId: $spaceId, status: $spaceStatus, isEnrolled: ${enrollmentStatus[spaceId]}");
    if (enrollmentStatus[spaceId] == true) {
      if (spaceStatus.toLowerCase() == "live") {
        return "Join Now";
      } else {
        return "Enrolled";
      }
    } else {
      if (spaceStatus.toLowerCase() == "scheduled") {
        return "Enroll";
      } else if (spaceStatus.toLowerCase() == "live") {
        return "View Details";
      } else {
        return "Enrolled ";
      }
    }
  }

  Future<void> enrollInSpace(String spaceId) async {
    if (_isEnrolling || spaceId.isEmpty) {
      Utils.snackBar("Error", "Invalid space ID or enrollment in progress.");
      return;
    }

    if (enrollmentStatus[spaceId] == true) {
      Utils.snackBar("Info", "You are already enrolled in this space");
      return;
    }

    _isEnrolling = true;
    rxRequestStatus[spaceId] = Status.LOADING;
    update();

    try {
      final loginData = await _prefs.getUser();
      if (loginData == null || loginData.token.isEmpty) {
        Utils.snackBar("Error", "User not authenticated. Token not found.");
        rxRequestStatus[spaceId] = Status.ERROR;
        update();
        return;
      }

      // log("Enroll URL: ${ApiUrls.enrollSpaceApi}/$spaceId");
      // log("Enroll Token: ${loginData.token}");

      final response = await _api.enrollSpace(spaceId, loginData.token);
      // log("Enroll API Response: $response");

      final enrollResponse = EnrollResponse.fromJson(response);

      if (enrollResponse.success) {
        enrollmentStatus[spaceId] = true;
        rxRequestStatus[spaceId] = Status.COMPLETED;

        // Update AllSpacesController with new space data
        if (enrollResponse.space != null) {
          final updatedSpace = enrollResponse.space!;
          final currentSpaces = allSpacesController.spaces;
          final spaceIndex = currentSpaces.indexWhere((s) => s.sId == spaceId);

          if (spaceIndex != -1) {
            currentSpaces[spaceIndex] = GetAllSpaces.Spaces(
              sId: updatedSpace.id,
              title: updatedSpace.title,
              description: updatedSpace.description,
              creator: currentSpaces[spaceIndex].creator,
              tags: updatedSpace.tags,
              status: updatedSpace.status ??
                  currentSpaces[spaceIndex].status, // Preserve status
              startTime: updatedSpace.startTime,
              totalJoined: updatedSpace.totalJoined,
              members: updatedSpace.members
                  ?.map((m) => {
                        'user': m.user,
                        'role': m.role,
                        'kicked': m.kicked ?? false,
                        '_id': m.id,
                        'joinedAt': m.joinedAt,
                      })
                  .toList(),
              createdAt: updatedSpace.createdAt,
              updatedAt: updatedSpace.updatedAt,
              // v: updatedSpace.v,
            );
            allSpacesController
                .setSpaces(currentSpaces.toList()); // Ensure reactivity
            allSpacesController.update(); // Trigger UI update
          }
        }

        Utils.snackBar(
          enrollResponse.message,
          "Success",
        );
      } else {
        if (enrollResponse.message.toLowerCase().contains("already enrolled")) {
          enrollmentStatus[spaceId] = true;
          rxRequestStatus[spaceId] = Status.COMPLETED;
          Utils.snackBar("Info", enrollResponse.message);
        } else {
          Utils.snackBar("Error", enrollResponse.message);
          rxRequestStatus[spaceId] = Status.ERROR;
        }
      }
    } catch (e) {
      // log("Enroll API Error: $e", stackTrace: stackTrace);
      Utils.snackBar(
        "$e",
        "Info",
      );
      rxRequestStatus[spaceId] = Status.ERROR;
    } finally {
      _isEnrolling = false;
      update();
    }
  }
}
