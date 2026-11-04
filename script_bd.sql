-- =============================================================================
-- Olli Pet API - Script do banco de dados (MySQL 8 / Azure Database for MySQL)
-- DevOps Tools & Cloud Computing - Sprint 4 - Turma 2TDSA
-- =============================================================================
-- Este arquivo reune, em ordem, as migrations do Flyway que a aplicacao aplica
-- sozinha no boot (src/main/resources/db/migration/V1..V8). Ele existe para
-- consulta e para criar o banco manualmente, se necessario:
--
--   mysql -h mysql-ollipet-rm562917.mysql.database.azure.com -u ollipetadmin -p \
--         --ssl-mode=REQUIRED ollipet < script_bd.sql
--
-- Em uso normal NAO rode este script: o Flyway cria tudo e registra as versoes
-- na tabela flyway_schema_history. Rodar os dois duplicaria as tabelas.
--
-- Tabelas do CORE do negocio:
--   usuario / responsavel / med_vet / administrador  -> pessoas (heranca JOINED)
--   pet                                              -> animais (FK id_resp)
--   consulta / prontuario                            -> agendamento e atendimento
--   vacina / aplicacao_vacina                        -> carteira de vacinacao
--   queixa / pergunta_triagem / opcao_resposta /
--   orientacao_triagem / triagem / resposta_triagem /
--   observacao_triagem                               -> triagem por questionario
--   tratamento / dose_tratamento                     -> tratamento em casa
-- =============================================================================

-- -----------------------------------------------------------------------------
-- V1__criar_schema_base.sql
-- Base: usuarios (tutor, veterinario), pets e prontuario. Usuario e a tabela-mae;
-- responsavel e med_vet guardam so os campos especificos (heranca JOINED).
-- -----------------------------------------------------------------------------
CREATE TABLE usuario (
    id_usuario   BIGINT AUTO_INCREMENT PRIMARY KEY,
    tipo         VARCHAR(20)  NOT NULL,
    nome         VARCHAR(100) NOT NULL,
    email        VARCHAR(120) NOT NULL,
    cpf          VARCHAR(11)  NOT NULL,
    senha        VARCHAR(100),
    firebase_uid VARCHAR(128),
    ativo        BOOLEAN      NOT NULL DEFAULT TRUE,
    criado_em    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uk_usuario_email UNIQUE (email),
    CONSTRAINT uk_usuario_cpf UNIQUE (cpf),
    CONSTRAINT uk_usuario_firebase_uid UNIQUE (firebase_uid)
);

CREATE TABLE responsavel (
    id_usuario BIGINT PRIMARY KEY,
    data_nasc  DATE,
    CONSTRAINT fk_responsavel_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);

CREATE TABLE med_vet (
    id_usuario    BIGINT      PRIMARY KEY,
    crmv          VARCHAR(20) NOT NULL,
    especialidade VARCHAR(80),
    CONSTRAINT fk_med_vet_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario),
    CONSTRAINT uk_med_vet_crmv UNIQUE (crmv)
);

CREATE TABLE pet (
    id_pet    BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome      VARCHAR(80) NOT NULL,
    descricao VARCHAR(255),
    raca      VARCHAR(80) NOT NULL,
    especie   VARCHAR(20) NOT NULL,
    data_nasc DATE        NOT NULL,
    id_resp   BIGINT      NOT NULL,
    CONSTRAINT fk_pet_responsavel FOREIGN KEY (id_resp) REFERENCES responsavel (id_usuario)
);

CREATE INDEX idx_pet_responsavel ON pet (id_resp);

CREATE TABLE prontuario (
    id_prontuario     BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_pet            BIGINT       NOT NULL,
    id_med_vet        BIGINT       NOT NULL,
    procedimento      VARCHAR(255) NOT NULL,
    data_procedimento DATE         NOT NULL,
    local_atendimento VARCHAR(120) NOT NULL,
    CONSTRAINT fk_prontuario_pet FOREIGN KEY (id_pet) REFERENCES pet (id_pet),
    CONSTRAINT fk_prontuario_med_vet FOREIGN KEY (id_med_vet) REFERENCES med_vet (id_usuario)
);

CREATE INDEX idx_prontuario_pet ON prontuario (id_pet);


-- -----------------------------------------------------------------------------
-- V2__criar_agendamento_consulta.sql
-- Agenda: cada consulta liga pet + veterinario; o prontuario passa a apontar
-- para a consulta que o originou (1 consulta -> no maximo 1 prontuario).
-- -----------------------------------------------------------------------------
CREATE TABLE consulta (
    id_consulta   BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_pet        BIGINT       NOT NULL,
    id_med_vet    BIGINT       NOT NULL,
    data_hora     TIMESTAMP    NOT NULL,
    motivo        VARCHAR(255) NOT NULL,
    status        VARCHAR(20)  NOT NULL,
    observacoes   VARCHAR(500),
    criado_em     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    atualizado_em TIMESTAMP,
    CONSTRAINT fk_consulta_pet FOREIGN KEY (id_pet) REFERENCES pet (id_pet),
    CONSTRAINT fk_consulta_med_vet FOREIGN KEY (id_med_vet) REFERENCES med_vet (id_usuario)
);

CREATE INDEX idx_consulta_agenda ON consulta (id_med_vet, data_hora);
CREATE INDEX idx_consulta_pet ON consulta (id_pet);
CREATE INDEX idx_consulta_status ON consulta (status);

ALTER TABLE prontuario ADD COLUMN id_consulta BIGINT;

ALTER TABLE prontuario
    ADD CONSTRAINT fk_prontuario_consulta FOREIGN KEY (id_consulta) REFERENCES consulta (id_consulta);

ALTER TABLE prontuario ADD CONSTRAINT uk_prontuario_consulta UNIQUE (id_consulta);


-- -----------------------------------------------------------------------------
-- V3__criar_carteira_vacinacao.sql
-- Vacinacao: catalogo de vacinas com protocolo e as doses aplicadas em cada pet.
-- -----------------------------------------------------------------------------
CREATE TABLE vacina (
    id_vacina       BIGINT AUTO_INCREMENT PRIMARY KEY,
    nome            VARCHAR(80) NOT NULL,
    especie         VARCHAR(20) NOT NULL,
    doses_protocolo INT         NOT NULL,
    intervalo_dias  INT         NOT NULL,
    meses_reforco   INT,
    CONSTRAINT uk_vacina_nome_especie UNIQUE (nome, especie)
);

CREATE TABLE aplicacao_vacina (
    id_aplicacao   BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_pet         BIGINT      NOT NULL,
    id_vacina      BIGINT      NOT NULL,
    id_med_vet     BIGINT      NOT NULL,
    numero_dose    INT         NOT NULL,
    data_aplicacao DATE        NOT NULL,
    proxima_dose   DATE,
    lote           VARCHAR(40),
    CONSTRAINT fk_aplicacao_pet FOREIGN KEY (id_pet) REFERENCES pet (id_pet),
    CONSTRAINT fk_aplicacao_vacina FOREIGN KEY (id_vacina) REFERENCES vacina (id_vacina),
    CONSTRAINT fk_aplicacao_med_vet FOREIGN KEY (id_med_vet) REFERENCES med_vet (id_usuario),
    CONSTRAINT uk_aplicacao_dose UNIQUE (id_pet, id_vacina, numero_dose)
);

CREATE INDEX idx_aplicacao_pet ON aplicacao_vacina (id_pet);
CREATE INDEX idx_aplicacao_proxima_dose ON aplicacao_vacina (proxima_dose);


-- -----------------------------------------------------------------------------
-- V4__inserir_dados_iniciais.sql
-- Carga inicial: 2 veterinarios, 2 tutores, 3 pets e o catalogo de vacinas.
-- -----------------------------------------------------------------------------
-- Senha de todos os usuarios de demonstracao: 123456 (BCrypt)
INSERT INTO usuario (tipo, nome, email, cpf, senha) VALUES
    ('VETERINARIO', 'Dra. Camila Duarte', 'camila.duarte@ollipet.com', '98765432100', '$2a$10$zztCBVlHLsW6w.9BUUtAsurw7KlpNhZ19Ld9yYpZtzDVptGkGXRpe'),
    ('VETERINARIO', 'Dr. Rafael Nunes',   'rafael.nunes@ollipet.com',  '45678912311', '$2a$10$zztCBVlHLsW6w.9BUUtAsurw7KlpNhZ19Ld9yYpZtzDVptGkGXRpe'),
    ('RESPONSAVEL', 'Maria Silva',        'maria.silva@email.com',     '12345678901', '$2a$10$zztCBVlHLsW6w.9BUUtAsurw7KlpNhZ19Ld9yYpZtzDVptGkGXRpe'),
    ('RESPONSAVEL', 'Joao Pereira',       'joao.pereira@email.com',    '32165498700', '$2a$10$zztCBVlHLsW6w.9BUUtAsurw7KlpNhZ19Ld9yYpZtzDVptGkGXRpe');

INSERT INTO med_vet (id_usuario, crmv, especialidade)
SELECT id_usuario, 'SP-12345', 'Clinica Geral' FROM usuario WHERE email = 'camila.duarte@ollipet.com';
INSERT INTO med_vet (id_usuario, crmv, especialidade)
SELECT id_usuario, 'SP-54321', 'Dermatologia' FROM usuario WHERE email = 'rafael.nunes@ollipet.com';

INSERT INTO responsavel (id_usuario, data_nasc)
SELECT id_usuario, DATE '1995-08-10' FROM usuario WHERE email = 'maria.silva@email.com';
INSERT INTO responsavel (id_usuario, data_nasc)
SELECT id_usuario, DATE '1988-02-27' FROM usuario WHERE email = 'joao.pereira@email.com';

INSERT INTO pet (nome, descricao, raca, especie, data_nasc, id_resp)
SELECT 'Thor', 'Cachorro docil, castrado', 'Golden Retriever', 'CAO', DATE '2021-03-15', id_usuario
FROM usuario WHERE email = 'maria.silva@email.com';
INSERT INTO pet (nome, descricao, raca, especie, data_nasc, id_resp)
SELECT 'Nina', 'Gata arisca com estranhos', 'Siames', 'GATO', DATE '2022-07-01', id_usuario
FROM usuario WHERE email = 'maria.silva@email.com';
INSERT INTO pet (nome, descricao, raca, especie, data_nasc, id_resp)
SELECT 'Bud', 'Idoso, acompanhamento cardiaco', 'Poodle', 'CAO', DATE '2019-11-20', id_usuario
FROM usuario WHERE email = 'joao.pereira@email.com';

-- Protocolo: doses_protocolo = quantidade da serie inicial, intervalo_dias = espera entre elas,
-- meses_reforco = periodicidade do reforco depois da serie concluida.
INSERT INTO vacina (nome, especie, doses_protocolo, intervalo_dias, meses_reforco) VALUES
    ('V10',              'CAO',  3, 21, 12),
    ('Antirrabica',      'CAO',  1,  0, 12),
    ('Giardia',          'CAO',  2, 21, 12),
    ('Gripe Canina',     'CAO',  2, 21, 12),
    ('V4',               'GATO', 3, 21, 12),
    ('Antirrabica',      'GATO', 1,  0, 12),
    ('Leucemia Felina',  'GATO', 2, 21, 12);


-- -----------------------------------------------------------------------------
-- V5__criar_triagem.sql
-- Triagem: queixas, perguntas e opcoes (ids fixos) e as triagens respondidas.
-- -----------------------------------------------------------------------------
CREATE TABLE queixa (
    id_queixa            BIGINT       PRIMARY KEY,
    nome                 VARCHAR(80)  NOT NULL,
    descricao            VARCHAR(255) NOT NULL,
    categoria            VARCHAR(30)  NOT NULL,
    especie              VARCHAR(20),
    limite_urgente       INT          NOT NULL,
    limite_pouco_urgente INT          NOT NULL,
    ordem                INT          NOT NULL,
    CONSTRAINT uk_queixa_nome UNIQUE (nome)
);

-- As perguntas e opcoes tem id fixo, definido no protocolo clinico e nao gerado pelo
-- banco: o aplicativo monta as telas em cima desses numeros.
CREATE TABLE pergunta_triagem (
    id_pergunta          BIGINT       PRIMARY KEY,
    id_queixa            BIGINT       NOT NULL,
    texto                VARCHAR(255) NOT NULL,
    ordem                INT          NOT NULL,
    obrigatoria          BOOLEAN      NOT NULL DEFAULT TRUE,
    id_opcao_dependencia BIGINT,
    CONSTRAINT fk_pergunta_queixa FOREIGN KEY (id_queixa) REFERENCES queixa (id_queixa)
);

CREATE TABLE opcao_resposta (
    id_opcao     BIGINT       PRIMARY KEY,
    id_pergunta  BIGINT       NOT NULL,
    texto        VARCHAR(120) NOT NULL,
    peso         INT          NOT NULL DEFAULT 0,
    sinal_alerta BOOLEAN      NOT NULL DEFAULT FALSE,
    marcador     VARCHAR(40),
    ordem        INT          NOT NULL,
    CONSTRAINT fk_opcao_pergunta FOREIGN KEY (id_pergunta) REFERENCES pergunta_triagem (id_pergunta)
);

-- A dependencia entre pergunta e opcao so pode ser criada depois das duas tabelas.
ALTER TABLE pergunta_triagem
    ADD CONSTRAINT fk_pergunta_dependencia
    FOREIGN KEY (id_opcao_dependencia) REFERENCES opcao_resposta (id_opcao);

CREATE TABLE orientacao_triagem (
    id_orientacao BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_queixa     BIGINT       NOT NULL,
    classificacao VARCHAR(20)  NOT NULL,
    texto         VARCHAR(255) NOT NULL,
    ordem         INT          NOT NULL,
    CONSTRAINT fk_orientacao_queixa FOREIGN KEY (id_queixa) REFERENCES queixa (id_queixa)
);

CREATE INDEX idx_orientacao_queixa ON orientacao_triagem (id_queixa, classificacao);

CREATE TABLE triagem (
    id_triagem    BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_pet        BIGINT      NOT NULL,
    id_queixa     BIGINT      NOT NULL,
    pontuacao     INT         NOT NULL,
    classificacao VARCHAR(20) NOT NULL,
    acao_sugerida VARCHAR(20) NOT NULL,
    status        VARCHAR(20) NOT NULL,
    criado_em     TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expira_em     TIMESTAMP   NOT NULL,
    id_consulta   BIGINT,
    CONSTRAINT fk_triagem_pet FOREIGN KEY (id_pet) REFERENCES pet (id_pet),
    CONSTRAINT fk_triagem_queixa FOREIGN KEY (id_queixa) REFERENCES queixa (id_queixa),
    CONSTRAINT fk_triagem_consulta FOREIGN KEY (id_consulta) REFERENCES consulta (id_consulta),
    CONSTRAINT uk_triagem_consulta UNIQUE (id_consulta)
);

CREATE INDEX idx_triagem_pet ON triagem (id_pet);
CREATE INDEX idx_triagem_fila ON triagem (classificacao, status);

CREATE TABLE resposta_triagem (
    id_resposta BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_triagem  BIGINT NOT NULL,
    id_pergunta BIGINT NOT NULL,
    id_opcao    BIGINT NOT NULL,
    CONSTRAINT fk_resposta_triagem FOREIGN KEY (id_triagem) REFERENCES triagem (id_triagem),
    CONSTRAINT fk_resposta_pergunta FOREIGN KEY (id_pergunta) REFERENCES pergunta_triagem (id_pergunta),
    CONSTRAINT fk_resposta_opcao FOREIGN KEY (id_opcao) REFERENCES opcao_resposta (id_opcao),
    CONSTRAINT uk_resposta_pergunta UNIQUE (id_triagem, id_pergunta)
);

-- Observacoes que a API deduz cruzando a triagem com o cadastro do pet
-- (idade, vacinacao em atraso). Ficam gravadas porque dependem do estado do
-- pet no momento da triagem e nao poderiam ser recalculadas depois.
CREATE TABLE observacao_triagem (
    id_observacao BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_triagem    BIGINT       NOT NULL,
    texto         VARCHAR(255) NOT NULL,
    CONSTRAINT fk_observacao_triagem FOREIGN KEY (id_triagem) REFERENCES triagem (id_triagem)
);


-- -----------------------------------------------------------------------------
-- V6__inserir_protocolos_triagem.sql
-- Carga dos 4 protocolos clinicos de triagem (27 perguntas).
-- -----------------------------------------------------------------------------
-- Protocolos de triagem. Conteudo documentado em docs/protocolos-triagem.md.
-- especie NULL significa que a queixa vale para cao e gato.
INSERT INTO queixa (id_queixa, nome, descricao, categoria, especie, limite_urgente, limite_pouco_urgente, ordem) VALUES
    (1, 'Vomito ou diarreia',  'Enjoo, vomito, fezes moles ou liquidas.',              'GASTROINTESTINAL', NULL, 12, 6, 1),
    (2, 'Pele e coceira',      'Coceira, vermelhidao, feridas ou queda de pelo.',      'DERMATOLOGICO',    NULL, 12, 5, 2),
    (3, 'Nao esta comendo',    'Perda de apetite ou recusa de alimento.',              'ALIMENTAR',        NULL, 11, 5, 3),
    (4, 'Respiracao e tosse',  'Tosse, espirro, cansaco ou dificuldade para respirar.','RESPIRATORIO',     NULL,  9, 4, 4);

-- ---------------------------------------------------------------------------
-- Queixa 1 - Vomito ou diarreia
-- ---------------------------------------------------------------------------
INSERT INTO pergunta_triagem (id_pergunta, id_queixa, texto, ordem, obrigatoria) VALUES
    (101, 1, 'Ha quanto tempo comecou?',                                            1, TRUE),
    (102, 1, 'Quantos episodios nas ultimas 24 horas?',                             2, TRUE),
    (103, 1, 'Tem sangue no vomito ou nas fezes?',                                  3, TRUE),
    (104, 1, 'Esta conseguindo beber agua?',                                        4, TRUE),
    (105, 1, 'Esta tentando vomitar sem sair nada, com a barriga inchada e dura?',  5, TRUE),
    (106, 1, 'Como esta o animo?',                                                  6, TRUE),
    (107, 1, 'Comeu algo diferente nos ultimos 3 dias?',                            7, TRUE);

INSERT INTO opcao_resposta (id_opcao, id_pergunta, texto, peso, sinal_alerta, ordem) VALUES
    (1011, 101, 'Menos de 12 horas',                        1, FALSE, 1),
    (1012, 101, '1 a 2 dias',                               2, FALSE, 2),
    (1013, 101, '3 dias ou mais',                           4, FALSE, 3),

    (1021, 102, '1 ou 2',                                   1, FALSE, 1),
    (1022, 102, '3 a 5',                                    3, FALSE, 2),
    (1023, 102, 'Mais de 5',                                5, FALSE, 3),

    (1031, 103, 'Nao',                                      0, FALSE, 1),
    (1032, 103, 'Sim, pouco ou raiado',                     3, FALSE, 2),
    (1033, 103, 'Sim, bastante - ou fezes pretas',          0, TRUE,  3),

    (1041, 104, 'Sim, normalmente',                         0, FALSE, 1),
    (1042, 104, 'Bebe pouco',                               2, FALSE, 2),
    (1043, 104, 'Nao bebe nada ha mais de 12 horas',        4, FALSE, 3),

    (1051, 105, 'Nao',                                      0, FALSE, 1),
    (1052, 105, 'Sim',                                      0, TRUE,  2),

    (1061, 106, 'Normal, brincando',                        0, FALSE, 1),
    (1062, 106, 'Mais quieto, mas levanta e anda',          2, FALSE, 2),
    (1063, 106, 'Nao levanta, muito prostrado',             0, TRUE,  3),

    (1071, 107, 'Nao, ou nao sei',                          0, FALSE, 1),
    (1072, 107, 'Racao nova ou petisco diferente',          1, FALSE, 2),
    (1073, 107, 'Lixo, planta, osso ou brinquedo',          3, FALSE, 3),
    (1074, 107, 'Veneno, remedio humano, chocolate ou uva', 0, TRUE,  4);

INSERT INTO orientacao_triagem (id_queixa, classificacao, texto, ordem) VALUES
    (1, 'ORIENTACAO',    'Retire a comida por 6 horas e mantenha agua fresca a vontade', 1),
    (1, 'ORIENTACAO',    'Ao voltar a alimentar, ofereca porcoes pequenas de comida leve', 2),
    (1, 'ORIENTACAO',    'Nao ofereca medicamento humano em nenhuma hipotese', 3),
    (1, 'ORIENTACAO',    'Se aparecer sangue ou o animal parar de levantar, procure atendimento imediato', 4),
    (1, 'POUCO_URGENTE', 'Retire a comida por 6 horas e mantenha agua fresca a vontade', 1),
    (1, 'POUCO_URGENTE', 'Nao ofereca medicamento humano em nenhuma hipotese', 2),
    (1, 'POUCO_URGENTE', 'Anote os horarios e o aspecto dos episodios para mostrar a veterinaria', 3),
    (1, 'URGENTE',       'Mantenha agua disponivel e nao force a alimentacao', 1),
    (1, 'URGENTE',       'Leve uma amostra recente das fezes, se conseguir coletar', 2),
    (1, 'EMERGENCIA',    'Leve o animal a clinica agora, sem esperar horario marcado', 1),
    (1, 'EMERGENCIA',    'Nao ofereca agua, comida nem medicamento no caminho', 2);

-- ---------------------------------------------------------------------------
-- Queixa 2 - Pele e coceira
-- ---------------------------------------------------------------------------
INSERT INTO pergunta_triagem (id_pergunta, id_queixa, texto, ordem, obrigatoria) VALUES
    (201, 2, 'Ha quanto tempo?',                                               1, TRUE),
    (202, 2, 'Quanto ele se coca?',                                            2, TRUE),
    (203, 2, 'Tem ferida, casquinha ou pus?',                                  3, TRUE),
    (204, 2, 'Esta perdendo pelo?',                                            4, TRUE),
    (205, 2, 'Onde esta concentrado?',                                         5, TRUE),
    (206, 2, 'Alem da coceira, esta diferente?',                               6, TRUE),
    (207, 2, 'Apareceu inchaco no focinho ou dificuldade para respirar?',      7, TRUE);

INSERT INTO opcao_resposta (id_opcao, id_pergunta, texto, peso, sinal_alerta, ordem) VALUES
    (2011, 201, 'Menos de 1 semana',                          1, FALSE, 1),
    (2012, 201, '1 a 4 semanas',                              2, FALSE, 2),
    (2013, 201, 'Mais de 1 mes',                              3, FALSE, 3),

    (2021, 202, 'De vez em quando',                           1, FALSE, 1),
    (2022, 202, 'Bastante, mas dorme normal',                 2, FALSE, 2),
    (2023, 202, 'Sem parar, nao consegue dormir',             4, FALSE, 3),

    (2031, 203, 'Nao, so vermelhidao',                        1, FALSE, 1),
    (2032, 203, 'Ferida seca ou casquinha',                   2, FALSE, 2),
    (2033, 203, 'Ferida com pus ou cheiro ruim',              4, FALSE, 3),

    (2041, 204, 'Nao',                                        0, FALSE, 1),
    (2042, 204, 'Sim, em um lugar so',                        2, FALSE, 2),
    (2043, 204, 'Sim, em varios lugares',                     3, FALSE, 3),

    (2051, 205, 'Orelhas',                                    2, FALSE, 1),
    (2052, 205, 'Patas',                                      2, FALSE, 2),
    (2053, 205, 'Barriga ou virilha',                         2, FALSE, 3),
    (2054, 205, 'Base do rabo',                               2, FALSE, 4),
    (2055, 205, 'Espalhado pelo corpo',                       3, FALSE, 5),

    (2061, 206, 'Nao, come e brinca normal',                  0, FALSE, 1),
    (2062, 206, 'Mais quieto ou comendo menos',               3, FALSE, 2),

    (2071, 207, 'Nao',                                        0, FALSE, 1),
    (2072, 207, 'Sim, inchaco no rosto ou focinho',           0, TRUE,  2),
    (2073, 207, 'Sim, esta respirando com dificuldade',       0, TRUE,  3);

INSERT INTO orientacao_triagem (id_queixa, classificacao, texto, ordem) VALUES
    (2, 'ORIENTACAO',    'Evite banhos com shampoo humano ou produtos perfumados', 1),
    (2, 'ORIENTACAO',    'Use colar elizabetano se ele estiver se machucando ao cocar', 2),
    (2, 'ORIENTACAO',    'Verifique se a protecao contra pulgas esta em dia', 3),
    (2, 'ORIENTACAO',    'Fotografe as lesoes hoje, ajuda a comparar na consulta', 4),
    (2, 'POUCO_URGENTE', 'Use colar elizabetano se ele estiver se machucando ao cocar', 1),
    (2, 'POUCO_URGENTE', 'Nao aplique pomada nem remedio humano sobre as feridas', 2),
    (2, 'POUCO_URGENTE', 'Fotografe as lesoes hoje, ajuda a comparar na consulta', 3),
    (2, 'URGENTE',       'Evite que ele lamba ou coce a regiao ate a consulta', 1),
    (2, 'URGENTE',       'Nao aplique pomada nem remedio humano sobre as feridas', 2),
    (2, 'EMERGENCIA',    'Leve o animal a clinica agora, sem esperar horario marcado', 1),
    (2, 'EMERGENCIA',    'Reacao alergica pode piorar em minutos, nao aguarde melhora', 2);

-- ---------------------------------------------------------------------------
-- Queixa 3 - Nao esta comendo
-- ---------------------------------------------------------------------------
INSERT INTO pergunta_triagem (id_pergunta, id_queixa, texto, ordem, obrigatoria) VALUES
    (301, 3, 'Ha quanto tempo esta sem comer direito?',    1, TRUE),
    (302, 3, 'Esta bebendo agua?',                         2, TRUE),
    (303, 3, 'Recusa tudo ou so a racao?',                 3, TRUE),
    (304, 3, 'Notou perda de peso?',                       4, TRUE),
    (305, 3, 'Tem outro sintoma junto?',                   5, TRUE),
    (306, 3, 'Mudou algo na rotina recentemente?',         6, TRUE);

INSERT INTO opcao_resposta (id_opcao, id_pergunta, texto, peso, sinal_alerta, marcador, ordem) VALUES
    (3011, 301, 'Menos de 24 horas',                                        2, FALSE, NULL,               1),
    (3012, 301, '1 a 2 dias',                                               4, FALSE, NULL,               2),
    (3013, 301, '3 dias ou mais',                                           5, FALSE, 'JEJUM_PROLONGADO', 3),

    (3021, 302, 'Sim, normalmente',                                         0, FALSE, NULL, 1),
    (3022, 302, 'Bebe pouco',                                               2, FALSE, NULL, 2),
    (3023, 302, 'Nao bebe nada',                                            4, FALSE, NULL, 3),

    (3031, 303, 'Come petisco ou comida caseira, recusa so a racao',        1, FALSE, NULL, 1),
    (3032, 303, 'Recusa tudo que e oferecido',                              4, FALSE, NULL, 2),

    (3041, 304, 'Nao',                                                      0, FALSE, NULL, 1),
    (3042, 304, 'Um pouco',                                                 2, FALSE, NULL, 2),
    (3043, 304, 'Sim, bastante',                                            4, FALSE, NULL, 3),

    (3051, 305, 'Nao, so nao come',                                         0, FALSE, NULL, 1),
    (3052, 305, 'Vomito ou diarreia',                                       3, FALSE, NULL, 2),
    (3053, 305, 'Baba ou parece doer para mastigar',                        3, FALSE, NULL, 3),
    (3054, 305, 'Esta prostrado, nao levanta',                              0, TRUE,  NULL, 4),

    (3061, 306, 'Nao',                                                      0, FALSE, NULL, 1),
    (3062, 306, 'Sim - mudanca de casa, viagem, pet novo ou obra',          1, FALSE, NULL, 2);

INSERT INTO orientacao_triagem (id_queixa, classificacao, texto, ordem) VALUES
    (3, 'ORIENTACAO',    'Ofereca a comida morna, o cheiro estimula o apetite', 1),
    (3, 'ORIENTACAO',    'Deixe agua fresca em mais de um ponto da casa', 2),
    (3, 'ORIENTACAO',    'Anote quanto ele comeu por dia ate a proxima avaliacao', 3),
    (3, 'POUCO_URGENTE', 'Ofereca a comida morna, o cheiro estimula o apetite', 1),
    (3, 'POUCO_URGENTE', 'Nao force a alimentacao com seringa sem orientacao da veterinaria', 2),
    (3, 'POUCO_URGENTE', 'Anote quanto ele comeu por dia ate a consulta', 3),
    (3, 'URGENTE',       'Mantenha agua disponivel e observe se ele bebe sozinho', 1),
    (3, 'URGENTE',       'Nao force a alimentacao com seringa sem orientacao da veterinaria', 2),
    (3, 'EMERGENCIA',    'Leve o animal a clinica agora, sem esperar horario marcado', 1);

-- ---------------------------------------------------------------------------
-- Queixa 4 - Respiracao e tosse
-- ---------------------------------------------------------------------------
INSERT INTO pergunta_triagem (id_pergunta, id_queixa, texto, ordem, obrigatoria) VALUES
    (401, 4, 'Como esta a respiracao agora?',                          1, TRUE),
    (402, 4, 'A lingua ou a gengiva esta arroxeada ou azulada?',       2, TRUE),
    (403, 4, 'Tem tosse?',                                             3, TRUE),
    (404, 4, 'Ha quanto tempo?',                                       4, TRUE),
    (405, 4, 'Cansa mais facil que antes no passeio ou brincando?',    5, TRUE),
    (406, 4, 'Esta espirrando ou com secrecao no nariz e olhos?',      6, TRUE),
    (407, 4, 'Pode ter engasgado com algum objeto ou alimento?',       7, TRUE);

INSERT INTO opcao_resposta (id_opcao, id_pergunta, texto, peso, sinal_alerta, ordem) VALUES
    (4011, 401, 'Normal',                                        0, FALSE, 1),
    (4012, 401, 'Mais rapida que o normal',                      4, FALSE, 2),
    (4013, 401, 'Com esforco, barulho ou de boca aberta',        0, TRUE,  3),

    (4021, 402, 'Nao, esta rosada',                              0, FALSE, 1),
    (4022, 402, 'Sim, arroxeada, azulada ou muito palida',       0, TRUE,  2),
    (4023, 402, 'Nao consegui ver',                              0, FALSE, 3),

    (4031, 403, 'Nao',                                           0, FALSE, 1),
    (4032, 403, 'Tosse seca, de vez em quando',                  2, FALSE, 2),
    (4033, 403, 'Tosse frequente',                               3, FALSE, 3),
    (4034, 403, 'Tosse com secrecao ou espuma',                  0, TRUE,  4),

    (4041, 404, 'Comecou hoje',                                  3, FALSE, 1),
    (4042, 404, 'Alguns dias',                                   2, FALSE, 2),
    (4043, 404, 'Semanas',                                       2, FALSE, 3),

    (4051, 405, 'Nao',                                           0, FALSE, 1),
    (4052, 405, 'Sim, cansa mais rapido',                        3, FALSE, 2),

    (4061, 406, 'Nao',                                           0, FALSE, 1),
    (4062, 406, 'Sim, transparente',                             1, FALSE, 2),
    (4063, 406, 'Sim, amarelada ou esverdeada',                  3, FALSE, 3),

    (4071, 407, 'Nao',                                           0, FALSE, 1),
    (4072, 407, 'Sim, ou nao tenho certeza',                     0, TRUE,  2);

INSERT INTO orientacao_triagem (id_queixa, classificacao, texto, ordem) VALUES
    (4, 'ORIENTACAO',    'Deixe o pet em local arejado e fresco, evite esforco e passeios', 1),
    (4, 'ORIENTACAO',    'Troque a coleira por peitoral enquanto houver tosse', 2),
    (4, 'ORIENTACAO',    'Evite fumaca, perfume e produtos de limpeza fortes no ambiente', 3),
    (4, 'POUCO_URGENTE', 'Deixe o pet em local arejado e fresco, evite esforco e passeios', 1),
    (4, 'POUCO_URGENTE', 'Grave um video curto da respiracao ou da tosse para mostrar a veterinaria', 2),
    (4, 'URGENTE',       'Mantenha o animal em repouso absoluto e em local ventilado', 1),
    (4, 'URGENTE',       'Nao ofereca agua a forca, pode agravar o quadro respiratorio', 2),
    (4, 'EMERGENCIA',    'Leve o animal a clinica agora, sem esperar horario marcado', 1),
    (4, 'EMERGENCIA',    'Transporte com a caixa aberta e o animal em posicao confortavel', 2);


-- -----------------------------------------------------------------------------
-- V7__criar_tratamento.sql
-- Tratamento em casa: a prescricao vira uma linha por dose prevista.
-- -----------------------------------------------------------------------------
CREATE TABLE tratamento (
    id_tratamento   BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_pet          BIGINT       NOT NULL,
    id_med_vet      BIGINT       NOT NULL,
    id_consulta     BIGINT,
    medicamento     VARCHAR(120) NOT NULL,
    dosagem         VARCHAR(80)  NOT NULL,
    intervalo_horas INT          NOT NULL,
    duracao_dias    INT          NOT NULL,
    inicio_em       TIMESTAMP    NOT NULL,
    status          VARCHAR(20)  NOT NULL,
    observacoes     VARCHAR(500),
    criado_em       TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    encerrado_em    TIMESTAMP,
    CONSTRAINT fk_tratamento_pet FOREIGN KEY (id_pet) REFERENCES pet (id_pet),
    CONSTRAINT fk_tratamento_med_vet FOREIGN KEY (id_med_vet) REFERENCES med_vet (id_usuario),
    CONSTRAINT fk_tratamento_consulta FOREIGN KEY (id_consulta) REFERENCES consulta (id_consulta)
);

CREATE INDEX idx_tratamento_pet ON tratamento (id_pet);
CREATE INDEX idx_tratamento_status ON tratamento (status);

-- Uma linha por horario previsto. A prescricao "12/12h por 7 dias" nao fica guardada
-- como texto: vira 14 registros concretos que o tutor confirma um a um.
CREATE TABLE dose_tratamento (
    id_dose          BIGINT AUTO_INCREMENT PRIMARY KEY,
    id_tratamento    BIGINT    NOT NULL,
    numero_dose      INT       NOT NULL,
    horario_previsto TIMESTAMP NOT NULL,
    confirmado_em    TIMESTAMP,
    CONSTRAINT fk_dose_tratamento FOREIGN KEY (id_tratamento) REFERENCES tratamento (id_tratamento),
    CONSTRAINT uk_dose_numero UNIQUE (id_tratamento, numero_dose)
);

CREATE INDEX idx_dose_horario ON dose_tratamento (horario_previsto);


-- -----------------------------------------------------------------------------
-- V8__criar_administrador.sql
-- Perfil de administracao da clinica.
-- -----------------------------------------------------------------------------
-- Perfil de administracao da clinica.
--
-- Cadastrar veterinario deixou de ser uma acao publica: qualquer pessoa que
-- baixasse o aplicativo poderia se declarar medico. A operacao passa a exigir
-- este perfil, que so a clinica possui.
--
-- Na heranca JOINED o Hibernate exige uma tabela por subclasse, mesmo quando ela
-- nao acrescenta nenhum atributo: a tabela guarda apenas a chave estrangeira.

CREATE TABLE administrador (
    id_usuario BIGINT PRIMARY KEY,
    CONSTRAINT fk_administrador_usuario FOREIGN KEY (id_usuario) REFERENCES usuario (id_usuario)
);

-- Senha: 123456 (mesmo hash das demais contas de demonstracao)
INSERT INTO usuario (tipo, nome, email, cpf, senha) VALUES
    ('ADMIN', 'Administracao Olli Pet', 'admin@ollipet.com', '00011122233',
     '$2a$10$zztCBVlHLsW6w.9BUUtAsurw7KlpNhZ19Ld9yYpZtzDVptGkGXRpe');

INSERT INTO administrador (id_usuario)
SELECT id_usuario FROM usuario WHERE email = 'admin@ollipet.com';

