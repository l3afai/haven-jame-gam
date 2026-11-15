extends CharacterBody2D

const SPEED = 300.0
var JUMP_VELOCITY = -400.0

const ACCEL = 10.0
const FRICTION = 10.0

const COOLDOWN = 2000.0
var timesincecooldown = -2000.0

func dash_possible() -> bool:
	return Time.get_ticks_msec() - timesincecooldown >= COOLDOWN

const WALL_SPEED = 50.0

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	
	if Input.is_action_just_pressed("ui_accept") and not is_on_floor() and not is_on_wall():
		if dash_possible():
			var dash_dir = direction
			if dash_dir == 0.0:
				dash_dir = -1.0 if $AnimatedSprite2D.flip_h else 1.0
				
			var isup := Input.is_action_pressed("ui_up")
			if isup:
				velocity.y = -300.0
			
			velocity.x = 1500.0 * dash_dir
			timesincecooldown = Time.get_ticks_msec()

	var is_sliding = false
	
	if not is_on_floor() and is_on_wall():
		var wall_normal = get_wall_normal()
		
		if velocity.y > 0 and ((wall_normal.x > 0 and direction < 0) or (wall_normal.x < 0 and direction > 0)):
			is_sliding = true

	if is_sliding:
		velocity.y = min(velocity.y + (get_gravity().y * delta), WALL_SPEED)
	elif not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif is_sliding:
			velocity.y = JUMP_VELOCITY
			velocity.x = get_wall_normal().x * SPEED * 1.5 

	if direction != 0.0:
		var targetvelo = Vector2(direction * SPEED, velocity.y)
		velocity = velocity.lerp(targetvelo, ACCEL * delta)
	else:
		var targetvelo = Vector2(0, velocity.y)
		velocity = velocity.lerp(targetvelo, FRICTION * delta)

	if direction > 0:
		$AnimatedSprite2D.flip_h = true
	elif direction < 0:
		$AnimatedSprite2D.flip_h = false

	move_and_slide()

	if is_on_floor():
		if abs(velocity.x) < 40:
			$AnimatedSprite2D.play("default")
		else:
			$AnimatedSprite2D.play("walking")
	else:
		if is_sliding:
			$AnimatedSprite2D.play("wall_slide")
		else:
			$AnimatedSprite2D.play("jump")
