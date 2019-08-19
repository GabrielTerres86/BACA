declare 

  -- Busca conta na tabela de associados
  cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type
                    ,pr_nrdconta in crapass.nrdconta%type) is
  select ass.cdcooper
       , ass.nrdconta  
    from crapass ass
   where ass.cdcooper = pr_cdcooper
     and ass.nrdconta = pr_nrdconta;   
  rw_crapass cr_crapass%rowtype;         

  -- Declaracao de variaveis
  vr_contador number := 0;  
  vr_deslinha varchar2(4000);
  vr_dscritic varchar2(4000);
  vr_utlfile_reader utl_file.file_type;
  vr_utlfile_writer utl_file.file_type; 
  vr_nmarquiv varchar2(4000) := '20190131_base_contas.csv';
  vr_nmsqlout varchar2(4000) := 'atualizacao-cadastral-prod-'||to_char(sysdate,'SSSSS')||'.sql';
  vr_nmdireto varchar2(4000) := '/usr/micros/cpd/bacas/SCTASK0045695';
     
begin
  
  -- Definicao de buffer
  dbms_output.enable(buffer_size => null);
    
  -- Abre relacao de contas 
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarquiv
                          ,pr_tipabert => 'R'
                          ,pr_utlfileh => vr_utlfile_reader
                          ,pr_des_erro => vr_dscritic);

  -- Cria arquivo sql com comandos
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmsqlout
                          ,pr_tipabert => 'W'
                          ,pr_utlfileh => vr_utlfile_writer
                          ,pr_des_erro => vr_dscritic);
                          
  begin
    
    loop

      -- Leitor das linhas do arquivo
      gene0001.pc_le_linha_arquivo(vr_utlfile_reader,vr_deslinha);

      -- Remover ultimo caracter
      vr_deslinha := substr(vr_deslinha,1,length(vr_deslinha)-1);
      rw_crapass := null;

      -- Busca cooperado na tabela de associados
      open cr_crapass (substr(vr_deslinha,1,instr(vr_deslinha,';',1)-1)
                      ,substr(vr_deslinha,  instr(vr_deslinha,';',1)+1));     
      fetch cr_crapass into rw_crapass;
      close cr_crapass;

      -- Todos exceto Viacredi
      if rw_crapass.cdcooper = 1 then
        
        continue;
        
      -- Escreve comando somente se existir        
      elsif rw_crapass.cdcooper is not null then                  
        
        gene0001.pc_escr_linha_arquivo(vr_utlfile_writer,'insert into crapalt (nrdconta,cdoperad,dsaltera,tpaltera,flgctitg,cdcooper,dtaltera) values ('||rw_crapass.nrdconta||',''1'',''revisao cadastral com base na renda automatica,'',1,3,'||rw_crapass.cdcooper||',trunc(sysdate));');
      
        -- Contador para commit    
        vr_contador := vr_contador + 1;
        
        -- Escreve commit        
        if mod(vr_contador,5000) = 0 then
          gene0001.pc_escr_linha_arquivo(vr_utlfile_writer,'commit;');
        end if;
      
      end if;    

    end loop;  
        
  exception
    
    when no_data_found then
      
      gene0001.pc_fecha_arquivo(vr_utlfile_reader);    
      gene0001.pc_escr_linha_arquivo(vr_utlfile_writer,'commit;');            
      gene0001.pc_fecha_arquivo(vr_utlfile_writer);
 
  end;                             

end; 