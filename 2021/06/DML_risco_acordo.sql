-- Created on 21/06/2021 by F0032386 
declare 

  vr_inrisco_acordo NUMBER := 0;
  vr_dtinicio_modelo2_3040 DATE;
  vr_cdmodelo       NUMBER;       
  
  
  CURSOR cr_acordo IS
  SELECT c.rowid rowid_contrato, a.cdcooper,a.nrdconta,c.cdorigem,c.nrctremp
    FROM tbrecup_acordo a,
         tbrecup_acordo_contrato c
   WHERE a.nracordo = c.nracordo
--     AND a.nracordo IN (1)
     AND a.cdcooper = 5
     AND a.dhacordo > to_date('15/06/2021','DD/MM/RRRR');      
    
  cursor cr_risco(pr_cdcooper tbrisco_central_ocr.cdcooper%TYPE,
                    pr_nrdconta tbrisco_central_ocr.nrdconta%TYPE,
                    pr_nrctremp tbrisco_central_ocr.nrctremp%TYPE,
                    pr_cdorigem tbrisco_central_ocr.cdorigem%TYPE,
                    pr_dtmvtoan crapdat.dtmvtoan%TYPE) is
    select inrisco_operacao
      from tbrisco_central_ocr r
     where r.cdcooper = pr_cdcooper
       and r.nrdconta = pr_nrdconta
       and r.nrctremp = pr_nrctremp
       and (r.cdmodali = CASE pr_cdorigem
                           WHEN 1 THEN 101
                           WHEN 2 THEN 499
                           WHEN 3 THEN 299
                           WHEN 4 THEN 301
                         END
          OR r.cdmodali = CASE pr_cdorigem
                           WHEN 2 THEN 299
                           WHEN 3 THEN 499
                         END
           )
       and r.dtrefere = pr_dtmvtoan;

    rw_risco cr_risco%ROWTYPE;
BEGIN 
  
  UPDATE crapprm x
     SET x.dsvlrprm = '01/06/2021'
   WHERE x.cdacesso = 'INIC_GERA_ACOR_3040_MOD2'; 
   
  COMMIT;
  
  FOR rw_acordo IN cr_acordo LOOP
    vr_inrisco_acordo := 0;  
  
    IF rw_acordo.cdorigem NOT IN (5,6) THEN
      OPEN cr_risco(pr_cdcooper => rw_acordo.cdcooper,
                    pr_nrdconta => rw_acordo.nrdconta,
                    pr_nrctremp => rw_acordo.nrctremp,
                    pr_cdorigem => rw_acordo.cdorigem,
                    pr_dtmvtoan => to_date('18/06/2021','DD/MM/RRRR'));
      FETCH cr_risco INTO rw_risco; 
      CLOSE cr_risco;
    END IF;
    
    vr_inrisco_acordo := rw_risco.inrisco_operacao;
    
    IF ( vr_inrisco_acordo <> 10) THEN
      vr_cdmodelo := RECUPERACAO.TIPOSDADOSACORDOS.modelo_acordo_v2;

      UPDATE tbrecup_acordo_contrato c
         SET c.inrisco_acordo = vr_inrisco_acordo,
             c.cdmodelo = vr_cdmodelo
       WHERE c.rowid = rw_acordo.rowid_contrato;

    END IF;  
  
  END LOOP;  
  
  COMMIT;
  
END;
