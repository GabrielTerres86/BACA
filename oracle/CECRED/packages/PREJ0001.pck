CREATE OR REPLACE PACKAGE CECRED.PREJ0001 AS

/*..............................................................................

   Programa: PREJ0001                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Jean Calão - Mout´S
   Data    : Maio/2017                      Ultima atualizacao: 09/01/2019

   Dados referentes ao programa:

   Frequencia: Diária (sempre que chamada)
   Objetivo  : Centralizar os procedimentos e funcoes referente aos processos de 
               transferência para prejuízo

   Alteracoes: 04/07/2018 - P450 - Adicionada Função para retornar Juros+60 
                            "Data Anterior" para Empréstimos/ financiamentos em prejuízo
                            Daniel(AMcom)

   09/01/2019 - 1) Ajuste reagendamento do processo.
                2) Padrões: 
                Others, Modulo/Action, PC Internal Exception, PC Log Programa
                Inserts, Updates, Deletes e SELECT's, Parâmetros                            
                (Envolti - Belli - PRB00040466)

..............................................................................*/

   TYPE typ_reg_log IS
      RECORD(valor_old crapprm.dsvlrprm%TYPE
            ,valor_new crapprm.dsvlrprm%TYPE);
   
    /* Pl-Table que ira chave e valor dos registros da CRAPPRM */
   TYPE typ_reg_consulta_prm IS
      RECORD(dsvlrprm crapprm.dsvlrprm%TYPE);
   
   TYPE typ_log           IS TABLE OF typ_reg_log          INDEX BY BINARY_INTEGER;         
   TYPE typ_verifica_log  IS TABLE OF typ_log              INDEX BY BINARY_INTEGER;
   TYPE typ_consulta_prm  IS TABLE OF typ_reg_consulta_prm INDEX BY BINARY_INTEGER;
   
    --
    FUNCTION fn_regra_dtprevisao_prejuizo(pr_cdcooper IN crapris.cdcooper%TYPE,
                                          pr_innivris IN crapris.innivris%TYPE,
                                          pr_qtdiaatr IN crapris.qtdiaatr%TYPE, 
                                          pr_dtdrisco IN crapris.dtdrisco%TYPE
                                          ) RETURN DATE;                              
	-- ***
    -- Função para retornar Juros+60 "Data Anterior" para Empréstimos/ financiamentos em prejuízo
    FUNCTION fn_juros60_emprej(pr_cdcooper IN  crapris.cdcooper%TYPE  --> Código da cooperativa
                              ,pr_nrdconta IN  crapris.nrdconta%TYPE  --> Número da conta
                              ,pr_nrctremp IN  crapris.nrctremp%TYPE) --> Número do contrato
                              RETURN NUMBER;
   
    /* Realiza a gravação dos parametros da transferencia para prejuizo informados na tela PARTRP */
    PROCEDURE pc_grava_prm_trp(pr_dsvlrprm1   IN VARCHAR2   --> Data de inicio da vigência
                              ,pr_dsvlrprm2   IN VARCHAR2   --> produto
                              ,pr_dsvlprmgl   IN VARCHAR2   --> operação
                              ,pr_xmllog      IN VARCHAR2   --> XML com informações de LOG
                              ,pr_cdcritic  OUT PLS_INTEGER --> Código da crítica
                              ,pr_dscritic  OUT VARCHAR2    --> Descrição da crítica
                              ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                              ,pr_nmdcampo  OUT VARCHAR2    --> Nome do campo com erro
                              ,pr_des_erro  OUT VARCHAR2);  --> Erros do processo

    /* Realiza a consulta das informacoes de parametros de transferencia para prejuizo - tela PARTRP */
    PROCEDURE pc_consulta_prm_trp(pr_dsvlrprm1   IN VARCHAR2            --> Data de inicio da vigência
                                 ,pr_dsvlrprm2   IN VARCHAR2           --> produto
                                 ,pr_xmllog      IN VARCHAR2           --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER         --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2            --> Descrição da crítica
                                 ,pr_retxml     IN OUT NOCOPY XMLType  --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2            --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2);          --> Erros do processo
    
    /* Rotina de transferencia de contratos de empréstimo - produto PP */
    PROCEDURE pc_transfere_epr_prejuizo_PP(pr_cdcooper in number
                                          ,pr_cdagenci in number
                                          ,pr_nrdcaixa in number
                                          ,pr_cdoperad in varchar2
                                          ,pr_nrdconta in number
                                          ,pr_idseqttl in number
                                          ,pr_dtmvtolt in date
                                          ,pr_nrctremp in number
                                          ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro  );
                                          
    /* Rotina de transferencia de contratos de empréstimo - produto TR */                         
    PROCEDURE pc_transfere_epr_prejuizo_TR(pr_cdcooper in number
                                          ,pr_cdagenci in number
                                          ,pr_nrdcaixa in number
                                          ,pr_cdoperad in varchar2
                                          ,pr_nrdconta in number
                                          ,pr_dtmvtolt in date
                                          ,pr_nrctremp in number
                                          ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro  )    ;
                                          
    /* Rotina de transferencia para prejuízo de contas correntes com estouro  */                                         
/*    Procedure pc_gera_prejuizo_cc(PR_CDCOOPER IN NUMBER DEFAULT NULL
                                  ,PR_NRDCONTA IN NUMBER DEFAULT NULL
                                  ,PR_VLSDDISP in NUMBER DEFAULT NULL);*/
                                                                      
    /* Rotina para estornar transferencia prejuizo PP */
    PROCEDURE pc_estorno_trf_prejuizo_PP(pr_cdcooper in number
                                          ,pr_cdagenci in number
                                          ,pr_nrdcaixa in number
                                          ,pr_cdoperad in varchar2
                                          ,pr_nrdconta in number
                                          ,pr_dtmvtolt in date
                                          ,pr_nrctremp in number
                                          ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro  );
                                          
    /* Rotina para estornar transferencia prejuizo TR */
    PROCEDURE pc_estorno_trf_prejuizo_TR(pr_cdcooper in number
                                          ,pr_cdagenci in number
                                          ,pr_nrdcaixa in number
                                          ,pr_cdoperad in varchar2
                                          ,pr_nrdconta in number
                                          ,pr_dtmvtolt in date
                                          ,pr_nrctremp in number
                                          ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro  );
                                          
     /* Rotina para estornar transferencia prejuizo CC */
/*    PROCEDURE pc_estorno_trf_prejuizo_CC(pr_cdcooper in number
                                          ,pr_cdagenci in number
                                          ,pr_nrdconta in number
                                          ,pr_dtmvtolt in date
                                          ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                          ,pr_tab_erro OUT gene0001.typ_tab_erro  );*/
                                          
    /* rotina executada pela tela Atenda para "forçar" o envio de empréstimos para prejuízo */
    PROCEDURE pc_transfere_prejuizo_web (pr_nrdconta   IN VARCHAR2     --> Conta corrente
                                         ,pr_nrctremp   IN VARCHAR2     --> Contrato de emprestimo
                                         ,pr_xmllog     IN VARCHAR2     --> XML com informações de LOG
                                         ,pr_cdcritic  OUT PLS_INTEGER  --> Código da crítica
                                         ,pr_dscritic  OUT VARCHAR2     --> Descrição da crítica
                                         ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                         ,pr_nmdcampo  OUT VARCHAR2     --> Nome do campo com erro
                                         ,pr_des_erro  OUT VARCHAR2);      
     
     /* Rotina chamada pela Atenda para estornar (desfazer) o prejuízo */                                    
     PROCEDURE pc_estorno_prejuizo_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                        ,pr_nrctremp   IN VARCHAR2  -- contrato
                                        ,pr_idtpoest   in varchar2
                                        ,pr_xmllog      IN VARCHAR2            --> XML com informações de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2)  ;    
     
     /* Rotina chamada pela Atenda para transferir prejuizos de CC */                                   
/*     PROCEDURE pc_transfere_prejuizo_CC_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                        ,pr_xmllog      IN VARCHAR2            --> XML com informações de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2);    */
     
     PROCEDURE pc_consulta_prejuizo_web(pr_dtprejuz in varchar2
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
              						 		 			  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
 				    	          	 		 			  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
						    				         			,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
          			    									,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					              							,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
										              		,pr_des_erro OUT VARCHAR2);
                                      
      PROCEDURE pc_importa_arquivo(pr_arquivo in varchar2
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informac?es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2             --> Descric?o da critica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2);   

      PROCEDURE pc_tela_busca_contratos(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                      ,pr_inprejuz in crapepr.inprejuz%type --> Indicador prejuizo
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2);       
                                      
      PROCEDURE pc_dispara_email_lote (pr_idtipo   IN VARCHAR2  -- Conta corrente
                                        ,pr_nrctremp   IN VARCHAR2  -- contrato
                                        ,pr_xmllog      IN VARCHAR2            --> XML com informações de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2);     

     PROCEDURE pc_controla_exe_job(pr_cdcritic OUT NUMBER,
                                   pr_dscritic OUT VARCHAR2);
                                     
                                                              
end PREJ0001;
/
CREATE OR REPLACE PACKAGE BODY CECRED.PREJ0001 AS
/*..............................................................................

   Programa: PREJ0001                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Jean Calão - Mout´S
     Data    : Maio/2017                      Ultima atualizacao: 09/01/2019

   Dados referentes ao programa:

   Frequencia: Diária (sempre que chamada)
   Objetivo  : Centralizar os procedimentos e funcoes referente aos processos de 
               transferência para prejuízo

   Alteracoes:

   11/06/2018 - INC0014258 Na rotina pc_controla_exe_job, não registrar as validações
                de execução do job como erro, para que o plantão não seja acionado (Carlos)

   23/06/2018 - Rename da tabela tbepr_cobranca para tbrecup_cobranca e filtro tpproduto = 0 (Paulo Penteado GFT)

   24/07/2018 - inc0018036 Melhorias nos fechamentos dos cursores das rotinas 
                pc_transfere_epr_prejuizo_PP, pc_transfere_epr_prejuizo_TR,
                pc_estorno_trf_prejuizo_PP e pc_estorno_trf_prejuizo_TR (Carlos)

     09/11/2018 - Alteração no cálculo dos dias de atraso na pc_transfere_epr_prejuizo_PP
                  (Reginaldo/AMcom/P450)

   09/01/2019 - 1) Ajuste reagendamento do processo.
                2) Padrões: 
                Others, Modulo/Action, PC Internal Exception, PC Log Programa
                Inserts, Updates, Deletes e SELECT's, Parâmetros                            
                (Envolti - Belli - PRB00040466)
  
..............................................................................*/

  vr_cdcritic  NUMBER(3);
  vr_dscritic  VARCHAR2(1000);
  vr_des_reto  VARCHAR2(10);
  vr_tab_erro  gene0001.typ_tab_erro ;
  vr_index     VARCHAR2(100);
  vr_index_calculado NUMBER;
  vr_flgativo  INTEGER;
  vr_flquitado INTEGER;
  --vr_flcancel  integer;
  --gl_nrdolote  craplot.nrdolote%type;
  vr_idfraude  BOOLEAN := FALSE;
  vr_qtregist  NUMBER;
  vr_tab_dados_epr empr0001.typ_tab_dados_epr;
  rw_crapdat   btch0001.cr_crapdat%ROWTYPE;
   
  CURSOR c_crapris(pr_cdcooper IN NUMBER
                  ,pr_nrdconta IN NUMBER
                  ,pr_nrctremp IN NUMBER) IS
    SELECT innivris, 
           dtdrisco
      FROM crapris
     WHERE crapris.cdcooper = pr_cdcooper     
       AND crapris.nrdconta = pr_nrdconta
       AND crapris.nrctremp = pr_nrctremp
       AND crapris.dtrefere = rw_crapdat.dtultdma
       AND crapris.cdorigem = 3
       AND crapris.inddocto = 1;

  CURSOR c_crapepr(pr_cdcooper in number
                  ,pr_nrdconta in number
                  ,pr_nrctremp in number) IS
    SELECT * 
      FROM crapepr
     WHERE crapepr.cdcooper = pr_cdcooper
       AND crapepr.nrdconta = pr_nrdconta
       AND crapepr.nrctremp = pr_nrctremp;
  r_crapepr c_crapepr%ROWTYPE;      
  --           
  CURSOR c_craplcr(pr_cdcooper in number) IS
    SELECT *
      FROM craplcr
     WHERE craplcr.cdcooper = pr_cdcooper
       AND craplcr.cdlcremp = r_crapepr.cdlcremp;
  r_craplcr c_craplcr%ROWTYPE;           
  --           
  CURSOR c_crapcyc(pr_cdcooper IN NUMBER
                  ,pr_nrdconta IN NUMBER
                  ,pr_nrctremp IN NUMBER) IS          
    SELECT 1
      FROM crapcyc 
     WHERE cdcooper = pr_cdcooper
       AND nrdconta = pr_nrdconta
       AND nrctremp = pr_nrctremp
       AND flgehvip = 1
       AND cdmotcin = 2; -- Alteração SM 6                        
  --
  CURSOR cr_crapcop (prc_cdcooper IN crapcop.cdcooper%TYPE) IS
    SELECT c.nmrescop
      FROM crapcop c
     WHERE c.cdcooper = prc_cdcooper;
  --
  FUNCTION f_valida_pagamento_abono(pr_cdcooper in number
                                   ,pr_nrdconta in number
                                   ,pr_nrctremp in number) RETURN BOOLEAN IS
    -- nova M324
    CURSOR cr_craplcm IS
      SELECT SUM(CASE WHEN c.cdhistor IN (2386) THEN c.vllanmto ELSE 0 END) 
             - 
             SUM(CASE WHEN c.cdhistor IN (2387) THEN c.vllanmto ELSE 0 END) valor_pago
        FROM craplcm c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta
         AND to_number(TRIM(REPLACE(c.cdpesqbb,'.',''))) = pr_nrctremp
         AND c.cdhistor in(2386,2387); 
      -- nova M324
    CURSOR cr_craplem IS
      SELECT SUM(CASE WHEN c.cdhistor IN (2391) THEN c.vllanmto ELSE 0 END) 
             - 
             SUM(CASE WHEN c.cdhistor IN (2395) THEN c.vllanmto ELSE 0 END) valor_pago_abono
        FROM craplem c
       WHERE c.cdcooper = pr_cdcooper
         AND c.nrdconta = pr_nrdconta
         AND c.nrctremp = pr_nrctremp
         AND c.cdhistor IN (2391,2395);    
    
    RESULT BOOLEAN;
    
  BEGIN
    RESULT := FALSE;
    FOR rw_craplcm IN cr_craplcm LOOP
      IF rw_craplcm.valor_pago > 0 THEN
        RESULT := TRUE; 
      END IF;
    END LOOP;
    
    FOR rw_craplem IN cr_craplem LOOP
      IF rw_craplem.valor_pago_abono > 0 THEN
        RESULT := TRUE; 
      END IF;
    END LOOP;
  
  RETURN(RESULT);
  END f_valida_pagamento_abono;
  --
  FUNCTION fn_regra_dtprevisao_prejuizo(pr_cdcooper IN crapris.cdcooper%TYPE,
                                        pr_innivris IN crapris.innivris%TYPE,
                                        pr_qtdiaatr IN crapris.qtdiaatr%TYPE, 
                                        pr_dtdrisco IN crapris.dtdrisco%TYPE
                                        ) RETURN DATE IS

        vr_dttrfprj                 DATE;
        vr_dias_no_risco_H          NUMBER;
        vr_data_prevista_risco_H    DATE;
        va_qtdiaatr                 NUMBER;
        vr_data_prevista_dia_atraso DATE;        
  
      BEGIN
        
        /* Busca data de movimento */
        OPEN  btch0001.cr_crapdat(pr_cdcooper);
        FETCH btch0001.cr_crapdat into rw_crapdat;
        CLOSE btch0001.cr_crapdat;      
        
        IF pr_innivris >= 9  THEN
            -- Quantidade de dias em que está em risco 9 - H
            vr_dias_no_risco_H := rw_crapdat.dtmvtolt - pr_dtdrisco;
            -- Calcular a quantidade de dias que ainda falta para completar os 180 dias em risco H
            vr_dias_no_risco_H := 180 - vr_dias_no_risco_H;
            -- Somar ou subtrair da data atual do sistema para ter a data prevista dos 180 dias em H
            vr_data_prevista_risco_H := rw_crapdat.dtmvtolt + vr_dias_no_risco_H;
            --
            -- Calcular a quantidade de dias que ainda falta para completar os 180 dias em atraso
            --va_qtdiaatr := 180 - nvl(rw_crapris_last.qtdiaatr,0);
            va_qtdiaatr := 180 - nvl(pr_qtdiaatr,0);
            -- Somar ou subtrair da data atual do sistema para ter a data prevista dos 180 dias em atraso
            vr_data_prevista_dia_atraso := rw_crapdat.dtmvtolt + va_qtdiaatr;
                
            -- Obter a maior data
            IF TO_NUMBER(TO_CHAR(vr_data_prevista_risco_H,'yyyymmdd')) > 
               TO_NUMBER(TO_CHAR(vr_data_prevista_dia_atraso,'yyyymmdd')) THEN
              vr_dttrfprj := vr_data_prevista_risco_H;
            ELSE
              vr_dttrfprj := vr_data_prevista_dia_atraso;
            END IF;
            --
          /*ELSIF vr_innivris = 9 AND NVL(rw_crapris_dtprev.dttrfprj, NULL) IS NOT NULL THEN
            -- Manter a mesma data
            vr_dttrfprj := rw_crapris_dtprev.dttrfprj;*/
            --
          ELSIF pr_innivris < 9 THEN
            -- Zerar a data prevista para transferencia a prejuizo
            vr_dttrfprj := NULL;
            --
          END IF;        
        --
        -- Retornar data prevista
        RETURN(vr_dttrfprj);
        
      END fn_regra_dtprevisao_prejuizo;  
  --
  -- ***
  -- Função para retornar Juros+60 "Data Anterior" para Empréstimos/ financiamentos em prejuízo
  FUNCTION fn_juros60_emprej(pr_cdcooper IN  crapris.cdcooper%TYPE
                            ,pr_nrdconta IN  crapris.nrdconta%TYPE
                            ,pr_nrctremp IN  crapris.nrctremp%TYPE) RETURN NUMBER IS
		
		CURSOR cr_juro60_pagos (pr_cdcooper crapris.cdcooper%TYPE
                     ,pr_nrdconta crapris.nrdconta%TYPE
                     ,pr_nrctremp crapris.nrctremp%TYPE) IS
		SELECT sum(CASE WHEN h.cdhistor = 2473 THEN h.vllanmto
               ELSE 0 END) 
          - sum(CASE WHEN h.cdhistor = 2474 THEN h.vllanmto
               ELSE 0 END) vllanmto
			FROM craplem h
		 WHERE h.cdhistor IN(2473, 2474)
			 AND cdcooper = pr_cdcooper
			 AND nrdconta = pr_nrdconta
			 AND nrctremp = pr_nrctremp;
		rw_juro60_pagos cr_juro60_pagos%ROWTYPE;															
		
    -- Verifica se existe lançamento para os históricos específicos
    CURSOR cr_juro60_lem (pr_cdcooper crapris.cdcooper%TYPE
                         ,pr_nrdconta crapris.nrdconta%TYPE
                         ,pr_nrctremp crapris.nrctremp%TYPE) IS
       SELECT nvl(SUM(h.vllanmto),0) vljura60
        FROM craplem h
       WHERE h.cdcooper = pr_cdcooper
		  	 AND h.nrdconta = pr_nrdconta
			   AND h.nrctremp = pr_nrctremp
          AND h.cdhistor IN(2402, 2406, 2382, 2397);         
       
    rw_juro60_lem cr_juro60_lem%ROWTYPE;     
		
  BEGIN
    -- Abre cursor cr_juro60_lem
    OPEN cr_juro60_lem(pr_cdcooper, pr_nrdconta, pr_nrctremp); 
   FETCH cr_juro60_lem
    INTO rw_juro60_lem;
   CLOSE cr_juro60_lem;
   
    -- Se existem lançamentos para os históricos específicos
     IF NVL(rw_juro60_lem.vljura60,0) > 0 THEN        
    
        OPEN cr_juro60_pagos(pr_cdcooper, pr_nrdconta, pr_nrctremp); 
       FETCH cr_juro60_pagos  
        INTO rw_juro60_pagos;
       CLOSE cr_juro60_pagos; 
        --
         RETURN(rw_juro60_lem.vljura60 - nvl(rw_juro60_pagos.vllanmto, 0));
  ELSE
    RETURN(0);  -- Garante retorno zero se não houver valor
  END IF;
  --
  END fn_juros60_emprej;

   PROCEDURE pc_grava_prm_trp(pr_dsvlrprm1 IN VARCHAR2  -- Data de inicio da vigência
                             ,pr_dsvlrprm2 IN VARCHAR2  -- produto
                             ,pr_dsvlprmgl IN VARCHAR2  -- Parametro geral
                             ,pr_xmllog    IN VARCHAR2            --> XML com informações de LOG
                             ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                             ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                             ,pr_retxml    IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                             ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                             ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo

   /* .............................................................................

   Programa: pc_grava_prm_trp
   Sistema : AyllosWeb
   Sigla   : PREJ
   Autor   : Jean Calão - Mout´S
   Data    : Maio/2017.                  Ultima atualizacao:

   Dados referentes ao programa:

   Frequencia: Sempre que for chamado

   Objetivo  : Efetua a gravação dos parametros de transferência para prejuízo - tela PARTRP
   Observacao: OS CÓDIGOS DE CRÍTICAS DESTE PROGRAMA SÃO PRÓPRIAS DO MESMO E SÃO
               TRATADAS DIRETAMENTE NO PROGRAMA PHP.

   Alteracoes:
   ..............................................................................*/
    -- Cursores

    CURSOR cr_dados_prm(p_cdcooper crapcop.cdcooper%TYPE
                       ,p_cdacesso crapprm.cdacesso%TYPE) IS
       SELECT prm.dsvlrprm
         FROM crapprm prm
        WHERE prm.cdcooper = p_cdcooper
          AND prm.nmsistem = 'CRED'
          AND prm.cdacesso = p_cdacesso;
    rw_dados_prm cr_dados_prm%ROWTYPE;

    -- Variáveis
    vr_cdcooper         NUMBER;
    vr_nmdatela         VARCHAR2(25);
    vr_nmeacao          VARCHAR2(25);
    vr_cdagenci         VARCHAR2(25);
    vr_nrdcaixa         VARCHAR2(25);
    vr_idorigem         VARCHAR2(25);
    vr_cdoperad         VARCHAR2(25);

    -- campos
    vr_dsvlprmgl        varchar2(240);
    
    vr_nrdrowid    ROWID;
    vr_dsorigem    VARCHAR2(100);

    vr_typ_log          typ_verifica_log;
    vr_typ_consulta_prm typ_consulta_prm;

    -- Excessões
    vr_exc_erro   EXCEPTION;
    wchave        varchar2(24);
    wparam        varchar2(240);

    -- Inicializa pl-table para gravar os parametros
    PROCEDURE pc_grava_parametros IS
    BEGIN
        vr_typ_consulta_prm(1).dsvlrprm  := pr_dsvlrprm1;
        vr_typ_consulta_prm(2).dsvlrprm  := pr_dsvlrprm2;
        vr_typ_consulta_prm(3).dsvlrprm  := pr_dsvlprmgl;
    END;

    -- Função para validar os históricos
    PROCEDURE pr_valida_historico(pr_cdcooper IN     craphis.cdcooper%TYPE
                                 ,pr_cdhistor IN     craphis.cdhistor%TYPE
                                 ,pr_indebcre IN     craphis.indebcre%TYPE
                                 ,pr_cdcritic IN OUT NUMBER
                                 ,pr_dscritic    OUT VARCHAR2) IS

      -- Histórico
      CURSOR cr_craphis IS
        SELECT his.indebcre
          FROM craphis his
         WHERE his.cdcooper = pr_cdcooper
           AND his.cdhistor = pr_cdhistor;

      -- Variáveis
      vr_indebcre         craphis.indebcre%TYPE;

    BEGIN

      -- Validar se o histórico informado é valido
      OPEN  cr_craphis;
      FETCH cr_craphis INTO vr_indebcre;
      -- Se não encontrou registro
      IF cr_craphis%NOTFOUND THEN
        -- Fechar o cursor
        CLOSE cr_craphis;

        -- Retorna erro de histórico não encontrado
        pr_dscritic := 'Historico nao encontrado!';
        -- Nesta situação o cdcritic ira retornar o indice do campo da tela que caiu na validação
        pr_cdcritic := pr_cdcritic + 10; -- Erro de historico não encontrado

        RETURN;
      ELSE
        -- Fechar o cursor
        CLOSE cr_craphis;

        -- Se for histórico de crédito e o histórico não for de débito
        IF pr_indebcre = 'C' AND  vr_indebcre <> 'C' THEN

          -- Retorna erro de histórico não encontrado
          pr_dscritic := 'Historico para tarifa deve ser um historico de credito!';
          RETURN;

        -- Verifica se é um histórico de débito
        ELSIF pr_indebcre = 'D' AND  vr_indebcre <> 'D' THEN

          -- Retorna erro de histórico não encontrado
          pr_dscritic := 'Historico para tarifa deve ser um historico de debito!';
          RETURN;

        END IF;
      END IF;

      -- Limpar os parametros de crítica
      pr_cdcritic := NULL;
      pr_dscritic := NULL;

    END pr_valida_historico;

   BEGIN

    -- Tratar os valores vindos da Web
    vr_dsvlprmgl  := pr_dsvlprmgl;
   
    -- Extrair informacoes padrao do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);

    -- Criar cabecalho do XML
     pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');

     -- Buscando descricao da origem do ambiente
     vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);

     /*-- Validar Histórico transferencia valor principal
     pr_cdcritic := 51; -- Código do erro que será retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm6
                        ,pr_indebcre => 'C' -- Validar como histórico de crédito
                        ,pr_cdcritic => pr_cdcritic -- Código do erro que será retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;

     -- Validar Histórico Estorno valor principal
     pr_cdcritic := 52; -- Código do erro que será retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm7
                        ,pr_indebcre => 'D' -- Validar como histórico de debito
                        ,pr_cdcritic => pr_cdcritic -- Código do erro que será retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;

     -- Validar Histórico transferencia juros + 60
     pr_cdcritic := 53; -- Código do erro que será retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm8
                        ,pr_indebcre => 'C' -- Validar como histórico de crédito
                        ,pr_cdcritic => pr_cdcritic -- Código do erro que será retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;

     -- Validar Histórico estorno juros + 60
     pr_cdcritic := 54; -- Código do erro que será retornado em caso de critica
     pr_valida_historico(pr_cdcooper => vr_cdcooper
                        ,pr_cdhistor => vr_dsvlrprm9
                        ,pr_indebcre => 'D' -- Validar como histórico de débito
                        ,pr_cdcritic => pr_cdcritic -- Código do erro que será retornado em caso de critica
                        ,pr_dscritic => pr_des_erro);
     -- Verifica ocorrencia de erros na validação
     IF pr_des_erro IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;*/
         
     -- Inicializa pl-table para gravar os parametros
     pc_grava_parametros;
     
     wchave := 'PARTRP_' || TO_CHAR(to_date(pr_dsvlrprm1,'dd/mm/yyyy'),'YYYYMMDD') || '_' ||
                pr_dsvlrprm2 ;
         
       OPEN  cr_dados_prm(vr_cdcooper, wchave ); --vr_tab_cdacesso(ind));
       FETCH cr_dados_prm INTO rw_dados_prm;
       
       -- Fecha o cursor
       CLOSE cr_dados_prm;
       
       wparam := vr_dsvlprmgl;
       
       BEGIN
         -- Realizar o update das informações
         UPDATE crapprm prm
            SET prm.dsvlrprm = wparam
          WHERE prm.cdcooper = vr_cdcooper
            AND prm.nmsistem = 'CRED'
            AND prm.cdacesso = wchave;

         -- Se nenhum registro foi atualizado
         IF SQL%ROWCOUNT = 0 THEN
           -- Faz a inserção do parametro
           INSERT INTO crapprm(nmsistem
                              ,cdcooper
                              ,cdacesso
                              ,dstexprm
                              ,dsvlrprm)
                        VALUES('CRED'
                              ,vr_cdcooper
                              ,wchave 
                              ,'Parametros Transferencia Prejuizo' 
                              ,wparam);
         END IF;

       EXCEPTION
         WHEN OTHERS THEN
           pr_des_erro := 'Erro ao atualizar parametros: '||SQLERRM;
       END;

     IF vr_typ_log.EXISTS(1) THEN -- Se foi inserido algum registro
        -- Gerando Log de Consulta
        GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => 'OK'
                            ,pr_dsorigem => vr_dsorigem
                            ,pr_dstransa => 'Inserido Parametrizacao transferencia prejuizo - PARTRP.'
                            ,pr_dttransa => TRUNC(SYSDATE)
                            ,pr_flgtrans => 1 --> SUCESSO/TRUE
                            ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nrdconta => 0
                            ,pr_nrdrowid => vr_nrdrowid);
       
     END IF;
     -- Efetivar as informações
     COMMIT;

   EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer alterações
      ROLLBACK;

      pr_dscritic := pr_des_erro;
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'Parametrizacao Transferência para prejuízo  - PARTRP.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');
    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;
      pr_des_erro := 'Erro geral na rotina pc_grava_prm_partrp: '||SQLERRM;
      pr_dscritic := pr_des_erro;
      pr_nmdcampo := '';
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'Parametrizacao Transferência prejuizo- PARTRP.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Dados>Rotina com erros</Dados></Root>');

   END pc_grava_prm_trp;

   PROCEDURE pc_consulta_prm_trp( pr_dsvlrprm1   IN VARCHAR2  -- Data de inicio da vigência
                                 ,pr_dsvlrprm2   IN VARCHAR2  -- produto
                                 ,pr_xmllog      IN VARCHAR2            --> XML com informações de LOG
                                 ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                 ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                 ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                 ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                 ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo

     /* .............................................................................

      Programa: pc_consulta_prm_trp
      Sistema : AyllosWeb
      Sigla   : PREJ
      Autor   : Jean Calão - Mout´S
      Data    : Maio/2017.                  Ultima atualizacao: 29/05/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Efetua a consulta dos parametros de transferência para prejuizo
      Observacao: -----

      Alteracoes:

     ..............................................................................*/
     -- Cursores
     CURSOR cr_crapprm(pr_cdcooper crapprm.cdcooper%TYPE
                      ,pr_cdacesso crapprm.cdacesso%TYPE) IS
       SELECT prm.dsvlrprm, prm.cdacesso
         FROM crapprm prm
        WHERE prm.cdcooper = pr_cdcooper
          AND prm.nmsistem = 'CRED'
          AND prm.cdacesso like pr_cdacesso;

     -- Variáveis
     vr_cdcooper         NUMBER;
     vr_nmdatela         VARCHAR2(25);
     vr_nmeacao          VARCHAR2(25);
     vr_cdagenci         VARCHAR2(25);
     vr_nrdcaixa         VARCHAR2(25);
     vr_idorigem         VARCHAR2(25);
     vr_cdoperad         VARCHAR2(25);
     vr_dsvlrprm         crapprm.dsvlrprm%TYPE;

     vr_nrdrowid    ROWID;
     vr_dsorigem    VARCHAR2(100);
     vr_dstransa    VARCHAR2(500);
     
     vr_vlprm3      varchar2(4);
     vr_vlprm4      varchar2(4);
     vr_vlprm5      varchar2(4);
     vr_vlprm6      varchar2(4);
     vr_vlprm7      varchar2(4);
     vr_vlprm8      varchar2(4);
     vr_vlprm9      varchar2(4);
     vr_vlprm10     varchar2(4);
     vr_vlprm11     varchar2(4);
     vr_vlprm12     varchar2(4);
     vr_vlprm13     varchar2(4);
     vr_vlprm14     varchar2(4);
     vr_vlprm15     varchar2(4);
     vr_vlprm16     varchar2(4);
     vr_vlprm17     varchar2(4);
     vr_vlprm18     varchar2(4);
     vr_vlprm19     varchar2(4);
     vr_vlprm20     varchar2(4);
     vr_vlprm21     varchar2(4);
     vr_vlprm22     varchar2(4);
     vr_vlprm23     varchar2(4);
     vr_vlprm24     varchar2(4);
     vr_vlprm25     varchar2(4);
     vr_vlprm26     varchar2(4);
     vr_vlprm27     varchar2(4);
     vr_vlprm28     varchar2(4);
     vr_vlprm29     varchar2(4);
     vr_vlprm30     varchar2(4);
     vr_vlprm31     varchar2(4);
     
     -- Excessões
     vr_exc_erro         EXCEPTION;
     
     wchave              varchar2(24);
     WDATA               VARCHAR2(10);

   BEGIN

      -- Extrair informacoes padrao do xml - parametros
      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => pr_dscritic);

      -- Buscando descricao da origem do ambiente
      vr_dsorigem := gene0001.vr_vet_des_origens(vr_idorigem);
      
      if pr_dsvlrprm1 ='00/00/0000' 
      or pr_dsvlrprm1 is null then
         wchave := 'PARTRP_%_' ||
                    pr_dsvlrprm2 ;
      else
         wchave := 'PARTRP_' || TO_CHAR(to_date(pr_dsvlrprm1,'dd/mm/yyyy'),'YYYYMMDD') || '_' ||
                    pr_dsvlrprm2 ;
      end if;
      
        -- Buscar o valor do parametro
        OPEN  cr_crapprm(vr_cdcooper, wchave);
        FETCH cr_crapprm INTO vr_dsvlrprm, wchave;

        -- Se não encontrar retorna erro
        IF cr_crapprm%NOTFOUND THEN
           pr_des_erro := 'Nao foram encontrados parametros de prejuizo para o produto: ' || pr_dsvlrprm2;
           close cr_crapprm;
           raise vr_exc_erro;               
        END IF;
        
        -- Fechar o cursor
        CLOSE cr_crapprm;
                                     
        WDATA := SUBSTR(WCHAVE,8,8);
        WDATA := SUBSTR(WDATA,7,2) || '/' || SUBSTR(WDATA,5,2) || '/' || SUBSTR(WDATA,1,4);
        
        vr_vlprm3 := substr(vr_dsvlrprm,1,4);
        vr_vlprm4 := substr(vr_dsvlrprm,6,4);
        vr_vlprm5 := substr(vr_dsvlrprm,11,4);
        vr_vlprm6 := substr(vr_dsvlrprm,16,4);
        vr_vlprm7 := substr(vr_dsvlrprm,21,4);
        vr_vlprm8 := substr(vr_dsvlrprm,26,4);
        vr_vlprm9 := substr(vr_dsvlrprm,31,4);
        vr_vlprm10:= substr(vr_dsvlrprm,36,4);
        vr_vlprm11:= substr(vr_dsvlrprm,41,4);
        vr_vlprm12:= substr(vr_dsvlrprm,46,4);
        vr_vlprm13:= substr(vr_dsvlrprm,51,4);
        vr_vlprm14:= substr(vr_dsvlrprm,56,4);
        vr_vlprm15:= substr(vr_dsvlrprm,61,4);
        vr_vlprm16:= substr(vr_dsvlrprm,66,4);
        vr_vlprm17:= substr(vr_dsvlrprm,71,4);
        vr_vlprm18:= substr(vr_dsvlrprm,76,4);
        vr_vlprm19:= substr(vr_dsvlrprm,81,4);
        vr_vlprm20:= substr(vr_dsvlrprm,86,4);
        vr_vlprm21:= substr(vr_dsvlrprm,91,4);
        vr_vlprm22:= substr(vr_dsvlrprm,96,4);
        vr_vlprm23:= substr(vr_dsvlrprm,101,4);
        vr_vlprm24:= substr(vr_dsvlrprm,106,4);
        vr_vlprm25:= substr(vr_dsvlrprm,111,4);
        vr_vlprm26:= substr(vr_dsvlrprm,116,4);
        vr_vlprm27:= substr(vr_dsvlrprm,121,4);
        vr_vlprm28:= substr(vr_dsvlrprm,126,4);
        vr_vlprm29:= substr(vr_dsvlrprm,131,4);
        vr_vlprm30:= substr(vr_dsvlrprm,136,4);
        vr_vlprm31:= substr(vr_dsvlrprm,141,4);
        
        -- Retorno XML
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                     '<Root>' ||
                                     '<dsvlrprm1>' ||WDATA ||'</dsvlrprm1>' ||
                                     '<dsvlrprm2>' ||pr_dsvlrprm2 ||'</dsvlrprm2>' ||
                                     '<dsvlrprm3>' ||vr_vlprm3 ||'</dsvlrprm3>' ||
                                     '<dsvlrprm4>' ||vr_vlprm4 ||'</dsvlrprm4>' ||
                                     '<dsvlrprm5>' ||vr_vlprm5 ||'</dsvlrprm5>' ||
                                     '<dsvlrprm6>' ||vr_vlprm6 ||'</dsvlrprm6>' ||
                                     '<dsvlrprm7>' ||vr_vlprm7 ||'</dsvlrprm7>' ||
                                     '<dsvlrprm8>' ||vr_vlprm8 ||'</dsvlrprm8>' ||
                                     '<dsvlrprm9>' ||vr_vlprm9 ||'</dsvlrprm9>' ||
                                     '<dsvlrprm10>'||vr_vlprm10 ||'</dsvlrprm10>' ||
                                     '<dsvlrprm11>'||vr_vlprm11 ||'</dsvlrprm11>' ||
                                     '<dsvlrprm12>'||vr_vlprm12 ||'</dsvlrprm12>' ||
                                     '<dsvlrprm13>'||vr_vlprm13 ||'</dsvlrprm13>' ||
                                     '<dsvlrprm14>'||vr_vlprm14 ||'</dsvlrprm14>' ||
                                     '<dsvlrprm15>'||vr_vlprm15 ||'</dsvlrprm15>' ||
                                     '<dsvlrprm16>'||vr_vlprm16 ||'</dsvlrprm16>' ||
                                     '<dsvlrprm17>'||vr_vlprm17 ||'</dsvlrprm17>' ||
                                     '<dsvlrprm18>'||vr_vlprm18 ||'</dsvlrprm18>' ||
                                     '<dsvlrprm19>'||vr_vlprm19 ||'</dsvlrprm19>' ||
                                     '<dsvlrprm20>'||vr_vlprm20 ||'</dsvlrprm20>' ||
                                     '<dsvlrprm21>'||vr_vlprm21 ||'</dsvlrprm21>' ||
                                     '<dsvlrprm22>'||vr_vlprm22 ||'</dsvlrprm22>' ||
                                     '<dsvlrprm23>'||vr_vlprm23 ||'</dsvlrprm23>' ||
                                     '<dsvlrprm24>'||vr_vlprm24 ||'</dsvlrprm24>' ||
                                     '<dsvlrprm25>'||vr_vlprm25 ||'</dsvlrprm25>' ||
                                     '<dsvlrprm26>'||vr_vlprm26 ||'</dsvlrprm26>' ||
                                     '<dsvlrprm27>'||vr_vlprm27 ||'</dsvlrprm27>' ||
                                     '<dsvlrprm28>'||vr_vlprm28 ||'</dsvlrprm28>' ||
                                     '<dsvlrprm29>'||vr_vlprm29 ||'</dsvlrprm29>' ||
                                     '<dsvlrprm30>'||vr_vlprm30 ||'</dsvlrprm30>' ||
                                     '<dsvlrprm31>'||vr_vlprm31 ||'</dsvlrprm31>' ||
                                     '</Root>');
                                     
      vr_dstransa := 'Buscando Parametrizacao transferencia prejuizo - PARTRP.' || wchave || ':' ||
                     vr_vlprm3 || ';' || vr_vlprm4 ||';'||vr_vlprm23 || ';' || vr_vlprm24 || ';' || 
                     vr_vlprm25|| ';' || vr_vlprm26 || ';' || vr_vlprm27|| ';' || vr_vlprm28 || ';' ||
                     vr_vlprm29|| ';' || vr_vlprm30|| ';' || vr_vlprm31;
      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => 0
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
   EXCEPTION
     WHEN vr_exc_erro THEN
       -- Desfazer alterações
       ROLLBACK;
       pr_dscritic := pr_des_erro;
       -- Retorno não OK
       GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => NVL(pr_dscritic,' ')
                           ,pr_dsorigem => vr_dsorigem
                           ,pr_dstransa => 'Parametrizacao transferencia prejuizo - PARTRP.'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nrdconta => 0
                           ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Dados>Rotina com erros</Dados></Root>');
     WHEN OTHERS THEN
       -- Desfazer alterações
       ROLLBACK;
       pr_des_erro := 'Erro geral na rotina pc_consulta_prm_trp: '|| SQLERRM;
       pr_dscritic := pr_des_erro;
       pr_cdcritic := 0;
       pr_nmdcampo := '';
       -- Retorno não OK
       GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => NVL(pr_dscritic,' ')
                           ,pr_dsorigem => vr_dsorigem
                           ,pr_dstransa => 'Parametrizacao transferencia prejuizo - PARTRP.'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nrdconta => 0
                           ,pr_nrdrowid => vr_nrdrowid);
       -- Commit do LOG
       COMMIT;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
       pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                      '<Root><Dados>Rotina com erros</Dados></Root>');
   END pc_consulta_prm_trp;

   Procedure pc_bloqueio_conta_corrente(pr_cdcooper in number
                                       , pr_nrdconta in number
                                       , pr_cdorigem in number -- 1 - Conta ; 2 - Emprestimos
                                       , pr_dscritic out varchar2) is
     vr_erro exception;
    begin
      pr_dscritic := 'OK';
      -- Bloqueio cartao magnetico
      BEGIN
        UPDATE CRAPCRM
        SET    CRAPCRM.CDSITCAR = 4 -- Bloqueado
        ,      CRAPCRM.DTCANCEL = rw_crapdat.Dtmvtolt
        ,      crapcrm.dttransa = trunc(sysdate)
        WHERE  CRAPCRM.CDCOOPER = PR_CDCOOPER
        AND    CRAPCRM.NRDCONTA = PR_NRDCONTA
        AND    CRAPCRM.CDSITCAR NOT IN (3,4);
      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao cancelar cartao magnetico: ' || sqlerrm;
          raise vr_erro;
        
      END;
     
     /* -- Bloqueio cartao credito
      BEGIN
        UPDATE CRAWCRD
        SET    CRAWCRD.INSITCRD = 6 -- Encerrado
        ,      CRAWCRD.Dtcancel = rw_crapdat.Dtmvtolt
        WHERE  CRAWCRD.CDCOOPER = PR_CDCOOPER
        AND    CRAWCRD.NRDCONTA = PR_NRDCONTA
        AND    CRAWCRD.INSITCRD NOT IN (5,6);
      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao cancelar cartao credito: ' || sqlerrm;
          raise vr_erro;
        
      END;*/
     
      -- Bloqueio senha internet
      BEGIN
        UPDATE CRAPSNH
        SET    CRAPSNH.CDSITSNH = 2 -- Bloqueado
        ,      CRAPSNH.dtblutsh = rw_crapdat.Dtmvtolt
        ,      crapsnh.dtaltsit = rw_crapdat.Dtmvtolt
        WHERE  CRAPSNH.CDCOOPER = PR_CDCOOPER
        AND    CRAPSNH.NRDCONTA = PR_NRDCONTA
        AND    CRAPSNH.CDSITSNH = 1 -- Ativa
        and    crapsnh.tpdsenha = 1 -- Internet
        and    crapsnh.idseqttl = 1; -- primeiro titular
      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao cancelar senha internet: ' || sqlerrm;
          raise vr_erro;
        
      END;
      -- Solicitado pela Fernanda por e-mail dia 28/03/2018
/*      -- Cancelamento Limite de Crédito
      BEGIN
        UPDATE CRAPLIM
        SET    CRAPLIM.INSITLIM = 3 -- Cancelado
        ,      CRAPLIM.DTFIMVIG = rw_crapdat.Dtmvtolt
        WHERE  CRAPLIM.CDCOOPER = PR_CDCOOPER
        AND    CRAPLIM.NRDCONTA = PR_NRDCONTA
        AND    CRAPLIM.INSITLIM = 2; -- Ativa;        
        
      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao cancelar LIMITE: ' || sqlerrm;
          raise vr_erro;
        
      END;*/
      
      BEGIN
        UPDATE CRAPMCR
        SET    CRAPMCR.DTCANCEL = rw_crapdat.Dtmvtolt
        WHERE  CRAPMCR.CDCOOPER = PR_CDCOOPER
        AND    CRAPMCR.NRDCONTA = PR_NRDCONTA
        AND    CRAPMCR.TPCTRMIF = 2;     
        
      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao cancelar LIMITE: ' || sqlerrm;
          raise vr_erro;
        
      END;
      
    exception
      when vr_erro then  
           pr_dscritic := 'erro na rotina de bloqueio de contas';
           
    end pc_bloqueio_conta_corrente;
   
   Procedure pc_reabrir_conta_corrente(pr_cdcooper in number
                                      ,pr_nrdconta in number
                                      ,pr_cdorigem in number -- 1 - Conta ; 2 - Emprestimos
                                      ,pr_dtprejuz in date
                                      ,pr_dscritic out varchar2) is
     vr_erro     exception;
        
    begin
      pr_dscritic := 'OK';
      -- Desbloqueio cartao magnetico
      BEGIN
        UPDATE CRAPCRM
        SET    CRAPCRM.CDSITCAR = 2 -- Ativo
        ,      CRAPCRM.DTCANCEL = null
        ,      crapcrm.dttransa = pr_dtprejuz
        WHERE  CRAPCRM.CDCOOPER = PR_CDCOOPER
        AND    CRAPCRM.NRDCONTA = PR_NRDCONTA
        AND    CRAPCRM.CDSITCAR = 4; -- bloequeado
      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao desbloquear cartao magnetico: ' || sqlerrm;
          raise vr_erro;
        
      END;
     
      -- desbloqueio senha internet
      BEGIN
        UPDATE CRAPSNH
        SET    CRAPSNH.CDSITSNH = 1 -- Ativa
        ,      CRAPSNH.Dtblutsh = null
        ,      crapsnh.dtaltsnh = pr_dtprejuz
        WHERE  CRAPSNH.CDCOOPER = PR_CDCOOPER
        AND    CRAPSNH.NRDCONTA = PR_NRDCONTA
        AND    CRAPSNH.CDSITSNH = 2 -- Cancelada
        and    crapsnh.tpdsenha = 1 -- Internet
        and    crapsnh.idseqttl = 1; -- primeiro titular
      EXCEPTION
        when others then
          pr_dscritic := 'Erro ao reativar senha internet: ' || sqlerrm;
          raise vr_erro;
        
      END;
      
    exception
      when vr_erro then  
           pr_dscritic := 'erro na rotina de bloqueio de contas';
           
    end pc_reabrir_conta_corrente;
    
  PROCEDURE pc_transfere_epr_prejuizo_PP(pr_cdcooper in number
                                      ,pr_cdagenci in number
                                      ,pr_nrdcaixa in number
                                      ,pr_cdoperad in varchar2
                                      ,pr_nrdconta in number
                                      ,pr_idseqttl in number
                                      ,pr_dtmvtolt in date
                                      ,pr_nrctremp in number
                                      ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                      ,pr_tab_erro OUT gene0001.typ_tab_erro  ) is
    /* .............................................................................

    Programa: pc_transfere_epr_prejuizo_PP
    Sistema : AyllosWeb / Rotina PC_CRPS780
    Sigla   : PREJ
    Autor   : Jean Calão - Mout´S
    Data    : Maio/2017.                  Ultima atualizacao: 09/11/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetua as transferencias de contratos PP para prejuízo 
    Observacao: Rotina chamada pela tela Atenda ou rotina automatica.

    Alteracoes: 22/01/2018 - Identação do código e ajustes conforme SM 6 Melhoria 324 
                             (Rafael Monteiro - Mout'S)
                             
                05/07/2018 - Pagamento de IOF no Atraso (Marcos-Envolti)

                09/11/2018 - Alteração no cálculo dos dias em atraso do contrato
                             (Reginaldo/AMcom/P450)
    
    ..............................................................................*/                                        
    
    -- Busca das parcelas
    CURSOR C_CRAPPEP IS
      SELECT CRAPPEP.CDCOOPER,
             CRAPPEP.NRDCONTA,
             CRAPPEP.NRCTREMP,
             CRAWEPR.DTLIBERA,
             CRAWEPR.TPEMPRST
        FROM CRAPPEP, CRAWEPR
       WHERE CRAWEPR.CDCOOPER(+) = CRAPPEP.CDCOOPER
         AND CRAWEPR.NRDCONTA(+) = CRAPPEP.NRDCONTA
         AND CRAWEPR.NRCTREMP(+) = CRAPPEP.NRCTREMP
         AND CRAPPEP.CDCOOPER = PR_CDCOOPER
         AND CRAPPEP.NRDCONTA = PR_NRDCONTA
         AND CRAPPEP.NRCTREMP = PR_NRCTREMP
         AND CRAPPEP.INLIQUID = 0
         AND CRAPPEP.INPREJUZ = 0;
    RW_CRAPPEP C_CRAPPEP%ROWTYPE;
  
    -- Calcula a quantidade de dias de atraso de um contrato
    -- (Reginaldo/AMcom/P450) - 09/11/2018
    CURSOR C_ATRASO(PR_CDCOOPER CRAPPEP.CDCOOPER%TYPE,
                    PR_NRDCONTA CRAPPEP.NRDCONTA%TYPE,
                    PR_NRCTREMP CRAPPEP.NRCTREMP%TYPE) IS
      SELECT RW_CRAPDAT.DTMVTOLT - MIN(PEP.DTVENCTO) QTDIAATR
        FROM CRAPPEP PEP, CRAPASS ASS
       WHERE PEP.CDCOOPER = PR_CDCOOPER
         AND PEP.NRDCONTA = PR_NRDCONTA
         AND PEP.NRCTREMP = PR_NRCTREMP
         AND (PEP.INLIQUID = 0 OR PEP.INPREJUZ = 1)
         AND PEP.DTVENCTO <= RW_CRAPDAT.DTMVTOAN
         AND ASS.CDCOOPER = PEP.CDCOOPER
         AND ASS.NRDCONTA = PEP.NRDCONTA
         AND ASS.CDAGENCI = DECODE(0, 0, ASS.CDAGENCI, 0);
    
    --    
    CURSOR c_crapris (pr_cdcooper craplem.cdcooper%TYPE 
                     ,pr_nrdconta craplem.nrdconta%TYPE
                     ,pr_nrctremp craplem.nrctremp%TYPE) IS
                         
      SELECT nvl(qtdiaatr,0) + 1 
        FROM crapris ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.nrdconta = pr_nrdconta
         AND ris.nrctremp = pr_nrctremp
         AND ris.dtrefere = rw_crapdat.dtmvtoan;
    --      
    CURSOR cr_craplem_60 (pr_qtdiaatr IN NUMBER) IS
      SELECT NVL(SUM(lem.vllanmto),0)
        FROM craplem lem
       WHERE lem.cdcooper = pr_cdcooper
         AND lem.nrdconta = pr_nrdconta
         AND lem.nrctremp = pr_nrctremp
         AND lem.cdhistor IN (1037,1038)
         AND lem.dtmvtolt > rw_crapdat.dtmvtolt - (pr_qtdiaatr - 59);  

    --Selecionar Lancamentos
    vr_vlttmupr        crapepr.vlttmupr%TYPE;
    vr_vlttjmpr        crapepr.vlttjmpr%TYPE;
    vr_vltiofpr        crapepr.vltiofpr%TYPE;
    vr_vlsdeved        crapepr.vlsdeved%TYPE;
    vr_vlajsdvd        NUMBER;
    vr_vlajslan        NUMBER;
    vr_cdhistor        craplem.cdhistor%TYPE;
    vr_flgcredi        BOOLEAN;
    vr_saldo_extrato   NUMBER;
    vr_nrdolote        craplem.nrdolote%TYPE;
    vr_cdhistor1       craplem.cdhistor%TYPE;
    vr_cdhistor2       craplem.cdhistor%TYPE;
    vr_cdhistor3       craplem.cdhistor%TYPE;
    vr_cdhistor4       craplem.cdhistor%TYPE;
    vr_cdhistor5       craplem.cdhistor%TYPE;
    vr_dstransa        VARCHAR2(500);
    vr_dtcalcul        DATE;
    vr_ehmensal        BOOLEAN;
    vr_vljurmes        NUMBER;
    vr_diarefju        INTEGER;
    vr_mesrefju        INTEGER;
    vr_anorefju        INTEGER;
    vr_tab_crawepr     empr0001.typ_tab_crawepr;
    vr_tab_pgto_parcel empr0001.typ_tab_pgto_parcel;
    vr_tab_calculado   empr0001.typ_tab_calculado;
    vr_nrdrowid        ROWID;
    vr_exc_erro        EXCEPTION;
    vr_index_crawepr   VARCHAR2(30);
    vr_qtdiaatr        crapris.qtdiaatr%TYPE; 
    vr_vljura60        crapris.vljura60%TYPE;  
    
    vr_nmrescop crapcop.nmrescop%TYPE;

  --      
  BEGIN
    -- Inicializar variaveis
    pr_des_reto := 'OK';
    vr_cdcritic := NULL;
    vr_dscritic := NULL;
    vr_flgativo := 0;
                          
    /* Busca data de movimento */
    OPEN  btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat into rw_crapdat;
    CLOSE btch0001.cr_crapdat;
    
    FOR rw_crapcop IN cr_crapcop(pr_cdcooper) LOOP
     vr_nmrescop := rw_crapcop.nmrescop;
    END LOOP;
    
    /* Verificar se possui acordo na CRAPCYC com motivo igual a 2 e VIP */
    OPEN c_crapcyc(pr_cdcooper, 
                   pr_nrdconta, 
                   pr_nrctremp);
    FETCH c_crapcyc INTO vr_flgativo;
    CLOSE c_crapcyc;
          
    IF nvl(vr_flgativo,0) = 1 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Transferencia para prejuizo nao permitida, acordo possui motivo 2 -Determinação Judicial – Prejuízo Não';
      pr_des_reto := 'NOK';
      RAISE vr_exc_erro;
    END IF;
    
    -- Buscar dados do contrato
    OPEN c_crapepr(pr_cdcooper
                  ,pr_nrdconta
                  ,pr_nrctremp);
    FETCH c_crapepr INTO r_crapepr;
    IF c_crapepr%FOUND THEN
      -- Não é possível enviar para prejuizo um contrato que já esteja em prejuízo
      CLOSE c_crapepr;
      IF r_crapepr.inprejuz = 1 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Contrato ja esta em prejuizo!';
        pr_des_reto := 'NOK';
        RAISE vr_exc_erro;
      ELSE
                                                                       
      
      
        /* Tratamento Juros */
        vr_dtcalcul := gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper
                                                  ,pr_dtmvtolt => LAST_DAY(rw_crapdat.dtmvtolt)
                                                  ,pr_tipo => 'A'
                                                  ,pr_feriado => true
                                                  ,pr_excultdia => true );
        IF rw_crapdat.dtmvtolt > vr_dtcalcul THEN
          vr_ehmensal := TRUE;
        ELSE
          vr_ehmensal := FALSE;
        END IF;
                             
        vr_tab_crawepr.DELETE;
        -- monta tabela de Contas e parcelas
        FOR rw_crappep in c_crappep LOOP
          vr_index_crawepr := lpad(rw_crappep.cdcooper,10,'0')||
                                   lpad(rw_crappep.nrdconta,10,'0')||
                                   lpad(rw_crappep.nrctremp,10,'0');
          vr_tab_crawepr(vr_index_crawepr).dtlibera:= rw_crappep.dtlibera;
          vr_tab_crawepr(vr_index_crawepr).tpemprst:= rw_crappep.tpemprst;
        END LOOP;
        -- Calcular e lançar os juros do contrato      
        empr0001.pc_lanca_juro_contrato(pr_cdcooper => pr_cdcooper
                                       ,pr_cdagenci => pr_cdagenci
                                       ,pr_nrdcaixa => pr_nrdcaixa
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_nrctremp => pr_nrctremp
                                       ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                       ,pr_cdoperad => pr_cdoperad
                                       ,pr_cdpactra => 0 -- pr_cdagencia
                                       ,pr_flnormal => true
                                       ,pr_dtvencto => rw_crapdat.dtmvtolt
                                       ,pr_ehmensal => vr_ehmensal
                                       ,pr_dtdpagto => R_crapepr.dtdpagto --rw_crapdat.dtmvtolt --crapepr.dtdpagto
                                       ,pr_tab_crawepr => vr_tab_crawepr
                                       ,pr_cdorigem => 7 -- 7 - Batch
                                       ,pr_vljurmes => vr_vljurmes
                                       ,pr_diarefju => vr_diarefju
                                       ,pr_mesrefju => vr_mesrefju
                                       ,pr_anorefju => vr_anorefju
                                       ,pr_des_reto => pr_des_reto
                                       ,pr_tab_erro => vr_tab_erro);

        IF pr_des_reto = 'NOK' THEN
          IF vr_tab_erro.exists(vr_tab_erro.first) THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Não foi possivel executar lancamento de juros no processo de prejuizo.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
        -- Atualizar data de juros
        IF vr_vljurmes > 0   THEN
          BEGIN
            UPDATE crapepr
               SET crapepr.diarefju = vr_diarefju
                  ,crapepr.mesrefju = vr_mesrefju
                  ,crapepr.anorefju = vr_anorefju
             WHERE cdcooper = pr_cdcooper
               AND nrdconta = pr_nrdconta
               AND nrctremp = pr_nrctremp;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar CRAPEPR(1)';
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
           END;
         END IF;

         BEGIN
           UPDATE crapepr
              SET crapepr.vlsdeved = crapepr.vlsdeved + vr_vljurmes
                 ,crapepr.vljuracu = crapepr.vljuracu + vr_vljurmes
                 ,crapepr.vljurmes = crapepr.vljurmes + vr_vljurmes
                 ,crapepr.vljuratu = crapepr.vljuratu + vr_vljurmes
            WHERE cdcooper = pr_cdcooper
              AND nrdconta = pr_nrdconta
              AND nrctremp = pr_nrctremp;
         EXCEPTION
           WHEN OTHERS THEN
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao atualizar CRAPEPR(2)';
             pr_des_reto := 'NOK';
             RAISE vr_exc_erro;
         END;
         
        -- Ajustar o saldo do emprestimo
        empr0001.pc_busca_pgto_parcelas(pr_cdcooper => pr_cdcooper
                                        ,pr_cdagenci => pr_cdagenci
                                        ,pr_nrdcaixa => pr_nrdcaixa
                                        ,pr_cdoperad => pr_cdoperad
                                        ,pr_nmdatela => 'CRPS780'
                                        ,pr_idorigem => 7 -- Batch
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_idseqttl => pr_idseqttl
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                        ,pr_flgerlog => 'S'
                                        ,pr_nrctremp => pr_nrctremp
                                        ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                                        ,pr_nrparepr => 0 -- Todas
                                        ,pr_des_reto => pr_des_reto
                                        ,pr_tab_erro => vr_tab_erro
                                        ,pr_tab_pgto_parcel => vr_tab_pgto_parcel
                                        ,pr_tab_calculado => vr_tab_calculado);

        IF pr_des_reto <> 'OK' THEN
          IF vr_tab_erro.exists(vr_tab_erro.first) THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Não foi possivel Buscar Dados Parcelas.';
          END IF;

          RAISE vr_exc_erro;
        END IF;

        vr_vlttmupr := 0;
        vr_vlttjmpr := 0;
        vr_vltiofpr := 0;
        vr_index    := vr_tab_pgto_parcel.FIRST;
        vr_index_calculado := vr_tab_calculado.FIRST;

        IF vr_index IS NOT NULL THEN
          FOR idx IN vr_tab_pgto_parcel.first..vr_tab_pgto_parcel.last LOOP
            IF vr_tab_pgto_parcel(idx).inliquid = 0 THEN
              vr_vlttmupr := vr_vlttmupr + vr_tab_pgto_parcel(idx).vlmtapar;
              vr_vlttjmpr := vr_vlttjmpr + vr_tab_pgto_parcel(idx).vlmrapar;
              vr_vltiofpr := vr_vltiofpr + vr_tab_pgto_parcel(idx).vliofcpl;
            END IF;
          END LOOP;
        END IF;
                                 
        OPEN c_craplcr(pr_cdcooper);
        FETCH c_craplcr into r_craplcr;

        IF c_craplcr%NOTFOUND THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Linha de Credito nao Cadastrada!';
          pr_des_reto := 'NOK';
          raise vr_exc_erro;
        END IF;

        CLOSE c_craplcr;

        IF vr_tab_calculado(vr_index_calculado).vlsdeved = 0
        OR vr_tab_calculado.count = 0  THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao buscar saldos do contrato.';
          pr_des_reto := 'NOK';
          RAISE vr_exc_erro;
        ELSE
          OPEN  c_crapris(pr_cdcooper, pr_nrdconta, pr_nrctremp);
          FETCH c_crapris into vr_qtdiaatr;
          CLOSE c_crapris;
                       
          IF  nvl(vr_qtdiaatr,0) >= 60  THEN  -- Calcular o valor dos juros a mais de 60 dias
            -- Obter valor de juros a mais de 60 dias
            OPEN cr_craplem_60 (pr_qtdiaatr => vr_qtdiaatr);
            FETCH cr_craplem_60 INTO vr_vljura60;
            CLOSE cr_craplem_60;
          END IF; 
                        
          /* Contabilizar creditos  */
          OPEN EMPR0001.cr_craplem_sld(pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta
                                      ,pr_nrctremp => pr_nrctremp);
          FETCH EMPR0001.cr_craplem_sld
            INTO vr_saldo_extrato;
          --Fechar Cursor
          CLOSE EMPR0001.cr_craplem_sld;             
          --
          --FOR rw_craplem IN cr_craplem(pr_cdcooper, pr_nrdconta, pr_nrctremp) LOOP
          vr_saldo_extrato :=  ABS(NVL(vr_saldo_extrato,0));
          --END LOOP;
          -- Saldo de acordo com as parcelas
          vr_vlsdeved := vr_tab_calculado(vr_index_calculado).vlsderel;
          -- calcula a diferenca entre saldo de parcelas com o saldo da EPR
          --vr_vlajsdvd := (vr_vlsdeved - (r_crapepr.vlsdeved + vr_vljurmes));
          vr_vlajsdvd := (vr_vlsdeved - vr_saldo_extrato);
          
          --Se o saldo devedor for negativo
          IF nvl(vr_vlajsdvd, 0) < 0 THEN
            IF r_craplcr.dsoperac = 'FINANCIAMENTO' THEN
              /* Financiamento */
              --Historico
              vr_cdhistor := 1043;
              --Lote
              vr_nrdolote := 600009;
            ELSE
              /* Emprestimo */
              --Historico
              vr_cdhistor := 1041;
              --Lote
              vr_nrdolote := 600007;
            END IF;
            vr_flgcredi := TRUE; /* Credita */
          ELSIF nvl(vr_vlajsdvd, 0) > 0 THEN
            IF r_craplcr.dsoperac = 'FINANCIAMENTO' THEN
              /* Financiamento */
              --Historico
              vr_cdhistor := 1042;
              --Lote
              vr_nrdolote := 600008;
            ELSE
              /* Emprestimo */
              --Historico
              vr_cdhistor := 1040;
              --Lote
              vr_nrdolote := 600006;
            END IF;
            vr_flgcredi := FALSE; /* Debita */
          END IF;

          vr_vlajslan := ABS(vr_vlajsdvd);
          
          IF nvl(vr_vlajslan, 0) <> 0 THEN
            /* Efetuar ajuste */
            /* Cria lancamento e atualiza o lote  */
            empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper --Codigo Cooperativa
                                           ,pr_dtmvtolt => pr_dtmvtolt --Data Emprestimo
                                           ,pr_cdagenci => pr_cdagenci --Codigo Agencia
                                           ,pr_cdbccxlt => 100 --Codigo Caixa
                                           ,pr_cdoperad => pr_cdoperad --Operador
                                           ,pr_cdpactra => pr_cdagenci --Posto Atendimento
                                           ,pr_tplotmov => 5 --Tipo movimento
                                           ,pr_nrdolote => vr_nrdolote --Numero Lote
                                           ,pr_nrdconta => pr_nrdconta --Numero da Conta
                                           ,pr_cdhistor => vr_cdhistor --Codigo Historico
                                           ,pr_nrctremp => pr_nrctremp --Numero Contrato
                                           ,pr_vllanmto => vr_vlajslan --Valor Lancamento
                                           ,pr_dtpagemp => pr_dtmvtolt --Data Pagamento Emprestimo
                                           ,pr_txjurepr => 0 --Taxa Juros Emprestimo
                                           ,pr_vlpreemp => 0 --Valor Emprestimo
                                           ,pr_nrsequni => 0 --Numero Sequencia
                                           ,pr_nrparepr => 0 --Numero Parcelas Emprestimo
                                           ,pr_flgincre => TRUE --Indicador Credito
                                           ,pr_flgcredi => vr_flgcredi --Credito/Debito
                                           ,pr_nrseqava => 0 --Pagamento: Sequencia do avalista
                                           ,pr_cdorigem => 7 -- Origem do Lançamento
                                           ,pr_cdcritic => vr_cdcritic --Codigo Erro
                                           ,pr_dscritic => vr_dscritic); --Descricao Erro
            --Se ocorreu err o
            IF vr_cdcritic IS NOT NULL
            OR vr_dscritic IS NOT NULL THEN
              RAISE vr_exc_erro;
            END IF;
          END IF;          
                      
          IF nvl(vr_vljura60,0) > 0 THEN
            -- Se o Juros +60 for maior que o saldo devedor, considerar somente o saldo devedor 
            -- para a transferencia 
            IF nvl(vr_vljura60,0) >= nvl(vr_vlsdeved,0) THEN
              vr_vljura60 := 0;
            ELSE
              vr_vlsdeved := vr_vlsdeved - vr_vljura60;
            END IF;
          END IF;
                      
          BEGIN
            UPDATE CRAPEPR
               SET  crapepr.vlprejuz  = vr_vlsdeved + nvl(vr_vljura60,0) --vr_tab_calculado(1).vlsderel + nvl(vr_vljura60,0)
                    ,crapepr.vlsdprej = vr_vlsdeved + nvl(vr_vljura60,0) --vr_tab_calculado(1).vlsderel + nvl(vr_vljura60,0)
                    ,crapepr.inprejuz = 1 /* Em prejuizo */
                    ,crapepr.inliquid = 1 /* Liquidado   */
                    ,crapepr.dtprejuz = rw_crapdat.dtmvtolt
                    ,crapepr.vlttmupr = vr_vlttmupr          /* Multa das Parcelas */
                    ,crapepr.vlttjmpr = vr_vlttjmpr          /* Juros de Mora das Parcelas */
                    ,crapepr.vltiofpr = vr_vltiofpr          /* IOF Prejuizo */
                    ,crapepr.vlpgmupr = 0
                    ,crapepr.vlpgjmpr = 0
                    --,crapepr.vlpiofpr = 0 /* Como não há estorno o valor pago persistirá */
                    ,crapepr.vlsdeved = 0
                    ,crapepr.vlsdevat = 0
               WHERE crapepr.cdcooper = pr_cdcooper
                 AND   crapepr.nrdconta = pr_nrdconta
                 AND   crapepr.nrctremp = pr_nrctremp;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao ATUALIZAR tabela de emprestimos (CRAPEPR): ' || sqlerrm;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
          END;
          -- Checar os históricos Conforme Epr ou Fin
          IF r_craplcr.dsoperac = 'FINANCIAMENTO' THEN /* Financiamento */
            vr_cdhistor1 := 2396;  /* 2396 - TRANSFERENCIA FINANCIAMENTO PP P/ PREJUIZO */
            if vr_idfraude then
               vr_cdhistor1 := 2400; /* 2400 - TRANSFERENCIA EMPRESTIMO SUSPEITA DE FRAUDE */
            end if;
            vr_cdhistor3 := 2397;  /* 2397 - REVERSAO JUROS +60 PP P/ PREJUIZO */
            
          ELSE /* Emprestimo */
            vr_cdhistor1 := 2381;  /* 2381 - TRANSFERENCIA EMPRESTIMO PP P/ PREJUIZO */
            IF vr_idfraude THEN
              vr_cdhistor1 := 2385; /* 2385 - TRANSFERENCIA EMPRESTIMO PP SUSPEITA DE FRAUDE */
            END IF;
            vr_cdhistor3 := 2382;  /* 2382 - REVERSAO JUROS +60 PP P/ PREJUIZO */
          END IF;
          
          -- IOF, Multa e Juros e Mora são os mesmos
          vr_cdhistor2 := 2411;  /* 2411 - MULTAS DE MORA SOBRE PREJUIZO */
          vr_cdhistor4 := 2415;  /* 2415 - JUROS MORA SOBRE PREJUIZO */
          vr_cdhistor5 := 2735;  /* 2735 - IOF sobre prejuizo */  

        END IF;
                           
        -- teste de verificacao lancamento LEM
        vr_dstransa := 'Acessando gravação da LEM, contrato: ' ||
                       pr_nrctremp || ' - Saldo: ' || vr_tab_calculado(1).vlsderel;
                                           
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => null
                            ,pr_dsorigem => 'AIMARO'
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => trunc(sysdate)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => to_number(to_char(sysdate,'HH24MISS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'CRPS780'
                            ,pr_nrdconta => PR_NRDCONTA
                            ,pr_nrdrowid => VR_NRDROWID);
                   
                   
                   
                                                
        IF vr_vlsdeved > 0 THEN 
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhistor1
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vlsdeved --vr_tab_calculado(1).vlsderel
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                                                             
          IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic := NVL(vr_cdcritic,0);
            vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor principal): ' || vr_dscritic;
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
          END IF;
        END IF;
        
        -- IOF (Segundo Contabilidade não é necessário gerar histórico de lançamento)           
        IF vr_vltiofpr > 0 THEN
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhistor5
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vltiofpr
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                              
          IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic := NVL(vr_cdcritic,0);
            vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (IOF): ' || vr_dscritic;
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
          END IF;
        END IF;
        
        -- Multa
        IF vr_vlttmupr > 0 THEN
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhistor2
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vlttmupr
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                                     
          IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic := NVL(vr_cdcritic,0);
            vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor multa): ' || vr_dscritic;
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
          END IF;
        END IF;
        
        -- Juros 60             
        IF nvl(vr_vljura60,0) > 0 THEN
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhistor3
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vljura60
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                              
          IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic := NVL(vr_cdcritic,0);
            vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor juros): ' || vr_dscritic;
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
          END IF;
        END IF;
        
        -- Juros de Mora              
        IF vr_vlttjmpr > 0 THEN
          empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhistor4
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vlttjmpr
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                              
          IF vr_dscritic IS NOT NULL THEN
            vr_cdcritic := NVL(vr_cdcritic,0);
            vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor juros): ' || vr_dscritic;
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
          END IF;
        END IF;
        --
        /* liquidar parcelas CRAPPEP */
        BEGIN
          UPDATE CRAPPEP
             SET inliquid = 1
                ,inprejuz = 1
           WHERE crappep.cdcooper = pr_cdcooper
             AND crappep.nrdconta = pr_nrdconta
             AND crappep.nrctremp = pr_nrctremp
             AND crappep.inliquid = 0;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao ATUALIZAR tabela de Parcelas de Emprestimos (CRAPPEP): ' || SQLERRM;
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
        END;

        vr_dstransa := 'Data: ' || to_char( rw_crapdat.dtmvtolt,'DD/MM/YYYY') ||
                       ' - Transferencia para prejuizo - ' ||
                       ', Conta:  ' || pr_nrdconta || 
                       ', Contrato: ' || pr_nrctremp;
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                            ,pr_cdoperad => pr_cdoperad
                            ,pr_dscritic => null
                            ,pr_dsorigem => 'AIMARO'
                            ,pr_dstransa => vr_dstransa
                            ,pr_dttransa => trunc(sysdate)
                            ,pr_flgtrans => 1
                            ,pr_hrtransa => to_number(to_char(sysdate,'HH24MISS'))
                            ,pr_idseqttl => 1
                            ,pr_nmdatela => 'CRPS780'
                            ,pr_nrdconta => pr_nrdconta
                            ,pr_nrdrowid => vr_nrdrowid);

        --vr_flgtrans := TRUE;
        
        -- Desativar o Rating
        rati0001.pc_desativa_rating(pr_cdcooper => pr_cdcooper
                                  , pr_cdagenci => 0
                                  , pr_nrdcaixa => 0
                                  , pr_cdoperad => pr_cdoperad
                                  , pr_rw_crapdat => rw_crapdat
                                  , pr_nrdconta => pr_nrdconta
                                  , pr_tpctrrat => 90
                                  , pr_nrctrrat => pr_nrctremp
                                  , pr_flgefeti => 'S'
                                  , pr_idseqttl => 1
                                  ,pr_idorigem => 7 -- batch
                                  ,pr_inusatab => false
                                  ,pr_nmdatela => 'CRPS780'
                                  ,pr_flgerlog => 'S'
                                  ,pr_des_reto => pr_des_reto
                                  ,pr_tab_erro => vr_tab_erro);

        IF pr_des_reto <> 'OK' THEN

          IF vr_tab_erro.exists(vr_tab_erro.first) THEN
            vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;          
            vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
          ELSE
            vr_cdcritic := 0;
            vr_dscritic := 'Não foi possivel desativar rating.';
          END IF;
          RAISE vr_exc_erro;
        END IF;
        
      END IF;

    ELSE
      CLOSE c_crapepr;
      vr_cdcritic := 0;
      vr_dscritic := 'Falha ao gerar o emprestimo para prejuizo. ' || sqlerrm;
      pr_des_reto := 'NOK';
      RAISE vr_exc_erro;
    END IF;

    IF c_crapepr%ISOPEN THEN
      CLOSE c_crapepr;
    END IF;
        
    -- Bloqueios da conta corrente
    pc_bloqueio_conta_corrente(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_cdorigem => 2 -- emprestimos
                              ,pr_dscritic => vr_dscritic);
                                  
    IF vr_dscritic <> 'OK' THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro no bloqueio da CC';
      pr_des_reto := 'NOK';
      RAISE vr_exc_erro;
    END IF;
          
    /*IF NOT vr_flgtrans THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Processo não foi concluido.';
      pr_tab_erro(PR_TAB_ERRO.FIRST).dscritic := vr_dscritic;
      pr_des_reto := 'NOK';
      RAISE vr_exc_erro;
    END IF;*/

  EXCEPTION
    WHEN vr_exc_erro then
      -- desfazer alterações
      ROLLBACK;
      --
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);  
      --
      pr_des_reto := 'NOK';
      -- fechar cursor principal    
      IF c_crapepr%ISOPEN THEN
        CLOSE c_crapepr;
      END IF;

    WHEN OTHERS THEN
      -- desfazer alterações
      ROLLBACK;
      -- fechar cursor principal
      IF c_crapepr%ISOPEN THEN
        CLOSE c_crapepr;
      END IF;           

      vr_cdcritic := 0;
      vr_dscritic := 'Falha rotina PREJ0001.pc_transfere_epr_prejuizo_PP - '||SQLERRM;
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);    

      pr_des_reto := 'NOK';
  END pc_transfere_epr_prejuizo_PP;
--
  PROCEDURE pc_transfere_epr_prejuizo_TR(pr_cdcooper IN NUMBER
                                        ,pr_cdagenci IN NUMBER
                                        ,pr_nrdcaixa IN NUMBER
                                        ,pr_cdoperad IN VARCHAR2
                                        ,pr_nrdconta IN NUMBER
                                        ,pr_dtmvtolt IN DATE
                                        ,pr_nrctremp IN NUMBER
                                        ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                        ,pr_tab_erro OUT gene0001.typ_tab_erro  ) is  

   /* .............................................................................

    Programa: pc_transfere_epr_prejuizo_TR
    Sistema : AyllosWeb / Rotina PC_CRPS780
    Sigla   : PREJ
    Autor   : Jean Calão - Mout´S
    Data    : Maio/2017.                  Ultima atualizacao: 22/01/2018

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetua as transferencias de contratos TR para prejuízo 
    Observacao: Rotina chamada pela tela Atenda ou rotina automatica.

    Alteracoes: 27/01/2017 - Identação do código e ajustes conforme SM 6 M324 
               (Rafael Monteiro - Mout'S)

   ..............................................................................*/                                          
    --   
    CURSOR c_busca_prx_lote(pr_cdhistor number) is
      SELECT MAX(nrdolote) nrdolote
        FROM craplot
       WHERE craplot.dtmvtolt = pr_dtmvtolt
         AND craplot.cdcooper = pr_cdcooper
         AND craplot.cdagenci = pr_cdagenci
         AND craplot.cdbccxlt = 200
         AND craplot.tplotmov = 5
         AND craplot.cdhistor = pr_cdhistor;
    --         
    CURSOR c_busca_boleto IS
      SELECT tbrecup_cobranca.cdcooper
            ,tbrecup_cobranca.nrdconta_cob
            ,tbrecup_cobranca.nrcnvcob 
            ,tbrecup_cobranca.nrboleto 
            ,tbrecup_cobranca.nrctremp
            ,crapcob.incobran
            ,crapcob.dtvencto
            ,crapcob.vltitulo
            ,crapcob.dtdpagto
            ,crapcob.nrdocmto
       FROM tbrecup_cobranca, crapcob
      WHERE tbrecup_cobranca.cdcooper  = pr_cdcooper
        AND tbrecup_cobranca.nrdconta  = pr_nrdconta
        AND tbrecup_cobranca.nrctremp  = pr_nrctremp
        AND tbrecup_cobranca.tpproduto = 0
        AND crapcob.cdcooper           = tbrecup_cobranca.cdcooper
        AND crapcob.nrdconta           = tbrecup_cobranca.nrdconta_cob
        AND crapcob.nrcnvcob           = tbrecup_cobranca.nrcnvcob
        AND crapcob.nrdocmto           = tbrecup_cobranca.nrboleto
        AND crapcob.incobran in (0, 5)
       ORDER BY tbrecup_cobranca.nrboleto DESC;
    --             
    CURSOR c_busca_retorno_boleto(pr_nrcnvcob NUMBER
                                 ,pr_nrdocmto NUMBER
                                 ,pr_dtdpagto DATE) IS
      SELECT 1
        FROM crapret
       WHERE crapret.cdcooper = pr_cdcooper    
         AND crapret.nrdconta = pr_nrdconta     
         AND crapret.nrcnvcob = pr_nrcnvcob     
         AND crapret.nrdocmto = pr_nrdocmto     
         AND crapret.cdocorre = 6     -- pendente de processamento
         AND crapret.dtocorre = pr_dtdpagto     
         AND crapret.flcredit = 0;
    r_busca_retorno_boleto c_busca_retorno_boleto%rowtype;  
    --
    CURSOR c_crapris (pr_cdcooper craplem.cdcooper%TYPE 
                     ,pr_nrdconta craplem.nrdconta%TYPE
                     ,pr_nrctremp craplem.nrctremp%TYPE) IS
                         
      SELECT vljura60
        FROM crapris ris
       WHERE ris.cdcooper = pr_cdcooper
         AND ris.nrdconta = pr_nrdconta
         AND ris.nrctremp = pr_nrctremp
         AND ris.dtrefere = rw_crapdat.dtultdma;
    --       
    vr_nrdolote      craplot.nrdolote%TYPE;
    vr_qtregist      NUMBER;
    vr_tab_dados_epr empr0001.typ_tab_dados_epr;
    vr_vlsdeved      NUMBER;     
    vr_vlttmupr      NUMBER;
    vr_vlttjmpr      NUMBER;
    vr_erro          EXCEPTION;
    vr_txjurepr      craplem.txjurepr%TYPE;
    vr_vlpreemp      craplem.vlpreemp%TYPE;
    vr_cdhistor1     NUMBER(4);
    vr_cdhistor2     NUMBER(4);
    vr_cdhistor3     NUMBER(4);    
    vr_cdhistor4     NUMBER(4);         
    vr_txmensal      crapepr.txmensal%TYPE;  
    vr_vljura60      crapris.vljura60%TYPE;
    vr_nmrescop      crapcop.nmrescop%TYPE;    

  BEGIN
    vr_cdcritic := NULL;
    vr_dscritic := NULL;
    pr_des_reto := 'OK';
    vr_flgativo := 0;
    
    /* Busca data de movimento */
    OPEN  btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;

    FOR rw_crapcop IN cr_crapcop(pr_cdcooper) LOOP
     vr_nmrescop := rw_crapcop.nmrescop;
    END LOOP;    

    /* Verifica se existe boleto em aberto ou pago, pendente de processamento, para o contrato */
    FOR r_busca_boleto in c_busca_boleto LOOP
      IF r_busca_boleto.incobran = 0 THEN -- boleto aberto
        vr_cdcritic := 0;
        vr_dscritic := 'Boleto da conta: ' || r_busca_boleto.nrdconta_cob ||
                       ', Contrato: ' || r_busca_boleto.nrctremp ||
                       ', Número: ' || r_busca_boleto.nrboleto ||
                       ', Vencto.: ' || to_char(r_busca_boleto.dtvencto,'dd/mm/yyyy') ||
                       ', Valor: ' || to_char(r_busca_boleto.vltitulo,'999g999g999d99') ||
                       '. Está EM ABERTO!';

        RAISE vr_erro;   
      END IF;
      --
      IF r_busca_boleto.incobran = 5 THEN -- boleto pago
          
          OPEN c_busca_retorno_boleto(r_busca_boleto.nrcnvcob
                                    , r_busca_boleto.nrdocmto
                                    , r_busca_boleto.dtdpagto);
          FETCH c_busca_retorno_boleto 
           INTO r_busca_retorno_boleto;
          --
          IF c_busca_retorno_boleto%FOUND THEN
            CLOSE c_busca_retorno_boleto;
            vr_cdcritic := 0;
            vr_dscritic := 'Boleto da conta: ' || r_busca_boleto.nrdconta_cob ||
                           ', Contrato: ' || r_busca_boleto.nrctremp ||
                           ', Número: ' || r_busca_boleto.nrboleto ||
                           ', Vencto.: ' || to_char(r_busca_boleto.dtvencto,'dd/mm/yyyy') ||
                           ', Valor: ' || to_char(r_busca_boleto.vltitulo,'999g999g999d99') ||
                           '. Está pago, PENDENTE de processamento!';
            RAISE vr_erro;   
          ELSE
            CLOSE c_busca_retorno_boleto;
          END IF;
                        
      END IF;
    END LOOP;
                
    /* verifica se possui acordo ativo ou liquidado */
    /* recp0001.pc_verifica_situacao_acordo (pr_cdcooper => pr_cdcooper
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_cdorigem => 0
                                         ,pr_flgretativo => vr_flgativo
                                         ,pr_flgretquitado => vr_flquitado
                                         ,pr_flgretcancelado => vr_flcancel
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0
    OR vr_dscritic is not null THEN
      pr_des_reto := 'NOK';
      RAISE vr_erro;
    END IF;
    --
    IF vr_flgativo = 1 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Transferencia para prejuizo nao permitida, emprestimo em acordo.';
      pr_des_reto := 'NOK';
      RAISE vr_erro;
    END IF;*/      
    --           
    IF vr_flquitado = 1 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Transferencia para prejuizo nao permitida, emprestimo liquidado através de acordo.';
      RAISE vr_erro;
    END IF;
             
    /* Verificar se possui acordo na CRAPCYC */
    OPEN c_crapcyc(pr_cdcooper, 
                   pr_nrdconta, 
                   pr_nrctremp);
    FETCH c_crapcyc INTO vr_flgativo;
    IF c_crapcyc%ISOPEN THEN
      CLOSE c_crapcyc;
    END IF;
            
    IF nvl(vr_flgativo,0) = 1 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Transferencia para prejuizo nao permitida, acordo possui motivo 2 -Determinação Judicial – Prejuízo Não';
      RAISE vr_erro;
    END IF;
             
    /* Busca o saldo devedor atualizado da conta / contrato de empréstimo a ser encaminhado para prejuizo */
    empr0001.pc_obtem_dados_empresti(pr_cdcooper       => pr_cdcooper --> Cooperativa conectada
                                    ,pr_cdagenci               => pr_cdagenci --> Código da agência
                                    ,pr_nrdcaixa               => 0 --> Número do caixa
                                    ,pr_cdoperad               => 1 --> Código do operador
                                    ,pr_nmdatela               => 'crps780'--> Nome datela conectada
                                    ,pr_idorigem               => 5       --> Indicador da origem da chamada
                                    ,pr_nrdconta               => pr_nrdconta --> Conta do associado
                                    ,pr_idseqttl               => 1 --> Sequencia de titularidade da conta
                                    ,pr_rw_crapdat             => rw_crapdat --> Vetor com dados de parâmetro (CRAPDAT)
                                    ,pr_dtcalcul               => rw_crapdat.dtmvtolt --> Data solicitada do calculo
                                    ,pr_nrctremp               => pr_nrctremp  --> Número contrato empréstimo
                                    ,pr_cdprogra               => 'CRPS780'   --> Programa conectado
                                    ,pr_inusatab               => false        --> Indicador de utilização da tabela
                                    ,pr_flgerlog               => 'N'          --> Gerar log S/N
                                    ,pr_flgcondc               => true         --> Mostrar emprestimos liquidados sem prejuizo
                                    ,pr_nmprimtl               => ''           --> Nome Primeiro Titular
                                    ,pr_tab_parempctl          => ''           --> Dados tabela parametro
                                    ,pr_tab_digitaliza         => ''           --> Dados tabela parametro
                                    ,pr_nriniseq               => 0            --> Numero inicial da paginacao
                                    ,pr_nrregist               => 0            --> Numero de registros por pagina
                                    ,pr_qtregist               => vr_qtregist  --> Qtde total de registros
                                    ,pr_tab_dados_epr          => vr_tab_dados_epr --> Saida com os dados do empréstimo
                                    ,pr_des_reto               => vr_des_reto  --> Retorno OK / NOK
                                    ,pr_tab_erro               => vr_tab_erro);  --> Tabela com possíves erros

    IF vr_des_reto = 'NOK' THEN
      IF vr_tab_erro.exists(vr_tab_erro.first) THEN
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      ELSE
        vr_cdcritic := 0;
        vr_dscritic := 'Não foi possivel obter dados de emprestimos TR.';
      END IF;
      RAISE vr_erro;
    END IF;

    vr_index := vr_tab_dados_epr.first;
    vr_vlsdeved := 0;

    WHILE vr_index IS NOT NULL LOOP
                    
      vr_vlsdeved := vr_tab_dados_epr(vr_index).vlsdeved ;
      vr_txjurepr := vr_tab_dados_epr(vr_index).txjuremp ;
      vr_vlpreemp := vr_tab_dados_epr(vr_index).vlpreemp ;
      vr_vlttmupr := vr_tab_dados_epr(vr_index).vlttmupr ;
      vr_vlttjmpr := vr_tab_dados_epr(vr_index).vlttjmpr ;
      r_crapepr.cdlcremp := vr_tab_dados_epr(vr_index).cdlcremp ;
      -- buscar proximo
      vr_index := vr_tab_dados_epr.next(vr_index);
                 
    END LOOP;
            
    /* Verifica linha de credito */
    OPEN c_craplcr(pr_cdcooper);
    FETCH c_craplcr INTO r_craplcr;

    IF c_craplcr%NOTFOUND THEN
      CLOSE c_craplcr;
      vr_cdcritic := 0;
      vr_dscritic := 'Linha de Credito nao Cadastrada!';
      RAISE vr_erro;
    ELSE
      CLOSE c_craplcr;
    END IF;    
            
    IF r_craplcr.dsoperac = 'FINANCIAMENTO' THEN /* Financiamento */
      vr_cdhistor3 := 2406;  /* 2406 - REVERSAO JUROS +60 FINANCIAMENTO TR P/ PREJUIZO */
    ELSE /* Emprestimo */
      vr_cdhistor3 := 2402;  /* 2402 - REVERSAO JUROS +60 EMPRESTIMO TR P/ PREJUIZO */
    end if;
    
    -- Históricos comuns
    -- Se Fraude
    if vr_idfraude then
      vr_cdhistor1 := 2405; /* 2405 - TRANSFERENCIA EMP/ FIN TR SUSPEITA DE FRAUDE */
    ELSE
      vr_cdhistor1 := 2401;  /* 2401 - TRANSFERENCIA EMPRESTIMO TR P/ PREJUIZO */
    end if;
    
    vr_cdhistor2 := 2411;  /* 2411 - MULTAS DE MORA SOBRE PREJUIZO */
    vr_cdhistor4 := 2415;  /* 2415 - JUROS MORA SOBRE PREJUIZO*/  
             
    vr_txmensal := r_craplcr.txmensal;
              
    -- Busca próximo numero de lote a ser criado
    OPEN c_busca_prx_lote(2401);
    FETCH c_busca_prx_lote into vr_nrdolote;              
    IF NOT c_busca_prx_lote%FOUND OR nvl(vr_nrdolote,0) = 0 THEN
      vr_nrdolote := nvl(vr_nrdolote,0) + 1;
    END IF;
    --
    IF c_busca_prx_lote%ISOPEN THEN
      CLOSE c_busca_prx_lote;
    END IF;
            
    vr_vljura60 := 0;
            
    OPEN c_crapris(pr_cdcooper
                ,pr_nrdconta
                ,pr_nrctremp);
    FETCH c_crapris INTO vr_vljura60;
    --
    IF c_crapris%ISOPEN THEN
      CLOSE c_crapris;
    END IF;
            
    IF nvl(vr_vljura60,0) > 0 THEN
      -- Se o Juros +60 for maior que o saldo devedor, considerar somente o saldo devedor 
      -- para a transferencia 
      IF nvl(vr_vljura60,0) >= nvl(vr_vlsdeved,0) THEN
        vr_vljura60 := 0;
      ELSE
        vr_vlsdeved := vr_vlsdeved - vr_vljura60;
      END IF;      
    
    END IF;
    /* Com base no registro enviado para gerar para prejuízo, cria lançamentos na CRAPLEM */         
    empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                   ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_cdbccxlt => 200
                                   ,pr_cdoperad => pr_cdoperad
                                   ,pr_cdpactra => pr_cdagenci
                                   ,pr_tplotmov => 5
                                   ,pr_nrdolote => vr_nrdolote
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_cdhistor => vr_cdhistor1
                                   ,pr_nrctremp => pr_nrctremp
                                   ,pr_vllanmto => nvl(vr_vlsdeved,0)
                                   ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                   ,pr_txjurepr => vr_txjurepr
                                   ,pr_vlpreemp => vr_vlpreemp
                                   ,pr_nrsequni => 0
                                   ,pr_nrparepr => 0
                                   ,pr_flgincre => true
                                   ,pr_flgcredi => false
                                   ,pr_nrseqava => 0
                                   ,pr_cdorigem => 7 -- batch
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);

    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      vr_cdcritic := NVL(vr_cdcritic,0);       
      vr_dscritic := 'Falha ao criar CRAPLEM his: '||to_char(vr_cdhistor1)||' '||
                     vr_dscritic;
                  
      RAISE vr_erro;           
      
    END IF;
              
    IF vr_vlttmupr > 0 THEN -- Multa
      empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_cdbccxlt => 200
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_cdpactra => pr_cdagenci
                                     ,pr_tplotmov => 5
                                     ,pr_nrdolote => vr_nrdolote
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_cdhistor => vr_cdhistor2
                                     ,pr_nrctremp => pr_nrctremp
                                     ,pr_vllanmto => nvl(vr_vlttmupr,0)
                                     ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                     ,pr_txjurepr => vr_txjurepr
                                     ,pr_vlpreemp => vr_vlpreemp
                                     ,pr_nrsequni => 0
                                     ,pr_nrparepr => 0
                                     ,pr_flgincre => true
                                     ,pr_flgcredi => false
                                     ,pr_nrseqava => 0
                                     ,pr_cdorigem => 7 -- batch
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);

      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_cdcritic := NVL(vr_cdcritic,0);       
        vr_dscritic := 'Falha ao criar Multa - CRAPLEM his: '||to_char(vr_cdhistor2)||' '||
                       vr_dscritic;
                  
        RAISE vr_erro;
      END IF;
    END IF; -- vr_vlttmupr >0
               
    IF nvl(vr_vljura60,0) > 0 THEN  -- Juros +60
      empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_cdbccxlt => 200
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_cdpactra => pr_cdagenci
                                     ,pr_tplotmov => 5
                                     ,pr_nrdolote => vr_nrdolote
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_cdhistor => vr_cdhistor3
                                     ,pr_nrctremp => pr_nrctremp
                                     ,pr_vllanmto => vr_vljura60
                                     ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                     ,pr_txjurepr => vr_txjurepr
                                     ,pr_vlpreemp => vr_vlpreemp
                                     ,pr_nrsequni => 0
                                     ,pr_nrparepr => 0
                                     ,pr_flgincre => true
                                     ,pr_flgcredi => false
                                     ,pr_nrseqava => 0
                                     ,pr_cdorigem => 7 -- batch
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);


      IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
        vr_cdcritic := NVL(vr_cdcritic,0);       
        vr_dscritic := 'Falha ao criar Juros +60 - CRAPLEM his: '||to_char(vr_cdhistor3)||' '||
                       vr_dscritic;
                  
        RAISE vr_erro;
      END IF;
    END IF;
    --           
    IF vr_vlttjmpr > 0 THEN -- Juros Mora
      empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                     ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_cdbccxlt => 200
                                     ,pr_cdoperad => pr_cdoperad
                                     ,pr_cdpactra => pr_cdagenci
                                     ,pr_tplotmov => 5
                                     ,pr_nrdolote => vr_nrdolote
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_cdhistor => vr_cdhistor4
                                     ,pr_nrctremp => pr_nrctremp
                                     ,pr_vllanmto => nvl(vr_vlttjmpr,0)
                                     ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                     ,pr_txjurepr => vr_txjurepr
                                     ,pr_vlpreemp => vr_vlpreemp
                                     ,pr_nrsequni => 0
                                     ,pr_nrparepr => 0
                                     ,pr_flgincre => true
                                     ,pr_flgcredi => false
                                     ,pr_nrseqava => 0
                                     ,pr_cdorigem => 7 -- batch
                                     ,pr_cdcritic => vr_cdcritic
                                     ,pr_dscritic => vr_dscritic);


      IF vr_cdcritic > 0 OR vr_dscritic is not null THEN
        vr_cdcritic := NVL(vr_cdcritic,0);       
        vr_dscritic := 'Falha ao criar Juros Mora - CRAPLEM his: '||to_char(vr_cdhistor4)||' '||
                       vr_dscritic;
                  
        RAISE vr_erro;
      END IF;
    END IF; -- vr_vlttjmpr >0
              
    IF pr_des_reto = 'OK' THEN 
      BEGIN
         UPDATE CRAPEPR
         SET   crapepr.vlprejuz  = vr_vlsdeved + nvl(vr_vljura60,0)
            ,  crapepr.vlsdprej = vr_vlsdeved + nvl(vr_vljura60,0)
            ,  crapepr.inprejuz = 1 /* Em prejuizo */
            ,  crapepr.inliquid = 1 /* Liquidado   */
            ,  crapepr.dtprejuz = pr_dtmvtolt
            ,  crapepr.txmensal = vr_txmensal
            ,  crapepr.vlttmupr = 0          /* Multa das Parcelas */
            ,  crapepr.vlttjmpr = 0          /* Juros de Mora das Parcelas */
            ,  crapepr.vltiofpr = 0          /* IOF prejuizo */
            ,  crapepr.vlpgmupr = 0
            ,  crapepr.vlpgjmpr = 0
            --,  crapepr.vlpiofpr = 0 /* Como não há estorno o valor pago persistirá */ 
         WHERE crapepr.cdcooper = pr_cdcooper
         AND   crapepr.nrdconta = pr_nrdconta
         AND   crapepr.nrctremp = pr_nrctremp;
      EXCEPTION
         WHEN OTHERS THEN
           vr_cdcritic := 0;
           vr_dscritic := 'Erro ao ATUALIZAR tabela de emprestimos (CRAPEPR) TR: ' || sqlerrm;
           RAISE vr_erro;
      END;
      
      /* bloqueio da conta corrente */
      pc_bloqueio_conta_corrente(pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_cdorigem => 2
                          ,pr_dscritic => vr_dscritic);
                
      IF vr_dscritic <> 'OK' THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Erro bloqueio conta corrente';
        RAISE vr_erro;
      END IF;
                
    END IF;
           
  EXCEPTION
    WHEN vr_erro THEN
      --
      ROLLBACK;

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
      pr_des_reto := 'NOK';
      
    WHEN OTHERS THEN
      ROLLBACK;
     
      vr_cdcritic := 0;
      vr_dscritic := 'Falha rotina PREJ0001 - pc_transfere_epr_prejuizo_TR - '||SQLERRM;
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
      pr_des_reto := 'NOK';
      
  END pc_transfere_epr_prejuizo_TR;      
    
   PROCEDURE pc_estorno_trf_prejuizo_PP(pr_cdcooper IN NUMBER
                                       ,pr_cdagenci IN NUMBER
                                       ,pr_nrdcaixa IN NUMBER
                                       ,pr_cdoperad IN VARCHAR2
                                       ,pr_nrdconta IN NUMBER
                                       ,pr_dtmvtolt IN DATE
                                       ,pr_nrctremp IN NUMBER
                                       ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                       ,pr_tab_erro OUT gene0001.typ_tab_erro  ) IS
/*..............................................................................

   Programa: PREJ0001                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Jean Calão - Mout´S
   Data    : Maio/2017                      Ultima atualizacao: 08/08/2017

   Dados referentes ao programa:

   Frequencia: Sempre que chamada
   Objetivo  : Realizar o estorno de transferência a prejuízo

   Alteracoes: 16/03/2018 -Identação e ajustes de regras no estorno PP Rafael - Mout's
   
               30/07/2018 - P410 - Zerar total IOF Prejuizo - Marcos(Envolti)
               
               08/08/2018 - P410 - Eliminar lançamento IOF prejuizo ao desfazer (Marcos-Envolti)
               
..............................................................................*/                                       

    CURSOR cr_craplem2(pr_dtmvtolt IN DATE) IS
      SELECT * 
        FROM craplem
       WHERE craplem.cdcooper = pr_cdcooper
         AND craplem.nrdconta = pr_nrdconta
         AND craplem.nrctremp = pr_nrctremp
         AND craplem.dtmvtolt = pr_dtmvtolt
         AND craplem.cdbccxlt = 100;
         -- and    craplem.nrdolote = 600029;
       
       rw_craplem cr_craplem2%rowtype;
      /*
        2409  JUROS PREJUIZO  
        2422  ESTORNO JUROS PREJ
        2411  MULTA   
        2423  EST MULTA
        2415  JUROS MORA  
        2416  EST JUROS MORA
      */  
       
    -- Validar se existe Juros +60 para estornoar
    CURSOR cr_lanc_lem (prc_cdcooper craplem.cdcooper%TYPE
                       ,prc_nrdconta craplem.nrdconta%TYPE
                       ,prc_nrctremp craplem.nrctremp%TYPE) IS                  
      SELECT NVL((SUM(CASE WHEN c.cdhistor IN (2382) THEN c.vllanmto ELSE 0 END) - 
                  SUM(CASE WHEN c.cdhistor IN (2384) THEN c.vllanmto ELSE 0 END)),0) sum_jr60_2382,
             NVL((SUM(CASE WHEN c.cdhistor IN (2397) THEN c.vllanmto ELSE 0 END) - 
                  SUM(CASE WHEN c.cdhistor IN (2399) THEN c.vllanmto ELSE 0 END)),0) sum_jr60_2397,
             NVL((SUM(CASE WHEN c.cdhistor IN (2409) THEN c.vllanmto ELSE 0 END) - 
                  SUM(CASE WHEN c.cdhistor IN (2422) THEN c.vllanmto ELSE 0 END)),0) sum_jratz_2409,
             NVL((SUM(CASE WHEN c.cdhistor IN (2411) THEN c.vllanmto ELSE 0 END) - 
                  SUM(CASE WHEN c.cdhistor IN (2423) THEN c.vllanmto ELSE 0 END)),0) sum_jrmulta_2411,
             NVL((SUM(CASE WHEN c.cdhistor IN (2415) THEN c.vllanmto ELSE 0 END) - 
                  SUM(CASE WHEN c.cdhistor IN (2416) THEN c.vllanmto ELSE 0 END)),0) sum_jrmora_2415
        FROM craplem c
       WHERE c.cdcooper = prc_cdcooper
         AND c.nrdconta = prc_nrdconta
         AND c.nrctremp = prc_nrctremp
         AND c.cdhistor in (2382,2384,2397,2399,2409,2422,2411,2423,2415,2416); 
    --
    CURSOR cr_vlprincipal (prc_cdcooper craplem.cdcooper%TYPE
                          ,prc_nrdconta craplem.nrdconta%TYPE
                          ,prc_nrctremp craplem.nrctremp%TYPE) IS
                  
      SELECT NVL((SUM(CASE WHEN c.cdhistor IN (2381) THEN c.vllanmto ELSE 0 END) - 
                  SUM(CASE WHEN c.cdhistor IN (2383) THEN c.vllanmto ELSE 0 END)),0) sum_empr_2381, -- Emprestimo
             NVL((SUM(CASE WHEN c.cdhistor IN (2396) THEN c.vllanmto ELSE 0 END) - 
                  SUM(CASE WHEN c.cdhistor IN (2398) THEN c.vllanmto ELSE 0 END)),0) sum_fina_2396  -- Financiamento            
        FROM craplem c
       WHERE c.cdcooper = prc_cdcooper
         AND c.nrdconta = prc_nrdconta
         AND c.nrctremp = prc_nrctremp
         AND c.cdhistor in (2381,2396,2383,2398);          
    --
    -- buscar se existe contratos em Prejuizo para a conta
    CURSOR cr_crapepr (prc_cdcooper craplem.cdcooper%TYPE
                      ,prc_nrdconta craplem.nrdconta%TYPE) IS
      SELECT DISTINCT 1 existe
        FROM crapepr epr
       WHERE epr.cdcooper = prc_cdcooper
         AND epr.nrdconta = prc_nrdconta 
         AND epr.inprejuz = 1
         AND epr.dtprejuz IS NOT NULL
         AND epr.cdlcremp <> 100;
           
    vr_cdhistor1 INTEGER;
    vr_flgtrans  BOOLEAN;
    vr_dstransa  VARCHAR2(500);
    vr_dtmvtolt  DATE;
    vr_auxvalor  NUMBER;
    vr_vljuro60  NUMBER;
    vr_cdhisatz  INTEGER;
    vr_vljratuz  NUMBER;
    vr_cdhismul  INTEGER;
    vr_vljrmult  NUMBER;
    vr_cdhismor  INTEGER;
    vr_vljrmora  NUMBER;
    vr_vlprinci  NUMBER;
    vr_nrdrowid  ROWID;
    vr_exc_erro  EXCEPTION; 
    vr_existe_prejuizo NUMBER(1);  
       
  BEGIN
    vr_flgtrans := FALSE;
    pr_des_reto := 'OK';
             
    /* Busca data de movimento */
    OPEN  btch0001.cr_crapdat(pr_cdcooper);
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    CLOSE btch0001.cr_crapdat;
             
    /* Busca informações do empréstimo */
    OPEN c_crapepr(pr_cdcooper
                 ,pr_nrdconta
                 ,pr_nrctremp);
    FETCH c_crapepr INTO r_crapepr;

    IF c_crapepr%FOUND THEN
      CLOSE c_crapepr;
      IF f_valida_pagamento_abono(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrctremp => pr_nrctremp) THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Não é possível fazer estorno da tranferência de prejuízo, existem pagamentos para a conta / contrato informado';
        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';
        RAISE vr_exc_erro;                     
      END IF;
      --
      IF r_crapepr.inprejuz = 0 THEN
        vr_cdcritic := 0;
        vr_dscritic := 'Contrato não esta em prejuizo!';

        gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                             ,pr_cdagenci => pr_cdagenci
                             ,pr_nrdcaixa => pr_nrdcaixa
                             ,pr_nrsequen => 1 --> Fixo
                             ,pr_cdcritic => vr_cdcritic
                             ,pr_dscritic => vr_dscritic
                             ,pr_tab_erro => pr_tab_erro);

        pr_des_reto := 'NOK';
        RAISE vr_exc_erro;
      ELSE
        /* Verificar se ocorreram pagamentos */
        vr_dtmvtolt := r_crapepr.dtprejuz;
        
        /* Ativa Rating */
        RATI0001.pc_verifica_contrato_rating(pr_cdcooper =>  pr_cdcooper
                                            ,pr_cdagenci => 0
                                           , pr_nrdcaixa => 0
                                           , pr_cdoperad => pr_cdoperad
                                           , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           , pr_dtmvtopr => rw_crapdat.dtmvtopr
                                           , pr_nrdconta => pr_nrdconta
                                           , pr_tpctrrat => 90
                                           , pr_nrctrrat => pr_nrctremp
                                           , pr_idseqttl => 1
                                           , pr_idorigem => 7 -- Batch
                                           , pr_nmdatela => 'CRPS780'
                                           , pr_inproces => 0
                                           , pr_flgerlog => true
                                           , pr_tab_erro => vr_tab_erro
                                           , pr_des_erro => vr_des_reto
                                           , pr_dscritic => vr_dscritic);
                     
        IF vr_des_reto <> 'OK' THEN

          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao ativar Rating!';

          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);

             pr_des_reto := 'NOK';
        END IF;
                    
        /* Busca Lançamentos Empréstimos (LEM) */
        FOR rw_craplem IN cr_craplem2(vr_dtmvtolt) LOOP
          vr_auxvalor :=0;
                        
          IF r_crapepr.vlprejuz > 0 AND rw_craplem.cdhistor IN (1732, 1731) THEN
             vr_auxvalor := r_crapepr.vlprejuz;
          END IF;
                        
          IF r_crapepr.vlttmupr > 0 AND rw_craplem.cdhistor IN (1734, 1733) THEN
            vr_auxvalor := r_crapepr.vlttmupr;
          END IF;
                        
          IF r_crapepr.vlttjmpr > 0 AND rw_craplem.cdhistor IN (1736, 1735) THEN
            vr_auxvalor := r_crapepr.vlttjmpr;
          END IF;
          
        END LOOP;
        --
        -- Se for o estorno no mesmo dia da transferencia, deverá ser exclusão       
        IF r_crapepr.dtprejuz = rw_crapdat.dtmvtolt THEN
          --
          IF vr_auxvalor > 0 THEN
            BEGIN
              UPDATE craplot 
                 SET craplot.nrseqdig = craplot.nrseqdig +  1
                    ,craplot.qtcompln = craplot.qtcompln -1
                    ,craplot.qtinfoln = craplot.qtinfoln -1
                    ,craplot.vlcompcr = craplot.vlcompcr + (vr_auxvalor * -1)
                    ,craplot.vlinfocr = craplot.vlinfocr + (vr_auxvalor * -1)
               WHERE craplot.cdcooper = rw_craplem.cdcooper
                 AND   craplot.cdagenci = rw_craplem.cdagenci
                 AND   craplot.cdbccxlt = rw_craplem.cdbccxlt
                 AND   craplot.nrdolote = rw_craplem.nrdolote
                 AND   craplot.dtmvtolt = rw_crapdat.dtmvtolt
                 AND   craplot.tplotmov = 5;
            EXCEPTION
              WHEN OTHERS THEN
                vr_cdcritic := 0;
                vr_dscritic := 'Erro ao atualizar lote!' || sqlerrm;
                vr_des_reto := 'NOK';
                RAISE vr_exc_erro;
            END;
                                 
          END IF;       
                       
          /* Excluir lançamentos da CRAPLEM */
          BEGIN
             DELETE FROM CRAPLEM
              WHERE craplem.cdcooper = pr_cdcooper
                AND craplem.nrdconta = pr_nrdconta
                AND craplem.nrctremp = pr_nrctremp
                AND craplem.dtmvtolt = rw_crapdat.dtmvtolt
                AND craplem.cdbccxlt = 100
                AND craplem.cdhistor in (2381,2382,2411,2415,2385,2396,2397,2400,2735);
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro na exclusão dos lançamentos!' || sqlerrm;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
          END;
                       
        ELSE -- Se não for o mesmo dia, deverá gerar linhas de estorno
          OPEN c_craplcr(pr_cdcooper);
          FETCH c_craplcr INTO r_craplcr;

          IF c_craplcr%NOTFOUND THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Linha de Credito nao Cadastrada!';
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
          END IF;
          CLOSE c_craplcr;
          --
          -- Atualizar CYBER
          --  
          BEGIN
            UPDATE crapcyb cyb
               SET cyb.vlsdevan = r_crapepr.vlsdeved
                  ,cyb.vlsdeved = r_crapepr.vlsdeved
                  ,cyb.qtprepag = r_crapepr.qtprecal
                  ,cyb.txmensal = r_crapepr.txmensal
                  ,cyb.txdiaria = r_crapepr.txjuremp
                  ,cyb.dtprejuz = null
                  ,cyb.vlsdprej = 0
                  ,cyb.vlpreemp = r_crapepr.vlpreemp
             WHERE cyb.cdcooper = pr_cdcooper
               AND cyb.nrdconta = pr_nrdconta
               AND cyb.nrctremp = pr_nrctremp;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Falha ao atualizar tabela CYBER! PP' || sqlerrm;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;                    
          END;   
          /*
            2381	TRANSFERENCIA EMPRESTIMO PP P/ PREJUIZO
            2382	REVERSAO JUROS +60 PP P/ PREJUIZO
            2383	ESTORNO TRANSFERENCIA EMPRESTIMO PP P/ PREJUIZO
            2384	ESTORNO DE REVERSAO JUROS +60 PP P/ PREJUIZO
            2396	TRANSFERENCIA FINANCIAMENTO PP P/ PREJUIZO
            2397	REVERSAO JUROS +60 PP P/ PREJUIZO
            2398	ESTORNO TRANSFERENCIA FINANCIAMENTO PP P/ PREJUIZO
            2399	ESTORNO DE REVERSAO JUROS +60 PP P/ PREJUIZO
          */
          -- Gerar Lançamento de estorno para valor Principal
          FOR rw_vlprincipal IN cr_vlprincipal(pr_cdcooper,
                                               pr_nrdconta,
                                               pr_nrctremp) LOOP
            
            IF rw_vlprincipal.sum_empr_2381 > 0 THEN
              vr_cdhistor1 := 2383;
              vr_vlprinci := rw_vlprincipal.sum_empr_2381;
            ELSE
              vr_cdhistor1 := 2398;
              vr_vlprinci := rw_vlprincipal.sum_fina_2396;
            END IF;
            --
            IF vr_vlprinci > 0 THEN
              -- Realizar o lançamento do estorno para valor principal
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_cdpactra => pr_cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_cdhistor1
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => vr_vlprinci
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => 0
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7 -- batch
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
                                                                 
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor principal): ' || vr_dscritic;
                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;
            END IF;
          END LOOP;

   
          -- Gerar Lançamento de estorno para valor Principal
          FOR rw_lanc_lem IN cr_lanc_lem(pr_cdcooper,
                                         pr_nrdconta,
                                         pr_nrctremp) LOOP
            
            IF rw_lanc_lem.sum_jr60_2382 > 0 THEN
              vr_cdhistor1 := 2384;
              vr_vljuro60 := rw_lanc_lem.sum_jr60_2382;
            END IF;
            --
            IF rw_lanc_lem.sum_jr60_2397 > 0 THEN
              vr_cdhistor1 := 2399;
              vr_vljuro60 := rw_lanc_lem.sum_jr60_2397;
            END IF;
            --
            IF rw_lanc_lem.sum_jratz_2409 > 0 THEN
              vr_cdhisatz := 2422;
              vr_vljratuz := rw_lanc_lem.sum_jratz_2409;
            END IF;
            --
            IF rw_lanc_lem.sum_jrmulta_2411 > 0 THEN
              vr_cdhismul := 2423;
              vr_vljrmult := rw_lanc_lem.sum_jrmulta_2411;
            END IF;
            --
            IF rw_lanc_lem.sum_jrmora_2415 > 0 THEN
              vr_cdhismor := 2416;
              vr_vljrmora := rw_lanc_lem.sum_jrmora_2415;
            END IF;    
            
            --
            IF vr_vljuro60 > 0 THEN
              -- Realizar o lançamento do estorno para valor principal
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_cdpactra => pr_cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_cdhistor1
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => vr_vljuro60
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => 0
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7 -- batch
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
                                                                 
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Ocorreu erro ao retornar gravação LEM PP(Juros +60): ' || vr_dscritic;
                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;
            END IF;
            --
            -- Juros Atualizado
            IF vr_vljratuz > 0 THEN
              -- Realizar o lançamento do estorno para valor principal
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_cdpactra => pr_cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_cdhisatz
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => vr_vljratuz
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => 0
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7 -- batch
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
                                                                 
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Ocorreu erro ao retornar gravação LEM PP (Juros Atualizado): ' || vr_dscritic;
                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;
            END IF;
             
            -- Multa
            IF vr_vljrmult > 0 THEN
              -- Realizar o lançamento do estorno para valor principal
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_cdpactra => pr_cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_cdhismul
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => vr_vljrmult
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => 0
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7 -- batch
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
                                                                 
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Ocorreu erro ao retornar gravação LEM PP (valor Multa): ' || vr_dscritic;
                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;
            END IF;
            
            -- Juros Mora
            IF vr_vljrmora > 0 THEN
              -- Realizar o lançamento do estorno para valor principal
              empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                             ,pr_cdagenci => pr_cdagenci
                                             ,pr_cdbccxlt => 100
                                             ,pr_cdoperad => pr_cdoperad
                                             ,pr_cdpactra => pr_cdagenci
                                             ,pr_tplotmov => 5
                                             ,pr_nrdolote => 600029
                                             ,pr_nrdconta => pr_nrdconta
                                             ,pr_cdhistor => vr_cdhismor
                                             ,pr_nrctremp => pr_nrctremp
                                             ,pr_vllanmto => vr_vljrmora
                                             ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                             ,pr_txjurepr => 0
                                             ,pr_vlpreemp => 0
                                             ,pr_nrsequni => 0
                                             ,pr_nrparepr => 0
                                             ,pr_flgincre => true
                                             ,pr_flgcredi => false
                                             ,pr_nrseqava => 0
                                             ,pr_cdorigem => 7 -- batch
                                             ,pr_cdcritic => vr_cdcritic
                                             ,pr_dscritic => vr_dscritic);
                                                                 
              IF vr_dscritic IS NOT NULL THEN
                vr_dscritic := 'Ocorreu erro ao retornar gravação LEM PP (Juros Mora): ' || vr_dscritic;
                pr_des_reto := 'NOK';
                RAISE vr_exc_erro;
              END IF;
            END IF;                                    
          END LOOP;          
                 
        END IF;
        /* atualizar parcelas do emprestimo */
        BEGIN
             UPDATE CRAPPEP
             SET    crappep.inliquid = 0
             ,      crappep.inprejuz = 0
             where  crappep.cdcooper = pr_cdcooper
             and    crappep.nrdconta = pr_nrdconta
             and    crappep.nrctremp = pr_nrctremp
             and    crappep.inliquid = 1
             and    crappep.inprejuz = 1; 
                      
        EXCEPTION
          when others then
            vr_cdcritic := 0;
            vr_dscritic := 'Erro ao atualizar parcelas!' || sqlerrm;
            pr_des_reto := 'NOK';
            raise vr_exc_erro;
        END;  
                  
                        
        /* Atualizar Emprestimo */
        BEGIN
           UPDATE CRAPEPR
              SET crapepr.vlsdeved = crapepr.vlprejuz
                 ,crapepr.vlsdevat = crapepr.vlsdprej
                 ,crapepr.vlprejuz = 0
                 ,crapepr.vlsdprej = 0
                 ,crapepr.inprejuz = 0
                 ,crapepr.inliquid = 0
                 ,crapepr.dtprejuz = null
                 ,crapepr.vlttmupr = 0
                 ,crapepr.vlttjmpr = 0
                 ,crapepr.vlpgmupr = 0
                 ,crapepr.vlpgjmpr = 0
                 ,crapepr.vltiofpr = 0
            WHERE crapepr.cdcooper = pr_cdcooper
              AND crapepr.nrdconta = pr_nrdconta
              AND crapepr.nrctremp = pr_nrctremp
              AND crapepr.inprejuz = 1; 
                     
        EXCEPTION
          when others then
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar emprestimo!' || sqlerrm;
              pr_des_reto := 'NOK';
              raise vr_exc_erro;
        END;
                     
        vr_dstransa := 'Data: ' || to_char( pr_dtmvtolt,'DD/MM/YYYY') ||
                       ' - Estorno de transferencia para prejuizo PP - ' ||
                       ', Conta:  ' || pr_nrdconta || 
                       ', Contrato: ' || pr_nrctremp;
                  
        gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                             ,pr_cdoperad => pr_cdoperad
                             ,pr_dscritic => null
                             ,pr_dsorigem => 'AIMARO'
                             ,pr_dstransa => vr_dstransa
                             ,pr_dttransa => pr_dtmvtolt
                             ,pr_flgtrans => 1
                             ,pr_hrtransa => to_number(to_char(sysdate,'HH24MISS'))
                             ,pr_idseqttl => 1
                             ,pr_nmdatela => 'CRPS780'
                             ,pr_nrdconta => PR_NRDCONTA
                             ,pr_nrdrowid => VR_NRDROWID);

        vr_flgtrans := TRUE;

      END IF;
      
      -- Checar prejuizo
      vr_existe_prejuizo := 0;
      FOR rw_crapepr IN cr_crapepr(pr_cdcooper,
                                   pr_nrdconta) LOOP
        vr_existe_prejuizo := 1; 
      END LOOP;
        
      IF vr_existe_prejuizo = 0 THEN
        rw_crapdat.dtmvtolt := r_crapepr.dtprejuz;
                
        pc_reabrir_conta_corrente(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_cdorigem => 3
                                 ,pr_dtprejuz => rw_crapdat.dtmvtolt 
                                 ,pr_dscritic => vr_dscritic);
                                             
        IF vr_dscritic is not null AND vr_dscritic <> 'OK' then
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao desbloquear conta corrente. ' || sqlerrm;
          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                               ,pr_cdagenci => pr_cdagenci
                               ,pr_nrdcaixa => pr_nrdcaixa
                               ,pr_nrsequen => 1 --> Fixo
                               ,pr_cdcritic => vr_cdcritic
                               ,pr_dscritic => vr_dscritic
                               ,pr_tab_erro => pr_tab_erro);
            pr_des_reto := 'NOK';
        END IF;     
      END IF; 
                  
    ELSE  -- Se não encontrou na tabela crapepr
      CLOSE c_crapepr;
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao estornar prejuizo PP: ' || sqlerrm;
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                          ,pr_cdagenci => pr_cdagenci
                          ,pr_nrdcaixa => pr_nrdcaixa
                          ,pr_nrsequen => 1 --> Fixo
                          ,pr_cdcritic => vr_cdcritic
                          ,pr_dscritic => vr_dscritic
                          ,pr_tab_erro => pr_tab_erro);
      pr_des_reto := 'NOK';
    END IF;

    IF NOT vr_flgtrans THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Erro ao estornar Prejuizo.';
      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);
     pr_des_reto := 'NOK';
    END IF;

  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer alterações
      ROLLBACK;
      IF vr_dscritic IS NULL THEN
        vr_dscritic := 'Erro na rotina pc_estorno_trf_prejuizo_PP: '; 
      END IF;
           
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                          ,pr_cdoperad => pr_cdoperad
                          ,pr_dscritic => vr_dscritic
                          ,pr_dsorigem => 'INTRANET'
                          ,pr_dstransa => 'PREJ0001-Estorno transferencia.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => 'crps780'
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
         
  END pc_estorno_trf_prejuizo_PP;
    
   /* Rotina para estornar transferencia prejuizo TR */
PROCEDURE pc_estorno_trf_prejuizo_TR(pr_cdcooper in number
                                    ,pr_cdagenci in number
                                    ,pr_nrdcaixa in number
                                    ,pr_cdoperad in varchar2
                                    ,pr_nrdconta in number
                                    ,pr_dtmvtolt in date
                                    ,pr_nrctremp in number
                                    ,pr_des_reto OUT VARCHAR --> Retorno OK / NOK
                                    ,pr_tab_erro OUT gene0001.typ_tab_erro  ) IS 
/*..............................................................................

   Programa: PREJ0001                        Antigo: Nao ha
   Sistema : Cred
   Sigla   : CRED
   Autor   : Jean Calão - Mout´S
   Data    : Maio/2017                      Ultima atualizacao: 08/08/2018

   Dados referentes ao programa:

   Frequencia: Sempre que chamada
   Objetivo  : Realizar o estorno de transferência a prejuízo

   Alteracoes: 21/05/2018 - Identação e ajustes de regras no estorno TR 
               (Rafael - Mout's)
               
               30/07/2018 - P410 - Ajustes no valor de IOF prejuizo (Marcos-Envolti)
               
               08/08/2018 - P410 - Eliminar lançamento IOF prejuizo ao desfazer (Marcos-Envolti)

..............................................................................*/          

      
  --
  CURSOR cr_craplem2(pr_dtmvtolt in date) IS
    SELECT * 
      FROM craplem
     WHERE craplem.cdcooper = pr_cdcooper
       AND craplem.nrdconta = pr_nrdconta
       AND craplem.nrctremp = pr_nrctremp
       AND craplem.dtmvtolt = pr_dtmvtolt
       AND craplem.cdbccxlt = 200;
  
  rw_craplem cr_craplem2%rowtype;
  --
  -- Validar se existe Juros +60 para estornoar
  CURSOR cr_lanc_lem (prc_cdcooper craplem.cdcooper%TYPE
                     ,prc_nrdconta craplem.nrdconta%TYPE
                     ,prc_nrctremp craplem.nrctremp%TYPE) IS                  
    SELECT NVL((SUM(CASE WHEN c.cdhistor IN (2402) THEN c.vllanmto ELSE 0 END) - 
                SUM(CASE WHEN c.cdhistor IN (2404) THEN c.vllanmto ELSE 0 END)),0) sum_jr60_2402,
           NVL((SUM(CASE WHEN c.cdhistor IN (2406) THEN c.vllanmto ELSE 0 END) - 
                SUM(CASE WHEN c.cdhistor IN (2407) THEN c.vllanmto ELSE 0 END)),0) sum_jr60_2406,
           NVL((SUM(CASE WHEN c.cdhistor IN (2409) THEN c.vllanmto ELSE 0 END) - 
                SUM(CASE WHEN c.cdhistor IN (2422) THEN c.vllanmto ELSE 0 END)),0) sum_jratz_2409,
           NVL((SUM(CASE WHEN c.cdhistor IN (2411) THEN c.vllanmto ELSE 0 END) - 
                SUM(CASE WHEN c.cdhistor IN (2423) THEN c.vllanmto ELSE 0 END)),0) sum_jrmulta_2411,
           NVL((SUM(CASE WHEN c.cdhistor IN (2415) THEN c.vllanmto ELSE 0 END) - 
                SUM(CASE WHEN c.cdhistor IN (2416) THEN c.vllanmto ELSE 0 END)),0) sum_jrmora_2415                  
      FROM craplem c
     WHERE c.cdcooper = prc_cdcooper
       AND c.nrdconta = prc_nrdconta
       AND c.nrctremp = prc_nrctremp
       AND c.cdhistor in (2402,2404,2406,2407,2409,2422,2411,2423,2415,2416); 
  --
  CURSOR cr_vlprincipal (prc_cdcooper craplem.cdcooper%TYPE
                        ,prc_nrdconta craplem.nrdconta%TYPE
                        ,prc_nrctremp craplem.nrctremp%TYPE) IS
                  
    SELECT NVL((SUM(CASE WHEN c.cdhistor IN (2401,2405) THEN c.vllanmto ELSE 0 END) - 
                SUM(CASE WHEN c.cdhistor IN (2403) THEN c.vllanmto ELSE 0 END)),0) sum_empr_2401 -- Emprestimo

      FROM craplem c
     WHERE c.cdcooper = prc_cdcooper
       AND c.nrdconta = prc_nrdconta
       AND c.nrctremp = prc_nrctremp
       AND c.cdhistor in (2401,2405,2403);
     --
   CURSOR cr_crapepr (prc_cdcooper craplem.cdcooper%TYPE
                        ,prc_nrdconta craplem.nrdconta%TYPE) IS
     SELECT DISTINCT 1 existe
       FROM crapepr epr
      WHERE epr.cdcooper = prc_cdcooper
        AND epr.nrdconta = prc_nrdconta 
        AND epr.inprejuz = 1
        AND epr.dtprejuz IS NOT NULL
        AND epr.cdlcremp <> 100;       

  vr_flgtrans        BOOLEAN;
  vr_exc_erro        EXCEPTION;
  vr_auxvalor        NUMBER;
  vr_dstransa        VARCHAR2(200);
  vr_nrdrowid        ROWID;
  vr_dtmvtolt        DATE;
  vr_cdhistor1       integer;    
  vr_vljuro60        NUMBER;
  vr_vlprinci        NUMBER;   
  vr_existe_prejuizo NUMBER(1);          
  vr_cdhisatz        INTEGER;
  vr_vljratuz        NUMBER;
  vr_cdhismul        INTEGER;
  vr_vljrmult        NUMBER;
  vr_cdhismor        INTEGER;
  vr_vljrmora        NUMBER;     
  
BEGIN
  vr_flgtrans := FALSE;
  pr_des_reto := 'OK';
         
  /* Busca data de movimento */
  open  btch0001.cr_crapdat(pr_cdcooper);
  fetch btch0001.cr_crapdat into rw_crapdat;
  close btch0001.cr_crapdat;
         
  /* Busca informações do empréstimo */
  OPEN c_crapepr(pr_cdcooper
                ,pr_nrdconta
                ,pr_nrctremp);
  FETCH c_crapepr INTO r_crapepr;

  IF c_crapepr%FOUND THEN
    CLOSE c_crapepr;
    IF f_valida_pagamento_abono(pr_cdcooper => pr_cdcooper
                              ,pr_nrdconta => pr_nrdconta
                              ,pr_nrctremp => pr_nrctremp) THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Não é possível fazer estorno da tranferência de prejuízo, existem pagamentos para a conta / contrato informado';

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      pr_des_reto := 'NOK';
      raise vr_exc_erro;                     
    END IF;           
    IF r_crapepr.inprejuz = 0 THEN
      vr_cdcritic := 0;
      vr_dscritic := 'Contrato não esta em prejuizo!';

      gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

      pr_des_reto := 'NOK';
      raise vr_exc_erro;
    ELSE
      /* Verificar se ocorreram pagamentos */
      vr_dtmvtolt := r_crapepr.dtprejuz;                                                          
                      
      /* Busca Lançamentos Empréstimos (LEM) */
      FOR rw_craplem in cr_craplem2(vr_dtmvtolt) LOOP
        vr_auxvalor :=0;
        IF r_crapepr.vlprejuz > 0 AND rw_craplem.cdhistor IN (349, 2401,2408,2411) THEN 
          vr_auxvalor := r_crapepr.vlprejuz;
        END IF;
      END LOOP;
      --                       
      IF r_crapepr.dtprejuz = rw_crapdat.dtmvtolt THEN
        /* Atualiza o lote */
        IF vr_auxvalor > 0 THEN
          BEGIN
            UPDATE CRAPLOT 
               SET craplot.nrseqdig = craplot.nrseqdig +  1
                  ,craplot.qtcompln = craplot.qtcompln -1
                  ,craplot.qtinfoln = craplot.qtinfoln -1
                  ,craplot.vlcompcr = craplot.vlcompcr + (vr_auxvalor * -1)
                  ,craplot.vlinfocr = craplot.vlinfocr + (vr_auxvalor * -1)
             WHERE craplot.cdcooper = rw_craplem.cdcooper
               AND craplot.cdagenci = rw_craplem.cdagenci
               AND craplot.cdbccxlt = rw_craplem.cdbccxlt
               AND craplot.nrdolote = rw_craplem.nrdolote
               AND craplot.dtmvtolt = rw_crapdat.dtmvtolt
               AND craplot.tplotmov = 5;
          EXCEPTION
            WHEN OTHERS THEN
              vr_cdcritic := 0;
              vr_dscritic := 'Erro ao atualizar lote!' || SQLERRM;
              pr_des_reto := 'NOK';
              raise vr_exc_erro;
          END;
        END IF;                  
        /* Excluir lançamentos da CRAPLEM */
        BEGIN
           DELETE FROM CRAPLEM
            WHERE  craplem.cdcooper = pr_cdcooper
              AND craplem.nrdconta  = pr_nrdconta
              AND craplem.nrctremp  = pr_nrctremp
              AND craplem.dtmvtolt  = rw_crapdat.dtmvtolt
              AND craplem.cdhistor in (2401, 2402, 2411, 2415, 2405, 2406, 2735);
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Erro na exclusão dos lançamentos!' || sqlerrm;
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;
        END;
      ELSE -- Então gerar histórico de estorno
        --
        OPEN c_craplcr(pr_cdcooper);
        FETCH c_craplcr INTO r_craplcr;
        
        IF c_CRAPLCR%NOTFOUND THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Linha de Credito nao Cadastrada!';
          pr_des_reto := 'NOK';
          raise vr_exc_erro;
        END IF;
        CLOSE c_craplcr;
               
        -- Gerar Lançamento de estorno para valor Principal
        FOR rw_vlprincipal IN cr_vlprincipal(pr_cdcooper,
                                             pr_nrdconta,
                                             pr_nrctremp) LOOP
                          
          IF rw_vlprincipal.sum_empr_2401 > 0 THEN
            vr_cdhistor1 := 2403;
            vr_vlprinci := rw_vlprincipal.sum_empr_2401;
          END IF;
          --
          IF vr_vlprinci > 0 THEN
            -- Realizar o lançamento do estorno para valor principal
            empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                           ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                           ,pr_cdagenci => pr_cdagenci
                                           ,pr_cdbccxlt => 100
                                           ,pr_cdoperad => pr_cdoperad
                                           ,pr_cdpactra => pr_cdagenci
                                           ,pr_tplotmov => 5
                                           ,pr_nrdolote => 600029
                                           ,pr_nrdconta => pr_nrdconta
                                           ,pr_cdhistor => vr_cdhistor1
                                           ,pr_nrctremp => pr_nrctremp
                                           ,pr_vllanmto => vr_vlprinci
                                           ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                           ,pr_txjurepr => 0
                                           ,pr_vlpreemp => 0
                                           ,pr_nrsequni => 0
                                           ,pr_nrparepr => 0
                                           ,pr_flgincre => true
                                           ,pr_flgcredi => false
                                           ,pr_nrseqava => 0
                                           ,pr_cdorigem => 7 -- batch
                                           ,pr_cdcritic => vr_cdcritic
                                           ,pr_dscritic => vr_dscritic);
                                                                                   
            IF vr_dscritic IS NOT NULL THEN
              vr_dscritic := 'Ocorreu erro ao retornar gravação LEM (valor principal): ' || vr_dscritic;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
            END IF;
          END IF;
        END LOOP;
        --
        -- Validar estorno Juros +60
        -- Gerar Lançamento de estorno para valor Principal
        FOR rw_lanc_lem IN cr_lanc_lem(pr_cdcooper,
                                 pr_nrdconta,
                                 pr_nrctremp) LOOP
                          
          IF rw_lanc_lem.sum_jr60_2402 > 0 THEN
            vr_cdhistor1 := 2404;
            vr_vljuro60 := rw_lanc_lem.sum_jr60_2402;
          END IF;
          --
          IF rw_lanc_lem.sum_jr60_2406 > 0 THEN
            vr_cdhistor1 := 2407;
            vr_vljuro60 := rw_lanc_lem.sum_jr60_2406;
          END IF;
          --
          IF rw_lanc_lem.sum_jratz_2409 > 0 THEN
            vr_cdhisatz := 2422;
            vr_vljratuz := rw_lanc_lem.sum_jratz_2409;
          END IF;
          --
          IF rw_lanc_lem.sum_jrmulta_2411 > 0 THEN
            vr_cdhismul := 2423;
            vr_vljrmult := rw_lanc_lem.sum_jrmulta_2411;
          END IF;
          --
          IF rw_lanc_lem.sum_jrmora_2415 > 0 THEN
            vr_cdhismor := 2416;
            vr_vljrmora := rw_lanc_lem.sum_jrmora_2415;              
          END IF;         
          --
          IF vr_vljuro60 > 0 THEN
            -- Realizar o lançamento do estorno para valor principal
            empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhistor1
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vljuro60
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                                                                                   
            IF vr_dscritic IS NOT NULL THEN
              vr_dscritic := 'Ocorreu erro ao retornar gravação LEM TR (Juros +60): ' || vr_dscritic;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
            END IF;
          END IF;
          -- Juros Atualizado
          IF vr_vljratuz > 0 THEN
            -- Realizar o lançamento do estorno para valor principal
            empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhisatz
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vljratuz
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                                                                                   
            IF vr_dscritic IS NOT NULL THEN
              vr_dscritic := 'Ocorreu erro ao retornar gravação LEM TR (Juros Atualizado): ' || vr_dscritic;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
            END IF;
          END IF;
          -- Multa
          IF vr_vljrmult > 0 THEN
            -- Realizar o lançamento do estorno para valor principal
            empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhismul
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vljrmult
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
            IF vr_dscritic IS NOT NULL THEN
              vr_dscritic := 'Ocorreu erro ao retornar gravação LEM TR (valor Multa): ' || vr_dscritic;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
            END IF;
          END IF;
          -- Juros Mora
          IF vr_vljrmora > 0 THEN
            -- Realizar o lançamento do estorno para valor principal
            empr0001.pc_cria_lancamento_lem(pr_cdcooper => pr_cdcooper
                                         ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                         ,pr_cdagenci => pr_cdagenci
                                         ,pr_cdbccxlt => 100
                                         ,pr_cdoperad => pr_cdoperad
                                         ,pr_cdpactra => pr_cdagenci
                                         ,pr_tplotmov => 5
                                         ,pr_nrdolote => 600029
                                         ,pr_nrdconta => pr_nrdconta
                                         ,pr_cdhistor => vr_cdhismor
                                         ,pr_nrctremp => pr_nrctremp
                                         ,pr_vllanmto => vr_vljrmora
                                         ,pr_dtpagemp => rw_crapdat.dtmvtolt
                                         ,pr_txjurepr => 0
                                         ,pr_vlpreemp => 0
                                         ,pr_nrsequni => 0
                                         ,pr_nrparepr => 0
                                         ,pr_flgincre => true
                                         ,pr_flgcredi => false
                                         ,pr_nrseqava => 0
                                         ,pr_cdorigem => 7 -- batch
                                         ,pr_cdcritic => vr_cdcritic
                                         ,pr_dscritic => vr_dscritic);
                                                                                   
            IF vr_dscritic IS NOT NULL THEN
              vr_dscritic := 'Ocorreu erro ao retornar gravação LEM TR (Juros Mora): ' || vr_dscritic;
              pr_des_reto := 'NOK';
              RAISE vr_exc_erro;
            END IF;
          END IF;            
        END LOOP;
        --
        BEGIN
          UPDATE crapcyb cyb
             SET cyb.vlsdevan = r_crapepr.vlsdeved
                ,cyb.vlsdeved = r_crapepr.vlsdeved
                ,cyb.qtprepag = r_crapepr.qtprecal
                ,cyb.txmensal = r_crapepr.txmensal
                ,cyb.txdiaria = r_crapepr.txjuremp
                ,cyb.dtprejuz = null
                ,cyb.vlsdprej = 0
                ,cyb.vlpreemp = r_crapepr.vlpreemp
           WHERE cyb.cdcooper = pr_cdcooper
             AND cyb.nrdconta = pr_nrdconta
             AND cyb.nrctremp = pr_nrctremp;
        EXCEPTION
          WHEN OTHERS THEN
            vr_cdcritic := 0;
            vr_dscritic := 'Falha ao atualizar tabela CYBER! PP' || sqlerrm;
            pr_des_reto := 'NOK';
            RAISE vr_exc_erro;                    
        END;                       
      END IF; -- Fim Condição do dia
              
      /* Atualizar Emprestimo */
      BEGIN
         UPDATE CRAPEPR
            SET 
               -- crapepr.vlsdeved = crapepr.vlprejuz
               -- ,crapepr.vlsdevat = crapepr.vlsdprej
                crapepr.vlprejuz = 0
               ,crapepr.vlsdprej = 0
               ,crapepr.inprejuz = 0
               ,crapepr.inliquid = 0
               ,crapepr.dtprejuz = null
               ,crapepr.vlttmupr = 0
               ,crapepr.vlttjmpr = 0
               ,crapepr.vlpgmupr = 0
               ,crapepr.vlpgjmpr = 0
               ,crapepr.vltiofpr = 0
          where crapepr.cdcooper = pr_cdcooper
          and   crapepr.nrdconta = pr_nrdconta
          and   crapepr.nrctremp = pr_nrctremp
          and   crapepr.inprejuz = 1; 
                         
       EXCEPTION
         when others then
             vr_cdcritic := 0;
             vr_dscritic := 'Erro ao atualizar emprestimo!' || sqlerrm;
             pr_des_reto := 'NOK';
             raise vr_exc_erro;
       END;
                       
       vr_dstransa := 'Data: ' || to_char( pr_dtmvtolt,'DD/MM/YYYY') ||
                      ' - Estorno de transferencia para prejuizo TR - ' ||
                      ', Conta:  ' || pr_nrdconta || 
                      ', Contrato: ' || pr_nrctremp;
       
       gene0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_dscritic => null
                           ,pr_dsorigem => 'AIMARO'
                           ,pr_dstransa => vr_dstransa
                           ,pr_dttransa => pr_dtmvtolt
                           ,pr_flgtrans => 1
                           ,pr_hrtransa => to_number(to_char(sysdate,'HH24MISS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => 'CRPS780'
                           ,pr_nrdconta => PR_NRDCONTA
                           ,pr_nrdrowid => VR_NRDROWID);
       vr_flgtrans := TRUE;

    END IF;
  
    vr_existe_prejuizo := 0 ;
    FOR rw_crapepr IN cr_crapepr(pr_cdcooper,
                                 pr_nrdconta) LOOP
      vr_existe_prejuizo := 1;
    END LOOP;
    --
    IF vr_existe_prejuizo = 0 THEN
      rw_crapdat.dtmvtolt := r_crapepr.dtprejuz;
               
      pc_reabrir_conta_corrente(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_cdorigem => 3
                               ,pr_dtprejuz => rw_crapdat.dtmvtolt
                               ,pr_dscritic => vr_dscritic);
                                        
      IF vr_dscritic IS NOT NULL AND vr_dscritic <> 'OK' THEN
          vr_cdcritic := 0;
          vr_dscritic := 'Erro ao desbloquear conta corrente. ' || sqlerrm;

          gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                           ,pr_cdagenci => pr_cdagenci
                           ,pr_nrdcaixa => pr_nrdcaixa
                           ,pr_nrsequen => 1 --> Fixo
                           ,pr_cdcritic => vr_cdcritic
                           ,pr_dscritic => vr_dscritic
                           ,pr_tab_erro => pr_tab_erro);

          pr_des_reto := 'NOK';
       END IF;                    
    END IF;
  ELSE
    CLOSE c_crapepr;
    vr_cdcritic := 0;
    vr_dscritic := 'Erro ao estornar prejuizo emprestimo TR: ' || sqlerrm;

    gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                         ,pr_cdagenci => pr_cdagenci
                         ,pr_nrdcaixa => pr_nrdcaixa
                         ,pr_nrsequen => 1 --> Fixo
                         ,pr_cdcritic => vr_cdcritic
                         ,pr_dscritic => vr_dscritic
                         ,pr_tab_erro => pr_tab_erro);

    pr_des_reto := 'NOK';
  END IF;
  
  IF NOT vr_flgtrans THEN
    vr_cdcritic := 0;
    vr_dscritic := 'Erro ao estornar Prejuizo.';

    gene0001.pc_gera_erro(pr_cdcooper => pr_cdcooper
                                   ,pr_cdagenci => pr_cdagenci
                                   ,pr_nrdcaixa => pr_nrdcaixa
                                   ,pr_nrsequen => 1 --> Fixo
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic
                                   ,pr_tab_erro => pr_tab_erro);

    pr_des_reto := 'NOK';

  END IF;
EXCEPTION
   WHEN vr_exc_erro THEN
       -- Desfazer alterações
       ROLLBACK;
       if vr_dscritic is null then
          vr_dscritic := 'Erro na rotina pc_estorno_trf_prejuizo_TR: '; 
       end if;
           
       -- Retorno não OK
       GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                           ,pr_cdoperad => pr_cdoperad
                           ,pr_dscritic => vr_dscritic
                           ,pr_dsorigem => 'INTRANET'
                           ,pr_dstransa => 'PREJ0001-Estorno transferencia.'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => 'crps780'
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
END pc_estorno_trf_prejuizo_TR;

    
  PROCEDURE pc_transfere_prejuizo_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                      ,pr_nrctremp   IN VARCHAR2  -- contrato
                                      ,pr_xmllog      IN VARCHAR2            --> XML com informações de LOG
                                      ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo

    /* .............................................................................

    Programa: pc_transfere_prejuizo_web
    Sistema : AyllosWeb
    Sigla   : PREJ
    Autor   : Jean Calão - Mout´S
    Data    : Maio/2017.                  Ultima atualizacao: 29/05/2017

    Dados referentes ao programa:

    Frequencia: Sempre que for chamado

    Objetivo  : Efetua a transferencia de contratos PP e TR para prejuízo (força o envio)
    Observacao: Rotina chamada pela tela Atenda / Prestações, botão "Transferir para prejuízo"

    Alteracoes: 31/01/2018 - Identação e Alterações referente a SM 6 M324
                (Rafael Monteiro - Mout'S)

   ..............................................................................*/
   -- Variáveis
   vr_cdcooper NUMBER;
   vr_nmdatela VARCHAR2(25);
   vr_nmeacao  VARCHAR2(25);
   vr_cdagenci VARCHAR2(25);
   vr_nrdcaixa VARCHAR2(25);
   vr_idorigem VARCHAR2(25);
   vr_cdoperad VARCHAR2(25);
   vr_nrdrowid ROWID;
   vr_dsorigem VARCHAR2(100);
   vr_dstransa VARCHAR2(500);
   vr_cddepart NUMBER(3);
   vr_tpemprst INTEGER;
   vr_inprejuz INTEGER;
   -- Excessões
   vr_exc_erro EXCEPTION;
       
   CURSOR cr_crapope is
     SELECT t.cddepart
       FROM crapope t
      WHERE t.cdoperad = vr_cdoperad;
           
  BEGIN
    -- define como operacao de fraude (para assumir históricos de operação de fraude)
    vr_idfraude := true;
       
    -- Extrair informacoes padrao do xml - parametros
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => pr_dscritic);

    OPEN cr_crapope;
    FETCH cr_crapope INTO vr_cddepart;
    CLOSE cr_crapope;

    /* Busca data de movimento */
    OPEN btch0001.cr_crapdat(vr_cdcooper);
    FETCH btch0001.cr_crapdat into rw_crapdat;
    CLOSE btch0001.cr_crapdat;
        
    /*Busca informações do emprestimo */
    OPEN c_crapepr(pr_cdcooper => vr_cdcooper
                  ,pr_nrdconta => pr_nrdconta
                  ,pr_nrctremp => pr_nrctremp);
        
    FETCH c_crapepr INTO r_crapepr;
    IF c_crapepr%FOUND THEN
       vr_tpemprst := r_crapepr.tpemprst;
       vr_inprejuz := r_crapepr.inprejuz;
    ELSE   
       vr_tpemprst := NULL;
    END IF;
    CLOSE c_crapepr;
        

    /* Verificar se possui acordo na CRAPCYC */
    OPEN c_crapcyc(vr_cdcooper, pr_nrdconta, pr_nrctremp);
    FETCH c_crapcyc INTO vr_flgativo;
    CLOSE c_crapcyc;
          
    IF nvl(vr_flgativo,0) = 1 THEN
      pr_des_erro := 'Transferencia para prejuizo nao permitida, acordo possui motivo 2 -Determinação Judicial – Prejuízo Não';
      RAISE vr_exc_erro;
    END IF;
          
             
    /* Gerando Log de Consulta */
    vr_dstransa := 'PREJ0001-realizando transferencia para prejuizo, Cooper: ' || vr_cdcooper || 
                    ' Conta: ' || pr_nrdconta || ', Contrato: ' || pr_nrctremp || ' Tipo: '
                     || r_crapepr.tpemprst || ' Data: ' || to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY');
        
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => 'OK'
                        ,pr_dsorigem => 'INTRANET'
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> SUCESSO/TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    -- Commit do LOG
    COMMIT;
        
    IF nvl(vr_inprejuz,2) = 0 THEN
      IF nvl(vr_tpemprst,2) = 1 THEN -- Contrato PP
        pc_transfere_epr_prejuizo_PP(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_idseqttl => 1
                                    ,pr_dtmvtolt => rw_crapdat.Dtmvtolt
                                    ,pr_nrctremp => pr_nrctremp
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro); 
                
      ELSE -- Contrato TR
        pc_transfere_epr_prejuizo_TR(pr_cdcooper => vr_cdcooper
                                    ,pr_cdagenci => vr_cdagenci
                                    ,pr_nrdcaixa => vr_nrdcaixa
                                    ,pr_cdoperad => vr_cdoperad
                                    ,pr_nrdconta => pr_nrdconta
                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                    ,pr_nrctremp => pr_nrctremp
                                    ,pr_des_reto => vr_des_reto
                                    ,pr_tab_erro => vr_tab_erro);  
       
      END IF;
    ELSE
       pr_des_erro := 'Transferencia para prejuizo ja realizada para este contrato!';
       RAISE vr_exc_erro;
    END IF;
         
    IF vr_des_reto <> 'OK' THEN
      pr_des_erro := 'Erro na transferencia para prejuizo: ' || vr_tab_erro(vr_tab_erro.first).dscritic;
      RAISE vr_exc_erro;
    END IF;
   
    vr_dstransa := 'PREJ0001-Transferência para prejuizo, referente contrato: ' || pr_nrctremp ||
                   ', realizada com sucesso.'; 
    -- Gerando Log de Consulta
    GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                        ,pr_cdoperad => vr_cdoperad
                        ,pr_dscritic => 'OK'
                        ,pr_dsorigem => vr_dsorigem
                        ,pr_dstransa => vr_dstransa
                        ,pr_dttransa => TRUNC(SYSDATE)
                        ,pr_flgtrans => 1 --> SUCESSO/TRUE
                        ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                        ,pr_idseqttl => 1
                        ,pr_nmdatela => vr_nmdatela
                        ,pr_nrdconta => pr_nrdconta
                        ,pr_nrdrowid => vr_nrdrowid);
    -- Commit do LOG
    COMMIT;
  EXCEPTION
    WHEN vr_exc_erro THEN
      -- Desfazer alterações
      ROLLBACK;
      IF pr_des_erro IS NULL THEN
        pr_des_erro := 'Erro na rotina pc_transfere_prejuizo: '; 
      END IF;
      pr_dscritic := pr_des_erro;
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => 'INTRANET'
                          ,pr_dstransa => 'PREJ0001-Transferencia forçada para prejuizo.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' || 
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    WHEN OTHERS THEN
      -- Desfazer alterações
      ROLLBACK;
      pr_des_erro := 'Erro geral na rotina pc_transfere_prejuizo: '|| SQLERRM;
      pr_dscritic := pr_des_erro;
      pr_cdcritic := 0;
      pr_nmdcampo := '';
      -- Retorno não OK
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => NVL(pr_dscritic,' ')
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => 'PREJ0001-Transferência Prejuízo.'
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 0 --> ERRO/FALSE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      -- Carregar XML padrao para variavel de retorno nao utilizada.
      -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' || 
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    
  END pc_transfere_prejuizo_web;

   PROCEDURE pc_estorno_prejuizo_web (pr_nrdconta   IN VARCHAR2  -- Conta corrente
                                        ,pr_nrctremp   IN VARCHAR2  -- contrato
                                        ,pr_idtpoest   in varchar2
                                        ,pr_xmllog      IN VARCHAR2            --> XML com informações de LOG
                                        ,pr_cdcritic  OUT PLS_INTEGER          --> Código da crítica
                                        ,pr_dscritic  OUT VARCHAR2             --> Descrição da crítica
                                        ,pr_retxml     IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                        ,pr_nmdcampo  OUT VARCHAR2             --> Nome do campo com erro
                                        ,pr_des_erro  OUT VARCHAR2) IS         --> Erros do processo

     /* .............................................................................

      Programa: pc_estorno_prejuizo_web
      Sistema : AyllosWeb
      Sigla   : PREJ
      Autor   : Jean Calão - Mout´S
      Data    : Maio/2017.                  Ultima atualizacao: 29/05/2017

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado

      Objetivo  : Efetua o estorno de transferencias de contratos PP e TR para prejuízo 
      Observacao: Rotina chamada pela tela Atenda / Prestações, botão "Desfazer Prejuízo"
                  Também é chamada pela tela ESTPRJ (Estorno de prejuízos).

      Alteracoes:

     ..............................................................................*/
     -- Variáveis
     vr_cdcooper         NUMBER;
     vr_nmdatela         VARCHAR2(25);
     vr_nmeacao          VARCHAR2(25);
     vr_cdagenci         VARCHAR2(25);
     vr_nrdcaixa         VARCHAR2(25);
     vr_idorigem         VARCHAR2(25);
     vr_cdoperad         VARCHAR2(25);
     
     vr_nrdrowid    ROWID;
     vr_dsorigem    VARCHAR2(100);
     vr_dstransa    VARCHAR2(500);
     vr_cddepart    number(3);
     vr_tpemprst    integer;
     vr_inprejuz    integer;
     
     -- Excessões
     vr_exc_erro         EXCEPTION;
     
     cursor cr_crapope is
        select t.cddepart
        from   crapope t
        where  t.cdoperad = vr_cdoperad;
     
     
     cursor cr_craplem(pr_dtmvtolt in date) is
        select 1 
        from   craplem t
        where  cdcooper = vr_cdcooper
        and    nrdconta = pr_nrdconta
        and    nrctremp = pr_nrctremp
        and    dtmvtolt >= trunc(pr_dtmvtolt,'MM')
        and  cdhistor not in (1037   /* Juros Normais */
                               ,1038   /* Juros Normais */
                               ,1732   /* FINANCIAMENTO PRE-FIXADO TRANSFERIDO PARA PREJUIZO */
                               ,1734   /* MULTA MORA FINANC. PRE-FIXADO TRANSF. P/ PREJUIZO */
                               ,1736   /* JUROS MORA FINANC. PRE-FIXADO TRANSF. P/ PREJUIZO */
                               ,1731   /* EMPRESTIMO PRE-FIXADO TRANSFERIDO PARA PREJUIZO  */
                               ,1733   /* MULTA MORA EMPREST. PRE-FIXADO TRANSF. P/ PREJUIZO */
                               ,1735
                               ,2381
                               ,2397
                               ,2411
                               ,2382
                               ,2383
                               ,2396
                               ,2398
                               ,2401
                               ,2403
                               ,2408
                               ,2409
                               ,2410)
         and nvl((select sum(vllanmto) 
                   from  craplem lem
                  where  lem.cdcooper = t.cdcooper
                    and  lem.nrdconta = t.nrdconta
                    and  lem.nrctremp = t.nrctremp
                    and  lem.dtmvtolt >= trunc(pr_dtmvtolt,'MM')
                    and  lem.cdhistor = 2388)   ,0) - 
              nvl((select sum(vllanmto) 
                   from  craplem lem
                  where  lem.cdcooper = t.cdcooper
                    and  lem.nrdconta = t.nrdconta
                    and  lem.nrctremp = t.nrctremp
                    and  lem.dtmvtolt >= trunc(pr_dtmvtolt,'MM')
                    and  lem.cdhistor = 2392)   ,0) > 0; /* JUROS MORA EMPREST. PRE-FIXADO TRANSF. P/ PREJUIZO */
      --   
    CURSOR cr_trsn_antigo(prc_cdcooper IN craplem.cdcooper%TYPE
                         ,prc_nrdconta IN craplem.nrdconta%TYPE
                         ,prc_nrctremp IN craplem.nrctremp%TYPE) IS
      SELECT 1 existe
        FROM craplem lem
       WHERE lem.cdcooper = prc_cdcooper
         AND lem.nrdconta = prc_nrdconta
         AND lem.nrctremp = prc_nrctremp
         AND lem.cdhistor = 349;   
    vr_existePg integer;
    vr_trsn_antigo NUMBER(1);
         
   BEGIN
      
     -- Extrair informacoes padrao do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);


      open cr_crapope;
      fetch cr_crapope into vr_cddepart;
      close cr_crapope;
      
      --if vr_cddepart not in (3,9,20) then
      --   pr_des_erro := 'Acesso não permitido ao usuário!';
      --   raise vr_exc_erro;
      --end if;
      /* Busca data de movimento */
      open btch0001.cr_crapdat(vr_cdcooper);
      fetch btch0001.cr_crapdat into rw_crapdat;
      close btch0001.cr_crapdat;
      
      vr_trsn_antigo := 0; 
      FOR rw_trsn_antigo IN cr_trsn_antigo(vr_cdcooper,
                                           pr_nrdconta,
                                           pr_nrctremp)LOOP
        vr_trsn_antigo := rw_trsn_antigo.existe;

      END LOOP;
      
      IF vr_trsn_antigo >= 1 THEN
        pr_des_erro := 'Estorno não permitido, a transferência deste contrato foi realizado no modelo antigo';
        RAISE vr_exc_erro;          
      END IF;      
      
      /*Busca informações do emprestimo */
      open c_crapepr(pr_cdcooper => vr_cdcooper
                    ,pr_nrdconta => pr_nrdconta
                    ,pr_nrctremp => pr_nrctremp);
      
      fetch c_crapepr into r_crapepr;
      if c_crapepr%found then
         vr_tpemprst := r_crapepr.tpemprst;
         vr_inprejuz := r_crapepr.inprejuz;
      else   
         vr_tpemprst := null;
      end if;
      close c_crapepr;
      
      if to_char(r_crapepr.dtprejuz,'yyyymm') < to_char(rw_crapdat.dtmvtolt,'yyyymm') then
         pr_des_erro := 'Impossivel fazer estorno do contrato, pois este contrato foi feito antes do mes vigente';
         raise vr_exc_erro;
      end if;
      
      /* verifica se houve pagamentos */
      open cr_craplem(rw_crapdat.dtmvtolt);
      fetch cr_craplem into vr_existePg;
      close cr_craplem;
      
      if nvl(vr_existePg,0) = 1 then
         pr_des_erro := 'Existe Pagamento ou abono ativo para a conta: ' || pr_nrdconta || ', contrato: ' || pr_nrctremp;
         raise vr_exc_erro;
      end if;
      
      /* Gerando Log de Consulta */
      vr_dstransa := 'PREJ0001-Efetuando estorno da transferencia para prejuizo, Cooper: ' || vr_cdcooper || 
                      ' Conta: ' || pr_nrdconta || ', Contrato: ' || pr_nrctremp || ' Tipo: '
                       || r_crapepr.tpemprst || ' Data: ' || to_char(rw_crapdat.dtmvtolt,'DD/MM/YYYY');
                     
      
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => 'INTRANET'
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      
      IF nvl(vr_inprejuz,2) = 1 THEN
         /*if pr_nrdconta = pr_nrctremp then -- estorno de conta corrente
            pc_estorno_trf_prejuizo_CC(pr_cdcooper => vr_cdcooper
                                          ,pr_cdagenci => vr_cdagenci
                                          ,pr_nrdconta => pr_nrdconta
                                          ,pr_dtmvtolt => rw_crapdat.Dtmvtolt
                                          ,pr_des_reto => vr_des_reto --> Retorno OK / NOK
                                          ,pr_tab_erro => vr_tab_erro);
         else*/
        IF nvl(vr_tpemprst,2) = 1 THEN
          pc_estorno_trf_prejuizo_PP(pr_cdcooper => vr_cdcooper
                                   , pr_cdagenci => vr_cdagenci
                                   , pr_nrdcaixa => vr_nrdcaixa
                                   , pr_cdoperad => vr_cdoperad
                                   , pr_nrdconta => pr_nrdconta
                                   , pr_dtmvtolt => rw_crapdat.Dtmvtolt
                                   , pr_nrctremp => pr_nrctremp
                                   , pr_des_reto => vr_des_reto
                                   , pr_tab_erro => vr_tab_erro); 
                
        ELSIF nvl(vr_tpemprst, 2) = 0 THEN
          pc_estorno_trf_prejuizo_TR(pr_cdcooper => vr_cdcooper
                                   , pr_cdagenci => vr_cdagenci
                                   , pr_nrdcaixa => vr_nrdcaixa
                                   , pr_cdoperad => vr_cdoperad
                                   , pr_nrdconta => pr_nrdconta
                                   , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                   , pr_nrctremp => pr_nrctremp
                                   , pr_des_reto => vr_des_reto
                                   , pr_tab_erro => vr_tab_erro);  
        END IF;
      ELSE
         pr_des_erro := 'Contrato não está em prejuízo !';
         raise vr_exc_erro;
      END IF;
       
      if vr_des_reto <> 'OK' then
        IF vr_tab_erro.count() > 0 THEN 
          -- Atribui críticas às variaveis
          --vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
          pr_des_erro := vr_tab_erro(vr_tab_erro.first).dscritic;
          RAISE vr_exc_erro;
        ELSE
          --vr_cdcritic := 0;
          --vr_dscritic := 'Erro ao Estornar Pagamento '||sqlerrm;
          --raise vr_erro;
         pr_des_erro := 'Erro no estorno da transferencia de prejuizo, ver log!';
         raise vr_exc_erro;          
        END IF;        
        
      end if;
 
      vr_dstransa := 'PREJ0001-Estorno da transferência para prejuizo, referente contrato: ' || pr_nrctremp ||
                     ', realizada com sucesso.'; 
      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
   EXCEPTION
     WHEN vr_exc_erro THEN
       -- Desfazer alterações
       ROLLBACK;
       if pr_des_erro is null then
          pr_des_erro := 'Erro na rotina pc_estorno_prejuizo: '; 
       end if;
       pr_dscritic := pr_des_erro;
       -- Retorno não OK
       GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => NVL(pr_dscritic,' ')
                           ,pr_dsorigem => 'INTRANET'
                           ,pr_dstransa => 'PREJ0001-Estorno transferencia para prejuizo.'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
       if pr_dscritic like '%Existe Pagamento%' 
       and pr_idtpoest = 'L' -- estorno em lote
       then
          null;
       else
          pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' || 
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
       end if;
     WHEN OTHERS THEN
       -- Desfazer alterações
       ROLLBACK;
       pr_des_erro := 'Erro geral na rotina pc_estorno_prejuizo: '|| SQLERRM;
       pr_dscritic := pr_des_erro;
       pr_cdcritic := 0;
       pr_nmdcampo := '';
       -- Retorno não OK
       GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                           ,pr_cdoperad => vr_cdoperad
                           ,pr_dscritic => NVL(pr_dscritic,' ')
                           ,pr_dsorigem => vr_dsorigem
                           ,pr_dstransa => 'PREJ0001-Estorno da Transferência Prejuízo.'
                           ,pr_dttransa => TRUNC(SYSDATE)
                           ,pr_flgtrans => 0 --> ERRO/FALSE
                           ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                           ,pr_idseqttl => 1
                           ,pr_nmdatela => vr_nmdatela
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrdrowid => vr_nrdrowid);
       -- Commit do LOG
       COMMIT;
       -- Carregar XML padrao para variavel de retorno nao utilizada.
       -- Existe para satisfazer exigencia da interface.
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?>' || 
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    
      
   END pc_estorno_prejuizo_web;
   
   
   PROCEDURE pc_consulta_prejuizo_web(pr_dtprejuz in varchar2
                                      ,pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                      ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do Contrato
              						 		 			  ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
 				    	          	 		 			  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
						    				         			,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
          			    									,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
					              							,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
										              		,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_consulta_prejuizo_web
     Sistema : Rotinas referentes a transferencia para prejuizo
     Sigla   : PREJ
     Autor   : Jean Calão (Mout´S)
     Data    : Jun/2017.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Tela para consultar os estornos

     Observacao: -----
     Alteracoes:
     ..............................................................................*/
    DECLARE
      -- Cursor dos estornos
      CURSOR cr_crapepr(pr_cdcooper crapepr.cdcooper%TYPE
                       ,pr_dtprejuz crapepr.dtprejuz%type
                       ,pr_nrdconta crapepr.nrdconta%TYPE
                       ,pr_nrctremp crapepr.nrctremp%type) IS
       SELECT *
         FROM crapepr epr
        WHERE epr.cdcooper = pr_cdcooper
          AND epr.dtprejuz = nvl(pr_dtprejuz, epr.dtprejuz)
          AND epr.nrdconta = decode(pr_nrdconta, 0, epr.nrdconta, pr_nrdconta)
          AND epr.nrctremp = decode(pr_nrctremp, 0, epr.nrctremp, pr_nrctremp)
          AND epr.inprejuz = 1
          AND epr.cdlcremp <> 100;
          
        rw_crapepr cr_crapepr%rowtype;
        
      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);
      vr_contador      PLS_INTEGER := 0;
      vr_idtipo        varchar2(2);
      vr_dstipo        varchar2(25);
      
      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper        PLS_INTEGER;
      vr_cdoperad        VARCHAR2(100);
      vr_nmdatela        VARCHAR2(100);
      vr_nmeacao         VARCHAR2(100);
      vr_cdagenci        VARCHAR2(100);
      vr_nrdcaixa        VARCHAR2(100);
      vr_idorigem        VARCHAR2(100);
      vr_dstransa        varchar2(200);
      vr_dsorigem    VARCHAR2(100);
      vr_nrdrowid    ROWID;
      vr_vlemprst    NUMBER := 0;
    BEGIN
      
     -- Extrair informacoes padrao do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);


  
     vr_dstransa := 'Consulta prejuizo: ' || pr_dtprejuz || ', conta: ' ||
                     pr_nrdconta || ', contrato: ' || pr_nrctremp;
                     
      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => 'OK'
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => PR_NRDCONTA
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
      
      
      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      FOR rw_crapepr IN cr_crapepr(pr_cdcooper => vr_cdcooper,
                                   pr_dtprejuz => to_date(pr_dtprejuz,'DD/MM/YYYY'),
                                   pr_nrdconta => pr_nrdconta,
                                   pr_nrctremp => pr_nrctremp) LOOP
        
         if rw_crapepr.tpemprst = 1 then
             vr_idtipo := 'PP';
             vr_dstipo := 'Empréstimo PP';
             vr_vlemprst := rw_crapepr.vlprejuz;
          end if;   
          
          if rw_crapepr.tpemprst = 0 then
             vr_idtipo := 'TR';
             vr_dstipo := 'Empréstimo TR';
             vr_vlemprst := rw_crapepr.vlprejuz;
          end if;   
          
          if  rw_crapepr.nrdconta = rw_crapepr.nrctremp
          and rw_crapepr.cdlcremp = 100 then
             vr_idtipo := 'CC';
             vr_dstipo := 'Conta corrente';
             vr_vlemprst := rw_crapepr.vlsdprej;
          end if;     
          
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtprejuz', pr_tag_cont => to_char(rw_crapepr.dtprejuz,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrdconta', pr_tag_cont => rw_crapepr.nrdconta, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrctremp', pr_tag_cont => rw_crapepr.nrctremp, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlemprst', pr_tag_cont => vr_vlemprst, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'idtipo', pr_tag_cont => vr_idtipo, pr_des_erro => vr_dscritic);
          gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dstipo', pr_tag_cont => vr_dstipo, pr_des_erro => vr_dscritic);
          vr_contador := vr_contador + 1;

      END LOOP; /* END FOR rw_tbepr_estorno */

      IF vr_contador <= 0 THEN
        vr_dscritic := 'Nao existe prejuizo gerado para a conta informada.';
        RAISE vr_exc_saida;

      END IF;

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em EMPR0008.pc_tela_consultar_estornos: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
                                       
         -- gravar LOG de teste
      
     vr_dstransa := 'Consulta prejuizo: ' || pr_dtprejuz || ', conta: ' ||
                     pr_nrdconta || ', contrato: ' || pr_nrctremp;
                     
      -- Gerando Log de Consulta
      GENE0001.pc_gera_log(pr_cdcooper => vr_cdcooper
                          ,pr_cdoperad => vr_cdoperad
                          ,pr_dscritic => pr_dscritic
                          ,pr_dsorigem => vr_dsorigem
                          ,pr_dstransa => vr_dstransa
                          ,pr_dttransa => TRUNC(SYSDATE)
                          ,pr_flgtrans => 1 --> SUCESSO/TRUE
                          ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                          ,pr_idseqttl => 1
                          ,pr_nmdatela => vr_nmdatela
                          ,pr_nrdconta => PR_NRDCONTA
                          ,pr_nrdrowid => vr_nrdrowid);
      -- Commit do LOG
      COMMIT;
     
    END;

  END pc_consulta_prejuizo_web;
  
  PROCEDURE pc_importa_arquivo(pr_arquivo in varchar2
                                     ,pr_xmllog   IN VARCHAR2              --> XML com informac?es de LOG
                                     ,pr_cdcritic OUT PLS_INTEGER          --> Codigo da critica
                                     ,pr_dscritic OUT VARCHAR2             --> Descric?o da critica
                                     ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                     ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                     ,pr_des_erro OUT VARCHAR2)    IS
    /* Rotina: pc_importa_arquivo
       Autor:  Jean (Mout´s)
       Data:   25/07/2017
       Objetivo: Importa arquivo CSV com contas / contratos para transferir para prejuízo


    */
    vr_nm_arquivo varchar2(2000);
    vr_nm_arqlog  varchar2(2000);

    vr_handle_arq utl_file.file_type;
    vr_handle_log utl_file.file_type;

    vr_linha_arq     varchar2(2000);
    
    vr_nrlinha   number;
    vr_nrdconta  number;
    vr_nrctremp  number;
    vr_tipoprej  varchar2(2);
    vr_cdcooper  number;
    vr_cdcooperx varchar2(10);
    vr_nrdcontax varchar2(10);
    vr_nrctrempx varchar2(10);
    vr_tipoprejx varchar2(10);
    vr_indice    number;
    vr_indiceant number;

    vr_des_erro  varchar2(2000);
    
    vr_cdagenci         VARCHAR2(25);
    vr_nrdcaixa         VARCHAR2(25);
    vr_idorigem         VARCHAR2(25);
    vr_cdoperad         VARCHAR2(25);
    vr_nmeacao          varchar2(25);
    vr_nmdatela         varchar2(25);
    
    vr_tpemprst         integer;
    vr_inprejuz         integer;
 
    vr_rw_crapdat btch0001.rw_crapdat%type;
    vr_tab_erro gene0001.typ_tab_erro;
    vr_endarqui varchar2(100);
    
    vr_exc_erro exception;
  BEGIN


     -- Extrair informacoes padrao do xml - parametros
     gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                             ,pr_cdcooper => vr_cdcooper
                             ,pr_nmdatela => vr_nmdatela
                             ,pr_nmeacao  => vr_nmeacao
                             ,pr_cdagenci => vr_cdagenci
                             ,pr_nrdcaixa => vr_nrdcaixa
                             ,pr_idorigem => vr_idorigem
                             ,pr_cdoperad => vr_cdoperad
                             ,pr_dscritic => pr_dscritic);

     vr_endarqui:= gene0001.fn_diretorio(pr_tpdireto => 'M' -- /micros/coop
                                          ,pr_cdcooper => vr_cdcooper
                                          ,pr_nmsubdir => '/preju/');

    IF pr_arquivo is null then
        vr_nm_arquivo := vr_endarqui || '/prejuizo.csv';
    else
       vr_nm_arquivo := pr_arquivo;
    END IF;

    open btch0001.cr_crapdat(pr_cdcooper => 1);
    fetch btch0001.cr_crapdat into vr_rw_crapdat;
    close btch0001.cr_crapdat;


    vr_nm_arqlog  := vr_endarqui || '/prejuizo_log';

    /* verificar se o arquivo existe */
    if not gene0001.fn_exis_arquivo(pr_caminho => vr_nm_arquivo) then
      vr_des_erro := 'Erro rotina pc_gera_arq_saldo_devedor - Arquivo: '  || vr_nm_arquivo || ', inexistente!' ;                  
      pr_cdcritic := 3;
      raise vr_exc_erro;
    end if;

    /* Abrir o arquivo de importação */
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arquivo
                            ,pr_tipabert => 'R' --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_handle_arq --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro);

    if vr_des_erro is not null then
      vr_des_erro := 'Rotina pc_gera_arq_saldo_devedor: Erro abertura arquivo importaçao!' ||
                     sqlerrm;
      pr_cdcritic := 4;
      raise vr_exc_erro;
    end if;

    /* Abrir o arquivo de LOG */
    gene0001.pc_abre_arquivo(pr_nmcaminh => vr_nm_arqlog
                            ,pr_tipabert => 'W' --> Modo de abertura (R,W,A)
                            ,pr_utlfileh => vr_handle_log --> Handle do arquivo aberto
                            ,pr_des_erro => vr_des_erro);

    if vr_des_erro is not null then
       vr_des_erro := 'Rotina pc_gera_arq_saldo_devedor: Erro abertura arquivo LOG!' || sqlerrm;
       pr_cdcritic := 6;
       raise vr_exc_erro;
    end if;

    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                           pr_des_text => 'Inicio da geracao Arquivo LOG');

    /* Processar linhas do arquivo */
    vr_nrlinha := 1;

   
      BEGIN
        LOOP
         -- exit when vr_nrlinha = 1019;

          gene0001.pc_le_linha_arquivo(pr_utlfileh => vr_handle_arq,
                                       pr_des_text => vr_linha_arq);

          -- valida a partir da linha 2, linha 1 é cabeçalho
          if vr_nrlinha >= 2 then
            -- busca cooperativa
            vr_indice    := instr(vr_linha_arq, ';');
            vr_cdcooperx := substr(vr_linha_arq, 1, vr_indice - 1);
            vr_indiceant := vr_indice;
            vr_cdcooper  := to_number(rtrim(vr_cdcooperx));
            
            --busca tipo
            vr_indice    := instr(vr_linha_arq, ';', vr_indice + 1);
            vr_tipoprejx  := substr(vr_linha_arq,
                                   vr_indiceant + 1,
                                   vr_indice - vr_indiceant - 1);
            vr_indiceant := vr_indice;
            vr_tipoprej  := rtrim(vr_tipoprejx);

            --busca conta
            vr_indice    := instr(vr_linha_arq, ';', vr_indice + 1);
            vr_nrdcontax  := substr(vr_linha_arq,
                                   vr_indiceant + 1,
                                   vr_indice - vr_indiceant - 1);
            vr_indiceant := vr_indice;
            vr_nrdconta  := to_number(rtrim(vr_nrdcontax));

            --busca contrato
            vr_indice := instr(vr_linha_arq, ';', vr_indice + 1);

            if vr_indice = 0 then
              vr_indice := length(vr_linha_arq) + 1;
            end if;
            vr_nrctrempx := substr(vr_linha_arq,
                                  vr_indiceant + 1,
                                  vr_indice - vr_indiceant - 1);
            vr_nrctrempx := replace(vr_nrctrempx,chr(13),null);

            vr_nrctremp := to_number(rtrim(vr_nrctrempx));

            if vr_nrctremp is null then
              vr_des_erro := 'Erro no arquivo, campo número do contrato não está preenchido!';
              pr_cdcritic := 7;
              raise vr_exc_erro;
            end if;

            -- valida campos do arquivo de importaçao

            if vr_cdcooper is null then
              vr_des_erro := 'cooperativa não informada!';
              pr_cdcritic := 8;
              raise vr_exc_erro;
            end if;

            if vr_nrdconta is null then
              vr_des_erro := 'Conta não informada!';
              pr_cdcritic := 9;
              raise vr_exc_erro;
            end if;

            if vr_nrctremp is null then
              vr_des_erro := 'Contrato não informado!';
              pr_cdcritic := 10;
              raise vr_exc_erro;
            end if;
            
            /*if vr_tipoprej = 'CC' then
               open c_crapepr(pr_cdcooper => vr_cdcooper
                             ,pr_nrdconta => vr_nrdconta
                             ,pr_nrctremp => vr_nrctremp);
               fetch c_crapepr into r_crapepr;
                if c_crapepr%found then
                   vr_inprejuz := 1;
                else   
                   vr_inprejuz := 0;
                end if;              
                close c_crapepr;
                
                if vr_inprejuz = 0 then             
                   pc_transfere_prejuizo_CC_web(pr_nrdconta => vr_nrdconta
                                              , pr_xmllog => pr_xmllog
                                              , pr_cdcritic => pr_cdcritic
                                              , pr_dscritic => pr_dscritic
                                              , pr_retxml => pr_retxml
                                              , pr_nmdcampo => pr_nmdcampo
                                              , pr_des_erro => vr_des_erro);
                                              
                   if vr_des_erro is not null then
                      pr_des_erro := 'Erro ao transferir conta para prejuizo! Conta:' ||
                                       vr_nrdconta || ', cooperativa: ' || vr_cdcooper ;
                      gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                               pr_des_text => pr_des_erro);
                                               
                   else
                        commit;
                   end if;
               else 
                  pr_des_erro := 'Transferencia ja efetuada para esta conta corrente! Conta:' ||
                                   vr_nrdconta || ', cooperativa: ' || vr_cdcooper ;
                  gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                           pr_des_text => pr_des_erro);
               end if;
            end if;*/
            
            if vr_tipoprej = 'EP' then
               /*Busca informações do emprestimo */
                open c_crapepr(pr_cdcooper => vr_cdcooper
                             , pr_nrdconta => vr_nrdconta
                             , pr_nrctremp => vr_nrctremp);
                
                fetch c_crapepr into r_crapepr;
                if c_crapepr%found then
                   vr_tpemprst := r_crapepr.tpemprst;
                   vr_inprejuz := r_crapepr.inprejuz;
                else   
                   vr_tpemprst := null;
                end if;
                close c_crapepr;
                
                if nvl(vr_inprejuz,2) = 0 then
                      
                   if nvl(vr_tpemprst,2) = 1 then
                      pc_transfere_epr_prejuizo_PP(pr_cdcooper => vr_cdcooper
                                               , pr_cdagenci => vr_cdagenci
                                               , pr_nrdcaixa => vr_nrdcaixa
                                               , pr_cdoperad => vr_cdoperad
                                               , pr_nrdconta => vr_nrdconta
                                               , pr_idseqttl => 1
                                               , pr_dtmvtolt => rw_crapdat.Dtmvtolt
                                               , pr_nrctremp => vr_nrctremp
                                               , pr_des_reto => vr_des_reto
                                               , pr_tab_erro => vr_tab_erro); 
                        
                   else
                      if nvl(vr_tpemprst, 2) = 0 then
                         pc_transfere_epr_prejuizo_TR(pr_cdcooper => vr_cdcooper
                                                   , pr_cdagenci => vr_cdagenci
                                                   , pr_nrdcaixa => vr_nrdcaixa
                                                   , pr_cdoperad => vr_cdoperad
                                                   , pr_nrdconta => vr_nrdconta
                                                   , pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                   , pr_nrctremp => vr_nrctremp
                                                   , pr_des_reto => vr_des_reto
                                                   , pr_tab_erro => vr_tab_erro);  
                       end if;
                   end if;
                   commit;
                else
                   pr_des_erro := 'Transferencia para prejuizo ja realizada para este contrato! Conta:' ||
                                   vr_nrdconta || ', contrato: ' || vr_nrctremp || ', cooperativa: ' ||
                                   vr_cdcooper ;
                    gene0001.pc_escr_linha_arquivo(pr_utlfileh => vr_handle_log,
                                           pr_des_text => pr_des_erro);
                end if;
                
            end if;
            
          end if;
          vr_nrlinha := vr_nrlinha + 1;
        END LOOP;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          -- Fim das linhas do arquivo
          NULL;
      END;
  
    -- Fecha arquivos
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_arq);
    gene0001.pc_fecha_arquivo(pr_utlfileh => vr_handle_log);
    commit;
  EXCEPTION

    WHEN vr_exc_erro THEN
        pr_des_erro := vr_des_erro;
        pr_dscritic := pr_cdcritic || 'Erro na PREJ0001 verifique o arquivo de LOG: ' || PR_DES_ERRO ;

        pr_retxml := XMLType.createXML('<?xml version="1.0"  encoding="ISO-8859-1" ?> ' ||
                                     '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    WHEN OTHERS THEN
      raise_application_error(-20150,
                              'erro na rotina PREJ0001.pc_importa_arquivo: ' ||
                              sqlerrm);

  END pc_importa_arquivo;


PROCEDURE pc_tela_busca_contratos(pr_nrdconta IN crapepr.nrdconta%TYPE --> Numero da Conta
                                      ,pr_inprejuz in crapepr.inprejuz%type --> Indicador prejuizo
                                      ,pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                      ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                      ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                      ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                      ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                      ,pr_des_erro OUT VARCHAR2) IS         --> Erros do processo
  BEGIN
    /* .............................................................................

     Programa: pc_tela_busca_contratos
     Sistema : Rotinas referentes aos contratos de prejuizo
     Sigla   : LIMI
     Autor   : Jean Calao
     Data    : Agosto/2017.                    Ultima atualizacao:

     Dados referentes ao programa:

     Frequencia: Sempre que for chamado

     Objetivo  : Buscar todos os contratos

     Observacao: -----
     Alteracoes:
     ..............................................................................*/

    DECLARE
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE,
                        pr_nrdconta IN crapepr.nrdconta%TYPE) IS
        SELECT nrctremp,
               dtmvtolt,
               vlemprst,
               qtpreemp,
               vlpreemp,
               cdlcremp,
               cdfinemp
          FROM crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapepr.nrdconta = pr_nrdconta
           and crapepr.inprejuz = pr_inprejuz
           AND ((crapepr.vlsdeved > 0 
            and  pr_inprejuz = 0) -- contratos ativos
            or  (crapepr.vlsdeved <= 0 
            and  pr_inprejuz = 1)); --contratos em prejuizo 

      -- Variável de críticas
      vr_cdcritic      crapcri.cdcritic%TYPE;
      vr_dscritic      VARCHAR2(10000);

      -- Tratamento de erros
      vr_exc_saida     EXCEPTION;

      -- Variaveis padrao
      vr_cdcooper      NUMBER;
      vr_cdoperad      VARCHAR2(100);
      vr_nmdatela      VARCHAR2(100);
      vr_nmeacao       VARCHAR2(100);
      vr_cdagenci      VARCHAR2(100);
      vr_nrdcaixa      VARCHAR2(100);
      vr_idorigem      VARCHAR2(100);
      vr_contador      PLS_INTEGER := 0;

    BEGIN

      gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                              ,pr_cdcooper => vr_cdcooper
                              ,pr_nmdatela => vr_nmdatela
                              ,pr_nmeacao  => vr_nmeacao
                              ,pr_cdagenci => vr_cdagenci
                              ,pr_nrdcaixa => vr_nrdcaixa
                              ,pr_idorigem => vr_idorigem
                              ,pr_cdoperad => vr_cdoperad
                              ,pr_dscritic => vr_dscritic);

      -- Criar cabeçalho do XML
      pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Dados/>');

      -- Busca todos os emprestimos de acordo com o numero da conta
      FOR rw_crapepr IN cr_crapepr(pr_cdcooper => NVL(vr_cdcooper,16),
                                   pr_nrdconta => pr_nrdconta) LOOP

        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'Dados', pr_posicao => 0, pr_tag_nova => 'inf', pr_tag_cont => NULL, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'nrctremp', pr_tag_cont => rw_crapepr.nrctremp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'dtmvtolt', pr_tag_cont => TO_CHAR(rw_crapepr.dtmvtolt,'DD/MM/YYYY'), pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'qtpreemp', pr_tag_cont => rw_crapepr.qtpreemp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlemprst', pr_tag_cont => rw_crapepr.vlemprst, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'vlpreemp', pr_tag_cont => rw_crapepr.vlpreemp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdlcremp', pr_tag_cont => rw_crapepr.cdlcremp, pr_des_erro => vr_dscritic);
        gene0007.pc_insere_tag(pr_xml => pr_retxml, pr_tag_pai => 'inf', pr_posicao => vr_contador, pr_tag_nova => 'cdfinemp', pr_tag_cont => rw_crapepr.cdfinemp, pr_des_erro => vr_dscritic);
        vr_contador := vr_contador + 1;

      END LOOP; /* END FOR rw_craplem */

    EXCEPTION
      WHEN vr_exc_saida THEN
        -- Se foi retornado apenas código
        IF vr_cdcritic > 0 AND vr_dscritic IS NULL THEN
          -- Buscar a descrição
          vr_dscritic := gene0001.fn_busca_critica(vr_cdcritic);
        END IF;


        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN

        pr_cdcritic := vr_cdcritic;
        pr_dscritic := 'Erro geral em PREJ0001.pc_tela_busca_contratos: ' || SQLERRM;

        -- Carregar XML padrão para variável de retorno não utilizada.
        -- Existe para satisfazer exigência da interface.
        pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                       '<Root><Erro>' || pr_dscritic || '</Erro></Root>');

    END;

  END pc_tela_busca_contratos;
  
  PROCEDURE pc_dispara_email_lote (pr_idtipo   IN VARCHAR2  -- Conta corrente
                                  ,pr_nrctremp IN VARCHAR2  -- contrato
                                  ,pr_xmllog   IN VARCHAR2            --> XML com informações de LOG
                                  ,pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                  ,pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                  ,pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                  ,pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                  ,pr_des_erro OUT VARCHAR2) IS 
                                        
    vr_conteudo   VARCHAR2(4000);
    vr_dscritic   VARCHAR2(4000);
      
    -- Variaveis padrao
    vr_cdcooper  NUMBER;
    vr_cdoperad  VARCHAR2(100);
    vr_nmdatela  VARCHAR2(100);
    vr_nmeacao   VARCHAR2(100);
    vr_cdagenci  VARCHAR2(100);
    vr_nrdcaixa  VARCHAR2(100);
    vr_idorigem  VARCHAR2(100);
    vr_contador  PLS_INTEGER := 0;
      
    CURSOR c01(pr_cdcooper NUMBER) IS
      SELECT lgm.dscritic
        FROM craplgm lgm
       WHERE lgm.cdcooper = pr_cdcooper
         AND lgm.dttransa = trunc(SYSDATE)
         AND lgm.dscritic LIKE '%Pagamento%';
         
         
  BEGIN
    --
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml
                            ,pr_cdcooper => vr_cdcooper
                            ,pr_nmdatela => vr_nmdatela
                            ,pr_nmeacao  => vr_nmeacao
                            ,pr_cdagenci => vr_cdagenci
                            ,pr_nrdcaixa => vr_nrdcaixa
                            ,pr_idorigem => vr_idorigem
                            ,pr_cdoperad => vr_cdoperad
                            ,pr_dscritic => vr_dscritic);
                              
    vr_conteudo := 'Existem erros na rotina de estorno em lote de prejuizo, conforme criticas abaixo: <br> ' || 
                  'Para essas contas, não foi estornado a tranferência a prejuízo<br>' ;
    vr_contador := 0;
    --
    FOR r01 IN c01(vr_cdcooper) LOOP
      vr_conteudo := vr_conteudo || r01.dscritic || '<br>';
      vr_contador := vr_contador + 1;
    END LOOP;
                                           
    vr_dscritic := NULL;
    IF vr_contador > 0 THEN 
       --/* Envia e-mail para o Operador */
      gene0003.pc_solicita_email(pr_cdcooper        => vr_cdcooper
                                ,pr_cdprogra        => 'PREJ0001'
                                ,pr_des_destino     => ''
                                ,pr_des_assunto     => 'ERRO NA EXECUCAO JOB: Estorno em Lote'
                                ,pr_des_corpo       => vr_conteudo
                                ,pr_des_anexo       => NULL
                                ,pr_flg_remove_anex => 'N' --> Remover os anexos passados
                                ,pr_flg_remete_coop => 'N' --> Se o envio sera do e-mail da Cooperativa
                                ,pr_flg_enviar      => 'S' --> Enviar o e-mail na hora
                                ,pr_des_erro        => vr_dscritic);
    END IF;
  END pc_dispara_email_lote;   
  --
  
  PROCEDURE pc_controla_exe_job(pr_cdcritic OUT NUMBER,
                                pr_dscritic OUT VARCHAR2) 
  IS
  /* ..........................................................................
  Procedure : pc controla exe job
  Sistema : CECRED
  Sigla   : CRED
  Autor   : Xxxx
  Data    : Xxxxx/9999                      Ultima atualizacao: 09/01/2019

  Dados referentes ao programa:
  Frequencia: Sempre que for chamado
  Objetivo  : Procedure para tratar transfêrencia de prejuizo
  
  Job permanente: JBP_TRANSFERENCIA_PREJU
  Job reagendado: JBPRE_TRF_PRE_REP_$123456789  

  Alterações:  09/01/2019 - 1) Ajuste reagendamento do processo.
                            2) Padrões: 
                            Others, Modulo/Action, PC Internal Exception, PC Log Programa
                            Inserts, Updates, Deletes e SELECT's, Parâmetros                            
                            (Envolti - Belli - PRB00040466)
                            
  ............................................................................. */     
  --
  -- Cursor
  CURSOR cr_crapcop IS
    SELECT cop.cdcooper
      FROM crapcop cop
     WHERE cop.cdcooper <> 3
     AND   cop.flgativo = 1 -- Seleciona cooperativas ativas - 09/01/2019 - PRB00040466
     ORDER BY cop.cdcooper;  
  --
  -- Variaveis
  
  vr_cdcoppar crapcop.cdcooper%TYPE;  
  vr_infimsol INTEGER;
  vr_cdcritic crapcri.cdcritic%TYPE;
  vr_dscritic VARCHAR2(10000); 
  ---vr_cdprogra VARCHAR2(40) := 'PC_CONTROLA_EXE_JOB'; - Não mais utilizado - 09/01/2019 - PRB00040466
  vr_nomdojob VARCHAR2(40) := 'JBP_TRANSFERENCIA_PREJU'; 
  --vr_dserro   VARCHAR2(10000); - Não mais utilizado - 09/01/2019 - PRB00040466
  --vr_dstexto  VARCHAR2(2000);  - Não mais utilizado - 09/01/2019 - PRB00040466
  vr_titulo   VARCHAR2(1000);
  vr_destinatario_email VARCHAR2(500);
  vr_idprglog   tbgen_prglog.idprglog%TYPE;
  --vr_exc_erro   EXCEPTION; - Não mais utilizado - 09/01/2019 - PRB00040466
  vr_dtmvtolt DATE;
  --vr_flgerlog    BOOLEAN := FALSE; - Não mais utilizado - 09/01/2019 - PRB00040466
  vr_dsvlrgar  VARCHAR2(32000) := '';
  vr_tipsplit  gene0002.typ_split;   
  vr_permite_trans NUMBER(1); 
  
  -- Variaveis para tratar erro e reagendamento do processo -- 09/01/2019 - PRB00040466
  vr_exc_erro_tratado   EXCEPTION;
  vr_exc_montada        EXCEPTION;
  vr_exc_others         EXCEPTION;      
  vr_sqlerrm  VARCHAR2(4000); 
  vr_qtdexec  INTEGER:= 0; 
  vr_cdproexe tbgen_prglog.cdprograma%TYPE := 'PREJ0001';            -- Programa que esta executando
  vr_nmrotpro tbgen_prglog.cdprograma%TYPE := 'pc_controla_exe_job'; -- Procedure que esta executando
  -- cdrotcpl: Rotina completa PCK e Procedure pois ela é independente e disparada por um Job
  --           O melhor seria ter criado uma procedure de controle e ela sim disparar procedures pcks..
  vr_cdrotcpl tbgen_prglog.cdprograma%TYPE;                         -- Rotina completa
  vr_nmjobtmp tbgen_prglog.cdprograma%TYPE := 'JBPRE_TRF_PRE_REP';  -- Job temporario para reagendamento
  vr_cdproint tbgen_prglog.cdprograma%TYPE := NULL;                 -- Procedure Interna que esta executando
  vr_nmsistem crapprm.nmsistem%TYPE := 'CRED';
  vr_cdacesso crapprm.cdacesso%TYPE;   
  vr_dsvlrprm crapprm.dsvlrprm%TYPE; 
  vr_dsagenda VARCHAR2 (4000) := NULL;
  vr_hriniexe VARCHAR2    (5) := NULL;
  vr_hrageexe VARCHAR2    (5) := NULL;
  vr_hrfimexe VARCHAR2    (5) := NULL;  
  vr_dtsysdat DATE;
  vr_cdcoplog crapcop.cdcooper%TYPE;                -- Código da cooperativa do log
  vr_cdproctr crapprg.cdprogra%TYPE := 'PREJU_TRF'; -- Transformado GRVM0001 pc controla exe job" em "PREJU TRF", motivo max de 10 caracteres no processo de reagendamento
  vr_dsparame VARCHAR2 (4000);
  vr_dsparcop VARCHAR2 (4000);
  vr_dsparint VARCHAR2 (4000);
  vr_ctreajob NUMBER      (2) := 0;                 -- Controle para reagendamento
  
  -- Procedure Internas 

  -- Controla log proc_batch, para apenas exibir qnd realmente processar informação
  PROCEDURE pc_controla_log_batch(pr_dstiplog IN VARCHAR2 DEFAULT 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                                 ,pr_tpocorre IN NUMBER   DEFAULT 2   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                                 ,pr_cdcricid IN NUMBER   DEFAULT 2   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                                 ,pr_tpexecuc IN NUMBER   DEFAULT 2   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                                 ,pr_dscritic IN VARCHAR2 DEFAULT NULL
                                 ,pr_cdcritic IN INTEGER  DEFAULT NULL
                                 ,pr_flgsuces IN NUMBER   DEFAULT 0    -- Indicador de sucesso da execução  
                                 ,pr_flabrchd IN INTEGER  DEFAULT 1    -- Abre chamado 1 Sim/ 0 Não
                                 ,pr_textochd IN VARCHAR2 DEFAULT NULL -- Texto do chamado
                                 ,pr_desemail IN VARCHAR2 DEFAULT NULL -- Destinatario do email
                                 ,pr_flreinci IN INTEGER  DEFAULT 1    -- Erro pode reincidir no prog em dias diferentes, devendo abrir chamado
                                 ,pr_cdcopprm IN VARCHAR2 DEFAULT NULL -- Cooperativa      
  ) 
  IS
  /* ..........................................................................    
  Procedure: pc controla log batch
  Sistema  : CECRED
  Autor    : Belli/Envolti - PRB00040466
  Data     : 09/01/2019                        Ultima atualizacao: 09/01/2019
    
  Dados referentes ao programa:    
  Frequencia: Sempre que for chamado
  Objetivo  : Chamar a rotina de Log para gravação de criticas.
    
  Alteracoes: 
    
  ............................................................................. */
    
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;
  BEGIN
    -- Controlar geração de log de execução dos jobs                                
    CECRED.pc_log_programa(pr_dstiplog      => pr_dstiplog -- I-início/ F-fim/ O-ocorrência/ E-erro 
                          ,pr_tpocorrencia  => pr_tpocorre -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_cdcriticidade => pr_cdcricid -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          ,pr_tpexecucao    => pr_tpexecuc -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                          ,pr_dsmensagem    => SUBSTR(pr_dscritic,1,3900)
                          ,pr_cdmensagem    => pr_cdcritic
                          ,pr_cdcooper      => pr_cdcopprm 
                          ,pr_flgsucesso    => pr_flgsuces
                          ,pr_flabrechamado => pr_flabrchd -- Abre chamado 1 Sim/ 0 Não
                          ,pr_texto_chamado => pr_textochd
                          ,pr_destinatario_email => pr_desemail
                          ,pr_flreincidente => pr_flreinci
                          ,pr_cdprograma    => vr_cdrotcpl
                          ,pr_idprglog      => vr_idprglog
                          );   
    IF LENGTH(pr_dscritic) > 3900 THEN   
      -- Controlar geração de log de execução dos jobs                                
      CECRED.pc_log_programa(pr_dstiplog      => 'O' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                            ,pr_tpocorrencia  => 3 -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                            ,pr_cdcriticidade => 0 -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                            ,pr_tpexecucao    => 2 -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                            ,pr_dsmensagem    => gene0001.fn_busca_critica(pr_cdcritic => 9999) ||
                                            '. Estouro do atributo pr_dscritic com tamanho de: '||LENGTH(pr_dscritic)||
                                            '. ' || vr_cdrotcpl || 
                                            '. ' || SUBSTR(pr_dscritic,3901,3900) 
                            ,pr_cdmensagem    => 9999
                            ,pr_cdcooper      => pr_cdcopprm 
                            ,pr_flgsucesso    => pr_flgsuces
                            ,pr_flabrechamado => pr_flabrchd -- Abre chamado 1 Sim/ 0 Não
                            ,pr_texto_chamado => pr_textochd
                            ,pr_destinatario_email => pr_desemail
                            ,pr_flreincidente => pr_flreinci
                            ,pr_cdprograma    => vr_cdrotcpl
                            ,pr_idprglog      => vr_idprglog
                            );     
    END IF;                                                       
  EXCEPTION
    WHEN OTHERS THEN
      -- No caso de erro de programa gravar tabela especifica de log  
      CECRED.pc_internal_exception (pr_cdcooper => pr_cdcopprm
                                   ,pr_compleme => 'LENGTH(pr_dscritic):' || LENGTH(pr_dscritic) ||
                                                   'pr_cdcritic:'         || pr_cdcritic
                                   );      
  END pc_controla_log_batch;   
    
  -- 
  PROCEDURE pc_le_crapprm
  IS
  /* ..........................................................................    
  Procedure: pc le crapprm
  Sistema  : CECRED
  Autor    : Belli/Envolti - PRB00040466
  Data     : 09/01/2019                        Ultima atualizacao: 09/01/2019
    
  Dados referentes ao programa:    
  Frequencia: Sempre que for chamado  
  Objetivo  : Posicionar parâmetros
  
  Regra de pesquisa:
    Primeiro le o registro com o codigo da cooperativa, se não encontrar 
    le o registro com o codigo da cooperativa com ZERO, 
    desta forma para os parametros iguais em todas cooperativas basta um cadastro.    
  ............................................................................. */
   
  vr_cdcoppar crapprm.cdcooper%TYPE;
  
  --
  PROCEDURE pc_le_crapprm_cooper
  IS
  /* ..........................................................................    
  Procedure: pc le crapprm cooper
  Sistema  : CECRED
  Autor    : Belli/Envolti - PRB00040466
  Data     : 09/01/2019                        Ultima atualizacao: 09/01/2019
    
  Dados referentes ao programa:    
  Frequencia: Sempre que for chamado
  
  Objetivo  : Posicionar parâmetros por cooperativa
  .............................................................................*/
  
  BEGIN
    SELECT  t30.dsvlrprm
    INTO    vr_dsvlrprm
    FROM    crapprm t30
    WHERE   t30.nmsistem = vr_nmsistem
    AND     t30.cdcooper = vr_cdcoppar
    AND     t30.cdacesso = vr_cdacesso;
  END;
  --
  BEGIN
    vr_cdcoppar := vr_cdcoplog;
    pc_le_crapprm_cooper;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      --
      vr_cdcoppar := 0;
      BEGIN
        pc_le_crapprm_cooper;
      EXCEPTION
        WHEN vr_exc_montada THEN  
          RAISE vr_exc_montada;
        WHEN vr_exc_erro_tratado THEN 
          RAISE vr_exc_erro_tratado; 
        WHEN vr_exc_others THEN 
          RAISE vr_exc_others; 
        WHEN OTHERS THEN   
          -- No caso de erro de programa gravar tabela especifica de log
          cecred.pc_internal_exception(pr_cdcooper => vr_cdcoplog); 
          -- Trata erro
          pr_cdcritic := 1036;
          pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)  ||                  
                         ' crapprm(8): '  ||
                         vr_dsparame      ||
                         ', vr_cdcoppar:' || vr_cdcoppar ||
                         ', vr_cdacesso:' || vr_cdacesso ||
                         '. ' || SQLERRM; 
          RAISE vr_exc_montada;
      END;
      --
    WHEN vr_exc_montada THEN  
      RAISE vr_exc_montada;
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcoplog); 
      -- Trata erro
      pr_cdcritic := 1036;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic)  ||                  
                    ' crapprm(4): '  ||
                    vr_dsparame      ||
                    ', vr_cdcoppar:' || vr_cdcoppar ||
                    ', vr_cdacesso:' || vr_cdacesso ||
                    '. ' || SQLERRM; 
      RAISE vr_exc_montada;
  END pc_le_crapprm;            
  --
               
  --  
  PROCEDURE pc_cria_job 
  IS
  /* ..........................................................................    
  Procedure: pc cria job
  Sistema  : CECRED
  Autor    : Belli/Envolti - PRB00040466
  Data     : 09/01/2019                        Ultima atualizacao: 09/01/2019
    
  Dados referentes ao programa:    
  Frequencia: Sempre que for chamado
  Objetivo  : cria job.
    
  Alteracoes: 
    
  ............................................................................. */ 
  --  
    vr_nmjobage    VARCHAR2  (100); -- Nome do job agendado
    vr_dsplsql     VARCHAR2 (4000);
    vr_dtagenda    DATE;
  BEGIN
    -- Posiciona procedure
    vr_cdproint := 'pc_cria_job';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => vr_cdproint);    
    vr_dsparint := ', vr_cdproint:' || vr_cdproint ||
                   ', vr_hrfimexe:' || vr_hrfimexe ||
                   ', vr_dtsysdat:' || TO_CHAR(vr_dtsysdat,'HH24:MI')||
                   ', vr_ctreajob:' || vr_ctreajob;                  
    -- posiciona parametros
    vr_cdacesso := 'PREJU_TRF_HOR_EXE';         
    pc_le_crapprm;
    -- Retorno  do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => vr_cdproint);   
    vr_dsagenda := vr_dsvlrprm;
    vr_hriniexe := SUBSTR(vr_dsagenda,01,05);
    vr_hrageexe := SUBSTR(vr_dsagenda,07,05);
    vr_hrfimexe := SUBSTR(vr_dsagenda,13,05);          
    --Horario de agendamento
    vr_dtagenda := ( vr_dtsysdat + (( ( SUBSTR(vr_hrageexe,1,2) * 60 ) + SUBSTR(vr_hrageexe,4,2) ) /1440) );
    vr_dsparint := vr_dsparint ||
                   ', vr_nmjobage:' || vr_nmjobage ||
                   ', vr_dsplsql:'  || vr_dsplsql  ||
                   ', vr_hriniexe:' || vr_hriniexe ||
                   ', vr_hrageexe:' || vr_hrageexe ||
                   ', vr_hrfimexe:' || vr_hrfimexe ||
                   ', vr_dtagenda:' || vr_dtagenda;
    -- Verifica se pode reagendar
    IF vr_hrfimexe < TO_CHAR(vr_dtsysdat,'HH24:MI') THEN
      -- Log acompanhamento
      pc_controla_log_batch(pr_cdcritic => 1201
                            ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                            '. Passou do horario limite'     || 
                                            ' ' || vr_dsparame ||
                                            ' ' || vr_dsparint
                            ,pr_dstiplog => 'O'
                            ,pr_tpocorre => 4
                            ,pr_flabrchd => 0
                            ,pr_cdcopprm => 0);
     ELSE                 
      -- Reagendado    
      vr_nmjobage  := vr_nmjobtmp || '_' || '$';
      vr_dsplsql  := 
      'declare
         vr_cdcritic number;
         vr_dscritic varchar2(4000);								
       begin 
         cecred.'    || 
         vr_cdrotcpl ||
         '(pr_cdcritic => vr_cdcritic, pr_dscritic => vr_dscritic); 
         if vr_dscritic is not null then
           RAISE_application_error(-20500,vr_dscritic);
          end if;
       end;';
      -- Log acompanhamento - Forçado Log - Teste Belli
      pc_controla_log_batch(pr_cdcritic => 1201
                           ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                               '. Vai Executar gene0001.pc_submit_job' ||
                                               ' ' || vr_dsparame ||
                                               ' ' || vr_dsparint ||
                                               ', vr_dtmvtolt:'   || vr_dtmvtolt
                               ,pr_dstiplog => 'O'
                               ,pr_tpocorre => 4
                               ,pr_flabrchd => 0
                               ,pr_cdcopprm => 0);                 
      
      -- Faz a chamada ao programa paralelo atraves de JOB
      -- Forçado comentario da rotina para Teste Belli
      gene0001.pc_submit_job(pr_cdcooper  => vr_cdcoplog     -- Código da cooperativa
                            ,pr_cdprogra  => vr_cdproexe     -- Código do programa
                            ,pr_dsplsql   => vr_dsplsql      -- Bloco PLSQL a executar
                            ,pr_dthrexe   => vr_dtagenda     -- Horario da execução
                            ,pr_interva   => NULL            -- apenas uma vez
                            ,pr_jobname   => vr_nmjobage     -- Nome randomico criado
                            ,pr_des_erro  => vr_dscritic);
      --                   
      IF TRIM(vr_dscritic) is not null THEN
        -- Montar mensagem de critica
        vr_cdcritic := 0;
        vr_dscritic := vr_dscritic ||
                       ' Retorno gene0001.pc_submit_job';
        RAISE vr_exc_erro_tratado;    
      END IF;   
    END IF;
        
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => NULL);  
  EXCEPTION 
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => 0); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;            
  END pc_cria_job;
  
  --  
  PROCEDURE pc_trata_nro_execucoes(pr_cdcopexe    IN NUMBER
                                  ,pr_dtproces    IN DATE
                                  ,pr_cdtipope    IN VARCHAR2
                                  ,pr_qtdexec     OUT INTEGER
                                  )         
  IS    
  /* ..........................................................................
    
  Procedure: pc trata nro execucoes
  Sistema  : AILOS
  Autor    : Belli/Envolti - PRB00040466
  Data     : 09/01/2019                        Ultima atualizacao: 09/01/2019
    
  Dados referentes ao programa:    
  Frequencia: Sempre que for chamado
  Objetivo  : Trata  execucoes
    
  Alteracoes:                            
    
  ............................................................................. */
    vr_flultexe    INTEGER          := NULL;
    vr_qtdexec     INTEGER          := NULL;
  BEGIN
    -- Posiciona procedure
    vr_cdproint := 'pc_trata_nro_execucoes';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => vr_cdproint);    
    vr_dsparint := ', vr_cdproint:'  || vr_cdproint ||
                   ', vr_hrfimexe:'  || vr_hrfimexe ||
                   ', pr_cdcopexe:'  || pr_cdcopexe ||
                   ', pr_cdtipope:'  || pr_cdtipope ||
                   ', pr_dtproces:'  || pr_dtproces ||
                   ', vr_cdproctr:'  || vr_cdproctr;
    --> Verificar a execução
    CECRED.gene0001.pc_controle_exec_pragma(pr_cdcooper  => pr_cdcopexe       --> Código da coopertiva
                                    ,pr_cdtipope  => pr_cdtipope       --> Tipo de operacao I-incrementar e C-Consultar
                                    ,pr_dtmvtolt  => pr_dtproces       --> Data do movimento
                                    ,pr_cdprogra  => vr_cdproctr       --> Codigo do programa
                                    ,pr_flultexe  => vr_flultexe       --> Retorna se é a ultima execução do procedimento
                                    ,pr_qtdexec   => vr_qtdexec        --> Retorna a quantidade
                                    ,pr_cdcritic  => vr_cdcritic       --> Codigo da critica de erro
                                    ,pr_dscritic  => vr_dscritic);     --> descrição do erro se ocorrer
    pr_qtdexec := vr_qtdexec;                                                               
    --Trata retorno
    IF nvl(vr_cdcritic,0) > 0         OR
        TRIM(vr_dscritic)   IS NOT NULL THEN
      vr_dscritic := vr_dscritic ||
                     ' Retorno gene0001.pc_controle_exec_pragma';
      RAISE vr_exc_erro_tratado;
    END IF;
    
    -- Limpa Action do modulo logado
    GENE0001.pc_informa_acesso(pr_module => vr_cdrotcpl, pr_action => NULL);
  EXCEPTION
      -- apenas repassar as criticas
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => pr_cdcopexe); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;  		           
  END pc_trata_nro_execucoes;
  
  -- pc processo
  PROCEDURE pc_processo
  IS
  /* ..........................................................................    
  Procedure: pc processo
  Sistema  : CECRED
  Autor    : Belli/Envolti - PRB00040466
  Data     : 09/01/2019                        Ultima atualizacao: 09/01/2019
    
  Dados referentes ao programa:    
  Frequencia: Sempre que for chamado
  Objetivo  : processa realmente o negocio por cooperativa.
    
  Alteracoes: 
    
  ............................................................................. */ 
  --   
  BEGIN
    -- Posiciona procedure
    vr_cdproint := 'pc_processo';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => vr_cdproint);    
    vr_cdcoplog := vr_cdcoppar;
    vr_dsparint := ', vr_cdproint:' || vr_cdproint ||
                   ', vr_cdcoplog:' || vr_cdcoplog;
      
    -- Log de inicio de execucao para cada cooperativa
    pc_controla_log_batch(pr_dstiplog => 'I'
                         ,pr_cdcopprm => vr_cdcoplog);
    
    -- Forçada log - Teste Belli 
    -- Log acompanhamento
    pc_controla_log_batch(pr_cdcritic => 1201
                             ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                             '. Vai executar as rotinas de negocio' ||
                                             ' pc_crps780 e PREJ0003.pc_transfere_prejuizo_cc' ||
                                             ' ' || vr_dsparame ||
                                             ' ' || vr_dsparint
                             ,pr_dstiplog => 'O'
                             ,pr_tpocorre => 4
                             ,pr_flabrchd => 0
                             ,pr_cdcopprm => vr_cdcoplog);  
      
    -- Forçado erro - Teste Belli
    --vr_cdcritic := 0 / 0; 
        
    --/* -- Forçada não execução - Teste Belli                                    
    pc_crps780(pr_cdcooper => vr_cdcoplog
              ,pr_nmdatela => 'job'
              ,pr_infimsol => vr_infimsol
              ,pr_cdcritic => vr_cdcritic
              ,pr_dscritic => vr_dscritic);
    --*/ -- Forçada não execução - Teste Belli                                          
    IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN 
      -- Montar mensagem de critica
      vr_dscritic := vr_dscritic ||
                     ' Retorno pc_crps780';                                         
      RAISE vr_exc_erro_tratado; 
    END IF;
    -- Retorna módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => vr_cdproint);

	  PREJ0005.pc_executa_job_prejuizo(pr_cdcooper => vr_cdcoplog
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
                                                     
    IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
      -- Montar mensagem de critica
      vr_dscritic := vr_dscritic ||
                     ' Retorno PREJ0005.pc_executa_job_prejuizo';                 
      RAISE vr_exc_erro_tratado; 
    END IF;

	  -- Retorna módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => vr_cdproint);
        
    -- Se as regras de prejuízo de conta corrente estão ativas para a cooperativa
    IF PREJ0003.fn_verifica_flg_ativa_prju(vr_cdcoplog) THEN      
      -- Retorna módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => vr_cdproint);
    
      -- Rotinas referente a calculo de juros, pagamento e liquidação de prejuizo de conta corrente
      -- serão executados durante o processo batch no crps752.      
      -- Transfere contas corrente para prejuízo
      --/* -- Forçada não execução - Teste Belli
      CECRED.PREJ0003.pc_transfere_prejuizo_cc(pr_cdcooper => vr_cdcoplog
                                              ,pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic
                                              ,pr_tab_erro => vr_tab_erro );
      --*/ -- Forçada não execução - Teste Belli                                        
      IF NVL(vr_cdcritic,0) <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Montar mensagem de critica
        vr_dscritic := vr_dscritic ||
                       ' Retorno PREJ0003.pc_transfere_prejuizo_cc';                 
        RAISE vr_exc_erro_tratado; 
      END IF;
    END IF; 
    -- Retorna módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => vr_cdproint);      
      
    -- Forçado erro Tratado nesta PCK - De origem externa - Teste Belli
    --vr_dscritic := vr_dscritic || '9999 -  Erro nao tratado: BLA BLA BLA ,,, BLA ,, BLA' ||
    --               ' Retorno PREJ0003.pc_transfere_prejuizo_cc';                 
    --RAISE vr_exc_erro_tratado;
          
    -- Registra que programa executou        
    pc_trata_nro_execucoes(pr_cdcopexe  => vr_cdcoplog
                          ,pr_dtproces  => TRUNC(vr_dtsysdat)
                          ,pr_cdtipope  => 'I'
                          ,pr_qtdexec   => vr_qtdexec);                                                
    -- Retorna módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => vr_cdproint);
      
    -- Log de fim de execucao
    pc_controla_log_batch(pr_dstiplog => 'F'
                         ,pr_cdcopprm => vr_cdcoplog);
                         
    vr_cdcoplog := 0;  -- Volta para rotina sem cooperativa               
    
    -- Limpa Action do modulo logado
    GENE0001.pc_informa_acesso(pr_module => vr_cdrotcpl, pr_action => NULL);
  EXCEPTION 
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcoplog); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;            
  END pc_processo; 

  -- Verifica a execução da cooperativa    
  PROCEDURE pc_ver_exe_coop
  IS  
  /* ..........................................................................    
  Procedure: pc ver exe coop
  Sistema  : CECRED
  Autor    : Belli/Envolti - PRB00040466
  Data     : 09/01/2019                        Ultima atualizacao: 09/01/2019
    
  Dados referentes ao programa:    
  Frequencia: Sempre que for chamado
  Objetivo  : Verifica a execução da cooperativa
    
  Alteracoes: 
    
  ............................................................................. */ 
  --   
  BEGIN  
    -- Posiciona procedure
    vr_cdproint := 'pc_ver_exe_coop';
    -- Inclusão do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => vr_cdproint); 
    vr_dsparint := ', vr_cdproint:' || vr_cdproint;
      
    vr_dsvlrgar := GENE0001.fn_param_sistema(pr_nmsistem => 'CRED'
                                            ,pr_cdcooper => 0
                                            ,pr_cdacesso => 'BLOQ_AUTO_PREJ');
    vr_tipsplit := gene0002.fn_quebra_string(pr_string => vr_dsvlrgar, pr_delimit => ';'); 
    -- Retorno do módulo e ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => vr_cdproint);
    
    vr_permite_trans := 1;
    FOR i IN vr_tipsplit.first..vr_tipsplit.last LOOP
      IF vr_cdcoppar = vr_tipsplit(i) THEN
        vr_permite_trans := 0;
      END IF;
    END LOOP;
      
    -- Forçado erro - Teste Belli
    --vr_cdcritic := 0 / 0;
       
    IF vr_permite_trans = 1 THEN
                      
      -- Confere se já executou
      pc_trata_nro_execucoes(pr_cdcopexe  => vr_cdcoppar
                            ,pr_dtproces  => TRUNC(vr_dtsysdat)
                            ,pr_cdtipope  => 'C2' -- Leva em conta a data 
                            ,pr_qtdexec   => vr_qtdexec);
      -- Retorno do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => vr_cdproint);
      vr_dsparint := vr_dsparint ||
                     ', vr_qtdexec:' || vr_qtdexec;
          
      IF vr_qtdexec = 0 THEN -- Programa não executou
              
        OPEN btch0001.cr_crapdat(vr_cdcoppar);
        FETCH btch0001.cr_crapdat  INTO rw_crapdat;
        -- Se nao encontrar
        IF BTCH0001.cr_crapdat%NOTFOUND THEN
          -- Fechar o cursor pois havera raise
          CLOSE BTCH0001.cr_crapdat;
          -- Montar mensagem de critica
           vr_cdcritic := 1;
           vr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic);
           RAISE vr_exc_erro_tratado;
        ELSE
          -- Fechar o cursor
          CLOSE BTCH0001.cr_crapdat;
        END IF;                   
            
        --Verifica o dia util da cooperativa e caso nao for pula a coop
        vr_dtmvtolt := gene0005.fn_valida_dia_util(pr_cdcooper  => vr_cdcoppar
                                                  ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                                  ,pr_tipo      => 'A');    
        -- Retorno do módulo e ação logado
        GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => vr_cdproint);        
        vr_dsparint := vr_dsparint ||
                       ', vr_dtmvtolt:' || vr_dtmvtolt ||
                       ', rw_crapdat.dtmvtolt:' || rw_crapdat.dtmvtolt ||
                       ', rw_crapdat.inproces:' || rw_crapdat.inproces;
                                                      
        IF vr_dtmvtolt = rw_crapdat.dtmvtolt THEN
          
          -- Verifica se a cadeia da cooperativa especifica terminou
          IF nvl(rw_crapdat.inproces,0) = 1 THEN          
        
            pc_processo;
            -- Retorno do módulo e ação logado
            GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => vr_cdproint);
            
          ELSE
            vr_ctreajob := vr_ctreajob + 1; -- Adiciona no Reagendamento   
            -- Log acompanhamento - Forçado Log para - Teste Belli 
            pc_controla_log_batch(pr_cdcritic => 1201
                             ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                             '. Cooperativa em processo batch' ||
                                             ' ' || vr_dsparame ||
                                             ' ' || vr_dsparint ||
                                             ', vr_qtdexec:'          || vr_qtdexec  ||
                                             ', vr_dtmvtolt:'         || vr_dtmvtolt ||
                                             ', rw_crapdat.inproces:' || rw_crapdat.inproces ||
                                             ', rw_crapdat.dtmvtolt:' || rw_crapdat.dtmvtolt
                             ,pr_dstiplog => 'O'
                             ,pr_tpocorre => 4
                             ,pr_flabrchd => 0
                             ,pr_cdcopprm => 0);           
          END IF; -- Verifica se a cadeia da cooperativa especifica terminou
        ELSE
          -- Log acompanhamento
          pc_controla_log_batch(pr_cdcritic => 1201
                               ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                               '. Data não útil para Cooperativa' ||
                                               ' ' || vr_dsparame ||
                                               ' ' || vr_dsparint ||
                                               ', vr_dtmvtolt:' || vr_dtmvtolt ||
                                               ', rw_crapdat.dtmvtolt:' || rw_crapdat.dtmvtolt
                               ,pr_dstiplog => 'O'
                               ,pr_tpocorre => 4
                               ,pr_flabrchd => 0
                               ,pr_cdcopprm => 0);                  
        END IF; -- Não é dia util 
      ELSE
        -- NULL; - Forçado comentario - Teste Belli 
        -- Log acompanhamento - Forçado Log para - Teste Belli 
        pc_controla_log_batch(pr_cdcritic => 1201
                             ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                             '. Cooperativa já executou nesta data' ||
                                             ' ' || vr_dsparame ||
                                             ' ' || vr_dsparint ||
                                             ', vr_dtmvtolt:'         || vr_dtmvtolt ||
                                             ', rw_crapdat.dtmvtolt:' || rw_crapdat.dtmvtolt
                             ,pr_dstiplog => 'O'
                             ,pr_tpocorre => 4
                             ,pr_flabrchd => 0
                             ,pr_cdcopprm => 0);   
      END IF; -- Já executou
    ELSE
      -- Log acompanhamento
      pc_controla_log_batch(pr_cdcritic => 1201
                           ,pr_dscritic => gene0001.fn_busca_critica(pr_cdcritic => 1201) ||
                                           '. Cooperativa não trabalha com transfêrencia de prejuizo' ||
                                           ' ' || vr_dsparame ||
                                           ' ' || vr_dsparint ||
                                           ', vr_permite_trans:' || vr_permite_trans 
                           ,pr_dstiplog => 'O'
                           ,pr_tpocorre => 4
                           ,pr_flabrchd => 0
                           ,pr_textochd => vr_titulo
                           ,pr_desemail => vr_destinatario_email
                           ,pr_cdcricid => 0
                           ,pr_cdcopprm => 0 );        
    END IF; -- Cooperativa não trabalha com transfêrencia de prejuizo
    
    -- Limpa ação logado
    GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => NULL);  
  EXCEPTION 
    WHEN vr_exc_erro_tratado THEN 
      RAISE vr_exc_erro_tratado; 
    WHEN vr_exc_others THEN 
      RAISE vr_exc_others; 
    WHEN OTHERS THEN   
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => 0); 
      -- Trata erro
      vr_sqlerrm := SQLERRM;
      RAISE vr_exc_others;           
  END pc_ver_exe_coop; 
  
  --                         BLOCO PRINCIPAL
  BEGIN                                      -- INICIO DO PROCESSO
    vr_cdrotcpl := vr_cdproexe ||'.' ||vr_nmrotpro;      
    -- Incluido nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => NULL);
    -- Incluida SYSDATE em variavel vr_dtsysdat para manupilar melhor quando teste - 09/10/2018 - Chd REQ0029484
    vr_dtsysdat := SYSDATE;
    vr_cdcoplog := 0;
    vr_cdcoppar := 0; 
    vr_cdcritic := NULL;
    vr_dscritic := NULL;  
    vr_dsparame := ' Nomdojob:'  || vr_nomdojob ||
                   ', cdrotcpl:' || vr_cdrotcpl ||
                   ', cdcoplog:' || vr_cdcoplog;
    -- Parte inicial do texto do chamado e do email
    vr_titulo             := '<b>Abaixo os erros encontrados no job ' || vr_nomdojob || '</b><br><br>';
    -- Buscar e-mails dos destinatarios do produto cyber
    vr_destinatario_email := gene0001.fn_param_sistema('CRED',vr_cdcoplog,'CYBER_RESPONSAVEL');
    
    -- Log de inicio de execucao sem cooperativa
    pc_controla_log_batch(pr_dstiplog => 'I'
                         ,pr_cdcopprm => 0);
      
    -- Forçado erro - Teste Belli
    --vr_cdcritic := 0 / 0;
    
    vr_dsparcop := vr_dsparame;
    FOR rw_crapcop IN cr_crapcop LOOP
      
      vr_cdcoppar := rw_crapcop.cdcooper;
      vr_dsparame := vr_dsparcop ||
                     ', vr_cdcoppar:' || vr_cdcoppar; 
      
      -- Forçado erro - Teste Belli
      --IF vr_cdcoppar > 1 THEN
      --  vr_cdcritic := 0 / 0;  
      --END IF;
      
      -- Verifica a execução da cooperativa
      pc_ver_exe_coop;
      -- Retorno nome do módulo logado
      GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => NULL);
      
    END LOOP;
    
    vr_dsparame := vr_dsparcop;
    
    -- Verifica se é necessario reagendamento
    IF vr_ctreajob > 0 THEN
      -- Reagendamento
      pc_cria_job;
      -- Retorno do módulo e ação logado
      GENE0001.pc_set_modulo(pr_module => vr_cdrotcpl, pr_action => NULL);
    END IF;
    
    -- Log de fim de execucao
    pc_controla_log_batch(pr_dstiplog => 'F'
                         ,pr_cdcopprm => 0);
    
    -- Retorno nome do módulo logado
    GENE0001.pc_set_modulo(pr_module => NULL, pr_action => NULL);
  EXCEPTION
    WHEN vr_exc_erro_tratado THEN
      IF NVL(vr_cdcritic,0) = 0 THEN
        -- Busca a primeira sequencia de numeros até o Hifen, de no maximo 5 caracteres         
        -- Se não encontrar hifen ou nenhum numero ou der algum problema permanece 0 no codigo
        BEGIN
          vr_cdcritic := 
            SUBSTR(NVL(LTRIM(TRANSLATE(SUBSTR(vr_dscritic
                                              , 1, REPLACE(INSTR(vr_dscritic, '-', 1, 1),0,1))
                                    ,TRANSLATE(SUBSTR(vr_dscritic
                                                       , 1, REPLACE(INSTR(vr_dscritic, '-', 1, 1),0,1))
                                    ,'1234567890',' '), ' ')),0),1,5); 
        EXCEPTION 
          WHEN OTHERS THEN   
            -- No caso de erro de programa gravar tabela especifica de log
            cecred.pc_internal_exception(pr_cdcooper => vr_cdcoplog); 
            vr_cdcritic := 0;
        END;           
      END IF;
      pr_cdcritic := NVL(vr_cdcritic,0);
      -- Monta mensagem
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => vr_cdcritic
                                              ,pr_dscritic => vr_dscritic) ||
                     ' '  || vr_dsparame ||
                     ' '  || vr_dsparint;                   
      -- Log de erro de execucao
      pc_controla_log_batch(pr_cdcritic => pr_cdcritic
                           ,pr_dscritic => pr_dscritic
                           ,pr_textochd => vr_titulo
                           ,pr_desemail => vr_destinatario_email
                           ,pr_cdcopprm => 0);
                            
      ROLLBACK;
    WHEN vr_exc_montada THEN                   
      -- Log de erro de execucao
      pc_controla_log_batch(pr_cdcritic => pr_cdcritic
                           ,pr_dscritic => pr_dscritic
                           ,pr_textochd => vr_titulo
                           ,pr_desemail => vr_destinatario_email
                           ,pr_cdcopprm => 0);
      
    WHEN vr_exc_others THEN     
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcoplog);
      -- Monta mensagem
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     ' '  || vr_dsparame ||
                     ' '  || vr_dsparint ||
                     '. ' || vr_sqlerrm;                   
      -- Log de erro de execucao
      pc_controla_log_batch(pr_cdcritic => pr_cdcritic
                           ,pr_dscritic => pr_dscritic
                           ,pr_textochd => vr_titulo
                           ,pr_desemail => vr_destinatario_email
                           ,pr_cdcopprm => 0);
                           
      ROLLBACK;                             
        
    WHEN OTHERS THEN     
      -- No caso de erro de programa gravar tabela especifica de log
      cecred.pc_internal_exception(pr_cdcooper => vr_cdcoplog);
      -- Monta mensagem
      pr_cdcritic := 9999;
      pr_dscritic := gene0001.fn_busca_critica(pr_cdcritic => pr_cdcritic) ||
                     ' '  || vr_dsparame ||
                     '. ' || SQLERRM;                   
      -- Log de erro de execucao
      pc_controla_log_batch(pr_cdcritic => pr_cdcritic
                           ,pr_dscritic => pr_dscritic
                           ,pr_textochd => vr_titulo
                           ,pr_desemail => vr_destinatario_email
                           ,pr_cdcopprm => 0);
                           
      ROLLBACK;                             
    
  END pc_controla_exe_job;

  
  
  
END PREJ0001;
/
