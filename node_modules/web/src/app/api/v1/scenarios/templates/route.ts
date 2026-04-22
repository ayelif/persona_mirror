import { ok } from '@/lib/http';

const templates = [
  { id: 'salary-negotiation', title: 'Zam Iste', category: 'work', context: 'Patronunla zam gorusmesi' },
  { id: 'set-boundaries', title: 'Sinir Koy', category: 'family', context: 'Aile bireyine sinir koyma konusmasi' },
  { id: 'hard-news', title: 'Zor Haberi Ver', category: 'friendship', context: 'Yakina zor bir haberi iletme' },
];

export async function GET() {
  return ok({ templates });
}
