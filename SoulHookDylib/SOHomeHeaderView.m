//
//  SOHomeHeaderView.m
//  SoulHookDylib
//
//  Created by fan on 2019/7/21.
//  Copyright © 2019 fancy. All rights reserved.
//

#import "SOHomeHeaderView.h"
#import "SoulHeader.h"

@interface SOHomeHeaderView ()

@property(nonatomic, strong) UIImageView *bgImageView;
@property(nonatomic, strong) UIImageView *avatarView;
@property(nonatomic, strong) UIButton *nameButton;
@property(nonatomic, strong) UILabel *infoLabel;
@property(nonatomic, strong) UILabel *tagLabel;
@property(retain, nonatomic) UIButton *kkqView; // KuaKuaWallView
@property(retain, nonatomic) UIButton *myMeetingView; // SoulMeetingView

@property(nonatomic, assign) CGFloat statuBarH;
@property(nonatomic, assign) CGFloat screenW;
@property(nonatomic, assign) CGFloat changed;

@end

@implementation SOHomeHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self addSubviews];
    }
    return self;
}

- (void)addSubviews {
    self.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:self.nameButton];
    [self addSubview:self.infoLabel];
    [self addSubview:self.tagLabel];
    [self addSubview:self.kkqView];
    [self addSubview:self.myMeetingView];
    
    [self addSubview:self.bgImageView];
    [self addSubview:self.avatarView];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataNoti:) name:SOHOOK_NOTIFICATION_USER_DATA object:nil];
}

- (void)dataNoti:(NSNotification *)noti {
    NSDictionary *data = noti.object;
    
    NSLog(@"收到通知");
    
    if (!self.bgImageView.image) {
        UIImage *bgImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:data[@"userBackgroundUrlNew"]]]];
        
        self.bgImageView.image = bgImage;
    }
    
    if (!self.avatarView.image) {
        NSString *avatarStr = [NSString stringWithFormat:@"%@%@.png", @"https://img.soulapp.cn/heads/", data[@"oriAvatarName"]];
        UIImage *avatarImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:avatarStr]]];
        
        self.avatarView.image = avatarImage;
    }
    
    [self.nameButton setTitle:data[@"signature"] forState:UIControlStateNormal];
    
    CGRect nameFrame = self.nameButton.frame;
    nameFrame.size.width = [self.nameButton sizeThatFits:CGSizeMake(self.screenW - 40, MAXFLOAT)].width;
    self.nameButton.frame = nameFrame;
    
    self.infoLabel.text = [NSString stringWithFormat:@"%@天,%@条瞬间", data[@"registerDay"], data[@"postCount"]];
    NSMutableString *tag = [NSMutableString string];
 
    if ([data[@"privacyTagModelList"] isKindOfClass:NSArray.class]) {
        NSArray *tags = data[@"privacyTagModelList"];
        [tags enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [tag appendString:obj[@"tagName"]];
            if (tags.count - 1 != idx ) {
                [tag appendString:@"、"];
            }
        }];
        
        self.tagLabel.text = tag;
    }
 
    [self.myMeetingView setTitle:[NSString stringWithFormat:@"来访：%@", data[@"recentViewNum"]] forState:UIControlStateNormal];
    
    [self configViewWithOffset:0];
}

- (void)configViewWithOffset:(CGFloat)offset {
    if (offset <= 0) {
        self.bgImageView.frame = CGRectMake(offset * 0.5, offset - 20, self.screenW - offset, 44 + self.statuBarH + 120 - offset);
        self.avatarView.frame = CGRectMake(20, 44 + self.statuBarH + 60, 80, 80);
        self.avatarView.layer.cornerRadius = 40;
    } else if (offset < 100) {
        CGFloat x = 20 + offset * 0.4 * 0.5;
        CGFloat y = 44 + self.statuBarH + 60 + offset * 0.45;
        CGFloat w = 80 - offset * 0.4;
    
        self.avatarView.frame = CGRectMake(x, y, w, w);
        self.avatarView.layer.cornerRadius = w / 2;
        
        if (self.changed) {
            [self exchangeSubviewAtIndex:5 withSubviewAtIndex:6];
            self.changed = NO;
        }
        
    } else if (offset >= 100) {
        if (!self.changed) {
            [self exchangeSubviewAtIndex:5 withSubviewAtIndex:6];
            self.changed = YES;
        }
        CGRect frame = self.bgImageView.frame;
        frame.origin.y = offset - 120;
        
        self.bgImageView.frame = frame;
    }
}

#pragma mark - Action
- (void)gestureAction:(UITapGestureRecognizer *)sender {
    switch (sender.view.tag) {
        case 2000:
            !self.bgBlock ? : self.bgBlock();
            break;
            
        case 2001:
            !self.avatarBlock ? : self.avatarBlock();
            break;
            
        case 2002:
            !self.tagBlock ? : self.tagBlock();
            break;
    }
}

- (void)buttonAction:(UIButton *)sender {
    switch (sender.tag) {
        case 1000:
            !self.nameBlock ? : self.nameBlock();
            break;
            
        case 1001:
            !self.kkBlock ? : self.kkBlock();
            break;
            
        case 1002:
            !self.visitBlock ? : self.visitBlock();
            break;
    }
}


- (CGSize)sizeThatFits:(CGSize)size {
    return CGSizeMake(self.screenW, self.tagLabel.frame.origin.y + self.tagLabel.frame.size.height + 20);
}

#pragma mark - Get
- (UIImageView *)bgImageView {
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.frame = CGRectMake(0, -20, self.screenW, 44 + self.statuBarH + 120);
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.userInteractionEnabled = YES;
        _bgImageView.clipsToBounds = YES;
        _bgImageView.tag = 2000;
        [_bgImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction:)]];
    }
    return _bgImageView;
}

- (UIImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[UIImageView alloc] init];
        _avatarView.frame = CGRectMake(20, 44 + self.statuBarH + 60, 80, 80);
        _avatarView.contentMode = UIViewContentModeScaleAspectFill;
        _avatarView.layer.cornerRadius = 40;
        _avatarView.layer.masksToBounds = YES;
        _avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
        _avatarView.layer.borderWidth = 2;
        _avatarView.userInteractionEnabled = YES;
        _avatarView.tag = 2001;
        [_avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction:)]];
    }
    return _avatarView;
}

- (UIButton *)nameButton {
    if (!_nameButton) {
        _nameButton = [[UIButton alloc] init];
        _nameButton.frame = CGRectMake(20, 44 + self.statuBarH + 150, 0, 20);
        _nameButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:15];
        [_nameButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _nameButton.tag = 1000;
        [_nameButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nameButton;
}

- (UILabel *)infoLabel {
    if (!_infoLabel) {
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.frame = CGRectMake(20, 44 + self.statuBarH + 180, 200, 20);
        _infoLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        _infoLabel.textColor = [UIColor blackColor];
        _infoLabel.userInteractionEnabled = YES;
        _infoLabel.tag = 2002;
        [_infoLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureAction:)]];
    }
    return _infoLabel;
}

- (UILabel *)tagLabel {
    if (!_tagLabel) {
        _tagLabel = [[UILabel alloc] init];
        _tagLabel.frame = CGRectMake(20, 44 + self.statuBarH + 210, self.screenW - 40, 20);
        _tagLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        _tagLabel.textColor = [UIColor blackColor];
    }
    return _tagLabel;
}

- (UIButton *)kkqView {
    if (!_kkqView) {
//        Class clz = NSClassFromString(@"KuaKuaWallView");
//        _kkqView = [[clz alloc] init];
//        _kkqView.frame = CGRectMake(120, 44 + self.statuBarH + 120, 80, 44);
        _kkqView = [[UIButton alloc] init];
        [_kkqView setTitle:@"夸夸墙" forState:UIControlStateNormal];
        [_kkqView setTitleColor:SO_THEME_COLOR forState:normal];
        _kkqView.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        _kkqView.layer.cornerRadius = 15;
        _kkqView.layer.masksToBounds = YES;
        _kkqView.layer.borderWidth = 1;
        _kkqView.layer.borderColor = SO_THEME_COLOR.CGColor;
        _kkqView.frame = CGRectMake(120, 44 + self.statuBarH + 110, 60, 30);
        _kkqView.tag = 1001;
        [_kkqView addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _kkqView;
}

- (UIButton *)myMeetingView {
    if (!_myMeetingView) {
//        Class clz = NSClassFromString(@"SoulMeetingView");
//        _myMeetingView = [[clz alloc] init];
//        _myMeetingView.frame = CGRectMake(220, 44 + self.statuBarH + 110, 50, 32);
        _myMeetingView = [[UIButton alloc] init];
        [_myMeetingView setTitle:@"来访：0" forState:UIControlStateNormal];
        [_myMeetingView setTitleColor:SO_THEME_COLOR forState:normal];
        _myMeetingView.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
        _myMeetingView.layer.cornerRadius = 15;
        _myMeetingView.layer.masksToBounds = YES;
        _myMeetingView.layer.borderWidth = 1;
        _myMeetingView.layer.borderColor = SO_THEME_COLOR.CGColor;
        _myMeetingView.frame = CGRectMake(190, 44 + self.statuBarH + 110, 80, 30);
        _myMeetingView.tag = 1002;
        [_myMeetingView addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _myMeetingView;
}

- (CGFloat)screenW {
    return [UIScreen mainScreen].bounds.size.width;
}

- (CGFloat)statuBarH {
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

@end
