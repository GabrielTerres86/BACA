/* .............................................................................

   Programa: Fontes/tab090.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Adriano/CECRED 
   Data    : Abril/2011                          Ultima alteracao:  07/12/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : TAB090 - Parametros Central Tx. Pre-fixadas.
   
   Alteracao : 14/09/2011 - Alteracao para considerar a taxa de multa como 
                            decimal (Vitor - GATI).

               20/04/2015 - Modificacao para colocar numa TRANSACTION a opcao 
                            de alteracao pois nao estava salvando os dados. 
                            (Jaison/Gielow - SD: 277755)
              
               02/06/2015 - Adicionado campo percentual na tela.
                            Projeto Portabilidade (Lombardi)

               07/12/2016 - Alterado campo dsdepart para cddepart.
                            PRJ341 - BANCENJUD (Odirlei-AMcom)
                            
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_cdagenci AS INT                                    NO-UNDO.
DEF        VAR tel_qtdparce AS INT FORMAT "999"                       NO-UNDO.
DEF        VAR tel_percmult AS DEC FORMAT "999.99"                    NO-UNDO.  
DEF        VAR tel_percatua AS DEC FORMAT "999.99"                    NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                   NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                     NO-UNDO.
DEF        VAR aux_contador AS INT                                    NO-UNDO.   

DEF        VAR log_percmult AS DEC FORMAT "999.99"                    NO-UNDO.
DEF        VAR log_qtdparce AS INT FORMAT "999"                       NO-UNDO.
DEF        VAR log_percatua AS INT FORMAT "999.99"                    NO-UNDO.


FORM WITH ROW 4 COLUMN 1 OVERLAY TITLE glb_tldatela SIZE 80 BY 18 
     FRAME f_titulo.

FORM SKIP(1)
     glb_cddopcao AT 10 LABEL "Opcao" AUTO-RETURN FORMAT "!"
                           HELP "Entre com a opcao desejada (A,C)."
                           VALIDATE(CAN-DO("A,C",glb_cddopcao),
                                    "014 - Opcao errada.")
     SKIP(2)
     tel_percmult AT 31 LABEL "Perc. de multa"
          HELP "Informe o percentual para multa."
          VALIDATE(tel_percmult <> 0 ,"357 - O campo deve ser prenchido.")
     SKIP(1)
     tel_qtdparce AT 12 LABEL "Qtd. Parcelas Curto x Longo prazo"
         HELP "Informe a quantidade de parcelas."
         VALIDATE(tel_qtdparce <> 0,"357 - O campo deve ser prenchido.")   
     SKIP(1)
     tel_percatua AT 2 LABEL "Perc. atualização proposta de portabilidade"
         HELP "Informe o percentual da atualização proposta."
         VALIDATE(tel_percatua <> 0, "357 - O campo deve ser prenchido.")
     WITH WIDTH 78 CENTERED ROW 5 OVERLAY NO-BOX SIDE-LABELS FRAME f_tab090.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       glb_cdprogra = "tab090".
       

VIEW FRAME f_titulo.
PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.

   IF   glb_cdcritic <> 0  THEN
        DO:
            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            glb_cdcritic = 0.
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_tab090.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "tab090"   THEN
                 DO:
                     HIDE FRAME f_tab090.
                     HIDE FRAME f_titulo.
                     RETURN.
                 END.
            NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            aux_cddopcao = glb_cddopcao.
        END.

   IF glb_cddopcao = "C" THEN
      DO:
         FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                            craptab.nmsistem = "CRED"       AND
                            craptab.tptabela = "USUARI"     AND
                            craptab.cdempres = 11           AND
                            craptab.cdacesso = "PAREMPCTL"  AND
                            craptab.tpregist = 01
                            NO-LOCK NO-ERROR.
        
         IF AVAIL craptab THEN
            DO:
                ASSIGN tel_percmult = DEC(SUBSTRING(craptab.dstextab,1,6))
                       tel_qtdparce = INT(SUBSTRING(craptab.dstextab,8,3))
                       tel_percatua = INT(SUBSTRING(craptab.dstextab,13,6)).
                
            END.
         ELSE 
            DO:
               MESSAGE "Informacoes nao encontradas.".
               BELL.
               PAUSE(2) NO-MESSAGE.
               RETURN.
      
            END.
           
         DISP tel_percmult
              tel_qtdparce
              tel_percatua
              WITH FRAME f_tab090.

      END.
  ELSE
     IF glb_cddopcao = "A" THEN      
        DO TRANSACTION:

            IF   glb_cddepart <> 20  AND  /* TI             */
                 glb_cddepart <>  9  AND  /* COORD.PRODUTOS */
                 glb_cddepart <> 14  THEN /* PRODUTOS       */
                 DO:
                    glb_cdcritic = 36.
                    NEXT.
                 END.
                
            FIND craptab WHERE craptab.cdcooper = glb_cdcooper AND
                               craptab.nmsistem = "CRED"       AND
                               craptab.tptabela = "USUARI"     AND
                               craptab.cdempres = 11           AND
                               craptab.cdacesso = "PAREMPCTL"  AND
                               craptab.tpregist = 01
                               EXCLUSIVE-LOCK NO-ERROR.

            IF AVAIL craptab THEN
               DO:
                  ASSIGN tel_percmult = DEC(SUBSTRING(craptab.dstextab,1,6))
                         tel_qtdparce = INT(SUBSTRING(craptab.dstextab,8,3))
                         tel_percatua = INT(SUBSTRING(craptab.dstextab,13,6))
                         log_percmult = DEC(SUBSTRING(craptab.dstextab,1,6))
                         log_qtdparce = INT(SUBSTRING(craptab.dstextab,8,3))
                         log_percatua = INT(SUBSTRING(craptab.dstextab,13,6)).


                  DO ON ENDKEY UNDO, LEAVE:
              
                      UPDATE tel_percmult
                             tel_qtdparce
                             tel_percatua 
                             WITH FRAME f_tab090.
                                    
                      IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /*   F4 OU FIM */
                           NEXT.
                  
                      /* Se nao modificou nada ... NEXT */
                      IF   NOT (tel_percmult <> log_percmult  OR 
                                tel_qtdparce <> log_qtdparce  OR 
                                tel_percatua <> log_percatua) THEN
                           NEXT.
              
                      RUN fontes/confirma.p (INPUT "",
                                             OUTPUT aux_confirma).
                  
                      IF   aux_confirma <> "S"   THEN
                           NEXT.

                      ASSIGN SUBSTRING(craptab.dstextab,1,6)   = STRING(tel_percmult,"999.99")
                             SUBSTRING(craptab.dstextab,8,3)   = STRING(tel_qtdparce,"999")
                             SUBSTRING(craptab.dstextab,13,6)  = STRING(tel_percatua,"999.99").
             
                      RUN gera_log (INPUT glb_cddopcao,
                                    INPUT log_percmult, 
                                    INPUT log_qtdparce, 
                                    INPUT log_percatua, 
                                    INPUT tel_percmult, 
                                    INPUT tel_qtdparce,
                                    INPUT tel_percatua).
              
                      LEAVE.

                  END.
               END.
            ELSE
               DO:
                  MESSAGE "Informacoes nao encontradas.".
                  BELL.
                  PAUSE(2) NO-MESSAGE.
                  RETURN.

               END.
        END.

END.  /*  Fim do DO WHILE TRUE  */


/* .......................................................................... */


PROCEDURE gera_log:

    DEF INPUT PARAM par_cddopcao LIKE glb_cddopcao      NO-UNDO.    
    DEF INPUT PARAM par_percmult AS DEC                 NO-UNDO.    
    DEF INPUT PARAM par_qtdparce AS INT                 NO-UNDO.   
    DEF INPUT PARAM par_percatua AS DEC                 NO-UNDO.   
    DEF INPUT PARAM par_prclmult AS DEC                 NO-UNDO.    
    DEF INPUT PARAM par_qtddparc AS INT                 NO-UNDO.   
    DEF INPUT PARAM par_prclatua AS DEC                 NO-UNDO.    


    UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt,"99/99/9999") +
                      " "     + STRING(TIME,"HH:MM:SS")  + "' --> '"      +
                      " Operador " + glb_cdoperad + " - " + "Alterou"     +
                      (IF par_percmult <> par_prclmult THEN
                      " o percentual da multa de " + STRING(par_percmult) + 
                      " para "  +
                      (IF par_percmult = par_prclmult THEN 
                        "---" ELSE
                        STRING(par_prclmult)) ELSE
                        "") +
                      (IF par_qtdparce <> par_qtddparc THEN
                      " a quantidade de parcelas de " + STRING(par_qtdparce) + 
                      " para "           + 
                      (IF par_qtdparce = par_qtddparc THEN
                        "---" ELSE 
                        STRING (par_qtddparc)) ELSE
                      "") +
                      (IF par_percatua <> par_prclatua THEN
                      " o percentual da multa de " + STRING(par_percatua) + 
                      " para "  +
                      (IF par_percatua = par_prclatua THEN 
                        "---" ELSE
                        STRING(par_prclatua)) ELSE
                        "") +
                       "." + " >> log/tab090.log").



END PROCEDURE.
