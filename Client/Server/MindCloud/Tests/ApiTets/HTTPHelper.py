from tornado.httputil import HTTPHeaders

__author__ = 'afathali'

class HTTPHelper:
    """
    Helper class for consturcting http request
    """
    @staticmethod
    def create_multipart_request_with_parameters(params):
        boundary = '----------------------------62ae4a76207c'
        content_type = 'multipart/form-data; boundary=' + boundary
        headers = HTTPHeaders({'content-type':content_type})
        postData = ''
        for paramName in params:
            postData = "--" + boundary +\
                       "\r\nContent-Disposition: form-data; name=\""\
                       + paramName + "\"\r\n\r\n"
            postData += params[paramName]
        postData += "\r\n--" + boundary + "--"
        return headers, postData

    @staticmethod
    def create_multipart_request_with_single_file(file_name, file):
        boundary = '----------------------------62ae4a76207c'
        content_type = 'multipart/form-data; boundary=' + boundary
        headers = HTTPHeaders({'content-type':content_type})
        postData = "--" + boundary +\
                   "\r\nContent-Disposition: form-data; name=\""+ file_name + \
                   "\"; filename=\"Xooml.xml\"\r\nContent-Type: application/xml\r\n\r\n"
        postData += file.read()
        postData += "\r\n--" + boundary + "--"
        return headers, postData

    @staticmethod
    def create_multipart_request_with_file_and_params(
            params, file_name, file):

        boundary = '----------------------------62ae4a76207c'
        content_type = 'multipart/form-data; boundary=' + boundary
        headers = HTTPHeaders({'content-type':content_type})
        postData = "--" + boundary +\
                   "\r\nContent-Disposition: form-data; name=\"" + file_name + \
                   "\"; filename=\"Xooml.xml\"\r\nContent-Type: application/xml\r\n\r\n"
        postData += file.read()
        for param_name in params:
            postData += "\r\n--" + boundary +\
                        "\r\nContent-Disposition: form-data; name=\""\
                        + param_name + "\"\r\n\r\n"
            postData += params[param_name]
        postData += "\r\n--" + boundary + "--"
        return headers, postData

