-- Created on 27/05/2019 by F0032710 
declare 

  CURSOR cr_principal IS
  SELECT con.cdadmcrd,
          con.nrdconta,
          con.cdcooper,
          con.inpessoa
    FROM  (SELECT d.cdadmcrd
          ,d.nrdconta
          ,d.nrcpftit
          ,d.cdcooper
          ,a.inpessoa
      FROM crawcrd d, crapass a
     WHERE d.insitcrd NOT IN (5, 6)
       and a.cdcooper = d.cdcooper
       and a.nrdconta = d.nrdconta
       AND d.flgprcrd = 1
       and (a.inpessoa = 2 or a.inpessoa = 1) -- busca apenas Contas PJ "2" e PF "1"
  GROUP BY d.cdadmcrd
          ,d.nrdconta
          ,d.cdcooper
          ,d.nrcpftit
          ,a.inpessoa) con
   GROUP BY
          con.cdadmcrd,
          con.nrdconta,
          con.cdcooper,
          con.inpessoa          
  HAVING COUNT(con.cdadmcrd) > 1;
  rw_principal cr_principal%ROWTYPE;
 
  CURSOR cr_admcrd (pr_cdcooper NUMBER,
                    pr_nrdconta NUMBER) IS 
  SELECT DISTINCT c.cdadmcrd FROM crawcrd c
   WHERE c.cdcooper = pr_cdcooper
    AND  c.nrdconta =  pr_nrdconta
    AND  c.insitcrd NOT IN (5, 6);
  rw_admcrd cr_admcrd%ROWTYPE;
  
  
  CURSOR cr_cartao_tit (pr_cdcooper NUMBER,
                        pr_nrdconta NUMBER,
                        pr_cdadmcrd NUMBER) IS    
  SELECT ROWID,c.nrctrcrd FROM crawcrd c
   WHERE c.cdcooper = pr_cdcooper
    AND  c.nrdconta =  pr_nrdconta
    AND  c.insitcrd NOT IN (5, 6)
    AND  c.cdadmcrd = pr_cdadmcrd
    ORDER BY c.dtsolici ASC;
  rw_cartao_tit cr_cartao_tit%ROWTYPE; 
  
  
  CURSOR cr_cartao_tit_pf (pr_cdcooper NUMBER,
                           pr_nrdconta NUMBER,
                           pr_cdadmcrd NUMBER) IS
  SELECT c.rowid, c.nrctrcrd FROM crawcrd c, crapttl t
   WHERE c.cdcooper = t.cdcooper
    AND  c.nrdconta = t.nrdconta
    AND  c.nrcpftit = t.nrcpfcgc
    AND  t.idseqttl = 1
    AND  c.cdcooper = pr_cdcooper
    AND  c.nrdconta = pr_nrdconta
    AND  c.insitcrd NOT IN (5, 6)
    AND  c.cdadmcrd = pr_cdadmcrd
    ORDER BY c.dtsolici ASC;
  rw_cartao_tit_pf cr_cartao_tit_pf%ROWTYPE;

  vr_nrdrowid ROWID;
  vr_adm VARCHAR2(50);

BEGIN
  

  -- loop principal
  FOR rw_principal IN cr_principal LOOP
    
    FOR rw_admcrd IN cr_admcrd(rw_principal.cdcooper,
                               rw_principal.nrdconta) LOOP
      
      IF rw_principal.inpessoa <> 1 THEN
        -- PJ
         
        rw_cartao_tit := NULL;
        -- buscar o cartão titular      
        OPEN cr_cartao_tit (rw_principal.cdcooper,
                            rw_principal.nrdconta,
                            rw_admcrd.cdadmcrd);
         FETCH cr_cartao_tit INTO rw_cartao_tit;
        CLOSE cr_cartao_tit;
        
        -- setar os cartçoes que estão com a titularidade indevida
        UPDATE crawcrd SET flgprcrd = 0
         WHERE cdcooper = rw_principal.cdcooper
          AND  nrdconta = rw_principal.nrdconta
          AND  cdadmcrd = rw_admcrd.cdadmcrd
          AND  ROWID <>   rw_cartao_tit.rowid;
          
        -- atribuir a titularidade 
        UPDATE crawcrd SET flgprcrd = 1
         WHERE ROWID = rw_cartao_tit.rowid;
                                                
         
      ELSE
        -- PF
        rw_cartao_tit_pf := NULL;
        -- buscar o cartão titular      
        OPEN cr_cartao_tit_pf (rw_principal.cdcooper,
                               rw_principal.nrdconta,
                               rw_admcrd.cdadmcrd);
         FETCH cr_cartao_tit_pf INTO rw_cartao_tit_pf;
        CLOSE cr_cartao_tit_pf;
        
         -- setar os cartçoes que estão com a titularidade indevida
        UPDATE crawcrd SET flgprcrd = 0
         WHERE cdcooper = rw_principal.cdcooper
          AND  nrdconta = rw_principal.nrdconta
          AND  cdadmcrd = rw_admcrd.cdadmcrd
          AND  ROWID <>   rw_cartao_tit_pf.rowid;
          
        -- atribuir a titularidade 
        UPDATE crawcrd SET flgprcrd = 1
         WHERE ROWID = rw_cartao_tit_pf.rowid;
                 
      END IF;
                   
    END LOOP;   
    
  END LOOP; -- fim loop principal 
  
  COMMIT;
  
EXCEPTION 
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao processar ' || SQLERRM);
    ROLLBACK;
    
END;
