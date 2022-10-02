import requests
import json
from requests_toolbelt import MultipartEncoder

base = "https://acm.o0o0o0o.cn/api/v4/"

cid = '3/'  # 比赛cid

s = requests.Session()
s.auth = ('test', 'test')

submit_url = base + 'contests/' + cid + 'submissions'

file_id = '0ABCDEFGHI'

for i in range(1):
    start = 17  # 题目开始编号，用于所以题目编号连续时
    for problem_id in range(start, start+9):
        index = problem_id - start + 1
        file_name = file_id[index] + '.cpp'
        code = open(file_name, 'rb')
        payload = {'problem': str(problem_id), 'language': 'cpp', 'code[]': (file_name, code, 'application/octet-stream')}

        m = MultipartEncoder(fields=payload)
        r = s.post(submit_url, data=m, headers={'Content-Type': m.content_type})