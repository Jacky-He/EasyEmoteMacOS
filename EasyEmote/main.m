//
//  main.m
//  EasyEmoteObjective-C
//
//  Created by Jacky He on 2020-12-21.
//
#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>
#import "Trie.h"

const NSString* kConnectionName = @"EasyEmote_Connection";

IMKServer* server;
IMKCandidates* candidates = nil;
Trie* dict;
NSMutableDictionary* DUMMYDICT;

NSString* toUTF16(NSString* str)
{
    uint32_t numval;
    NSScanner* scanner = [NSScanner scannerWithString:str];
    if (![scanner scanHexInt:&numval]) return @"";
    if (numval > 0xDF77 && numval < 0xE000) return @"";
    if (numval <= 0xDF77 || (numval >= 0xE000 && numval <= 0xFFFF))
    {
        unichar c = numval;
        return [NSString stringWithCharacters:&c length:1];
    }
    numval -= 0x10000;
    uint32_t i1 = (54 << 10) + ((numval >> 10)&1023);
    uint32_t i2 = (55 << 10) + (numval&1023);
    unichar c1 = i1;
    unichar c2 = i2;
    NSString* s1 = [NSString stringWithCharacters:&c1 length:1];
    NSString* s2 = [NSString stringWithCharacters:&c2 length:1];
    NSString* res = [s1 stringByAppendingString:s2];
    return res;
}

NSString* toUTF16Sequence(NSString* str)
{
    NSMutableString* res = [NSMutableString string];
    NSArray<NSString*>* chars = [str componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    for (NSInteger i = 0; i < [chars count]; i++) [res appendString:toUTF16(chars[i])];
    return res;
}

int main(int argc, char * argv[])
{
    NSLog(@"DEBUGMESSAGE: LOL1");
    
    NSString* identifier = [[NSBundle mainBundle] bundleIdentifier];
        
    server = [[IMKServer alloc] initWithName:(NSString*)kConnectionName bundleIdentifier:identifier];
    candidates = [[IMKCandidates alloc] initWithServer:server panelType:kIMKSingleColumnScrollingCandidatePanel styleType:kIMKMain];
   
    DUMMYDICT = [[NSMutableDictionary alloc]init];
    //load emojis
    dict = [[Trie alloc] init];
    NSURL* url = [[NSBundle mainBundle] URLForResource:@"emojiStore" withExtension:@"txt"];
    @try
    {
        NSString* inputString = [[NSString alloc] initWithContentsOfURL: url encoding:NSUTF8StringEncoding error:nil];
        NSArray<NSString*>* lines = [inputString componentsSeparatedByString:@"\n"];
        [inputString release];
        for (NSInteger i = 0; i < [lines count]; i++)
        {
            NSString* str = lines[i];
            if (![str containsString:@":"]) continue;
            NSArray<NSString*>* parts = [str componentsSeparatedByString:@":"];
            NSString* codestr = [parts[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString* descr = [parts[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString* unicodestr = toUTF16Sequence(codestr);
            [dict insert:[descr lowercaseString] unicodestr:unicodestr];
        }
    }
    @catch (NSException* exception)
    {
        NSLog(@"DEBUGMESSAGE: Error getting contents of file");
    }
//    [dict load_properties:[dict root]];
//    NSMutableArray<Pair*>* arr = [dict subsequence_search:@"ye"];
//    for (NSInteger i = 0; i < [arr count]; i++)
//    {
//        NSLog(@"%@ %@", [arr[i] first], [arr[i] second]);
//    }
//    NSLog(@"DEBUGMESSAGE: LOL2");
    NSString* s = [[NSBundle mainBundle] resourcePath];
    NSLog(@"DEBUGMESSAGE: %@", s);
    [NSThread sleepForTimeInterval:10000000000];
    
//    [[NSApplication sharedApplication] run];
    [DUMMYDICT release];
    [dict release];
    [server release];
    [candidates release];
    return 0;
}
