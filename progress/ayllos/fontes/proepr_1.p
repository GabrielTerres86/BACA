/* .............................................................................

   Programa: Fontes/proepr_1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/96.                           Ultima atualizacao: 25/04/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento da PROPOSTA DE EMPRESTIMO para a tela
               ATENDA.

   Alteracoes: 03/04/98 - Tratamento para milenio e troca para V8 (Margarete)

               18/02/2000 - Nova rotina de permissoes (Edson).

               19/09/2006 - Permitir o uso do F2-AJUDA (Evandro).

               03/07/2009 - Arrumar frame f_opcoes. (Gabriel).  

               18/03/2010 - Utilizar um browser dinamico (Gabriel).

               18/06/2010 - Adaptado para utilizar a temp-table da BO 02
                            (Gabriel).

               28/07/2010 - Mudada a passagem de parametros para os proepr
                            (Gabriel).

               07/06/2011 - Alteração de chamada para proepr_m. (André - DB1)

               21/07/2011 - Nao permitir alteracao de parcela com tipo de 
                            credito = 1. (Diego - GATI)

               13/09/2013 - Novo botão "Registrar Gravames".
                            (Andre Euzebio/Supero)

               25/04/2014 - Opcao Excluir - Apenas excluir se flgexclui TRUE
                            GRAVAMES (Guilherme/SUPERO)

............................................................................. */

{ sistema/generico/includes/var_internet.i }

{ includes/var_online.i }
{ includes/var_proepr.i }

DEF INPUT PARAM           par_nrdconta AS INTE               NO-UNDO.
DEF INPUT PARAM           par_vltotemp AS DECI               NO-UNDO.
DEF INPUT PARAM           par_dsdidade AS CHAR               NO-UNDO.
DEF INPUT PARAM TABLE FOR tt-proposta-epr.


DEF VAR p_opcao      AS CHAR EXTENT 6 INIT

    ["Alterar","Consultar","Excluir","Incluir","Imprimir","Registrar Gravames"]   NO-UNDO.

DEF VAR tab_cddopcao AS CHAR EXTENT 6 INIT
                                ["A","C","E","I","M","G"]    NO-UNDO.

DEF VAR opcao        AS INTE                                 NO-UNDO.
DEF VAR aux_contador AS INTE                                 NO-UNDO.
DEF VAR aux_confirma AS CHAR   FORMAT "!"                     NO-UNDO.

DEF VAR h-b1wgen0171 AS HANDLE                               NO-UNDO.

FORM SPACE(8)
     p_opcao[1] FORMAT "x(7)"
     p_opcao[2] FORMAT "x(9)"
     p_opcao[3] FORMAT "x(7)"
     p_opcao[4] FORMAT "x(7)"
     p_opcao[5] FORMAT "x(8)"
     p_opcao[6] FORMAT "x(18)"
     SPACE(8)
     WITH ROW 20 CENTERED NO-BOX NO-LABELS OVERLAY FRAME f_opcoes.


FORM b_crawepr 
     
    WITH TITLE " Propostas de Emprestimo em Andamento " 
    
    WITH WIDTH 78 OVERLAY ROW 9 CENTERED FRAME f_crawepr.


ASSIGN aux_flgsaida = FALSE.       

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   DISPLAY p_opcao[1]
           p_opcao[2]
           p_opcao[3]
           p_opcao[4]
           p_opcao[5]
           p_opcao[6]
           WITH FRAME f_opcoes.

   DO aux_contador = 1 TO 6:
   
       COLOR DISPLAY NORMAL p_opcao[aux_contador]
                     WITH FRAME f_opcoes.

   END.

   ASSIGN opcao = 1 WHEN opcao = 0.
          
   /* Destacar opcao em uso */
   COLOR DISPLAY MESSAGE p_opcao[opcao] WITH FRAME f_opcoes.

   /* Abrir o browser com as propostas de emprestimo */
   OPEN QUERY q_crawepr FOR EACH tt-proposta-epr NO-LOCK.
         
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
      /* Reposicionar */
      IF   aux_ultlinha <> 0   THEN
           DO:
               /* Abrir o browser com as propostas de emprestimo */
               OPEN QUERY q_crawepr FOR EACH tt-proposta-epr NO-LOCK.

               REPOSITION q_crawepr  TO ROW aux_ultlinha.

               aux_ultlinha = 0.
           END.  

      ENABLE b_crawepr WITH FRAME f_crawepr.

      APPLY "ENTRY" TO b_crawepr IN FRAME f_crawepr.
                     
      READKEY.

      HIDE MESSAGE NO-PAUSE.

      /* Eventos do browse */
      IF   CAN-DO("CURSOR-UP,CURSOR-DOWN,HOME,PAGE-UP,PAGE-DOWN",
                  KEYFUNCTION(LASTKEY))  THEN
           DO:
               APPLY KEYFUNCTION(LASTKEY) TO b_crawepr IN FRAME f_crawepr.
           END.
      ELSE
      IF   CAN-DO("CURSOR-RIGHT,TAB",KEYFUNCTION(LASTKEY))   THEN
           DO:
               COLOR DISPLAY NORMAL p_opcao[opcao]
                                    WITH FRAME f_opcoes.

               ASSIGN opcao = IF   opcao = 6   THEN
                                   1
                              ELSE
                                   opcao + 1.
           END.
      ELSE
      IF   CAN-DO("CURSOR-LEFT,BACK-TAB",KEYFUNCTION(LASTKEY))   THEN
           DO:
               COLOR DISPLAY NORMAL p_opcao[opcao]
                                    WITH FRAME f_opcoes.

               ASSIGN opcao = IF   opcao = 1   THEN
                                   6
                              ELSE
                                   opcao - 1.
           END.
      ELSE
      IF   CAN-DO("GO,RETURN,END-ERROR",KEYFUNCTION(LASTKEY))  THEN
           DO:
               IF   AVAIL tt-proposta-epr THEN
                    aux_ultlinha = CURRENT-RESULT-ROW("q_crawepr"). 

               LEAVE.
           END.
        
      COLOR DISPLAY MESSAGE p_opcao[opcao]
                            WITH FRAME f_opcoes.

   END. /*  Fim do DO WHILE TRUE */
    
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO:
            ASSIGN aux_flgsaida  = TRUE.

            HIDE FRAME f_opcoes  NO-PAUSE.
            HIDE FRAME f_crawepr NO-PAUSE.

            LEAVE.
        END.

   /* Opcao e rotina para permissoes */
   ASSIGN glb_cddopcao = tab_cddopcao[opcao]
          glb_nmrotina = "EMPRESTIMOS".
   
   /* Temporariamente Opcao Registrar gravames nao validar permissao */
   if opcao <> 6 then         
   do:
   { includes/acesso.i }
   end.
       
   /* Dependendo a opcao que foi escolhida */
   CASE opcao:
                
       WHEN 1 THEN DO: /* ALTERACAO */

           IF   NOT AVAIL tt-proposta-epr   THEN
                NEXT.

           IF   tt-proposta-epr.tpemprst = 1   THEN
                DO:
                     MESSAGE "Operacao invalida para esse tipo de contrato.".
                     NEXT.
                END.
           
                
           DISABLE b_crawepr WITH FRAME f_crawepr.
        
           RUN fontes/proepr_a.p (  INPUT par_nrdconta,
                                    INPUT tt-proposta-epr.nrctremp,
                                    INPUT par_vltotemp,
                                    INPUT par_dsdidade). 
                
       END.

       WHEN 2 THEN DO: /* CONSULTA */

           IF   NOT AVAIL tt-proposta-epr   THEN
                NEXT.

           DISABLE b_crawepr WITH FRAME f_crawepr. 

           RUN fontes/proepr_c.p (INPUT par_nrdconta,
                                  INPUT tt-proposta-epr.nrctremp).

           NEXT.
       END.

       WHEN 3 THEN DO: /* EXCLUSAO */

           IF   NOT AVAIL tt-proposta-epr   THEN
                NEXT.

           IF   tt-proposta-epr.tpemprst = 1   THEN
                DO:
                    MESSAGE "Operacao invalida para esse tipo de contrato".
                    NEXT.
                END.

           IF  NOT tt-proposta-epr.flexclui  THEN DO:
               MESSAGE " Exclusao Nao Permitida: " +
                       "Gravames em Processamento/Alienado".
               NEXT.
           END.


           DISABLE b_crawepr WITH FRAME f_crawepr.

           RUN fontes/proepr_e.p (INPUT par_nrdconta,
                                  INPUT tt-proposta-epr.nrctremp).

           IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                NEXT.

       END.

       WHEN 4 THEN DO: /* INCLUSAO */

           DISABLE b_crawepr WITH FRAME f_crawepr.
          
           RUN fontes/proepr_i.p (INPUT par_nrdconta,
                                  INPUT par_vltotemp,
                                  INPUT par_dsdidade).
       END.

       WHEN 5 THEN DO: /* IMPRESSAO */

           IF   NOT AVAIL tt-proposta-epr   THEN
                NEXT.

           DISABLE b_crawepr WITH FRAME f_crawepr.
             
           RUN fontes/proepr_m.p (INPUT tt-proposta-epr.nrdrecid,
                                  INPUT TABLE tt-proposta-epr).
           
       END.
       
       WHEN 6 THEN DO: /* REGISTRAR GRAVAMES */
            
            /* Irlan */

            IF  NOT AVAIL tt-proposta-epr   THEN
                NEXT.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                  ASSIGN aux_confirma = "N".
    
                  MESSAGE "078 - Deseja incluir o registro do bem no Gravames?(S/N)"
                       UPDATE aux_confirma.
                  LEAVE.
            
             END.  /*  Fim do DO WHILE TRUE  */
    
             IF   KEYFUNCTION(LASTKEY) = "END-ERROR" OR
                aux_confirma <> "S" THEN
                DO:
                    glb_cdcritic = 79.
                    RUN fontes/critic.p.
                    MESSAGE glb_dscritic.
                    glb_cdcritic = 0.
                    PAUSE 3 NO-MESSAGE.
                    NEXT.
             END.
                 
                 
             RUN sistema/generico/procedures/b1wgen0171.p
                 PERSISTENT SET h-b1wgen0171.
                
             RUN registrar_gravames IN h-b1wgen0171
                               ( INPUT glb_cdcooper,
                                 INPUT par_nrdconta,
                                 INPUT tt-proposta-epr.nrctremp,
                                 INPUT glb_dtmvtolt,
                                 INPUT "E",  /* OU "E"....*/
                                OUTPUT TABLE tt-erro).
             
    
             IF  VALID-HANDLE(h-b1wgen0171) THEN
                 DELETE PROCEDURE h-b1wgen0171.
             
             IF  TEMP-TABLE tt-erro:HAS-RECORDS THEN DO:
                 FIND FIRST tt-erro NO-LOCK NO-ERROR.
                 
                 IF  AVAIL tt-erro  THEN DO:
                     MESSAGE tt-erro.dscritic.
                     PAUSE 2 NO-MESSAGE.
                     HIDE MESSAGE.
                     NEXT.
                 END.
             END.
             ELSE DO:
                MESSAGE "Registro de alienacao do Gravame " +
                        "incluido com sucesso!".
                PAUSE 3 NO-MESSAGE.
                HIDE MESSAGE.
             END.
         END.
   END CASE. /* Fim opcoes */

   LEAVE.
         
END. /* Fim do DO WHILE TRUE */

HIDE FRAME f_opcoes  NO-PAUSE.
HIDE FRAME f_crawepr NO-PAUSE.

/* .......................................................................... */
