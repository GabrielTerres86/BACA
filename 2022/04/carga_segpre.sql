DECLARE
  vr_idseqpar   NUMBER;
  vr_min_faixa  NUMBER;
  vr_max_faixa1 NUMBER := 3000000;
  vr_max_faixa2 NUMBER := 500000;
  vr_max_faixa3 NUMBER := 100000;
  vr_max_faixa4 NUMBER := 50000;
  
  CURSOR cr_crapop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.flgativo = 1;
BEGIN
  FOR rw_idseqpar IN (SELECT p.idseqpar
                        FROM tbseg_parametros_prst p
                       WHERE p.tppessoa = 1
                         AND p.cdsegura = 514
                         AND p.tpcustei = 0) LOOP
    DELETE
      FROM tbseg_param_prst_cap_seg p
     WHERE p.idseqpar = rw_idseqpar.idseqpar;
     
    DELETE
      FROM tbseg_param_prst_tax_cob p
     WHERE p.idseqpar = rw_idseqpar.idseqpar;
    
    DELETE
      FROM tbseg_parametros_prst p
     WHERE p.idseqpar = rw_idseqpar.idseqpar;
  END LOOP;
  
	COMMIT;
	
  FOR rw_crapop IN cr_crapop LOOP  
    BEGIN
      SELECT NVL(MAX(idseqpar)+1,1)
        INTO vr_idseqpar
        FROM tbseg_parametros_prst;
        
      INSERT INTO tbseg_parametros_prst(idseqpar,
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
                                        dtfimvigencia)
      VALUES(vr_idseqpar,
             rw_crapop.cdcooper,
             1,
             514,
             0,
             0,
             240,
             30,
             5,
             10000,
             0,
             15,
             5,
             10000,
             2.5326,
             0,
             0,
             30,
             0,
             200000,
						 '77001060',
             'filetransfer.icatuseguros.com.br',
             'Producao-Ailos',
             '@Ailos2019@',
             0,
             0,
             66,
             0,
             1,
             TO_DATE('25/04/2022','DD/MM/RRRR'),
             TO_DATE('31/08/2041','DD/MM/RRRR'));
      
      COMMIT;
			
      INSERT INTO tbseg_param_prst_tax_cob(idseqpar,
                                           gbidamin,
                                           gbidamax,
                                           gbsegmin,
                                           gbsegmax)
      VALUES(vr_idseqpar
            ,18
            ,65
            ,0.4641030
            ,0.0258970);
						
      COMMIT;
			
      INSERT INTO tbseg_param_prst_tax_cob(idseqpar,
                                           gbidamin,
                                           gbidamax,
                                           gbsegmin,
                                           gbsegmax)
      VALUES(vr_idseqpar
            ,66
            ,80
            ,2.8023630
            ,0.0198370);
						
      COMMIT;
			
      IF rw_crapop.cdcooper = 1 THEN
        vr_min_faixa := 40000;
      ELSIF rw_crapop.cdcooper = 5 THEN
        vr_min_faixa := 10000;
      ELSIF rw_crapop.cdcooper = 16 THEN
        vr_min_faixa := 10000;
      ELSE
        vr_min_faixa := 0.01;
      END IF;
      
      INSERT INTO tbseg_param_prst_cap_seg (idseqpar, idademin, idademax, capitmin, capitmax)
      VALUES (vr_idseqpar, 18, 65, vr_min_faixa, vr_max_faixa1);
      
			COMMIT;
      
			INSERT INTO tbseg_param_prst_cap_seg (idseqpar, idademin, idademax, capitmin, capitmax)
      VALUES (vr_idseqpar, 66, 70, vr_min_faixa, vr_max_faixa2);
      
			COMMIT;
      
			INSERT INTO tbseg_param_prst_cap_seg (idseqpar, idademin, idademax, capitmin, capitmax)
      VALUES (vr_idseqpar, 71, 75, vr_min_faixa, vr_max_faixa3);
      
			COMMIT;
			
      INSERT INTO tbseg_param_prst_cap_seg (idseqpar, idademin, idademax, capitmin, capitmax)
      VALUES (vr_idseqpar, 76, 80, vr_min_faixa, vr_max_faixa4);
           
      COMMIT;  

    END; 
  END LOOP;
END;
/