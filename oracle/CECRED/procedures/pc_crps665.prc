CREATE OR REPLACE PROCEDURE CECRED.PC_CRPS665 (pr_cdcooper IN crapcop.cdcooper%TYPE      --> Codigo Cooperativa
                                       ,pr_cdoperad IN VARCHAR2                   --> Nome Operador
                                       ,pr_stprogra OUT PLS_INTEGER               --> Saida de termino da execucao
                                       ,pr_infimsol OUT PLS_INTEGER               --> Saida de termino da solicitacao
                                       ,pr_cdcritic OUT crapcri.cdcritic%TYPE     --> Codigo da Critica
                                       ,pr_dscritic OUT VARCHAR2) IS              --> Descricao da Critica
  BEGIN

  /* .............................................................................

   Programa: pc_crps665                         Antigo: Fontes/crps665.p
   Sistema : ATUALIZACAO DE VALORES NO EMPRESTIMO
   Sigla   : CRED
   Autor   : James Prust Junior
   Data    : Janeiro/2014.                     Ultima atualizacao: 30/11/2015

   Dados referentes ao programa:

   Frequencia: Diario.
   Objetivo  : Atende a solicitacao 1. Ordem = 49.
               Atualizar os valores na tabela crapepr.

   Alteracoes: 15/04/2014 - Conversao Progress -> Oracle (Alisson - Amcom)
               
               09/05/2014 - Adicionado parametros de paginacao em prc.
                            pc_obtem_dados_empresti. 
                            (Jorge/Guilherme) - SD 109570
                            
               30/11/2015 - Alterado idorigem de 1-Ayllos para 7-Batch devido a tratamentos
                            dentro da rotina pc_obtem_dados_empresti(Odirlei-AMcom)
                           
     ............................................................................. */

     DECLARE
     
      
       /*Cursores Locais */

       -- Selecionar os dados da Cooperativa
       CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
         SELECT crapcop.cdcooper
               ,crapcop.nmrescop
               ,crapcop.nrtelura
               ,crapcop.cdbcoctl
               ,crapcop.cdagectl
               ,crapcop.dsdircop
               ,crapcop.nrctactl
               ,crapcop.cdagedbb
               ,crapcop.cdageitg
               ,crapcop.nrdocnpj
         FROM crapcop crapcop
         WHERE crapcop.cdcooper = pr_cdcooper;
       rw_crapcop cr_crapcop%ROWTYPE;
              
       /* Cursor de Emprestimos */
       CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE
                         ,pr_tpemprst IN crapepr.tpemprst%TYPE
                         ,pr_inliquid IN crapepr.inliquid%TYPE) IS  
         SELECT crapepr.*
               ,crapepr.rowid
         FROM crapepr 
         WHERE crapepr.cdcooper = pr_cdcooper   
         AND   crapepr.tpemprst = pr_tpemprst   
         AND   crapepr.inliquid = pr_inliquid;
       rw_crapepr cr_crapepr%ROWTYPE; 
       
       --Selecionar Associados
       CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%TYPE) IS
         SELECT /*+ INDEX(crapass crapass##crapass7) */
                crapass.nrdconta
               ,crapass.inpessoa
               ,crapass.cdagenci 
               ,crapass.nmprimtl
         FROM crapass crapass
         WHERE crapass.cdcooper = pr_cdcooper;      
          
       --Tipo de Registro de Associados
       TYPE typ_reg_crapass IS RECORD 
         (inpessoa crapass.inpessoa%TYPE
         ,cdagenci crapass.cdagenci%TYPE
         ,nmprimtl crapass.nmprimtl%TYPE);
         
       --Tipo de Tabela de Associados
       TYPE typ_tab_crapass IS TABLE OF typ_reg_crapass INDEX BY PLS_INTEGER;
       --Tabela de Memoria de Associados
       vr_tab_crapass typ_tab_crapass;
       
       --Tabela de Memoria de Erros
       vr_tab_erro GENE0001.typ_tab_erro;
       
       --Tabela de Memoria de dados emprestimo
       vr_tab_dados_epr empr0001.typ_tab_dados_epr;
       
       /* Tipo de Registro para Emprestimos */
       TYPE typ_reg_crapepr IS RECORD
         (qtlcalat  NUMBER(35,4)
         ,qtpcalat  crapepr.qtprecal%TYPE
         ,vlsdevat  NUMBER
         ,vlpapgat  NUMBER
         ,vlppagat  NUMBER
         ,qtmdecat  NUMBER
         ,tab_rowid ROWID);
          
       /* Tipo de Tabela para Emprestimos */
       TYPE typ_tab_crapepr IS TABLE OF typ_reg_crapepr INDEX BY PLS_INTEGER;
       
       /* Tabela de Memoria Emprestimos Para FORALL */
       vr_tab_crapepr typ_tab_crapepr;
       
       --Registro do tipo calendario
       rw_crapdat  BTCH0001.cr_crapdat%ROWTYPE;
            
       --Constantes
       vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS665';

       --Variaveis Locais
       vr_flgtrans BOOLEAN; 
       vr_inusatab BOOLEAN;  
       
       --Variaveis dos Associados
       vr_cdagenci crapass.cdagenci%TYPE;
       vr_nmprimtl crapass.nmprimtl%TYPE;
       
       --Variaveis usadas nos indices das tabelas memorias
       vr_index     PLS_INTEGER;
       vr_index_epr VARCHAR2(100);
       
       --Variaveis para busca de parametros
       vr_dstextab            craptab.dstextab%TYPE;
       vr_dstextab_parempctl  craptab.dstextab%TYPE;
       vr_dstextab_digitaliza craptab.dstextab%TYPE;
       
       --Variaveis para retorno de erro
       vr_cdcritic      INTEGER:= 0;
       vr_dscritic      VARCHAR2(4000);
       vr_des_erro      VARCHAR2(3);

       --Variaveis de Excecao
       vr_exc_erro      EXCEPTION;
       vr_exc_saida     EXCEPTION;
       vr_exc_fimprg    EXCEPTION;
       
       --Variavel para retorno da qtd total de registros (utilizado para paginacao)
       vr_qtregist      INTEGER:= 0;
       
       --Procedure para limpar os dados das tabelas de memoria
       PROCEDURE pc_limpa_tabela IS
       BEGIN
         vr_tab_crapass.DELETE;
         vr_tab_crapepr.DELETE;
         vr_tab_dados_epr.DELETE;
         vr_tab_erro.DELETE;
       EXCEPTION
         WHEN OTHERS THEN
           --Variavel de erro recebe erro ocorrido
           vr_cdcritic:= 0;
           vr_dscritic:= 'Erro ao limpar tabelas de memoria. Rotina pc_CRPS665.pc_limpa_tabela. '||sqlerrm;
           --Sair do programa
           RAISE vr_exc_saida;
       END pc_limpa_tabela;
       
                                       
     ---------------------------------------
     -- Inicio Bloco Principal PC_CRPS665
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

       -- Verifica se a cooperativa esta cadastrada
       OPEN cr_crapcop(pr_cdcooper => pr_cdcooper);
       FETCH cr_crapcop INTO rw_crapcop;
       -- Se nao encontrar
       IF cr_crapcop%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE cr_crapcop;
         -- Montar mensagem de critica
         vr_cdcritic:= 651;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE cr_crapcop;
       END IF;

       -- Verifica se a data esta cadastrada
       OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
       FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
       -- Se nao encontrar
       IF BTCH0001.cr_crapdat%NOTFOUND THEN
         -- Fechar o cursor pois havera raise
         CLOSE BTCH0001.cr_crapdat;
         -- Montar mensagem de critica
         vr_cdcritic:= 1;
         vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic);
         RAISE vr_exc_saida;
       ELSE
         -- Apenas fechar o cursor
         CLOSE BTCH0001.cr_crapdat;
       END IF;

       --Limpar Tabela
       pc_limpa_tabela;
       
       --Carregar tabela associados
       FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP
         vr_tab_crapass(rw_crapass.nrdconta).inpessoa:= rw_crapass.inpessoa; 
         vr_tab_crapass(rw_crapass.nrdconta).cdagenci:= rw_crapass.cdagenci;
         vr_tab_crapass(rw_crapass.nrdconta).nmprimtl:= rw_crapass.nmprimtl; 
       END LOOP;
         
       --Buscar Indicador Uso tabela
       vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'TAXATABELA'
                                               ,pr_tpregist => 0);
       --Se nao encontrou
       IF vr_dstextab IS NULL THEN
         --Nao usa tabela
         vr_inusatab:= FALSE;
       ELSE
         IF  SUBSTR(vr_dstextab,1,1) = '0' THEN
           --Nao usa tabela
           vr_inusatab:= FALSE;
         ELSE
           --Nao usa tabela
           vr_inusatab:= TRUE;
         END IF;    
       END IF;
       
       -- busca o tipo de documento GED    
       vr_dstextab_digitaliza := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                           ,pr_nmsistem => 'CRED'
                                                           ,pr_tptabela => 'GENERI'
                                                           ,pr_cdempres => 00
                                                           ,pr_cdacesso => 'DIGITALIZA'
                                                           ,pr_tpregist => 5);
       
       -- Leitura do indicador de uso da tabela de taxa de juros                                                    
       vr_dstextab_parempctl := tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                                          ,pr_nmsistem => 'CRED'
                                                          ,pr_tptabela => 'USUARI'
                                                          ,pr_cdempres => 11
                                                          ,pr_cdacesso => 'PAREMPCTL'
                                                          ,pr_tpregist => 01);                                                           
       
       /* Processar Emprestimos */
       FOR rw_crapepr IN cr_crapepr (pr_cdcooper => pr_cdcooper
                                    ,pr_tpemprst => 0
                                    ,pr_inliquid => 0) LOOP

         --Marcar que nao houve transacao
         vr_flgtrans:= FALSE;
         
         --Limpar tabelas
         vr_tab_erro.DELETE;
         vr_tab_dados_epr.DELETE;

         BEGIN
          
           --Buscar dados do Associado
           vr_cdagenci:= vr_tab_crapass(rw_crapepr.nrdconta).cdagenci;
           vr_nmprimtl:= vr_tab_crapass(rw_crapepr.nrdconta).nmprimtl;
           
          
           --Obter Dados Emprestimos
           EMPR0001.pc_obtem_dados_empresti(pr_cdcooper => rw_crapepr.cdcooper --> Cooperativa conectada
                                           ,pr_cdagenci => vr_cdagenci         --> Código da agência
                                           ,pr_nrdcaixa => 0                   --> Número do caixa
                                           ,pr_cdoperad => pr_cdoperad         --> Código do operador
                                           ,pr_nmdatela => vr_cdprogra         --> Nome datela conectada
                                           ,pr_idorigem => 7 /*batch*/         --> Indicador da origem da chamada
                                           ,pr_nrdconta => rw_crapepr.nrdconta --> Conta do associado
                                           ,pr_idseqttl => 1 /*idseqttl*/      --> Sequencia de titularidade da conta
                                           ,pr_rw_crapdat => rw_crapdat        --> Vetor com dados de parâmetro (CRAPDAT)
                                           ,pr_dtcalcul => NULL                --> Data solicitada do calculo
                                           ,pr_nrctremp => rw_crapepr.nrctremp --> Número contrato empréstimo
                                           ,pr_cdprogra => vr_cdprogra         --> Programa conectado
                                           ,pr_inusatab => vr_inusatab         --> Indicador de utilização da tabela
                                           ,pr_flgerlog => 'N'                 --> Gerar log S/N
                                           ,pr_flgcondc => FALSE               --> Mostrar emprestimos liquidados sem prejuizo
                                           ,pr_nmprimtl => vr_nmprimtl         --> Nome Primeiro Titular
                                           ,pr_tab_parempctl => vr_dstextab_parempctl   --> Dados tabela parametro
                                           ,pr_tab_digitaliza => vr_dstextab_digitaliza --> Dados tabela parametro
                                           ,pr_nriniseq => 0                   --> Numero inicial paginacao
                                           ,pr_nrregist => 0                   --> Qtd registro por pagina
                                           ,pr_qtregist => vr_qtregist         --> Qtd total de registros
                                           ,pr_tab_dados_epr => vr_tab_dados_epr        --> Saida com os dados do empréstimo
                                           ,pr_des_reto => vr_des_erro         --> Retorno OK / NOK
                                           ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros
         
           --Se ocorreu erro
           IF vr_des_erro <> 'OK' THEN
             --Desfaz transacao
             RAISE vr_exc_erro;
           END IF;  
           
           --Buscar primeiro registro da tabela de emprestimos
           vr_index_epr:= vr_tab_dados_epr.FIRST;
           --Se Retornou Dados
           IF vr_index_epr IS NOT NULL THEN
             
             --Buscar proximo indice
             vr_index:= vr_tab_crapepr.count + 1;
             --Carregar tabela para o FORALL com dados retornados da vr_tab_dados_epr         
             vr_tab_crapepr(vr_index).qtlcalat:= nvl(vr_tab_dados_epr(vr_index_epr).qtlemcal,0); 
             vr_tab_crapepr(vr_index).qtpcalat:= nvl(vr_tab_dados_epr(vr_index_epr).qtprecal,0);
             vr_tab_crapepr(vr_index).vlsdevat:= nvl(vr_tab_dados_epr(vr_index_epr).vlsdeved,0);
             vr_tab_crapepr(vr_index).vlpapgat:= nvl(vr_tab_dados_epr(vr_index_epr).vlpreapg,0);
             vr_tab_crapepr(vr_index).vlppagat:= nvl(vr_tab_dados_epr(vr_index_epr).vlprepag,0);
             vr_tab_crapepr(vr_index).qtmdecat:= nvl(vr_tab_dados_epr(vr_index_epr).qtmesdec,0);
             vr_tab_crapepr(vr_index).tab_rowid:= rw_crapepr.rowid; 
           
           END IF;  
           --Marcar Sucesso na transacao
           vr_flgtrans:= TRUE; 
         EXCEPTION
           WHEN vr_exc_erro THEN
             --Ignorar registro e continuar
             NULL;
           WHEN OTHERS THEN
             vr_cdcritic:= 0;
             vr_dscritic:= 'Erro ao processar emprestimo: '||sqlerrm;
             RAISE vr_exc_saida;
         END;                                         

         --Se ocorreu erro
         IF NOT vr_flgtrans THEN
           --Se tem erros na tabela
           IF vr_tab_erro.count > 0 THEN
             vr_cdcritic:= 0;
             vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
           ELSIF nvl(vr_cdcritic,0) > 0 THEN 
             vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
           END IF;
           -- Envio centralizado de log de erro
           btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper
                                     ,pr_ind_tipo_log => 2 -- Erro tratato
                                     ,pr_des_log      => to_char(sysdate,'hh24:mi:ss')||' - '
                                                      || vr_cdprogra || ' --> '
                                                      || vr_dscritic );
         END IF;  
       END LOOP; /*  Fim do FOR EACH e da transacao -- Leitura dos emprestimos  */

       --Atualizar informacoes da crapepr com base na temp-table
       BEGIN
         FORALL idx IN INDICES OF vr_tab_crapepr SAVE EXCEPTIONS
           UPDATE crapepr SET crapepr.qtlcalat = vr_tab_crapepr(idx).qtlcalat
                             ,crapepr.qtpcalat = vr_tab_crapepr(idx).qtpcalat
                             ,crapepr.vlsdevat = vr_tab_crapepr(idx).vlsdevat
                             ,crapepr.vlpapgat = vr_tab_crapepr(idx).vlpapgat
                             ,crapepr.vlppagat = vr_tab_crapepr(idx).vlppagat
                             ,crapepr.qtmdecat = vr_tab_crapepr(idx).qtmdecat
           WHERE crapepr.rowid = vr_tab_crapepr(idx).tab_rowid;
       EXCEPTION
         WHEN others THEN
           -- Gerar erro
           vr_dscritic := 'Erro ao atualizar tabela crapsdv. '||
                          SQLERRM(-(SQL%BULK_EXCEPTIONS(1).ERROR_CODE));
           RAISE vr_exc_saida;
       END;

       --Limpar Tabela
       pc_limpa_tabela;
       
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
   END PC_CRPS665;
/

