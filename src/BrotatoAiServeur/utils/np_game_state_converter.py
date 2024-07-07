import numpy as np
from src.BrotatoAiServeur.model.brotato_game_state import GameState


def game_state_to_array(game_state: GameState, max_enemies: int, max_projectiles: int) -> np.ndarray:
    # Convert player position, velocity and health to array
    player_info = np.array([game_state.player.position.x, game_state.player.position.y,
                            game_state.player.velocity.x, game_state.player.velocity.y,
                            game_state.player.health], dtype=np.float32)


    enemies_info = []
    for enemy in game_state.enemies:
        enemies_info.extend([enemy.position.x, enemy.position.y, enemy.velocity.x, enemy.velocity.y])

    if len(game_state.enemies) < max_enemies:
        enemies_info.extend([0.0, 0.0, 0.0, 0.0] * (max_enemies - len(game_state.enemies)))
    enemies_info = np.array(enemies_info, dtype=np.float32)


    projectiles_info = []
    for projectile in game_state.projectiles:
        projectiles_info.extend([projectile.position.x, projectile.position.y,
                                 projectile.direction.x, projectile.direction.y])

    if len(game_state.projectiles) < max_projectiles:
        projectiles_info.extend([0.0, 0.0, 0.0, 0.0] * (max_projectiles - len(game_state.projectiles)))
    projectiles_info = np.array(projectiles_info, dtype=np.float32)

    # Combine all information into a single array
    state = np.concatenate([player_info, enemies_info, projectiles_info])
    return state