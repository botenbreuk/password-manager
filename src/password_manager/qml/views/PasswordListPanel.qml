import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import "../components"

Rectangle {
    id: listPanel
    Layout.fillWidth: true
    Layout.fillHeight: true
    Layout.preferredWidth: 70
    color: "#252525"
    radius: 12

    property var model: null
    property string searchQuery: ""
    property bool showFavoritesOnly: false
    property bool editMode: false
    property int editingRow: -1
    property int totpRefreshTrigger: 0
    property int totpRemainingSeconds: 30

    readonly property int count: passwordList.count

    signal editRequested(int row)
    signal deleteRequested(int row)
    signal toggleFavoriteRequested(int row)
    signal copyUsernameRequested(int row)
    signal copyPasswordRequested(int row)
    signal copyTotpRequested(int row)
    signal openWebsiteRequested(int row)
    signal toggleVisibilityRequested(int row)

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#40000000"
        shadowBlur: 0.5
        shadowVerticalOffset: 2
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // Panel header
        Rectangle {
            Layout.fillWidth: true
            height: 52
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 10

                Text {
                    text: listPanel.searchQuery !== "" ? "Search Results" : (listPanel.showFavoritesOnly ? "Favorites" : "Saved Passwords")
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    color: "#ffffff"
                }

                Rectangle {
                    width: countText.width + 16
                    height: 24
                    radius: 12
                    color: "#1976D2"
                    visible: passwordList.count > 0

                    Text {
                        id: countText
                        anchors.centerIn: parent
                        text: passwordList.count
                        font.pixelSize: 13
                        font.weight: Font.Bold
                        color: "#ffffff"
                    }
                }

                Item { Layout.fillWidth: true }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                height: 1
                color: "#3a3a3a"
            }
        }

        // Column headers
        Rectangle {
            Layout.fillWidth: true
            height: 36
            color: "#2a2a2a"

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 10

                Text {
                    text: "WEBSITE"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    font.letterSpacing: 0.5
                    color: "#808080"
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                }
                Text {
                    text: "USERNAME"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    font.letterSpacing: 0.5
                    color: "#808080"
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                }
                Text {
                    text: "PASSWORD"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    font.letterSpacing: 0.5
                    color: "#808080"
                    Layout.fillWidth: true
                    Layout.preferredWidth: 1
                }
                Text {
                    text: "TOTP"
                    font.pixelSize: 11
                    font.weight: Font.Medium
                    font.letterSpacing: 0.5
                    color: "#808080"
                    Layout.preferredWidth: 115
                }
                Item {
                    Layout.preferredWidth: 132
                }
            }
        }

        // Password list
        ListView {
            id: passwordList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: listPanel.model

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }

            delegate: Rectangle {
                id: delegateItem
                width: passwordList.width
                height: matchesSearch ? 56 : 0
                visible: matchesSearch
                clip: true
                color: listPanel.editMode && listPanel.editingRow === index ? "#1976D230" : (mouseArea.containsMouse ? "#2f2f2f" : "#002f2f2f")

                property bool matchesSearch: {
                    if (listPanel.showFavoritesOnly && !model.favorite) return false
                    if (listPanel.searchQuery === "") return true
                    var query = listPanel.searchQuery.toLowerCase()
                    return model.website.toLowerCase().indexOf(query) !== -1 ||
                           model.username.toLowerCase().indexOf(query) !== -1
                }

                Behavior on height {
                    NumberAnimation { duration: 150 }
                }

                Behavior on color {
                    ColorAnimation { duration: 150 }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    spacing: 10

                    // Website - clickable link
                    Text {
                        text: model.website
                        font.pixelSize: 14
                        color: websiteMouseArea.containsMouse ? "#1976D2" : "#ffffff"
                        font.underline: websiteMouseArea.containsMouse
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1

                        MouseArea {
                            id: websiteMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: listPanel.openWebsiteRequested(index)
                        }
                    }

                    // Username - clickable to copy
                    CopyableCell {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        displayText: model.username
                        onCopyClicked: listPanel.copyUsernameRequested(index)
                    }

                    // Password - clickable to copy
                    CopyableCell {
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        displayText: model.password
                        masked: !model.visible
                        onCopyClicked: listPanel.copyPasswordRequested(index)
                    }

                    // TOTP code display with timer
                    Rectangle {
                        Layout.preferredWidth: 115
                        height: 28
                        color: "transparent"
                        border.color: totpMouseArea.containsMouse ? "#3d8b40" : "transparent"
                        border.width: 1
                        radius: 14
                        visible: model.hasTotp

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                text: {
                                    var trigger = listPanel.totpRefreshTrigger
                                    return model.hasTotp ? passwordController.generateTotp(index) : ""
                                }
                                font.pixelSize: 14
                                font.weight: Font.Medium
                                font.family: "Menlo"
                                color: totpMouseArea.containsMouse ? "#66BB6A" : "#4CAF50"
                            }

                            Canvas {
                                id: timerCanvas
                                width: 18
                                height: 18
                                anchors.verticalCenter: parent.verticalCenter

                                property real progress: listPanel.totpRemainingSeconds / 30.0
                                property color circleColor: listPanel.totpRemainingSeconds <= 5 ? "#ef5350" : "#4CAF50"

                                onProgressChanged: requestPaint()
                                onCircleColorChanged: requestPaint()

                                onPaint: {
                                    var ctx = getContext("2d")
                                    ctx.reset()

                                    var centerX = width / 2
                                    var centerY = height / 2
                                    var radius = width / 2 - 2

                                    ctx.beginPath()
                                    ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                                    ctx.strokeStyle = "#404040"
                                    ctx.lineWidth = 2
                                    ctx.stroke()

                                    ctx.beginPath()
                                    ctx.arc(centerX, centerY, radius, -Math.PI / 2, -Math.PI / 2 + (2 * Math.PI * progress))
                                    ctx.strokeStyle = circleColor
                                    ctx.lineWidth = 2
                                    ctx.stroke()
                                }
                            }
                        }

                        MouseArea {
                            id: totpMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: listPanel.copyTotpRequested(index)
                        }

                        ToolTip {
                            visible: totpMouseArea.containsMouse
                            text: "Click to copy"
                            y: -height - 5
                            contentItem: Text {
                                text: "Click to copy"
                                color: "#ffffff"
                                font.pixelSize: 12
                            }
                            background: Rectangle {
                                color: "#424242"
                                radius: 4
                            }
                        }
                    }

                    // Empty placeholder when no TOTP
                    Item {
                        Layout.preferredWidth: 115
                        height: 28
                        visible: !model.hasTotp
                    }

                    Row {
                        spacing: 2
                        Layout.preferredWidth: 132
                        opacity: mouseArea.containsMouse ? 1 : 0.6

                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }

                        IconButton {
                            width: 32
                            height: 32
                            materialIcon: model.favorite ? "\ue838" : "\ue83a"
                            iconSize: 16
                            iconColor: model.favorite ? "#FFC107" : "#e0e0e0"
                            tooltip: model.favorite ? "Remove from favorites" : "Add to favorites"
                            onClicked: listPanel.toggleFavoriteRequested(index)
                        }
                        IconButton {
                            width: 32
                            height: 32
                            materialIcon: "\ue3c9"
                            iconSize: 16
                            iconColor: "#1976D2"
                            tooltip: "Edit"
                            onClicked: listPanel.editRequested(index)
                        }
                        IconButton {
                            width: 32
                            height: 32
                            materialIcon: model.visible ? "\ue8f4" : "\ue8f5"
                            iconSize: 16
                            tooltip: model.visible ? "Hide password" : "Show password"
                            onClicked: listPanel.toggleVisibilityRequested(index)
                        }
                        IconButton {
                            width: 32
                            height: 32
                            materialIcon: "\ue872"
                            iconSize: 16
                            iconColor: "#ef5350"
                            tooltip: "Delete"
                            onClicked: listPanel.deleteRequested(index)
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 20
                    anchors.rightMargin: 20
                    height: 1
                    color: "#2a2a2a"
                    visible: index < passwordList.count - 1
                }
            }

            // Empty state
            Item {
                anchors.fill: parent
                visible: passwordList.count === 0

                Column {
                    anchors.centerIn: parent
                    spacing: 12

                    Text {
                        text: "\ue899"
                        font.family: "Material Icons"
                        font.pixelSize: 64
                        color: "#404040"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "No passwords yet"
                        font.pixelSize: 16
                        font.weight: Font.Medium
                        color: "#606060"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        text: "Add your first password using the form"
                        font.pixelSize: 13
                        color: "#505050"
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }
    }
}
