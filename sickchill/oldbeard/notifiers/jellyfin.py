from urllib.parse import urljoin

import requests
from requests import RequestException
from requests.structures import CaseInsensitiveDict

from sickchill import logger, settings


class Notifier(object):
    def _make_headers(self, jellyfin_apikey=None):
        return CaseInsensitiveDict({"X-Emby-Token": jellyfin_apikey or settings.JELLYFIN_APIKEY, "Content-Type": "application/json"})

    def _notify_jellyfin(self, message, host=None, jellyfin_apikey=None):
        """Handles notifying Jellyfin host via HTTP API
        Returns:
            Returns True for no issue or False if there was an error
        """
        # https://api.jellyfin.org/#tag/Notifications/operation/CreateAdminNotification
        url = urljoin(host or settings.JELLYFIN_HOST, "Notifications/Admin")
        params = {"Name": "SickChill", "Description": message, "NotificationLevel": "Normal"}

        if not settings.USE_JELLYFIN:
            logger.debug("Notification for Jellyfin not enabled, skipping this notification")
            return False

        try:
            response = requests.post(url, json=params, headers=self._make_headers(jellyfin_apikey))
            if response:
                logger.debug(_("JELLYFIN: HTTP response: {content}").format(content=response.content))
            response.raise_for_status()

            return True
        except RequestException as error:
            logger.warning(_("JELLYFIN: Warning: Could not contact Jellyfin at {url} {error}").format(url=url, error=error))
            return False

    ##############################################################################
    # Public functions
    ##############################################################################

    def test_notify(self, host, jellyfin_apikey):
        return self._notify_jellyfin(_("This is a test notification from SickChill"), host, jellyfin_apikey)

    def update_library(self, show=None):
        """Handles updating the Jellyfin Media Server via HTTP API
        Returns:
            Returns True for no issue or False if there was an error
        """

        if settings.USE_JELLYFIN:
            if not settings.JELLYFIN_HOST:
                logger.debug(_("JELLYFIN: No host specified, check your settings"))
                return False

            params = {}
            if show:
                params.update({"TvdbId": show.indexerid})
                # https://api.jellyfin.org/#tag/Library/operation/PostAddedSeries
                url = urljoin(settings.JELLYFIN_HOST, "Library/Series/Added")
            else:
                # https://api.jellyfin.org/#tag/Library/operation/RefreshLibrary
                url = urljoin(settings.JELLYFIN_HOST, "Library/Refresh")

            try:
                response = requests.post(url, params=params, headers=self._make_headers())
                response.raise_for_status()
                logger.debug(_("JELLYFIN: HTTP status: {status_code}, response: {content}").format(status_code=response.status_code, content=response.content))
                return True

            except requests.exceptions.RequestException as error:
                logger.warning(_("JELLYFIN: Warning: Could not contact Jellyfin at {url} {error}").format(url=url, error=error))

                return False
