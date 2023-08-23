SELECT "Lead Studio", SUM("Profitability") AS "total_profitability"
FROM "movies"
GROUP BY "Lead Studio"
ORDER BY "total_profitability" DESC
LIMIT 10;
