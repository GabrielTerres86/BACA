/* ..........................................................................

   Programa: fontes/dirfs.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Julio
   Data    : Fevereiro/2005                    Ultima atualizacao: 12/09/2006 

   Dados referentes ao programa:

   Frequencia: Ayllos.
   Objetivo  : Executada a partir da tela DIRF. 
               Tela para visualizacao do status do processo DIRF.

   Alteracoes: 27/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               12/09/2006 - Alteracao nos helps dos campos da tela (Elton).

............................................................................ */

{ includes/var_online.i }

DEF   VAR tel_nranocal   LIKE crapdrf.nranocal                        NO-UNDO.
DEF   VAR tel_flarqint   AS LOGICAL FORMAT "INTEGRADO/NAO INTEGRADO"  NO-UNDO.
DEF   VAR tel_nrlandig   AS INTEGER                                   NO-UNDO.
DEF   VAR tel_dtgerarq   LIKE crapdrf.dtmvtolt                        NO-UNDO.
DEF   VAR tel_flsitdrf   AS LOGICAL FORMAT "LIBERADA/BLOQUEADA"       NO-UNDO.
DEF   VAR tel_qtlanint   AS INTEGER                                   NO-UNDO.
DEF   VAR tel_qtlanapl   AS INTEGER                                   NO-UNDO.

DEF   VAR aux_confirma   AS CHAR    FORMAT "!(1)"                     NO-UNDO.

FORM SKIP(2)
     tel_nranocal  AT 19  LABEL "Ano Calendario"
                      HELP 'Informe o ano a ser consultado ou "F7" para liberar manutencao.'
                          VALIDATE(CAN-FIND(FIRST crapdrf WHERE 
                                   crapdrf.cdcooper = glb_cdcooper AND
                                   crapdrf.nranocal = tel_nranocal NO-LOCK), 
                          "Nao existem dados para o ano calendario informado!")
     SKIP(1)
     tel_qtlanapl  AT 02 LABEL "Total Lanc. Aplicacoes (Ayllos)"
     SKIP(1)
     tel_flarqint  AT 12 LABEL "Integracao de Arquivo"
     "->" tel_qtlanint FORMAT "zz,zz9" "Lancamentos"
     SKIP(1)
     tel_nrlandig  AT 10 LABEL "Qtd. de dados digitados"
     SKIP(1)
     tel_dtgerarq  AT 16 LABEL "Arquivo Gerado em"
     SKIP(1)      
     tel_flsitdrf  AT 17 LABEL "Situacao de Dirf"
     SKIP(2)
     WITH WIDTH 78 OVERLAY ROW 5 CENTERED NO-LABELS SIDE-LABELS 
          TITLE "STATUS DIRF" FRAME f_status.

ASSIGN glb_cddopcao = "S".

{ includes/acesso.i }

ON "F7" OF tel_nranocal DO:

   FIND crapdrf WHERE crapdrf.cdcooper = glb_cdcooper        AND
                      crapdrf.nranocal = INPUT tel_nranocal  AND
                      crapdrf.tpregist = 1                  
                      EXCLUSIVE-LOCK NO-ERROR.

   IF   AVAILABLE crapdrf   THEN
        DO:
            IF   TRIM(crapdrf.dsobserv) <> ""   THEN
                 DO:
                     aux_confirma = "N".
                     MESSAGE COLOR NORMAL 
                           "Existe arquivo gerado para DIRF" 
                           INPUT tel_nranocal
                      ", liberar os dados para manutencao ?"
                     UPDATE aux_confirma.
                     
                     IF   aux_confirma = "S"   THEN
                          DO:
                              ASSIGN crapdrf.dsobserv = ""
                                     tel_flsitdrf     = TRUE.
                              
                              DISPLAY tel_flsitdrf WITH FRAME f_status.
                          END.
                 END.
        END.
   ELSE
        MESSAGE "A manutencao de dados para DIRF" INPUT tel_nranocal 
                "ja esta liberada!" VIEW-AS ALERT-BOX.        
END.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   UPDATE tel_nranocal WITH FRAME f_status.

   ASSIGN tel_nrlandig = 0
          tel_qtlanint = 0
          tel_qtlanapl = 0.

   FOR EACH crapdrf WHERE crapdrf.cdcooper = glb_cdcooper   AND
                          crapdrf.nranocal = tel_nranocal   AND
                          crapdrf.tpregist = 2              NO-LOCK:

       IF   crapdrf.tporireg = 1   THEN
            tel_qtlanapl = tel_qtlanapl + 1.
       ELSE
       IF   crapdrf.tporireg = 2   THEN
            tel_nrlandig = tel_nrlandig + 1.
       ELSE
       IF   crapdrf.tporireg = 3   THEN
            tel_qtlanint = tel_qtlanint + 1.
   END.

   ASSIGN tel_flarqint = tel_qtlanint > 0.

   FIND crapdrf WHERE crapdrf.cdcooper = glb_cdcooper   AND
                      crapdrf.nranocal = tel_nranocal   AND
                      crapdrf.tpregist = 1              NO-LOCK NO-ERROR.

   IF   AVAILABLE crapdrf   THEN
        ASSIGN tel_dtgerarq = crapdrf.dtmvtolt
               tel_flsitdrf = TRIM(crapdrf.dsobserv) = "". 
   ELSE
        ASSIGN tel_dtgerarq = ?
               tel_flsitdrf = TRUE.

   IF   tel_dtgerarq = ?   THEN
        DISPLAY tel_qtlanapl    
                tel_flarqint    
                tel_qtlanint   
                tel_nrlandig    
                "NAO FOI GERADO" @ tel_dtgerarq    
                tel_flsitdrf    
                WITH FRAME f_status.
   ELSE
        DISPLAY tel_qtlanapl    
                tel_flarqint    
                tel_qtlanint   
                tel_nrlandig    
                tel_dtgerarq    
                tel_flsitdrf    
                WITH FRAME f_status.

END. /* DO WHILE TRUE */

/* ......................................................................... */
