////
////  ContentView.swift
////  yealinkCalc
////
////  Created by Aleksandr Oschepkov on 20.02.2024.
////
//
//import SwiftUI
//import SwiftData
//import Combine
//let scheduleConf: [String: Any?] = [
//    "autoCount": true,
//    "confTypes": ["NC", "VGCP"],
//    "data": nil,
//    "limit": 20,
//    "orderbys": [["field": "conferenceTimePattern.conferenceTime.startDateTimeStamp", "order": 1]],
//    "skip": 0,
//    "states": ["ready", "create", "ongoing"],
//    "total": 0
//]
//struct YealinkCalendar: View {
//    @Environment(\.modelContext) private var modelContext
//    @Query(sort: \ConfDataModel.startDateTimeStamp) private var confDataItems: [ConfDataModel]
//    @StateObject var weatherViewModel: WeatherViewModel
//    @State private var showingAlert = false
//    
//    let timer = Timer.publish(every: 60, on: .main, in: .common).autoconnect()
//    var ymsUrl = "api/open/v1/conference/record/b6b4307d15b04b0ca24f73ae299f574d/pagedList"
//    var ymsapi = YmsApiResponce()
//    @State var CellID = " "
//    var body: some View {
//        VStack(){
//            ZStack(){
//                Rectangle()
//                    .fill(Color(hex: "#9CA1A4")!)
//                    .frame(maxWidth: .infinity, maxHeight: 90.0)
//                HStack(alignment: .bottom, content: {
//                    Rectangle()
//                        .fill(Color(hex: "#9CA1A4")!)
//                        .frame(maxWidth: 20, maxHeight: 90)
//                    VStack(){
//                        Rectangle()
//                            .fill(Color(hex: "#9CA1A4")!)
//                            .frame(width: 330,height: 10)
//                        Image("inpzMini")
//                            .resizable()
//                            .frame(width: 330,height: 90)
//                            .frame(alignment: .center)
//                    }
//                    Spacer()
//                    VStack(){
//                        Text(currentDate(format: "EEEE"))
//                            .font(.title)
//                        Text(currentDate(format: "dd MMMM"))
//                            .font(.title)
//                    }
//                    .frame(alignment: .trailing)
//                    AnalogClockView(foregroundColor: .constant(.black))
//                        .frame(width: 75,height: 75)
//                    Rectangle()
//                        .fill(Color(hex: "#9CA1A4")!)
//                        .frame(maxWidth: 20, maxHeight: 90)
//                    DigitalTime()
//                        .frame(width: 90,height: 90)
//                        .frame(alignment: .center)
//                    Rectangle()
//                        .fill(Color(hex: "#9CA1A4")!)
//                        .frame(maxWidth: 20, maxHeight: 90)
//                })
//            }
//            HStack(){
//                ZStack(){
//                    RoundedRectangle(cornerRadius: 10)
//                        .fill(Color(hex: "#B5DBD2")!)
//                        .frame(maxWidth: 1000)
//                    VStack(alignment: .center, content: {
//                        Spacer()
//                        Text(confDataItems.first?.conferenceSubject ?? "Переговорная 'Библиотека'")
//                            .font(.system(size: 36))
//                            .foregroundStyle(.white)
//                            .frame(height: 100)
//                        Text((confDataItems.first?.startTime ?? " ") + " - " + (confDataItems.first?.endTime ?? "Свободна -"))
//                            .font(.system(size: 42))
//                            .foregroundStyle(.white)
//                            .frame(height: 100)
//                        Text(confDataItems.first?.plainEmailRemark ?? "Переговорная комната")
//                            .font(.system(size: 36))
//                            .foregroundStyle(.white)
//                            .frame(height: 100)
//                        Spacer()
//                    })
//                }
//                Spacer()
//                ScrollView() {
//                    Spacer(minLength: 10)
//                    VStack(alignment: .leading, spacing: 20, content: {
//                        ForEach(confDataItems, id: \.self) { Cell in
//                            Button {
//                                CellID = Cell.conferencePlanId
//                                showingAlert = true
//                            } label: {
//                                confCell(Cell)
//                            }     .alert(isPresented: $showingAlert) {
//                                Alert(title: Text(confDataItems.filter({$0.conferencePlanId == CellID}).first?.conferenceSubject ?? " error"),
//                                      message: Text(confDataItems.filter({$0.conferencePlanId == CellID}).first?.plainEmailRemark ?? " error"),
//                                      dismissButton: .default(Text("Вернуться"))
//                                )
//                            }
//                           
//                        } .frame(height: 45)
//                       
//                    }).frame(maxWidth: 300)
//                }
//            }
//            Spacer()
//            CurrentlyWeatherView(weatherViewModel: weatherViewModel)
//        }///rrgb(156,161,164)
//        .background(Color(hex: "#9CA1A4"))
//        .edgesIgnoringSafeArea(.all)
//        .statusBar(hidden: true)
//        .task {
//            removeAll()
//            do {
//                let confInfo =  try await ymsapi.getConfSchedule(funcURL: ymsUrl , json: scheduleConf as [String : Any])
//                print(confInfo)
//                confDataWriting(schedulerInfo: confInfo)
//                print("SwiftData")
//                print(confDataItems)
//            } catch {
//                print("Ерор")
//            }
//            
//        }.onReceive(timer) { t in
//            
//            let curDate = Date().timeIntervalSince1970 * 1000
//            let dateToString = String(format: "%.0f", curDate)
//            
//            print("timer fired \(curDate)")
//            print(dateToString)
//            
//            Task{
//                removeAll()
//                do {
//                    let confInfo =  try await ymsapi.getConfSchedule(funcURL: ymsUrl , json: scheduleConf as [String : Any])
//                    confDataWriting(schedulerInfo: confInfo)
//                } catch {
//                    print("Ерор")
//                }
//            }
//            
//        }
//    }
//    func confDataWriting(schedulerInfo: ConferenseSheduler){
//        let confInfo = schedulerInfo.data.data
//        var i = confInfo.count
//        var numElement = 0
//        while i != 0{
//            let conferencePlanId = confInfo[numElement].conferencePlanID
//            let conferenceSubject = confInfo[numElement].conferenceSubject.subject
//            let startDateTimeStamp = confInfo[numElement].conferenceTimePattern.conferenceTime.startDateTimeStamp
//            let endDateTimeStamp = confInfo[numElement].conferenceTimePattern.conferenceTime.endDateTimeStamp
//            let startTime = confInfo[numElement].conferenceTimePattern.conferenceTime.startTime
//            let endTime = confInfo[numElement].conferenceTimePattern.conferenceTime.endTime
//            let organizerId = confInfo[numElement].organizer.id
//            let organizerName = confInfo[numElement].organizer.name
//            let organizeExt = confInfo[numElement].organizer.organizerExtension
//            let plainEmailRemark = confInfo[numElement].plainEmailRemark
//            let confsInfo = ConfDataModel(conferencePlanId: conferencePlanId, conferenceSubject: conferenceSubject, startDateTimeStamp: startDateTimeStamp, endDateTimeStamp: String(endDateTimeStamp), startTime: startTime, endTime: endTime, organizerId: organizerId, organizerName: organizerName, organizeExt: organizeExt, plainEmailRemark: plainEmailRemark)
//            i = i - 1
//            numElement = numElement + 1
//            print("Print items  \(confsInfo.organizerName)")
//            modelContext.insert(confsInfo)
//        }
//    }
//    //ToDo View
//    @ViewBuilder
//    //   func confCell(_ confs: ConfModel) -> some View{
//    func confCell(_ confs: ConfDataModel) -> some View{
//            HStack(){
//                VStack(spacing: 1, content: {
//                    let timePeriod = confs.startTime + "-" + confs.endTime
//                    Text(timePeriod)
//                        .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .trailing)
//                        .font(.title)
//                    Text(confs.organizerName)
//                        .frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .trailing)
//                    
//                })
//                Spacer()
//            }
//            .font(.callout)
//            .padding(.horizontal, 15)
//            .frame(maxWidth: .infinity*0.8, alignment: .center)
//            .frame(height: 60)
//            .background(Color(hex: "#B5DBD2")!, in: .rect(cornerRadius: 10))
//            .contentShape(.dragPreview, .rect(cornerRadius: 10))
//        
//    }
//    func removeAll() {
//        print("Remove all")
//        do {
//            try modelContext.delete(model: ConfDataModel.self)
//            
//        } catch {
//            print("Failed to clear all Country and City data.")
//        }
//    }
//    func currentDate(format: String) -> String{
//        let dateFormatter = DateFormatter()
//        dateFormatter.locale = Locale(identifier: "ru_RU")
//        dateFormatter.dateFormat = format
//        let stringDate = dateFormatter.string(from: Date())
//        return stringDate
//    }
//}
//
