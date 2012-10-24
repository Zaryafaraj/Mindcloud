//  IdeaStock
//
//  Created by Ali Fathalian on 4/10/12.
//  Copyright (c) 2012 University of Washington. All rights reserved.
//

#import "DropboxAssociativeBulletinBoardTests.h"
#import "MockDropBoxDatamodel.h"
#import "DropBoxAssociativeBulletinBoard.h"
#import "Note.h"
/*
 * PART I : 1 -55 
 * PART II : 55- 110
 * PART III : 110 - 169
 */

#define POSITION_TYPE @"position"
#define VISIBILITY_TYPE @"visibility"
#define LINKAGE_TYPE @"linkage"
#define STACKING_TYPE @"stacking"
#define GROUPING_TYPE @"grouping"
#define NOTE_NAME_TYPE @"name"


@interface DropboxAssociativeBulletinBoardTests()

@property (nonatomic,strong) MockDropBoxDatamodel * dataModel;
@property (nonatomic,strong) DropBoxAssociativeBulletinBoard * board;
@end

@implementation DropboxAssociativeBulletinBoardTests

@synthesize dataModel = _dataModel;
@synthesize board = _board;

DropBoxAssociativeBulletinBoard * board;

-(MockDropBoxDatamodel *) dataModel{
    if (!_dataModel){
        _dataModel = [[MockDropBoxDatamodel alloc] init];
    }
    return _dataModel;
}



- (void)setUp
{
    self.board = [[DropBoxAssociativeBulletinBoard alloc] initBulletinBoardFromXoomlWithDatamodel:self.dataModel andName:@"testBoard"];

    
}

- (void)tearDown
{
    
}

/*
//1
- (void) testInitEmptyBulletinBoard{
    
    NSString * boardName = @"testBoard";
    DropBoxAssociativeBulletinBoard * board = [[DropBoxAssociativeBulletinBoard alloc] initEmptyBulletinBoardWithDataModel:self.dataModel andName:boardName];
    STAssertEqualObjects(boardName, board.bulletinBoardName,@"Board Name didnt get initiated correctly");
    
    int actualNoteCount = [[board getAllNotes] count];
    STAssertEquals(0, actualNoteCount,@"An empty board doesn't have zero notes");
    
    int stackingCount = [[board getAllBulletinBoardAttributeNamesOfType:STACKING_TYPE] count];
    STAssertEquals(0,stackingCount,@"Stacking attributes were not empty");
    
    int groupingCount = [[board getAllBulletinBoardAttributeNamesOfType:GROUPING_TYPE] count];
    STAssertEquals(0,groupingCount,@"Stacking attributes were not empty");

}
*/
//2
-(void) testInitBulletinBoardWithXooml{
    
    NSDictionary * notes = [self.board getAllNotes];
   int actualNoteCount = [notes count];
    
    //test the number of notes
    STAssertEquals(2, actualNoteCount, @"Notes didn't get initiated successfully");
    
    //test note contents
    NSArray * noteObjects = [notes allValues];
    for (id<Note> note in noteObjects){
        NSString * noteText = note.noteText;
        STAssertEqualObjects(@"Note1Text1",noteText, @"Note text didn't get initiated properly");
    }
    
    //test bulletinboard attributes
    NSDictionary * stackingAttributes = [self.board getAllBulletinBoardAttributeNamesOfType:STACKING_TYPE];
    NSDictionary * groupingAttributes = [self.board getAllBulletinBoardAttributeNamesOfType:GROUPING_TYPE];
    
    int stackingCount = [stackingAttributes count];
    STAssertEquals(2, stackingCount, @"All the stackings didn't get generated");
    int groupingCount = [groupingAttributes count];
    STAssertEquals(2, groupingCount,@"All the stackings didn't get generated");
    
    //test note attributes
    for (NSString * noteID in notes){
        NSDictionary * noteLinkages =[self.board getAllNoteAttributeNamesOfType:LINKAGE_TYPE forNote:noteID ];
        int linkageSize = [noteLinkages count];
        STAssertEquals(1, linkageSize,@"linkages didn't instantiate correctly");
        
        NSDictionary *noteName = [self.board getAllNoteAttributeNamesOfType:NOTE_NAME_TYPE forNote:noteID];
        NSString * name = [noteName[[[noteName allKeys] lastObject]] lastObject];
        if (![name isEqualToString:@"Note1"] && ![name isEqualToString:@"Note2"]){
            STFail(@"Note NAmes didn't get instantiated correctly");
        }
                    
        NSDictionary *notePosition = [self.board getAllNoteAttributeNamesOfType:POSITION_TYPE forNote:noteID];
        int positionItems = [notePosition count];
        STAssertEquals(2, positionItems,@"Note Position didn't get insantiated");
        NSDictionary *visibility = [self.board getAllNoteAttributeNamesOfType:VISIBILITY_TYPE forNote:noteID];
        int visibilityCount = [visibility count];
        STAssertEquals(1,visibilityCount,@"visibility didn't get insantiated correctly");
    }
    
}
/*
//3
-(void) testInitEmptyBulletinBoardWithNilDataModel{
    
}

//4
-(void) testInitBulletinBoardWithXoomlWithNilDataModel{
    
}

//5
-(void) testInitEmptyBulletinBoardWithNilName{
    
}

//6
-(void) testInitBulletinBoardWithXoomlWithNilName{
    
}

//7
-(void) testInitBulletinBoardWithInvalidXooml{
    
}

//8
-(void) testInitBulletinBoardWithNilXooml{
    
}

//9
-(void) testBulletinBoardTimer{
    
}

//10
-(void) testBulletinBoardInvalidateTimer{
    
}

//11
-(void) testAddNoteContent{
    
}

//12
-(void) testAddNoteContentWithInvalidNote{
    
}

//13
-(void) testAddNoteContentWithNilNote{
    
}

//14
-(void) testNoteContentWithNilProperties{
    
}

//15
-(void) testNoteContentWithMissingRequiredProperty{

}

//16
-(void) testNoteContentWithMissingOptionalProperty{

}

//17

-(void) testAddNoteAttribute{

}

//18
-(void) testAddNoteAttributeWithNilName{

}

//19
-(void) testAddNoteAttributeWithNilType{

}

//20
-(void) testAddNoteAttributeWithInvalidType{

}

//21
-(void) testAddNoteAttributeWithNilNoteId{

}

//22
-(void) testAddNoteAttributeWithInvalidNoteID{

}

//23
-(void) testAddNoteAttributeWithInvalidValues{

}

//24
-(void) testAddNoteAttributeWithEmptyValues{

}

//25
-(void) testAddNoteToAttribute{

}

//26
-(void) testAddNoteToAttributeWithInvalidTargetID{

}

//27
-(void) testAddNoteToAttributeWithInvalidSourceID{

}

//28
-(void) testAddNoteToAttributeWithNilTargetID{

}

//29
-(void) testAddNoteToAttributeWithNilSourceID{

}

//30
-(void) testAddNoteToAttributeWithInvalidAttributeType{

}

//31
-(void) testAddNoteToAttributeWithNilAttributeType{

}

//32
-(void) testAddNoteToAttributeWithNilAttributeName{

}

//33
-(void) testAddNoteToAttributeWithNewAttributeName{

}

//34
-(void) testAddBulletinBoardAttribute{

}

//35
-(void) testAddBulletinBoardAttributeWithInvalidType{

}

//36
-(void) testAddBulletinBoardAttributeWithNilAttributeType{

}

//37
-(void) testAddBulletinBoardAttributeWithNilAttributeName{

}

//38
-(void) testAddNoteToBulletinBoardAttribute{

}

//39

-(void) testAddNoteToBulletinBoardAttributeWithInvalidNoteID{

}

//40
-(void) testAddNoteToBulletinBoardAttributeWithNilNoteID{

}

//41
-(void) testAddNoteToBulletinBoardAttributeWithInvalidAttributeType{

}

//42
-(void) testAddNoteToBulletinBoardAttributeWithNonExistingAttributeName{

}

//43
-(void) testAddNoteToBulletinBoardAttributeWithNilAttributeName{

}

//44

-(void) testRemoveNote{

}

//45

-(void) testRemoveNoteWithInvalidNoteID{

}

//46

-(void) testRemoveNoteWithNilNoteID{

}

//47
-(void) testRemoveNoteFromAttribute{

}

//48
-(void) testRemoveNoteFromAttributeWithInvalidTargetID{

}

//49
-(void) testRemoveNoteFromAttributeWithInvalidSourceID{

}

//50
-(void) testRemoveNoteFromAttributeWithNilTargetID{

}

//51
-(void) testRemoveNoteFromAttributeWithNilSourceID{

}

//52
-(void) testRemoveNoteFromAttributeWithInvalidAttributeName{

}

//53
-(void) testRemoveNoteFromAttributeWithInvalidAttributeType{

}

//54
-(void) testRemoveNoteFromAttributeWithNilAttributeName{

}

//55

-(void) testRemoveNoteFromAttributeWithNilAttributeType{

}

//56
-(void) testRemoveNoteFromAttributeWhenAttributeDoesNotContainTarget{

}

//57
-(void) testRemoveNoteFromAttributeWhenAttributeDoesntBelongToSource{

}

//58
-(void) testRemoveNoteFromAttributeTwice{

}

//59
-(void) testRemoveNoteFromAttributeWithEmptyAttributeValues{

}

//60
-(void) testRemoveNoteAttribute{

}

//61
-(void) testRemoveNoteAttributeWithInvalidNoteID{

}
//62
-(void) testRemoveNoteAttributeForNonExistingAttributeName{

}

//63
-(void) testRemoveNoteAttributeForNonExistingAttributeType{

}

//64
-(void) testRemoveNoteAttributeWithInvalidAttributeType{

}

//65
-(void) testRemoveNoteAttributeWithNilAttributeName{

}

//66
-(void) testRemoveNoteAttributeWithNilAttributeType{

}

//67
-(void) testRemoveNoteAttributeWithNilNoteID{

}

//68
-(void) testRemoveNoteAttributeTwice{

}

//68
-(void) testRemoveNoteAttributeFromEmptyNoteAttributes{

}

//69
-(void) testRemoveNoteAttributeFromBulletinBoardAttribute{

}

//70
-(void) testRemoveNoteAttributeFromBulletinBoardAttributeInvalidNoteID{

}

//71
-(void) testRemoveNoteAttributeFromBulletinBoardAttributeNilNoteID{

}

//72
-(void) testRemoveNoteAttributeFromBulletinBoardAttributeInvalidAttributeName{

}

//73
-(void) testRemoveNoteAttributeFromBulletinBoardAttributeInvalidAttributeType{

}

//74
-(void) testRemoveNoteAttributeFromBulletinBoardAttributeNilAttributeName{

}

//75
-(void) testRemoveNoteAttributeFromBulletinBoardAttributeNilAttributeType{

}

//76
-(void) testRemoveNoteAttributeFromBulletinBoardAttributeFromNonExistingAttribute{

}

//77
-(void) testRemoveNoteAttributeFromBulletinBoardAttributeTwice{

}

//78
-(void) testRemoveNoteAttributeFromBulletinBoardAttributeWithNoteNotBelongingToAttribute{

}

//79
-(void) removeBulletinBoardAttribute{

}

//80
-(void) removeBulletinBoardAttributeInvalidName{

}

//81
-(void) removeBulletinBoardAttributeInvalidType{

}

//82
-(void) removeBulletinBoardAttributeTwice{

}

//83
- (void) updateNoteContent{

}

//84
- (void) updateNoteContentWithInvalidNoteID{

}

//85
- (void) updateNoteContentWithNilNoteID{

}

//86
- (void) updateNoteContentWithInvalidNewCotnent{

}

//87
- (void) updateNoteContentWithNilNewContnent{

}

//88
-(void) testRenameNoteAttribute{

}

//89
-(void) testRenameNoteAttributeInvalidOldName{

}

//90
-(void) testRenameNoteAttributeNilOldName{

}

//91
-(void) testRenameNoteAttributeInvalidAttributeType{

}

//92
-(void) testRenameNoteAttributeNilAttributeType{

}

//93
-(void) testRenameNoteAttributeInvalidNoteID{

}

//94
-(void) testRenameNoteAttributeNilNoteID{

}

//95
-(void) testRenameNoteAttributeNilNewAttributeName{

}

//96
-(void) testRenameNoteAttributeToSelf{

}
//97
-(void) testUpdateNoteAttribute{

}
//98
-(void) testUpdateNoteAttributeInvalidName{

}
//99
-(void) testUpdateNoteAttributeNilName{

}
//100
-(void) testUpdateNoteAttributeInvalidType{

}

//101
-(void) testUpdateNoteAttributeNilType{

}

//102
-(void) testUpdateNoteAttributeInvalidNoteID{

}

//103
-(void) testUpdateNoteAttributeNilNoteID{

}

//104
-(void) testUpdateNoteAttributeForNonExistingAttribute{

}

//105
-(void) testUpdateNoteAttributeWithEmptyOldValues{

}

//106
-(void) testUpdateNoteAttributeWithEmptyNewValues{

}

//107
-(void) testUpdateNoteAttributeWithOneValue{

}

//108
-(void) testUpdateNoteAttributeWithSameNewValues{

}

//109
-(void) testRenameBulletinBoardAttribute{

}

//110
-(void) testRenameBulletinBoardAttributeInvalidOldAttribute{

}

//111
-(void) testRenameBulletinBoardAttributeNilOldAttribute{

}

//112
-(void) testRenameBulletinBoardAttributeInvalidAttributeType{

}

//113
-(void) testRenameBulletinBoardAttributeNilAttributeType{

}

//114
-(void) testRenameBulletinBoardAttributeNilNewAttributeName{

}

//115
-(void) testRenameBulletinBoardAttributeNonExistingAttribute{

}

//116
-(void) testGetAllNotes{

}

//117
-(void) testGetAllNotesWithNoNote{

}

//118
-(void) testGetAllBulletinBoardAttributes{

}

//119
-(void) testGetAllBulletinBoardAttributesInvalidType{

}

//120
-(void) testGetAllBulletinBoardAttributesNilType{

}

//121
-(void) testGetAllBulletinBoardAttributesWithNoAttribute{

}

//122
-(void) testGetAllNoteAttributes{

}

//123
-(void) testGetAllNoteAttributesInvalidNoteID{

}

//124
-(void) testGetAllNoteAttributesNilNoteID{

}

//125
-(void) testGetAllNoteAttributesInvalidAttributeType{

}

//126
-(void) testGetAllNoteAttributesNilAttributeType{

}

//127
-(void) testGetAllNoteAttributesWithNoAttribute{

}

//128
-(void) testGetNoteContnet{

}

//129
-(void) testGetNoteContentInvalidNoteID{

}

//130
-(void) testGetNoteContentNilNoteID{

}

//140
-(void) testGetllAllNotesInBulletinBoardAttribute{

}

//141
-(void) testGetllAllNotesInBulletinBoardAttributeWithInvalidAttributeName{

}

//142
-(void) testGetllAllNotesInBulletinBoardAttributeWithNilAttributeName{

}

//143
-(void) testGetllAllNotesInBulletinBoardAttributeWhenAttributeDoesNotExist{

}

//144
-(void) testGetllAllNotesInBulletinBoardAttributeWithInvalidAttributeType{

}

//145
-(void) testGetllAllNotesInBulletinBoardAttributeWithNilAttributeType{

}

//146
-(void) testGetllAllNotesInBulletinBoardAttributeWithNoBulletinBoardAttribute{

}

//147
-(void) testGetAllNotesInNoteAttribute{

}

//148
-(void) testGetAllNotesInNoteAttributeInvalidNoteID{

}

//149
-(void) testGetAllNotesInNoteAttributeNilNoteID{

}

//150
-(void) testGetAllNotesInNoteAttributeInvalidAttributeName{

}

//151
-(void) testGetAllNotesInNoteAttributeNilAttributeName{

}

//152
-(void) testGetAllNotesInNoteAttributeWhenNoAttributeExist{

}

//153
-(void) testGetAllNotesInNoteAttributeInvalidAttributeType{

}

//154
-(void) testGetAllNotesInNoteAttributeWithNilAttributeType{

}

//155
-(void) testSaveBulletinBoard{

}

//156
-(void) testSynchrnization{

}

//157
-(void) testSynchrnoizationFlag{

}

//158
-(void) testBackToBackBulletinBoardCreation{


}

//159
-(void) testBackToBackBulletinBoardDeletion{

}

//160
-(void) testBackToBackBulletinBoardAttributeCreation{

}

//161
-(void) testBackToBackBulletinBoardAttributeUpdate{

}

//162
- (void) testBackToBackBulletinBoardAttributeRemove{

}

//163
-(void) testBackToBackBulletinBoardRemove{

}

//164
-(void) testBackToBackNoteCreation{

}

//165
-(void) testBackToBackNoteUpdate{

}

//166
-(void) testBackToBackNoteAttributeCreations{

}

//167
-(void) testBackToBackNoteAttributeUpdate{

}

//168
-(void) testBackToBackNoteAttributeRemove{

}

//169
-(void) testBackToBackNoteRemove{

}*/

@end
