extends Control


var stats = PlayerStats
onready var level = $Panel/Level
onready var curExp = $Panel/CurrentExp

func _ready():
	visible = false

func _input(event):
	if event.is_action_pressed("stats"):
		level.text = "Level: " + str(stats.level)
		curExp.text = "Experience: " + str(stats.cur_exp)
		$Timer.start(3)
		visible = true

func _on_Timer_timeout():
	visible = false
