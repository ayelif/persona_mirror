'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { api } from '@/lib/client-api';

type Scenario = {
  id: string;
  title: string;
  context: string;
  category: string;
};

export default function Home() {
  const [idToken, setIdToken] = useState('');
  const [title, setTitle] = useState('');
  const [context, setContext] = useState('');
  const [category, setCategory] = useState('work');
  const [scenarios, setScenarios] = useState<Scenario[]>([]);
  const [error, setError] = useState('');
  const router = useRouter();

  const loadScenarios = async () => {
    const token = localStorage.getItem('pm_token');
    if (!token) return;
    const result = await api.getScenarios();
    setScenarios(result.scenarios ?? []);
  };

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void loadScenarios();
  }, []);

  const onLogin = async () => {
    setError('');
    const result = await api.login(idToken);
    if (result.error) {
      setError(result.error.message);
      return;
    }
    localStorage.setItem('pm_token', result.access_token);
    await loadScenarios();
  };

  const onCreateScenario = async () => {
    setError('');
    const result = await api.createScenario({ title, context, category });
    if (result.error) {
      setError(result.error.message);
      return;
    }
    setTitle('');
    setContext('');
    await loadScenarios();
  };

  const onStart = async (scenarioId: string) => {
    const result = await api.createSession(scenarioId);
    if (result.error) {
      setError(result.error.message);
      return;
    }
    router.push(`/sessions/${result.session.id}`);
  };

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-4xl flex-col gap-6 bg-[#faf7f4] p-6 text-[#2c2c2c]">
      <section className="rounded-2xl bg-white p-6 shadow-sm">
        <h1 className="text-2xl font-bold">Persona Mirror</h1>
        <p className="mt-2 text-sm text-[#7a7a7a]">Zor konuşmaları prova et.</p>
        <label className="mt-4 block text-sm">Google id_token (MVP demo)</label>
        <input
          className="mt-1 w-full rounded-lg border border-[#e0d9d2] px-3 py-2"
          value={idToken}
          onChange={(event) => setIdToken(event.target.value)}
        />
        <button className="mt-3 rounded-lg bg-[#1e2a4a] px-4 py-2 text-white" onClick={onLogin}>
          Google ile Giriş
        </button>
      </section>

      <section className="rounded-2xl bg-white p-6 shadow-sm">
        <h2 className="text-xl font-semibold">Yeni Senaryo</h2>
        <input
          className="mt-3 w-full rounded-lg border border-[#e0d9d2] px-3 py-2"
          placeholder="Baslik"
          value={title}
          onChange={(event) => setTitle(event.target.value)}
        />
        <textarea
          className="mt-3 min-h-28 w-full rounded-lg border border-[#e0d9d2] px-3 py-2"
          placeholder="Konusma baglami"
          value={context}
          onChange={(event) => setContext(event.target.value)}
        />
        <select
          className="mt-3 w-full rounded-lg border border-[#e0d9d2] px-3 py-2"
          value={category}
          onChange={(event) => setCategory(event.target.value)}
        >
          <option value="work">Is Hayati</option>
          <option value="family">Aile</option>
          <option value="friendship">Arkadaslik</option>
          <option value="romantic">Romantik</option>
          <option value="other">Diger</option>
        </select>
        <button className="mt-3 rounded-lg bg-[#1e2a4a] px-4 py-2 text-white" onClick={onCreateScenario}>
          Simulasyona Basla
        </button>
      </section>

      <section className="rounded-2xl bg-white p-6 shadow-sm">
        <h2 className="text-xl font-semibold">Gecmis Senaryolar</h2>
        <ul className="mt-3 space-y-2">
          {scenarios.map((scenario) => (
            <li key={scenario.id} className="flex items-center justify-between rounded-lg border border-[#efe7df] p-3">
              <div>
                <p className="font-medium">{scenario.title}</p>
                <p className="text-xs text-[#7a7a7a]">{scenario.category}</p>
              </div>
              <button className="rounded-lg bg-[#2c2c2c] px-3 py-2 text-white" onClick={() => onStart(scenario.id)}>
                Oturum Ac
              </button>
            </li>
          ))}
        </ul>
      </section>
      {error ? <p className="text-sm text-red-600">{error}</p> : null}
    </main>
  );
}
