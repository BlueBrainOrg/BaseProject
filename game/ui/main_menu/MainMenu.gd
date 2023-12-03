extends Control


@export var scene_loader_cfg: SceneLoaderConfig

func _ready() -> void:
	SceneLoader.set_configuration_from_resource(scene_loader_cfg)


func _on_start_pressed() -> void:
	SceneLoader.load_scene(self, "scene1")


func _on_exit_pressed() -> void:
	get_tree().quit()
