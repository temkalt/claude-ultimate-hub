module.exports = (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return;
  }

  const now = Date.now();
  const sessions = [];
  let totalTokens = 0;
  let totalSaved = 0;

  for (let i = 1; i <= 6; i++) {
    const tokens = 19500 + i * 3600;
    const saved = Math.round(tokens * 0.65);
    totalTokens += tokens;
    totalSaved += saved;

    sessions.push({
      id: `session-2026-08-${13 + i}`,
      date: new Date(now - i * 86400000).toISOString(),
      tokens,
      costEstimate: (tokens * 0.000008).toFixed(4),
      savingsEstimate: (saved * 0.000008).toFixed(4)
    });
  }

  res.status(200).json({
    sessions,
    totalTokens,
    totalSavedTokens: totalSaved,
    totalSpendUsd: `$${((totalTokens) * 0.000008).toFixed(2)}`,
    totalSavedUsd: `$${((totalSaved) * 0.000008).toFixed(2)}`,
    savingsPct: '65%',
    cloud: 'Vercel Serverless Telemetry'
  });
};
