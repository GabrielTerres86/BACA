CREATE TABLE TBCRD_PREAPROV_LIMITE (
    IDLIMITE         NUMBER(10)    NOT NULL,
    SKCARGA          NUMBER(10)    NOT NULL,
    CDCOOPER         NUMBER(3) 	   NOT NULL,
    TPPESSOA         NUMBER(1)     NOT NULL,
    NRCPFCNPJ        NUMBER(14)    NOT NULL,
    CDFAIXARISCO     NUMBER(3)     NULL,
    VLPOTENPARMAX    NUMBER(25,2)  NULL,
    VLPOTENLIMMAX    NUMBER(25,2)  NULL,
    CDRATING         VARCHAR2(2)   NULL,
    DTCALCULORATING  DATE          NULL,
    CDSTATUSCARGA    NUMBER(10)    NULL,
    DSSTATUSCARGA    VARCHAR2(255) NULL,
	CDSTATUSLIM      NUMBER(1)     NULl
);

COMMENT ON TABLE TBCRD_PREAPROV_LIMITE IS 
	'Tabela das cargas disponibilizadas aos cooperados';

COMMENT ON COLUMN TBCRD_PREAPROV_LIMITE.IDLIMITE IS
    'Chave artificial de identificacao do limite';

COMMENT ON COLUMN TBCRD_PREAPROV_LIMITE.SKCARGA IS
    'Chave artificial de identificacao da carga';

COMMENT ON COLUMN TBCRD_PREAPROV_LIMITE.CDCOOPER IS
    'CÃ³digo da cooperativa';

COMMENT ON COLUMN TBCRD_PREAPROV_LIMITE.TPPESSOA IS
    'Identificacao do tipo de pessoa (1 = PF, 2 = PJ)';

COMMENT ON COLUMN TBCRD_PREAPROV_LIMITE.NRCPFCNPJ IS
    'Numero do CPF ou CNPJ base ao qual o limite potencial pertence';

COMMENT ON COLUMN TBCRD_PREAPROV_LIMITE.CDFAIXARISCO IS
    'Codigo da faixa de risco usada para definir a taxa do contrato na precificacao';

COMMENT ON COLUMN TBCRD_PREAPROV_LIMITE.VLPOTENLIMMAX IS
    'Potencial maximo de limite de pre-aprovado calculado para o cooperado na carga';

COMMENT ON COLUMN TBCRD_PREAPROV_LIMITE.CDRATING IS
    'Codigo do rating a ser utilizado na operacao no caso de contratacao';

COMMENT ON COLUMN TBCRD_PREAPROV_LIMITE.DTCALCULORATING IS
    'Data do calculo do rating (dependendo de parametros pode ser re-calculado no processo noturno pelo Aimaro)';

COMMENT ON COLUMN TBCRD_PREAPROV_LIMITE.CDSTATUSCARGA IS
    'Codigo do status que identifica se o registro foi aceito ou nao pelo sistema Aimaro';

COMMENT ON COLUMN TBCRD_PREAPROV_LIMITE.DSSTATUSCARGA IS
    'Descricao do status de carga armazenado pelo Aimaro';
	
COMMENT ON COLUMN TBCRD_PREAPROV_LIMITE.CDSTATUSLIM IS
    'Status do limite do cooperado. 1 desbloqueada; 2 bloqueada';

ALTER TABLE TBCRD_PREAPROV_LIMITE ADD CONSTRAINT TBCRD_PREAPROV_LIMITE_PK PRIMARY KEY ( IDLIMITE, SKCARGA, CDCOOPER, TPPESSOA, NRCPFCNPJ );	

ALTER TABLE TBCRD_PREAPROV_LIMITE ADD CONSTRAINT TBCRD_PREAPROV_LIMITE_FK FOREIGN KEY (SKCARGA, CDCOOPER)
  REFERENCES TBCRD_PREAPROV_CARGA(SKCARGA, CDCOOPER); 	
