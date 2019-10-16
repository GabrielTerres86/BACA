-- CRAPACA TELA_CONVEN.pc_gera_extr_ted
INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('GERAR_EXTRATO_TED','TELA_CONVEN','pc_gera_extr_ted','pr_cdcooper,pr_cdconven,pr_datarepasse',(SELECT a.nrseqrdr FROM CRAPRDR a WHERE a.nmprogra = 'TELA_CONVEN' AND ROWNUM = 1));
COMMIT;


