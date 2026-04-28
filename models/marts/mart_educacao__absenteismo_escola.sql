{{
    config(
        schema="mart_rmi",
        alias="absenteismo_escola",
        materialized="table"
    )
}}

with alunos_total_escola as (

    select
        id_escola,
        count(distinct id_aluno) as qtd_alunos_total_escola
    from {{ ref('stg_educacao__frequencia') }}
    where id_escola is not null
      and id_aluno is not null
    group by id_escola

),

base_avaliacao as (

    select
        id_escola,
        id_aluno,
        frequencia_avaliacao
    from {{ ref('int_educacao__base_desempenho') }}
    where id_escola is not null
      and id_aluno is not null
      and frequencia_avaliacao is not null

),

frequencia_aluno_escola as (

    select
        id_escola,
        id_aluno,
        round(avg(frequencia_avaliacao), 2) as media_frequencia_aluno
    from base_avaliacao
    group by
        id_escola,
        id_aluno

),

indicadores_avaliacao as (

    select
        id_escola,

        count(distinct id_aluno) as qtd_alunos_avaliados,

        count(distinct case
            when media_frequencia_aluno < 75 then id_aluno
        end) as qtd_alunos_avaliados_freq_abaixo_75,

        round(avg(media_frequencia_aluno), 2) as media_frequencia_avaliados,

        round(
            safe_divide(
                count(distinct case
                    when media_frequencia_aluno < 75 then id_aluno
                end),
                count(distinct id_aluno)
            ),
            4
        ) as pct_alunos_avaliados_freq_abaixo_75

    from frequencia_aluno_escola
    group by id_escola

),

escolas_nomeadas as (

    select
        id_escola,
        concat(
            'Escola ',
            cast(dense_rank() over (order by id_escola) as string)
        ) as escola_anonimizada
    from alunos_total_escola
    group by id_escola

)

select
    t.id_escola,
    e.escola_anonimizada,

    t.qtd_alunos_total_escola,

    coalesce(a.qtd_alunos_avaliados, 0) as qtd_alunos_avaliados,

    coalesce(
        a.qtd_alunos_avaliados_freq_abaixo_75,
        0
    ) as qtd_alunos_avaliados_freq_abaixo_75,

    a.media_frequencia_avaliados,

    coalesce(
        a.pct_alunos_avaliados_freq_abaixo_75,
        0
    ) as pct_alunos_avaliados_freq_abaixo_75,

    round(
        safe_divide(
            coalesce(a.qtd_alunos_avaliados, 0),
            t.qtd_alunos_total_escola
        ),
        4
    ) as pct_cobertura_avaliacao_na_escola

from alunos_total_escola as t
left join indicadores_avaliacao as a
    on t.id_escola = a.id_escola
left join escolas_nomeadas as e
    on t.id_escola = e.id_escola