import json
from Helpers.HTTPHelper import HTTPHelper
import urllib
import urllib2

__author__ = 'afathali'

def i_am_alive(self_address, self_port, load_balancer):

    url = '/'.join([load_balancer, 'Configs/Jokers'])
    my_full_address = self_address+':' + str(self_port)
    data = {'operation' : 'add_servers', 'address' : my_full_address}
    try:
        postData = urllib.urlencode(data)
        req = urllib2.Request(url, postData)
        urllib2.urlopen(req)
    except Exception:
        #nothing to do we aren't getting announced
        #maybe should crash
        pass



