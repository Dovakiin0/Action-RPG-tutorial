extends Node

export(int) var max_health setget set_max_health
var health = max_health setget set_health
var level = 1 
var cur_exp = 0 setget set_exp
var next_exp = 15

signal no_health
signal health_changed(value)
signal max_health_changed(value)
signal level_up
signal get_exp(value)


func set_exp(value):
	cur_exp = cur_exp + value
	emit_signal("get_exp", value)
	if cur_exp >= next_exp:
		emit_signal("level_up")
		self.level += 1
		cur_exp = 0
	

func set_max_health(value):
	max_health = value
	self.health = min(health, max_health)
	emit_signal("max_health_changed", max_health)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")


func _ready():
	self.health = max_health
