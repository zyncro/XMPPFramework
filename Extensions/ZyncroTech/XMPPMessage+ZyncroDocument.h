//
//  XMPPMessage+ZyncroDocument.h
//  ZyncroMessenger
//
//  Created by Luis Valdés on 4/3/15.
//  Copyright (c) 2015 Zyncro Tech. All rights reserved.
//

#import "XMPPMessage.h"

@interface XMPPMessage (ZyncroDocument)

- (void)addDocumentId:(NSString *)documentId groupId:(NSString *)documentGroupId name:(NSString *)documentName andURL:(NSString *)documentURL;

- (NSXMLElement *)documentElement;

- (NSString *)documentId;
- (NSString *)documentGroupId;
- (NSString *)documentName;
- (NSString *)documentURL;

- (BOOL)hasDocumentId;
- (BOOL)hasDocumentGroupId;
- (BOOL)hasDocumentName;
- (BOOL)hasDocumentURL;

@end
