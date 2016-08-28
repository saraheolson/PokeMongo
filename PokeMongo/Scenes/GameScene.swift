//
//  GameScene.swift
//  PokeMongo
//
//  Created by Floater on 8/21/16.
//  Copyright © 2016 SarahEOlson. All rights reserved.
//

import SpriteKit
import GameplayKit

let ballMask:UInt32 = 0x1 << 0 // 1
let monsterMask:UInt32 = 0x1 << 1 // 2

class GameScene: SKScene {
    
    var titleLabel : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    // Define nodes used in the game
    var ball: SKSpriteNode?
    var monster: Monster?
    
    // Contains all the monsters for the game
    private var monsters: [Monster] = []

    var hitCount = 0

    // Defines where user touched
    var startTouchLocation: CGPoint = CGPoint.zero
    var endTouchLocation: CGPoint = CGPoint.zero

    override func sceneDidLoad() {

        // Assign this scene as a delegate so we get collision event notifications
        self.physicsWorld.contactDelegate = self

        // Load all the monsters
        monsters = Monster.allMonsters(frame.height, screenWidth: frame.width)

        // Get label node from scene and store it for use later
        self.titleLabel = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.titleLabel {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        titleLabel?.isHidden = true
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }

        if ball == nil {
            createBall()
        }
        
        if monster == nil {
            createMonster()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Record the start of the touch event
        startTouchLocation = touches.first!.location(in: self)
        
        // Create a spinner to track the user's touch movements
        updateSpinner(atLocation: startTouchLocation, withColor: SKColor.white)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Update the spinner as the touch moves
        let currentTouchLocation = touches.first!.location(in: self)
        updateSpinner(atLocation: currentTouchLocation, withColor: SKColor.green)
        
        // Move the ball along with the user's gesture
        if let ball = ball {
            ball.position = currentTouchLocation
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Record the end of the touch event
        endTouchLocation = touches.first!.location(in: self)
        
        // Update the spinner
        updateSpinner(atLocation: endTouchLocation, withColor: SKColor.blue)

        // Continue the ball's movement along the same path as the touch gesture
        let factor: CGFloat = 50
        let vector = CGVector(dx: factor * (endTouchLocation.x - startTouchLocation.x), dy: factor * (endTouchLocation.y - startTouchLocation.y))
        ball?.physicsBody?.applyImpulse(vector)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Update the spinner when the touch is cancelled
        let currentTouchLocation = touches.first!.location(in: self)
        updateSpinner(atLocation: currentTouchLocation, withColor: SKColor.red)
    }
    
    func updateSpinner(atLocation location: CGPoint, withColor color: SKColor) {
        
        // Creates a spinner to display the user's touch gesture
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = location
            n.strokeColor = color
            self.addChild(n)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Check if the node is not in the scene
        if let ball = ball {
            if (ball.position.x > self.size.width/2 + ball.size.width/2 ||
                ball.position.y > self.size.height + ball.size.height) {
                
                // The ball is outside the bounds of the visible view, so reset it
                resetBall()
            }
        }
    }
    
    // MARK: - Create nodes
    
    func createBall() {
        
        // Create the ball node
        ball = SKSpriteNode(imageNamed: "Ball")
        if let ball = ball {
            
            // Add physics
            ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.frame.size.width/2)
            ball.physicsBody?.isDynamic = true
            ball.physicsBody?.affectedByGravity = false
            ball.physicsBody?.allowsRotation = false
            ball.physicsBody?.mass = 50
            ball.physicsBody?.categoryBitMask = ballMask
            ball.physicsBody?.collisionBitMask = monsterMask
            ball.physicsBody?.contactTestBitMask = monsterMask

            // Set position and scale
            ball.position = CGPoint(x: 0, y: 100)
            ball.scale(to: CGSize(width: 50, height: 50))
        
            // Add to the scene
            addChild(ball)
        }
    }
    
    func resetBall() {
        
        // Reset ball and remove it
        ball?.removeAllActions()
        ball?.removeFromParent()
        ball = nil
        
        // Reset touched locations
        startTouchLocation = CGPoint.zero
        endTouchLocation = CGPoint.zero
        
        // Create a new ball to throw
        createBall()
    }
    
    func createMonster() {
        
        // Create and configure monster
        monster = randomMonster()
        monster?.configureMonster()
        
        // Add to the scene
        if let node = monster?.node {
            addChild(node)
        }
    }
    
    /**
     * Returns a random monster from the available list
     */
    func randomMonster() -> Monster {
        let monsterCount = UInt32(monsters.count)
        let imageNumber = Int(arc4random_uniform(monsterCount))
        return monsters[imageNumber]
    }
}

extension GameScene: SKPhysicsContactDelegate {

    /** 
     * Delegate method called when objects contact each other.
     */
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Determine which node is the ball and which is the monster
        let ball = (contact.bodyA.categoryBitMask == ballMask) ? contact.bodyA : contact.bodyB
        let other = (ball == contact.bodyA) ? contact.bodyB : contact.bodyA
        if other.categoryBitMask == monsterMask {
            
            // Monster was hit
            self.didHitMonster()
        }
        
        // Reset the ball
        resetBall()
    }
    
    /**
     * Called when the monster and the ball collide
     */
    func didHitMonster() {
        
        if let monster = self.monster, let node = monster.node {
            
            // Display a spark particle when the monster is hit
            let spark:SKEmitterNode = SKEmitterNode(fileNamed: "SparkParticle")!
            spark.position = node.position
            spark.particleColor = monster.hitColor
            self.addChild(spark)
            
            // Reset the ball into its default position
            resetBall()
            
            // Reset the monster
            monster.directHit()
            self.monster = nil
            
            // Update the hit count
            hitCount += 1

            // Display the title label to notify user of the hit
            self.titleLabel?.text = "Hit Count: \(hitCount)"
            self.titleLabel?.isHidden = false
            
            // Create a new monster after a short delay
            let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                
                // Add a new monster
                if self.monster == nil {
                    self.createMonster()
                }
                
                // Hide the title label
                self.titleLabel?.isHidden = true
            }
        }
    }
}
