/* .............................................................................

   Programa: Fontes/lancstt.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Outubro/2000.                       Ultima atualizacao: 09/03/2016
     
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de troca de data da tela lancst.
   
   Alteracoes: Alterar nrdolote p/6 posicoes (Margarete/Planner).

               18/06/2001 - Aumentar o prazo da custodia para 2 anos (Deborah)

               11/07/2001 - Alterado para adaptar o nome de campo (Edson).

               25/09/2001 - Alterado layout da tela para mostrar cheques por
                            tipo Credi, maiores e menores (Junior).

               21/05/2002 - Permitir qualquer dia para custodia(Margarete).

               25/03/2004 - Nao permitir a alteracao de data de liberacao 
                            quando esta for menor ou igual a data do movi-
                            mento (Edson).

               30/08/2004 - Colocar prazo minimo para entrada da custodia
                            (Deborah).

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando 
               
               25/01/2011 - Nao permitir alteracao de data antes de 2 dias
                            Projeto Truncagem (Ze).

               09/03/2016 - Nao permitir que a data de liberacao seja no ultimo 
                            dia util do ano (Douglas - Chamado 391928)
............................................................................. */

DEF VAR ant_dtlibera AS DATE    NO-UNDO.
DEF VAR aux_dtminimo AS DATE    NO-UNDO.
DEF VAR aux_qtddmini AS INTEGER NO-UNDO.

{ includes/var_online.i }

{ includes/var_lancst.i }

ASSIGN tel_nmcustod = ""
       tel_dtlibera = ?
       tel_nrcustod = 0
       tel_cdcmpchq = 0
       tel_cdbanchq = 0
       tel_cdagechq = 0
       tel_nrddigc1 = 0
       tel_nrctachq = 0
       tel_nrddigc2 = 0
       tel_nrcheque = 0
       tel_nrddigc3 = 0
       tel_vlcheque = 0
       tel_nrseqdig = 1.

FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                   craplot.dtmvtolt = tel_dtmvtolt   AND
                   craplot.cdagenci = tel_cdagenci   AND
                   craplot.cdbccxlt = tel_cdbccxlt   AND
                   craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR NO-WAIT.

IF  NOT AVAILABLE craplot   THEN
    RETURN.
    
ASSIGN  tel_dtlibera = craplot.dtmvtopg
        tel_vlcompdb = craplot.vlcompdb
        tel_vlcompcr = craplot.vlcompcr
        tel_qtcompln = craplot.qtcompln
        tel_vlinfodb = craplot.vlinfodb
        tel_vlinfocr = craplot.vlinfocr
        tel_qtinfoln = craplot.qtinfoln
        tel_vldifedb = craplot.vlcompdb - craplot.vlinfodb
        tel_vldifecr = craplot.vlcompcr - craplot.vlinfocr
        tel_qtdifeln = craplot.qtcompln - craplot.qtinfoln

        tel_qtinfocc = craplot.qtinfocc
        tel_vlinfocc = craplot.vlinfocc
        tel_qtcompcc = craplot.qtcompcc
        tel_vlcompcc = craplot.vlcompcc
        tel_qtdifecc = craplot.qtinfocc - craplot.qtcompcc
        tel_vldifecc = craplot.vlinfocc - craplot.vlcompcc

        tel_qtinfoci = craplot.qtinfoci
        tel_vlinfoci = craplot.vlinfoci
        tel_qtcompci = craplot.qtcompci
        tel_vlcompci = craplot.vlcompci
        tel_qtdifeci = craplot.qtinfoci - craplot.qtcompci
        tel_vldifeci = craplot.vlinfoci - craplot.vlcompci

        tel_qtinfocs = craplot.qtinfocs
        tel_vlinfocs = craplot.vlinfocs
        tel_qtcompcs = craplot.qtcompcs
        tel_vlcompcs = craplot.vlcompcs
        tel_qtdifecs = craplot.qtinfocs - craplot.qtcompcs
        tel_vldifecs = craplot.vlinfocs - craplot.vlcompcs.

DISPLAY tel_qtinfocc tel_vlinfocc tel_qtcompcc
        tel_vlcompcc tel_qtdifecc tel_vldifecc
        tel_qtinfoci tel_vlinfoci tel_qtcompci
        tel_vlcompci tel_qtdifeci tel_vldifeci
        tel_qtinfocs tel_vlinfocs tel_qtcompcs
        tel_vlcompcs tel_qtdifecs tel_vldifecs
        tel_dtlibera
        WITH FRAME f_lancst.

IF   tel_dtlibera <= glb_dtmvtolt   THEN
     DO:
         MESSAGE "Nao e' possivel alterar a data de liberacao.".
         MESSAGE "Data atual menor ou igual a data de hoje.".
         RETURN.
     END.

PAUSE 0.

CMC-7:
      
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            ASSIGN glb_cdcritic = 0
                   tel_dsdocmc7 = "".
        END.

   UPDATE tel_dtlibera WITH FRAME f_troca.
  
   ASSIGN aux_dtminimo = glb_dtmvtolt
          aux_qtddmini = 0.
     
   DO WHILE TRUE:
                
      aux_dtminimo = aux_dtminimo + 1.
      IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtminimo))) OR
           CAN-FIND(crapfer WHERE crapfer.cdcooper = glb_cdcooper  AND 
                                  crapfer.dtferiad = aux_dtminimo) THEN
           NEXT.
      ELSE 
           aux_qtddmini = aux_qtddmini + 1.

      IF   aux_qtddmini = 2 THEN
           LEAVE.
                       
   END.  /*  Fim do DO WHILE TRUE  */
            
   IF   tel_dtlibera <> ?   THEN
        DO:
            IF   tel_dtlibera <= aux_dtminimo                OR
                 tel_dtlibera = craplot.dtmvtopg             OR
                 tel_dtlibera > (glb_dtmvtolt + 1095)         THEN
                 DO:
                     glb_cdcritic = 13.
                     NEXT.
                 END.
                 
            /*  Nao permite data de liberacao para último dia útil do Ano.  */
            RUN sistema/generico/procedures/b1wgen0015.p 
            PERSISTENT SET h-b1wgen0015.

            ASSIGN aux_dtdialim = DATE(12,31,YEAR(tel_dtlibera)).
            RUN retorna-dia-util IN h-b1wgen0015 (INPUT glb_cdcooper,
                                                  INPUT FALSE,  /* Feriado */
                                                  INPUT TRUE, /** Anterior **/
                                                  INPUT-OUTPUT aux_dtdialim).

            DELETE PROCEDURE h-b1wgen0015.

            IF   aux_dtdialim = tel_dtlibera THEN 
                 DO:
                     glb_cdcritic = 13.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic. 
                     NEXT.
                 END.
        END.
   ELSE
        DO:
            glb_cdcritic = 13.
            NEXT.
        END.
                
   HIDE MESSAGE NO-PAUSE.

   DO WHILE TRUE TRANSACTION ON ERROR UNDO, LEAVE:
   
      FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                         craplot.dtmvtolt = tel_dtmvtolt   AND
                         craplot.cdagenci = tel_cdagenci   AND
                         craplot.cdbccxlt = tel_cdbccxlt   AND
                         craplot.nrdolote = tel_nrdolote
                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

      IF   NOT AVAILABLE craplot   THEN
           IF   LOCKED craplot   THEN
                DO:
                    PAUSE 2 NO-MESSAGE.
                    NEXT.
                END.
           ELSE
                glb_cdcritic = 60.
      ELSE
           DO:   
               IF   craplot.tplotmov <> 19   THEN
                    glb_cdcritic = 100.
           END.
                   
      IF   glb_cdcritic > 0   THEN
           LEAVE.

      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

         ASSIGN aux_confirma = "N"
                glb_cdcritic = 78.
 
         RUN fontes/critic.p.
         BELL.
         MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
         glb_cdcritic = 0.
         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
           aux_confirma <> "S" THEN
           DO:
               glb_cdcritic = 79.
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
               NEXT CMC-7.
           END.
    
      MESSAGE COLOR NORMAL "Aguarde... ".

      FOR EACH crapcst WHERE crapcst.cdcooper = glb_cdcooper   AND 
                             crapcst.dtmvtolt = tel_dtmvtolt   AND
                             crapcst.cdagenci = tel_cdagenci   AND
                             crapcst.cdbccxlt = tel_cdbccxlt   AND
                             crapcst.nrdolote = tel_nrdolote   EXCLUSIVE-LOCK:
 
          aux_nrdocmto = INT(STRING(crapcst.nrcheque,"999999") +
                             STRING(crapcst.nrddigc3,"9")).

          DO WHILE TRUE:
        
             FIND craplau WHERE craplau.cdcooper = glb_cdcooper       AND 
                                craplau.dtmvtolt = crapcst.dtmvtolt   AND
                                craplau.cdagenci = crapcst.cdagenci   AND
                                craplau.cdbccxlt = crapcst.cdbccxlt   AND
                                craplau.nrdolote = crapcst.nrdolote   AND
                       DECIMAL(craplau.nrdctabb) = crapcst.nrctachq   AND
                                craplau.nrdocmto = aux_nrdocmto
                                USE-INDEX craplau1 EXCLUSIVE-LOCK 
                                NO-ERROR NO-WAIT.

             IF   NOT AVAILABLE craplau   THEN
                  IF   LOCKED craplau   THEN
                       DO:
                           PAUSE 2 NO-MESSAGE.
                           NEXT.
                       END.
                      
             LEAVE.

          END.  /*  Fim do DO WHILE TRUE  */
        
          IF   AVAILABLE craplau   THEN
               craplau.dtmvtopg = tel_dtlibera.
 
          crapcst.dtlibera = tel_dtlibera.
     
       END.  /*  Fim do FOR EACH -- crapcst  */

       ASSIGN ant_dtlibera     = craplot.dtmvtopg
              craplot.dtmvtopg = tel_dtlibera.
                 
       UNIX SILENT VALUE("echo " + 
                         STRING(TODAY,"99/99/9999") + " - " +
                         STRING(TIME,"HH:MM:SS") +
                         " - Operador: " + glb_nmoperad +
                         " - Alteracao da liberacao do lote " +
                         STRING(craplot.dtmvtolt,"99/99/9999") + "-" +
                         STRING(craplot.cdagenci,"999") + "-" +
                         STRING(craplot.cdbccxlt,"999") + "-" +
                         STRING(craplot.nrdolote,"999999") + " de " +
                         STRING(ant_dtlibera,"99/99/9999") + " para " +
                         STRING(tel_dtlibera,"99/99/9999") +  
                         " >> log/custodia.log").
                   
       LEAVE.
   
   END.  /*  Fim do DO WHILE TRUE e da transacao  */   

   HIDE FRAME f_troca NO-PAUSE.

   HIDE MESSAGE NO-PAUSE.

   IF   glb_cdcritic > 0   THEN
        NEXT.
   /*
   IF   tel_qtdifeln = 0  AND  
        tel_vldifedb = 0  AND 
        tel_vldifecr = 0   THEN
        DO:
            RUN fontes/lancstd.p.          /*  Mostra resumo do lote  */
 
            glb_nmdatela = "LOTE".
            RETURN.                        /*  Volta ao lancst.p  */
        END.
     */
     HIDE FRAME f_lanctos.

     LEAVE.

END.   /*  Fim do DO WHILE TRUE  */

HIDE FRAME f_troca NO-PAUSE.

ASSIGN tel_dtmvtolt = glb_dtmvtolt
       tel_cdagenci = 0
       tel_cdbccxlt = 0
       tel_nrdolote = 0.

CLEAR FRAME f_lancst NO-PAUSE.

/* .......................................................................... */

