// Provides the visualiser's appearance and capture settings.
// Plasma loads this page from the widget configuration sidebar.
import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.SimpleKCM {
    id: configRoot

    // ---------- Configuration bindings ----------

    property alias cfg_visualizerBarHeight: barHeight.value
    property alias cfg_visualizerBarCount: barCount.value
    property alias cfg_visualizerSmoothing: smoothing.value
    property string cfg_visualizerScale

    // ---------- Settings form ----------

    Kirigami.FormLayout {
        QQC2.SpinBox {
            id: barHeight

            Kirigami.FormData.label: i18n("Bar height (px):")
            from: 1
            to: 512
            editable: true
        }

        QQC2.SpinBox {
            id: barCount

            Kirigami.FormData.label: i18n("Number of bars:")
            from: 1
            to: 512
            editable: true
        }

        QQC2.SpinBox {
            id: smoothing

            Kirigami.FormData.label: i18n("Smoothing (0 = immediate, 100 = smooth):")
            from: 0
            to: 100
            editable: true
        }

        QQC2.ComboBox {
            Kirigami.FormData.label: i18n("Scale:")
            model: [i18n("Square root (boosts quieter bars)"), i18n("Linear")]
            currentIndex: configRoot.cfg_visualizerScale === "linear" ? 1 : 0
            onActivated: configRoot.cfg_visualizerScale = currentIndex === 1 ? "linear" : "sqrt"
        }
    }
}
