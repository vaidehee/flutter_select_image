import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  final PermissionHandler _permissionHandler = PermissionHandler();
  var shouldShowRational = true;

  Future<bool> _requestPermission(PermissionGroup permission) async {
    var result = await _permissionHandler.requestPermissions([permission]);
    if (result[permission] == PermissionStatus.granted) {
      print("inside granted");
      return true;
    }
    return false;
  }

  Future<bool> shouldShowReqPermission(PermissionGroup permission) async {
    shouldShowRational = await _permissionHandler
        .shouldShowRequestPermissionRationale(permission);
    return shouldShowRational;
  }

  /// Requests the users permission for camara access
  Future<bool> requestCamaraPermission(
      {Function onPermissionDenied,
      Function onPermissionGranted,
      Function onNeverAskAgainChecked}) async {
    bool shouldshow = await _permissionHandler
        .shouldShowRequestPermissionRationale(Platform.isAndroid
            ? PermissionGroup.camera
            : PermissionGroup.photos);
    print("shouldShow::${shouldshow}");
    var granted = await _requestPermission(
        Platform.isAndroid ? PermissionGroup.camera : PermissionGroup.photos);
    print("granted:::::${granted.toString()}");

    if (!shouldshow && !granted) {
      onNeverAskAgainChecked();
    } else if (!granted) {
      onPermissionDenied();
    } else {
      onPermissionGranted();
    }

    return granted;
  }

  Future<bool> hasCamaraPermission() async {
    return hasPermission(
      PermissionGroup.camera
//        Platform.isAndroid ? PermissionGroup.camera : PermissionGroup.photos
    );
  }
  Future<bool> hasPhotosPermission() async {
    return hasPermission(
        PermissionGroup.photos
//        Platform.isAndroid ? PermissionGroup.camera : PermissionGroup.photos
    );
  }

  Future<bool> hasPermission(PermissionGroup permission) async {
    var permissionStatus =
        await _permissionHandler.checkPermissionStatus(permission);
      print(permissionStatus);
    switch(permissionStatus)
    {
      case PermissionStatus.granted:
        return true;
            break;
            case PermissionStatus.denied:
        return false;
            break;
    }
    //return permissionStatus == PermissionStatus.granted;
  }


  Future<bool> isUnknown(PermissionGroup permission)async{

    var unknownStatuss=await _permissionHandler.checkPermissionStatus(permission);
switch(unknownStatuss)
{
  case PermissionStatus.unknown:
    return true;
    break;
}
  }

}
