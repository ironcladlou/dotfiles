function regExpMatch(url, pattern) {
	try { return new RegExp(pattern).test(url); } catch(ex) { return false; }
}

function FindProxyForURL(url, host) {
  alert('dan');
  var proxy='PROXY file.rdu.redhat.com:3128x';
  //var proxy='PROXY squid.corp.redhat.com:8080'
	if (shExpMatch(url, '*://*.openshift.redhat.com/*') || shExpMatch(url, '*://openshift.redhat.com/*')) return proxy;
	if (shExpMatch(url, '*://*.compute-1.amazonaws.com*') || shExpMatch(url, '*://compute-1.amazonaws.com*')) return proxy;
	if (shExpMatch(url, '*://openshiftdev.redhat.com*') || shExpMatch(url, '*://*.dev.rhcloud.com*')) return proxy;
	return 'DIRECT';
}

