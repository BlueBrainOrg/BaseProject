#**************************************************************************/
#*  automatic_layer_enums.gd                                              */
#**************************************************************************/
#*                       This file was created for:                       */
#*                             GODOT ENGINE                               */
#*                        https://godotengine.org                         */
#**************************************************************************/
#* Copyright (c) 2023-Present Adam Wardell                                */
#*                                                                        */
#* Permission is hereby granted, free of charge, to any person obtaining  */
#* a copy of this software and associated documentation files (the        */
#* "Software"), to deal in the Software without restriction, including    */
#* without limitation the rights to use, copy, modify, merge, publish,    */
#* distribute, sublicense, and/or sell copies of the Software, and to     */
#* permit persons to whom the Software is furnished to do so, subject to  */
#* the following conditions:                                              */
#*                                                                        */
#* The above copyright notice and this permission notice shall be         */
#* included in all copies or substantial portions of the Software.        */
#*                                                                        */
#* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
#* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
#* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
#* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
#* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
#* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
#* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
#**************************************************************************/

@tool
extends EditorPlugin

const template_fmt:String = """#This file was autogenerated by automatic_layer_enums.gd
class_name {class_name}

enum {enum_name} {
{enum_vals}}

const Strings := {
{enum_strings}}
"""

func _enter_tree() -> void:
	var popup := PopupMenu.new()
	var label_fmt := "Generate %s Layer Enums"
	var options := load_plugin_options()
	for i in options.size():
		var layer = options[i]
		popup.add_item(label_fmt % layer["name"], i)
	popup.add_item("Generate All", options.size())
	popup.id_pressed.connect(generate_enums)
	add_tool_submenu_item("Layer Enums", popup)

func _exit_tree() -> void:
	remove_tool_menu_item("Layer Enums")

func generate_enums(id) -> void:
	var options = load_plugin_options()
	if id == options.size():
		for i in options.size():
			generate_enums(i)
		return

	var data = options[id]
	var max_layers:int = int(data["max_count"])
	var enum_vals:String = ""
	var enum_strings:String = ""
	for i in range(1, max_layers + 1):
		var layer_name:String = ProjectSettings.get_setting_with_override(data["project_setting"] % i) as String
		if !layer_name.is_empty():
			var regex:RegEx = RegEx.create_from_string("[^\\w_]")
			var layer_name_esc = regex.sub(layer_name, "_", true)
			enum_vals += String.chr(9) #tab
			enum_vals += "%s = 1 << (%d - 1),\n" % [layer_name_esc, i]
			enum_strings += String.chr(9) #tab
			enum_strings += "%s.%s:\"%s\",\n" % [data["enum_name"], layer_name_esc, layer_name]

	var file_txt := template_fmt.format({
		"class_name":data["class_name"],
		"enum_name":data["enum_name"],
		"enum_vals":enum_vals,
		"enum_strings":enum_strings
	});
	var file_path:String = data["script"]
	if !DirAccess.dir_exists_absolute(file_path.get_base_dir()):
		DirAccess.make_dir_recursive_absolute(file_path.get_base_dir())
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(file_txt)
	file.close()
	print("Wrote to " + file_path)
	var rfs = EditorInterface.get_resource_filesystem()
	rfs.scan()
	rfs.scan_sources()

func load_plugin_options() -> Array[Dictionary]:
	var config := ConfigFile.new()
	var path := (get_script() as Script).resource_path.get_base_dir() + "/plugin_options.cfg"
	if config.load(path) == OK:
		var result:Array[Dictionary] = []
		var sections = config.get_sections()
		result.resize(sections.size())
		var index:int = 0
		for section in sections:
			var dict := {}
			dict["name"] = section
			for key in config.get_section_keys(section):
				dict[key] = config.get_value(section, key)
			result[index] = dict
			index += 1
		return result
	return []