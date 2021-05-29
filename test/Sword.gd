extends Area2D


onready var player = $SwordAnimation

func swing():
	player.play("Swing")

func on_finish():
	visible = false
