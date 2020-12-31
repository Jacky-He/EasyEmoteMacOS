#import <Foundation/Foundation.h>
#import "Record.h"

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
    Record* _record;
    NSInteger _currlevel;
    NSInteger _last_same_ancestor_level;
}

+(instancetype)trienode:(NSString*)value parent:(TrieNode*)parent;
-(void)add:(NSString*)child;
-(NSMutableDictionary*)children;
-(void)set_unicode_str:(NSString*)str;
-(void)set_parent:(TrieNode*)t;
-(NSString*)get_unicode_str;
-(NSInteger)get_cnt;
-(NSString*)get_descr_str;
-(void)set_descr_str:(NSString*)str;
-(void)set_cnt:(NSInteger)val;
-(NSString*)get_value;
-(NSMutableArray<NSMutableDictionary*>*)get_first_occurrences;
-(NSMutableArray<NSMutableDictionary*>*)get_last_occurrences;
-(TrieNode*)get_next_in_level;
-(void)set_next_in_level:(TrieNode*)node;
-(void)set_numlevels:(NSInteger)levels;
-(NSInteger)get_numlevels;
-(NSMutableDictionary*)get_first_occurrences_at_level:(NSInteger)level;
-(NSMutableDictionary*)get_last_occurrences_at_level:(NSInteger)level;
-(void)set_record:(Record*)r;
-(Record*)get_record;
-(void)clear_first_occurrences;
-(void)clear_last_occurrences;
-(NSInteger)get_curr_level;
-(NSInteger)get_last_same_ancestor_level;
-(void)set_curr_level:(NSInteger)level;
-(void)set_last_same_ancestor_level:(NSInteger)level;

@end
