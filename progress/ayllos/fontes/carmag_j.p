/* ............................................................................

   Programa: Fontes/carmag_j.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Marco/2008.                  Ultima atualizacao: 29/05/2014
   
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   
   Objetivo  : Rotina para imprimir a autorizacao de acesso e termo de 
               responsabilidade de Cartoes Magneticos de Pessoa Juridica.

   Alteracoes: 14/05/2009 - Alteracao para utilizacao de BOs - Temp-tables -
                            GATI - Eder
                            
               30/05/2011 - Alteracao do format dos campos nmbairro e nmcidade
                            (Fabrício) 
               
               10/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM)
............................................................................ */
{ sistema/generico/includes/b1wgen0032tt.i }
{ sistema/generico/includes/var_internet.i }
{includes/var_online.i} 
{includes/var_atenda.i}

DEF INPUT  PARAM par_nrdconta  AS INT                                NO-UNDO.

DEF STREAM str_1.       

/***** Variaveis de impressao - utilizadas em impressao.i *****/
DEF        VAR aux_flgescra AS LOGI                                  NO-UNDO.
DEF        VAR par_flgfirst AS LOGI    INIT TRUE                     NO-UNDO.
DEF        VAR par_flgcance AS LOGI                                  NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR par_flgrodar AS LOGI    INIT TRUE                     NO-UNDO.
/**************************************************************/
DEF        VAR h_b1wgen0032 AS HANDLE                                NO-UNDO.

DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR rel_dsoperad AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_qtprepo  AS INTE                                  NO-UNDO.
DEF        VAR aux_qtsocadm AS INTE                                  NO-UNDO.

FORM "Aguarde... Imprimindo o Termo de Responsabilidade!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM 
     "\022\024\033\120" /* reseta impressora */ /*configs */
     "\0330\033x0\033\017" /* ajusta tamnho e fonte */
     SKIP(5) SPACE(10)
     "\033\016 ACESSO CAIXA ELETRONICO   -   SOLICITACAO, AUTORIZACAO DE" 
     SKIP SPACE(56) 
     "\033\016        ACESSO E TERMO DE RESPONSABILIDADE - PESSOA JURIDICA"  
     "\022\024\033\120" /* reseta impressora */ /* configs */
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_titulo.
     
FORM SKIP(4)
                      tt-termo-magnetico.nmextcop AT 4 FORMAT "X(50)" NO-LABEL 
                 " - " tt-termo-magnetico.nmrescop     FORMAT "X(11)" NO-LABEL
     SKIP
     "CNPJ:"      AT 4 tt-termo-magnetico.nrdocnpj     FORMAT "X(18)" NO-LABEL 
     SKIP(2)
     "Cooperado:" AT 4 tt-termo-magnetico.nmprimtl     FORMAT "x(35)" NO-LABEL
     "C/C:"           tt-termo-magnetico.nrdconta FORMAT "zzzz,zzz,9" NO-LABEL
     SKIP
     "CNPJ:"      AT 4 tt-termo-magnetico.nrcpfcgc     FORMAT "X(18)" NO-LABEL
     SKIP(3)
     "Socio(s)/Proprietario(s) do Cooperado:" AT 4
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_cabecalho.

FORM SKIP(2)
     "Nome:"         AT 4  tt-represen-carmag.nmdavali FORMAT "X(40)" NO-LABEL 
     SKIP                                              
     "CPF:"          AT 4  tt-represen-carmag.nrcpfppt FORMAT "X(14)" NO-LABEL 
     "Estado Civil:" AT 24 tt-represen-carmag.dsestcvl FORMAT "X(30)" NO-LABEL
     SKIP
     "Cargo:"        AT 4  tt-represen-carmag.dsproftl FORMAT "X(21)" NO-LABEL 
     SKIP
     "End.:"         AT 4  tt-represen-carmag.dsendere FORMAT "X(33)" NO-LABEL
                       "," tt-represen-carmag.nrendere FORMAT "X(5)"  NO-LABEL 
                           tt-represen-carmag.complend FORMAT "X(20)"
     "     "         AT 4  tt-represen-carmag.nmbairro FORMAT "X(40)" NO-LABEL 
                           tt-represen-carmag.nmcidade FORMAT "X(25)" NO-LABEL
                       "-" tt-represen-carmag.cdufende FORMAT "!(2)"  NO-LABEL
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_socioadmin.

FORM SKIP(2)
     "Preposto:"     AT 4  tt-represen-carmag.nmdavali FORMAT "X(40)" NO-LABEL 
     SKIP                                              
     "CPF:"          AT 4  tt-represen-carmag.nrcpfppt FORMAT "X(14)" NO-LABEL 
     "Estado Civil:" AT 24 tt-represen-carmag.dsestcvl FORMAT "X(30)" NO-LABEL
     SKIP
     "End.:"         AT 4  tt-represen-carmag.dsendere FORMAT "X(33)" NO-LABEL 
                       "," tt-represen-carmag.nrendere FORMAT "X(5)"  NO-LABEL 
                           tt-represen-carmag.complend FORMAT "X(20)"
     "     "         AT 4  tt-represen-carmag.nmbairro FORMAT "X(40)" NO-LABEL 
                           tt-represen-carmag.nmcidade FORMAT "X(25)" NO-LABEL
                       "-" tt-represen-carmag.cdufende FORMAT "!(2)"  NO-LABEL
  "Tipo de Vinculo:" AT 4  tt-represen-carmag.dsproftl FORMAT "X(21)" NO-LABEL
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_preposto.

FORM SKIP(5)SPACE(7)
     "Solicitamos a Cooperativa  acima  qualificada, que  nos  seja  dado"  
     SKIP SPACE(7) 
     "acesso aos Servicos do Caixa Eletronico atraves do cartao magnetico"  
     SKIP SPACE(7)
     "com o qual poderemos realizar as transacoes financeiras disponiveis"
     SKIP SPACE(7)
     "com acesso a nossa conta  corrente acima assinalada, em consonancia" 
     SKIP SPACE(7)
     "com  estabelecido  nas  Condicoes Gerais Aplicaveis  ao Contrato de"
     SKIP SPACE(7)                                                  
     "Conta Corrente e Investimento subscrito na data da sua abertura."
     SKIP SPACE(7)
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_autorizacao.

FORM SKIP(2) SPACE(7)
     "Para a  utilizacao  dos  Servicos do  Caixa Eletronico, autorizamos"
     SKIP SPACE(7)                                           
     "o Preposto  acima qualificado, para que individualmente, mediante o"
     SKIP SPACE(7)
     "previo cadastramento  de senha pessoal necessaria ao acesso, efetue"
     SKIP SPACE(7)
     "as transacoes disponibilizadas." 
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_autorizacao2.

FORM SKIP(2) SPACE(7)
     "Pela  presente  autorizacao  concordamos  com a revogacao, enquanto"
     SKIP SPACE(7)
     "perdurar o presente  termo, de quaisquer  disposicoes em  contrario"
     SKIP SPACE(7)
     "estabelecidas nas  Condicoes Gerais Aplicaveis ao Contrato de Conta"
     SKIP SPACE(7)
     "Corrente   e  Investimento,  com  o  qual  anuimos   em   face   da"
     SKIP SPACE(7)
     "Proposta/Contrato de Abertura de Conta Corrente por nos subscrita."
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_autorizacao3.

FORM SKIP(2) SPACE(7)
     "Assumimos  plena  responsabilidade  sobre  os  atos praticados pelo"
     SKIP SPACE(7)
     "Preposto  acima  qualificado, na condicao  de  usuario dos Servicos"
     SKIP SPACE(7)
     "do Caixa Eletronico disponibilizados pela cooperativa."
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_autorizacao4.
     
FORM SKIP(2) SPACE(7)
     "Obrigamo-nos  a comunicar  imediatamente  a  Cooperativa o furto ou"
     SKIP SPACE(7)
     "extravio do cartao magnetico, ainda que nao tenha fornecido a senha"
     SKIP SPACE(7)
     "para ninguem."
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_autorizacao41.     
     
FORM SKIP(2) SPACE(7)
     "E de  nosso  conhecimento  que a  senha e pessoal e  nao  deve  ser"
     SKIP SPACE(7)
     "repassada a qualquer pessoa, ainda que de confianca, da mesma forma"
     SKIP SPACE(7)
     "estamos  cientes  que nao  poderemos  aceitar ou solicitar ajuda de"
     SKIP SPACE(7)
     "estranhos  para operar os  sistemas eletronicos. A referida senha e"
     SKIP SPACE(7)
     "de uso exclusivo."
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_autorizacao42.     

FORM SKIP(2) SPACE(7)
     "Declaramos que e de nosso conhecimento  que nao estao  contempladas"
     SKIP SPACE(7)
     "neste  servico  quaisquer  transacoes  que  envolvam  operacoes  de"
     SKIP SPACE(7)
     "emprestimos,  as  quais  devem   ser  formalizados  diretamente  em" 
     SKIP SPACE(7)
     "qualquer dos Postos de Atendimento."
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_autorizacao5.
     
FORM SKIP(2) SPACE(7)
     "Estamos cientes de que, caso  ocorra  qualquer alteracao societaria"
     SKIP SPACE(7)
     "e a sua devida  atualizacao  nos  cadastros desta Cooperativa, novo"
     SKIP SPACE(7)
     "termo devera ser assinado, e nova senha de acesso aos servicos sera" 
     SKIP SPACE(7)
     "providenciada. A nao  observancia  deste item acarretara o bloqueio"
     SKIP SPACE(7)
     "automatico dos servicos disponiveis."
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_autorizacao51.     

FORM SKIP(2) SPACE(7)
     "Obrigamo-nos  a  comunicar,  por  escrito, a  Cooperativa, qualquer"
     SKIP SPACE(7)
     "alteracao com relacao as autorizacoes concedidas neste instrumento,"
     SKIP SPACE(7)
     "isentando esta de  qualquer  responsabilidade  pela ausencia de sua" 
     SKIP SPACE(7)
     "tempestiva realizacao."
     SKIP(3) SPACE(7)
     tt-termo-magnetico.dsrefere FORMAT "x(50)" NO-LABEL       
     SKIP(3) SPACE(7)
     "Socio(s) Proprietario(s):"
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_autorizacao6.
     
FORM SKIP(3)
     "__________________________________________________" AT 4  
     SKIP
     tt-represen-carmag.nmdavali FORMAT "X(40)" AT 4
     SKIP
     tt-represen-carmag.nrcpfppt FORMAT "X(14)" AT 4 LABEL "CPF"
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_asssocioadmin.

FORM SKIP(4)
     "Testemunhas:" AT 4     
     SKIP(3)
     "_______________________________    ______________________________" AT 4
     SKIP(6)
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_testemunhas.

FORM "De acordo"                 AT 4
     SKIP(3)
     "__________________________________________________" AT 12  
     SKIP
     tt-termo-magnetico.nmextcop AT 12 FORMAT "X(50)"
     SKIP
     tt-termo-magnetico.nrdocnpj AT 29 FORMAT "X(18)"
     SKIP(4)
     "_____________________"     AT 5
     SKIP
     tt-termo-magnetico.nmoperad AT 5  FORMAT "x(20)" NO-LABEL
     SKIP
     tt-termo-magnetico.dsmvtolt AT 5  FORMAT "x(22)" NO-LABEL
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 FRAME f_operador.
     
HIDE MESSAGE NO-PAUSE.
VIEW FRAME f_aguarde.

RUN sistema/generico/procedures/b1wgen0032.p PERSISTENT SET h_b1wgen0032.

RUN termo-responsabilidade-cartao IN h_b1wgen0032
                                           ( INPUT  glb_cdcooper,
                                             INPUT  0,
                                             INPUT  0,
                                             INPUT  glb_cdoperad,   
                                             INPUT  glb_nmdatela,
                                             INPUT  1,
                                             INPUT  par_nrdconta,
                                             INPUT  1,
                                             INPUT  glb_dtmvtolt,
                                             INPUT  YES,
                                             OUTPUT TABLE tt-erro,
                                             OUTPUT TABLE tt-termo-magnetico,
                                             OUTPUT TABLE tt-represen-carmag).
DELETE PROCEDURE h_b1wgen0032.
                                         
IF   RETURN-VALUE = "NOK"   THEN
     DO:
         FIND FIRST tt-erro NO-ERROR.
         IF   AVAIL tt-erro   THEN
              DO:
                  BELL.
                  MESSAGE tt-erro.dscritic.
                  HIDE FRAME f_aguarde NO-PAUSE.
                  RETURN "NOK".
              END.
     END.

FIND FIRST tt-termo-magnetico NO-ERROR.
IF   NOT AVAIL tt-termo-magnetico   THEN
     DO:
         HIDE FRAME f_aguarde NO-PAUSE.
         RETURN "NOK".
     END.

ASSIGN rel_dsoperad = TRIM(tt-termo-magnetico.nmoperad) + " - " + 
                      tt-termo-magnetico.dsmvtolt.

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.              

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.    

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

PUT STREAM str_1 CONTROL "\0332\033x0\022"         NULL. /* 1/6 */
PUT STREAM str_1 CONTROL "\0330\033x0\022\033\120" NULL.
         
/* Titulo */
VIEW STREAM str_1 FRAME f_titulo.

/* Aqui vem o nome da cooperativa - Cabecalho */
DISPLAY STREAM str_1 
        tt-termo-magnetico.nmextcop   tt-termo-magnetico.nmrescop
        tt-termo-magnetico.nrdocnpj   tt-termo-magnetico.nmprimtl  
        tt-termo-magnetico.nrdconta   tt-termo-magnetico.nrcpfcgc 
        WITH FRAME f_cabecalho.

/* Centraliza o nome da cooperativa */
IF   LENGTH(tt-termo-magnetico.nmextcop) < 50   THEN
     tt-termo-magnetico.nmextcop = 
              FILL(" ",INT((50 - LENGTH(tt-termo-magnetico.nmextcop)) / 2)) +
              tt-termo-magnetico.nmextcop.

/* Aqui vem os nomes dos socios/prop */
FOR EACH tt-represen-carmag WHERE
         tt-represen-carmag.dsproftl = "SOCIO/PROPRIETARIO":

    IF   LINE-COUNTER(str_1) > 75  THEN
         PAGE STREAM str_1.
         
     DISPLAY STREAM str_1 
             tt-represen-carmag.nrcpfppt   tt-represen-carmag.nmdavali 
             tt-represen-carmag.dsendere   tt-represen-carmag.nrendere 
             tt-represen-carmag.complend   tt-represen-carmag.nmbairro 
             tt-represen-carmag.nmcidade   tt-represen-carmag.cdufende 
             tt-represen-carmag.dsproftl   tt-represen-carmag.dsestcvl
             WITH FRAME f_socioadmin.

     DOWN WITH FRAME f_socioadmin.
END.

IF   LINE-COUNTER(str_1) > 75  THEN
     PAGE STREAM str_1.

/* Aqui vem o preposto */
FIND FIRST tt-represen-carmag WHERE 
           tt-represen-carmag.flgprepo = TRUE NO-LOCK NO-ERROR.

IF   AVAIL tt-represen-carmag   THEN
     DO:
        DISPLAY STREAM str_1 
                tt-represen-carmag.nrcpfppt   tt-represen-carmag.nmdavali 
                tt-represen-carmag.dsendere   tt-represen-carmag.nrendere 
                tt-represen-carmag.complend   tt-represen-carmag.nmbairro 
                tt-represen-carmag.nmcidade   tt-represen-carmag.cdufende 
                tt-represen-carmag.dsproftl   tt-represen-carmag.dsestcvl
                WITH FRAME f_preposto.
     END.
   
IF   LINE-COUNTER(str_1) > 73  THEN
     PAGE STREAM str_1.
/* Aqui vem a autorizacao */
VIEW STREAM str_1 FRAME f_autorizacao.
IF   LINE-COUNTER(str_1) > 77  THEN
     PAGE STREAM str_1.
VIEW STREAM str_1 FRAME f_autorizacao2.
IF   LINE-COUNTER(str_1) > 76  THEN
     PAGE STREAM str_1.
VIEW STREAM str_1 FRAME f_autorizacao3.
IF   LINE-COUNTER(str_1) > 78  THEN
     PAGE STREAM str_1.
VIEW STREAM str_1 FRAME f_autorizacao4.
IF   LINE-COUNTER(str_1) > 78  THEN
     PAGE STREAM str_1.
VIEW STREAM str_1 FRAME f_autorizacao41.
IF   LINE-COUNTER(str_1) > 76  THEN
     PAGE STREAM str_1.
VIEW STREAM str_1 FRAME f_autorizacao42.
IF   LINE-COUNTER(str_1) > 75  THEN
     PAGE STREAM str_1.
VIEW STREAM str_1 FRAME f_autorizacao5.
IF   LINE-COUNTER(str_1) > 76  THEN
     PAGE STREAM str_1.
VIEW STREAM str_1 FRAME f_autorizacao51.
IF   LINE-COUNTER(str_1) > 69  THEN
     PAGE STREAM str_1.
DISPLAY STREAM str_1 tt-termo-magnetico.dsrefere WITH FRAME f_autorizacao6.

/* Assinaturas dos socios/prop */
FOR EACH tt-represen-carmag NO-LOCK:
    IF   tt-represen-carmag.flgprepo   THEN
         aux_qtprepo  = aux_qtprepo + 1.
    ELSE
         aux_qtsocadm = aux_qtsocadm + 1.
END.

FOR EACH tt-represen-carmag WHERE 
         tt-represen-carmag.dsproftl = "SOCIO/PROPRIETARIO" NO-LOCK:
    
    /* Se possui socio/prop e nao for o preposto imprime sem o preposto */
    IF  (aux_qtsocadm >= aux_qtprepo)  THEN
         DO: 
            IF   LINE-COUNTER(str_1) > 75  THEN
                 PAGE STREAM str_1.

            DISPLAY STREAM str_1 
                    tt-represen-carmag.nmdavali   tt-represen-carmag.nrcpfppt
                    WITH FRAME f_asssocioadmin.
            DOWN WITH FRAME f_asssocioadmin.                      
     
         END.
    
    /* se tiver preposto e nao tiver socio/prop imprime o preposto */
    IF   aux_qtprepo > aux_qtsocadm         AND
         tt-represen-carmag.flgprepo = TRUE THEN
         DO:
            IF   LINE-COUNTER(str_1) > 75  THEN
                 PAGE STREAM str_1.

            DISPLAY STREAM str_1 
                    tt-represen-carmag.nmdavali   tt-represen-carmag.nrcpfppt
                    WITH FRAME f_asssocioadmin.
            
            DOWN WITH FRAME f_asssocioadmin.
         END.
END.

IF   LINE-COUNTER(str_1) > 68  THEN
     PAGE STREAM str_1.

VIEW STREAM str_1 FRAME f_testemunhas.

IF   LINE-COUNTER(str_1) > 69  THEN
     PAGE STREAM str_1.

DISPLAY STREAM str_1 
        tt-termo-magnetico.nmextcop   tt-termo-magnetico.nrdocnpj
        tt-termo-magnetico.nmoperad   tt-termo-magnetico.dsmvtolt
        WITH FRAME f_operador.

OUTPUT STREAM str_1 CLOSE.

HIDE FRAME f_aguarde NO-PAUSE.

/* FIND para o impressao.i */
FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper AND
                         crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

MESSAGE "Imprimindo TERMO de responsabilidade...".
{ includes/impressao.i }

RETURN "OK".
/* ......................................................................... */
