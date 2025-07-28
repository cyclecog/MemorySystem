import sqlite3
from datetime import datetime

class NeuroMemorySystem:
    def __init__(self, db_path="memory.db"):
        self.conn = sqlite3.connect(db_path)
        self.conn.execute("""
        CREATE TABLE IF NOT EXISTS memory_meta (
            id INTEGER PRIMARY KEY,
            data_id TEXT UNIQUE,
            content_hash TEXT,
            storage_path TEXT,
            mem_type TEXT DEFAULT 'active',
            created_at TIMESTAMP,
            last_accessed TIMESTAMP,
            access_count INTEGER DEFAULT 0
        )
        """)
        self.conn.commit()

    def add_memory(self, data_id, content_hash, storage_path="", mem_type="active"):
        now = datetime.now().isoformat()
        self.conn.execute(
            """
            INSERT INTO memory_meta
            (data_id, content_hash, storage_path, mem_type, created_at, last_accessed, access_count)
            VALUES (?, ?, ?, ?, ?, ?, ?)
            """,
            (data_id, content_hash, storage_path, mem_type, now, now, 0)
        )
        self.conn.commit()

    def update_access_time(self, data_id):
        now = datetime.now().isoformat()
        self.conn.execute(
            "UPDATE memory_meta SET last_accessed = ? WHERE data_id = ?",
            (now, data_id)
        )
        self.conn.commit()
