CREATE OR REPLACE PROCEDURE CECRED.pc_crps204(pr_cdcooper IN crapcop.cdcooper%TYPE --> Codigo Cooperativa
                                      ,pr_flgresta IN PLS_INTEGER --> Flag padrao para utilizacao de restart
                                      ,pr_stprogra OUT PLS_INTEGER --> Saida de termino da execucao
                                      ,pr_infimsol OUT PLS_INTEGER --> Saida de termino da solicitacao
                                      ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Codigo da Critica
                                      ,pr_dscritic OUT VARCHAR2) IS

  /* ..........................................................................
  
     programa: Fontes/pc_crps204.p                    Antigo: Fontes/crps204.p
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor   : Odair
     Data    : Julho/97                        Ultima atualizacao: 09/12/2014
   
     Dados referentes ao programa:
  
     Frequencia: Diario.
     Objetivo  : Atende a solicitacao 002.
                 Listar as capas de lotes de determinados tipos do mes.
                 Emite relatorio 161.
  
     Alteracoes: 21/10/97 - Alterar solicitacao de 39 para 46 e datas de inicio
                            e fim de leitura (Odair).
                            
                 19/07/99 - Alterar a solicitacao de 46 (quinzenal) para
                            02 - diario (Odair) e nao gerar pedido de impressao
                            (Edson).
               
               07/08/2001 - Alterar para nao selecionar mais os lotes tipo 4
                            (Junior).
                            
               10/04/2002 - Mostrar os lotes de c/c referentes a credito de 
                            capital - faixa 1300 (Deborah).
  
               05/01/2006 - Cancelar impressao da Coope 1 (Magui).
               
               16/02/2006 - Unificacao dos bancos - SQLWorks - Eder
               
               25/05/2007 - Retirado vinculacao da execucao do fontes/imprim.p   
                            ao codigo da cooperativa vinculada (Guilherme).
                            
               03/04/2012 - Acerto no estouro de campo em f_lanctos (Ze).
               
               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               09/12/2014 - Conversão Progress >> Oracle PL/SQL (Jéssica DB1)
  ............................................................................. */

  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

  --Constantes
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS204';

  --Variaveis para retorno de erro
  vr_cdcritic INTEGER := 0;
  vr_dscritic VARCHAR2(4000);

  --Variaveis de Excecao
  vr_exc_final  EXCEPTION;
  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;

  aux_dslotmov VARCHAR2(100);
  ------------------------------- VARIAVEIS -------------------------------

  -- Data do movimento
  vr_dtmvtolt crapdat.dtmvtolt%TYPE;

  -- Variáveis para o caminho e nome do arquivo base
  vr_nom_diretorio VARCHAR2(200);

  -- Variaveis para os XMLs e relatórios
  vr_clobxml CLOB; -- Clob para conter o XML de dados

  ------------------------------- CURSORES ---------------------------------

  -- Buscar os dados da cooperativa
  CURSOR cr_crapcop(pr_cdcooper IN craptab.cdcooper%TYPE) IS
    SELECT crapcop.nmrescop,
           crapcop.nrtelura,
           crapcop.dsdircop,
           crapcop.cdbcoctl,
           crapcop.cdagectl,
           crapcop.nrctactl,
           crapcop.cdcooper
      FROM crapcop
     WHERE cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;

  -- Cursor genérico de calendário
  rw_crapdat BTCH0001.CR_CRAPDAT%ROWTYPE;

  -- Buscar as capas de lote
  CURSOR cr_craplot(pr_cdcooper IN craplot.cdcooper%TYPE,
                    pr_dtmvtolt IN craplot.dtmvtolt%TYPE) IS
    SELECT craplot.cdagenci,
           craplot.cdbccxlt,
           craplot.nrdolote,
           craplot.tplotmov,
           craplot.dtmvtolt,
           sum(craplot.vlcompdb) vlcompdb,
           sum(craplot.vlcompcr) vlcompcr,
           sum(craplot.qtcompln) qtcompln
      FROM craplot
     WHERE craplot.cdcooper = pr_cdcooper
       AND craplot.dtmvtolt = pr_dtmvtolt
       AND ((craplot.tplotmov IN (2, 3, 5, 8, 14, 16)) OR
           (craplot.nrdolote > 1200 AND craplot.nrdolote < 1299) OR
           (craplot.nrdolote > 1300 AND craplot.nrdolote < 1399) OR
           (craplot.nrdolote > 2200 AND craplot.nrdolote < 2299))
  GROUP BY craplot.cdagenci,
           craplot.cdbccxlt,
           craplot.nrdolote,
           craplot.tplotmov,
           craplot.dtmvtolt
  ORDER BY craplot.tplotmov,
           craplot.dtmvtolt,
           craplot.cdagenci,
           craplot.nrdolote;

  ----------------------------------------------------------------------
  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB,
                            pr_desdados IN VARCHAR2) IS
  BEGIN
    dbms_lob.writeappend(pr_clobdado, length(pr_desdados), pr_desdados);
  END;

  ---------------------------------------
  -- Inicio Bloco principal pc_crps204 
  ---------------------------------------
BEGIN

  --Limpar parametros saida
  pr_cdcritic := NULL;
  pr_dscritic := NULL;

  -- Incluir nome do modulo logado
  gene0001.pc_informa_acesso(pr_module => 'pc_' || vr_cdprogra,
                             pr_action => vr_cdprogra);

  -- Validações iniciais do programa
  btch0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                            pr_flgbatch => 1,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_cdcritic => vr_cdcritic);
  -- Se ocorreu erro
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  -- Verifica se a cooperativa esta cadastrada
  OPEN cr_crapcop(pr_cdcooper);
  FETCH cr_crapcop
    INTO rw_crapcop;
  -- Verificar se existe informação, e gerar erro caso não exista
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor
    CLOSE cr_crapcop;
    -- Gerar exceção
    vr_cdcritic := 651;
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                               pr_ind_tipo_log => 2, -- Erro tratato
                               pr_des_log      => to_char(SYSDATE,
                                                          'hh24:mi:ss') ||
                                                  ' - ' || vr_cdprogra ||
                                                  ' --> ' || vr_dscritic);
    RAISE vr_exc_saida;
  ELSE
    CLOSE cr_crapcop;
  END IF;

  -- Buscar a data do movimento
  OPEN btch0001.cr_crapdat(pr_cdcooper);
  FETCH btch0001.cr_crapdat
    INTO rw_crapdat;
  -- Verificar se existe informação, e gerar erro caso não exista
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor
    CLOSE btch0001.cr_crapdat;
    -- Gerar exceção
    vr_cdcritic := 1;
    vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    RAISE vr_exc_saida;
  END IF;
  CLOSE btch0001.cr_crapdat;
  vr_dtmvtolt := rw_crapdat.dtmvtolt;

  -- preparar o CLOB para armazenar as infos do arquivo
  dbms_lob.createtemporary(vr_clobxml, true, dbms_lob.call);
  dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
  pc_escreve_clob(vr_clobxml, '<?xml version="1.0" encoding="utf-8"?><raiz>');

  -- Leitura dos lotes
  FOR rw_craplot IN cr_craplot(pr_cdcooper, vr_dtmvtolt) LOOP
  
    IF rw_craplot.tplotmov = 1 THEN
      aux_dslotmov := '1 - LANCAMENTOS DE C/C';
    
    ELSIF rw_craplot.tplotmov = 2 THEN
      aux_dslotmov := '2 - LANCAMENTOS DE CAPITAL';
      
    ELSIF rw_craplot.tplotmov = 3 THEN
      aux_dslotmov := '3 - LANCAMENTOS DE PLANOS';
        
    ELSIF rw_craplot.tplotmov = 5 THEN
      aux_dslotmov := '5 - PAGAMENTO DE EMPRESTIMOS';
          
    ELSIF rw_craplot.tplotmov = 8 THEN
      aux_dslotmov := '8 - CONTRATOS DE CAPITAL';
            
    ELSIF rw_craplot.tplotmov = 14 THEN
      aux_dslotmov := '14 - POUPANCA PROGRAMADA';
              
    ELSIF rw_craplot.tplotmov = 16 THEN
      aux_dslotmov := '16 - PROPOSTAS CREDICARD';
    END IF;
     
  
    --Agrupamento dos movimentos

    pc_escreve_clob(vr_clobxml, 
                           '<refer>'
                           ||'  <aux_dslotmov>'||aux_dslotmov||'</aux_dslotmov>'
                           ||'  <vr_dtmvtolt>'||to_char(to_date(vr_dtmvtolt,'mm/dd/yyyy'),'dd/mm/yyyy')||'</vr_dtmvtolt>'
                           ||'  <dtmvtolt>'||to_char(to_date(rw_craplot.dtmvtolt,'mm/dd/yyyy'),'dd/mm/yyyy')||'</dtmvtolt>' 
                           ||'  <nrdolote>'||trim(gene0002.fn_mask(rw_craplot.nrdolote, 'zzz.zzz'))||'</nrdolote>' 
                           ||'  <cdagenci>'||to_char(rw_craplot.cdagenci, 'fm990')||'</cdagenci>' 
                           ||'  <cdbccxlt>'||to_char(rw_craplot.cdbccxlt, 'fm990')||'</cdbccxlt>' 
                           ||'  <qtcompln>'||to_char(rw_craplot.qtcompln, 'fm999g990')||'</qtcompln>' 
                           ||'  <vlcompdb>'||to_char(rw_craplot.vlcompdb, 'fm999g999g999g990d00')||'</vlcompdb>'
                           ||'  <vlcompcr>'||to_char(rw_craplot.vlcompcr, 'fm999g999g999g990d00')||'</vlcompcr>' 
                           ||'</refer>');
  END LOOP;
  -- Fecha os lotes  
  pc_escreve_clob(vr_clobxml, '</raiz>');

  -- definição do diretório onde o relatório será gerado
  vr_nom_diretorio := gene0001.fn_diretorio('c', -- /usr/coop
                                            pr_cdcooper,
                                            'rl');

  -- solicita o relatório usando o xml
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper, --> cooperativa conectada
                              pr_cdprogra  => vr_cdprogra, --> programa chamador
                              pr_dtmvtolt  => rw_crapdat.dtmvtolt, --> data do movimento atual
                              pr_dsxml     => vr_clobxml, --> arquivo xml de dados (clob)
                              pr_dsxmlnode => '/raiz/refer', --> nó base do xml para leitura dos dados
                              pr_dsjasper  => 'crrl161.jasper', --> arquivo de layout do ireport
                              pr_dsparams  => null, --> array de parametros diversos
                              pr_dsarqsaid => vr_nom_diretorio || '/crrl161.lst', --> arquivo final
                              pr_flg_gerar => 's', --> gerar o arquivo na hora
                              pr_qtcoluna  => 80, --> qtd colunas do relatório (80,132,234)
                              pr_sqcabrel  => 1, --> sequencia do relatorio (cabrel 1..5)  
                              pr_flg_impri => 's', --> chamar a impressão (imprim.p)
                              pr_nmformul  => '80col', --> nome do formulário para impressão
                              pr_nrcopias  => 1, --> número de cópias para impressão
                              pr_des_erro  => vr_dscritic); --> saída com erro

  dbms_lob.close(vr_clobxml);
  dbms_lob.freetemporary(vr_clobxml);

  -- Testar se houve erro
  IF vr_dscritic IS NOT NULL THEN
    -- Gerar exceção
    vr_cdcritic := 0;
    RAISE vr_exc_saida;
  END IF;

  -- Finaliza a execução com sucesso
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                            pr_cdprogra => vr_cdprogra,
                            pr_infimsol => pr_infimsol,
                            pr_stprogra => pr_stprogra);

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
    
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2 -- erro tratato
                                ,
                                 pr_des_log      => to_char(sysdate,
                                                            'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic);
    
    END IF;
  
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);
    -- Efetuar commit pois gravaremos o que foi processo até então
    COMMIT;
  
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas
    pr_cdcritic := NVL(vr_cdcritic, 0);
    pr_dscritic := vr_dscritic;
    -- Efetuar rollback
    ROLLBACK;
  
  WHEN OTHERS THEN
    -- Efetuar retorno do erro não tratado
    pr_cdcritic := 0;
    pr_dscritic := SQLERRM;
    -- Efetuar rollback
    ROLLBACK;
  
END pc_crps204;
/

