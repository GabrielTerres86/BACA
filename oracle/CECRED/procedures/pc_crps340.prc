CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS340 (pr_cdcooper  IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                                       ,pr_flgresta  IN PLS_INTEGER             --> Flag padrao para utilização de restart
                                       ,pr_stprogra OUT PLS_INTEGER             --> Saída de termino da execução
                                       ,pr_infimsol OUT PLS_INTEGER             --> Saída de termino da solicitacao
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE   --> Critica encontrada
                                       ,pr_dscritic OUT VARCHAR2) IS

BEGIN
  /* ..........................................................................

  Programa: pc_crps340  (Fonte Antigo Fontes/crps340.p)
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Margarete
  Data    : Abril/2003.                     Ultima atualizacao: 22/06/2016

  Dados referentes ao programa:

  Frequencia: Diario (Batch - Background).
  Objetivo  : Atende a solicitacao 4.
              Emite relatorio com os limites de credito concedidos no mes
               que serao microfilmados  (286).

  Alteracoes: 02/05/2003 - Acerto no nome do Formulario (Ze Eduardo).

              23/06/2003 - Imprimir contratos < 1000 (Margarete).

              22/07/2003 - Foi alterado o valor fixo 1000 para a variavel
                           aux_dstextab e incluido o campo flgmifil
                           (Fernando).

              01/03/2004 - Alterar termo de responsabilidade (Margarete).

              21/09/2005 - Modificado FIND FIRST para FIND na tabela
                           crapcop.cdcooper = glb_cdcooper (Diego).

              26/01/2006 - Excluido no Termo de Responsabilidade, campos p/
                           assinaturas, ref. RECEBIMENTO CECRED (Diego).

              17/02/2006 - Unificacao dos bancos - SQLWorks - Eder.

              11/10/2007 - Retirada uma via do termo de responsabilidade
                           do relatiro. (Gabriel)

              03/03/2009 - Tratamento para microfilmagem de desconto de
                           titulos (Guilherme).

              24/06/2010 - Alterado o prazo de devolucao de 5 para 30 dias
                           (Adriano).

              21/07/2011 - Alterado o layout para DECLARACAO DE RECEBIMENTO
                           (Isara - RKAM)

              31/08/2012 - Tratamento crapcop.nmrescop "x(20)" (Diego).

              30/10/2013 - Conversao PROGRESS >>> PLSQL (Adriano)

              22/06/2016 - Correcao para o uso da function fn_busca_dstextab
                           da TABE0001. (Carlos Rafael Tanholi).  
  ............................................................................. */

  DECLARE

    --Busca dos dados da cooperativa
    CURSOR cr_crapcop IS
    SELECT cop.nmrescop
          ,cop.nmextcop
      FROM crapcop cop
     WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;

    -- Cursor generico de calendario
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;

    --Busca os contratos de emprestimos e limites de creditos que foram microfilmados.
    CURSOR cr_crapmcr (pr_dstextab IN NUMERIC) IS
    SELECT mcr.dtmvtolt
          ,mcr.cdagenci
          ,mcr.nrdconta
          ,mcr.vlcontra
          ,mcr.flgmifil
          ,mcr.tpctrlim
          ,mcr.dtcancel
          ,mcr.nrcontra
          ,mcr.rowid
     FROM crapmcr mcr
    WHERE mcr.cdcooper = pr_cdcooper
      AND to_char(mcr.dtmvtolt,'mm') = to_char(rw_crapdat.dtmvtolt,'mm')
      AND to_char(mcr.dtmvtolt,'yyyy') = to_char(rw_crapdat.dtmvtolt,'yyyy')
      AND mcr.tpctrmif = 2 --Tipo de contrato do limite de credito (2-Descto)
      AND mcr.dtcancel IS NULL
      AND mcr.vlcontra >= pr_dstextab
          ORDER BY mcr.dtmvtolt
                  ,mcr.cdagenci
                  ,mcr.nrdconta
                  ,mcr.nrcontra;
    rw_crapmcr cr_crapmcr%ROWTYPE;

    --Busca associado
    CURSOR cr_crapass (pr_nro_conta  IN rw_crapmcr.nrdconta%TYPE) IS
    SELECT ass.nmprimtl
      FROM crapass ass
     WHERE ass.cdcooper = pr_cdcooper
       AND ass.nrdconta = pr_nro_conta;
    rw_crapass cr_crapass%ROWTYPE;

    --------------------------VARIAVEIS----------------------------------------

    -- Codigo do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS340';
    -- Nome do relatorio
    vr_nmrelato CONSTANT varchar2(12) := 'crrl286';


    -- Codigo da critica
    vr_cdcritic crapcri.cdcritic%TYPE;
    -- Descrição da critica
    vr_dscritic VARCHAR2(4000);
    -- Tratamento de finalizacao do programa
    vr_exc_fimprg EXCEPTION;
    -- Tratamento de saida do programa
    vr_exc_saida EXCEPTION;
    --Armazena a quantidade total de contratos
    vr_tot_qtctremp NUMBER := 0;
    --Armazena o valor total dos limites
    vr_tot_vllimite NUMBER := 0;
    --Tipo do contrato
    vr_tpctrlim VARCHAR2(20);
    --Situacao do contrato
    vr_dssitctr VARCHAR2(3);
    --Variavel para armazenar conteudo do relatorio
    vr_dsxmldad CLOB;
    --Armazena o diretorio do relatorio
    vr_dsdireto VARCHAR2(400);
    --Armazena o valor de microfilmagem parametrizado na tab
    vr_vlrmifil numeric :=0;
    -- Guardar registro dstextab
    vr_dstextab craptab.dstextab%TYPE;    

    --Procedure para escrever na variavel CLOB
    PROCEDURE pc_escreve_clob(pr_des_dados IN VARCHAR2) IS
    BEGIN
      dbms_lob.writeappend(vr_dsxmldad,LENGTH(pr_des_dados),pr_des_dados);
    END;

  BEGIN

    -- Incluir nome do modulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                              ,pr_action => null);

    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop;
    FETCH cr_crapcop
     INTO rw_crapcop;
    -- Se não encontrar
    IF cr_crapcop%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE cr_crapcop;
      -- Montar mensagem de critica
      vr_cdcritic := 651;
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE cr_crapcop;
    END IF;

    -- Validacoes iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper
                             ,pr_flgbatch => 1
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_cdcritic => vr_cdcritic);

    IF vr_cdcritic <> 0 THEN
      -- Buscar descrição da critica
      vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;
    -- Verificacao do calendario
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;

    -- Buscar configuração na tabela
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'GENERI'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'VLMICFLIMI'
                                             ,pr_tpregist => 0);   
    									 
    IF TRIM(vr_dstextab) IS NULL THEN     
      --O limite sera "zero"
      vr_vlrmifil := 0;
    ELSE
      vr_vlrmifil := gene0002.fn_char_para_number(vr_dstextab);
    END IF;

    --Inicializa o CLOB
    dbms_lob.createtemporary(vr_dsxmldad,TRUE);
    dbms_lob.OPEN(vr_dsxmldad,dbms_lob.lob_readwrite);


    --Inicia o xml
    pc_escreve_clob('<?xml version="1.0" encoding="utf-8"?>' ||
                    '<raiz>' ||
                       '<termo>' ||
                          '<nmmesref>' || gene0001.vr_vet_nmmesano(to_char(rw_crapdat.dtmvtolt,'mm')) || '/' || TRIM(to_char(rw_crapdat.dtmvtolt,'yyyy')) || '</nmmesref>' ||
                          '<nmextcop>' || RPAD((rw_crapcop.nmextcop || ' - ' || TRIM(rw_crapcop.nmrescop)),50,' ') || '</nmextcop>' ||
                          '<nmrescop>' || TRIM(SUBSTR(rw_crapcop.nmrescop,1,20)) || '</nmrescop>' ||
                       '</termo>' ||
                       '<microfil>');

    --Busca os contratos de emprestimos e limites de creditos que foram microfilmados.
    FOR rw_crapmcr IN cr_crapmcr(pr_dstextab => vr_vlrmifil) LOOP

      --Busca o associado
      OPEN cr_crapass(pr_nro_conta => rw_crapmcr.nrdconta);
      FETCH cr_crapass INTO rw_crapass;

      -- Se não encontrar
      IF cr_crapass%NOTFOUND THEN
        -- Fechar o cursor pois havera raise
        CLOSE cr_crapass;
        -- Montar mensagem de critica
        vr_cdcritic := 251;
        vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE cr_crapass;
      END IF;

      --Incrementa quantidade total de contratos
      vr_tot_qtctremp := vr_tot_qtctremp + 1;
      --Incrementa valor total de limites
      vr_tot_vllimite := vr_tot_vllimite + rw_crapmcr.vlcontra;
      vr_tpctrlim := '';

      --Verifica a situacao do contrato
      IF NOT rw_crapmcr.dtcancel IS NULL THEN
        vr_dssitctr := 'CAN'; --Cancelado
      ELSE
        vr_dssitctr := 'ATI'; --Ativo
      END IF;

      --Verifica o tipo de contrato do limite
      IF rw_crapmcr.tpctrlim = 1 THEN
        vr_tpctrlim := 'Limite de Credito';
      ELSE
        IF rw_crapmcr.tpctrlim = 2 THEN
          vr_tpctrlim := 'Desconto de Cheques';
        ELSE
          IF rw_crapmcr.tpctrlim = 3 THEN
            vr_tpctrlim := 'Desconto de Titulos';
          ELSE
            vr_tpctrlim := 'Tipo Desconhecido';
          END IF;

        END IF;
      END IF;
      --Inclui as informacoes no xml
      pc_escreve_clob('<crapmcr>' ||
                         '<nmmesref>' || gene0001.vr_vet_nmmesano(to_char(rw_crapdat.dtmvtolt,'mm')) || '/' || TRIM(to_char(rw_crapdat.dtmvtolt,'yyyy')) || '</nmmesref>' ||
                         '<dtmvtolt>' || TO_CHAR(rw_crapmcr.dtmvtolt,'dd/mm/yyyy') || '</dtmvtolt>' ||
                         '<cdagenci>' || rw_crapmcr.cdagenci || '</cdagenci>' ||
                         '<nrdconta>' || GENE0002.FN_MASK_CONTA(rw_crapmcr.nrdconta) || '</nrdconta>' ||
                         '<nmprimtl>' || SUBSTR(rw_crapass.nmprimtl,1,38) || '</nmprimtl>' ||
                         '<nrcontra>' || rw_crapmcr.nrcontra || '</nrcontra>' ||
                         '<dssitctr>' || vr_dssitctr || '</dssitctr>' ||
                         '<vlcontra>' || rw_crapmcr.vlcontra || '</vlcontra>' ||
                         '<tpctrlim>' || vr_tpctrlim || '</tpctrlim>' ||
                      '</crapmcr>');

    END LOOP;

    --Finaliza o xml
    pc_escreve_clob(   '</microfil>' ||
                       '<total>' ||
                          '<qtctremp>' || vr_tot_qtctremp || '</qtctremp>' ||
                          '<vllimite>' || vr_tot_vllimite || '</vllimite>' ||
                       '</total>' ||
                    '</raiz>');

    --Por questoes de performance, o update foi feito neste ponto.
    --Atualiza o registro de microfilmagem
    BEGIN
      UPDATE crapmcr SET crapmcr.flgmifil = 1 --Contrato foi microfilmado
        WHERE crapmcr.cdcooper = pr_cdcooper
          AND TO_CHAR(crapmcr.dtmvtolt,'mm') = TO_CHAR(rw_crapdat.dtmvtolt,'mm')
          AND TO_CHAR(crapmcr.dtmvtolt,'yyyy') = TO_CHAR(rw_crapdat.dtmvtolt,'yyyy')
          AND crapmcr.tpctrmif = 2 --Tipo de contrato do limite de credito (2-Descto)
          AND crapmcr.dtcancel IS NULL
          AND crapmcr.vlcontra >= vr_vlrmifil;
    EXCEPTION
      WHEN OTHERS THEN
        vr_dscritic := 'Erro ao atualizar a tabela crapmcr. Detalhes'|| SQLERRM;
        RAISE vr_exc_saida;
    END;


    --Busca o diretório para geracao do relatorio
    vr_dsdireto := GENE0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/Coop
                                        ,pr_cdcooper => pr_cdcooper
                                        ,pr_nmsubdir => 'rl');

    -- Efetuar solicitacao de geracao de relatorio --
    gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                --> Cooperativa conectada
                               ,pr_cdprogra  => vr_cdprogra                --> Programa chamador
                               ,pr_dtmvtolt  => rw_crapdat.dtmvtolt        --> Data do movimento atual
                               ,pr_dsxml     => vr_dsxmldad                --> Arquivo XML de dados
                               ,pr_dsxmlnode => '/raiz'                    --> Nó base do XML para leitura dos dados
                               ,pr_dsjasper  => 'crrl286_principal.jasper' --> Arquivo de layout do iReport
                               ,pr_dsparams  => ''                          --> Enviar como parâmetro apenas o valor maior deposito
                               ,pr_dsarqsaid => vr_dsdireto ||'/'|| vr_nmrelato||'.lst' --> Arquivo final com código da agência
                               ,pr_qtcoluna  => 132                        --> 132 colunas
                               ,pr_sqcabrel  => 1                          --> Sequencia do Relatorio {includes/cabrel132_1.i}
                               ,pr_flg_impri => 'S'                        --> Chamar a impressão (Imprim.p)
                               ,pr_nmformul  => '132dm'                    --> Nome do formulário para impressão
                               ,pr_nrcopias  => 1                          --> Número de cópias
                               ,pr_flg_gerar => 'N'                        --> gerar PDF
                               ,pr_des_erro  => vr_dscritic);              --> Saída com erro

    -- Testar se houve erro
    IF vr_dscritic IS NOT NULL THEN
      -- Gerar exceção
      RAISE vr_exc_saida;
    END IF;

     -- Liberando a memoria alocada pro CLOB
    dbms_lob.close(vr_dsxmldad);
    dbms_lob.freetemporary(vr_dsxmldad);


    -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                             ,pr_cdprogra => vr_cdprogra
                             ,pr_infimsol => pr_infimsol
                             ,pr_stprogra => pr_stprogra);

    -- Efetuar commit
    COMMIT;
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Liberando a memoria alocada pro CLOB
      dbms_lob.close(vr_dsxmldad);
      dbms_lob.freetemporary(vr_dsxmldad);

      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Se foi gerada critica para envio ao log
      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        -- Envio centralizado de log de erro
        btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                  ,pr_ind_tipo_log => 2 -- Erro tratado
                                  ,pr_des_log      => to_char(SYSDATE,'hh24:mi:ss')||' - '
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
      -- Liberando a memoria alocada pro CLOB
      dbms_lob.close(vr_dsxmldad);
      dbms_lob.freetemporary(vr_dsxmldad);

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
      -- Liberando a memoria alocada pro CLOB
      dbms_lob.close(vr_dsxmldad);
      dbms_lob.freetemporary(vr_dsxmldad);

      -- Efetuar retorno do erro não tratado
      pr_cdcritic := 0;
      pr_dscritic := sqlerrm;
      -- Efetuar rollback
      ROLLBACK;

  END;

END PC_CRPS340;
/
