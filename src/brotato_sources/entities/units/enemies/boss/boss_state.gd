class_name BossState
extends Node2D

export (float) var hp_start = 0.5
export (float) var timer_start = 45.0

onready var movement_behavior = $MovementBehavior
onready var attack_behavior = $AttackBehavior
