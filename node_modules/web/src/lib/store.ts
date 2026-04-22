import { randomUUID } from 'node:crypto';

type User = { id: string; email: string | null; google_sub_id: string | null };
type Scenario = {
  id: string;
  user_id: string;
  title: string;
  context: string;
  category: string;
  created_at: string;
};
type Session = {
  id: string;
  user_id: string;
  scenario_id: string;
  status: 'active' | 'completed' | 'abandoned';
  started_at: string;
  ended_at: string | null;
};
type Message = { id: string; session_id: string; role: 'user' | 'assistant'; content: string; created_at: string };
type Analysis = {
  id: string;
  session_id: string;
  created_at: string;
  empathy_score: number;
  clarity_score: number;
  assertiveness_score: number;
  summary: string;
  strengths: string[];
  improvements: string[];
  alternative_lines: string[];
  share_image_url: string | null;
};

const users = new Map<string, User>();
const scenarios = new Map<string, Scenario>();
const sessions = new Map<string, Session>();
const messages: Message[] = [];
const analyses = new Map<string, Analysis>();

export const memoryStore = {
  getOrCreateUser: (googleSubId: string, email: string | null) => {
    const found = [...users.values()].find((user) => user.google_sub_id === googleSubId || user.email === email);
    if (found) return found;
    const created = { id: randomUUID(), email, google_sub_id: googleSubId };
    users.set(created.id, created);
    return created;
  },
  listScenarios: (userId: string) => [...scenarios.values()].filter((scenario) => scenario.user_id === userId),
  createScenario: (scenario: Omit<Scenario, 'id' | 'created_at'>) => {
    const created = { ...scenario, id: randomUUID(), created_at: new Date().toISOString() };
    scenarios.set(created.id, created);
    return created;
  },
  createSession: (session: Omit<Session, 'id' | 'started_at' | 'ended_at' | 'status'>) => {
    const created: Session = {
      ...session,
      id: randomUUID(),
      started_at: new Date().toISOString(),
      ended_at: null,
      status: 'active',
    };
    sessions.set(created.id, created);
    return created;
  },
  getSession: (id: string) => sessions.get(id),
  setSessionStatus: (id: string, status: Session['status']) => {
    const session = sessions.get(id);
    if (!session) return null;
    session.status = status;
    session.ended_at = new Date().toISOString();
    sessions.set(id, session);
    return session;
  },
  addMessage: (message: Omit<Message, 'id' | 'created_at'>) => {
    const created = { ...message, id: randomUUID(), created_at: new Date().toISOString() };
    messages.push(created);
    return created;
  },
  getSessionMessages: (sessionId: string) => messages.filter((message) => message.session_id === sessionId),
  saveAnalysis: (analysisInput: Omit<Analysis, 'id' | 'created_at'>) => {
    const analysis = { ...analysisInput, id: randomUUID(), created_at: new Date().toISOString() };
    analyses.set(analysis.session_id, analysis);
    return analysis;
  },
  getAnalysis: (sessionId: string) => analyses.get(sessionId) ?? null,
  getScenario: (id: string) => scenarios.get(id),
};
