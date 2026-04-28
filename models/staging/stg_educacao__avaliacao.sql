{{
    config(
        schema="staging_rmi",
        alias="avaliacao",
        materialized="table"
    )
}}

select
    to_hex(id_aluno) as id_aluno,
    cast(id_turma as string) as id_turma,
    cast(frequencia as float64) as frequencia,
    {{ clean_string('bimestre') }} as bimestre,
    -- existem registros com valores ponto flutuante com muitas casas decimais ex: 5.1099999999999994
    round(cast(disciplina_1 as numeric), 2) as disciplina_1,
    round(cast(disciplina_2 as numeric), 2) as disciplina_2,
    round(cast(disciplina_3 as numeric), 2) as disciplina_3,
    round(cast(disciplina_4 as numeric), 2) as disciplina_4
from `desafio-cientista-dados.brutos_rmi.avaliacao`