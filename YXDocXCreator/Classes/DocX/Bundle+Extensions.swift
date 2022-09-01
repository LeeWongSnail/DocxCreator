//
//  Bundle+Extensions.swift
//  
//
//  Created by Morten Bertz on 2021/03/23.
//

import Foundation

#if SWIFT_PACKAGE
extension Bundle{
    class var blankDocumentURL:URL?{
        return Bundle.module.url(forResource: "blank", withExtension: nil)
    }
}
#else
extension Bundle{
    class var blankDocumentURL:URL?{
        return resourceBundle?.resourceURL?.appendingPathComponent("YXDocXCreateResource")
    }
    
    class var resourceBundle: Bundle? {
        let componentName = String(describing: "YXDocXCreator")
        let bundleName = "\(componentName).bundle"
        
        
        var associateBundleURL = Bundle.main.url(forResource: "Frameworks", withExtension: nil)
        associateBundleURL = associateBundleURL?.appendingPathComponent("YXDocXCreator")
        associateBundleURL = associateBundleURL?.appendingPathExtension("framework")
        
        if let url = associateBundleURL, let associateBundle = Bundle(url: url) {
            associateBundleURL = associateBundle.url(forResource: "YXDocXCreator", withExtension: "bundle")
            if let url = associateBundleURL, let bundle = Bundle(url: url)   {
                return bundle
            }
        }
        
        return nil
    }
}

//NSURL *associateBundleURL = [[NSBundle mainBundle] URLForResource:bundleName withExtension:@"bundle"];
//NSBundle *bundle = [NSBundle bundleWithURL:associateBundleURL];
#endif
