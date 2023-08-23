SELECT {% if filters %}{{ filters | join(', ') | sqlsafe }}{% else %}*{% endif %}
FROM "movies"
ORDER BY "rotten tomatoes %" DESC
LIMIT 10;
