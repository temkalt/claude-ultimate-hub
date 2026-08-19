module.exports = (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return;
  }

  res.status(200).json({
    status: 'ready',
    mode: 'vercel-serverless',
    version: '3.0.0',
    cloud: 'Vercel Edge & Serverless Global CDN',
    serverTime: new Date().toISOString(),
    toolsCount: '1,000+',
    profilesCount: 14,
    skillsCount: 320,
    mcpCount: 350,
    subagentsCount: 80
  });
};
