-- Scripts DML Projetos: PRJ0013792 - Inclusão do cheque especial na esteira de crédito
-- Tipo: Telas

-- armazenar tela para interface web
INSERT INTO CRAPRDR (NMPROGRA, DTSOLICI) values ('LIMI0003', sysdate);


--------------------- Crapaca ---------------------
INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('VERIFICA_CONTING_LIMCHEQ','LIMI0003','pc_conting_limcheq_web','pr_cdcooper',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('ENVIAR_ESTEIRA_LIMITE','LIMI0003','pc_analisar_proposta','pr_tpenvest,pr_nrctrlim,pr_tpctrlim,pr_nrdconta,pr_dtmovito',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('SENHA_ENVIAR_ESTEIRA_LIMITE','LIMI0003','pc_enviar_proposta_manual','pr_nrctrlim,pr_tpctrlim,pr_nrdconta,pr_dtmovito,pr_flgconti',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('BUSCA_MOTIVOS_ANULA_LIMITE','LIMI0003','pc_busca_moti_anula','pr_tpproduto,pr_nrdconta,pr_nrctrato,pr_tpctrlim',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('GRAVA_MOTIVO_ANULA_LIMITE','LIMI0003','pc_grava_moti_anula','pr_tpproduto,pr_nrdconta,pr_nrctrato,pr_tpctrlim,pr_cdmotivo,pr_dsmotivo,pr_dsobservacao',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('GERA_IMPRESSAO_LIMITE','LIMI0003','pc_gera_impressao','pr_nrdconta,pr_idseqttl,pr_idimpres,pr_tpctrlim,pr_nrctrlim,pr_dsiduser,pr_flgerlog',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('EFETIVA_PROPOSTA_LIMITE','LIMI0003','pc_confirmar_novo_limite_web','pr_nrdconta,pr_idseqttl,pr_inconfir,pr_nrctrlim,pr_flgerlog,pr_insitapr',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('VALIDA_PROPOSTA_LIMITE','LIMI0003','pc_verifica_impressao','pr_nrdconta,pr_nrctrlim',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1));

INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('VERIFICA_CONTING_ESTEIRA','LIMI0003','pc_conting_esteira_web','pr_cdcooper,pr_tpctrlim',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'LIMI0003' AND ROWNUM = 1));


COMMIT; 