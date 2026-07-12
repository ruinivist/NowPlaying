import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Dialogs as Dialogs
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.mpris as Mpris

KCM.SimpleKCM {
    id: configRoot

    property alias cfg_opacity: opacitySpinBox.value
    property string cfg_fontFamily
    property alias cfg_labelFontSize: labelFontSizeSpinBox.value
    property alias cfg_titleFontSize: titleFontSizeSpinBox.value
    property alias cfg_artistFontSize: artistFontSizeSpinBox.value
    property string cfg_labelVisibilityMode
    property string cfg_labelPlacement
    property alias cfg_labelText: labelTextArea.text
    property alias cfg_useLabelArtwork: useLabelArtworkCheckBox.checked
    property alias cfg_imageBorderRadius: imageBorderRadiusSpinBox.value
    property string cfg_backgroundStyle
    property alias cfg_backgroundColor: backgroundColorField.text
    property alias cfg_backgroundRadius: backgroundRadiusSpinBox.value
    property alias cfg_foregroundColor: foregroundColorField.text
    property alias cfg_textShadowEnabled: textShadowCheckBox.checked
    property alias cfg_showMediaControls: showMediaControlsCheckBox.checked
    property alias cfg_sourcePriority: sourcePriorityField.text
    property alias cfg_sourceWhitelist: sourceWhitelistCheckBox.checked
    property alias cfg_trackTextVerticalSpacing: trackTextVerticalSpacingSpinBox.value
    property alias cfg_labelVerticalSpacing: labelVerticalSpacingSpinBox.value
    property alias cfg_separatorGapLabel: separatorGapLabelSpinBox.value
    property alias cfg_separatorGapTrack: separatorGapTrackSpinBox.value
    property alias cfg_separatorHeight: separatorHeightSpinBox.value
    property alias cfg_hideSeparator: hideSeparatorCheckBox.checked
    readonly property int containerRole: Qt.UserRole + 1
    readonly property var availableFonts: Qt.fontFamilies()
    property var detectedSources: []
    readonly property var labelVisibilityOptions: [{
        "text": i18n("Auto hide when idle"),
        "value": "auto"
    }, {
        "text": i18n("Always show"),
        "value": "always"
    }, {
        "text": i18n("Always hide"),
        "value": "never"
    }]
    readonly property var labelPlacementOptions: [{
        "text": i18n("Left"),
        "value": "left"
    }, {
        "text": i18n("Right"),
        "value": "right"
    }]
    readonly property var backgroundStyleOptions: [{
        "text": i18n("Default"),
        "value": "custom"
    }, {
        "text": i18n("Solid background"),
        "value": "default"
    }]
    readonly property bool hasSourcePriorityEntries: sourcePriorityField.text.split(",").some((entry) => {
        return normalizeDesktopEntry(entry).length > 0;
    })

    function syncComboByValue(comboBox, options, configuredValue, fallbackValue) {
        const requestedValue = configuredValue || fallbackValue;
        const requestedIndex = options.findIndex((option) => {
            return option.value === requestedValue;
        });
        const fallbackIndex = options.findIndex((option) => {
            return option.value === fallbackValue;
        });
        const resolvedIndex = requestedIndex >= 0 ? requestedIndex : (fallbackIndex >= 0 ? fallbackIndex : 0);
        if (comboBox.currentIndex !== resolvedIndex)
            comboBox.currentIndex = resolvedIndex;

        return options[resolvedIndex].value;
    }

    function normalizeDesktopEntry(value) {
        return (value || "").toString().trim();
    }

    function refreshDetectedSources() {
        const sources = [];
        const seen = {
        };
        const playerCount = detectedSourcesModel.rowCount();
        for (let row = 0; row < playerCount; ++row) {
            const player = detectedSourcesModel.data(detectedSourcesModel.index(row, 0), containerRole);
            const desktopEntry = normalizeDesktopEntry(player ? player.desktopEntry : "");
            const desktopEntryKey = desktopEntry.toLowerCase();
            if (!desktopEntry || seen[desktopEntryKey])
                continue;

            seen[desktopEntryKey] = true;
            sources.push(desktopEntry);
        }
        detectedSources = sources;
    }

    Component.onCompleted: cfg_sourceWhitelist = hasSourcePriorityEntries && cfg_sourceWhitelist
    onCfg_fontFamilyChanged: {
        const index = availableFonts.indexOf(cfg_fontFamily);
        if (index >= 0 && fontFamilyComboBox.currentIndex !== index)
            fontFamilyComboBox.currentIndex = index;

    }
    onCfg_labelVisibilityModeChanged: {
        const resolvedValue = syncComboByValue(labelVisibilityModeComboBox, labelVisibilityOptions, cfg_labelVisibilityMode, "auto");
        if (cfg_labelVisibilityMode !== resolvedValue)
            cfg_labelVisibilityMode = resolvedValue;

    }
    onCfg_labelPlacementChanged: {
        const resolvedValue = syncComboByValue(labelPlacementComboBox, labelPlacementOptions, cfg_labelPlacement, "left");
        if (cfg_labelPlacement !== resolvedValue)
            cfg_labelPlacement = resolvedValue;

    }
    onCfg_backgroundStyleChanged: {
        const resolvedValue = syncComboByValue(backgroundStyleComboBox, backgroundStyleOptions, cfg_backgroundStyle, "custom");
        if (cfg_backgroundStyle !== resolvedValue)
            cfg_backgroundStyle = resolvedValue;

    }

    Kirigami.FormLayout {
        SectionHeader {
            title: i18n("Global")
        }

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

        QQC2.ComboBox {
            id: backgroundStyleComboBox

            Kirigami.FormData.label: i18n("Background style:")
            model: configRoot.backgroundStyleOptions
            textRole: "text"
            valueRole: "value"
            onActivated: configRoot.cfg_backgroundStyle = currentValue
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Background color:")
            enabled: configRoot.cfg_backgroundStyle === "custom"

            QQC2.TextField {
                id: backgroundColorField

                Layout.fillWidth: true
                placeholderText: i18n("transparent or #AARRGGBB")
            }

            QQC2.Button {
                text: i18n("Pick...")
                onClicked: {
                    backgroundColorDialog.selectedColor = backgroundColorField.text || "transparent";
                    backgroundColorDialog.open();
                }
            }

        }

        RowLayout {
            Kirigami.FormData.label: i18n("Foreground color:")

            QQC2.TextField {
                id: foregroundColorField

                Layout.fillWidth: true
                placeholderText: i18n("white or #RRGGBB")
            }

            QQC2.Button {
                text: i18n("Pick...")
                onClicked: {
                    foregroundColorDialog.selectedColor = foregroundColorField.text || "white";
                    foregroundColorDialog.open();
                }
            }

        }

        QQC2.SpinBox {
            id: backgroundRadiusSpinBox

            Kirigami.FormData.label: i18n("Background radius:")
            enabled: configRoot.cfg_backgroundStyle === "custom"
            from: 0
            to: 100
        }

        QQC2.CheckBox {
            id: textShadowCheckBox

            Kirigami.FormData.label: i18n("Text shadow:")
            text: i18n("Enable")
        }

        QQC2.CheckBox {
            id: showMediaControlsCheckBox

            Kirigami.FormData.label: i18n("Media controls:")
            text: i18n("Show media controls")
        }

        QQC2.TextField {
            id: sourcePriorityField

            Kirigami.FormData.label: i18n("Source priority:")
            Layout.fillWidth: true
            placeholderText: i18n("example: spotify, firefox")
            onTextChanged: configRoot.cfg_sourceWhitelist = configRoot.hasSourcePriorityEntries && configRoot.cfg_sourceWhitelist
        }

        QQC2.CheckBox {
            id: sourceWhitelistCheckBox

            Kirigami.FormData.label: ""
            text: i18n("Only use listed sources")
            enabled: configRoot.hasSourcePriorityEntries
        }

        QQC2.Label {
            id: detectedSourcesField

            Kirigami.FormData.label: i18n("Current sources being detected:")
            Layout.fillWidth: true
            Layout.preferredHeight: Math.max(implicitHeight, Kirigami.Units.gridUnit * 2)
            textFormat: TextEdit.PlainText
            wrapMode: TextEdit.WrapAnywhere
            text: configRoot.detectedSources.length > 0 ? configRoot.detectedSources.join("\n") : i18n("No active MPRIS desktopEntry values detected")
        }

        QQC2.SpinBox {
            id: separatorHeightSpinBox

            Kirigami.FormData.label: i18n("Separator height (%):")
            from: 0
            to: 100
        }

        QQC2.CheckBox {
            id: hideSeparatorCheckBox

            Kirigami.FormData.label: i18n("Separator:")
            text: i18n("Hide separator")
        }

        SectionHeader {
            title: i18n("Label")
        }

        QQC2.ComboBox {
            id: labelVisibilityModeComboBox

            Kirigami.FormData.label: i18n("Now Playing labels:")
            model: configRoot.labelVisibilityOptions
            textRole: "text"
            valueRole: "value"
            onActivated: configRoot.cfg_labelVisibilityMode = currentValue
        }

        QQC2.ComboBox {
            id: labelPlacementComboBox

            Kirigami.FormData.label: i18n("Label placement:")
            model: configRoot.labelPlacementOptions
            textRole: "text"
            valueRole: "value"
            onActivated: configRoot.cfg_labelPlacement = currentValue
        }

        QQC2.CheckBox {
            id: useLabelArtworkCheckBox

            Kirigami.FormData.label: i18n("Label image:")
            text: i18n("Show track image when available")
        }

        QQC2.SpinBox {
            id: imageBorderRadiusSpinBox

            Kirigami.FormData.label: i18n("Image border radius:")
            from: 0
            to: 100
        }

        QQC2.TextArea {
            id: labelTextArea

            Kirigami.FormData.label: i18n("Label text:")
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 3
            placeholderText: i18n("Use a line break for multiple lines")
            wrapMode: TextEdit.NoWrap
        }

        QQC2.SpinBox {
            id: labelFontSizeSpinBox

            Kirigami.FormData.label: i18n("Label font size:")
            from: 8
            to: 72
        }

        QQC2.SpinBox {
            id: labelVerticalSpacingSpinBox

            Kirigami.FormData.label: i18n("Label line spacing (negatives possible):")
            from: -200
            to: 200
        }

        QQC2.SpinBox {
            id: separatorGapLabelSpinBox

            Kirigami.FormData.label: i18n("Separator gap from label:")
            from: 0
            to: 24
        }

        SectionHeader {
            title: i18n("Track & Artist")
        }

        QQC2.SpinBox {
            id: titleFontSizeSpinBox

            Kirigami.FormData.label: i18n("Title font size:")
            from: 8
            to: 96
        }

        QQC2.SpinBox {
            id: artistFontSizeSpinBox

            Kirigami.FormData.label: i18n("Artist font size:")
            from: 8
            to: 96
        }

        QQC2.SpinBox {
            id: trackTextVerticalSpacingSpinBox

            Kirigami.FormData.label: i18n("Title/artist spacing (negatives possible):")
            from: -200
            to: 200
        }

        QQC2.SpinBox {
            id: separatorGapTrackSpinBox

            Kirigami.FormData.label: i18n("Separator gap from track:")
            from: 0
            to: 24
        }

    }

    Dialogs.ColorDialog {
        id: backgroundColorDialog

        title: i18n("Select background color")
        options: Dialogs.ColorDialog.ShowAlphaChannel
        onAccepted: configRoot.cfg_backgroundColor = selectedColor.toString()
    }

    Dialogs.ColorDialog {
        id: foregroundColorDialog

        title: i18n("Select foreground color")
        options: Dialogs.ColorDialog.ShowAlphaChannel
        onAccepted: configRoot.cfg_foregroundColor = selectedColor.toString()
    }

    Mpris.Mpris2Model {
        id: detectedSourcesModel

        onRowsInserted: configRoot.refreshDetectedSources()
        onRowsRemoved: configRoot.refreshDetectedSources()
        onModelReset: configRoot.refreshDetectedSources()
        onDataChanged: configRoot.refreshDetectedSources()
        Component.onCompleted: configRoot.refreshDetectedSources()
    }

    component SectionHeader: Item {
        required property string title

        Kirigami.FormData.isSection: true
        implicitHeight: sectionLayout.implicitHeight

        ColumnLayout {
            id: sectionLayout

            anchors.left: parent.left
            anchors.right: parent.right
            spacing: Kirigami.Units.smallSpacing

            QQC2.Label {
                text: parent.parent.title
                font.bold: true
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Kirigami.Theme.textColor
                opacity: 0.25
            }

        }

    }

}
