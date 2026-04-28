{{
    config(
        schema="intermediate_rmi",
        alias="avaliacao_normalizada",
        materialized="table"
    )
}}

with base as (

    select *
    from {{ ref('int_educacao__avaliacao_consolidada') }}

),

notas as (

    select
        id_aluno,
        id_turma,
        bimestre,
        frequencia,
        'disciplina_1' as disciplina,
        disciplina_1 as nota
    from base

    union all

    select
        id_aluno,
        id_turma,
        bimestre,
        frequencia,
        'disciplina_2' as disciplina,
        disciplina_2 as nota
    from base

    union all

    select
        id_aluno,
        id_turma,
        bimestre,
        frequencia,
        'disciplina_3' as disciplina,
        disciplina_3 as nota
    from base

    union all

    select
        id_aluno,
        id_turma,
        bimestre,
        frequencia,
        'disciplina_4' as disciplina,
        disciplina_4 as nota
    from base

)

select
    id_aluno,
    id_turma,
    bimestre,
    frequencia,
    disciplina,
    nota
from notas
where nota is not null -- usada para análises de desempenho acadêmico, pois só considera registros que realmente têm nota