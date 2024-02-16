DECLARE

  vr_idseqpar cecred.tbseg_parametros_prst.idseqpar%TYPE;

  CURSOR cr_tbseg_parametros_prst(pr_cdcooper IN cecred.tbseg_parametros_prst.cdcooper%TYPE) IS
    SELECT p.*
      FROM cecred.tbseg_parametros_prst p
     WHERE p.cdcooper = pr_cdcooper
       AND p.tpcustei = 1
       AND p.cdsegura = CECRED.segu0001.busca_seguradora
       AND p.tppessoa = 1;
  rw_tbseg_parametros_prst cr_tbseg_parametros_prst%ROWTYPE;
  
  CURSOR cr_crapcop IS
    SELECT cdcooper
      FROM cecred.crapcop c
     WHERE c.flgativo = 1      
       AND c.cdcooper <> 3
       AND c.cdcooper = 16
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
       dtctrmista)
    VALUES
      (vr_idseqpar,
       rw_tbseg_parametros_prst.cdcooper,
       rw_tbseg_parametros_prst.tppessoa,
       rw_tbseg_parametros_prst.cdsegura,
       rw_tbseg_parametros_prst.tpdpagto,
       rw_tbseg_parametros_prst.modalida,
       rw_tbseg_parametros_prst.qtparcel,
       rw_tbseg_parametros_prst.piedias,
       rw_tbseg_parametros_prst.pieparce,
       rw_tbseg_parametros_prst.pielimit,
       rw_tbseg_parametros_prst.pietaxa,
       rw_tbseg_parametros_prst.ifttdias,
       rw_tbseg_parametros_prst.ifttparc,
       rw_tbseg_parametros_prst.ifttlimi,
       rw_tbseg_parametros_prst.iftttaxa,
       rw_tbseg_parametros_prst.lmpseleg,
       rw_tbseg_parametros_prst.tpcustei,
       rw_tbseg_parametros_prst.vlcomiss,
       rw_tbseg_parametros_prst.tpadesao,
       rw_tbseg_parametros_prst.limitdps,
       '000000077001236',
       rw_tbseg_parametros_prst.enderftp,
       rw_tbseg_parametros_prst.loginftp,
       rw_tbseg_parametros_prst.senhaftp,
       rw_tbseg_parametros_prst.flgelepf,
       rw_tbseg_parametros_prst.flginden,
       rw_tbseg_parametros_prst.idadedps,
       0.30380,
       1,
       TO_DATE('15/02/2024', 'dd/mm/yyyy'),
       TO_DATE('14/02/2054', 'dd/mm/yyyy'),
       rw_tbseg_parametros_prst.lminsoci,
       null); 

    UPDATE cecred.tbseg_parametros_prst p
       SET p.dtfimvigencia = to_date('14/02/2024','dd/mm/yyyy')
     WHERE p.idseqpar = rw_tbseg_parametros_prst.idseqpar;

    INSERT INTO cecred.tbseg_param_prst_cap_seg
      (idseqpar, idademin, idademax, capitmin, capitmax)
      SELECT vr_idseqpar, p.idademin, p.idademax, 0, 3000000
        FROM cecred.tbseg_param_prst_cap_seg p
       WHERE p.idseqpar = rw_tbseg_parametros_prst.idseqpar;

    INSERT INTO cecred.tbseg_param_prst_tax_cob
      (idseqpar, gbidamin, gbidamax, gbsegmin, gbsegmax)
      SELECT vr_idseqpar, p.gbidamin, p.gbidamax, 0.28504790, 0.01875210
        FROM cecred.tbseg_param_prst_tax_cob p
       WHERE p.idseqpar = rw_tbseg_parametros_prst.idseqpar;
    COMMIT;
  END LOOP;
END;
