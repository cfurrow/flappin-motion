class SkyLineScene < SKScene
  WORLD = 0x1 << 1

  def didMoveToView(view)
    super

    physicsWorld.gravity = CGVectorMake(0.0, -5.0)
    physicsWorld.contactDelegate = self

    add_skyline
    add_ground
    add_bird

    add_pause_label

    show_go_button
  end

  def add_pause_label
    label = SKLabelNode.labelNodeWithFontNamed("Chalkduster")
    label.text = "Pause"
    label.position = CGPointMake(80, 500)
    label.name = "pause"
    addChild label
  end

  def show_go_button
    removeActionForKey("add_pipes_action")
    label = SKLabelNode.labelNodeWithFontNamed("Chalkduster")
    label.text = "Go!"
    label.position = CGPointMake(mid_x, mid_y)
    label.name = "go"
    addChild label
  end

  def add_skyline
    texture = SKTexture.textureWithImageNamed("skyline.png")

    2.times do |i|
      x_position = mid_x + (i * mid_x * 2)
      skyline = SKSpriteNode.spriteNodeWithTexture(texture)
      skyline.position = CGPointMake(x_position, mid_y)
      skyline.name = "skyline"
      skyline.zPosition = -20
      skyline.scale = 1.12
      skyline.runAction scroll_action(mid_x, 0.1)

      addChild skyline
    end
  end

  def add_ground
    texture = SKTexture.textureWithImageNamed("ground.png")
    x = CGRectGetMidX(self.frame) + 7

    2.times do |i|
      ground = SKSpriteNode.spriteNodeWithTexture texture
      ground.position = CGPointMake(x + (i * x * 2), 56)
      ground.runAction scroll_action(x, 0.02)

      addChild ground
    end

    addChild PhysicalGround.alloc.init
  end

  def add_bird
    addChild Bird.alloc.init
    reset_bird_position
  end

  def bird
    @bird ||= childNodeWithName("bird")
  end

  def reset_bird_position
    bird.position = CGPointMake(80, mid_y + bird.size.height / 2)
  end

  def begin_spawning_pipes
    pipes = SKAction.performSelector("add_pipes", onTarget: self)
    delay = SKAction.waitForDuration(4.0)
    sequence = SKAction.sequence([pipes, delay])

    action = SKAction.repeatActionForever(sequence)

    runAction action, withKey: "add_pipes_action"
  end

  def add_pipes
    addChild PipePair.alloc.init
  end

  # This action is used for both the ground and sky.
  #
  def scroll_action(x, duration)
    width = (x * 2)
    move = SKAction.moveByX(-width, y: 0, duration: duration * width)
    reset = SKAction.moveByX(width, y: 0, duration: 0)

    SKAction.repeatActionForever(SKAction.sequence([move, reset]))
  end

  def update(current_time)
    @delta = @last_update_time ?  current_time - @last_update_time : 0
    @last_update_time = current_time
    #@bird = nil # Force bird refresh once per frame

    check_controller

    bird.rotate
  end

  def touchesBegan(touches, withEvent: event)
    touch = touches.anyObject
    location = touch.locationInNode(self)
    node = nodeAtPoint(location)

    if node.name == "pause"
      if self.isPaused
        self.paused = false
      else
        self.paused = true
      end
    elsif node.name == "go"
      node.removeFromParent
      remove_all_pipes

      reset_bird_position
      bird.turn_on_physics

      begin_spawning_pipes
    else
      bird.jump
    end
  end

  def check_controller
    controllers = GCController.controllers

    if controllers.count > 1
      controller = controller.first.extendedGamepad

      if controller.buttonA.isPressed?
        bird.jump
      end
    end
  end

  # Contact delegate method
  #
  def didBeginContact(contact)
    bird.turn_off_physics
    reset_bird_position
    show_go_button
    bird.zRotation = 0

    remove_all_pipes
  end

  def remove_all_pipes
    enumerateChildNodesWithName "pipes", usingBlock:-> (node, stop) { node.removeFromParent }
  end

  # Helper methods.
  #
  def mid_x
    CGRectGetMidX(self.frame)
  end

  def mid_y
    CGRectGetMidY(self.frame)
  end
end
