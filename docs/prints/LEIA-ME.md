# Prints da entrega (Sprint 4)

Salve cada print **nesta pasta, com exatamente este nome** e rode:

```bash
pip install reportlab pillow
python docs/gerar_pdf.py
```

O script encaixa cada imagem na seção certa de `docs/Sprint4-DevOps-OlliPet.pdf`.
Print que ainda não existe é simplesmente omitido (o PDF já traz as saídas reais
dos comandos). Para conferir o que falta, rode `python docs/gerar_pdf.py --pendencias`:
cada print ausente aparece como uma caixa vermelha com o nome do arquivo.

| Arquivo | O que mostrar |
|---|---|
| `01-devops-projeto.png` | Project Settings > Overview do projeto **Sprint 4 - Azure DevOps** (privado, Git, Scrum) |
| `02-devops-professor.png` | Project Settings > Permissions/Users com o professor convidado |
| `03-devops-boards.png` | Azure Boards com os work items |
| `04-devops-variable-group.png` | Pipelines > Library > `ollipet-cloud` com as 3 variáveis com cadeado |
| `05-devops-service-connection.png` | Project Settings > Service connections > `sc-ollipet-azure` |
| `06-pipeline-disparo.png` | Lista de runs mostrando o run nascido do push (motivo "Individual CI") |
| `07-pipeline-build.png` | Stage **CI - Build, testes e artefato** concluído, com os steps abertos |
| `08-pipeline-testes.png` | Aba **Tests** do run com os testes aprovados |
| `09-pipeline-artefato.png` | Artefato `drop` publicado com o `.jar` |
| `10-pipeline-deploy.png` | Stage **CD - Deploy no Azure Web App** concluído |
| `11-azure-recursos.png` | Portal: Resource Group `rg-ollipet-rm562917` (ou `az resource list -g rg-ollipet-rm562917 -o table`) |
| `12-azure-webapp.png` | Web App `ollipet-api-rm562917` > Deployment Center com o deploy recente |
| `13-api-swagger-nuvem.png` | Swagger aberto em `https://ollipet-api-rm562917.azurewebsites.net/swagger-ui.html` |
| `14-crud-create.png` | POST `/api/v1/pets` (201) + `SELECT` no MySQL com o registro novo |
| `15-crud-read.png` | GET `/api/v1/pets/{id}` (200) |
| `16-crud-update.png` | PUT `/api/v1/pets/{id}` (200) + `SELECT` com o campo alterado |
| `17-crud-delete.png` | DELETE `/api/v1/pets/{id}` (204) + `SELECT` sem o registro |

Para incluir o vídeo, preencha `VIDEO = ""` no topo de `docs/gerar_pdf.py` com o
link do YouTube e gere o PDF de novo.
