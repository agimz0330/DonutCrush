//
//  StartView.swift
//  DonutCrush
//
//  Created by User23 on 2022/4/30.
//

import SwiftUI

struct StartView: View {
    @State var str = "Welcome" // start: welcome, pause: Pause
    
    var body: some View {
        ZStack{
            Color.yellow
            
            VStack{
                Text("\(str)")
                    .font((.custom("", size: 30)))
                    .foregroundColor(Color.black)
                
                HStack{
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 200, height: 100)
                        .cornerRadius(40)
                        .overlay(
                            VStack(spacing: 10){
                                Image(systemName: "play")
                                    .font(.largeTitle)
                                Text("play")
                            }
                        )
                    
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 70, height: 100)
                        .cornerRadius(30)
                        .overlay(
                            VStack(spacing: 10){
                                Image(systemName: "arrow.clockwise")
                                    .font(.largeTitle)
                                
                                Text("restart")
                            }
                        )
                }
            }
        } // ZStack END
    }
}

struct StartView_Previews: PreviewProvider {
    static var previews: some View {
        StartView()
    }
}
