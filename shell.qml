import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import Niri

ShellRoot {

	// theme
	property color darkBlurple: "#2b303b"
	property color mellow: "#f6b511"
	property color darkMellow: "#ba8e23"
	property color trans: "#00000000"
	property string fontFam: "JetBrainsMono Nerd Font"

	// processes
	property int cpuUsage: 0
	// property int memUsage: 0
	property var lastCpuIdle: 0 
	property var lastCpuTotal: 0
	
	// niri plugin bullshit

    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }
        implicitHeight: 30
        color: trans
	
        Niri {
            id: niri
            Component.onCompleted: connect()

            onConnected: console.log("Connected to niri")
            onErrorOccurred: function(error) {
                console.error("Niri error:", error)
            }
        }

        // workspaces module
        Row { 
            spacing: 10
            anchors {
                left: parent.left
                leftMargin: 5
                verticalCenter: parent.verticalCenter
            }

            Row {
		spacing: 5

                Repeater {
                    model: niri.workspaces

                    Rectangle {
			width: 20
                        height: 30
                        color: trans

                        Text {
                            anchors.centerIn: parent
                            text: model.name || model.index
                            font.family: fontFam
                            color: model.isFocused || model.isActive ? mellow : darkMellow
			    font.pixelSize: 14
			    font.bold: true
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: niri.focusWorkspaceById(model.id)
                            cursorShape: Qt.PointingHandCursor
                        }
		    }
                }
	    }
    	}
	SystemClock {
	id: clock
	precision: SystemClock.Seconds
	}
	
	// clock module
	Text {
		anchors.centerIn: parent
		color: mellow
		font.family: fontFam
		font.pixelSize: 14
		font.bold: true
		text: Qt.formatDateTime(clock.date,"h:mm:ss ~ yy-MM-dd")
	}

	// cpu module
	
	Process {
	id: cpuProc
	command: ["head", "-n", "1", "/proc/stat"]
		stdout: SplitParser {
			onRead: data => {
			if (!data) return
			var p = data.trim().split(/\s+/)
			var idle = parseInt(p[4]) + parseInt(p[5])
			var total = p.slice(1, 8).reduce((a, b) => a + parseInt(b), 0)
			if (lastCpuTotal > 0) {
				cpuUsage = Math.round(100 * (1 - (idle - lastCpuIdle) / (total - lastCpuTotal)))
			}
			lastCpuTotal = total
			lastCpuIdle = idle
			}
			}
	}

	Timer {
		interval: 2000
		running: true
		repeat: true
		onTriggered: {
			if (!cpuProc.running) {
				cpuProc.running = true
			}
		}
	}

	Text {
		anchors {
			right: parent.right
			rightMargin: 10
			verticalCenter: parent.verticalCenter
		}
		text: " " + cpuUsage + "%"
		color: mellow
		font.family: fontFam
		font.pixelSize: 14
		font.bold: true
	}
	//text based outline
	Text {
	        anchors.bottom: parent.bottom
		anchors.bottomMargin: -1
		color: mellow
		font.family: fontFam
		font.pixelSize: 14
		font.bold: true
		text:"_______________/--------------------------------------------------------------\\_________________________/-------------------------------------------------------------------\\__________"

       }
	
	
    }
}





