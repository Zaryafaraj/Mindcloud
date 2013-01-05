import json
import cStringIO
from tornado import gen
from tornado.httpclient import AsyncHTTPClient
from tornado.httputil import HTTPFile
from Cache.MindcloudCache import MindcloudCache
from Helpers.HTTPHelper import HTTPHelper
from Logging.Log import log
from Properties.MindcloudProperties import Properties
from Sharing.SharingEvent import SharingEvent
from Storage.StorageResponse import StorageResponse

__author__ = 'afathali'

class JokerHelper():
    """
    Responsible for constructing requests to joker
    """
    __instance = None

    __COLLECTION_NAME_KEY = 'collection_name'
    __USER_ID_KEY = 'user_id'
    __ACTION_KEY = 'action'
    __NOTE_NAME_KEY = 'note_name'

    def __init__(self):
        self.__cache = MindcloudCache()
        self.__log = log()

    @classmethod
    def get_instance(cls):
        if cls.__instance is None:
            cls.__instance = JokerHelper()
        return cls.__instance

    @gen.engine
    def get_sharing_space_server(self, sharing_secret, callback):
        #First look into cache
        sharing_server = yield gen.Task(self.__cache.get_sharing_space_server, sharing_secret)
        if sharing_server is not None:
            callback(sharing_server)

        else:
            #its not in the cache go and ask the load balancer for it
            load_balancer = Properties.load_balancer_url
            url = '/'.join([load_balancer, 'SharingFactory', sharing_secret])

            http = AsyncHTTPClient()
            response = yield gen.Task(http.fetch, url, method='GET')
            if response.code == StorageResponse.OK:
                try:
                    json_obj = json.loads(response.body)
                    server_address = json_obj['server']
                    cached = json_obj['cached']
                    if cached.lower() == 'false':
                        yield gen.Task(self.__cache.set_sharing_space_server,
                            sharing_secret, server_address)
                    callback(server_address)
                except Exception:
                    self.__log.warning('JokerHelper - corrupted response from load balancer for sharing space %s : \n %s' % (sharing_secret, response.body))
                    callback(None)

            else:
                self.__log.warning('JokerHelper - %s returned from load balancer for sharing space %s' % (str(response.code), sharing_secret))
                callback(None)

    @gen.engine
    def update_manifest(self, server_address, sharing_secret, user_id,
                        collection_name, manifest_file, callback):
        json_dict = {
                        SharingEvent.UPDATE_MANIFEST :
                            {
                             JokerHelper.__COLLECTION_NAME_KEY : collection_name,
                             JokerHelper.__USER_ID_KEY : user_id
                            }
                    }
        json_str = json.dumps(json_dict)
        params = {JokerHelper.__ACTION_KEY : json_str}
        file_obj = manifest_file
        if isinstance(manifest_file, HTTPFile):
            file_obj = cStringIO.StringIO(manifest_file.body)

        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params(params,
            'file', file_obj)
        http = AsyncHTTPClient()
        url = '/'.join([server_address, 'SharingSpace', sharing_secret])
        response = yield gen.Task(http.fetch,url,
            method='POST', headers=headers, body=post_data)
        callback(response.code)

    @gen.engine
    def update_note(self, server_address, sharing_secret,
                    user_id, collection_name, note_name, note_file, callback):
        json_dict = {
                        SharingEvent.UPDATE_NOTE :
                                {
                                JokerHelper.__COLLECTION_NAME_KEY : collection_name,
                                JokerHelper.__USER_ID_KEY : user_id,
                                JokerHelper.__NOTE_NAME_KEY : note_name
                                }
                    }

        json_str = json.dumps(json_dict)
        params = {JokerHelper.__ACTION_KEY : json_str}
        file_obj = note_file
        if isinstance(note_file, HTTPFile):
            file_obj = cStringIO.StringIO(note_file.body)

        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params(params,
            'file', file_obj)
        http = AsyncHTTPClient()
        url = '/'.join([server_address, 'SharingSpace', sharing_secret])
        response = yield gen.Task(http.fetch,url,
            method='POST', headers=headers, body=post_data)
        callback(response.code)
