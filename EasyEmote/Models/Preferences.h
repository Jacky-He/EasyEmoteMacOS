#import <YCML/YCML.h>
#import <fmdb/FMDB.h>
#import "Triplet.h"
#import "Pair.h"
#import "Record.h"
#import "CHCSVParser.h"
#import "Trie.h"

@interface Preferences : NSObject
{
    YCFFN* _prediction_model;
    FMDatabase* _db;
}

-(Preferences*)initialize;
-(void)sort_based_on_history:(NSArray<Triplet*>*)arr;
-(void)insert_new_entry:(Triplet*)entry candidates:(NSArray<Triplet*>*)potential;
-(void)load_all_tables:(NSMutableArray<Triplet*>*)arr;
-(Record*)get_record:(NSString*)emote output:(double)res;
-(void)train_model;
-(void)load_all_emote_records;

@end
