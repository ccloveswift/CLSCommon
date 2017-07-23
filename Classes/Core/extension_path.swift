//
//  extension_url.swift
//  Booom
//
//  Created by TT on 2017/1/8.
//  Copyright © 2017年 TT. All rights reserved.
//

import Foundation

extension URL {
    

    public static func e_gotDocumentsURL() -> URL {
        
        let str = String.e_gotDocuments()
        
        return URL.init(string: str)!
    }
    

    public static func e_gotLibraryURL() -> URL {
        
        let str = String.e_gotLibrary()
        
        return URL.init(string: str)!
    }
}

extension String {
    
    public static func e_gotDocuments() -> String {
        
        let documentsPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory,
                                                                 .userDomainMask, true)
        let documentsPath = documentsPaths[0]
        
        return documentsPath
    }
    
    public static func e_gotLibrary() -> String {
        
        let libraryPaths = NSSearchPathForDirectoriesInDomains(.libraryDirectory,
                                                               .userDomainMask, true)
        let libraryPath = libraryPaths[0]
        
        return libraryPath
    }
}
