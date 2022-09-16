DECLARE

  vr_nmdatela  CONSTANT craptel.nmdatela%TYPE := 'SVRPIX';
  vr_tldatela  CONSTANT craptel.tldatela%TYPE := 'SOLICITACOES DE VALORES A RECEBER VIA PIX';
  vr_nrseqrdr  craprdr.nrseqrdr%TYPE;

BEGIN

  INSERT INTO cecred.craptel 
                (nmdatela,
                 nrmodulo,
                 cdopptel,
                 tldatela,
                 tlrestel,
                 flgteldf,
                 flgtelbl,
                 nmrotina,
                 lsopptel,
                 inacesso,
                 cdcooper,
                 idsistem,
                 idevento,
                 nrordrot,
                 nrdnivel,
                 nmrotpai,
                 idambtel)
                SELECT vr_nmdatela,
                   7,
                   '@,A,R,E',
                   vr_tldatela,
                   'VALORES A RECEBER VIA PIX',
                   0,
                   1, 
                   ' ',
                   'Acesso,Aprovar,Reprocessar,Encerrar',
                   1,
                   cdcooper, 
                   1,
                   0,
                   1,
                   1,
                   '',
                   2
                FROM cecred.crapcop t
                 WHERE t.flgativo = 1;

  INSERT INTO cecred.crapprg
                (nmsistem,
                 cdprogra,
                 dsprogra##1,
                 dsprogra##2,
                 dsprogra##3,
                 dsprogra##4,
                 nrsolici,
                 nrordprg,
                 inctrprg,
                 cdrelato##1,
                 cdrelato##2,
                 cdrelato##3,
                 cdrelato##4,
                 cdrelato##5,
                 inlibprg,
                 cdcooper)
                SELECT 'CRED',
                   vr_nmdatela,
                   vr_tldatela,
                   '.',
                   '.',
                   '.',
                   50,
                   (SELECT MAX(g.nrordprg)+1 FROM cecred.crapprg g WHERE g.cdcooper = c.cdcooper AND g.nrsolici = 50),
                   1,
                   0,
                   0,
                   0,
                   0,
                   0,
                   1,
                   c.cdcooper
                FROM cecred.crapcop c
                 WHERE c.flgativo = 1;
  
  
  
  BEGIN
    INSERT INTO craprdr(nmprogra,dtsolici)
                VALUES ('SVRPIX',SYSDATE) RETURN nrseqrdr INTO vr_nrseqrdr;
  EXCEPTION
    WHEN dup_val_on_index THEN
      SELECT nrseqrdr
        INTO vr_nrseqrdr
        FROM craprdr 
       WHERE nmprogra = 'SVRPIX';
  END;
  
  INSERT INTO crapaca(nmdeacao
                     ,nmpackag
                     ,nmproced
                     ,lstparam
                     ,nrseqrdr)
               VALUES('BUSCAR_SOLICITACAO_DEVOLUCAO'
                     ,NULL
                     ,'buscarSolicDevolucaoVlr'
                     ,'pr_cdcooper,pr_nrcpfcgc,pr_nrdconta,pr_dtsolini,pr_dtsolfim,pr_dsprotoc,pr_idsituac'
                     ,vr_nrseqrdr);
  
  INSERT INTO crapaca(nmdeacao
                     ,nmpackag
                     ,nmproced
                     ,lstparam
                     ,nrseqrdr)
               VALUES('GRAVAR_SITUACAO_DEVOLUCAO'
                     ,NULL
                     ,'gravarSitSolicDevolucao'
                     ,'pr_idsolici,pr_idrotina,pr_dsobserv'
                     ,vr_nrseqrdr);
  
  
  COMMIT;
  
EXCEPTION
  WHEN OTHERS THEN
    RAISE_application_error(-20500,SQLERRM);
    ROLLBACK;
END;
