extends KinematicBody2D

const DeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO
const FORCE = 140

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

enum {
	IDLE,
	WANDER,
	CHASE
}

var state = CHASE

onready var sprite = $AnimatedBatSprite
onready var stats = $Stats
onready var playerDetection = $PlayerDetection
onready var hurtBox = $HurtBox
onready var softCollosion = $SoftCollision
onready var WanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200*delta)
			seek_player()
			if WanderController.get_time_left() == 0:
				state = pick_random_state([IDLE,WANDER])
				WanderController.start_wander_timer(rand_range(1,3))
		WANDER:
			seek_player()
			if WanderController.get_time_left() == 0:
				state_wanderer()
			accelerate_towards_point(WanderController.target_position, delta)
			if global_position.distance_to(WanderController.target_position) <= MAX_SPEED * delta:
				state_wanderer()
		CHASE:
			var player = playerDetection.player
			if player != null:
				accelerate_towards_point(player.global_position,delta)
			else:
				state = IDLE
	if softCollosion.is_colliding():
		velocity += softCollosion.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func state_wanderer():
	state = pick_random_state([IDLE,WANDER])
	WanderController.start_wander_timer(rand_range(1,3))

func accelerate_towards_point(pos, delta):
	var direction = global_position.direction_to(pos)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func seek_player():
	if playerDetection.can_see_player():
		state = CHASE
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()

func _on_HurtBox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * FORCE
	hurtBox.create_hit_effect()
	hurtBox.start_invincibility(0.3)

func death_effect():
	var deathEffect = DeathEffect.instance()
	get_parent().add_child(deathEffect)
	deathEffect.global_position = global_position
	

func _on_Stats_no_health():
	death_effect()
	queue_free()


func _on_HurtBox_invincibility_ended():
	animationPlayer.play("Stop")


func _on_HurtBox_invincibility_started():
	animationPlayer.play("Start")
