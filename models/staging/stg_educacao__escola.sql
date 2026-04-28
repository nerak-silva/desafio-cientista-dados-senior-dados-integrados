{{
    config(
        schema="staging_rmi",
        alias="escola",
        materialized="table"
    )
}}

select
    cast(id_escola as string) as id_escola,
    cast(bairro as string) as id_bairro
from `desafio-cientista-dados.brutos_rmi.escola`