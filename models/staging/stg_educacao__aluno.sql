{{
    config(
        schema="staging_rmi",
        alias="aluno",
        materialized = "table",
    )
}}


select
    to_hex(id_aluno) as id_aluno,
    cast(id_turma as string) as id_turma,
    -- Tratamento preventivo no staging: atualmente nao existe valores nulos ou strings vazias, mas a macro garante padronização caso esse cenário apareça futuramente.    \
    {{ clean_string('faixa_etaria') }} as faixa_etaria, 
    cast(bairro as string) as id_bairro -- renomei para id porque neste contexto é um dado anonimizado
from `desafio-cientista-dados.brutos_rmi.aluno`