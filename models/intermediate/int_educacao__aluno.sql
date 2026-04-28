{{
    config(
        schema="intermediate_rmi",
        alias="aluno",
        materialized="table"
    )
}}

select
    id_aluno,
    id_turma,
    faixa_etaria,
    id_bairro
from {{ ref('stg_educacao__aluno') }}
where id_aluno is not null