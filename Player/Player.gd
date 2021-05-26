extends KinematicBody2D

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")
const BatExp = preload("res://Enemies/Bat.tscn")

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
var roll_vector =  Vector2.DOWN

var stats = PlayerStats

onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitBox = $HitboxPivot/SwordHitBox
onready var hurtBox =  $HurtBox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer


func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	stats.connect("get_exp",self,"on_exp_get")
	stats.connect("level_up",self,"on_level_up")
	animationTree.active = true
	swordHitBox.knockback_vector = roll_vector

func on_exp_get(value):
	$Exp.text = "EXP: " + str(value)
	$AnimationPlayer.play("EXPFLOAT")
	
func on_level_up():
	$LevelUp.text = "Level Up"
	$AnimationPlayer.play("LevelUp")
	
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

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	hurtBox.start_invincibility(0.6)
	hurtBox.create_hit_effect()
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)

func _on_HurtBox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_HurtBox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")
