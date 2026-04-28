{{
    config(
        schema="mart_rmi",
        alias="visao_geral_cards",
        materialized="table"
    )
}}

with
    -- Média de nota por aluno, calculada a partir da base normalizada por disciplina
    notas_aluno as (
        select
            id_aluno,
            avg(nota) as media_nota_aluno
        from {{ ref('int_educacao__base_desempenho') }}
        where nota is not null
        group by id_aluno
    ),

    -- Indicadores de desempenho usados nos cards de visao geral do dashboard
    desempenho as (
        select
            count(distinct id_aluno) as qtd_alunos_com_nota,
            sum(media_nota_aluno) as soma_medias_alunos,
            avg(media_nota_aluno) as media_nota,

            -- Quantidade de alunos em risco acadêmico
            countif(media_nota_aluno < 5) as qtd_alunos_media_abaixo_5,

            -- Percentual para apoio de análises e validações
            round(
                safe_divide(
                    countif(media_nota_aluno < 5),
                    count(distinct id_aluno)
                ),
                4
            ) as pct_alunos_media_abaixo_5

        from notas_aluno
    ),

    -- Média de frequência por aluno
    frequencia_aluno as (
        select
            id_aluno,
            avg(frequencia) as media_frequencia_aluno
        from {{ ref('stg_educacao__avaliacao') }}
        where frequencia is not null
        group by id_aluno
    ),

    -- Indicadores de frequência usados nos cards de visao geral do dashboard
    frequencia as (
        select
            count(distinct id_aluno) as qtd_alunos_com_frequencia,
            sum(media_frequencia_aluno) as soma_medias_frequencia_alunos,
            avg(media_frequencia_aluno) as media_frequencia,

            -- Quantidade de alunos em risco de absenteísmo
            countif(media_frequencia_aluno < 75) as qtd_alunos_freq_abaixo_75,

            -- Percentual de apoio para análises e validações
            round(
                safe_divide(
                    countif(media_frequencia_aluno < 75),
                    count(distinct id_aluno)
                ),
                4
            ) as pct_alunos_freq_abaixo_75

        from frequencia_aluno
    ),

    -- Total de alunos cadastrados, independentemente de terem avaliação registrada
    cobertura_alunos as (
        select
            count(distinct id_aluno) as total_alunos
        from {{ ref('stg_educacao__aluno') }}
    ),

    -- Total de escolas cadastradas na base
    cobertura_escolas as (
        select
            count(distinct id_escola) as total_escolas
        from {{ ref('stg_educacao__escola') }}
    )

select
    ca.total_alunos,
    ce.total_escolas,

    -- Indicadores de desempenho
    d.qtd_alunos_com_nota,
    d.soma_medias_alunos,
    round(d.media_nota, 1) as media_nota,
    d.qtd_alunos_media_abaixo_5,
    d.pct_alunos_media_abaixo_5,

    -- Indicadores de frequência
    f.qtd_alunos_com_frequencia,
    f.soma_medias_frequencia_alunos,

    -- Campo em escala 0-1 para uso como percentual no Looker Studio
    round(f.media_frequencia / 100, 4) as media_frequencia,

    f.qtd_alunos_freq_abaixo_75,
    f.pct_alunos_freq_abaixo_75

from desempenho as d
cross join frequencia as f
cross join cobertura_alunos as ca
cross join cobertura_escolas as ce