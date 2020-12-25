//
//  YCModelLayer.h
//  YCML
//
//  Created by Ioannis (Yannis) Chatzikonstantinou on 11/10/15.
//  Copyright © 2015 Ioannis (Yannis) Chatzikonstantinou. All rights reserved.
//
// This file is part of YCML.
//
// YCML is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// YCML is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with YCML.  If not, see <http://www.gnu.org/licenses/>.

@import Foundation;

/**
 An abstract class implementing the infrastructure for building a predictive 
 model connectivity layer.
 */
@interface YCModelLayer : NSObject

+ (instancetype)layer;

/**
 Returns the receiver's input size.
 */
@property (readonly) int inputSize;

/**
 Returns the receiver's output size.
 */
@property (readonly) int outputSize;

/**
 Holds layer properties.
 */
@property NSMutableDictionary *properties;

@end
