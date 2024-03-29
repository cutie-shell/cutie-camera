QT += quick

CONFIG += c++11

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        src/main.cpp

RESOURCES += src/qml/qml.qrc icons/icons.qrc sounds/sounds.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
target.path = /usr/bin
!isEmpty(target.path): INSTALLS += target

desktopfile.files = cutie-camera.desktop
desktopfile.path = /usr/share/applications/

icon.files = cutie-camera.svg
icon.path = /usr/share/icons/hicolor/scalable/apps/

INSTALLS += desktopfile icon
