import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root

    // Properties accessed from configuration.
    // "qmllint" sees `plasmoid` as QObject here, but Plasma injects `configuration` at runtime.
    // qmllint disable missing-property
    property int configuredOpacity: plasmoid.configuration.opacity
    // qmllint disable missing-property
    property string configuredFontFamily: plasmoid.configuration.fontFamily
    // qmllint disable missing-property
    property string configuredLabelVisibilityMode: plasmoid.configuration.labelVisibilityMode
    // qmllint disable missing-property
    property string configuredLabelPlacement: plasmoid.configuration.labelPlacement
    // qmllint disable missing-property
    property string configuredLabelText: plasmoid.configuration.labelText
    // qmllint disable missing-property
    property string configuredBackgroundStyle: plasmoid.configuration.backgroundStyle
    // qmllint disable missing-property
    property string configuredBackgroundColor: plasmoid.configuration.backgroundColor
    // qmllint disable missing-property
    property int configuredBackgroundRadius: plasmoid.configuration.backgroundRadius
    // qmllint disable missing-property
    property string configuredForegroundColor: plasmoid.configuration.foregroundColor
    // qmllint disable missing-property
    property bool configuredTextShadowEnabled: plasmoid.configuration.textShadowEnabled
    // qmllint disable missing-property
    property int configuredTrackTextVerticalSpacing: plasmoid.configuration.trackTextVerticalSpacing
    // qmllint disable missing-property
    property int configuredLabelVerticalSpacing: plasmoid.configuration.labelVerticalSpacing
    // qmllint disable missing-property
    property int configuredSeparatorGapLabel: plasmoid.configuration.separatorGapLabel
    // qmllint disable missing-property
    property int configuredSeparatorGapTrack: plasmoid.configuration.separatorGapTrack
    // qmllint disable missing-property
    property int configuredSeparatorHeight: plasmoid.configuration.separatorHeight
    readonly property int resolvedBackgroundHints: {
        if (configuredBackgroundStyle === "default")
            return PlasmaCore.Types.DefaultBackground | PlasmaCore.Types.ConfigurableBackground;

        if (configuredBackgroundStyle === "none")
            return PlasmaCore.Types.NoBackground;

        return PlasmaCore.Types.NoBackground;
    }

    width: Kirigami.Units.gridUnit * 25
    height: Kirigami.Units.gridUnit * 5
    Layout.minimumWidth: Kirigami.Units.gridUnit * 25
    Layout.minimumHeight: Kirigami.Units.gridUnit * 5
    Plasmoid.backgroundHints: resolvedBackgroundHints
    opacity: configuredOpacity / 100

    Player {
        id: player
    }

    fullRepresentation: Representation {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 25
        Layout.minimumHeight: Kirigami.Units.gridUnit * 5
        Layout.preferredWidth: root.width
        Layout.preferredHeight: root.height
        configuredFontFamily: root.configuredFontFamily
        configuredLabelVisibilityMode: root.configuredLabelVisibilityMode
        configuredLabelPlacement: root.configuredLabelPlacement
        configuredLabelText: root.configuredLabelText
        configuredBackgroundStyle: root.configuredBackgroundStyle
        configuredBackgroundColor: root.configuredBackgroundColor
        configuredBackgroundRadius: root.configuredBackgroundRadius
        configuredForegroundColor: root.configuredForegroundColor
        configuredTextShadowEnabled: root.configuredTextShadowEnabled
        configuredTrackTextVerticalSpacing: root.configuredTrackTextVerticalSpacing
        configuredLabelVerticalSpacing: root.configuredLabelVerticalSpacing
        configuredSeparatorGapLabel: root.configuredSeparatorGapLabel
        configuredSeparatorGapTrack: root.configuredSeparatorGapTrack
        configuredSeparatorHeight: root.configuredSeparatorHeight
    }

    compactRepresentation: Representation {
        Layout.minimumWidth: Kirigami.Units.gridUnit * 25
        Layout.minimumHeight: Kirigami.Units.gridUnit * 5
        Layout.preferredWidth: root.width
        Layout.preferredHeight: root.height
        configuredFontFamily: root.configuredFontFamily
        configuredLabelVisibilityMode: root.configuredLabelVisibilityMode
        configuredLabelPlacement: root.configuredLabelPlacement
        configuredLabelText: root.configuredLabelText
        configuredBackgroundStyle: root.configuredBackgroundStyle
        configuredBackgroundColor: root.configuredBackgroundColor
        configuredBackgroundRadius: root.configuredBackgroundRadius
        configuredForegroundColor: root.configuredForegroundColor
        configuredTextShadowEnabled: root.configuredTextShadowEnabled
        configuredTrackTextVerticalSpacing: root.configuredTrackTextVerticalSpacing
        configuredLabelVerticalSpacing: root.configuredLabelVerticalSpacing
        configuredSeparatorGapLabel: root.configuredSeparatorGapLabel
        configuredSeparatorGapTrack: root.configuredSeparatorGapTrack
        configuredSeparatorHeight: root.configuredSeparatorHeight
    }

}
