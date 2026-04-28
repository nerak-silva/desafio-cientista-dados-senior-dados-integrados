select *
from {{ ref('stg_educacao__avaliacao') }}
where frequencia < 0
   or frequencia > 100