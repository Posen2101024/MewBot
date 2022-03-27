import discord
import redis
import os
client = discord.Client()

@client.event
async def on_ready():
    print('目前登入身份：', client.user)

@client.event
async def on_message(message):
    if message.author == client.user:
        return
    if message.content == 'ping':
        await message.channel.send('pong')

REDIS_POOL = redis.ConnectionPool(host='localhost', port=6379, db=0, decode_responses=True)
r = redis.Redis(connection_pool=REDIS_POOL)

if os.getenv('TOKEN'):
    r.set('TOKEN', os.getenv('TOKEN'))

client.run(r.get('TOKEN'))
