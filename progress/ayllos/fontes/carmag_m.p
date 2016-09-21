/* ............................................................................

   Programa: Fontes/carmag_m.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/99.                         Ultima atualizacao: 23/07/2015
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   
   Objetivo  : Rotina para imprimir o termo de entrega do cartao magnetico.

   Alteracoes: 21/10/1999 - Buscar dados da Cooperativa no crapcop (Edson).
         
               09/07/2002 - Usar nome por extenso (Deborah).
               
               09/12/2003 - Buscar nome da cidade no crapcop (Junior).

               20/09/2005 - Modificado FIND FIRST para FIND na tabela
                            crapcop.cdcooper = glb_cdcooper (Diego).

               25/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando

               14/05/2009 - Alteracao para utilizacao de BOs - Temp-tables -
                            GATI - Eder 
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM)                            
                            
               23/07/2015 - Remover os campos Limite, Forma de Saque e Recido
                            de entrega. (James)              
............................................................................ */
{ sistema/generico/includes/b1wgen0032tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_carmag.i }

DEF STREAM str_1.

DEF INPUT  PARAM par_nrdconta  AS INTE                               NO-UNDO.
DEF INPUT  PARAM par_nrcartao  AS DECI                               NO-UNDO.

/***** Variaveis de impressao - utilizadas em impressao.i *****/
DEF        VAR aux_flgescra AS LOGI                                  NO-UNDO.
DEF        VAR par_flgfirst AS LOGI    INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGI                                  NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR par_flgrodar AS LOGI    INIT TRUE                     NO-UNDO.
/**************************************************************/
DEF        VAR rel_dsoperad AS CHAR                                  NO-UNDO.
DEF        VAR rel_dsdponto AS CHAR                                  NO-UNDO.
DEF        VAR rel_dstitulo AS CHAR                                  NO-UNDO.
DEF        VAR rel_nmextcp1 AS CHAR    FORMAT "x(29)"                NO-UNDO.
DEF        VAR rel_nmextcp2 AS CHAR    FORMAT "X(21)"                NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.


FORM "Aguarde... Imprimindo a Declaracao de Recebimento!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM rel_dstitulo AT 23 FORMAT "x(45)"
     SKIP(2)
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_titulo.
     
FORM SKIP(1)
     "DECLARACAO DE RECEBIMENTO" AT 27 
     SKIP(4)
     WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 80 FRAME f_declara.
      
FORM "EU," tt-declar-recebimento.nmprimtl FORMAT "x(39)" ", CONTA" 
     tt-declar-recebimento.nrdconta FORMAT "zzzz,zzz,9" ", DECLARO TER" SKIP
     "RECEBIDO O CARTAO" 
     tt-declar-recebimento.nmrescop FORMAT "x(11)"
     ", COM PROPOSITO DE PERMITIR SAQUES "
     "E CONSULTA" SKIP
     "DE SALDOS NOS TERMINAIS DE AUTO-ATENDIMENTO DA" 
     rel_nmextcp1 FORMAT "x(29)" 
     rel_nmextcp2 FORMAT "x(21)" "."
     SKIP(2)
     WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 80 FRAME f_declara_ass.

FORM "EU," tt-declar-recebimento.nmprimtl    FORMAT "x(29)" ", OPERADOR" 
     tt-declar-recebimento.nrdconta          FORMAT "zzzz9" 
     ", DECLARO TER  RECEBIDO O" SKIP
     "CARTAO" tt-declar-recebimento.nmrescop FORMAT "x(11)"
     ", O QUAL PERMITE ACESSO AO TERMINAL FINANCEIRO PARA  FINS"
     SKIP
     "FUNCIONAIS DE MANUTENCAO E OPERACAO."
     SKIP(2)
     WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 80 FRAME f_declara_ope.
      
FORM tt-declar-recebimento.nrcartao FORMAT "9999,9999,9999,9999" 
                                    LABEL "NUMERO DO CARTAO"
     SKIP(1)
     tt-declar-recebimento.dtvalcar FORMAT "99/99/9999" 
                                    LABEL "DATA DE VALIDADE" AT 1
     SKIP(1)
     tt-declar-recebimento.dtemscar FORMAT "99/99/9999" 
                                    LABEL "DATA DE EMISSAO" AT 2
     SKIP(2)
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_dados_ass.

FORM tt-declar-recebimento.nrcartao FORMAT "9999,9999,9999,9999" 
                                    LABEL "NUMERO DO CARTAO"
     SKIP(1)
     tt-declar-recebimento.dsdnivel FORMAT "x(20)"   
                                    LABEL "NIVEL" AT 12
     SKIP(1)
     tt-declar-recebimento.dsparuso FORMAT "x(20)" 
                                    LABEL "PARA USO EM" AT 6
     SKIP(1)
     tt-declar-recebimento.dtvalcar FORMAT "99/99/9999" 
                                    LABEL "DATA DE VALIDADE" AT 1
     SKIP(1)
     tt-declar-recebimento.dtemscar FORMAT "99/99/9999" 
                                    LABEL "DATA DE EMISSAO" AT 2
     SKIP(2)
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_dados_ope.

FORM tt-declar-recebimento.dsrefere FORMAT "x(35)" NO-LABEL AT 1
     SKIP(3)
     "TITULAR"  AT  1
     "OPERADOR" AT 42
     SKIP(5)
     "------------------------------------" AT  1
     "-----------------------------------"  AT 42
     SKIP
     tt-declar-recebimento.nmprimtl FORMAT "x(36)" NO-LABEL AT  1
     tt-declar-recebimento.nmoperad FORMAT "x(35)" NO-LABEL AT 42
     SKIP
     tt-declar-recebimento.dsmvtolt FORMAT "x(30)" NO-LABEL AT 42
     SKIP(3)
 "--(Corte aqui)--------------------------------------------------------------"
     SKIP(3)
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_termo.
     
FORM SKIP
     "DICAS DE UTILIZACAO" AT 30 
     SKIP(3)
     "1) GUARDE SEMPRE EM LUGAR SEGURO E LONGE DE FONTES ELETRO-MAGNETICAS "
     "(IMAS," SKIP
     "   TELEFONES, CAIXAS DE SOM, ETC);"
     SKIP(1)
     "2) NUNCA DIGA A SUA SENHA A NINGUEM"
     rel_dsdponto AT 36 FORMAT "x"
     SKIP(1)
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_dicas_1.

FORM "3) NAO PECA AJUDA A PESSOAS ESTRANHAS!" SKIP
     "   PROCURE SEMPRE UM POSTO DA" tt-declar-recebimento.nmrescop 
                                                           FORMAT "x(11)" "."
     SKIP(2)
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_dicas_2.

FORM "DADOS DO CARTAO" AT 31
     SKIP(2)
     tt-declar-recebimento.nrdconta FORMAT "zzzz,zzz,9" LABEL "CONTA" AT 12
     SKIP(1)
     tt-declar-recebimento.nmprimtl FORMAT "x(40)"      LABEL "TITULAR" AT 10
     SKIP(1)
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_cartao_ass.

FORM SKIP(1)
     "DADOS DO CARTAO" AT 31
     SKIP(1)
     tt-declar-recebimento.nrdconta FORMAT "zzzz9" LABEL "OPERADOR" AT  9
     SKIP(1)
     tt-declar-recebimento.nmprimtl FORMAT "x(40)" LABEL "TITULAR"  AT 10
     SKIP(1)
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_cartao_ope.

FORM SKIP(2)
     rel_dsoperad AT 9 FORMAT "x(55)" LABEL "OPERADOR"
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_operador.

HIDE MESSAGE NO-PAUSE.
VIEW FRAME f_aguarde.

RUN sistema/generico/procedures/b1wgen0032.p PERSISTENT SET h_b1wgen0032.
RUN declaracao-recebimento-cartao IN h_b1wgen0032
                                       ( INPUT  glb_cdcooper,
                                         INPUT  0,
                                         INPUT  0,
                                         INPUT  glb_cdoperad,   
                                         INPUT  glb_nmdatela,
                                         INPUT  1,
                                         INPUT  par_nrdconta,
                                         INPUT  1,
                                         INPUT  glb_dtmvtolt,
                                         INPUT  par_nrcartao,
                                         INPUT  YES,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT TABLE tt-declar-recebimento).
DELETE PROCEDURE h_b1wgen0032.
                              
IF   RETURN-VALUE = "NOK"   THEN
     DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
         IF   AVAIL tt-erro   THEN
              DO:
                  BELL.
                  MESSAGE tt-erro.dscritic.
                  HIDE FRAME f_aguarde NO-PAUSE.
                  RETURN "NOK".
              END.
     END.

FIND tt-declar-recebimento NO-ERROR.
IF   NOT AVAIL tt-declar-recebimento   THEN
     DO:
         HIDE FRAME f_aguarde NO-PAUSE.
         RETURN "NOK".
     END.

ASSIGN rel_dstitulo = "** CARTAO " + CAPS(tt-declar-recebimento.nmrescop) +
                      " - AUTO ATENDIMENTO **"
                      
       rel_nmextcp1 = SUBSTRING(tt-declar-recebimento.nmextcop,1,29)
       rel_nmextcp2 = SUBSTRING(tt-declar-recebimento.nmextcop,30,50).

ASSIGN rel_dsoperad = TRIM(tt-declar-recebimento.nmoperad) + " - " +
                      tt-declar-recebimento.dsmvtolt.

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.  

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

PUT STREAM str_1 CONTROL "\022\024\033\120\0330" NULL.

DISPLAY STREAM str_1 rel_dstitulo WITH FRAME f_titulo.

VIEW STREAM str_1 FRAME f_declara.     
     
IF   tt-declar-recebimento.tpcarcta = 9   THEN
     DO:
         rel_dsdponto = ".".
         
         DISPLAY STREAM str_1
                 tt-declar-recebimento.nmprimtl  tt-declar-recebimento.nrdconta
                 tt-declar-recebimento.nmrescop
                 WITH FRAME f_declara_ope.
      
         DISPLAY STREAM str_1
                 tt-declar-recebimento.nrcartao  tt-declar-recebimento.dsdnivel 
                 tt-declar-recebimento.dsparuso  tt-declar-recebimento.dtvalcar
                 tt-declar-recebimento.dtemscar 
                 WITH FRAME f_dados_ope.

         DISPLAY STREAM str_1
                 tt-declar-recebimento.dsrefere  tt-declar-recebimento.nmprimtl 
                 tt-declar-recebimento.nmoperad  tt-declar-recebimento.dsmvtolt
                 WITH FRAME f_termo.
      
         VIEW STREAM str_1 FRAME f_titulo.
         
         DISPLAY STREAM str_1 rel_dsdponto WITH FRAME f_dicas_1.
      
         DISPLAY STREAM str_1
                 tt-declar-recebimento.nrdconta  tt-declar-recebimento.nmprimtl
                 WITH FRAME f_cartao_ope.

         DISPLAY STREAM str_1
                 tt-declar-recebimento.nrcartao  tt-declar-recebimento.dsdnivel 
                 tt-declar-recebimento.dsparuso  tt-declar-recebimento.dtvalcar
                 tt-declar-recebimento.dtemscar 
                 WITH FRAME f_dados_ope.
     END.
ELSE
IF   tt-declar-recebimento.tpcarcta = 1   THEN
     DO:
         FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                            crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
                            
         rel_dsdponto = ";".
 
         DISPLAY STREAM str_1
                 tt-declar-recebimento.nmprimtl  tt-declar-recebimento.nrdconta
                 tt-declar-recebimento.nmrescop  rel_nmextcp1 
                 rel_nmextcp2
                 WITH FRAME f_declara_ass.
      
         DISPLAY STREAM str_1
                 tt-declar-recebimento.nrcartao  tt-declar-recebimento.dtvalcar
                 tt-declar-recebimento.dtemscar 
                 WITH FRAME f_dados_ass.

         DISPLAY STREAM str_1
                 tt-declar-recebimento.dsrefere  tt-declar-recebimento.nmprimtl
                 tt-declar-recebimento.nmoperad  tt-declar-recebimento.dsmvtolt
                 WITH FRAME f_termo.
     
         VIEW STREAM str_1 FRAME f_titulo.
         
         DISPLAY STREAM str_1 rel_dsdponto WITH FRAME f_dicas_1.
         DISPLAY STREAM str_1 
                 tt-declar-recebimento.nmrescop 
                 WITH FRAME f_dicas_2.
  
         DISPLAY STREAM str_1
                 tt-declar-recebimento.nrdconta  tt-declar-recebimento.nmprimtl
                 WITH FRAME f_cartao_ass.

         DISPLAY STREAM str_1
                 tt-declar-recebimento.nrcartao  tt-declar-recebimento.dtemscar
                 WITH FRAME f_dados_ass.
     END.

DISPLAY STREAM str_1
        rel_dsoperad 
        WITH FRAME f_operador.

OUTPUT STREAM str_1 CLOSE.

HIDE FRAME f_aguarde NO-PAUSE.

MESSAGE "Imprimindo declaracao de recebimento...".

{ includes/impressao.i } 

RETURN "OK".

/* ......................................................................... */