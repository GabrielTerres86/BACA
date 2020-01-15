-- Created on 11/01/2020 by T0032613 
DECLARE

  vr_rootmicros      VARCHAR2(5000) := gene0001.fn_param_sistema('CRED',3,'ROOT_MICROS');
  vr_nmdireto        VARCHAR2(4000) := vr_rootmicros||'cpd/bacas/PRB0042679';
  vr_nmarqimp        VARCHAR2(100)  := 'backup.txt';
  vr_ind_arquiv      utl_file.file_type;
  vr_excsaida        EXCEPTION;
  vr_dscritic        varchar2(5000) := ' ';
  
   -- Cursor para buscar os rep. legal/procurador que foram gerados com tpdoc errado
   CURSOR cr_contas IS
      SELECT doc.cdcooper, doc.nrdconta, doc.flgdigit, doc.tpbxapen, doc.cdopebxa, doc.dtbxapen, doc.rowid
        FROM crapavt avt, crapdoc doc, crapass ass
       WHERE avt.nrdconta = doc.nrdconta
         AND avt.cdcooper = doc.cdcooper
         AND avt.dtmvtolt = doc.dtmvtolt
         AND avt.tpctrato = 6
         AND avt.dtmvtolt > '08/10/2019'
         AND doc.tpdocmto = 8
         AND doc.flgdigit = 0
         and doc.tpbxapen = 0
         AND ass.cdcooper = doc.cdcooper
         AND ass.nrdconta = doc.nrdconta
         AND ass.dtmvtolt <> avt.dtmvtolt  
       UNION 
      SELECT doc.cdcooper, doc.nrdconta, doc.flgdigit, doc.tpbxapen, doc.cdopebxa, doc.dtbxapen, doc.rowid
        FROM crapcrl crl, crapdoc doc, crapass ass
       WHERE crl.cdcooper = doc.cdcooper
         AND crl.nrdconta = doc.nrdconta
         AND crl.dtmvtolt = doc.dtmvtolt
         AND crl.dtmvtolt > '08/10/2019'   
         AND doc.tpdocmto = 8
         AND doc.flgdigit = 0
         and doc.tpbxapen = 0
         AND ass.cdcooper = doc.cdcooper
         AND ass.nrdconta = doc.nrdconta
         AND ass.dtmvtolt <> crl.dtmvtolt;
         
  procedure backup(pr_msg VARCHAR2) IS
  BEGIN
    gene0001.pc_escr_linha_arquivo(vr_ind_arquiv, pr_msg);
  END;
         
BEGIN 
  
  --Criar arquivo
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto        --> Diretorio do arquivo
                          ,pr_nmarquiv => vr_nmarqimp        --> Nome do arquivo
                          ,pr_tipabert => 'W'                --> modo de abertura (r,w,a)
                          ,pr_utlfileh => vr_ind_arquiv      --> handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic);      --> erro
  -- em caso de crítica
  IF vr_dscritic IS NOT NULL THEN        
     RAISE vr_excsaida;
  END IF;

   FOR rw_contas IN cr_contas LOOP
      
      backup('update crapdoc doc set doc.tpbxapen = '|| rw_contas.tpbxapen ||
                                 '  ,doc.flgdigit = '|| rw_contas.flgdigit ||
                                 '  ,doc.dtbxapen = '|| case when rw_contas.dtbxapen is null 
                                                             then 'null' 
                                                             else 'to_date(''(' || to_char(rw_contas.dtbxapen,'dd/mm/rrr') ||''',''dd/mm/rrrr'')'
                                                         end ||
                                 ' ,doc.cdopebxa = '''|| rw_contas.cdopebxa ||''' '||
                ' where rowid = '''|| rw_contas.rowid || ''';');
                                         
      BEGIN
          UPDATE crapdoc doc
             SET doc.flgdigit = 1 
                ,doc.tpbxapen = 3 -- Baixa manual
                ,doc.dtbxapen = SYSDATE                
                ,doc.cdopebxa = '1'
           WHERE doc.rowid = rw_contas.rowid;
             
      EXCEPTION
        WHEN OTHERS THEN
          vr_dscritic := 'Erro baixando a pendencia de digitalizacao, ROWID '|| rw_contas.rowid ||' - ERRO: ' || SQLERRM;
          RAISE vr_excsaida;
      END;
   END LOOP;

  COMMIT;

EXCEPTION    
  WHEN vr_excsaida then
    ROLLBACK;
    raise_application_error( -20001,vr_dscritic);         
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
    
  WHEN OTHERS then
    ROLLBACK;
    raise_application_error( -20001,'Erro baixando a pendencia de digitalizacao - '    ||
                                    'erro: ' || sqlerrm);         

    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_ind_arquiv); --> Handle do arquivo aberto;  
end;
