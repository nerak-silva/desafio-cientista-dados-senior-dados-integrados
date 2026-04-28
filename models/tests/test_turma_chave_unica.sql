select
    id_turma,
    id_aluno,
    count(*) as qtd
from {{ ref('stg_educacao__turma') }}
group by 1, 2
having count(*) > 1