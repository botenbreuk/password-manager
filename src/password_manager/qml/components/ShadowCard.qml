import QtQuick
import QtQuick.Effects

Rectangle {
    property color cardColor: "#252525"
    property int cardRadius: 16
    property real shadowBlur: 1.0

    color: cardColor
    radius: cardRadius

    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: "#40000000"
        shadowBlur: shadowBlur
        shadowVerticalOffset: 4
    }
}
