extends KinematicBody

onready var muzzle = $Hand/Muzzle
onready var aimcast = $Camera/RayCast
var moveSpeed : float = 5.0
var jumpForce : float = 5.0
var gravity : float = 12.0
# cam look
var minLookAngle : float = -90.0
var maxLookAngle : float = 90.0
var lookSensitivity : float = 7.0
# vectors
var vel : Vector3 = Vector3()
var mouseDelta : Vector2 = Vector2()
# components
onready var camera : Camera = get_node("Camera")
onready var bullet = preload("res://Scenes/SubScenes/Spell.tscn")
var can_fire = true
var rate_of_fire = 0.5

var mouseMode = 1
var invenOpen = false

func _physics_process(delta):
	vel.x = 0
	vel.z = 0
	var input = Vector2()
	if mouseMode == 1:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	elif mouseMode == 0:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_pressed("capture_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		mouseMode = 1
	
	if Input.is_action_pressed("release_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouseMode = 0
	
		
	
# shooting inputs
	if Input.is_action_pressed("mouse_left") and can_fire == true:
		can_fire = false
			#if aimcast.is_colliding():
		var b = bullet.instance()
		muzzle.add_child(b)
		b.look_at(aimcast.get_collision_point(), Vector3.UP)
		b.shoot = true
		yield(get_tree().create_timer(rate_of_fire), 'timeout')
		can_fire = true
	
	# If i is pressed and inventory is NOT open, call OPEN
	if Input.is_action_just_pressed("ui_inventory") and invenOpen == false:
		get_parent().get_node("CanvasLayer")._on_InvenPressed()
		invenOpen = true
	# If i is pressed and inventory IS open, call CLOSE
	elif Input.is_action_just_pressed("ui_inventory") and invenOpen == true:
		get_parent().get_node("CanvasLayer")._on_InvenClose()
		
	# movement inputs
	if Input.is_action_pressed("move_forwards"):
			input.y -= 1
	if Input.is_action_pressed("move_backwards"):
			input.y += 1
	if Input.is_action_pressed("move_left"):
			input.x -= 1
	if Input.is_action_pressed("move_right"):
			input.x += 1
		
	input = input.normalized()
	  
	# get the forward and right directions
	var forward = global_transform.basis.z
	var right = global_transform.basis.x 
	var relativeDir = (forward * input.y + right * input.x)
	
	# set the velocity
	vel.x = relativeDir.x * moveSpeed
	vel.z = relativeDir.z * moveSpeed 
	
	# apply gravity
	vel.y -= gravity * delta
	
	# move the player
	vel = move_and_slide(vel, Vector3.UP)
	
	# jumping
	if Input.is_action_pressed("ui_jump") and is_on_floor():
		vel.y = jumpForce

func _process(delta):
	# rotate the camera along the x axis
	camera.rotation_degrees.x -= mouseDelta.y * lookSensitivity * delta
	# clamp camera x rotation axis
	camera.rotation_degrees.x = clamp(camera.rotation_degrees.x, minLookAngle, maxLookAngle)
	# rotate the player along their y-axis
	rotation_degrees.y -= mouseDelta.x * lookSensitivity * delta
	# reset the mouseDelta vector
	mouseDelta = Vector2()

# Tracks mouse IF mouse is captured in FPS mode (1)
func _input(event):
	if event is InputEventMouseMotion:
		if mouseMode != 0:
			mouseDelta = event.relative

