extends Area3D

signal claimed_item()

func claim() -> void:
	claimed_item.emit()
