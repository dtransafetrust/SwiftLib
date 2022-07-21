//
// Copyright (c) Safetrust, Inc. - All Rights Reserved
// Unauthorized copying of this file, via any medium is strictly prohibited
// Proprietary and confidential
//

import Foundation

extension String {

    private static let EMAIL_REGEX = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
//
//    private static let PHONE_NUMBER_REGEX = "^(?:(?:\+?1\s*(?:[.-]\s*)?)?(?:\(\s*([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9])\s*\)|([2-9]1[02-9]|[2-9][02-8]1|[2-9][02-8][02-9]))\s*(?:[.-]\s*)?)?([2-9]1[02-9]|[2-9][02-9]1|[2-9][02-9]{2})\s*(?:[.-]\s*)?([0-9]{4})(?:\s*(?:#|x\.?|ext\.?|extension)\s*(\d+))?$"

    func isValidEmail() -> Bool {
        return NSPredicate(format: "SELF MATCHES %@", String.EMAIL_REGEX).evaluate(with: self)
    }

    func isValidPhoneNumber() -> Bool {
        do {
            if (self.count < 10) {
                return false
            }
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSMakeRange(0, self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }

    func normalizationPhoneNumber() -> String {
        return (self.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "(", with: "").replacingOccurrences(of: ")", with: "").replacingOccurrences(of: "-", with: ""))
    }
}

class ValidationError: Error {
    var message: String

    init(_ message: String) {
        self.message = message
    }
}

protocol ValidatorConvertible {
    func validated(_ value: String) throws -> String
}

enum ValidatorType {
    case email
    case password
    case firstname
    case lastname
    case countrycode
    case pincode
    case phonenumber
    case confirmpassword
}

enum VaildatorFactory {
    static func validatorFor(type: ValidatorType) -> ValidatorConvertible {
        switch type {
        case .email: return EmailValidator()
        case .password: return PasswordValidator()
        case .firstname: return FirstNameValidator()
        case .lastname: return LastNameValidator()
        case .countrycode: return CountryCodeValidator()
        case .pincode: return PinCodeValidator()
        case .phonenumber: return PhoneValidator()
        case .confirmpassword: return ConfirmPasswordValidator()
        }
    }
}

struct PinCodeValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value != "" else { throw ValidationError("Pin code is required!") }
        return value
    }
}

struct CountryCodeValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value != "" else { throw ValidationError("Country code is required!") }
        return value
    }
}

struct FirstNameValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value != "" else { throw ValidationError("First name is required!") }
        return value
    }
}

struct LastNameValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value != "" else { throw ValidationError("Last name is required!") }
        return value
    }
}

struct PasswordValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value != "" else { throw ValidationError("Password is required!") }
        guard value.count >= 6 else { throw ValidationError("Password must have at least 6 characters") }
        return value
    }
}

struct ConfirmPasswordValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        guard value != "" else { throw ValidationError("Confirm password is required!") }
        return value
    }
}

struct EmailValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        do {
            if try NSRegularExpression(pattern: "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$", options: .caseInsensitive).firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil {
                throw ValidationError("Invalid email Address")
            }
        } catch {
            throw ValidationError("Invalid email Address")
        }
        return value
    }
}

struct PhoneValidator: ValidatorConvertible {
    func validated(_ value: String) throws -> String {
        do {
            if (value.count < 10) {
                throw ValidationError("Enter valid phone number!")
            }
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: value, options: [], range: NSMakeRange(0, value.count))
            var result: Bool = false
            if let res = matches.first {
                result = res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == value.count
                if(value.contains("+")) {
                    return value
                } else {
                    return "+" + value
                }
            } else {
                throw ValidationError("Enter valid phone number!")
            }
        } catch {
            throw ValidationError("Enter valid phone number!")
        }
    }
}
