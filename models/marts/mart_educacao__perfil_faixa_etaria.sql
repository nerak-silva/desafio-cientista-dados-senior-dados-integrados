{{
    config(
        schema="mart_rmi",
        alias="perfil_faixa_etaria",
        materialized="table"
    )
}}

select
    faixa_etaria,
    count(distinct id_aluno) as qtd_alunos,
    round(
        safe_divide(
            count(distinct id_aluno),
            sum(count(distinct id_aluno)) over ()
        ) * 100,
        2
    ) as pct_alunos
from {{ ref('int_educacao__aluno') }}
where faixa_etaria is not null
group by 1