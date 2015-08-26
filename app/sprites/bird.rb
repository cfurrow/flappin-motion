class Bird < SKSpriteNode
  BIRD = 0x1 << 0

  def init
    self.initWithImageNamed("bird_one.png")
    turn_on_physics
    self.position = CGPointMake(80, 400)
    self.scale = 1.1
    self.name = "bird"
    self.runAction flap
    self
  end

  def flap
    bird_one = SKTexture.textureWithImageNamed("bird_one.png")
    bird_two = SKTexture.textureWithImageNamed("bird_two.png")
    bird_three = SKTexture.textureWithImageNamed("bird_three.png")
    animation = SKAction.animateWithTextures([bird_one, bird_two, bird_three], timePerFrame: 0.15)

    SKAction.repeatActionForever animation
  end

  def turn_off_physics(&block)
    self.physicsBody = nil
    if block_given?
      yield
      turn_on_physics
    end
  end

  def turn_on_physics
    self.physicsBody = physics_body
  end

  def physics_body
    body = SKPhysicsBody.bodyWithRectangleOfSize(size)
    body.friction = 0.0
    body.categoryBitMask = BIRD
    body.contactTestBitMask = SkyLineScene::WORLD
    body.usesPreciseCollisionDetection = true
    body
  end
end
