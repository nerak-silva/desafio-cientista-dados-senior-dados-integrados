{{
    config(
        schema="staging_rmi",
        alias="frequencia",
        materialized="table"
    )
}}

select
    cast(f.id_escola as string) as id_escola,
    to_hex(f.id_aluno) as id_aluno,
    cast(f.id_turma as string) as id_turma,
    cast(f.data_inicio as date) as data_inicio,
    cast(f.data_fim as date) as data_fim,
    {{ clean_string('f.disciplina') }} as disciplina,
    cast(f.frequencia as float64) as frequencia
from `desafio-cientista-dados.brutos_rmi.frequencia` as f