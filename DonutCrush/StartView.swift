//
//  StartView.swift
//  DonutCrush
//
//  Created by User23 on 2022/4/30.
//

import SwiftUI

struct StartView: View {
    @ObservedObject var game: Game
    
    @Binding var showStartView: Bool
    @Binding var stateStr: String // start: welcome, pause: Pause
    
    var body: some View {
        ZStack{
            start_background()
            
            VStack{
                HStack{
                    Text("D")
                        .foregroundColor(orange_font)
                    Text("o")
                        .foregroundColor(caputMortuum_color)
                    Text("n")
                        .foregroundColor(deer_color)
                    Text("u")
                        .foregroundColor(milkChocolate_color)
                    Text("t ")
                        .foregroundColor(cream_color)
                }
                .font((.custom("PWYummyDonuts", size: 70)))
                
                HStack{
                    Text(" C")
                        .foregroundColor(deer_color)
                    Text("r")
                        .foregroundColor(brown_bg)
                    Text("u")
                        .foregroundColor(rootBear_color)
                    Text("s")
                        .foregroundColor(cream_color)
                    Text("h")
                        .foregroundColor(caputMortuum_color)
                }
                .font((.custom("PWYummyDonuts", size: 70)))
                
                VStack(alignment: .leading, spacing: 0){
                    HStack{
                        Text("\n\(stateStr)")
                            .font((.custom("MAGICWORLD", size: 50)))
                            .foregroundColor(rootBear_color)
                    }
                    
                    HStack{
                        Button(action: {
                            showStartView = false
                            game.startTimer()
                            game.initialGame()
                        }, label: {
                            Rectangle()
                                .fill(caputMortuum_color)
                                .frame(width: 160, height: 100)
                                .cornerRadius(30)
                                .shadow(radius: 20)
                                .padding()
                                .overlay(
                                    VStack(spacing: 10){
                                        Image(systemName: "play")
                                            .font(.largeTitle)
                                        Text("play")
                                    }
                                    .foregroundColor(cream_color)
                                )
                        })
                        
                        Button(action: {
                            game.initialGame()
                            showStartView = false
                            game.startTimer()
                        }, label: {
                            Rectangle()
                                .fill(cream_color)
                                .frame(width: 70, height: 100)
                                .cornerRadius(30)
                                .overlay(
                                    VStack(spacing: 10){
                                        Image(systemName: "arrow.clockwise")
                                            .font(.largeTitle)
                                        
                                        Text("restart")
                                    }
                                    .foregroundColor(orange_font)
                                )
                        })
                        
                    }
                }
            }
            
            Image("donut1")
                .scaleEffect(0.6)
                .offset(x: -120, y: -30)
            
            Image("donut9")
                .rotationEffect(.degrees(-70))
                .scaleEffect(0.7)
                .offset(x: 120, y: 250)
        } // ZStack END
    }
}

struct start_background: View {
    var body: some View{
        ZStack{
            yellow_bg
                .edgesIgnoringSafeArea(.all)
            Rectangle()
                .fill(brown_bg)
                .frame(width: 300, height: 1000)
                .rotationEffect(.degrees(10))
                .offset(x: 180)
            
        }
    }
}
