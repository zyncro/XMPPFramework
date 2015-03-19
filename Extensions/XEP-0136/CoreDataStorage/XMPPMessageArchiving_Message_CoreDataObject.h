#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "XMPP.h"

typedef NS_ENUM(int16_t, XMPPMessageArchiving_Message_CoreDataObjectMessageStatus) {
    XMPPMessageArchiving_Message_CoreDataObjectMessageStatusPending     = 0,    // Message pending to be sent
    XMPPMessageArchiving_Message_CoreDataObjectMessageStatusSent        = 1,    // Message already sent to the server
    XMPPMessageArchiving_Message_CoreDataObjectMessageStatusReceived    = 2,    // Message received by destination user
    XMPPMessageArchiving_Message_CoreDataObjectMessageStatusFailed      = 3,    // Message failed to send
    
    XMPPMessageArchiving_Message_CoreDataObjectMessageStatusToUpload    = 4,    // Preparing for upload
    XMPPMessageArchiving_Message_CoreDataObjectMessageStatusUploading   = 5,    // Upload in progress
    XMPPMessageArchiving_Message_CoreDataObjectMessageStatusUploaded    = 6,    // Successfully uploaded but XMPP message not sent yet
    
    XMPPMessageArchiving_Message_CoreDataObjectMessageStatusToDownload  = 7,    // Initial state for incoming messages from others with attachments
    XMPPMessageArchiving_Message_CoreDataObjectMessageStatusDownloading = 8,    // Download in progress
    XMPPMessageArchiving_Message_CoreDataObjectMessageStatusDownloaded  = 9,    // Already downloaded to disk
    
    /**
     * Please note that the Core Data model entity for object does validate if the 'messageStatus'
     * property is within range of valid values. If you include new values to this enum,
     * remember to update validation fields in Core Data model
    **/
};

typedef NS_ENUM(int16_t, XMPPMessageArchiving_Message_CoreDataObjectMessageType) {
    XMPPMessageArchiving_Message_CoreDataObjectMessageTypeDefault           = 0,
    
    XMPPMessageArchiving_Message_CoreDataObjectMessageTypeRoomUserJoined    = 1,
    XMPPMessageArchiving_Message_CoreDataObjectMessageTypeRoomUserLeft      = 2,
    XMPPMessageArchiving_Message_CoreDataObjectMessageTypeRoomUserBanned    = 3,
    XMPPMessageArchiving_Message_CoreDataObjectMessageTypeRoomDestroyed     = 4,
    
    XMPPMessageArchiving_Message_CoreDataObjectMessageTypeAttachment        = 5,
    
    /**
     * Please note that the Core Data model entity for object does validate if the 'type'
     * property is within range of valid values. If you include new values to this enum,
     * remember to update validation fields in Core Data model
     **/
};


@interface XMPPMessageArchiving_Message_CoreDataObject : NSManagedObject

@property (nonatomic, strong) XMPPMessage * message;  // Transient (proper type, not on disk)
@property (nonatomic, strong) NSString * messageStr;  // Shadow (binary data, written to disk)

/**
 * This is the bare jid of the person you're having the conversation with.
 * For example: robbiehanson@deusty.com
 * 
 * Regardless of whether the message was incoming or outgoing,
 * this will represent the "other" participant in the conversation.
**/
@property (nonatomic, strong) XMPPJID * bareJid;      // Transient (proper type, not on disk)
@property (nonatomic, strong) NSString * bareJidStr;  // Shadow (binary data, written to disk)

@property (nonatomic, strong) NSString * body;
@property (nonatomic, strong) NSString * thread;

@property (nonatomic, strong) NSNumber * outgoing;    // Use isOutgoing
@property (nonatomic, assign) BOOL isOutgoing;        // Convenience property

@property (nonatomic, strong) NSNumber * composing;   // Use isComposing
@property (nonatomic, assign) BOOL isComposing;       // Convenience property

@property (nonatomic, strong) NSDate * localTimestamp;
@property (nonatomic, strong) NSDate * remoteTimestamp;

@property (nonatomic, strong) NSString * streamBareJidStr;

@property (strong, nonatomic) NSString *messageId;
@property (assign, nonatomic) XMPPMessageArchiving_Message_CoreDataObjectMessageStatus messageStatus;

@property (strong, nonatomic) NSString *documentId;             // Attachment in messages
@property (strong, nonatomic) NSString *documentGroupId;        // Attachment's parent group in messages
@property (strong, nonatomic) NSString *uploadDownloadTaskId;   // Attachment local upload/download task ID to track network progress

@property (strong, nonatomic) NSString *userString;
@property (assign, nonatomic) XMPPMessageArchiving_Message_CoreDataObjectMessageType type;

/**
 * This method is called immediately before the object is inserted into the managedObjectContext.
 * At this point, all normal properties have been set.
 * 
 * If you extend XMPPMessageArchiving_Message_CoreDataObject,
 * you can use this method as a hook to set your custom properties.
**/
- (void)willInsertObject;

/**
 * This method is called immediately after the message has been changed.
 * At this point, all normal properties have been updated.
 * 
 * If you extend XMPPMessageArchiving_Message_CoreDataObject,
 * you can use this method as a hook to set your custom properties.
**/
- (void)didUpdateObject;

@end
