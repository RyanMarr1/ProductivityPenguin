//
//  ReportExtensionsSOHI.swift
//  ReportExtensionsSOHI
//
//  Created by Michael Chen on 11/4/23.
//

import DeviceActivity
import SwiftUI

@main
struct ReportExtensionsSOHI: DeviceActivityReportExtension {
    var body: some DeviceActivityReportScene {
        // Create a report for each DeviceActivityReport.Context that your app supports.
        TotalActivityReport { totalActivity in
            TotalActivityView(totalActivity: totalActivity)
        }
        // Add more reports here...
    }
}
