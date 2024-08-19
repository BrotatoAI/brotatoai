class_name Behavior
extends Node2D

var _parent:Node = null


func init(parent:Node)->Node:
	_parent = parent
	return self
