SELECT {% if filters %}{{ filters | join(', ') | sqlsafe }}{% else %}*{% endif %}
FROM {{ table | sqlsafe }}
WHERE UPPER(genre) = UPPER('{{ genre | sqlsafe}}');