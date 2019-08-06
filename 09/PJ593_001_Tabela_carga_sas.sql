CREATE TABLE TBCRD_PREAPROV_CARGA (
    SKCARGA          NUMBER(10)    NOT NULL,
    CDCOOPER         NUMBER(3) 	   NOT NULL,
    DSCARGA          VARCHAR2(255) NULL,
    QTPFCARREGADOS   NUMBER(10)    NULL,
    QTPJCARREGADOS   NUMBER(10)    NULL,
    VLPOTENPARTOTAL  NUMBER(25,2)  NULL,
    VLPOTENLIMTOTAL  NUMBER(25,2)  NULL,
    IDPRESAS         NUMBER(10)    NULL,
    DTCARGA          TIMESTAMP(6)  NULL,
    DTLIBERACAO      TIMESTAMP(6)  NULL,
    DTINIVIGENCIA    TIMESTAMP(6)  NULL,
    DTFINVIGENCIA    TIMESTAMP(6)  NULL,
    INCARGA          NUMBER(2)     NULL,
    DSUSERCONN       VARCHAR2(50)  NULL,
    DSUSERUSER       VARCHAR2(50)  NULL
);

COMMENT ON TABLE TBCRD_PREAPROV_CARGA IS 
	'Cargas geradas pelo SAS de limite de cartao pre aprovado por cooperativa';

COMMENT ON COLUMN TBCRD_PREAPROV_CARGA.SKCARGA IS
    'Chave de identificacao do DW';

COMMENT ON COLUMN TBCRD_PREAPROV_CARGA.CDCOOPER IS
    'Codigo da cooperativa';

COMMENT ON COLUMN TBCRD_PREAPROV_CARGA.DSCARGA IS
    'Descricao da carga apresentada na tela de liberacao da carga';

COMMENT ON COLUMN TBCRD_PREAPROV_CARGA.QTPFCARREGADOS IS
    'Quantidade de limites calculados de pessoa fisica';

COMMENT ON COLUMN TBCRD_PREAPROV_CARGA.QTPJCARREGADOS IS
    'Quantidade de limites calculados de pessoa juridica';

COMMENT ON COLUMN TBCRD_PREAPROV_CARGA.VLPOTENPARTOTAL IS
    'Soma dos valores de potencial de parcela na carga';

COMMENT ON COLUMN TBCRD_PREAPROV_CARGA.VLPOTENLIMTOTAL IS
    'Soma dos valores de potencial de limite na carga';

COMMENT ON COLUMN TBCRD_PREAPROV_CARGA.IDPRESAS IS
    'Codigo de identificacao interno do processo SAS (nao usar no Aimaro)';

COMMENT ON COLUMN TBCRD_PREAPROV_CARGA.DTCARGA IS
    'Data e hora do que a carga foi realizada no banco de dados de integracao';

COMMENT ON COLUMN TBCRD_PREAPROV_CARGA.DTLIBERACAO IS
    'Data e hora que a carga foi librada no Aimaro';

COMMENT ON COLUMN TBCRD_PREAPROV_CARGA.DTINIVIGENCIA IS
    'Data e hora de inicio da vigencia da carga';

COMMENT ON COLUMN TBCRD_PREAPROV_CARGA.DTFINVIGENCIA IS
    'Data e hora de fim da vigencia da carga';

COMMENT ON COLUMN TBCRD_PREAPROV_CARGA.INCARGA IS
    'Status da carga. 1 desbloqueada; 2 bloqueada';
	
COMMENT ON COLUMN TBCRD_PREAPROV_CARGA.DSUSERCONN IS
    'Usuario de conexao utilizado para inserir a carga no banco de integracao';	
	
COMMENT ON COLUMN TBCRD_PREAPROV_CARGA.DSUSERUSER IS
    'Usuario do sistema operacional que estava utilizando a conexao para inserir registros';	

ALTER TABLE TBCRD_PREAPROV_CARGA ADD CONSTRAINT TBCRD_PREAPROV_CARGA_PK PRIMARY KEY ( SKCARGA, CDCOOPER );