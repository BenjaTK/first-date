class_name Interactable
extends Area2D


signal interacted


@onready var sprite: Node2D = $Sprite


func _process(delta: float) -> void:
	if not monitoring:
		sprite.material.set_shader_parameter("width", 0.0)
		return


	sprite.material.set_shader_parameter("width", 1.0 if has_overlapping_bodies() else 0.0)


func _input(event: InputEvent) -> void:
	if not monitoring:
		return

	if event.is_action_pressed("interact") and has_overlapping_bodies():
		interacted.emit()
