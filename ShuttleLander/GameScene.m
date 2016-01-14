//
//  GameScene.m
//  ShuttleLander
//
//  Created by Daniil Pendikov on 20/09/15.
//  Copyright (c) 2015 ltst. All rights reserved.
//

#import "GameScene.h"
#import "Shuttle.h"
#import "Explosion.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_HALF_WIDTH 0.5 * [UIScreen mainScreen].bounds.size.width
#define SCREEN_HALF_HEIGHT 0.5 * [UIScreen mainScreen].bounds.size.height

#define SHUTTLE_WIDTH _shuttle.frame.size.widht
#define SHUTTLE_HEIGHT _shuttle.frame.size.height
#define SHUTTLE_SCALE 0.15
#define SHUTTLE_SPEED 5
#define SHUTTLE_PLUS_ACCELERATION 0.21
#define SHUTTLE_MINUS_ACCELERATION 0.1

typedef NS_ENUM(NSUInteger, GameState) {
    GameStateIsNotPlaying,
    GameStateIsPlaying
};

@implementation GameScene {
    Shuttle *_shuttle;
    GameState _gameState;
    BOOL _gameStarted;
    BOOL _isTouching;
    
    CGFloat _plusAcceleration;
    CGFloat _minusAcceleration;
    
    SKLabelNode *_fuelLabel;
    SKLabelNode *_scoreLabel;
    
    CGFloat _fuel;
    NSInteger _successfulLandings;
    NSInteger _totalLandings;
    
    Explosion *_explosion;
    
    CGPoint _lastTouchLocation;
    CGFloat _deltaX;
    CGFloat _deltaY;
}

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    [self setup];
}

-(void)setup {
    
    [self setupShuttle];
    [self setupUI];
    [self setupExplosion];
}

-(void)setupExplosion {
    _explosion = [[Explosion alloc]init];
    _explosion.position = CGPointMake(SCREEN_HALF_WIDTH, SCREEN_HALF_HEIGHT);
    _explosion.xScale = _explosion.yScale = 1;
    _explosion.hidden = YES;
    [self addChild:_explosion];
}

-(void)setupShuttle {
    _shuttle = [[Shuttle alloc]init];
    _shuttle.position = CGPointMake(SCREEN_HALF_WIDTH, SCREEN_HEIGHT + SHUTTLE_HEIGHT);
    _shuttle.xScale = _shuttle.yScale = SHUTTLE_SCALE;
    [self addChild:_shuttle];
    
    _fuel = 1;
}

-(void)setupUI {
    _fuelLabel = [[SKLabelNode alloc]initWithFontNamed:@"Helvetica-Neue"];
    _fuelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeRight;
    _fuelLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    _fuelLabel.fontSize = 20;
    _fuelLabel.position = CGPointMake(SCREEN_WIDTH - 10, SCREEN_HEIGHT - 10);
    [self addChild:_fuelLabel];
    
    _scoreLabel = [[SKLabelNode alloc]initWithFontNamed:@"Helvetica-Neue"];
    _scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    _scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeTop;
    _scoreLabel.fontSize = 20;
    _scoreLabel.position = CGPointMake(10, SCREEN_HEIGHT - 10);
    [self addChild:_scoreLabel];
}

-(void)startGameAfterDelay:(CGFloat)delay {
    if (_gameState == GameStateIsPlaying || _gameStarted) {
        return;
    }
    _gameStarted = YES;
    [self performSelector:@selector(doStartGame) withObject:nil afterDelay:delay];
}

-(void)doStartGame {
    _gameStarted = NO;
    _gameState = GameStateIsPlaying;
    _shuttle.position = CGPointMake(SCREEN_HALF_WIDTH, SCREEN_HEIGHT + SHUTTLE_HEIGHT);
    [_shuttle runAction:[SKAction rotateToAngle:0 duration:0]];
    
    _plusAcceleration = 0;
    _minusAcceleration = 0;
    _fuel = 1;
    
    _explosion.hidden = YES;
}

-(void)endGame {
    _gameState = GameStateIsNotPlaying;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _isTouching = YES;
    
    UITouch *touch = [touches anyObject];
    _lastTouchLocation = [touch locationInNode:self];
    _deltaX = 0;
    _deltaY = 0;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    CGPoint newLocation = [touch locationInNode:self];
    
    _deltaX = newLocation.x - _lastTouchLocation.x;
    _deltaY = newLocation.y - _lastTouchLocation.y;
    
    _lastTouchLocation = [touch locationInNode:self];
    
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    _isTouching = NO;
    _deltaX = 0;
    _deltaY = 0;
}

-(void)update:(CFTimeInterval)currentTime {
    
    if (_gameState == GameStateIsPlaying) {
        [self updateShuttlePosition];
    }
    
    [self updateGameState];
    [self updateUI];
}

-(void)updateGameState {
    if (_gameState == GameStateIsNotPlaying) {
        [self startGameAfterDelay:1];
    }
    if (_shuttle.position.y < SHUTTLE_HEIGHT * 0.5) {
        [self shuttleDidTouchGround];
    }
}

-(void)updateShuttlePosition {
    
    if (_fuel > 0) {
        [self updatePlusAcceleration];
    }
    
    double angle = atan2(_lastTouchLocation.y - _shuttle.position.y, _lastTouchLocation.x - _shuttle.position.x) + M_PI / 2;
    
    
    _minusAcceleration += SHUTTLE_MINUS_ACCELERATION;
    
    
    CGFloat incrementY = [self shuttleSpeed] + _plusAcceleration;
    CGFloat incrementX = 0;
    _shuttle.position = CGPointMake(_shuttle.position.x + incrementX, _shuttle.position.y + incrementY);
    
//    _shuttle.position = CGPointMake(SCREEN_HALF_WIDTH, SCREEN_HALF_HEIGHT);
    
    
    
    
//    [_shuttle runAction:[SKAction rotateToAngle:angle duration:0]];
}

-(void)updatePlusAcceleration {
    static BOOL wasTouching = NO;
    if (_isTouching) {
        _fuel -= 0.005;
        wasTouching = YES;
        _plusAcceleration += SHUTTLE_PLUS_ACCELERATION;
    } else {
        if (wasTouching) {
            _plusAcceleration = 0;
            _minusAcceleration = 0;
        }
        wasTouching = NO;
    }
}

-(void)updateUI {
    NSInteger percents = (NSInteger)(_fuel * 100);
    _fuelLabel.text = [NSString stringWithFormat:@"FUEL: %lu %%", percents];
    if (percents < 1) {
        _fuelLabel.fontColor = [SKColor redColor];
    } else {
        _fuelLabel.fontColor = [SKColor whiteColor];
    }
    
    _scoreLabel.text = [NSString stringWithFormat:@"%lu/%lu", _successfulLandings, _totalLandings];
}

-(CGFloat)shuttleSpeed {
    return - 1 * SHUTTLE_SPEED - _minusAcceleration;
}

-(void)shuttleDidTouchGround {
    if (_gameState != GameStateIsNotPlaying) {
        
        _totalLandings++;
        
        if (fabs([self shuttleSpeed] + _plusAcceleration) <= 1.8) {
            NSLog(@"success");
            _successfulLandings++;
        } else {
            _explosion.position = CGPointMake(_shuttle.position.x + 45, _shuttle.position.y+19);
            _explosion.hidden = NO;
            [_explosion animate];
        }
        
        [self endGame];
    }
}

@end
