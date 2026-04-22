'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { api } from '@/lib/client-api';

type Analysis = {
  empathy_score: number;
  clarity_score: number;
  assertiveness_score: number;
  summary: string;
  strengths: string[];
  improvements: string[];
  alternative_lines: string[];
  share_image_url?: string | null;
};

export default function AnalysisPage() {
  const params = useParams<{ sessionId: string }>();
  const [analysis, setAnalysis] = useState<Analysis | null>(null);
  const [error, setError] = useState('');

  useEffect(() => {
    const run = async () => {
      let result = await api.getAnalysis(params.sessionId);
      if (result.error) {
        result = await fetch(`/api/v1/sessions/${params.sessionId}/analyse`, {
          method: 'POST',
          headers: { Authorization: `Bearer ${localStorage.getItem('pm_token') ?? ''}` },
        }).then((response) => response.json());
      }
      if (result.error) {
        setError(result.error.message);
        return;
      }
      setAnalysis(result.analysis);
    };
    void run();
  }, [params.sessionId]);

  if (!analysis && !error) return <main className="p-6">Rapor yukleniyor...</main>;

  return (
    <main className="mx-auto flex min-h-screen w-full max-w-3xl flex-col gap-4 bg-[#faf7f4] p-6">
      <h1 className="text-2xl font-bold">Analiz Raporu</h1>
      {error ? <p className="text-red-600">{error}</p> : null}
      {analysis ? (
        <section className="rounded-2xl bg-white p-6 shadow-sm">
          <p className="font-medium">Empati: {analysis.empathy_score}/10</p>
          <p className="font-medium">Netlik: {analysis.clarity_score}/10</p>
          <p className="font-medium">Kararlilik: {analysis.assertiveness_score}/10</p>
          <p className="mt-3 text-sm">{analysis.summary}</p>
          <h2 className="mt-4 font-semibold">Guclu Yanlar</h2>
          <ul className="list-disc pl-5">{analysis.strengths?.map((item) => <li key={item}>{item}</li>)}</ul>
          <h2 className="mt-4 font-semibold">Gelisim Alanlari</h2>
          <ul className="list-disc pl-5">{analysis.improvements?.map((item) => <li key={item}>{item}</li>)}</ul>
          <h2 className="mt-4 font-semibold">Su da Diyebilirdin</h2>
          <ul className="list-disc pl-5">
            {analysis.alternative_lines?.map((item) => <li key={item}>{item}</li>)}
          </ul>
          <button className="mt-4 rounded-lg bg-[#1e2a4a] px-4 py-2 text-white">Bu Analizi Paylas</button>
        </section>
      ) : null}
    </main>
  );
}
