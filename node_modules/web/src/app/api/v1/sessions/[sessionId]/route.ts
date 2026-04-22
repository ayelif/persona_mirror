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
  const messages = memoryStore.getSessionMessages(sessionId);
  return ok({ session, messages });
}
