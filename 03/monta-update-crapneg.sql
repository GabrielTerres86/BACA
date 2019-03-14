declare

  -- Busca cooperativa
  cursor cr_crapcop (pr_cdagectl in crapcop.cdagectl%type) is
  select cop.cdcooper
       , cop.cdbcoctl
    from crapcop cop
   where cop.cdagectl = pr_cdagectl;
  rw_crapcop cr_crapcop%rowtype;   
  
  -- Busca conta do associado
  cursor cr_crapass (pr_cdcooper in crapass.cdcooper%type
                    ,pr_nrdconta in crapass.nrdconta%type) is
  select ass.*
    from crapass ass
   where ass.cdcooper = pr_cdcooper
     and ass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%rowtype;   
  
  -- Busca registro para atualizacao  
  cursor cr_crapneg (pr_cdcooper in crapneg.cdcooper%type
                    ,pr_cdbcoctl in crapcop.cdbcoctl%type
                    ,pr_nrdconta in crapneg.nrdconta%type
                    ,pr_dtiniest in crapneg.dtiniest%type
                    ,pr_cdobserv in crapneg.cdobserv%type
                    ,pr_nrcheque in crapneg.nrdocmto%type) is 
  select negg.rowid
    from crapneg negg
   where negg.cdcooper = pr_cdcooper
     and negg.cdbanchq = pr_cdbcoctl
     and negg.nrdconta = pr_nrdconta 
     and negg.dtiniest = pr_dtiniest 
     and negg.cdobserv = pr_cdobserv
     and to_number(substr(lpad(negg.nrdocmto,7,0),1,6)) = pr_nrcheque
     and negg.flgctitg = 1
     and negg.dtectitg = to_date('08/02/2019','dd/mm/yyyy');
  rw_crapneg cr_crapneg%rowtype;      

  -- Variaveis da crapneg
  aux_nrdconta crapneg.nrdconta%type;
  aux_nrcheque crapneg.nrdocmto%type;
  aux_dtiniest crapneg.dtiniest%type; 
  aux_cdmotivo crapneg.cdobserv%type;

  -- Variaveis de controle
  vr_exc_saida exception;
  vr_texto     varchar2(4000);
  vr_utlfile   utl_file.file_type;
  vr_nmarqdat  varchar2(200) := 'CCF61701.995';
  vr_dscritic  varchar2(4000);  
  vr_nmdireto  varchar2(100) := '/microsd3/cpd/bacas/INC0033067';  
    
begin
  
  -- Define tamanho do buffer
  dbms_output.enable(buffer_size => null);

  -- Abre arquivo para edicao
  gene0001.pc_abre_arquivo(pr_nmdireto => vr_nmdireto
                          ,pr_nmarquiv => vr_nmarqdat
                          ,pr_tipabert => 'R'
                          ,pr_utlfileh => vr_utlfile
                          ,pr_des_erro => vr_dscritic);
                          
  if trim(vr_dscritic) is not null then
    dbms_output.put_line(vr_dscritic||' - Erro ao abrir arquivo.');
    raise vr_exc_saida;
  end if;                          
    
  begin          
    
    loop  
                
      -- Varre linhas do arquivo
      gene0001.pc_le_linha_arquivo(vr_utlfile,vr_texto);
                           
      -- Ignora registros de outros bancos           
      if nvl(substr(replace(vr_texto,'',''),18,3),0) <> '085' then      
        continue;
      end if;
    
      -- Popula variaveis
      begin    
        aux_nrdconta := to_number(substr(vr_texto,25,12));
        aux_nrcheque := to_number(substr(vr_texto,37,6));
        aux_cdmotivo := to_number(substr(vr_texto,60,2));
        aux_dtiniest := to_date(lpad(to_number(substr(vr_texto,68,2)),2,0)||'/'||
                                lpad(to_number(substr(vr_texto,66,2)),2,0)||'/'||
                                to_number(substr(vr_texto,62,4)),'dd/mm/rrrr');      
      exception
        when others then
          dbms_output.put_line(vr_texto||' - Erro ao definir parâmetros.');
          continue;           
      end;                                       
         
      -- Busca cooperativa    
      open cr_crapcop (to_number(substr(vr_texto,21,4)));
      fetch cr_crapcop into rw_crapcop;
    
      -- Imprime registros invalidos    
      if cr_crapcop%notfound then
        dbms_output.put_line(vr_texto||' - Cooperativa não encontrada.');
        close cr_crapcop;
        continue;      
      end if;
    
      close cr_crapcop;

      -- Busca associado
      open cr_crapass (rw_crapcop.cdcooper
                      ,aux_nrdconta);
      fetch cr_crapass into rw_crapass;   
     
      -- Imprime registros invalidos    
      if cr_crapass%notfound then
        dbms_output.put_line(vr_texto||' - Conta não encontrada.');
        close cr_crapass;
        continue;      
      end if;
     
     close cr_crapass;                 
         
      -- Busca associado
      open cr_crapneg (rw_crapcop.cdcooper
                      ,rw_crapcop.cdbcoctl
                      ,aux_nrdconta
                      ,aux_dtiniest
                      ,aux_cdmotivo                      
                      ,aux_nrcheque);
      fetch cr_crapneg into rw_crapneg;  
    
      -- Cria atualizacao do registro
      if cr_crapneg%found then
        update crapneg
          set flgctitg = 2
        where flgctitg = 1
          and cdcooper = rw_crapcop.cdcooper
          and cdbanchq = rw_crapcop.cdbcoctl
          and nrdconta = aux_nrdconta
          and dtiniest = to_date(aux_dtiniest,'dd/mm/rrrr')
          and cdobserv = aux_cdmotivo
          and dtectitg = to_date('08/02/2019','dd/mm/yyyy')
          and to_number(substr(lpad(nrdocmto,7,0),1,6)) = aux_nrcheque; 
      end if;    
    
      close cr_crapneg;     
    
    end loop;
  exception  
    when no_data_found then
      gene0001.pc_fecha_arquivo(vr_utlfile); 
  end;      
  
  ---------- Planilha - Jailton - Compe ---------- 
  update crapneg set flgctitg = 2 where flgctitg = 1 and cdcooper = 1 and nrdconta = 8751587 and nrdocmto = 604 and rowid = 'AAAS9aAB9AAAEZdAAA'; 
  update crapneg set flgctitg = 2 where flgctitg = 1 and cdcooper = 1 and nrdconta = 7950934 and nrdocmto = 35 and rowid = 'AAAS9aAB9AAAEZdAAD';
  update crapneg set flgctitg = 2 where flgctitg = 1 and cdcooper = 1 and nrdconta = 8686955 and nrdocmto = 396 and rowid = 'AAAS9aAB9AAAEZdAAC';
  update crapneg set flgctitg = 2 where flgctitg = 1 and cdcooper = 7 and nrdconta = 135119 and nrdocmto = 345 and rowid = 'AAAS9aAB9AAAEZdAAB';
  commit;

exception
  when others then  
    dbms_output.put_line('Erro não tratado: '||sqlerrm);             
end;