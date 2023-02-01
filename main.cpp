#include <QtWidgets/QApplication>
#include <QtWebEngine>

int main(int argc, char **argv)
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QtWebEngine::initialize();
    QApplication app(argc, argv);
    QQmlApplicationEngine appEngine;
    appEngine.load(QUrl("qrc:/resource/devium_gui.qml"));
    return app.exec();
}
