from __future__ import absolute_import

import re
from StringIO import StringIO
import urllib
from tornado import gen
from tornado.httpclient import AsyncHTTPClient

try:
    import json
except ImportError:
    import simplejson as json


def format_path(path):
    """Normalize path for use with the Dropbox API.

    This function turns multiple adjacent slashes into single
    slashes, then ensures that there's a leading slash but
    not a trailing slash.
    """
    if not path:
        return path

    path = re.sub(r'/+', '/', path)

    if path == '/':
        return (u"" if isinstance(path, unicode) else "")
    else:
        return '/' + path.strip('/')


class DropboxClient(object):
    """
    The main access point of doing REST calls on Dropbox. You should
    first create and configure a dropbox.session.DropboxSession object,
    and then pass it into DropboxClient's constructor. DropboxClient
    then does all the work of properly calling each API method
    with the correct OAuth authentication.

    You should be aware that any of these methods can raise a
    rest.ErrorResponse exception if the server returns a non-200
    or invalid HTTP response. Note that a 401 return status at any
    point indicates that the user needs to be reauthenticated.
    """

    def __init__(self, session):
        """Initialize the DropboxClient object.

        Args:
            ``session``: A dropbox.session.DropboxSession object to use for making requests.
            ``rest_client``: A dropbox.rest.RESTClient-like object to use for making requests. [optional]
        """
        self.session = session

    def request(self, target, params=None, method='POST', content_server=False):
        """Make an HTTP request to a target API method.

        This is an internal method used to properly craft the url, headers, and
        params for a Dropbox API request.  It is exposed for you in case you
        need craft other API calls not in this library or if you want to debug it.

        Args:
            - ``target``: The target URL with leading slash (e.g. '/files')
            - ``params``: A dictionary of parameters to add to the request
            - ``method``: An HTTP method (e.g. 'GET' or 'POST')
            - ``content_server``: A boolean indicating whether the request is to the
               API content server, for example to fetch the contents of a file
               rather than its metadata.

        Returns:
            - A tuple of (url, params, headers) that should be used to make the request.
              OAuth authentication information will be added as needed within these fields.
        """
        assert method in ['GET', 'POST', 'PUT'], "Only 'GET', 'POST', and 'PUT' are allowed."
        if params is None:
            params = {}

        host = self.session.API_CONTENT_HOST if content_server else self.session.API_HOST
        base = self.session.build_url(host, target)
        headers, params = self.session.build_access_headers(method, base, params)

        if method in ('GET', 'PUT'):
            url = self.session.build_url(host, target, params)
        else:
            url = self.session.build_url(host, target)

        return url, params, headers


    def get_chunked_uploader(self, file_obj, length):

        """Creates a ChunkedUploader to upload the given file-like object.

        Args:
            - ``file_obj``: The file-like object which is the source of the data
              being uploaded.
            - ``length``: The number of bytes to upload.

        The expected use of this function is as follows:

        .. code-block:: python

            bigFile = open("data.txt", 'rb')

            uploader = myclient.get_chunked_uploader(bigFile, size)
            print "uploading: ", size
            while uploader.offset < size:
                try:
                    upload = uploader.upload_chunked()
                except rest.ErrorResponse, e:
                    # perform error handling and retry logic

        The SDK leaves the error handling and retry logic to the developer
        to implement, as the exact requirements will depend on the application
        involved.
        """
        return DropboxClient.ChunkedUploader(self, file_obj, length)

    class ChunkedUploader(object):
        """Contains the logic around a chunked upload, which uploads a
        large file to Dropbox via the /chunked_upload endpoint
        """

        def __init__(self, client, file_obj, length):
            self.client = client
            self.offset = 0
            self.upload_id = None

            self.last_block = None
            self.file_obj = file_obj
            self.target_length = length


        def upload_chunked(self, chunk_size=4 * 1024 * 1024):
            """Uploads data from this ChunkedUploader's file_obj in chunks, until
            an error occurs. Throws an exception when an error occurs, and can
            be called again to resume the upload.

            Args:
                - ``chunk_size``: The number of bytes to put in each chunk. [default 4 MB]
            """

            while self.offset < self.target_length:
                next_chunk_size = min(chunk_size, self.target_length - self.offset)
                if self.last_block is None:
                    self.last_block = self.file_obj.read(next_chunk_size)

                try:
                    (self.offset, self.upload_id) = self.client.upload_chunk(StringIO(self.last_block), next_chunk_size,
                                                                             self.offset, self.upload_id)
                    self.last_block = None
                except ErrorResponse, e:
                    reply = e.body
                    if "offset" in reply and reply['offset'] != 0:
                        if reply['offset'] > self.offset:
                            self.last_block = None
                            self.offset = reply['offset']

        def finish(self, path, overwrite=False, parent_rev=None):
            """Commits the bytes uploaded by this ChunkedUploader to a file
            in the users dropbox.

            Args:
                - ``path``: The full path of the file in the Dropbox.
                - ``overwrite``: Whether to overwrite an existing file at the given path. [default False]
                  If overwrite is False and a file already exists there, Dropbox
                  will rename the upload to make sure it doesn't overwrite anything.
                  You need to check the metadata returned for the new name.
                  This field should only be True if your intent is to potentially
                  clobber changes to a file that you don't know about.
                - ``parent_rev``: The rev field from the 'parent' of this upload. [optional]
                  If your intent is to update the file at the given path, you should
                  pass the parent_rev parameter set to the rev value from the most recent
                  metadata you have of the existing file at that path. If the server
                  has a more recent version of the file at the specified path, it will
                  automatically rename your uploaded file, spinning off a conflict.
                  Using this parameter effectively causes the overwrite parameter to be ignored.
                  The file will always be overwritten if you send the most-recent parent_rev,
                  and it will never be overwritten if you send a less-recent one.
            """

            path = "/commit_chunked_upload/%s%s" % (self.client.session.root, format_path(path))

            params = dict(
                overwrite=bool(overwrite),
                upload_id=self.upload_id
            )

            if parent_rev is not None:
                params['parent_rev'] = parent_rev

            url, params, headers = self.client.request(path, params, content_server=True)

            return self.client.rest_client.POST(url, params, headers)

    def upload_chunk(self, file_obj, length, offset=0, upload_id=None):
        """Uploads a single chunk of data from the given file like object. The majority of users
        should use the ChunkedUploader object, which provides a simpler interface to the
        chunked_upload API endpoint.

        Args:
            - ``file_obj``: The source of the data to upload
            - ``length``: The number of bytes to upload in one chunk.

        Returns:
            - The reply from the server, as a dictionary
        """

        params = dict()

        if upload_id:
            params['upload_id'] = upload_id
            params['offset'] = offset

        url, ignored_params, headers = self.request("/chunked_upload", params, method='PUT', content_server=True)

        try:
            reply = self.rest_client.PUT(url, file_obj, headers)
            return reply['offset'], reply['upload_id']
        except ErrorResponse, e:
            raise e

    @gen.engine
    def put_file(self, full_path, file_obj, callback, overwrite=False, parent_rev=None):
        """Upload a file.

        A typical use case would be as follows:

        .. code-block:: python

            f = open('working-draft.txt')
            response = client.put_file('/magnum-opus.txt', f)
            print "uploaded:", response

        which would return the metadata of the uploaded file, similar to:

        .. code-block:: python

            {
                'bytes': 77,
                'icon': 'page_white_text',
                'is_dir': False,
                'mime_type': 'text/plain',
                'modified': 'Wed, 20 Jul 2011 22:04:50 +0000',
                'path': '/magnum-opus.txt',
                'rev': '362e2029684fe',
                'revision': 221922,
                'root': 'dropbox',
                'size': '77 bytes',
                'thumb_exists': False
            }

        Args:
            - ``full_path``: The full path to upload the file to, *including the file name*.
              If the destination directory does not yet exist, it will be created.
            - ``file_obj``: A file-like object to upload. If you would like, you can pass a string as file_obj.
            - ``overwrite``: Whether to overwrite an existing file at the given path. [default False]
              If overwrite is False and a file already exists there, Dropbox
              will rename the upload to make sure it doesn't overwrite anything.
              You need to check the metadata returned for the new name.
              This field should only be True if your intent is to potentially
              clobber changes to a file that you don't know about.
            - ``parent_rev``: The rev field from the 'parent' of this upload. [optional]
              If your intent is to update the file at the given path, you should
              pass the parent_rev parameter set to the rev value from the most recent
              metadata you have of the existing file at that path. If the server
              has a more recent version of the file at the specified path, it will
              automatically rename your uploaded file, spinning off a conflict.
              Using this parameter effectively causes the overwrite parameter to be ignored.
              The file will always be overwritten if you send the most-recent parent_rev,
              and it will never be overwritten if you send a less-recent one.

        Returns:
            - A dictionary containing the metadata of the newly uploaded file.

              For a detailed description of what this call returns, visit:
              https://www.dropbox.com/developers/reference/api#files-put

        Raises:
            - A dropbox.rest.ErrorResponse with an HTTP status of
              - 400: Bad request (may be due to many things; check e.error for details)
              - 503: User over quota

        Note: In Python versions below version 2.6, httplib doesn't handle file-like objects.
        In that case, this code will read the entire file into memory (!).
        """
        path = "/files_put/%s%s" % (self.session.root, format_path(full_path))

        params = {
            'overwrite': bool(overwrite),
        }

        if parent_rev is not None:
            params['parent_rev'] = parent_rev

        url, params, headers = self.request(path, params, method='PUT', content_server=True)

        http = AsyncHTTPClient()
        #in case someone read the file along the way
        file_obj.seek(0)
        body = file_obj.read()
        response = yield gen.Task(http.fetch, url, method='PUT', headers=headers, body=body)
        callback(response)

    @gen.engine
    def get_file(self, from_path, callback, rev=None):
        """Download a file.

        Unlike most other calls, get_file returns a raw HTTPResponse with the connection open.
        You should call .read() and perform any processing you need, then close the HTTPResponse.

        A typical usage looks like this:

        .. code-block:: python

            out = open('magnum-opus.txt', 'w')
            f, metadata = client.get_file_and_metadata('/magnum-opus.txt').read()
            out.write(f)

        which would download the file ``magnum-opus.txt`` and write the contents into
        the file ``magnum-opus.txt`` on the local filesystem.

        Args:
            - ``from_path``: The path to the file to be downloaded.
            - ``rev``: A previous rev value of the file to be downloaded. [optional]

        Returns:
            - An httplib.HTTPResponse that is the result of the request.

        Raises:
            - A dropbox.rest.ErrorResponse with an HTTP status of
              - 400: Bad request (may be due to many things; check e.error for details)
              - 404: No file was found at the given path, or the file that was there was deleted.
              - 200: Request was okay but response was malformed in some way.
        """
        path = "/files/%s%s" % (self.session.root, format_path(from_path))

        params = {}
        if rev is not None:
            params['rev'] = rev

        url, params, headers = self.request(path, params, method='GET', content_server=True)
        http = AsyncHTTPClient()
        response = yield gen.Task(http.fetch, url, method='GET', headers=headers)
        callback(response)

    def get_file_and_metadata(self, from_path, rev=None):
        """Download a file alongwith its metadata.

        Acts as a thin wrapper around get_file() (see get_file() comments for
        more details)

        Args:
            - ``from_path``: The path to the file to be downloaded.
            - ``rev``: A previous rev value of the file to be downloaded. [optional]

        Returns:
            - An httplib.HTTPResponse that is the result of the request.
            - A dictionary containing the metadata of the file (see
              https://www.dropbox.com/developers/reference/api#metadata for details).

        Raises:
            - A dropbox.rest.ErrorResponse with an HTTP status of
              - 400: Bad request (may be due to many things; check e.error for details)
              - 404: No file was found at the given path, or the file that was there was deleted.
              - 200: Request was okay but response was malformed in some way.
        """
        file_res = self.get_file(from_path, rev)
        metadata = DropboxClient.__parse_metadata_as_dict(file_res)

        return file_res, metadata

    @staticmethod
    def __parse_metadata_as_dict(dropbox_raw_response):
        """Parses file metadata from a raw dropbox HTTP response, raising a
        dropbox.rest.ErrorResponse if parsing fails.
        """
        metadata = None
        for header, header_val in dropbox_raw_response.getheaders():
            if header.lower() == 'x-dropbox-metadata':
                try:
                    metadata = json.loads(header_val)
                except ValueError:
                    raise ErrorResponse(dropbox_raw_response)
        if not metadata: raise ErrorResponse(dropbox_raw_response)
        return metadata


    @gen.engine
    def create_copy_ref(self, from_path, callback):
        """Creates and returns a copy ref for a specific file.  The copy ref can be
        used to instantly copy that file to the Dropbox of another account.

        Args:
         - ``path``: The path to the file for a copy ref to be created on.

        Returns:
            - A dictionary that looks like the following example:

              ``{"expires":"Fri, 31 Jan 2042 21:01:05 +0000", "copy_ref":"z1X6ATl6aWtzOGq0c3g5Ng"}``

        """
        path = "/copy_ref/%s%s" % (self.session.root, format_path(from_path))

        url, params, headers = self.request(path, {}, method='GET')
        http = AsyncHTTPClient()
        response = yield gen.Task(http.fetch, url, method='GET', headers=headers)
        callback(response)

    @gen.engine
    def add_copy_ref(self, copy_ref, to_path, callback):
        """Adds the file referenced by the copy ref to the specified path

        Args:
         - ``copy_ref``: A copy ref string that was returned from a create_copy_ref call.
           The copy_ref can be created from any other Dropbox account, or from the same account.
         - ``path``: The path to where the file will be created.

        Returns:
            - A dictionary containing the metadata of the new copy of the file.
         """
        path = "/fileops/copy"

        params = {'from_copy_ref': copy_ref,
                  'to_path': format_path(to_path),
                  'root': self.session.root}

        url, params, headers = self.request(path, params)
        http = AsyncHTTPClient()
        response = yield gen.Task(http.fetch, url,
                                  method='POST', headers=headers, body=urllib.urlencode(params))
        callback(response)

    def file_copy(self, from_path, to_path):
        """Copy a file or folder to a new location.

        Args:
            - ``from_path``: The path to the file or folder to be copied.
            - ``to_path``: The destination path of the file or folder to be copied.
              This parameter should include the destination filename (e.g.
              from_path: '/test.txt', to_path: '/dir/test.txt'). If there's
              already a file at the to_path, this copy will be renamed to
              be unique.

        Returns:
            - A dictionary containing the metadata of the new copy of the file or folder.

              For a detailed description of what this call returns, visit:
              https://www.dropbox.com/developers/reference/api#fileops-copy

        Raises:
            - A dropbox.rest.ErrorResponse with an HTTP status of:

              - 400: Bad request (may be due to many things; check e.error for details)
              - 404: No file was found at given from_path.
              - 503: User over storage quota.
        """
        params = {'root': self.session.root,
                  'from_path': format_path(from_path),
                  'to_path': format_path(to_path),
        }

        url, params, headers = self.request("/fileops/copy", params)

        return self.rest_client.POST(url, params, headers)


    @gen.engine
    def file_create_folder(self, path, callback):
        """Create a folder.

        Args:
            - ``path``: The path of the new folder.

        Returns:
            - A dictionary containing the metadata of the newly created folder.

              For a detailed description of what this call returns, visit:
              https://www.dropbox.com/developers/reference/api#fileops-create-folder

        Raises:
            - A dropbox.rest.ErrorResponse with an HTTP status of
              - 400: Bad request (may be due to many things; check e.error for details)
              - 403: A folder at that path already exists.
        """
        params = {'root': self.session.root, 'path': format_path(path)}

        url, params, headers = self.request("/fileops/create_folder", params)

        http = AsyncHTTPClient()
        response = yield gen.Task(http.fetch, url, method='POST', headers=headers,
                                  body=urllib.urlencode(params))
        callback(response)

    @gen.engine
    def file_delete(self, path, callback):
        """Delete a file or folder.

        Args:
            - ``path``: The path of the file or folder.

        Returns:
            - A dictionary containing the metadata of the just deleted file.

              For a detailed description of what this call returns, visit:
              https://www.dropbox.com/developers/reference/api#fileops-delete

        Raises:
          - 400: Bad request (may be due to many things; check e.error for details)
          - 404: No file was found at the given path.
        """
        params = {'root': self.session.root, 'path': format_path(path)}

        url, params, headers = self.request("/fileops/delete", params)

        http = AsyncHTTPClient()
        response = yield gen.Task(http.fetch, url, method='POST', headers=headers,
                                  body=urllib.urlencode(params))
        #for 503 retry three times
        counter = 0
        while response.code == 503 and counter < 3:
            counter_closure = counter
            response = yield gen.Task(http.fetch, url, method='POST', headers=headers,
                                      body=urllib.urlencode(params))
            counter_closure += 1
            counter = counter_closure
            print counter

        if response.code == 503:
            response = yield gen.Task(http.fetch, url, method='POST', headers=headers,
                                      body=urllib.urlencode(params))
        callback(response)


    @gen.engine
    def file_move(self, from_path, to_path, callback):
        """Move a file or folder to a new location.

        Args:
            - ``from_path``: The path to the file or folder to be moved.
            - ``to_path``: The destination path of the file or folder to be moved.
              This parameter should include the destination filename (e.g.
            - ``from_path``: '/test.txt', to_path: '/dir/test.txt'). If there's
              already a file at the to_path, this file or folder will be renamed to
              be unique.

        Returns:
            - A dictionary containing the metadata of the new copy of the file or folder.

              For a detailed description of what this call returns, visit:
              https://www.dropbox.com/developers/reference/api#fileops-move

        Raises:
            - A dropbox.rest.ErrorResponse with an HTTP status of

              - 400: Bad request (may be due to many things; check e.error for details)
              - 404: No file was found at given from_path.
              - 503: User over storage quota.
        """
        params = {'root': self.session.root, 'from_path': format_path(from_path), 'to_path': format_path(to_path)}

        url, params, headers = self.request("/fileops/move", params)

        http = AsyncHTTPClient()
        response = yield gen.Task(http.fetch, url, method='POST', headers=headers,
                                  body=urllib.urlencode(params))
        callback(response)


    @gen.engine
    def metadata(self, path, callback, list=True, file_limit=25000, hash=None, rev=None, include_deleted=False):
        """Retrieve metadata for a file or folder.

        A typical use would be:

        .. code-block:: python

            folder_metadata = client.metadata('/')
            print "metadata:", folder_metadata

        which would return the metadata of the root directory. This
        will look something like:

        .. code-block:: python

            {
                'bytes': 0,
                'contents': [
                    {
                       'bytes': 0,
                       'icon': 'folder',
                       'is_dir': True,
                       'modified': 'Thu, 25 Aug 2011 00:03:15 +0000',
                       'path': '/Sample Folder',
                       'rev': '803beb471',
                       'revision': 8,
                       'root': 'dropbox',
                       'size': '0 bytes',
                       'thumb_exists': False
                    },
                    {
                       'bytes': 77,
                       'icon': 'page_white_text',
                       'is_dir': False,
                       'mime_type': 'text/plain',
                       'modified': 'Wed, 20 Jul 2011 22:04:50 +0000',
                       'path': '/magnum-opus.txt',
                       'rev': '362e2029684fe',
                       'revision': 221922,
                       'root': 'dropbox',
                       'size': '77 bytes',
                       'thumb_exists': False
                    }
                ],
                'hash': 'efdac89c4da886a9cece1927e6c22977',
                'icon': 'folder',
                'is_dir': True,
                'path': '/',
                'root': 'app_folder',
                'size': '0 bytes',
                'thumb_exists': False
            }

        In this example, the root directory contains two things: ``Sample Folder``,
        which is a folder, and ``/magnum-opus.txt``, which is a text file 77 bytes long

        Args:
            - ``path``: The path to the file or folder.
            - ``list``: Whether to list all contained files (only applies when
              path refers to a folder).
            - ``file_limit``: The maximum number of file entries to return within
              a folder. If the number of files in the directory exceeds this
              limit, an exception is raised. The server will return at max
              25,000 files within a folder.
            - ``hash``: Every directory listing has a hash parameter attached that
              can then be passed back into this function later to save on\
              bandwidth. Rather than returning an unchanged folder's contents,\
              the server will instead return a 304.\
            - ``rev``: The revision of the file to retrieve the metadata for. [optional]
              This parameter only applies for files. If omitted, you'll receive
              the most recent revision metadata.

        Returns:
            - A dictionary containing the metadata of the file or folder
              (and contained files if appropriate).

              For a detailed description of what this call returns, visit:
              https://www.dropbox.com/developers/reference/api#metadata

        Raises:
            - A dropbox.rest.ErrorResponse with an HTTP status of

              - 304: Current directory hash matches hash parameters, so contents are unchanged.
              - 400: Bad request (may be due to many things; check e.error for details)
              - 404: No file was found at given path.
              - 406: Too many file entries to return.
        """
        path = "/metadata/%s%s" % (self.session.root, format_path(path))

        params = {'file_limit': file_limit,
                  'list': 'true',
                  'include_deleted': include_deleted,
        }

        if not list:
            params['list'] = 'false'
        if hash is not None:
            params['hash'] = hash
        if rev:
            params['rev'] = rev

        url, params, headers = self.request(path, params, method='GET')

        http = AsyncHTTPClient()
        response = yield gen.Task(http.fetch, url, method='GET', headers=headers)
        response_json = json.loads(response.body)
        callback(response_json)


    def search(self, path, query, file_limit=1000, include_deleted=False):
        """Search directory for filenames matching query.

        Args:
            - ``path``: The directory to search within.
            - ``query``: The query to search on (minimum 3 characters).
            - ``file_limit``: The maximum number of file entries to return within a folder.
              The server will return at max 1,000 files.
            - ``include_deleted``: Whether to include deleted files in search results.

        Returns:
            - A list of the metadata of all matching files (up to
              file_limit entries).  For a detailed description of what
              this call returns, visit:
              https://www.dropbox.com/developers/reference/api#search

        Raises:
            - A dropbox.rest.ErrorResponse with an HTTP status of
              - 400: Bad request (may be due to many things; check e.error for details)
        """
        path = "/search/%s%s" % (self.session.root, format_path(path))

        params = {
            'query': query,
            'file_limit': file_limit,
            'include_deleted': include_deleted,
        }

        url, params, headers = self.request(path, params)

        return self.rest_client.POST(url, params, headers)


    def share(self, path):
        """Create a shareable link to a file or folder.

        Shareable links created on Dropbox are time-limited, but don't require any
        authentication, so they can be given out freely. The time limit should allow
        at least a day of shareability, though users have the ability to disable
        a link from their account if they like.

        Args:
            - ``path``: The file or folder to share.

        Returns:
            - A dictionary that looks like the following example:

              ``{'url': 'http://www.dropbox.com/s/m/a2mbDa2', 'expires': 'Thu, 16 Sep 2011 01:01:25 +0000'}``

              For a detailed description of what this call returns, visit:
              https://www.dropbox.com/developers/reference/api#shares

        Raises:
            - A dropbox.rest.ErrorResponse with an HTTP status of

              - 400: Bad request (may be due to many things; check e.error for details)
              - 404: Unable to find the file at the given path.
        """
        path = "/shares/%s%s" % (self.session.root, format_path(path))

        url, params, headers = self.request(path, method='GET')

        return self.rest_client.GET(url, headers)

