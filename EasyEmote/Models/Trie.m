//
//  Trie.m
//  EasyEmote
//
//  Created by Jacky He on 2020-12-21.
//

#import <Foundation/Foundation.h>
#import "Trie.h"

@implementation Trie

-(Node)root
{
    if (_root == nil) _root = [[TrieNode alloc]init];
    return _root;
}

-(void)insert:(NSString*)word unicodestr:(NSString*)unicode
{
    if (word == nil) return;
    if ([self contains:word]) return;
    Node curr = [self root];
    [curr set_cnt:([curr get_cnt]+1)];
    for (NSInteger i = 0; i < [word length]; i++)
    {
        NSString* c = [word substringWithRange:NSMakeRange(i, 1)];
        [curr add: c];
        curr = [curr children][c];
        [curr set_cnt:([curr get_cnt]+1)];
    }
    [curr set_unicode_str:unicode];
}

-(BOOL)contains:(NSString*)word
{
    if (word == nil) return true;
    Node curr = [self root];
    NSInteger idx = 0;
    while (idx < word.length && [curr children][[word substringWithRange:NSMakeRange(idx, 1)]] != nil)
    {
        curr = [curr children][[word substringWithRange:NSMakeRange(idx, 1)]];
        idx++;
    }
    return idx == [word length] && [curr get_unicode_str] != nil;
}

-(NSString*)get_unicode_str:(NSString*)descr
{
    if (descr == nil) return nil;
    Node curr = [self root];
    NSInteger idx = 0;
    while (idx < [descr length] && [curr children][[descr substringWithRange:NSMakeRange(idx, 1)]] != nil)
    {
        curr = [curr children][[descr substringWithRange:NSMakeRange(idx, 1)]];
        idx++;
    }
    return idx == [descr length] ? [curr get_unicode_str] : nil;
}

-(NSMutableArray<Pair*>*)get_most_relevant:(NSString*)input
{
    NSMutableArray<Pair*>* res = [NSMutableArray array];
    if (input == nil) return res;
    Node curr = [self root];
    NSInteger idx = 0;
    while (idx < [input length] && [curr children][[input substringWithRange:NSMakeRange(idx, 1)]] != nil)
    {
        curr = [curr children][[input substringWithRange:NSMakeRange(idx, 1)]];
        idx++;
    }
    if (idx < [input length]) return res;
    res = [self random_n:curr maxlength:80];
    NSString* copy = [input substringToIndex:([input length]-1)];
    for (NSInteger i = 0; i < [res count]; i++) [res[i] set_first:[copy stringByAppendingString:[res[i] first]]];
    return res;
}

-(NSMutableArray<Pair*>*)random_n:(Node)node maxlength:(NSInteger)num
{
    NSMutableArray<Pair*>* res = [NSMutableArray array];
    NSInteger remain = num;
    if ([node get_unicode_str] != nil)
    {
        remain--;
        [res addObject:[[Pair alloc] initialize:@"" second:[node get_unicode_str]]];
    }
    NSArray<Node>* children = [[node children] allValues];
    for (NSInteger i = 0; i < [children count]; i++)
    {
        if (remain <= 0) break;
        NSInteger sub = MIN(remain, [children[i] get_cnt]);
        NSMutableArray<Pair*>* temp = [self random_n:children[i] maxlength:(sub)];
        [res addObjectsFromArray:temp];
        remain -= sub;
    }
    for (int i = 0; i < [res count]; i++)
    {
        [res[i] set_first:[[node get_value] stringByAppendingString:[res[i] first]]];
    }
    return res;
}

-(void)dealloc_helper:(Node)node
{
    NSArray* adj = [[node children] allValues];
    for (NSInteger i = 0; i < [adj count]; i++) [self dealloc_helper:adj[i]];
    [node release];
}

-(void)dealloc
{
    [self dealloc_helper:[self root]];
    [super dealloc];
}

@end
