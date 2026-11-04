# Roteiro do vídeo — Sprint 4 (DevOps Tools & Cloud Computing) — Turma 2TDSA

Duração sugerida: 10 a 15 min. Grave em **720p ou mais**, **narrando com a voz** (sem
legenda) e **sem cortes a partir da Cena 3** (alteração → CI/CD → CRUD).
Publique no YouTube como **Não listado** e cole o link no README e no PDF.

## Links que precisam estar abertos (uma aba cada) ANTES de gravar

| Aba | Endereço |
|---|---|
| 1. Projeto no Azure DevOps | https://dev.azure.com/ollipetnoite/Sprint%204%20-%20Azure%20DevOps |
| 2. Pipelines | https://dev.azure.com/ollipetnoite/Sprint%204%20-%20Azure%20DevOps/_build |
| 3. Library (Variable Group) | https://dev.azure.com/ollipetnoite/Sprint%204%20-%20Azure%20DevOps/_library |
| 4. Portal - Resource Group | https://portal.azure.com/#browse/resourcegroups → `rg-ollipet-rm562917` |
| 5. Swagger publicado | https://ollipet-api-rm562917.azurewebsites.net/swagger-ui.html |
| 6. GitHub | https://github.com/HenriqueRodriguesV/Sprint4DevOps |

Além disso: **IDE** (IntelliJ ou VS Code) com o repositório clonado e um **terminal
MySQL** conectado no banco em nuvem (passo abaixo).

### Preparar o terminal MySQL (fazer uma vez, antes de gravar)

1. Libere o IP do seu computador no firewall do MySQL. No Portal:
   `mysql-ollipet-rm562917` → **Networking** → **+ Add current client IP address** → **Save**.
2. Conecte (MySQL Workbench ou terminal):

   ```bash
   mysql -h mysql-ollipet-rm562917.mysql.database.azure.com -u ollipetadmin -p --ssl-mode=REQUIRED ollipet
   ```

   Senha: a mesma da variável secret `DATASOURCE_PASSWORD` (o Henrique tem).
3. Teste com `SELECT id_pet, nome, raca, id_resp FROM pet;` — deve listar Thor, Nina e Bud.

### Ensaiar o login no Swagger (antes de gravar)

No Swagger publicado: `POST /api/v1/auth/login` → **Try it out** →

```json
{ "email": "maria.silva@email.com", "senha": "123456" }
```

Copie o `token`, clique em **Authorize** (cadeado no topo) e cole o token.

---

## Cena 1 — Apresentação e ferramentas (~1 min)

Diga nome, RM e turma (2TDSA). Passe rapidamente por cada aba e diga o que é:
IDE com o projeto, GitHub, Azure DevOps (projeto **Sprint 4 - Azure DevOps**),
Portal da Azure (Resource Group com MySQL, App Service Plan e Web App) e o terminal
MySQL conectado no banco em nuvem.

> *"Esse é o projeto Olli Pet, uma API Spring Boot. Vou mostrar o deploy
> automatizado com Azure DevOps: o código aqui na IDE, o projeto no Azure DevOps,
> os recursos na Azure e o banco MySQL em nuvem que a API usa."*

## Cena 2 — Configuração do projeto e da pipeline (~2 min)

1. **Project Settings → Overview**: projeto privado, Git, Scrum. Mostre em
   **Project Settings → Permissions → Contributors** o professor convidado.
2. **Boards → Work items**: os itens da sprint.
3. **Pipelines → a pipeline → Edit** (mostra o `azure-pipelines.yml`):
   - `trigger: main` → todo push na main dispara;
   - stage **Build**: `Maven@4` (compila + testes JUnit), `PublishPipelineArtifact@1` (artefato);
   - stage **Deploy**: `dependsOn: Build` → só começa com o artefato pronto;
     `AzureWebApp@1` → publica no Web App.
4. **Library → ollipet-cloud**: as 3 variáveis do banco com **cadeado (secret)**.

> *"As credenciais do banco ficam aqui no Variable Group, como secret. Não aparecem
> no código nem nos logs."*

## Cena 3 — Alterar o código e fazer push (~1 min) — A PARTIR DAQUI, SEM CORTES

No IDE, abra `src/main/resources/application.properties` e altere a linha:

```properties
springdoc.info.version=v4.0.0 - Sprint 4
```

para

```properties
springdoc.info.version=v4.1.0 - Video Sprint 4
```

No terminal da IDE:

```bash
git add src/main/resources/application.properties
git commit -m "Atualiza versao da API para o video da Sprint 4"
git push origin main
```

> *"Mudei a versão que aparece no topo do Swagger. Commit e push na main."*

## Cena 4 — Disparo automático e execução do CI/CD (~4-6 min)

Volte em **Pipelines**: um run novo aparece sozinho (motivo **Individual CI**,
com a mensagem do seu commit). **Não clique em Run manual.**

- Abra o run → stage **CI - Build, testes e artefato** → abra cada step e explique:
  checkout, `mvn clean package` compilando e rodando os testes, cópia do `.jar`,
  publicação do artefato.
- Aba **Tests** do run: os 30 testes aprovados.
- Quando o Build terminar, mostre o stage **CD - Deploy no Azure Web App**
  começando sozinho e o step `Aplicar App Settings e publicar o .jar`.

> *"O Deploy começou sozinho porque depende do artefato do Build. Esse step está
> publicando o jar no Web App."*

## Cena 5 — Artefato e recursos no Portal (~1 min)

- No run: **1 published** → artefato `drop` → o `.jar`.
- No Portal: `ollipet-api-rm562917` → **Deployment Center** → o deploy que acabou
  de acontecer (horário de agora).

## Cena 6 — Alteração no ar + CRUD com SELECT no banco (~4-5 min)

1. Atualize o **Swagger publicado**: o topo mostra **v4.1.0 - Video Sprint 4**
   (prova de que o deploy automático funcionou).
2. Faça o login (`POST /api/v1/auth/login`) e o **Authorize**.
3. CRUD, sempre com o `SELECT` no terminal MySQL logo depois:

| Passo | No Swagger | No MySQL |
|---|---|---|
| **Create** | `POST /api/v1/pets` com o JSON abaixo → **201** | `SELECT id_pet, nome, raca, id_resp FROM pet ORDER BY id_pet DESC LIMIT 1;` |
| **Read** | `GET /api/v1/pets/{id}` → **200** | (mesmo SELECT) |
| **Update** | `PUT /api/v1/pets/{id}` com o JSON abaixo → **200** | `SELECT id_pet, nome, descricao FROM pet WHERE id_pet = {id};` |
| **Delete** | `DELETE /api/v1/pets/{id}` → **204** | `SELECT COUNT(*) FROM pet WHERE id_pet = {id};` → **0** |

Create:

```json
{ "nome": "Bolinha", "descricao": "Vira-lata resgatado, muito brincalhao", "raca": "Vira-lata", "especie": "CAO", "dataNascimento": "2024-02-10" }
```

Update:

```json
{ "nome": "Bolinha Castrado", "descricao": "Castrado em 11/2026", "raca": "Vira-lata", "especie": "CAO", "dataNascimento": "2024-02-10" }
```

## Cena 7 — Encerramento (~30 s)

> *"Recapitulando: alteramos o código, o push disparou o CI sozinho, os testes
> rodaram, o artefato foi publicado, o deploy no Web App aconteceu automaticamente
> e o CRUD está gravando no MySQL da Azure."*

---

## Checklist antes de publicar o vídeo

- [ ] 720p ou mais, narração com voz, sem legenda
- [ ] Sem cortes da Cena 3 em diante
- [ ] Run nasceu do push (Individual CI), não manual
- [ ] Mostrou e explicou cada etapa do Build e do Deploy
- [ ] Mostrou os testes (aba Tests) e o artefato `drop`
- [ ] Mostrou o Web App atualizado no Portal
- [ ] Mostrou a versão nova no Swagger publicado
- [ ] CRUD completo com SELECT depois de cada operação
- [ ] YouTube "Não listado"; link colado no README e no PDF
