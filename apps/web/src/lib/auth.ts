import { jwtVerify, SignJWT } from 'jose';
import { headers } from 'next/headers';
import { env } from './env';

const secret = new TextEncoder().encode(env.appJwtSecret);

export type AppJwtPayload = {
  sub: string;
  email?: string;
};

export const issueAppJwt = async (payload: AppJwtPayload) =>
  new SignJWT(payload)
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuedAt()
    .setExpirationTime('7d')
    .sign(secret);

export const verifyAppJwt = async (token: string) => {
  const result = await jwtVerify(token, secret);
  return result.payload as AppJwtPayload;
};

export const getUserFromAuthHeader = async () => {
  const headerMap = await headers();
  const authorization = headerMap.get('authorization');
  if (!authorization) return null;
  const token = authorization.replace('Bearer ', '');
  if (!token) return null;
  try {
    return await verifyAppJwt(token);
  } catch {
    return null;
  }
};
