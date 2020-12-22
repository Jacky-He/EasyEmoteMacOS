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
    [children setObject:[[TrieNode alloc]initialize:child parent:self] forKey:child];
}

-(NSMutableDictionary*)children
{
    if (_children == nil) _children = [[NSMutableDictionary alloc] init];
    return _children;
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
    [super dealloc];
}

@end
