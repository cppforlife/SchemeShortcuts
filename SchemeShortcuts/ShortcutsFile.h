#import <Foundation/Foundation.h>

@class SchemeDestinationPair;

@interface ShortcutsFile : NSObject {
    NSString *_filePath;
    NSMutableDictionary *_mapping;
}

- (id)initWithFilePath:(NSString *)filePath;

- (SchemeDestinationPair *)pairForShortcut:(NSString *)key;
@end
