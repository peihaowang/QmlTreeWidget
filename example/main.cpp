#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQmlFileSelector>

int main(int argc, char *argv[])
{
	QGuiApplication app(argc, argv);
#if defined(Q_OS_WIN)
	QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#endif

	QStringList selectors;
#ifdef QT_EXTRA_FILE_SELECTOR
	selectors += QT_EXTRA_FILE_SELECTOR;
#else
	if (app.arguments().contains("-touch"))
	    selectors += "touch";
#endif

	QQmlApplicationEngine engine;
	QQmlFileSelector::get(&engine)->setExtraSelectors(selectors);
	engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
	if (engine.rootObjects().isEmpty())
		return -1;

	return app.exec();
}
