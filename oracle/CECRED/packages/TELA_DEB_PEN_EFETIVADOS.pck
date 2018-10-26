CREATE OR REPLACE PACKAGE CECRED.TELA_DEB_PEN_EFETIVADOS IS
---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_DEB_PEN_EFETIVADOS
  --  Sistema  : DEBITADOR UNICO
  --  Sigla    : DEB
  --  Autor    : Elton (AMcom)
  --  Data     : Abril/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações usadas na tela de consulta de debitos pendentes e efetivados (DEBITO)
  --
  -- Alterado:
  --
  ---------------------------------------------------------------------------------------------------------------



--------------------- INICIO HORARIOS -----------------------

PROCEDURE pc_busca_debitos(           pr_tipoexec IN INTEGER                      --> 1 - pendente/ 2 -efetivado
                                    , pr_cdcooper  IN crapcop.cdcooper%TYPE       --> Código da coopertiva
                                    , pr_cdagenci IN crapass.cdagenci%TYPE        --> Código da agencia
                                    , pr_ds_cdprocesso IN VARCHAR2                --> programas debitador, separados por virgula
                                    , pr_nrdconta IN crapass.nrdconta%TYPE        --> Conta
                                    , pr_dtmvtolt IN VARCHAR2                         --> Data do movimento
                                    , pr_pagina   IN NUMBER                       --> Nr da Pagina                                    
                                    , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                    , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                    , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                    , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                    , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                    , pr_des_erro OUT VARCHAR2);
                                    

PROCEDURE pc_busca_deb_pendentes(     pr_cdcooper  IN crapcop.cdcooper%TYPE       --> Código da coopertiva
                                    , pr_cdagenci IN crapass.cdagenci%TYPE        --> Código da agencia
                                    , pr_ds_cdprocesso IN VARCHAR2                --> programas debitador, separados por virgula
                                    , pr_nrdconta IN crapass.nrdconta%TYPE        --> Conta
                                    , pr_dtmvtolt IN VARCHAR2                     --> Data do movimento
                                    , pr_pagina   IN NUMBER                       --> Nr da Pagina                                    
                                    , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                    , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                    , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                    , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                    , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                    , pr_des_erro OUT VARCHAR2);                                    
                                    

PROCEDURE pc_busca_deb_efetivados(   pr_cdcooper  IN crapcop.cdcooper%TYPE       --> Código da coopertiva
                                    , pr_cdagenci IN crapass.cdagenci%TYPE        --> Código da agencia
                                    , pr_nrdconta IN crapass.nrdconta%TYPE        --> Conta
                                    , pr_dtmvtolt IN VARCHAR2                         --> Data do movimento
                                    , pr_pagina   IN NUMBER                       --> Nr da Pagina                                    
                                    , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                    , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                    , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                    , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                    , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                    , pr_des_erro OUT VARCHAR2);

                                    
PROCEDURE pc_busca_progra_debitador(     pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       , pr_des_erro OUT VARCHAR2);			                                    

PROCEDURE pc_busca_pa_conta(  pr_cdcooper IN crapcop.cdcooper%TYPE      --> Código da coopertiva
                            , pr_nrdconta IN crapass.nrdconta%TYPE      --> Conta
                            , pr_xmllog   IN VARCHAR2                   --> XML com informações de LOG
                            , pr_cdcritic OUT PLS_INTEGER               --> Código da crítica
                            , pr_dscritic OUT VARCHAR2                  --> Descrição da crítica
                            , pr_retxml   IN OUT NOCOPY XMLType         --> Arquivo de retorno do XML
                            , pr_nmdcampo OUT VARCHAR2                  --> Nome do campo com erro
                            , pr_des_erro OUT VARCHAR2);
                            
PROCEDURE pc_valida_pa     (  pr_cdcooper IN crapcop.cdcooper%TYPE      --> Código da coopertiva
                            , pr_cdagenci IN crapass.cdagenci%TYPE      --> Código da agencia
                            , pr_xmllog   IN VARCHAR2                   --> XML com informações de LOG
                            , pr_cdcritic OUT PLS_INTEGER               --> Código da crítica
                            , pr_dscritic OUT VARCHAR2                  --> Descrição da crítica
                            , pr_retxml   IN OUT NOCOPY XMLType         --> Arquivo de retorno do XML
                            , pr_nmdcampo OUT VARCHAR2                  --> Nome do campo com erro
                            , pr_des_erro OUT VARCHAR2);                            


END TELA_DEB_PEN_EFETIVADOS;
/
CREATE OR REPLACE PACKAGE BODY CECRED.TELA_DEB_PEN_EFETIVADOS IS
  ---------------------------------------------------------------------------------------------------------------
  --
  --  Programa : TELA_DEB_PEN_EFETIVADOS
  --  Sistema  : DEBITADOR UNICO
  --  Sigla    : DEB
  --  Autor    : Elton (AMcom)
  --  Data     : Abril/2018.
  --
  -- Frequencia: -----
  -- Objetivo  : Procedimentos para retorno das informações usadas na tela de consulta de debitos pendentes e efetivados
  --
  -- Alterado:
  --
  --             06/08/2018 - PJ450 - TRatamento do nao pode debitar, crítica de negócio, 
  --                          após chamada da rotina de geraçao de lançamento em CONTA CORRENTE.
  --                          Alteração específica neste programa acrescentando o tratamento para a origem
  --                          BLQPREJU
  --                          (Renato Cordeiro - AMcom)
  ---------------------------------------------------------------------------------------------------------------


PROCEDURE pc_busca_debitos(        pr_tipoexec IN INTEGER                      --> 1 - pendente/ 2 -efetivado
                                    , pr_cdcooper  IN crapcop.cdcooper%TYPE       --> Código da coopertiva
                                    , pr_cdagenci IN crapass.cdagenci%TYPE        --> Código da agencia
                                    , pr_ds_cdprocesso IN VARCHAR2                --> programas debitador, separados por virgula
                                    , pr_nrdconta IN crapass.nrdconta%TYPE        --> Conta
                                    , pr_dtmvtolt IN VARCHAR2                         --> Data do movimento
                                    , pr_pagina   IN NUMBER                       --> Nr da Pagina                                    
                                    , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                    , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                    , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                    , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                    , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                    , pr_des_erro OUT VARCHAR2) IS
BEGIN

    /* ............................................................................
        Programa: pc_busca_debitador_progra
        Sistema : CECRED
        Sigla   : DEB
        Autor   : Elton (AMCOM)
        Data    : Abril/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para buscar débitos pendentes e efetivados
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;
	
BEGIN

    pr_des_erro := 'OK';
    
    IF pr_tipoexec = 1 THEN -- Pendentes
        pc_busca_deb_pendentes(   pr_cdcooper      =>  pr_cdcooper       
                                , pr_cdagenci      =>  pr_cdagenci     
                                , pr_ds_cdprocesso =>  pr_ds_cdprocesso
                                , pr_nrdconta	     =>  pr_nrdconta	 
                                , pr_dtmvtolt 	   =>  pr_dtmvtolt
                                , pr_pagina   	   =>  pr_pagina   	 
                                , pr_xmllog  	     =>  pr_xmllog  	 
                                , pr_cdcritic 	   =>  pr_cdcritic 	 
                                , pr_dscritic      =>  pr_dscritic     
                                , pr_retxml   	   =>  pr_retxml   	 
                                , pr_nmdcampo 	   =>  pr_nmdcampo 	 
                                , pr_des_erro 	   =>  pr_des_erro 	); 

          -- Se retornou alguma crítica
        IF TRIM(pr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;
    ELSIF pr_tipoexec = 2 THEN -- Efetivados

       pc_busca_deb_efetivados(   pr_cdcooper      =>  pr_cdcooper       
                                , pr_cdagenci      =>  pr_cdagenci     
                                , pr_nrdconta	     =>  pr_nrdconta	 
                                , pr_dtmvtolt 	   =>  pr_dtmvtolt 	 	
                                , pr_pagina   	   =>  pr_pagina   	 
                                , pr_xmllog  	     =>  pr_xmllog  	 
                                , pr_cdcritic 	   =>  pr_cdcritic 	 
                                , pr_dscritic      =>  pr_dscritic     
                                , pr_retxml   	   =>  pr_retxml   	 
                                , pr_nmdcampo 	   =>  pr_nmdcampo 	 
                                , pr_des_erro 	   =>  pr_des_erro 	); 

         -- Se retornou alguma crítica
        IF TRIM(pr_dscritic) IS NOT NULL THEN
            -- Levanta exceção
            RAISE vr_exc_saida;
        END IF;      
    
    END IF;


    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_debitos: ' ||pr_dscritic;
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_debitos: ' || SQLERRM;

    END;
END pc_busca_debitos;


PROCEDURE pc_busca_deb_pendentes(     pr_cdcooper  IN crapcop.cdcooper%TYPE       --> Código da coopertiva
                                    , pr_cdagenci IN crapass.cdagenci%TYPE        --> Código da agencia
                                    , pr_ds_cdprocesso IN VARCHAR2                --> programas debitador, separados por virgula
                                    , pr_nrdconta IN crapass.nrdconta%TYPE        --> Conta
                                    , pr_dtmvtolt IN VARCHAR2                     --> Data do movimento
                                    , pr_pagina   IN NUMBER                       --> Nr da Pagina                                    
                                    , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                    , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                    , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                    , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                    , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                    , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_busca_debitos
        Sistema : CECRED
        Sigla   : DEB
        Autor   : Elton (AMcom)
        Data    : Abril/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para buscar dados dos débitos pendentes
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

        -- Variaveis auxiliares
   -- vr_auxconta    INTEGER :=0; -- Contador auxiliar p/ posicao no XML
    vr_RegTotal    INTEGER :=0;
    vr_nrlinhas    INTEGER :=15;
    vr_auxinicial  INTEGER :=0;
    vr_auxfinal    INTEGER :=0 ;
    vr_dtmvtolt    DATE;

    vr_ds_cdprocesso_ant   tbgen_debitador_horario_proc.cdprocesso%TYPE;
    vr_dsprocReduzido      tbgen_debitador_param.dsprocesso%type;
    vr_dsprocesso          tbgen_debitador_param.dsprocesso%type;
    
         
    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis gerais da procedure
    vr_contcont INTEGER := 0; -- Contador para inserção dos dados no XML
    vr_contador INTEGER := 0;
    
    --- variaveis negocio
    vr_dtmovini craplau.dtmvtopg%TYPE;
   
    vr_dtprdebi crapseg.dtdebito%type;    
    vr_dtmvante DATE;                        --> Data anterior, usada para pegar fatura uam qtd x de dias

    vr_data_aux DATE;
    
    vr_qtddiapg   INTEGER;                   --> Qtd de dias corridos que vai tentar debitar a fatura por meio de repique
    vr_dsconteu   VARCHAR(100);              --> Auxiliar para retornar da funcao de busca de parametro
    vr_proxhorario VARCHAR(5);
      -- Tratamento de erros
	    vr_des_erro   VARCHAR2(4000);
      vr_tab_erro   GENE0001.typ_tab_erro; 

 ---------------------------- ESTRUTURAS DE REGISTRO ---------------------
    -- Definicao do tipo da tabela para linhas de credito
    TYPE typ_reg_craplcr IS
     RECORD(dsoperac craplcr.dsoperac%TYPE,
            perjurmo craplcr.perjurmo%TYPE,
            flgcobmu craplcr.flgcobmu%TYPE);	
    TYPE typ_tab_craplcr IS
      TABLE OF typ_reg_craplcr
        INDEX BY PLS_INTEGER; -- Codigo da Linha
    -- Vetor para armazenar os dados de Linha de Credito
    vr_tab_craplcr typ_tab_craplcr;
    

    ----------->>> CURSORES <<<--------

  -- Busca os dados da linha de credito, para crps724
    CURSOR cr_craplcr(pr_cdcooper IN craplcr.cdcooper%TYPE) IS
      SELECT cdlcremp
            ,dsoperac
            ,perjurmo
            ,flgcobmu
        FROM craplcr
       WHERE cdcooper = pr_cdcooper
         AND tpprodut = 2;
         
 -- Busca historico, para crps724
    CURSOR cr_craphis(pr_cdcooper IN craplcr.cdcooper%TYPE, pr_cdhistor in craphis.cdhistor%TYPE ) IS
      SELECT craphis.cdhistor||'-'||craphis.dshistor dshist
        FROM craphis
       WHERE cdcooper = pr_cdcooper
         AND cdhistor = pr_cdhistor;        
         
    -- Dados do programa (processos)
  CURSOR cr_nome_Programa(pr_cdprocesso tbgen_debitador_horario_proc.cdprocesso%TYPE) IS         
  SELECT    substr(p.dsprocesso,1,20) dsprocReduzido
          , p.dsprocesso
         FROM TBGEN_DEBITADOR_PARAM p
        WHERE p.cdprocesso = pr_cdprocesso;

-- BUSCA PROXIMO HORÁRIO DE PROCESSAMENTO DO PROGRAMA NO DEBITADOR
  CURSOR cr_horario_processo(pr_cdprocesso tbgen_debitador_horario_proc.cdprocesso%TYPE) IS         
  SELECT  MAX(to_char(hr.dhprocessamento,'HH24:MI')) dhprocessamento 
      FROM tbgen_debitador_horario_proc hp
         , tbgen_debitador_horario hr
     WHERE hp.cdprocesso = pr_cdprocesso
       AND hr.idhora_processamento = hp.idhora_processamento
       AND  to_char(hr.dhprocessamento,'HH24MI') >  to_char(SYSDATE,'HH24MI')
       AND ROWNUM =1;    

    -- -- não encontrou no dia atual, pois não existe execução do programa depois desta hora, então executa esse cursor.
    CURSOR cr_horario_processo_prox_dia(pr_cdprocesso tbgen_debitador_horario_proc.cdprocesso%TYPE) IS 
    SELECT  to_char(hr.dhprocessamento,'HH24:MI') dhprocessamento 
      FROM tbgen_debitador_horario_proc hp
         , tbgen_debitador_horario hr
     WHERE hp.cdprocesso = pr_cdprocesso
       AND hr.idhora_processamento = hp.idhora_processamento
       AND ROWNUM =1;       

    
   -- dados de debitos pendentes
   -- querys de cada programa de debito que consta no debitador
     CURSOR cr_debitos IS
    -- crps172 - DEBITO EM CONTA DAS PRESTACOES DE PLANO DE CAPITAL - crappla - pendentes
    select * from (
    select  coope
           ,agencia
           ,conta
           ,gene0007.fn_acento_xml(associado) associado
           ,vlrlancamento
           ,to_char(dtmvto,'DD/MM/YYYY') dtmvto
           ,gene0007.fn_acento_xml(historico) historico
           ,cdprocesso
           ,auxcdlcremp
           --data, agencia, conta
           ,ROW_NUMBER() OVER (ORDER BY dtmvto desc,conta) Row_Num
    from (
    select
           pla.cdcooper coope,
           ass.cdagenci agencia,
           pla.nrdconta conta,
           ass.nmprimtl associado,
           pla.vlprepla vlrlancamento,
           pla.dtmvtolt dtmvto,
           his.cdhistor||'-'||his.dshistor historico,
           'PC_CRPS172' cdprocesso
           , 0 auxcdlcremp
    from crapass ass,
         crapsld sld,
         crapcot cot,
         crappla pla,
         craphis his
    where pla.cdcooper = pr_cdcooper
      and pla.nrdconta > 1 --pr_nrctares
      and pla.tpdplano = 1
      and pla.cdsitpla = 1
      and pla.flgpagto = 0
      and pla.indpagto = 0
      and pla.dtdpagto <= vr_dtmvtolt
      and pla.qtprepag <= pla.qtpremax
      and cot.cdcooper (+) = pla.cdcooper
      and cot.nrdconta (+) = pla.nrdconta
      and sld.cdcooper (+) = pla.cdcooper
      and sld.nrdconta (+) = pla.nrdconta
      and ass.cdcooper     = pla.cdcooper
      and ass.nrdconta     = pla.nrdconta
      and ass.cdagenci     = pr_cdagenci      
      and ass.nrdconta     = nvl(pr_nrdconta,ass.nrdconta)      
      and pla.cdcooper     = his.cdcooper
      and his.cdhistor     = 127 -- DB. COTAS
      and InStr(pr_ds_cdprocesso,'PC_CRPS172'||',') > 0 
  union
   --DEBNET - crps509_PRIORI - programa de convenios próprios - CECRED, mas somente agua e luz
      SELECT DISTINCT
             craplau.cdcooper coope
            ,crapass.CDAGENCI agencia
            ,craplau.nrdconta conta
            ,crapass.nmprimtl associado 
            ,craplau.vllanaut vlrlancamento
            ,craplau.dtmvtopg dtmvto --dt deve ser pago
            ,craphis.cdhistor||'-'||craphis.dshistor historico
            ,'PC_CRPS509_PRIORI' 
            , 0 auxcdlcremp
       FROM craplau craplau
          ,crapass crapass
          ,craphis craphis 
      WHERE craplau.cdcooper = crapass.cdcooper
        AND craplau.nrdconta = crapass.nrdconta
        AND craplau.cdcooper = craphis.cdcooper
        AND craplau.cdhistor = craphis.cdhistor
        AND crapass.cdcooper = pr_cdcooper  
        AND crapass.cdagenci = pr_cdagenci
        AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
        AND craplau.cdtiptra <> 4                                    
        AND ((    craplau.cdcooper = pr_cdcooper
            AND   craplau.dtmvtopg = vr_dtmvtolt 
            AND   craplau.insitlau = 1
            AND   craplau.dsorigem IN ('INTERNET','TAA')
            AND    craplau.tpdvalor = 0)
            OR
           (    craplau.cdcooper  = pr_cdcooper
            AND craplau.dtmvtopg BETWEEN vr_dtmovini /*pr_dtmovini*/ AND vr_dtmvtolt --pr_dtmvtopg
            AND craplau.insitlau  = 1
            AND craplau.dsorigem  = 'DEBAUT'))
            and InStr(pr_ds_cdprocesso,'PC_CRPS509_PRIORI'||',') > 0    
            -- verifica se convenio é agua e luz
            and exists ( select 1 
              FROM gnconve a
                  ,crapcon b
             WHERE a.cdhisdeb = craphis.cdhistor
               AND a.cdhiscxa = b.cdhistor
               AND b.cdsegmto in (2,3) -- 3=energia; 2=agua.
               AND b.cdcooper = craplau.cdcooper)     
   union
   --DEBNET - crps509 - programa de convenios próprios - CECRED , menos agua e luz
      SELECT DISTINCT
             craplau.cdcooper coope
            ,crapass.CDAGENCI agencia
            ,craplau.nrdconta conta
            ,crapass.nmprimtl associado 
            ,craplau.vllanaut vlrlancamento
            ,craplau.dtmvtopg dtmvto --dt deve ser pago
            ,craphis.cdhistor||'-'||craphis.dshistor historico
            ,'PC_CRPS509' 
            , 0 auxcdlcremp
       FROM craplau craplau
          ,crapass crapass
          ,craphis craphis 
      WHERE craplau.cdcooper = crapass.cdcooper
        AND craplau.nrdconta = crapass.nrdconta
        AND craplau.cdcooper = craphis.cdcooper
        AND craplau.cdhistor = craphis.cdhistor
        AND crapass.cdcooper = pr_cdcooper  
        AND crapass.cdagenci = pr_cdagenci
        AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
        AND craplau.cdtiptra <> 4              
        AND ((    craplau.cdcooper = pr_cdcooper
            AND   craplau.dtmvtopg = vr_dtmvtolt 
            AND   craplau.insitlau = 1
            AND   craplau.dsorigem IN ('INTERNET','TAA')
            AND    craplau.tpdvalor = 0)
            OR
           (    craplau.cdcooper  = pr_cdcooper
            AND craplau.dtmvtopg BETWEEN vr_dtmovini /*pr_dtmovini*/ AND vr_dtmvtolt --pr_dtmvtopg
            AND craplau.insitlau  = 1
            AND craplau.dsorigem  = 'DEBAUT'))
            and InStr(pr_ds_cdprocesso,'PC_CRPS509'||',') > 0     
            -- verifica se convenio é diferente de agua e luz
            and not exists ( select 1 
              FROM gnconve a
                  ,crapcon b
             WHERE a.cdhisdeb = craphis.cdhistor
               AND a.cdhiscxa = b.cdhistor
               AND b.cdsegmto in (2,3) -- 3=energia; 2=agua.
               AND b.cdcooper = craplau.cdcooper)                         
     Union
      --DEBSIC - crps642_PRIORI - programa de convenios terceiroS - SICREDI - somente agua e luz
      SELECT DISTINCT
             craplau.cdcooper coope
            ,crapass.CDAGENCI agencia
            ,craplau.nrdconta conta
            ,crapass.nmprimtl associado 
            ,craplau.vllanaut vlrlancamento
            ,craplau.dtmvtopg dtmvto --dt deve ser pago
            ,craphis.cdhistor||'-'||craphis.dshistor historico
            ,'PC_CRPS642_PRIORI'             
            , 0 auxcdlcremp
      FROM craplau
          ,crapass
          ,craphis
      WHERE craplau.cdcooper = crapass.cdcooper
        AND craplau.nrdconta = crapass.nrdconta
        AND crapass.cdcooper = pr_cdcooper
        AND crapass.cdagenci = pr_cdagenci
        AND crapass.nrdconta     = nvl(pr_nrdconta,crapass.nrdconta)      
        AND craplau.cdcooper = craphis.cdcooper
        AND craplau.cdhistor = craphis.cdhistor
        AND ((craplau.cdcooper = pr_cdcooper
        AND craplau.dtmvtopg = vr_dtmvtolt
        AND craplau.insitlau = 1
        AND craplau.dsorigem IN ('INTERNET','TAA','CAIXA')
        AND craplau.tpdvalor = 1)
          -- debito automatico sicredi
        OR (craplau.cdcooper  = pr_cdcooper
        AND craplau.dtmvtopg BETWEEN vr_dtmovini AND vr_dtmvtolt
        AND craplau.insitlau  = 1
        AND craplau.cdhistor  = 1019))   
        and InStr(pr_ds_cdprocesso,'PC_CRPS642_PRIORI'||',') > 0          
        and exists (select 1 
             FROM crapscn
                  ,crapcon
                  ,crapatr
             WHERE crapscn.cdempcon = crapcon.cdempcon
               AND crapscn.cdsegmto = crapcon.cdsegmto
               AND crapscn.cdempcon = crapatr.cdempcon
               AND crapscn.cdsegmto = crapatr.cdsegmto
               AND crapatr.cdcooper = craplau.cdcooper  -- CODIGO DA COOPERATIVA
               AND crapatr.nrdconta = craplau.nrdconta  -- NUMERO DA CONTA
               AND crapatr.cdhistor = craplau.cdhistor  -- CODIGO DO HISTORICO
               AND crapatr.cdrefere = craplau.nrcrcard  -- COD. REFERENCIA
               AND crapcon.flgcnvsi = 1 -- indica que é sicred
               AND crapscn.cdempcon <> 0
               AND crapscn.dsoparre = 'E' -- debito automatico
               AND crapscn.cddmoden IN ('A','C') -- tipo da modalidade de cadastro debito automatico
               AND crapscn.cdsegmto in (2, 3) -- agua / energia
               AND crapcon.cdcooper = craplau.cdcooper
                UNION
               SELECT 1
               FROM crapscn
                   ,crapcon
               WHERE crapscn.cdempcon = crapcon.cdempcon
                AND crapscn.cdsegmto = crapcon.cdsegmto
                AND crapcon.flgcnvsi = 1 -- indica que é sicred
                AND crapscn.dsoparre <> 'E' -- diferente de debito automatico
                AND crapscn.cdsegmto in (2, 3) -- agua / energia
                AND crapscn.cdempcon = TO_NUMBER(SUBSTR(craplau.dscodbar,16,4)) -- empresa convenio
                AND crapscn.cdsegmto = TO_NUMBER(SUBSTR(craplau.dscodbar,2,1))  -- segmento convenio
                AND crapcon.cdcooper = craplau.cdcooper                
               )
      Union
      --DEBSIC - crps642 - programa de convenios terceiroS - SICREDI, menos agua e luz
      SELECT DISTINCT
             craplau.cdcooper coope
            ,crapass.CDAGENCI agencia
            ,craplau.nrdconta conta
            ,crapass.nmprimtl associado 
            ,craplau.vllanaut vlrlancamento
            ,craplau.dtmvtopg dtmvto --dt deve ser pago
            ,craphis.cdhistor||'-'||craphis.dshistor historico
            ,'PC_CRPS642'             
            , 0 auxcdlcremp
      FROM craplau
          ,crapass
          ,craphis
      WHERE craplau.cdcooper = crapass.cdcooper
        AND craplau.nrdconta = crapass.nrdconta
        AND crapass.cdcooper = pr_cdcooper
        AND crapass.cdagenci = pr_cdagenci
        AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
        AND craplau.cdcooper = craphis.cdcooper
        AND craplau.cdhistor = craphis.cdhistor
        AND ((craplau.cdcooper = pr_cdcooper
        AND craplau.dtmvtopg = vr_dtmvtolt
        AND craplau.insitlau = 1
        AND craplau.dsorigem IN ('INTERNET','TAA','CAIXA')
        AND craplau.tpdvalor = 1)
          -- debito automatico sicredi
        OR (craplau.cdcooper  = pr_cdcooper
        AND craplau.dtmvtopg BETWEEN vr_dtmovini AND vr_dtmvtolt
        AND craplau.insitlau  = 1
        AND craplau.cdhistor  = 1019))        
        and InStr(pr_ds_cdprocesso,'PC_CRPS642'||',') > 0          
        -- verificar se agua e luz  
        and not exists (select 1 
             FROM crapscn
                  ,crapcon
                  ,crapatr
             WHERE crapscn.cdempcon = crapcon.cdempcon
               AND crapscn.cdsegmto = crapcon.cdsegmto
               AND crapscn.cdempcon = crapatr.cdempcon
               AND crapscn.cdsegmto = crapatr.cdsegmto
               AND crapatr.cdcooper = craplau.cdcooper  -- CODIGO DA COOPERATIVA
               AND crapatr.nrdconta = craplau.nrdconta  -- NUMERO DA CONTA
               AND crapatr.cdhistor = craplau.cdhistor  -- CODIGO DO HISTORICO
               AND crapatr.cdrefere = craplau.nrcrcard  -- COD. REFERENCIA
               AND crapcon.flgcnvsi = 1 -- indica que é sicred
               AND crapscn.cdempcon <> 0
               AND crapscn.dsoparre = 'E' -- debito automatico
               AND crapscn.cddmoden IN ('A','C') -- tipo da modalidade de cadastro debito automatico
               AND crapscn.cdsegmto in (2, 3) -- agua / energia
               AND crapcon.cdcooper = craplau.cdcooper
               UNION
               SELECT 1
               FROM crapscn
                   ,crapcon
               WHERE crapscn.cdempcon = crapcon.cdempcon
                AND crapscn.cdsegmto = crapcon.cdsegmto
                AND crapcon.flgcnvsi = 1 -- indica que é sicred
                AND crapscn.dsoparre <> 'E' -- diferente de debito automatico
                AND crapscn.cdsegmto in (2, 3) -- agua / energia
                AND crapscn.cdempcon = TO_NUMBER(SUBSTR(craplau.dscodbar,16,4)) -- empresa convenio
                AND crapscn.cdsegmto = TO_NUMBER(SUBSTR(craplau.dscodbar,2,1))  -- segmento convenio
                AND crapcon.cdcooper = craplau.cdcooper                
               )          
      union
      -- pc_crps145 - Poupanca Programada - craprpp - pendentes
      SELECT craprpp.cdcooper coope,
             ass.CDAGENCI agencia,
             craprpp.nrdconta conta,
             ass.nmprimtl associado,
             craprpp.vlprerpp vlrlancamento, --Valor da prestacao da poupanca programada.
             craprpp.dtdebito dtmvto,
             his.cdhistor||'-'||his.dshistor historico
            ,'PC_CRPS145'                 
            , 0 auxcdlcremp
      FROM   craprpp,
             crapass ass,
             craphis his 
      WHERE  craprpp.cdcooper  = pr_cdcooper 
      AND    craprpp.nrdconta >= 1 --pr_nrctares 
      AND    craprpp.nrctrrpp  > 0 --pr_nrctrrpp Numero da poupanca programada
      AND   (craprpp.cdsitrpp  = 1 OR craprpp.cdsitrpp  = 2) --Situacao: 0-nao ativo, 1-ativo, 2-suspenso, 3-cancelado, 5-vencido.
      AND    craprpp.dtdebito <= vr_dtmvtolt --pr_dtdebito
      AND    craprpp.indebito  = 0 --Indicador de debito
      AND    ass.cdcooper      = craprpp.cdcooper
      AND    ass.nrdconta      = craprpp.nrdconta
      AND    ass.cdagenci      = pr_cdagenci
      AND    ass.nrdconta      = nvl(pr_nrdconta,ass.nrdconta)      
      AND    craprpp.cdcooper  = his.cdcooper
      AND    his.cdhistor      = 150 --CR.PLANO POUP       
      AND    InStr(pr_ds_cdprocesso,'PC_CRPS145'||',') > 0    
      Union
      -- Processamento de agendamento de recarga de celular
      SELECT distinct
             ope.cdcooper coope,
             ass.cdagenci agencia,
             ope.nrdconta conta,
             ass.nmprimtl associado,
             ope.vlrecarga vlrlancamento, --valor da recarga
             ope.DTRECARGA dtmvto, --Data da recarga de celular
             his.cdhistor||'-'||his.dshistor historico
            ,'RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA'            
            , 0 auxcdlcremp
      FROM tbrecarga_operacao ope,
           tbrecarga_operadora opr,
           crapass ass,
           craphis his
      WHERE ope.cdcooper = pr_cdcooper
        AND ope.insit_operacao IN (1) --(1-Agendado/ 2-Processado/ 3-Transacao Pendente/ 4-Cancelado/ 5-Nao efetivado/ 6-Nao aprovada transacao pendente/ 7-Expirada transacao pendente/ 8-Transacao abortada)
        AND ope.dtrecarga = vr_dtmvtolt
        AND ass.cdagenci    = pr_cdagenci        
        AND ass.nrdconta    = nvl(pr_nrdconta,ass.nrdconta)      
        AND opr.cdoperadora = ope.cdoperadora
        AND ass.cdcooper    = ope.cdcooper
        AND ass.nrdconta    = ope.nrdconta
        AND ope.cdcooper    = his.cdcooper        
        AND his.cdhistor   = opr.cdhisdeb_cooperado  
   /*     AND (his.cdhistor   = opr.cdhisdeb_cooperado OR 
             his.cdhistor   = opr.cdhisdeb_centralizacao)    */
        AND InStr(pr_ds_cdprocesso,'RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA'||',') > 0                 
      union
      --  cecred.pc_crps439 - DEBITO DIARIO DO SEGURO
      SELECT distinct 
             crapseg.CDCOOPER Coope,
             crapass.CDAGENCI agencia, --PA
             crapseg.NRDCONTA Conta,
             crapass.nmprimtl associado, 
             crapseg.VLPRESEG vlrlancamento, --Valor do premio mensal a ser debitado
             crapseg.dtdebito dtmvto, --Data do proximo debito
             craphis.cdhistor||'-'||craphis.dshistor historico
            ,'PC_CRPS439'                 
            , 0 auxcdlcremp
      FROM crapseg 
          ,crapass 
          ,crapcsg
          ,craphis 
      WHERE crapcsg.CDHSTAUT##2 = craphis.cdhistor
        AND crapseg.cdcooper = craphis.cdcooper
        AND crapseg.cdsegura = crapcsg.CDSEGURA
        AND crapseg.cdcooper = crapass.cdcooper
        AND crapseg.nrdconta = crapass.nrdconta
        AND crapseg.cdcooper = pr_cdcooper
        AND crapass.cdagenci = pr_cdagenci    
        AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
        AND crapseg.nrdconta > 1 --pr_nrctares
        AND crapseg.tpseguro >= 11
        AND crapseg.CDSITSEG = 1
        AND crapseg.indebito = 0 --Indicador de debito (1-nao debitado, 1-debitado)
        AND (   crapseg.dtdebito <= vr_dtprdebi
            OR crapseg.dtprideb = vr_dtmvtolt)
        AND InStr(pr_ds_cdprocesso,'PC_CRPS439'||',') > 0                   
     union
     -- tarifas
      SELECT distinct  lat.cdcooper cdcoope
                ,crapass.cdagenci  
                ,lat.nrdconta
                ,crapass.nmprimtl associado
                ,lat.vltarifa vlrlancamento
                ,lat.dtmvtolt dtmvto
                ,craphis.cdhistor||'-'||craphis.dshistor historico            
               ,'TARI0001.PC_DEB_TARIFA_PEND'                     
               , 0 auxcdlcremp
      FROM craplat lat
                ,crapass 
                ,craphis 
      WHERE lat.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
             AND lat.dtmvtolt >=  to_date('22/04/1500','DD/MM/RRRR') --mesma regra que está na tari0001.pc_deb_tarifa_pend
             AND lat.dtmvtolt <= vr_dtmvtolt--pr_dtafinal -- DATA DE MOVIMENTAÇÃO
             AND crapass.cdagenci = pr_cdagenci                     
             AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
             AND lat.insitlat = 1
             AND lat.cdhistor = craphis.cdhistor
             AND lat.cdcooper = craphis.cdcooper
             AND lat.cdcooper = crapass.cdcooper
             AND lat.nrdconta = crapass.nrdconta      
             AND InStr(pr_ds_cdprocesso,'TARI0001.PC_DEB_TARIFA_PEND'||',') > 0                       
      union
      --fatura cartão CRPS674
          SELECT fat.cdcooper
                ,crapass.cdagenci  
                ,fat.nrdconta
                ,crapass.nmprimtl associado
                ,fat.vlpendente vlrlancamento
                ,fat.dtvencimento dtmvto
                ,craphis.cdhistor||'-'||craphis.dshistor historico            
               ,'PC_CRPS674'
               , 0 auxcdlcremp
          FROM tbcrd_fatura fat
                ,crapass 
                ,craphis 
         WHERE fat.cdcooper     = pr_cdcooper
             AND fat.insituacao   = 1--pr_insituacao
             AND trunc(fat.dtvencimento)  BETWEEN trunc(vr_dtmvante) 
                                        AND trunc(vr_dtmvtolt)
             AND crapass.cdagenci = pr_cdagenci                                               
             AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
             AND fat.cdcooper = craphis.cdcooper
             AND craphis.cdhistor = 1545 --PG.FAT.CARTAO
             AND fat.cdcooper = crapass.cdcooper
             AND fat.nrdconta = crapass.nrdconta               
             AND InStr(pr_ds_cdprocesso,'PC_CRPS674'||',') > 0                           
      union
      --CRPS688
      SELECT distinct craplau.cdcooper
                    ,crapass.cdagenci  
                    ,craplau.nrdconta
                    ,crapass.nmprimtl associado
                    ,craplau.vllanaut vlrlancamento
                    ,craplau.dtmvtopg dtmvto
                    ,craphis.cdhistor||'-'||craphis.dshistor historico            
                    ,'PC_CRPS688'    
                    , 0 auxcdlcremp
            FROM craplau 
                ,crapass 
                ,craphis ,
                (select  cdcooper
                        ,nrdconta
                      /* se tipo for aplicacao(flgtipar=0) ou resgate(flgtipar=1)
                      pegar o nro lote e o historico correspondente*/               
                       ,(TO_CHAR(decode( flgtipar,0, 32001, 32002),'fm00000') || TO_CHAR(nrdocmto,'fm0000000000') || '%')  nrdocsrc                   
                       ,decode( flgtipar,0, 32001, 32002) nrdolote
                       ,decode( flgtipar,0, 527, 530) cdhistor
                    from crapaar aar
                    WHERE aar.cdcooper = pr_cdcooper
                    AND aar.cdsitaar = 1) crapaar_1      
            WHERE crapaar_1.cdcooper = craplau.cdcooper
            AND   crapaar_1.nrdconta = craplau.nrdconta 
            AND craplau.nrdocmto LIKE crapaar_1.nrdocsrc         
            AND craplau.cdcooper = pr_cdcooper
            AND craplau.cdhistor = crapaar_1.cdhistor
            AND craplau.nrdolote = crapaar_1.nrdolote
            AND craplau.dtmvtopg = vr_dtmvtolt
            AND craplau.insitlau = 1 --Pendente       
            AND crapass.cdagenci = pr_cdagenci   
            AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
            AND craplau.cdhistor = craphis.cdhistor
            AND craplau.cdcooper = craphis.cdcooper
            AND craplau.cdcooper = crapass.cdcooper
            AND craplau.nrdconta = crapass.nrdconta        
            AND InStr(pr_ds_cdprocesso,'PC_CRPS688'||',') > 0        
      union
      SELECT 
               crapepr.cdcooper
              ,crapass.cdagenci
              ,crapepr.nrdconta
              ,crapass.nmprimtl associado            
              ,crappep.vlparepr vlrlancamento
              ,crappep.dtvencto dtmvto
            --  ,crapepr.cdlcremp
             -- ,craphis.cdhistor||'-'||craphis.dshistor historico          
              , ' ' historico  --- vai buscar esse informação somente no loop
              ,'PC_CRPS724'     
              ,crapepr.cdlcremp auxcdlcremp                     --->      Codigo da linha de credito do emprestimo.
          FROM crapepr
          JOIN crawepr
            ON crawepr.cdcooper = crapepr.cdcooper
           AND crawepr.nrdconta = crapepr.nrdconta
           AND crawepr.nrctremp = crapepr.nrctremp
          JOIN crappep
            ON crappep.cdcooper = crapepr.cdcooper
           AND crappep.nrdconta = crapepr.nrdconta
           AND crappep.nrctremp = crapepr.nrctremp
          JOIN crapass
            ON crapass.cdcooper = crapepr.cdcooper
           AND crapass.nrdconta = crapepr.nrdconta
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapass.cdagenci = pr_cdagenci     
           AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
           AND crapepr.tpemprst = 2 -- Pos-Fixado
           AND crappep.inliquid = 0 -- Pendente            
           AND InStr(pr_ds_cdprocesso,'PC_CRPS724'||',') > 0      
           and crappep.dtvencto <= vr_dtmvtolt -- para só buscar com vencimento até o dia da tela
      union
      SELECT      
           craplau.cdcooper coope,
           ass.cdagenci agencia,
           craplau.nrdconta conta,
           ass.nmprimtl associado,
           craplau.vllanaut vlrlancamento,
           craplau.dtmvtolt dtmvto,
           his.cdhistor||'-'||his.dshistor historico,
           'TELA_LAUTOM.PC_EFETIVA_LCTO_PENDENTE_JOB' cdprocesso
           , 0 auxcdlcremp            
          FROM craplau
             , craphis his
             , crapass ass
         WHERE craplau.cdcooper = pr_cdcooper
           AND craplau.insitlau = 1 -- Pendente
           AND craplau.cdbccxlt = 100
           AND craplau.nrdolote = 600033
           AND craplau.dsorigem in ('TRMULTAJUROS','BLQPREJU')
           and ass.cdcooper     = craplau.cdcooper
           AND ass.nrdconta     = craplau.nrdconta
           AND ass.cdagenci     = pr_cdagenci      
           AND ass.nrdconta     = nvl(pr_nrdconta,ass.nrdconta)      
           AND craplau.cdcooper = his.cdcooper
           AND craplau.cdhistor = his.cdhistor
           AND InStr(pr_ds_cdprocesso,'TELA_LAUTOM.PC_EFETIVA_LCTO_PENDENTE_JOB'||',') > 0                             
      union
      SELECT --'PP' idtpprd -- Tipo de produto de emprestimo, se PP chama a PC_CRPS750_2
                crappep.cdcooper
               , crapass.cdagenci
               , crappep.nrdconta
               , crapass.nmprimtl associado           
               , crappep.vlsdvpar vlrlancamento
               , crappep.dtvencto dtmvto
               , craphis.cdhistor||'-'||craphis.dshistor historico            
               ,'PC_CRPS750'        
               , 0 auxcdlcremp                  
            FROM crawepr
               , crapass
               , crappep
               , crapepr
               , craphis 
           WHERE crawepr.cdcooper (+) = crappep.cdcooper
             AND crawepr.nrdconta (+) = crappep.nrdconta
             AND crawepr.nrctremp (+) = crappep.nrctremp
             AND crapass.cdagenci =  pr_cdagenci
             AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
             AND crapass.cdcooper = crappep.cdcooper
             AND crapass.nrdconta = crappep.nrdconta
             and crapepr.cdcooper = crappep.cdcooper
             and crapepr.nrdconta = crappep.nrdconta
             and crapepr.nrctremp = crappep.nrctremp
             and crapepr.tpemprst = 1 -- Price Pre Fixado
             and crapepr.inliquid = 0
             and crapepr.inprejuz = 0
             AND crappep.cdcooper = pr_cdcooper
             AND crappep.dtvencto <= vr_dtmvtolt
             AND crappep.inprejuz = 0
             AND ((crappep.inliquid = 0) OR (crappep.inliquid = 1 AND crappep.dtvencto > vr_dtmovini))
             and craphis.cdcooper = crappep.cdcooper
             and craphis.cdhistor = 108
             AND InStr(pr_ds_cdprocesso,'PC_CRPS750'||',') > 0       
           UNION
           SELECT --'TR' idtpprd
                  epr.cdcooper
                  ,crapass.CDAGENCI
                  ,crapass.nrdconta
                  ,crapass.nmprimtl associado           
                  ,prc.vlparcela vlrlancamento
                  ,prc.dtdpagto dtmvto
                  ,craphis.cdhistor||'-'||craphis.dshistor historico            
                  ,'PC_CRPS750'           
                  , 0 auxcdlcremp                        
              FROM crapepr           epr,
                   tbepr_tr_parcelas prc,
                   crapass,
                   craphis                
             WHERE epr.cdcooper      = prc.cdcooper
               AND epr.nrdconta      = prc.nrdconta
               AND epr.nrctremp      = prc.nrctremp
               AND epr.cdcooper      = pr_cdcooper  
               AND epr.inliquid      = 0                    --> Somente não liquidados
               AND epr.indpagto      = 0                    --> Nao pago no mês ainda
               AND epr.flgpagto      = 0                    --> Débito em conta
               AND epr.tpemprst      = 0                    --> Price TR
               AND prc.dtdpagto     <= vr_dtmvtolt        
               AND prc.flgacordo    <> 1
               AND prc.flgprocessa   = 1
               AND 108               = craphis.cdhistor
               AND epr.cdcooper      = craphis.cdcooper
               AND epr.cdcooper      = crapass.cdcooper
               AND prc.nrdconta      = crapass.nrdconta  
               AND crapass.cdagenci  =  pr_cdagenci           
               AND crapass.nrdconta  = nvl(pr_nrdconta,crapass.nrdconta)      
               AND InStr(pr_ds_cdprocesso,'PC_CRPS750'||',') > 0       
      union
      -- CRPS268.p - DEBITO EM CONTA REFERENTE SEGURO DE VIDA EM GRUPO
      SELECT distinct
             crapseg.CDCOOPER coope,
             crapass.cdagenci agencia,       
             crapass.NRDCONTA Conta,
             crapass.nmprimtl associado,       
             crapseg.VLPRESEG vlrlancamento, --Valor do premio mensal a ser debitado
             crapseg.dtdebito dtmvto, --Data do proximo debito
             craphis.cdhistor||'-'||craphis.dshistor historico,
             'PC_CRPS268' cdprocesso
             , 0 auxcdlcremp
      FROM crapseg 
          ,crapass 
          ,crapcsg
          ,craphis 
      WHERE crapcsg.CDHSTAUT##2 = craphis.cdhistor
        AND crapseg.cdcooper = craphis.cdcooper
        AND crapseg.cdsegura = crapcsg.CDSEGURA
        AND crapseg.cdcooper = crapass.cdcooper
        AND crapseg.nrdconta = crapass.nrdconta
        AND crapseg.cdcooper = pr_cdcooper
        AND crapass.cdagenci = pr_cdagenci           
        AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
        AND crapseg.nrdconta >= 1 --pr_nrctares
        AND  crapseg.nrctrseg > 1  --aux_nrctrseg   
        AND crapseg.tpseguro = 3
        AND  crapseg.cdsitseg = 1 
        AND crapseg.indebito = 0 --Indicador de debito (1-nao debitado, 1-debitado)
        AND ( crapseg.dtdebito <= vr_dtmvtolt /*pr_dtprdebi*/ or --Data do proximo debito de seguro
               crapseg.dtprideb = vr_dtmvtolt or /*vr_dtmvtolt*/ --Data do primeiro debito do seguro
              ( to_char(crapseg.dtrenova,'yyyymm') = to_char(pr_dtmvtolt,'yyyymm') --MONTH(glb_dtmvtolt) 
                  AND  crapseg.dtrenova <= vr_dtmvtolt ) )
         AND InStr(pr_ds_cdprocesso,'PC_CRPS268'||',') > 0           
	  union	 
		SELECT 
					 craplau.cdcooper coope
					,crapass.CDAGENCI agencia
					,craplau.nrdconta conta
					,crapass.nmprimtl associado 
					,craplau.vllanaut vlrlancamento
					,craplau.dtmvtopg dtmvto --dt deve ser pago
					,craphis.cdhistor||'-'||craphis.dshistor historico
					,'PC_CRPS663' 
					, 0 auxcdlcremp
		FROM craplau
			,crapass crapass
			,craphis craphis 
		WHERE craplau.cdcooper = pr_cdcooper 
		AND   craplau.dtmvtopg = vr_dtmvtolt --= aux_dtrefere     
		AND  (craplau.cdhistor = 1230             OR 
			  craplau.cdhistor = 1231             OR
			  craplau.cdhistor = 1232             OR 
			  craplau.cdhistor = 1233             OR 
			  craplau.cdhistor = 1234)       
		AND   craplau.insitlau = 1 
		AND   craplau.cdcooper = crapass.cdcooper
		AND   craplau.nrdconta = crapass.nrdconta
		AND   craplau.cdcooper = craphis.cdcooper
		AND   craplau.cdhistor = craphis.cdhistor
		AND   crapass.cdagenci = pr_cdagenci
		AND   crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
		and InStr(pr_ds_cdprocesso,'PC_CRPS663'||',') > 0    	
    union
    SELECT 	   craplau.cdcooper coope
              ,crapass.CDAGENCI agencia
              ,craplau.nrdconta conta
              ,crapass.nmprimtl associado 
              ,craplau.vllanaut vlrlancamento
              ,craplau.dtmvtopg dtmvto --dt deve ser pago
              ,craphis.cdhistor||'-'||craphis.dshistor historico
              ,'PAGA0003.PC_PROCESSA_AGEND_BANCOOB' 
              , 0 auxcdlcremp             
    FROM   craplau,
           crapass crapass,      
           craphis
    WHERE craplau.cdcooper = craphis.cdcooper
    AND craplau.cdhistor = craphis.cdhistor
    AND craplau.cdcooper = pr_cdcooper
    AND craplau.dtmvtopg = vr_dtmvtolt
    AND craplau.insitlau = 1
    AND craplau.tpdvalor = 2 -- Bancoob
    AND craplau.cdcooper = crapass.cdcooper
    AND craplau.nrdconta = crapass.nrdconta
    AND crapass.cdagenci = pr_cdagenci
    AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
    AND InStr(pr_ds_cdprocesso,'PAGA0003.PC_PROCESSA_AGEND_BANCOOB'||',') > 0        	 
    )   
    ) WHERE Row_Num BETWEEN vr_auxinicial AND vr_auxfinal;                	      
     
 
    rw_debitos cr_debitos%ROWTYPE;    
    
BEGIN
    pr_des_erro := 'OK';

    vr_dtmvtolt := to_date(pr_dtmvtolt,'dd/mm/yyyy');

     -- Data anterior util, para DEBNET (509) e DEBSIC (642) e outros
    vr_dtmovini := gene0005.fn_valida_dia_util(pr_cdcooper,
                                                 (vr_dtmvtolt - 1), -- 1 dia anterior
                                                 'A',    -- Anterior
                                                 TRUE,   -- Feriado
                                                 FALSE); -- Desconsiderar 31/12
      -- Adiciona mais um 1 dia na data inicial, para pegar finais de semana e feriados
    vr_dtmovini := vr_dtmovini + 1;
    ---------------
    

    IF  InStr(pr_ds_cdprocesso,'PC_CRPS439'||',') > 0   THEN        
      -- Tratamento de data para o CRPS439    
      -- Data posterior util
      vr_dtprdebi := gene0005.fn_valida_dia_util(pr_cdcooper,
                                                   (vr_dtmvtolt - 1), -- 1 dia anterior
                                                   'P',    -- Proximo
                                                   TRUE,   -- Feriado
                                                   FALSE); -- Desconsiderar 31/12
                                                   
      IF TO_CHAR(vr_dtmvtolt,'MM') <> TO_CHAR(vr_dtprdebi,'MM') THEN
         vr_dtprdebi := TRUNC(vr_dtprdebi,'MM') - 1;
      ELSE
         vr_dtprdebi := vr_dtmvtolt;
      END IF;
      -------------------
    END IF;

    IF  InStr(pr_ds_cdprocesso,'PC_CRPS674'||',') > 0   THEN        
    --------------------- CRPS674
       tari0001.pc_carrega_par_tarifa_vigente(pr_cdcooper => pr_cdcooper
                                            ,pr_cdbattar => 'DIASREPCCR'
                                            ,pr_dsconteu => vr_dsconteu
                                            ,pr_cdcritic => vr_cdcritic
                                            ,pr_dscritic => vr_dscritic
                                            ,pr_des_erro => vr_des_erro
                                            ,pr_tab_erro => vr_tab_erro);
                                            
      -- Verifica se Houve Erro no Retorno
      IF vr_des_erro = 'NOK' THEN
        -- Envio Centralizado de Log de Erro
        IF vr_tab_erro.count > 0 THEN

          -- Recebe Fescrição do Erro
          vr_dscritic := vr_tab_erro(vr_tab_erro.FIRST).dscritic;

          -- Quantidade Isento
          vr_qtddiapg := 0;
        END IF;
      ELSE
        -- Quantidade dias que pode ser feito repique
        vr_qtddiapg := to_number(vr_dsconteu);  
      END IF; 
    -- Tratamento de data para o CRPS674 
          -- Pegar a data de referencia do periodo    
      vr_dtmvante:= gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,pr_dtmvtolt => vr_dtmvtolt - vr_qtddiapg, pr_tipo => 'A');
      vr_dtmvante:= gene0005.fn_valida_dia_util(pr_cdcooper => pr_cdcooper,pr_dtmvtolt => vr_dtmvante - 1, pr_tipo => 'A');

    END IF;

    IF  InStr(pr_ds_cdprocesso,'PC_CRPS724'||',') > 0   THEN    
     -- Limpar tabela de memoria
        vr_tab_craplcr.DELETE;
           -- Carregar linhas de credito, para crps724
        FOR rw_craplcr IN cr_craplcr(pr_cdcooper => pr_cdcooper) LOOP
          vr_tab_craplcr(rw_craplcr.cdlcremp).dsoperac := rw_craplcr.dsoperac;
          vr_tab_craplcr(rw_craplcr.cdlcremp).perjurmo := rw_craplcr.perjurmo;
          vr_tab_craplcr(rw_craplcr.cdlcremp).flgcobmu := rw_craplcr.flgcobmu;
        END LOOP;
    END IF;
    
    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Debitos',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);
                           
    --- controle paginação da tela                           
    vr_auxinicial := ((pr_pagina - 1)*vr_nrlinhas) + 1;
    vr_auxfinal   := (pr_pagina* vr_nrlinhas);                           

     SELECT  count(*) INTO vr_RegTotal
     from (
     select
           pla.cdcooper coope,
           ass.cdagenci agencia,
           pla.nrdconta conta,
           ass.nmprimtl associado,
           pla.vlprepla vlrlancamento,
           pla.dtmvtolt dtmvto,
           his.cdhistor||'-'||his.dshistor historico,
           'PC_CRPS172' cdprocesso
           , 0 auxcdlcremp
    from crapass ass,
         crapsld sld,
         crapcot cot,
         crappla pla,
         craphis his
    where pla.cdcooper = pr_cdcooper
      and pla.nrdconta > 1 --pr_nrctares
      and pla.tpdplano = 1
      and pla.cdsitpla = 1
      and pla.flgpagto = 0
      and pla.indpagto = 0
      and pla.dtdpagto <= vr_dtmvtolt
      and pla.qtprepag <= pla.qtpremax
      and cot.cdcooper (+) = pla.cdcooper
      and cot.nrdconta (+) = pla.nrdconta
      and sld.cdcooper (+) = pla.cdcooper
      and sld.nrdconta (+) = pla.nrdconta
      and ass.cdcooper     = pla.cdcooper
      and ass.nrdconta     = pla.nrdconta
      and ass.cdagenci     = pr_cdagenci      
      and ass.nrdconta     = nvl(pr_nrdconta,ass.nrdconta)      
      and pla.cdcooper     = his.cdcooper
      and his.cdhistor     = 127 -- DB. COTAS
      and InStr(pr_ds_cdprocesso,'PC_CRPS172'||',') > 0 
  union
   --DEBNET - crps509_PRIORI - programa de convenios próprios - CECRED, mas somente agua e luz
      SELECT DISTINCT
             craplau.cdcooper coope
            ,crapass.CDAGENCI agencia
            ,craplau.nrdconta conta
            ,crapass.nmprimtl associado 
            ,craplau.vllanaut vlrlancamento
            ,craplau.dtmvtopg dtmvto --dt deve ser pago
            ,craphis.cdhistor||'-'||craphis.dshistor historico
            ,'PC_CRPS509_PRIORI' 
            , 0 auxcdlcremp
       FROM craplau craplau
          ,crapass crapass
          ,craphis craphis 
      WHERE craplau.cdcooper = crapass.cdcooper
        AND craplau.nrdconta = crapass.nrdconta
        AND craplau.cdcooper = craphis.cdcooper
        AND craplau.cdhistor = craphis.cdhistor
        AND crapass.cdcooper = pr_cdcooper  
        AND crapass.cdagenci = pr_cdagenci
        AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
        AND craplau.cdtiptra <> 4                                    
        AND ((    craplau.cdcooper = pr_cdcooper
            AND   craplau.dtmvtopg = vr_dtmvtolt 
            AND   craplau.insitlau = 1
            AND   craplau.dsorigem IN ('INTERNET','TAA')
            AND    craplau.tpdvalor = 0)
            OR
           (    craplau.cdcooper  = pr_cdcooper
            AND craplau.dtmvtopg BETWEEN vr_dtmovini /*pr_dtmovini*/ AND vr_dtmvtolt --pr_dtmvtopg
            AND craplau.insitlau  = 1
            AND craplau.dsorigem  = 'DEBAUT'))
            and InStr(pr_ds_cdprocesso,'PC_CRPS509_PRIORI'||',') > 0    
            -- verifica se convenio é agua e luz
            and exists ( select 1 
              FROM gnconve a
                  ,crapcon b
             WHERE a.cdhisdeb = craphis.cdhistor
               AND a.cdhiscxa = b.cdhistor
               AND b.cdsegmto in (2,3) -- 3=energia; 2=agua.
               AND b.cdcooper = craplau.cdcooper)     
   union
   --DEBNET - crps509 - programa de convenios próprios - CECRED , menos agua e luz
      SELECT DISTINCT
             craplau.cdcooper coope
            ,crapass.CDAGENCI agencia
            ,craplau.nrdconta conta
            ,crapass.nmprimtl associado 
            ,craplau.vllanaut vlrlancamento
            ,craplau.dtmvtopg dtmvto --dt deve ser pago
            ,craphis.cdhistor||'-'||craphis.dshistor historico
            ,'PC_CRPS509' 
            , 0 auxcdlcremp
       FROM craplau craplau
          ,crapass crapass
          ,craphis craphis 
      WHERE craplau.cdcooper = crapass.cdcooper
        AND craplau.nrdconta = crapass.nrdconta
        AND craplau.cdcooper = craphis.cdcooper
        AND craplau.cdhistor = craphis.cdhistor
        AND crapass.cdcooper = pr_cdcooper  
        AND crapass.cdagenci = pr_cdagenci
        AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
        AND craplau.cdtiptra <> 4              
        AND ((    craplau.cdcooper = pr_cdcooper
            AND   craplau.dtmvtopg = vr_dtmvtolt 
            AND   craplau.insitlau = 1
            AND   craplau.dsorigem IN ('INTERNET','TAA')
            AND    craplau.tpdvalor = 0)
            OR
           (    craplau.cdcooper  = pr_cdcooper
            AND craplau.dtmvtopg BETWEEN vr_dtmovini /*pr_dtmovini*/ AND vr_dtmvtolt --pr_dtmvtopg
            AND craplau.insitlau  = 1
            AND craplau.dsorigem  = 'DEBAUT'))
            and InStr(pr_ds_cdprocesso,'PC_CRPS509'||',') > 0     
            -- verifica se convenio é diferente de agua e luz
            and not exists ( select 1 
              FROM gnconve a
                  ,crapcon b
             WHERE a.cdhisdeb = craphis.cdhistor
               AND a.cdhiscxa = b.cdhistor
               AND b.cdsegmto in (2,3) -- 3=energia; 2=agua.
               AND b.cdcooper = craplau.cdcooper)                         
     Union
      --DEBSIC - crps642_PRIORI - programa de convenios terceiroS - SICREDI - somente agua e luz
      SELECT DISTINCT
             craplau.cdcooper coope
            ,crapass.CDAGENCI agencia
            ,craplau.nrdconta conta
            ,crapass.nmprimtl associado 
            ,craplau.vllanaut vlrlancamento
            ,craplau.dtmvtopg dtmvto --dt deve ser pago
            ,craphis.cdhistor||'-'||craphis.dshistor historico
            ,'PC_CRPS642_PRIORI'             
            , 0 auxcdlcremp
      FROM craplau
          ,crapass
          ,craphis
      WHERE craplau.cdcooper = crapass.cdcooper
        AND craplau.nrdconta = crapass.nrdconta
        AND crapass.cdcooper = pr_cdcooper
        AND crapass.cdagenci = pr_cdagenci
        AND crapass.nrdconta     = nvl(pr_nrdconta,crapass.nrdconta)      
        AND craplau.cdcooper = craphis.cdcooper
        AND craplau.cdhistor = craphis.cdhistor
        AND ((craplau.cdcooper = pr_cdcooper
        AND craplau.dtmvtopg = vr_dtmvtolt
        AND craplau.insitlau = 1
        AND craplau.dsorigem IN ('INTERNET','TAA','CAIXA')
        AND craplau.tpdvalor = 1)
          -- debito automatico sicredi
        OR (craplau.cdcooper  = pr_cdcooper
        AND craplau.dtmvtopg BETWEEN vr_dtmovini AND vr_dtmvtolt
        AND craplau.insitlau  = 1
        AND craplau.cdhistor  = 1019))   
        and InStr(pr_ds_cdprocesso,'PC_CRPS642_PRIORI'||',') > 0          
        and exists (select 1 
             FROM crapscn
                  ,crapcon
                  ,crapatr
             WHERE crapscn.cdempcon = crapcon.cdempcon
               AND crapscn.cdsegmto = crapcon.cdsegmto
               AND crapscn.cdempcon = crapatr.cdempcon
               AND crapscn.cdsegmto = crapatr.cdsegmto
               AND crapatr.cdcooper = craplau.cdcooper  -- CODIGO DA COOPERATIVA
               AND crapatr.nrdconta = craplau.nrdconta  -- NUMERO DA CONTA
               AND crapatr.cdhistor = craplau.cdhistor  -- CODIGO DO HISTORICO
               AND crapatr.cdrefere = craplau.nrcrcard  -- COD. REFERENCIA
               AND crapcon.flgcnvsi = 1 -- indica que é sicred
               AND crapscn.cdempcon <> 0
               AND crapscn.dsoparre = 'E' -- debito automatico
               AND crapscn.cddmoden IN ('A','C') -- tipo da modalidade de cadastro debito automatico
               AND crapscn.cdsegmto in (2, 3) -- agua / energia
               AND crapcon.cdcooper = craplau.cdcooper
                UNION
               SELECT 1
               FROM crapscn
                   ,crapcon
               WHERE crapscn.cdempcon = crapcon.cdempcon
                AND crapscn.cdsegmto = crapcon.cdsegmto
                AND crapcon.flgcnvsi = 1 -- indica que é sicred
                AND crapscn.dsoparre <> 'E' -- diferente de debito automatico
                AND crapscn.cdsegmto in (2, 3) -- agua / energia
                AND crapscn.cdempcon = TO_NUMBER(SUBSTR(craplau.dscodbar,16,4)) -- empresa convenio
                AND crapscn.cdsegmto = TO_NUMBER(SUBSTR(craplau.dscodbar,2,1))  -- segmento convenio
                AND crapcon.cdcooper = craplau.cdcooper                
               )
      Union
      --DEBSIC - crps642 - programa de convenios terceiroS - SICREDI, menos agua e luz
      SELECT DISTINCT
             craplau.cdcooper coope
            ,crapass.CDAGENCI agencia
            ,craplau.nrdconta conta
            ,crapass.nmprimtl associado 
            ,craplau.vllanaut vlrlancamento
            ,craplau.dtmvtopg dtmvto --dt deve ser pago
            ,craphis.cdhistor||'-'||craphis.dshistor historico
            ,'PC_CRPS642'             
            , 0 auxcdlcremp
      FROM craplau
          ,crapass
          ,craphis
      WHERE craplau.cdcooper = crapass.cdcooper
        AND craplau.nrdconta = crapass.nrdconta
        AND crapass.cdcooper = pr_cdcooper
        AND crapass.cdagenci = pr_cdagenci
        AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
        AND craplau.cdcooper = craphis.cdcooper
        AND craplau.cdhistor = craphis.cdhistor
        AND ((craplau.cdcooper = pr_cdcooper
        AND craplau.dtmvtopg = vr_dtmvtolt
        AND craplau.insitlau = 1
        AND craplau.dsorigem IN ('INTERNET','TAA','CAIXA')
        AND craplau.tpdvalor = 1)
          -- debito automatico sicredi
        OR (craplau.cdcooper  = pr_cdcooper
        AND craplau.dtmvtopg BETWEEN vr_dtmovini AND vr_dtmvtolt
        AND craplau.insitlau  = 1
        AND craplau.cdhistor  = 1019))        
        and InStr(pr_ds_cdprocesso,'PC_CRPS642'||',') > 0          
        -- verificar se agua e luz  
        and not exists (select 1 
             FROM crapscn
                  ,crapcon
                  ,crapatr
             WHERE crapscn.cdempcon = crapcon.cdempcon
               AND crapscn.cdsegmto = crapcon.cdsegmto
               AND crapscn.cdempcon = crapatr.cdempcon
               AND crapscn.cdsegmto = crapatr.cdsegmto
               AND crapatr.cdcooper = craplau.cdcooper  -- CODIGO DA COOPERATIVA
               AND crapatr.nrdconta = craplau.nrdconta  -- NUMERO DA CONTA
               AND crapatr.cdhistor = craplau.cdhistor  -- CODIGO DO HISTORICO
               AND crapatr.cdrefere = craplau.nrcrcard  -- COD. REFERENCIA
               AND crapcon.flgcnvsi = 1 -- indica que é sicred
               AND crapscn.cdempcon <> 0
               AND crapscn.dsoparre = 'E' -- debito automatico
               AND crapscn.cddmoden IN ('A','C') -- tipo da modalidade de cadastro debito automatico
               AND crapscn.cdsegmto in (2, 3) -- agua / energia
               AND crapcon.cdcooper = craplau.cdcooper
                UNION
               SELECT 1
               FROM crapscn
                   ,crapcon
               WHERE crapscn.cdempcon = crapcon.cdempcon
                AND crapscn.cdsegmto = crapcon.cdsegmto
                AND crapcon.flgcnvsi = 1 -- indica que é sicred
                AND crapscn.dsoparre <> 'E' -- diferente de debito automatico
                AND crapscn.cdsegmto in (2, 3) -- agua / energia
                AND crapscn.cdempcon = TO_NUMBER(SUBSTR(craplau.dscodbar,16,4)) -- empresa convenio
                AND crapscn.cdsegmto = TO_NUMBER(SUBSTR(craplau.dscodbar,2,1))  -- segmento convenio
                AND crapcon.cdcooper = craplau.cdcooper                
               )          
      union
      -- pc_crps145 - Poupanca Programada - craprpp - pendentes
      SELECT craprpp.cdcooper coope,
             ass.CDAGENCI agencia,
             craprpp.nrdconta conta,
             ass.nmprimtl associado,
             craprpp.vlprerpp vlrlancamento, --Valor da prestacao da poupanca programada.
             craprpp.dtdebito dtmvto,
             his.cdhistor||'-'||his.dshistor historico
            ,'PC_CRPS145'                 
            , 0 auxcdlcremp
      FROM   craprpp,
             crapass ass,
             craphis his 
      WHERE  craprpp.cdcooper  = pr_cdcooper 
      AND    craprpp.nrdconta >= 1 --pr_nrctares 
      AND    craprpp.nrctrrpp  > 0 --pr_nrctrrpp Numero da poupanca programada
      AND   (craprpp.cdsitrpp  = 1 OR craprpp.cdsitrpp  = 2) --Situacao: 0-nao ativo, 1-ativo, 2-suspenso, 3-cancelado, 5-vencido.
      AND    craprpp.dtdebito <= vr_dtmvtolt --pr_dtdebito
      AND    craprpp.indebito  = 0 --Indicador de debito
      AND    ass.cdcooper      = craprpp.cdcooper
      AND    ass.nrdconta      = craprpp.nrdconta
      AND    ass.cdagenci      = pr_cdagenci
      AND    ass.nrdconta      = nvl(pr_nrdconta,ass.nrdconta)      
      AND    craprpp.cdcooper  = his.cdcooper
      AND    his.cdhistor      = 150 --CR.PLANO POUP       
      AND    InStr(pr_ds_cdprocesso,'PC_CRPS145'||',') > 0    
      Union
      -- Processamento de agendamento de recarga de celular
      SELECT distinct
             ope.cdcooper coope,
             ass.cdagenci agencia,
             ope.nrdconta conta,
             ass.nmprimtl associado,
             ope.vlrecarga vlrlancamento, --valor da recarga
             ope.DTRECARGA dtmvto, --Data da recarga de celular
             his.cdhistor||'-'||his.dshistor historico
            ,'RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA'            
            , 0 auxcdlcremp
      FROM tbrecarga_operacao ope,
           tbrecarga_operadora opr,
           crapass ass,
           craphis his
      WHERE ope.cdcooper = pr_cdcooper
        AND ope.insit_operacao IN (1) --(1-Agendado/ 2-Processado/ 3-Transacao Pendente/ 4-Cancelado/ 5-Nao efetivado/ 6-Nao aprovada transacao pendente/ 7-Expirada transacao pendente/ 8-Transacao abortada)
        AND ope.dtrecarga = vr_dtmvtolt
        AND ass.cdagenci    = pr_cdagenci        
        AND ass.nrdconta    = nvl(pr_nrdconta,ass.nrdconta)      
        AND opr.cdoperadora = ope.cdoperadora
        AND ass.cdcooper    = ope.cdcooper
        AND ass.nrdconta    = ope.nrdconta
        AND ope.cdcooper    = his.cdcooper        
        AND his.cdhistor   = opr.cdhisdeb_cooperado  
    /*    AND (his.cdhistor   = opr.cdhisdeb_cooperado OR 
             his.cdhistor   = opr.cdhisdeb_centralizacao)   */ 
        AND InStr(pr_ds_cdprocesso,'RCEL0001.PC_PROCES_AGENDAMENTOS_RECARGA'||',') > 0                 
      union
      --  cecred.pc_crps439 - DEBITO DIARIO DO SEGURO
      SELECT distinct 
             crapseg.CDCOOPER Coope,
             crapass.CDAGENCI agencia, --PA
             crapseg.NRDCONTA Conta,
             crapass.nmprimtl associado, 
             crapseg.VLPRESEG vlrlancamento, --Valor do premio mensal a ser debitado
             crapseg.dtdebito dtmvto, --Data do proximo debito
             craphis.cdhistor||'-'||craphis.dshistor historico
            ,'PC_CRPS439'                 
            , 0 auxcdlcremp
      FROM crapseg 
          ,crapass 
          ,crapcsg
          ,craphis 
      WHERE crapcsg.CDHSTAUT##2 = craphis.cdhistor
        AND crapseg.cdcooper = craphis.cdcooper
        AND crapseg.cdsegura = crapcsg.CDSEGURA
        AND crapseg.cdcooper = crapass.cdcooper
        AND crapseg.nrdconta = crapass.nrdconta
        AND crapseg.cdcooper = pr_cdcooper
        AND crapass.cdagenci = pr_cdagenci    
        AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
        AND crapseg.nrdconta > 1 --pr_nrctares
        AND crapseg.tpseguro >= 11
        AND crapseg.CDSITSEG = 1
        AND crapseg.indebito = 0 --Indicador de debito (1-nao debitado, 1-debitado)
        AND (   crapseg.dtdebito <= vr_dtprdebi
            OR crapseg.dtprideb = vr_dtmvtolt)
        AND InStr(pr_ds_cdprocesso,'PC_CRPS439'||',') > 0                   
     union
     -- tarifas
      SELECT distinct  lat.cdcooper cdcoope
                ,crapass.cdagenci  
                ,lat.nrdconta
                ,crapass.nmprimtl associado
                ,lat.vltarifa vlrlancamento
                ,lat.dtmvtolt dtmvto
                ,craphis.cdhistor||'-'||craphis.dshistor historico            
               ,'TARI0001.PC_DEB_TARIFA_PEND'                     
               , 0 auxcdlcremp
      FROM craplat lat
                ,crapass 
                ,craphis 
      WHERE lat.cdcooper = pr_cdcooper -- CODIGO DA COOPERATIVA
             AND lat.dtmvtolt >=  to_date('22/04/1500','DD/MM/RRRR') --mesma regra que está na tari0001.pc_deb_tarifa_pend
             AND lat.dtmvtolt <= vr_dtmvtolt--pr_dtafinal -- DATA DE MOVIMENTAÇÃO
             AND crapass.cdagenci = pr_cdagenci                     
             AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
             AND lat.insitlat = 1
             AND lat.cdhistor = craphis.cdhistor
             AND lat.cdcooper = craphis.cdcooper
             AND lat.cdcooper = crapass.cdcooper
             AND lat.nrdconta = crapass.nrdconta      
             AND InStr(pr_ds_cdprocesso,'TARI0001.PC_DEB_TARIFA_PEND'||',') > 0                       
      union
      --fatura cartão CRPS674
          SELECT fat.cdcooper
                ,crapass.cdagenci  
                ,fat.nrdconta
                ,crapass.nmprimtl associado
                ,fat.vlpendente vlrlancamento
                ,fat.dtvencimento dtmvto
                ,craphis.cdhistor||'-'||craphis.dshistor historico            
               ,'PC_CRPS674'
               , 0 auxcdlcremp
          FROM tbcrd_fatura fat
                ,crapass 
                ,craphis 
         WHERE fat.cdcooper     = pr_cdcooper
             AND fat.insituacao   = 1--pr_insituacao
             AND trunc(fat.dtvencimento)  BETWEEN trunc(vr_dtmvante) 
                                        AND trunc(vr_dtmvtolt)
             AND crapass.cdagenci = pr_cdagenci                                               
             AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
             AND fat.cdcooper = craphis.cdcooper
             AND craphis.cdhistor = 1545 --PG.FAT.CARTAO
             AND fat.cdcooper = crapass.cdcooper
             AND fat.nrdconta = crapass.nrdconta               
             AND InStr(pr_ds_cdprocesso,'PC_CRPS674'||',') > 0                           
      union
      --CRPS688
      SELECT distinct craplau.cdcooper
                    ,crapass.cdagenci  
                    ,craplau.nrdconta
                    ,crapass.nmprimtl associado
                    ,craplau.vllanaut vlrlancamento
                    ,craplau.dtmvtopg dtmvto
                    ,craphis.cdhistor||'-'||craphis.dshistor historico            
                    ,'PC_CRPS688'    
                    , 0 auxcdlcremp
            FROM craplau 
                ,crapass 
                ,craphis ,
                (select  cdcooper
                        ,nrdconta
                      /* se tipo for aplicacao(flgtipar=0) ou resgate(flgtipar=1)
                      pegar o nro lote e o historico correspondente*/               
                       ,(TO_CHAR(decode( flgtipar,0, 32001, 32002),'fm00000') || TO_CHAR(nrdocmto,'fm0000000000') || '%')  nrdocsrc                   
                       ,decode( flgtipar,0, 32001, 32002) nrdolote
                       ,decode( flgtipar,0, 527, 530) cdhistor
                    from crapaar aar
                    WHERE aar.cdcooper = pr_cdcooper
                    AND aar.cdsitaar = 1) crapaar_1      
            WHERE crapaar_1.cdcooper = craplau.cdcooper
            AND   crapaar_1.nrdconta = craplau.nrdconta 
            AND craplau.nrdocmto LIKE crapaar_1.nrdocsrc         
            AND craplau.cdcooper = pr_cdcooper
            AND craplau.cdhistor = crapaar_1.cdhistor
            AND craplau.nrdolote = crapaar_1.nrdolote
            AND craplau.dtmvtopg = vr_dtmvtolt
            AND craplau.insitlau = 1 --Pendente       
            AND crapass.cdagenci = pr_cdagenci   
            AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
            AND craplau.cdhistor = craphis.cdhistor
            AND craplau.cdcooper = craphis.cdcooper
            AND craplau.cdcooper = crapass.cdcooper
            AND craplau.nrdconta = crapass.nrdconta        
            AND InStr(pr_ds_cdprocesso,'PC_CRPS688'||',') > 0        
      union
      SELECT 
               crapepr.cdcooper
              ,crapass.cdagenci
              ,crapepr.nrdconta
              ,crapass.nmprimtl associado            
              ,crappep.vlparepr vlrlancamento
              ,crappep.dtvencto dtmvto
            --  ,crapepr.cdlcremp
             -- ,craphis.cdhistor||'-'||craphis.dshistor historico          
              , ' ' historico  --- vai buscar esse informação somente no loop
              ,'PC_CRPS724'     
              ,crapepr.cdlcremp auxcdlcremp                     --->      Codigo da linha de credito do emprestimo.
          FROM crapepr
          JOIN crawepr
            ON crawepr.cdcooper = crapepr.cdcooper
           AND crawepr.nrdconta = crapepr.nrdconta
           AND crawepr.nrctremp = crapepr.nrctremp
          JOIN crappep
            ON crappep.cdcooper = crapepr.cdcooper
           AND crappep.nrdconta = crapepr.nrdconta
           AND crappep.nrctremp = crapepr.nrctremp
          JOIN crapass
            ON crapass.cdcooper = crapepr.cdcooper
           AND crapass.nrdconta = crapepr.nrdconta
         WHERE crapepr.cdcooper = pr_cdcooper
           AND crapass.cdagenci = pr_cdagenci     
           AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
           AND crapepr.tpemprst = 2 -- Pos-Fixado
           AND crappep.inliquid = 0 -- Pendente            
           AND InStr(pr_ds_cdprocesso,'PC_CRPS724'||',') > 0       
           and crappep.dtvencto <= vr_dtmvtolt -- para só buscar com vencimento até o dia da tela 
      union
      SELECT      
           craplau.cdcooper coope,
           ass.cdagenci agencia,
           craplau.nrdconta conta,
           ass.nmprimtl associado,
           craplau.vllanaut vlrlancamento,
           craplau.dtmvtolt dtmvto,
           his.cdhistor||'-'||his.dshistor historico,
           'TELA_LAUTOM.PC_EFETIVA_LCTO_PENDENTE_JOB' cdprocesso
           , 0 auxcdlcremp            
          FROM craplau
             , craphis his
             , crapass ass
         WHERE craplau.cdcooper = pr_cdcooper
           AND craplau.insitlau = 1 -- Pendente
           AND craplau.cdbccxlt = 100
           AND craplau.nrdolote = 600033
           AND craplau.dsorigem IN ('TRMULTAJUROS','BLQPREJU')
           and ass.cdcooper     = craplau.cdcooper
           AND ass.nrdconta     = craplau.nrdconta
           AND ass.cdagenci     = pr_cdagenci      
           AND ass.nrdconta     = nvl(pr_nrdconta,ass.nrdconta)      
           AND craplau.cdcooper = his.cdcooper
           AND craplau.cdhistor = his.cdhistor
           AND InStr(pr_ds_cdprocesso,'TELA_LAUTOM.PC_EFETIVA_LCTO_PENDENTE_JOB'||',') > 0                             
      union
      SELECT --'PP' idtpprd -- Tipo de produto de emprestimo, se PP chama a PC_CRPS750_2
                crappep.cdcooper
               , crapass.cdagenci
               , crappep.nrdconta
               , crapass.nmprimtl associado           
               , crappep.vlsdvpar vlrlancamento
               , crappep.dtvencto dtmvto
               , craphis.cdhistor||'-'||craphis.dshistor historico            
               ,'PC_CRPS750'        
               , 0 auxcdlcremp                  
            FROM crawepr
               , crapass
               , crappep
               , crapepr
               , craphis 
           WHERE crawepr.cdcooper (+) = crappep.cdcooper
             AND crawepr.nrdconta (+) = crappep.nrdconta
             AND crawepr.nrctremp (+) = crappep.nrctremp
             AND crapass.cdagenci =  pr_cdagenci
             AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
             AND crapass.cdcooper = crappep.cdcooper
             AND crapass.nrdconta = crappep.nrdconta
             and crapepr.cdcooper = crappep.cdcooper
             and crapepr.nrdconta = crappep.nrdconta
             and crapepr.nrctremp = crappep.nrctremp
             and crapepr.tpemprst = 1 -- Price Pre Fixado
             and crapepr.inliquid = 0
             and crapepr.inprejuz = 0
             AND crappep.cdcooper = pr_cdcooper
             AND crappep.dtvencto <= vr_dtmvtolt
             AND crappep.inprejuz = 0
             AND ((crappep.inliquid = 0) OR (crappep.inliquid = 1 AND crappep.dtvencto > vr_dtmovini))
             and craphis.cdcooper = crappep.cdcooper
             and craphis.cdhistor = 108
             AND InStr(pr_ds_cdprocesso,'PC_CRPS750'||',') > 0       
           UNION
           SELECT --'TR' idtpprd
                  epr.cdcooper
                  ,crapass.CDAGENCI
                  ,crapass.nrdconta
                  ,crapass.nmprimtl associado           
                  ,prc.vlparcela vlrlancamento
                  ,prc.dtdpagto dtmvto
                  ,craphis.cdhistor||'-'||craphis.dshistor historico            
                  ,'PC_CRPS750'           
                  , 0 auxcdlcremp                        
              FROM crapepr           epr,
                   tbepr_tr_parcelas prc,
                   crapass,
                   craphis                
             WHERE epr.cdcooper      = prc.cdcooper
               AND epr.nrdconta      = prc.nrdconta
               AND epr.nrctremp      = prc.nrctremp
               AND epr.cdcooper      = pr_cdcooper  
               AND epr.inliquid      = 0                    --> Somente não liquidados
               AND epr.indpagto      = 0                    --> Nao pago no mês ainda
               AND epr.flgpagto      = 0                    --> Débito em conta
               AND epr.tpemprst      = 0                    --> Price TR
               AND prc.dtdpagto     <= vr_dtmvtolt        
               AND prc.flgacordo    <> 1
               AND prc.flgprocessa   = 1
               AND 108               = craphis.cdhistor
               AND epr.cdcooper      = craphis.cdcooper
               AND epr.cdcooper      = crapass.cdcooper
               AND prc.nrdconta      = crapass.nrdconta  
               AND crapass.cdagenci  =  pr_cdagenci           
               AND crapass.nrdconta  = nvl(pr_nrdconta,crapass.nrdconta)      
               AND InStr(pr_ds_cdprocesso,'PC_CRPS750'||',') > 0       
      union
      -- CRPS268.p - DEBITO EM CONTA REFERENTE SEGURO DE VIDA EM GRUPO
      SELECT distinct
             crapseg.CDCOOPER coope,
             crapass.cdagenci agencia,       
             crapass.NRDCONTA Conta,
             crapass.nmprimtl associado,       
             crapseg.VLPRESEG vlrlancamento, --Valor do premio mensal a ser debitado
             crapseg.dtdebito dtmvto, --Data do proximo debito
             craphis.cdhistor||'-'||craphis.dshistor historico,
             'PC_CRPS268' cdprocesso
             , 0 auxcdlcremp
      FROM crapseg 
          ,crapass 
          ,crapcsg
          ,craphis 
      WHERE crapcsg.CDHSTAUT##2 = craphis.cdhistor
        AND crapseg.cdcooper = craphis.cdcooper
        AND crapseg.cdsegura = crapcsg.CDSEGURA
        AND crapseg.cdcooper = crapass.cdcooper
        AND crapseg.nrdconta = crapass.nrdconta
        AND crapseg.cdcooper = pr_cdcooper
        AND crapass.cdagenci = pr_cdagenci           
        AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
        AND crapseg.nrdconta >= 1 --pr_nrctares
        AND  crapseg.nrctrseg > 1  --aux_nrctrseg   
        AND crapseg.tpseguro = 3
        AND  crapseg.cdsitseg = 1 
        AND crapseg.indebito = 0 --Indicador de debito (1-nao debitado, 1-debitado)
        AND ( crapseg.dtdebito <= vr_dtmvtolt /*pr_dtprdebi*/ or --Data do proximo debito de seguro
               crapseg.dtprideb = vr_dtmvtolt or /*vr_dtmvtolt*/ --Data do primeiro debito do seguro
              ( to_char(crapseg.dtrenova,'yyyymm') = to_char(vr_dtmvtolt,'yyyymm') --MONTH(glb_dtmvtolt) 
                  AND  crapseg.dtrenova <= vr_dtmvtolt ) )
         AND InStr(pr_ds_cdprocesso,'PC_CRPS268'||',') > 0   
      union	 
      SELECT 
             craplau.cdcooper coope
            ,crapass.CDAGENCI agencia
            ,craplau.nrdconta conta
            ,crapass.nmprimtl associado 
            ,craplau.vllanaut vlrlancamento
            ,craplau.dtmvtopg dtmvto --dt deve ser pago
            ,craphis.cdhistor||'-'||craphis.dshistor historico
            ,'PC_CRPS663' 
            , 0 auxcdlcremp
      FROM craplau
        ,crapass crapass
        ,craphis craphis 
      WHERE craplau.cdcooper = pr_cdcooper 
      AND   craplau.dtmvtopg = vr_dtmvtolt  
      AND  (craplau.cdhistor = 1230             OR 
          craplau.cdhistor = 1231             OR
          craplau.cdhistor = 1232             OR 
          craplau.cdhistor = 1233             OR 
          craplau.cdhistor = 1234)       
      AND   craplau.insitlau = 1 
      AND   craplau.cdcooper = crapass.cdcooper
      AND   craplau.nrdconta = crapass.nrdconta
      AND   craplau.cdcooper = craphis.cdcooper
      AND   craplau.cdhistor = craphis.cdhistor
      AND   crapass.cdagenci = pr_cdagenci
      AND   crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
      and InStr(pr_ds_cdprocesso,'PC_CRPS663'||',') > 0    	    
     union
      SELECT 	   craplau.cdcooper coope
                ,crapass.CDAGENCI agencia
                ,craplau.nrdconta conta
                ,crapass.nmprimtl associado 
                ,craplau.vllanaut vlrlancamento
                ,craplau.dtmvtopg dtmvto --dt deve ser pago
                ,craphis.cdhistor||'-'||craphis.dshistor historico
                ,'PAGA0003.PC_PROCESSA_AGEND_BANCOOB' 
                , 0 auxcdlcremp             
      FROM   craplau,
             crapass crapass,      
             craphis
      WHERE craplau.cdcooper = craphis.cdcooper
      AND craplau.cdhistor = craphis.cdhistor
      AND craplau.cdcooper = pr_cdcooper
      AND craplau.dtmvtopg = vr_dtmvtolt
      AND craplau.insitlau = 1
      AND craplau.tpdvalor = 2 -- Bancoob
      AND craplau.cdcooper = crapass.cdcooper
      AND craplau.nrdconta = crapass.nrdconta
      AND crapass.cdagenci = pr_cdagenci
      AND crapass.nrdconta = nvl(pr_nrdconta,crapass.nrdconta)      
      AND InStr(pr_ds_cdprocesso,'PAGA0003.PC_PROCESSA_AGEND_BANCOOB'||',') > 0            
     )     
     ;

    ---- fim count
    
 --   dbms_output.put_line('total reg: '||vr_RegTotal);

    vr_ds_cdprocesso_ant := 'inicializa';

    -- Percorre os horários
    FOR rw_debitos
      IN cr_debitos LOOP
      
        -- para o CRPS724
        IF rw_debitos.cdprocesso = 'PC_CRPS724' THEN
            vr_data_aux :=  to_date(rw_debitos.dtmvto,'DD/MM/YYYY'); 
           -- Se for Financiamento
           IF (vr_tab_craplcr(rw_debitos.auxcdlcremp).dsoperac = 'FINANCIAMENTO') THEN

                rw_debitos.historico := 2333;   
           ELSE
              --se for emprestimo 
                rw_debitos.historico := 2332;
           END IF;
           FOR rw_craplcr IN cr_craphis(pr_cdcooper => pr_cdcooper, pr_cdhistor => rw_debitos.historico) LOOP
               rw_debitos.historico := rw_craplcr.dshist;
           END LOOP;         
        
        END IF;
        ---
        IF rw_debitos.cdprocesso <> vr_ds_cdprocesso_ant then
          FOR rw_horario_processo IN cr_horario_processo(pr_cdprocesso => rw_debitos.cdprocesso) LOOP
            vr_proxhorario := rw_horario_processo.dhprocessamento;
          END LOOP;   
          
          IF vr_proxhorario is null THEN
              FOR rw_horario_processo_prox IN cr_horario_processo_prox_dia(pr_cdprocesso => rw_debitos.cdprocesso) LOOP
                vr_proxhorario := rw_horario_processo_prox.dhprocessamento;
            END LOOP;   
          END IF; 

          FOR rw_nome_Programa IN cr_nome_Programa(pr_cdprocesso => rw_debitos.cdprocesso) LOOP
            vr_dsprocReduzido := rw_nome_Programa.dsprocReduzido;
            vr_dsprocesso     := rw_nome_Programa.dsprocesso;
          END LOOP;   
         
          vr_ds_cdprocesso_ant :=   rw_debitos.cdprocesso;      

        END IF;


        
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Debitos',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Debito',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);

       -- ID do programa
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Debito',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'Programa',
                               pr_tag_cont => rw_debitos.cdprocesso,
                               pr_des_erro => pr_dscritic);

       -- Descrição reduzida do programa
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Debito',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dsprocReduzido',
                               pr_tag_cont => vr_dsprocReduzido,
                               pr_des_erro => pr_dscritic);

       -- Descrição completa do programa
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Debito',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'dsprocesso',
                               pr_tag_cont => vr_dsprocesso,
                               pr_des_erro => pr_dscritic);


        -- conta do cooperado
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Debito',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'conta',
                               pr_tag_cont => rw_debitos.conta,
                               pr_des_erro => pr_dscritic);

        -- nome cooperado
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Debito',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'associado',
                               pr_tag_cont => rw_debitos.associado,
                               pr_des_erro => pr_dscritic);

      -- valor débito 
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Debito',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'vlrdebito',
                               pr_tag_cont => rw_debitos.vlrlancamento ,
                               pr_des_erro => pr_dscritic);       

     -- Data débito 
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Debito',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'Datadeb',
                               pr_tag_cont => rw_debitos.dtmvto ,
                               pr_des_erro => pr_dscritic);       
                               
     -- histórico (código e descrição) 
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Debito',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'historico',
                               pr_tag_cont => rw_debitos.historico ,
                               pr_des_erro => pr_dscritic);                                      

        -- Próximo Horário 
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Debito',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'proximohorario',
                               pr_tag_cont => vr_proxhorario,
                               pr_des_erro => pr_dscritic);                               
                               
     --- para teste
      -- Dbms_Output.put_line(' Reg: '||vr_contador||'-'||rw_debitos.dtmvto||'-'||rw_debitos.conta||'-'||rw_debitos.associado
      --  ||'-'||rw_debitos.cdprocesso||'-'||vr_dsprocReduzido||'-'||rw_debitos.vlrlancamento||'-'||vr_proxhorario||'-'||rw_debitos.historico );

        vr_contador := vr_contador + 1;

    END LOOP;
    
    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'RgInicio'
                            ,pr_tag_cont => vr_auxinicial

                            ,pr_des_erro => vr_dscritic);


    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'TmPagina'
                            ,pr_tag_cont => vr_nrlinhas
                            ,pr_des_erro => vr_dscritic);


     gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'QtRegist'
                            ,pr_tag_cont => vr_RegTotal
                            ,pr_des_erro => vr_dscritic);	



    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := ' - pc_busca_deb_pendentes: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := ' - pc_busca_deb_pendentes: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_busca_deb_pendentes;

----------------------------

PROCEDURE pc_busca_deb_efetivados(    pr_cdcooper  IN crapcop.cdcooper%TYPE       --> Código da coopertiva
                                    , pr_cdagenci IN crapass.cdagenci%TYPE        --> Código da agencia
                                    , pr_nrdconta IN crapass.nrdconta%TYPE        --> Conta
                                    , pr_dtmvtolt IN VARCHAR2                         --> Data do movimento
                                    , pr_pagina   IN NUMBER                       --> Nr da Pagina                                    
                                    , pr_xmllog   IN VARCHAR2                     --> XML com informações de LOG
                                    , pr_cdcritic OUT PLS_INTEGER                 --> Código da crítica
                                    , pr_dscritic OUT VARCHAR2                    --> Descrição da crítica
                                    , pr_retxml   IN OUT NOCOPY XMLType           --> Arquivo de retorno do XML
                                    , pr_nmdcampo OUT VARCHAR2                    --> Nome do campo com erro
                                    , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_busca_deb_efetivados
        Sistema : CECRED
        Sigla   : DEB
        Autor   : Elton (AMcom)
        Data    : Abril/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para buscar dados dos débitos efetivados
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

        -- Variaveis auxiliares
    vr_RegTotal    INTEGER :=0;
    vr_nrlinhas    INTEGER :=15;
    vr_auxinicial  INTEGER :=0;
    vr_auxfinal    INTEGER :=0 ;

           
    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis gerais da procedure
    vr_contcont INTEGER := 0; -- Contador para inserção dos dados no XML
    vr_contador INTEGER := 0;
 
    
      -- Tratamento de erros
 	    vr_des_erro   VARCHAR2(4000);
      vr_tab_erro   GENE0001.typ_tab_erro; 

    ----------->>> CURSORES <<<--------
     
   -- dados de debitos efetivados
     CURSOR cr_debitos_efetivados IS
    select * from (
    select  coope
           ,agencia
           ,conta
           ,associado
           ,vlrlancamento
           ,dtmvto
           ,historico
           ,ROW_NUMBER() OVER (ORDER BY conta, progress_recid) Row_Num
    from (
    SELECT craplcm.cdcooper coope,
           crapass.cdagenci agencia,
           craplcm.nrdconta conta,
           gene0007.fn_acento_xml(crapass.nmprimtl) associado, 
           craplcm.vllanmto vlrlancamento,
           to_char(craplcm.dtmvtolt,'dd/mm/yyyy') dtmvto,
           gene0007.fn_acento_xml(craphis.cdhistor||'-'||craphis.dshistor) historico,
           craplcm.progress_recid
    FROM craplcm , crapass , craphis , crapage
    WHERE craplcm.dtmvtolt = to_date(pr_dtmvtolt,'DD/MM/YYYY') -- pr_dtmvtolt   -- parametro tela
    AND craplcm.cdcooper   = pr_cdcooper 
    AND crapass.cdagenci   = pr_cdagenci 
    AND crapass.nrdconta   = nvl(pr_nrdconta,crapass.nrdconta)        
    AND craplcm.cdcooper   = crapass.cdcooper
    AND craplcm.nrdconta   = crapass.nrdconta
    AND craplcm.cdhistor   = craphis.cdhistor
    AND craplcm.cdcooper   = craphis.cdcooper
    AND craphis.indebcre   = 'D' --- indica debito
    AND craplcm.cdcooper   = crapage.cdcooper
    AND crapage.cdagenci   = crapass.cdagenci
     )   
         ) WHERE Row_Num BETWEEN vr_auxinicial AND vr_auxfinal;                	      
     
 
    rw_deb_efetivados cr_debitos_efetivados%ROWTYPE;    
    
BEGIN
    pr_des_erro := 'OK';

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Debitos',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    --- controle paginação da tela                           
    vr_auxinicial := ((pr_pagina - 1)*vr_nrlinhas) + 1;
    vr_auxfinal   := (pr_pagina* vr_nrlinhas);                           

     SELECT  count(*) INTO vr_RegTotal
     from (
       SELECT craplcm.cdcooper coope,
             crapass.cdagenci agencia,
             craplcm.nrdconta conta,
             crapass.nmprimtl associado,
             craplcm.vllanmto vlrlancamento,
             craplcm.dtmvtolt dtmvto,
             craphis.cdhistor||'-'||craphis.dshistor historico,
             craplcm.progress_recid
      FROM craplcm , crapass , craphis , crapage
      WHERE craplcm.dtmvtolt =  to_date(pr_dtmvtolt,'DD/MM/YYYY') --pr_dtmvtolt   -- parametro tela
      AND craplcm.cdcooper   = pr_cdcooper 
      AND crapass.cdagenci   = pr_cdagenci 
      AND crapass.nrdconta   = nvl(pr_nrdconta,crapass.nrdconta)             
      AND craplcm.cdcooper   = crapass.cdcooper
      AND craplcm.nrdconta   = crapass.nrdconta
      AND craplcm.cdhistor   = craphis.cdhistor
      AND craplcm.cdcooper   = craphis.cdcooper
      AND craphis.indebcre   = 'D' --- indica debito
      AND craplcm.cdcooper   = crapage.cdcooper
      AND crapage.cdagenci   = crapass.cdagenci
      );
 
    ---- fim count
    
--    dbms_output.put_line('total reg: '||vr_RegTotal);


    -- Percorre os DEBITOS
    FOR rw_deb_efetivados
      IN cr_debitos_efetivados LOOP
      
        
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Debitos',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Debito',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);

        -- conta do cooperado
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Debito',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'conta',
                               pr_tag_cont => rw_deb_efetivados.conta,
                               pr_des_erro => pr_dscritic);

        -- nome cooperado
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Debito',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'associado',
                               pr_tag_cont => rw_deb_efetivados.associado,
                               pr_des_erro => pr_dscritic);

      -- valor débito 
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Debito',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'vlrdebito',
                               pr_tag_cont => rw_deb_efetivados.vlrlancamento ,
                               pr_des_erro => pr_dscritic);       

     -- Data débito 
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Debito',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'Datadeb',
                               pr_tag_cont => rw_deb_efetivados.dtmvto ,
                               pr_des_erro => pr_dscritic);       
                               
     -- histórico (código e descrição) 
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Debito',
                               pr_posicao  => vr_contador,
                               pr_tag_nova => 'historico',
                               pr_tag_cont => rw_deb_efetivados.historico ,
                               pr_des_erro => pr_dscritic);                                      
                 
                               
     --- para teste
     --  Dbms_Output.put_line(' Reg: '||vr_contador||'-'||rw_deb_efetivados.dtmvto||'-'||rw_deb_efetivados.conta||'-'||rw_deb_efetivados.associado
     --    ||'-'||rw_deb_efetivados.vlrlancamento||'-'||rw_deb_efetivados.historico );

        vr_contador := vr_contador + 1;

    END LOOP;
    
    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'RgInicio'
                            ,pr_tag_cont => vr_auxinicial

                            ,pr_des_erro => vr_dscritic);


    gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'TmPagina'
                            ,pr_tag_cont => vr_nrlinhas
                            ,pr_des_erro => vr_dscritic);


     gene0007.pc_insere_tag(pr_xml      => pr_retxml
                            ,pr_tag_pai  => 'Root'
                            ,pr_posicao  => 0
                            ,pr_tag_nova => 'QtRegist'
                            ,pr_tag_cont => vr_RegTotal
                            ,pr_des_erro => vr_dscritic);	



    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := ' - pc_busca_deb_efetivados: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := ' - pc_busca_deb_efetivados: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_busca_deb_efetivados;

---------------------------


PROCEDURE pc_busca_progra_debitador(     pr_xmllog   IN VARCHAR2              --> XML com informações de LOG
                                       , pr_cdcritic OUT PLS_INTEGER          --> Código da crítica
                                       , pr_dscritic OUT VARCHAR2             --> Descrição da crítica
                                       , pr_retxml   IN OUT NOCOPY XMLType    --> Arquivo de retorno do XML
                                       , pr_nmdcampo OUT VARCHAR2             --> Nome do campo com erro
                                       , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_busca_debitador_progra
        Sistema : CECRED
        Sigla   : DEB
        Autor   : Elton (AMCOM)
        Data    : Abril/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para buscar programas debitador
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    -- Variáveis retornadas da gene0004.pc_extrai_dados
    vr_cdcooper INTEGER;
    vr_cdoperad VARCHAR2(100);
    vr_nmdatela VARCHAR2(100);
    vr_nmeacao  VARCHAR2(100);
    vr_cdagenci VARCHAR2(100);
    vr_nrdcaixa VARCHAR2(100);
    vr_idorigem VARCHAR2(100);

    -- Variáveis gerais da procedure
    vr_contador_pr    INTEGER := 0;    -- Para inserção dos dados de programa no XML

    ----------->>> CURSORES <<<--------

    -- Dados das prioridades (processos)
    CURSOR cr_dados_Programas IS
 SELECT    p.cdprocesso
          ,gene0007.fn_acento_xml(substr(p.dsprocesso,1,20)) dsprocReduzido
          ,gene0007.fn_acento_xml(p.dsprocesso) dsprocesso
          ,p.nrprioridade
         FROM TBGEN_DEBITADOR_PARAM p
        WHERE p.nrprioridade is not null
    ORDER BY substr(p.dsprocesso,1,20);
  
    rw_dados_Programas cr_dados_Programas%ROWTYPE;
		
	
BEGIN

    pr_des_erro := 'OK';

    -- Extrai dados do xml
    gene0004.pc_extrai_dados(pr_xml      => pr_retxml,
                             pr_cdcooper => vr_cdcooper,
                             pr_nmdatela => vr_nmdatela,
                             pr_nmeacao  => vr_nmeacao,
                             pr_cdagenci => vr_cdagenci,
                             pr_nrdcaixa => vr_nrdcaixa,
                             pr_idorigem => vr_idorigem,
                             pr_cdoperad => vr_cdoperad,
                             pr_dscritic => vr_dscritic);

    -- Se retornou alguma crítica
    IF TRIM(vr_dscritic) IS NOT NULL THEN
        -- Levanta exceção
        RAISE vr_exc_saida;
    END IF;

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Programas',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    -- Percorre os horários
    FOR rw_dados_Programas
      IN cr_dados_Programas LOOP
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Programas',
                               pr_posicao  => 0,
                               pr_tag_nova => 'Programa',
                               pr_tag_cont => NULL,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - cdprocesso
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Programa',
                               pr_posicao  => vr_contador_pr,
                               pr_tag_nova => 'cdprocesso',
                               pr_tag_cont => rw_dados_Programas.cdprocesso,
                               pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - dsprocesso
        gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                               pr_tag_pai  => 'Programa',
                               pr_posicao  => vr_contador_pr,
                               pr_tag_nova => 'dsprocReduzido',
                               pr_tag_cont => rw_dados_Programas.dsprocesso,
                               pr_des_erro => pr_dscritic);

 
														 
				

        vr_contador_pr := vr_contador_pr + 1;
    END LOOP;
		

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := 'Erro geral na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_progra_debitador: ' ||vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_progra_debitador: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_busca_progra_debitador;

PROCEDURE pc_busca_pa_conta(  pr_cdcooper IN crapcop.cdcooper%TYPE      --> Código da coopertiva
                            , pr_nrdconta IN crapass.nrdconta%TYPE      --> Conta
                            , pr_xmllog   IN VARCHAR2                   --> XML com informações de LOG
                            , pr_cdcritic OUT PLS_INTEGER               --> Código da crítica
                            , pr_dscritic OUT VARCHAR2                  --> Descrição da crítica
                            , pr_retxml   IN OUT NOCOPY XMLType         --> Arquivo de retorno do XML
                            , pr_nmdcampo OUT VARCHAR2                  --> Nome do campo com erro
                            , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_busca_pa_conta
        Sistema : CECRED
        Sigla   : DEB
        Autor   : Elton (AMCOM)
        Data    : Maio/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para validar conta cooperado
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Variáveis gerais da procedure
    vr_contador_pr    INTEGER := 0;    -- Para inserção dos dados de programa no XML
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    ----------->>> CURSORES <<<--------
  -- busca conta
    CURSOR cr_conta(pr_cdcooper IN crapass.cdcooper%TYPE,
                    pr_nrdconta IN crapass.nrdconta%TYPE)IS
      select a.inpessoa,
             a.cdagenci,
             a.nrdconta,
             a.vllimcre,
             a.nrcpfcgc,
             a.nmprimtl
      from crapass a
      where a.cdcooper = pr_cdcooper
      and a.nrdconta   = pr_nrdconta;

    rw_cr_conta cr_conta%ROWTYPE; 
	
BEGIN

    pr_des_erro := 'OK';

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Contas',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

    --VALIDAR CONTA
    OPEN cr_conta(pr_cdcooper => pr_cdcooper   
                 ,pr_nrdconta => pr_nrdconta );
    FETCH cr_conta INTO rw_cr_conta;     
        -- Se nao encontrar
    IF cr_conta%NOTFOUND THEN
          -- Fechar o cursor
          CLOSE cr_conta;       
          -- Montar mensagem de critica
          pr_cdcritic := 564;
          vr_dscritic := 'Conta nao cadastrada!';
          -- volta para o programa chamador
          RAISE vr_exc_saida;
    ELSE
          -- Fechar o cursor
          CLOSE cr_conta;   
    END IF;

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Contas',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Conta',
                           pr_tag_cont => rw_cr_conta.cdagenci,
                           pr_des_erro => pr_dscritic);

        -- Prioridade (Processo) - cdprocesso
/*    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Programa',
                           pr_posicao  => vr_contador_pr,
                           pr_tag_nova => 'PA',
                           pr_tag_cont => rw_cr_conta.cdagenci,
                           pr_des_erro => pr_dscritic); */

     --- para teste
     --Dbms_Output.put_line(' Reg: '||vr_contador_pr||'-'||pr_nrdconta||'-'||rw_cr_conta.cdagenci);
		

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_DEBITADOR_UNICO - pc_busca_pa_conta: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_busca_pa_conta;

PROCEDURE pc_valida_pa     (  pr_cdcooper IN crapcop.cdcooper%TYPE      --> Código da coopertiva
                            , pr_cdagenci IN crapass.cdagenci%TYPE      --> Código da agencia
                            , pr_xmllog   IN VARCHAR2                   --> XML com informações de LOG
                            , pr_cdcritic OUT PLS_INTEGER               --> Código da crítica
                            , pr_dscritic OUT VARCHAR2                  --> Descrição da crítica
                            , pr_retxml   IN OUT NOCOPY XMLType         --> Arquivo de retorno do XML
                            , pr_nmdcampo OUT VARCHAR2                  --> Nome do campo com erro
                            , pr_des_erro OUT VARCHAR2) IS

BEGIN

    /* ............................................................................
        Programa: pc_busca_pa_conta
        Sistema : CECRED
        Sigla   : DEB
        Autor   : Elton (AMCOM)
        Data    : Maio/2018                 Ultima atualizacao:

        Dados referentes ao programa:
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina para validar conta cooperado
        Observacao: -----
        Alteracoes:
    ..............................................................................*/

DECLARE

    ----------->>> VARIAVEIS <<<--------

    -- Variável de críticas
    vr_cdcritic crapcri.cdcritic%TYPE; --> Cód. Erro
    vr_dscritic VARCHAR2(1000);        --> Desc. Erro

    -- Variáveis gerais da procedure
    vr_contador_pr    INTEGER := 0;    -- Para inserção dos dados de programa no XML
    
    -- Tratamento de erros
    vr_exc_saida EXCEPTION;

    ----------->>> CURSORES <<<--------
  -- busca CRAPAGE
    CURSOR cr_crapage(pr_cdcooper  IN crapage.cdcooper%TYPE,
                      pr_cdagencia IN crapage.cdagenci%TYPE)IS
     select a.cdagenci
     from crapage a
     where a.cdcooper = pr_cdcooper and
           a.cdagenci = pr_cdagencia;

    rw_crapage cr_crapage%ROWTYPE;

	
BEGIN

    pr_des_erro := 'OK';

    -- Criar cabeçalho do XML de retorno
    pr_retxml := XMLType.createXML('<?xml version="1.0" encoding="ISO-8859-1" ?><Root/>');
    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Root',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Agencias',
                           pr_tag_cont => NULL,
                           pr_des_erro => vr_dscritic);

  --> Buscar crapage
    OPEN cr_crapage(pr_cdcooper  => pr_cdcooper,
                    pr_cdagencia => pr_cdagenci);
    FETCH cr_crapage INTO rw_crapage;     
    -- Se nao encontrar
    IF cr_crapage%NOTFOUND THEN
      -- Fechar o cursor
      CLOSE cr_crapage;       
      -- Montar mensagem de critica
      pr_cdcritic := 0;
      vr_dscritic := 'PA não cadastrado!';
      -- volta para o programa chamador
      RAISE vr_exc_saida;
    ELSE
      -- Fechar o cursor
      CLOSE cr_crapage;   
    END IF;

    gene0007.pc_insere_tag(pr_xml      => pr_retxml,
                           pr_tag_pai  => 'Agencias',
                           pr_posicao  => 0,
                           pr_tag_nova => 'Agencia',
                           pr_tag_cont => rw_crapage.cdagenci,
                           pr_des_erro => pr_dscritic);

     --- para teste
     --Dbms_Output.put_line(' Reg: '||vr_contador_pr||'-'||rw_crapage.cdagenci);
		

    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_dscritic := vr_dscritic;
        -- Carregar XML padrao para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
      WHEN OTHERS THEN
        pr_dscritic := 'Erro não tratado na rotina da tela TELA_DEBITADOR_UNICO - pc_valida_pa: ' || SQLERRM;
        -- Carregar XML padrão para variavel de retorno
        pr_retxml := XMLTYPE.CREATEXML('<?xml version="1.0" encoding="ISO-8859-1" ?> ' ||
                                           '<Root><Erro>' || pr_dscritic || '</Erro></Root>');
    END;
END pc_valida_pa;

END TELA_DEB_PEN_EFETIVADOS;
/
