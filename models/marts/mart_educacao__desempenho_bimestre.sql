{{
    config(
        schema="mart_rmi",
        alias="desempenho_bimestre",
        materialized="table"
    )
}}

-- Qual foi a média de nota e frequência por bimestre e disciplina?
-- Exemplos de uso: evolução da média por bimestre, comparação entre disciplinas, queda ou melhora no desempenho ao longo do ano
select
    bimestre,
    disciplina,
    count(*) as qtd_registros,
    avg(nota) as media_nota,
    min(nota) as menor_nota,
    max(nota) as maior_nota,
    avg(frequencia) as media_frequencia
from {{ ref('int_educacao__avaliacao_normalizada') }}
group by 1, 2