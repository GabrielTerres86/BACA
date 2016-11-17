/* .............................................................................

   Programa: Fontes/segvida_a.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah       
   Data    : Agosto/1999                         Ultima atualizacao: 27/02/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento da alteracao da proposta de seguro de 
               vida em grupo.
               
   Alteracoes: 10/11/1999 - Seguro de vida para conjuge (Deborah).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 
               
               31/03/2010 - Adaptaçao para browse dinamico (Gabriel).
               
               06/09/2011 - Implementada chamada da procedure 
                            atualizar_seguro_vida da b1wgen0033
                            (Gati - Oliver)
                            
               27/02/2013 - Incluir  INPUT "A" em chamada do fonte segvida_m
                            (Lucas R.)
............................................................................. */

DEF INPUT PARAM par_tpseguro AS INT                                  NO-UNDO.
DEF INPUT PARAM par_nrctrseg AS INT                                  NO-UNDO.

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_seguro.i }
{ sistema/generico/includes/var_internet.i }

DEF VAR r-recidseg      AS  RECID                                   NO-UNDO.
DEF BUFFER b-tt-seguros FOR tt-seguros.

DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

   RUN sistema/generico/procedures/b1wgen0033.p 
       PERSISTENT SET h-b1wgen0033.

   RUN busca_seguros IN h-b1wgen0033(INPUT glb_cdcooper,
                                     INPUT 0,
                                     INPUT 0,
                                     INPUT glb_cdoperad,
                                     INPUT glb_dtmvtolt,
                                     INPUT tel_nrdconta,
                                     INPUT 1,
                                     INPUT 1,
                                     INPUT glb_nmdatela,
                                     INPUT FALSE,
                                     OUTPUT TABLE tt-seguros,
                                     OUTPUT aux_qtsegass,
                                     OUTPUT aux_vltotseg,
                                     OUTPUT TABLE tt-erro).

   RUN buscar_proposta_seguro IN h-b1wgen0033(INPUT glb_cdcooper,
                                              INPUT 0,
                                              INPUT 0,
                                              INPUT glb_cdoperad,
                                              INPUT glb_dtmvtolt,
                                              INPUT tel_nrdconta,
                                              INPUT 1,
                                              INPUT 1,
                                              INPUT glb_nmdatela,
                                              INPUT FALSE,
                                              OUTPUT TABLE tt-prop-seguros,
                                              OUTPUT aux_qtsegass,
                                              OUTPUT aux_vltotseg,
                                              OUTPUT TABLE tt-erro).

   DELETE PROCEDURE h-b1wgen0033.

   IF   RETURN-VALUE <> "OK"  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.
           IF   AVAIL tt-erro   THEN
               DO:
                   ASSIGN glb_cdcritic = tt-erro.cdcritic.
                   NEXT.
               END.
       END.

   FIND FIRST tt-seguros WHERE
              tt-seguros.cdcooper   = glb_cdcooper   AND
              tt-seguros.nrdconta   = tel_nrdconta   AND
              tt-seguros.tpseguro   = par_tpseguro   AND
              tt-seguros.nrctrseg   = par_nrctrseg   NO-ERROR.
   
   FIND FIRST tt-prop-seguros WHERE
              tt-prop-seguros.cdcooper   = glb_cdcooper   AND
              tt-prop-seguros.nrdconta   = tel_nrdconta   AND
              tt-prop-seguros.tpseguro   = par_tpseguro   AND
              tt-prop-seguros.nrctrseg   = par_nrctrseg   NO-ERROR.
    
   ASSIGN seg_vlpreseg = tt-seguros.vlpreseg
          tel_dtinivig = tt-seguros.dtinivig
          tel_vlcapseg = tt-seguros.vlseguro
          tel_dtfimvig = tt-seguros.dtfimvig
          tel_qtpreseg = tt-seguros.qtprepag
          tel_dtcancel = tt-seguros.dtcancel
          tel_vlprepag = tt-seguros.vlprepag
          tel_dtdebito = tt-seguros.dtdebito
          tel_dscobert = " "        
          seg_tpplaseg = tt-seguros.tpplaseg
          seg_nmdsegur = tt-seguros.nmdsegur
          tel_nmbenefi[1] = tt-seguros.nmbenvid[1]
          tel_dsgraupr[1] = tt-seguros.dsgraupr[1]
          tel_txpartic[1] = tt-seguros.txpartic[1]   
          tel_nmbenefi[2] = tt-seguros.nmbenvid[2]
          tel_dsgraupr[2] = tt-seguros.dsgraupr[2]
          tel_txpartic[2] = tt-seguros.txpartic[2]
          tel_nmbenefi[3] = tt-seguros.nmbenvid[3]
          tel_dsgraupr[3] = tt-seguros.dsgraupr[3]
          tel_txpartic[3] = tt-seguros.txpartic[3]   
          tel_nmbenefi[4] = tt-seguros.nmbenvid[4]
          tel_dsgraupr[4] = tt-seguros.dsgraupr[4]
          tel_txpartic[4] = tt-seguros.txpartic[4]  
          tel_nmbenefi[5] = tt-seguros.nmbenvid[5]
          tel_dsgraupr[5] = tt-seguros.dsgraupr[5]
          tel_txpartic[5] = tt-seguros.txpartic[5].
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      DISPLAY seg_nmdsegur
              seg_vlpreseg    tel_dtinivig    tel_vlcapseg    tel_dtfimvig
              tel_qtpreseg    tel_dtcancel    tel_vlprepag    tel_dtdebito
              tel_dscobert    seg_tpplaseg    tel_nmbenefi[1] tel_dsgraupr[1] 
              tel_txpartic[1] tel_nmbenefi[2] tel_dsgraupr[2] tel_txpartic[2]
              tel_nmbenefi[3] tel_dsgraupr[3] tel_txpartic[3] tel_nmbenefi[4] 
              tel_dsgraupr[4] tel_txpartic[4] tel_nmbenefi[5] tel_dsgraupr[5] 
              tel_txpartic[5] WITH FRAME f_seguro_3.

      UPDATE  tel_nmbenefi[1] tel_dsgraupr[1] tel_txpartic[1] tel_nmbenefi[2] 
              tel_dsgraupr[2] tel_txpartic[2] tel_nmbenefi[3] tel_dsgraupr[3]
              tel_txpartic[3] tel_nmbenefi[4] tel_dsgraupr[4] tel_txpartic[4]
              tel_nmbenefi[5] tel_dsgraupr[5] tel_txpartic[5] 
              WITH FRAME f_seguro_3.

      IF   glb_cdcritic > 0   THEN
           NEXT.
     
      LEAVE.
      
   END.
      
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            HIDE FRAME f_seguro_3 NO-PAUSE.
            RETURN.
        END.

    /*  Confirmacao dos dados  */

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       aux_confirma = "N".

       glb_cdcritic = 78.
       RUN fontes/critic.p.
       BELL.
       glb_cdcritic = 0.
       MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
       LEAVE.
  
    END.  /*  Fim do DO WHILE TRUE  */

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
         aux_confirma <> "S" THEN
         DO:
             glb_cdcritic = 79.
             RUN fontes/critic.p.
             glb_cdcritic = 0.
             BELL.
             MESSAGE glb_dscritic.
             HIDE FRAME f_seguro_3      NO-PAUSE.
             NEXT.
         END.

    ASSIGN tt-seguros.nmbenvid[1] = tel_nmbenefi[1]
           tt-seguros.dsgraupr[1] = tel_dsgraupr[1]
           tt-seguros.txpartic[1] = tel_txpartic[1]
           tt-seguros.nmbenvid[2] = tel_nmbenefi[2]
           tt-seguros.dsgraupr[2] = tel_dsgraupr[2]
           tt-seguros.txpartic[2] = tel_txpartic[2]
           tt-seguros.nmbenvid[3] = tel_nmbenefi[3]
           tt-seguros.dsgraupr[3] = tel_dsgraupr[3]
           tt-seguros.txpartic[3] = tel_txpartic[3]
           tt-seguros.nmbenvid[4] = tel_nmbenefi[4]
           tt-seguros.dsgraupr[4] = tel_dsgraupr[4]
           tt-seguros.txpartic[4] = tel_txpartic[4]
           tt-seguros.nmbenvid[5] = tel_nmbenefi[5]
           tt-seguros.dsgraupr[5] = tel_dsgraupr[5]
           tt-seguros.txpartic[5] = tel_txpartic[5].

    RUN sistema/generico/procedures/b1wgen0033.p 
        PERSISTENT SET h-b1wgen0033.

    RUN atualizar_seguro IN h-b1wgen0033(INPUT glb_cdcooper,                        
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT glb_cdoperad,
                                         INPUT glb_dtmvtolt,
                                         INPUT tel_nrdconta,
                                         INPUT 1,
                                         INPUT 1,
                                         INPUT glb_nmdatela,
                                         INPUT FALSE,
                                         INPUT tt-seguros.tpseguro,
                                         INPUT tt-seguros.nrctrseg,
                                         INPUT tt-seguros.cdsegura,
                                         INPUT tt-seguros.cdsitseg,
                                         INPUT tt-seguros.dsgraupr[1],
                                         INPUT tt-seguros.dsgraupr[2],
                                         INPUT tt-seguros.dsgraupr[3],
                                         INPUT tt-seguros.dsgraupr[4],
                                         INPUT tt-seguros.dsgraupr[5],
                                         INPUT tt-seguros.nmbenvid[1],
                                         INPUT tt-seguros.nmbenvid[2],
                                         INPUT tt-seguros.nmbenvid[3],
                                         INPUT tt-seguros.nmbenvid[4],
                                         INPUT tt-seguros.nmbenvid[5],
                                         INPUT tt-seguros.txpartic[1],
                                         INPUT tt-seguros.txpartic[2],
                                         INPUT tt-seguros.txpartic[3],
                                         INPUT tt-seguros.txpartic[4],
                                         INPUT tt-seguros.txpartic[5],
                                         OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0033.

    IF   RETURN-VALUE <> "OK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF   AVAIL tt-erro   THEN
                DO:
                    ASSIGN glb_cdcritic = tt-erro.cdcritic.
                    NEXT.
                END.
        END.

   RUN fontes/segvida_m.p (INPUT tt-prop-seguros.registro,
                           INPUT "A" ). /*cddopcao*/.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_seguro_3 NO-PAUSE.

/* .......................................................................... */
