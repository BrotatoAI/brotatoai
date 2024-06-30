import gymnasium as gym

env = gym.make("LunarLander-v2", render_mode="human")
env.metadata['render_fps'] = 5000
observation, info = env.reset()

for i in range(100000):
    action = env.action_space.sample()
    observation, reward, terminated, truncated, info = env.step(action)

    print("Interation:", i)
    print("Observation:", observation)
    print("Reward:", reward)
    print("Terminated:", terminated)
    print("Truncated:", truncated)
    print("Info:", info)

    if terminated or truncated:
        observation, info = env.reset()

env.close()