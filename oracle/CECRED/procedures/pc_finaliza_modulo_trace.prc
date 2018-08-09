CREATE OR REPLACE PROCEDURE CECRED.pc_finaliza_modulo_trace (pr_dsnmexe in VARCHAR2
                                                            ,pr_caminho in VARCHAR2)  
IS
/*
  Programa : pc_finaliza_modulo_trace
  Sistema : Todos
  Autor   : Desconhecido
  Data    : Mes/Ano                   Ultima atualizacao: 19/12/2017  

  Objetivo  : Finalizar as operações de Trace.
  
  Alterações: 
  
  19/12/2017 - Inclusão do comando PRAGMA
               (Belli - Envolti - Chamado 816992)
*/  
  -- Inclusão do comando PRAGMA - 19/12/2017 - Chamado 816992
  PRAGMA AUTONOMOUS_TRANSACTION;  
  
  vr_typ_said    varchar2(4);
  vr_des_erro    varchar2(4000);
  vr_caminho_trc varchar2(4000);
  vr_comando     varchar2(4000);
  vr_data_arq    varchar2(15) := to_char(sysdate, 'yyyymmdd_hh24miss');
  vr_sessionid   varchar2(10) := sys_context('USERENV','SESSIONID');

BEGIN
  select value
    into vr_caminho_trc
    from v$parameter
   where name = 'user_dump_dest';
   -----

  -- Desabilita o TRACE na sessão
  execute immediate 'alter session set events ''10046 trace name context off''';
  --

  -- Agrupa arquivos de trace caso tenha sido gerado mais de um (ex: trace de comando com PARALLEL QUERY)
  vr_comando := 'trcsess output='||vr_caminho_trc||'/trcsess_PERFORMANCE_'||pr_dsnmexe||'.tmp clientid='||vr_sessionid||' '||vr_caminho_trc||'/*PERFORMANCE_'||pr_dsnmexe||'.trc ';
  gene0001.pc_OScommand_Shell(pr_des_comando => vr_comando,
                              pr_typ_saida   => vr_typ_said,
                              pr_des_saida   => vr_des_erro);
  if vr_typ_said = 'ERR' then
    raise_application_error(-20002, vr_des_erro);
  end if;

  -- Converte o arquivo TRC gerado (binário) para arquivo texto (também com extensão TRC), já no local de destino
  vr_comando := 'tkprof '||vr_caminho_trc||'/trcsess_PERFORMANCE_'||pr_dsnmexe||'.tmp '||pr_caminho||'/'||pr_dsnmexe||'_'||vr_data_arq||'.trc sys=no';
  gene0001.pc_OScommand_Shell(pr_des_comando => vr_comando,
                              pr_typ_saida   => vr_typ_said,
                              pr_des_saida   => vr_des_erro);
  if vr_typ_said = 'ERR' then
    raise_application_error(-20003, vr_des_erro);
  end if;
  
  -- Gera um novo arquivo texto, contendo apenas as linhas de total, para facilitar a identificação das queries mais demoradas
  vr_comando := 'grep -e "^call" '||pr_caminho||'/'||pr_dsnmexe||'_'||vr_data_arq||'.trc | head -1 > '||pr_caminho||'/'||pr_dsnmexe||'_'||vr_data_arq||'_totais.trc ';
  gene0001.pc_OScommand_Shell(pr_des_comando => vr_comando,
                              pr_typ_saida   => vr_typ_said,
                              pr_des_saida   => vr_des_erro);
  if vr_typ_said = 'ERR' then
    raise_application_error(-20004, vr_des_erro);
  end if;

  vr_comando := 'grep -e "^total" '||pr_caminho||'/'||pr_dsnmexe||'_'||vr_data_arq||'.trc >> '||pr_caminho||'/'||pr_dsnmexe||'_'||vr_data_arq||'_totais.trc';
  gene0001.pc_OScommand_Shell(pr_des_comando => vr_comando,
                              pr_typ_saida   => vr_typ_said,
                              pr_des_saida   => vr_des_erro);
  if vr_typ_said = 'ERR' then
    raise_application_error(-20004, vr_des_erro);
  end if;

  COMMIT;
    
EXCEPTION
  when others then
    raise_application_error(-20001, 'Erro ao habilitar o TRACE: '||sqlerrm);
END;
/
