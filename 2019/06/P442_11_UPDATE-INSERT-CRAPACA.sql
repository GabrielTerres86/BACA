BEGIN
-- Seta para o tipo Desbloqueio
 update tbgen_motivo set flgtipo = 0 
  where IDMOTIVO = 51;
  
INSERT INTO CRAPACA (NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
VALUES ('COMBO_MOTIVOS', 'TELA_ATENDA_PREAPV', 'pc_combo_motivos', 'pr_flgtipo', (SELECT T2.NRSEQRDR FROM CRAPRDR T2 WHERE T2.NMPROGRA = 'TELA_ATENDA_PREAPV'));
  

  UPDATE CRAPACA SET LSTPARAM = 'pr_idmotivo,pr_dsmotivo,pr_cdproduto,pr_flgreserva_sistema,pr_flgativo,pr_flgtipo,pr_flgexibe' 
   WHERE NMDEACAO = 'MANTEM_MOTIVO' 
     AND NMPACKAG = 'TELA_CADMOT';

  COMMIT;
END;