{{
    config(
        schema="mart_rmi",
        alias="desempenho_aluno_bimestre",
        materialized="table"
    )
}}

-- Qual foi o desempenho médio de cada aluno em cada bimestre?
-- Exemplos de uso: acompanhar aluno ao longo dos bimestres, identificar alunos com baixo desempenho individual
select
    id_aluno,
    id_turma,
    bimestre,
    avg(nota) as media_nota,
    count(*) as qtd_disciplinas_avaliadas,
    max(frequencia) as frequencia
from {{ ref('int_educacao__avaliacao_normalizada') }}
group by 1, 2, 3

