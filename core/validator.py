import hashlib

class ContentValidator:
    @staticmethod
    def generate_hash(content):
        """生成内容的SHA256哈希"""
        return hashlib.sha256(content).hexdigest()
