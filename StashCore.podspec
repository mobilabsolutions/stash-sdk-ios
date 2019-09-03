Pod::Spec.new do |spec|
  spec.name         = "StashCore"
  spec.version      = "1.0"
  spec.summary      = "Stash iOS Core SDK"

  spec.description  = <<-DESC
              The Stash iOS SDK allows interfacing with multiple payment service providers in a unified fashion.
                   DESC

  spec.homepage     = "https://mobilabsolutions.com/payment-solution/"

  spec.license      = { :type => "TODO", :file => "LICENSE" }
  spec.author       = { "MobiLab Solutions GmbH" => "contact@mobilabsolutions.com" }
  spec.platform     = :ios, "11.3"
  spec.source       = { :git => "https://github.com/mobilabsolutions/payment-sdk-ios-open.git", :tag => "#{s.version}" }
  spec.swift_versions = "5.0"
  spec.source_files  = "Core/**/*.{swift, h}"
  spec.resource_bundles = { "StashCore" => ["Core/PaymentSDK/Internal/UI/Resources/**/*.xcassets", "Core/PaymentSDK/Internal/UI/Resources/**/*.ttf"] }
  spec.framework  = "UIKit"
  spec.module_name = "StashCore"
  spec.requires_arc = true
end
