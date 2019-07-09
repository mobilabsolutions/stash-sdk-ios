// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
    private var isCI: Bool {
        return Bool(environmentVariable(get: "CI")) ?? false
    }

    private let keychainName = "ci-build-keychain"
    private var random = SystemRandomNumberGenerator()
    private let adhocAppIdentifiers = [("com.mobilabsolutions.payment.*", "Payment Sample and Demo Ad-Hoc")]

    func beforeAll() {
        if self.isCI {
            puts(message: "Running on CI: Will behave differently.")
        } else {
            puts(message: "Running locally")
        }
    }

    func testLane() {
        desc("Runs Unit and UI tests")
        self.unitTestLane()
        self.uiTestLane()
    }

    func uiTestLane() {
        desc("Run UI tests")
        runTests(workspace: "MobilabPayment.xcworkspace", scheme: "SampleUITests", device: "iPhone X", prelaunchSimulator: true)
    }

    func unitTestLane() {
        desc("Run Unit tests")
        runTests(workspace: "MobilabPayment.xcworkspace", scheme: "MobilabPaymentTests", prelaunchSimulator: true)
    }

    func betaLane() {
        desc("Distribute to Beta")
        let changeLog: String
        let buildSecret = environmentVariable(get: "CRASHLYTICS_BUILD_SECRET")
        let apiKey = environmentVariable(get: "CRASHLYTICS_API_KEY")

        if self.isCI {
            changeLog = changelogFromGitCommits(between: self.ciCommitRangeInCommaNotation(),
                                                mergeCommitFiltering: "exclude_merges")
            incrementBuildNumber(buildNumber: environmentVariable(get: "TRAVIS_BUILD_NUMBER"))
        } else {
            changeLog = changelogFromGitCommits(mergeCommitFiltering: "exclude_merges")
            incrementBuildNumber()
        }

        self.prepareForDistribution()

        self.betaSample(buildSecret: buildSecret, apiKey: apiKey, changeLog: changeLog)
        self.betaDemo(buildSecret: buildSecret, apiKey: apiKey, changeLog: changeLog)

        self.tearDownFromDistribution()
    }

    private func betaSample(buildSecret: String, apiKey: String, changeLog: String) {
        buildApp(workspace: "MobilabPayment.xcworkspace", scheme: "Sample", clean: false,
                 includeBitcode: false, exportMethod: "ad-hoc")
        crashlytics(crashlyticsPath: "./Sample/other/Crashlytics.framework/submit",
                    apiToken: apiKey, buildSecret: buildSecret, notes: changeLog, emails: environmentVariable(get: "CRASHLYTICS_TESTERS"), notifications: false)
    }

    private func betaDemo(buildSecret: String, apiKey: String, changeLog: String) {
        buildApp(workspace: "MobilabPayment.xcworkspace", scheme: "MobilabPaymentDemo", clean: false,
                 includeBitcode: false, exportMethod: "ad-hoc")
        crashlytics(crashlyticsPath: "./MobilabPaymentDemo/other/Crashlytics.framework/submit",
                    apiToken: apiKey, buildSecret: buildSecret, notes: changeLog, emails: environmentVariable(get: "CRASHLYTICS_TESTERS"),
                    notifications: false)
    }

    private func prepareForDistribution() {
        guard self.isCI, let password = String(random.next()).data(using: .utf8)?.base64EncodedString()
        else { return }

        createKeychain(name: self.keychainName, password: password, defaultKeychain: true, unlock: true, timeout: 3600, lockWhenSleeps: true)

        importCertificate(certificatePath: "fastlane/Certificates/distribution.p12",
                          certificatePassword: environmentVariable(get: "CERTIFICATE_KEY"),
                          keychainName: self.keychainName,
                          keychainPassword: password,
                          logOutput: true)

        for (appIdentifier, provisioningName) in self.adhocAppIdentifiers {
            sigh(adhoc: true,
                 appIdentifier: appIdentifier,
                 username: environmentVariable(get: "FASTLANE_USER"),
                 teamId: environmentVariable(get: "TEAM_ID"),
                 provisioningName: provisioningName,
                 ignoreProfilesWithDifferentName: true,
                 certId: environmentVariable(get: "CERTIFICATE_ID"))
        }
    }

    private func tearDownFromDistribution() {
        guard isCI
        else { return }

        deleteKeychain(name: self.keychainName)
    }

    private func ciCommitRangeInCommaNotation() -> String {
        // It is unclear whether Travis will continue formatting the commit range
        // in triple dot notation or start using double dot: https://github.com/travis-ci/travis-ci/issues/4596
        return environmentVariable(get: "TRAVIS_COMMIT_RANGE")
            .replacingOccurrences(of: "...", with: ",")
            .replacingOccurrences(of: "..", with: ",")
    }
}
