# Desafio Técnico — Cientista de Dados Sênior

Este repositório contém uma solução para o desafio técnico de Cientista de Dados Sênior RMI.

A solução utiliza `dbt` para modelagem e transformação dos dados, com armazenamento e execução das consultas no BigQuery. Antes da modelagem, realizei uma **análise exploratória em Python no Google Colab**, conectada ao BigQuery, para investigar volume, estrutura, preenchimento, distribuição dos campos e possíveis inconsistências nas fontes. Essa etapa ajudou a orientar as decisões de modelagem, a escolha dos indicadores e a construção dos marts analíticos.

O projeto organiza as transformações nas camadas `staging`, `intermediate` e `marts`. Na camada `staging`, os dados brutos são padronizados, tipados e preparados para uso analítico. Na camada `intermediate`, as fontes são combinadas para formar bases reutilizáveis, como a base de desempenho escolar. Na camada `marts`, são construídas as tabelas finais do projeto, já organizadas para consumo analítico e dashboard.

Para demonstrar o uso desses modelos em um contexto de gestão, desenvolvi um dashboard da educação, mostrando como os dados finais podem ser explorados para:

- identificar escolas e regiões que exigem maior atenção em frequência;
- acompanhar indicadores gerais;
- analisar a relação entre tamanho das turmas, faixa etária e desempenho nas avaliações.

O dashboard pode ser acessado aqui: [Dashboard Educação](https://datastudio.google.com/reporting/0c66300c-b24e-4bac-8268-8bc8f2e4604f)

A solução foi construída para apoiar análises de frequência, desempenho e perfil dos alunos e turmas, transformando os dados brutos em indicadores consolidados e interpretáveis.

Entre os principais temas explorados estão:

- acompanhamento de indicadores gerais de alunos, escolas, desempenho e frequência;
- identificação de escolas e regiões com maior proporção de alunos avaliados com frequência inferior a 75%;
- análise da relação entre características das turmas e desempenho nas avaliações;
- análise complementar do desempenho por faixa etária dos alunos;
- avaliação da cobertura dos registros de avaliação para apoiar a interpretação dos indicadores.

Além dos modelos `dbt`, o projeto inclui testes de qualidade, documentação das decisões de modelagem, análise exploratória em notebook e painel de visualização para monitorar os principais indicadores de frequência, desempenho e cobertura da avaliação.

---

## Como executar o projeto

### Pré-requisitos

- Python instalado;
- dbt instalado;
- adapter do BigQuery configurado;
- acesso ao projeto BigQuery com as tabelas brutas carregadas;
- arquivo `profiles.yml` configurado corretamente.

### Instalação das dependências

```bash
dbt deps
```

### Execução dos modelos

```bash
dbt run
```

### Execução dos testes

```bash
dbt test
```

### Execução completa recomendada

```bash
dbt build
```

---

## Comandos úteis

Executar todos os modelos:

```bash
dbt run
```

Executar todos os testes:

```bash
dbt test
```

Executar modelos e testes:

```bash
dbt build
```
---

## Estrutura do projeto

```text
models/
  staging/
    rmi/
      stg_educacao__aluno.sql
      stg_educacao__escola.sql
      stg_educacao__turma.sql
      stg_educacao__frequencia.sql
      stg_educacao__avaliacao.sql
      _stg_rmi_educacao_schema.yml

  intermediate/
    int_educacao__aluno.sql
    int_educacao__avaliacao_consolidada.sql
    int_educacao__avaliacao_normalizada.sql
    int_educacao__base_desempenho.sql
    _int_rmi_educacao_schema.yml

  marts/
    mart_educacao__visao_geral.sql
    mart_educacao__absenteismo_escola.sql
    mart_educacao__absenteismo_regiao.sql
    mart_educacao__desempenho_perfil_turma.sql
    mart_educacao_desempenho_faixa_tamanho_turma.sql
    mart_educacao__desempenho_faixa_etaria.sql
    mart_educacao__perfil_faixa_etaria.sql
    mart_educacao__desempenho_aluno_bimestre.sql
    mart_educacao__desempenho_bimestre.sql
    mart_educacao__priorizacao_turmas.sql
    schema.yml

macros/
  clean_string.sql

tests/
  test_avaliacao_frequencia_fora_da_faixa.sql
  test_avaliacao_notas_fora_da_faixa.sql
  test_frequencia_fora_da_faixa.sql
  test_frequencia_intervalo_data_invalido.sql
  test_turma_chave_unica.sql

notebooks/
  EDA_ciencia_dados.ipynb

```

A organização segue a arquitetura em camadas:

```text
brutos → staging → intermediate → marts → consumo no dashboard
```

---

## Fontes de dados

Foram utilizadas as seguintes tabelas educacionais anonimizadas:

| Tabela | Descrição |
|---|---|
| `aluno` | Cadastro de alunos, com identificadores anonimizados, faixa etária e bairro |
| `escola` | Cadastro de escolas, com identificador e bairro anonimizados |
| `turma` | Relação entre alunos e turmas |
| `frequencia` | Registros de frequência por disciplina e período |
| `avaliacao` | Notas por disciplina, frequência geral bimestral e bimestre |

---

## Análise exploratória

Antes da construção dos modelos, foi desenvolvida uma análise exploratória em Python no Google Colab, conectada ao BigQuery.

O notebook está disponível em:

```text
notebooks/EDA_ciencia_dados.ipynb
```

A análise exploratória teve como objetivo:

- verificar volume de linhas e estrutura das tabelas;
- entender a granularidade das fontes;
- avaliar preenchimento dos principais campos;
- comparar campos de frequência disponíveis nas tabelas `frequencia` e `avaliacao`;
- identificar inconsistências ou limitações relevantes para a modelagem;
- orientar a construção dos modelos intermediários e marts.

---

## Camada staging

A camada `staging` tem como objetivo padronizar as fontes brutas para uso nas camadas seguintes.

Principais tratamentos aplicados:

- padronização de nomes de colunas;
- conversão de tipos;
- conversão de identificadores para formato textual quando necessário;
- tratamento preventivo de strings vazias e nulos;
- remoção de registros sem identificadores essenciais.

Também foi criada a macro `clean_string`, utilizada para padronizar campos textuais. A macro converte o valor para `string`, remove espaços nas extremidades e transforma strings vazias em `null`.

```sql
{% macro clean_string(column_name) %}
    nullif(trim(cast({{ column_name }} as string)), '')
{% endmacro %}

Modelos principais:

| Modelo | Descrição |
|---|---|
| `stg_educacao__aluno` | Base padronizada de alunos |
| `stg_educacao__escola` | Base padronizada de escolas |
| `stg_educacao__turma` | Relação aluno-turma |
| `stg_educacao__frequencia` | Frequência por disciplina/período |
| `stg_educacao__avaliacao` | Avaliações, notas e frequência bimestral |

---

## Camada intermediate

A camada `intermediate` combina dados de múltiplas fontes e cria bases reutilizáveis para os marts.

### `int_educacao__aluno`

Modelo intermediário com a base de alunos padronizada para uso nas análises de perfil, como distribuição por faixa etária.

### `int_educacao__avaliacao_consolidada`

Modelo que consolida os registros de avaliação por aluno, turma e bimestre, preservando as notas por disciplina e a frequência geral bimestral.

### `int_educacao__avaliacao_normalizada`

Modelo que transforma as colunas de disciplinas (`disciplina_1`, `disciplina_2`, `disciplina_3`, `disciplina_4`) em linhas, criando uma estrutura analítica com os campos `disciplina` e `nota`.

Essa normalização facilita o cálculo de médias, indicadores de desempenho e agregações por disciplina.

### `int_educacao__base_desempenho`

Principal modelo intermediário do projeto. Ele combina avaliação normalizada, aluno, turma, escola e frequência, permitindo análises por:

- aluno;
- turma;
- escola;
- bairro da escola;
- faixa etária;
- bimestre;
- disciplina;
- nota;
- frequência geral bimestral.

A frequência usada nesse modelo vem da tabela `avaliacao`, pois o schema descreve esse campo como o percentual de frequência geral do aluno no bimestre.

---

## Camada marts

A camada `marts` contém os modelos finais utilizados no dashboard e modelos complementares para análises adicionais.

Os marts principais alimentam diretamente o dashboard educacional. Já os marts complementares foram mantidos no projeto porque permitem extrair conclusões adicionais sobre desempenho por bimestre e priorização de turmas, mesmo não sendo todos utilizados diretamente nos gráficos finais.

### Marts usados no dashboard

| Modelo | Uso principal |
|---|---|
| `mart_educacao__visao_geral` | Indicadores executivos dos cards do dashboard |
| `mart_educacao__absenteismo_escola` | Ranking de escolas por percentual de alunos avaliados com frequência inferior a 75% e tabela de apoio |
| `mart_educacao__absenteismo_regiao` | Ranking de bairros/regiões por percentual de alunos avaliados com frequência inferior a 75% |
| `mart_educacao__desempenho_perfil_turma` | Gráfico de dispersão entre tamanho da turma e média de nota |
| `mart_educacao_desempenho_faixa_tamanho_turma` | Média de nota por faixa de tamanho da turma |
| `mart_educacao__desempenho_faixa_etaria` | Média de nota por faixa etária dos alunos avaliados |
| `mart_educacao__perfil_faixa_etaria` | Distribuição de alunos por faixa etária |

### Marts complementares

| Modelo | Uso complementar |
|---|---|
| `mart_educacao__desempenho_aluno_bimestre` | Permite analisar desempenho médio e frequência por aluno, turma e bimestre |
| `mart_educacao__desempenho_bimestre` | Permite avaliar médias de nota e frequência por bimestre e disciplina |
| `mart_educacao__priorizacao_turmas` | Classifica turmas em prioridade alta, média ou baixa com base em desempenho e frequência |

Os modelos complementares não foram usados diretamente no dashboard final para evitar excesso de visualizações, mas foram mantidos por agregarem valor analítico. Eles permitem análises adicionais, como evolução por bimestre, acompanhamento individual por aluno/turma/bimestre e priorização de turmas para acompanhamento pedagógico.

---

## Descrição dos principais marts

### `mart_educacao__visao_geral`

Modelo utilizado para os indicadores executivos do dashboard. Ele materializa a tabela final `visao_geral_cards`, consumida nos cards principais.

Indicadores principais:

- total de alunos;
- total de escolas;
- média geral de nota;
- quantidade de alunos com média inferior a 5;
- frequência média;
- quantidade de alunos com frequência inferior a 75%.

---

### `mart_educacao__absenteismo_escola`

Modelo utilizado para responder:

> Quais escolas possuem maior percentual de alunos avaliados com frequência inferior a 75%?

O modelo calcula, por escola:

- total de alunos da escola;
- quantidade de alunos avaliados;
- cobertura da avaliação;
- quantidade de alunos avaliados com frequência inferior a 75%;
- percentual de alunos avaliados com frequência inferior a 75%;
- frequência média dos alunos avaliados.

A taxa é calculada sobre alunos avaliados, pois a fonte do indicador é a tabela `avaliacao`.

Fórmula:

```text
% alunos avaliados com frequência < 75 =
alunos avaliados com frequência < 75 / alunos avaliados
```

---

### `mart_educacao__absenteismo_regiao`

Modelo utilizado para responder:

> Quais bairros possuem maior percentual de alunos avaliados com frequência inferior a 75%?

O modelo segue a mesma lógica do absenteísmo por escola, agregando os dados pelo bairro da escola.

---

### `mart_educacao__desempenho_perfil_turma`

Modelo utilizado para analisar a relação entre tamanho da turma e desempenho médio.

Indicadores principais:

- identificador anonimizado da turma;
- quantidade de alunos;
- tamanho da turma;
- quantidade de avaliações;
- média de nota da turma;
- frequência média da turma;
- percentual de alunos com nota abaixo de 5;
- percentual de alunos com nota maior ou igual a 7.

Esse modelo alimenta o gráfico de dispersão:

```text
Relação entre tamanho da turma e média de nota
```

---

### `mart_educacao_desempenho_faixa_tamanho_turma`

Modelo utilizado para comparar o desempenho médio por faixa de tamanho da turma.

Faixas utilizadas:

- Até 30 alunos;
- 31 a 40 alunos;
- 41 a 50 alunos;
- 51 a 60 alunos;
- Acima de 60 alunos.

Esse modelo alimenta o gráfico:

```text
Média de nota por faixa de tamanho da turma
```

---

### `mart_educacao__desempenho_faixa_etaria`

Modelo utilizado para analisar desempenho por faixa etária dos alunos avaliados.

Indicadores principais:

- faixa etária;
- quantidade de alunos;
- média de nota;
- quantidade de alunos com nota abaixo de 5;
- percentual de alunos com nota abaixo de 5.

Esse modelo complementa a análise de perfil, considerando uma característica disponível na base de alunos.

---

### `mart_educacao__perfil_faixa_etaria`

Modelo utilizado para visualizar a distribuição dos alunos por faixa etária.

Indicadores principais:

- faixa etária;
- quantidade de alunos;
- percentual de alunos.

---

## Decisões de modelagem

### Uso da frequência da tabela avaliação

O desafio propõe a análise de alunos com frequência inferior a 75%. Durante a exploração dos dados, foram identificadas duas fontes com campos de frequência:

| Fonte | Descrição |
|---|---|
| `frequencia.frequencia` | Frequência por disciplina e período |
| `avaliacao.frequencia` | Frequência geral bimestral do aluno |

A tabela `frequencia` foi avaliada como possível fonte para o indicador de absenteísmo. No entanto, seus valores apresentaram concentração próxima de 100%, o que reduzia a utilidade analítica do corte de 75%.

A tabela `avaliacao`, por outro lado, possui o campo `frequencia` descrito como percentual de frequência geral do aluno no bimestre. Por isso, esse campo foi utilizado para o indicador de frequência inferior a 75%.

### Denominador do indicador de absenteísmo

Como a frequência utilizada vem da tabela `avaliacao`, o indicador representa alunos avaliados, e não necessariamente todos os alunos da escola.

Por isso, o dashboard e os marts deixam explícito:

- total de alunos da escola;
- quantidade de alunos avaliados;
- cobertura da avaliação;
- quantidade de alunos avaliados com frequência inferior a 75%;
- percentual de alunos avaliados com frequência inferior a 75%.

Essa decisão evita interpretar a taxa como se ela representasse todos os alunos da escola quando, na prática, ela representa o subconjunto com avaliação registrada.

### Consolidação do indicador por escola e região

Para evitar distorções causadas por bimestres isolados com poucos registros, o ranking principal foi consolidado no período analisado.

A lógica aplicada foi:

1. calcular a frequência média do aluno na escola ou região;
2. classificar o aluno como abaixo de 75% quando sua frequência média for inferior a 75;
3. calcular a proporção de alunos avaliados abaixo de 75% por escola ou região.

### Análise de desempenho por perfil de turma

A pergunta sugerida no desafio menciona tamanho, série e turno. No entanto, no schema disponibilizado, os campos de série e turno não estavam presentes nas fontes modeladas.

Por isso, a análise de perfil de turma foi concentrada no tamanho da turma, calculado pela quantidade de alunos distintos por `id_turma`.

Como complemento, também foi analisado o desempenho por faixa etária dos alunos.

Essa decisão evita inferir atributos não disponíveis na base.

### Marts complementares

Além dos modelos usados diretamente no dashboard, foram mantidos alguns marts complementares para demonstrar possibilidades adicionais de análise.

O modelo `mart_educacao__priorizacao_turmas`, por exemplo, classifica turmas em prioridade alta, média ou baixa com base em desempenho e frequência. Esse modelo poderia apoiar uma análise de acompanhamento pedagógico, permitindo identificar turmas com baixa média de nota ou maior proporção de alunos com frequência inferior a 75%.

---

## Dashboard

O dashboard foi estruturado em três blocos principais.

### 1. Visão geral

Indicadores executivos:

- total de alunos;
- total de escolas;
- média de nota;
- alunos com média inferior a 5;
- frequência média;
- alunos com frequência inferior a 75%.

### 2. Absenteísmo

Visualizações:

- escolas com maior percentual de alunos avaliados com frequência inferior a 75%;
- bairros/regiões com maior percentual de alunos avaliados com frequência inferior a 75%;
- tabela de apoio com total de alunos, alunos avaliados, cobertura e quantidade abaixo de 75%.

A tabela de apoio foi incluída para contextualizar os rankings, especialmente nos casos em que a escola possui baixa cobertura de avaliação.

### 3. Desempenho

Visualizações:

- relação entre tamanho da turma e média de nota;
- média de nota por faixa de tamanho da turma;
- distribuição de alunos por faixa etária;
- média de nota por faixa etária dos alunos avaliados.

---

## Perguntas analíticas respondidas

### 1. Absenteísmo crônico por região

Pergunta:

```text
Quais escolas/regiões têm maior taxa de alunos com frequência abaixo de 75%?
```

Resposta no projeto:

- a análise foi feita por escola e por bairro/região da escola;
- o indicador considera alunos avaliados com frequência geral bimestral registrada;
- o dashboard mostra os rankings por percentual;
- a tabela de apoio mostra o volume de alunos avaliados e a cobertura da avaliação.

### 2. Desempenho por perfil de turma

Pergunta:

```text
Como a composição das turmas se correlaciona com desempenho nas avaliações?
```

Resposta no projeto:

- a composição da turma foi representada pelo tamanho da turma;
- foram analisadas a relação entre quantidade de alunos e média de nota e a média de nota por faixas de tamanho da turma;
- série e turno não foram analisados por não estarem disponíveis no schema das fontes modeladas;
- como complemento, foi incluída análise de desempenho por faixa etária dos alunos.

---

## Testes de qualidade

Foram aplicados testes genéricos e testes de regra de negócio com o objetivo de validar a confiabilidade dos dados modelados.

### Testes genéricos

Exemplos de testes aplicados:

- `not_null` em chaves essenciais;
- `unique` em identificadores que devem ser únicos;
- `relationships` para validar integridade entre tabelas;
- `accepted_values` para domínios controlados, como bimestre e faixas etárias.

### Testes singulares / regra de negócio

Foram criados testes específicos para validar regras relevantes ao contexto educacional:

| Teste | Objetivo |
|---|---|
| `test_avaliacao_frequencia_fora_da_faixa` | Verifica se a frequência geral bimestral da avaliação está entre 0 e 100 |
| `test_avaliacao_notas_fora_da_faixa` | Verifica se as notas das disciplinas estão dentro da escala esperada de 0 a 10 |
| `test_frequencia_fora_da_faixa` | Verifica se a frequência da tabela de frequência está entre 0 e 100 |
| `test_frequencia_intervalo_data_invalido` | Verifica se `data_fim` não é anterior a `data_inicio` |
| `test_turma_chave_unica` | Verifica duplicidade na relação entre aluno e turma |

A estratégia de testes priorizou colunas e regras que impactam diretamente os indicadores finais do dashboard.

---

## Limitações

- Os dados são anonimizados e aleatorizados, portanto no dashboard, escolas e bairros/regiões receberam nomes fictícios e sequenciais, como `Escola 69` e `Bairro 100`, apenas para facilitar a visualização e a comparação dos indicadores. Esses nomes não representam unidades ou bairros reais.
- O indicador de frequência inferior a 75% usa a frequência geral bimestral da tabela `avaliacao`.
- Como a tabela `avaliacao` não cobre necessariamente todos os alunos da escola, o percentual de absenteísmo foi calculado sobre alunos avaliados.
- Série e turno não estavam disponíveis nas fontes modeladas, limitando a análise de perfil de turma ao tamanho da turma.
- Algumas escolas possuem baixa cobertura de avaliação; por isso, os rankings devem ser interpretados junto à tabela de apoio.

---