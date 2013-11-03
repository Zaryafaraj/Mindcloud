import json
import random
import urllib
import uuid
from tornado.httputil import HTTPHeaders
from tornado.ioloop import IOLoop
from tornado.testing import AsyncHTTPTestCase
from Tests.ApiTets.HTTPHelper import HTTPHelper
from Tests.TestingProperties import TestingProperties
from TornadoMain import Application


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
        headers, postData = HTTPHelper.create_multipart_request_with_file_and_params(params, file_name, file_obj)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=postData)
        self.assertEquals(200, response.code)

        #cleanup
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
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
        headers, postData = HTTPHelper.create_multipart_request_with_single_file(file_name, file_obj)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=postData)
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
        headers, postData = HTTPHelper.create_multipart_request_with_file_and_params(params, file_name, file_obj)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=postData)
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
        headers, postData = HTTPHelper.create_multipart_request_with_file_and_params(params, file_name, file_obj)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=postData)
        self.assertEquals(400, response.code)

        #cleanup
        url = '/'.join(['', self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_set_collection_file_without_passing_file(self):

        collection_name = 'collName1'+str(random.randint(0, 100))

        file_name = 'drawing.dwg'
        url = '/'.join(['', self.account_id, 'Collections', collection_name, 'Files'])
        params = {'fileName': file_name}
        headers, postData = HTTPHelper.create_multipart_request_with_parameters(params)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=postData)
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
        headers, postData = HTTPHelper.create_multipart_request_with_file_and_params(params, file_name, file_obj)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=postData)
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
        headers, postData = HTTPHelper.create_multipart_request_with_file_and_params(params, file_name, file_obj)
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
        headers, postData = HTTPHelper.create_multipart_request_with_file_and_params(params, file_name, file_obj)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=postData)
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
        headers, postData = HTTPHelper.create_multipart_request_with_file_and_params(params, file_name, file_obj)
        response = self.fetch(path=url, headers=headers, method='POST',
                              body=postData)
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
        pass

