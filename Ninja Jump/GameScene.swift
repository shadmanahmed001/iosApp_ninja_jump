//
//  GameScene.swift
//  Ninja Jump
//
//  Created by Marcus Sakoda on 3/10/17.
//  Copyright © 2017 Marcus Sakoda. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let Ghost : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
        var Ground = SKSpriteNode()
        var Ghost = SKSpriteNode()
    
        var wallPair = SKNode()
        var moveAndRemove = SKAction()
    
        var gameStarted = Bool()
    
        var score = Int()
        let scoreLbl = SKLabelNode()
        var died = Bool()
        var restartBTN = SKSpriteNode()
    
    func restartScene() {
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
        
    }
    
    func createScene() {
        self.physicsWorld.contactDelegate = self
        
        
        scoreLbl.position = CGPoint(x: 0, y: 500)
        scoreLbl.text = "\(score)"
        scoreLbl.fontSize = 50
        scoreLbl.zPosition = 5
        scoreLbl.fontName = "04b_19"
        self.addChild(scoreLbl)
        
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(0.75)
        Ground.position = CGPoint(x: 0, y: -600)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCategory.Ghost
        Ground.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        
        Ground.zPosition = 3
        
        self.addChild(Ground)
        
        
        Ghost = SKSpriteNode(imageNamed: "Ghost")
        Ghost.size = CGSize(width: 60, height: 70)
        Ghost.position = CGPoint(x: 0, y: 200)
        
        Ghost.physicsBody = SKPhysicsBody(circleOfRadius: Ghost.frame.height/2)
        Ghost.physicsBody?.categoryBitMask = PhysicsCategory.Ghost
        Ghost.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.wall
        Ghost.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.wall | PhysicsCategory.Score
        Ghost.physicsBody?.affectedByGravity = false
        Ghost.physicsBody?.isDynamic = true
        
        Ghost.zPosition = 2
        
        
        
        self.addChild(Ghost)

    }
    
    override func didMove(to view: SKView) {
        
        
        createScene()
        
    }
    
    func createBTN() {
        restartBTN = SKSpriteNode(color: SKColor.blue, size: CGSize(width:200,height:100)
        )
//        restartBTN.setScale(100)
        restartBTN.position = CGPoint(x: 0, y: 0)
        restartBTN.zPosition = 6
        self.addChild(restartBTN)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.Score && secondBody.categoryBitMask == PhysicsCategory.Ghost || firstBody.categoryBitMask == PhysicsCategory.Ghost && secondBody.categoryBitMask == PhysicsCategory.Score {
             score += 1
            scoreLbl.text = "\(score)"
        }
        if firstBody.categoryBitMask == PhysicsCategory.Ghost && secondBody.categoryBitMask == PhysicsCategory.wall || firstBody.categoryBitMask == PhysicsCategory.wall && secondBody.categoryBitMask == PhysicsCategory.Ghost {
            died = true
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameStarted == false {
            gameStarted = true
            Ghost.physicsBody?.affectedByGravity = true
            let spawn = SKAction.run({
                ()
                
                self.createWalls()
            })
            
            let delay = SKAction.wait(forDuration: 2.0)
            let SpawnDelay = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnDelay)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + 20)
            let movePipes = SKAction.moveBy(x: -distance, y: 0.0, duration: TimeInterval(0.01 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            Ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            Ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 90))
        }
        else {
            if died == true {
                createBTN()
                enumerateChildNodes(withName: "WallPair", using: <#T##(SKNode, UnsafeMutablePointer<ObjCBool>) -> Void#>)
            }
            else {
                Ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                Ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 90))
            }
            

        }
        
        for touch in touches {
            let location = touch.location(in: self)
            if died == true {
                if restartBTN.contains(location){
                    restartScene()
                }
                
            }
        }
    }
    
    func createWalls(){
        let scoreNode = SKSpriteNode()
        
        scoreNode.size = CGSize(width: 1, height:900)
        scoreNode.position = CGPoint(x: self.frame.width / 2, y: 0)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        scoreNode.color = SKColor.white
        
        wallPair = SKNode()
        wallPair.name = "WallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: 400, y: 550)
        btmWall.position = CGPoint(x: 400, y: -350)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.Ghost
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOf: btmWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCategory.wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCategory.Ghost
        btmWall.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        btmWall.physicsBody?.isDynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        
        topWall.zRotation = CGFloat(M_PI)
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1
        
        let randomPosition = CGFloat.random(min: -200, max: 200)
        
        wallPair.position.y = wallPair.position.y + randomPosition
        
        wallPair.addChild(scoreNode)
        
        wallPair.run(moveAndRemove)
        
        self.addChild(wallPair)
        
    }
    
    override func update(_ currentTime: CFTimeInterval) {
        
    }
}
