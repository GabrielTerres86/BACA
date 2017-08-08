
/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+---------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL             |
  +------------------------------------------+---------------------------------+
  |  procedures/bo_algortimo_seguranca.p     | GENE0006                        |
  |     calcula_id                           | GENE0006.fn_calcula_id          |
  |     id_sessao                            | GENE0006.pc_id_sessao           |
  |     converte_hex                         | GENE0006.fn_converte_hex        |
  |     gera_protocolo                       | GENE0006.pc_gera_protocolo      |
  |     lista_protocolos                     | GENE0006.pc_lista_protocolos    |
  |     estorno_procotocolo                  | GENE0006.pc_estorno_protocolo   |
  +------------------------------------------+---------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/












/* .............................................................................

   Programa: sistema/generico/procedures/bo_algoritmo_seguranca.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Agosto/2006                   Ultima Atualizacao: 05/06/2017
   Dados referentes ao programa:

   Frequencia: Diario (internet)
   Objetivo  : Rotinas que auxiliam na seguranca das paginas da internet.

   Alteracoes: 25/06/2007 - Tratamento para pessoa juridica (David).
   
               13/09/2007 - Alimentar crappro.dttransa (Evandro).
               
               13/11/2007 - Incluida procedure lista_protocolos (Guilherme).
                          - Gerar protocolo para plano de capital (David).
                          
               28/04/2008 - Adicionado o estorno de protocoloes (Evandro).
                          - Adaptacao para agendamentos (David).       
                              
               31/07/2008 - Incluir parametro para geracao do protocolo (David).
               
               15/06/2010 - Incluido parametro "origem" na procedure 
                            lista_protocolos (Diego).
                            
               03/10/2011 - Incluir informacoes do TAA (Gabriel).  
                          - Adicionado campos nmprepo, nrcpfpre, nmoperad e 
                            nrcpfope em cratpro da procedure lista_protocolos 
                            (Jorge).
                            
               27/10/2011 - Parametros de operador na gera_protocolo 
                          - Melhoria, fazer a geração do protocolo em um
                            transaction para evitar duplicidade (Guilherme).
                            
               09/03/2012 - Alimentado os campos cdbcoctl e cdagectl,
                            da temp-table cratpro, na procedure 
                            lista_protocolos; somente se cdtippro = 2 ou 6.
                            (Fabricio)
                            
               08/05/2012 - Projeto TED Internet (David).
               
               10/12/2013 - Incluir VALIDATE crappro (Lucas R.).
               
               06/06/2014 - Ajustes referente ao projeto de captacao:
                            - Alterado a procedure pc_estorna_protocolo
                              para tratar o protocolos de aplicação.
                            (Adriano).
                            
                28/05/2015 - Alterada a origem do TAA na consulta de protocolos para 4.
						    (Dionathan)
                            
                09/07/2015 - Adição do tipo 1 (Transferencia) para receber as
                            informações de Banco/Agência Titular na lista_protocolos
                    
                19/05/2016 - Ajuste para exibir protocolos 15 - pagamento convenio
				             PRJ320 - Oferta DebAut (Odirlei-AMcom)
                     
                22/02/2017 - Alteraçoes para compor comprovantes DARF/DAS 
                             Modelo Sicredi (Lucas Lunelli)

				23/03/2017 - Adicionado tratamento para o protocolo 20 - Recarga
							 de celular. (PRJ321 - Reinert)

				24/03/2017 - Adicionado parametro na lista_protocolos para que posssa
                             ser filtrado por uma lista fixa de protocolos. PR354.1
                             (Dionathan)
							 
                30/05/2017 - Ajustado a chamada de procedures Oracle para gerar
                             o protocolo (Douglas - Chamado 663312)
			 
				05/06/2017 - Pesquisar comprovantes filtrando somente pela data 
				             da transação (David).
							 
............................................................................. */

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/bo_algoritmo_seguranca.i }
{ sistema/generico/includes/var_oracle.i   }

/* Rotina para gerar um codigo identificador de sessao para ser usado na
   validacao de parametros na URL */
FUNCTION calcula_id RETURN CHAR (INPUT par_dscampo1 AS CHAR,
                                 INPUT par_dscampo2 AS CHAR):
                                 
    DEF  VAR aux_contador AS INT                                      NO-UNDO.
    DEF  VAR aux_dsembara AS CHAR                                     NO-UNDO.
    DEF  VAR aux_dscampos AS CHAR                                     NO-UNDO.
    
    /* Intercala o KEY-CODE de cada caractere dos dois campos */
    DO aux_contador = 1 TO LENGTH(par_dscampo1):
    
       IF   aux_contador <= LENGTH(par_dscampo2)   THEN
            aux_dscampos = aux_dscampos + 
                           STRING(KEY-CODE(SUBSTRING(par_dscampo1,
                                           aux_contador,1))) + 
                           STRING(KEY-CODE(SUBSTRING(par_dscampo2,
                                           aux_contador,1))).
       ELSE
            aux_dscampos = aux_dscampos + 
                           STRING(KEY-CODE(SUBSTRING(par_dscampo1,
                                           aux_contador,1))).
    END.
    
    /* "Embaralha" os caracteres intercalados */
    DO aux_contador = 1 TO INT(LENGTH(aux_dscampos) / 2):
    
       aux_dsembara = aux_dsembara +
                      SUBSTRING(aux_dscampos,aux_contador,1).
                      
       IF   LENGTH(aux_dscampos) MOD 2 <> 0   THEN
            DO:
                IF   aux_contador <> INT(LENGTH(aux_dscampos) / 2)   THEN
                     aux_dsembara = aux_dsembara +
                                    SUBSTRING(aux_dscampos,
                                              LENGTH(aux_dscampos) + 1 -
                                              aux_contador,1).
            END.
       ELSE
            aux_dsembara = aux_dsembara +
                           SUBSTRING(aux_dscampos,LENGTH(aux_dscampos) + 1 -
                                     aux_contador,1).
    END.
    
    aux_dscampos = aux_dsembara.
    
    RETURN aux_dscampos.
                                        
END FUNCTION.


PROCEDURE id_sessao:

   DEF  INPUT  PARAM par_cdcooper LIKE crapttl.cdcooper              NO-UNDO.
   DEF  INPUT  PARAM par_nrdconta LIKE crapttl.nrdconta              NO-UNDO.
   DEF  INPUT  PARAM par_idseqttl LIKE crapttl.idseqttl              NO-UNDO.
   DEF  OUTPUT PARAM par_idsessio AS CHAR                            NO-UNDO.

   DEF  VAR aux_nmprimtl AS CHAR                                     NO-UNDO.
   DEF  VAR aux_nrdconta AS CHAR                                     NO-UNDO.

   FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                      crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                      
   IF   NOT AVAILABLE crapass   THEN
        RETURN "NOK".
        
   IF   crapass.inpessoa = 1   THEN
        DO:
            FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta AND
                               crapttl.idseqttl = par_idseqttl NO-LOCK NO-ERROR.
                   
            IF   NOT AVAILABLE crapttl   THEN
                 RETURN "NOK".
            
            ASSIGN aux_nmprimtl = ENTRY(1,crapttl.nmextttl," ").
        END.
   ELSE
        aux_nmprimtl = ENTRY(1,crapass.nmprimtl," ").
                           
   ASSIGN aux_nrdconta = STRING(par_cdcooper) + STRING(par_idseqttl) +
                         STRING(par_nrdconta).
       
   IF   LENGTH(aux_nmprimtl) > LENGTH(aux_nrdconta)   THEN
        par_idsessio = calcula_id(aux_nmprimtl, aux_nrdconta).
   ELSE
        par_idsessio = calcula_id(aux_nrdconta, aux_nmprimtl).
        
   RETURN "OK".        
        
END PROCEDURE.


FUNCTION converte_hex RETURNS CHARACTER (INPUT par_vlconver AS CHARACTER).

    /* Funcao que recebe um numero (em char) e devolve o mesmo numero em
       hexadecimal (em char tambem) */
    
    DEF   VAR aux_vldresto   AS INTEGER                             NO-UNDO.
    DEF   VAR aux_vlemhexa   AS CHAR                                NO-UNDO.

    DO WHILE TRUE:
    
       ASSIGN aux_vldresto = INTEGER(par_vlconver) MODULO 16
              aux_vlemhexa = (IF aux_vldresto < 10 THEN
                                 STRING(aux_vldresto)
                              ELSE CHR(ASC("A") + aux_vldresto - 10)) +
                              aux_vlemhexa.

       IF   INTEGER(par_vlconver) < 16   THEN
            LEAVE.

       par_vlconver = STRING((INTEGER(par_vlconver) - aux_vldresto) / 16).
   END.

   IF   LENGTH(aux_vlemhexa) < 2   THEN
        aux_vlemhexa = "0" + aux_vlemhexa.
   
   RETURN (aux_vlemhexa).
   
END FUNCTION.

PROCEDURE gera_protocolo:

    /* Recebe os parametros e gera um protocolo unico em hexadecimal
    
       Observacao: Os parametros sao convertido para numeros, multiplicados 
                   pela variavel "aux_multipli" e depois somados.
                   Sao adicionados alguns campos sem multiplicacao para serem
                   identificadores unicos. Apos isto sao transformados em
                   hexadecimal de 2 em 2 caracteres.                   
                   Quando o parametro par_gravapro for igual a YES/TRUE, sera
                   gravado um registro na tabela crappro. */


    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt              NO-UNDO.
    DEF  INPUT PARAM par_hrtransa LIKE craplcm.hrtransa              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta              NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto LIKE craplcm.nrdocmto              NO-UNDO.
    DEF  INPUT PARAM par_nrseqaut LIKE crapaut.nrseqaut              NO-UNDO.
    DEF  INPUT PARAM par_vllanmto LIKE craplcm.vllanmto              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa LIKE crapaut.nrdcaixa              NO-UNDO.
    DEF  INPUT PARAM par_gravapro AS LOGI                            NO-UNDO.
    DEF  INPUT PARAM par_cdtippro LIKE crappro.cdtippro              NO-UNDO.
    DEF  INPUT PARAM par_dsinfor1 AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dsinfor2 AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dsinfor3 AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dscedent AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_flgagend AS LOGI                            NO-UNDO.

    DEF  INPUT PARAM par_nrcpfope AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_nrcpfpre AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_nmprepos AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM par_dsprotoc LIKE crappro.dsprotoc              NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                            NO-UNDO.

    DEF VAR          aux_des_erro AS CHAR                            NO-UNDO.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
   
    /* GENE0006 */
    RUN STORED-PROCEDURE pc_gera_protocolo_car aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_cdcooper, /* Código da cooperativa */
                          INPUT par_dtmvtolt, /* Data movimento */
                          INPUT par_hrtransa, /* Hora da Transacao */
                          INPUT par_nrdconta, /* Numero da Conta */  
                          INPUT par_nrdocmto, /* Número do documento */ 
                          INPUT par_nrseqaut, /* Número da sequencia */ 
                          INPUT par_vllanmto, /* Valor lançamento */ 
                          INPUT par_nrdcaixa, /* Número do caixa */ 
                          INPUT INTE(STRING(par_gravapro,"1/0")), /* Controle de gravaçao (0-Nao/1-Sim)*/
                          INPUT par_cdtippro, /* Código de operaçao */ 
                          INPUT par_dsinfor1, /* Descriçao 1 */
                          INPUT par_dsinfor2, /* Descriçao 2 */
                          INPUT par_dsinfor3, /* Descriçao 3 */
                          INPUT par_dscedent, /* Descritivo */ 
                          INPUT INTE(STRING(par_flgagend,"1/0")), /* Controle de agenda (0-Nao/1-Sim) */
                          INPUT par_nrcpfope, /* Número de operaçao */
                          INPUT par_nrcpfpre, /* Número pré operaçao */
                          INPUT par_nmprepos, /* Nome */
                         OUTPUT "",  /* pr_dsprotoc */
                         OUTPUT "",  /* pr_dscritic */
                         OUTPUT ""). /* pr_des_erro */
    
    CLOSE STORED-PROC pc_gera_protocolo_car aux_statproc = PROC-STATUS
          WHERE PROC-HANDLE = aux_handproc.

    ASSIGN par_dsprotoc = ""
           par_dscritic = ""
           aux_des_erro = ""
           par_dsprotoc = pc_gera_protocolo_car.pr_dsprotoc
                          WHEN pc_gera_protocolo_car.pr_dsprotoc <> ?
           par_dscritic = pc_gera_protocolo_car.pr_dscritic
                          WHEN pc_gera_protocolo_car.pr_dscritic <> ?
           aux_des_erro = pc_gera_protocolo_car.pr_des_erro
                          WHEN pc_gera_protocolo_car.pr_des_erro <> ?.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    RETURN aux_des_erro.

END PROCEDURE. /* Fim gera_protocolo */

PROCEDURE lista_protocolos:

    DEF INPUT  PARAM par_cdcooper LIKE crappro.cdcooper             NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE crappro.nrdconta             NO-UNDO.
    DEF INPUT  PARAM par_dtinipro LIKE crappro.dtmvtolt             NO-UNDO.
    DEF INPUT  PARAM par_dtfimpro LIKE crappro.dtmvtolt             NO-UNDO.
    DEF INPUT  PARAM par_dsprotoc AS CHAR                           NO-UNDO.
    DEF INPUT  PARAM par_iniconta AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF INPUT  PARAM par_cdtippro AS INTE                           NO-UNDO.

    /*par_cdorigem -> 1-ayllos, 3-internet, 4-TAA*/
    DEF INPUT  PARAM par_cdorigem AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_dstransa AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dscritic LIKE crapcri.dscritic             NO-UNDO.
    DEF OUTPUT PARAM par_qttotreg AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR cratpro.

    DEF VAR aux_nmoperad LIKE crapopi.nmoperad                      NO-UNDO.
    DEF VAR aux_splitqtd AS INTEGER                                 NO-UNDO.
    DEF VAR aux_splititm AS INTEGER                                 NO-UNDO.
    DEF VAR aux_dsprotoc AS CHAR                                    NO-UNDO.

    /**********************************************************************/
    /** Parametros para Internet: dtinipro, dtfimpro, iniconta, nrregist **/
    /** ---------------------------------------------------------------- **/
    /** dtinipro -> para consultar determinado periodo (inicio)          **/
    /**             fora da internet passar parametro com valor "?"      **/
    /** dtfimpro -> para consultar determinado periodo (fim)             **/
    /**             fora da internet passar parametro com valor "?"      **/
    /** iniconta -> a partir do registro nr X, gravar na TEMP-TABLE      **/
    /**             fora da internet passar parametro com valor "0"      **/
    /** nrregist -> nr de registros que devem ser gravados na TEMP-TABLE **/
    /**             fora da internet passar parametro com valor "0"      **/
    /**********************************************************************/

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop  THEN
        RETURN "NOK".
    
    ASSIGN par_dstransa = "Listagem de Protocolos"
           par_dtinipro = IF  par_dtinipro = ?  THEN 
                              06/15/2007 
                          ELSE 
                              par_dtinipro
           par_dtfimpro = IF  par_dtfimpro = ?  THEN 
                              aux_datdodia 
                          ELSE 
                              par_dtfimpro
           par_qttotreg = 0.
               
    /*Validaçao removida em 31/08/2016 - PRJ386.5 - CECRED MOBILE (Dionathan)
    IF  par_dtfimpro > aux_datdodia  THEN
        ASSIGN par_dtfimpro = aux_datdodia.*/
                  
    FIND FIRST crapdat
	     WHERE crapdat.cdcooper = par_cdcooper
		 NO-LOCK NO-ERROR.

    EMPTY TEMP-TABLE cratpro.

    IF par_dsprotoc <> "" THEN
    DO:
      ASSIGN aux_splitqtd = NUM-ENTRIES(par_dsprotoc,";").
      
      DO aux_splititm = 1 TO aux_splitqtd:
        aux_dsprotoc = ENTRY(aux_splititm,par_dsprotoc,";").
        
        FIND FIRST crappro
             WHERE crappro.cdcooper = par_cdcooper  AND
                   crappro.dsprotoc = aux_dsprotoc NO-LOCK.
        
        /* Registra os dados do associado */
        RUN lista_protocolo
            (INPUT par_cdcooper,
             INPUT par_nrdconta,
             INPUT par_cdorigem,

             BUFFER crappro,
             
             INPUT-OUTPUT par_iniconta,
             INPUT-OUTPUT par_nrregist,
             INPUT-OUTPUT par_qttotreg,
             INPUT-OUTPUT TABLE cratpro,

             OUTPUT par_dscritic
            ).
      END.
    END.
    ELSE
    FOR EACH crappro WHERE crappro.cdcooper  = par_cdcooper  AND
                           crappro.nrdconta  = par_nrdconta  AND                           
                           crappro.dttransa >= par_dtinipro  AND
                           crappro.dttransa <= par_dtfimpro  AND
                          (par_cdtippro      = 0             OR
                           crappro.cdtippro  = par_cdtippro) NO-LOCK
                           BY crappro.dttransa DESC BY crappro.hrautent DESC:

        IF  par_cdorigem = 3  AND 
           (crappro.cdtippro = 5 OR crappro.cdtippro = 6)  THEN /* TAA */
            NEXT.

        IF  par_cdtippro <> 8     AND 
            crappro.cdtippro = 8  THEN /** Protocolo Favorecido **/
            NEXT.
                           
          /* Registra os dados do associado */
          RUN lista_protocolo
              (INPUT par_cdcooper,
               INPUT par_nrdconta,
               INPUT par_cdorigem,

               BUFFER crappro,

               INPUT-OUTPUT par_iniconta,
               INPUT-OUTPUT par_nrregist,
               INPUT-OUTPUT par_qttotreg,
               INPUT-OUTPUT TABLE cratpro,

               OUTPUT par_dscritic
              ).
      END.
    
    RETURN "OK".
 
END PROCEDURE.

PROCEDURE lista_protocolo:

    DEF INPUT  PARAM par_cdcooper LIKE crappro.cdcooper             NO-UNDO.
    DEF INPUT  PARAM par_nrdconta LIKE crappro.nrdconta             NO-UNDO.
    /*par_cdorigem -> 1-ayllos, 3-internet, 4-TAA*/
    DEF INPUT  PARAM par_cdorigem AS INTE                           NO-UNDO.
    
    DEF PARAM BUFFER crabpro FOR crappro.
    
    DEF INPUT-OUTPUT  PARAM par_iniconta AS INTE                    NO-UNDO.
    DEF INPUT-OUTPUT  PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT-OUTPUT  PARAM par_qttotreg AS INTE                    NO-UNDO.
    DEF INPUT-OUTPUT  PARAM TABLE FOR cratpro.

    DEF OUTPUT PARAM par_dscritic LIKE crapcri.dscritic             NO-UNDO.
    

    DEF VAR aux_nmoperad LIKE crapopi.nmoperad                      NO-UNDO.

        /** Nao carregar Protocolo pagamento fatura 
    caso seja o dia de geracao, devido o pagamento
    ainda poder ser estornado. **/
    IF crabpro.cdtippro = 15  AND
      crabpro.dtmvtolt = crapdat.dtmvtolt THEN 
		   NEXT.
                           
        ASSIGN par_qttotreg = par_qttotreg + 1.
        
        IF  par_nrregist > 0                              AND 
           (par_qttotreg <= par_iniconta                  OR
            par_nrregist < (par_qttotreg - par_iniconta)) THEN
            NEXT.
        
        IF par_cdorigem = 3 AND /* InternetBank */
       crabpro.cdtippro = 1 AND
       SUBSTR(crabpro.dsinform[3],1,3) = "TAA" THEN
           NEXT.
        
        IF par_cdorigem = 4 AND /* TAA */
       crabpro.cdtippro = 1 AND
       SUBSTR(crabpro.dsinform[3],1,3) <> "TAA" THEN
           NEXT.

        IF par_cdorigem = 3 AND /* InternetBank */
           crabpro.cdtippro = 20 AND
           SUBSTR(crabpro.dsinform[3],1,3) = "TAA" THEN
           NEXT.
        IF par_cdorigem = 4 AND /* TAA */
           crabpro.cdtippro = 20 AND
           SUBSTR(crabpro.dsinform[3],1,3) <> "TAA" THEN
           NEXT.           
               
        ASSIGN aux_nmoperad = "".
        FIND FIRST crapopi WHERE crapopi.cdcooper = par_cdcooper 
                             AND crapopi.nrdconta = par_nrdconta
                         AND crapopi.nrcpfope = crabpro.nrcpfope
                             NO-LOCK NO-ERROR.
        IF  AVAIL crapopi  THEN
            ASSIGN aux_nmoperad = crapopi.nmoperad.

        /** Se incluir novo campo para protocolo de TED, verificar a procedure
            executa-envio-ted na BO b1wgen0015, onde o protocolo criado eh
            retornado para o InternetBank sem passar por aqui **/
        CREATE cratpro.
    ASSIGN cratpro.cdtippro    = crabpro.cdtippro
           cratpro.dtmvtolt    = crabpro.dtmvtolt
           cratpro.dttransa    = crabpro.dttransa
           cratpro.hrautent    = crabpro.hrautent
           cratpro.vldocmto    = crabpro.vldocmto
           cratpro.nrdocmto    = crabpro.nrdocmto
           cratpro.nrseqaut    = crabpro.nrseqaut
           cratpro.dsinform[1] = crabpro.dsinform[1]
           cratpro.dsinform[2] = crabpro.dsinform[2]
           cratpro.dsinform[3] = crabpro.dsinform[3]
           cratpro.dsprotoc    = crabpro.dsprotoc
           cratpro.flgagend    = crabpro.flgagend
           cratpro.nmprepos    = crabpro.nmprepos
           cratpro.nrcpfpre    = crabpro.nrcpfpre
               cratpro.nmoperad    = aux_nmoperad
               cratpro.nrcpfope    = crabpro.nrcpfope
               cratpro.cdbcoctl    = crapcop.cdbcoctl WHEN (crabpro.cdtippro = 1 AND par_cdorigem = 3)
                                                        OR crabpro.cdtippro = 2
                                                        OR crabpro.cdtippro = 6
                                                        OR crabpro.cdtippro = 9
                                                        OR crabpro.cdtippro = 11
                                                        OR crabpro.cdtippro = 15
                                                        OR crabpro.cdtippro = 16
                                                        OR crabpro.cdtippro = 17
                                                        OR crabpro.cdtippro = 18
                                                        OR crabpro.cdtippro = 19
														OR crabpro.cdtippro = 20
               cratpro.cdagectl    = crapcop.cdagectl WHEN (crabpro.cdtippro = 1 AND par_cdorigem = 3)
                                                        OR crabpro.cdtippro = 2
                                                        OR crabpro.cdtippro = 6
                                                        OR crabpro.cdtippro = 9
                                                        OR crabpro.cdtippro = 11
                                                        OR crabpro.cdtippro = 15
                                                        OR crabpro.cdtippro = 16
                                                        OR crabpro.cdtippro = 17
                                                        OR crabpro.cdtippro = 18
                                                        OR crabpro.cdtippro = 19
														OR crabpro.cdtippro = 20
               cratpro.cdagesic    = crapcop.cdagesic.

        IF   par_cdorigem = 4   THEN /* TAA */
             DO:
                 /* Transferencia */
                 IF   cratpro.cdtippro = 1   THEN
                      ASSIGN cratpro.dscedent  = 
                     SUBSTR(ENTRY(2,crabpro.dsinform[2],"#"),19) NO-ERROR.
                 ELSE
                 IF   cratpro.cdtippro = 20   THEN
                      ASSIGN cratpro.dscedent = IF   crabpro.dscedent = ""   THEN 
                                                     ENTRY(2,cratpro.dsinform[2],"#") + " - " + 
                                                     ENTRY(1,cratpro.dsinform[2],"#") /* Telefone - Operadora */
                                                ELSE
                                                     crabpro.dscedent.  
                 ELSE
                      ASSIGN cratpro.dscedent = IF   crabpro.dscedent = ""   THEN 
                                                     "PAGAMENTO TAA"
                                                ELSE
                                                 crabpro.dscedent.  
                                                                 
             END.
        ELSE
             DO:
             ASSIGN cratpro.dscedent = crabpro.dscedent.
    END.

    RETURN "OK".
 
END PROCEDURE.


PROCEDURE estorna_protocolo:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper              NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt              NO-UNDO.
    DEF  INPUT PARAM par_nrdconta LIKE crapass.nrdconta              NO-UNDO.
    DEF  INPUT PARAM par_cdtippro LIKE crappro.cdtippro              NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto LIKE craplcm.nrdocmto              NO-UNDO.
    DEF  INPUT PARAM par_cdoperad LIKE crapope.cdoperad              NO-UNDO.
    DEF OUTPUT PARAM par_dsprotoc LIKE crappro.dsprotoc              NO-UNDO.
    
    /*Aplicacao*/
    IF par_cdtippro = 10 THEN
       DO:
          FIND crappro WHERE crappro.cdcooper = par_cdcooper   AND
                             crappro.nrdconta = par_nrdconta   AND
                             crappro.dtmvtolt = par_dtmvtolt   AND
                             crappro.cdtippro = par_cdtippro   AND
                             crappro.nrdocmto = par_nrdocmto   AND
                             crappro.flgativo = 1 /*Ativo*/
                             EXCLUSIVE-LOCK NO-ERROR.
                             
          IF NOT AVAILABLE crappro THEN
             RETURN "NOK".
               
          ASSIGN par_dsprotoc     = crappro.dsprotoc
                                                     
                 crappro.dsprotoc = crappro.dsprotoc                  + " " +
                                    "*** CANCELADO ("                 +
                                    STRING(par_dtmvtolt,"99/99/9999") + " - " +
                                    STRING(TIME,"HH:MM:SS")           + ")"
                 crappro.flgativo = 0.
       END.
    ELSE
      DO:
         FIND crappro WHERE crappro.cdcooper = par_cdcooper   AND
                            crappro.nrdconta = par_nrdconta   AND
                            crappro.dtmvtolt = par_dtmvtolt   AND
                            crappro.cdtippro = par_cdtippro   AND
                            crappro.nrdocmto = par_nrdocmto
                            EXCLUSIVE-LOCK NO-ERROR.
                            
         IF   NOT AVAILABLE crappro   THEN
              RETURN "NOK".
              
         ASSIGN par_dsprotoc     = crappro.dsprotoc
                                                    
                crappro.dsprotoc = crappro.dsprotoc                  + " " +
                                   "*** ESTORNADO ("                 +
                                   STRING(par_dtmvtolt,"99/99/9999") + " - " +
                                   STRING(TIME,"HH:MM:SS")           + ")".

      END.

    RETURN "OK".
             
END PROCEDURE. /* Fim estorna_protocolo */

/*............................................................................*/

