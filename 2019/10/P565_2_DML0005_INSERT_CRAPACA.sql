DELETE FROM CRAPACA
 WHERE nrseqrdr =
       (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN')
   AND NMDEACAO = 'BUSCAR_DADOS_LIBERACAO_CONV';
  
INSERT INTO cecred.crapaca
  (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
  (SEQACA_NRSEQACA.NEXTVAL,
   'BUSCAR_DADOS_LIBERACAO_CONV',
   'TELA_CONVEN',
   'pc_busca_liberacao_conve_web',
   'pr_tparrecad,pr_cdempres,pr_cdconven,pr_cdempcon,pr_cdsegmto',
   (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN'));
COMMIT;

DELETE FROM CRAPACA
 WHERE nrseqrdr =
       (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN')
   AND NMDEACAO = 'GRAVAR_DADOS_CONVEN_LIB';
  
INSERT INTO cecred.crapaca
  (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
  (SEQACA_NRSEQACA.NEXTVAL,
   'GRAVAR_DADOS_CONVEN_LIB',
   'TELA_CONVEN',
   'pc_gravar_liberacao_conve_web',
   '',
   (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN'));
COMMIT;

DELETE CRAPACA
 WHERE nrseqrdr =
       (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN')
   AND NMDEACAO = 'BUSCA_COOP_CONVEN_AILOS';
  
INSERT INTO cecred.crapaca
  (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
  (SEQACA_NRSEQACA.NEXTVAL,
   'BUSCA_COOP_CONVEN_AILOS',
   'TELA_CONVEN',
   'pc_busca_coop_conven_web',
   '',
   (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN'));
COMMIT;

DELETE CRAPACA
 WHERE nrseqrdr =
       (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN')
   AND NMDEACAO = 'BUSCA_FORMA_ARRECADACAO';
  
INSERT INTO cecred.crapaca
  (nrseqaca, nmdeacao, nmpackag, nmproced, lstparam, nrseqrdr)
VALUES
  (SEQACA_NRSEQACA.NEXTVAL,
   'BUSCA_FORMA_ARRECADACAO',
   'TELA_CONVEN',
   'pc_busca_forma_arrecad_web',
   'pr_cdcooper,pr_cdempcon,pr_cdsegmto',
   (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'TELA_CONVEN'));
COMMIT;

