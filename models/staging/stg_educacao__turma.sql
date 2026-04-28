{{
    config(
        schema="staging_rmi",
        alias="turma",
        materialized="table"
    )
}}

select
    cast(ano as int64) as ano,
    cast(id_turma as string) as id_turma,
    to_hex(id_aluno) as id_aluno
from `desafio-cientista-dados.brutos_rmi.turma`