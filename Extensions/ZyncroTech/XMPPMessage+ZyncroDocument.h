//
//  XMPPMessage+ZyncroDocument.h
//  ZyncroMessenger
//
//  Created by Luis Valdés on 4/3/15.
//  Copyright (c) 2015 Zyncro Tech. All rights reserved.
//

#import <XMPPFramework/XMPPMessage.h>

@interface XMPPMessage (ZyncroDocument)

- (void)addDocumentId:(NSString *)documentId;

- (NSString *)documentId;

- (BOOL)hasDocumentId;

@end
