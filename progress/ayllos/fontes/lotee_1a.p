/* .............................................................................

   Programa: fontes/lotee_1a.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   
   Alteracoes: 29/05/2009 - Inclui "9" mais o codigo da cooperativa na conta do
                            cooperado se for diferente de Viacredi ou CECRED ou
                            se convenio for Unimed ou Uniodonto (Elton).
                            
               20/09/2013 - Adicionado format no par_cdagenci. (Reinert)
               
               23/10/2014 - Tratamento para o campo Usa Agencia 
                            (gnconve.flgagenc); convenios a partir de 2014.
                            (Fabricio)
   
............................................................................. */
{ includes/var_online.i }

DEF INPUT  PARAM par_cdhistor AS INT                          NO-UNDO.
DEF OUTPUT PARAM par_cdagenci AS CHAR                         NO-UNDO.
DEF OUTPUT PARAM par_cdcooperativa AS CHAR   FORMAT "x(04)"   NO-UNDO.

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

ASSIGN par_cdcooperativa = "8888".
FOR EACH gncvcop NO-LOCK WHERE
         gncvcop.cdcooper = crapcop.cdcooper:

    FOR EACH  gnconve NO-LOCK WHERE
              gnconve.cdconven = gncvcop.cdconven AND
              gnconve.flgativo = YES              AND
              gnconve.cdhisdeb > 0                AND
              gnconve.nmarqdeb <> " "             AND
              gnconve.cdhisdeb = par_cdhistor:
 
         ASSIGN par_cdagenci = STRING(crapcop.cdagectl,"9999").
             
        IF  (gnconve.cdcooper = crapcop.cdcooper  OR
             crapcop.cdcooper = 1                 OR
             gnconve.flgagenc = TRUE)             AND
             gnconve.cdconven <> 22               AND
             gnconve.cdconven <> 32               AND  /*UNIODONTO*/ 
             gnconve.cdconven <> 38               AND  /*UNIM.PLAN.NORTE*/
             gnconve.cdconven <> 43               AND  /*SERVMED*/
             gnconve.cdconven <> 46               AND  /*UNIODONTO FEDER.*/
             gnconve.cdconven <> 47               AND  /*UNIMED CREDCREA*/
             gnconve.cdconven <> 55               AND  /*LIBERTY*/
             gnconve.cdconven <> 57               AND  /*RBS*/
             gnconve.cdconven <> 58               THEN /*PORTO SEGURO*/
            ASSIGN par_cdcooperativa = " ".
        ELSE
            ASSIGN par_cdcooperativa = "9" + STRING(crapcop.cdcooper,"999").
        LEAVE.
   END.
END.

RETURN.
 
