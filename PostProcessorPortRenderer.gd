extends Node2D

func assign_world(World):
	var vp = get_node("TextureSprite/PPPort/Post_Processor/3dVP")
	for child in vp.get_children():
		vp.remove_child(child)
	vp.add_child(World)

func get_env():
	return get_node("TextureSprite/PPPort/Post_Processor/WorldEnvironment")

func disable():
	get_node("TextureSprite").texture.set_viewport_path_in_scene(NodePath("TextureSprite/PPPort/Post_Processor/3dVP"))

func enable():
	get_node("TextureSprite").texture.set_viewport_path_in_scene(NodePath("TextureSprite/PPPort"))


var width = 1280.0
var height = 720.0
func set_size(w,h):
	scale.x = float(w)/1280.0
	scale.y = float(h)/720.0
	width = float(w)
	height = float(h)
