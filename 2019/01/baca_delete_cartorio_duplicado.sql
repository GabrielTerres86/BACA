-- Created on 18/01/2019 by F0030248 
declare 
  -- Local variables here
  i integer;

  vr_linha VARCHAR2(1000);
  vr_dscritic VARCHAR2(1000);
  vr_done NUMBER;
  
  vr_input_file utl_file.file_type;    
begin
  -- Test statements here
  FOR rw IN (SELECT idcidade, cdcartorio, COUNT(1) qtd
              FROM tbcobran_cartorio_protesto  
              GROUP BY idcidade, cdcartorio
              HAVING COUNT(1) > 1) LOOP
              
      FOR x IN (SELECT t.rowid rowid_cart, row_number() over (PARTITION BY t.idcidade ORDER BY t.cdcartorio) seq, t.*, mun.dscidade 
                  FROM tbcobran_cartorio_protesto t, crapmun mun
                 WHERE t.idcidade = rw.idcidade
                   AND t.cdcartorio = rw.cdcartorio
                   AND mun.idcidade (+) = t.idcidade ) LOOP                                 
         IF x.seq > 1 THEN
           DELETE tbcobran_cartorio_protesto WHERE ROWID = x.rowid_cart;
         END IF;
         dbms_output.put_line(x.nmcartorio || ' - ' || x.nrcpf_cnpj || ' - ' || x.idcidade || ' - ' || x.dscidade || ' - ' || x.cdcartorio || '(' || x.seq || ')');
      END LOOP;
  END LOOP;              
  
  -- Abre o arquivo de dados em modo de grava??o
  gene0001.pc_abre_arquivo(pr_nmdireto => '/micros/cecred/rafael'   -- IN -- Diret?rio do arquivo
                          ,pr_nmarquiv => 'cartorios_duplicados.txt'         -- IN -- Nome do arquivo
                          ,pr_tipabert => 'W'           -- IN -- Modo de abertura (R,W,A)
                          ,pr_utlfileh => vr_input_file -- IN -- Handle do arquivo aberto
                          ,pr_des_erro => vr_dscritic   -- IN -- Erro
                          );  
  
  -- Escrever o registro no arquivo
  LOOP 
    EXIT WHEN vr_done = 1;
    dbms_output.get_line(vr_linha, vr_done);
        
    gene0001.pc_escr_linha_arquivo(pr_utlfileh  => vr_input_file            -- Handle do arquivo aberto
                                  ,pr_des_text  => vr_linha  -- Texto para escrita
                                  );
  END LOOP;                                
  gene0001.pc_fecha_arquivo(pr_utlfileh => vr_input_file); --> Handle do arquivo aberto;                                    

  COMMIT; 
  
end;
