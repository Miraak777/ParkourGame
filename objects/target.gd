extends StaticBody3D

@export var max_health: float = 1.0

func take_damage() -> void:
	queue_free()
