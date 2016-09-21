/*.............................................................................

  Programa: Fontes/procap.p
  Sistema : Conta-Corrente - Cooperativa de Credito
  Sigla   : CRED
  Autor   : Tiago
  Data    : Setembro/12                            Ultima alteracao: 19/08/2015

  Objetivo  : Mostrar a tela Procap.

  Alteracao : 31/07/2015 - Ajuste para retirar o caminho absoluto na chamada 
                           de fontes (Adriano - SD 314469).
              
              19/08/2015 - Remover chamada da procedure acesso_opcao 
                           (Lucas Ranghetti #322522)
............................................................................ */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0140tt.i }

DEF VAR aux_cddopcao  AS CHAR                                          NO-UNDO.
DEF VAR aux_indtpcon  AS INT   INITIAL 1                               NO-UNDO.
DEF VAR aux_indtpsta  AS INT   INITIAL 1                               NO-UNDO.
DEF VAR aux_confirma  AS CHAR  FORMAT "!(1)"                           NO-UNDO.

DEF VAR tel_dstpcons  AS CHAR    FORMAT "x(5)"   
    VIEW-AS COMBO-BOX LIST-ITEMS "Data",
                                 "Conta"                               NO-UNDO.
DEF VAR tel_nrdconta  AS INTE    FORMAT "zzzz,zzz,9"                   NO-UNDO.
DEF VAR tel_dtconsul  AS DATE    FORMAT "99/99/9999"                   NO-UNDO.
DEF VAR tel_dsstatus  AS CHAR    FORMAT "x(13)"   
    VIEW-AS COMBO-BOX LIST-ITEMS "Todos",
                                 "Ativos",
                                 "Desbloqueados"                       NO-UNDO.

/* BO HANDLE */
DEF VAR h-b1wgen0140 AS HANDLE                                NO-UNDO.

/*Consulta*/
DEF QUERY  bprocap-q FOR tt-craplct.
DEF BROWSE bprocap-b QUERY bprocap-q
      DISP SPACE(2)
           tt-craplct.dtmvtolt             COLUMN-LABEL "Dt.Integra"
           SPACE(1)
           tt-craplct.nrdconta             COLUMN-LABEL "Conta"
           SPACE(1)
           tt-craplct.vllanmto             COLUMN-LABEL "Valor" FORMAT "zzz,zz9.99"
           SPACE(2)
           tt-craplct.dtlibera             COLUMN-LABEL "Dt.Desbloq" 
           SPACE(2)
           tt-craplct.dtdsaque             COLUMN-LABEL "Dt.Saque"
           WITH 9 DOWN OVERLAY NO-BOX.    

FORM  bprocap-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
           WITH CENTERED OVERLAY ROW 8 FRAME f_lst_procap.

/*Consulta fim*/

/*Alteracao desbloqueio*/
DEF QUERY  bprocap-qa FOR tt-craplct.
DEF BROWSE bprocap-ba QUERY bprocap-qa
      DISP SPACE(1)
           tt-craplct.dtmvtolt             COLUMN-LABEL "Dt.Integra"
           SPACE(1)
           tt-craplct.nrdconta             COLUMN-LABEL "Conta"
           SPACE(1)
           tt-craplct.vllanmto             COLUMN-LABEL "Valor" FORMAT "zzz,zz9.99"
           SPACE(2)
           tt-craplct.dtlibera             COLUMN-LABEL "Dt.Desbloq" 
           SPACE(2)
           tt-craplct.dtdsaque             COLUMN-LABEL "Dt.Saque"
           SPACE(2)
           tt-craplct.dsdesblq             COLUMN-LABEL "Desbloq?"  FORMAT "!"
           ENABLE tt-craplct.dsdesblq  AUTO-RETURN
       HELP "'S':Desbloquear  'F1':Confirmar operacao  ."
                  VALIDATE (CAN-DO("S,N",tt-craplct.dsdesblq),"014 - Opcao errada.")
           WITH 9 DOWN OVERLAY NO-BOX.    

DEF FRAME  f_lst_procapa
           bprocap-ba HELP "Use as SETAS para navegar e <F4> para sair <F1> para efetuar desbloqueio" SKIP 
           WITH CENTERED OVERLAY ROW 8.
/*Alteracao desbloqueio fim*/


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM SKIP
     glb_cddopcao AT 5  LABEL "Opcao" AUTO-RETURN
         HELP "Entre com a opcao desejada (C ou D)"
         VALIDATE(CAN-DO("C,D",glb_cddopcao),"014 - Opcao errada.")
     tel_dstpcons AT 17  LABEL "Tipo Consulta"
        HELP "Informe o tipo: Use setas(cima/baixo) ou <END>/<F4> p/ sair."
     tel_dsstatus AT 48  LABEL "Status"
        HELP "Informe o status: Use setas (cima/baixo) ou <END>/<F4> p/ sair."
     SKIP
     tel_dtconsul AT 26  LABEL "Data"
        HELP "Informe a data ou deixe em branco para todas as datas."
     tel_nrdconta AT 49  LABEL "Conta"
        HELP "Informe a conta ou 0 (Zero) para todas as contas."
     WITH NO-BOX CENTERED ROW 6 WIDTH 78 OVERLAY SIDE-LABELS NO-LABEL FRAME f_procap.

VIEW FRAME f_moldura.
PAUSE 0.

RUN fontes/inicia.p. 

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

ON RETURN OF tel_dsstatus DO:
   APPLY "F1".
END.

ON RETURN OF tel_dstpcons DO:
   APPLY "TAB".
END.

ON  VALUE-CHANGED OF tel_dstpcons   DO:
    ASSIGN aux_indtpcon = SELF:LOOKUP(SELF:SCREEN-VALUE).
END.

ON  VALUE-CHANGED OF tel_dsstatus   DO:
    ASSIGN aux_indtpsta = SELF:LOOKUP(SELF:SCREEN-VALUE).
END.

ON END-ERROR OF bprocap-b DO:
   DISABLE bprocap-b WITH FRAME f_lst_procap.
   CLOSE QUERY bprocap-q.
   HIDE FRAME f_lst_procap.
END.

/* Manter opcao T desbloqueio todos desativado, qdo solicitado basta
   apenas descomentar este codigo 
   
ON ENTRY, GO , END-ERROR OF tt-craplct.dsdesblq DO: 
      
    IF   CAN-FIND (FIRST tt-craplct WHERE tt-craplct.dsdesblq = "T") THEN
         DO:
             /* Seta na temp-table "sim" para todos */
             FOR EACH tt-craplct WHERE tt-craplct.dsdesblq <> "S":
             
                  tt-craplct.dsdesblq = "S".
             
             END.           
        
             RUN pAltProcap(INPUT YES).

         END.
                                   
END.
*/

ON ANY-KEY OF  tt-craplct.dsdesblq IN BROWSE bprocap-ba
DO: 
    IF KEY-FUNCTION(LASTKEY) <> "S" AND
       KEY-FUNCTION(LASTKEY) <> "N" AND
       KEY-FUNCTION(LASTKEY) <> "RETURN"      AND
       KEY-FUNCTION(LASTKEY) <> "END-ERROR"   AND 
       KEY-FUNCTION(LASTKEY) <> "GO"          AND
       KEY-CODE(KEY-FUNCTION(LASTKEY)) <> 501 AND 
       KEY-CODE(KEY-FUNCTION(LASTKEY)) <> 502 THEN
       RETURN NO-APPLY.
END.

PROCEDURE pConsProcap:  
   
   EMPTY TEMP-TABLE tt-craplct.

   RUN sistema/generico/procedures/b1wgen0140.p
                  PERSISTENT SET h-b1wgen0140.

   RUN busca_lanctos IN h-b1wgen0140(INPUT glb_cdcooper,
                                     INPUT aux_indtpcon,
                                     INPUT aux_indtpsta,
                                     INPUT tel_nrdconta,
                                     INPUT tel_dtconsul,
                                     INPUT 930,
                                     INPUT glb_dtmvtolt,
                                     INPUT glb_cddopcao,
                                     OUTPUT TABLE tt-craplct).

   DELETE PROCEDURE h-b1wgen0140.

   OPEN QUERY bprocap-q FOR EACH tt-craplct WHERE 
                                 tt-craplct.cdcooper = glb_cdcooper NO-LOCK
                                 BY tt-craplct.nrdconta.

   UPDATE bprocap-b WITH FRAME f_lst_procap.
   WAIT-FOR RETURN OF bprocap-b.
   DISABLE bprocap-b WITH FRAME f_lst_procap.
   CLOSE QUERY bprocap-q.
   HIDE FRAME f_lst_procap. 

END.

PROCEDURE pAltProcap:  

    DEF INPUT PARAM par_refresh     AS  LOGICAL                         NO-UNDO.

    IF  par_refresh = NO THEN
        DO: 
            EMPTY TEMP-TABLE tt-craplct.
        
            RUN sistema/generico/procedures/b1wgen0140.p
                           PERSISTENT SET h-b1wgen0140.
        
            RUN busca_lanctos IN h-b1wgen0140(INPUT glb_cdcooper,
                                              INPUT aux_indtpcon,
                                              INPUT aux_indtpsta,
                                              INPUT tel_nrdconta,
                                              INPUT tel_dtconsul,
                                              INPUT 930,
                                              INPUT glb_dtmvtolt,
                                              INPUT glb_cddopcao,
                                              OUTPUT TABLE tt-craplct).
        
            DELETE PROCEDURE h-b1wgen0140.
        END.

    OPEN QUERY bprocap-qa FOR EACH tt-craplct WHERE 
                                  tt-craplct.cdcooper = glb_cdcooper NO-LOCK
                                  BY tt-craplct.nrdconta.
    
    IF  par_refresh = NO THEN
        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            UPDATE bprocap-ba WITH FRAME f_lst_procapa.
            LEAVE.
        END.

    VIEW FRAME f_lst_procapa.

END.


DO WHILE TRUE:

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        UPDATE glb_cddopcao
               tel_dstpcons
               tel_dsstatus
               WITH FRAME f_procap.

        ASSIGN tel_dtconsul = ?
               tel_nrdconta = 0.

        DISPLAY tel_dtconsul
                tel_nrdconta
                WITH FRAME f_procap.

        UPDATE
               tel_dtconsul WHEN aux_indtpcon = 1 
               tel_nrdconta WHEN aux_indtpcon = 2
               WITH FRAME f_procap.

        LEAVE.

    END.

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.

            IF  CAPS(glb_nmdatela) <> "procap"   THEN
                DO:
                    HIDE FRAME f_procap.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.
    
    IF  aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i } 
            aux_cddopcao = glb_cddopcao.
        END.
        
    IF  glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            CLEAR FRAME f_procap NO-PAUSE.
            glb_cdcritic = 0.
        END.

    /*Verifica digito da conta*/
    IF  tel_nrdconta > 0 THEN
    DO:   
        glb_nrcalcul = tel_nrdconta.
        RUN fontes/digfun.p.
    
        IF  NOT glb_stsnrcal THEN
            DO: 
                MESSAGE "Digito de conta invalido".
                NEXT.
            END.
    END.

    CASE glb_cddopcao:
        WHEN "C" THEN 
            DO: 
                RUN pConsProcap.
            END.
        WHEN "D" THEN
            DO:
                RUN pAltProcap(INPUT NO).

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    DO:
                        PAUSE 0.

                        HIDE FRAME f_lst_procapa.
                        ASSIGN tel_dtconsul = ?
                               tel_nrdconta = 0.

                        DISPLAY tel_dtconsul
                                tel_nrdconta
                                WITH FRAME f_procap.

                        NEXT.
                    END.     
                
                RUN fontes/confirma.p (INPUT  "",
                                       OUTPUT aux_confirma).

                HIDE FRAME f_lst_procapa.

                IF  aux_confirma = "S" THEN
                    DO:
                        RUN sistema/generico/procedures/b1wgen0140.p
                            PERSISTENT SET h-b1wgen0140.

                        RUN desbloqueia_procap 
                            IN h-b1wgen0140(INPUT TABLE tt-craplct,
                                            OUTPUT TABLE tt-erro).

                        DELETE PROCEDURE h-b1wgen0140.

                    END.
            END.
    END CASE.


    ASSIGN tel_dtconsul = ?
           tel_nrdconta = 0.

    DISPLAY tel_dtconsul
            tel_nrdconta
            WITH FRAME f_procap.


END.

