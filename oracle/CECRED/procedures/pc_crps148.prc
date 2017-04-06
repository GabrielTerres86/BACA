CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS148" (pr_cdcooper in crapcop.cdcooper%TYPE
                     ,pr_flgresta  IN PLS_INTEGER            --> Indicador para utilização de restart
                     ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                     ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                     ,pr_cdcritic out crapcri.cdcritic%TYPE
                     ,pr_dscritic out varchar2) is
/* ..........................................................................

   Programa: pc_crps148 (antigo Fontes/crps148.p)
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Abril/96.                      Ultima atualizacao: 05/04/2017

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 5 (Finalizacao do processo).
               Calcula as aplicacoes RPP aniversariantes.
               Nao gera relatorio.

   Alteracoes: 27/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               27/09/2004 - Aumentado nro digitos nrctrrpp(Mirtes)

               16/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre
               04/06/2008 - Alterado para nao considerar cdsitrpp = 5 (poupanca
                            baixada pelo vencimento)  no for each na craprpp.
                            (Rosangela)

               28/06/2013 - Conversão Progress >> Oracle PL/SQL (Daniel-Supero)

               25/11/2013 - Ajustes na passagem dos parâmetros para restart (Marcos-Supero)

               27/05/2015 - Realizando a retirada dos tratamentos de restart, pois o programa
                            apresentou erros no processo batch. Os códigos foram comentados e 
                            podem ser removidos em futuras alterações do fonte. (Renato - Supero)
                            
               05/04/2017 - #455742 Melhorias de performance. Ajuste de passagem dos parâmetros inpessoa e 
                            nrcpfcgc para não consultar novamente o associado no pkg apli0001 (Carlos)
............................................................................. */
  -- Poupança programada
  cursor cr_craprpp (pr_cdcooper in craprpp.cdcooper%type,
                     pr_dtmvtopr in craprpp.dtfimper%type) is
    select craprpp.nrdconta,
           craprpp.nrctrrpp,
           craprpp.rowid,
           crapass.inpessoa,
           crapass.nrcpfcgc
      from craprpp, crapass
     where craprpp.cdcooper  = pr_cdcooper
       and craprpp.dtfimper <= pr_dtmvtopr
       and craprpp.incalmes  = 0
       and craprpp.cdsitrpp <> 5
       AND craprpp.cdcooper = crapass.cdcooper
       AND craprpp.nrdconta = crapass.nrdconta
     order by craprpp.nrdconta,
              craprpp.nrctrrpp;
  -- Registro para armazenar as datas
  rw_crapdat     btch0001.cr_crapdat%rowtype;
  -- Exception para tratamento de erros tratáveis sem abortar a execução
  vr_exc_mensagem  exception;
  -- Código do programa
  vr_cdprogra      crapprg.cdprogra%type;
  -- Data do movimento
  vr_dtmvtopr      crapdat.dtmvtopr%type;
  vr_inproces      crapdat.inproces%type;
  --Informacoes tabelas genericas
  vr_prcaplic      craptab.dstextab%type;
  -- Saldo calculado da poupança
  vr_vlsdrdpp      craprpp.vlsdrdpp%type := 0;
  -- Variáveis para controle de reprocesso
  vr_dsrestar      crapres.dsrestar%type;
  vr_inrestar      number(1);
  -- Tratamento de erros
  vr_exc_erro      exception;
begin
  vr_cdprogra := 'CRPS148';
  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_CRPS148',
                             pr_action => vr_cdprogra);
  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => pr_cdcritic);
  -- Se retornou algum erro
  if pr_cdcritic <> 0 then
    -- Buscar descrição do erro
    pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    -- Envio centralizado de log de erro
    raise vr_exc_erro;
  end if;

  -- Buscar a data do movimento
  open btch0001.cr_crapdat(pr_cdcooper);
    fetch btch0001.cr_crapdat into rw_crapdat;
    if btch0001.cr_crapdat%notfound then
      -- Fechar o cursor pois haverá raise
      close btch0001.cr_crapdat;
      pr_cdcritic:= 1;
      -- Montar mensagem de critica
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
      raise vr_exc_erro;
    else
      -- Atribuir a proxima data do movimento
      vr_dtmvtopr := rw_crapdat.dtmvtopr;
      -- Atribuir o indicador de processo
      vr_inproces := rw_crapdat.inproces;
    end if;
  close btch0001.cr_crapdat;

  -- Buscar o percentual de IR da aplicação
  vr_prcaplic := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                            pr_nmsistem => 'CRED',
                                            pr_tptabela => 'CONFIG',
                                            pr_cdempres => 0,
                                            pr_cdacesso => 'PERCIRAPLI',
                                            pr_tpregist => 0);

  -- Buscar informações de reprocesso
  /*btch0001.pc_valida_restart (pr_cdcooper,
                              vr_cdprogra,
                              pr_flgresta,
                              vr_nrctares,
                              vr_dsrestar,
                              vr_inrestar,
                              pr_cdcritic,
                              pr_dscritic);
  if pr_dscritic is not null then
    raise vr_exc_erro;
  end if;*/

  -- Buscar informações da poupança programada
  for rw_craprpp in cr_craprpp (pr_cdcooper,
                                vr_dtmvtopr) loop
    /*if vr_inrestar > 0 and
       rw_craprpp.nrdconta = vr_nrctares and
       rw_craprpp.nrctrrpp <= to_number(vr_dsrestar) then
      continue;
    end if;*/
    -- Executa cálculo de poupança (antigo poupanca.i)
    apli0001.pc_calc_poupanca (pr_cdcooper => pr_cdcooper,          --> Cooperativa
                               pr_dstextab => vr_prcaplic,          --> Percentual de IR da aplicação
                               pr_cdprogra => vr_cdprogra,          --> Programa chamador
                               pr_inproces => vr_inproces,          --> Indicador do processo
                               pr_dtmvtolt => rw_crapdat.dtmvtolt,  --> Data do processo
                               pr_dtmvtopr => vr_dtmvtopr,          --> Próximo dia útil
                               pr_rpp_rowid => rw_craprpp.rowid,    --> Identificador do registro da tabela CRAPRPP em processamento
                               pr_vlsdrdpp => vr_vlsdrdpp,          --> Saldo da poupança programada
                               pr_inpessoa => rw_craprpp.inpessoa,
                               pr_nrcpfcgc => rw_craprpp.nrcpfcgc,
                               pr_cdcritic => pr_cdcritic,          --> Código da critica de erro
                               pr_des_erro => pr_dscritic);         --> Descrição do erro encontrado
    if pr_dscritic is not null or pr_cdcritic is not null then
      raise vr_exc_erro;
    end if;
    -- Atualiza controle de reprocesso
    /*begin
      update crapres
         set crapres.nrdconta = rw_craprpp.nrdconta
       where crapres.cdcooper = pr_cdcooper
         and crapres.cdprogra = vr_cdprogra;
      if sql%rowcount = 0 then
        pr_cdcritic := 151;
        pr_dscritic := gene0001.fn_busca_critica(151);
        --
        raise vr_exc_erro;
      end if;
    exception
      when others then
        pr_cdcritic := 0;
        pr_dscritic := 'Erro ao atualizar controle de reprocesso: '||sqlerrm;
        raise vr_exc_erro;
    end;
    --
    commit;*/
  end loop;
  -- Eliminar controle de reprocesso
  /*btch0001.pc_elimina_restart(pr_cdcooper,
                              vr_cdprogra,
                              pr_flgresta,
                              pr_dscritic);
  if pr_dscritic is not null then
    pr_cdcritic := 0;
    raise vr_exc_erro;
  end if;*/
  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);
  --
  commit;
exception
  when vr_exc_erro then
    -- Se foi retornado apenas código
    IF pr_cdcritic > 0 AND pr_dscritic IS NULL THEN
      -- Buscar a descrição
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic);
    END IF;
    -- Desfazer as alterações
    rollback;
  when others then
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Desfazer as alterações
    rollback;
END;
/
