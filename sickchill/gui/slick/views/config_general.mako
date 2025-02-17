<%inherit file="/layouts/config.mako" />
<%!
    import os
    import datetime

    from sickchill import settings
    from sickchill.oldbeard.common import SKIPPED, ARCHIVED, IGNORED, statusStrings, cpu_presets
    from sickchill.oldbeard.filters import hide
    from sickchill.oldbeard.scdatetime import scdatetime, date_presets, time_presets
    from sickchill.oldbeard.helpers import anon_url, LOCALE_NAMES
    import sickchill
    import sickchill.init_helpers

    def lang_name(code):
        return LOCALE_NAMES.get(code, {}).get("name", "Unknown")
%>

<%block name="tabs">
    <li><a href="#misc">${_('Misc')}</a></li>
    <li><a href="#interface">${_('Interface')}</a></li>
    <li><a href="#logging-settings">${_('Logging')}</a></li>
    <li><a href="#advanced-settings">${_('Advanced')}</a></li>
</%block>

<%block name="pages">
    <form id="configForm" action="saveGeneral" method="post">

        <!-- /misc //-->
        <div id="misc">
            <!-- Misc -->
            <div class="row">
                <div class="col-lg-3 col-md-4 col-sm-4 col-xs-12">
                    <div class="component-group-desc">
                        <h3>${_('Misc')}</h3>
                        <p>${_('Startup and Indexer options.')}</p>
                        <p>${_('Show file locations.')}</p>
                        <p><b>${_('Some options may require a manual restart to take effect.')}</b></p>
                    </div>
                </div>
                <div class="col-lg-9 col-md-8 col-sm-8 col-xs-12">
                    <fieldset class="component-group-list">

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Default Indexer Language')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <select name="indexerDefaultLang" id="indexerDefaultLang" class="form-control form-control-inline input-sm input350
                                        bfh-languages" data-language="${settings.INDEXER_DEFAULT_LANGUAGE}" data-available="${','.join(sickchill.indexer.languages())}"></select>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="indexerDefaultLang">${_('for adding shows and metadata providers')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Launch browser')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="launch_browser" id="launch_browser" ${checked(settings.LAUNCH_BROWSER)}/>
                                <label for="launch_browser">${_('open the SickChill home page on startup')}</label>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Initial page')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <select id="default_page" name="default_page" class="form-control input-sm input150">
                                            <option value="home" ${selected(settings.DEFAULT_PAGE == 'home')}>${_('Shows')}</option>
                                            <option value="schedule" ${selected(settings.DEFAULT_PAGE == 'schedule')}>${_('Schedule')}</option>
                                            <option value="history" ${selected(settings.DEFAULT_PAGE == 'history')}>${_('History')}</option>
                                            <option value="news" ${selected(settings.DEFAULT_PAGE == 'news')}>${_('News')}</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="default_page">${_('when launching SickChill interface')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Large Screen Margins')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="checkbox" name="no_lgmargin" id="no_lgmargin" ${checked(settings.NO_LGMARGIN)}/>
                                        <label for="no_lgmargin">${_('No side margins on large screens')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        ## Fix
                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Hour to update shows')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="number" min="0" max="23" step="1" name="showupdate_hour" id="showupdate_hour" value="${settings.SHOWUPDATE_HOUR}" class="form-control input-sm input75" autocapitalize="off" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="showupdate_hour">${_('with information such as next air dates, show ended, etc. Use 15 for 3pm, 4 for 4am etc.')}</label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label><b>${_('note')}:</b>&nbsp;${_('minutes are randomized each time SickChill is started')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Days to wait before updating paused and ended shows')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input class="form-control input-sm input75" type="number" name="ended_shows_update_interval" id="ended_shows_update_interval" min="-1" max="365"
                                               value="${settings.ENDED_SHOWS_UPDATE_INTERVAL}">
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="ended_shows_update_interval">
                                            ${_('Paused and Ended shows will only be updated after this many days have passed, if there is an update for the show')}
                                        </label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label><b>${_('note')}:</b>&nbsp;${_('Default 7, daily 0, never -1')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Send to trash for actions')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="checkbox" name="trash_remove_show" id="trash_remove_show" ${checked(settings.TRASH_REMOVE_SHOW)}/>
                                        <label for="trash_remove_show">${_('when using show "Remove" and delete files')}</label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="checkbox" name="trash_rotate_logs" id="trash_rotate_logs" ${checked(settings.TRASH_ROTATE_LOGS)}/>
                                        <label for="trash_rotate_logs">${_('on scheduled deletes of the oldest log files')}</label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <span>${_('selected actions use trash (recycle bin) instead of the default permanent delete')}</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Use initial indexer set to')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <select id="indexer_default" name="indexer_default" class="form-control input-sm input150">
                                            <option value="0" ${selected(settings.INDEXER_DEFAULT == 0)}>${_('All Indexers')}</option>
                                            % for indexer, instance in sickchill.indexer:
                                                <option value="${indexer}" ${selected(settings.INDEXER_DEFAULT == indexer)}>${instance.name}</option>
                                            % endfor
                                        </select>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="indexer_default">${_('as the default selection when adding new shows')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Timeout show indexer at')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="number" min="10" step="1" name="indexer_timeout" id="indexer_timeout" value="${settings.INDEXER_TIMEOUT}" class="form-control input-sm input75" autocapitalize="off" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="indexer_timeout">${_('seconds of inactivity when finding new shows (default:20)')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Show root directories')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <span>${_('where the files of shows are located')}</span>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-lg-6 col-md-8 col-sm-12 col-xs-12">
                                        <%include file="/inc_rootDirs.mako" />
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-12">
                                <input type="submit" class="btn config_submitter" value="${_('Save Changes')}" />
                            </div>
                        </div>
                    </fieldset>
                </div>
            </div>

            <!-- Divider -->
            <div class="config-group-divider"></div>

            <!-- Updates -->
            <div class="row">
                <div class="col-lg-3 col-md-4 col-sm-4 col-xs-12">
                    <div class="component-group-desc">
                        <h3>${_('Updates')}</h3>
                        <p>${_('Options for software updates.')}</p>
                    </div>
                </div>
                <div class="col-lg-9 col-md-8 col-sm-8 col-xs-12">
                    <fieldset class="component-group-list">

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Check for software updates')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="version_notify" id="version_notify" ${checked(settings.VERSION_NOTIFY)}/>
                                <label for="version_notify">${_('''display notifications when updates are available. Checks are run on startup and at the frequency set below*''')}</label>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Automatically update')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="auto_update" id="auto_update" ${checked(settings.AUTO_UPDATE)}/>
                                <label for="auto_update">${_('''fetch and install software updates. Updates are run on startup and in the background at the frequency set below*''')}</label>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Check the server every*')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="number" min="1" step="1" name="update_frequency" id="update_frequency" value="${settings.UPDATE_FREQUENCY}" class="form-control input-sm input75" autocapitalize="off" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="update_frequency">${_('hours for software updates (default:168 (7d))')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Notify on software update')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="notify_on_update" id="notify_on_update" ${checked(settings.NOTIFY_ON_UPDATE)}/>
                                <label for="notify_on_update">${_('send a message to all enabled notifiers when SickChill has been updated')}</label>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-12">
                                <input type="submit" class="btn config_submitter" value="${_('Save Changes')}" />
                            </div>
                        </div>
                    </fieldset>
                </div>
            </div>
        </div>

        <!-- /interface //-->
        <div id="interface">
            <!-- User Interface -->
            <div class="row">
                <div class="col-lg-3 col-md-4 col-sm-4 col-xs-12">
                    <div class="component-group-desc">
                        <h3>${_('User Interface')}</h3>
                        <p>${_('Options for visual appearance.')}</p>
                    </div>
                </div>
                <div class="col-lg-9 col-md-8 col-sm-8 col-xs-12">

                    <fieldset class="component-group-list">

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Interface Language')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <select id="gui_language" name="gui_language" class="form-control input-sm input250">
                                            <option value="" ${selected(settings.GUI_LANG == "")}>${_('System Language')}</option>
                                            % for lang in [language for language in os.listdir(sickchill.init_helpers.locale_dir) if '_' in language]:
                                                <option value="${lang}" ${selected(settings.GUI_LANG == lang)}>${lang_name(lang)}</option>
                                            % endfor
                                        </select>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="gui_language">${_('for appearance to take effect, save then refresh your browser')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Display theme')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <select id="theme_name" name="theme_name" class="form-control input-sm input250">
                                            <option value="dark" ${selected(settings.THEME_NAME == 'dark')}>${_('Dark')}</option>
                                            <option value="light" ${selected(settings.THEME_NAME == 'light')}>${_('Light')}</option>
                                        </select>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="theme_name">${_('for appearance to take effect, save then refresh your browser')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Use a background image')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" class="enabler" name="sickchill_background" id="sickchill_background"
                                    ${checked(settings.SICKCHILL_BACKGROUND)} />
                                <label for="sickchill_background">${_('use a custom image as background for SickChill')}</label>
                            </div>
                        </div>
                        <div id="content_sickchill_background" ${hidden(settings.SICKCHILL_BACKGROUND)}>
                            <div class="field-pair row">
                                <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                    <label class="component-title">${_('Background Path')}</label>
                                </div>
                                <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <input type="text" name="sickchill_background_path" id="sickchill_background_path"
                                                   value="${settings.SICKCHILL_BACKGROUND_PATH}" class="form-control input-sm input350" autocapitalize="off" />
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12">
                                            <label for="sickchill_background_path" class="component-desc">${_('Path to the background image')}</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Show fanart in the background')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" class="enabler" name="fanart_background" id="fanart_background" ${checked(settings.FANART_BACKGROUND)}>
                                <label for="fanart_background">${_('on the show summary page')}</label>
                            </div>
                        </div>
                        <div id="content_fanart_background" ${hidden(settings.FANART_BACKGROUND)}>
                            <div class="field-pair row">
                                <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                    <label class="component-title">${_('Fanart transparency')}</label>
                                </div>
                                <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <input type="number" step="0.1" min="0.1" max="1.0" name="fanart_background_opacity" id="fanart_background_opacity" value="${settings.FANART_BACKGROUND_OPACITY}" class="form-control input-sm input75" />
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12">
                                            <label for="fanart_background_opacity" class="component-desc">${_('transparency of the fanart in the background')}</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Use a custom stylesheet file')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" class="enabler" name="custom_css" id="custom_css"
                                    ${checked(settings.CUSTOM_CSS)} />
                                <label for="custom_css">${_('use a custom .css file to style SickChill (for advanced users)')}</label>
                            </div>
                        </div>
                        <div id="content_custom_css" ${hidden(settings.CUSTOM_CSS)}>
                            <div class="field-pair row">
                                <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                    <label class="component-title">${_('Stylesheet File Path')}</label>
                                </div>
                                <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <input type="text" name="custom_css_path" id="custom_css_path"
                                                   value="${settings.CUSTOM_CSS_PATH}" class="form-control input-sm input350" autocapitalize="off" />
                                        </div>
                                    </div>
                                    <div class="row">
                                        <div class="col-md-12">
                                            <label for="custom_css_path" class="component-desc">${_('Path to the stylesheet (.css) file')}</label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Show all seasons')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="display_all_seasons" id="display_all_seasons" ${checked(settings.DISPLAY_ALL_SEASONS)}>
                                <label for="display_all_seasons">${_('on the show summary page')}</label>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Sort with "The", "A", "An"')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="sort_article" id="sort_article" ${checked(settings.SORT_ARTICLE)}/>
                                <label for="sort_article">${_('include articles ("The", "A", "An") when sorting show lists')}</label>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Definite/Indefinite articles to remove for sorting')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="text" name="grammar_articles" id="grammar_articles" value="${settings.GRAMMAR_ARTICLES}" class="form-control input-sm input100" autocapitalize="off" />
                                <label for="grammar_articles">${_('List of words to treat as articles, separated by the pipe character. Default: "the|a|an"')}</label>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Missed episodes range')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="number" step="1" min="0" max="42810" name="coming_eps_missed_range" id="coming_eps_missed_range"
                                               value="${settings.COMING_EPS_MISSED_RANGE}" class="form-control input-sm input75" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="coming_eps_missed_range">${_('set the range in days of the missed episodes in the Schedule page')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Display fuzzy dates')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="fuzzy_dating" id="fuzzy_dating" class="viewIf datePresets" ${checked(settings.FUZZY_DATING)}/>
                                <label for="fuzzy_dating">${_('move absolute dates into tooltips and display e.g. "Last Thu", "On Tue"')}</label>
                            </div>
                        </div>

                        <div class="field-pair row show_if_fuzzy_dating ${(' metadataDiv', '')[not bool(settings.FUZZY_DATING)]}">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Trim zero padding')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="trim_zero" id="trim_zero" ${checked(settings.TRIM_ZERO)} />
                                <label for="trim_zero">${_('remove the leading number "0" shown on hour of day, and date of month')}</label>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Date style')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <select class="form-control input-sm input250 ${(' metadataDiv', '')[bool(settings.FUZZY_DATING)]}" id="date_presets${('_na', '')[bool(settings.FUZZY_DATING)]}" name="date_preset${('_na', '')[bool(settings.FUZZY_DATING)]}">
                                    % for cur_preset in date_presets:
                                        <option value="${cur_preset}" ${selected(settings.DATE_PRESET == cur_preset or ("%x" == settings.DATE_PRESET and cur_preset == '%a, %b %d, %Y'))}>${datetime.datetime(datetime.datetime.now().year, 12, 31, 14, 30, 47).strftime(cur_preset)}</option>
                                    % endfor
                                </select>
                                <select class="form-control input-sm input250 ${(' metadataDiv', '')[not bool(settings.FUZZY_DATING)]}" id="date_presets${(' metadataDiv', '')[not bool(settings.FUZZY_DATING)]}" name="date_preset${('_na', '')[not bool(settings.FUZZY_DATING)]}">
                                    <option value="%x" ${selected(settings.DATE_PRESET == '%x')}>${_('Use System Default')}</option>
                                    % for cur_preset in date_presets:
                                        <option value="${cur_preset}" ${selected(settings.DATE_PRESET == cur_preset)}>${datetime.datetime(datetime.datetime.now().year, 12, 31, 14, 30, 47).strftime(cur_preset)}</option>
                                    % endfor
                                </select>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Time style')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <select id="time_presets" name="time_preset" class="form-control input-sm input250">
                                            % for cur_preset in time_presets:
                                                <option value="${cur_preset}" ${selected(settings.TIME_PRESET_W_SECONDS == cur_preset)}>${scdatetime.now().scftime(show_seconds=True,t_preset=cur_preset)}</option>
                                            % endfor
                                        </select>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="time_presets"><b>${_('note')}:</b>&nbsp;${_('seconds are only shown on the History page')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Timezone')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input style="margin-top: 2px !important;" type="radio" name="timezone_display" id="local" value="local" ${checked(settings.TIMEZONE_DISPLAY == "local")} >
                                        <label for="local" class="space-right">${_('Local')}</label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <input style="margin-top: 2px !important;" type="radio" name="timezone_display" id="network" value="network" ${checked(settings.TIMEZONE_DISPLAY == "network")} />
                                        <label for="network">${_('Network')}</label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label>${_('display dates and times in either your timezone or the shows network timezone')}</label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label><b>${_('note')}:</b>&nbsp;${_('use local timezone to start searching for episodes minutes after show ends (depends on your dailysearch frequency)')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Download url')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input class="form-control input350" type="text" name="download_url" id="download_url" value="${settings.DOWNLOAD_URL}" size="35" autocapitalize="off" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="download_url" class="component-desc">${_('URL where the shows can be downloaded.')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-12">
                                <input type="submit" class="btn config_submitter" value="${_('Save Changes')}" />
                            </div>
                        </div>

                    </fieldset>
                </div>
            </div>

            <!-- Divider -->
            <div class="config-group-divider"></div>

            <!-- Web Interface -->
            <div class="row">
                <div class="col-lg-3 col-md-4 col-sm-4 col-xs-12">
                    <div class="component-group-desc">
                        <h3>${_('Web Interface')}</h3>
                        <p>${_('It is recommended that you enable a username and password to secure SickChill from being tampered with remotely.')}</p>
                        <p><b>${_('These options require a manual restart to take effect.')}</b></p>
                    </div>
                </div>
                <div class="col-lg-9 col-md-8 col-sm-8 col-xs-12">
                    <fieldset class="component-group-list">

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('API key')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="text" name="api_key" id="api_key" value="${settings.API_KEY}" class="form-control input-sm input300" readonly="readonly" autocapitalize="off" />
                                        <input class="btn btn-inline" type="button" id="generate_new_apikey" value="Generate">
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="api_key">${_('used to give 3rd party programs limited access to SickChill')}</label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label>${_('you can try all the features of the API')} <a href="${static_url('apibuilder/', include_version=False)}">${_('here')}</a></label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('HTTP logs')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="web_log" id="web_log" ${checked(settings.WEB_LOG)}/>
                                <label>${_('enable logs from the internal Tornado web server')}</label>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('HTTP username')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="text" name="web_username" id="web_username" value="${settings.WEB_USERNAME}" class="form-control input-sm input300" autocapitalize="off" autocomplete="no" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label>${_('set blank for no login')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('HTTP password')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input
                                            type="password" name="web_password" id="web_password" value="${settings.WEB_PASSWORD|hide}"
                                            class="form-control input-sm input300" autocomplete="no" autocapitalize="off" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="web_password">${_('blank = no authentication')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('HTTP port')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="number" min="1" step="1" name="web_port" id="web_port" value="${settings.WEB_PORT}" class="form-control input-sm input100" autocapitalize="off" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="web_port">${_('web port to browse and access SickChill (default:8081)')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Notify on login')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="notify_on_login" class="enabler" id="notify_on_login" ${checked(settings.NOTIFY_ON_LOGIN)}/>
                                <label for="notify_on_login">${_('enable to be notified when a new login happens in webserver')}</label>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Listen on IPv6')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="web_ipv6" id="web_ipv6" ${checked(settings.WEB_IPV6)}/>
                                <label for="web_ipv6">${_('attempt binding to any available IPv6 address')}</label>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Enable HTTPS')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="enable_https" class="enabler" id="enable_https" ${checked(settings.ENABLE_HTTPS)}/>
                                <label for="enable_https">${_('enable access to the web interface using a HTTPS address')}</label>
                            </div>
                        </div>

                        <div id="content_enable_https" ${hidden(settings.ENABLE_HTTPS)}>

                            <div class="field-pair row">
                                <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                    <label class="component-title">${_('HTTPS certificate')}</label>
                                </div>
                                <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                    <input type="text" name="https_cert" id="https_cert" value="${settings.HTTPS_CERT}" class="form-control input-sm input300" autocapitalize="off" />
                                    <label for="https_cert">${_('file name or path to HTTPS certificate')}</label>
                                </div>
                            </div>

                            <div class="field-pair row">
                                <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                    <label class="component-title">${_('HTTPS key')}</label>
                                </div>
                                <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                    <input type="text" name="https_key" id="https_key" value="${settings.HTTPS_KEY}" class="form-control input-sm input300" autocapitalize="off" />
                                    <label for="https_key">${_('file name or path to HTTPS key')}</label>
                                </div>
                            </div>

                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Reverse proxy headers')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="checkbox" name="handle_reverse_proxy" id="handle_reverse_proxy" ${checked(settings.HANDLE_REVERSE_PROXY)}/>
                                        <label for="handle_reverse_proxy">${_('accept the following reverse proxy headers (advanced)...')}</label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label>${_('(X-Forwarded-For, X-Forwarded-Host, and X-Forwarded-Proto)')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-12">
                                <input type="submit" class="btn config_submitter" value="${_('Save Changes')}" />
                            </div>
                        </div>

                    </fieldset>
                </div>
            </div>
        </div>

        <!-- /logging settings //-->
        <div id="logging-settings">

            <!-- Logging settings -->
            <div class="row">
                <div class="col-lg-3 col-md-4 col-sm-4 col-xs-12">
                    <div class="component-group-desc">
                        <h3>${_('Logging Settings')}</h3>
                        <p>${_('Options for Logging.')}</p>
                        <p>${_('RESTART REQUIRED after saving changes.')}</p>
                    </div>
                </div>
                <div class="col-lg-9 col-md-8 col-sm-8 col-xs-12">
                    <fieldset class="component-group-list">

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-3 col-sm-4 col-xs-12">
                                <label class="component-title">${_('Log Dir')}</label>
                            </div>
                            <div class="col-lg-9 col-md-9 col-sm-8 col-xs-12 pull-right component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="text" name="log_dir" id="log_dir" value="${settings.LOG_DIR}"
                                               class="form-control input-sm input350" autocapitalize="off"/>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <span>${_('The folder where sickchill log/s go.')}</span>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <span><b>${_('note')}
                                            :</b>&nbsp;${_('please make sure that sickchill user has the right permissions for the folder.')}</span>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Notify on Logged Errors')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="notify_on_logged_error"
                                       id="notify_on_logged_error" ${checked(settings.NOTIFY_ON_LOGGED_ERROR)}/>
                                <label for="notify_on_logged_error">${_('send logged errors to notifiers')}</label>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Enable debug')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="debug" id="debug" ${checked(settings.DEBUG)}/>
                                <label for="debug">${_('enable debug logging')}</label>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Enable database debug')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="dbdebug" id="dbdebug" ${checked(settings.DBDEBUG)}/>
                                <label for="dbdebug">${_('enable database debug logging')}</label>
                            </div>
                        </div>
                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Number of Log files saved')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="number" min="1" step="1" name="log_nr" id="log_nr"
                                               value="${settings.LOG_NR}" class="form-control input-sm input75"
                                               autocapitalize="off"/>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label
                                            for="log_nr">${_('number of log files saved when rotating logs (default: 5)')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Size of Log files saved')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="number" min="0.5" step="0.1" name="log_size" id="log_size"
                                               value="${settings.LOG_SIZE}" class="form-control input-sm input75"
                                               autocapitalize="off"/>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label
                                            for="log_size">${_('maximum size in MB of the log file (default: 1MB, max: 100MB)')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                    </fieldset>
                </div>
            </div>
        </div>

        <!-- /advanced settings //-->
        <div id="advanced-settings">

            <!-- Advanced Settings -->
            <div class="row">
                <div class="col-lg-3 col-md-4 col-sm-4 col-xs-12">
                    <div class="component-group-desc">
                        <h3>${_('Advanced Settings')}</h3>
                        <p>${_('The special options.')}</p>
                    </div>
                </div>
                <div class="col-lg-9 col-md-8 col-sm-8 col-xs-12">
                    <fieldset class="component-group-list">

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('CPU throttling')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <select id="cpu_presets" name="cpu_preset" class="form-control input-sm input250">
                                            % for cur_preset in cpu_presets:
                                                <option value="${cur_preset}" ${selected(settings.CPU_PRESET == cur_preset)}>${cur_preset.capitalize()}</option>
                                            % endfor
                                        </select>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="cpu_presets">${_('Normal (default). High is lower and Low is higher CPU use')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Anonymous redirect')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="text" name="anon_redirect" value="${settings.ANON_REDIRECT}" class="form-control input-sm input300" autocapitalize="off" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="anon_redirect">${_('backlink protection via anonymizer service, must end in "?" (default: {} )').format(settings.DEFAULT_ANON_REDIRECT)}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Verify SSL Certs')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="ssl_verify" id="ssl_verify" ${checked(settings.SSL_VERIFY)}/>
                                <label for="ssl_verify">${_('verify SSL Certificates (Disable this for broken SSL installs (Like QNAP))')}</label>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('No Restart')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="checkbox" name="no_restart" id="no_restart" ${checked(settings.NO_RESTART)}/>
                                        <label for="no_restart">${_('only shutdown when restarting SC')}</label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label>${_('only select this when you have external software restarting SC automatically when it stops (like FireDaemon)')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Encrypt passwords')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="checkbox" name="encryption_version" id="encryption_version" ${checked(settings.ENCRYPTION_VERSION)}/>
                                        <label for="encryption_version">${_('in the <code>config.ini</code> file')}</label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <b>${_('warning')}:</b>&nbsp;${_('passwords must only contain')}
                                        <a target="_blank" href="${anon_url('http://en.wikipedia.org/wiki/ASCII#ASCII_printable_characters')}">${_('ASCII characters')}</a>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Unprotected calendar')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="checkbox" name="calendar_unprotected" id="calendar_unprotected" ${checked(settings.CALENDAR_UNPROTECTED)}/>
                                        <label for="calendar_unprotected">${_('allow subscribing to the calendar without user and password')}</label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label>${_('some services like Google Calendar only work this way')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Google Calendar Icons')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <input type="checkbox" name="calendar_icons" id="calendar_icons" ${checked(settings.CALENDAR_ICONS)}/>
                                <label for="calendar_icons">${_('show an icon next to exported calendar events in Google Calendar')}</label>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Proxy host')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="text" name="proxy_setting" value="${settings.PROXY_SETTING}" class="form-control input-sm input300" autocapitalize="off" />
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="proxy_setting">${_('blank to disable or proxy to use when connecting to providers')}</label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="checkbox" name="proxy_indexers" id="proxy_indexers" ${checked(settings.PROXY_INDEXERS)}/>
                                        <label for="proxy_indexers">${_('also use global proxy setting for indexers (tvdb, xem, anidb, etc.)')}</label>
                                    </div>

                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Skip Remove Detection')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="checkbox" name="skip_removed_files" id="skip_removed_files" ${checked(settings.SKIP_REMOVED_FILES)}/>
                                        <label for="skip_removed_files">${_('skip detection of removed files')}</label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label>${_('if disabled the episode will be set to the default deleted status')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Ignore Broken Symbolic Links')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        <input type="checkbox" name="ignore_broken_symlinks" id="ignore_broken_symlinks" ${checked(settings.IGNORE_BROKEN_SYMLINKS)}/>
                                        <label for="ignore_broken_symlinks">${_('If checked, broken symbolic links warnings generated when calculating show size will be logged as debug')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="field-pair row">
                            <div class="col-lg-3 col-md-4 col-sm-5 col-xs-12">
                                <label class="component-title">${_('Default deleted episode status')}</label>
                            </div>
                            <div class="col-lg-9 col-md-8 col-sm-7 col-xs-12 component-desc">
                                <div class="row">
                                    <div class="col-md-12">
                                        % if not settings.SKIP_REMOVED_FILES:
                                            <select name="ep_default_deleted_status" id="ep_default_deleted_status" class="form-control input-sm input250" title="Default delete status">
                                                % for defStatus in [SKIPPED, IGNORED, ARCHIVED]:
                                                    <option value="${defStatus}" ${selected(int(settings.EP_DEFAULT_DELETED_STATUS) == defStatus)}>${statusStrings[defStatus]}</option>
                                                % endfor
                                            </select>
                                        % else:
                                            <select name="ep_default_deleted_status" id="ep_default_deleted_status" class="form-control input-sm input250" title="Default delete status" disabled>
                                                % for defStatus in [SKIPPED, IGNORED]:
                                                    <option value="${defStatus}" ${selected(settings.EP_DEFAULT_DELETED_STATUS == defStatus)}>${statusStrings[defStatus]}</option>
                                                % endfor
                                            </select>
                                            <input type="hidden" name="ep_default_deleted_status" value="${settings.EP_DEFAULT_DELETED_STATUS}" />
                                        % endif
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label for="ep_default_deleted_status">${_('define the status to be set for media file that has been deleted.')}</label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label><b>${_('note')}:</b>&nbsp;${_('Archived option will keep previous downloaded quality')}</label>
                                    </div>
                                </div>
                                <div class="row">
                                    <div class="col-md-12">
                                        <label>${_('example: Downloaded (1080p WEB-DL) ==> Archived (1080p WEB-DL)')}</label>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-12">
                                <input type="submit" class="btn config_submitter" value="${_('Save Changes')}" />
                            </div>
                        </div>
                    </fieldset>
                </div>
            </div>

        </div>
    </form>
</%block>
