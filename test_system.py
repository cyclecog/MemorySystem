import unittest
from core.memory import NeuroMemorySystem
from core.validator import ContentValidator

class TestMemorySystem(unittest.TestCase):
    def setUp(self):
        # 关键：用内存数据库，每次测试全新开始
        self.mem = NeuroMemorySystem(":memory:")  

    def test_basic_insert(self):
        content = b"project details"
        content_hash = ContentValidator.generate_hash(content)
        self.mem.add_memory("doc1", content_hash)  # 现在内存数据库无历史数据

        result = self.mem.conn.execute(
            "SELECT mem_type FROM memory_meta WHERE data_id='doc1'"
        ).fetchone()
        self.assertEqual(result[0], "active", "mem_type 应为 active")

if __name__ == "__main__":
    unittest.main(verbosity=2)
