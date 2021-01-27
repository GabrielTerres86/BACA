DECLARE
  CURSOR cr_crapcop IS
    SELECT cop.* FROM crapcop cop;
  vr_nmdatela VARCHAR2(6);
BEGIN
  vr_nmdatela := 'PSPPIX';
  FOR rw_crapcop IN cr_crapcop LOOP
    INSERT INTO craptel
      (NMDATELA
      ,NRMODULO
      ,CDOPPTEL
      ,TLDATELA
      ,TLRESTEL
      ,FLGTELDF
      ,FLGTELBL
      ,NMROTINA
      ,LSOPPTEL
      ,INACESSO
      ,CDCOOPER
      ,IDSISTEM
      ,IDEVENTO
      ,NRORDROT
      ,NRDNIVEL
      ,NMROTPAI
      ,IDAMBTEL)
    VALUES
      (vr_nmdatela
      ,5
      ,'A,C,I'
      ,'Gerenciamento dos participantes indiretos do PIX'
      ,'Gerenciamento dos PSPs indiretos do PIX'
      ,0
      ,1
      ,' '
      ,'ALTERACAO,CONSULTA,INCLUSAO'
      ,0
      ,rw_crapcop.cdcooper
      ,1
      ,0
      ,1
      ,1
      ,' '
      ,2);
  
    INSERT INTO crapprg
      (NMSISTEM
      ,CDPROGRA
      ,DSPROGRA##1
      ,DSPROGRA##2
      ,DSPROGRA##3
      ,DSPROGRA##4
      ,NRSOLICI
      ,NRORDPRG
      ,INCTRPRG
      ,CDRELATO##1
      ,CDRELATO##2
      ,CDRELATO##3
      ,CDRELATO##4
      ,CDRELATO##5
      ,INLIBPRG
      ,CDCOOPER
      ,QTMINMED)
    VALUES
      ('CRED'
      ,vr_nmdatela
      ,'Gerenciamento dos participantes indiretos do PIX'
      ,' '
      ,' '
      ,' '
      ,(SELECT MAX(nvl(nrsolici, 0)) + 1 FROM crapprg)
      ,NULL
      ,1
      ,0
      ,0
      ,0
      ,0
      ,0
      ,1
      ,rw_crapcop.cdcooper
      ,NULL);
  
    COMMIT;
  END LOOP;

  insert into craprdr (NRSEQRDR , NMPROGRA , DTSOLICI)
  values (SEQRDR_NRSEQRDR.NEXTVAL, 'BTCH0001', sysdate);

  insert into crapaca (NRSEQACA, NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values (SEQACA_NRSEQACA.NEXTVAL, 'GERA_LOG_BATCH', 'BTCH0001', 'pc_gera_log_batch_web', 'pr_cdcooper,pr_ind_tipo_log,pr_des_log,pr_nmarqlog,pr_flnovlog,pr_flfinmsg,pr_dsdirlog,pr_dstiplog,pr_cdprograma,pr_tpexecucao,pr_cdcriticidade,pr_flgsucesso,pr_cdmensagem', (SELECT nrseqrdr FROM craprdr WHERE nmprogra = 'BTCH0001'));

  COMMIT;

END;
