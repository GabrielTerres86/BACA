/* ............................................................................

   Programa: Fontes/crps603.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Junho/2011                        Ultima atualizacao: 18/04/2017

   Dados referentes ao programa:

   Frequencia: Diario
   Objetivo  : Informacoes COAF
               Solicitacao : 86
               Ordem do programa na solicitacao = 56.
               Relatorio 604.
                                      
   Alteracoes : 22/06/2011 - Melhorar log , executar fimprg.p (Gabriel).
   
                15/02/2013 - Tratamento nmrescop "x(20)" (Diego).
                
                10/06/2013 - Alteração função enviar_email_completo para
                            nova versão (Jean Michel).
                
                11/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)
                            
                03/01/2014 - Trocar critica 15 Agencia nao cadastrada por 
                             962 PA nao cadastrado (Reinert)
            
				18/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                 crapass, crapttl, crapjur 
							(Adriano - P339).
            
.............................................................................*/

{ includes/var_batch.i "NEW" } 
  
DEF STREAM str_1.

DEF VAR aux_contador AS INTE                                       NO-UNDO.
DEF VAR aux_flgconti AS LOGI INIT FALSE                            NO-UNDO.
DEF VAR aux_flgregis AS LOGI INIT FALSE                            NO-UNDO.
DEF VAR aux_nmarquiv AS CHAR                                       NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                       NO-UNDO.
DEF VAR aux_nmarqpdf AS CHAR                                       NO-UNDO.

/* variaveis para includes/cabrel132_1.i */
DEF VAR rel_nmresemp AS    CHAR   FORMAT "x(15)"                   NO-UNDO.
DEF VAR rel_nmrelato AS    CHAR   FORMAT "x(40)" EXTENT 5          NO-UNDO.
DEF VAR rel_nrmodulo AS    INTE   FORMAT     "9"                   NO-UNDO.
DEF VAR rel_nmempres AS    CHAR   FORMAT "x(15)"                   NO-UNDO.
DEF VAR rel_nmmodulo AS    CHAR   FORMAT "x(15)" EXTENT 5
                                  INIT ["","","","",""]            NO-UNDO.

DEF VAR h-b1wgen0011 AS HANDLE                                     NO-UNDO.
DEF VAR h-b1wgen0024 AS HANDLE                                     NO-UNDO.

DEF BUFFER crabfld FOR crapfld.


ASSIGN glb_cdprogra = "crps603".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0   THEN
     DO:
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" +
                            glb_dscritic + " >> log/proc_batch.log").
         glb_cdcritic = 0.
         QUIT.
     END.
           
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAIL crapcop   THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                            " - " + glb_cdprogra + "' --> '" +
                            glb_dscritic + " >> log/proc_batch.log").
         glb_cdcritic = 0.
         QUIT.
     END.

ASSIGN aux_nmarquiv = "crrl604"
    
       aux_nmarqimp = 
      "/usr/coop/" + crapcop.dsdircop + "/converte/" + aux_nmarquiv + ".lst"

       aux_nmarqpdf = 
      "/usr/coop/" + crapcop.dsdircop + "/converte/" + aux_nmarquiv + ".pdf"
    
       aux_nmarquiv = aux_nmarquiv + ".pdf".


OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 84.

{ includes/cabrel132_1.i }

VIEW STREAM str_1 FRAME f_cabrel132_1.

TRANSACAO:
DO TRANSACTION:

    FOR EACH crapfld WHERE crapfld.cdcooper = glb_cdcooper   AND
                           crapfld.cdtipcld = 1              AND 
                           crapfld.dtdenvcf = ?              NO-LOCK:
                                                        
        /* Atualiza data de envio */
        DO aux_contador = 1 TO 10:

            FIND crabfld WHERE crabfld.cdcooper = crapfld.cdcooper   AND
                               crabfld.dtmvtolt = crapfld.dtmvtolt   AND
                               crabfld.cdtipcld = crapfld.cdtipcld
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF   NOT AVAIL crabfld   THEN
                 DO:
                     IF   LOCKED crabfld   THEN
                          DO:
                              glb_cdcritic = 77.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                     ELSE
                          DO:
                              glb_cdcritic = 55.
                              LEAVE.
                          END.                                  
                 END.

            ASSIGN glb_cdcritic = 0                   
                   crabfld.dtdenvcf = glb_dtmvtolt.

            LEAVE.

        END. /* Tratamento de LOCK */

        IF   glb_cdcritic <> 0   THEN
             DO:
                 RUN fontes/critic.p.
                 UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                    " - " + glb_cdprogra + "' --> '" +
                                    glb_dscritic + " >> log/proc_batch.log").
                 glb_cdcritic = 0.  

                 UNDO, LEAVE TRANSACAO.
             END.

        /* Controle de movimentacao */
        FOR EACH crapcld WHERE crapcld.cdcooper = crapfld.cdcooper    AND 
                               crapcld.dtmvtolt = crapfld.dtmvtolt    AND
                               crapcld.cdtipcld = 1                   AND
                               crapcld.infrepcf = 1                   NO-LOCK:

            IF   NOT aux_flgregis    THEN
                 ASSIGN aux_flgregis = TRUE.

            RUN email-creditos.

            IF   RETURN-VALUE <> "OK"   THEN
                 UNDO, LEAVE TRANSACAO.

        END.
      
    END.  /* Fim FOR EACH crapfld */

    ASSIGN aux_flgconti = TRUE.

END. /* Fim TRANSACAO */

IF   NOT aux_flgregis   THEN
     DO:
         DISPLAY STREAM str_1 "* Nao foi registrada movimentacao neste dia." 
                        WITH FRAME f_sem_movimentacao.
     END.

OUTPUT STREAM str_1 CLOSE.

/* Se deu erro , aborta.  Aqui ele já gerou o log */
IF   NOT aux_flgconti   THEN
     QUIT. 

RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT SET h-b1wgen0024.

RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                        INPUT aux_nmarqpdf).

DELETE PROCEDURE h-b1wgen0024.

RUN sistema/generico/procedures/b1wgen0011.p PERSISTENT SET h-b1wgen0011.
                            
RUN enviar_email_completo IN h-b1wgen0011 (INPUT glb_cdcooper,
                                           INPUT glb_cdprogra, 
                                           INPUT crapcop.dsdemail,
                                           INPUT crapcop.dsemlcof,
                                           INPUT "Fechamento de creditos",
                                           INPUT "",
                                           INPUT aux_nmarquiv,
                                           INPUT "Fechamento de creditos",
                                           INPUT TRUE).
DELETE PROCEDURE h-b1wgen0011.

/* Colocar arquivo na INTRANET */
UNIX SILENT VALUE ("cp " + aux_nmarqimp + " /usr/coop/" + crapcop.dsdircop +
                   "/rl  2>/dev/null").

ASSIGN glb_nmarqimp = "rl/crrl604.lst"
       glb_nrcopias = 1
       glb_nmformul = "132col".

RUN fontes/imprim.p.

/* Remover o arquivo gerado (.lst do /converte)  */         
UNIX SILENT VALUE ("rm " + aux_nmarqimp + " 2>/dev/null"). 

RUN fontes/fimprg.p.


PROCEDURE email-creditos:

    DEF VAR aux_inpessoa        AS CHAR             NO-UNDO.
    DEF VAR aux_dsocpttl        AS CHAR             NO-UNDO.
    DEF VAR aux_nmextcop        AS CHAR             NO-UNDO.
    DEF VAR aux_cdagenci        AS CHAR             NO-UNDO.
    DEF VAR aux_nrcpfcgc        AS CHAR             NO-UNDO.
	DEF VAR aux_inpolexp        AS CHAR				NO-UNDO.

    DEF VAR aux_flgpubli        AS LOGI    FORMAT "Sim/Nao"  NO-UNDO.
    DEF VAR aux_dtaltera        AS DATE                      NO-UNDO.

   
    FORM SKIP(2)
         "          Data:" crapfld.dtmvtolt
         SKIP
         "   Cooperativa:" aux_nmextcop FORMAT "x(70)"
         SKIP
         "           PA :" aux_cdagenci FORMAT "x(50)"
         SKIP(1)
         "      Conta/DV:" crapcld.nrdconta 
         SKIP
         "Total Creditos:" crapcld.vltotcre 
         SKIP(1)
         "     Admis. Coop:" crapass.dtadmiss
         SKIP
         " Recadastramento:" aux_dtaltera
         SKIP(1)
         "Justificativa do PA:" crapcld.dsdjusti
         SKIP
         "  Informacao da Sede:" crapcld.dsobserv 
         SKIP(1)
         "Tit. Nome"
         "CPF/CNPJ          "                      AT 47
         "Politicamente exposta Servidor Publico"   
         SKIP
         "---- ---------------------------------------- ------------------"
         "--------------------- ----------------"
         WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_email.

    FORM crapttl.idseqttl   FORMAT "zzz9"
         crapttl.nmextttl   FORMAT "x(40)"
         aux_nrcpfcgc       FORMAT "x(18)"  AT 47
         aux_inpolexp                       AT 66
         aux_flgpubli                       AT 88
         WITH DOWN WIDTH 132  NO-BOX NO-LABELS FRAME f_titulares_fis.

    FORM crapjur.nmextttl   FORMAT "x(40)"  AT 6
         aux_nrcpfcgc       FORMAT "x(18)"  AT 47
         WITH WIDTH 132 NO-BOX NO-LABELS FRAME f_titulares_jur.   


    ASSIGN aux_dsocpttl = "169,319,67,309,308,271,65,306,272,273,74,305,69," + 
                          "316,209,311,303,64,310,314,313,315,307,76,75,77," +
                          "317,325,312,304".

    FIND crapass WHERE crapass.cdcooper = glb_cdcooper       AND
                       crapass.nrdconta = crapcld.nrdconta   NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass THEN
        DO:
            ASSIGN glb_cdcritic = 9.
            RUN fontes/critic.p.
            UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               glb_dscritic + " >> log/proc_batch.log").      
            ASSIGN glb_cdcritic = 0.

            RETURN "NOK".
        END.

    FIND crapage WHERE crapage.cdcooper = glb_cdcooper       AND 
                       crapage.cdagenci = crapcld.cdagenci   NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapage THEN
        DO:
            ASSIGN glb_cdcritic = 962.
            RUN fontes/critic.p.
            UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                               " - " + glb_cdprogra + "' --> '" +
                               glb_dscritic + " >> log/proc_batch.log").  
            ASSIGN glb_cdcritic = 0.

            RETURN "NOK".
        END.

    FIND LAST crapalt WHERE crapalt.cdcooper = glb_cdcooper     AND
                            crapalt.nrdconta = crapcld.cdagenci AND 
                            crapalt.tpaltera = 1                NO-LOCK NO-ERROR.

    IF   AVAIL crapalt THEN
         ASSIGN aux_dtaltera = crapalt.dtaltera.

    ASSIGN aux_nmextcop = crapcop.nmrescop + " - " + crapcop.nmextcop
           aux_cdagenci = STRING(crapage.cdagenci) + " - " +
                          crapage.nmresage + " (" + crapage.nmcidade + ")". 

    DISP STREAM str_1 crapfld.dtmvtolt  aux_nmextcop        aux_cdagenci
                      crapcld.nrdconta  crapcld.vltotcre    crapass.dtadmiss
                      aux_dtaltera      crapcld.dsdjusti    crapcld.dsobserv
                      WITH FRAME f_email.

    IF  crapass.inpessoa = 1 THEN
        DO:
            FOR EACH crapttl WHERE crapttl.cdcooper = glb_cdcooper     AND 
                                   crapttl.nrdconta = crapcld.nrdconta NO-LOCK:
                
                /* Verifica se é servidor publico */
                ASSIGN aux_flgpubli = 
                       CAN-DO(aux_dsocpttl,STRING(crapttl.cdocpttl))
                       aux_nrcpfcgc = STRING(STRING(crapttl.nrcpfcgc,
                                      "zzzzzzzzzzz"), "xxx.xxx.xxx-xx").

				IF crapttl.inpolexp = 0 THEN
				   ASSIGN aux_inpolexp = "Nao".
				ELSE IF crapttl.inpolexp = 1 THEN
				   ASSIGN aux_inpolexp = "Sim".
			    ELSE IF crapttl.inpolexp = 2 THEN
				   ASSIGN aux_inpolexp = "Pendente".

                DISP STREAM str_1 crapttl.idseqttl  crapttl.nmextttl 
                                  aux_nrcpfcgc      aux_inpolexp
                                  aux_flgpubli
                                  WITH FRAME f_titulares_fis.

                DOWN STREAM str_1 WITH FRAME f_titulares_fis.

            END. /* FIM FOR EACH crapttl */
        END.
    ELSE
        DO:
            FIND crapjur WHERE crapjur.cdcooper = glb_cdcooper   AND 
                               crapjur.nrdconta = crapcld.nrdconta  
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapjur THEN
                DO:
                    ASSIGN glb_cdcritic = 821.
                    RUN fontes/critic.p.
                    UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " >> log/proc_batch.log").             
                    ASSIGN glb_cdcritic = 0.
                    
                    RETURN "NOK".
                END.

            ASSIGN aux_nrcpfcgc = STRING(STRING(crapass.nrcpfcgc,
                                "zzzzzzzzzzzzzz"),"xx.xxx.xxx/xxxx-xx").

            DISP STREAM str_1 crapjur.nmextttl  aux_nrcpfcgc
                              WITH FRAME f_titulares_jur.
        END.

    RETURN "OK".

END PROCEDURE. /* FIM email-creditos */

/* ......................................................................... */


