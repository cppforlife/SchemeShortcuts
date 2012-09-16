#import "ShortcutsFile.h"
#import "SchemeDestinationPair.h"

@interface ShortcutsFile ()
@property (strong, nonatomic) NSString *filePath;
@property (strong, nonatomic) NSMutableDictionary *mapping;
@end

@implementation ShortcutsFile
@synthesize filePath = _filePath, mapping = _mapping;

- (id)initWithFilePath:(NSString *)filePath {
    if (self = [super init]) {
        self.filePath = filePath;
        NSLog(@"Shortcuts file at %@", self.filePath);

        self.mapping = [NSMutableDictionary dictionary];
        [self _load];
    }
    return self;
}

- (void)dealloc {
    [_filePath release];
    [_mapping release];
    [super dealloc];
}

- (void)_load {
    NSError *error = nil;
    NSString *fileContents = [NSString stringWithContentsOfFile:self.filePath encoding:NSUTF8StringEncoding error:&error];

    if (error) {
        NSLog(@"Error reading: %@", error);
        return;
    }

    NSArray *lines = [fileContents componentsSeparatedByString:@"\n"];

    for (NSString *line in lines) {
        NSArray *declaration = [line componentsSeparatedByString:@": "];
        if (declaration.count != 2) continue;

        SchemeDestinationPair *pair = [SchemeDestinationPair fromString:[declaration objectAtIndex:1]];
        [self.mapping setObject:pair forKey:[declaration objectAtIndex:0]];
    }
}

- (SchemeDestinationPair *)pairForShortcut:(NSString *)key {
    return [self.mapping objectForKey:key];
}
@end
