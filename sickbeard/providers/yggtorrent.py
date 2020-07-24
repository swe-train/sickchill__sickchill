# coding=utf-8
# Author: adaur <adaur.underground@gmail.com>
# Contributor: PHD <phd59fr@gmail.com>, pluzun <pluzun59@gmail.com>
#
# URL: https://sickchill.github.io
#
# This file is part of SickChill.
#
# SickChill is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# SickChill is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with SickChill. If not, see <http://www.gnu.org/licenses/>.
# Stdlib Imports
import re
from urllib.parse import urljoin

# Third Party Imports
import validators

# First Party Imports
from sickbeard import logger, tvcache
from sickbeard.bs4_parser import BS4Parser
from sickchill.helper.common import convert_size, try_int
from sickchill.providers.torrent.TorrentProvider import TorrentProvider


class YggTorrentProvider(TorrentProvider):

    def __init__(self):

        # Provider Init
        TorrentProvider.__init__(self, 'YggTorrent')

        # Credentials
        self.username = None
        self.password = None

        # Torrent Stats
        self.minseed = 0
        self.minleech = 0

        # URLs
        self.custom_url = None
        self.url = 'https://www2.yggtorrent.se/'
        self.urls = {
            'login': urljoin(self.url, 'user/login'),
            'search': urljoin(self.url, 'engine/search')
        }

        # Proper Strings
        self.proper_strings = ['PROPER']

        # Cache
        self.cache = tvcache.TVCache(self, min_time=30)

    def update_urls(self, new_url, custom=False):
        if custom and not new_url:
            return True

        if not validators.url(new_url):
            if custom:
                logger.warning("Invalid custom url: {0}".format(self.custom_url))
            else:
                logger.debug('Url changing has failed!')

            return False

        self.url = new_url
        self.urls = {
            'login': urljoin(self.url, 'user/login'),
            'search': urljoin(self.url, 'engine/search')
        }
        return True

    def login(self):
        login_params = {
            'id': self.username,
            'pass': self.password,
        }

        self.update_urls(self.custom_url, True)

        response = self.get_url(self.urls['login'], post_data=login_params, returns='response')
        if response and self.url not in response.url:
            new_url = response.url.split('user/login')[0]
            logger.debug('Changing base url from {} to {}'.format(self.url, new_url))
            if not self.update_urls(new_url):
                return False

            response = self.get_url(self.urls['login'], post_data=login_params, returns='response')

        # The login is now an AJAX call (401 : Bad credentials, 200 : Logged in, other : server failure)
        if not response or response.status_code != 200:
            logger.warning('Unable to connect to provider')
            return False
        else:
            # It seems we are logged, let's verify that !
            response = self.get_url(self.url, returns='response')

            if response.status_code != 200:
                logger.warning('Unable to connect to provider')
                return False
            if 'logout' not in response.text:
                logger.warning('Invalid username or password. Check your settings')
                return False

        return True

    def search(self, search_strings, age=0, ep_obj=None):
        self.login()

        results = []

        for mode in search_strings:
            items = []
            logger.debug('Search Mode: {0}'.format(mode))

            for search_string in search_strings[mode]:

                if mode != 'RSS':
                    logger.debug('Search string: {0}'.format(search_string))
                # search string needs to be normalized, single quotes are apparently not allowed on the site
                # ç should also be replaced, people tend to use c instead
                replace_chars = {
                                "'": '',
                                "ç": 'c'
                }

                for k, v in replace_chars.items():
                    search_string = search_string.replace(k, v)

                logger.debug('Sanitized string: {0}'.format(search_string))

                try:
                    search_params = {
                        'category': '2145',
                        'sub_category' : 'all',
                        'name': re.sub(r'[()]', '', search_string),
                        'do': 'search'
                    }

                    data = self.get_url(self.urls['search'], params=search_params, returns='text')
                    if not data:
                        continue

                    if 'logout' not in data:
                        logger.debug('Refreshing cookies')
                        self.login()

                    with BS4Parser(data, 'html5lib') as html:
                        torrent_table = html.find(class_='table')
                        torrent_rows = torrent_table('tr') if torrent_table else []

                        # Continue only if at least one Release is found
                        if len(torrent_rows) < 2:
                            logger.debug('Data returned from provider does not contain any torrents')
                            continue

                        # Skip column headers
                        for result in torrent_rows[1:]:
                            cells = result('td')
                            if len(cells) < 9:
                                continue

                            title = cells[1].find('a').get_text(strip=True)
                            id = cells[2].find('a')['target']
                            download_url = urljoin(self.url, 'engine/download_torrent?id=' + id)

                            if not (title and download_url):
                                continue

                            seeders = try_int(cells[7].get_text(strip=True))
                            leechers = try_int(cells[8].get_text(strip=True))

                            torrent_size = cells[5].get_text()
                            size = convert_size(torrent_size) or -1

                            # Filter unseeded torrent
                            if seeders < self.minseed or leechers < self.minleech:
                                if mode != 'RSS':
                                    logger.debug('Discarding torrent because it doesn\'t meet the minimum seeders or leechers: {0} (S:{1} L:{2})'.format
                                               (title, seeders, leechers))
                                continue

                            item = {'title': title, 'link': download_url, 'size': size, 'seeders': seeders, 'leechers': leechers, 'hash': ''}
                            if mode != 'RSS':
                                logger.debug('Found result: {0} with {1} seeders and {2} leechers'.format
                                           (title, seeders, leechers))

                            items.append(item)

                except (AttributeError, TypeError, KeyError, ValueError):
                    logger.exception('Failed parsing provider {}.'.format(self.name))

            # For each search mode sort all the items by seeders if available
            items.sort(key=lambda d: try_int(d.get('seeders', 0)), reverse=True)
            results += items

        return results


provider = YggTorrentProvider()
