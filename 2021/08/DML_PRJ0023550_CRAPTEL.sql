DECLARE
  --Cooperativas ativas que não possuem o cadastro de tela
  CURSOR cr_crapcop(pr_nmdatela IN craptel.nmdatela%TYPE) IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1
       AND NOT EXISTS (SELECT 1
              FROM craptel tel
             WHERE tel.nmdatela = pr_nmdatela
               AND tel.cdcooper = cop.cdcooper);

  vr_nmdatela craptel.nmdatela%TYPE := 'PRONAM';
  vr_nrmodulo craptel.nrmodulo%TYPE := 3; --Empréstimos
  vr_cdopptel craptel.cdopptel%TYPE := '@,C';
  vr_tldatela craptel.tldatela%TYPE := 'Acompanhamento Operacoes Pronampe';
  vr_tlrestel craptel.tlrestel%TYPE := 'Acompanhamento Operacoes Pronampe';
  vr_lsopptel craptel.lsopptel%TYPE := 'ACESSO,CONSULTA';
  VR_NRSEQRDR  NUMBER;
BEGIN
  --Para cada cooperativa insere a tela
  FOR rw_crapcop IN cr_crapcop(vr_nmdatela) LOOP
    INSERT INTO craptel
      (nmdatela
      ,nrmodulo
      ,cdopptel
      ,tldatela
      ,tlrestel
      ,lsopptel
      ,cdcooper)
    VALUES
      (vr_nmdatela
      ,vr_nrmodulo
      ,vr_cdopptel
      ,vr_tldatela
      ,vr_tlrestel
      ,vr_lsopptel
      ,rw_crapcop.cdcooper);
  END LOOP;
  
  insert into CRAPRDR (NMPROGRA, DTSOLICI)
  values ( 'TELA_PRONAM', TRUNC(SYSDATE))
  RETURNING NRSEQRDR INTO VR_NRSEQRDR;

  insert into crapaca ( NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ( 'CONSULTA_CONTRATOS', 'TELA_PRONAM', 'pc_consultar_contratos_web', 'pr_cdcooper,pr_nrdconta,pr_nrcontrato,pr_nriniseq,pr_nrregist,pr_datrini,pr_datrfim', VR_NRSEQRDR);
  insert into crapaca ( NMDEACAO, NMPACKAG, NMPROCED, LSTPARAM, NRSEQRDR)
  values ( 'GRAVA_HONRAPRONAMP', 'TELA_PRONAM', 'pc_atualizar_innaohonrar_web', 'pr_contratos', VR_NRSEQRDR);

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    RAISE_APPLICATION_ERROR(-20500, SQLERRM);
    ROLLBACK;
END;