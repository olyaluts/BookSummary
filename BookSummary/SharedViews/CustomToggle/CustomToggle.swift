//
//  CustomToggle.swift
//  BookSummary
//
//  Created by Olya Lutsyk on 15.09.2024.
//

import Foundation
import SwiftUI

struct CustomToggle: View {
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(isOn ? .blue : .clear)
                    .frame(width: 40, height: 40)
                
                Image(systemName: "headphones")
                    .foregroundColor(isOn ? .white : .gray)
                    .font(.system(size: 20, weight: .bold))
            }
            .padding(.leading, 8)
            
            Spacer()
            
            ZStack {
                Circle()
                    .fill(!isOn ? .blue : .clear)
                    .frame(width: 40, height: 40)
                
                Image(systemName: "list.bullet")
                    .foregroundColor(!isOn ? .white : .gray)
                    .font(.system(size: 20, weight: .bold))
            }
            .padding(.trailing, 8)
        }
        .frame(width: 100, height: 50)
        .background(.white)
        .cornerRadius(25)
        .shadow(color: .gray.opacity(0.3), radius: 3, x: 0, y: 2)
        .onTapGesture {
            isOn.toggle()
        }
        .animation(.easeInOut, 
                   value: isOn)
    }
}
