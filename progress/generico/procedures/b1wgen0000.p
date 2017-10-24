/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +----------------------------------------+--------------------------------------------------+
  | Rotina Progress                        | Rotina Oracle PLSQL                              |
  +----------------------------------------+--------------------------------------------------+
  | valida-senha-coordenador               | LOGIN0001.pc_val_senha_coordenador_car           |
  +----------------------------------------+--------------------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 23/SET/2015 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - ADRIANO   (CECRED)
   
*******************************************************************************/


/*..............................................................................

   Programa: b1wgen0000.p                  
   Autor(a): David
   Data    : 09/07/2007                        Ultima atualizacao: 23/08/2017

   Dados referentes ao programa:

   Objetivo  : BO PARA LOGIN E MENU DO SISTEMA AYLLOS (INTERNET)

   Alteracoes: 15/09/2008 - Alterar tpregist na leitura da tabela "TEMPOCIOSO"
                            (David).

               10/10/2008 - Incluir procedure para pedir senha de Operador/
                            Coordenador/Gerente (David).
                            
               10/11/2008 - Alteracao sobre nova estrutura de permissoes
                            (Guilherme).
               
               22/05/2009 - Alteracao CDOPERAD (Kbase).
               
               16/10/2009 - Trazer tambem rotinas filha na tt-rotina(Guilherme).
               
               02/12/2009 - Acerto no controle de acesso durante o processo
                            batch (David).
                            
               30/07/2010 - Verificar se o sistema esta bloqueado devido ao
                            processo batch e eetornar novas variaveis de 
                            ambiente (David).
                            
               20/10/2010 - Criar nova procedure para verificar permissao de
                            acesso as operacoes (David).
                            
               14/07/2011 - Verificar e retornar se o operador precisa trocar
                            de senha (Gabriel).            
               
               19/01/2012 - Validacoes para o camo PAC Trabalho (Tiago).
               
               31/05/2012 - Ajuste na procedure valida-pac-trabalho para 
                            utilizar buffer na leitura da crapope (David).
                            
               07/02/2012 - Incluir campo tt-login.flgperac, tt-login.nvoperad
                            em procedure efetua_login (Lucas R.)
                            
               08/04/2013 - Alterada consultas em craptel e crapace devido ao
                            novo campo idambtel e idambace respectivametne. 
                            (Jorge).
                            
               13/08/2013 - Nova forma de chamar as agências, alterado para
                          "Posto de Atendimento" (PA). (André Santos - SUPERO)
                          
               08/12/2013 - Diminuir a leitura no crapace - problemas de
                            desempenho (Ze/Mirtes).           
                            
               13/01/2014 - Alterada critica ao nao encontrar PA para "962 - PA 
                            nao cadastrado." (Reinert)
                            
               04/12/2014 - Alterado critica 36 para "Operador nao possui permissao
                            de acesso." (Jorge/Rosangela) - SD 228463
                            
               23/02/2015 - Alterado a ordemo resultado da consulta 
                            das abas da tela de limite de crédito. (Kelvin)
                            
               08/05/2015 - Nova ordenacao para as opcoes do limite 
                            de credito (Gabriel-RKAM).    
                            
               12/08/2015 - Validar situacao do operador quando e' solicitada
                            a senha de coordenador/gerente (Gabriel-RKAM).
                            
               16/10/2015 - Inclusão de UPPER na validação do CDOPERAD. SM 326639
                            (Dionathan Henchel)
                            
               07/12/2015 - Realizado ajuste para chamar a rotina convertida
                            na proceudure valida-senha-coordenador
                            (Adriano).
                            
               17/02/2016 - Verificado campo insitage em proc. valida-pac-trabalho.
                            (Jorge/Thiago) - SD 394728

               12/05/2016 - Removido o UPPER das queries da crapace. As leituras efetuadas no Progress 
			                      nao devem forcar o UPPER dos campos de texto, pois o Dataserver 
							              ja faz isso por padrao (Douglas - Chamado 450846)
              
              27/06/2016 - Incluir o cdoperad na tt-login para e setar a
                           variavel de sessao com valor que esta retornando do
                           cadastro do operador. Quando o operador digita o
                           codigo do operador em maisculo na variavel de sessao
                           gravava o cdoperad digitado enquanto no cadastro
                           estava em minusculo, isto gerava problemas no oracle
                           ao consultar um nome de operador usando a variavel
                           cdoperad da sessao que estava em maisculo (Oscar).        

			  07/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                           departamento passando a considerar o código (Renato Darosci)

			  24/10/2017 - Adicionado validacao para autenticacao pelo CRM. (PRJ339 - Reinert)
..............................................................................*/


{ sistema/generico/includes/b1wgen0000tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.


/*................................ PROCEDURES ................................*/


/******************************************************************************/
/**        Procedure para efetuar login no sistema Ayllos - Modo WEB         **/
/******************************************************************************/
PROCEDURE efetua_login:

    DEF  INPUT PARAM par_cdcooper LIKE crapope.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vldsenha AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cddsenha LIKE crapope.cddsenha             NO-UNDO.
    DEF  INPUT PARAM par_cdpactra LIKE crapope.cdpactra             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-login.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dtmvtolt AS DATE                                    NO-UNDO.
    DEF VAR aux_dtmvtoan AS DATE                                    NO-UNDO.
    DEF VAR aux_dtmvtopr AS DATE                                    NO-UNDO.

    DEF VAR aux_nmarqblq AS CHAR                                    NO-UNDO.
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Cooperativa nao cadastrada.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
             
            RETURN "NOK".
        END.

    ASSIGN aux_nmarqblq = "/usr/coop/" + crapcop.dsdircop + 
                          "/arquivos/cred_bloq".

    IF  SEARCH(aux_nmarqblq) <> ?  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Sistema Bloqueado. Tente mais tarde!!!".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                           
            RETURN "NOK".
        END.
    
    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapope  THEN
        DO:

            ASSIGN aux_cdcritic = 67
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                           
            RETURN "NOK".
        END.
        
    IF  NOT crapope.flgdonet THEN
        DO:
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Acesso nao autorizado.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
             
            RETURN "NOK".
        END.
            
    IF  crapope.cdsitope <> 1  THEN
        DO:
            ASSIGN aux_cdcritic = 627
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
             
            RETURN "NOK".
        END.

    IF  NOT CAN-DO("1,3",STRING(crapope.tpoperad))  THEN
        DO:
            ASSIGN aux_cdcritic = 36
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
             
            RETURN "NOK".
        END.

    IF  par_vldsenha AND crapope.cddsenha <> par_cddsenha  THEN
        DO:        
            ASSIGN aux_cdcritic = 3
                   aux_dscritic = "".
            
                 RUN gera_erro (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT 1,          /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic).

                 RETURN "NOK".
        END.
        
    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapdat  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Sistema sem data de movimento.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
             
            RETURN "NOK".
        END.
    
    RUN valida-pac-trabalho (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT par_cdoperad,
                             INPUT par_idorigem,
                             INPUT par_cdpactra,
                             OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".

    ASSIGN aux_dtmvtolt = crapdat.dtmvtolt
           aux_dtmvtopr = crapdat.dtmvtopr
           aux_dtmvtoan = crapdat.dtmvtoan.

    IF  crapdat.inproces >= 3  THEN 
        DO:
            ASSIGN aux_dtmvtoan = aux_dtmvtolt
                   aux_dtmvtolt = aux_dtmvtopr.
             
            DO WHILE TRUE:          

                ASSIGN aux_dtmvtopr = aux_dtmvtopr + 1.

                IF  LOOKUP(STRING(WEEKDAY(aux_dtmvtopr)),"1,7") <> 0  THEN
                    NEXT.

                IF  CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper  AND
                                           crapfer.dtferiad = aux_dtmvtopr) THEN
                    NEXT.

                LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */
        END.
    
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 0            AND
                       craptab.cdacesso = "TEMPOCIOSO" AND
                       craptab.tpregist = 1            NO-LOCK NO-ERROR.

    CREATE tt-login.
    ASSIGN tt-login.nmoperad = crapope.nmoperad
           tt-login.cddepart = crapope.cddepart
           tt-login.nmrescop = crapcop.nmrescop
           tt-login.dsdircop = crapcop.dsdircop
           tt-login.dtmvtolt = aux_dtmvtolt
           tt-login.dtmvtopr = aux_dtmvtopr
           tt-login.dtmvtoan = aux_dtmvtoan
           tt-login.inproces = crapdat.inproces
           tt-login.stimeout = IF  NOT AVAILABLE craptab  THEN
                                   300
                               ELSE
                                   INTE(craptab.dstextab)
                                      
           tt-login.flgdsenh = 
                (crapdat.dtmvtolt - crapope.dtaltsnh) >= crapope.nrdedias 
           tt-login.cdpactra = crapope.cdpactra
           tt-login.flgperac = crapope.flgperac
           tt-login.nvoperad = crapope.nvoperad
           tt-login.cdoperad = crapope.cdoperad.
    
	/* Buscar o registro do departamento */
    FIND crapdpo WHERE crapdpo.cdcooper = par_cdcooper     AND
                       crapdpo.cddepart = crapope.cddepart NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapdpo  THEN
		ASSIGN tt-login.dsdepart = "".
	ELSE
	    ASSIGN tt-login.dsdepart = crapdpo.dsdepart.

  /* PRJ339 - Reinert */
  /* Se login foi feito pelo AyllosWeb*/
	IF  par_idorigem = 5 THEN
      DO:
        /* Verificar se CRM esta liberado na prm */
        FOR FIRST crapprm FIELDS(dsvlrprm)
                           WHERE crapprm.cdcooper = 0
                             AND crapprm.nmsistem = "CRED"
                             AND crapprm.cdacesso = "LIBCRM"
                             NO-LOCK:
          IF CAPS(crapprm.dsvlrprm) = "N" THEN
             DO:      
                /* Se operador tiver acesso ao CRM */
                IF  crapope.flgutcrm THEN
                    DO:
                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = "Operador nao esta habilitado para acessar o sistema Ayllos. Utilize o CRM.".
                        
                       RUN gera_erro (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT 1,            /** Sequencia **/
                                      INPUT aux_cdcritic,
                                      INPUT-OUTPUT aux_dscritic).
                         
                       RETURN "NOK".                    
                    END. /* IF  crapope.flgutcrm THEN */
                /*Buscar registro do PA*/
                FOR FIRST crapage FIELDS(flgutcrm)
                                   WHERE crapage.cdcooper = par_cdcooper
                                     AND crapage.cdagenci = par_cdagenci
                                     NO-LOCK:
                  /* Se PA utiliza CRM */
                  IF  crapage.flgutcrm THEN
                      DO:
                         ASSIGN aux_cdcritic = 0
                                aux_dscritic = "PA nao esta habilitado para acessar o sistema Ayllos. Utilize o CRM".
                          
                         RUN gera_erro (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1,            /** Sequencia **/
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).
                           
                         RETURN "NOK".

                      END. /* IF  crapage.flgutcrm THEN */
                END. /* FOR FIRST crapage  */                    
             END. /* IF CAPS(crapprm.dsvlrprm) = "N" THEN */
        END. /* FOR FIRST crapprm */
      END. /* IF  par_idorigem = 5 THEN */
  
    RETURN "OK".
        
END PROCEDURE.


/******************************************************************************/
/**          Procedure para retornar telas que usuario pode acessar          **/
/******************************************************************************/
PROCEDURE carrega_menu:

    DEF  INPUT PARAM par_cdcooper LIKE crapace.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idsistem LIKE craptel.idsistem             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-menu.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    FOR EACH craptel WHERE craptel.cdcooper = par_cdcooper AND
                           craptel.idsistem = par_idsistem AND
                           craptel.flgtelbl = TRUE         AND
                           craptel.nmrotina = ""           AND 
                           (craptel.idambtel = 2 OR 
                            craptel.idambtel = 0)          NO-LOCK
                           BY craptel.nrmodulo BY craptel.nmdatela:
    
        /*----------08/12/2013 - Jose Eduardo/Mirtes
        FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                           crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.
                                   
        IF  crapope.cddepart <> 20  THEN  /* "TI" */
            DO:
                FIND FIRST crapace WHERE crapace.cdcooper = par_cdcooper     AND
                                         crapace.cdoperad = par_cdoperad     AND
                                         crapace.nmdatela = craptel.nmdatela AND
                                         crapace.nmrotina = craptel.nmrotina AND
                                         crapace.idambace = 2 /* web */
                                         NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapace  THEN
                    NEXT.
            END.
        ---------------------------------------*/

        CREATE tt-menu.
        ASSIGN tt-menu.nmdatela = craptel.nmdatela
               tt-menu.nrmodulo = craptel.nrmodulo.
            
    END. /** Fim do FOR EACH craptel **/

    FIND FIRST tt-menu NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE tt-menu  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Operador nao possui permissao de acesso.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
             
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**  Procedure para verificar permissao de acesso em telas,rotinas e opcoes  **/
/******************************************************************************/
PROCEDURE verifica_permissao_operacao:

    DEF  INPUT PARAM par_cdcooper LIKE crapace.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idsistem LIKE craptel.idsistem             NO-UNDO.
    DEF  INPUT PARAM par_nmdatela LIKE craptel.nmdatela             NO-UNDO.
    DEF  INPUT PARAM par_nmrotina LIKE craptel.nmrotina             NO-UNDO.
    DEF  INPUT PARAM par_cddopcao LIKE crapace.cddopcao             NO-UNDO.
    DEF  INPUT PARAM par_inproces LIKE crapdat.inproces             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    RUN valida-acesso-sistema (INPUT par_cdcooper,
                               INPUT par_cdoperad,
                               INPUT par_idsistem,
                               INPUT par_nmdatela,
                               INPUT par_nmrotina,
                               INPUT par_inproces).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
             
            RETURN "NOK".
        END.
    
    IF  crapope.cddepart <> 20  THEN   /* "TI" */
        DO: 
            FIND crapace WHERE crapace.cdcooper = par_cdcooper AND
                               crapace.cdoperad = par_cdoperad AND
                               crapace.nmdatela = par_nmdatela AND
                               crapace.nmrotina = par_nmrotina AND
                               crapace.cddopcao = par_cddopcao AND 
                               crapace.idambace = 2 NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crapace  THEN
                DO:      
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Operador nao possui permissao de acesso.".
                    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                     
                    RETURN "NOK".
                END.
        END.            
                        
    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**  Procedure para verificar permissao de acesso em telas,rotinas e opcoes  **/
/******************************************************************************/
PROCEDURE obtem_permissao:

    DEF  INPUT PARAM par_cdcooper LIKE crapace.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idsistem LIKE craptel.idsistem             NO-UNDO.
    DEF  INPUT PARAM par_nmdatela LIKE craptel.nmdatela             NO-UNDO.
    DEF  INPUT PARAM par_nmrotina LIKE craptel.nmrotina             NO-UNDO.
    DEF  INPUT PARAM par_cddopcao LIKE crapace.cddopcao             NO-UNDO.
    DEF  INPUT PARAM par_inproces LIKE crapdat.inproces             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-opcoes.
    DEF OUTPUT PARAM TABLE FOR tt-rotinas.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    RUN valida-acesso-sistema (INPUT par_cdcooper,
                               INPUT par_cdoperad,
                               INPUT par_idsistem,
                               INPUT par_nmdatela,
                               INPUT par_nmrotina,
                               INPUT par_inproces).

    IF  RETURN-VALUE = "NOK"  THEN
        DO: 
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
             
            RETURN "NOK".
        END.
    
    IF  crapope.cddepart = 20  THEN  /* "TI" */
        DO:
            DO aux_contador = 1 TO NUM-ENTRIES(craptel.cdopptel,","):
            
                CREATE tt-opcoes.
                ASSIGN tt-opcoes.cddopcao = TRIM(ENTRY(aux_contador,
                                                       craptel.cdopptel,",")).

            END. /** Fim do DO ... TO **/
        END.
    ELSE
        FOR EACH crapace WHERE crapace.cdcooper = par_cdcooper  AND
                               crapace.nmdatela = par_nmdatela  AND
                               crapace.nmrotina = par_nmrotina  AND
                              (par_cddopcao     = ""            OR
                               crapace.cddopcao = par_cddopcao) AND
                               crapace.cdoperad = par_cdoperad AND
                               crapace.idambace = 2 /* 2 - web */
                               NO-LOCK:            

            CREATE tt-opcoes.
            ASSIGN tt-opcoes.cddopcao = crapace.cddopcao.

        END. /** Fim do FOR EACH crapace **/

    FIND FIRST tt-opcoes NO-LOCK NO-ERROR.
            
    IF  NOT AVAILABLE tt-opcoes  THEN
        DO:
            
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Operador nao possui permissao de acesso.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
             
            RETURN "NOK".
        END.
        
    /* Carregar rotinas pai disponiveis da tela */
    IF  par_nmrotina = "" AND par_cddopcao = ""  THEN
        DO: 
            FOR EACH craptel WHERE craptel.cdcooper  =  par_cdcooper AND
                                   craptel.nmdatela  =  par_nmdatela AND
                                   craptel.nmrotina  <> ""           AND
                                   craptel.idsistem  =  par_idsistem AND
                                   craptel.flgtelbl  =  TRUE         AND
                                   craptel.nrordrot  >  0            AND
                                   craptel.nrdnivel  =  1            AND
                                   (craptel.idambtel  = 2 OR
                                    craptel.idambtel  = 0)
                                   NO-LOCK             
                                   BY craptel.nrordrot:
                 
                IF  crapope.cddepart <> 20  THEN   /* "TI" */
                    DO:
                        FIND crapace WHERE 
                             crapace.cdcooper = par_cdcooper     AND
                             crapace.nmdatela = par_nmdatela     AND
                             crapace.nmrotina = craptel.nmrotina AND
                             crapace.cddopcao = "@"              AND
                             crapace.cdoperad = par_cdoperad     AND
                             crapace.idambace = 2 /* web */   
                             NO-LOCK NO-ERROR.
                                   
                        IF  NOT AVAILABLE crapace  THEN
                            NEXT.
                    END.
                
                CREATE tt-rotinas.
                ASSIGN tt-rotinas.nmrotina = craptel.nmrotina.
            
            END.
        END.
    ELSE
        /* Rotinas filhas de uma determinada rotina */
        FOR EACH craptel WHERE craptel.cdcooper  =  par_cdcooper AND
                               craptel.nmdatela  =  par_nmdatela AND
                               craptel.nmrotpai  =  par_nmrotina AND
                               craptel.idsistem  =  par_idsistem AND
                               craptel.flgtelbl  =  TRUE         AND
                               (craptel.idambtel  =  2 OR
                                craptel.idambtel  =  0)
                               NO-LOCK  BY craptel.nrordrot:
         
            IF  crapope.cddepart <> 20  THEN  /* "TI" */
                DO:
                    FIND crapace WHERE 
                         crapace.cdcooper = par_cdcooper     AND
                         crapace.nmdatela = par_nmdatela     AND
                         crapace.nmrotina = craptel.nmrotina AND
                         crapace.cddopcao = "@"              AND
                         crapace.cdoperad = par_cdoperad     AND
                         crapace.idambace = 2 /* web */ 
                         NO-LOCK NO-ERROR.
                               
                    IF  NOT AVAILABLE crapace  THEN
                        NEXT.
                END.
        
            CREATE tt-rotinas.
            ASSIGN tt-rotinas.nmrotina = craptel.nmrotina.
            
        END.
        
        /*Apenas se for tela de limite de crédito*/
        IF   par_nmdatela = "ATENDA" AND par_nmrotina = "LIMITE CRED" THEN 
             DO:
                 RUN trata_opcoes_limite (INPUT "@,N,I,U,A,C,R,P",
                                          INPUT-OUTPUT TABLE tt-opcoes).
             END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE trata_opcoes_limite:

    DEF INPUT PARAM par_lsopcoes AS CHAR                            NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-opcoes. 

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_cddopcao AS CHAR                                    NO-UNDO.


    DEF BUFFER b-tt-opcoes FOR tt-opcoes.

    DO aux_contador = 1 TO NUM-ENTRIES(par_lsopcoes).

       ASSIGN aux_cddopcao = ENTRY(aux_contador,par_lsopcoes).
                   
       /* Faz find na temp-table buscando em ordem os itens e adicionando
          no buffer na ordem correta*/

       FIND tt-opcoes WHERE tt-opcoes.cddopcao = aux_cddopcao NO-ERROR.
            
       IF   AVAIL tt-opcoes THEN
            DO:
                CREATE b-tt-opcoes.
                BUFFER-COPY tt-opcoes TO b-tt-opcoes. 
                DELETE tt-opcoes.
            END.

    END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**        Procedure para carregar dados para cabecalho de relatorios        **/
/******************************************************************************/
PROCEDURE cabecalho_relatorios:

    DEF  INPUT PARAM par_cdcooper LIKE crapace.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrelato LIKE craprel.cdrelato             NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-cabec-relatorio.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
        
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
             
            RETURN "NOK".
        END.

    FIND craprel WHERE craprel.cdcooper = par_cdcooper AND
                       craprel.cdrelato = par_cdrelato NO-LOCK NO-ERROR. 
     
    IF  NOT AVAILABLE craprel  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Relatorio nao cadastrado no sistema.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
             
            RETURN "NOK".
        END.

    CREATE tt-cabec-relatorio.
    ASSIGN tt-cabec-relatorio.nmrescop = crapcop.nmrescop
           tt-cabec-relatorio.nmrelato = craprel.nmrelato
           tt-cabec-relatorio.nmdestin = craprel.nmdestin.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**           Procedure para validar senha do coordenador/gerente            **/
/******************************************************************************/
PROCEDURE valida-senha-coordenador:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nvopelib AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdopelib AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddsenha AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
    
    /* Efetuar a chamada da rotina Oracle */ 
    RUN STORED-PROCEDURE pc_val_senha_coordenador_car
        aux_handproc = PROC-HANDLE NO-ERROR(INPUT par_cdcooper, /*Cooperativa*/
                                            INPUT par_cdagenci, /*Agencia    */
                                            INPUT par_nrdcaixa, /*Caixa      */
                                            INPUT par_cdoperad, /*Operador   */
                                            INPUT par_nmdatela, /*Nome tela  */
                                            INPUT par_idorigem, /*IdOrigem   */
                                            INPUT par_nrdconta, /*Conta*/
                                            INPUT par_idseqttl, /*Seq. titular*/
                                            INPUT par_nvopelib, /*Nivel Oper.*/
                                            INPUT par_cdopelib, /*Cod.Operad.*/
                                            INPUT par_cddsenha, /*Nr.da Senha*/
                                            INPUT string(INT(par_flgerlog)), /*Cod. Opção */
                                           OUTPUT "",         /*Saida OK/NOK */
                                           OUTPUT ?,          /*Tab. Retorno */
                                           OUTPUT 0,          /*Cod. critica */
                                           OUTPUT "").        /*Desc. critica*/

    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_val_senha_coordenador_car
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

    HIDE MESSAGE NO-PAUSE.

    /* Busca possíveis erros */ 
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_val_senha_coordenador_car.pr_cdcritic 
                          WHEN pc_val_senha_coordenador_car.pr_cdcritic <> ?
           aux_dscritic = pc_val_senha_coordenador_car.pr_dscritic 
                          WHEN pc_val_senha_coordenador_car.pr_dscritic <> ?.

    /* Apresenta a crítica */
    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO: 
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT 0,
                          INPUT 0,
                          INPUT 1,          /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           RETURN "NOK".

        END.
      
    RETURN "OK".

END PROCEDURE.

PROCEDURE consulta-pac-ope:

    DEF  INPUT PARAM par_cdcooper LIKE crapope.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM par_cdpactra LIKE crapope.cdpactra             NO-UNDO.
    
    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.
                       
    IF  AVAIL(crapope) THEN
        ASSIGN par_cdpactra = crapope.cdpactra.
    ELSE
        RETURN "NOK".
        
    RETURN "OK".    

END PROCEDURE.

PROCEDURE valida-pac-trabalho:

    DEF  INPUT PARAM par_cdcooper LIKE crapope.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdpactra LIKE crapope.cdpactra             NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.  

    DEF BUFFER crabope FOR crapope.

    DEF VAR aux_contador AS INTE NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    DO TRANSACTION ON ERROR UNDO,  LEAVE
                   ON ENDKEY UNDO, LEAVE.

        FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                           crapage.cdagenci = par_cdpactra NO-LOCK NO-ERROR.
    
        IF  NOT AVAIL crapage  THEN
            DO:
                ASSIGN aux_cdcritic = 962. /* PA nao cadastrado */
                UNDO, LEAVE.
            END.

		/* Se PA estiver Inativo */
        IF crapage.insitage = 2 THEN
        DO:
            ASSIGN aux_dscritic = "PA de trabalho Inativo.".
            UNDO, LEAVE.
        END.

        DO aux_contador = 1 TO 10:

            FIND crabope WHERE crabope.cdcooper = par_cdcooper AND
                               crabope.cdoperad = par_cdoperad 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                    
            IF  NOT AVAIL crabope  THEN
                DO:
                    IF  LOCKED crabope  THEN
                        DO:
                            IF  aux_contador = 10  THEN
                                DO:
                                    aux_dscritic = "Registro de operador " +
                                            "esta em uso. Tente novamente.".
                                    UNDO, LEAVE.
                                END.

                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            aux_dscritic = "Operador nao cadastrado.".
                            UNDO, LEAVE.
                        END.
                END.
            ELSE
            IF  crabope.cdpactra <> par_cdpactra THEN
                ASSIGN crabope.cdpactra = par_cdpactra.

            LEAVE.

        END. /** Fim do DO .. TO **/
            
        ASSIGN aux_flgtrans = TRUE.
        
    END. /** Fim do DO TRANSACTION **/

    IF  AVAIL crabope  THEN
        DO:
            FIND CURRENT crabope NO-LOCK NO-ERROR.
            RELEASE crabope.
        END.

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel atualizar o PA de " +
                                      "trabalho.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
    
    RETURN "OK".

END PROCEDURE.


/*............................ PROCEDURES INTERNAS ...........................*/


PROCEDURE valida-acesso-sistema:

    DEF  INPUT PARAM par_cdcooper LIKE crapace.cdcooper             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idsistem LIKE craptel.idsistem             NO-UNDO.
    DEF  INPUT PARAM par_nmdatela LIKE craptel.nmdatela             NO-UNDO.
    DEF  INPUT PARAM par_nmrotina LIKE craptel.nmrotina             NO-UNDO.
    DEF  INPUT PARAM par_inproces LIKE crapdat.inproces             NO-UNDO.

    DEF VAR aux_nmarqblq AS CHAR                                    NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651.
            RETURN "NOK".
        END.

    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE crapope  THEN
        DO:
            ASSIGN aux_cdcritic = 67.
            RETURN "NOK".
        END.

    FIND craptel WHERE craptel.cdcooper = par_cdcooper AND
                       craptel.nmdatela = par_nmdatela AND
                       craptel.nmrotina = par_nmrotina AND
                       craptel.idsistem = par_idsistem 
                       NO-LOCK NO-ERROR.
                                   
    IF  NOT AVAILABLE craptel  THEN
        DO:
            ASSIGN aux_dscritic = "Tela nao cadastrada no sistema.".
            RETURN "NOK".
        END.
    
    FIND crapprg WHERE crapprg.cdcooper = par_cdcooper AND
                       crapprg.cdprogra = par_nmdatela AND
                       crapprg.nmsistem = "CRED"       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapprg   THEN
        DO:
            ASSIGN aux_cdcritic = 2.
            RETURN "NOK".
        END.

    ASSIGN aux_nmarqblq = "/usr/coop/" + crapcop.dsdircop + 
                          "/arquivos/cred_bloq".

    IF  SEARCH(aux_nmarqblq) <> ?  THEN
        DO:
            ASSIGN aux_dscritic = "Sistema Bloqueado. Tente mais tarde!!!".
            RETURN "NOK".
        END.

    IF  craptel.inacesso = 2 AND par_inproces > 2  THEN
        .
    ELSE
    IF  craptel.inacesso = 1  THEN  
        DO:
            IF   par_inproces > 2  THEN
                 DO:
                    ASSIGN aux_cdcritic = 138.
                    RETURN "NOK".
                END.   
        END.
    ELSE
    IF  par_inproces = 1                                                OR
       (par_inproces = 2 AND SEARCH("/usr/coop/" + crapcop.dsdircop + 
                                    "/arquivos/so_consulta") <> ?)      THEN
        .
    ELSE
        DO:
            ASSIGN aux_cdcritic = 138.
            RETURN "NOK".
        END.
    
    IF  craptel.idambtel <> 0 AND craptel.idambtel <> 2  THEN
        DO:
            ASSIGN aux_dscritic = "Acesso nao autorizado.".
            RETURN "NOK".
        END.
        
    IF  NOT craptel.flgtelbl  THEN
        DO:
            ASSIGN aux_dscritic = "Tela bloqueada".
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/*............................................................................*/
