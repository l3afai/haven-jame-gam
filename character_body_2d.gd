extends CharacterBody2D


const SPEED = 300.0
var JUMP_VELOCITY = -400.0

const ACCEL = 5.0
const FRICTION = 3.04
const COOLDOWN = 2000.0
var timesincecooldown = 2000.0
func dash_possible() -> bool:
	return Time.get_ticks_msec() - timesincecooldown >= COOLDOWN

func _physics_process(delta: float) -> void:


	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimatedSprite2D.play("jump")


	var direction := Input.get_axis("ui_left", "ui_right")
	if direction > 0:
		$AnimatedSprite2D.flip_h = true
	if direction < 0:
		$AnimatedSprite2D.flip_h = false
	
	if Input.is_action_just_pressed("ui_accept") and not is_on_floor():
		if dash_possible():
			var isup := Input.is_action_pressed("ui_up")
			if isup:
				velocity.y -= 300
			velocity.x += 1500 * direction
			timesincecooldown = Time.get_ticks_msec()
	
	if direction !=  0.0:
		if is_on_floor():
			$AnimatedSprite2D.play("walking")
		var targetvelo = Vector2(direction * SPEED,velocity.y)
		velocity = velocity.lerp(targetvelo, ACCEL * delta)
	else:
		var targetvelo = Vector2(0,velocity.y)
		velocity = velocity.lerp(targetvelo, FRICTION * delta)
	if int(abs(velocity.x)) < 40:
		$AnimatedSprite2D.play("default")
	

	move_and_slide()
