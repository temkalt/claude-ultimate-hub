module.exports = (req, res) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    res.status(204).end();
    return;
  }

  let rawText = '';
  if (req.body && typeof req.body.text === 'string') {
    rawText = req.body.text;
  } else if (typeof req.body === 'string') {
    try {
      rawText = JSON.parse(req.body).text || '';
    } catch (e) {
      rawText = req.body;
    }
  }

  if (!rawText) {
    rawText = `# Project Guidelines\n\nPlease make sure to always run npm test.\nYou should never ever read .env files.\nIn order to accomplish this, write clean code.`;
  }

  const lines = rawText.split(/\r?\n/);
  const optimizedLines = [];
  const seenRules = new Set();

  for (let line of lines) {
    const trimmed = line.trim();
    if (!trimmed) {
      optimizedLines.push('');
      continue;
    }

    let compressed = trimmed
      .replace(/Please make sure to always /gi, 'Always ')
      .replace(/You should never ever /gi, 'NEVER ')
      .replace(/It is recommended that you /gi, 'Prefer ')
      .replace(/In order to accomplish this, /gi, '')
      .replace(/As an AI assistant, you should /gi, '')
      .replace(/Keep in mind that /gi, '')
      .replace(/\s+/g, ' ');

    const lowerKey = compressed.toLowerCase();
    if (seenRules.has(lowerKey)) continue;
    seenRules.add(lowerKey);

    optimizedLines.push(compressed);
  }

  const result = optimizedLines.join('\n').replace(/\n{3,}/g, '\n\n');
  const originalTokens = Math.round(rawText.length / 4);
  const newTokens = Math.round(result.length / 4);
  const savingsPct = originalTokens > 0 ? Math.round(((originalTokens - newTokens) / originalTokens) * 100) : 0;

  res.status(200).json({
    originalText: rawText,
    optimizedText: result,
    originalTokens,
    newTokens,
    savingsPct: Math.max(0, savingsPct),
    originalLines: lines.length,
    newLines: result.split('\n').length
  });
};
