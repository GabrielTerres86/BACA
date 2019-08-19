-- Created on 05/06/2019 by F0030248 
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
  FOR rw IN (SELECT cob.rowid cob_rowid, nrcnvcob, nrdocmto, nmdavali, cdtpinav, nrinsava 
               FROM crapcob cob
              WHERE cdcooper = 1
                AND nrdconta = 3714586
                AND dtmvtolt BETWEEN to_date('01/06/2019','DD/MM/RRRR') AND TRUNC(SYSDATE)
                AND nmdavali IS NULL) LOOP
                   
    pc_print('  update crapcob set nmdavali = ' || 
                                  nvl(rw.nmdavali,'NULL') || ',' ||
                                 ' cdtpinav = ' || nvl(to_char(rw.cdtpinav),'NULL') || ',' ||
                                 ' nrinsava = ' || nvl(to_char(rw.nrinsava),'NULL') || 
                                 ' where rowid = ''' || rw.cob_rowid || ''';');
                                         
                
    UPDATE crapcob SET nrinsava = 0,
                       nmdavali = ' ',
                       cdtpinav = 0
     WHERE ROWID = rw.cob_rowid;
     
  END LOOP;
  
  pc_print('  commit;');
  pc_print('end;', TRUE);
  
  DBMS_XSLPROCESSOR.CLOB2FILE(vr_dslobdev, '/micros/cecred/rafael/', 'baca_mhtec_api_rollback.sql', NLS_CHARSET_ID('UTF8'));    
  
  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_dslobdev);
  dbms_lob.freetemporary(vr_dslobdev);
  
  COMMIT;           
                
end;
