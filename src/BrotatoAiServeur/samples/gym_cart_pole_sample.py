import gymnasium as gym

env = gym.make('CartPole-v1', render_mode="human")
env.metadata['render_fps'] = 0

observation, info = env.reset()

for _ in range(10000):
    env.render()
    action = env.action_space.sample()
    observation, reward, terminated, truncated, info = env.step(action)

    if terminated or truncated:
        observation = env.reset()  # Réinitialiser si l'épisode est terminé

env.close()  # Fermer l'environnement
