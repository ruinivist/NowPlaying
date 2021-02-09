import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.11
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: configRoot

    signal configurationChanged

    property alias cfg_opacity: opacitySpinBox.value

    property string cfg_preferredSource

	property string cfg_fontFamily

    ColumnLayout {
        spacing: units.smallSpacing * 2


        RowLayout{
            Label {
                text: i18n("Opacity percent")
            }
            SpinBox {
                id: opacitySpinBox
                from: 0
                to: 100
            }
        }

        RowLayout{

            Label {
                text: i18n("Preferred media source")
            }

            ListModel {
                id: sourcesModel
                Component.onCompleted: {
                    var arr = []
                    arr.push({
                                "text": cfg_preferredSource
                            })
                    var sources = dataSource.sources
                    for (var i = 0, j = sources.length; i < j; ++i) {
                        if (sources[i] === cfg_preferredSource) {
                            continue
                        }
                        arr.push({
                                    "text": sources[i]
                                })
                    }
                    append(arr)
                }
            }

            ComboBox {
                id: sourcesComboBox
                model: sourcesModel
                focus: true
                currentIndex: 0
                textRole: "text"
                onCurrentIndexChanged: {
                    var current = model.get(currentIndex)
                    if (current) {
                        cfg_preferredSource = current.text
                        configRoot.configurationChanged()
                    }
                }
            }
        }

        RowLayout{
            Label {
                text: i18n("Font")
            }
            ComboBox{
                id: fontFamilyComboBox
                model: Qt.fontFamilies()
                onCurrentIndexChanged: {
                    var current = Qt.fontFamilies()[currentIndex]
                    cfg_fontFamily=current
                    configRoot.configurationChanged()
                }
            }
        }

    }

    PlasmaCore.DataSource {
        id: dataSource
        engine: "mpris2"
    }
}
