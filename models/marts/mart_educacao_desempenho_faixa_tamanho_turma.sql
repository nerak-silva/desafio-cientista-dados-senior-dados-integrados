{{
    config(
        schema="mart_rmi",
        alias="desempenho_faixa_tamanho_turma",
        materialized="table"
    )
}}

with turma_desempenho as (

    select
        id_turma,
        count(distinct id_aluno) as qtd_alunos,
        round(avg(nota), 2) as media_nota_turma
    from {{ ref('int_educacao__base_desempenho') }}
    where id_turma is not null
      and id_aluno is not null
      and nota is not null
    group by id_turma

),

turma_classificada as (

    select
        id_turma,
        qtd_alunos,
        media_nota_turma,

        case
            when qtd_alunos <= 30 then 'Até 30 alunos'
            when qtd_alunos <= 40 then '31 a 40 alunos'
            when qtd_alunos <= 50 then '41 a 50 alunos'
            when qtd_alunos <= 60 then '51 a 60 alunos'
            else 'Acima de 60 alunos'
        end as faixa_tamanho_turma,

        case
            when qtd_alunos <= 30 then 1
            when qtd_alunos <= 40 then 2
            when qtd_alunos <= 50 then 3
            when qtd_alunos <= 60 then 4
            else 5
        end as ordem_faixa_tamanho_turma

    from turma_desempenho

)

select
    faixa_tamanho_turma,
    ordem_faixa_tamanho_turma,

    count(distinct id_turma) as qtd_turmas,
    sum(qtd_alunos) as qtd_alunos,
    round(avg(media_nota_turma), 2) as media_nota

from turma_classificada
group by
    faixa_tamanho_turma,
    ordem_faixa_tamanho_turma