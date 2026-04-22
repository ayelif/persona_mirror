import { createScenarioSchema } from '@persona-mirror/shared-contracts';
import { getUserFromAuthHeader } from '@/lib/auth';
import { fail, ok } from '@/lib/http';
import { memoryStore } from '@/lib/store';

export async function GET() {
  const user = await getUserFromAuthHeader();
  if (!user) return fail('Unauthorized', 401);
  return ok({ scenarios: memoryStore.listScenarios(user.sub) });
}

export async function POST(request: Request) {
  const user = await getUserFromAuthHeader();
  if (!user) return fail('Unauthorized', 401);
  try {
    const input = createScenarioSchema.parse(await request.json());
    const scenario = memoryStore.createScenario({
      user_id: user.sub,
      title: input.title,
      context: input.context,
      category: input.category,
    });
    return ok({ scenario }, 201);
  } catch (error) {
    return fail(error instanceof Error ? error.message : 'Validation failed', 400);
  }
}
