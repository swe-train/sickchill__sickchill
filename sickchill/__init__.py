from sickchill.init_helpers import maybe_daemonize

maybe_daemonize()

from sickchill.show.indexers import indexer, ShowIndexer
