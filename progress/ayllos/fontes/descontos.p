/* .............................................................................

   Programa: Fontes/descontos.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Agosto/2008                    Ultima Atualizacao:  14/10/2009     

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Fazer a escolha entre DESCONTO DE CHEQUES E DESCONTO DE TITULOS
               na rotina DESCONTOS da tela ATENDA.
               
   Alteracoes : 14/10/2009 - Esconder frame f_desconto (Gabriel)
  
............................................................................. */
{ includes/var_online.i }

DEF OUTPUT PARAM par_erro AS LOGICAL NO-UNDO.

DEF VAR reg_dsdopcao AS CHAR EXTENT 2 INIT 
                     ["Cheques",
                      "Titulos"]       NO-UNDO.

FORM SKIP(1)
     reg_dsdopcao[1] FORMAT "x(7)" AT 11 
     reg_dsdopcao[2] FORMAT "x(7)" AT 31 
     SKIP(1)
     WITH ROW 15 COLUMN 2 WIDTH 50 NO-LABELS TITLE "Escolha o tipo de desconto" 
     OVERLAY CENTERED FRAME f_desconto.
     
ASSIGN par_erro = FALSE.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
   
    DISPLAY reg_dsdopcao[1] reg_dsdopcao[2] 
            WITH FRAME f_desconto.
            
    /* Escolhe a opcao desejada */
    CHOOSE FIELD reg_dsdopcao[1] reg_dsdopcao[2] 
                 WITH FRAME f_desconto.
                    
    /* Se escolher Cheque */
    IF  FRAME-VALUE = reg_dsdopcao[1]  THEN
        DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "DSC CHQS". 
                       
            { includes/acesso.i }
                                 
            RUN fontes/desconto_cheques.p.
                 
            IF   glb_cdcritic > 0   THEN
                 DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    PAUSE 2 NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.
                    glb_cdcritic = 0.
                    par_erro = TRUE.
                 END.

        END.         
    ELSE
    IF  FRAME-VALUE = reg_dsdopcao[2]  THEN
        DO:
            ASSIGN glb_cddopcao = "@"
                   glb_nmrotina = "DSC TITS". 
                   
            { includes/acesso.i }
            
            RUN fontes/desconto_titulos.p.
                 
            IF   glb_cdcritic > 0   THEN
                 DO:
                    RUN fontes/critic.p.
                    BELL.
                    MESSAGE glb_dscritic.
                    PAUSE 2 NO-MESSAGE.
                    HIDE MESSAGE NO-PAUSE.
                    ASSIGN glb_cdcritic = 0
                           par_erro = TRUE.
                 END.
        END.

END. /* Final do DO WHILE */

HIDE FRAME f_desconto.

/* .......................................................................... */
