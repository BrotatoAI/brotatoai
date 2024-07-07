import logging
import threading
import gymnasium as gym
import numpy as np
from gymnasium import spaces
from model.brotato_game_state import GameState
from server import Server
import matplotlib.pyplot as plt
from src.BrotatoAiServeur.utils.np_game_state_converter import game_state_to_array

logger = logging.getLogger(__name__)

MAX_ENEMIES = 20
MAX_PROJECTILES = 0

class BrotatoEnv(gym.Env):

    game_state = None

    server = Server()

    def __init__(self):
        super(BrotatoEnv, self).__init__()

        logger.info("Starting server in a separate thread")
        self.server_thread = threading.Thread(target=self.server.start)
        self.server_thread.start()

        n_player = 5  # position (2) + velocity (2) + health (1)
        n_enemies = 4 * MAX_ENEMIES  # each enemy position (2) + velocity (2)
        n_projectiles = 4 * MAX_PROJECTILES  # each projectile a position (2) + direction (2)
        n = n_player + n_enemies + n_projectiles

        self.action_space = spaces.Discrete(2) # vector of 2
        self.observation_space = spaces.Box(low=0, high=1, shape=(n,), dtype=np.float32)

        self.reset()

    def reset(self, **kwargs):
        logger.info("Resetting environment")
        self.state = np.zeros(self.observation_space.shape, dtype=np.float32)
        return self.state, {}

    def step(self, action):
        logger.info("Taking action")
        self._take_action(action)
        self.state = self._get_game_state()

        if self.state is None:
            # Skip the iteration if state is None
            logger.info("State is None, skipping iteration")
            empty_state = np.zeros(self.observation_space.shape, dtype=np.float32)
            return empty_state, 0.0, True, False, {}

        reward = self._calculate_reward()
        done = self._is_done()
        truncated = False
        return self.state, reward, done, truncated, {}

    def render(self, mode='human'):
        if mode == 'human':
            plt.figure(figsize=(10, 10))
            plt.xlim(0, 1)
            plt.ylim(0, 1)

            # Render player
            plt.plot(self.state[0], self.state[1], 'bo', label='Player')

            # Render enemies
            for i in range(MAX_ENEMIES):
                idx = 5 + i * 4
                if self.state[idx] != 0 or self.state[idx + 1] != 0:  # Ignore zero-padded enemies
                    plt.plot(self.state[idx], self.state[idx + 1], 'ro', label='Enemy' if i == 0 else "")

            # Render projectiles
            offset = 5 + 4 * MAX_ENEMIES
            for i in range(MAX_PROJECTILES):
                idx = offset + i * 4
                if self.state[idx] != 0 or self.state[idx + 1] != 0:  # Ignore zero-padded projectiles
                    plt.plot(self.state[idx], self.state[idx + 1], 'go', label='Projectile' if i == 0 else "")

            plt.legend()
            plt.show()
        else:
            super().render(mode=mode)

    def _get_game_state(self):
        logger.info("Getting game state")
        self.game_state = self.get_game_state_from_godot()

        if self.game_state is None:
            logger.info("Game state is None")
            return None

        logger.debug("Game state: %s", self.game_state)
        return game_state_to_array(self.game_state, MAX_ENEMIES, MAX_PROJECTILES)

    def _take_action(self, action):
        if action == 0:
            move_player_up()
        elif action == 1:
            move_player_down()
        elif action == 2:
            move_player_left()
        elif action == 3:
            move_player_right()

    def _calculate_reward(self):
        return self.game_state.player.health + (60 - self.game_state.duration)

    def _is_done(self):
        return self.game_state.player.health <= 0 or self.game_state.duration <= 0.1

    def get_game_state_from_godot(self) -> GameState:
        return self.server.last_game_state

