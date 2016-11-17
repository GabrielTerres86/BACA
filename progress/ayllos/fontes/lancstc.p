/* .............................................................................

   Programa: Fontes/lancstc.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Abril/2000.                      Ultima atualizacao: 08/07/2010
      
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Processar a rotina de consulta da tela lancst.

   Alteracoes: 11/07/2001 - Alterado para adaptar o nome de campo (Edson).

               25/09/2001 - Alterado layout da tela para mostrar cheques por
                            tipo Credi, maiores e menores (Junior).

               16/05/2005 - Tratamento Conta Integracao(Mirtes)

               30/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               08/07/2010 - Tratamento para Compe 085 (Ze).
............................................................................. */

{ includes/var_online.i }

{ includes/var_lancst.i }

{ includes/proc_conta_integracao.i }

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

CMC-7:

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
    
   IF   glb_cdcritic > 0 THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            ASSIGN glb_cdcritic = 0
                   tel_dsdocmc7 = ""
                   tel_vlcheque = 0
                   tel_nrcustod = 0
                   tel_nrseqdig = 0
                   tel_nmcustod = ""
                   tel_dtlibera = ?
                   tel_reganter = "".

            DISPLAY tel_nrcustod tel_nmcustod tel_dtlibera tel_vlcheque 
                    tel_nrseqdig WITH FRAME f_lancst.        

            HIDE FRAME f_regant NO-PAUSE.
        END.
      
   UPDATE tel_dsdocmc7 WITH FRAME f_lancst
         
   EDITING:
            
      READKEY.
       
      IF   NOT CAN-DO(aux_lsvalido,KEYLABEL(LASTKEY))   THEN
           DO:
               glb_cdcritic = 666.
               NEXT.
           END.

      IF   KEYLABEL(LASTKEY) = "G"   THEN
           APPLY KEYCODE(":").
      ELSE
           APPLY LASTKEY.
  
   END.  /*  Fim do EDITING  */
         
   HIDE MESSAGE NO-PAUSE.
       
   IF   TRIM(tel_dsdocmc7) <> ""   THEN
        DO:
            IF   LENGTH(tel_dsdocmc7) <> 34            OR
                 SUBSTRING(tel_dsdocmc7,01,1) <> "<"   OR
                 SUBSTRING(tel_dsdocmc7,10,1) <> "<"   OR
                 SUBSTRING(tel_dsdocmc7,21,1) <> ">"   OR
                 SUBSTRING(tel_dsdocmc7,34,1) <> ":"   THEN
                 DO:
                     glb_cdcritic = 666.
                     NEXT.
                 END.
        
            ASSIGN tel_cdbanchq = INT(SUBSTRING(tel_dsdocmc7,02,03))
                   tel_cdagechq = INT(SUBSTRING(tel_dsdocmc7,05,04))
                   tel_cdcmpchq = INT(SUBSTRING(tel_dsdocmc7,11,03))
                   tel_nrcheque = INT(SUBSTRING(tel_dsdocmc7,14,06))
                   tel_nrctachq = IF tel_cdbanchq = 1 
                                    THEN DECIMAL(SUBSTRING(tel_dsdocmc7,25,08))
                                    ELSE DECIMAL(SUBSTRING(tel_dsdocmc7,23,10)).

            /*  Calcula primeiro digito de controle  */
                  
            glb_nrcalcul = DECIMAL(STRING(tel_cdcmpchq,"999") +
                                   STRING(tel_cdbanchq,"999") +
                                   STRING(tel_cdagechq,"9999") + "0").
                                      
            RUN fontes/digfun.p.
                  
            tel_nrddigc1 = INT(SUBSTRING(STRING(glb_nrcalcul),
                                  LENGTH(STRING(glb_nrcalcul)))).    
                   
            /*  Calcula segundo digito de controle  */

            glb_nrcalcul = tel_nrctachq * 10.
                                         
            RUN fontes/digfun.p.
                  
            tel_nrddigc2 = INT(SUBSTRING(STRING(glb_nrcalcul),
                                  LENGTH(STRING(glb_nrcalcul)))).    
 
            /*  Calcula terceiro digito de controle  */

            glb_nrcalcul = tel_nrcheque * 10.
                                         
            RUN fontes/digfun.p.
                  
            tel_nrddigc3 = INT(SUBSTRING(STRING(glb_nrcalcul),
                                  LENGTH(STRING(glb_nrcalcul)))).    
                       
            /*  Mostra os dados lidos  */
                  
            DISPLAY tel_cdcmpchq tel_cdbanchq tel_cdagechq 
                    tel_nrddigc1 tel_nrctachq tel_nrddigc2 
                    tel_nrcheque tel_nrddigc3 WITH FRAME f_lancst.
        END.
   ELSE
        DO:
            aux_confirma = "S".
           
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               MESSAGE COLOR NORMAL "Listar o lote? (S/N):" UPDATE aux_confirma.

               LEAVE.
               
            END.  /*  Fim do DO WHILE TRUE  */

            IF   aux_confirma = "S"   THEN
                 DO:
                     RUN proc_lista.
                     NEXT.
                 END.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                  
               RUN fontes/cmc7.p (OUTPUT tel_dsdocmc7).
                        
               IF   LENGTH(tel_dsdocmc7) <> 34   THEN
                    LEAVE.
                         
               DISPLAY tel_dsdocmc7 WITH FRAME f_lancst.
                     
               RUN mostra_dados.
 
               IF   glb_cdcritic > 0   THEN
                    NEXT.

               LEAVE.
                   
            END.  /*  Fim do DO WHILE TRUE  */
                  
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
                 NEXT.
        END.
     
   DO WHILE TRUE:    

      FIND crapcst WHERE crapcst.cdcooper = glb_cdcooper   AND 
                         crapcst.dtmvtolt = tel_dtmvtolt   AND
                         crapcst.cdagenci = tel_cdagenci   AND
                         crapcst.cdbccxlt = tel_cdbccxlt   AND
                         crapcst.nrdolote = tel_nrdolote   AND
                         crapcst.cdcmpchq = tel_cdcmpchq   AND
                         crapcst.cdbanchq = tel_cdbanchq   AND
                         crapcst.cdagechq = tel_cdagechq   AND
                         crapcst.nrctachq = tel_nrctachq   AND
                         crapcst.nrcheque = tel_nrcheque   NO-LOCK NO-ERROR.
                           
      IF   NOT AVAILABLE crapcst   THEN
           DO:
               IF  (tel_cdbanchq = 756            AND 
                    tel_cdagechq = aux_cdagebcb)  OR
                   (tel_cdbanchq = aux_cdbcoctl   AND
                    tel_cdagechq = aux_cdagectl)  THEN
                    DO:
                        FIND FIRST craptrf WHERE
                                   craptrf.cdcooper = glb_cdcooper      AND 
                                   craptrf.nrdconta = INT(tel_nrctachq) AND
                                   craptrf.tptransa = 1 
                                   USE-INDEX craptrf1 NO-LOCK NO-ERROR.

                        IF   AVAILABLE craptrf THEN
                             DO:
                                 tel_nrctachq = craptrf.nrsconta.
                                 DISPLAY tel_nrctachq WITH FRAME f_lancst.
                                 NEXT.
                             END.
                    END.

               glb_cdcritic = 90.
               LEAVE.
           END.

      FIND craplot WHERE craplot.cdcooper = glb_cdcooper   AND 
                         craplot.dtmvtolt = tel_dtmvtolt   AND
                         craplot.cdagenci = tel_cdagenci   AND
                         craplot.cdbccxlt = tel_cdbccxlt   AND
                         craplot.nrdolote = tel_nrdolote   NO-LOCK NO-ERROR.

      IF   NOT AVAILABLE craplot   THEN
           glb_cdcritic = 60.
      ELSE
           DO:   
               IF   craplot.tplotmov <> 19   THEN
                    glb_cdcritic = 100.
           END.
                   
      IF   glb_cdcritic > 0   THEN
           LEAVE.

      FIND crapass WHERE crapass.cdcooper = glb_cdcooper     AND 
                         crapass.nrdconta = crapcst.nrdconta NO-LOCK NO-ERROR.
      
      IF   NOT AVAILABLE crapass   THEN
           DO:
               glb_cdcritic = 9.
               LEAVE.
           END.

      ASSIGN tel_nmcustod = crapass.nmprimtl
             tel_vlcheque = crapcst.vlcheque
             tel_dtlibera = crapcst.dtlibera
             tel_nrcustod = crapcst.nrdconta
             tel_nrseqdig = crapcst.nrseqdig.
      
      DISPLAY tel_nrcustod tel_nmcustod tel_dtlibera 
              tel_vlcheque tel_nrseqdig
              WITH FRAME f_lancst.
 
      ASSIGN tel_vlcompdb = craplot.vlcompdb
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

      LEAVE.
        
   END.  /*  Fim do DO WHILE TRUE e da transacao  */

   IF   glb_cdcritic > 0   THEN
        NEXT.

   DISPLAY tel_qtinfocc tel_vlinfocc tel_qtcompcc
           tel_vlcompcc tel_qtdifecc tel_vldifecc
           tel_qtinfoci tel_vlinfoci tel_qtcompci
           tel_vlcompci tel_qtdifeci tel_vldifeci
           tel_qtinfocs tel_vlinfocs tel_qtcompcs
           tel_vlcompcs tel_qtdifecs tel_vldifecs
           tel_cdcmpchq tel_cdbanchq tel_cdagechq
           tel_nrddigc1 tel_nrctachq tel_nrddigc2
           tel_nrcheque tel_nrddigc3 tel_vlcheque
           tel_nrseqdig
           WITH FRAME f_lancst.

   HIDE FRAME f_lanctos.

END.   /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

{ includes/proc_lancst.i }

PROCEDURE proc_lista:

    CLEAR FRAME f_lanctos ALL NO-PAUSE.

    ASSIGN aux_contador = 0
           aux_flgretor = FALSE
           aux_regexist = FALSE.
 
    FOR EACH crapcst WHERE crapcst.cdcooper = glb_cdcooper   AND 
                           crapcst.dtmvtolt = tel_dtmvtolt   AND
                           crapcst.cdagenci = tel_cdagenci   AND
                           crapcst.cdbccxlt = tel_cdbccxlt   AND
                           crapcst.nrdolote = tel_nrdolote   
                           USE-INDEX crapcst4 NO-LOCK:

        ASSIGN aux_regexist = TRUE
               aux_contador = aux_contador + 1.

        IF   aux_contador = 1   THEN
             IF   aux_flgretor   THEN
                  DO:
                      PAUSE MESSAGE
                          "Tecle <Entra> para continuar ou <Fim> para encerrar".
                      CLEAR FRAME f_lanctos ALL NO-PAUSE.
                  END.
             ELSE
                  aux_flgretor = TRUE.

        PAUSE (0).

        DISPLAY crapcst.cdcmpchq  crapcst.cdbanchq 
                crapcst.cdagechq  crapcst.nrddigc1
                crapcst.nrctachq  crapcst.nrddigc2
                crapcst.nrcheque  crapcst.nrddigc3
                crapcst.vlcheque  crapcst.nrseqdig
                WITH FRAME f_lanctos.

        IF   aux_contador = 11   THEN
             aux_contador = 0.
        ELSE
             DOWN WITH FRAME f_lanctos.

    END.  /*  Fim do FOR EACH  */

    IF   aux_regexist   AND
         KEYFUNCTION(LASTKEY) <> "END-ERROR"   THEN     
         PAUSE MESSAGE "Tecle <Entra> para encerrar".

    HIDE FRAME f_lanctos NO-PAUSE.

END PROCEDURE.

/* .......................................................................... */

