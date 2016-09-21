/* .............................................................................

   Programa: Fontes/deschq_1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003.                         Ultima atualizacao: 20/03/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para tratar PROPOSTAS DE LIMITE DE DESCONTO DE CHEQUES
               para a tela ATENDA.

   Alteracoes: 05/04/2006 - Inclusao da data de inicio de vigencia na listagem
                            da tela (Julio)

               19/09/2006 - Alterado o nome da rotina e permitir o uso do
                            F2-AJUDA (Evandro).
                            
               13/10/2009 - Alterado para browse dinamico (Gabriel).          
               
               24/06/2010 - Receber como parametros os limites (Gabriel). 
               
               22/09/2010 - Ajustar parametros para deschq_m.p (David). 
               
               10/09/2012 - Ordenar limites por Dt. de Inicio de Vig. e Nr. do
                            Contrato (Lucas).

               27/12/2012 - Bloquear Alteracoes para Migracao AltoVale (Ze).
               
               02/01/2013 - Ignorar registro de cooperado migrado ALTO VALE.
                            (Fabricio).
                            
               20/03/2013 - Passado o paramentro nrctrlim para os fontes ao
                            inves do nrdrecid:
                            - fontes/deschq_a.p;
                            - fontes/deschq_x.p;
                            - fontes/deschq_c.p;
                            - fontes/deschq_e.p
                            (Adriano).
                                         
............................................................................. */

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_deschq.i }

DEF INPUT PARAM TABLE FOR tt-limite_chq.

DEFINE VARIABLE p_opcao      AS CHAR EXTENT 6 INIT
       ["Alterar","Cancelar","Consultar","Excluir","Incluir","Imprimir"]
       NO-UNDO.

DEFINE VARIABLE tab_cddopcao AS CHAR EXTENT 6 INIT
                                ["A","X","C","E","I","M"] NO-UNDO.



FORM SPACE(13)
     p_opcao[1] FORMAT "x(7)"
     p_opcao[2] FORMAT "x(8)"
     p_opcao[3] FORMAT "x(9)"
     p_opcao[4] FORMAT "x(7)"
     p_opcao[5] FORMAT "x(7)"
     p_opcao[6] FORMAT "x(8)"
     SPACE(13)
     WITH ROW 20 CENTERED NO-BOX NO-LABELS OVERLAY FRAME f_opcoes.

FORM b-craplim
     
     WITH ROW 10 OVERLAY CENTERED TITLE " Desconto de Cheques - Limite " 
     
     FRAME f_limite.

FUNCTION cooperado-migrado RETURNS LOGICAL (INPUT par_nrctaant AS INT):

    FIND FIRST craptco WHERE craptco.cdcopant = glb_cdcooper  AND
                             craptco.nrctaant = par_nrctaant  AND
                             craptco.tpctatrf = 1             AND
                             craptco.flgativo = TRUE
                             NO-LOCK NO-ERROR.

    IF AVAIL craptco THEN
        RETURN TRUE.
    ELSE
        RETURN FALSE.

END FUNCTION.


aux_flgsaida = FALSE.


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

   OPEN QUERY q-craplim FOR EACH tt-limite_chq NO-LOCK
                              BY tt-limite_chq.dtinivig DESC
                              BY tt-limite_chq.nrctrlim. 

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      ENABLE b-craplim WITH FRAME f_limite.

      APPLY "ENTRY" TO b-craplim IN FRAME f_limite.

      READKEY.

      HIDE MESSAGE NO-PAUSE.

      /* Eventos do browse */
      IF   CAN-DO("CURSOR-UP,CURSOR-DOWN,HOME,PAGE-UP,PAGE-DOWN",
                  KEYFUNCTION(LASTKEY))  THEN
           DO:      
               APPLY KEYFUNCTION(LASTKEY) TO b-craplim IN FRAME f_limite.
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
               LEAVE.
           END.

      COLOR DISPLAY MESSAGE p_opcao[opcao] 
                            WITH FRAME f_opcoes.
                                  
   
   END.  /* Fim do DO WHILE TRUE */
    
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
        DO:
            ASSIGN aux_flgsaida  = TRUE.
            HIDE FRAME f_opcoes NO-PAUSE.
            HIDE FRAME f_limite NO-PAUSE.
            LEAVE.
        END.

   ASSIGN glb_cddopcao = tab_cddopcao[opcao]
          glb_nmrotina = "DSC CHQS - LIMITE".
            
   { includes/acesso.i } /* Testa permissao */
                        
   HIDE FRAME f_opcoes NO-PAUSE.
   HIDE FRAME f_limite NO-PAUSE.

   IF   opcao = 1   THEN /* Alteracao*/
        DO:
            IF   NOT AVAIL tt-limite_chq   THEN
                 NEXT.

            IF cooperado-migrado(INPUT tel_nrdconta) THEN
            DO:
                MESSAGE "Conta migrada.".
                NEXT.
            END.
            
            RUN fontes/deschq_a.p (INPUT tt-limite_chq.nrctrlim).  
        END.
   ELSE
   IF   opcao = 2   THEN /* Cancelamento */
        DO:
            IF   NOT AVAIL tt-limite_chq   THEN
                 NEXT.

            IF cooperado-migrado(INPUT tel_nrdconta) THEN
            DO:
                MESSAGE "Conta migrada.".
                NEXT.
            END.

            RUN fontes/deschq_x.p (INPUT tt-limite_chq.nrctrlim).
        END.
   ELSE
   IF   opcao = 3   THEN /* Consulta     */
        DO:
            IF   NOT AVAIL tt-limite_chq    THEN
                 NEXT.
               
            RUN fontes/deschq_c.p (INPUT tt-limite_chq.nrctrlim).            
        END.
   ELSE
   IF   opcao = 4   THEN /* Exclusao     */
        DO:
            IF   NOT AVAIL tt-limite_chq   THEN
                 NEXT.

            IF cooperado-migrado(INPUT tel_nrdconta) THEN
            DO:
                MESSAGE "Conta migrada.".
                NEXT.
            END.
            
            RUN fontes/deschq_e.p (INPUT tt-limite_chq.nrctrlim).
        END.
   ELSE
   IF   opcao = 5   THEN /* Inclusao     */
        DO:
            IF cooperado-migrado(INPUT tel_nrdconta) THEN
            DO:
                MESSAGE "Conta migrada.".
                NEXT.
            END.
            
            RUN fontes/deschq_i.p.
        END.
   ELSE
   IF   opcao = 6   THEN /* Impressao    */
        DO:
            IF   NOT AVAIL tt-limite_chq   THEN
                 NEXT.
                
            RUN fontes/deschq_m.p (INPUT tel_nrdconta,
                                   INPUT tt-limite_chq.nrctrlim).
        END.
      
   LEAVE.

END. /* Fim do DO WHILE TRUE */


/* .......................................................................... */
