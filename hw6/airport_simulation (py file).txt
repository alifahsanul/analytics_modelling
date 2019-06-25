"""
Airport security system
Scenario:
1. Passengers arrive (poisson distribution)
2. Passengers go to boarding-pass check queue (waiting time is exponential distribution)
3. Passengers go to available personal-check queue (waiting time is uniform distribution)
"""

import numpy as np
import simpy

RANDOM_SEED = 42
NUM_BOARDING_PASS_CHECKER = 5
NUM_PERSONAL_CHECK_QUEUES = 5
SIM_TIME = 24 * 60 # Simulate for 1 Day
LAMBDA_PASS_ARRIVAL = 5
MEAN_BOARDING_PASS_SERVICE_TIME = 0.75
PERSONAL_CHECK_WAIT_MIN = 0.5
PERSONAL_CHECK_WAIT_MAX = 1
DEBUG = False
avg_waiting_times = []
num_iterations = 10

for iteration in range(num_iterations):
START_TIME_DICT = {}
END_TIME_DICT = {}
PASSENGER_NAMES = []

class BoardingPassCheck(object):
    def __init__(self, env):
        self.env = env
        self.machine = simpy.Resource(env, NUM_BOARDING_PASS_CHECKER)

    def check(self, passenger):
        yield self.env.timeout(np.random.exponential(MEAN_BOARDING_PASS_SERVICE_TIME))
        if DEBUG: print('Passenger {} has been checked'.format(passenger))

class PersonalCheck(object):
    def __init__(self, env):
        self.env = env
        self.machine = simpy.Resource(env, NUM_PERSONAL_CHECK_QUEUES)

    def check(self, passenger):
        yield self.env.timeout(np.random.uniform(PERSONAL_CHECK_WAIT_MIN, PERSONAL_CHECK_WAIT_MAX))
        if DEBUG: print('Personal check has finished for Passenger {}'.format(passenger))


def passenger(env, name, cw, checkout):
    if DEBUG: print('%s arrives at the ariport at %.2f.' % (name, env.now))
    START_TIME_DICT[name] = env.now
    with cw.machine.request() as request:
        yield request
        if DEBUG: print('%s enters the boarding check queue at %.2f.' % (name, env.now))
        yield env.process(cw.check(name))
        if DEBUG: print('%s leaves the boarding check queue at %.2f.' % (name, env.now))
    with checkout.machine.request() as request:
        yield request
        if DEBUG: print('%s enters the personal check queue at %.2f.' % (name, env.now))
        yield env.process(checkout.check(name))
        if DEBUG: print('%s leaves the personal check queue at %.2f.' % (name, env.now))
        END_TIME_DICT[name] = env.now


def setup(env):
    board_check = BoardingPassCheck(env)
    personal_check = PersonalCheck(env)
    i = 0
    while True:
        yield env.timeout(np.random.exponential(scale=1 / LAMBDA_PASS_ARRIVAL))
        PASSENGER_NAMES.append('Passenger %d' % i)
        START_TIME_DICT['Passenger %d' % i] = np.nan
        END_TIME_DICT['Passenger %d' % i] = np.nan
        env.process(passenger(env, 'Passenger %d' % i, board_check, personal_check))
        i += 1

env = simpy.Environment()
env.process(setup(env))
env.run(until=SIM_TIME)

waiting_times = np.array([END_TIME_DICT[x] - START_TIME_DICT[x] for x in PASSENGER_NAMES])
avg_waiting_time = np.nanmean(waiting_times)
avg_waiting_times.append(avg_waiting_time)
print('Average of average waiting time is {:.2f} minutes'.format(np.mean(avg_waiting_times)))
