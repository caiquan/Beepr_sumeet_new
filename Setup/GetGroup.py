#!/usr/bin/python
import requests
import json
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.poolmanager import PoolManager
import ssl
import sys
import getopt

class MyAdapter(HTTPAdapter):
    def init_poolmanager(self, connections, maxsize, block=False):
        self.poolmanager = PoolManager(num_pools=connections,
                                       maxsize=maxsize,
                                       block=block,
                                       ssl_version=ssl.PROTOCOL_TLSv1)

def usage():
	print('''
HipaaGram Setup Script Usage

python HipaaGramSetup.py --username myusername@email.com --password myP@ssw0rd --appId 185bff27-a5b6-410e-bee3-71db20f51617 --apiKey 5b7a544d-261e-48f6-b254-792d6efa3722
''')

username = 'suji'
password = 'navi626!'
app_id = '76ea4a58-be5c-45bc-acc5-f23a159da6dd'
api_key = '58302dcc-ff28-4a79-973e-b03c594066c5'

if not username or not password or not app_id or not api_key:
	print("\nusername, password, app_id, and api_key are required parameters\n")
	usage()
	sys.exit(2)

# Script to setup an org, app, and custom classes for HipaaGram

base_url = "https://api.catalyze.io"

headers = {'X-Api-Key': api_key, 'Content-Type': 'application/json', 'Accept': 'application/json'}

s = requests.Session()
s.mount('https://', MyAdapter())

# login to the new app
route = '{}/v2/auth/signin'.format(base_url)
data = {'username': username, 'password': password}
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()
# print (resp)
headers['Authorization'] = 'Bearer {}'.format(resp['sessionToken'])

# Getting Group list
# route = '{0}/v2/app/{1}/groups'.format(base_url, app_id)
# r = s.get(route, data=json.dumps(data), headers=headers)
# resp = r.json()
# r.raise_for_status()
# print(resp)

# Getting sumeet's files list
# 'https://api.catalyze.io/v2/users/{userId}/files'
# route = '{0}/v2/users/{1}/files'.format(base_url, '1b7c8bc7-5abe-4d15-9eac-f3ef5a77ab0a')
# r = s.get(route, data=json.dumps(data), headers=headers)
# resp = r.json()
# r.raise_for_status()
# print(resp)

# create the People custom class
# route = '{}/v2/classes'.format(base_url)
# data = {'name':'People','schema':{'objectId':'string','user1':'string','user2':'string','objUser1':'object','objUser2':'object','nameUser1':'string','nameUser2':'string'},'phi':False}
# r = s.post(route, data=json.dumps(data), headers=headers)
# resp = r.json()
# r.raise_for_status()
# 
# set create permissions for People class for the app
# route = '{}/v2/acl/custom/People/{}'.format(base_url, '14c70061-cdd0-4134-a037-96b78c3efd16')
# data = ['create','retrieve', 'update' , 'delete']
# r = s.post(route, data=json.dumps(data), headers=headers)
# resp = r.json()
# r.raise_for_status()

# Update user for jhpassion0621@gmail.com
# PUT /users/{usersId}
route = '{0}/v2/users/{1}'.format(base_url, 'ce62f696-cce1-4ff5-b292-cbc35a1c15fe')
print(route)
data = {'name': {'prefix':'JH','firstName':'Jamse','middleName':'D','lastName':'Lee','maidenName':'','suffix':'jr'}}

r = s.put(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()
print(resp)


# ################   DELETE entry part     ######################################
# # delete user's class entry /classes/{name}/entry/{entryId}
# route = '{}/v2/classes/Users/entry/{}'.format(base_url, '20b747ba-369d-44f2-96de-9e9595dceb2c')
# data = {}
# r = s.delete(route, data=json.dumps(data), headers=headers)
# resp = r.json()
# r.raise_for_status()
# print(resp)

print('\n\nSuccess! Your HipaaGram application is ready to use!')
