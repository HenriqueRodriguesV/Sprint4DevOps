"""Gera docs/Sprint4-DevOps-OlliPet.pdf (documentacao da entrega da Sprint 4).

Uso (na raiz do repositorio):
    pip install reportlab
    python docs/gerar_pdf.py

Os prints ficam em docs/prints/ com os nomes listados em PRINTS (ver
docs/prints/LEIA-ME.md). Cada print que existir e encaixado na sua secao; um
print que ainda nao existir aparece como uma caixa "PRINT PENDENTE" com o nome
do arquivo esperado, para que nada seja esquecido antes da entrega.
"""

import sys
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import cm
from reportlab.lib.utils import ImageReader
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    Image,
    KeepTogether,
    PageBreak,
    Paragraph,
    Preformatted,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

RAIZ = Path(__file__).resolve().parent.parent
PRINTS_DIR = RAIZ / "docs" / "prints"
SAIDA = RAIZ / "docs" / "Sprint4-DevOps-OlliPet.pdf"
DIAGRAMA = RAIZ / "docs" / "azure" / "arquitetura-cicd-vertical.png"

# ---------------------------------------------------------------------------
# Dados da entrega - ajuste aqui antes de gerar
# ---------------------------------------------------------------------------
TURMA = "2TDSA"
EQUIPE = [
    ("Andre Rosa Colombo", "RM563112"),
    ("Gabriely Bonfim Silva", "RM566242"),
    ("Henrique Rodrigues Vespasiano", "RM562917"),
    ("Mirelly Sousa Alves", "RM566299"),
    ("Ruan Luca Feliciano", "RM562218"),
]
REPOSITORIO = "https://github.com/HenriqueRodriguesV/Sprint4DevOps"
API_URL = "https://ollipet-api-rm562917.azurewebsites.net/swagger-ui.html"
VIDEO = ""  # cole aqui o link do YouTube (nao listado) e gere o PDF de novo

# Com "--pendencias", prints ainda nao salvos aparecem como caixas vermelhas;
# sem a opcao (padrao), o PDF sai limpo, so com o que ja existe.
MOSTRAR_PENDENCIAS = "--pendencias" in sys.argv
PROJETO_DEVOPS = "dev.azure.com/ollipetnoite - Sprint 4 – Azure DevOps (privado, Git, Scrum)"

# Arquivo esperado em docs/prints/ -> legenda
PRINTS = {
    "01-devops-projeto.png": "Projeto 'Sprint 4 – Azure DevOps' (Project Settings > Overview: privado, Git, Scrum).",
    "02-devops-professor.png": "Professor convidado no projeto (Project Settings > Permissions / Users).",
    "03-devops-boards.png": "Azure Boards com os work items da sprint.",
    "04-devops-variable-group.png": "Variable Group 'ollipet-cloud' com as variaveis do banco marcadas como secret (cadeado).",
    "05-devops-service-connection.png": "Service Connection 'sc-ollipet-azure' (Azure Resource Manager).",
    "06-pipeline-disparo.png": "Run disparado automaticamente pelo push na master (trigger: 'Individual CI').",
    "07-pipeline-build.png": "Stage 'CI - Build, testes e artefato' concluido, com os steps do Maven.",
    "08-pipeline-testes.png": "Aba 'Tests' do run com os testes JUnit aprovados.",
    "09-pipeline-artefato.png": "Artefato 'drop' publicado, com o .jar da API.",
    "10-pipeline-deploy.png": "Stage 'CD - Deploy no Azure Web App' concluido automaticamente apos o Build.",
    "11-azure-recursos.png": "Resource Group 'rg-ollipet-rm562917' no Portal (ou saida de 'az resource list').",
    "12-azure-webapp.png": "Web App 'ollipet-api-rm562917' com o deploy recente (Deployment Center).",
    "13-api-swagger-nuvem.png": "Swagger da API publicada no endereco azurewebsites.net.",
    "14-crud-create.png": "CREATE - POST /api/v1/pets (201) + SELECT no MySQL mostrando o registro novo.",
    "15-crud-read.png": "READ - GET /api/v1/pets/{id} (200) batendo com o banco.",
    "16-crud-update.png": "UPDATE - PUT /api/v1/pets/{id} (200) + SELECT mostrando o campo alterado.",
    "17-crud-delete.png": "DELETE - DELETE /api/v1/pets/{id} (204) + SELECT mostrando que o registro sumiu.",
}

# ---------------------------------------------------------------------------
# Estilos (mesma identidade visual do PDF da Sprint 3)
# ---------------------------------------------------------------------------
FONTES = Path("/usr/share/fonts/truetype/dejavu")
try:
    pdfmetrics.registerFont(TTFont("Texto", str(FONTES / "DejaVuSans.ttf")))
    pdfmetrics.registerFont(TTFont("Texto-B", str(FONTES / "DejaVuSans-Bold.ttf")))
    pdfmetrics.registerFont(TTFont("Mono", str(FONTES / "DejaVuSansMono.ttf")))
    F, FB, FM = "Texto", "Texto-B", "Mono"
except Exception:  # fonte DejaVu ausente (ex.: Windows): usa as embutidas
    F, FB, FM = "Helvetica", "Helvetica-Bold", "Courier"

AZUL = colors.HexColor("#1f3b6f")
LINK = colors.HexColor("#2a6ad1")
CINZA = colors.HexColor("#555555")
FUNDO_CODIGO = colors.HexColor("#1e2235")

titulo = ParagraphStyle("titulo", fontName=FB, fontSize=24, leading=30, alignment=TA_CENTER, textColor=colors.HexColor("#111827"))
subtitulo = ParagraphStyle("sub", fontName=F, fontSize=14, leading=18, textColor=colors.HexColor("#111827"))
subtitulo2 = ParagraphStyle("sub2", fontName=F, fontSize=11, leading=15, textColor=LINK)
h1 = ParagraphStyle("h1", fontName=FB, fontSize=15, leading=20, spaceBefore=12, spaceAfter=6, textColor=colors.HexColor("#111827"))
h2 = ParagraphStyle("h2", fontName=FB, fontSize=11.5, leading=15, spaceBefore=8, spaceAfter=4, textColor=AZUL)
corpo = ParagraphStyle("corpo", fontName=F, fontSize=9.6, leading=13.5, spaceAfter=5)
item = ParagraphStyle("item", parent=corpo, leftIndent=14, bulletIndent=4)
legenda = ParagraphStyle("legenda", fontName=F, fontSize=8.4, leading=11, textColor=CINZA, alignment=TA_CENTER, spaceAfter=8)
celula = ParagraphStyle("celula", fontName=F, fontSize=8.4, leading=11)
celula_b = ParagraphStyle("celula_b", parent=celula, fontName=FB)
codigo = ParagraphStyle("codigo", fontName=FM, fontSize=7.8, leading=10.2, textColor=colors.HexColor("#e6e6e6"))

LARGURA = A4[0] - 4 * cm


def p(texto, estilo=corpo):
    return Paragraph(texto, estilo)


def check(texto):
    return Paragraph("<font color='#1a7f37'>&#10004;</font> " + texto, item)


def bloco_codigo(texto):
    t = Table([[Preformatted(texto.strip("\n"), codigo)]], colWidths=[LARGURA])
    t.setStyle(TableStyle([
        ("BACKGROUND", (0, 0), (-1, -1), FUNDO_CODIGO),
        ("LEFTPADDING", (0, 0), (-1, -1), 12),
        ("RIGHTPADDING", (0, 0), (-1, -1), 12),
        ("TOPPADDING", (0, 0), (-1, -1), 8),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 8),
    ]))
    return t


def tabela(linhas, larguras, cabecalho=True):
    dados = [[Paragraph(str(c), celula_b if (cabecalho and i == 0) else celula) for c in linha]
             for i, linha in enumerate(linhas)]
    t = Table(dados, colWidths=larguras, repeatRows=1 if cabecalho else 0)
    estilo = [
        ("GRID", (0, 0), (-1, -1), 0.4, colors.HexColor("#d0d4dc")),
        ("VALIGN", (0, 0), (-1, -1), "TOP"),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
    ]
    if cabecalho:
        estilo.append(("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#eef2f8")))
    t.setStyle(TableStyle(estilo))
    return t


def imagem(caminho, largura_max=LARGURA, altura_max=17 * cm):
    w, h = ImageReader(str(caminho)).getSize()
    escala = min(largura_max / w, altura_max / h)
    return Image(str(caminho), width=w * escala, height=h * escala)


def texto_evidencia(nome):
    """Saida real de comando salva em docs/prints/evidencias/<nome>, um bloco por paragrafo."""
    caminho = PRINTS_DIR / "evidencias" / nome
    if not caminho.exists():
        return []
    blocos = []
    for trecho in caminho.read_text(encoding="utf-8").split("\n\n"):
        if trecho.strip():
            blocos.append(KeepTogether([bloco_codigo(trecho), Spacer(1, 6)]))
    return blocos


def evidencia(nome):
    """Encaixa docs/prints/<nome> ou desenha a caixa de print pendente."""
    caminho = PRINTS_DIR / nome
    texto = PRINTS[nome]
    if caminho.exists():
        return KeepTogether([imagem(caminho, altura_max=12 * cm), p(texto, legenda)])
    if not MOSTRAR_PENDENCIAS:
        return Spacer(1, 0)
    caixa = Table([[Paragraph(
        f"<b>PRINT PENDENTE</b><br/>{texto}<br/><font name='{FM}' size='8'>salvar como docs/prints/{nome}</font>",
        ParagraphStyle("pend", parent=celula, alignment=TA_CENTER, textColor=colors.HexColor("#9c2b2b")))]],
        colWidths=[LARGURA], rowHeights=[2.6 * cm])
    caixa.setStyle(TableStyle([
        ("BOX", (0, 0), (-1, -1), 1, colors.HexColor("#c0504d")),
        ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#fdf1f0")),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
    ]))
    return KeepTogether([caixa, Spacer(1, 8)])


def rodape(canvas, doc):
    canvas.saveState()
    canvas.setFont(F, 7.5)
    canvas.setFillColor(CINZA)
    canvas.drawString(2 * cm, 1.2 * cm, f"Olli Pet API - DevOps Tools & Cloud Computing - Sprint 4 - Turma {TURMA}")
    canvas.drawRightString(A4[0] - 2 * cm, 1.2 * cm, f"pagina {doc.page}")
    canvas.restoreState()


# ---------------------------------------------------------------------------
# Conteudo
# ---------------------------------------------------------------------------
def montar():
    s = []

    # Capa ------------------------------------------------------------------
    s += [Spacer(1, 1.2 * cm), p("Challenge Clyvo — Olli Pet", titulo), Spacer(1, 10),
          p("Apresentação do Trabalho", subtitulo),
          p("DevOps Tools &amp; Cloud Computing — Sprint 4: Deploy automatizado com Azure DevOps", subtitulo2),
          Spacer(1, 14)]
    s.append(p(f"<b>Turma {TURMA}</b> — Time Olli Pet"))
    s.append(tabela([("Integrante", "RM")] + EQUIPE, [LARGURA * 0.7, LARGURA * 0.3]))
    s.append(Spacer(1, 12))
    s.append(p("Este documento apresenta o que foi entregue na Sprint 4: a arquitetura com o fluxo de CI/CD, "
               "a configuração do projeto no Azure DevOps, a pipeline de build, testes e deploy, o banco de "
               "dados em nuvem e as evidências (prints e saídas de comando) de que a aplicação foi publicada "
               "automaticamente e persiste os dados no MySQL da Azure."))
    s.append(Spacer(1, 6))
    s.append(tabela([
        ("Repositório GitHub", f"<link href='{REPOSITORIO}' color='#2a6ad1'>{REPOSITORIO}</link>"),
        ("API em produção (Azure)", f"<link href='{API_URL}' color='#2a6ad1'>{API_URL}</link>"),
        ("Projeto Azure DevOps", PROJETO_DEVOPS),
        ("Pipeline", "azure-pipelines.yml — CI (Build + testes + artefato) e CD (deploy) automáticos"),
        ("Banco de dados", "Azure Database for MySQL Flexible Server 8.0.21 - Mexico Central (schema ollipet)"),
    ] + ([("Vídeo de apresentação", f"<link href='{VIDEO}' color='#2a6ad1'>{VIDEO}</link>")] if VIDEO else []) + [
    ], [LARGURA * 0.32, LARGURA * 0.68], cabecalho=False))
    s.append(PageBreak())

    # 1 ---------------------------------------------------------------------
    s.append(p("1. Descrição da solução", h1))
    s.append(p("A Olli Pet é uma clínica veterinária que resolvia agendamento, vacinação, triagem de urgência "
               "e acompanhamento de tratamento por WhatsApp e planilhas. A API em Spring Boot é o backend do "
               "aplicativo mobile da clínica e concentra quatro regras de negócio:"))
    for t in ["<b>Triagem por questionário</b> — classifica a urgência do pet a partir das respostas do tutor.",
              "<b>Agendamento de consulta</b> — controla a agenda dos veterinários e impede choque de horário.",
              "<b>Carteira de vacinação</b> — calcula sozinha o número da dose e a próxima aplicação.",
              "<b>Tratamento em casa</b> — transforma a prescrição em doses que o tutor confirma uma a uma."]:
        s.append(Paragraph(t, item, bulletText="•"))
    s.append(p("Benefícios para o negócio", h2))
    s.append(p("A agenda deixa de depender da recepção conferir conflitos; a triagem funciona a qualquer hora; "
               "a clínica enxerga quem está com vacina atrasada antes de o tutor aparecer; e o veterinário passa "
               "a ver o percentual real de doses confirmadas. Com a Sprint 4, cada mudança no código chega à "
               "produção sozinha, testada, em minutos — sem deploy manual e sem risco de publicar uma versão "
               "que não compila ou quebra os testes."))

    # 2 ---------------------------------------------------------------------
    s.append(p("2. Como cada requisito foi atendido", h1))
    for t in [
        "<b>Projeto no Azure DevOps</b> \"Sprint 4 – Azure DevOps\": privado, Git, processo Scrum, professor convidado — seção 5.",
        "<b>Pipeline de CI</b> disparada a cada push na <font name='%s'>master</font>: build com Maven, testes automatizados JUnit publicados e artefato .jar publicado — seção 6." % FM,
        "<b>Pipeline de CD</b> disparada automaticamente após o artefato (dependsOn: Build), com deploy no Azure Web App — seção 6.",
        "<b>Credenciais protegidas</b>: usuário, senha e URL do banco em Variable Group com variáveis secret, nunca no código — seção 5.",
        "<b>Banco de dados em nuvem</b> (não H2): Azure Database for MySQL Flexible Server — seção 4.",
        "<b>DDL comentado</b> em arquivo separado: <font name='%s'>script_bd.sql</font>, validado em MySQL 8 — seção 4." % FM,
        "<b>Recursos criados via Azure CLI</b>: <font name='%s'>docs/azure/provisionar.sh</font> — seção 7." % FM,
        "<b>CRUD completo</b> na tabela <font name='%s'>pet</font> (relacionada a <font name='%s'>responsavel</font>) com SELECT no banco após cada operação — seção 8." % (FM, FM),
        "<b>Desenho da arquitetura e do fluxo CI/CD</b> e detalhamento dos componentes — seção 3.",
        "<b>Código-fonte no GitHub</b> com README de execução e deploy — seção 9.",
    ]:
        s.append(check(t))
    s.append(PageBreak())

    # 3 ---------------------------------------------------------------------
    s.append(p("3. Arquitetura e fluxo CI/CD", h1))
    s.append(imagem(DIAGRAMA, altura_max=13 * cm))
    s.append(p("Fluxo: push na master → CI (Maven: build + testes) → artefato .jar → CD automático → Azure Web App → MySQL em nuvem.", legenda))
    for t in ["<b>1.</b> O desenvolvedor faz <i>git push</i> na branch master do GitHub.",
              "<b>2.</b> O push dispara a pipeline no Azure DevOps (trigger em master).",
              "<b>3.</b> CI: <i>mvn clean package</i> compila e roda os testes JUnit; os resultados vão para a aba Tests.",
              "<b>4.</b> O .jar é publicado como artefato <i>drop</i>.",
              "<b>5.</b> CD: o stage Deploy começa sozinho quando o artefato existe.",
              "<b>6.</b> A task AzureWebApp@1 aplica as App Settings (secrets do Variable Group) e publica o .jar.",
              "<b>7.</b> No boot, a API conecta no MySQL via JDBC/SSL e o Flyway aplica as migrations V1..V8."]:
        s.append(p(t, item))
    s.append(p("Detalhamento dos componentes", h2))
    s.append(tabela([
        ("Componente", "Nome do recurso", "Tipo", "Descrição funcional", "Tecnologia"),
        ("Repositório", "Sprint4DevOps", "Repositório Git", "Código, pipeline e scripts", "GitHub"),
        ("Projeto DevOps", "Sprint 4 – Azure DevOps", "Projeto privado (Git, Scrum)", "Boards, Pipelines, Library", "Azure DevOps"),
        ("Pipeline", "azure-pipelines.yml", "YAML multi-stage", "CI (build/testes/artefato) e CD (deploy)", "Azure Pipelines"),
        ("Variable Group", "ollipet-cloud", "Library (secret)", "URL, usuário e senha do banco", "Azure Pipelines"),
        ("Service Connection", "sc-ollipet-azure", "Azure Resource Manager", "Permite à pipeline publicar na Azure", "Azure DevOps"),
        ("Resource Group", "rg-ollipet-rm562917", "Grupo de recursos", "Agrupa os recursos da solução", "Azure"),
        ("App Service Plan", "plan-ollipet-rm562917", "Linux B1", "Capacidade do Web App", "Azure App Service"),
        ("Web App", "ollipet-api-rm562917", "Web App Linux Java 21", "Executa a API (perfil cloud)", "Azure App Service"),
        ("Banco de dados", "mysql-ollipet-rm562917", "MySQL Flexible Server 8.0.21 B1ms (Mexico Central)", "Persistência relacional (schema ollipet)", "MySQL + Flyway"),
    ], [LARGURA * w for w in (0.16, 0.22, 0.2, 0.25, 0.17)]))
    s.append(PageBreak())

    # 4 ---------------------------------------------------------------------
    s.append(p("4. Banco de dados em nuvem", h1))
    s.append(p("Localmente a API usa H2 em arquivo; na nuvem o perfil Spring <b>cloud</b> "
               "(<font name='%s'>application-cloud.properties</font>) troca para o <b>Azure Database for MySQL "
               "Flexible Server</b>. O schema é criado exclusivamente pelo Flyway (<i>ddl-auto=validate</i>) e o "
               "módulo <i>flyway-mysql</i> foi adicionado ao pom.xml." % FM))
    s.append(bloco_codigo("""
# src/main/resources/application-cloud.properties
spring.datasource.url=${DATABASE_URL}
spring.datasource.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.username=${DATASOURCE_USERNAME}
spring.datasource.password=${DATASOURCE_PASSWORD}
spring.jpa.database-platform=org.hibernate.dialect.MySQLDialect
spring.flyway.enabled=true
"""))
    s.append(Spacer(1, 6))
    s.append(p("Validação das migrations em MySQL 8", h2))
    s.append(p("Antes de subir para a nuvem, as oito migrations foram aplicadas em um MySQL 8.0 limpo, na mesma "
               "ordem que o Flyway usa. Todas executaram sem erro e criaram as 18 tabelas do core com a carga inicial:"))
    s.append(bloco_codigo("""
$ for f in V1 V2 V3 V4 V5 V6 V7 V8; do mysql ollipet < ${f}__*.sql; done
V1__criar_schema_base.sql                OK
V2__criar_agendamento_consulta.sql       OK
V3__criar_carteira_vacinacao.sql         OK
V4__inserir_dados_iniciais.sql           OK
V5__criar_triagem.sql                    OK
V6__inserir_protocolos_triagem.sql       OK
V7__criar_tratamento.sql                 OK
V8__criar_administrador.sql              OK

mysql> SELECT id_pet, nome, raca, id_resp FROM pet;
+--------+------+------------------+---------+
| id_pet | nome | raca             | id_resp |
+--------+------+------------------+---------+
|      1 | Thor | Golden Retriever |       3 |
|      2 | Nina | Siames           |       3 |
|      3 | Bud  | Poodle           |       4 |
+--------+------+------------------+---------+
"""))
    s.append(p("O mesmo conteúdo, comentado, está em <font name='%s'>script_bd.sql</font> na raiz do repositório "
               "(tabelas: usuario, responsavel, med_vet, administrador, pet, consulta, prontuario, vacina, "
               "aplicacao_vacina, queixa, pergunta_triagem, opcao_resposta, orientacao_triagem, triagem, "
               "resposta_triagem, observacao_triagem, tratamento, dose_tratamento)." % FM))
    s.append(PageBreak())

    # 4.1 validacao local ----------------------------------------------------
    local = PRINTS_DIR / "local"
    s.append(p("4.1 Validação local antes do deploy (perfil cloud + MySQL 8)", h1))
    s.append(p("Antes de publicar, o mesmo build da pipeline foi executado e a API foi iniciada com o perfil "
               "<b>cloud</b> apontando para um MySQL 8.0: o Flyway aplicou as migrations V1..V8 e o Hibernate "
               "validou o schema (<i>ddl-auto=validate</i>) sem divergências."))
    if (local / "testes-local.txt").exists():
        s.append(p("Testes automatizados (mvn clean package) — 30 testes, 0 falhas", h2))
        s.append(bloco_codigo((local / "testes-local.txt").read_text(encoding="utf-8")))
    s.append(bloco_codigo("""
Flyway: Database: jdbc:mysql://localhost:3306/ollipet (MySQL 8.0)
Flyway: Successfully applied 8 migrations to schema `ollipet`, now at version v8
Started ChallengeClyvoApplication in 7.706 seconds
"""))
    if (local / "swagger-local.png").exists():
        s.append(Spacer(1, 6))
        s.append(imagem(local / "swagger-local.png", altura_max=9 * cm))
        s.append(p("Swagger da API rodando com o perfil cloud (MySQL).", legenda))
    if (local / "crud-local.txt").exists():
        s.append(PageBreak())
        s.append(p("CRUD completo com SELECT no MySQL após cada operação", h2))
        for trecho in (local / "crud-local.txt").read_text(encoding="utf-8").split("\n\n"):
            if trecho.strip():
                s.append(KeepTogether([bloco_codigo(trecho), Spacer(1, 6)]))
    s.append(PageBreak())

    # 5 ---------------------------------------------------------------------
    s.append(p("5. Projeto no Azure DevOps", h1))
    s.append(p("Projeto <b>Sprint 4 – Azure DevOps</b> na organização <b>ollipetnoite</b>, privado, com controle "
               "de versão Git e processo Scrum. O professor <b>Felipe Oliveira</b> (pf2128@fiap.com.br) foi "
               "convidado como <b>Contributor</b> do projeto, com nível de acesso <b>Basic</b>. URL, usuário e "
               "senha do banco ficam no Variable Group <b>ollipet-cloud</b> (Pipelines → Library), marcados como "
               "secret: a pipeline os injeta no Web App como App Settings no deploy, e eles não aparecem no "
               "código, no YAML nem nos logs. A Service Connection <b>sc-ollipet-azure</b> usa Workload Identity "
               "Federation (sem senha armazenada) e só tem permissão de Contributor no Resource Group do projeto."))
    s.append(p("Configuração do projeto (item 4 do enunciado)", h2))
    s.append(tabela([
        ("Campo", "Valor"),
        ("Project Name", "Sprint 4 – Azure DevOps"),
        ("Description", "Projeto para entrega da Sprint 4 do professor Felipe Cavalcante Vilella de Oliveira<br/>"
                        "Integrantes do grupo:<br/>"
                        "RM563112 - Andre Rosa Colombo - 2TDSA<br/>"
                        "RM566242 - Gabriely Bonfim Silva - 2TDSA<br/>"
                        "RM562917 - Henrique Rodrigues Vespasiano - 2TDSA<br/>"
                        "RM566299 - Mirelly Sousa Alves - 2TDSA<br/>"
                        "RM562218 - Ruan Luca Feliciano - 2TDSA"),
        ("Visibility", "Private"),
        ("Version control", "Git"),
        ("Work item process", "Scrum"),
    ], [LARGURA * 0.28, LARGURA * 0.72]))
    s.append(Spacer(1, 8))
    s += texto_evidencia("devops-config.txt")
    s += [evidencia("01-devops-projeto.png"), evidencia("02-devops-professor.png"), evidencia("03-devops-boards.png"),
          evidencia("04-devops-variable-group.png"), evidencia("05-devops-service-connection.png")]
    s.append(PageBreak())

    # 6 ---------------------------------------------------------------------
    s.append(p("6. Pipeline CI/CD", h1))
    s.append(bloco_codigo("""
trigger:
  branches:
    include: [ master, main ]  # todo push na master dispara a pipeline

stages:
  - stage: Build               # CI
    jobs:
      - job: BuildAndTest
        steps:
          - task: Maven@4                    # mvn clean package = build + testes JUnit
            inputs: { goals: 'clean package', publishJUnitResults: true }
          - task: CopyFiles@2                # copia o .jar
          - task: PublishPipelineArtifact@1  # publica o artefato "drop"

  - stage: Deploy              # CD
    dependsOn: Build           # so comeca quando o artefato existe
    jobs:
      - deployment: DeployWebApp
        environment: producao-ollipet
        strategy: { runOnce: { deploy: { steps:
          - task: AzureWebApp@1              # App Settings (secrets) + deploy do .jar
        } } }
"""))
    s.append(p("Arquivo completo: <font name='%s'>azure-pipelines.yml</font> na raiz do repositório." % FM, legenda))
    s.append(p("Execução disparada pelo push (motivo individualCI)", h2))
    s.append(p("O run abaixo nasceu sozinho de um <i>git push</i>: o CI compilou, rodou e publicou os 30 "
               "testes, publicou o artefato <i>drop</i>, e o CD começou automaticamente em seguida e publicou o .jar "
               "no Web App."))
    s += texto_evidencia("pipeline-run.txt")
    s += [evidencia("06-pipeline-disparo.png"), evidencia("07-pipeline-build.png"),
          evidencia("08-pipeline-testes.png"), evidencia("09-pipeline-artefato.png"),
          evidencia("10-pipeline-deploy.png")]
    s.append(PageBreak())

    # 7 ---------------------------------------------------------------------
    s.append(p("7. Recursos na Azure (criados via Azure CLI)", h1))
    s.append(p("Todos os recursos foram criados pelo script <font name='%s'>docs/azure/provisionar.sh</font> (Azure CLI), "
               "na região <b>Mexico Central</b> — a assinatura Azure for Students só libera cinco regiões e o MySQL "
               "Flexible B1ms só tem SKU disponível em Mexico Central e Chile Central." % FM))
    s.append(bloco_codigo("""
$ export MYSQL_ADMIN_PASSWORD='********'
$ bash docs/azure/provisionar.sh
>> 1/5 Resource Group: rg-ollipet-rm562917 (mexicocentral)
>> 2/5 Azure Database for MySQL Flexible Server: mysql-ollipet-rm562917
>> 3/5 Firewall do MySQL
>> 4/5 App Service Plan (Linux): plan-ollipet-rm562917
>> 5/5 Web App (Java 21): ollipet-api-rm562917
"""))
    s.append(Spacer(1, 6))
    s += texto_evidencia("azure-recursos.txt")
    s += [evidencia("11-azure-recursos.png"), evidencia("12-azure-webapp.png"), evidencia("13-api-swagger-nuvem.png")]
    s.append(PageBreak())

    # 8 ---------------------------------------------------------------------
    s.append(p("8. CRUD completo no ambiente publicado", h1))
    s.append(p("O CRUD foi executado na API publicada (https://ollipet-api-rm562917.azurewebsites.net) sobre a "
               "tabela <b>pet</b>, relacionada a <b>responsavel</b> pela chave estrangeira <i>pet.id_resp</i>. A "
               "listagem traz os pets da carga inicial (Thor, Nina), criados pelo Flyway no MySQL da Azure, junto "
               "com o registro novo — os dados vêm do banco em nuvem."))
    s += texto_evidencia("crud-nuvem.txt")
    s.append(p("Conferência com SELECT direto no MySQL da Azure", h2))
    s.append(p("Após cada operação, o SELECT abaixo é executado no banco em nuvem (mostrado também no vídeo):"))
    s.append(bloco_codigo("""
-- depois do CREATE e do READ
SELECT id_pet, nome, raca, id_resp FROM pet ORDER BY id_pet DESC LIMIT 1;
-- depois do UPDATE
SELECT id_pet, nome, descricao FROM pet WHERE id_pet = {id};
-- depois do DELETE (0 = registro removido)
SELECT COUNT(*) FROM pet WHERE id_pet = {id};
"""))
    s += [evidencia("14-crud-create.png"), evidencia("15-crud-read.png"),
          evidencia("16-crud-update.png"), evidencia("17-crud-delete.png")]

    # 9 ---------------------------------------------------------------------
    s.append(p("9. Código no GitHub", h1))
    s.append(p(f"Repositório público com o código da API, a pipeline, os scripts de provisionamento, o DDL e o README "
               f"com o passo a passo de execução e deploy: <link href='{REPOSITORIO}' color='#2a6ad1'>{REPOSITORIO}</link>"))
    s.append(p("10. Vídeo de demonstração", h1))
    s.append(p((f"<link href='{VIDEO}' color='#2a6ad1'>{VIDEO}</link> — " if VIDEO else "")
               + "O vídeo mostra a alteração no código, o push, o disparo automático do CI/CD com cada etapa "
               "explicada, o artefato, o deploy no Portal e o CRUD com SELECT no banco após cada operação."))
    return s


def main():
    doc = SimpleDocTemplate(str(SAIDA), pagesize=A4, leftMargin=2 * cm, rightMargin=2 * cm,
                            topMargin=1.8 * cm, bottomMargin=1.8 * cm,
                            title="Olli Pet - DevOps Sprint 4 - 2TDSA", author="Time Olli Pet")
    doc.build(montar(), onFirstPage=rodape, onLaterPages=rodape)
    faltando = [n for n in PRINTS if not (PRINTS_DIR / n).exists()]
    print(f"PDF gerado: {SAIDA}")
    if faltando:
        print(f"{len(faltando)} print(s) pendente(s) em docs/prints/:")
        for n in faltando:
            print("  -", n)


if __name__ == "__main__":
    main()
