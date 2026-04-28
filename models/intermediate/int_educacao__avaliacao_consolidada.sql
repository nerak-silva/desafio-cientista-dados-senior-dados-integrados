{{
    config(
        schema="intermediate_rmi",
        alias="avaliacao_consolidada",
        materialized="table"
    )
}}

select
    id_aluno,
    id_turma,
    bimestre,
    max(frequencia) as frequencia,
    max(disciplina_1) as disciplina_1,
    max(disciplina_2) as disciplina_2,
    max(disciplina_3) as disciplina_3,
    max(disciplina_4) as disciplina_4
from {{ ref('stg_educacao__avaliacao') }}
group by 1, 2, 3