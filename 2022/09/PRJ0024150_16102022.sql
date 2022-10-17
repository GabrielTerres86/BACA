DECLARE

  vr_aux_param VARCHAR(1000);

  CURSOR cr_cooperativas IS
    SELECT a.cdcooper
          ,CASE
             WHEN a.cdcooper = 1 THEN
              '850012'
             WHEN a.cdcooper = 16 THEN
              '1017128'
             ELSE
              '0'
           END conta
          ,'3968' historico
      FROM crapcop a
     WHERE a.flgativo = 1;
     
BEGIN

  INSERT INTO crappat
    (CDPARTAR
    ,NMPARTAR
    ,TPDEDADO
    ,CDPRODUT)
  VALUES
    ((SELECT MAX(cdpartar) + 1 FROM crappat)
    ,'HISTORICOS_CRED_SFH'
    ,2
    ,0);

  INSERT INTO crappat
    (CDPARTAR
    ,NMPARTAR
    ,TPDEDADO
    ,CDPRODUT)
  VALUES
    ((SELECT MAX(cdpartar) + 1 FROM crappat)
    ,'HISTORICOS_CRED_SFI'
    ,2
    ,0);
        
  INSERT INTO crappco
    (CDPARTAR
    ,CDCOOPER
    ,DSCONTEU)
  VALUES
    ((SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar = 'HISTORICOS_CRED_SFH')
    ,3
    ,'VLPARCELA,3697/VLMORA,3696/VLMULTA,3695/VLTAXA_ADM_PF,3805/VLTAXA_ADM_PJ,3806/VLSEGURO_MPI,3808/VLSEGURO_DFI,3807/VLPARCELA_ESTORNO_FGTS,3746/VLSALDO_DEVEDOR_FGTS,3748/');

  INSERT INTO crappco
    (CDPARTAR
    ,CDCOOPER
    ,DSCONTEU)
  VALUES
    ((SELECT a.cdpartar FROM CREDITO.crappat a WHERE a.nmpartar = 'HISTORICOS_CRED_SFI')
    ,3
    ,'VLPARCELA,3700/VLMORA,3699/VLMULTA,3698/VLTAXA_ADM_PF,3805/VLTAXA_ADM_PJ,3806/VLSEGURO_MPI,3808/VLSEGURO_DFI,3807/VLPARCELA_ESTORNO_FGTS,3746/VLSALDO_DEVEDOR_FGTS,3748/');    
    
    
    
    
 INSERT INTO crappat
    (CDPARTAR
    ,NMPARTAR
    ,TPDEDADO
    ,CDPRODUT)
  VALUES
    ((SELECT MAX(cdpartar) + 1
       FROM crappat)
    ,'HISTORICOS_CRED_BOLETO_IQ'
    ,2
    ,0);

  FOR rw_cooperativas IN cr_cooperativas LOOP
    vr_aux_param := TRIM(vr_aux_param || rw_cooperativas.cdcooper || ',' || rw_cooperativas.conta || ',' ||
                         rw_cooperativas.historico || '/');
  END LOOP;

  INSERT INTO crappco
    (CDPARTAR
    ,CDCOOPER
    ,DSCONTEU)
  VALUES
    ((SELECT a.cdpartar
       FROM CREDITO.crappat a
      WHERE a.nmpartar = 'HISTORICOS_CRED_BOLETO_IQ')
    ,3
    ,vr_aux_param);   
    
  INSERT INTO crapaca
    (nmdeacao
    ,nmpackag
    ,nmproced
    ,lstparam
    ,nrseqrdr)
  VALUES
    ('PROCESSA_ARQ_DAMP_FGTS'
    ,'EMPR0025'
    ,'pc_processar_arq_damp_fgts'
    ,'pr_tpexecuc,pr_dsdiretor,pr_dsarquivo,pr_linha_dados'
    ,(SELECT a.nrseqrdr
       FROM craprdr a
      WHERE a.nmprogra = 'EMPR0025'
        AND ROWNUM = 1));
    
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
    ROLLBACK;
END;





