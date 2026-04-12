import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: configRoot

    property alias cfg_opacity: opacitySpinBox.value
    property string cfg_fontFamily
    readonly property var availableFonts: Qt.fontFamilies()

    onCfg_fontFamilyChanged: {
        const index = availableFonts.indexOf(cfg_fontFamily);
        if (index >= 0 && fontFamilyComboBox.currentIndex !== index)
            fontFamilyComboBox.currentIndex = index;

    }

    Kirigami.FormLayout {
        QQC2.SpinBox {
            id: opacitySpinBox

            Kirigami.FormData.label: i18n("Opacity percent:")
            from: 0
            to: 100
        }

        QQC2.ComboBox {
            id: fontFamilyComboBox

            Kirigami.FormData.label: i18n("Font:")
            model: configRoot.availableFonts
            onActivated: configRoot.cfg_fontFamily = currentText
        }

    }

}
