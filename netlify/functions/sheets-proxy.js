exports.handler = async (event) => {
  const { sheet, id: sheetsId } = event.queryStringParameters || {};
  if (!sheet)     return { statusCode: 400, body: JSON.stringify({ error: 'sheet required' }) };
  if (!sheetsId)  return { statusCode: 400, body: JSON.stringify({ error: 'id required' }) };

  const url = `https://docs.google.com/spreadsheets/d/${sheetsId}/gviz/tq?tqx=out:json&sheet=${encodeURIComponent(sheet)}`;

  try {
    const res = await fetch(url);
    const text = await res.text();
    return {
      statusCode: 200,
      headers: {
        'Content-Type': 'text/plain; charset=utf-8',
        'Cache-Control': 'public, max-age=300',
      },
      body: text,
    };
  } catch (err) {
    return { statusCode: 502, body: JSON.stringify({ error: err.message }) };
  }
};
