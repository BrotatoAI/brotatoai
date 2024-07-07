from typing import List

class Vector2:
    def __init__(self, x: float, y: float):
        self.x = x
        self.y = y

class Player:
    def __init__(self, health: int, position: Vector2, velocity: Vector2):
        self.health = health
        self.position = position
        self.velocity = velocity

class Enemy:
    def __init__(self, position: Vector2, velocity: Vector2):
        self.position = position
        self.velocity = velocity

class Projectile:
    def __init__(self, position: Vector2, direction: Vector2):
        self.position = position
        self.direction = direction

class GameState:
    def __init__(self, duration: float, player: Player, enemies: List[Enemy], projectiles: List[Projectile]):
        self.duration = duration
        self.player = player
        self.enemies = enemies
        self.projectiles = projectiles