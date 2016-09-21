CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS019 (pr_cdcooper IN crapcop.cdcooper%TYPE   --> Codigo Cooperativa
                                       ,pr_flgresta IN PLS_INTEGER             --> Flag padrao para utilizacao de restart
                                       ,pr_stprogra OUT PLS_INTEGER            --> Saida de termino da execucao
                                       ,pr_infimsol OUT PLS_INTEGER            --> Saida de termino da solicitacao
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE  --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS           --> Descricao da Critica
  BEGIN

  /* .............................................................................

   Programa: PC_CRPS019                      Antigo: Fontes/CRPS019.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Fevereiro/92.                   Ultima atualizacao: 04/02/2014

   Dados referentes ao programa:

   Frequencia: Mensal (Batch - Background).
   Objetivo  : Atende a solicitacao 013 (mensal - limpeza mensal)
               Emite: arquivo geral de extratos de conta para microfilmagem
                      ate a conta 559999.

   Alteracoes: 03/11/94 - Alterado para criar a variavel com os historicos refe-
                          rentes a cheques (Deborah).

               24/01/97 - Alterado para tratar o historico 191 da mesma forma
                          que o 47 (Deborah).

               03/04/97 - Alterado para trocar do /win10 para o /win12 (Deborah)

               04/02/98 - Incluir funcao transmic (Odair)

               09/03/98 - Alterado para passar novo parametro para o shell
                          transmic (Deborah).

               22/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               24/06/99 - Incluir na lista historicos 338,340 (Odair)

               02/08/99 - Alterado para ler a lista de historicos de uma tabela
                          (Edson).

               05/10/1999 - Parametrizar o diretorio (Deborah).

               10/01/2000 - Padronizar mensagens (Deborah).

               23/02/2000 - Tratar arquivos quando nao ha lancamentos nao
                            transmitir para Hering (Odair)

               30/10/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner)

               04/01/2001 - Mostrar o periodo de apuracao do CPMF no lugar do
                            numero do documento. (Eduardo).

               16/01/2001 - Mostrar no extrato de conta corrente as taxas de
                            juros utilizadas. (Eduardo).

               27/06/2001 - Gravar dados da 3030 (Margarete).

               29/08/2001 - Identificar os depositos da cooperativa (Margarete)

               02/08/2004 - Alterar diretorio do win12 (Margarete).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               14/02/2006 - Unificacao dos bancos - SQLWorks - Eder

               01/06/2007 - Acerto na taxas referente ao Lim. Cheque (Ze).

               21/07/2008 - Inclusao do cdcooper no FIND craphis (Mirtes).

               30/10/2008 - Alteracao CDEMPRES (Diego).

               19/10/2009 - Alteracao Codigo Historico (Kbase).

               13/04/2011 - Alterado da conta 730000 p/ 2625500 (Guilherme).

               07/01/2013 - Alterar RETURN por QUIT (David).

               04/02/2014 - Conversao Progress -> Oracle (Alisson - Amcom)


     ............................................................................. */

     DECLARE


     --Constantes
     vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS019';


     --Variaveis Locais
     vr_dstextab craptab.dstextab%TYPE;

     --Variaveis para retorno de erro
     vr_cdcritic        INTEGER:= 0;
     vr_dscritic        VARCHAR2(4000);

     --Variaveis de Excecao
     vr_exc_final       EXCEPTION;
     vr_exc_saida       EXCEPTION;
     vr_exc_fimprg      EXCEPTION;


     ---------------------------------------
     -- Inicio Bloco Principal PC_CRPS019
     ---------------------------------------
     BEGIN

       --Limpar parametros saida
       pr_cdcritic:= NULL;
       pr_dscritic:= NULL;

       -- Incluir nome do modulo logado
       GENE0001.pc_informa_acesso(pr_module => 'PC_'||vr_cdprogra
                                 ,pr_action => NULL);

       -- Validacoes iniciais do programa
       BTCH0001.pc_valida_iniprg (pr_cdcooper => pr_cdcooper
                                 ,pr_flgbatch => 0
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_cdcritic => vr_cdcritic);

       --Se retornou critica aborta programa
       IF vr_cdcritic <> 0 THEN
         --Descricao do erro recebe mensagam da critica
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         -- Envio centralizado de log de erro
         btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                   ,pr_ind_tipo_log => 2 -- Erro tratato
                                   ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                       || vr_cdprogra || ' --> '
                                                       || vr_dscritic );
         --Sair do programa
         RAISE vr_exc_saida;
       END IF;

       /*  Parametros de execucao do programa  */
       vr_dstextab:= tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'CONFIG'
                                               ,pr_cdempres => pr_cdcooper
                                               ,pr_cdacesso => 'MICROFILMA'
                                               ,pr_tpregist => 19);

       --Se nao encontrou
       IF vr_dstextab IS NULL THEN
         -- Montar mensagem de critica
         vr_cdcritic:= 652;
         vr_dscritic:= gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         --Complementar mensagem
         vr_dscritic:= vr_dscritic ||' - CRED-CONFIG-NN-MICROFILMA-019';
         RAISE vr_exc_saida;
       END IF;

       /*  Verifica se o programa deve rodar para esta Cooperativa  */
       IF TO_NUMBER(SUBSTR(vr_dstextab,1,1)) <> 1 THEN
         --Sair com fimprg
         RAISE vr_exc_fimprg;
       END IF;

       --Executar o programa
       LIMP0001.pc_limpeza_microfilmagem (pr_cdcooper => pr_cdcooper     --> Codigo Cooperativa
                                         ,pr_flgresta => pr_flgresta     --> Flag padrao para utilizacao de restart
                                         ,pr_cdprogra => vr_cdprogra     --> Nome Programa da Execucao crps019/crps076
                                         ,pr_stprogra => pr_stprogra     --> Saida de termino da execucao
                                         ,pr_flgtrans => SUBSTR(vr_dstextab,3,1) = '1' --> Transmite ou nao o arquivo
                                         ,pr_infimsol => pr_infimsol     --> Saida de termino da solicitacao
                                         ,pr_cdcritic => vr_cdcritic     --> Codigo da Critica
                                         ,pr_dscritic => vr_dscritic);   --> Descricao da Critica
       --Verificar se ocorreu erro
       IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
         RAISE vr_exc_saida;
       END IF;

       -- Processo OK, devemos chamar a fimprg
       btch0001.pc_valida_fimprg (pr_cdcooper => pr_cdcooper
                                 ,pr_cdprogra => vr_cdprogra
                                 ,pr_infimsol => pr_infimsol
                                 ,pr_stprogra => pr_stprogra);


       --Salvar informacoes no banco de dados
       COMMIT;
     EXCEPTION
       WHEN vr_exc_fimprg THEN
         -- Se foi retornado apenas codigo
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           -- Buscar a descricao da critica
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
         --Limpar parametros
         pr_cdcritic:= 0;
         pr_dscritic:= NULL;
         -- Efetuar commit pois gravaremos o que foi processado ate entao
         COMMIT;
       WHEN vr_exc_saida THEN
         -- Se foi retornado apenas codigo
         IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
           -- Buscar a descricao
           vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
         END IF;
         -- Devolvemos codigo e critica encontradas
         pr_cdcritic := NVL(vr_cdcritic,0);
         pr_dscritic := vr_dscritic;
         -- Efetuar rollback
         ROLLBACK;
       WHEN OTHERS THEN
         -- Efetuar retorno do erro nao tratado
         pr_cdcritic := 0;
         pr_dscritic := sqlerrm;
         -- Efetuar rollback
         ROLLBACK;
     END;
   END PC_CRPS019;
/

