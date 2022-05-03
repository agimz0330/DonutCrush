//
//  game.swift
//  DonutCrush
//
//  Created by User23 on 2022/4/29.
//

import Foundation

struct Donut{
    var value: Int = 0
    var isAppear: Bool = false
    var offset: Int = 0
}

class Game: ObservableObject{
    let boardRow: Int = 15
    let boardCol: Int = 10
    
    @Published var highestScore: Int = 0
    
    private var timer: Timer?
    private var startDate: Date?
    @Published var elapsedTime: Int = 0
    @Published var secondElapse: Int = 0
    @Published var timeUp: Bool = false
    
    init(){
        setHighestScore() // set highest score
    }
    
    func startTimer(){
        elapsedTime += secondElapse
        secondElapse = 0
        startDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ [weak self] timer in
            if let self = self,
               let startDate = self.startDate{
                self.secondElapse = Int(round(timer.fireDate.timeIntervalSince1970 - startDate.timeIntervalSince1970))
                if self.elapsedTime + self.secondElapse == 10{
                    self.timeUp = true
                }
            }
        }
    }
    
    func stopTimer(){
        timer?.invalidate()
        timer = nil
    }
    
    func saveHighestScore(){ // 將最高分存入UserDefaults
        let encoder = JSONEncoder()
        if let encodeData = try? encoder.encode(highestScore){
            UserDefaults.standard.set(encodeData, forKey: "highestScore")
        }
    }
    
    func setHighestScore(){
        // 從UserDefaults存取最高分
        if let data = UserDefaults.standard.data(forKey: "highestScore"){
            let decoder = JSONDecoder()
            if let decodeData = try? decoder.decode(Int.self, from: data){
                highestScore = decodeData
            }
        }
    }
}
