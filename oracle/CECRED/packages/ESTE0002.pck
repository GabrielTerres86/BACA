CREATE OR REPLACE PACKAGE CECRED.ESTE0002 is
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : ESTE0002
      Sistema  : Rotinas referentes a comunica��o com a ESTEIRA de CREDITO da IBRATAN
      Sigla    : CADA
      Autor    : Odirlei Busana - AMcom
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a comunica��o com a ESTEIRA de CREDITO da IBRATAN - Motor de Credito

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  
  PROCEDURE pc_gera_json_pessoa_ass(pr_cdcooper IN crapass.cdcooper%TYPE
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE
																	 ,pr_flprepon IN BOOLEAN DEFAULT FALSE
                                   ,pr_dsjsonan OUT json
                                   ,pr_cdcritic OUT NUMBER
                                   ,pr_dscritic OUT VARCHAR2);
  
  PROCEDURE pc_gera_json_pessoa_avt ( pr_rw_crapavt  IN crapavt%ROWTYPE,        --> Dados do avalista
                                      ---- OUT ----
                                      pr_dsjsonavt OUT NOCOPY json,             --> Retorno do clob em modelo json dos dados do avalista
                                      pr_cdcritic  OUT NUMBER,                  --> Codigo da critica
                                      pr_dscritic  OUT VARCHAR2);               --> Descricao da critica
                                   
  --> Rotina responsavel por montar o objeto json para analise
  PROCEDURE pc_gera_json_analise ( pr_cdcooper   IN crapass.cdcooper%TYPE   --> Codigo da cooperativa
                                  ,pr_cdagenci   IN crapass.cdagenci%TYPE   --> Codigo da cooperativa
                                  ,pr_nrdconta   IN crapass.nrdconta%TYPE   --> Codigo da cooperativa
                                  ,pr_nrctremp   IN crapepr.nrctremp%TYPE   --> Codigo da cooperativa
                                  ,pr_nrctaav1   IN crapepr.nrctaav1%TYPE   --> Codigo da cooperativa
                                  ,pr_nrctaav2   IN crapepr.nrctaav2%TYPE   --> Codigo da cooperativa
                                  ---- OUT ----
                                  ,pr_dsjsonan  OUT NOCOPY json             --> Retorno do clob em modelo json com os dados para analise
                                  ,pr_cdcritic  OUT NUMBER                  --> Codigo da critica
                                  ,pr_dscritic  OUT VARCHAR2);              --> Descricao da critica
  
						

									
END ESTE0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.ESTE0002 IS
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : ESTE0002
      Sistema  : Rotinas referentes a comunica��o com a ESTEIRA de CREDITO da IBRATAN
      Sigla    : CADA
      Autor    : Odirlei Busana - AMcom
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a comunica��o com a ESTEIRA de CREDITO da IBRATAN - Motor de credito

      Alteracoes:

  ---------------------------------------------------------------------------------------------------------------*/
  
  --> Rotina para retornar descri��o do grau escolar
  FUNCTION fn_des_grescola (pr_grescola  IN NUMBER) 
                            RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_grescola        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descri��o do grau escolar
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    -----------> VARIAVEIS <-----------
    vr_dsgresco VARCHAR2(100) := NULL;
    
  BEGIN
    SELECT CASE pr_grescola 
             WHEN 1 THEN 'NAO ALFABETIZAD'
             WHEN 2 THEN 'ENS.FUNDAMENTAL'
             WHEN 3 THEN 'ENSINO MEDIO'
             WHEN 4 THEN 'SUP.INCOMPLETO'
             WHEN 5 THEN 'SUP.COMPLETO'
             WHEN 6 THEN 'POS GRADUADO'
             WHEN 7 THEN 'MESTRADO'
             WHEN 8 THEN 'DOUTORADO'
             WHEN 9 THEN 'SUP.ANDAMENTO'
             ELSE NULL
           END CASE  
      INTO vr_dsgresco FROM dual;         
      
      RETURN vr_dsgresco;
      
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_des_grescola; 
  
  --> Rotina para retornar descri��o de forma��o
  FUNCTION fn_des_cdfrmttl (pr_cdfrmttl  IN NUMBER) --> codigo da formacao. 
                            RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_cdfrmttl        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descri��o de forma��o
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    CURSOR cr_gncdfrm IS
      SELECT dsfrmttl 
        FROM gncdfrm 
        WHERE cdfrmttl = pr_cdfrmttl;
    rw_gncdfrm cr_gncdfrm%ROWTYPE;
    
    
    -----------> VARIAVEIS <-----------   
    
  BEGIN
    
   OPEN cr_gncdfrm;
   FETCH cr_gncdfrm INTO rw_gncdfrm;
   CLOSE cr_gncdfrm;
   
   RETURN rw_gncdfrm.dsfrmttl;
  
      
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_des_cdfrmttl; 
  
  --> Rotina para retornar descri��o do tipos de naturezas de ocupacao
  FUNCTION fn_des_cdnatopc (pr_cdnatocp  IN NUMBER) --> Codigo da natureza de ocupacao.  
                            RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_cdnatopc        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descri��o do tipos de naturezas de ocupacao
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    CURSOR cr_gncdnto IS
      SELECT rsnatocp 
        FROM gncdnto
       WHERE cdnatocp = pr_cdnatocp;
    rw_gncdnto cr_gncdnto%ROWTYPE;
    
    -----------> VARIAVEIS <-----------   
    
  BEGIN
    
   OPEN cr_gncdnto;
   FETCH cr_gncdnto INTO rw_gncdnto;
   CLOSE cr_gncdnto;
   
   RETURN rw_gncdnto.rsnatocp;
  
      
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_des_cdnatopc; 
  
  --> Rotina para retornar descri��o da ocupac�o.
  FUNCTION fn_des_cdocupa (pr_cdocupa  IN NUMBER) --> codigo da ocupacao. 
                            RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_cdocupa        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descri��o da ocupac�o.
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    CURSOR cr_gncdocp IS
      SELECT rsdocupa 
        FROM gncdocp
       WHERE cdocupa = pr_cdocupa;
    rw_gncdocp cr_gncdocp%ROWTYPE;
    
    -----------> VARIAVEIS <-----------   
    
  BEGIN
    
   OPEN cr_gncdocp;
   FETCH cr_gncdocp INTO rw_gncdocp;
   CLOSE cr_gncdocp;
   
   RETURN rw_gncdocp.rsdocupa;
  
      
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_des_cdocupa;
  
  --> Rotina para retornar descri��o do turno
  FUNCTION fn_des_cdturnos (pr_cdturnos  IN NUMBER) --> Codigo do turno
                            RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_cdturnos        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descri��o do turno.
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------    
    
    -----------> VARIAVEIS <-----------   
    vr_dsdturno VARCHAR2(100) := NULL;
    
  BEGIN

    
    SELECT CASE pr_cdturnos 
             WHEN 1 THEN 'PRIMEIRO TURNO'
             WHEN 2 THEN 'SEGUNDO TURNO'
             WHEN 3 THEN 'TERCEIRO TURNO'
             WHEN 4 THEN 'GERAL'
             ELSE NULL
           END CASE  
      INTO vr_dsdturno FROM dual;         
      
      RETURN vr_dsdturno;
  
      
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_des_cdturnos; 
  
  
  --> Rotina para retornar descri��o do nivel do cargo.
  FUNCTION fn_des_cdnvlcgo (pr_cdnvlcgo  IN NUMBER) --> Codigo do nivel do cargo
                            RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_cdnvlcgo        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descri��o do nivel do cargo.
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------    
    
    -----------> VARIAVEIS <-----------   
    vr_dsdnivel VARCHAR2(100) := NULL;
    
  BEGIN

    
    SELECT CASE pr_cdnvlcgo 
             WHEN 1 THEN 'DIRECAO'
             WHEN 2 THEN 'GERENCIA'
             WHEN 3 THEN 'SUPERVISAO'
             WHEN 4 THEN 'ASSES/TECN'
             WHEN 5 THEN 'EXECUCAO'
             WHEN 6 THEN 'SEM NIVEL'              
             ELSE NULL
           END CASE  
      INTO vr_dsdnivel FROM dual;         
      
      RETURN vr_dsdnivel;
  
      
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_des_cdnvlcgo; 
  
  --> Rotina para retornar descri��o do tipo de contrato de trabalho
  FUNCTION fn_des_tpcttrab (pr_tpcttrab  IN NUMBER) --> Codigo tipo de contrato de trabalho
                            RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_tpcttrab        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descri��o do tipo de contrato de trabalho
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------    
    
    -----------> VARIAVEIS <-----------   
    vr_dstipctr VARCHAR2(100) := NULL;
    
  BEGIN
    
    SELECT CASE pr_tpcttrab 
             WHEN 1 THEN 'PERMANENTE'
             WHEN 2 THEN 'TEMP/TERCEIRO'
             WHEN 3 THEN 'SEM VINCULO'            
             ELSE NULL
           END CASE  
      INTO vr_dstipctr FROM dual;         
      
      RETURN vr_dstipctr;
  
      
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_des_tpcttrab; 
  
  
  --> Rotina para retornar descri��o do estado civil
  FUNCTION fn_des_cdestciv (pr_cdestciv  IN NUMBER) --> Codigo do estado civil
                            RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_cdestciv        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descri��o do estado civil
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------    
    
    -----------> VARIAVEIS <-----------   
    vr_dsestciv VARCHAR2(100) := NULL;
    
  BEGIN
    
    SELECT CASE pr_cdestciv 
             WHEN  1 THEN 'SOLTEIRO(A)'
             WHEN  2 THEN 'CASADO(A)-COMUNHAO UNIVERSAL'
             WHEN  3 THEN 'CASADO(A)-COMUNHAO PARCIAL'
             WHEN  4 THEN 'CASADO(A)-SEPARACAO DE BENS'
             WHEN  5 THEN 'VIUVO(A)'
             WHEN  6 THEN 'SEPARADO(A) JUDICIALMENTE'
             WHEN  7 THEN 'DIVORCIADO(A)'
             WHEN  8 THEN 'CASADO(A)-REGIME TOTAL'
             WHEN  9 THEN 'CAS REGIME MISTO OU ESPECIAL'
             WHEN 11 THEN 'CASADO(A)-PART.FINAL AQUESTOS'
             ELSE NULL
           END CASE  
      INTO vr_dsestciv FROM dual;         
      
      RETURN vr_dsestciv;
        
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_des_cdestciv;
  
  
  --> Rotina para retornar descri��o de indicador de menor
  FUNCTION fn_des_inhabmen (pr_inhabmen  IN NUMBER) --> indicador de menor
                            RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_inhabmen        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descri��o de indicador de menor
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------    
    
    -----------> VARIAVEIS <-----------   
    vr_dsindmen VARCHAR2(100) := NULL;
    
  BEGIN
    
    SELECT CASE pr_inhabmen    
             WHEN  0 THEN 'menor/maior'
             WHEN  1 THEN 'menor emancipado'
             WHEN  2 THEN 'incapacidade civil'
             ELSE NULL
           END CASE  
      INTO vr_dsindmen FROM dual;         
      
      RETURN vr_dsindmen;
        
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_des_inhabmen;
  
  
  
  --> Rotina para retornar descri��o do tipo de conta
  FUNCTION fn_des_cdtipcta (pr_cdtipcta  IN NUMBER) --> Codigo do tipo de conta
                            RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_cdtipcta        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descri��o do tipo de conta
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------    
    
    -----------> VARIAVEIS <-----------   
    vr_dstipcta VARCHAR2(100) := NULL;
    
  BEGIN
    
    SELECT CASE pr_cdtipcta 
             WHEN  1 THEN 'NORMAL'
             WHEN  2 THEN 'ESPECIAL'
             WHEN  3 THEN 'NORMAL CONJUNTA'
             WHEN  4 THEN 'ESPEC. CONJUNTA'
             WHEN  5 THEN 'CHEQUE SALARIO'
             WHEN  6 THEN 'CTA APLIC CONJ.'
             WHEN  7 THEN 'CTA APLIC INDIV'
             WHEN  8 THEN 'NORMAL CONVENIO'
             WHEN  9 THEN 'ESPEC. CONVENIO'
             WHEN 10 THEN 'CONJ. CONVENIO'
             ELSE NULL
           END CASE  
      INTO vr_dstipcta FROM dual;         
      
      RETURN vr_dstipcta;
        
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_des_cdtipcta;
  
  --> Rotina para retornar descri��o de situacao da conta
  FUNCTION fn_des_cdsitdct (pr_cdsitdct  IN NUMBER) --> Codigo de situacao da conta
                            RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_cdsitdct        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descri��o de situacao da conta
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------    
    
    -----------> VARIAVEIS <-----------   
    vr_dssitcta VARCHAR2(100) := NULL;
    
  BEGIN
    
    SELECT CASE pr_cdsitdct 
             WHEN  1 THEN 'Nor'
             WHEN  2 THEN 'Enc.Ass'
             WHEN  3 THEN 'Enc.COOP'
             WHEN  4 THEN 'Enc.Dem'
             WHEN  5 THEN 'Nao aprov'
             WHEN  6 THEN 'S/Tal'
             WHEN  9 THEN 'Outr'
             ELSE NULL
           END CASE  
      INTO vr_dssitcta FROM dual;         
      
      RETURN vr_dssitcta;
        
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_des_cdsitdct;
  
  --> Rotina para retornar descri��o de indicador
  FUNCTION fn_des_incasprp (pr_incasprp  IN NUMBER) --> Codigo indicador
                            RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_incasprp        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descri��o de indicador
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------    
    
    -----------> VARIAVEIS <-----------   
    vr_dscasprp VARCHAR2(100) := NULL;
    
  BEGIN
    
    SELECT CASE pr_incasprp 
             WHEN  1 THEN 'quitado'
             WHEN  2 THEN 'financ'
             WHEN  3 THEN 'alugado'
             WHEN  4 THEN 'familiar'
             WHEN  5 THEN 'cedido'
             ELSE NULL
           END CASE  
      INTO vr_dscasprp FROM dual;         
      
      RETURN vr_dscasprp;
        
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_des_incasprp;
  
  --> Rotina para retornar descri��o da situa��o do CPF
  FUNCTION fn_des_cdsitcpf (pr_cdsitcpf  IN NUMBER) --> Codigo da situa��o do CPF
                            RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_cdsitcpf        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descri��o da situa��o do CPF
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------    
    
    -----------> VARIAVEIS <-----------   
    vr_dssitcpf VARCHAR2(100) := NULL;
    
  BEGIN
    
    SELECT CASE pr_cdsitcpf 
             WHEN  1 THEN 'Reg.'
             WHEN  2 THEN 'Pend.'
             WHEN  3 THEN 'Cancel.'
             WHEN  4 THEN 'Irreg.'
             WHEN  5 THEN 'Susp.'
             ELSE NULL
           END CASE  
      INTO vr_dssitcpf FROM dual;         
      
      RETURN vr_dssitcpf;
        
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_des_cdsitcpf;
  
  --> Rotina para retornar descri��o de cadastro positivo
  FUNCTION fn_des_incadpos (pr_incadpos  IN NUMBER) --> Codigo cadastro positivo
                            RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_incadpos        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descri��o de cadastro positivo
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------    
    
    -----------> VARIAVEIS <-----------   
    vr_dscadpos VARCHAR2(100) := NULL;
    
  BEGIN
    
    SELECT CASE pr_incadpos 
             WHEN 3 THEN 'Cancelado'
             WHEN 2 THEN 'Autorizado'
             ELSE 'Nao Autorizado'
           END CASE  
      INTO vr_dscadpos FROM dual;         
      
      RETURN vr_dscadpos;
        
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_des_incadpos;
  
  --> Rotina para retornar descri��o de atraso
  FUNCTION fn_des_pontualidade (pr_qtdiaatr  IN NUMBER) --> qtd dias de atraso
                                RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_incadpos        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descri��o de atraso
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------    
    
    -----------> VARIAVEIS <-----------   
    
  BEGIN
    
    IF nvl(pr_qtdiaatr,0) = 0 THEN
      RETURN 'S';
    ELSIF pr_qtdiaatr < 60 THEN
      RETURN 'A';
    ELSE 
      RETURN 'M';
    END IF;
        
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_des_pontualidade;
  
  
  PROCEDURE pc_gera_json_pessoa_ass(pr_cdcooper IN crapass.cdcooper%TYPE
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE
																	 ,pr_flprepon IN BOOLEAN DEFAULT FALSE
                                   ,pr_dsjsonan OUT json
                                   ,pr_cdcritic OUT NUMBER
                                   ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /* ..........................................................................
      
        Programa : pc_gera_json_pessoa_ass
        Sistema  : Conta-Corrente - Cooperativa de Credito
        Sigla    : CRED
        Autor    : Lucas Reinert
        Data     : Maio/2017.                    Ultima atualizacao: 
      
        Dados referentes ao programa:
      
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina responsavel por buscar todas as informa��es cadastrais
                    e das opera��es da conta parametrizada.
      
        Altera��o : 
          
    ..........................................................................*/
    DECLARE
      -- Vari�veis para exce��es
      vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_exc_saida EXCEPTION;
			vr_des_reto VARCHAR2(3);
			vr_tab_erro GENE0001.typ_tab_erro;
    
      -- Declarar objetos Json necess�rios:
      vr_obj_generico  json := json();
      vr_obj_generic2  json := json();
      vr_obj_generic3  json := json();			
      vr_obj_responsav json := json();
      vr_lst_generic2  json_list := json_list();
			vr_lst_generic3  json_list := json_list();
			
			-- Vari�veis auxiliares
			vr_tpcmpvrn VARCHAR2(100);
			vr_dstextab craptab.dstextab%TYPE;
			vr_nmseteco craptab.dstextab%TYPE;
			vr_qtdopliq VARCHAR2(10);
			vr_flliquid BOOLEAN;
			vr_flprjcop BOOLEAN;
			vr_fl800900 BOOLEAN;
			vr_vladtdep crapsda.vllimcre%TYPE;
			vr_flggrupo INTEGER;
			vr_nrdgrupo crapgrp.nrdgrupo%TYPE;
			vr_gergrupo VARCHAR2(100);
			vr_dsdrisgp crapgrp.dsdrisgp%TYPE;
			vr_temcotas BOOLEAN;
			vr_temdebaut BOOLEAN;
			vr_vlsldtot NUMBER;
			vr_ind      PLS_INTEGER;
			vr_vlsldapl craprda.vlsdrdca%TYPE := 0;
			vr_vlsldrgt NUMBER;
			vr_percenir NUMBER;
			vr_vlsldppr NUMBER;
			vr_flgativo INTEGER;
			vr_nrctrhcj NUMBER;
			vr_flgliber INTEGER;
			vr_vltotccr NUMBER;
			vr_vlutiliz NUMBER;
			vr_ind_coresp VARCHAR2(100);
			vr_ind_coresp2 VARCHAR2(100);
			vr_qtmesdec NUMBER(10);
			vr_qtpreemp INTEGER;
			vr_qtprecal NUMBER(10);
			vr_tot_vlsdeved NUMBER(25, 10) := 0;
			vr_tot_qtprecal NUMBER := 0;
			vr_nratrmai NUMBER(25,10);
      vr_vltotatr NUMBER(25,10);
      vr_qtpclatr NUMBER;
      vr_qtpclpag NUMBER;
			vr_idxempr  VARCHAR2(100);
			vr_vlsdeved NUMBER;
			vr_dias     NUMBER;
      vr_inusatab BOOLEAN;
			vr_dstextab_parempctl craptab.dstextab%TYPE;
			vr_dstextab_digitaliza craptab.dstextab%TYPE;
			vr_qtregist INTEGER;
			vr_vlsalari crapcje.vlsalari%TYPE;
			vr_vltotpre NUMBER(25,2);
			vr_vlmedfat NUMBER;
			vr_vlendivi NUMBER;
			vr_qtmesest crapprm.dsvlrprm%TYPE;
			vr_qtmeschq crapprm.dsvlrprm%TYPE;	
			vr_qthisemp crapprm.dsvlrprm%TYPE;	
			vr_qqdiacheq NUMBER;
			
			--PlTables auxiliares
			vr_tab_sald                EXTR0001.typ_tab_saldos;
			vr_tab_medias              EXTR0001.typ_tab_medias;
			vr_tab_comp_medias         EXTR0001.typ_tab_comp_medias;
			vr_tab_ocorren             CADA0004.typ_tab_ocorren;
			vr_tab_saldo_rdca          APLI0001.typ_tab_saldo_rdca;
			vr_tab_conta_bloq          APLI0001.typ_tab_ctablq;
			vr_tab_craplpp             APLI0001.typ_tab_craplpp;
			vr_tab_craplrg             APLI0001.typ_tab_craplpp;
			vr_tab_resgate             APLI0001.typ_tab_resgate;
			vr_tab_dados_rpp           APLI0001.typ_tab_dados_rpp;
			vr_tab_cartoes             CADA0004.typ_tab_cartoes;
			vr_tab_co_responsavel      EMPR0001.typ_tab_dados_epr;
			vr_tab_co_responsavel_ord  EMPR0001.typ_tab_dados_epr;
			vr_tab_dados_epr           EMPR0001.typ_tab_dados_epr;
			vr_vet_nrctrliq            RATI0001.typ_vet_nrctrliq := RATI0001.typ_vet_nrctrliq(0,0,0,0,0,0,0,0,0,0);
			
      --Tipo de registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
      -- Cursor para endere�o
      CURSOR cr_crapenc(pr_tpendass crapenc.tpendass%TYPE) IS
        SELECT enc.dsendere
              ,enc.nrendere
              ,enc.complend
              ,enc.nmbairro
              ,enc.nmcidade
              ,enc.cdufende
              ,enc.nrcepend
              ,enc.nrcxapst
              ,enc.incasprp
              ,enc.vlalugue
              ,enc.dtinires
          FROM crapenc enc
         WHERE enc.cdcooper = pr_cdcooper
           AND enc.nrdconta = pr_nrdconta
           AND enc.tpendass = pr_tpendass;
      rw_crapenc cr_crapenc%ROWTYPE;
    
      -- Cursor para telefones:
      CURSOR cr_craptfc IS
        SELECT tfc.tptelefo
              ,tfc.nrdddtfc
              ,tfc.nrtelefo
          FROM craptfc tfc
         WHERE tfc.cdcooper = pr_cdcooper
           AND tfc.nrdconta = pr_nrdconta
           AND tfc.tptelefo IN (1, 2, 3); /* Residencial, Celular e Comercial */
    
      -- Busca no cadastro do associado:
      CURSOR cr_crapass IS
        SELECT ass.nrdconta
              ,ass.nrcpfcgc
              ,ass.cdagenci
              ,ass.dtnasctl
              ,ass.nrmatric
              ,ass.cdtipcta
              ,ass.cdsitdct
              ,ass.dtcnsscr
              ,ass.inlbacen
              ,decode(ass.incadpos,1,'Nao Autorizado',2,'Autorizado','Cancelado') incadpos
              ,ass.dtelimin
              ,ass.inccfcop
              ,ass.dtcnsspc
              ,ass.dtdsdspc
              ,ass.inadimpl
              ,ass.cdsitdtl
              ,ass.inpessoa
							,ass.dtcnscpf
							,ass.cdsitcpf
							,ass.cdclcnae
							,ass.vllimcre
							,ass.nmprimtl
							,ass.dtadmiss
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
    
      -- Buscaremos informa��es da proposta de empr�stimo em aprova��o
      CURSOR cr_crawepr IS
        SELECT epr.nrctrliq##1
              ,epr.nrctrliq##2
              ,epr.nrctrliq##3
              ,epr.nrctrliq##4
              ,epr.nrctrliq##5
              ,epr.nrctrliq##6
              ,epr.nrctrliq##7
              ,epr.nrctrliq##8
              ,epr.nrctrliq##9
              ,epr.nrctrliq##10
							,TO_CHAR(NRCTRLIQ##1) || ',' || TO_CHAR(NRCTRLIQ##2) || ',' ||
               TO_CHAR(NRCTRLIQ##3) || ',' || TO_CHAR(NRCTRLIQ##4) || ',' ||
               TO_CHAR(NRCTRLIQ##5) || ',' || TO_CHAR(NRCTRLIQ##6) || ',' ||
               TO_CHAR(NRCTRLIQ##7) || ',' || TO_CHAR(NRCTRLIQ##8) || ',' ||
               TO_CHAR(NRCTRLIQ##9) || ',' || TO_CHAR(NRCTRLIQ##10) dsliquid
							,epr.vlpreemp
							,epr.vlemprst
          FROM crawepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;
			
      -- Buscar informa��es do primeiro titular 
      CURSOR cr_crapttl IS
        SELECT ttl.nmextttl
              ,ttl.dtcnscpf
              ,ttl.cdsitcpf
              ,ttl.tpdocttl
              ,ttl.nrdocttl
              ,ttl.cdoedttl
              ,ttl.dtnasttl
              ,ttl.cdsexotl
              ,ttl.tpnacion
              ,ttl.dsnacion
              ,ttl.dsnatura || '-' || ttl.cdufnatu dsnatura
              ,ttl.dthabmen
              ,ttl.cdestcvl
              ,ttl.cdgraupr
              ,ttl.cdfrmttl
              ,ttl.nmmaettl
              ,ttl.nmpaittl
              ,ttl.cdnatopc
              ,ttl.cdocpttl
              ,ttl.tpcttrab
              ,ttl.cdempres
              ,ttl.nrcpfemp
              ,ttl.dsproftl
              ,ttl.cdnvlcgo
              ,ttl.nrcadast
              ,ttl.cdturnos
              ,ttl.inpolexp
              ,ttl.dtadmemp
              ,ttl.vlrendim
              ,ttl.vldrendi##1 + ttl.vldrendi##2 + ttl.vldrendi##3 +
               ttl.vldrendi##4 + ttl.vldrendi##5 + ttl.vldrendi##6 vroutrorn
							,ttl.inhabmen
							,ttl.grescola
              ,ass.dtcnsscr
              ,ass.inlbacen
              ,ass.incadpos
              ,ass.dtelimin
              ,ass.dtcnsspc
              ,ass.dtdsdspc
              ,ass.inadimpl
              ,ass.cdsitdtl
          FROM crapttl ttl
              ,crapass ass
         WHERE ttl.cdcooper = pr_cdcooper
           AND ttl.nrdconta = pr_nrdconta
           AND ttl.idseqttl = 1
           AND ass.cdcooper = ttl.cdcooper
           AND ass.nrdconta = ttl.nrdconta;
      rw_crapttl cr_crapttl%ROWTYPE;
    
      -- Buscar dados do titular pessoa juridical
      CURSOR cr_crapjur IS
        SELECT jur.nmextttl
              ,jur.nmfansia
              ,jur.natjurid
              ,jur.qtfilial
              ,jur.qtfuncio
              ,jur.cdseteco
              ,jur.cdrmativ
              ,jur.vlfatano
              ,jur.vlcaprea
              ,jur.dtregemp
              ,jur.nrregemp
              ,jur.orregemp
              ,jur.dtinsnum
              ,jur.nrinsmun
              ,jur.nrinsest
              ,jur.flgrefis
              ,jur.nrcdnire
          FROM crapjur jur
         WHERE jur.cdcooper = pr_cdcooper
           AND jur.nrdconta = pr_nrdconta;
      rw_crapjur cr_crapjur%ROWTYPE;
    
      -- Libera Pr� Aprovado
      CURSOR cr_preapv IS
        SELECT flglibera_pre_aprv
          FROM tbepr_param_conta
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      vr_flglibera_pre_aprv tbepr_param_conta.flglibera_pre_aprv%TYPE;
    
      -- Data Ultima Revis�o Cadastral
      CURSOR cr_revisa IS
        SELECT MAX(crapalt.dtaltera)
          FROM crapalt
         WHERE crapalt.cdcooper = pr_cdcooper
           AND crapalt.nrdconta = pr_nrdconta
           AND crapalt.tpaltera = 1;
      vr_dtaltera DATE;
    
      -- Conta tem Alerta
      CURSOR cr_alerta IS
        SELECT 1
          FROM crapcrt
         WHERE nrcpfcgc = rw_crapass.nrcpfcgc
           AND cdsitreg = 1 --> Inserido
           AND dtexclus IS NULL;
      vr_indexis NUMBER;
    
      -- Quantidade de Dependentes
      CURSOR cr_depend IS
        SELECT COUNT(1)
          FROM crapdep
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      vr_qtdepend NUMBER;
			
			-- Pegar salario do Conjuge
			CURSOR cr_crapcje (pr_cdcooper IN crapnrc.cdcooper%type
												,pr_nrdconta IN crapnrc.nrdconta%type) IS
				SELECT nvl(sum(nvl(vlsalari,0)),0) vlsalari
					FROM crapcje
				 WHERE crapcje.cdcooper = pr_cdcooper
					 AND crapcje.nrdconta = pr_nrdconta
					 AND crapcje.idseqttl = 1;
			rw_crapcje cr_crapcje%rowtype;
			    
      -- Buscar descri��o
      CURSOR cr_nature(pr_natjurid IN crapjur.natjurid%TYPE) IS
        SELECT gncdntj.dsnatjur
          FROM gncdntj
         WHERE gncdntj.cdnatjur = pr_natjurid;
      vr_dsnatjur gncdntj.dsnatjur%TYPE;
		
	    -- Buscar descri��o
			CURSOR cr_ramatv(pr_cdseteco IN gnrativ.cdseteco%TYPE
			                ,pr_cdrmativ IN gnrativ.cdrmativ%TYPE) IS
				SELECT gnrativ.nmrmativ
					FROM gnrativ
				 WHERE gnrativ.cdseteco  = pr_cdseteco
					 AND gnrativ.cdrmativ = pr_cdrmativ;    
			vr_dsramatv gnrativ.nmrmativ%type;
		
      -- Buscar descri��o
      CURSOR cr_cnae(pr_cdclcnae IN crapass.cdclcnae%TYPE) IS
        SELECT dscnae
          FROM tbgen_cnae
         WHERE cdcnae = pr_cdclcnae;
      vr_dscnae tbgen_cnae.dscnae%TYPE;
    
      -- Buscar informa��es de faturamento 
      CURSOR cr_crapjfn IS
        SELECT jfn.perfatcl
              ,to_date('01' || to_char(jfn.mesftbru##1, 'fm00') ||
                       jfn.anoftbru##1
                      ,'ddmmrrrr') dtfatme1
              ,to_date('01' || to_char(jfn.mesftbru##2, 'fm00') ||
                       jfn.anoftbru##2
                      ,'ddmmrrrr') dtfatme2
              ,to_date('01' || to_char(jfn.mesftbru##3, 'fm00') ||
                       jfn.anoftbru##3
                      ,'ddmmrrrr') dtfatme3
              ,to_date('01' || to_char(jfn.mesftbru##4, 'fm00') ||
                       jfn.anoftbru##4
                      ,'ddmmrrrr') dtfatme4
              ,to_date('01' || to_char(jfn.mesftbru##5, 'fm00') ||
                       jfn.anoftbru##5
                      ,'ddmmrrrr') dtfatme5
              ,to_date('01' || to_char(jfn.mesftbru##6, 'fm00') ||
                       jfn.anoftbru##6
                      ,'ddmmrrrr') dtfatme6
              ,to_date('01' || to_char(jfn.mesftbru##7, 'fm00') ||
                       jfn.anoftbru##7
                      ,'ddmmrrrr') dtfatme7
              ,to_date('01' || to_char(jfn.mesftbru##8, 'fm00') ||
                       jfn.anoftbru##8
                      ,'ddmmrrrr') dtfatme8
              ,to_date('01' || to_char(jfn.mesftbru##9, 'fm00') ||
                       jfn.anoftbru##9
                      ,'ddmmrrrr') dtfatme9
              ,to_date('01' || to_char(jfn.mesftbru##10, 'fm00') ||
                       jfn.anoftbru##10
                      ,'ddmmrrrr') dtfatme10
              ,to_date('01' || to_char(jfn.mesftbru##11, 'fm00') ||
                       jfn.anoftbru##11
                      ,'ddmmrrrr') dtfatme11
              ,to_date('01' || to_char(jfn.mesftbru##12, 'fm00') ||
                       jfn.anoftbru##12
                      ,'ddmmrrrr') dtfatme12
              ,jfn.vlrftbru##1
              ,jfn.vlrftbru##2
              ,jfn.vlrftbru##3
              ,jfn.vlrftbru##4
              ,jfn.vlrftbru##5
              ,jfn.vlrftbru##6
              ,jfn.vlrftbru##7
              ,jfn.vlrftbru##8
              ,jfn.vlrftbru##9
              ,jfn.vlrftbru##10
              ,jfn.vlrftbru##11
              ,jfn.vlrftbru##12
          FROM crapjfn jfn
         WHERE jfn.cdcooper = pr_cdcooper
           AND jfn.nrdconta = pr_nrdconta;
      rw_crapjfn cr_crapjfn%ROWTYPE;
    
      -- Buscar ultimas opera��es de Cr�dito Liquidadas      
      CURSOR cr_crapepr IS
        SELECT epr.nrctremp
              ,epr.vlemprst
							,epr.dtmvtolt
              ,epr.qtpreemp
              ,epr.vlpreemp
              ,epr.cdlcremp
							,lcr.dslcremp
              ,epr.cdfinemp
							,fin.dsfinemp
							,ROWNUM
          FROM crapepr epr
              ,craplcr lcr
              ,crapfin fin
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.inliquid = 1 -- Somente liquidadas
           AND lcr.cdcooper = epr.cdcooper
           AND lcr.cdlcremp = epr.cdlcremp
           AND lcr.flglispr = 1 -- Somente as que listam na proposta
           AND fin.cdcooper = epr.cdcooper
           AND fin.cdfinemp = epr.cdfinemp
         ORDER BY epr.dtultpag DESC;
    
      -- Busca data da Liquida��o        
      CURSOR cr_dtliquid(pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT MAX(lem.dtmvtolt)
          FROM craplem lem
              ,craphis his
         WHERE lem.cdcooper = pr_cdcooper
           AND lem.nrdconta = pr_nrdconta
           AND lem.nrctremp = pr_nrctremp
           AND his.cdcooper = lem.cdcooper
           AND his.cdhistor = lem.cdhistor
           AND his.indebcre = 'C'; -- Lcto de Crecito
      vr_dtliquid DATE;
    
      -- Buscar quantos dias de atraso houve no contrato
      CURSOR cr_crapris(pr_nrctremp IN crapepr.nrctremp%TYPE
                       ,pr_dtultdma IN crapdat.dtultdma%TYPE) IS
        SELECT MAX(ris.qtdiaatr) qtdiaatr
          FROM crapris ris
         WHERE ris.cdcooper = pr_cdcooper
           AND ris.nrdconta = pr_nrdconta
           AND ris.nrctremp = pr_nrctremp
           AND ris.dtrefere <= pr_dtultdma
           AND ris.inddocto = 1;
      vr_qtdiaatr NUMBER;
    
      -- Checar se esta proposta foi liquidada em novos contratos
      CURSOR cr_eprliquid(pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT 1
          FROM crawepr wpr2
         WHERE wpr2.cdcooper = pr_cdcooper
           AND wpr2.nrdconta = pr_nrdconta
           AND wpr2.nrctremp = pr_nrctremp
           AND wpr2.cdcooper = pr_cdcooper
           AND wpr2.nrdconta = pr_nrdconta
           AND pr_nrctremp -- Contrato registro em loop
               IN (wpr2.nrctrliq##1
                  ,wpr2.nrctrliq##2
                  ,wpr2.nrctrliq##3
                  ,wpr2.nrctrliq##4
                  ,wpr2.nrctrliq##5
                  ,wpr2.nrctrliq##6
                  ,wpr2.nrctrliq##7
                  ,wpr2.nrctrliq##8
                  ,wpr2.nrctrliq##9
                  ,wpr2.nrctrliq##10);
      rw_eprliquid cr_eprliquid%ROWTYPE;
    
      -- Verificar se houve prejuizo do Cooperado na Cooperativa          
      CURSOR cr_crapepr_preju IS
        SELECT 1
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.inprejuz = 1;
      rw_crapepr_preju cr_crapepr_preju%ROWTYPE;
    
      -- Verificar se ha emprestimo nas linhas 800 e 900     
      CURSOR cr_crapepr_800_900 IS
        SELECT 1
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.inliquid = 0
           AND epr.cdlcremp IN (800, 900);
      rw_crapepr_800_900 cr_crapepr_800_900%ROWTYPE;
    
      -- Buscar outras propostas em Andamento
      CURSOR cr_crawepr_outras IS
        SELECT SUM(epr.vlsdeved) vlsdeved
              ,SUM(wpr.vlpreemp) vlpreemp
          FROM crawepr wpr,
					     crapepr epr
         WHERE wpr.cdcooper = pr_cdcooper
           AND wpr.nrdconta = pr_nrdconta
           AND wpr.nrctremp <> pr_nrctremp  -- Somente em aberto
					 AND epr.cdcooper = wpr.cdcooper
					 AND epr.nrdconta = wpr.nrdconta
					 AND epr.nrctremp = wpr.nrctremp;
      rw_crawepr_outras cr_crawepr_outras%ROWTYPE;
    
      -- Buscar Quantidade de Utiliza��o do Adiantamento a Depositante
      CURSOR cr_crapneg_adt(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
			                     ,pr_qtmesest IN INTEGER) IS
        SELECT SUM(qtdiaest)
          FROM crapneg
         WHERE cdcooper = pr_cdcooper
           AND cdhisest = 5 -- Estouro C/C 
           AND nrdconta = pr_nrdconta
           AND vlestour > vllimcre
           AND dtiniest BETWEEN add_months(TRUNC(pr_dtmvtolt), -pr_qtmesest) AND
               TRUNC(pr_dtmvtolt);
      vr_vtqdtdep	crapneg.qtdiaest%TYPE;
    
      -- Buscar Quantidade de Utiliza��o do Cheque Especial
      CURSOR cr_crapneg_chqesp(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
			                        ,pr_qtmesest IN INTEGER) IS
        SELECT qtdiaest
              ,dtiniest
              ,vlestour
          FROM crapneg
         WHERE cdcooper = pr_cdcooper
           AND cdhisest = 5 -- Estouro
           AND nrdconta = pr_nrdconta
           AND dtiniest BETWEEN add_months(TRUNC(pr_dtmvtolt), -12) AND
               TRUNC(pr_dtmvtolt);
    
      -- Buscar Contrato Limite Cr�dito
      CURSOR cr_craplim_chqesp IS
        SELECT lim.dtinivig
              ,lim.vllimite
          FROM craplim lim
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.nrdconta = pr_nrdconta
           AND lim.insitlim = 2; -- Ativo
      rw_craplim_chqesp cr_craplim_chqesp%ROWTYPE;
    
      -- Buscar ultimas ocorr�ncias de Cheques Devolvidos
      CURSOR cr_crapneg_cheq(pr_qtmeschq IN INTEGER) IS
        SELECT dtiniest
              ,vlestour
              ,cdobserv
							,rownum
          FROM crapneg
         WHERE crapneg.cdcooper = pr_cdcooper
           AND crapneg.cdhisest = 1
           AND crapneg.cdobserv IN (12, 13)
           AND crapneg.nrdconta = pr_nrdconta
           AND crapneg.dtiniest BETWEEN add_months(TRUNC(rw_crapdat.dtmvtolt),-pr_qtmeschq)
                                                   AND TRUNC(rw_crapdat.dtmvtolt)					 
         ORDER BY crapneg.dtiniest DESC;
    
      -- Buscar Saldo de Cotas
      CURSOR cr_crapcot IS
        SELECT vldcotas
          FROM crapcot
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      vr_vldcotas crapcot.vldcotas%TYPE;
			
      -- Busca se o cooperado tem plano de cotas ativo
      CURSOR cr_crappla IS
        SELECT 1
          FROM crappla
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND cdsitpla = 1;
      rw_crappla cr_crappla%ROWTYPE;
    
      -- Verificar se cooperado tem Debito Autom�tico
      CURSOR cr_crapatr IS
        SELECT COUNT(1)
          FROM crapatr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dtfimatr IS NULL;
      rw_crapatr cr_crapatr%ROWTYPE;
    
      -- Buscar as informa��es do Arquivo SCR
      CURSOR cr_crapopf(pr_dtmvtoan IN crapdat.dtmvtolt%TYPE) IS
        SELECT qtopesfn
              ,qtifssfn
              ,dtrefere
          FROM crapopf
         WHERE nrcpfcgc = rw_crapass.nrcpfcgc
           AND dtrefere <= pr_dtmvtoan
         ORDER BY dtrefere DESC;
      rw_crapopf cr_crapopf%ROWTYPE;
    
      -- Na sequencia buscar os valores dos vencimentos
      CURSOR cr_crapvop IS
        SELECT SUM(vlvencto) vlopesfn
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 205 AND 290 THEN
                      vlvencto
                     ELSE
                      0
                   END) vlopevnc
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 310 AND 310 THEN
                      vlvencto
                     ELSE
                      0
                   END) vlopeprj
              ,SUM(CASE
                     WHEN cdvencto = 130 THEN
                      vlvencto
                     ELSE
                      0
                   END) vlvcto130
          FROM crapvop
         WHERE nrcpfcgc = rw_crapass.nrcpfcgc
           AND dtrefere = rw_crapopf.dtrefere;
      rw_crapvop cr_crapvop%ROWTYPE;
    
      -- Buscar todos os seguros da Conta do Cooperado 
      CURSOR cr_crapseg IS
        SELECT DECODE(seg.tpseguro
                     ,1
                     ,'CASA'
                     ,11
                     ,'CASA'
                     ,2
                     ,'AUTO'
                     ,3
                     ,'VIDA'
                     ,4
                     ,'PRST'
                     ,'    ') dstipo
              ,wseg.vlseguro vlpremio
          FROM crapseg seg
              ,crapcsg csg
              ,crawseg wseg
         WHERE seg.cdcooper = csg.cdcooper
           AND seg.cdsegura = csg.cdsegura
           AND seg.cdcooper = pr_cdcooper
           AND seg.nrdconta = pr_nrdconta
           AND seg.cdcooper = wseg.cdcooper(+)
           AND seg.nrdconta = wseg.nrdconta(+)
           AND seg.nrctrseg = wseg.nrctrseg(+)
           AND seg.cdsitseg IN (1, 3, 11)
           AND wseg.vlseguro > 0
        UNION ALL
        SELECT DECODE(segnov.tpseguro
                     ,'C'
                     ,'CASA'
                     ,'A'
                     ,'AUTO'
                     ,'V'
                     ,'VIDA'
                     ,'G'
                     ,'VIDA'
                     ,'P'
                     ,'PRST'
                     ,'    ') dstipo
              ,segnov.vlpremio_total vlpremio
          FROM tbseg_contratos segnov
              ,crapcsg         csg
              ,tbseg_parceiro  par
         WHERE segnov.cdparceiro = par.cdparceiro
           AND segnov.cdcooper = csg.cdcooper
           AND segnov.cdsegura = csg.cdsegura
           AND segnov.cdcooper = pr_cdcooper
           AND segnov.nrdconta = pr_nrdconta
           AND segnov.flgvigente = 1
           AND segnov.nrapolice > 0
           AND segnov.vlpremio_total > 0;
    
      -- Verificar se h� bloqueio de aplica��es na conta
      CURSOR cr_crapblj IS
        SELECT SUM(vlbloque)
          FROM crapblj
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND cdmodali = 2
           AND dtblqfim IS NULL;
      vr_vlbloque crapblj.vlbloque%TYPE;
      -- Verificar se h� bloqueio de aplica��es na conta
      CURSOR cr_crapblj_pp IS
        SELECT SUM(vlbloque)
          FROM crapblj
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND cdmodali > 2
           AND dtblqfim IS NULL;
      vr_vlbloque_pp crapblj.vlbloque%TYPE;
    
      -- Buscar contrato de desconto cheques
      CURSOR cr_craplim_chq IS
        SELECT dtinivig
              ,vllimite
          FROM craplim
         WHERE craplim.cdcooper = pr_cdcooper
           AND craplim.nrdconta = pr_nrdconta
           AND craplim.tpctrlim = 2
           AND craplim.insitlim = 2; /* ATIVO */
      rw_craplim_chq cr_craplim_chq%ROWTYPE;
    
      -- Buscar border�s ativos
      CURSOR cr_crapcdb(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT SUM(vlcheque) vlcheque
          FROM crapcdb
         WHERE crapcdb.cdcooper = pr_cdcooper
           AND crapcdb.nrdconta = pr_nrdconta
           AND crapcdb.insitchq = 2
           AND crapcdb.dtlibera > pr_dtmvtolt;
      rw_crapcdb cr_crapcdb%ROWTYPE;
    
      -- Buscar contrato de desconto titulos
      CURSOR cr_craplim_tit IS
        SELECT dtinivig
              ,vllimite
          FROM craplim
         WHERE craplim.cdcooper = pr_cdcooper
           AND craplim.nrdconta = pr_nrdconta
           AND craplim.tpctrlim = 3
           AND craplim.insitlim = 2; /* ATIVO */
      rw_craplim_tit cr_craplim_tit%ROWTYPE;
    
      -- Buscar border�s ativos
      CURSOR cr_craptdb(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT SUM(vltitulo) vltitulo
          FROM craptdb
         WHERE craptdb.cdcooper = pr_cdcooper
           AND craptdb.nrdconta = pr_nrdconta
           AND ((craptdb.insittit = 4) OR
               (craptdb.insittit = 2 AND
               craptdb.dtdpagto = pr_dtmvtolt));
      rw_craptdb cr_craptdb%ROWTYPE;
    
      -- Buscar informa��es da linha
      CURSOR cr_craplcr(pr_cdlcremp IN craplcr.cdlcremp%TYPE) IS
        SELECT lcr.flglispr
          FROM craplcr lcr
         WHERE lcr.cdcooper = pr_cdcooper
           AND lcr.cdlcremp = pr_cdlcremp;
      rw_craplcr cr_craplcr%ROWTYPE;
    
      -- Para PP, buscaremos no cadastro de parcelas a quantidade de parcelas pagas em atraso      
      CURSOR cr_crappep_atraso(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
			                        ,pr_nrctremp IN crappep.nrctremp%TYPE
															,pr_qthisemp IN INTEGER) IS
        SELECT COUNT(1)
          FROM crappep
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND dtultpag > dtvencto -- Paga depois do vencimento
           AND dtultpag >= add_months(pr_dtmvtolt, -pr_qthisemp) -- Nos ultimos XX meses
           AND inliquid = 1 -- Liquidadas
           AND vlmtapar > 0; -- Com multa
    
      -- Para as parcelas pagas tamb�m buscaremos no cadastro de parcelas
      CURSOR cr_crappep_pagtos(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
			                        ,pr_nrctremp IN crappep.nrctremp%TYPE
															,pr_qthisemp IN INTEGER) IS
        SELECT COUNT(1)
          FROM crappep
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND dtultpag >= add_months(pr_dtmvtolt, -pr_qthisemp) -- Nos ultimos XX meses
           AND inliquid = 1 -- Liquidadas
           AND vlmtapar = 0; -- Sem multa
    
      -- Para TR, buscaremos nos lan�amentos de pagtos a quantidade de lan�amentos de Multa
      CURSOR cr_craplem_atraso(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
			                        ,pr_nrctremp IN craplem.nrctremp%TYPE
															,pr_qthisemp IN INTEGER) IS
        SELECT COUNT(1)
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND cdhistor = 443 -- Multa
           AND dtmvtolt >= add_months(pr_dtmvtolt, -pr_qthisemp); -- Nos ultimos XX meses
    
      -- Somar o valor pago nos ultimos 6 meses
      CURSOR cr_craplem_pago(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE
			                      ,pr_nrctremp IN craplem.nrctremp%TYPE
														,pr_qthisemp IN INTEGER) IS
        SELECT SUM(vllanmto)
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND cdhistor NOT IN (99, 98, 443) -- Remover libera��o, juros e Multa
           AND dtmvtolt >= add_months(pr_dtmvtolt, -pr_qthisemp) -- Nos ultimos XX meses
           AND vlpreemp > 0;
			vr_vlpclpag NUMBER(25,10);
			
			-- Busca dos bens do associado CURSOR cr_crapbem e vr_vlrtotbem
			CURSOR cr_crapbem IS
			SELECT SUM(vlrdobem)
				FROM crapbem 
			 WHERE cdcooper = pr_cdcooper
					 AND nrdconta = pr_nrdconta
					 AND idseqttl = 1;
			vr_vltotbem NUMBER;
			
    BEGIN
      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se n�o encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        CLOSE BTCH0001.cr_crapdat;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;	
		
      -- Buscar informa��es cadastrais da conta
      OPEN cr_crapass;
      FETCH cr_crapass
        INTO rw_crapass;
    
      -- Se n�o encontrar registro
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        -- Sair acusando critica 9
        vr_cdcritic := 9;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapass;
      END IF;
			
      -- Se preponente
			IF pr_flprepon THEN 
      
        -- Buscaremos informa��es da proposta de empr�stimo em aprova��o    
        OPEN cr_crawepr;
        FETCH cr_crawepr INTO rw_crawepr;
  		
        -- Se n�o encontrar registro
        IF cr_crawepr%NOTFOUND THEN
          CLOSE cr_crawepr;
          -- Sair acusando critica 535 
          vr_cdcritic := 535;
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crawepr;
        END IF;
      END IF;
      
      -- Enviaremos os dados b�sicos encontrados na tabela 
      vr_obj_generico.put('documento', rw_crapass.nrcpfcgc);
    
      -- Para Pessoas Fisicas 
      IF rw_crapass.inpessoa = 1 THEN
        vr_obj_generico.put('tipoPessoa', 'FISICA');
        -- Buscar dados do titular 
        OPEN cr_crapttl;
        FETCH cr_crapttl
          INTO rw_crapttl;
        CLOSE cr_crapttl;
      
        vr_obj_generico.put('nome', rw_crapttl.nmextttl);
        vr_obj_generico.put('dataNascimento'
                           ,este0001.fn_data_ibra(rw_crapass.dtnasctl));													 
        -- Se o Documento for RG
        IF rw_crapttl.tpdocttl = 'CI' THEN
          vr_obj_generico.put('rg', rw_crapttl.nrdocttl);
          vr_obj_generico.put('ufRg', rw_crapttl.cdoedttl);
        END IF;
        vr_obj_generico.put('nomeMae', rw_crapttl.nmmaettl);
			  vr_obj_generico.put('tipoNacionalidade',rw_crapttl.tpnacion);
        vr_obj_generico.put('nacionalidade'  ,rw_crapttl.dsnacion);
      
        -- Montar objeto profissao       
        IF rw_crapttl.dsproftl <> ' ' THEN
          vr_obj_generic2 := json();
          vr_obj_generic2.put('titulo', rw_crapttl.dsproftl);
          vr_obj_generico.put('profissao', vr_obj_generic2);
        END IF;
      
        -- Buscar endere�o residencial
        OPEN cr_crapenc(10);
        FETCH cr_crapenc
          INTO rw_crapenc;
        CLOSE cr_crapenc;
      
      ELSE
        vr_obj_generico.put('tipoPessoa', 'JURIDICA');
        -- Buscar dados da conta PJ
        OPEN cr_crapjur;
        FETCH cr_crapjur
          INTO rw_crapjur;
        CLOSE cr_crapjur;
      
        vr_obj_generico.put('razaoSocial', rw_crapjur.nmextttl);
        vr_obj_generico.put('dataFundacao'
                           ,este0001.fn_data_ibra(rw_crapass.dtnasctl));
      
        -- Buscar endere�o comercial
        OPEN cr_crapenc(9);
        FETCH cr_crapenc
          INTO rw_crapenc;
        CLOSE cr_crapenc;
      
      END IF;
    
      -- Montar objeto Telefone para Telefones Celular/Residencial/Comercial      
      vr_lst_generic2 := json_list();
      -- Criar objeto s� para este telefone
      vr_obj_generic2 := json();
      -- Buscar todos os registros
      FOR rw_craptfc IN cr_craptfc LOOP
        -- Para pessoa Juridica sempre enviamos comercial
        IF rw_crapass.inpessoa = 2 THEN
          vr_obj_generic2.put('especie', 'COMERCIAL');
        ELSE
          -- Para pessoa Fisica temos de testar 
          IF rw_craptfc.tptelefo = 3 THEN
            vr_obj_generic2.put('especie', 'COMERCIAL');
          ELSE
            vr_obj_generic2.put('especie', 'DOMICILIO');
          END IF;
        END IF;
      
        -- Celular
        IF rw_craptfc.tptelefo = 2 THEN
          vr_obj_generic2.put('tipo', 'MOVEL');
        ELSE
          vr_obj_generic2.put('tipo', 'FIXO');
        END IF;
      
        vr_obj_generic2.put('ddd', rw_craptfc.nrdddtfc);
        vr_obj_generic2.put('numero'
                           ,REPLACE(REPLACE(rw_craptfc.nrtelefo, '-', '')
                                   ,'.'
                                   ,''));
        -- Adicionar telefone na lista
        vr_lst_generic2.append(vr_obj_generic2.to_json_value());
      END LOOP;
      -- Adicionar o array telefone no objeto
      vr_obj_generico.put('telefones', vr_lst_generic2);
    
      -- Montar objeto Endereco
      IF rw_crapenc.dsendere <> ' ' THEN
        vr_obj_generic2 := json();
      
        vr_obj_generic2.put('logradouro', rw_crapenc.dsendere);
        vr_obj_generic2.put('numero', rw_crapenc.nrendere);
        vr_obj_generic2.put('complemento', rw_crapenc.complend);
        vr_obj_generic2.put('bairro', rw_crapenc.nmbairro);
        vr_obj_generic2.put('cidade', rw_crapenc.nmcidade);
        vr_obj_generic2.put('uf', rw_crapenc.cdufende);
        vr_obj_generic2.put('cep', rw_crapenc.nrcepend);
      
        vr_obj_responsav.put('endereco', vr_obj_generic2);
      END IF;
    
      -- Montar informa��es Adicionais
      vr_obj_generic2 := json();
    
      IF rw_crapass.inpessoa = 1 THEN
        vr_obj_generic2.put('sexo', rw_crapttl.cdsexotl);				
			END IF;
		
      -- Caixa Postal
      IF rw_crapenc.nrcxapst <> 0 THEN
        vr_obj_generic2.put('caixaPostal', rw_crapenc.nrcxapst);
      END IF;
    
      -- Conta
			vr_obj_generic2.put('conta', to_number(substr(pr_nrdconta,1,length(pr_nrdconta)-1)));
			vr_obj_generic2.put('contaDV', to_number(substr(pr_nrdconta,-1)));
    
      -- Agencia
      vr_obj_generic2.put('agenci', rw_crapass.cdagenci);
    
		  -- Data Admiss�o Coop
			IF rw_crapass.dtadmiss IS NOT NULL THEN 
				 vr_obj_generic2.put('dataAdmissaoCoop', ESTE0001.fn_Data_ibra(rw_crapass.dtadmiss));
			END IF;
		
      -- Matricula
      vr_obj_generic2.put('matric', rw_crapass.nrmatric);
    
      -- Tipo da Conta
      vr_obj_generic2.put('tipoConta'
                         ,rw_crapass.cdtipcta);
    
      -- Situa��o da Conta
      vr_obj_generic2.put('situacaoConta'
                         ,rw_crapass.cdsitdct);
    
      -- Tipo do Im�vel
      IF rw_crapenc.incasprp <> 0 THEN
        vr_obj_generic2.put('tipoImovel'
                           ,rw_crapenc.incasprp);
      END IF;
    
      -- Valor do Imovel (Somente quando n�o for alugado)
      IF rw_crapenc.vlalugue > 0 AND rw_crapenc.incasprp NOT IN (0, 3) THEN
        vr_obj_generic2.put('valorImovel'
                           ,este0001.fn_decimal_ibra(rw_crapenc.vlalugue));
			ELSE
				-- Quando alugado usamos o mesmo campo para enviar valor do aluguel
				vr_obj_generic2.put('valorAluguel', este0001.fn_decimal_ibra(rw_crapenc.vlalugue));
			END IF;    
			
			-- Busca dos bens do associado CURSOR cr_crapbem e vr_vlrtotbem
			OPEN cr_crapbem;
			FETCH cr_crapbem
			 INTO vr_vltotbem;
			CLOSE cr_crapbem;

			-- Se o titular possui bens
			IF vr_vltotbem > 0 THEN 
				vr_obj_generic2.put('valorTotalBens', este0001.fn_decimal_ibra(vr_vltotbem));
			END IF;			
			
      -- Data de Inicio de Resid�ncia
      IF rw_crapenc.dtinires IS NOT NULL THEN
        vr_obj_generic2.put('inicioResidImovel'
                           ,este0001.fn_data_ibra(rw_crapenc.dtinires));
      END IF;
    
      -- Data de demiss�o na Cooperativa
      IF rw_crapass.dtelimin IS NOT NULL THEN
        vr_obj_generic2.put('dataDemissao'
                           ,este0001.fn_data_ibra(rw_crapass.dtelimin));
      END IF;
			
			-- Somente para preponente
			IF pr_flprepon THEN 
				--Verificar se usa tabela juros
				vr_dstextab:= TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
																								 ,pr_nmsistem => 'CRED'
																								 ,pr_tptabela => 'USUARI'
																								 ,pr_cdempres => 11
																								 ,pr_cdacesso => 'TAXATABELA'
																								 ,pr_tpregist => 0);
				-- Se a primeira posi��o do campo
				-- dstextab for diferente de zero
				vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0';
	           
				-- Busca endividamento do cooperado
			  RATI0001.pc_calcula_endividamento(pr_cdcooper   => pr_cdcooper     --> C�digo da Cooperativa
																				 ,pr_cdagenci   => 1               --> C�digo da ag�ncia
																				 ,pr_nrdcaixa   => 0               --> N�mero do caixa
																				 ,pr_cdoperad   => '1'     	       --> C�digo do operador
																				 ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de par�metro (CRAPDAT)
																				 ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
																				 ,pr_dsliquid   => rw_crawepr.dsliquid --> Lista de contratos a liquidar
																				 ,pr_idseqttl   => 1               --> Sequencia de titularidade da conta
																				 ,pr_idorigem   => 1 /*AYLLOS*/    --> Indicador da origem da chamada
																				 ,pr_inusatab   => vr_inusatab     --> Indicador de utiliza��o da tabela de juros
																				 ,pr_tpdecons   => 3               --> Tipo da consulta 3 - Considerar a data atual
																				 ,pr_vlutiliz   => vr_vlutiliz     --> Valor da d�vida
																				 ,pr_cdcritic   => vr_cdcritic     --> Critica encontrada no processo
																				 ,pr_dscritic   => vr_dscritic);   --> Sa�da de erro
				-- Se houve erro
				IF nvl(vr_cdcritic,0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
					-- Encerrar o processo
					RAISE vr_exc_saida;
				END IF;

				vr_obj_generic2.put('valorEndividamento',ESTE0001.fn_decimal_ibra(vr_vlutiliz));
			END IF;			
	    
			-- Data da consulta no SPC 
			IF rw_crapass.dtcnsspc IS NOT NULL THEN
				vr_obj_generic2.put('dataConsultaSPC'
													 ,este0001.fn_data_ibra(rw_crapass.dtcnsspc));
			END IF;
		    
			-- Data da inclus�o no SPC pela cooperativa
			IF rw_crapass.dtdsdspc IS NOT NULL THEN
        vr_obj_generic2.put('dataInclusaoSPCpelaCoop'
                           ,este0001.fn_data_ibra(rw_crapass.dtdsdspc));
      END IF;
    
      -- Est� no SPC(cooperativa)
      vr_obj_generic2.put('SPCpelaCoop'
                         ,rw_crapass.inadimpl=1);
    
      -- Est� no SPC(outras IFs)
      vr_obj_generic2.put('SPCoutrasIFs'
                         ,rw_crapass.inlbacen=1);
    
      -- CCF
      vr_obj_generic2.put('ccf', rw_crapass.inccfcop=1);
    
      -- Cadastro Positivo
      vr_obj_generic2.put('cadastroPositivo'
                         ,rw_crapass.incadpos);
    
      -- Data Consulta SCR
      IF rw_crapass.dtcnsscr IS NOT NULL THEN
        vr_obj_generic2.put('dataConsultaSCR'
                           ,este0001.fn_data_ibra(rw_crapass.dtcnsscr));
      END IF;
    
      -- Libera Pr� Aprovado
      OPEN cr_preapv;
      FETCH cr_preapv
        INTO vr_flglibera_pre_aprv;
      CLOSE cr_preapv;
    
      vr_obj_generic2.put('liberaPreAprovad'
                         ,(vr_flglibera_pre_aprv=1));
    
      -- Data Ultima Revis�o Cadastral      
      OPEN cr_revisa;
      FETCH cr_revisa
        INTO vr_dtaltera;
      CLOSE cr_revisa;
    
      IF vr_dtaltera IS NOT NULL THEN
        vr_obj_generic2.put('liberaPreAprovad', este0001.fn_data_ibra(vr_dtaltera));
      END IF;
    
      vr_indexis := 0;
      OPEN cr_alerta;
      FETCH cr_alerta
        INTO vr_indexis;
      CLOSE cr_alerta;
    
      vr_obj_generic2.put('estaALERTA', (vr_indexis=1));
    
      -- Conta tem Registro Contra Ordem
      IF rw_crapass.cdsitdtl = 2 THEN
        vr_obj_generic2.put('estaDCTROR'
                           ,(rw_crapass.cdsitdtl = 2));
      END IF;
    
      -- Somente para Pessoa Fisica
      IF rw_crapass.inpessoa = 1 THEN
      
        -- Nome Pai
        IF rw_crapttl.nmpaittl <> ' ' THEN
          vr_obj_generic2.put('nomePai', rw_crapttl.nmpaittl);
        END IF;
      
        -- Estado Civil
        IF rw_crapttl.cdestcvl <> 0 THEN
          vr_obj_generic2.put('estadoCivil'
                             ,rw_crapttl.cdestcvl);
        END IF;
      
        -- Naturalidade
        IF rw_crapttl.dsnatura <> ' ' THEN
          vr_obj_generic2.put('naturalidadeDescricao', rw_crapttl.dsnatura);
        END IF;
      
        -- Habilita��o Menor
        IF rw_crapttl.inhabmen <> 0 THEN
          vr_obj_generic2.put('reponsabiLegal'
                             ,rw_crapttl.inhabmen);
        END IF;
      
        -- Data Emancipa��o
        IF rw_crapttl.dthabmen IS NOT NULL THEN
          vr_obj_generic2.put('dataEmancipa'
                             ,este0001.fn_data_ibra(rw_crapttl.dthabmen));
        END IF;
      
        -- Valor Rendimento
        IF rw_crapttl.vlrendim <> 0 THEN
          vr_obj_generic2.put('valorSalario'
                             ,este0001.fn_decimal_ibra(rw_crapttl.vlrendim));
        END IF;
      
        -- Outros Rendimentos
        IF rw_crapttl.vroutrorn <> 0 THEN
          vr_obj_generic2.put('valorOutrosRendim'
                             ,este0001.fn_decimal_ibra(rw_crapttl.vroutrorn));
        END IF;
      
        -- Data Consulta CPF
        IF rw_crapttl.dtcnscpf IS NOT NULL THEN
          vr_obj_generic2.put('dataConsultaCPF'
                             ,este0001.fn_data_ibra(rw_crapttl.dtcnscpf));
        END IF;
      
        -- Situa��o CPF
        vr_obj_generic2.put('situacaoCPF'
                           ,rw_crapttl.cdsitcpf);
      
        -- Escolaridade
        IF rw_crapttl.grescola <> 0 THEN
          vr_obj_generic2.put('escolaridade'
                             ,rw_crapttl.grescola);
        END IF;
      
        -- Curso Superior
        IF rw_crapttl.cdfrmttl <> 0 THEN
          vr_obj_generic2.put('cursoSuperiorCodigo'
                             ,rw_crapttl.cdfrmttl);
          vr_obj_generic2.put('cursoSuperiorDescricao'
                             ,fn_des_cdfrmttl(rw_crapttl.cdfrmttl));
														 
        END IF;
      
        -- Natureza Ocupa��o
        IF rw_crapttl.cdnatopc <> 0 THEN
          vr_obj_generic2.put('naturezaOcupacao'
                             ,rw_crapttl.cdnatopc);
        END IF;
      
        -- Ocupa��o
        IF rw_crapttl.cdocpttl <> 0 THEN
          vr_obj_generic2.put('ocupacaoCodigo'
                             ,rw_crapttl.cdocpttl);
          vr_obj_generic2.put('ocupacaoDescricao'
                             ,fn_des_cdocupa(rw_crapttl.cdocpttl));														 
        END IF;
      
        -- Tipo Contrato de Trabalho
        IF rw_crapttl.tpcttrab <> 0 THEN
          vr_obj_generic2.put('tipoContratoTrabalho'
                             ,rw_crapttl.tpcttrab);
        END IF;
      
        -- Nivel Cargo
        IF rw_crapttl.cdnvlcgo <> 0 THEN
          vr_obj_generic2.put('nivelCargo'
                             ,rw_crapttl.cdnvlcgo);
        END IF;
      
        -- Turno
        IF rw_crapttl.cdturnos <> 0 THEN
          vr_obj_generic2.put('turno'
                             ,rw_crapttl.cdturnos);
        END IF;
      
        -- Data Admiss�o
        IF rw_crapttl.dtadmemp IS NOT NULL THEN
          vr_obj_generic2.put('dataAdmissao'
                             ,este0001.fn_data_ibra(rw_crapttl.dtadmemp));
        END IF;
      
        -- CNPJ Empresa
        IF rw_crapttl.nrcpfemp <> 0 THEN
          vr_obj_generic2.put('codCNPJEmpresa', rw_crapttl.nrcpfemp);
        END IF;
      
        -- Tipo Comprovante de Renda
        IF rw_crapttl.cdnatopc = 8 THEN
          vr_tpcmpvrn := 'C';
        ELSIF rw_crapttl.tpcttrab = 1 THEN
          vr_tpcmpvrn := 'F';
        ELSIF rw_crapttl.tpcttrab = 4 THEN
          vr_tpcmpvrn := 'R';
        ELSE
          vr_tpcmpvrn := 'S';
        END IF;
      
        vr_obj_generic2.put('tipoComprovanteRenda', vr_tpcmpvrn);
      
        -- Pessoa Politicamente Exposta
        vr_obj_generic2.put('pessoaPoliticamenteExposta'
                           ,(rw_crapttl.inpolexp=1));
      
        OPEN cr_depend;
        FETCH cr_depend
          INTO vr_qtdepend;
        CLOSE cr_depend;
      
        vr_obj_generic2.put('quantDependentes', vr_qtdepend);
				
			  -- Somente para preponente
				IF pr_flprepon THEN 

					-- calcular nivel de comprometimento

					-- Contratos que ele esta liquidando
					vr_vet_nrctrliq(1)  := rw_crawepr.nrctrliq##1;
					vr_vet_nrctrliq(2)  := rw_crawepr.nrctrliq##2;
					vr_vet_nrctrliq(3)  := rw_crawepr.nrctrliq##3;
					vr_vet_nrctrliq(4)  := rw_crawepr.nrctrliq##4;
					vr_vet_nrctrliq(5)  := rw_crawepr.nrctrliq##5;
					vr_vet_nrctrliq(6)  := rw_crawepr.nrctrliq##6;
					vr_vet_nrctrliq(7)  := rw_crawepr.nrctrliq##7;
					vr_vet_nrctrliq(8)  := rw_crawepr.nrctrliq##8;
					vr_vet_nrctrliq(9)  := rw_crawepr.nrctrliq##9;
					vr_vet_nrctrliq(10) := rw_crawepr.nrctrliq##10;

					--Verificar se usa tabela juros
					vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
																									,pr_nmsistem => 'CRED'
																									,pr_tptabela => 'USUARI'
																									,pr_cdempres => 11
																									,pr_cdacesso => 'TAXATABELA'
																									,pr_tpregist => 0);
					-- Se a primeira posi��o do campo
					-- dstextab for diferente de zero
					vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0';

					RATI0001.pc_nivel_comprometimento(pr_cdcooper     => pr_cdcooper     --> Cooperativa conectada
																					 ,pr_cdoperad     => '1'             --> Operador conectado
																					 ,pr_idseqttl     => 1               --> Sequencia do titular
																					 ,pr_idorigem     => 5               --> Origem da requisi��o
																					 ,pr_nrdconta     => pr_nrdconta     --> Conta do associado
																					 ,pr_tpctrato     => 90              --> Tipo do Rating
																					 ,pr_nrctrato     => pr_nrctremp     --> N�mero do contrato de Rating
																					 ,pr_vet_nrctrliq => vr_vet_nrctrliq --> Vetor de contratos a liquidar
																					 ,pr_vlpreemp     => rw_crawepr.vlpreemp     --> Valor da parcela
																					 ,pr_rw_crapdat   => rw_crapdat      --> Calend�rio do movimento atual
																					 ,pr_flgdcalc     => 1               --> Flag para calcular sim ou n�o
																					 ,pr_inusatab     => vr_inusatab     --> Indicador de utiliza��o da tabela de juros
																					 ,pr_vltotpre     => vr_vltotpre     --> Valor calculado da presta��o
																					 ,pr_dscritic     => vr_dscritic);
					-- Se retornou erro, deve abortar
					IF nvl(vr_cdcritic,0) > 0 THEN
						RAISE vr_exc_saida;
					END IF;
					
					--Pegar salario do Conjuge
					OPEN cr_crapcje (pr_cdcooper => pr_cdcooper
													,pr_nrdconta => pr_nrdconta);
					--Posicionar no proximo registro
					FETCH cr_crapcje INTO rw_crapcje;
					-- Se ja existe , entao pegar do cadastro
					IF cr_crapcje%FOUND THEN
						vr_vlsalari := rw_crapcje.vlsalari;
					END IF;
          CLOSE cr_crapcje;
					
          IF (nvl(rw_crapttl.vlrendim,0) + nvl(rw_crapttl.vroutrorn,0) + nvl(vr_vlsalari,0)) <> 0 THEN
            /* Dividir pelo ( salario + rendimentos + Salario conjuge ) */
            vr_vltotpre := nvl(vr_vltotpre,0) / (nvl(rw_crapttl.vlrendim,0) + nvl(rw_crapttl.vroutrorn,0) + nvl(vr_vlsalari,0));
          END IF;
									-- Envio do percentual de comprometimento de renda do Preponente
				  vr_obj_generic2.put('percentComprometRenda' , ESTE0001.fn_decimal_ibra(vr_vltotpre));
				END IF;				
      
      ELSE
      
        -- Faturamento Annual 
        IF rw_crapjur.vlfatano <> 0 THEN
          vr_obj_generic2.put('valorFaturamentoAnual'
                             ,este0001.fn_decimal_ibra(rw_crapjur.vlfatano));
        END IF;
      
        -- Data Consulta CNPJ
        IF rw_crapass.dtcnscpf IS NOT NULL THEN
          vr_obj_generic2.put('dataConsultaCNPJ'
                             ,este0001.fn_data_ibra(rw_crapass.dtcnscpf));
        END IF;
      
        -- Situa��o CNPJ
        vr_obj_generic2.put('situacaoCNPJ'
                           ,rw_crapass.cdsitcpf);
      
        -- Nome Fantasia
        IF rw_crapjur.nmfansia <> ' ' THEN
          vr_obj_generic2.put('nomeFantasia', rw_crapjur.nmfansia);
        END IF;
      
        -- Natureza Juridica
        IF rw_crapjur.natjurid <> 0 THEN
          -- Buscar descri��o          
          OPEN cr_nature(rw_crapjur.natjurid);
          FETCH cr_nature
            INTO vr_dsnatjur;
          CLOSE cr_nature;
        
          vr_obj_generic2.put('naturezaJuridicaCodigo'
                             ,rw_crapjur.natjurid);
          vr_obj_generic2.put('naturezaJuridicaDescricao'
                             ,vr_dsnatjur);														 
        END IF;
      
        -- Quantidade Filiais
        vr_obj_generic2.put('quantFiliais', rw_crapjur.qtfilial);
      
        -- Quantidade Funcion�rios
        vr_obj_generic2.put('quantFuncionarios', rw_crapjur.qtfuncio);
      
        -- Ramo Atividade
        IF rw_crapjur.cdseteco <> 0 AND rw_crapjur.cdrmativ <> 0 THEN
          -- Buscar descri��o          
          OPEN cr_ramatv(rw_crapjur.cdseteco
					              ,rw_crapjur.cdrmativ);
          FETCH cr_ramatv
            INTO vr_dsramatv;
          CLOSE cr_ramatv;
        
          vr_obj_generic2.put('ramoAtividadeCodigo'
                             ,rw_crapjur.cdrmativ);
          vr_obj_generic2.put('ramoAtividadeDescricao'
                             ,vr_dsramatv);
														 
        END IF;
      
        -- Setor Economico
        IF rw_crapjur.cdseteco <> 0 THEN
        
          -- Buscar descri��o
          vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                   ,pr_nmsistem => 'CRED'
                                                   ,pr_tptabela => 'GENERI'
                                                   ,pr_cdempres => 0
                                                   ,pr_cdacesso => 'SETORECONO'
                                                   ,pr_tpregist => rw_crapjur.cdseteco);
          -- Se Encontrou
          IF TRIM(vr_dstextab) IS NOT NULL THEN
            vr_nmseteco := vr_dstextab;
          ELSE
            vr_nmseteco := 'Nao Cadastrado';
          END IF;
          vr_obj_generic2.put('setorEconomicoCodigo'
                             ,rw_crapjur.cdseteco);
					vr_obj_generic2.put('setorEconomicoDescricao'
                             ,vr_nmseteco);
        END IF;
				
	      -- Buscar faturamento m�dio mensal
				cada0001.pc_calcula_faturamento(pr_cdcooper => pr_cdcooper
																			 ,pr_cdagenci => 1
																			 ,pr_nrdcaixa => 1
																			 ,pr_nrdconta => pr_nrdconta
																			 ,pr_vlmedfat => vr_vlmedfat
																			 ,pr_tab_erro => vr_tab_erro
																			 ,pr_des_reto => vr_des_reto);

				-- Media Faturamento Anual
				vr_obj_generic2.put('mediaFaturamentoAnual', este0001.fn_decimal_ibra(vr_vlmedfat));
						
        -- Valor Faturamento Anual
        vr_obj_generic2.put('valorFaturamentoAnual'
                           ,este0001.fn_decimal_ibra(rw_crapjur.vlfatano));
      
        -- Valor Faturamento Anual
        vr_obj_generic2.put('valorFaturamentoAnual'
                           ,este0001.fn_decimal_ibra(rw_crapjur.vlfatano));
      
        -- Capital Realizado
        vr_obj_generic2.put('capitalRealizado'
                           ,este0001.fn_decimal_ibra(rw_crapjur.vlcaprea));
      
        -- Data de registro da empresa
        IF rw_crapjur.dtregemp IS NOT NULL THEN
          vr_obj_generic2.put('dataRegistroEmpresa'
                             ,este0001.fn_data_ibra(rw_crapjur.dtregemp));
        END IF;
      
        -- Orgao de Registro da Empresa
        IF rw_crapjur.orregemp IS NOT NULL THEN
          vr_obj_generic2.put('orgaoRegistroEmpresa', rw_crapjur.orregemp);
        END IF;
      
        -- Numero Registro Empresa
        IF rw_crapjur.nrregemp <> 0 THEN
          vr_obj_generic2.put('numeroRegistroEmpresa', rw_crapjur.nrregemp);
        END IF;
      
        -- Data Inscri��o Municipal
        IF rw_crapjur.dtinsnum IS NOT NULL THEN
          vr_obj_generic2.put('dataInscricMunicipal'
                             ,este0001.fn_data_ibra(rw_crapjur.dtinsnum));
        END IF;
      
        -- Numero Inscri��o Municipal
        IF rw_crapjur.nrinsmun <> 0 THEN
          vr_obj_generic2.put('numeroInscricMunicipal'
                             ,rw_crapjur.nrinsmun);
        END IF;
      
        -- Numero Inscri��o Estadual
        IF rw_crapjur.nrinsest <> 0 THEN
          vr_obj_generic2.put('numeroInscricEstadual', rw_crapjur.nrinsest);
        END IF;
      
        -- Participante REFIS
        vr_obj_generic2.put('optanteRefis'
                           ,(rw_crapjur.flgrefis=1));
      
        -- Numero Nire
        IF rw_crapjur.nrcdnire <> 0 THEN
          vr_obj_generic2.put('numeroNIRE', rw_crapjur.nrcdnire);
        END IF;
      
        -- CNAE
        IF rw_crapass.cdclcnae <> 0 THEN
          -- Buscar descri��o          
          OPEN cr_cnae(rw_crapass.cdclcnae);
          FETCH cr_cnae
            INTO vr_dscnae;
          CLOSE cr_cnae;
        
          vr_obj_generic2.put('cnaeCodigo'
                             ,rw_crapass.cdclcnae);
          vr_obj_generic2.put('cnaeDescricao'
                             ,vr_dscnae);														 
        END IF;
      
        -- Buscar informa��es do Faturamento
        OPEN cr_crapjfn;
        FETCH cr_crapjfn
          INTO rw_crapjfn;
        CLOSE cr_crapjfn;
      
        -- Percentual faturamento cliente �nico
        IF rw_crapjfn.perfatcl <> 0 THEN
          vr_obj_generic2.put('percentFaturamenMaiorCliente'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.perfatcl));
        END IF;
      				
				-- Somente para preponente
				IF pr_flprepon THEN 

					-- Iniciar com o empr�stimo atual
					vr_vlendivi := rw_crawepr.vlemprst;

					-- Se houver Valor Total SFN exceto na cooperativa
					IF rw_crapvop.vlopesfn <> 0 THEN
							-- Us�-lo
							vr_vlendivi := nvl(vr_vlendivi,0) + rw_crapvop.vlopesfn;
					ELSE
							-- Usar valor do endividamento
							vr_vlendivi := nvl(vr_vlendivi,0) + nvl(vr_vlutiliz,0);
					END IF;
				    
					-- Calcular percentual individamento
					vr_vlendivi := (nvl(vr_vlendivi,0) / nvl(vr_vlmedfat,0));

					-- Envio do percentual de comprometimento de renda do Preponente
					vr_obj_generic2.put('percentComprometRenda' , este0001.fn_decimal_ibra(vr_vlendivi));

				END IF;      
      END IF;
    		    
      -- Verificar se houve prejuizo do Cooperado na Cooperativa          
      OPEN cr_crapepr_preju;
      FETCH cr_crapepr_preju
        INTO rw_crapepr_preju;
    
      IF cr_crapepr_preju%FOUND OR rw_crapass.cdsitdtl IN (5, 6, 7, 8) THEN
        vr_flprjcop := TRUE;
      ELSE
        vr_flprjcop := FALSE;
      END IF;
      CLOSE cr_crapepr_preju;
    
      -- Enviar causouPrejuizoCoop
      vr_obj_generic2.put('causouPrejuizoCoop', vr_flprjcop);
    
      -- Verificar se ha emprestimo nas linhas 800 e 900
      OPEN cr_crapepr_800_900;
      FETCH cr_crapepr_800_900
        INTO rw_crapepr_800_900;
    
      IF cr_crapepr_800_900%FOUND THEN
        vr_fl800900 := TRUE;
      ELSE
        vr_fl800900 := FALSE;
      END IF;
    
      -- Enviar temLinha800e900
      vr_obj_generic2.put('temLinha800e900', vr_fl800900);
    
      -- Buscar outras propostas em Andamento      
      OPEN cr_crawepr_outras;
      FETCH cr_crawepr_outras
        INTO rw_crawepr_outras;
      CLOSE cr_crawepr_outras;
    
      -- Enviar as informa��es para o JSON
      vr_obj_generic2.put('somaOperacoes'
                         ,este0001.fn_decimal_ibra(nvl(rw_crawepr_outras.vlsdeved,0)));
      vr_obj_generic2.put('somaPrestacoes'
                         ,este0001.fn_decimal_ibra(nvl(rw_crawepr_outras.vlpreemp,0)));
    
      -- Buscar o Saldo do Cooperado (Declarar vr_vladtdep)
      extr0001.pc_obtem_saldo_dia(pr_cdcooper   => pr_cdcooper
                                 ,pr_rw_crapdat => rw_crapdat
                                 ,pr_cdagenci   => 1
                                 ,pr_nrdcaixa   => 1
                                 ,pr_cdoperad   => '1'
                                 ,pr_nrdconta   => pr_nrdconta
                                 ,pr_vllimcre   => rw_crapass.vllimcre
                                 ,pr_dtrefere   => rw_crapdat.dtmvtolt
                                 ,pr_flgcrass   => FALSE
                                 ,pr_des_reto   => vr_des_reto
                                 ,pr_tab_sald   => vr_tab_sald
                                 ,pr_tab_erro   => vr_tab_erro);
    
      IF vr_tab_sald(0).vlsddisp < 0 THEN
        IF abs(vr_tab_sald(0).vlsddisp) > vr_tab_sald(0).vllimcre THEN
          vr_vladtdep := vr_tab_sald(0).vllimcre + vr_tab_sald(0).vlsddisp;
        ELSE
          vr_vladtdep := 0;
        END IF;
      ELSE
        vr_vladtdep := 0;
      END IF;
    
      -- Enviar o valorAdiantDeposit
      vr_obj_generic2.put('valorAdiantDeposit'
                         ,este0001.fn_decimal_ibra(vr_vladtdep));
    
			-- Buscar par�metro da quantidade de meses para busca dos Estouros/Adiantamentos
			vr_qtmesest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_ESTOUROS');
		
      -- Buscar Quantidade de Utiliza��o do Adiantamento a Depositante          
      OPEN cr_crapneg_adt(rw_crapdat.dtmvtolt
			                   ,nvl(vr_qtmesest,0));
      FETCH cr_crapneg_adt
        INTO vr_vtqdtdep;
      CLOSE cr_crapneg_adt;
    
      -- Enviar o quantUtilizaAdtoDeposit
      vr_obj_generic2.put('quantUtilizaAdtoDeposit', nvl(vr_vtqdtdep,0));
						
      -- Buscar Contrato Limite Cr�dito    
      OPEN cr_craplim_chqesp;
      FETCH cr_craplim_chqesp
        INTO rw_craplim_chqesp;
      CLOSE cr_craplim_chqesp;
    
      -- Enviar as informa��es do limite de cr�dito (somente se houver limite de cr�dito)
      IF rw_craplim_chqesp.vllimite > 0 THEN
        vr_obj_generic2.put('dataContratoLimiteCred'
                           ,este0001.fn_data_ibra(rw_craplim_chqesp.dtinivig));
        vr_obj_generic2.put('limiteCredito'
                           ,este0001.fn_decimal_ibra(rw_craplim_chqesp.vllimite));
      
        -- Enviar saldo utilizado do limite de cr�dito
        IF vr_tab_sald(0).vlsddisp < 0 THEN
          -- Se temos adiantamento a depositante 
          IF vr_vladtdep > 0 THEN
            -- Estamos usando todo o limite
            vr_obj_generic2.put('saldoUtilizLimiteCredito'
                               ,este0001.fn_decimal_ibra(rw_craplim_chqesp.vllimite));
          ELSE
            -- O Saldo negativo � o valor utilizado 
            vr_obj_generic2.put('saldoUtilizLimiteCredito'
                               ,este0001.fn_decimal_ibra(vr_tab_sald(0).vlsddisp));
          END IF;
        END IF;
      END IF;
    
      -- Chamar rotina para busca das M�dias da Conta Corrente
      extr0001.pc_carrega_medias(pr_cdcooper        => pr_cdcooper
                                ,pr_cdagenci        => 1
                                ,pr_nrdcaixa        => 1
                                ,pr_cdoperad        => '1'
                                ,pr_nrdconta        => pr_nrdconta
                                ,pr_dtmvtolt        => rw_crapdat.dtmvtolt
                                ,pr_idorigem        => 5
                                ,pr_idseqttl        => 1
                                ,pr_nmdatela        => 'ATENDA'
                                ,pr_flgerlog        => 0
                                ,pr_tab_medias      => vr_tab_medias
                                ,pr_tab_comp_medias => vr_tab_comp_medias
                                ,pr_cdcritic        => vr_cdcritic
                                ,pr_dscritic        => vr_dscritic);
    
      -- Testar erros e se n�o houver, enviar os Saldos M�dios
      vr_obj_generic2.put('saldoMedioAtual'
                         ,este0001.fn_decimal_ibra(vr_tab_comp_medias(1).vltsddis));
      vr_obj_generic2.put('saldoMedioTrimes'
                         ,este0001.fn_decimal_ibra(vr_tab_comp_medias(1).vlsmdtri));
      vr_obj_generic2.put('saldoMedioSemes'
                         ,este0001.fn_decimal_ibra(vr_tab_comp_medias(1).vlsmdsem));
    
      -- Acionar rotina de ocorr�ncias na conta 
      cada0004.pc_lista_ocorren(pr_cdcooper    => pr_cdcooper
                               ,pr_cdagenci    => 1
                               ,pr_nrdcaixa    => 1
                               ,pr_cdoperad    => '1'
                               ,pr_nrdconta    => pr_nrdconta
                               ,pr_rw_crapdat  => rw_crapdat
                               ,pr_idorigem    => 5
                               ,pr_idseqttl    => 1
                               ,pr_nmdatela    => 'ATENDA'
                               ,pr_flgerlog    => 0
                               ,pr_tab_ocorren => vr_tab_ocorren
                               ,pr_des_reto    => vr_des_reto
                               ,pr_tab_erro    => vr_tab_erro);
    
      vr_obj_generic2.put('ratingAtivoConta', vr_tab_ocorren(vr_tab_ocorren.first).indrisco);
      vr_obj_generic2.put('ratingConta', vr_tab_ocorren(vr_tab_ocorren.first).nivrisco);
      vr_obj_generic2.put('riscoCooperado', vr_tab_ocorren(vr_tab_ocorren.first).inrisctl);
    
      -- Buscar risco do grupo econ�mico (se existir)
      geco0001.pc_busca_grupo_associado(pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_flggrupo => vr_flggrupo
                                       ,pr_nrdgrupo => vr_nrdgrupo
                                       ,pr_gergrupo => vr_gergrupo
                                       ,pr_dsdrisgp => vr_dsdrisgp);
      -- Se houver grupo 
      IF vr_flggrupo = 1 THEN
        vr_obj_generic2.put('riscoGrupoEconomico', vr_dsdrisgp);
      END IF;
        
      -- Buscar Saldo de Cotas
      OPEN cr_crapcot;
      FETCH cr_crapcot
        INTO vr_vldcotas;
      CLOSE cr_crapcot;
      -- Enviar o saldo das cotas
      vr_obj_generic2.put('saldoCotas', este0001.fn_decimal_ibra(vr_vldcotas));
    
      -- Busca se o cooperado tem plano de cotas ativo      
      OPEN cr_crappla;
      FETCH cr_crappla
        INTO rw_crappla;
    
      IF cr_crappla%FOUND THEN
        vr_temcotas := TRUE;
      ELSE
        vr_temcotas := FALSE;
      END IF;
      CLOSE cr_crappla;
    
      -- Enviar flag se tem Cotas
      vr_obj_generic2.put('temPlanoCotas', vr_temcotas);
    
      -- Verificar se cooperado tem Debito Autom�tico
      OPEN cr_crapatr;
      FETCH cr_crapatr
        INTO rw_crapatr;
    
      IF cr_crapatr%FOUND THEN
        vr_temdebaut := TRUE;
      ELSE
        vr_temdebaut := FALSE;
      END IF;
      CLOSE cr_crapatr;
    
      -- Enviar flag se tem DebAutom�tico
      vr_obj_generic2.put('temDebaut', vr_temdebaut);
    
      -- Buscar as informa��es do Arquivo SCR   
      OPEN cr_crapopf(rw_crapdat.dtmvtoan);
      FETCH cr_crapopf
        INTO rw_crapopf;
    
      -- Na sequencia buscar os valores dos vencimentos
      OPEN cr_crapvop;
      FETCH cr_crapvop
        INTO rw_crapvop;
      CLOSE cr_crapvop;
    
		  IF cr_crapopf%FOUND THEN
				-- Enfim, enviar as informa��es ao JSON
				vr_obj_generic2.put('conscrOpSFN'
													 ,este0001.fn_decimal_ibra(rw_crapvop.vlopesfn));
				vr_obj_generic2.put('conscrOpVenc'
													 ,este0001.fn_decimal_ibra(rw_crapvop.vlopevnc));
				vr_obj_generic2.put('conscrOpPrej'
													 ,este0001.fn_decimal_ibra(rw_crapvop.vlopeprj));
				vr_obj_generic2.put('conscrQtOper', rw_crapopf.qtopesfn);
				vr_obj_generic2.put('conscrqtIFs', rw_crapopf.qtifssfn);
				vr_obj_generic2.put('conscr61a90'
													 ,este0001.fn_decimal_ibra(rw_crapvop.vlvcto130));
      END IF;    
      CLOSE cr_crapopf;
			    
      -- Buscar informa��es e Saldos das Aplica��es 
      apli0002.pc_obtem_dados_aplicacoes(pr_cdcooper       => pr_cdcooper --Codigo Cooperativa
                                        ,pr_cdagenci       => 1 --Codigo Agencia
                                        ,pr_nrdcaixa       => 1 --Numero do Caixa
                                        ,pr_cdoperad       => '1' --Codigo Operador
                                        ,pr_nmdatela       => 'ATENDA' --Nome da Tela
                                        ,pr_idorigem       => 5 --Origem dos Dados
                                        ,pr_nrdconta       => pr_nrdconta --Numero da Conta do Associado
                                        ,pr_idseqttl       => 1 --Sequencial do Titular
                                        ,pr_nraplica       => 0 --Numero da Aplicacao
                                        ,pr_cdprogra       => 'ATENDA' --Nome da Tela
                                        ,pr_flgerlog       => 0 /*FALSE*/ --Imprimir log
                                        ,pr_dtiniper       => NULL --Data Inicio periodo   
                                        ,pr_dtfimper       => NULL --Data Final periodo
                                        ,pr_vlsldapl       => vr_vlsldtot --Saldo da Aplicacao
                                        ,pr_tab_saldo_rdca => vr_tab_saldo_rdca --Tipo de tabela com o saldo RDCA
                                        ,pr_des_reto       => vr_des_reto --Retorno OK ou NOK
                                        ,pr_tab_erro       => vr_tab_erro); --Tabela de Erros
      -- Se retornou erro
      IF vr_des_reto = 'NOK' THEN
        --Se possuir erro na PLTable
        IF vr_tab_erro.count > 0 THEN
          vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_dscritic := 'Nao foi possivel carregar o aplicacoes.';
        END IF;
      
        -- Limpar tabela de erros
        vr_tab_erro.delete;
      
        RAISE vr_exc_saida;
      END IF;
    
      -- loop sobre a tabela de saldo
      vr_ind := vr_tab_saldo_rdca.first;
      WHILE vr_ind IS NOT NULL LOOP
        -- Somar o valor de resgate
        vr_vlsldapl := vr_vlsldapl + vr_tab_saldo_rdca(vr_ind).sldresga;
        vr_ind := vr_tab_saldo_rdca.next(vr_ind);
      END LOOP;
    
      --> Buscar saldo das aplicacoes
      apli0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper --> C�digo da Cooperativa
                                        ,pr_cdoperad => 1 --> C�digo do Operador
                                        ,pr_nmdatela => 'ATENDA' --> Nome da Tela
                                        ,pr_idorigem => 5 --> AYLLOS WEB 
                                        ,pr_nrdconta => pr_nrdconta --> N�mero da Conta
                                        ,pr_idseqttl => 1 --> Titular da Conta
                                        ,pr_nraplica => 0 --> N�mero da Aplica��o / Par�metro Opcional
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data de Movimento
                                        ,pr_cdprodut => 0 --> C�digo do Produto -�> Par�metro Opcional
                                        ,pr_idblqrgt => 1 --> Identificador de Bloqueio de Resgate  
                                        ,pr_idgerlog => 0 --> Identificador de Log (0 � N�o / 1 � Sim)
                                        ,pr_vlsldtot => vr_vlsldtot --> Saldo Total da Aplica��o
                                        ,pr_vlsldrgt => vr_vlsldrgt --> Saldo Total para Resgate
                                        ,pr_cdcritic => vr_cdcritic --> C�digo da cr�tica
                                        ,pr_dscritic => vr_dscritic); --> Descri��o da cr�tica
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
      vr_vlsldapl := vr_vlsldapl + vr_vlsldrgt;
    
      -- Verificar se h� bloqueio de aplica��es na conta      
      OPEN cr_crapblj;
      FETCH cr_crapblj
        INTO vr_vlbloque;
      CLOSE cr_crapblj;
    
      -- Enviar informa��es das aplica��es para o JSON
      vr_obj_generic2.put('temAplicacao'
                         ,(nvl(vr_vlsldapl,0) > 0));
      vr_obj_generic2.put('temAplicacaoBloqueada'
                         ,(nvl(vr_vlbloque,0) > 0));
      vr_obj_generic2.put('saldoDisponAplicacao'
                         ,este0001.fn_decimal_ibra(GREATEST(0
                                                  ,nvl(vr_vlsldapl,0) -
                                                   nvl(vr_vlbloque,0)
																									)));
      vr_obj_generic2.put('saldoTotalAplicacao'
                         ,este0001.fn_decimal_ibra(vr_vlsldapl));
    
      -- Buscar informa��es e Saldos das Poupan�as Programadas
      apli0001.pc_consulta_poupanca(pr_cdcooper      => pr_cdcooper --> Cooperativa 
                                   ,pr_cdagenci      => 1 --> Codigo da Agencia
                                   ,pr_nrdcaixa      => 1 --> Numero do caixa 
                                   ,pr_cdoperad      => 1 --> Codigo do Operador
                                   ,pr_idorigem      => 5 --> Identificador da Origem
                                   ,pr_nrdconta      => pr_nrdconta --> Nro da conta associado
                                   ,pr_idseqttl      => 1 --> Identificador Sequencial
                                   ,pr_nrctrrpp      => 0 --> Contrato Poupanca Programada 
                                   ,pr_dtmvtolt      => rw_crapdat.dtmvtolt --> Data do movimento atual
                                   ,pr_dtmvtopr      => rw_crapdat.dtmvtopr --> Data do proximo movimento
                                   ,pr_inproces      => rw_crapdat.inproces --> Indicador de processo
                                   ,pr_cdprogra      => 'ATENDA' --> Nome do programa chamador
                                   ,pr_flgerlog      => FALSE --> Flag erro log
                                   ,pr_percenir      => vr_percenir --> % IR para Calculo Poupanca
                                   ,pr_tab_craptab   => vr_tab_conta_bloq --> Tipo de tabela de Conta Bloqueada
                                   ,pr_tab_craplpp   => vr_tab_craplpp --> Tipo de tabela com lancamento poupanca
                                   ,pr_tab_craplrg   => vr_tab_craplrg --> Tipo de tabela com resgates
                                   ,pr_tab_resgate   => vr_tab_resgate --> Tabela com valores dos resgates 
                                   ,pr_vlsldrpp      => vr_vlsldppr --> Valor saldo poupanca programada
                                   ,pr_retorno       => vr_des_reto --> Descricao de erro ou sucesso OK/NOK 
                                   ,pr_tab_dados_rpp => vr_tab_dados_rpp --> Poupancas Programadas
                                   ,pr_tab_erro      => vr_tab_erro); --> Saida com erros;
      --Se retornou erro
      IF vr_des_reto = 'NOK' THEN
        -- Extrair o codigo e critica de erro da tabela de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
      
        -- Limpar tabela de erros
        vr_tab_erro.delete;
      
        RAISE vr_exc_saida;
      END IF;
    
      -- Verificar se h� bloqueio de aplica��es na conta          
      OPEN cr_crapblj_pp;
      FETCH cr_crapblj_pp
        INTO vr_vlbloque_pp;
      CLOSE cr_crapblj_pp;
    
      -- Enviar informa��es das aplica��es para o JSON
      vr_obj_generic2.put('temPoupProgram'
                         ,(nvl(vr_vlsldppr,0) > 0));
      vr_obj_generic2.put('temPoupProgamBloqueada'
                         ,(nvl(vr_vlbloque_pp,0) > 0));
      vr_obj_generic2.put('saldoDisponPoupProgram'
                         ,este0001.fn_decimal_ibra(GREATEST(0
                                                  ,nvl(vr_vlsldppr,0) -
                                                   nvl(vr_vlbloque_pp,0)
																									)));
      vr_obj_generic2.put('saldoTotalPoupProgram'
                         ,este0001.fn_decimal_ibra(nvl(vr_vlsldppr,0)));
    
      --> Procedure para listar cartoes do cooperado                    
      cada0004.pc_lista_cartoes(pr_cdcooper => pr_cdcooper --> Codigo da cooperativa
                               ,pr_cdagenci => 1 --> Codigo de agencia
                               ,pr_nrdcaixa => 1 --> Numero do caixa
                               ,pr_cdoperad => 1 --> Codigo do operador
                               ,pr_nrdconta => pr_nrdconta --> Numero da conta
                               ,pr_idorigem => 5 --> Identificado de oriem
                               ,pr_idseqttl => 1 --> sequencial do titular
                               ,pr_nmdatela => 'ATENDA' --> Nome da tela
                               ,pr_flgerlog => 'N' --> identificador se deve gerar log S-Sim e N-Nao
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data da cooperativa
                                ------ OUT ------
                               ,pr_flgativo    => vr_flgativo --> Retorna situa��o 1-ativo 2-inativo
                               ,pr_nrctrhcj    => vr_nrctrhcj --> Retorna numero do contrato
                               ,pr_flgliber    => vr_flgliber --> Retorna se esta liberado 1-sim 2-nao
                               ,pr_vltotccr    => vr_vltotccr --> retorna total de limite do cartao 
                               ,pr_tab_cartoes => vr_tab_cartoes --> retorna temptable com os dados dos convenios
                               ,pr_des_reto    => vr_des_reto --> OK ou NOK
                               ,pr_tab_erro    => vr_tab_erro);
    
      -- Se houve retorno n�o Ok
      IF vr_des_reto = 'NOK' THEN
        -- Retornar a mensagem de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        -- Limpar tabela de erros
        vr_tab_erro.delete;
        RAISE vr_exc_saida;
      END IF;
    
      -- Enviar flag de encontro e valor de Limite de Cr�dito  
      vr_obj_generic2.put('temCartaoCredito'
                         ,(vr_flgativo > 0));
      vr_obj_generic2.put('limiteCartaoCredit'
                         ,este0001.fn_decimal_ibra(vr_vltotccr));
    
      -- Buscar contrato de desconto cheques     
      OPEN cr_craplim_chq;
      FETCH cr_craplim_chq
        INTO rw_craplim_chq;
      CLOSE cr_craplim_chq;
      -- Buscar border�s ativos
      OPEN cr_crapcdb(rw_crapdat.dtmvtolt);
      FETCH cr_crapcdb
        INTO rw_crapcdb;
      CLOSE cr_crapcdb;
    
      -- Enviar informa��es do contrato de Cheque
      vr_obj_generic2.put('dataContrDescCheq'
                         ,este0001.fn_data_ibra(rw_craplim_chq.dtinivig));
      vr_obj_generic2.put('limiteDescCheq'
                         ,este0001.fn_decimal_ibra(nvl(rw_craplim_chq.vllimite,0)));
      vr_obj_generic2.put('saldoUtilizDescCheq'
                         ,este0001.fn_decimal_ibra(nvl(rw_crapcdb.vlcheque,0)));
    
      -- Buscar contrato de desconto titulos     
      OPEN cr_craplim_tit;
      FETCH cr_craplim_tit
        INTO rw_craplim_tit;
      CLOSE cr_craplim_tit;
    
      -- Buscar border�s ativos
      OPEN cr_craptdb(rw_crapdat.dtmvtolt);
      FETCH cr_craptdb
        INTO rw_craptdb;
      CLOSE cr_craptdb;
    
      -- Enviar informa��es do contrato de Cheque
      vr_obj_generic2.put('dataContrDescTitul'
                         ,este0001.fn_data_ibra(rw_craplim_tit.dtinivig));
      vr_obj_generic2.put('limiteDescTitul'
                         ,este0001.fn_decimal_ibra(nvl(rw_craplim_tit.vllimite,0)));
      vr_obj_generic2.put('saldoUtilizDescTitul'
                         ,este0001.fn_decimal_ibra(nvl(rw_craptdb.vltitulo,0)));
        
      -- Ent�o chamaremos a rotina para busca do endividamento total 
      gene0005.pc_saldo_utiliza(pr_cdcooper    => pr_cdcooper
                               ,pr_tpdecons    => 3
                               ,pr_cdagenci    => 1
                               ,pr_nrdcaixa    => 1
                               ,pr_cdoperad    => 1
                               ,pr_nrdconta    => NULL
                               ,pr_nrcpfcgc    => rw_crapass.nrcpfcgc
                               ,pr_idseqttl    => 1
                               ,pr_idorigem    => 5
                               ,pr_dsctrliq    => rw_crawepr.dsliquid
                               ,pr_cdprogra    => 'ATENDA'
                               ,pr_tab_crapdat => rw_crapdat
                               ,pr_inusatab    => TRUE
                               ,pr_vlutiliz    => vr_vlutiliz
                               ,pr_cdcritic    => vr_cdcritic
                               ,pr_dscritic    => vr_dscritic);
    
      IF NVL(vr_cdcritic, 0) <> 0 OR vr_dscritic IS NOT NULL THEN
        -- Se for erro 9, entao o associado esta com data de eliminacao preenchida.
        -- Neste caso nao deve dar erro, e sim considerar como valor zerado
        IF NVL(vr_cdcritic, 0) = 9 THEN
          vr_vlutiliz := 0;
          vr_cdcritic := 0;
          vr_dscritic := NULL;
        ELSE
          RAISE vr_exc_saida;
        END IF;
      END IF;
    
      -- Enviar o saldo utilizado
      vr_obj_generic2.put('saldoDevedor', este0001.fn_decimal_ibra(vr_vlutiliz));
    
      -- Verificar co-responsabilidade
      empr0003.pc_gera_co_responsavel(pr_cdcooper           => pr_cdcooper
                                     ,pr_cdagenci           => 1
                                     ,pr_nrdcaixa           => 1
                                     ,pr_cdoperad           => '1'
                                     ,pr_nmdatela           => 'ATENDA'
                                     ,pr_idorigem           => 5
                                     ,pr_cdprogra           => 'ATENDA'
                                     ,pr_nrdconta           => pr_nrdconta
                                     ,pr_idseqttl           => 1
                                     ,pr_dtcalcul           => rw_crapdat.dtmvtolt
                                     ,pr_flgerlog           => 'N'
                                     ,pr_vldscchq           => rw_craplim_chq.vllimite /* Valor Limite Cheques */
                                     ,pr_vlutlchq           => rw_crapcdb.vlcheque /* Valor utilizado Cheques */
                                     ,pr_vldctitu           => rw_craplim_tit.vllimite /* Valor Limite Titulos */
                                     ,pr_vlutitit           => rw_craptdb.vltitulo /* Valor utilizado Titulos */
                                     ,pr_tab_co_responsavel => vr_tab_co_responsavel
                                     ,pr_dscritic           => vr_cdcritic
                                     ,pr_cdcritic           => vr_dscritic);
    
      -- Testar poss�veis erros no retorno prevendo j� o formato convertido� 
      IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
      -- Passar a PLTable retornada para fazer a ordena��o    
      vr_ind_coresp := vr_tab_co_responsavel.first;
      -- Loop para ordernar PLTable
      WHILE vr_ind_coresp IS NOT NULL LOOP
        vr_tab_co_responsavel_ord(LPAD(vr_tab_co_responsavel(vr_ind_coresp).nrdconta, 8, '0' || LPAD(vr_tab_co_responsavel(vr_ind_coresp).nrctremp, 8, '0'))) := vr_tab_co_responsavel(vr_ind_coresp);
        vr_ind_coresp := vr_tab_co_responsavel.next(vr_ind_coresp);
      END LOOP;
    
      -- Passar a PLTable retornada para fazer a ordena��o    
      vr_ind_coresp2 := vr_tab_co_responsavel_ord.first;
      -- Loop para buscar todos os contratos em que o avalista � co-respos�vel 
      WHILE vr_ind_coresp2 IS NOT NULL LOOP
      
        OPEN cr_craplcr(pr_cdlcremp => vr_tab_co_responsavel_ord(vr_ind_coresp2)
                                       .cdlcremp);
        FETCH cr_craplcr
          INTO rw_craplcr;
        CLOSE cr_craplcr;
      
        /* Se nao lista na proposta */
        IF rw_craplcr.flglispr = 0 THEN
          continue;
        END IF;
      
        /* Se saldo devedor igual a 0 */
        IF vr_tab_co_responsavel_ord(vr_ind_coresp2).vlsdeved = 0 THEN
          continue;
        END IF;
      
        /* Atraso/Parcela */
        vr_qtmesdec := vr_tab_co_responsavel_ord(vr_ind_coresp2).qtmesdec - vr_tab_co_responsavel_ord(vr_ind_coresp2)
                       .qtprecal;
        vr_qtpreemp := vr_tab_co_responsavel_ord(vr_ind_coresp2).qtpreemp - vr_tab_co_responsavel_ord(vr_ind_coresp2)
                       .qtprecal;
      
        IF vr_qtmesdec > vr_qtpreemp THEN
          vr_qtprecal := vr_qtpreemp;
        ELSE
          vr_qtprecal := vr_qtmesdec;
        END IF;
        /* Somar totais */
        vr_tot_vlsdeved := vr_tot_vlsdeved + vr_tab_co_responsavel_ord(vr_ind_coresp2)
                          .vlsdeved;
        vr_tot_qtprecal := vr_tot_qtprecal + vr_qtprecal;
      
        -- Buscar pr�ximo registro
        vr_ind_coresp2 := vr_tab_co_responsavel_ord.next(vr_ind_coresp2);
      END LOOP;
    
      -- Enfim, enviar as informa��es para o JSON (Neste ponto voltamos a trazer c�digo PLSQL)
      vr_obj_generic2.put('coopAvalista'
                         ,(vr_tot_vlsdeved > 0));
      vr_obj_generic2.put('valorCoopAvalista'
                         ,este0001.fn_decimal_ibra(vr_tot_vlsdeved));
      vr_obj_generic2.put('coopAvalistaAtraso'
                         ,(vr_tot_qtprecal > 0));
      vr_obj_generic2.put('valorAvalistaAtraso'
                         ,este0001.fn_decimal_ibra(vr_tot_qtprecal));
												 
			--Verificar se usa tabela juros
			vr_dstextab:= TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
																							 ,pr_nmsistem => 'CRED'
																							 ,pr_tptabela => 'USUARI'
																							 ,pr_cdempres => 11
																							 ,pr_cdacesso => 'TAXATABELA'
																							 ,pr_tpregist => 0);
			-- Se a primeira posi��o do campo
			-- dstextab for diferente de zero
			vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0';												 
    
      -- Buscar todos os contratos do Cooperado
      empr0001.pc_obtem_dados_empresti(pr_cdcooper       => pr_cdcooper --> Cooperativa conectada
                                      ,pr_cdagenci       => 1 --> C�digo da ag�ncia
                                      ,pr_nrdcaixa       => 1 --> N�mero do caixa
                                      ,pr_cdoperad       => '1' --> C�digo do operador
                                      ,pr_nmdatela       => 'ATENDA' --> Nome datela conectada
                                      ,pr_idorigem       => 5 --> Indicador da origem da chamada
                                      ,pr_nrdconta       => pr_nrdconta --> Conta do associado
                                      ,pr_idseqttl       => 1 --> Sequencia de titularidade da conta
                                      ,pr_rw_crapdat     => rw_crapdat --> Vetor com dados de par�metro (CRAPDAT)
                                      ,pr_dtcalcul       => NULL --> Data solicitada do calculo
                                      ,pr_nrctremp       => 0 --> N�mero contrato empr�stimo
                                      ,pr_cdprogra       => 'ATENDA' --> Programa conectado
                                      ,pr_inusatab       => vr_inusatab --> Indicador de utiliza��o da tabela de juros
                                      ,pr_flgerlog       => 'N' --> Gerar log S/N
                                      ,pr_flgcondc       => FALSE --> Mostrar emprestimos liq. s/ prejuizo
                                      ,pr_nmprimtl       => rw_crapass.nmprimtl --> Nome Primeiro Titular
                                      ,pr_tab_parempctl  => vr_dstextab_parempctl --> Dados tabela parametro
                                      ,pr_tab_digitaliza => vr_dstextab_digitaliza --> Dados tabela parametro
                                      ,pr_nriniseq       => 0 --> Numero inicial da paginacao
                                      ,pr_nrregist       => 0 --> Numero de registros por pagina
                                      ,pr_qtregist       => vr_qtregist --> Qtde total de registros
                                      ,pr_tab_dados_epr  => vr_tab_dados_epr --> Saida com os dados do empr�stimo
                                      ,pr_des_reto       => vr_des_reto --> Retorno OK / NOK
                                      ,pr_tab_erro       => vr_tab_erro); --> Tabela com poss�ves erros
    
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
        
          vr_dscritic := 'Conta: ' || pr_nrdconta ||
                         ' nao possui emprestimo.: ' ||
                        -- concatenado a critica na versao oracle para tbm saber a causa de abortar o programa
                         vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_dscritic := 'Conta: ' || pr_nrdconta ||
                         ' nao possui emprestimo.';
        END IF;
        RAISE vr_exc_saida;
      END IF;
			
			-- Buscar par�metro da quantidade de meses para encontro do hist�rico de empr�stimos
			vr_qthisemp := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_EMPREST');
			
      -- Zerar variaveis auxiliares
      vr_nratrmai := 0;
      vr_vltotatr := 0;
      vr_qtpclatr := 0;
      vr_qtpclpag := 0;
    
      -- varrer temptable de emprestimos
      vr_idxempr := vr_tab_dados_epr.first;
      WHILE vr_idxempr IS NOT NULL LOOP
        -- Para aqueles com saldo devedor
        IF vr_tab_dados_epr(vr_idxempr).vlsdeved > 0 THEN
          -- Chamar calculo de dias em atraso
          empr0001.pc_calc_dias_atraso(pr_cdcooper   => pr_cdcooper
                                      ,pr_cdprogra   => 'ATENDA'
                                      ,pr_nrdconta   => pr_nrdconta
                                      ,pr_nrctremp   => vr_tab_dados_epr(vr_idxempr)
                                                        .nrctremp
                                      ,pr_rw_crapdat => rw_crapdat
                                      ,pr_inusatab   => TRUE
                                      ,pr_vlsdeved   => vr_vlsdeved
                                      ,pr_qtprecal   => vr_qtprecal
                                      ,pr_qtdiaatr   => vr_dias
                                      ,pr_cdcritic   => vr_cdcritic
                                      ,pr_des_erro   => vr_dscritic);
          --Se ocorreu erro
          IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
            --Levantar Exce��o
            RAISE vr_exc_saida;
          END IF;
        
          -- Se h� atraso
          IF vr_dias > 0 THEN
            -- Se for o maior
            IF vr_dias > vr_nratrmai THEN
              -- Atualizar maior atraso
              vr_nratrmai := vr_dias;
            END IF;
            -- Acumular saldo em atraso
            vr_vltotatr := vr_vltotatr + vr_vlsdeved;
          END IF;
        END IF;
      
        -- Calculo de Parcelas conforme tipo de empr�stimo 
        IF vr_tab_dados_epr(vr_idxempr).tpemprst = 1 THEN
          -- Para PP, buscaremos no cadastro de parcelas a quantidade de parcelas pagas em atraso
          OPEN cr_crappep_atraso(rw_crapdat.dtmvtolt
					                      ,vr_tab_dados_epr(vr_idxempr).nrctremp
																,vr_qthisemp);
          FETCH cr_crappep_atraso
            INTO vr_qtpclatr;
          CLOSE cr_crappep_atraso;
        
          -- Para as parcelas pagas tamb�m buscaremos no cadastro de parcelas           
          OPEN cr_crappep_pagtos(rw_crapdat.dtmvtolt
					                      ,vr_tab_dados_epr(vr_idxempr).nrctremp
																,vr_qthisemp);
          FETCH cr_crappep_pagtos
            INTO vr_qtpclpag;
          CLOSE cr_crappep_pagtos;
        
        ELSE
          -- Para TR, buscaremos nos lan�amentos de pagtos a quantidade de lan�amentos de Multa         
          OPEN cr_craplem_atraso(rw_crapdat.dtmvtolt
					                      ,vr_tab_dados_epr(vr_idxempr).nrctremp
																,vr_qthisemp);
          FETCH cr_craplem_atraso
            INTO vr_qtpclatr;
          CLOSE cr_craplem_atraso;
        
          -- Somar o valor pago nos ultimos 6 meses
          OPEN cr_craplem_pago(rw_crapdat.dtmvtolt
					                    ,vr_tab_dados_epr(vr_idxempr).nrctremp
															,vr_qthisemp);
          FETCH cr_craplem_pago
            INTO vr_vlpclpag;
          CLOSE cr_craplem_pago;
          -- Quantidade Parcelas paga � Valor Paga nos ultimos 6 meses / Valor da Parcela
          vr_qtpclpag := ROUND(vr_vlpclpag / vr_tab_dados_epr(vr_idxempr)
                               .vlpreemp);
        
          -- Descontar da quantidade paga a quantidade em atraso, pq mesmo tendo pago 
          -- proporcionalmente o valor total da parcela, se teve multa no m�s significa
          -- que foi pago ap�s o vencimento
          vr_qtpclpag := vr_qtpclpag - vr_qtpclatr;
        
          -- Garantir que n�o fique negativo, portanto se for negativo trar� zero.
          vr_qtpclpag := greatest(0, vr_qtpclpag);
        
        END IF;
      
        -- Buscar o pr�ximo
        vr_idxempr := vr_tab_dados_epr.next(vr_idxempr);
      END LOOP;
    
      -- Enviar informa��es do atraso e parcelas calculadas para o JSON
      vr_obj_generic2.put('valorAtrasoEmprest'
                         ,este0001.fn_decimal_ibra(vr_vltotatr));
      vr_obj_generic2.put('quantDiasAtrasoEmprest', vr_nratrmai);
      vr_obj_generic2.put('quantParcelPagas', vr_qtpclpag);
      vr_obj_generic2.put('quantParcelAtraso', vr_qtpclatr);
      vr_obj_generic2.put('quantParcelVencidas', vr_qtpclpag - vr_qtpclatr);
			
      -- Montar objeto para seguro
      vr_lst_generic3 := json_list();
    
      -- Buscar todos os seguros da Conta do Cooperado 
      -- Efetuar la�o para trazer todos os registros 
      FOR rw_crapseg IN cr_crapseg LOOP
            
        -- Criar objeto para a opera��o e enviar suas informa��es 
        vr_obj_generic3 := json();
        vr_obj_generic3.put('tipoSeguro', rw_crapseg.dstipo);
        vr_obj_generic3.put('valorApoliceSeguro'
                           ,este0001.fn_decimal_ibra(rw_crapseg.vlpremio));
        vr_obj_generic3.put('tipoPagtoSeguro ', 'Debito Autom�tico');
      
        -- Adicionar Opera��o na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
      END LOOP; -- Final da leitura os seguros
    
      -- Adicionar o array seguro no objeto informa��es adicionais
      vr_obj_generic2.put('seguro', vr_lst_generic3);
			
      -- Montar objeto para CheqDevol
      vr_lst_generic3 := json_list();
    
			-- Buscar par�metro da quantidade de meses para busca dos Estouros/Adiantamentos
			vr_qtmeschq := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_DEV_CHEQUES');		
		
      -- Efetuar la�o para trazer todos os registros 
      FOR rw_negchq IN cr_crapneg_cheq(vr_qtmeschq) LOOP
      
        -- Verificar a quantidade de registros j� lidos, pois n�o poder� passer de 10
        IF rw_negchq.rownum > 10 THEN
          EXIT;
        END IF;
      
        -- Criar objeto para a opera��o e enviar suas informa��es 
        vr_obj_generic3 := json();
        vr_obj_generic3.put('dataCheqDevol'
                           ,este0001.fn_data_ibra(rw_negchq.dtiniest));
        vr_obj_generic3.put('valorCheqDevol'
                           ,este0001.fn_decimal_ibra(rw_negchq.vlestour));
        vr_obj_generic3.put('alineaCheqDevol', rw_negchq.cdobserv);
      
        -- Adicionar Opera��o na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
      END LOOP; -- Final da leitura das opera��es
    
      -- Adicionar o array CheqDevol no objeto informa��es adicionais
      vr_obj_generic2.put('cheqDevol', vr_lst_generic3);
						    
			-- Montar objeto para Estrutura Estouros
      vr_lst_generic3 := json_list();
			-- Inicializar quantidade total de dias de utiliza��o do cheque especial
      vr_qqdiacheq := 0;
    
      -- Buscar Quantidade de Utiliza��o do Cheque Especial      
      FOR rw_crapneg_chqesp IN cr_crapneg_chqesp(rw_crapdat.dtmvtolt
			                                          ,nvl(vr_qtmesest,0)) LOOP    
				-- Acumular dias utiliza��o cheque especial
			  vr_qqdiacheq := vr_qqdiacheq + rw_crapneg_chqesp.qtdiaest;
																								
        -- Para cada registro de Estouro, criar objeto para a opera��o e enviar suas informa��es 
        vr_obj_generic3 := json();				
				
				vr_obj_generic3.put('quantDiaEstouro', rw_crapneg_chqesp.qtdiaest);
				vr_obj_generic3.put('dataEstouro'
													 ,este0001.fn_data_ibra(rw_crapneg_chqesp.dtiniest));
				vr_obj_generic3.put('valorEstouro'
													 ,este0001.fn_decimal_ibra(rw_crapneg_chqesp.vlestour));
													 
        -- Adicionar Opera��o na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());													 
				
      END LOOP;
			-- Adicionar o array Estouros no objeto informa��es adicionais
			vr_obj_generic2.put('estouro', vr_lst_generic3);			
			-- Enviar informa��es de Cheque Especial 
			vr_obj_generic2.put('quantDiasChequeEspecial'
												 ,vr_qqdiacheq);
						
      -- Montar objeto para OpCred
      vr_lst_generic3 := json_list();
		
      -- L�gica para retorno das ultimas opera��es de Cr�dito Liquidadas
      -- Primeiramente buscamos a quantidade de opera��es a serem enviadas 
      vr_dstextab := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                               ,pr_nmsistem => 'CRED'
                                               ,pr_tptabela => 'USUARI'
                                               ,pr_cdempres => 11
                                               ,pr_cdacesso => 'PROPOSTEPR'
                                               ,pr_tpregist => 0);
      -- Conforme o tipo de pessoa
      IF rw_crapass.inpessoa = 1 THEN
        vr_qtdopliq := SUBSTR(vr_dstextab, 44, 3);
      ELSE
        vr_qtdopliq := SUBSTR(vr_dstextab, 52, 3);
      END IF;
        
      -- Efetuar la�o para trazer todos os registros 
      FOR rw_crapepr IN cr_crapepr LOOP
      
        -- Verificar a quantidade de registros j� lidos, pois n�o poder� passer da quantidade parametrizada
        IF vr_qtdopliq < rw_crapepr.rownum THEN
          EXIT;
        END IF;
      
        -- Busca data da Liquida��o        
        OPEN cr_dtliquid(rw_crapepr.nrctremp);
        FETCH cr_dtliquid
          INTO vr_dtliquid;
        CLOSE cr_dtliquid;
      
        -- Busca data da Liquida��o         
        OPEN cr_crapris(rw_crapepr.nrctremp, rw_crapdat.dtultdma);
        FETCH cr_crapris
          INTO vr_qtdiaatr;
        CLOSE cr_crapris;
      
        OPEN cr_eprliquid(rw_crapepr.nrctremp);
        FETCH cr_eprliquid
          INTO rw_eprliquid;
      
        IF cr_eprliquid%FOUND THEN
          vr_flliquid := TRUE;
        ELSE
          vr_flliquid := FALSE;
        END IF;
        CLOSE cr_eprliquid;
        -- Criar objeto para a opera��o e enviar suas informa��es 
        vr_obj_generic3 := json();
        vr_obj_generic3.put('contratOpCred'
                           ,gene0002.fn_mask_contrato(rw_crapepr.nrctremp));
        vr_obj_generic3.put('dataContratOpCred', este0001.fn_data_ibra(rw_crapepr.dtmvtolt));													 
        vr_obj_generic3.put('valorOpCred'
                           ,este0001.fn_decimal_ibra(rw_crapepr.vlemprst));
        vr_obj_generic3.put('valorPrestOpCred'
                           ,este0001.fn_decimal_ibra(rw_crapepr.vlpreemp));
        vr_obj_generic3.put('quantPrestOpCred'
                           ,este0001.fn_decimal_ibra(rw_crapepr.qtpreemp));
        vr_obj_generic3.put('finalidadeOpCredCodigo', rw_crapepr.cdfinemp);
        vr_obj_generic3.put('finalidadeOpCredDescricao', rw_crapepr.dsfinemp);				
        vr_obj_generic3.put('linhaOpCredCodigo', rw_crapepr.cdlcremp);
        vr_obj_generic3.put('linhaOpCredDescricao', rw_crapepr.dslcremp);				
        vr_obj_generic3.put('liquidacaoOpCred', este0001.fn_data_ibra(vr_dtliquid));
        vr_obj_generic3.put('pontualidadeOpCred'
                           ,fn_des_pontualidade(vr_qtdiaatr));
        vr_obj_generic3.put('atrasoOpCred'
                           ,(nvl(vr_qtdiaatr,0) > 0));
        vr_obj_generic3.put('propostasLiquidOpCred', vr_flliquid);
      
        -- Adicionar Opera��o na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
      END LOOP; -- Final da leitura das opera��es
    
      -- Adicionar o array OpCred no objeto informa��es adicionais
      vr_obj_generic2.put('opCred', vr_lst_generic3);
						
      -- Somente para Pessoa Fisica
      IF rw_crapass.inpessoa <> 1 THEN
			
        -- Montar objeto para faturamentos
        vr_lst_generic3 := json_list();
      
        -- Criar objeto para m�s 01
        vr_obj_generic3 := json();
        vr_obj_generic3.put('dataFaturamentoMes'
                           ,este0001.fn_data_ibra(rw_crapjfn.dtfatme1));
        vr_obj_generic3.put('valorFaturamentoMes'
                           ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##1));
        -- Adicionar M�s na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
        -- Criar objeto para m�s 02
        vr_obj_generic3 := json();
        vr_obj_generic3.put('dataFaturamentoMes'
                           ,este0001.fn_data_ibra(rw_crapjfn.dtfatme2));
        vr_obj_generic3.put('valorFaturamentoMes'
                           ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##2));
        -- Adicionar M�s na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
        -- Criar objeto para m�s 03
        vr_obj_generic3 := json();
        vr_obj_generic3.put('dataFaturamentoMes'
                           ,este0001.fn_data_ibra(rw_crapjfn.dtfatme3));
        vr_obj_generic3.put('valorFaturamentoMes'
                           ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##3));
        -- Adicionar M�s na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
        -- Criar objeto para m�s 04
        vr_obj_generic3 := json();
        vr_obj_generic3.put('dataFaturamentoMes'
                           ,este0001.fn_data_ibra(rw_crapjfn.dtfatme4));
        vr_obj_generic3.put('valorFaturamentoMes'
                           ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##4));
        -- Adicionar M�s na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
        -- Criar objeto para m�s 05
        vr_obj_generic3 := json();
        vr_obj_generic3.put('dataFaturamentoMes'
                           ,este0001.fn_data_ibra(rw_crapjfn.dtfatme5));
        vr_obj_generic3.put('valorFaturamentoMes'
                           ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##5));
        -- Adicionar M�s na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
        -- Criar objeto para m�s 06
        vr_obj_generic3 := json();
        vr_obj_generic3.put('dataFaturamentoMes'
                           ,este0001.fn_data_ibra(rw_crapjfn.dtfatme6));
        vr_obj_generic3.put('valorFaturamentoMes'
                           ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##6));
        -- Adicionar M�s na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
        -- Criar objeto para m�s 07
        vr_obj_generic3 := json();
        vr_obj_generic3.put('dataFaturamentoMes'
                           ,este0001.fn_data_ibra(rw_crapjfn.dtfatme7));
        vr_obj_generic3.put('valorFaturamentoMes'
                           ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##7));
        -- Adicionar M�s na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
        -- Criar objeto para m�s 08
        vr_obj_generic3 := json();
        vr_obj_generic3.put('dataFaturamentoMes'
                           ,este0001.fn_data_ibra(rw_crapjfn.dtfatme8));
        vr_obj_generic3.put('valorFaturamentoMes'
                           ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##8));
        -- Adicionar M�s na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
        -- Criar objeto para m�s 09
        vr_obj_generic3 := json();
        vr_obj_generic3.put('dataFaturamentoMes'
                           ,este0001.fn_data_ibra(rw_crapjfn.dtfatme9));
        vr_obj_generic3.put('valorFaturamentoMes'
                           ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##9));
        -- Adicionar M�s na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
        -- Criar objeto para m�s 10
        vr_obj_generic3 := json();
        vr_obj_generic3.put('dataFaturamentoMes'
                           ,este0001.fn_data_ibra(rw_crapjfn.dtfatme10));
        vr_obj_generic3.put('valorFaturamentoMes'
                           ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##10));
        -- Adicionar M�s na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
        -- Criar objeto para m�s 11
        vr_obj_generic3 := json();
        vr_obj_generic3.put('dataFaturamentoMes'
                           ,este0001.fn_data_ibra(rw_crapjfn.dtfatme11));
        vr_obj_generic3.put('valorFaturamentoMes'
                           ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##11));
        -- Adicionar M�s na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
        -- Criar objeto para m�s 12
        vr_obj_generic3 := json();
        vr_obj_generic3.put('dataFaturamentoMes'
                           ,este0001.fn_data_ibra(rw_crapjfn.dtfatme12));
        vr_obj_generic3.put('valorFaturamentoMes'
                           ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##12));
        -- Adicionar M�s na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
        -- Adicionar o array de faturamentos no objeto informa��es adicionais
        vr_obj_generic2.put('faturamentoMes', vr_lst_generic3);
						
			END IF;
			
      -- Enviar informa��es adicionais ao JSON 
      vr_obj_generico.put('informacoesAdicionais', vr_obj_generic2);

      -- Ao final copiamos o json montado ao retornado
      pr_dsjsonan := vr_obj_generico;
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      WHEN OTHERS THEN
        pr_cdcritic := 0;
        pr_dscritic := 'Erro na montagem dos dados para an�lise autom�tica da proposta: ' ||
                       SQLERRM;
    END;
  END pc_gera_json_pessoa_ass;

  
  PROCEDURE pc_gera_json_pessoa_avt ( pr_rw_crapavt  IN crapavt%ROWTYPE,        --> Dados do avalista
                                      ---- OUT ----
                                      pr_dsjsonavt OUT NOCOPY json,             --> Retorno do clob em modelo json dos dados do avalista
                                      pr_cdcritic  OUT NUMBER,                  --> Codigo da critica
                                      pr_dscritic  OUT VARCHAR2) IS             --> Descricao da critica
  /* ..........................................................................
    
      Programa : pc_gera_json_pessoa_avt        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(AMcom)
      Data     : Maio/2017.                   Ultima atualizacao: 05/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por montar o objeto json contendo 
                  os dados do avalista terceiro.
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Objeto json
    vr_obj_generico json := json();
    vr_obj_generic2 json := json();
    vr_lst_generic2 json_list := json_list();

      
  BEGIN
  
    -- Enviaremos os dados b�sicos encontrados na tabela 
    vr_obj_generico.put('documento'      ,pr_rw_crapavt.nrcpfcgc);

    -- Para Pessoas Fisicas 
    IF pr_rw_crapavt.inpessoa = 1 THEN 
    
      vr_obj_generico.put('tipoPessoa','FISICA');
      vr_obj_generico.put('nome'           ,pr_rw_crapavt.nmdavali);
      vr_obj_generico.put('dataNascimento' ,este0001.fn_Data_ibra(pr_rw_crapavt.dtnascto));
      
      -- Se o Documento for RG
      IF pr_rw_crapavt.tpdocava = 'CI' THEN
        vr_obj_generico.put('rg'  , pr_rw_crapavt.nrdocava);
        vr_obj_generico.put('ufRg', pr_rw_crapavt.cdufddoc);
      END IF;
      
      vr_obj_generico.put('nomeMae'      ,pr_rw_crapavt.nmmaecto);
      vr_obj_generico.put('nacionalidade',pr_rw_crapavt.dsnacion);
      vr_obj_generico.put('sexo' ,pr_rw_crapavt.cdsexcto);
      
      -- Montar objeto profissao       
      IF pr_rw_crapavt.dsproftl <> ' ' THEN 
        vr_obj_generic2 := json();
        vr_obj_generic2.put('titulo'   , pr_rw_crapavt.dsproftl);
        vr_obj_generic2.put('profissao', vr_obj_generico);
      END IF;     

    ELSE
      vr_obj_generico.put('tipoPessoa'  ,'JURIDICA');
      vr_obj_generico.put('razaoSocial' ,pr_rw_crapavt.nmdavali);
      vr_obj_generico.put('dataFundacao',ESTE0001.fn_Data_ibra(pr_rw_crapavt.dtnascto));
    END IF;
    
    -- Montar objeto Telefone para Telefone Residencial/Comercial      
    IF pr_rw_crapavt.nrfonres <> ' ' THEN 
      vr_lst_generic2 := json_list();
      -- Criar objeto s� para este telefone
      vr_obj_generic2 := json();
      -- Montar Especie conforme tipo de Pessoa
      IF pr_rw_crapavt.inpessoa = 1 THEN
        vr_obj_generic2.put('especie', 'DOMICILIO'); 
      ELSE 
        vr_obj_generic2.put('especie', 'COMERCIAL'); 
      END IF;
      IF SUBSTR(pr_rw_crapavt.nrfonres,1,1) < 8 THEN 
        vr_obj_generic2.put('tipo', 'FIXO');
      ELSE
        vr_obj_generic2.put('tipo', 'MOVEL');
      END IF;
      vr_obj_generic2.put('numero', replace(replace(pr_rw_crapavt.nrfonres,'-',''),'.','')); 
      -- Adicionar telefone na lista
      vr_lst_generic2.append(vr_obj_generic2.to_json_value());
      -- Adicionar o array telefone no objeto
      vr_obj_generico.put('telefones', vr_lst_generic2);
    END IF;
    
    -- Montar objeto Endereco
    IF pr_rw_crapavt.dsendres##1 <> ' ' THEN 
      vr_obj_generic2 := json();

      vr_obj_generic2.put('logradouro'  , pr_rw_crapavt.dsendres##1);
      vr_obj_generic2.put('numero'      , pr_rw_crapavt.nrendere);
      vr_obj_generic2.put('complemento' , pr_rw_crapavt.complend);
      vr_obj_generic2.put('bairro'      , pr_rw_crapavt.dsendres##2);
      vr_obj_generic2.put('cidade'      , pr_rw_crapavt.nmcidade);
      vr_obj_generic2.put('uf'          , pr_rw_crapavt.cdufresd);
      vr_obj_generic2.put('cep'         , pr_rw_crapavt.nrcepend);

      vr_obj_generico.put('endereco', vr_obj_generic2);
     END IF;
     
     -- Montar informa��es Adicionais
     vr_obj_generic2 := json();

     -- Caixa Postal
     IF pr_rw_crapavt.nrcxapst <> 0 THEN 
       vr_obj_generico.put('caixaPostal', pr_rw_crapavt.nrcxapst);
     END IF;
     
     -- Somente para Pessoa Fisica
     IF pr_rw_crapavt.inpessoa = 1 THEN 

       -- Nome Pai
       IF pr_rw_crapavt.nmpaicto <> ' ' THEN 
         vr_obj_generico.put('nomePai', pr_rw_crapavt.nmpaicto);
       END IF;
       
       -- Estado Civil
       IF pr_rw_crapavt.cdestcvl <> 0 THEN 
         vr_obj_generico.put('estadoCivil', fn_des_cdestciv(pr_rw_crapavt.cdestcvl));
       END IF;
       
       -- Naturalidade
       IF pr_rw_crapavt.dsnatura <> ' ' THEN 
         vr_obj_generico.put('naturalidade', pr_rw_crapavt.dsnatura);
       END IF;

       -- Salario
       IF pr_rw_crapavt.vlrenmes <> 0 THEN 
         vr_obj_generic2.put('valorSalario', ESTE0001.fn_decimal_ibra(pr_rw_crapavt.vlrenmes));
       END IF;

       -- Outros Rendimentos
       IF pr_rw_crapavt. vloutren <> 0 THEN 
         vr_obj_generic2.put('valorOutrosRendim', ESTE0001.fn_decimal_ibra(pr_rw_crapavt.vloutren));
       END IF;

       -- Habilita��o Menor
       IF pr_rw_crapavt.inhabmen <> 0 THEN 
         vr_obj_generic2.put('reponsabiLegal', fn_des_inhabmen(pr_rw_crapavt.inhabmen));
       END IF;

       -- Data Emancipa��o
       IF pr_rw_crapavt.dthabmen IS NOT NULL THEN 
         vr_obj_generico.put('dataEmancipa' ,ESTE0001.fn_Data_ibra(pr_rw_crapavt.dthabmen));
       END IF;
       
       -- Data de Vig�ncia Procura��o
       IF pr_rw_crapavt.dtvalida IS NOT NULL THEN 
         vr_obj_generico.put('datVigenciaProcuracao' ,ESTE0001.fn_Data_ibra(pr_rw_crapavt.dtvalida));
       END IF;  

       -- Data de Admiss�o Procura��o
       IF pr_rw_crapavt.dtadmsoc IS NOT NULL THEN 
         vr_obj_generico.put('datAdmissaoProcuracao' ,ESTE0001.fn_Data_ibra(pr_rw_crapavt.dtadmsoc));
       END IF;  


     ELSE
       -- Faturamento Annual � Rendimento M�s + Outros * 12
       IF pr_rw_crapavt.vlrenmes + pr_rw_crapavt. vloutren <> 0 THEN 
         vr_obj_generic2.put('valorFaturamentoAnual', ESTE0001.fn_decimal_ibra((pr_rw_crapavt.vlrenmes +
                                                                                pr_rw_crapavt.vloutren)*12));
       END IF;
       
     END IF;
     
     -- Enviar informa��es adicionais ao JSON 
     vr_obj_generico.put('informacoesAdicionais' ,vr_obj_generic2);        
              
     -- Ao final copiamos o json montado ao retornado
     pr_dsjsonavt := vr_obj_generico;
    
    
  EXCEPTION
    WHEN OTHERS THEN  
      pr_cdcritic := 0;   
      pr_dscritic := 'Erro ao montar dados json avalista: '||SQLERRM;
  END pc_gera_json_pessoa_avt;
  
  --> Rotina responsavel por montar o objeto json para analise
  PROCEDURE pc_gera_json_analise ( pr_cdcooper   IN crapass.cdcooper%TYPE   --> Codigo da cooperativa
                                  ,pr_cdagenci   IN crapass.cdagenci%TYPE   --> Codigo da cooperativa
                                  ,pr_nrdconta   IN crapass.nrdconta%TYPE   --> Codigo da cooperativa
                                  ,pr_nrctremp   IN crapepr.nrctremp%TYPE   --> Codigo da cooperativa
                                  ,pr_nrctaav1   IN crapepr.nrctaav1%TYPE   --> Codigo da cooperativa
                                  ,pr_nrctaav2   IN crapepr.nrctaav2%TYPE   --> Codigo da cooperativa
                                  ---- OUT ----
                                  ,pr_dsjsonan  OUT NOCOPY json             --> Retorno do clob em modelo json com os dados para analise
                                  ,pr_cdcritic  OUT NUMBER                  --> Codigo da critica
                                  ,pr_dscritic  OUT VARCHAR2) IS            --> Descricao da critica
  /* ..........................................................................
    
      Programa : pc_gera_json_analise        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(AMcom)
      Data     : Maio/2017.                   Ultima atualizacao: 09/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por montar o objeto json para analise.
    
      Altera��o : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
	  -- Buscar quantidade de dias de reaproveitamento   		
		CURSOR cr_craprbi IS
		  SELECT rbi.qtdiarpv
			  FROM craprbi rbi
				    ,crapass ass
						,crawepr epr
			 WHERE ass.cdcooper = pr_cdcooper
				 AND ass.nrdconta = pr_nrdconta
				 AND epr.cdcooper = pr_cdcooper
				 AND epr.nrdconta = pr_nrdconta
				 AND epr.nrctremp = pr_nrctremp
				 AND epr.dsoperac IN('EMPRESTIMO','FINANCIAMENTO')
				 AND rbi.cdcooper = pr_cdcooper
			   AND rbi.inpessoa = ass.inpessoa
				 AND rbi.inprodut = decode(epr.dsoperac, 'EMPRESTIMO', 1, 'FINANCIAMENTO',2, 0);
		rw_craprbi cr_craprbi%ROWTYPE;
		
		-- Buscar PA do operador de envio da proposta
		CURSOR cr_crapope IS
		  SELECT ope.cdpactra
			  FROM crapope ope
				    ,crawepr epr
			 WHERE epr.cdcooper = pr_cdcooper
			   AND epr.nrdconta = pr_nrdconta
				 AND epr.nrctremp = pr_nrctremp
			   AND ope.cdcooper = pr_cdcooper
			   AND upper(ope.cdoperad) = upper(epr.cdoperad);
		vr_cdpactra crapope.cdpactra%TYPE;
		
		-- Buscar �ltima data de consulta ao bacen
		CURSOR cr_crapopf IS
	    SELECT opf.dtrefere
			  FROM crapopf opf
				    ,crapass ass
			 WHERE ass.cdcooper = pr_cdcooper
			   AND ass.nrdconta = pr_nrdconta
				 AND opf.nrcpfcgc = ass.nrcpfcgc
			 ORDER BY dtrefere DESC;
		rw_crapopf cr_crapopf%ROWTYPE;
		
    --> Buscar dados da proposta
    CURSOR cr_crawepr IS
      SELECT lcr.dsoperac
            ,lcr.flgreneg
            ,wpr.vlemprst
            ,wpr.vlpreemp
            ,wpr.qtpreemp
            ,wpr.dtvencto
            ,lcr.cdlcremp
            ,lcr.dslcremp
            ,decode(wpr.tpemprst,1,'PP','TR') tpproduto
            ,lcr.tpctrato
            -- Indica que am linha de credito eh CDC ou C DC
            ,DECODE(instr(replace(UPPER(lcr.dslcremp),'C DC','CDC'),'CDC'),0,0,1) inlcrcdc
            ,fin.cdfinemp
            ,fin.dsfinemp
            ,wpr.inconcje
            ,wpr.idquapro
            ,TO_CHAR(WPR.NRCTRLIQ##1) || ',' || TO_CHAR(WPR.NRCTRLIQ##2) || ',' ||
             TO_CHAR(WPR.NRCTRLIQ##3) || ',' || TO_CHAR(WPR.NRCTRLIQ##4) || ',' ||
             TO_CHAR(WPR.NRCTRLIQ##5) || ',' || TO_CHAR(WPR.NRCTRLIQ##6) || ',' ||
             TO_CHAR(WPR.NRCTRLIQ##7) || ',' || TO_CHAR(WPR.NRCTRLIQ##8) || ',' ||
             TO_CHAR(WPR.NRCTRLIQ##9) || ',' || TO_CHAR(WPR.NRCTRLIQ##10) dsliquid
             ,ass.nrcpfcgc
             ,ass.inpessoa
        FROM crawepr wpr
            ,craplcr lcr
            ,crapfin fin      
            ,crapass ass
       WHERE wpr.cdcooper = lcr.cdcooper
         AND wpr.cdlcremp = lcr.cdlcremp
         AND wpr.cdcooper = fin.cdcooper 
         AND wpr.cdfinemp = fin.cdfinemp
         AND wpr.cdcooper = ass.cdcooper
         AND wpr.nrdconta = ass.nrdconta
         AND wpr.cdcooper = pr_cdcooper
         AND wpr.nrdconta = pr_nrdconta
         AND wpr.nrctremp = pr_nrctremp;
    rw_crawepr cr_crawepr%ROWTYPE;
    
    -- Buscar os dados do associado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%type,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa,
             ass.inhabmen,
             ass.dtnasctl
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Buscar avalistas terceiros
    CURSOR cr_crapavt(pr_cdcooper crapass.cdcooper%TYPE,
                      pr_nrdconta crapass.nrdconta%TYPE,
                      pr_nrctremp crapavt.nrctremp%TYPE,
                      pr_tpctrato crapavt.tpctrato%TYPE,
                      pr_dsproftl crapavt.dsproftl%TYPE) IS
      SELECT crapavt.* --> necessario ser todos os campos pois envia como parametro
        FROM crapavt
       WHERE crapavt.cdcooper = pr_cdcooper
         AND crapavt.nrdconta = pr_nrdconta
         AND crapavt.nrctremp = pr_nrctremp
         AND crapavt.tpctrato = pr_tpctrato
         AND (   pr_dsproftl IS NULL 
               OR ( pr_dsproftl = 'SOCIO' AND dsproftl IN('SOCIO/PROPRIETARIO'
                                                         ,'SOCIO ADMINISTRADOR'
                                                         ,'DIRETOR/ADMINISTRADOR'
                                                         ,'SINDICO'
                                                         ,'ADMINISTRADOR'))
               OR ( pr_dsproftl = 'PROCURADOR' AND dsproftl LIKE UPPER('%PROCURADOR%'))
              );
    rw_crapavt cr_crapavt%ROWTYPE;
    
    --> Buscar cadastro do Conjuge:
    CURSOR cr_crapcje (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT crapcje.nrctacje
            ,crapcje.nmconjug
            ,crapcje.nrcpfcjg
            ,crapcje.dtnasccj
            ,crapcje.tpdoccje
            ,crapcje.nrdoccje
            ,crapcje.grescola
            ,crapcje.cdfrmttl
            ,crapcje.cdnatopc
            ,crapcje.cdocpcje
            ,crapcje.tpcttrab
            ,crapcje.dsproftl
            ,crapcje.cdnvlcgo
            ,crapcje.nrfonemp
            ,crapcje.nrramemp
            ,crapcje.cdturnos
            ,crapcje.dtadmemp
            ,crapcje.vlsalari
            ,crapcje.nrdocnpj
            ,crapcje.cdufdcje
       FROM crapcje
      WHERE crapcje.cdcooper = pr_cdcooper
        AND crapcje.nrdconta = pr_nrdconta
        AND crapcje.idseqttl = 1;
    rw_crapcje cr_crapcje%ROWTYPE;
    
    --> Buscar representante legal
    CURSOR cr_crapcrl (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT crapcrl.cdcooper
            ,crapcrl.nrctamen
            ,crapcrl.idseqmen
            ,crapcrl.nrdconta
            ,crapcrl.nrcpfcgc
            ,crapcrl.nmrespon
            ,crapcrl.dsorgemi
            ,crapcrl.cdufiden
            ,crapcrl.dtemiden
            ,crapcrl.dtnascin
            ,crapcrl.cddosexo
            ,crapcrl.cdestciv
            ,crapcrl.dsnacion
            ,crapcrl.dsnatura
            ,crapcrl.cdcepres
            ,crapcrl.dsendres
            ,crapcrl.nrendres
            ,crapcrl.dscomres
            ,crapcrl.dsbaires
            ,crapcrl.nrcxpost
            ,crapcrl.dscidres
            ,crapcrl.dsdufres
            ,crapcrl.nmpairsp
            ,crapcrl.nmmaersp
            ,crapcrl.tpdeiden
            ,crapcrl.nridenti
            ,crapcrl.cdrlcrsp
        FROM crapcrl
       WHERE crapcrl.cdcooper = pr_cdcooper
         AND crapcrl.nrctamen = pr_nrdconta;
    
    -- Declarar cursor de participa��es societ�rias
    CURSOR cr_crapepa (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT cdcooper, 
             nrdconta, 
             nrdocsoc, 
             nrctasoc, 
             nmfansia, 
             nrinsest, 
             natjurid, 
             dtiniatv, 
             qtfilial, 
             qtfuncio, 
             dsendweb, 
             cdseteco, 
             cdmodali, 
             cdrmativ, 
             vledvmto, 
             dtadmiss, 
             dtmvtolt, 
             persocio, 
             nmprimtl
        FROM crapepa 
       WHERE cdcooper = pr_cdcooper 
         AND nrdconta = pr_nrdconta;
    
    -- Buscar descri��o
    CURSOR cr_nature (pr_natjurid gncdntj.cdnatjur%TYPE) IS
      SELECT gncdntj.dsnatjur
        FROM gncdntj
       WHERE gncdntj.cdnatjur = pr_natjurid;
    rw_nature cr_nature%ROWTYPE; 
    
    -- Buscar descri��o
    CURSOR cr_gnrativ ( pr_cdseteco gnrativ.cdseteco%TYPE,
                        pr_cdrmativ gnrativ.cdrmativ%TYPE)IS
      SELECT gnrativ.nmrmativ
        FROM gnrativ
       WHERE gnrativ.cdseteco = pr_cdseteco
         AND gnrativ.cdrmativ = pr_cdrmativ;    
    rw_gnrativ cr_gnrativ%ROWTYPE;
    
    
    -- Buscar os bens em garanita na Proposta
    CURSOR cr_crapbpr (pr_cdcooper crapass.cdcooper%type,
                       pr_nrdconta crapass.nrdconta%TYPE,
                       pr_nrctremp crawepr.nrctremp%TYPE ) IS       
      SELECT crapbpr.dscatbem
            ,crapbpr.vlmerbem
            ,crapbpr.nranobem
            ,crapbpr.nrcpfbem
        FROM crapbpr 
       WHERE crapbpr.cdcooper = pr_cdcooper
         AND crapbpr.nrdconta = pr_nrdconta
         AND crapbpr.nrctrpro = pr_nrctremp   
         AND crapbpr.tpctrpro = 90
         AND trim(crapbpr.dscatbem) is not NULL;
    
    
    --> Buscar se a conta � de Colaborador Cecred
    CURSOR cr_tbcolab(pr_cdcooper crapcop.cdcooper%TYPE
                     ,pr_nrcpfcgc crapass.nrcpfcgc%TYPE) IS 
                     
      SELECT substr(lpad(col.cddcargo_vetor,7,'0'),5,3) cddcargo
        FROM tbcadast_colaborador col       
       WHERE col.cdcooper = pr_cdcooper
         AND col.nrcpfcgc = pr_nrcpfcgc
         AND col.flgativo = 'A';         
				 
    CURSOR cr_crapprp IS
		  SELECT prp.flgdocje
			  FROM crapprp prp
			 WHERE prp.cdcooper = pr_cdcooper
			   AND prp.nrdconta = pr_nrdconta
				 AND prp.nrctrato = pr_nrctremp
				 AND prp.tpctrato = 90;
		rw_crapprp cr_crapprp%ROWTYPE;
   
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
     
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(500);
    vr_exc_erro EXCEPTION;

    -- Objeto json    
    vr_obj_analise   json      := json();
    vr_obj_conjuge   json      := json();
    vr_obj_avalista  json      := json();
    vr_obj_responsav json      := json();
    vr_obj_socio     json      := json();
    vr_obj_particip  json      := json();
    vr_obj_procurad  json      := json();
    vr_obj_generico  json      := json();
    vr_obj_generic2  json      := json();
    vr_lst_generico  json_list := json_list();
    vr_lst_generic2  json_list := json_list();
    
    vr_flavalis      BOOLEAN := FALSE;
    vr_flrespvl      BOOLEAN := FALSE;
    vr_flsocios      BOOLEAN := FALSE;
    vr_flpartic      BOOLEAN := FALSE;
    vr_flprocura     BOOLEAN := FALSE;
    vr_nrdeanos      INTEGER;
    vr_nrdmeses      INTEGER;
    vr_dsdidade      VARCHAR2(100);
    vr_dstextab      craptab.dstextab%TYPE;
    vr_nmseteco      craptab.dstextab%TYPE;
    vr_dstpgara      craptab.dstextab%TYPE;
    vr_dsquapro      VARCHAR2(100);
    vr_flgcolab      BOOLEAN;
    vr_cddcargo      tbcadast_colaborador.cdcooper%TYPE;
		vr_qtdiarpv      INTEGER;
    
      
  BEGIN
  
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se n�o encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;  
  
    vr_obj_analise.put('proposta', gene0002.fn_mask_contrato(pr_nrctremp));
                      
	  -- Buscar quantidade de dias de reaproveitamento             
    OPEN cr_craprbi;
		FETCH cr_craprbi INTO rw_craprbi;
		
		-- Se encontrou
		IF cr_craprbi%FOUND THEN
			-- Buscar a coluna e multiplicar por 24 para chegarmos na quantidade de horas de reaproveitamento
			vr_qtdiarpv := rw_craprbi.qtdiarpv * 24;
		ELSE
			-- Se n�o encontrar consideramos 168 horas (7 dias)
			vr_qtdiarpv := 168;
		END IF;
    CLOSE cr_craprbi;
		
		-- Buscar PA do operador
		OPEN cr_crapope;
		FETCH cr_crapope INTO vr_cdpactra;
		
		OPEN cr_crapopf;
		FETCH cr_crapopf INTO rw_crapopf;
		
		-- Montar os atributos de 'configuracoes'
		vr_obj_generico := json();
		vr_obj_generico.put('centroCusto', vr_cdpactra);
		vr_obj_generico.put('dataBaseBacen', este0001.fn_Data_ibra(nvl(rw_crapopf.dtrefere, rw_crapdat.dtmvtolt)));
		vr_obj_generico.put('horasReaproveitamento', vr_qtdiarpv);
		
    -- Adicionar o array configuracoes
    vr_obj_analise.put('configuracoes', vr_obj_generico);																	 
																	 
    --> Buscar dados da proposta de emprestimo
    OPEN cr_crawepr;
    FETCH cr_crawepr INTO rw_crawepr;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crawepr%NOTFOUND THEN
      CLOSE cr_crawepr;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crawepr;
    
    --> indicadoresCliente
    vr_obj_generico := json();
    
    vr_obj_generico.put('cooperativa', pr_cdcooper); 
    vr_obj_generico.put('agenci', pr_cdagenci);

    -- Se for CDC
    IF rw_crawepr.inlcrcdc = 1 THEN  
      vr_obj_generico.put('segmentoCodigo'    ,0); 
      vr_obj_generico.put('segmentoDescricao' ,'CDC Diversos');  
      vr_obj_generico.put('linhaCreditoCodigo'    ,'');
      vr_obj_generico.put('linhaCreditoDescricao' ,'');
      vr_obj_generico.put('finalidadeCodigo'      ,''); 
      vr_obj_generico.put('finalidadeDescricao'   ,'');   
    ELSE

      vr_obj_generico.put('segmentoCodigo' ,2); -- Emprestimos/Financiamento 
      vr_obj_generico.put('segmentoDescricao' ,'Emprestimos/Financiamento');   
      vr_obj_generico.put('linhaCreditoCodigo'    ,rw_crawepr.cdlcremp);
      vr_obj_generico.put('linhaCreditoDescricao' ,rw_crawepr.dslcremp);
      vr_obj_generico.put('finalidadeCodigo'      ,rw_crawepr.cdfinemp);       
      vr_obj_generico.put('finalidadeDescricao'   ,rw_crawepr.dsfinemp);                
    END IF;
    
    vr_obj_generico.put('tipoProduto'           ,rw_crawepr.tpproduto);
    vr_obj_generico.put('tipoGarantiaCodigo'    ,rw_crawepr.tpctrato );
    
    --> Buscar descri��o do tipo de garantia
    vr_dstpgara  := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                               pr_nmsistem => 'CRED',
                                               pr_tptabela => 'GENERI', 
                                               pr_cdempres => 0, 
                                               pr_cdacesso => 'CTRATOEMPR', 
                                               pr_tpregist => rw_crawepr.tpctrato);    
                                               
    vr_obj_generico.put('tipoGarantiaDescricao'    ,TRIM(vr_dstpgara) );

    vr_obj_generico.put('valorEmprest'  , ESTE0001.fn_decimal_ibra(rw_crawepr.vlemprst));
    vr_obj_generico.put('quantParcela'  , rw_crawepr.qtpreemp);
    vr_obj_generico.put('primeiroVencto', ESTE0001.fn_Data_ibra(rw_crawepr.dtvencto));
    vr_obj_generico.put('valorParcela'  , ESTE0001.fn_decimal_ibra(rw_crawepr.vlpreemp));

    vr_obj_generico.put('renegociacao', rw_crawepr.flgreneg = 1);

    vr_obj_generico.put('qualificaOperacaoCodigo'    ,rw_crawepr.idquapro );

    CASE rw_crawepr.idquapro
      WHEN 1 THEN vr_dsquapro := 'Operacao normal';
      WHEN 2 THEN vr_dsquapro := 'Renovacao de credito';
      WHEN 3 THEN vr_dsquapro := 'Renegociacao de credito';
      WHEN 4 THEN vr_dsquapro := 'Composicao da divida';
      ELSE vr_dsquapro := ' ';
    END CASE;

    vr_obj_generico.put('qualificaOperacaoDescricao'    ,vr_dsquapro );
         
    IF rw_crawepr.inpessoa = 1 THEN 
      -- Verificar se a conta � de colaborador do sistema Cecred
      vr_cddcargo := NULL;
      OPEN cr_tbcolab(pr_cdcooper => pr_cdcooper
                     ,pr_nrcpfcgc => rw_crawepr.nrcpfcgc);
      FETCH cr_tbcolab INTO vr_cddcargo;
      IF cr_tbcolab%FOUND THEN 
        vr_flgcolab := TRUE;
      ELSE
        vr_flgcolab := FALSE;
      END IF;
      CLOSE cr_tbcolab; 
              
      vr_obj_generico.put('cooperadoColaborador',vr_flgcolab);
			
			OPEN cr_crapprp;
			FETCH cr_crapprp INTO rw_crapprp;
			CLOSE cr_crapprp;
      vr_obj_generico.put('conjugeCoResponv',nvl(rw_crapprp.flgdocje,0)=1);

    END IF;
    
    -- Efetuar la�o para trazer todos os registros 
    FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_nrctremp => pr_nrctremp )  LOOP 

      -- Para cada registro de Bem, criar objeto para a opera��o e enviar suas informa��es 
			vr_lst_generic2 := json_list();
      vr_obj_generic2 := json();
      vr_obj_generic2.put('categoriaBem',     rw_crapbpr.dscatbem);
      vr_obj_generic2.put('anoGarantia',      rw_crapbpr.nranobem);
      vr_obj_generic2.put('valorGarantia',    ESTE0001.fn_decimal_ibra(rw_crapbpr.vlmerbem));
      vr_obj_generic2.put('bemInterveniente', rw_crapbpr.nrcpfbem <> 0);


      -- Adicionar Bem na lista
      vr_lst_generic2.append(vr_obj_generic2.to_json_value());
  
    END LOOP; -- Final da leitura dos Bens

    -- Adicionar o array bemEmGarantia
    vr_obj_generico.put('bemEmGarantia', vr_lst_generic2);

    vr_obj_generico.put('operacao', rw_crawepr.dsoperac); 
    vr_obj_analise.put('indicadoresCliente', vr_obj_generico);         
    
    pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp
                           ,pr_flprepon => true
                           ,pr_dsjsonan => vr_obj_generico
                           ,pr_cdcritic => vr_cdcritic 
                           ,pr_dscritic => vr_dscritic);
                           
     -- Testar poss�veis erros na rotina:
     IF nvl(vr_cdcritic,0) <> 0 OR 
        trim(vr_dscritic) IS NOT NULL THEN 
       RAISE vr_exc_erro;
     END IF;    
       
    -- Adicionar o JSON montado do Proponente no objeto principal
    vr_obj_analise.put('proponente',vr_obj_generico);
    
    rw_crapass := NULL;
    --> Buscar dados do associado
    OPEN cr_crapass(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);
    FETCH cr_crapass INTO rw_crapass;
    
    -- Caso nao encontrar abortar proceso
    IF cr_crapass%NOTFOUND THEN
      CLOSE cr_crapass;
      vr_cdcritic := 9;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_crapass;
    
    --> Para Pessoa Fisica iremos buscar seu Conjuge
    IF rw_crapass.inpessoa = 1 THEN 
    
      --> Buscar cadastro do Conjuge
      rw_crapcje := NULL;
      OPEN cr_crapcje( pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapcje INTO rw_crapcje;
     
      -- Se n�o encontrar 
      IF cr_crapcje%NOTFOUND THEN
        -- apenas fechamos o cursor
        CLOSE cr_crapcje;
      ELSE   
        -- Fechar o cursor e enviar 
        CLOSE cr_crapcje;
        --> Se Conjuge for associado:
        IF rw_crapcje.nrctacje <> 0 THEN 

          -- Passaremos a conta para montagem dos dados:
          pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapcje.nrctacje
                                 ,pr_nrctremp => pr_nrctremp
                                 ,pr_dsjsonan => vr_obj_conjuge
                                 ,pr_cdcritic => vr_cdcritic 
                                 ,pr_dscritic => vr_dscritic);

          -- Testar poss�veis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF; 
            
          -- Adicionar o JSON montado do Proponente no objeto principal
          vr_obj_analise.put('conjuge',vr_obj_conjuge);

        ELSE
          -- Enviaremos os dados b�sicos encontrados na tabela de conjugue
          vr_obj_conjuge.put('documento'      ,rw_crapcje.nrcpfcjg);
          vr_obj_conjuge.put('tipoPessoa'     ,'FISICA');
          vr_obj_conjuge.put('nome'           ,rw_crapcje.nmconjug);
          vr_obj_conjuge.put('dataNascimento' ,ESTE0001.fn_Data_ibra(rw_crapcje.dtnasccj));
          
          -- Se o Documento for RG
          IF rw_crapcje.tpdoccje = 'CI' THEN
            vr_obj_conjuge.put('rg', rw_crapcje.nrdoccje);
            vr_obj_conjuge.put('ufRg', rw_crapcje.cdufdcje);
          END IF;
          
          -- Montar objeto Telefone para Telefone Comercial      
          IF rw_crapcje.nrfonemp <> ' ' THEN 
            vr_lst_generic2 := json_list();
            -- Criar objeto s� para este telefone
            vr_obj_generico := json();
            vr_obj_generico.put('especie', 'COMERCIAL');
            IF SUBSTR(rw_crapcje.nrfonemp,1,1) < 8 THEN 
              vr_obj_generico.put('tipo', 'FIXO');
            ELSE
              vr_obj_generico.put('tipo', 'MOVEL');
            END IF;
            
            vr_obj_generico.put('numero', replace(replace(rw_crapcje.nrfonemp,'-',''),'.',''));
            -- Adicionar telefone na lista
            vr_lst_generic2.append(vr_obj_generico.to_json_value());
            -- Adicionar o array telefone no objeto Conjuge
            vr_obj_conjuge.put('telefones', vr_lst_generic2);
              
          END IF;     

          -- Montar objeto profissao       
          IF rw_crapcje.dsproftl <> ' ' THEN 
            vr_obj_generico := json();
            vr_obj_generico.put('titulo'   , rw_crapcje.dsproftl);
            vr_obj_conjuge.put ('profissao', vr_obj_generico);
          END IF;     
          
          -- Montar informa��es Adicionais
          vr_obj_generico := json();
          -- Escolaridade
          IF rw_crapcje.grescola <> 0 THEN 
            vr_obj_generico.put('escolaridade', fn_des_grescola(rw_crapcje.grescola));
          END IF;
          -- Curso Superior
          IF rw_crapcje.cdfrmttl <> 0 THEN 
            vr_obj_generico.put('cursoSuperior', fn_des_cdfrmttl(rw_crapcje.cdfrmttl));
          END IF;
          -- Natureza Ocupa��o
          IF rw_crapcje.cdnatopc <> 0 THEN 
            vr_obj_generico.put('naturezaOcupacao', fn_des_cdnatopc(rw_crapcje.cdnatopc));
          END IF;
          -- Ocupa��o
          IF rw_crapcje.cdocpcje <> 0 THEN 
            vr_obj_generico.put('ocupacao', fn_des_cdocupa(rw_crapcje.cdocpcje));
          END IF;
          -- Tipo Contrato de Trabalho
          IF rw_crapcje.tpcttrab <> 0 THEN 
            vr_obj_generico.put('tipoContratoTrabalho', fn_des_tpcttrab(rw_crapcje.cdocpcje));
          END IF;
          -- Nivel Cargo
          IF rw_crapcje.cdnvlcgo <> 0 THEN 
            vr_obj_generico.put('nivelCargo', fn_des_cdnvlcgo(rw_crapcje.cdnvlcgo));
          END IF;
          -- Turno
          IF rw_crapcje.cdturnos <> 0 THEN 
            vr_obj_generico.put('turno', fn_des_cdturnos(rw_crapcje.cdturnos));
          END IF;
          -- Data Admiss�o
          IF rw_crapcje.dtadmemp IS NOT NULL THEN 
            vr_obj_generico.put('dataAdmissao', ESTE0001.fn_Data_ibra(rw_crapcje.dtadmemp));
          END IF;
          -- Salario
          IF rw_crapcje.vlsalari <> 0 THEN 
            vr_obj_generico.put('valorSalario', ESTE0001.fn_decimal_ibra(rw_crapcje.vlsalari));
          END IF;
          -- CNPJ Empresa
          IF rw_crapcje.nrdocnpj <> 0 THEN 
            vr_obj_generico.put('codCNPJEmpresa', rw_crapcje.nrdocnpj);
          END IF;
          -- Enviar informa��es adicionais ao JSON Conjuge
          vr_obj_conjuge.put('informacoesAdicionais' ,vr_obj_generico);        
              
          -- Ao final adicionamos o json montado ao principal
          vr_obj_analise.put('conjuge' ,vr_obj_conjuge);        
        END IF; 
        
      END IF;  
      
    END IF;
    
    --> BUSCAR AVALISTAS INTERNOS E EXTERNOS: 
    -- Inicializar lista de Avalistas
    vr_lst_generico := json_list();
 
    -- Enviar avalista 01 em novo json s� para avalistas
    IF nvl(pr_nrctaav1,0) <> 0 THEN
      -- Setar flag para indicar que h� avalista
      vr_flavalis := true;
      

      pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrctaav1
                             ,pr_nrctremp => pr_nrctremp
                             ,pr_dsjsonan => vr_obj_avalista
                             ,pr_cdcritic => vr_cdcritic 
                             ,pr_dscritic => vr_dscritic);

      -- Testar poss�veis erros na rotina:
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro;
      END IF;

      -- Adicionar o avalista montato na lista de avalistas
      vr_lst_generico.append(vr_obj_avalista.to_json_value());

    END IF;
    
    -- Enviar avalista 02 em novo json s� para avalistas
    IF nvl(pr_nrctaav2,0) <> 0 THEN
      -- Setar flag para indicar que h� avalista
      vr_flavalis := true;
      
      pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrctaav2
                             ,pr_nrctremp => pr_nrctremp
                             ,pr_dsjsonan => vr_obj_avalista
                             ,pr_cdcritic => vr_cdcritic 
                             ,pr_dscritic => vr_dscritic);

      -- Testar poss�veis erros na rotina:
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro;
      END IF;

      -- Adicionar o avalista montato na lista de avalistas
      vr_lst_generico.append(vr_obj_avalista.to_json_value());

    END IF;
    
    --> Efetuar la�o para retornar todos os registros dispon�veis:
    FOR rw_crapavt IN cr_crapavt( pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta 
                                 ,pr_nrctremp => pr_nrctremp
                                 ,pr_tpctrato => 1
                                 ,pr_dsproftl => null) LOOP
                                 
      -- Setar flag para indicar que h� avalista
      vr_flavalis := true;
      -- Enviaremos os dados b�sicos encontrados na tabela de avalistas terceiros 
      pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                             ,pr_dsjsonavt  => vr_obj_avalista
                             ,pr_cdcritic   => vr_cdcritic 
                             ,pr_dscritic   => vr_dscritic);
      -- Testar poss�veis erros na rotina:
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro;
      END IF; 
      
      -- Adicionar o avalista montato na lista de avalistas
      vr_lst_generico.append(vr_obj_avalista.to_json_value());
      
      
    END LOOP; --> crapavt                             
    
    -- Enviar novo objeto de avalistas para dentro do objeto principal (Se houve encontro) 
    IF vr_flavalis = true THEN
      vr_obj_analise.put('avalistas' , vr_lst_generico);
    END IF; 
  
    --> Para pessoa f�sica verificaremos necessidade de envio dos respons�veis legais:
    IF rw_crapass.inpessoa = 1 THEN 
         
       -- Inicializar idade
       vr_nrdeanos := 18;    
       -- Se menor de idade 
       IF rw_crapass.inhabmen = 0  THEN 
         -- Verifica a idade
         cada0001.pc_busca_idade(pr_dtnasctl => rw_crapass.dtnasctl
                                ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                                ,pr_nrdeanos => vr_nrdeanos
                                ,pr_nrdmeses => vr_nrdmeses
                                ,pr_dsdidade => vr_dsdidade
                                ,pr_des_erro => vr_dscritic);

         -- Verficia se ocorreram erros
         IF vr_dscritic IS NOT NULL THEN
           vr_nrdeanos := 18;
         END IF;
       END IF;
    
      -- Se menor de idade ou incapaz
      IF vr_nrdeanos < 18 OR rw_crapass.inhabmen = 2 THEN
      
        -- Inicializar lista de Representantes
        vr_lst_generico := json_list();
        
        --> Efetuar la�o para retornar todos os registros dispon�veis
        FOR rw_crapcrl IN cr_crapcrl ( pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta ) LOOP
          -- Setar flag para indicar que h� responsaveis
          vr_flrespvl := true;
          
          --> Se Respons�vel for associado
          IF rw_crapcrl.nrdconta <> 0 THEN 
            -- Passaremos a conta para montagem dos dados:
            pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => rw_crapcrl.nrdconta
                                   ,pr_nrctremp => pr_nrctremp
                                   ,pr_dsjsonan => vr_obj_responsav
                                   ,pr_cdcritic => vr_cdcritic 
                                   ,pr_dscritic => vr_dscritic); 
            -- Testar poss�veis erros na rotina:
            IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
              RAISE vr_exc_erro;
            END IF;
            
            -- Adicionar o avalista montato na lista de avalistas
            vr_lst_generico.append(vr_obj_responsav.to_json_value());

         ELSE
           -- Enviaremos os dados b�sicos encontrados na tabela de respons�vel legal
           vr_obj_responsav.put('documento'      ,rw_crapcrl.nrcpfcgc);
           vr_obj_responsav.put('tipoPessoa'     ,'FISICA');
           vr_obj_responsav.put('nome'           ,rw_crapcrl.nmrespon);
           
           IF rw_crapcrl.dtnascin IS NOT NULL THEN 
             vr_obj_responsav.put('dataNascimento' ,ESTE0001.fn_Data_ibra(rw_crapcrl.dtnascin));
           END IF;
           
           IF rw_crapcrl.nmmaersp IS NOT NULL THEN 
             vr_obj_responsav.put('nomeMae' ,rw_crapcrl.nmmaersp);
           END IF;
           
           IF rw_crapcrl.cddosexo <> 0 THEN 
             vr_obj_responsav.put('sexo' ,rw_crapcrl.cddosexo);
           END IF;
           vr_obj_responsav.put('nacionalidade'  ,rw_crapcrl.dsnacion);

           -- Se o Documento for RG
           IF rw_crapcrl.tpdeiden = 'CI' THEN
             vr_obj_responsav.put('rg', rw_crapcrl.nridenti);
             vr_obj_responsav.put('ufRg', rw_crapcrl.cdufiden);
           END IF; 

           -- Montar objeto Endereco
           IF rw_crapcrl.dsendres <> ' ' THEN 
             vr_obj_generico := json();
     
             vr_obj_generico.put('logradouro'  , rw_crapcrl.dsendres);
             vr_obj_generico.put('numero'      , rw_crapcrl.nrendres);
             vr_obj_generico.put('complemento' , rw_crapcrl.dscomres);
             vr_obj_generico.put('bairro'      , rw_crapcrl.dsbaires);
             vr_obj_generico.put('cidade'      , rw_crapcrl.dscidres);
             vr_obj_generico.put('uf'          , rw_crapcrl.dsdufres);
             vr_obj_generico.put('cep'         , rw_crapcrl.cdcepres);

             vr_obj_responsav.put('endereco', vr_obj_generico);
           END IF;     
        
           -- Montar informa��es Adicionais
           vr_obj_generico := json();
           
           -- Nome Pai
           IF rw_crapcrl.nmpairsp <> ' ' THEN 
             vr_obj_generico.put('nomePai', rw_crapcrl.nmpairsp);
           END IF;
           -- Estado Civil
           IF rw_crapcrl.cdestciv <> 0 THEN 
             vr_obj_generico.put('estadoCivil', fn_des_cdestciv(rw_crapcrl.cdestciv));
           END IF;
           -- Naturalidade
           IF rw_crapcrl.dsnatura <> ' ' THEN 
             vr_obj_generico.put('naturalidade', rw_crapcrl.dsnatura);
           END IF;
           -- Caixa Postal
           IF rw_crapcrl. nrcxpost <> 0 THEN 
             vr_obj_generico.put('caixaPostal', rw_crapcrl.nrcxpost);
           END IF;
     
           -- Enviar informa��es adicionais ao JSON Responsavel Leval
           vr_obj_responsav.put('informacoesAdicionais' ,vr_obj_generico);     

           -- Adicionar o responsavel montato na lista de responsaveis
           vr_lst_generico.append(vr_obj_responsav.to_json_value());
         END IF;
          
          
        END LOOP; --> crapcrl  
        
        -- Enviar novo objeto de responsaveis para dentro do objeto principal
        -- (Somente se encontramos)
        IF vr_flrespvl THEN 
          vr_obj_analise.put('representantesLegais' ,vr_lst_generico);    
        END IF;
                
      END IF;
    END IF; -- INPESSOA
    
    --> Para pessoa Jur�dica buscaremos os s�cios da Empresa:
    IF rw_crapass.inpessoa = 2 THEN
    
      -- Inicializar lista de Representantes
      vr_lst_generico := json_list();
    
      --> Efetuar la�o para retornar todos os registros dispon�veis:
      FOR rw_crapavt IN cr_crapavt( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta 
                                   ,pr_nrctremp => 0
                                   ,pr_tpctrato => 6
                                   ,pr_dsproftl => 'SOCIO') LOOP 
    
        -- Setar flag para indicar que h� s�cio
        vr_flsocios := true;
        -- Se socio for associado
        IF rw_crapavt.nrdctato > 0 THEN 
          -- Passaremos a conta para montagem dos dados:

          pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapavt.nrdconta
                                 ,pr_nrctremp => pr_nrctremp
                                 ,pr_dsjsonan => vr_obj_socio
                                 ,pr_cdcritic => vr_cdcritic 
                                 ,pr_dscritic => vr_dscritic);
          -- Testar poss�veis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF;  
          
          -- Adicionar o responsavel montato na lista de socios
          vr_lst_generico.append(vr_obj_socio.to_json_value());

        ELSE
          -- Enviaremos os dados b�sicos encontrados na tabela de socios
          pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                                 ,pr_dsjsonavt  => vr_obj_socio
                                 ,pr_cdcritic   => vr_cdcritic 
                                 ,pr_dscritic   => vr_dscritic);
          -- Testar poss�veis er ros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF; 
          -- Adicionar o responsavel montato na lista de socios
          vr_lst_generico.append(vr_obj_socio.to_json_value());

        END IF;
      
      
      END LOOP; --Fim crapavt
      
      -- Enviar novo objeto de socios para dentro do objeto principal (Se houve encontro) 
      IF vr_flsocios = true THEN      
        vr_obj_analise.put('socios' ,vr_lst_generico); 
      END IF;
       
    END IF; --> INPESSOA 2   
    
    --> Busca das participa��es societ�rias
    IF rw_crapass.inpessoa = 1 THEN 
      
      -- Inicializar lista de Participa��es Societ�rias
      vr_lst_generico := json_list();
      
      --> Efetuar la�o para retornar todos os registros dispon�veis de participa��es:
      FOR rw_crapepa IN cr_crapepa( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta)  LOOP
        -- Setar flag para indicar que h� participa��es
        vr_flpartic := true;
        -- Se socio for associado
        IF rw_crapepa.nrdconta > 0 THEN 
          -- Passaremos a conta para montagem dos dados:
          pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapepa.nrdconta
                                 ,pr_nrctremp => pr_nrctremp
                                 ,pr_dsjsonan => vr_obj_particip
                                 ,pr_cdcritic => vr_cdcritic 
                                 ,pr_dscritic => vr_dscritic); 
          -- Testar poss�veis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF;  
          -- Adicionar o responsavel montato na lista de socios
          vr_lst_generico.append(vr_obj_particip.to_json_value());

        ELSE
          -- Enviaremos os dados b�sicos encontrados na tabela de Participa��es    
          vr_obj_particip.put('documento'      ,rw_crapepa.nrdocsoc);
          vr_obj_particip.put('tipoPessoa'     ,'JURIDICA');
          vr_obj_particip.put('razaoSocial'    ,rw_crapepa.nmprimtl);
          
          IF rw_crapepa.dtiniatv IS NOT NULL THEN 
            vr_obj_particip.put('dataFundacao' ,ESTE0001.fn_Data_ibra(rw_crapepa.dtiniatv));
          END IF;
          
          -- Montar informa��es Adicionais
          vr_obj_generico := json();

          -- Conta
          vr_obj_generico.put('conta', to_number(substr(rw_crapepa.nrdconta,1,length(rw_crapepa.nrdconta)-1)));
          vr_obj_generico.put('contaDV', to_number(substr(rw_crapepa.nrdconta,-1)));

          -- Natureza Juridica
          IF rw_crapepa.natjurid <> 0 THEN 
            --> Buscar descri��o
            OPEN cr_nature(pr_natjurid => rw_crapepa.natjurid);
            FETCH cr_nature INTO rw_nature;
            CLOSE cr_nature;

            vr_obj_generico.put('naturezaJuridica', rw_crapepa.natjurid||'-'||rw_nature.dsnatjur);
          END IF;
          
          -- Quantidade Filiais
          vr_obj_generico.put('quantFiliais', rw_crapepa.qtfilial);

          -- Quantidade Funcion�rios
          vr_obj_generico.put('quantFuncionarios', rw_crapepa.qtfuncio);
        
          -- Ramo Atividade
          IF rw_crapepa.cdseteco <> 0 AND rw_crapepa.cdrmativ <> 0 THEN 
              
            OPEN cr_gnrativ (pr_cdseteco => rw_crapepa.cdseteco, 
                             pr_cdrmativ => rw_crapepa.cdrmativ );
            FETCH cr_gnrativ INTO rw_gnrativ;
            CLOSE cr_gnrativ;
            
            vr_obj_generico.put('ramoAtividade', rw_crapepa.cdrmativ ||'-'||rw_gnrativ.nmrmativ);
          END IF;
          
          -- Setor Economico
          IF rw_crapepa.cdseteco <> 0 THEN 
          
            -- Buscar descri��o
            vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'GENERI'
                                                     ,pr_cdempres => 0
                                                     ,pr_cdacesso => 'SETORECONO'
                                                     ,pr_tpregist => rw_crapepa.cdseteco);
            -- Se Encontrou
            IF TRIM(vr_dstextab) IS NOT NULL THEN
              vr_nmseteco := vr_dstextab;
            ELSE
              vr_nmseteco := 'Nao Cadastrado';
            END IF;
            vr_obj_generico.put('setorEconomico', rw_crapepa.cdseteco ||'-'|| vr_nmseteco);
          END IF;

          -- Numero Inscri��o Estadual
          IF rw_crapepa.nrinsest <> 0 THEN   
            vr_obj_generico.put('numeroInscricEstadual', rw_crapepa.nrinsest);
          END IF;
         
          -- Enviar informa��es adicionais ao JSON Responsavel Leval
          vr_obj_particip.put('informacoesAdicionais' ,vr_obj_generico);    

          -- Adicionar o responsavel montado na lista de participa��es
          vr_lst_generico.append(vr_obj_particip.to_json_value());          
          
        END IF;  
        
      END LOOP; --> fim crapepa
      
      -- Enviar novo objeto de participa��es para dentro do objeto principal (Se houve encontro) 
      IF vr_flpartic = true THEN      
        vr_obj_analise.put('participacoesSocietarias' ,vr_lst_generico);
      END IF;
      
    END IF; --> INPESSOA 1   
    
    --> Busca dos procuradores:
    -- Inicializar lista de Representantes
    vr_lst_generico := json_list();

    -->Efetuar la�o para retornar todos os registros dispon�veis de Procuradores:
    FOR rw_crapavt IN cr_crapavt(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctremp => 0
                                ,pr_tpctrato => 6
                                ,pr_dsproftl => 'PROCURADOR') LOOP
      -- Setar flag para indicar que h� s�cio
      vr_flprocura := true;
      -- Se socio for associado
      IF rw_crapavt.nrdctato > 0 THEN 
        -- Passaremos a conta para montagem dos dados:
        pc_gera_json_pessoa_ass ( pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapavt.nrdctato
                                 ,pr_nrctremp => pr_nrctremp
                                 ,pr_dsjsonan => vr_obj_procurad
                                 ,pr_cdcritic => vr_cdcritic 
                                 ,pr_dscritic => vr_dscritic); 
        -- Testar poss�veis erros na rotina:
        IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
          RAISE vr_exc_erro;
        END IF;  

        -- Adicionar o responsavel montato na lista de responsaveis
        vr_lst_generico.append(vr_obj_procurad.to_json_value());

      ELSE
        -- Enviaremos os dados b�sicos encontrados na tabela de procuradores
        pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                               ,pr_dsjsonavt  => vr_obj_procurad
                               ,pr_cdcritic   => vr_cdcritic 
                               ,pr_dscritic   => vr_dscritic);
        -- Testar poss�veis erros na rotina:
        IF vr_cdcritic <> 0 OR vr_dscritic IS NOT NULL THEN 
          RAISE vr_exc_erro;
        END IF;        
        -- Adicionar o responsavel montato na lista de responsaveis
        vr_lst_generico.append(vr_obj_procurad.to_json_value());
      END IF;
    END LOOP;

    -- Enviar novo objeto de procuradores para dentro do objeto principal (Se houve encontro) 
    IF vr_flprocura = true THEN
      vr_obj_analise.put('procuradores' ,vr_lst_generico);    
    END IF;
    
    pr_dsjsonan := vr_obj_analise;
    
  EXCEPTION
    WHEN vr_exc_erro  THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN 
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na montagem dos dados para an�lise autom�tica da proposta: '||sqlerrm;
  END pc_gera_json_analise;
    
  
END ESTE0002;
/
