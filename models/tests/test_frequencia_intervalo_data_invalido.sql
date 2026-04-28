select *
from {{ ref('stg_educacao__frequencia') }}
where safe_cast(data_fim as date) < safe_cast(data_inicio as date)