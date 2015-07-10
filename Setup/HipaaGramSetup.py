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

headers['Authorization'] = 'Bearer {}'.format(resp['sessionToken'])

# create the Users custom class
route = '{}/v2/classes'.format(base_url)
data = {'name':'Users','schema':{'objectId':'string','email':'string','fullname':'string','emailCopy':'string','profilePhoto':'string'},'phi':False}
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()

# create the Users custom class
route = '{}/v2/classes'.format(base_url)
data = {'name':'Blocked','schema':{'objectId':'string','user':'string','user1':'string','user2':'string'},'phi':False}
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()

# create the Group custom class
route = '{}/v2/classes'.format(base_url)
data = {'name':'Group','schema':{'objectId':'string','memebers':'array','name':'string','user':'string'},'phi':False}
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()

# create the Message custom class
route = '{}/v2/classes'.format(base_url)
data = {'name':'Message','schema':{'objectId':'string','groupId':'string','picture':'string','text':'string','user':'string','video':'string'},'phi':False}
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()

# create the People custom class
route = '{}/v2/classes'.format(base_url)
data = {'name':'People','schema':{'objectId':'string','user1':'string','user2':'string','objUser1':'object','objUser2':'object','nameUser1':'string','nameUser2':'string'},'phi':False}
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()

# create the Recent custom class
route = '{}/v2/classes'.format(base_url)
data = {'name':'Recent','schema':{'objectId':'string','counter':'string','picture':'string','text':'string','user':'string','video':'string'},'phi':False}
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()

# create the Report class
route = '{}/v2/classes'.format(base_url)
data = {'name':'Report','schema':{'objectId':'string','user1':'string','user2':'string', 'createdAt':'string'},'phi':False}
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()

# create the CreateRetrieve default group
route = '{}/v2/groups'.format(base_url)
data = {'name':'CreateRetrieve','default':True}
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()

create_retrieve_groups_id = resp['groupsId']
print 'CreateRetrive group id {0}'.format(create_retrieve_groups_id)

# create the Create default group
route = '{}/v2/groups'.format(base_url)
data = {'name':'Create','default':True}
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()

create_groups_id = resp['groupsId']
print 'Create group id {0}'.format(create_groups_id)

# set create permissions for contacts class for the app
route = '{}/v2/acl/custom/Users/{}'.format(base_url, create_retrieve_groups_id)
data = ['create', 'retrieve', 'update', 'delete']
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()

# set create permissions for conversations class for the app
route = '{}/v2/acl/custom/Blocked/{}'.format(base_url, create_retrieve_groups_id)
data = ['create', 'retrieve', 'update' , 'delete']
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()

# set create permissions for Recent class for the app
route = '{}/v2/acl/custom/Recent/{}'.format(base_url, create_retrieve_groups_id)
data = ['create','retrieve']
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()

# set create permissions for Group class for the app
route = '{}/v2/acl/custom/Group/{}'.format(base_url, create_retrieve_groups_id)
data = ['create','retrieve' ,'update' , 'delete']
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()

# set create permissions for messages class for the app
route = '{}/v2/acl/custom/Message/{}'.format(base_url, create_retrieve_groups_id)
data = ['create','retrieve']
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()

# set create permissions for Report class for the app
route = '{}/v2/acl/custom/Report/{}'.format(base_url, create_retrieve_groups_id)
data = ['create','retrieve']
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()

# set create permissions for People class for the app
route = '{}/v2/acl/custom/People/{}'.format(base_url, create_retrieve_groups_id)
data = ['create','retrieve', 'update' , 'delete']
r = s.post(route, data=json.dumps(data), headers=headers)
resp = r.json()
r.raise_for_status()

print('\n\nSuccess! Your HipaaGram application is ready to use!')
