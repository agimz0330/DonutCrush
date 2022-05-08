//
//  game.swift
//  DonutCrush
//
//  Created by User23 on 2022/4/29.
//

import Foundation
import SwiftUI

let yellow_bg = Color(red: 238/255, green: 225/255, blue: 186/255)
let brown_bg = Color(red: 156/255, green: 99/255, blue: 79/255)
let orange_font = Color(red: 195/255, green: 121/255, blue: 96/255)
let milkChocolate_color = Color(red: 132/255, green: 86/255, blue: 60/255)
let deer_color = Color(red: 189/255, green: 140/255, blue: 97/255)
let cream_color = Color(red: 239/255, green: 226/255, blue: 178/255)
let caputMortuum_color = Color(red: 90/255, green: 44/255, blue: 34/255)
let rootBear_color = Color(red: 39/255, green: 13/255, blue: 11/255)


struct Donut{
    var value: Int = 0
//    var isAppear: Bool = false
    var offset: CGSize = CGSize.zero
    var previousOffset: CGSize = CGSize.zero
}

class Game: ObservableObject{
    @Published var donuts: [[Donut]] = Array(repeating: Array(repeating: Donut(),
                                                              count: 9),
                                             count: 12)
    // 遊戲行列數
    let boardRow: Int = 12
    let boardCol: Int = 9
    
    @Published var score: Int = 0
    // 最高分
    @Published var highestScore: Int = 0
    // 計時
    private var timer: Timer?
    private var startDate: Date?
    @Published var elapsedTime: Int = 0 // 遊戲開始 總共過了幾秒
    @Published var secondElapse: Int = 0 // 計時器跑了幾秒
    @Published var timeUp: Bool = false // 時間到
    let timeUpSecond: Int = 10 // 時間到的秒數
    
    func initialGame(){
        donuts = Array(repeating: Array(repeating: Donut(),
                                        count: boardCol),
                       count: boardRow)

        for row in 0..<boardRow{
            for col in 0..<boardCol{
                donuts[row][col].value = Int.random(in: 1...12)
            }
        }
        
        getHighestScore() // set highest score
        timeUp = false
        score = 0
        elapsedTime = 0
        secondElapse = 0
    }
    
    func startTimer(){
        elapsedTime += secondElapse
        secondElapse = 0
        startDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ [weak self] timer in
            if let self = self,
               let startDate = self.startDate{
                self.secondElapse = Int(round(timer.fireDate.timeIntervalSince1970 - startDate.timeIntervalSince1970))
                if self.elapsedTime + self.secondElapse == 10{ // 時間到
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
    
    func getHighestScore(){
        // 從UserDefaults存取最高分
        if let data = UserDefaults.standard.data(forKey: "highestScore"){
            let decoder = JSONDecoder()
            if let decodeData = try? decoder.decode(Int.self, from: data){
                highestScore = decodeData
            }
        }
    }
}
