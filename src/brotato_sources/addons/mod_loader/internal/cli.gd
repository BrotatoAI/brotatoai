class_name _ModLoaderCLI
extends Reference





const LOG_NAME: = "ModLoader:CLI"



static func is_running_with_command_line_arg(argument:String)->bool:
	for arg in OS.get_cmdline_args():
		if argument == arg.split("=")[0]:
			return true

	return false



static func get_cmd_line_arg_value(argument:String)->String:
	var args: = _get_fixed_cmdline_args()

	for arg_index in args.size():
		var arg: = args[arg_index] as String

		var key: = arg.split("=")[0]
		if key == argument:
			
			if "=" in arg:
				var value: = arg.trim_prefix(argument + "=")
				value = value.trim_prefix("\"").trim_suffix("\"")
				value = value.trim_prefix("'").trim_suffix("'")
				return value

			
			elif arg_index + 1 < args.size() and not args[arg_index + 1].begins_with("--"):
				return args[arg_index + 1]

	return ""


static func _get_fixed_cmdline_args()->PoolStringArray:
	return fix_godot_cmdline_args_string_space_splitting(OS.get_cmdline_args())




static func fix_godot_cmdline_args_string_space_splitting(args:PoolStringArray)->PoolStringArray:
	if not OS.has_feature("editor"):
		return args
	if OS.has_feature("Windows"):
		return args

	var fixed_args: = PoolStringArray([])
	var fixed_arg: = ""
	
	
	
	for arg in args:
		var arg_string: = arg as String
		if "=\"" in arg_string or "=\"" in fixed_arg or arg_string.begins_with("\"") or fixed_arg.begins_with("\""):
			if not fixed_arg == "":
				fixed_arg += " "
			fixed_arg += arg_string
			if arg_string.ends_with("\""):
				fixed_args.append(fixed_arg.trim_prefix(" "))
				fixed_arg = ""
				continue
		
		elif "='" in arg_string or "='" in fixed_arg or arg_string.begins_with("'") or fixed_arg.begins_with("'"):
			if not fixed_arg == "":
				fixed_arg += " "
			fixed_arg += arg_string
			if arg_string.ends_with("'"):
				fixed_args.append(fixed_arg.trim_prefix(" "))
				fixed_arg = ""
				continue

		else :
			fixed_args.append(arg_string)

	return fixed_args
