{{
    config(
        schema="mart_rmi",
        alias="desempenho_faixa_etaria",
        materialized="table"
    )
}}

select
    faixa_etaria,

    count(distinct id_aluno) as qtd_alunos,
    count(nota) as qtd_notas_validas,

    round(avg(nota), 2) as media_nota,

    count(distinct case
        when nota < 5 then id_aluno
    end) as qtd_alunos_nota_abaixo_5,

    round(
        safe_divide(
            count(distinct case
                when nota < 5 then id_aluno
            end),
            count(distinct id_aluno)
        ),
        4
    ) as pct_alunos_nota_abaixo_5,

    case
        when faixa_etaria = '0-5' then 1
        when faixa_etaria = '6-10' then 2
        when faixa_etaria = '11-14' then 3
        when faixa_etaria = '15-17' then 4
        when faixa_etaria = '18+' then 5
        else 99
    end as ordem_faixa_etaria

from {{ ref('int_educacao__base_desempenho') }}
where faixa_etaria is not null
  and nota is not null
group by
    faixa_etaria