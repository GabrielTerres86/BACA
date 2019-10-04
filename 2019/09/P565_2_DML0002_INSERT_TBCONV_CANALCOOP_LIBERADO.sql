declare

  vr_idseqconvelib number := null;
  vr_idsequencia   number := null;
  vr_ativo         number := null;   
  
  /*
DELETE Tbconv_Canalcoop_Liberado;
DELETE TBCONV_LIBERACAO;
COMMIT;
*/
/*
select * from TBCONV_LIBERACAO t;
select * from Tbconv_Canalcoop_Liberado*/
  
  --Convênios AILOS
  cursor cr_gnconve is  
    select 3  tparrecd, 
           'AILOS' dstparrecd,
           gnconve.cdconven,
           gnconve.cdcooper,--3 - ailos
           gnconve.flgativo,
           gnconve.cdhiscxa,
           gnconve.cdhisdeb,           
           gnconve.intpconvenio,
           decode(gnconve.intpconvenio,1,'ARRECADAÇÃO',2,'DEBITO AUTOMATICO',3,'ARRECADAÇÃO/DEBITO AUTOMATICO',gnconve.intpconvenio) dsintpconvenio
      from gnconve
     where gnconve.intpconvenio is not null
       --and gnconve.cdconven = 48
     order by gnconve.intpconvenio;
     
  --Convênios BANCOOB
  cursor cr_tbconv_arrecadacao is
    select t.tparrecadacao tparrecd, 
           'BANCOOB' dstparrecd,
           t.cdempres cdconven,
           1 flgativo,
           1 intpconvenio, --(para o bancoob só existe tipo de convenio de arrecadação)
           'ARRECADAÇÃO' dsintpconvenio, 
           t.cdempcon,
           t.cdsegmto,
           crapcon.cdcooper           
      from tbconv_arrecadacao t,
           crapcon, 
           crapcop c
     where t.cdempcon = crapcon.cdempcon
       and t.cdsegmto = crapcon.cdsegmto
       and crapcon.cdcooper = c.cdcooper
       and c.flgativo = 1
       and t.cdempres is not null
       and t.tparrecadacao = 2 --bancoob  
       --and t.cdempres = 24756  
     order by t.cdempres, c.cdcooper;
     
  --Cooperativas ativas   
  cursor cr_crapcop is
    select crapcop.cdcooper
      from crapcop 
     where crapcop.flgativo = 1
     ORDER BY crapcop.cdcooper;   
  
  --Arrecadação (AILOS)  
  cursor cr_crapcon( pr_cdhiscxa number
                    ,pr_cdcooper number
                    ,pr_tparrecd number) is
    select crapcon.tparrecd,
           decode(crapcon.tparrecd,1,'SICREDI',2,'BANCOOB',3,'AILOS',crapcon.tparrecd) dstparrecd,--Tipo de arrecadacao efetuada na cooperativa (1-Sicredi/ 2-Bancoob/ 3-Cecred)
           crapcon.cdcooper,
           crapcon.cdsegmto,
           decode(crapcon.cdsegmto,1,' - Prefeituras' 
                                  ,2,' - Saneamento'
                                  ,3,' - Energia Elétria e Gás'
                                  ,4,' - Telecomunicações'
                                  ,5,' - Orgãos Governamentais'
                                  ,6,' - Orgãos identificados através do CNPJ'
                                  ,7,' - Multas de Trânsito'
                                  ,9,' - Uso interno do banco',crapcon.cdsegmto) dscdsegmto,
           crapcon.cdempcon,
           crapcon.NMRESCON           
      from crapcon
     where crapcon.cdhistor = pr_cdhiscxa
       and crapcon.tparrecd = pr_tparrecd --2-Bancoob e 3-AILOS
       and crapcon.cdcooper = pr_cdcooper;
   
  --Canais  
  cursor cr_canal is
    select t.cdcanal,t.nmcanal 
      from tbgen_canal_entrada t
     where t.cdcanal in(2,3,4); 
  
  --Verificar se já existe o Convênio 
  cursor cr_liberacao(pr_tparrecd  tbconv_liberacao.tparrecadacao%type, 
                      pr_cdcooper  tbconv_liberacao.cdcooper%type, 
                      pr_cdconven  tbconv_liberacao.cdcooper%type) is
     select t.idseqconvelib
       from tbconv_liberacao t
      where t.tparrecadacao = pr_tparrecd
        and t.cdcooper = pr_cdcooper
        and ((pr_tparrecd = 3 and t.cdconven = pr_cdconven)
            or(pr_tparrecd = 2 and t.cdempres = pr_cdconven));
  
  --Verificar se já existe o Canal    
  cursor cr_libcanal( pr_idseqconvelib tbconv_canalcoop_liberado.idsequencia%type,
                      pr_cdsegmto      tbconv_canalcoop_liberado.cdsegmto%type, 
                      pr_cdempcon      tbconv_canalcoop_liberado.cdempcon%type, 
                      pr_cdcanal       tbconv_canalcoop_liberado.cdcanal%type) is
    select t.idsequencia 
      from tbconv_canalcoop_liberado t                          
     where t.idseqconvelib = pr_idseqconvelib
       and t.cdsegmto = pr_cdsegmto
       and t.cdempcon = pr_cdempcon
       and t.cdcanal  = pr_cdcanal; 
     
begin
  --------------------------------------------------------------------
  --Convênios BANCOOB
  --------------------------------------------------------------------
  dbms_output.put_line(' ------------------BANCOOB ------------------------------- ');
      
  for rw_conve in cr_tbconv_arrecadacao loop
     
    dbms_output.put_line('   Convênio: '|| rw_conve.cdconven 
                          || ' Cooper.: '||rw_conve.cdcooper
                          || ' - '||rw_conve.dsintpconvenio);
               
    --Inserir Liberação por cooperativa
    vr_idseqconvelib := null; 
    open cr_liberacao(rw_conve.tparrecd, rw_conve.cdcooper, rw_conve.cdconven);
    fetch cr_liberacao into vr_idseqconvelib;
    close cr_liberacao;  
    if vr_idseqconvelib is null then
      --INSERIR tbconv_liberacao    
      begin            
        insert into tbconv_liberacao
          (idseqconvelib, tparrecadacao, cdcooper, cdempres, cdconven, flgautdb)
        values
          (tbconv_liberacao_seq.nextval, rw_conve.tparrecd, rw_conve.cdcooper, rw_conve.cdconven, 0, 0)
         returning tbconv_liberacao.idseqconvelib INTO vr_idseqconvelib;        
      exception
        when others then
          dbms_output.put_line('Erro ao inserir na tabela tbconv_liberacao - '
             || ' tparrecd: '|| rw_conve.tparrecd
             || ' cdcooper: '|| rw_conve.cdcooper
             || ' cdempres: '|| rw_conve.cdconven
             || ' intpconvenio: '|| rw_conve.intpconvenio
             || sqlerrm);      
      end;
          
      /*dbms_output.put_line('        Cadastro na tabela tbconv_liberacao - '
             || ' tparrecd: '|| rw_conve.tparrecd
             || ' cdcooper: '|| rw_conve.cdcooper
             || ' cdconven: '|| rw_conve.cdconven
             || ' intpconvenio: '|| rw_conve.intpconvenio);*/
    else
      --Atualizar a tbconv_liberacao 
      begin            
        update tbconv_liberacao
           set flgautdb = 0
         where idseqconvelib = vr_idseqconvelib;                   
      exception
        when others then
          dbms_output.put_line('Erro ao atualizar na tabela tbconv_liberacao - '
             || ' tparrecd: '|| rw_conve.tparrecd
             || ' cdcooper: '|| rw_conve.cdcooper
             || ' cdconven: '|| rw_conve.cdconven
             || ' intpconvenio: '|| rw_conve.intpconvenio
             || sqlerrm);      
      end; 
        
      /*dbms_output.put_line('    Cadastro na tabela tbconv_liberacao - '
             || ' tparrecd: '|| rw_conve.tparrecd
             || ' cdcooper: '|| rw_conve.cdcooper
             || ' cdconven: '|| rw_conve.cdconven
             || ' intpconvenio: '|| rw_conve.intpconvenio);*/
                  
    end if;
      
    --Se TipoConvênio for 1 - arrecadação OU 3-arrecadacao/deb.aut.
    if rw_conve.intpconvenio in(1,3) and vr_idseqconvelib is not null then
        
      --Inserir os canais   
      for rw_canais in cr_canal loop
             
        vr_idsequencia := null; 
        open cr_libcanal(vr_idseqconvelib,rw_conve.cdsegmto, rw_conve.cdempcon, rw_canais.cdcanal); 
        fetch cr_libcanal into vr_idsequencia;   
        if cr_libcanal%notfound then
          --inserir tbconv_canalcoop_liberado 
          begin
            insert into tbconv_canalcoop_liberado
              (idsequencia, idseqconvelib, cdsegmto, cdempcon, cdcanal, flgliberado)
            values
              (tbconv_canalcoop_liberado_seq.nextval, vr_idseqconvelib, rw_conve.cdsegmto, rw_conve.cdempcon, rw_canais.cdcanal, 1);
          exception
            when others then
              dbms_output.put_line('Erro ao inserir na tabela tbconv_canalcoop_liberado - '          
               || ' vr_idseqconvelib: '|| vr_idseqconvelib
               || ' cdsegmto: '|| rw_conve.cdsegmto
               || ' cdempcon: '||rw_conve.cdempcon
               || ' cdcanal: '|| rw_canais.cdcanal
               || sqlerrm);     
          end;              
        else
          --Atualizar tbconv_canalcoop_liberado
          begin
            update tbconv_canalcoop_liberado
               set flgliberado = 1
             where idsequencia = vr_idsequencia; 
           
          exception
            when others then
              dbms_output.put_line('Erro ao atualizar na tabela tbconv_canalcoop_liberado - '          
               || ' vr_idseqconvelib: '|| vr_idseqconvelib
               || ' cdsegmto: '|| rw_conve.cdsegmto
               || ' cdempcon: '||rw_conve.cdempcon
               || ' cdcanal: '|| rw_canais.cdcanal
               || sqlerrm);     
          end;  
        end if; 
        close cr_libcanal;
            
        /*dbms_output.put_line('            Canais - '          
               || ' vr_idseqconvelib: '|| vr_idseqconvelib
               || ' cdsegmto: '|| rw_conve.cdsegmto
               || ' cdempcon: '||rw_conve.cdempcon
               || ' cdcanal: '|| rw_canais.cdcanal);*/
                   
      end loop; --Fim Canais -      
    end if;--Fim TipoConvênio for 1 - arrecadação OU 3-arrecadacao/deb.aut.              
  end loop;  --Fim Convênio
  --
  commit;
  --------------------------------------------------------------------
  --Convênios AILOS
  --------------------------------------------------------------------
  dbms_output.put_line(' ------------------AILOS   ------------------------------- ');
  
  for rw_gnconve in cr_gnconve loop
    
    dbms_output.put_line('Convênio: '|| rw_gnconve.cdconven || ' - '|| rw_gnconve.dstparrecd
                          || ' Cooperativa: '|| rw_gnconve.cdcooper
                          || ' Ativo: '|| rw_gnconve.flgativo
                          || ' Tipo Convênio: '||rw_gnconve.intpconvenio||' - '||rw_gnconve.dsintpconvenio);
               
    --Cooperativas Ativas
    for rw_crapcop in cr_crapcop loop
      
      dbms_output.put_line('    Cooperativa - crapcop.cdcooper: '|| rw_crapcop.cdcooper );
      
      --Regra para Ativas Canais/Deb.Aut.  - 3 = AILOS
      if rw_gnconve.cdcooper = 3 then
        if rw_gnconve.flgativo = 1 then
          vr_ativo := 1;
        else
          vr_ativo := 0;
        end if;    
      else
        --Replicar para todas as coopertivas, mas Ativar apenas para a propria cooperativa
        if rw_crapcop.cdcooper = rw_gnconve.cdcooper and rw_gnconve.flgativo = 1 then
          vr_ativo := 1;
        else
          vr_ativo := 0;        
        end if;
      end if;
      
      --Inserir Liberação por cooperativa
      vr_idseqconvelib := null; 
      open cr_liberacao(rw_gnconve.tparrecd, rw_crapcop.cdcooper, rw_gnconve.cdconven);
      fetch cr_liberacao into vr_idseqconvelib;
      close cr_liberacao;  
      if vr_idseqconvelib is null then
        --INSERIR tbconv_liberacao    
        begin            
          insert into tbconv_liberacao
            (idseqconvelib, tparrecadacao, cdcooper, cdempres, cdconven, flgautdb)
          values
            (tbconv_liberacao_seq.nextval, rw_gnconve.tparrecd, rw_crapcop.cdcooper, 0, rw_gnconve.cdconven, decode(rw_gnconve.intpconvenio,3,vr_ativo,2,vr_ativo,0))
           returning tbconv_liberacao.idseqconvelib INTO vr_idseqconvelib;        
        exception
          when others then
            dbms_output.put_line('Erro ao inserir na tabela tbconv_liberacao - '
               || ' tparrecd: '|| rw_gnconve.tparrecd
               || ' cdcooper: '|| rw_crapcop.cdcooper
               || ' cdconven: '|| rw_gnconve.cdconven
               || ' intpconvenio: '|| rw_gnconve.intpconvenio
               || sqlerrm);      
        end;
          
       /* dbms_output.put_line('        Cadastro na tabela tbconv_liberacao - '
               || ' tparrecd: '|| rw_gnconve.tparrecd
               || ' cdcooper: '|| rw_crapcop.cdcooper
               || ' cdconven: '|| rw_gnconve.cdconven
               || ' intpconvenio: '|| rw_gnconve.intpconvenio);*/
      else
        --Atualizar a tbconv_liberacao 
        begin            
          update tbconv_liberacao
             set flgautdb = decode(rw_gnconve.intpconvenio,3,vr_ativo,2,vr_ativo,0)
           where idseqconvelib = vr_idseqconvelib;                   
        exception
          when others then
            dbms_output.put_line('Erro ao atualizar na tabela tbconv_liberacao - '
               || ' tparrecd: '|| rw_gnconve.tparrecd
               || ' cdcooper: '|| rw_crapcop.cdcooper
               || ' cdconven: '|| rw_gnconve.cdconven
               || ' intpconvenio: '|| rw_gnconve.intpconvenio
               || sqlerrm);      
        end; 
        
        /*dbms_output.put_line('    Cadastro na tabela tbconv_liberacao - '
               || ' tparrecd: '|| rw_gnconve.tparrecd
               || ' cdcooper: '|| rw_crapcop.cdcooper
               || ' cdconven: '|| rw_gnconve.cdconven
               || ' intpconvenio: '|| rw_gnconve.intpconvenio);*/
                  
      end if;
      
      --Se TipoConvênio for 1 - arrecadação OU 3-arrecadacao/deb.aut.
      if rw_gnconve.intpconvenio in(1,3) and vr_idseqconvelib is not null then
        --Busca na crapcon
        for rw_crapcon in cr_crapcon(rw_gnconve.cdhiscxa
                                    ,rw_crapcop.cdcooper
                                    ,rw_gnconve.tparrecd )loop
          --Inserir os canais   
          for rw_canais in cr_canal loop
             
            vr_idsequencia := null; 
            open cr_libcanal(vr_idseqconvelib,rw_crapcon.cdsegmto, rw_crapcon.cdempcon, rw_canais.cdcanal); 
            fetch cr_libcanal into vr_idsequencia;   
            if cr_libcanal%notfound then
              --inserir tbconv_canalcoop_liberado 
              begin
                insert into tbconv_canalcoop_liberado
                  (idsequencia, idseqconvelib, cdsegmto, cdempcon, cdcanal, flgliberado)
                values
                  (tbconv_canalcoop_liberado_seq.nextval, vr_idseqconvelib, rw_crapcon.cdsegmto, rw_crapcon.cdempcon, rw_canais.cdcanal, vr_ativo);
              exception
                when others then
                  dbms_output.put_line('Erro ao inserir na tabela tbconv_canalcoop_liberado - '          
                   || ' vr_idseqconvelib: '|| vr_idseqconvelib
                   || ' cdsegmto: '|| rw_crapcon.cdsegmto
                   || ' cdempcon: '||rw_crapcon.cdempcon
                   || ' cdcanal: '|| rw_canais.cdcanal
                   || sqlerrm);     
              end;              
            else
              --Atualizar tbconv_canalcoop_liberado
              begin
                update tbconv_canalcoop_liberado
                   set flgliberado = vr_ativo
                 where idsequencia = vr_idsequencia; 
           
              exception
                when others then
                  dbms_output.put_line('Erro ao atualizar na tabela tbconv_canalcoop_liberado - '          
                   || ' vr_idseqconvelib: '|| vr_idseqconvelib
                   || ' cdsegmto: '|| rw_crapcon.cdsegmto
                   || ' cdempcon: '||rw_crapcon.cdempcon
                   || ' cdcanal: '|| rw_canais.cdcanal
                   || sqlerrm);     
              end;  
            end if; 
            close cr_libcanal;
            
           /* dbms_output.put_line('            Canais - '          
                   || ' vr_idseqconvelib: '|| vr_idseqconvelib
                   || ' cdsegmto: '|| rw_crapcon.cdsegmto
                   || ' cdempcon: '||rw_crapcon.cdempcon
                   || ' cdcanal: '|| rw_canais.cdcanal);*/
                   
          end loop; --Fim Canais -      
        end loop;--Fim  Arrecadação - crapcon
        
      end if;--Fim TipoConvênio for 1 - arrecadação OU 3-arrecadacao/deb.aut.              
      
    end loop;  --Fim Cooperativas ativas
  end loop; --Fim Convênio
  commit;
end;     
