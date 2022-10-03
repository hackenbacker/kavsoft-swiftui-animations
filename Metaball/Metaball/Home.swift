//
//  Home.swift
//  Metaball
//
//  Created by Hackenbacker on 2022/10/01.
//

import SwiftUI

/// デモの選択肢
enum MetaballOption: String, CaseIterable, Identifiable {
    case single  = "Single"  // Metaballをドラッグして楽しみます
    case clubbed = "Clubbed" // Metaballがウニョウニョ動くのを見て楽しみます

    var id: String { rawValue }
}

/// ホーム画面
struct Home: View {
    // Animation Properties
    @State var dragOffset: CGSize = .zero
    @State var startAnimation: Bool = true
    @State var selected: MetaballOption = .single
    
    var body: some View {
        VStack {
            Text("Metaball Animation")
                .font(.title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(15)

            Picker("", selection: $selected) {
                ForEach(MetaballOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 15)

            switch selected {
            case .single:
                SingleMetaBall()
            case .clubbed:
                ClubbedView()
            }
        }
    }
    
    /// Metaballがウニョウニョ動くのを見て楽しみます
    /// - Returns: 複数のボールが融合するView
    func ClubbedView() -> some View {
        let numberOfBalls = 15 // Ballの数を指定する
        let ballIndexes = 1...numberOfBalls
        // Tips: animationCycleの方が大きいと間欠運動になる。ballMovingTimeの方が大きいと連続運動になる。
        let animationCycle = 2.0 // アニメーションの周期 (秒) how long the animation needs to be changed
        let ballMovingTime = 1.9 // Ballが移動する時間 (秒)

        return Rectangle()
            .fill(theGradient)
            .mask({
                TimelineView(.animation(minimumInterval: animationCycle, paused: false)) { _ in
                    Canvas { context, size in
                        // Adding Filters
                        context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                        // This blur Radius determines the amount of elasticity between two elements
                        context.addFilter(.blur(radius: 30))

                        // Draw Layer
                        context.drawLayer { layerContext in
                            // Placing Symbols
                            for index in ballIndexes {
                                if let resolvedView = context.resolveSymbol(id: index) {
                                    layerContext.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                                }
                            }
                        }
                    } symbols: {
                        ForEach(ballIndexes, id: \.self) { index in
                            // Generating Custom Offset For Each Time
                            // Thus It will be at random place and clubbed with each other
                            let offset   = startAnimation
                                ? CGSize(width: .random(in: -180...180), height: .random(in: -240...240)) // Ballが動き回る範囲
                                : .zero
                            let diameter = startAnimation ? CGFloat.random(in: 120...160) : 140 // Ballの直径
                            Ball(offset: offset, diameter: diameter)
                                .tag(index)
                                .animation(.easeOut(duration: ballMovingTime), value: offset)
                        }
                    }
                }
            })
            .contentShape(Rectangle())
            .onTapGesture {
                // Tapしたら中央に集まって停止する
                startAnimation.toggle()
            }
    }

    /// Metaballをドラッグして楽しみます
    /// - Returns: ボールが2つのView
    func SingleMetaBall() -> some View {
        let centerBallIndex  = 0
        let draggedBallIndex = 1

        return Rectangle()
            .fill(theGradient)
            .mask {
                Canvas { context, size in
                    // Adding Filters
                    context.addFilter(.alphaThreshold(min: 0.5, color: .white))
                    // This blur Radius determines the amount of elasticity between two elements
                    context.addFilter(.blur(radius: 35))

                    // Draw Layer
                    context.drawLayer { layerContext in
                        // Placing Symbols
                        for index in [centerBallIndex, draggedBallIndex] {
                            if let resolvedView = context.resolveSymbol(id: index) {
                                layerContext.draw(resolvedView, at: CGPoint(x: size.width / 2, y: size.height / 2))
                            }
                        }
                    }
                } symbols: {
                    Ball()
                        .tag(centerBallIndex)
                    Ball(offset: dragOffset)
                        .tag(draggedBallIndex)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation
                    }
                    .onEnded { _ in
                        withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.7)) {
                            dragOffset = .zero
                        }
                    }
            )
    }

    /// ボール１個を生成する
    /// - Parameters:
    ///   - offset: ボール中心からのオフセット
    ///   - diameter: ボールの直径
    /// - Returns: 生成したボール
    func Ball(offset: CGSize = .zero, diameter: CGFloat = 150) -> some View {
        Circle()
            .fill(.white)
            .frame(width: diameter, height: diameter)
            .offset(offset)
    }

    private var theGradient: LinearGradient {
        .linearGradient(colors: [Color("Gradient1"), Color("Gradient2")],
                        startPoint: .top,
                        endPoint: .bottom)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        Home()
            .preferredColorScheme(.dark)
    }
}
