CREATE OR REPLACE PACKAGE CECRED."AJUSTA_OBJETO" is

  procedure move_objeto_tablespace;

  procedure grava_comando_indice;

  procedure recria_indice(wp_tablespace_name varchar2);

  procedure recria_indice_paralelo;

  procedure remove_tabela;

  procedure remove_sequence;

end ajusta_objeto;
/

CREATE OR REPLACE PACKAGE BODY CECRED."AJUSTA_OBJETO" is

  procedure move_objeto_tablespace is
  
    cursor c0001 is
      select a.owner, a.table_name, a.tablespace_name
        from cecred.tabela_tablespace a
       order by 1, 2, 3;
  
    r0001 c0001%rowtype;
  
    cursor c0002(pwd_owner           varchar2,
                 pwd_table_name      varchar2,
                 pwd_tablespace_name varchar2) is
      select a.owner,
             a.index_name,
             pwd_tablespace_name || '_I' tablespace_name
        from dba_indexes a
       where a.owner = pwd_owner
         and a.table_name = pwd_table_name
         and a.tablespace_name <> pwd_tablespace_name || '_I'
       order by 1, 2, 3;
  
    cursor c0003 is
      select 'alter table "' || a.owner || '"."' || a.table_name ||
             '" move tablespace ' || a.tablespace_name || '_D' ww_comando
        from cecred.tabela_tablespace a
       where not exists
       (select 1
                from dba_tables b
               where a.owner = b.owner
                 and a.table_name = b.table_name
                 and a.tablespace_name || '_D' = b.tablespace_name)
       order by 1;
  
    r0003 c0003%rowtype;
  
    cursor c0004 is
      select 'alter index "' || a.owner || '"."' || a.index_name ||
             '" rebuild tablespace ' || a.tablespace_name ww_comando
        from cecred.index_tablespace a
       order by 1;
  
    r0004 c0004%rowtype;
  
  begin
  
    execute immediate 'truncate table cecred.log_comando_move';
    execute immediate 'truncate table cecred.index_tablespace';
  
    for r0001 in c0001 loop
    
      for r0002 in c0002(r0001.owner,
                         r0001.table_name,
                         r0001.tablespace_name) loop
      
        insert into cecred.index_tablespace
        values
          (r0002.owner, r0002.index_name, r0002.tablespace_name);
      
      end loop;
    
      commit;
    
    end loop;
  
    for r0003 in c0003 loop
    
      dbms_output.put_line('comando:' || r0003.ww_comando);
      execute immediate r0003.ww_comando;
      insert into log_comando_move
      values
        (cecred.seq_log_comando_move.nextval, r0003.ww_comando);
    
    end loop;
  
    for r0004 in c0004 loop
    
      execute immediate r0004.ww_comando;
      insert into cecred.log_comando_move
      values
        (cecred.seq_log_comando_move.nextval, r0004.ww_comando);
    
    end loop;
  
    commit;
  
    --exception
    --when others then
    -- raise_application_error(-25001,'Erro Geral MOVE_OBJETO_TABLESPACE: '||sqlerrm);
  end move_objeto_tablespace;

  procedure grava_comando_indice is
  
    cursor c0001 is
      select to_char(dbms_metadata.get_ddl('INDEX', a.index_name, a.owner)) ww_comando,
             a.tablespace_name,
             a.owner,
             a.index_name
        from dba_indexes a, tabela_tablespace b
       where a.owner = 'CECRED'
         and a.owner = b.owner
         and a.table_name = b.table_name
       order by 1;
  
    r0001 c0001%rowtype;
  
    cursor c0002 is
      select 'drop index "' || a.owner || '"."' || a.index_name || '"' ww_comando
        from dba_indexes a, tabela_tablespace b
       where a.owner = 'CECRED'
         and a.owner = b.owner
         and a.table_name = b.table_name
      
       order by 1;
  
    r0002 c0002%rowtype;
  
  begin
  
    execute immediate 'truncate table cecred.create_index';
  
    for r0001 in c0001 loop
    
      insert into cecred.create_index
        (owner, index_name, ds_comando, tablespace_name, status, ds_erro)
      values
        (r0001.owner,
         r0001.index_name,
         r0001.ww_comando,
         r0001.tablespace_name,
         null,
         null);
    
    end loop;
  
    commit;
  
    for r0002 in c0002 loop
    
      execute immediate r0002.ww_comando;
    
    end loop;
  
  exception
    when others then
      raise_application_error(-25002,
                              'Erro Geral GRAVA_COMANDO_INDICE: ' ||
                              sqlerrm);
  end grava_comando_indice;

  procedure recria_indice(wp_tablespace_name varchar2) is
  
    cursor c0003 is
      select owner, index_name, tablespace_name, ds_comando
        from cecred.create_index
       where tablespace_name = wp_tablespace_name
         and (status is null or status <> 'OK')
       order by 1, 2;
  
    r0003 c0003%rowtype;
  
    cursor c9999(wp_owner varchar2, wp_index_name varchar2) is
      select owner, index_name, ds_comando
        from (select owner,
                     index_name,
                     tablespace_name,
                     'alter index ' || owner || '.' || index_name ||
                     ' rebuild parallel 18' ds_comando
                from dba_indexes
              union all
              select index_owner,
                     index_name,
                     tablespace_name,
                     'alter index ' || index_owner || '.' || index_name ||
                     ' rebuild partition ' || partition_name ||
                     ' parallel 18' ds_comando
                from dba_ind_partitions
              union all
              select index_owner,
                     index_name,
                     tablespace_name,
                     'alter index ' || index_owner || '.' || index_name ||
                     ' rebuild subpartition ' || subpartition_name ||
                     'parallel 18' ds_comando
                from dba_ind_subpartitions)
       where owner = wp_owner
         and index_name = wp_index_name
         and tablespace_name is not null;
  
    r9999 c9999%rowtype;
  
    ww_cont_erro number;
  
  begin
  
    -- Força Paralelismo DDL na Sessão
    execute immediate 'ALTER SESSION FORCE PARALLEL DDL PARALLEL 18';
  
    for r0003 in c0003 loop
    
      begin
      
        -- Verificar se tem ou não partition - Fernando Klock
        if (INSTR(r0003.ds_comando, '(PARTITION') - 1) < 0 then
        
          execute immediate r0003.ds_comando || ' UNUSABLE';
        
        else
        
          execute immediate substr(r0003.ds_comando,
                                   0,
                                   INSTR(r0003.ds_comando, '(PARTITION') - 1) ||
                            ' UNUSABLE';
        
        end if;
      
        -- Efetua o Rebuild do Indice em Paralelo
        execute immediate 'ALTER INDEX ' || r0003.owner || '.' ||
                          r0003.index_name || ' NOLOGGING parallel 18';
      
        ww_cont_erro := 0;
        for r9999 in c9999(r0003.owner, r0003.index_name) loop
          execute immediate r9999.ds_comando;
        end loop;
      
        execute immediate 'ALTER INDEX ' || r0003.owner || '.' ||
                          r0003.index_name || ' LOGGING parallel 1';
      
        begin
          if ww_cont_erro = 0 then
          
            update cecred.create_index
               set status = 'OK', ds_erro = null
             where owner = r0003.owner
               and index_name = r0003.index_name;
          
            commit;
          
          end if;
        
        exception
          when others then
            raise_application_error(-25033,
                                    'UPDATE CECRED.CREATE_INDEX OK: ' ||
                                    sqlerrm);
        end;
      
      exception
        when others then
          declare
            ww_erro varchar2(500) := sqlerrm;
          begin
            update cecred.create_index
               set status = 'ERRO NOK', ds_erro = ww_erro
             where owner = r0003.owner
               and index_name = r0003.index_name;
          
            commit;
          
            ww_cont_erro := ww_cont_erro + 1;
          
          exception
            when others then
              raise_application_error(-25333,
                                      'UPDATE CECRED.CREATE_INDEX NOK: ' ||
                                      sqlerrm);
          end;
        
      end;
    
    end loop;
  
  end recria_indice;

  procedure recria_indice_paralelo is
  
    cursor c0004 is
      select distinct tablespace_name
        from cecred.create_index
       where status is null
          or status <> 'OK'
       order by 1;
  
    r0004 c0004%rowtype;
  
    ww_cont number := 99999990;
  
  begin
  
    for r0004 in c0004 loop
    
      sys.dbms_job.submit(ww_cont,
                          'CECRED.AJUSTA_OBJETO.RECRIA_INDICE(''' ||
                          R0004.TABLESPACE_NAME || ''');',
                          sysdate,
                          null);
    
      ww_cont := ww_cont + 1;
    
    end loop;
  
    commit;
  
  exception
    when others then
      raise_application_error(-25004,
                              'Erro Geral RECRIA_INDICE_PARALELO: ' ||
                              sqlerrm);
  end recria_indice_paralelo;

  procedure remove_tabela is
  
    cursor c0005 is
      select 'drop table cecred."' || a.table_name || '" purge;' ww_comando
        from cecred.tabela_tablespace a, dba_tables b
       where a.owner = b.owner
         and a.table_name = b.table_name
       order by 1;
  
    r0005 c0005%rowtype;
  
  begin
  
    for r0005 in c0005 loop
      --execute immediate r0005.ww_comando;
      dbms_output.put_line(r0005.ww_comando);
    
    end loop;
  
  exception
    when others then
      raise_application_error(-25003,
                              'Erro para dropar a tabela: ' || sqlerrm);
    
  end remove_tabela;

  procedure remove_sequence is
  
    cursor c0006 is
      select 'drop sequence cecred."' || a.object_name || '";' ww_comando
        from dba_objects a
       where a.owner = 'CECRED'
         and a.object_type = 'SEQUENCE'
       order by 1;
  
    r0006 c0006%rowtype;
  
  begin
  
    for r0006 in c0006 loop
      --execute immediate r0006.ww_comando;
      dbms_output.put_line(r0006.ww_comando);
    
    end loop;
  
  exception
    when others then
      raise_application_error(-25003,
                              'Erro para dropar a sequence: ' || sqlerrm);
    
  end remove_sequence;

end ajusta_objeto;
/

