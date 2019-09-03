Pod::Spec.new do |spec|
  spec.name         = "Stash"
  spec.version      = "1.0"
  spec.summary      = "Stash iOS SDK Components"

  spec.description  = <<-DESC
  The Stash iOS SDK allows interfacing with multiple payment service providers in a unified fashion.
                   DESC

  spec.homepage     = "https://mobilabsolutions.com/payment-solution/"
  spec.license      = { :type => "TODO", :file => "LICENSE" }

  spec.author             = { "MobiLab Solutions GmbH" => "contact@mobilabsolutions.com" }
  spec.platform     = :ios, "11.3"
  spec.source       = { :git => "https://github.com/mobilabsolutions/payment-sdk-ios-open.git", :tag => "#{s.version}" }
  spec.swift_versions = "5.0"
  spec.requires_arc = true

  spec.dependency "StashCore", "~> 1.0"

  spec.subspec "Adyen" do |spec| 
    spec.dependency "Adyen", "~> 2.8"
    spec.source_files  = "StashAdyen/**/*.swift"
  end

  spec.subspec "Braintree" do |spec| 
    spec.dependency "Braintree/DataCollector"
    spec.dependency "BraintreeDropIn", "~> 7.3"
    spec.source_files  = "StashBraintree/**/*.swift"
  end

  spec.subspec "BSPayone" do |spec| 
    spec.source_files  = "StashBSPayone/**/*.swift", "Core/Extensions/Foundation/URL+Extras.swift"
  end

end
