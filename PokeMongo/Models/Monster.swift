//
//  Monster.swift
//  PokeYourMongo
//
//  Created by Floater on 8/13/16.
//  Copyright © 2016 WomenWhoCode. All rights reserved.
//

import UIKit
import SpriteKit

class Monster {
    
    var name: String
    var spriteArray = Array<SKTexture>();
    var hitColor: UIColor
    var node: SKSpriteNode?
    let minY: UInt32 = 100
    let minX: UInt32 = 0
    let maxY: UInt32
    let maxX: UInt32
    
    init(name: String,
         hitColor: UIColor,
         maxX: UInt32,
         maxY: UInt32) {
        
        self.name = name
        self.hitColor = hitColor
        self.maxX = maxX
        self.maxY = maxY
    }
    
    func configureMonster() {
        
        let textureAtlas = SKTextureAtlas(named:"\(name).atlas")
        
        // Programmatically add sprite animation
        spriteArray = [textureAtlas.textureNamed("\(name)1"),
                       textureAtlas.textureNamed("\(name)2")]
        
        node = SKSpriteNode(texture:spriteArray[0]);
        
        if let node = node {
            node.position = randomizePosition(fromPoint: CGPoint(x: 0, y: 800))
            node.zPosition = 2
            node.physicsBody = SKPhysicsBody(texture: node.texture!, size: node.frame.size)
            node.physicsBody?.isDynamic = true
            node.physicsBody?.affectedByGravity = false
            node.physicsBody?.allowsRotation = false
            node.physicsBody?.categoryBitMask = monsterMask
            node.physicsBody?.collisionBitMask = ballMask
            node.physicsBody?.contactTestBitMask = ballMask
            
            let scale = randomScale()
            node.xScale = scale;
            node.yScale = scale;
            
            startMovement()
        }
    }
    
    // MARK: - Actions
    
    func directHit() {
        if let node = node {
            node.removeAllActions()
            node.removeFromParent()
        }
    }
    
    func startMovement() {
        
        if let node = node {
            let moveSequence = SKAction.sequence([
                randomMoveAction(nearPoint: CGPoint(x: 200, y: 850)),
                randomMoveAction(nearPoint: CGPoint(x: -200, y: 600)),
                randomMoveAction(nearPoint: CGPoint(x: -50, y: 1200)),
                randomMoveAction(nearPoint: CGPoint(x: 100, y: 700)),
                randomMoveAction(nearPoint: CGPoint(x: 250, y: 200))])
            let repeatMoves = SKAction.repeatForever(moveSequence)
            node.run(repeatMoves)
            
            let animateAction = SKAction.animate(with: spriteArray, timePerFrame: 0.20);
            let repeatAnimation = SKAction.repeatForever(animateAction)
            node.run(repeatAnimation)
        }
    }

    func stopMovement() {
        node?.removeAllActions()
    }
    
    // MARK: - Random functions
    
    func randomMoveAction(nearPoint point: CGPoint) -> SKAction {
        return SKAction.move(to: randomizePosition(fromPoint: point), duration: 1.0)
    }
    
    func randomScale() -> CGFloat {
        
        // Number between 0.3 and 1.3
        let scale = (CGFloat(arc4random()) /  CGFloat(UInt32.max)) + 0.3
        print("scale: \(scale)")
        return scale
    }

    func randomizePosition(fromPoint point: CGPoint) -> CGPoint {
        
        let randomX = randomCGFloat(starting: CGFloat(point.x), ending: CGFloat(point.x + 50))
        let randomY = randomCGFloat(starting: CGFloat(point.y), ending: CGFloat(point.y + 50))
        
        print("randomPoint: \(randomX),\(randomY)")
        return CGPoint(x: CGFloat(randomX), y: CGFloat(randomY))
    }
    
    func randomCGFloat(starting: CGFloat, ending: CGFloat ) -> CGFloat
    {
        var offset: CGFloat = 0
        
        if starting < 0   // allow negative ranges
        {
            offset = fabs(starting)
        }
        
        let min = UInt32(starting + offset)
        let max = UInt32(ending  + offset)
        
        return CGFloat(min + arc4random_uniform(max - min)) - offset
    }
    
    // MARK: - Static factory functions
    
    static func allMonsters(_ screenHeight: UInt32, screenWidth: UInt32) -> [Monster] {
        
        let blueMonster = Monster(name: "BlueMonster",
                                  hitColor: UIColor.blue,
                                  maxX: screenWidth/2,
                                  maxY: screenHeight)
        let purpleMonster = Monster(name: "PurpleMonster",
                                    hitColor: UIColor.purple,
                                    maxX: screenWidth/2,
                                    maxY: screenHeight)
        let blackMonster = Monster(name: "BlackMonster",
                                   hitColor: UIColor.black,
                                   maxX: screenWidth/2,
                                   maxY: screenHeight)
        let greenMonster = Monster(name: "GreenMonster",
                                   hitColor: UIColor.green,
                                   maxX: screenWidth/2,
                                   maxY: screenHeight)
        
        return [blueMonster, purpleMonster, blackMonster, greenMonster]
    }
}
