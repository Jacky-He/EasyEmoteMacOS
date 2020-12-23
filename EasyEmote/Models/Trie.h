#import <Foundation/Foundation.h>
#import "TrieNode.h"
#import "Pair.h"

typedef TrieNode* Node;

@interface Trie: NSObject
{
    Node _root;
}

-(Node)root;
-(void)insert:(NSString*)word unicodestr:(NSString*)unicode;
-(BOOL)contains:(NSString*)word;
-(NSString*)get_unicode_str:(NSString*)descr;
-(void)dealloc_helper:(Node)node;
-(NSMutableArray<Pair*>*)get_most_relevant:(NSString*)input;
-(NSMutableArray<Pair*>*)random_n:(Node)node maxlength:(NSInteger)num;
@end
