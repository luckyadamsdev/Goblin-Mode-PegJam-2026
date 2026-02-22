extends Node3D
class_name SparkleEffect

@export var sparkles:MeshInstance3D

func _process(delta: float) -> void:
	if visible:
		sparkles.rotate_y(delta * 18.0)

func show_sparkles() -> void:
	var tween:= create_tween()
	visible = true
	scale = Vector3(0.2, 0.01, 0.2)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "scale", Vector3(1.0, 1.8, 1.0), 0.6)
	await get_tree().create_timer(2.0).timeout
	visible = false
