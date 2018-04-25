declare

  vr_continua boolean;

  vr_posicao_atual number(4);

  vr_posicao_final number(4);

  vr_permissao varchar2(1);

  vr_nmdatela varchar2(10) := 'ATACOR'; --*********************************
  vr_nrmodulo number(1):= 1;                     --********************************* 
  vr_idevento number(1):= 3;                     --*********************************
  vr_idambace number(1):= 2;                     --*********************************

  vr_existe number(1);

  vr_restricao_liberacao varchar2(1000) := null; --*********************************

  type vr_typ_teste_restricao is REF CURSOR;

  vr_cur_teste_restricao_var vr_typ_teste_restricao;

  vr_cdoperad crapope.cdoperad%type;

  vr_sql varchar2(1000);

  vr_aux varchar2(1000);

  -- Operadores do Credito - todas permissões
  TYPE vr_typ_operad_credito IS VARRAY(6) OF VARCHAR2(8); -- --*********************************

  vr_vet_operad_credito vr_typ_operad_credito := vr_typ_operad_credito('F0030622',
                                                                       'F0030879',
                                                                       'F0030546',
                                                                       'F0030754',
                                                                       'F0031251',
                                                                       'F0030544');
                                                          --*********************************
begin
  -- Liberar acessos ATVPRB - todas permissões

  for a in 1 .. 6 loop--*********************************
  
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
      
      dbms_output.put_line('Libera:'|| vr_cdoperad);
      
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
                     vr_nrmodulo,
                     vr_idevento,
                     vr_idambace,
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
