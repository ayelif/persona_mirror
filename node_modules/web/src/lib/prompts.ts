const corePrompt =
  'Sen bir rol yapma simulatöründe kullanicinin zor konusmalari prova etmesine yardimci olan bir yapay zekasin. Karsi tarafi gercekci ve hafif direncli canlandir. Cevaplarini kisa ve dogal tut.';

export const buildCharacterPrompt = (scenarioContext: string) =>
  `${corePrompt}\nBu senaryoda su kisiyi canlandiriyorsun: ${scenarioContext}`;

export const buildAnalysisPrompt = (conversation: string) =>
  [
    'Asagidaki konusmayi analiz et.',
    'Empati, netlik ve kararlilik puanlarini 1-10 arasinda ver.',
    'Guclu yanlar, gelisim alanlari ve alternatif ifadeler uret.',
    'Sadece JSON dondur.',
    conversation,
  ].join('\n\n');
