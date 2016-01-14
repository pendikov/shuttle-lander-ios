//
//  Explosion.m
//  ShuttleLander
//
//  Created by Daniil Pendikov on 20/09/15.
//  Copyright (c) 2015 ltst. All rights reserved.
//

#import "Explosion.h"

@implementation Explosion {
    NSArray *_textures;
}

-(instancetype)init {
    if (self = [super initWithColor:[SKColor clearColor] size:CGSizeMake(190, 150)]) {
        NSMutableArray *textures = [[NSMutableArray alloc]init];
        for (int i=0; i<17; i++) {
            NSString *filename = [NSString stringWithFormat:@"frame_%d.gif", i];
            SKTexture *texture = [SKTexture textureWithImageNamed:filename];
            NSAssert(texture, @"texture must not be nil");
            [textures addObject:texture];
        }
        _textures = textures;        
    }
    return self;
}

-(void)animate {
    [self runAction:[SKAction animateWithTextures:_textures timePerFrame:1.0/17]];
}

@end
