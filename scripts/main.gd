extends Spatial

onready var cube : MeshInstance = MeshInstance.new()
onready var pipe : MeshInstance = MeshInstance.new()
onready var camera : Camera = Camera.new()
onready var light : OmniLight = OmniLight.new()
onready var bulb : MeshInstance = MeshInstance.new()
onready var shade : CSGMesh = preload("res://scenes/light_shade.tscn").instance()
onready var def_env : Environment = preload("res://default_env.tres")

export(float, 0.0, 2.0) var ambient_intensity = 0.15
export(bool) var ambient_enabled := true
export(bool) var camera_motion := true
export(float, 0.0, 24.0) var light_range = 16.0
export(float, 0.0, 2.0) var light_intensity = 1.5
export(Color) var light_color = Color(0.9, 0.6, 0.3, 1)

var light_position : Vector3 = Vector3.ZERO
var shade_mesh : MeshInstance
var shade_scale := 2.2
var elapsed_time := 0.0

var material : SpatialMaterial

func _ready():
	# setup camera and default enviroment
	camera.set_translation(Vector3(0, 0, 44))
	camera.environment = def_env
	#camera.environment.background_mode = Environment.BG_COLOR
	#camera.environment.background_color = Color(0.17, 0.4, 0.57, 1) * 0.4
	#camera.environment.ambient_light_color = Color(1, 1, 1, 1)
	#camera.environment.ambient_light_energy = 0.15
	add_child(camera)
	
	# setup stage (which is a cube's interior)
	cube.mesh = CubeMesh.new()
	cube.mesh.size = Vector3(32, 32, 32)
	material = SpatialMaterial.new()
	material.set_cull_mode(material.CULL_FRONT)
	material.flags_disable_ambient_light = true
	cube.material_override = material
	add_child(cube)
	
	# setup pipe (an extra obstacle for the light rays)
	pipe.mesh = CylinderMesh.new()
	pipe.mesh.set_height(40.0)
	pipe.mesh.set_top_radius(1.2)
	pipe.mesh.set_bottom_radius(2.5)
	material = SpatialMaterial.new()
	material.albedo_color = Color(0.9, 0.4, 0.3, 1)
	pipe.material_override = material
	pipe.rotate_x(deg2rad(-45))
	pipe.rotate_y(deg2rad(25))
	add_child(pipe)

	# setup light bulb
	bulb.mesh = SphereMesh.new()
	bulb.scale = Vector3(0.2, 0.2, 0.2)
	material = SpatialMaterial.new()
	material.flags_unshaded = true
	bulb.material_override = material
	add_child(bulb)

	# setup light emitter
	light.shadow_enabled = true
	add_child(light)

	# setup light shade
	shade.scale = Vector3(shade_scale, shade_scale, shade_scale)
	add_child(shade)


func _process(delta):
	# update user parameters
	light.omni_range = light_range
	light.light_energy = light_intensity
	light.light_color = light_color
	if ambient_enabled:
		camera.environment.ambient_light_energy = ambient_intensity
	else:
		camera.environment.ambient_light_energy = 0.0

	# light & bulb movement
	light_position = Vector3(sin(elapsed_time * 0.6) * 8, sin(elapsed_time * 0.7) * 8 + 4, sin(elapsed_time * 0.8) * 8)
	light.translation = light_position
	bulb.translation = 	light_position

	# shade movement
	shade.translation = light_position
	shade.rotation.y += delta
	shade.rotation.z -= delta * 0.5
	
	# camera sway
	if camera_motion:
		camera.translation.x = -light.translation.x * 1.5
		camera.look_at(transform.origin, Vector3.UP)

	# increment time
	elapsed_time += delta

