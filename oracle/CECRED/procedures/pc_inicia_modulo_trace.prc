CREATE OR REPLACE PROCEDURE CECRED.pc_inicia_modulo_trace(pr_dsnmexe varchar2) IS
  vr_typ_said    varchar2(4);
  vr_des_erro    varchar2(4000);
  vr_caminho     varchar2(4000);
  vr_comando     varchar2(4000);
  vr_sessionid   varchar2(10) := sys_context('USERENV','SESSIONID');

BEGIN
  -- Busca o caminho onde o TRACE é gerado
  select value
    into vr_caminho
    from v$parameter
   where name = 'user_dump_dest';

  -- Remove arquivos de TRACE antigos para o mesmo programa
  vr_comando := 'rm '||vr_caminho||'/*PERFORMANCE_'||pr_dsnmexe||'.*';
  gene0001.pc_OScommand_Shell(pr_des_comando => vr_comando,
                              pr_typ_saida   => vr_typ_said,
                              pr_des_saida   => vr_des_erro);
  -- define um IDENTIFICADOR para o trace
  dbms_session.set_identifier(vr_sessionid);

  -- Habilita o TRACE na sessão
  execute immediate 'alter session set statistics_level=all';
  execute immediate 'alter session set tracefile_identifier=PERFORMANCE_'||pr_dsnmexe;
  execute immediate 'alter session set max_dump_file_size=UNLIMITED';
  execute immediate 'alter session set events ''10046 trace name context forever, level 12''';

  gene0001.pc_informa_acesso(pr_module => pr_dsnmexe,pr_action => null);

EXCEPTION
  when others then
    raise_application_error(-20001, 'Erro ao habilitar o TRACE: '||sqlerrm);
END;
/
