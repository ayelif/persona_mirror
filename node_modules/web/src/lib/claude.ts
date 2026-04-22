import Anthropic from '@anthropic-ai/sdk';
import { analysisSchema } from '@persona-mirror/shared-contracts';
import { env, hasExternalIntegrations } from './env';
import { buildAnalysisPrompt, buildCharacterPrompt } from './prompts';

const client = new Anthropic({ apiKey: env.anthropicApiKey });

export const getAssistantReply = async (scenarioContext: string, history: string) => {
  if (!hasExternalIntegrations) {
    return `Bunu duyuyorum. Biraz daha acabilir misin? (baglam: ${scenarioContext.slice(0, 30)}...)`;
  }

  const response = await client.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 350,
    system: buildCharacterPrompt(scenarioContext),
    messages: [{ role: 'user', content: history }],
  });

  const text = response.content.find((block) => block.type === 'text');
  return text?.text ?? 'Seni anliyorum, devam edelim.';
};

export const getSessionAnalysis = async (history: string) => {
  if (!hasExternalIntegrations) {
    return {
      empathy_score: 7,
      clarity_score: 7,
      assertiveness_score: 6,
      summary: 'Mesajlarin net ve dengeli. Biraz daha somut talep dili guclendirebilir.',
      strengths: ['Sakin bir ton kullandin'],
      improvements: ['Talebini daha erken netlestir'],
      alternative_lines: ['Bunu soylemek isterim: beklentimi acikca paylasiyorum.'],
    };
  }

  const response = await client.messages.create({
    model: 'claude-sonnet-4-20250514',
    max_tokens: 900,
    messages: [{ role: 'user', content: buildAnalysisPrompt(history) }],
  });

  const text = response.content.find((block) => block.type === 'text');
  const parsed = JSON.parse(text?.text ?? '{}');
  return analysisSchema.parse(parsed);
};
