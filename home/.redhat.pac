function regExpMatch(url, pattern) {
  try { return new RegExp(pattern).test(url); } catch(ex) { return false; }
}

function FindProxyForURL(url, host) {
  var proxy = 'PROXY file.rdu.redhat.com:3128';
  var proxy_patterns = [
    '*://*.openshift.com/*',
    '*://*.openshift.redhat.com/*',
    '*://openshift.redhat.com/*',
    '*://*.compute-1.amazonaws.com*',
    '*://compute-1.amazonaws.com*',
    '*://openshiftdev.redhat.com*',
    '*://*.dev.rhcloud.com*',
    '*://*.usersys.redhat.com*'
  ];

  destination = 'DIRECT';

  for (var i = 0; i < proxy_patterns.length; i++) {
    if (shExpMatch(url, proxy_patterns[i])) {
      destination = proxy;
      break;
    }
  }

  return destination;
}

