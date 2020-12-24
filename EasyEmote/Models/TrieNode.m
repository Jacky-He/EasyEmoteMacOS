//
//  TrieNode.m
//  EasyEmote
//
//  Created by Jacky He on 2020-12-21.
//

#import <Foundation/Foundation.h>
#import "TrieNode.h"

@implementation TrieNode

-(TrieNode*)initialize:(NSString*)value parent:(TrieNode*)parent
{
    self = [super init];
    if (self)
    {
        _value = [value retain];
        _parent = parent;
        _cnt = 0;
    }
    return self;
}

-(void)add:(NSString*)child
{
    NSMutableDictionary* children = [self children];
    if ([children objectForKey:child] != nil) return;
    TrieNode* newnode = [[TrieNode alloc]initialize:child parent:self];
    [children setObject: newnode forKey:child];
    [newnode release];
}

-(NSMutableDictionary*)children
{
    if (_children == nil) _children = [[NSMutableDictionary alloc] init];
    return _children;
}

-(NSMutableArray<NSMutableDictionary*>*)get_first_occurrences
{
    extern NSMutableDictionary* DUMMYDICT;
    if (_first_occurrences == nil)
    {
        _first_occurrences = [[NSMutableArray alloc] initWithCapacity:_numlevels];
        for (NSInteger i = 0; i < _numlevels; i++) [_first_occurrences addObject:DUMMYDICT];
    }
    return _first_occurrences;
}

-(NSMutableDictionary*)get_first_occurrences_at_level:(NSInteger)level
{
    extern NSMutableDictionary* DUMMYDICT;
    NSMutableArray<NSMutableDictionary*>* first  = [self get_first_occurrences];
    if (first[level] == DUMMYDICT)
    {
        NSMutableDictionary* obj = [[NSMutableDictionary alloc] init];
        [first setObject:obj atIndexedSubscript:level];
        [obj release];
    }
    return first[level];
}

-(NSMutableArray<NSMutableDictionary*>*)get_last_occurrences
{
    extern NSMutableDictionary* DUMMYDICT;
    if (_last_occurrences == nil)
    {
        _last_occurrences = [[NSMutableArray alloc] initWithCapacity:_numlevels];
        for (NSInteger i = 0; i < _numlevels; i++) [_last_occurrences addObject:DUMMYDICT];
    }
    return _last_occurrences;
}

-(NSMutableDictionary*)get_last_occurrences_at_level:(NSInteger)level
{
    extern NSMutableDictionary* DUMMYDICT;
    NSMutableArray<NSMutableDictionary*>* last = [self get_last_occurrences];
    if (last[level] == DUMMYDICT)
    {
        NSMutableDictionary* obj = [[NSMutableDictionary alloc] init];
        [last setObject:obj atIndexedSubscript:level];
        [obj release];
    }
    return last[level];
}

-(void)set_numlevels:(NSInteger)levels
{
    _numlevels = levels;
}

-(NSInteger)get_numlevels
{
    return _numlevels;
}

-(void)set_next_in_level:(TrieNode *)node
{
    if (_next_in_level != nil) [_next_in_level release];
    _next_in_level = [node retain];
}

-(TrieNode*)get_next_in_level
{
    return _next_in_level;
}

-(void)set_unicode_str:(NSString*)str
{
    if (_unicodestr != nil) [_unicodestr release];
    _unicodestr = [str retain];
}

-(NSString*)get_unicode_str
{
    return _unicodestr;
}

-(void)set_descr_str:(NSString *)str
{
    if (_descrstr != nil) [_descrstr release];
    _descrstr = [str retain];
}

-(NSString*)get_descr_str
{
    return _descrstr;
}

-(NSInteger)get_cnt
{
    return _cnt;
}

-(void)set_cnt:(NSInteger)val
{
    _cnt = val;
}

-(NSString*)get_value
{
    return _value;
}

-(void)dealloc
{
    [_value release];
    [_children release];
    [_unicodestr release];
    [_descrstr release];
    [_next_in_level release];
    [_first_occurrences release];
    [_last_occurrences release];
    [super dealloc];
}

@end
