//
//  ContentView.swift
//  DonutCrush
//
//  Created by User23 on 2022/4/27.
//

import SwiftUI

struct ContentView: View {
    @StateObject var game: Game = Game()
    
    @State private var showStartView: Bool = true
    @State private var stateStr: String = "Welcome"
    @State private var showResultView: Bool = false
    
    func dragGesture(r: Int, c: Int) -> some Gesture{
        DragGesture(minimumDistance: 10)
            .onChanged { (value) in
                if abs(value.translation.width) > abs(value.translation.height){ // 水平
                    // 限制移動的距離
                    if value.translation.width > 40{
                        game.donuts[r][c].offset.width = 40
                    }
                    else if value.translation.width < -40{
                        game.donuts[r][c].offset.width = -40
                    }
                    else{
                        game.donuts[r][c].offset.width = value.translation.width
                    }
                    
                    if value.translation.width > 0 && c < game.boardCol-1{ // ->
                        game.donuts[r][c].direction = Direction.right
                        game.donuts[r][c+1].offset.width = -game.donuts[r][c].offset.width
                    }
                    else if value.translation.width < 0 && c > 0{ // <-
                        game.donuts[r][c].direction = Direction.left
                        game.donuts[r][c-1].offset.width = -game.donuts[r][c].offset.width
                    }
                }
                else{ // 垂直
                    
                    if value.translation.height > 40{
                        game.donuts[r][c].offset.height = 40
                    }
                    else if value.translation.height < -40{
                        game.donuts[r][c].offset.height = -40
                    }
                    else{
                        game.donuts[r][c].offset.height = value.translation.height
                    }
                    
                    if value.translation.height < 0 && r > 0{ // 上
                        game.donuts[r][c].direction = Direction.up
                        game.donuts[r-1][c].offset.height = -game.donuts[r][c].offset.height
                    }
                    else if value.translation.height > 0 && r < game.boardRow-1{ // 下
                        game.donuts[r][c].direction = Direction.down
                        game.donuts[r+1][c].offset.height = -game.donuts[r][c].offset.height
                    }
                }
            }
            .onEnded { (value) in
                if game.canSwipe(row: r, col: c){ // 可以交換
                    game.doSwipe(row: r, col: c)
                }
                else{ // 不能交換
                    withAnimation(.easeInOut(duration: 0.3)){
                        // 將四周格子offset調回原本位置
                        game.donuts[r][c].offset = .zero
                        if c < game.boardCol-1 {game.donuts[r][c+1].offset = .zero}
                        if c > 0 {game.donuts[r][c-1].offset = .zero}
                        if r > 0 {game.donuts[r-1][c].offset = .zero}
                        if r < game.boardRow-1 {game.donuts[r+1][c].offset = .zero}
                    }
                }
            }
    }
    
    var body: some View {
        ZStack{
            my_background()
            
            VStack{ // content
                
                ZStack{ // 分數
                    Image("scoreboard")
                        .scaleEffect(1.5)
                    Text("\(game.score)") // 分數
                        .font((.custom("PWYummyDonuts", size: 40)))
                        .foregroundColor(rootBear_color)
                        .offset(x: 5, y: 5)
                    
                    HStack{
                        Button(action: { // 重新洗牌
                            withAnimation(.easeInOut(duration: 1)){
                                game.randomBoard()
                            }
                        }, label: {
                            Image(systemName: "shuffle")
                                .font(.largeTitle)
                                .foregroundColor(brown_bg)
                        })
                        
                        Button(action: { // 暫停
                            game.stopTimer()
                            stateStr = "pause"
                            showStartView = true
                        }, label: {
                            Image(systemName: "pause.fill")
                                .font(.largeTitle)
                                .foregroundColor(brown_bg)
                        })
                    }
                    .offset(x: 130, y: -40)
                }
                
                
                VStack(spacing: 0){ // 遊戲介面(格子)
                    
                    ForEach(0..<game.boardRow){ row in
                        HStack(spacing: 0){
                            
                            ForEach(0..<game.boardCol){col in 
                                ZStack{
                                    deer_color // 格子
                                        .frame(width: 40, height: 40)
                                        .border(cream_color)
                                        .opacity(0.6)
                                    
                                    if game.donuts[row][col].isHint{
                                        Rectangle()
                                            .fill(Color.white)
                                            .blur(radius: 10)
                                            .frame(width: 40, height: 40)
                                            .scaleEffect(1.2)
                                    }

                                    if game.donuts[row][col].value > 0{ // 甜甜圈
                                        Image("donut\(game.donuts[row][col].value)")
                                            .resizable()
                                            .frame(width: 40, height: 40)
                                            .offset(game.donuts[row][col].offset)
                                            .gesture(dragGesture(r: row, c: col))
                                    }
                                }
                            } // ForEach_col End
                        }
                    } // ForEach_row End
                }
                
                // 時間
                timeBarView(secondElapse: $game.secondElapse, elapsedTime: $game.elapsedTime , timeUpSecond: game.timeUpSecond)
                
//                Spacer()
            } // content VStack END
            
            if game.timeUp{ // 結算畫面
                ResultView(game: game, showStartView: $showStartView, stateStr: $stateStr)
            }
        } // ZStack END
        .fullScreenCover(isPresented: $showStartView, content: {
            StartView(game: game, showStartView: $showStartView, stateStr: $stateStr)
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct ResultView: View{
    @ObservedObject var game: Game
    @Binding var showStartView: Bool
    @Binding var stateStr: String
    
    var body: some View{
        ZStack{
            yellow_bg
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                ZStack{
                    Rectangle()
                        .frame(width: 250, height: 150)
                        .foregroundColor(cream_color)
                        .cornerRadius(50)
                    
                    VStack{
                        Text("Your Score")
                            .font((.custom("MAGICWORLD", size: 40)))
                            .foregroundColor(milkChocolate_color)
                            .offset(y: 15)
                        
                        Text("\(game.score)") // 這輪分數
                            .font((.custom("PWYummyDonuts", size: 70)))
                            .foregroundColor(orange_font)
                        Text("\nBest Score:\t") // 最高分
                            .font((.custom("", size: 20)))
                            .foregroundColor(milkChocolate_color)
                            + Text("\(game.highestScore)")
                            .italic()
                            .font((.custom("", size: 20)))
                            .foregroundColor(milkChocolate_color)
                    }
                }
                
                Button(action: {
                    game.initialGame()
                    stateStr = "Welcome"
                    showStartView = true
                }, label: {
                    ZStack{
                        Rectangle()
                            .frame(width: 100, height: 60)
                            .foregroundColor(caputMortuum_color)
                            .cornerRadius(25)
                            .shadow(radius: 20)
                        
                        Text("OK") // 返回按鈕
                            .font((.custom("MAGICWORLD", size: 40)))
                            .foregroundColor(cream_color)
                            .offset(y: 5)
                    }
                    .offset(y: 10)
                })
            } // VStack END
            .offset(y: 60)
        }
    }
}

struct my_background: View {
    var body: some View{
        ZStack{
            Image("cream_bg")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .offset(x: -250)
            Image("bake")
                .scaleEffect(0.5)
                .offset(y: 250)
        }
    }
}

struct timeBarView: View{
    @Binding var secondElapse: Int
    @Binding var elapsedTime: Int
    var timeUpSecond: Int
    
    var body: some View{
        let light_green = Color(red: 200/255, green: 240/255, blue: 220/255, opacity: 0.8)
        
        VStack{
            ZStack{
                Image(systemName: "bubble.middle.bottom.fill")
                    .font(.largeTitle)
                    .foregroundColor(orange_font)
                
                Text("\(timeUpSecond - secondElapse - elapsedTime)")
                    .font(.title3)
                    .foregroundColor(cream_color)
            }
            .offset(x: (-130 + 260 * CGFloat(timeUpSecond - secondElapse - elapsedTime)/CGFloat(timeUpSecond)), y: 20)
            
            ZStack{
                Rectangle()
                    .fill(light_green)
                    .frame(width: 300, height: 50)
                    .cornerRadius(30)
                    .padding()
                
                Rectangle()
                    .fill(cream_color)
                    .frame(width: 260, height: 30)
                    .cornerRadius(15)
                    .offset(x: 10)
                
                Rectangle()
                    .fill(orange_font)
                    .frame(width: 260 * CGFloat(timeUpSecond - secondElapse - elapsedTime)/CGFloat(timeUpSecond), height: 30)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .offset(x: (-240 + 260 * CGFloat(timeUpSecond - secondElapse - elapsedTime)/CGFloat(timeUpSecond)) / 2)
                
                Image("time_clock")
                    .resizable()
                    .frame(width: 70, height: 70)
                    .offset(x: -140)
            }
        }
    }
}
