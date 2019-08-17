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
  
  CURSOR cr_crawcrd_b (pr_cdcooper NUMBER,
                       pr_nrdconta NUMBER,
                       pr_cdadmcrd NUMBER) IS
    SELECT c.flgprcrd,ROWID FROM crawcrd c
     WHERE c.cdcooper = pr_cdcooper
       AND c.nrdconta = pr_nrdconta
       AND c.cdadmcrd = pr_cdadmcrd;
  rw_crawcrd_b cr_crawcrd_b%ROWTYPE;   
 
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
  vr_nom_diretorio varchar2(200);
  vr_nmarqdat varchar2(200);
  vr_arquivo_txt utl_file.file_type;
  vr_dscritic VARCHAR2(4000);
  vr_dslinha VARCHAR2(4000);
BEGIN
  
  -- gerar arquivo contabil
  vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                            pr_cdcooper => 3,
                                            pr_nmsubdir => 'log');
                                            
  vr_nmarqdat := 'script_retorno_INC0012357.log';                                         
                                            

  -- Abre o arquivo para escrita
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio,    --> Diretório do arquivo
                           pr_nmarquiv => vr_nmarqdat,         --> Nome do arquivo
                           pr_tipabert => 'W',                 --> Modo de abertura (R,W,A)
                           pr_utlfileh => vr_arquivo_txt,      --> Handle do arquivo aberto
                           pr_des_erro => vr_dscritic);
                                                                               
                                                
  -- loop principal
  FOR rw_principal IN cr_principal LOOP
    
    FOR rw_crawcrd_b IN cr_crawcrd_b(rw_principal.cdcooper,
                                     rw_principal.nrdconta,
                                     rw_principal.cdadmcrd) LOOP
      vr_dslinha := 'update crawcrd set flgprcrd = ' || rw_crawcrd_b.flgprcrd || ' WHERE rowid = ' || '''' || rw_crawcrd_b.rowid || '''' || ';';   
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_dslinha);  
    END LOOP;
    
    
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
  vr_dslinha := ' commit;';
  gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_dslinha); 
  
  
  gene0001.pc_fecha_arquivo(vr_arquivo_txt);
   
  
  COMMIT;
  
EXCEPTION 
  WHEN OTHERS THEN
    dbms_output.put_line('Erro ao processar ' || SQLERRM);
    ROLLBACK;
    
END;
