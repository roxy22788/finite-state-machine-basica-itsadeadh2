extends CharacterBody2D

const GRAVITY = 800
const MOVE_SPEED = 120
const JUMP_FORCE = 200


enum {WALK, ATTACK, JUMP, FALL, IDLE, SLIDE}
var current_state = IDLE

var enter_state = true

@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta):
	match current_state:
		WALK:
			_walk_state(delta)
		ATTACK:
			_attack_state(delta)
		JUMP:
			_jump_state(delta)
		FALL:
			_fall_state(delta)
		IDLE:
			_idle_state(delta)
		SLIDE:
			_slide_state(delta)

# state functions
func _jump_state(_delta):
	if enter_state:
		animated_sprite.play("jump")
		velocity.y = -JUMP_FORCE
		enter_state = false
		
	_apply_gravity(_delta)
	_move()
	_apply_move_and_slide()
	
	_set_state(_check_jump_state())
	
func _fall_state(_delta):
	animated_sprite.play("fall")
	_apply_gravity(_delta)
	_move()
	_apply_move_and_slide()
	
	_set_state(_check_fall_state())

func _walk_state(_delta):
	animated_sprite.play("walk")

	_move()
	_apply_gravity(_delta)
	_apply_move_and_slide()
	
	_set_state(_check_walk_state())
	
func _attack_state(_delta):
	if enter_state:
		animated_sprite.play("attack")
		enter_state = false
	velocity.x = 0
	_apply_gravity(_delta)
	_apply_move_and_slide()

func _idle_state(_delta):
	animated_sprite.play("idle")
	velocity.x = 0
	_apply_gravity(_delta)
	_apply_move_and_slide()
	
	_set_state(_check_idle_state())

func _slide_state(_delta):
	animated_sprite.play("slide")
	velocity.x = lerp(velocity.x, 0.0, 0.05)
	_apply_gravity(_delta)
	_apply_move_and_slide()
	
	_set_state(_check_slide_state())
	
	
# check functions
func _check_idle_state():
	var new_state = IDLE
	if Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left"):
		new_state = WALK
	elif Input.is_action_pressed("ui_attack"):
		new_state = ATTACK
	elif Input.is_action_pressed("ui_jump"):
		new_state = JUMP
	elif not is_on_floor():
		new_state = FALL
	return new_state
	
func _check_walk_state():
	var new_state = WALK
	if Input.get_axis("ui_left", "ui_right") == 0:
		new_state = IDLE
	elif Input.is_action_pressed("ui_attack"):
		new_state = ATTACK
	elif Input.is_action_pressed("ui_jump"):
		new_state = JUMP
	elif Input.is_action_pressed("ui_down"):
		new_state = SLIDE
	elif not is_on_floor():
		new_state = FALL
	return new_state
	
func _check_jump_state():
	var new_state = JUMP
	if velocity.y >= 0:
		new_state = FALL
	elif Input.is_action_pressed("ui_attack"):
		new_state = ATTACK
	return new_state

func _check_fall_state():
	var new_state = FALL
	if is_on_floor():
		new_state = IDLE
	elif Input.is_action_pressed("ui_attack"):
		new_state = ATTACK
	return new_state
	
func _check_slide_state():
	var new_state = SLIDE
	if abs(round(velocity.x)) <= 20:
		new_state = IDLE
	elif not is_on_floor():
		new_state = FALL
	return new_state
	
	
# helpers functions
func _apply_gravity(_delta):
	velocity.y += GRAVITY * _delta
	
func _apply_move_and_slide():
	move_and_slide()

func _move():
	if Input.is_action_pressed("ui_right"):
		velocity.x = MOVE_SPEED
		animated_sprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -MOVE_SPEED
		animated_sprite.flip_h = true
		
func _set_state(new_state):
	if new_state != current_state:
		enter_state = true
	current_state = new_state



func _on_animated_sprite_2d_animation_finished():
	var anim_name = animated_sprite.animation
	if anim_name == "attack":
		_set_state(IDLE)
