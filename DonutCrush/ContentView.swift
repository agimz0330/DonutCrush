//
//  ContentView.swift
//  DonutCrush
//
//  Created by User23 on 2022/4/27.
//

import SwiftUI

struct ContentView: View {
    @StateObject var game: Game = Game()
    
    @State private var offset = CGSize.zero
    @State private var previousOffset = CGSize.zero
    
    @State private var offset2 = CGSize.zero
    @State private var previousOffset2 = CGSize.zero
    
    @State private var showStartView: Bool = false
    @State private var showResultView: Bool = false
    
    var dragGesture: some Gesture{
        DragGesture(minimumDistance: 25)
            .onChanged { (value) in
                if abs(value.translation.width) > abs(value.translation.height){ // 水平
                    
                    if value.translation.width > 40{
                        offset.width = previousOffset.width + 40
                    }
                    else if value.translation.width < -40{
                        offset.width = previousOffset.width - 40
                    }
                    else{
                        offset.width = previousOffset.width + value.translation.width
                    }
                    
                    if value.translation.width > 0{ // ->
                        offset2.width = -offset.width
                    }
                    else{ // <-
                        
                    }
                }
                else{
                    if value.translation.height > 0{ // 上
                        
                    }
                    else{ // 下
                        
                    }
                    if value.translation.height > 40{
                        offset.height = previousOffset.height + 40
                    }
                    else if value.translation.height < -40{
                        offset.height = previousOffset.height - 40
                    }
                    else{
                        offset.height = previousOffset.height + value.translation.height
                    }
                }
            }
            .onEnded { (value) in
                previousOffset = offset
                previousOffset2 = offset2
            }
    }
    
    var body: some View {
        ZStack{
            Color.yellow  // background
                .edgesIgnoringSafeArea(.all)
            
            VStack{ // content
            
                HStack{
                    Text("TIME: \(game.elapsedTime + game.secondElapse)")
                    Button(action: {
                        game.stopTimer()
                    }, label: {
                        Image(systemName: "pause.fill")
                            .font(.largeTitle)
                            .foregroundColor(.pink)
                    })
                    
                    Button(action: {
                        game.startTimer()
                    }, label: {
                        Image(systemName: "play.fill")
                            .font(.largeTitle)
                            .foregroundColor(.pink)
                    })
                } // HStack END
                
                VStack(spacing: 0){
                    ForEach(0..<game.boardRow){ row in // 1, 2, 3
                        HStack(spacing: 0){
                            ForEach(1..<game.boardCol){col in // 1, 2, 3, 4
                                ZStack{
                                    Color.gray
                                        .frame(width: 40, height: 40)
                                        .border(Color.pink)

//                                    Image("donut\(row*4 + col)")
//                                        .resizable()
//                                        .frame(width: 40, height: 40)
                                }
                            } // ForEach_col End
                        }
                    } // ForEach_row End
                }
                
                HStack{
                    Color.red
                        .frame(width: 40, height: 40)
                        .offset(offset)
                        .gesture(dragGesture)
                    
                    Color.green
                        .frame(width: 40, height: 40)
                        .offset(offset2)
                        .gesture(dragGesture)
                }
                
            } // content VStack END
            
            if game.timeUp{
                ResultView(game: game)
            }
        } // ZStack END
        .fullScreenCover(isPresented: $showStartView, content: {
            StartView()
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
    
    var body: some View{
        ZStack{
            Color.pink
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)
            
            VStack{
                ZStack{
                    Rectangle()
                        .frame(width: 250, height: 150)
                        .foregroundColor(Color.yellow)
                        .cornerRadius(50)
                    
                    VStack{
                        Text("\(111)") // 這輪分數
                            .font((.custom("", size: 70)))
                            .foregroundColor(Color.black)
                        Text("Highest Score: ") // 最高分
                            .font((.custom("", size: 25)))
                            .foregroundColor(Color.blue)
                        + Text("\(999)\t")
                            .italic()
                            .font((.custom("", size: 30)))
                            .foregroundColor(Color.blue)
                    }
                }
                
                Button(action: {}, label: {
                    ZStack{
                        Rectangle()
                            .frame(width: 100, height: 60)
                            .foregroundColor(Color.red)
                            .cornerRadius(25)
                        
                        Text("OK") // 這輪分數
                            .font((.custom("", size: 30)))
                            .foregroundColor(Color.black)
                    }
                    .offset(y: 30)
                })
            } // VStack END
            .offset(y: 60)
        }
        .onAppear{
            game.stopTimer()
        }
    }
}
