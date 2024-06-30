import gymnasium as gym

env = gym.make('CarRacing-v2', render_mode="human")
env.metadata['render_fps'] = 2000

observation, info = env.reset()

for _ in range(100000):
    action = env.action_space.sample()
    observation, reward, terminated, truncated, info = env.step(action)

    if terminated or truncated:
        observation = env.reset()

env.close()  # Fermer l'environnement
