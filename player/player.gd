extends CharacterBody3D

@export_category("Head")
@export var MOUSE_SENSITIVITY: float = 0.002
@export var BASE_FOV: float = 75.0
@export var SPRINT_FOV: float = 90.0
@export var FOV_CHANGE_STEP: float = 8.0
@export_category("Body")
@export var MOVE_SPEED: float = 6
@export var SPRINT_SPEED: float = 6.0
@export var JUMP_VELOCITY: float = 8.0
@export var GRAVITY_MULTIPLIER: float = 2.5
@export var COYOTE_TIME: float = 0.1


@onready var camera : Camera3D = $Camera3D

var BASE_GRAVITY : float = ProjectSettings.get_setting("physics/3d/default_gravity")

var is_sprinting := false
var is_wall_sprint := false
var coyote_time_left := 0.0
var body_turned_timer : = 0.0
var head_backward: Vector3
var body_backward: Vector3
var input_dir: Vector2
var wall_sprint_direction : Vector3

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Mouse rotating player only in horizontal, vertical rotation on camera
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		# Lock rotating further than looking down/up
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-89), deg_to_rad(89)) 
		
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		if coyote_time_left > 0:
			coyote_time_left -= delta
		velocity.y -= BASE_GRAVITY * GRAVITY_MULTIPLIER * delta
	if is_on_floor() and coyote_time_left < COYOTE_TIME:
		coyote_time_left = COYOTE_TIME
	
	input_dir = Input.get_vector("MoveBackward", "MoveForward","MoveLeft", "MoveRight")
	if input_dir != Vector2.ZERO:
			var forward_direction := basis.z.normalized()
			var side_direction := basis.x.normalized()
			var direction := (forward_direction * -input_dir.x + side_direction * input_dir.y).normalized()
			velocity.x = direction.x * MOVE_SPEED
			velocity.z = direction.z * MOVE_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, MOVE_SPEED)
		velocity.z = move_toward(velocity.z, 0, MOVE_SPEED)
	if Input.is_action_pressed("Jump") and coyote_time_left > 0:
		velocity.y = JUMP_VELOCITY
		coyote_time_left = 0


	move_and_slide()
	
	# WallRunInitiator
	#if is_on_wall_only():
		#var wall_degree = absf(rad_to_deg(get_wall_normal().signed_angle_to(head_backward, Vector3.UP)))
		#if wall_degree > player.WALL_SPRINT_MIN_DEGREE and wall_degree < player.WALL_SPRINT_MAX_DEGREE and movement_mode == MovementMode.MidAir:
			#movement_mode = MovementMode.WallSideRun
			#var wall_direction := Vector3.UP.cross(get_wall_normal())
			#wall_sprint_direction = signf(wall_direction.dot(-head_backward)) * wall_direction
