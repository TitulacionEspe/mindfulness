// Edge Function: emotional-chat
// Acompanante emocional empatico (NO diagnostica). Llama a Google Gemini Flash.
// La GEMINI_API_KEY vive como secret del servidor, nunca en la app.
//
// Despliegue:
//   supabase secrets set GEMINI_API_KEY=tu_api_key
//   supabase functions deploy emotional-chat
//
// Respuesta JSON: { reply: string, riskLevel: 'none'|'low'|'high', suggestAppointment: boolean }

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
Eres "Calma", un acompanante emocional calido dentro de una app universitaria de
mindfulness e higiene del sueno. Tu rol es ESCUCHAR, COMPRENDER y ALENTAR.

Como hablas:
- Tono carinoso, cercano, esperanzador y respetuoso. Usa el espanol de Ecuador, natural.
- Valida lo que siente la persona antes de cualquier otra cosa ("tiene sentido que te sientas asi").
- Anima con frases lindas y motivadoras que inviten a seguir adelante, sin sonar cursi ni falso.
- Respuestas breves y humanas (2 a 5 frases). Haz alguna pregunta abierta y suave para que se exprese.

Lo que NUNCA haces:
- No diagnosticas ni das etiquetas clinicas (depresion, ansiedad, trastorno, etc.).
- No recomiendas medicamentos ni tomas decisiones por la persona.
- Jamas usas lenguaje estigmatizante ("loco", "loca", "demente", "exagerado").
- No prometes confidencialidad absoluta si hay riesgo de vida.

Si la persona expresa angustia fuerte, desesperanza profunda, ideas de hacerse dano,
de no querer vivir, o autolesion:
- Responde con calma y contencion, sin alarmar ni juzgar.
- Recuerdale que no esta sola y que pedir ayuda es un acto de valentia.
- Sugierele con delicadeza agendar una cita con un psicologo desde el modulo de Citas
  de la app, para poder hablarlo con alguien preparado.
- Si el riesgo es alto, incluye una linea de emergencia (en Ecuador: 911, o linea de
  ayuda emocional 171 opcion 6).

Devuelve SIEMPRE y UNICAMENTE un JSON valido con esta forma exacta:
{"reply": "<tu mensaje para la persona>", "riskLevel": "none|low|high", "suggestAppointment": true|false}
- riskLevel "high" y suggestAppointment true cuando detectes riesgo de dano.
- riskLevel "low" para tristeza/estres notable sin riesgo; suggestAppointment puede ser true si crees que le ayudaria.
- riskLevel "none" para conversacion cotidiana.
`.trim();

// Capa de seguridad independiente del modelo: detecta patrones de riesgo aunque
// el modelo no los marque. Fuerza riskLevel='high' y suggestAppointment=true.
const RISK_PATTERNS: RegExp[] = [
  /\bsuicid/i,
  /\bme quiero morir\b/i,
  /\bno quiero (vivir|seguir)\b/i,
  /\bquitarme la vida\b/i,
  /\bhacerme dano\b/i,
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
}

const FALLBACK_REPLY =
  "Estoy aqui contigo y quiero escucharte. En este momento tuve un problemita para responderte, " +
  "pero no te quedes solo con lo que sientes. Cuentame de nuevo, con calma.";

function jsonResponse(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

async function callGemini(
  message: string,
  history: IncomingMessage[],
): Promise<ParsedReply> {
  // Construye contenidos: historial reciente + mensaje actual.
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
      temperature: 0.8,
      maxOutputTokens: 512,
      responseMimeType: "application/json",
    },
    safetySettings: [
      {
        category: "HARM_CATEGORY_DANGEROUS_CONTENT",
        threshold: "BLOCK_NONE",
      },
    ],
  });

  // Reintenta ante errores transitorios de Google (503/429/500) con backoff.
  // Importante para concurrencia: evita que un pico temporal muestre la
  // respuesta de respaldo al usuario.
  const RETRYABLE = new Set([429, 500, 503]);
  const maxAttempts = 4;
  // Backoff exponencial acotado: 1s, 2s, 4s (no mas, para no congelar la app).
  const backoffMs = (attempt: number) => Math.min(4000, 1000 * 2 ** (attempt - 1));

  for (let attempt = 1; attempt <= maxAttempts; attempt++) {
    const url =
      `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${GEMINI_API_KEY}`;

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

        if (RETRYABLE.has(res.status) && attempt < maxAttempts) {
          // Espera incremental: 600ms, 1400ms...
          await new Promise((r) => setTimeout(r, backoffMs(attempt)));
          continue;
        }

        return {
          reply: FALLBACK_REPLY,
          riskLevel: "none",
          suggestAppointment: false,
        };
      }

      const data = await res.json();
      const raw: string =
        data?.candidates?.[0]?.content?.parts?.[0]?.text ?? "";

      return parseModelReply(raw);
    } catch (err) {
      console.error(`Gemini fetch failed (intento ${attempt})`, err);
      if (attempt < maxAttempts) {
        await new Promise((r) => setTimeout(r, attempt * 700 + 200));
        continue;
      }
      return {
        reply: FALLBACK_REPLY,
        riskLevel: "none",
        suggestAppointment: false,
      };
    } finally {
      clearTimeout(timeout);
    }
  }

  return {
    reply: FALLBACK_REPLY,
    riskLevel: "none",
    suggestAppointment: false,
  };
}

function parseModelReply(raw: string): ParsedReply {
  try {
    const parsed = JSON.parse(raw);
    const reply = typeof parsed.reply === "string" && parsed.reply.trim()
      ? parsed.reply.trim()
      : FALLBACK_REPLY;
    const riskLevel = ["none", "low", "high"].includes(parsed.riskLevel)
      ? parsed.riskLevel
      : "none";
    const suggestAppointment = parsed.suggestAppointment === true;
    return { reply, riskLevel, suggestAppointment };
  } catch (_e) {
    // Si el modelo no devolvio JSON, usamos el texto crudo como respuesta.
    return {
      reply: raw.trim() || FALLBACK_REPLY,
      riskLevel: "none",
      suggestAppointment: false,
    };
  }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  // Verifica el JWT del usuario.
  const authHeader = req.headers.get("Authorization") ?? "";
  if (!authHeader.startsWith("Bearer ")) {
    return jsonResponse({ error: "No autorizado" }, 401);
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userData, error: userError } = await supabase.auth.getUser();
  if (userError || !userData?.user) {
    return jsonResponse({ error: "Sesion invalida" }, 401);
  }

  let payload: { message?: string; history?: IncomingMessage[] };
  try {
    payload = await req.json();
  } catch (_e) {
    return jsonResponse({ error: "Cuerpo invalido" }, 400);
  }

  const message = (payload.message ?? "").trim();
  if (!message) {
    return jsonResponse({ error: "Mensaje vacio" }, 400);
  }

  const history = Array.isArray(payload.history) ? payload.history : [];

  if (!GEMINI_API_KEY) {
    console.error("GEMINI_API_KEY no configurada");
    return jsonResponse({
      reply: FALLBACK_REPLY,
      riskLevel: "none",
      suggestAppointment: false,
    });
  }

  const result = await callGemini(message, history);

  // Capa de seguridad: si el texto del usuario tiene patrones de riesgo, forzamos escalamiento.
  if (detectRisk(message)) {
    result.riskLevel = "high";
    result.suggestAppointment = true;
  }

  return jsonResponse(result);
});
