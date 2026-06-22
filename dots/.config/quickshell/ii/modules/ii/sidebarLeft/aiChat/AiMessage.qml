import qs.services
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

Rectangle {
    id: root
    property int messageIndex
    property var messageData
    property var messageInputField
    property bool isUserMessage: root.messageData?.role === "user"
    property real headerSafetyGap: 14
    property real headerInnerWidth: messageBubble.width - root.messagePadding * 2 - 8
    property real headerControlsWidth: controlButtonGroup.implicitWidth + (modelVisibilityIndicator.visible ? modelVisibilityIndicator.implicitWidth + headerRowLayout.spacing : 0)
    property real nameWrapperMaxWidth: Math.max(0, root.headerInnerWidth - root.headerControlsWidth - headerRowLayout.spacing - root.headerSafetyGap)
    property real userNameRequiredWidth: userNameMetrics.width + nameRowLayout.spacing + roleIcon.implicitWidth + nameRowLayout.anchors.leftMargin + nameRowLayout.anchors.rightMargin
    property bool showUserName: !root.isUserMessage || root.nameWrapperMaxWidth >= root.userNameRequiredWidth
    property real minimumBubbleWidth: root.isUserMessage ? 240 : root.width * 0.52
    property color aiBubbleColor: "#212020"

    property real messagePadding: 9
    property real contentSpacing: 4

    property bool enableMouseSelection: false
    property bool renderMarkdown: true
    property bool editing: false

    property list<var> messageBlocks: StringUtils.splitMarkdownBlocks(root.messageData?.content)

    anchors.left: parent?.left
    anchors.right: parent?.right
    implicitHeight: messageBubble.implicitHeight

    color: "transparent"

    function saveMessage() {
        if (!root.editing) return;
        // Get all Loader children (each represents a segment)
        const segments = messageContentColumnLayout.children
            .map(child => child.segment)
            .filter(segment => (segment));

        // Reconstruct markdown
        const newContent = segments.map(segment => {
            if (segment.type === "code") {
                const lang = segment.lang ? segment.lang : "";
                // Remove trailing newlines
                const code = segment.content.replace(/\n+$/, "");
                return "```" + lang + "\n" + code + "\n```";
            } else {
                return segment.content;
            }
        }).join("");

        root.editing = false
        root.messageData.content = newContent;
    }

    Keys.onPressed: (event) => {
        if ( // Prevent de-select
            event.key === Qt.Key_Control || 
            event.key == Qt.Key_Shift || 
            event.key == Qt.Key_Alt || 
            event.key == Qt.Key_Meta
        ) {
            event.accepted = true
        }
        // Ctrl + S to save
        if ((event.key === Qt.Key_S) && event.modifiers == Qt.ControlModifier) {
            root.saveMessage();
            event.accepted = true;
        }
    }

    Rectangle {
        id: messageBubble
        anchors.top: parent.top
        anchors.left: root.isUserMessage ? undefined : parent.left
        anchors.right: root.isUserMessage ? parent.right : undefined
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        width: Math.min(root.width - 12, Math.max(columnLayout.implicitWidth + root.messagePadding * 2, root.minimumBubbleWidth))
        implicitHeight: columnLayout.implicitHeight + root.messagePadding * 2
        radius: Appearance.rounding.large
        color: root.isUserMessage ? Appearance.colors.colSecondaryContainer : root.aiBubbleColor

        Rectangle {
            width: 12
            height: 12
            radius: 3
            rotation: 45
            color: messageBubble.color
            anchors.top: parent.top
            anchors.topMargin: 18
            anchors.left: root.isUserMessage ? undefined : parent.left
            anchors.right: root.isUserMessage ? parent.right : undefined
            anchors.leftMargin: -4
            anchors.rightMargin: -4
        }

        ColumnLayout { // Main layout of the bubble
            id: columnLayout

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: messagePadding
            spacing: root.contentSpacing

            Rectangle {
                Layout.fillWidth: true
                implicitWidth: headerRowLayout.implicitWidth + 4 * 2
                implicitHeight: headerRowLayout.implicitHeight + 4 * 2
                color: "transparent"
                radius: Appearance.rounding.small
        
            RowLayout { // Header
                id: headerRowLayout
                anchors {
                    fill: parent
                    margins: 4
                }
                spacing: root.isUserMessage ? 26 : 18
                layoutDirection: root.messageData?.role === "user" ? Qt.RightToLeft : Qt.LeftToRight

                Item { // Name
                    id: nameWrapper
                    implicitHeight: Math.max(nameRowLayout.implicitHeight + 5 * 2, 30)
                    Layout.fillWidth: true
                    Layout.maximumWidth: root.nameWrapperMaxWidth
                    Layout.alignment: Qt.AlignVCenter

                    RowLayout {
                        id: nameRowLayout
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: root.messageData?.role === "user" ? undefined : parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        width: root.messageData?.role === "user" ? implicitWidth : parent.width - anchors.leftMargin - anchors.rightMargin
                        spacing: root.messageData?.role === "user" ? 6 : 12
                        layoutDirection: root.messageData?.role === "user" ? Qt.RightToLeft : Qt.LeftToRight

                        Item {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillHeight: true
                            implicitWidth: messageData?.role == 'assistant' ? modelIcon.width : roleIcon.implicitWidth
                            implicitHeight: messageData?.role == 'assistant' ? modelIcon.height : roleIcon.implicitHeight

                            CustomIcon {
                                id: modelIcon
                                anchors.centerIn: parent
                                visible: messageData?.role == 'assistant' && Ai.models[messageData?.model].icon
                                width: Appearance.font.pixelSize.large
                                height: Appearance.font.pixelSize.large
                                source: messageData?.role == 'assistant' ? Ai.models[messageData?.model].icon :
                                    messageData?.role == 'user' ? 'linux-symbolic' : 'desktop-symbolic'

                                colorize: true
                                color: Appearance.m3colors.m3onSecondaryContainer
                            }

                            MaterialSymbol {
                                id: roleIcon
                                anchors.centerIn: parent
                                visible: !modelIcon.visible
                                iconSize: Appearance.font.pixelSize.larger
                                color: Appearance.m3colors.m3onSecondaryContainer
                                text: messageData?.role == 'user' ? 'person' : 
                                    messageData?.role == 'interface' ? 'settings' : 
                                    messageData?.role == 'assistant' ? 'neurology' : 
                                    'computer'
                            }
                        }

                        StyledText {
                            id: providerName
                            visible: root.showUserName
                            Layout.alignment: Qt.AlignVCenter
                            Layout.fillWidth: root.messageData?.role !== "user"
                            elide: Text.ElideRight
                            horizontalAlignment: root.messageData?.role === "user" ? Text.AlignRight : Text.AlignLeft
                            font.pixelSize: Appearance.font.pixelSize.normal
                            color: root.isUserMessage ? Appearance.m3colors.m3onSecondaryContainer : Appearance.colors.colSubtext
                            text: messageData?.role == 'assistant' ? Ai.models[messageData?.model].name :
                                (messageData?.role == 'user' && SystemInfo.username) ? SystemInfo.username :
                                Translation.tr("Interface")
                        }

                        TextMetrics {
                            id: userNameMetrics
                            font: providerName.font
                            text: providerName.text
                        }
                    }
                }

                Button { // Not visible to model
                    id: modelVisibilityIndicator
                    visible: messageData?.role == 'interface'
                    implicitWidth: 16
                    implicitHeight: 30
                    Layout.alignment: Qt.AlignVCenter

                    background: Item

                    MaterialSymbol {
                        id: notVisibleToModelText
                        anchors.centerIn: parent
                        iconSize: Appearance.font.pixelSize.small
                        color: Appearance.colors.colSubtext
                        text: "visibility_off"
                    }
                    StyledToolTip {
                        text: Translation.tr("Not visible to model")
                    }
                }

                ButtonGroup {
                    id: controlButtonGroup
                    spacing: 5

                    AiMessageControlButton {
                        id: regenButton
                        buttonIcon: "refresh"
                        visible: messageData?.role === 'assistant'

                        onClicked: {
                            Ai.regenerate(root.messageIndex)
                        }
                        
                        StyledToolTip {
                            text: Translation.tr("Regenerate")
                        }
                    }

                    AiMessageControlButton {
                        id: copyButton
                        buttonIcon: activated ? "inventory" : "content_copy"

                        onClicked: {
                            Quickshell.clipboardText = root.messageData?.content
                            copyButton.activated = true
                            copyIconTimer.restart()
                        }

                        Timer {
                            id: copyIconTimer
                            interval: 1500
                            repeat: false
                            onTriggered: {
                                copyButton.activated = false
                            }
                        }
                        
                        StyledToolTip {
                            text: Translation.tr("Copy")
                        }
                    }
                    AiMessageControlButton {
                        id: editButton
                        activated: root.editing
                        enabled: root.messageData?.done ?? false
                        buttonIcon: "edit"
                        onClicked: {
                            root.editing = !root.editing
                            if (!root.editing) { // Save changes
                                root.saveMessage()
                            }
                        }
                        StyledToolTip {
                            text: root.editing ? Translation.tr("Save") : Translation.tr("Edit")
                        }
                    }
                    AiMessageControlButton {
                        id: toggleMarkdownButton
                        activated: !root.renderMarkdown
                        buttonIcon: "code"
                        onClicked: {
                            root.renderMarkdown = !root.renderMarkdown
                        }
                        StyledToolTip {
                            text: Translation.tr("View Markdown source")
                        }
                    }
                    AiMessageControlButton {
                        id: deleteButton
                        buttonIcon: "close"
                        onClicked: {
                            Ai.removeMessage(root.messageIndex)
                        }
                        StyledToolTip {
                            text: Translation.tr("Delete")
                        }
                    }
                }
            }
        }

            Loader {
                Layout.fillWidth: true
                active: root.messageData?.localFilePath && root.messageData?.localFilePath.length > 0
                sourceComponent: AttachedFileIndicator {
                    filePath: root.messageData?.localFilePath
                    canRemove: false
                }
            }

            ColumnLayout { // Message content
                id: messageContentColumnLayout
                spacing: 0

                Item {
                    Layout.fillWidth: true
                    implicitHeight: loadingIndicatorLoader.shown ? loadingIndicatorLoader.implicitHeight : 0
                    implicitWidth: loadingIndicatorLoader.implicitWidth
                    visible: implicitHeight > 0

                    Behavior on implicitHeight {
                        animation: Appearance.animation.elementMove.numberAnimation.createObject(this)
                    }
                    FadeLoader {
                        id: loadingIndicatorLoader
                        anchors.centerIn: parent
                        shown: (root.messageBlocks.length < 1) && (!root.messageData.done)
                        sourceComponent: MaterialLoadingIndicator {
                            loading: true
                        }
                    }
                }
                Repeater {
                    model: ScriptModel {
                        values: root.messageBlocks
                    }
                    delegate: DelegateChooser {
                        id: messageDelegate
                        role: "type"

                        DelegateChoice { roleValue: "code"; MessageCodeBlock {
                            editing: root.editing
                            renderMarkdown: root.renderMarkdown
                            enableMouseSelection: root.enableMouseSelection
                            segmentContent: modelData.content
                            segmentLang: modelData.lang
                            messageData: root.messageData
                        } }
                        DelegateChoice { roleValue: "think"; MessageThinkBlock {
                            editing: root.editing
                            renderMarkdown: root.renderMarkdown
                            enableMouseSelection: root.enableMouseSelection
                            segmentContent: modelData.content
                            messageData: root.messageData
                            done: root.messageData?.done ?? false
                            completed: modelData.completed ?? false
                        } }
                        DelegateChoice { roleValue: "text"; MessageTextBlock {
                            editing: root.editing
                            renderMarkdown: root.renderMarkdown
                            enableMouseSelection: root.enableMouseSelection
                            segmentContent: modelData.content
                            messageData: root.messageData
                            done: root.messageData?.done ?? false
                            forceDisableChunkSplitting: root.messageData?.content.includes("```") ?? true
                        } }
                    }
                }
            }

            Flow { // Annotations
                visible: root.messageData?.annotationSources?.length > 0
                spacing: 5
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft

                Repeater {
                    model: ScriptModel {
                        values: root.messageData?.annotationSources || []
                    }
                    delegate: AnnotationSourceButton {
                        required property var modelData
                        displayText: modelData.text
                        url: modelData.url
                    }
                }
            }

            Flow { // Search queries
                visible: root.messageData?.searchQueries?.length > 0
                spacing: 5
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignLeft

                Repeater {
                    model: ScriptModel {
                        values: root.messageData?.searchQueries || []
                    }
                    delegate: SearchQueryButton {
                        required property var modelData
                        query: modelData
                    }
                }
            }
        }
    }
}
