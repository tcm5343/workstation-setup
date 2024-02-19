#!/usr/bin/python3

import time

last_time = time.time()
wait_time = 2

while (True):
    if time.time() > last_time + wait_time:
        print("test")
        last_time = time.time()
    time.sleep(1)
