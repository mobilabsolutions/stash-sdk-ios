//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation
import UIKit

/// :nodoc:
public class FormSelectField: FormPickerField {
    public init(values: [String]) {
        self.values = values

        let pickerView = UIPickerView()
        super.init(customInputView: pickerView)

        pickerView.delegate = self
        pickerView.dataSource = self

        selectedValue = values.first
    }

    public required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private var values: [String]
}

/// :nodoc:
extension FormSelectField: UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in _: UIPickerView) -> Int {
        return 1
    }

    public func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        return self.values.count
    }

    public func pickerView(_: UIPickerView, titleForRow row: Int, forComponent _: Int) -> String? {
        return self.values[row]
    }

    public func pickerView(_: UIPickerView, didSelectRow row: Int, inComponent _: Int) {
        selectedValue = self.values[row]
    }
}
