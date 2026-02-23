//
//  CountdownWidgetBundle.swift
//  CountdownWidget
//
//  Created by Riley Koo on 2/22/26.
//

import WidgetKit
import SwiftUI

@main
struct CountdownWidgetBundle: WidgetBundle {
    var body: some Widget {
        CountdownWidget()
        CountdownWidgetControl()
        CountdownWidgetLiveActivity()
    }
}
