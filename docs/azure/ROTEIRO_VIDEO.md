# Roteiro do vídeo — Sprint 4 (DevOps Tools & Cloud Computing) — Turma 2TDSA

Cada cena segue o **"Fluxo do vídeo"** do enunciado, na mesma ordem. Em cada uma:
**Mostrar** = o que fica na tela (onde clicar); **Falar** = texto pronto para ler.
A coluna "Enunciado" indica o item avaliado e o desconto se faltar.

Regras do enunciado para o vídeo: **720p ou mais, áudio claro, sem legenda,
explicação por voz**, ferramentas abertas e prontas antes de gravar.
**Não corte do início da Cena 4 até o fim da Cena 8** (alteração → CI/CD → CRUD).

Abas abertas antes de gravar (nesta ordem): IDE com o projeto · Azure DevOps (projeto)
· Pipelines · Library · Portal (Resource Group) · Swagger · MySQL Workbench conectado ·
GitHub · README (seção 2, diagrama).

---

## Cena 1 — Apresentação e ferramentas (~1 min)

| | |
|---|---|
| **Enunciado** | "Mostre as ferramentas usadas (IDE, Azure DevOps, Banco de Dados, Portal do Azure etc.)" |
| **Mostrar** | Passe por cada aba, parando 3 a 5 segundos em cada: IDE → GitHub → Azure DevOps → Portal → MySQL Workbench → Swagger |

**Falar:**
> "Olá, somos do time Olli Pet, turma 2TDSA. Eu sou [nome], RM [número]. Este é o
> vídeo da Sprint 4 de DevOps Tools and Cloud Computing. Vou mostrar as ferramentas
> que usamos: aqui no [IntelliJ/VS Code] está o código da nossa API em Java com Spring
> Boot; aqui o repositório no GitHub, na branch master; aqui o Azure DevOps, onde
> ficam o projeto, o Boards e a pipeline de CI/CD; aqui o Portal do Azure com os
> recursos: o Web App onde a API roda e o banco Azure Database for MySQL; aqui o MySQL
> Workbench conectado nesse banco em nuvem; e aqui o Swagger da API publicada na Azure."

## Cena 2 — Solução, arquitetura e banco (~1,5 min)

| | |
|---|---|
| **Enunciado** | "É obrigatório a explicação pelo aluno sobre os itens a serem entregues": 1. Descrição da solução (-10), 2. Diagrama (até 20 pts), 3. Banco em nuvem (-40 se não permitido) |
| **Mostrar** | README no GitHub: seção **1. Descrição da solução** → seção **2. Arquitetura e fluxo CI/CD** (diagrama) → seção **3. Banco de dados em nuvem** |

**Falar:**
> "A Olli Pet é uma API REST para uma clínica veterinária: triagem de urgência por
> questionário, agendamento de consultas, carteira de vacinação e acompanhamento de
> tratamento. A stack é Java 21, Spring Boot, Spring Security, JPA, Flyway e Maven.
>
> Neste diagrama está a arquitetura e o fluxo de CI/CD, numerado: [aponte cada
> número] 1, o desenvolvedor faz push na master do GitHub; 2, isso dispara a pipeline
> no Azure DevOps; 3 e 4, o CI compila, roda os testes e publica o artefato; 5, o
> artefato dispara o CD; 6, o CD faz o deploy no Azure Web App; 7, a API conecta no
> banco MySQL da Azure. As credenciais vêm do Variable Group protegido. E o usuário
> final acessa a API pelo Swagger ou pelo aplicativo.
>
> O banco de dados é em nuvem: Azure Database for MySQL Flexible Server, um serviço
> PaaS. O schema é criado pelo Flyway, com as migrations versionadas no projeto."

## Cena 3 — Projeto no Azure DevOps e configuração da pipeline (~2 min)

| | |
|---|---|
| **Enunciado** | 4. Configuração do projeto (zero se não configurar) · 5. Professor com acesso Basic (zero sem acesso) · "Apresente a configuração da pipeline (cada jobs/tasks)" · IV. Variáveis protegidas (-15) |
| **Mostrar** | 1) **Project settings** (engrenagem no canto inferior esquerdo) → Overview: nome, descrição, Private, Git, Scrum · 2) **Project settings → Permissions → Contributors → Members**: o professor · 3) **Boards → Work items** · 4) **Pipelines** → a pipeline → **Edit**: role o YAML de cima a baixo · 5) **Pipelines → Library → ollipet-cloud**: as 3 variáveis com cadeado |

**Falar:**
> "Este é o projeto no Azure DevOps: o nome é 'Sprint 4 – Azure DevOps', a descrição
> tem o nome do professor e os integrantes com RM e turma, a visibilidade é privada,
> o versionamento é Git e o processo é Scrum. Em Permissions, o professor Felipe
> está como membro do projeto com acesso Basic. Aqui no Boards estão os itens da
> sprint.
>
> Agora a pipeline, feita em YAML. O trigger é a branch master: qualquer alteração
> nela dispara a pipeline sozinha. Ela tem dois stages. O primeiro é o CI: a task
> Maven roda o 'mvn clean package', que compila o projeto e executa os testes
> automatizados, e publica o resultado dos testes; a task CopyFiles copia o jar
> gerado; e a PublishPipelineArtifact publica esse jar como artefato no Azure DevOps.
> O segundo stage é o CD: ele tem 'dependsOn Build', então só começa quando o
> artefato existe; ele baixa o artefato e a task AzureWebApp faz o deploy no Web
> App, aplicando as configurações do banco.
>
> Os dados sensíveis, que são a URL, o usuário e a senha do banco, ficam aqui na
> Library, no Variable Group 'ollipet-cloud', todos com o cadeado, ou seja, como
> secret. Eles não aparecem no código nem nos logs."

## Cena 4 — Alterar o código e fazer push (~1 min) — A PARTIR DAQUI, SEM CORTES

| | |
|---|---|
| **Enunciado** | "Altere algo no código... fácil de visualizar" · Alteração em README ao invés de código: -20 |
| **Mostrar** | Primeiro o **Swagger** com o grupo **Pets** dizendo "Cadastro de pets". Depois, na IDE, abra `src/main/java/org/fiap/challenge_clyvo/controller/PetController.java`, linha 29 |

Troque:

```java
@Tag(name = "Pets", description = "Cadastro de pets")
```

por:

```java
@Tag(name = "Pets", description = "Cadastro de pets - alterado ao vivo na Sprint 4")
```

No terminal da IDE:

```bash
git add src/main/java/org/fiap/challenge_clyvo/controller/PetController.java
git commit -m "Altera descricao do cadastro de pets"
git push origin master
```

**Falar:**
> "Hoje, no Swagger publicado, o grupo Pets mostra a descrição 'Cadastro de pets'.
> Vou alterar isso no código Java, aqui no PetController, para 'Cadastro de pets -
> alterado ao vivo na Sprint 4'. Agora faço o commit e o push na branch master."

## Cena 5 — Disparo automático e explicação do CI/CD durante a execução (~4-6 min)

| | |
|---|---|
| **Enunciado** | "Mostre o início automático da pipeline após o commit" (-30 se não disparar) · "Explique cada etapa do CI/CD durante a execução — abra os detalhes" (-20) |
| **Mostrar** | Aba **Pipelines**: o run novo aparece sozinho (não clique em Run). Abra o run → clique no stage **CI - Build, testes e artefato** → clique em cada step conforme ele roda. Quando o CI acabar, volte e abra o stage **CD - Deploy no Azure Web App** |

**Falar (vá falando enquanto roda):**
> "Olha aqui: assim que eu fiz o push, a pipeline começou sozinha. O motivo aparece
> como 'Individual CI' e a mensagem é o meu commit. Vou abrir os detalhes.
>
> No stage de CI: o 'Initialize job' prepara o agente; o 'Checkout' baixa o código
> da master do GitHub; agora o 'mvn clean package' está compilando e — aqui nos logs
> — rodando os testes automatizados; o 'Copiar o jar' separa o arquivo gerado; e o
> 'Publicar artefato' envia o jar para o Azure DevOps.
>
> O CI terminou e repare que o CD começou sozinho, porque ele depende do artefato.
> No CD: o 'Download Artifact' baixa o jar publicado pelo CI, e o 'Aplicar App
> Settings e publicar o .jar' faz o deploy no Azure Web App, usando as credenciais
> protegidas do Variable Group."

## Cena 6 — Artefato e resultados dos testes (~1 min)

| | |
|---|---|
| **Enunciado** | "Mostre o artefato criado e os resultados dos testes" · sem artefato: -20 · sem testes: -20 |
| **Mostrar** | No resumo do run: aba **Tests** (30 aprovados) → volte ao resumo e clique em **1 published** → abra o artefato **drop** e mostre o `.jar` |

**Falar:**
> "Aqui na aba Tests estão os resultados: 30 testes automatizados, todos aprovados.
> E aqui o artefato publicado pelo CI, chamado 'drop', com o jar da aplicação."

## Cena 7 — Recursos atualizados no Portal do Azure (~1 min)

| | |
|---|---|
| **Enunciado** | "Demonstre no Portal do Azure os recursos atualizados pelo deploy" (-10) · Deploy em Web App (-30 se não) |
| **Mostrar** | Portal → Resource Group **rg-ollipet-rm562917** (os 3 recursos) → clique em **ollipet-api-rm562917** → menu **Deployment Center** → aba **Logs**: o deploy de agora |

**Falar:**
> "No Portal do Azure, este é o Resource Group do projeto, com o Web App, o App
> Service Plan e o banco MySQL. No Web App, em Deployment Center, aparece o deploy
> que acabou de ser feito pela pipeline, com o horário de agora."

## Cena 8 — Aplicação com a alteração + CRUD com SELECT no banco (~4-5 min)

| | |
|---|---|
| **Enunciado** | "Não demonstrar a execução do App com a alteração": -30 · "Acesse a aplicação no Web App e execute o CRUD completo, mostrando no banco cada operação" · evidência por SELECT: -30 se faltar |
| **Mostrar** | Recarregue o **Swagger** (F5) e mostre o grupo Pets com o texto novo. Depois deixe o Swagger e o MySQL Workbench lado a lado (ou alterne) |

1. **Login:** `POST /api/v1/auth/login` → **Try it out** →
   `{ "email": "maria.silva@email.com", "senha": "123456" }` → **Execute** → copie o
   `token` → botão **Authorize** (topo) → cole → **Authorize** → **Close**.
2. **CRUD**, sempre com o SELECT logo depois:

| Operação | No Swagger | SELECT no Workbench |
|---|---|---|
| Inserir | `POST /api/v1/pets` com o JSON abaixo → **201** (anote o `id`) | `SELECT id_pet, nome, raca, id_resp FROM pet ORDER BY id_pet DESC LIMIT 1;` |
| Consultar | `GET /api/v1/pets/{id}` → **200** | o mesmo SELECT |
| Atualizar | `PUT /api/v1/pets/{id}` com o JSON abaixo → **200** | `SELECT id_pet, nome, descricao FROM pet WHERE id_pet = {id};` |
| Deletar | `DELETE /api/v1/pets/{id}` → **204** | `SELECT COUNT(*) FROM pet WHERE id_pet = {id};` (resultado 0) |

Inserir:

```json
{ "nome": "Bolinha", "descricao": "Vira-lata resgatado", "raca": "Vira-lata", "especie": "CAO", "dataNascimento": "2024-02-10" }
```

Atualizar:

```json
{ "nome": "Bolinha Castrado", "descricao": "Castrado em 11/2026", "raca": "Vira-lata", "especie": "CAO", "dataNascimento": "2024-02-10" }
```

**Falar:**
> "Recarregando o Swagger da aplicação publicada na Azure, o grupo Pets já mostra o
> texto novo: a alteração no código chegou em produção sozinha, pela pipeline.
>
> Agora o CRUD completo na tabela pet, que se relaciona com a tabela de responsável
> pela coluna id_resp. Primeiro faço o login e autorizo o token.
> Inserir: crio o pet Bolinha, retornou 201 com o id [x]. No banco, o SELECT mostra o
> registro novo, ligado à responsável 3.
> Consultar: o GET do id [x] retorna os mesmos dados que estão no banco.
> Atualizar: mudo o nome para Bolinha Castrado, retornou 200, e o SELECT mostra o
> nome e a descrição alterados.
> Deletar: o DELETE retornou 204, e o SELECT confirma que o registro não existe mais."

## Cena 9 — Encerramento (~30 s)

**Falar:**
> "Resumindo: alteramos o código, o push na master disparou o CI sozinho, os testes
> rodaram e o artefato foi publicado, o CD fez o deploy automático no Azure Web App,
> e a aplicação com a alteração está gravando no MySQL em nuvem. Obrigado!"

---

## Checklist final (descontos do enunciado)

- [ ] 720p+, voz clara, sem legenda (-30)
- [ ] Explicou descrição, diagrama e banco (Cena 2)
- [ ] Mostrou projeto, professor Basic, pipeline (cada task) e Library com cadeado (Cena 3)
- [ ] Alteração em **código Java**, não README (-20)
- [ ] Pipeline disparou sozinha pelo push na master (-30)
- [ ] Explicou cada etapa do CI e do CD durante a execução (-20)
- [ ] Mostrou testes e artefato (-20 cada)
- [ ] Mostrou os recursos no Portal (-10)
- [ ] Mostrou a alteração rodando na aplicação (-30)
- [ ] CRUD completo com SELECT após cada operação (-30)
- [ ] YouTube **Não listado** e link enviado para o PDF de entrega
