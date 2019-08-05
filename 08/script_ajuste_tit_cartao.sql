-- Created on 31/07/2019 by F0032710 
declare 
  CURSOR cr_principal IS  
    SELECT con.* FROM (SELECT c.cdcooper,c.cdcooper ||' - '|| p.nmrescop AS dscooper,  
         c.nrdconta,
         c.cdadmcrd, 
         d.nmresadm,
         c.insitcrd,      
         (SELECT COUNT(1) FROM crawcrd x
           WHERE x.cdcooper = c.cdcooper
             AND x.nrdconta = c.nrdconta
             AND x.cdadmcrd = c.cdadmcrd) qtd_crd_adm,
         (SELECT COUNT(1) FROM crawcrd x
           WHERE x.cdcooper = c.cdcooper
             AND x.nrdconta = c.nrdconta
             AND x.cdadmcrd = c.cdadmcrd
             AND x.flgprcrd = 1
             AND x.insitcrd NOT IN (5,6)) qtd_tit
    FROM crawcrd c
   LEFT JOIN crapass a ON (a.cdcooper = c.cdcooper AND 
                           a.nrdconta = c.nrdconta)  
   LEFT JOIN crapadc d ON (d.cdadmcrd = c.cdadmcrd AND d.cdcooper = c.cdcooper)  
   LEFT JOIN crapcop p ON (p.cdcooper = c.cdcooper)                      
   WHERE c.cdcooper > 0
    AND  c.cdadmcrd > 0
    AND  a.inpessoa <> 1
    AND  LENGTH(c.nrcrcard) > 14
    AND  a.dtdemiss IS NULL) con
    WHERE con.qtd_tit = 0
      AND con.insitcrd NOT IN (5,6)
    GROUP BY con.cdcooper,con.dscooper,con.nrdconta, con.cdadmcrd, con.insitcrd, con.qtd_crd_adm, con.qtd_tit,con.nmresadm
    ORDER BY con.cdcooper;

  rw_principal cr_principal%ROWTYPE;
  
  CURSOR cr_crawcrd_tit (pr_cdcooper IN crawcrd.cdcooper%TYPE, 
                         pr_nrdconta IN crawcrd.nrdconta%TYPE,
                         pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE) IS
    SELECT c.*,c.rowid FROM crawcrd c 
     WHERE c.cdcooper = pr_cdcooper
       AND c.nrdconta = pr_nrdconta
       AND c.cdadmcrd = pr_cdadmcrd
       AND c.insitcrd NOT IN (5,6)
       AND c.nrctrcrd = (SELECT MIN(c.nrctrcrd) FROM crawcrd c 
                         WHERE c.cdcooper = pr_cdcooper
                           AND c.nrdconta = pr_nrdconta
                           AND c.cdadmcrd = pr_cdadmcrd
                           AND c.insitcrd NOT IN (5,6));
  rw_crawcrd_tit cr_crawcrd_tit%ROWTYPE;
                           
  CURSOR cr_crawcrd_bkp (pr_cdcooper IN crawcrd.cdcooper%TYPE, 
                         pr_nrdconta IN crawcrd.nrdconta%TYPE,
                         pr_cdadmcrd IN crawcrd.cdadmcrd%TYPE) IS
    SELECT c.*,c.rowid FROM crawcrd c 
     WHERE c.cdcooper = pr_cdcooper
       AND c.nrdconta = pr_nrdconta
       AND c.cdadmcrd = pr_cdadmcrd;  
  rw_crawcrd_bkp cr_crawcrd_bkp%ROWTYPE;

  vr_nom_diretorio VARCHAR2(100);
  vr_nmarqdat VARCHAR2(50);  
  vr_arquivo_txt utl_file.file_type; 
  vr_dscritic VARCHAR2(4000);
  vr_linhadet VARCHAR2(4000);
          
begin
  
  vr_nom_diretorio := gene0001.fn_diretorio(pr_tpdireto => 'C',
                                              pr_cdcooper => 3,
                                              pr_nmsubdir => 'log');

  -- Nome do arquivo a ser gerado
  vr_nmarqdat        := 'plano_retorno_INC0017809.txt';

  -- Abre o arquivo para escrita
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nom_diretorio,    --> Diretório do arquivo
                           pr_nmarquiv => vr_nmarqdat,         --> Nome do arquivo                          
                           pr_tipabert => 'W',                 --> Modo de abertura (R,W,A)                           
                           pr_utlfileh => vr_arquivo_txt,      --> Handle do arquivo aberto
                           pr_des_erro => vr_dscritic);
                                   
  gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, 'BEGIN');      
  
  FOR rw_principal IN cr_principal LOOP  
    -- fazer backup    
    FOR rw_crawcrd_bkp IN cr_crawcrd_bkp (rw_principal.cdcooper,
                                          rw_principal.nrdconta,
                                          rw_principal.cdadmcrd) LOOP
      
      vr_linhadet := 'update crawcrd set flgprcrd = ' || rw_crawcrd_bkp.flgprcrd || ' where rowid = ''' || rw_crawcrd_bkp.rowid || '''' || ';';
      gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, vr_linhadet);                                            
    END LOOP;
    
    OPEN cr_crawcrd_tit(rw_principal.cdcooper,
                        rw_principal.nrdconta,
                        rw_principal.cdadmcrd);

    rw_crawcrd_tit := NULL;
    
     FETCH cr_crawcrd_tit INTO rw_crawcrd_tit;
    CLOSE cr_crawcrd_tit;
    
    IF rw_crawcrd_tit.rowid IS NOT NULL THEN
      UPDATE crawcrd SET flgprcrd = 1
       WHERE ROWID = rw_crawcrd_tit.rowid;    
    END IF;
    
              
  END LOOP;
  
  gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, 'COMMIT;');
  gene0001.pc_escr_linha_arquivo(vr_arquivo_txt, 'END;');
  gene0001.pc_fecha_arquivo(vr_arquivo_txt);
  
  COMMIT;
end;
