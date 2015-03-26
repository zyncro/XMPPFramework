//
//  ZyncroSearchContacts.h
//  Pods
//
//  Created by Moral on 24/3/15.
//
//

#import "XMPPIQ.h"

@interface XMPPIQ (ZyncroContacts)

- (void)addQueryWithItemsPerPage:(NSUInteger)itemsPerPage pageNumber:(NSUInteger)pageNumber searchText:(NSString *)text;
- (BOOL)hasSearchQuery;
- (NSArray *)items;

@end
