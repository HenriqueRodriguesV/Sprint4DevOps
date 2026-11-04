"""Gera o PDF OFICIAL de entrega da Sprint 4 (DevOps Tools & Cloud Computing).

O enunciado pede "Somente isso no PDF, o resto e no README":
  - nome completo, RM e turma de cada integrante;
  - link do repositorio no GitHub;
  - link do video no YouTube;
  - link do projeto no Azure DevOps.

Uso: pip install reportlab && python docs/entrega/gerar_pdf_entrega.py
Antes de entregar, preencha VIDEO com o link do YouTube (nao listado).
"""

from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import cm
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle

SAIDA = Path(__file__).resolve().parent / "Entrega-Sprint4-DevOps-2TDSA.pdf"

TURMA = "2TDSA"
INTEGRANTES = [
    ("Andre Rosa Colombo", "RM563112"),
    ("Gabriely Bonfim Silva", "RM566242"),
    ("Henrique Rodrigues Vespasiano", "RM562917"),
    ("Mirelly Sousa Alves", "RM566299"),
    ("Ruan Luca Feliciano", "RM562218"),
]
GITHUB = "https://github.com/HenriqueRodriguesV/Sprint4DevOps"
VIDEO = ""  # cole aqui o link do YouTube
AZURE_DEVOPS = "https://dev.azure.com/ollipetnoite/Sprint%204%20%E2%80%93%20Azure%20DevOps"

FONTES = Path("/usr/share/fonts/truetype/dejavu")
try:
    pdfmetrics.registerFont(TTFont("Texto", str(FONTES / "DejaVuSans.ttf")))
    pdfmetrics.registerFont(TTFont("Texto-B", str(FONTES / "DejaVuSans-Bold.ttf")))
    F, FB = "Texto", "Texto-B"
except Exception:
    F, FB = "Helvetica", "Helvetica-Bold"

LARGURA = A4[0] - 4 * cm
titulo = ParagraphStyle("t", fontName=FB, fontSize=20, leading=26, alignment=TA_CENTER)
sub = ParagraphStyle("s", fontName=F, fontSize=11.5, leading=16, alignment=TA_CENTER, textColor=colors.HexColor("#2a6ad1"))
h = ParagraphStyle("h", fontName=FB, fontSize=12.5, leading=17, spaceBefore=16, spaceAfter=6)
cel = ParagraphStyle("c", fontName=F, fontSize=10, leading=13)
celb = ParagraphStyle("cb", parent=cel, fontName=FB)


def tabela(linhas, larguras, cabecalho=True):
    dados = [[Paragraph(str(c), celb if cabecalho and i == 0 else cel) for c in l] for i, l in enumerate(linhas)]
    t = Table(dados, colWidths=larguras)
    estilo = [("GRID", (0, 0), (-1, -1), 0.5, colors.HexColor("#c9ced8")),
              ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
              ("TOPPADDING", (0, 0), (-1, -1), 6), ("BOTTOMPADDING", (0, 0), (-1, -1), 6)]
    if cabecalho:
        estilo.append(("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#eef2f8")))
    t.setStyle(TableStyle(estilo))
    return t


def link(url, texto=None):
    if not url:
        return "<font color='#b00020'>PREENCHER ANTES DE ENTREGAR</font>"
    return f"<link href='{url}' color='#2a6ad1'>{texto or url}</link>"


def main():
    s = [Spacer(1, 1.5 * cm),
         Paragraph("Challenge Clyvo — Olli Pet", titulo), Spacer(1, 6),
         Paragraph("DevOps Tools &amp; Cloud Computing — Entrega da Sprint 4", sub),
         Paragraph("Deploy automatizado com Azure DevOps (CI/CD) e banco de dados em nuvem", sub),
         Paragraph("Integrantes", h),
         tabela([("Nome completo", "RM", "Turma")] + [(n, rm, TURMA) for n, rm in INTEGRANTES],
                [LARGURA * 0.6, LARGURA * 0.22, LARGURA * 0.18]),
         Paragraph("Links", h),
         tabela([("Repositório no GitHub", link(GITHUB)),
                 ("Vídeo no YouTube", link(VIDEO)),
                 ("Projeto no Azure DevOps", link(AZURE_DEVOPS, "https://dev.azure.com/ollipetnoite/Sprint 4 – Azure DevOps"))],
                [LARGURA * 0.32, LARGURA * 0.68], cabecalho=False)]
    SimpleDocTemplate(str(SAIDA), pagesize=A4, leftMargin=2 * cm, rightMargin=2 * cm,
                      title="Entrega Sprint 4 - DevOps - 2TDSA", author="Time Olli Pet").build(s)
    print(f"PDF gerado: {SAIDA}")
    if not VIDEO:
        print("ATENCAO: link do video ainda vazio (VIDEO).")


if __name__ == "__main__":
    main()
