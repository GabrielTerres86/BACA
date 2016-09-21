/* .............................................................................

   Programa: includes/seg_simples.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Marco/2005                       Ultima atualizacao: 25/07/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina/Tela para o novo modelo de inclusao do seguro.

   Alteracoes: 03/05/2005 - Atualizar data de movimento quando fizer endoco
                            (Julio)

               23/06/2005 - Atualizar numero de sequencia do regsito quando
                            for atualizar a data de movimento (Julio)

               06/07/2005 - Alimentado campo cdcooper da tabela crawseg (Diego).

               01/12/2005 - Tratamento para seguro SUL AMERICA-CASA (Evandro).

               07/12/2005 - Tratamento para atribuicao da data de debito caso
                            seja parcela unica (Julio)

              01/02/2006  - Unificacao dos Bancos - SQLWorks - Fernando.
              
              09/02/2006  - Tratamento para parcela unica plano 37 (Julio)
              
              29/03/2006  - Se for parcela unica, qtparcel = 1 (Julio)
              
              21/06/2006  - Incluidos campos referente Local do Risco (Diego).
              
              10/07/2006  - Configuracao do FRAME para craptsg.mmpripag = 0.
                            (Julio)
                            
              19/11/2008  - Acerto na data Final de Vigencia (Diego). 
              
              30/03/2010  - Lançar seguros automaticamente,
                            sem passar pela LANSEG.
                            Tirar substituicao de seguros (Gabriel).
                            
              27/04/2011 - Ajuste para o formato dos campos de cidade/bairro
                           (Gabriel).              
                           
              25/08/2011 - Projeto de seguro residencial. Realizadas alteracoes
                           para seguro tipo 11, casa, e criados metodos
                           na BO b1wgen0033 para realizar leituras
                           no banco de dados.
                           (Gati - Oliver)
                           
              01/12/2011 - UPDATE do campo seg_dsendres na inclusao do seguro
                           residencial. (Fabricio)
                           
              16/12/2011 - Incluido a passagem do parametro seg_dtnascsg
                           nas procedures
                           - validar_criacao 
                           - cria_seguro
                           (Adriano).      
                           
              27/02/2013 - Incluir aux_flgsegur como parametro na procedure 
                           cria_seguro (Lucas R.).
                           
              25/07/2013 - Incluido o campo complemento no endereco. (James).                      
..............................................................................*/

DEF VAR aux_flgsegur AS LOG             NO-UNDO.

ON VALUE-CHANGED OF b_planos IN FRAME f_planos DO:

    DISPLAY tt-plano-seg.vlplaseg
            tt-plano-seg.flgunica
            tt-plano-seg.qtmaxpar
            tt-plano-seg.mmpripag
            tt-plano-seg.qtdiacar
            tt-plano-seg.ddmaxpag            
            WITH FRAME f_planos.
END.

ON RETURN OF b_planos IN FRAME f_planos DO:
   
   ASSIGN seg_tpplaseg = tt-plano-seg.tpplaseg
          seg_vlpreseg = tt-plano-seg.vlplaseg
          seg_vltotpre = tt-plano-seg.vlplaseg
          aux_vldebseg = tt-plano-seg.vlplaseg.
          
   DISPLAY seg_tpplaseg WITH FRAME f_seg_simples.

   APPLY "GO".   /* para fechar o frame f_planos e continua o update */  
END.

ON LEAVE OF seg_tpplaseg IN FRAME f_seg_simples DO:

   RUN sistema/generico/procedures/b1wgen0033.p
       PERSISTENT SET h-b1wgen0033.

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
        INPUT seg_cdsegura,
        INPUT seg_cdtipseg,
        INPUT INPUT seg_tpplaseg,
        OUTPUT TABLE tt-plano-seg,
        OUTPUT TABLE tt-erro).

   DELETE PROCEDURE h-b1wgen0033.
   
   FIND tt-plano-seg WHERE
        tt-plano-seg.cdcooper = glb_cdcooper        AND
        tt-plano-seg.cdsegura = seg_cdsegura        AND
        tt-plano-seg.tpseguro = seg_cdtipseg        AND
        tt-plano-seg.cdsitpsg = 1                   NO-ERROR.

   IF   AVAILABLE tt-plano-seg THEN
        DO:
           ASSIGN seg_vlpreseg = tt-plano-seg.vlplaseg
                   seg_vltotpre = tt-plano-seg.vlplaseg
                   aux_vldebseg = tt-plano-seg.vlplaseg.

            DISPLAY seg_vlpreseg 
                   WITH FRAME f_seg_simples_mens.
        
        END.                                        
   PAUSE 0.     
END.

ON RETURN OF seg_nrcepend IN FRAME f_seg_simples_mens DO:
    ASSIGN INPUT seg_nrcepend.

    IF  seg_nrcepend <> 0  THEN 
        DO:
            RUN fontes/zoom_endereco.p (INPUT seg_nrcepend,
                                        OUTPUT TABLE tt-endereco).
    
            FIND FIRST tt-endereco NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-endereco THEN
                DO:
                    ASSIGN seg_nrcepend = tt-endereco.nrcepend 
                           seg_dsendres = tt-endereco.dsendere 
                           seg_nmbairro = tt-endereco.nmbairro 
                           seg_nmcidade = tt-endereco.nmcidade 
                           seg_cdufresd = tt-endereco.cdufende
                           seg_complend = tt-endereco.dscmpend.
                END.
            ELSE
                DO:
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        RETURN NO-APPLY.
                        
                    ASSIGN seg_dsendres = "" 
                           seg_nmbairro = "" 
                           seg_nmcidade = "" 
                           seg_cdufresd = ""
                           seg_complend = "".
                END.
        END.
    ELSE
        ASSIGN seg_nrcepend = 0 
               seg_dsendres = "" 
               seg_nmbairro = "" 
               seg_nmcidade = "" 
               seg_cdufresd = ""
               seg_complend = "".

     DISPLAY seg_nrcepend  seg_dsendres
             seg_complend  seg_nmbairro  
             seg_nmcidade  seg_cdufresd
            WITH FRAME f_seg_simples_mens.
END.

ON LEAVE OF seg_vltotpre IN FRAME f_seg_simples_var DO:

   IF  tt-plano-seg.vlplaseg = 0  AND  seg_qtmaxpar = 0   THEN
       DO:
           ASSIGN seg_vlpreseg = INPUT seg_vltotpre.
           DISPLAY seg_vlpreseg WITH FRAME f_seg_simples_var.
       END.
END.

ON LEAVE OF seg_flgclabe IN FRAME f_seg_simples_mens DO:
    ASSIGN INPUT FRAME f_seg_simples_mens seg_flgclabe.

    IF seg_flgclabe = YES THEN
        DO:
            ENABLE seg_nmbenvid[1]
                WITH FRAME f_seg_simples_mens.
        END.
    ELSE
        DO:
            ASSIGN
            seg_nmbenvid[1] = ""
            seg_nmbenvid[1]:SCREEN-VALUE IN FRAME f_seg_simples_mens = "".

            DISABLE seg_nmbenvid[1]
                WITH FRAME f_seg_simples_mens.

            APPLY "GO" TO SELF.
        END.
END.

IF   glb_cddopcao = "I"   THEN
    ASSIGN seg_nrctrseg = 0
           seg_tpplaseg = 0
           seg_ddvencto = 1
           seg_vlpreseg = 0
           seg_vltotpre = 0
           seg_qtmaxpar = 0
           seg_ddpripag = DAY(glb_dtmvtolt)
           seg_dtinivig = glb_dtmvtolt
           seg_flgclabe = NO
           seg_nmbenvid[1] = ""
           seg_dtfimvig = glb_dtmvtolt + 365
           seg_dsendres = ""
           seg_complend = ""
           seg_nrendere = 0
           seg_nmbairro = ""
           seg_nmcidade = ""
           seg_cdufresd = ""
           seg_nrcepend = 0
           aux_dtinivig = glb_dtmvtolt.

blk_principal:
DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

    DISPLAY seg_nmresseg
            seg_dstipseg
            seg_nrctrseg
            seg_tpplaseg WHEN glb_cddopcao = "A"
            WITH FRAME f_seg_simples.

    UPDATE  seg_nrctrseg 
            seg_tpplaseg 
            WITH FRAME f_seg_simples
            
    EDITING:
        DO WHILE TRUE:
            
            READKEY PAUSE 1.
            
            IF   FRAME-FIELD = "seg_tpplaseg"   AND
                 LASTKEY = KEYCODE("F7")        THEN
                DO:
                     RUN sistema/generico/procedures/b1wgen0033.p
                         PERSISTENT SET h-b1wgen0033.

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
                          INPUT seg_cdsegura,
                          INPUT seg_cdtipseg,
                          INPUT 0,
                          OUTPUT TABLE tt-plano-seg,
                          OUTPUT TABLE tt-erro).

                     DELETE PROCEDURE h-b1wgen0033.
                     
                     OPEN QUERY q_planos 
                                FOR EACH tt-plano-seg WHERE
                                         tt-plano-seg.cdcooper = 
                                                  glb_cdcooper  AND
                                         tt-plano-seg.cdsegura =
                                                  seg_cdsegura  AND
                                         tt-plano-seg.tpseguro =
                                                  seg_cdtipseg  AND
                                         tt-plano-seg.cdsitpsg =
                                                  1 /* ativo */ NO-LOCK
                                BY tt-plano-seg.dsmorada.
                                                          
                     /* para atualizar os campos na frame */
                     APPLY "VALUE-CHANGED" TO b_planos.
                     
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        UPDATE b_planos WITH FRAME f_planos.
                        LEAVE.
                     END.
                     
                     HIDE FRAME f_planos.
                     NEXT.
                 END.
                 
            APPLY LASTKEY.
                    
            LEAVE.
        END.
    END.

    DISPLAY seg_dsendres   
            seg_nrendere
            seg_complend
            seg_nmbairro  
            seg_nrcepend
            seg_nmcidade
            seg_cdufresd WITH FRAME f_seg_simples_mens.

    PAUSE 0.

    blk_dtdebito:
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        IF   seg_tpplaseg > 0   THEN
             DO:

                 RUN sistema/generico/procedures/b1wgen0033.p
                     PERSISTENT SET h-b1wgen0033.

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
                      INPUT seg_cdsegura,
                      INPUT 11,
                      INPUT seg_tpplaseg,
                      OUTPUT TABLE tt-plano-seg,
                      OUTPUT TABLE tt-erro).

                 DELETE PROCEDURE h-b1wgen0033.

                 FIND tt-plano-seg NO-ERROR.

                 IF   AVAILABLE tt-plano-seg THEN
                      DO:              
                          /* Mostra os valores na tela */
                          ASSIGN seg_vlpreseg = IF seg_vlpreseg = 0 THEN
                                                   tt-plano-seg.vlplaseg
                                                ELSE
                                                   seg_vlpreseg
                                 seg_vltotpre = tt-plano-seg.vlplaseg   
                                 aux_vldebseg = tt-plano-seg.vlplaseg.
                             
                          /* Habilita os frames para poder ocultar os campos */

                          VIEW FRAME f_seg_simples_var.
                          PAUSE 0.
                          HIDE seg_ddvencto 
                               seg_qtmaxpar IN FRAME f_seg_simples_var.
                          
                          VIEW FRAME f_seg_simples_mens.
                          DISP seg_vlpreseg WITH FRAME f_seg_simples_mens.

                          DISPLAY seg_ddpripag 
                                   WITH FRAME f_seg_simples_ddpripag.

                          IF NOT tt-plano-seg.flgunica THEN
                              DO:
                                UPDATE seg_ddvencto
                                        WITH FRAME f_seg_simples_ddpripag.
                              END.

                          ASSIGN glb_cdcritic = 0.

                          ASSIGN seg_dtpripag = DATE(MONTH(glb_dtmvtolt),
                                                seg_ddpripag,
                                                YEAR(glb_dtmvtolt)).

                          UPDATE seg_vlpreseg WHEN
                                 tt-plano-seg.vlplaseg = 0
                                 WITH FRAME f_seg_simples_mens
                          EDITING:
                              DO WHILE TRUE:
                                  READKEY PAUSE 1.
                                  IF FRAME-FIELD = "seg_vlpreseg" AND
                                     KEYFUNCTION(LASTKEY) = "END-ERROR" AND
                                    INPUT seg_vlpreseg <> aux_vldebseg THEN
                                      DO:
                                          seg_vlpreseg = aux_vldebseg.
                                          DISPLAY seg_vlpreseg 
                                          WITH FRAME f_seg_simples_mens.

                                          NEXT.
                                      END.

                                      APPLY LASTKEY.     
                                      LEAVE.
                              END.
                          END.

                          DISPLAY seg_dtinivig 
                                  seg_dtfimvig
                              WITH FRAME f_seg_simples_mens.

                          cria_seguro:
                          DO WHILE TRUE:
                              HIDE FRAME f_seg_simples_end_corr.

                              UPDATE seg_flgclabe seg_nmbenvid[1]
                                  WITH FRAME f_seg_simples_mens.
                              
                              DISPLAY seg_nrcepend
                                      seg_dsendres
                                      seg_complend
                                      seg_nrendere
                                      seg_nmbairro
                                      seg_nmcidade
                                      seg_cdufresd
                                  WITH FRAME f_seg_simples_mens.
                             
                              UPDATE seg_nrcepend
                                     seg_dsendres
                                     seg_nrendere
                                     seg_complend
                                  WITH FRAME f_seg_simples_mens
                             
                              EDITING:
                                  READKEY.
                                  HIDE MESSAGE NO-PAUSE.
                                  IF LASTKEY = KEYCODE("F7")  THEN
                                  DO:
                                      IF FRAME-FIELD =
                                         "seg_nrcepend"  THEN DO:
                                          RUN
                                           fontes/zoom_endereco.p 
                                          (INPUT 0,
                                          OUTPUT TABLE
                                            tt-endereco).
                                          FIND FIRST tt-endereco
                                              NO-LOCK NO-ERROR.
                                          IF AVAIL tt-endereco THEN
                                              ASSIGN
                                              seg_nrcepend =
                                               tt-endereco.nrcepend
                                              seg_dsendres =
                                               tt-endereco.dsendere
                                              seg_complend = 
                                               tt-endereco.dscmpend
                                              seg_nmbairro =
                                               tt-endereco.nmbairro
                                              seg_nmcidade =
                                               tt-endereco.nmcidade
                                              seg_cdufresd =
                                               tt-endereco.cdufende.
                          
                                          DISPLAY seg_nrcepend    
                                                  seg_dsendres
                                                  seg_complend
                                                  seg_nmbairro
                                                  seg_nmcidade
                                                  seg_cdufresd
                                            WITH FRAME
                                              f_seg_simples_mens.
                                      END.
                                  END.
                                  ELSE
                                      APPLY LASTKEY.
                              END.

                              RUN sistema/generico/procedures/b1wgen0033.p 
                                  PERSISTENT SET h-b1wgen0033.

                              RUN validar_criacao IN h-b1wgen0033 (INPUT glb_cdcooper,                                 
                                                                   INPUT 0,                                            
                                                                   INPUT 0,                                            
                                                                   INPUT glb_cdoperad,                                 
                                                                   INPUT glb_dtmvtolt,                                 
                                                                   INPUT tel_nrdconta,                                 
                                                                   INPUT 1, /*idseqttl*/                               
                                                                   INPUT 1, /* idorigem */                             
                                                                   INPUT glb_nmdatela,                                 
                                                                   INPUT FALSE,                                        
                                                                   INPUT seg_cdsegura,                                 
                                                                   INPUT seg_ddvencto,                                                                 
                                                                   INPUT seg_dtfimvig,                                  
                                                                   INPUT seg_dtinivig, /* dtiniseg */                   
                                                                   INPUT seg_dtinivig,                                  
                                                                   INPUT seg_nmbenvid[1],                                                       
                                                                   INPUT "", /* nmbenvid2 */                            
                                                                   INPUT "", /* nmbenvid3 */                            
                                                                   INPUT "", /* nmbenvid4 */                            
                                                                   INPUT "", /* nmbenvid5 */                           
                                                                   INPUT seg_nrctrseg,                                  
                                                                   INPUT 4151, /* nrdolote */                           
                                                                   INPUT seg_tpplaseg,                                  
                                                                   INPUT 11, /* tpseguro - casa */                      
                                                                   INPUT 0, /* txpartic1 */                             
                                                                   INPUT 0, /* txpartic3 */                             
                                                                   INPUT 0, /* txpartic4 */                             
                                                                   INPUT 0, /* txpartic5 */                             
                                                                   INPUT 0, /* txpartic6 */                             
                                                                   INPUT seg_vlpreseg,                                                                    
                                                                   INPUT 0, /* vlcapseg */                              
                                                                   INPUT 200, /* Banco/Caixa cdbccxlt */                
                                                                   INPUT STRING(tt-associado.nrcpfcgc),                 
                                                                   INPUT tt-associado.nmprimtl, /*nmdsegur*/                                                                    
                                                                   INPUT seg_nmcidade,
                                                                   INPUT seg_nrcepend,
                                                                   INPUT seg_tpendcor,
                                                                   INPUT 1, /*nrpagina*/
                                                                   INPUT seg_dtnascsg,
                                                                   OUTPUT aux_crawseg,
                                                                   OUTPUT aux_nmdcampo,
                                                                   OUTPUT TABLE tt-erro).

                              DELETE PROCEDURE h-b1wgen0033.
                          
                              IF RETURN-VALUE <> "OK" THEN
                                  DO:
                                      FIND FIRST tt-erro NO-ERROR.
                                      IF AVAIL tt-erro THEN
                                          DO:
                                              IF tt-erro.cdcritic <> 0 THEN DO:
                                                  ASSIGN glb_cdcritic = tt-erro.cdcritic
                                                         glb_dscritic = tt-erro.dscritic.
                                                  
                                              END.
                                              ELSE
                                                  ASSIGN glb_dscritic = tt-erro.dscritic.
                                              
                                              BELL.
                                              MESSAGE glb_dscritic.
                                              PAUSE(3) NO-MESSAGE.
                                              HIDE MESSAGE NO-PAUSE.
                                              glb_cdcritic = 0.
                                               
                                              IF NOT tt-plano-seg.flgunica AND aux_nmdcampo = 'seg_ddvencto' THEN
                                                  NEXT blk_dtdebito.
                                              ELSE
                                              IF aux_nmdcampo = 'seg_nrctrseg' THEN
                                                  NEXT blk_principal.
                                              ELSE
                                              IF aux_nmdcampo = 'seg_nrcepend' THEN
                                                 NEXT cria_seguro.
                                              ELSE 
                                                  NEXT.
                                          END.
                                  END.

                              /* Se nao for a vista, cacula a data do proximo debito */
                              IF   NOT tt-plano-seg.flgunica   AND   seg_qtmaxpar <> 1   THEN
                                   DO:
                                          /* calcula a data para o proximo mes */
                                         RUN fontes/calcdata.p (INPUT DATE(MONTH(glb_dtmvtolt),
                                                                           seg_ddvencto,
                                                                           YEAR(glb_dtmvtolt)),
                                                                INPUT  1,
                                                                INPUT  "M",
                                                                INPUT  seg_ddvencto,
                                                                OUTPUT aux_dtdebito).
                                   END.
                              ELSE
                                   ASSIGN aux_dtdebito = DATE(MONTH(glb_dtmvtolt),
                                                              DAY(seg_dtpripag),
                                                              YEAR(glb_dtmvtolt)).
                                   
                              ASSIGN aux_dtprideb = IF tt-plano-seg.mmpripag > 0 THEN
                                                        aux_dtdebito
                                                    ELSE
                                                        DATE(MONTH(glb_dtmvtolt),
                                                             DAY(seg_dtpripag),
                                                             YEAR(glb_dtmvtolt)).

                              HIDE FRAME f_seg_simples_ddpripag.
                              HIDE FRAME f_seg_simples_mens.
                             
                              DISP seg_tpendcor
                                   seg_dsendres_2
                                   seg_nrendere_2
                                   seg_complend_2
                                   seg_nmbairro_2
                                   seg_nrcepend_2
                                   seg_nmcidade_2
                                   seg_cdufresd_2
                              WITH FRAME f_seg_simples_end_corr.
                             
                              UPDATE seg_tpendcor
                                    WITH FRAME f_seg_simples_end_corr
                              EDITING:
                                  READKEY.
                                  IF KEYFUNCTION(LASTKEY) =
                                      "END-ERROR" THEN
                                      NEXT cria_seguro.

                                  IF KEYFUNCTION(LASTKEY) < 'a' THEN
                                    ASSIGN seg_tpendcor:SCREEN-VALUE IN FRAME f_seg_simples_end_corr
                                        = KEYFUNCTION(LASTKEY).

                                  IF KEYFUNCTION(LASTKEY) =
                                      "RETURN" THEN DO:
                                      IF INPUT seg_tpendcor = 1 OR
                                         INPUT seg_tpendcor = 2 OR
                                         INPUT seg_tpendcor = 3
                                          THEN DO:
                                          APPLY LASTKEY.
                                          RUN carrega_end_cor
                                              (INPUT seg_nrctrseg).

                                          IF RETURN-VALUE <> "OK" THEN DO:
                                             NEXT.
                                          END.
                                      END.    
                                  END.
                                  ELSE
                                      APPLY LASTKEY.
                              END.
                              LEAVE.
                          END. 

                        RUN sistema/generico/procedures/b1wgen0033.p 
                                             PERSISTENT SET h-b1wgen0033.
    
    
                        RUN validar_criacao IN h-b1wgen0033 (INPUT glb_cdcooper,                                 
                                                             INPUT 0,                                            
                                                             INPUT 0,                                            
                                                             INPUT glb_cdoperad,                                 
                                                             INPUT glb_dtmvtolt,                                 
                                                             INPUT tel_nrdconta,                                 
                                                             INPUT 1, /*idseqttl*/                               
                                                             INPUT 1, /* idorigem */                             
                                                             INPUT glb_nmdatela,                                 
                                                             INPUT FALSE,                                        
                                                             INPUT seg_cdsegura,                                 
                                                             INPUT seg_ddvencto,                                                                 
                                                             INPUT seg_dtfimvig,                                  
                                                             INPUT seg_dtinivig, /* dtiniseg */                   
                                                             INPUT seg_dtinivig,                                  
                                                             INPUT seg_nmbenvid[1],                                                       
                                                             INPUT "", /* nmbenvid2 */                            
                                                             INPUT "", /* nmbenvid3 */                            
                                                             INPUT "", /* nmbenvid4 */                            
                                                             INPUT "", /* nmbenvid5 */                           
                                                             INPUT seg_nrctrseg,                                  
                                                             INPUT 4151, /* nrdolote */                           
                                                             INPUT seg_tpplaseg,                                  
                                                             INPUT 11, /* tpseguro - casa */                      
                                                             INPUT 0, /* txpartic1 */                             
                                                             INPUT 0, /* txpartic3 */                             
                                                             INPUT 0, /* txpartic4 */                             
                                                             INPUT 0, /* txpartic5 */                             
                                                             INPUT 0, /* txpartic6 */                             
                                                             INPUT seg_vlpreseg,                                                                    
                                                             INPUT 0, /* vlcapseg */                              
                                                             INPUT 200, /* Banco/Caixa cdbccxlt */                
                                                             INPUT STRING(tt-associado.nrcpfcgc),                 
                                                             INPUT tt-associado.nmprimtl, /*nmdsegur*/                                                                    
                                                             INPUT seg_nmcidade,
                                                             INPUT seg_nrcepend,
                                                             INPUT seg_tpendcor,
                                                             INPUT 2, /*nrpagina*/
                                                             INPUT seg_dtnascsg,
                                                             OUTPUT aux_crawseg,
                                                             OUTPUT aux_nmdcampo,
                                                             OUTPUT TABLE tt-erro).

                        IF RETURN-VALUE <> "OK" THEN
                            DO:
                                FIND FIRST tt-erro NO-ERROR.
                                IF AVAIL tt-erro THEN
                                    DO:
                                        IF tt-erro.cdcritic <> 0 THEN DO:
                                            ASSIGN glb_cdcritic = tt-erro.cdcritic
                                                   glb_dscritic = tt-erro.dscritic.
                                            
                                        END.
                                        ELSE
                                            ASSIGN glb_dscritic = tt-erro.dscritic.
                
                                        BELL.
                                        MESSAGE glb_dscritic.
                                        PAUSE(3) NO-MESSAGE.
                                        HIDE MESSAGE NO-PAUSE.
                                        glb_cdcritic = 0.
                                        NEXT.
                                    END.
                            END.

                        RUN fontes/confirma.p (INPUT "",
                                               OUTPUT aux_confirma).
                
                        IF   aux_confirma <> "S"    THEN
                             DO:
                                 HIDE FRAME f_seg_simples             NO-PAUSE.
                                 HIDE FRAME f_seg_simples_ddpripag    NO-PAUSE.
                                 HIDE FRAME f_seg_simples_ddpagto_car NO-PAUSE.
                                 HIDE FRAME f_seg_simples_mens        NO-PAUSE.
                                 HIDE FRAME f_seg_simples_var         NO-PAUSE.
                                 HIDE FRAME f_seg_simples_end_corr    NO-PAUSE.
                                 RETURN.                 
                             END.
                
                        RUN cria_seguro IN h-b1wgen0033 (INPUT glb_cdcooper,
                                                         INPUT 0,
                                                         INPUT 0,
                                                         INPUT glb_cdoperad,
                                                         INPUT glb_dtmvtolt,
                                                         INPUT tel_nrdconta,
                                                         INPUT 1, /*idseqttl*/
                                                         INPUT 1, /* idorigem */
                                                         INPUT glb_nmdatela,
                                                         INPUT FALSE,
                                                         INPUT 0, /* cdmotcan */
                                                         INPUT seg_cdsegura,
                                                         INPUT 1, /* cdsitseg */
                                                         INPUT "", /* dsgraupr1 */
                                                         INPUT "", /* dsgraupr2 */
                                                         INPUT "", /* dsgraupr3 */
                                                         INPUT "", /* dsgraupr4 */
                                                         INPUT "", /* dsgraupr5 */
                                                         INPUT ?, /* dtaltseg */
                                                         INPUT ?, /* dtcancel */
                                                         INPUT aux_dtdebito,
                                                         INPUT seg_dtfimvig,
                                                         INPUT seg_dtinivig, 
                                                         INPUT seg_dtinivig,
                                                         INPUT aux_dtprideb,
                                                         INPUT ?, /* dtultalt */
                                                         INPUT ?, /* dtultpag */
                                                         INPUT seg_flgclabe,
                                                         INPUT NO, /* flgconve */
                                                         INPUT tt-plano-seg.flgunica,
                                                         INPUT 0, /* indebito */
                                                         INPUT "", /* lsctrant */
                                                         INPUT seg_nmbenvid[1],
                                                         INPUT "", /* nmbenvid2 */
                                                         INPUT "", /* nmbenvid3 */
                                                         INPUT "", /* nmbenvid4 */
                                                         INPUT "", /* nmbenvid5 */
                                                         INPUT 0, /* nrctratu */
                                                         INPUT seg_nrctrseg,
                                                         INPUT 4151, /* nrdolote */
                                                         INPUT aux_qtparcel,
                                                         INPUT 0, /* qtprepag */
                                                         INPUT 0, /* qtprevig */
                                                         INPUT 0, /* tpdpagto */
                                                         INPUT seg_tpendcor,
                                                         INPUT seg_tpplaseg,
                                                         INPUT 11, /* tpseguro - casa */
                                                         INPUT 0, /* txpartic1 */
                                                         INPUT 0, /* txpartic3 */
                                                         INPUT 0, /* txpartic4 */
                                                         INPUT 0, /* txpartic5 */
                                                         INPUT 0, /* txpartic6 */
                                                         INPUT 0, /* vldifseg */
                                                         INPUT seg_vltotpre, /* vlpremio */
                                                         INPUT 0, /* vlprepag */
                                                         INPUT seg_vlpreseg,
                                                         INPUT 0, /* vlcapseg */
                                                         INPUT 200, /* Banco/Caixa cdbccxlt */
                                                         INPUT STRING(tt-associado.nrcpfcgc),
                                                         INPUT tt-associado.nmprimtl, /*nmdsegur*/
                                                         INPUT seg_vltotpre,
                                                         INPUT seg_cdcalcul,
                                                         INPUT seg_vlseguro,
                                                         INPUT seg_dsendres,
                                                         INPUT seg_nrendere,
                                                         INPUT seg_nmbairro,
                                                         INPUT seg_nmcidade,
                                                         INPUT seg_cdufresd,
                                                         INPUT seg_nrcepend,
                                                         INPUT 0, /*cdsexosg*/
                                                         INPUT aux_cdempres, /*cdempres*/
                                                         INPUT seg_dtnascsg,
                                                         INPUT CAPS(seg_complend),
                                                         OUTPUT aux_flgsegur,
                                                         OUTPUT aux_crawseg,
                                                         OUTPUT TABLE tt-erro).
                
                        DELETE PROCEDURE h-b1wgen0033.
                
                        IF RETURN-VALUE <> "OK" THEN
                            DO:
                                FIND FIRST tt-erro NO-ERROR.
                                IF AVAIL tt-erro THEN
                                    DO:
                                        ASSIGN glb_cdcritic = tt-erro.cdcritic
                                               glb_dscritic = tt-erro.dscritic.
                
                                        BELL.
                                        MESSAGE glb_dscritic.
                                        PAUSE(3) NO-MESSAGE.
                                        HIDE MESSAGE NO-PAUSE.
                                        glb_cdcritic = 0.
                                        NEXT.
                                    END.
                            END.
                        /* impressao da autorizacao do debito */
                        RUN fontes/seguro_m.p (INPUT INTEGER(aux_crawseg)).
                        LEAVE.
                    END.
                    ELSE 
                        DO:
                           IF RETURN-VALUE <> "OK"  THEN DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                                IF AVAIL tt-erro   THEN DO:
                                    ASSIGN glb_cdcritic = tt-erro.cdcritic
                                           glb_dscritic = tt-erro.dscritic.
                                    BELL.
                                    MESSAGE glb_dscritic.
                                    LEAVE.
                                END.
                            END.
                        END.
             END.
             ELSE 
                 LEAVE.
                
                
    END.

    /* Limpa os campos */
    ASSIGN seg_ddvencto = 1
           seg_flgclabe = NO
           seg_nmbenvid[1] = ""
           seg_vlpreseg = 0
           seg_qtmaxpar = 0
           seg_ddpripag = DAY(glb_dtmvtolt)
           seg_dtinivig = glb_dtmvtolt
           seg_dtfimvig = glb_dtmvtolt + 365.
END.

HIDE FRAME f_seg_simples.
HIDE FRAME f_seg_simples_mens.
HIDE FRAME f_seg_simples_ddpripag.
HIDE FRAME f_seg_simples_ddpagto_car.
HIDE FRAME f_seg_simples_var.
HIDE FRAME f_seg_simples_end_corr.
/* .......................................................................... */

