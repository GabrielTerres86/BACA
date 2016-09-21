/* ..........................................................................

   Programa: Fontes/impmatric.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Setembro/98                     Ultima atualizacao: 29/05/2014
   
   Dados referentes ao programa:

   Frequencia:
   Objetivo  : Imprimir fichas  da matricula.

   Alteracao : 26/10/1999 - Buscar dados da cooperativa no crapcop (Edson).
   
               14/09/2001 - Incluir data de admissao do associado no relatorio
                            (Junior).
                            
               20/09/2001 - Alterar data no relatorio  - CCOH: data de admissao
                            CCTEXTIL - data do cadastramento (Junior).
               
               05/02/2003 - Nao permitir a impressao de ficha de matricula para
                            contas duplicadas (Edson).
                                                                  
               30/09/2003 - Data de admissao na rel_dtadmiss (Margarete).

               27/04/2004 - Imprimir termo de parcelamento de capital (Edson).

               28/09/2004 - Tratar conta integracao (Margarete).

               28/09/2005 - Modificado FIND FIRST para FIND na tabela 
                            crapcop.cdcooper = glb_cdcooper (Diego).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               28/04/2006 - Incluir novos campos (Magui).
               
               10/04/2007 - Retirados os campos comentados de endereco da
                            crapass do fonte para nao aparecer no grep
                            (Evandro).
                            
               22/02/2008 - Alterado turno a partir de crapttl.cdturnos
                            (Gabriel).
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase).

               04/11/2008 - Retirado constante da UF "SC" e colocado campo de
                            arquivo (Martin).
                            
               08/06/2010 - Adapatado para uso de BO (Jose Luis, DB1)
               
               13/12/2010 - Alterado format dos campos nmprimtl (Henrique).
               
               06/06/2011 - Ajuste no format dos campos nmcidade e nmbairro
                            (David).
                            
               27/11/2012 - Correções em instâncias da BO52 (Lucas).
               
               25/04/2013 - Incluir campo cdufnatu no form de pessoa fisica
                            (Lucas R.)

               30/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               16/01/2014 - Ajuste em layout de CPF, CNPJ e CEP. (Jorge).
               
               05/02/2014 - Inclusao da data de demissao (tt-relat-cab.dtdemiss)
                            na impressao (Carlos).
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
............................................................................. */

{ sistema/generico/includes/b1wgen0052tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ includes/var_online.i }
{ includes/var_matric.i } 

DEF STREAM str_1.                  /* Para fichas de recadastramento */

DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL      INIT TRUE                NO-UNDO.
DEF        VAR par_flgrodar AS LOGICAL      INIT TRUE                NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_nmarqtmp AS CHAR                                  NO-UNDO.
DEF        VAR rel_asterisc AS CHAR                                  NO-UNDO.
DEF        VAR aux_qtdlinha AS INT                                   NO-UNDO.
DEF        VAR hb1wgen0052r AS HANDLE                                NO-UNDO.

FORM "Aguarde... Imprimindo ficha de matricula e/ou"  skip
     "           termo de parcelamento de capital!!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM SKIP(3)
     tt-relat-cab.nmextcop AT 1 FORMAT "x(50)"     NO-LABEL     SKIP
     tt-relat-cab.dsendcop AT 1 FORMAT "x(50)"     NO-LABEL     SKIP
     tt-relat-cab.nrdocnpj AT 1 FORMAT "x(25)"     NO-LABEL
     SKIP(2)
     "-------------------"                              AT 51
     "|MATR.:"                                          AT 51
      rel_nrmatric   NO-LABELS                          AT 62 
     "|"                                                AT 69
     "MATRICULA DE COOPERADO"                           AT 22
      rel_nrdconta   LABEL "|CONTA"                     AT 51
     "|"                                                AT 69
     "-------------------"                              AT 51
     SKIP(2)
     WITH COLUMN 12 FRAME f_cabecalho SIDE-LABELS NO-BOX WIDTH 80.
     
     
FORM SKIP(1)
     "T E R M O    D E    A D M I S S A O"   AT  19
     SKIP(1)
     "O acima qualificado e abaixo assinado,  solicita  sua  admissao  como"
     SKIP
     "cooperado desta Cooperativa, subscrevendo e integralizando  as  cotas"
     SKIP
     "de capital minimas estipulados no seu Estatuto Social."
     SKIP(1)
     "Em consequencia da sua admissao,  autoriza  o  debito  em  sua  conta"
     SKIP
     "corrente de quaisquer parcelas e/ou valores  relativos  a  obrigacoes"
     SKIP
     "que venha a assumir  com  a  Cooperativa,  inclusive  decorrentes  de"
     SKIP
     "responsabilidade subsidiaria, em face da condicao de cooperado."
     SKIP(1)
     "Por final, declara que, de forma livre e espontanea esta integrando o"
     "quadro social da Cooperativa, vinculando-se as disposicoes legais que"
     "regulam o cooperativismo, ao Sistema CECRED, ao  Estatuto  Social  da"
     "Cooperativa, ao seu Regimento Interno, as  deliberacoes  assembleares"
     "desta e as do seu Conselho de Administracao,  reconhecendo  desde  ja"
     "que qualquer celebracao  de  contrato,  seja  ativo,  passivo  ou  de"
     "prestacao de servicos, tera caracteristica de ATO COOPERATIVO."
     SKIP(2)
     "A D M I S S A O"
     SKIP(1)
     "\033\105"                     AT  2
     tt-relat-cab.dtadmiss          NO-LABEL FORMAT "99/99/9999"
     "\033\106"
     SKIP
     "_______________"
     "__________________________"   AT 19
     "______________________"       AT 48
     SKIP
     "DATA"                         AT  6
     "ASSINATURA DO COOPERADO"      AT 20
     "ASSINATURA DO DIRETOR"        AT 48
     SKIP(2)
     "D E M I S S A O"
     SKIP(1)
     "\033\105"                     AT  2
     tt-relat-cab.dtdemiss          NO-LABEL FORMAT "99/99/9999"
     "\033\106"
     SKIP
     "_______________"
     "__________________________"   AT 19
     "______________________"       AT 48
     SKIP
     "DATA"                         AT  6
     "ASSINATURA DO COOPERADO"      AT 20
     "ASSINATURA DO DIRETOR"        AT 48
     WITH COLUMN 12 WIDTH 80 FRAME f_termo SIDE-LABELS NO-BOX.

/**** Para impressao do debito de cotas ***/

FORM SKIP(3)
     tt-relat-cab.nmextcop AT 1 FORMAT "x(50)"     NO-LABEL     SKIP
     tt-relat-cab.dsendcop AT 1 FORMAT "x(50)"     NO-LABEL     SKIP
     tt-relat-cab.nrdocnpj AT 1 FORMAT "x(25)"     NO-LABEL
     SKIP(4)
     WITH COLUMN 12 NO-BOX NO-LABELS FRAME f_cooperativa.

FORM "AUTORIZACAO DE DEBITO EM CONTA-CORRENTE PARA AUMENTO DE CAPITAL" 
     SKIP
     "===============================================================" 
     SKIP
     "             (PARCELAMENTO DA SUBSCRICAO INICIAL)"               
     SKIP(3)
     tt-relat-par.nrdconta AT  2 FORMAT "X(10)" LABEL "Conta/dv"
     tt-relat-par.nrmatric AT 27 FORMAT "X(7)" LABEL "Matricula"
     SKIP(1)
     tt-relat-par.nmprimtl AT  1 FORMAT "x(50)" LABEL "Associado"
     SKIP(4)
     "O associado acima qualificado, autoriza um debito mensal em conta-" SKIP
     "corrente de depositos a vista, em" 
     tt-relat-par.dsdprazo               FORMAT "x(2)" NO-LABEL 
     "parcela(s), na importancia de" SKIP
     "R$" tt-relat-par.vlparcel          FORMAT "x(10)" NO-LABEL 
     tt-relat-par.dsparcel[1]            FORMAT "x(52)" NO-LABEL SKIP
     tt-relat-par.dsparcel[2]            FORMAT "x(66)" NO-LABEL SKIP
     "a partir de" tt-relat-par.dtdebito FORMAT "99/99/9999" NO-LABEL 
     ", para credito de suas cotas de CAPITAL."
     SKIP(4)
     WITH COLUMN 12 NO-BOX SIDE-LABELS NO-LABELS FRAME f_autoriza.

FORM "O debito sera efetuado  somente mediante  suficiente  provisao  de" SKIP
     "fundos. Quando a data do debito nao coincidir com dia util, o lan-" SKIP
     "camento sera efetuado no primeiro dia util subsequente."
     SKIP(4)
     WITH COLUMN 12 NO-BOX FRAME f_saldo.

FORM SKIP(5)
     tt-relat-cab.nmcidade           FORMAT "X(19)" 
     tt-relat-cab.dtmvtolt           FORMAT "99/99/9999" "." SKIP(5)
     "_________________________________ " 
     "_______________________________"  SKIP
     tt-relat-cab.nmprimtl     AT  1 FORMAT "x(33)" NO-LABEL
     tt-relat-cab.nmrescop[1]  AT 36 FORMAT "x(32)" SKIP
     tt-relat-cab.nmrescop[2]  AT 36 FORMAT "x(32)"
     WITH COLUMN 12 NO-BOX NO-LABELS FRAME f_assina.

/* .......................................................................... */



RUN Busca_Impressao.

IF  RETURN-VALUE <> "OK" THEN
    RETURN.

FIND FIRST tt-relat-cab NO-ERROR.

IF  NOT AVAILABLE tt-relat-cab THEN
    DO:
       MESSAGE "Dados para o cabecalho do relatorio nao foram encontrados.".
       RETURN.
    END.

/* Efetuar a busca p/ causa do impressao.i */
FIND crapass WHERE crapass.cdcooper = glb_cdcooper AND
                   crapass.nrdconta = tel_nrdconta NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapass THEN
     DO:
         glb_cdcritic = 9.
         RUN fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         glb_cdcritic = 0.
         RETURN.
     END.

HIDE MESSAGE NO-PAUSE.

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

PUT STREAM str_1 CONTROL "\022\024\033\120\0330" NULL.

IF   tt-relat-cab.inpessoa = 1   THEN
     RUN trata_conta_fisica.
ELSE
     RUN trata_conta_juridica.

RUN proc_parcela.

OUTPUT STREAM str_1 CLOSE.

{ includes/impressao.i } 

PROCEDURE trata_conta_fisica:

    FORM "PA (POSTO DE ATENDIMENTO):"
         tt-relat-fis.cdagenci "-" tt-relat-fis.nmresage SKIP(1)
         "CONTA / DV....:"         tt-relat-fis.nrdconta FORMAT "X(9)" SKIP(1)
         "NOME..........:"         tt-relat-fis.nmprimtl SKIP(1)
         "CPF...........:"         tt-relat-fis.nrcpfcgc
         "DOCUMENTO:"        AT 44 tt-relat-fis.nrdocptl SKIP(1)
         "ORG.EMI.......:"         tt-relat-fis.cdoedptl
         "UF:"               AT 31 tt-relat-fis.cdufdptl
         "DATA EMI:"         AT 45 tt-relat-fis.dtemdptl SKIP(1)
         "FILIACAO......:"         
         tt-relat-fis.nmmaettl                           SKIP    
         SPACE(16)
         tt-relat-fis.nmpaittl                           SKIP(1)
         "NASCIMENTO....:"         tt-relat-fis.dtnasctl
         "SEXO:"             AT 49 tt-relat-fis.cdsexotl SKIP(1)
         "NATURAL DE....:"         tt-relat-fis.dsnatura FORMAT "x(25)"
         "UF:"               AT 49 tt-relat-fis.cdufnatu SKIP(1)
         "NACIONALIDADE.:"         tt-relat-fis.dsnacion
          SKIP(1)
         "ENDERECO......:"         tt-relat-fis.dsendere FORMAT "x(40)"
         "NRO:"                    tt-relat-fis.nrendere FORMAT "x(7)"  SKIP(1)
         "COMPLEMENTO...:"         tt-relat-fis.complend SKIP(1)
         "BAIRRO........:"         tt-relat-fis.nmbairro FORMAT "x(40)" SKIP(1)
         "CIDADE........:"         tt-relat-fis.nmcidade FORMAT "x(25)"
         "UF:"             AT 44   tt-relat-fis.cdufende
         "CEP:"            AT 52   tt-relat-fis.nrcepend FORMAT "X(10)" SKIP(1)
         "PROFISSAO.....:"         tt-relat-fis.dsocpttl FORMAT "x(50)" SKIP(1)
         "EMPRESA.......:"         tt-relat-fis.nmempres FORMAT "x(35)"
         "TURNO:"          AT 53   tt-relat-fis.cdturnos SKIP(1)
         "CADASTRO / DV.:"         tt-relat-fis.nrcadast FORMAT "X(10)" SKIP(1)
         "ESTADO CIVIL..:"         tt-relat-fis.dsestcvl SKIP(1)
         "CONJUGE.......:"         tt-relat-fis.nmconjug
         WITH COLUMN 12 FRAME f_fisica NO-LABELS NO-BOX.

    FIND tt-relat-fis WHERE 
        INT(REPLACE(tt-relat-fis.nrdconta,".","")) = tel_nrdconta NO-ERROR.

    IF  NOT AVAILABLE tt-relat-fis THEN
        DO:
           MESSAGE "Relatorio dos dados da pessoa fisica nao encontrado.".
           READKEY.
           RETURN "NOK".
        END.

    ASSIGN
        rel_nrmatric = INTEGER(tt-relat-cab.nrmatric)
        rel_nrdconta = INTEGER(tt-relat-cab.nrdconta).
         
    DISPLAY STREAM str_1 
        tt-relat-cab.nmextcop    
        tt-relat-cab.dsendcop
        tt-relat-cab.nrdocnpj        
        rel_nrmatric
        rel_nrdconta
        WITH FRAME f_cabecalho.
    
    DISPLAY STREAM str_1 
        tt-relat-fis.nmresage        
        tt-relat-fis.nrdconta
        tt-relat-fis.nrcadast    
        tt-relat-fis.nmprimtl
        tt-relat-fis.nrcpfcgc        
        tt-relat-fis.nrdocptl
        tt-relat-fis.cdoedptl    
        tt-relat-fis.cdufdptl
        tt-relat-fis.dtemdptl    
        tt-relat-fis.nmmaettl
        tt-relat-fis.dtnasctl    
        tt-relat-fis.cdsexotl
        tt-relat-fis.dsnatura
        tt-relat-fis.cdufnatu
        tt-relat-fis.dsnacion    
        tt-relat-fis.dsendere    
        tt-relat-fis.nrendere
        tt-relat-fis.complend    
        tt-relat-fis.nmbairro
        tt-relat-fis.nmcidade    
        tt-relat-fis.cdufende
        tt-relat-fis.nrcepend    
        tt-relat-fis.dsocpttl
        tt-relat-fis.nmempres        
        tt-relat-fis.cdturnos    
        tt-relat-fis.dsestcvl        
        tt-relat-fis.nmconjug
        tt-relat-fis.cdagenci    
        tt-relat-fis.nmpaittl
        WITH FRAME f_fisica.
                         
    DISPLAY STREAM str_1 tt-relat-cab.dtadmiss tt-relat-cab.dtdemiss WITH FRAME f_termo.

END PROCEDURE.


PROCEDURE trata_conta_juridica:

    FORM "PA (POSTO DE ATENDIMENTO):" tt-relat-jur.cdagenci 
         " - "                    tt-relat-jur.nmresage SKIP(1)
         "CONTA / DV....:"        tt-relat-jur.nrdconta FORMAT "X(10)" SKIP(1)
         "RAZAO SOCIAL..:"        tt-relat-jur.nmprimtl SKIP(1)
         "NOME FANTASIA.:"        tt-relat-jur.nmfansia SKIP(1)
         "CNPJ..........:"        tt-relat-jur.nrcpfcgc
         "INSCR.ESTAD.:"   AT 39  tt-relat-jur.nrinsest SKIP(1)
         "DATA CONSTITU.:"        tt-relat-jur.dtiniatv
         "NAT.JURIDICA:"   AT 39  tt-relat-jur.rsnatjur SKIP(1)
         "ATIV.PRINCIPAL:"        tt-relat-jur.cdrmativ
         "-"                      tt-relat-jur.dsrmativ SKIP(1)
         "ENDERECO......:"        tt-relat-jur.dsendere FORMAT "x(40)"
         "NRO:"                   tt-relat-jur.nrendere FORMAT "x(7)"  SKIP(1)
         "COMPLEMENTO...:"        tt-relat-jur.complend FORMAT "x(40)" SKIP(1) 
         "BAIRRO........:"        tt-relat-jur.nmbairro FORMAT "x(40)" SKIP(1)
         "CIDADE........:"        tt-relat-jur.nmcidade FORMAT "x(25)" 
         "UF:"             AT 44  tt-relat-jur.cdufende 
         "CEP:"            AT 52  tt-relat-jur.nrcepend FORMAT "X(10)" SKIP(1)
         "TELEFONE......:"           
          "(" SPACE(0) tt-relat-jur.nrdddtfc SPACE(0) ")" SPACE(0)
         tt-relat-jur.nrtelefo
         WITH COLUMN 12 FRAME f_juridica NO-LABELS NO-BOX.
         
    FORM SKIP(1)
         "-----------REPRESENTANTES LEGAIS/MANDATARIOS OU"
         "PREPOSTOS------------"
         SKIP
         "NOME"
         "CPF"     AT 33
         "FUNCAO"  AT 50
         WITH COLUMN 12 WIDTH 80 FRAME f_cab_repres NO-LABELS NO-BOX.
         
    FORM tt-relat-rep.nmdavali               FORMAT "x(30)"
         tt-relat-rep.nrcpfcgc   AT 33       FORMAT "X(14)"
         tt-relat-rep.dsproftl   AT 50
         WITH DOWN COLUMN 12 WIDTH 80 FRAME f_repres NO-LABELS NO-BOX.
         
    FIND tt-relat-jur WHERE 
        INT(REPLACE(tt-relat-jur.nrdconta,".","")) = tel_nrdconta NO-ERROR.

    IF  NOT AVAILABLE tt-relat-jur THEN
        DO:
           MESSAGE "Relatorio dos dados da pessoa juridica nao encontrado.".
           READKEY.
           RETURN "NOK".
        END.

    ASSIGN
        rel_nrmatric = INTEGER(tt-relat-cab.nrmatric)
        rel_nrdconta = INTEGER(tt-relat-cab.nrdconta).

    DISPLAY STREAM str_1 
        tt-relat-cab.nmextcop    
        tt-relat-cab.dsendcop
        tt-relat-cab.nrdocnpj        
        rel_nrmatric
        rel_nrdconta
        WITH FRAME f_cabecalho.
                         
    DISPLAY STREAM str_1 
        tt-relat-jur.nmresage        
        tt-relat-jur.nrdconta
        tt-relat-jur.nmprimtl    
        tt-relat-jur.nmfansia
        tt-relat-jur.nrcpfcgc        
        tt-relat-jur.nrinsest
        tt-relat-jur.dtiniatv    
        tt-relat-jur.rsnatjur
        tt-relat-jur.cdrmativ    
        tt-relat-jur.dsrmativ
        tt-relat-jur.dsendere    
        tt-relat-jur.nrendere
        tt-relat-jur.complend    
        tt-relat-jur.nmbairro
        tt-relat-jur.nmcidade    
        tt-relat-jur.cdufende
        tt-relat-jur.nrcepend    
        tt-relat-jur.nrtelefo
        tt-relat-jur.cdagenci    
        tt-relat-jur.nrdddtfc
        WITH FRAME f_juridica.
                         
    /* Representantes */
    VIEW STREAM str_1 FRAME f_cab_repres.

    FOR EACH tt-relat-rep:
        DISPLAY STREAM str_1 
            tt-relat-rep.nmdavali
            tt-relat-rep.nrcpfcgc
            tt-relat-rep.dsproftl
            WITH FRAME f_repres.
                             
        DOWN STREAM str_1 WITH FRAME f_repres.
    END.

    /* verifica se nao cabe o termo e as assinaturas num total de 35 linhas */
    IF   LINE-COUNTER(str_1) + 35 >= PAGE-SIZE(str_1)   THEN
         DO:
            /* preenche com asteriscos o final da pagina */
            aux_qtdlinha = PAGE-SIZE(str_1) - LINE-COUNTER(str_1).

            DO aux_contador = 0 TO aux_qtdlinha - 1:

               /* 80 - porque sao 80 colunas (92 - 12 de margem esquerda) */
               rel_asterisc = "           " + 
                              FILL(" ",INT(80 / aux_qtdlinha) * aux_contador) +
                              "**".
   
               PUT STREAM str_1 rel_asterisc FORMAT "x(80)" SKIP.
   
               IF   LENGTH(rel_asterisc) >= 80               AND
                    LINE-COUNTER(str_1) < PAGE-SIZE(str_1)   THEN
                    ASSIGN aux_contador = 0.

               IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)  THEN
                    LEAVE.
            END.

            PAGE STREAM str_1.

            ASSIGN
                rel_nrmatric = INTEGER(tt-relat-cab.nrmatric)
                rel_nrdconta = INTEGER(tt-relat-cab.nrdconta).
         
            DISPLAY STREAM str_1 
                tt-relat-cab.nmextcop    
                tt-relat-cab.dsendcop
                tt-relat-cab.nrdocnpj        
                rel_nrmatric
                rel_nrdconta
                WITH FRAME f_cabecalho.
         END.
    
    DISPLAY STREAM str_1 tt-relat-cab.dtadmiss tt-relat-cab.dtdemiss 
        WITH FRAME f_termo.
    
END.
     
/* .......................................................................... */

PROCEDURE proc_parcela:

    FIND FIRST tt-relat-par NO-ERROR.

    IF  NOT AVAILABLE tt-relat-par THEN
        RETURN.

    DISPLAY STREAM str_1 
        tt-relat-cab.nmextcop
        tt-relat-cab.dsendcop
        tt-relat-cab.nrdocnpj
        WITH FRAME f_cooperativa.

    DISPLAY STREAM str_1
        tt-relat-par.nrdconta  
        tt-relat-par.nrmatric
        tt-relat-par.nmprimtl  
        tt-relat-par.dsdprazo      
        tt-relat-par.dtdebito
        tt-relat-par.vlparcel      
        tt-relat-par.dsparcel[1]   
        tt-relat-par.dsparcel[2]
        WITH FRAME f_autoriza.

    VIEW STREAM str_1 FRAME f_saldo.

    DISPLAY STREAM str_1
        tt-relat-cab.nmcidade  
        tt-relat-cab.dtmvtolt  
        tt-relat-cab.nmprimtl 
        tt-relat-cab.nmrescop[1]  
        tt-relat-cab.nmrescop[2]
        WITH FRAME f_assina.

END PROCEDURE.

/* ......................................................................... */

PROCEDURE Busca_Impressao:

    IF  NOT VALID-HANDLE(hb1wgen0052r) THEN
        RUN sistema/generico/procedures/b1wgen0052.p 
            PERSISTENT SET hb1wgen0052r.

    RUN Busca_Impressao IN hb1wgen0052r
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT 1, 
          INPUT YES,
          INPUT glb_dtmvtolt,
         OUTPUT TABLE tt-relat-cab,
         OUTPUT TABLE tt-relat-par,
         OUTPUT TABLE tt-relat-fis,
         OUTPUT TABLE tt-relat-jur,
         OUTPUT TABLE tt-relat-rep,
         OUTPUT TABLE tt-erro ) NO-ERROR.

    IF  VALID-HANDLE(hb1wgen0052r) THEN
        DELETE PROCEDURE hb1wgen0052r.

    IF  ERROR-STATUS:ERROR THEN
        DO:
           MESSAGE ERROR-STATUS:GET-MESSAGE(1).
           RETURN "NOK".
        END.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    RETURN "OK".

END PROCEDURE.
