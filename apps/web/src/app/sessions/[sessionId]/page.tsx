'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { api } from '@/lib/client-api';

type Message = {
  id: string;
  role: 'user' | 'assistant';
  content: string;
};

export default function SessionPage() {
  const params = useParams<{ sessionId: string }>();
  const router = useRouter();
  const [messages, setMessages] = useState<Message[]>([]);
  const [content, setContent] = useState('');
  const [error, setError] = useState('');
  const [isSending, setIsSending] = useState(false);

  const loadSession = async () => {
    const result = await api.getSession(params.sessionId);
    if (result.error) {
      setError(result.error.message);
      return;
    }
    setMessages(result.messages ?? []);
  };

  useEffect(() => {
    // eslint-disable-next-line react-hooks/set-state-in-effect
    void loadSession();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [params.sessionId]);

  const onSend = async () => {
    if (!content.trim()) return;
    setIsSending(true);
    setError('');
    const userMessage: Message = { id: crypto.randomUUID(), role: 'user', content };
    setMessages((prev) => [...prev, userMessage]);
    const toSend = content;
    setContent('');
    const result = await api.sendMessage(params.sessionId, toSend);
    setIsSending(false);
    if (result.error) {
      setError(result.error.message);
      return;
    }
    setMessages((prev) => [...prev, result.message]);
  };

  const onEndSession = async () => {
    const result = await api.endSession(params.sessionId);
    if (result.error) {
      setError(result.error.message);
      return;
    }
    router.push(`/sessions/${params.sessionId}/analysis`);
  };

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-3xl flex-col gap-4 bg-[#faf7f4] p-6">
      <header className="flex items-center justify-between rounded-2xl bg-white p-4 shadow-sm">
        <h1 className="text-xl font-semibold">Simulasyon Oturumu</h1>
        <button className="rounded-lg bg-[#1e2a4a] px-3 py-2 text-white" onClick={onEndSession}>
          Oturumu Bitir & Analizi Al
        </button>
      </header>
      <section className="flex-1 space-y-2 rounded-2xl bg-white p-4 shadow-sm">
        {messages.map((message) => (
          <div
            key={message.id}
            className={`max-w-[80%] rounded-xl px-3 py-2 ${
              message.role === 'user' ? 'ml-auto bg-[#1e2a4a] text-white' : 'bg-[#f5efe9]'
            }`}
          >
            {message.content}
          </div>
        ))}
        {isSending ? <p className="text-sm text-[#7a7a7a]">AI yaziyor...</p> : null}
      </section>
      <footer className="rounded-2xl bg-white p-4 shadow-sm">
        <div className="flex gap-2">
          <input
            className="flex-1 rounded-lg border border-[#e0d9d2] px-3 py-2"
            value={content}
            onChange={(event) => setContent(event.target.value)}
            placeholder="Mesajini yaz"
          />
          <button className="rounded-lg bg-[#2c2c2c] px-4 py-2 text-white" onClick={onSend}>
            Gonder
          </button>
        </div>
        {error ? <p className="mt-2 text-sm text-red-600">{error}</p> : null}
      </footer>
    </main>
  );
}
