//
//  NIMMessageModel.m
//  NIMKit
//
//  Created by NetEase.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "NIMMessageModel.h"
#import "NIMKit.h"
#import "NIMKitQuickCommentUtil.h"

@implementation NIMLinkModel

@end

@interface NIMMessageModel()

@property (nonatomic,strong) NSMutableDictionary *contentSizeInfo;
@property (nonatomic,strong) NSMutableDictionary *replyContentSizeInfo;

@end

static NSRegularExpression *linkRegex; //= [[NSRegularExpression alloc] initWithPattern:@"\\[.*?\\]\\((.*?)\\)" options:NSRegularExpressionCaseInsensitive error:nil];
static NSRegularExpression *titleRegex;// = [[NSRegularExpression alloc] initWithPattern:@"\\[(.*?)\\]" options:NSRegularExpressionCaseInsensitive error:nil];

@implementation NIMMessageModel

@synthesize contentViewInsets  = _contentViewInsets;
@synthesize bubbleViewInsets   = _bubbleViewInsets;
@synthesize replyContentViewInsets  = _replyContentViewInsets;
@synthesize replyBubbleViewInsets   = _replyBubbleViewInsets;
@synthesize shouldShowAvatar   = _shouldShowAvatar;
@synthesize shouldShowNickName = _shouldShowNickName;
@synthesize shouldShowLeft     = _shouldShowLeft;
@synthesize avatarMargin       = _avatarMargin;
@synthesize nickNameMargin     = _nickNameMargin;
@synthesize avatarSize         = _avatarSize;
@synthesize repliedMessage     = _repliedMessage;
@synthesize parentMessage      = _parentMessage;



- (instancetype)initWithMessage:(NIMMessage*)message
{
    if (self = [self init])
    {
        _message = message;
        _messageTime = message.timestamp;
        _contentSizeInfo = [[NSMutableDictionary alloc] init];
        _replyContentSizeInfo = [NSMutableDictionary dictionary];
        _enableRepliedContent = YES;
        _enableQuickComments = YES;
        _shouldShowPinContent = YES;
        _enableSubMessages = YES;
    }
    [self updateLinks];
    return self;
}

- (void) updateLinks {
    if (linkRegex == nil) {
        linkRegex = [[NSRegularExpression alloc] initWithPattern:@"\\[.*?\\]\\((.*?)\\)" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    if (titleRegex == nil) {
        titleRegex = [[NSRegularExpression alloc] initWithPattern:@"\\[(.*?)\\]" options:NSRegularExpressionCaseInsensitive error:nil];
    }
    NSString *text = self.message.text;
    NSMutableArray *link = [NSMutableArray array];
    while (TRUE) {
        NSTextCheckingResult *result = [[linkRegex matchesInString:text options:0 range:NSMakeRange(0, text.length)] firstObject];
        if (result == NULL) {
            break;
        }
        NSTextCheckingResult *titleResult = [[titleRegex matchesInString:text options:0 range: result.range] firstObject];
        if (titleResult == NULL) {
            break;
        }   
        NSString *linkValue = [text substringWithRange: [result rangeAtIndex:1]];
        NSString *title = [text substringWithRange: [titleResult rangeAtIndex:1]];
        text = [text stringByReplacingCharactersInRange:result.range withString:title];
        NIMLinkModel *model = [[NIMLinkModel alloc] init];
        model.title = title;
        model.linkValue = linkValue;
        model.range = NSMakeRange(result.range.location, title.length);
        [link addObject:model];
    }
    _links = link;
    _message.text = text;
}

- (void)cleanCache
{
    [_contentSizeInfo removeAllObjects];
    _contentViewInsets = UIEdgeInsetsZero;
    _bubbleViewInsets = UIEdgeInsetsZero;
    _replyContentViewInsets = UIEdgeInsetsZero;
    _replyBubbleViewInsets = UIEdgeInsetsZero;
}

- (NSString*)description{
    return self.message.text;
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[NIMMessageModel class]])
    {
        return NO;
    }
    else
    {
        NIMMessageModel *model = object;
        return [self.message isEqual:model.message];
    }
}

- (CGSize)contentSize:(CGFloat)width
{
    CGSize size = [self.contentSizeInfo[@(width)] CGSizeValue];
    if (CGSizeEqualToSize(size, CGSizeZero))
    {
        [self updateLayoutConfig];
        id<NIMCellLayoutConfig> layoutConfig = [[NIMKit sharedKit] layoutConfig];
        size = [layoutConfig contentSize:self cellWidth:width];
        [self.contentSizeInfo setObject:[NSValue valueWithCGSize:size] forKey:@(width)];
    }
    return size;
}


- (UIEdgeInsets)contentViewInsets{
    if (UIEdgeInsetsEqualToEdgeInsets(_contentViewInsets, UIEdgeInsetsZero))
    {
        id<NIMCellLayoutConfig> layoutConfig = [[NIMKit sharedKit] layoutConfig];
        _contentViewInsets = [layoutConfig contentViewInsets:self];
    }
    return _contentViewInsets;
}

- (UIEdgeInsets)bubbleViewInsets{
    if (UIEdgeInsetsEqualToEdgeInsets(_bubbleViewInsets, UIEdgeInsetsZero))
    {
        id<NIMCellLayoutConfig> layoutConfig = [[NIMKit sharedKit] layoutConfig];
        _bubbleViewInsets = [layoutConfig cellInsets:self];
    }
    return _bubbleViewInsets;
}

- (CGSize)replyContentSize:(CGFloat)width
{
    id<NIMCellLayoutConfig> layoutConfig = [[NIMKit sharedKit] layoutConfig];
    CGSize size = [layoutConfig replyContentSize:self cellWidth:width];
    return size;
}

- (UIEdgeInsets)replyContentViewInsets{
    if (UIEdgeInsetsEqualToEdgeInsets(_replyContentViewInsets, UIEdgeInsetsZero))
    {
        id<NIMCellLayoutConfig> layoutConfig = [[NIMKit sharedKit] layoutConfig];
        _replyContentViewInsets = [layoutConfig replyContentViewInsets:self];
    }
    return _replyContentViewInsets;
}

- (UIEdgeInsets)replyBubbleViewInsets{
    if (UIEdgeInsetsEqualToEdgeInsets(_replyBubbleViewInsets, UIEdgeInsetsZero))
    {
        id<NIMCellLayoutConfig> layoutConfig = [[NIMKit sharedKit] layoutConfig];
        _replyBubbleViewInsets = [layoutConfig replyCellInsets:self];
    }
    return _replyBubbleViewInsets;
}


- (void)updateLayoutConfig
{
    id<NIMCellLayoutConfig> layoutConfig = [[NIMKit sharedKit] layoutConfig];
    
    _shouldShowAvatar       = [layoutConfig shouldShowAvatar:self];
    _shouldShowNickName     = _focreShowNickName ? YES : [layoutConfig shouldShowNickName:self];
    _shouldShowLeft         = _focreShowLeft ? YES : [layoutConfig shouldShowLeft:self];
    _avatarMargin           = [layoutConfig avatarMargin:self];
    _nickNameMargin         = [layoutConfig nickNameMargin:self];
    _avatarSize             = [layoutConfig avatarSize:self];
}


- (BOOL)shouldShowReadLabel
{
    if (self.message.session.sessionType == NIMSessionTypeP2P)
    {
        return _shouldShowReadLabel && self.message.isRemoteRead;
    }
    else if (self.message.session.sessionType == NIMSessionTypeSuperTeam) { //超大群这个功能还没做
        return NO;
    }
    else
    {
        return _shouldShowReadLabel;
    }
    
}

- (BOOL)needShowReplyCountContent
{
    return self.enableSubMessages;
}

- (BOOL)needShowRepliedContent
{
    BOOL should = self.message.messageType == NIMMessageTypeTip;
    return !should && self.enableRepliedContent &&
    self.message.repliedMessageId.length > 0;
}

- (BOOL)needShowEmoticonsView
{
    return self.enableQuickComments && !CGSizeEqualToSize(CGSizeZero, self.emoticonsContainerSize);
}

- (void)quickComments:(NIMMessage *)message
           completion:(void(^)(NSMapTable *))completion
{
    [[NIMSDK sharedSDK].chatExtendManager quickCommentsByMessage:message
                                                      completion:^(NSError * _Nullable error, NSMapTable<NSNumber *,NIMQuickComment *> * _Nullable result)
    {
        if (completion)
        {
            if (result.count > 0)
            {
                _emoticonsContainerSize = [NIMKitQuickCommentUtil containerSizeWithComments:result];
            }
            completion(result);
        }
    }];
}

@end
