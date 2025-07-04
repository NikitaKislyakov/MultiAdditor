//
//  CollageType.swift
//  PhotoEditor
//
//  Created by Никита Кисляков on 04.06.2025.
//


import UIKit

enum CollageRatios: CaseIterable {
    case oneone
    case oneTwo
    case oneThree
    case twoThree
    case threeFive
    case fiveSeven
    case twooOne
    case threeOne
    case fiveThree
    case sevenFive
    
    var value: CGFloat {
        switch self {
            case .oneone: return 1
            case .oneTwo: return 1/2
            case .oneThree: return 1/3
            case .twoThree: return 2/3
            case .threeFive: return 3/5
            case .fiveSeven: return 5/7
            case .twooOne: return 2/1
            case .threeOne: return 3/1
            case .fiveThree: return 5/3
            case .sevenFive: return 7/5
        }
    }
    
    var label: String {
        switch self {
            case .oneone: return "1 X 1"
            case .oneTwo: return "1 X 2"
            case .oneThree: return "1 X 3"
            case .twoThree: return "2 X 3"
            case .threeFive: return "3 X 5"
            case .fiveSeven: return "5 X 7"
            case .twooOne: return "2 X 1"
            case .threeOne: return "3 X 1"
            case .fiveThree: return "5 X 3"
            case .sevenFive: return "7 X 5"
        }
    }
    
}

enum ContainerType: Hashable, Identifiable {
    
    var id: Self { self }
    
    case empty(UIColor)
    case image(UIImage)
    
    var color: UIColor? {
        switch self {
        case .empty(let uIColor): return uIColor
        default: return nil
        }
    }
}

struct Container: Identifiable, Hashable {
    var type: ContainerType
    var id = UUID.init().uuidString
}

struct ViewContainer: Identifiable, Hashable {
    var type: [CollageType]
    var id = UUID.init().uuidString
}

enum CollageType: Hashable, Identifiable {
    
    var id: Self { self }
    
    case row(ViewContainer, CGFloat)
    case column(ViewContainer, CGFloat)
    case data(Container, CGFloat)
    
    enum Base: String {
        case row, column, data
    }
    
}

extension CollageType {
    
    var length: CGFloat {
        switch self {
        case .row(_, let i):
            return i;
        case .column(_, let i):
            return i;
        case .data(_, let i):
            return i;
        }
    }
    
    var content: [CollageType] {
        switch self {
        case .row(let array, _):
            return array.type
        case .column(let array, _):
            return array.type
        case .data(_, _):
            return []
        }
    }
    
    var isRow: Bool {
        switch self {
        case .row(_, _):
            return true;
        default:
            return false;
        }
    }
    
    var isData: Bool {
        switch self {
        case .data(_, _):
            return true;
        default:
            return false;
        }
    }
    
    var factorsArray: [CGFloat] {
        let mapped = self.content.map { $0.length }
        let resut: [CGFloat] = mapped.enumerated().map { (offset, element) in
            let result = (0...offset).reduce(0) { partialResult, index in partialResult + mapped[index] }
            return result
        }
        return resut
    }
 
    var stringy: String {
        switch self {
        case .row(_, _): return "Row"
        case .column(_, _): return "Column"
        case .data(_, _): return "Data"
        }
    }
    
    
    func getColorForContainer(_ id: String) -> UIColor? {
        switch self {
            
        case .row(let array, _):
            return array.type.compactMap { $0.getColorForContainer(id) }.first
            
        case .column(let array, _):
            return array.type.compactMap { $0.getColorForContainer(id) }.first
            
        case .data(let container, _):
            if container.id == id {
                return container.type.color
            } else { return nil }
            
        }
    }
    
}


extension CollageType {
    
    static let collages: [CollageType] = [
    
        .column(.init(type: [
            .data(.init(type: .empty(.systemRed)), 1),
            .data(.init(type: .empty(.systemIndigo)), 1),
        ]), 1),
        
        .row(.init(type: [
            .data(.init(type: .empty(.systemPink)), 1),
            .data(.init(type: .empty(.systemTeal)), 1),
        ]), 1),
        
        .row(.init(type: [
            .data(.init(type: .empty(.systemRed)), 1),
            .data(.init(type: .empty(.systemBlue)), 1),
            .data(.init(type: .empty(.systemGray)), 1)
        ]), 1),

        .row(.init(type: [
            .column(.init(type: [ .data(.init(type: .empty(.systemOrange)), 1), .data(.init(type: .empty(.systemGray2)), 1) ]), 1),
            .data(.init(type: .empty(.systemBrown)), 1)
        ]), 1),
        
        .row(.init(type: [
            .data(.init(type: .empty(.systemYellow)), 1),
            .column(.init(type: [ .data(.init(type: .empty(.systemRed)), 1), .data(.init(type: .empty(.systemBrown)), 1) ]), 1),
        ]), 1),
        
        .column(.init(type: [
            .row(.init(type: [ .data(.init(type: .empty(.systemOrange)), 1), .data(.init(type: .empty(.systemGray2)), 1) ]), 1),
            .data(.init(type: .empty(.systemBrown)), 1)
        ]), 1),
        
        .column(.init(type: [
            .data(.init(type: .empty(.systemPink)), 1),
            .row(.init(type: [ .data(.init(type: .empty(.systemRed)), 1), .data(.init(type: .empty(.systemIndigo)), 1) ]), 1),
        ]), 1),
        
        .column(.init(type: [
            .row(.init(type: [ .data(.init(type: .empty(.systemPink)), 2), .data(.init(type: .empty(.systemPurple)), 1) ]), 1),
            .row(.init(type: [ .data(.init(type: .empty(.systemRed)), 1), .data(.init(type: .empty(.systemIndigo)), 2) ]), 1),
        ]), 1),
        
        .column(.init(type: [
            .data(.init(type: .empty(.systemIndigo)), 1),
            .data(.init(type: .empty(.systemPink)), 1),
            .data(.init(type: .empty(.systemTeal)), 1)
        ]), 1),

        .row(.init(type: [
            .column(.init(type: [ .data(.init(type: .empty(.systemPink)), 1), .data(.init(type: .empty(.systemPurple)), 2) ]), 1),
            .column(.init(type: [ .data(.init(type: .empty(.systemRed)), 2), .data(.init(type: .empty(.systemIndigo)), 1) ]), 1),
        ]), 1),
        
            .row(.init(type: [
                .column(.init(type: [
                    .row(.init(type: [
                        .column(.init(type: [
                            .data(.init(type: .empty(.systemRed)), 1),
                            .data(.init(type: .empty(.systemCyan)), 1)
                        ]), 1),
                        .data(.init(type: .empty(.green)), 1)
                    ]), 1),
                    .data(.init(type: .empty(.magenta)), 1),
                    .row(.init(type: [
                        .column(.init(type: [
                            .data(.init(type: .empty(.systemOrange)), 1),
                            .data(.init(type: .empty(.systemTeal)), 1)
                        ]), 1),
                        .data(.init(type: .empty(.systemBlue)), 1)
                    ]), 1),
                ]), 1),
                .data(.init(type: .empty(.systemMint)), 1),
            ]), 1),

        .row(.init(type: [
            .column(.init(type: [
                .data(.init(type: .empty(.systemRed)), 1),
                .row(.init(type: [
                    .data(.init(type: .empty(.systemBlue)), 1),
                    .data(.init(type: .empty(.systemIndigo)), 1)
                ]), 1),
                .data(.init(type: .empty(.systemMint)), 1),
            ]), 1),
            .column(.init(type: [
                .data(.init(type: .empty(.systemPink)), 1),
                .data(.init(type: .empty(.systemGray)), 1),
            ]), 1),
            .column(.init(type: [
                .data(.init(type: .empty(.systemYellow)), 1),
                .row(.init(type: [
                    .data(.init(type: .empty(.systemGreen)), 1),
                    .data(.init(type: .empty(.brown)), 1)
                ]), 1),
                .data(.init(type: .empty(.systemTeal)), 1),
            ]), 1),

        ]), 1),

    ]
    
}
