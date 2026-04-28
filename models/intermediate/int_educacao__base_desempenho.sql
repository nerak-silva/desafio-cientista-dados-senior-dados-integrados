{{
    config(
        schema="intermediate_rmi",
        alias="base_desempenho",
        materialized="table"
    )
}}

with avaliacao as (

    select *
    from {{ ref('int_educacao__avaliacao_normalizada') }}

),

turma as (

    select *
    from {{ ref('stg_educacao__turma') }}

),

aluno as (

    select *
    from {{ ref('stg_educacao__aluno') }}

),

frequencia as (

    select *
    from {{ ref('stg_educacao__frequencia') }}

),

escola as (

    select *
    from {{ ref('stg_educacao__escola') }}

),

turma_escola as (

    select
        id_turma,
        any_value(id_escola) as id_escola
    from frequencia
    where id_turma is not null
      and id_escola is not null
    group by id_turma

)

select
    a.id_aluno,
    a.id_turma,
    te.id_escola,
    e.id_bairro as id_bairro_escola,
    t.ano,
    a.bimestre,
    a.disciplina,
    a.nota,
    a.frequencia as frequencia_avaliacao,
    al.faixa_etaria,
    al.id_bairro as id_bairro_aluno
from avaliacao as a
left join turma as t
    on a.id_aluno = t.id_aluno
   and a.id_turma = t.id_turma
left join aluno as al
    on a.id_aluno = al.id_aluno
left join turma_escola as te
    on a.id_turma = te.id_turma
left join escola as e
    on te.id_escola = e.id_escola