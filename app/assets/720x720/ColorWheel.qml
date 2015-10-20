import bb.cascades 1.0
import bb.system 1.0
import colorwheel 1.0

Page { // PAGE - START
    property int padding: 20
    property int cursorSize: 30
    
    property bool expanded: false
    
    property alias selectedColor: cntrColor.background
    property alias hex: hexLabel.text
    property alias rgb: rgbLabel.text
    
    Container {
        horizontalAlignment: HorizontalAlignment.Fill
        layout: DockLayout {}
        
        Container { // BODY - START
            id: cntrBody
            horizontalAlignment: HorizontalAlignment.Fill
            topPadding: getBodyPadding()
            
            ColorPickerView {
                id: colorPickerView
                objectName: "colorPickerView"
                
                layoutProperties: StackLayoutProperties { spaceQuota: 1 }
                horizontalAlignment: HorizontalAlignment.Center
                preferredWidth: 400
                preferredHeight: 500
                
                ColorWheelView {
                    id: colorWheelView
                    objectName: "colorWheelView"
                    
                    layout: AbsoluteLayout {}
                    preferredWidth: expanded ? colorPickerView.preferredWidth * 2 / 3 : colorPickerView.preferredWidth
                    preferredHeight: preferredWidth
                    
                    horizontalAlignment: HorizontalAlignment.Center
                    
                    ImageView { // COLOR WHEEL - START
                        objectName: "wheelImageView"
                        layoutProperties: AbsoluteLayoutProperties {}
                        preferredWidth: colorWheelView.preferredWidth
                        preferredHeight: colorWheelView.preferredHeight
                    } // COLOR WHEEL - END
                    
                    ImageView {
                        objectName: "ivCursor"
                        layoutProperties: AbsoluteLayoutProperties {
                            positionX: -120
                            positionY: -120
                        }
                        preferredWidth: cursorSize
                        preferredHeight: cursorSize
                    }
                }
                
                Container { // LIGHTNESS BAR - START
                    id: cntrLightness
                    topPadding: 20
                    LightnessBarView {
                        id: colorBarView
                        objectName: "colorBarView"
                        layout: AbsoluteLayout {}
                        preferredWidth: 720
                        preferredHeight: 32
                        
                        ImageView {
                            objectName: "barImageView"
                            layoutProperties: AbsoluteLayoutProperties {}
                            preferredWidth: 768
                            preferredHeight: 32
                        }
                        
                        ImageView {
                            objectName: "ivCursor"
                            layoutProperties: AbsoluteLayoutProperties {}
                            preferredWidth: cursorSize
                            preferredHeight: cursorSize
                        }
                    }    
                } // LIGHTNESS BAR - END
                
                Container { // HIDDEN - START
                    id: cntrColor
                    objectName: "cntrColor"
                    visible: false
                    
                    // RGB LABEL - START
                    Label {
                        id: rgbLabel
                        objectName: "rgbLabel"
                    } // RGB LABEL - END
                    
                    // HEX LABEL - START 
                    Label {
                        id: hexLabel
                        objectName: "hexLabel"
                    } // HEX LABEL - END
                } // HIDDEN - END
            }
            
            Container {
                horizontalAlignment: HorizontalAlignment.Fill
                
                Container { // COLOR RULE - START
                    visible: expanded
                    topPadding: 20
                    DropDown {
                        id: ddColorRule
                        title: 'Color Rules (Enabled In Full Version)'
                        enabled: false
                        options: [
                            Option { text: "None"; selected: true }
                        ]
                        
                        onExpandedChanged: {
                            if (expanded || ddFormat.expanded) {
                                cntrLightness.opacity = 0
                                ddFormat.visible = false
                            } else {
                                cntrLightness.opacity = 1
                                ddFormat.visible = true
                            }
                        }
                    }
                } // COLOR RULE - END
                
                Container { // FORMAT - START
                    visible: expanded
                    topPadding: 10
                    bottomPadding: 10
                    DropDown {
                        id: ddFormat
                        title: 'Format'
                        options: [
                            Option { imageSource: "asset:///images/icons/format/hex.png"; text: "#1234FE"; selected: true }, 
                            Option { imageSource: "asset:///images/icons/format/hex.png"; text: "1234FE" }, 
                            Option { imageSource: "asset:///images/icons/format/rgb.png"; text: "(255, 255, 255)" }, 
                            Option { imageSource: "asset:///images/icons/format/rgba.png"; text: "(0, 0, 0, 1.0)" }, 
                            Option { imageSource: "asset:///images/icons/format/hsv.png"; text: "(360, 100, 100)" }
                        ]
                        
                        onSelectedIndexChanged: {
                            if (selectedIndex == 0)
                                format = 'hexN'
                            else if (selectedIndex == 1)
                                format = 'hex'
                            else if (selectedIndex == 2)
                                format = 'rgb'
                            else if (selectedIndex == 3)
                                format = 'rgba'
                            else if (selectedIndex == 4)
                                format = 'hsv'
                        }
                        
                        onExpandedChanged: {
                            if (expanded || ddColorRule.expanded) {
                                cntrLightness.opacity = 0
                                ddColorRule.visible = false
                            } else {
                                cntrLightness.opacity = 1
                                ddColorRule.visible = true
                            }
                        }
                    }
                } // FORMAT - END
                
                Container { // SELECTED COLOR - START
                    background: selectedColor
                    horizontalAlignment: HorizontalAlignment.Fill
                    minHeight: 75
                    gestureHandlers: DoubleTapHandler { 
                        onDoubleTapped: {
                            killAllToasts()
                            if (countColorsInPalette() == 5)
                                toastCount.show()
                            else if (!isColorInPalette(getColor(rgb, 'rgb'))) { 
                                toastPalette.show()
                                copyToPalette(getColor(rgb, 'rgb'))
                            } else
                                toastAlready.show()
                        }
                    }
                    attachedObjects: [
                        SystemToast {
                            id: toastCount
                            body: "You can only have a maximum of 5 colors in your palette."
                        },
                        
                        SystemToast {
                            id: toastPalette
                            body: getColor(rgb, format) + " added to palette."
                            button.label: "Undo"
                            onFinished: {
                                if (result == SystemUiResult.ButtonSelection) {
                                    var r = getColor(rgb, 'rgb')
                                    palette = palette.replace(r, "")
                                }
                            }
                        },
                        
                        SystemToast {
                            id: toastAlready
                            body: getColor(rgb, format) + " has already been added to the palette."
                            button.label: "Remove"
                            onFinished: {
                                if (result == SystemUiResult.ButtonSelection) {
                                    var r = getColor(rgb, 'rgb')
                                    palette = palette.replace(r, "")
                                }
                            }
                        }
                    ]
                } // SELECTED COLOR - END
            }
        } // BODY - END
        
        // HEADER - START
        Container {
            layout: DockLayout {}
            horizontalAlignment: HorizontalAlignment.Right
            minHeight: 110
            topPadding: 50
            rightPadding: 50
            leftPadding: 50
            
            ImageView { imageSource: "asset:///images/logos/logo-header.png" }
            ImageView { // EXPAND - START
                id: ivExpand
                imageSource: expanded ? "asset:///images/header/shrink.png" : "asset:///images/header/expand.png" 
                horizontalAlignment: HorizontalAlignment.Right
                
                gestureHandlers: TapHandler {
                    onTapped: {
                        if (expanded)
                            expanded = false
                        else {
                            expanded = true
                            killAllToasts()
                        }
                    }
                }
            } // EXPAND - END
        } // HEADER - END
    }
    
    // =====================================================================
    // ACTION-BAR
    // =====================================================================
    actions: [
        InvokeActionItem {
            imageSource: "asset:///images/action-bar/share.png"
            title: "Share"
            query {
                mimeType: "text/plain"
                invokeActionId: "bb.action.SHARE"
            }
            onTriggered: { data = "Hey! Take a look at cooler - the perfect color palette app for designers.\nhttp://bit.ly/coolerbbw" }
        },
        
        ActionItem {
            imageSource: "asset:///images/action-bar/color.png"
            title: "Add Selected Colour"
            onTriggered: {
                killAllToasts()
                if (countColorsInPalette() == 5)
                    toastCount.show()
                else if (!isColorInPalette(getColor(rgb, 'rgb'))) {
                    toastPalette.show()
                    copyToPalette(getColor(rgb, 'rgb'))
                } else
                    toastAlready.show()
            }
        },
        
        ActionItem {
            imageSource: "asset:///images/action-bar/palette.png"
            title: (palette.length > 0) ? "Replace Palette" : "Set Palette"
            enabled: (ddColorRule.selectedOption.text != 'None')
            onTriggered: {
                killAllToasts()
                toastAll.show()
                toastAll.r = palette
                
                // Clear palette first
                palette = ''
                
                // Add all five colors from color rule to palette
                copyToPalette(getColor(getColorRule(1), 'rgb')) 
                copyToPalette(getColor(getColorRule(2), 'rgb')) 
                copyToPalette(getColor(getColorRule(3), 'rgb')) 
                copyToPalette(getColor(getColorRule(4), 'rgb')) 
                copyToPalette(getColor(getColorRule(5), 'rgb'))
            }
            attachedObjects: SystemToast {
                id: toastAll
                property string r // save palette
                body: getAllString() + " palette" + getAllMiddle() + ddColorRule.selectedOption.text.toLowerCase() + getAllEnding()
                button.label: "Undo"
                onFinished: { if (result == SystemUiResult.ButtonSelection) { palette = r }}
            }
        },
        
        ActionItem {
            imageSource: "asset:///images/action-bar/clear.png"
            title: "Clear Palette"
            enabled: (palette.length > 0)
            onTriggered: {
                killAllToasts()
                toastClear.show()
                
                // Store palettes temporarily to restore 
                // if user presses undo
                toastClear.r = palette
                
                // Clear palettes
                palette = ''
            }
            
            attachedObjects: [
                SystemToast {
                    id: toastClear
                    body: "Palette cleared."
                    button.label: "Undo"
                    
                    // Properties to store palettes
                    property string r
                    
                    onFinished: {
                        if (result == SystemUiResult.ButtonSelection) {
                            palette = r
                        }
                    }
                }
            ]
        }
    ] // ACTION-BAR - END
    
    // =====================================================================
    // HELPER FUNCTIONS
    // =====================================================================
    function killAllToasts() {
        toastAll.cancel()
        toastAlready.cancel()
        toastClear.cancel()
        toastCount.cancel()
        toastPalette.cancel()
    }
    
    function getBodyPadding() {
        if (expanded)
            return 20
        return 60
    }
    
    function getAllString() {
        if (palette.length == 0)
        	return "Set"
        else if (countColorsInPalette() == 1)
        	return "Replaced colour in"
        return "Replaced colours in"
    }
    
    function getAllMiddle() {
        if (getAllString() == "Set")
        	return ' to '
        return ' with '
    }
    
    function getAllEnding() {
        if (ddColorRule.selectedOption.text == 'Shades')
        	return '.'
        return ' colours.'
    }
    
    function copyToPalette(c) {
        var color = c.substring(1, c.length - 1)
        if (!isColorInPalette(getColor(color, 'rgb'))) {
            palette += c
	    }
    }
    
    function countColorsInPalette() {
        var p = palette, pp
        var arr = []
        
        if (p.length > 0) {
            // Get rid of front and end brackets
            pp = p.substring(1, p.length - 1)
            
            // Only one color
            if (p.indexOf(')(') == -1) {
                arr.push(pp)
                
            // More than one color
            } else {
                // Replace all brackets with delimiter (semi-colon)
                pp = pp.replace(/\)\(/g, ';')
                
                // Split into array
                arr = pp.split(';')
            }
        }
        return arr.length
    }
	
	// Check if color is in palette
    function isColorInPalette(c) {
    	return (palette.indexOf(c) != -1)
	}
    
    // Get string representation of color in the given format
    function getColor(c, f) {
        if (f == 'hex')
            return hexify(getComponentFromRGB(c, 'r'))
            + hexify(getComponentFromRGB(c, 'g'))
            + hexify(getComponentFromRGB(c, 'b'))
        else if (f == 'hexN')
            return "#" + hexify(getComponentFromRGB(c, 'r'))
            + hexify(getComponentFromRGB(c, 'g'))
            + hexify(getComponentFromRGB(c, 'b'))
        else if (f == 'rgb')
            return "(" + c + ")"
        else if (f == 'rgba')
            return "(" + c + ", 0.1)"
        else 
        	return "(" + convertRGBtoHSV(c) + ")"
    }
    
    function getComponentFromRGB(rgb, t) {
        var arr = rgb.split(", ")
        var r = parseFloat(arr[0])
        var g = parseFloat(arr[1])
        var b = parseFloat(arr[2])
        return (t == 'r') ? r : (t == 'g') ? g : b
    }
    
    function hexify(n) {
        var digits = '0123456789ABCDEF'
        var lsd = n % 16
        var msd = (n - lsd) / 16
        var hexified = digits.charAt(msd) + digits.charAt(lsd)
        return hexified
    }
    
    // RGB TO HSV
    function convertRGBtoHSV(rgb) {
        var arr = rgb.split(", ")
        var r = parseFloat(arr[0])
        var g = parseFloat(arr[1])
        var b = parseFloat(arr[2])
        
        var min = Math.min(r, g, b)
        var max = Math.max(r, g, b)
        
        var hsv, hue, sat, val
        
        // Compute value
        val = max
        if (val == 0) { // If black, set hue and saturation to 0
            hue = 0
            sat = 0
            hsv = Math.round(hue) + ', ' + Math.round(sat) + ', ' + Math.round(val)
            return hsv
        }
        
        // Normalize value
        r /= val
        g /= val
        b /= val
        min = Math.min(r, g, b)
        max = Math.max(r, g, b)
        
        // Computer saturation
        sat = max - min
        if (sat == 0) { // Saturation -> gray and arbitrarily assign hue
            hue = 0
            hsv = Math.round(hue) + ', ' + Math.round(sat) + ', ' + Math.round((val / 255) * 100)
            return hsv
        }
        
        // Normalize saturation
        r = (r - min) / (max - min)
        g = (g - min) / (max - min)
        b = (b - min) / (max - min)
        min = Math.min(r, g, b)
        max = Math.max(r, g, b)
        
        // Compute hue
        if (max == r) {
            hue = 0.0 + 60.0*(g - b)
            if (hue < 0)
            	hue += 360
        } else if (max == g)
            hue = 120 + 60*(b - r)
        else
        	hue = 240 + 60*(r - g)
        
        hsv = Math.round(hue) + ', ' + Math.round(sat * 100) + ', ' + Math.round((val / 255) * 100)
        return hsv
    }
    
    // HSV TO RGB
    function convertHSVtoRGB(hsv) {
        var arr = hsv.split(", ")
        var h = parseFloat(arr[0]) / 360
        var s = parseFloat(arr[1]) / 100
        var v = parseFloat(arr[2]) / 100
        
        var red, blue, green
        var r, b, g, k, m, n, o, p
        
        if (s == 0) {
            red = v * 255
            blue = v * 255
            green = v * 255
        } else {
            k = h * 6;
            m = Math.floor(k)
            n = v * (1 - s)
            o = v * (1 - s * (k - m))
            p = v * (1 - s * (1 - (k - m)))
            
            if (m == 0) {r = v; g = p; b = n}
            else if (m == 1) {r = o; g = v; b = n}
            else if (m == 2) {r = n; g = v; b = p}
            else if (m == 3) {r = n; g = o; b = v}
            else if (m == 4) {r = p; g = n; b = v}
            else {r = v; g = n; b = o}
            
            red = r * 255
            blue = g * 255
            green = b * 255
        }
        
        return Math.round(red) + ', ' + Math.round(blue) + ', ' + Math.round(green)
    }
    
    function setFormatDropdown() {
        var f = ''
        if (format == 'hexN')
            f = "#1234FE"
        else if (format == 'hex')
            f = "1234FE"
        else if (format == 'rgb')
            f = "(255, 255, 255)"
        else if (format == 'rgba')
            f = "(0, 0, 0, 1.0)"
        else if (format == 'hsv')
            f = "(360, 100, 100)"
        
        for (var i = 0; i < ddFormat.count(); i++) {
            var o = ddFormat.at(i)
            if(o.text == f)
                ddFormat.setSelectedIndex(i)
        }
    }
} // PAGE - END