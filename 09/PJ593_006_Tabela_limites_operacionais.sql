CREATE TABLE TBCRD_LIMOPER (
    IDLIMOP          NUMBER(10)     NOT NULL,
    CDCOOPER         NUMBER(3) 	    NOT NULL,
    VLLIMOUTORG      NUMBER(25,2)   NULL,
    VLLIMCONSUMD     NUMBER(25,2)   NULL,
	VLLIMDISP        NUMBER(25,2)   NULL,
	NRPERCSEG		 NUMBER(3)      NULL,
	NRPERCDISPMAJOR  NUMBER(3)      NULL,
	NRPERCDISPPA     NUMBER(3)      NULL,
	NRPERCDISPOPNORM NUMBER(3)      NULL,
	DSEMAILS         VARCHAR2(2000) NULL,
	CDOPERAD         VARCHAR(10)    NULL,
	DTALTERA         DATE           NULL,
	DTCADASTRO       DATE           NULL
);

COMMENT ON TABLE TBCRD_LIMOPER IS 
	'Tabela de limites operacionais da cooperativa';

COMMENT ON COLUMN TBCRD_LIMOPER.IDLIMOP IS
    'Chave artificial de identificacao do limite operacional';

COMMENT ON COLUMN TBCRD_LIMOPER.CDCOOPER IS
    'Codigo da cooperativa';

COMMENT ON COLUMN TBCRD_LIMOPER.VLLIMOUTORG IS
    'Valor do Limite Outorgado';

COMMENT ON COLUMN TBCRD_LIMOPER.VLLIMCONSUMD IS
    'Valor do Limite Consumido';

COMMENT ON COLUMN TBCRD_LIMOPER.VLLIMDISP IS
    'Valor do limite disponivel';

COMMENT ON COLUMN TBCRD_LIMOPER.NRPERCSEG IS
    'Percentual de Seguranca';

COMMENT ON COLUMN TBCRD_LIMOPER.NRPERCDISPMAJOR IS
    'Percentual disponivel de majoracao';

COMMENT ON COLUMN TBCRD_LIMOPER.NRPERCDISPPA IS
    'Percentual de limite pre-aprovado';

COMMENT ON COLUMN TBCRD_LIMOPER.NRPERCDISPOPNORM IS
    'Percentaul de limite operacional normal';

COMMENT ON COLUMN TBCRD_LIMOPER.DSEMAILS IS
    'Emails para notificacao';

COMMENT ON COLUMN TBCRD_LIMOPER.DTCADASTRO IS
    'Data de cadastro do limite. ';

COMMENT ON COLUMN TBCRD_LIMOPER.DTALTERA IS
    'Data de alteracao, caso for algum operador que efetuou a alteracao dos limites ';

COMMENT ON COLUMN TBCRD_LIMOPER.CDOPERAD IS
    'Codigo do operador que fez a alteracao ';
	

ALTER TABLE TBCRD_LIMOPER ADD CONSTRAINT TBCRD_LIMOPER_PK PRIMARY KEY ( IDLIMOP, CDCOOPER );	