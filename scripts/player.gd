extends CharacterBody3D

class_name Player

var speed = 5.0
const jump_velocity = 4.5

var mouse_sensitivity: float = 0.005
@export var player_camera: Camera3D
@export var camera_pivot: Marker3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			
func _unhandled_input(event: InputEvent) -> void:
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# moves the camera based on mouse motion
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensitivity
		camera_pivot.rotation.x -= event.relative.y * mouse_sensitivity
		camera_pivot.rotation_degrees.x = clamp(camera_pivot.rotation_degrees.x, -90.0, 90.0)

	# swaps camera shoulder
	if event.is_action_pressed("swap shoulder"):
		swap_shoulder()
	
	# handles aiming
	#TODO this should be handled in the relevent equipment scripts
	if event.is_action_pressed("aim"):
		var camera_tween: Tween = create_tween()	
		camera_tween.tween_property(player_camera, "fov", 45, 0.25)
	if event.is_action_released("aim"):
		var camera_tween: Tween = create_tween()	
		camera_tween.tween_property(player_camera, "fov", 90, 0.25)

var on_right_shoulder: bool = true
func swap_shoulder():
	var camera_tween: Tween = create_tween()	
	var right_shoulder_position: float = 0.8
	var left_shoulder_position: float = -0.8
	if on_right_shoulder:
		camera_tween.tween_property(player_camera, "position:x", left_shoulder_position, 0.25)
		on_right_shoulder = false
	else:
		camera_tween.tween_property(player_camera, "position:x", right_shoulder_position, 0.25)
		on_right_shoulder = true


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()
