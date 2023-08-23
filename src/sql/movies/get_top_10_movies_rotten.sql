SELECT 
{%- if filters %}
{%- for f in filters %} "{{ f | replace('%20', ' ') | sqlsafe }}"
{%- if not loop.last %},{% endif %}
{%- endfor %}
{%- else %}
*
{%- endif %}
FROM "movies"
ORDER BY "rotten tomatoes %" DESC
LIMIT 10;
