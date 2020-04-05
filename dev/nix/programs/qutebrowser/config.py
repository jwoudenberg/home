## Autogenerated config.py
## Documentation:
##   qute://help/configuring.html
##   qute://help/settings.html

## Aliases for commands. The keys of the given dictionary are the
## aliases, while the values are the commands they map to.
## Type: Dict
c.aliases = {
    'w': 'session-save',
    'q': 'tab-close',
    'qa': 'quit',
    'wq': 'quit --save',
    'wqa': 'quit --save',
}

## Always restore open sites when qutebrowser is reopened.
## Type: Bool
c.auto_save.session = False

## Backend to use to display websites. qutebrowser supports two different
## web rendering engines / backends, QtWebKit and QtWebEngine. QtWebKit
## was discontinued by the Qt project with Qt 5.6, but picked up as a
## well maintained fork: https://github.com/annulen/webkit/wiki -
## qutebrowser only supports the fork. QtWebEngine is Qt's official
## successor to QtWebKit. It's slightly more resource hungry than
## QtWebKit and has a couple of missing features in qutebrowser, but is
## generally the preferred choice.
## Type: String
## Valid values:
##   - webengine: Use QtWebEngine (based on Chromium).
##   - webkit: Use QtWebKit (based on WebKit, similar to Safari).
c.backend = 'webengine'

## Which cookies to accept.
## Type: String
## Valid values:
##   - all: Accept all cookies.
##   - no-3rdparty: Accept cookies from the same origin only. This is known to break some sites, such as GMail.
##   - no-unknown-3rdparty: Accept cookies from the same origin only, unless a cookie is already set for the domain. On QtWebEngine, this is the same as no-3rdparty.
##   - never: Don't accept cookies at all.
c.content.cookies.accept = 'no-3rdparty'

## Allow websites to request geolocations.
## Type: BoolAsk
## Valid values:
##   - true
##   - false
##   - ask
c.content.geolocation = False

## Search engines which can be used via the address bar. Maps a search
## engine name (such as `DEFAULT`, or `ddg`) to a URL with a `{}`
## placeholder. The placeholder will be replaced by the search term, use
## `{{` and `}}` for literal `{`/`}` signs. The search engine named
## `DEFAULT` is used when `url.auto_search` is turned on and something
## else than a URL was entered to be opened. Other search engines can be
## used by prepending the search engine name to the search term, e.g.
## `:open google qutebrowser`.
## Type: Dict
c.url.searchengines = {'DEFAULT': 'https://duckduckgo.com/?q={}'}

## Page(s) to open at the start.
## Type: List of FuzzyUrl, or FuzzyUrl
c.url.start_pages = ['about:blank']

## Bindings for normal mode
config.bind('<Ctrl-O>', 'back')
config.bind('<Ctrl-I>', 'forward')
config.bind('gt', 'tab-next')
config.bind('<Ctrl-P>', 'completion-item-focus prev', mode='command')
config.bind('<Ctrl-N>', 'completion-item-focus next', mode='command')
