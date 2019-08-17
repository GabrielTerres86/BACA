PL/SQL Developer Test script 3.0
224
declare
  cursor cr_craplem is    
    select craplem.cdcooper,
           craplem.nrdconta, 
           craplem.dtmvtolt, 
           sum(craplem.vllanmto) vloperacao
      from craplem, crapass a
     where craplem.cdhistor in (2330, 2331, 2334, 2335)
       and craplem.dtmvtolt between '01/01/2018' and '31/12/2018'
       and craplem.cdcooper = a.cdcooper
       and craplem.nrdconta = a.nrdconta
       and a.inpessoa = 1
     
     group by craplem.cdcooper, craplem.nrdconta,craplem.dtmvtolt
       order by 1, 2;

  cursor cr_crapdir is
    select *
  from (select d.cdcooper,
               d.nrdconta,
               sum(a.vloperacao) vloperacao,
               max(d.vlprepag) vlprepag
          from crapdir d, tbcc_operacoes_diarias a, crapass ass
         where d.cdcooper = a.cdcooper
           and d.nrdconta = a.nrdconta
           and ass.cdcooper = a.cdcooper
           and ass.nrdconta = a.nrdconta
           and ass.inpessoa = 1
           and a.cdoperacao = 21
           and a.dtoperacao between '01/01/2018' and '31/12/2018'
           and d.dtmvtolt = '31/12/2018'
         group by d.cdcooper, d.nrdconta) t
 where nvl(t.vloperacao, 0) <> nvl(t.vlprepag, 0);  
  rw_crapdir cr_crapdir%rowtype;
  
  
  vr_nrdconta_ant     number;
  vr_cdcooper_ant     number;
  vr_vloperac         number;
  vr_dsxmldad_dir     CLOB;
  vr_dsxmldad_operac  CLOB;
  vr_des_erro         varchar2(4000);
  vr_caminho          varchar2(200) := '/micros/cecred/odirlei';
  vr_vlprepag_novo number;
  
  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_csv_dir (pr_des_dados IN VARCHAR2) IS
  BEGIN
    dbms_lob.writeappend(vr_dsxmldad_dir,length(pr_des_dados||chr(10)),pr_des_dados||chr(10));
  END;
  
  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_operac (pr_des_dados IN VARCHAR2) IS
  BEGIN
    dbms_lob.writeappend(vr_dsxmldad_operac,length(pr_des_dados||chr(10)),pr_des_dados||chr(10));
  END;
  
begin


  dbms_lob.createtemporary(vr_dsxmldad_dir, TRUE);
  dbms_lob.open(vr_dsxmldad_dir, dbms_lob.lob_readwrite);
  
  dbms_lob.createtemporary(vr_dsxmldad_operac, TRUE);
  dbms_lob.open(vr_dsxmldad_operac, dbms_lob.lob_readwrite);


  vr_nrdconta_ant := 0;
  vr_cdcooper_ant := 0;
  vr_vloperac     := 0;
  vr_vlprepag_novo := 0;
  for rw_craplem in cr_craplem loop
  
    if vr_nrdconta_ant <> rw_craplem.nrdconta or 
       vr_cdcooper_ant <> rw_craplem.cdcooper then
       
      if vr_nrdconta_ant > 0 then 
      --> Atualizar crapdir
      
        begin
          update crapdir d
             set d.vlprepag = d.vlprepag + vr_vloperac
           where d.cdcooper = vr_cdcooper_ant
             and d.nrdconta = vr_nrdconta_ant
             and d.dtmvtolt = to_date('31/12/2018','DD/MM/RRRR')
             returning vlprepag into vr_vlprepag_novo;
        end;
        
        if sql%rowcount = 0 then
          raise_application_error(-20500,'Nao encontrou registro para atualização '||vr_cdcooper_ant||'-'||vr_nrdconta_ant);        
        end if;
        
        pc_escreve_csv_dir(vr_cdcooper_ant||';'||vr_nrdconta_ant||';'||'31/12/2018'||';'||vr_vloperac||';'||vr_vlprepag_novo);
        
       
      end if;
      vr_nrdconta_ant := rw_craplem.nrdconta; 
      vr_cdcooper_ant := rw_craplem.cdcooper;   
      vr_vlprepag_novo := 0; 
      vr_vloperac      := 0;
        
    end if;     
  
  
    begin
      insert into tbcc_operacoes_diarias 
                  ( cdcooper, 
                    nrdconta, 
                    cdoperacao, 
                    dtoperacao, 
                    nrsequen, 
                    vloperacao)
           values ( rw_craplem.cdcooper, 
                    rw_craplem.nrdconta, 
                    21, --cdoperacao
                    rw_craplem.dtmvtolt, --dtoperacao, 
                    0, --nrsequen
                    rw_craplem.vloperacao);            
    exception
      --> gravar sequencial 1
      when dup_val_on_index  then
        begin 
        insert into tbcc_operacoes_diarias 
                  ( cdcooper, 
                    nrdconta, 
                    cdoperacao, 
                    dtoperacao, 
                    nrsequen, 
                    vloperacao)
           values ( rw_craplem.cdcooper, 
                    rw_craplem.nrdconta, 
                    21, --cdoperacao
                    rw_craplem.dtmvtolt, --dtoperacao, 
                    1, --nrsequen
                    rw_craplem.vloperacao);   
        exception
           when dup_val_on_index  then
            insert into tbcc_operacoes_diarias 
                      ( cdcooper, 
                        nrdconta, 
                        cdoperacao, 
                        dtoperacao, 
                        nrsequen, 
                        vloperacao)
               values ( rw_craplem.cdcooper, 
                        rw_craplem.nrdconta, 
                        21, --cdoperacao
                        rw_craplem.dtmvtolt, --dtoperacao, 
                        2, --nrsequen
                        rw_craplem.vloperacao);   
        end;             
    end;
    
    pc_escreve_operac(rw_craplem.cdcooper||';'||rw_craplem.nrdconta||';'||rw_craplem.dtmvtolt||';'||rw_craplem.vloperacao);
        
    
    vr_vloperac := nvl(vr_vloperac,0) + nvl(rw_craplem.vloperacao,0);
    
  end loop;  
  
  begin
    raise_application_error(-20500,'erro')  ;
  exception
    when others then
      null;   
  
  end;
  
  if vr_nrdconta_ant > 0 then 
    --> Atualizar crapdir
      
    begin
      update crapdir d
         set d.vlprepag = d.vlprepag + vr_vloperac
       where d.cdcooper = vr_cdcooper_ant
         and d.nrdconta = vr_nrdconta_ant
         and d.dtmvtolt = to_date('31/12/2018','DD/MM/RRRR')
         returning vlprepag into vr_vlprepag_novo;
    end;
        
    if sql%rowcount = 0 then
      raise_application_error(-20500,'Nao encontrou registro para atualização '||vr_cdcooper_ant||'-'||vr_nrdconta_ant);        
    end if;
        
    pc_escreve_csv_dir(vr_cdcooper_ant||';'||vr_nrdconta_ant||';'||'31/12/2018'||';'||vr_vloperac||';'||vr_vlprepag_novo);
        
       
  end if;

  
  -- Criar o arquivo no diretorio especificado
  gene0002.pc_clob_para_arquivo(pr_clob => vr_dsxmldad_dir, 
                                pr_caminho => vr_caminho, 
                                pr_arquivo => 'dir_PF.csv',  
                                pr_des_erro => vr_des_erro);

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_dsxmldad_dir);
  dbms_lob.freetemporary(vr_dsxmldad_dir);
    
  gene0002.pc_clob_para_arquivo(pr_clob => vr_dsxmldad_operac, 
                                pr_caminho => vr_caminho, 
                                pr_arquivo => 'operac_PF.csv',  
                                pr_des_erro => vr_des_erro);

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_dsxmldad_operac);
  dbms_lob.freetemporary(vr_dsxmldad_operac);

 
  for rw_crapdir in cr_crapdir loop
    dbms_output.put_line(rw_crapdir.cdcooper||';'||rw_crapdir.nrdconta||';'||rw_crapdir.vloperacao||';'||rw_crapdir.vlprepag);  
  end loop;
   open cr_crapdir;  
  if cr_crapdir%found then
    close cr_crapdir;
    rollback;
    raise_application_error(-20500,'Valores diferentes');  
  
  end if;
  close cr_crapdir;


end;
0
0
