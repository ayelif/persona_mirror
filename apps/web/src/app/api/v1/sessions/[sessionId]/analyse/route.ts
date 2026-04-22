import { getSessionAnalysis } from '@/lib/claude';
import { getUserFromAuthHeader } from '@/lib/auth';
import { fail, ok } from '@/lib/http';
import { memoryStore } from '@/lib/store';

export async function GET(
  _request: Request,
  context: { params: Promise<{ sessionId: string }> },
) {
  const user = await getUserFromAuthHeader();
  if (!user) return fail('Unauthorized', 401);
  const { sessionId } = await context.params;
  const session = memoryStore.getSession(sessionId);
  if (!session || session.user_id !== user.sub) return fail('Session not found', 404);
  const analysis = memoryStore.getAnalysis(sessionId);
  if (!analysis) return fail('Analysis not found', 404);
  return ok({ analysis });
}

export async function POST(
  _request: Request,
  context: { params: Promise<{ sessionId: string }> },
) {
  const user = await getUserFromAuthHeader();
  if (!user) return fail('Unauthorized', 401);
  const { sessionId } = await context.params;
  const session = memoryStore.getSession(sessionId);
  if (!session || session.user_id !== user.sub) return fail('Session not found', 404);
  const conversation = memoryStore
    .getSessionMessages(sessionId)
    .map((message) => `${message.role.toUpperCase()}: ${message.content}`)
    .join('\n');
  const analysis = await getSessionAnalysis(conversation);
  const saved = memoryStore.saveAnalysis({
    session_id: sessionId,
    ...analysis,
    share_image_url: `https://example.com/share/${sessionId}.png`,
  });
  return ok({ analysis: saved }, 201);
}
