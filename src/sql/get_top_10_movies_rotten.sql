SELECT {% if filters %}{{ filters | join(', ') | sqlsafe }}{% else %}*{% endif %}
FROM {{ table | sqlsafe }}
ORDER BY "rotten tomatoes %" DESC
LIMIT 10;
