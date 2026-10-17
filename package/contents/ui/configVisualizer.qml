// Provides the visualiser's appearance and capture settings.
// Plasma loads this page from the widget configuration sidebar.
import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs as Dialogs
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: configRoot

    // ---------- Configuration bindings ----------

    property alias cfg_visualizerEnabled: enabledCheckBox.checked
    property string cfg_visualizerColorMode
    property alias cfg_visualizerColor: visualizerColorField.text
    property alias cfg_visualizerBarHeight: barHeight.value
    property alias cfg_visualizerBarCount: barCount.value
    property alias cfg_visualizerSmoothing: smoothing.value
    property string cfg_visualizerScale

    // ---------- Settings form ----------

    Kirigami.FormLayout {
        QQC2.CheckBox {
            id: enabledCheckBox

            text: i18n("Enabled")
        }

        QQC2.SpinBox {
            id: barHeight

            Kirigami.FormData.label: i18n("Bar height (px):")
            enabled: configRoot.cfg_visualizerEnabled
            from: 1
            to: 512
            editable: true
        }

        QQC2.SpinBox {
            id: barCount

            Kirigami.FormData.label: i18n("Number of bars:")
            enabled: configRoot.cfg_visualizerEnabled
            from: 1
            to: 512
            editable: true
        }

        QQC2.SpinBox {
            id: smoothing

            Kirigami.FormData.label: i18n("Smoothing (0 = least, 100 = most):")
            enabled: configRoot.cfg_visualizerEnabled
            from: 0
            to: 100
            editable: true
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Scale:")
            enabled: configRoot.cfg_visualizerEnabled
            model: [i18n("Square root (boosts quieter bars)"), i18n("Linear")]
            currentIndex: configRoot.cfg_visualizerScale === "linear" ? 1 : 0
            onActivated: configRoot.cfg_visualizerScale = currentIndex === 1 ? "linear" : "sqrt"
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Color:")
            enabled: configRoot.cfg_visualizerEnabled
            model: [i18n("Foreground"), i18n("Custom")]
            currentIndex: configRoot.cfg_visualizerColorMode === "custom" ? 1 : 0
            onActivated: configRoot.cfg_visualizerColorMode = currentIndex === 1 ? "custom" : "foreground"
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Visualiser color:")
            enabled: configRoot.cfg_visualizerEnabled
            visible: configRoot.cfg_visualizerColorMode === "custom"

            QQC2.TextField {
                id: visualizerColorField

                Layout.fillWidth: true
                placeholderText: i18n("white or #RRGGBB")
            }

            QQC2.Button {
                text: i18n("Pick...")
                onClicked: {
                    visualizerColorDialog.selectedColor = visualizerColorField.text || "white";
                    visualizerColorDialog.open();
                }
            }
        }
    }

    // ---------- Custom color picker ----------

    Dialogs.ColorDialog {
        id: visualizerColorDialog

        title: i18n("Select visualiser color")
        options: Dialogs.ColorDialog.ShowAlphaChannel
        onAccepted: configRoot.cfg_visualizerColor = selectedColor.toString()
    }
}
