#import <Foundation/Foundation.h>

@interface TrieNode:NSObject
{
    NSString* _value;
    TrieNode* _parent;
    NSMutableDictionary *_children;
    NSString* _unicodestr;
    NSString* _descrstr;
    NSInteger _cnt;
    NSInteger _numlevels;
    NSMutableArray<NSMutableDictionary*>* _first_occurrences;
    NSMutableArray<NSMutableDictionary*>* _last_occurrences;
    TrieNode* _next_in_level;
}

-(TrieNode*)initialize:(NSString*)value parent:(TrieNode*)parent numlevels:(NSInteger)levels;
-(void)add:(NSString*)child;
-(NSMutableDictionary*)children;
-(void)set_unicode_str:(NSString*)str;
-(NSString*)get_unicode_str;
-(NSInteger)get_cnt;
-(NSString*)get_descr_str;
-(void)set_descr_str:(NSString*)str;
-(void)set_cnt:(NSInteger)val;
-(NSString*)get_value;
-(NSArray<NSMutableDictionary*>*)get_first_occurrences;
-(NSArray<NSMutableDictionary*>*)get_last_occurrences;
-(TrieNode*)get_next_in_level;
-(void)set_next_in_level:(TrieNode*)node;

@end
