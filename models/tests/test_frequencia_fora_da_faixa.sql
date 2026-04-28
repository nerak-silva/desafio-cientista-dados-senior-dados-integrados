select *
from {{ ref('stg_educacao__frequencia') }}
where frequencia < 0
   or frequencia > 100