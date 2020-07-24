# coding=utf-8
# Author: Nic Wolfe <nic@wolfeden.ca>
# 2019-11-29 : Updated by Benj to comply with Tvdb API V3
# 2019-12-01 : Made sure update will be done when the cache is empty
#    or the last update is more then a week old.
#    Also remove the hardcoded api key and use the one from indexer_config
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
import datetime
import threading
import time

# First Party Imports
import sickchill
from sickbeard import db, logger, network_timezones, ui
from sickchill import settings
from sickchill.helper.exceptions import CantRefreshShowException, CantUpdateShowException


class ShowUpdater(object):
    def __init__(self):
        self.lock = threading.Lock()
        self.amActive = False

        self.seven_days = 7*24*60*60

    def run(self, force=False):
        if self.amActive:
            return

        self.amActive = True
        try:
            logger.info('ShowUpdater for tvdb Api V3 starting')

            cache_db_con = db.DBConnection('cache.db')
            for index, provider in sickchill.indexer:
                database_result = cache_db_con.select('SELECT `time` FROM lastUpdate WHERE provider = ?', [provider.name])
                last_update = int(database_result[0][0]) if database_result else 0
                network_timezones.update_network_dict()
                update_timestamp = int(time.time())
                updated_shows = []

                if last_update:
                    logger.info('Last update: {}'.format(time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(last_update))))

                    current_check = update_timestamp
                    while current_check >= last_update:

                        try:
                            TvdbData = sickchill.indexer[1].updates(fromTime=current_check - self.seven_days, toTime=current_check)
                            TvdbData.series()
                            updated_shows.extend([d['id'] for d in TvdbData.series])
                        except Exception as error:
                            logger.info(str(error))

                        current_check -= self.seven_days - 1
                else:
                    logger.info(_('No last update time from the cache, so we do a full update for all shows'))

                pi_list = []
                for cur_show in settings.showList:
                    try:
                        cur_show.nextEpisode()

                        skip_update = False
                        # Skip ended shows until interval is met
                        if cur_show.status == 'Ended' and settings.ENDED_SHOWS_UPDATE_INTERVAL != 0:  # 0 is always
                            if settings.ENDED_SHOWS_UPDATE_INTERVAL == -1:  # Never
                                skip_update = True
                            if (datetime.datetime.today() - datetime.datetime.fromordinal(cur_show.last_update_indexer or 1)).days < \
                                    settings.ENDED_SHOWS_UPDATE_INTERVAL:
                                skip_update = True

                        # Just update all of the shows for now until they fix the updates api
                        # When last_update is not set from the cache or the show was in the tvdb updated list we update the show
                        if not last_update or (cur_show.indexerid in updated_shows and not skip_update):
                            pi_list.append(settings.showQueueScheduler.action.update_show(cur_show, True))
                        else:
                            pi_list.append(settings.showQueueScheduler.action.refresh_show(cur_show, force))
                    except (CantUpdateShowException, CantRefreshShowException) as error:
                        logger.info(_('Automatic update failed: {0}').format(str(error)))

                ui.ProgressIndicators.setIndicator('dailyUpdate', ui.QueueProgressIndicator('Daily Update', pi_list))

                if database_result:
                    cache_db_con.action('UPDATE lastUpdate SET `time` = ? WHERE provider = ?', [str(update_timestamp), provider.name])
                else:
                    cache_db_con.action('INSERT INTO lastUpdate (time, provider) VALUES (?, ?)', [str(update_timestamp), provider.name])
        except Exception as error:
            logger.exception(str(error))

        self.amActive = False

    @staticmethod
    def request_hook(response, **kwargs):
        logger.info('{0} URL: {1} [Status: {2}]'.format
                   (response.request.method, response.request.url, response.status_code))

    def __del__(self):
        pass
