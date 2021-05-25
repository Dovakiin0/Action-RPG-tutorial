extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("Attack"):
		var GrassEffect = load("res://Effects/GrassEffect.tscn")
		var grassEffect = GrassEffect.instance()
		
		queue_free()
