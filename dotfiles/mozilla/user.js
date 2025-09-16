// Reference:
// https://searchfox.org/mozilla-central/source/modules/libpref/init/StaticPrefList.yaml

// Open all requests for new windows in new tabs instead
user_pref('browser.link.open_newwindow', 3);
user_pref('browser.link.open_newwindow.restriction', 0);

// Resume previous session on startup
user_pref('browser.startup.page', 3);

user_pref('browser.tabs.loadDivertedInBackground', true);
user_pref('browser.urlbar.trimURLs', false);
user_pref('browser.urlbar.update2.engineAliasRefresh', true);

user_pref('devtools.chrome.enabled', true);
user_pref('devtools.command-button-measure.enabled', true);
user_pref('devtools.command-button-rulers.enabled', true);
user_pref('devtools.command-button-screenshot.enabled', true);
user_pref('devtools.selfxss.count', 0);

user_pref('general.warnOnAboutConfig', false);

// This pref defines what the blocking policy would be used in blocking autoplay.
// 0 : use sticky activation (default)
// https://html.spec.whatwg.org/multipage/interaction.html#sticky-activation
// 1 : use transient activation (the transient activation duration can be
//     adjusted by the pref `dom.user_activation.transient.timeout`)
// https://html.spec.whatwg.org/multipage/interaction.html#transient-activation
// 2 : user input depth (allow autoplay when the play is trigged by user input
//     which is determined by the user input depth)
user_pref('media.autoplay.blocking_policy', 1);
// Block autoplay, asking for permission by default.
// 0=Allowed, 1=Blocked, 5=All Blocked
user_pref('media.autoplay.default', 5);

// Reject all third-party cookies
user_pref('network.cookie.cookieBehavior', 1);

user_pref('privacy.donottrackheader.enabled', true);
user_pref('privacy.donottrackheader.value', 1);
user_pref('privacy.globalprivacycontrol.enabled', true);
user_pref('privacy.trackingprotection.enabled', true);
user_pref('dom.private-attribution.submission.enabled', false);

// Disable AI stuff
user_pref('browser.ml.enabled', false);
user_pref('browser.ml.chat.enabled', false);
user_pref('browser.ml.chat.menu', false);
user_pref('browser.ml.chat.sidebar', false);
user_pref('browser.tabs.groups.smart.enabled', false);
