// https://github.com/akhodakivskiy/VimFx/blob/master/extension/lib/defaults.coffee
// https://github.com/lydell/dotfiles/blob/master/.vimfx
// https://github.com/azuwis/.vimfx/blob/master/config.js

const {classes: Cc, interfaces: Ci, utils: Cu} = Components
const nsIStyleSheetService = Cc['@mozilla.org/content/style-sheet-service;1']
    .getService(Ci.nsIStyleSheetService)
const {OS} = Cu.import('resource://gre/modules/osfile.jsm')

Cu.import('resource://gre/modules/XPCOMUtils.jsm')
XPCOMUtils.defineLazyModuleGetter(this, 'AddonManager', 'resource://gre/modules/AddonManager.jsm')
XPCOMUtils.defineLazyModuleGetter(this, 'NetUtil', 'resource://gre/modules/NetUtil.jsm')
XPCOMUtils.defineLazyModuleGetter(this, 'PlacesUtils', 'resource://gre/modules/PlacesUtils.jsm')
XPCOMUtils.defineLazyModuleGetter(this, 'PopupNotifications', 'resource://gre/modules/PopupNotifications.jsm')
XPCOMUtils.defineLazyModuleGetter(this, 'Preferences', 'resource://gre/modules/Preferences.jsm')


// Maps

let map = (shortcuts, command, custom=false) => {
    vimfx.set(`${custom ? 'custom.' : ''}mode.normal.${command}`, shortcuts)
}

map('<c-d>', 'scroll_half_page_down')
map('<c-u>', 'scroll_half_page_up')

map('j <c-e>', 'scroll_down')
map('k <c-y>', 'scroll_up')

map('K gT',     'tab_select_previous')
map('J gt',     'tab_select_next')
map('gl <c-6>', 'tab_select_most_recent')
map('gK',       'tab_move_backward')
map('gJ',       'tab_move_forward')
map('g^ x',     'tab_select_first_non_pinned')
map('d',        'tab_close')
map('u',        'tab_restore')

map('a/', 'find')
map('/',  'find_highlight_all')

map('<force><escape> <force><c-[>', 'esc')
vimfx.set('mode.caret.exit', '<escape> <c-[>')
vimfx.set('mode.hints.exit', '<escape> <c-[>')


// Custom commands

let {commands} = vimfx.modes.normal

vimfx.addCommand({
    name: 'search_selected_text',
    description: 'Search for the selected text'
}, ({vim}) => {
    vimfx.send(vim, 'getSelection', null, selection => {
        let inTab = true // Change to `false` if you’d like to search in current tab.
        vim.window.BrowserSearch.loadSearch(selection, inTab)
    })
})
map('*', 'search_selected_text', true)

vimfx.addCommand({
    name: 'search_tabs',
    description: 'Search tabs',
    category: 'location',
    order: commands.focus_location_bar.order + 1,
}, (args) => {
    commands.focus_location_bar.run(args)
    args.vim.window.gURLBar.value = '% '
})
map('b', 'search_tabs', true)

vimfx.addCommand({
    name: 'toggle_tabbar',
    description: 'Toggle tab bar',
    category: 'tabs',
}, ({vim}) => {
    let {window} = vim
    window.gBrowser.setStripVisibilityTo(!window.gBrowser.getStripVisibility());
})
map('M', 'toggle_tabbar', true)

vimfx.addCommand({
    name: 'goodreads_search',
    description: 'Search for Amazon book on Goodreads',
}, ({vim}) => {
    let {window} = vim
    let document = window.gBrowser.contentDocument
    let asin_elements = document.getElementsByName('ASIN');
    if (asin_elements.length == 0) {
        asin_elements = document.getElementsByName('ASIN.0');
    };
    if (asin_elements.length == 0) {
        window.alert('Sorry, this doesn\'t appear to be an Amazon book page.');
    } else {
        let asin = asin_elements[0].value;
        if (asin.match(/\D/) === null) {
            window.gBrowser.addTab('http://www.goodreads.com/review/isbn/' + asin);
        } else {
            window.gBrowser.addTab('https://www.goodreads.com/search?q=' + asin);
        }
    }
})
map('gR', 'goodreads_search', true)


// VimFx settings

let set = (pref, valueOrFunction) => {
    let value = typeof valueOrFunction === 'function'
        ? valueOrFunction(vimfx.getDefault(pref))
        : valueOrFunction
    vimfx.set(pref, value)
}

// set('hint_chars', 'ehstirnoamupcwlfg dy')
// set('prevent_autofocus', true) // Causes issues with sites like Gmail


// Firefox settings

let {Preferences} = Cu.import('resource://gre/modules/Preferences.jsm', {})

Preferences.set({
    'browser.link.open_newwindow.restriction': 0,
    'browser.startup.page': 3,
    'browser.tabs.loadDivertedInBackground': true,
    'browser.urlbar.trimURLs': false,
    'devtools.chrome.enabled': true,
    'devtools.command-button-eyedropper.enabled': true,
    'devtools.command-button-rulers.enabled': true,
    'devtools.theme': 'dark',
    'devtools.selfxss.count': 0,
    'general.warnOnAboutConfig': false,
    'media.autoplay.enabled': false,
    'network.cookie.cookieBehavior': 1,
    // 'network.dns.disablePrefetch': true,
    // 'network.http.speculative-parallel-limit': 0,
    // 'network.prefetch-next': false,
    'noscript.clearClick.rapidFireCheck': false,
    'privacy.donottrackheader.enabled': true,
    'privacy.donottrackheader.value': 1,
    'privacy.trackingprotection.enabled': true,
})


// Custom CSS files

let loadCss = (uriString) => {
    let uri = Services.io.newURI(uriString, null, null)
    let method = nsIStyleSheetService.AUTHOR_SHEET
    if (!nsIStyleSheetService.sheetRegistered(uri, method)) {
        nsIStyleSheetService.loadAndRegisterSheet(uri, method)
    }
    vimfx.on('shutdown', () => {
        nsIStyleSheetService.unregisterSheet(uri, method)
    })
}

loadCss(`${__dirname}/chrome.css`)
loadCss(`${__dirname}/content.css`)
loadCss(`${__dirname}/tabs.css`)


// Key overrides

vimfx.addKeyOverrides(
    [ location => location.hostname === 'mail.google.com',
        [
            '!', '#', '*', '.', '/', ':', ';', '?',
            'A', 'F', 'I', 'N', 'R', 'U', '_',
            '[', ']', '{', '}',
            'a', 'c', 'd', 'e', 'f', 'g', 'i', 'j', 'k', 'l', 'm',
            'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'x', 'y', 'z'
        ]
    ]
)


let bootstrap = () => {
    // add custom search engine keywords
    let search_engines = [
        {keyword: 'g', title:'Google Search', url: 'https://www.google.com/search?q=%s&ie=utf-8&oe=utf-8&safe=off'},
        {keyword: 'gi', title:'Google Image Search', url: 'https://www.google.com/search?site=&tbm=isch&source=hp&biw=1090&bih=690&q=%s&btnG=Search+by+image&oq=&gs_l='},
        {keyword: 'ddg', title:'Duckduckgo Search', url: 'https://ac.duckduckgo.com/ac/?q=%s&type=list'},
        {keyword: 'w', title: 'Wikipedia Search', url: 'https://en.wikipedia.org/wiki/Special:Search?search=%s'},
        {keyword: 'a', title: 'Amazon.com', url: 'https://www.amazon.com/exec/obidos/external-search/?field-keywords=%s&mode=blended'},
        {keyword: 't', title: 'Twitter Search', url: 'https://twitter.com/search/%s'},
        {keyword: 'yt', title:'YouTube Video Search', url: 'https://www.youtube.com/results?search_query=%s'},
        {keyword: 'packages', title: 'Debian Package Search', url: 'https://packages.debian.org/search?keywords=%s'},
        {keyword: 'bts', title: 'Debian Bug Search', url: 'https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=%s'},
        {keyword: 'moby', title: 'MobyGames', url: 'https://www.mobygames.com/search/quick?q=%s'},
        {keyword: 'j', title: 'OpenCloud Jira', url: 'https://jira.opencloud.com/jira/secure/QuickSearch.jspa?searchString=%s'},
    ]
    let bookmarks = PlacesUtils.bookmarks
    search_engines.forEach((element) => {
        let uri = NetUtil.newURI(element.url, null, null)
        if (!bookmarks.isBookmarked(uri)) {
            bookmarks.insertBookmark(
                bookmarks.unfiledBookmarksFolder,
                uri,
bookmarks.DEFAULT_INDEX,
                element.title)
            PlacesUtils.keywords.insert(element)
        }
    })
}

let bootstrapIfNeeded = () => {
    let bootstrapFile = OS.Path.fromFileURI(`${__dirname}/config.js`)
    let bootstrapPref = "extensions.VimFx.bootstrapTime"
    let file = Cc['@mozilla.org/file/local;1'].createInstance(Ci.nsIFile)
    file.initWithPath(bootstrapFile)
    if (file.exists() && file.isFile() && file.isReadable()) {
        let mtime = Math.floor(file.lastModifiedTime / 1000)
        let btime = Preferences.get(bootstrapPref)
        if (!btime || mtime > btime) {
            bootstrap()
            Preferences.set(bootstrapPref, Math.floor(Date.now() / 1000))
        }
    }
}
bootstrapIfNeeded()
