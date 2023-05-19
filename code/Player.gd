extends KinematicBody

export var angle := 0.0
export var speed_forward := 100.0
export var speed_backward := 30.0
export var speed_jump := 200.0
export var speed_rotation := 0.05
export var gravity := -10

var vec_y = 0
var jump = false
var walking = false
var crouch = false
var dead = false
var fly = false

func _physics_process(delta):
	if Input.is_action_just_pressed("change_camera"):
		var camera = get_parent().get_node("Camera")
		camera.current = not camera.current
	
	var direction = Vector3()
	if not dead:
		walking = false
		if not fly and Input.is_action_just_pressed("crouch"):
			crouch = true
		elif Input.is_action_just_released("crouch"):
			crouch = false
		if not crouch and Input.is_action_just_pressed("fly"):
			fly = not fly
			if fly:
				direction.y += 5000
				vec_y = 0
		if Input.is_action_pressed("forward"):
			if crouch:
				direction.z = speed_backward
				$Obj/AnimationPlayer.play("m crouch walk")
			elif fly:
				direction.z = speed_forward
				$Obj/AnimationPlayer.play("m swim forward")
			else:
				direction.z = speed_forward
				$Obj/AnimationPlayer.play("m run")
			walking = true
		elif Input.is_action_pressed("backward"):
			direction.z = -speed_backward
			if crouch:
				$Obj/AnimationPlayer.play("m crouch backward")
			elif fly:
				$Obj/AnimationPlayer.play("m swim back")
			else:
				$Obj/AnimationPlayer.play("m backward")
			walking = true
		if Input.is_action_pressed("left"):
			rotate_y(speed_rotation)
			angle += speed_rotation
			if crouch:
				$Obj/AnimationPlayer.play("m crouch side")
			elif fly:
				$Obj/AnimationPlayer.play("m swim forward")
			else:
				$Obj/AnimationPlayer.play("m run")
			walking = true
		elif Input.is_action_pressed("right"):
			rotate_y(-speed_rotation)
			angle -= speed_rotation
			if crouch:
				$Obj/AnimationPlayer.play("m crouch side")
			elif fly:
				$Obj/AnimationPlayer.play("m swim forward")
			else:
				$Obj/AnimationPlayer.play("m run")
			walking = true
		if not jump and not crouch and not fly and Input.is_action_just_pressed("jump"):
			vec_y += speed_jump
			jump = true
			$Obj/AnimationPlayer.play("m jump")
		if not fly and Input.is_action_just_pressed("kill"):
			$Obj/AnimationPlayer.play("m death")
			dead = true
	else:
		if $Obj/AnimationPlayer.is_playing():
			$Obj/AnimationPlayer.play("m death")
		if Input.is_action_just_pressed("kill"):
			dead = false
		#return
	
	direction.y += vec_y
	direction = direction.rotated(Vector3.UP, angle)
	if not fly:
		vec_y += gravity
	var _error = move_and_slide(direction * delta, Vector3.UP)
	if is_on_floor():
		if jump:
			jump = false
		else:
			vec_y = 0
			if not walking and not dead:
				if crouch:
					$Obj/AnimationPlayer.play("m crouch root")
				else:
					$Obj/AnimationPlayer.play("m root")
	elif fly and not walking:
		$Obj/AnimationPlayer.play("m swim root")
