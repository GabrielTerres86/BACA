/*.............................................................................

   Programa: b1wgen0092.p                  
   Autora  : André - DB1
   Data    : 04/05/2011                        Ultima atualizacao: 07/06/2016
    
   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : BO - AUTORIZACOES DE DEBITO EM CONTA

   Alteracoes: 01/02/2012 - Verificacao na gncvcop se o convenio esta
                            cadastrado para a cooperativa (Tiago).
                            
               27/11/2012 - Tratamento para Aguas de Itapocoroy (Elton).
               
               05/08/2013 - Remover procedure verifica-tabela-exec pois nao
                            ser mais utilizada (Lucas R.).
                            
               15/10/2013 - Incluir par_dsdepart <> "COMPE" na valida-oper
                            (Lucas R.)
                            
               17/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
               
               19/05/2014 - Ajustes referentes ao chamado - Projeto Debito
                            Automatico - Softdesk 148330 (Lucas R.) 
                            
               20/08/2014 - Adicionado procedure busca_convenios_codbarras.
                             (Projeto Debito Facil - Chamado 184458) - 
                             (Fabricio).
                             
               28/08/2014 - Adicionado procedure busca_autorizacoes_cadastradas.
                            (Projeto Debito Facil - Chamado 184458) - 
                             (Fabricio).
                             
               29/08/2014 - Adicionada procedure altera_autorizacao.
                            (Projeto Debito Facil - Chamado 184458) - 
                            (Fabricio).
                            
               01/09/2014 - Adicionada procedure exclui_autorizacao.
                            (Projeto Debito Facil - Chamado 184458) - 
                            (Fabricio).
                            
               05/09/2014 - Adicionada procedure valida_datas_suspensao.
                            (Projeto Debito Facil - Chamado 184458) - 
                            (Fabricio).
                            
               08/09/2014 - Adicionada procedure busca_autorizacoes_suspensas e
                            exclui_suspensao_autorizacao.
                            (Projeto Debito Facil - Chamado 184458) - 
                            (Fabricio).
                            
               09/09/2014 - Adicionada procedure busca_lancamentos.
                            (Projeto Debito Facil - Chamado 184458) - 
                            (Fabricio).
                             
               10/09/2014 - Adicionadas procedures bloqueia_lancamento e 
                            desbloqueia_lancamento.
                            (Projeto Debito Facil - Chamado 184458) - 
                            (Fabricio).
                            
               19/05/2014 - Alteraçao de parâmetros na chamada da procedure
                            grava-dados e novos tratamentos na procedure
                            busca-autori para Projeto de Débito Fácil
                           (Lucas Lunelli - Out/2014).
                           
               05/11/2014 - Incluido clausula cdempcon <> 0 na procedure
                            busca-convenios.
                          - Na procedure retorna-calculo-barras, ajustado critica
                            de convenio na cadastrado, na busca da crapscn. 
                            (Lucas R.)
                            
              03/12/2014 - Incluir clausula crapscn.cdempcon <> 0 na busca da crapscn
                           (Lucas R. # 228699)
                          
              19/12/2014 - Se historico for vazio gera critica, procedure
                           valida-historico (Lucas R. #235558)
                           
              03/02/2015 - Incluir validacao para nao deixar incluir faturas zeradas
                           na prcedure retorna-calculo-barras (Lucas R. #242146)
              
              05/03/2015 - Retirado a condicao
                           " crapscn.dsnomcnv MATCHES "*FEBRABAN*" "
                           do fonte (SD 233749 - Tiago).
                           
              25/03/2015 - #265349 Retirado o bloqueio para faturas com os 
                           grupos 3 ou 4 = 0 no codigo de barras (Carlos)
                           
              25/03/2015 - Validar quantidade de caracteres quando for TIM,
                           maximo sera 20 (Lucas Ranghetti #269537)
                           
              30/03/2015 - Incluida validacao de horario para inclusao de 
                           debito automatico sicredi (valida-horario-sicredi) 
                           (Carlos)
                           
              22/04/2015 - (Chamado 268943) Tratamento para nao permitir data 
                            de inicio e fim iguais para suspensao temporaria
                            (Tiago Castro - RKAM).
                            
              19/05/2015 - Alterar historico 635 - Samae Gaspar para usar o 
                           calculo de digito no modulo 11 (Lucas Ranghetti #287615)
                           
              15/06/2015 - Incluir validacao na procedure busca_lancamentos para 
                           buscar registros da craplcm somente se for consulta
                           (Lucas Ranghetti #295102 )
                           
              30/06/2015 - Incluir validacao para nao validar o historico 667
                           da celesc quando for cancelamento de debito 
                           (Lucas Ranghetti #292358)
                           
              28/07/2015 - Adicionar validacao para historico zerado na procedure
                           valida-dados (Lucas Ranghetti #311450 )
                           
              01/09/2015 - Na procedure valida-dados, validar a exlusao de autorizacao 
                           de debito no dia do debito (Lucas Ranghetti #318223)
                           
              27/11/2015 - Incluir historico 2016 - DB.WBT INTERNET para nao validar
                           quando for cancelamento de autorizacao de debito 
                           (Lucas Ranghetti #308844)
                           
              18/04/2016 - Incluir procedure para validar senha do cartao 
                           magnetico e também atualizar o indicador na crapatr (Lucas Ranghetti #436229)
              17/06/2016 - Inclusão de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)

.............................................................................*/

/*............................... DEFINICOES ................................*/

{ sistema/generico/includes/b1wgen0092tt.i } 
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/ayllos/includes/var_online.i NEW }
 
DEF VAR aux_cdcritic AS INTE                                            NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                            NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                            NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                            NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                           NO-UNDO.

DEF VAR aux_dsinfor1 AS CHAR                                            NO-UNDO.
DEF VAR aux_dsinfor2 AS CHAR                                            NO-UNDO.
DEF VAR aux_dsinfor3 AS CHAR                                            NO-UNDO.
DEF VAR aux_dsprotoc AS CHAR                                            NO-UNDO.

DEF VAR h-b1wgen9999 AS HANDLE                                          NO-UNDO.
DEF VAR h-b1wgen9998 AS HANDLE                                          NO-UNDO.
DEF VAR h-bo_algoritmo_seguranca AS HANDLE                              NO-UNDO.
DEF VAR h-b1wgen0015 AS HANDLE                                          NO-UNDO.


/*............................ PROCEDURES EXTERNAS ...........................*/

/******************************************************************************/
/**           Procedure para buscar autorizacoes de debito                   **/
/******************************************************************************/
PROCEDURE busca-autori:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdrefere AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_flgsicre AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-autori.

    DEF VAR aux_dtdiatab AS INTE                                    NO-UNDO.
    DEF VAR aux_dtlimite AS DATE    FORMAT "99/99/9999"             NO-UNDO.
    DEF VAR aux_regexist AS LOGI                                    NO-UNDO.
    DEF VAR aux_inconfir AS INTE                                    NO-UNDO.
    DEF VAR aux_retornvl AS CHAR                                    NO-UNDO.
    DEF VAR par_dshistor AS CHAR                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-autori.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter autorizacoes de debito em conta"
           aux_retornvl = "NOK".
    
    Busca: DO WHILE TRUE:
        
        IF  par_cddopcao = "E" OR
            par_cddopcao = "R" THEN
            DO: 
                FIND crapatr WHERE crapatr.cdcooper = par_cdcooper  AND
                                   crapatr.nrdconta = par_nrdconta  AND
                                   crapatr.cdhistor = (IF par_flgsicre = "yes" OR 
                                                          par_flgsicre = "S" THEN
                                                          1019
                                                       ELSE INT(par_cdhistor) ) AND
                                   crapatr.cdrefere = par_cdrefere
                                   USE-INDEX crapatr1
                                   NO-LOCK NO-ERROR NO-WAIT.
              
                IF  NOT AVAIL crapatr  THEN
                    DO:
                        ASSIGN aux_cdcritic = 453.
                        LEAVE Busca.
                    END.                          

                /* Se nao for celesc ou wbt, deve validar */
                IF  (INT(par_cdhistor) <> 667) AND
                    (INT(par_cdhistor) <> 2016) THEN
                    IF  crapatr.nmempres <> "" AND par_cddopcao <> "R" THEN
                        DO:
                            ASSIGN aux_dscritic =  "Debito autorizado pelo convenio " + 
                                                   "nao pode ser alterado.".
                            LEAVE Busca.
                        END.
            
                IF  par_flgsicre = "yes" OR par_flgsicre = "S" THEN
                    DO:
                        FIND FIRST crapscn WHERE 
                                   crapscn.dsoparre = "E"                 AND
                                  (crapscn.cddmoden = "A"                 OR
                                   crapscn.cddmoden = "C")                AND
                                   crapscn.cdempcon = crapatr.cdempcon    AND
                                   crapscn.cdsegmto = STRING(crapatr.cdsegmto)
                                   NO-LOCK NO-ERROR NO-WAIT.
                        
                        IF  AVAIL crapscn THEN
                            par_dshistor = crapscn.dsnomcnv.

                    END.
                ELSE
                    DO:
                        FIND craphis WHERE craphis.cdcooper = par_cdcooper AND 
                                           craphis.cdhistor = INT(par_cdhistor)
                                           NO-LOCK NO-ERROR.
    
                        IF  NOT AVAIL craphis THEN
                            DO:
                                ASSIGN aux_cdcritic = 093.
                                LEAVE Busca.
                            END.
                        ELSE
                            par_dshistor = craphis.dshistor.
                    END.
                
                CREATE tt-autori.
                ASSIGN tt-autori.cdhistor = crapatr.cdhistor
                       tt-autori.dshistor = par_dshistor
                       tt-autori.cddddtel = crapatr.cddddtel
                       tt-autori.cdrefere = crapatr.cdrefere
                       tt-autori.dtautori = IF par_cddopcao = "R" THEN 
                                               par_dtmvtolt
                                            ELSE crapatr.dtiniatr
                       tt-autori.dtcancel = IF par_cddopcao = "R" THEN 
                                               ? 
                                            ELSE crapatr.dtfimatr
                       tt-autori.dtultdeb = crapatr.dtultdeb
                       tt-autori.dtvencto = crapatr.ddvencto
                       tt-autori.nmfatura = crapatr.nmfatura
                       tt-autori.vlrmaxdb = crapatr.vlrmaxdb
                       tt-autori.desmaxdb = STRING(crapatr.vlrmaxdb, "zzz,zz9.99")
                       tt-autori.cdempcon = crapatr.cdempcon
                       tt-autori.cdsegmto = crapatr.cdsegmto.

            END.
        ELSE
        IF  par_cddopcao = "C"  THEN
            DO: 
                ASSIGN aux_regexist = FALSE.
               
                IF  par_cdhistor = "0"  THEN
                    DO:   
                        FOR EACH crapatr WHERE 
                                 crapatr.cdcooper = par_cdcooper AND
                                 crapatr.nrdconta = par_nrdconta AND
                                 IF  (par_flgsicre = "yes" OR 
                                     par_flgsicre = "S") THEN 
                                     crapatr.cdhistor = 1019
                                 ELSE crapatr.cdhistor <> 1019     
                                 USE-INDEX crapatr1 NO-LOCK:

                             par_dshistor = "".

                            IF  par_flgsicre = "yes" OR
                                par_flgsicre = "S" THEN
                                DO:
                                    FIND FIRST crapscn WHERE 
                                               crapscn.dsoparre = "E"                 AND
                                              (crapscn.cddmoden = "A"                 OR
                                               crapscn.cddmoden = "C")                AND
                                               crapscn.cdempcon = crapatr.cdempcon    AND
                                               crapscn.cdsegmto = STRING(crapatr.cdsegmto)
                                               NO-LOCK NO-ERROR NO-WAIT.
                                    
                                    IF  AVAIL crapscn THEN
                                        par_dshistor = crapscn.dsnomcnv.
                                END.    
                            ELSE
                                DO:
                                    FIND FIRST craphis WHERE craphis.cdcooper = par_cdcooper AND 
                                                            craphis.cdhistor = crapatr.cdhistor
                                                            NO-LOCK NO-ERROR.
                                    IF  AVAIL craphis THEN
                                        par_dshistor = craphis.dshistor.
                                        
                                END.

                            IF  par_idorigem = 4  THEN /* TAA */
                                DO:
                                    IF  (crapatr.dtfimatr <> ?) OR
                                        (crapatr.tpautori = 0)  OR
                                        (crapatr.cdempcon = 0   AND
                                         crapatr.cdsegmto = 0)  THEN
                                        NEXT.
                                    
                                    FIND FIRST crapcon WHERE crapcon.cdcooper = crapatr.cdcooper AND
                                                             crapcon.cdempcon = crapatr.cdempcon AND
                                                             crapcon.cdsegmto = crapatr.cdsegmto NO-LOCK NO-ERROR.

                                    IF  NOT AVAIL crapcon THEN
                                        NEXT.
                                END.
                                
                            FIND FIRST gnconve WHERE gnconve.cdhisdeb = crapatr.cdhistor NO-LOCK NO-ERROR.

                            CREATE tt-autori.
                            ASSIGN aux_regexist = TRUE
                                   tt-autori.cdhistor = crapatr.cdhistor
                                   tt-autori.dshistor = par_dshistor
                                   tt-autori.cddddtel = crapatr.cddddtel
                                   tt-autori.cdrefere = crapatr.cdrefere
                                   tt-autori.dtautori = crapatr.dtiniatr
                                   tt-autori.dtcancel = crapatr.dtfimatr
                                   tt-autori.dtultdeb = crapatr.dtultdeb
                                   tt-autori.dtvencto = crapatr.ddvencto
                                   tt-autori.nmfatura = crapatr.nmfatura
                                   tt-autori.nmempres = crapatr.nmempres
                                   tt-autori.vlrmaxdb = crapatr.vlrmaxdb
                                   tt-autori.desmaxdb = STRING(crapatr.vlrmaxdb, "zzz,zz9.99")
                                   tt-autori.cdempcon = crapatr.cdempcon
                                   tt-autori.cdsegmto = crapatr.cdsegmto
                                   tt-autori.nmempcon = IF AVAIL gnconve THEN gnconve.nmempres ELSE "".

                        END.  /*  Fim do FOR EACH  --  Leitura do crapatr  */

                        IF  NOT aux_regexist  THEN
                            DO:
                                ASSIGN aux_cdcritic = 453.
                                LEAVE Busca.
                            END.
                    END.
                ELSE 
                IF  par_cdhistor > "0" AND par_cdrefere = 0  THEN
                    DO:
                        FOR EACH crapatr WHERE 
                                 crapatr.cdcooper = par_cdcooper  AND
                                 crapatr.nrdconta = par_nrdconta  AND
                                 crapatr.cdhistor = INT(par_cdhistor)  NO-LOCK
                                 USE-INDEX crapatr1:
               
                            FIND craphis WHERE
                                 craphis.cdcooper = par_cdcooper AND 
                                 craphis.cdhistor = crapatr.cdhistor
                                 NO-LOCK NO-ERROR.
               
                            IF  NOT AVAIL craphis THEN
                                DO:
                                    ASSIGN aux_cdcritic = 093.
                                    LEAVE Busca.
                                END.

                            IF  par_idorigem = 4  THEN /* TAA */
                                DO:
                                    IF  (crapatr.dtfimatr <> ?) OR
                                        (crapatr.tpautori = 0)  OR
                                        (crapatr.cdempcon = 0   AND
                                         crapatr.cdsegmto = 0)  THEN
                                        NEXT.
                                    
                                    FIND FIRST crapcon WHERE crapcon.cdcooper = crapatr.cdcooper AND
                                                             crapcon.cdempcon = crapatr.cdempcon AND
                                                             crapcon.cdsegmto = crapatr.cdsegmto NO-LOCK NO-ERROR.

                                    IF  NOT AVAIL crapcon THEN
                                        NEXT.
                                END.

                            FIND FIRST gnconve WHERE gnconve.cdhisdeb = crapatr.cdhistor NO-LOCK NO-ERROR.
                            
                            CREATE tt-autori.
                            ASSIGN aux_regexist = TRUE
                                   tt-autori.cdhistor = crapatr.cdhistor
                                   tt-autori.cddddtel = crapatr.cddddtel
                                   tt-autori.cdrefere = crapatr.cdrefere
                                   tt-autori.dshistor = craphis.dshistor
                                   tt-autori.dtautori = crapatr.dtiniatr
                                   tt-autori.dtcancel = crapatr.dtfimatr
                                   tt-autori.dtultdeb = crapatr.dtultdeb
                                   tt-autori.dtvencto = crapatr.ddvencto
                                   tt-autori.nmfatura = crapatr.nmfatura
                                   tt-autori.nmempres = crapatr.nmempres
                                   tt-autori.vlrmaxdb = crapatr.vlrmaxdb
                                   tt-autori.desmaxdb = STRING(crapatr.vlrmaxdb, "zzz,zz9.99")
                                   tt-autori.cdempcon = crapatr.cdempcon
                                   tt-autori.cdsegmto = crapatr.cdsegmto
                                   tt-autori.nmempcon = IF AVAIL gnconve THEN gnconve.nmempres ELSE "".

                        END.  /*  Fim do FOR EACH  --  Leitura do crapatr  */
               
                        IF  NOT aux_regexist  THEN
                            DO:
                                ASSIGN aux_cdcritic = 453.
                                LEAVE Busca.
                            END.
                    END.
                ELSE
                IF  par_cdhistor > "0" AND par_cdrefere > 0  THEN
                    DO:
                        FOR EACH crapatr WHERE 
                                 crapatr.cdcooper = par_cdcooper  AND
                                 crapatr.nrdconta = par_nrdconta  AND
                                 crapatr.cdhistor = int(par_cdhistor)  AND
                                 crapatr.cdrefere = par_cdrefere NO-LOCK
                                 USE-INDEX crapatr1:
               
                            FIND craphis WHERE
                                 craphis.cdcooper = par_cdcooper AND 
                                 craphis.cdhistor = crapatr.cdhistor
                                 NO-LOCK NO-ERROR.
               
                            IF  NOT AVAIL craphis THEN
                                DO:
                                    ASSIGN aux_cdcritic = 093.
                                    LEAVE Busca.
                                END.

                            IF  par_idorigem = 4  THEN /* TAA */
                                DO:
                                    IF  (crapatr.dtfimatr <> ?) OR 
                                        (crapatr.tpautori = 0)  OR
                                        (crapatr.cdempcon = 0   AND
                                         crapatr.cdsegmto = 0)  THEN
                                        NEXT.
                                    
                                    FIND FIRST crapcon WHERE crapcon.cdcooper = crapatr.cdcooper AND
                                                             crapcon.cdempcon = crapatr.cdempcon AND
                                                             crapcon.cdsegmto = crapatr.cdsegmto NO-LOCK NO-ERROR.

                                    IF  NOT AVAIL crapcon THEN
                                        NEXT.
                                END.

                            FIND FIRST gnconve WHERE gnconve.cdhisdeb = crapatr.cdhistor NO-LOCK NO-ERROR.
                            
                            CREATE tt-autori.
                            ASSIGN aux_regexist = TRUE
                                   tt-autori.cdhistor = crapatr.cdhistor
                                   tt-autori.cddddtel = crapatr.cddddtel
                                   tt-autori.cdrefere = crapatr.cdrefere
                                   tt-autori.dshistor = craphis.dshistor
                                   tt-autori.dtautori = crapatr.dtiniatr
                                   tt-autori.dtcancel = crapatr.dtfimatr
                                   tt-autori.dtultdeb = crapatr.dtultdeb                                  
                                   tt-autori.dtvencto = crapatr.ddvencto
                                   tt-autori.nmfatura = crapatr.nmfatura
                                   tt-autori.nmempres = crapatr.nmempres
                                   tt-autori.vlrmaxdb = crapatr.vlrmaxdb
                                   tt-autori.desmaxdb = STRING(crapatr.vlrmaxdb, "zzz,zz9.99")
                                   tt-autori.cdempcon = crapatr.cdempcon
                                   tt-autori.cdsegmto = crapatr.cdsegmto
                                   tt-autori.nmempcon = IF AVAIL gnconve THEN gnconve.nmempres ELSE "".

                        END.  /*  Fim do FOR EACH  --  Leitura do crapatr  */
               
                        IF  NOT aux_regexist  THEN
                            DO:
                                ASSIGN aux_cdcritic = 453.
                                LEAVE Busca.
                            END.
                    END.
            END.
        ASSIGN aux_retornvl = "OK".

        LEAVE.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log ( INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT (IF  aux_retornvl = "OK" THEN TRUE 
                                                ELSE FALSE),
                                     INPUT par_idseqttl,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid ).

        END.

    RETURN aux_retornvl.

END PROCEDURE.

/* ************************************************************************ */
/*                 Verifica digito e associado cadastrado                   */
/* ************************************************************************ */
PROCEDURE valida-conta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_cdsitdtl AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrdconta AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.
    	
    Busca: DO WHILE TRUE:

        IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
            RUN sistema/generico/procedures/b1wgen9999.p
                PERSISTENT SET h-b1wgen9999.
    
        RUN dig_fun IN h-b1wgen9999 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT 0,
                      INPUT-OUTPUT par_nrdconta,
                     OUTPUT TABLE tt-erro ).

        DELETE PROCEDURE h-b1wgen9999.

        IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN
            RETURN "NOK".

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta 
                           NO-LOCK NO-ERROR.
                           
        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE Busca.
            END.

        ASSIGN par_nmprimtl = crapass.nmprimtl
               par_cdsitdtl = crapass.cdsitdtl.

        LEAVE Busca.
    END.

    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
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

/*
Validacao de horario para inclusao de faturas do SICREDI (tela AUTORI). 
O horario eh cadastrado na tela CADPAC.
*/
PROCEDURE valida-horario-sicredi:
    
    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    FIND FIRST crapope WHERE 
        crapope.cdcooper = par_cdcooper AND 
        crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.
    
    FIND FIRST craptab WHERE craptab.cdcooper = par_cdcooper AND
                             craptab.nmsistem = 'CRED'       AND
                             craptab.tptabela = 'GENERI'     AND
                             craptab.cdempres = 0            AND
                             craptab.cdacesso = 'HRPGSICRED' AND
                             craptab.tpregist = crapope.cdpactra
                             NO-LOCK NO-ERROR.
    
    IF  TIME < INT(ENTRY(1, craptab.dstextab, " ")) OR /* hora inicial */
        TIME > INT(ENTRY(2, craptab.dstextab, " "))    /* hora final */ THEN
        ASSIGN aux_dscritic = "Horario p/ inclusao SICREDI esta " + 
                              "fora do estabelecido na tela CADPAC".

    IF (aux_dscritic <> "") THEN DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT 0,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE valida_conta_sicredi:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.

    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    RUN valida-horario-sicredi (INPUT par_cdcooper,
                                INPUT 0, /* cdagenci */
                                INPUT 0, /* nrdcaixa */
                                INPUT par_cdoperad,
                                OUTPUT TABLE tt-erro).
    IF (RETURN-VALUE <> "OK") THEN DO:
        FIND FIRST tt-erro NO-ERROR.
        IF  AVAILABLE tt-erro THEN
            ASSIGN aux_dscritic = tt-erro.dscritic.
        RETURN "NOK".
    END.

    Busca: DO WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta AND
                           crapass.nrctacns <> 0
                           NO-LOCK NO-ERROR.
                               
        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_dscritic = "Conta Sicredi nao cadastrada.".
                LEAVE Busca.
            END.
        
        LEAVE Busca.
    END.
        
    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.
    
    RETURN "OK".

END.

/* ************************************************************************ */
/*                           Valida historico                               */
/* ************************************************************************ */
PROCEDURE valida-historico:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM aux_dshistor AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dshistor AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_nmdcampo = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validar historico".

    DO  WHILE TRUE:
    
        IF  aux_dshistor <> "" THEN
            DO: 
                FIND FIRST craphis WHERE craphis.cdcooper = par_cdcooper AND 
                                         craphis.inautori = 1            AND
                                        (craphis.cdhistor = par_cdhistor OR
                                         craphis.dsexthst MATCHES "*" + aux_dshistor + "*")
                                         NO-LOCK NO-ERROR.
                  
                IF  NOT AVAIL craphis  THEN
                    DO: 
                        ASSIGN aux_cdcritic = 93.
                        LEAVE.
                    END.
                
                IF  craphis.indebcta <> 1  THEN
                    DO:
                        ASSIGN aux_cdcritic = 93.
                        LEAVE.
                    END.

                ASSIGN par_dshistor = craphis.dsexthst.

            END.
        ELSE
            DO:
                IF  SUBSTR(par_cddopcao,1,1) = "I" THEN
                    ASSIGN aux_dscritic = "Convenio nao informado.".
            END.

        LEAVE.
    END.

    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

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

    RETURN "OK".

END PROCEDURE.


/* ************************************************************************ */
/*                           Valida operador                                */
/* ************************************************************************ */
PROCEDURE valida-oper:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsdepart AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validar departamento".

    IF  par_dsdepart <> "TI"                   AND
        par_dsdepart <> "SUPORTE"              AND
        par_dsdepart <> "COORD.ADM/FINANCEIRO" AND   
        par_dsdepart <> "COORD.PRODUTOS"       AND
        par_dsdepart <> "COMPE"                THEN
        DO:
            ASSIGN aux_cdcritic = 0. /* retirado valdacao de departamento */
        END.

    IF  aux_cdcritic <> 0 THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa, 
                            INPUT 1, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

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

    RETURN "OK".

END PROCEDURE.


/* ************************************************************************ */
/*                           Valida dados da autorizacao                    */
/* ************************************************************************ */
PROCEDURE valida-prej-tit:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cdsitdtl AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validar titular bloqueado/prejuizo na conta".

    DO WHILE TRUE:
        IF  CAN-DO("5,6,7,8",STRING(par_cdsitdtl))  THEN
            DO:
                ASSIGN aux_cdcritic = 695.
                LEAVE.
            END.

        IF  CAN-DO("2,4,6,8",STRING(par_cdsitdtl))  THEN
            DO:
                ASSIGN aux_cdcritic = 95.
                LEAVE.
            END.
        LEAVE.
    END.

    IF  aux_cdcritic <> 0 THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

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

    RETURN "OK".

END PROCEDURE.

/* ************************************************************************ */
/*                           Valida dados da autorizacao                    */
/* ************************************************************************ */
PROCEDURE valida-dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrefere AS DECI                           NO-UNDO.

    DEF  INPUT PARAM par_dtiniatr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimatr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtlimite AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmprimtl AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrdconta AS INTE                                    NO-UNDO.
    DEF VAR aux_cdrefere AS DECI                                    NO-UNDO.
    DEF VAR aux_stsnrcal AS LOGI                                    NO-UNDO.
    DEF VAR aux_nrdigito AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Valida dados da autorizacao de debito em conta"
           par_nmdcampo = "".
    
    Valida: DO WHILE TRUE:

        IF  par_cddopcao = "I"  THEN
            DO:   
                IF  par_cdhistor = 0 THEN
                    DO:
                        ASSIGN aux_dscritic = "Convenio nao selecionado."
                               par_nmdcampo = "dshistor".
                        LEAVE Valida.
                    END.
                ELSE
                IF  par_cdhistor = 509   THEN   /* UNIMED */
                    DO:
                        IF  LENGTH(STRING(par_cdrefere)) = 14  THEN
                            DO:
                                ASSIGN aux_dscritic = "Nao se deve cadastrar " + 
                                  "os dois ultimos digitos para UNIMED BLUMENAU"
                                       par_nmdcampo = "cdrefere".
                                LEAVE Valida.
                            END.                         
                        ELSE /* Unimed Blumenau sempre tem 12 digitos 
                                Se for plano empresarial tem 6 */
                        IF  LENGTH(STRING(par_cdrefere)) <> 12    AND
                            LENGTH(STRING(par_cdrefere)) <> 6     THEN
                            DO:
                                ASSIGN aux_cdcritic = 654
                                       par_nmdcampo = "cdrefere".
                                LEAVE Valida.                              
                            END.
                        ELSE   /* UNIMED Blumenau sempre comeca com 026" */
                        IF  SUBSTR(TRIM(STRING(par_cdrefere)), 1, 2) <> "26"
                            THEN
                            DO:
                                ASSIGN aux_dscritic = "Este codigo de " +
                                             "referencia nao eh UNIMED BLUMENAU"
                                       par_nmdcampo = "cdrefere".
                                LEAVE Valida.                                   
                            END.
                    END.
                ELSE
                IF  par_cdhistor = 371  THEN    /* GLOBAL TELECOM */
                    DO:
                        ASSIGN aux_cdrefere = par_cdrefere.
                        RUN diglobal ( INPUT-OUTPUT aux_cdrefere,
                                       OUTPUT aux_stsnrcal ).
                        ASSIGN aux_cdrefere = 0.
                        IF  NOT aux_stsnrcal THEN
                            DO:
                                ASSIGN aux_cdcritic = 008
                                       par_nmdcampo = "cdrefere".
                                LEAVE Valida.
                            END.                         
                        IF  LENGTH(STRING(par_cdrefere)) > 9 THEN
                            DO:
                                ASSIGN aux_cdcritic = 654
                                       par_nmdcampo = "cdrefere".
                                LEAVE Valida.
                            END.                     
                    END.
                ELSE  
                IF  par_cdhistor = 288  OR    /* CELULAR */
                    par_cdhistor = 834  THEN  /* TIM Celular */ 
                    DO:
                        IF  LENGTH(STRING(par_cdrefere)) > 20 THEN
                            DO:
                                ASSIGN aux_cdcritic = 654
                                       par_nmdcampo = "cdrefere".
                                LEAVE Valida.
                            END.

                        ASSIGN aux_cdrefere = par_cdrefere.
                        RUN digtim ( INPUT-OUTPUT aux_cdrefere,
                                     OUTPUT aux_stsnrcal ).
                        ASSIGN aux_cdrefere = 0.

                        IF   NOT aux_stsnrcal THEN
                             DO:
                                 ASSIGN aux_cdcritic = 008
                                        par_nmdcampo = "cdrefere".
                                 LEAVE Valida.
                             END.
                             
                        IF   par_cdrefere < 1000000000 THEN
                              DO:
                                 ASSIGN aux_cdcritic = 654
                                        par_nmdcampo = "cdrefere".
                                 LEAVE Valida.
                              END.
                                    
                    END.
                ELSE    
                IF  par_cdhistor = 667 OR
                    par_cdhistor = 624 OR /*Celesc */
                    par_cdhistor = 928 THEN /* CERSAD */
                    DO:
                         IF  LENGTH(STRING(par_cdrefere)) > 9 THEN
                            DO:
                                ASSIGN aux_cdcritic = 654
                                       par_nmdcampo = "cdrefere".
                                LEAVE Valida.
                            END.       

                        ASSIGN aux_cdrefere = 
                                         DEC(STRING(par_cdrefere,"999999999")).
                        RUN digcel ( INPUT-OUTPUT aux_cdrefere,
                                     OUTPUT aux_stsnrcal ).
                        ASSIGN aux_cdrefere = 0.

                        IF  NOT aux_stsnrcal THEN
                            DO:
                                ASSIGN aux_cdcritic = 008 
                                       par_nmdcampo = "cdrefere".
                                LEAVE Valida.
                            END.
                
                                     
                    END.
                ELSE       
                IF  par_cdhistor = 635 THEN /* SAMAE GASPAR */
                    DO:
                         IF  par_cdrefere > 999999 THEN
                             DO:
                                 ASSIGN aux_cdcritic = 654
                                        par_nmdcampo = "cdrefere".
                                 LEAVE Valida.
                             END.                     

                         ASSIGN aux_cdrefere = DEC(STRING(par_cdrefere,"999999")).

                         RUN calculo-referencia-mod11 (INPUT-OUTPUT aux_cdrefere,
                                                       OUTPUT aux_nrdigito,
                                                       OUTPUT aux_stsnrcal).
                              
                         ASSIGN aux_cdrefere = 0.

                         /* Se digito nao confere gera erro */
                         IF  NOT aux_stsnrcal THEN
                             DO:
                                ASSIGN aux_cdcritic = 8
                                       par_nmdcampo = "cdrefere".
                                LEAVE Valida.
                             END.
                    END.
                ELSE
                IF  par_cdhistor = 616  OR   /* SAMAE Brusque */
                    par_cdhistor = 619  OR   /* SAMAE Pomerode */
                    par_cdhistor = 900  THEN /* SAMAE Rio Negrinho */
                    DO:
                        IF   par_cdrefere > 999999 THEN
                             DO:
                                 ASSIGN aux_cdcritic = 654
                                        par_nmdcampo = "cdrefere".
                                 LEAVE Valida.
                             END.                     
                
                        ASSIGN aux_cdrefere = DEC(STRING(par_cdrefere,"999999")).

                        IF  NOT VALID-HANDLE(h-b1wgen9998) THEN
                            RUN sistema/generico/procedures/b1wgen9998.p
                                PERSISTENT SET h-b1wgen9998.

                        RUN digm10 IN h-b1wgen9998 
                                    ( INPUT-OUTPUT aux_cdrefere,
                                     OUTPUT aux_nrdigito,
                                     OUTPUT aux_stsnrcal ).
        
                        ASSIGN aux_cdrefere = 0.

                        IF  VALID-HANDLE(h-b1wgen9998) THEN
                            DELETE PROCEDURE h-b1wgen9998.

                        IF  NOT aux_stsnrcal THEN
                            DO:
                                ASSIGN aux_cdcritic = 008
                                       par_nmdcampo = "cdrefere".
                                LEAVE Valida.
                            END.                              
                    END.
                ELSE                                 
                IF  par_cdhistor = 674 THEN /* SEMASA Itajai*/
                    DO:
                        ASSIGN aux_cdrefere = par_cdrefere.

                        RUN dig_semasa ( INPUT-OUTPUT aux_cdrefere,
                                         OUTPUT aux_stsnrcal ).

                        ASSIGN aux_cdrefere = 0.
                        
                        IF  NOT aux_stsnrcal THEN
                            DO:
                                ASSIGN aux_cdcritic = 008
                                       par_nmdcampo = "cdrefere".
                                LEAVE Valida.
                            END.
                            
                        IF  aux_cdrefere > 99999999 THEN /* 8 Digitos */
                            DO:
                                ASSIGN aux_cdcritic = 654
                                       par_nmdcampo = "cdrefere".
                                LEAVE Valida.
                            END.
                    END.
                ELSE
                /* Calcula digito para Casan, TELESC, Samae, B.T.V, Vivo, 
                   Aguas Itapema, DAE Naveg., Aguas Joinville, Aguas Pr.Getulio,
                   Foz do Brasil, Aguas de Massaranduba, Aguas de Itapocoroy  */   
                IF  CAN-DO("29,31,48,149,292,453,628,643,455,672,554,852,961,962,1130",
                           TRIM(STRING(par_cdhistor))) THEN
                    DO:
                        IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                            RUN sistema/generico/procedures/b1wgen9999.p
                                PERSISTENT SET h-b1wgen9999.
        
                        ASSIGN aux_cdrefere = par_cdrefere.

                        RUN dig_fun IN h-b1wgen9999 
                                    ( INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT 0,
                                      INPUT-OUTPUT aux_cdrefere,
                                     OUTPUT TABLE tt-erro ).

                        ASSIGN aux_cdrefere = 0.
                        IF  VALID-HANDLE(h-b1wgen9999) THEN
                            DELETE PROCEDURE h-b1wgen9999.
        
                        IF  RETURN-VALUE <> "OK"  THEN
                            DO:
                                ASSIGN par_nmdcampo = "cdrefere".
                                RETURN "NOK".
                            END.

                        IF  par_cdhistor = 31 THEN /* TELESC FIXA */
                            DO:
                                IF  LENGTH(STRING(par_cdrefere)) > 10 THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 654
                                               par_nmdcampo = "cdrefere".
                                        LEAVE Valida.
                                    END.    
                               
                                IF  par_cdrefere < 700000000 THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 654
                                               par_nmdcampo = "cdrefere".
                                        LEAVE Valida.
                                    END.     
                            END.
                        ELSE
                        IF  par_cdhistor = 29    OR    /* SAMAE BLUMENAU */
                            par_cdhistor = 643   OR    /* SAMAE BNU CECRED*/
                            par_cdhistor = 628   THEN  /* SAMAE TIMBO */
                            DO:
                                IF  par_cdrefere > 999999 THEN /* 6 Digitos*/
                                    DO:
                                        ASSIGN aux_cdcritic = 654
                                               par_nmdcampo = "cdrefere".
                                        LEAVE Valida.
                                    END.
                            END.
                        ELSE
                        IF  par_cdhistor = 852  THEN /* AGUAS PRES. GETULIO */
                            DO: 
                                IF  par_cdrefere > 999999999 THEN /* 9 Dig.*/
                                    DO:
                                        ASSIGN aux_cdcritic = 654
                                               par_nmdcampo = "cdrefere".
                                        LEAVE Valida.
                                    END.
                            END.
                        ELSE
                        IF  par_cdhistor = 149  THEN /* SAMAE JARAGUA DO SUL */
                            DO:
                                IF  par_cdrefere > 9999999999 THEN /* 10 Dig.*/
                                    DO:
                                        ASSIGN aux_cdcritic = 654
                                               par_nmdcampo = "cdrefere".
                                        LEAVE Valida.
                                    END.
                            END.
                        ELSE
                        IF  par_cdhistor = 453  THEN  /* VIVO */
                            DO:
                                IF  par_cdrefere > 99999999999 THEN /*11 Dig.*/
                                    DO:
                                        ASSIGN aux_cdcritic = 654
                                               par_nmdcampo = "cdrefere".
                                        LEAVE Valida.
                                    END.
                            END.
                        ELSE                        
                        IF  par_cdhistor = 48    OR   /* CASAN */
                            par_cdhistor = 455   OR   /* AGUAS ITAPEMA */
                            par_cdhistor = 672   OR   /* DAE NAVEGANTES */ 
                            par_cdhistor = 554   OR   /* AGUAS JOINVILLE */
                            par_cdhistor = 961   OR   /* FOZ DO BRASIL */
                            par_cdhistor = 962   OR   /* AGUAS DE MASSARANDUBA */ 
                            par_cdhistor = 1130  THEN /* AGUAS DE ITAPOCOROY */
                            DO:        
                                IF  par_cdrefere > 99999999 THEN /* 8 Dig.*/
                                    DO:
                                        ASSIGN aux_cdcritic = 654
                                               par_nmdcampo = "cdrefere".
                                        LEAVE Valida.
                                    END.
                            END.   
                    END.
                     
                FIND  crapatr WHERE crapatr.cdcooper = par_cdcooper  AND  
                                    crapatr.nrdconta = par_nrdconta  AND
                                    crapatr.cdhistor = par_cdhistor  AND
                                    crapatr.cdrefere = par_cdrefere  NO-LOCK
                                    USE-INDEX crapatr1 NO-ERROR.
                
                IF  AVAILABLE crapatr  THEN
                    DO:
                        IF  (par_cdhistor = 31   OR 
                             par_cdhistor = 288  OR
                             par_cdhistor = 834) AND  
                             crapatr.dtfimatr = 01/01/0001 THEN
                            .
                        ELSE
                            DO:
                                ASSIGN aux_cdcritic = 452
                                       par_nmdcampo = "cdrefere".
                                LEAVE Valida.
                            END.
                    END.
            END.
        ELSE
        IF  par_cddopcao = "E" THEN
            DO:

                 /* Nao sera permitido a exlusao de autorizacao de debito no dia do debito */
                 FIND FIRST craplau WHERE craplau.cdcooper = par_cdcooper AND
                                          craplau.nrdconta = par_nrdconta AND
                                          craplau.cdhistor = par_cdhistor AND
                                          craplau.nrdocmto = par_cdrefere AND
                                          craplau.dtmvtopg = par_dtmvtolt
                                          NO-LOCK NO-ERROR.
  
                  IF  AVAIL craplau THEN
                      DO:
                          ASSIGN aux_dscritic = "Nao permitido excluir optante do" +
                                                " debito automatico no dia do debito." +
                                                " Favor excluir no proximo dia util."
                                 par_nmdcampo = "".
                          LEAVE Valida.
                      END.

                FIND crapatr WHERE crapatr.cdcooper = par_cdcooper  AND  
                                   crapatr.nrdconta = par_nrdconta  AND
                                   crapatr.cdhistor = par_cdhistor  AND
                                   crapatr.cdrefere = par_cdrefere  NO-LOCK
                                   USE-INDEX crapatr1 NO-ERROR.
                IF  AVAIL crapatr THEN
                    DO: 
                        IF  crapatr.dtiniatr = par_dtmvtolt THEN
                            DO: 
                                ASSIGN aux_dscritic = "Esta alteracao podera" +
                                       " ser efetuada no proximo dia util."
                                       par_nmdcampo = "".
                                LEAVE Valida.
                            END.

                        LEAVE Valida.
                    END.                
            END.
        /*ELSE
        IF  par_cddopcao = "R" THEN
            DO:     
                IF  par_dtfimatr <> ? OR
                    par_dtiniatr > par_dtmvtolt OR
                    par_dtiniatr = ? THEN
                    DO:
                        ASSIGN aux_cdcritic = 013
                               par_nmdcampo = "dtautori". 
                        LEAVE Valida.
                    END.
            END.*/

        LEAVE Valida.

    END. /*  Fim do DO WHILE TRUE  */

    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
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

    RETURN "OK".

END PROCEDURE.

/* ************************************************************************ */
/*                   Verifica se autorizacao foi baixada                    */
/* ************************************************************************ */
PROCEDURE verifica-aut-baixada:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrefere AS DECI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    
    IF  CAN-FIND(FIRST crapatr 
                 WHERE crapatr.cdcooper = par_cdcooper AND
                       crapatr.nrdconta = par_nrdconta AND
                       crapatr.cdhistor = par_cdhistor AND
                       crapatr.cdrefere = par_cdrefere
                       USE-INDEX crapatr1) THEN
        DO:
            ASSIGN aux_cdcritic = 550.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,        
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
    

    RETURN "OK".

END PROCEDURE.

/* ************************************************************************ */
/*                           Gravacao dos dados                             */
/* ************************************************************************ */
PROCEDURE grava-dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdrefere AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cddddtel AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtiniatr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimatr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtultdeb AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmfatura AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlrmaxdb AS DECI                           NO-UNDO. /* Lunelli */

    DEF  INPUT PARAM par_flgsicre AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdempcon AS INTE                           NO-UNDO. /* Lunelli */
    DEF  INPUT PARAM par_cdsegmto AS INTE                           NO-UNDO. /* Lunelli */
    DEF  INPUT PARAM par_flgmanua AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_fatura01 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_fatura02 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_fatura03 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_fatura04 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_codbarra AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_nmfatret AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_retornvl AS CHAR INIT "NOK"                         NO-UNDO.
    DEF VAR aux_vlrcalcu AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdsegmto AS CHAR                                    NO-UNDO. 
    DEF VAR aux_cdempcon AS INTE                                    NO-UNDO.
    DEF VAR aux_cdempres AS CHAR                                    NO-UNDO.
    DEF VAR aux_tpautori AS INTE                                    NO-UNDO.
    DEF VAR aux_flgmaxdb AS LOGI                                    NO-UNDO.
    DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.   
    DEF VAR aux_dsnomcnv AS CHAR                                    NO-UNDO.    
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = (IF par_cddopcao = "E" THEN "Exclui" 
                           ELSE IF par_cddopcao = "I" THEN "Inclui" 
                           ELSE IF par_cddopcao = "R" THEN "Recadastra"
                           ELSE "Altera") + " autorizacao de debito em conta".
    
    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta 
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                UNDO Grava, LEAVE Grava.
            END.

        IF par_idorigem = 3 THEN /* IBANK */
        DO:
            /** Verifica o horario inicial e final para a operacao **/
            RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET
                                                            h-b1wgen0015.
    
            IF VALID-HANDLE(h-b1wgen0015) THEN
            DO:
                RUN horario_operacao IN h-b1wgen0015 (INPUT par_cdcooper,
                                                      INPUT par_cdagenci,
                                                      INPUT 11,
                                                      INPUT crapass.inpessoa,
                                                     OUTPUT aux_dscritic,
                                                     OUTPUT TABLE tt-limite).
    
                DELETE PROCEDURE h-b1wgen0015.
    
                IF RETURN-VALUE = "NOK" THEN
                    UNDO Grava, LEAVE Grava.
        
                FIND FIRST tt-limite NO-LOCK NO-ERROR.
                    
                IF NOT AVAILABLE tt-limite THEN
                DO:
                    ASSIGN aux_dscritic = "Tabela de limites nao encontrada.".
                    UNDO Grava, LEAVE Grava.
                END.
        
                /** Validar horario **/
                IF tt-limite.idesthor = 1 THEN /** Estourou horario   **/
                DO:
                    ASSIGN aux_dscritic = "Horario esgotado para realizar operacao " +
                                          "de Debito Automatico Facil.".
        
                    UNDO Grava, LEAVE Grava.
                END.
            END.
            ELSE
            DO:
                ASSIGN aux_dscritic = "Nao foi possivel realizar a operacao.".
                UNDO Grava, LEAVE Grava.
            END.
        END.

        IF  par_cddopcao = "I" THEN
            DO: 
                FIND gnconve WHERE gnconve.cdhisdeb = int(par_cdhistor)
                                                NO-LOCK NO-ERROR.

                IF  AVAIL(gnconve) THEN
                    DO:
                        FIND gncvcop WHERE gncvcop.cdcooper = par_cdcooper AND
                                           gncvcop.cdconven = gnconve.cdconven
                                           NO-LOCK NO-ERROR.
    
                        IF  NOT AVAIL(gncvcop) THEN
                            DO:
                                ASSIGN aux_dscritic = "Convenio nao cadastrado " +
                                                      "para a cooperativa.".
                                UNDO Grava, LEAVE Grava.
                            END.

                    END.

                /* Verifica convenio da empresa, e arrecadaçao por cod de barras */
                IF  par_idorigem = 2 /* CXONLINE */ OR
                    par_idorigem = 3 /* IBANK */    OR
                    par_idorigem = 4 /* TAA */      THEN
                    DO:
                        FIND FIRST crapcon WHERE crapcon.cdcooper = par_cdcooper AND
                                                 crapcon.cdempcon = par_cdempcon AND
                                                 crapcon.cdsegmto = par_cdsegmto NO-LOCK NO-ERROR.

                        IF  NOT AVAIL crapcon THEN
                            DO:
                                ASSIGN aux_dscritic = "Empresa nao conveniada.".
                                UNDO Grava, LEAVE Grava.
                            END.
                        ELSE
                            DO:
                                IF  crapcon.flgcnvsi = TRUE THEN
                                    DO:
                                        ASSIGN aux_dscritic = "Convevio indisponivel para Debito Automatico.".
                                        UNDO Grava, LEAVE Grava.
                                    END.
                            END.
                    END.    

                ASSIGN aux_vlrcalcu = "".

                IF  par_flgsicre = "yes" OR 
                    par_flgsicre = "S" THEN
                    DO:
                        IF  par_flgmanua = "yes" OR 
                            par_flgmanua = "S" THEN
                            DO: 
                                ASSIGN  aux_vlrcalcu  = SUBSTR(STRING(par_fatura01,"999999999999"),1,11) + 
                                                       SUBSTR(STRING(par_fatura02,"999999999999"),1,11) + 
                                                       SUBSTR(STRING(par_fatura03,"999999999999"),1,11) + 
                                                       SUBSTR(STRING(par_fatura04,"999999999999"),1,11).

                                FIND FIRST crapscn WHERE 
                                           crapscn.dsoparre = "E"                       AND
                                          (crapscn.cddmoden = "A"                       OR
                                           crapscn.cddmoden = "C")                      AND
                                           crapscn.cdempcon = INT(SUBSTR(aux_vlrcalcu,16,4)) AND
                                           crapscn.cdsegmto = SUBSTR(aux_vlrcalcu,2,1)
                                           NO-LOCK NO-ERROR NO-WAIT.
            
                                IF  AVAIL crapscn THEN
                                    ASSIGN aux_cdsegmto = crapscn.cdsegmto
                                           aux_cdempcon = crapscn.cdempcon 
                                           aux_cdempres = STRING(crapscn.cdempres). 

                            END.
                        ELSE
                            DO: 
                                FIND FIRST crapscn WHERE 
                                           crapscn.dsoparre = "E"                       AND
                                          (crapscn.cddmoden = "A"                       OR
                                           crapscn.cddmoden = "C")                      AND
                                           crapscn.cdempcon = INT(SUBSTR(par_codbarra,16,4)) AND
                                           crapscn.cdsegmto = SUBSTR(par_codbarra,2,1)
                                           NO-LOCK NO-ERROR NO-WAIT.

                                IF  AVAIL crapscn THEN
                                    ASSIGN aux_vlrcalcu  = par_codbarra
                                           aux_cdsegmto = crapscn.cdsegmto
                                           aux_cdempcon = crapscn.cdempcon
                                           aux_cdempres = crapscn.cdempres.
                            END.
                    END.
                ELSE /* Se nao for SICREDI assume dados diferentes, dependendo do tipo de origem */
                    DO:
                        IF  par_idorigem = 3 /* IBANK */    OR 
                            par_idorigem = 4 /* TAA */      OR
                            par_idorigem = 2 /* CXONLINE */ THEN
                            DO:
                                ASSIGN aux_cdempcon = par_cdempcon
                                       aux_cdsegmto = STRING(par_cdsegmto).

                                IF  par_idorigem = 3 /* IBANK */    THEN
                                    ASSIGN aux_tpautori = 1.
                                ELSE
                                IF  par_idorigem = 4 /* TAA */      THEN
                                    ASSIGN aux_tpautori = 2.
                                ELSE
                                IF  par_idorigem = 2 /* CXONLINE */ THEN
                                    ASSIGN aux_tpautori = 3.
                            END.
                        ELSE 
                            ASSIGN aux_cdempcon = 0
                                   aux_cdsegmto = "0".
                    END.

                IF  par_vlrmaxdb > 0 THEN
                    ASSIGN aux_flgmaxdb = TRUE.
                ELSE
                    ASSIGN aux_flgmaxdb = FALSE.

                IF  par_cdhistor = "31" THEN
                    DO:
                        ContadorAtr: DO aux_contador = 1 TO 10:

                            FIND crapatr WHERE 
                                 crapatr.cdcooper = par_cdcooper AND
                                 crapatr.nrdconta = par_nrdconta AND
                                 crapatr.cdhistor = int(par_cdhistor) AND
                                 crapatr.cdrefere = par_cdrefere
                                 USE-INDEX crapatr1
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            
                            IF  AVAILABLE crapatr THEN
                                DELETE crapatr.
                            ELSE
                            IF  LOCKED(crapatr)  THEN
                                DO:
                                    IF  aux_contador = 10 THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 341.
                                            UNDO Grava, LEAVE Grava.
                                        END.
                                    ELSE 
                                        DO:
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT ContadorAtr.
                                        END.
                                END.
                        END.
                    END.
                ELSE 
                    DO:
                        FIND crapatr WHERE 
                             crapatr.cdcooper = par_cdcooper      AND
                             crapatr.nrdconta = par_nrdconta      AND
                             crapatr.cdhistor = INT(par_cdhistor) AND
                             crapatr.cdrefere = par_cdrefere 
                             USE-INDEX crapatr1
                             NO-LOCK NO-ERROR NO-WAIT.
            
                        IF  AVAILABLE crapatr THEN
                            DO: 
                                ASSIGN aux_cdcritic = 452.
                                UNDO Grava, LEAVE Grava.
                            END.
                    END.

                    CREATE tt-autori-ant.
                    ASSIGN tt-autori-ant.cdcooper = par_cdcooper
                           tt-autori-ant.nrdconta = par_nrdconta.
                    
                    /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                    IF par_cdagenci = 0 THEN
                      ASSIGN par_cdagenci = glb_cdagenci.
                    /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */

                    CREATE crapatr.
                    ASSIGN crapatr.cdcooper = par_cdcooper
                           crapatr.nrdconta = par_nrdconta
                           crapatr.cdempcon = aux_cdempcon
                           crapatr.cdsegmto = INT(aux_cdsegmto)
                           crapatr.cdempres = IF par_flgsicre = "yes" OR 
                                                 par_flgsicre = "S" THEN 
                                                 aux_cdempres
                                              ELSE "0"
                           crapatr.cdrefere = par_cdrefere
                           crapatr.cdhistor = IF par_flgsicre = "yes" OR 
                                                 par_flgsicre = "S" THEN 
                                                 1019 
                                              ELSE INT(par_cdhistor)
                           crapatr.dtiniatr = par_dtmvtolt
                           crapatr.cdbarras = aux_vlrcalcu
                           crapatr.flgmaxdb = aux_flgmaxdb
                           crapatr.vlrmaxdb = par_vlrmaxdb
                           crapatr.tpautori = aux_tpautori
                           /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                           crapatr.cdopeori = par_cdoperad
                           crapatr.cdageori = par_cdagenci
                           crapatr.dtinsori = TODAY
                           /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                           crapatr.dshisext = par_nmfatura.

                    VALIDATE crapatr.

                    CREATE tt-autori-atl.
                    BUFFER-COPY crapatr TO tt-autori-atl.
                    
                    IF  par_idorigem = 3 THEN /** Internet **/
                        DO:
                            RUN sistema/generico/procedures/bo_algoritmo_seguranca.p 
                                    PERSISTENT SET h-bo_algoritmo_seguranca.
                
                            IF VALID-HANDLE(h-bo_algoritmo_seguranca) THEN
                            DO:
                                ASSIGN aux_dsinfor1 = "Cadastro - Inclusao"
                                       aux_dsinfor2 = crapass.nmprimtl
                                       aux_dsinfor3 = STRING(crapatr.cdrefere, 
                                                      "zzzzzzzzzzzzzzzz9") + "#" +
                                                      STRING(crapatr.vlrmaxdb,
                                                      "zzz,zzz,zz9.99")    + "#" +
                                                      crapatr.dshisext.
    
                                RUN gera_protocolo IN h-bo_algoritmo_seguranca 
                                          (INPUT par_cdcooper,
                                           INPUT par_dtmvtolt,
                                           INPUT TIME,
                                           INPUT par_nrdconta,
                                           INPUT crapatr.cdrefere,
                                           INPUT 0,     /** Autenticacao   **/
                                           INPUT 0,
                                           INPUT par_nrdcaixa,
                                           INPUT YES,   /** Gravar crappro **/
                                           INPUT 11,     /** Debito Facil  **/
                                           INPUT aux_dsinfor1,
                                           INPUT aux_dsinfor2,
                                           INPUT aux_dsinfor3,
                                           INPUT crapcon.nmextcon, /** Cedente **/
                                           INPUT FALSE, /** Agendamento **/
                                           INPUT 0,
                                           INPUT 0,
                                           INPUT "",
                                          OUTPUT aux_dsprotoc,
                                          OUTPUT aux_dscritic). 
                                                
                                DELETE PROCEDURE h-bo_algoritmo_seguranca.
        
                                IF RETURN-VALUE <> "OK" THEN
                                    UNDO Grava, LEAVE Grava.
        
                            END.
                        END.
                    ELSE
                        DO:
                            RUN verifica_log ( INPUT par_cdcooper,
                                               INPUT par_cdoperad,
                                               INPUT par_nrdconta,
                                               INPUT par_cdhistor,
                                               INPUT par_cdrefere,
                                               INPUT par_dtmvtolt,
                                               INPUT par_dtiniatr,
                                               INPUT par_dtfimatr,
                                               INPUT par_dtvencto,
                                               INPUT par_nmfatura,
                                               INPUT par_cddopcao ).
            
                            /*ASSIGN par_nmfatret = crapatr.nmfatura.*/
                        END.                    
            END.
        ELSE
        IF  par_cddopcao = "R" OR 
            par_cddopcao = "E" THEN
            DO: 
                IF  (par_cddopcao = "R" AND
                     par_dtfimatr = ? ) THEN
                    DO:
                        RUN verifica_log
                            ( INPUT par_cdcooper,
                              INPUT par_cdoperad,
                              INPUT par_nrdconta,
                              INPUT par_cdhistor,
                              INPUT par_cdrefere,
                              INPUT par_dtmvtolt,
                              INPUT par_dtiniatr,
                              INPUT par_dtfimatr,
                              INPUT par_dtvencto,
                              INPUT par_nmfatura,
                              INPUT par_cddopcao ).
                    END.

                Contador: DO aux_contador = 1 TO 10:

                    FIND crapatr WHERE crapatr.cdcooper = par_cdcooper AND
                                       crapatr.nrdconta = par_nrdconta AND
                                       crapatr.cdhistor = int(par_cdhistor) AND
                                       crapatr.cdrefere = par_cdrefere
                                       USE-INDEX crapatr1
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                    
                    IF  NOT AVAIL crapatr THEN
                        IF  LOCKED crapatr  THEN
                            DO:
                                IF  aux_contador = 10 THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 341.
                                        UNDO Grava, LEAVE Grava.
                                    END.
                                ELSE 
                                    DO:
                                        PAUSE 1 NO-MESSAGE.
                                        NEXT Contador.
                                    END.
                            END.
                        ELSE 
                            DO:
                                ASSIGN aux_cdcritic = 453.
                                UNDO Grava, LEAVE Grava.
                            END.
                    ELSE
                        DO:
                            /* Temp-table para geraçao de log */
                            CREATE tt-autori-ant.
                            BUFFER-COPY crapatr TO tt-autori-ant.
                        END.
                END.

                IF  par_cddopcao = "R" THEN
                    DO:  
                        IF  crapatr.dtfimatr <> ? THEN
                            ASSIGN crapatr.dtfimatr = ?.
                    
                        ASSIGN crapatr.dtiniatr = par_dtmvtolt.
                    END.
                ELSE
                IF  par_cddopcao = "E" THEN
                    DO:
                        
                         /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                        IF par_cdagenci = 0 THEN
                          ASSIGN par_cdagenci = glb_cdagenci.
                        /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */

                         /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                         ASSIGN crapatr.cdopeexc = par_cdoperad
                                crapatr.cdageexc = par_cdagenci
                                crapatr.dtinsexc = TODAY.
                         /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */

                        IF  crapatr.dtfimatr = ? AND 
                            par_idorigem <> 4    THEN /* TAA */
                            DO:
                                ASSIGN crapatr.dtfimatr = par_dtmvtolt.
                                CREATE tt-autori-atl.
                                BUFFER-COPY crapatr TO tt-autori-atl.
                            END.
                        ELSE
                            DO:
                                CREATE tt-autori-atl.
                                ASSIGN tt-autori-atl.cdcooper = par_cdcooper
                                       tt-autori-atl.nrdconta = par_nrdconta.
                                DELETE crapatr.
                            END.

                        RUN verifica_log ( INPUT par_cdcooper,
                                           INPUT par_cdoperad,
                                           INPUT par_nrdconta,
                                           INPUT par_cdhistor,
                                           INPUT par_cdrefere,
                                           INPUT par_dtmvtolt,
                                           INPUT par_dtiniatr,
                                           INPUT par_dtfimatr,
                                           INPUT par_dtvencto,
                                           INPUT par_nmfatura,
                                           INPUT par_cddopcao ).
                    END.
            END.

            IF  AVAIL crapatr AND CAN-DO("A,R",par_cddopcao)  THEN
                DO:
                    /* Temp-table para geraçao de log de alteraçao */
                    CREATE tt-autori-atl.
                    BUFFER-COPY crapatr TO tt-autori-atl.
                END.
        
            ASSIGN aux_retornvl = "OK".
    END.

   RELEASE crapatr.
    
   IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
        DO: 

            /*ASSIGN aux_dscritic = "Erro na transacao. Nao foi " + 
                                  "possivel confirmar novo limite.". */

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.

    IF  par_flgerlog  THEN
        RUN proc_gerar_log_tab (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT (IF  aux_retornvl = "OK" THEN TRUE 
                                       ELSE FALSE),
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                            INPUT TRUE,
                            INPUT BUFFER tt-autori-ant:HANDLE,
                            INPUT BUFFER tt-autori-atl:HANDLE ).

    RETURN aux_retornvl.

END PROCEDURE.

PROCEDURE busca_convenios_codbarras:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdempcon AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdsegmto AS INTE NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-convenios-codbarras.

    FOR EACH crapcon WHERE crapcon.cdcooper =  par_cdcooper         AND
                           crapcon.flgcnvsi =  FALSE                AND
                           crapcon.cdempcon >= par_cdempcon         AND
                           crapcon.cdsegmto >= par_cdsegmto         NO-LOCK,
        FIRST gnconve WHERE gnconve.cdhiscxa = crapcon.cdhistor AND
                            gnconve.flgativo = TRUE             AND
                            gnconve.nmarqatu <> ""              AND
                            gnconve.cdhisdeb <> 0 NO-LOCK:

        CREATE tt-convenios-codbarras.
        ASSIGN tt-convenios-codbarras.nmextcon = crapcon.nmextcon
               tt-convenios-codbarras.nmrescon = crapcon.nmrescon
               tt-convenios-codbarras.cdempcon = crapcon.cdempcon
               tt-convenios-codbarras.cdsegmto = crapcon.cdsegmto.
               tt-convenios-codbarras.cdhistor = gnconve.cdhisdeb.


    END.

END PROCEDURE.

PROCEDURE busca_autorizacoes_cadastradas:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-autorizacoes-cadastradas.

    
    FOR EACH crapatr WHERE crapatr.cdcooper = par_cdcooper AND
                           crapatr.nrdconta = par_nrdconta AND
                           crapatr.tpautori <> 0           AND
                           (((par_cddopcao = "A" OR par_cddopcao = "E")   AND
                             crapatr.dtiniatr = par_dtmvtolt)             OR
                            (par_cddopcao = "C" OR par_cddopcao = "S"))   AND
                           crapatr.dtfimatr = ? /* ativa */               AND
                           ((par_cddopcao = "S" AND crapatr.dtfimsus = ?) OR
                            (par_cddopcao <> "S"))                    NO-LOCK,
        FIRST crapcon WHERE crapcon.cdcooper = crapatr.cdcooper AND
                            crapcon.cdempcon = crapatr.cdempcon AND
                            crapcon.cdsegmto = crapatr.cdsegmto AND
                            crapcon.flgcnvsi = FALSE NO-LOCK:

        CREATE tt-autorizacoes-cadastradas.
        ASSIGN tt-autorizacoes-cadastradas.nmextcon = crapcon.nmextcon
               tt-autorizacoes-cadastradas.nmrescon = crapcon.nmrescon
               tt-autorizacoes-cadastradas.cdempcon = crapatr.cdempcon
               tt-autorizacoes-cadastradas.cdsegmto = crapatr.cdsegmto
               tt-autorizacoes-cadastradas.cdrefere = crapatr.cdrefere
               tt-autorizacoes-cadastradas.vlmaxdeb = crapatr.vlrmaxdb
               tt-autorizacoes-cadastradas.dshisext = crapatr.dshisext.
    END.

END PROCEDURE.

PROCEDURE altera_autorizacao:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdsegmto AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdempcon AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdrefere AS DECI NO-UNDO.
    DEF INPUT PARAM par_vlmaxdeb AS DECI NO-UNDO.
    DEF INPUT PARAM par_dshisext AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE INIT 0  NO-UNDO.

    DEF VAR aux_vlmaxdeb AS DECI         NO-UNDO.
    DEF VAR aux_dshisext AS CHAR         NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    Altera: DO WHILE TRUE TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        FIND crapatr WHERE crapatr.cdcooper = par_cdcooper AND
                           crapatr.nrdconta = par_nrdconta AND
                           crapatr.cdsegmto = par_cdsegmto AND
                           crapatr.cdempcon = par_cdempcon AND
                           crapatr.cdrefere = par_cdrefere AND
                           crapatr.tpautori <> 0
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF NOT AVAIL crapatr THEN
        DO:
            IF LOCKED crapatr THEN
            DO:
                ASSIGN aux_contador = aux_contador + 1.

                IF aux_contador = 10 THEN
                DO:
                    ASSIGN aux_dscritic = "Tabela CRAPATR esta em uso.".

                    LEAVE Altera.
                END.
            END.
            ELSE
            DO:
                ASSIGN aux_dscritic = "Autorizacao nao encontrada.".

                LEAVE Altera.
            END.
        END.
        ELSE
        DO:
            IF par_vlmaxdeb = crapatr.vlrmaxdb AND
               par_dshisext = crapatr.dshisext THEN
            DO:
                ASSIGN aux_dscritic = "Nao foi realizada nenhuma alteracao".

                LEAVE Altera.
            END.

            ASSIGN aux_vlmaxdeb     = crapatr.vlrmaxdb
                   aux_dshisext     = crapatr.dshisext
                   crapatr.vlrmaxdb = par_vlmaxdeb
                   crapatr.flgmaxdb = par_vlmaxdeb > 0
                   crapatr.dshisext = par_dshisext.

            /* gera protocolo */
            RUN sistema/generico/procedures/bo_algoritmo_seguranca.p 
                    PERSISTENT SET h-bo_algoritmo_seguranca.

            IF VALID-HANDLE(h-bo_algoritmo_seguranca) THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapass  THEN
                DO:
                    ASSIGN aux_cdcritic = 9.
                    UNDO Altera, LEAVE Altera.
                END.

                /** Verifica o horario inicial e final para a operacao **/
                RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET
                                                                h-b1wgen0015.
        
                IF VALID-HANDLE(h-b1wgen0015) THEN
                DO:
                    RUN horario_operacao IN h-b1wgen0015 (INPUT par_cdcooper,
                                                          INPUT 90,
                                                          INPUT 11,
                                                          INPUT crapass.inpessoa,
                                                         OUTPUT aux_dscritic,
                                                         OUTPUT TABLE tt-limite).

                    DELETE PROCEDURE h-b1wgen0015.
            
                    IF RETURN-VALUE = "NOK" THEN
                        UNDO Altera, LEAVE Altera.
            
                    FIND FIRST tt-limite NO-LOCK NO-ERROR.
                        
                    IF NOT AVAILABLE tt-limite THEN
                    DO:
                        ASSIGN aux_dscritic = "Tabela de limites nao encontrada.".
                        UNDO Altera, LEAVE Altera.
                    END.
            
                    /** Validar horario **/
                    IF tt-limite.idesthor = 1 THEN /** Estourou horario   **/
                    DO:
                        ASSIGN aux_dscritic = "Horario esgotado para realizar operacao " +
                                              "de Debito Automatico Facil.".
            
                        UNDO Altera, LEAVE Altera.
                    END.
                END.
                ELSE
                DO:
                    ASSIGN aux_dscritic = "Nao foi possivel realizar a operacao.".
                    UNDO Altera, LEAVE Altera.
                END.

                FIND FIRST crapcon WHERE crapcon.cdcooper = par_cdcooper AND
                                         crapcon.cdempcon = par_cdempcon AND
                                         crapcon.cdsegmto = par_cdsegmto AND
                                         crapcon.flgcnvsi = FALSE 
                                         NO-LOCK NO-ERROR.


                IF NOT AVAIL crapcon THEN
                DO:
                    ASSIGN aux_dscritic = "Empresa nao conveniada.".
                    UNDO Altera, LEAVE Altera.
                END.

                ASSIGN aux_dsinfor1 = "Cadastro - Alteracao"
                       aux_dsinfor2 = crapass.nmprimtl
                       aux_dsinfor3 = STRING(crapatr.cdrefere, 
                                      "zzzzzzzzzzzzzzzz9") + "#" +
                                      aux_dshisext         + "#" +
                                      crapatr.dshisext     + "#" +
                                      STRING(aux_vlmaxdeb,
                                      "zzz,zzz,zz9.99")    + "#" +
                                      STRING(crapatr.vlrmaxdb,
                                      "zzz,zzz,zz9.99").

                RUN gera_protocolo IN h-bo_algoritmo_seguranca 
                          (INPUT par_cdcooper,
                           INPUT par_dtmvtolt,
                           INPUT TIME,
                           INPUT par_nrdconta,
                           INPUT crapatr.cdrefere,
                           INPUT 0,     /** Autenticacao   **/
                           INPUT 0,
                           INPUT 0,
                           INPUT YES,   /** Gravar crappro **/
                           INPUT 11,     /** Debito Facil  **/
                           INPUT aux_dsinfor1,
                           INPUT aux_dsinfor2,
                           INPUT aux_dsinfor3,
                           INPUT crapcon.nmextcon, /** Cedente **/
                           INPUT FALSE, /** Agendamento **/
                           INPUT 0,
                           INPUT 0,
                           INPUT "",
                          OUTPUT aux_dsprotoc,
                          OUTPUT aux_dscritic). 
                                
                DELETE PROCEDURE h-bo_algoritmo_seguranca.

                IF RETURN-VALUE <> "OK" THEN
                    UNDO Altera, LEAVE Altera.

            END.
                    

            LEAVE Altera.
        END.
    END. /* END TRANSACTION */

    IF  aux_cdcritic <> 0 OR aux_dscritic <> ""  THEN
    DO: 
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 90,
                       INPUT 0,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE exclui_autorizacao:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdsegmto AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdempcon AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdrefere AS DECI NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE INIT 0  NO-UNDO.

    DEF VAR aux_cdrefere AS DECI         NO-UNDO.
    DEF VAR aux_vlmaxdeb AS DECI         NO-UNDO.
    DEF VAR aux_dshisext AS CHAR         NO-UNDO.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    Exclui: DO WHILE TRUE TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        FIND crapatr WHERE crapatr.cdcooper = par_cdcooper AND
                           crapatr.nrdconta = par_nrdconta AND
                           crapatr.cdsegmto = par_cdsegmto AND
                           crapatr.cdempcon = par_cdempcon AND
                           crapatr.cdrefere = par_cdrefere AND
                           crapatr.tpautori <> 0
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF NOT AVAIL crapatr THEN
        DO:
            IF LOCKED crapatr THEN
            DO:
                ASSIGN aux_contador = aux_contador + 1.

                IF aux_contador = 10 THEN
                DO:
                    ASSIGN aux_dscritic = "Tabela CRAPATR esta em uso.".

                    LEAVE Exclui.
                END.
            END.
            ELSE
            DO:
                ASSIGN aux_dscritic = "Autorizacao nao encontrada.".

                LEAVE Exclui.
            END.
        END.
        ELSE
        DO:
            ASSIGN aux_cdrefere = crapatr.cdrefere
                   aux_vlmaxdeb = crapatr.vlrmaxdb
                   aux_dshisext = crapatr.dshisext.

            DELETE crapatr.

            /* gera protocolo */
            RUN sistema/generico/procedures/bo_algoritmo_seguranca.p 
                    PERSISTENT SET h-bo_algoritmo_seguranca.

            IF VALID-HANDLE(h-bo_algoritmo_seguranca) THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapass  THEN
                DO:
                    ASSIGN aux_cdcritic = 9.
                    UNDO Exclui, LEAVE Exclui.
                END.

                /** Verifica o horario inicial e final para a operacao **/
                RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET
                                                                h-b1wgen0015.
        
                IF VALID-HANDLE(h-b1wgen0015) THEN
                DO:
                    RUN horario_operacao IN h-b1wgen0015 (INPUT par_cdcooper,
                                                          INPUT 90,
                                                          INPUT 11,
                                                          INPUT crapass.inpessoa,
                                                         OUTPUT aux_dscritic,
                                                         OUTPUT TABLE tt-limite).

                    DELETE PROCEDURE h-b1wgen0015.
            
                    IF RETURN-VALUE = "NOK" THEN
                        UNDO Exclui, LEAVE Exclui.
            
                    FIND FIRST tt-limite NO-LOCK NO-ERROR.
                        
                    IF NOT AVAILABLE tt-limite THEN
                    DO:
                        ASSIGN aux_dscritic = "Tabela de limites nao encontrada.".
                        UNDO Exclui, LEAVE Exclui.
                    END.
            
                    /** Validar horario **/
                    IF tt-limite.idesthor = 1 THEN /** Estourou horario   **/
                    DO:
                        ASSIGN aux_dscritic = "Horario esgotado para realizar operacao " +
                                              "de Debito Automatico Facil.".
            
                        UNDO Exclui, LEAVE Exclui.
                    END.
                END.
                ELSE
                DO:
                    ASSIGN aux_dscritic = "Nao foi possivel realizar a operacao.".
                    UNDO Exclui, LEAVE Exclui.
                END.

                FIND FIRST crapcon WHERE crapcon.cdcooper = par_cdcooper AND
                                         crapcon.cdempcon = par_cdempcon AND
                                         crapcon.cdsegmto = par_cdsegmto AND
                                         crapcon.flgcnvsi = FALSE 
                                         NO-LOCK NO-ERROR.


                IF NOT AVAIL crapcon THEN
                DO:
                    ASSIGN aux_dscritic = "Empresa nao conveniada.".
                    UNDO Exclui, LEAVE Exclui.
                END.

                ASSIGN aux_dsinfor1 = "Cadastro - Exclusao"
                       aux_dsinfor2 = crapass.nmprimtl
                       aux_dsinfor3 = STRING(aux_cdrefere, 
                                      "zzzzzzzzzzzzzzzz9") + "#" +
                                      STRING(aux_vlmaxdeb,
                                      "zzz,zzz,zz9.99")    + "#" +
                                      aux_dshisext.

                RUN gera_protocolo IN h-bo_algoritmo_seguranca 
                          (INPUT par_cdcooper,
                           INPUT par_dtmvtolt,
                           INPUT TIME,
                           INPUT par_nrdconta,
                           INPUT aux_cdrefere,
                           INPUT 0,     /** Autenticacao   **/
                           INPUT 0,
                           INPUT 0,
                           INPUT YES,   /** Gravar crappro **/
                           INPUT 11,     /** Debito Facil  **/
                           INPUT aux_dsinfor1,
                           INPUT aux_dsinfor2,
                           INPUT aux_dsinfor3,
                           INPUT crapcon.nmextcon, /** Cedente **/
                           INPUT FALSE, /** Agendamento **/
                           INPUT 0,
                           INPUT 0,
                           INPUT "",
                          OUTPUT aux_dsprotoc,
                          OUTPUT aux_dscritic). 
                                
                DELETE PROCEDURE h-bo_algoritmo_seguranca.

                IF RETURN-VALUE <> "OK" THEN
                    UNDO Exclui, LEAVE Exclui.

            END.

            LEAVE Exclui.
        END.
    END. /* END TRANSACTION */

    IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
    DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 90,
                       INPUT 0,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE valida_datas_suspensao:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdsegmto AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdempcon AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdrefere AS DECI NO-UNDO.
    DEF INPUT PARAM par_dtinisus AS DATE NO-UNDO.
    DEF INPUT PARAM par_dtfimsus AS DATE NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF AVAIL crapcop THEN
    DO:
        IF crapcop.qtdiasus = 0 THEN
        DO:
            ASSIGN aux_dscritic = "Quantidade de dias limite para suspensao " +
                                  "nao cadastrada.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 90,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
    END.
    ELSE
    DO:
        ASSIGN aux_dscritic = "Tabela cadastro de cooperativas nao existe.".
            
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 90,
                       INPUT 0,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    IF par_dtfimsus > (par_dtmvtolt + crapcop.qtdiasus) THEN
    DO:
        ASSIGN aux_dscritic = "Data limite para suspensao nao pode ser " +
                              "maior que " + 
                              STRING(par_dtmvtolt + crapcop.qtdiasus, 
                                     "99/99/9999") + ".".
            
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 90,
                       INPUT 0,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    IF par_dtinisus < par_dtmvtolt THEN
    DO:
        ASSIGN aux_dscritic = "Data de inicio da suspensao nao pode ser " +
                               "menor que a data atual.".
            
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 90,
                       INPUT 0,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.
    
    IF par_dtinisus = par_dtfimsus THEN
    DO:
      ASSIGN aux_dscritic = "Data de inicio da suspensao e data final " +
                               "nao podem ser iguais.".
            
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 90,
                       INPUT 0,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE cadastra_suspensao_autorizacao:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_cdsegmto AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdempcon AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdrefere AS DECI NO-UNDO.
    DEF INPUT PARAM par_dtinisus AS DATE NO-UNDO.
    DEF INPUT PARAM par_dtfimsus AS DATE NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE INIT 0  NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    Bloqueia: DO WHILE TRUE TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        FIND crapatr WHERE crapatr.cdcooper = par_cdcooper AND
                           crapatr.nrdconta = par_nrdconta AND
                           crapatr.cdsegmto = par_cdsegmto AND
                           crapatr.cdempcon = par_cdempcon AND
                           crapatr.cdrefere = par_cdrefere AND
                           crapatr.tpautori <> 0
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF NOT AVAIL crapatr THEN
        DO:
            IF LOCKED crapatr THEN
            DO:
                ASSIGN aux_contador = aux_contador + 1.

                IF aux_contador = 10 THEN
                DO:
                    ASSIGN aux_dscritic = "Tabela CRAPATR esta em uso.".

                    LEAVE Bloqueia.
                END.
            END.
            ELSE
            DO:
                ASSIGN aux_dscritic = "Autorizacao nao encontrada.".

                LEAVE Bloqueia.
            END.
        END.
        ELSE
        DO:
            ASSIGN crapatr.dtinisus = par_dtinisus
                   crapatr.dtfimsus = par_dtfimsus.

            /* gera protocolo */
            RUN sistema/generico/procedures/bo_algoritmo_seguranca.p 
                    PERSISTENT SET h-bo_algoritmo_seguranca.

            IF VALID-HANDLE(h-bo_algoritmo_seguranca) THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapass  THEN
                DO:
                    ASSIGN aux_cdcritic = 9.
                    UNDO Bloqueia, LEAVE Bloqueia.
                END.

                /** Verifica o horario inicial e final para a operacao **/
                RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET
                                                                h-b1wgen0015.
        
                IF VALID-HANDLE(h-b1wgen0015) THEN
                DO:
                    RUN horario_operacao IN h-b1wgen0015 (INPUT par_cdcooper,
                                                          INPUT 90,
                                                          INPUT 11,
                                                          INPUT crapass.inpessoa,
                                                         OUTPUT aux_dscritic,
                                                         OUTPUT TABLE tt-limite).

                    DELETE PROCEDURE h-b1wgen0015.
            
                    IF RETURN-VALUE = "NOK" THEN
                        UNDO Bloqueia, LEAVE Bloqueia.
            
                    FIND FIRST tt-limite NO-LOCK NO-ERROR.
                        
                    IF NOT AVAILABLE tt-limite THEN
                    DO:
                        ASSIGN aux_dscritic = "Tabela de limites nao encontrada.".
                        UNDO Bloqueia, LEAVE Bloqueia.
                    END.
            
                    /** Validar horario **/
                    IF tt-limite.idesthor = 1 THEN /** Estourou horario   **/
                    DO:
                        ASSIGN aux_dscritic = "Horario esgotado para realizar operacao " +
                                              "de Debito Automatico Facil.".
            
                        UNDO Bloqueia, LEAVE Bloqueia.
                    END.
                END.
                ELSE
                DO:
                    ASSIGN aux_dscritic = "Nao foi possivel realizar a operacao.".
                    UNDO Bloqueia, LEAVE Bloqueia.
                END.

                FIND FIRST crapcon WHERE crapcon.cdcooper = par_cdcooper AND
                                         crapcon.cdempcon = par_cdempcon AND
                                         crapcon.cdsegmto = par_cdsegmto AND
                                         crapcon.flgcnvsi = FALSE 
                                         NO-LOCK NO-ERROR.


                IF NOT AVAIL crapcon THEN
                DO:
                    ASSIGN aux_dscritic = "Empresa nao conveniada.".
                    UNDO Bloqueia, LEAVE Bloqueia.
                END.

                ASSIGN aux_dsinfor1 = "Suspensao - Inclusao"
                       aux_dsinfor2 = crapass.nmprimtl
                       aux_dsinfor3 = STRING(crapatr.cdrefere, 
                                      "zzzzzzzzzzzzzzzz9") + "#" +
                                      STRING(crapatr.vlrmaxdb,
                                      "zzz,zzz,zz9.99")    + "#" +
                                      STRING(crapatr.dtinisus,
                                      "99/99/9999")        + "#" +
                                      STRING(crapatr.dtfimsus,
                                      "99/99/9999").

                RUN gera_protocolo IN h-bo_algoritmo_seguranca 
                          (INPUT par_cdcooper,
                           INPUT par_dtmvtolt,
                           INPUT TIME,
                           INPUT par_nrdconta,
                           INPUT crapatr.cdrefere,
                           INPUT 0,     /** Autenticacao   **/
                           INPUT 0,
                           INPUT 0,
                           INPUT YES,   /** Gravar crappro **/
                           INPUT 11,     /** Debito Facil  **/
                           INPUT aux_dsinfor1,
                           INPUT aux_dsinfor2,
                           INPUT aux_dsinfor3,
                           INPUT crapcon.nmextcon, /** Cedente **/
                           INPUT FALSE, /** Agendamento **/
                           INPUT 0,
                           INPUT 0,
                           INPUT "",
                          OUTPUT aux_dsprotoc,
                          OUTPUT aux_dscritic). 
                                
                DELETE PROCEDURE h-bo_algoritmo_seguranca.

                IF RETURN-VALUE <> "OK" THEN
                    UNDO Bloqueia, LEAVE Bloqueia.

            END.

            LEAVE Bloqueia.
        END.
    END.

    IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
    DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 90,
                       INPUT 0,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca_autorizacoes_suspensas:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-autorizacoes-suspensas.

    
    FOR EACH crapatr WHERE crapatr.cdcooper = par_cdcooper AND
                           crapatr.nrdconta = par_nrdconta AND
                           crapatr.tpautori <> 0           AND
                           ((par_cddopcao = "C" AND
                             crapatr.dtfimsus >= par_dtmvtolt) OR
                            (par_cddopcao = "E" AND
                             crapatr.dtfimsus > par_dtmvtolt)) NO-LOCK,
        FIRST crapcon WHERE crapcon.cdcooper = crapatr.cdcooper AND
                            crapcon.cdempcon = crapatr.cdempcon AND
                            crapcon.cdsegmto = crapatr.cdsegmto AND
                            crapcon.flgcnvsi = FALSE NO-LOCK:

        CREATE tt-autorizacoes-suspensas.
        ASSIGN tt-autorizacoes-suspensas.nmextcon = crapcon.nmextcon
               tt-autorizacoes-suspensas.nmrescon = crapcon.nmrescon
               tt-autorizacoes-suspensas.cdempcon = crapatr.cdempcon
               tt-autorizacoes-suspensas.cdsegmto = crapatr.cdsegmto
               tt-autorizacoes-suspensas.cdrefere = crapatr.cdrefere
               tt-autorizacoes-suspensas.dtinisus = crapatr.dtinisus
               tt-autorizacoes-suspensas.dtfimsus = crapatr.dtfimsus.
    END.

END PROCEDURE.

PROCEDURE exclui_suspensao_autorizacao:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdsegmto AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdempcon AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdrefere AS DECI NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE INIT 0  NO-UNDO.

    DEF VAR aux_dtfimsus AS DATE         NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    Desbloqueia: DO WHILE TRUE TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        FIND crapatr WHERE crapatr.cdcooper = par_cdcooper AND
                           crapatr.nrdconta = par_nrdconta AND
                           crapatr.cdsegmto = par_cdsegmto AND
                           crapatr.cdempcon = par_cdempcon AND
                           crapatr.cdrefere = par_cdrefere AND
                           crapatr.tpautori <> 0
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF NOT AVAIL crapatr THEN
        DO:
            IF LOCKED crapatr THEN
            DO:
                ASSIGN aux_contador = aux_contador + 1.

                IF aux_contador = 10 THEN
                DO:
                    ASSIGN aux_dscritic = "Tabela CRAPATR esta em uso.".

                    LEAVE Desbloqueia.
                END.
            END.
            ELSE
            DO:
                ASSIGN aux_dscritic = "Autorizacao nao encontrada.".

                LEAVE Desbloqueia.
            END.
        END.
        ELSE
        DO:            
            ASSIGN aux_dtfimsus     = crapatr.dtfimsus
                   crapatr.dtfimsus = par_dtmvtolt.

            /* gera protocolo */
            RUN sistema/generico/procedures/bo_algoritmo_seguranca.p 
                    PERSISTENT SET h-bo_algoritmo_seguranca.

            IF VALID-HANDLE(h-bo_algoritmo_seguranca) THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapass  THEN
                DO:
                    ASSIGN aux_cdcritic = 9.
                    UNDO Desbloqueia, LEAVE Desbloqueia.
                END.

                /** Verifica o horario inicial e final para a operacao **/
                RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET
                                                                h-b1wgen0015.
        
                IF VALID-HANDLE(h-b1wgen0015) THEN
                DO:
                    RUN horario_operacao IN h-b1wgen0015 (INPUT par_cdcooper,
                                                          INPUT 90,
                                                          INPUT 11,
                                                          INPUT crapass.inpessoa,
                                                         OUTPUT aux_dscritic,
                                                         OUTPUT TABLE tt-limite).

                    DELETE PROCEDURE h-b1wgen0015.
            
                    IF RETURN-VALUE = "NOK" THEN
                        UNDO Desbloqueia, LEAVE Desbloqueia.
            
                    FIND FIRST tt-limite NO-LOCK NO-ERROR.
                        
                    IF NOT AVAILABLE tt-limite THEN
                    DO:
                        ASSIGN aux_dscritic = "Tabela de limites nao encontrada.".
                        UNDO Desbloqueia, LEAVE Desbloqueia.
                    END.
            
                    /** Validar horario **/
                    IF tt-limite.idesthor = 1 THEN /** Estourou horario   **/
                    DO:
                        ASSIGN aux_dscritic = "Horario esgotado para realizar operacao " +
                                              "de Debito Automatico Facil.".
            
                        UNDO Desbloqueia, LEAVE Desbloqueia.
                    END.
                END.
                ELSE
                DO:
                    ASSIGN aux_dscritic = "Nao foi possivel realizar a operacao.".
                    UNDO Desbloqueia, LEAVE Desbloqueia.
                END.

                FIND FIRST crapcon WHERE crapcon.cdcooper = par_cdcooper AND
                                         crapcon.cdempcon = par_cdempcon AND
                                         crapcon.cdsegmto = par_cdsegmto AND
                                         crapcon.flgcnvsi = FALSE 
                                         NO-LOCK NO-ERROR.


                IF NOT AVAIL crapcon THEN
                DO:
                    ASSIGN aux_dscritic = "Empresa nao conveniada.".
                    UNDO Desbloqueia, LEAVE Desbloqueia.
                END.

                ASSIGN aux_dsinfor1 = "Suspensao - Exclusao"
                       aux_dsinfor2 = crapass.nmprimtl
                       aux_dsinfor3 = STRING(crapatr.cdrefere, 
                                      "zzzzzzzzzzzzzzzz9") + "#" +
                                      STRING(crapatr.vlrmaxdb,
                                      "zzz,zzz,zz9.99")    + "#" +
                                      STRING(crapatr.dtinisus,
                                      "99/99/9999")        + "#" +
                                      STRING(aux_dtfimsus,
                                      "99/99/9999").

                RUN gera_protocolo IN h-bo_algoritmo_seguranca 
                          (INPUT par_cdcooper,
                           INPUT par_dtmvtolt,
                           INPUT TIME,
                           INPUT par_nrdconta,
                           INPUT crapatr.cdrefere,
                           INPUT 0,     /** Autenticacao   **/
                           INPUT 0,
                           INPUT 0,
                           INPUT YES,   /** Gravar crappro **/
                           INPUT 11,     /** Debito Facil  **/
                           INPUT aux_dsinfor1,
                           INPUT aux_dsinfor2,
                           INPUT aux_dsinfor3,
                           INPUT crapcon.nmextcon, /** Cedente **/
                           INPUT FALSE, /** Agendamento **/
                           INPUT 0,
                           INPUT 0,
                           INPUT "",
                          OUTPUT aux_dsprotoc,
                          OUTPUT aux_dscritic). 
                                
                DELETE PROCEDURE h-bo_algoritmo_seguranca.

                IF RETURN-VALUE <> "OK" THEN
                    UNDO Desbloqueia, LEAVE Desbloqueia.

            END.
            
            LEAVE Desbloqueia.
        END.
    END.

    IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
    DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 90,
                       INPUT 0,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE busca_lancamentos:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_dtiniper AS DATE NO-UNDO.
    DEF INPUT PARAM par_dtfimper AS DATE NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-lancamentos.
    
    /* busca os lancamentos agendados (PENDENTES e BLOQUEADOS) */
    FOR EACH craplau WHERE craplau.cdcooper = par_cdcooper      AND
                           craplau.nrdconta = par_nrdconta      AND
                           craplau.insitlau = 1                 AND
                           ((par_cddopcao = "C"                 AND
                             craplau.dtmvtopg >= par_dtiniper   AND
                             craplau.dtmvtopg <= par_dtfimper   AND
                             craplau.dtmvtopg >= par_dtmvtolt)  OR
                            (par_cddopcao <> "C"                AND
                             craplau.dtmvtopg > par_dtmvtolt))  AND
                           ((par_cddopcao = "B"                 AND
                             craplau.flgblqdb = FALSE)          OR
                            (par_cddopcao = "D"                 AND
                             craplau.flgblqdb = TRUE)           OR
                            (par_cddopcao = "C"))               NO-LOCK,
        FIRST crapatr WHERE crapatr.cdcooper = craplau.cdcooper AND
                            crapatr.nrdconta = craplau.nrdconta AND
                            crapatr.cdhistor = craplau.cdhistor AND
                            crapatr.cdrefere = craplau.nrdocmto AND
                            crapatr.tpautori <> 0               NO-LOCK,
        FIRST gnconve WHERE gnconve.flgativo = TRUE             AND
                            gnconve.cdhisdeb = crapatr.cdhistor AND
                            gnconve.nmarqatu <> ""              NO-LOCK,
        FIRST crapcon WHERE crapcon.cdcooper = crapatr.cdcooper AND
                            crapcon.cdsegmto = crapatr.cdsegmto AND
                            crapcon.cdempcon = crapatr.cdempcon AND
                            crapcon.cdhistor = gnconve.cdhiscxa AND
                            crapcon.flgcnvsi = FALSE            NO-LOCK:

        CREATE tt-lancamentos.
        ASSIGN tt-lancamentos.dtmvtolt = craplau.dtmvtopg
               tt-lancamentos.nmextcon = crapcon.nmextcon
               tt-lancamentos.dshisext = crapatr.dshisext
               tt-lancamentos.nrdocmto = craplau.nrdocmto
               tt-lancamentos.vllanmto = craplau.vllanaut
               tt-lancamentos.cdhistor = craplau.cdhistor
               tt-lancamentos.situacao = IF craplau.flgblqdb THEN
                                            "BLOQUEADO"
                                         ELSE 
                                            "PENDENTE".
    END.

    /* Ira consultar registros de Debito Facil somente se for a opcao de consulta */
    IF  par_cddopcao = "C" THEN
        DO: 
            /* busca os lancamentos efetivados */
            FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcooper  AND
                                   craplcm.nrdconta = par_nrdconta  AND
                                   craplcm.dtmvtolt >= par_dtiniper AND
                                   craplcm.dtmvtolt <= par_dtfimper NO-LOCK,
                FIRST crapatr WHERE crapatr.cdcooper = craplcm.cdcooper AND
                                    crapatr.nrdconta = craplcm.nrdconta AND
                                    crapatr.cdhistor = craplcm.cdhistor AND
                                    crapatr.cdrefere = craplcm.nrdocmto AND
                                    crapatr.tpautori <> 0               NO-LOCK,
                FIRST gnconve WHERE gnconve.flgativo = TRUE             AND
                                    gnconve.cdhisdeb = crapatr.cdhistor AND
                                    gnconve.nmarqatu <> ""              NO-LOCK,
                FIRST crapcon WHERE crapcon.cdcooper = crapatr.cdcooper AND
                                    crapcon.cdsegmto = crapatr.cdsegmto AND
                                    crapcon.cdempcon = crapatr.cdempcon AND
                                    crapcon.cdhistor = gnconve.cdhiscxa AND
                                    crapcon.flgcnvsi = FALSE            NO-LOCK:
        
                CREATE tt-lancamentos.
                ASSIGN tt-lancamentos.dtmvtolt = craplcm.dtmvtolt
                       tt-lancamentos.nmextcon = crapcon.nmextcon
                       tt-lancamentos.dshisext = crapatr.dshisext
                       tt-lancamentos.nrdocmto = craplcm.nrdocmto
                       tt-lancamentos.vllanmto = craplcm.vllanmto
                       tt-lancamentos.cdhistor = craplcm.cdhistor
                       tt-lancamentos.situacao = "EFETIVADO".
            END.
        END. 

END PROCEDURE.

PROCEDURE bloqueia_lancamento:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_dtmvtopg AS DATE NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS DECI NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE INIT 0  NO-UNDO.

    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    Bloqueia: DO WHILE TRUE TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        FIND craplau WHERE craplau.cdcooper = par_cdcooper AND
                           craplau.nrdconta = par_nrdconta AND
                           craplau.dtmvtopg = par_dtmvtopg AND
                           craplau.nrdocmto = par_nrdocmto AND
                           craplau.cdhistor = par_cdhistor
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF NOT AVAIL craplau THEN
        DO:
            IF LOCKED craplau THEN
            DO:
                ASSIGN aux_contador = aux_contador + 1.

                IF aux_contador = 10 THEN
                DO:
                    ASSIGN aux_dscritic = "Tabela CRAPLAU esta em uso.".

                    LEAVE Bloqueia.
                END.
            END.
            ELSE
            DO:
                ASSIGN aux_dscritic = "Lancamento de agendamento de debito " +
                                      "nao encontrado.".

                LEAVE Bloqueia.
            END.
        END.
        ELSE
        DO:
            ASSIGN craplau.flgblqdb = TRUE
                   craplau.dtdebito = par_dtmvtolt.

            /* gera protocolo */
            RUN sistema/generico/procedures/bo_algoritmo_seguranca.p 
                    PERSISTENT SET h-bo_algoritmo_seguranca.

            IF VALID-HANDLE(h-bo_algoritmo_seguranca) THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapass  THEN
                DO:
                    ASSIGN aux_cdcritic = 9.
                    UNDO Bloqueia, LEAVE Bloqueia.
                END.

                /** Verifica o horario inicial e final para a operacao **/
                RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET
                                                                h-b1wgen0015.
        
                IF VALID-HANDLE(h-b1wgen0015) THEN
                DO:
                    RUN horario_operacao IN h-b1wgen0015 (INPUT par_cdcooper,
                                                          INPUT 90,
                                                          INPUT 11,
                                                          INPUT crapass.inpessoa,
                                                         OUTPUT aux_dscritic,
                                                         OUTPUT TABLE tt-limite).

                    DELETE PROCEDURE h-b1wgen0015.
            
                    IF RETURN-VALUE = "NOK" THEN
                        UNDO Bloqueia, LEAVE Bloqueia.
            
                    FIND FIRST tt-limite NO-LOCK NO-ERROR.
                        
                    IF NOT AVAILABLE tt-limite THEN
                    DO:
                        ASSIGN aux_dscritic = "Tabela de limites nao encontrada.".
                        UNDO Bloqueia, LEAVE Bloqueia.
                    END.
            
                    /** Validar horario **/
                    IF tt-limite.idesthor = 1 THEN /** Estourou horario   **/
                    DO:
                        ASSIGN aux_dscritic = "Horario esgotado para realizar operacao " +
                                              "de Debito Automatico Facil.".
            
                        UNDO Bloqueia, LEAVE Bloqueia.
                    END.
                END.
                ELSE
                DO:
                    ASSIGN aux_dscritic = "Nao foi possivel realizar a operacao.".
                    UNDO Bloqueia, LEAVE Bloqueia.
                END.

                FIND crapatr WHERE crapatr.cdcooper = par_cdcooper AND
                                   crapatr.nrdconta = par_nrdconta AND
                                   crapatr.cdrefere = par_nrdocmto AND
                                   crapatr.cdhistor = par_cdhistor AND
                                   crapatr.tpautori <> 0
                                   NO-LOCK NO-ERROR.

                IF NOT AVAIL crapatr THEN
                DO:
                    ASSIGN aux_dscritic = "Autorizacao de debito nao encontrada.".
                    UNDO Bloqueia, LEAVE Bloqueia.
                END.

                FIND FIRST gnconve WHERE gnconve.flgativo = TRUE             AND
                                         gnconve.cdhisdeb = crapatr.cdhistor AND
                                         gnconve.nmarqatu <> "" NO-LOCK NO-ERROR.

                IF NOT AVAIL gnconve THEN
                DO:
                    ASSIGN aux_dscritic = "Registro de convenios nao localizado.".
                    UNDO Bloqueia, LEAVE Bloqueia.
                END.

                FIND crapcon WHERE crapcon.cdcooper = crapatr.cdcooper AND
                                   crapcon.cdsegmto = crapatr.cdsegmto AND
                                   crapcon.cdempcon = crapatr.cdempcon AND
                                   crapcon.cdhistor = gnconve.cdhiscxa AND
                                   crapcon.flgcnvsi = FALSE
                                   NO-LOCK NO-ERROR.

                IF NOT AVAIL crapcon THEN
                DO:
                    ASSIGN aux_dscritic = "Empresa nao conveniada.".
                    UNDO Bloqueia, LEAVE Bloqueia.
                END.

                ASSIGN aux_dsinfor1 = "Bloqueio de Debito - Inclusao"
                       aux_dsinfor2 = crapass.nmprimtl
                       aux_dsinfor3 = STRING(crapatr.cdrefere, 
                                      "zzzzzzzzzzzzzzzz9") + "#" +
                                      STRING(crapatr.vlrmaxdb,
                                      "zzz,zzz,zz9.99")    + "#" +
                                      STRING(craplau.dtmvtopg,
                                      "99/99/9999")        + "#" +
                                      STRING(craplau.vllanaut,
                                      "zzz,zzz,zz9.99").

                RUN gera_protocolo IN h-bo_algoritmo_seguranca 
                          (INPUT par_cdcooper,
                           INPUT par_dtmvtolt,
                           INPUT TIME,
                           INPUT par_nrdconta,
                           INPUT crapatr.cdrefere,
                           INPUT 0,     /** Autenticacao   **/
                           INPUT 0,
                           INPUT 0,
                           INPUT YES,   /** Gravar crappro **/
                           INPUT 11,     /** Debito Facil  **/
                           INPUT aux_dsinfor1,
                           INPUT aux_dsinfor2,
                           INPUT aux_dsinfor3,
                           INPUT crapcon.nmextcon, /** Cedente **/
                           INPUT FALSE, /** Agendamento **/
                           INPUT 0,
                           INPUT 0,
                           INPUT "",
                          OUTPUT aux_dsprotoc,
                          OUTPUT aux_dscritic). 
                                
                DELETE PROCEDURE h-bo_algoritmo_seguranca.

                IF RETURN-VALUE <> "OK" THEN
                    UNDO Bloqueia, LEAVE Bloqueia.

            END.

            LEAVE Bloqueia.
        END.
    END. /* END TRANSACTION */

    IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
    DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 90,
                       INPUT 0,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE desbloqueia_lancamento:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_dtmvtopg AS DATE NO-UNDO.
    DEF INPUT PARAM par_nrdocmto AS DECI NO-UNDO.
    DEF INPUT PARAM par_cdhistor AS INTE NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE INIT 0  NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    Desbloqueia: DO WHILE TRUE TRANSACTION ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        FIND craplau WHERE craplau.cdcooper = par_cdcooper AND
                           craplau.nrdconta = par_nrdconta AND
                           craplau.dtmvtopg = par_dtmvtopg AND
                           craplau.nrdocmto = par_nrdocmto AND
                           craplau.cdhistor = par_cdhistor
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF NOT AVAIL craplau THEN
        DO:
            IF LOCKED craplau THEN
            DO:
                ASSIGN aux_contador = aux_contador + 1.

                IF aux_contador = 10 THEN
                DO:
                    ASSIGN aux_dscritic = "Tabela CRAPLAU esta em uso.".

                    LEAVE Desbloqueia.
                END.
            END.
            ELSE
            DO:
                ASSIGN aux_dscritic = "Lancamento de agendamento de debito " +
                                      "nao encontrado.".

                LEAVE Desbloqueia.
            END.
        END.
        ELSE
        DO:
            ASSIGN craplau.flgblqdb = FALSE
                   craplau.dtdebito = ?.

            /* gera protocolo */
            RUN sistema/generico/procedures/bo_algoritmo_seguranca.p 
                    PERSISTENT SET h-bo_algoritmo_seguranca.

            IF VALID-HANDLE(h-bo_algoritmo_seguranca) THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = par_nrdconta 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapass  THEN
                DO:
                    ASSIGN aux_cdcritic = 9.
                    UNDO Desbloqueia, LEAVE Desbloqueia.
                END.

                /** Verifica o horario inicial e final para a operacao **/
                RUN sistema/generico/procedures/b1wgen0015.p PERSISTENT SET
                                                                h-b1wgen0015.
        
                IF VALID-HANDLE(h-b1wgen0015) THEN
                DO:
                    RUN horario_operacao IN h-b1wgen0015 (INPUT par_cdcooper,
                                                          INPUT 90,
                                                          INPUT 11,
                                                          INPUT crapass.inpessoa,
                                                         OUTPUT aux_dscritic,
                                                         OUTPUT TABLE tt-limite).

                    DELETE PROCEDURE h-b1wgen0015.
            
                    IF RETURN-VALUE = "NOK" THEN
                        UNDO Desbloqueia, LEAVE Desbloqueia.
            
                    FIND FIRST tt-limite NO-LOCK NO-ERROR.
                        
                    IF NOT AVAILABLE tt-limite THEN
                    DO:
                        ASSIGN aux_dscritic = "Tabela de limites nao encontrada.".
                        UNDO Desbloqueia, LEAVE Desbloqueia.
                    END.
            
                    /** Validar horario **/
                    IF tt-limite.idesthor = 1 THEN /** Estourou horario   **/
                    DO:
                        ASSIGN aux_dscritic = "Horario esgotado para realizar operacao " +
                                              "de Debito Automatico Facil.".
            
                        UNDO Desbloqueia, LEAVE Desbloqueia.
                    END.
                END.
                ELSE
                DO:
                    ASSIGN aux_dscritic = "Nao foi possivel realizar a operacao.".
                    UNDO Desbloqueia, LEAVE Desbloqueia.
                END.

                FIND crapatr WHERE crapatr.cdcooper = par_cdcooper AND
                                   crapatr.nrdconta = par_nrdconta AND
                                   crapatr.cdrefere = par_nrdocmto AND
                                   crapatr.cdhistor = par_cdhistor AND
                                   crapatr.tpautori <> 0
                                   NO-LOCK NO-ERROR.

                IF NOT AVAIL crapatr THEN
                DO:
                    ASSIGN aux_dscritic = "Autorizacao de debito nao encontrada.".
                    UNDO Desbloqueia, LEAVE Desbloqueia.
                END.

                FIND FIRST gnconve WHERE gnconve.flgativo = TRUE             AND
                                         gnconve.cdhisdeb = crapatr.cdhistor AND
                                         gnconve.nmarqatu <> "" NO-LOCK NO-ERROR.

                IF NOT AVAIL gnconve THEN
                DO:
                    ASSIGN aux_dscritic = "Registro de convenios nao localizado.".
                    UNDO Desbloqueia, LEAVE Desbloqueia.
                END.

                FIND crapcon WHERE crapcon.cdcooper = crapatr.cdcooper AND
                                   crapcon.cdsegmto = crapatr.cdsegmto AND
                                   crapcon.cdempcon = crapatr.cdempcon AND
                                   crapcon.cdhistor = gnconve.cdhiscxa AND
                                   crapcon.flgcnvsi = FALSE
                                   NO-LOCK NO-ERROR.

                IF NOT AVAIL crapcon THEN
                DO:
                    ASSIGN aux_dscritic = "Empresa nao conveniada.".
                    UNDO Desbloqueia, LEAVE Desbloqueia.
                END.

                ASSIGN aux_dsinfor1 = "Bloqueio de Debito - Exclusao"
                       aux_dsinfor2 = crapass.nmprimtl
                       aux_dsinfor3 = STRING(crapatr.cdrefere, 
                                      "zzzzzzzzzzzzzzzz9") + "#" +
                                      STRING(crapatr.vlrmaxdb,
                                      "zzz,zzz,zz9.99")    + "#" +
                                      STRING(craplau.dtmvtopg,
                                      "99/99/9999")        + "#" +
                                      STRING(craplau.vllanaut,
                                      "zzz,zzz,zz9.99").

                RUN gera_protocolo IN h-bo_algoritmo_seguranca 
                          (INPUT par_cdcooper,
                           INPUT par_dtmvtolt,
                           INPUT TIME,
                           INPUT par_nrdconta,
                           INPUT crapatr.cdrefere,
                           INPUT 0,     /** Autenticacao   **/
                           INPUT 0,
                           INPUT 0,
                           INPUT YES,   /** Gravar crappro **/
                           INPUT 11,     /** Debito Facil  **/
                           INPUT aux_dsinfor1,
                           INPUT aux_dsinfor2,
                           INPUT aux_dsinfor3,
                           INPUT crapcon.nmextcon, /** Cedente **/
                           INPUT FALSE, /** Agendamento **/
                           INPUT 0,
                           INPUT 0,
                           INPUT "",
                          OUTPUT aux_dsprotoc,
                          OUTPUT aux_dscritic). 
                                
                DELETE PROCEDURE h-bo_algoritmo_seguranca.

                IF RETURN-VALUE <> "OK" THEN
                    UNDO Desbloqueia, LEAVE Desbloqueia.

            END.

            LEAVE Desbloqueia.
        END.
    END. /* END TRANSACTION */

    IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
    DO:
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 90,
                       INPUT 0,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.

/* ........................PROCEDURE INTERNAS............................... */

/* ......................................................................... 
     Calcular/conferir o digito verif da Global Telecom (fontes/diglobal.p)  
   ......................................................................... */
PROCEDURE diglobal:

    DEF INPUT-OUTPUT PARAM par_nrcalcul AS DECIMAL FORMAT ">>>>>>>>9" NO-UNDO.
    DEF OUTPUT PARAM par_stsnrcal       AS LOGICAL                    NO-UNDO.

    DEF VAR aux_digito   AS INT     INIT 0                            NO-UNDO.
    DEF VAR aux_posicao  AS INT     INIT 0                            NO-UNDO.
    DEF VAR aux_peso     AS INT     INIT 2                            NO-UNDO.
    DEF VAR aux_calculo  AS INT     INIT 0                            NO-UNDO.
    DEF VAR aux_resto    AS INT     INIT 0                            NO-UNDO.

    IF  LENGTH(STRING(par_nrcalcul)) < 2   THEN
        DO:
            ASSIGN par_stsnrcal = FALSE.
            RETURN.
        END.
    
    DO  aux_posicao = 1 TO (LENGTH(STRING(par_nrcalcul)) - 1):
    
        ASSIGN aux_peso = aux_peso - 2.
        IF  aux_peso = 0  THEN
            ASSIGN aux_peso = 2.
             
        ASSIGN aux_calculo = aux_calculo +
                          (INTEGER(SUBSTR(STRING(par_nrcalcul),aux_posicao,1))
                           * aux_peso)
               aux_peso    = aux_peso + 1.              
    END.  /*  Fim do DO .. TO  */
    
    ASSIGN aux_resto = aux_calculo MODULO 10.
    
    IF  aux_resto > 9   THEN
        ASSIGN aux_digito = 0.
    ELSE
        ASSIGN aux_digito = aux_resto.
    
    IF (INTEGER(SUBSTRING(STRING(par_nrcalcul),
                   LENGTH(STRING(par_nrcalcul)),1))) <> aux_digito  THEN
        ASSIGN par_stsnrcal = FALSE.
    ELSE
        ASSIGN par_stsnrcal = TRUE.
    
    ASSIGN par_nrcalcul = DECIMAL(SUBSTRING(STRING(par_nrcalcul),1,
                                            LENGTH(STRING(par_nrcalcul)) - 1) +
                                  STRING(aux_digito)).

END PROCEDURE.



/* ......................................................................... 
    Calcular e conferir o digito verificador pelo modulo onze           
    da tim telesc. (fontes/digtim.p)                            
   ......................................................................... */
PROCEDURE digtim:

    DEF INPUT-OUTPUT PARAM par_nrcalcul AS DECIMAL 
                                        FORMAT ">>>>>>>>>>>>>>>>>>>9" NO-UNDO.
    DEF OUTPUT PARAM par_stsnrcal       AS LOGICAL                    NO-UNDO.

    DEF VAR aux_digito   AS INT     INIT 0                            NO-UNDO.
    DEF VAR aux_posicao  AS INT     INIT 0                            NO-UNDO.
    DEF VAR aux_peso     AS INT     INIT 2                            NO-UNDO.
    DEF VAR aux_calculo  AS INT     INIT 0                            NO-UNDO.
    DEF VAR aux_resto    AS INT     INIT 0                            NO-UNDO.
    DEF VAR aux_strnume  AS CHAR                                      NO-UNDO.

    IF  LENGTH(STRING(par_nrcalcul)) < 2  THEN
        DO:
            par_stsnrcal = FALSE.
            RETURN.
        END.
    
    ASSIGN aux_strnume = STRING(par_nrcalcul,"99999999999999999999").

    /*  alimenta a tabela de pesos e multiplica para cada digito  */
    ASSIGN aux_peso = 4.  
    
    DO aux_posicao = 1 TO 19:
    
        ASSIGN aux_calculo = aux_calculo +
               INTEGER(SUBSTRING(aux_strnume, aux_posicao, 1)) * aux_peso.
      
        ASSIGN aux_peso = IF  aux_peso = 2 THEN
                              9
                          ELSE aux_peso - 1.
    END.
    
    ASSIGN aux_resto = aux_calculo MODULO 11.
    
    IF   aux_resto = 0 OR
         aux_resto = 1 THEN
         ASSIGN aux_digito = 0.
    ELSE   
         ASSIGN aux_digito = 11 - aux_resto.
    
    IF  (INTEGER(SUBSTRING(aux_strnume,LENGTH(aux_strnume),1))) <> aux_digito 
        THEN
        ASSIGN par_stsnrcal = FALSE.
    ELSE
        ASSIGN par_stsnrcal = TRUE.
    
    ASSIGN par_nrcalcul = DECIMAL(SUBSTRING(aux_strnume,1, 
                                            LENGTH(aux_strnume) - 1) +
                                  STRING(aux_digito)).

END PROCEDURE.



/* ......................................................................... 
    Calcular e conferir o digito verificador pelo modulo 11 peso 7.         
    Baseado em fontes/digcel.p                                              
   ......................................................................... */
PROCEDURE digcel:

    DEF INPUT-OUTPUT PARAM par_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9" 
                                                                      NO-UNDO.
    DEF OUTPUT PARAM par_stsnrcal       AS LOGICAL                    NO-UNDO.

    DEF VAR aux_digito  AS INT     INIT 0                        NO-UNDO.
    DEF VAR aux_posicao AS INT     INIT 0                        NO-UNDO.
    DEF VAR aux_peso    AS INT     INIT 2                        NO-UNDO.
    DEF VAR aux_calculo AS INT     INIT 0                        NO-UNDO.
    DEF VAR aux_resto   AS INT     INIT 0                        NO-UNDO.
    
    IF  LENGTH(STRING(par_nrcalcul)) < 2   THEN
        DO:
            ASSIGN par_stsnrcal = FALSE.
            RETURN.
        END.
    
    DO  aux_posicao = (LENGTH(STRING(par_nrcalcul)) - 1) TO 1 BY -1:
    
        ASSIGN aux_calculo = aux_calculo + 
                             (INTEGER(SUBSTRING(STRING(par_nrcalcul),
                                                aux_posicao,1)) * aux_peso).
    
        ASSIGN aux_peso = aux_peso + 1.
    
        IF  aux_peso = 8  THEN
            ASSIGN aux_peso = 2.
    
    END.  /*  Fim do DO .. TO  */
    
    ASSIGN aux_resto = aux_calculo MODULO 11.
                                 
    IF  aux_resto = 1  OR aux_resto = 0   THEN
        ASSIGN aux_digito = 0.
    ELSE             
        ASSIGN aux_digito = 11 - aux_resto.
         
    IF (INTEGER(SUBSTRING(STRING(par_nrcalcul),
                   LENGTH(STRING(par_nrcalcul)),1))) <> aux_digito  THEN
        ASSIGN par_stsnrcal = FALSE.
    ELSE
        ASSIGN par_stsnrcal = TRUE.
    
    ASSIGN par_nrcalcul = DECIMAL(SUBSTRING(STRING(par_nrcalcul),1,
                                            LENGTH(STRING(par_nrcalcul)) - 1) +
                                  STRING(aux_digito)).

END PROCEDURE.


/* ......................................................................... 
     Calcular e conferir o digito verificador para SEMASA.
     Disponibilizar nro calculado digito "X".                                
     Baseado em fontes/dig_semasa.p                                          
   ......................................................................... */
PROCEDURE dig_semasa:

    DEF INPUT-OUTPUT PARAM par_nrcalcul AS DECIMAL FORMAT ">>>>>>>>>>>>>9" 
                                                                      NO-UNDO.
    DEF OUTPUT PARAM par_stsnrcal       AS LOGICAL                    NO-UNDO.

    DEF VAR aux_digito  AS INT     INIT 0                             NO-UNDO.
    DEF VAR aux_posicao AS INT     INIT 0                             NO-UNDO.
    DEF VAR aux_peso    AS INT     EXTENT 10  INIT [5,3,3,2,7,6,5,4,3,2]
                                                                      NO-UNDO.
    DEF VAR aux_calculo AS INT     INIT 0                             NO-UNDO.
    DEF VAR aux_resto   AS INT     INIT 0                             NO-UNDO.
    DEF VAR aux_indice  AS INT                                        NO-UNDO.
                 
    IF  LENGTH(STRING(par_nrcalcul)) < 2   THEN
        DO:
            ASSIGN par_stsnrcal = FALSE.
            RETURN.
        END.
    
    ASSIGN  aux_indice = 10.
    
    DO  aux_posicao = (LENGTH(STRING(par_nrcalcul)) - 1) TO 1 BY -1:
                                
        ASSIGN aux_calculo = aux_calculo + 
                            (INTEGER(SUBSTRING(STRING(par_nrcalcul),
                                     aux_posicao,1)) * aux_peso[aux_indice]).
        ASSIGN aux_indice = aux_indice - 1.
        
    END.  /*  Fim do DO .. TO  */
    
    ASSIGN aux_resto = aux_calculo MODULO 11.
    
    IF  aux_resto > 1 AND aux_resto < 10 THEN 
        ASSIGN aux_digito = 11 - aux_resto.
    ELSE
        ASSIGN aux_digito = 0.
    
    IF  (INTEGER(SUBSTRING(STRING(par_nrcalcul),
                           LENGTH(STRING(par_nrcalcul)),1))) <> aux_digito THEN
         ASSIGN par_stsnrcal = FALSE.
    ELSE
         ASSIGN par_stsnrcal = TRUE.
    
    /** Substituicao do numero do digito errado pelo numero correto **/
    ASSIGN par_nrcalcul = DECIMAL(SUBSTRING(STRING(par_nrcalcul),1,
                                            LENGTH(STRING(par_nrcalcul)) - 1) +
                                  STRING(aux_digito)).

END PROCEDURE.

/* ......................................................................... */

PROCEDURE verifica_log:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrefere AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtautori AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtcancel AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmfatura AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.

    DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
    DEF VAR aux_vldantes AS CHAR                                    NO-UNDO.
    DEF VAR aux_vldepois AS CHAR                                    NO-UNDO.

    FIND  crapatr WHERE crapatr.cdcooper = par_cdcooper  AND  
                        crapatr.nrdconta = par_nrdconta  AND
                        crapatr.cdhistor = par_cdhistor  AND
                        crapatr.cdrefere = par_cdrefere  NO-LOCK
                        USE-INDEX crapatr1 NO-ERROR.

    IF  AVAIL crapatr  THEN
        DO:
            IF  par_cddopcao = "I"   THEN
                DO:

                    ASSIGN aux_nmdcampo = "Dia do Vencto."
                           aux_vldantes = ""
                           aux_vldepois = STRING(crapatr.ddvencto).

                    RUN gera_log ( par_cdcooper,
                                   par_cdoperad,
                                   par_cdrefere,
                                   par_nrdconta,
                                   par_dtmvtolt,
                                   par_cddopcao,
                                   aux_nmdcampo, 
                                   aux_vldantes, 
                                   aux_vldepois ).
        
                    ASSIGN aux_nmdcampo = "Nome na Fatura"
                           aux_vldantes = ""
                           aux_vldepois = STRING(crapatr.nmfatura).

                    RUN gera_log ( par_cdcooper,
                                   par_cdoperad,
                                   par_cdrefere,
                                   par_nrdconta,
                                   par_dtmvtolt,
                                   par_cddopcao,
                                   aux_nmdcampo, 
                                   aux_vldantes, 
                                   aux_vldepois ).
                
                    LEAVE.         
                END.
            ELSE
            IF  par_cddopcao = "E"   THEN
                DO:
                    ASSIGN aux_nmdcampo = "Data de Cancel."
                           aux_vldantes = ""
                           aux_vldepois = "".
                                                    
                    RUN gera_log ( par_cdcooper,
                                   par_cdoperad,
                                   par_cdrefere,
                                   par_nrdconta,
                                   par_dtmvtolt,
                                   par_cddopcao,
                                   aux_nmdcampo, 
                                   aux_vldantes, 
                                   aux_vldepois ).
        
                    LEAVE.
                END.
        
            IF  crapatr.ddvencto <> par_dtvencto   THEN
                DO:
                    ASSIGN aux_nmdcampo = "Dia do Vencto."
                           aux_vldantes = STRING(crapatr.ddvencto)
                           aux_vldepois = STRING(par_dtvencto).
                           
                    RUN gera_log ( par_cdcooper,
                                   par_cdoperad,
                                   par_cdrefere,
                                   par_nrdconta,
                                   par_dtmvtolt,
                                   par_cddopcao,
                                   aux_nmdcampo, 
                                   aux_vldantes, 
                                   aux_vldepois ).
                END.
                
            IF  crapatr.nmfatura <> par_nmfatura   THEN
                DO:
                    ASSIGN aux_nmdcampo = "Nome na Fatura"
                           aux_vldantes = STRING(crapatr.nmfatura)
                           aux_vldepois = STRING(CAPS(par_nmfatura)).
                           
                    RUN gera_log ( par_cdcooper,
                                   par_cdoperad,
                                   par_cdrefere,
                                   par_nrdconta,
                                   par_dtmvtolt,
                                   par_cddopcao,
                                   aux_nmdcampo, 
                                   aux_vldantes, 
                                   aux_vldepois ).
                END.
                
            IF  crapatr.dtfimatr <> par_dtcancel  THEN
                DO:
                    ASSIGN aux_nmdcampo = "Data de Cancel."
                           aux_vldantes = STRING(crapatr.dtfimatr)
                           aux_vldepois = IF par_dtcancel = ? THEN
                                             "BRANCO"
                                          ELSE
                                             STRING(par_dtcancel).
                           
                    RUN gera_log ( par_cdcooper,
                                   par_cdoperad,
                                   par_cdrefere,
                                   par_nrdconta,
                                   par_dtmvtolt,
                                   par_cddopcao,
                                   aux_nmdcampo, 
                                   aux_vldantes, 
                                   aux_vldepois ).
                END.

            IF  crapatr.dtiniatr <> par_dtautori   AND
                crapatr.dtfimatr = par_dtcancel    THEN /*nao imprimir 2x*/
                DO:
                    ASSIGN aux_nmdcampo = "Inicio da Autori."
                           aux_vldantes = STRING(crapatr.dtiniatr)
                           aux_vldepois = STRING(par_dtautori).
                           
                    RUN gera_log ( par_cdcooper,
                                   par_cdoperad,
                                   par_cdrefere,
                                   par_nrdconta,
                                   par_dtmvtolt,
                                   par_cddopcao,
                                   aux_nmdcampo, 
                                   aux_vldantes, 
                                   aux_vldepois ).
                END.
        END.
    ELSE
    IF  par_cddopcao = "E"   THEN
           DO:
               ASSIGN aux_nmdcampo = "Data de Cancel."
                      aux_vldantes = ""
                      aux_vldepois = "".
                                               
               RUN gera_log ( par_cdcooper,
                              par_cdoperad,
                              par_cdrefere,
                              par_nrdconta,
                              par_dtmvtolt,
                              par_cddopcao,
                              aux_nmdcampo, 
                              aux_vldantes, 
                              aux_vldepois ).
    
               LEAVE.
           END.

END PROCEDURE.


PROCEDURE gera_log:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdrefere AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vldantes AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vldepois AS CHAR                           NO-UNDO.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  par_vldantes = ? THEN
        ASSIGN par_vldantes = "".
    IF  par_vldepois = ? THEN
        ASSIGN par_vldepois = "".

    IF  par_cddopcao = "A"   THEN
        UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " " +
                          STRING(TIME,"HH:MM:SS") + "' --> '"  +
                          " Operador " + par_cdoperad +
                          " Alterou '    'a Fatura " + STRING(par_cdrefere) +
                          " - " + "Conta " +
                          STRING(par_nrdconta,"zzzz,zzz,9") + 
                          "' --> '" + par_nmdcampo +
                          " de " + par_vldantes +
                          " para " + par_vldepois +
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/log/autori.log").
    ELSE
    IF  par_cddopcao = "I"   THEN
        UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " " +
                          STRING(TIME,"HH:MM:SS") + "' --> '"  +
                          " Operador " + par_cdoperad +
                          " Incluiu '    'a Fatura " + STRING(par_cdrefere) +
                          " - " + "Conta " + 
                          STRING(par_nrdconta,"zzzz,zzz,9") + 
                          "' --> '" + par_nmdcampo +
                          ": " + par_vldepois +
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/log/autori.log").
    ELSE
    IF  par_cddopcao = "E"   THEN
        DO:
            IF  AVAILABLE crapatr   THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")
                                  + " " + STRING(TIME,"HH:MM:SS") + "' --> '"
                                  + " Operador " + par_cdoperad +
                                  " Cancelou '   'a Fatura " + 
                                  STRING(par_cdrefere) +
                                  " - " + "Conta " +
                                  STRING(par_nrdconta,"zzzz,zzz,9") + 
                                  " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                  "/log/autori.log").
            ELSE
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999")
                                  + " " + STRING(TIME,"HH:MM:SS") + "' --> '"
                                  + " Operador " + par_cdoperad +
                                  " Excluiu '    'a Fatura " + 
                                  STRING(par_cdrefere) +
                                  " - " + "Conta " +
                                  STRING(par_nrdconta,"zzzz,zzz,9") + 
                                  " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                                  "/log/autori.log").
        END.
    ELSE
    IF  par_cddopcao = "R"   THEN
        UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " " +
                          STRING(TIME,"HH:MM:SS") + "' --> '"  +
                          " Operador " + par_cdoperad +
                          " Recadastrou a Fatura " + STRING(par_cdrefere) +
                          " - " + "Conta " +
                          STRING(par_nrdconta,"zzzz,zzz,9") + 
                          "' --> '" + par_nmdcampo +
                          " de " + par_vldantes +
                          " para " + par_vldepois +
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/log/autori.log").


END PROCEDURE.

PROCEDURE calculo-referencia-mod11:

  /**********************************************************************
     Procedure para calcular e conferir o digito verificador pelo modulo onze
     para o numero de referencia de debito automatico.

   **********************************************************************/
    DEF INPUT-OUTPUT PARAM nro-calculado AS DECIMAL                 NO-UNDO.
    DEF OUTPUT       PARAM nro-digito    AS INTEGER                 NO-UNDO.
    DEF OUTPUT       PARAM l-retorno     AS LOGICAL                 NO-UNDO.
    
    DEF        VAR aux_digito   AS INT     INIT 0                   NO-UNDO.
    DEF        VAR aux_posicao  AS INT     INIT 0                   NO-UNDO.
    DEF        VAR aux_peso     AS INT     INIT 9                   NO-UNDO.
    DEF        VAR aux_calculo  AS INT     INIT 0                   NO-UNDO.
    DEF        VAR aux_resto    AS INT     INIT 0                   NO-UNDO.
    DEF        VAR aux_strnume  AS CHAR                             NO-UNDO.
    
    DEF VAR aux_tamanho AS INTE NO-UNDO.
    DEF VAR aux_digitve AS INT  NO-UNDO.

    ASSIGN aux_strnume = STRING(nro-calculado)
           aux_tamanho = LENGTH(aux_strnume)
           aux_digitve = INT(SUBSTR(aux_strnume,aux_tamanho,1))
    
           aux_strnume = SUBSTR(aux_strnume,1,aux_tamanho - 1 )
           aux_peso = 2.  /*alimenta a tabela de pesos e multiplica
                            para cada digito*/
    
    DO aux_posicao = (LENGTH(STRING(aux_strnume))) TO 1 BY -1:
    
       ASSIGN aux_calculo = aux_calculo +
              INTEGER(SUBSTRING(aux_strnume, aux_posicao, 1)) * aux_peso
              aux_peso = IF  aux_peso = 9 THEN 2
                         ELSE aux_peso + 1.
    END.
    
    ASSIGN aux_resto = aux_calculo MODULO 11.
    
    CASE aux_resto:
       WHEN  0  THEN  ASSIGN aux_digito = 0.
       WHEN  1  THEN  ASSIGN aux_digito = 0.
       WHEN  10 THEN  ASSIGN aux_digito = 1.
    END CASE.
    
    IF aux_resto <> 0   AND
       aux_resto <> 1   AND
       aux_resto <> 10  THEN
       ASSIGN aux_digito = 11 - aux_resto.
    
    IF  aux_digitve <> aux_digito THEN
        l-retorno = FALSE.
    ELSE
        l-retorno = TRUE.
    
    ASSIGN nro-digito = aux_digito.
    
END PROCEDURE.

PROCEDURE retorna-calculo-referencia:

    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_codbarra AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_cdrefere AS CHAR                               NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_dsnomcnv AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrdigito AS INT                                        NO-UNDO.
    DEF VAR aux_flgretor AS LOG                                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN  aux_cdcritic = 0
            aux_dscritic = "".

    IF  par_codbarra <> "" THEN
        DO: 
            FIND FIRST crapscn WHERE 
                       crapscn.dsoparre = "E"                       AND
                      (crapscn.cddmoden = "A"                       OR
                       crapscn.cddmoden = "C")                      AND
                       crapscn.cdempcon <> 0                        AND
                       crapscn.cdempcon = INT(SUBSTR(par_codbarra,16,4)) AND
                       crapscn.cdsegmto = SUBSTR(par_codbarra,2,1)
                       NO-LOCK NO-ERROR NO-WAIT.
            
            IF  NOT AVAIL crapscn THEN
                ASSIGN aux_cdcritic = 563.
            ELSE
                DO: 
                   ASSIGN par_dsnomcnv = crapscn.dsnomcnv.

                   IF  crapscn.nrmodulo = 10 THEN
                       DO: 
                           RUN calculo-referencia-mod10 (INPUT-OUTPUT par_cdrefere,
                                                         OUTPUT aux_nrdigito,
                                                         OUTPUT aux_flgretor).

                           /* Se digito nao confere gera erro */
                           IF  NOT aux_flgretor THEN
                               ASSIGN aux_cdcritic = 8
                                      par_nmdcampo = "cdrefere".
                       END.
                   ELSE
                   IF  crapscn.nrmodulo = 11 THEN
                       DO:
                           RUN calculo-referencia-mod11 (INPUT-OUTPUT par_cdrefere,
                                                         OUTPUT aux_nrdigito,
                                                         OUTPUT aux_flgretor).
                            
                           /* Se digito nao confere gera erro */
                           IF  NOT aux_flgretor THEN
                               ASSIGN aux_cdcritic = 8
                                      par_nmdcampo = "cdrefere".
                       END.

                END.
            
            IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0, /* cdagenci */
                                   INPUT 0, /* nrdcaixa */
                                   INPUT 1, /* Sequencia */
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.
        END.
    RETURN "OK".

END.

/*** Rotina para calculo do digito verificador no modulo 10
     para o codigo de referencia do debito automatico ***/
PROCEDURE calculo-referencia-mod10:

    DEF INPUT-OUTPUT PARAM nro-calculado AS DECIMAL                 NO-UNDO.
    DEF OUTPUT       PARAM nro-digito    AS INTEGER                 NO-UNDO.
    DEF OUTPUT       PARAM l-retorno     AS LOGICAL                 NO-UNDO.

    DEF   VAR aux_dscorbar AS CHAR                                  NO-UNDO.
    DEF   VAR aux_dscalcul AS CHAR                                  NO-UNDO.
    DEF   VAR aux_conver   AS CHAR                                  NO-UNDO.

    DEF   VAR aux_nrdigbar AS INT     INIT 0                        NO-UNDO.
    DEF   VAR aux_digito   AS INT     INIT 0                        NO-UNDO.
    DEF   VAR aux_posicao  AS INT     INIT 0                        NO-UNDO.
    DEF   VAR aux_peso     AS INT     INIT 2                        NO-UNDO.
    DEF   VAR aux_calculo  AS INT     INIT 0                        NO-UNDO.
    DEF   VAR aux_resto    AS INT     INIT 0                        NO-UNDO.

    DEF VAR aux_tamanho AS INTE NO-UNDO.

    aux_tamanho = LENGTH(string(nro-calculado)).

    ASSIGN aux_dscorbar = STRING(nro-calculado,FILL("9",aux_tamanho))
           aux_dscalcul = SUBSTR(aux_dscorbar,01,aux_tamanho - 1)
           aux_nrdigbar = INTE(SUBSTR(aux_dscorbar,aux_tamanho,1))
           aux_peso     = 2.

   DO aux_posicao = 1 TO LENGTH(STRING(aux_dscalcul)):

      ASSIGN aux_conver = STRING(INTE(SUBSTR(STRING(aux_dscalcul),
                          aux_posicao,1)) * aux_peso).

      IF  LENGTH(aux_conver) = 2  THEN
          DO:
             ASSIGN aux_calculo = aux_calculo +
                                  INTE(SUBSTR(aux_conver,1,1)) +
                                  INTE(SUBSTR(aux_conver,2,1)).
          END.
      ELSE
          ASSIGN aux_calculo = aux_calculo + INTE(aux_conver).

     IF  aux_peso = 2  THEN
         ASSIGN aux_peso = 1.
     ELSE
        ASSIGN aux_peso = 2.
  END.

  ASSIGN aux_resto = 10 - (aux_calculo MODULO 10).

  IF  aux_resto = 10  THEN
      ASSIGN aux_digito = 0.
  ELSE
      ASSIGN aux_digito = aux_resto.

  IF  aux_digito <> aux_nrdigbar  THEN
      ASSIGN l-retorno = FALSE.
  ELSE
      ASSIGN l-retorno = TRUE.

  ASSIGN nro-digito    = aux_digito
         nro-calculado = DECI(SUBSTR(aux_dscorbar,01,03) + STRING(aux_digito) +
                         SUBSTR(aux_dscorbar,05,40)).

END.

PROCEDURE retorna-calculo-barras:

    DEF INPUT         PARAM par_cdcooper AS INTE                      NO-UNDO.
    DEF INPUT         PARAM par_fatura01 AS DECI                      NO-UNDO.
    DEF INPUT         PARAM par_fatura02 AS DECI                      NO-UNDO.
    DEF INPUT         PARAM par_fatura03 AS DECI                      NO-UNDO.
    DEF INPUT         PARAM par_fatura04 AS DECI                      NO-UNDO.
    DEF INPUT         PARAM par_codbarra AS CHAR                      NO-UNDO.
    DEF INPUT         PARAM par_flgmanua AS CHAR                      NO-UNDO.
    DEF INPUT         PARAM par_nomcampo AS CHAR                      NO-UNDO.

    DEF OUTPUT        PARAM par_nmdcampo AS CHAR                      NO-UNDO.
    DEF OUTPUT        PARAM par_dsnomcnv AS CHAR                      NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF                VAR aux_nrdcaixa    LIKE crapaut.nrdcaixa      NO-UNDO.
    DEF                VAR aux_lindigit    AS DECI                    NO-UNDO.
    DEF                VAR aux_vlrcalcu    AS DEC                     NO-UNDO.
    DEF                VAR aux_nrodigit    AS INTE                    NO-UNDO.
    DEF                VAR aux_nrdigito    AS INTE                    NO-UNDO.
    DEF                VAR aux_flgretor    AS LOG                     NO-UNDO.
    DEF                VAR aux_cdempcon    AS INT                     NO-UNDO.
    DEF                VAR aux_cdsegmto    AS CHAR                    NO-UNDO.

    DEF                VAR aux_lengtfat    AS DECI                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    Valida:
    DO  WHILE TRUE:

        IF  par_fatura01 <> 0 OR
            par_fatura02 <> 0 OR
            par_fatura03 <> 0 OR
            par_fatura04 <> 0 THEN  
            DO: 

                ASSIGN aux_vlrcalcu  =
                 DEC(SUBSTR(STRING(par_fatura01,"999999999999"),1,11) + 
                     SUBSTR(STRING(par_fatura02,"999999999999"),1,11) + 
                     SUBSTR(STRING(par_fatura03,"999999999999"),1,11) + 
                     SUBSTR(STRING(par_fatura04,"999999999999"),1,11)).
                                                        
                ASSIGN par_codbarra = STRING(aux_vlrcalcu).
    
                ASSIGN aux_cdempcon = INT(SUBSTR(par_codbarra,16,4))
                       aux_cdsegmto = SUBSTR(par_codbarra,2,1).   

                /* Valida os campos manuais */
                /* Campo 1 */
                ASSIGN aux_lindigit = DECI(SUBSTR(STRING(par_fatura01,
                                                         "999999999999"),1,11))
                       aux_nrdigito = INTE(SUBSTR(STRING(par_fatura01,
                                                         "999999999999"),12,11)).

                IF  DEC(SUBSTR(STRING(par_fatura01), 3, 1)) = 6 OR
                    DEC(SUBSTR(STRING(par_fatura01), 3, 1)) = 7 THEN
                    DO: 
                        /** Verificacao pelo modulo 10**/       
                        RUN calculo-digito-mod10 (INPUT-OUTPUT aux_lindigit,
                                                  OUTPUT       aux_nrodigit,
                                                  OUTPUT       aux_flgretor).
                    END. 
                ELSE
                   DO:  
                        /*** Verificacao pelo modulo 11 ***/
                        RUN calculo-digito-mod11 (INPUT-OUTPUT aux_lindigit,
                                                  OUTPUT aux_nrodigit,
                                                  OUTPUT aux_flgretor).
                    END.

                IF  aux_nrodigit <> aux_nrdigito  THEN 
                    DO:
                        ASSIGN aux_dscritic = "008 - Digito errado"
                               par_nmdcampo = "fatura01".
                        LEAVE Valida.
                    END.
                  
                /* Campo 2 */
                ASSIGN aux_lindigit = DECI(SUBSTR(STRING(par_fatura02,
                                                         "999999999999"),1,11))
                       aux_nrdigito = INTE(SUBSTR(STRING(par_fatura02,
                                                         "999999999999"),12,11)).
                
                IF  DEC(SUBSTR(STRING(par_fatura01), 3, 1)) = 6 OR
                    DEC(SUBSTR(STRING(par_fatura01), 3, 1)) = 7 THEN
                    DO: 
                        /** Verificacao pelo modulo 10**/       
                        RUN calculo-digito-mod10 (INPUT-OUTPUT aux_lindigit,
                                                  OUTPUT       aux_nrodigit,
                                                  OUTPUT       aux_flgretor).
                    END. 
                ELSE
                   DO:  
                        /*** Verificacao pelo modulo 11 ***/
                        RUN calculo-digito-mod11 (INPUT-OUTPUT aux_lindigit,
                                                  OUTPUT aux_nrodigit,
                                                  OUTPUT aux_flgretor).
                    END.

                IF  aux_nrodigit <> aux_nrdigito  THEN 
                    DO:
                        ASSIGN aux_dscritic = "008 - Digito errado"
                               par_nmdcampo = "fatura02".
                        LEAVE Valida.
                    END.
    
                /* Campo 3 */
                ASSIGN aux_lindigit = DECI(SUBSTR(STRING(par_fatura03,
                                                         "999999999999"),1,11))
                       aux_nrdigito = INTE(SUBSTR(STRING(par_fatura03,
                                                         "999999999999"),12,11)).
                
                IF  DEC(SUBSTR(STRING(par_fatura01), 3, 1)) = 6 OR
                    DEC(SUBSTR(STRING(par_fatura01), 3, 1)) = 7 THEN
                    DO: 
                        /** Verificacao pelo modulo 10**/       
                        RUN calculo-digito-mod10 (INPUT-OUTPUT aux_lindigit,
                                                  OUTPUT       aux_nrodigit,
                                                  OUTPUT       aux_flgretor).
                    END. 
                ELSE
                   DO:  
                        /*** Verificacao pelo modulo 11 ***/
                        RUN calculo-digito-mod11 (INPUT-OUTPUT aux_lindigit,
                                                  OUTPUT aux_nrodigit,
                                                  OUTPUT aux_flgretor).
                    END.

                IF  aux_nrodigit <> aux_nrdigito  THEN 
                    DO:
                        
                    ASSIGN aux_dscritic = "008 - Digito errado"
                               par_nmdcampo = "fatura03".
                        LEAVE Valida.
                    END.
    
                        
                /* Campo 4 */
                ASSIGN aux_lindigit = DECI(SUBSTR(STRING(par_fatura04,
                                                         "999999999999"),1,11))
                       aux_nrdigito = INTE(SUBSTR(STRING(par_fatura04,
                                                         "999999999999"),12,11)).
                
                IF  DEC(SUBSTR(STRING(par_fatura01), 3, 1)) = 6 OR
                    DEC(SUBSTR(STRING(par_fatura01), 3, 1)) = 7 THEN
                    DO: 
                        /** Verificacao pelo modulo 10**/       
                        RUN calculo-digito-mod10 (INPUT-OUTPUT aux_lindigit,
                                                  OUTPUT       aux_nrodigit,
                                                  OUTPUT       aux_flgretor).
                    END. 
                ELSE
                   DO:  
                        /*** Verificacao pelo modulo 11 ***/
                        RUN calculo-digito-mod11 (INPUT-OUTPUT aux_lindigit,
                                                  OUTPUT aux_nrodigit,
                                                  OUTPUT aux_flgretor).
                    END.

                IF  aux_nrodigit <> aux_nrdigito  THEN 
                    DO:
                        ASSIGN aux_dscritic = "008 - Digito errado"
                               par_nmdcampo = "fatura04".
                        LEAVE Valida.
                    END.
    
            END.
        ELSE /* Cod. barras informado */
            DO:
                
                ASSIGN aux_vlrcalcu = DEC(par_codbarra).
    
                ASSIGN aux_cdempcon = INT(SUBSTR(par_codbarra,16,4))
                       aux_cdsegmto = SUBSTR(par_codbarra,2,1).   
                
                IF  INT(SUBSTR(STRING(aux_vlrcalcu), 3, 1)) = 6 OR
                    INT(SUBSTR(STRING(aux_vlrcalcu), 3, 1)) = 7 THEN
                    DO: 
                        /** Verificacao pelo modulo 10**/       
                        RUN calculo-digito-mod10 (INPUT-OUTPUT aux_vlrcalcu,
                                                  OUTPUT       aux_nrodigit,
                                                  OUTPUT       aux_flgretor).
                    END. 
                ELSE
                   DO:  
                        /*** Verificacao pelo modulo 11 ***/
                        RUN calculo-digito-mod11 (INPUT-OUTPUT aux_vlrcalcu,
                                                  OUTPUT aux_nrodigit,
                                                  OUTPUT aux_flgretor).
                    END.
                
                /* Se digito nao confere gera erro */
                IF  NOT aux_flgretor THEN
                    DO:
                        ASSIGN aux_cdcritic = 008
                               par_nmdcampo = "codbarra".
                        LEAVE Valida.    
                    END.
            END.    
        
        IF  par_fatura02 <> 0 OR 
            INT(SUBSTR(STRING(aux_vlrcalcu),16,4)) <> 0 THEN
            DO:
            
                FIND crapscn WHERE 
                     crapscn.dsoparre = "E"                 AND
                    (crapscn.cddmoden = "A"                  OR
                     crapscn.cddmoden = "C")                AND
                     crapscn.cdempcon <> 0                  AND
                     crapscn.cdempcon = aux_cdempcon        AND
                     crapscn.cdsegmto = aux_cdsegmto 
                     NO-LOCK NO-ERROR NO-WAIT.
            
                IF  AVAIL crapscn THEN
                    ASSIGN par_dsnomcnv = crapscn.dsnomcnv.
                ELSE
                    DO:
                        ASSIGN aux_dscritic = "Este convenio nao pode ser cadastrado no debito automatico.".

                        IF  par_flgmanua = "S" OR 
                            par_flgmanua = "yes" THEN
                            par_nmdcampo = "fatura02".
                        ELSE
                            par_nmdcampo = "codbarra".
                        
                        LEAVE Valida.
                    END.
            END.
        
        /* Gravar informacoes sem format com 999999 */
        /* Manual */
        IF  par_flgmanua = "S" OR 
            par_flgmanua = "yes" THEN
            ASSIGN aux_lengtfat = DECI(SUBSTR(STRING(par_fatura01),1,11) +  
                                       SUBSTR(STRING(par_fatura02),1,11) + 
                                       SUBSTR(STRING(par_fatura03),1,11) + 
                                       SUBSTR(STRING(par_fatura04),1,11)).
        ELSE
            ASSIGN aux_lengtfat = DECI(par_codbarra).

        /* informacoes tem que estar corretas */
        IF  DEC(LENGTH(STRING(aux_lengtfat))) <> 44    OR /* tamanho do codigo Barras */
            DEC(SUBSTR(STRING(aux_lengtfat),1,1)) <> 8 OR /* indica que e fatura */
            aux_lengtfat = 0  THEN
            DO: 
                /* Manual */
                IF  par_flgmanua = "S" OR 
                    par_flgmanua = "yes" THEN
                    DO:
                        /* ayllos caracter */
                        IF  par_nomcampo = "caracter" THEN
                            IF  par_fatura01 = 0 OR 
                                par_fatura02 = 0 THEN
                                DO: 
                                    ASSIGN aux_dscritic = "008 - Digito errado".
                                    LEAVE Valida.
                                END.
                        
                        /* ayllos web */
                        IF  par_nomcampo = "fatura01" AND par_fatura01 = 0 THEN 
                            DO: 
                                ASSIGN aux_dscritic = "008 - Digito errado"
                                       par_nmdcampo = "fatura01".    
                                LEAVE Valida.
                            END.
                        ELSE
                        IF  par_nomcampo = "fatura02" AND par_fatura02 = 0 THEN 
                            DO: 
                                ASSIGN aux_dscritic = "008 - Digito errado" 
                                       par_nmdcampo = "fatura02".
                                LEAVE Valida.
                            END.
                    END.
                ELSE  /* Automatico - na leitora de codigo de barras */
                    DO: 
                        ASSIGN aux_dscritic = "008 - Digito errado"
                               par_nmdcampo = "codbarra".
                        LEAVE Valida.
                    END.
            END.
            
        LEAVE Valida.
    END.             
            
    IF  aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0, /* cdagenci */
                           INPUT 0, /* nrdcaixa */
                           INPUT 1, /* Sequencia */
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    RETURN "OK".
END.

/* Calculo do modulo 11 para validar digito das faturas */
PROCEDURE calculo-digito-mod11:

  /**********************************************************************
   Procedure para calcular e conferir o digito verificador pelo modulo onze 
   das faturas de arrecadacao pagas manualmente - GNRE.
  **********************************************************************/
    DEF INPUT-OUTPUT PARAM nro-calculado AS DECIMAL                 NO-UNDO.
    DEF OUTPUT       PARAM nro-digito    AS INTEGER                 NO-UNDO.
    DEF OUTPUT       PARAM l-retorno     AS LOGICAL                 NO-UNDO.
    
    DEF        VAR aux_digito   AS INT     INIT 0                         NO-UNDO.
    DEF        VAR aux_posicao  AS INT     INIT 0                         NO-UNDO.
    DEF        VAR aux_peso     AS INT     INIT 9                         NO-UNDO.
    DEF        VAR aux_calculo  AS INT     INIT 0                         NO-UNDO.
    DEF        VAR aux_resto    AS INT     INIT 0                         NO-UNDO.
    DEF        VAR aux_strnume  AS CHAR                                   NO-UNDO.
    
    ASSIGN aux_strnume = 
    SUBSTR(STRING(nro-calculado,"99999999999999999999999999999999999999999999"),
           1,3) +
    SUBSTR(STRING(nro-calculado,"99999999999999999999999999999999999999999999"),
           5,40)
       aux_peso = 2.  /*alimenta a tabela de pesos e multiplica 
                        para cada digito*/

    DO aux_posicao = (LENGTH(STRING(aux_strnume))) TO 1 BY -1:
       ASSIGN aux_calculo = aux_calculo + 
                  INTEGER(SUBSTRING(aux_strnume, aux_posicao, 1)) * aux_peso
              aux_peso = IF   aux_peso = 9 THEN
                              2
                         ELSE aux_peso + 1.
    END.
    
    ASSIGN aux_resto = aux_calculo MODULO 11.
    
    CASE aux_resto:
    
         WHEN  0  THEN  ASSIGN aux_digito = 0.
         WHEN  1  THEN  ASSIGN aux_digito = 0.
         WHEN  10 THEN  ASSIGN aux_digito = 1.
    END CASE.
        
    IF aux_resto <> 0   AND
       aux_resto <> 1   AND
       aux_resto <> 10  THEN
       ASSIGN aux_digito = 11 - aux_resto.
    
    IF   INTE(SUBSTR(STRING
         (nro-calculado,"99999999999999999999999999999999999999999999"),4,1)) <>
                               aux_digito THEN
         l-retorno = FALSE.
    ELSE
         l-retorno = TRUE.
    
    ASSIGN nro-digito = aux_digito.

END PROCEDURE. 

/* Calculo do modulo 10 para validar digito das faturas */
PROCEDURE calculo-digito-mod10:

    DEF INPUT-OUTPUT PARAM nro-calculado AS DECIMAL                 NO-UNDO.
    DEF OUTPUT       PARAM nro-digito    AS INTEGER                 NO-UNDO.
    DEF OUTPUT       PARAM l-retorno     AS LOGICAL                 NO-UNDO.
     
    DEF   VAR aux_dscorbar AS CHAR                                  NO-UNDO.
    DEF   VAR aux_dscalcul AS CHAR                                  NO-UNDO.
    DEF   VAR aux_conver   AS CHAR                                  NO-UNDO.
    
    DEF   VAR aux_nrdigbar AS INT     INIT 0                        NO-UNDO.
    DEF   VAR aux_digito   AS INT     INIT 0                        NO-UNDO.
    DEF   VAR aux_posicao  AS INT     INIT 0                        NO-UNDO.
    DEF   VAR aux_peso     AS INT     INIT 2                        NO-UNDO.
    DEF   VAR aux_calculo  AS INT     INIT 0                        NO-UNDO.
    DEF   VAR aux_resto    AS INT     INIT 0                        NO-UNDO.
    
    ASSIGN aux_dscorbar = STRING(nro-calculado,FILL("9",44))
           aux_dscalcul = SUBSTR(aux_dscorbar,01,03) + SUBSTR(aux_dscorbar,05,40)
           aux_nrdigbar = INTE(SUBSTR(aux_dscorbar,4,1))
           aux_peso     = 2.

    DO aux_posicao = 1 TO LENGTH(STRING(aux_dscalcul)):

       
        ASSIGN aux_conver = STRING(INTE(SUBSTR(STRING(aux_dscalcul),
                                               aux_posicao,1)) * aux_peso).
        
        IF  LENGTH(aux_conver) = 2  THEN 
            DO:
                ASSIGN aux_calculo = aux_calculo + 
                                     INTE(SUBSTR(aux_conver,1,1)) +
                                     INTE(SUBSTR(aux_conver,2,1)).
            END.
        ELSE
            ASSIGN aux_calculo = aux_calculo + INTE(aux_conver).
    
        IF  aux_peso = 2  THEN
            ASSIGN aux_peso = 1.
        ELSE 
            ASSIGN aux_peso = 2.
    
    END.  
    
    ASSIGN aux_resto = 10 - (aux_calculo MODULO 10).
    
    IF  aux_resto = 10  THEN
        ASSIGN aux_digito = 0.
    ELSE
        ASSIGN aux_digito = aux_resto.
    
    IF  aux_digito <> aux_nrdigbar  THEN
        ASSIGN l-retorno = FALSE.
    ELSE
        ASSIGN l-retorno = TRUE.
    
    ASSIGN nro-digito    = aux_digito
           nro-calculado = DECI(SUBSTR(aux_dscorbar,01,03) + STRING(aux_digito) +
                                SUBSTR(aux_dscorbar,05,40)).
    
END.

/******************************************************************************
  Procedure para trazer os convenios sicredi
******************************************************************************/
PROCEDURE busca-convenios:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dshistor AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_flglanca AS LOGI                            NO-UNDO.
    DEF  INPUT PARAM par_inautori AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                            NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-crapscn.

    DEF VAR aux_nrregist AS INTE                                     NO-UNDO.

    ASSIGN aux_nrregist = par_nrregist.

    conv: DO ON ERROR UNDO, LEAVE:

        EMPTY TEMP-TABLE tt-crapscn.

        FOR EACH crapscn WHERE
                 crapscn.cdempcon <> 0                  AND
                 crapscn.dsoparre = "E"                 AND
                (crapscn.cddmoden = "A"                 OR
                 crapscn.cddmoden = "C")                AND
                 crapscn.dsnomcnv  MATCHES "*" + par_dshistor + "*"
                 NO-LOCK BY crapscn.dsnomcnv:

            ASSIGN par_qtregist = par_qtregist + 1.

            /* controles da paginaçao */
            IF  (par_qtregist < par_nriniseq) OR
                (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                NEXT.

            IF  aux_nrregist > 0 THEN
                DO:
                   FIND FIRST tt-crapscn 
                       WHERE tt-crapscn.cdhistor = crapscn.cdempres NO-ERROR.
    
                   IF   NOT AVAILABLE tt-crapscn THEN
                        DO:
                           CREATE tt-crapscn.
                           ASSIGN tt-crapscn.cdhistor = crapscn.cdempres
                                  tt-crapscn.dshistor = crapscn.dsnomcnv.
                        END.
                END.

             ASSIGN aux_nrregist = aux_nrregist - 1.
        END.

        LEAVE conv.
    END.

    RETURN "OK".

END PROCEDURE.

/* Validar senha do cartao magnetico do cooperado */ 
PROCEDURE valida_senha_cooperado:
   
   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.   
   DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   
   DEF  INPUT PARAM par_cddsenha AS INTE                           NO-UNDO.   
   DEF OUTPUT PARAM TABLE FOR tt-erro.   
   
   DEF VAR aux_cdcritic AS INT                                     NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
   DEF VAR aux_flgsevld AS LOGICAL                                 NO-UNDO.   
  
   ASSIGN aux_cdcritic = 0
          aux_dscritic = ""
          aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
          aux_dstransa = "Validar senha do cooperado".
  
   FOR EACH crapcrm FIELDS (dssencar) 
                    WHERE crapcrm.cdcooper = crapcop.cdcooper AND
                          crapcrm.nrdconta = par_nrdconta     
                          NO-LOCK:

       IF  CAPS(ENCODE(STRING(par_cddsenha))) = CAPS(crapcrm.dssencar) THEN
           DO:
               ASSIGN aux_flgsevld = TRUE.
               LEAVE.
           END.
   END.

  IF  aux_flgsevld = FALSE THEN
      DO:
          ASSIGN aux_cdcritic  = 0
                 aux_dscritic = "Senha invalida.".

          RUN gera_erro ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic ).

          IF  par_flgerlog  THEN
              RUN proc_gerar_log ( INPUT par_cdcooper,
                                   INPUT par_cdoperad,
                                   INPUT aux_dscritic,
                                   INPUT aux_dsorigem,
                                   INPUT aux_dstransa,
                                   INPUT TRUE,
                                   INPUT 0,
                                   INPUT par_nmdatela,
                                   INPUT par_nrdconta,
                                  OUTPUT aux_nrdrowid ).
          RETURN "NOK".
      END.        

    RETURN "OK".
END.


PROCEDURE atualiza_inassele:

   DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
   DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
   DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.   
   DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
   DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
   
   DEF  INPUT PARAM par_inassele AS INTE                           NO-UNDO.   
   DEF  INPUT PARAM par_cdhistor AS CHAR                           NO-UNDO.   
   DEF  INPUT PARAM par_cdrefere AS DEC                            NO-UNDO.      
   DEF OUTPUT PARAM TABLE FOR tt-erro.   

   DEF VAR aux_cdcritic AS INT                                     NO-UNDO.
   DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
   DEF VAR aux_vlrantes AS INTEGER                                 NO-UNDO.
   DEF VAR aux_vldepois AS INTEGER                                 NO-UNDO.        
  
   ASSIGN aux_cdcritic = 0
          aux_dscritic = ""
          aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
          aux_dstransa = "Atualizar indicador de assinatura eletronica.".
          
  FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
               NO-LOCK NO-ERROR NO-WAIT.
  
  FIND crapatr WHERE crapatr.cdcooper = par_cdcooper      AND
                     crapatr.nrdconta = par_nrdconta      AND
                     crapatr.cdhistor = INT(par_cdhistor) AND
                     crapatr.cdrefere = par_cdrefere 
                     USE-INDEX crapatr1
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

  IF  NOT AVAILABLE crapatr THEN
      ASSIGN aux_dscritic = "Autorizacao nao encontrada.".
   
   /*ASSIGN aux_vlrantes = crapatr.inassele
          aux_vldepois = par_inassele.*/
   
   IF  aux_dscritic = "" OR aux_cdcritic = 0 THEN
       DO:  
          /* 1- Por senha / 2 - Autorizacao Assinada */
          /*ASSIGN crapatr.inassele = par_inassele.   */
            VALIDATE crapatr.            
            RELEASE crapatr.
            
          UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " " +
                          STRING(TIME,"HH:MM:SS") + "' --> '"  +
                          " Operador " + par_cdoperad +
                          " Incluir/Alterou '    'a Fatura " + STRING(par_cdrefere) +
                          " - " + "Conta " +
                          STRING(par_nrdconta,"zzzz,zzz,9") + 
                          "' --> '" + "inassele" +
                          " de " + STRING(aux_vlrantes) +
                          " para " + STRING(aux_vldepois) +
                          " >> /usr/coop/" + TRIM(crapcop.dsdircop) +
                          "/log/autori.log").
          
       END.
   ELSE
       DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log ( INPUT par_cdcooper,
                                     INPUT par_cdoperad,
                                     INPUT aux_dscritic,
                                     INPUT aux_dsorigem,
                                     INPUT aux_dstransa,
                                     INPUT TRUE,
                                     INPUT 0,
                                     INPUT par_nmdatela,
                                     INPUT par_nrdconta,
                                    OUTPUT aux_nrdrowid ).
          RETURN "NOK".
       END.   
   
   
   RETURN "OK".
                            
END PROCEDURE.