//
//  Constants.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 03.02.2022.
//

import UIKit

public typealias Json = [String: Any]

/// Длительность анимаций при действиях
let animationsDuration: TimeInterval = 0.2

/// Размеры окна в редакторе на сайте. Понадобится для масштабирования
let editorWindowSize = CGSize(width: 390, height: 694)
/// Коэффициент масштабирования по горизонтали. Вычисляется при показе виджетов
var xScaleFactor: CGFloat = 1
/// Коэффициент масштабирования по вертикали. Вычисляется при показе виджетов
var yScaleFactor: CGFloat = 1
/// Высота верхней вьюшки (где картинка и название Story)
let topViewHeight: CGFloat = 64

public let pinkColor = #colorLiteral(red: 0.9843137255, green: 0.337254902, blue: 0.4745098039, alpha: 1)  // #FB5679

public let sliderTint = #colorLiteral(red: 0.3921568627, green: 0.3921568627, blue: 0.3921568627, alpha: 0.250212585)  // #646464 with alpha = 0.25
public let sliderStart = #colorLiteral(red: 0.8078431373, green: 0.1450980392, blue: 0.7921568627, alpha: 1)  // #CE25CA
public let sliderFinish = #colorLiteral(red: 0.9176470588, green: 0.05490196078, blue: 0.3058823529, alpha: 1)  // #EA0E4E

public let purpleStart = #colorLiteral(red: 0.6823529412, green: 0.07450980392, blue: 0.6705882353, alpha: 1)  // #AE13AB
public let purpleFinish = #colorLiteral(red: 0.537254902, green: 0.05490196078, blue: 0.9176470588, alpha: 1)  // #890EEA
public let blue = #colorLiteral(red: 0, green: 0.6980392157, blue: 1, alpha: 1)  // #00B2FF
public let darkBlue = #colorLiteral(red: 0.2117647059, green: 0.431372549, blue: 0.9960784314, alpha: 1)  // #366EFE
public let white = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)  // #FFFFFF
public let green = #colorLiteral(red: 0.2666666667, green: 0.8509803922, blue: 0.2156862745, alpha: 1)  // #44D937
public let orange = #colorLiteral(red: 1, green: 0.662745098, blue: 0.2392156863, alpha: 1)  // #FFA93D
public let orangeRed = #colorLiteral(red: 1, green: 0.2980392157, blue: 0.1450980392, alpha: 1)  // #FF4C25
public let yellow = #colorLiteral(red: 0.9529411765, green: 0.8, blue: 0, alpha: 1)  // #F3CC00
public let black = #colorLiteral(red: 0.01960784314, green: 0.01960784314, blue: 0.1137254902, alpha: 1)  // #05051D
public let red = #colorLiteral(red: 0.8392156863, green: 0.1529411765, blue: 0.1529411765, alpha: 1)  // #D62727
public let gray = #colorLiteral(red: 0.8666666667, green: 0.8588235294, blue: 0.8705882353, alpha: 1)  // #DDDBDE
public let darkGray = #colorLiteral(red: 0.09411764706, green: 0.09411764706, blue: 0.1803921569, alpha: 1)  // #DDDBDE

// Notifications
let disableSwipeNotificanionName = "DisableSwipe"
let enableSwipeNotificanionName = "EnableSwipe"
let sendStatisticNotificationName = "SendStatistic"
let startConfettiNotificationName = "StartConfetti"

let groupIdParam = "group_id"
let storyIdParam = "story_id"
let widgetIdParam = "widget_id"
let widgetValueParam = "value"
let widgetTypeParam = "type"

let statisticActionsParam = "actions"

let statisticClickParam = "click"
let statisticDurationParam = "duration"
let statisticImpressionParam = "impression"
let statisticAnswerParam = "answer"

let statisticBackParam = "back"
let statisticNextParam = "next"
let statisticOpenParam = "open"
let statisticCloseParam = "close"
let statisticInteractionsParam = "interactions"
let statisticViewsParam = "views"
