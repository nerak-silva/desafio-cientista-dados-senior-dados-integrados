{{
    config(
        schema="mart_rmi",
        alias="priorizacao_turmas",
        materialized="table"
    )
}}

-- Quais turmas devem ser priorizadas para intervenção?
-- Exemplos de uso: classifica a turma em prioridade, acompanhamento de turmas prioritárias, quantidade de turmas em alta prioridade
with turma_resumo as (

    select
        id_turma,
        count(distinct id_aluno) as qtd_alunos,
        round(avg(nota), 2) as media_nota,
        round(avg(frequencia_avaliacao), 2) as media_frequencia,
        round(
            safe_divide(
                count(distinct case when frequencia_avaliacao < 75 then id_aluno end),
                count(distinct id_aluno)
            ) * 100,
            2
        ) as pct_alunos_freq_abaixo_75,
        round(
            safe_divide(
                count(distinct case when nota < 5 then id_aluno end),
                count(distinct id_aluno)
            ) * 100,
            2
        ) as pct_alunos_nota_abaixo_5
    from {{ ref('int_educacao__base_desempenho') }}
    group by 1

)

select
    *,
    case
        when media_nota < 5 or pct_alunos_freq_abaixo_75 >= 20 then 'Alta'
        when media_nota < 7 or pct_alunos_freq_abaixo_75 >= 10 then 'Média'
        else 'Baixa'
    end as prioridade
from turma_resumo