/* .............................................................................

   Programa: Fontes/rdcapp_x.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/96.                           Ultima atualizacao: 21/06/2011

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento da cancelamento da poupanca programada.

   Alteracoes: 03/04/98 - Tratamento para milenio e troca para V8 (Margarete).

               16/11/00 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               16/09/2004 - Alterado alinhamento dos campos e incluida exibicao
                            dos campos CI e Resgate (Evandro).

               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando 
               
               22/04/2008 - Vencimento poupanca programada (Guilherme).
               
               28/04/2010 - Passar para um browse dinamico.
                            Utilizar a BO 6 de poupança  (Gabriel).
                        
               21/06/2011 - Alterada flag de log de FALSE  p/ TRUE
                            em BO b1wgen0006 (Jorge).
............................................................................. */

DEF INPUT PARAM par_nrctrrpp AS INTE                    NO-UNDO.
                      
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_rdcapp.i }

{ sistema/generico/includes/var_internet.i }


DEF VAR aux_confirma AS CHAR FORMAT "!(1)"              NO-UNDO.
DEF VAR aux_vlsdrpp  AS DECI                            NO-UNDO.
DEF VAR aux_flgftlog AS LOGICAL INIT TRUE               NO-UNDO.

DEF VAR h-b1wgen0006 AS HANDLE                          NO-UNDO.


DO WHILE TRUE:
    
   RUN sistema/generico/procedures/b1wgen0006.p
                         PERSISTENT SET h-b1wgen0006.

   RUN consulta-poupanca IN h-b1wgen0006
                         (INPUT glb_cdcooper,
                          INPUT 0,
                          INPUT 0,
                          INPUT glb_cdoperad,
                          INPUT glb_nmdatela,
                          INPUT 1, /* Origem*/
                          INPUT tel_nrdconta,
                          INPUT 1, /* Titular */
                          INPUT par_nrctrrpp,
                          INPUT glb_dtmvtolt,
                          INPUT glb_dtmvtopr,
                          INPUT glb_inproces,
                          INPUT glb_cdprogra,
                          INPUT FALSE,
                          OUTPUT aux_vlsdrpp,
                          OUTPUT TABLE tt-erro,
                          OUTPUT TABLE tt-dados-rpp).

   DELETE PROCEDURE h-b1wgen0006.

   /* Dados da Poupança */
   FIND FIRST tt-dados-rpp NO-LOCK NO-ERROR.

   IF   NOT AVAIL tt-dados-rpp  THEN
        LEAVE.

   ASSIGN tel_dsaplica = " Poupanca Programada " +
                      TRIM(STRING(par_nrctrrpp,"z,zzz,zz9")) +
                         "-Dia " + STRING(DAY(tt-dados-rpp.dtdebito),"99") + " "

          tel_dspesrpp = STRING(tt-dados-rpp.dtmvtolt,"99/99/9999") + "-" +
                         STRING(tt-dados-rpp.cdagenci,"999") + "-" +
                         STRING(tt-dados-rpp.cdbccxlt,"999") + "-" +
                         STRING(tt-dados-rpp.nrdolote,"999999")

          tel_vlprerpp = tt-dados-rpp.vlprerpp
          tel_qtprerpp = tt-dados-rpp.qtprepag
          tel_vlprepag = tt-dados-rpp.vlprepag
          tel_vljuracu = tt-dados-rpp.vljuracu
          tel_vlrgtacu = tt-dados-rpp.vlrgtacu
          tel_vlsdrdpp = tt-dados-rpp.vlsdrdpp
          tel_dtinirpp = tt-dados-rpp.dtinirpp
          tel_dtrnirpp = tt-dados-rpp.dtrnirpp
          tel_dtaltrpp = tt-dados-rpp.dtaltrpp
          tel_dtdebito = tt-dados-rpp.dtdebito
          tel_dtcancel = tt-dados-rpp.dtcancel
          tel_dtvctopp = tt-dados-rpp.dtvctopp
          tel_dssitrpp = tt-dados-rpp.dssitrpp. 

      
   DISPLAY tel_vlprerpp tel_qtprerpp tel_vlprepag tel_vljuracu
           tel_vlrgtacu tel_vlsdrdpp tel_dtinirpp tel_dtrnirpp
           tel_dtaltrpp tel_dtdebito tel_dtcancel tel_dspesrpp
           tel_dssitrpp tel_dtvctopp
           WITH FRAME f_rdcapp.
   
   /* Confirmaçao dos dados */
   RUN fontes/confirma.p (INPUT "",
                          OUTPUT aux_confirma).

   IF   aux_confirma <> "S" THEN
        LEAVE.

   RUN sistema/generico/procedures/b1wgen0006.p
                        PERSISTENT SET h-b1wgen0006.

   RUN cancelar-poupanca IN h-b1wgen0006 (INPUT glb_cdcooper,
                                          INPUT 0,
                                          INPUT 0,
                                          INPUT glb_cdoperad,
                                          INPUT glb_nmdatela,
                                          INPUT 1, /* Origem */
                                          INPUT tel_nrdconta,
                                          INPUT 1, /* Titular */
                                          INPUT par_nrctrrpp,
                                          INPUT glb_dtmvtolt,
                                          INPUT TRUE,
                                          OUTPUT TABLE tt-erro).
   DELETE PROCEDURE h-b1wgen0006.

   IF   RETURN-VALUE <> "OK"   THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF   AVAIL tt-erro   THEN
                 MESSAGE tt-erro.dscritic.

            LEAVE.

        END.
          
   LEAVE.

END.  /*  Fim do DO WHILE TRUE */


HIDE FRAME f_rdcapp NO-PAUSE.


/* .......................................................................... */
