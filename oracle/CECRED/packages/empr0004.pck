CREATE OR REPLACE PACKAGE CECRED.EMPR0004 AS

  /* -------------------------------------------------------------------------------------------------------------

    Programa: EMPR0004                     Antigo: sistema/generico/procedures/b1wgen0084.p
    Autor   : Irlan
    Data    : Fevereiro/2011               ultima Atualizacao: 25/04/2017
     
    Dados referentes ao programa:
   
    Objetivo  : BO para rotinas do sistema 
                "Novo Produto de Credito com taxa Pre-fixada".
                
    Alteracoes: 10/09/2014 - Conversao Progress -> Oracle (Alisson - AMcom) 
    
                07/04/2015 - Criado procedure pc_obtem_msg_credito_atraso. (Jorge/Rodrigo)            

				25/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							 (Adriano - P339).

..............................................................................*/

    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
      
    --Tipo de Registro para Cabecalho (b1wgen9999tt.i/tt-cabrel) 
    TYPE typ_reg_cabrel IS RECORD
      (nmrescop crapcop.nmrescop%TYPE
      ,nmrelato VARCHAR2(20)
      ,dtmvtref DATE
      ,nmmodulo VARCHAR2(15)
      ,cdrelato INTEGER
      ,progerad VARCHAR2(10)
      ,dtmvtolt DATE
      ,dshoraat VARCHAR2(20)
      ,nmdestin VARCHAR2(40));
    TYPE typ_tab_cabrel IS TABLE OF typ_reg_cabrel INDEX BY PLS_INTEGER;
          
    --Tipo de Registro para dados do Cooperado (b1wgen0001tt.i/tt-dados_cooperado) 
    TYPE typ_reg_dados_cooperado IS RECORD 
      (nmextcop crapcop.nmextcop%TYPE
      ,inpessoa crapass.inpessoa%TYPE
      ,nmprimtl crapass.nmprimtl%TYPE
      ,nrcpfcgc crapass.nrcpfcgc%TYPE
      ,nrdconta crapass.nrdconta%TYPE
      ,cdagenci crapass.cdagenci%TYPE
      ,nmresage crapage.nmresage%TYPE
      ,vllimcre crapass.vllimcre%TYPE);
    TYPE typ_tab_dados_cooperado IS TABLE OF typ_reg_dados_cooperado INDEX BY PLS_INTEGER;
    
    
    
          
    --Tipo de Registro para Taxas de Juros  (b1wgen0001tt.i/tt-taxajuros) 
    TYPE typ_reg_taxa_juros IS RECORD
      (dslcremp craptax.dslcremp%TYPE
      ,txmensal craptax.txmensal%TYPE);  
    TYPE typ_tab_taxa_juros IS TABLE OF typ_reg_taxa_juros INDEX BY PLS_INTEGER;
    
        
    --Tipo de Registro para Totais Futuros  (b1wgen0003tt.i/tt-totais-futuros) 
    TYPE typ_reg_totais_futuros IS RECORD    
      (vllautom NUMBER
      ,vllaudeb NUMBER
      ,vllaucre NUMBER);
    TYPE typ_tab_totais_futuros IS TABLE OF typ_reg_totais_futuros INDEX BY PLS_INTEGER;
    
        
    --Tipo de Registro para Lancamentos Futuros  (b1wgen0003tt.i/tt-lancamento_futuro) 
    TYPE typ_reg_lancamento_futuro IS RECORD   
      (dtmvtolt DATE
      ,dshistor VARCHAR2(50)
      ,nrdocmto VARCHAR2(11)
      ,indebcre VARCHAR2(1)
      ,vllanmto NUMBER(25,2)
      ,dsmvtolt VARCHAR2(10));
    TYPE typ_tab_lancamento_futuro IS TABLE OF typ_reg_lancamento_futuro INDEX BY PLS_INTEGER;
    

    --Tipo de Registro para Extrato de investimento  (b1wgen0020tt.i/tt-extrato_inv) 
    TYPE typ_reg_extrato_inv IS RECORD   
      (dtmvtolt craplci.dtmvtolt%type
      ,dshistor craphis.dshistor%type
      ,nrdocmto craplci.nrdocmto%type
      ,indebcre craphis.indebcre%type
      ,vllanmto craplci.vllanmto%type
      ,vlsldtot NUMBER
      ,cdbloque VARCHAR2(1000)
      ,dsextrat craphis.dsextrat%type);
    TYPE typ_tab_extrato_inv IS TABLE OF typ_reg_extrato_inv INDEX BY PLS_INTEGER;

    --Tipo de Registro para parcela Emprestimo (b1wgen0084tt.i/tt-parcelas-epr) 
    TYPE typ_reg_parcela_epr IS RECORD
      (cdcooper crapcop.cdcooper%TYPE
      ,nrdconta crapass.nrdconta%TYPE
      ,nrctremp crappep.nrctremp%TYPE
      ,nrparepr INTEGER
      ,vlparepr NUMBER
      ,dtparepr DATE
      ,indpagto INTEGER
      ,dtvencto DATE
			,dtultpag crappep.dtultpag%TYPE
			,vlsdvpar crappep.vlsdvpar%TYPE
			);  
    TYPE typ_tab_parcela_epr IS TABLE OF typ_reg_parcela_epr INDEX BY PLS_INTEGER;
     
    --Tipo de Registro para Data da parcela do Emprestimo (b1wgen0084tt.i/tt-datas-parcelas) 
    TYPE typ_tab_datas_parcelas IS TABLE OF DATE INDEX BY PLS_INTEGER;
    
    --Tipo de Registro para Extrato de Emprestimo (b1wgen0002tt.i/tt-extrato_epr) 
    TYPE typ_reg_extrato_epr IS RECORD
      (nrdconta crapass.nrdconta%TYPE
      ,dtmvtolt craplem.dtmvtolt%TYPE
      ,cdagenci craplem.cdagenci%TYPE
      ,cdbccxlt craplem.cdbccxlt%TYPE
      ,nrdolote craplem.nrdolote%TYPE
      ,dshistor VARCHAR2(4000)
      ,dshistoi VARCHAR2(4000)
      ,nrdocmto craplem.nrdocmto%TYPE
      ,indebcre VARCHAR2(1)
      ,vllanmto craplem.vllanmto%TYPE 
      ,txjurepr craplem.txjurepr%TYPE 
      ,qtpresta NUMBER
      ,tpemprst crapepr.tpemprst%TYPE
      ,nrparepr crappep.nrparepr%TYPE 
      ,cdhistor craphis.cdhistor%TYPE
      ,nrseqdig craplem.nrseqdig%TYPE
      ,flgsaldo BOOLEAN DEFAULT TRUE
      ,dsextrat VARCHAR2(4000)
      ,flglista BOOLEAN DEFAULT TRUE
      ,nranomes INTEGER);  
    TYPE typ_tab_extrato_epr IS TABLE OF typ_reg_extrato_epr INDEX BY PLS_INTEGER;
    
    --Tipo de Registro para Extrato de Emprestimo Auxiliar (b1wgen0112tt.i/tt-extrato_epr_aux) 
    TYPE typ_reg_extrato_epr_aux IS RECORD
      (nrdconta crapass.nrdconta%TYPE
      ,dtmvtolt craplem.dtmvtolt%TYPE
      ,cdagenci craplem.cdagenci%TYPE
      ,cdbccxlt craplem.cdbccxlt%TYPE
      ,nrdolote craplem.nrdolote%TYPE
      ,dshistor VARCHAR2(4000)
      ,nrdocmto craplem.nrdocmto%TYPE
      ,indebcre VARCHAR2(1)
      ,vllanmto craplem.vllanmto%TYPE 
      ,txjurepr craplem.txjurepr%TYPE 
      ,qtpresta NUMBER
      ,nrparepr VARCHAR2(100)
      ,vldebito craplem.vllanmto%type 
      ,vlcredit craplem.vllanmto%type 
      ,vlsaldo  craplem.vllanmto%type 
      ,dsextrat VARCHAR2(4000)
      ,flglista BOOLEAN DEFAULT TRUE);  
    TYPE typ_tab_extrato_epr_aux IS TABLE OF typ_reg_extrato_epr_aux INDEX BY PLS_INTEGER;

    --Tipo de Tabela para armazenar decimais  
    TYPE typ_tab_number IS TABLE OF NUMBER INDEX BY PLS_INTEGER;
    
    --Tipo de Tabela para armazenar totais do mes (b1wgen0001tt.i/tt-tarifas) 
    TYPE typ_reg_tarifas IS RECORD
       (vlrdomes typ_tab_number);
    TYPE typ_tab_tarifas IS TABLE OF typ_reg_tarifas INDEX BY craphis.dsexthst%TYPE;
        
    --Tipo de Tabela para armazenar extrato aplicacoes rdca (b1wgen0081tt.i/tt-extr-rdca) 
    TYPE typ_reg_extrato_rdca IS RECORD
       (dtmvtolt DATE
       ,dshistor VARCHAR2(100)
       ,nrdocmto INTEGER
       ,indebcre VARCHAR2(1)
       ,vllanmto NUMBER
       ,vlsldapl NUMBER
       ,txaplica NUMBER
       ,dsaplica VARCHAR2(100)
       ,cdagenci INTEGER
       ,vlpvlrgt VARCHAR2(100)
       ,cdhistor INTEGER
       ,tpaplrdc INTEGER
       ,dsextrat VARCHAR2(100));
    TYPE typ_tab_extrato_rdca IS TABLE OF typ_reg_extrato_rdca INDEX BY PLS_INTEGER;

    --Tipo de Tabela para armazenar extrato da poupanca (b1wgen0006tt.i/tt-extr-rpp) 
    TYPE typ_reg_extrato_rpp IS RECORD
       (dtmvtolt DATE
       ,dshistor VARCHAR2(100)
       ,nrdocmto INTEGER
       ,indebcre VARCHAR2(1)
       ,vllanmto NUMBER
       ,vlsldppr NUMBER
       ,txaplica NUMBER
       ,txaplmes NUMBER
       ,cdagenci INTEGER
       ,cdbccxlt INTEGER
       ,nrdolote INTEGER
       ,dsextrat VARCHAR2(100));    
    TYPE typ_tab_extrato_rpp IS TABLE OF typ_reg_extrato_rpp INDEX BY PLS_INTEGER;
    
    --Tipo de Tabela para armazenar extrato cotas (b1wgen0021tt.i/tt-extrato_cotas) 
    TYPE typ_reg_extrato_cotas IS RECORD
      (dtmvtolt DATE
      ,dshistor VARCHAR2(100)
      ,nrdocmto NUMBER
      ,nrctrpla NUMBER
      ,indebcre VARCHAR2(1)
      ,vllanmto NUMBER
      ,vlsldtot NUMBER
      ,cdagenci INTEGER
      ,cdbccxlt INTEGER
      ,nrdolote INTEGER
      ,dsextrat VARCHAR2(1000));
    TYPE typ_tab_extrato_cotas IS TABLE OF typ_reg_extrato_cotas INDEX BY PLS_INTEGER;
    
    --Tipo de Tabela para armazenar extrato IR (b1wgen0112tt.i/tt-extrato_ir) 
    TYPE typ_reg_extrato_ir IS RECORD
      (nrcpfcgc VARCHAR2(100)
      ,nrdconta crapass.nrdconta%type
      ,nmprimtl crapass.nmprimtl%type
      ,cdagenci crapass.cdagenci%type
      ,nmsegntl crapttl.nmextttl%type
      ,dsanoant VARCHAR2(10)
      ,dtrefer1 DATE
      ,vlsdapl1 NUMBER
      ,vlsdccd1 NUMBER
      ,vlsddve1 NUMBER
      ,vlttcca1 NUMBER
      ,dtrefer2 DATE
      ,vlsdapl2 NUMBER
      ,vlsdccd2 NUMBER
      ,vlsddve2 NUMBER
      ,vlttcca2 NUMBER
      ,vlrendim NUMBER
      ,nmextcop crapcop.nmextcop%type
      ,nrdocnpj VARCHAR2(100)
      ,dsendcop VARCHAR2(100)
      ,dsendcop##1 VARCHAR2(100)
      ,dsendcop##2 VARCHAR2(100)
      ,dscpmfpg VARCHAR2(100)
      ,vlcpmfpg NUMBER
      ,vldoirrf NUMBER
      ,cdagectl crapcop.cdagectl%type
      ,nmcidade VARCHAR2(100)
      ,regexis1 BOOLEAN
      ,dsagenci VARCHAR2(100)
      ,dtmvtolt DATE
      ,dtmvtol1 DATE
      ,vlsddvem NUMBER
      ,vlsdccdp NUMBER
      ,vlsdapli NUMBER
      ,vlttccap NUMBER
      ,qtjaicmf NUMBER
      ,qtjaicm1 NUMBER
      ,vlrenap1 NUMBER
      ,vlmoefix NUMBER(35,8)
      ,vlmoefi1 NUMBER(35,8)
      ,dscooper VARCHAR2(100)
      ,dstelcop VARCHAR2(100)
      ,vlrenapl NUMBER
      ,flganter BOOLEAN
      ,vlrencot NUMBER
      ,vlirfcot NUMBER
      ,anirfcot NUMBER);
    TYPE typ_tab_extrato_ir IS TABLE OF typ_reg_extrato_ir INDEX BY PLS_INTEGER;
    
    --Tipo de Tabela para armazenar retençao de IR (b1wgen0112tt.i/tt-retencao_ir) 
    TYPE typ_reg_retencao_ir IS RECORD
      (nrcpfbnf VARCHAR2(18)
      ,nmmesref VARCHAR2(3)
      ,cdretenc VARCHAR2(100)
      ,dsretenc VARCHAR2(100)
      ,vlrentot NUMBER
      ,vlirfont NUMBER);   
    TYPE typ_tab_retencao_ir IS TABLE OF typ_reg_retencao_ir INDEX BY PLS_INTEGER;

    --Tipo de Registro para Extrato de Cheques do Associado  (b1wgen0001tt.i/tt-extrato_cheque) 
    TYPE typ_reg_extrato_cheque IS RECORD 
      (dtmvtolt VARCHAR2(10)
      ,nrdocmto crapchd.nrdocmto%TYPE
      ,cdbanchq crapchd.cdbanchq%TYPE
      ,cdagechq crapchd.cdagechq%TYPE
      ,nrctachq crapchd.nrctachq%TYPE
      ,nrcheque crapchd.nrcheque%TYPE
      ,nrddigc3 crapchd.nrddigc3%TYPE
      ,vlcheque crapchd.vlcheque%TYPE
      ,vltotchq NUMBER);
    TYPE typ_tab_extrato_cheque IS TABLE OF typ_reg_extrato_cheque INDEX BY PLS_INTEGER;

    --Subrotina para Validar Emprestimo Tipo 1
    PROCEDURE pc_valida_empr_tipo1 (pr_cdcooper  IN crapcop.cdcooper%TYPE      --Codigo Cooperativa
                                   ,pr_cdagenci  IN crapass.cdagenci%TYPE      --Codigo Agencia
                                   ,pr_nrdcaixa  IN INTEGER                    --Numero do Caixa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE      --Numero da Conta do Associado
                                   ,pr_nrctremp  IN INTEGER                    --Numero Contrato Emprestimo
                                   ,pr_des_reto  OUT VARCHAR2                  --Retorno OK ou NOK
                                   ,pr_tab_erro  OUT gene0001.typ_tab_erro);   --Tabela de Erros  
                                   
    --Subrotina para buscar parcelas proposta 
    PROCEDURE pc_busca_parcelas_proposta (pr_cdcooper   IN crapcop.cdcooper%TYPE       --Codigo Cooperativa
                                        ,pr_cdagenci    IN crapass.cdagenci%TYPE       --Codigo Agencia
                                        ,pr_nrdcaixa    IN INTEGER                     --Numero do Caixa
                                        ,pr_cdoperad    IN VARCHAR2                    --Codigo Operador
                                        ,pr_nmdatela    IN VARCHAR2                    --Nome da Tela
                                        ,pr_idorigem    IN INTEGER                     --Origem dos Dados
                                        ,pr_nrdconta    IN crapass.nrdconta%TYPE       --Numero da Conta do Associado
                                        ,pr_idseqttl    IN INTEGER                     --Sequencial do Titular
                                        ,pr_dtmvtolt    IN DATE                        --Data Movimento
                                        ,pr_flgerlog    IN BOOLEAN                     --Imprimir log
                                        ,pr_nrctremp    IN crapepr.nrctremp%TYPE       --Contrato Emprestimo
                                        ,pr_cdlcremp    IN crapepr.cdlcremp%TYPE       --Linha Credito
                                        ,pr_vlemprst    IN crapepr.vlemprst%TYPE       --Valor Emprestimo
                                        ,pr_qtparepr    IN crapepr.qtpreemp%TYPE       --Quantidade parcelas emprestimo
                                        ,pr_dtlibera    IN DATE                        --Data Liberacao
                                        ,pr_dtdpagto    IN DATE                        --Data pagamento 
                                        ,pr_parcela_epr OUT typ_tab_parcela_epr        -->Tipo de tabela com parcelas emprestimo
                                        ,pr_des_reto    OUT VARCHAR2                   --Retorno OK ou NOK
                                        ,pr_tab_erro    OUT gene0001.typ_tab_erro);    --Tabela de Erros                                     
                                    
   --Subrotina para verificar dias de atraso em operacao de credito e retornar mensagem caso ocorra
    PROCEDURE pc_obtem_msg_credito_atraso (pr_cdcooper  IN crapcop.cdcooper%TYPE      --Codigo Cooperativa
                                          ,pr_cdagenci  IN crapass.cdagenci%TYPE      --Codigo Agencia
                                          ,pr_nrdcaixa  IN INTEGER                    --Numero do Caixa
                                          ,pr_cdoperad  IN VARCHAR2                   --Codigo Operador
                                          ,pr_nmdatela  IN VARCHAR2                   --Nome da Tela
                                          ,pr_idorigem  IN INTEGER                    --Origem dos Dados
                                          ,pr_cdprogra  IN VARCHAR2                   --Codigo Nome programa 
                                          ,pr_nrdconta  IN crapass.nrdconta%TYPE      --Numero da Conta do Associado
                                          ,pr_idseqttl  IN INTEGER                    --Sequencial do Titular
                                          ,pr_cdcritic  OUT INTEGER                   --Codigo de critica  
                                          ,pr_dscritic  OUT VARCHAR2);                --Descricao de critica
    
END EMPR0004;
/

CREATE OR REPLACE PACKAGE BODY CECRED.EMPR0004 AS

  /* -------------------------------------------------------------------------------------------------------------

    Programa: EMPR0004                     Antigo: sistema/generico/procedures/b1wgen0084.p
    Autor   : Irlan
    Data    : Fevereiro/2011               ultima Atualizacao: 08/08/2017
     
    Dados referentes ao programa:
   
    Objetivo  : BO para rotinas do sistema 
                "Novo Produto de Credito com taxa Pre-fixada".
   
    Alteracoes: 27/06/2011 - Incluidos procedimentos para tratativas de 
                             antecipacao e estorno, cfme, novo calculo de 
                             parcelas de emprestimos;
                           - Incluida validacao de utilizacao de novo calculo
                             de emprestimo para curto ou longo prazo
                             (GATI - Diego B./Eder).
                             
                21/07/2011 - Inclusao de procedimentos para obtencao e 
                             manipulacao de dados de parcelas da proposta.
                             (GATI - Diego B.)
                             
                22/07/2011 - Procedimentos referentes a efetivacao
                 de 
                             proposta. (GATI - Diego B.)
                
                10/08/2011 - Retirada de rotinas de aprovacao de proposta.
                             (GATI - Diego B.)
                             
                15/08/2011 - Utilizar fixo Cooperativa = 3 na busca dos 
                             parametros ao validar utilizacao do novo calculo.
                             (GATI - Diego B.)
                             
                17/08/2011 - Desenvolvimento da rotina de impressao de 
                             extratos - imprime extrato. (GATI - Diego B.)
                             
                30/08/2011 - Adicionado novo parametro par_intpextr na rotina
                             de impressao de extrato (imprime extrato), esse 
                             parametro diz se o relatorio sera simplificado 
                             (sem impressao de historico) ou detalhado (com 
                             impressao de historico) sendo que 1 = simplificado
                             e 2 = detalhado. (GATI - Diego B.)
                             
                19/09/2011 - Adicionado codigo da linha de credito (cdlcremp)
                             como parametro (par_cdlcremp) da procedure de 
                             validacao de novo calculo  (valida_novo_calculo).
                           - Adicionado validacao de linha de credito na 
                             procedure de validacao de novo calculo 
                             (valida_novo_calculo). (GATI - Diego B.)
                             
                22/09/2011 - Alteração da procedure verifica_alcada para 
                             verifica_alcada_estorno. (GATI - Vitor)     
                             
                04/10/2011 - Foram retiradas as procedures
                             verifica alcada estorno,
                             busca antecipacao parcela,
                             gera antecipacao parcela,
                             calcula antecipacao parcela,
                             efetiva antecipacao parcela,
                             valida antecipacao parcela,
                             gera estorno lancamento,
                             efetiva estorno lancamento,
                             valida estorno lancamento,
                             busca lancamentos parcela,
                             busca pagamentos parcelas e
                             gera pagamentos_parcelas, pois foi criada a BO
                             b1wgen0084a.
                           - Alterada mensagem de erro gerada apos execucao
                             da valida_novo_calculo
                           - Efetuadas correcoes no relatorio gerado pela
                             procedure imprime extrato.
                           - Corrigida logica que define quantidade de dias
                             de carencia, agora considerando sempre o
                             calendario comercial, meses com 30 dias  
                           - Retirado parametro aux_permnovo da procedure
                             valida_novo_calculo, e adicionado retorno mais
                             especifico de erros.
                             (GATI - Oliver)
                
                24/01/2012 - Problema de Handle preso (Oscar)
                
                25/01/2012 - Código desnecessario busca dados efetivacao proposta (Oscar)
                
                10/02/2012 - Correção na procedure 'valida_dados_efetivacao_proposta'
                             para gerar crítica 36 como limitador de acesso. (Lucas)
                             
                23/02/2012 - Implementado novo parametro para a rotina
                             valida_novo_calculo. (Tiago)             
                
                28/02/2012 - Incluido critica 946. (Tiago)
                
                29/02/2012 - Incluido funcao fnValidaEmprTipo1. (Tiago)
                
                05/03/2012 - Alterada efetivacao da proposta (Gabriel)
                
                23/03/2012 - Tratamento para composicao do saldo do extrato
                             tt-extrato_epr.flgsaldo (Tiago)
                             
                04/04/2012 - Incluir campo dtlibera , e campo vlsdvpar (Gabriel)             
                
                17/04/2012 - Retirada a procedure imprime extrato (Tiago).
                
                11/05/2012 - Adicionar a função fnBuscaDataDoUltimoDiaUtilMes (Oscar).

                29/11/2012 - Tratar campo vlsdvsji (Gabriel).

                10/04/2013 - Incluido a chamada da procedure alerta_fraude
                             dentro das procedures grava_efetivacao_proposta,
                             valida_dados_efetivacao_proposta (Adriano).

                04/06/2013 - 2a Fase Projeto Credito (Gabriel).     

                16/07/2013 - Voltar os historicos 1032, 1033 na efetivacao
                             da proposta (Gabriel)                  

                21/08/2013 - Nao criar historicos 1032, 1033 na efetivacao
                             da proposta e separar historicos de emprestimo
                             e financiamento (Lucas).

               11/09/2013 - Incluir os pacs liberados para emprestimos
                            prefixados. (Irlan) 

               18/10/2013 - GRAVAMES - Valida bens alienados no 
                            grava_efetivacao_proposta (Guilherme/SUPERO).
                            
               25/10/2013 - Realizado ajuste para retirar o bloqueio de 
                            emprestimos Pre-fixado da cooperativa Viacredi e
                            incluido a cooperativa Acredicoop.
                            Procedures alterdadas:
                            - valida_dados_efetivacao_proposta
                            (Adriano)

               29/10/2013 - Incluido cdcooper e tpctrato na consulta do
                            avalista terceiro na consulta da efetivacao.
                            (Irlan).
                            
               01/11/2013 - Ajustes:
                            - valida_novo_calculo: bloquear a criacao de 
                              emprestimos Prefixado com linhas de credito CDC
                            - grava_efetivacao_proposta: inclusao do parametro
                              cdpactra na chamada da cria_lancamento_lem
                            (Adriano).
                            
               28/11/2013 - Ajuste na procedure valida_novo_calculo para
                            incluir restricao da linha de emprestimo
                            (Adriano).
                            
               17/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)                          
               
               10/02/2014 - Retirado restricao da Acredi para afetivar 
                            propostas Prefixadas.(Irlan)
                            
               11/03/2014 - Ajuste para gravar o campo crapepr.qttolatr na
                            procedure "grava_efetivacao_proposta" (James)
                            
               10/04/2014 - Ajuste em proc. criar_emprestimo_avalista, retirado
                            critica de nao encontrado associado quando verificado
                            avalista. (Jorge) (liberado em emergencial Abril)
                            
               29/04/2014 - Ajuste de verificacao da nova proposta na procedure 
                            "valida_alteracao_numero_proposta_parcelas".(James) 
                             
               10/09/2014 - Conversao Progress -> Oracle (Alisson - AMcom)
               
               08/04/2015 - Criado proc. pc_obtem_msg_credito_atraso. (Jorge/Rodrigo)

               08/08/2017 - Remocao da pc_calcula_emprestimo e pc_gera_parcelas_emprest.
                            (Jaison/James - PRJ298)

..............................................................................*/

    --Subrotina para Validar Emprestimo Tipo 1
    PROCEDURE pc_valida_empr_tipo1 (pr_cdcooper  IN crapcop.cdcooper%TYPE      --Codigo Cooperativa
                                   ,pr_cdagenci  IN crapass.cdagenci%TYPE      --Codigo Agencia
                                   ,pr_nrdcaixa  IN INTEGER                    --Numero do Caixa
                                   ,pr_nrdconta  IN crapass.nrdconta%TYPE      --Numero da Conta do Associado
                                   ,pr_nrctremp  IN INTEGER                    --Numero Contrato Emprestimo
                                   ,pr_des_reto  OUT VARCHAR2                  --Retorno OK ou NOK
                                   ,pr_tab_erro  OUT gene0001.typ_tab_erro) IS --Tabela de Erros

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_valida_empr_tipo1            Antigo: procedures/b1wgen0134.p/valida_empr_tipo1 
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2014                           Ultima atualizacao: 15/07/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo   : Procedure para Validar Emprestimo Tipo 1
  --
  -- Alterações : 15/07/2014 - Conversão Progress -> Oracle (Alisson - AMcom)
  --              
  ---------------------------------------------------------------------------------------------------------------
      -- Buscar cadastro auxiliar de emprestimo
      CURSOR cr_crawepr (pr_cdcooper IN crawepr.cdcooper%type,
                         pr_nrdconta IN crawepr.nrdconta%type,
                         pr_nrctremp IN crawepr.nrctremp%type) is
        SELECT crawepr.tpemprst
              ,crawepr.rowid
        FROM crawepr crawepr
        WHERE crawepr.cdcooper = pr_cdcooper
        AND   crawepr.nrdconta = pr_nrdconta
        AND   crawepr.nrctremp = pr_nrctremp
        AND   crawepr.tpemprst = 1;
      rw_crawepr cr_crawepr%rowtype;
      --Variaveis de Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecoes
      vr_exc_erro EXCEPTION;
    BEGIN
      --Limpar tabelas memoria
      pr_tab_erro.DELETE;
      --Consultar Emprestimo
      OPEN cr_crawepr (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr INTO rw_crawepr;
      --Se nao Encontrou
      IF cr_crawepr%NOTFOUND THEN
        --Fechar Cursor
        CLOSE cr_crawepr;  
        --mensagem Critica
        vr_cdcritic:= 946;
        vr_dscritic:= NULL;
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Retorno não OK
        pr_des_reto := 'NOK';
        --Sair Programa
        RETURN;                     
      END IF;
      --Fechar Cursor
      CLOSE cr_crawepr; 
      --Retorno OK
      pr_des_reto:= 'OK';  
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Chamar rotina de gravação de erro
        vr_dscritic := 'Erro na pc_valida_empr_tipo1 --> '|| sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
    END pc_valida_empr_tipo1; 

    --Subrotina para calcular a data de vencimento de cada parcela
    PROCEDURE pc_calcula_data_parcela (pr_cdcooper      IN crapcop.cdcooper%TYPE    --Codigo Cooperativa
                                       ,pr_dtvencto     IN DATE                     --Data de Pagamento
                                       ,pr_nrparcel     IN INTEGER                  --Numero de parcelas
                                       ,pr_data_parcela OUT typ_tab_datas_parcelas  --Tabela com parcelas emprestimo
                                       ,pr_des_reto     OUT VARCHAR2                --Retorno OK ou NOK
                                       ,pr_dscritic     OUT VARCHAR2) IS            --Descricao do Erro 
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_calcula_data_parcela            Antigo: procedures/b1wgen0084.p/calcula_data_parcela
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2014                           Ultima atualizacao: 14/07/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
   -- Objetivo   : Procedure para calcular a data de vencimento de cada parcela
  --
  -- Alterações : 14/07/2014 - Conversão Progress -> Oracle (Alisson - AMcom)
  --              
  ---------------------------------------------------------------------------------------------------------------
      --Variaveis locais
      vr_dtcalcul DATE;
      vr_dia      INTEGER;
      vr_mes      INTEGER;
      vr_ano      INTEGER;
      --Variaveis de Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
    BEGIN
      --Limpar tabelas memoria
      pr_data_parcela.DELETE;
      --Inicializar variaveis
      vr_dtcalcul:= pr_dtvencto;
      vr_dia:= to_number(to_char(vr_dtcalcul,'DD'));
      vr_mes:= to_number(to_char(vr_dtcalcul,'MM'));
      vr_ano:= to_number(to_char(vr_dtcalcul,'YYYY'));
      --Percorrer todas as parcelas
      FOR idx IN 1..pr_nrparcel LOOP
        --Se for dia 29 ou mais
        IF vr_dia >= 29 THEN
          /*  Se nao existir o dia no mes, joga o vencimento para o ultimo deste mesmo mes. */
          BEGIN
            vr_dtcalcul:= TO_DATE(lpad(vr_dia,2,'0')||lpad(vr_mes,2,'0')||vr_ano,'DDMMYYYY');
          EXCEPTION
            WHEN OTHERS THEN
              vr_dtcalcul:= LAST_DAY(TRUNC(TO_DATE(lpad(vr_mes,2,'0')||vr_ano,'MMYYYY')));
          END;    
        ELSE
          --Data calculada
          vr_dtcalcul:= TO_DATE(lpad(vr_dia,2,'0')||lpad(vr_mes,2,'0')||vr_ano,'DDMMYYYY');
        END IF; 
        --Popular tabela com a data da parcela
        pr_data_parcela(idx):= vr_dtcalcul;
        --Se for Dezembro
        IF vr_mes = 12 THEN 
          --Usar janeiro
          vr_mes:= 1;
          --Incrementar Ano
          vr_ano:= vr_ano + 1;
        ELSE
          --Incrementar Mes 
          vr_mes:= vr_mes + 1;
        END IF;      
      END LOOP;  
      --Retorno OK
      pr_des_reto:= 'OK';  
    EXCEPTION
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Chamar rotina de gravação de erro
        pr_dscritic := 'Erro na pc_calcula_data_parcela --> '|| sqlerrm;
    END pc_calcula_data_parcela; 


    --Subrotina para buscar parcelas proposta 
    PROCEDURE pc_busca_parcelas_proposta (pr_cdcooper   IN crapcop.cdcooper%TYPE       --Codigo Cooperativa
                                        ,pr_cdagenci    IN crapass.cdagenci%TYPE       --Codigo Agencia
                                        ,pr_nrdcaixa    IN INTEGER                     --Numero do Caixa
                                        ,pr_cdoperad    IN VARCHAR2                    --Codigo Operador
                                        ,pr_nmdatela    IN VARCHAR2                    --Nome da Tela
                                        ,pr_idorigem    IN INTEGER                     --Origem dos Dados
                                        ,pr_nrdconta    IN crapass.nrdconta%TYPE       --Numero da Conta do Associado
                                        ,pr_idseqttl    IN INTEGER                     --Sequencial do Titular
                                        ,pr_dtmvtolt    IN DATE                        --Data Movimento
                                        ,pr_flgerlog    IN BOOLEAN                     --Imprimir log
                                        ,pr_nrctremp    IN crapepr.nrctremp%TYPE       --Contrato Emprestimo
                                        ,pr_cdlcremp    IN crapepr.cdlcremp%TYPE       --Linha Credito
                                        ,pr_vlemprst    IN crapepr.vlemprst%TYPE       --Valor Emprestimo
                                        ,pr_qtparepr    IN crapepr.qtpreemp%TYPE       --Quantidade parcelas emprestimo
                                        ,pr_dtlibera    IN DATE                        --Data Liberacao
                                        ,pr_dtdpagto    IN DATE                        --Data pagamento 
                                        ,pr_parcela_epr OUT typ_tab_parcela_epr        -->Tipo de tabela com parcelas emprestimo
                                        ,pr_des_reto    OUT VARCHAR2                   --Retorno OK ou NOK
                                        ,pr_tab_erro    OUT gene0001.typ_tab_erro) IS  --Tabela de Erros

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_busca_parcelas_proposta            Antigo: procedures/b1wgen0084.p/busca_parcelas_proposta
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Alisson C. Berrido - Amcom
  --  Data     : Julho/2014                           Ultima atualizacao: 11/07/2014
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo   : Procedure para buscar parcelas proposta 
  --
  -- Alterações : 11/07/2014 - Conversão Progress -> Oracle (Alisson - AMcom)
  --              
  ---------------------------------------------------------------------------------------------------------------
      -- Buscar cadastro auxiliar de emprestimo
      CURSOR cr_crawepr (pr_cdcooper IN crawepr.cdcooper%type,
                         pr_nrdconta IN crawepr.nrdconta%type,
                         pr_nrctremp IN crawepr.nrctremp%type) is
        SELECT dtlibera
        FROM crawepr
        WHERE crawepr.cdcooper = pr_cdcooper
        AND crawepr.nrdconta   = pr_nrdconta
        AND crawepr.nrctremp   = pr_nrctremp;
      rw_crawepr cr_crawepr%rowtype;
    
      -- Busca as parcelas do contrato de emprestimos e seus respectivos valores
      CURSOR cr_crappep (pr_cdcooper IN crawepr.cdcooper%TYPE
                        ,pr_nrdconta IN crawepr.nrdconta%TYPE
                        ,pr_nrctremp IN crawepr.nrctremp%TYPE) is
        SELECT crappep.cdcooper
              ,crappep.nrdconta
              ,crappep.nrctremp
              ,crappep.nrparepr
              ,crappep.vlparepr
              ,crappep.dtvencto
              ,crappep.inliquid
							,crappep.dtultpag
							,crappep.vlsdvpar
        FROM crappep crappep
        WHERE crappep.cdcooper = pr_cdcooper
        AND crappep.nrdconta   = pr_nrdconta
        AND crappep.nrctremp   = pr_nrctremp; 
      --Variaveis Locais
      vr_dstransa VARCHAR2(100);
      vr_dsorigem VARCHAR2(100);
      vr_nrdrowid ROWID;
      --Variaveis de indices
      vr_index PLS_INTEGER;
      --Variaveis de Erro
      vr_cdcritic INTEGER;
      vr_dscritic VARCHAR2(4000);
      --Variaveis de Excecoes
      vr_exc_erro EXCEPTION;
    BEGIN
      --Limpar tabelas memoria
      pr_tab_erro.DELETE;
      pr_parcela_epr.DELETE;
      
      --Inicializar transacao
      vr_dsorigem:= gene0001.vr_vet_des_origens(pr_idorigem);
      vr_dstransa:= 'Buscar parcelas da proposta.';
      --Consultar Emprestimo
      OPEN cr_crawepr (pr_cdcooper => pr_cdcooper
                      ,pr_nrdconta => pr_nrdconta
                      ,pr_nrctremp => pr_nrctremp);
      FETCH cr_crawepr INTO rw_crawepr;
      --Se Encontrou
      IF cr_crawepr%FOUND THEN
        --Selecionar as Parcelas do Emprestimo
        FOR rw_crappep IN cr_crappep (pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrctremp => pr_nrctremp) LOOP
          --Incrementar Indice 
          vr_index:= pr_parcela_epr.count + 1;
          pr_parcela_epr(vr_index).cdcooper:= rw_crappep.cdcooper;
          pr_parcela_epr(vr_index).nrdconta:= rw_crappep.nrdconta;
          pr_parcela_epr(vr_index).nrctremp:= rw_crappep.nrctremp;
          pr_parcela_epr(vr_index).nrparepr:= rw_crappep.nrparepr;
          pr_parcela_epr(vr_index).vlparepr:= rw_crappep.vlparepr;
          pr_parcela_epr(vr_index).dtparepr:= rw_crappep.dtvencto;
          pr_parcela_epr(vr_index).indpagto:= rw_crappep.inliquid;
          pr_parcela_epr(vr_index).dtvencto:= rw_crappep.dtvencto;
					pr_parcela_epr(vr_index).dtultpag:= rw_crappep.dtultpag;
					pr_parcela_epr(vr_index).vlsdvpar:= rw_crappep.vlsdvpar;
        END LOOP;                             
      END IF;
      --Fechar Cursor
      CLOSE cr_crawepr;                   
      
      -- Se foi solicitado geração de LOG
      IF pr_flgerlog THEN
        -- Chamar geração de LOG
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => NULL
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> TRUE
                            ,pr_hrtransa => gene0002.fn_busca_time
                            ,pr_idseqttl => pr_idseqttl
                            ,pr_nmdatela => pr_nmdatela
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);
      END IF;    
      --Retorno OK
      pr_des_reto:= 'OK';  
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Chamar rotina de gravação de erro
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado geração de LOG
        IF pr_flgerlog THEN
          -- Chamar geração de LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => GENE0001.vr_vet_des_origens(pr_idorigem)
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;  
      WHEN OTHERS THEN
        -- Retorno não OK
        pr_des_reto := 'NOK';
        -- Chamar rotina de gravação de erro
        vr_dscritic := 'Erro na pc_busca_parcelas_proposta --> '|| sqlerrm;
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => 0 --> Critica 0
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);
        -- Se foi solicitado geração de LOG
        IF pr_flgerlog THEN
          -- Chamar geração de LOG
          gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                              ,pr_cdoperad => pr_cdoperad
                              ,pr_dscritic => vr_dscritic
                              ,pr_dsorigem => GENE0001.vr_vet_des_origens(pr_idorigem)
                              ,pr_dstransa => vr_dstransa
                              ,pr_dttransa => TRUNC(SYSDATE)
                              ,pr_flgtrans => 0 --> FALSE
                              ,pr_hrtransa => gene0002.fn_busca_time
                              ,pr_idseqttl => pr_idseqttl
                              ,pr_nmdatela => pr_nmdatela
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrdrowid => vr_nrdrowid);
        END IF;    
    END pc_busca_parcelas_proposta; 


    --Subrotina para verificar operacao de credito em atraso
    PROCEDURE pc_obtem_msg_credito_atraso (pr_cdcooper  IN crapcop.cdcooper%TYPE      --Codigo Cooperativa
                                          ,pr_cdagenci  IN crapass.cdagenci%TYPE      --Codigo Agencia
                                          ,pr_nrdcaixa  IN INTEGER                    --Numero do Caixa
                                          ,pr_cdoperad  IN VARCHAR2                   --Codigo Operador
                                          ,pr_nmdatela  IN VARCHAR2                   --Nome da Tela
                                          ,pr_idorigem  IN INTEGER                    --Origem dos Dados
                                          ,pr_cdprogra  IN VARCHAR2                   --Codigo nome do programa
                                          ,pr_nrdconta  IN crapass.nrdconta%TYPE      --Numero da Conta do Associado
                                          ,pr_idseqttl  IN INTEGER                    --Sequencial do Titular
                                          ,pr_cdcritic  OUT INTEGER                   --Codigo de critica
                                          ,pr_dscritic  OUT VARCHAR2) IS              --Descricao de critica

  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : pc_obtem_msg_credito_atraso
  --  Sistema  : 
  --  Sigla    : CRED
  --  Autor    : Jorge Issamu Hamaguchi
  --  Data     : Abril/2015                           Ultima atualizacao: 08/08/2017
  --
  -- Dados referentes ao programa:
  --
  -- Frequencia: -----
  -- Objetivo   : Procedure para verificar operacao de credito em atraso
  --
  -- Alterações : 08/08/2017 - Inclusao do produto Pos-Fixado. (Jaison/James - PRJ298)
  --              
  ---------------------------------------------------------------------------------------------------------------
      
      -- Busca dos dados do associado
      CURSOR cr_crapass (pr_cdcooper IN crapass.cdcooper%type,
                         pr_nrdconta IN crapass.nrdconta%type)IS
             SELECT crapass.inpessoa
                   ,crapass.nmprimtl
             FROM   crapass
             WHERE  crapass.cdcooper = pr_cdcooper
             AND    crapass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
      
      CURSOR cr_craptrf IS
             SELECT craptrf.nrdconta
             FROM   craptrf
             WHERE  craptrf.cdcooper = pr_cdcooper
             AND    craptrf.nrdconta = pr_nrdconta
             AND    craptrf.tptransa = 1
             AND    craptrf.insittrs = 2;
      rw_craptrf cr_craptrf%ROWTYPE;
             
      -- cursor genérico de calendário
      rw_crapdat btch0001.cr_crapdat%ROWTYPE;
      
      CURSOR cr_crapepr (pr_nrctremp IN crapepr.nrctremp%TYPE) IS
             SELECT crapepr.tpdescto
                   ,crapepr.dtdpagto
             FROM   crapepr
             WHERE  crapepr.cdcooper = pr_cdcooper
             AND    crapepr.nrdconta = pr_nrdconta
             AND    crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
      
      CURSOR cr_crapfer (pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
             SELECT crapfer.dtferiad 
             FROM   crapfer
             WHERE  crapfer.cdcooper = pr_cdcooper
             AND    crapfer.dtferiad = pr_dtmvtolt;
      rw_crapfer cr_crapfer%ROWTYPE;
                    
      CURSOR cr_crapavl IS 
             SELECT crapavl.nrdconta,
                    crapavl.nrctaavd,
                    crapavl.nrctravd,
                    crapepr.inprejuz,
                    crapepr.vlsdprej,
                    crapepr.inliquid,
                    crapepr.tpdescto,
                    crapepr.dtdpagto 
             FROM   crapavl, crapepr
             WHERE  crapavl.cdcooper = pr_cdcooper
             AND    crapavl.nrdconta = pr_nrdconta
             AND    crapavl.tpctrato = 1
             AND    crapepr.cdcooper = pr_cdcooper
             AND    crapepr.nrdconta = crapavl.nrctaavd
             AND    crapepr.nrctremp = crapavl.nrctravd;
      rw_crapavl cr_crapavl%ROWTYPE;
      
      CURSOR cr_crapcyc (pr_cdcooper IN crapass.cdcooper%TYPE,
                         pr_nrdconta IN crapass.nrdconta%TYPE,
                         pr_nrctremp IN crapcyc.nrctremp%TYPE) IS
             SELECT crapcyc.flgehvip 
             FROM   crapcyc
             WHERE  crapcyc.cdcooper = pr_cdcooper
             AND    crapcyc.nrdconta = pr_nrdconta
             AND    crapcyc.nrctremp = pr_nrctremp;
      rw_crapcyc cr_crapcyc%ROWTYPE;
      
      --Variaveis para uso nos Indices
      vr_index_epr VARCHAR2(100);
      --Tabela de Memoria de dados emprestimo
      vr_tab_dados_epr empr0001.typ_tab_dados_epr;
      vr_tab_erro gene0001.typ_tab_erro;      
      
      
      --Variaveis de Erro
      vr_cdcritic INTEGER := 0;
      vr_dscritic VARCHAR2(4000);
      vr_des_reto VARCHAR2(3);
      
      --Variaveis de Excecoes
      vr_exc_erro EXCEPTION;
      vr_next_reg EXCEPTION;
      
      --variaveis gerias
      vr_qtregist NUMBER := 0;
      vr_flferiad NUMBER := 0;
      vr_qtempatr NUMBER := 0;
      vr_qtdiadev NUMBER := 0;
      vr_dsmsgdev VARCHAR2(500);
      vr_qtdiade2 NUMBER := 0;
      vr_dsmsgde2 VARCHAR2(500);
      vr_qtdiaavl NUMBER := 0;
      vr_dsmsgavl VARCHAR2(500);
      vr_qtdiaav2 NUMBER := 0;
      vr_dsmsgav2 VARCHAR2(500);
      vr_flmsgtaa NUMBER := 0;
      vr_flmsgiba NUMBER := 0;
      vr_flgehvip NUMBER := 0;
      vr_dsconteu VARCHAR2(500);
      vr_numerror NUMBER := 0;
      vr_dsmsgatr VARCHAR2 (4000);
      
    BEGIN
      
      --Buscar Data do Sistema para a cooperativa 
      OPEN btch0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH btch0001.cr_crapdat INTO rw_crapdat;
      --Se nao encontrou
      IF btch0001.cr_crapdat%NOTFOUND THEN
        -- Fechar Cursor
        CLOSE btch0001.cr_crapdat;
        -- montar mensagem de critica
        vr_cdcritic:= 1;
        vr_dscritic:= NULL;
        -- Levantar Excecao
        RAISE vr_exc_erro;
      ELSE
        -- apenas fechar o cursor
        CLOSE btch0001.cr_crapdat;
      END IF;   
    
      -- Busca dos dados do associado
      OPEN  cr_crapass(pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapass INTO rw_crapass;       
      -- Se não encontrar
      IF cr_crapass%NOTFOUND THEN 
        -- Fechar o cursor
        CLOSE cr_crapass;
        -- Gerar erro com critica 9
        vr_cdcritic := 9;
        vr_dscritic := gene0001.fn_busca_critica(9);
        RAISE vr_exc_erro;
      END IF;
      -- Fechar o cursor
      CLOSE cr_crapass;

      -- Busca se conta foi transferida
      OPEN  cr_craptrf;
      FETCH cr_craptrf INTO rw_craptrf;
      -- Se não encontrar
      IF cr_craptrf%FOUND THEN  
        -- Fechar o cursor
        CLOSE cr_craptrf;
        vr_cdcritic := 0;
        vr_dscritic := 'Conta transferida para ' || gene0002.fn_mask_conta(rw_craptrf.nrdconta);
        RAISE vr_exc_erro;
      END IF;
      -- Fechar o cursor
      CLOSE cr_craptrf;
      
      --  Busca quantidade dias de atraso em operacao de credito para devedor (PRIMEIRA MENSAGEM) 
      tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                            ,pr_cdbattar => 'DDMSG1DEVE'
                                            ,pr_dsconteu => vr_dsconteu
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_reto
                                            ,pr_tab_erro => vr_tab_erro);
      -- verifica se houve erro no retorno
      IF vr_des_reto = 'NOK' THEN
        vr_dscritic:= 'Problema ao consultar dias de atraso em operacao de credito.(1)';
        RAISE vr_exc_erro;
      END IF;
     
      vr_qtdiadev := to_number(vr_dsconteu);
      
      --  Busca quantidade dias de atraso em operacao de credito para devedor (SEGUNDA MENSAGEM)
      tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                            ,pr_cdbattar => 'DDMSG2DEVE'
                                            ,pr_dsconteu => vr_dsconteu
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_reto
                                            ,pr_tab_erro => vr_tab_erro);
      -- verifica se houve erro no retorno
      IF vr_des_reto = 'NOK' THEN
        vr_dscritic := 'Problema ao consultar dias de atraso em operacao de credito.(2)';
        RAISE vr_exc_erro;
      END IF;
     
      vr_qtdiade2 := to_number(vr_dsconteu);
      
       --  Busca mensagem de atraso em operacao de credito para devedor (PRIMEIRA MENSAGEM)
      tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                            ,pr_cdbattar => 'TXTMSG1DEV'
                                            ,pr_dsconteu => vr_dsconteu
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_reto
                                            ,pr_tab_erro => vr_tab_erro);
      -- verifica se houve erro no retorno
      IF vr_des_reto = 'NOK' THEN
         vr_dscritic := 'Problema ao consultar mensagem de atraso em operacao de credito.(3)';
         RAISE vr_exc_erro;
      END IF;
     
      vr_dsmsgdev := vr_dsconteu;
      
      --  Busca mensagem de atraso em operacao de credito para devedor (SEGUNDA MENSAGEM) 
      tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                            ,pr_cdbattar => 'TXTMSG2DEV'
                                            ,pr_dsconteu => vr_dsconteu
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_reto
                                            ,pr_tab_erro => vr_tab_erro);
      -- verifica se houve erro no retorno
      IF vr_des_reto = 'NOK' THEN
         vr_dscritic := 'Problema ao consultar mensagem de atraso em operacao de credito.(4)';
         RAISE vr_exc_erro;
      END IF;
     
      vr_dsmsgde2 := vr_dsconteu;
      
      --  Busca quantidade dias de atraso em operacao de credito para avalista (PRIMEIRA MENSAGEM) 
      tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                            ,pr_cdbattar => 'DDMSG1AVAL'
                                            ,pr_dsconteu => vr_dsconteu
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_reto
                                            ,pr_tab_erro => vr_tab_erro);
      -- verifica se houve erro no retorno
      IF vr_des_reto = 'NOK' THEN
         vr_dscritic := 'Problema ao consultar dias de atraso em operacao de credito.(5)';
         RAISE vr_exc_erro;
      END IF;
     
      vr_qtdiaavl := to_number(vr_dsconteu);
      
      --  Busca quantidade dias de atraso em operacao de credito para avalista (SEGUNDA MENSAGEM) 
      tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                            ,pr_cdbattar => 'DDMSG2AVAL'
                                            ,pr_dsconteu => vr_dsconteu
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_reto
                                            ,pr_tab_erro => vr_tab_erro);
      -- verifica se houve erro no retorno
      IF vr_des_reto = 'NOK' THEN
         vr_dscritic := 'Problema ao consultar dias de atraso em operacao de credito.(6)';
         RAISE vr_exc_erro;
      END IF;
     
      vr_qtdiaav2 := to_number(vr_dsconteu);
      
      --  Busca mensagem de atraso em operacao de credito para avalista (PRIMEIRA MENSAGEM) 
      tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                            ,pr_cdbattar => 'TXTMSG1AVL'
                                            ,pr_dsconteu => vr_dsconteu
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_reto
                                            ,pr_tab_erro => vr_tab_erro);
      -- verifica se houve erro no retorno
      IF vr_des_reto = 'NOK' THEN
        vr_dscritic := 'Problema ao consultar mensagem de atraso em operacao de credito.(7)';
        RAISE vr_exc_erro;
      END IF;
     
      vr_dsmsgavl := vr_dsconteu;
      
      --  Busca mensagem de atraso em operacao de credito para avalista (SEGUNDA MENSAGEM)
      tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                            ,pr_cdbattar => 'TXTMSG2AVL'
                                            ,pr_dsconteu => vr_dsconteu
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_reto
                                            ,pr_tab_erro => vr_tab_erro);
      -- verifica se houve erro no retorno
      IF vr_des_reto = 'NOK' THEN
         vr_dscritic := 'Problema ao consultar mensagem de atraso em operacao de credito.(8)';
         RAISE vr_exc_erro;
      END IF;
     
      vr_dsmsgav2 := vr_dsconteu;
      
      --  Busca flag para mostrar alerta de atraso no TAA
      tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                            ,pr_cdbattar => 'FLAGMSGTAA'
                                            ,pr_dsconteu => vr_dsconteu
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_reto
                                            ,pr_tab_erro => vr_tab_erro);
      -- verifica se houve erro no retorno
      IF vr_des_reto = 'NOK' THEN
         vr_dscritic := 'Problema ao consultar mensagem de atraso em operacao de credito.(9)';
         RAISE vr_exc_erro;
      END IF;
      
      -- Se nao for para exibir mensagem de alerta atraso no TAA
      IF vr_dsconteu = 'N' AND pr_idorigem = 4 THEN
         RAISE vr_exc_erro;
      END IF;
       
      --  Busca flag para mostrar alerta de atraso no Internet Bank
      tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                            ,pr_cdbattar => 'FLAGMSGIBA'
                                            ,pr_dsconteu => vr_dsconteu
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_reto
                                            ,pr_tab_erro => vr_tab_erro);
      -- verifica se houve erro no retorno
      IF vr_des_reto = 'NOK' THEN
         vr_dscritic := 'Problema ao consultar mensagem de atraso em operacao de credito.(10)';
         RAISE vr_exc_erro;
      END IF;
     
      -- Se nao for para exibir mensagem de alerta atraso no InternetBank
      IF vr_dsconteu = 'N' AND pr_idorigem = 3 THEN
         RAISE vr_exc_erro;
      END IF;
      
      
        
      -- Busca saldo total de emprestimos 
      EMPR0001.pc_obtem_dados_empresti(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                      ,pr_cdagenci => pr_cdagenci         --> Código da agência
                                      ,pr_nrdcaixa => pr_nrdcaixa         --> Número do caixa
                                      ,pr_cdoperad => pr_cdoperad         --> Código do operador
                                      ,pr_nmdatela => pr_nmdatela         --> Nome datela conectada
                                      ,pr_idorigem => pr_idorigem         --> Indicador da origem da chamada
                                      ,pr_nrdconta => pr_nrdconta         --> Conta do associado
                                      ,pr_idseqttl => pr_idseqttl         --> Sequencia de titularidade da conta
                                      ,pr_rw_crapdat => rw_crapdat        --> Vetor com dados de parâmetro (CRAPDAT)
                                      ,pr_dtcalcul => NULL                --> Data solicitada do calculo
                                      ,pr_nrctremp => 0                   --> Número contrato empréstimo
                                      ,pr_cdprogra => pr_cdprogra         --> Programa conectado
                                      ,pr_inusatab => FALSE               --> Indicador de utilização da tabela
                                      ,pr_flgerlog => 'N'                 --> Gerar log S/N
                                      ,pr_flgcondc => FALSE               --> Mostrar emprestimos liquidados sem prejuizo
                                      ,pr_nmprimtl => rw_crapass.nmprimtl --> Nome Primeiro Titular
                                      ,pr_tab_parempctl => ''             --> Dados tabela parametro
                                      ,pr_tab_digitaliza => ''            --> Dados tabela parametro
                                      ,pr_nriniseq => 0                   --> Numero inicial paginacao
                                      ,pr_nrregist => 0                   --> Qtd registro por pagina
                                      ,pr_qtregist => vr_qtregist         --> Qtd total de registros
                                      ,pr_tab_dados_epr => vr_tab_dados_epr  --> Saida com os dados do empréstimo
                                      ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                      ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros
           
      --Se ocorreu erro
      IF vr_des_reto = 'NOK' THEN
        --Se tem erro na tabela 
        IF vr_tab_erro.COUNT > 0 THEN
          vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSE
          vr_dscritic:= 'Nao foi possivel concluir a requisicao';
        END IF;    
        --Sair com erro
        RAISE vr_exc_erro;
      END IF;  
           
      --Buscar primeiro registro da tabela de emprestimos
      vr_index_epr:= vr_tab_dados_epr.FIRST;
      --Se Retornou Dados
      WHILE vr_index_epr IS NOT NULL LOOP
      BEGIN
            --Buscar se contrato eh VIP ou não, caso seja, nao mostra mensagem alerta atraso.
            OPEN cr_crapcyc(pr_cdcooper => pr_cdcooper,
                            pr_nrdconta => pr_nrdconta,
                            pr_nrctremp => vr_tab_dados_epr(vr_index_epr).nrctremp);
            FETCH cr_crapcyc INTO vr_flgehvip;
            -- Fechar Cursor
            CLOSE cr_crapcyc;
            
            -- Se contrato for VIP.
            IF vr_flgehvip = 1 THEN
               RAISE vr_next_reg;
            END IF;      
                  
            IF vr_tab_dados_epr(vr_index_epr).vlsdeved <= 0  THEN
               RAISE vr_next_reg;
            END IF;
             
            OPEN  cr_crapepr(pr_nrctremp => vr_tab_dados_epr(vr_index_epr).nrctremp);
            FETCH cr_crapepr INTO rw_crapepr;
            -- Se não encontrar
            IF cr_crapepr%FOUND        AND 
               rw_crapepr.tpdescto = 2 AND
               rw_crapdat.dtmvtolt < rw_crapepr.dtdpagto THEN  
               -- Fechar o cursor
               CLOSE cr_crapepr;
               RAISE vr_next_reg;
            END IF;
            CLOSE cr_crapepr;
             
            OPEN cr_crapfer(pr_dtmvtolt => vr_tab_dados_epr(vr_index_epr).dtdpagto); 
            FETCH cr_crapfer INTO rw_crapfer;
            IF cr_crapfer%FOUND THEN
               vr_flferiad := 1;
            ELSE
               vr_flferiad := 0;
            END IF;
            CLOSE cr_crapfer;
            
            IF vr_tab_dados_epr(vr_index_epr).tpemprst IN (1,2) THEN -- PP ou POS
               IF vr_tab_dados_epr(vr_index_epr).flgatras = 1 THEN 
                  IF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiade2 THEN
                     vr_numerror := 2;
                     EXIT;
                  ELSIF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiadev THEN
                     vr_numerror := 1;
                  END IF;
               END IF;            
            ELSE
               IF (vr_tab_dados_epr(vr_index_epr).qtmesdec - vr_tab_dados_epr(vr_index_epr).qtprecal) >= 0.01  AND
                   vr_tab_dados_epr(vr_index_epr).dtdpagto < rw_crapdat.dtmvtolt THEN
                    
                   -- se for sabado, domingo ou feriado                  
                   IF to_char(vr_tab_dados_epr(vr_index_epr).dtdpagto,'D') IN (1,7) OR
                      vr_flferiad = 1 THEN
                      IF vr_tab_dados_epr(vr_index_epr).dtdpagto < rw_crapdat.dtmvtoan  THEN
                         IF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiade2 THEN
                            vr_numerror := 2;
                            EXIT;
                         ELSIF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiadev THEN
                            vr_numerror := 1;
                         END IF;
                      END IF;
                   ELSE 
                      IF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiade2 THEN
                         vr_numerror := 2;
                         EXIT;
                      ELSIF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiadev THEN
                         vr_numerror := 1;
                      END IF;
                   END IF;
                ELSE
                   IF vr_tab_dados_epr(vr_index_epr).vlpreapg <> 0                   AND
                      vr_tab_dados_epr(vr_index_epr).dtdpagto <> rw_crapdat.dtmvtolt AND        
                      (vr_tab_dados_epr(vr_index_epr).qtmesdec - vr_tab_dados_epr(vr_index_epr).qtprecal) >= 0.01 THEN 
                     
                      -- se nao for sabado, domingo ou feriado                  
                      IF NOT (to_char(vr_tab_dados_epr(vr_index_epr).dtdpagto,'D') IN (1,7) OR
                              vr_flferiad = 1) THEN
                         IF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiade2 THEN
                            vr_numerror := 2;
                            EXIT;
                         ELSIF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiadev THEN
                            vr_numerror := 1;
                         END IF;
                      END IF; 
                   END IF;
                END IF;      
            END IF;
            
            --Proximo registro  
            vr_index_epr:= vr_tab_dados_epr.NEXT(vr_index_epr);  
            
      EXCEPTION
            WHEN vr_next_reg THEN
                 --Proximo Registro
                 vr_index_epr:= vr_tab_dados_epr.NEXT(vr_index_epr);
            WHEN vr_exc_erro THEN
                 RAISE vr_exc_erro;  
      END;     
      END LOOP;
      
      -- verificar se teve mensagem de atraso Devedor
      IF vr_numerror = 0 THEN
         vr_dsmsgatr := '';
      ELSIF vr_numerror = 1 THEN
         vr_dsmsgatr := vr_dsmsgdev;
      ELSIF vr_numerror = 2 THEN
         vr_dsmsgatr := vr_dsmsgde2;
      END IF;
      
      --Limpar dados de retorno da proc. pc_obtem_dados_empresti
      vr_qtregist := 0;
      vr_tab_dados_epr.DELETE;
      vr_des_reto := '';
      vr_tab_erro.DELETE;
      vr_flferiad := 0;
      vr_index_epr := 0;
      vr_numerror := 0;
      vr_flgehvip := 0;
      
      --Verificar casos em que o cooperado eh Avalista
      FOR rw_crapavl IN cr_crapavl LOOP
          --Buscar se conta AVALISADA eh VIP ou não, caso seja, nao mostra mensagem alerta atraso.
          OPEN cr_crapcyc(pr_cdcooper => pr_cdcooper,
                          pr_nrdconta => rw_crapavl.nrctaavd,
                          pr_nrctremp => rw_crapavl.nrctravd);
          FETCH cr_crapcyc INTO vr_flgehvip;
          -- Fechar Cursor
          CLOSE cr_crapcyc;
          
          -- Se conta AVALISADA for VIP nao exibe mensagem alerta atraso.
          IF vr_flgehvip = 1 THEN
             vr_flgehvip := 0;
             CONTINUE;
          END IF;
          
          IF NOT ((rw_crapavl.inprejuz = 1  AND
                   rw_crapavl.vlsdprej > 0) OR
                   rw_crapavl.inliquid = 0) THEN
             CONTINUE;
          END IF;

          -- Ate 100 emprestimos em atraso
          vr_qtempatr := vr_qtempatr + 1; 
       
          IF  vr_qtempatr > 99  THEN 
              EXIT;
          END IF;
          
          -- Busca dos dados do associado
          OPEN  cr_crapass(pr_cdcooper => pr_cdcooper,
                           pr_nrdconta => rw_crapavl.nrctaavd);
          FETCH cr_crapass INTO rw_crapass;       
          -- Se não encontrar
          IF cr_crapass%NOTFOUND THEN 
            -- Fechar o cursor
            CLOSE cr_crapass;
            -- Gerar erro com critica 9
            vr_cdcritic := 9;
            vr_dscritic := gene0001.fn_busca_critica(9);
            RAISE vr_exc_erro;
          END IF;
          -- Fechar o cursor
          CLOSE cr_crapass;
          
          EMPR0001.pc_obtem_dados_empresti(pr_cdcooper => pr_cdcooper         --> Cooperativa conectada
                                          ,pr_cdagenci => pr_cdagenci         --> Código da agência
                                          ,pr_nrdcaixa => pr_nrdcaixa         --> Número do caixa
                                          ,pr_cdoperad => pr_cdoperad         --> Código do operador
                                          ,pr_nmdatela => pr_nmdatela         --> Nome datela conectada
                                          ,pr_idorigem => pr_idorigem         --> Indicador da origem da chamada
                                          ,pr_nrdconta => rw_crapavl.nrctaavd --> Conta do associado
                                          ,pr_idseqttl => pr_idseqttl         --> Sequencia de titularidade da conta
                                          ,pr_rw_crapdat => rw_crapdat        --> Vetor com dados de parâmetro (CRAPDAT)
                                          ,pr_dtcalcul => NULL                --> Data solicitada do calculo
                                          ,pr_nrctremp => rw_crapavl.nrctravd --> Número contrato empréstimo
                                          ,pr_cdprogra => pr_cdprogra         --> Programa conectado
                                          ,pr_inusatab => FALSE               --> Indicador de utilização da tabela
                                          ,pr_flgerlog => 'N'                 --> Gerar log S/N
                                          ,pr_flgcondc => FALSE               --> Mostrar emprestimos liquidados sem prejuizo
                                          ,pr_nmprimtl => rw_crapass.nmprimtl --> Nome Primeiro Titular
                                          ,pr_tab_parempctl => ''             --> Dados tabela parametro
                                          ,pr_tab_digitaliza => ''            --> Dados tabela parametro
                                          ,pr_nriniseq => 0                   --> Numero inicial paginacao
                                          ,pr_nrregist => 0                   --> Qtd registro por pagina
                                          ,pr_qtregist => vr_qtregist         --> Qtd total de registros
                                          ,pr_tab_dados_epr => vr_tab_dados_epr  --> Saida com os dados do empréstimo
                                          ,pr_des_reto => vr_des_reto         --> Retorno OK / NOK
                                          ,pr_tab_erro => vr_tab_erro);       --> Tabela com possíves erros
             
          --Se ocorreu erro
          IF vr_des_reto = 'NOK' THEN
             --Se tem erro na tabela 
             IF vr_tab_erro.COUNT > 0 THEN
                vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
             ELSE
                vr_dscritic:= 'Nao foi possivel concluir a requisicao';
             END IF;    
             --Sair com erro
             RAISE vr_exc_erro;
          END IF;
            
          --Buscar primeiro registro da tabela de emprestimos
          vr_index_epr:= vr_tab_dados_epr.FIRST;
          --Se nao Retornou Dados
          IF vr_index_epr IS NULL THEN
             vr_dscritic := 'Registro de emprestimo temporario nao encontrado.';
             RAISE vr_exc_erro;
          END IF;
          
          OPEN cr_crapfer(pr_dtmvtolt => vr_tab_dados_epr(vr_index_epr).dtdpagto); 
          FETCH cr_crapfer INTO rw_crapfer;
          IF cr_crapfer%FOUND THEN
             vr_flferiad := 1;
          ELSE
             vr_flferiad := 0;
          END IF;
          CLOSE cr_crapfer;
          
          IF vr_tab_dados_epr(vr_index_epr).tpemprst IN (1,2) THEN -- PP ou POS
             IF vr_tab_dados_epr(vr_index_epr).flgatras = 1 THEN 
                IF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiaav2 THEN
                   vr_numerror := 2;
                   EXIT;
                ELSIF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiaavl THEN
                   vr_numerror := 1;
                END IF;
             END IF;
          ELSE 
             IF rw_crapavl.inprejuz = 1 AND rw_crapavl.vlsdprej > 0  THEN
                IF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiaav2 THEN
                   vr_numerror := 2;
                   EXIT;
                ELSIF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiaavl THEN
                   vr_numerror := 1;
                END IF;
             ELSE
                IF vr_tab_dados_epr(vr_index_epr).vlsdeved <= 0  THEN
                   CONTINUE;
                END IF;    
                    
                IF rw_crapavl.tpdescto = 2 AND 
                   rw_crapdat.dtmvtolt < rw_crapavl.dtdpagto THEN
                   CONTINUE;
                END IF;
                
                IF (vr_tab_dados_epr(vr_index_epr).qtmesdec - 
                    vr_tab_dados_epr(vr_index_epr).qtprecal) >= 0.01       AND
                    vr_tab_dados_epr(vr_index_epr).dtdpagto < rw_crapdat.dtmvtolt THEN
                    IF to_char(vr_tab_dados_epr(vr_index_epr).dtdpagto,'D') IN (1,7) OR 
                       vr_flferiad = 1 THEN
                       IF vr_tab_dados_epr(vr_index_epr).dtdpagto < rw_crapdat.dtmvtoan THEN
                          IF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiaav2 THEN
                             vr_numerror := 2;
                             EXIT;
                          ELSIF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiaavl THEN
                             vr_numerror := 1;
                          END IF;
                       END IF;
                    ELSE 
                        IF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiaav2 THEN
                           vr_numerror := 2;
                           EXIT;
                        ELSIF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiaavl THEN
                           vr_numerror := 1;
                        END IF;
                    END IF;
                ELSE
                    IF vr_tab_dados_epr(vr_index_epr).vlpreapg <> 0 AND
                       vr_tab_dados_epr(vr_index_epr).dtdpagto <> rw_crapdat.dtmvtolt  THEN 
                       -- se nao for sabado, domingo ou feriado                  
                       IF NOT (to_char(vr_tab_dados_epr(vr_index_epr).dtdpagto,'D') IN (1,7) OR
                               vr_flferiad = 1) THEN
                          IF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiaav2 THEN
                             vr_numerror := 2;
                             EXIT;
                          ELSIF (rw_crapdat.dtmvtolt - vr_tab_dados_epr(vr_index_epr).dtdpagto) >= vr_qtdiaavl THEN
                             vr_numerror := 1;
                          END IF;
                       END IF;
                    END IF;
                END IF; 
             END IF;
          END IF; 
                  
      END LOOP;  
      
      -- verificar se teve mensagem de atraso Avalista
      IF vr_numerror = 1 THEN
         IF vr_dsmsgatr IS NULL THEN
            vr_dsmsgatr := vr_dsmsgavl;
         ELSE
            vr_dsmsgatr := vr_dsmsgatr || '|' || vr_dsmsgavl;
         END IF;
      ELSIF vr_numerror = 2 THEN
         IF vr_dsmsgatr IS NULL THEN
            vr_dsmsgatr := vr_dsmsgav2;
         ELSE
            vr_dsmsgatr := vr_dsmsgatr || '|' || vr_dsmsgav2;
         END IF;
      END IF;
      
      IF vr_dsmsgatr IS NOT NULL THEN
         vr_dscritic := vr_dsmsgatr;
         RAISE vr_exc_erro;
      END IF;
       
    EXCEPTION
      WHEN vr_exc_erro THEN
        -- Apenas retornar a variável de saida
        pr_cdcritic := NVL(pr_cdcritic, 0);
        pr_dscritic := vr_dscritic;
        
      WHEN OTHERS THEN
        -- Chamar rotina de gravação de erro
        pr_dscritic := 'Erro na pc_obtem_msg_credito_atraso --> '|| sqlerrm;
    
    END pc_obtem_msg_credito_atraso; 
    
     
END EMPR0004;
/

