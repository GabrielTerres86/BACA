CREATE OR REPLACE PROCEDURE CECRED.pc_crps455 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                              ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                                              ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  /* .............................................................................

     Programa: pc_crps455     (Fontes/crps455.p)
     Sistema : Conta-Corrente - Cooperativa de Credito
     Sigla   : CRED
     Autor(a): Diego/Mirtes
     Data    : Agosto/2005.                      Ultima atualizacao: 30/03/2015
     
     Dados referentes ao programa:

     Frequencia: Diario.
     Objetivo  : Emite relatorio para acompanhamento e analise dos cheques
                 de outros Bancos devolvidos fora do prazo regular de 
                 liberacao (380) - Solicitacao 2.

     Alteracoes: 12/09/2005 - Acrescentados campos PAC, BANCO, AGENCIA e
                              SALDO (Diego).                           
                              
                 17/02/2006 - Unificacao dos Bancos de Dados - SQLWorks - Andre

                 15/03/2006 - Efetuar acerto indice/leitura crapchd(Mirtes)
                 
                 29/01/2007 - Alterado formato dos campos do tipo DATE de
                              "99/99/99" para "99/99/9999" (Elton).

                 23/01/2009 - Incluir codigo da alinea (Gabriel). 
                 
                 16/08/2013 - Nova forma de chamar as agencias, de PAC agora 
                              a escrita será PA (André Euzébio - Supero).
                              
                 08/10/2014 - Efetuado tratamento para depositos intercooperativas
                              (Reinert).
                              
                 30/03/2015 - Conversão Progress -> Oracle (Odirlei-AMcom)             

  ............................................................................ */


  ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

  -- Código do programa
  vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS455';

  -- Tratamento de erros
  vr_exc_saida  EXCEPTION;
  vr_exc_fimprg EXCEPTION;
  vr_cdcritic   PLS_INTEGER;
  vr_dscritic   VARCHAR2(4000);

  ------------------------------- CURSORES ---------------------------------

  -- Busca dos dados da cooperativa
  CURSOR cr_crapcop IS
    SELECT cop.nmrescop
          ,cop.nmextcop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
  rw_crapcop cr_crapcop%ROWTYPE;
  -- Cursor genérico de calendário
  rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
  CURSOR cr_craplcm (pr_cdcooper craplcm.cdcooper%TYPE,
                     pr_dtmvtolt craplcm.dtmvtolt%TYPE) IS 
    SELECT /*+index (craplcm CRAPLCM##CRAPLCM4)*/
           craplcm.nrdocmto
          ,craplcm.cdcoptfn
          ,craplcm.cdbanchq
          ,craplcm.cdagechq
          ,craplcm.cdcmpchq
          ,craplcm.nrctachq
          ,craplcm.dtmvtolt
          ,craplcm.nrdconta
          ,craplcm.cdpesqbb
          ,craplcm.vllanmto
      FROM craplcm craplcm
     WHERE craplcm.cdcooper = pr_cdcooper
       AND craplcm.dtmvtolt = pr_dtmvtolt
       AND craplcm.cdhistor = 351 -- DEV.CH.DEP.
       ORDER BY craplcm.nrdconta;
  
  CURSOR cr_crapchd ( pr_cdcooper craplcm.cdcooper%TYPE,
                      pr_cdbanchq craplcm.cdbanchq%TYPE,
                      pr_cdagechq craplcm.cdagechq%TYPE,
                      pr_cdcmpchq craplcm.cdcmpchq%TYPE,
                      pr_nrctachq craplcm.nrctachq%TYPE,
                      pr_nrdocmto craplcm.nrdocmto%TYPE,
                      pr_dtmvtolt craplcm.dtmvtolt%TYPE,
                      pr_cdcoptfn craplcm.cdcoptfn%TYPE,
                      pr_nrdconta craplcm.nrdconta%TYPE) IS 
    SELECT /*+index_asc (crapchd crapchd##crapchd4)*/
           crapchd.nrdocmto
          ,crapchd.dtmvtolt
          ,crapchd.cdbanchq
          ,crapchd.cdagechq
      FROM crapchd
     WHERE crapchd.cdcooper = pr_cdcooper
       AND crapchd.cdbanchq = pr_cdbanchq
       AND crapchd.cdagechq = pr_cdagechq
       AND crapchd.cdcmpchq = pr_cdcmpchq
       AND crapchd.nrctachq = pr_nrctachq
       AND crapchd.nrcheque = pr_nrdocmto
       AND crapchd.dtmvtolt < pr_dtmvtolt
       -- se possuir a informação de coop. casch, buscar pelo numero da conta destino
       AND ((crapchd.nrctadst = pr_nrdconta AND pr_cdcoptfn <> 0) OR
            -- senap buscar no numero da conta
            (crapchd.nrdconta = pr_nrdconta AND pr_cdcoptfn = 0)
            );
  rw_crapchd cr_crapchd%ROWTYPE;
  
  -- buscar dados do associado
  CURSOR cr_crapass ( pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
    SELECT crapass.cdagenci
          ,crapsld.vlsddisp
      FROM crapass, crapsld 
    WHERE crapsld.cdcooper = crapass.cdcooper    
      AND crapsld.nrdconta = crapass.nrdconta
      AND crapass.cdcooper = pr_cdcooper    
      AND crapass.nrdconta = pr_nrdconta;
  rw_crapass cr_crapass%ROWTYPE; 
  
  -- Buscar Depositos Bloqueados - D15
  CURSOR cr_crapdpb ( pr_cdcooper crapass.cdcooper%TYPE,
                      pr_dtmvtolt crapchd.dtmvtolt%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE,
                      pr_nrdocmto crapchd.nrdocmto%TYPE) IS
    SELECT crapdpb.nrdocmto
          ,crapdpb.dtliblan
      FROM crapdpb
     WHERE crapdpb.cdcooper = pr_cdcooper
       AND crapdpb.dtliblan > pr_dtmvtolt
       AND crapdpb.nrdconta = pr_nrdconta
       AND crapdpb.nrdocmto = pr_nrdocmto;
     

  ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

  ------------------------------- VARIAVEIS -------------------------------
  -- Variáveis para armazenar as informações em XML
  vr_des_xml         CLOB;
  -- Variável para armazenar os dados do XML antes de incluir no CLOB
  vr_texto_completo  VARCHAR2(32600);
  -- diretorio de geracao do relatorio
  vr_nom_direto  VARCHAR2(100);
  -- Nome do relatorio    
  vr_nmarqimp   VARCHAR2(100) := 'crrl380.lst'; 
  
  -- variaeis de controle
  vr_nrdocmto craplcm.nrdocmto%TYPE;
  vr_fcrapchd BOOLEAN;
  vr_fcrapass BOOLEAN;
  vr_nrdconta craplcm.nrdconta%TYPE := 0;
  
  
  --------------------------- SUBROTINAS INTERNAS --------------------------
  -- Subrotina para escrever texto na variável CLOB do XML
  PROCEDURE pc_escreve_xml(pr_des_dados IN VARCHAR2,
                           pr_fecha_xml IN BOOLEAN DEFAULT FALSE) IS
  BEGIN
    gene0002.pc_escreve_xml(vr_des_xml, vr_texto_completo, pr_des_dados, pr_fecha_xml);
  END;
  

BEGIN
  --------------- VALIDACOES INICIAIS -----------------

  -- Incluir nome do módulo logado
  GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                            ,pr_action => null);
  -- Verifica se a cooperativa esta cadastrada
  OPEN cr_crapcop;
  FETCH cr_crapcop
   INTO rw_crapcop;
  -- Se não encontrar
  IF cr_crapcop%NOTFOUND THEN
    -- Fechar o cursor pois haverá raise
    CLOSE cr_crapcop;
    -- Montar mensagem de critica
    vr_cdcritic := 651;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE cr_crapcop;
  END IF;

  -- Leitura do calendário da cooperativa
  OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
  FETCH btch0001.cr_crapdat
   INTO rw_crapdat;
  -- Se não encontrar
  IF btch0001.cr_crapdat%NOTFOUND THEN
    -- Fechar o cursor pois efetuaremos raise
    CLOSE btch0001.cr_crapdat;
    -- Montar mensagem de critica
    vr_cdcritic := 1;
    RAISE vr_exc_saida;
  ELSE
    -- Apenas fechar o cursor
    CLOSE btch0001.cr_crapdat;
  END IF;

  -- Validações iniciais do programa
  BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                           ,pr_flgbatch => 1
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_cdcritic => vr_cdcritic);
  -- Se a variavel de erro é <> 0
  IF vr_cdcritic <> 0 THEN
    -- Envio centralizado de log de erro
    RAISE vr_exc_saida;
  END IF;

  --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  
  -- Inicializar o CLOB
  vr_des_xml := NULL;
  dbms_lob.createtemporary(vr_des_xml, TRUE);
  dbms_lob.open(vr_des_xml, dbms_lob.lob_readwrite);
  -- Inicilizar as informações do XML
  vr_texto_completo := NULL;
  pc_escreve_xml('<?xml version="1.0" encoding="utf-8"?><crrl380>');
  
  -- buscar lançamentos DEV.CH.DEP.
  FOR rw_craplcm IN cr_craplcm(pr_cdcooper => pr_cdcooper,
                               pr_dtmvtolt => rw_crapdat.dtmvtolt) LOOP
    
    --buscar numero do documento do cheque
    IF rw_craplcm.nrdocmto > 999999  THEN
      vr_nrdocmto := SUBSTR(to_char(rw_craplcm.nrdocmto,'00000000'),3,6);
    ELSE
      vr_nrdocmto := rw_craplcm.nrdocmto;
    END IF;
    
    /* Deposito intercoop. */
    IF  rw_craplcm.cdcoptfn <> 0 THEN
      -- buscar dados do cheques depositados
      OPEN cr_crapchd ( pr_cdcooper => rw_craplcm.cdcoptfn,
                        pr_cdbanchq => rw_craplcm.cdbanchq,
                        pr_cdagechq => rw_craplcm.cdagechq,
                        pr_cdcmpchq => rw_craplcm.cdcmpchq,
                        pr_nrctachq => rw_craplcm.nrctachq,
                        pr_nrdocmto => vr_nrdocmto,
                        pr_dtmvtolt => rw_craplcm.dtmvtolt,
                        pr_cdcoptfn => rw_craplcm.cdcoptfn,
                        pr_nrdconta => rw_craplcm.nrdconta);
      FETCH cr_crapchd INTO rw_crapchd;
      -- atribuir variavel se encontrou cheque
      vr_fcrapchd := cr_crapchd%FOUND;
      CLOSE cr_crapchd;
    
    ELSE
      -- buscar dados do cheques depositados
      OPEN cr_crapchd ( pr_cdcooper => pr_cdcooper,
                        pr_cdbanchq => rw_craplcm.cdbanchq,
                        pr_cdagechq => rw_craplcm.cdagechq,
                        pr_cdcmpchq => rw_craplcm.cdcmpchq,
                        pr_nrctachq => rw_craplcm.nrctachq,
                        pr_nrdocmto => vr_nrdocmto,
                        pr_dtmvtolt => rw_craplcm.dtmvtolt,
                        pr_cdcoptfn => rw_craplcm.cdcoptfn,
                        pr_nrdconta => rw_craplcm.nrdconta);
      FETCH cr_crapchd INTO rw_crapchd;
      -- atribuir variavel se encontrou cheque
      vr_fcrapchd := cr_crapchd%FOUND;
      CLOSE cr_crapchd;
    END IF;
    
    -- buscar dados do associado se for um associado ainda não lido
    IF vr_nrdconta <> rw_craplcm.nrdconta THEN
      -- buscar dados do associado
      OPEN cr_crapass ( pr_cdcooper => pr_cdcooper,
                        pr_nrdconta => rw_craplcm.nrdconta);
      FETCH cr_crapass INTO rw_crapass;
      -- atribuir indicador se encontrou associaco
      vr_fcrapass := cr_crapass%FOUND;
      CLOSE cr_crapass;      
    END IF;
    
    -- se localizou o cheque 
    IF vr_fcrapchd THEN
      -- Buscar Depositos Bloqueados - D15
      FOR rw_crapdpb IN cr_crapdpb( pr_cdcooper => pr_cdcooper,
                                    pr_dtmvtolt => rw_crapchd.dtmvtolt,
                                    pr_nrdconta => rw_craplcm.nrdconta,
                                    pr_nrdocmto => rw_crapchd.nrdocmto) LOOP
         /* Devol.Fora Data */
         IF rw_craplcm.dtmvtolt > rw_crapdpb.dtliblan THEN
           -- incluir linhas no xml para o arquivo
           pc_escreve_xml('<cheque>
                             <cdagenci>'|| rw_crapass.cdagenci                          ||' </cdagenci>
                             <cdbanchq>'|| rw_crapchd.cdbanchq                          ||' </cdbanchq>
                             <cdagechq>'|| to_char(rw_crapchd.cdagechq,'fm999G999G999') ||' </cdagechq>
                             <nrdconta>'|| gene0002.fn_mask_conta(rw_craplcm.nrdconta)  ||' </nrdconta>
                             <nrdocmto_dpb>'|| rw_crapdpb.nrdocmto                      ||' </nrdocmto_dpb>
                             <nrdocmto_lcm>'|| rw_craplcm.nrdocmto                      ||' </nrdocmto_lcm>
                             <dtmvtolt_chd>'|| to_char(rw_crapchd.dtmvtolt,'DD/MM/RR')  ||' </dtmvtolt_chd>
                             <dtliblan>'|| to_char(rw_crapdpb.dtliblan,'DD/MM/RR')      ||' </dtliblan>
                             <dtmvtolt_dpb>'|| to_char(rw_craplcm.dtmvtolt,'DD/MM/RR')  ||' </dtmvtolt_dpb>
                             <cdpesqbb>'|| rw_craplcm.cdpesqbb ||' </cdpesqbb>
                             <vllanmto>'|| rw_craplcm.vllanmto ||' </vllanmto>
                             <vlsddisp>'|| rw_crapass.vlsddisp ||' </vlsddisp>
                           </cheque>');
         END IF;    
      END LOOP; -- Fim Loop rw_crapdpb
                                    
    END IF;
  END LOOP;                   
  
  --> descarregar buffer
  pc_escreve_xml('</crrl380>',TRUE);
  
  -- Busca do diretório base da cooperativa para PDF
  vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' -- /usr/coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => '/rl'); --> Utilizaremos o rl
  
  -- Efetuar solicitação de geração de relatório --
  gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper         --> Cooperativa conectada
                             ,pr_cdprogra  => vr_cdprogra         --> Programa chamador
                             ,pr_dtmvtolt  => rw_crapdat.dtmvtolt --> Data do movimento atual
                             ,pr_dsxml     => vr_des_xml          --> Arquivo XML de dados
                             ,pr_dsxmlnode => '/crrl380/cheque'    --> Nó base do XML para leitura dos dados
                             ,pr_dsjasper  => 'crrl380.jasper'    --> Arquivo de layout do iReport
                             ,pr_dsparams  => NULL                --> Sem parametros
                             ,pr_dsarqsaid => vr_nom_direto||'/'||vr_nmarqimp --> Arquivo final com código da agência
                             ,pr_qtcoluna  => 132                 --> 132 colunas
                             ,pr_sqcabrel  => 1                   --> Sequencia do Relatorio {includes/cabrel132_5.i}
                             ,pr_flg_impri => 'S'                 --> Chamar a impressão (Imprim.p)
                             ,pr_nmformul  => '132col'            --> Nome do formulário para impressão
                             ,pr_nrcopias  => 1                   --> Número de cópias
                             ,pr_flg_gerar => 'N'                 --> gerar PDF
                             ,pr_des_erro  => vr_dscritic);       --> Saída com erro
  -- Testar se houve erro
  IF vr_dscritic IS NOT NULL THEN
    -- Gerar exceção
    RAISE vr_exc_saida;
  END IF;

  -- Liberando a memória alocada pro CLOB
  dbms_lob.close(vr_des_xml);
  dbms_lob.freetemporary(vr_des_xml);                                      
  

  ----------------- ENCERRAMENTO DO PROGRAMA -------------------

  -- Processo OK, devemos chamar a fimprg
  btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                           ,pr_cdprogra => vr_cdprogra
                           ,pr_infimsol => pr_infimsol
                           ,pr_stprogra => pr_stprogra);

  -- Salvar informações atualizadas
  COMMIT;

EXCEPTION
  WHEN vr_exc_fimprg THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Envio centralizado de log de erro
    btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                              ,pr_ind_tipo_log => 2 -- Erro tratato
                              ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                               || vr_cdprogra || ' --> '
                                               || vr_dscritic );
    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);
    -- Efetuar commit
    COMMIT;
  WHEN vr_exc_saida THEN
    -- Se foi retornado apenas código
    IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
      -- Buscar a descrição
      vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
    END IF;
    -- Devolvemos código e critica encontradas das variaveis locais
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
END pc_crps455;
/

