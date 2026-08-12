import asyncio
from sqlalchemy import text
from app.db.session import engine

async def fix_alembic_version():
    async with engine.begin() as conn:
        await conn.execute(text("UPDATE alembic_version SET version_num='60af5e678a38';"))
        print("✅ Alembic version successfully reverted to 60af5e678a38")

if __name__ == "__main__":
    asyncio.run(fix_alembic_version())
