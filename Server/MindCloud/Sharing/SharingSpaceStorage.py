from Sharing.SharingSpaceController import SharingSpaceController

__author__ = 'afathali'

class SharingSpaceStorage():

    __sharing_spaces = {}

    @staticmethod
    def get_sharing_space(sharing_secret):
        if sharing_secret in SharingSpaceStorage.__sharing_spaces:
            return SharingSpaceStorage.__sharing_spaces[sharing_secret]
        else:
            sharing_space = SharingSpaceController()
            SharingSpaceStorage.__sharing_spaces[sharing_secret] = sharing_space
            return sharing_space

