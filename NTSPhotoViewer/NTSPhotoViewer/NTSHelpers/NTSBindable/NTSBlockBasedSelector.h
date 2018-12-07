//
//  NTSBlockBasedSelector.h
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NTSBlockBasedSelector : NSObject

@end

typedef void (^OBJCBlock)(id selector);

void class_addMethodWithBlock(Class class, SEL newSelector, OBJCBlock block);
