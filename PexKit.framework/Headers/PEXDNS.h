//
//  PEXDNS.h
//  pexapp
//
//  Created by Hani Mustafa on 6/23/13.
//  Copyright (c) 2013 pexip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PEXDns : NSObject

+ (void) resolveURI:(NSString* _Nonnull)uri completionBlock:(void (^_Nonnull)(NSString* _Nonnull serviceID))block;

@end