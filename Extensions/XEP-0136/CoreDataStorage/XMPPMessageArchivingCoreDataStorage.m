#import "XMPPMessageArchivingCoreDataStorage.h"
#import "XMPPCoreDataStorageProtected.h"
#import "XMPPLogging.h"
#import "NSXMLElement+XEP_0203.h"
#import "XMPPMessage+XEP_0085.h"
#import "XMPPMessage+XEP0045.h"
#import "XMPPMessage+ZyncroDocument.h" // Add <document id="xxx" groupId="zzz" /> element to XMPPMessage
#import "XMPPMessage+ZyncroRoom.h"     // Add <roommessage id="xxx"></roomMessageId> element to XMPPMessage
#import "XMPPMessage+ZyncroRoomNotification.h"

#if ! __has_feature(objc_arc)
#warning This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

// Log levels: off, error, warn, info, verbose
// Log flags: trace
#if DEBUG
  static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN; // VERBOSE; // | XMPP_LOG_FLAG_TRACE;
#else
  static const int xmppLogLevel = XMPP_LOG_LEVEL_WARN;
#endif

@interface XMPPMessageArchivingCoreDataStorage ()
{
	NSString *messageEntityName;
	NSString *contactEntityName;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation XMPPMessageArchivingCoreDataStorage

static XMPPMessageArchivingCoreDataStorage *sharedInstance;

+ (instancetype)sharedInstance
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		
		sharedInstance = [[XMPPMessageArchivingCoreDataStorage alloc] initWithDatabaseFilename:nil storeOptions:nil];
	});
	
	return sharedInstance;
}

/**
 * Documentation from the superclass (XMPPCoreDataStorage):
 * 
 * If your subclass needs to do anything for init, it can do so easily by overriding this method.
 * All public init methods will invoke this method at the end of their implementation.
 * 
 * Important: If overriden you must invoke [super commonInit] at some point.
**/
- (void)commonInit
{
	[super commonInit];
	
	messageEntityName = @"XMPPMessageArchiving_Message_CoreDataObject";
	contactEntityName = @"XMPPMessageArchiving_Contact_CoreDataObject";
}

/**
 * Documentation from the superclass (XMPPCoreDataStorage):
 * 
 * Override me, if needed, to provide customized behavior.
 * For example, you may want to perform cleanup of any non-persistent data before you start using the database.
 * 
 * The default implementation does nothing.
**/
- (void)didCreateManagedObjectContext
{
	// If there are any "composing" messages in the database, delete them (as they are temporary).
	
	NSManagedObjectContext *moc = [self managedObjectContext];
	NSEntityDescription *messageEntity = [self messageEntity:moc];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"composing == YES"];
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = messageEntity;
	fetchRequest.predicate = predicate;
	fetchRequest.fetchBatchSize = saveThreshold;
	
	NSError *error = nil;
	NSArray *messages = [moc executeFetchRequest:fetchRequest error:&error];
	
	if (messages == nil)
	{
		XMPPLogError(@"%@: %@ - Error executing fetchRequest: %@", [self class], THIS_METHOD, error);
		return;
	}
	
	NSUInteger count = 0;
	
	for (XMPPMessageArchiving_Message_CoreDataObject *message in messages)
	{
		[moc deleteObject:message];
		
		if (++count > saveThreshold)
		{
			if (![moc save:&error])
			{
				XMPPLogWarn(@"%@: Error saving - %@ %@", [self class], error, [error userInfo]);
				[moc rollback];
			}
		}
	}
	
	if (count > 0)
	{
		if (![moc save:&error])
		{
			XMPPLogWarn(@"%@: Error saving - %@ %@", [self class], error, [error userInfo]);
			[moc rollback];
		}
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Internal API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)willInsertMessage:(XMPPMessageArchiving_Message_CoreDataObject *)message
{
	// Override hook
}

- (void)didUpdateMessage:(XMPPMessageArchiving_Message_CoreDataObject *)message
{
	// Override hook
}

- (void)willDeleteMessage:(XMPPMessageArchiving_Message_CoreDataObject *)message
{
	// Override hook
}

- (void)willInsertContact:(XMPPMessageArchiving_Contact_CoreDataObject *)contact
{
	// Override hook
}

- (void)didUpdateContact:(XMPPMessageArchiving_Contact_CoreDataObject *)contact
{
	// Override hook
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Private API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (XMPPMessageArchiving_Message_CoreDataObject *)composingMessageWithJid:(XMPPJID *)messageJid
                                                               streamJid:(XMPPJID *)streamJid
                                                                outgoing:(BOOL)isOutgoing
                                                    managedObjectContext:(NSManagedObjectContext *)moc
{
	XMPPMessageArchiving_Message_CoreDataObject *result = nil;
	
	NSEntityDescription *messageEntity = [self messageEntity:moc];
	
	// Order matters:
	// 1. composing - most likely not many with it set to YES in database
	// 2. bareJidStr - splits database by number of conversations
	// 3. outgoing - splits database in half
	// 4. streamBareJidStr - might not limit database at all
	
	NSString *predicateFrmt = @"composing == YES AND bareJidStr == %@ AND outgoing == %@ AND streamBareJidStr == %@";
	NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateFrmt,
	                             [messageJid bare],  @(isOutgoing), [streamJid bare]];
// BEGIN ZYNCRO
	NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"localTimestamp" ascending:NO];
// END ZYNCRO
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	fetchRequest.entity = messageEntity;
	fetchRequest.predicate = predicate;
	fetchRequest.sortDescriptors = @[sortDescriptor];
	fetchRequest.fetchLimit = 1;
	
	NSError *error = nil;
	NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
	
	if (results == nil || error)
	{
		XMPPLogError(@"%@: %@ - Error executing fetchRequest: %@", THIS_FILE, THIS_METHOD, fetchRequest);
	}
	else
	{
		result = (XMPPMessageArchiving_Message_CoreDataObject *)[results lastObject];
	}
	
	return result;
}

- (XMPPMessageArchiving_Message_CoreDataObject *)archivedMessageWithMessageId:(NSString *)messageId inManagedObjectContext:(NSManagedObjectContext *)moc {
    if (!messageId || messageId.length == 0) {
        return nil;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity      = [self messageEntity:moc];
    request.predicate   = [NSPredicate predicateWithFormat:@"messageId == %@", messageId];
    request.fetchLimit  = 1;
    
    NSError *error;
    NSArray *messages = [moc executeFetchRequest:request error:&error];
    
    XMPPMessageArchiving_Message_CoreDataObject *message = nil;
    if (messages.count == 0) {
        XMPPLogError(@"Error, no archived message with id '%@' found.", messageId);
    } else {
        message = messages[0];
    }
    return message;
}

- (XMPPMessageArchiving_Message_CoreDataObjectMessageType)messageTypeForNotificationType:(NSString *)notificationType {
    XMPPMessageArchiving_Message_CoreDataObjectMessageType messageType;
    if ([notificationType isEqualToString:@"user-joined"]) {
        messageType = XMPPMessageArchiving_Message_CoreDataObjectMessageTypeRoomUserJoined;
    } else if ([notificationType isEqualToString:@"user-left"]) {
        messageType = XMPPMessageArchiving_Message_CoreDataObjectMessageTypeRoomUserLeft;
    } else if ([notificationType isEqualToString:@"user-banned"]) {
        messageType = XMPPMessageArchiving_Message_CoreDataObjectMessageTypeRoomUserBanned;
    } else if ([notificationType isEqualToString:@"room-created"]) {
        messageType = XMPPMessageArchiving_Message_CoreDataObjectMessageTypeRoomCreated;
    }  else if ([notificationType isEqualToString:@"room-destroyed"]) {
        messageType = XMPPMessageArchiving_Message_CoreDataObjectMessageTypeRoomDestroyed;
    }else {
        messageType = XMPPMessageArchiving_Message_CoreDataObjectMessageTypeDefault;
    }
    return messageType;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Public API
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (XMPPMessageArchiving_Contact_CoreDataObject *)contactForMessage:(XMPPMessageArchiving_Message_CoreDataObject *)msg
{
	// Potential override hook
	
	return [self contactWithBareJidStr:msg.bareJidStr
	                  streamBareJidStr:msg.streamBareJidStr
	              managedObjectContext:msg.managedObjectContext];
}

- (XMPPMessageArchiving_Contact_CoreDataObject *)contactWithJid:(XMPPJID *)contactJid
                                                      streamJid:(XMPPJID *)streamJid
                                           managedObjectContext:(NSManagedObjectContext *)moc
{
	return [self contactWithBareJidStr:[contactJid bare]
	                  streamBareJidStr:[streamJid bare]
	              managedObjectContext:moc];
}

- (XMPPMessageArchiving_Contact_CoreDataObject *)contactWithBareJidStr:(NSString *)contactBareJidStr
                                                      streamBareJidStr:(NSString *)streamBareJidStr
                                                  managedObjectContext:(NSManagedObjectContext *)moc
{
	NSEntityDescription *entity = [self contactEntity:moc];
	
	NSPredicate *predicate;
	if (streamBareJidStr)
	{
		predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@ AND streamBareJidStr == %@",
	                                                              contactBareJidStr, streamBareJidStr];
	}
	else
	{
		predicate = [NSPredicate predicateWithFormat:@"bareJidStr == %@", contactBareJidStr];
	}
	
	NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:entity];
	[fetchRequest setFetchLimit:1];
	[fetchRequest setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *results = [moc executeFetchRequest:fetchRequest error:&error];
	
	if (results == nil)
	{
		XMPPLogError(@"%@: %@ - Fetch request error: %@", THIS_FILE, THIS_METHOD, error);
		return nil;
	}
	else
	{
		return (XMPPMessageArchiving_Contact_CoreDataObject *)[results lastObject];
	}
}

- (NSString *)messageEntityName
{
	__block NSString *result = nil;
	
	dispatch_block_t block = ^{
		result = messageEntityName;
	};
	
	if (dispatch_get_specific(storageQueueTag))
		block();
	else
		dispatch_sync(storageQueue, block);
	
	return result;
}

- (void)setMessageEntityName:(NSString *)entityName
{
	dispatch_block_t block = ^{
		messageEntityName = entityName;
	};
	
	if (dispatch_get_specific(storageQueueTag))
		block();
	else
		dispatch_async(storageQueue, block);
}

- (NSString *)contactEntityName
{
	__block NSString *result = nil;
	
	dispatch_block_t block = ^{
		result = contactEntityName;
	};
	
	if (dispatch_get_specific(storageQueueTag))
		block();
	else
		dispatch_sync(storageQueue, block);
	
	return result;
}

- (void)setContactEntityName:(NSString *)entityName
{
	dispatch_block_t block = ^{
		contactEntityName = entityName;
	};
	
	if (dispatch_get_specific(storageQueueTag))
		block();
	else
		dispatch_async(storageQueue, block);
}

- (NSEntityDescription *)messageEntity:(NSManagedObjectContext *)moc
{
	// This is a public method, and may be invoked on any queue.
	// So be sure to go through the public accessor for the entity name.
	
	return [NSEntityDescription entityForName:[self messageEntityName] inManagedObjectContext:moc];
}

- (NSEntityDescription *)contactEntity:(NSManagedObjectContext *)moc
{
	// This is a public method, and may be invoked on any queue.
	// So be sure to go through the public accessor for the entity name.
	
	return [NSEntityDescription entityForName:[self contactEntityName] inManagedObjectContext:moc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Storage Protocol
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (BOOL)configureWithParent:(XMPPMessageArchiving *)aParent queue:(dispatch_queue_t)queue
{
	return [super configureWithParent:aParent queue:queue];
}

- (void)archiveMessage:(XMPPMessage *)message outgoing:(BOOL)isOutgoing xmppStream:(XMPPStream *)xmppStream
{
	// Message should either have a body, or be a composing notification
	
	NSString *messageBody = message.body;
    BOOL isComposing = NO;
	BOOL shouldDeleteComposingMessage = NO;
    BOOL isCarbonMessage = ([message.from.bare isEqualToString:[xmppStream myJID].bare] && !isOutgoing)? YES : NO;
    
    
    if (message.isGroupChatMessage && !message.elementID && !message.hasRoomMessageId) {
        return;
    }
    
	if ([messageBody length] == 0 && !message.hasNotification)
	{
		// Message doesn't have a body.
		// Check to see if it has a chat state (composing, paused, etc).
		
		isComposing = [message hasComposingChatState];
		if (!isComposing)
		{
			if ([message hasChatState])
			{
				// Message has non-composing chat state.
				// So if there is a current composing message in the database,
				// then we need to delete it.
				shouldDeleteComposingMessage = YES;
			}
			else
			{
				// Message has no body and no chat state.
				// Nothing to do with it.
				return;
			}
		}
    }
    
	[self scheduleBlock:^{
        if (messageBody.length == 0 && !message.hasNotification) {
            return; // Do NOT insert in DB
        }
        
        XMPPJID *myJid = [self myJIDForXMPPStream:xmppStream];
        
        if (message.hasNotification
            && ([message.notificationType isEqualToString:@"user-banned"] || [message.notificationType isEqualToString:@"user-left"])
            && [message.notificationUser isEqualToString:myJid.user]) {
            return; // Do NOT insert in DB
        }
        
        XMPPMessageArchiving_Message_CoreDataObject *archivedMessage = nil;
        NSManagedObjectContext *moc = [self managedObjectContext];
        
        if (messageBody.length > 0 && message.isErrorMessage && message.elementID.length > 0) {
            // If we receive an error message with body & ID, it means there was an error sending
            // this message. Mark the archived message as 'Failed' and do NOT insert this new one.
            archivedMessage = [self archivedMessageWithMessageId:message.elementID inManagedObjectContext:moc];
            archivedMessage.messageStatus = XMPPMessageArchiving_Message_CoreDataObjectMessageStatusFailed;
            return; // Do not insert this one
        }
        
        if (!isOutgoing && message.body.length > 0 && [message.from.resource isEqualToString:myJid.user] && !message.hasNotification) {
            // If the message was sent by me (group echo), do NOT insert it in the DB.
            return;
        }
		
		if (shouldDeleteComposingMessage)
		{
			if (archivedMessage)
			{
				[self willDeleteMessage:archivedMessage]; // Override hook
				[moc deleteObject:archivedMessage];
			}
			else
			{
				// Composing message has already been deleted (or never existed)
			}
		}
		else
		{
			XMPPLogVerbose(@"Previous archivedMessage: %@", archivedMessage);
            
            BOOL didCreateNewArchivedMessage = NO;
            if (isOutgoing) {
                archivedMessage = [self archivedMessageWithMessageId:message.elementID inManagedObjectContext:moc];
            } else {
            	archivedMessage = (XMPPMessageArchiving_Message_CoreDataObject *)
					[[NSManagedObject alloc] initWithEntity:[self messageEntity:moc]
				             insertIntoManagedObjectContext:nil];
				
				didCreateNewArchivedMessage = YES;
                
                //  Filter duplicated messages, special case in group with a new element called "roommessage" with an "id" attribute to storage the message Id.
                NSString *messageId = (message.isGroupChatMessage && message.hasRoomMessageId)? message.roomMessageId : message.elementID;
                if ([self archivedMessageWithMessageId:messageId inManagedObjectContext:moc]) {
                    NSLog(@"Duplicated message.");
                    return;
                }
			}

            XMPPJID *messageJid = (isOutgoing)? message.to : message.from;
            
            if (didCreateNewArchivedMessage) {
                archivedMessage.message = message;
                
                if (message.hasNotification) {
                    archivedMessage.body = nil;
                    archivedMessage.type = [self messageTypeForNotificationType:message.notificationType];
                } else {
                    archivedMessage.body = messageBody;
                    archivedMessage.type = XMPPMessageArchiving_Message_CoreDataObjectMessageTypeDefault;
                }
                
                
                archivedMessage.bareJid = [messageJid bareJID];
                archivedMessage.streamBareJidStr = [myJid bare];
                
                // Create new local timestamp
                archivedMessage.localTimestamp = [[NSDate alloc] init];
                
                NSDate *timestamp = [message delayedDeliveryDate];
                if (timestamp)
                    archivedMessage.remoteTimestamp = timestamp;
                else
                    archivedMessage.remoteTimestamp = archivedMessage.localTimestamp;
                
                archivedMessage.thread = message.thread;
                archivedMessage.isOutgoing = isOutgoing;
                archivedMessage.isComposing = isComposing;
                
                archivedMessage.messageId = (message.isGroupChatMessage && message.hasRoomMessageId)? message.roomMessageId : message.elementID;
                                
                if (isOutgoing && !isComposing) {
                    archivedMessage.messageStatus = XMPPMessageArchiving_Message_CoreDataObjectMessageStatusSent;
                }
            
                //  CARBON - Update values
                if (isCarbonMessage) {
                    archivedMessage.bareJid = message.to.bareJID;
                    archivedMessage.isOutgoing = YES;
                }
                
                if (message.isGroupChatMessage) {
                    archivedMessage.userString = (message.from.resource)? : message.notificationUser;
                    
                    if (isCarbonMessage) {
                        archivedMessage.userString  = [xmppStream.myJID user];
                        archivedMessage.bareJid     = message.to.bareJID;
                    }
                }
                
                // Message with ZLink/Document ID
                if (message.hasDocumentId) {
                    archivedMessage.type            = XMPPMessageArchiving_Message_CoreDataObjectMessageTypeAttachment;
                    archivedMessage.documentId      = message.documentId;
                    archivedMessage.documentGroupId = message.documentGroupId;
                    archivedMessage.messageStatus   = XMPPMessageArchiving_Message_CoreDataObjectMessageStatusToDownload;
                }
                
                XMPPLogVerbose(@"New archivedMessage: %@", archivedMessage);
                
                //  Fix NSConflict
                [moc setMergePolicy:NSOverwriteMergePolicy];
                                                             
                if (didCreateNewArchivedMessage) // [archivedMessage isInserted] doesn't seem to work
                {
                    XMPPLogVerbose(@"Inserting message...");
                    
                    [archivedMessage willInsertObject];       // Override hook
                    [self willInsertMessage:archivedMessage]; // Override hook
                    [moc insertObject:archivedMessage];
                }
                else
                {
                    XMPPLogVerbose(@"Updating message...");

                    [archivedMessage didUpdateObject];       // Override hook
                    [self didUpdateMessage:archivedMessage]; // Override hook
                }
            }
			// Create or update contact (if message with actual content)
			
			if ([messageBody length] > 0 || message.hasNotification)
			{
				BOOL didCreateNewContact = NO;
                XMPPMessageArchiving_Contact_CoreDataObject *contact;
                
                //  The first time I receive a carbon message, the contact will be nil and then I've to create below.
                //  once has been created, it will be able to show messages in the contacts' list.
                if (isCarbonMessage) {
                    contact = [self contactWithJid:message.to streamJid:nil managedObjectContext:[self managedObjectContext]];
                } else {
                    contact = [self contactForMessage:archivedMessage];
                }
				
				XMPPLogVerbose(@"Previous contact: %@", contact);
				
				if (contact == nil) {
					contact = (XMPPMessageArchiving_Contact_CoreDataObject *)
					    [[NSManagedObject alloc] initWithEntity:[self contactEntity:moc]
					             insertIntoManagedObjectContext:nil];
					
					didCreateNewContact = YES;
				}
				
                contact.bareJid = (isCarbonMessage) ? message.to : archivedMessage.bareJid;
                contact.streamBareJidStr = archivedMessage.streamBareJidStr;
				contact.mostRecentMessageTimestamp = archivedMessage.remoteTimestamp;
				contact.mostRecentMessageBody = archivedMessage.body;
				contact.mostRecentMessageOutgoing = @(isOutgoing);
                contact.mostRecentMessageType = archivedMessage.type;
                contact.mostRecentMessageUserStr = archivedMessage.userString;
                contact.badgeUnreadMessages = (isOutgoing) ? 0 : contact.badgeUnreadMessages + 1;
                
				XMPPLogVerbose(@"New contact: %@", contact);
				
				if (didCreateNewContact) // [contact isInserted] doesn't seem to work
				{
					XMPPLogVerbose(@"Inserting contact...");
					
					[contact willInsertObject];       // Override hook
					[self willInsertContact:contact]; // Override hook
					[moc insertObject:contact];
                    
                    //  Notify delegate
                    if (_delegate
                        && [_delegate conformsToProtocol:@protocol(XMPPMessageArchivingCoreDataStorageDelegate)]
                        && [_delegate respondsToSelector:@selector(xmppMessageArchivingCoreDataStorage:didCreateUser:)]) {
                        [_delegate xmppMessageArchivingCoreDataStorage:self didCreateUser:contact];
                    }
				}
				else
				{
					XMPPLogVerbose(@"Updating contact...");
					
					[contact didUpdateObject];       // Override hook
					[self didUpdateContact:contact]; // Override hook
				}
			}
		}
	}];
}

@end
