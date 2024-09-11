DECLARE
 
  vr_idseqpar cecred.tbseg_parametros_prst.idseqpar%TYPE;
 
  CURSOR cr_tbseg_parametros_prst(pr_cdcooper IN cecred.tbseg_parametros_prst.cdcooper%TYPE) IS
    SELECT p.*
      FROM cecred.tbseg_parametros_prst p
     WHERE p.cdcooper = 11
       AND p.tpcustei = 0
       AND p.cdsegura = CECRED.segu0001.busca_seguradora
       AND p.tppessoa = 2;
  rw_tbseg_parametros_prst cr_tbseg_parametros_prst%ROWTYPE;
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop c
     WHERE c.flgativo = 1      
       AND c.cdcooper = 3
    ORDER BY c.cdcooper; 
BEGIN
 
  FOR rw_crapcop IN cr_crapcop LOOP
 
    vr_idseqpar := cecred.tbseg_parametros_prst_seq.nextval;
 
    OPEN cr_tbseg_parametros_prst(pr_cdcooper => rw_crapcop.cdcooper);
    FETCH cr_tbseg_parametros_prst INTO rw_tbseg_parametros_prst;
    CLOSE cr_tbseg_parametros_prst;
 
    INSERT INTO cecred.tbseg_parametros_prst
      (idseqpar,
       cdcooper,
       tppessoa,
       cdsegura,
       tpdpagto,
       modalida,
       qtparcel,
       piedias,
       pieparce,
       pielimit,
       pietaxa,
       ifttdias,
       ifttparc,
       ifttlimi,
       iftttaxa,
       lmpseleg,
       tpcustei,
       vlcomiss,
       tpadesao,
       limitdps,
       nrapolic,
       enderftp,
       loginftp,
       senhaftp,
       flgelepf,
       flginden,
       idadedps,
       pagsegu,
       seqarqu,
       dtinivigencia,
       dtfimvigencia,
       lminsoci,
       dtctrmista,
       QTMES_SOCIO)
    VALUES
      (vr_idseqpar,
       3,
       2,
       rw_tbseg_parametros_prst.cdsegura,
       1,
       1,
       rw_tbseg_parametros_prst.qtparcel,
       rw_tbseg_parametros_prst.piedias,
       rw_tbseg_parametros_prst.pieparce,
       rw_tbseg_parametros_prst.pielimit,
       rw_tbseg_parametros_prst.pietaxa,
       rw_tbseg_parametros_prst.ifttdias,
       rw_tbseg_parametros_prst.ifttparc,
       rw_tbseg_parametros_prst.ifttlimi,
       rw_tbseg_parametros_prst.iftttaxa,
       200000,
       0,
       1,
       rw_tbseg_parametros_prst.tpadesao,
       rw_tbseg_parametros_prst.limitdps,
       '77001393',
       rw_tbseg_parametros_prst.enderftp,
       rw_tbseg_parametros_prst.loginftp,
       rw_tbseg_parametros_prst.senhaftp,
       rw_tbseg_parametros_prst.flgelepf,
       rw_tbseg_parametros_prst.flginden,
       rw_tbseg_parametros_prst.idadedps,
       0.0588,
       1,
       TRUNC(SYSDATE),
       TO_DATE('23/04/2054', 'dd/mm/yyyy'),
       10000,
       null,
       6); 
    INSERT INTO cecred.tbseg_param_prst_cap_seg
      (idseqpar, idademin, idademax, capitmin, capitmax)
      SELECT vr_idseqpar, 18, 65, 10000, 1000000
        FROM cecred.tbseg_param_prst_cap_seg p
       WHERE p.idseqpar = rw_tbseg_parametros_prst.idseqpar;
 
    INSERT INTO cecred.tbseg_param_prst_tax_cob
      (idseqpar, gbidamin, gbidamax, gbsegmin, gbsegmax)
      SELECT vr_idseqpar, 18, 65, 0.05586, 0.00294
        FROM cecred.tbseg_param_prst_tax_cob p
       WHERE p.idseqpar = rw_tbseg_parametros_prst.idseqpar;
    COMMIT;
  END LOOP;
  
  update tbseg_parametros_prst p set p.nrapolic = '77001393', P.PAGSEGU = 0.0588 where p.nrapolic = '000000077001299' and p.tppessoa = 2; 
  UPDATE tbseg_prestamista p set p.nrapolice = '77001393' where p.nrapolice = '000000077001299';
  COMMIT;
END;
