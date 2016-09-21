CREATE OR REPLACE PROCEDURE CECRED.pc_crps431 (pr_cdcooper IN crapcop.cdcooper%TYPE  --> Cooperativa solicitada
                                              ,pr_cdoperad IN VARCHAR2               --> Codigo do Operador
                                              ,pr_stprogra OUT PLS_INTEGER           --> Saída de termino da execução
                                              ,pr_infimsol OUT PLS_INTEGER           --> Saída de termino da solicitação
                                              ,pr_cdcritic OUT crapcri.cdcritic%TYPE --> Critica encontrada
                                              ,pr_dscritic OUT VARCHAR2) IS          --> Texto de erro/critica encontrada
BEGIN

  /* ............................................................................

   Programa: pc_crps431                      Antigo: Fontes/crps431.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Janeiro/2005                      Ultima atualizacao: 26/08/2014

   Dados referentes ao programa:

   Frequencia: Semanal.
   Objetivo  : Atende a solicitacao 070.
               Verificar/listar (relatorio 405) contas que tenham saldo em
               conta e que tenham valores em prejuizo.

   Alteracoes: 15/03/2005 - Nao deixar mostrar totais menores que zero (Julio).
            
               11/04/2005 - Nao usar mais o fontes/slddpv.p e sim ler a crapsld
                            para obter o saldo da c/c (Evandro).

               20/06/2005 - Alterado formulario de impressao p/ imprimir       
                            frente e verso (Diego).

               30/11/2005 - Alterado numero de copias para Viacredi,
                            glb_nrcopias = 1 (Diego).
                            
               30/01/2006 - Imprimir uma unica via para CREDIFIESC (Evandro).
               
               07/02/2006 - Colocada a "includes/var_faixas_ir.i" depois do
                            "fontes/iniprg.p" por causa da "glb_cdcooper"
                            (Evandro).

               07/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando.

               22/06/2007 - Verifica somente aplicacoes RDCA30 e RDCA60 (Elton).

               23/07/2007 - Verificar todos os tipos de aplicacoes (David).

               19/11/2007 - Substituir chamada da include aplicacao.i pela
                            BO b1wgen0004.i e rdca2s pela b1wgen0004a.i
                            (Sidnei - Precise).
                            
               02/06/2011 - Estanciado a b1wgen0004 no incio do programa e 
                            deletado no final para ganho de performance
                            (Adriano).

               06/11/2011 - Incluido a coluna PAC, e classificado por PAC e Conta
                            (Tiago).
                            
               05/03/2012 - Alteraçao para consultar saldo em cotas/capital na
                            BO21 (Lucas) .            
                            
               16/09/2013 - Tratamento para Imunidade Tributaria (Ze).      
               
               05/11/2013 - Instanciado h-b1wgen0159 fora da poupanca.i
                            (Lucas R.)
               
               07/11/2013 - Nova forma de chamar as agencias, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
                            
               24/06/2014 - Conversao Progress -> Oracle (Alisson - AMcom)
                            
               26/08/2014 - Adicionado tratamento para produtos de captação.
							              (Reinert)                
  ............................................................................. */

  DECLARE
  
    ------------------------ CONSTANTES  -------------------------------------
  
    -- Código do programa
    vr_cdprogra CONSTANT crapprg.cdprogra%TYPE:= 'CRPS431';  -- Codigo do Programa
    vr_nmarqimp CONSTANT VARCHAR2(20):= 'crrl405.lst';       -- Nome do relatório
    vr_cdagenci CONSTANT INTEGER:= 1;                        -- Codigo Agencia
    vr_cdbccxlt CONSTANT INTEGER:= 100;                      -- Codigo Banco/Caixa Lote

    ------------------------ VARIAVEIS PRINCIPAIS ----------------------------  
    -- Tratamento de erros
    vr_exc_saida  EXCEPTION;
    vr_exc_fimprg EXCEPTION;
    vr_cdcritic   PLS_INTEGER;
    vr_dscritic   VARCHAR2(4000);
  
    ------------------------------- CURSORES ---------------------------------
  
    -- Busca dos dados da cooperativa
    CURSOR cr_crapcop (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT cop.nmrescop, cop.nmextcop
        FROM crapcop cop
       WHERE cop.cdcooper = pr_cdcooper;
    rw_crapcop cr_crapcop%ROWTYPE;
    -- Cursor genérico de calendário
    rw_crapdat btch0001.cr_crapdat%ROWTYPE;
  
 
    -- Cursor para busca de associados
    CURSOR cr_crapass (pr_cdcooper crapcop.cdcooper%TYPE) IS
      SELECT crapass.nrdconta,
             crapass.inpessoa,
             crapass.cdsitdtl,
             crapass.dtelimin,
             crapass.cdagenci,
             crapass.cdsecext,
             crapass.nmprimtl
       FROM crapass crapass
       WHERE crapass.cdcooper = pr_cdcooper
       AND EXISTS (SELECT 1 
                   FROM crapepr
                   WHERE crapepr.cdcooper = crapass.cdcooper
                   AND   crapepr.nrdconta = crapass.nrdconta
                   AND   crapepr.inprejuz = 1                  
                   AND   crapepr.inliquid = 1                  
                   AND   crapepr.vlsdprej > 0)
       ORDER BY crapass.nrdconta;
    rw_crapass cr_crapass%ROWTYPE;

    -- Cursor para busca dos saldos
    CURSOR cr_crapsld (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT crapsld.nrdconta
            ,crapsld.vlsddisp
       FROM crapsld crapsld
       WHERE crapsld.cdcooper = pr_cdcooper 
       AND   nvl(crapsld.vlsddisp,0) > 0
       AND EXISTS (SELECT 1 
                   FROM crapepr
                   WHERE crapepr.cdcooper = crapsld.cdcooper
                   AND   crapepr.nrdconta = crapsld.nrdconta
                   AND   crapepr.inprejuz = 1                  
                   AND   crapepr.inliquid = 1                  
                   AND   crapepr.vlsdprej > 0);
     
    -- Selecionar Aplicacoes RDA
    CURSOR cr_craprda_conta (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT  craprda.nrdconta
      FROM craprda craprda
      WHERE craprda.cdcooper = pr_cdcooper
      AND   craprda.insaqtot = 0
      AND EXISTS (SELECT 1 
                   FROM crapepr
                   WHERE crapepr.cdcooper = craprda.cdcooper
                   AND   crapepr.nrdconta = craprda.nrdconta
                   AND   crapepr.inprejuz = 1                  
                   AND   crapepr.inliquid = 1                  
                   AND   crapepr.vlsdprej > 0);
    
    -- Selecionar Aplicacoes RDA
    CURSOR cr_craprda (pr_cdcooper IN crapcop.cdcooper%TYPE
                      ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT  /*+ INDEX (craprda craprda##craprda6) */ 
              craprda.nrdconta
             ,craprda.nraplica
             ,craprda.tpaplica
             ,craprda.vlsdrdca                
      FROM craprda craprda
      WHERE craprda.cdcooper = pr_cdcooper
      AND   craprda.nrdconta = pr_nrdconta
      AND   craprda.insaqtot = 0;
			
		-- Selecionar aplicações de captação
		CURSOR cr_craprac_conta (pr_cdcooper IN craprac.cdcooper%TYPE) IS
		  SELECT rac.nrdconta
			      ,rac.nraplica
						,rac.vlsldatl
			  FROM craprac rac
			 WHERE rac.cdcooper = pr_cdcooper
			   AND rac.idsaqtot = 0
				 AND EXISTS (SELECT 1
				               FROM crapepr epr
											WHERE epr.cdcooper = rac.cdcooper
											  AND epr.nrdconta = rac.nrdconta
												AND epr.inprejuz = 1
												AND epr.inliquid = 1
												AND epr.vlsdprej > 0);
				
		-- Selecionar Aplicações de captação								
		CURSOR cr_craprac (pr_cdcooper IN craprac.cdcooper%TYPE
		                  ,pr_nrdconta IN craprac.nrdconta%TYPE) IS
			SELECT rac.nrdconta
			      ,rac.nraplica
						,rac.vlsldatl
						,rac.cdprodut
						,rac.idblqrgt
			  FROM craprac rac
			 WHERE rac.cdcooper = pr_cdcooper
			   AND rac.nrdconta = pr_nrdconta
				 AND rac.idsaqtot = 0;
				 
      
    -- Selecionar Tipo de Aplicacao
    CURSOR cr_crapdtc (pr_cdcooper IN crapcop.cdcooper%TYPE) IS
      SELECT  crapdtc.tpaplrdc
             ,crapdtc.tpaplica                
      FROM crapdtc crapdtc
      WHERE crapdtc.cdcooper = pr_cdcooper; 

    --Selecionar as contas que possuem RPP
    CURSOR cr_craprpp_conta (pr_cdcooper IN craprpp.cdcooper%TYPE) IS
      SELECT craprpp.nrdconta
      FROM craprpp craprpp
      WHERE craprpp.cdcooper = pr_cdcooper;
             
    -- Buscar dados do cadastro de poupança programada
    CURSOR cr_craprpp(pr_cdcooper  IN crapcob.cdcooper%TYPE         --> Código da cooperativa
                     ,pr_nrdconta  IN craprpp.nrdconta%TYPE) IS     --> Número da conta
      SELECT craprpp.cdsitrpp
            ,craprpp.vlprerpp
            ,craprpp.nrctrrpp
            ,craprpp.dtmvtolt
            ,craprpp.rowid
      FROM craprpp craprpp
      WHERE craprpp.cdcooper = pr_cdcooper
      AND   craprpp.nrdconta = pr_nrdconta;
    rw_craprpp cr_craprpp%rowtype;
      
    -- Buscar Saldo dos Investimentos
    CURSOR cr_crapsli (pr_cdcooper  IN crapcob.cdcooper%TYPE         --> Código da cooperativa
                      ,pr_dtrefere  IN crapsli.dtrefere%TYPE) IS     --> Data Referencia
      SELECT crapsli.nrdconta
             ,crapsli.vlsddisp 
      FROM crapsli crapsli 
      WHERE crapsli.cdcooper = pr_cdcooper
      AND   crapsli.dtrefere = LAST_DAY(pr_dtrefere) 
      AND   nvl(crapsli.vlsddisp,0) > 0;
       
    ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    
    -- Registro para armazenar saldos da conta
    TYPE typ_reg_conta IS RECORD
      (cdagenci crapass.cdagenci%TYPE
      ,nrdconta crapass.nrdconta%TYPE
      ,nmprimtl crapass.nmprimtl%TYPE
      ,vlsconta NUMBER    /* CONTA CORRENTE   */
      ,vlsaplic NUMBER    /* APLICACOES       */
      ,vlspprog NUMBER    /* POUPANCA PROGR.  */
      ,vlscotas NUMBER    /* COTAS/CAPITAL    */
      ,vlscinve NUMBER    /* CONTA DE INVEST. */
      ,vlstotal NUMBER);  /* TOTAL            */
      
    ---------------------------- ESTRUTURAS DE TABELA ---------------------
    TYPE typ_tab_crapsld IS TABLE OF crapsld.vlsddisp%TYPE INDEX BY PLS_INTEGER;
    TYPE typ_tab_crapdtc IS TABLE OF crapdtc.tpaplrdc%TYPE INDEX BY PLS_INTEGER;
    TYPE typ_tab_craprpp IS TABLE OF INTEGER INDEX BY PLS_INTEGER;
    TYPE typ_tab_crapsli IS TABLE OF crapsli.vlsddisp%TYPE INDEX BY PLS_INTEGER;
    TYPE typ_tab_conta   IS TABLE OF typ_reg_conta INDEX BY VARCHAR2(20);

    
    vr_tab_crapsld typ_tab_crapsld;         --Armazenar Saldo da Conta
    vr_tab_crapdtc typ_tab_crapdtc;         --Armazenar Tipo de Aplicacao
    vr_tab_conta   typ_tab_conta;           --Armazenar dados para relatorio
    vr_tab_craprpp typ_tab_craprpp;         --Armazenar Saldo Poupanca Programada   
    vr_tab_crapsli typ_tab_crapsli;         --Armazenar Saldo Investimento
    vr_tab_saldo_cotas APLI0002.typ_tab_saldo_cotas; --Armazenar Saldo das Cotas
    vr_tab_craprda typ_tab_craprpp;         --Armazenar Contas com Rendimentos  
		vr_tab_craprac typ_tab_craprpp;         --Armazenar aplicações de captação
    vr_tab_erro    GENE0001.typ_tab_erro;   --Armazenar Erros da subrotina
    
    ------------------------------- VARIAVEIS -------------------------------
  
	  -- Variaveis para controle de arquivos/diretorios
    vr_nom_direto_rl     VARCHAR2(100);                 -- Diretório onde será gerado o relatório
    
	  -- Variaveis utilizadas para o relatório
    vr_clobxml    CLOB;                                 -- Clob para conter o XML de dados    
    vr_nrcopias   INTEGER;                              -- Numero Copias do Relatorio
		vr_texto_completo    VARCHAR2(32600);               -- String Completa para o CLOB
        
    --Totalizadores do Relatorio
    vr_tot_vltotcta NUMBER:= 0;
    vr_tot_vltotapl NUMBER:= 0;
    vr_tot_vltotpou NUMBER:= 0;
    vr_tot_vltotcot NUMBER:= 0;
    vr_tot_vltotinv NUMBER:= 0;
    vr_tot_vltotger NUMBER:= 0;
    
    --Indices 
    vr_index_conta VARCHAR2(20);
    
    --Variaveis Locais
    vr_dsparams  VARCHAR2(400);
    vr_dstextab  craptab.dstextab%TYPE;
    vr_percirtab craptab.dstextab%TYPE;  --> Variavel para armazenar mensagem tabela generica IR
    vr_dtinitax  DATE;
    vr_dtfimtax  DATE;
		
    vr_vlsldtot NUMBER;  --> Valor saldo total das aplicações
		vr_vlsldrgt NUMBER;  --> Valor total de resgate

    
    --------------------------- SUBROTINAS INTERNAS --------------------------
  
    -- Subrotina para limpar tabelas de Memoria
    PROCEDURE pc_limpa_tabela IS
    BEGIN
      vr_tab_crapsld.DELETE;
      vr_tab_crapdtc.DELETE;
      vr_tab_craprpp.DELETE;
      vr_tab_crapsli.DELETE;
      vr_tab_craprda.DELETE;
			vr_tab_craprac.DELETE;
      vr_tab_conta.DELETE;
      vr_tab_saldo_cotas.DELETE;
    EXCEPTION
      WHEN OTHERS THEN
        --Descricao do Erro
        vr_dscritic:= 'Erro ao limpar tabelas de Memoria. '||sqlerrm;
        --Sair
        RAISE vr_exc_saida;  
    END; 
    
    -- Subrotina para verificar os Saldos
    PROCEDURE pc_verifica_saldos (pr_cdcooper IN crapcop.cdcooper%TYPE --Codigo Cooperativa
                                 ,pr_nrdconta IN crapass.nrdconta%TYPE --Numero da Conta
                                 ,pr_cdagenci IN crapass.cdagenci%TYPE --Codigo Agencia
                                 ,pr_nmprimtl IN crapass.nmprimtl%TYPE --Nome Primeiro Titular
                                 ,pr_tab_conta IN OUT typ_tab_conta    --Tabela de Contas
                                 ,pr_dscritic OUT VARCHAR2 ) IS        --Descricao Erro
        --Variaveis Locais
        vr_vlsdrdca     NUMBER(25,8):= 0;
        vr_sldpresg     NUMBER(25,8):= 0;
        vr_vlsldapl     NUMBER(25,8):= 0;
        vr_vlrenrgt     NUMBER(25,8):= 0;
        vr_vlrdirrf     craplap.vllanmto%TYPE:= 0;
        vr_perirrgt     NUMBER(25,2):= 0;
        vr_vlrrgtot     craplap.vllanmto%TYPE:= 0;
        vr_vlirftot     craplap.vllanmto%TYPE:= 0;
        vr_vlrendmm     craplap.vlrendmm%TYPE:= 0;
        vr_vlrvtfim     craplap.vllanmto%TYPE:= 0;
        vr_vlsdrdpp     craprpp.vlsdrdpp%type:= 0;
        vr_dup_vlsdrdca NUMBER(25,8):= 0;
        vr_vldperda     NUMBER;
        vr_txaplica     NUMBER;
        vr_tot_geral    NUMBER;
        
        --Variaveis de Erro
        vr_des_erro VARCHAR2(3);
        
        --Variaveis de Excecoes
        vr_exc_erro EXCEPTION;
      BEGIN
        
        --Limpar parametros erro
        pr_dscritic:= NULL;

        --Montar Indice
        vr_index_conta:= LPAD(pr_cdagenci,10,'0')||LPAD(pr_nrdconta,10,'0');
        
        --Inserir dados tabela conta
        pr_tab_conta(vr_index_conta).cdagenci:= pr_cdagenci;
        pr_tab_conta(vr_index_conta).nrdconta:= pr_nrdconta;
        pr_tab_conta(vr_index_conta).nmprimtl:= pr_nmprimtl;
        pr_tab_conta(vr_index_conta).vlsconta:= 0;
        pr_tab_conta(vr_index_conta).vlsaplic:= 0;
        pr_tab_conta(vr_index_conta).vlspprog:= 0;
        pr_tab_conta(vr_index_conta).vlscotas:= 0;
        pr_tab_conta(vr_index_conta).vlscinve:= 0;
        pr_tab_conta(vr_index_conta).vlstotal:= 0;
                  
        --Selecionar Saldo Conta Corrente
        IF vr_tab_crapsld.EXISTS(pr_nrdconta) AND vr_tab_crapsld(pr_nrdconta) > 0 THEN
          pr_tab_conta(vr_index_conta).vlsconta:= pr_tab_conta(vr_index_conta).vlsconta + vr_tab_crapsld(pr_nrdconta);
        END IF;
          
        /* saldo em APLICACOES */
        IF vr_tab_craprda.EXISTS(pr_nrdconta) THEN
          --Selecionar rendimentos das aplicacoes
          FOR rw_craprda IN cr_craprda (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta) LOOP
             --Zerar variavel retorno
             vr_vlsdrdca:= 0;
             
             --Zerar tabela erro
             vr_tab_erro.DELETE;
             
             IF rw_craprda.tpaplica = 3 THEN 
               -- Consulta saldo aplicação RDCA30 (Antiga includes/b1wgen0004.i)
               APLI0001.pc_consul_saldo_aplic_rdca30(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do processo
                                                    ,pr_inproces => rw_crapdat.inproces --> Indicador do processo
                                                    ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> Próximo dia util
                                                    ,pr_cdprogra => vr_cdprogra         --> Programa em execução
                                                    ,pr_cdagenci => vr_cdagenci         --> Código da agência
                                                    ,pr_nrdcaixa => vr_cdbccxlt         --> Número do caixa
                                                    ,pr_nrdconta => rw_craprda.nrdconta --> Nro da conta da aplicação RDCA
                                                    ,pr_nraplica => rw_craprda.nraplica --> Nro da aplicação RDCA
                                                    ,pr_vlsdrdca => vr_vlsdrdca         --> Saldo da aplicação
                                                    ,pr_vlsldapl => vr_vlsldapl         --> Saldo da aplicação RDCA
                                                    ,pr_sldpresg => vr_sldpresg         --> Valor saldo de resgate
                                                    ,pr_dup_vlsdrdca => vr_dup_vlsdrdca --> Acumulo do saldo da aplicacao RDCA
                                                    ,pr_vldperda => vr_vldperda         --> Valor calculado da perda
                                                    ,pr_txaplica => vr_txaplica         --> Taxa aplicada sob o empréstimo
                                                    ,pr_des_reto => vr_des_erro         --> OK ou NOK
                                                    ,pr_tab_erro => vr_tab_erro);       --> Tabela com erros
               --Acumular Saldo Aplicacao
               pr_tab_conta(vr_index_conta).vlsaplic:= pr_tab_conta(vr_index_conta).vlsaplic + vr_vlsdrdca;                        
             ELSIF rw_craprda.tpaplica = 5 THEN
               -- Consulta saldo aplicação RDCA60 (Antiga includes/b1wgen0004a.i)
               APLI0001.pc_consul_saldo_aplic_rdca60(pr_cdcooper => pr_cdcooper         --> Cooperativa
                                                    ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do movto atual
                                                    ,pr_dtmvtopr => rw_crapdat.dtmvtopr --> Data do próximo movimento
                                                    ,pr_cdprogra => vr_cdprogra         --> Programa em execução
                                                    ,pr_cdagenci => vr_cdagenci         --> Código da agência
                                                    ,pr_nrdcaixa => vr_cdbccxlt         --> Número do caixa
                                                    ,pr_nrdconta => rw_craprda.nrdconta --> Nro da conta da aplicação RDCA
                                                    ,pr_nraplica => rw_craprda.nraplica --> Nro da aplicação RDCA
                                                    ,pr_vlsdrdca => vr_vlsdrdca         --> Saldo da aplicação
                                                    ,pr_sldpresg => vr_sldpresg         --> Saldo para resgate
                                                    ,pr_des_reto => vr_des_erro         --> OK ou NOK
                                                    ,pr_tab_erro => vr_tab_erro);       --> Tabela com erros
               --Acumular Saldo Aplicacao                                     
               pr_tab_conta(vr_index_conta).vlsaplic:= pr_tab_conta(vr_index_conta).vlsaplic + vr_vlsdrdca; 
             ELSE
               --Se nao Encontrar Tipo Aplicacao
               IF NOT vr_tab_crapdtc.EXISTS(rw_craprda.tpaplica) THEN
                 --Montar Erro
                 vr_cdcritic:= 346;
                 --Buscar Critica
                 vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
                 --Complementar a Critica
                 vr_dscritic:= vr_dscritic ||' Conta/dv: '||to_char(rw_craprda.nrdconta,'fm9999g999g0')||
                                             ' Nr.Aplicacao: '||to_char(rw_craprda.nraplica,'fm999g990');
                 --Escrever erro no log
                 btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(SYSDATE,
                                                              'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || vr_dscritic);
                 --Limpar erro
                 vr_cdcritic:= 0;
                 --Proximo Registro
                 CONTINUE;  
               END IF;  
               
               --Tipo Aplicacao RDC
               IF vr_tab_crapdtc(rw_craprda.tpaplica) = 1 THEN  /* RDCPRE*/
                 --Incrementar saldo aplicacao
                 pr_tab_conta(vr_index_conta).vlsaplic:= pr_tab_conta(vr_index_conta).vlsaplic + rw_craprda.vlsdrdca;
               ELSIF vr_tab_crapdtc(rw_craprda.tpaplica) = 2 THEN  /* RDCPOS*/
                 --Zerar Variaveis Retorno
                 vr_sldpresg:= 0;       
                 vr_vlrenrgt:= 0;
                 vr_vlrdirrf:= 0;       
                 vr_perirrgt:= 0;
                 vr_vlrrgtot:= 0;       
                 vr_vlirftot:= 0;
                 vr_vlrendmm:= 0;       
                 vr_vlrvtfim:= 0; 
                 --Deletar todos os erros
                 vr_tab_erro.DELETE; 
                 -- Rotina de calculo do saldo das aplicacoes RDC POS para resgate com IRPF.
                 APLI0001.pc_saldo_rgt_rdc_pos(pr_cdcooper => pr_cdcooper        --> Cooperativa
                                              ,pr_cdagenci => vr_cdagenci         --> Código da agência
                                              ,pr_nrdcaixa => vr_cdbccxlt         --> Número do caixa
                                              ,pr_nrctaapl => rw_craprda.nrdconta --> Nro da conta da aplicação RDC
                                              ,pr_nraplres => rw_craprda.nraplica --> Nro da aplicação RDC
                                              ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data do movimento atual passado
                                              ,pr_dtaplrgt => rw_crapdat.dtmvtolt --> Data do movimento atual passado
                                              ,pr_vlsdorgt => 0                   --> Valor RDC
                                              ,pr_flggrvir => FALSE               --> Identificador se deve gravar valor insento
                                              ,pr_dtinitax => vr_dtinitax         --> Data Inicial da Utilizacao da taxa da poupanca
                                              ,pr_dtfimtax => vr_dtfimtax         --> Data Final da Utilizacao da taxa da poupanca
                                              ,pr_vlsddrgt => vr_sldpresg         --> Valor do resgate total sem irrf ou o solicitado
                                              ,pr_vlrenrgt => vr_vlrenrgt         --> Rendimento total a ser pago quando resgate total
                                              ,pr_vlrdirrf => vr_vlrdirrf         --> IRRF do que foi solicitado
                                              ,pr_perirrgt => vr_perirrgt         --> Percentual de aliquota para calculo do IRRF
                                              ,pr_vlrgttot => vr_vlrrgtot         --> Resgate para zerar a aplicação
                                              ,pr_vlirftot => vr_vlirftot         --> IRRF para finalizar a aplicacao
                                              ,pr_vlrendmm => vr_vlrendmm         --> Rendimento da ultima provisao até a data do resgate
                                              ,pr_vlrvtfim => vr_vlrvtfim         --> Quantia provisao reverter para zerar a aplicação
                                              ,pr_des_reto => vr_des_erro         --> OK ou NOK
                                              ,pr_tab_erro => vr_tab_erro);       --> Tabela com erros

                 --Se retornou erro
                 IF vr_des_erro = 'NOK' THEN
                   -- Tenta buscar o erro no vetor de erro
                   IF vr_tab_erro.COUNT > 0 THEN
                     vr_cdcritic:= vr_tab_erro(vr_tab_erro.FIRST).cdcritic;
                     vr_dscritic:= vr_tab_erro(vr_tab_erro.FIRST).dscritic;
                   END IF;
                   --Complementar Informacoes na mensagem erro
                   vr_dscritic:= vr_dscritic ||' Conta/dv: '||to_char(rw_craprda.nrdconta,'fm9999g999g0')||
                                             ' Nr.Aplicacao: '||to_char(rw_craprda.nraplica,'fm999g990');
                   --Escrever Erro no Log
                   btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                   pr_ind_tipo_log => 2 -- Erro tratato
                                  ,pr_des_log      => to_char(SYSDATE,
                                                              'hh24:mi:ss') ||
                                                      ' - ' || vr_cdprogra ||
                                                      ' --> ' || vr_dscritic);
                   --Proximo registro de Aplicacao
                   CONTINUE;                                   
                 END IF;
                 --Somar Saldo a resgatar
                 IF nvl(vr_vlrrgtot,0) > 0 THEN
                   pr_tab_conta(vr_index_conta).vlsaplic:= pr_tab_conta(vr_index_conta).vlsaplic + vr_vlrrgtot;
                 ELSE
                   pr_tab_conta(vr_index_conta).vlsaplic:= pr_tab_conta(vr_index_conta).vlsaplic + rw_craprda.vlsdrdca;
                 END IF;    
               END IF;  
             END IF;      
          END LOOP;  
        END IF; --vr_tab_craprda
				
				/* Aplicação de captação */
        IF vr_tab_craprac.EXISTS(pr_nrdconta) THEN
					
				  /* Para cada registro de aplicação de captação */
				  FOR rw_craprac IN cr_craprac (pr_cdcooper => pr_cdcooper         -- Cooperativa
						                           ,pr_nrdconta => pr_nrdconta) LOOP   -- Nr. da conta
					  -- Zerar saldo					
					  vr_vlsldrgt := 0;
					
					  -- Buscar saldo da aplicação
					  apli0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper,        -- Cooperativa
																							 pr_cdoperad => '1',                -- Operador
																							 pr_nmdatela => 'pc_crps431',       -- Nome da tela
																							 pr_idorigem => 1,                  -- Origem: 1-Ayllos
																							 pr_nrdconta => pr_nrdconta,        -- Nr. da conta
																							 pr_idseqttl => 1,                  -- Id do titular
																							 pr_nraplica => rw_craprac.nraplica,-- Nr. da aplicação 
																							 pr_dtmvtolt => rw_crapdat.dtmvtolt,-- Data atual
																							 pr_cdprodut => rw_craprac.cdprodut,-- Cód. do produto
																							 pr_idblqrgt => 1,                  -- Id de bloqueio de resgate
																							 pr_idgerlog => 0,                  -- Não gerar log
																							 pr_vlsldtot => vr_vlsldtot,        -- Valor do saldo total da aplicação
																							 pr_vlsldrgt => vr_vlsldrgt,        -- Valor saldo total de resgate
																							 pr_cdcritic => vr_cdcritic,        -- Código da crítica
																							 pr_dscritic => vr_dscritic);       -- Descrição da crítica
																													 
						IF nvl(vr_vlsldrgt,0) > 0 THEN
							-- Acumular saldo
							pr_tab_conta(vr_index_conta).vlsaplic := pr_tab_conta(vr_index_conta).vlsaplic + vr_vlsldrgt;
						END IF;
						 
				  END LOOP;
																			 				
				END IF;
        /* saldo em POUPANCA PROGRAMADA */
        IF vr_tab_craprpp.EXISTS(pr_nrdconta) THEN
          -- Busca registros para poupança programada
          FOR rw_craprpp IN cr_craprpp (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta) LOOP
            --Zerar saldo
            vr_vlsdrdpp:= 0;
            -- Calcular o saldo até a data do movimento
            apli0001.pc_calc_poupanca(pr_cdcooper  => pr_cdcooper
                                     ,pr_dstextab  => vr_percirtab
                                     ,pr_cdprogra  => vr_cdprogra
                                     ,pr_inproces  => rw_crapdat.inproces
                                     ,pr_dtmvtolt  => rw_crapdat.dtmvtolt
                                     ,pr_dtmvtopr  => rw_crapdat.dtmvtopr
                                     ,pr_rpp_rowid => rw_craprpp.rowid
                                     ,pr_vlsdrdpp  => vr_vlsdrdpp
                                     ,pr_cdcritic  => vr_cdcritic
                                     ,pr_des_erro  => vr_dscritic);
            --Se Saldo Maior zero
            IF nvl(vr_vlsdrdpp,0) > 0 THEN
              --Acumular saldo
              pr_tab_conta(vr_index_conta).vlspprog:= pr_tab_conta(vr_index_conta).vlspprog + vr_vlsdrdpp;
            END IF;                           
          END LOOP;                                
        END IF; 
        
        /* saldo em COTAS/CAPITAL  */
        
        -- Obter Saldo Das Cotas do Associado
        APLI0002.pc_obtem_saldo_cotas (pr_cdcooper => pr_cdcooper               --Codigo Cooperativa
                                      ,pr_cdagenci => 0                         --Codigo Agencia
                                      ,pr_nrdcaixa => 0                         --Numero do Caixa
                                      ,pr_cdoperad => pr_cdoperad               --Codigo operador
                                      ,pr_nmdatela => vr_cdprogra               --Nome da Tela
                                      ,pr_idorigem => 1 /*Ayllos*/              --Origem da Execucao
                                      ,pr_nrdconta => pr_nrdconta               --Numero da Conta
                                      ,pr_idseqttl => 1                         --Sequencial do Titular
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt       --Data do Movimento
                                      ,pr_tab_saldo_cotas => vr_tab_saldo_cotas --Tabela de Cotas
                                      ,pr_tab_erro => vr_tab_erro               --Tabela Erros
                                      ,pr_dscritic => vr_dscritic);             --Descricao Erro
        --Se ocorreu erro
        IF vr_dscritic IS NOT NULL THEN
          --Levantar Excecao
          RAISE vr_exc_erro;
        ELSE
          --Se possui a conta no vetor
          IF vr_tab_saldo_cotas.EXISTS(pr_nrdconta) THEN
            --Acumular Saldo Cotas
            pr_tab_conta(vr_index_conta).vlscotas:= pr_tab_conta(vr_index_conta).vlscotas + vr_tab_saldo_cotas(pr_nrdconta).vlsldcap;
          END IF;  
        END IF;   
                                   
        /* saldo em CONTA DE INVESTIMENTOS */ 
        IF vr_tab_crapsli.EXISTS(pr_nrdconta) THEN
          --Acumular saldo Investimento
          pr_tab_conta(vr_index_conta).vlscinve:= pr_tab_conta(vr_index_conta).vlscinve + vr_tab_crapsli(pr_nrdconta);
        END IF;   
         
        --Somar valores para totalizador 
        vr_tot_geral:= pr_tab_conta(vr_index_conta).vlsconta +
                       pr_tab_conta(vr_index_conta).vlsaplic + 
                       pr_tab_conta(vr_index_conta).vlspprog +
                       pr_tab_conta(vr_index_conta).vlscotas +
                       pr_tab_conta(vr_index_conta).vlscinve;
           
        --Eliminar linhas em branco da tabela de memoria
        IF vr_tot_geral = 0 THEN  
          pr_tab_conta.DELETE(vr_index_conta);
        ELSE
          --Somar valores no totalizador
          pr_tab_conta(vr_index_conta).vlstotal:= vr_tot_geral;  
        END IF;
                                      
      EXCEPTION
        WHEN vr_exc_erro THEN
          pr_dscritic:= vr_dscritic;
        WHEN OTHERS THEN
          pr_dscritic:= 'Erro ao verificar saldos. '||sqlerrm;  
      END;  

  BEGIN

    --------------- VALIDACOES INICIAIS -----------------
  
    -- Incluir nome do módulo logado
    GENE0001.pc_informa_acesso(pr_module => 'PC_' || vr_cdprogra,
                               pr_action => NULL);
                               
    -- Verifica se a cooperativa esta cadastrada
    OPEN cr_crapcop (pr_cdcooper => pr_cdcooper);
    FETCH cr_crapcop INTO rw_crapcop;
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
    FETCH btch0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
    IF btch0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois efetuaremos raise
      CLOSE btch0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      RAISE vr_exc_saida;
    ELSE
      -- Apenas fechar o cursor
      CLOSE btch0001.cr_crapdat;
    END IF;
  
    -- Validações iniciais do programa
    BTCH0001.pc_valida_iniprg(pr_cdcooper => pr_cdcooper,
                              pr_flgbatch => 0,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_cdcritic => vr_cdcritic);
    -- Se a variavel de erro é <> 0
    IF vr_cdcritic <> 0 THEN
      -- Envio centralizado de log de erro
      RAISE vr_exc_saida;
    END IF;
  
    --------------- REGRA DE NEGOCIO DO PROGRAMA -----------------
  
    -- Limpar tabelas de Memoria
    pc_limpa_tabela;

    -- Carregar Contas que possuem RDA
    FOR rw_craprda IN cr_craprda_conta (pr_cdcooper => pr_cdcooper) LOOP
      vr_tab_craprda(rw_craprda.nrdconta):= 0; 
    END LOOP;
		
		-- Carregar contas que possuem aplicação de captação
		FOR rw_craprac IN cr_craprac_conta (pr_cdcooper => pr_cdcooper) LOOP
			vr_tab_craprac(rw_craprac.nrdconta) := 0; 
		END LOOP;

    -- Carregar Tabela Saldos
    FOR rw_crapsld IN cr_crapsld (pr_cdcooper => pr_cdcooper) LOOP
      vr_tab_crapsld(rw_crapsld.nrdconta):= rw_crapsld.vlsddisp; 
    END LOOP;

    -- Carregar tabela Tipo Aplicacao
    FOR rw_crapdtc IN cr_crapdtc (pr_cdcooper => pr_cdcooper) LOOP
      vr_tab_crapdtc(rw_crapdtc.tpaplica):= rw_crapdtc.tpaplrdc;
    END LOOP;  

    --Carregar tabela memoria com dados da tabela CRAPRPP
    FOR rw_craprpp IN cr_craprpp_conta (pr_cdcooper => pr_cdcooper) LOOP
      vr_tab_craprpp(rw_craprpp.nrdconta):= 0;
    END LOOP;

    --Carregar tabela memoria com Saldo Conta Investimento
    FOR rw_crapsli IN cr_crapsli (pr_cdcooper => pr_cdcooper
                                 ,pr_dtrefere => rw_crapdat.dtmvtolt) LOOP
      vr_tab_crapsli (rw_crapsli.nrdconta):= rw_crapsli.vlsddisp;
    END LOOP;

    /* Data de fim e inicio da utilizacao da taxa de poupanca.
       Utiliza-se essa data quando o rendimento da aplicacao for menor que
       a poupanca, a cooperativa opta por usar ou nao.
       Essa informacao é necessária para a rotina pc_saldo_rgt_rdc_pos */
    vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                            ,pr_nmsistem => 'CRED'
                                            ,pr_tptabela => 'USUARI'
                                            ,pr_cdempres => 11
                                            ,pr_cdacesso => 'MXRENDIPOS'
                                            ,pr_tpregist => 1);
    --Determinar as data de inicio e fim das taxas para rotina pc_saldo_rgt_rdc_pos
    vr_dtinitax := To_Date(gene0002.fn_busca_entrada(1, vr_dstextab, ';'),'DD/MM/YYYY');
    vr_dtfimtax := To_Date(gene0002.fn_busca_entrada(2, vr_dstextab, ';'),'DD/MM/YYYY');    

    --Selecionar o percentual de IR para calculo poupanca
    vr_percirtab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'CONFIG'
                                             ,pr_cdempres => 0
                                             ,pr_cdacesso => 'PERCIRAPLI'
                                             ,pr_tpregist => 0);
                                                 
    -- Busca do diretório base da cooperativa para a geração de relatórios
	  vr_nom_direto_rl:= gene0001.fn_diretorio(pr_tpdireto => 'C'           --> /usr/coop
							    									   	    ,pr_cdcooper => pr_cdcooper   --> Cooperativa
							  	   									      ,pr_nmsubdir => 'rl');        --> Utilizaremos o rl
    
		/*  Leitura dos Associados  */
    FOR rw_crapass IN cr_crapass (pr_cdcooper => pr_cdcooper) LOOP   -- Cod. Cooperativa
      --Verificar Saldos
      pc_verifica_saldos (pr_cdcooper => pr_cdcooper         --Codigo Cooperativa
                         ,pr_nrdconta => rw_crapass.nrdconta --Numero da Conta
                         ,pr_cdagenci => rw_crapass.cdagenci --Codigo Agencia
                         ,pr_nmprimtl => rw_crapass.nmprimtl --Nome Primeiro Titular
                         ,pr_tab_conta => vr_tab_conta       --Tabela de Contas
                         ,pr_dscritic  => vr_dscritic);      --Descricao Critica
      --Se ocorreu erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;                           
    END LOOP; --cr_crapass

    -- Inicializar as informações do XML de dados para o relatório
	  dbms_lob.createtemporary(vr_clobxml, TRUE, dbms_lob.CALL);
  	dbms_lob.open(vr_clobxml, dbms_lob.lob_readwrite);

    -- Inicializa o XML
    gene0002.pc_escreve_xml(vr_clobxml, vr_texto_completo,
       '<?xml version="1.0" encoding="utf-8"?><crrl405><contas>');

    --Gerar Relatorio
    vr_index_conta:= vr_tab_conta.FIRST;
    WHILE vr_index_conta IS NOT NULL LOOP

      --Acumular Totais 
      vr_tot_vltotcta:= nvl(vr_tot_vltotcta,0) + vr_tab_conta(vr_index_conta).vlsconta;
      vr_tot_vltotapl:= nvl(vr_tot_vltotapl,0) + vr_tab_conta(vr_index_conta).vlsaplic;
      vr_tot_vltotpou:= nvl(vr_tot_vltotpou,0) + vr_tab_conta(vr_index_conta).vlspprog;
      vr_tot_vltotcot:= nvl(vr_tot_vltotcot,0) + vr_tab_conta(vr_index_conta).vlscotas;
      vr_tot_vltotinv:= nvl(vr_tot_vltotinv,0) + vr_tab_conta(vr_index_conta).vlscinve;
      vr_tot_vltotger:= nvl(vr_tot_vltotger,0) + vr_tab_conta(vr_index_conta).vlstotal; 
            
      --Enviar Nulo se o valor for zero
      IF vr_tab_conta(vr_index_conta).vlsconta = 0 THEN
        vr_tab_conta(vr_index_conta).vlsconta:= NULL;
      END IF;
      IF vr_tab_conta(vr_index_conta).vlsaplic = 0 THEN
        vr_tab_conta(vr_index_conta).vlsaplic:= NULL;
      END IF;
      IF vr_tab_conta(vr_index_conta).vlspprog = 0 THEN
        vr_tab_conta(vr_index_conta).vlspprog:= NULL;
      END IF;
      IF vr_tab_conta(vr_index_conta).vlscotas = 0 THEN
        vr_tab_conta(vr_index_conta).vlscotas:= NULL;
      END IF;
      IF vr_tab_conta(vr_index_conta).vlscinve = 0 THEN
        vr_tab_conta(vr_index_conta).vlscinve:= NULL;
      END IF;
      IF vr_tab_conta(vr_index_conta).vlstotal = 0 THEN
        vr_tab_conta(vr_index_conta).vlstotal:= NULL;
      END IF;
        
      -- Escreve no relatório o dados do aviso
			gene0002.pc_escreve_xml(vr_clobxml, vr_texto_completo,
         '<conta>' ||
            '<cdagenci>' || to_char(vr_tab_conta(vr_index_conta).cdagenci,'fm990') || '</cdagenci>' ||
			      '<nrdconta>' || to_char(vr_tab_conta(vr_index_conta).nrdconta,'fm9999g999g0') || '</nrdconta>' ||
            '<nmprimtl>' || SUBSTR(vr_tab_conta(vr_index_conta).nmprimtl,1,28) || '</nmprimtl>' ||
				    '<vlsconta>' || to_char(vr_tab_conta(vr_index_conta).vlsconta,'fm999g999g990d00') || '</vlsconta>' ||
					  '<vlsaplic>' || to_char(vr_tab_conta(vr_index_conta).vlsaplic,'fm999g999g990d00') || '</vlsaplic>' ||
					  '<vlspprog>' || to_char(vr_tab_conta(vr_index_conta).vlspprog,'fm999g999g990d00') || '</vlspprog>' ||
					  '<vlscotas>' || to_char(vr_tab_conta(vr_index_conta).vlscotas,'fm999g999g990d00') || '</vlscotas>' ||
					  '<vlscinve>' || to_char(vr_tab_conta(vr_index_conta).vlscinve,'fm999g999g990d00') || '</vlscinve>' ||
            '<vlstotal>' || to_char(vr_tab_conta(vr_index_conta).vlstotal,'fm999g999g990d00') || '</vlstotal>' ||
			   '</conta>');
		  --Proximo registro
      vr_index_conta:= vr_tab_conta.NEXT(vr_index_conta);		
    END LOOP;        
    --Fechar Tag Contas e Relatorio
    gene0002.pc_escreve_xml(vr_clobxml, vr_texto_completo,'</contas></crrl405>',TRUE);
      
    --Eliminar totais Negativos
    IF vr_tot_vltotcta < 0 THEN
      vr_tot_vltotcta:= 0;
    END IF;
    IF vr_tot_vltotapl < 0 THEN
      vr_tot_vltotapl:= 0;
    END IF;
    IF vr_tot_vltotpou < 0 THEN
      vr_tot_vltotpou:= 0;
    END IF;
    IF vr_tot_vltotcot < 0 THEN
      vr_tot_vltotcot:= 0;
    END IF;
    IF vr_tot_vltotinv < 0 THEN
      vr_tot_vltotinv:= 0;
    END IF;
    IF vr_tot_vltotger < 0 THEN
      vr_tot_vltotger:= 0;
    END IF;
      
    --Colocar os totais como parametros
    vr_dsparams:= 'PR_VLTOTCTA##'||to_char(vr_tot_vltotcta,'fm999g999g990d00')||'@@'||
                  'PR_VLTOTAPL##'||to_char(vr_tot_vltotapl,'fm999g999g990d00')||'@@'||
                  'PR_VLTOTPOU##'||to_char(vr_tot_vltotpou,'fm999g999g990d00')||'@@'||
                  'PR_VLTOTCOT##'||to_char(vr_tot_vltotcot,'fm999g999g990d00')||'@@'||
                  'PR_VLTOTINV##'||to_char(vr_tot_vltotinv,'fm999g999g990d00')||'@@'||
                  'PR_VLTOTGER##'||to_char(vr_tot_vltotger,'fm999g999g990d00');
    
    --Determinar Numero Copias
    IF pr_cdcooper in (1,6) THEN
      vr_nrcopias:= 1;
    ELSE
      vr_nrcopias:= 3;
    END IF;

    -- Gera relatório 405
		gene0002.pc_solicita_relato(pr_cdcooper  => pr_cdcooper                   --> Cooperativa conectada
		 												   ,pr_cdprogra  => vr_cdprogra                   --> Programa chamador
														   ,pr_dtmvtolt  => rw_crapdat.dtmvtolt           --> Data do movimento atual
														   ,pr_dsxml     => vr_clobxml                    --> Arquivo XML de dados
														   ,pr_dsxmlnode => '/crrl405/contas/conta'       --> Nó base do XML para leitura dos dados
														   ,pr_dsjasper  => 'crrl405.jasper'              --> Arquivo de layout do iReport
														   ,pr_dsparams  => vr_dsparams                   --> Sem parâmetros
														   ,pr_dsarqsaid => vr_nom_direto_rl||'/'||vr_nmarqimp  --> Arquivo final com o path
														   ,pr_qtcoluna  => 132                           --> 132 colunas
														   ,pr_flg_gerar => 'N'                           --> Geraçao na hora
														   ,pr_flg_impri => 'S'                           --> Chamar a impressão (Imprim.p)
														   ,pr_nmformul  => '132dm'                       --> Nome do formulário para impressão
														   ,pr_nrcopias  => vr_nrcopias                   --> Número de cópias
														   ,pr_sqcabrel  => 1                             --> Qual a seq do cabrel
														   ,pr_des_erro  => vr_dscritic);                 --> Saída com erro
    --Se ocorreu erro no relatorio
    IF vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_saida;
    END IF; 
      
    --Fechar Clob e Liberar Memoria	
	  dbms_lob.close(vr_clobxml);
    dbms_lob.freetemporary(vr_clobxml);
        
    ----------------- ENCERRAMENTO DO PROGRAMA -------------------
   
    -- Limpar tabelas Memoria
    pc_limpa_tabela;

    -- Processo OK, devemos chamar a fimprg
    btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                              pr_cdprogra => vr_cdprogra,
                              pr_infimsol => pr_infimsol,
                              pr_stprogra => pr_stprogra);
															
		-- commit final
		COMMIT;
  EXCEPTION
    WHEN vr_exc_fimprg THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND
         vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Envio centralizado de log de erro
      btch0001.pc_gera_log_batch(pr_cdcooper     => pr_cdcooper,
                                 pr_ind_tipo_log => 2 -- Erro tratato
                                ,pr_des_log      => to_char(SYSDATE,
                                                            'hh24:mi:ss') ||
                                                    ' - ' || vr_cdprogra ||
                                                    ' --> ' || vr_dscritic);
      -- Chamamos a fimprg para encerrarmos o processo sem parar a cadeia
      btch0001.pc_valida_fimprg(pr_cdcooper => pr_cdcooper,
                                pr_cdprogra => vr_cdprogra,
                                pr_infimsol => pr_infimsol,
                                pr_stprogra => pr_stprogra);
      -- Efetuar COMMIT;
      COMMIT;
    WHEN vr_exc_saida THEN
      -- Se foi retornado apenas código
      IF vr_cdcritic > 0 AND
         vr_dscritic IS NULL THEN
        -- Buscar a descrição
        vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
      END IF;
      -- Devolvemos código e critica encontradas das variaveis locais
      pr_cdcritic:= NVL(vr_cdcritic, 0);
      pr_dscritic:= vr_dscritic;
      -- Efetuar rollback
      ROLLBACK;
    WHEN OTHERS THEN
      -- Efetuar retorno do erro não tratado
      pr_cdcritic:= 0;
      pr_dscritic:= SQLERRM;
      -- Efetuar rollback
      ROLLBACK;
  END;

END pc_crps431;
/

