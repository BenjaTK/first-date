extends Area2D


@onready var limits_rect: ReferenceRect = $LimitsRect


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not (body is Player):
		return

	var camera: Camera2D = Game.get_camera()
	var rect: Rect2 = limits_rect.get_global_rect()

	camera.limit_left = rect.position.x
	camera.limit_right = rect.end.x
	camera.limit_top = rect.position.y
	camera.limit_bottom = rect.end.y
