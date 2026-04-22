import { OAuth2Client } from 'google-auth-library';
import { googleAuthSchema } from '@persona-mirror/shared-contracts';
import { issueAppJwt } from '@/lib/auth';
import { env } from '@/lib/env';
import { fail, ok } from '@/lib/http';
import { memoryStore } from '@/lib/store';

const googleClient = new OAuth2Client(env.googleClientId);

export async function POST(request: Request) {
  try {
    const body = googleAuthSchema.parse(await request.json());
    let email: string | null = null;
    let sub = body.id_token;

    if (env.googleClientId) {
      const ticket = await googleClient.verifyIdToken({
        idToken: body.id_token,
        audience: env.googleClientId,
      });
      const payload = ticket.getPayload();
      if (!payload?.sub) return fail('Invalid Google token', 401);
      sub = payload.sub;
      email = payload.email ?? null;
    }

    const user = memoryStore.getOrCreateUser(sub, email);
    const accessToken = await issueAppJwt({
      sub: user.id,
      email: user.email ?? undefined,
    });

    return ok({ access_token: accessToken, user });
  } catch (error) {
    return fail(error instanceof Error ? error.message : 'Authentication failed', 400);
  }
}
