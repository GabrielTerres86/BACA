CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS343(pr_cdcooper  IN crapcop.cdcooper%TYPE
                                      ,pr_flgresta  IN PLS_INTEGER
                                      ,pr_stprogra OUT PLS_INTEGER
                                      ,pr_infimsol OUT PLS_INTEGER
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE
                                      ,pr_dscritic OUT VARCHAR2) AS
/* .............................................................................

   Programa: PC_CRPS343                      Antigo -> Fontes/crps343.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2003.                     Ultima atualizacao: 27/07/2017

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 005.
               Criar base da comp. eletronica dos cheques descontados.

   Alteracoes: 19/12/2003 - Alterado para NAO gerar base de compensacao com a
                            data 31/12 (Edson).

               30/06/2005 - Alimentado campo cdcooper da tabela crapchd (Diego).

               21/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               17/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               20/03/2007 - Corrigir atualizacao crapchd.nrctachq (Magui).

               19/12/2013 - Conversão Progress -> Oracle (Gabriel).
               
               27/07/2017 - #704386 Logar informações da chave única da tabela 
                            crapchd ao falhar o insert e não interromper o 
                            programa (Carlos)
............................................................................. */
  -- Variaveis de uso no programa
  vr_cdprogra crapprg.cdprogra%TYPE := 'CRPS343';  -- Codigo do presente programa
  vr_nmrescop crapcop.nmrescop%TYPE;               -- Nome da cooperativa
  vr_dstextab        VARCHAR2(50);                 -- Descrição da craptab
  vr_vlchqmai        NUMBER(10,2);                 -- Valor cheque maior
  vr_dtmvtopr        DATE;                         -- Proxima data util
  vr_nrctachq        NUMBER(20);                   -- Numero conta cheque
  vr_tpdmovto        NUMBER(1);                    -- Tipo de movimento
  vr_nrdcampo        NUMBER(20);                   -- Validacao do cmc7
  vr_lsdigctr        VARCHAR2(200);                -- Lista digitos do cmc7
  vr_cdcritic        crapcri.cdcritic%TYPE;        -- Codigo da critica
  vr_dscritic        VARCHAR2(2000);               -- Descricao da critica
  vr_idprglog        NUMBER := 0;
  vr_exc_saida       EXCEPTION;                    -- Exeption parar cadeia
  vr_exc_fimprg      EXCEPTION;                    -- Exception para rodar fimprf

  -- Cursor da cooperativa logada
  CURSOR cr_crapcop (pr_cdcooper crapcop.cdcooper%TYPE) IS
    SELECT cop.nmrescop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;

  -- Cursor de Cheques contidos do Bordero de desconto de cheques
  CURSOR cr_crapcdb (pr_cdcooper crapcop.cdcooper%TYPE
                    ,pr_dtmvtolt crapdat.dtmvtolt%TYPE
                    ,pr_dtmvtopr crapdat.dtmvtopr%TYPE) IS
    SELECT cdb.vlcheque
          ,cdb.dsdocmc7
          ,cdb.inchqcop
          ,cdb.cdagechq
          ,cdb.cdbccxlt
          ,cdb.cdcmpchq
          ,cdb.cdoperad
          ,cdb.insitchq
          ,cdb.nrcheque
          ,cdb.cdbanchq
          ,cdb.nrctachq
          ,cdb.nrdconta
          ,cdb.nrddigc1
          ,cdb.nrddigc2
          ,cdb.nrddigc3
          ,cdb.nrdocmto
          ,cdb.nrseqdig
     FROM crapcdb cdb
    WHERE cdb.cdcooper =  pr_cdcooper  -- Codigo da cooperativa
      AND cdb.dtlibera >  pr_dtmvtolt  -- Data da liberacao
      AND cdb.dtlibera <= pr_dtmvtopr  -- Data da liberacao
      AND cdb.insitchq = 2             -- Cheque Processado
      AND cdb.dtdevolu IS NULL;        -- Sem data de devolucao

  -- Dados da data da cooperativa logada
  rw_crapdat btch0001.cr_crapdat%rowtype;

  -- Dados da craptab
  rw_crapcdb cr_crapcdb%rowtype;

BEGIN

  -- Incluir nome do módulo logado
  gene0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra
                            ,pr_action => NULL);

  -- Obter os dados da cooperativa logada
  OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);

  FETCH cr_crapcop INTO vr_nmrescop;

  -- Se cooperativa nao encontrada, gera critica para o log
  IF  cr_crapcop%notfound   THEN

    vr_cdcritic := 651;

    CLOSE cr_crapcop;

    RAISE vr_exc_saida;

  END IF;

  CLOSE cr_crapcop;

  -- Obter dados da data da cooperativa
  OPEN btch0001.cr_crapdat (pr_cdcooper => pr_cdcooper);

  FETCH btch0001.cr_crapdat INTO rw_crapdat;

  -- Se nao exisitir a data da cooperativa, obter critica e jogar para o log
  IF  btch0001.cr_crapdat%notfound  THEN

    vr_cdcritic := 1;

    CLOSE btch0001.cr_crapdat;

    RAISE vr_exc_saida;

  END IF;

  CLOSE btch0001.cr_crapdat;

  -- Realizar as validacoes do iniprg
  btch0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper,
                             pr_flgbatch => 1,
                             pr_cdprogra => vr_cdprogra,
                             pr_infimsol => pr_infimsol,
                             pr_cdcritic => vr_cdcritic);

  -- Se possui critica, buscar a descricao e jogar ao log
  IF  vr_cdcritic <> 0  THEN

    RAISE vr_exc_saida;

  END IF;

  -- Tabela com valores dos maiores cheques
  vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                           ,pr_nmsistem => 'CRED'
                                           ,pr_tptabela => 'USUARI'
                                           ,pr_cdempres => 11
                                           ,pr_cdacesso => 'MAIORESCHQ'
                                           ,pr_tpregist => 1);
  -- Se não achou, aborta execução
  IF  vr_dstextab IS NULL  THEN
    vr_cdcritic := 55;
    RAISE vr_exc_saida;
  END IF;

  -- Obter valor cheque maior
  vr_vlchqmai := to_number(substr(vr_dstextab,1,15));

  -- Proxima data util
  vr_dtmvtopr := rw_crapdat.dtmvtopr;

  -- Se for final de ano, somar mais um dia e pegar o proxima dia util
  IF  to_char(vr_dtmvtopr,'dd') = 31  AND
      to_char(vr_dtmvtopr,'mm') = 12  THEN
    vr_dtmvtopr := vr_dtmvtopr + 1;
    vr_dtmvtopr := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                              ,pr_dtmvtolt => vr_dtmvtopr);
  END IF;

  -- Percorre cheques contidos do bordero de desconto de cheques
  FOR rw_crapcdb IN cr_crapcdb (pr_cdcooper => pr_cdcooper
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_dtmvtopr => rw_crapdat.dtmvtopr) LOOP

    -- Obter numero da conta cheque
    IF  rw_crapcdb.cdbanchq = 1  AND
        rw_crapcdb.inchqcop = 0  THEN
      vr_nrctachq := to_number(substr(rw_crapcdb.dsdocmc7,23,10));
    ELSE
      vr_nrctachq := rw_crapcdb.nrctachq;
    END IF;

    -- Obter tipo de movimento
    IF  vr_vlchqmai <= rw_crapcdb.vlcheque  THEN
      vr_tpdmovto := 1;
    ELSE
      vr_tpdmovto := 2;
    END IF;

    -- Retorna os digitos CMC 7
    cheq0001.pc_dig_cmc7 (pr_dsdocmc7 => rw_crapcdb.dsdocmc7
                         ,pr_nrdcampo => vr_nrdcampo
                         ,pr_lsdigctr => vr_lsdigctr);

    BEGIN

      -- Cheques acolhidos para depositos nas contas dos associados.
      INSERT INTO crapchd (cdagechq
                          ,cdagenci
                          ,cdbanchq
                          ,cdbccxlt
                          ,cdcmpchq
                          ,cdoperad
                          ,cdsitatu
                          ,dsdocmc7
                          ,dtmvtolt
                          ,inchqcop
                          ,insitchq
                          ,nrcheque
                          ,nrctachq
                          ,nrdconta
                          ,nrddigc1
                          ,nrddigc2
                          ,nrddigc3
                          ,nrddigv1
                          ,nrddigv2
                          ,nrddigv3
                          ,nrdocmto
                          ,nrdolote
                          ,nrseqdig
                          ,nrterfin
                          ,cdtipchq
                          ,tpdmovto
                          ,vlcheque
                          ,cdcooper)
                   VALUES (rw_crapcdb.cdagechq
                          ,1  -- PAC
                          ,rw_crapcdb.cdbanchq
                          ,rw_crapcdb.cdbccxlt
                          ,rw_crapcdb.cdcmpchq
                          ,rw_crapcdb.cdoperad
                          ,1  -- Situacao atual
                          ,rw_crapcdb.dsdocmc7
                          ,vr_dtmvtopr
                          ,rw_crapcdb.inchqcop
                          ,rw_crapcdb.insitchq
                          ,rw_crapcdb.nrcheque
                          ,vr_nrctachq
                          ,rw_crapcdb.nrdconta
                          ,rw_crapcdb.nrddigc1
                          ,rw_crapcdb.nrddigc2
                          ,rw_crapcdb.nrddigc3
                          ,gene0002.fn_busca_entrada(1,vr_lsdigctr,',')
                          ,gene0002.fn_busca_entrada(2,vr_lsdigctr,',')
                          ,gene0002.fn_busca_entrada(3,vr_lsdigctr,',')
                          ,rw_crapcdb.nrdocmto
                          ,888888  -- Numero do lote
                          ,rw_crapcdb.nrseqdig
                          ,0       -- Numero do terminal financeiro
                          ,to_number(substr(rw_crapcdb.dsdocmc7,20,1)) -- Tipificacao do cheque
                          ,vr_tpdmovto  -- Tipo de movimento para troca eletronica de documentos
                          ,rw_crapcdb.vlcheque
                          ,pr_cdcooper);
    EXCEPTION

      -- Tratamento de erro na inserção
      WHEN OTHERS THEN
        cecred.pc_log_programa(PR_DSTIPLOG      => 'E', 
                               PR_CDPROGRAMA    => vr_cdprogra, 
                               pr_cdcooper      => pr_cdcooper, 
                               pr_tpocorrencia  => 2, 
                               pr_cdcriticidade => 1, 
                               pr_dsmensagem => 'Erro na inserção da crapchd. ' || sqlerrm ||
                                                ' cdcooper: ' || pr_cdcooper         ||
                                                ' dtmvtopr: ' || vr_dtmvtopr         ||
                                                ' cdcmpchq: ' || rw_crapcdb.cdcmpchq ||
                                                ' cdbanchq: ' || rw_crapcdb.cdbanchq ||
                                                ' cdagechq: ' || rw_crapcdb.cdagechq ||
                                                ' nrctachq: ' || vr_nrctachq         ||
                                                ' nrcheque: ' || rw_crapcdb.nrcheque,
                               PR_IDPRGLOG => vr_idprglog);
    END;

  END LOOP;

  COMMIT;

EXCEPTION

  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Se foi gerada critica para envio ao log
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      -- Envio centralizado de log de erro

      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                ,pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                 || vr_cdprogra || ' --> '
                                                 || vr_dscritic );

    END IF;
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;

  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic,0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;

  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := sqlerrm;
    -- Efetuar rollback
    ROLLBACK;

END PC_CRPS343;
/
