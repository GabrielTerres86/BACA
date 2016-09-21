/*.............................................................................

    Programa: sistema/generico/procedures/b1wgen0182.p
    Data    : Setembro/2013
    Autor   : Renersson Ricardo Agostini (GATI)      Ultima atualizacao: 24/03/2014
  
    Dados referentes ao programa:
  
    Objetivo  : BO com rotina de controle para as administradoras de cartão
                de crédito (tela ADMCRD).
                
  
    Alteracoes: 25/02/2014 - Reformulação e Correção da BO182 (Lucas).
    
                06/03/2014 - Incluso VALIDATE (Daniel).
                
                24/03/2014 - Novos campos Projeto cartão Bancoob (Jean Michel).
    
.............................................................................*/

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgen0182tt.i }

DEFINE VARIABLE aux_cdcritic AS INTE                            NO-UNDO.
DEFINE VARIABLE aux_dscritic AS CHAR                            NO-UNDO.
DEFINE VARIABLE aux_contador AS INTE                            NO-UNDO.
                                                               
PROCEDURE altera-adm-cartoes:   
                                                               
    DEFINE INPUT  PARAMETER par_cdcooper AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHAR                NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdadmcrd AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmadmcrd LIKE crapadc.nmadmcrd  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmresadm LIKE crapadc.nmresadm  NO-UNDO.
    DEFINE INPUT  PARAMETER par_insitadc AS LOGICAL             NO-UNDO.
    DEFINE INPUT  PARAMETER par_qtcarnom LIKE crapadc.qtcarnom  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmbandei LIKE crapadc.nmbandei  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctacor LIKE crapadc.nrctacor  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdigcta LIKE crapadc.nrdigcta  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrrazcta LIKE crapadc.nrrazcta  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmagecta LIKE crapadc.nmagecta  NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagecta LIKE crapadc.cdagecta  NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddigage LIKE crapadc.cddigage  NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsendere LIKE crapadc.dsendere  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmbairro LIKE crapadc.nmbairro  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmcidade LIKE crapadc.nmcidade  NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdufende LIKE crapadc.cdufende  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcepend LIKE crapadc.nrcepend  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmpescto LIKE crapadc.nmpescto  NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpctahab LIKE crapadc.tpctahab  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctamae LIKE crapadc.nrctamae  NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdclasse LIKE crapadc.cdclasse  NO-UNDO.
    DEFINE INPUT  PARAMETER par_inanuida LIKE crapadc.inanuida  NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsemail1 LIKE crapadc.dsdemail  NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsemail2 LIKE crapadc.dsdemail  NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsemail3 LIKE crapadc.dsdemail  NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsemail4 LIKE crapadc.dsdemail  NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsemail5 LIKE crapadc.dsdemail  NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGI                NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgcchip AS INTE                NO-UNDO.
    
    DEFINE OUTPUT PARAMETER par_nmdcampo AS CHAR                NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEF   VAR   aux_qtregist             AS INTE                NO-UNDO.
    DEF   VAR   aux_insitadc             AS INTE                NO-UNDO.
    DEF   VAR   log_insitadc             AS LOGI                NO-UNDO.
    DEF   VAR   log_dsdemail             LIKE crapadc.dsdemail  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapadc.

    IF  par_flgerlog THEN
        DO:
            RUN consulta-administradora (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT 0  /* nrdcaixa */,
                                         INPUT par_cdoperad,
                                         INPUT par_dtmvtolt,
                                         INPUT "A",
                                         INPUT par_cdadmcrd,
                                         INPUT "" /* nmadmcrd */,
                                         INPUT 999,
                                         INPUT 0,
                                         OUTPUT aux_qtregist,
                                         OUTPUT TABLE tt-crapadc,
                                         OUTPUT TABLE tt-erro).
        
            IF  RETURN-VALUE <> "OK"   THEN
                RETURN "NOK".
        END.

    Grava: DO TRANSACTION
           ON ERROR  UNDO Grava, LEAVE Grava
           ON QUIT   UNDO Grava, LEAVE Grava
           ON STOP   UNDO Grava, LEAVE Grava
           ON ENDKEY UNDO Grava, LEAVE Grava:
            
            DO  aux_contador = 1 TO 10:
                
                FIND crapadc WHERE crapadc.cdcooper = par_cdcooper AND 
                                   crapadc.cdadmcrd = par_cdadmcrd 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE crapadc   THEN
                    IF  LOCKED crapadc   THEN
                        DO:
                            aux_cdcritic = 77.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            aux_cdcritic = 55.
                            LEAVE.
                        END.    
                LEAVE.

            END.  /*  Fim do DO .. TO  */
        
            IF  aux_cdcritic > 0  THEN
                DO:
                    ASSIGN aux_dscritic = "".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
        
                    RETURN "NOK".
                END.

            IF par_insitadc THEN
                ASSIGN aux_insitadc = 0.
            ELSE
                ASSIGN aux_insitadc = 1.

            ASSIGN crapadc.nmadmcrd = par_nmadmcrd
                   crapadc.nmresadm = par_nmresadm
                   crapadc.insitadc = aux_insitadc
                   crapadc.qtcarnom = par_qtcarnom
                   crapadc.nmbandei = par_nmbandei
                   crapadc.nrctacor = par_nrctacor
                   crapadc.nrdigcta = par_nrdigcta
                   crapadc.nrrazcta = par_nrrazcta
                   crapadc.nmagecta = par_nmagecta
                   crapadc.cdagecta = par_cdagecta
                   crapadc.cddigage = par_cddigage
                   crapadc.dsendere = par_dsendere
                   crapadc.nmbairro = par_nmbairro
                   crapadc.nmcidade = par_nmcidade
                   crapadc.cdufende = CAPS(par_cdufende)
                   crapadc.nrcepend = par_nrcepend
                   crapadc.nmpescto = par_nmpescto
                   crapadc.tpctahab = par_tpctahab
                   crapadc.nrctamae = par_nrctamae
                   crapadc.cdclasse = par_cdclasse 
                   crapadc.flgcchip = IF par_flgcchip = 0 THEN FALSE ELSE TRUE

                   crapadc.inanuida = par_inanuida
                   crapadc.dsdemail = par_dsemail1 + "," +
                                      par_dsemail2 + "," + 
                                      par_dsemail3 + "," + 
                                      par_dsemail4 + "," + 
                                      par_dsemail5
                       log_dsdemail = crapadc.dsdemail.
    END.
/*
    IF  par_flgerlog THEN
        DO:        
            FIND FIRST tt-crapadc WHERE tt-crapadc.cdadmcrd = par_cdadmcrd
                                                          NO-LOCK NO-ERROR.

            IF  par_nmadmcrd <> tt-crapadc.nmadmcrd  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "            +
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "           +
                                  par_cdoperad + " '-->' Alterou o Nome da Administradora "    +
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "    +
                                  tt-crapadc.nmadmcrd + " para " + par_nmadmcrd + "."          +
                                  " >> log/admcrd.log").

            IF  par_nmresadm <> tt-crapadc.nmresadm  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "                   +  
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "                  +  
                                  par_cdoperad + " '-->' Alterou o Nome Resumido da Administradora "  +  
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "           +  
                                  tt-crapadc.nmresadm + " para " + par_nmresadm + "."                 +  
                                  " >> log/admcrd.log").

            IF  aux_insitadc <> tt-crapadc.insitadc  THEN
                DO:
                    IF  tt-crapadc.insitadc = 0 THEN
                        ASSIGN log_insitadc = TRUE.
                    ELSE
                        ASSIGN log_insitadc = FALSE.

                    UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "             +   
                                      STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "            +   
                                      par_cdoperad + " '-->' Alterou a Situacao da Administradora " +   
                                      STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "     +   
                                      STRING(log_insitadc,"ATIVADA/DESATIVADA") + " para "          + 
                                      STRING(par_insitadc,"ATIVADA/DESATIVADA") + "."               +
                                      " >> log/admcrd.log").

                END.

            IF  par_nmbandei <> tt-crapadc.nmbandei  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "             +   
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "            +   
                                  par_cdoperad + " '-->' Alterou a Bandeira da Administradora " +   
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "     +   
                                  tt-crapadc.nmbandei + " para " + par_nmbandei + "."           +   
                                  " >> log/admcrd.log").                                        

            IF  par_qtcarnom <> tt-crapadc.qtcarnom  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "                      +  
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "                     +  
                                  par_cdoperad + " '-->' Alterou a Qtd. Caract. Nome da Administradora " +  
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "              +  
                                  STRING(tt-crapadc.qtcarnom) + " para " + STRING(par_qtcarnom) + "."    +  
                                  " >> log/admcrd.log"). 

            IF  par_flghabcj <> tt-crapadc.flghabcj  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "                      +
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "                     +  
                                  par_cdoperad + " '-->' Alterou a Habilitacao de PJ da Administradora " +  
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "              +  
                                  STRING(tt-crapadc.flghabcj,"Sim/Nao") + " para "                       + 
                                  STRING(par_flghabcj,"Sim/Nao") + "."                                   +  
                                  " >> log/admcrd.log"). 

            IF  par_inanuida <> tt-crapadc.inanuida  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "                   + 
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "                  + 
                                  par_cdoperad + " '-->' Alterou a Anuidade da Administradora "       +   
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "           + 
                                  STRING(tt-crapadc.inanuida) + " para " + STRING(par_inanuida) + "." + 
                                  " >> log/admcrd.log"). 

            IF  par_nrctacor <> tt-crapadc.nrctacor  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "                   +
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "                  +
                                  par_cdoperad + " '-->' Alterou a Conta Corrente da Administradora " +   
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "           + 
                                  STRING(tt-crapadc.nrctacor) + " para " + STRING(par_nrctacor) + "." + 
                                  " >> log/admcrd.log"). 

            IF  par_nrdigcta <> tt-crapadc.nrdigcta  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "                           +
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "                          +
                                  par_cdoperad + " '-->' Alterou o Dig. da Conta Corrente da Administradora " +   
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "                   + 
                                  STRING(tt-crapadc.nrdigcta) + " para " + STRING(par_nrdigcta) + "."         + 
                                  " >> log/admcrd.log"). 

            IF  par_nrrazcta <> tt-crapadc.nrrazcta  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "                   +  
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "                  +  
                                  par_cdoperad + " '-->' Alterou a Razao C/C da Administradora "      +   
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "           +  
                                  STRING(tt-crapadc.nrrazcta) + " para " + STRING(par_nrrazcta) + "." + 
                                  " >> log/admcrd.log"). 

            IF  par_nmagecta <> tt-crapadc.nmagecta  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "                   +  
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "                  +  
                                  par_cdoperad + " '-->' Alterou a Agencia da Administradora "        +   
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "           +  
                                  STRING(tt-crapadc.nmagecta) + " para " + STRING(par_nmagecta) + "." + 
                                  " >> log/admcrd.log"). 

            IF  par_cdagecta <> tt-crapadc.cdagecta  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "                   +  
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "                  +  
                                  par_cdoperad + " '-->' Alterou a Cta.Agencia da Administradora "    +   
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "           +  
                                  STRING(tt-crapadc.cdagecta) + " para " + STRING(par_cdagecta) + "." + 
                                  " >> log/admcrd.log").

            IF  par_cddigage <> tt-crapadc.cddigage  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "                           +
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "                          +
                                  par_cdoperad + " '-->' Alterou o Dig. da Cta.Agencia da Administradora "    +   
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "                   + 
                                  STRING(tt-crapadc.cddigage) + " para " + STRING(par_cddigage) + "."         + 
                                  " >> log/admcrd.log"). 

            IF  par_dsendere <> tt-crapadc.dsendere  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "             +   
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "            +   
                                  par_cdoperad + " '-->' Alterou o Endereco da Administradora " +   
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "     +   
                                  tt-crapadc.dsendere + " para " + par_dsendere + "."           +   
                                  " >> log/admcrd.log").

            IF  par_nmbairro <> tt-crapadc.nmbairro  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "           +   
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "          +   
                                  par_cdoperad + " '-->' Alterou o Bairro da Administradora " +   
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "   +   
                                  tt-crapadc.nmbairro + " para " + par_nmbairro + "."         +   
                                  " >> log/admcrd.log").

            IF  par_nmcidade <> tt-crapadc.nmcidade  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "           +   
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "          +   
                                  par_cdoperad + " '-->' Alterou a Cidade da Administradora " +   
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "   +   
                                  tt-crapadc.nmcidade + " para " + par_nmcidade + "."         +   
                                  " >> log/admcrd.log").

            IF  par_cdufende <> tt-crapadc.cdufende  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "         +   
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "        +   
                                  par_cdoperad + " '-->' Alterou a UF da Administradora "   +   
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de " +   
                                  tt-crapadc.cdufende + " para " + par_cdufende + "."       +   
                                  " >> log/admcrd.log").

            IF  par_nrcepend <> tt-crapadc.nrcepend  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "                   +  
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "                  +  
                                  par_cdoperad + " '-->' Alterou o CEP da Administradora "            +   
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "           +  
                                  STRING(tt-crapadc.nrcepend) + " para " + STRING(par_nrcepend) + "." + 
                                  " >> log/admcrd.log").

            IF  par_nmpescto <> tt-crapadc.nmpescto  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "                      +   
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "                     +   
                                  par_cdoperad + " '-->' Alterou a Pessoa de Contato da Administradora " +   
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "              +   
                                  tt-crapadc.nmpescto + " para " + par_nmpescto + "."                    +   
                                  " >> log/admcrd.log").

            IF  log_dsdemail <> tt-crapadc.dsdemail  THEN
                UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "                       +   
                                  STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "                      +   
                                  par_cdoperad + " '-->' Alterou os E-mail de Contato da Administradora " +   
                                  STRING(par_cdadmcrd) + " " + tt-crapadc.nmadmcrd + " de "               +   
                                  tt-crapadc.dsdemail + " para " + log_dsdemail + "."                     +   
                                  " >> log/admcrd.log").
        END.
  */
    RELEASE crapcsg NO-ERROR.

    RETURN "OK".

END PROCEDURE.

PROCEDURE exclui-adm-cartoes:
                                                                
    DEFINE INPUT  PARAMETER par_cdcooper AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHAR                NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdadmcrd AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGI                NO-UNDO.
                                                                
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEF   VAR   aux_qtregist             AS INTE                NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    IF  par_flgerlog THEN
        DO:
            RUN consulta-administradora (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT 0  /* nrdcaixa */,
                                         INPUT par_cdoperad,
                                         INPUT par_dtmvtolt,
                                         INPUT "E",
                                         INPUT par_cdadmcrd,
                                         INPUT "" /* nmadmcrd */,
                                         INPUT 999,
                                         INPUT 0,
                                         OUTPUT aux_qtregist,
                                         OUTPUT TABLE tt-crapadc,
                                         OUTPUT TABLE tt-erro).
        
            IF  RETURN-VALUE <> "OK"   THEN
                RETURN "NOK".
        END.            

    Elimina: DO TRANSACTION
             ON ERROR  UNDO Elimina, LEAVE Elimina
             ON QUIT   UNDO Elimina, LEAVE Elimina
             ON STOP   UNDO Elimina, LEAVE Elimina
             ON ENDKEY UNDO Elimina, LEAVE Elimina:
            
            DO  aux_contador = 1 TO 10:
                
                FIND crapadc WHERE crapadc.cdcooper = par_cdcooper AND 
                                   crapadc.cdadmcrd = par_cdadmcrd 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE crapadc   THEN
                    IF  LOCKED crapadc   THEN
                        DO:
                            aux_cdcritic = 77.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            aux_cdcritic = 55.
                            LEAVE.
                        END.    
                LEAVE.

            END.  /*  Fim do DO .. TO  */
        
            IF  aux_cdcritic > 0  THEN
                DO:
                    ASSIGN aux_dscritic = "".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
        
                    RETURN "NOK".
                END. 

            DELETE crapadc.
    END.

    
    FIND FIRST tt-crapadc WHERE tt-crapadc.cdadmcrd = par_cdadmcrd
                                                  NO-LOCK NO-ERROR.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.

    UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "              +
                      STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "             +
                      par_cdoperad + " '-->' Eliminou a Administradora de Cartões "  +
                      STRING(par_cdadmcrd) + " " + CAPS(tt-crapadc.nmadmcrd) + "."   +
                      " >> /usr/coop/" + TRIM(crapcop.dsdircop) + "/log/admcrd.log").
    

    RETURN "OK".

END PROCEDURE.

PROCEDURE inclui-adm-cartoes:

    DEFINE INPUT PARAMETER par_cdcooper AS INTE                 NO-UNDO.
    DEFINE INPUT PARAMETER par_cdagenci AS INTE                 NO-UNDO.
    DEFINE INPUT PARAMETER par_nrdcaixa AS INTE                 NO-UNDO.
    DEFINE INPUT PARAMETER par_cdoperad AS CHAR                 NO-UNDO.
    DEFINE INPUT PARAMETER par_dtmvtolt AS DATE                 NO-UNDO.
    DEFINE INPUT PARAMETER par_cdadmcrd AS INTE                 NO-UNDO.
    DEFINE INPUT PARAMETER par_nmadmcrd LIKE crapadc.nmadmcrd   NO-UNDO.
    DEFINE INPUT PARAMETER par_nmresadm LIKE crapadc.nmresadm   NO-UNDO.
    DEFINE INPUT PARAMETER par_insitadc AS LOGICAL              NO-UNDO.
    DEFINE INPUT PARAMETER par_qtcarnom LIKE crapadc.qtcarnom   NO-UNDO.
    DEFINE INPUT PARAMETER par_nmbandei LIKE crapadc.nmbandei   NO-UNDO.
    DEFINE INPUT PARAMETER par_nrctacor LIKE crapadc.nrctacor   NO-UNDO.
    DEFINE INPUT PARAMETER par_nrdigcta LIKE crapadc.nrdigcta   NO-UNDO.
    DEFINE INPUT PARAMETER par_nrrazcta LIKE crapadc.nrrazcta   NO-UNDO.
    DEFINE INPUT PARAMETER par_nmagecta LIKE crapadc.nmagecta   NO-UNDO.
    DEFINE INPUT PARAMETER par_cdagecta LIKE crapadc.cdagecta   NO-UNDO.
    DEFINE INPUT PARAMETER par_cddigage LIKE crapadc.cddigage   NO-UNDO.
    DEFINE INPUT PARAMETER par_dsendere LIKE crapadc.dsendere   NO-UNDO.
    DEFINE INPUT PARAMETER par_nmbairro LIKE crapadc.nmbairro   NO-UNDO.
    DEFINE INPUT PARAMETER par_nmcidade LIKE crapadc.nmcidade   NO-UNDO.
    DEFINE INPUT PARAMETER par_cdufende LIKE crapadc.cdufende   NO-UNDO.
    DEFINE INPUT PARAMETER par_nrcepend LIKE crapadc.nrcepend   NO-UNDO.
    DEFINE INPUT PARAMETER par_nmpescto LIKE crapadc.nmpescto   NO-UNDO.
    DEFINE INPUT PARAMETER par_dsemail1 LIKE crapadc.dsdemail   NO-UNDO.
    DEFINE INPUT PARAMETER par_dsemail2 LIKE crapadc.dsdemail   NO-UNDO.
    DEFINE INPUT PARAMETER par_dsemail3 LIKE crapadc.dsdemail   NO-UNDO.
    DEFINE INPUT PARAMETER par_dsemail4 LIKE crapadc.dsdemail   NO-UNDO.
    DEFINE INPUT PARAMETER par_dsemail5 LIKE crapadc.dsdemail   NO-UNDO.
    DEFINE INPUT PARAMETER par_tpctahab LIKE crapadc.tpctahab   NO-UNDO.
    DEFINE INPUT PARAMETER par_nrctamae LIKE crapadc.nrctamae   NO-UNDO.
    DEFINE INPUT PARAMETER par_cdclasse LIKE crapadc.cdclasse   NO-UNDO.
    DEFINE INPUT PARAMETER par_inanuida LIKE crapadc.inanuida   NO-UNDO.
    DEFINE INPUT PARAMETER par_flgerlog AS LOGI                 NO-UNDO.
    DEFINE INPUT PARAMETER par_flgcchip AS INTE                 NO-UNDO.

    DEFINE OUTPUT PARAMETER par_nmdcampo AS CHAR                NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.                  
    
    Inclui: DO TRANSACTION                                      
            ON ERROR  UNDO Inclui, LEAVE Inclui                 
            ON QUIT   UNDO Inclui, LEAVE Inclui                 
            ON STOP   UNDO Inclui, LEAVE Inclui                 
            ON ENDKEY UNDO Inclui, LEAVE Inclui:                

            DO  aux_contador = 1 TO 10:
                
                FIND crapadc WHERE crapadc.cdcooper = par_cdcooper AND 
                                   crapadc.cdadmcrd = par_cdadmcrd 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAILABLE crapadc   THEN
                    DO:
                        IF  LOCKED crapadc   THEN
                            DO:
                                aux_cdcritic = 77.
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                    END.
                ELSE
                    DO:
                        aux_cdcritic = 790.
                        LEAVE.
                    END.

                LEAVE.

            END.  /*  Fim do DO .. TO  */
        
            IF  aux_cdcritic > 0  THEN
                DO:
                    ASSIGN aux_dscritic = "".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
        
                    RETURN "NOK".
                END. 
                
        CREATE crapadc.
        ASSIGN crapadc.cdcooper = par_cdcooper
               crapadc.cdadmcrd = par_cdadmcrd
               crapadc.nmadmcrd = par_nmadmcrd           
               crapadc.nmresadm = par_nmresadm
               crapadc.insitadc = IF par_insitadc THEN 0 ELSE 1
               crapadc.qtcarnom = par_qtcarnom 
               crapadc.nmbandei = par_nmbandei 
               crapadc.nrctacor = par_nrctacor 
               crapadc.nrdigcta = par_nrdigcta 
               crapadc.nrrazcta = par_nrrazcta 
               crapadc.nmagecta = par_nmagecta  
               crapadc.cdagecta = par_cdagecta 
               crapadc.cddigage = par_cddigage 
               crapadc.dsendere = par_dsendere 
               crapadc.nmbairro = par_nmbairro 
               crapadc.nmcidade = par_nmcidade   
               crapadc.cdufende = CAPS(par_cdufende)
               crapadc.nrcepend = par_nrcepend 
               crapadc.nmpescto = par_nmpescto 
               crapadc.dsdemail = par_dsemail1 + "," +
                                  par_dsemail2 + "," + 
                                  par_dsemail3 + "," + 
                                  par_dsemail4 + "," + 
                                  par_dsemail5
               crapadc.tpctahab = par_tpctahab
               crapadc.nrctamae = par_nrctamae
               crapadc.cdclasse = par_cdclasse
               crapadc.inanuida = par_inanuida
               crapadc.flgcchip = IF par_flgcchip = 0 THEN FALSE ELSE TRUE.

        VALIDATE crapadc.

    END.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR NO-WAIT.

    UNIX SILENT VALUE("echo " + STRING(par_dtmvtolt,"99/99/9999") + " "           +
                      STRING(TIME,"HH:MM:SS") + "' -->' " + " Operador "          +
                      par_cdoperad + " '-->' Criou a Administradora de Cartões "  +
                      STRING(par_cdadmcrd) + " " + CAPS(par_nmadmcrd) + "."       +
                      " >> /usr/coop/" + TRIM(crapcop.dsdircop) + "/log/admcrd.log").
    

    RETURN "OK".

END PROCEDURE.

PROCEDURE consulta-administradora:
                                                                
    DEFINE INPUT  PARAMETER par_cdcooper AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHAR                NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddopcao AS CHAR                NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdadmcrd AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmadmcrd AS CHAR                NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrregist AS INTE                NO-UNDO.
    DEFINE INPUT  PARAMETER par_nriniseq AS INTE                NO-UNDO.
    DEFINE OUTPUT PARAMETER par_qtregist AS INTE                NO-UNDO.
                                                                
    DEFINE OUTPUT PARAMETER TABLE FOR tt-crapadc.               
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.                  
                                                                
    DEFINE VARIABLE aux_nrregist AS INTE                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapadc.

    ASSIGN aux_nrregist = par_nrregist.

    IF  par_cddopcao <> "" AND
        par_cdadmcrd = 0   THEN
        DO:
            ASSIGN aux_dscritic = "Administradora nao informada.".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdadmcrd,
                           INPUT par_nrdcaixa,
                           INPUT 0, /* nrsequen */
                           INPUT 0, /* cdcritic */
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FOR EACH crapadc WHERE crapadc.cdcooper  = par_cdcooper
                       AND crapadc.cdadmcrd >= par_cdadmcrd 
                       AND crapadc.nmadmcrd MATCHES('*' + par_nmadmcrd + '*')
                       NO-LOCK:

        ASSIGN par_qtregist = par_qtregist + 1.
    
        /* controles da paginacao */
        IF  (par_qtregist < par_nriniseq) OR
            (par_qtregist > (par_nriniseq + par_nrregist)) THEN
            NEXT.
    
        IF  aux_nrregist > 0 THEN
            DO:
                CREATE tt-crapadc.
                BUFFER-COPY crapadc TO tt-crapadc.

            END.
    
        ASSIGN aux_nrregist = aux_nrregist - 1.
        
    END.

    IF  NOT TEMP-TABLE tt-crapadc:HAS-RECORDS AND
        par_cddopcao = ""                     THEN
        DO:
            ASSIGN aux_dscritic = "Administradoras nao encontradas.".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdadmcrd,
                           INPUT par_nrdcaixa,
                           INPUT 0, /* nrsequen */
                           INPUT 0, /* cdcritic */
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    IF  par_cddopcao <> "" THEN
        DO:
            FIND FIRST tt-crapadc WHERE tt-crapadc.cdadmcrd = par_cdadmcrd
                                                          NO-LOCK NO-ERROR.
            IF  NOT AVAIL tt-crapadc  THEN
                DO:
                    IF  par_cddopcao <> "I"   THEN
                        DO:
                            ASSIGN aux_dscritic = "Administradora nao cadastrada.".
        
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdadmcrd,
                                           INPUT par_nrdcaixa,
                                           INPUT 0, /* nrsequen */
                                           INPUT 0, /* cdcritic */
                                           INPUT-OUTPUT aux_dscritic).
                            RETURN "NOK".
                        END.
                END.
            ELSE
                IF  par_cddopcao = "I" THEN
                    DO:
                        ASSIGN aux_cdcritic = 790.

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdadmcrd,
                                       INPUT par_nrdcaixa,
                                       INPUT 0, /* nrsequen */
                                       INPUT aux_cdcritic, /* cdcritic */
                                       INPUT-OUTPUT aux_dscritic).
                        RETURN "NOK".
                    END.
        END.

    RETURN "OK".

END PROCEDURE.
