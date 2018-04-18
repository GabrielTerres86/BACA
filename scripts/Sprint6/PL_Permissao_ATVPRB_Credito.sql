declare

  vr_continua boolean;

  vr_posicao_atual number(4);

  vr_posicao_final number(4);

  vr_permissao varchar2(1);

  vr_nmdatela varchar2(10) := 'ATVPRB'; --*********************************

  vr_existe number(1);

  vr_restricao_liberacao varchar2(1000) := '@CH'; --*********************************

  type vr_typ_teste_restricao is REF CURSOR;

  vr_cur_teste_restricao_var vr_typ_teste_restricao;

  vr_cdoperad crapope.cdoperad%type;

  vr_sql varchar2(1000);

  vr_aux varchar2(1000);

  -- Operadores do Credito - todas permissões
  TYPE vr_typ_operad_credito IS VARRAY(20) OF VARCHAR2(8); -- --*********************************

  vr_vet_operad_credito vr_typ_operad_credito := vr_typ_operad_credito('F0030066',
                                                                       'F0030978',
                                                                       'F0030584',
                                                                       'F0030513',
                                                                       'F0030542',
                                                                       'F0031809',
                                                                       'F0030539',
                                                                       'F0031403',
                                                                       'F0030835',
                                                                       'F0030688',
                                                                       'F0030537',
                                                                       'F0031810',
                                                                       'F0030517',
                                                                       'F0030827',
                                                                       'F0031090',
                                                                       'F0031089',
                                                                       'F0030516',
                                                                       'F0030521',
                                                                       'F0031401',
                                                                       'F0031803');
  /*
    vr_vet_operad_credito vr_typ_operad_credito := vr_typ_operad_credito(
  'F0030973','F0030173','F0030622','F0030213',
  'F0030976','F0031108','F0030879','F0030482',
  'F0030619','F0031646','F0030878','F0030544',  
  'F0031251','F0030546','F0031265'  
  );
  */
  /*   -- Operadores do Recuperação e Jurídico - somente permissões @ C H
     TYPE vr_typ_operad_demais IS VARRAY(15) OF VARCHAR2(8); -- define o tipo do vetor 
     vr_vet_operad_demais vr_typ_operad_demais := vr_typ_operad_demais('F0030973','F0030622','F0030976','F0030879',
                                                                       'F0030619','F0030878','F0030544','F0031251',
                                                                       'F0030546','F0031265','F0030173','F0030213',
                                                                       'F0031108','F0030482','F0031646');
  */
begin
  -- Liberar acessos ATVPRB - todas permissões

  for a in 1 .. 20 loop
  
    vr_cdoperad := vr_vet_operad_credito(a);
  
    begin
      select 1
        into vr_existe
        from dual
       where exists
       (select 1 from crapope a where a.cdoperad = vr_cdoperad);
    exception
      when no_Data_found then
        vr_existe := 0;
    end;
  
    if vr_existe = 0 then
      begin
        select 1
          into vr_existe
          from dual
         where exists
         (select 1 from crapope a where a.cdoperad = lower(vr_cdoperad));
      exception
        when no_Data_found then
          vr_existe := 0;
      end;
      if vr_existe = 0 then
        dbms_output.put_line('*****************************Não existe:' || vr_cdoperad);
      
      else
      
        dbms_output.put_line('Libera:' || vr_cdoperad);
      
        for cur_cooper in (select a.cdopptel, a.cdcooper
                             from craptel a
                            where a.nmdatela = vr_nmdatela
                            order by a.cdcooper) loop
        
          vr_continua := true;
        
          vr_posicao_atual := 1;
        
          vr_posicao_final := length(cur_cooper.cdopptel);
        
          while vr_continua loop
          
            if vr_posicao_atual > vr_posicao_final then
              vr_continua := false;
            else
              vr_permissao := substr(cur_cooper.cdopptel,
                                     vr_posicao_atual,
                                     1);
            
              if vr_restricao_liberacao is not null then
                vr_sql := 'select instr (' || '''' ||
                          vr_restricao_liberacao || '''' || ',' || '''' ||
                          vr_permissao || '''' || ') from dual';
                --              dbms_output.put_line(vr_sql);
              
                open vr_cur_teste_restricao_var for vr_sql;
              
                fetch vr_cur_teste_restricao_var
                  into vr_aux;
              
                close vr_cur_teste_restricao_var;
              
              end if;
            
              if vr_restricao_liberacao is not null and vr_aux = 0 then
                dbms_output.put_line('Permissão ' || vr_permissao ||
                                     ' não será liberada');
                vr_posicao_atual := vr_posicao_atual + 2;
              else
              
                -- grava a permissão
                dbms_output.put_line('Grava : ' || vr_permissao ||
                                     ' coop: ' || cur_cooper.cdcooper);
                begin
                  insert into crapace
                    (nmdatela,
                     cddopcao,
                     cdoperad,
                     nmrotina,
                     cdcooper,
                     nrmodulo,
                     idevento,
                     idambace,
                     progress_recid)
                  values
                    (vr_nmdatela,
                     vr_permissao,
                     vr_cdoperad,
                     ' ',
                     cur_cooper.cdcooper,
                     1,
                     5,
                     2,
                     null);
                exception
                  when dup_val_on_index then
                    dbms_output.put_line('Registro já existe');
                end;
                vr_posicao_atual := vr_posicao_atual + 2;
              end if;
            end if;
          end loop;
        end loop;
      end if;
    end if;
  end loop;
end;

commit;