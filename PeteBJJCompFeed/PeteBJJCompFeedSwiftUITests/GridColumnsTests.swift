//
//  GridColumnsTests.swift
//  PeteBJJCompFeedSwiftUITests
//
//  Created by Kobe Sam on 10/24/26.
//

import SwiftUI
import Testing
@testable import PeteBJJCompFeedSwiftUI

struct GridColumnsTests {

    @Test(arguments: [DynamicTypeSize.xSmall, .large, .xxLarge])
    func count_isTwoOnCompactWidth(dynamicTypeSize: DynamicTypeSize) {
        #expect(GridColumns.count(horizontalSizeClass: .compact, dynamicTypeSize: dynamicTypeSize) == 2)
    }

    @Test(arguments: [DynamicTypeSize.xSmall, .large, .xxLarge])
    func count_isThreeOnRegularWidth(dynamicTypeSize: DynamicTypeSize) {
        #expect(GridColumns.count(horizontalSizeClass: .regular, dynamicTypeSize: dynamicTypeSize) == 3)
    }

    @Test(arguments: [UserInterfaceSizeClass.compact, .regular], [DynamicTypeSize.xxxLarge, .accessibility1, .accessibility5])
    func count_isOneAtLargestTextSizes(horizontalSizeClass: UserInterfaceSizeClass, dynamicTypeSize: DynamicTypeSize) {
        #expect(GridColumns.count(horizontalSizeClass: horizontalSizeClass, dynamicTypeSize: dynamicTypeSize) == 1)
    }
}
