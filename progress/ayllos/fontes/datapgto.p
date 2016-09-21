/* .............................................................................

   Programa: fontes/datapgto.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   
   Alteracoes: 10/11/2013 - Inclusao de VALIDATE craptab (Carlos)
............................................................................. */
DEF INPUT  PARAM par_cdcooper AS INT                          NO-UNDO.

DEF          VAR aux_cdempres AS INT  FORMAT "zz9"            NO-UNDO.
DEF          VAR aux_nrdiames AS INT  FORMAT "z9"             NO-UNDO.
DEF          VAR aux_nrdiahor AS INT  FORMAT "z9"             NO-UNDO.
DEF          VAR aux_nrmesnov AS INT  FORMAT "z9"             NO-UNDO.
DEF          VAR aux_qtdiacar AS INT  FORMAT "999"            NO-UNDO.

DO WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

   UPDATE aux_cdempres LABEL "Empresa"
          WITH FRAME f_finalidade TITLE " Pagto da Empresas ".

   FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                      craptab.nmsistem = "CRED"         AND
                      craptab.tptabela = "GENERI"       AND
                      craptab.cdempres = 0              AND
                      craptab.cdacesso = "DIADOPAGTO"   AND
                      craptab.tpregist = aux_cdempres   EXCLUSIVE-LOCK NO-ERROR.

   IF   NOT AVAILABLE craptab   THEN
        DO:
            CREATE craptab.
            ASSIGN craptab.nmsistem = "CRED"
                   craptab.tptabela = "GENERI"
                   craptab.cdempres = 0
                   craptab.cdacesso = "DIADOPAGTO"
                   craptab.tpregist = aux_cdempres
                   craptab.cdcooper = par_cdcooper.

            VALIDATE craptab.
        END.
   ELSE
        ASSIGN aux_nrmesnov = INTEGER(SUBSTRING(craptab.dstextab,1,2))
               aux_nrdiames = INTEGER(SUBSTRING(craptab.dstextab,4,2))
               aux_nrdiahor = INTEGER(SUBSTRING(craptab.dstextab,7,2))
               aux_qtdiacar = INTEGER(SUBSTRING(craptab.dstextab,10,3)).

   UPDATE aux_nrmesnov lABEL "Mes Novo"
          aux_nrdiames LABEL "Mensalista"
          aux_nrdiahor LABEL "Horista"
          aux_qtdiacar LABEL "Carencia"
          WITH FRAME f_finalidade SIDE-LABELS.

   craptab.dstextab = STRING(aux_nrmesnov,"99")  + " " +
                      STRING(aux_nrdiames,"99")  + " " +
                      STRING(aux_nrdiahor,"99")  + " " +
                      STRING(aux_qtdiacar,"999") + " 0".

   CLEAR FRAME f_finalidade NO-PAUSE.
END.
                               
/* .......................................................................... */

