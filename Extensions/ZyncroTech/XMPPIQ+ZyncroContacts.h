//
//  ZyncroSearchContacts.h
//  Pods
//
//  Created by Moral on 24/3/15.
//
//

#import "XMPPIQ.h"

@interface XMPPIQ (ZyncroContacts)

- (void)addQueryWithItemsPerPage:(NSString *)itemsPerPage pageNumber:(NSString *)pageNumber;

@end
