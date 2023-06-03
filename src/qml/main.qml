import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.12
import QtGraphicalEffects 1.0
import QtMultimedia 5.15
import Qt.labs.settings 1.0

import Cutie 1.0

CutieWindow {
    id: window
    width: 400
    height: 800
    visible: true
    title: "Camera"

    Settings {
        id: settings
        property int cameraId: 0
        property var resArray: []
    }

    ListModel {
        id: resolutionModel
    }
    
    Item {
        id: cslate

        state: "PhotoCapture"

        states: [
           State {
               name: "PhotoCapture"
           },
           State {
               name: "VideoCapture"
           }
        ]
    }

    SoundEffect {
           id: sound
           source: "sounds/camera-shutter.wav"
    }

    initialPage: CutiePage {  
        VideoOutput {
            id: viewfinder
            anchors.fill: parent

            autoOrientation: true
            source: camera

            Rectangle {
                id: focusPointRect
                border {
                  width: 4
                  color: "steelblue"
                }
                color: "transparent"
                radius: 90
                width: 100
                height: 100
                visible: false

                Timer {
                    id: visTm
                    interval: 2000; running: false; repeat: false
                    onTriggered: focusPointRect.visible = false
                }
            }
        }
    }

    Camera {
        id: camera

        focus {
            focusMode: Camera.FocusMacro
            focusPointMode: Camera.FocusPointCustom
        }

        Component.onCompleted: {

            if(!settings.resArray.length || (settings.resArray.length < QtMultimedia.availableCameras.length)) {
                var arr = []
                for (var i = 0; i < QtMultimedia.availableCameras.length; i++){
                    arr.push(0)
                }
                settings.setValue("resArray", arr)
            }

            if(!settings.cameraId)
                settings.cameraId = camera.deviceId

            camera.deviceId = settings.cameraId
            resolutionModel.clear()
            for (var p in camera.imageCapture.supportedResolutions){
                resolutionModel.append({"widthR": camera.imageCapture.supportedResolutions[p].width, "heightR": camera.imageCapture.supportedResolutions[p].height})
            }
            camera.imageCapture.resolution = camera.imageCapture.supportedResolutions[settings.resArray[camera.deviceId]]
        }
    }

    Image {
        id: shutterBtn
        width: 90
        height: 90
        anchors.bottom: parent.bottom
        source: "icons/shutter_stills@27.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 8
        fillMode: Image.PreserveAspectFit
        MouseArea{
            anchors.fill: parent
            onClicked: {
                if (cslate.state == "PhotoCapture") {
                    camera.imageCapture.capture();
                    sound.play();
                } else {
                    if (camera.videoRecorder.recorderState === CameraRecorder.RecordingState) {
                        camera.videoRecorder.stop();
                        shutterBtn.source="icons/record_video@27.png";
                    } else {
                        camera.videoRecorder.record();
                        shutterBtn.source="icons/record_video_stop@27.png";
                    }
                }
            }
        }
    }

    Image {
        id: modeBtn
        anchors.left: parent.left
        anchors.margins: 20
        anchors.verticalCenter: shutterBtn.verticalCenter
        source: "icons/record_video@27.png"
        sourceSize.height: 40
        sourceSize.width: 40
        width: 40
        height: 40
        fillMode: Image.PreserveAspectFit

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked: {
                camera.cameraState = Camera.UnloadedState;
                if (cslate.state === "PhotoCapture") {
                    cslate.state = "VideoCapture";
                    camera.captureMode = Camera.CaptureVideo;
                    modeBtn.source = "icons/shutter_stills@27.png";
                    shutterBtn.source = "icons/record_video@27.png";
                } else {
                    cslate.state = "PhotoCapture";
                    camera.captureMode = Camera.CaptureStillImage;
                    modeBtn.source = "icons/record_video@27.png";
                    shutterBtn.source = "icons/shutter_stills@27.png";
                }
                camera.cameraState = Camera.ActiveState;
                camera.videoRecorder.resolution = camera.viewfinder.resolution;
            }
        }
    }

    Image {
        id: camSwitchBtn
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.margins: 20
        width: 40
        height: 40
        source: "icons/icon-s-sync.svg"
        fillMode: Image.PreserveAspectFit
        sourceSize.height: 40
        sourceSize.width: 40
        visible: camera.position !== Camera.UnspecifiedPosition

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (camera.position === Camera.BackFace) {
                    camera.position = Camera.FrontFace;
                } else if (camera.position === Camera.FrontFace) {
                    camera.position = Camera.BackFace;
                }
            }
        }
    }

    Item {
        id: camZoom
        onScaleChanged: {
            camera.setDigitalZoom(scale)
        }
    }

    PinchArea
    {
        MouseArea
        {
            id:dragArea
            hoverEnabled: true
            anchors.fill: parent
            scrollGestureEnabled: false

            onClicked: {
                camera.focus.customFocusPoint = Qt.point(mouse.x/dragArea.width, mouse.y/dragArea.height)
                camera.focus.focusMode = Camera.FocusMacro
                focusPointRect.visible = true
                focusPointRect.x = mouse.x - (focusPointRect.width/2)
                focusPointRect.y = mouse.y - (focusPointRect.height/2)
                visTm.start()
                camera.searchAndLock()
            }
        }
        anchors.fill:parent
        pinch.dragAxis: pinch.XAndYAxis
        pinch.target: camZoom
        pinch.maximumScale: camera.maximumDigitalZoom
        pinch.minimumScale: 0

        onPinchStarted: {
        }

        onPinchUpdated: {
        }
    }

    Rectangle {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: 5
        width: 200
        height: 40
        color: "#99000000"
        border.width: 2
        border.color: "lightblue"

        Text {
            text: camera.viewfinder.resolution.width + "x" + camera.viewfinder.resolution.height

            anchors.fill: parent
            anchors.margins: 5
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            color: "white"
            font.bold: true
            style: Text.Raised
            styleColor: "black"
            font.pixelSize: 14
        }

        ResolutionListPopup {
            id: popup
            anchors.right: parent.right
            anchors.top: parent.bottom
            anchors.bottomMargin: 16
            visible: opacity > 0
            onCurrentValueChanged: {
                camera.imageCapture.resolution = camera.imageCapture.supportedResolutions[currentValue]
                settings.resArray[camera.deviceId] = currentValue
                settings.setValue("resArray", settings.resArray)
                popup.toggle()
            }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                popup.toggle()
            }
        }
    }
}