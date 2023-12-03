extends "res://addons/scene_loader/autoloads/scene_loader.gd"


func set_configuration_from_resource(config: SceneLoaderConfig) -> void:
	if config.scenes != null:
		scenes = config.scenes

	if config.path_to_progress_bar != null:
		path_to_progress_bar = config.path_to_progress_bar

	if config.loading_screen != null:
		loading_screen = load(config.loading_screen)
