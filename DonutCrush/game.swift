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
    var direction: Direction = Direction.none
}
enum Direction {
    case right, left, up, down, none
}

struct Grid {
    var row: Int
    var col: Int
    
    init(r: Int, c: Int){
        self.row = r
        self.col = c
    }
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
    let timeUpSecond: Int = 60 // 時間到的秒數
    
    func initialGame(){
        donuts = Array(repeating: Array(repeating: Donut(),
                                        count: boardCol),
                       count: boardRow)
        
        getHighestScore() // set highest score
        timeUp = false
        score = 0
        elapsedTime = 0
        secondElapse = 0
        
        randomBoard()
        
    }
    
    func randomBoard(){
        for re_col in 0..<boardCol{
            let col = boardCol - re_col - 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(re_col)){
                for row in 0..<self.boardRow{
                    self.donuts[row][col].value = Int.random(in: 1...12)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            self.disappearGrid(comboTimes: 0) // 消除連線的格子
        }
    }
    
    func startTimer(){
        elapsedTime += secondElapse
        secondElapse = 0
        startDate = Date()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){ [weak self] timer in
            if let self = self,
               let startDate = self.startDate{
                self.secondElapse = Int(round(timer.fireDate.timeIntervalSince1970 - startDate.timeIntervalSince1970))
                if self.elapsedTime + self.secondElapse == self.timeUpSecond{ // 時間到
                    self.endGame()
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
    
    func endGame(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1){
            if self.score > self.highestScore{
                self.highestScore = self.score
                self.saveHighestScore()
            }
            self.timeUp = true
        }
    }
    
    func haveThreeSame(row: Int, col: Int, value: Int, direction: Direction) -> Bool{
        // value 放在(row, col)這格 (格子, 向哪個方向交換) 會不會連線
        if value == 0{return false}
        
        var starttt = col
        var enddd = col
        // 橫(左->右)
        while enddd < boardCol-1 && donuts[row][enddd+1].value == value && direction != .left{ // 向右檢查
            enddd += 1
        }
        while starttt > 0 && donuts[row][starttt-1].value == value && direction != .right{ // 向左檢查
            starttt -= 1
        }
        if enddd-starttt >= 2{
            return true
        }
        
        starttt = row
        enddd = row
        // 直 (上->下)
        while starttt > 0 && donuts[starttt-1][col].value == value && direction != .down{ // 向上檢查
            starttt -= 1
        }
        while enddd < boardRow-1 && donuts[enddd+1][col].value == value && direction != .up{ // 向下檢查
            enddd += 1
        }
        if enddd-starttt >= 2{
            return true
        }
        return false
    }
    
    func canSwipe(row: Int, col: Int) -> Bool{
        switch donuts[row][col].direction{
        case .right:
            if haveThreeSame(row: row, col: col, value: donuts[row][col+1].value, direction: .left) || haveThreeSame(row: row, col: col+1, value: donuts[row][col].value, direction: .right){
                return true
            }
        case .left:
            if haveThreeSame(row: row, col: col, value: donuts[row][col-1].value, direction: .right) || haveThreeSame(row: row, col: col-1, value: donuts[row][col].value, direction: .left){
                return true
            }
        case .up:
            if haveThreeSame(row: row, col: col, value: donuts[row-1][col].value, direction: .down) || haveThreeSame(row: row-1, col: col, value: donuts[row][col].value, direction: .up){
                return true
            }
        case .down:
            if haveThreeSame(row: row, col: col, value: donuts[row+1][col].value, direction: .up) || haveThreeSame(row: row+1, col: col, value: donuts[row][col].value, direction: .down){
                return true
            }
        default:
            return false
        }
        return false
    }
    
    func doSwipe(row: Int, col: Int){ // 格子交換
        let donutValue = donuts[row][col].value
        
        switch donuts[row][col].direction{
        case .right:
            donuts[row][col].value = donuts[row][col+1].value
            donuts[row][col+1].value = donutValue
            donuts[row][col+1].offset = .zero
        case .left:
            donuts[row][col].value = donuts[row][col-1].value
            donuts[row][col-1].value = donutValue
            donuts[row][col-1].offset = .zero
        case .up:
            donuts[row][col].value = donuts[row-1][col].value
            donuts[row-1][col].value = donutValue
            donuts[row-1][col].offset = .zero
        case .down:
            donuts[row][col].value = donuts[row+1][col].value
            donuts[row+1][col].value = donutValue
            donuts[row+1][col].offset = .zero
        default: break
        }
        donuts[row][col].direction = .none
        donuts[row][col].offset = .zero
        
        disappearGrid(comboTimes: 1) // 消除連線的格子
    }
    
    func disappearGrid(comboTimes: Int){ // 消除連線的格子
        var disappearGrids: [Grid] = [] // 可連線的格子
        var addScore = 0
        
        for re_row in 0..<boardRow{
            let row = boardRow - re_row - 1
            for col in 0..<boardCol{
                if haveThreeSame(row: row, col: col, value: donuts[row][col].value, direction: donuts[row][col].direction){
                    disappearGrids.append(Grid(r: row, c: col))
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            for grid in disappearGrids{
                self.donuts[grid.row][grid.col].value = 0
            }
        }
        print("combo", comboTimes)
        addScore = (disappearGrids.count) * comboTimes
        for i in 0..<addScore{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1 * Double(i)){
                self.score += 1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3){
            self.dropDown(comboTimes: comboTimes)
        }
    }
    
    func dropDown(comboTimes: Int){
        for col in 0..<boardCol{
            var dropCount = 0
            
            for re_row in 0..<boardRow{
                let row = boardRow - re_row - 1
                
                if dropCount != 0 && donuts[row][col].value != 0 {
                    donuts[row+dropCount][col].value = donuts[row][col].value
                    donuts[row+dropCount][col].offset.height = CGFloat(-dropCount * 40)
                    
                    if row-dropCount >= 0{
                        donuts[row][col].value = donuts[row-dropCount][col].value
                    }
                    else {
                        donuts[row][col].value = Int.random(in: 1...12)
                    }
                    donuts[row][col].offset.height = CGFloat(-dropCount * 40)
                }
                
                if donuts[row][col].value == 0{
                    dropCount += 1
                    if row < dropCount{
                        donuts[row][col].value = Int.random(in: 1...12)
                        donuts[row][col].offset.height = CGFloat(-dropCount * 40)
                    }
                }
            } // for row end
            
            for row in 0..<boardRow{
                if donuts[row][col].value == 0{
                    donuts[row][col].value = Int.random(in: 1...12)
                    donuts[row][col].offset.height = CGFloat(-dropCount * 40)
                }
                
                withAnimation(.linear){
                    donuts[row][col].offset.height = 0
                }
            }
        } // for col end
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.disappearGrid(comboTimes: comboTimes+1)
        }
    } // func dropDown end
}
