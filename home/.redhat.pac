function regExpMatch(url, pattern) {
	try { return new RegExp(pattern).test(url); } catch(ex) { return false; }
}

function FindProxyForURL(url, host) {
	if (shExpMatch(url, '*://*.openshift.redhat.com/*') || shExpMatch(url, '*://openshift.redhat.com/*')) return 'PROXY squid.corp.redhat.com:8080';
	if (shExpMatch(url, '*://*.compute-1.amazonaws.com*') || shExpMatch(url, '*://compute-1.amazonaws.com*')) return 'PROXY squid.corp.redhat.com:8080';
	if (shExpMatch(url, '*://openshiftdev.redhat.com*') || shExpMatch(url, '*://*.dev.rhcloud.com*')) return 'PROXY squid.corp.redhat.com:8080';
	return 'DIRECT';
}

