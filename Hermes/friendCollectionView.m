//
//  friendCollectionView.m
//  Hermes
//
//  Created by Raylen Margono on 3/29/15.
//  Copyright (c) 2015 Raylen Margono. All rights reserved.
//

#import "friendCollectionView.h"

@implementation friendCollectionView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [self initialization];
        self.frame = CGRectMake(0, -800, self.bounds.size.width, self.bounds.size.height);
    }
    
    return self;
}

-(void)initialization{
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    CGRect aRect = CGRectMake(0, 100, screenWidth, screenHeight-100);
    //setup collectionview
    UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
    //add blurredView
    self.blurMask = [[UIImageView alloc]initWithFrame:self.frame];
    //set up friendlabels
    UITextField *friendText = [[UITextField alloc]initWithFrame:CGRectMake(self.frame.size.width/2-42, 20, 100, 100)];
    friendText.text = @"Friends";
    friendText.textAlignment = NSTextAlignmentCenter;
    [friendText setEnabled:NO];
    [friendText setTextColor:[UIColor blackColor]];
    friendText.font = [UIFont fontWithName:@"SackersGothicLightAT" size:20 ];
    //add button
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 28, 70, 80)];
    [backButton setTitle:@"back" forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    backButton.titleLabel.font = [UIFont fontWithName:@"SackersGothicLightAT" size:16 ];
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //set up friend button
    self.friendButton = [[UIButton alloc]initWithFrame:CGRectMake(self.frame.size.width-80, 45, 50, 50)];
    [self.friendButton setTitle:@"+" forState:UIControlStateNormal];
    [self.friendButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.friendButton.titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
    [self.friendButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.friendButton addTarget:self action:@selector(segueToFriendSearch:) forControlEvents:
     UIControlEventTouchUpInside];
    self.friendButton.titleLabel.font = [UIFont fontWithName:@"SackersGothicLightAT" size:20 ];


    //setup collectionview
    _collectionView=[[UICollectionView alloc] initWithFrame:aRect collectionViewLayout:layout];
    [_collectionView setDataSource:self];
    [_collectionView setDelegate:self];
    
    [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    [_collectionView setBackgroundColor:[UIColor clearColor] ];
    [self addSubview:self.blurMask];
    [self addSubview:self.collectionView];
    [self addSubview:friendText];
    [self addSubview:self.friendButton];
    [self addSubview:backButton];
    [self getFriends];
}

-(void)backAction:(id)sender{
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = CGRectMake(0, -800, self.bounds.size.width, self.bounds.size.height);
    }completion:^(BOOL finished) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refresh" object:nil];
    }];
}

-(void)getFriends{
    //query all of users friends
    PFRelation *relation = [[PFUser currentUser] relationForKey:@"friends"];
    PFQuery *query = [relation query];
    [query orderByAscending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        dispatch_queue_t myQueue = dispatch_queue_create("My Queue",NULL);
        dispatch_async(myQueue, ^{
            // Perform long running process
            self.allUsers = objects;
            PFUser *allUsers = [[PFUser alloc]init];
            self.users = [[NSMutableArray alloc]init];
            NSMutableArray *userArray=[[NSMutableArray alloc]init];
            [userArray addObject:allUsers];
            for (PFUser *user in objects) {
                if (userArray.count==3) {
                    [self.users addObject:userArray];
                    userArray=[[NSMutableArray alloc]init];
                }
                [userArray addObject:user];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.users addObject:userArray];
                [self.collectionView reloadData];
            });
        });
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *userInSection = [self.users objectAtIndex:section];
    return userInSection.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.users count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    CollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if (indexPath.section==0&&indexPath.row==0) {
        UIImage *image = [UIImage imageNamed:@"icon"];
        cell.imageView.image=image;
    }else{
        PFUser *user = [self.users[indexPath.section] objectAtIndex:indexPath.row];
        PFFile *file = user[@"profilePhoto"];
        if (file) {
            [user[@"profilePhoto"] getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error) {
                    UIImage *image = [UIImage imageWithData:data];
                    // image can now be set on a UIImageView
                    cell.imageView.image = image;
                }
            }];
        }
        NSMutableArray *array = [self.delegate.unseenPostCenter objectForKey:user.objectId];
        if (array.count>0) {
            cell.newPostField.hidden= NO;
            NSMutableArray *temp = [self.delegate.unseenPostCenter objectForKey:user.objectId];
            cell.newPostField.text = [NSString stringWithFormat:@"%lu",(unsigned long)temp.count];
        }
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(100, 100);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [UIView animateWithDuration:0.5f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.frame = CGRectMake(0, -800, self.bounds.size.width, self.bounds.size.height);
    }completion:^(BOOL finished) {
        if (indexPath.section==0&&indexPath.row==0) {
            self.userArray = [[NSMutableArray alloc]initWithArray: self.allUsers];
        }else{
            self.userArray = [[NSMutableArray alloc]init];
            PFUser *user = [self.users[indexPath.section] objectAtIndex:indexPath.row];
            [self.userArray addObject:user];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"newUser" object:nil];
    }];
   

}

#pragma mark collection view cell paddings
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5.0f, 5.0f, 5.0f, 0.0f); // top, left, bottom, right
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 7.0;
}

-(NSMutableArray *)returnSelectedUser:(PFUser *)user{
    return self.userArray;
}

-(void)reloadData{
    [self.collectionView reloadData];
}

-(void)segueToFriendSearch:(id)sender{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"segueToFriendSearch" object:nil];
}

-(void)moveToView:(id)sender{
    self.blurMask.image = (UIImage *)sender;
    
    [UIView animateWithDuration:0.3
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^
     {
         self.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
     }
                     completion:^(BOOL finished)
     {
     }];
}


@end
