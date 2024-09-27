DECLARE

  vr_count NUMBER := 0;

  CURSOR cr_taxas IS
    SELECT p.cdcooper,
           p.pagsegu,
           t.idseqpar,
           t.gbidamin,
           t.gbidamax,
           p.iftttaxa,
           (p.iftttaxa/10) AS new_iftttaxa,
           t.gbsegmin,
           t.gbsegmin/10 AS new_gbsegmin,
           t.gbsegmax,
           (t.gbsegmax/10) AS new_gbsegmax,
           (t.gbsegmin/10) + (t.gbsegmax/10)  tot_new
      FROM cecred.tbseg_parametros_prst p, 
           cecred.tbseg_param_prst_tax_cob t
     WHERE p.idseqpar = t.idseqpar
       AND p.nrapolic = '77001060'
     ORDER BY 1,3,4,5;
 
  CURSOR cr_tbseg_prestamista IS
    SELECT p.cdcooper,
           p.nrdconta,
           p.nrctrseg,
           p.nrctremp,
           p.pemorte,
           p.pemorte/10 as new_pemorte,
           p.peinvalidez,
           p.peinvalidez/10 as new_peinvalidez,
           p.peiftttaxa,
           p.peiftttaxa/10 as new_peiftttaxa           
      FROM cecred.tbseg_prestamista p,
           cecred.crapass a
     WHERE p.cdcooper = a.cdcooper
       AND p.nrdconta = a.nrdconta
       AND p.tpcustei = 0
       AND a.inpessoa = 1
     ORDER BY 1,2,3,4;
    
BEGIN
  
  FOR rw_taxas IN cr_taxas LOOP

    UPDATE cecred.tbseg_parametros_prst p
       SET p.iftttaxa = rw_taxas.new_iftttaxa
     WHERE p.idseqpar = rw_taxas.idseqpar;
    
    UPDATE cecred.tbseg_param_prst_tax_cob t
       SET t.gbsegmin = rw_taxas.new_gbsegmin,
           t.gbsegmax = rw_taxas.new_gbsegmax
     WHERE t.idseqpar = rw_taxas.idseqpar
       AND t.gbidamin = rw_taxas.gbidamin
       AND t.gbidamax = rw_taxas.gbidamax;

    COMMIT;     
  END LOOP;     
  
  FOR rw_tbseg_prestamista IN cr_tbseg_prestamista LOOP
    
    UPDATE cecred.tbseg_prestamista t
       SET t.pemorte = rw_tbseg_prestamista.new_pemorte,
           t.peinvalidez = rw_tbseg_prestamista.new_peinvalidez,
           t.peiftttaxa = rw_tbseg_prestamista.new_peiftttaxa
     WHERE cdcooper = rw_tbseg_prestamista.cdcooper
       AND nrdconta = rw_tbseg_prestamista.nrdconta
       AND nrctrseg = rw_tbseg_prestamista.nrctrseg
       AND nrctremp = rw_tbseg_prestamista.nrctremp;
  
    vr_count := vr_count + 1;
    IF vr_count = 10000 THEN
      vr_count := 0;
      COMMIT;       
    END IF;
    
  END LOOP;
  COMMIT;

END;
