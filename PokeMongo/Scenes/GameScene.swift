//
//  GameScene.swift
//  PokeMongo
//
//  Created by Floater on 8/21/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import SpriteKit
import GameplayKit

// Define our bitmask categories
let ballMask: UInt32 = 0x1 << 0 //1
let monsterMask: UInt32 = 0x1 << 1 //2

class GameScene: SKScene {
    
    // Define nodes used in the game
    var ball: SKSpriteNode?
    var monster: SKSpriteNode?
    
    // Label for displaying contextual information to the user
    var titleLabel : SKLabelNode?

    // Holds last touch event locations
    var startTouchLocation: CGPoint = CGPoint.zero
    var endTouchLocation: CGPoint = CGPoint.zero

    override func sceneDidLoad() {
        
        // Get label node from scene and store it for use later
        self.titleLabel = self.childNode(withName: "//helloLabel") as? SKLabelNode
        titleLabel?.isHidden = true

        self.physicsWorld.contactDelegate = self
        
        // Add a ball to the scene
        if ball == nil {
            createBall()
        }
        
        if monster == nil {
            createMonster()
        }
    }
    
    // MARK: - Touch gesture methods
    
    /**
     *  Called when a touch event is initiated.
     */
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Record the beginning of the touch event
        startTouchLocation = touches.first!.location(in: self)
        
        checkPhysics()
    }
    
    /**
     *  Called when a touch event moves.
     */
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Move the ball along with the user's touch gesture
        let currentTouchLocation = touches.first!.location(in: self)
        if let ball = ball {
            ball.position = currentTouchLocation
        }
    }
    
    /**
     *  Called when a touch event is ended.
     */
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Record the end of the touch event
        endTouchLocation = touches.first!.location(in: self)
        
        // Continue the ball's movement along the same path as the touch gesture
        let factor: CGFloat = 50
        let vector = CGVector(dx: factor * (endTouchLocation.x - startTouchLocation.x), dy: factor * (endTouchLocation.y - startTouchLocation.y))
        ball?.physicsBody?.applyImpulse(vector)
    }
    
    /**
     *  Called before each frame is rendered.
     */
    override func update(_ currentTime: TimeInterval) {
        
        // Check to see if the ball node has left the scene bounds
        if let ball = ball {
            if (ball.position.x > self.size.width/2 + ball.size.width/2 ||
                ball.position.x < -(self.size.width/2 + ball.size.width/2) ||
                ball.position.y > self.size.height + ball.size.height) {
                
                // The ball is outside the bounds of the visible view
                resetBall()
            }
        }
    }
    
    // MARK: - Ball node methods
    
    /**
     * Create a ball node and add it to the scene.
     */
    func createBall() {
        
        // Create the ball node
        ball = SKSpriteNode(imageNamed: "Ball")
        if let ball = ball {
            
            ball.name = "Ball"
            
            // Add physics
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width/2)
            ball.physicsBody?.isDynamic = true
            ball.physicsBody?.affectedByGravity = false
            ball.physicsBody?.allowsRotation = false
            ball.physicsBody?.mass = 50

            // Set position and scale
            ball.position = CGPoint(x: 0, y: 100)
            ball.zPosition = 2
            ball.scale(to: CGSize(width: 50, height: 50))
        
            // Define contacts and collisions
            ball.physicsBody?.categoryBitMask = ballMask
            ball.physicsBody?.collisionBitMask = monsterMask
            ball.physicsBody?.contactTestBitMask = monsterMask
            
            // Add to the scene
            addChild(ball)
            
            // Display a spark particle when the ball is placed in the scene
            let spark:SKEmitterNode = SKEmitterNode(fileNamed: "MagicParticle")!
            spark.position = ball.position
            self.addChild(spark)
        }
    }
    
    /**
     * Reset the ball to the default position.
     */
    func resetBall() {
        
        // Remove the current ball from the scene
        ball?.removeAllActions()
        ball?.removeFromParent()
        ball = nil
        
        // Reset touch locations
        startTouchLocation = CGPoint.zero
        endTouchLocation = CGPoint.zero
        
        // Create a new ball and add to the scene
        createBall()
    }
    
    // MARK: - Monster functions
    
    func createMonster() {
        
        let textureAtlas = SKTextureAtlas(named: "PurpleMonster.atlas")
        let spriteArray = [textureAtlas.textureNamed("PurpleMonster1"), textureAtlas.textureNamed("PurpleMonster2")]
        monster = SKSpriteNode(texture: spriteArray[0])
        
        if let monster = self.monster {
            
            monster.name = "Monster"
            
            monster.position = CGPoint(x: 0, y: frame.height/2)
            monster.zPosition = 2
            
            monster.physicsBody = SKPhysicsBody(texture: monster.texture!, size: monster.frame.size)
            monster.physicsBody?.isDynamic = true
            monster.physicsBody?.affectedByGravity = false
            monster.physicsBody?.allowsRotation = false
            
            monster.physicsBody?.categoryBitMask = monsterMask
            monster.physicsBody?.collisionBitMask = ballMask
            monster.physicsBody?.contactTestBitMask = ballMask
            
            moveMonster()
            
            let animateAction = SKAction.animate(with: spriteArray, timePerFrame: 0.2)
            let repeatAnimation = SKAction.repeatForever(animateAction)
            monster.run(repeatAnimation)
            
            addChild(monster)
        }
    }
    
    func moveMonster() {
        
        if let monster = self.monster {
            
            let moveRight = SKAction.move(to: CGPoint(x: self.size.width/2, y: self.size.height/2), duration: 1.0)
            let moveLeft = SKAction.move(to: CGPoint(x: -(self.size.width/2), y: self.size.height/2), duration: 1.0)
            let moveSequence = SKAction.sequence([moveLeft, moveRight])
            
            let repeatMovesForever = SKAction.repeatForever(moveSequence)
            monster.run(repeatMovesForever)
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if let monster = self.monster {
            
            monster.removeAllActions()
            monster.removeFromParent()
            self.monster = nil

            let spark: SKEmitterNode = SKEmitterNode(fileNamed: "SparkParticle")!
            spark.position = monster.position
            spark.particleColor = UIColor.purple
            addChild(spark)
            
            self.resetBall()

            let delayTime = DispatchTime.now() + 1.0
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
             
                if self.monster == nil {
                    self.createMonster()
                }
            }
        }
    }
    
    //MARK: - Analyse the collision/contact set up.
    func checkPhysics() {
        
        // Create an array of all the nodes with physicsBodies
        var physicsNodes = [SKNode]()
        
        //Get all physics bodies
        enumerateChildNodes(withName: "//.") { node, _ in
            if let _ = node.physicsBody {
                physicsNodes.append(node)
            } else {
                print("\(node.name) does not have a physics body so cannot collide or be involved in contacts.")
            }
        }
        
        //For each node, check it's category against every other node's collion and contctTest bit mask
        for node in physicsNodes {
            let category = node.physicsBody!.categoryBitMask
            // Identify the node by its category if the name is blank
            let name = node.name != nil ? node.name : "Category \(category)"
            let collisionMask = node.physicsBody!.collisionBitMask
            let contactMask = node.physicsBody!.contactTestBitMask
            
            // If all bits of the collisonmask set, just say it collides with everything.
            if collisionMask == UInt32.max {
                print("\(name) collides with everything")
            }
            
            for otherNode in physicsNodes {
                if (node != otherNode) && (node.physicsBody?.isDynamic == true) {
                    let otherCategory = otherNode.physicsBody!.categoryBitMask
                    // Identify the node by its category if the name is blank
                    let otherName = otherNode.name != nil ? otherNode.name : "Category \(otherCategory)"
                    
                    // If the collisonmask and category match, they will collide
                    if ((collisionMask & otherCategory) != 0) && (collisionMask != UInt32.max) {
                        print("\(name) collides with \(otherName)")
                    }
                    // If the contactMAsk and category match, they will contact
                    if (contactMask & otherCategory) != 0 {print("\(name) notifies when contacting \(otherName)")}
                }
            }
        }  
    }
}
