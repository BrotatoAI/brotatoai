import json
import struct
import asyncio
import logging
import random
from src.BrotatoAiServeur.utils.json_to_gate_state_converter import json_to_game_state

logger = logging.getLogger(__name__)

class Server:

    def __init__(self):
        self.last_game_state = None

    async def start_server(self):
        server = await asyncio.start_server(self.handle_request, 'localhost', 4242)

        addr = server.sockets[0].getsockname()
        logger.info(f'Serving on {addr}')

        async with server:
            await server.serve_forever()

        logger.info('Closing server')

    async def handle_request(self, reader: asyncio.StreamReader, writer: asyncio.StreamWriter):
        logger.info("New connection ...")
        try:
            while True:
                # Read the size of the incoming message
                data_size_bytes = await reader.readexactly(8)
                data_size = struct.unpack('Q', data_size_bytes)[0]

                # logger.debug(f"Message size {data_size!r}")

                # Read the message based on the size
                message = await reader.readexactly(data_size)
                message_str = message.decode()

                # logger.debug(f"Message {message_str!r}")

                # Randomly choose an action (replace with your logic)
                choice = random.choice(['up', 'down', 'left', 'right'])
                writer.write(choice.encode())

                try:
                    state_dic = json.loads(message_str)
                    logger.debug("State: %s", json.dumps(state_dic, indent=4))

                    self.last_game_state = json_to_game_state(state_dic)

                except json.JSONDecodeError:
                    logger.error("Error parsing JSON")

        except Exception as e:
            logger.error(f"Error reading message size: {e}")
        finally:
            writer.close()
            await writer.wait_closed()

    def determine_action(self, player_position, monster_positions):
        # Your logic to determine the action
        return 0  # Example: always go up

    def start(self):
        asyncio.run(self.start_server())

if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG,
                        format='%(asctime)s.%(msecs)03d - %(message)s',
                        datefmt='%H:%M:%S')
    server = Server()
    server.start()
