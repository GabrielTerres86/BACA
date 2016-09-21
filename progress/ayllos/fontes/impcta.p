/* ............................................................................

   Programa: fontes/impcta.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Dezembro/2004                    Ultima atualizacao: 30/05/2014
             
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela IMPCTA.
   
   Alteracoes: 27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               23/01/2007 - Incluidas opcoes "I"(impressao) e "T"(tela)
                            (Diego).
                            
               19/12/2013 - Incluida verificacao de numero de contas salario
                            utilizadas. (Reinert)
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

............................................................................ */

{ includes/var_online.i }

DEF STREAM str_1.

DEF TEMP-TABLE w-contas                                              NO-UNDO
    FIELD nrdconta AS INTEGER.
    
DEF VAR tel_nrctaini AS INT            FORMAT "zzzz,zz9"             NO-UNDO.
DEF VAR tel_nrctafin AS INT            FORMAT "zzzz,zz9"             NO-UNDO.
DEF VAR aux_contador AS INT                                          NO-UNDO.
DEF VAR aux_nrctaini AS INT                                          NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                         NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                         NO-UNDO.

/* variaveis para impressao */
DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.
DEF        VAR rel_nmempres     AS CHAR    FORMAT "x(15)"            NO-UNDO.
DEF        VAR rel_nmmesref AS CHAR    FORMAT "x(014)"               NO-UNDO.
DEF        VAR par_flgrodar AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.


DEF QUERY q_contas FOR w-contas.
      
DEF BROWSE b_contas QUERY q_contas
    DISPLAY w-contas.nrdconta COLUMN-LABEL "Conta-Corrente" FORMAT "zzzz,zzz,9"
            WITH 7 DOWN.

FORM b_contas  HELP "Use as SETAS para navegar ou <F4> para sair." SKIP
     WITH NO-BOX CENTERED OVERLAY ROW 10 WIDTH 30 FRAME f_contas.

FORM SKIP(1)
     "Opcao:"           AT 5
     glb_cddopcao       AT 12 NO-LABEL AUTO-RETURN
               HELP "Informe a opcao desejada (T-Terminal ou I-Impressao)."
                        VALIDATE (glb_cddopcao = "T" OR glb_cddopcao = "I", 
                                  "014 - Opcao errada.")
     SKIP(1)
     tel_nrctaini  AT 10  LABEL "Numeracao Inicial" 
                          HELP  "Digite o numero inicial da conta (sem digito)"
                          VALIDATE(INPUT tel_nrctaini > 0,
                                   "375 - O campo deve ser preenchido.")
     tel_nrctafin  AT 44  LABEL "Numeracao Final"
                          HELP  "Digite o numero final da conta (sem digito)"
                          VALIDATE(INPUT tel_nrctafin > 0,
                                   "375 - O campo deve ser preenchido.")
     SKIP(12)
     WITH ROW 4 WIDTH 80 SIDE-LABEL TITLE glb_tldatela FRAME f_impcta.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56 FRAME f_atencao.

ASSIGN glb_cddopcao = "T".

DO WHILE TRUE: 

   RUN fontes/inicia.p.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
      UPDATE glb_cddopcao
             tel_nrctaini
             tel_nrctafin
             WITH FRAME f_impcta.
      LEAVE.
   END.
   
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "IMPCTA"   THEN
                 DO:
                     HIDE FRAME f_impcta.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF   (tel_nrctaini >= 95000    AND    tel_nrctaini <= 100000)   OR
        (tel_nrctafin >= 95000    AND    tel_nrctafin <= 100000)   THEN
         DO:
             MESSAGE "Numeracao Reservada para Cia. Hering 95.000 a 100.000".
             PAUSE.
             NEXT.
         END.    
   
   IF   tel_nrctafin < tel_nrctaini   THEN
        DO:
            MESSAGE "A Numeracao final tem que ser MAIOR que a numeracao"
                    "inicial.".
            NEXT.
        END.
            
   IF   glb_cddopcao = "T"  THEN
        DO:
            EMPTY TEMP-TABLE w-contas.
            
            ASSIGN aux_nrctaini = tel_nrctaini.

            DO WHILE aux_nrctaini <= tel_nrctafin:

               glb_nrcalcul = aux_nrctaini * 10.
               RUN fontes/digfun.p.

               FIND crapass WHERE crapass.cdcooper = glb_cdcooper           AND 
                                  crapass.nrdconta = INTEGER(glb_nrcalcul) 
                                  NO-LOCK NO-ERROR.

                FIND crapccs WHERE crapccs.cdcooper = glb_cdcooper           AND 
                                  crapccs.nrdconta = INTEGER(glb_nrcalcul) 
                                  NO-LOCK NO-ERROR.

               IF   AVAILABLE crapass OR AVAILABLE crapccs  THEN
                    DO:
                        aux_nrctaini = aux_nrctaini + 1.
                        NEXT.  
                    END.

               FIND crapdem WHERE crapdem.cdcooper = glb_cdcooper           AND
                                  crapdem.nrdconta = INTEGER(glb_nrcalcul)
                                  NO-LOCK NO-ERROR.

               IF   AVAILABLE crapdem   THEN
                    DO:
                        aux_nrctaini = aux_nrctaini + 1.
                        NEXT.
                    END.

               CREATE w-contas.
               ASSIGN w-contas.nrdconta = glb_nrcalcul.
                      
               aux_nrctaini = aux_nrctaini + 1.
            END.
            
            OPEN QUERY q_contas 
                 FOR EACH w-contas NO-LOCK.
                                                   
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
               UPDATE b_contas WITH FRAME f_contas.
               LEAVE.
            END.
                           
            IF   KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                 DO:
                     HIDE FRAME f_contas.
                     NEXT.
                 END.
            ELSE
                 HIDE FRAME f_contas.
        END.
   ELSE
   IF   glb_cddopcao = "I"  THEN
        DO:
            DISPLAY tel_dsimprim tel_dscancel WITH FRAME f_atencao.
            CHOOSE FIELD tel_dsimprim tel_dscancel WITH FRAME f_atencao.

            IF   FRAME-VALUE <> tel_dsimprim   THEN
                 LEAVE.

            INPUT THROUGH basename `tty` NO-ECHO.
            SET aux_nmendter WITH FRAME f_terminal.
            INPUT CLOSE.     
            
            aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                  aux_nmendter.

            UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
            ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

            ASSIGN glb_cdcritic    = 0
                   glb_nrdevias    = 1
                   glb_cdempres    = 11          
                   glb_nmformul    = "80col"
                   glb_cdrelato[1] = 404.
  
            { includes/cabrel080_1.i }
   
            OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

            VIEW STREAM str_1 FRAME f_cabrel080_1.
   
            ASSIGN aux_nrctaini = tel_nrctaini
                   aux_contador = 0.

            DO WHILE aux_nrctaini <= tel_nrctafin:

               glb_nrcalcul = aux_nrctaini * 10.
               RUN fontes/digfun.p.

               FIND crapass WHERE crapass.cdcooper = glb_cdcooper           AND 
                                  crapass.nrdconta = INTEGER(glb_nrcalcul) 
                                  NO-LOCK NO-ERROR.
                
               FIND crapccs WHERE crapccs.cdcooper = glb_cdcooper           AND 
                                  crapccs.nrdconta = INTEGER(glb_nrcalcul) 
                                  NO-LOCK NO-ERROR.

               IF   AVAILABLE crapass OR AVAILABLE crapccs  THEN
                    DO:
                        aux_nrctaini = aux_nrctaini + 1.
                        NEXT.  
                    END.

               FIND crapdem WHERE crapdem.cdcooper = glb_cdcooper           AND
                                  crapdem.nrdconta = INTEGER(glb_nrcalcul)
                                  NO-LOCK NO-ERROR.

               IF   AVAILABLE crapdem   THEN
                    DO:
                        aux_nrctaini = aux_nrctaini + 1.
                        NEXT.
                    END.

               PUT STREAM str_1 
                          " "
                          glb_nrcalcul  FORMAT "zzzz,zzz,9".
       
               aux_contador = aux_contador + 1.

               
               /* 6 contas por linha */
               IF   aux_contador = 7   THEN
                    DO:
                        PUT STREAM str_1 SKIP(2).
                        aux_contador = 0.
                    END.

               aux_nrctaini = aux_nrctaini + 1.
           
            END.

            PUT STREAM str_1 SKIP(1).
            
            OUTPUT STREAM str_1 CLOSE.
   
            /* somente para impressao */

            FIND FIRST crapass WHERE 
                       crapass.cdcooper = glb_cdcooper  NO-LOCK NO-ERROR.
   
            { includes/impressao.i }
               
        END.
END.

/*...........................................................................*/
