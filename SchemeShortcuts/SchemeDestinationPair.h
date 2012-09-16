#import <Foundation/Foundation.h>

@interface SchemeDestinationPair : NSObject {
    NSString *_schemeName;
    NSString *_destinationName;
}

+ (SchemeDestinationPair *)fromString:(NSString *)string;

- (NSString *)schemeName;
- (NSString *)destinationName;
@end
