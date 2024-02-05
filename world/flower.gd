extends Interactable


func _on_interacted() -> void:
	queue_free()
	get_overlapping_bodies().front().has_flower = true
