COMMENT ON COLUMN TBCRD_APROVACAO_CARTAO.indtipo_senha
  IS 
    '1 - Cartao Magnetico TA, 2 - Cartao Cecred TA, 3 - Conta Online, 4 - Supervisor, 5 - Operador, 6 - Canais';

CREATE TABLE TBCRD_TRANS_PEND
(
  IDTRPEND      NUMBER(15)    NOT NULL,
  CDCOOPER      NUMBER(3)     NOT NULL,
  NRDCONTA      NUMBER(10)    NOT NULL,
  NRCTRCRD 	    NUMBER(10)    NULL, 
  NRCRCARD  	NUMBER(25,2)  NULL,
  TPTRANS	    NUMBER(6)     NULL,
  TPCANAL	    NUMBER(5)     NULL
);

COMMENT ON TABLE TBCRD_TRANS_PEND
  IS 'Dados da transacao pendente de cartao de credito';

COMMENT ON COLUMN TBCRD_TRANS_PEND.IDTRPEND
  IS 'Codigo sequencial da transacao pendente';
 
COMMENT ON COLUMN TBCRD_TRANS_PEND.CDCOOPER
  IS 'Codigo da cooperativa';
  
COMMENT ON COLUMN TBCRD_TRANS_PEND.NRDCONTA
  IS 'Numero da conta';
  
COMMENT ON COLUMN TBCRD_TRANS_PEND.NRCTRCRD
  IS 'Numero da proposta.';
  
COMMENT ON COLUMN TBCRD_TRANS_PEND.NRCRCARD
  IS 'Numero do cartao Credicard.';
  
COMMENT ON COLUMN TBCRD_TRANS_PEND.TPTRANSACAO
  IS 'Tipo de transacao do carta (0-Novo / 1-Upgrade-Downgrade)';
  
COMMENT ON COLUMN TBCRD_TRANS_PEND.TPCANAL
  IS 'Tipo de canal aprovacao (0-Aimaro / 1- Canal (IB e MOBILE))'; 
  

ALTER  TABLE TBCRD_TRANS_PEND ADD CONSTRAINT TBCRD_TRANS_PEND_PK PRIMARY KEY (IDTRPEND, CDCOOPER, NRDCONTA);
