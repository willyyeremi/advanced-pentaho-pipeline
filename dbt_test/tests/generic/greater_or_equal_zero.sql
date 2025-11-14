{% test greater_or_equal_zero(model, column_name) %}

SELECT 
    {{ column_name }}
FROM 
    {{ model }}
WHERE 
    {{ column_name }} >= 0 

{% endtest %}