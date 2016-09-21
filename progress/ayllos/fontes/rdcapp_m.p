/* .............................................................................
   
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   ESTE PROGRAMA ESTA SENDO DESABILITADO, POIS NAO EXISTE MAIS POUPANÇA EM 
   ESTUDO. 
   Utilizado só o fontes/rdcapp_n.p 
   28/04/2010. (Gabriel)
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
   
   
   Programa: Fontes/rdcapp_m.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Marco/96.                       Ultima atualizacao: 28/04/2010

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para impressao da proposta da poupanca programada.

   Alteracoes: 19/09/96 - Alterado para passar novo parametro "M" moeda para a
                          rotina extenso.p (Odair).

               25/10/1999 - Substituir "CREDIHERING" por glb_nmrescop (Edson).

               10/07/2002 - Imprimir nome completo da Coop (Margarete).
               
               09/12/2003 - Buscar nome da cidade no crapcop (Junior).

               03/03/2004 - Usar taxa Cdi (Margarete).

               22/09/2004 - Aumentado campo nro poupanca prog.(Mirtes).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando.
               
               24/04/2008 - Alteracao do contrato para prazo determinado e nova
                            Classificacao Bacen(Guilherme).
                            
               04/11/2008 - Retirado constante da UF "SC" e colocado campo de
                            arquivo (Martin).

............................................................................. */

DEF INPUT PARAM par_recidrpp AS INT                                  NO-UNDO.

DEF STREAM str_1.

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_rdcapp.i }

DEF        VAR rel_ddaniver AS INT                                   NO-UNDO.
DEF        VAR rel_nranoini AS INT                                   NO-UNDO.
DEF        VAR rel_nrdiargt AS INT                                   NO-UNDO.
DEF        VAR rel_dsprerpp AS CHAR    EXTENT 2                      NO-UNDO.
DEF        VAR rel_nrdocnpj AS CHAR                                  NO-UNDO.
DEF        VAR rel_dsmesano AS CHAR                                  NO-UNDO.
DEF        VAR rel_nmprimtl AS CHAR                                  NO-UNDO.
DEF        VAR rel_vlprerpp AS DECIMAL                               NO-UNDO.

DEF        VAR rll_nrctrrpp AS INTE FORMAT "z,zzz,zz9"               NO-UNDO.
DEF        VAR rll_vlprerpp AS DECI FORMAT "zzzz,zzz,zz9.99"         NO-UNDO.
DEF        VAR rll_dtvctopp AS DATE                                  NO-UNDO.

DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.

DEF        VAR par_flgrodar AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.

DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.

DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        var aux_txaplica AS DEC     FORMAT "Z9.99"                NO-UNDO.

DEF        VAR rel_nmrescop AS CHAR    EXTENT 2                      NO-UNDO.
DEF        VAR aux_qtpalavr AS INTE                                  NO-UNDO.
DEF        VAR aux_contapal AS INTE                                  NO-UNDO.
DEF        VAR aux_nmcidade AS CHAR                                  NO-UNDO.

FORM SKIP(3)
     crapcop.nmextcop AT 18 FORMAT "x(50)"
     SKIP
     rel_nrdocnpj AT 29 FORMAT "x(25)"
     SKIP(3)
     "AUTORIZACAO DE DEBITO EM CONTA-CORRENTE PARA CREDITO NA" AT 3
     "POUPANCA PROGRAMADA" AT 59
     SKIP
     "========================================================" AT 3
     "===================" AT 59
     SKIP(3)
     crapass.nrdconta AT  2 FORMAT "zzzz,zzz,9" LABEL "Conta/dv"
     rll_nrctrrpp AT 25 FORMAT "z,zzz,zz9" LABEL "Numero da Poupanca"
     rll_vlprerpp AT 57 FORMAT "zzzz,zzz,zz9.99" LABEL "Valor"
     SKIP(1)
     crapass.nmprimtl AT  1 FORMAT "x(40)" LABEL "Associado"
     rel_ddaniver     AT 57 FORMAT "99" LABEL "Dia do Aniversario"
     SKIP(2)
     "O associado acima qualificado, autoriza um debito mensal   em "
     "conta-corrente de" SKIP
     "depositos  a  vista,  com   vencimento  em " 
     rll_dtvctopp FORMAT "99/99/9999" ",  na   importancia  de" SKIP
     "R$" rel_vlprerpp FORMAT "zzz,zzz,zz9.99" NO-LABEL 
     rel_dsprerpp[1] FORMAT "x(62)" NO-LABEL SKIP
     "a partir do mes de" rel_dsmesano FORMAT "x(9)" NO-LABEL "de"
     rel_nranoini FORMAT "9999" NO-LABEL
     ", para credito na  sua  POUPANCA " AT 37
     "PROGRAMADA" SKIP
     crapcop.nmrescop FORMAT "x(11)"
     SKIP(2)
     WITH NO-BOX SIDE-LABELS NO-LABELS FRAME f_autoriza_1.

FORM "O presente instrumento substitui a autorizacao anterior com o mesmo"
     "numero,  que" SKIP
     "fica cancelada." SKIP
     WITH NO-BOX SIDE-LABELS NO-LABELS FRAME f_autoriza_2.

FORM "O debito sera efetuado somente mediante suficiente provisao de fundos."
     SKIP
     "Quando a data de aniversario nao coincidir com dia util, o debito"
     "sera  efetuado" SKIP
     "no primeiro dia util subsequente." SKIP(3)
     "A POUPANCA PROGRAMADA tem as seguintes caracteristicas:"
     SKIP(2)
     "1)  Taxa inicial = " aux_txaplica "% do CDI. Apos 30 dias a" 
     "taxa podera ser alterada," SKIP
     "    garantindo-se remuneracao igual a caderneta de poupanca;" SKIP(1)
     "2)  Ato Cooperativo art. 79 da lei 5764/71;" SKIP(1)
     "3)  Classificado como recibo de deposito cooperativo, de acordo com a"
     "Resolucao"
     SKIP
     "    3.454 do Bacen;" SKIP(1)
     "4)  Rendimento mensal calculado na data do aniversario;" SKIP(1)
     "5)  Saques fora da data de aniversario, admitidos a criterio da"
     "Cooperativa, nao" SKIP
     "    fazem jus a qualquer rendimento proporcional;" SKIP(1)
     "6)  Os saques deverao ser comunicados com antecedencia minima de"
     rel_nrdiargt FORMAT "zz9" NO-LABEL "dia(s);"
     SKIP(3)
     aux_nmcidade format "x(19)" glb_dtmvtolt FORMAT "99/99/9999" "."
     SKIP(4)
     "____________________________________  " AT 3
     "____________________________________"  SKIP
     rel_nmprimtl AT 3 FORMAT "x(36)" NO-LABEL
     rel_nmrescop[1] AT 42 FORMAT "x(36)" SKIP
     rel_nmrescop[2] AT 42 FORMAT "x(36)" 
     WITH NO-BOX SIDE-LABELS NO-LABELS FRAME f_autoriza_3.

FORM "Aguarde... Imprimindo contrato!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

/*  Busca dados da cooperativa  */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         RETURN.
     END.
 
ASSIGN aux_nmcidade = TRIM(crapcop.nmcidade)
                    + " "
                    + trim(crapcop.cdufdcop)
                    + ",".

RUN p_divinome.

rel_nrdocnpj = "CNPJ " + STRING(STRING(crapcop.nrdocnpj,"99999999999999"),
                                "xx.xxx.xxx/xxxx-xx").

/*** Busca taxa a ser paga ***/ 
FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND 
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "CONFIG"      AND
                   craptab.cdacesso = "TXADIAPLIC"  AND
                   craptab.tpregist = 2             NO-LOCK NO-ERROR.
                   
IF   NOT AVAILABLE craptab THEN
     DO:
         glb_cdcritic = 347.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         RETURN.
     END.

ASSIGN aux_txaplica = DECIMAL(ENTRY(2,craptab.dstextab,"#")).

/* Pegar exclusive-lock para alterar flag de impressao */
DO aux_cont = 1 TO 10:
    
    FIND crawrpp WHERE RECID(crawrpp) = par_recidrpp 
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
    IF   NOT AVAILABLE crawrpp   THEN
         DO:
             IF   LOCKED crawrpp   THEN
                  DO:               
                     glb_cdcritic = 341.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                  END.
             ELSE
                  DO:
                     glb_cdcritic = 484.
                     LEAVE.
                  END.
         END.

END.     

IF  glb_cdcritic > 0  THEN
    DO:
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic.
        LEAVE.
    END.

FIND crapass WHERE crapass.cdcooper = glb_cdcooper      AND 
                   crapass.nrdconta = crawrpp.nrdconta  NO-LOCK NO-ERROR.
                   
IF   NOT AVAILABLE crapass   THEN
     DO:
         glb_cdcritic = 9.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
         RETURN.
     END.

RUN fontes/extenso.p (INPUT  crawrpp.vlprerpp, INPUT 60, INPUT 60, INPUT "M",
                      OUTPUT rel_dsprerpp[1], OUTPUT rel_dsprerpp[2]).

ASSIGN rel_dsprerpp[1] = "(" + rel_dsprerpp[1] + ")"
       rel_nmprimtl    = crapass.nmprimtl
       rel_ddaniver    = DAY(crawrpp.dtdebito)
       rel_nranoini    = YEAR(crawrpp.dtdebito)
       rel_dsmesano    = TRIM(aux_nmmesano[MONTH(crawrpp.dtdebito)])
       rel_vlprerpp    = crawrpp.vlprerpp
       rll_vlprerpp    = crawrpp.vlprerpp
       rll_dtvctopp    = crawrpp.dtvctopp
       rll_nrctrrpp    = crawrpp.nrctrrpp.

FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND 
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 11            AND
                   craptab.cdacesso = "DIARESGATE"  AND
                   craptab.tpregist = 1
                   USE-INDEX craptab1 NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     rel_nrdiargt = 0.
ELSE
     rel_nrdiargt = INTEGER(craptab.dstextab).

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 64.

/*  Configura a impressora para 1/6"  */

PUT STREAM str_1 CONTROL "\0332\033x0\022" NULL.

DISPLAY STREAM str_1
        crapass.nmprimtl rll_nrctrrpp crapass.nrdconta
        rel_ddaniver     rll_vlprerpp rel_dsprerpp[1]
        rel_dsmesano     rel_nranoini     rel_vlprerpp
        crapcop.nmrescop crapcop.nmextcop rel_nrdocnpj
        rll_dtvctopp
        WITH FRAME f_autoriza_1.

IF   CAN-FIND(craprpp WHERE craprpp.cdcooper = glb_cdcooper       AND
                            craprpp.nrdconta = crawrpp.nrdconta   AND
                            craprpp.nrctrrpp = crawrpp.nrctrrpp)   THEN
     VIEW STREAM str_1 FRAME f_autoriza_2.

DISPLAY STREAM str_1
        rel_nrdiargt glb_dtmvtolt    aux_nmcidade aux_txaplica
        rel_nmprimtl rel_nmrescop[1] rel_nmrescop[2] 
        WITH FRAME f_autoriza_3.

OUTPUT STREAM str_1 CLOSE.

VIEW FRAME f_aguarde.
PAUSE 3 NO-MESSAGE.
HIDE FRAME f_aguarde NO-PAUSE.

 { includes/impressao.i } 

ASSIGN crawrpp.dtimpcrt = glb_dtmvtolt.

RELEASE crawrpp.

PROCEDURE p_divinome:

    /******* Divide o campo crapcop.nmextcop em duas Strings *******/
    ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(crapcop.nmextcop)," ") / 2
           rel_nmrescop = "".

    DO aux_contapal = 1 TO NUM-ENTRIES(TRIM(crapcop.nmextcop)," "):
        IF  aux_contapal <= aux_qtpalavr   THEN
            rel_nmrescop[1] = rel_nmrescop[1] +   
                              (IF TRIM(rel_nmrescop[1]) = "" THEN "" ELSE " ") 
                              + ENTRY(aux_contapal,crapcop.nmextcop," ").
        ELSE
            rel_nmrescop[2] = rel_nmrescop[2] +
                              (IF TRIM(rel_nmrescop[2]) = "" THEN "" ELSE " ")
                              + ENTRY(aux_contapal,crapcop.nmextcop," ").
                           
    END.  /*  Fim DO .. TO  */ 
           
    ASSIGN rel_nmrescop[1] = FILL(" ",20 - INT(LENGTH(rel_nmrescop[1]) / 2)) + 
                             rel_nmrescop[1]
           rel_nmrescop[2] = FILL(" ",20 - INT(LENGTH(rel_nmrescop[2]) / 2)) +
                             rel_nmrescop[2].

END PROCEDURE.

/* .......................................................................... */


