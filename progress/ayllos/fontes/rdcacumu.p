/*..............................................................................

   Programa: Fontes/rdcaacumu.p                          
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Elton     
   Data    : Outubro/2007.                   Ultima atualizacao: 11/06/2014
                                                                        
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para consulta e simulacao do acumulo das aplicacoes
               RDCPRE E RDCPOS.

   Alteracoes: 11/03/2008 - Melhorar leitura do craplap para taxas (Magui).

               26/08/2008 - Nao dar erro do progress quando a data de
                            vencimento estiver errada e alterada taxa como 
                            esta no programa fontes/impextrda.p (Gabriel). 

               12/11/2008 - Eliminar handles da BO b1wgen0004.p (David).
               
               28/04/2010 - Utilizar a includes/var_rdcapp2.i (Gabriel). 
               
               11/10/2010 - Utilizar BO da rotina (David).
               
               29/11/2010 - Utilizar BO b1wgen0081.p (Adriano).
                          
               11/06/2014 - Ajustes referente ao projeto captacao (Adriano).
               
..............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0004tt.i }  
{ sistema/generico/includes/b1wgen0081tt.i }

DEF  INPUT PARAM par_nrdconta AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_nraplica AS INTE                                  NO-UNDO.
DEF  INPUT PARAM par_idtipapl AS CHAR                                  NO-UNDO.

DEF VAR tel_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR tel_dsaplica AS CHAR                                           NO-UNDO.

DEF VAR tel_nrdconta LIKE craprda.nrdconta                             NO-UNDO.
DEF VAR tel_nraplica LIKE craprda.nraplica                             NO-UNDO.
DEF VAR tel_tpaplica LIKE craprda.tpaplica                             NO-UNDO.
DEF VAR tel_dtmvtcon LIKE craprda.dtmvtolt                             NO-UNDO.
DEF VAR tel_txaplica LIKE craplap.txaplica                             NO-UNDO.
DEF VAR tel_txaplmes LIKE craplap.txaplmes                             NO-UNDO.
DEF VAR tel_vlsdrdca LIKE craprda.vlsdrdca                             NO-UNDO.
DEF VAR tel_qtdiacar LIKE craprda.qtdiaapl                             NO-UNDO.
DEF VAR tel_dtcarenc AS DATE                                           NO-UNDO.

DEF VAR tel_qtdiaapl AS INTE                                           NO-UNDO.

DEF VAR tel_vlstotal AS DECI                                           NO-UNDO.
DEF VAR tel_vlaplica AS DECI                                           NO-UNDO.

DEF VAR tel_dtvencto AS DATE                                           NO-UNDO.

DEF VAR aux_desdhelp AS CHAR                                           NO-UNDO.

DEF VAR aux_tpaplrdc AS INTE                                           NO-UNDO.
DEF VAR aux_cdperapl AS INTE                                           NO-UNDO.
DEF VAR aux_qtdiaapl AS INTE                                           NO-UNDO.
DEF VAR aux_dtvencto AS DATE                                           NO-UNDO.
DEF VAR aux_dsaplica AS CHAR                                           NO-UNDO.

DEF VAR h-b1wgen0081 AS HANDLE                                         NO-UNDO.

DEF QUERY q_acumula  FOR tt-acumula.
DEF QUERY q_periodos FOR tt-carencia-aplicacao.

DEF BROWSE b_acumula QUERY q_acumula
    DISP tt-acumula.nraplica LABEL "Numero"   
         SPACE(2)
         tt-acumula.tpaplica LABEL "Tipo" 
         SPACE(2)            
         tt-acumula.vlsdrdca LABEL "Saldo na Data" 
         WITH 4 DOWN WIDTH 50 NO-BOX NO-LABEL.

DEF BROWSE b_periodos QUERY q_periodos
   DISP tt-carencia-aplicacao.cdperapl LABEL "Periodo"  FORMAT "z9"   
        tt-carencia-aplicacao.qtdiaini LABEL "Inicio"   FORMAT "zzz9" 
        tt-carencia-aplicacao.qtdiafim LABEL "Fim"      FORMAT "zzz9" 
        tt-carencia-aplicacao.qtdiacar LABEL "Carencia" FORMAT "zz9"  
        WITH NO-LABEL NO-BOX OVERLAY 6 DOWN.

FORM SPACE(10) 
     b_acumula
     WITH FRAME f_acumula ROW 14 NO-BOX OVERLAY WIDTH 50 CENTERED.

FORM b_periodos
     HELP "Use as SETAS para navegar e <F4> para sair" 
     WITH CENTERED OVERLAY ROW 10 FRAME f_periodos TITLE "Periodos".

FORM SKIP(1)
     tel_cddopcao LABEL "Opcao" FORMAT "!(1)"
                  HELP "Informe 'C' para consulta ou 'S' para simulacao."
                  VALIDATE(INPUT tel_cddopcao = "C" OR INPUT tel_cddopcao = "S",
                           "014 - Opcao errada.")
     SPACE(2)
     tel_nrdconta LABEL "Conta/DV"
     SPACE(1)
     tel_nraplica LABEL "Aplicacao"
     "-"
     tel_dsaplica NO-LABEL FORMAT "x(6)"
     tel_dtmvtcon LABEL "Dt.Apl."
     SKIP
     SPACE(57)
     tel_dtvencto LABEL "Dt.Vencto" FORMAT "99/99/9999"
     SKIP
     tel_vlaplica LABEL "Vlr.Apl."  FORMAT "zz,zzz,zz9.99"
     SPACE(3)
     "Taxas =>"
     tel_txaplica LABEL "Contrato"
     SPACE(3)
     tel_txaplmes LABEL "Minima"
     SKIP
     SPACE(26)
     tel_vlsdrdca LABEL "Saldo"
     SKIP(8)
     WITH FRAME f_dados SIDE-LABELS OVERLAY ROW 7 WIDTH 80 
          TITLE " Verifica Saldos Acumulados ".

FORM "TOTAL DE ====> "
     tel_vlstotal NO-LABEL FORMAT "zz,zzz,zz9.99"
     WITH FRAME f_total NO-BOX OVERLAY ROW 20 COLUMN 28.

FORM tel_cddopcao LABEL "Opcao" FORMAT "!(1)"  
     SPACE(2)
     tel_nrdconta LABEL "Conta/DV"     
     tel_tpaplica LABEL "Tipo Aplicacao"
     "-"
     tel_dsaplica NO-LABEL
     WITH FRAME f_tipo_apli SIDE-LABELS NO-BOX OVERLAY ROW 9 COLUMN 2 WIDTH 78.

FORM SPACE(10)
     tel_vlaplica LABEL "Valor" FORMAT "zz,zzz,zz9.99"
         HELP "Informe o valor da aplicacao."
     SPACE(12)
     tel_qtdiaapl LABEL "Dias"  FORMAT "zzz9"
         HELP "Quantos dias a aplicacao pode ficar"
     SPACE(5)
     tel_dtmvtcon LABEL "Dt.Vencto"
         HELP "Informe a data de vencimento da aplicacao."
     SKIP
     tel_qtdiacar LABEL "Carencia" FORMAT "zzz9"
         HELP "Pressione <F7> para selecionar a carencia"
     "Taxas =>"
     tel_txaplica LABEL "Contrato"
     SPACE(4)
     tel_txaplmes LABEL "Minima"
     SKIP
     SPACE(26)
     tel_vlsdrdca LABEL "Saldo"
     SKIP(1)
     WITH FRAME f_simula_pre SIDE-LABELS NO-BOX OVERLAY ROW 10 COLUMN 2 WIDTH 78.

FORM SPACE(10)
     tel_vlaplica LABEL "Valor" FORMAT "zz,zzz,zz9.99"
         HELP "Informe o valor da aplicacao."
     SPACE(2)
     tel_qtdiacar LABEL "Carencia" FORMAT "zzz9"
     tel_dtcarenc LABEL "Data Carencia" FORMAT "99/99/9999"
     SKIP
     tel_dtmvtcon LABEL "Dt.Vencto" AT 52
         HELP "Informe a data de vencimento da aplicacao."
     SKIP
     "Taxas =>"
     tel_txaplica LABEL "Contrato"
     SPACE(4)
     tel_txaplmes LABEL "Minima"
     SKIP
     SPACE(26)
     tel_vlsdrdca LABEL "Saldo"
     SKIP(1)
     WITH FRAME f_simula_pos SIDE-LABELS NO-BOX OVERLAY ROW 10 COLUMN 2 WIDTH 78.

ON LEAVE OF tel_tpaplica IN FRAME f_tipo_apli DO:

   HIDE MESSAGE NO-PAUSE.

   DO WITH FRAME f_tipo_apli:

      ASSIGN tel_tpaplica.

   END.

   IF NOT VALID-HANDLE(h-b1wgen0081) THEN
      RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.

   RUN validar-tipo-aplicacao IN h-b1wgen0081 (INPUT glb_cdcooper,
                                               INPUT 0,
                                               INPUT 0,
                                               INPUT glb_cdoperad,
                                               INPUT glb_nmdatela,
                                               INPUT 1,
                                               INPUT par_nrdconta,
                                               INPUT 1,
                                               INPUT tel_tpaplica,
                                               INPUT TRUE,
                                              OUTPUT aux_tpaplrdc,
                                              OUTPUT TABLE tt-erro).

   IF VALID-HANDLE(h-b1wgen0081) THEN
      DELETE PROCEDURE h-b1wgen0081.

   IF RETURN-VALUE = "NOK"  THEN
      DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF AVAIL tt-erro  THEN
            DO:
                BELL.
                MESSAGE tt-erro.dscritic.
            END.

         RETURN NO-APPLY.

      END.

   FIND tt-tipo-aplicacao WHERE tt-tipo-aplicacao.tpaplrdc = aux_tpaplrdc
                                NO-LOCK NO-ERROR.

   ASSIGN tel_dsaplica = tt-tipo-aplicacao.dsaplica.

   DISPLAY tel_dsaplica 
           WITH FRAME f_tipo_apli.
   
   IF aux_tpaplrdc = 1  THEN  /** RDCPRE **/
      DO:
         ASSIGN tel_qtdiacar = 0.
         DISPLAY "" @ tel_qtdiacar 
                 WITH FRAME f_simula_pre.

      END.
    
END.

ON RETURN OF tel_vlaplica IN FRAME f_simula_pos DO:
    
   HIDE MESSAGE NO-PAUSE.
   
   RUN zoom_carencia.

   IF RETURN-VALUE = "NOK"  THEN
      RETURN NO-APPLY.
     
   DO WITH FRAME f_simula_pos:
       
      ASSIGN tel_vlaplica.

   END.    

   IF NOT VALID-HANDLE(h-b1wgen0081) THEN
      RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
   
   MESSAGE "Calculando data de vencimento. Aguarde ...".

   RUN calcula-permanencia-resgate IN h-b1wgen0081
                                  (INPUT glb_cdcooper,
                                   INPUT 0, /*cdagenci*/
                                   INPUT 0, /*nrdcaixa*/
                                   INPUT glb_cdoperad,   
                                   INPUT glb_nmdatela,
                                   INPUT 1, /*idorigem - ayllos*/
                                   INPUT tel_nrdconta,
                                   INPUT 1, /*idseqttl*/
                                   INPUT tel_tpaplica,
                                   INPUT glb_dtmvtolt,
                                   INPUT TRUE, /*flggerlog*/
                                   INPUT tel_qtdiacar, 
                                   INPUT-OUTPUT aux_qtdiaapl, 
                                   INPUT-OUTPUT tel_dtmvtcon,
                                  OUTPUT TABLE tt-erro).

   HIDE MESSAGE NO-PAUSE.

   IF VALID-HANDLE(h-b1wgen0081) THEN
      DELETE PROCEDURE h-b1wgen0081.                        

   IF RETURN-VALUE = "NOK"  THEN
      DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
         IF AVAIL tt-erro  THEN
            DO:
                BELL.
                MESSAGE tt-erro.dscritic.
            END.
     
         RETURN NO-APPLY.

      END.
   
   ASSIGN aux_dtvencto = tel_dtmvtcon.

   DISP tel_dtmvtcon 
        WITH FRAME f_simula_pos.
  
END.                          

ON RETURN OF tel_dtmvtcon IN FRAME f_simula_pos DO:

   DO WITH FRAME f_simula_pos.

      ASSIGN tel_dtmvtcon NO-ERROR.

   END.

   IF ERROR-STATUS:ERROR   THEN
      RETURN NO-APPLY.
   
   HIDE MESSAGE NO-PAUSE.
           
   IF NOT VALID-HANDLE(h-b1wgen0081) THEN
      RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.
                    
   ASSIGN aux_qtdiaapl = 0.
   
   RUN calcula-permanencia-resgate IN h-b1wgen0081
                                  (INPUT glb_cdcooper,
                                   INPUT 0, /*cdagenci*/
                                   INPUT 0, /*nrdcaixa*/
                                   INPUT glb_cdoperad,   
                                   INPUT glb_nmdatela,
                                   INPUT 1, /*idorigem - ayllos*/
                                   INPUT tel_nrdconta,
                                   INPUT 1, /*idseqttl*/
                                   INPUT tel_tpaplica,
                                   INPUT glb_dtmvtolt,
                                   INPUT TRUE, /*flgerlog*/
                                   INPUT tel_qtdiacar, 
                                   INPUT-OUTPUT aux_qtdiaapl,
                                   INPUT-OUTPUT tel_dtmvtcon,
                                  OUTPUT TABLE tt-erro).
                                  
   IF VALID-HANDLE(h-b1wgen0081) THEN
      DELETE PROCEDURE h-b1wgen0081. 

   IF RETURN-VALUE = "NOK"  THEN
      DO: 
         ASSIGN tel_dtmvtcon = aux_dtvencto.

         DISPLAY tel_dtmvtcon WITH FRAME f_simula_pos.

         FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
         IF AVAIL tt-erro  THEN
            DO: 
                BELL.
                MESSAGE tt-erro.dscritic.
            END.
     
         RETURN NO-APPLY.

      END.

   DISPLAY tel_dtmvtcon 
           WITH FRAME f_simula_pos.

END.

ON LEAVE OF tel_qtdiaapl IN FRAME f_simula_pre DO:
            
   HIDE MESSAGE NO-PAUSE.

   DO WITH FRAME f_simula_pre:

      ASSIGN tel_qtdiaapl 
             tel_dtmvtcon.

   END.
   
   IF tel_qtdiaapl > 0 OR tel_dtmvtcon <> ?  THEN
      DO:
         IF NOT VALID-HANDLE(h-b1wgen0081) THEN
            RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT 
                SET h-b1wgen0081.
   
         RUN calcula-permanencia-resgate IN h-b1wgen0081
                                        (INPUT glb_cdcooper,
                                         INPUT 0, /*cdagenci*/
                                         INPUT 0, /*nrdcaixa*/
                                         INPUT glb_cdoperad,   
                                         INPUT glb_nmdatela,
                                         INPUT 1, /*idorigem - ayllos*/
                                         INPUT par_nrdconta,
                                         INPUT 1, /*idseqttl*/
                                         INPUT tel_tpaplica,
                                         INPUT glb_dtmvtolt,
                                         INPUT TRUE, /*flgerlog*/
                                         INPUT 0, /*qtdiacar*/
                                        INPUT-OUTPUT tel_qtdiaapl,
                                        INPUT-OUTPUT tel_dtmvtcon,
                                        OUTPUT TABLE tt-erro).
                                        
         IF VALID-HANDLE(h-b1wgen0081) THEN
            DELETE PROCEDURE h-b1wgen0081. 
         
         IF RETURN-VALUE = "NOK"  THEN
            DO:
               FIND FIRST tt-erro NO-LOCK NO-ERROR.
              
               IF AVAIL tt-erro  THEN
                  DO:
                      BELL.
                      MESSAGE tt-erro.dscritic.
                  END.
           
               RETURN NO-APPLY.
            END.
         
         DISPLAY tel_qtdiaapl 
                 tel_dtmvtcon 
                 WITH FRAME f_simula_pre.

      END.
    
END.

ON LEAVE OF tel_dtmvtcon IN FRAME f_simula_pre DO:
    
   DO WITH FRAME f_simula_pre:

      ASSIGN tel_qtdiaapl 
             tel_dtmvtcon 
             tel_qtdiacar NO-ERROR.

   END.

   IF ERROR-STATUS:ERROR   THEN
      RETURN NO-APPLY.
   
   HIDE MESSAGE NO-PAUSE.
           
   IF NOT VALID-HANDLE(h-b1wgen0081) THEN
      RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT 
          SET h-b1wgen0081.
   
   RUN calcula-permanencia-resgate IN h-b1wgen0081
                                  (INPUT glb_cdcooper,
                                   INPUT 0, /*cdagenci*/
                                   INPUT 0, /*nrdcaixa*/
                                   INPUT glb_cdoperad,   
                                   INPUT glb_nmdatela,
                                   INPUT 1, /*idorigem - ayllos*/
                                   INPUT par_nrdconta,
                                   INPUT 1, /*idseqttl*/
                                   INPUT tel_tpaplica,
                                   INPUT glb_dtmvtolt,
                                   INPUT TRUE, /*flgerlog*/
                                   INPUT 0, /*qtdiacar*/
                                   INPUT-OUTPUT tel_qtdiaapl,
                                   INPUT-OUTPUT tel_dtmvtcon,
                                  OUTPUT TABLE tt-erro).
                                  
   IF VALID-HANDLE(h-b1wgen0081) THEN
      DELETE PROCEDURE h-b1wgen0081. 
   
   IF RETURN-VALUE = "NOK"  THEN
      DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
         IF AVAIL tt-erro  THEN
            DO:
                BELL.
                MESSAGE tt-erro.dscritic.
            END.
     
         RETURN NO-APPLY.
      END.
   
   DISPLAY tel_qtdiaapl 
           tel_dtmvtcon 
           WITH FRAME f_simula_pre.

   RUN zoom_carencia.

   IF RETURN-VALUE = "NOK"  THEN
      RETURN NO-APPLY.
   
END.

ON RETURN OF b_periodos IN FRAME f_periodos DO:   

   ASSIGN tel_qtdiacar = tt-carencia-aplicacao.qtdiacar
          tel_dtcarenc = tt-carencia-aplicacao.dtcarenc
          aux_cdperapl = tt-carencia-aplicacao.cdperapl
          aux_qtdiaapl = tt-carencia-aplicacao.qtdiafim.

   DISPLAY tel_qtdiacar 
           tel_dtcarenc
           WITH FRAME f_simula_pos.
     
   APPLY "GO".
        
END.

ASSIGN tel_cddopcao = "C".

DO WHILE TRUE:

   CLEAR FRAME f_dados.
   CLEAR FRAME f_simula_pre.
   CLEAR FRAME f_total.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_cddopcao WITH FRAME f_dados.
      LEAVE.

   END. /** Fim do DO WHILE TRUE **/

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
      DO:
          HIDE FRAME f_dados NO-PAUSE.
          HIDE MESSAGE NO-PAUSE.
          LEAVE.
      END.

   IF tel_cddopcao = "C"  THEN
      DO:
         IF NOT VALID-HANDLE(h-b1wgen0081) THEN
            RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT 
                SET h-b1wgen0081.
         
         RUN consultar-saldo-acumulado IN h-b1wgen0081 
                                      (INPUT glb_cdcooper,
                                       INPUT 0, /*cdagenci*/
                                       INPUT 0, /*nrdcaixa*/
                                       INPUT glb_cdoperad,
                                       INPUT glb_nmdatela,
                                       INPUT 1, /*idorigem - ayllos*/
                                       INPUT par_nrdconta,
                                       INPUT 1, /*idseqttl*/
                                       INPUT par_nraplica,
                                       INPUT glb_dtmvtolt,
                                       INPUT TRUE, /*flgerlog*/
                                       INPUT par_idtipapl,
                                      OUTPUT TABLE tt-dados-acumulo,
                                      OUTPUT TABLE tt-acumula,
                                      OUTPUT TABLE tt-erro).

         IF VALID-HANDLE(h-b1wgen0081) THEN
            DELETE PROCEDURE h-b1wgen0081.

         IF RETURN-VALUE = "NOK"  THEN
            DO:
               FIND FIRST tt-erro NO-LOCK NO-ERROR.

               IF AVAILABLE tt-erro  THEN
                  DO:
                      BELL.
                      MESSAGE tt-erro.dscritic.
                  END.

               NEXT.
            END.

         FIND FIRST tt-dados-acumulo NO-LOCK NO-ERROR.

         IF NOT AVAILABLE tt-dados-acumulo  THEN
            DO:
                BELL.
                MESSAGE "Registro de acumulo nao encontrado.".
                NEXT.
            END.

         ASSIGN tel_nrdconta = tt-dados-acumulo.nrdconta
                tel_nraplica = tt-dados-acumulo.nraplica
                tel_dsaplica = tt-dados-acumulo.dsaplica
                tel_dtmvtcon = tt-dados-acumulo.dtmvtolt
                tel_dtvencto = tt-dados-acumulo.dtvencto
                tel_vlaplica = tt-dados-acumulo.vlaplica
                tel_txaplica = tt-dados-acumulo.txaplica
                tel_txaplmes = tt-dados-acumulo.txaplmes
                tel_vlsdrdca = tt-dados-acumulo.vlsldrdc
                tel_vlstotal = tt-dados-acumulo.vlstotal. 
                     
         DISPLAY tel_nrdconta  tel_nraplica
                 tel_dsaplica  tel_dtmvtcon  
                 tel_dtvencto  tel_vlaplica  
                 tel_txaplica  tel_txaplmes  
                 tel_vlsdrdca  WITH FRAME f_dados.

         PAUSE(0).
                      
         DISPLAY tel_vlstotal 
                 WITH FRAME f_total.

         OPEN QUERY q_acumula FOR EACH tt-acumula NO-LOCK.

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            UPDATE b_acumula WITH FRAME f_acumula.
            LEAVE.

         END. /** Fim do DO WHILE TRUE **/

         HIDE FRAME f_total   NO-PAUSE.
         HIDE FRAME f_acumula NO-PAUSE.

      END.
   ELSE
   IF tel_cddopcao = "S"  THEN
      DO:
         IF NOT VALID-HANDLE(h-b1wgen0081) THEN
            RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT
                SET h-b1wgen0081.

         RUN obtem-tipos-aplicacao IN h-b1wgen0081 
                                  (INPUT glb_cdcooper,
                                   INPUT 0, /*cdagenci*/
                                   INPUT 0, /*nrdcaixa*/
                                   INPUT glb_cdoperad,
                                   INPUT glb_nmdatela,
                                   INPUT 1, /*idorigem - ayllos*/
                                   INPUT par_nrdconta,
                                   INPUT 1, /*idseqttl*/
                                   INPUT TRUE, /*flgerlog*/
                                  OUTPUT TABLE tt-tipo-aplicacao,
                                  OUTPUT TABLE tt-erro).

         IF VALID-HANDLE(h-b1wgen0081) THEN
            DELETE PROCEDURE h-b1wgen0081.

         IF RETURN-VALUE = "NOK"  THEN
            DO:
               FIND FIRST tt-erro NO-LOCK NO-ERROR.

               IF AVAILABLE tt-erro  THEN
                  DO:
                      BELL.
                      MESSAGE tt-erro.dscritic.
                  END.

               NEXT.
            END.

         ASSIGN aux_desdhelp = "".

         FOR EACH tt-tipo-aplicacao NO-LOCK:

             IF  aux_desdhelp = ""  THEN
                 ASSIGN aux_desdhelp = "Informe o tipo da aplicacao: " +
                                       STRING(tt-tipo-aplicacao.tpaplica) + 
                                       "-" + tt-tipo-aplicacao.dsaplica.
             ELSE
                 ASSIGN aux_desdhelp = aux_desdhelp + "," + 
                                       STRING(tt-tipo-aplicacao.tpaplica) + 
                                       "-" + tt-tipo-aplicacao.dsaplica.

         END. /** Fim do FOR EACH tt-tipo-aplicacao **/

         ASSIGN tel_tpaplica:HELP = aux_desdhelp.

         ASSIGN tel_nrdconta = par_nrdconta
                tel_tpaplica = 0
                tel_vlaplica = 0
                tel_qtdiaapl = 0
                tel_dtmvtcon = ?
                tel_qtdiacar = 0
                aux_tpaplrdc = 0
                aux_cdperapl = 0.

         DISPLAY tel_cddopcao 
                 tel_nrdconta 
                 WITH FRAME f_tipo_apli.
                                       
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            UPDATE tel_tpaplica WITH FRAME f_tipo_apli.
            LEAVE.

         END.

         IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
            DO:
                HIDE FRAME f_tipo_apli NO-PAUSE.
                NEXT.
            END.
                                         
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
            IF aux_tpaplrdc = 1  THEN
               UPDATE tel_vlaplica 
                      tel_qtdiaapl 
                      tel_dtmvtcon 
                      WITH FRAME f_simula_pre.
            ELSE                          
               UPDATE tel_vlaplica 
                      tel_dtmvtcon 
                      WITH FRAME f_simula_pos
                        
            EDITING:
                
                READKEY.
               
                IF FRAME-FIELD = "tel_vlaplica"  THEN
                   DO:
                      IF FRAME-FIELD = "tel_vlaplica"  THEN
                         DO:       
                            IF LASTKEY = KEYCODE(".")  THEN
                               APPLY 44.
                            ELSE
                               APPLY LASTKEY.
                         END.
                      ELSE
                      IF KEYFUNCTION(LASTKEY) = "CURSOR-DOWN"   OR
                         KEYFUNCTION(LASTKEY) = "CURSOR-UP"     OR
                         KEYFUNCTION(LASTKEY) = "CURSOR-LEFT"   OR
                         KEYFUNCTION(LASTKEY) = "CURSOR-RIGHT"  OR
                         KEYFUNCTION(LASTKEY) = "RETURN"        OR
                         KEYFUNCTION(LASTKEY) = "BACK-TAB"      OR
                         KEYFUNCTION(LASTKEY) = "TAB"           OR
                         KEYFUNCTION(LASTKEY) = "GO"            OR 
                         KEYFUNCTION(LASTKEY) = "END-ERROR"     THEN
                         APPLY LASTKEY.
                   END.    
                ELSE
                   APPLY LASTKEY.
                
            END. /** Fim do EDITING **/
            
            IF NOT VALID-HANDLE(h-b1wgen0081) THEN
               RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT
                   SET h-b1wgen0081.
            
            MESSAGE "Realizando simulacao. Aguarde ...".

            RUN simular-saldo-acumulado IN h-b1wgen0081
                                       (INPUT glb_cdcooper,
                                        INPUT 0, /*cdagenci*/
                                        INPUT 0, /*nrdcaixa*/
                                        INPUT glb_cdoperad,
                                        INPUT glb_nmdatela,
                                        INPUT 1, /*idorigem - ayllos*/
                                        INPUT par_nrdconta,
                                        INPUT 1, /*idseqttl*/
                                        INPUT tel_tpaplica,
                                        INPUT tel_dtmvtcon,
                                        INPUT tel_vlaplica,
                                        INPUT aux_cdperapl,
                                        INPUT glb_dtmvtolt,
                                        INPUT glb_cdprogra,
                                        INPUT TRUE, /*flgerlog*/
                                       OUTPUT TABLE tt-dados-acumulo,
                                       OUTPUT TABLE tt-acumula,
                                       OUTPUT TABLE tt-erro).

            IF VALID-HANDLE(h-b1wgen0081) THEN
               DELETE PROCEDURE h-b1wgen0081.

            HIDE MESSAGE NO-PAUSE.

            IF RETURN-VALUE = "NOK"  THEN
               DO:                       
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.
                      
                  IF AVAILABLE tt-erro  THEN
                     DO:
                         BELL.   
                         MESSAGE tt-erro.dscritic.
                     END.    
                  
                  NEXT.
               END.

            FIND FIRST tt-dados-acumulo NO-LOCK NO-ERROR.

            IF NOT AVAILABLE tt-dados-acumulo  THEN
               DO:
                   BELL.
                   MESSAGE "Registro de acumulo nao encontrado.".
                   NEXT.
               END.
   
            ASSIGN tel_txaplica = tt-dados-acumulo.txaplica
                   tel_txaplmes = tt-dados-acumulo.txaplmes
                   tel_vlstotal = tt-dados-acumulo.vlstotal. 
                 
            /*RDCPRE*/
            IF tel_tpaplica = 7 THEN
               DISPLAY tel_txaplica 
                       tel_txaplmes 
                       WITH FRAME f_simula_pre.
            ELSE
               DISPLAY tel_txaplica 
                       tel_txaplmes 
                       WITH FRAME f_simula_pos.
           
            PAUSE(0).
                     
            DISPLAY tel_vlstotal 
                    WITH FRAME f_total.
   
            OPEN QUERY q_acumula FOR EACH tt-acumula NO-LOCK.
   
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
               UPDATE b_acumula WITH FRAME f_acumula.
               LEAVE.
   
            END. /** Fim do DO WHILE TRUE **/
   
            HIDE FRAME f_total   NO-PAUSE.
            HIDE FRAME f_acumula NO-PAUSE.
            HIDE FRAME f_simula_pre  NO-PAUSE.
            HIDE FRAME f_simula_pos  NO-PAUSE.
   
            LEAVE.
           
         END. /** Fim  do DO WHILE TRUE **/

         IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
            DO:
               HIDE FRAME f_simula_pre NO-PAUSE.
               HIDE FRAME f_simula_pos NO-PAUSE.
            END.

      END.

END. /** Fim do DO WHILE TRUE **/

/*............................................................................*/

PROCEDURE zoom_carencia:
   
   IF NOT VALID-HANDLE(h-b1wgen0081) THEN
      RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT SET h-b1wgen0081.

   RUN obtem-dias-carencia IN h-b1wgen0081
                           (INPUT glb_cdcooper,
                            INPUT 0, /*cdagenci*/
                            INPUT 0, /*nrdcaixa*/
                            INPUT glb_cdoperad,
                            INPUT glb_nmdatela,
                            INPUT 1, /*idorigem - ayllos*/
                            INPUT glb_dtmvtolt,
                            INPUT par_nrdconta,
                            INPUT 1, /*idseqttl*/
                            INPUT tel_tpaplica,
                            INPUT tel_qtdiaapl,
                            INPUT tel_qtdiacar,
                            INPUT FALSE, /** Somente validacao **/
                            INPUT FALSE, /** Nao gera LOG      **/
                           OUTPUT TABLE tt-carencia-aplicacao,
                           OUTPUT TABLE tt-erro).

   IF VALID-HANDLE(h-b1wgen0081) THEN
      DELETE PROCEDURE h-b1wgen0081.

   IF RETURN-VALUE = "NOK"  THEN
      DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF AVAILABLE tt-erro  THEN
            DO:
                BELL.
                MESSAGE tt-erro.dscritic.
            END.
         
         RETURN "NOK".
      END.

   OPEN QUERY q_periodos FOR EACH tt-carencia-aplicacao NO-LOCK 
                                  BY tt-carencia-aplicacao.qtdiacar.
   
   GET FIRST q_periodos NO-LOCK.

   ASSIGN tel_qtdiacar = tt-carencia-aplicacao.qtdiacar
          aux_cdperapl = tt-carencia-aplicacao.cdperapl.
   
   IF aux_tpaplrdc = 1  THEN  /** RDCPRE **/
      RETURN "OK".
       
   DISPLAY tel_qtdiacar 
           WITH FRAME f_simula_pos.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      PAUSE(0).
      UPDATE b_periodos WITH FRAME f_periodos.
      LEAVE.

   END. /** Fim do DO WHILE TRUE **/
           
   HIDE FRAME f_periodos NO-PAUSE.
       
   RETURN "OK".

END PROCEDURE.  

/*............................................................................*/
