extends Resource
class_name SceneLoaderConfig

## keys are scene lookup names, values are scene file paths i.e.{"scene1": "res://scenes/scene1.tscn"}
@export var scenes: Dictionary

@export_category("Loading Screen")
## scene to be used for the loading screen
@export_file("*.tscn") var loading_screen: String
## Node Path to the progress bar in the loading screen scene
@export var path_to_progress_bar: String
