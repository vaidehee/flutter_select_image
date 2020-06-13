import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SelectImageScreen extends StatefulWidget {
  @override
  _SelectImageScreenState createState() => _SelectImageScreenState();
}

class _SelectImageScreenState extends State<SelectImageScreen> {
  File imageFile;
  bool isProfilePicSelected = false;
  bool isCameraPermission;
  bool isPhotosPermission;
  String fileName;
  String profilePic = "";
  final PermissionHandler _permissionHandler = PermissionHandler();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                  onTap: () {
                    showOptionActionSheet();
                  },
                  child: getUserProfilePic())
            ],
          ),
        ),
      ),
    );
  }

  Widget getUserProfilePic() {
    if (isProfilePicSelected) {
      return Container(
        margin: EdgeInsets.only(top: 35.0, bottom: 35.0),
        child: Stack(
          children: <Widget>[
            Container(
              height: 120.0,
              width: 120.0,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2.0),
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: imageFile == null
                        ? "images/profilepic_placeholder.png"
                        : FileImage(imageFile),
                  )),
            ),

            Positioned(
              right: 5.0,
              bottom: 5.0,
              child: Container(
                  height: 35.0,
                  width: 35.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey,
                  ),
                  padding: EdgeInsets.all(5.0),
                  child: Icon(Icons.photo_camera)),
            )
          ],
        ),
      );
    } else {
      return Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          Container(
            height: 120.0,
            width: 120.0,
            margin: EdgeInsets.only(top: 5.0),
            //profilePic is  your profile image that you fetch from api ,since we are not working with api, this will be blank on initialization
            child: profilePic != null && profilePic != "" ? CachedNetworkImage(
                imageUrl: "$profilePic",
                imageBuilder: (context, imageProvider) =>
                    Container(
                      width: 120,
                      height: 120,
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.grey, width: 1.0),
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                placeholder: (context, url) =>
                    getPlaceHolder(height: 120, width: 120)
            ) : getPlaceHolder(height: 120, width: 120),
          ),
          Container(
              height: 30.0,
              width: 30.0,
              margin: const EdgeInsets.only(right: 10.0),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey
              ),
              child: Icon(Icons.photo_camera, color: Colors.black,)
          )
        ],
      );
    }
  }

  Widget getPlaceHolder({double height = 40, double width = 40}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: Colors.grey, width: 1.0),
      ),
      child: Image.asset(
        "images/profilepic_placeholder.png",
        width: width,
        height: height,
      ),
    );
  }

  void showOptionActionSheet() {
    showModalBottomSheet(context: context,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) {
          return CupertinoActionSheet(

              title: Text("Choose an Option", textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              actions: <Widget>[

                CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.pop(context);
                      selectedProfilePicFromCamera();
                    },
                    child: Text("Camera", textAlign: TextAlign.center,)
                ),

                CupertinoActionSheetAction(
                    onPressed: () {
                      Navigator.of(context).pop();
                      selectedProfilePicFromGallery();
                    },
                    child: Text("Gallery", textAlign: TextAlign.center,)
                ),

              ],
              cancelButton: CupertinoActionSheetAction(onPressed: () {
                Navigator.pop(context);
              },
                  child: Text("Cancel")
              ));
        });
  }

  void selectedProfilePicFromCamera() async{
    if (Platform.isIOS && isCameraPermission == false)
      {
        showAllowPermissionDialog(true);
      }
    else
      {
        File selectedFile= await ImagePicker.pickImage(source: ImageSource.camera);
        File croppedFile = await ImageCropper.cropImage(
            sourcePath: selectedFile.path,
            aspectRatio:CropAspectRatio(ratioX: 1,ratioY: 1),
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
            ],
            androidUiSettings: AndroidUiSettings(
                hideBottomControls: true,
                toolbarTitle: '',
                toolbarColor: Colors.grey,
                activeControlsWidgetColor: Colors.grey,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true),
            iosUiSettings: IOSUiSettings(
              minimumAspectRatio: 1.0,
            )
        );
        if (selectedFile != null) {
          if(!mounted){
            return;
          }
          setState(() {
            if(croppedFile==null)
            {
              isProfilePicSelected=false;
            }
            else
            {
              this.imageFile=croppedFile;
              isProfilePicSelected = true;
            }
            });
        }
      }
  }

  void selectedProfilePicFromGallery() async {
    if(Platform.isIOS && isPhotosPermission == false) {
      showAllowPermissionDialog(false);
    }else{
      File selectedFile =
          await ImagePicker.pickImage(source: ImageSource.gallery,);
      File croppedFile = await ImageCropper.cropImage(
          sourcePath: selectedFile.path,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
          ],
          androidUiSettings: AndroidUiSettings(
              hideBottomControls: true,
              activeControlsWidgetColor: Colors.grey,
              toolbarTitle: '',
              toolbarColor: Colors.grey,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          )
      );
      if (selectedFile != null) {
        if(!mounted){
          return;
        }
        setState(() {
          if(croppedFile==null)
          {
            isProfilePicSelected=false;
          }
          else
          {
            this.imageFile=croppedFile;
            isProfilePicSelected = true;
          }
        });
      }
    }

  }

  showAllowPermissionDialog(bool isCameraPermission) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            elevation: 0.0,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              width: MediaQuery.of(context).size.width / 1.3,
              // height:160.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                      margin: EdgeInsets.symmetric(vertical: 5.0),
                      child: isCameraPermission == true?Text(
                        "Camera Permission",textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20.0,color:  Colors.grey),
                      ):Text(
                        "Photos Permission",textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w500,fontSize: 20.0,color: Colors.grey),
                      )
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15.0,horizontal: 5.0),
                    child: isCameraPermission == true?Text("Please allow access to camera permission.",textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15.0,color: Colors.grey)
                    ):Text("Please allow access to gallery permission.",textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.w300,fontSize: 15.0,color: Colors.grey)
                    ),
                  ),
                  Container(
                    child: Divider(
                      color: Colors.grey,
                      height: 4.0,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: FlatButton(
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "Cancel",
                            style: TextStyle(fontWeight: FontWeight.w500,fontFamily: "Helvetica",fontSize: 18.0,color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                      ),
                      Expanded(
                        child: FlatButton(
                          textColor: Colors.white,
                          onPressed: () {
                            Navigator.of(context).pop();
                            _permissionHandler.openAppSettings();
                          },
                          child: Text("Settings",style: TextStyle(
                              fontWeight: FontWeight.w500,
                              fontFamily: "Helvetica",
                              fontSize: 18.0,
                              color: Colors.grey),),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        });
  }

}
