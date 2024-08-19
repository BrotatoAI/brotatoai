extends Reference


class_name FixedTimer


var elapsed:float = 0.0


var wait_time:float = 1.0


var _is_stopped:bool = false


func _init(_wait_time = 1.0)->void :
	wait_time = _wait_time



func start()->void :
	elapsed = 0.0
	_is_stopped = false



func stop()->void :
	_is_stopped = true



func is_stopped()->bool:
	return _is_stopped



func completed()->bool:
	return elapsed >= wait_time




func try_advance(dt:float)->void :
	if _is_stopped:
		return 
	elapsed += dt



func try_loop(dt:float)->int:
	try_advance(dt)
	if not completed():
		return 0
	var loops: = int(elapsed / wait_time)
	elapsed = fmod(elapsed, wait_time)
	return loops
