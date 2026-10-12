extends CanvasLayer

func _process(delta: float) -> void:
	$VBoxContainer/FPSCounter.text = "%.1f " % (1/delta) + "%.2fms"  % (delta*1000)

func _physics_process(delta: float) -> void:
	$VBoxContainer/pFPSCounter.text = "%.1f " % (1/delta) + "%.2fms"  % (delta*1000)
