/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL                     |
  +---------------------------------+-----------------------------------------+
  | procedures/b1wgen0082.p         |                                         |
  |   verifica-cadastro-ativo       | COBR0001.fn_verif_ceb_ativo             |
  |                                 |                                         |
  |                                 |                                         |  
  +---------------------------------+-----------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - DANIEL ZIMMERMANN    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/


/*............................................................................

  Programa: b1wgen0082.p
  Autor   : Gabriel
  Data    : 08/12/2010                        Ultima Alteracao: 20/02/2019
  
  Dados referentes ao programa:
  
  Objetivo: BO referente a rotina COBRANCA da tela ATENDA.
  
  Alteracoes: 19/05/2011 - Tratar se eh cobranca registrada (Guilherme).
  
              29/06/2011 - Criticas operadores - Temporaria (Gabriel).
              
              21/07/2011 - Impressao para a Cobranca Registrada (Gabriel). 
              
              16/08/2011 - Liberar a cobranca registrada para a Viacredi
                           (Gabriel). 
                           
              18/08/2011 - Liberar a cobranca registrada para todas as 
                           cooperativas (Gabriel)   
                           
              22/08/2011 - Inclusao do campo tt-cadastro-bloqueto.dsorgban na
                           procedure carrega-convenios-ceb (Adriano). 
                           
              04/11/2011 - Aumentar o formato do vllbolet (Gabriel).

              21/03/2012 - Modificado a forma de gravacao de log quanto a
                           inclusao de convenios (Tiago).
                           
              07/12/2012 - Alterado relatorio termo adesao cobrança registrada
                           (David Kruger).        
                           
              13/02/2013 - Nao permitir cadastrar convenio de cobranca ao 
                           cooperado com CEB > 9999 (Rafael).
                           
              18/02/2013 - Nao permitir habilitar/ativar dois convenios 
                           INTERNET do mesmo banco para o mesmo cooperado. 
                           (Rafael).
                           
              12/03/2013 - Incluido a chamada da procedure alerta_fraude
                           na procedure habilita-convenio (Adriano).
                           
              10/05/2013 - Retirado verificacao de vlr maximo do boleto,
                           campo vllboleto em proc. valida-dados-limites e
                           habilita-convenio. 
                         - Deletado proc. valida-dados-titulares-limites.(Jorge)
                         
              05/06/2013 - Projeto Melhorias da Cobranca - adaptar nova opcao
                           de recebimento de arq. de retorno CNAB400. (Rafael)
                           
              03/07/2013 - Nao permitir habilitar/ativar dois convenios 
                           INTERNET da "cobranca sem registro" para o mesmo 
                           cooperado (Rafael).
                           
              19/09/2013 - Inclusao do parametro flgcebhm, procedure
                           habilita-convenio (Carlos)
                           
              10/02/2014 - Inserido novo paragrafo no CONTRATO/TERMO DE ADESAO 
                           AO SISTEMA DE COBRANCA REGISTRADA (Tiago).
                           
              05/03/2014 - Incluso VALIDATE (Daniel).

              09/05/2014 - Incluido regra para nao permitir ativar um convenio 
                           sem registro do BB inativo. (Rafael)
                           
              06/08/2014 - Alterar 3o parágrafo do termo de adesao da cobrança 
                           com registro, levando em consideraçao o “float” do 
                           convenio da cobrança ( Renato - Supero ) 
              
              29/08/2014 - Permitir a reativação de convênios de cobrança sem 
                           registro (Renato - Supero - SD 194301  )
                           
              09/10/2014 - Alterado a procedure habilita-convenio para quando for 
                           usuario da CECRED, não alterar o campo crapceb.cdoperad
                           e gravar no campo crapceb.cdhomolo 
                           (Douglas - Chamado 121479)
                           
              27/10/2014 - Alterado a procedure habilita-convenio para gravar a 
                           alteração do campo crapceb.cdhomolo na VERLOG
                           (Douglas - Chamado 121479)
             
              02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                           Cedente por Beneficiário e  Sacado por Pagador 
                           Chamado 229313 (Jean Reddiga - RKAM).    
                           
              28/04/2015 - Ajustes referente ao projeto DP 219 - Cooperativa
                           emite e expede. (Reinert)
                           
              29/05/2015 - Ajustes referente ao projeto DP 219 - Cooperativa
                           emite e expede. (Daniel)             

              10/08/2015 - Ajuste na valida-habilitacao para não permitir 
                           selecionar convenios inativos. 
                           (Douglas - Chamado 316261)
                           
              03/11/2015 - Ajustes referente Projeto de Assinatura Multipla.
                          (Daniel)             

              23/11/2015 - Inclusao do indicador de negativacao pelo Serasa.
                           (Jaison/Andrino)

              23/02/2016 - Alterado para buscar o campo qtdfloat da tabela crapcco 
                           para a tabela crapceb. Projeto 213 - Reciprocidade (Lombardi)

              07/04/2016 - PRJ 213 - Reciprocidade. (Jaison/Marcos)

              17/06/2016 - Inclusão de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)

			  04/08/2016 - Alterado rotina carrega-convenios-ceb para trazer a 
						   forma de envio de arquivo de cobranca na tt. (Reinert)

              13/12/2016 - PRJ340 - Nova Plataforma de Cobranca - Fase II. (Jaison/Cechet)

			  20/02/2019 - Novo campo Homologado API (Andrey Formigari - Supero)

.............................................................................*/

{ sistema/generico/includes/var_internet.i }    
{ sistema/generico/includes/gera_log.i  }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/b1wgen0082tt.i }

DEF STREAM str_1.                                                    

DEF VAR aux_cdcritic AS INTE                                         NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                         NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                         NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                         NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                        NO-UNDO.

DEF VAR h-b1wgen0059 AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                       NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                         NO-UNDO.
DEF VAR par_loginusr AS CHAR                                         NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                         NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                         NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                         NO-UNDO.
DEF VAR par_numipusr AS CHAR                                         NO-UNDO.

DEF NEW SHARED VAR glb_nrcalcul AS DECI                          NO-UNDO.
DEF NEW SHARED VAR glb_stsnrcal AS LOGI                          NO-UNDO.

/****************************************************************************
 Funcao que retorna se o Cooperado possui cadastro de emissao bloqueto ativo 
****************************************************************************/
FUNCTION verifica-cadastro-ativo RETURNS LOGICAL (INPUT par_cdcooper AS INTE,
                                                  INPUT par_nrdconta AS INTE):

    FIND FIRST crapceb WHERE crapceb.cdcooper = par_cdcooper   AND
                             crapceb.nrdconta = par_nrdconta   AND
                             crapceb.insitceb = 1
                             NO-LOCK NO-ERROR.

    RETURN AVAIL(crapceb).

END FUNCTION.


/****************************************************************************
 Procedure que traz os convenios CEB do cooperado.
****************************************************************************/
PROCEDURE carrega-convenios-ceb:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.

    DEF OUTPUT PARAM par_dsdmesag AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-cadastro-bloqueto. 
    DEF OUTPUT PARAM TABLE FOR tt-crapcco.
    DEF OUTPUT PARAM TABLE FOR tt-titulares.       
    DEF OUTPUT PARAM TABLE FOR tt-emails-titular.

    DEF VAR          aux_dtcadast AS DATE                            NO-UNDO.
	DEF VAR          aux_qtregist AS INTE                            NO-UNDO.


    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Carregar a rotina de cobranca.".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
           
    EMPTY TEMP-TABLE tt-cadastro-bloqueto.
    
    EMPTY TEMP-TABLE tt-emails-titular.

    FIND FIRST crapprm WHERE crapprm.nmsistem = 'CRED' AND
                             crapprm.cdacesso = 'DT_VIG_RECECIPR_V2' AND
                             crapprm.cdcooper = par_cdcooper
                             NO-LOCK NO-ERROR.
    IF AVAIL crapprm THEN
    DO:
      ASSIGN aux_dtcadast = DATE(crapprm.dsvlrprm).
    END.
	
	FIND FIRST crapprm WHERE crapprm.nmsistem = 'CRED' AND
                           crapprm.cdcooper = par_cdcooper AND
                           crapprm.cdacesso = 'RECIPROCIDADE_PILOTO' AND
							             crapprm.dsvlrprm = '1'
                           NO-LOCK NO-ERROR.
    IF NOT AVAIL crapprm THEN
    DO:
      ASSIGN aux_dtcadast = NOW.
    END.

    /* Trazer os convenios CEB */
    FOR EACH crapceb  WHERE crapceb.cdcooper = par_cdcooper     AND
                            crapceb.nrdconta = par_nrdconta    AND
                            (crapceb.dtinsori <= aux_dtcadast OR crapceb.dtinsori = ?)  NO-LOCK,
                            
                                                                  
        FIRST crapcco WHERE crapcco.cdcooper = crapceb.cdcooper AND
                            crapcco.nrconven = crapceb.nrconven NO-LOCK,
        
        FIRST crapope WHERE crapope.cdcooper = crapceb.cdcooper AND
                            crapope.cdoperad = crapceb.cdoperad NO-LOCK:

        IF   crapceb.cddemail > 0   THEN
             FIND crapcem WHERE crapcem.cdcooper = crapceb.cdcooper   AND
                                crapcem.nrdconta = crapceb.nrdconta   AND
                                crapcem.idseqttl = 1                  AND
                                crapcem.cddemail = crapceb.cddemail
                                NO-LOCK NO-ERROR.

        FIND FIRST crapass 
             WHERE crapass.cdcooper = par_cdcooper
               AND crapass.nrdconta = par_nrdconta 
               NO-LOCK NO-ERROR.

        IF AVAIL crapass THEN
        DO:
            
            IF crapass.idastcjt = 0 THEN
            DO:
            
        FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper    AND
                                 crapsnh.nrdconta = par_nrdconta    AND
                                 crapsnh.idseqttl = 1               AND
                                 crapsnh.tpdsenha = 1                      
                                 NO-LOCK USE-INDEX crapsnh1 NO-ERROR.
            END.
            ELSE
            DO:
                FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper    AND
                                         crapsnh.nrdconta = par_nrdconta    AND
                                         crapsnh.tpdsenha = 1                      
                                         NO-LOCK USE-INDEX crapsnh1 NO-ERROR.
            END.

        CREATE tt-cadastro-bloqueto.
        ASSIGN tt-cadastro-bloqueto.nrconven = crapceb.nrconven
               tt-cadastro-bloqueto.nrcnvceb = crapceb.nrcnvceb
               tt-cadastro-bloqueto.insitceb = crapceb.insitceb
               tt-cadastro-bloqueto.dtcadast = crapceb.dtcadast
               tt-cadastro-bloqueto.inarqcbr = crapceb.inarqcbr
               tt-cadastro-bloqueto.flgcruni = crapceb.flgcruni
               tt-cadastro-bloqueto.flgcebhm = crapceb.flgcebhm
               tt-cadastro-bloqueto.dssitceb = (crapceb.insitceb = 1)
               tt-cadastro-bloqueto.dsorgarq = crapcco.dsorgarq 
               tt-cadastro-bloqueto.flgativo = crapcco.flgativo 
               tt-cadastro-bloqueto.flgregis = crapcco.flgregis
               tt-cadastro-bloqueto.cdoperad = crapceb.cdoperad + " - " + 
                                               crapope.nmoperad
               tt-cadastro-bloqueto.dsorgban = crapcco.dsorgarq + " " + 
                                               STRING(crapcco.cddbanco,"999")
               tt-cadastro-bloqueto.flgregon = crapceb.flgregon 
               tt-cadastro-bloqueto.flgpgdiv = crapceb.flgpgdiv
               tt-cadastro-bloqueto.flcooexp = crapceb.flcooexp 
               tt-cadastro-bloqueto.flceeexp = crapceb.flceeexp
               tt-cadastro-bloqueto.cddbanco = crapcco.cddbanco
                   tt-cadastro-bloqueto.flserasa = crapceb.flserasa
               tt-cadastro-bloqueto.flsercco = INT(crapcco.flserasa)
               tt-cadastro-bloqueto.qtdfloat = crapceb.qtdfloat 
               tt-cadastro-bloqueto.flprotes = crapceb.flprotes
			   tt-cadastro-bloqueto.qtlimaxp = crapceb.qtlimaxp
			   tt-cadastro-bloqueto.qtlimmip = crapceb.qtlimmip
               tt-cadastro-bloqueto.qtdecprz = crapceb.qtdecprz
               tt-cadastro-bloqueto.idrecipr = crapceb.idrecipr
               tt-cadastro-bloqueto.inenvcob = crapceb.inenvcob
			   tt-cadastro-bloqueto.flgapihm = crapceb.flgapihm.

        IF   AVAIL crapcem   AND   crapceb.cddemail > 0  THEN
             ASSIGN tt-cadastro-bloqueto.cddemail = crapcem.cddemail
                    tt-cadastro-bloqueto.dsdemail = crapcem.dsdemail.

        IF   NOT AVAIL crapsnh THEN
             ASSIGN par_dsdmesag = "O acesso a Internet nao esta ativo. " +
                                   "Verifique a rotina INTERNET.".         
        END.
        ELSE
        DO:
            ASSIGN par_dsdmesag = "Associado nao cadastrado.".
        END.
                                                                                  
    END.

    /* Se nao criou nenhum registro, verifica mensagem */
    IF   NOT TEMP-TABLE tt-cadastro-bloqueto:HAS-RECORDS   THEN
         DO:

             FIND FIRST crapass 
                  WHERE crapass.cdcooper = par_cdcooper
                    AND crapass.nrdconta = par_nrdconta 
                    NO-LOCK NO-ERROR.

             IF AVAIL(crapass) THEN
             DO:
             
                 IF crapass.idastcjt = 0 THEN
                 DO:
             FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper    AND
                                      crapsnh.nrdconta = par_nrdconta    AND
                                      crapsnh.idseqttl = 1               AND
                                      crapsnh.tpdsenha = 1                      
                                      NO-LOCK USE-INDEX crapsnh1 NO-ERROR.

             IF   NOT AVAIL crapsnh  OR 
                  crapsnh.cdsitsnh <> 1   THEN
                  ASSIGN par_dsdmesag =
                             "O acesso a Internet nao esta ativo. " +
                             "Verifique a rotina INTERNET.".
         END.
                 ELSE
                 DO:
                    FIND FIRST crapsnh WHERE crapsnh.cdcooper = par_cdcooper    AND
                                             crapsnh.nrdconta = par_nrdconta    AND
                                             crapsnh.tpdsenha = 1               AND
                                             crapsnh.cdsitsnh = 1
                                             NO-LOCK USE-INDEX crapsnh1 NO-ERROR.

                     IF NOT AVAIL crapsnh THEN
                          ASSIGN par_dsdmesag =
                                     "O acesso a Internet nao esta ativo. " +
                                     "Verifique a rotina INTERNET.".
                 END.
             END.
             ELSE
             DO:
                ASSIGN par_dsdmesag = "Associado nao cadastrado.".
             END.
         END.

    /* Se for Ayllos caracter */
    IF   par_idorigem = 1   THEN
         DO:
             /* Conectar ao generico */
             RUN sistema/generico/procedures/b1wgen9999.p 
                                  PERSISTENT SET h-b1wgen9999.

             RUN p-conectagener IN h-b1wgen9999.

             RUN sistema/generico/procedures/b1wgen0059.p
                                  PERSISTENT SET h-b1wgen0059.
    
             RUN busca-crapcco IN h-b1wgen0059
                               (INPUT par_cdcooper,
                                INPUT 0,  /* Todos */
                                INPUT "", /* Todos */
                               OUTPUT aux_qtregist,
                               OUTPUT TABLE tt-crapcco).

             DELETE PROCEDURE h-b1wgen0059.

             RUN p-desconectagener IN h-b1wgen9999.

             DELETE PROCEDURE h-b1wgen9999.

         END. 

    RUN valores-max-titulares (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                              OUTPUT TABLE tt-titulares).
                          
    FOR EACH crapcem WHERE crapcem.cdcooper = par_cdcooper   AND
                           crapcem.nrdconta = par_nrdconta   AND
                           crapcem.idseqttl = 1              NO-LOCK:
 
        CREATE tt-emails-titular.
        ASSIGN tt-emails-titular.cddemail = crapcem.cddemail
               tt-emails-titular.dsdemail = crapcem.dsdemail.
         
    END. /** Fim do FOR EACH crapcem **/
    
    IF   par_flgerlog  THEN
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid).

    RETURN "OK".

END PROCEDURE.


/*********************** PROCEDURES INTERNAS   *******************************/



/*****************************************************************************
 Procedure que traz os dados da impressao do termo de cobranca.
*****************************************************************************/
PROCEDURE  obtem-dados-adesao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.  
    DEF  INPUT PARAM par_flgregis AS LOGI                           NO-UNDO.    
    DEF  INPUT PARAM par_nmdtest1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpftest1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nmdtest2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpftest2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdtitul AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nrconven AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmmesano AS CHAR EXTENT 12
        INIT ["janeiro","fevereiro","marco","abril","maio","junho",
              "julho","agosto","setembro","outubro","novembro","dezembro"] 
                                                                    NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.


    IF   par_flgerlog   THEN
         ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
                aux_dstransa = "Obter dados para impressao do termo de cobranca.".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
           
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapenc.
    EMPTY TEMP-TABLE tt-crapcop.


    DO WHILE TRUE:

       FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapcop   THEN
            DO:
                ASSIGN aux_cdcritic = 651.
                LEAVE.
            END.

       FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                          crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapass   THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE.
            END.

       FIND crapope WHERE crapope.cdcooper = par_cdcooper   AND
                          crapope.cdoperad = par_cdoperad   NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapope   THEN
            DO:
                ASSIGN aux_cdcritic = 67.
                LEAVE.
            END.

       ASSIGN par_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                             par_dsiduser.

       UNIX SILENT VALUE("rm " + par_nmarqimp + "* 2>/dev/null").        

       ASSIGN par_nmarqimp = par_nmarqimp + STRING(TIME) + ".ex".
                
       OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGE-SIZE 84 PAGED.

       /* Se nao tiver mudado o limite de nenhum , pegar o 1.ttl */
                        /* Ou se é Registrada */
       ASSIGN par_dsdtitul = "1" WHEN par_dsdtitul = "" OR par_flgregis.

       /* Para cada titular */
       DO aux_contador = 1 TO NUM-ENTRIES(par_dsdtitul):

           EMPTY TEMP-TABLE tt-dados-adesao-net.
           
           ASSIGN par_idseqttl = INTE(ENTRY(aux_contador,par_dsdtitul)).

           FIND crapsnh WHERE crapsnh.cdcooper = par_cdcooper   AND
                              crapsnh.nrdconta = par_nrdconta   AND
                              crapsnh.idseqttl = par_idseqttl   AND
                              crapsnh.tpdsenha = 1             
                              NO-LOCK NO-ERROR.

           IF   NOT AVAIL crapsnh   THEN
                DO:
                    ASSIGN aux_dscritic = "Registro de senha nao encontrado.".
                    LEAVE.
                END.

           IF   crapass.inpessoa = 1   THEN
                DO:
                    FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                                       crapttl.nrdconta = par_nrdconta   AND
                                       crapttl.idseqttl = par_idseqttl 
                                       NO-LOCK NO-ERROR.
                   
                    IF   NOT AVAIL crapttl   THEN
                         DO:
                             ASSIGN aux_dscritic = "Titular nao cadastrado.".
                             LEAVE.
                         END.
                   
                    ASSIGN aux_nmprimtl = crapttl.nmextttl
                           aux_nrcpfcgc = STRING(STRING(crapttl.nrcpfcgc,
                                            "99999999999"),"xxx.xxx.xxx-xx").
                END.
           ELSE     
                ASSIGN aux_nmprimtl = crapass.nmprimtl
                       aux_nrcpfcgc = STRING(STRING(crapass.nrcpfcgc, 
                                     "99999999999999"),"xx.xxx.xxx/xxxx-xx").
           
           CREATE tt-crapcop.
           BUFFER-COPY crapcop EXCEPT nrctabcb TO tt-crapcop.

           CREATE tt-dados-adesao-net.        
           ASSIGN tt-dados-adesao-net.nrdocnpj = STRING(STRING(crapcop.nrdocnpj,
                                                   "99999999999999"),
                                                   "xx.xxx.xxx/xxxx-xx") 
                  tt-dados-adesao-net.nrdconta = crapass.nrdconta
                  tt-dados-adesao-net.nmprimtl = aux_nmprimtl
                  tt-dados-adesao-net.nrcpfcgc = aux_nrcpfcgc
                  tt-dados-adesao-net.dsmvtolt = TRIM(SUBSTR(crapcop.nmcidade,1,1) +
                                              SUBSTR(LOWER(crapcop.nmcidade),2)) +
                                              ", " + 
                                              STRING(DAY(par_dtmvtolt),"99") + 
                                              " de " + 
                                              aux_nmmesano[MONTH(par_dtmvtolt)] + 
                                              " de " +
                                              STRING(YEAR(par_dtmvtolt),"9999") + 
                                              "."
                  tt-dados-adesao-net.dsmvtope = STRING(par_dtmvtolt,"99/99/9999") + 
                                                 " - " + STRING(TIME,"HH:MM:SS")
                  tt-dados-adesao-net.nmoperad = crapope.nmoperad
                  tt-dados-adesao-net.cddbanco = "085".


           glb_nrcalcul = INTEGER(STRING(crapcop.cdagectl,"9999") + "0").
           RUN fontes/digfun.p.
           tt-dados-adesao-net.cdagectl = STRING(glb_nrcalcul).

           IF   par_flgregis   THEN /* Se registrada, pegar end. Cooperado*/
                DO:
                    IF   crapass.inpessoa = 1   THEN
                         FIND FIRST crapenc WHERE 
                                    crapenc.cdcooper = par_cdcooper   AND
                                    crapenc.nrdconta = par_nrdconta   AND
                                    crapenc.idseqttl = par_idseqttl   AND
                                    crapenc.tpendass = 10
                                    NO-LOCK NO-ERROR.  
                    ELSE
                         FIND FIRST crapenc WHERE
                                    crapenc.cdcooper = par_cdcooper   AND
                                    crapenc.nrdconta = par_nrdconta   AND
                                    crapenc.idseqttl = par_idseqttl   AND
                                    crapenc.tpendass = 9
                                    NO-LOCK NO-ERROR.
                     
                    IF   NOT AVAIL crapenc   THEN
                         DO:
                             aux_cdcritic = 247.
                             LEAVE.
                         END.
                    
                    IF   crapcop.dtregcob = ?   OR
                         crapcop.idregcob = ""  OR
                         crapcop.idlivcob = ""  OR
                         crapcop.nrfolcob = 0   OR
                         crapcop.dsloccob = ""  OR
                         crapcop.dscidcob = ""  THEN
                         DO:
                             ASSIGN aux_dscritic = 
                       "Faltam os parametros do CADCOP na opcao COBRANCA REG.".
                             LEAVE.
                         END.

                    ASSIGN tt-dados-adesao-net.nmdtest1 = par_nmdtest1
                           tt-dados-adesao-net.cpftest1 = 
                                STRING(STRING(par_cpftest1,
                                  "99999999999"),"xxx.xxx.xxx-xx")
                            
                           tt-dados-adesao-net.nmdtest2 = par_nmdtest2
                           tt-dados-adesao-net.cpftest2 = 
                                STRING(STRING(par_cpftest2,
                                  "99999999999"),"xxx.xxx.xxx-xx").
                                                             
                    CREATE tt-crapenc.
                    BUFFER-COPY crapenc EXCEPT dsendere TO tt-crapenc.   
                    ASSIGN tt-crapenc.dsendere =
                        crapenc.dsendere + ", " + STRING(crapenc.nrendere).

                 END.

           IF   par_flgregis   THEN
                RUN monta-arquivo-registrada 
                        (INPUT TABLE tt-dados-adesao-net,
                         INPUT TABLE tt-crapcop,   
                         INPUT TABLE tt-crapenc,
                         INPUT par_nrconven).
           ELSE
                RUN monta-arquivo-nao-registrada
                         (INPUT TABLE tt-dados-adesao-net,
                          INPUT TABLE tt-crapcop).

           IF   RETURN-VALUE <> "OK"   THEN
                LEAVE.

       END.  /* Fim para cada titular */
           
       OUTPUT STREAM str_1 CLOSE.

       IF   aux_dscritic <> ""   OR 
            aux_cdcritic <> 0    THEN
            LEAVE.
          
       IF   par_idorigem = 5   THEN  /* Copia para o Ayllos Web */
            DO:
                RUN sistema/generico/procedures/b1wgen0024.p
                    PERSISTENT SET h-b1wgen0024.
                
                RUN envia-arquivo-web IN h-b1wgen0024 
                                      (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_nmarqimp,
                                      OUTPUT par_nmarqpdf,
                                      OUTPUT TABLE tt-erro).
                
                DELETE PROCEDURE h-b1wgen0024.
                
                IF   RETURN-VALUE <> "OK"   THEN
                     LEAVE.
            END.  

       ASSIGN aux_flgtrans = TRUE.
       LEAVE.

    END. /* Fim tratamento de criticas */

    IF   NOT aux_flgtrans   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   NOT AVAIL tt-erro   THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
             ELSE
                  aux_dscritic = tt-erro.dscritic.

             IF  par_flgerlog  THEN                           
                 RUN proc_gerar_log (INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT FALSE,
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid).                   
             RETURN "NOK".

         END.
                       
    IF   par_flgerlog   THEN          
         RUN proc_gerar_log (INPUT par_cdcooper,
                             INPUT par_cdoperad,
                             INPUT "",
                             INPUT aux_dsorigem,
                             INPUT aux_dstransa,
                             INPUT TRUE,
                             INPUT par_idseqttl,
                             INPUT par_nmdatela,
                             INPUT par_nrdconta,
                            OUTPUT aux_nrdrowid).
                           
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Procedure que joga os dados para o arquivo , Ayllos Caracter e Web
*****************************************************************************/
PROCEDURE monta-arquivo-nao-registrada:

    DEF INPUT PARAM TABLE FOR tt-dados-adesao-net.
    DEF INPUT PARAM TABLE FOR tt-crapcop.


    FORM "\022\024\033\120" /* Reseta impressora */
         SKIP(5)
         "\033\105TERMO DE ADESAO AOS SERVICOS DE COBRANCA BANCARIA\033\106" AT 11
         SKIP(5)
         "\0332\033x0"
         SKIP
         tt-dados-adesao-net.nmprimtl 
         ", titular da conta"
         SKIP
         "corrente no."
         tt-dados-adesao-net.nrdconta 
         ",   na   qualidade    de    Cooperado     da"
         SKIP
         tt-crapcop.nmextcop 
         ","
         SKIP
         "rua "
         tt-crapcop.dsendcop
         "no."
         tt-crapcop.nrendcop  
         ","
         SKIP
         "bairro "
         tt-crapcop.nmbairro  
         ",  CEP "
         tt-crapcop.nrcepend
         ", " 
         tt-crapcop.nmcidade
         ","
         SKIP
         "CNPJ"
         tt-dados-adesao-net.nrdocnpj 
         ","
         "resolve firmar o presente TERMO DE ADESAO"  
         SKIP
         "aos Servicos de Cobranca Bancaria disponibilizados pela Cooperativa,"
         SKIP
         "nos exatos termos do  disposto nas CONDICOES  GERAIS  APLICAVEIS  AO"
         SKIP
         "CONTRATO DE  CONTA  CORRENTE  E  CONTA INVESTIMENTO,"  
         tt-crapcop.dsclacc[1] FORMAT "x(15)"
         WITH DOWN NO-BOX NO-LABELS COLUMN 7 WIDTH 80 FRAME f_termo.

    FORM SKIP
         "as quais  o subscrevente adere  e  declara,  ao assinar  este termo,"
         SKIP
         "delas  ter pleno  conhecimento,  estar de acordo  com seu teor,  ter" 
         SKIP
         "recebido  copia  das  referidas  CONDICOES  GERAIS,   bem  como  das"
         SKIP
         "informacoes  tecnicas referentes  a  sistematica  de  transmissao  e" 
         SKIP
         "recepcao de dados."
         SKIP(3)
         tt-dados-adesao-net.dsmvtolt FORMAT "x(50)"
         WITH DOWN NO-BOX NO-LABELS COLUMN 7 WIDTH 80 FRAME f_termo_2.     

    FORM SKIP 
         tt-crapcop.dsclacc[2] FORMAT "x(68)"
         WITH DOWN NO-BOX NO-LABELS COLUMN 7 WIDTH 80 FRAME f_clausula_2.

    FORM SKIP
         tt-crapcop.dsclacc[3] FORMAT "x(68)"
         WITH DOWN NO-BOX NO-LABELS COLUMN 7 WIDTH 80 FRAME f_clausula_3.

    FORM SKIP
         tt-crapcop.dsclacc[4] FORMAT "x(68)"
         WITH DOWN NO-BOX NO-LABELS COLUMN 7 WIDTH 80 FRAME f_clausula_4.

    FORM SKIP
         tt-crapcop.dsclacc[5] FORMAT "x(68)"
         WITH DOWN NO-BOX NO-LABELS COLUMN 7 WIDTH 80 FRAME f_clausula_5.

    FORM SKIP
         tt-crapcop.dsclacc[6] FORMAT "x(68)"
         WITH DOWN NO-BOX NO-LABELS COLUMN 7 WIDTH 80 FRAME f_clausula_6.

    FORM SKIP(7)
         "______________________________________"  AT 15
         tt-dados-adesao-net.nmprimtl AT 14 
         SKIP
         "CPF/CNPJ:"                  AT 21
         tt-dados-adesao-net.nrcpfcgc            
         SKIP(2)
         "De acordo"
         SKIP(3)
         "__________________________________________________" AT 9
         SKIP
         tt-crapcop.nmextcop AT  9
         SKIP
         "CNPJ:"                      AT 23
         tt-dados-adesao-net.nrdocnpj 
         SKIP(4)
         "_____________________"  
         SKIP
         tt-dados-adesao-net.nmoperad FORMAT  "x(20)" NO-LABEL  
         SKIP
         tt-dados-adesao-net.dsmvtope FORMAT  "x(22)" NO-LABEL       
         WITH DOWN NO-BOX NO-LABELS COLUMN 7 WIDTH 80 FRAME f_assinatura.

    FIND FIRST tt-dados-adesao-net NO-LOCK NO-ERROR.

    IF   NOT AVAIL tt-dados-adesao-net   THEN
         DO:
             ASSIGN aux_dscritic = "Dados para o termo nao encontrados.".
             RETURN "NOK".
         END.

    FIND FIRST tt-crapcop NO-LOCK NO-ERROR.

    IF   NOT AVAIL tt-crapcop   THEN
         DO:
             ASSIGN aux_dscritic = "Dados da cooperativa nao encontrados.".
             RETURN "NOK".
         END.

    DISPLAY STREAM str_1
            tt-dados-adesao-net.nmprimtl
            tt-dados-adesao-net.nrdconta
            tt-crapcop.nmextcop
            tt-dados-adesao-net.nrdocnpj 
            tt-crapcop.dsendcop
            tt-crapcop.nrendcop
            tt-crapcop.nmbairro
            tt-crapcop.nrcepend
            tt-crapcop.nmcidade
            tt-crapcop.dsclacc[1] 
            WITH FRAME f_termo.

    IF  tt-crapcop.dsclacc[2] <> "" THEN
        DISPLAY STREAM str_1 tt-crapcop.dsclacc[2] 
                             WITH FRAME f_clausula_2.
        
    IF  tt-crapcop.dsclacc[3] <> "" THEN
        DISPLAY STREAM str_1 tt-crapcop.dsclacc[3]
                             WITH FRAME f_clausula_3.
        
    IF  tt-crapcop.dsclacc[4] <> "" THEN
        DISPLAY STREAM str_1 tt-crapcop.dsclacc[4] 
                             WITH FRAME f_clausula_4.
        
    IF  tt-crapcop.dsclacc[5] <> "" THEN
        DISPLAY STREAM str_1 tt-crapcop.dsclacc[5] 
                             WITH FRAME f_clausula_5.
        
    IF  tt-crapcop.dsclacc[6] <> "" THEN
        DISPLAY STREAM str_1 tt-crapcop.dsclacc[6] 
                             WITH FRAME f_clausula_6.
      
    DISPLAY STREAM str_1 tt-dados-adesao-net.dsmvtolt 
                         WITH FRAME f_termo_2. 

    /* Centraliza o nome do titular */
    IF   LENGTH(tt-dados-adesao-net.nmprimtl) < 40   THEN    
         tt-dados-adesao-net.nmprimtl = 
              FILL(" ",INT((40 - LENGTH(tt-dados-adesao-net.nmprimtl)) / 2)) + 
              tt-dados-adesao-net.nmprimtl.
                    
    /* Centraliza o nome da cooperativa */
    IF   LENGTH(tt-crapcop.nmextcop) < 50   THEN
         tt-crapcop.nmextcop = 
              FILL(" ",INT((50 - LENGTH( tt-crapcop.nmextcop)) / 2)) +
              tt-crapcop.nmextcop.

    DISPLAY STREAM str_1 
            tt-dados-adesao-net.nmprimtl 
            tt-dados-adesao-net.nrcpfcgc     
            tt-crapcop.nmextcop
            tt-dados-adesao-net.nrdocnpj
            tt-dados-adesao-net.nmoperad  
            tt-dados-adesao-net.dsmvtope   
            WITH FRAME f_assinatura.

    PAGE STREAM str_1.

    RETURN "OK".

END PROCEDURE.


PROCEDURE monta-arquivo-registrada:

    DEF INPUT PARAM TABLE FOR tt-dados-adesao-net.
    DEF INPUT PARAM TABLE FOR tt-crapcop.
    DEF INPUT PARAM TABLE FOR tt-crapenc.
    DEF INPUT PARAM par_nrconven AS INTE                            NO-UNDO.

    DEF VAR aux_nmextcop AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsendere AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdregi1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdregi2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_qtdfloat AS INTE FORMAT "99"                        NO-UNDO.
    DEF VAR aux_dsextens AS CHAR FORMAT "x(6)"                      NO-UNDO.
    
    /* Valores esperados sao 1, 2, 3, 4, 5. Vetor criado com 
       intuito de cobrir quantidade de valores maior */
    DEF VAR aux_nmnumero AS CHAR EXTENT 10
        INIT ["um","dois","tres","quatro","cinco"
             ,"seis","sete","oito","nove","dez"]                    NO-UNDO.

    DEF VAR h-b1wgen0078 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_paragrafo_5 AS CHAR                                 NO-UNDO.

    FORM "CONTRATO/TERMO DE ADESAO AO SISTEMA DE COBRANCA REGISTRADA"
         SKIP(2)
         "COOPERATIVA"
         SKIP(1)
         aux_nmextcop FORMAT "x(100)"  
         SKIP(1)
         "CNPJ: " tt-dados-adesao-net.nrdocnpj
         SKIP(1)
         "Endereco: " aux_dsendere FORMAT "x(110)"
         SKIP(1)
         WITH NO-LABEL SIDE-LABEL WIDTH 132 FRAME f_coop.
    
    FORM "COOPERADO"
         SKIP(1)
         tt-dados-adesao-net.nmprimtl LABEL "Nome/Razao Social" FORMAT "x(50)"
         SKIP(1)
         tt-dados-adesao-net.nrcpfcgc LABEL "CPF/CNPJ"          FORMAT "x(18)"
         SKIP(1)
         tt-crapenc.dsendere LABEL "Endereco" FORMAT "x(80)" 
         SKIP(1)
         tt-crapenc.nmcidade LABEL "Cidade"
         SKIP(1)
         tt-crapenc.cdufende LABEL "UF"   
         SPACE(5)
         tt-crapenc.nrcepend LABEL "CEP"
         SKIP(1)
         tt-dados-adesao-net.cddbanco LABEL "Banco"
         SPACE(5)
         tt-dados-adesao-net.cdagectl LABEL "Agencia"   
         SPACE(5)
         tt-dados-adesao-net.nrdconta LABEL "Conta/DV"
         SKIP(1)
         WITH SIDE-LABEL WIDTH 132 FRAME f_cooperado.
         
    FORM "Pelo presente instrumento, o COOPERADO acima identificado e"
         "qualificado adere ao Servico de Cobranca Registrada e declara,"
         SKIP 
         "em carater irrevogavel e irretratavel, para todos os" 
         "efeitos legais, o seguinte:"
         SKIP(1)
         "1 - Esta ciente e de pleno acordo com as disposicoes contidas"
         "nas Clausulas e Condicoes Gerais do Contrato para Prestacao de"
         SKIP
         "    Servico de Cobranca Registrada, registrado no"
         aux_dsdregi1 FORMAT "x(80)"
         SKIP
         aux_dsdregi2 FORMAT "x(65)"
         "as quais integram este Contrato/Termo de Adesao, para os"
         SKIP           
         "    devidos fins, formando um documento unico e indivisivel, cujo" 
         "teor declara conhecer e entender e com o qual concorda, passando"
         SKIP
         "    a assumir todas as prerrogativas e obrigacoes que lhe"
         "sao atribuidas, na condicao de COOPERADO usuario do servico de"
         SKIP
         "    cobranca registrada."
         SKIP(1)
         "2 - Esta ciente e de pleno acordo com as disposicoes contidas na"
         "'Tabela de Tarifas' relativo as tarifas a serem cobradas pela "
         SKIP
         "    prestacao do servico de Cobranca Registrada,"
         "a quais fazem parte integrante do presente Contrato/Termo"
         "    de Adesao." 
         SKIP(1)
         "3 - Esta ciente de que os valores correspondentes aos creditos recebidos "
         "serao lancados na conta corrente que o COOPERADO "
         SKIP
         "    mantem na COOPERATIVA, mencionada no preambulo deste Contrato/Termo de Adesao, " 
         "bem como autoriza a COOPERATIVA a "
         SKIP 
         "    estornar de sua conta corrente o valor dos cheques que, entregues "
         "pelos Pagadores para quitacao de seus compromissos"
         SKIP
         "    (Titulos /Duplicatas, etc), forem devolvidos por qualquer motivo pelo"
         " Banco Pagador, ficando o credito "
         SKIP
         "    retido/bloqueado pelo periodo da efetiva compensacao dos cheques."
         SKIP(1)
         "4 - Esta ciente da proibicao de cobrar do pagador/cliente qualquer  valor "
         "relativo  a  emissao de boleto, independente do "
         SKIP
         "    titulo  ( custo,  tarifa,  ressarcimento  de  despesas,  etc) e da denominacao "
         '( "tarifa  de  emissao  de  boleto", '
         SKIP
         '    "taxa de emissao de fatura de cobranca").'
         SKIP(1)
         aux_paragrafo_5
         SKIP(1)
         "E por estarem assim justas e contratadas, firmam"
         "o presente Contrato/Termo de Adesao em tantas vias quantas"
         SKIP
         "forem necessarias para a entrega de uma via para cada parte,"
         "na presenca das duas testemunhas abaixo identificadas,"
         SKIP
         "que, estando cientes, tambem assinam, para que produza os" 
         "devidos e legais efeitos."
         SKIP(1)
         tt-dados-adesao-net.dsmvtolt AT 80 FORMAT "x(50)"
         SKIP(1)
         WITH NO-LABEL WIDTH 132 FRAME f_texto.
   
   FORM "Pelo presente instrumento, o COOPERADO acima identificado e"
         "qualificado adere ao Servico de Cobranca Registrada e declara,"
         SKIP 
         "em carater irrevogavel e irretratavel, para todos os" 
         "efeitos legais, o seguinte:"
         SKIP(1)
         "1 - Esta ciente e de pleno acordo com as disposicoes contidas"
         "nas Clausulas e Condicoes Gerais do Contrato para Prestacao de"
         SKIP
         "    Servico de Cobranca Registrada, registrado no"
         aux_dsdregi1 FORMAT "x(80)"
         SKIP
         aux_dsdregi2 FORMAT "x(65)"
         "as quais integram este Contrato/Termo de Adesao, para os"
         SKIP           
         "    devidos fins, formando um documento unico e indivisivel, cujo" 
         "teor declara conhecer e entender e com o qual concorda, passando"
         SKIP
         "    a assumir todas as prerrogativas e obrigacoes que lhe" 
         "sao atribuidas, na condicao de COOPERADO usuario do servico de"
         SKIP
         "    cobranca registrada."
         SKIP(1)
         "2 - Esta ciente e de pleno acordo com as disposicoes contidas na"
         "'Tabela de Tarifas' relativo as tarifas a serem cobradas pela "
         SKIP
         "    prestacao do servico de Cobranca Registrada,"
         "a quais fazem parte integrante do presente Contrato/Termo"
         "    de Adesao."
         SKIP(1)
         "3 - Esta ciente de que os valores correspondentes aos creditos recebidos"
         "serao lancados na conta corrente que o COOPERADO mantem"
         SKIP 
         "    na COOPERATIVA, apos transcorrido o prazo de" aux_qtdfloat aux_dsextens
         "dia(s), contado da data da liquidacao do titulo perante a COOPERATIVA."
         SKIP
         "    O COOPERADO autoriza a COOPERATIVA estornar de sua conta corrente o"
         "valor dos cheques que, entregues pelos pagadores para"
         SKIP
		 "    quitacao de seus compromissos(Titulos/Duplicatas, etc), forem"
		 "devolvidos por qualquer motivo pelo Banco Pagador, ficando o"
         SKIP
         "    credito retido/bloqueado pelo periodo da efetiva compensacao dos cheques."
         SKIP(1)
         "4 - Esta ciente da proibicao de cobrar do pagador/cliente qualquer  valor "
         "relativo  a  emissao de boleto, independente do "
         SKIP
         "    titulo  ( custo,  tarifa,  ressarcimento  de  despesas,  etc) e da denominacao "
         '( "tarifa  de  emissao  de  boleto", '
         SKIP
         '    "taxa de emissao de fatura de cobranca").'
         SKIP(1)
         aux_paragrafo_5
         SKIP(1)
         "E por estarem assim justas e contratadas, firmam"
         "o presente Contrato/Termo de Adesao em tantas vias quantas"
         SKIP
         "forem necessarias para a entrega de uma via para cada parte,"
         "na presenca das duas testemunhas abaixo identificadas,"
         SKIP
         "que, estando cientes, tambem assinam, para que produza os" 
         "devidos e legais efeitos."
         SKIP(1)
         tt-dados-adesao-net.dsmvtolt AT 80 FORMAT "x(50)"
         SKIP(1)
         WITH NO-LABEL WIDTH 132 FRAME f_texto_float.
   
    FORM "__________________________________________" 
         SKIP
         tt-dados-adesao-net.nmprimtl LABEL "Cooperado"   FORMAT "x(50)"
         SKIP(3)
         "__________________________________________" 
         SKIP
         tt-crapcop.nmextcop          LABEL "Cooperativa" FORMAT "x(100)"
         SKIP(3)
         "TESTEMUNHAS"
         SKIP(3)
         "__________________________________________"
         SKIP
         tt-dados-adesao-net.nmdtest1 LABEL "Nome"        FORMAT "x(50)"
         SKIP                                             
         tt-dados-adesao-net.cpftest1 LABEL "CPF"         FORMAT "x(30)"
         SKIP(3)                                          
         "__________________________________________"     
         SKIP                                             
         tt-dados-adesao-net.nmdtest2 LABEL "Nome"        FORMAT "x(50)"
         SKIP                                             
         tt-dados-adesao-net.cpftest2 LABEL "CPF"         FORMAT "x(30)"
         SKIP(1)
         WITH SIDE-LABELS WIDTH 132 FRAME f_assinaturas.
 

    FIND FIRST tt-dados-adesao-net NO-LOCK NO-ERROR.

    IF   NOT AVAIL tt-dados-adesao-net   THEN
         DO:
             ASSIGN aux_dscritic = "Dados para o termo nao encontrados.".
             RETURN "NOK".
         END.

    FIND FIRST tt-crapcop NO-LOCK NO-ERROR.

    IF   NOT AVAIL tt-crapcop   THEN
         DO:
             ASSIGN aux_dscritic = "Dados da cooperativa nao encontrados.".
             RETURN "NOK".
         END.
         
    FIND FIRST tt-crapenc NO-LOCK NO-ERROR.

    IF   NOT AVAIL tt-crapenc   THEN
         DO:
             ASSIGN aux_dscritic = "Endereco do cooperado nao encontrado.".
             RETURN "NOK".
         END.

    ASSIGN aux_nmextcop = tt-crapcop.nmextcop + " - "  + tt-crapcop.nmrescop
        
           aux_dsdregi1 = tt-crapcop.dsloccob + " de " + tt-crapcop.dscidcob +
                          ", em " + STRING(tt-crapcop.dtregcob,"99/99/9999") +
                          ","  
         
           aux_dsdregi2 = "    " +                  
                          "sob o n. " + tt-crapcop.idregcob + ", livro " + 
                          tt-crapcop.idlivcob + ", folha " +
                          TRIM(STRING(tt-crapcop.nrfolcob,"zzz,zz9")) + ",".
        
                        
    RUN sistema/generico/procedures/b1wgen0078.p PERSISTENT SET h-b1wgen0078.

    RUN busca-end-coop IN h-b1wgen0078 (INPUT TABLE tt-crapcop,
                                       OUTPUT aux_dsendere).

    DELETE PROCEDURE h-b1wgen0078.

    DISPLAY STREAM str_1 aux_nmextcop 
                         tt-dados-adesao-net.nrdocnpj
                         aux_dsendere WITH FRAME f_coop.

    DISPLAY STREAM str_1 tt-dados-adesao-net.nmprimtl
                         tt-dados-adesao-net.nrcpfcgc
                         tt-crapenc.dsendere
                         tt-crapenc.nmcidade
                         tt-crapenc.cdufende
                         tt-crapenc.nrcepend WITH FRAME f_cooperado.  
    
    /* Buscar dados do convenio */
    FIND FIRST crapceb WHERE crapceb.cdcooper = tt-crapcop.cdcooper          AND
                             crapceb.nrdconta = tt-dados-adesao-net.nrdconta AND
                             crapceb.nrconven = par_nrconven                 NO-LOCK NO-ERROR.
    
    /* Se encontrar o registro */
    IF AVAILABLE crapceb AND crapceb.qtdfloat > 0 THEN
      ASSIGN aux_qtdfloat = crapceb.qtdfloat
             aux_dsextens = "(" + aux_nmnumero[aux_qtdfloat] + ")".
    ELSE 
      ASSIGN aux_qtdfloat = 0
             aux_dsextens = "".

    aux_paragrafo_5 = "5 - O COOPERADO assume a responsabilidade pela emissao, impressao" +
                      "e envio dos boletos de cobranca aos seus respectivos pagadores".

    /* Se a quantidade de float for igual a zero */
    IF aux_qtdfloat = 0 THEN
      DISPLAY STREAM str_1 aux_dsdregi1
                           aux_dsdregi2   
                           tt-dados-adesao-net.dsmvtolt WITH FRAME f_texto.
    ELSE
      DISPLAY STREAM str_1 aux_dsdregi1
                           aux_dsdregi2   
                           aux_qtdfloat
                           aux_dsextens
                           tt-dados-adesao-net.dsmvtolt WITH FRAME f_texto_float.
    
    DISPLAY STREAM str_1 tt-dados-adesao-net.nmprimtl
                         tt-crapcop.nmextcop  
                         tt-dados-adesao-net.nmdtest1                                                
                         tt-dados-adesao-net.cpftest1 
                         tt-dados-adesao-net.nmdtest2 
                         tt-dados-adesao-net.cpftest2 WITH FRAME f_assinaturas.


    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Procedure para trazer os titulares da conta.
*****************************************************************************/
PROCEDURE valores-max-titulares:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-titulares.

    DEF  VAR aux_contador         AS INTE                             NO-UNDO.

    EMPTY TEMP-TABLE tt-titulares.


    FOR EACH crapsnh WHERE crapsnh.cdcooper = par_cdcooper      AND
                           crapsnh.nrdconta = par_nrdconta      AND 
                           crapsnh.tpdsenha = 1                 AND 
                           crapsnh.cdsitsnh = 1                 NO-LOCK,
        
        FIRST crapttl WHERE crapttl.cdcooper = crapsnh.cdcooper AND
                            crapttl.nrdconta = crapsnh.nrdconta AND
                            crapttl.idseqttl = crapsnh.idseqttl NO-LOCK:

        CREATE tt-titulares.
        ASSIGN tt-titulares.idseqttl = crapttl.idseqttl
               tt-titulares.nmextttl = crapttl.nmextttl
            
                aux_contador  = aux_contador + 1.

    END.

    IF   aux_contador = 1   THEN
         EMPTY TEMP-TABLE tt-titulares.

    RETURN "OK".

END PROCEDURE.

/* ......................................................................... */
