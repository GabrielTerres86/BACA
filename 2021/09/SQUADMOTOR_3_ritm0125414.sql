DECLARE
  vr_nrseqaca NUMBER;
BEGIN
    
  SELECT NVL(MAX(nrseqaca),0)+1 INTO vr_nrseqaca
    FROM crapaca;
  
  DELETE CECRED.crapaca 
   WHERE nmdeacao = 'DESOPE_BUSCA_HIST_BLOQUEIO_DIGITAL' 
     AND nmpackag = 'TELA_CONTAS_DESAB';
     
  INSERT INTO CECRED.crapaca(nrseqaca
                     ,nmdeacao
                     ,nmpackag
                     ,nmproced
                     ,lstparam
                     ,nrseqrdr)
               VALUES(vr_nrseqaca
                     ,'DESOPE_BUSCA_HIST_BLOQUEIO_DIGITAL'
                     ,'TELA_CONTAS_DESAB'
                     ,'pc_busca_hist_bloqueio_digital'
                     ,'pr_nrdconta,pr_tpproduto'
                     ,71);
  COMMIT;                     
EXCEPTION         
   WHEN OTHERS THEN
        ROLLBACK;  
END;
/
DECLARE
  vr_nrseqaca NUMBER;
BEGIN
    
  SELECT NVL(MAX(nrseqaca),0)+1 INTO vr_nrseqaca
    FROM crapaca;
  
  DELETE CECRED.crapaca 
   WHERE nmdeacao = 'DESOPE_COMBO_MOTIVOS_BLOQUEIO_DIGITAL' 
     AND nmpackag = 'TELA_CONTAS_DESAB';
     
  INSERT INTO CECRED.crapaca(nrseqaca
                     ,nmdeacao
                     ,nmpackag
                     ,nmproced
                     ,lstparam
                     ,nrseqrdr)
               VALUES(vr_nrseqaca
                     ,'DESOPE_COMBO_MOTIVOS_BLOQUEIO_DIGITAL'
                     ,'TELA_CONTAS_DESAB'
                     ,'pc_combo_motivos_bloqueio_digital'
                     ,'pr_flgtipo,pr_cdproduto'
                     ,71);
  COMMIT;                     
EXCEPTION         
   WHEN OTHERS THEN
        ROLLBACK;  
END;
/
BEGIN
   UPDATE CECRED.crapaca set lstparam = 'pr_nrdconta,pr_flgrenli,pr_flmajora,pr_dsmotmaj,pr_flcnaulc,pr_flcredigi,pr_idmotivobd'
    WHERE UPPER(nmdeacao) = 'DESOPE_GRAVA_CONTA'
      AND UPPER(nmpackag) = 'TELA_CONTAS_DESAB'
      AND LOWER(nmproced) = 'pc_grava_dados_conta';
   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
     ROLLBACK;
END;
/
BEGIN
   DELETE CECRED.tbgen_dominio_campo WHERE nmdominio = 'TPPRODUTO' AND cddominio = 1;
   INSERT INTO CECRED.tbgen_dominio_campo(nmdominio
                                  ,cddominio
                                  ,dscodigo)
                            VALUES('TPPRODUTO'
                                   ,1
                                   ,'Crédito Digital');
   COMMIT;
EXCEPTION
   WHEN OTHERS THEN
     ROLLBACK;
END;
/