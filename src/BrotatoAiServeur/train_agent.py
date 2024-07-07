
from stable_baselines3 import PPO
from src.BrotatoAiServeur.brotato_env import BrotatoEnv
import logging

logging.basicConfig(level=logging.WARN)

logger = logging.getLogger(__name__)

# Learn
logger.info("Creating environment")
env = BrotatoEnv()
model = PPO('MlpPolicy', env, verbose=1)

logger.info("Training model")
model.learn(total_timesteps=10_000_000)

logger.info("Saving model")
model.save("ppo_brotato")

model = PPO.load("ppo_brotato")

# Use
# obs = env.reset()
# for _ in range(10000):
#     action, _states = model.predict(obs)
#     obs, rewards, done, info = env.step(action)
#     env.render()
#     if done:
#         obs = env.reset()
