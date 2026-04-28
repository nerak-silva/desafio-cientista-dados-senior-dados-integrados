{{
    config(
        schema="mart_rmi",
        alias="desempenho_perfil_turma",
        materialized="table"
    )
}}

with base as (

    select
        id_turma,
        id_aluno,
        bimestre,
        disciplina,
        nota,
        frequencia_avaliacao
    from {{ ref('int_educacao__base_desempenho') }}
    where id_turma is not null
      and id_aluno is not null
      and nota is not null

),

turma_resumo as (

    select
        id_turma,
        count(distinct id_aluno) as qtd_alunos,
        count(nota) as qtd_avaliacoes,
        round(avg(nota), 2) as media_nota,
        round(avg(frequencia_avaliacao), 2) as media_frequencia,
        round(
            safe_divide(
                count(distinct case when nota < 5 then id_aluno end),
                count(distinct id_aluno)
            ) * 100,
            2
        ) as pct_alunos_nota_abaixo_5,
        round(
            safe_divide(
                count(distinct case when nota >= 7 then id_aluno end),
                count(distinct id_aluno)
            ) * 100,
            2
        ) as pct_alunos_nota_acima_7
    from base
    group by id_turma

)

select
    id_turma,
    concat(
        'Turma ',
        cast(dense_rank() over (order by id_turma) as string)
    ) as turma_anonimizada,
    qtd_alunos,
    case
        when qtd_alunos <= 20 then 'Pequena'
        when qtd_alunos <= 35 then 'Média'
        else 'Grande'
    end as tamanho_turma,
    qtd_avaliacoes,
    media_nota,
    media_frequencia,
    pct_alunos_nota_abaixo_5,
    pct_alunos_nota_acima_7
from turma_resumo