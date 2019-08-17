-- Created on 10/06/2019 by F0030248 
declare 
  -- Local variables here
  i integer;
  vr_dslobdev      CLOB;
  vr_dsbufdev      VARCHAR2(32700);  
  vr_dscritic      VARCHAR2(1000);
  
  procedure pc_print(pr_msg VARCHAR2, vr_close BOOLEAN DEFAULT FALSE) is
  begin
    -- Inicilizar as informacoes do XML
    gene0002.pc_escreve_xml(vr_dslobdev,vr_dsbufdev,pr_msg || CHR(10), vr_close);    
  end pc_print;
  
BEGIN
  
  -- Inicializar o CLOB
  dbms_lob.createtemporary(vr_dslobdev, TRUE);
  dbms_lob.open(vr_dslobdev, dbms_lob.lob_readwrite);
  vr_dsbufdev := NULL;
  
  -- criar um array
  pc_print('begin');    

  -- Test statements here
  FOR rw IN (SELECT sab.rowid sab_rowid, complend
               FROM crapsab sab
              WHERE sab.cdcooper = 1
                AND sab.nrdconta = 3714586
                AND sab.complend IS NULL) LOOP
                   
    pc_print('  update crapsab set complend = ' || 
                                  nvl(rw.complend,'NULL') || 
                                 ' where rowid = ''' || rw.sab_rowid || ''';');                                         
                
    UPDATE crapsab SET complend = ' '
     WHERE ROWID = rw.sab_rowid;
     
  END LOOP;
  
  pc_print('  commit;');
  pc_print('end;', TRUE);
  
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_dslobdev, '/micros/cecred/rafael/', 'baca_mhtec_crapsab_rollback.sql', NLS_CHARSET_ID('UTF8'));    
  
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_dslobdev);
  dbms_lob.freetemporary(vr_dslobdev);
  
  COMMIT;           
                
end;
