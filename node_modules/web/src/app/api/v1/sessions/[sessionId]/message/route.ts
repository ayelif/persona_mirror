import { sessionMessageSchema } from '@persona-mirror/shared-contracts';
import { getAssistantReply } from '@/lib/claude';
import { getUserFromAuthHeader } from '@/lib/auth';
import { fail, ok } from '@/lib/http';
import { memoryStore } from '@/lib/store';

export async function POST(
  request: Request,
  context: { params: Promise<{ sessionId: string }> },
) {
  const user = await getUserFromAuthHeader();
  if (!user) return fail('Unauthorized', 401);
  const { sessionId } = await context.params;
  const session = memoryStore.getSession(sessionId);
  if (!session || session.user_id !== user.sub) return fail('Session not found', 404);

  try {
    const input = sessionMessageSchema.parse(await request.json());
    memoryStore.addMessage({
      session_id: sessionId,
      role: 'user',
      content: input.content,
    });

    const conversation = memoryStore
      .getSessionMessages(sessionId)
      .map((message) => `${message.role.toUpperCase()}: ${message.content}`)
      .join('\n');

    const scenario = memoryStore.getScenario(session.scenario_id);
    const reply = await getAssistantReply(scenario?.context ?? '', conversation);
    const assistantMessage = memoryStore.addMessage({
      session_id: sessionId,
      role: 'assistant',
      content: reply,
    });

    return ok({ message: assistantMessage });
  } catch (error) {
    return fail(error instanceof Error ? error.message : 'Message failed', 400);
  }
}
