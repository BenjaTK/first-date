extends Camera2D
## Una cámara con shaking
class_name ShakingCamera


## Máximo movimiento horizontal/vertical en pixeles.
@export var max_offset := Vector2(100, 75)

var decay := 0.8
## Fuerza actual del movimiento.
var _trauma := 0.0
## Exponencial del _trauma. Usar [2, 3].
var _trauma_power := 2.0

@onready var noise := FastNoiseLite.new()
var noise_y := 0


func _ready() -> void:
	Game.camera = self
	randomize()
	noise.seed = randi_range(0, 16)
	noise.frequency = 0.25
	noise.fractal_octaves = 2


## Lo que se llama para empezar el movimiento. [0, 1]
func shake(amount: float, decay_time: float) -> void:
	decay = decay_time
	_trauma = min(amount * 0.5, 1.0)


func _process(delta: float) -> void:
	if _trauma != null:
		_trauma = max(_trauma - decay * delta, 0)
		_shaking()


func _shaking() -> void:
	var amount := pow(_trauma, _trauma_power)
	noise_y += 1
	offset.x = max_offset.x * amount * noise.get_noise_2d(noise.seed * 2, noise_y)
	offset.y = max_offset.y * amount * noise.get_noise_2d(noise.seed * 3, noise_y)


func hit_stop(duration: float = 0.1) -> void:
	Engine.time_scale = 0.001
	await get_tree().create_timer(duration, true, false, true).timeout
	Engine.time_scale = 1

