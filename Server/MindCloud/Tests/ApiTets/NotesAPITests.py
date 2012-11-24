import json
from tornado.httputil import HTTPHeaders

__author__ = 'afathali'
import urllib
from tornado.ioloop import IOLoop
from tornado.testing import AsyncHTTPTestCase
from Tests.ApiTets.HTTPHelper import HTTPHelper
from TornadoMain import Application

__author__ = 'afathali'

class NotesTests(AsyncHTTPTestCase):

    account_id = '04B08CB7-17D5-493A-8ED1-E086FDC1327E'

    def get_new_ioloop(self):
        return IOLoop.instance()

    def get_app(self):
        application = Application()
        return application

    def test_get_all_notes(self):
        collection_name = 'collName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        note_file = open('../test_resources/note.xml')
        url += '/' + collection_name + '/Notes'
        params = {'noteName' : 'NoteName'}
        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params\
            (params, 'file', note_file)
        response = self.fetch(path=url, headers=headers, method='POST',
            body=post_data)
        self.assertEqual(200, response.code)

        url = '/'.join(['', self.account_id, 'Collections', collection_name, 'Notes'])
        response = self.fetch(path=url, method='GET')
        self.assertEqual(200, response.code)
        response_json = json.loads(response.body)
        self.assertTrue(len(response_json) == 1)

        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_save_note_with_file(self):

        collection_name = 'collName'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        note_file = open('../test_resources/note.xml')
        url += '/' + collection_name + '/Notes'
        params = {'noteName' : 'NoteName'}
        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params\
            (params, 'file', note_file)
        response = self.fetch(path=url, headers=headers, method='POST',
            body=post_data)
        self.assertEqual(200, response.code)
        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_get_note(self):

        collection_name = 'collName'
        note_name = 'note_name'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        note_file = open('../test_resources/note.xml')
        url += '/' + collection_name + '/Notes'
        params = {'noteName' : note_name}
        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params\
            (params, 'file', note_file)
        response = self.fetch(path=url, headers=headers, method='POST',
            body=post_data)
        self.assertEqual(200, response.code)

        url += '/' + note_name
        response = self.fetch(path=url,method='GET')
        self.assertEqual(200, response.code)
        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_get_invalid_note(self):
        url = '/'.join(['', self.account_id, 'Collections', 'dummyyy','Notes', 'dummy'])
        headers = HTTPHeaders()
        response = self.fetch(path=url,method='GET', headers=headers)
        self.assertEqual(404, response.code)

    def test_update_note(self):

        collection_name = 'collName'
        note_name = 'notename'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        note_file = open('../test_resources/note.xml')
        url += '/' + collection_name + '/Notes'
        params = {'noteName' : note_name}
        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params\
            (params, 'file', note_file)
        response = self.fetch(path=url, headers=headers, method='POST',
            body=post_data)
        self.assertEqual(200, response.code)

        #update
        note_file = open('../test_resources/note2.xml')
        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params\
            (params, 'file', note_file)
        response = self.fetch(path=url, headers=headers, method='POST',
            body=post_data)
        self.assertEqual(200, response.code)

        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

    def test_remove_note(self):

        collection_name = 'collName'
        note_name = 'note_name'
        params = {'collectionName':collection_name}
        url = '/'+self.account_id + '/Collections'
        response = self.fetch(path=url, method='POST', body=urllib.urlencode(params))
        self.assertEqual(200, response.code)
        note_file = open('../test_resources/note.xml')
        url += '/' + collection_name + '/Notes'
        params = {'noteName' : note_name}
        headers, post_data = HTTPHelper.create_multipart_request_with_file_and_params\
            (params, 'file', note_file)
        response = self.fetch(path=url, headers=headers, method='POST',
            body=post_data)
        self.assertEqual(200, response.code)

        #Delete
        del_url = '/'.join(['', self.account_id, 'Collections', collection_name, 'Notes', note_name])
        self.fetch(path=del_url, method='GET')
        self.assertEqual(200, response.code)

        #cleanup
        url = '/'.join(['',self.account_id, 'Collections', collection_name])
        self.fetch(path=url, method='DELETE')

