/* .............................................................................

   Programa: Fontes/debito.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah  
   Data    : Abril/1999                      Ultima Atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela debito.

   Alteracoes: 25/10/1999 - Alterado para pegar no nome resumido da 
                            cooperativa da variavel glb_nmrescop (Edson).

               01/02/2001 - Acrescentar o NO-ERROR nos FIND's (Eduardo).
               
               26/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               13/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)
                            
               25/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano).                             
               
               13/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero). 
                            
               16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)     
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................. */

{ includes/var_online.i } 

DEF        VAR tel_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_cdbccxlt AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_qtlanmto AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tel_dtrefere AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_vllanmto AS DECIMAL FORMAT "z,zzz,zzz,zzz,zz9.99" NO-UNDO.

DEF        VAR aux_confirma AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_pesquisa AS LOGICAL FORMAT "S/N"                  NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL                               NO-UNDO.
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR par_flgrodar AS LOGICAL      INIT TRUE                NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.

DEF STREAM str_1.

FORM SKIP (3)  
     glb_cddopcao AT 5 LABEL "Opcao" AUTO-RETURN
                  HELP "Opcao: C - Consulta ou R - Impressao"
                  VALIDATE (glb_cddopcao = "C" OR glb_cddopcao = "R",
                            "014 - Opcao errada.")
                            
     tel_cdagenci AT 17 LABEL "PA"
                  HELP "Informe o numero do PA."
                  VALIDATE(CAN-FIND(crapage WHERE
                                    crapage.cdcooper = glb_cdcooper AND
                                    crapage.cdagenci = tel_cdagenci),
                                    "962 - PA nao cadastrado.")
     
     tel_cdbccxlt AT 30 LABEL "Banco" 
                  HELP "Informe o numero do banco." 
                  VALIDATE(CAN-FIND(crapbcl WHERE
                                    crapbcl.cdbccxlt = tel_cdbccxlt),
                                    "057 - Banco/caixa nao cadastrado.")

     tel_dtrefere AT 45 LABEL "Data do debito"
                  HELP "Informe a data programada para debito."
 
     SKIP (3)
     "Qtd. documentos      Total a debitar"  AT 17    
     SKIP (1)
     tel_qtlanmto AT 25 NO-LABEL
     tel_vllanmto       NO-LABEL
     SKIP (6)
     WITH NO-LABELS SIDE-LABELS TITLE " Debitos automaticos "
          ROW 4 COLUMN 1  OVERLAY WIDTH 80 FRAME f_debito.

FORM craplau.cdhistor       LABEL "Cod"
     craphis.dshistor       LABEL "Historico" FORMAT "x(015)" 
     craplau.nrdconta       LABEL "Conta/dv"
     craplau.vllanaut       LABEL "Valor"     FORMAT "zz,zzz,zzz,zz9.99"
     craplau.nrdocmto       LABEL "Documento" FORMAT "zzz,zzz,zzz,zzz,zz9"
     WITH 11 DOWN NO-LABELS ROW 6 COLUMN 5 OVERLAY FRAME f_dados.

FORM "Mostrar os lancamentos?"    AT  2
     aux_pesquisa                 AUTO-RETURN
     "(S/N) "                     
      WITH NO-LABELS ROW 17 column 19 OVERLAY FRAME f_confirma.

FORM "Aguarde... Imprimindo o relatorio!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM craplau.cdhistor       LABEL "COD"
     craphis.dshistor       LABEL "HISTORICO" FORMAT "x(015)" 
     craplau.nrdconta       LABEL "CONTA/DV"
     craplau.vllanaut       LABEL "VALOR"     FORMAT "zz,zzz,zzz,zz9.99"
     craplau.nrdocmto       LABEL "DOCUMENTO" FORMAT "zzz,zzz,zzz,zzz,zz9"
     WITH DOWN NO-LABELS ROW 6 COLUMN 5 FRAME f_listar.

FORM "----------"        AT 31
     "-----------------" AT 42
     tel_qtlanmto        AT 31 FORMAT "zz,zzz,zz9"
     tel_vllanmto        AT 42 FORMAT "zz,zzz,zzz,zz9.99" 
     WITH NO-LABELS NO-BOX FRAME f_total.

FORM glb_nmrescop FORMAT "x(11)" NO-LABEL "- DEBITOS AUTOMATICOS"
     glb_dtmvtolt AT 52 LABEL "DATA DE EMISSAO" FORMAT "99/99/9999"
     SKIP(1)
     "PA:"       AT 12
     tel_cdagenci       NO-LABEL
     "BANCO DE PAGAMENTO:"
     tel_cdbccxlt       NO-LABEL
     "DATA DO DEBITO"
     tel_dtrefere       NO-LABEL
     SKIP(1)
     WITH SIDE-LABELS NO-BOX FRAME f_cabeca.
      
glb_cddopcao = "C".

DO WHILE TRUE:

   RUN fontes/inicia.p.

   CLEAR FRAME f_dados ALL NO-PAUSE.

   HIDE FRAME f_dados NO-PAUSE.

   DISPLAY glb_cddopcao WITH FRAME f_debito.
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               CLEAR FRAME f_debito NO-PAUSE.
               CLEAR FRAME f_dados ALL NO-PAUSE.
               glb_cdcritic = 0.
           END.

      UPDATE glb_cddopcao tel_cdagenci tel_cdbccxlt tel_dtrefere 
             WITH FRAME f_debito.
               
      IF   tel_dtrefere <= glb_dtmvtolt OR
           tel_dtrefere = ? THEN
           DO:
               glb_cdcritic = 013.
               NEXT-PROMPT tel_dtrefere WITH FRAME f_debito.
               NEXT.
           END.
       
      LEAVE.
   
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "DEBITO"   THEN
                 DO:
                     HIDE FRAME f_debito.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> INPUT glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = INPUT glb_cddopcao.
        END.

   IF   glb_cddopcao = "C" THEN
        DO:
            ASSIGN tel_qtlanmto = 0
                   tel_vllanmto = 0.
            
            MESSAGE "Aguarde...".  
                  
            FOR EACH craplau WHERE craplau.cdcooper = glb_cdcooper  AND
                                   craplau.cdagenci = tel_cdagenci  AND
                                  (craplau.cdbccxlt = 11            OR
                           /*      craplau.cdbccxlt = 100           OR  */
                                   craplau.cdbccxlt = 911)          AND
                                   craplau.dtmvtopg = tel_dtrefere  AND 
                                   craplau.cdbccxpg = tel_cdbccxlt  NO-LOCK:
                
                ASSIGN tel_qtlanmto = tel_qtlanmto + 1
                       tel_vllanmto = tel_vllanmto + craplau.vllanaut.
            END.
                                                          
            DISPLAY tel_qtlanmto tel_vllanmto WITH FRAME f_debito.

            PAUSE(0).

            aux_pesquisa = false.

            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               UPDATE aux_pesquisa WITH FRAME f_confirma.

               LEAVE.
 
            END.

            HIDE FRAME f_confirma NO-PAUSE.

            IF  aux_pesquisa THEN
                DO:
                    ASSIGN aux_regexist = FALSE
                           aux_flgretor = FALSE
                           aux_contador = 0.

                    HIDE MESSAGE NO-PAUSE.

                    FOR EACH craplau WHERE craplau.cdcooper = glb_cdcooper  AND
                                           craplau.cdagenci = tel_cdagenci  AND
                                          (craplau.cdbccxlt = 11            OR
                                           craplau.cdbccxlt = 911)          AND
                                           craplau.dtmvtopg = tel_dtrefere  AND 
                                           craplau.cdbccxpg = tel_cdbccxlt 
                                           NO-LOCK BY craplau.cdhistor         
                                                      BY craplau.nrdconta 
                                                         BY craplau.nrdocmto.

                        ASSIGN aux_regexist = TRUE
                               aux_contador = aux_contador + 1.

                        IF   aux_contador = 1   THEN
                             IF   aux_flgretor   THEN
                                  DO:
                                      PAUSE MESSAGE
                         "Tecle <Entra> para continuar ou <Fim> para encerrar".
                                      CLEAR FRAME f_dados ALL NO-PAUSE.
                                      HIDE MESSAGE NO-PAUSE.
                                  END.
                             ELSE
                                  aux_flgretor = TRUE.

                        FIND craphis NO-LOCK WHERE 
                               craphis.cdcooper = craplau.cdcooper AND 
                               craphis.cdhistor = craplau.cdhistor NO-ERROR.
                        
                        DISPLAY craplau.cdhistor craphis.dshistor
                                craplau.nrdconta craplau.vllanaut
                                craplau.nrdocmto  WITH FRAME f_dados.

                        IF   aux_contador = 11   THEN
                             aux_contador = 0.
                        ELSE
                             DOWN WITH FRAME f_dados.
 
                    END.  /*  Fim do FOR EACH  */

                    IF  aux_contador >= 1 AND
                        KEYFUNCTION(LASTKEY) <> "END-ERROR" THEN
                        DO:
                            PAUSE MESSAGE "Tecle qualquer tecla para encerrar".
                            HIDE MESSAGE NO-PAUSE.
                        END.

                    IF  aux_contador = 0 AND aux_regexist  THEN
                        DO:
                            PAUSE MESSAGE "Tecle qualquer tecla para encerrar".
                            HIDE MESSAGE NO-PAUSE.
                        END.
 
                    IF  NOT aux_regexist THEN
                        DO:
                            glb_cdcritic = 090.
                            RUN fontes/critic.p.
                            BELL.
                            MESSAGE glb_dscritic.
                            glb_cdcritic = 0.
                        END.

                END.
        END.
   ELSE
        IF   glb_cddopcao = "R"   THEN
             DO:
                 MESSAGE "Aguarde...".
                 
                 /* Acessar crapass e crapage para nao dar pau no
                    includes/impressao.i */
                    
                 FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                          NO-LOCK NO-ERROR.

                 FIND crapage WHERE crapage.cdcooper = glb_cdcooper     AND
                                    crapage.cdagenci = crapass.cdagenci 
                                    NO-LOCK NO-ERROR.

                 INPUT THROUGH basename `tty` NO-ECHO.

                 SET aux_nmendter WITH FRAME f_terminal.

                 INPUT CLOSE.
                 
                 aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                                       aux_nmendter. 

                 UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

                 ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) +                                        ".ex"
                        tel_qtlanmto = 0
                        tel_vllanmto = 0.

                 OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

                 PUT STREAM str_1 CONTROL "\022\024\033\120\0330" NULL.

                 DISPLAY STREAM str_1
                         glb_dtmvtolt tel_cdagenci tel_cdbccxlt tel_dtrefere 
                         glb_nmrescop
                         WITH FRAME f_cabeca.
                         
                 FOR EACH craplau WHERE craplau.cdcooper = glb_cdcooper AND
                                        craplau.cdagenci = tel_cdagenci AND
                                       (craplau.cdbccxlt = 11           OR
                                        craplau.cdbccxlt = 911)         AND
                                        craplau.dtmvtopg = tel_dtrefere AND 
                                        craplau.cdbccxpg = tel_cdbccxlt NO-LOCK
                                        BY craplau.cdhistor 
                                           BY craplau.nrdconta 
                                              BY craplau.nrdocmto.
     
                     FIND craphis NO-LOCK WHERE 
                               craphis.cdcooper = craplau.cdcooper AND 
                               craphis.cdhistor = craplau.cdhistor NO-ERROR.
                        
                     DISPLAY STREAM str_1 
                             craplau.cdhistor craphis.dshistor
                             craplau.nrdconta craplau.vllanaut
                             craplau.nrdocmto  WITH FRAME f_listar.

                     DOWN STREAM str_1 WITH FRAME f_listar.
    
                     ASSIGN tel_qtlanmto = tel_qtlanmto + 1
                            tel_vllanmto = tel_vllanmto + craplau.vllanaut.
                                                          
                 END.  /*  Fim do FOR EACH  */

                 DISPLAY STREAM str_1 
                         tel_qtlanmto tel_vllanmto WITH FRAME f_total.

                 OUTPUT STREAM str_1 CLOSE.         
                 HIDE MESSAGE NO-PAUSE.

                 VIEW FRAME f_aguarde.
                 PAUSE 3 NO-MESSAGE.
                 HIDE FRAME f_aguarde NO-PAUSE.

                  { includes/impressao.i } 
             END.
END.

