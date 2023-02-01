import qbs
import qbs.File
import qbs.Process
import qbs.FileInfo

QtGuiApplication {
	type: "application.output"
	files: ["*.cpp", "*.qrc", "resource/*.rc"]

	property string outputPath: qbs.installRoot == "" ? FileInfo.joinPaths(project.buildDirectory, "install-root") : qbs.installRoot
	property string executableName: name + ".exe"

	Depends { name: "cpp" }

	consoleApplication: false

	Depends { name: "Qt.qml" }
	Depends { name: "Qt.quick" }
	Depends { name: "Qt.widgets" }
	Depends { name: "Qt.webengine" }
	Depends { name: "Qt.quickcontrols2" }

	cpp.cxxFlags: ["/std:c++17"]
	cpp.runtimeLibrary: "dynamic"
	cpp.treatWarningsAsErrors: true

	Rule {
        inputs: "application"
        Artifact {
            filePath: FileInfo.joinPaths(product.outputPath, product.executableName)
            fileTags: "application.output"
        }

        prepare: {
            var cmds = []

            var cmdCopy = new JavaScriptCommand()
            cmdCopy.silent = false
            cmdCopy.description = "copying " + product.executableName
            cmdCopy.sourceCode = function () { File.copy(input.filePath, output.filePath); }
            cmds.push(cmdCopy)

            var cmdDeploy = new JavaScriptCommand()
            cmdDeploy.silent = false
            cmdDeploy.description = "deploying QT libs"

            cmdDeploy.windeployqt = FileInfo.joinPaths(product.moduleProperty("Qt.core", "binPath"), "windeployqt.exe")

            cmdDeploy.args = []
            cmdDeploy.args[0] = "--qmldir"
            cmdDeploy.args[1] = FileInfo.joinPaths(product.moduleProperty("Qt.core", "binPath"), "../qml")
            cmdDeploy.args[2] = "--" + product.qbs.buildVariant
            cmdDeploy.args[3] = output.filePath

            cmdDeploy.sourceCode = function(){
                var process;
                try {
                    process = new Process();
                    process.exec(windeployqt, args, true)
                } finally {
                    if (process)
                        process.close();
                }
            }
            cmds.push(cmdDeploy)

            return cmds
        }
    }
}