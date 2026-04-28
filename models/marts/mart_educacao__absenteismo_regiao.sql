{{
    config(
        schema="mart_rmi",
        alias="absenteismo_regiao",
        materialized="table"
    )
}}

with base as (

    select
        id_bairro_escola,
        id_aluno,
        frequencia_avaliacao
    from {{ ref('int_educacao__base_desempenho') }}
    where id_bairro_escola is not null
      and id_aluno is not null
      and frequencia_avaliacao is not null

),

frequencia_aluno_regiao as (

    select
        id_bairro_escola,
        id_aluno,
        round(avg(frequencia_avaliacao), 2) as media_frequencia_aluno
    from base
    group by
        id_bairro_escola,
        id_aluno

),

regioes_nomeadas as (

    select
        id_bairro_escola,
        concat(
            'Bairro ',
            cast(dense_rank() over (order by id_bairro_escola) as string)
        ) as regiao_anonimizada
    from frequencia_aluno_regiao
    group by id_bairro_escola

)

select
    f.id_bairro_escola,
    r.regiao_anonimizada,

    count(distinct f.id_aluno) as qtd_alunos,

    count(distinct case
        when f.media_frequencia_aluno < 75 then f.id_aluno
    end) as qtd_alunos_freq_abaixo_75,

    round(avg(f.media_frequencia_aluno), 2) as media_frequencia,

    round(
        safe_divide(
            count(distinct case
                when f.media_frequencia_aluno < 75 then f.id_aluno
            end),
            count(distinct f.id_aluno)
        ),
        4
    ) as pct_alunos_freq_abaixo_75

from frequencia_aluno_regiao as f
left join regioes_nomeadas as r
    on f.id_bairro_escola = r.id_bairro_escola
group by
    f.id_bairro_escola,
    r.regiao_anonimizada