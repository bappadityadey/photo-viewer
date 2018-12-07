//
//  NTSBlockBasedSelector.m
//  NTSPhotoViewer
//
//  Created by Bappaditya Dey on 24/11/18.
//  Copyright © 2018 Bappaditya Dey. All rights reserved.
//

#import "NTSBlockBasedSelector.h"
#import <objc/runtime.h>

@implementation NTSBlockBasedSelector
@end

void class_addMethodWithBlock(Class class, SEL newSelector, OBJCBlock block) {
    IMP newImplementation = imp_implementationWithBlock(block);
    Method method = class_getInstanceMethod(class, newSelector);
    class_addMethod(class, newSelector, newImplementation,  method_getTypeEncoding(method));
}
