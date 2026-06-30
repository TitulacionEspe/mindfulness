// Edge Function: emotional-chat
// Acompañante emocional empático (NO diagnostica). Llama a Google Gemini Flash.
// La GEMINI_API_KEY vive como secret del servidor, nunca en la app.
//
// Despliegue:
//   supabase secrets set GEMINI_API_KEY=tu_api_key
//   supabase functions deploy emotional-chat
//
// Respuesta JSON:
// { reply: string, riskLevel: 'none'|'low'|'high', suggestAppointment: boolean, available?: boolean }

import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY") ?? "";
const GEMINI_MODEL = Deno.env.get("GEMINI_MODEL") ?? "gemini-2.5-flash";
const SUPABASE_URL = Deno.env.get("SUPABASE_URL") ?? "";
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY") ?? "";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

const SYSTEM_PROMPT = `
Eres el Asistente de Nidara, un acompañante emocional dentro de una aplicación
universitaria de mindfulness e higiene del sueño. Tu rol es escuchar, comprender
y orientar con calma, sin reemplazar al personal de Psicología ni al personal de
la salud.

Como hablas:
- Tono neutral, respetuoso, cercano y de acompañamiento. Usa español natural de Ecuador.
- Valida lo que siente la persona antes de orientar ("tiene sentido que te sientas así").
- Evita trato romántico, coqueto, infantilizante o posesivo. No uses frases como
  "mi amor", "mi corazón", "mi vida", "cariño" ni similares.
- Respuestas breves y humanas (2 a 4 frases). Haz una pregunta abierta y suave si aporta claridad.
- Si la persona pide un dato concreto y seguro, responde brevemente y vuelve al objetivo de bienestar.

Lo que NUNCA haces:
- No diagnosticas ni das etiquetas clínicas (depresión, ansiedad, trastorno, etc.).
- No recomiendas medicamentos ni tomas decisiones por la persona.
- Jamás usas lenguaje estigmatizante ("loco", "loca", "demente", "exagerado").
- No prometes confidencialidad absoluta si hay riesgo de vida.
- No muestras JSON, llaves, comillas de estructura, markdown ni texto técnico.

Si la persona expresa angustia fuerte, desesperanza profunda, ideas de hacerse daño,
de no querer vivir, o autolesión:
- Responde con calma y contención, sin alarmar ni juzgar.
- Recuérdale que no está sola y que pedir ayuda es válido.
- Sugiere agendar una cita con personal de Psicología desde el módulo de Citas.
- Si el riesgo es alto, incluye una línea de emergencia: en Ecuador, 911 o 171 opción 6.

Devuelve SIEMPRE y ÚNICAMENTE un JSON válido con esta forma exacta:
{"reply": "<tu mensaje para la persona>", "riskLevel": "none|low|high", "suggestAppointment": true|false}
- riskLevel "high" y suggestAppointment true cuando detectes riesgo de daño.
- riskLevel "low" para tristeza o estrés notable sin riesgo; suggestAppointment puede ser true si crees que le ayudaría.
- riskLevel "none" para conversación cotidiana.
`.trim();

const RESPONSE_SCHEMA = {
  type: "object",
  properties: {
    reply: {
      type: "string",
      description:
        "Respuesta final visible para el usuario. Español natural, sin JSON ni markdown.",
    },
    riskLevel: {
      type: "string",
      enum: ["none", "low", "high"],
      description: "Nivel de riesgo detectado.",
    },
    suggestAppointment: {
      type: "boolean",
      description: "true si conviene sugerir una cita con Psicología.",
    },
  },
  required: ["reply", "riskLevel", "suggestAppointment"],
};

const RISK_PATTERNS: RegExp[] = [
  /\bsuicid/i,
  /\bme quiero morir\b/i,
  /\bno quiero (vivir|seguir)\b/i,
  /\bquitarme la vida\b/i,
  /\bhacerme da[nñ]o\b/i,
  /\bauto[\s-]?lesi/i,
  /\bcortarme\b/i,
  /\bya no aguanto\b/i,
  /\bno vale la pena (vivir|nada)\b/i,
  /\bmejor (estar muerto|no existir)\b/i,
];

function detectRisk(text: string): boolean {
  return RISK_PATTERNS.some((re) => re.test(text));
}

interface IncomingMessage {
  role: "user" | "assistant";
  content: string;
}

interface ParsedReply {
  reply: string;
  riskLevel: "none" | "low" | "high";
  suggestAppointment: boolean;
  available?: boolean;
}

const FALLBACK_REPLY =
  "Estoy aquí para acompañarte. Cuéntame un poco más, con calma.";

const ASSISTANT_UNAVAILABLE_REPLY =
  "El asistente de Nidara no está disponible en este momento. Intenta nuevamente más tarde.";

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

function unavailableReply(): ParsedReply {
  return {
    reply: ASSISTANT_UNAVAILABLE_REPLY,
    riskLevel: "none",
    suggestAppointment: false,
    available: false,
  };
}

function fallbackReply(): ParsedReply {
  return {
    reply: FALLBACK_REPLY,
    riskLevel: "none",
    suggestAppointment: false,
    available: true,
  };
}

function sanitizeSupportTone(reply: string): string {
  return reply
    .replace(
      /(^|,\s*|\s+)mi\s+(amor|coraz[oó]n|vida|cielo|rey|reina)\b[,.!¡¿?\s]*/gi,
      (_match, prefix) => (prefix.includes(",") ? ". " : prefix),
    )
    .replace(
      /(^|,\s*|\s+)(amor|coraz[oó]n|cariñ[oa]|corazoncito)\b[,.!¡¿?\s]*/gi,
      (_match, prefix) => (prefix.includes(",") ? ". " : prefix),
    )
    .replace(/\s+([,.!?])/g, "$1")
    .replace(/([,.!?])([A-Za-zÁÉÍÓÚÜÑáéíóúüñ])/g, "$1 $2")
    .replace(/\s{2,}/g, " ")
    .replace(/^\s*[,.!?]+\s*/, "")
    .trim();
}

function isUsableReply(reply: string): boolean {
  const clean = sanitizeSupportTone(reply).trim();
  if (!clean) return false;
  if (clean.toLowerCase() === "mi") return false;
  if (/^\s*[\{\[]/.test(clean)) return false;
  if (/"reply"|'reply'/.test(clean)) return false;
  if (!/[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]/.test(clean)) return false;

  const wordCount = clean.split(/\s+/).filter(Boolean).length;
  return clean.length >= 12 || wordCount >= 3;
}

async function callGemini(
  message: string,
  history: IncomingMessage[],
): Promise<ParsedReply> {
  const contents = [
    ...history.slice(-10).map((m) => ({
      role: m.role === "assistant" ? "model" : "user",
      parts: [{ text: m.content }],
    })),
    { role: "user", parts: [{ text: message }] },
  ];

  const requestBody = JSON.stringify({
    systemInstruction: { parts: [{ text: SYSTEM_PROMPT }] },
    contents,
    generationConfig: {
      temperature: 0.5,
      maxOutputTokens: 512,
      responseMimeType: "application/json",
      responseSchema: RESPONSE_SCHEMA,
    },
    safetySettings: [
      {
        category: "HARM_CATEGORY_DANGEROUS_CONTENT",
        threshold: "BLOCK_NONE",
      },
    ],
  });

  const retryable = new Set([429, 500, 503, 504]);
  const maxAttempts = 4;
  const backoffMs = (attempt: number) =>
    Math.min(4000, 1000 * 2 ** (attempt - 1));

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`;

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 20000);

    try {
      const res = await fetch(url, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        signal: controller.signal,
        body: requestBody,
      });

      if (!res.ok) {
        const errText = await res.text();
        console.error(`Gemini error (intento ${attempt})`, res.status, errText);

        if (retryable.has(res.status) && attempt < maxAttempts) {
          await new Promise((resolve) =>
            setTimeout(resolve, backoffMs(attempt)),
          );
          continue;
        }

        return unavailableReply();
      }

      const data = await res.json();
      const raw: string =
        data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";

      return parseModelReply(raw);
    } catch (err) {
      console.error(`Gemini fetch failed (intento ${attempt})`, err);
      if (attempt < maxAttempts) {
        await new Promise((resolve) =>
          setTimeout(resolve, attempt * 700 + 200),
        );
        continue;
      }
      return unavailableReply();
    } finally {
      clearTimeout(timeout);
    }
  }

  return unavailableReply();
}

function parseModelReply(raw: string): ParsedReply {
  const trimmed = raw.trim();
  try {
    const parsed = JSON.parse(trimmed);
    const reply =
      typeof parsed.reply === "string" ? sanitizeSupportTone(parsed.reply) : "";

    if (!isUsableReply(reply)) {
      return unavailableReply();
    }

    const riskLevel = ["none", "low", "high"].includes(parsed.riskLevel)
      ? parsed.riskLevel
      : "none";
    const suggestAppointment = parsed.suggestAppointment === true;
    return { reply, riskLevel, suggestAppointment, available: true };
  } catch (_e) {
    if (/^\s*[\{\[]/.test(trimmed) || /"reply"|'reply'/.test(trimmed)) {
      return unavailableReply();
    }

    const reply = sanitizeSupportTone(trimmed);
    if (!isUsableReply(reply)) return unavailableReply();
    return { ...fallbackReply(), reply };
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.startsWith("Bearer ")) {
    return jsonResponse({ error: "No autorizado" }, 401);
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData?.user) {
    return jsonResponse({ error: "Sesión inválida" }, 401);
  }

  let payload: { message?: string; history?: IncomingMessage[] };
  try {
    payload = await req.json();
  } catch (_e) {
    return jsonResponse({ error: "Cuerpo inválido" }, 400);
  }

  const message = (payload.message ?? "").trim();
  if (!message) {
    return jsonResponse({ error: "Mensaje vacío" }, 400);
  }

  const history = Array.isArray(payload.history) ? payload.history : [];

  if (!GEMINI_API_KEY) {
    console.error("GEMINI_API_KEY no configurada");
    return jsonResponse(unavailableReply());
  }

  const result = await callGemini(message, history);

  if (detectRisk(message)) {
    result.riskLevel = "high";
    result.suggestAppointment = true;
  }

  return jsonResponse(result);
});
