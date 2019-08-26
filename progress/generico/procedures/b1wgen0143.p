/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0143.p
    Autor   : Gabriel Capoia (DB1)
    Data    : 07/12/2012                     Ultima atualizacao:14/10/2016.

    Objetivo  : Tranformacao BO tela MANCCF.

    Alteracoes: 10/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
                29/11/2013 - Retirado comentários e códigos comentados
                             desnecessários (Jéssica DB1) e acertado a 
                             identação.

                19/03/2015 #255079 Inclusao da procedure Refaz_Regulariza para 
                           permitir reenviar o cheque p regularizacao. 
                           Gravando log para verlog (Carlos)
    
                13/01/2016 - Ajustes pra impressao da carta na tela manccf web
                             (Tiago/Elton SD379410)
                             
                09/08/2016 - #480588 Ajuste da rotina Imprime_Carta para 
                             atualizar os campos dtimpreg e cdopeimp (Carlos)
                             
                11/08/2016 - #481330 Ajuste da procedure Refaz_Regulariza para
                             atualizar os campos flgctitg, dtfimest e cdoperad;
                             Melhoria do retorno de erros (Carlos)

                14/10/2016 - #536120 Melhoria da msg de log na rotina proc_crialog
                             e criacao de logtel para a opcao 
                             Refaz_regulariza (Carlos)
							 
                24/04/2018 - #853017 Permitir realizar o Refaz Regularização para 
				             qualquer situação diferente de 0 (ainda não enviado). 
							 (Wagner/Sustenção).			
							 
                14/01/2019 - Alteracoes para balizar novo botao de inclusao de
                             devolucoes pela alinea 12. 
                             Chamado PRB0040458 - Gabriel (Mouts).				 
                             
                29/07/2019 - Alteracoes na mensagem de impressao de carta adicionando
                             a taxa do bacen. (RITM0020376 - Joao Mannes (Mouts))
                             
............................................................................*/

/*............................. DEFINICOES .................................*/
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0143tt.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3.
DEF STREAM str_4.

DEF VAR aux_dstransa AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                        NO-UNDO.
DEF VAR aux_idorigem AS INTE                                        NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen9998 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.
                                                                    
DEF VAR aux_nmarqtp1 AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqtp2 AS CHAR                                        NO-UNDO.
DEF VAR aux_nmarqtp3 AS CHAR                                        NO-UNDO.
                                                       
DEF VAR aux_flgfirst AS LOGI                                        NO-UNDO.
DEF VAR aux_flgfibob AS LOGI                                        NO-UNDO.
DEF VAR aux_flgfibra AS LOGI                                        NO-UNDO.
DEF VAR aux_flgficec AS LOGI                                        NO-UNDO.

DEF VAR rel_dsexten1 AS CHAR     FORMAT "x(65)"                     NO-UNDO.
DEF VAR rel_dsexten2 AS CHAR     FORMAT "x(16)"                     NO-UNDO.
                                                                    
DEF VAR rel_nrcpfcgc AS CHAR     FORMAT "x(18)"                     NO-UNDO.
DEF VAR rel_nmrescop AS CHAR     EXTENT 2                           NO-UNDO.
DEF VAR aux_qtpalavr AS INTE                                        NO-UNDO.
DEF VAR aux_qtcontpa AS INTE                                        NO-UNDO.
DEF VAR aux_flgzerar AS LOGI                                        NO-UNDO.
                                                                    
DEF VAR aux_qtdtitul AS INTE                                        NO-UNDO.
                                                                    
DEF VAR aux_flgbanco AS LOGI                                        NO-UNDO.
DEF VAR aux_flgbncob AS LOGI                                        NO-UNDO.
DEF VAR aux_arquivaz AS LOGI                                        NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.
                                                                    
DEF VAR rel_cdbanchq AS INTE     FORMAT "zzz9"                      NO-UNDO.
DEF VAR rel_cdagechq AS INTE     FORMAT "zzz9"                      NO-UNDO.
DEF VAR rel_dtdiamov AS INTE     FORMAT "99"                        NO-UNDO.
DEF VAR rel_dtanomov AS INTE     FORMAT "9999"                      NO-UNDO.
DEF VAR rel_nmmesref AS CHAR     FORMAT "x(09)"                     NO-UNDO.
DEF VAR rel_nmdbanco AS CHAR     FORMAT "x(30)"                     NO-UNDO.
DEF VAR aux_nmmesref AS CHAR     FORMAT "x(11)" EXTENT 12            
                                 INIT ["JANEIRO  ","FEVEREIRO",   
                                       "MARCO    ","ABRIL    ",   
                                       "MAIO     ","JUNHO    ",   
                                       "JULHO    ","AGOSTO   ",   
                                       "SETEMBRO ","OUTUBRO  ",   
                                       "NOVEMBRO ","DEZEMBRO "]     NO-UNDO.
                                                                    
DEF VAR rel_nrdconta LIKE crapass.nrdconta                          NO-UNDO.
DEF VAR rel_nrdocmto LIKE crapneg.nrdocmto                          NO-UNDO.
DEF VAR rel_vlestour LIKE crapneg.vlestour                          NO-UNDO.
DEF VAR rel_nrdctabb LIKE crapneg.nrdctabb                          NO-UNDO.
DEF VAR rel_nmcidade AS CHAR     EXTENT 2                           NO-UNDO.
                                                                    
DEF VAR rel_idseqttl  LIKE crapneg.idseqttl                         NO-UNDO.
                                                                    
DEF VAR tel_nmextttl  AS CHAR    FORMAT "x(30)"                     NO-UNDO.
DEF VAR tel_nmextttl2 AS CHAR    FORMAT "x(30)"                     NO-UNDO.
DEF VAR tel_nrcpfcgc  LIKE crapass.nrcpfcgc                         NO-UNDO.
DEF VAR tel_nrcpfcgc2 LIKE crapttl.nrcpfcg                          NO-UNDO.
DEF VAR aux_dsdlinha  AS CHAR    FORMAT "x(31)"                        
                      INIT "-------------------------------"        NO-UNDO.
DEF VAR aux_dscpfcgc  AS CHAR    FORMAT "x(9)"  INIT "CPF/CNPJ:"    NO-UNDO.
DEF VAR aux_nrdconta  AS CHAR                   INIT "C/C:"         NO-UNDO.
DEF VAR rel_nrdconta2 LIKE crapass.nrdconta                         NO-UNDO.
                                                                    
DEF VAR aux_vlregccf AS DECI     FORMAT "zz9.99"                    NO-UNDO.
DEF VAR aux_contchq  AS INTE                                        NO-UNDO.
DEF VAR aux_vltotccf AS DECI     FORMAT "zzz,zz9.99"                NO-UNDO.
DEF VAR aux_vltarifa AS DECI     FORMAT "zzz,zz9.99"                NO-UNDO.
DEF VAR aux_vltotal  AS DECI     FORMAT "zzz,zz9.99"                NO-UNDO.

DEF VAR aux_qtchqbob AS INTE                                        NO-UNDO.
DEF VAR aux_qtchqcec AS INTE                                        NO-UNDO.
DEF VAR aux_qtchqbra AS INTE                                        NO-UNDO.

FORM SKIP(2)
    rel_nmcidade[1] FORMAT "x(25)" ","  rel_dtdiamov "DE" rel_nmmesref FORMAT "x(09)" "DE"
    rel_dtanomov "." AT 52
    SKIP(2)
    "A"
    SKIP
    crapcop.nmextcop
    SKIP(2)
    "Prezados Senhores:"  
    SKIP(2)
    WITH NO-BOX NO-LABEL DOWN WIDTH 77
    FRAME f_cabec_bancoob.

FORM SKIP(2)     
    "Solicito  a " crapcop.nmextcop " a" 
    SKIP
    "exclusao no CCF (Cadastro de Emitentes de Cheque sem  Fundos), dos registros"
    SKIP 
    "incluidos pela devolucao do(s) seguinte(s) cheque(s):"
    WITH NO-BOX NO-LABEL DOWN WIDTH 90 FRAME f_escop_bancoob.
      
FORM SKIP(2)
    "\017Banco"                AT 01
    " Agencia"                 AT 15
    " Conta"                   AT 33
    "Nr Cheque"                AT 49
    "Valor"                    AT 66
    "Tit.\022"                 AT 79
    WITH NO-BOX NO-LABEL DOWN WIDTH 90 FRAME f_titulo_bcobrasil.
         
FORM tt-crapneg.cdbanchq                            AT 01
     tt-crapneg.cdagechq                            AT 17
     tt-crapneg.nrdctabb   FORMAT "zzzz,zzz,9"      AT 28
     tt-crapneg.nrdocmto   FORMAT "zzz,zzz,9"       AT 47
     tt-crapneg.vlestour   FORMAT "zzz,zzz.99"      AT 60
     tt-crapneg.idseqttl   FORMAT "z9"              AT 80
     WITH NO-BOX NO-LABEL DOWN WIDTH 90 FRAME f_relacao_bcobrasil.

FORM SKIP(1)
    "Autorizo o debito na minha conta corrente da tarifa de exclusao de CCF,"
    SKIP
    "no valor total de R$" aux_vltotccf
    SKIP(3)
    "Atenciosamente,"
    SKIP(2)
    WITH NO-BOX NO-LABEL WIDTH 90 FRAME f_rodape.

FORM SKIP(1)
    "Autorizo o debito na minha conta corrente da tarifa de exclusao de CCF,"
    SKIP
    "no valor de R$" aux_vltotal
    SKIP
    "A regularizacao do CCF sera efetuada mediante pagamento da tarifa em "
    SKIP
    "conta corrente, ou pagamento em especie no caixa."
    SKIP(3)
    "Atenciosamente,"
    SKIP(2)
    WITH NO-BOX NO-LABEL WIDTH 90 FRAME f_rodape3.    
    
FORM SKIP(4)
    "-------------------------------"
    aux_dsdlinha AT 35 
    SKIP
    "\033\105" tel_nmextttl "\033\106"
    "\033\105" tel_nmextttl2 AT 42 "\033\106"   
    SKIP                                         
    "\033\105" "CPF/CNPJ:" 
               tel_nrcpfcgc    "\033\106"
    "\033\105" aux_dscpfcgc    AT 42  
               tel_nrcpfcgc2   "\033\106"
    SKIP
    "\033\105" "C/C:" rel_nrdconta "\033\106"
    "\033\105" aux_nrdconta AT 42 
               rel_nrdconta2 "\033\106"
    SKIP(6)
    "-------------------------------"
    SKIP
    "\033\105" crapope.cdoperad "\033\106"
    "\033\105" " - "            
               crapope.nmoperad "\033\106" AT 14
    SKIP(1)
    "OBS: OS DOCUMENTOS DEVEM ESTAR DE ACORDO COM AS NORMAS DO BACEN, SUJEITO A ANALISE"
    SKIP
    "PARA EFETIVAR A REGULARIZACAO DO CCF."
     
    WITH NO-BOX NO-LABEL DOWN WIDTH 90 FRAME f_rodape2.                         

FUNCTION LockTabela   RETURNS CHARACTER PRIVATE 
    ( INPUT par_cddrecid AS RECID,
      INPUT par_nmtabela AS CHAR ) FORWARD.

FUNCTION f_ver_contaitg RETURN INTEGER PRIVATE
    (INPUT par_nrdctitg AS CHAR) FORWARD.

/*................................ PROCEDURES ..............................*/
/* ------------------------------------------------------------------------ */
/*                         EFETUA A BUSCA MANUTENCAO DO CCF                 */
/* ------------------------------------------------------------------------ */
PROCEDURE Busca_Dados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM aux_nmprimtl AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR cratneg.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_opmigrad AS LOGI                                    NO-UNDO.
    DEF VAR aux_nmoperad AS CHAR                                    NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Manutencao do CCF".

    EMPTY TEMP-TABLE cratneg.
    EMPTY TEMP-TABLE tt-erro.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        
        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crapcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Busca.
            END.

        IF  NOT VALID-HANDLE(h-b1wgen9998) THEN
            RUN sistema/generico/procedures/b1wgen9998.p
                PERSISTENT SET h-b1wgen9998.

        /* Validacao de operado e conta migrada */
        RUN valida_operador_migrado IN h-b1wgen9998
                                  ( INPUT par_cdoperad,
                                    INPUT par_nrdconta,
                                    INPUT par_cdcooper,
                                    INPUT 0, /* cdagenci */
                                   OUTPUT aux_opmigrad,
                                   OUTPUT TABLE tt-erro).

        IF  VALID-HANDLE(h-b1wgen9998) THEN
            DELETE OBJECT h-b1wgen9998.

        IF  RETURN-VALUE <> "OK" THEN
            LEAVE Busca.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND
                           crapass.nrdconta = par_nrdconta  NO-LOCK
                      USE-INDEX crapass1 NO-ERROR.

        IF  NOT AVAILABLE crapass THEN
            DO:
                ASSIGN aux_cdcritic = 009
                       aux_dscritic = "".
                LEAVE Busca.
            END.

        ASSIGN aux_nmprimtl = crapass.nmprimtl.

        FOR EACH crapneg WHERE crapneg.cdcooper = par_cdcooper      AND
                               crapneg.nrdconta = crapass.nrdconta  AND
                               crapneg.cdhisest = 1                 AND
                               CAN-DO("12,13", STRING(crapneg.cdobserv)) 
                               USE-INDEX crapneg1 NO-LOCK: 

            FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                               crapope.cdoperad = crapneg.cdoperad
                               NO-LOCK NO-ERROR.

            IF  AVAIL crapope THEN
                ASSIGN aux_nmoperad = STRING(ENTRY(1, crapope.nmoperad," "),"x(11)").
            ELSE                        
                ASSIGN aux_nmoperad = "".

            CREATE cratneg.
            ASSIGN cratneg.nrseqdig = crapneg.nrseqdig
                   cratneg.dtiniest = crapneg.dtiniest
                   cratneg.cdbanchq = crapneg.cdbanchq
                   cratneg.nrctachq = crapneg.nrctachq
                   cratneg.cdobserv = crapneg.cdobserv
                   cratneg.nrdocmto = crapneg.nrdocmto
                   cratneg.vlestour = crapneg.vlestour
                   cratneg.dtfimest = crapneg.dtfimest
                   cratneg.nmoperad = aux_nmoperad
                   cratneg.flgselec = FALSE
                   cratneg.flgctitg = crapneg.flgctitg
                   cratneg.idseqttl = crapneg.idseqttl.  

        END.    /*   Fim do for each crapneg   */

        /*IF  NOT TEMP-TABLE cratneg:HAS-RECORDS THEN
            DO:
                ASSIGN aux_cdcritic = 530
                       aux_dscritic = "".
                LEAVE Busca.
            END.*/

        LEAVE Busca.

    END. /* Busca */

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                
            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
        /*OUTPUT CLOSE.*/
    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */

PROCEDURE Busca_Titular:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR cratttl.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_qtdtitul AS INTE                                    NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_qtdtitul = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Manutencao do CCF".

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE cratttl.

    Busca: DO ON ERROR UNDO Busca, LEAVE Busca:
        
        FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND
                           crapass.nrdconta = par_nrdconta  NO-LOCK
                      USE-INDEX crapass1 NO-ERROR.

        IF  NOT AVAILABLE crapass THEN
            DO:
                ASSIGN aux_cdcritic = 009
                       aux_dscritic = "".
                LEAVE Busca.
            END.

        IF  crapass.inpessoa = 2 THEN
            DO:
                CREATE cratttl.
                ASSIGN cratttl.idseqttl = 1 
                       cratttl.nmextttl = crapass.nmprimtl.
                       aux_qtdtitul = aux_qtdtitul + 1.
            END.

        FOR EACH crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta 
                               NO-LOCK:

            CREATE cratttl.
            ASSIGN cratttl.idseqttl = crapttl.idseqttl
                   cratttl.nmextttl = crapttl.nmextttl
                   aux_qtdtitul = aux_qtdtitul + 1.          

        END.
    
        IF  aux_qtdtitul > 1 THEN
            DO:
                CREATE  cratttl.
                ASSIGN  cratttl.idseqttl = 9 
                        cratttl.nmextttl = "TODOS".
            END.

        LEAVE Busca.

    END. /* Busca */

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                
            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Titular */

/* ------------------------------------------------------------------------- */
/*               REALIZA A GRAVACAO DOS DADOS DA OPCAO TITULAR               */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Titular:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_nrseqdig AS INTE                                    NO-UNDO.
    DEF VAR aux_flgdocto AS LOGI                                    NO-UNDO.
   
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Grava Manutencao do CCF - Titular"
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_idorigem = par_idorigem.

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        Contador: DO aux_contador = 1 TO 10:

            FIND crapneg WHERE crapneg.cdcooper = par_cdcooper AND
                               crapneg.nrdconta = par_nrdconta AND
                               crapneg.cdhisest = 1            AND
                               crapneg.nrseqdig = par_nrseqdig AND
                               CAN-DO("12,13", STRING(crapneg.cdobserv)) 
                               USE-INDEX crapneg1 EXCLUSIVE-LOCK NO-ERROR.

            IF  NOT AVAIL crapneg THEN
                DO:
                    IF  LOCKED(crapneg)   THEN
                        DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                    FIND crapneg WHERE
                                         crapneg.cdcooper = par_cdcooper AND
                                         crapneg.nrdconta = par_nrdconta AND
                                         crapneg.cdhisest = 1            AND
                                         crapneg.nrseqdig = par_nrseqdig AND
                                         CAN-DO("12,13", STRING(crapneg.cdobserv)) 
                                         USE-INDEX crapneg1 NO-LOCK NO-ERROR.

                                    /* encontra o usuario que esta travando */
                                    ASSIGN aux_dscritic = 
                                               LockTabela( INPUT RECID(crapneg),
                                                           INPUT "crapneg").
                                    LEAVE Contador.
                                END.
                            ELSE 
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT Contador.
                                END.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 419.
                            LEAVE Contador.
                        END.
                END.
            ELSE
                LEAVE Contador.
                
        END. /* Contador */

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        RUN proc_crialog_2
            (INPUT par_cdcooper,
             INPUT par_dtmvtolt,
             INPUT par_cdoperad,
             INPUT crapneg.nrdconta,
             INPUT crapneg.idseqttl,
             INPUT par_idseqttl,
             INPUT crapneg.nrdocmto).

           ASSIGN crapneg.idseqttl = par_idseqttl.
        
        LEAVE Grava.

    END. /* Grava */
    
    ASSIGN aux_returnvl = "OK".

    IF  aux_dscritic <> "" OR 
        aux_cdcritic <> 0  THEN
        DO: 
            
                ASSIGN aux_returnvl = "NOK".
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
          
        END.
    ELSE
        DO:        
            IF TEMP-TABLE tt-erro:HAS-RECORDS THEN
                ASSIGN aux_returnvl = "NOK".
                
        END.

    RETURN aux_returnvl.

END PROCEDURE. /* Grava_Titular */

/* ------------------------------------------------------------------------- */
/*             REALIZA A GRAVACAO DOS DADOS DA OPCAO REGULARIZAR             */
/* ------------------------------------------------------------------------- */
PROCEDURE Grava_Regulariza:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimest AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgctitg AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM aux_msgconfi AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nmoperad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_dtfimest AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM aux_flgctitg AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_flgzerar AS LOGI                                    NO-UNDO.
   
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Grava Manutencao do CCF - Regulariza"
           aux_cdcritic = 0
           aux_nmoperad = par_nmoperad
           aux_dtfimest = par_dtfimest
           aux_flgctitg = par_flgctitg
           aux_returnvl = "NOK"
           aux_idorigem = par_idorigem.

    Grava: DO TRANSACTION
        ON ERROR  UNDO Grava, LEAVE Grava
        ON QUIT   UNDO Grava, LEAVE Grava
        ON STOP   UNDO Grava, LEAVE Grava
        ON ENDKEY UNDO Grava, LEAVE Grava:

        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crapcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Grava.
            END.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND
                           crapass.nrdconta = par_nrdconta  NO-LOCK
                      USE-INDEX crapass1 NO-ERROR.

        IF  NOT AVAILABLE crapass THEN
            DO:
                ASSIGN aux_cdcritic = 009
                       aux_dscritic = "".
                LEAVE Grava.
            END.

        Contador: DO aux_contador = 1 TO 10:

            FIND crapneg WHERE crapneg.cdcooper = par_cdcooper AND
                               crapneg.nrdconta = par_nrdconta AND
                               crapneg.nrseqdig = par_nrseqdig
                               USE-INDEX crapneg1 EXCLUSIVE-LOCK NO-ERROR.

            IF  NOT AVAIL crapneg THEN
                DO:
                    IF  LOCKED(crapneg)   THEN
                        DO:
                            IF  aux_contador = 10 THEN
                                DO:
                                    FIND crapneg WHERE
                                         crapneg.cdcooper = par_cdcooper AND
                                         crapneg.nrdconta = par_nrdconta AND
                                         crapneg.nrseqdig = par_nrseqdig
                                         USE-INDEX crapneg1 NO-LOCK NO-ERROR.

                                    /* encontra o usuario que esta travando */
                                    ASSIGN aux_dscritic = 
                                               LockTabela( INPUT RECID(crapneg),
                                                           INPUT "crapneg").
                                    LEAVE Contador.
                                END.
                            ELSE 
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT Contador.
                                END.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 419.
                            LEAVE Contador.
                        END.
                END.
            ELSE
                LEAVE Contador.
                
        END. /* Contador */

        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
            UNDO Grava, LEAVE Grava.

        ASSIGN aux_flgzerar = FALSE.

        IF  crapneg.dtfimest = ? THEN
            DO:
            /* Deixa regularizar o cheque se a inclusao ja foi processada
            pelo banco de compensacao/serasa ou se nem foi enviada */
            IF  crapneg.flgctitg <> 2   AND
                crapneg.flgctitg <> 0   THEN
                DO:
                    IF (crapneg.flgctitg = 3   AND
                        crapneg.cdbanchq = 756 AND
                        crapneg.dtiniest < 01/01/2007) OR  
                       (crapneg.flgctitg = 1 AND  /*Bancoob nao tem retorno*/
                        crapneg.cdbanchq = 756)  THEN
                        .
                    ELSE
                        DO:
                            IF  crapneg.cdbanchq <> crapcop.cdbcoctl  THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "A Inclusao no CCF ainda nao foi processada " +
                                                          "pelo banco de compensacao. Impossivel Regularizar!".
                                    UNDO Grava, LEAVE Grava.
                                END.
                            ELSE
                                DO:
                                    ASSIGN aux_cdcritic = 0
                                           aux_dscritic = "A Inclusao no CCF ainda nao foi processada pelo SERASA." +
                                                          "Impossivel Regularizar!".
                                    UNDO Grava, LEAVE Grava.
                                END.

                        END. /*Else*/

                END. /* IF  crapneg.flgctitg <> 2 ... */

            ASSIGN crapneg.cdoperad = par_cdoperad
                   crapneg.dtfimest = par_dtmvtolt
                   crapneg.flgctitg = IF crapneg.flgctitg = 2 OR 
                                         crapneg.flgctitg = 3 OR
                                         crapneg.flgctitg = 1 THEN
                                           6   /* enviar exclusao no CCF */
                                      ELSE crapneg.flgctitg.

            IF  crapneg.flgctitg <>  0 THEN
                RUN proc_crialog
                    ( INPUT par_cdcooper,
                      INPUT par_dtmvtolt,
                      INPUT par_cdoperad,
                      INPUT par_nrdconta,
                      INPUT "envio",
                      INPUT crapneg.nrdocmto).
            ELSE
                RUN proc_crialog
                    ( INPUT par_cdcooper,
                      INPUT par_dtmvtolt,
                      INPUT par_cdoperad,
                      INPUT par_nrdconta,
                      INPUT "exclusao",
                      INPUT crapneg.nrdocmto).

            END. /* IF  crapneg.dtfimest ... */
        ELSE
            DO:
                IF  crapneg.dtfimest = par_dtmvtolt THEN
                    DO:
                        /* Deixa cancelar a regularizacao se a propria regula-
                           rizacao ainda nao foi enviada ao banco de compensa-
                           cao/serasa ou se a inclusao foi bem sussedida */
                        IF  crapneg.flgctitg <> 6   AND
                            crapneg.flgctitg <> 2   AND
                            crapneg.flgctitg <> 0   AND      
                            crapneg.flgctitg <> 1   AND
                            crapneg.cdbanchq <> 756 THEN
                            DO:   
                                IF  crapneg.cdbanchq <> crapcop.cdbcoctl  THEN
                                    DO:
                                        ASSIGN aux_cdcritic = 0
                                               aux_dscritic = "A Regularizacao no CCF ainda nao foi processada pelo banco" +
                                                              "de compensacao. Impossivel Cancelar!".
                                        UNDO Grava, LEAVE Grava.
                                    END.
                                ELSE
                                    DO:
                                        ASSIGN aux_cdcritic = 0
                                               aux_dscritic = "A Regularizacao no CCF ainda nao foi processada pelo SERASA." +
                                                              "Impossivel Cancelar!".
                                        UNDO Grava, LEAVE Grava.
                                    END.

                            END. /* IF  crapneg.flgctitg <> 6 ... */

                        IF  crapneg.flgctitg = 2   THEN
                            ASSIGN aux_msgconfi = "ATENCAO! Voce deve enviar a INCLUSAO NO CCF!!!".

                        ASSIGN crapneg.cdoperad = ""
                               crapneg.dtfimest = ?
                               aux_flgzerar     = TRUE
                               crapneg.flgctitg = IF  crapneg.dtectitg <> ?
                                                      THEN 2  /*Inclusao OK*/
                                                      ELSE 0. /*Nao enviada*/

                        IF  crapneg.flgctitg <> 0   THEN   
                            RUN proc_crialog
                                ( INPUT par_cdcooper,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdoperad,
                                  INPUT par_nrdconta,
                                  INPUT "cancelamento - envio", 
                                  INPUT crapneg.nrdocmto).
                        ELSE
                            RUN proc_crialog
                                ( INPUT par_cdcooper,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdoperad,
                                  INPUT par_nrdconta,
                                  INPUT "cancelamento - exclusao",
                                  INPUT crapneg.nrdocmto).

                    END. /* IF  crapneg.dtfimest ... */

            END. /* ELSE */

        IF  aux_flgzerar THEN
            ASSIGN aux_nmoperad = ""
                   aux_dtfimest = ?
                   aux_flgctitg = crapneg.flgctitg.
        ELSE
            DO:

                IF  crapneg.dtfimest = par_dtmvtolt THEN
                    DO:
                        FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                                           crapope.cdoperad = crapneg.cdoperad
                                           NO-LOCK NO-ERROR.

                        IF  AVAIL crapope THEN
                            ASSIGN aux_nmoperad = 
                                STRING(ENTRY(1, crapope.nmoperad," "),"x(11)").
                        ELSE                        
                            ASSIGN aux_nmoperad = "INEXISTENTE".

                        ASSIGN aux_nmoperad = aux_nmoperad
                               aux_dtfimest = par_dtmvtolt
                               aux_flgctitg = crapneg.flgctitg.
                    END.
                ELSE 
                    DO:
                        ASSIGN aux_cdcritic = 520.
                        LEAVE Grava.
                    END. 
        END.

        LEAVE Grava.

    END. /* Grava */

    ASSIGN aux_returnvl = "OK".

    IF  aux_dscritic <> "" OR 
        aux_cdcritic <> 0  THEN
        DO: 
            ASSIGN aux_returnvl = "NOK".
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        DO:        
            IF TEMP-TABLE tt-erro:HAS-RECORDS THEN
                ASSIGN aux_returnvl = "NOK".
        END.

    RETURN aux_returnvl.

END PROCEDURE. /* Grava_Regulariza */


PROCEDURE Refaz_Regulariza:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimest AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgctitg AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM aux_msgconfi AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nmoperad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_dtfimest AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM aux_flgctitg AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_nrdocmto LIKE crapneg.nrdocmto NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    LimpaData: DO TRANSACTION
        ON ERROR  UNDO LimpaData, LEAVE LimpaData
        ON QUIT   UNDO LimpaData, LEAVE LimpaData
        ON STOP   UNDO LimpaData, LEAVE LimpaData
        ON ENDKEY UNDO LimpaData, LEAVE LimpaData:

        Contador: DO aux_contador = 1 TO 10:
        
        FIND crapneg WHERE crapneg.cdcooper = par_cdcooper AND
                           crapneg.nrdconta = par_nrdconta AND
                           crapneg.nrseqdig = par_nrseqdig
                           USE-INDEX crapneg1 EXCLUSIVE-LOCK NO-ERROR.
        
        IF  NOT AVAIL crapneg THEN
            DO:
                IF  LOCKED(crapneg)   THEN
                    DO:
                        IF  aux_contador = 10 THEN
                            DO:
                                FIND crapneg WHERE
                                     crapneg.cdcooper = par_cdcooper AND
                                     crapneg.nrdconta = par_nrdconta AND
                                     crapneg.nrseqdig = par_nrseqdig
                                     USE-INDEX crapneg1 NO-LOCK NO-ERROR.
        
                                /* encontra o usuario que esta travando */
                                ASSIGN aux_dscritic = 
                                           LockTabela( INPUT RECID(crapneg),
                                                       INPUT "crapneg").
                                LEAVE Contador.
                            END.
                        ELSE 
                            DO:
                                PAUSE 1 NO-MESSAGE.
                                NEXT Contador.
                            END.
                    END.
                ELSE
                    DO:
                        ASSIGN aux_cdcritic = 419.
                        LEAVE Contador.
                    END.
            END.
        ELSE
            LEAVE Contador.
            
        END. /* Contador */
        
        IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        UNDO LimpaData, LEAVE LimpaData.

        IF crapneg.flgctitg <> 0 THEN
        DO:
            ASSIGN crapneg.flgctitg = 6
                   crapneg.dtfimest = par_dtmvtolt
                   crapneg.cdoperad = par_cdoperad
                   aux_nrdocmto     = crapneg.nrdocmto.
        END.
        ELSE
        DO:
            ASSIGN aux_dscritic = "O cheque precisa estar com a situacao diferente de 0 (zero)".
        END.

        RELEASE crapneg.

        LEAVE LimpaData.

    END. /* fim LimpaData */

    ASSIGN aux_returnvl = "OK".

    IF  aux_dscritic <> "" OR 
        aux_cdcritic <> 0  OR
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
    ASSIGN aux_returnvl = "NOK".

    IF aux_returnvl = "OK" THEN
    DO:
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Reenviar regularizacao".
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT aux_dscritic,
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT NO,
                            INPUT 1, /** idseqttl **/
                            INPUT 'MANCCF',
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).
        
        RUN proc_crialog (INPUT par_cdcooper,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrdconta,
                          INPUT aux_dstransa, 
                          INPUT aux_nrdocmto).
    END.

    RETURN aux_returnvl.
      
END PROCEDURE.

/* ------------------------------------------------------------------------- */
/*             REALIZA A GRAVACAO NO CCF             						 */
/* ------------------------------------------------------------------------- */
PROCEDURE Inclui_CCF:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcheque AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlcheque AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
	DEF  INPUT PARAM par_nmoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtfimest AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgctitg AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM aux_msgconfi AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_nmoperad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM aux_dtfimest AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM aux_flgctitg AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador_11 AS INTE                                 	NO-UNDO.
    DEF VAR aux_contador_12 AS INTE                                 	NO-UNDO.
	DEF VAR aux_nrseqneg    AS INTE                                     NO-UNDO.
	
	DEF BUFFER crabneg FOR crapneg.
   
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_dsorigem = ""
           aux_dstransa = "Inclusao no CCF"
           aux_cdcritic = 0
           aux_returnvl = "NOK"
		   aux_contador_11 = 0
		   aux_contador_12 = 0.

	FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.

	IF  NOT AVAILABLE crapcop  THEN
		DO: 
			ASSIGN aux_cdcritic = 651
				   aux_dscritic = "Cooperativa nao encontrada.".
		END.

	FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND
					   crapass.nrdconta = par_nrdconta  NO-LOCK
				  USE-INDEX crapass1 NO-ERROR.

	IF  NOT AVAILABLE crapass THEN
		DO:
			ASSIGN aux_cdcritic = 009
				   aux_dscritic = "Associado nao encontrado.".
		END.

	FOR EACH crapneg WHERE crapneg.cdcooper = par_cdcooper AND
						   crapneg.nrdconta = par_nrdconta AND
						   crapneg.nrdocmto = par_nrcheque AND
						   crapneg.vlestour = par_vlcheque AND
						   CAN-DO("11,12", STRING(crapneg.cdobserv)) NO-LOCK:
		
		IF crapneg.cdobserv = 11 THEN
			DO: ASSIGN aux_contador_11 = aux_contador_11 + 1. END.
		 
		IF crapneg.cdobserv = 12 THEN 
			DO: ASSIGN aux_contador_12 = aux_contador_12 + 1. END.
	END.
	
	IF aux_contador_11 = 0 AND aux_contador_12 = 0 THEN
		DO:
			ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Cheque nao localizado.".
			
		END.
	
	IF aux_contador_11 < 2 AND aux_dscritic = "" THEN
		DO:
			ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Inclusao nao permitida, cheque nao foi devolvido " +
								  "duas vezes pela alinea 11.".
		END.
	
	IF aux_contador_12 >= 1 AND aux_dscritic = "" THEN
		DO:
			ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Inclusao nao permitida, cheque ja incluso" +
								  " no CCF pela alinea 12.".
		END.
		
	 /* Cursor que cddepart parametrizado */
    FIND FIRST crapprm WHERE crapprm.cdcooper = 0
                         AND crapprm.nmsistem = "CRED"
                         AND crapprm.cdacesso = "EXCLUIR_DEVOLU_CDDEPART"
                             NO-LOCK NO-ERROR.

    /* Se nao encontrar aborta operacao */
    IF NOT AVAILABLE crapprm AND aux_dscritic = "" THEN
		DO:
			ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Parametrizacao de departamento nao encontrada.".
		END.

    /* Cursor que busca operadores */
    FIND FIRST crapope WHERE crapope.cdcooper = par_cdcooper
                         AND crapope.cdoperad = par_cdoperad
                         AND crapope.cdsitope = 1 
                             NO-LOCK NO-ERROR.

    /* Se operador nao possui permissoes retorna critica */
    IF NOT AVAILABLE crapope AND aux_dscritic = "" THEN
      DO:
			ASSIGN aux_cdcritic = 0
				   aux_dscritic = "Operador nao existe ou esta inativo.".
		END.
    ELSE
      DO:
            /* Inicialmente departamentos 4 e 20 sao permitidos */
            IF NOT CAN-DO(crapprm.dsvlrprm,STRING(crapope.cddepart)) AND aux_dscritic = "" THEN
				DO:
					ASSIGN aux_cdcritic = 0
						   aux_dscritic = "Inclusao nao permitida, somente operadores do departamento da compensacao.".
				END.
      END.
		
	IF aux_dscritic = "" THEN
		DO:
			RUN STORED-PROCEDURE pc_sequence_progress
			aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPNEG"
												,INPUT "NRSEQDIG"
												,INPUT STRING(par_cdcooper) + ";" + STRING(par_nrdconta)
												,INPUT "N"
												,"").
			  
			CLOSE STORED-PROC pc_sequence_progress
			aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
						
			ASSIGN aux_nrseqneg = INTE(pc_sequence_progress.pr_sequence)
								  WHEN pc_sequence_progress.pr_sequence <> ?.

			FIND FIRST crabneg WHERE crabneg.cdcooper = par_cdcooper AND
								     crabneg.nrdconta = par_nrdconta AND
								     crabneg.nrdocmto = par_nrcheque AND
								     crabneg.cdobserv = 11
									 NO-LOCK NO-ERROR.
			
			CREATE crapneg.
			ASSIGN crapneg.nrdconta = crabneg.nrdconta
				   crapneg.dtiniest = crabneg.dtiniest
				   crapneg.nrseqdig = aux_nrseqneg
				   crapneg.cdhisest = crabneg.cdhisest
				   crapneg.cdobserv = 12
				   crapneg.nrdctabb = crabneg.nrdctabb
				   crapneg.nrdocmto = crabneg.nrdocmto
				   crapneg.vlestour = crabneg.vlestour
				   crapneg.qtdiaest = crabneg.qtdiaest
				   crapneg.vllimcre = crabneg.vllimcre
				   crapneg.cdbanchq = crabneg.cdbanchq
				   crapneg.cdtctant = crabneg.cdtctant
				   crapneg.cdagechq = crabneg.cdagechq
				   crapneg.cdtctatu = crabneg.cdtctatu
				   crapneg.nrctachq = crabneg.nrctachq
				   crapneg.dtfimest = crabneg.dtfimest
				   crapneg.cdoperad = crabneg.cdoperad
				   crapneg.cdcooper = crabneg.cdcooper
				   crapneg.flgctitg = 0
				   crapneg.dtectitg = ?
				   crapneg.dtimpreg = crabneg.dtimpreg
				   crapneg.cdopeimp = crabneg.cdopeimp.
				   
			ASSIGN aux_msgconfi = "Inclusao realizada!".
		END.
	
	IF aux_dscritic <> "" THEN
		DO:
			ASSIGN aux_returnvl = "NOK".
		END.
	ELSE
		DO:
			ASSIGN aux_returnvl = "OK".
		END.
		
	IF aux_dscritic <> "" THEN
		DO:
			CREATE tt-erro.
			ASSIGN tt-erro.dscritic = aux_dscritic.
		END.

    RETURN aux_returnvl.

END PROCEDURE. /* Inclui_CCF */

/* ------------------------------------------------------------------------- */
/*                           GERA IMPRESSÃO DAS CARTAS                       */
/* ------------------------------------------------------------------------- */
PROCEDURE Imprime_Carta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqdig AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-nmarqimp.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_qtdtitul AS INTE                                    NO-UNDO.
    DEF VAR aux_cont     AS INTE                                    NO-UNDO.

    DEF VAR aux_cdtarifa AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdhistor AS INTE                                    NO-UNDO.
    DEF VAR aux_cdhisest AS INTE                                    NO-UNDO.
    DEF VAR aux_dtdivulg AS DATE                                    NO-UNDO.
    DEF VAR aux_dtvigenc AS DATE                                    NO-UNDO.
    DEF VAR aux_cdfvlcop AS INTE                                    NO-UNDO.
    DEF VAR h-b1wgen0153 AS HANDLE                                  NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0
           aux_returnvl = "NOK"
           aux_qtdtitul = 0
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca Dados Manutencao do CCF".

    EMPTY TEMP-TABLE tt-nmarqimp.
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapneg.
     
    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        
        FOR FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crapcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND
                           crapass.nrdconta = par_nrdconta  NO-LOCK
                      USE-INDEX crapass1 NO-ERROR.

        IF  NOT AVAILABLE crapass THEN
            DO:
                ASSIGN aux_cdcritic = 009
                       aux_dscritic = "".
                LEAVE Imprime.
            END.

        FIND crapope WHERE crapope.cdcooper = par_cdcooper  AND
                           crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapope THEN
            DO:
                ASSIGN aux_cdcritic = 67
                       aux_dscritic = "".
                LEAVE Imprime.
            END.


        ASSIGN rel_nmcidade[1] = TRIM(crapcop.nmcidade).

        /*   Busca o nome da cooperativa e divide o campo de duas variaveis  */
        ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crapcop.nmextcop)," ") / 2
               rel_nmrescop = "".

        DO aux_qtcontpa = 1 TO NUM-ENTRIES(TRIM(crapcop.nmextcop)," "):
            IF  aux_qtcontpa <= aux_qtpalavr   THEN
                ASSIGN rel_nmrescop[1] = rel_nmrescop[1] +  
                                        (IF TRIM(rel_nmrescop[1]) = "" THEN
                                             ""
                                         ELSE " ") +
                                         ENTRY(aux_qtcontpa,crapcop.nmextcop," ").
            ELSE
                ASSIGN rel_nmrescop[2] = rel_nmrescop[2] +
                                        (IF TRIM(rel_nmrescop[2]) = "" THEN
                                             "" 
                                         ELSE " ") +
                                         ENTRY(aux_qtcontpa,crapcop.nmextcop," ").
        END.  /*  Fim DO .. TO  */ 

        ASSIGN rel_nmrescop[1] = FILL(" ",20 - INT(LENGTH(rel_nmrescop[1]) / 2)) +
                                                          rel_nmrescop[1]
               rel_nmrescop[2] = FILL(" ",20 - INT(LENGTH(rel_nmrescop[2]) / 2)) +
                                                          rel_nmrescop[2]
               rel_nmrescop[1] = TRIM(rel_nmrescop[1]," ")
               rel_nmrescop[2] = TRIM(rel_nmrescop[2]," ").

        ASSIGN  aux_flgfibob = TRUE
                aux_flgfibra = TRUE
                aux_flgficec = TRUE
                aux_nmarqtp1 = "/usr/coop/viacredi/arq/bancoob" + par_dsiduser + STRING(TIME) + 
                                /* para evitar duplicidade devido paralelismo */
                                SUBSTRING(STRING(NOW),21,3) + ".ex" 
                /*
                aux_nmarqtp2 = "/usr/coop/viacredi/arq/bbrasil" + par_dsiduser + STRING(TIME) + 
                               /* para evitar duplicidade devido paralelismo */
                                SUBSTRING(STRING(NOW),21,3) + ".ex"
                
                aux_nmarqtp3 = "/usr/coop/viacredi/arq/bcecred" + par_dsiduser + STRING(TIME) + 
                              /* para evitar duplicidade devido paralelismo */
                              SUBSTRING(STRING(NOW),21,3) + ".ex"
                */
                rel_dtdiamov = DAY(par_dtmvtolt)
                rel_dtanomov = YEAR(par_dtmvtolt)
                rel_nmmesref = TRIM(aux_nmmesref[MONTH(par_dtmvtolt)]).

        ASSIGN rel_nrdconta = par_nrdconta.
      

        IF  crapass.inpessoa = 1 THEN
            ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
                   rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xxx.xxx.xxx-xx").
        ELSE
            ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                   rel_nrcpfcgc = STRING(rel_nrcpfcgc,"xx.xxx.xxx/xxxx-xx").
        
        
        DO aux_cont = 1 TO NUM-ENTRIES(par_nrseqdig):


            FOR EACH crapneg WHERE crapneg.cdcooper = par_cdcooper AND
                                   crapneg.nrdconta = par_nrdconta AND
                                   crapneg.nrseqdig = 
                                   INT(ENTRY(aux_cont,par_nrseqdig))
                                   USE-INDEX crapneg1 EXCLUSIVE-LOCK
                                   BY crapneg.nrdctabb
                                   BY crapneg.nrdocmto:

                CREATE tt-crapneg.
                ASSIGN tt-crapneg.nrdconta = crapneg.nrdconta
                       tt-crapneg.cdbanchq = crapneg.cdbanchq
                       tt-crapneg.cdagechq = crapneg.cdagechq
                       tt-crapneg.nrdocmto = crapneg.nrdocmto
                       tt-crapneg.nrctachq = crapneg.nrctachq
                       tt-crapneg.vlestour = crapneg.vlestour
                       tt-crapneg.idseqttl = crapneg.idseqttl
                       tt-crapneg.nrdctabb = crapneg.nrdctabb
                       aux_qtchqbob = aux_qtchqbob + 1
                       crapneg.dtimpreg    = par_dtmvtolt
                       crapneg.cdopeimp    = par_cdoperad.

                VALIDATE crapneg.
                        
            END. /* FOR EACH crapneg */
                
        END. /* FIM DO TO  */
        
            
            
        IF  crapass.inpessoa = 1  THEN
            ASSIGN aux_cdtarifa = "EXCLUCCFPF".
        ELSE
            ASSIGN aux_cdtarifa = "EXCLUCCFPJ".
                
        IF  NOT VALID-HANDLE(h-b1wgen0153) THEN
            RUN sistema/generico/procedures/b1wgen0153.p
                PERSISTENT SET h-b1wgen0153.

        RUN carrega_dados_tarifa_vigente IN h-b1wgen0153
                                        (INPUT par_cdcooper,
                                         INPUT aux_cdtarifa,
                                         INPUT 1, 
                                         INPUT "", /*cdprogra*/
                                        OUTPUT aux_cdhistor,
                                        OUTPUT aux_cdhisest,
                                        OUTPUT aux_vlregccf,
                                        OUTPUT aux_dtdivulg,
                                        OUTPUT aux_dtvigenc,
                                        OUTPUT aux_cdfvlcop,
                                        OUTPUT TABLE tt-erro).

        DELETE PROCEDURE h-b1wgen0153.

        IF  RETURN-VALUE <> "OK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.

                IF  AVAIL tt-erro  THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                ELSE
                    ASSIGN aux_dscritic = "Erro na tarifa de CCF.".

                LEAVE Imprime.
            END.

        ASSIGN 
               aux_flgbanco = TRUE
               aux_flgbncob = TRUE
               aux_arquivaz = TRUE
               aux_nmendter = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                              par_dsiduser
               aux_nmendter = aux_nmendter + STRING(TIME) + SUBSTRING(STRING(NOW),21,3).

       ASSIGN aux_nmarqimp = aux_nmendter + "_1.ex"
              aux_nmarqpdf = aux_nmendter + "_1.pdf".
        
       OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 84.

       ASSIGN aux_flgfirst = TRUE.
        
       FOR EACH tt-crapneg NO-LOCK:
     
          
            IF aux_flgfirst = TRUE THEN DO:

         

                    DISPLAY STREAM str_1 
                                   rel_dtdiamov  rel_nmmesref
                                   rel_dtanomov  crapcop.nmextcop
                                   rel_nmcidade[1]
                                   WITH FRAME f_cabec_bancoob.
        
                /*** Pessoa Juridica ***/
                IF  crapass.inpessoa <> 1 THEN
                    ASSIGN tel_nmextttl = crapass.nmprimtl.
                ELSE 
                    FOR EACH crapttl WHERE  
                             crapttl.cdcooper = par_cdcooper AND
                             crapttl.nrdconta = par_nrdconta NO-LOCK:
                        ASSIGN tel_nmextttl = crapttl.nmextttl.
                    END.
        
                DISPLAY STREAM str_1 crapcop.nmextcop   
                    WITH FRAME f_escop_bancoob.
        
                DISPLAY STREAM str_1 
                    WITH FRAME f_titulo_bcobrasil.
        
                ASSIGN aux_flgfirst = FALSE.
            END.


        DISP STREAM str_1 tt-crapneg.cdbanchq tt-crapneg.cdagechq
                          tt-crapneg.nrdctabb tt-crapneg.nrdocmto
                          tt-crapneg.vlestour tt-crapneg.idseqttl 
                      WITH FRAME f_relacao_bcobrasil.

        DOWN STREAM str_1 WITH FRAME f_relacao_bcobrasil.

       END.


        ASSIGN aux_vltotccf = aux_vlregccf * aux_qtchqbob.

        FIND crapfvl WHERE crapfvl.cdfaixav = 13 AND
                           crapfvl.cdtarifa = 14
                           NO-LOCK NO-ERROR.

        FIND crapfco WHERE crapfco.cdcooper = par_cdcooper AND
                           crapfco.cdfaixav = crapfvl.cdfaixav AND
                           crapfco.flgvigen = true
                           NO-LOCK NO-ERROR.
        
        IF AVAILABLE crapfco THEN
           ASSIGN aux_vltarifa = crapfco.vltarifa.
             
        IF (aux_vltarifa > 0) THEN
           DO:
             ASSIGN aux_vltotal  = aux_vltotccf + aux_vltarifa.
             DISPLAY STREAM str_1 aux_vltotal WITH FRAME f_rodape3.
           END.
        ELSE
        DISPLAY STREAM str_1 aux_vltotccf WITH FRAME f_rodape.

    /*** Pessoa Juridica ***/
    IF  crapass.inpessoa <> 1 THEN
        DO:
            ASSIGN tel_nmextttl = crapass.nmprimtl
                   tel_nrcpfcgc = crapass.nrcpfcgc.

            DISPLAY STREAM str_1 tel_nmextttl
                           tel_nrcpfcgc
                           rel_nrdconta
                           crapope.cdoperad
                           crapope.nmoperad
                           WITH FRAME f_rodape2.
        END.
    ELSE 
        FOR EACH crapttl WHERE  
                 crapttl.cdcooper = par_cdcooper AND
                 crapttl.nrdconta = par_nrdconta NO-LOCK :

            ASSIGN tel_nmextttl = crapttl.nmextttl
                   tel_nrcpfcgc = crapttl.nrcpfcgc.   

            IF  crapttl.idseqttl = 1 OR 
                crapttl.idseqttl = 3 THEN
                DO:
                    DISPLAY STREAM str_1 
                                   tel_nmextttl
                                   tel_nrcpfcgc
                                   rel_nrdconta
                                   crapope.cdoperad
                                   crapope.nmoperad
                                   WITH FRAME f_rodape2.
                END. /* IF  crapttl.idseqttl = 1 */

            IF  crapttl.idseqttl = 2 OR 
                crapttl.idseqttl = 4 THEN
                DO:    
                    ASSIGN tel_nmextttl2 = crapttl.nmextttl
                           tel_nrcpfcgc2 = crapttl.nrcpfcgc
                           rel_nrdconta2 = crapttl.nrdconta.

                    DISPLAY STREAM str_1 
                                   aux_dsdlinha
                                   tel_nmextttl2
                                   aux_dscpfcgc
                                   tel_nrcpfcgc2
                                   aux_nrdconta
                                   rel_nrdconta2
                                   crapope.cdoperad
                                   crapope.nmoperad
                                   WITH FRAME f_rodape2.
                END. /* IF  crapttl.idseqttl = 2 */

            IF  crapttl.idseqttl = 2 THEN         
                DOWN STREAM str_1 WITH FRAME f_rodape2.

        END. /* FOR EACH crapttl */


        CREATE tt-nmarqimp.
        ASSIGN tt-nmarqimp.nmarqimp = aux_nmarqimp.

       
        OUTPUT STREAM str_1 CLOSE.
        
        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
/*
                FOR EACH tt-nmarqimp:


                    ASSIGN aux_dscomand = "cat " /*+ aux_nmarqimp + ".aux "  */ + 
                                          tt-nmarqimp.nmarqimp + " >> " + 
                                          aux_nmarqimp + " 2> /dev/null".
        
                    UNIX SILENT VALUE(aux_dscomand).
                    
                    
                END.
*/
                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE Imprime.
                    END.

                RUN envia-arquivo-web IN h-b1wgen0024 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT aux_nmarqimp,
                     OUTPUT aux_nmarqpdf,
                     OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.

                IF  RETURN-VALUE <> "OK" THEN
                    RETURN "NOK".
            END.

        /* Remove os arquivos temporarios */
        IF  SEARCH(aux_nmarqtp1) <> ?   THEN
            UNIX SILENT VALUE("rm " + aux_nmarqtp1 + " 2> /dev/null").

        IF  SEARCH(aux_nmarqtp2) <> ?   THEN
            UNIX SILENT VALUE("rm " + aux_nmarqtp2 + " 2> /dev/null").

        IF  SEARCH(aux_nmarqtp3) <> ?   THEN
            UNIX SILENT VALUE("rm " + aux_nmarqtp3 + " 2> /dev/null").
        
        LEAVE Imprime.

    END. /* Imprime */

    IF  VALID-HANDLE(h-b1wgen9999) THEN
        DELETE OBJECT h-b1wgen9999.

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0  OR 
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN

                FIND FIRST tt-erro NO-ERROR.

                IF  AVAIL tt-erro THEN
                    ASSIGN aux_dscritic = tt-erro.dscritic.
                
            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT NO,
                                    INPUT 1, /** idseqttl **/
                                    INPUT par_nmdatela,
                                    INPUT 0, /* nrdconta */
                                   OUTPUT aux_nrdrowid).

        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* Busca_Dados */

/*............................. PROCEDURES INTERNAS .........................*/

PROCEDURE proc_crialog:

DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
DEF  INPUT PARAM aux_dtmvtolt AS DATE                           NO-UNDO.
DEF  INPUT PARAM aux_cdoperad AS CHAR                           NO-UNDO.
DEF  INPUT PARAM aux_nrdconta AS INTE                           NO-UNDO.
DEF  INPUT PARAM aux_opcreg   AS CHAR                           NO-UNDO.
DEF  INPUT PARAM aux_nrdocmto AS DECI                           NO-UNDO.

    FOR FIRST crapcop WHERE 
              crapcop.cdcooper = par_cdcooper NO-LOCK: END.

     UNIX SILENT VALUE("echo " + STRING(aux_dtmvtolt,"99/99/9999") + " "  +
                      STRING(TIME,"HH:MM:SS") + "' --> '"                 +
                      " Operador "  + aux_cdoperad                        +
                      " solicitou " + aux_opcreg                          + 
                      " na regularizacao "                                +
                      " do cheque "  + STRING(aux_nrdocmto,"zzz,zzz,9")   +
                      " na conta "  + STRING(aux_nrdconta,"zzzz,zzz,9")   +
                      " >> /usr/coop/" +  TRIM(crapcop.dsdircop) + 
                      "/log/manccf.log").

END PROCEDURE.

PROCEDURE proc_crialog_2:

DEF  INPUT PARAM par_cdcooper   AS INTE                        NO-UNDO.
DEF  INPUT PARAM aux_dtmvtolt   AS DATE                        NO-UNDO.
DEF  INPUT PARAM aux_cdoperad   AS CHAR                        NO-UNDO.
DEF  INPUT PARAM aux_nrdconta   AS INTE                        NO-UNDO.
DEF  INPUT PARAM aux_idseqttl   AS INTE                        NO-UNDO.
DEF  INPUT PARAM aux_idseqttl_2 AS INTE                        NO-UNDO.
DEF  INPUT PARAM aux_nrdocmto   AS DECI                        NO-UNDO.

    FOR FIRST crapcop WHERE 
              crapcop.cdcooper = par_cdcooper NO-LOCK: END.


     UNIX SILENT VALUE("echo " + STRING(aux_dtmvtolt,"99/99/9999") + " "  +
                      STRING(TIME,"HH:MM:SS") + "' --> '"                 +
                      " Operador "  + aux_cdoperad                        +
                      " alterou a titularidade"                           +
                      " da conta"     + STRING(aux_nrdconta,"zzzz,zzz,9") +
                      " - referente ao cheque "   
                                      + STRING(aux_nrdocmto,"zzz,zzz,9")  +
                      " -"                                                +
                      " de "          + STRING(aux_idseqttl,"9")          + 
                      " para "        + STRING(aux_idseqttl_2,"9")        +
                      " >> /usr/coop/" +  TRIM(crapcop.dsdircop) + 
                      "/log/manccf.log").

END PROCEDURE.

PROCEDURE Tira_asterisco:

    DEFINE INPUT  PARAMETER aux_dsstring AS CHAR      NO-UNDO.
    DEFINE OUTPUT PARAMETER aux_dsreturn AS CHAR      NO-UNDO.

    DEFINE VAR    aux_conta AS INTEGER                NO-UNDO.

    ASSIGN aux_conta = 1.

    DO WHILE aux_conta <= LENGTH(aux_dsstring):

        IF  SUBSTR(aux_dsstring, aux_conta, 1) = "*" THEN
            LEAVE.
        ELSE
            ASSIGN aux_conta = aux_conta + 1.
    END.

    IF  (aux_conta = 63 /* LENGTH(aux_dsstring) */) OR
        (aux_conta = 0)   THEN
        ASSIGN aux_dsreturn = "".
    ELSE
        ASSIGN aux_dsreturn = SUBSTR(aux_dsstring, 1, aux_conta - 1).

END PROCEDURE.

/*.............................. PROCEDURES (FIM) ...........................*/

/*................................ FUNCTIONS ................................*/

FUNCTION LockTabela RETURNS CHARACTER PRIVATE 
    ( INPUT par_cddrecid AS RECID,
      INPUT par_nmtabela AS CHAR ):
/*-----------------------------------------------------------------------------
  Objetivo:  Identifica o usuario que esta locando o registro
     Notas:  
-----------------------------------------------------------------------------*/

    DEF VAR aux_loginusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmusuari AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdevice AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtconnec AS CHAR                                    NO-UNDO.
    DEF VAR aux_numipusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_mslocktb AS CHAR                                    NO-UNDO.

    ASSIGN aux_mslocktb = "Registro sendo alterado em outro terminal " +
                          "(" + par_nmtabela + ").".

    IF  aux_idorigem = 3  THEN  /** InternetBank **/
        RETURN aux_mslocktb.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        RETURN aux_mslocktb.

    RUN acha-lock IN h-b1wgen9999 (INPUT par_cddrecid,
                                   INPUT "banco",
                                   INPUT par_nmtabela,
                                  OUTPUT aux_loginusr,
                                  OUTPUT aux_nmusuari,
                                  OUTPUT aux_dsdevice,
                                  OUTPUT aux_dtconnec, 
                                  OUTPUT aux_numipusr).

    DELETE OBJECT h-b1wgen9999.

    ASSIGN aux_mslocktb = aux_mslocktb + " Operador: " + 
                          aux_loginusr + " - " + aux_nmusuari.

    RETURN aux_mslocktb.   /* Function return value. */

END FUNCTION.

FUNCTION f_ver_contaitg RETURN INTEGER PRIVATE
    (INPUT par_nrdctitg AS CHAR):

    IF  par_nrdctitg = "" THEN
        RETURN 0.
    ELSE
        DO:
            IF  CAN-DO("1,2,3,4,5,6,7,8,9,0",
                       SUBSTR(par_nrdctitg,LENGTH(par_nrdctitg),1)) THEN
                RETURN INTE(STRING(par_nrdctitg,"99999999")).
            ELSE
                RETURN INTE(SUBSTR(STRING(par_nrdctitg,"99999999"),
                                   1,LENGTH(par_nrdctitg) - 1) + "0").
        END.
       
END.

