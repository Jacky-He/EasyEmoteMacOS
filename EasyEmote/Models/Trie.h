#import <Foundation/Foundation.h>
#import "TrieNode.h"
#import "Triplet.h"

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
-(NSMutableArray<Triplet*>*)prefix_search:(NSString*)input;
-(NSMutableArray<Triplet*>*)random_n:(Node)node maxlength:(NSInteger)num;
-(void)load_properties:(Node)node;
-(NSMutableArray<Triplet*>*)subsequence_search:(NSString*)sequence;
-(void)subsequence_search_helper:(NSString*)sequence curridx:(NSInteger)idx currnode:(Node)curr arr:(NSMutableArray<Triplet*>*)res;
-(NSMutableArray<Triplet*>*)all_emotes_in_subtrees:(Node)curr;
-(void)dfs_get_emote:(Node)curr arr:(NSMutableArray*)res;
-(void)update_record:(NSString*)word record:(Record*)r;
-(Record*)get_record:(NSString*)word;

@end
