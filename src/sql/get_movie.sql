SELECT {% if filters %}{{ filters | join(', ') | sqlsafe }}{% else %}*{% endif %}
FROM {{ table | sqlsafe }}
{% if movie %}
WHERE UPPER(film) = UPPER('{{ movie | sqlsafe}}');
{% endif %}