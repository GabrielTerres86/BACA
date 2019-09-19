CREATE OR REPLACE PACKAGE CECRED.NPCB0002 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : NPCB0002
      Sistema  : Rotinas referentes a Nova Plataforma de Cobrança de Boletos
      Sigla    : NPCB
      Autor    : Renato Darosci - Supero
      Data     : Dezembro/2016.                   

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a Nova Plataforma de Cobrança de Boletos 
  ---------------------------------------------------------------------------------------------------------------*/
              
  --> Procedure para liberar sessoes apos fim do processamento
  procedure pc_libera_sessao_sqlserver_npc(pr_cdprogra_org in varchar2 default 'vazio');

  procedure pc_existe_cns_tit_npc(pr_cdcooper  in tbcobran_consulta_titulo.cdcooper%type --> Código da cooperativa
                                 ,pr_cdagenci  in tbcobran_consulta_titulo.cdagenci%type --> Código do PA
                                 ,pr_dscodbar  in tbcobran_consulta_titulo.dscodbar%type --> Código de barras
                                 --
                                 ,pr_cdctrlcs out varchar2 --> Numero do controle da consulta
                                 ,pr_dsxmltit out tbcobran_consulta_titulo.dsxml%type --> XML de retorno
                                 ,pr_tpconcip out tbcobran_consulta_titulo.tpconsulta%type --> Tipo de Consulta CIP
                                 ,pr_idloccns out varchar2 --> Indica se localizou a consulta na base Aimaro
                                 );

  --> Rotina para consultar os titulos CIP
  PROCEDURE pc_consultar_valor_titulo(pr_cdcooper       IN NUMBER       -- Cooperativa
                                     ,pr_nrdconta       IN NUMBER       -- Número da conta
                                     ,pr_cdagenci       IN NUMBER       -- Agência     
                                     ,pr_nrdcaixa       IN NUMBER       -- Número do caixa  
                                     ,pr_idseqttl       IN NUMBER       -- Titular da conta
                                     ,pr_flmobile       IN NUMBER       -- Indicador origem Mobile
                                     ,pr_titulo1        IN NUMBER       -- FORMAT "99999,99999"
                                     ,pr_titulo2        IN NUMBER       -- FORMAT "99999,999999"
                                     ,pr_titulo3        IN NUMBER       -- FORMAT "99999,999999"
                                     ,pr_titulo4        IN NUMBER       -- FORMAT "9"
                                     ,pr_titulo5        IN NUMBER       -- FORMAT "zz,zzz,zzz,zzz999"
                                     ,pr_codigo_barras  IN VARCHAR2     -- Codigo de Barras
                                     ,pr_cdoperad       IN VARCHAR2     -- Código do operador
                                     ,pr_idorigem       IN NUMBER       -- Origem da requisição
                                     ,pr_nrdocbenf     OUT NUMBER       -- Documento do beneficiário emitente
                                     ,pr_tppesbenf     OUT VARCHAR2     -- Tipo de pessoa beneficiaria
						                         ,pr_dsbenefic     OUT VARCHAR2     -- Descrição do beneficiário emitente
                                     ,pr_vlrtitulo     OUT NUMBER       -- Valor do título
                                     ,pr_vlrjuros      OUT NUMBER       -- Valor dos Juros
						                         ,pr_vlrmulta	     OUT NUMBER       -- Valor da multa
						                         ,pr_vlrdescto	   OUT NUMBER       -- Valor do desconto
						                         ,pr_cdctrlcs      OUT VARCHAR2     -- Numero do controle da consulta
 	 			  		                       ,pr_flblq_valor   OUT NUMBER	      -- Flag para bloquear o valor de pagamento
                                     ,pr_fltitven      OUT NUMBER       -- Flag indicador de titulo vencido
                                     ,pr_dtvencto      OUT VARCHAR2     -- Data de vencimento do titulo vencido                                     
	  				                         ,pr_des_erro      OUT VARCHAR2     -- Indicador erro OK/NOK
                                     ,pr_cdcritic      OUT NUMBER       -- Código do erro 
			  		                         ,pr_dscritic      OUT VARCHAR2);   -- Descricao do erro 
  
  --> Rotina para consultar os titulos CIP
  PROCEDURE pc_consultar_titulo_cip(pr_cdcooper       IN INTEGER     -- Cooperativa
                                   ,pr_nrdconta       IN NUMBER       -- Número da conta
                                   ,pr_cdagenci       IN INTEGER     -- Agência
                                   ,pr_flmobile       IN INTEGER     -- Indicador origem Mobile
					                         ,pr_dtmvtolt       IN DATE         -- Data de movimento
                                   ,pr_titulo1        IN NUMBER      -- FORMAT "99999,99999"
                                   ,pr_titulo2        IN NUMBER      -- FORMAT "99999,999999"
                                   ,pr_titulo3        IN NUMBER      -- FORMAT "99999,999999"
                                   ,pr_titulo4        IN NUMBER      -- FORMAT "9"
                                   ,pr_titulo5        IN NUMBER      -- FORMAT "zz,zzz,zzz,zzz999"
                                   ,pr_codigo_barras  IN VARCHAR2    -- Codigo de Barras
                                   ,pr_cdoperad       IN VARCHAR2    -- Código do operador
                                   ,pr_idorigem       IN NUMBER       -- Origem da requisição
                                   ,pr_flgpgdda       IN INTEGER DEFAULT 0 -- Indicador pagto DDA
                                   ,pr_nrdocbenf     OUT NUMBER      -- Documento do beneficiário emitente
                                   ,pr_tppesbenf     OUT VARCHAR2    -- Tipo de pessoa beneficiaria
						                       ,pr_dsbenefic     OUT VARCHAR2    -- Descrição do beneficiário emitente
                                   ,pr_vlrtitulo     OUT NUMBER      -- Valor do título
                                   ,pr_vlrjuros      OUT NUMBER      -- Valor dos Juros
                                   ,pr_vlrmulta      OUT NUMBER      -- Valor da multa
                                   ,pr_vlrdescto     OUT NUMBER      -- Valor do desconto
                                   ,pr_cdctrlcs      OUT VARCHAR2    -- Numero do controle da consulta
					                         ,pr_tbTituloCIP   OUT NPCB0001.typ_reg_TituloCIP  -- TAB com os dados do Boleto
						                       ,pr_flblq_valor   OUT NUMBER	     -- Flag para bloquear o valor de pagamento			
					                         ,pr_fltitven      OUT NUMBER      -- Flag indicando que o título está vencido
					                         ,pr_flcontig      OUT NUMBER       -- Flag indicando se esta a cip esta em contigencia
                                   ,pr_des_erro      OUT VARCHAR2    -- Indicador erro OK/NOK
                                   ,pr_cdcritic      OUT NUMBER      -- Código do erro 
					                         ,pr_dscritic      OUT VARCHAR2);  -- Descricao do erro

  --> Rotina para enviar titulo para CIP de forma online
  PROCEDURE pc_registra_tit_cip_online (pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                       ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Numer da conta do cooperado
                                       ,pr_cdcritic    OUT INTEGER               --> Codigo da critico
                                       ,pr_dscritic    OUT VARCHAR2              --> Descrição da critica
                                       ) ;

  --> Rotina para processar titulos que foram pagos em contigencia
  PROCEDURE pc_proc_tit_contigencia (pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                    ,pr_dtmvtolt     IN craptit.dtmvtolt%TYPE --> Numer da conta do cooperado
                                    ,pr_cdcritic    OUT INTEGER               --> Codigo da critico
                                    ,pr_dscritic    OUT VARCHAR2 );           --> Descrição da critica
                                       
  --> Validar valor dos titulos durante o periodo de convivencia
  FUNCTION fn_valid_val_conv ( pr_cdcooper IN INTEGER,
                               pr_dtmvtolt IN DATE,
                               pr_flgregis IN INTEGER,
                               pr_flgpgdiv IN INTEGER,
                               pr_vlinform IN NUMBER,
                               pr_vltitulo IN NUMBER )RETURN INTEGER;                                     
END NPCB0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.NPCB0002 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : NPCB0002
      Sistema  : Rotinas referentes a Nova Plataforma de Cobrança de Boletos
      Sigla    : NPCB
      Autor    : Renato Darosci - Supero
      Data     : Dezembro/2016.                   Ultima atualizacao: 14/11/2018

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas de transações da Nova Plataforma de Cobrança de Boletos

      Alteracoes: 17/07/2017 - Ajustes na pc_consultar_valor_titulo para retornar o nome do beneficiario
                               sem caracteres especiais que geram erro no xml(Odirlei-AMcom)

                  09/11/2017 - Inclusão de chamada da procedure pc_libera_sessao_sqlserver_npc.
                               (SD#791193 - AJFink)

                  03/01/2018 - Ajustar a chamada da fn_valid_periodo_conviv pois o 
                               periodo de convivencia será tratado por faixa de valores
                               (Douglas - Chamado 823963)
                               
                  12/04/2018 - Ajustado o cursor cr_crapage na function pc_consultar_titulo_cip,
                               inclusa clausula que validar se o municipio pertence ao mesmo 
                               estado do municipio é o mesmo da praça financeira.
                               (INC0012121 - GSaquetta)
      
                  16/10/2018 - Substituir arquivo texto por tabela oracle
                               ( Belli - Envolti - Chd INC0025460 ) 

                  14/11/2018 - Quando crítica 940 (timeout) então retornar mensagem específica.
                               (PTASK0010184 - AJFink)

  ---------------------------------------------------------------------------------------------------------------*/
  -- Declaração de variáveis/constantes gerais
  --> Declaração geral de exception
  vr_exc_erro        EXCEPTION;
                         
  procedure pc_libera_sessao_sqlserver_npc(pr_cdprogra_org in varchar2 default 'vazio') is
    /******************************************************************************
      Programa: pc_libera_sessao_sqlserver_npc
      Sistema : Cobranca - Cooperativa de Credito
      Sigla   : CRED
      Autor   : AJFink SD#791193
      Data    : Novembro/2017.                     Ultima atualizacao: 08/12/2017
      Objetivo: Libera a sessao aberta no SQLSERVER. Implementada devido ao comando
                select da funcao fn_datamov manter a sessao presa apos o fim
                do processamento. Deve ser incluída após um commit/rollback.

      Alteracoes: 08/12/2017 - Inclusão do dblink JDNPCBISQL. Tratamento de exceção
                               individualizado. Rotina deve ser chamada nos programas
                               que são utilizados com Progress devido ao WebSpeed manter
                               a sessão aberta e presa no SqlServer (SD#791193 - Ajfink)

    ******************************************************************************/
    --
    dblink_not_open exception;
    pragma exception_init(dblink_not_open,-2081);
    --
  begin
    --
    begin
      --
      execute immediate 'ALTER SESSION CLOSE DATABASE LINK JDNPCSQL';
      --
    exception
      when dblink_not_open then
        null;
      when others then
        begin
          npcb0001.pc_gera_log_npc(pr_cdcooper => 3
                                  ,pr_nmrotina => 'npcb0002.plssn JDNPCSQL('||pr_cdprogra_org||')'
                                  ,pr_dsdolog  => sqlerrm);
        exception
          when others then
            null;
        end; 
    end;
    --
    begin
      --
      execute immediate 'ALTER SESSION CLOSE DATABASE LINK JDNPCBISQL';
      --
    exception
      when dblink_not_open then
        null;
      when others then
        begin
          npcb0001.pc_gera_log_npc(pr_cdcooper => 3
                                  ,pr_nmrotina => 'npcb0002.plssn JDNPCBISQL('||pr_cdprogra_org||')'
                                  ,pr_dsdolog  => sqlerrm);
        exception
          when others then
            null;
        end; 
    end;
    --
  end pc_libera_sessao_sqlserver_npc;

  procedure pc_existe_cns_tit_npc(pr_cdcooper  in tbcobran_consulta_titulo.cdcooper%type --> Código da cooperativa
                                 ,pr_cdagenci  in tbcobran_consulta_titulo.cdagenci%type --> Código do PA
                                 ,pr_dscodbar  in tbcobran_consulta_titulo.dscodbar%type --> Código de barras
                                 --
                                 ,pr_cdctrlcs out varchar2 --> Numero do controle da consulta
                                 ,pr_dsxmltit out tbcobran_consulta_titulo.dsxml%type --> XML de retorno
                                 ,pr_tpconcip out tbcobran_consulta_titulo.tpconsulta%type --> Tipo de Consulta CIP
                                 ,pr_idloccns out varchar2 --> Indica se localizou a consulta na base Aimaro
                                 ) is
    --
    /* ..........................................................................

      Programa : pc_existe_cns_tit_npc        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : AJFink - PRB0040364
      Data     : Outubro/2018.                   Ultima atualizacao: --/--/----

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Checar a base histórica de consultas de títulos da NPC CIP,
                  se o título tenha é encontrato dentro do prazo de tempo
                  parametrizado então retornar os dados encontrados.

    ..........................................................................*/
    --
    cursor c_cns_npc(pr_cdcooper_crc tbcobran_consulta_titulo.cdcooper%type
                    ,pr_cdagenci_crc tbcobran_consulta_titulo.cdagenci%type
                    ,pr_dscodbar_crc tbcobran_consulta_titulo.dscodbar%type
                    ,pr_nrminuto_crc number) is
      select cns.cdctrlcs
            ,cns.dsxml
            ,cns.tpconsulta
      from tbcobran_consulta_titulo cns
      where cns.cdcritic = 0 --considerar somente consultas realizadas com sucesso
        and cns.nrdident <> 0 --numero de identificacao da CIP deve ser diferente de zero
        and cns.cdagenci = pr_cdagenci_crc
        and cns.cdcooper = pr_cdcooper_crc
        and cns.dhconsulta >= (sysdate-(nvl(pr_nrminuto_crc,0)/1440))
        and cns.dscodbar = pr_dscodbar_crc;
    r_cns_npc c_cns_npc%rowtype;
    --
    vr_idloccns varchar2(1) := 'N';
    vr_nrminuto number(15);
    vr_cdctrlcs tbcobran_consulta_titulo.cdctrlcs%type := null;
    vr_dsxmltit tbcobran_consulta_titulo.dsxml%type := null;
    vr_tpconcip tbcobran_consulta_titulo.tpconsulta%type := null;
    --
  begin
    --
    begin
      --
      vr_nrminuto := nvl(to_number(trim(gene0001.fn_param_sistema('CRED',0,'NPC_MIN_EXT_CNS_TIT'))),0);
      --
      --se a quantidade de minutos de validação é maior que zero então indica que devemos conferir
      --a base do Aimaro
      if vr_nrminuto > 0 then
        --
        open c_cns_npc(pr_cdcooper_crc => pr_cdcooper
                      ,pr_cdagenci_crc => pr_cdagenci
                      ,pr_dscodbar_crc => pr_dscodbar
                      ,pr_nrminuto_crc => vr_nrminuto
                      );
        fetch c_cns_npc into r_cns_npc;
        if c_cns_npc%found then
          --
          vr_idloccns := 'S';
          vr_cdctrlcs := r_cns_npc.cdctrlcs;
          vr_dsxmltit := r_cns_npc.dsxml;
          vr_tpconcip := r_cns_npc.tpconsulta;
          --
        end if;
        close c_cns_npc;
        --
      end if;
    exception
      when others then
        begin
          cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper);
          vr_idloccns := 'N';
          vr_cdctrlcs := null;
          vr_dsxmltit := null;
          vr_tpconcip := null;
        end;
    end;
    --
    pr_idloccns := vr_idloccns;
    pr_cdctrlcs := vr_cdctrlcs;
    pr_dsxmltit := vr_dsxmltit;
    pr_tpconcip := vr_tpconcip;
    --
  end pc_existe_cns_tit_npc;

  --> Rotina para consultar os titulos CIP
  PROCEDURE pc_consultar_valor_titulo(pr_cdcooper       IN NUMBER       -- Cooperativa
                                     ,pr_nrdconta       IN NUMBER       -- Número da conta
                                     ,pr_cdagenci       IN NUMBER       -- Agência     
                                     ,pr_nrdcaixa       IN NUMBER       -- Número do caixa  
                                     ,pr_idseqttl       IN NUMBER       -- Titular da conta
                                     ,pr_flmobile       IN NUMBER       -- Indicador origem Mobile
                                     ,pr_titulo1        IN NUMBER       -- FORMAT "99999,99999"
                                     ,pr_titulo2        IN NUMBER       -- FORMAT "99999,999999"
                                     ,pr_titulo3        IN NUMBER       -- FORMAT "99999,999999"
                                     ,pr_titulo4        IN NUMBER       -- FORMAT "9"
                                     ,pr_titulo5        IN NUMBER       -- FORMAT "zz,zzz,zzz,zzz999"
                                     ,pr_codigo_barras  IN VARCHAR2     -- Codigo de Barras
                                     ,pr_cdoperad       IN VARCHAR2     -- Código do operador
                                     ,pr_idorigem       IN NUMBER       -- Origem da requisição
                                     ,pr_nrdocbenf     OUT NUMBER       -- Documento do beneficiário emitente
                                     ,pr_tppesbenf     OUT VARCHAR2     -- Tipo de pessoa beneficiaria
						                         ,pr_dsbenefic     OUT VARCHAR2     -- Descrição do beneficiário emitente
                                     ,pr_vlrtitulo     OUT NUMBER       -- Valor do título
                                     ,pr_vlrjuros      OUT NUMBER       -- Valor dos Juros
						                         ,pr_vlrmulta	     OUT NUMBER       -- Valor da multa
						                         ,pr_vlrdescto	   OUT NUMBER       -- Valor do desconto
						                         ,pr_cdctrlcs      OUT VARCHAR2     -- Numero do controle da consulta
 	 			  		                       ,pr_flblq_valor   OUT NUMBER	      -- Flag para bloquear o valor de pagamento
                                     ,pr_fltitven      OUT NUMBER       -- Flag indicador de titulo vencido
                                     ,pr_dtvencto      OUT VARCHAR2     -- Data de vencimento do titulo vencido                                     
	  				                         ,pr_des_erro      OUT VARCHAR2     -- Indicador erro OK/NOK
                                     ,pr_cdcritic      OUT NUMBER       -- Código do erro 
			  		                         ,pr_dscritic      OUT VARCHAR2) IS -- Descricao do erro 
                                     
/*
Alterções:
			   29/04/2019 - RITM0011951 - SCTASK0053162 Adicionar a data de vencimento da CIP
			                no retorno do InternetBank186 (INC0033893) - Marcio (Mouts)
*/                                     
                                     
   --Selecionar informacoes cobranca
  CURSOR cr_crapcob (pr_cdcooper IN crapcob.cdcooper%TYPE
                    ,pr_nrdconta IN crapcob.nrdconta%TYPE   
                    ,pr_nrcnvcob IN crapcob.nrcnvcob%TYPE 
                    ,pr_nrdocmto IN crapcob.nrdocmto%TYPE) IS
    SELECT cob.cdcooper,
           cob.nrdconta,
           cob.vltitulo,
           cob.cdmensag,
           cob.vldescto,
           cob.vlabatim,
           cob.tpdmulta,
           cob.vlrmulta,
           cob.vljurdia,
           cob.tpjurmor,
           cob.dtvencto,
           cob.dsinform,
           cob.inpagdiv,
           decode(ass.inpessoa,1,ass.nmprimtl,jur.nmfansia) dsbenefic,
           ass.nrcpfcgc nrdocbenf,
           decode(ass.inpessoa,1,'F','J') tppesbenf,      
           ceb.flgpgdiv,
           cob.flgregis
      FROM crapcob cob
         , crapceb ceb
         , crapcco cco
         , crapass ass
         , crapjur jur
     WHERE ceb.cdcooper = pr_cdcooper
       AND ceb.nrconven = pr_nrcnvcob
       AND ceb.nrdconta = pr_nrdconta
       AND cco.cdcooper = ceb.cdcooper + 0
       AND cco.nrconven = ceb.nrconven + 0
       AND cob.cdcooper = ceb.cdcooper + 0
       AND cob.nrcnvcob = ceb.nrconven + 0
       AND cob.nrdconta = ceb.nrdconta + 0
       AND cob.nrdocmto = pr_nrdocmto
       AND cob.nrdctabb = cco.nrdctabb + 0
       AND ass.cdcooper = cob.cdcooper
       AND ass.nrdconta = cob.nrdconta
       AND jur.cdcooper (+) = ass.cdcooper
       AND jur.nrdconta (+) = ass.nrdconta;
   rw_crapcob cr_crapcob%ROWTYPE;                                     
                                    
    -- Variáveis
    rw_crapdat         BTCH0001.cr_crapdat%ROWTYPE;       
    vr_cdcritic        NUMBER;
    vr_dscritic        VARCHAR2(1000);  
    vr_des_erro        VARCHAR2(3);
    vr_tbtitulocip     NPCB0001.typ_reg_titulocip;        
    vr_nrdocbenf       NUMBER;
    vr_tppesbenf       VARCHAR2(1);
    vr_dsbenefic       VARCHAR2(100);
    vr_vlrtitulo       NUMBER;
    vr_vlrjuros        NUMBER;
    vr_vlrmulta        NUMBER;
    vr_vlrdescto       NUMBER;
    vr_vlrabatim        NUMBER;     
    vr_flgtitven       NUMBER;
    vr_cdctrlcs        VARCHAR2(50);   
    vr_flblq_valor     NUMBER;
    
    vr_nrdconta_cob    crapcob.nrdconta%TYPE := 0;
    vr_insittit        craptit.insittit%TYPE := 0;
    vr_intitcop        craptit.intitcop%TYPE := 0;
    vr_convenio        crapcob.nrcnvcob%TYPE := 0;
    vr_bloqueto        crapcob.nrdocmto%TYPE := 0;
    vr_contaconve      INTEGER := 0;

    vr_titulo1         NUMBER  := pr_titulo1; 
    vr_titulo2         NUMBER  := pr_titulo2; 
    vr_titulo3         NUMBER  := pr_titulo3; 
    vr_titulo4         NUMBER  := pr_titulo4; 
    vr_titulo5         NUMBER  := pr_titulo5;
    vr_codbarras       VARCHAR2(44) := pr_codigo_barras;       
    vr_nrdcaixa        NUMBER  := pr_nrdcaixa; 
    vr_flgpgdda        INTEGER := 0;
    vr_tab_erro        GENE0001.typ_tab_erro;
    vr_critica_data    BOOLEAN:= FALSE;
    vr_flcontig        INTEGER := 0;
    vr_flconviv        INTEGER := 0;
    
  BEGIN
               
    pr_des_erro := 'NOK';

    -- Buscar a data do sistema
    OPEN  BTCH0001.cr_crapdat(pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se nao encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Fechar o cursor pois havera raise
      CLOSE BTCH0001.cr_crapdat;
      -- Montar mensagem de critica
      vr_cdcritic := 1;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;
    
    --> verificar se veio do canal DDDA
    IF vr_nrdcaixa = 999 THEN
      vr_nrdcaixa := 900;
      vr_flgpgdda := 1;
    END IF;
    
    
    -- rw_crapdat.dtmvtolt := TRUNC(SYSDATE); -- ver renato
    -- rw_crapdat.dtmvtolt := to_date('18/05/2017','DD/MM/RRRR');

    -- Ajustar o código de barras ou a linha digitável
    NPCB0001.pc_linha_codigo_barras(pr_titulo1  => vr_titulo1  
                                   ,pr_titulo2  => vr_titulo2  
                                   ,pr_titulo3  => vr_titulo3  
                                   ,pr_titulo4  => vr_titulo4  
                                   ,pr_titulo5  => vr_titulo5  
                                   ,pr_codbarra => vr_codbarras
                                   ,pr_cdcritic => vr_cdcritic
                                   ,pr_dscritic => vr_dscritic);
     
    -- Se ocorreu erro ao configurar a linha digitável / código de barras
    IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;

    --Identificar titulo Cooperativa
    CXON0014.pc_identifica_titulo_coop2 (pr_cooper      => pr_cdcooper        --Codigo Cooperativa
                                        ,pr_nro_conta   => pr_nrdconta      --Numero Conta
                                        ,pr_idseqttl    => pr_idseqttl      --Sequencial do Titular
                                        ,pr_cod_agencia => pr_cdagenci      --Codigo da Agencia
                                        ,pr_nro_caixa   => vr_nrdcaixa      --Numero Caixa
                                        ,pr_codbarras   => vr_codbarras     --Codigo Barras
                                        ,pr_flgcritica  => TRUE             --Flag Critica
                                        ,pr_nrdconta    => vr_nrdconta_cob  --Numero da Conta OUT
                                        ,pr_insittit    => vr_insittit      --Situacao Titulo
                                        ,pr_intitcop    => vr_intitcop      --Indicador titulo cooperativa
                                        ,pr_convenio    => vr_convenio      --Numero Convenio
                                        ,pr_bloqueto    => vr_bloqueto      --Numero Boleto
                                        ,pr_contaconve  => vr_contaconve    --Conta do Convenio
                                        ,pr_cdcritic    => vr_cdcritic      --Codigo do erro
                                        ,pr_dscritic    => vr_dscritic);    --Descricao erro
    --Se Ocorreu erro
    IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
      --Levantar Excecao
      RAISE vr_exc_erro;
    END IF;
    
    IF vr_intitcop = 1 THEN /* Se for titulo da cooperativa */
    
      -- buscar o titulo para calcular valores
      OPEN cr_crapcob(pr_cdcooper => pr_cdcooper
                     ,pr_nrdconta => vr_nrdconta_cob
                     ,pr_nrcnvcob => vr_convenio
                     ,pr_nrdocmto => vr_bloqueto);
      FETCH cr_crapcob INTO rw_crapcob;
      CLOSE cr_crapcob;  
    
      /* Parametros de saida da cobranca registrada */
      vr_vlrjuros  := 0;
      vr_vlrmulta  := 0;
      vr_vlrdescto := 0;
      vr_vlrabatim := 0;
      vr_vlrtitulo := rw_crapcob.vltitulo; 

      /* trata o desconto */
      /* se concede apos o vencimento */
      IF rw_crapcob.cdmensag = 2 THEN
        --Valor Desconto
        vr_vlrdescto:= rw_crapcob.vldescto;
        --Diminuir valor desconto do Valor do titulo
        vr_vlrtitulo:= Nvl(vr_vlrtitulo,0) - vr_vlrdescto;
      END IF;
      /* utilizar o abatimento antes do calculo de juros/multa */
      IF rw_crapcob.vlabatim > 0 THEN
        --Valor Abatimento
        vr_vlrabatim:= rw_crapcob.vlabatim;
        --Diminuir valor abatimento do Valor do titulo
        vr_vlrtitulo:= Nvl(vr_vlrtitulo,0) - vr_vlrabatim;
      END IF;

      -- Limpar a tabela de erros
      vr_tab_erro.DELETE;

      --Verificar vencimento do titulo
      CXON0014.pc_verifica_vencimento_titulo (pr_cod_cooper      => pr_cdcooper          --Codigo Cooperativa
                                             ,pr_cod_agencia     => pr_cdagenci          --Codigo da Agencia
                                             ,pr_dt_agendamento  => NULL                 --Data Agendamento
                                             ,pr_dt_vencto       => rw_crapcob.dtvencto  --Data Vencimento
                                             ,pr_critica_data    => vr_critica_data      --Critica na validacao
                                             ,pr_cdcritic        => vr_cdcritic          --Codigo da Critica
                                             ,pr_dscritic        => vr_dscritic          --Descricao da Critica
                                             ,pr_tab_erro        => vr_tab_erro);        --Tabela retorno erro
      --Se ocorreu erro
      IF vr_cdcritic IS NOT NULL OR vr_dscritic IS NOT NULL THEN
        
        IF vr_tab_erro.Count > 0 THEN
          vr_dscritic:= vr_dscritic || ' ' || vr_tab_erro(vr_tab_erro.FIRST).dscritic;
        ELSIF TRIM(vr_dscritic) IS NULL THEN
          vr_dscritic:= gene0001.fn_busca_critica(vr_cdcritic);
        END IF;

        vr_dscritic:= 'Nao foi possivel verificar o vencimento do boleto. Erro: ' || vr_dscritic;              
        
        --Levantar Excecao
        RAISE vr_exc_erro;
      END IF;
        
      --Retorna se está vencido ou não        
      IF vr_critica_data = TRUE THEN
        pr_fltitven := 1;   
      ELSE
        pr_fltitven := 0;        
      END IF;

      /* verifica se o titulo esta vencido */
      IF vr_critica_data THEN

        CXON0014.pc_calcula_vlr_titulo_vencido(pr_vltitulo => vr_vlrtitulo
                                              ,pr_tpdmulta => rw_crapcob.tpdmulta
                                              ,pr_vlrmulta => rw_crapcob.vlrmulta
                                              ,pr_tpjurmor => rw_crapcob.tpjurmor
                                              ,pr_vljurdia => rw_crapcob.vljurdia
                                              ,pr_qtdiavenc => (rw_crapdat.dtmvtocd - rw_crapcob.dtvencto)
                                              ,pr_vlfatura => vr_vlrtitulo
                                              ,pr_vlrmulta_calc => vr_vlrmulta
                                              ,pr_vlrjuros_calc => vr_vlrjuros
                                              ,pr_dscritic =>  vr_dscritic);

            
      ELSE
        -- se concede apos vencto, ja calculou 
        IF rw_crapcob.cdmensag <> 2  THEN
          --Valor Desconto
          vr_vlrdescto:= rw_crapcob.vldescto;
          --Retirar o desconto do valor do titulo
          vr_vlrtitulo:= Nvl(vr_vlrtitulo,0) - vr_vlrdescto;
        END IF;
      END IF;
      
      -- Valor do titulo é o mesmo utilizado na pc_consultar_titulo_cip
      vr_flconviv := NPCB0001.fn_valid_periodo_conviv (pr_dtmvtolt => rw_crapdat.dtmvtolt
                                                      ,pr_vltitulo => TO_NUMBER(SUBSTR(gene0002.fn_mask(pr_titulo5,'99999999999999'),5,10)) / 100);
      
      -- verificar se autoriza pagto divergente
      IF rw_crapcob.inpagdiv = 0 THEN
        pr_flblq_valor := 1; -- não autorizar pagto divergente
      ELSE
        pr_flblq_valor := 0; -- permite alterar o valor a pagar do boleto
      END IF;
      
      --> Se for periodo de convivencia
      IF vr_flconviv = 1 THEN      
        --> Liberar o campo no periodo de convivencia
        pr_flblq_valor := 0;        
      END IF;
      
      pr_vlrjuros  := nvl(vr_vlrjuros,0);
      pr_vlrmulta  := nvl(vr_vlrmulta,0);
      pr_vlrdescto := nvl(vr_vlrdescto,0);      
      pr_vlrtitulo := nvl(vr_vlrtitulo,0);
      pr_nrdocbenf := rw_crapcob.nrdocbenf;
      pr_tppesbenf := rw_crapcob.tppesbenf;
      pr_dsbenefic := gene0007.fn_caract_acento(pr_texto => rw_crapcob.dsbenefic, 
                                                pr_insubsti => 1 );           
          
    ELSE  -- titulo de fora, consultar CIP      
      
      -- Chamar a rotina de consulta dos dados      
      NPCB0002.pc_consultar_titulo_cip(pr_cdcooper      => pr_cdcooper 
                                      ,pr_nrdconta      => pr_nrdconta      
                                      ,pr_cdagenci      => pr_cdagenci       
                                      ,pr_flmobile      => pr_flmobile  
                                      ,pr_dtmvtolt      => rw_crapdat.dtmvtolt
                                      ,pr_titulo1       => pr_titulo1        
                                      ,pr_titulo2       => pr_titulo2        
                                      ,pr_titulo3       => pr_titulo3        
                                      ,pr_titulo4       => pr_titulo4        
                                      ,pr_titulo5       => pr_titulo5        
                                      ,pr_codigo_barras => pr_codigo_barras  
                                      ,pr_cdoperad      => pr_cdoperad  
                                      ,pr_idorigem      => pr_idorigem    
                                      ,pr_flgpgdda      => vr_flgpgdda 
                                      ,pr_nrdocbenf     => vr_nrdocbenf
                                      ,pr_tppesbenf     => vr_tppesbenf
                                      ,pr_dsbenefic     => vr_dsbenefic      
                                      ,pr_vlrtitulo     => vr_vlrtitulo      
                                      ,pr_vlrjuros      => vr_vlrjuros       
                                      ,pr_vlrmulta      => vr_vlrmulta       
                                      ,pr_vlrdescto     => vr_vlrdescto      
                                      ,pr_cdctrlcs      => vr_cdctrlcs       
                                      ,pr_tbtitulocip   => vr_tbtitulocip    
                                      ,pr_flblq_valor   => vr_flblq_valor    
                                      ,pr_fltitven      => vr_flgtitven
                                      ,pr_flcontig      => vr_flcontig
                                      ,pr_des_erro      => vr_des_erro       
                                      ,pr_cdcritic      => vr_cdcritic       
                                      ,pr_dscritic      => vr_dscritic);     
                                           
      -- Se der erro não retorna informações   
      IF vr_des_erro = 'NOK' THEN
        -- Não retornar as informações do título  
        -- Retornar os valores consultados na CIP
        pr_nrdocbenf   := NULL;
        pr_tppesbenf   := NULL;
        pr_dsbenefic   := NULL;
        pr_vlrtitulo   := NULL;
        pr_vlrjuros    := NULL;
        pr_vlrmulta    := NULL;
        pr_fltitven    := NULL; 
        pr_vlrdescto   := NULL; 
        pr_cdctrlcs    := vr_cdctrlcs;
        pr_flblq_valor := NULL;

        -- sobrescrever a mensagem de critica de boleto nao encontrado da JDNPC        
        IF vr_cdcritic = 950 THEN
          vr_dscritic := 'Boleto nao registrado. Favor entrar em contato com o beneficiario.';
        ELSIF vr_cdcritic = 940 THEN --PTASK0010184
          vr_dscritic := 'Tempo de consulta excedido. Informe o titulo novamente.';
        END IF;
        
        -- Retornar erro 
        pr_des_erro := 'NOK';
        RAISE vr_exc_erro;
      
      -- Se não encontrou titulo na CIP e não ocorreu erro (normalmente por estar fora do rollout)
      ELSIF vr_tbtitulocip.NumCtrlPart IS NULL AND vr_flcontig = 0 THEN

        -- Busca o valor do titulo de vencimento
        CXON0014.pc_retorna_vlr_tit_vencto(pr_cdcooper      => pr_cdcooper
                                          ,pr_nrdconta      => pr_nrdconta
                                          ,pr_idseqttl      => pr_idseqttl
                                          ,pr_cdagenci      => pr_cdagenci
                                          ,pr_nrdcaixa      => vr_nrdcaixa
                                          ,pr_titulo1       => pr_titulo1
                                          ,pr_titulo2       => pr_titulo2
                                          ,pr_titulo3       => pr_titulo3
                                          ,pr_titulo4       => pr_titulo4
                                          ,pr_titulo5       => pr_titulo5
                                          ,pr_codigo_barras => pr_codigo_barras
                                          ,pr_vlfatura      => vr_vlrtitulo
                                          ,pr_vlrjuros      => vr_vlrjuros
                                          ,pr_vlrmulta      => vr_vlrmulta
                                          ,pr_fltitven      => vr_flgtitven
                                          ,pr_des_erro      => vr_des_erro
                                          ,pr_dscritic      => vr_dscritic);
        
        -- Se ocorreu erro 
        IF vr_des_erro = 'NOK' OR vr_dscritic IS NOT NULL THEN
          pr_des_erro := 'NOK';
          RAISE vr_exc_erro;
        END IF;
        
        -- Retornar as variáveis
        pr_nrdocbenf   := NULL;
        pr_tppesbenf   := NULL;
        pr_dsbenefic   := NULL;
        pr_vlrtitulo   := vr_vlrtitulo;
        pr_vlrjuros    := vr_vlrjuros;
        pr_vlrmulta    := vr_vlrmulta;
        pr_fltitven    := vr_flgtitven;
        pr_vlrdescto   := NULL;
        pr_cdctrlcs    := NULL;
        pr_flblq_valor := 0;
        
      ELSE -- Se efetuou a busca na CIP com sucesso e encontrou registro
        -- Retornar os valores consultados na CIP
        pr_nrdocbenf   := vr_nrdocbenf;
        pr_tppesbenf   := vr_tppesbenf;
        pr_dsbenefic   := gene0007.fn_caract_acento(pr_texto => vr_dsbenefic, 
                                                    pr_insubsti => 1  );
        pr_vlrtitulo   := vr_vlrtitulo;
        pr_vlrjuros    := vr_vlrjuros;
        pr_vlrmulta    := vr_vlrmulta;
        pr_vlrdescto   := vr_vlrdescto;
        pr_cdctrlcs    := vr_cdctrlcs;
        pr_flblq_valor := vr_flblq_valor;
        -- Títulos CIP poderão ser pagos vencidos, mas iremos retornar o flag para bloquear agendamento
        pr_fltitven    := vr_flgtitven; 
        
        -- Realizar as pré-validações do título
        NPCB0001.pc_valid_titulo_npc(pr_cdcooper    => pr_cdcooper
                                    ,pr_dtmvtolt    => rw_crapdat.dtmvtolt
                                    ,pr_cdctrlcs    => vr_cdctrlcs
                                    ,pr_tbtitulocip => vr_tbtitulocip
                                    ,pr_flcontig    => vr_flcontig
                                    ,pr_cdcritic    => vr_cdcritic
                                    ,pr_dscritic    => vr_dscritic);
        
        -- Se ocorreu erro 
        IF NVL(vr_cdcritic,0) > 0 OR vr_dscritic IS NOT NULL THEN
          pr_des_erro := 'NOK';
          RAISE vr_exc_erro;
        END IF;
        
      END IF;
      
    END IF; -- vr_intitcop = 1
    
    IF pr_dsbenefic IS NOT NULL THEN
      -- Truncar nome do beneficiário para ficar com mesma regra do front IB
      pr_dsbenefic := SUBSTR(pr_dsbenefic,1,15);
    END IF;
    
    pr_dtvencto:= to_char(rw_crapcob.dtvencto,'DD/MM/YYYY'); -- Márcio (Mouts)    
    
    -- Retornar o ok, informando sucesso na execução 
    pr_des_erro := 'OK';
    
  EXCEPTION 
     WHEN vr_exc_erro THEN
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
      pr_dscritic := SQLERRM;
      begin
        cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                    ,pr_compleme => 'npcb0002.pc_consultar_valor_titulo');
      exception
        when others then
          null;
      end;
      -- Efetuar rollback
      ROLLBACK;
  END pc_consultar_valor_titulo;
  
  --> Rotina para consultar os titulos CIP
  PROCEDURE pc_consultar_titulo_cip(pr_cdcooper       IN INTEGER      -- Cooperativa
					                         ,pr_nrdconta       IN NUMBER       -- Número da conta
                                   ,pr_cdagenci       IN INTEGER      -- Agência
					                         ,pr_flmobile       IN INTEGER      -- Indicador origem Mobile
					                         ,pr_dtmvtolt       IN DATE         -- Data de movimento
                                   ,pr_titulo1        IN NUMBER       -- FORMAT "99999,99999"
                                   ,pr_titulo2        IN NUMBER       -- FORMAT "99999,999999"
                                   ,pr_titulo3        IN NUMBER       -- FORMAT "99999,999999"
                                   ,pr_titulo4        IN NUMBER       -- FORMAT "9"
                                   ,pr_titulo5        IN NUMBER       -- FORMAT "zz,zzz,zzz,zzz999"
                                   ,pr_codigo_barras  IN VARCHAR2     -- Codigo de Barras
						                       ,pr_cdoperad       IN VARCHAR2     -- Código do operador
                                   ,pr_idorigem       IN NUMBER       -- Origem da requisição
                                   ,pr_flgpgdda       IN INTEGER DEFAULT 0 -- Indicador pagto DDA
                                   ,pr_nrdocbenf     OUT NUMBER       -- Documento do beneficiário emitente
                                   ,pr_tppesbenf     OUT VARCHAR2     -- Tipo de pessoa beneficiaria
						                       ,pr_dsbenefic	   OUT VARCHAR2     -- Descrição do beneficiário emitente
						                       ,pr_vlrtitulo	   OUT NUMBER	      -- Valor do título
						                       ,pr_vlrjuros	     OUT NUMBER       -- Valor dos Juros
						                       ,pr_vlrmulta	     OUT NUMBER       -- Valor da multa
						                       ,pr_vlrdescto	   OUT NUMBER       -- Valor do desconto*/
						                       ,pr_cdctrlcs      OUT VARCHAR2     -- Numero do controle da consulta
					                         ,pr_tbTituloCIP   OUT NPCB0001.typ_reg_TituloCIP  -- TAB com os dados do Boleto
						                       ,pr_flblq_valor   OUT NUMBER	      -- Flag para bloquear o valor de pagamento				
                                   ,pr_fltitven      OUT NUMBER       -- Flag indicando que o título está vencido
					                         ,pr_flcontig      OUT NUMBER       -- Flag indicando se esta a cip esta em contigencia
                                   ,pr_des_erro      OUT VARCHAR2     -- Indicador erro OK/NOK
                                   ,pr_cdcritic      OUT NUMBER       -- Código do erro 
					                         ,pr_dscritic      OUT VARCHAR2) IS -- Descricao do erro

  /* ..........................................................................
    
      Programa : pc_consultar_titulo_cip        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Renato Darosci(Supero)
      Data     : Dezembro/2016.                   Ultima atualizacao: 16/10/2018

      Dados referentes ao programa:

      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para consultar o titulo na CIP, realizar a gravação do 
                  retorno da consulta e retornar a tab com os dados recebidos

      Alteração : 

      16/10/2018 - Substituir arquivo texto por tabela oracle
                   ( Belli - Envolti - Chd INC0025460 )

      21/10/2018 - Incluir chamada da procedure pc_existe_cns_tit_npc e 
                   tratamento para a consulta que será reaproveitada.
                   (PRB0040364 - AJFink)

      22/10/2018 - Para o PA 199 (Viacredi), se o código do municipio
                   CAF retornar NULO, então atribuir 4903.
                   Isso porque no CAF é "LUIS ALVES" e no correio "LUIZ ALVES".
                   Situação repassada para a ABBC analisar.
                   (INC0023777 - AJFink)

      21/10/2018 - O campo vr_titulo5 é numérico e no caso das faturas de cartão de crédito
                   o conteúdo contém apenas zeros. Dessa forma o programa não consegue
                   processar o substr como deveria e retorna nulo. As faturas de cartão de crédito
                   que não estavam registrados na CIP deixaram de ser aceitas no dia 03/11/2018.
                   (INC0026591 - AJFink)                   

    ..........................................................................*/
    
    /****************************/
    PRAGMA AUTONOMOUS_TRANSACTION;
    /****************************/
    ----------> CURSORES <-----------   
    -- Buscar a cidade da agencia
    CURSOR cr_crapage IS
      SELECT a.cdcidade
        FROM crapcaf a
           , crapmun m
           , crapage t
       WHERE TRIM(a.nmcidade) = TRIM(m.dscidade)
         AND a.cdufresd = m.cdestado
         AND m.idcidade = t.idcidade
         AND t.cdagenci = pr_cdagenci 
         AND t.cdcooper = pr_cdcooper;
    
    --> Buscar codigo do municipio
    CURSOR cr_crapcop IS 
      SELECT a.cdcidade
        FROM crapcaf a
            ,crapcop t
       WHERE TRIM(a.nmcidade) = TRIM(t.nmcidade)
         AND t.cdcooper = pr_cdcooper;
    
    ----------> VARIAVEIS <-----------   
    vr_idrollout       INTEGER;
    vr_flbltcip        BOOLEAN := FALSE;
    vr_titulo1         NUMBER  := pr_titulo1; 
    vr_titulo2         NUMBER  := pr_titulo2; 
    vr_titulo3         NUMBER  := pr_titulo3; 
    vr_titulo4         NUMBER  := pr_titulo4; 
    vr_titulo5         NUMBER  := pr_titulo5;
    vr_codbarras       VARCHAR2(44) := pr_codigo_barras;
    vr_cdctrlcs        VARCHAR2(50);
    vr_cdcritic        NUMBER;
    vr_dscritic        VARCHAR2(1000);
    vr_cdcritic_req    NUMBER;
    vr_dscritic_req    VARCHAR2(1000);
    vr_des_erro        VARCHAR2(3);
    vr_vlboleto        NUMBER;
    vr_tpconcip        NUMBER;
    vr_xmltit          CLOB;
    vr_nrdrowid        VARCHAR2(50);
    vr_cdcidade        crapcaf.cdcidade%TYPE;
    vr_de_campo        NUMBER;
    vr_dtvencto        DATE;
    vr_idloccns        varchar2(1);
    
    -- Altera log de arquivo para oracle - 16/10/2018 - Chd INC0025460
    vr_idprglog           tbgen_prglog.idprglog%TYPE := 0;

  BEGIN   

     -- Inicializar o retorno como não-ok
     pr_des_erro := 'NOK';
     
     -- Ajustar o código de barras ou a linha digitável
     NPCB0001.pc_linha_codigo_barras(pr_titulo1  => vr_titulo1  
                                    ,pr_titulo2  => vr_titulo2  
                                    ,pr_titulo3  => vr_titulo3  
                                    ,pr_titulo4  => vr_titulo4  
                                    ,pr_titulo5  => vr_titulo5  
                                    ,pr_codbarra => vr_codbarras
                                    ,pr_cdcritic => vr_cdcritic
                                    ,pr_dscritic => vr_dscritic);
     
     -- Se ocorreu erro ao configurar a linha digitável / código de barras
     IF vr_cdcritic > 0 OR vr_dscritic IS NOT NULL THEN
       RAISE vr_exc_erro;
     END IF;
     
     -- Quando uma Instituição autorizada pelo BACEN a atuar como destinatária emissora de Boletos 
     -- de Pagamento e não foi concedido um código de compensação, as instituições devem reconhecer 
     -- o ISPB da Instituição através do detalhamento do Boleto de Pagamento contido na base assim 
     -- como a sua identificação no código de barras gerado. O ISPB deve estar contido na posição 
     -- 10 a 19 e nas três primeiras posições o valor fixo 988, na posição 04 a 04 deve estar fixo 
     -- o valor Zero, e na posição 06 à 09 devem estar preenchidos com o valor Zero. Neste cenário, 
     -- o código de barras não terá em sua composição o valor do Boleto de Pagamento, o fator de 
     -- vencimento e o código da moeda.
     -- Dessa forma verificamos se o código de barras inicia com 998 para neste caso permitir a 
     -- consulta na CIP sem validar pelo Rollout da Nova Plataforma de Cobrança
     IF SUBSTR(vr_codbarras,1,3) = 988 THEN
       vr_flbltcip := TRUE;
     ELSE 
       -- Reserva o valor do boleto
       vr_vlboleto := TO_NUMBER(SUBSTR(gene0002.fn_mask(vr_titulo5,'99999999999999'),5,10)) / 100;
     
       -- Verificar se o titulo está na faixa de rollout
       vr_idrollout := NPCB0001.fn_verifica_rollout(pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => pr_dtmvtolt
                                                   ,pr_vltitulo => vr_vlboleto
                                                   ,pr_tpdregra => 2);
                                                   
       -- Verifica se está na faixa de rollout
       IF vr_idrollout = 1 THEN
         vr_flbltcip := TRUE;
       END IF;
     END IF;
     
     -- Ver renato -- Apenas para teste.... deve ser removido
     --vr_flbltcip := TRUE;
     
     -- Se não é um titulo CIP... não realiza a consulta via WS das informações
     IF NOT vr_flbltcip AND pr_flgpgdda = 0 THEN
       -- Retornar os valores em branco indicando que está fora da faixa de rollaut
       pr_nrdocbenf   := NULL;
       pr_tppesbenf   := NULL;
       pr_dsbenefic   := NULL;
       pr_vlrtitulo   := NULL;
       pr_vlrjuros    := NULL;
       pr_vlrmulta    := NULL;
       pr_vlrdescto   := NULL;
       pr_cdctrlcs    := NULL;
       pr_flblq_valor := NULL;
       
       -- Garantir que não retorne dados tbm na collection
       pr_tbTituloCIP := NULL;
            
       -- como não consultou a CIP, parametro contingencia sera zero;
       pr_flcontig := 0;
            
       pr_des_erro := 'OK';
       
       -- Sai da rotina de consulta 
       RETURN;
     
     ELSE
       --
       --PRB0040364
       npcb0002.pc_existe_cns_tit_npc(pr_cdcooper => pr_cdcooper
                                     ,pr_cdagenci => pr_cdagenci
                                     ,pr_dscodbar => vr_codbarras
                                     --
                                     ,pr_cdctrlcs => vr_cdctrlcs
                                     ,pr_dsxmltit => vr_xmltit
                                     ,pr_tpconcip => vr_tpconcip
                                     ,pr_idloccns => vr_idloccns);
       --
       if nvl(vr_idloccns,'N') = 'S' then --PRB0040364
         -- Retornar o número de controle de consulta
         pr_cdctrlcs := vr_cdctrlcs;
         pr_flcontig := 0;
         vr_dscritic := null;
         --
       else

         -- Montar o número de controle do participante (código de controle da consulta)
         vr_cdctrlcs := NPCB0001.fn_montar_NumCtrlPart(pr_cdbarras => vr_codbarras
                                                      ,pr_cdagenci => pr_cdagenci
                                                      ,pr_flmobile => pr_flmobile);
         
         -- Retornar o número de controle de consulta
         pr_cdctrlcs := vr_cdctrlcs;
         pr_flcontig := 0;

         /* BUSCAR O CÓDIGO DO MUNICIPIO DE PAGAMENTO */
         -- Se o pagamento foi via Internet Banking ou Mobile
         IF pr_cdagenci IN (90,91) OR pr_flmobile = 1 THEN
           -- Deve buscar o municipio de residencia do cooperado
           OPEN  cr_crapcop;
           FETCH cr_crapcop INTO vr_cdcidade;
           -- Se não for encontrado registro
           IF cr_crapcop%NOTFOUND THEN
             vr_cdcidade := NULL;
           END IF;
           -- Fechar o cursor
           CLOSE cr_crapcop;
         ELSE
           -- Deve buscar a cidade da agencia
           OPEN  cr_crapage;
           FETCH cr_crapage INTO vr_cdcidade;
           -- Se não encontrou cidade
           IF cr_crapage%NOTFOUND THEN
             if pr_cdcooper = 1 and pr_cdagenci = 199 then --INC0023777
               vr_cdcidade := 4903; --LUIZ ALVES
             else
               vr_cdcidade := NULL;
             end if;
           END IF;
           -- Fechar o cursor 
           CLOSE cr_crapage;
         END IF;
         
         -- CONSULTAR O TITULO NA CIP VIA WEBSERVICE
         NPCB0003.pc_wscip_requisitar_titulo(pr_cdcooper => pr_cdcooper
                                            ,pr_cdctrlcs => vr_cdctrlcs
                                            ,pr_cdbarras => vr_codbarras
                                            ,pr_dtmvtolt => pr_dtmvtolt
                                            ,pr_cdcidade => vr_cdcidade
                                            ,pr_dsxmltit => vr_xmltit
                                            ,pr_tpconcip => vr_tpconcip
                                            ,pr_des_erro => vr_des_erro
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic);
         
         -- Se retornar o indicador de erro da rotina 
         IF vr_des_erro = 'NOK' THEN
         
           -- Gerar log para a tela ver log, quando há número de conta
           IF pr_nrdconta IS NOT NULL THEN
             
             -- Incluso rollback neste ponto, apenas para garantir que em futuras alterações não 
             -- sejam inclusas operações DML e acabem por fim comitando informações indevidas
             ROLLBACK;
             
             -- Chamar rotina generica para criação de log - LOGTEL
             GENE0001.pc_gera_log(pr_cdcooper => pr_cdcooper
                                 ,pr_cdoperad => pr_cdoperad
                                 ,pr_dscritic => vr_cdcritic||'-'||vr_dscritic
                                 ,pr_dsorigem => GENE0001.vr_vet_des_origens(pr_idorigem)
                                 ,pr_dstransa => 'Consultar titulo NPC'
                                 ,pr_dttransa => TRUNC(SYSDATE)
                                 ,pr_flgtrans => 0 -- ERRO/FALSE
                                 ,pr_hrtransa => TO_NUMBER(TO_CHAR(SYSDATE,'SSSSS'))
                                 ,pr_idseqttl => 1
                                 ,pr_nmdatela => 'NPCB0000'
                                 ,pr_nrdconta => pr_nrdconta
                                 ,pr_nrdrowid => vr_nrdrowid);
           
             -- Realiza o commit para gravar as informações da VERLOG
             COMMIT;
           
           END IF;
            
           -- Nao deve abortar pois deve gerar tabela de consulta e verificar se critica é de contigencia 
           --> RAISE vr_exc_erro;
         END IF;

       end if; --nvl(vr_idloccns,'N') = 'S'

       --> Se nao retornou critica, extrai dados do xml
       IF vr_dscritic IS NULL THEN
       
         pr_tbTituloCIP := NULL;
         -- Converter o XML retornado
         NPCB0003.pc_xmlsoap_extrair_titulo(pr_dsxmltit => vr_xmltit
                                           ,pr_tbtitulo => pr_tbTituloCIP
                                           ,pr_des_erro => vr_des_erro
                                           ,pr_dscritic => vr_dscritic);
         
         -- Se retornar o indicador de erro da rotina de extração de título
         IF vr_des_erro = 'NOK' THEN
           RAISE vr_exc_erro;
         END IF;
       ELSE
         vr_cdcritic_req := vr_cdcritic;
         vr_dscritic_req := vr_dscritic;
         --> Se retornou critica, extrais dados do codigo de barras
         pr_tbTituloCIP.NumCodBarras := vr_codbarras;
         --Retornar valor fatura
--         pr_tbTituloCIP.VlrTit := TO_NUMBER(SUBSTR(vr_titulo5,05,10));
--         pr_tbTituloCIP.VlrTit := pr_tbTituloCIP.VlrTit / 100;
         pr_tbTituloCIP.VlrTit := vr_vlboleto; --INC0026591
         --> Verificar se esta em contigencia
         IF nvl(vr_cdcritic_req,0) = 945 THEN
           pr_flcontig := 1;
           vr_de_campo := TO_NUMBER(SUBSTR(gene0002.fn_mask(vr_titulo5,'99999999999999'),1,4));
           cxon0014.pc_calcula_data_vencimento(pr_dtmvtolt => pr_dtmvtolt
                                              ,pr_de_campo => vr_de_campo
                                              ,pr_dtvencto => vr_dtvencto
                                              ,pr_cdcritic => vr_cdcritic          -- Codigo da Critica
                                              ,pr_dscritic => vr_dscritic);        -- Descricao da Critica
           pr_tbTituloCIP.DtVencTit  := vr_dtvencto;
         END IF;
       END IF;

       --realizar o insert somente quanto a consulta não veio de reaproveitamento
       if nvl(vr_idloccns,'N') = 'N' then --PRB0040364
         -- Inserir o registro consultado na tabela de registro de consulta
         BEGIN
           INSERT INTO tbcobran_consulta_titulo
             (cdctrlcs
             ,nrdident
             ,cdcooper
             ,cdagenci
             ,dtmvtolt
             ,tpconsulta
             ,dhconsulta
             ,dscodbar
             ,vltitulo
             ,nrispbds
             ,dsxml
             ,cdcanal
             ,cdoperad
             ,cdcritic
             ,flgcontingencia)
           VALUES
             (vr_cdctrlcs                 -- cdctrlcs
             ,nvl(pr_tbTituloCIP.NumIdentcTit,0) -- nrdident
             ,pr_cdcooper                 -- cdcooper
             ,pr_cdagenci                 -- cdagenci
             ,pr_dtmvtolt                 -- dtmvtolt
             ,vr_tpconcip                 -- tpconsulta
             ,SYSDATE                     -- dhconsulta
             ,pr_tbTituloCIP.NumCodBarras -- dscodbar
             ,nvl(pr_tbTituloCIP.VlrTit,0)-- vltitulo --INC0026591
             ,nvl(pr_tbTituloCIP.ISPBPartDestinatario,0) -- nrispbds
             ,nvl(vr_xmltit,' ')          -- dsxml
             ,NPCB0001.fn_canal_pag_NPC(pr_cdagenci,0)  -- cdcanal 
             ,pr_cdoperad                 -- cdoperad
             ,nvl(vr_cdcritic_req,0)      -- cdcritic
             ,pr_flcontig );              -- flgcontingencia
         EXCEPTION
           WHEN OTHERS THEN
             --> Gerar log para facilitar identificação de erros
             vr_dscritic := 'Erro ao registrar consulta CIP: '||SQLERRM;
             begin
               cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                           ,pr_compleme => 'pc_consultar_titulo_cip->cdctrlcs:'||vr_cdctrlcs);
             exception
               when others then
                 null;
             end;
             begin
               npcb0001.pc_gera_log_npc( pr_cdcooper => pr_cdcooper,
                                         pr_nmrotina => 'pc_consultar_titulo_cip', 
                                         pr_dsdolog  => 'Erro ao registrar consulta CIP -> '||
                                                        'cdctrlcs:'   ||vr_cdctrlcs ||
                                                        ',nrdident:'  ||nvl(pr_tbTituloCIP.NumIdentcTit,0) ||
                                                        ',cdcooper:'  ||pr_cdcooper                        ||
                                                        ',cdagenci:'  ||pr_cdagenci                        ||
                                                        ',dtmvtolt:'  ||pr_dtmvtolt                        ||
                                                        ',tpconsulta: '||vr_tpconcip                        || 
                                                        ',dhconsulta: '||SYSDATE                            ||
                                                        ',dscodbar:'  ||pr_tbTituloCIP.NumCodBarras          ||
                                                        ',vltitulo:'  ||pr_tbTituloCIP.VlrTit                ||
                                                        ',nrispbds:'  ||nvl(pr_tbTituloCIP.ISPBPartDestinatario,0)|| 
                                                        ',cdcanal:'   ||NPCB0001.fn_canal_pag_NPC(pr_cdagenci,0) || 
                                                        ',cdoperad:'  || pr_cdoperad                             ||
                                                        ',xmltit:'  || vr_xmltit ||
                                                        ',cdcritic:'  || nvl(vr_cdcritic_req,0)                  ||
                                                        ',flcontig:'  || pr_flcontig );                 
               
             exception
               when others then
                 null;
             end;
             raise vr_exc_erro;
         END;
       end if; --nvl(vr_idloccns,'N') = 'N'

       --> Se retornou critica de titulo nao registrao
       IF nvl(vr_cdcritic_req,0) = 950 THEN
         --> e ainda esta no periodo de convivencia
         IF NPCB0001.fn_valid_periodo_conviv (pr_dtmvtolt => pr_dtmvtolt
                                             ,pr_vltitulo => NVL(vr_vlboleto,TO_NUMBER(SUBSTR(gene0002.fn_mask(vr_titulo5,'99999999999999'),5,10)) / 100)) = 1 THEN
           --> Garantir a gravação da tabela tbcobran_consulta_titulo
           COMMIT;

           -- Altera log de arquivo para oracle - 16/10/2018 - Chd INC0025460
           BEGIN   
             -- Controlar geração de log de execução dos jobs                                
             CECRED.pc_log_programa(
                           pr_dstiplog      => 'E' -- I-início/ F-fim/ O-ocorrência/ E-erro 
                          ,pr_tpocorrencia  => 1   -- 1-Erro de negocio/ 2-Erro nao tratado/ 3-Alerta/ 4-Mensagem
                          ,pr_cdcriticidade => 0   -- 0-Baixa/ 1-Media/ 2-Alta/ 3-Critica
                          ,pr_tpexecucao    => 0   -- 0-Outro/ 1-Batch/ 2-Job/ 3-Online
                          ,pr_dsmensagem    => 'Coop: '  || pr_cdcooper ||' - '||
                                               'Codbar: '|| vr_codbarras ||' - '||
                                               'Banco: ' || SUBSTR(vr_codbarras,1,3)||' -> '||
                                               '['||vr_cdctrlcs||']: '||' 950 - Titulo não registrado na CIP, '||
                                               'porém consulta ainda esta no periodo de convivencia.' ||
                                               ' npc_conviv_'||to_char(SYSDATE,'RRRRMM')||'.log'
                          ,pr_cdmensagem    => 0
                          ,pr_cdcooper      => 3 
                          ,pr_flgsucesso    => 1
                          ,pr_flabrechamado => 0   -- Abre chamado 1 Sim/ 0 Não
                          ,pr_texto_chamado => NULL
                          ,pr_destinatario_email => NULL
                          ,pr_flreincidente => 0
                          ,pr_cdprograma    => 'NPCB0002'
                          ,pr_idprglog      => vr_idprglog
                          );                                                          
           EXCEPTION 
             WHEN OTHERS THEN
               -- No caso de erro de programa gravar tabela especifica de log  
               CECRED.pc_internal_exception (pr_cdcooper => 3
                                            ,pr_compleme => 'Coop: '  || pr_cdcooper ||' - '||
                                                            'Codbar: '|| vr_codbarras ||' - '||
                                                            'Banco: ' || SUBSTR(vr_codbarras,1,3)||' -> '||
                                                            '['||vr_cdctrlcs||']: '||' 950 - Titulo não registrado na CIP, '||
                                                            'porém consulta ainda esta no periodo de convivencia.' ||
                                                            ' npc_conviv_'||to_char(SYSDATE,'RRRRMM')||'.log'
                                            );      
           END;                        
           
           --> limpar variaveis/parametro
           vr_cdctrlcs    := NULL;
           pr_cdctrlcs    := NULL;
           pr_tbTituloCIP := NULL;
           pr_des_erro    := 'OK';
           
           --> Garantir a gravação da tabela tbcobran_consulta_titulo
           COMMIT;
           --> Sair da procedure sem validação e sem numero de controle de consulta
           --> para que a rotina trate o titulo como fora do rollout npc
           RETURN;
         
         END IF;       
       END IF;
       
       
       --> Se possuir critica e se não é contigencia
       IF (nvl(vr_cdcritic_req,0) > 0 OR trim(vr_dscritic_req) IS NOT NULL) AND pr_flcontig = 0 THEN
         --> Garantir a gravação da tabela tbcobran_consulta_titulo
         COMMIT;
         vr_cdcritic := vr_cdcritic_req;
         vr_dscritic := vr_dscritic_req;

         RAISE vr_exc_erro;       
       END IF;       
       
       -- Realizar as pré-validações do boleto
       NPCB0001.pc_valid_titulo_npc(pr_cdcooper    => pr_cdcooper
                                   ,pr_dtmvtolt    => pr_dtmvtolt
                                   ,pr_cdctrlcs    => vr_cdctrlcs
                                   ,pr_tbtitulocip => pr_tbTituloCIP
                                   ,pr_flcontig    => pr_flcontig
                                   ,pr_cdcritic    => vr_cdcritic
                                   ,pr_dscritic    => vr_dscritic );
       
       -- Se retornar erro
       IF vr_dscritic IS NOT NULL THEN
         -- Se encontrou critica na validação deve gravar a consulta da mesma 
         -- forma, sendo assim, é realizado o commit para que o rollback não 
         -- limpe as informações
         COMMIT;  -- ATENÇÃO:  A REMOÇÃO DESDE COMMIT CAUSARÁ ERROS NA TELA 
                  --           DE PAGAMENTO.
       
         RAISE vr_exc_erro;
       END IF;
       
       -- Retornar o doc do beneficiário
       pr_nrdocbenf := TRIM(pr_tbTituloCIP.CNPJ_CPFBenfcrioOr);   -- Documento do Beneficiário Original
       
       -- Retornar o tipo da pessoa do beneficiário
       pr_tppesbenf := TRIM(pr_tbTituloCIP.TpPessoaBenfcrioOr);   -- Tipo Pessoa do Beneficiário Original
       
       -- Retornar o nome do beneficiário
       pr_dsbenefic := gene0007.fn_caract_acento( NVL(TRIM(pr_tbTituloCIP.NomFantsBenfcrioOr)   -- Nome Fantasia do Beneficiário Original
                          ,TRIM(pr_tbTituloCIP.Nom_RzSocBenfcrioOr)));-- Razão Social do Beneficiário Original
       
       
       -- Definir os valores do título
       NPCB0001.pc_valor_calc_titulo_npc(pr_dtmvtolt  => pr_dtmvtolt
                                        ,pr_tbtitulo  => pr_tbTituloCIP
                                        ,pr_vlrtitulo => pr_vlrtitulo   -- Retornar valor do título
                                        ,pr_vlrjuros  => pr_vlrjuros    -- Retornar valor dos juros
                                        ,pr_vlrmulta  => pr_vlrmulta    -- Retornar valor da multa
                                        ,pr_vlrdescto => pr_vlrdescto); -- Retornar valor de desconto
         
         --> Se valor estiver diferente retornar critica
       IF pr_vlrtitulo IS NULL THEN
         -- Se encontrou critica na validação deve gravar a consulta da mesma 
         -- forma, sendo assim, é realizado o commit para que o rollback não 
         -- limpe as informações
         COMMIT;
         
         vr_dscritic := 'Problemas ao buscar valor do titulo.';
         RAISE vr_exc_erro;
       END IF;
         
       -- Se não permitir pagamento parcial e não permitir valor divergente (3-Não aceitar pagamento com o valor divergente)
       IF pr_tbTituloCIP.IndrPgtoParcl = 'N' AND pr_tbTituloCIP.TpAutcRecbtVlrDivgte = '3' THEN         
         IF pr_vlrtitulo = 0 THEN
           vr_dscritic := 'Valor do titulo não está de acordo com o autorização de pagamento divergente, favor entrar em contato com o Beneficiario.';
           -- Se encontrou critica na validação deve gravar a consulta da mesma 
           -- forma, sendo assim, é realizado o commit para que o rollback não 
           -- limpe as informações
           COMMIT;
           RAISE vr_exc_erro;         
         END IF;
       
         -- Indicar que não deve permitir alteração do valor do pagamento
         pr_flblq_valor := 1;
       ELSE 
         -- Indicar que deve permitir alteração do valor do pagamento para que o mesmo possa ser informado
         pr_flblq_valor := 0;
       END IF;
       
       -- Verifica se o título está vencidos
       IF pr_dtmvtolt > pr_tbTituloCIP.DtVencTit THEN
         -- Indicar que o título está vencido
         pr_fltitven := 1;
       ELSE
         -- Indicar que o título NÃO está vencido
         pr_fltitven := 0;
       END IF;
     END IF;
     
     pr_des_erro := 'OK';
     
     -- Encerrar com commit devido a rotina pragma
     COMMIT;
  
  EXCEPTION 
     WHEN vr_exc_erro THEN
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
      pr_dscritic := SQLERRM;
      begin
        cecred.pc_internal_exception(pr_cdcooper => pr_cdcooper
                                    ,pr_compleme => 'npcb0002.pc_consultar_titulo_cip');
      exception
        when others then
          null;
      end;
      -- Efetuar rollback
      ROLLBACK;
  END pc_consultar_titulo_cip;
  
  --> Rotina para enviar titulo para CIP de forma online
  PROCEDURE pc_registra_tit_cip_online (pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                       ,pr_nrdconta     IN crapass.nrdconta%TYPE --> Numer da conta do cooperado
                                       ,pr_cdcritic    OUT INTEGER               --> Codigo da critico
                                       ,pr_dscritic    OUT VARCHAR2              --> Descrição da critica
                                       ) IS
  /* ..........................................................................
    
      Programa : pc_registra_tit_cip_online        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Janeiro/2017.                   Ultima atualizacao: 24/01/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para enviar titulo para CIP de forma online
      Alteração : 18/05/2018 - Devido a um problema com a transação na b1wnet0001.p
                               e InternetBank4.p foi ajustado para o job iniciar 10 segundos
                               após a inclusão do título. Para garantir que a transação tenha
                               encerrado e o título esteja visível em outra sessão. (INC0013085-AJFink)
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    ----------> VARIAVEIS <-----------
    vr_dscritic       VARCHAR2(4000);
    vr_cdcritic       INTEGER;
    vr_exc_erro       EXCEPTION;
    
    vr_dsplsql        VARCHAR2(10000);
    vr_jobname        VARCHAR2(100);
    
    
    
  BEGIN    
    
    
    vr_jobname := 'JB618_'||pr_nrdconta||'$';
    vr_dsplsql := 
'declare
  vr_cdcritic integer; 
  vr_dscritic varchar2(400);
begin
  pc_crps618(pr_cdcooper   => '||pr_cdcooper||
           ',pr_nrdconta  => '||pr_nrdconta||
           ',pr_cdcritic  => vr_cdcritic '||
           ',pr_dscritic  => vr_dscritic );
  commit;
  npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => ''NPCB0002_JB618'');
exception
  when others then
    rollback;
    npcb0002.pc_libera_sessao_sqlserver_npc(pr_cdprogra_org => ''NPCB0002_JB618'');
    raise;
end;';
    
    gene0001.pc_submit_job(pr_cdcooper => pr_cdcooper, 
                           pr_cdprogra => 'NPCB0002', 
                           pr_dsplsql  => vr_dsplsql, 
                           pr_dthrexe  => to_timestamp_tz(to_char(CAST(current_timestamp AT TIME ZONE 'AMERICA/SAO_PAULO' AS timestamp)+(10/86400),'ddmmyyyyhh24miss')||' AMERICA/SAO_PAULO','ddmmyyyyhh24miss TZR'),
                           pr_interva  => NULL, 
                           pr_jobname  => vr_jobname, 
                           pr_des_erro => vr_dscritic );
                           
    IF vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro;
    END IF;
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Nao foi possivel enviar titulo cip online: '||SQLERRM; 
  END pc_registra_tit_cip_online;

  
  --> Rotina para processar titulos que foram pagos em contigencia
  PROCEDURE pc_proc_tit_contigencia (pr_cdcooper     IN crapcop.cdcooper%TYPE --> Codigo da cooperativa
                                    ,pr_dtmvtolt     IN craptit.dtmvtolt%TYPE --> Numer da conta do cooperado
                                    ,pr_cdcritic    OUT INTEGER               --> Codigo da critico
                                    ,pr_dscritic    OUT VARCHAR2              --> Descrição da critica
                                       ) IS
  /* ..........................................................................
    
      Programa : pc_proc_tit_contigencia        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(AMcom)
      Data     : Agosto/2017.                   Ultima atualizacao: 
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para processar titulos que foram pagos em contigencia
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    CURSOR cr_craptit IS 
      SELECT tit.cdcooper,
             tit.nrdconta,
             tit.cdagenci,
             tit.vldpagto,
             tit.dtmvtolt,
             tit.dscodbar,
             tit.cdoperad,
             tit.intitcop,
             tit.nrdident,
             tit.rowid,
             tit.flgpgdda      
      
        FROM craptit tit
       WHERE tit.cdcooper = decode(pr_cdcooper,0,tit.cdcooper,pr_cdcooper)
         AND tit.dtmvtolt = pr_dtmvtolt
         --> Titulos gerados em contigencia
         AND tit.flgconti = 1
         --> que ainda não foi enviado a baixa operacional
         AND TRIM(tit.cdctrbxo) IS NULL;
         
    
    ----------> VARIAVEIS <-----------
    vr_dscritic       VARCHAR2(4000);
    vr_cdcritic       INTEGER;
    vr_exc_erro       EXCEPTION;    
    vr_des_erro        VARCHAR2(3);
    
    vr_tbtitulocip     NPCB0001.typ_reg_titulocip;        
    vr_nrdocbenf       NUMBER;
    vr_tppesbenf       VARCHAR2(1);
    vr_dsbenefic       VARCHAR2(100);
    vr_vltitulo        NUMBER;
    vr_vlrjuros        NUMBER;
    vr_vlrmulta        NUMBER;
    vr_vlrdescto       NUMBER;
    vr_fltitven        NUMBER;
    vr_cdctrlcs        VARCHAR2(50);   
    vr_flblq_valor     NUMBER;
    vr_flcontig        INTEGER;
    vr_nridetit        NUMBER;
    vr_tpdbaixa        INTEGER;
    vr_cdsittit        INTEGER;
    
  BEGIN   
   
    --> Buscar titulos pagos em contigencia
    FOR rw_craptit IN cr_craptit LOOP
    
      --> Rotina para consultar os titulos CIP
      pc_consultar_titulo_cip ( pr_cdcooper       => rw_craptit.cdcooper    -- Cooperativa
                               ,pr_nrdconta       => rw_craptit.nrdconta  -- Número da conta
                               ,pr_cdagenci       => rw_craptit.cdagenci  -- Agência
                               ,pr_flmobile       => 0                    -- Indicador origem Mobile
                               ,pr_dtmvtolt       => rw_craptit.dtmvtolt  -- Data de movimento
                               ,pr_titulo1        => NULL                 -- FORMAT "99999,99999"
                               ,pr_titulo2        => NULL                 -- FORMAT "99999,999999"
                               ,pr_titulo3        => NULL                 -- FORMAT "99999,999999"
                               ,pr_titulo4        => NULL                 -- FORMAT "9"
                               ,pr_titulo5        => NULL                 -- FORMAT "zz,zzz,zzz,zzz999"
                               ,pr_codigo_barras  => rw_craptit.dscodbar  -- Codigo de Barras
                               ,pr_cdoperad       => rw_craptit.cdoperad  -- Código do operador
                               ,pr_idorigem       => 7                    -- Origem da requisição
                               ,pr_flgpgdda       => rw_craptit.flgpgdda  -- Indicador pagto DDA
                               ,pr_nrdocbenf      => vr_nrdocbenf         -- Documento do beneficiário emitente
                               ,pr_tppesbenf      => vr_tppesbenf         -- Tipo de pessoa beneficiaria
                               ,pr_dsbenefic      => vr_dsbenefic         -- Descrição do beneficiário emitente
                               ,pr_vlrtitulo      => vr_vltitulo          -- Valor do título
                               ,pr_vlrjuros       => vr_vlrjuros          -- Valor dos Juros
                               ,pr_vlrmulta       => vr_vlrmulta          -- Valor da multa
                               ,pr_vlrdescto      => vr_vlrdescto         -- Valor do desconto*/
                               ,pr_cdctrlcs       => vr_cdctrlcs          -- Numero do controle da consulta
                               ,pr_tbTituloCIP    => vr_tbTituloCIP       -- TAB com os dados do Boleto
                               ,pr_flblq_valor    => vr_flblq_valor       -- Flag para bloquear o valor de pagamento        
                               ,pr_fltitven       => vr_fltitven          -- Flag indicando que o título está vencido
                               ,pr_flcontig       => vr_flcontig          -- Flag indicando se esta a cip esta em contigencia
                               ,pr_des_erro       => vr_des_erro          -- Indicador erro OK/NOK
                               ,pr_cdcritic       => vr_cdcritic          -- Código do erro 
                               ,pr_dscritic       => vr_dscritic );       -- Descricao do erro
    
      -- Se ainda estiver em contigencia
      IF vr_flcontig = 1 THEN
        NPCB0001.pc_gera_log_npc(pr_cdcooper => rw_craptit.cdcooper, 
                               pr_nmrotina => 'pc_proc_tit_contigencia', 
                               pr_dsdolog  => '['||vr_cdctrlcs||']: '||' Processo ainda em contigencia.');
        
        --> Deve sair do programa
        EXIT;
      END IF;
    
      -- Se der erro não retorna informações   
      IF vr_des_erro = 'NOK' THEN              
        
        NPCB0001.pc_gera_log_npc(pr_cdcooper => rw_craptit.cdcooper, 
                                 pr_nmrotina => 'pc_proc_tit_contigencia', 
                                 pr_dsdolog  => '['||vr_cdctrlcs||']: '||vr_dscritic);
      
        vr_dscritic := NULL;
        vr_cdcritic := 0;
        continue; 
      END IF;
      
      --> Validação do pagamento do boleto na Nova plataforma de cobrança 
      NPCB0001.pc_valid_pagamento_npc 
                        ( pr_cdcooper  => rw_craptit.cdcooper --> Codigo da cooperativa
                         ,pr_dtmvtolt  => rw_craptit.dtmvtolt --> Data de movimento                                   
                         ,pr_cdctrlcs  => vr_cdctrlcs         --> Numero de controle da consulta no NPC
                         ,pr_dtagenda  => NULL                --> Data de agendamento
                         ,pr_vldpagto  => rw_craptit.vldpagto  --> Valor a ser pago
                         ,pr_vltitulo  => vr_vltitulo         --> Valor do titulo
                         ,pr_nridenti  => vr_nridetit         --> Retornar numero de identificacao do titulo no npc
                         ,pr_tpdbaixa  => vr_tpdbaixa         --> Retornar tipo de baixa
                         ,pr_flcontig  => vr_flcontig         --> Retornar inf que a CIP esta em modo de contigencia
                         ,pr_cdcritic  => vr_cdcritic         --> Codigo da critico
                         ,pr_dscritic  => vr_dscritic );      --> Descrição da critica
                           
      --> Verificar se retornou critica                             
      IF nvl(vr_cdcritic,0) <> 0 OR
         TRIM(vr_dscritic) IS NOT NULL THEN
         
        NPCB0001.pc_gera_log_npc(pr_cdcooper => rw_craptit.cdcooper, 
                                 pr_nmrotina => 'pc_proc_tit_contigencia', 
                                 pr_dsdolog  => '['||vr_cdctrlcs||']: '||vr_dscritic); 
        vr_dscritic := NULL;
        vr_cdcritic := 0;
        continue;
      END IF;
      
      --> Atualizar dados do titulo
      BEGIN
        UPDATE craptit 
           SET cdctrlcs = nvl(vr_cdctrlcs,' ')          
              ,nrdident = nvl(vr_nridetit,0)            
              ,nrispbds = nvl(vr_tbTituloCIP.ISPBPartDestinatario,0)      
              ,tpbxoper = nvl(vr_tpdbaixa,0)                  
         WHERE craptit.rowid = rw_craptit.rowid;
      EXCEPTION
        WHEN OTHERS THEN  
          vr_dscritic := 'Não foi possivel atualizar craptit: '||SQLERRM;
          NPCB0001.pc_gera_log_npc(pr_cdcooper => rw_craptit.cdcooper, 
                                 pr_nmrotina => 'pc_proc_tit_contigencia', 
                                 pr_dsdolog  => '['||vr_cdctrlcs||']: '||vr_dscritic); 
          vr_dscritic := NULL;
          continue;
      END;
      
      ------->>>>>>> ENVIAR BAIXA OPERACIONAL <<<<<<<-------
      
      --Determinar situacao titulo
      IF rw_craptit.intitcop = 1 THEN
        vr_cdsittit:= 3;  /* Pg.IntraBanc. */
      ELSE
        vr_cdsittit:= 4; /* Pg.InterBanc. */
      END IF;     
      
 
      
      --Executar Baixa Operacional
      NPCB0003.pc_wscip_requisitar_baixa(pr_cdcooper => rw_craptit.cdcooper  --> Codigo da cooperativa
                                        ,pr_dtmvtolt => rw_craptit.dtmvtolt  --> Data de movimento
                                        ,pr_dscodbar => rw_craptit.dscodbar  --> Codigo de barra
                                        ,pr_cdctrlcs => vr_cdctrlcs  --> Identificador da consulta
                                        ,pr_idtitdda => vr_nridetit  --> Identificador Titulo DDA
                                        ,pr_tituloCIP => vr_tbTituloCIP 
                                        ,pr_flmobile => 0
                                        --,pr_xml_frag => vr_xml --Documento XML referente ao fragmento do XML de resposta do SOAP
                                        ,pr_des_erro => vr_des_erro --Indicador erro OK/NOK
                                        ,pr_dscritic => vr_dscritic); --Descricao erro
      IF vr_des_erro = 'NOK' THEN      
        vr_dscritic := 'Não foi possivel requisitar baixa em contingencia: ' || vr_dscritic;
        NPCB0001.pc_gera_log_npc(pr_cdcooper => rw_craptit.cdcooper, 
                                 pr_nmrotina => 'pc_proc_tit_contigencia', 
                                 pr_dsdolog  => '['||vr_cdctrlcs||']: '||vr_dscritic); 
        vr_dscritic := NULL;
        continue;
      END IF;
      
      --> Depois de enviar a baixa operacional para cip é necessario realizar commit
      COMMIT;
    
    END LOOP;
    
    
  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
      
    WHEN OTHERS THEN
      pr_cdcritic := 0;
      pr_dscritic := 'Nao foi possivel enviar titulo em contigencia cip: '||SQLERRM; 
  END pc_proc_tit_contigencia;
  
  
  FUNCTION fn_valid_val_conv ( pr_cdcooper IN INTEGER,
                               pr_dtmvtolt IN DATE,
                               pr_flgregis IN INTEGER,
                               pr_flgpgdiv IN INTEGER,
                               pr_vlinform IN NUMBER,
                               pr_vltitulo IN NUMBER )RETURN INTEGER IS
  /* ..........................................................................
    
      Programa : fn_valid_val_conv        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(AMcom)
      Data     : Setembro/2017.                   Ultima atualizacao: 12/01/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para validar valor dos titulos no periodo de convivencia
      Alteração : 03/01/2018 - Ajustar a chamada da fn_valid_periodo_conviv pois o 
                               periodo de convivencia será tratado por faixa de valores
                               (Douglas - Chamado 823963)
        
                  12/01/2018 - Ajuste para validar o valor do titulo e o valor informado
                               utilizando ROUND na comparação (Douglas - Chamado 817561)
    ..........................................................................*/
  
    vr_flconviv  INTEGER;
    vr_idrollout INTEGER;
  BEGIN
    vr_flconviv := NPCB0001.fn_valid_periodo_conviv (pr_dtmvtolt => pr_dtmvtolt
                                                    ,pr_vltitulo => pr_vltitulo);
      
    IF vr_flconviv = 1 THEN
    
      -- Verificar se o titulo está na faixa de rollout
      vr_idrollout := NPCB0001.fn_verifica_rollout( pr_cdcooper => pr_cdcooper
                                                   ,pr_dtmvtolt => pr_dtmvtolt
                                                   ,pr_vltitulo => pr_vltitulo
                                                   ,pr_tpdregra => 2);
    
      IF pr_flgregis = 0 THEN
        --> se estiver no rollout e valor informado for menor que valor do titulo
        IF vr_idrollout = 1 AND ROUND(pr_vlinform, 2) < ROUND(pr_vltitulo, 2) THEN
          RETURN 0; -- Nao permitir        
        ELSE
          -- se nao estiver no rollout ou valor nao for menor
          RETURN 1; -- permitir        
        END IF;
      --> Convenio com registro
      ELSE
        IF pr_flgpgdiv = 0 THEN
           -- Se o valor informado for menor que valor do titulo
           IF ROUND(pr_vlinform, 2) < ROUND(pr_vltitulo, 2) THEN
             RETURN 0; -- Nao permitir     
           ELSE
             -- se nao estiver no rollout ou valor nao for menor
             RETURN 1; -- permitir 
           END IF;  
        END IF;
      END IF;
    END IF;
    
    RETURN 3; -- nao valida esta situação 
  
  END;

END NPCB0002;
/
