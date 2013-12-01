import random
import json
import urllib
from tornado.ioloop import IOLoop
from tornado.testing import AsyncHTTPTestCase
from Tests.ApiTets.HTTPHelper import HTTPHelper
from Tests.TestingProperties import TestingProperties
from TornadoMain import Application


#noinspection PyBroadException
class CollectionTests(AsyncHTTPTestCase):

    account_id = TestingProperties.account_id
    subscriber_id = TestingProperties.subscriber_id

    def get_new_ioloop(self):
        return IOLoop.instance()

    def get_app(self):
        application = Application()
        return application

    def test_set_collection_file(self):
        collection_name = 'collName1'+str(random.randint(0, 100))
        params = {'collectionName': collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)

        file_name = 'drawing.dwg'
        url = '/'.join(['', self.account_id, 'Collections', collection_name, 'Files'])
        params = {'fileName': file_name}
        file_obj = open('../../test_resources/screen.drw')
        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params(params, file_name, file_obj)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=post_data)
        self.assertEquals(200, response.code)

        #cleanup
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def __wait(self, duration):
        try:
            self.wait(timeout=duration)
        except Exception:
            pass

    def test_set_collection_file_with_subscribers_owner(self):

        collection_name = 'collName1'+str(random.randint(0, 100))
        params = {'collectionName': collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url += "/" + collection_name + '/Share'
        response = self.fetch(path=url, method='POST', body="")
        json_obj = json.loads(response.body)
        sharing_secret = json_obj['sharing_secret']
        sharing_secret = str(sharing_secret)
        self.assertEqual(200, response.code)

        #subscribe
        subscription_url = '/'.join(['', self.subscriber_id,
                                     'Collections', 'ShareSpaces', 'Subscribe'])
        headers, post_data = \
            HTTPHelper.create_multipart_request_with_parameters({'sharing_secret': sharing_secret})
        response = self.fetch(path=subscription_url, method='POST',
                              headers=headers, body=post_data)
        self.assertEqual(200, response.code)
        json_obj = json.loads(response.body)
        subscriber_collection_name = json_obj['collection_name']

        #post a file
        file_name = 'drawing.dwg'
        url = '/'.join(['', self.account_id, 'Collections', collection_name, 'Files'])
        params = {'fileName': file_name,
                  'sharing_secret': sharing_secret}
        file_obj = open('../../test_resources/screen.drw')
        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params(params, file_name, file_obj)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=post_data)
        self.assertEquals(200, response.code)

        #wait for a couple of seconds
        self.__wait(5)

        #now try to get the file from the subscriber
        url = '/'.join(['', self.subscriber_id, 'Collections', subscriber_collection_name, 'Files', file_name])
        response = self.fetch(path=url, headers=headers, method='GET')
        self.assertEqual(200, response.code)

        #cleanup
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')
        url = '/'.join(['', self.subscriber_id, 'Collections', subscriber_collection_name])
        self.fetch(path=url, method='DELETE')

    def test_set_collection_file_with_subscribers_subscriber(self):

        collection_name = 'collName1'+str(random.randint(0, 100))
        params = {'collectionName': collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        url += "/" + collection_name + '/Share'
        response = self.fetch(path=url, method='POST', body="")
        json_obj = json.loads(response.body)
        sharing_secret = json_obj['sharing_secret']
        sharing_secret = str(sharing_secret)
        self.assertEqual(200, response.code)

        #subscribe
        subscription_url = '/'.join(['', self.subscriber_id,
                                     'Collections', 'ShareSpaces', 'Subscribe'])
        headers, post_data = \
            HTTPHelper.create_multipart_request_with_parameters({'sharing_secret': sharing_secret})
        response = self.fetch(path=subscription_url, method='POST',
                              headers=headers, body=post_data)
        self.assertEqual(200, response.code)
        json_obj = json.loads(response.body)
        subscriber_collection_name = json_obj['collection_name']

        #post a file
        file_name = 'drawing.dwg'
        url = '/'.join(['', self.subscriber_id, 'Collections', subscriber_collection_name, 'Files'])
        params = {'fileName': file_name,
                  'sharing_secret': sharing_secret}
        file_obj = open('../../test_resources/screen.drw')
        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params(params, file_name, file_obj)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=post_data)
        self.assertEquals(200, response.code)

        #wait for a couple of seconds
        self.__wait(5)

        #now try to get the file from the subscriber
        url = '/'.join(['', self.account_id, 'Collections', collection_name, 'Files', file_name])
        response = self.fetch(path=url, headers=headers, method='GET')
        self.assertEqual(200, response.code)

        #cleanup
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')
        url = '/'.join(['', self.subscriber_id, 'Collections', subscriber_collection_name])
        self.fetch(path=url, method='DELETE')

    def test_set_collection_file_without_file_name(self):
        collection_name = 'collName1'+str(random.randint(0, 100))
        params = {'collectionName': collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)

        url = '/'.join(['', self.account_id, 'Collections', collection_name, 'Files'])
        file_obj = open('../../test_resources/screen.drw')
        file_name = 'dummyfilename'
        headers, post_data = HTTPHelper.create_multipart_request_with_single_file(file_name, file_obj)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=post_data)
        self.assertEquals(400, response.code)

        #cleanup
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_set_collection_file_non_existing_collection(self):

        collection_name = 'collName1'+str(random.randint(0, 100))

        file_name = 'drawing.dwg'
        url = '/'.join(['', self.account_id, 'Collections', collection_name, 'Files'])
        params = {'fileName': file_name}
        file_obj = open('../../test_resources/screen.drw')
        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params(params, file_name, file_obj)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=post_data)
        self.assertEquals(200, response.code)

        #cleanup
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_set_collection_file_invalid_filename(self):
        collection_name = 'collName1'+str(random.randint(0, 100))

        file_name = '../drawing.dwg'
        url = '/'.join(['', self.account_id, 'Collections', collection_name, 'Files'])
        params = {'fileName': file_name}
        file_obj = open('../../test_resources/screen.drw')
        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params(params, file_name, file_obj)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=post_data)
        self.assertEquals(400, response.code)

        #cleanup
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_set_collection_file_without_passing_file(self):

        collection_name = 'collName1'+str(random.randint(0, 100))

        file_name = 'drawing.dwg'
        url = '/'.join(['', self.account_id, 'Collections', collection_name, 'Files'])
        params = {'fileName': file_name}
        headers, post_data = HTTPHelper.create_multipart_request_with_parameters(params)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=post_data)
        self.assertEquals(400, response.code)

        #cleanup
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_get_collection_file(self):

        collection_name = 'collName1'+str(random.randint(0, 100))
        params = {'collectionName': collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)

        file_name = 'drawing.dwg'
        url = '/'.join(['', self.account_id, 'Collections', collection_name, 'Files'])
        params = {'fileName': file_name}
        file_obj = open('../../test_resources/screen.drw')
        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params(params, file_name, file_obj)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=post_data)
        self.assertEquals(200, response.code)

        url += '/' + file_name
        response = self.fetch(path=url, headers=headers, method='GET')

        self.assertEqual(200, response.code)

        #cleanup
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_get_collection_file_non_existing_file(self):

        collection_name = 'collName1'+str(random.randint(0, 100))
        params = {'collectionName': collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)

        file_name = 'drawing.dwg'
        url = '/'.join(['', self.account_id, 'Collections', collection_name, 'Files'])
        params = {'fileName': file_name}
        file_obj = open('../../test_resources/screen.drw')
        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params(params, file_name, file_obj)
        url += '/' + file_name

        response = self.fetch(path=url, headers=headers, method='GET')

        self.assertEqual(404, response.code)

        #cleanup
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_get_collection_invalid_filename(self):
        collection_name = 'collName1'+str(random.randint(0, 100))
        params = {'collectionName': collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)

        file_name = 'drawing.dwg'
        url = '/'.join(['', self.account_id, 'Collections', collection_name, 'Files'])
        params = {'fileName': file_name}
        file_obj = open('../../test_resources/screen.drw')
        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params(params, file_name, file_obj)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=post_data)
        self.assertEquals(200, response.code)

        url += '/../..' + file_name

        response = self.fetch(path=url, headers=headers, method='GET')

        self.assertEqual(404, response.code)

        #cleanup
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_remove_collection_file(self):

        collection_name = 'collName1'+str(random.randint(0, 100))
        params = {'collectionName': collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)

        file_name = 'drawing.dwg'
        url = '/'.join(['', self.account_id, 'Collections', collection_name, 'Files'])
        params = {'fileName': file_name}
        file_obj = open('../../test_resources/screen.drw')
        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params(params, file_name, file_obj)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=post_data)
        self.assertEquals(200, response.code)

        url += '/' + file_name
        response = self.fetch(path=url, headers=headers, method='GET')

        self.assertEqual(200, response.code)

        response = self.fetch(path=url, headers=headers, method='DELETE')
        self.assertEqual(200, response.code)

        response = self.fetch(path=url, headers=headers, method='GET')
        self.assertEqual(404, response.code)

        #cleanup
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')
