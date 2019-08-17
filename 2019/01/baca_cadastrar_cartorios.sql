-- Created on 18/01/2019 by F0030248 
declare 
  -- Local variables here
  i INTEGER;
  
  vr_linha VARCHAR2(1000);
  vr_dscritic VARCHAR2(1000);
  vr_done NUMBER;
  
  vr_input_file utl_file.file_type;      
  
  CURSOR cr_cart (pr_idcidade IN tbcobran_cartorio_protesto.idcidade%TYPE
                 ,pr_cdcartorio IN tbcobran_cartorio_protesto.cdcartorio%TYPE) IS
    SELECT cart.idcartorio
      FROM tbcobran_cartorio_protesto cart
     WHERE cart.idcidade = pr_idcidade
       AND cart.cdcartorio = pr_cdcartorio;
  rw_cart cr_cart%ROWTYPE;       
begin
  -- Test statements here
  FOR rw IN (

    SELECT DISTINCT sab.nmcidsac, sab.cdufsaca, ret.cdcomarc, ret.cdcartorio, mun.idcidade, mun.dscidade
      FROM tbcobran_confirmacao_ieptb ret, crapcob cob, crapsab sab, crapmun mun, crapcco cco
    WHERE ret.dtmvtolt >= to_date('01/11/2018','DD/MM/RRRR')
      AND ret.cdcomarc > 0
      AND cco.cdcooper = ret.cdcooper
      AND cco.nrconven = ret.nrcnvcob
      AND cob.cdcooper = ret.cdcooper
      AND cob.nrdconta = ret.nrdconta
      AND cob.nrcnvcob = ret.nrcnvcob
      AND cob.nrdocmto = ret.nrdocmto
      AND cob.nrdctabb = cco.nrdctabb
      AND cob.cdbandoc = cco.cddbanco
      AND sab.cdcooper = cob.cdcooper
      AND sab.nrdconta = cob.nrdconta
      AND sab.nrinssac = cob.nrinssac
      AND mun.cdcomarc = ret.cdcomarc
      AND trim(mun.dscidade) = TRIM(sab.nmcidsac)
    
    ) LOOP
    
      OPEN cr_cart(rw.idcidade, rw.cdcartorio);
      FETCH cr_cart INTO rw_cart;
            
      IF cr_cart%FOUND THEN                         
        dbms_output.put_line ('Cartorio ' || rw.cdcomarc || ' - ' || rw.nmcidsac || ' - OK');                           
      ELSE
         dbms_output.put_line ('Cartorio ' || rw.cdcomarc || ' - ' || rw.nmcidsac || ' - ' || rw.dscidade || ' - ' || ' nao cadastrado');  

         BEGIN         
           INSERT INTO tbcobran_cartorio_protesto(nrcpf_cnpj, nmcartorio, idcidade, flgativo, cdcartorio)
           VALUES (0, 'PRACA PAGADOR ' || rw.nmcidsac || ' - ' || rw.cdufsaca, rw.idcidade, 1, rw.cdcartorio);
         EXCEPTION WHEN OTHERS THEN
           dbms_output.put_line ('Erro ao cadastrar Cartorio ' || rw.cdcomarc || ' - ' || rw.nmcidsac || ' - ' || SQLERRM);             
         END; 
                  
      END IF;
      
      CLOSE cr_cart;
    
    END LOOP;
  
  -- Abre o arquivo de dados em modo de grava??o
  gene0001.pc_abre_arquivo(pr_nmdireto => '/micros/cecred/rafael'   -- IN -- Diret?rio do arquivo
                          ,pr_nmarquiv => 'cadastrar_cartorios.txt'         -- IN -- Nome do arquivo
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
