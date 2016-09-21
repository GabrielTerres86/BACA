/* .............................................................................

   Programa: Fontes/pesqsr.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson   (Guilherme)
   Data    : Novembro/92     (Maio/2007)       Ultima atualizacao: 19/08/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar movimentacoes de cheque do BB e Bancoob.

   Alteracoes: 29/05/2007 - Antiga tela PESQBB, alterado para PESQSR com suas
                            respectivas frames e nomes de includes(Guilherme).
               
               12/06/2007 - Excluida opcao "L" - pesquisa por lote e
                            substituida opcao "N" por "C" (Elton).
                            
               24/06/2007 - Criada opcao "D" - pesquisa por DOC/TED (Guilherme).
               
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 
            
               15/05/2012 - substituição do FIND craptab para os registros 
                            CONTACONVE pela chamada do fontes ver_ctace.p
                            (Lucas R.)
                            
               01/07/2014 - Incluir campo "Age.Acl." na "ORIGEM DO LANCAMENTO".
                            (Reinert) 
                            
               18/09/2014 - Incluir campo "Coop." ao lado de “Bco Chq” para
                            mostrar o código da agência do cheque (Vanessa)  
                            
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).                           
               
............................................................................. */

{ includes/var_online.i }

DEF        VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR tel_cdagenci AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_cdbccxlt AS INT     FORMAT "zz9"                  NO-UNDO.
DEF        VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tel_nrdconta AS INT     FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR tel_nrdocmto AS INT     FORMAT "z,zzz,zzz,9"          NO-UNDO.
DEF        VAR tel_nrdctabb AS INT     FORMAT "z,zzz,zzz,9"          NO-UNDO.
DEF        VAR tel_nrdctabb_x  LIKE    crapass.nrdctitg              NO-UNDO.
DEF        VAR tel_nrseqimp AS INT     FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR tel_vllanmto AS DECIMAL FORMAT "zzzz,zzz,zz9.99"      NO-UNDO.
DEF        VAR tel_vldoipmf AS DECIMAL FORMAT "z,zzz,zz9.99"         NO-UNDO.
DEF        VAR tel_cdpesqbb AS CHAR    FORMAT "x(31)"                NO-UNDO.
DEF        VAR tel_nmprimtl AS CHAR    FORMAT "x(40)"                NO-UNDO.
DEF        VAR tel_dsagenci AS CHAR    FORMAT "x(21)"                NO-UNDO.
DEF        VAR tel_cdturnos AS INT     FORMAT "z9"                   NO-UNDO.
DEF        VAR tel_nrfonemp AS CHAR    FORMAT "X(20)"                NO-UNDO.
DEF        VAR tel_nrramemp AS INT     FORMAT "9999"                 NO-UNDO.
DEF        VAR tel_dscritic AS CHAR    FORMAT "x(20)"                NO-UNDO.


DEF        VAR tel_cdbanchq AS CHAR FORMAT "x(09)"                   NO-UNDO.
DEF        VAR tel_sqlotchq LIKE craplcm.sqlotchq                    NO-UNDO.
DEF        VAR tel_cdcmpchq LIKE craplcm.cdcmpchq                    NO-UNDO.
DEF        VAR tel_nrlotchq LIKE craplcm.nrlotchq                    NO-UNDO.
DEF        VAR tel_nrctachq LIKE craplcm.nrctachq                    NO-UNDO.
DEF        VAR tel_cdbaninf LIKE crapfdc.cdbanchq                    NO-UNDO.
/*DEF        VAR tel_cdagechq LIKE crapfdc.cdagechq                    NO-UNDO.*/
DEF        VAR tel_cdagechq AS INT     FORMAT "zzz9"                  NO-UNDO.
DEF        VAR tel_cdagetfn LIKE craplcm.cdagetfn                    NO-UNDO.


DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.

DEF        VAR aux_nrdigitg AS CHAR                                  NO-UNDO.

DEF        VAR aux_dtlimite AS DATE                                  NO-UNDO.

DEF        VAR aux_flgretor AS LOGICAL                               NO-UNDO.
DEF        VAR aux_regexist AS LOGICAL                               NO-UNDO.
DEF        VAR aux_lsconta1 AS CHAR                                  NO-UNDO.
DEF        VAR aux_lsconta2 AS CHAR                                  NO-UNDO.
DEF        VAR aux_lsconta3 AS CHAR                                  NO-UNDO.
DEF        VAR aux_cdagechq AS CHAR                                  NO-UNDO.
DEF        VAR aux_ctamigra AS LOGICAL                               NO-UNDO.
DEF        VAR aux_cdagectl LIKE crapcop.cdagectl EXTENT 99          NO-UNDO.

/* variaveis para conta de integracao */
DEF BUFFER crabass5 FOR crapass.
DEF     VAR aux_nrctaass AS INT       FORMAT "zzzz,zzz,9"            NO-UNDO.
DEF     VAR aux_ctpsqitg LIKE craplcm.nrdctabb                       NO-UNDO.
DEF     VAR aux_nrdctitg LIKE crapass.nrdctitg                       NO-UNDO.

DEF BUFFER crabcop FOR crapcop.

{ includes/proc_conta_integracao.i }

FORM SKIP(1)
     glb_cddopcao AT  7 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada 'C' ou 'D'."      
                        VALIDATE (glb_cddopcao = "C" OR glb_cddopcao = "D", 
                                        "014 - Opcao errada.") 
      " C = Pelo numero do Cheque, D = Creditos(DOC/TED)"  
     SKIP(1)
"Data    PA  Bco/Cxa  Lote   Conta/dv    Docto    Cta.Chq/Base Bco.Chq Coop"
                             
     AT 5 SKIP(1)
     tel_dtmvtolt AT  2 NO-LABEL AUTO-RETURN
                        HELP "Informe a data do movimento"
                        VALIDATE(tel_dtmvtolt >= aux_dtlimite   AND
                                 tel_dtmvtolt <= glb_dtmvtolt,
                                 "013 - Data errada")

     tel_cdagenci AT 12 NO-LABEL AUTO-RETURN
                        HELP "Informe o PA do movimento"
                        VALIDATE(CAN-FIND(crapage WHERE
                                          crapage.cdcooper = glb_cdcooper AND 
                                          crapage.cdagenci = tel_cdagenci),
                                          "015 - PA nao cadastrado")

     tel_cdbccxlt AT 18 NO-LABEL AUTO-RETURN
                        HELP "Informe o banco do movimento"
                        VALIDATE(CAN-FIND(crapbcl WHERE
                                          crapbcl.cdbccxlt = tel_cdbccxlt),
                                          "057 - Banco nao cadastrado")

     tel_nrdolote AT 24 NO-LABEL AUTO-RETURN
                        HELP "Informe o lote do movimento"
                        VALIDATE(tel_nrdolote > 0,"058 - Numero do lote errado")

     tel_nrdconta AT 31 NO-LABEL AUTO-RETURN
                        HELP "Informe a conta do associado"
                        VALIDATE(tel_nrdconta > 0,"008 - Digito errado")
                        
     tel_nrdocmto AT 44 NO-LABEL AUTO-RETURN
                        HELP "Informe do numero do documento"
                        VALIDATE(tel_nrdocmto > 0,"008 - Digito errado")

     tel_nrdctabb AT 56 NO-LABEL AUTO-RETURN
                        HELP "Informe o numero da conta base ou do cheque"
                        VALIDATE(tel_nrdctabb > 0,"008 - Digito errado")

     tel_cdbaninf AT 68 NO-LABEL AUTO-RETURN
                        HELP "Informe o banco do cheque"

     tel_cdagechq AT 75 NO-LABEL AUTO-RETURN
                       
    
     SKIP(1)
     "Valor do Docto.  Codigo de Pesquisa" AT 2
     "Sequencia   Valor da CPMF" AT 52
     SKIP
     tel_vllanmto AT 02 NO-LABEL
     tel_cdpesqbb AT 19 NO-LABEL
     tel_nrseqimp AT 54 NO-LABEL
     tel_vldoipmf AT 65 NO-LABEL
     SKIP(1)
     tel_nmprimtl AT  2 LABEL "Titular"
     tel_dsagenci AT 53 LABEL "PA"
     tel_cdturnos       LABEL "Tu"
     tel_nrfonemp       LABEL "Fone"
     tel_nrramemp       LABEL "Ramal"
     SKIP(1)
     SPACE(29) tel_dscritic NO-LABEL 
     SKIP
     tel_cdagetfn LABEL "Age.Acl."
     SKIP
     tel_cdbanchq LABEL "Bco/Age" COLON 9
     SPACE(1)
     tel_cdcmpchq LABEL "Comp"
     SPACE(1)
     tel_nrlotchq LABEL "Lote"
     SPACE(1)
     tel_sqlotchq LABEL "Sq"
     SPACE(1)                           
     tel_nrctachq LABEL "Conta"  FORMAT "zzzzzzzzzzzz" 
     WITH ROW 4 OVERLAY SIDE-LABELS TITLE glb_tldatela FRAME f_pesqsr.

/*  Busca dados da cooperativa  */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         BELL.
         glb_cdcritic = 0.
         NEXT.
     END.

ASSIGN tel_dscritic = "ORIGEM DO LANCAMENTO"
       glb_cddopcao = "C"
       glb_cdcritic = 0
       aux_dtlimite = IF MONTH(glb_dtmvtolt) = 01
                         THEN DATE(12,01,YEAR(glb_dtmvtolt) - 1)
                         ELSE DATE(MONTH(glb_dtmvtolt) - 1,01,
                                    YEAR(glb_dtmvtolt)).

/*  Le tabela com as contas convencio do Banco do Brasil - talao normal */

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 1,
                       OUTPUT aux_lsconta1).

/*  Le tabela com as contas convencio do Banco do Brasil - talao transf.*/

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 2,
                       OUTPUT aux_lsconta2).

/*  Le tabela com as contas convencio do Banco do Brasil - chq.salario */

RUN fontes/ver_ctace.p(INPUT glb_cdcooper,
                       INPUT 3,
                       OUTPUT aux_lsconta3).

FOR EACH crabcop FIELDS (cdcooper cdagectl) NO-LOCK:

    ASSIGN aux_cdagectl[crabcop.cdcooper] = crabcop.cdagectl.

END.

DO WHILE TRUE:

   RUN fontes/inicia.p.

   COLOR DISPLAY MESSAGES tel_dscritic WITH FRAME f_pesqsr.

   DISPLAY tel_dscritic WITH FRAME f_pesqsr. 
   
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE glb_cddopcao WITH FRAME f_pesqsr.
      LEAVE.

   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN    /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   glb_nmdatela <> "PESQSR"   THEN
                 DO:
                     HIDE FRAME f_pesqsr.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   IF   aux_cddopcao <> glb_cddopcao   THEN
        DO:
            { includes/acesso.i}
            aux_cddopcao = glb_cddopcao.
        END.

   IF   glb_cddopcao = "C"   THEN
        DO:  
            { includes/pesqsrc.i }
        END.
                             
   IF   glb_cddopcao = "D"   THEN
        DO:
            { includes/pesqsrd.i }
        END.
                               
END.  /*  Fim do DO WHILE TRUE  */

/* .......................................................................... */

