/* .............................................................................
   
   Programa: Fontes/rdcapp_n.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme    
   Data    : Abril/2008.                     Ultima atualizacao: 30/05/2014    

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para impressao da poupanca programada.

   Alteracoes: 04/11/2008 - Retirado constante da UF "SC" e colocado campo de
                            arquivo (Martin).
                            
               24/04/2010 - A impressao da poupança acontecerá sempre por
                            este fontes. Pois nao existe mais poupança em
                            estudo.
                            Usar a BO b1wgen0006. (Gabriel)
                         
               21/06/2011 - Alterada flag de log de FALSE  p/ TRUE
                            em BO b1wgen0006 (Jorge).  
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).

............................................................................. */

DEF INPUT PARAM par_nrdrowid AS ROWID NO-UNDO.


DEF STREAM str_1.

{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_rdcapp.i }

{ sistema/generico/includes/var_internet.i }


DEF        VAR rel_ddaniver AS INT                                   NO-UNDO.
DEF        VAR rel_nranoini AS INT                                   NO-UNDO.

DEF        VAR rel_dsprerpp AS CHAR    EXTENT 2                      NO-UNDO.
DEF        VAR rel_nrdocnpj AS CHAR                                  NO-UNDO.
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.

DEF        VAR par_flgrodar AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.

DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.

DEF        VAR h-b1wgen0006 AS HANDLE                                NO-UNDO.

FORM SKIP(3)
     tt-autoriza-rpp.nmextcop AT 18 FORMAT "x(50)"
     
     SKIP    
     rel_nrdocnpj             AT 29 FORMAT "x(25)"   
     SKIP(3)
     
     "AUTORIZACAO DE DEBITO EM CONTA-CORRENTE PARA CREDITO NA"  AT 3
     "POUPANCA PROGRAMADA"    AT 59
     SKIP
     "========================================================" AT 3
     "==================="    AT 59
     
     SKIP(3)
     tel_nrdconta AT  2 FORMAT "zzzz,zzz,9"      LABEL "Conta/dv"
     tt-autoriza-rpp.nrctrrpp AT 25 FORMAT "z,zzz,zz9"       LABEL "Numero da Poupanca"
     tt-autoriza-rpp.vlprerpp AT 57 FORMAT "zzzz,zzz,zz9.99" LABEL "Valor"
     SKIP(1)

     tt-autoriza-rpp.nmprimtl AT  1 FORMAT "x(40)"           LABEL "Associado"
     rel_ddaniver AT 57 FORMAT "99"              LABEL "Dia do Aniversario"
     
     SKIP(2)
     "O associado acima qualificado, autoriza um debito mensal   em "
     "conta-corrente de" SKIP
     "depositos  a  vista,  com   vencimento  em " 

     tt-autoriza-rpp.dtvctopp FORMAT "99/99/9999" ",  na   importancia  de" 
      SKIP
     
     "R$" tt-autoriza-rpp.vlprerpp   FORMAT "zzz,zzz,zz9.99"     NO-LABEL 
     rel_dsprerpp[1]     FORMAT "x(62)"              NO-LABEL 
     SKIP
     "a partir do mes de" tt-autoriza-rpp.dsmesano FORMAT "x(9)" NO-LABEL "de"
     rel_nranoini        FORMAT "9999"               NO-LABEL
     ", para credito na  sua  POUPANCA " AT 37
     "PROGRAMADA" 
     SKIP
     tt-autoriza-rpp.nmrescop FORMAT "x(11)"
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
     "1)  Taxa inicial = " tt-autoriza-rpp.txaplica FORMAT "Z9.99"
     "% do CDI. Apos 30 dias a" 
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
     tt-autoriza-rpp.nrdiargt FORMAT "zz9" NO-LABEL "dia(s);"
     SKIP(3)
     tt-autoriza-rpp.nmcidade format "x(19)" glb_dtmvtolt FORMAT "99/99/9999" "."
     SKIP(3)
     "____________________________________  " AT 3
     "____________________________________"  SKIP
     tt-autoriza-rpp.nmprimtl AT 3 FORMAT "x(36)" NO-LABEL
     tt-autoriza-rpp.nmexcop1  AT 42 FORMAT "x(36)" SKIP
     tt-autoriza-rpp.nmexcop2 AT 42 FORMAT "x(36)" 
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


RUN sistema/generico/procedures/b1wgen0006.p
                     PERSISTENT SET h-b1wgen0006.
                    
RUN obtem-dados-autorizacao IN h-b1wgen0006
                        (INPUT glb_cdcooper,
                         INPUT 0,
                         INPUT 0,
                         INPUT glb_cdoperad,
                         INPUT glb_nmdatela,
                         INPUT 1, /* Origem */
                         INPUT tel_nrdconta,
                         INPUT 1, /* Titular */
                         INPUT par_nrdrowid,
                         INPUT 0,
                         INPUT glb_dtmvtolt,
                         INPUT TRUE,
                         OUTPUT TABLE tt-erro,
                         OUTPUT TABLE tt-autoriza-rpp).

DELETE PROCEDURE h-b1wgen0006.

IF   RETURN-VALUE <> "OK"   THEN
     DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.

         IF   AVAIL tt-erro   THEN
              MESSAGE tt-erro.dscritic.

         RETURN.
     END.
     
FIND FIRST tt-autoriza-rpp NO-LOCK NO-ERROR.

IF   NOT AVAIL tt-autoriza-rpp   THEN
     RETURN.

ASSIGN rel_nrdocnpj    = "CNPJ " + tt-autoriza-rpp.nrdocnpj                
       rel_dsprerpp[1] = "(" + tt-autoriza-rpp.dsprerpp + ")"       
       rel_ddaniver    = INT(tt-autoriza-rpp.ddaniver) 
       rel_nranoini    = INT(tt-autoriza-rpp.nranoin).

       
INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.    

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 64.

/*  Configura a impressora para 1/6"  */

PUT STREAM str_1 CONTROL "\0332\033x0\022" NULL.

DISPLAY STREAM str_1
        tt-autoriza-rpp.nmprimtl 
        tt-autoriza-rpp.nrctrrpp 
        tel_nrdconta
        rel_ddaniver 
        tt-autoriza-rpp.vlprerpp
        rel_dsprerpp[1]
        tt-autoriza-rpp.dsmesano   
        rel_nranoini 
        tt-autoriza-rpp.vlprerpp
        tt-autoriza-rpp.nmrescop
        tt-autoriza-rpp.nmextcop         
        rel_nrdocnpj
        tt-autoriza-rpp.dtvctopp
        WITH FRAME f_autoriza_1.

/* A poupança possui alteraçao */
IF   tt-autoriza-rpp.flgsubst  THEN
      VIEW STREAM str_1 FRAME f_autoriza_2.

DISPLAY STREAM str_1
        tt-autoriza-rpp.nrdiargt 
        glb_dtmvtolt
        tt-autoriza-rpp.nmcidade 
        tt-autoriza-rpp.txaplica
        tt-autoriza-rpp.nmprimtl
        tt-autoriza-rpp.nmexcop1 
        tt-autoriza-rpp.nmexcop2 
        WITH FRAME f_autoriza_3.

OUTPUT STREAM str_1 CLOSE.

VIEW FRAME f_aguarde.

PAUSE 3 NO-MESSAGE.

HIDE FRAME f_aguarde NO-PAUSE.

/* Pra complilar */
FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                         NO-LOCK NO-ERROR.

{ includes/impressao.i }


/* .......................................................................... */
