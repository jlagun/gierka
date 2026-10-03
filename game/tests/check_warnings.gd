extends SceneTree
## Fails if any of the project's scripts has a GDScript warning. Run it with
## tools/check_warnings.sh, which does the two steps below.
##
## Godot only treats a warning as a problem when its project setting is "Error",
## and it reads those settings once, at startup. So this works in two runs:
##   1. `-- --write-override` writes game/override.cfg, which raises every
##      warning that is on (set to "Warn") to Error. Warnings that are off, like
##      the "inferred declaration" style warning, stay off.
##   2. A second run, started with that file in place, compiles every script and
##      fails if one of them doesn't compile.
## Add-ons are skipped: they aren't our code.

const WRITE_OVERRIDE_OPTION: String = "--write-override"
const OVERRIDE_PATH: String = "res://override.cfg"
const WARNINGS_PREFIX: String = "debug/gdscript/warnings/"
## Settings in the warnings group that aren't warnings themselves.
const NOT_WARNINGS: Array[String] = [
	"enable", "exclude_addons", "renamed_in_godot_4_hint", "directory_rules"
]
const WARN_LEVEL: int = 1
const ERROR_LEVEL: int = 2
const SKIPPED_FOLDERS: Array[String] = ["res://addons", "res://.godot"]


## Not _init: the autoloads (Net) only exist once the tree is initialized.
func _initialize() -> void:
	if WRITE_OVERRIDE_OPTION in OS.get_cmdline_user_args():
		quit(_write_override())
	else:
		quit(_check_scripts())


func _write_override() -> int:
	var config := ConfigFile.new()
	for property in ProjectSettings.get_property_list():
		var setting: String = property["name"]
		if not setting.begins_with(WARNINGS_PREFIX):
			continue
		if setting.trim_prefix(WARNINGS_PREFIX) in NOT_WARNINGS:
			continue
		var level: Variant = ProjectSettings.get_setting(setting)
		if typeof(level) != TYPE_INT or level != WARN_LEVEL:
			continue
		config.set_value("debug", setting.trim_prefix("debug/"), ERROR_LEVEL)
	return config.save(OVERRIDE_PATH)


func _check_scripts() -> int:
	if not FileAccess.file_exists(OVERRIDE_PATH):
		printerr("%s is missing. Run tools/check_warnings.sh instead." % OVERRIDE_PATH)
		return 1
	var failed: Array[String] = []
	var paths := _find_scripts("res://")
	for path in paths:
		# This script is running, so it can't be reloaded. Godot already compiled it.
		if path == get_script().resource_path:
			continue
		var script: GDScript = load(path)
		# Keeping the state lets it recompile scripts that already have instances.
		if script == null or script.reload(true) != OK:
			failed.append(path)
	if failed.is_empty():
		print("No warnings or errors in %d scripts." % paths.size())
		return 0
	printerr("These scripts have warnings or errors (details above):")
	for path in failed:
		printerr("  " + path)
	return 1


func _find_scripts(folder: String) -> Array[String]:
	var found: Array[String] = []
	if folder.trim_suffix("/") in SKIPPED_FOLDERS:
		return found
	for file in DirAccess.get_files_at(folder):
		if file.ends_with(".gd"):
			found.append(folder.path_join(file))
	for subfolder in DirAccess.get_directories_at(folder):
		found.append_array(_find_scripts(folder.path_join(subfolder)))
	return found
