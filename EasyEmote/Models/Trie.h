#import <Foundation/Foundation.h>
#import "TrieNode.h"
#import "Pair.h"

typedef TrieNode* Node;

@interface Trie: NSObject
{
    Node _root;
    NSInteger _numlevels;
}

-(Node)root;
-(void)insert:(NSString*)word unicodestr:(NSString*)unicode;
-(BOOL)contains:(NSString*)word;
-(NSString*)get_unicode_str:(NSString*)descr;
-(void)dealloc_helper:(Node)node;
-(NSMutableArray<Pair*>*)get_most_relevant:(NSString*)input;
-(NSMutableArray<Pair*>*)random_n:(Node)node maxlength:(NSInteger)num;
-(void)load_properties:(Node)node currlevel:(NSInteger)level;
-(NSMutableArray<Pair*>*)subsequence_search:(NSString*)sequence;
-(void)subsequence_search_helper:(NSString*)sequence curridx:(NSInteger)idx currnode:(Node)curr currlevel:(NSInteger)level arr:(NSMutableArray<Pair*>*)res;
-(NSMutableArray<Pair*>*)all_emotes_in_subtrees:(Node)curr;
-(void)dfs_get_emote:(Node)curr arr:(NSMutableArray*)res;

@end
