CREATE OR REPLACE PROCEDURE CECRED."PC_CRPS339" (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Cooperativa solicitada
                    ,pr_flgresta  IN PLS_INTEGER            --> Flag padrão para utilização de restart
                    ,pr_stprogra OUT PLS_INTEGER            --> Saída de termino da execução
                    ,pr_infimsol OUT PLS_INTEGER            --> Saída de termino da solicitação
                    ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Critica encontrada
                    ,pr_dscritic OUT VARCHAR2) IS           --> Texto de erro/critica encontrada
  BEGIN
    /* .............................................................................

       Programa: pc_crps339 (Fontes/crps339.p)
       Sistema : Conta-Corrente - Cooperativa de Credito
       Sigla   : CRED
       Autor   : Margarete
       Data    : Abril/2003.                     Ultima atualizacao: 09/09/2019.

       Dados referentes ao programa:

       Frequencia: Diario (Batch - Background).
       Objetivo  : Atende a solicitacao 4.
                   Emite relatorio com os emprestimos concedidos no mes
                   que serao microfilmados  (285).

       Alteracoes: Acerto no nome do Formulario (Ze Eduardo).

                   23/06/2003 - Imprimir contratos < 2000 (Margarete).

                   22/07/2003 - Foi alterado o valor fixo 2000 para a variavel
                                aux_dstextab e incluido o campo flgmifil
                                (Fernando).

                   01/03/2004 - Alterar termo de responsabilidade (Margarete).

                   03/05/2004 - Incluido mais um campo craptab (Margarete).

                   21/09/2005 - Modificado FIND FIRST para FIND na tabela
                                crapcop.cdcooper = glb_cdcooper (Diego).

                   16/02/2006 - Unificacao dos bancos - SQLWorks - Eder

                   27/02/2007 - Retirado do relatorio "Recebimento Cecred" (Elton).

                   11/10/2007 - Retirada 01 via do termo de responsabilidade do
                                relatorio. (Gabriel).

                   24/06/2010 - Alterado o prazo de devolução de 5 para 30 dias
                                (Adriano).

                   21/07/2011 - Alterado o layout para DECLARACAO DE RECEBIMENTO
                                (Isara - RKAM)

                   31/08/2012 - Tratamento crapcop.nmrescop "x(20)" (Diego).

                   04/07/2013 - Conversão Progress >> PLSQL (Marcos-Supero)

                   09/08/2013 - Troca da busca do mes por extenso com to_char para
                                utilizarmos o vetor gene0001.vr_vet_nmmesano (Marcos-Supero)

                   11/10/2013 - Ajustes na rotina para prever a nova forma de retorno
                                das criticas e chamadas a fimprg.p (Douglas Pagel).

                   07/11/2014 - Criacao do cursor "cr_crapepr" para verificacao 
                                se e um emprestimo com origem (3) Internet ou 
                                (4) TAA, caso seja vai para o proximo. (Jaison)
                                
                   02/03/2015 - (Chamado 252147) Retirar pendências geradas nos 
                                relatórios: 266, 620, 285  quanto as operações 
                                de crédito liberadas devido aos Termos de Cessão 
                                de Crédito (Cartão Bancoob) (Tiago Castro - RKAM).

                   09/09/2019 - P438 - Inclusão da origem 10 (MOBILE) no filtro dos cursores de emprestimos
                                (Douglas Pagel/AMcom)
    ............................................................................ */

    DECLARE

      ------------------------ VARIAVEIS PRINCIPAIS ----------------------------

      -- Código do programa
      vr_cdprogra CONSTANT crapprg.cdprogra%TYPE := 'CRPS339';
      vr_dslinhas            VARCHAR2(2000);        --> Linhas que nao possuirao analise de credito
      -- Tratamento de erros
      vr_exc_saida   EXCEPTION;
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

      -- Buscar o cadastro dos associados da Cooperativa
      CURSOR cr_crapass IS
        SELECT ass.nrdconta
              ,ass.nmprimtl
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper;

      -- Efetua busca de todos os contratos microfilmados
      CURSOR cr_crapmcr(pr_vlcontra NUMBER) IS
        SELECT mcr.rowid
              ,mcr.dtmvtolt
              ,mcr.cdagenci
              ,mcr.nrdconta
              ,mcr.nrcontra
              ,mcr.vlcontra
              ,mcr.qtpreemp
              ,to_char(mcr.dtmvtolt,'dd/mm/yyyy') || '-' ||
               to_char(mcr.cdagenci,'fm000') || '-' ||
               to_char(mcr.cdbccxlt,'fm000') || '-' ||
               to_char(mcr.nrdolote,'fm000000')  cdpesqui
          FROM crapmcr mcr
         WHERE cdcooper = pr_cdcooper
           AND trunc(mcr.dtmvtolt,'mm') = trunc(rw_crapdat.dtmvtolt,'mm') -- Mes corrente
           AND mcr.vlcontra >= NVL(pr_vlcontra,0)                         -- Valor parametrizado
           AND mcr.tpctrmif  = 1                                          -- Cheque especial
         ORDER BY mcr.dtmvtolt
                 ,mcr.cdagenci
                 ,mcr.nrdconta
                 ,mcr.nrcontra;

      -- Verifica emprestimo 
      CURSOR cr_crapepr(pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT crapepr.nrctremp,
               crapepr.cdlcremp,
               crapepr.cdorigem 
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           AND crapepr.nrctremp = pr_nrctremp
           AND crapepr.cdorigem NOT IN (3,4,10);
      rw_crapepr cr_crapepr%ROWTYPE;

      ---------------------------- ESTRUTURAS DE REGISTRO ---------------------

      -- Definição de tipo para armazenar nome dos associados
      TYPE typ_tab_crapass IS
        TABLE OF crapass.nmprimtl%TYPE
          INDEX BY PLS_INTEGER; --> Número da conta
      vr_tab_crapass typ_tab_crapass;

      ------------------------------- VARIAVEIS -------------------------------

      -- Variáveis auxiliares ao processo
      vr_dstextab craptab.dstextab%TYPE;  --> Busca na craptab
      vr_vlcontra NUMBER;                 --> Valor mínimo de contrato
      vr_flgachou BOOLEAN := false;       --> Flag para teste de encontro de registros


      -- Variaveis para os XMLs e relatórios
      vr_clobxml     CLOB;                  -- Clob para conter o XML de dados
      vr_nom_direto  VARCHAR2(200);         -- Diretório para gravação do arquivo



      --------------------------- SUBROTINAS INTERNAS --------------------------

      -- Subrotina para escrever texto na variável CLOB do XML
      PROCEDURE pc_escreve_clob(pr_clobdado IN OUT NOCOPY CLOB
                               ,pr_desdados IN VARCHAR2) IS
      BEGIN
        dbms_lob.writeappend(pr_clobdado, length(pr_desdados),pr_desdados);
      END;

    BEGIN
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

      -- Buscar valor minimo para contratos
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'GENERI'
                                               ,pr_cdempres => 0
                                               ,pr_cdacesso => 'VLMICFEMPR'
                                               ,pr_tpregist => 0);
      -- Se encontrar
      IF vr_dstextab IS NOT NULL THEN
        -- Tenta converter para número
        vr_vlcontra := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,7));
      END IF;

      -- Busca dos associados da cooperativa
      FOR rw_crapass IN cr_crapass LOOP
        -- Adicionar ao vetor as informações chaveando pela conta
        vr_tab_crapass(rw_crapass.nrdconta) := rw_crapass.nmprimtl;
      END LOOP;

      -- Incluir o nó raiz ao XML
      dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
      dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);
      pc_escreve_clob(vr_clobxml,'<?xml version="1.0" encoding="utf-8"?><raiz>');

      -- Efetua busca de todos os contratos microfilmados
      FOR rw_crapmcr IN cr_crapmcr(pr_vlcontra => vr_vlcontra) LOOP

        -- Se não existir associado
        IF NOT vr_tab_crapass.EXISTS(rw_crapmcr.nrdconta) THEN
          -- Gerar erro 251
          vr_cdcritic := 251;
          vr_dscritic := gene0001.fn_busca_critica(251);
          -- Incluir conta na critica
          vr_dscritic := pr_dscritic || ' CONTA = ' || gene0002.fn_mask_conta(rw_crapmcr.nrdconta);
          -- Gerar exception
          RAISE vr_exc_saida;
        END IF;
        
        -- Verifica emprestimo 
        OPEN cr_crapepr(pr_nrdconta => rw_crapmcr.nrdconta
                       ,pr_nrctremp => rw_crapmcr.nrcontra);
        FETCH cr_crapepr
         INTO rw_crapepr;        
         CLOSE cr_crapepr;
          -- Busca as linhas de credito que nao devem possuir analise
          vr_dslinhas := ';'||
                          gene0001.fn_param_sistema(pr_nmsistem => 'CRED',
                                                    pr_cdcooper =>  0,
                                                    pr_cdacesso => 'CREDITO_BANCOOB')||
                          ';';

          -- Verifica se a linha de credito atual esta parametrizada para nao ser processada
          IF instr(vr_dslinhas,';'||rw_crapepr.cdlcremp||';') > 0 THEN
            -- busca proximo contrato
            continue;
          END IF;   

        -- Ativar a flag de encontro de informações
        vr_flgachou := true;

        -- Enviar o registro para o relatório
        pc_escreve_clob(vr_clobxml,'<detalhe>'
                                 ||'  <dtmvtolt>'||to_char(rw_crapmcr.dtmvtolt,'dd/mm/rrrr')||'</dtmvtolt>'
                                 ||'  <cdagenci>'||rw_crapmcr.cdagenci||'</cdagenci>'
                                 ||'  <nrdconta>'||LTRIM(gene0002.fn_mask_conta(rw_crapmcr.nrdconta))||'</nrdconta>'
                                 ||'  <nmprimtl>'||substr(vr_tab_crapass(rw_crapmcr.nrdconta),1,38)||'</nmprimtl>'
                                 ||'  <nrcontra>'||gene0002.fn_mask(rw_crapmcr.nrcontra,'z.zzz.zz9')||'</nrcontra>'
                                 ||'  <qtpreemp>'||to_char(rw_crapmcr.qtpreemp,'fm990')||'</qtpreemp>'
                                 ||'  <vlcontra>'||to_char(rw_crapmcr.vlcontra,'fm99g999g999g990d00')||'</vlcontra>'
                                 ||'  <cdpesqui>'||rw_crapmcr.cdpesqui||'</cdpesqui>'
                                 ||'</detalhe>');

        -- Por fim, ativa a flag de contrato microfilmado
        BEGIN
          UPDATE crapmcr
             SET flgmifil = 1
           WHERE rowid = rw_crapmcr.rowid;
        EXCEPTION
          WHEN OTHERS THEN
            -- Montar erro e sair
            vr_dscritic := 'Erro ao atualizar o contrato para microfilmado [Conta: '
                        || gene0002.fn_mask_conta(rw_crapmcr.nrdconta)
                        || ', Contrato: '||gene0002.fn_mask(rw_crapmcr.nrcontra,'zzz.zzz')||']. Detalhes: '
                        ||sqlerrm;
            RAISE vr_exc_saida;
        END;

      END LOOP;

      -- Encerrar a tag raiz
      pc_escreve_clob(vr_clobxml,'</raiz>');

      -- Se encontrou alguma informação
      IF vr_flgachou THEN

        -- Busca do diretório base da cooperativa para a geração de relatórios
        vr_nom_direto := gene0001.fn_diretorio(pr_tpdireto => 'C' --> /usr/coop
                                              ,pr_cdcooper => pr_cdcooper);

        -- Submeter o relatório 285
        gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                       --> Cooperativa conectada
                                   ,pr_cdprogra  => vr_cdprogra                       --> Programa chamador
                                   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt               --> Data do movimento atual
                                   ,pr_dsxml     => vr_clobxml                        --> Arquivo XML de dados
                                   ,pr_dsxmlnode => '/raiz'                           --> Nó base do XML para leitura dos dados
                                   ,pr_dsjasper  => 'crrl285.jasper'                  --> Arquivo de layout do iReport
                                   ,pr_dsparams  => 'PR_NMMESREF##'||gene0001.vr_vet_nmmesano(to_char(rw_crapdat.dtmvtolt,'MM'))||'/'||to_char(rw_crapdat.dtmvtolt,'YYYY')||'@@'
                                                 || 'PR_NMEXTCOP##'||rw_crapcop.nmextcop --> Parametros para montagem do termo
                                   ,pr_dsarqsaid => vr_nom_direto||'/rl/crrl285.lst' --> Arquivo final com o path
                                   ,pr_qtcoluna  => 132                               --> 132 colunas
                                   ,pr_flg_gerar => 'N'                               --> Geraçao na hora
                                   ,pr_flg_impri => 'S'                               --> Chamar a impressão (Imprim.p)
                                   ,pr_nmformul  => '132col'                          --> Nome do formulário para impressão
                                   ,pr_nrcopias  => 2                                 --> Número de cópias
                                   ,pr_sqcabrel  => 1                                 --> Qual a seq do cabrel
                                   ,pr_des_erro  => vr_dscritic);                     --> Saída com erro
        -- Liberando a memória alocada pro CLOB
        dbms_lob.close(vr_clobxml);
        dbms_lob.freetemporary(vr_clobxml);
        -- Testar se houve erro
        IF vr_dscritic IS NOT NULL THEN
          -- Gerar exceção
          RAISE vr_exc_saida;
        END IF;

      END IF;
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper
                               ,pr_cdprogra => vr_cdprogra
                               ,pr_infimsol => pr_infimsol
                               ,pr_stprogra => pr_stprogra);
      -- Efetuar commit final
      COMMIT;

    EXCEPTION
      WHEN vr_exc_fimprg THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;
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
        -- Efetuar commit
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
    END;

  END pc_crps339;
/

