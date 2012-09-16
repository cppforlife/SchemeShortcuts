#import "SchemeDestinationPair.h"

@interface SchemeDestinationPair ()
@property (strong, nonatomic) NSString *schemeName;
@property (strong, nonatomic) NSString *destinationName;
@end

@implementation SchemeDestinationPair
@synthesize schemeName = _schemeName, destinationName = _destinationName;

+ (SchemeDestinationPair *)fromString:(NSString *)string {
    NSArray *components = [string componentsSeparatedByString:@" > "];

    SchemeDestinationPair *pair = [[[SchemeDestinationPair alloc] init] autorelease];
    pair.schemeName = [components objectAtIndex:0];
    pair.destinationName = [components objectAtIndex:1];
    return pair;
}

- (void)dealloc {
    [_schemeName release];
    [_destinationName release];
    [super dealloc];
}
@end
