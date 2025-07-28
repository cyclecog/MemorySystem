# core/validator.py
import hashlib

class ContentValidator:
    # ✅ 方法定义：缩进 4 个空格
        def generate_hash(self, content):
    # ✅ 方法体：再缩进 4 个空格
            hash_obj = hashlib.sha256(content.encode())
            return hash_obj.hexdigest()
