/* ............................................................................

   Programa: Fontes/sldccr_ct1.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Marco/97.                           Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para listar contrato de cartoes de credito.

   Alteracoes: 11/08/98 - Identificar 2via atraves da data dtentr2v (Deborah).

               25/10/1999 - Buscar dados da cooperativa no crapcop (Edson).

               30/07/2001 - Incluir geracao de nota promissoria (Margarete).

               09/07/2002 - Imprimir nome completo da Coop (Margarete).
               
               09/12/2003 - Buscar nome da cidade no crapcop (Junior).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).
                            
               31/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               09/06/2009 - Alteracao para utilizacao de BOs - Temp-tables
                            (GATI - Eder)
                            
               09/11/2010 - Alteracao para adequacao projeto cartao PJ
                            (GATI - Sandro) 
                            
               15/08/2013 - Nova forma de chamar as agências, agora 
                            a escrita será PA (André Euzébio - Supero).  
                            
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................ */
{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen0019tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }
{ includes/var_atenda.i }
{ includes/var_sldccr.i }

DEF  INPUT  PARAM par_nrctrcrd   AS  INTEGER       NO-UNDO.

DEF NEW GLOBAL SHARED STREAM str_1.

/***** Variaveis de impressao - utilizadas em impressao.i *****/
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR par_flgrodar AS LOGICAL INIT TRUE                     NO-UNDO.
/**************************************************************/

DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR aux_nmcidade AS CHAR    EXTENT 2                      NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR h_b1wgen0028 AS HANDLE                                NO-UNDO.


FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM " Aguarde... Imprimindo contrato de cartao de credito! "
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM "\022\024\033\120"     /* Reseta impressora */
     SKIP
     "\0330\033x0\033\017"
     "\033\016"
     tt-ctr_credicard.nmextcop FORMAT "x(50)"
     "\024\022\033\120"
     SKIP(1)
     "\0330\033x0\033\017"
     "\033\016 CONTRATO P/ UTILIZACAO DO CARTAO DE CREDITO CREDICARD"
     tt-ctr_credicard.dssubsti  NO-LABEL FORMAT "X(9)"
     SKIP(3)
     "1. CONTRATANTES"
     SKIP(1)
     "\033\016"            tt-ctr_credicard.nmprimtl  FORMAT "x(40)" AT 05
     "\024         , CPF " tt-ctr_credicard.nrcpfcgc  FORMAT "999,999,999,99"
     ", conta-corrente"
     SKIP
     "\033\016"     tt-ctr_credicard.nrdconta   AT 4
     "\024no PA.:" tt-ctr_credicard.cdagenci   FORMAT "zz9"
     ", abaixo assinado e doravante denominado ASSOCIADO."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 136 NO-LABELS NO-BOX FRAME f_inicio_0.

FORM "\033\016" AT 3
     tt-ctr_credicard.nmextcop FORMAT "x(50)"
     "\024,"
     tt-ctr_credicard.nrdocnpj FORMAT "x(23)" ","
     SKIP
     "doravante denominada" AT 4 
     tt-ctr_credicard.nmrescop FORMAT "x(11)" "."
     SKIP(1)
     "2. OBJETO"
     SKIP(1)
     "Este contrato regula as condicoes para intermediacao de prestacao" AT 4
     "de servicos de administracao de cartoes de credito e seus desdo-"
     SKIP
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 136 NO-LABELS NO-BOX FRAME f_inicio_1.

FORM "bramentos,  entre  a" AT 4
     tt-ctr_credicard.nmrescop FORMAT "x(11)"
     ",  seu  ASSOCIADO"
     " aderente e a  empresa  CREDICARD S.A.  ADMINISTRADORA DE CARTOES  DE"
     " CREDITO,"
     SKIP
     "CNPJ 34.098.442/0001-34, doravante denominada CREDICARD." AT 04
     SKIP(1)
     "3. CLAUSULAS"
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 136 NO-LABELS NO-BOX FRAME f_inicio_2.

FORM "3.1. A" AT 4
     tt-ctr_credicard.nmrescop FORMAT "x(11)"
     ", na condicao  de intermediaria para o"
     "fornecimento do cartao de credito do tipo Empresarial a seus associados,"
     SKIP
     "subscreveu o contrato de adesao ao sistema de cartao" AT 09
     "de credito oferecido pela CREDICARD, de acordo com o contrato registrado"
     SKIP
     "no 4. Registro  de  Titulos e Documentos de Sao Paulo sob"  AT 09
     "n. 2.048.515 e no 3. Oficio de Registro de  Titulos e Documentos do"
     SKIP
     "Rio de Janeiro sob n. 311.099, funcionando naquele"              AT 09
     "contrato como EMPRESA."
     SKIP(1)
     "3.2. O ASSOCIADO, na  condicao de usuario do cartao de credito,"   AT 04
     "pelo presente instrumento, declara conhecer o contrato referido na"
     SKIP
     "clausula anterior, aderindo e aceitando suas condicoes,"  AT 09
     "as quais se sujeita, funcionando naquele contrato como TITULAR."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 136 NO-LABELS NO-BOX FRAME f_inicio_3.

FORM "3.3. A" AT 4
     tt-ctr_credicard.nmrescop FORMAT "x(11)"
     ", ficara sub-rogada em todos os direitos da"
     "CREDICARD, perante o ASSOCIADO usuario do cartao, sempre que liqui-"
     SKIP
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 136 NO-LABELS NO-BOX FRAME f_inicio_4.

FORM "dar as faturas mensais, e ate a liquidacao total do"    AT 09
     "debito pelo associado perante a"
     tt-ctr_credicard.nmrescop FORMAT "x(11)" "."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 136 NO-LABELS NO-BOX FRAME f_inicio_5.

FORM "3.4. O relacionamento do ASSOCIADO, para comunicacao de perda,"  AT 04
     "roubo, furto, fraude ou falsificacao de cartao e outras, sera dire-"
     SKIP
     "to com a CREDICARD, podendo eventualmente a" AT 9
     tt-ctr_credicard.nmrescop FORMAT "x(11)"
     "servir de intermediaria."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 136 NO-LABELS NO-BOX FRAME f_inicio_6.

FORM "3.5. A remuneracao pelos servicos disponibilizados sera de"   AT 04
     "inteira responsabilidade do ASSOCIADO, cabendo a"
     tt-ctr_credicard.nmrescop FORMAT "x(11)" "debita-los"
     SKIP
     "na conta corrente do ASSOCIADO." AT 09
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 136 NO-LABELS NO-BOX FRAME f_inicio_7.

FORM "3.5.1. A" AT 9
     tt-ctr_credicard.nmrescop FORMAT "x(11)"
     "podera  repassar, alem da  remuneracao dos"
     "servicos cobrados pela  CREDICARD, uma remuneracao pelos seus"
     SKIP
     "servicos de intermediacao, que tambem serao debitados"  AT 16
     "na conta do ASSOCIADO."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 136 NO-LABELS NO-BOX FRAME f_inicio_8.

FORM "3.6. O  valor da fatura mensal oriundo da  utilizacao do cartao,"  AT 04
     "e demais despesas ou encargos, sera debitado mensalmente, na data"
     SKIP
     "do vencimento, pela" AT 9
     tt-ctr_credicard.nmrescop FORMAT "x(11)" ", na conta corrente do"
     " associado, ficando desde logo, autorizada para tal, independentemente"
     SKIP
     "de qualquer notificacao ou aviso previo, obrigando-se o ASSOCIADO," AT 09
     "a manter saldo suficiente."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 136 NO-LABELS NO-BOX FRAME f_inicio_9.

FORM "3.7. Cabe a" AT 4
     tt-ctr_credicard.nmrescop FORMAT "x(11)"
     ", a seu  criterio, estabelecer o limite" 
     "de credito do ASSOCIADO, podendo ajusta-lo ou ate cancela-lo inte-"
     SKIP
     "gralmente, de acordo  com  suas condicoes gerais perante"  AT 09
     "a CREDICARD ou as condicoes de credito do ASSOCIADO perante a Coope-"
     SKIP
     "rativa, podendo ainda, reduzi-lo, se o saldo devedor da fatura" AT 09
     "mensal nao for liquidado pelo ASSOCIADO."
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 136 NO-LABELS NO-BOX FRAME f_inicio_10.

FORM SKIP(1)
     "3.8. A" AT 4
     tt-ctr_credicard.nmrescop FORMAT "x(11)"
     ", remetera  ao ASSOCIADO, juntamente com o"
     "aviso de debito em  conta corrente, toda a documentacao,  extratos e"
     SKIP
     "demonstrativos remetidos pela CREDICARD." AT 09
     SKIP(1)
     "3.9. O  ASSOCIADO  declara receber  o  cartao de credito  de numero" 
     AT 04
     "\033\016" tt-ctr_credicard.nrcrcard  "\024, conforme  proposta"
     SKIP tt-ctr_credicard.nrctrcrd FORMAT "999,999" AT 09
     ", em nome do titular do cartao," AT 16 
     tt-ctr_credicard.nmtitcrd FORMAT "x(40)"
     "." AT  89
     SKIP(1)
     "4. DISPOSICOES GERAIS"
     SKIP(1)
     WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 136 NO-ATTR-SPACE FRAME f_dados_1.

FORM "4.1. O foro competente do presente contrato e o de "  AT 4
     aux_nmcidade[1] FORMAT "x(20)" 
     ", podendo  entretanto  a"  tt-ctr_credicard.nmrescop FORMAT "X(11)"  ","
     " optar  pelo  foro"  SKIP
     "estabelecido na clausula  decima oitava do contrato com a CREDICARD."  
     AT 09
     SKIP(2)
     aux_nmcidade[2] FORMAT "X(75)"   
     SKIP(3)
     "___________________________________  "  AT 01
     "___________________________________  "
     "_______________________________________________________"
     SKIP(1)
     WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 136 NO-ATTR-SPACE FRAME f_dados_2.

FORM "Operador:" AT 01 tt-ctr_credicard.nmoperad FORMAT "x(25)"
     tt-ctr_credicard.nmrecop1  FORMAT "x(35)" AT 39
     tt-ctr_credicard.nmprimtl  FORMAT "x(40)" AT 77
     tt-ctr_credicard.nmrecop2  FORMAT "x(35)" AT 39
     SKIP(2)
     "Testemunhas: "                           AT 15
     "______________________________________________   "
     "______________________________________________"
     SKIP(2)
     "Nome: ________________________________________   " AT 29
     "Nome: ________________________________________"
     SKIP(2)
     "Conta/dv: ____________________________________   " AT 29
     "Conta/dv: ____________________________________"
     WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 136 NO-ATTR-SPACE FRAME f_dados_3.
     
RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.
RUN impressoes_cartoes IN h_b1wgen0028
                            ( INPUT  glb_cdcooper,
                              INPUT  0,
                              INPUT  0,
                              INPUT  glb_cdoperad,
                              INPUT  glb_nmdatela,
                              INPUT  1,
                              INPUT  tel_nrdconta,
                              INPUT  1,
                              INPUT  glb_dtmvtolt,
                              INPUT  glb_dtmvtopr,
                              INPUT  glb_inproces,
                              INPUT  5, /* Contrato Credicard */
                              INPUT  par_nrctrcrd,
                              INPUT  YES,
                              INPUT  ?, /* (par_flgimpnp) */
                              INPUT  0, /* (par_cdmotivo) */
                              
                              OUTPUT TABLE tt-dados_prp_ccr,
                              OUTPUT TABLE tt-dados_prp_emiss_ccr,
                              OUTPUT TABLE tt-outros_cartoes,
                              OUTPUT TABLE tt-termo_cancblq_cartao,
                              OUTPUT TABLE tt-ctr_credicard,
                              OUTPUT TABLE tt-bdn_visa_cecred,
                              OUTPUT TABLE tt-termo_solici2via,
                              OUTPUT TABLE tt-avais-ctr,
                              OUTPUT TABLE tt-ctr_bb,
                              OUTPUT TABLE tt-termo_alt_dt_venc,
                              OUTPUT TABLE tt-alt-limite-pj,
                              OUTPUT TABLE tt-alt-dtvenc-pj,
                              OUTPUT TABLE tt-termo-entreg-pj,       
                              OUTPUT TABLE tt-segviasen-cartao,
                              OUTPUT TABLE tt-segvia-cartao,
                              OUTPUT TABLE tt-termocan-cartao,
                              OUTPUT TABLE tt-erro).

DELETE PROCEDURE h_b1wgen0028.

IF   RETURN-VALUE = "NOK" THEN
     DO:
         FIND FIRST tt-erro NO-LOCK NO-ERROR.
         IF   AVAIL tt-erro THEN
              DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
              END.
     END.
     
FIND tt-ctr_credicard NO-ERROR.
IF   NOT AVAIL tt-ctr_credicard   THEN
     RETURN "NOK".     
 
ASSIGN aux_nmcidade[1] = TRIM(tt-ctr_credicard.nmcidade) 
                       + " -" 
                       + TRIM(tt-ctr_credicard.cdufdcop)
       aux_nmcidade[2] = TRIM(tt-ctr_credicard.nmcidade)
                       + " "
                       + TRIM(tt-ctr_credicard.cdufdcop)
                       + ", "
                       + tt-ctr_credicard.dsemsctr.
                       
VIEW FRAME f_aguarde.
PAUSE 3 NO-MESSAGE.
HIDE FRAME f_aguarde NO-PAUSE.

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter. 

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

DISPLAY STREAM str_1
        tt-ctr_credicard.nmextcop   tt-ctr_credicard.dssubsti
        tt-ctr_credicard.nmprimtl   tt-ctr_credicard.nrcpfcgc
        tt-ctr_credicard.nrdconta   tt-ctr_credicard.cdagenci  
        WITH FRAME f_inicio_0.

DISPLAY STREAM str_1
        tt-ctr_credicard.nmextcop   tt-ctr_credicard.nrdocnpj
        tt-ctr_credicard.nmrescop 
        WITH FRAME f_inicio_1.

DISPLAY STREAM str_1
        tt-ctr_credicard.nmrescop 
        WITH FRAME f_inicio_2.

DISPLAY STREAM str_1
        tt-ctr_credicard.nmrescop 
        WITH FRAME f_inicio_3.

DISPLAY STREAM str_1
        tt-ctr_credicard.nmrescop 
        WITH FRAME f_inicio_4.

DISPLAY STREAM str_1
        tt-ctr_credicard.nmrescop 
        WITH FRAME f_inicio_5.

DISPLAY STREAM str_1
        tt-ctr_credicard.nmrescop 
        WITH FRAME f_inicio_6.

DISPLAY STREAM str_1
        tt-ctr_credicard.nmrescop 
        WITH FRAME f_inicio_7.

DISPLAY STREAM str_1
        tt-ctr_credicard.nmrescop 
        WITH FRAME f_inicio_8.

DISPLAY STREAM str_1
        tt-ctr_credicard.nmrescop 
        WITH FRAME f_inicio_9.

DISPLAY STREAM str_1
        tt-ctr_credicard.nmrescop 
        WITH FRAME f_inicio_10.

DISPLAY STREAM str_1
        tt-ctr_credicard.nmrescop   tt-ctr_credicard.nrcrcard  
        tt-ctr_credicard.nrctrcrd   tt-ctr_credicard.nmtitcrd
        WITH FRAME f_dados_1.
        
DISPLAY STREAM str_1
        tt-ctr_credicard.nmrescop   aux_nmcidade[1] 
        aux_nmcidade[2]  
        WITH FRAME f_dados_2.
             
DISPLAY STREAM str_1
        tt-ctr_credicard.nmoperad   tt-ctr_credicard.nmrecop1 
        tt-ctr_credicard.nmrecop2   tt-ctr_credicard.nmprimtl 
        WITH FRAME f_dados_3.

/** Tratamento da impressao da nota promissoria **/        
IF   NOT aux_flgimp2v   THEN
     DO:
         EMPTY TEMP-TABLE tt_dados_promissoria.
         
         CREATE tt_dados_promissoria.
         ASSIGN tt_dados_promissoria.dsemsctr = tt-ctr_credicard.dsemsctr
                tt_dados_promissoria.dsctrcrd = tt-ctr_credicard.dsctrcrd
                tt_dados_promissoria.dsdmoeda = tt-ctr_credicard.dsdmoeda
                tt_dados_promissoria.vllimite = tt-ctr_credicard.vllimite
                tt_dados_promissoria.dsdtmvt1 = tt-ctr_credicard.dsdtmvt1
                tt_dados_promissoria.dsdtmvt2 = tt-ctr_credicard.dsdtmvt2
                tt_dados_promissoria.nmextcop = tt-ctr_credicard.nmextcop
                tt_dados_promissoria.nmrescop = tt-ctr_credicard.nmrescop
                tt_dados_promissoria.dsvlnpr1 = tt-ctr_credicard.dsvlnpr1
                tt_dados_promissoria.dsvlnpr2 = tt-ctr_credicard.dsvlnpr2
                tt_dados_promissoria.nmcidpac = tt-ctr_credicard.nmcidpac
                tt_dados_promissoria.nmprimtl = tt-ctr_credicard.nmprimtl
                tt_dados_promissoria.dscpfcgc = tt-ctr_credicard.dscpfcgc
                tt_dados_promissoria.nrdconta = tt-ctr_credicard.nrdconta
                tt_dados_promissoria.endeass1 = tt-ctr_credicard.endeass1
                tt_dados_promissoria.endeass2 = tt-ctr_credicard.endeass2
                tt_dados_promissoria.nmcidade = tt-ctr_credicard.nmcidade
                tt_dados_promissoria.dsmvtolt = tt-ctr_credicard.dsectrnp.
                
         ASSIGN aux_contador = 1.      
         FOR EACH tt-avais-ctr:
             IF   aux_contador = 1   THEN
                  ASSIGN 
                     tt_dados_promissoria.nmdaval1    = tt-avais-ctr.nmdavali
                     tt_dados_promissoria.nmdcjav1    = tt-avais-ctr.nmconjug
                     tt_dados_promissoria.dscpfav1    = tt-avais-ctr.cpfavali
                     tt_dados_promissoria.dscfcav1    = tt-avais-ctr.nrcpfcjg
                     tt_dados_promissoria.dsendav1[1] = tt-avais-ctr.dsendav1
                     tt_dados_promissoria.dsendav1[2] = tt-avais-ctr.dsendav2
                     aux_contador                     = aux_contador + 1.
             ELSE
                  ASSIGN 
                     tt_dados_promissoria.nmdaval2    = tt-avais-ctr.nmdavali
                     tt_dados_promissoria.nmdcjav2    = tt-avais-ctr.nmconjug
                     tt_dados_promissoria.dscpfav2    = tt-avais-ctr.cpfavali
                     tt_dados_promissoria.dscfcav2    = tt-avais-ctr.nrcpfcjg
                     tt_dados_promissoria.dsendav2[1] = tt-avais-ctr.dsendav1
                     tt_dados_promissoria.dsendav2[2] = tt-avais-ctr.dsendav2.
         END.            
         
         RELEASE tt_dados_promissoria.
         
         RUN fontes/impromissoria.p (INPUT TABLE tt_dados_promissoria).
     END.
/** Tratamento da impressao da nota promissoria **/

OUTPUT STREAM str_1 CLOSE.

glb_nrdevias = 1.

FIND crapass WHERE
     crapass.cdcooper = glb_cdcooper AND
     crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.
{ includes/impressao.i }

RETURN "OK".
/* ......................................................................... */
