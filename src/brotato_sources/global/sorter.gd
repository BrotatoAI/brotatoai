class_name Sorter
extends Node


static func sort_depth_ascending(a:ItemAppearanceData, b:ItemAppearanceData):
	if a.depth < b.depth:
		return true
	return false
