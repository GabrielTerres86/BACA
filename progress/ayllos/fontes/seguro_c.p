/* .............................................................................

   Programa: Fontes/seguro_c.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/96.                           Ultima atualizacao: 25/07/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento da consulta do seguro.

   Alteracoes: Imprimir cancelamento de seguros (Odair)

               25/04/97 - Tratar seguro auto (Edson).

               12/06/97 - Tratar automacao dos seguros (Edson).

               06/11/97 - Tratar cobertura extra de seguro (Edson).

               02/08/1999 - Tratar seguro de vida em grupo (Deborah).

               23/08/1999 - Acerto na descricao do seguro (Deborah). 

               10/11/1999 - Seguro de vida para conjuge (Deborah).

               20/01/2000 - Tratar seguro prestamista (Deborah).  

               16/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).

               02/05/2001 - Permitir o cadastramento de seguro auto parcelado.
                            (Ze Eduardo).
                            
               21/09/2001 - Seguro Residencial (Ze Eduardo).

               03/01/2002 - Acertos no seguro residencial (Ze Eduardo).

               12/07/2002 - Sem proposta nao mostrar o crapass (Margarete).

               30/03/2005 - Acertos para novo modelo de cadastramento de
                            seguro - Unibanco (Evandro).
                            
               01/12/2005 - Tratamento para seguro SUL AMERICA-CASA (Evandro).

               17/01/2006 - Nao mostrar o botao de CANCELAR na opcao de
                            consulta (Evandro).
                                                              
               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               12/06/2006 - Modificados campos referente endereco para a 
                            estrutura crapenc (Diego).
                            
               21/06/2006 - Incluidos campos referente Local do Risco para
                            seguro tipo CASA (Diego).
                            
               10/07/2006 - Tratamento para FRAME com craptsg.mmpripag = 0
                            (Julio)

               14/07/2006 - Nao estava aparecendo locais de risco na consulta
                            (Julio)
                            
               05/11/2007 - Alterado nmdsecao(crapass)p/ttl.nmdsecao(Guilherme).
               
               15/12/2008 - Retirar seguros de Automoveis (Gabriel).
               
               31/03/2010 - Adaptacao para browse dinamico.
                            Retirado a consulta de seguros "em estudo" (Gabriel)
                            
               02/09/2011 - Adicionada logica para voltar na primeira pagina.
                            Adicionadas chamadas para procedure
                            busca_end_cor da b1wgen0033 (Gati - Oliver)
                            
               19/10/2011 - Alterado para executar procedure buscar_seguro_geral
                            ao inves de busca_seguros; chamar seguro especifico
                            a ser consultado (GATI - Eder)
                            
               25/07/2013 - Incluido o campo Complemento no endereco. (James)             
............................................................................. */
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_seguro.i }
{ sistema/generico/includes/var_internet.i }

DEF INPUT PARAM par_cdsegura AS INTE                               NO-UNDO.
DEF INPUT PARAM par_tpseguro AS INTE                               NO-UNDO.
DEF INPUT PARAM par_nrctrseg AS INTE                               NO-UNDO.

RUN sistema/generico/procedures/b1wgen0033.p PERSISTENT SET h-b1wgen0033.

RUN buscar_associados IN h-b1wgen0033 (INPUT glb_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT glb_cdoperad,
                                       INPUT glb_dtmvtolt,
                                       INPUT tel_nrdconta,
                                       INPUT 1,
                                       INPUT 1,
                                       INPUT glb_nmdatela,
                                       INPUT FALSE,
                                       OUTPUT TABLE tt-associado,
                                       OUTPUT TABLE tt-erro).

DELETE PROCEDURE h-b1wgen0033.

IF   RETURN-VALUE <> "OK"  THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
        IF   AVAIL tt-erro   THEN
            DO:
                ASSIGN glb_cdcritic = tt-erro.cdcritic
                       glb_dscritic = tt-erro.dscritic.
                BELL.
                MESSAGE glb_dscritic.
                glb_cdcritic = 0.
                RETURN.
            END.
    END.
    
FIND FIRST tt-associado WHERE
           tt-associado.cdcooper = glb_cdcooper  AND
           tt-associado.nrdconta = tel_nrdconta  NO-ERROR.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   DO WHILE TRUE ON ERROR UNDO, LEAVE:

      RUN sistema/generico/procedures/b1wgen0033.p
          PERSISTENT SET h-b1wgen0033.

      RUN buscar_seguro_geral IN h-b1wgen0033 (INPUT  glb_cdcooper,
                                               INPUT  0,
                                               INPUT  0,
                                               INPUT  glb_cdoperad,
                                               INPUT  glb_dtmvtolt,
                                               INPUT  tel_nrdconta,
                                               INPUT  1,
                                               INPUT  1,
                                               INPUT  glb_nmdatela,
                                               INPUT  FALSE,
                                               INPUT  par_cdsegura,
                                               INPUT  par_tpseguro,
                                               INPUT  par_nrctrseg,
                                               OUTPUT TABLE tt-seg-geral,
                                               OUTPUT TABLE tt-erro).

      DELETE PROCEDURE h-b1wgen0033.

      IF  RETURN-VALUE <> "OK"  THEN
          DO:
              FIND FIRST tt-erro NO-LOCK NO-ERROR.
              IF   AVAIL tt-erro   THEN
                  DO:
                      ASSIGN glb_cdcritic = tt-erro.cdcritic
                             glb_dscritic = tt-erro.dscritic.
                      BELL.
                      MESSAGE glb_dscritic.
                      glb_cdcritic = 0.
                      RETURN.
                  END.
          END.

      FIND tt-seg-geral NO-ERROR.
      IF  NOT AVAIL tt-seg-geral  THEN
          RETURN "NOK".

      /* tratamento para o novo modelo de seguro */
      IF   tt-seg-geral.tpseguro = 11   THEN
           DO:
               /*RUN seguro_casa (tt-seguros.registro).*/
               RUN seguro_casa.
               RETURN.
           END.

      IF   tt-seg-geral.tpseguro <> 1   THEN    /*  Antigo CASA  */
           DO:                   /* Seguro Vida */                   
               ASSIGN tel_dsseguro    = tt-seg-geral.dsseguro
                      tel_dspesseg    = tt-seg-geral.dspesseg
                      seg_vlpreseg    = tt-seg-geral.vlpreseg
                      tel_qtpreseg    = tt-seg-geral.qtpreseg
                      tel_vlprepag    = tt-seg-geral.vlprepag
                      tel_dtinivig    = tt-seg-geral.dtinivig
                      tel_dtfimvig    = tt-seg-geral.dtfimvig
                      tel_dtcancel    = tt-seg-geral.dtcancel
                      tel_dtdebito    = tt-seg-geral.dtdebito
                      seg_tpplaseg    = tt-seg-geral.tpplaseg
                      tel_nmbenefi[1] = tt-seg-geral.nmbenefi[1]
                      tel_nmbenefi[2] = tt-seg-geral.nmbenefi[2]
                      tel_nmbenefi[3] = tt-seg-geral.nmbenefi[3]
                      tel_nmbenefi[4] = tt-seg-geral.nmbenefi[4]
                      tel_nmbenefi[5] = tt-seg-geral.nmbenefi[5]
                      tel_dsgraupr[1] = tt-seg-geral.dsgraupr[1]
                      tel_dsgraupr[2] = tt-seg-geral.dsgraupr[2]
                      tel_dsgraupr[3] = tt-seg-geral.dsgraupr[3]
                      tel_dsgraupr[4] = tt-seg-geral.dsgraupr[4]
                      tel_dsgraupr[5] = tt-seg-geral.dsgraupr[5]
                      tel_txpartic[1] = tt-seg-geral.txpartic[1]
                      tel_txpartic[2] = tt-seg-geral.txpartic[2]
                      tel_txpartic[3] = tt-seg-geral.txpartic[3]
                      tel_txpartic[4] = tt-seg-geral.txpartic[4]
                      tel_txpartic[5] = tt-seg-geral.txpartic[5]
                      tel_dssitseg    = tt-seg-geral.dssitseg
                      tel_dsevento    = tt-seg-geral.dsevento
                      tel_vlcapseg    = tt-seg-geral.vlcapseg
                      tel_dscobert    = tt-seg-geral.dscobert
                      seg_nmdsegur    = tt-seg-geral.nmdsegur.
                  
               DISPLAY seg_nmdsegur
                       seg_vlpreseg     tel_dtinivig    tel_vlprepag 
                       tel_dtfimvig     tel_qtpreseg    tel_dtcancel 
                       tel_dtdebito     seg_tpplaseg    tel_vlcapseg
                       tel_dscobert     tel_nmbenefi[1] tel_dsgraupr[1]
                       tel_txpartic[1]  WHEN tel_txpartic[1] > 0
                       tel_nmbenefi[2]  tel_dsgraupr[2]
                       tel_txpartic[2]  WHEN tel_txpartic[2] > 0
                       tel_nmbenefi[3]  tel_dsgraupr[3]
                       tel_txpartic[3]  WHEN tel_txpartic[3] > 0
                       tel_nmbenefi[4]  tel_dsgraupr[4]
                       tel_txpartic[4]  WHEN tel_txpartic[4] > 0
                       tel_nmbenefi[5]  tel_dsgraupr[5]
                       tel_txpartic[5]  WHEN tel_txpartic[5] > 0
                       tel_dspesseg     tel_dssitseg 
                       tel_dsevento     WITH FRAME f_seguro_3.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  IF   tel_dsevento <> ""   THEN
                       DO:   
                           CHOOSE FIELD tel_dsevento WITH FRAME f_seguro_3.

                           IF FRAME-VALUE = tel_cancelar   OR
                              FRAME-VALUE = "Imprimir"     THEN
                              DO:
                                  RUN fontes/seguro_x.p (INPUT par_tpseguro,
                                                         INPUT par_nrctrseg).

                                  IF   glb_cdcritic = 0   THEN
                                       DO:
                                           ASSIGN tel_dsevento = "Imprimir"
                                                  tel_dssitseg = "Cancelado".

                                           DISPLAY tel_dsevento
                                                   tel_dssitseg
                                                   glb_dtmvtolt @
                                                       tel_dtcancel
                                                   WITH FRAME f_seguro_3.
                                       END.
                                  ELSE
                                       glb_cdcritic = 0.
                              END.

                       END.  
                  ELSE       
                       DO:   
                           PAUSE MESSAGE "Tecle algo para retornar.".
                           LEAVE.
                       END.  

               END.  /*  Fim do DO WHILE TRUE  */

               HIDE FRAME f_seguro_3 NO-PAUSE.

           END.             
              
      LEAVE.                 

   END.  /*  Fim do DO WHILE TRUE  */
           
   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_seguro_1.

/* tratamento para o novo modelo de seguro */
PROCEDURE seguro_casa:

    ASSIGN seg_nmresseg    = tt-seg-geral.nmresseg
           seg_dstipseg    = tt-seg-geral.dstipseg
           seg_nrctrseg    = tt-seg-geral.nrctrseg
           seg_tpplaseg    = tt-seg-geral.tpplaseg
           seg_ddvencto    = tt-seg-geral.ddvencto
           seg_vlpreseg    = tt-seg-geral.vlpreseg
           seg_vltotpre    = tt-seg-geral.vltotpre
           seg_dtinivig    = tt-seg-geral.dtinivig
           seg_dtfimvig    = tt-seg-geral.dtfimvig
           seg_dtcancel    = tt-seg-geral.dtcancel
           seg_qtmaxpar    = tt-seg-geral.qtmaxpar
           seg_ddpripag    = tt-seg-geral.ddpripag
           seg_dsendres    = tt-seg-geral.dsendres
           seg_nrendere    = tt-seg-geral.nrendres
           seg_nmcidade    = tt-seg-geral.nmcidade
           seg_nmbairro    = tt-seg-geral.nmbairro
           seg_cdufresd    = tt-seg-geral.cdufresd
           seg_nrcepend    = tt-seg-geral.nrcepend
           seg_complend    = tt-seg-geral.complend
           seg_flgclabe    = tt-seg-geral.flgclabe
           seg_nmbenvid[1] = tt-seg-geral.nmbenvid[1]
           seg_dsmotcan    = tt-seg-geral.dsmotcan
           seg_tpendcor    = tt-seg-geral.tpendcor
           seg_dsendres_2  = tt-seg-geral.dsendres_2
           seg_nrendere_2  = tt-seg-geral.nrendres_2
           seg_nmbairro_2  = tt-seg-geral.nmbairro_2
           seg_nrcepend_2  = tt-seg-geral.nrcepend_2
           seg_nmcidade_2  = tt-seg-geral.nmcidade_2
           seg_cdufresd_2  = tt-seg-geral.cdufresd_2
           seg_complend_2  = tt-seg-geral.complend_2.

    /* Busca o plano para ver qual frame usar */
    RUN sistema/generico/procedures/b1wgen0033.p PERSISTENT SET h-b1wgen0033.

    RUN buscar_plano_seguro IN h-b1wgen0033
                               (INPUT glb_cdcooper,
                                INPUT 0,
                                INPUT 0,
                                INPUT glb_cdoperad,
                                INPUT glb_dtmvtolt,
                                INPUT tel_nrdconta,
                                INPUT 1,
                                INPUT 1,
                                INPUT glb_nmdatela,
                                INPUT FALSE,
                                INPUT tt-seg-geral.cdsegura,
                                INPUT tt-seg-geral.tpseguro,
                                INPUT tt-seg-geral.tpplaseg,
                                OUTPUT TABLE tt-plano-seg,
                                OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0033.

    FIND tt-plano-seg WHERE tt-plano-seg.cdcooper = glb_cdcooper            AND
                            tt-plano-seg.cdsegura = tt-seg-geral.cdsegura   AND
                            tt-plano-seg.tpseguro = tt-seg-geral.tpseguro   AND
                            tt-plano-seg.cdsitpsg = 1                       AND
                            tt-plano-seg.tpplaseg = tt-seg-geral.tpplaseg
                            NO-LOCK NO-ERROR.

    DISPLAY seg_nmresseg
            seg_dstipseg
            seg_nrctrseg
            seg_tpplaseg 
            WITH FRAME f_seg_simples.
            
    PAUSE 0.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

        HIDE FRAME f_seg_simples_end_corr.

        VIEW FRAME f_seg_simples_mens. 

        IF   tt-plano-seg.mmpripag = 0   AND
             NOT tt-plano-seg.flgunica   THEN
             DISPLAY seg_ddpripag seg_ddvencto
                     WITH FRAME f_seg_simples_ddpripag.
        ELSE 
        IF   NOT tt-plano-seg.flgunica  THEN
             DISPLAY seg_ddvencto
                     WITH FRAME f_seg_simples_ddpagto_car.

        DISPLAY seg_vlpreseg
                seg_dtinivig
                seg_dtfimvig
                seg_dtcancel
                seg_dsmotcan
                seg_dsendres
                seg_nrendere
                seg_complend
                seg_nmcidade
                seg_nmbairro
                seg_cdufresd
                seg_nrcepend
                seg_flgclabe
                seg_nmbenvid[1]
                WITH FRAME f_seg_simples_mens.

        PAUSE MESSAGE "Pressione algo para continuar - <F4>/<END> para sair.".

        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:

            HIDE FRAME f_seg_simples_mens.
            HIDE FRAME f_seg_simples_ddpripag.

            DISP seg_tpendcor
                 seg_dsendres_2
                 seg_nrendere_2
                 seg_complend_2
                 seg_nmbairro_2
                 seg_nrcepend_2
                 seg_nmcidade_2
                 seg_cdufresd_2
                WITH FRAME f_seg_simples_end_corr.

            PAUSE MESSAGE "Pressione algo para sair - <F4>/<END> para voltar.".

            LEAVE.
        END.

        IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            NEXT.

        LEAVE.
    END.

    HIDE FRAME f_seg_simples             NO-PAUSE.
    HIDE FRAME f_seg_simples_mens        NO-PAUSE.
    HIDE FRAME f_seg_simples_end_corr    NO-PAUSE.
    HIDE FRAME f_seg_simples_ddpripag    NO-PAUSE.
    HIDE FRAME f_seg_simples_ddpagto_car NO-PAUSE.
    HIDE FRAME f_seg_simples_var         NO-PAUSE.

END PROCEDURE.

/* .......................................................................... */
