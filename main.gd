extends Node2D

var level_orchestrator: LevelOrchestrator

func _ready():
	level_orchestrator = preload("res://services/level_orchestrator.gd").new(self)
