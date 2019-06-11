// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
    func testLane() {
        desc("Runs Unit and UI tests")
        self.unitTestLane()
        self.uiTestLane()
    }

    func uiTestLane() {
        desc("Run UI tests")
        runTests(project: "MobilabPayment.xcodeproj", scheme: "SampleUITests", device: "iPhone X", prelaunchSimulator: true)
    }

    func unitTestLane() {
        desc("Run Unit tests")
        runTests(project: "MobilabPayment.xcodeproj", scheme: "MobilabPaymentTests", prelaunchSimulator: true)
    }

    func betaLane() {
        desc("Distribute to Beta")
        let changeLog = changelogFromGitCommits(mergeCommitFiltering: "exclude_merges")
        let buildSecret = environmentVariable(get: "CRASHLYTICS_BUILD_SECRET")
        let apiKey = environmentVariable(get: "CRASHLYTICS_API_KEY")
        betaSample(buildSecret: buildSecret, apiKey: apiKey, changeLog: changeLog)
        betaDemo(buildSecret: buildSecret, apiKey: apiKey, changeLog: changeLog)
    }

    private func betaSample(buildSecret: String, apiKey: String, changeLog: String) {
        incrementBuildNumber()
        buildApp(project: "MobilabPayment.xcodeproj", scheme: "Sample", clean: false,
                 includeBitcode: false, exportMethod: "ad-hoc")
        crashlytics(crashlyticsPath: "./Sample/other/Crashlytics.framework/submit",
                    apiToken: apiKey, buildSecret: buildSecret, notes: changeLog, groups: "payment-sdk-testers")
    }

    private func betaDemo(buildSecret: String, apiKey: String, changeLog: String) {
        incrementBuildNumber()
        buildApp(project: "MobilabPayment.xcodeproj", scheme: "Demo", clean: false,
                 includeBitcode: false, exportMethod: "ad-hoc")
        crashlytics(crashlyticsPath: "./Sample/other/Crashlytics.framework/submit",
                    apiToken: apiKey, buildSecret: buildSecret, notes: changeLog, groups: "payment-sdk-testers")
    }
}
