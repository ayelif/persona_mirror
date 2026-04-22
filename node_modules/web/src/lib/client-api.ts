'use client';

const authHeaders = (): Record<string, string> => {
  const token = localStorage.getItem('pm_token');
  if (!token) return {};
  return { Authorization: `Bearer ${token}` };
};

const jsonHeaders = () => ({
  'Content-Type': 'application/json',
  ...authHeaders(),
});

export const api = {
  login: async (idToken: string) => {
    const response = await fetch('/api/v1/auth/google', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ id_token: idToken }),
    });
    return response.json();
  },
  getScenarios: async () => {
    const response = await fetch('/api/v1/scenarios', {
      headers: authHeaders(),
    });
    return response.json();
  },
  createScenario: async (payload: { title: string; context: string; category: string }) => {
    const response = await fetch('/api/v1/scenarios', {
      method: 'POST',
      headers: jsonHeaders(),
      body: JSON.stringify(payload),
    });
    return response.json();
  },
  createSession: async (scenarioId: string) => {
    const response = await fetch('/api/v1/sessions', {
      method: 'POST',
      headers: jsonHeaders(),
      body: JSON.stringify({ scenario_id: scenarioId }),
    });
    return response.json();
  },
  getSession: async (sessionId: string) => {
    const response = await fetch(`/api/v1/sessions/${sessionId}`, { headers: authHeaders() });
    return response.json();
  },
  sendMessage: async (sessionId: string, content: string) => {
    const response = await fetch(`/api/v1/sessions/${sessionId}/message`, {
      method: 'POST',
      headers: jsonHeaders(),
      body: JSON.stringify({ content }),
    });
    return response.json();
  },
  endSession: async (sessionId: string) => {
    const response = await fetch(`/api/v1/sessions/${sessionId}/end`, {
      method: 'PATCH',
      headers: authHeaders(),
    });
    return response.json();
  },
  getAnalysis: async (sessionId: string) => {
    const response = await fetch(`/api/v1/sessions/${sessionId}/analyse`, {
      headers: authHeaders(),
    });
    return response.json();
  },
};
