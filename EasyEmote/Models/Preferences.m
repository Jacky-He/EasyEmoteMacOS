#import "Preferences.h"

@implementation Preferences

-(Preferences*)initialize
{
    self = [super init];
    if (self)
    {
//        [self train_model];
    }
    return self;
}

-(YCFFN*)get_prediction_model
{
    return _prediction_model;
}

-(void)set_prediction_model:(YCFFN*)model
{
    if (_prediction_model != nil) [_prediction_model release];
    if (model == nil) return;
    _prediction_model = [model retain];
}

-(void)train_model
{
    Matrix* m = [self get_csv_data];
    if (m == nil || [m columns] < 20) // only train if has enough data
    {
        [self set_prediction_model:nil];
        return;
    }
    NSLog(@"DEBUGMESSAGE: Training Model...");
    @autoreleasepool {
        dispatch_async(dispatch_queue_create("Train Model", nil), ^{
            Matrix* input = [m removeRow:4];
            Matrix* output = [m row:4];
            YCELMTrainer* trainer = [YCELMTrainer trainer];
            @try
            {
                YCFFN* model = (YCFFN* )[trainer train:nil inputMatrix:input outputMatrix:output];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self set_prediction_model:model];
                    NSLog(@"DEBUGMESSAGE: Training Finished!");
                });
            }
            @catch (NSException* e)
            {
                NSLog(@"DEBUGMESSAGE: Error training model %@", [e description]);
            }
        });
    }
}

- (Matrix *)matrixWithCSVName:(NSString *)path
{
    NSString* fileContents = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSMutableArray *arrays = [fileContents.CSVComponents mutableCopy];
    NSMutableArray *cols = [NSMutableArray array];
    for (NSArray *a in arrays)
    {
        [cols addObject:[Matrix matrixFromNSArray:a rows:(int)(a.count) columns:1]];
    }
    [fileContents release];
    return [Matrix matrixFromColumns:cols]; // Transpose to have one sample per column
}

-(Matrix*)get_csv_data
{
    NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"dataset.csv"];
//    NSString* defaultpath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"default.csv"];
    NSFileManager* filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:path]) return [self matrixWithCSVName:path];
    else return nil;
}

-(FMDatabase*)get_db
{
    NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"shistory.db"];
    if (_db == nil) _db = [FMDatabase databaseWithPath:path];
    return _db;
}

-(void)sort_without_model:(NSMutableArray<Triplet*>*)arr
{
    [arr sortUsingComparator:^NSComparisonResult(id a, id b) {
        Record* r1 = [(Triplet*)a third];
        Record* r2 = [(Triplet*)b third];
        if (r1 == nil || r2 == nil)
        {
            if (r1 == r2) return NSOrderedSame;
            if (r1 == nil) return NSOrderedDescending;
            return NSOrderedAscending;
        }
        if ([r1 ave_int] != [r2 ave_int])
        {
            if ([r1 ave_int] < 0) return NSOrderedDescending;
            if ([r2 ave_int] < 0) return NSOrderedAscending;
            if ([r1 ave_int] < [r2 ave_int]) return NSOrderedAscending;
            return NSOrderedDescending;
        }
        if ([r1 wago_select] != [r2 wago_select])
        {
            if ([r1 wago_select] > [r2 wago_select]) return NSOrderedAscending;
            return NSOrderedDescending;
        }
        if ([r1 mago_select] != [r2 mago_select])
        {
            if ([r1 mago_select] > [r2 mago_select]) return NSOrderedAscending;
            return NSOrderedDescending;
        }
        if ([r1 total_select] != [r2 total_select])
        {
            if ([r1 total_select] > [r2 total_select]) return NSOrderedAscending;
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
}

-(void)sort_based_on_history:(NSMutableArray<Triplet*>*)arr
{
    YCFFN* model = [self get_prediction_model];
    if (model == nil)
    {
        [self sort_without_model:arr];
        return;
    }
//    NSMutableArray<Pair*>* doublepair = [[NSMutableArray alloc]init];
//    NSInteger cnt = [arr count];
//    for (NSInteger i = 0; i < cnt; i++)
//    {
//        Record* r = [self get_record:arr[i] output:0];
//        if (r == nil)
//        {
//            NSNumber* n = [NSNumber numberWithDouble:-1.0];
//            Pair* obj = [[Pair alloc] initialize:arr[i] second:n];
//            [doublepair addObject:obj];
//            [obj release];
//            [n release];
//        }
//        else
//        {
//            double* mat = malloc(sizeof(double)*4);
//            mat[0] = [r total_select];
//            mat[1] = [r mago_select];
//            mat[2] = [r wago_select];
//            mat[3] = [r ave_int];
//            Matrix* input = [Matrix matrixFromArray:mat rows:4 columns:1];
//            Matrix* output = [model activateWithMatrix:input];
//            double pre = [output valueAtRow:0 column:0];
//            NSNumber* n = [NSNumber numberWithDouble:pre];
//            Pair* obj = [[Pair alloc]initialize:arr[i] second:n];
//            [doublepair addObject:obj];
//            free(mat);
//            [obj release];
//            [n release];
//        }
//    }
//    [doublepair sortUsingComparator:^NSComparisonResult(id a, id b) {
//        NSNumber* n1 = [(Pair*)a second];
//        NSNumber* n2 = [(Pair*)b second];
//        return [n2 compare:n1];
//    }];
//    for (NSInteger i = 0; i < [doublepair count]; i++) [arr setObject:[doublepair[i] first] atIndexedSubscript:i];
//    [doublepair release];
}

-(Record*)get_record:(NSString*)emote output:(double)res
{
    FMDatabase* db = [self get_db];
    if (![db open])
    {
        NSLog(@"DEBUGMESSAGE: failed to open sqlite database");
        return nil;
    }
    Record* r = [self get_record_helper:emote output:res];
    [db close];
    return r;
}

-(Record*)get_record_helper:(NSString*)emote output:(double)res
{
    //assert db is open
    FMDatabase* db = [self get_db];
    NSDate* curr = [NSDate date];
    NSTimeInterval timestamp = [curr timeIntervalSinceReferenceDate];
    NSInteger roundedtime = round(timestamp);
    NSInteger wago = roundedtime - 7*24*3600;
    NSInteger mago = roundedtime - 30*24*3600;
    int wago_select = 0;
    int mago_select = 0;
    int total_select = 0;
    double ave_int = -1.0;
    NSString* sql = [NSString stringWithFormat: @"CREATE TABLE if not exists `%@` (`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, `timestamp` INTEGER NOT NULL);", emote];
    if (![db executeStatements:sql]) NSLog(@"DEBUGMESSAGE error = %@", [db lastErrorMessage]);
    sql = [NSString stringWithFormat: @"SELECT COUNT(*) FROM `%@` WHERE `timestamp`>=%ld;", emote, wago];
    FMResultSet *s = [db executeQuery:sql];
    if ([s next]) wago_select = [s intForColumnIndex:0];
    [s close];
    sql = [NSString stringWithFormat: @"SELECT COUNT(*) FROM `%@` WHERE `timestamp`>=%ld;", emote, mago];
    s = [db executeQuery:sql];
    if ([s next]) mago_select = [s intForColumnIndex:0];
    [s close];
    sql = [NSString stringWithFormat:@"SELECT ave_interval, numselection FROM `interval` WHERE emoji='%@'", emote];
    s = [db executeQuery:sql];
    if ([s next])
    {
        ave_int = [s doubleForColumn:@"ave_interval"];
        total_select = [s intForColumn:@"numselection"];
    }
    [s close];
    return [[Record alloc] initialize:res total_select:total_select mago_select:mago_select wago_select:wago_select ave_int:ave_int];
}

-(void)append_to_CSV:(Record*)r
{
    if ([r ave_int] < 0 || r == nil) return;
    NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"dataset.csv"];
    NSString* s = [NSString stringWithFormat:@"%d,%d,%d,%.f,%.f\n", [r total_select], [r mago_select], [r wago_select], [r ave_int], [r res]];
    NSFileManager* filemanager = [NSFileManager defaultManager];
    if ([filemanager fileExistsAtPath:path])
    {
        NSFileHandle* fh = [NSFileHandle fileHandleForWritingAtPath:path];
        [fh seekToEndOfFile];
        NSData* data = [s dataUsingEncoding:NSUTF8StringEncoding];
        [fh writeData:data];
        [fh closeFile];
    }
    else [filemanager createFileAtPath:path contents:[s dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
}

-(void)load_all_tables:(NSMutableArray<Triplet*>*)arr
{
    FMDatabase* db = [self get_db];
    if (![db open])
    {
        NSLog(@"DEBUGMESSAGE: failed to open sqlite database");
        return;
    }
    NSString* q = @"CREATE TABLE if not exists `interval` (`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, `emoji` TEXT NOT NULL UNIQUE, `ave_interval` REAL NOT NULL, `numselection` INTEGER NOT NULL, `last_seen` INTEGER NOT NULL);";
    if (![db executeStatements:q]) NSLog(@"DEBUGMESSAGE: error = %@", [db lastErrorMessage]);
    for (NSInteger i = 0; i < [arr count]; i++)
    {
        NSString* sql = [NSString stringWithFormat:
                         @"CREATE TABLE if not exists `%@` (`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, `timestamp` INTEGER NOT NULL);", [arr[i] first]];
        if (![db executeStatements:sql]) NSLog(@"DEBUGMESSAGE: error = %@", [db lastErrorMessage]);
    }
    [db close];
}

-(void)load_all_emote_records
{
    FMDatabase* db = [self get_db];
    if (![db open])
    {
        NSLog(@"DEBUGMESSAGE: failed to open sqlite database");
        return;
    }
    extern Trie* dict;
    NSString* sql = @"SELECT `emoji` FROM `interval`;";
    FMResultSet *s = [db executeQuery:sql];
    NSMutableArray<NSString*>* arr = [NSMutableArray array];
    while ([s next])
    {
        NSString* emote = [s stringForColumn:@"emoji"];
        [arr addObject:emote];
    }
    [s close];
    for (NSInteger i = 0; i < [arr count]; i++)
    {
        Record* r = [self get_record_helper:arr[i] output:-1.0];
        NSString* nocolon = [arr[i] substringWithRange:NSMakeRange(1, [arr[i] length]-2)];
        [dict update_record:nocolon record:r];
        [r release];
    }
    [db close];
}

-(void)insert_new_entry:(Triplet*)entry candidates:(NSArray<Triplet*>*)potential
{
    FMDatabase* db = [self get_db];
    if (![db open])
    {
        NSLog(@"DEBUGMESSAGE: failed to open sqlite database");
        return;
    }
    NSDate* curr = [NSDate date];
    NSTimeInterval timestamp = [curr timeIntervalSinceReferenceDate];
    NSInteger roundedtime = round(timestamp);
    NSString* sql = [NSString stringWithFormat:
                     @"CREATE TABLE if not exists `%@` (`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, `timestamp` INTEGER NOT NULL);"
                     "CREATE TABLE if not exists `interval` (`id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, `emoji` TEXT NOT NULL UNIQUE, `ave_interval` REAL NOT NULL, `numselection` INTEGER NOT NULL, `last_seen` INTEGER NOT NULL);"
                     , [entry first]];
    if (![db executeStatements:sql]) NSLog(@"DEBUGMESSAGE: error = %@", [db lastErrorMessage]);
    [db close];
    
    bool did = false;
    for (NSInteger i = 0; i < [potential count]; i++)
    {
        double res = [[potential[i] first] isEqualToString:[entry first]] ? 1.0 : 0.0;
        Record* r = [potential[i] third];
        if ([[potential[i] first] isEqualToString:@":purse:"])
        {
            NSLog(@"DEBUGMESSAGE: PURSE: %@", r);
        }
        if (r == nil) continue;
        Record* tmp = [[Record alloc] initialize:res total_select:[r total_select] mago_select:[r mago_select] wago_select:[r wago_select] ave_int:[r ave_int]];
        if ([tmp ave_int] >= 0) did = true;
        [self append_to_CSV:tmp];
        [tmp release];
    }
    
    if (![db open])
    {
        NSLog(@"DEBUGMESSAGE: failed to open sqlite database");
        return;
    }
    sql = [NSString stringWithFormat:
                     @"INSERT INTO `%@` (`timestamp`) VALUES (%ld);"
                     "INSERT INTO `interval` (`emoji`, `ave_interval`, `numselection`, `last_seen`) VALUES ('%@', -1.0, 1, %ld) ON CONFLICT(`emoji`) "
                     "DO UPDATE SET ave_interval=(ave_interval*(numselection-1)+(excluded.last_seen-last_seen))/numselection, numselection=numselection+1, last_seen=excluded.last_seen;"
                      , [entry first], roundedtime, [entry first], roundedtime];
    
    if (![db executeStatements:sql]) NSLog(@"DEBUGMESSAGE: error = %@", [db lastErrorMessage]);
    [db close];
    
    extern Trie* dict;
    Record* r = [self get_record:[entry first] output:-1.0];
    NSString* nocolon = [[entry first] substringWithRange:NSMakeRange(1, [[entry first] length]-2)];
    [dict update_record:nocolon record:r];
    [r release];
}

-(void)dealloc
{
    [_prediction_model release];
    [_db release];
    [super dealloc];
}

@end
