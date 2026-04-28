select *
from {{ ref('stg_educacao__avaliacao') }}
where
    (disciplina_1 is not null and (disciplina_1 < 0 or disciplina_1 > 10))
    or (disciplina_2 is not null and (disciplina_2 < 0 or disciplina_2 > 10))
    or (disciplina_3 is not null and (disciplina_3 < 0 or disciplina_3 > 10))
    or (disciplina_4 is not null and (disciplina_4 < 0 or disciplina_4 > 10))