// Small CLI tool to create a GitHub App for Backstage
//
// Heavily inspired by https://github.com/backstage/backstage/blob/master/packages/cli/src/commands/create-github-app/

const http = require('http');
const crypto = require('crypto');
const fs = require('fs/promises')

const hostname = '127.0.0.1';
const port = 3000;

const FORM_PAGE = `
<html>
  <body>
    <form id="form" action="ACTION_URL" method="post">
      <input type="hidden" name="manifest" value="MANIFEST_JSON">
      <input type="submit" value="Continue">
    </form>
    <script>
      document.getElementById("form").submit()
    </script>
  </body>
</html>
`;


let baseUrl;


const webhookId = crypto
.randomBytes(15)
.toString('base64')
.replace(/[\+\/]/g, '');

const webhookUrl = `https://smee.io/${webhookId}`;

const handleIndex = (req, res, GITHUB_ORG_ID) => {
  const encodedOrg = encodeURIComponent(GITHUB_ORG_ID);
  const actionUrl = `https://github.com/organizations/${encodedOrg}/settings/apps/new`;


  res.statusCode = 200;
  const manifest = {
    default_events: ['create', 'delete', 'push', 'repository'],
    default_permissions: {
      members: 'read',
      administration: 'write',
      contents: 'write',
      metadata: 'read',
      pull_requests: 'write',
      issues: 'write',
      workflows: 'write',
      checks: 'read',
      actions_variables: 'write',
      secrets: 'write',
      environments: 'write',
    },
    name: `backstage-${GITHUB_ORG_ID}`,
    url: 'https://backstage.io',
    description: 'GitHub App for Backstage',
    public: false,
    redirect_url: `${baseUrl}/callback`,
    hook_attributes: {
      url: webhookUrl,
      active: false,
    },
  };

  const manifestJson = JSON.stringify(manifest).replace(/\"/g, '&quot;');

  let body = FORM_PAGE;
  body = body.replace('MANIFEST_JSON', manifestJson);
  body = body.replace('ACTION_URL', actionUrl);

  res.setHeader('content-type', 'text/html');
  res.end(body);
}


const writeConfigFile = async (data, webhookUrl) => {
  const fileName = `github-app-credentials.json`;
  const content = JSON.stringify({
    name: data.name,
    slug: data.slug,
    appId: data.id,
    webhookUrl: webhookUrl,
    clientId: data.client_id,
    clientSecret: data.client_secret,
    webhookSecret: data.webhook_secret,
    privateKey: data.pem,
  }, null, 2)

  await fs.writeFile(fileName, content);

  console.log(`Created ${fileName}, you can close the server now.`)
}

const handleCallback = async (req, res) => {
  const url = new URL(req.url, `http://${req.headers.host}`);
  const conversionRes = await fetch(`https://api.github.com/app-manifests/${encodeURIComponent(url.searchParams.get('code'))}/conversions`, {
    method: 'POST',
  });

  if (conversionRes.status !== 201) {
    const body = await conversionRes.text();
    res.statusCode = conversionRes.status;
    res.end(body);
  }

  const data = await conversionRes.json();

  await writeConfigFile(data, webhookUrl);

  res.writeHead(302, { Location: `${data.html_url}/installations/new` });
  res.end();
}

if (process.env.STUB_FILE === '1') {
  writeConfigFile({
    name: 'stub',
    slug: 'stub',
    id: 'stub',
    client_id: 'stub',
    client_secret: 'stub',
    webhook_secret: 'stub',
    pem: 'stub',
  }, 'https://smee.io/stub');

  return;
}

const GITHUB_ORG_ID = process.env.GITHUB_ORG_ID;
if (!GITHUB_ORG_ID) {
  console.error('Please export GITHUB_ORG_ID');
  process.exit(1);
}

const server = http.createServer((req, res) => {
  if (req.url === '/') {
    handleIndex(req, res, GITHUB_ORG_ID);
  } else if (req.url.startsWith('/callback?')) {
    handleCallback(req, res);
  } else {
    res.statusCode = 404;
    res.end('Not found, url: ' + req.url);
  }
});

server.listen(port, hostname, () => {
  baseUrl = `http://${hostname}:${port}`;

  console.log(`Open ${baseUrl}`);
});
