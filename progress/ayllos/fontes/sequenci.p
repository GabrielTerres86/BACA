/* .............................................................................

   Programa: Fontes/sequenci.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo
   Data    : Abril/2001.                         Ultima atualizacao:   /  /

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Entrar com a linha sequencial do codigo barra tipo 3. 
               Para faturas de 2a via onde nao existe o cod. barras.

   Alteracoes: 
............................................................................. */

{ includes/var_online.i }

DEF INPUT  PARAM par_cddopcao AS CHAR                                NO-UNDO.
DEF OUTPUT PARAM par_dscodbar AS CHAR                                NO-UNDO.

DEF VAR tel_nrdigtcc AS INTEGER FORMAT "99"                          NO-UNDO.
DEF VAR tel_nrdigvl1 AS INTEGER FORMAT "99"                          NO-UNDO.
DEF VAR tel_nrdigvl2 AS INTEGER FORMAT "99"                          NO-UNDO.
DEF VAR tel_cdseqfat AS DECIMAL FORMAT "zzzzzzzzzzzzzzzzzzz9"        NO-UNDO.
DEF VAR tel_dtfatura AS INTEGER FORMAT "9999"                        NO-UNDO.
DEF VAR tel_vlfatura AS DECIMAL FORMAT "zzzz,zz9.99"                 NO-UNDO.
DEF VAR tel_nrdconta AS DECIMAL FORMAT "zzzz,zzz,9"                  NO-UNDO.

DEF VAR aux_nrdigver AS INTEGER                                      NO-UNDO.
DEF VAR aux_flgopcao AS LOGICAL FORMAT "S/N"  INIT "S"               NO-UNDO.
DEF VAR aux_nrcalcul AS CHAR                                         NO-UNDO.
                                  
FORM  SKIP(1)
     "   Conta       DV   Fat.   Tot. a Pagar   DV             Sequencial   DV"
      SKIP(1)
      WITH ROW 13 COLUMN 2 OVERLAY 2 DOWN WIDTH 78
                       TITLE " Sequencial " FRAME f_moldura.

FORM                    
     tel_nrdconta AT  3 NO-LABEL AUTO-RETURN
                        HELP "Entre com a conta."
                        VALIDATE (tel_nrdconta > 0, "127 - Conta errada")

     tel_nrdigtcc AT 15 NO-LABEL 
                        HELP "Entre com o digito da conta."

     tel_dtfatura AT 20 NO-LABEL 
                        HELP "Informe o faturamento."
                        VALIDATE (tel_dtfatura < 1300, "013 - Data errada")     

     tel_vlfatura AT 28 NO-LABEL AUTO-RETURN
                        HELP "Entre com o total a pagar."
                        VALIDATE (tel_vlfatura > 0,
                                  "091 - Valor do lancamento errado.")

     tel_nrdigvl1 AT 42 NO-LABEL 
                        HELP "Entre com o digito do total a pagar."

     tel_cdseqfat AT 47 NO-LABEL 
                        HELP "Informe o numero sequencial da fatura."
                        VALIDATE (tel_cdseqfat > 0,"117 - Sequencia Errada.")

     tel_nrdigvl2 AT 70 NO-LABEL 
                        HELP "Entre com o digito do total a pagar."

     WITH ROW 17 COLUMN 4 OVERLAY NO-LABELS NO-BOX FRAME f_sequencia.

par_dscodbar = "".

IF   par_cddopcao = "E" THEN     /*   Opcao Excluir  */
     DO:
          VIEW FRAME f_moldura.
          
          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

             IF   glb_cdcritic > 0 THEN
                  DO:
                      RUN fontes/critic.p.
                      BELL.
                      MESSAGE glb_dscritic.
                      glb_cdcritic = 0.
                  END.

             PAUSE(0).
             
             UPDATE  tel_cdseqfat  WITH FRAME f_sequencia.

             par_dscodbar = "000000000000000000000000000000" + 
                             STRING(tel_cdseqfat,"999999999999") + "00".
             
             LEAVE.

          END.  /*  Fim do DO WHILE TRUE  */

          HIDE FRAME f_moldura   NO-PAUSE.
          HIDE FRAME f_sequencia NO-PAUSE.       
     
     END.   /*  Fim  do IF par_cddopcao = "E"  */
ELSE                           /*    Opcao Incluir  */
     DO:
        MESSAGE "Deseja digitar o sequencial da fatura ? (S/N)"  
                 UPDATE aux_flgopcao.   
        
        IF   aux_flgopcao THEN
             DO:
                 VIEW FRAME f_moldura.             

                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    PAUSE(0).
                    
                    UPDATE  tel_nrdconta  tel_nrdigtcc  tel_dtfatura
                            tel_vlfatura  tel_nrdigvl1  tel_cdseqfat
                            tel_nrdigvl2  WITH FRAME f_sequencia

                    EDITING:

                             READKEY.
                             IF   FRAME-FIELD = "tel_vlfatura"   THEN
                                  IF   LASTKEY =  KEYCODE(".")   THEN
                                       APPLY 44.
                                  ELSE
                                       APPLY LASTKEY.
                             ELSE  
                                  APPLY LASTKEY.

                    END.  /*  Fim do EDITING  */
                       
                    /*    Calcula digito verificador   */
                             
                    glb_nrcalcul = tel_cdseqfat.
                                                    
                    RUN fontes/digfun.p.
                         
                    IF   NOT glb_stsnrcal   THEN
                         DO:
                             glb_cdcritic = 8.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             PAUSE 5 NO-MESSAGE.
                             glb_cdcritic = 0.
                             NEXT-PROMPT tel_cdseqfat WITH FRAME f_sequencia.
                             NEXT.
                         END.
                         
                    ASSIGN aux_nrcalcul = STRING(tel_cdseqfat,"999999999999") +
                                    STRING((tel_vlfatura * 100),"999999999999") 
                                    +  SUBSTR(STRING(tel_nrdigvl2,"99"),1,1)
                           glb_nrcalcul = DECIMAL(aux_nrcalcul).

                    RUN fontes/digsam.p.

                    IF   NOT glb_stsnrcal   THEN
                         DO:
                             glb_cdcritic = 8.
                             RUN fontes/critic.p.
                             BELL.
                             MESSAGE glb_dscritic.
                             PAUSE 5 NO-MESSAGE.
                             glb_cdcritic = 0.
                             NEXT-PROMPT tel_nrdigvl2 WITH FRAME f_sequencia.
                             NEXT.
                         END.

                    /*  Calcula digito verificador da linha do sequencial 
                        e compoe o codigo de  barras  */
       
                    glb_nrcalcul = DECIMAL("8361" +
                                   STRING(tel_vlfatura * 100,"99999999999") +
                                   "0008" +
                                   STRING(tel_nrdigtcc,"99") +
                                   STRING(tel_nrdigvl1,"99") +
                                   "003" +
                                   STRING(tel_dtfatura,"9999") +
                                   STRING(tel_cdseqfat,"999999999999") +
                                   STRING(tel_nrdigvl2,"99")).

                    RUN fontes/cdbarra3.p (OUTPUT aux_nrdigver).
   
                    par_dscodbar = "836" +  STRING(aux_nrdigver,"9") +
                                   STRING(tel_vlfatura * 100,"99999999999") +
                                   "0008" + STRING(tel_nrdigtcc,"99") +
                                   STRING(tel_nrdigvl1,"99") + "003" +
                                   STRING(tel_dtfatura,"9999") +
                                   STRING(tel_cdseqfat,"999999999999") +
                                    STRING(tel_nrdigvl2,"99").
                  
                    LEAVE.

                 END.  /*  Fim do DO WHILE TRUE  */

                 HIDE FRAME f_moldura   NO-PAUSE.
                 HIDE FRAME f_sequencia NO-PAUSE.
             END.   /*  Fim  do IF aux_flgopcao    */

     END.    /*  Fim  do IF par_cddopcao = "I"   */

IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     
     par_dscodbar = "".

/* .......................................................................... */