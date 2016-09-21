/* .............................................................................

   Programa: Fontes/seguro.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/96.                           Ultima atualizacao: 19/09/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratamento do seguro para a tela ATENDA.

   Alteracoes: 22/04/97 - Alterado para tratar automacao do seguro AUTO (Edson).

               02/08/1999 - Tratar seguro de vida em grupo (Deborah). 

               20/01/2000 - Tratar seguro prestamista (Deborah).

               30/03/2005 - Tratamento para tipo de seguro 11 - CASA (Evandro).
               
               10/08/2005 - Alterado para conectar com o banco generico ao
                            chamar os programas  fontes/seguro_i.p  e
                            fontes/segvida_m.p (Diego).

               01/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               19/09/2006 - Permitir o uso do F2-AJUDA (Evandro).

               04/11/2008 - Permitir soh consultar os novos seguros AUTO 
                            (Gabriel).

               20/04/2009 - Desabilitar opcoes de cancelamento, exclusao, alt. 
                            e substituicao para todos os seguros auto (Gabriel).
                            
               23/03/2010 - Utilizar browse dinamico.
                            Retirar opcoes nao mais utilizadas , substituicao
                            e exclusao (Gabriel). 
                            
               19/10/2011 - Realizada alteração de consultas de tabelas para
                            utilização da bo b1wgen0033 (Lauro).
                            
               27/02/2013 - Incluir INPUT "I" em chamada do fonte segvida_m 
                            (Lucas R.)                               

               19/09/2014 - Bloquer opcao de cancelamento do seguro do tipo 
                            prestamista (Softdesk 179295 - Lucas R.)  
............................................................................. */


{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_seguro.i }
{ includes/gg0000.i     }

/* Include com a tt-erro */
{ sistema/generico/includes/var_internet.i }

DEF INPUT PARAM TABLE FOR tt-seguros.

DEFINE VARIABLE p_opcao      AS CHAR EXTENT 5 INIT
    ["Alterar","Cancelar","Consultar","Imprimir","Incluir"]             NO-UNDO.

DEFINE VARIABLE tab_cddopcao AS CHAR EXTENT 5 INIT
                                ["A","X","C","M","I"]                   NO-UNDO.

DEF VAR opcao                AS INTE                                    NO-UNDO.



FORM SPACE(15)
     p_opcao[1] FORMAT "x(7)"
     p_opcao[2] FORMAT "x(8)"
     p_opcao[3] FORMAT "x(9)"
     p_opcao[4] FORMAT "x(8)"
     p_opcao[5] FORMAT "x(7)"
     SPACE(5)
     WITH WIDTH 78 ROW 20 CENTERED NO-BOX NO-LABELS OVERLAY FRAME f_opcoes.

FORM b_seguros

     WITH TITLE " Escolha o Seguro " 
    
     WIDTH 78 OVERLAY ROW 10 CENTERED FRAME f_seguros.


/* Flag de controle de saida */
ASSIGN aux_flgsaida = FALSE. 

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF   glb_cdcritic > 0   THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   DISPLAY p_opcao[1]
           p_opcao[2]
           p_opcao[3]
           p_opcao[4]
           p_opcao[5]
           WITH FRAME f_opcoes.

   DO aux_contador = 1 TO 5:

      COLOR DISPLAY NORMAL p_opcao[aux_contador]
                    WITH FRAME f_opcoes.

   END.
       
   /* Consulta */
   ASSIGN opcao = 3 WHEN opcao = 0.

   /* Destacar opcao em uso */
   COLOR DISPLAY MESSAGE p_opcao[opcao] WITH FRAME f_opcoes.

   /* Abrir os seguros */
   OPEN QUERY q_seguros FOR EACH tt-seguros NO-LOCK.
       
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   aux_ultlinha <> 0   THEN
           DO:
               /* Abrir o browser com os seguros */
               OPEN QUERY q_seguros FOR EACH tt-seguros NO-LOCK.

               REPOSITION q_seguros  TO ROW aux_ultlinha.

               aux_ultlinha = 0.
           END.
           
      ENABLE b_seguros WITH FRAME f_seguros.

      APPLY "ENTRY" TO b_seguros IN FRAME f_seguros.
       
      READKEY.

      HIDE MESSAGE NO-PAUSE.

      /* Eventos do browse */
      IF   CAN-DO("CURSOR-UP,CURSOR-DOWN,HOME,PAGE-UP,PAGE-DOWN",
                  KEYFUNCTION(LASTKEY))  THEN
           DO:
               APPLY KEYFUNCTION(LASTKEY) TO b_seguros IN FRAME f_seguros.
           END.
      ELSE
      IF   CAN-DO("CURSOR-RIGHT,TAB",KEYFUNCTION(LASTKEY))   THEN
           DO:
               COLOR DISPLAY NORMAL p_opcao[opcao]
                                    WITH FRAME f_opcoes.

               ASSIGN opcao = IF   opcao = 5   THEN
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
                                   5
                              ELSE
                                   opcao - 1.
           END.
      ELSE
      IF   CAN-DO("GO,RETURN,END-ERROR",KEYFUNCTION(LASTKEY))  THEN
           DO:
               IF   AVAIL tt-seguros   THEN
                    aux_ultlinha = CURRENT-RESULT-ROW("q_seguros").

               LEAVE.
           END.

      COLOR DISPLAY MESSAGE p_opcao[opcao]
                            WITH FRAME f_opcoes.

   END.  /* Fim do DO WHILE TRUE */

   /* Volta para a tela ATENDA */
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
        DO: 
            ASSIGN aux_flgsaida = TRUE.

            HIDE MESSAGE NO-PAUSE.

            HIDE FRAME f_opcoes  NO-PAUSE.
            HIDE FRAME f_seguros NO-PAUSE.

            LEAVE.

        END.

   ASSIGN glb_cddopcao = tab_cddopcao[opcao]
          glb_nmrotina = "SEGURO".

   { includes/acesso.i }

   /* Se existe algum seguro ... */
   IF   AVAIL tt-seguros   THEN
        DO: 
            /* Os seguros Auto somente consulta (Alteracoes e 
              demais operacoes atraves de importacao crps520 )*/
                        
            IF   tt-seguros.tpseguro = 2   THEN
                 IF   NOT CAN-DO("3,5",STRING(opcao))   THEN
                      DO:
                          MESSAGE "Seguro AUTO permitido somente"
                                  "CONSULTA.".
                          PAUSE 2 NO-MESSAGE.
                          NEXT.
                      END.                      
        END.

   CASE opcao: /* Dependendo a opcao selecionada */
    
       WHEN 1 THEN DO: /* ALTERAR */

           IF    NOT AVAIL tt-seguros   THEN
                 NEXT.

           IF    tt-seguros.tpseguro <> 3 THEN
                 NEXT.

           /* Seguro de vida, conecta gener  */
           IF   f_conectagener()  THEN
                DO:
                    RUN fontes/segvida_a.p (INPUT tt-seguros.tpseguro,
                                            INPUT tt-seguros.nrctrseg).  

                    RUN p_desconectagener.            
                END.

       END.
        
       WHEN 2 THEN DO: /* CANCELAR */
           
           IF   NOT AVAIL tt-seguros   THEN
                NEXT.
            
           /* Se for prestamista e seguro estiver ativo a opcao de cancelar 
              sera desativada, para os demais seguros segue normalmente  */
           IF  tt-seguros.tpseguro = 4 AND tt-seguros.cdsitseg = 1 THEN
               DO:
                  MESSAGE "Opcao bloqueada!".
                  PAUSE 2 NO-MESSAGE.
               END.
           ELSE
              RUN fontes/seguro_x.p (INPUT tt-seguros.tpseguro,
                                     INPUT tt-seguros.nrctrseg).
             
       END.

       WHEN 3 THEN DO: /* CONSULTAR */

           IF   NOT AVAIL tt-seguros  THEN
                NEXT.

           /* Seguro AUTO */
           IF   tt-seguros.tpseguro = 2   THEN
                RUN fontes/segauto.p (INPUT tt-seguros.nrctrseg).
           ELSE
                RUN fontes/seguro_c.p (INPUT tt-seguros.cdsegura,
                                       INPUT tt-seguros.tpseguro,
                                       INPUT tt-seguros.nrctrseg).

           /* Nao altera os dados, nao precisa re-carregar o browse  */

           NEXT.

       END.

       WHEN 4 THEN DO: /* IMPRIMIR */

           IF   NOT AVAIL tt-seguros   THEN
                NEXT.

            RUN sistema/generico/procedures/b1wgen0033.p
                            PERSISTENT SET h-b1wgen0033.

            RUN buscar_proposta_seguro IN h-b1wgen0033
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
                 OUTPUT TABLE tt-prop-seguros,
                 OUTPUT aux_qtsegass,
                 OUTPUT aux_vltotseg,
                 OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0033.
           
            FIND tt-prop-seguros WHERE
                 tt-prop-seguros.cdcooper = glb_cdcooper  AND
                 tt-prop-seguros.nrdconta = tel_nrdconta  AND
                 tt-prop-seguros.nrctrseg = tt-seguros.nrctrseg
                NO-ERROR.

           IF   CAN-DO ("3,4",STRING(tt-seguros.tpseguro))  THEN
                DO:
                    IF   f_conectagener()  THEN
                         DO:
                             RUN fontes/segvida_m.p (INPUT tt-prop-seguros.registro,
                                                     INPUT "I").
                            
                             RUN p_desconectagener. 
                         END.                    
                END.
           ELSE
                DO:
                    RUN fontes/seguro_m.p (INPUT tt-prop-seguros.registro).
                                                           
                END.
                
           /* Nao altera os dados ,  nao precisa re-carregar browse*/ 

           NEXT.
            
       END.

       WHEN 5 THEN DO:
           IF   f_conectagener()   THEN
                DO:
                    RUN fontes/seguro_i.p.

                    RUN p_desconectagener.
                END.

       END.
        
   END CASE. /* Fim tratamento Opcao */
                    
   LEAVE.
         
END. /* Fim do DO WHILE TRUE */

HIDE FRAME f_opcoes  NO-PAUSE.
HIDE FRAME f_seguros NO-PAUSE.

/* .......................................................................... */

