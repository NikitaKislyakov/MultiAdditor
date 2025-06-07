//
//  CollageView.swift
//  PhotoEditor
//
//  Created by Никита Кисляков on 04.06.2025.
//

import SwiftUI

struct CollageView: View {

    var size: CGSize
    var type: CollageType
    var isMini = false

    var dividerCount: Int { type.content.count - 1 }
    var denom: CGFloat { type.content.reduce(0) { $0 + $1.length } }

    @State var factors: [CGFloat]
    @EnvironmentObject var collageSelector: CollageSelectorViewModel

    init(size: CGSize, type: CollageType, isMini: Bool = false) {
        self.size = size
        self.type = type
        self.isMini = isMini
        _factors = State(initialValue: type.factorsArray)
    }

    func getSize(with fraction: CGFloat) -> CGSize {
        type.isRow ?
            CGSize(width: size.width, height: size.height * fraction) :
            CGSize(width: size.width * fraction, height: size.height)
    }

    var body: some View {
        Group {
            switch type {

            case .row(let array, _):
                VStack(spacing: 0) {
                    ForEach(Array(array.type.enumerated()), id: \.element) { typ in
                        let index = typ.offset
                        let num = index == 0 ? factors[0] : factors[index] - factors[index - 1]
                        let fraction = CGFloat(num) / CGFloat(denom)
                        let childSize = getSize(with: fraction)

                        CollageView(size: childSize, type: typ.element, isMini: isMini)
                    }
                }
                .frame(width: size.width, height: size.height)
                .overlay(alignment: .topLeading) {
                    ForEach(0..<(factors.count - 1), id: \.self) { index in
                        Rectangle()
                            .fill(Color.secondary.opacity(0.25))
                            .frame(height: isMini ? 1 : 4)
                            .offset(y: size.height * (factors[index] / denom))
                            .gesture(
                                DragGesture(minimumDistance: 2)
                                    .onChanged { value in
                                        let pt = value.location.y
                                        let ratioY = pt / (size.height / denom)
                                        factors[index] = min(max(0, ratioY), denom)
                                    }
                                    .onEnded { _ in
                                        collageSelector.iterateOverSelectedCollage(for: type, factorsArray: factors)
                                    }
                            )
                    }
                }

            case .column(let array, _):
                HStack(spacing: 0) {
                    ForEach(Array(array.type.enumerated()), id: \.element) { typ in
                        let index = typ.offset
                        let num = index == 0 ? factors[0] : factors[index] - factors[index - 1]
                        let fraction = CGFloat(num) / CGFloat(denom)
                        let childSize = getSize(with: fraction)

                        CollageView(size: childSize, type: typ.element, isMini: isMini)
                    }
                }
                .frame(width: size.width, height: size.height)
                .overlay(alignment: .topLeading) {
                    ForEach(0..<(factors.count - 1), id: \.self) { index in
                        Rectangle()
                            .fill(Color.secondary.opacity(0.25))
                            .frame(width: isMini ? 1 : 4)
                            .offset(x: size.width * (factors[index] / denom))
                            .gesture(
                                DragGesture(minimumDistance: 2)
                                    .onChanged { value in
                                        let pt = value.location.x
                                        let ratioX = pt / (size.width / denom)
                                        factors[index] = min(max(0, ratioX), denom)
                                    }
                                    .onEnded { _ in
                                        collageSelector.iterateOverSelectedCollage(for: type, factorsArray: factors)
                                    }
                            )
                    }
                }

            case .data(let container, _):
                ContainerView(container)
            }
        }
        .frame(width: size.width, height: size.height)
        .clipped()
    }

    @ViewBuilder
    func ContainerView(_ container: Container) -> some View {
        switch container.type {
        case .empty(let uIColor):
            VStack {
                if !isMini {
                    Button {
                        collageSelector.selectBlock(with: container.id)
                    } label: {
                        Image(systemName: "photo.on.rectangle.angled")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .tint(.white.opacity(0.3))
                            .frame(width: 32, height: 32)
                    }
                }
            }
            .frame(width: size.width, height: size.height)
            .modifier(BgModifier(color: Color(uiColor: uIColor).opacity(0.5), fill: true))

        case .image(let uIImage):
            CollageImageView(image: uIImage, size: size)
                .onTapGesture {
                    withAnimation {
                        collageSelector.selectForReplaceMent(id: container)
                    }
                }
        }
    }
}

struct CollageView_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { proxy in
            let size = proxy.size.toSquareSize
            VStack {
                Spacer()
                CollageView(
                    size: .init(width: size.width, height: size.height),
                    type: .column(.init(type: [
                        .data(.init(type: .empty(.red)), 1),
                        .data(.init(type: .empty(.blue)), 1),
                    ]), 1)
                )
                Spacer()
            }
        }.padding()
    }
}
