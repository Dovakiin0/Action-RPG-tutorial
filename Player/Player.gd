extends KinematicBody2D

export var FRICTION = 500
export var ACCELERATION = 500
export var ROLL_SPEED = 100
export var MAX_SPEED = 80

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector =  Vector2.LEFT

onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitBox = $HitboxPivot/SwordHitBox

func _ready():
	animationTree.active = true
	swordHitBox.knockback_vector = roll_vector

func _physics_process(delta):
	match state:
		MOVE: 
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state()



func move_state(delta):
	var input_vector = Vector2.ZERO # (0,0)
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left") # (
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized() # (1,0)
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitBox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)	
		animationTree.set("parameters/Roll/blend_position", input_vector)	
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move();
	if Input.is_action_just_pressed("Attack"):
		state = ATTACK
	if Input.is_action_just_pressed("Roll"):
		state = ROLL
	
func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")
	
func move():
	velocity = move_and_slide(velocity)

func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move();

func roll_animation_finish():
	velocity = Vector2.ZERO
	state = MOVE
	
func attack_animation_finish():
	state = MOVE
