from tornado.httputil import HTTPHeaders
from tornado.ioloop import IOLoop
from tornado.testing import AsyncHTTPTestCase
from TornadoMain import Application

__author__ = 'afathali'

class CategoriesTests(AsyncHTTPTestCase):

    account_id = '04B08CB7-17D5-493A-8ED1-E086FDC1327E'

    def get_new_ioloop(self):
        return IOLoop.instance()

    def get_app(self):
        application = Application()
        return application

    def _create_multipart_request(self, file):
        boundary = '----------------------------62ae4a76207c'
        content_type = 'multipart/form-data; boundary=' + boundary
        headers = HTTPHeaders({'content-type':content_type})
        postData = "--" + boundary +\
                   "\r\nContent-Disposition: form-data; name=\"file\"; filename=\"thumbnail.jpg\"\r\nContent-Type: image/jpeg\r\n\r\n"
        postData += file.read()
        postData += "\r\n--" + boundary + "--"
        return headers, postData

    def test_add_categories(self):
        categories_file = open('../test_resources/categories.xml')
        url = '/' + self.account_id + '/Categories'
        headers, post_data = self._create_multipart_request(categories_file)
        response = self.fetch(path=url, headers=headers, method='POST',
            body=post_data)
        self.assertEqual(200, response.code)

