SELECT Genre, ROUND(AVG("Profitability"),2) AS "avg_profitability"
FROM "movies"
GROUP BY Genre
ORDER BY avg_profitability DESC;