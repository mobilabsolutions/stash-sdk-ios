//
//  Result.swift
//  ProtocolBasedNetworkingTutorialFinal
//
//  Created by James Rochabrun on 11/27/17.
//  Copyright © 2017 James Rochabrun. All rights reserved.
//

import Foundation

enum MLResult<T, U> where U: Error  {
    case success(T)
    case failure(U)
}
