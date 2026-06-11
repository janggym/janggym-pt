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

  const prompt = `이 음식 사진에서 보이는 음식들의 영양 정보를 추정해줘.
다른 설명 없이 아래 JSON 형식으로만 응답해:
{"foods":[{"name":"음식이름","calories":숫자,"carb":숫자,"protein":숫자,"fat":숫자}],"total_calories":숫자,"total_carb":숫자,"total_protein":숫자,"total_fat":숫자}
calories는 kcal, carb/protein/fat은 g 단위. 사진에 보이는 양 기준으로 추정.
음식이 보이지 않으면 {"foods":[],"total_calories":0,"total_carb":0,"total_protein":0,"total_fat":0}`;

  let geminiRes;
  try {
    geminiRes = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [
          { text: prompt },
          { inline_data: { mime_type: mediaType, data: image } },
        ]}],
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
    const parts = data.candidates?.[0]?.content?.parts || [];
    const text = parts.filter(p => !p.thought).map(p => p.text || '').join('').trim();
    const match = text.match(/\{[\s\S]*\}/);
    result = JSON.parse(match ? match[0] : text);
  } catch {
    return { statusCode: 422, body: JSON.stringify({ error: '칼로리를 분석하지 못했습니다.' }) };
  }

  return {
    statusCode: 200,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(result),
  };
};
