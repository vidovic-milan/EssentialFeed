import XCTest
import EssentialFeed
@testable import EssentialFeediOS

class FeedLocalizationTests: XCTestCase {

    func test_localizedString_hasAllKeysAndValuesForLocalizedLanguages() {
        let table = "Feed"
        let bundle = Bundle(for: FeedPresenter.self)
        let localizationBundles = allLocalizationBundles(in: bundle)
        let localizedKeys = allLocalizedStringKeys(in: localizationBundles, table: table)

        localizationBundles.forEach { (bundle, locale) in
            localizedKeys.forEach { key in
                let value = bundle.localizedString(forKey: key, value: nil, table: table)
                if key == value {
                    XCTFail("Missing value for key: \(key) in table \(table) for locale: \(locale)")
                }
            }
        }
    }

    private typealias LocalizedBundle = (bundle: Bundle, localization: String)

    private func allLocalizationBundles(in bundle: Bundle, file: StaticString = #file, line: UInt = #line) -> [LocalizedBundle] {
        return bundle.localizations.compactMap { localization in
            guard
                let path = bundle.path(forResource: localization, ofType: "lproj"),
                let localizedBundle = Bundle(path: path)
            else {
                XCTFail("Couldn't find bundle for localization: \(localization)", file: file, line: line)
                return nil
            }
            
            return (localizedBundle, localization)
        }
    }

    private func allLocalizedStringKeys(in bundles: [LocalizedBundle], table: String, file: StaticString = #file, line: UInt = #line) -> Set<String> {
        return bundles.reduce([]) { (acc, current) in
            guard
                let path = current.bundle.path(forResource: table, ofType: "strings"),
                let strings = NSDictionary(contentsOfFile: path),
                let keys = strings.allKeys as? [String]
            else {
                XCTFail("Couldn't load localized strings for localization: \(current.localization)", file: file, line: line)
                return acc
            }
            
            return acc.union(Set(keys))
        }
    }
}
