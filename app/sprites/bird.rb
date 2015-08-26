class Bird < SKSpriteNode
  BIRD = 0x1 << 0

  def init
    self.initWithImageNamed("bird_one.png")
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

  def jump
    if physics_enabled?
      physicsBody.velocity = CGVectorMake(0, 0)
      physicsBody.applyImpulse CGVectorMake(0, 8)
    end
  end

  def rotate
    if physics_enabled?
      dy = physicsBody.velocity.dy
      self.zRotation = max_rotate(dy * (dy < 0 ? 0.003 : 0.001))
    end
  end

  def max_rotate(value)
    if value > 0.7
      0.7
    elsif value < -0.3
      -0.3
    else
      value
    end
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

  def physics_enabled?
    !!self.physicsBody
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
