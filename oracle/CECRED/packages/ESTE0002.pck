CREATE OR REPLACE PACKAGE CECRED.ESTE0002 IS
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : ESTE0002
      Sistema  : Rotinas referentes a comunicação com a ESTEIRA de CREDITO da IBRATAN
      Sigla    : CADA
      Autor    : Odirlei Busana - AMcom
      Data     : Maio/2017                   Ultima atualizacao: 28/03/2019

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a comunicação com a ESTEIRA de CREDITO da IBRATAN - Motor de Credito

      Alteracoes: 23/11/2017 - Alterações para o projeto 404. (Lombardi)

                  12/12/2017 - Projeto 410 - inclusão do IOF sobre atraso - (JEan - MOut´S)

				  28/03/2019 - P450 - inclusão da chamada da pc_json_variaveis_rating 
				               responsável pela variaveis internas JSON. (Mário - AMcom)

                  29/07/2019 - Ajuste geração tag 'documento' incluso NVL (Daniel - Ailos)
  
  ---------------------------------------------------------------------------------------------------------------*/
  
  --> Funcao para CPF/CNPJ
  FUNCTION fn_mask_cpf_cnpj(pr_nrcpfcgc IN NUMBER, pr_inpessoa IN NUMBER) return VARCHAR2;
  
  --> Funcao para formatar data hora conforme padrao da IBRATAN
  FUNCTION fn_Data_ibra_motor (pr_data IN DATE) RETURN VARCHAR2;
  
  --> Rotina para retornar descrição do grau escolar
  FUNCTION fn_des_grescola (pr_grescola  IN NUMBER) 
                            RETURN VARCHAR2; 
  
  --> Rotina para retornar descrição de formação
  FUNCTION fn_des_cdfrmttl (pr_cdfrmttl  IN NUMBER) --> codigo da formacao. 
                            RETURN VARCHAR2; 
  
  --> Rotina para retornar descrição do tipos de naturezas de ocupacao
  FUNCTION fn_des_cdnatopc (pr_cdnatocp  IN NUMBER) --> Codigo da natureza de ocupacao.  
                            RETURN VARCHAR2; 
  
  --> Rotina para retornar descrição da ocupacão.
  FUNCTION fn_des_cdocupa (pr_cdocupa  IN NUMBER) --> codigo da ocupacao. 
                            RETURN VARCHAR2;
  
  --> Rotina para retornar descrição do turno
  FUNCTION fn_des_cdturnos (pr_cdturnos  IN NUMBER) --> Codigo do turno
                            RETURN VARCHAR2; 
  
  --> Rotina para retornar descrição do nivel do cargo.
  FUNCTION fn_des_cdnvlcgo (pr_cdnvlcgo  IN NUMBER) --> Codigo do nivel do cargo
                            RETURN VARCHAR2; 
  
  --> Rotina para retornar descrição do tipo de contrato de trabalho
  FUNCTION fn_des_tpcttrab (pr_tpcttrab  IN NUMBER) --> Codigo tipo de contrato de trabalho
                            RETURN VARCHAR2;   
  
  --> Rotina para retornar descrição do estado civil
  FUNCTION fn_des_cdestciv (pr_cdestciv  IN NUMBER) --> Codigo do estado civil
                            RETURN VARCHAR2;
  
  --> Rotina para retornar descrição de indicador de menor
  FUNCTION fn_des_inhabmen (pr_inhabmen  IN NUMBER) --> indicador de menor
                            RETURN VARCHAR2;
  
  --> Rotina para retornar descrição do tipo de conta
  FUNCTION fn_des_cdtipcta (pr_inpessoa IN tbcc_tipo_conta.inpessoa%TYPE,  --> Tipo de pessoa
                            pr_cdtipcta IN tbcc_tipo_conta.cdtipo_conta%TYPE)  --> Tipo de conta
                            RETURN VARCHAR2;
  
  --> Rotina para retornar descrição de indicador
  FUNCTION fn_des_incasprp (pr_incasprp  IN NUMBER) --> Codigo indicador
                            RETURN VARCHAR2;
  
  --> Rotina para retornar descrição da situação do CPF
  FUNCTION fn_des_cdsitcpf (pr_cdsitcpf  IN NUMBER) --> Codigo da situação do CPF
                            RETURN VARCHAR2;
  
  --> Rotina para retornar descrição de cadastro positivo
  FUNCTION fn_des_incadpos (pr_incadpos  IN NUMBER) --> Codigo cadastro positivo
                            RETURN VARCHAR2;
  
  --> Rotina para remover caracteres do telefone
  FUNCTION fn_somente_numeros_telefone(pr_nrtelefo VARCHAR2) RETURN VARCHAR2;
  
  --> Rotina para retornar descrição de atraso
  FUNCTION fn_des_pontualidade (pr_qtdiaatr  IN NUMBER) --> qtd dias de atraso
                                RETURN VARCHAR2;
  
    /* Rotina de calculo de dias do ultimo pagamento de emprestimos em atraso*/
  PROCEDURE pc_calc_dias_atraso(pr_cdcooper   IN crapepr.cdcooper%TYPE --> Código da cooperativa
                               ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Numero da conta do emprestimo
                               ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato de emprestimo
                               ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE --> Data Movimento
                               ,pr_dtmvtoan   IN crapdat.dtmvtoan%TYPE --> Data Movimento Anterior
                               ,pr_dtmvtopr   IN crapdat.dtmvtopr%TYPE --> Data Movimento Próximo
                               ,pr_tpemprst   IN crapepr.tpemprst%TYPE --> Tipo do Empréstimo
                               ,pr_qtmesdec   IN crapepr.qtmesdec%TYPE --> Meses decorridos
                               ,pr_dtdpagto   IN crapepr.dtdpagto%TYPE --> Data de pagamento
                               ,pr_qtprecal   IN crapepr.qtprecal%TYPE --> Quantidade parcelas calculadas
                               ,pr_flgpagto   IN crapepr.flgpagto%TYPE --> TIpo de pagamento
                               ,pr_qtdiaatr   OUT NUMBER --> Quantidade de dias em atraso
                               ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> Código de critica encontrada
                               ,pr_des_erro   OUT VARCHAR2);
  
  --> Procedure para montar o JSON   
  PROCEDURE pc_gera_json_pessoa_ass(pr_cdcooper IN crapass.cdcooper%TYPE --> Código da cooperativa
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE --> Numero da conta do emprestimo
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE --> Numero do contrato de emprestimo
                                   ,pr_flprepon IN BOOLEAN DEFAULT FALSE --> Flag Repon
                                   ,pr_vlsalari IN NUMBER  DEFAULT 0  --> Valor do Salario Associado
                                   ,pr_persocio IN NUMBER  DEFAULT 0 --> Percential do sócio
                                   ,pr_dtadmsoc IN DATE    DEFAULT NULL --> Data Admissãio do Sócio
                                   ,pr_dtvigpro IN DATE    DEFAULT NULL --> Data Vigência do Produto
                                   ,pr_tpprodut IN NUMBER  DEFAULT 0 --> Tipo de Produto
                                   ,pr_inPropon IN BOOLEAN DEFAULT FALSE --> Flag Proponente
                                   ,pr_dsjsonan OUT json --> Retorno Variáveis Json
                                   ,pr_cdcritic OUT NUMBER --> Código de critica encontrada
                                   ,pr_dscritic OUT VARCHAR2);
                               
       
  PROCEDURE pc_gera_json_pessoa_avt ( pr_rw_crapavt  IN crapavt%ROWTYPE,        --> Dados do avalista
                                      ---- OUT ----
                                      pr_dsjsonavt OUT NOCOPY json,             --> Retorno do clob em modelo json dos dados do avalista
                                      pr_cdcritic  OUT NUMBER,                  --> Codigo da critica
                                      pr_dscritic  OUT VARCHAR2);
  
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
									
  
  --> Rotina para calcular valor total financiado
  PROCEDURE pc_ret_valor_financiado (pr_cdcooper   IN crapass.cdcooper%TYPE   --> Codigo da cooperativa
                                    ,pr_nrdconta   IN crapass.nrdconta%TYPE   --> Codigo da cooperativa
                                    ,pr_nrctremp   IN crapepr.nrctremp%TYPE   --> Codigo da cooperativa
                                    ---- OUT ----
                                    ,pr_vlfinanc  OUT NUMBER                  --> Retornar valor financiado 
                                    ,pr_cdcritic  OUT NUMBER                  --> Codigo da critica
                                    ,pr_dscritic  OUT VARCHAR2);              --> Descricao da critica                                  					
END ESTE0002;
/
CREATE OR REPLACE PACKAGE BODY CECRED.ESTE0002 IS
  /* ---------------------------------------------------------------------------------------------------------------

      Programa : ESTE0002
      Sistema  : Rotinas referentes a comunicação com a ESTEIRA de CREDITO da IBRATAN
      Sigla    : CADA
      Autor    : Odirlei Busana - AMcom
      Data     : Maio/2017.                   Ultima atualizacao: 28/06/2019

      Dados referentes ao programa:

      Frequencia: -----
      Objetivo  : Rotinas referentes a comunicação com a ESTEIRA de CREDITO da IBRATAN - Motor de credito

      Alteracoes: 12/09/2017 - Ajuste nacionalidade e orgao emissor. PRJ339 - CRM (Odirlei-AMcom)

                  25/10/2017 - Removida verificacao de tipo de telefone do conjuge, registros com DDD
                               na frente ocasionam problemas devido ao parenteses.
                               Heitor (Mouts) - Chamado 778505

                  12/12/2017 - Projeto 410 - Incluir o tratamento para o IOF por atraso - (Jean / MOut´S)
                  
                  20/03/2018 - #INC0010628 Não considerar contratos que foram para prejuízo (Carlos)

                  05/04/2018 - Novos campos criados para mandar ao motor de crédito 
                               Referente a avais cruzados. Diego Simas (AMcom)
                  
                  27/04/2018 - Removida funcao fn_des_cdsitdct. PRJ366 (Lombardi)

                  24/05/2018 - Projeto Regulatório de Crédito - Inclusão de cpf/cnpj no objeto contasAvalizadas
                               Campo documentoAval - Diego Simas - AMcom

                  01/08/2018 - Adicionado o parâmetro pr_tpprodut na procedure pc_gera_json_pessoa_ass para
                               distinguir qual configuração da PAREST irá buscar (Paulo Penteado GFT)

                  03/09/2018 - P450 - Ajuste na tag causouPrejuizoCoop e criação da tag estaEmPrejuizoCoop
                               (Diego Simas/AMcom)

				  10/11/2018 - Ajuste na procedure "pc_gera_json_pessoa_ass" - correção no cursor que identifica
							   se o contrato de empréstimo está/esteve em prejuízo
							   (Reginaldo/AMcom)

                  16/04/2019 - Correção busca limite cheque especial, não estava filtrando o tipo de produto (Daniel - Ailos)

                  23/01/2019 - P450 - Novas variaveis internas para o Json - Ailos X Ibratan
                               relacionado ao empréstimo e desconto de título - (Fabio Adriano - AMcom)

                  28/06/2019 - P450 - Reposicionado VariaveisInterna abaixo de VariaveisAdicionais no Proponente (Mario - AMcom)   

  ---------------------------------------------------------------------------------------------------------------*/
  
  --> Funcao para CPF/CNPJ
  FUNCTION fn_mask_cpf_cnpj(pr_nrcpfcgc IN NUMBER, pr_inpessoa IN NUMBER) return VARCHAR2 IS
  BEGIN
    IF pr_inpessoa = 1 THEN
      RETURN gene0002.fn_mask(pr_nrcpfcgc,'99999999999');
    ELSE
      RETURN gene0002.fn_mask(pr_nrcpfcgc,'99999999999999');                                                 
    END IF;
  END;
  
  --> Funcao para formatar data hora conforme padrao da IBRATAN
  FUNCTION fn_Data_ibra_motor (pr_data IN DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(pr_data,'RRRRMMDD');
  END fn_Data_ibra_motor;
  
   
  --> Funcao para formatar data hora conforme padrao da IBRATAN
  FUNCTION fn_DataTempo_ibra (pr_data IN DATE) RETURN VARCHAR2 IS
  BEGIN
    RETURN to_char(pr_data,'RRRR-MM-DD"T"HH24:MI:SS".000Z"');
  END fn_DataTempo_ibra;

  --> Rotina para retornar descrição do grau escolar
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
      Objetivo  : Rotina para retornar descrição do grau escolar
    
      Alteração : 
        
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
  
  --> Rotina para retornar descrição de formação
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
      Objetivo  : Rotina para retornar descrição de formação
    
      Alteração : 
        
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
  
  --> Rotina para retornar descrição do tipos de naturezas de ocupacao
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
      Objetivo  : Rotina para retornar descrição do tipos de naturezas de ocupacao
    
      Alteração : 
        
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
  
  --> Rotina para retornar descrição da ocupacão.
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
      Objetivo  : Rotina para retornar descrição da ocupacão.
    
      Alteração : 
        
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
  
  --> Rotina para retornar descrição do turno
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
      Objetivo  : Rotina para retornar descrição do turno.
    
      Alteração : 
        
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
  
  
  --> Rotina para retornar descrição do nivel do cargo.
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
      Objetivo  : Rotina para retornar descrição do nivel do cargo.
    
      Alteração : 
        
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
  
  --> Rotina para retornar descrição do tipo de contrato de trabalho
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
      Objetivo  : Rotina para retornar descrição do tipo de contrato de trabalho
    
      Alteração : 
        
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
  
  
  --> Rotina para retornar descrição do estado civil
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
      Objetivo  : Rotina para retornar descrição do estado civil
    
      Alteração : 
        
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
  
  
  --> Rotina para retornar descrição de indicador de menor
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
      Objetivo  : Rotina para retornar descrição de indicador de menor
    
      Alteração : 
        
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
  
  
  
  --> Rotina para retornar descrição do tipo de conta
  FUNCTION fn_des_cdtipcta (pr_inpessoa IN tbcc_tipo_conta.inpessoa%TYPE,  --> Tipo de pessoa
                            pr_cdtipcta IN tbcc_tipo_conta.cdtipo_conta%TYPE)  --> Tipo de conta
                            RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_cdtipcta        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descrição do tipo de conta
    
      Alteração : 20/02/2018 - Busca a descrição do tipo de conta da tabela
                               TBCC_TIPO_CONTA. PRJ366 (Lombardi).
        
    ..........................................................................*/
    -----------> CURSORES <-----------    
    CURSOR cr_tipo_conta IS
      SELECT tpcta.dstipo_conta
        FROM tbcc_tipo_conta tpcta
       WHERE tpcta.inpessoa = pr_inpessoa
         AND tpcta.cdtipo_conta = pr_cdtipcta;
    rw_tipo_conta cr_tipo_conta%ROWTYPE;
    
    -----------> VARIAVEIS <-----------   
    vr_dstipcta VARCHAR2(100) := NULL;
    
  BEGIN
    
    -- Buscar descrição do tipo de conta
    OPEN cr_tipo_conta;
    FETCH cr_tipo_conta INTO rw_tipo_conta;
      
    IF cr_tipo_conta%FOUND THEN
      CLOSE cr_tipo_conta;
      vr_dstipcta := rw_tipo_conta.dstipo_conta;
      RETURN vr_dstipcta;
    ELSE
      CLOSE cr_tipo_conta;
      RETURN NULL;
    END IF;
        
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
  END fn_des_cdtipcta;
  
  --> Rotina para retornar descrição de indicador
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
      Objetivo  : Rotina para retornar descrição de indicador
    
      Alteração : 
        
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
  
  --> Rotina para retornar descrição da situação do CPF
  FUNCTION fn_des_cdsitcpf (pr_cdsitcpf  IN NUMBER) --> Codigo da situação do CPF
                            RETURN VARCHAR2 IS 
  /* ..........................................................................
    
      Programa : fn_des_cdsitcpf        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(Amcom)
      Data     : Maio/2017.                   Ultima atualizacao: 04/05/2017
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para retornar descrição da situação do CPF
    
      Alteração : 
        
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
  
  --> Rotina para retornar descrição de cadastro positivo
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
      Objetivo  : Rotina para retornar descrição de cadastro positivo
    
      Alteração : 
        
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
  
  --> Rotina para remover caracteres do telefone
  FUNCTION fn_somente_numeros_telefone(pr_nrtelefo VARCHAR2) RETURN VARCHAR2 IS
  
  BEGIN
    RETURN replace(replace(replace(replace(replace(pr_nrtelefo,' ',''),'-',''),'.',''),')',''),'(','');
  END;
  
  --> Rotina para retornar descrição de atraso
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
      Objetivo  : Rotina para retornar descrição de atraso
    
      Alteração : 
        
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
  
    /* Rotina de calculo de dias do ultimo pagamento de emprestimos em atraso*/
  PROCEDURE pc_calc_dias_atraso(pr_cdcooper   IN crapepr.cdcooper%TYPE --> Código da cooperativa
                               ,pr_nrdconta   IN crapepr.nrdconta%TYPE --> Numero da conta do emprestimo
                               ,pr_nrctremp   IN crapepr.nrctremp%TYPE --> Numero do contrato de emprestimo
                               ,pr_dtmvtolt   IN crapdat.dtmvtolt%TYPE --> Data Movimento
                               ,pr_dtmvtoan   IN crapdat.dtmvtoan%TYPE --> Data Movimento Anterior
                               ,pr_dtmvtopr   IN crapdat.dtmvtopr%TYPE --> Data Movimento Próximo
                               ,pr_tpemprst   IN crapepr.tpemprst%TYPE --> Tipo do Empréstimo
                               ,pr_qtmesdec   IN crapepr.qtmesdec%TYPE --> Meses decorridos
                               ,pr_dtdpagto   IN crapepr.dtdpagto%TYPE --> Data de pagamento
                               ,pr_qtprecal   IN crapepr.qtprecal%TYPE --> Quantidade parcelas calculadas
                               ,pr_flgpagto   IN crapepr.flgpagto%TYPE --> TIpo de pagamento
                               ,pr_qtdiaatr   OUT NUMBER --> Quantidade de dias em atraso
                               ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> Código de critica encontrada
                               ,pr_des_erro   OUT VARCHAR2) IS --> Retorno de erro
  BEGIN
    DECLARE
    
      --Selecionar informacoes dos emprestimos
      CURSOR cr_crapepr(pr_cdcooper IN crapepr.cdcooper%TYPE
                       ,pr_nrdconta IN crapepr.nrdconta%TYPE
                       ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT crapepr.qtlcalat
              ,crapepr.qtpcalat
          FROM crapepr crapepr
         WHERE crapepr.cdcooper = pr_cdcooper
               AND crapepr.nrdconta = pr_nrdconta
               AND crapepr.nrctremp = pr_nrctremp;
      rw_crapepr cr_crapepr%ROWTYPE;
    
      --Variaveis Locais
      vr_qtdias   INTEGER := 0;
      vr_qtmesdec crapepr.qtmesdec%TYPE;
      vr_qtprecal crapepr.qtprecal%TYPE;
    
      --Variaveis de Excecao
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;
    
      --Variavel para tratar mensagem erro
      vr_des_erro VARCHAR2(4000);
    
    BEGIN
      --Inicializar variavel de erro
      pr_des_erro := NULL;
      --Zerar variaveis de retorno
      pr_qtdiaatr := 0;
    
      --Se o tipo de emprestimo for anual
      IF pr_tpemprst = 0 THEN
        
        --Quantidade de meses recebe o valor passado como parametro
        vr_qtmesdec := pr_qtmesdec;
        
        --Se a data de pagamento nao for nula
        IF pr_dtdpagto IS NOT NULL THEN
          /* Verif. final mes(dia nao util) */
          -- Se o dia do pagamento > dia movimento para o mesmo mês e ano
          IF to_number(to_char(pr_dtdpagto, 'DD')) >
             to_number(to_char(pr_dtmvtolt, 'DD'))
             AND to_char(pr_dtdpagto, 'YYYYMM') =
             to_char(pr_dtmvtolt, 'YYYYMM') THEN
            --Reduzir a Quantidade meses em 1
            vr_qtmesdec := Nvl(vr_qtmesdec, 0) - 1;
          END IF;
        END IF;
        --Quantidade dias recebe quantidade meses menos quantidade parcelas * 30
        vr_qtdias := (vr_qtmesdec - pr_qtprecal) * 30;
      
        --Se estiver em dia
        IF vr_qtdias < 0 THEN
          --Levantar Exceção
          RAISE vr_exc_saida;
        END IF;
      
        --Se quantidade dias for negativa e a data de pagamento nao for nula e nao tiver pago e data pagamento maior data movimento
        IF vr_qtdias <= 0
           AND pr_dtdpagto IS NOT NULL
           AND pr_flgpagto = 0
           AND /* Conta Corrente */
           pr_dtdpagto >= pr_dtmvtolt THEN
          --Levantar excecao
          RAISE vr_exc_saida;
        END IF;
      ELSE
        --Buscar a quantidade de dias em atraso
        vr_qtdias := EMPR0001.fn_busca_dias_atraso_epr(pr_cdcooper => pr_cdcooper
                                                      ,pr_nrdconta => pr_nrdconta
                                                      ,pr_nrctremp => pr_nrctremp
                                                      ,pr_dtmvtolt => pr_dtmvtolt
                                                      ,pr_dtmvtoan => pr_dtmvtoan);
        --Se a quantidade de dias for inferior ou igual a zero
        IF vr_qtdias <= 0 THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
      END IF;
    
      --Zerar Variaveis para chamada calculo
      vr_qtprecal := 0;
    
      --Se o mes da data de movimento for igual do mes da proxima data de movimento
      IF to_char(pr_dtmvtolt, 'MM') = to_char(pr_dtmvtopr, 'MM') THEN
        --Se o tipo de emprestimo for anual
        IF pr_tpemprst = 0 THEN
          --Quantidade de parcelas calculada recebe qdade. lancamentos atualizados
          vr_qtprecal := nvl(rw_crapepr.qtlcalat, 0);
        ELSE
          --Quantidade de parcelas calculada recebe qdade. prestacoes calculadas
          vr_qtprecal := nvl(rw_crapepr.qtpcalat, 0);
        END IF;
      END IF;
    
      -- Se o tipo de emprestimo for TR
      IF pr_tpemprst = 0 THEN
        --Incrementar no parametro de retorno a quantidade de parcelas calculada
        vr_qtprecal := pr_qtprecal + Nvl(vr_qtprecal, 0);
        --Quantidade de dias recebe a quantidade de meses menos parcelas calculadas * 30
        vr_qtdias := (vr_qtmesdec - Nvl(vr_qtprecal, 0)) * 30;
      
        --Se a quantidade de dias for menor zero
        IF vr_qtdias < 0 THEN
          --Levantar Excecao
          RAISE vr_exc_saida;
        END IF;
        --Se quantidade dias for negativa e a data de pagamento nao for nula e nao tiver pago e data pagamento maior data movimento
        IF vr_qtdias <= 0
           AND pr_dtdpagto IS NOT NULL
           AND pr_flgpagto = 0
           AND /* Conta Corrente */
           pr_dtdpagto >= pr_dtmvtolt THEN
          --Levantar excecao
          RAISE vr_exc_saida;
        END IF;
        --Se quantidade dias for negativa e nao tiver pago
        IF vr_qtdias <= 0 AND pr_flgpagto = 0 THEN
          /* Conta Corrente */
          --Quantidade de dias recebe dias entre a data movimento e data de pagamento do emprestimo
          vr_qtdias := pr_dtmvtolt - pr_dtdpagto;
        END IF;
      END IF;
    
      --Retornar dias em atraso
      pr_qtdiaatr := vr_qtdias;
    
    EXCEPTION
      WHEN vr_exc_erro THEN
        pr_cdcritic := nvl(pr_cdcritic, 0);
        pr_des_erro := vr_des_erro;
      WHEN vr_exc_saida THEN
        --Retornar dias em atraso
        pr_qtdiaatr := vr_qtdias;
      WHEN OTHERS THEN
        pr_cdcritic := nvl(pr_cdcritic, 0);
        pr_des_erro := 'Erro na rotina EMPR0001.pc_calc_dias_atraso. ' ||
                       sqlerrm;
    END;
  END;
  
  --> Rotina para retornar total de prestações que o avalista tem
  --> e também retornar a quantidade de contratos ativo do avalista
  --> Diego Simas (AMcom)
  PROCEDURE pc_resumo_aval(pr_cdcooper    IN crapepr.cdcooper%TYPE --> Código da cooperativa
                          ,pr_nrdconta    IN crapepr.nrdconta%TYPE --> Numero da conta do emprestimo
                          ,pr_vltprava   OUT crapepr.vlpreemp%TYPE --> Valor total das prestações em que o cooperado é avalista
                          ,pr_qtconava   OUT NUMBER                --> Quantidade de contratos em que o cooperado é avalista
                          ,pr_cdcritic   OUT crapcri.cdcritic%TYPE --> Código de critica encontrada
                          ,pr_dscritic   OUT VARCHAR2              --Descrição da crítica
                          ,pr_nmdcampo   OUT VARCHAR2              --Nome do Campo
                          ,pr_des_erro   OUT VARCHAR2) IS          --> Retorno de erro
  /* ..........................................................................

        Programa : pc_resumo_aval
        Sistema  : Conta-Corrente - Cooperativa de Credito
        Sigla    : CRED
        Autor    : Diego Simas (AMcom)
        Data     : Abril/2018.                    Ultima atualizacao: 

        Dados referentes a procedure:

        Frequencia: Sempre que for chamado
        Objetivo  : Rotina responsavel por buscar dados do avalista

        Alteração : 
        
    ..........................................................................*/                           
    
      -- Selecionar informações do avalista
      -- Cursor para pegar quantidade de contratos e o valor total
      -- das prestações do avalista
      CURSOR cr_crapavl (pr_cdcooper crapass.cdcooper%TYPE,
                         pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT SUM(emp.vlpreemp) total_prestacoes, 
       COUNT(DISTINCT emp.nrctremp) qtd_contratos
        FROM crapepr emp
       WHERE emp.cdcooper = pr_cdcooper
         AND emp.nrdconta = pr_nrdconta
         AND emp.inliquid = 0;
      rw_crapavl cr_crapavl%ROWTYPE;

      -- Variáveis de Exceção
      vr_exc_erro  EXCEPTION;
      vr_exc_saida EXCEPTION;

      -- Variável para tratar mensagem erro
      vr_des_erro VARCHAR2(4000);
      vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(4000);

  BEGIN
      
    OPEN cr_crapavl(pr_cdcooper => pr_cdcooper,
                    pr_nrdconta => pr_nrdconta);

    FETCH cr_crapavl INTO rw_crapavl;

    IF cr_crapavl%NOTFOUND THEN
        -- Fecha cursor
        CLOSE cr_crapavl;       
        pr_vltprava := 0;
        pr_qtconava := 0;
     ELSE
        -- Fecha cursor
        CLOSE cr_crapavl;
        pr_vltprava := rw_crapavl.total_prestacoes;
        pr_qtconava := rw_crapavl.qtd_contratos;
     END IF;
     
     pr_des_erro := 'OK';

  EXCEPTION
    WHEN vr_exc_erro THEN
      pr_des_erro := 'NOK';
      -- Erro
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;
    WHEN OTHERS THEN
      pr_des_erro := 'NOK';
      -- Erro
      pr_cdcritic:= 0;
      pr_dscritic:= 'Erro na pc_resumo_aval --> '|| SQLERRM;  
    
  END pc_resumo_aval;

  --> Procedure para montar o JSON     
  PROCEDURE pc_gera_json_pessoa_ass(pr_cdcooper IN crapass.cdcooper%TYPE
                                   ,pr_nrdconta IN crapass.nrdconta%TYPE
                                   ,pr_nrctremp IN crapepr.nrctremp%TYPE
                                   ,pr_flprepon IN BOOLEAN DEFAULT FALSE
                                   ,pr_vlsalari IN NUMBER  DEFAULT 0
                                   ,pr_persocio IN NUMBER  DEFAULT 0
                                   ,pr_dtadmsoc IN DATE    DEFAULT NULL
                                   ,pr_dtvigpro IN DATE    DEFAULT NULL
                                   ,pr_tpprodut IN NUMBER  DEFAULT 0
                                   ,pr_inPropon IN BOOLEAN DEFAULT FALSE
                                   ,pr_dsjsonan OUT json
                                   ,pr_cdcritic OUT NUMBER
                                   ,pr_dscritic OUT VARCHAR2) IS
  BEGIN
    /* ..........................................................................
      
        Programa : pc_gera_json_pessoa_ass
        Sistema  : Conta-Corrente - Cooperativa de Credito
        Sigla    : CRED
        Autor    : Lucas Reinert
        Data     : Maio/2017.                    Ultima atualizacao: 13/03/2019
      
        Dados referentes ao programa:
      
        Frequencia: Sempre que for chamado
        Objetivo  : Rotina responsavel por buscar todas as informações cadastrais
                    e das operações da conta parametrizada.
      
                    pr_tpprodut --> Tipo de produto (0 - Empréstimos e Financiamentos
                                                     1 - Desconto de Títulos
                                                     4 - Cartão de Crédito) 
      
        Alteração : 19/10/2017 - Renomear "quantDiasAtrasoEmprest" para "quantDiasMaiorAtrasoEmprest"
                                 Criar campo "quantDiasAtrasoEmprest" com a maior quantidade de dias em atraso (Lombardi)
          
                    21/12/2017 - Ajustar tratamento de erro, para que a mensagem seja exibida em tela
                               - Ajustar passagem de parametro cdcritic e dscritic 
                               (Douglas - Chamado 819146)

                    24/05/2018 - Projeto Regulatório de Crédito - Inclusão de cpf/cnpj no objeto contasAvalizadas
                                 Campo documentoAval - Diego Simas - AMcom

                  01/08/2018 - Adicionado o parâmetro pr_tpprodut para distinguir qual configuração da PAREST 
                               irá buscar (Paulo Penteado GFT)

                   03/09/2018 - P450 - Ajuste na tag causouPrejuizoCoop e criação da tag estaEmPrejuizoCoop
                                (Diego Simas/AMcom)

                   11/10/2018 - P450 - Correção no cursor que identifica se o contrato de empréstimo está/esteve em prejuízo
                                (Reginaldo/AMcom)

                   01/11/2018 - P442 - Envio dos Scores Behaviour do Cooperado (MArcos Envolti)  
				   
				   19/12/2018 - P442 - Envio de quantidade dias em Estouro (Marcos Envolti)

                    06/02/2019 - P442 - Envio do Potencial Limite e Valor Utilizado (Marcos-Envolti)             

                    11/02/2019 - P442 - Mudança no teste de bloqueio ou não do PreAprovado (Marcos-Envolti)

                    05/03/2019 - P637 - Motor de Crédito - Adequação dos campos conforme ESTE0005
                                (Luciano Kienolt - Supero)

                    19/03/2019 - Adicionado as tags Histórico de SCR – Atraso – Últimas 3 bases,
                                 Histórico prejuízo SCR – Ultimas 3 bases,
                                 Operações de Cessão de Crédito Ativa.
                                 P637 - Cartão - Luciano Kienolt - Supero
                               
                    03/04/2019 - Adicionado cursor/tag de Valor Patrimonio Referencial
                                 P637 - Cartão - Luciano Kienolt - Supero

                    13/03/2019 - P450 - Novas variaveis internas para o Json - Ailos X Ibratan
                                 utilizando CNPJ Raiz, Informação do BI e 
                                 Geração de todas variáveis - (Mário Bernat - AMcom)

    ..........................................................................*/
    DECLARE
      -- Variáveis para exceções
      vr_cdcritic PLS_INTEGER;
      vr_dscritic VARCHAR2(4000);
      vr_nmdcampo VARCHAR2(100);
      vr_exc_saida EXCEPTION;
	  vr_des_reto VARCHAR2(3);
	  vr_tab_erro GENE0001.typ_tab_erro;
      vr_des_erro VARCHAR2(10);
      vr_exc_erro EXCEPTION;
    
      -- Declarar objetos Json necessários:
      vr_obj_generico  json := json();
      vr_obj_generic2  json := json();
      vr_obj_generic3  json := json();	
      vr_lst_generic2  json_list := json_list();
      vr_lst_generic3  json_list := json_list();
			
			-- Variáveis auxiliares
			vr_tpcmpvrn VARCHAR2(100);
			vr_dstextab craptab.dstextab%TYPE;
			vr_nmseteco craptab.dstextab%TYPE;
			vr_qtdopliq VARCHAR2(10);
			vr_flliquid BOOLEAN;
			vr_flprjcop BOOLEAN;
			vr_fl800900 BOOLEAN;
			vr_vladtdep crapsda.vllimcre%TYPE;
			vr_qtdiaest INTEGER;
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
      vr_vlendivi NUMBER := 0;
			vr_ind_coresp VARCHAR2(100);
			vr_qtprecal NUMBER(10) := 0;
			vr_tot_vlsdeved NUMBER(25, 10) := 0;
      vr_ava_vlsdeved NUMBER(25, 10) := 0;
			vr_tot_qtprecal NUMBER := 0;
			vr_nratrmai NUMBER(25,10);
      vr_vltotatr NUMBER(25,10);
      vr_qtpclven NUMBER;
      vr_qtpclatr NUMBER;
      vr_qtpclpag NUMBER;
			vr_tot_qtpclatr NUMBER;
      vr_tot_qtpclpag NUMBER;
			vr_idxempr  VARCHAR2(100);
			vr_vlsdeved NUMBER;
			vr_dias     NUMBER;
      vr_inusatab BOOLEAN;
			vr_dstextab_parempctl craptab.dstextab%TYPE;
			vr_dstextab_digitaliza craptab.dstextab%TYPE;
			vr_qtregist INTEGER;
			vr_vltotpre NUMBER(25,2) := 0;
      /*vr_vlsalari crapcje.vlsalari%TYPE;
      vr_vlpercom NUMBER(25,2);
      vr_vlalugue NUMBER;
      vr_vlrendim NUMBER;*/
      vr_nrconbir crapcbc.nrconbir%TYPE;
      vr_nrseqdet crapcbd.nrseqdet%TYPE;
      vr_cdbircon crapbir.cdbircon%TYPE;
      vr_dsbircon crapbir.dsbircon%TYPE;
      vr_cdmodbir crapmbr.cdmodbir%TYPE;
      vr_dsmodbir crapmbr.dsmodbir%TYPE;
      vr_flsituac VARCHAR2(100) := 'N';      
			vr_vlmedfat NUMBER;
			vr_qtmesest crapprm.dsvlrprm%TYPE;
			vr_qtmeschq crapprm.dsvlrprm%TYPE;	
	    vr_qtmeschqal11 crapprm.dsvlrprm%TYPE;
      vr_qtmeschqal12 crapprm.dsvlrprm%TYPE;
			vr_qthisemp crapprm.dsvlrprm%TYPE;	
			vr_qqdiacheq NUMBER;    
      vr_tab_estouros risc0001.typ_tab_estouros;
      vr_dtiniest DATE;
      vr_qtdiaat2 INTEGER := 0;
      vr_idcarga  tbepr_carga_pre_aprv.idcarga%TYPE;
      vr_vllimdis crapcpa.vllimdis%TYPE := 0;
      vr_vlctrpre crapcpa.vlctrpre%TYPE := 0;
      vr_vlpotlim crapcpa.vlpot_lim_max%TYPE := 0;
      vr_vlpotpar crapcpa.vlpot_parc_maximo%TYPE := 0;
      vr_skcarga  tbepr_carga_pre_aprv.skcarga_sas%TYPE := 0;
      vr_nrfimpre          craplcr.nrfimpre%TYPE;
      vr_vlpot_parc_max    crapcpa.vlpot_parc_maximo%TYPE;
      vr_vlpot_lim_max     crapcpa.vlpot_lim_max%TYPE;
      vr_vl_scr_61_90      crapvop.vlvencto%TYPE;         
      vr_vl_scr_61_90_cje  crapvop.vlvencto%TYPE;         
      vr_vlope_pos_scr     crapepr.vlsdeved%TYPE;         
      vr_vlope_pos_scr_cje crapepr.vlsdeved%TYPE;         
      vr_vlprop_andamt     crapepr.vlsdeved%TYPE;              
      vr_vlprop_andamt_cje crapepr.vlsdeved%TYPE;
      vr_vlparcel          NUMBER(25,2) := 0;
      vr_vldispon          NUMBER(25,2) := 0;
      vr_cdfinpre crapfin.cdfinemp%TYPE;
      vr_vlsldpre NUMBER(25,2) := 0;

      vr_maior_nratrmai NUMBER(25,10);
      vr_vltprava crapepr.vlpreemp%TYPE;
      vr_qtconava INTEGER := 0;
      vr_vlblqapl NUMBER(18,2);
      vr_vlblqpou NUMBER(18,2);
      vr_vlbloque NUMBER(18,2);
      vr_vlresblq NUMBER(18,2);
      vr_vlsldppr_aux NUMBER(18,2);
      vr_vlsldapl_aux NUMBER(18,2);
      vr_vlbloque_pp crapblj.vlbloque%TYPE;
      vr_documento VARCHAR(100);
      --vr_vet_nrctrliq            RATI0001.typ_vet_nrctrliq := RATI0001.typ_vet_nrctrliq(0,0,0,0,0,0,0,0,0,0);
      vr_inprejuz BOOLEAN;
      vr_flesprej BOOLEAN;
      vr_flemprej BOOLEAN;
      vr_cont_SCR       NUMBER;      
      vr_atrasoscr      BOOLEAN; 
      vr_dtdpagto_atr   DATE;
      vr_prejscr        BOOLEAN;
      			
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
			vr_tab_dados_epr           EMPR0001.typ_tab_dados_epr;
			
      --Tipo de registro do tipo data
      rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
    
      -- Cursor para endereço
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
           AND enc.tpendass = pr_tpendass
           AND enc.idseqttl = 1;
      rw_crapenc cr_crapenc%ROWTYPE;
    
      -- Cursor para telefones:
      CURSOR cr_craptfc IS
        SELECT tfc.tptelefo
              ,tfc.nrdddtfc
              ,tfc.nrtelefo
          FROM craptfc tfc
         WHERE tfc.cdcooper = pr_cdcooper
           AND tfc.nrdconta = pr_nrdconta
           AND tfc.idseqttl = 1
           AND tfc.tptelefo IN (1, 2, 3); /* Residencial, Celular e Comercial */
      
      -- Busca Email
      CURSOR cr_crapcem IS
        SELECT cem.dsdemail
          FROM crapcem cem
         WHERE cem.cdcooper = pr_cdcooper
           AND cem.nrdconta = pr_nrdconta
           AND cem.idseqttl = 1;
      vr_dsdemail crapcem.dsdemail%TYPE;
      
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
							,ass.dtmvtolt
              ,ass.dtadmiss
              ,ass.nrcpfcnpj_base
          FROM crapass ass
         WHERE ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta;
      rw_crapass cr_crapass%ROWTYPE;
    
      -- Buscaremos informações da proposta de empréstimo em aprovação
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
              ,decode(empr0001.fn_tipo_finalidade(epr.cdcooper, epr.cdfinemp),3,1,0) inintcdc
          FROM crawepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.nrctremp = pr_nrctremp;
      rw_crawepr cr_crawepr%ROWTYPE;
			
      -- Buscar informações do primeiro titular 
      CURSOR cr_crapttl IS
        SELECT ttl.nmextttl
              ,ttl.dtcnscpf
              ,ttl.cdsitcpf
              ,ttl.tpdocttl
              ,ttl.nrdocttl
              ,org.cdorgao_expedidor cdoedttl
              ,ttl.dtnasttl
              ,ttl.cdsexotl
              ,ttl.tpnacion
              ,nac.dsnacion dsnacion
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
              ,ttl.vlsalari vlrendim
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
              ,crapnac nac
              ,tbgen_orgao_expedidor org
         WHERE ttl.cdcooper = pr_cdcooper
           AND ttl.nrdconta = pr_nrdconta
           AND ttl.idseqttl = 1
           AND ass.cdcooper = ttl.cdcooper
           AND ass.nrdconta = ttl.nrdconta
           AND ttl.cdnacion = nac.cdnacion(+)
           AND ttl.idorgexp = org.idorgao_expedidor(+);
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
              ,jur.dtiniatv
          FROM crapjur jur
         WHERE jur.cdcooper = pr_cdcooper
           AND jur.nrdconta = pr_nrdconta;
      rw_crapjur cr_crapjur%ROWTYPE;
    
      -- Verifica se esta na tabela do pre-aprovado
      CURSOR cr_crapcpa (pr_cdcooper IN crapcpa.cdcooper%TYPE,
                         pr_tppessoa IN crapcpa.tppessoa%TYPE,
                         pr_nrcpfcnpj_base IN crapcpa.nrcpfcnpj_base%TYPE,
                         pr_idcarga  IN crapcpa.iddcarga%TYPE) IS
        SELECT cpa.vllimdis
              ,cpa.vlcalpre
              ,cpa.vlctrpre
              ,cpa.cdlcremp
              ,cpa.vlpot_lim_max
              ,cpa.vlpot_parc_maximo
              ,car.skcarga_sas
			  ,case car.skcarga_sas when 0 -- se tiver carga manual, utiliza o valor da carga
                    then cpa.iddcarga 
               else car.skcarga_sas end idCarga -- senão é automatica, usa carga sas
          FROM crapcpa cpa
			  ,tbepr_carga_pre_aprv car
         WHERE car.cdcooper = cpa.cdcooper
           AND car.idcarga  = cpa.iddcarga
           AND cpa.cdcooper = pr_cdcooper
           AND cpa.tppessoa = pr_tppessoa
           AND cpa.nrcpfcnpj_base = pr_nrcpfcnpj_base
           AND cpa.iddcarga = pr_idcarga;
      rw_crapcpa cr_crapcpa%rowtype;    
    
      -- Pré Aprovado Nao Liberado
      vr_flglibera_pre_aprv NUMBER := 0;
    
      -- Data Ultima Revisão Cadastral
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
			    
      -- Buscar descrição
      CURSOR cr_nature(pr_natjurid IN crapjur.natjurid%TYPE) IS
        SELECT gncdntj.dsnatjur
          FROM gncdntj
         WHERE gncdntj.cdnatjur = pr_natjurid;
      vr_dsnatjur gncdntj.dsnatjur%TYPE;
		
	    -- Buscar descrição
			CURSOR cr_ramatv(pr_cdseteco IN gnrativ.cdseteco%TYPE
			                ,pr_cdrmativ IN gnrativ.cdrmativ%TYPE) IS
				SELECT gnrativ.nmrmativ
					FROM gnrativ
				 WHERE gnrativ.cdseteco  = pr_cdseteco
					 AND gnrativ.cdrmativ = pr_cdrmativ;    
			vr_dsramatv gnrativ.nmrmativ%type;
		
      -- Buscar descrição
      CURSOR cr_cnae(pr_cdclcnae IN crapass.cdclcnae%TYPE) IS
        SELECT dscnae
          FROM tbgen_cnae
         WHERE cdcnae = pr_cdclcnae;
      vr_dscnae tbgen_cnae.dscnae%TYPE;
    
      -- Buscar informações de faturamento 
      CURSOR cr_crapjfn IS
        SELECT jfn.perfatcl
              ,'01' || to_char(jfn.mesftbru##1, 'fm00') || to_char(jfn.anoftbru##1, 'fm0000') dtfatme1
              ,'01' || to_char(jfn.mesftbru##2, 'fm00') || to_char(jfn.anoftbru##2, 'fm0000') dtfatme2
              ,'01' || to_char(jfn.mesftbru##3, 'fm00') || to_char(jfn.anoftbru##3, 'fm0000') dtfatme3
              ,'01' || to_char(jfn.mesftbru##4, 'fm00') || to_char(jfn.anoftbru##4, 'fm0000') dtfatme4
              ,'01' || to_char(jfn.mesftbru##5, 'fm00') || to_char(jfn.anoftbru##5, 'fm0000') dtfatme5
              ,'01' || to_char(jfn.mesftbru##6, 'fm00') || to_char(jfn.anoftbru##6, 'fm0000') dtfatme6
              ,'01' || to_char(jfn.mesftbru##7, 'fm00') || to_char(jfn.anoftbru##7, 'fm0000') dtfatme7
              ,'01' || to_char(jfn.mesftbru##8, 'fm00') || to_char(jfn.anoftbru##8, 'fm0000') dtfatme8
              ,'01' || to_char(jfn.mesftbru##9, 'fm00') || to_char(jfn.anoftbru##9, 'fm0000') dtfatme9
              ,'01' || to_char(jfn.mesftbru##10, 'fm00') || to_char( jfn.anoftbru##10, 'fm0000') dtfatme10
              ,'01' || to_char(jfn.mesftbru##11, 'fm00') || to_char( jfn.anoftbru##11, 'fm0000') dtfatme11
              ,'01' || to_char(jfn.mesftbru##12, 'fm00') || to_char( jfn.anoftbru##12, 'fm0000') dtfatme12
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
    
      -- Buscar ultimas operações de Crédito Liquidadas      
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
    
      -- Busca data da Liquidação        
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
           AND ris.nrctremp = NVL(pr_nrctremp,ris.nrctremp)
           AND ris.dtrefere >= pr_dtultdma
           AND ris.cdmodali in(299,499)
           AND ris.inddocto = 1;
      vr_qtdiaatr NUMBER;
    
      -- Checar se esta proposta foi liquidada em novos contratos
      CURSOR cr_eprliquid(pr_nrctremp IN crapepr.nrctremp%TYPE) IS
        SELECT 1
          FROM crawepr wpr2
         WHERE wpr2.cdcooper = pr_cdcooper
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
    
      -- Causou Prejuizo / Esta em Prejuizo
      -- PJ 450 - Diego Simas (AMcom)
      -- INICIO
      
      -- Cursor para encontrar o cpf/cnpj base do cooperado
      -- e encontrar todas as contas do cooperado atraves do seu CPF/CNPJ
      CURSOR cr_crapass_cpf_cnpj(pr_cdcooper IN crapass.cdcooper%TYPE
                                ,pr_nrdconta IN crapass.nrdconta%TYPE) IS
      SELECT nrdconta
        FROM crapass a
       WHERE a.cdcooper = pr_cdcooper
         AND a.nrcpfcnpj_base IN (SELECT nrcpfcnpj_base
                                    FROM crapass x
                                   WHERE x.cdcooper = a.cdcooper
                                     AND x.nrdconta = pr_nrdconta)
       ORDER BY nrdconta; 
       rw_crapass_cpf_cnpj cr_crapass_cpf_cnpj%ROWTYPE;
      
      -- Verificar se o cooperado teve emprestimo com prejuizo
      -- ou se esta com emprestimo em prejuizo na Cooperativa          
      CURSOR cr_crapepr_preju(pr_cdcooper IN crapepr.cdcooper%TYPE
                             ,pr_nrdconta IN crapepr.nrdconta%TYPE
                             ,pr_inliquid IN crapepr.inliquid%TYPE)IS
        SELECT 1
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.inprejuz = 1
					 AND ((pr_inliquid = 0 AND epr.vlsdprej > 0)
					  OR (pr_inliquid = 1 AND epr.vlsdprej = 0));
      rw_crapepr_preju cr_crapepr_preju%ROWTYPE;
    
      --> Consultar se já houve prejuizo nessa conta do cooperado
      CURSOR cr_prejuizo(pr_cdcooper tbcc_prejuizo.cdcooper%TYPE,
                         pr_nrdconta tbcc_prejuizo.nrdconta%TYPE)IS 
        SELECT 1
          FROM tbcc_prejuizo t
         WHERE t.cdcooper = pr_cdcooper
           AND t.nrdconta = pr_nrdconta;
      rw_prejuizo cr_prejuizo%ROWTYPE; 
      
      -- FIM
      -- PJ 450 - Diego Simas (AMcom)
      -- Causou Prejuizo / Esta em Prejuizo
    
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
        SELECT SUM(wpr.vlemprst) vlsdeved
              ,SUM(wpr.vlpreemp) vlpreemp
          FROM crawepr wpr
         WHERE wpr.cdcooper = pr_cdcooper
           AND wpr.nrdconta = pr_nrdconta
           AND wpr.nrctremp <> pr_nrctremp  -- Somente em aberto
           AND wpr.insitapr = 1             -- Somente Aprovadas
           AND wpr.insitest <> 6 -- Anulada
           AND NOT EXISTS(SELECT 1 
                           FROM crapepr epr
                          WHERE epr.cdcooper = wpr.cdcooper
                            AND epr.nrdconta = wpr.nrdconta
                            AND epr.nrctremp = wpr.nrctremp);
      rw_crawepr_outras cr_crawepr_outras%ROWTYPE;
      
      -- Busca saldo
      CURSOR cr_crapsld IS
        SELECT crapsld.qtddsdev
          FROM crapsld
         WHERE crapsld.cdcooper = pr_cdcooper
           AND crapsld.nrdconta = pr_nrdconta;
      rw_crapsld cr_crapsld%ROWTYPE;
      
      -- Buscar Contrato Limite Crédito
      CURSOR cr_craplim_chqesp IS
        SELECT lim.dtinivig
              ,lim.vllimite
          FROM craplim lim
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.nrdconta = pr_nrdconta
		   AND lim.tpctrlim = 1 -- Cheque Especial
           AND lim.insitlim = 2; -- Ativo
      rw_craplim_chqesp cr_craplim_chqesp%ROWTYPE;
    
      -- Cursor para pegar os contratos em que o cooperado é avalista
      -- Objeto Contas Avalizada do Proponente
      -- Diego Simas (AMcom)
      CURSOR cr_crapavl_contas (pr_cdcooper crapass.cdcooper%TYPE,
                                pr_nrdconta crapass.nrdconta%TYPE)IS
      SELECT ass.nrdconta conta, 
             ass.nmprimtl nome,
             ass.nrcpfcgc documento,
             ass.inpessoa tipo_pessoa,
             emp.nrctremp contrato
        FROM crapavl ava, 
             crapass ass,        
             crapepr emp
       WHERE ava.cdcooper = pr_cdcooper
         AND ava.nrdconta = pr_nrdconta
         AND emp.cdcooper = ava.cdcooper
         AND emp.nrdconta = ava.nrctaavd
         AND emp.nrctremp = ava.nrctravd
         AND emp.inliquid = 0
         AND ass.cdcooper = emp.cdcooper
          AND ass.nrdconta = emp.nrdconta;
      rw_crapavl_contas cr_crapavl_contas%ROWTYPE;

      -- Buscar ultimas ocorrências de Cheques Devolvidos
      CURSOR cr_crapneg_cheq(pr_qtmeschq     IN INTEGER
			                      ,pr_qtmeschqal11 IN INTEGER
														,pr_qtmeschqal12 IN INTEGER) IS
        SELECT dtiniest
              ,vlestour
              ,cdobserv
							,rownum
          FROM crapneg
         WHERE crapneg.cdcooper = pr_cdcooper
           AND crapneg.cdhisest = 1 /* Dev Cheques */
           AND crapneg.nrdconta = pr_nrdconta
           AND crapneg.dtiniest BETWEEN add_months(TRUNC(rw_crapdat.dtmvtolt),
					                                         -DECODE(crapneg.cdobserv
																									        ,11,pr_qtmeschqal11
																									        ,12,pr_qtmeschqal12
																													,pr_qtmeschq))
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
    
      -- Verificar se cooperado tem Debito Automático
      CURSOR cr_crapatr IS
        SELECT 1
          FROM crapatr
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dtfimatr IS NULL;
      rw_crapatr cr_crapatr%ROWTYPE;
    
      -- Buscar as informações do Arquivo SCR
      CURSOR cr_crapopf IS
        SELECT qtopesfn
              ,qtifssfn
              ,dtrefere
          FROM crapopf
         WHERE nrcpfcgc = rw_crapass.nrcpfcgc
         ORDER BY dtrefere DESC;
      rw_crapopf cr_crapopf%ROWTYPE;
      
      -- Na sequencia buscar os valores dos vencimentos
      CURSOR cr_crapvop(pr_nrcpfcgc in crapass.nrcpfcgc%type) IS
        SELECT SUM(vlvencto) vlopesfn
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 205 AND 290 THEN
                      vlvencto
                     ELSE
                      0
                   END) vlopevnc
              ,SUM(CASE
                     WHEN cdvencto BETWEEN 310 AND 330 THEN
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
         WHERE nrcpfcgc = pr_nrcpfcgc
           AND dtrefere = rw_crapopf.dtrefere;
      rw_crapvop     cr_crapvop%ROWTYPE;
    
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
           AND segnov.indsituacao in('A','R','E')
           AND segnov.nrapolice > 0;
    
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
    
      -- Buscar borderôs ativos
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
    
      -- Buscar borderôs ativos
      CURSOR cr_craptdb(pr_dtmvtolt IN crapdat.dtmvtolt%TYPE) IS
        SELECT SUM(vltitulo) vltitulo
          FROM craptdb
         WHERE craptdb.cdcooper = pr_cdcooper
           AND craptdb.nrdconta = pr_nrdconta
           AND ((craptdb.insittit = 4) OR
               (craptdb.insittit = 2 AND
               craptdb.dtdpagto = pr_dtmvtolt));
      rw_craptdb cr_craptdb%ROWTYPE;
    
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
           AND vlpagmta > 0; -- Com multa
    
      -- Para as parcelas pagas também buscaremos no cadastro de parcelas
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
           AND vlpagmta = 0; -- Sem multa
    
      -- Para TR, buscaremos nos lançamentos de pagtos a quantidade de lançamentos de Multa
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
        SELECT nvl(SUM(vllanmto),0)
          FROM craplem
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND nrctremp = pr_nrctremp
           AND cdhistor NOT IN (99, 98, 443) -- Remover liberação, juros e Multa
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
      
      
      -- Buscar saldos diarios dos associados
      CURSOR cr_crapsda (pr_cdcooper crapsda.cdcooper%type,
                         pr_nrdconta crapsda.nrdconta%type,
                         pr_dtiniest crapsda.dtmvtolt%type) IS
        SELECT vlsddisp,
               vllimcre
          FROM crapsda
         WHERE crapsda.cdcooper = pr_cdcooper
           AND crapsda.nrdconta = pr_nrdconta
           AND crapsda.dtmvtolt >= pr_dtiniest         
          ORDER BY crapsda.dtmvtolt DESC;
      
      -- Cursor para verificar se o cooperado teve linha de credito no periodo
      CURSOR cr_craplim (pr_cdcooper craplim.cdcooper%TYPE,
                         pr_nrdconta craplim.nrdconta%TYPE,
                         pr_dtiniest craplim.dtinivig%TYPE) IS
        SELECT 1 
          FROM craplim lim
         WHERE lim.cdcooper = pr_cdcooper
           AND lim.nrdconta = pr_nrdconta
           AND lim.insitlim IN (2,3)
           AND nvl(lim.dtfimvig,pr_dtiniest) >= pr_dtiniest;
      rw_craplim cr_craplim%ROWTYPE;
			
      -- Busca dos scores do Cooperado
      CURSOR cr_tbcrd_score(pr_cdcooper crapcop.cdcooper%TYPE
                           ,pr_nrdconta crapass.nrdconta%TYPE) IS
        SELECT sco.cdmodelo
              ,csc.dsmodelo
              ,sco.dtbase
              ,sco.nrscore_alinhado
              ,sco.dsclasse_score
              ,sco.flvigente
              ,sco.dsexclusao_principal
              ,row_number() over (partition By sco.cdmodelo
                                      order by sco.flvigente DESC, sco.dtbase DESC) nrseqreg 
          FROM crapass     ass
              ,tbcrd_score sco
              ,tbcrd_carga_score csc
         WHERE csc.cdmodelo      = sco.cdmodelo
           AND csc.dtbase        = sco.dtbase
           AND sco.cdcooper      = ass.cdcooper
           AND sco.tppessoa      = ass.inpessoa
           AND sco.nrcpfcnpjbase = ass.nrcpfcnpj_base
           AND ass.cdcooper = pr_cdcooper
           AND ass.nrdconta = pr_nrdconta
         ORDER BY sco.flvigente DESC
                 ,sco.dtbase DESC;
			
      --Verifica se é impossibilitado de negativação
      CURSOR cr_crapcyc (pr_cdcooper crapcyc.cdcooper%TYPE,
                         pr_nrdconta crapcyc.nrdconta%TYPE) IS
        SELECT 1
          FROM crapcyb cyb
          JOIN crapcyc cyc
            ON cyc.cdcooper = cyb.cdcooper
           AND cyc.cdorigem = cyb.cdorigem
           AND cyc.nrdconta = cyb.nrdconta
           AND cyc.nrctremp = cyb.nrctremp
         WHERE cyb.cdcooper = pr_cdcooper
           AND cyb.nrdconta = pr_nrdconta
           AND cyb.dtdbaixa is null
           AND cyc.flgehvip = 1 /* flag CIN */;
      rw_crapcyc cr_crapcyc%ROWTYPE;
	  	  
      --Verifica se possui atraso no cartão
      CURSOR cr_crdalat (pr_cdcooper tbcrd_alerta_atraso.cdcooper%TYPE,
                         pr_nrdconta tbcrd_alerta_atraso.nrdconta%TYPE) IS
        SELECT qtdias_atraso
          FROM tbcrd_alerta_atraso
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta;
      rw_crdalat cr_crdalat%ROWTYPE; 
      
      --Busca informação cessão cartão
      CURSOR cr_crapepr_cessao (pr_cdcooper crapepr.cdcooper%TYPE,
                                pr_nrdconta crapepr.nrdconta%TYPE) IS
        SELECT MAX(dtmvtolt) as dtUltCessao,
               CASE WHEN MIN(epr.inliquid) = 0 /* Se existe contrato nao liquidado */
                    THEN 1
                    ELSE 0
                END AS flgTemCessaoAtiva
          FROM crapepr epr
         WHERE epr.cdcooper = pr_cdcooper
           AND epr.nrdconta = pr_nrdconta
           AND epr.cdfinemp IN (SELECT fin.cdfinemp
                                  FROM crapfin fin
                                 WHERE fin.cdcooper = epr.cdcooper
                                   AND fin.tpfinali = 1 /* Cessao cartao */);
      rw_crapepr_cessao cr_crapepr_cessao%ROWTYPE;                        

      --Busca informação de Renegociação e Composição
      CURSOR cr_rencomp (pr_cdcooper crawepr.cdcooper%TYPE,
                         pr_nrdconta crawepr.nrdconta%TYPE,
                         pr_dtmovto  INTEGER) IS
        SELECT MAX(
               CASE WHEN wpr.idquapro = 3 /* Renegociacao */
                    THEN 1
                    ELSE 0
                 END) AS temRenegociacao,
               MAX(
               CASE WHEN wpr.idquapro = 4 /* Composicao */
                    THEN 1
                    ELSE 0
                 END) AS temComposicao
          FROM crawepr wpr
          JOIN crapepr epr /* Join para garantir que a proposta foi efetivada */
            ON epr.cdcooper = wpr.cdcooper
           AND epr.nrdconta = wpr.nrdconta
           AND epr.nrctremp = wpr.nrctremp
         WHERE wpr.cdcooper = pr_cdcooper
           AND wpr.nrdconta = pr_nrdconta
           AND epr.dtmvtolt >= add_months(TRUNC(SYSDATE), -pr_dtmovto);
      rw_rencomp cr_rencomp%ROWTYPE;
      
      --Busca Dados SCPC
      CURSOR cr_crapspc(pr_dtinclus INTEGER) IS
        SELECT nrctremp
              ,nrctrspc
              ,dtvencto
              ,dtinclus
              ,dtdbaixa
              ,tpidenti
              ,cdorigem
              ,tpinsttu
              ,vldivida
          FROM crapspc
         WHERE cdcooper = pr_cdcooper
           AND nrdconta = pr_nrdconta
           AND dtinclus >= add_months(TRUNC(SYSDATE),-pr_dtinclus);
      rw_crapspc cr_crapspc%ROWTYPE; 
      
    BEGIN
      --Verificar se a data existe
      OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
      FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
      -- Se não encontrar
      IF BTCH0001.cr_crapdat%NOTFOUND THEN
        -- Montar mensagem de critica
        vr_cdcritic:= 1;
        CLOSE BTCH0001.cr_crapdat;
        RAISE vr_exc_saida;
      ELSE
        -- Apenas fechar o cursor
        CLOSE BTCH0001.cr_crapdat;
      END IF;	
		
      -- Buscar informações cadastrais da conta
      OPEN cr_crapass;
      FETCH cr_crapass
        INTO rw_crapass;
    
      -- Se não encontrar registro
      IF cr_crapass%NOTFOUND THEN
        CLOSE cr_crapass;
        -- Sair acusando critica 9
        vr_cdcritic := 9;
        RAISE vr_exc_saida;
      ELSE
        CLOSE cr_crapass;
      END IF;
			
      IF pr_flprepon THEN 
        -- Buscaremos informações da proposta de empréstimo em aprovação    
        OPEN cr_crawepr;
        FETCH cr_crawepr INTO rw_crawepr;
    		
        -- Se não encontrar registro
        IF cr_crawepr%NOTFOUND THEN
          CLOSE cr_crawepr;
          -- Sair acusando critica 535 
          vr_cdcritic := 535;
          RAISE vr_exc_saida;
        ELSE
          CLOSE cr_crawepr;
        END IF;        

        -- Contratos que ele esta liquidando
        /*vr_vet_nrctrliq(1)  := rw_crawepr.nrctrliq##1;
        vr_vet_nrctrliq(2)  := rw_crawepr.nrctrliq##2;
        vr_vet_nrctrliq(3)  := rw_crawepr.nrctrliq##3;
        vr_vet_nrctrliq(4)  := rw_crawepr.nrctrliq##4;
        vr_vet_nrctrliq(5)  := rw_crawepr.nrctrliq##5;
        vr_vet_nrctrliq(6)  := rw_crawepr.nrctrliq##6;
        vr_vet_nrctrliq(7)  := rw_crawepr.nrctrliq##7;
        vr_vet_nrctrliq(8)  := rw_crawepr.nrctrliq##8;
        vr_vet_nrctrliq(9)  := rw_crawepr.nrctrliq##9;
        vr_vet_nrctrliq(10) := rw_crawepr.nrctrliq##10;*/
      END IF;  

      --Verificar se usa tabela juros
      vr_dstextab:= TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                              ,pr_nmsistem => 'CRED'
                                              ,pr_tptabela => 'USUARI'
                                              ,pr_cdempres => 11
                                              ,pr_cdacesso => 'TAXATABELA'
                                              ,pr_tpregist => 0);
      -- Se a primeira posição do campo
      -- dstextab for diferente de zero
      vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0'; 
      
      -- Buscar saldo devedor
      EMPR0001.pc_saldo_devedor_epr (pr_cdcooper   => pr_cdcooper     --> Cooperativa conectada
                                    ,pr_cdagenci   => 1               --> Codigo da agencia
                                    ,pr_nrdcaixa   => 0               --> Numero do caixa
                                    ,pr_cdoperad   => '1'             --> Codigo do operador
                                    ,pr_nmdatela   => 'ATENDA'        --> Nome datela conectada
                                    ,pr_idorigem   => 1 /*Ayllos*/    --> Indicador da origem da chamada
                                    ,pr_nrdconta   => pr_nrdconta     --> Conta do associado
                                    ,pr_idseqttl   => 1               --> Sequencia de titularidade da conta
                                    ,pr_rw_crapdat => rw_crapdat      --> Vetor com dados de parametro (CRAPDAT)
                                    ,pr_nrctremp   => 0               --> Numero contrato emprestimo
                                    ,pr_cdprogra   => 'B1WGEN0001'    --> Programa conectado
                                    ,pr_inusatab   => vr_inusatab     --> Indicador de utilizacão da tabela
                                    ,pr_flgerlog   => 'N'             --> Gerar log S/N
                                    ,pr_vlsdeved   => vr_vlendivi     --> Saldo devedor calculado
                                    ,pr_vltotpre   => vr_vltotpre     --> Valor total das prestacães
                                    ,pr_qtprecal   => vr_qtprecal     --> Parcelas calculadas
                                    ,pr_des_reto   => vr_des_reto     --> Retorno OK / NOK
                                    ,pr_tab_erro   => vr_tab_erro);   --> Tabela com possives erros

      -- Se houve retorno de erro
      IF vr_des_reto = 'NOK' THEN
        -- Extrair o codigo e critica de erro da tabela de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        
        -- Limpar tabela de erros
        vr_tab_erro.DELETE;
        
        RAISE vr_exc_saida;
      END IF;
      
      -- Enviaremos os dados básicos encontrados na tabela 
      vr_obj_generico.put('documento', fn_mask_cpf_cnpj(NVL(rw_crapass.nrcpfcgc,0),rw_crapass.inpessoa));
    
      -- Para Pessoas Fisicas 
      IF rw_crapass.inpessoa = 1 THEN
        vr_obj_generico.put('tipoPessoa', 'FISICA');
        -- Buscar dados do titular 
        OPEN cr_crapttl;
        FETCH cr_crapttl
          INTO rw_crapttl;
        CLOSE cr_crapttl;
      
        vr_obj_generico.put('nome', rw_crapttl.nmextttl);
        
        IF rw_crapttl.cdsexotl = 1 THEN
          vr_obj_generico.put('sexo', 'MASCULINO');	
        ELSE
          vr_obj_generico.put('sexo', 'FEMININO');	  			
        END IF;
        
        vr_obj_generico.put('dataNascimento'
                           ,fn_Data_ibra_motor(rw_crapass.dtnasctl));													 
        -- Se o Documento for RG
        IF rw_crapttl.tpdocttl = 'CI' THEN
          vr_obj_generico.put('rg', rw_crapttl.nrdocttl);
          vr_obj_generico.put('ufRg', rw_crapttl.cdoedttl);
        END IF;
        vr_obj_generico.put('nomeMae', rw_crapttl.nmmaettl);
			  /*vr_obj_generico.put('tipoNacionalidade',rw_crapttl.tpnacion);*/
        vr_obj_generico.put('nacionalidade'  ,rw_crapttl.dsnacion);
      
        -- Montar objeto profissao       
        IF rw_crapttl.dsproftl <> ' ' THEN
          vr_obj_generic2 := json();
          vr_obj_generic2.put('titulo', rw_crapttl.dsproftl);
          vr_obj_generico.put('profissao', vr_obj_generic2);
        END IF;
      
        -- Buscar endereço residencial
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
                           ,fn_Data_ibra_motor(rw_crapjur.dtiniatv));
      
        -- Buscar endereço comercial
        OPEN cr_crapenc(9);
        FETCH cr_crapenc
          INTO rw_crapenc;
        CLOSE cr_crapenc;
      
      END IF;
    
      -- Montar objeto Telefone para Telefones Celular/Residencial/Comercial      
      vr_lst_generic2 := json_list();
      -- Criar objeto só para este telefone
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
        vr_obj_generic2.put('numero',fn_somente_numeros_telefone(rw_craptfc.nrtelefo));
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
        -- Adicionar o array endereco no objeto
        vr_obj_generico.put('endereco', vr_obj_generic2);
      END IF;
    
      -- Montar informações Adicionais
      vr_obj_generic2 := json();
    
      -- Caixa Postal
      IF rw_crapenc.nrcxapst <> 0 THEN
        vr_obj_generic2.put('caixaPostal', rw_crapenc.nrcxapst);
      END IF;
    
      -- Conta
			vr_obj_generic2.put('conta', to_number(substr(pr_nrdconta,1,length(pr_nrdconta)-1)));
			vr_obj_generic2.put('contaDV', to_number(substr(pr_nrdconta,-1)));
    
      -- Agencia
      vr_obj_generic2.put('agenci', rw_crapass.cdagenci);
    
		  -- Data Admissão Coop
			vr_obj_generic2.put('dataAdmissaoCoop', fn_Data_ibra_motor(NVL(rw_crapass.dtmvtolt,rw_crapass.dtadmiss)));
			
      -- Matricula
      vr_obj_generic2.put('matric', rw_crapass.nrmatric);
    
      -- Tipo da Conta
      vr_obj_generic2.put('tipoConta'
                         ,rw_crapass.cdtipcta);
    
      -- Situação da Conta
      vr_obj_generic2.put('situacaoConta'
                         ,rw_crapass.cdsitdct);
    
      -- Email
      OPEN cr_crapcem;
      FETCH cr_crapcem INTO vr_dsdemail;
      CLOSE cr_crapcem;
      vr_obj_generic2.put('email',vr_dsdemail);
    
      -- Tipo do Imóvel
      IF rw_crapenc.incasprp <> 0 THEN
        vr_obj_generic2.put('tipoImovel'
                           ,rw_crapenc.incasprp);
      END IF;
      
      --- Enviar fixo para o CDC quando estiver null ou 0
      IF coalesce(rw_crapenc.incasprp,0)=0 and rw_crawepr.inintcdc=1 THEN
        vr_obj_generic2.put('tipoImovel', 1);
      END IF;

      -- Valor do Imovel (Somente quando não for alugado)
      IF rw_crapenc.vlalugue > 0 AND rw_crapenc.incasprp NOT IN (0, 3) THEN
        vr_obj_generic2.put('valorImovel',este0001.fn_decimal_ibra(rw_crapenc.vlalugue));
        vr_obj_generic2.put('valorAluguel',este0001.fn_decimal_ibra(0));
        /*vr_vlalugue := 0;*/
			ELSE
				-- Quando alugado enviaremos valor Aluguel
				vr_obj_generic2.put('valorImovel',este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('valorAluguel', este0001.fn_decimal_ibra(rw_crapenc.vlalugue));
        /*vr_vlalugue := rw_crapenc.vlalugue;*/
			END IF;    
			
			-- Busca dos bens do associado CURSOR cr_crapbem e vr_vlrtotbem
			OPEN cr_crapbem;
			FETCH cr_crapbem
			 INTO vr_vltotbem;
			CLOSE cr_crapbem;

			-- Se o titular possui bens
			vr_obj_generic2.put('valorTotalBens', este0001.fn_decimal_ibra(vr_vltotbem));
			
      -- Data de Inicio de Residência
      IF rw_crapenc.dtinires IS NOT NULL THEN
        vr_obj_generic2.put('inicioResidImovel'
                           ,fn_Data_ibra_motor(rw_crapenc.dtinires));
      END IF;
    
      -- Data de demissão na Cooperativa
      IF rw_crapass.dtelimin IS NOT NULL THEN
        vr_obj_generic2.put('dataDemissao'
                           ,fn_Data_ibra_motor(rw_crapass.dtelimin));
      END IF;
	    
			-- Data da consulta no SPC 
			IF rw_crapass.dtcnsspc IS NOT NULL THEN
				vr_obj_generic2.put('dataConsultaSPC'
													 ,fn_Data_ibra_motor(rw_crapass.dtcnsspc));
			END IF;
		    
			-- Data da inclusão no SPC pela cooperativa
			IF rw_crapass.dtdsdspc IS NOT NULL THEN
        vr_obj_generic2.put('dataInclusaoSPCpelaCoop'
                           ,fn_Data_ibra_motor(rw_crapass.dtdsdspc));
      END IF;
    
      -- Está no SPC(cooperativa)
      vr_obj_generic2.put('SPCpelaCoop'
                         ,NVL(rw_crapass.inadimpl,0)=1);
    
      -- Está no SPC(outras IFs)
      sspc0001.pc_busca_consulta_biro(pr_cdcooper => pr_cdcooper
                                     ,pr_nrdconta => pr_nrdconta
                                     ,pr_nrconbir => vr_nrconbir
                                     ,pr_nrseqdet => vr_nrseqdet);
      -- Se encontrar 
      IF NVL(vr_nrconbir,0) > 0 AND NVL(vr_nrseqdet,0) > 0 THEN 
        -- Buscar o detalhamento da consulta
        sspc0001.pc_verifica_situacao(pr_nrconbir => vr_nrconbir
                                     ,pr_nrseqdet => vr_nrseqdet
                                     ,pr_cdbircon => vr_cdbircon
                                     ,pr_dsbircon => vr_dsbircon
                                     ,pr_cdmodbir => vr_cdmodbir
                                     ,pr_dsmodbir => vr_dsmodbir
                                     ,pr_flsituac => vr_flsituac);
      END IF;
      vr_obj_generic2.put('SPCoutrasIFs',vr_flsituac='S');
    
      -- CCF
      vr_obj_generic2.put('ccf', NVL(rw_crapass.inccfcop,0)=1);
    
      -- Cadastro Positivo
      vr_obj_generic2.put('cadastroPositivo'
                         ,rw_crapass.incadpos);
    
      -- Data Consulta SCR
      IF rw_crapass.dtcnsscr IS NOT NULL THEN
        vr_obj_generic2.put('dataConsultaSCR'
                           ,fn_Data_ibra_motor(rw_crapass.dtcnsscr));
      END IF;
      
      -- PreAprovado
      vr_flglibera_pre_aprv := 0;
      
      -- Busca a carga ativa
      vr_idcarga := empr0002.fn_idcarga_pre_aprovado_cta(pr_cdcooper => pr_cdcooper
                                                        ,pr_nrdconta => pr_nrdconta);
      --  Caso nao possua carga ativa
      IF vr_idcarga > 0 THEN
          -- Verifica se existe Bloqueio em Conta
        vr_flglibera_pre_aprv := empr0002.fn_flg_preapv_liberado(pr_cdcooper,pr_nrdconta);
        -- Efetuar o calculo do PreAprovado disponivel
        vr_vlparcel := 0;
        vr_vldispon := 0;
        -- Chamar o calculo e desprezar os retornos não necessários para esta   
        empr0002.pc_calc_pre_aprovado_analitico(pr_cdcooper => pr_cdcooper                      -- Cooperatia
                                               ,pr_tppessoa => rw_crapass.inpessoa              -- TpPessoa
                                               ,pr_nrcpf_cnpj_base => rw_crapass.nrcpfcnpj_base -- CPF/CNPJ Base
                                               ,pr_idcarga  => vr_idcarga                    -- ID da Carga                                     
                                               -- Saida
                                               ,pr_nrfimpre          => vr_nrfimpre          -- Quantidade de parcelas
                                               ,pr_vlpot_parc_max    => vr_vlpot_parc_max    -- Potencial parcela Maximo
                                               ,pr_vlpot_lim_max     => vr_vlpot_lim_max     -- Potencial Limite Maximo
                                               ,pr_vl_scr_61_90      => vr_vl_scr_61_90      -- SCR de 61 a 90
                                               ,pr_vl_scr_61_90_cje  => vr_vl_scr_61_90_cje  -- SCR de 61 a 90 Conjuge
                                               ,pr_vlope_pos_scr     => vr_vlope_pos_scr     -- Saldo Devedor Pos Scr
                                               ,pr_vlope_pos_scr_cje => vr_vlope_pos_scr_cje -- Saldo Devedor Pos Scr Conjuge
                                               ,pr_vlprop_andamt     => vr_vlprop_andamt     -- Proposta em Andamento
                                               ,pr_vlprop_andamt_cje => vr_vlprop_andamt_cje -- Proposta em Andamento Conjuge
                                               -- Calculo que será devolvido  
                                               ,pr_vlparcel          => vr_vlparcel          -- Valor Parcela
                                               ,pr_vldispon          => vr_vldispon          -- Valor Disponível
                                               ,pr_dscritic => vr_dscritic);                 -- Saida de Critica
        IF vr_dscritic IS NOT NULL THEN
          RAISE vr_exc_saida;
        END IF;

        --> Verifica se esta na tabela do pre-aprovado
        OPEN cr_crapcpa(pr_cdcooper => pr_cdcooper
                       ,pr_tppessoa => rw_crapass.inpessoa
                       ,pr_nrcpfcnpj_base => rw_crapass.nrcpfcnpj_base
                       ,pr_idcarga  => vr_idcarga);
        FETCH cr_crapcpa INTO rw_crapcpa;
        -- Somente casa Haja
        IF cr_crapcpa%FOUND THEN
          CLOSE cr_crapcpa;
          -- Copiar limite disponivel, potencial SAS e valor contratado da Carga
          vr_skcarga  := rw_crapcpa.skcarga_sas;          
          vr_vlctrpre := rw_crapcpa.vlctrpre;
          vr_vlpotlim := rw_crapcpa.vlpot_lim_max;
          vr_vlpotpar := rw_crapcpa.vlpot_parc_maximo;          
        ELSE
          CLOSE cr_crapcpa;
        END IF; 
      END IF;
    
      -- Enviar os campos do PreAprovado
      vr_obj_generic2.put('liberaPreAprovad', (nvl(vr_flglibera_pre_aprv,0)=1));
      vr_obj_generic2.put('idCargaPreAprovado', este0001.fn_decimal_ibra(vr_skcarga));            
      vr_obj_generic2.put('limitePreAprovado', este0001.fn_decimal_ibra(nvl(vr_vldispon,0)));
      vr_obj_generic2.put('limiteParcelaPreAprovado', este0001.fn_decimal_ibra(nvl(vr_vlparcel,0)));
      --vr_obj_generic2.put('utilizPreAprovado', este0001.fn_decimal_ibra(nvl(vr_vlctrpre,0)));
      --vr_obj_generic2.put('utilizParcelaPreAprovado', este0001.fn_decimal_ibra(nvl(vr_vl_scr_61_90 + vr_vlope_pos_scr + vr_vlope_pos_scr_cje + vr_vlprop_andamt + vr_vlprop_andamt_cje,0)));
      vr_obj_generic2.put('potLimMaxPreAprovado', este0001.fn_decimal_ibra(nvl(vr_vlpotlim,0)));
      vr_obj_generic2.put('potParMaxPreAprovado', este0001.fn_decimal_ibra(nvl(vr_vlpotpar,0)));
    
      -- Data Ultima Revisão Cadastral      
      OPEN cr_revisa;
      FETCH cr_revisa
        INTO vr_dtaltera;
      CLOSE cr_revisa;
    
      IF vr_dtaltera IS NOT NULL THEN
        vr_obj_generic2.put('dataUltimaRevCadast', fn_Data_ibra_motor(vr_dtaltera));
      END IF;
    
      vr_indexis := 0;
      OPEN cr_alerta;
      FETCH cr_alerta
        INTO vr_indexis;
      CLOSE cr_alerta;
    
      vr_obj_generic2.put('estaALERTA', (vr_indexis=1));
    
      -- Conta tem Registro Contra Ordem
      vr_obj_generic2.put('estaDCTROR'
                         ,(NVL(rw_crapass.cdsitdtl,0) = 2));
      				
      -- Buscar as informações do Arquivo SCR   
      OPEN cr_crapopf;
      FETCH cr_crapopf
        INTO rw_crapopf;
      
      IF cr_crapopf%FOUND THEN
        CLOSE cr_crapopf;
          
        -- Na sequencia buscar os valores dos vencimentos
        OPEN cr_crapvop(rw_crapass.nrcpfcgc);
        FETCH cr_crapvop
          INTO rw_crapvop;
        CLOSE cr_crapvop;    
          
        -- Enfim, enviar as informações ao JSON
        vr_obj_generic2.put('conscrOpSFN'
                           ,este0001.fn_decimal_ibra(rw_crapvop.vlopesfn));
        vr_obj_generic2.put('conscrOpVenc'
                           ,este0001.fn_decimal_ibra(rw_crapvop.vlopevnc));
        vr_obj_generic2.put('conscrOpPrej'
                           ,este0001.fn_decimal_ibra(rw_crapvop.vlopeprj));
        vr_obj_generic2.put('conscrQtOper', rw_crapopf.qtopesfn);
        vr_obj_generic2.put('conscrQtIFs', rw_crapopf.qtifssfn);
        vr_obj_generic2.put('conscr61a90'
                           ,este0001.fn_decimal_ibra(rw_crapvop.vlvcto130));        
      ELSE         
        CLOSE cr_crapopf;
        
        -- Enfim, enviar as informações ao JSON
        vr_obj_generic2.put('conscrOpSFN'
                           ,este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('conscrOpVenc'
                           ,este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('conscrOpPrej'
                           ,este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('conscrQtOper', 0);
        vr_obj_generic2.put('conscrQtIFs', 0);
        vr_obj_generic2.put('conscr61a90'
                           ,este0001.fn_decimal_ibra(0));  
        
      END IF;   
      
      -- Buscar outras propostas em Andamento      
      OPEN cr_crawepr_outras;
      FETCH cr_crawepr_outras
        INTO rw_crawepr_outras;
      CLOSE cr_crawepr_outras;
    
      -- Propostas Em Andamento
      vr_obj_generic2.put('somaOperacoesAndamento'
                         ,este0001.fn_decimal_ibra(nvl(rw_crawepr_outras.vlsdeved,0)));
      vr_obj_generic2.put('somaPrestacoesAndamento'
                         ,este0001.fn_decimal_ibra(nvl(rw_crawepr_outras.vlpreemp,0)));
      
      -- Soma das Operações em Andamento
      vr_obj_generic2.put('somaOperacoes'
                         ,este0001.fn_decimal_ibra(nvl(vr_vlendivi,0)));
      vr_obj_generic2.put('somaPrestacoes'
                         ,este0001.fn_decimal_ibra(nvl(vr_vltotpre,0)));
      
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
      
        -- Habilitação Menor
        vr_obj_generic2.put('reponsabiLegal',rw_crapttl.inhabmen);
      
        -- Data Emancipação
        IF rw_crapttl.dthabmen IS NOT NULL THEN
          vr_obj_generic2.put('dataEmancipa'
                             ,fn_Data_ibra_motor(rw_crapttl.dthabmen));
        END IF;
      
        -- Valor Rendimento
        IF pr_vlsalari > rw_crapttl.vlrendim THEN 
          vr_obj_generic2.put('valorSalario'
                             ,este0001.fn_decimal_ibra(pr_vlsalari));
        ELSE
          vr_obj_generic2.put('valorSalario'
                             ,este0001.fn_decimal_ibra(rw_crapttl.vlrendim));            
        END IF;
      
        -- Outros Rendimentos
        vr_obj_generic2.put('valorOutrosRendim'
                           ,este0001.fn_decimal_ibra(rw_crapttl.vroutrorn));
        
        -- Data Consulta CPF
        IF rw_crapttl.dtcnscpf IS NOT NULL THEN
          vr_obj_generic2.put('dataConsultaCPF'
                             ,fn_Data_ibra_motor(rw_crapttl.dtcnscpf));
        END IF;
      
        -- Situação CPF
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
      
        -- Natureza Ocupação
        IF rw_crapttl.cdnatopc <> 0 THEN
          vr_obj_generic2.put('naturezaOcupacao'
                             ,rw_crapttl.cdnatopc);
        END IF;
      
        -- Ocupação
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
      
        -- Data Admissão
        IF rw_crapttl.dtadmemp IS NOT NULL THEN
          vr_obj_generic2.put('dataAdmissao'
                             ,fn_Data_ibra_motor(rw_crapttl.dtadmemp));
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
                           ,(NVL(rw_crapttl.inpolexp,0)=1));
      
        OPEN cr_depend;
        FETCH cr_depend
          INTO vr_qtdepend;
        CLOSE cr_depend;
      
        vr_obj_generic2.put('quantDependentes', vr_qtdepend);
      
      ELSE
      
        -- Faturamento Annual 
        vr_obj_generic2.put('valorFaturamentoAnual'
                           ,este0001.fn_decimal_ibra(rw_crapjur.vlfatano));
        
        -- Data Consulta CNPJ
        IF rw_crapass.dtcnscpf IS NOT NULL THEN
          vr_obj_generic2.put('dataConsultaCNPJ'
                             ,fn_Data_ibra_motor(rw_crapass.dtcnscpf));
        END IF;
      
        -- Situação CNPJ
        vr_obj_generic2.put('situacaoCNPJ'
                           ,rw_crapass.cdsitcpf);
      
        -- Nome Fantasia
        IF rw_crapjur.nmfansia <> ' ' THEN
          vr_obj_generic2.put('nomeFantasia', rw_crapjur.nmfansia);
        END IF;
      
        -- Natureza Juridica
        IF rw_crapjur.natjurid <> 0 THEN
          -- Buscar descrição          
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
      
        -- Quantidade Funcionários
        vr_obj_generic2.put('quantFuncionarios', rw_crapjur.qtfuncio);
      
        -- Ramo Atividade
        IF rw_crapjur.cdseteco <> 0 AND rw_crapjur.cdrmativ <> 0 THEN
          -- Buscar descrição          
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
        
          -- Buscar descrição
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
				
	      -- Buscar faturamento médio mensal
				cada0001.pc_calcula_faturamento(pr_cdcooper => pr_cdcooper
																			 ,pr_cdagenci => 1
																			 ,pr_nrdcaixa => 1
																			 ,pr_nrdconta => pr_nrdconta
																			 ,pr_vlmedfat => vr_vlmedfat
																			 ,pr_tab_erro => vr_tab_erro
																			 ,pr_des_reto => vr_des_reto);

				-- Media Faturamento Anual
				vr_obj_generic2.put('mediaFaturamentoAnual', este0001.fn_decimal_ibra(round(vr_vlmedfat,0)));
						
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
                             ,fn_Data_ibra_motor(rw_crapjur.dtregemp));
        END IF;
      
        -- Orgao de Registro da Empresa
        IF rw_crapjur.orregemp IS NOT NULL THEN
          vr_obj_generic2.put('orgaoRegistroEmpresa', rw_crapjur.orregemp);
        END IF;
      
        -- Numero Registro Empresa
        IF rw_crapjur.nrregemp <> 0 THEN
          vr_obj_generic2.put('numeroRegistroEmpresa', rw_crapjur.nrregemp);
        END IF;
      
        -- Data Inscrição Municipal
        IF rw_crapjur.dtinsnum IS NOT NULL THEN
          vr_obj_generic2.put('dataInscricMunicipal'
                             ,fn_Data_ibra_motor(rw_crapjur.dtinsnum));
        END IF;
      
        -- Numero Inscrição Municipal
        IF rw_crapjur.nrinsmun <> 0 THEN
          vr_obj_generic2.put('numeroInscricMunicipal'
                             ,rw_crapjur.nrinsmun);
        END IF;
      
        -- Numero Inscrição Estadual
        IF rw_crapjur.nrinsest <> 0 THEN
          vr_obj_generic2.put('numeroInscricEstadual', rw_crapjur.nrinsest);
        END IF;
      
        -- Participante REFIS
        vr_obj_generic2.put('optanteRefis'
                           ,(nvl(rw_crapjur.flgrefis,0)=1));
      
        -- Numero Nire
        IF rw_crapjur.nrcdnire <> 0 THEN
          vr_obj_generic2.put('numeroNIRE', rw_crapjur.nrcdnire);
        END IF;
      
        -- CNAE
        IF rw_crapass.cdclcnae <> 0 THEN
          -- Buscar descrição          
          OPEN cr_cnae(rw_crapass.cdclcnae);
          FETCH cr_cnae
            INTO vr_dscnae;
          CLOSE cr_cnae;
        
          vr_obj_generic2.put('cnaeCodigo'
                             ,rw_crapass.cdclcnae);
          vr_obj_generic2.put('cnaeDescricao'
                             ,vr_dscnae);														 
        END IF;
      
        -- Buscar informações do Faturamento
        OPEN cr_crapjfn;
        FETCH cr_crapjfn
          INTO rw_crapjfn;
        CLOSE cr_crapjfn;
      
        -- Percentual faturamento cliente único
        IF rw_crapjfn.perfatcl <> 0 THEN
          vr_obj_generic2.put('percentFaturamenMaiorCliente'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.perfatcl));
        END IF; 
      END IF;
    		    
      -- Causou Prejuizo / Esta em Prejuizo     
      -- PJ 450 - Diego Simas (AMcom) 
      -- INICIO      
      
      vr_flesprej := FALSE;
      vr_flemprej := FALSE;

      FOR rw_crapass_cpf_cnpj              
       IN cr_crapass_cpf_cnpj
         (pr_cdcooper => pr_cdcooper
         ,pr_nrdconta => pr_nrdconta) LOOP    
          -- Para cada conta do associado cpf/cnpj 
          -- verificamos se está em prejuízo de empréstimo e conta corrente
          -- ou se já causou prejuizo de emprestimo e conta corrente
          
          -- Está em Prejuizo na Cooperativa      
          -- Emprestimo
          OPEN cr_crapepr_preju(pr_cdcooper => pr_cdcooper 
                               ,pr_nrdconta => rw_crapass_cpf_cnpj.nrdconta
                               ,pr_inliquid => 0);
      FETCH cr_crapepr_preju
        INTO rw_crapepr_preju;
    
          IF cr_crapepr_preju%FOUND THEN
             vr_flemprej := TRUE;
      END IF;
          
      CLOSE cr_crapepr_preju;
    
          -- Conta Corrente
          vr_inprejuz := PREJ0003.fn_verifica_preju_conta(pr_cdcooper, rw_crapass_cpf_cnpj.nrdconta);
          IF vr_inprejuz = TRUE THEN
             vr_flemprej := TRUE;
          END IF;
          
          -- Esteve algum dia em Prejuizo na Cooperativa      
          -- Emprestimo
          OPEN cr_crapepr_preju(pr_cdcooper => pr_cdcooper 
                               ,pr_nrdconta => rw_crapass_cpf_cnpj.nrdconta
                               ,pr_inliquid => 1);
      FETCH cr_crapepr_preju
        INTO rw_crapepr_preju;
    
          IF cr_crapepr_preju%FOUND THEN
             vr_flesprej := TRUE;
      END IF;
          
      CLOSE cr_crapepr_preju;
    
          -- Conta Corrente                   
          OPEN cr_prejuizo(pr_cdcooper => pr_cdcooper 
                          ,pr_nrdconta => rw_crapass_cpf_cnpj.nrdconta);
          FETCH cr_prejuizo
           INTO rw_prejuizo;
          
          IF cr_prejuizo%FOUND THEN
             vr_flesprej := TRUE;
          END IF;
          
          CLOSE cr_prejuizo;
                
      END LOOP;
    
      -- Enviar causouPrejuizoCoop
      vr_obj_generic2.put('causouPrejuizoCoop', vr_flesprej);
      -- Enviar estaEmPrejuizoCoop
      vr_obj_generic2.put('estaEmPrejuizoCoop', vr_flemprej);
    
      -- FIM      
      -- PJ 450 - Diego Simas (AMcom)
      -- Causou Prejuizo / Esta em Prejuizo
    
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
        -- Buscar dados do Saldo para enviar quantos dias está em estouro
        OPEN cr_crapsld;
        FETCH cr_crapsld INTO rw_crapsld;
        CLOSE cr_crapsld;
        vr_qtdiaest := nvl(rw_crapsld.qtddsdev,0);
      ELSE
        vr_vladtdep := 0;
        vr_qtdiaest := 0;
      END IF;
    
      -- Enviar dados do Estouro
      vr_obj_generic2.put('quantDiaEstouroVigente',vr_qtdiaest);
    
      -- Enviar o valorAdiantDeposit
      vr_obj_generic2.put('valorAdiantDeposit'
                         ,este0001.fn_decimal_ibra(vr_vladtdep));
    
			-- Buscar parâmetro da quantidade de meses para busca dos Estouros/Adiantamentos
      IF nvl(pr_tpprodut,0) = 1 THEN -- desconto titulo (TELA PAREST)
        vr_qtmesest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_EST_DESC');
      ELSIF nvl(pr_tpprodut,0) = 4 THEN -- cartao (TELA PAREST)
        vr_qtmesest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_EST_CRD');
      ELSE -- emprestimo (TELA PAREST)
        vr_qtmesest := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_ESTOUROS');
      END IF;
		            
      -- Montar objeto para Estrutura Estouros
      vr_lst_generic3 := json_list();
    
      /* Inicializar */  
      vr_qqdiacheq := 0;
    
      /* Obter as informaões de estouro do cooperado */
      RISC0001.pc_lista_estouros( pr_cdcooper      => pr_cdcooper     --> Codigo Cooperativa
                                 ,pr_cdoperad      => '1'             --> Operador conectado
                                 ,pr_nrdconta      => pr_nrdconta     --> Numero da Conta
                                 ,pr_idorigem      => 5               --> Identificador Origem
                                 ,pr_idseqttl      => 1               --> Sequencial do Titular
                                 ,pr_nmdatela      => 'RATI0001'      --> Nome da tela
                                 ,pr_dtmvtolt      => rw_crapdat.dtmvtolt --> Data do movimento
                                 ,pr_tab_estouros  => vr_tab_estouros --> Informações de estouro na conta
                                 ,pr_dscritic      => vr_dscritic);   --> Retorno de erro

      -- verificar se retornou critica
      IF vr_dscritic is not null THEN
        raise vr_exc_saida;
      END IF;

      /* Data do inicio do estouro a partir de um ano atras */
      vr_dtiniest := add_months(rw_crapdat.dtmvtolt, -vr_qtmesest);

      -- varrer temptable de estouro
      IF vr_tab_estouros.count > 0 THEN
        FOR I IN vr_tab_estouros.FIRST..vr_tab_estouros.LAST LOOP
          IF vr_tab_estouros(I).dtiniest >= vr_dtiniest AND vr_tab_estouros(I).cdhisest  = 'Estouro' THEN
            -- Para cada registro de Estouro, criar objeto para a operação e enviar suas informações 
            vr_obj_generic3 := json();        
            
            vr_obj_generic3.put('quantDiaEstouro', vr_tab_estouros(I).qtdiaest);
            vr_obj_generic3.put('dataEstouro'
                               ,fn_Data_ibra_motor(vr_tab_estouros(I).dtiniest));
            vr_obj_generic3.put('valorEstouro'
                               ,este0001.fn_decimal_ibra(vr_tab_estouros(I).vlestour));
                               
            -- Adicionar Operação na lista
            vr_lst_generic3.append(vr_obj_generic3.to_json_value());  
            

          END IF;
        END LOOP;
      END IF;
      
      -- Adicionar o array Estouros no objeto informações adicionais
			vr_obj_generic2.put('estouro', vr_lst_generic3);		
      
      
      
      -- Verificar se cooperado possui contrato de
      -- limite de credito no periodo
      OPEN cr_craplim( pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta,
                       pr_dtiniest => vr_dtiniest);
      FETCH cr_craplim INTO rw_craplim;
      
      -- se não possuir contrato de limite de credito, não precisa
      -- verificar a sda
      IF cr_craplim%NOTFOUND THEN                 
        CLOSE cr_craplim;
      ELSE
        CLOSE cr_craplim;                  
        -- Varrer tabela de saldo do dia
        FOR rw_crapsda IN cr_crapsda ( pr_cdcooper => pr_cdcooper,
                                       pr_nrdconta => pr_nrdconta,
                                       pr_dtiniest => vr_dtiniest) LOOP

          -- se o saldo for negativo e o maior que o limite de credito
          IF rw_crapsda.vlsddisp < 0  AND
             rw_crapsda.vlsddisp >= (rw_crapsda.vllimcre*-1) THEN
            vr_qtdiaat2 := nvl(vr_qtdiaat2,0) + 1;
          ELSE
            -- armazenar maior data
            IF nvl(vr_qtdiaat2,0) > nvl(vr_qqdiacheq,0) THEN
              vr_qqdiacheq := nvl(vr_qtdiaat2,0);
            END IF;
            vr_qtdiaat2 := 0;
          END IF;

        END LOOP;
      END IF; -- FIM IF cr_craplim%NOTFOUND 

      IF vr_qqdiacheq = 0  THEN
        vr_qqdiacheq := vr_qtdiaat2;
      END IF;

      IF vr_qtdiaat2 > vr_qqdiacheq THEN
        vr_qqdiacheq := vr_qtdiaat2;
      END IF;
    
      -- Enviar informações de Cheque Especial 
      vr_obj_generic2.put('quantDiasChequeEspecial', NVL(vr_qqdiacheq,0));
						
      -- Buscar Contrato Limite Crédito    
      OPEN cr_craplim_chqesp;
      FETCH cr_craplim_chqesp
        INTO rw_craplim_chqesp;
      CLOSE cr_craplim_chqesp;
    
      -- Enviar as informações do limite de crédito (somente se houver limite de crédito)
      IF rw_craplim_chqesp.vllimite > 0 THEN
        vr_obj_generic2.put('dataContratoLimiteCred'
                           ,fn_Data_ibra_motor(rw_craplim_chqesp.dtinivig));
        vr_obj_generic2.put('limiteCredito'
                           ,este0001.fn_decimal_ibra(rw_craplim_chqesp.vllimite));
      
        -- Enviar saldo utilizado do limite de crédito
        IF vr_tab_sald(0).vlsddisp < 0 THEN
          -- Se temos adiantamento a depositante 
          IF vr_vladtdep < 0 THEN
            -- Estamos usando todo o limite
            vr_obj_generic2.put('saldoUtilizLimiteCredito'
                               ,este0001.fn_decimal_ibra(rw_craplim_chqesp.vllimite));
          ELSE
            -- O Saldo negativo é o valor utilizado 
            vr_obj_generic2.put('saldoUtilizLimiteCredito'
                               ,este0001.fn_decimal_ibra(vr_tab_sald(0).vlsddisp));
          END IF;
        ELSE
          vr_obj_generic2.put('saldoUtilizLimiteCredito'
                             ,este0001.fn_decimal_ibra(0));
        END IF;
      END IF;
    
      -- Chamar rotina para busca das Médias da Conta Corrente
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
    
      -- Testar erros e se não houver, enviar os Saldos Médios
      IF vr_tab_comp_medias.count > 0 THEN 
        vr_obj_generic2.put('saldoMedioAtual'
                           ,este0001.fn_decimal_ibra(vr_tab_comp_medias(vr_tab_comp_medias.first).vltsddis));
        vr_obj_generic2.put('saldoMedioTrimes'
                           ,este0001.fn_decimal_ibra(vr_tab_comp_medias(vr_tab_comp_medias.first).vlsmdtri));
        vr_obj_generic2.put('saldoMedioSemes'
                           ,este0001.fn_decimal_ibra(vr_tab_comp_medias(vr_tab_comp_medias.first).vlsmdsem));
      ELSE
        vr_obj_generic2.put('saldoMedioAtual'
                           ,este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('saldoMedioTrimes'
                           ,este0001.fn_decimal_ibra(0));
        vr_obj_generic2.put('saldoMedioSemes'
                           ,este0001.fn_decimal_ibra(0));
      END IF;
      
      -- Acionar rotina de ocorrências na conta 
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
      IF vr_tab_ocorren.count > 0 THEN 
        vr_obj_generic2.put('ratingAtivoConta', vr_tab_ocorren(vr_tab_ocorren.first).inrisctl);
        vr_obj_generic2.put('ratingConta', vr_tab_ocorren(vr_tab_ocorren.first).indrisco);
        vr_obj_generic2.put('riscoCooperado', NVL(trim(vr_tab_ocorren(vr_tab_ocorren.first).nivrisco),'A'));
      ELSE
        vr_obj_generic2.put('ratingAtivoConta', 'A');
        vr_obj_generic2.put('ratingConta', 'A');
        vr_obj_generic2.put('riscoCooperado', 'A');        
      END IF;
      
      -- Buscar risco do grupo econômico (se existir)
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
    
      -- Verificar se cooperado tem Debito Automático
      OPEN cr_crapatr;
      FETCH cr_crapatr
        INTO rw_crapatr;
    
      IF cr_crapatr%FOUND THEN
        vr_temdebaut := TRUE;
      ELSE
        vr_temdebaut := FALSE;
      END IF;
      CLOSE cr_crapatr;
    
      -- Enviar flag se tem DebAutomático
      vr_obj_generic2.put('temDebaut', vr_temdebaut);
    
      -- Buscar informações e Saldos das Aplicações 
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
      apli0005.pc_busca_saldo_aplicacoes(pr_cdcooper => pr_cdcooper --> Código da Cooperativa
                                        ,pr_cdoperad => 1 --> Código do Operador
                                        ,pr_nmdatela => 'ATENDA' --> Nome da Tela
                                        ,pr_idorigem => 5 --> AYLLOS WEB 
                                        ,pr_nrdconta => pr_nrdconta --> Número da Conta
                                        ,pr_idseqttl => 1 --> Titular da Conta
                                        ,pr_nraplica => 0 --> Número da Aplicação / Parâmetro Opcional
                                        ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data de Movimento
                                        ,pr_cdprodut => 0 --> Código do Produto -–> Parâmetro Opcional
                                        ,pr_idblqrgt => 1 --> Identificador de Bloqueio de Resgate  
                                        ,pr_idgerlog => 0 --> Identificador de Log (0 – Não / 1 – Sim)
                                        ,pr_vlsldtot => vr_vlsldtot --> Saldo Total da Aplicação
                                        ,pr_vlsldrgt => vr_vlsldrgt --> Saldo Total para Resgate
                                        ,pr_cdcritic => vr_cdcritic --> Código da crítica
                                        ,pr_dscritic => vr_dscritic); --> Descrição da crítica
      IF NVL(vr_cdcritic, 0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
      vr_vlsldapl := vr_vlsldapl + vr_vlsldrgt;
    
      -- Buscar informações e Saldos das Poupanças Programadas
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
    
      -- Busca Saldo Bloqueado Judicial para Aplicações
      gene0005.pc_retorna_valor_blqjud(pr_cdcooper => pr_cdcooper --> Cooperativa
                                      ,pr_nrdconta => pr_nrdconta --> Conta
                                      ,pr_nrcpfcgc => 0 --> Fixo - CPF/CGC
                                      ,pr_cdtipmov => 0 --> Fixo - Tipo do movimento
                                      ,pr_cdmodali => 2 --> Modalidade Aplicação
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data atual
                                      ,pr_vlbloque => vr_vlbloque --> Valor bloqueado
                                      ,pr_vlresblq => vr_vlresblq --> Valor que falta bloquear
                                      ,pr_dscritic => vr_dscritic); --> Erros encontrados no processo
      --Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
      -- Busca Saldo Bloqueado Judicial para Poupanças
      gene0005.pc_retorna_valor_blqjud(pr_cdcooper => pr_cdcooper --> Cooperativa
                                      ,pr_nrdconta => pr_nrdconta --> Conta
                                      ,pr_nrcpfcgc => 0 --> Fixo - CPF/CGC
                                      ,pr_cdtipmov => 0 --> Fixo - Tipo do movimento
                                      ,pr_cdmodali => 3 --> Modalidade Poupança
                                      ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data atual
                                      ,pr_vlbloque => vr_vlbloque_pp --> Valor bloqueado
                                      ,pr_vlresblq => vr_vlresblq --> Valor que falta bloquear
                                      ,pr_dscritic => vr_dscritic); --> Erros encontrados no processo
      
      --Se retornou erro
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
      
      -- Busca Bloqueio de Cobertura de Operação (Garantia)
      BLOQ0001.pc_calc_bloqueio_garantia(pr_cdcooper => pr_cdcooper
                                        ,pr_nrdconta => pr_nrdconta
                                        ,pr_vlbloque_aplica => vr_vlblqapl
                                        ,pr_vlbloque_poupa => vr_vlblqpou
                                        ,PR_DSCRITIC => VR_DSCRITIC);
      
      -- Se retornou critica
      IF vr_dscritic IS NOT NULL THEN
        -- Retornar com a critica
        vr_dscritic := 'Erro ao verificar bloqueios de garantia Conta ' || rw_crapass.nrdconta || '-->' || vr_dscritic;
        RAISE vr_exc_saida;
      END IF;
      
      vr_vlsldppr_aux := vr_vlsldppr;
      vr_vlsldapl_aux := vr_vlsldapl;
      
      vr_vlsldppr_aux := GREATEST(0, nvl(vr_vlsldppr_aux,0) - nvl(vr_vlbloque_pp,0));
      vr_vlsldapl_aux := GREATEST(0, nvl(vr_vlsldapl_aux,0) - nvl(vr_vlbloque,0));
      
      vr_vlsldppr_aux := GREATEST(NVL(vr_vlsldppr_aux,0) - NVL(vr_vlblqpou,0),0);
      vr_vlsldapl_aux := GREATEST(NVL(vr_vlsldapl_aux,0) - NVL(vr_vlblqapl,0),0);
    
      -- Enviar informações das aplicações para o JSON
      vr_obj_generic2.put('temPoupProgram',(nvl(vr_vlsldppr,0) > 0));
      vr_obj_generic2.put('temPoupProgamBloqueada',(vr_vlsldppr_aux <> vr_vlsldppr));
      vr_obj_generic2.put('saldoDisponPoupProgram',este0001.fn_decimal_ibra(vr_vlsldppr_aux));
      vr_obj_generic2.put('saldoTotalPoupProgram',este0001.fn_decimal_ibra(nvl(vr_vlsldppr,0)));
    
      -- Enviar informações das aplicações para o JSON
      vr_obj_generic2.put('temAplicacao', (nvl(vr_vlsldapl,0) > 0));
      vr_obj_generic2.put('temAplicacaoBloqueada', (vr_vlsldapl_aux <> vr_vlsldapl));
      vr_obj_generic2.put('saldoDisponAplicacao', este0001.fn_decimal_ibra(vr_vlsldapl_aux));
      vr_obj_generic2.put('saldoTotalAplicacao', este0001.fn_decimal_ibra(vr_vlsldapl));
    
      -- Selecionar informacoes % IR para o calculo da APLI0001.pc_calc_saldo_rpp
      vr_percenir:= GENE0002.fn_char_para_number
                          (TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                     ,pr_nmsistem => 'CRED'
                                                     ,pr_tptabela => 'CONFIG'
                                                     ,pr_cdempres => 0
                                                     ,pr_cdacesso => 'PERCIRAPLI'
                                                     ,pr_tpregist => 0));
    
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
                               ,pr_flgzerar => 'N' --> Nao zerar limite
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt --> Data da cooperativa
                               ,pr_flgprcrd => 1 --> considerar apenas limite titular
                                ------ OUT ------
                               ,pr_flgativo    => vr_flgativo --> Retorna situação 1-ativo 2-inativo
                               ,pr_nrctrhcj    => vr_nrctrhcj --> Retorna numero do contrato
                               ,pr_flgliber    => vr_flgliber --> Retorna se esta liberado 1-sim 2-nao
                               ,pr_vltotccr    => vr_vltotccr --> retorna total de limite do cartao 
                               ,pr_tab_cartoes => vr_tab_cartoes --> retorna temptable com os dados dos convenios
                               ,pr_des_reto    => vr_des_reto --> OK ou NOK
                               ,pr_tab_erro    => vr_tab_erro);
    
      -- Se houve retorno não Ok
      IF vr_des_reto = 'NOK' THEN
        -- Retornar a mensagem de erro
        vr_cdcritic := vr_tab_erro(vr_tab_erro.first).cdcritic;
        vr_dscritic := vr_tab_erro(vr_tab_erro.first).dscritic;
        -- Limpar tabela de erros
        vr_tab_erro.delete;
        RAISE vr_exc_saida;
      END IF;
    
      -- VArrer cartoes ate encontrar algum ativo
      IF vr_tab_cartoes.count > 0 THEN
        FOR vr_dx IN vr_tab_cartoes.first..vr_tab_cartoes.last LOOP
          IF vr_tab_cartoes(vr_dx).dssitcrd IN('Solic.','Liber.','Sol.2v','Prc.BB','Em uso','Sol.2v') THEN
            vr_flgativo := 1;
          END IF;
        END LOOP;
      END IF;
    
      -- Enviar flag de encontro e valor de Limite de Crédito
      vr_obj_generic2.put('temCartaoCredito'
                         ,(vr_flgativo > 0));
      
      -- ajustado para retornar o limite correto devido a erros na pc_lista_cartoes
      -- cartao segunda via, cartao adicional
      ccrd0001.pc_retorna_limite_conta (pr_cdcooper => pr_cdcooper
                                       ,pr_nrdconta => pr_nrdconta
                                       ,pr_vllimtot => vr_vltotccr);

      vr_obj_generic2.put('limiteCartaoCredito'
                         ,este0001.fn_decimal_ibra(vr_vltotccr));
    
      -- Buscar contrato de desconto cheques     
      OPEN cr_craplim_chq;
      FETCH cr_craplim_chq
        INTO rw_craplim_chq;
      CLOSE cr_craplim_chq;
      -- Buscar borderôs ativos
      OPEN cr_crapcdb(rw_crapdat.dtmvtolt);
      FETCH cr_crapcdb
        INTO rw_crapcdb;
      CLOSE cr_crapcdb;
    
      -- Enviar informações do contrato de Cheque
      vr_obj_generic2.put('dataContrDescCheq'
                         ,fn_Data_ibra_motor(rw_craplim_chq.dtinivig));
      vr_obj_generic2.put('limiteDescCheq'
                         ,este0001.fn_decimal_ibra(nvl(rw_craplim_chq.vllimite,0)));
      vr_obj_generic2.put('saldoUtilizDescCheq'
                         ,este0001.fn_decimal_ibra(nvl(rw_crapcdb.vlcheque,0)));
    
      -- Buscar contrato de desconto titulos     
      OPEN cr_craplim_tit;
      FETCH cr_craplim_tit
        INTO rw_craplim_tit;
      CLOSE cr_craplim_tit;
    
      -- Buscar borderôs ativos
      OPEN cr_craptdb(rw_crapdat.dtmvtolt);
      FETCH cr_craptdb
        INTO rw_craptdb;
      CLOSE cr_craptdb;
    
      -- Enviar informações do contrato de Cheque
      vr_obj_generic2.put('dataContrDescTitul'
                         ,fn_Data_ibra_motor(rw_craplim_tit.dtinivig));
      vr_obj_generic2.put('limiteDescTitul'
                         ,este0001.fn_decimal_ibra(nvl(rw_craplim_tit.vllimite,0)));
      vr_obj_generic2.put('saldoUtilizDescTitul'
                         ,este0001.fn_decimal_ibra(nvl(rw_craptdb.vltitulo,0)));
        
      -- Então chamaremos a rotina para busca do endividamento total 
      gene0005.pc_saldo_utiliza(pr_cdcooper    => pr_cdcooper
                               ,pr_tpdecons    => 3
                               ,pr_cdagenci    => 1
                               ,pr_nrdcaixa    => 1
                               ,pr_cdoperad    => 1
                               ,pr_nrdconta    => pr_nrdconta
                               ,pr_nrcpfcgc    => 0
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
      vr_obj_generic2.put('saldoDevedor', este0001.fn_decimal_ibra(vr_vlutiliz + vr_vltotccr));
    
      -- P637 – Motor de Crédito - Criar novos atributos para listar as operações de Empréstimo e Financiamento ativas  
      -- Buscar todos os contratos do Cooperado
      empr0001.pc_obtem_dados_empresti(pr_cdcooper       => pr_cdcooper --> Cooperativa conectada
                                      ,pr_cdagenci       => 1 --> Código da agência
                                      ,pr_nrdcaixa       => 1 --> Número do caixa
                                      ,pr_cdoperad       => '1' --> Código do operador
                                      ,pr_nmdatela       => 'EXTEMP' --> Nome datela conectada
                                      ,pr_idorigem       => 5 --> Indicador da origem da chamada
                                      ,pr_nrdconta       => pr_nrdconta --> Conta do associado
                                      ,pr_idseqttl       => 1 --> Sequencia de titularidade da conta
                                      ,pr_rw_crapdat     => rw_crapdat --> Vetor com dados de parâmetro (CRAPDAT)
                                      ,pr_dtcalcul       => NULL --> Data solicitada do calculo
                                      ,pr_nrctremp       => 0 --> Número contrato empréstimo
                                      ,pr_cdprogra       => 'ATENDA' --> Programa conectado
                                      ,pr_inusatab       => vr_inusatab --> Indicador de utilização da tabela de juros
                                      ,pr_flgerlog       => 'N' --> Gerar log S/N
                                      ,pr_flgcondc       => FALSE --> Mostrar emprestimos liq. s/ prejuizo
                                      ,pr_nmprimtl       => rw_crapass.nmprimtl --> Nome Primeiro Titular
                                      ,pr_tab_parempctl  => vr_dstextab_parempctl --> Dados tabela parametro
                                      ,pr_tab_digitaliza => vr_dstextab_digitaliza --> Dados tabela parametro
                                      ,pr_nriniseq       => 0 --> Numero inicial da paginacao
                                      ,pr_nrregist       => 0 --> Numero de registros por pagina
                                      ,pr_qtregist       => vr_qtregist --> Qtde total de registros
                                      ,pr_tab_dados_epr  => vr_tab_dados_epr --> Saida com os dados do empréstimo
                                      ,pr_des_reto       => vr_des_reto --> Retorno OK / NOK
                                      ,pr_tab_erro       => vr_tab_erro); --> Tabela com possíves erros
    
      IF vr_des_reto = 'NOK' THEN
        IF vr_tab_erro.exists(vr_tab_erro.first) THEN
          vr_dscritic := 'Conta: ' || pr_nrdconta ||
                         ' nao possui emprestimo.: ' || -- concatenar a causa de abortar o programa
                         vr_tab_erro(vr_tab_erro.first).dscritic;
        ELSE
          vr_dscritic := 'Conta: ' || pr_nrdconta ||
                         ' nao possui emprestimo.';
        END IF;
        RAISE vr_exc_saida;
      END IF;
			
      -- PJ637
      vr_lst_generic3 := json_list();
	  
      -- varrer temptable de emprestimos
      vr_idxempr := vr_tab_dados_epr.first;
      WHILE vr_idxempr IS NOT NULL LOOP

        -- Considerar contratos de empréstimo não liquidados, sem prejuízo 
        IF vr_tab_dados_epr(vr_idxempr).inliquid = 0 AND
           vr_tab_dados_epr(vr_idxempr).inprejuz = 0 THEN
          -- Criar objeto para a operação e enviar suas informações 
          vr_obj_generic3 := json();
          vr_obj_generic3.put('numContrato', vr_tab_dados_epr(vr_idxempr).nrctremp);
          vr_obj_generic3.put('dataContratacao', este0002.fn_data_ibra_motor(vr_tab_dados_epr(vr_idxempr).dtmvtolt));
          vr_obj_generic3.put('valorAberto', este0001.fn_decimal_ibra(vr_tab_dados_epr(vr_idxempr).vlsdeved)); --P637
          vr_obj_generic3.put('valorPrestacao', este0001.fn_decimal_ibra(vr_tab_dados_epr(vr_idxempr).vlpreemp)); --P637
      
          -- Adicionar Operação na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        END IF;
      
        -- Buscar o próximo
        vr_idxempr := vr_tab_dados_epr.next(vr_idxempr);
      END LOOP; -- Final temptable de emprestimos
      
      -- Adicionar o array de emprestimos no objeto informações adicionais
      vr_obj_generic2.put('opCredAberto', vr_lst_generic3);
     


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
                                     ,pr_dscritic           => vr_dscritic
                                     ,pr_cdcritic           => vr_cdcritic);
    
      -- Testar possíveis erros no retorno prevendo já o formato convertido… 
      IF NVL(vr_cdcritic, 0) > 0 OR TRIM(vr_dscritic) IS NOT NULL THEN
        RAISE vr_exc_saida;
      END IF;
    
      -- Loop para buscar todos os contratos em que o avalista é co-resposável 
      vr_ind_coresp := vr_tab_co_responsavel.first;
      WHILE vr_ind_coresp IS NOT NULL LOOP
      
        /* Se Saldo Devedor Maior que Zero */ 
        IF vr_tab_co_responsavel(vr_ind_coresp).vlsdeved > 0 THEN
      
          -- Se ha pagamento a pagar
          IF NVL(vr_tab_co_responsavel(vr_ind_coresp).vlpreapg,0)
           + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlmrapar,0)
           + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlmtapar,0)
           + NVL(vr_tab_co_responsavel(vr_ind_coresp).vliofcpl,0)  > 0 THEN
           -- Acumular atraso
            vr_tot_qtprecal := vr_tot_qtprecal + 1;
            vr_ava_vlsdeved := vr_ava_vlsdeved + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlpreapg,0)
                                               + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlmrapar,0)
                                               + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlmtapar,0)
                                               + NVL(vr_tab_co_responsavel(vr_ind_coresp).vliofcpl,0);
                                               
            -- Data do maior atraso.
            IF vr_dtdpagto_atr IS NULL THEN
              vr_dtdpagto_atr := vr_tab_co_responsavel(vr_ind_coresp).dtdpagto;
            ELSE
              IF vr_dtdpagto_atr > vr_tab_co_responsavel(vr_ind_coresp).dtdpagto THEN
                vr_dtdpagto_atr := vr_tab_co_responsavel(vr_ind_coresp).dtdpagto;
              END IF;
            END IF;
                                               
          END IF;
          /* Somar totais */
          vr_tot_vlsdeved := vr_tot_vlsdeved + NVL(vr_tab_co_responsavel(vr_ind_coresp).vlsdeved,0);

        END IF;
        
        -- Buscar próximo registro
        vr_ind_coresp := vr_tab_co_responsavel.next(vr_ind_coresp);
      END LOOP;
    
      -- Enfim, enviar as informações para o JSON (Neste ponto voltamos a trazer código PLSQL)
      vr_obj_generic2.put('coopAvalista'
                         ,(vr_tot_vlsdeved > 0));
      vr_obj_generic2.put('valorCoopAvalista'
                         ,este0001.fn_decimal_ibra(vr_tot_vlsdeved));
      vr_obj_generic2.put('coopAvalistaAtraso'
                         ,(vr_tot_qtprecal > 0));
      vr_obj_generic2.put('valorAvalistaAtraso'
                         ,este0001.fn_decimal_ibra(vr_ava_vlsdeved));
												 
      -- INÍCIO AVAIS CRUZADOS                   
      -- Buscar as contas avalizadas do proponente
      -- Diego Simas (AMcom)
      vr_lst_generic3 := json_list();
      
      -- Efetuar laço para trazer todos os registros
      FOR rw_crapavl_contas IN cr_crapavl_contas(pr_cdcooper, pr_nrdconta) LOOP
        -- Criar objeto para as contas avalizadas e enviar suas informações
        vr_obj_generic3 := json();
        vr_obj_generic3.put('contaAval', rw_crapavl_contas.conta);
        vr_obj_generic3.put('nomeAval', rw_crapavl_contas.nome);
        vr_documento := fn_mask_cpf_cnpj(pr_nrcpfcgc => rw_crapavl_contas.documento
                                        ,pr_inpessoa => rw_crapavl_contas.tipo_pessoa);
        vr_obj_generic3.put('documentoAval', vr_documento);
        vr_obj_generic3.put('contratoAval', rw_crapavl_contas.contrato);
        -- Adicionar contas avalizadas na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      END LOOP; -- Final da leitura das operações

      -- Adicionar o array contasAvalizadas no objeto informações adicionais
      vr_obj_generic2.put('contasAvalizadas', vr_lst_generic3);
      -- Diego Simas (AMcom) 
      -- FIM AVAIS CRUZADOS

			--Verificar se usa tabela juros
			vr_dstextab:= TABE0001.fn_busca_dstextab (pr_cdcooper => pr_cdcooper
																							 ,pr_nmsistem => 'CRED'
																							 ,pr_tptabela => 'USUARI'
																							 ,pr_cdempres => 11
																							 ,pr_cdacesso => 'TAXATABELA'
																							 ,pr_tpregist => 0);
			-- Se a primeira posição do campo
			-- dstextab for diferente de zero
			vr_inusatab:= SUBSTR(vr_dstextab,1,1) != '0';												 
    
      -- Leitura do indicador de uso da tabela de taxa de juros
      vr_dstextab_parempctl := tabe0001.fn_busca_dstextab(pr_cdcooper => 3
                                                         ,pr_nmsistem => 'CRED'
                                                         ,pr_tptabela => 'USUARI'
                                                         ,pr_cdempres => 11
                                                         ,pr_cdacesso => 'PAREMPCTL'
                                                         ,pr_tpregist => 01);    
    
    -- busca o tipo de documento GED
    vr_dstextab_digitaliza := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                                        ,pr_nmsistem => 'CRED'
                                                        ,pr_tptabela => 'GENERI'
                                                        ,pr_cdempres => 00
                                                        ,pr_cdacesso => 'DIGITALIZA'
                                                        ,pr_tpregist => 5);    
    
      -- Buscar todos os contratos do Cooperado
      empr0001.pc_obtem_dados_empresti(pr_cdcooper       => pr_cdcooper --> Cooperativa conectada
                                      ,pr_cdagenci       => 1 --> Código da agência
                                      ,pr_nrdcaixa       => 1 --> Número do caixa
                                      ,pr_cdoperad       => '1' --> Código do operador
                                      ,pr_nmdatela       => 'EXTEMP' --> Nome datela conectada
                                      ,pr_idorigem       => 5 --> Indicador da origem da chamada
                                      ,pr_nrdconta       => pr_nrdconta --> Conta do associado
                                      ,pr_idseqttl       => 1 --> Sequencia de titularidade da conta
                                      ,pr_rw_crapdat     => rw_crapdat --> Vetor com dados de parâmetro (CRAPDAT)
                                      ,pr_dtcalcul       => NULL --> Data solicitada do calculo
                                      ,pr_nrctremp       => 0 --> Número contrato empréstimo
                                      ,pr_cdprogra       => 'ATENDA' --> Programa conectado
                                      ,pr_inusatab       => vr_inusatab --> Indicador de utilização da tabela de juros
                                      ,pr_flgerlog       => 'N' --> Gerar log S/N
                                      ,pr_flgcondc       => FALSE --> Mostrar emprestimos liq. s/ prejuizo
                                      ,pr_nmprimtl       => rw_crapass.nmprimtl --> Nome Primeiro Titular
                                      ,pr_tab_parempctl  => vr_dstextab_parempctl --> Dados tabela parametro
                                      ,pr_tab_digitaliza => vr_dstextab_digitaliza --> Dados tabela parametro
                                      ,pr_nriniseq       => 0 --> Numero inicial da paginacao
                                      ,pr_nrregist       => 0 --> Numero de registros por pagina
                                      ,pr_qtregist       => vr_qtregist --> Qtde total de registros
                                      ,pr_tab_dados_epr  => vr_tab_dados_epr --> Saida com os dados do empréstimo
                                      ,pr_des_reto       => vr_des_reto --> Retorno OK / NOK
                                      ,pr_tab_erro       => vr_tab_erro); --> Tabela com possíves erros
    
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
			
			-- Buscar parâmetro da quantidade de meses para encontro do histórico de empréstimos
      IF nvl(pr_tpprodut,0) = 1 THEN -- desconto (tela PAREST)
        vr_qthisemp := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_EMPRES_DESC');
      ELSIF nvl(pr_tpprodut,0) = 4 THEN -- cartao (tela PAREST)
        vr_qthisemp := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_EMPRES_CRD');
      ELSE -- Emprestimo (tela PAREST)
        vr_qthisemp := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_EMPREST');
      END IF;
			
      -- Zerar variaveis auxiliares
      vr_nratrmai := 0;
      vr_vltotatr := 0;
      vr_qtpclven := 0;
      vr_qtpclatr := 0;
      vr_qtpclpag := 0;
      vr_tot_qtpclatr := 0;
      vr_tot_qtpclpag := 0;
      vr_maior_nratrmai := 0;

      -- Buscar a finalidade de PreAprovado
      vr_cdfinpre := empr0002.fn_finali_pre_aprovado(pr_cdcooper => pr_cdcooper, pr_inpessoa => rw_crapass.inpessoa);

      -- varrer temptable de emprestimos
      vr_idxempr := vr_tab_dados_epr.first;
      WHILE vr_idxempr IS NOT NULL LOOP

        -- Não considerar contratos de empréstimo que foram para prejuízo
        IF vr_tab_dados_epr(vr_idxempr).inprejuz = 1 THEN
          vr_idxempr := vr_tab_dados_epr.next(vr_idxempr);
          continue;
        END IF;
      
        -- Para aqueles com saldo devedor
        IF vr_tab_dados_epr(vr_idxempr).vlsdeved > 0 THEN
          -- Chamar calculo de dias em atraso
          pc_calc_dias_atraso(pr_cdcooper => pr_cdcooper  
                                      ,pr_nrdconta   => pr_nrdconta
                             ,pr_nrctremp => vr_tab_dados_epr(vr_idxempr).nrctremp  
                             ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                             ,pr_dtmvtoan => rw_crapdat.dtmvtoan
                             ,pr_dtmvtopr => rw_crapdat.dtmvtopr
                             ,pr_tpemprst => vr_tab_dados_epr(vr_idxempr).tpemprst   
                             ,pr_qtmesdec => vr_tab_dados_epr(vr_idxempr).qtmesdec   
                             ,pr_dtdpagto => vr_tab_dados_epr(vr_idxempr).dtdpagto   
                             ,pr_qtprecal => vr_tab_dados_epr(vr_idxempr).qtprecal   
                             ,pr_flgpagto => vr_tab_dados_epr(vr_idxempr).flgpagto   
                                      ,pr_qtdiaatr   => vr_dias
                                      ,pr_cdcritic   => vr_cdcritic
                                      ,pr_des_erro   => vr_dscritic);
          --Se ocorreu erro
          IF vr_dscritic IS NOT NULL OR vr_cdcritic IS NOT NULL THEN
            --Levantar Exceção
            RAISE vr_exc_saida;
          END IF;
        
          -- Se há atraso
          IF vr_dias > 0 THEN
            
            IF vr_dias > vr_maior_nratrmai THEN
              vr_maior_nratrmai := vr_dias;
            END IF;
            -- Acumular saldo em atraso
            vr_vltotatr := vr_vltotatr + vr_tab_dados_epr(vr_idxempr).vlpreapg
                                       + vr_tab_dados_epr(vr_idxempr).vlmrapar
                                       + vr_tab_dados_epr(vr_idxempr).vlmtapar
                                       + vr_tab_dados_epr(vr_idxempr).vliofcpl;
            -- Meses em atraso
            vr_qtpclven := vr_qtpclven + CEIL(vr_dias/30);                          
          END IF;
          
		  -- Caso o empréstimo seja de PreAprovado
          IF vr_tab_dados_epr(vr_idxempr).cdfinemp = vr_cdfinpre THEN
            vr_vlsldpre := vr_vlsldpre + vr_tab_dados_epr(vr_idxempr).vlsdeved;
          END IF;

        END IF;
      
        -- Calculo de Parcelas conforme tipo de empréstimo 
        IF vr_tab_dados_epr(vr_idxempr).tpemprst IN (1,2) THEN
          -- Para PP ou POS, buscaremos no cadastro de parcelas a quantidade de parcelas pagas em atraso
          OPEN cr_crappep_atraso(rw_crapdat.dtmvtolt
					                      ,vr_tab_dados_epr(vr_idxempr).nrctremp
																,vr_qthisemp);
          FETCH cr_crappep_atraso
            INTO vr_qtpclatr;
          CLOSE cr_crappep_atraso;
        
          -- Para as parcelas pagas também buscaremos no cadastro de parcelas           
          OPEN cr_crappep_pagtos(rw_crapdat.dtmvtolt
					                      ,vr_tab_dados_epr(vr_idxempr).nrctremp
																,vr_qthisemp);
          FETCH cr_crappep_pagtos
            INTO vr_qtpclpag;
          CLOSE cr_crappep_pagtos;
        
        ELSE
          -- Para TR, buscaremos nos lançamentos de pagtos a quantidade de lançamentos de Multa         
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
          -- Quantidade Parcelas paga é Valor Paga nos ultimos 6 meses / Valor da Parcela
          vr_qtpclpag := ROUND(vr_vlpclpag / vr_tab_dados_epr(vr_idxempr).vlpreemp);
        
          -- Descontar da quantidade paga a quantidade em atraso, pq mesmo tendo pago 
          -- proporcionalmente o valor total da parcela, se teve multa no mês significa
          -- que foi pago após o vencimento
          vr_qtpclpag := vr_qtpclpag - vr_qtpclatr;
        
          -- Garantir que não fique negativo, portanto se for negativo trará zero.
          vr_qtpclpag := greatest(0, vr_qtpclpag);
        
        END IF;
        
        -- TOtalizar
        vr_tot_qtpclatr :=  vr_tot_qtpclatr + vr_qtpclatr;
        vr_tot_qtpclpag :=  vr_tot_qtpclpag + vr_qtpclpag;
        
        -- Buscar o próximo
        vr_idxempr := vr_tab_dados_epr.next(vr_idxempr);
      END LOOP;

      -- Envio do total de saldo devedor de PreAprovado
      vr_obj_generic2.put('saldoDevedorPreAprovado', este0001.fn_decimal_ibra(nvl(vr_vlsldpre,0)));
      
      -- Busca maior atraso dentre os emprestimos do cooperado        
      OPEN cr_crapris(null, add_months(rw_crapdat.dtmvtolt,-vr_qthisemp));
      FETCH cr_crapris
        INTO vr_nratrmai;
      CLOSE cr_crapris;
      
      
      -- Enviar informações do atraso e parcelas calculadas para o JSON
      vr_obj_generic2.put('valorAtrasoEmprest'
                         ,este0001.fn_decimal_ibra(vr_vltotatr));
      vr_obj_generic2.put('quantDiasMaiorAtrasoEmprest', vr_nratrmai);
      
      vr_obj_generic2.put('quantParcelPagas', vr_tot_qtpclpag);
      vr_obj_generic2.put('quantParcelPagasAtraso', vr_tot_qtpclatr);
      vr_obj_generic2.put('quantParcelAtraso', vr_qtpclven);
      vr_obj_generic2.put('quantDiasAtrasoEmprest', vr_maior_nratrmai);
			 
      -- Data de Vigência Procuração
      IF pr_dtvigpro IS NOT NULL THEN 
        vr_obj_generic2.put('dataVigenciaProcuracao' ,fn_Data_ibra_motor(pr_dtvigpro));
      END IF;  

      -- Data de Admissão Procuração
      IF pr_dtadmsoc IS NOT NULL THEN 
        vr_obj_generic2.put('dataAdmissaoProcuracao' ,fn_Data_ibra_motor(pr_dtadmsoc));
      END IF;  
      
      -- Percentual Procuração
      IF pr_persocio IS NOT NULL THEN 
        vr_obj_generic2.put('valorPercentualProcuracao' ,Este0001.fn_Decimal_Ibra(pr_persocio));
      END IF;
      
      --AQUI ALTERACAO PF
      vr_obj_generic2.put('QtConta', vr_tot_qtpclatr);
      
      -- Montar objeto para seguro
      vr_lst_generic3 := json_list();
    
      -- Buscar todos os seguros da Conta do Cooperado 
      -- Efetuar laço para trazer todos os registros 
      FOR rw_crapseg IN cr_crapseg LOOP
            
        -- Criar objeto para a operação e enviar suas informações 
        vr_obj_generic3 := json();
        vr_obj_generic3.put('tipoSeguro', rw_crapseg.dstipo);
        vr_obj_generic3.put('valorApoliceSeguro'
                           ,este0001.fn_decimal_ibra(rw_crapseg.vlpremio));
        vr_obj_generic3.put('tipoPagtoSeguro ', 'Debito Automático');
      
        -- Adicionar Operação na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
      END LOOP; -- Final da leitura os seguros
    
      -- Adicionar o array seguro no objeto informações adicionais
      vr_obj_generic2.put('seguro', vr_lst_generic3);
			
      --Limpa variáveis SCR
      vr_cont_SCR := 0;
      vr_atrasoscr := FALSE;
      vr_prejscr := FALSE;

      -- Buscar as informações do Arquivo SCR
      FOR rw_crapopf IN cr_crapopf LOOP
        vr_cont_SCR := vr_cont_SCR + 1;

        -- Na sequencia buscar os valores dos vencimentos
        OPEN cr_crapvop(rw_crapass.nrcpfcgc);
        FETCH cr_crapvop
          INTO rw_crapvop;
        CLOSE cr_crapvop;

        IF rw_crapvop.vlopevnc > 0 THEN
           vr_atrasoscr := TRUE;
        END IF;

        IF rw_crapvop.vlopeprj > 0 THEN
          vr_prejscr := TRUE;
        END IF;

        IF vr_cont_SCR = 3 THEN
          EXIT;
        END IF;
      END LOOP;

      vr_obj_generic2.put('existeAtraso3BasesSCR',vr_atrasoscr);
      vr_obj_generic2.put('existePrej3BasesSCR',vr_prejscr);      
			
      -- Montar objeto para CheqDevol
      vr_lst_generic3 := json_list();
    
			-- Buscar parâmetro da quantidade de meses para busca dos Estouros/Adiantamentos
      IF nvl(pr_tpprodut,0) = 1 THEN -- desconto titulo (TELA PAREST)
        vr_qtmeschq := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_DEVCHQ_DESC');
        vr_qtmeschqal11 := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_DC_A11_DESC');
        vr_qtmeschqal12 := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_DC_A12_DESC');
      ELSIF nvl(pr_tpprodut,0) = 4 THEN -- cartao (TELA PAREST)
        vr_qtmeschq := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_DEVCHQ_CRD');        
        vr_qtmeschqal11 := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_DCH_A11_CRD');
        vr_qtmeschqal12 := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_DCH_A12_CRD');            
      ELSE -- emprestimo (TELA PAREST)
        vr_qtmeschq := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_DEV_CHEQUES');        
        vr_qtmeschqal11 := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_DEV_CH_AL11');
        vr_qtmeschqal12 := gene0001.fn_param_sistema('CRED',pr_cdcooper,'QTD_MES_HIST_DEV_CH_AL11');            
      END IF;
		
      -- Efetuar laço para trazer todos os registros 
      FOR rw_negchq IN cr_crapneg_cheq(vr_qtmeschq
				                              ,vr_qtmeschqal11
																			,vr_qtmeschqal12) LOOP
      
        -- Criar objeto para a operação e enviar suas informações 
        vr_obj_generic3 := json();
        vr_obj_generic3.put('dataCheqDevol'
                           ,fn_Data_ibra_motor(rw_negchq.dtiniest));
        vr_obj_generic3.put('valorCheqDevol'
                           ,este0001.fn_decimal_ibra(rw_negchq.vlestour));
        vr_obj_generic3.put('alineaCheqDevol', rw_negchq.cdobserv);
      
        -- Adicionar Operação na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
      END LOOP; -- Final da leitura das operações
    
      -- Adicionar o array CheqDevol no objeto informações adicionais
      vr_obj_generic2.put('cheqDevol', vr_lst_generic3);
						
      -- Montar objeto para OpCred
      vr_lst_generic3 := json_list();
		
      -- Lógica para retorno das ultimas operações de Crédito Liquidadas
      -- Primeiramente buscamos a quantidade de operações a serem enviadas 
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
        
      -- Montar objeto para scoreBehaviour
      vr_lst_generic3 := json_list();
    
      -- Buscar todos os seguros da Conta do Cooperado 
      -- Efetuar laço para trazer todos os registros 
      FOR rw_score IN cr_tbcrd_score(pr_cdcooper,pr_nrdconta) LOOP
        -- Desprezar 6º score adiante
        IF rw_score.nrseqreg > 6 THEN
          EXIT;
        END IF;
        -- Criar objeto para a operação e enviar suas informações 
        vr_obj_generic3 := json();
        vr_obj_generic3.put('cdModelo', rw_score.cdmodelo);
        vr_obj_generic3.put('dsModelo',rw_score.dsmodelo);
        vr_obj_generic3.put('dtBase ', to_char(rw_score.dtbase,'dd/mm/rrrr'));
        vr_obj_generic3.put('dsClasseScore', rw_score.dsclasse_score);
        vr_obj_generic3.put('nrScoreAlinhado', rw_score.nrscore_alinhado);
        vr_obj_generic3.put('dsExclusaoPrinc', rw_score.dsexclusao_principal);
        vr_obj_generic3.put('flSituacao ', rw_score.flvigente);
        -- Adicionar Score na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      END LOOP; -- Final da leitura os seguros
    
      -- Adicionar o array seguro no objeto informações adicionais
      vr_obj_generic2.put('scoreBehaviour', vr_lst_generic3);      

      -- Montar objeto para opCred
      vr_lst_generic3 := json_list();
    
      -- Efetuar laço para trazer todos os registros 
      FOR rw_crapepr IN cr_crapepr LOOP
      
        -- Verificar a quantidade de registros já lidos, pois não poderá passer da quantidade parametrizada
        IF vr_qtdopliq < cr_crapepr%rowcount THEN
          EXIT;
        END IF;
      
        -- Busca data da Liquidação        
        OPEN cr_dtliquid(rw_crapepr.nrctremp);
        FETCH cr_dtliquid
          INTO vr_dtliquid;
        CLOSE cr_dtliquid;
      
        -- Busca atraso
        OPEN cr_crapris(rw_crapepr.nrctremp, rw_crapepr.dtmvtolt);
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
        -- Criar objeto para a operação e enviar suas informações 
        vr_obj_generic3 := json();
        vr_obj_generic3.put('contratOpCred'
                           ,gene0002.fn_mask_contrato(rw_crapepr.nrctremp));
        vr_obj_generic3.put('dataContratOpCred', fn_Data_ibra_motor(rw_crapepr.dtmvtolt));													 
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
        vr_obj_generic3.put('liquidacaoOpCred', fn_Data_ibra_motor(vr_dtliquid));
        vr_obj_generic3.put('pontualidadeOpCred'
                           ,fn_des_pontualidade(vr_qtdiaatr));
        vr_obj_generic3.put('atrasoOpCred'
                           ,(nvl(vr_qtdiaatr,0) > 0));
        vr_obj_generic3.put('propostasLiquidOpCred', vr_flliquid);
      
        -- Adicionar Operação na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());
      
      END LOOP; -- Final da leitura das operações
    
      -- Adicionar o array OpCred no objeto informações adicionais
      vr_obj_generic2.put('opCred', vr_lst_generic3);
						
      -- INÍCIO AVAIS CRUZADOS
      -- Buscar a quantidade de contratos e o valor total
      -- das prestações de contratos ativos do avalista
      -- Diego Simas (AMcom)
      pc_resumo_aval(pr_cdcooper => pr_cdcooper   --Cooperativa
                    ,pr_nrdconta => pr_nrdconta   --Conta
                    ,pr_vltprava => vr_vltprava   --Valor total das prestações do aval
                    ,pr_qtconava => vr_qtconava   --Quantidade de contratos do aval
                    ,pr_cdcritic => vr_cdcritic   --Código da crítica
                    ,pr_dscritic => vr_dscritic   --Descrição da crítica
                    ,pr_nmdcampo => vr_nmdcampo   --Nome do campo de retorno
                    ,pr_des_erro => vr_des_erro); --Retorno OK;NOK

      IF vr_des_erro <> 'OK'      OR
         nvl(vr_cdcritic,0) <> 0  OR
           vr_dscritic IS NOT NULL  THEN
           RAISE vr_exc_erro;
      END IF;

      -- Cria informação totalPrestacoesAvalista
      vr_obj_generic2.put('totalPrestacoesAvalista'
                         ,este0001.fn_decimal_ibra(vr_vltprava));
      -- Cria informação qtdContratosAvalista
      vr_obj_generic2.put('qtdContratosAvalista'
                         ,vr_qtconava);
      
      -- Diego Simas (AMcom)
      -- FIM AVAIS CRUZADOS

       --Novos campos para Cartão de Crédito
      -- Verifica se é impossibilitado de negativação (CIN)
      OPEN cr_crapcyc( pr_cdcooper => pr_cdcooper,
                       pr_nrdconta => pr_nrdconta);
      FETCH cr_crapcyc INTO rw_crapcyc;

      -- se não possuir contrato de limite de credito, não precisa
      -- verificar a sda
      IF cr_crapcyc%NOTFOUND THEN
        CLOSE cr_crapcyc;
        vr_obj_generic2.put('cin', FALSE);
      ELSE
        CLOSE cr_crapcyc;
        vr_obj_generic2.put('cin', TRUE);
      END IF;

      --Busca dias de atraso do cartão
      OPEN cr_crdalat(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta);
      FETCH cr_crdalat INTO rw_crdalat ;

      IF cr_crdalat%NOTFOUND THEN
        CLOSE cr_crdalat;
        vr_obj_generic2.put('quantAtrasoCartaoCecred', 0);
      ELSE
        CLOSE cr_crdalat;
        vr_obj_generic2.put('quantAtrasoCartaoCecred', rw_crdalat.qtdias_atraso);
      END IF;

      --Parcela com maior atraso
      vr_obj_generic2.put('dataParcelaMaiorAtrasoAval', este0002.fn_data_ibra_motor(vr_dtdpagto_atr));

      --Busca informação cessão cartão
      OPEN cr_crapepr_cessao (pr_cdcooper => pr_cdcooper,
                              pr_nrdconta => pr_nrdconta);
      FETCH cr_crapepr_cessao INTO rw_crapepr_cessao;

      IF cr_crapepr_cessao%NOTFOUND THEN
        CLOSE cr_crapepr_cessao;
      ELSE
        CLOSE cr_crapepr_cessao;
        vr_obj_generic2.put('dataOpCessaoCredito', este0002.fn_data_ibra_motor(rw_crapepr_cessao.dtultcessao));
        vr_obj_generic2.put('existeCessaoAtiva', nvl(rw_crapepr_cessao.flgtemcessaoativa,0)=1);
      END IF;

      --Busca informação de Renegociação e Composição
      OPEN cr_rencomp(pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta,
                      pr_dtmovto  => vr_qthisemp);
      FETCH cr_rencomp INTO rw_rencomp;

      IF cr_rencomp%NOTFOUND THEN
        CLOSE cr_rencomp;
        vr_obj_generic2.put('teveComposicao',false);
        vr_obj_generic2.put('teveRenegociacao',false);
      ELSE
        CLOSE cr_rencomp;
        IF rw_rencomp.temrenegociacao = 1 then
          vr_obj_generic2.put('teveRenegociacao',true);
        ELSE
          vr_obj_generic2.put('teveRenegociacao',false);
        END IF;
        IF rw_rencomp.temcomposicao = 1 THEN
          vr_obj_generic2.put('teveComposicao',true);
        ELSE
          vr_obj_generic2.put('teveComposicao',false);
        END IF;
      END IF;

      -- Montar objeto para Negativação Cyber
      vr_lst_generic3 := json_list();

      -- Buscar todos os dados do SPC
      -- Efetuar laço para trazer todos os registros
      FOR rw_crapspc IN cr_crapspc(pr_dtinclus => vr_qthisemp) LOOP

        -- Criar objeto para a operação e enviar suas informações
        vr_obj_generic3 := json();
        vr_obj_generic3.put('numeroContrato',rw_crapspc.nrctremp);
        vr_obj_generic3.put('numeroContratoSPC',rw_crapspc.nrctrspc);
        vr_obj_generic3.put('dataVencimento',este0002.fn_data_ibra_motor(rw_crapspc.dtvencto));
        vr_obj_generic3.put('dataInclusao',este0002.fn_data_ibra_motor(rw_crapspc.dtinclus));
        vr_obj_generic3.put('dataBaixa',este0002.fn_data_ibra_motor(rw_crapspc.dtdbaixa));
        vr_obj_generic3.put('tpIdentificacao',rw_crapspc.tpidenti);
        vr_obj_generic3.put('cdOrigem',rw_crapspc.cdorigem);
        vr_obj_generic3.put('tpInstituicao',rw_crapspc.tpinsttu);
        vr_obj_generic3.put('vlDivida',este0001.fn_decimal_ibra(rw_crapspc.vldivida));

        -- Adicionar Operação na lista
        vr_lst_generic3.append(vr_obj_generic3.to_json_value());

      END LOOP; -- Final da leitura das negativações

      -- Adicionar o array seguro no objeto informações adicionais
      vr_obj_generic2.put('negativacaoCyber', vr_lst_generic3);


      -- Somente para Pessoa Fisica
      IF rw_crapass.inpessoa <> 1 THEN
			
        -- Montar objeto para faturamentos
        vr_lst_generic3 := json_list();
      
        -- Criar objeto para mês 01
        if rw_crapjfn.dtfatme1 <> '01000000' then
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,fn_Data_ibra_motor(to_date(rw_crapjfn.dtfatme1,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##1));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;

        if rw_crapjfn.dtfatme2 <> '01000000' then
          -- Criar objeto para mês 02
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,fn_Data_ibra_motor(to_date(rw_crapjfn.dtfatme2,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##2));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme3 <> '01000000' then        
          -- Criar objeto para mês 03
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,fn_Data_ibra_motor(to_date(rw_crapjfn.dtfatme3,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##3));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme4 <> '01000000' then
          -- Criar objeto para mês 04
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,fn_Data_ibra_motor(to_date(rw_crapjfn.dtfatme4,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##4));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme5 <> '01000000' then
          -- Criar objeto para mês 05
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,fn_Data_ibra_motor(to_date(rw_crapjfn.dtfatme5,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##5));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme6 <> '01000000' then
          -- Criar objeto para mês 06
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,fn_Data_ibra_motor(to_date(rw_crapjfn.dtfatme6,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##6));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;        
        
        if rw_crapjfn.dtfatme7 <> '01000000' then
          -- Criar objeto para mês 07
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,fn_Data_ibra_motor(to_date(rw_crapjfn.dtfatme7,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##7));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme8 <> '01000000' then
          -- Criar objeto para mês 08
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,fn_Data_ibra_motor(to_date(rw_crapjfn.dtfatme8,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##8));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme9 <> '01000000' then
          -- Criar objeto para mês 09
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,fn_Data_ibra_motor(to_date(rw_crapjfn.dtfatme9,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##9));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme10 <> '01000000' then        
          -- Criar objeto para mês 10
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,fn_Data_ibra_motor(to_date(rw_crapjfn.dtfatme10,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##10));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme11 <> '01000000' then
          -- Criar objeto para mês 11
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,fn_Data_ibra_motor(to_date(rw_crapjfn.dtfatme11,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##11));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;
        
        if rw_crapjfn.dtfatme12 <> '01000000' then
          -- Criar objeto para mês 12
          vr_obj_generic3 := json();
          vr_obj_generic3.put('dataFaturamentoMes'
                             ,fn_Data_ibra_motor(to_date(rw_crapjfn.dtfatme12,'ddmmrrrr')));
          vr_obj_generic3.put('valorFaturamentoMes'
                             ,este0001.fn_decimal_ibra(rw_crapjfn.vlrftbru##12));
          -- Adicionar Mês na lista
          vr_lst_generic3.append(vr_obj_generic3.to_json_value());
        end if;  
      
        -- Adicionar o array de faturamentos no objeto informações adicionais
        vr_obj_generic2.put('faturamentoMes', vr_lst_generic3);
						
			END IF;
			
      --so quando for proponente
      IF pr_inPropon THEN
        vr_obj_generic3 := json();
        -- Chamada das Novas variaveis internas para o Json
        rati0003.pc_json_variaveis_rating(pr_cdcooper => pr_cdcooper --> Código da cooperativa
                                         ,pr_nrdconta => pr_nrdconta --> Numero da conta do emprestimo
                                         ,pr_nrctremp => pr_nrctremp --> Numero do contrato de desconto de tidulo
                                         ,pr_flprepon => false   --> Flag Repon
                                         ,pr_vlsalari => 0       --> Valor do Salario Associado
                                         ,pr_persocio => 0       --> Percential do sócio
                                         ,pr_dtadmsoc => NULL    --> Data Admissãio do Sócio
                                         ,pr_dtvigpro => NULL    --> Data Vigência do Produto
                                         ,pr_tpprodut => 0       --> Tipo de Produto
                                         ,pr_dsjsonvar => vr_obj_generic3 --> Retorno Variáveis Json
                                         ,pr_cdcritic => vr_cdcritic  --> Código de critica encontrada
                                         ,pr_dscritic => vr_dscritic);

        -- Verifica inconsistencias
        if nvl(vr_cdcritic,0) > 0 or trim(vr_dscritic) is not null then
          RAISE vr_exc_erro;
        end if;

        -- Enviar informações das variáveis internas ao JSON
        vr_obj_generic2.put('variaveisInternas', vr_obj_generic3);
			END IF;
			
      -- Enviar informações adicionais ao JSON 
      vr_obj_generico.put('informacoesAdicionais', vr_obj_generic2);

      -- Ao final copiamos o json montado ao retornado
      pr_dsjsonan := vr_obj_generico;
    
    EXCEPTION
      WHEN vr_exc_saida THEN
        pr_cdcritic := vr_cdcritic;
        pr_dscritic := vr_dscritic;
      
      WHEN OTHERS THEN
        IF SQLCODE < 0 THEN
          -- Caso ocorra exception gerar o código do erro com a linha do erro
          vr_dscritic:= vr_dscritic ||
                        dbms_utility.format_error_backtrace;
                       
        END IF;  

        -- Montar a mensagem final do erro 
        vr_dscritic:= 'Erro na montagem dos dados para análise automática da proposta (1): ' ||
                       vr_dscritic || ' -- SQLERRM: ' || SQLERRM;
                       
        -- Remover as ASPAS que quebram o texto
        vr_dscritic:= replace(vr_dscritic,'"', '');
        vr_dscritic:= replace(vr_dscritic,'''','');
        -- Remover as quebras de linha
        vr_dscritic:= replace(vr_dscritic,chr(10),'');
        vr_dscritic:= replace(vr_dscritic,chr(13),'');
      
        pr_cdcritic := 0;
        pr_dscritic := vr_dscritic;
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
    
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    -- Busca a Nacionalidade
    CURSOR cr_crapnac(pr_cdnacion IN crapnac.cdnacion%TYPE) IS
      SELECT crapnac.dsnacion
        FROM crapnac
       WHERE crapnac.cdnacion = pr_cdnacion;
    
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_exc_erro EXCEPTION;

    -- Objeto json
    vr_obj_generico json := json();
    vr_obj_generic2 json := json();
    vr_lst_generic2 json_list := json_list(); 
    vr_inpessoa     crapass.inpessoa%TYPE;
    vr_stsnrcal     BOOLEAN;
    vr_dsnacion     crapnac.dsnacion%TYPE;
      
  BEGIN
    
    -- Validar o CPF/CNPJ para definir se é fisica ou jurídica 
    gene0005.pc_valida_cpf_cnpj(pr_nrcalcul => pr_rw_crapavt.nrcpfcgc
                               ,pr_stsnrcal => vr_stsnrcal
                               ,pr_inpessoa => vr_inpessoa);

    -- Enviaremos os dados básicos encontrados na tabela 
    vr_obj_generico.put('documento'      ,fn_mask_cpf_cnpj(NVL(pr_rw_crapavt.nrcpfcgc,0),vr_inpessoa));    
    
    -- Para Pessoas Fisicas 
    IF vr_inpessoa = 1 THEN 
    
      vr_obj_generico.put('tipoPessoa','FISICA');
      vr_obj_generico.put('nome'           ,pr_rw_crapavt.nmdavali);
       
      IF pr_rw_crapavt.cdsexcto = 1 THEN 
        vr_obj_generico.put('sexo' ,'MASCULINO');
      ELSIF pr_rw_crapavt.cdsexcto = 2 THEN 
        vr_obj_generico.put('sexo' ,'FEMININO');
      END IF;  

      vr_obj_generico.put('dataNascimento' ,fn_Data_ibra_motor(pr_rw_crapavt.dtnascto));
      
      -- Se o Documento for RG
      IF pr_rw_crapavt.tpdocava = 'CI' THEN
        vr_obj_generico.put('rg'  , pr_rw_crapavt.nrdocava);
        IF TRIM(pr_rw_crapavt.cdufddoc) IS NOT NULL THEN 
          vr_obj_generico.put('ufRg', pr_rw_crapavt.cdufddoc); 
        END IF;  
      END IF;
      
      IF TRIM(replace(pr_rw_crapavt.nmmaecto,'.','')) IS NOT NULL THEN
        vr_obj_generico.put('nomeMae'      ,pr_rw_crapavt.nmmaecto);
      END IF;  
      
      -- Busca a Nacionalidade
      vr_dsnacion := '';
      OPEN  cr_crapnac(pr_cdnacion => pr_rw_crapavt.cdnacion);
      FETCH cr_crapnac INTO vr_dsnacion;
      CLOSE cr_crapnac;
      
      vr_obj_generico.put('nacionalidade',vr_dsnacion);
      
      -- Montar objeto profissao       
      IF pr_rw_crapavt.dsproftl <> ' ' THEN 
        vr_obj_generic2 := json();
        vr_obj_generic2.put('titulo'   , pr_rw_crapavt.dsproftl);
        vr_obj_generic2.put('profissao', vr_obj_generico);
      END IF;     

    ELSE
      vr_obj_generico.put('tipoPessoa'  ,'JURIDICA');
      vr_obj_generico.put('razaoSocial' ,pr_rw_crapavt.nmdavali);
      vr_obj_generico.put('dataFundacao',fn_Data_ibra_motor(pr_rw_crapavt.dtnascto));
    END IF;
    
    -- Montar objeto Telefone para Telefone Residencial/Comercial      
    IF pr_rw_crapavt.nrfonres <> ' ' THEN 
      vr_lst_generic2 := json_list();
      -- Criar objeto só para este telefone
      vr_obj_generic2 := json();
      -- Montar Especie conforme tipo de Pessoa
      IF vr_inpessoa = 1 THEN
        vr_obj_generic2.put('especie', 'DOMICILIO'); 
      ELSE 
        vr_obj_generic2.put('especie', 'COMERCIAL'); 
      END IF;
      /*IF SUBSTR(pr_rw_crapavt.nrfonres,1,1) < 8 THEN 
        vr_obj_generic2.put('tipo', 'FIXO');
      ELSE
        vr_obj_generic2.put('tipo', 'MOVEL');
      END IF;*/
      vr_obj_generic2.put('numero', fn_somente_numeros_telefone(pr_rw_crapavt.nrfonres)); 
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
     
     -- Montar informações Adicionais
     vr_obj_generic2 := json();

     -- Caixa Postal
     IF pr_rw_crapavt.nrcxapst <> 0 THEN 
       vr_obj_generic2.put('caixaPostal', pr_rw_crapavt.nrcxapst);
     END IF;
     
     -- Somente para Pessoa Fisica
     IF vr_inpessoa = 1 THEN 
     
       -- Nome Pai
       IF pr_rw_crapavt.nmpaicto NOT IN(' ','.') THEN 
         vr_obj_generic2.put('nomePai', pr_rw_crapavt.nmpaicto);
       END IF;
       
       -- Estado Civil
       IF pr_rw_crapavt.cdestcvl <> 0 THEN 
         vr_obj_generic2.put('estadoCivil', pr_rw_crapavt.cdestcvl);
       END IF;
       
       -- Email
       vr_obj_generic2.put('email', pr_rw_crapavt.dsdemail);
       
       -- Naturalidade
       IF pr_rw_crapavt.dsnatura <> ' ' THEN 
         vr_obj_generic2.put('naturalidade', pr_rw_crapavt.dsnatura);
       END IF;

       -- Salario
       IF pr_rw_crapavt.vlrenmes <> 0 THEN 
         vr_obj_generic2.put('valorSalario', ESTE0001.fn_decimal_ibra(pr_rw_crapavt.vlrenmes));
       END IF;

       -- Outros Rendimentos
       IF pr_rw_crapavt. vloutren <> 0 THEN 
         vr_obj_generic2.put('valorOutrosRendim', ESTE0001.fn_decimal_ibra(pr_rw_crapavt.vloutren));
       END IF;

       -- Habilitação Menor
       IF pr_rw_crapavt.inhabmen > 0 THEN 
         vr_obj_generic2.put('reponsabiLegal', pr_rw_crapavt.inhabmen);
         
         -- Data Emancipação
         IF pr_rw_crapavt.dthabmen IS NOT NULL THEN 
           vr_obj_generic2.put('dataEmancipa' ,fn_Data_ibra_motor(pr_rw_crapavt.dthabmen));
         END IF;
       END IF;  
       
       -- Data de Vigência Procuração
       IF pr_rw_crapavt.dtvalida IS NOT NULL THEN 
         vr_obj_generic2.put('dataVigenciaProcuracao' ,fn_Data_ibra_motor(pr_rw_crapavt.dtvalida));
       END IF;  

       -- Data de Admissão Procuração
       IF pr_rw_crapavt.dtadmsoc IS NOT NULL THEN 
         vr_obj_generic2.put('dataAdmissaoProcuracao' ,fn_Data_ibra_motor(pr_rw_crapavt.dtadmsoc));
       END IF;  
       
       -- Percentual Procuração
       IF pr_rw_crapavt.persocio > 0 THEN 
         vr_obj_generic2.put('valorPercentualProcuracao' ,Este0001.fn_Decimal_Ibra(pr_rw_crapavt.persocio));
       END IF;

     ELSE
       -- Faturamento Annual – Rendimento MÊs + Outros * 12
       IF pr_rw_crapavt.vlrenmes + pr_rw_crapavt. vloutren <> 0 THEN 
         vr_obj_generic2.put('valorFaturamentoAnual', ESTE0001.fn_decimal_ibra((pr_rw_crapavt.vlrenmes +
                                                                                pr_rw_crapavt.vloutren)*12));
       END IF;
       
     END IF;
     
     -- Enviar informações adicionais ao JSON 
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
      Data     : Maio/2017.                   Ultima atualizacao: 12/04/2018
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina responsavel por montar o objeto json para analise.
    
      Alteração : 19/10/2017 - Enviar um novo campo "valorPrestLiquidacao". (Lombardi)
        
                  23/11/2017 - Alterações para o projeto 404. (Lombardi)
        
                  23/11/2017 - Alterações para o projeto 404. (Lombardi)
                  09/07/2018 - Inclusao de campos para projeto CDC.
                               PRJ439 - CDC(Odirlei-AMcom)
        
                  14/12/2018 - Adicionado o valor da parcela carencia (Rafael Faria - Supero)
                  10/07/2019 - P438 - Inclusão do atributo canalOrigem no Json para identificar 
                                a origem da operação de crédito no Motor. (Douglas Pagel / AMcom).

        
        
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
		
		-- Buscar última data de consulta ao bacen
		CURSOR cr_crapopf IS
	    SELECT max(opf.dtrefere) dtrefere
        FROM crapopf opf;
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
            ,wpr.tpemprst
            ,decode(wpr.tpemprst,1,'PP',2,'POS','TR') tpproduto
            ,lcr.tpctrato
            -- Indica que am linha de credito eh CDC ou C DC
            ,decode(fin.tpfinali,3,1,0) inlcrcdc
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
             ,DECODE(wpr.flgpagto,0,'CONTA','FOLHA') despagto
             ,lcr.txminima
             ,wpr.idcobope
             ,wpr.dtdpagto
             ,wpr.dtlibera
             ,wpr.dtcarenc
             ,wpr.percetop
             ,wpr.idcarenc
             ,wpr.dtmvtolt
             ,wpr.hrinclus
             ,lcr.perjurmo
             ,lcr.txmensal
             ,wpr.vlprecar	 
             ,wpr.cdorigem
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
      SELECT ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Buscar dados titular
    CURSOR cr_crapttl(pr_cdcooper crapass.cdcooper%type,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ttl.dtnasttl
            ,ttl.inhabmen
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = 1;                      
    rw_crapttl cr_crapttl%rowtype;
    
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
            ,org.cdorgao_expedidor dsorgemi
            ,crapcrl.cdufiden
            ,crapcrl.dtemiden
            ,crapcrl.dtnascin
            ,crapcrl.cddosexo
            ,crapcrl.cdestciv
            ,crapnac.dsnacion
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
        FROM crapcrl,
             crapnac,
             tbgen_orgao_expedidor org
       WHERE crapcrl.cdcooper = pr_cdcooper
         AND crapcrl.nrctamen = pr_nrdconta
         AND crapcrl.cdnacion = crapnac.cdnacion(+)
         AND crapcrl.idorgexp = org.idorgao_expedidor(+);
    
    -- Declarar cursor de participações societárias
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
    
    -- Buscar descrição
    CURSOR cr_nature (pr_natjurid gncdntj.cdnatjur%TYPE) IS
      SELECT gncdntj.dsnatjur
        FROM gncdntj
       WHERE gncdntj.cdnatjur = pr_natjurid;
    rw_nature cr_nature%ROWTYPE; 
    
    -- Buscar descrição
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
            ,greatest(crapbpr.nranobem,crapbpr.nrmodbem) nranobem
            ,crapbpr.nrcpfbem
        FROM crapbpr 
       WHERE crapbpr.cdcooper = pr_cdcooper
         AND crapbpr.nrdconta = pr_nrdconta
         AND crapbpr.nrctrpro = pr_nrctremp   
         AND crapbpr.tpctrpro = 90
         AND trim(crapbpr.dscatbem) is not NULL;
    
    -- Buscar Saldo de Cotas
    CURSOR cr_crapcot(pr_cdcooper crapass.cdcooper%type,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT vldcotas
        FROM crapcot
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    vr_vldcotas crapcot.vldcotas%TYPE;
    
    --> Buscar se a conta é de Colaborador Cecred
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
   
    --> Busca o percentual da cobertura de garantia    
    CURSOR cr_tabgar_cobertura(pr_idcob tbgar_cobertura_operacao.idcobertura%TYPE) IS
		  SELECT cob.perminimo 
        FROM tbgar_cobertura_operacao cob 
       WHERE cob.idcobertura = pr_idcob;       
		rw_tabgar_cobertura cr_tabgar_cobertura%ROWTYPE;
   
    CURSOR cr_crapepr (pr_cdcooper IN crapepr.cdcooper%TYPE
                      ,pr_nrdconta IN crapepr.nrdconta%TYPE
                      ,pr_nrctremp IN crapepr.nrctremp%TYPE) IS
      SELECT nvl(vlpreemp,0)
        FROM crapepr
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta
         AND nrctremp = pr_nrctremp;

    --Busca Patrimonio referencial da cooperativa 
    CURSOR cr_tbcadast_cooperativa(pr_cdcooper INTEGER) IS
      SELECT vlpatrimonio_referencial
        FROM tbcadast_cooperativa
       WHERE cdcooper = pr_cdcooper;
    rw_tbcadast_cooperativa cr_tbcadast_cooperativa%ROWTYPE;   	  
  
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
    vr_obj_generic4  json      := json(); -- Variáveis internas
    
    vr_flavalis      BOOLEAN := FALSE;
    vr_flrespvl      BOOLEAN := FALSE;
    vr_flsocios      BOOLEAN := FALSE;
    vr_flpartic      BOOLEAN := FALSE;
    vr_flprocura     BOOLEAN := FALSE;
    vr_flgbens       BOOLEAN := FALSE;
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
    vr_vlpreclc      NUMBER := 0;                -- Parcela calcula
    vr_valoriof      NUMBER;
    vr_vliofpri      NUMBER;
    vr_vliofadi      NUMBER;
    vr_flgimune      PLS_INTEGER;
    vr_vlcobert      NUMBER;
    vr_tab_split     gene0002.typ_split;
    vr_dsliquid      VARCHAR2(1000);
    vr_sum_vlpreemp  crapepr.vlpreemp%TYPE := 0;
    vr_vlpreemp      crapepr.vlpreemp%TYPE;
    vr_percenminimo  tbgar_cobertura_operacao.perminimo%TYPE;
    vr_qtdias_carencia tbepr_posfix_param_carencia.qtddias%TYPE := 0;
    vr_data_aux      DATE := NULL;
    vr_vlempfin      NUMBER;
    vr_prtlmult      NUMBER;
    vr_txdjuros      NUMBER;
    vr_vlpatref      tbcadast_cooperativa.vlpatrimonio_referencial%TYPE;

      
  BEGIN
  
    --Verificar se a data existe
    OPEN BTCH0001.cr_crapdat(pr_cdcooper => pr_cdcooper);
    FETCH BTCH0001.cr_crapdat INTO rw_crapdat;
    -- Se não encontrar
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
			-- Se não encontrar consideramos 168 horas (7 dias)
			vr_qtdiarpv := 168;
		END IF;
    CLOSE cr_craprbi;
		
		-- Buscar PA do operador
		OPEN cr_crapope;
		FETCH cr_crapope INTO vr_cdpactra;
    CLOSE cr_crapope;
		
		OPEN cr_crapopf;
		FETCH cr_crapopf INTO rw_crapopf;
    IF cr_crapopf%NOTFOUND THEN
      CLOSE cr_crapopf;
      vr_dscritic := 'Data Base Bacen-SCR nao encontrada!';
      RAISE vr_exc_erro;
    ELSE
    CLOSE cr_crapopf;
    END IF;
		
		-- Montar os atributos de 'configuracoes'
		vr_obj_generico := json();
		vr_obj_generico.put('centroCusto', vr_cdpactra);
    vr_obj_generico.put('dataBaseBacen', to_char(rw_crapopf.dtrefere,'RRRRMM'));
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
    
    vr_data_aux := to_date(to_char(rw_crawepr.dtmvtolt,'DD/MM/RRRR') ||' '||
                           to_char(to_date(rw_crawepr.hrinclus,'SSSSS'),'HH24:MI:SS'),
                           'DD/MM/RRRR HH24:MI:SS');    
    vr_obj_generico.put('dataProposta', fn_DataTempo_ibra(vr_data_aux));
    vr_obj_generico.put('cooperativa', pr_cdcooper); 
    vr_obj_generico.put('agenci', pr_cdagenci);

    /* 0 – CDC Diversos
       1 – CDC Veículos 
       2 – Empréstimos /Financiamentos 
       3 – Desconto Cheques 
       4 – Desconto Títulos 
       5 – Cartão de Crédito 
       6 – Limite de Crédito
       9 – Consignado
       10 - Rating
	   12 - Limite de Pré-aprovado */
    -- Se for CDC
    IF rw_crawepr.cdfinemp = 58 and rw_crawepr.inlcrcdc = 1 THEN
      vr_obj_generico.put('segmentoCodigo'    ,0); 
      vr_obj_generico.put('segmentoDescricao' ,'CDC Diversos');  
    ELSIF rw_crawepr.cdfinemp = 59 and rw_crawepr.inlcrcdc = 1 THEN
      vr_obj_generico.put('segmentoCodigo'    ,1); 
      vr_obj_generico.put('segmentoDescricao' ,'CDC Veiculos');
    ELSE

      vr_obj_generico.put('segmentoCodigo' ,2); -- Emprestimos/Financiamento 
      vr_obj_generico.put('segmentoDescricao' ,'Emprestimos/Financiamento');   
    END IF;

      vr_obj_generico.put('linhaCreditoCodigo'    ,rw_crawepr.cdlcremp);
      vr_obj_generico.put('linhaCreditoDescricao' ,rw_crawepr.dslcremp);
      vr_obj_generico.put('finalidadeCodigo'      ,rw_crawepr.cdfinemp);       
      vr_obj_generico.put('finalidadeDescricao'   ,rw_crawepr.dsfinemp);                
    
    vr_obj_generico.put('tipoProduto'           ,rw_crawepr.tpproduto);
    vr_obj_generico.put('tipoGarantiaCodigo'    ,rw_crawepr.tpctrato );
    
    --> Buscar descrição do tipo de garantia
    vr_dstpgara  := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                               pr_nmsistem => 'CRED',
                                               pr_tptabela => 'GENERI', 
                                               pr_cdempres => 0, 
                                               pr_cdacesso => 'CTRATOEMPR', 
                                               pr_tpregist => rw_crawepr.tpctrato);    
                                               
    vr_obj_generico.put('tipoGarantiaDescricao'    ,TRIM(vr_dstpgara) );

    vr_obj_generico.put('debitoEm'    ,rw_crawepr.despagto );
    vr_obj_generico.put('liquidacao'  ,rw_crawepr.dsliquid!='0,0,0,0,0,0,0,0,0,0');

    vr_obj_generico.put('valorTaxaMensal', ESTE0001.fn_decimal_ibra(rw_crawepr.txminima));

    vr_obj_generico.put('valorEmprest'  , ESTE0001.fn_decimal_ibra(rw_crawepr.vlemprst));
    vr_obj_generico.put('quantParcela'  , rw_crawepr.qtpreemp);
    vr_obj_generico.put('primeiroVencto', fn_Data_ibra_motor(rw_crawepr.dtvencto));
    vr_obj_generico.put('valorParcela'  , ESTE0001.fn_decimal_ibra(rw_crawepr.vlpreemp));
    vr_obj_generico.put('valorParcelaCarencia'  , ESTE0001.fn_decimal_ibra(nvl(rw_crawepr.vlprecar,0)));

    vr_obj_generico.put('renegociacao', nvl(rw_crawepr.flgreneg,0) = 1);

    --> Rotina para calcular valor total financiado
    pc_ret_valor_financiado ( pr_cdcooper   => pr_cdcooper     --> Codigo da cooperativa
                             ,pr_nrdconta   => pr_nrdconta     --> Codigo da cooperativa
                             ,pr_nrctremp   => pr_nrctremp     --> Codigo da cooperativa
                              ---- OUT ----
                             ,pr_vlfinanc   => vr_vlempfin     --> Retornar valor financiado 
                             ,pr_cdcritic   => vr_cdcritic     --> Codigo da critica
                             ,pr_dscritic   => vr_dscritic );  --> Descricao da critica
    IF nvl(vr_cdcritic,0) > 0 OR
       vr_dscritic IS NOT NULL THEN
      RAISE vr_exc_erro; 
    END IF;   
    vr_obj_generico.put('valorEmprestFinanciado'  , ESTE0001.fn_decimal_ibra(vr_vlempfin)); 

    vr_obj_generico.put('qualificaOperacaoCodigo',rw_crawepr.idquapro );

    CASE rw_crawepr.idquapro
      WHEN 1 THEN vr_dsquapro := 'Operacao normal';
      WHEN 2 THEN vr_dsquapro := 'Renovacao de credito';
      WHEN 3 THEN vr_dsquapro := 'Renegociacao de credito';
      WHEN 4 THEN vr_dsquapro := 'Composicao da divida';
      ELSE vr_dsquapro := ' ';
    END CASE;

    vr_obj_generico.put('qualificaOperacaoDescricao'    ,vr_dsquapro );
         
    IF rw_crawepr.inpessoa = 1 THEN 
      -- Verificar se a conta é de colaborador do sistema Cecred
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
    
    -- Efetuar laço para trazer todos os registros 
    FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_nrctremp => pr_nrctremp )  LOOP 

      -- Indicar que encontrou
      vr_flgbens := TRUE;
      -- Para cada registro de Bem, criar objeto para a operação e enviar suas informações 
			vr_lst_generic2 := json_list();
      vr_obj_generic2 := json();
      vr_obj_generic2.put('categoriaBem',     rw_crapbpr.dscatbem);
      vr_obj_generic2.put('anoGarantia',      rw_crapbpr.nranobem);
      vr_obj_generic2.put('valorGarantia',    ESTE0001.fn_decimal_ibra(rw_crapbpr.vlmerbem));
      vr_obj_generic2.put('bemInterveniente', rw_crapbpr.nrcpfbem <> 0);

      -- Adicionar Bem na lista
      vr_lst_generic2.append(vr_obj_generic2.to_json_value());
  
    END LOOP; -- Final da leitura dos Bens

    IF rw_crawepr.idcobope > 0 THEN
      -- Busca valor de cobertura da operação
      vr_vlcobert := BLOQ0001.fn_valor_bloqueio_garantia_in(pr_idcobert => rw_crawepr.idcobope);
                               
      -- Se houver valor em cobertura
      IF vr_vlcobert > 0 THEN
         -- Busca o percentual minimo de cobertura
         OPEN cr_tabgar_cobertura(rw_crawepr.idcobope);
			   FETCH cr_tabgar_cobertura INTO vr_percenminimo;
			   CLOSE cr_tabgar_cobertura;
         
        -- idenpendente da linha e se o percentual minimo de cobertura é maior que 100%        
        IF vr_percenminimo > 100 THEN
        -- Indicar que encontrou
        vr_flgbens := TRUE;
        -- Enviar valor bloqueado de Cobertura
        vr_obj_generic2 := json();
           vr_obj_generic2.put('categoriaBem', 'APLICACAO FINANCEIRA'); --GARANTIA APLICACAO FINANCEIRA ACIMA 100%
        vr_obj_generic2.put('valorGarantia', ESTE0001.fn_decimal_ibra(vr_vlcobert));
        -- Adicionar Bem na lista
        vr_lst_generic2.append(vr_obj_generic2.to_json_value());
        ELSE
          -- se nao for linha especifica           
          -- se percentual mininmo for igual a 100% considera GARANTIA APLICACAO FINANCEIRA ATE 100
          IF (rw_crawepr.tpctrato <> 4 AND vr_percenminimo = 100) OR (rw_crawepr.tpctrato = 4 AND vr_percenminimo <= 100) THEN            
            -- Indicar que encontrou
            vr_flgbens := TRUE;
            -- Enviar valor bloqueado de Cobertura
            vr_obj_generic2 := json();
            vr_obj_generic2.put('categoriaBem', 'APLICACAO FINANCEIRA'); --GARANTIA APLICACAO FINANCEIRA ATE 100%
            vr_obj_generic2.put('valorGarantia', ESTE0001.fn_decimal_ibra(vr_vlcobert));
            -- Adicionar Bem na lista
            vr_lst_generic2.append(vr_obj_generic2.to_json_value());
          END IF;          
          -- se percentual for menor que 100%, segue regra padrão do sistema
        END IF;
      END IF;
    END IF;
    
    -- Adicionar o array bemEmGarantia
    IF vr_flgbens THEN
      vr_obj_generico.put('bemEmGarantia', vr_lst_generic2);
    ELSE
      -- Verificar se o valor das Cotas é Superior ao da Proposta
      OPEN cr_crapcot(pr_cdcooper
                     ,pr_nrdconta);
      FETCH cr_crapcot
       INTO vr_vldcotas;
      CLOSE cr_crapcot;
      -- Se valor das cotas é superior ao da proposta
      IF NVL(vr_vldcotas,0) > rw_crawepr.vlemprst THEN 
        -- Adicionar as cotas  
        vr_lst_generic2 := json_list();
        vr_obj_generic2 := json();
        vr_obj_generic2.put('categoriaBem','COTAS CAPITAL');
        vr_obj_generic2.put('anoGarantia',0);
        vr_obj_generic2.put('valorGarantia',ESTE0001.fn_decimal_ibra(vr_vldcotas));
        vr_obj_generic2.put('bemInterveniente',false);
        -- Adicionar Bem na lista
        vr_lst_generic2.append(vr_obj_generic2.to_json_value());
        -- Adicionar as cotas como garantia
        vr_obj_generico.put('bemEmGarantia', vr_lst_generic2);
      END IF;
    END IF;  

    -- Busca quantidade de dias da carencia
    IF rw_crawepr.tpemprst = 2 AND nvl(rw_crawepr.idcarenc,0) > 0 THEN
      EMPR0011.pc_busca_qtd_dias_carencia(pr_idcarencia => rw_crawepr.idcarenc
                                         ,pr_qtddias    => vr_qtdias_carencia
                                         ,pr_cdcritic   => vr_cdcritic
                                         ,pr_dscritic   => vr_dscritic); 
      -- Testar possíveis erros na rotina:
      IF vr_cdcritic > 0 OR trim(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro;
      END IF;                                          
    END IF;
    
    -- Buscar IOF
    TIOF0001.pc_calcula_iof_epr(pr_cdcooper => pr_cdcooper
                               ,pr_nrdconta => pr_nrdconta
                               ,pr_dtmvtolt => rw_crapdat.dtmvtolt
                               ,pr_inpessoa => rw_crawepr.inpessoa
                               ,pr_cdlcremp => rw_crawepr.cdlcremp
                               ,pr_cdfinemp => rw_crawepr.cdfinemp
                               ,pr_qtpreemp => rw_crawepr.qtpreemp
                               ,pr_vlpreemp => rw_crawepr.vlpreemp
                               ,pr_vlemprst => rw_crawepr.vlemprst
                               ,pr_dtdpagto => rw_crawepr.dtdpagto
                               ,pr_dtlibera => rw_crawepr.dtlibera
                               ,pr_tpemprst => rw_crawepr.tpemprst
                               ,pr_dtcarenc => rw_crawepr.dtcarenc
                               ,pr_qtdias_carencia => vr_qtdias_carencia
                               ,pr_dsctrliq => rw_crawepr.dsliquid
                               ,pr_idgravar => 'N'
                               ,pr_vlpreclc => vr_vlpreclc
                               ,pr_valoriof => vr_valoriof
                               ,pr_vliofpri => vr_vliofpri
                               ,pr_vliofadi => vr_vliofadi
                               ,pr_flgimune => vr_flgimune
                               ,pr_dscritic => vr_dscritic);
    -- Testar possíveis erros na rotina:
    IF trim(vr_dscritic) IS NOT NULL THEN 
      RAISE vr_exc_erro;
    END IF;    
       

    vr_obj_generico.put('operacao', rw_crawepr.dsoperac); 
    vr_obj_generico.put('CETValor', este0001.fn_decimal_ibra(nvl(rw_crawepr.percetop,0)));
    vr_obj_generico.put('IOFValor', este0001.fn_decimal_ibra(nvl(vr_valoriof,0)));
    vr_obj_generico.put('IOFPrincipal', este0001.fn_decimal_ibra(nvl(vr_vliofpri,0)));
    vr_obj_generico.put('IOFAdicional', este0001.fn_decimal_ibra(nvl(vr_vliofadi,0)));
    vr_obj_generico.put('flgimune', nvl(vr_flgimune,0));
    
    
    IF rw_crawepr.dsliquid <> '0,0,0,0,0,0,0,0,0,0' THEN
      vr_tab_split := gene0002.fn_quebra_string(rw_crawepr.dsliquid, ',');
      
      vr_dsliquid := vr_tab_split.FIRST;
          
      vr_sum_vlpreemp := 0;
      
      WHILE vr_dsliquid IS NOT NULL LOOP
        
        IF vr_tab_split(vr_dsliquid) <> '0' THEN
          
          OPEN cr_crapepr (pr_cdcooper => pr_cdcooper
                          ,pr_nrdconta => pr_nrdconta
                          ,pr_nrctremp => vr_tab_split(vr_dsliquid));
          FETCH cr_crapepr INTO vr_vlpreemp;
          CLOSE cr_crapepr;
          vr_sum_vlpreemp := vr_sum_vlpreemp + vr_vlpreemp;
          
        END IF;
        vr_dsliquid := vr_tab_split.NEXT(vr_dsliquid);    
      END LOOP;
    END IF;
    
    vr_obj_generico.put('valorPrestLiquidacao', ESTE0001.fn_decimal_ibra(vr_sum_vlpreemp));
    
    --> Incluir campos adicionais
    -- Taxa anual
    vr_txdjuros := ROUND((POWER(1 + (nvl(rw_crawepr.txmensal,0) / 100),12) - 1) * 100,2);
    vr_obj_generico.put('valorTaxaAno', ESTE0001.fn_decimal_ibra(vr_txdjuros)); 
    
    vr_obj_generico.put('valorTaxaMoratoria', ESTE0001.fn_decimal_ibra(rw_crawepr.perjurmo));
    
    vr_obj_generico.put('valorMulta', ESTE0001.fn_decimal_ibra(2)); --> fixo 2% 
    
    -- Buscar dados da TAB
    vr_dstextab := TABE0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper
                                             ,pr_nmsistem => 'CRED'
                                             ,pr_tptabela => 'USUARI'
                                             ,pr_cdempres => 11
                                             ,pr_cdacesso => 'PAREMPREST'
                                             ,pr_tpregist => 01);

    --Se encontrou parametro, atribui valor. Caso contrario, mantem Zero 
    IF TRIM(vr_dstextab) IS NOT NULL THEN      
      vr_prtlmult := gene0002.fn_char_para_number(SUBSTR(vr_dstextab,1,3));      
    END IF;    
    vr_dstextab := null;
    
    vr_obj_generico.put('toleranciaJurosMoraMulta', ESTE0001.fn_decimal_ibra(vr_prtlmult));

    vr_obj_generico.put('canalOrigem',rw_crawepr.cdorigem);        
        
    -- Buscar Patrimonio referencial da cooperativa 
    OPEN cr_tbcadast_cooperativa(pr_cdcooper);
    FETCH cr_tbcadast_cooperativa 
     INTO vr_vlpatref;
     
    IF cr_tbcadast_cooperativa%NOTFOUND THEN
      vr_vlpatref := 0;
    END IF;
    CLOSE cr_tbcadast_cooperativa;    
    -- Incluir Patrimonio referencial da cooperativa
    vr_obj_generico.put('valorPatrimonioReferencial',ESTE0001.fn_decimal_ibra(vr_vlpatref));
    
    vr_obj_analise.put('indicadoresCliente', vr_obj_generico);         
    
    pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctremp
                           ,pr_flprepon => true
                           ,pr_inPropon => true  --Gerar VariaveisInternas para proponente
                           ,pr_dsjsonan => vr_obj_generico
                           ,pr_cdcritic => vr_cdcritic 
                           ,pr_dscritic => vr_dscritic);
                           
     -- Testar possíveis erros na rotina:
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
     
      -- Se não encontrar 
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
                                 ,pr_vlsalari => rw_crapcje.vlsalari
                                 ,pr_dsjsonan => vr_obj_conjuge
                                 ,pr_cdcritic => vr_cdcritic 
                                 ,pr_dscritic => vr_dscritic);

          -- Testar possíveis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF; 
            
          -- Adicionar o JSON montado do Proponente no objeto principal
          vr_obj_analise.put('conjuge',vr_obj_conjuge);

        ELSE
          -- Enviaremos os dados básicos encontrados na tabela de conjugue
          vr_obj_conjuge.put('documento'      ,fn_mask_cpf_cnpj(NVL(rw_crapcje.nrcpfcjg,0),1));
          vr_obj_conjuge.put('tipoPessoa'     ,'FISICA');
          vr_obj_conjuge.put('nome'           ,rw_crapcje.nmconjug);
          
          vr_obj_conjuge.put('dataNascimento' ,fn_Data_ibra_motor(rw_crapcje.dtnasccj));
          
          -- Se o Documento for RG
          IF rw_crapcje.tpdoccje = 'CI' THEN
            vr_obj_conjuge.put('rg', rw_crapcje.nrdoccje);
            vr_obj_conjuge.put('ufRg', rw_crapcje.cdufdcje);
          END IF;
          
          -- Montar objeto Telefone para Telefone Comercial      
          IF rw_crapcje.nrfonemp <> ' ' THEN 
            vr_lst_generic2 := json_list();
            -- Criar objeto só para este telefone
            vr_obj_generico := json();
            vr_obj_generico.put('especie', 'COMERCIAL');
            /*
            IF SUBSTR(rw_crapcje.nrfonemp,1,1) < 8 THEN 
              vr_obj_generico.put('tipo', 'FIXO');
            ELSE
              vr_obj_generico.put('tipo', 'MOVEL');
            END IF;
			*/
            
            vr_obj_generico.put('numero', fn_somente_numeros_telefone(rw_crapcje.nrfonemp));
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
          
          -- Montar informações Adicionais
          vr_obj_generico := json();
          -- Escolaridade
          IF rw_crapcje.grescola <> 0 THEN 
            vr_obj_generico.put('escolaridade', rw_crapcje.grescola);
          END IF;
          -- Curso Superior
          IF rw_crapcje.cdfrmttl <> 0 THEN 
            vr_obj_generico.put('cursoSuperiorCodigo'
                               ,rw_crapcje.cdfrmttl);
            vr_obj_generico.put('cursoSuperiorDescricao'
                               ,fn_des_cdfrmttl(rw_crapcje.cdfrmttl));
          END IF;
          -- Natureza Ocupação
          IF rw_crapcje.cdnatopc <> 0 THEN 
            vr_obj_generico.put('naturezaOcupacao', rw_crapcje.cdnatopc);
          END IF;
          -- Ocupação
          IF rw_crapcje.cdocpcje <> 0 THEN 
            vr_obj_generico.put('ocupacaoCodigo'
                               ,rw_crapcje.cdocpcje);
            vr_obj_generico.put('ocupacaoDescricao'
                               ,fn_des_cdocupa(rw_crapcje.cdocpcje));
          END IF;
          -- Tipo Contrato de Trabalho
          IF rw_crapcje.tpcttrab <> 0 THEN 
            vr_obj_generico.put('tipoContratoTrabalho', rw_crapcje.tpcttrab);
          END IF;
          -- Nivel Cargo
          IF rw_crapcje.cdnvlcgo <> 0 THEN 
            vr_obj_generico.put('nivelCargo', rw_crapcje.cdnvlcgo);
          END IF;
          -- Turno
          IF rw_crapcje.cdturnos <> 0 THEN 
            vr_obj_generico.put('turno', rw_crapcje.cdturnos);
          END IF;
          -- Data Admissão
          IF rw_crapcje.dtadmemp IS NOT NULL THEN 
            vr_obj_generico.put('dataAdmissao', fn_Data_ibra_motor(rw_crapcje.dtadmemp));
          END IF;
          -- Salario
          IF rw_crapcje.vlsalari <> 0 THEN 
            vr_obj_generico.put('valorSalario', ESTE0001.fn_decimal_ibra(rw_crapcje.vlsalari));
          END IF;
          -- CNPJ Empresa
          IF rw_crapcje.nrdocnpj <> 0 THEN 
            vr_obj_generico.put('codCNPJEmpresa', rw_crapcje.nrdocnpj);
          END IF;

          -- Enviar informações adicionais ao JSON Conjuge
          -- tratamento para nao enviar JSON como LISTA quando executado no PHP junto a funcao JSON_DECODE
          IF json_ac.object_count(vr_obj_generico) > 0 THEN
          vr_obj_conjuge.put('informacoesAdicionais' ,vr_obj_generico);        
          END IF;
              
          -- Ao final adicionamos o json montado ao principal
          vr_obj_analise.put('conjuge' ,vr_obj_conjuge);        
        END IF; 
        
      END IF;  
      
    END IF;
    
    --> BUSCAR AVALISTAS INTERNOS E EXTERNOS: 
    -- Inicializar lista de Avalistas
    vr_lst_generico := json_list();
 
    -- Enviar avalista 01 em novo json só para avalistas
    IF nvl(pr_nrctaav1,0) <> 0 THEN
      -- Setar flag para indicar que há avalista
      vr_flavalis := true;
      
      pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrctaav1
                             ,pr_nrctremp => pr_nrctremp
                             ,pr_dsjsonan => vr_obj_avalista
                             ,pr_cdcritic => vr_cdcritic 
                             ,pr_dscritic => vr_dscritic);

      -- Testar possíveis erros na rotina:
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro;
      END IF;

      -- Adicionar o avalista montato na lista de avalistas
      vr_lst_generico.append(vr_obj_avalista.to_json_value());

    END IF;
    
    -- Enviar avalista 02 em novo json só para avalistas
    IF nvl(pr_nrctaav2,0) <> 0 THEN
      -- Setar flag para indicar que há avalista
      vr_flavalis := true;
      
      pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrctaav2
                             ,pr_nrctremp => pr_nrctremp
                             ,pr_dsjsonan => vr_obj_avalista
                             ,pr_cdcritic => vr_cdcritic 
                             ,pr_dscritic => vr_dscritic);

      -- Testar possíveis erros na rotina:
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro;
      END IF;

      -- Adicionar o avalista montato na lista de avalistas
      vr_lst_generico.append(vr_obj_avalista.to_json_value());

    END IF;
    
    --> Efetuar laço para retornar todos os registros disponíveis:
    FOR rw_crapavt IN cr_crapavt( pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta 
                                 ,pr_nrctremp => pr_nrctremp
                                 ,pr_tpctrato => 1
                                 ,pr_dsproftl => null) LOOP
                                 
      -- Setar flag para indicar que há avalista
      vr_flavalis := true;
      -- Enviaremos os dados básicos encontrados na tabela de avalistas terceiros 
      pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                             ,pr_dsjsonavt  => vr_obj_avalista
                             ,pr_cdcritic   => vr_cdcritic 
                             ,pr_dscritic   => vr_dscritic);
      -- Testar possíveis erros na rotina:
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
  
    --> Para pessoa física verificaremos necessidade de envio dos responsáveis legais:
    IF rw_crapass.inpessoa = 1 THEN 
      
       -- Buscar dados titular
       OPEN cr_crapttl(pr_cdcooper,pr_nrdconta);
       FETCH cr_crapttl
        INTO rw_crapttl;
       CLOSE cr_crapttl; 
         
       -- Inicializar idade
       vr_nrdeanos := 18;    
       -- Se menor de idade 
       IF rw_crapttl.inhabmen = 0  THEN 
         -- Verifica a idade
         cada0001.pc_busca_idade(pr_dtnasctl => rw_crapttl.dtnasttl
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
      IF vr_nrdeanos < 18 OR rw_crapttl.inhabmen = 2 THEN
      
        -- Inicializar lista de Representantes
        vr_lst_generico := json_list();
        
        --> Efetuar laço para retornar todos os registros disponíveis
        FOR rw_crapcrl IN cr_crapcrl ( pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta ) LOOP
          -- Setar flag para indicar que há responsaveis
          vr_flrespvl := true;
          
          --> Se Responsável for associado
          IF rw_crapcrl.nrdconta <> 0 THEN 
            -- Passaremos a conta para montagem dos dados:
            pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => rw_crapcrl.nrdconta
                                   ,pr_nrctremp => pr_nrctremp
                                   ,pr_dsjsonan => vr_obj_responsav
                                   ,pr_cdcritic => vr_cdcritic 
                                   ,pr_dscritic => vr_dscritic); 
            -- Testar possíveis erros na rotina:
            IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
              RAISE vr_exc_erro;
            END IF;
            
            -- Adicionar o avalista montato na lista de avalistas
            vr_lst_generico.append(vr_obj_responsav.to_json_value());

         ELSE
           -- Enviaremos os dados básicos encontrados na tabela de responsável legal
           vr_obj_responsav.put('documento'      , fn_mask_cpf_cnpj(NVL(rw_crapcrl.nrcpfcgc,0),1));
           vr_obj_responsav.put('tipoPessoa'     ,'FISICA');
           vr_obj_responsav.put('nome'           ,rw_crapcrl.nmrespon);
           IF rw_crapcrl.cddosexo = 1 THEN
             vr_obj_responsav.put('sexo','MASCULINO');
           ELSE
             vr_obj_responsav.put('sexo','FEMININO');
           END IF;
           
           IF rw_crapcrl.dtnascin IS NOT NULL THEN 
             vr_obj_responsav.put('dataNascimento' ,fn_Data_ibra_motor(rw_crapcrl.dtnascin));
           END IF;
           
           IF rw_crapcrl.nmmaersp IS NOT NULL THEN 
             vr_obj_responsav.put('nomeMae' ,rw_crapcrl.nmmaersp);
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
        
           -- Montar informações Adicionais
           vr_obj_generico := json();
           
           -- Nome Pai
           IF rw_crapcrl.nmpairsp <> ' ' THEN 
             vr_obj_generico.put('nomePai', rw_crapcrl.nmpairsp);
           END IF;
           -- Estado Civil
           IF rw_crapcrl.cdestciv <> 0 THEN 
             vr_obj_generico.put('estadoCivil', rw_crapcrl.cdestciv);
           END IF;
           -- Naturalidade
           IF rw_crapcrl.dsnatura <> ' ' THEN 
             vr_obj_generico.put('naturalidade', rw_crapcrl.dsnatura);
           END IF;
           -- Caixa Postal
           IF rw_crapcrl. nrcxpost <> 0 THEN 
             vr_obj_generico.put('caixaPostal', rw_crapcrl.nrcxpost);
           END IF;
     
           -- Enviar informações adicionais ao JSON Responsavel Leval
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
    
    --> Para pessoa Jurídica buscaremos os sócios da Empresa:
    IF rw_crapass.inpessoa = 2 THEN
    
      -- Inicializar lista de Representantes
      vr_lst_generico := json_list();
    
      --> Efetuar laço para retornar todos os registros disponíveis:
      FOR rw_crapavt IN cr_crapavt( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta 
                                   ,pr_nrctremp => 0
                                   ,pr_tpctrato => 6
                                   ,pr_dsproftl => 'SOCIO') LOOP 
    
        -- Setar flag para indicar que há sócio
        vr_flsocios := true;
        -- Se socio for associado
        IF rw_crapavt.nrdctato > 0 THEN 
          -- Passaremos a conta para montagem dos dados:
          pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapavt.nrdctato
                                 ,pr_nrctremp => pr_nrctremp
                                 ,pr_dsjsonan => vr_obj_socio
                                 ,pr_persocio => rw_crapavt.persocio
                                 ,pr_dtadmsoc => rw_crapavt.dtadmsoc
                                 ,pr_dtvigpro => rw_crapavt.dtvalida
                                 ,pr_cdcritic => vr_cdcritic 
                                 ,pr_dscritic => vr_dscritic);
          -- Testar possíveis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF;  
          
          -- Adicionar o responsavel montato na lista de socios
          vr_lst_generico.append(vr_obj_socio.to_json_value());

        ELSE
          -- Enviaremos os dados básicos encontrados na tabela de socios
          pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                                 ,pr_dsjsonavt  => vr_obj_socio
                                 ,pr_cdcritic   => vr_cdcritic 
                                 ,pr_dscritic   => vr_dscritic);
          -- Testar possíveis er ros na rotina:
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
       
      --> Busca das participações societárias
      
      -- Inicializar lista de Participações Societárias
      vr_lst_generico := json_list();
      
      --> Efetuar laço para retornar todos os registros disponíveis de participações:
      FOR rw_crapepa IN cr_crapepa( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta)  LOOP
        -- Setar flag para indicar que há participações
        vr_flpartic := true;
        -- Se socio for associado
        IF rw_crapepa.nrctasoc > 0 THEN 
          -- Passaremos a conta para montagem dos dados:
          pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapepa.nrctasoc
                                 ,pr_nrctremp => pr_nrctremp
                                 ,pr_persocio => rw_crapepa.persocio
                                 ,pr_dtadmsoc => rw_crapepa.dtadmiss
                                 ,pr_dtvigpro => to_date('31/12/9999','dd/mm/rrrr')
                                 ,pr_dsjsonan => vr_obj_particip
                                 ,pr_cdcritic => vr_cdcritic 
                                 ,pr_dscritic => vr_dscritic); 
          -- Testar possíveis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF;  
          -- Adicionar o responsavel montato na lista de socios
          vr_lst_generico.append(vr_obj_particip.to_json_value());

        ELSE
          -- Enviaremos os dados básicos encontrados na tabela de Participações    
          vr_obj_particip.put('documento'      ,fn_mask_cpf_cnpj(NVL(rw_crapepa.nrdocsoc,0),2));
          vr_obj_particip.put('tipoPessoa'     ,'JURIDICA');
          vr_obj_particip.put('razaoSocial'    ,rw_crapepa.nmprimtl);
          
          IF rw_crapepa.dtiniatv IS NOT NULL THEN 
            vr_obj_particip.put('dataFundacao' ,fn_Data_ibra_motor(rw_crapepa.dtiniatv));
          END IF;
          
          -- Montar informações Adicionais
          vr_obj_generico := json();

          -- Conta
          vr_obj_generico.put('conta', to_number(substr(rw_crapepa.nrdconta,1,length(rw_crapepa.nrdconta)-1)));
          vr_obj_generico.put('contaDV', to_number(substr(rw_crapepa.nrdconta,-1)));
          
          IF INSTR(rw_crapepa.dsendweb,'@') > 0 THEN
            vr_obj_generico.put('email', rw_crapepa.dsendweb);
          END IF;
          
          -- Natureza Juridica
          IF rw_crapepa.natjurid <> 0 THEN 
            --> Buscar descrição
            OPEN cr_nature(pr_natjurid => rw_crapepa.natjurid);
            FETCH cr_nature INTO rw_nature;
            CLOSE cr_nature;

            vr_obj_generico.put('naturezaJuridica', rw_crapepa.natjurid||'-'||rw_nature.dsnatjur);
          END IF;
          
          -- Quantidade Filiais
          vr_obj_generico.put('quantFiliais', rw_crapepa.qtfilial);

          -- Quantidade Funcionários
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
          
            -- Buscar descrição
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

          -- Numero Inscrição Estadual
          IF rw_crapepa.nrinsest <> 0 THEN   
            vr_obj_generico.put('numeroInscricEstadual', rw_crapepa.nrinsest);
          END IF;
          
          -- Data de Vigência Procuração
          vr_obj_generico.put('dataVigenciaProcuracao' ,fn_Data_ibra_motor(to_date('31/12/9999','dd/mm/rrrr')));
          
          -- Data de Admissão Procuração
          IF rw_crapepa.dtadmiss IS NOT NULL THEN 
            vr_obj_generico.put('dataAdmissaoProcuracao' ,fn_Data_ibra_motor(rw_crapepa.dtadmiss));
          END IF;  
           
          -- Percentual Procuração
          IF rw_crapepa.persocio IS NOT NULL THEN 
            vr_obj_generico.put('valorPercentualProcuracao' ,Este0001.fn_Decimal_Ibra(rw_crapepa.persocio));
          END IF;
         
          -- Enviar informações adicionais ao JSON Responsavel Leval
          vr_obj_particip.put('informacoesAdicionais' ,vr_obj_generico);    

          -- Adicionar o responsavel montado na lista de participações
          vr_lst_generico.append(vr_obj_particip.to_json_value());          
          
        END IF;  
        
      END LOOP; --> fim crapepa
      
      -- Enviar novo objeto de participações para dentro do objeto principal (Se houve encontro) 
      IF vr_flpartic = true THEN      
        vr_obj_analise.put('participacoesSocietarias' ,vr_lst_generico);
      END IF;
      
    END IF; --> INPESSOA 2   
    
    --> Busca dos procuradores:
    -- Inicializar lista de Representantes
    vr_lst_generico := json_list();

    -->Efetuar laço para retornar todos os registros disponíveis de Procuradores:
    FOR rw_crapavt IN cr_crapavt(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctremp => 0
                                ,pr_tpctrato => 6
                                ,pr_dsproftl => 'PROCURADOR') LOOP
      -- Setar flag para indicar que há sócio
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
        -- Testar possíveis erros na rotina:
        IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
          RAISE vr_exc_erro;
        END IF;  

        -- Adicionar o responsavel montato na lista de responsaveis
        vr_lst_generico.append(vr_obj_procurad.to_json_value());

      ELSE
        -- Enviaremos os dados básicos encontrados na tabela de procuradores
        pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                               ,pr_dsjsonavt  => vr_obj_procurad
                               ,pr_cdcritic   => vr_cdcritic 
                               ,pr_dscritic   => vr_dscritic);
        -- Testar possíveis erros na rotina:
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
      IF SQLCODE < 0 THEN
        -- Caso ocorra exception gerar o código do erro com a linha do erro
        vr_dscritic:= vr_dscritic ||
                      dbms_utility.format_error_backtrace;
                       
      END IF;  

      -- Montar a mensagem final do erro 
      vr_dscritic:= 'Erro na montagem dos dados para análise automática da proposta (2): ' ||
                     vr_dscritic || ' -- SQLERRM: ' || SQLERRM;
                       
      -- Remover as ASPAS que quebram o texto
      vr_dscritic:= replace(vr_dscritic,'"', '');
      vr_dscritic:= replace(vr_dscritic,'''','');
      -- Remover as quebras de linha
      vr_dscritic:= replace(vr_dscritic,chr(10),'');
      vr_dscritic:= replace(vr_dscritic,chr(13),'');
      
      pr_cdcritic := 0;
      pr_dscritic := vr_dscritic;

  END pc_gera_json_analise;
    
  PROCEDURE pc_gera_json_limite ( pr_cdcooper   IN crapass.cdcooper%TYPE   --> Codigo da cooperativa
                                 ,pr_cdagenci   IN crapass.cdagenci%TYPE   --> Codigo da cooperativa
                                 ,pr_nrdconta   IN crapass.nrdconta%TYPE   --> Codigo da cooperativa
                                 ,pr_nrctrlim   IN crapepr.nrctremp%TYPE   --> Codigo da cooperativa
                                 ,pr_tpctrlim   IN craplim.tpctrlim%TYPE
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
    
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
	  -- Buscar quantidade de dias de reaproveitamento   		
		CURSOR cr_craprbi IS
		  SELECT rbi.qtdiarpv
			  FROM craprbi rbi
				    ,crapass ass
						,craplim lim
			 WHERE ass.cdcooper = pr_cdcooper
				 AND ass.nrdconta = pr_nrdconta
				 AND lim.cdcooper = pr_cdcooper
				 AND lim.nrdconta = pr_nrdconta
				 AND lim.nrctrlim = pr_nrctrlim
				 AND lim.tpctrlim = pr_tpctrlim
				 AND rbi.cdcooper = pr_cdcooper
			   AND rbi.inpessoa = ass.inpessoa
				 AND rbi.inprodut = decode(lim.tpctrlim, 3, 5, 2, 4, 3);
		rw_craprbi cr_craprbi%ROWTYPE;
		
		-- Buscar PA do operador de envio da proposta
		CURSOR cr_crapope IS
		  SELECT ope.cdpactra
			  FROM crapope ope
				    ,craplim lim
			 WHERE lim.cdcooper = pr_cdcooper
			   AND lim.nrdconta = pr_nrdconta
				 AND lim.nrctrlim = pr_nrctrlim
			   AND ope.cdcooper = pr_cdcooper
			   AND upper(ope.cdoperad) = upper(lim.cdoperad);
		vr_cdpactra crapope.cdpactra%TYPE;
		
		-- Buscar última data de consulta ao bacen
		CURSOR cr_crapopf IS
	    SELECT max(opf.dtrefere) dtrefere
        FROM crapopf opf;
		rw_crapopf cr_crapopf%ROWTYPE;
		
    --> Buscar dados da proposta
    CURSOR cr_craplim IS
      SELECT lim.vllimite
            ,ldc.cddlinha
            ,ldc.dsdlinha
            ,ldc.tpctrato
            ,lim.inconcje
            ,lim.idquapro
            ,ass.nrcpfcgc
            ,ass.inpessoa
            ,ldc.txmensal
        FROM craplim lim
            ,crapldc ldc     
            ,crapass ass
       WHERE lim.cdcooper = ldc.cdcooper
         AND lim.cddlinha = ldc.cddlinha
         AND lim.cdcooper = ass.cdcooper
         AND lim.nrdconta = ass.nrdconta
         AND lim.cdcooper = pr_cdcooper
         AND lim.nrdconta = pr_nrdconta
         AND lim.nrctrlim = pr_nrctrlim
         AND lim.tpctrlim = pr_tpctrlim;
    rw_craplim cr_craplim%ROWTYPE;
    
    -- Buscar os dados do associado
    CURSOR cr_crapass(pr_cdcooper crapass.cdcooper%type,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ass.inpessoa
        FROM crapass ass
       WHERE ass.cdcooper = pr_cdcooper
         AND ass.nrdconta = pr_nrdconta;
    rw_crapass cr_crapass%ROWTYPE;
    
    -- Buscar dados titular
    CURSOR cr_crapttl(pr_cdcooper crapass.cdcooper%type,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT ttl.dtnasttl
            ,ttl.inhabmen
        FROM crapttl ttl
       WHERE ttl.cdcooper = pr_cdcooper
         AND ttl.nrdconta = pr_nrdconta
         AND ttl.idseqttl = 1;                      
    rw_crapttl cr_crapttl%rowtype;
    
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
            ,org.cdorgao_expedidor dsorgemi
            ,crapcrl.cdufiden
            ,crapcrl.dtemiden
            ,crapcrl.dtnascin
            ,crapcrl.cddosexo
            ,crapcrl.cdestciv
            ,crapnac.dsnacion
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
        FROM crapcrl,
             crapnac,
             tbgen_orgao_expedidor org
       WHERE crapcrl.cdcooper = pr_cdcooper
         AND crapcrl.nrctamen = pr_nrdconta
         AND crapcrl.cdnacion = crapnac.cdnacion(+)
         AND crapcrl.idorgexp = org.idorgao_expedidor(+);
    
    -- Declarar cursor de participações societárias
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
    
    -- Buscar descrição
    CURSOR cr_nature (pr_natjurid gncdntj.cdnatjur%TYPE) IS
      SELECT gncdntj.dsnatjur
        FROM gncdntj
       WHERE gncdntj.cdnatjur = pr_natjurid;
    rw_nature cr_nature%ROWTYPE; 
    
    -- Buscar descrição
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
            ,greatest(crapbpr.nranobem,crapbpr.nrmodbem) nranobem
            ,crapbpr.nrcpfbem
        FROM crapbpr 
       WHERE crapbpr.cdcooper = pr_cdcooper
         AND crapbpr.nrdconta = pr_nrdconta
         AND crapbpr.nrctrpro = pr_nrctremp   
         AND crapbpr.tpctrpro = 90
         AND trim(crapbpr.dscatbem) is not NULL;
    
    -- Buscar Saldo de Cotas
    CURSOR cr_crapcot(pr_cdcooper crapass.cdcooper%type,
                      pr_nrdconta crapass.nrdconta%TYPE) IS
      SELECT vldcotas
        FROM crapcot
       WHERE cdcooper = pr_cdcooper
         AND nrdconta = pr_nrdconta;
    vr_vldcotas crapcot.vldcotas%TYPE;
    
    --> Buscar se a conta é de Colaborador Cecred
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
				 AND prp.nrctrato = pr_nrctrlim
				 AND prp.tpctrato = pr_tpctrlim;
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
    vr_obj_generic4  json      := json(); -- Variáveis internas
    
    vr_flavalis      BOOLEAN := FALSE;
    vr_flrespvl      BOOLEAN := FALSE;
    vr_flsocios      BOOLEAN := FALSE;
    vr_flpartic      BOOLEAN := FALSE;
    vr_flprocura     BOOLEAN := FALSE;
    vr_flgbens       BOOLEAN := FALSE;
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
    -- Se não encontrar
    IF BTCH0001.cr_crapdat%NOTFOUND THEN
      -- Montar mensagem de critica
      vr_cdcritic:= 1;
      CLOSE BTCH0001.cr_crapdat;
      RAISE vr_exc_erro;
    ELSE
      -- Apenas fechar o cursor
      CLOSE BTCH0001.cr_crapdat;
    END IF;  
  
    vr_obj_analise.put('proposta', gene0002.fn_mask_contrato(pr_nrctrlim));
                      
	  -- Buscar quantidade de dias de reaproveitamento             
    OPEN cr_craprbi;
		FETCH cr_craprbi INTO rw_craprbi;
		
		-- Se encontrou
		IF cr_craprbi%FOUND THEN
			-- Buscar a coluna e multiplicar por 24 para chegarmos na quantidade de horas de reaproveitamento
			vr_qtdiarpv := rw_craprbi.qtdiarpv * 24;
		ELSE
			-- Se não encontrar consideramos 168 horas (7 dias)
			vr_qtdiarpv := 168;
		END IF;
    CLOSE cr_craprbi;
		
		-- Buscar PA do operador
		OPEN cr_crapope;
		FETCH cr_crapope INTO vr_cdpactra;
    CLOSE cr_crapope;
		
		OPEN cr_crapopf;
		FETCH cr_crapopf INTO rw_crapopf;
    IF cr_crapopf%NOTFOUND THEN
      CLOSE cr_crapopf;
      vr_dscritic := 'Data Base Bacen-SCR nao encontrada!';
      RAISE vr_exc_erro;
    ELSE
    CLOSE cr_crapopf;
    END IF;
		
		-- Montar os atributos de 'configuracoes'
		vr_obj_generico := json();
		vr_obj_generico.put('centroCusto', vr_cdpactra);
    vr_obj_generico.put('dataBaseBacen', to_char(rw_crapopf.dtrefere,'RRRRMM'));
		vr_obj_generico.put('horasReaproveitamento', vr_qtdiarpv);
		
    -- Adicionar o array configuracoes
    vr_obj_analise.put('configuracoes', vr_obj_generico);																	 
																	 
    --> Buscar dados da proposta de emprestimo
    OPEN cr_craplim;
    FETCH cr_craplim INTO rw_craplim;
    
    -- Caso nao encontrar abortar proceso
    IF cr_craplim%NOTFOUND THEN
      CLOSE cr_craplim;
      vr_cdcritic := 535; -- 535 - Proposta nao encontrada.
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_craplim;
    
    --> indicadoresCliente
    vr_obj_generico := json();
    
    vr_obj_generico.put('cooperativa', pr_cdcooper); 
    vr_obj_generico.put('agenci', pr_cdagenci);


    vr_obj_generico.put('segmentoCodigo' ,2); -- Emprestimos/Financiamento  -- ????????
    vr_obj_generico.put('segmentoDescricao' ,'Limite Desconto Titulo');   
    vr_obj_generico.put('linhaCreditoCodigo'    ,rw_craplim.cddlinha); -- ????????
    vr_obj_generico.put('linhaCreditoDescricao' ,rw_craplim.dsdlinha); -- ????????
    vr_obj_generico.put('finalidadeCodigo'      ,0); -- ????????      
    vr_obj_generico.put('finalidadeDescricao'   ,' '); -- ????????               

    
    vr_obj_generico.put('tipoProduto'           ,0); -- ????????
    vr_obj_generico.put('tipoGarantiaCodigo'    ,0 ); -- ????????
/*    
    --> Buscar descrição do tipo de garantia
    vr_dstpgara  := tabe0001.fn_busca_dstextab(pr_cdcooper => pr_cdcooper,
                                               pr_nmsistem => 'CRED',
                                               pr_tptabela => 'GENERI', 
                                               pr_cdempres => 0, 
                                               pr_cdacesso => 'CTRATOEMPR', 
                                               pr_tpregist => rw_crawepr.tpctrato);    
                                              
    vr_obj_generico.put('tipoGarantiaDescricao'    ,TRIM(vr_dstpgara) );
*/
    vr_obj_generico.put('debitoEm'    ,'C' ); -- ????????
    vr_obj_generico.put('liquidacao'  ,'false'); -- ????????

    vr_obj_generico.put('valorTaxaMensal', ESTE0001.fn_decimal_ibra(rw_craplim.txmensal));

    vr_obj_generico.put('valorEmprest'  , ESTE0001.fn_decimal_ibra(rw_craplim.vllimite));
 --   vr_obj_generico.put('quantParcela'  , rw_crawepr.qtpreemp);
 --   vr_obj_generico.put('primeiroVencto', fn_Data_ibra_motor(rw_crawepr.dtvencto));
 --   vr_obj_generico.put('valorParcela'  , ESTE0001.fn_decimal_ibra(rw_crawepr.vlpreemp));

    vr_obj_generico.put('renegociacao', 'flase');

    vr_obj_generico.put('qualificaOperacaoCodigo',rw_craplim.idquapro );

    CASE rw_craplim.idquapro
      WHEN 1 THEN vr_dsquapro := 'Operacao normal';
      WHEN 2 THEN vr_dsquapro := 'Renovacao de credito';
      WHEN 3 THEN vr_dsquapro := 'Renegociacao de credito';
      WHEN 4 THEN vr_dsquapro := 'Composicao da divida';
      ELSE vr_dsquapro := ' ';
    END CASE;

    vr_obj_generico.put('qualificaOperacaoDescricao'    ,vr_dsquapro );
         
    IF rw_craplim.inpessoa = 1 THEN 
      -- Verificar se a conta é de colaborador do sistema Cecred
      vr_cddcargo := NULL;
      OPEN cr_tbcolab(pr_cdcooper => pr_cdcooper
                     ,pr_nrcpfcgc => rw_craplim.nrcpfcgc);
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
    
    -- Efetuar laço para trazer todos os registros 
    FOR rw_crapbpr IN cr_crapbpr(pr_cdcooper => pr_cdcooper,
                                 pr_nrdconta => pr_nrdconta,
                                 pr_nrctremp => pr_nrctrlim )  LOOP 

      -- Indicar que encontrou
      vr_flgbens := TRUE;
      -- Para cada registro de Bem, criar objeto para a operação e enviar suas informações 
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
    IF vr_flgbens THEN
      vr_obj_generico.put('bemEmGarantia', vr_lst_generic2);
    ELSE
      -- Verificar se o valor das Cotas é Superior ao da Proposta
      OPEN cr_crapcot(pr_cdcooper
                     ,pr_nrdconta);
      FETCH cr_crapcot
       INTO vr_vldcotas;
      CLOSE cr_crapcot;
      -- Se valor das cotas é superior ao da proposta
      IF NVL(vr_vldcotas,0) > rw_craplim.vllimite THEN 
        -- Adicionar as cotas  
        vr_lst_generic2 := json_list();
        vr_obj_generic2 := json();
        vr_obj_generic2.put('categoriaBem','COTAS CAPITAL');
        vr_obj_generic2.put('anoGarantia',0);
        vr_obj_generic2.put('valorGarantia',ESTE0001.fn_decimal_ibra(vr_vldcotas));
        vr_obj_generic2.put('bemInterveniente',false);
        -- Adicionar Bem na lista
        vr_lst_generic2.append(vr_obj_generic2.to_json_value());
        -- Adicionar as cotas como garantia
        vr_obj_generico.put('bemEmGarantia', vr_lst_generic2);
      END IF;
    END IF;  

    vr_obj_generico.put('operacao', 'DESCONTO'); -- ???????? 
    vr_obj_analise.put('indicadoresCliente', vr_obj_generico);         
    
    pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                           ,pr_nrdconta => pr_nrdconta
                           ,pr_nrctremp => pr_nrctrlim
                           ,pr_flprepon => true
                           ,pr_dsjsonan => vr_obj_generico
                           ,pr_cdcritic => vr_cdcritic 
                           ,pr_dscritic => vr_dscritic);
                           
     -- Testar possíveis erros na rotina:
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
     
      -- Se não encontrar 
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
                                 ,pr_nrctremp => pr_nrctrlim
                                 ,pr_vlsalari => rw_crapcje.vlsalari
                                 ,pr_dsjsonan => vr_obj_conjuge
                                 ,pr_cdcritic => vr_cdcritic 
                                 ,pr_dscritic => vr_dscritic);

          -- Testar possíveis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF; 
            
          -- Adicionar o JSON montado do Proponente no objeto principal
          vr_obj_analise.put('conjuge',vr_obj_conjuge);

        ELSE
          -- Enviaremos os dados básicos encontrados na tabela de conjugue
          vr_obj_conjuge.put('documento'      ,fn_mask_cpf_cnpj(NVL(rw_crapcje.nrcpfcjg,0),1));
          vr_obj_conjuge.put('tipoPessoa'     ,'FISICA');
          vr_obj_conjuge.put('nome'           ,rw_crapcje.nmconjug);
          
          vr_obj_conjuge.put('dataNascimento' ,fn_Data_ibra_motor(rw_crapcje.dtnasccj));
          
          -- Se o Documento for RG
          IF rw_crapcje.tpdoccje = 'CI' THEN
            vr_obj_conjuge.put('rg', rw_crapcje.nrdoccje);
            vr_obj_conjuge.put('ufRg', rw_crapcje.cdufdcje);
          END IF;
          
          -- Montar objeto Telefone para Telefone Comercial      
          IF rw_crapcje.nrfonemp <> ' ' THEN 
            vr_lst_generic2 := json_list();
            -- Criar objeto só para este telefone
            vr_obj_generico := json();
            vr_obj_generico.put('especie', 'COMERCIAL');
            IF SUBSTR(rw_crapcje.nrfonemp,1,1) < 8 THEN 
              vr_obj_generico.put('tipo', 'FIXO');
            ELSE
              vr_obj_generico.put('tipo', 'MOVEL');
            END IF;
            
            vr_obj_generico.put('numero', fn_somente_numeros_telefone(rw_crapcje.nrfonemp));
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
          
          -- Montar informações Adicionais
          vr_obj_generico := json();
          -- Escolaridade
          IF rw_crapcje.grescola <> 0 THEN 
            vr_obj_generico.put('escolaridade', rw_crapcje.grescola);
          END IF;
          -- Curso Superior
          IF rw_crapcje.cdfrmttl <> 0 THEN 
            vr_obj_generico.put('cursoSuperiorCodigo'
                               ,rw_crapcje.cdfrmttl);
            vr_obj_generico.put('cursoSuperiorDescricao'
                               ,fn_des_cdfrmttl(rw_crapcje.cdfrmttl));
          END IF;
          -- Natureza Ocupação
          IF rw_crapcje.cdnatopc <> 0 THEN 
            vr_obj_generico.put('naturezaOcupacao', rw_crapcje.cdnatopc);
          END IF;
          -- Ocupação
          IF rw_crapcje.cdocpcje <> 0 THEN 
            vr_obj_generico.put('ocupacaoCodigo'
                               ,rw_crapcje.cdocpcje);
            vr_obj_generico.put('ocupacaoDescricao'
                               ,fn_des_cdocupa(rw_crapcje.cdocpcje));
          END IF;
          -- Tipo Contrato de Trabalho
          IF rw_crapcje.tpcttrab <> 0 THEN 
            vr_obj_generico.put('tipoContratoTrabalho', rw_crapcje.tpcttrab);
          END IF;
          -- Nivel Cargo
          IF rw_crapcje.cdnvlcgo <> 0 THEN 
            vr_obj_generico.put('nivelCargo', rw_crapcje.cdnvlcgo);
          END IF;
          -- Turno
          IF rw_crapcje.cdturnos <> 0 THEN 
            vr_obj_generico.put('turno', rw_crapcje.cdturnos);
          END IF;
          -- Data Admissão
          IF rw_crapcje.dtadmemp IS NOT NULL THEN 
            vr_obj_generico.put('dataAdmissao', fn_Data_ibra_motor(rw_crapcje.dtadmemp));
          END IF;
          -- Salario
          IF rw_crapcje.vlsalari <> 0 THEN 
            vr_obj_generico.put('valorSalario', ESTE0001.fn_decimal_ibra(rw_crapcje.vlsalari));
          END IF;
          -- CNPJ Empresa
          IF rw_crapcje.nrdocnpj <> 0 THEN 
            vr_obj_generico.put('codCNPJEmpresa', rw_crapcje.nrdocnpj);
          END IF;

          -- Enviar informações adicionais ao JSON Conjuge
          -- tratamento para nao enviar JSON como LISTA quando executado no PHP junto a funcao JSON_DECODE
          IF json_ac.object_count(vr_obj_generico) > 0 THEN
          vr_obj_conjuge.put('informacoesAdicionais' ,vr_obj_generico);        
          END IF;
              
          -- Ao final adicionamos o json montado ao principal
          vr_obj_analise.put('conjuge' ,vr_obj_conjuge);        
        END IF; 
        
      END IF;  
      
    END IF;
    
    --> BUSCAR AVALISTAS INTERNOS E EXTERNOS: 
    -- Inicializar lista de Avalistas
    vr_lst_generico := json_list();
 
    -- Enviar avalista 01 em novo json só para avalistas
    IF nvl(pr_nrctaav1,0) <> 0 THEN
      -- Setar flag para indicar que há avalista
      vr_flavalis := true;
      
      pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrctaav1
                             ,pr_nrctremp => pr_nrctrlim
                             ,pr_dsjsonan => vr_obj_avalista
                             ,pr_cdcritic => vr_cdcritic 
                             ,pr_dscritic => vr_dscritic);

      -- Testar possíveis erros na rotina:
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro;
      END IF;

      -- Adicionar o avalista montato na lista de avalistas
      vr_lst_generico.append(vr_obj_avalista.to_json_value());

    END IF;
    
    -- Enviar avalista 02 em novo json só para avalistas
    IF nvl(pr_nrctaav2,0) <> 0 THEN
      -- Setar flag para indicar que há avalista
      vr_flavalis := true;
      
      pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                             ,pr_nrdconta => pr_nrctaav2
                             ,pr_nrctremp => pr_nrctrlim
                             ,pr_dsjsonan => vr_obj_avalista
                             ,pr_cdcritic => vr_cdcritic 
                             ,pr_dscritic => vr_dscritic);

      -- Testar possíveis erros na rotina:
      IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
        RAISE vr_exc_erro;
      END IF;

      -- Adicionar o avalista montato na lista de avalistas
      vr_lst_generico.append(vr_obj_avalista.to_json_value());

    END IF;
    
    --> Efetuar laço para retornar todos os registros disponíveis:
    FOR rw_crapavt IN cr_crapavt( pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => pr_nrdconta 
                                 ,pr_nrctremp => pr_nrctrlim
                                 ,pr_tpctrato => 8 -- Desconto de Cheque
                                 ,pr_dsproftl => null) LOOP
                                 
      -- Setar flag para indicar que há avalista
      vr_flavalis := true;
      -- Enviaremos os dados básicos encontrados na tabela de avalistas terceiros 
      pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                             ,pr_dsjsonavt  => vr_obj_avalista
                             ,pr_cdcritic   => vr_cdcritic 
                             ,pr_dscritic   => vr_dscritic);
      -- Testar possíveis erros na rotina:
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
  
    --> Para pessoa física verificaremos necessidade de envio dos responsáveis legais:
    IF rw_crapass.inpessoa = 1 THEN 
      
       -- Buscar dados titular
       OPEN cr_crapttl(pr_cdcooper,pr_nrdconta);
       FETCH cr_crapttl
        INTO rw_crapttl;
       CLOSE cr_crapttl; 
         
       -- Inicializar idade
       vr_nrdeanos := 18;    
       -- Se menor de idade 
       IF rw_crapttl.inhabmen = 0  THEN 
         -- Verifica a idade
         cada0001.pc_busca_idade(pr_dtnasctl => rw_crapttl.dtnasttl
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
      IF vr_nrdeanos < 18 OR rw_crapttl.inhabmen = 2 THEN
      
        -- Inicializar lista de Representantes
        vr_lst_generico := json_list();
        
        --> Efetuar laço para retornar todos os registros disponíveis
        FOR rw_crapcrl IN cr_crapcrl ( pr_cdcooper => pr_cdcooper
                                      ,pr_nrdconta => pr_nrdconta ) LOOP
          -- Setar flag para indicar que há responsaveis
          vr_flrespvl := true;
          
          --> Se Responsável for associado
          IF rw_crapcrl.nrdconta <> 0 THEN 
            -- Passaremos a conta para montagem dos dados:
            pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => rw_crapcrl.nrdconta
                                   ,pr_nrctremp => pr_nrctrlim
                                   ,pr_dsjsonan => vr_obj_responsav
                                   ,pr_cdcritic => vr_cdcritic 
                                   ,pr_dscritic => vr_dscritic); 
            -- Testar possíveis erros na rotina:
            IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
              RAISE vr_exc_erro;
            END IF;
            
            -- Adicionar o avalista montato na lista de avalistas
            vr_lst_generico.append(vr_obj_responsav.to_json_value());

         ELSE
           -- Enviaremos os dados básicos encontrados na tabela de responsável legal
           vr_obj_responsav.put('documento'      , fn_mask_cpf_cnpj(NVL(rw_crapcrl.nrcpfcgc,0),1));
           vr_obj_responsav.put('tipoPessoa'     ,'FISICA');
           vr_obj_responsav.put('nome'           ,rw_crapcrl.nmrespon);
           IF rw_crapcrl.cddosexo = 1 THEN
             vr_obj_responsav.put('sexo','MASCULINO');
           ELSE
             vr_obj_responsav.put('sexo','FEMININO');
           END IF;
           
           IF rw_crapcrl.dtnascin IS NOT NULL THEN 
             vr_obj_responsav.put('dataNascimento' ,fn_Data_ibra_motor(rw_crapcrl.dtnascin));
           END IF;
           
           IF rw_crapcrl.nmmaersp IS NOT NULL THEN 
             vr_obj_responsav.put('nomeMae' ,rw_crapcrl.nmmaersp);
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
        
           -- Montar informações Adicionais
           vr_obj_generico := json();
           
           -- Nome Pai
           IF rw_crapcrl.nmpairsp <> ' ' THEN 
             vr_obj_generico.put('nomePai', rw_crapcrl.nmpairsp);
           END IF;
           -- Estado Civil
           IF rw_crapcrl.cdestciv <> 0 THEN 
             vr_obj_generico.put('estadoCivil', rw_crapcrl.cdestciv);
           END IF;
           -- Naturalidade
           IF rw_crapcrl.dsnatura <> ' ' THEN 
             vr_obj_generico.put('naturalidade', rw_crapcrl.dsnatura);
           END IF;
           -- Caixa Postal
           IF rw_crapcrl. nrcxpost <> 0 THEN 
             vr_obj_generico.put('caixaPostal', rw_crapcrl.nrcxpost);
           END IF;
     
           -- Enviar informações adicionais ao JSON Responsavel Leval
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
    
    --> Para pessoa Jurídica buscaremos os sócios da Empresa:
    IF rw_crapass.inpessoa = 2 THEN
    
      -- Inicializar lista de Representantes
      vr_lst_generico := json_list();
    
      --> Efetuar laço para retornar todos os registros disponíveis:
      FOR rw_crapavt IN cr_crapavt( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta 
                                   ,pr_nrctremp => 0
                                   ,pr_tpctrato => 6
                                   ,pr_dsproftl => 'SOCIO') LOOP 
    
        -- Setar flag para indicar que há sócio
        vr_flsocios := true;
        -- Se socio for associado
        IF rw_crapavt.nrdctato > 0 THEN 
          -- Passaremos a conta para montagem dos dados:
          pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapavt.nrdctato
                                 ,pr_nrctremp => pr_nrctrlim
                                 ,pr_dsjsonan => vr_obj_socio
                                 ,pr_persocio => rw_crapavt.persocio
                                 ,pr_dtadmsoc => rw_crapavt.dtadmsoc
                                 ,pr_dtvigpro => rw_crapavt.dtvalida
                                 ,pr_cdcritic => vr_cdcritic 
                                 ,pr_dscritic => vr_dscritic);
          -- Testar possíveis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF;  
          
          -- Adicionar o responsavel montato na lista de socios
          vr_lst_generico.append(vr_obj_socio.to_json_value());

        ELSE
          -- Enviaremos os dados básicos encontrados na tabela de socios
          pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                                 ,pr_dsjsonavt  => vr_obj_socio
                                 ,pr_cdcritic   => vr_cdcritic 
                                 ,pr_dscritic   => vr_dscritic);
          -- Testar possíveis er ros na rotina:
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
       
      --> Busca das participações societárias
      
      -- Inicializar lista de Participações Societárias
      vr_lst_generico := json_list();
      
      --> Efetuar laço para retornar todos os registros disponíveis de participações:
      FOR rw_crapepa IN cr_crapepa( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta)  LOOP
        -- Setar flag para indicar que há participações
        vr_flpartic := true;
        -- Se socio for associado
        IF rw_crapepa.nrctasoc > 0 THEN 
          -- Passaremos a conta para montagem dos dados:
          pc_gera_json_pessoa_ass(pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapepa.nrctasoc
                                 ,pr_nrctremp => pr_nrctrlim
                                 ,pr_persocio => rw_crapepa.persocio
                                 ,pr_dtadmsoc => rw_crapepa.dtadmiss
                                 ,pr_dtvigpro => to_date('31/12/9999','dd/mm/rrrr')
                                 ,pr_dsjsonan => vr_obj_particip
                                 ,pr_cdcritic => vr_cdcritic 
                                 ,pr_dscritic => vr_dscritic); 
          -- Testar possíveis erros na rotina:
          IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
            RAISE vr_exc_erro;
          END IF;  
          -- Adicionar o responsavel montato na lista de socios
          vr_lst_generico.append(vr_obj_particip.to_json_value());

        ELSE
          -- Enviaremos os dados básicos encontrados na tabela de Participações    
          vr_obj_particip.put('documento'      ,fn_mask_cpf_cnpj(NVL(rw_crapepa.nrdocsoc,0),2));
          vr_obj_particip.put('tipoPessoa'     ,'JURIDICA');
          vr_obj_particip.put('razaoSocial'    ,rw_crapepa.nmprimtl);
          
          IF rw_crapepa.dtiniatv IS NOT NULL THEN 
            vr_obj_particip.put('dataFundacao' ,fn_Data_ibra_motor(rw_crapepa.dtiniatv));
          END IF;
          
          -- Montar informações Adicionais
          vr_obj_generico := json();

          -- Conta
          vr_obj_generico.put('conta', to_number(substr(rw_crapepa.nrdconta,1,length(rw_crapepa.nrdconta)-1)));
          vr_obj_generico.put('contaDV', to_number(substr(rw_crapepa.nrdconta,-1)));
          
          IF INSTR(rw_crapepa.dsendweb,'@') > 0 THEN
            vr_obj_generico.put('email', rw_crapepa.dsendweb);
          END IF;
          
          -- Natureza Juridica
          IF rw_crapepa.natjurid <> 0 THEN 
            --> Buscar descrição
            OPEN cr_nature(pr_natjurid => rw_crapepa.natjurid);
            FETCH cr_nature INTO rw_nature;
            CLOSE cr_nature;

            vr_obj_generico.put('naturezaJuridica', rw_crapepa.natjurid||'-'||rw_nature.dsnatjur);
          END IF;
          
          -- Quantidade Filiais
          vr_obj_generico.put('quantFiliais', rw_crapepa.qtfilial);

          -- Quantidade Funcionários
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
          
            -- Buscar descrição
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

          -- Numero Inscrição Estadual
          IF rw_crapepa.nrinsest <> 0 THEN   
            vr_obj_generico.put('numeroInscricEstadual', rw_crapepa.nrinsest);
          END IF;
          
          -- Data de Vigência Procuração
          vr_obj_generico.put('dataVigenciaProcuracao' ,fn_Data_ibra_motor(to_date('31/12/9999','dd/mm/rrrr')));
          
          -- Data de Admissão Procuração
          IF rw_crapepa.dtadmiss IS NOT NULL THEN 
            vr_obj_generico.put('dataAdmissaoProcuracao' ,fn_Data_ibra_motor(rw_crapepa.dtadmiss));
          END IF;  
           
          -- Percentual Procuração
          IF rw_crapepa.persocio IS NOT NULL THEN 
            vr_obj_generico.put('valorPercentualProcuracao' ,Este0001.fn_Decimal_Ibra(rw_crapepa.persocio));
          END IF;
         
          -- Enviar informações adicionais ao JSON Responsavel Leval
          vr_obj_particip.put('informacoesAdicionais' ,vr_obj_generico);    

          -- Adicionar o responsavel montado na lista de participações
          vr_lst_generico.append(vr_obj_particip.to_json_value());          
          
        END IF;  
        
      END LOOP; --> fim crapepa
      
      -- Enviar novo objeto de participações para dentro do objeto principal (Se houve encontro) 
      IF vr_flpartic = true THEN      
        vr_obj_analise.put('participacoesSocietarias' ,vr_lst_generico);
      END IF;
      
    END IF; --> INPESSOA 2   
    
    --> Busca dos procuradores:
    -- Inicializar lista de Representantes
    vr_lst_generico := json_list();

    -->Efetuar laço para retornar todos os registros disponíveis de Procuradores:
    FOR rw_crapavt IN cr_crapavt(pr_cdcooper => pr_cdcooper
                                ,pr_nrdconta => pr_nrdconta
                                ,pr_nrctremp => 0
                                ,pr_tpctrato => 6
                                ,pr_dsproftl => 'PROCURADOR') LOOP
      -- Setar flag para indicar que há sócio
      vr_flprocura := true;
      -- Se socio for associado
      IF rw_crapavt.nrdctato > 0 THEN 
        -- Passaremos a conta para montagem dos dados:
        pc_gera_json_pessoa_ass ( pr_cdcooper => pr_cdcooper
                                 ,pr_nrdconta => rw_crapavt.nrdctato
                                 ,pr_nrctremp => pr_nrctrlim
                                 ,pr_dsjsonan => vr_obj_procurad
                                 ,pr_cdcritic => vr_cdcritic 
                                 ,pr_dscritic => vr_dscritic); 
        -- Testar possíveis erros na rotina:
        IF nvl(vr_cdcritic,0) <> 0 OR TRIM(vr_dscritic) IS NOT NULL THEN 
          RAISE vr_exc_erro;
        END IF;  

        -- Adicionar o responsavel montato na lista de responsaveis
        vr_lst_generico.append(vr_obj_procurad.to_json_value());

      ELSE
        -- Enviaremos os dados básicos encontrados na tabela de procuradores
        pc_gera_json_pessoa_avt(pr_rw_crapavt => rw_crapavt
                               ,pr_dsjsonavt  => vr_obj_procurad
                               ,pr_cdcritic   => vr_cdcritic 
                               ,pr_dscritic   => vr_dscritic);
        -- Testar possíveis erros na rotina:
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
      pr_dscritic := 'Erro na montagem dos dados para análise automática da proposta: '||sqlerrm;
  END pc_gera_json_limite;
  
--> Rotina para calcular valor total financiado
  PROCEDURE pc_ret_valor_financiado
                                ( pr_cdcooper   IN crapass.cdcooper%TYPE   --> Codigo da cooperativa
                                 ,pr_nrdconta   IN crapass.nrdconta%TYPE   --> Codigo da cooperativa
                                 ,pr_nrctremp   IN crapepr.nrctremp%TYPE   --> Codigo da cooperativa
                                  ---- OUT ----
                                 ,pr_vlfinanc  OUT NUMBER                  --> Retornar valor financiado 
                                 ,pr_cdcritic  OUT NUMBER                  --> Codigo da critica
                                 ,pr_dscritic  OUT VARCHAR2) IS            --> Descricao da critica
  /* ..........................................................................
    
      Programa : pc_ret_valor_financiado        
      Sistema  : Conta-Corrente - Cooperativa de Credito
      Sigla    : CRED
      Autor    : Odirlei Busana(AMcom)
      Data     : Junho/2018.                   Ultima atualizacao: 
    
      Dados referentes ao programa:
    
      Frequencia: Sempre que for chamado
      Objetivo  : Rotina para calcular valor total financiado
    
      Alteração : 
        
    ..........................................................................*/
    -----------> CURSORES <-----------
    CURSOR cr_crawepr (pr_cdcooper  crawepr.cdcooper%TYPE,
                       pr_nrdconta  crawepr.nrdconta%TYPE,
                       pr_nrctremp  crawepr.nrctremp%TYPE) IS
      SELECT crawepr.cdfinemp,
             crawepr.cdlcremp,
             crawepr.dtmvtolt,
             crawepr.vlemprst,
             crawepr.qtpreemp,
             crawepr.vlpreemp,
             crawepr.dtvencto,
             crawepr.qttolatr,
             crawepr.percetop,
             crawepr.nrctaav1,
             crawepr.nrctaav2,
             crapass.inpessoa,
             crapass.nrcpfcgc,
             crapass.nrdocptl,
             crapass.cdagenci,
             crawepr.cdagenci cdageepr,
             crapass.nmprimtl,
             crawepr.tpemprst,
             crawepr.flgpagto,
             add_months(crawepr.dtvencto,crawepr.qtpreemp -1) dtultpag,
             crawepr.dtlibera,
             crawepr.dtdpagto,
             crawepr.txmensal,
             crapage.nmcidade,
             crapage.cdufdcop,
             crawepr.nrseqrrq,
             crawepr.idcobope,
             crawepr.idfiniof,
             crawepr.nrctrliq##1 || ',' ||
             crawepr.nrctrliq##2 || ',' ||
             crawepr.nrctrliq##3 || ',' ||
             crawepr.nrctrliq##4 || ',' ||
             crawepr.nrctrliq##5 || ',' ||
             crawepr.nrctrliq##6 || ',' ||
             crawepr.nrctrliq##7 || ',' ||
             crawepr.nrctrliq##8 || ',' ||
             crawepr.nrctrliq##9 || ',' ||
             crawepr.nrctrliq##10 dsctrliq
        FROM crapage,
             crapass,
             crawepr
       WHERE crawepr.cdcooper = pr_cdcooper
         AND crawepr.nrdconta = pr_nrdconta
         AND crawepr.nrctremp = pr_nrctremp
         AND crapass.cdcooper = crawepr.cdcooper
         AND crapass.nrdconta = crawepr.nrdconta
         AND crapage.cdcooper = crapass.cdcooper
         AND crapage.cdagenci = crapass.cdagenci;
    rw_crawepr cr_crawepr%ROWTYPE;
    
    -- buscar bens da proposta
    CURSOR cr_crapbpr (pr_cdcooper  crawepr.cdcooper%TYPE,
                       pr_nrdconta  crawepr.nrdconta%TYPE,
                       pr_nrctremp  crawepr.nrctremp%TYPE) IS 
      SELECT t.dscatbem
        FROM crapbpr t
       WHERE t.cdcooper = pr_cdcooper
         AND t.nrdconta = pr_nrdconta
         AND t.nrctrpro = pr_nrctremp;
    rw_crapbpr cr_crapbpr%ROWTYPE;
    
    -- Cursor sobre o cadastro de linhas de credito (tela LCREDI)
    CURSOR cr_craplcr(pr_cdlcremp craplcr.cdlcremp%TYPE) IS
      SELECT dsoperac,
             dslcremp,
             tplcremp,
             tpdescto,
             decode(cdusolcr,2,0,cdusolcr) cdusolcr, -- Se for Epr/Boletos, considera como normal
             txminima,
             ROUND((POWER(1 + (txminima / 100),12) - 1) * 100,2) prjurano,
             perjurmo,
             dsorgrec,
             tpctrato,
             txjurfix,
             flgcobmu
        FROM craplcr
       WHERE cdcooper = pr_cdcooper
         AND cdlcremp = pr_cdlcremp;
    rw_craplcr cr_craplcr%ROWTYPE;--armazena informacoes do cursor cr_craplcr
    
    --Tipo de registro do tipo data
    rw_crapdat BTCH0001.cr_crapdat%ROWTYPE;
     
    -----------> VARIAVEIS <-----------
    -- Tratamento de erros
    vr_cdcritic NUMBER;
    vr_dscritic VARCHAR2(500);
    vr_exc_erro EXCEPTION;
    
    vr_dscatbem VARCHAR2(1000);
    vr_vlemprst NUMBER;
    vr_vlrdoiof NUMBER;
    vr_vlrtarif NUMBER;
    vr_vlrtares NUMBER;
    vr_vltarbem NUMBER;
    vr_vlpreclc NUMBER := 0;                -- Parcela calcula
    vr_vliofpri NUMBER;
    vr_vliofadi NUMBER;
    vr_flgimune PLS_INTEGER;
    
    vr_cdhisbem NUMBER := 0;                -- Hostorico do bem
    vr_cdhistor NUMBER := 0;                -- Historico
    vr_cdusolcr NUMBER := 0;                -- Uso linha de credito
    vr_cdfvlcop crapfco.cdfvlcop%TYPE;
    

      
  BEGIN
  
    --> Buscar dados do emprestimo
    OPEN  cr_crawepr (pr_cdcooper => pr_cdcooper,
                      pr_nrdconta => pr_nrdconta, 
                      pr_nrctremp => pr_nrctremp);
    FETCH cr_crawepr INTO rw_crawepr;
    
    IF cr_crawepr%FOUND THEN
      CLOSE cr_crawepr;
      vr_vlemprst := nvl(rw_crawepr.vlemprst,0);
    ELSE
      CLOSE cr_crawepr;
      vr_dscritic := 'Emprestimo '||nvl(pr_nrctremp,0) ||' nao encontrado para impressao'; --monta critica
      RAISE vr_exc_erro;
    END IF;
    
    -- Busca os dados do cadastro de linhas de credito
    OPEN cr_craplcr(rw_crawepr.cdlcremp);
    FETCH cr_craplcr INTO rw_craplcr;
    -- Se nao encontrar o emprestimo finaliza o programa
    IF cr_craplcr%NOTFOUND THEN
      vr_dscritic := 'Linha de credito nao encontrada para impressao'; -- monta critica
      CLOSE cr_craplcr;
      RAISE vr_exc_erro;
    END IF;
    CLOSE cr_craplcr;
            
    if rw_crawepr.idfiniof = 1 then
       vr_dscatbem := '';
       FOR rw_crapbpr IN cr_crapbpr (pr_cdcooper  => pr_cdcooper,
                                     pr_nrdconta  => pr_nrdconta,
                                     pr_nrctremp  => pr_nrctremp) LOOP
           vr_dscatbem := vr_dscatbem || '|' || rw_crapbpr.dscatbem;
       END LOOP;
              
       -- Buscar iof
       TIOF0001.pc_calcula_iof_epr( pr_cdcooper => pr_cdcooper
                                   ,pr_nrdconta => pr_nrdconta
                                   ,pr_nrctremp => pr_nrctremp
                                   ,pr_dtmvtolt => rw_crawepr.dtmvtolt
                                   ,pr_inpessoa => rw_crawepr.inpessoa
                                   ,pr_cdfinemp => rw_crawepr.cdfinemp
                                   ,pr_cdlcremp => rw_crawepr.cdlcremp
                                   ,pr_qtpreemp => rw_crawepr.qtpreemp
                                   ,pr_vlpreemp => rw_crawepr.vlpreemp
                                   ,pr_vlemprst => rw_crawepr.vlemprst
                                   ,pr_dtdpagto => rw_crawepr.dtdpagto
                                   ,pr_dtlibera => rw_crawepr.dtlibera
                                   ,pr_tpemprst => rw_crawepr.tpemprst
                                   ,pr_dtcarenc        => null
                                   ,pr_qtdias_carencia => null
                                   ,pr_valoriof => vr_vlrdoiof
                                   ,pr_dscatbem => vr_dscatbem
                                   ,pr_idfiniof => rw_crawepr.idfiniof
                                   ,pr_dsctrliq => rw_crawepr.dsctrliq
                                   ,pr_vlpreclc => vr_vlpreclc
                                   ,pr_vliofpri => vr_vliofpri
                                   ,pr_vliofadi => vr_vliofadi
                                   ,pr_flgimune => vr_flgimune
                                   ,pr_dscritic => vr_dscritic);
                                         
      -- VERIFICA SE OCORREU UMA CRITICA
      IF vr_dscritic IS NOT NULL THEN
        RAISE vr_exc_erro;
      END IF;
            
      -- Calcula tarifa
      TARI0001.pc_calcula_tarifa(pr_cdcooper => pr_cdcooper
                               , pr_nrdconta => pr_nrdconta
                               , pr_cdlcremp => rw_crawepr.cdlcremp
                               , pr_vlemprst => rw_crawepr.vlemprst
                               , pr_cdusolcr => rw_craplcr.cdusolcr 
                               , pr_tpctrato => rw_craplcr.tpctrato
                               , pr_dsbemgar => vr_dscatbem
                               , pr_cdprogra => 'RelCET'
                               , pr_flgemail => 'N'
                               , pr_vlrtarif => vr_vlrtarif
                               , pr_vltrfesp => vr_vlrtares
                               , pr_vltrfgar => vr_vltarbem
                               , pr_cdhistor => vr_cdhistor
                               , pr_cdfvlcop => vr_cdfvlcop
                               , pr_cdhisgar => vr_cdhistor
                               , pr_cdfvlgar => vr_cdfvlcop
                               , pr_cdcritic => vr_cdcritic
                               , pr_dscritic => vr_dscritic);
            
      if vr_dscritic is not null then
         raise vr_exc_erro;
      end if;
            
      vr_vlrtarif := ROUND(nvl(vr_vlrtarif,0),2) + nvl(vr_vlrtares,0) + nvl(vr_vltarbem,0);
                                               
      -- valor total emprestado
      pr_vlfinanc := nvl(rw_crawepr.vlemprst,0) + nvl(vr_vlrdoiof,0) + nvl(vr_vlrtarif,0);      
    ELSE
      pr_vlfinanc := nvl(rw_crawepr.vlemprst,0);
    END IF;
       
  EXCEPTION
    WHEN vr_exc_erro  THEN
      pr_cdcritic := vr_cdcritic;
      pr_dscritic := vr_dscritic;

    WHEN OTHERS THEN 
      pr_cdcritic := 0;
      pr_dscritic := 'Erro na pc_ret_valor_financiado: '||sqlerrm;
  END pc_ret_valor_financiado;    
  
END ESTE0002;
/
