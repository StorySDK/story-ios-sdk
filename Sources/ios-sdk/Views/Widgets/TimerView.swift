//
//  TimerView.swift
//  ios-sdk
//
//  Created by MeadowsPhone Team on 06.02.2022.
//

import UIKit

class TimerView: UIView {
    /*
     const calculateTime = (time: number) => {
       const days = Math.floor(time / (1000 * 60 * 60 * 24));
       const hours = Math.floor((time / (1000 * 60 * 60)) % 24);
       const minutes = Math.floor((time / 1000 / 60) % 60);

       return {
         days: days < 10 ? `0${days > 0 ? days : 0}` : `${days}`,
         hours: hours < 10 ? `0${hours > 0 ? hours : 0}` : `${hours}`,
         minutes: minutes < 10 ? `0${minutes > 0 ? minutes : 0}` : `${minutes}`
       };
     };

     const INIT_ELEMENT_STYLES = {
       widget: {
         borderRadius: 10,
         padding: 15
       },
       text: {
         fontSize: 16,
         marginBottom: 8
       },
       digit: {
         width: 22,
         height: 36,
         fontSize: 16,
         borderRadius: 4
       },
       caption: {
         marginTop: 2,
         fontSize: 6
       }
     };

     */
    private var story: Story!
    private var data: WidgetData!
    private var timerWidget: TimerWidget!
    
    private lazy var centerView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .horizontal
        sv.spacing = 16
        
        return sv
    }()
    
    private lazy var captionView: UIStackView = {
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
    ///Timer
    private var timer: Timer?
    ///Интервал таймера
    private var timeDelta: TimeInterval = 60
    private var dateIsChecked = false
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    convenience init(frame: CGRect, story: Story, data: WidgetData, timerWidget: TimerWidget) {
        self.init(frame: frame)
        self.story = story
        self.data = data
        self.timerWidget = timerWidget
        self.transform = CGAffineTransform.identity.rotated(by: data.position.rotate * .pi / 180)

        prepareUI()
    }

    override func setNeedsLayout() {
        super.setNeedsLayout()
        DispatchQueue.main.async {
            self.checkDate()
        }
    }

    private func prepareUI() {
        backgroundColor = .clear
        layer.cornerRadius = 10
        layer.shadowColor = black.withAlphaComponent(0.15).cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = .zero
        layer.shadowRadius = 4
        clipsToBounds = true
        var viewColor: UIColor = white
        var textColor: UIColor = white
        if timerWidget.color == "purple" {
            let colors = [purpleStart, purpleFinish]
            let points = [CGPoint(x: 0.02, y: 0), CGPoint(x: 0.96, y: 0)]
            let l = Utils.getGradient(frame: bounds, colors: colors, points: points)
            l.cornerRadius = 10
            layer.insertSublayer(l, at: 0)
        }
        else {
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
            centerView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            label.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            label.bottomAnchor.constraint(equalTo: centerView.topAnchor, constant: -8 * xScaleFactor)
        ])
        
        NSLayoutConstraint.activate([
            captionView.centerXAnchor.constraint(equalTo: centerXAnchor),
            captionView.widthAnchor.constraint(equalTo: centerView.widthAnchor),
            captionView.topAnchor.constraint(equalTo: centerView.bottomAnchor, constant: 2 * xScaleFactor)
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
                    v.widthAnchor.constraint(equalToConstant: 22 * xScaleFactor)
                ])
                v.layer.cornerRadius = 4
                v.backgroundColor = viewColor
                let l = UILabel()
                l.translatesAutoresizingMaskIntoConstraints = false
                v.addSubview(l)
                NSLayoutConstraint.activate([
                    l.centerYAnchor.constraint(equalTo: v.centerYAnchor),
                    l.centerXAnchor.constraint(equalTo: v.centerXAnchor)
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
                cl.widthAnchor.constraint(equalToConstant: 44 * xScaleFactor + 2)
            ])
            cl.font = UIFont.getFont(name: "Inter-Regular", size: 6 * fontScaleFactor)
            cl.textAlignment = .left
            cl.text = captions[i]
            cl.textColor = textColor
            captionView.addArrangedSubview(cl)
            centerView.addArrangedSubview(sv)
        }
    }
}

//MARK: Date
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
        }
        else {
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
            //Отправим сообщение, что нужен фейерверк
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: startConfettiNotificationName), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name.init(rawValue: disableSwipeNotificanionName), object: nil)
        }
    }
}

//MARK: - Timer
extension TimerView {
    private func startTimer() -> Void {
        self.timer = Timer.scheduledTimer(timeInterval: self.timeDelta, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    @objc private func update () {
        if let date = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate) {
            currentDate = date
        }
        refreshData()
    }
}
