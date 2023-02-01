import QtQuick 2.12
import Qt.labs.settings 1.1
import QtQml 2.12
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.2
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.12
import QtQuick.Window 2.12
import QtWebEngine 1.10

ApplicationWindow
{
    id: app
    property bool is_dark: false
    property QtObject main_profile: WebEngineProfile {}

    visibility: "Maximized"
    minimumWidth: 640
    minimumHeight: 480
    visible: true
    color: is_dark === false ? "gainsboro" : "darkGray"

    property Item current_web: web_tabs.currentIndex < web_tabs.count ? web_tabs.getTab(web_tabs.currentIndex).item : null
    title: current_web && current_web.title

    toolBar: ToolBar
    {
        style: ToolBarStyle
        {
            background: Rectangle
            {
                implicitWidth: 100
                implicitHeight: 50
                color: is_dark === false ? "white" : "dimGray"
            }
        }
        RowLayout
        {
            anchors.fill: parent
            ToolButton
            {
                iconSource: is_dark === false ? "icons/icons/menu_light.png" : "icons/icons/menu_black.png"
                enabled: about_view.visible || settings_view.visible ? false : true
                menu: Menu
                {
                    id: menus
                    Menu
                    {
                        id: session_history
                        title: "Sessions history"
                        Instantiator
                        {
                            model: current_web.navigationHistory.items
                            MenuItem
                            {
                                text: model.title
                                onTriggered: current_web.url = model.url
                            }
                            onObjectAdded: function(p_index, p_object)
                            {
                                session_history.insertItem(p_index, p_object)
                            }
                        }
                    }
                    MenuItem
                    {
                        text: "Downloads"
                        onTriggered:
                        {
                            downloads_view.visible = !downloads_view.visible
                            itemcode_view.visible = false
                        }
                    }
                    MenuSeparator {}
                    MenuItem
                    {
                        text: "Settings"
                        onTriggered:
                        {
                            settings_view.visible = !settings_view.visible
                            downloads_view.visible = false
                            itemcode_view.visible = false
                        }
                    }
                    MenuItem
                    {
                        text: "Item code"
                        onTriggered:
                        {
                            itemcode_view.visible = !itemcode_view.visible
                        }
                    }
                    MenuSeparator {}
                    MenuItem
                    {
                        text: "About"
                        onTriggered:
                        {
                            about_view.visible = !about_view.visible
                            downloads_view.visible = false
                            itemcode_view.visible = false
                        }
                    }
                }
            }
            ToolButton
            {
                iconSource: is_dark === false ? "icons/icons/add_light.png" : "icons/icons/add_black.png"
                enabled: about_view.visible || settings_view.visible ? false : true
                onClicked:
                {
                    web_tabs.create_tab(web_tabs.count != 0 ? current_web.profile : main_profile)
                    web_tabs.currentIndex = web_tabs.count - 1
                }
            }
            ToolButton
            {
                iconSource: is_dark === false ? "icons/icons/prev_light.png" : "icons/icons/prev_black.png"
                enabled: current_web && current_web.canGoBack || about_view.visible || settings_view.visible || web_tabs.count === 0 ? false : true
                onClicked: current_web.goBack()
            }
            ToolButton
            {
                iconSource: current_web && current_web.loading ? is_dark === false ? "icons/icons/rel1_light.png" : "icons/icons/rel1_black.png" : is_dark === false? "icons/icons/rel_light.png" : "icons/icons/rel_black.png"
                enabled: about_view.visible || settings_view.visible || web_tabs.count === 0 ? false : true
                onClicked: current_web && current_web.loading ? current_web.stop() : current_web.reload()
            }
            TextField
            {
                id: address_field
                style: TextFieldStyle
                {
                    padding
                    {
                        left: 26
                    }
                    background: Rectangle
                    {
                        implicitWidth: 100
                        implicitHeight: 30
                        color: is_dark === false ? "gainsboro" : "darkGray"
                        radius: 20
                    }
                }
                Layout.fillWidth: true
                text: current_web && current_web.url
                onAccepted:
                {
                    if(address_field.text.match("https://www."))
                    {
                        current_web.url = address_field.text
                    }
                    else
                    {
                        current_web.url = "https://www." + address_field.text
                    }
                }
            }
            ToolButton
            {
                enabled: about_view.visible || settings_view.visible ? false : true
                iconSource: is_dark === false ? "icons/icons/down_light.png" : "icons/icons/down_black.png"
                onClicked:
                {
                    downloads_view.visible = !downloads_view.visible
                    itemcode_view.visible = false
                }
            }
        }
        ProgressBar
        {
            height: 4
            anchors
            {
                left: parent.left
                top: parent.bottom
                right: parent.right
                leftMargin: -parent.leftMargin
                rightMargin: -parent.rightMargin
            }
            style: ProgressBarStyle
            {
                background: Item {}
            }
            minimumValue: 0
            maximumValue: 100
            value: (current_web && current_web.loadProgress < 100) ? current_web.loadProgress : 0
        }
    }
    TabView
    {
        id: web_tabs
        anchors
        {
            top: parent.top
            bottom: itemcode_view.top
            left: parent.left
            right: downloads_view.left
        }
        style: TabViewStyle
        {
            tab: Rectangle
            {
                color: is_dark === false ? "gainsboro" : "darkGray"
                radius: 10
                border.width: 2
                border.color: is_dark === false ? "lightGray" : "dimGray"
                implicitWidth: web_tabs.count > 9 ? web_tabs.width/web_tabs.count : Math.max(text.width + 50, web_tabs.width/9)
                implicitHeight: 35
                Text
                {
                    id: text
                    anchors
                    {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 20
                    }
                    text: styleData.title
                    color: "black"
                }
                ToolButton
                {
                    anchors
                    {
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                        rightMargin: 5
                    }
                    height: 20
                    width: 20
                    iconSource: is_dark === false ? "icons/icons/rel1_light.png" : "icons/icons/rel1_black.png"
                    onClicked:
                    {
                        web_tabs.removeTab(styleData.index)
                        if(web_tabs.count === 0)
                        {
                            Qt.quit()
                        }
                    }
                }
            }
        }
        function create_tab(p_profile)
        {
            var tab = addTab("", tab_component)
            tab.active = true
            tab.title = Qt.binding(function() { return tab.item.title })
            tab.item.profile = p_profile
            p_profile.downloadRequested.connect(onDownloadRequested);
            return tab
        }
        Component.onCompleted: create_tab(main_profile)
        Component
        {
            id: tab_component
            WebEngineView
            {
                id: webengine_view
                focus: true
                url: "https://www.google.com"
                onNewViewRequested: function(p_request)
                {
                    if (p_request.destination === WebEngineView.NewViewInBackgroundTab)
                    {
                        var backgroundTab = web_tabs.create_tab(current_web.profile)
                        p_request.openIn(backgroundTab.item)
                    }
                }
            }
        }
    }
    Rectangle
    {
        id: settings_view
        visible: false
        anchors.fill: parent
        color: is_dark === false ? "gainsboro" : "gray"
        Rectangle
        {
            id: rect1
            color: is_dark === false ? "lightGray" : "darkGray"
            radius: 30
            visible: true
            anchors
            {
                top: parent.top
                topMargin: 40
                bottom: parent.bottom
                bottomMargin: 50
                right: parent.right
                rightMargin: 50
                left: parent.left
                leftMargin: 50
            }
            Text
            {
                id: settings_text
                horizontalAlignment: Text.AlignHCenter
                height: 30
                anchors
                {
                    top: parent.top
                    topMargin: 20
                    left: parent.left
                    right: parent.right
                }
                text: "Settings"
            }
            RowLayout
            {
                width:400
                anchors
                {
                    top: settings_text.bottom
                    topMargin: 20
                    right: parent.right
                    rightMargin: 200
                    left: parent.left
                    leftMargin: 200
                }
                Text
                {
                    text: "Change theme: "
                }
                RadioButton
                {
                    id:dark_button
                    text: "Dark"
                    checked: is_dark
                    onClicked:
                    {
                        is_dark = true
                        checked = true
                        light_button.checked = false
                    }
                }
                RadioButton
                {
                    id:light_button
                    text: "Light"
                    checked: !is_dark
                    onClicked:
                    {
                        is_dark = false
                        checked = true
                        dark_button.checked = false
                    }
                }
            }
            Button
            {
                id: apply_button
                text: "Apply"
                width: 75
                height: 50
                x: rect1.width/2-40
                style : ButtonStyle
                {
                    background: Rectangle
                    {
                        color: is_dark === false ? "gainsboro" : "gray"
                        radius: 20
                    }
                }
                anchors
                {
                    bottom: parent.bottom
                    bottomMargin: 10
                }
                onClicked:
                {
                    settings_view.visible = false;
                }
            }
        }
    }
    WebEngineView
    {
        id: itemcode_view
        visible: false
        height: visible ? 400 : 0
        inspectedView: visible && web_tabs.currentIndex < web_tabs.count ? web_tabs.getTab(web_tabs.currentIndex).item : null
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        onNewViewRequested: function(p_request)
        {
            var tab = web_tabs.create_tab(current_web.profile)
            web_tabs.currentIndex = web_tabs.count - 1
            p_request.openIn(tab.item)
        }
    }
    Rectangle
    {
        id: downloads_view
        visible: false
        anchors
        {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
        }
        width: visible ? parent.width/3 : 0
        color: is_dark === false ? "gainsboro" : "gray"
        ListModel
        {
            id: download_model
            property var downloads: []
        }
        function append(p_download)
        {
            download_model.append(p_download)
            download_model.downloads.push(p_download)
        }
        Rectangle
        {
            id: rect
            color: is_dark === false ? "lightGray" : "darkGray"
            visible: true
            anchors
            {
                top: parent.top
                bottom: parent.bottom
                bottomMargin: 50
                right: parent.right
                rightMargin: 50
                left: parent.left
                leftMargin: 50
            }
            Component
            {
                id: download_delegate
                Rectangle
                {
                    width: list_view.width
                    height: childrenRect.height
                    anchors.margins: 10
                    radius: 3
                    color: "transparent"
                    //border.color: "black"
                    Rectangle
                    {
                        id: prog
                        property real progress: download_model.downloads[index] ? download_model.downloads[index].receivedBytes / download_model.downloads[index].totalBytes : 0
                        radius: 3
                        color: width == list_view.width ? "lightBlue" : "lightGreen"
                        width: list_view.width * progress
                        height: cancel_button.height
                        Behavior on width
                        {
                            SmoothedAnimation
                            {
                                duration: 100
                            }
                        }
                    }
                    Rectangle
                    {
                        anchors
                        {
                            left: parent.left
                            right: parent.right
                            leftMargin: 20
                        }
                        Label
                        {
                            id: label
                            text: downloadDirectory + "/" + downloadFileName
                            anchors
                            {
                                //verticalCenter: cancel_button.verticalCenter
                                left: parent.left
                                right: cancel_button.left
                            }
                        }
                        Button
                        {
                            id: cancel_button
                            //anchors.left: label.right
                            anchors.right: parent.right
                            width: 20
                            height: 20
                            iconSource: is_dark === false ? "icons/icons/rel1_light.png" : "icons/icons/rel1_black.png"
                            onClicked:
                            {
                                var download = download_model.downloads[index]
                                download.cancel()
                                download_model.downloads = download_model.downloads.filter(function (el) { return el.id !== download.id} )
                                download_model.remove(index)
                            }
                        }
                    }
                }
            }
        }
        ListView
        {
            id: list_view
            anchors
            {
                topMargin: 10
                top: download_text.bottom
                bottom: rect.bottom
                horizontalCenter: parent.horizontalCenter
            }
            width: rect.width - 20
            spacing: 5
            model: download_model
            delegate: download_delegate
        }
        Text
        {
            id: download_text
            horizontalAlignment: Text.AlignHCenter
            height: 30
            anchors
            {
                top: rect.top
                topMargin: 20
                left: rect.left
                right: rect.right
            }
            font.pixelSize: 20
            text: "Downloads"
        }
        Button
        {
            id: close_button
            text: "Close"
            width: 75
            height: 50
            style : ButtonStyle
            {
                background: Rectangle
                {
                    color: is_dark === false ? "gainsboro" : "gray"
                    radius: 20
                }
            }
            anchors
            {
                bottom: rect.bottom
                bottomMargin: 10
            }
            x: rect.width/2+10
            onClicked:
            {
                downloads_view.visible = !downloads_view.visible
            }
        }
    }
    function onDownloadRequested(download)
    {

        if(!itemcode_view.visible)
        {
            downloads_view.visible = true
        }
        downloads_view.append(download)
        download.accept()
    }
    Rectangle
    {
        id: about_view
        visible: false
        anchors.fill: parent
        color: is_dark === false ? "gainsboro" : "gray"
        Rectangle
        {
            color: is_dark === false ? "lightGray" : "darkGray"
            visible: true
            radius: 30
            anchors
            {
                top: parent.top
                topMargin: 40
                bottom: parent.bottom
                bottomMargin: parent.width/9
                right: parent.right
                rightMargin: parent.width/8
                left: parent.left
                leftMargin: parent.width/8
            }
            Text
            {
                id: about_view_text
                horizontalAlignment: Text.AlignHCenter
                height: 30
                anchors
                {
                    top: parent.top
                    topMargin: 20
                    left: parent.left
                    right: parent.right
                }
                font.pixelSize: 20
                text: "About DeviumBrowser"
            }
            Image
            {
                id: devium_image
                source: "icons/icons/icon.png"
                height: 100
                width: 100
                anchors
                {
                    top: parent.top
                    topMargin: 40
                    left: parent.left
                    leftMargin: 20
                }
                enabled: false
            }
            Image
            {
                source: "icons/icons/newyear.png"
                height: 150
                width: 150
                anchors
                {
                    bottom: parent.bottom
                    bottomMargin: 40
                    right: parent.right
                    rightMargin: 20
                }
                enabled: false
            }
            Text
            {
                id: dev_text
                height: 30
                anchors
                {
                    top: about_view_text.bottom
                    topMargin: 15
                    left: devium_image.right
                }
                font.pixelSize: 40
                text: "Devium"
            }
            Text
            {
                width: 150
                anchors
                {
                    top: dev_text.bottom
                    topMargin: 10
                    left: devium_image.right
                    leftMargin: 2
                }
                font.pixelSize: 20
                text: "Browser"
            }
            Text
            {
                height: 30
                anchors
                {
                    top: dev_text.bottom
                    topMargin: 60
                    left: parent.left
                    leftMargin: 40
                }
                font.pixelSize: 20
                text: "Version: 1.0\nSoftware Update: 1.0\nCode: fn11-31b\nAttention! Happy New Year!"
            }
            Button
            {
                text: "Close"
                width: 75
                height: 50
                x:parent.width/2-40
                style : ButtonStyle
                {
                    background: Rectangle
                    {
                        color: is_dark === false ? "gainsboro" : "gray"
                        radius: 20
                    }
                }
                anchors
                {
                    bottom: parent.bottom
                    bottomMargin: 10
                }
                onClicked:
                {
                    about_view.visible = false;
                }
            }
        }
    }
    Action
    {
        shortcut: "Ctrl+D"
        onTriggered:
        {
            downloads_view.visible = !downloads_view.visible
            itemcode_view.visible = false
        }
    }
    Action
    {
        shortcut: StandardKey.Refresh
        onTriggered:
        {
            if (current_web)
            {
                current_web.reload()
            }
        }
    }
    Action
    {
        shortcut: StandardKey.Close
        onTriggered: current_web.triggerWebAction(WebEngineView.RequestClose)
    }
    Action
    {
        shortcut: StandardKey.Back
        onTriggered: current_web.triggerWebAction(WebEngineView.Back)
    }
    Action
    {
        shortcut: StandardKey.Forward
        onTriggered: current_web.triggerWebAction(WebEngineView.Forward)
    }
    Action
    {
        shortcut: "Ctrl+B"
        onTriggered: is_dark = !is_dark
    }
    Action
    {
        shortcut: "Ctrl+Shift+I"
        onTriggered: itemcode_view.visible = !itemcode_view.visible
    }
}
