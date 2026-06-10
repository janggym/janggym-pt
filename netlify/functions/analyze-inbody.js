exports.handler = async (event) => {
  if (event.httpMethod !== 'POST') return { statusCode: 405, body: 'Method Not Allowed' };

  let body;
  try { body = JSON.parse(event.body); }
  catch { return { statusCode: 400, body: JSON.stringify({ error: 'Invalid JSON' }) }; }

  const { image, mediaType } = body;
  if (!image || !mediaType)
    return { statusCode: 400, body: JSON.stringify({ error: 'image and mediaType required' }) };

  const apiKey = process.env.GEMINI_API_KEY;
  if (!apiKey)
    return { statusCode: 500, body: JSON.stringify({ error: 'GEMINI_API_KEY not configured' }) };

  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=${apiKey}`;

  let geminiRes;
  try {
    geminiRes = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [
          { text: '이 인바디 결과지 이미지에서 다음 수치를 읽어서 JSON으로만 응답해줘. 다른 설명 없이 JSON만:\n{"weight":숫자,"fat_pct":숫자,"muscle_kg":숫자}\n체중(kg), 체지방률(%), 골격근량(kg). 값을 찾을 수 없으면 null로 해줘.' },
          { inline_data: { mime_type: mediaType, data: image } },
        ]}],
        generationConfig: { responseMimeType: 'application/json' },
      }),
    });
  } catch (err) {
    return { statusCode: 502, body: JSON.stringify({ error: 'Gemini 호출 실패: ' + err.message }) };
  }

  const data = await geminiRes.json();
  if (!geminiRes.ok)
    return { statusCode: geminiRes.status, body: JSON.stringify({ error: data.error?.message || 'Gemini API 오류' }) };

  let result;
  try {
    const text = data.candidates?.[0]?.content?.parts?.[0]?.text?.trim() || '';
    const match = text.match(/\{[\s\S]*\}/);
    result = JSON.parse(match ? match[0] : text);
  } catch {
    return { statusCode: 422, body: JSON.stringify({ error: '수치를 인식하지 못했습니다.' }) };
  }

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(result),
  };
};
