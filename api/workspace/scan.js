module.exports = (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return;
  }

  let targetPath = '.';
  if (req.body && req.body.targetPath) targetPath = req.body.targetPath;

  res.status(200).json({
    path: targetPath,
    isNode: true,
    isNextJs: true,
    isReact: true,
    isDocker: true,
    isSupabase: true,
    frameworks: ['Next.js 15', 'React 19', 'Tailwind CSS', 'Supabase', 'Playwright E2E'],
    recommendedProfile: 'Web',
    recommendedMcps: ['playwright', 'supabase', 'postgres', 'stripe'],
    recommendedSkills: ['ui-ux-pro-max', 'bulletproof', 'caveman', 'agent-security'],
    cloud: 'Vercel Edge Stack Scanner'
  });
};
