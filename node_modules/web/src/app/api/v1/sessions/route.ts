import { createSessionSchema } from '@persona-mirror/shared-contracts';
import { getAssistantReply } from '@/lib/claude';
import { getUserFromAuthHeader } from '@/lib/auth';
import { fail, ok } from '@/lib/http';
import { memoryStore } from '@/lib/store';

export async function POST(request: Request) {
  const user = await getUserFromAuthHeader();
  if (!user) return fail('Unauthorized', 401);

  try {
    const input = createSessionSchema.parse(await request.json());
    const scenario = memoryStore.getScenario(input.scenario_id);
    if (!scenario || scenario.user_id !== user.sub) return fail('Scenario not found', 404);

    const session = memoryStore.createSession({
      scenario_id: scenario.id,
      user_id: user.sub,
    });

    const firstMessage = await getAssistantReply(scenario.context, 'Konusmayi sen baslat.');
    const assistantMessage = memoryStore.addMessage({
      session_id: session.id,
      role: 'assistant',
      content: firstMessage,
    });

    return ok({ session, first_message: assistantMessage }, 201);
  } catch (error) {
    return fail(error instanceof Error ? error.message : 'Session creation failed', 400);
  }
}
