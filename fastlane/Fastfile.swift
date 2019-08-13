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
        runTests(project: "Stash.xcodeproj", scheme: "StashSampleUITests", device: "iPhone X", prelaunchSimulator: true)
    }

    func unitTestLane() {
        desc("Run Unit tests")
        runTests(project: "Stash.xcodeproj", scheme: "StashTests", prelaunchSimulator: true)
    }

    func betaLane() {
        desc("Distribute to Beta")
        let changeLog: String
        let buildSecret = environmentVariable(get: "CRASHLYTICS_BUILD_SECRET")
        let apiKey = environmentVariable(get: "CRASHLYTICS_API_KEY")

        if self.isCI {
            changeLog = changelogFromGitCommits(between: self.ciCommitRangeInCommaNotation(),
                                                mergeCommitFiltering: "exclude_merges")
            incrementBuildNumber(buildNumber: environmentVariable(get: "TRAVIS_BUILD_NUMBER"), xcodeproj: "Stash.xcodeproj")
            incrementBuildNumber(buildNumber: environmentVariable(get: "TRAVIS_BUILD_NUMBER"), xcodeproj: "StashDemo/StashDemo.xcodeproj")
        } else {
            changeLog = changelogFromGitCommits(mergeCommitFiltering: "exclude_merges")
            incrementBuildNumber(xcodeproj: "Stash.xcodeproj")
            incrementBuildNumber(xcodeproj: "StashDemo/StashDemo.xcodeproj")
        }

        self.prepareForDistribution()

        self.betaSample(buildSecret: buildSecret, apiKey: apiKey, changeLog: changeLog)
        self.betaDemo(buildSecret: buildSecret, apiKey: apiKey, changeLog: changeLog)

        self.tearDownFromDistribution()
    }

    private func betaSample(buildSecret: String, apiKey: String, changeLog: String) {
        buildApp(project: "Stash.xcodeproj", scheme: "StashSample", clean: false,
                 includeBitcode: false, exportMethod: "ad-hoc")
        crashlytics(crashlyticsPath: "./Sample/other/Crashlytics.framework/submit",
                    apiToken: apiKey, buildSecret: buildSecret, notes: changeLog, emails: environmentVariable(get: "CRASHLYTICS_TESTERS"), notifications: false)
    }

    private func betaDemo(buildSecret: String, apiKey: String, changeLog: String) {
        buildApp(project: "StashDemo/StashDemo.xcodeproj", scheme: "StashDemo", clean: false,
                 includeBitcode: false, exportMethod: "ad-hoc")
        crashlytics(crashlyticsPath: "./StashDemo/other/Crashlytics.framework/submit",
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
        guard self.isCI
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

    // Currently, Fastlane.sigh is broken for the configuration we use. Therefore we use the below version
    private func sigh(adhoc: Bool = false,
              developerId: Bool = false,
              development: Bool = false,
              skipInstall: Bool = false,
              force: Bool = false,
              appIdentifier: String,
              username: String,
              teamId: String? = nil,
              teamName: String? = nil,
              provisioningName: String? = nil,
              ignoreProfilesWithDifferentName: Bool = false,
              outputPath: String = ".",
              certId: String? = nil,
              certOwnerName: String? = nil,
              filename: String? = nil,
              skipFetchProfiles: Bool = false,
              skipCertificateVerification: Bool = false,
              platform: String = "ios",
              readonly: Bool = false,
              templateName: String? = nil) {
        var arguments: [RubyCommand.Argument] = [
            RubyCommand.Argument(name: "app_identifier", value: appIdentifier),
            RubyCommand.Argument(name: "username", value: username),
            RubyCommand.Argument(name: "output_path", value: outputPath),
            RubyCommand.Argument(name: "platform", value: platform),
        ]

        if adhoc {
            arguments.append(RubyCommand.Argument(name: "adhoc", value: adhoc))
        }

        if developerId {
            arguments.append(RubyCommand.Argument(name: "developer_id", value: developerId))
        }

        if development {
            arguments.append(RubyCommand.Argument(name: "development", value: development))
        }

        if skipInstall {
            arguments.append(RubyCommand.Argument(name: "skip_install", value: skipInstall))
        }

        if force {
            arguments.append(RubyCommand.Argument(name: "force", value: force))
        }

        if let teamName = teamName {
            arguments.append(RubyCommand.Argument(name: "team_name", value: teamName))
        }

        if let teamId = teamId {
            arguments.append(RubyCommand.Argument(name: "team_id", value: teamId))
        }

        if let provisioningName = provisioningName {
            arguments.append(RubyCommand.Argument(name: "provisioning_name", value: provisioningName))
        }

        if ignoreProfilesWithDifferentName {
            arguments.append(RubyCommand.Argument(name: "ignore_profiles_with_different_name", value: ignoreProfilesWithDifferentName))
        }

        if let certId = certId {
            arguments.append(RubyCommand.Argument(name: "cert_id", value: certId))
        }

        if let certOwnerName = certOwnerName {
            arguments.append(RubyCommand.Argument(name: "cert_owner_name", value: certOwnerName))
        }

        if let filename = filename {
            arguments.append(RubyCommand.Argument(name: "filename", value: filename))
        }

        if skipFetchProfiles {
            arguments.append(RubyCommand.Argument(name: "skip_fetch_profiles", value: skipFetchProfiles))
        }

        if skipCertificateVerification {
            arguments.append(RubyCommand.Argument(name: "skip_certificate_verification", value: skipCertificateVerification))
        }

        if readonly {
            arguments.append(RubyCommand.Argument(name: "readonly", value: readonly))
        }

        if let templateName = templateName {
            arguments.append(RubyCommand.Argument(name: "template_name", value: templateName))
        }

        let command = RubyCommand(commandID: "", methodName: "sigh", className: nil, args: arguments)
        _ = runner.executeCommand(command)
    }
}
