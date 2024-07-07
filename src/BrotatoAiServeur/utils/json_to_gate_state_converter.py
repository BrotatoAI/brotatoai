from src.BrotatoAiServeur.model.brotato_game_state import GameState, Player, Enemy, Projectile, Vector2

def json_to_game_state(state_dic) -> GameState:
    player_dict = state_dic.get("player")
    if player_dict:
        player = Player(
            health=player_dict.get("health", -1),
            position=Vector2(player_dict["position"]["x"], player_dict["position"]["y"]),
            velocity=Vector2(player_dict["velocity"]["x"], player_dict["velocity"]["y"])
        )
    else:
        player = None

    enemies = []
    for enemy_dict in state_dic.get("enemies", []):
        enemy = Enemy(
            position=Vector2(enemy_dict["position"]["x"], enemy_dict["position"]["y"]),
            velocity=Vector2(enemy_dict["velocity"]["x"], enemy_dict["velocity"]["y"])
        )
        enemies.append(enemy)

    projectiles = []
    for projectile_dict in state_dic.get("projectiles", []):
        projectile = Projectile(
            position=Vector2(projectile_dict["position"]["x"], projectile_dict["position"]["y"]),
            direction=Vector2(projectile_dict["direction"]["x"], projectile_dict["direction"]["y"])
        )
        projectiles.append(projectile)

    return GameState(
        duration=state_dic.get("duration", -1.0),
        player=player,
        enemies=enemies,
        projectiles=projectiles
    )