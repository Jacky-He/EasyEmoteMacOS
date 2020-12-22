#import <Foundation/Foundation.h>

@interface TrieNode:NSObject
{
    NSString* _value;
    TrieNode* _parent;
    NSMutableDictionary *_children;
    NSString* _unicodestr;
    NSInteger _cnt;
}

-(TrieNode*)initialize:(NSString*)value parent:(TrieNode*)parent;
-(void)add:(NSString*)child;
-(NSMutableDictionary*)children;
-(void)set_unicode_str:(NSString*)str;
-(NSString*)get_unicode_str;
-(NSInteger)get_cnt;
-(void)set_cnt:(NSInteger)val;
-(NSString*)get_value;

@end
