//
//  TimerView.swift
//  StorySDK
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class TimerView: SRWidgetView {
    private let story: SRStory
    private let timerWidget: TimerWidget
    
    private let centerView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 16
        return sv
    }()
    
    private let captionView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 16
        return sv
    }()

    private var digitViews = [UIView]()
    private var digitLabels = [UILabel]()
    private let captions = ["Days", "Hours", "Minutes"]
    
    private var widgetDate = Date()
    private var currentDate = Date()
    
    private var timer: Timer?
    private var timeDelta: TimeInterval = 60
    private var dateIsChecked = false
    
    init(story: SRStory, data: SRWidget, timerWidget: TimerWidget) {
        self.story = story
        self.timerWidget = timerWidget
        super.init(data: data)
    }
    
    override func setupView() {
        super.setupView()
        
        var viewColor: UIColor = white
        var textColor: UIColor = white
        if timerWidget.color == "purple" {
            let colors = [purpleStart, purpleFinish]
            let points = [CGPoint(x: 0.02, y: 0), CGPoint(x: 0.96, y: 0)]
            let l = Utils.getGradient(frame: bounds, colors: colors, points: points)
            l.cornerRadius = 10
            layer.insertSublayer(l, at: 0)
        } else {
            backgroundColor = Utils.getSolidColor(timerWidget.color)
        }
        let text = timerWidget.text
        var fontScaleFactor: CGFloat = 1
        if let minWidth = data.positionLimits.minWidth {
            fontScaleFactor *= frame.width / CGFloat(minWidth)
        }
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.getFont(name: "Inter-Bold", size: 16 * fontScaleFactor)
        label.text = text
        label.textAlignment = .center
        if timerWidget.color == "white" {
            textColor = black
            viewColor = gray
        }
        label.textColor = textColor
        addSubview(label)
        addSubview(captionView)
        addSubview(centerView)
        NSLayoutConstraint.activate([
            centerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerView.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
        
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: centerView.topAnchor, constant: -8 * xScaleFactor),
        ])
        
        NSLayoutConstraint.activate([
            captionView.centerXAnchor.constraint(equalTo: centerXAnchor),
            captionView.widthAnchor.constraint(equalTo: centerView.widthAnchor),
            captionView.topAnchor.constraint(equalTo: centerView.bottomAnchor, constant: 2 * xScaleFactor),
        ])
        
        for i in 0 ... 2 {
            let sv = UIStackView()
            sv.axis = .horizontal
            sv.spacing = 2
            sv.distribution = .fill
            for _ in 0 ... 1 {
                let v = UIView()
                NSLayoutConstraint.activate([
                    v.heightAnchor.constraint(equalToConstant: 36 * xScaleFactor),
                    v.widthAnchor.constraint(equalToConstant: 22 * xScaleFactor),
                ])
                v.layer.cornerRadius = 4
                v.backgroundColor = viewColor
                let l = UILabel()
                l.translatesAutoresizingMaskIntoConstraints = false
                v.addSubview(l)
                NSLayoutConstraint.activate([
                    l.centerYAnchor.constraint(equalTo: v.centerYAnchor),
                    l.centerXAnchor.constraint(equalTo: v.centerXAnchor),
                ])
                l.font = UIFont.getFont(name: "Inter-SemiBold", size: 16 * fontScaleFactor)
                l.text = "0"
                l.textColor = black
                digitLabels.append(l)
                digitViews.append(v)
                sv.addArrangedSubview(v)
            }
            let cl = UILabel()
            NSLayoutConstraint.activate([
                cl.widthAnchor.constraint(equalToConstant: 44 * xScaleFactor + 2),
            ])
            cl.font = UIFont.getFont(name: "Inter-Regular", size: 6 * fontScaleFactor)
            cl.textAlignment = .left
            cl.text = captions[i]
            cl.textColor = textColor
            captionView.addArrangedSubview(cl)
            centerView.addArrangedSubview(sv)
        }
    }
    
    override func setupContentLayer(_ layer: CALayer) {
        layer.cornerRadius = 10
        layer.shadowColor = black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkDate()
    }
}

// MARK: Date
extension TimerView {
    private func checkDate() {
        if dateIsChecked {
            return
        }
        dateIsChecked = true
        widgetDate = Date(timeIntervalSince1970: TimeInterval(timerWidget.time) / 1000)
//        currentDate = convertDateFromUTC()
        print("UTC:", Date(), "now:", currentDate, "widget:", widgetDate)
        if widgetDate > currentDate {
            refreshData()
            startTimer()
        } else {
            print("Timer not needed")
        }
    }
    
    private func convertDateFromUTC() -> Date {
        let currentDate = Date()
         
        let timezoneOffset =  TimeZone.current.secondsFromGMT()
        let epochDate = currentDate.timeIntervalSince1970
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        let timeZoneOffsetDate = Date(timeIntervalSince1970: timezoneEpochOffset)
        
        return timeZoneOffsetDate
    }
    
    private func refreshData() {
        let diffDays = widgetDate.days(from: currentDate)
        let diffHours = widgetDate.hours(from: currentDate) - diffDays * 24
        var diffMinutes = widgetDate.minutes(from: currentDate)  - diffDays * 24 * 60 - diffHours * 60
        if diffMinutes < 0 {
            diffMinutes = 0
        }
        digitLabels[0].text = String(diffDays / 10)
        digitLabels[1].text = String(diffDays % 10)
        digitLabels[2].text = String(diffHours / 10)
        digitLabels[3].text = String(diffHours % 10)
        digitLabels[4].text = String(diffMinutes / 10)
        digitLabels[5].text = String(diffMinutes % 10)
        
        if diffDays <= 0 && diffHours <= 0 && diffMinutes <= 0 {
            guard let timer = timer else {
                return
            }
            timer.invalidate()
            self.timer = nil
            // Отправим сообщение, что нужен фейерверк
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: startConfettiNotificationName), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: disableSwipeNotificanionName), object: nil)
        }
    }
}

// MARK: - Timer
extension TimerView {
    private func startTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: self.timeDelta, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc private func update () {
        if let date = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate) {
            currentDate = date
        }
        refreshData()
    }
}
