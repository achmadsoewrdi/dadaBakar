import asyncio
from sqlalchemy import text
from app.db.session import engine

async def seed_tello():
    async with engine.begin() as conn:
        await conn.execute(text("""
            INSERT INTO hardware_types (id, name, display_name, description, pin_map_json)
            VALUES (
                gen_random_uuid(),
                'tello_drone',
                'DJI Tello',
                'Drone DJI Tello — dikontrol via UDP port 8889',
                '{"command_port": 8889, "state_port": 8890, "video_port": 11111, "default_ip": "192.168.10.1"}'
            )
            ON CONFLICT (name) DO NOTHING;
        """))
        print("✅ Tello seeded successfully")

if __name__ == "__main__":
    asyncio.run(seed_tello())
