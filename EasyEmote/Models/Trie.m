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
    _numlevels = MAX(_numlevels, [word length]+1);
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
    [curr set_descr_str:word];
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

-(void)load_properties:(Node)node currlevel:(NSInteger)level
{
    [node set_numlevels:_numlevels];
    NSArray* sortedKeys = [[[node children] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    if ([sortedKeys count] == 0) return;
    NSMutableArray<NSMutableDictionary*>* first_occurrences = [node get_first_occurrences];
    NSMutableArray<NSMutableDictionary*>* last_occurrences = [node get_last_occurrences];
    for (NSString* key in sortedKeys)
    {
        Node neighbour = [node children][key];
        [self load_properties:neighbour currlevel:level+1];
        NSMutableDictionary* a = first_occurrences[level+1];
        NSMutableDictionary* b = last_occurrences[level+1];
        [a setObject:neighbour forKey:key];
        [b setObject:neighbour forKey:key];
        NSMutableArray<NSMutableDictionary*>* cfirst_occur = [neighbour get_first_occurrences];
        NSMutableArray<NSMutableDictionary*>* clast_occur = [neighbour get_last_occurrences];
        for (NSInteger i = level+2; i < _numlevels; i++)
        {
            NSMutableDictionary* cfirst_dict = cfirst_occur[i];
            NSMutableDictionary* clast_dict = clast_occur[i];
            NSMutableDictionary* first_dict = first_occurrences[i];
            NSMutableDictionary* last_dict = last_occurrences[i];
            NSArray* chars = [cfirst_dict allKeys];
            for (NSString* c in chars)
            {
                if (![c isEqualToString:[node get_value]])
                {
                    if ([first_dict objectForKey:c] == nil) [first_dict setObject:cfirst_dict[c] forKey:c];
                    [last_dict setObject:clast_dict[c] forKey:c];
                }
            }
        }
    }
    for (NSInteger i = 0; i < [sortedKeys count]; i++)
    {
        NSString* key = sortedKeys[i];
        NSMutableArray<NSMutableDictionary*>* last_occur = [[node children][key] get_last_occurrences];
        for (NSInteger k = level+2; k < _numlevels; k++)
        {
            for (NSInteger j = i+1; j < [sortedKeys count]; j++)
            {
                NSString* nextkey = sortedKeys[j];
                NSMutableArray<NSMutableDictionary*>* first_occur = [[node children][nextkey] get_first_occurrences];
                NSMutableDictionary* last_occur_level = last_occur[k];
                NSMutableDictionary* first_occur_level = first_occur[k];
                NSArray* chars = [last_occur_level allKeys];
                for (NSString* c in chars)
                {
                    Node n = [last_occur_level objectForKey:c];
                    if ([n get_next_in_level] == nil && [first_occur_level objectForKey:c] != nil) [n set_next_in_level:[first_occur_level objectForKey:c]];
                }
            }
        }
    }
}

-(void)dfs_get_emote:(Node)curr arr:(NSMutableArray<Pair*>*)res
{
    for (Node each in [[curr children] allValues]) [self dfs_get_emote:each arr:res];
    if ([curr get_unicode_str] != nil) [res addObject:[[Pair alloc]initialize:[curr get_descr_str] second:[curr get_unicode_str]]];
}

-(NSMutableArray<Pair*>*)all_emotes_in_subtrees:(Node)curr
{
    NSMutableArray<Pair*>* res = [NSMutableArray array];
    [self dfs_get_emote:curr arr:res];
    return res;
}

-(void)subsequence_search_helper:(NSString*)sequence curridx:(NSInteger)idx currnode:(Node)curr currlevel:(NSInteger)level arr:(NSMutableArray<Pair*>*)res
{
    if ([sequence length] <= idx)
    {
        [res addObjectsFromArray:[self all_emotes_in_subtrees:curr]];
        return;
    }
    NSMutableArray<NSMutableDictionary*>* first_occurrences = [curr get_first_occurrences];
    NSMutableArray<NSMutableDictionary*>* last_ocurrences = [curr get_last_occurrences];
    for (NSInteger i = level+1; i < _numlevels; i++)
    {
        Node n = [first_occurrences[i] objectForKey:[sequence substringWithRange:NSMakeRange(idx, 1)]];
        if (n == nil) continue;
        Node last = [last_ocurrences[i] objectForKey:[sequence substringWithRange:NSMakeRange(idx, 1)]];
        while (n != last)
        {
            [self subsequence_search_helper:sequence curridx:idx+1 currnode:n currlevel:i arr:res];
            n = [n get_next_in_level];
        }
        [self subsequence_search_helper:sequence curridx:idx+1 currnode:n currlevel:i arr:res];
    }
}

-(NSMutableArray<Pair*>*)subsequence_search:(NSString *)sequence
{
    NSMutableArray<Pair*>* res = [NSMutableArray array];
    [self subsequence_search_helper:sequence curridx:0 currnode:[self root] currlevel: 0 arr:res];
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
