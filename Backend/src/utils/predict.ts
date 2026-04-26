export const predictDelay = ({
  queueLength,
  cycles,
  timeOfDay,
}: {
  queueLength: number;
  cycles: number;
  timeOfDay: number;
}) => {
  const AVG_CYCLE_TIME = 60; // from real data

  // Base processing time
  let baseTime = cycles * AVG_CYCLE_TIME;

  // Queue effect (realistic)
  let queueImpact = queueLength * 6;

  // Peak hours (from your dataset)
  let peakMultiplier = 1;
  if ([16, 17, 18].includes(timeOfDay)) {
    peakMultiplier = 1.5;
  }

  const estimatedMinutes =
    (baseTime + queueImpact) * peakMultiplier;

  let delayRisk = "LOW";
  if (estimatedMinutes > 120) delayRisk = "HIGH";
  else if (estimatedMinutes > 60) delayRisk = "MEDIUM";

  return {
    estimatedMinutes: Math.round(estimatedMinutes),
    delayRisk,
  };
};