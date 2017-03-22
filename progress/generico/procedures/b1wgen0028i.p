/*..............................................................................

   Programa  : b1wgen0028i.p
   Autor     : Sandro (GATI)
   Data      : Novembro/2010                    Ultima Atualizacao: 14/02/2017

   Dados referentes ao programa:

   Objetivo  : Tratar impressoes da BO 028.

   Alteracoes: 12/01/2011 - Corrigido posicionamento do campo aux_dsciddat na 
                            nota promissoria, e aumentado numero de linhas para
                            quebra de pagina da Proposta de Cartao (Diego).

               19/01/2011 - Ajuste da impressao dos documentos:
                            - Termo de entrega de cartao;
                            - Termo de solicitacao de segunda via de cartao;
                            - Termo de solicitacao de segunda via de senha;
                            - Termo de cancelamento de cartao;
                            - Termo de alteracao de data de vencimento do 
                              cartao;
                            - Termo de alteracao do valor de limite do cartao.
                            Os ajustes foram:
                            - Ajuste do nome do associado para 50 posicoes nas
                              assinaturas;
                            - Utilizacao do nome completo da Cooperativa;
                            - Utilizacao de tracejado tambem para Cooperativa.
                            (GATI - Eder).

               23/02/2011 - Inclusão da procedure termo_encerra_cartao
                            (Isara - RKAM).

               28/03/2011 - Parametrizado o nome da Adm. de Cartao em 
                            termo_encerra_cartao (Irlan).

               30/05/2011 - Alterado format do campo 
                            tt_dados_promissoria_imp.endeass2. (Fabricio)

               01/09/2011 - Impressao do Extrato Cecred Visa em PDF
                           (Guilherme/Supero)
                           
               17/01/2012 - Handle preso na BO99999 (Oscar).
               
               17/04/2012 - Inclusão da procedure gera_impressao_contrato_bb.
                            (David Kruger).
               
               17/08/2012 - Corrigido a impressao do contrato e emissao  
                            proposta cartao (Tiago).
                            
               22/08/2012 - Corrigido impressao Prop.Alteracao de Limite 
                            de Cartao de Credito, numero da proposta
                            estava cortado na impressão (Tiago).             
                            
               03/09/2013 - Quebra de Página da Proposta de Novo Limite
                            de Crédito na procedure 'imprimi_limite_pf' (Lucas).
               
               12/11/2013 - Nova forma de chamar as agências, agora 
                            a escrita será PA (Guilherme Gielow)  
               
               05/08/2014 - Alteração da Nomeclatura para PA (Vanessa).           
               
               09/10/2015 - Desenvolvimento do projeto 126. (James)
               
			   14/02/2017 - Ajustando o format do campo nrctrcrd nos relatórios que o utilizam.
							SD 594718 (Kelvin).
               
..............................................................................*/

{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/b1wgen0019tt.i }
{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/b1wgen0028tt.i }

{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/b1wgen0069tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }

{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF SHARED STREAM str_1.

DEF  VAR aux_dscartao AS CHAR INIT "NACIONAL,INTERNACIONAL,GOLD"       NO-UNDO.
DEF  VAR aux_cdcartao AS CHAR INIT "1,2,3"                             NO-UNDO.
DEF  VAR aux_dsgraupr AS CHAR INIT
     "Conjuge,Filhos,Companheiro,Primeiro Titular,Segundo Titular"     NO-UNDO.
DEF  VAR aux_cdgraupr AS CHAR INIT "1,3,4,5,6"                         NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.

DEFINE VARIABLE aux_qtregist AS INTEGER     NO-UNDO.

DEFINE VARIABLE h-b1wgen0028     AS HANDLE                             NO-UNDO.


/**************************
    PROCEDURES GERAIS
**************************/    
PROCEDURE gera_impressao_proposta_cartao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.       
    DEF  INPUT PARAM par_nrctrcrd AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.    

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
 
    DEF   VAR h-b1wgen0024     AS HANDLE                                 NO-UNDO.

    DEF   VAR rel_dsemsprp     AS CHAR                                   NO-UNDO.
    DEF   VAR rel_asterisc     AS CHAR                                   NO-UNDO.
    DEF   VAR aux_contador     AS INT                                    NO-UNDO.
    DEF   VAR aux_qtdlinha     AS INT                                    NO-UNDO.
    DEF   VAR aux_nmarqimp     AS CHAR                                   NO-UNDO.
    DEF   VAR aux_nmprimtl     AS CHAR                                   NO-UNDO.
    DEF   VAR aux_nmarquiv     AS CHAR                                   NO-UNDO.
    DEF   VAR aux_nmarqpdf     AS CHAR                                   NO-UNDO.
        
    FORM "\022\024\033\120\0330\033x0\033\105"  /* Reseta impressora */
         SKIP
         tt-dados_prp_ccr.nmextcop FORMAT "x(70)"
         SKIP(2)
         "PROPOSTA DE CARTAO DE CREDITO"
         tt-dados_prp_ccr.dsadicio FORMAT "X(35)"
         SKIP(1)
         "Numero da proposta:" AT 50 tt-dados_prp_ccr.nrctrcrd FORMAT "zzz,zzz,zz9"
         "\033\120\033\106"                          
         WITH NO-BOX COLUMN 1 NO-LABELS WIDTH 80 FRAME f_cooperativa.    
    
    
    FORM "\022\024\033\120\0330\033x0\033\105"  /* Reseta impressora */
         SKIP
         tt-dados_prp_ccr.nmextcop FORMAT "x(70)"
         SKIP(2)
         "PROPOSTA DE CARTAO DE CREDITO" AT 15
         tt-dados_prp_ccr.dsadicio FORMAT "X(35)" AT 45
         SKIP
         "PESSOA JURIDICA"  AT 28
         SKIP(1)
         "Numero da proposta:\033\120\033\106" AT 50 tt-dados_prp_ccr.nrctrcrd FORMAT "zzz,zzz,zz9"
    /*      "\033\120\033\106" */
         WITH NO-BOX COLUMN 1 NO-LABELS WIDTH 80 FRAME f_cooperativa_pj.    
    
    
    FORM "\0332\033x0DADOS DO ASSOCIADO"
         SKIP(1)
         "Conta/dv:"                tt-dados_prp_ccr.nrdconta FORMAT "zzzz,zzz,9"
         "Matricula:"        AT 29  tt-dados_prp_ccr.nrmatric FORMAT "zzz,zz9"
         "PA"                AT 50  tt-dados_prp_ccr.nmresage FORMAT "X(21)"
         SKIP(1)
         "Nome do(s) titular(es):"  tt-dados_prp_ccr.nmprimtl FORMAT "x(34)"
         "Admissao:"          AT 61 tt-dados_prp_ccr.dtadmiss FORMAT "99/99/9999"
         SKIP
         "CPF/CNPJ:"                tt-dados_prp_ccr.nrcpfcgc FORMAT "X(18)"
         SKIP
         tt-dados_prp_ccr.nmsegntl AT 25                      FORMAT "X(40)"
         SKIP
         "Empresa:"                 tt-dados_prp_ccr.nmresemp FORMAT "X(33)"
         "Secao:"             AT 46 tt-dados_prp_ccr.nmdsecao FORMAT "X(20)"
         SKIP
         "Telefone/Ramal:"          tt-dados_prp_ccr.nrdofone FORMAT "X(20)"
         SKIP
         "Tipo de conta:"           tt-dados_prp_ccr.dstipcta FORMAT "x(20)"
         "Situacao da conta:" AT 38 tt-dados_prp_ccr.dssitdct FORMAT "x(22)"
         SKIP(1)      
                                    tt-dados_prp_ccr.tpcartao FORMAT "x(60)"
         SKIP(1)
         "Titular:"                 tt-dados_prp_ccr.nmtitcrd FORMAT "X(40)"
         "CPF:"             AT 62 tt-dados_prp_ccr.nrcpftit FORMAT "999,999,999,99"
         SKIP
         "Parentesco:"             tt-dados_prp_ccr.dsparent  FORMAT "X(25)"
         SKIP(1)
         "RECIPROCIDADE"
         SKIP(1)
         "Saldo medio do trimestre:" tt-dados_prp_ccr.vlsmdtri 
                                                            FORMAT "zzzzzz,zz9.99"
         "Capital:"         AT 41 tt-dados_prp_ccr.vlcaptal FORMAT "zzzzzz,zz9.99"
         "Plano:"           AT 64 tt-dados_prp_ccr.vlprepla FORMAT "zzz,zz9.99"
         SKIP
         "Aplicacoes:"            tt-dados_prp_ccr.vlaplica FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "RENDA MENSAL"
         SKIP(1)
         "Salario:"                  tt-dados_prp_ccr.vlsalari FORMAT "zzzz,zz9.99"
         "Salario do conjuge:" AT 23 tt-dados_prp_ccr.vlsalcon FORMAT "zzzz,zz9.99"
         "Outras rendas:"      AT 55 tt-dados_prp_ccr.vloutras FORMAT "zzzz,zz9.99"
         SKIP
         "Limite de credito:"        tt-dados_prp_ccr.vllimcre FORMAT "zzz,zz9.99"
         "Aluguel:"            AT 61 tt-dados_prp_ccr.vlalugue FORMAT "zzzz,zz9.99"
         SKIP
         "    Limite Debito:"        tt-dados_prp_ccr.vllimdeb FORMAT "zzz,zz9.99"
         SKIP(1)
         "DIVIDA:"
         "TOTAL OP.CREDITO:"   AT 15
         tt-dados_prp_ccr.vlutiliz 
         SKIP(1)
         "Saldo devedor de emprestimos:" tt-dados_prp_ccr.vltotemp
         "Prestacoes:"             AT 49 tt-dados_prp_ccr.vltotpre
         WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_dados.
        
    FORM "\0332\033x0DADOS DO ASSOCIADO"
         SKIP(1)
         "Conta/dv:"                tt-dados_prp_ccr.nrdconta FORMAT "zzzz,zzz,9"
         "Matricula:"        AT 29  tt-dados_prp_ccr.nrmatric FORMAT "zzz,zz9"
         "PA"                AT 50  tt-dados_prp_ccr.nmresage FORMAT "X(21)"
         SKIP(1)
         "Nome da empresa:"  tt-dados_prp_ccr.nmprimtl FORMAT "x(34)"
         "Data admissao:"          AT 56 tt-dados_prp_ccr.dtadmiss FORMAT "99/99/9999"
         SKIP
         "CNPJ/MF:"                tt-dados_prp_ccr.nrcpfcgc FORMAT "X(18)"
         SKIP
         "Representante(s) Legal(ais) - nomeado(s) abaixo"
         SKIP
         "Tipo de conta:"           tt-dados_prp_ccr.dstipcta FORMAT "x(20)"
         "Situacao da conta:" AT 38 tt-dados_prp_ccr.dssitdct FORMAT "x(22)"
         SKIP(1)      
         "RECIPROCIDADE"
         SKIP(1)
         "Saldo medio trimestre:" tt-dados_prp_ccr.vlsmdtri FORMAT "zzz,zzz,zz9.99"
         "Capital:"         AT 41 tt-dados_prp_ccr.vlcaptal FORMAT "zzzzzz,zz9.99"
         "Plano:"           AT 64 tt-dados_prp_ccr.vlprepla FORMAT "zzz,zz9.99"
         SKIP
         "Aplicacoes:"            tt-dados_prp_ccr.vlaplica FORMAT "zzz,zzz,zz9.99"
         SKIP
         "Limite de credito:"        tt-dados_prp_ccr.vllimcre FORMAT "zzz,zzz,zz9.99"
         SKIP
         "Limite de debito: "        tt-dados_prp_ccr.vllimdeb FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "RENDA MENSAL"
         SKIP(1)
         "Faturamento do mes:"                  tt-dados_prp_ccr.vlrftmes FORMAT "zzz,zzz,zz9.99"                                                                                 
         "Faturamento ultimos 12 meses:" AT 37 tt-dados_prp_ccr.vlrfttot  FORMAT "zzz,zzz,zz9.99"    
         SKIP(1)           
         "DIVIDAS E OBRIGACOES"
         SKIP(1)
         "Total Operacoes de credito:" tt-dados_prp_ccr.vlutiliz FORMAT "zzz,zzz,zz9.99"
         SKIP
         "Saldo devedor de emprestimos:" tt-dados_prp_ccr.vltotemp FORMAT "zzz,zzz,zz9.99"
         SKIP
         "Prestacoes Mensais:"  tt-dados_prp_ccr.vltotpre FORMAT "zzz,zzz,zz9.99"
         WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_dados_pj.
        
    FORM SKIP(1)
         "OUTROS CARTOES"
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_outros.
    
    FORM SKIP
         tt-outros_cartoes.dsdnomes FORMAT "x(23)"
         tt-outros_cartoes.dstipcrd FORMAT "x(34)"
         tt-outros_cartoes.vllimite FORMAT "zzz,zz9.99"
         tt-outros_cartoes.dssituac FORMAT "x(10)"
         WITH NO-BOX NO-LABELS WIDTH 80 DOWN FRAME f_cartoes.
    
    FORM SKIP(1)
         "Dia do debito em conta corrente:"  tt-dados_prp_ccr.dddebito FORMAT "99"
         "Conta-mae:" AT 51 tt-dados_prp_ccr.nrctamae FORMAT "9999,9999,9999,9999"
          SKIP(1)
         "Limite Proposto:" tt-dados_prp_ccr.cdlimcrd FORMAT "99999" "-"
                            tt-dados_prp_ccr.vllimcrd FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "\022\033\115\033\106AUTORIZO A CONSULTA DE MINHAS INFORMACOES CADASTRAIS"
         "NOS SERVICOS DE PROTECAO AO CREDITO" SKIP 
         "(SPC, SERASA, CADIN, ...) ALEM DO CADASTRO DA CENTRAL"         
         "DE RISCO DO BANCO CENTRAL DO BRASIL.\024\022\033\120\0332\033x0"
         SKIP(1)
         "CONSULTADO  SPC  EM ____/____/_______"
         SKIP(1)
         "CENTRAL DE RISCO EM ____/____/_______"
         "SITUACAO: ____________ VISTO: ___________" AT 39
         SKIP(1)
         "APROVACAO"
         SKIP(1)
         "____________________________________" AT  3
         "____________________________________" AT 44
         SKIP
         "  Operador:" tt-dados_prp_ccr.nmoperad       FORMAT "x(26)"
                       tt-dados_prp_ccr.nmrecop1 AT 44 FORMAT "x(36)" SKIP
                       tt-dados_prp_ccr.nmrecop2 AT 44 FORMAT "x(36)" SKIP(1)
         "__________________________________________________" AT 3
         SKIP
         tt-dados_prp_ccr.nmprimtl      FORMAT "X(50)" AT 3
         "\022\033\115\033\106"
         tt-dados_prp_ccr.nmcidade      FORMAT "x(13)"  
         ", " tt-dados_prp_ccr.dsemsprp FORMAT "X(25)" "."
         "\024\022\033\120\0332\033x0"
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_final. 
        
    FORM SKIP(1)
                                
         "LIMITE CARTAO EMPRESARIAL:" tt-dados_prp_ccr.vllimcrd FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "\022\033\115\033\106AUTORIZO A CONSULTA DE MINHAS INFORMACOES CADASTRAIS"
         "NOS SERVICOS DE PROTECAO AO CREDITO" SKIP 
         "(SPC, SERASA, CADIN, ...) ALEM DO CADASTRO DA CENTRAL"
         "DE RISCO DO BANCO CENTRAL DO BRASIL.\024\022\033\120\0332\033x0"
         SKIP(1)
         "CONSULTADO  SPC  EM ____/____/_______"
         SKIP(1)
         "CENTRAL DE RISCO EM ____/____/_______"
         "SITUACAO: ____________ VISTO: ___________" AT 39
         SKIP(1)
         "APROVACAO"
         SKIP(1)
         "______________________________________" AT  1
         "______________________________________" AT 42
         SKIP
         "Operador:" tt-dados_prp_ccr.nmoperad       FORMAT "x(26)"
                       tt-dados_prp_ccr.nmrecop1 AT 42 FORMAT "x(36)" 
                       SKIP
                       tt-dados_prp_ccr.nmrecop2 AT 42 FORMAT "x(36)" 
                       SKIP(1)    
         SKIP(3)
        "__________________________________________________" AT  1
        "__________________________________________________" AT 56
    
         SKIP
         /* imprimir nome da empresa aqui */
         tt-dados_prp_ccr.nmprimtl      FORMAT "X(50)" AT 1
         aux_nmprimtl                   FORMAT "X(50)" AT 56
         SKIP
        "Nome representante:" 
        "Nome representante:" AT 56
         SKIP
        "CPF representante:" 
        "CPF representante:"  AT 56
         SKIP(3)   
         "\022\033\115\033\106"
         rel_dsemsprp FORMAT "X(50)"
         "\024\022\033\120\0332\033x0"
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 110 FRAME f_final_pj. 
        
    /*  utiliza o handle da bo 028 que ja esta na memoria.*/
    ASSIGN h-b1wgen0028 = SOURCE-PROCEDURE.

    IF  NOT VALID-HANDLE(h-b1wgen0028) THEN
        DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO " +
                                  "b1wgen0028.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
    
        END.

    RUN impressoes_cartoes IN h-b1wgen0028 ( INPUT  par_cdcooper,
                                             INPUT  0,
                                             INPUT  0,
                                             INPUT  par_cdoperad,
                                             INPUT  par_nmdatela,
                                             INPUT  1,
                                             INPUT  par_nrdconta,
                                             INPUT  1,
                                             INPUT  par_dtmvtolt,
                                             INPUT  par_dtmvtopr,
                                             INPUT  par_inproces,
                                             INPUT  3, /* Proposta */
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

    IF   RETURN-VALUE = "NOK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
             IF   AVAIL tt-erro   THEN
                 RETURN "NOK".

         END.

    FIND tt-dados_prp_ccr NO-ERROR.
    IF   NOT AVAIL tt-dados_prp_ccr   THEN
         DO:

             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Nao foi possivel gerar a impressao.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT 0,
                            INPUT 0,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".

         END.

    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                          par_dsiduser.
    
    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
     
    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    ASSIGN aux_nmprimtl = tt-dados_prp_ccr.nmprimtl.

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 80.

    FIND crapass WHERE
         crapass.cdcooper = par_cdcooper AND
         crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  crapass.inpessoa = 1   THEN
        DISPLAY STREAM str_1
                tt-dados_prp_ccr.nmextcop   tt-dados_prp_ccr.dsadicio
                tt-dados_prp_ccr.nrctrcrd
                WITH FRAME f_cooperativa.
    ELSE
        DISPLAY STREAM str_1
                tt-dados_prp_ccr.nmextcop   tt-dados_prp_ccr.dsadicio
                tt-dados_prp_ccr.nrctrcrd
                WITH FRAME f_cooperativa_pj.


    IF  crapass.inpessoa = 1   THEN
        DO:

            DISPLAY STREAM str_1
                    tt-dados_prp_ccr.nrdconta   tt-dados_prp_ccr.nrmatric
                    tt-dados_prp_ccr.nmresage   tt-dados_prp_ccr.nmprimtl
                    tt-dados_prp_ccr.dtadmiss   tt-dados_prp_ccr.nmsegntl
                    tt-dados_prp_ccr.nmresemp   tt-dados_prp_ccr.nmdsecao
                    tt-dados_prp_ccr.nrdofone   tt-dados_prp_ccr.dstipcta
                    tt-dados_prp_ccr.dssitdct   tt-dados_prp_ccr.tpcartao
                    tt-dados_prp_ccr.nmtitcrd   tt-dados_prp_ccr.vlaplica
                    tt-dados_prp_ccr.nrcpfcgc   tt-dados_prp_ccr.nrcpftit
                    tt-dados_prp_ccr.dsparent   tt-dados_prp_ccr.vlsmdtri
                    tt-dados_prp_ccr.vlcaptal   tt-dados_prp_ccr.vlprepla
                    tt-dados_prp_ccr.vlsalari   tt-dados_prp_ccr.vlsalcon
                    tt-dados_prp_ccr.vloutras   tt-dados_prp_ccr.vllimcre
                    tt-dados_prp_ccr.vllimdeb   tt-dados_prp_ccr.vlalugue
                    tt-dados_prp_ccr.vltotemp   tt-dados_prp_ccr.vltotpre
                    tt-dados_prp_ccr.vlutiliz
                    WITH FRAME f_dados.


        END.
    ELSE
        DO:

            DISPLAY STREAM str_1
                    tt-dados_prp_ccr.nrdconta    tt-dados_prp_ccr.nrmatric
                    tt-dados_prp_ccr.nmresage    tt-dados_prp_ccr.nmprimtl
                    tt-dados_prp_ccr.dtadmiss    tt-dados_prp_ccr.nrcpfcgc
                    tt-dados_prp_ccr.dstipcta    tt-dados_prp_ccr.dssitdct
                    tt-dados_prp_ccr.vlsmdtri    tt-dados_prp_ccr.vlcaptal
                    tt-dados_prp_ccr.vlprepla    tt-dados_prp_ccr.vlaplica
                    tt-dados_prp_ccr.vllimcre    tt-dados_prp_ccr.vllimdeb
                    tt-dados_prp_ccr.vlrftmes    tt-dados_prp_ccr.vlrfttot
                    tt-dados_prp_ccr.vlutiliz    tt-dados_prp_ccr.vltotemp
                    tt-dados_prp_ccr.vltotpre
                    WITH FRAME f_dados_pj.

        END.


    IF   CAN-FIND(FIRST tt-outros_cartoes)   THEN
         DO:
             VIEW STREAM str_1 FRAME f_outros.
             DOWN STREAM str_1 WITH FRAME f_outros.

             FOR EACH tt-outros_cartoes:
                 DISPLAY STREAM str_1
                         tt-outros_cartoes.dsdnomes
                         tt-outros_cartoes.dstipcrd
                         tt-outros_cartoes.vllimite
                         tt-outros_cartoes.dssituac
                         WITH FRAME f_cartoes.

                 DOWN STREAM str_1 WITH FRAME f_cartoes.
             END.
         END.

    /* Preenche com asteriscos espacos em branco na Quebra de Pagina */
    IF   (LINE-COUNTER(str_1) + 28) > PAGE-SIZE(str_1)  THEN
         DO:
            /* preenche com asteriscos o final da pagina */
            aux_qtdlinha = PAGE-SIZE(str_1) - LINE-COUNTER(str_1).

            DO aux_contador  = 0 TO aux_qtdlinha - 1:

               rel_asterisc = FILL(" ",INT(80 / aux_qtdlinha) * aux_contador) +
                              "**".

               PUT STREAM str_1 rel_asterisc FORMAT "x(80)" SKIP.
    /*            PUT STREAM str_1 STRING(LINE-COUNTER(str_1)) FORMAT "x(80)" SKIP. */

               IF   LENGTH(rel_asterisc) >= 80              AND
                    LINE-COUNTER(str_1) < PAGE-SIZE(str_1)   THEN
                    ASSIGN aux_contador = 0.

               IF   LINE-COUNTER(str_1) >= PAGE-SIZE(str_1)  THEN
                    LEAVE.

            END.

            PAGE STREAM str_1.


            IF  crapass.inpessoa = 1   THEN
                DISPLAY STREAM str_1
                        tt-dados_prp_ccr.nmextcop tt-dados_prp_ccr.dsadicio
                        tt-dados_prp_ccr.nrctrcrd
                        WITH FRAME f_cooperativa.
            ELSE
                DISPLAY STREAM str_1
                        tt-dados_prp_ccr.nmextcop tt-dados_prp_ccr.dsadicio
                        tt-dados_prp_ccr.nrctrcrd
                        WITH FRAME f_cooperativa_pj.



         END. /* IF   (LINE-COUNTER(str_1) + 21 ) > PAGE-SIZE(str_1) */


    IF  crapass.inpessoa = 1   THEN
        DO:

            DISPLAY STREAM str_1
                tt-dados_prp_ccr.dddebito   tt-dados_prp_ccr.nrctamae
                tt-dados_prp_ccr.cdlimcrd   tt-dados_prp_ccr.vllimcrd
                tt-dados_prp_ccr.nmoperad   tt-dados_prp_ccr.nmrecop1
                tt-dados_prp_ccr.nmrecop2   tt-dados_prp_ccr.nmprimtl
                tt-dados_prp_ccr.nmcidade   tt-dados_prp_ccr.dsemsprp
                WITH FRAME f_final.

        END.
    ELSE
        DO:

            ASSIGN rel_dsemsprp = TRIM(tt-dados_prp_ccr.nmcidade) + " " + STRING(tt-dados_prp_ccr.cdufdcop,"!(2)") + ", " +
                                  TRIM(tt-dados_prp_ccr.dsemsprp) + ".".

            DISPLAY STREAM str_1
                    tt-dados_prp_ccr.nmoperad   tt-dados_prp_ccr.nmrecop1
                    tt-dados_prp_ccr.nmrecop2   tt-dados_prp_ccr.nmprimtl
                    rel_dsemsprp                tt-dados_prp_ccr.vllimcrd
                    aux_nmprimtl
                    WITH FRAME f_final_pj.

        END.

    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            DO WHILE TRUE:

                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.
            
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE.
                    END.
                
                RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                        INPUT aux_nmarqpdf).
    
                /** Copiar pdf para visualizacao no Ayllos WEB **/
                IF  SEARCH(aux_nmarqpdf) = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                              " a impressao.".
                        LEAVE.                      
                    END.
                            
                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                   '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                                   ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                                   '/temp/" 2>/dev/null').
   
                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.
    
            IF  aux_dscritic <> ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-erro  THEN
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                                                       
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

                    RETURN "NOK".
                END.

            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

        END.                                                                      
                                                      
    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

    RETURN "OK".

END PROCEDURE.

PROCEDURE gera_impressao_contrato_cartao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.       
    DEF  INPUT PARAM par_nrctrcrd AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_flgimp2v AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF   VAR h-b1wgen0024     AS HANDLE                            NO-UNDO.

    DEF   VAR aux_contador     AS INTE                              NO-UNDO.
    DEF   VAR aux_nmarqimp     AS CHAR                              NO-UNDO.
    DEF   VAR aux_nmarquiv     AS CHAR                              NO-UNDO.
    DEF   VAR aux_nmarqpdf     AS CHAR                              NO-UNDO.

    DEF    VAR aux_dsmesano       AS CHAR EXTENT 15 INIT
                                       ["de  Janeiro  de","de Fevereiro de",
                                        "de   Marco   de","de    Abril  de",
                                        "de    Maio   de","de    Junho  de",
                                        "de    Julho  de","de   Agosto  de",
                                        "de  Setembro de","de  Outubro  de",
                                        "de  Novembro de","de  Dezembro de"]
                                                                    NO-UNDO.


    DEF    VAR aux_dsrepre1       AS CHAR                           NO-UNDO.
    DEF    VAR aux_dsrepre2       AS CHAR                           NO-UNDO.
    DEF    VAR aux_nmprimtl       AS CHAR    FORMAT "x(40)"         NO-UNDO.

    DEF    VAR aux_dslinhax       AS CHAR                           NO-UNDO.
    DEF    VAR aux_dsstring       AS CHAR                           NO-UNDO.
    DEF    VAR rel_dslinha1       AS CHAR                           NO-UNDO.
    DEF    VAR rel_dslinha2       AS CHAR                           NO-UNDO.
    DEF    VAR rel_dslinha3       AS CHAR                           NO-UNDO.
    DEF    VAR rel_dslinha4       AS CHAR                           NO-UNDO.
    DEF    VAR rel_dslinha5       AS CHAR                           NO-UNDO.
    DEF    VAR rel_dslinha6       AS CHAR                           NO-UNDO.
    DEF    VAR rel_dslinha7       AS CHAR                           NO-UNDO.
    DEF    VAR rel_dslinha8       AS CHAR                           NO-UNDO. 
    DEF    VAR rel_dslinha9       AS CHAR                           NO-UNDO.
    DEF    VAR rel_dslinha10      AS CHAR                           NO-UNDO. 
    DEF    VAR rel_dslinha11      AS CHAR                           NO-UNDO.
    DEF    VAR rel_dslinha12      AS CHAR                           NO-UNDO.

    DEF    VAR rel_dsendere       AS CHAR                           NO-UNDO.
    DEF    VAR rel_nmcidend       AS CHAR                           NO-UNDO.
    DEF    VAR rel_dsemsctr       AS CHAR                           NO-UNDO.
    DEF    VAR rel_dfiador1       AS CHAR                           NO-UNDO.
    DEF    VAR rel_dfiador2       AS CHAR                           NO-UNDO.

    DEF    VAR aux_dstopico       AS CHAR                           NO-UNDO.
    DEF    VAR aux_nrtopico       AS INTE                           NO-UNDO.

    DEF    VAR h-b1wgen9999       AS HANDLE                         NO-UNDO.

FORM "\022\024\033\120"     /* Reseta impressora */
     SKIP
     "\0330\033x0\033\017"
     "\033\016 CONTRATO PARA UTILIZACAO CARTAO DE CREDITO" 
     tt-bdn_visa_cecred.nmcartao  NO-LABEL FORMAT "X(15)"
     "\022\024\033\120"     /* Reseta impressora */
     SKIP(1)
     "\033\105"
     tt-bdn_visa_cecred.dssubsti AT 27 NO-LABEL FORMAT "X(15)"
     "PROPOSTA:\033\106"         AT 53 
     "\033\016"
     tt-bdn_visa_cecred.nrctrcrd NO-LABEL
     "\022\024\033\120"     /* Reseta impressora */
     SKIP(3)
     "\0330\033x0\033\017"
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_titulo.

FORM "\033\1071) DAS PARTES:  "
     tt-bdn_visa_cecred.nmextcop FORMAT "x(50)"
     " - "
     tt-bdn_visa_cecred.nmrescop
     "\033\110,   sociedade   cooperativa   de   credito,    de"
     SKIP
     "responsabilidade limitada, regida pela legislacao vigente, normas"
     "baixadas pelo  Conselho  Monetario  Nacional,  pela  regulamentacao"
     SKIP
     "estabelecida pelo Banco Central do Brasil e pelo seu estatuto social,"
     "arquivado na Junta  Comercial  do  Estado  de  Santa  Catarina,"
     SKIP
     "inscrita    no   "
     tt-bdn_visa_cecred.nrdocnpj FORMAT "X(23)"
     " ,  estabelecida    a"
     tt-bdn_visa_cecred.dsendcop
     " ,  n. "
     tt-bdn_visa_cecred.nrendcop
     " ,  bairro"
     SKIP
     tt-bdn_visa_cecred.nmbairro
     " ,"
     tt-bdn_visa_cecred.nmcidade  FORMAT "x(23)"
     ","
     tt-bdn_visa_cecred.cdufdcop
     " filiada a \033\107COOPERATIVA  CENTRAL  DE  CREDITO  URBANO -"
     "CECRED\033\110, Cooperativa Central de"
     SKIP
     "Credito, de  responsabilidade  limitada, inscrita  no  CNPJ/MF sob o n."
     " 05.463.212/0001-29,  estabelecida  na  Rua  Frei  Estanislau"
     SKIP
     "Schaette, n. 1201, bairro Agua Verde, na cidade de Blumenau, Estado de"
     "Santa Catarina."
     SKIP
     "\033\107COOPERADO(A):\033\110"
     tt-bdn_visa_cecred.nmprimtl FORMAT "x(40)"
     ", CPF/CNPJ " 
     tt-bdn_visa_cecred.nrcpfcgc FORMAT "X(18)"
     ", Conta-corrente:"
     tt-bdn_visa_cecred.nrdconta
     "."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_1.

FORM "\033\1072) DO OBJETO:\033\110 O presente contrato tem por objeto"
     "regular as condicoes para intermediacao de prestacao de  servicos "
     "de  administracao"
     SKIP
     "de cartoes de credito e seus desdobramentos ente a"
     "\033\107COOPERATIVA\033\110, o(a) \033\107COOPERADO(A)\033\110 e as"
     "empresas \033\107BRADESCO ADMINISTRADORA DE CARTOES DE"
     SKIP
     "CREDITO LTDA.\033\110, CNPJ/MF n. 43.199.330/0001-60 e \033\107BANCO"
     "BRADESCO S.A., \033\110CNPJ/MF n. 60.746.948/0001-12, doravante"
     "denominadas comumente de"
     SKIP
     "\033\107BRADESCO\033\110, autorizada a operar com os cartoes de"
     "credito da bandeira \033\107VISA\033\110."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_2.

FORM "\033\1073) DO CONTRATO DE INTERMEDIACAO:\033\110 A \033\107COOPERATIVA"
     "\033\110, na condicao de intermediaria, para o fornecimento do Cartao"
     "de  Credito  do  Sistema"
     SKIP
     "VISA, tipo CECRED - EMPRESARIAL a seus associados, subscreveu o"
     "contrato/regulamento de  adesao  ao  sistema  de  cartao  de  credito"
     SKIP
     "oferecido pelo BRADESCO, de acordo com o instrumento registrado no 1o"
     "Cartorio de Registro de Titulos e Documentos de Osasco,  Estado"
     SKIP
     "de Sao Paulo sob n. 64.053, no livro 'A', funcionando naquele"
     "contrato/regulamento como \033\107"
     tt-bdn_visa_cecred.dsvincul FORMAT "X(20)"
     "\033\110"
     SKIP(1)
     "\033\107Paragrafo unico: O(a) COOPERADO(A),\033\110 na condicao de"
     "usuario do cartao de  credito,  pelo  presente  instrumento,  declara "
     "conhecer  o"
     SKIP
     "contrato/regulamento  referido  no  \033\064caput\033\065,  aderindo  e "
     "aceitando  as  condicoes,  as  quais  se   sujeita,   funcionando"
     "   naquele"
     SKIP
     "contrato/regulamento como BENEFICIARIO, assim como, recebe neste ato"
     "uma copia do Regulamento da Utilizacao dos  Cartoes  de  Credito"
     SKIP
     "Bradesco Empresariais, fazendo estes parte integrante do presente"
     "instrumento."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_3.
   
FORM "\033\1074) DA SUB-ROGACAO DE DIREITOS:\033\110"
     "A \033\107COOPERATIVA\033\110 ficara sub-rogada em todos os direitos do"
     "BRADESCO, perante o(a)  \033\107COOPERADO(A)\033\110,  usuario"
     SKIP
     "do cartao, sempre que liquidar as faturas mensais, e ate a liquidacao"
     "total do debito deste perante a mesma."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_4.
    
FORM "\033\1075) DOS PROBLEMAS COM O CARTAO:\033\110 O relacionamento do(a)"
     "\033\107COOPERADO(A)\033\110, para comunicacao de danificacao, perda,"
     "roubo, furto,  fraude  ou"
     SKIP
     "falsificacao de cartao e outras, sera diretamente com o"
     "BRADESCO, podendo eventualmente a \033\107COOPERATIVA\033\110 servir de"
     "intermediaria."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_5.

FORM "\033\1076) DA REMUNERACAO DOS SERVICOS:\033\110 A remuneracao pelos"
     "servicos disponibilizados sera de inteira  responsabilidade  do(a) "
     "\033\107COOPERADO(A)\033\110,"
     SKIP
     "cabendo a \033\107COOPERATIVA\033\110 debita-la na conta corrente do"
     "mesmo."
     SKIP(1)
     "\033\107Paragrafo unico:\033\110 A \033\107COOPERATIVA\033\110 podera"
     "repassar, alem da remuneracao dos servicos cobrados pelo BRADESCO, uma"
     "remuneracao  pelos  seus"
     SKIP
     "servicos de intermediacao, que tambem sera debitada na conta do(a)"
     "\033\107COOPERADO(A)\033\110."     
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_6.

FORM "\033\1077) DO DEBITO DAS FATURAS:\033\110 O(a)"
     "\033\107COOPERADO(A)\033\110 e o(s) \033\107FIADOR(ES)\033\110,"
     "desde logo, em carater  irrevogavel  e  irretratavel,  para  todos  os"
     SKIP
     "efeitos legais e contratuais, autoriza(m) desde ja, o debito do valor"
     "da fatura mensal oriunda da  utilizacao  do  cartao,  e  demais"
     SKIP
     "despesas ou encargos, inclusive anuidades, na data do seu vencimento,"
     "em sua(s) conta(s) corrente(s)  mantida  junto  a "
     "\033\107COOPERATIVA\033\110,"
     SKIP
     "podendo esta utilizar o saldo credor de qualquer conta em nome dos"
     "mesmos, aplicacao financeira e  creditos  de  seus  titulares,  em"
     SKIP
     "qualquer das unidades da mesma, efetuando o bloqueio dos valores, ate o"
     "limite  necessario  para  a  liquidacao  ou  amortizacao  das"
     SKIP
     "obrigacoes assumidas e vencidas no presente contrato, obrigando-se ainda"
     "o(a) \033\107COOPERADO(A)\033\110 e o(s)  \033\107FIADOR(ES)\033\110, "
     "a  sempre  manter(em)"
     SKIP
     "saldo em sua(s) conta(s)-corrente(s) para a realizacao dos referidos"
     "debitos."
     SKIP(1)
     "\033\107Paragrafo unico:\033\110 O(a) \033\107COOPERADO(A)\033\110"
     "podera efetuar saques na rede de caixas eletronicos BDN e Banco 24"
     "Horas, sendo que tais saques  e"
     SKIP
     "respectivas tarifas serao imediatamente debitados de sua conta corrente"
     "junto a \033\107COOPERATIVA\033\110."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_7.

FORM "\033\1078) DO LIMITE DE CREDITO:\033\110 Cabe a"
     "\033\107COOPERATIVA\033\110, a seu criterio, estabelecer o limite de"
     "credito do(a) \033\107COOPERADO(A)\033\110, podendo ajusta-lo ou"
     SKIP
     "ate cancela-lo integralmente, de acordo com suas condicoes gerais de"
     "credito do mesmo perante esta, podendo ainda,  reduzi-lo,  se  o"
     SKIP
     "saldo devedor da fatura mensal nao for liquidado pelo(a)"
     "\033\107COOPERADO(A)\033\110."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_8.

FORM "\033\1079) DO FORNECIMENTO DE EXTRATOS:\033\110 A"
     "\033\107COOPERATIVA\033\110, na condicao de intermediaria nao tera "
     "qualquer  controle  de  administracao  sobre  o"
     SKIP
     "cartao de creditos, sendo que, inclusive os extratos mensais de"
     "utilizacao das contas sera de responsabilidade exclusiva do BRADESCO."
     SKIP(1)
     "\033\107Paragrafo unico:\033\110 A \033\107COOPERATIVA\033\110 podera"
     "remeter ao(a) \033\107COOPERADO(A)\033\110, juntamente com  o  aviso "
     "de  debito  em  conta  corrente,  toda  a"
     SKIP
     "documentacao, extratos e demonstrativos remetidos pelo BRADESCO."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_9.

FORM "\033\10710) DO RECEBIMENTO DO CARTAO:\033\110 O(a)"
     "\033\107COOPERADO(A)\033\110 declara receber o  cartao  de  credito  n. "
     tt-bdn_visa_cecred.nrcrcard
     ",  conforme  proposta"
     SKIP
     tt-bdn_visa_cecred.nrctrcrd
     ", em nome do titular do cartao,"
     tt-bdn_visa_cecred.nmtitcrd
     "."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_10.
     
FORM "\033\10711) DAS GARANTIAS - DA FIANCA:\033\110 Para garantir o"
     "cumprimento das obrigacoes assumidas no presente contrato, comparecem,"
     "igualmente,  na"
     SKIP
     "condicao de \033\107FIADOR(ES)\033\110, a(s) pessoa(s) e"
     "seu(s) conjuge(s) nominado(s), o(s) qual(is) expressamente declara(m)"
     "que responsabiliza(m)-"
     SKIP
     "se, solidariamente, como principal(is) pagador(es), pelo cumprimento de"
     "todas as  obrigacoes  assumidas  pelo(a)  \033\107COOPERADO(A)\033\110 "
     "neste"
     SKIP
     "contrato, renunciando, expressamente, os beneficios de ordem que"
     "trata o art. 827, em conformidade com o art. 828, incisos I e II,  e"
     SKIP
     "art. 838, do Codigo Civil Brasileiro (Lei n. 10.406, de 10/01/2002)."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_11.
     
     
FORM "\033\10712) DA GARANTIA ADICIONAL - DAS NOTAS  PROMISSORIAS:\033\110"
     " Como  garantia  adicional,  o(a)  \033\107COOPERADO(A)\033\110 "
     "emite  Nota(s)  Promissoria(s),"
     SKIP
     "vinculada(s) ao Contrato, no valor total do Emprestimo/Financiamento,"
     "inerente(s) a(s) parcela(s)  nele  estabelecida(s),  igualmente"
     SKIP
     "subscrita pelo(s) \033\107FIADOR(ES)\033\110,"
     "a(s) qual(is) passa(m) a ser parte integrante do presente."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_12.
     
     
FORM "\033\10713) DA EXIGIBILIDADE:\033\110 O presente instrumento reverte-se"
     "da condicao de titulo executivo extrajudicial,  nos  termos  do"
     "Art.  585  do"
     "C.P.C., reconhecendo as partes, desde ja, a sua liquidez, certeza e"
     "exigibilidade."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_13.
     
FORM "\033\10714) DO PRAZO DE VIGENCIA E DAS CONDICOES ESPECIAIS DE"
     "VENCIMENTO:\033\110 O presente contrato vigorara por prazo"
     "indeterminado, sendo  que  a"
     SKIP
     "falta ou insuficiencia de fundos na(s) conta(s)-corrente(s),"
     "impossibilitando o pagamento e liquidacao no  vencimento,  de  quaisquer"
     SKIP
     "das faturas do cartao de credito, independentemente de qualquer"
     "notificacao judicial ou extrajudicial, podera determinar, a  criterio"
     SKIP
     "da \033\107COOPERATIVA\033\110, o vencimento antecipado do presente"
     "contrato, com a cobranca de forma amigavel e/ou judicial dos  valores"
     " estornados"
     SKIP
     "da conta-corrente, mantendo este contrato as suas caracteristicas de"
     "liquidez, certeza e exigibilidade."
     SKIP(1)
     "\033\107Paragrafo unico:\033\110 Sobre o montante da quantia devida e"
     "nao paga, incidirao, alem da correcao monetaria, com base no  INPC/IBGE,"
     " juros"
     SKIP
     "moratorios e compensatorios a base do que preceitua o atr. 406, do"
     "Codigo Civil Brasileiro (Lei n."
     "10.406,  de  10/01/2002),  ao  mes"
     SKIP
     "vigente entre a data da mora ate a data do efetivo pagamento, multa"
     "contratual de 2% (dois por cento), sobre o  montante  apurado,  e"
     SKIP
     "impostos que incidam ou venham a incidir sobre  a  operacao  contratada,"
     " devendo  o(a)  \033\107COOPERADO(A)\033\110  e  seus"
     " \033\107Coobrigados\033\110,  efetuar"
     SKIP
     "imediatamente o pagamento do montante do debito apurado, sob pena de"
     "serem demandados judicialmente."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_14.
     
FORM "\033\10715) DOS EFEITOS DO CONTRATO:\033\110 Este contrato obriga a"
     "\033\107COOPERATIVA\033\110, o(a) \033\107COOPERADO(A)\033\110,  e  o(s)"
     " \033\107FIADOR(ES)\033\110,  ao  fiel  cumprimento  das"
     SKIP
     "clausulas e condicoes estabelecidas no mesmo, sendo  celebrado  em"
     " carater  irrevogavel  e  irretratavel,  obrigando,  tambem,  seus"
     SKIP
     "herdeiros, cessionarios e sucessores, a qualquer titulo."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_15.
     
FORM "\033\10716) DO FORO:\033\110 As partes, de comum acordo, elegem o foro"
     "da Comarca do domicilio do(a) \033\107COOPERADO(A)\033\110, com exclusao"
     " de  qualquer  outro,"
     SKIP
     "por mais privilegiado que seja, para dirimir quaisquer questoes"
     "resultantes do presente contrato."
     SKIP
     "E assim, por se acharem justos e contratados, assinam o presente"
     "contrato, em 02 (duas) vias de igual teor e forma,  na  presenca  de"
     SKIP
     "duas testemunhas abaixo, que, estando cientes, tambem assinam, para que"
     "produza os devidos e legais efeitos."
     SKIP(1)
     tt-bdn_visa_cecred.nmcidade
     tt-bdn_visa_cecred.cdufdcop
     tt-bdn_visa_cecred.dsemsctr FORMAT "X(25)"
     "."
     SKIP(3)
     "__________________________________________________"
     "__________________________________________________"       AT 80
     SKIP
     tt-bdn_visa_cecred.nmprimtl
     tt-bdn_visa_cecred.nmextcop                                AT 85
     SKIP(3)
     "__________________________________________________"
     "__________________________________________________"       AT 80
     SKIP(1)
     "Fiador 1: ________________________________________"       
     "Conjuge Fiador 1: ________________________________"       AT 80
     SKIP(1)
     "CPF: _________________________"
     "CPF: _________________________"                           AT 80
     SKIP(3)
     "__________________________________________________"
     "__________________________________________________"       AT 80
     SKIP(1)
     "Fiador 2: ________________________________________"
     "Conjuge Fiador 2: ________________________________"       AT 80
     SKIP(1)
     "CPF: _________________________"
     "CPF: _________________________"                           AT 80
     SKIP(3)
     "__________________________________________________"
     "__________________________________________________"       AT 80
     SKIP(1)
     "Testemunha 1: ____________________________________"
     "Testemunha 2: ____________________________________"       AT 80
     SKIP(1)
     "CPF/MF: _________________________"
     "CPF/MF: _________________________"                        AT 80
     SKIP(1)
     "CI: _____________________________"
     "CI: _____________________________"                        AT 80
     SKIP(3)
     "__________________________________________________"       AT 80
     SKIP
     "Operador:"                                                AT 80
     tt-bdn_visa_cecred.nmoperad FORMAT "X(25)"
     SKIP(1)
     WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 150 NO-ATTR-SPACE FRAME f_topico_16.
     
/* forms pessoa juridica */

FORM "\022\024\033\120"     /* Reseta impressora */
     SKIP
     "\0330\033x0\033\017"
     "\033\016 CONTRATO PARA UTILIZACAO CARTAO DE CREDITO" 
     tt-bdn_visa_cecred.nmcartao  NO-LABEL FORMAT "X(15)"
     "\022\024\033\120"     /* Reseta impressora */
     SKIP(1)
     "\033\105"
     tt-bdn_visa_cecred.dssubsti AT 27 NO-LABEL FORMAT "X(15)"
     "PROPOSTA:\033\106"         AT 53 
     "\033\016"
     tt-bdn_visa_cecred.nrctrcrd NO-LABEL
     "\022\024\033\120"     /* Reseta impressora */
     SKIP(3)
     "\0330\033x0\033\017"
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_titulo_pj.

FORM "I - DAS CONDICOES ESPECIAIS:  "
     SKIP
     "\033\1071.  DA IDENTIFICACAO:\033\110"
     SKIP
     rel_dslinha1 FORMAT "x(154)"
     SKIP
     rel_dslinha2 FORMAT "x(154)"
     SKIP
     rel_dslinha3 FORMAT "x(154)"
     SKIP
     rel_dslinha5 FORMAT "x(154)"
     SKIP
     rel_dslinha6 FORMAT "x(154)"
     SKIP
     rel_dslinha7 FORMAT "x(154)"
     SKIP
     rel_dslinha8 FORMAT "x(154)"
     SKIP(1)
     rel_dslinha9 FORMAT "x(154)"
     SKIP
     rel_dslinha10 FORMAT "x(154)"
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 154 NO-LABELS NO-BOX FRAME f_topico_1_pj.

FORM "\033\1072. DO LIMITE GLOBAL DE CREDITO:\033\110"
     SKIP
     "2.1. Valor: " tt-bdn_visa_cecred.vllimglb FORMAT "zzz,zzz,zz9.99" tt-bdn_visa_cecred.dsvllim1  FORMAT "x(105)"
     SKIP
     tt-bdn_visa_cecred.dsvllim2 FORMAT "x(133)"
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_2_pj.

FORM "\033\1073. DOS ENCARGOS FINANCEIROS:\033\110"
     SKIP
     "3.1. Indice de Atualizacao Monetaria: \033\107T.R. (Taxa Referencial de Juros);\033\110"
     SKIP
     "3.2. Juros Remuneratorios: \033\10726,82% (vinte e seis virgula oitenta e dois por cento)\033\110 ao ano (2,00% a.m., capitalizados mensalmente);"
     SKIP
     "3.3. Juros Moratorios: 12,00% (doze por cento) ao ano."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_3_pj.

FORM "\033\1074. DO PAGAMENTO DAS FATURAS MENSAIS:\033\110"
     SKIP
     "4.1. Forma de pagamento: debito na c/c n. " tt-bdn_visa_cecred.nrdconta FORMAT "zzzz,zzz,9" ";"
     SKIP
     "4.2. Data do Debito: De acordo com os vencimentos constantes das Propostas de Emissao de Cartao de Credito dos usuarios vinculados ao"
     SKIP
     "presente contrato."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_4_pj. 

FORM "\033\1075. DO PRAZO DO CONTRATO:\033\110"
     SKIP
     "5.1. Prazo de 24 meses."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_5_pj.

FORM "\033\1076. DO(S) REPRESENTANTE(S): \033\110"
     SKIP
     "6.1. "  tt-bdn_visa_cecred.dsrepre1 FORMAT "x(140)"
     SKIP
              tt-bdn_visa_cecred.dsrepre2 FORMAT "x(140)"
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_6_pj.

FORM "\033\1077. DOS FIADORES \033\110"
     SKIP
     rel_dfiador1 FORMAT "x(90)"
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_7_1_pj.

FORM "\033\1077. DOS FIADORES \033\110"
     SKIP
     rel_dfiador1 FORMAT "x(90)"
     SKIP
     rel_dfiador2 FORMAT "x(90)"
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_7_2_pj.

FORM "II - DAS CONDICOES ESPECIAIS:"
     SKIP
     rel_dslinha1 FORMAT "x(180)"
     SKIP
     rel_dslinha2 FORMAT "x(180)"
     SKIP
     rel_dslinha3 FORMAT "x(180)"
     SKIP
     rel_dslinha4 FORMAT "x(180)"
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 180 NO-LABELS NO-BOX FRAME f_topico_8_pj.

FORM aux_dstopico FORMAT "x(202)"
     SKIP
     "cartoes de credito e seus desdobramentos entre a \033\107Cooperativa\033\110, a \033\107Cooperada\033\110 e as empresas \033\107BRADESCO ADMINISTRADORA DE CARTOES DE CREDITO"
     SKIP
     "LTDA.\033\110,  CNPJ/MF  n.   43.199.330/0001-60  e  \033\107BANCO BRADESCO S.A.\033\110,  CNPJ/MF  n. 60.746.948/0001-12, doravante denominadas comumente de"
     SKIP
     "\033\107ADMINISTRADORA DE CARTOES\033\110, autorizada a operar com os cartoes de credito da bandeira \033\107VISA.\033\110"
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 202 NO-LABELS NO-BOX FRAME f_topico_9_pj.

FORM aux_dstopico FORMAT "x(182)"
     SKIP
     "VISA,  tipo  CECRED  -  EMPRESARIAL  a  seus  associados, subscreveu o contrato/regulamento de adesao ao sistema de cartao de credito"
     SKIP
     "oferecido  pelo  BRADESCO, de acordo com o instrumento registrado no primeiro Cartorio de Registro de Titulos e Documentos de Osasco,"
     SKIP
     'Estado de Sao Paulo sob n. 64.053 no livro "A", funcionando naquele contrato/regulamento como \033\107Cooperativa Filiada\033\110.'
     SKIP(1)
     "\033\107Paragrafo unico.\033\110  A  \033\107Cooperada\033\110, na pessoa de seus usuarios do cartao de credito, pelo presente instrumento, declara estar ciente e de"
     SKIP
     "pleno acordo com as disposicoes contidas no Regulamento da Utilizacao dos Cartoes de Credito Bradesco Empresariais referido no caput,"
     SKIP
     "aderindo  e  aceitando  suas  condicoes, as quais se sujeita, funcionando naquele contrato/regulamento como BENEFICIARIA, assim como,"
     SKIP
     "recebe neste ato uma copia, fazendo este parte integrante do presente instrumento."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 182 NO-LABELS NO-BOX FRAME f_topico_10_pj.

FORM aux_dstopico FORMAT "x(220)"
     SKIP
     "\033\107Cooperada\033\110,  pelo  uso  do(s)  cartao(oes), sempre que liquidar as faturas mensais, e ate a liquidacao total do debito deste perante a"
     SKIP
     "mesma."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 220 NO-LABELS NO-BOX FRAME f_topico_11_pj.

FORM aux_dstopico FORMAT "x(182)"
     SKIP
     "falsificacao  de  cartao  e  outras,  sera diretamente com a \033\107ADMINISTRADORA DE CARTOES\033\110, podendo eventualmente a \033\107Cooperativa\033\110 servir de"
     SKIP
     "intermediaria."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 182 NO-LABELS NO-BOX FRAME f_topico_12_pj.

FORM aux_dstopico FORMAT "x(201)"
     SKIP
     "vigente  a  epoca,  cujo valor constara no quadro de tarifas da \033\107Cooperativa\033\110, sera de inteira responsabilidade da \033\107Cooperada\033\110, cabendo a"
     SKIP
     "\033\107Cooperativa\033\110 debita-la na conta corrente da mesma."
     SKIP(1)
     "\033\107Paragrafo unico.\033\110 A  \033\107Cooperativa\033\110  podera  repassar,  alem  da  remuneracao  dos  servicos cobrados pela \033\107ADMINISTRADORA DE CARTOES\033\110, uma"
     SKIP
     "remuneracao pelos seus servicos de intermediacao, que tambem sera debitada na conta da \033\107Cooperada.\033\110"
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 201 NO-LABELS NO-BOX FRAME f_topico_13_pj.

FORM aux_dstopico FORMAT "x(184)"
     SKIP
     "sendo  que  a  \033\107Cooperada\033\110  e  o(s)  \033\107FIADOR(ES)\033\110,  em  carater  irrevogavel  e irretratavel, para todos os efeitos legais e contratuais,"
     SKIP
     "autoriza(m),  desde ja, o debito do valor da fatura mensal, individualizada e nominal por usuario, oriunda das despesas de utilizacao"
     SKIP
     "do  cartao, conforme valor apresentado no demonstrativo  mensal,  e  demais despesas ou encargos, inclusive anuidades, na data do seu"
     SKIP
     "vencimento,  em  sua(s)  conta(s)  corrente(s) mantida junto a \033\107Cooperativa\033\110, podendo esta utilizar o saldo credor de qualquer conta em"
     SKIP
     "nome  dos  mesmos,  aplicacao  financeira  e  creditos de seus titulares, em qualquer das unidades da mesma, efetuando o bloqueio dos"
     SKIP
     "valores,  ate  o  limite  necessario  para  a  liquidacao  ou  amortizacao  das obrigacoes assumidas e vencidas no presente contrato,"
     SKIP
     "obrigando-se  ainda  a  \033\107Cooperada\033\110  e  o(s) \033\107FIADOR(ES)\033\110, a sempre manter(em) saldo em sua(s) conta(s)-corrente(s) para a realizacao dos"
     SKIP
     "referidos debitos."
     SKIP(1)
     "\033\107Paragrafo unico.\033\110  A  \033\107Cooperada\033\110  podera  efetuar  saques  na  rede de caixas eletronicos BDN e Banco 24 Horas, sendo que tais saques e"
     SKIP
     "respectivas tarifas serao imediatamente debitados de sua conta corrente junto a \033\107Cooperativa.\033\110"
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 184 NO-LABELS NO-BOX FRAME f_topico_14_pj.

FORM aux_dstopico FORMAT "x(197)"
     SKIP
     "cancela-lo  integralmente, de acordo com suas condicoes gerais de credito do mesmo perante esta, podendo ainda, reduzi-lo, se o saldo"
     SKIP
     "devedor da fatura mensal nao for liquidado pela \033\107Cooperada.\033\110"
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 197 NO-LABELS NO-BOX FRAME f_topico_15_pj.

FORM aux_dstopico FORMAT "x(197)"
     SKIP
     "cartao  de  credito,  sendo  que,  inclusive,  os  extratos  mensais  de utilizacao das contas sera de responsabilidade exclusiva da"
     SKIP
     "\033\107ADMINISTRADORA DE CARTOES.\033\110"
     SKIP(1)
     "\033\107Paragrafo unico:\033\110  A \033\107Cooperativa\033\110  podera remeter a \033\107Cooperada\033\110, juntamente com o aviso de debito em conta corrente, toda a documentacao,"
     SKIP
     "extratos e demonstrativos remetidos pela \033\107ADMINISTRADORA DE CARTOES.\033\110"
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 197 NO-LABELS NO-BOX FRAME f_topico_16_pj.

FORM aux_dstopico FORMAT "x(222)"
     SKIP
     "receberao os \033\107CARTOES\033\110, por  intermedio  de  relacao  nominal mediante entrega de Proposta para Emissao de Cartao de Credito, subscrita"
     SKIP
     "pela pessoa devidamente autorizada pela \033\107Cooperada\033\110, doravante denominado simplesmente \033\107REPRESENTANTE\033\110."
     SKIP(1) 
     "\033\107Paragrafo primeiro\033\110. A  \033\107Cooperada\033\110  podera  indicar  o  limite de utilizacao do \033\107CARTAO\033\110, dentro do valor maximo do limite atribuido pela"
     SKIP
     "\033\107Cooperativa\033\110 a \033\107Cooperada\033\110, observada as condicoes descritas no Anexo I sobre limite do \033\107CARTAO\033\110;"
     SKIP(1)
     "\033\107Paragrafo segundo\033\110. A  \033\107Cooperativa\033\110  podera,  a  qualquer  momento,  alterar  o  limite  do  \033\107CARTAO\033\110 dos usuarios mediante comunicacao a"
     SKIP
     "\033\107Cooperada\033\110;"
     SKIP(1)
     "\033\107Paragrafo terceiro\033\110. A  \033\107Cooperada\033\110  compromete-se  sem  qualquer  onus  para  a \033\107Cooperativa\033\110, a prestar as informacoes e esclarecimentos"
     SKIP
     "necessarios  aos  usuarios dos \033\107CARTOES\033\110 vinculados ao presente Contrato, inclusive a sujeicao ao Regulamento da Utilizacao dos Cartoes"
     SKIP
     "de Credito Empresariais da \033\107ADMINISTRADORA DE CARTOES\033\110;"
     SKIP(1)
     "\033\107Paragrafo quarto\033\110. A  \033\107Cooperada\033\110 compromete-se em comunicar a \033\107Cooperativa\033\110, pedido(s) de bloqueio de determinado(s) usuario(s) do \033\107CARTAO\033\110"
     SKIP
     "pelas razoes que achar pertinentes a tal procedimento;"
     SKIP(1)
     "\033\107Paragrafo quinto\033\110. A  \033\107Cooperativa\033\110  cancelara imediatamente o \033\107CARTAO\033\110, assim que receber o pedido de bloqueio da \033\107Cooperada\033\110, sem prejuizo"
     SKIP
     "da liquidacao das operacoes realizadas ate o momento do recebimento da comunicacao enviada pela \033\107Cooperada\033\110."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 222 NO-LABELS NO-BOX FRAME f_topico_17_pj.

FORM aux_dstopico FORMAT "x(182)"
     SKIP
     "do(s) Cartao(oes), desistir da adesao, manifestando-se por escrito e restituindo o(s) Cartao(oes) devidamente inutilizado(s)."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 182 NO-LABELS NO-BOX FRAME f_topico_18_pj.

FORM aux_dstopico FORMAT "x(182)"
     SKIP(1)
     "a) promover  seus melhores esfor‡os junto aos usuarios beneficiados com o \033\107CARTAO EMPRESARIAL\033\110, no sentido de controlar e disciplinar a"
     SKIP
     "utilizacao e os cuidados quanto a seguran‡a no uso do \033\107CARTAO\033\110;"
     SKIP(1)
     "b) indicar  formalmente  outro  \033\107REPRESENTANTE\033\110,  em  caso  de  necessidade de substituicao do(s) nome(s) indicado(s) no item 6.1., das"
     SKIP
     "CONDICOES  ESPECIAIS,  na  qualidade  de  preposto,  para  tratar  de assuntos relacionados com o presente contrato, em especial para"
     SKIP
     "solicitar, cancelar e receber o \033\107CARTAO\033\110;"
     SKIP(1)
     "c) informar  de  imediato  a \033\107Cooperativa\033\110 e/ou a \033\107ADMINISTRADORA DE CARTOES\033\110, utilizando-se da Central de Atendimento aos Clientes desta"
     SKIP
     "ultima,  disponivel dia e noite, diretamente pelo usuario do \033\107CARTAO\033\110 ou por intermedio de seu \033\107REPRESENTANTE\033\110, a ocorrencia de extravio,"
     SKIP
     "roubo, furto, defeito, dano ou duplicacao de qualquer \033\107CARTAO\033\110;"
     SKIP(1)
     "d) exigir  que  o  ex-usuario  se  comprometa  a entregar o \033\107CARTAO\033\110 ao \033\107REPRESENTANTE\033\110, devidamente inutilizado, para que este proceda a"
     SKIP
     "devolucao a \033\107Cooperativa\033\110;"
     SKIP(1)
     'e) submeter-se  as  regras  estabelecidas  no  "Regulamento  de  Utilizacao dos Cartoes de Credito Empresariais" da \033\107ADMINISTRADORA DE'
     SKIP
     "CARTOES, ANEXO I.\033\110"
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 182 NO-LABELS NO-BOX FRAME f_topico_19_pj.

FORM aux_dstopico FORMAT "x(172)"
     SKIP
     "entregues  ao  \033\107REPRESENTANTE\033\110  da  \033\107Cooperada\033\110,  mediante  contra  recibo,  ficando  ao  encargo  desta entregar os \033\107CARTOES\033\110 aos usuarios"
     skip
     "beneficiarios."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 172 NO-LABELS NO-BOX FRAME f_topico_20_pj.

FORM aux_dstopico FORMAT "x(166)"
    SKIP
    "condicao  de  \033\107FIADOR(ES)\033\110,  a(s) pessoa(s) e seus conjuges nominado(s) no item 7, das CONDICOES ESPECIAIS, o(s) qual(is) expressamente"
    SKIP
    "declara(m)  que  responsabiliza(m)-se,  solidariamente,  como  principal(is)  pagador(es),  pelo  cumprimento  de todas as obrigacoes"
    SKIP
    "assumidas pela \033\107Cooperada\033\110 neste contrato, renunciando, expressamente, os beneficios de ordem que trata o art. 827, em conformidade com"
    SKIP
    "o art. 828, incisos I e II, e art. 838, do Codigo Civil Brasileiro (Lei n. 10.406, de 10/01/2002)."
    SKIP(1)
    WITH COLUMN 5 NO-ATTR-SPACE WIDTH 166 NO-LABELS NO-BOX FRAME f_topico_21_pj.

FORM aux_dstopico FORMAT "x(182)"
     SKIP
     "ao Contrato, no valor total do Limite Global de Credito contratados, inerente aos valores que possam ser utilizados nas operacoes com"
     SKIP
     "o Cartao de Credito Empresarial, igualmente subscrita pelo(s) \033\107FIADOR(ES)\033\110, a(s) qual(is) passa(m) a ser parte integrante do presente."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 182 NO-LABELS NO-BOX FRAME f_topico_22_pj.

FORM aux_dstopico FORMAT "x(200)"
    SKIP
    "o  montante  dos  debitos  e  coobrigacoes, prestadas pelas instituicoes financeiras, registradas em nome desta, junto ao cadastro do"
    SKIP
    "Sistema  de  Informacoes  de Credito - SCR do Banco Central do Brasil, assim como, consultar e compartilhar informacoes cadastrais da"
    SKIP
    "\033\107Cooperada\033\110 com outras Cooperativas de Credito, instituicoes financeiras ou assemelhadas, bem como, junto aos demais orgaos de protecao"
    SKIP
    "ao credito, na forma da legislacao vigente."
    SKIP(1)
    WITH COLUMN 5 NO-ATTR-SPACE WIDTH 200 NO-LABELS NO-BOX FRAME f_topico_23_pj.

FORM aux_dstopico FORMAT "x(166)"
     SKIP
     "C.P.C., reconhecendo as partes, desde ja, a sua liquidez, certeza e exigibilidade."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 166 NO-LABELS NO-BOX FRAME f_topico_24_pj.

FORM aux_dstopico FORMAT "x(166)"
     SKIP
     "contar  da  data  da  assinatura, podendo, entretanto, ser prorrogado automaticamente por periodos iguais e sucessivos, desde que nao"
     SKIP
     "haja manifestacao ao contrario das partes."
     SKIP(1)
     "\033\107Paragrafo primeiro\033\110. O  presente  contrato podera ser resilido a qualquer tempo por qualquer das partes, sem direito a compensacoes ou"
     SKIP
     "indenizacoes,  mediante  denuncia  escrita  com ate 30 (trinta) dias de antecedencia contados do recebimento do comunicado pela outra"
     SKIP
     "Parte."
     SKIP(1)
     "\033\107Paragrafo segundo\033\110. No  caso do termino deste contrato, ou ainda no caso da sua rescisao, por qualquer motivo, a \033\107Cooperada\033\110 obriga-se a"
     SKIP
     "pagar todas  as despesas faturadas, desde que realizadas regularmente por intermedio dos \033\107CARTOES\033\110."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 166 NO-LABELS NO-BOX FRAME f_topico_25_pj.

FORM aux_dstopico FORMAT "x(182)"
     SKIP
     "qualquer aviso, nas seguintes hipoteses:"
     SKIP(1)
     "a) se  quaisquer  das  Partes  falir,  requerer recuperacao judicial ou iniciar procedimentos de recuperacao extrajudicial, tiver sua"
     SKIP
     "falencia ou liquidacao requerida;"
     SKIP(1)
     "b) se a \033\107Cooperada\033\110 tiver cassada sua autorizacao para funcionamento;"
     SKIP(1)
     "c) se  a  \033\107Cooperada\033\110  nao  mantiver  recursos  financeiros  suficientes  na(s)  conta(s)-correntes(s),  impossibilitando o pagamento e"
     SKIP
     "liquidacao no vencimento, de quaisquer das faturas do cartao de credito."
     SKIP(1)
     "\033\107Paragrafo primeiro\033\110. A  ocorrencia  de  quaisquer  das  hipoteses  apresentadas,  ou  ainda,  a infracao de quaisquer das clausulas ou"
     SKIP
     "condicoes  aqui estipuladas, podera ensejar imediata rescisao/resilicao deste Contrato, por simples notificacao escrita com indicacao"
     SKIP
     "da  denuncia  a  Parte  infratora,  que tera prazo de 5 (cinco) dias, apos o recebimento, para sanar a falta. Decorrido o prazo e nao"
     SKIP
     "tendo sido sanada a falta, o Contrato ficara rescindido de pleno direito, respondendo ainda, a Parte infratora pelas perdas e danos"
     SKIP
     "decorrentes."
     SKIP(1)
     "\033\107Paragrafo segundo\033\110. Ocorrendo  o  vencimento  antecipado do presente contrato, ficara autorizada a \033\107Cooperativa\033\110 a efetuar a cobranca de"
     SKIP
     "forma amigavel  e/ou  judicial  dos  valores  das  faturas nao quitadas, estornados da conta-corrente, mantendo este contrato as suas"
     SKIP
     "caracteristicas de liquidez, certeza e exigibilidade."
     SKIP(1)
     "\033\107Paragrafo terceiro\033\110. Sobre  o  montante  da quantia devida e nao paga, incidirao ENCARGOS FINANCEIROS, compreendidos, alem da correcao"
     SKIP
     "monetaria,  de  juros  remuneratorios e juros moratorios, conforme o indice e taxas estabelecidas no item 3, das CONDICOES ESPECIAIS,"
     SKIP
     "apurados  entre  a  data  da  mora ate a data do efetivo pagamento, alem de multa contratual de 2% (dois por cento), sobre o montante"
     SKIP
     "apurado  e  impostos  que  incidam  ou  venham a incidir sobre a operacao contratada, devendo a \033\107Cooperada\033\110 e seus \033\107Coobrigados\033\110, efetuar"
     SKIP
     "imediatamente o pagamento do montante do debito apurado, sob pena de serem demandados judicialmente."
     SKIP(1)
     WITH COLUMN 5 NO-ATTR-SPACE WIDTH 182 NO-LABELS NO-BOX FRAME f_topico_26_pj.

    FORM aux_dstopico FORMAT "x(198)"
        SKIP
        "condicoes  estabelecidas  no  mesmo,  sendo  celebrado  em  carater  irrevogavel  e  irretratavel, obrigando, tambem, seus herdeiros,"
        SKIP
        "cessionarios e sucessores, a qualquer titulo."
        SKIP(1)
        WITH COLUMN 5 NO-ATTR-SPACE WIDTH 198 NO-LABELS NO-BOX FRAME f_topico_27_pj.

    FORM aux_dstopico FORMAT "x(183)"
         SKIP
         "cooperativismo,  o  Sistema  CECRED,  ao  estatuto  social da \033\107Cooperativa\033\110, as deliberacoes assembleares desta e as do seu Conselho de"
         SKIP
         "Administracao, aos quais a \033\107Cooperada\033\110 livre e espontaneamente aderiu ao integrar o quadro social da \033\107Cooperativa\033\110, e cujo teor as partes"
         SKIP
         "ratificam, reconhecendo-se nesta operacao a celebracao de um \033\107ATO COOPERATIVO.\033\110"
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 183 NO-LABELS NO-BOX FRAME f_topico_28_pj.

    FORM aux_dstopico FORMAT "x(182)"
         SKIP
         "privilegiado que se seja, para dirimir quaisquer questoes resultantes do presente contrato."
         SKIP(1)
         "E  assim,  por  se acharem justos e contratados, assinam o presente contrato, em 02 (duas) vias de igual teor e forma, na presenca de"
         SKIP
         "duas testemunhas abaixo, que, estando cientes, tambem assinam, para que produza os devidos e legais efeitos."
         SKIP(1)
         rel_dsemsctr FORMAT "x(50)"
         SKIP(3)
         "__________________________________________________"
         "__________________________________________________"       AT 80
         SKIP
         tt-bdn_visa_cecred.nmprimtl
         aux_nmprimtl                                AT 80
         SKIP
         "Nome do(a) representante:"                                
         "Nome do(a) representante:"                                AT 80
         SKIP
         "CPF do(a) representante:"
         "CPF do(a) representante:"                                 AT 80
         SKIP(3)
         "__________________________________________________"
         SKIP
         tt-bdn_visa_cecred.nmextcop                                  
         SKIP(3)
        "__________________________________________________"
        "__________________________________________________"       AT 80
         SKIP
         "Fiador 1:"       
          tt-bdn_visa_cecred.nmdaval1 FORMAT "x(40)"
         "Conjuge Fiador 1:"       AT 80
         tt-bdn_visa_cecred.nmconju1  FORMAT "x(40)"
         SKIP
         "CPF:"
         tt-bdn_visa_cecred.cpfcgc1  FORMAT "x(15)"
         "CPF:"                           AT 80
         tt-bdn_visa_cecred.nrcpfcj1 FORMAT "x(15)"
         SKIP(3)
         "__________________________________________________"
         "__________________________________________________"       AT 80
         SKIP
         "Fiador 2:"
         tt-bdn_visa_cecred.nmdaval2  FORMAT "x(40)"
         "Conjuge Fiador 2:"       AT 80
         tt-bdn_visa_cecred.nmconju2 FORMAT "x(40)"
         SKIP
         "CPF:"
          tt-bdn_visa_cecred.cpfcgc2 FORMAT "x(15)"
         "CPF:"                    AT 80                        
         tt-bdn_visa_cecred.nrcpfcj2 FORMAT "x(15)"
         SKIP(2)
         "TESTEMUNHAS:"
         SKIP(2)
         "__________________________________________________"
         "__________________________________________________"       AT 80                 
         SKIP
         "Nome:"                                
         "Nome:"                                AT 80
         SKIP
         "CPF:"
         "CPF:"                                 AT 80
         SKIP(1)
         WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 182 NO-ATTR-SPACE FRAME f_topico_29_pj.

    FORM 
        SKIP(1)
        rel_dsemsctr FORMAT "x(50)"
        SKIP(3)
        "_____________________________________"
        SKIP
        tt-bdn_visa_cecred.nmprimtl
        SKIP
        "CNPJ:"        
        SKIP
        "Conta/dv:" 
        SKIP(2)
        "Endereco:"
        SKIP
        rel_dsendere FORMAT "x(50)"
        SKIP
        tt-bdn_visa_cecred.complend FORMAT "x(40)"
        SKIP
        tt-bdn_visa_cecred.nmbaiend FORMAT "x(15)"
        SKIP
        rel_nmcidend FORMAT "x(20)"
        SKIP
        tt-bdn_visa_cecred.nrcepend FORMAT "zz,zzz,zz9"
        SKIP(1)
          WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 150 NO-ATTR-SPACE FRAME f_final_pj.

    /*  utiliza o handle da bo 028 que ja esta na memoria.*/
    ASSIGN h-b1wgen0028 = SOURCE-PROCEDURE.

    IF  NOT VALID-HANDLE(h-b1wgen0028) THEN
        DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO " +
                                  "b1wgen0028.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
    
        END.

    RUN impressoes_cartoes IN h-b1wgen0028( INPUT  par_cdcooper,
                                            INPUT  0,
                                            INPUT  0,
                                            INPUT  par_cdoperad,
                                            INPUT  par_nmdatela,
                                            INPUT  1,
                                            INPUT  par_nrdconta,
                                            INPUT  1,
                                            INPUT  par_dtmvtolt,
                                            INPUT  par_dtmvtopr,
                                            INPUT  par_inproces,
                                            INPUT  2, /* Contrato Visa Cecred */
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

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro THEN
                RETURN "NOK".

        END.
     
    FIND tt-bdn_visa_cecred NO-ERROR.
    IF   NOT AVAIL tt-bdn_visa_cecred   THEN
         DO:

             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Nao foi possivel gerar a impressao.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT 0,
                            INPUT 0,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".

         END.

    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                          par_dsiduser.
    
    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
     
    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

    ASSIGN aux_nmprimtl = tt-bdn_visa_cecred.nmprimtl.

    FIND crapass WHERE
         crapass.cdcooper = par_cdcooper AND
         crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  crapass.inpessoa = 1   THEN
        DO:

            DISPLAY STREAM str_1
                    tt-bdn_visa_cecred.nmcartao   tt-bdn_visa_cecred.dssubsti
                    tt-bdn_visa_cecred.nrctrcrd
                    WITH FRAME f_titulo.
        
            DISPLAY STREAM str_1
                    tt-bdn_visa_cecred.nmextcop   tt-bdn_visa_cecred.nmrescop
                    tt-bdn_visa_cecred.nrdocnpj   tt-bdn_visa_cecred.dsendcop
                    tt-bdn_visa_cecred.nrendcop   tt-bdn_visa_cecred.nmbairro
                    tt-bdn_visa_cecred.nmcidade   tt-bdn_visa_cecred.cdufdcop  
                    tt-bdn_visa_cecred.nmprimtl   tt-bdn_visa_cecred.nrcpfcgc
                    tt-bdn_visa_cecred.nrdconta
                    WITH FRAME f_topico_1.
        
            DISPLAY STREAM str_1     
                    WITH FRAME f_topico_2.
                
            DISPLAY STREAM str_1
                    tt-bdn_visa_cecred.dsvincul
                    WITH FRAME f_topico_3.
                
            DISPLAY STREAM str_1 WITH FRAME f_topico_4.
            DISPLAY STREAM str_1 WITH FRAME f_topico_5.
            DISPLAY STREAM str_1 WITH FRAME f_topico_6.
            DISPLAY STREAM str_1 WITH FRAME f_topico_7.
            DISPLAY STREAM str_1 WITH FRAME f_topico_8.
            DISPLAY STREAM str_1 WITH FRAME f_topico_9.
                
            DISPLAY STREAM str_1
                    tt-bdn_visa_cecred.nrcrcard   tt-bdn_visa_cecred.nrctrcrd
                    tt-bdn_visa_cecred.nmtitcrd
                    WITH FRAME f_topico_10.
        
            DISPLAY STREAM str_1 WITH FRAME f_topico_11.
            DISPLAY STREAM str_1 WITH FRAME f_topico_12.
            DISPLAY STREAM str_1 WITH FRAME f_topico_13.
        
            PAGE STREAM str_1.  /* quebra de pagina */
        
            DISPLAY STREAM str_1
                    tt-bdn_visa_cecred.nmcartao   tt-bdn_visa_cecred.dssubsti
                    tt-bdn_visa_cecred.nrctrcrd
                    WITH FRAME f_titulo.
        
            DISPLAY STREAM str_1     WITH FRAME f_topico_14.
        
            DISPLAY STREAM str_1     WITH FRAME f_topico_15.
        
            DISPLAY STREAM str_1 
                    tt-bdn_visa_cecred.nmcidade   tt-bdn_visa_cecred.cdufdcop
                    tt-bdn_visa_cecred.dsemsctr   tt-bdn_visa_cecred.nmprimtl
                    tt-bdn_visa_cecred.nmextcop   tt-bdn_visa_cecred.nmoperad
                    WITH FRAME f_topico_16.

        END.
    ELSE
        DO:

            DISPLAY STREAM str_1
                    tt-bdn_visa_cecred.nmcartao   tt-bdn_visa_cecred.dssubsti
                    tt-bdn_visa_cecred.nrctrcrd
                    WITH FRAME f_titulo_pj.
        
            ASSIGN aux_dslinhax  =  "1.1. COOPERATIVA: " + tt-bdn_visa_cecred.nmextcop + ", sociedade cooperativa de credito, de responsabilidade limitada," +
                                    "regida pela legislacao vigente, normas baixadas pelo Conselho Monetario Nacional, pela regulamentacao estabelecida pelo Banco Central" +
                                    " do Brasil e pelo seu estatuto social, arquivado na Junta Comercial do Estado de Santa Catarina, inscrita no CNPJ n. ".
                                                                
            RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

            IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                             
                    RETURN "NOK".
                END.

            RUN quebra-str IN h-b1wgen9999 ( INPUT aux_dslinhax,
                                             INPUT 133, INPUT 133, 
                                             INPUT 133, INPUT 0, 
                                            OUTPUT rel_dslinha1, 
                                            OUTPUT rel_dslinha2,
                                            OUTPUT rel_dslinha3, 
                                            OUTPUT rel_dslinha4).

            DELETE PROCEDURE h-b1wgen9999.

            ASSIGN aux_dslinhax  =  tt-bdn_visa_cecred.nrdocnpj + ", " +
                                    "estabelecida a " + tt-bdn_visa_cecred.dsendcop + ", n. " + TRIM(STRING(tt-bdn_visa_cecred.nrendcop,"zzz,zz9")) + ", Bairro " + tt-bdn_visa_cecred.nmbairro + ", " + tt-bdn_visa_cecred.nmcidade + ", " + tt-bdn_visa_cecred.cdufdcop + ", " +
                                    "filiada  a  COOPERATIVA CENTRAL DE CREDITO URBANO - CECRED, Cooperativa Central de Credito, de responsabilidade limitada, inscrita no " +            
                                    "CNPJ/MF  sob  o  n.  05.463.212/0001-29, estabelecida a Rua Frei Estanislau Schaette, n. 1.201, CEP 89.037-003, Bairro Agua Verde, no " +           
                                    "municipio de Blumenau, Estado de Santa Catarina.".

            RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

            IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                             
                    RETURN "NOK".
                END.

            RUN quebra-str IN h-b1wgen9999 ( INPUT aux_dslinhax,
                                             INPUT 133, INPUT 133, 
                                             INPUT 133, INPUT 133, 
                                            OUTPUT rel_dslinha5, 
                                            OUTPUT rel_dslinha6,
                                            OUTPUT rel_dslinha7, 
                                            OUTPUT rel_dslinha8).

            DELETE PROCEDURE h-b1wgen9999.

            ASSIGN aux_dslinhax  = "1.2. COOPERADA: " + tt-bdn_visa_cecred.nmprimtl + ", pessoa juridica de direito privado, inscrita no CNPJ/MF n. " + 
                                    tt-bdn_visa_cecred.nrcpfcgc + ", Conta corrente: " + TRIM(STRING(tt-bdn_visa_cecred.nrdconta,"zzzz,zzz,9")) + ", representada neste ato por seu(s) representante(s) legal(ais), abaixo nominado(s).".
          
            RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

            IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                             
                    RETURN "NOK".
                END.

            RUN quebra-str IN h-b1wgen9999  ( INPUT aux_dslinhax,
                                              INPUT 133, INPUT 133, 
                                              INPUT 0, INPUT 0, 
                                             OUTPUT rel_dslinha9, 
                                             OUTPUT rel_dslinha10,
                                             OUTPUT rel_dslinha11, 
                                             OUTPUT rel_dslinha12).

            DELETE PROCEDURE h-b1wgen9999.

            ASSIGN rel_dslinha1 = REPLACE(rel_dslinha1,"1.1.","\033\1071.1.")
                   rel_dslinha1 = REPLACE(rel_dslinha1,"COOPERATIVA:","COOPERATIVA:\033\110")
                   rel_dslinha9 = REPLACE(rel_dslinha9,"1.2.","\033\1071.2.")            
                   rel_dslinha9 = REPLACE(rel_dslinha9,"COOPERADA:","COOPERADA:\033\110").

            DISPLAY STREAM str_1
                    rel_dslinha1   rel_dslinha2
                    rel_dslinha3   rel_dslinha5
                    rel_dslinha6   rel_dslinha7
                    rel_dslinha8   rel_dslinha9
                    rel_dslinha10
                    WITH FRAME f_topico_1_pj.
       
            DISPLAY STREAM str_1  
                    tt-bdn_visa_cecred.vllimglb   tt-bdn_visa_cecred.dsvllim1
                    tt-bdn_visa_cecred.dsvllim2
                    WITH FRAME f_topico_2_pj.
                
            DISPLAY STREAM str_1 WITH FRAME f_topico_3_pj.
                
            DISPLAY STREAM str_1 
                    tt-bdn_visa_cecred.nrdconta            
                    WITH FRAME f_topico_4_pj.

            DISPLAY STREAM str_1 WITH FRAME f_topico_5_pj.

            DISPLAY STREAM str_1 
                    tt-bdn_visa_cecred.dsrepre1   tt-bdn_visa_cecred.dsrepre2            
                    WITH FRAME f_topico_6_pj.

            ASSIGN aux_nrtopico = 6.

            IF  tt-bdn_visa_cecred.cpfcgc1 <> "" THEN
                DO:

                    ASSIGN rel_dfiador1 =  "7.1. Fiador 1 " + tt-bdn_visa_cecred.nmdaval1 + ", portador do CPF n. " + tt-bdn_visa_cecred.cpfcgc1.

                    IF  tt-bdn_visa_cecred.cpfcgc2 <> "" THEN 
                        DO:

                            ASSIGN rel_dfiador1 = rel_dfiador1 + ";"
                                   rel_dfiador2 =  "7.2. Fiador 2 " + tt-bdn_visa_cecred.nmdaval2 + ", portador do CPF n. " + tt-bdn_visa_cecred.cpfcgc2 + ".".

                            DISPLAY STREAM str_1 
                                    rel_dfiador1
                                    rel_dfiador2
                                    WITH FRAME f_topico_7_2_pj.

                        END.
                    ELSE
                        DO:
                            ASSIGN rel_dfiador1 = rel_dfiador1 + ".".
                            
                            DISPLAY STREAM str_1 
                                    rel_dfiador1
                                    WITH FRAME f_topico_7_1_pj.

                        END.

                    ASSIGN aux_nrtopico = 7.

                END.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dslinhax  = STRING(aux_nrtopico,"9") + ") DAS PARTES CONTRATANTES: Sao partes contratantes neste instrumento, de um lado, @ " + TRIM(tt-bdn_visa_cecred.nmextcop) + "# qualificada no item 1.1. das CONDICOES ESPECIAIS, por seu representante no final assinado e doravante denominada simplesmente Cooperativa e, de outro lado, a pessoa nomeada e qualificada no item 1.2., das CONDICOES ESPECIAIS, e, daqui em diante, denominada Cooperada.".

            RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

            IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                             
                    RETURN "NOK".
                END.

            RUN quebra-str IN h-b1wgen9999 ( INPUT aux_dslinhax,
                                             INPUT 133, INPUT 133, 
                                             INPUT 133, INPUT 133, 
                                            OUTPUT rel_dslinha1, 
                                            OUTPUT rel_dslinha2,
                                            OUTPUT rel_dslinha3, 
                                            OUTPUT rel_dslinha4).

            DELETE PROCEDURE h-b1wgen9999.

            ASSIGN rel_dslinha1 = REPLACE(rel_dslinha1,STRING(aux_nrtopico,"9") + ") DAS PARTES CONTRATANTES:","\033\107" + STRING(aux_nrtopico,"9") + ") DAS PARTES CONTRATANTES:\033\110")
                   rel_dslinha1 = REPLACE(rel_dslinha1,"@","a\033\107").

            IF  INDEX(rel_dslinha1,"#") > 0 THEN        
                ASSIGN rel_dslinha1 = REPLACE(rel_dslinha1,"#","\033\110,").
            ELSE
                IF  INDEX(rel_dslinha2,"#") > 0 THEN        
                    ASSIGN rel_dslinha2 = REPLACE(rel_dslinha2,"#","\033\110,").

            IF  INDEX(rel_dslinha2,"Cooperativa") > 0 THEN
                ASSIGN rel_dslinha2 = REPLACE(rel_dslinha2,"Cooperativa","\033\107Cooperativa\033\110").
            ELSE
                IF  INDEX(rel_dslinha3,"Cooperativa") > 0 THEN
                    ASSIGN rel_dslinha3 = REPLACE(rel_dslinha3,"Cooperativa","\033\107Cooperativa\033\110").

            IF  INDEX(rel_dslinha3,"Cooperada") > 0 THEN
                ASSIGN rel_dslinha3 = REPLACE(rel_dslinha3,"Cooperada","\033\107Cooperada\033\110").
            ELSE
                IF  INDEX(rel_dslinha4,"Cooperada") > 0 THEN
                    ASSIGN rel_dslinha4 = REPLACE(rel_dslinha4,"Cooperada","\033\107Cooperada\033\110").

            DISPLAY STREAM str_1
                    rel_dslinha1   rel_dslinha2
                    rel_dslinha3   rel_dslinha4
                    WITH FRAME f_topico_8_pj.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"9") +  ") DO OBJETO:\033\110 O presente contrato tem por objeto regular as condicoes para intermediacao de prestacao de servi‡os de administracao de".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_9_pj.        

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + TRIM(STRING(aux_nrtopico,">9")) + ") DO CONTRATO DE INTERMEDIACAO:\033\110  A  \033\107Cooperativa\033\110,  na condicao de intermediaria, para o fornecimento do Cartao de Credito do Sistema".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_10_pj.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.
            
            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") + ") DA SUB-ROGACAO DE DIREITOS:\033\110  A  \033\107Cooperativa\033\110  ficara  sub-rogada  em  todos  os  direitos  da \033\107ADMINISTRADORA DE CARTOES\033\110, perante a".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_11_pj.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107"  + STRING(aux_nrtopico,"99") + ") DOS PROBLEMAS COM O CARTAO:\033\110  O  relacionamento  da  \033\107Cooperada\033\110,  para  comunicacao  de danificacao, perda, roubo, furto, fraude ou".

            DISPLAY STREAM str_1
                    aux_dstopico
                    WITH FRAME f_topico_12_pj.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") + ") DA REMUNERACAO DOS SERVICOS:\033\110 A remuneracao pelos servicos disponibilizados, compreendidos pela taxa anual de emissao/manutencao".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_13_pj.            

            PAGE STREAM str_1.  /* quebra de pagina */

            ASSIGN aux_nrtopico = aux_nrtopico + 1.


            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") + ") DAS FATURAS E DO DEBITO DAS FATURAS:\033\110  As  faturas  serao emitidas pela \033\107ADMINISTRADORA DE CARTOES\033\110 e serao nominais a cada usuario,".

            DISPLAY STREAM str_1 
                    aux_dstopico                
                    WITH FRAME f_topico_14_pj.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") + ") DO LIMITE DE CREDITO:\033\110  Cabe a \033\107Cooperativa\033\110, a seu criterio, estabelecer o limite de credito da \033\107Cooperada\033\110, podendo ajusta-lo ou ate".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_15_pj.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") + ") DO FORNECIMENTO DE EXTRATOS:\033\110  A  \033\107Cooperativa\033\110,  na  condicao  de intermediaria nao tera qualquer controle de administracao sobre o".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_16_pj.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") +  ") DA INDICACAO DOS USUARIOS DO CARTAO DE CREDITO:\033\110 A  \033\107Cooperada\033\110  compromete-se  em  indicar  a  \033\107Cooperativa\033\110  o  nome das pessoas que".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_17_pj.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") + ") DA DESISTENCIA DE CARTAO RECEBIDO:\033\110 Sera  facultado  o direito a Cooperada, no prazo de 7(sete) dias uteis a contar do recebimento".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_18_pj.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") + ") DAS OBRIGACOES DA COOPERADA:\033\110 Para a consecucao dos objetivos do presente instrumento, a \033\107Cooperada\033\110 obriga-se a:".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_19_pj.
            
            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") + ") DO RECEBIMENTO DO CARTAO:\033\110 Os  cartoes  a  serem fornecidos nos termos do presente Contrato serao nominais ao(s) Usuario(s), sendo".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_20_pj.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") + ") DAS GARANTIAS - DA FIANCA:\033\110 Para  garantir o cumprimento das obrigacoes assumidas no presente contrato, comparecem, igualmente, na".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_21_pj.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") + ") DA GARANTIA ADICIONAL - DAS NOTAS PROMISSORIAS:\033\110 Como  garantia  adicional, a \033\107Cooperada\033\110 emite Nota(s) Promissoria(s), vinculada(s)".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_22_pj.

            PAGE STREAM str_1.  /* quebra de pagina */

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") + ") DA CONSULTA E LIBERACAO DE INFORMACOES:\033\110 A \033\107Cooperada\033\110 autoriza desde ja a \033\107Cooperativa\033\110 a consultar as informacoes consolidadas sobre".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_23_pj.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") + ") DA EXIGIBILIDADE:\033\110 O  presente  instrumento  reveste-se  da  condicao de titulo executivo extrajudicial, nos termos do Art. 585 do".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_24_pj.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107"  + STRING(aux_nrtopico,"99") + ") DO PRAZO DE VIGENCIA DO CONTRATO:\033\110 O  presente  Contrato  vigorara  pelo  prazo  indicado no item 5.1., das CONDICOES ESPECIAIS, a".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_25_pj.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") + ") DAS CONDICOES ESPECIAIS DE VENCIMENTO:\033\110 Alem  das previstas em lei, este Contrato podera ser rescindido/resilido de imediato e sem".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_26_pj.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") + ") DOS EFEITOS DO CONTRATO:\033\110 Este  contrato  obriga a \033\107Cooperativa\033\110, a \033\107Cooperada\033\110 e o(s) FIADOR(ES), ao fiel cumprimento das clausulas e".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_27_pj.

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") + ") DO ATO COOPERATIVO:\033\110 Declaram  as  partes  que  o  presente  instrumento esta tambem vinculado as disposicoes legais que regulam o".

            DISPLAY STREAM str_1 
                    aux_dstopico
                    WITH FRAME f_topico_28_pj.

            PAGE STREAM str_1.  /* quebra de pagina */

            ASSIGN rel_dsemsctr = TRIM(tt-bdn_visa_cecred.nmcidade) + " " + STRING(tt-bdn_visa_cecred.cdufdcop,"!(2)") + ", " +
                                  TRIM(tt-bdn_visa_cecred.dsemsctr) + ".".

            ASSIGN aux_nrtopico = aux_nrtopico + 1.

            ASSIGN aux_dstopico = "\033\107" + STRING(aux_nrtopico,"99") + ") DO FORO:\033\110 As partes, de comum acordo, elegem o foro da Comarca do domicilio da \033\107Cooperada\033\110, com exclusao de qualquer outro, por mais".

            DISPLAY STREAM str_1
                    aux_dstopico
                    rel_dsemsctr                  aux_nmprimtl                  
                    tt-bdn_visa_cecred.nmprimtl   tt-bdn_visa_cecred.nmextcop
                    tt-bdn_visa_cecred.nmdaval1   tt-bdn_visa_cecred.nmconju1
                    tt-bdn_visa_cecred.cpfcgc1    tt-bdn_visa_cecred.nrcpfcj1
                    tt-bdn_visa_cecred.nmdaval2   tt-bdn_visa_cecred.nmconju2
                    tt-bdn_visa_cecred.cpfcgc2    tt-bdn_visa_cecred.nrcpfcj2
                    WITH FRAME f_topico_29_pj.

        END.

    /** Tratamento da impressao da nota promissoria **/        
    IF   NOT par_flgimp2v   THEN
         DO:
             EMPTY TEMP-TABLE tt_dados_promissoria.
             
             CREATE tt_dados_promissoria.
             ASSIGN tt_dados_promissoria.dsemsctr = tt-bdn_visa_cecred.dsemsctr
                    tt_dados_promissoria.dsctrcrd = tt-bdn_visa_cecred.dsctrcrd
                    tt_dados_promissoria.dsdmoeda = tt-bdn_visa_cecred.dsdmoeda
                    tt_dados_promissoria.vllimite = tt-bdn_visa_cecred.vllimite
                    tt_dados_promissoria.dsdtmvt1 = tt-bdn_visa_cecred.dsdtmvt1
                    tt_dados_promissoria.dsdtmvt2 = tt-bdn_visa_cecred.dsdtmvt2
                    tt_dados_promissoria.nmextcop = tt-bdn_visa_cecred.nmextcop
                    tt_dados_promissoria.nmrescop = tt-bdn_visa_cecred.nmrescop
                    tt_dados_promissoria.dsvlnpr1 = tt-bdn_visa_cecred.dsvlnpr1
                    tt_dados_promissoria.dsvlnpr2 = tt-bdn_visa_cecred.dsvlnpr2
                    tt_dados_promissoria.nmcidpac = tt-bdn_visa_cecred.nmcidpac
                    tt_dados_promissoria.nmprimtl = tt-bdn_visa_cecred.nmprimtl
                    tt_dados_promissoria.dscpfcgc = tt-bdn_visa_cecred.dscpfcgc
                    tt_dados_promissoria.nrdconta = tt-bdn_visa_cecred.nrdconta
                    tt_dados_promissoria.endeass1 = tt-bdn_visa_cecred.endeass1
                    tt_dados_promissoria.endeass2 = tt-bdn_visa_cecred.endeass2
                    tt_dados_promissoria.nmcidade = tt-bdn_visa_cecred.nmcidade
                    tt_dados_promissoria.dsmvtolt = 
                             STRING(DAY(par_dtmvtolt),"99")             + " " +
                             aux_dsmesano[MONTH(par_dtmvtolt)]          + " " +
                             STRING(YEAR(par_dtmvtolt),"9999").
                    
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
                         tt_dados_promissoria.dsendav1[3] = tt-avais-ctr.dsendav3
                         aux_contador                     = aux_contador + 1.
                 ELSE
                      ASSIGN 
                         tt_dados_promissoria.nmdaval2    = tt-avais-ctr.nmdavali
                         tt_dados_promissoria.nmdcjav2    = tt-avais-ctr.nmconjug
                         tt_dados_promissoria.dscpfav2    = tt-avais-ctr.cpfavali
                         tt_dados_promissoria.dscfcav2    = tt-avais-ctr.nrcpfcjg
                         tt_dados_promissoria.dsendav2[1] = tt-avais-ctr.dsendav1
                         tt_dados_promissoria.dsendav2[2] = tt-avais-ctr.dsendav2
                         tt_dados_promissoria.dsendav2[3] = tt-avais-ctr.dsendav3.
             END.            
             
             RELEASE tt_dados_promissoria.
             
             RUN gera_impressao_promissoria ( INPUT par_cdcooper,
                                              INPUT TABLE tt_dados_promissoria,
                                             OUTPUT TABLE tt-erro).

         END.
    /** Fim - Tratamento da impressao da nota promissoria **/

    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            DO WHILE TRUE:

                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.
            
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE.
                    END.
                
                RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                        INPUT aux_nmarqpdf).
    
                /** Copiar pdf para visualizacao no Ayllos WEB **/
                IF  SEARCH(aux_nmarqpdf) = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                              " a impressao.".
                        LEAVE.                      
                    END.
                            
                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                   '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                                   ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                                   '/temp/" 2>/dev/null').
   
                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.
    
            IF  aux_dscritic <> ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-erro  THEN
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                                                       
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

                    RETURN "NOK".
                END.

            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
     
        END.                                                                      
                                                      
    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

    RETURN "OK".

END PROCEDURE.

PROCEDURE gera_impressao_contrato_bb:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrcrd AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgimpnp AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_nmendter AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgimp2v AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cdmotivo AS INTE                           NO-UNDO.



    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    
    DEF VAR h_b1wgen0028 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_contador AS INT                                     NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.


    FORM "\022\024\033\120"     /* Reseta impressora */
         SKIP
         "\0330\033x0\033\017"
         "\033\016    CONTRATO PARA UTILIZACAO DE CARTAO MULTIPLO" 
         "\022\024\033\120"     /* Reseta impressora */
         SKIP(1)
         "\033\105"
         tt-ctr_bb.nmcartao NO-LABEL  AT 25 FORMAT "X(15)"
         "\033\106" 
         "\022\024\033\120"     /* Reseta impressora */
         SKIP(3)
         "\0330\033x0\033\017"
         WITH COLUMN 10 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_titulo.
    
    FORM "\033\1071) DAS PARTES:  "
         tt-ctr_bb.nmextcop FORMAT "x(50)"
         " - "
         tt-ctr_bb.nmrescop
         "\033\110,   sociedade   cooperativa   de   credito,    de"
         SKIP
         "responsabilidade limitada, regida pela legislacao vigente, normas"
         "baixadas pelo  Conselho  Monetario  Nacional,  pela  regulamentacao"
         SKIP
         "estabelecida pelo Banco Central do Brasil e pelo seu estatuto social,"
         "arquivado na Junta  Comercial  do  Estado  de  Santa  Catarina,"
         SKIP
         "inscrita    no    "
         tt-ctr_bb.nrdocnpj FORMAT "X(23)"
         " ,  estabelecida    a"
         tt-ctr_bb.dsendcop
         " ,  n. "
         tt-ctr_bb.nrendcop
         " ,  bairro"
         SKIP
         tt-ctr_bb.nmbairroc
         " ,"
         tt-ctr_bb.nmcidadec  FORMAT "x(23)"
         ","
         tt-ctr_bb.cdufdcop
         " filiada a \033\107COOPERATIVA  CENTRAL  DE  CREDITO  URBANO -"
         "CECRED\033\110, Cooperativa Central de"
         SKIP
         "Credito, de  responsabilidade  limitada, inscrita  no  CNPJ/MF sob o n."
         " 05.463.212/0001-29,  estabelecida  na  Rua  Frei  Estanislau"
         SKIP
         "Schaette, n. 1201, bairro Agua Verde, na cidade de Blumenau, Estado de"
         "Santa Catarina."
         SKIP
         "\033\107COOPERADO(A):\033\110"
         tt-ctr_bb.nmprimtl FORMAT "x(40)"
         "       CPF/CNPJ " 
         tt-ctr_bb.nrcpfcgc FORMAT "X(18)"
         SKIP
         "              Conta-corrente:"
         tt-ctr_bb.nrdconta
         "                      Conta-integracao:"
         tt-ctr_bb.nrdctitg
         SKIP
         "              Rua:" tt-ctr_bb.dsendere
         "   Numero:" tt-ctr_bb.nrendere
         SKIP
         "              Bairro:" tt-ctr_bb.nmbairro FORMAT "x(40)"
         "Cidade:" tt-ctr_bb.nmcidade FORMAT "x(25)"
         SKIP
         "              CEP:" tt-ctr_bb.nrcepend
         "                                 U.F.:" tt-ctr_bb.cdufende
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_1.
    
    FORM "\033\1072) DO OBJETO:\033\110 O presente contrato tem por objeto"
         "regular as condicoes para intermediacao de  prestacao  de  servicos "
         "de  utilizacao,"
         SKIP
         "pelo 1o titular e pelos demais titulares eventualmente vinculados a"
         " conta-corrente,  do  Cartao  Multiplo  do "
         "\033\107Banco do Brasil S.A.\033\110,"
         SKIP
         "CNPJ/MF nr. 00.000.000/5060-10, doravante denominado comumente  de "
         "\033\107Banco do Brasil\033\110,  neles  compreendidas  as  funcoes"
         " de  credito,"
         SKIP 
         "debito e bancaria, com abrangencia no pais e exterior, adequados ao"
         "perfil de uso do \033\107Cooperado(a)\033\110,  inclusive  para "
         "movimentacao  de"
         SKIP
         "sua conta-corrente."
         SKIP(1)
         "\033\107Paragrafo Primeiro:\033\110 Entende-se por"
         "\033\107Funcao Credito,\033\110 a utilizacao do cartao como meio de"
         " pagamento  de  compras  de  bens  e  servicos"
         SKIP
         "realizadas em estabelecimentos credenciados as redes"
         "Visa ou MasterCard, observado o limite de credito  para  compras  do "
         "cooperado,"
         SKIP
         "estabelecido pela \033\107Cooperativa;\033\110"
         SKIP(1)                                    
         "\033\107Paragrafo Segundo:\033\110 Entende-se por"
         "\033\107Funcao Debito,\033\110 a utilizacao do cartao como  meio  de"
         " pagamento  de  compras  de  bens  e  servicos"
         SKIP
         "realizadas em estabelecimentos credenciados as redes"
         "Visa Electron ou MasterCard Maestro, limitado ao saldo ou parametro"
         "diario  para"
         SKIP
         "compra  do  cooperado  estabelecido  pela "
         "\033\107Cooperativa\033\110,  caso este seja inferior ao saldo existente,"
         "devendo  estes  valores  estarem "
         SKIP 
         "em consonancia com os limites estabelecidos pelo"
         "\033\107Banco do Brasil\033\110 para essas operacoes;"
         SKIP(1)
         "\033\107Paragrafo Terceiro:\033\110 Entende-se por"
         "\033\107Funcao Bancaria,\033\110 a utilizacao do cartao para acessar o"
         "Codigo de  Integracao  Cooperado  junto  ao"
         SKIP
         "\033\107Banco do Brasil\033\110 e terminais eletronicos"
         "compartilhados, efetuar saques e depositos  via  terminais  de"
         " auto-atendimento,  transferir"
         SKIP
         "recursos e acessar terminais de auto-atendimento,  limitado  ao "
         "parametro  diario  estabelecido  pela " 
         "\033\107Cooperativa\033\110,  que  estara  em"
         SKIP                                           
         "consonancia com os limites estabelecidos pelo"
         "\033\107Banco do Brasil\033\110 para essas operacoes. Entende-se por"
         "\033\107Saques,\033\110  a  utilizacao  do  cartao"
         SKIP
         "para efetuar saques nos terminais de auto-atendimento do"
         "\033\107Banco do Brasil\033\110, nos terminais do Banco24Horas e"
         "terminais  eletronicos  das"
         SKIP
         "redes Visa Plus e MasterCard Cirrus, limitado ao Limite de Credito para"
         "Saques do  \033\107Cooperado\033\110  estabelecido  pela "
         "\033\107Cooperativa\033\110,  ou  a"
         SKIP
         "debito do Codigo de Integracao Cooperado, limitado ao parametro diario"
         "estabelecido pela \033\107Cooperativa\033\110, baseado no saldo de  sua "
         "conta"
         SKIP
         "corrente ou limite estabelecido, o que for menor, e que devera estar em"
         "consonancia"
         "com os limites estabelecidos pelo \033\107Banco do Brasil\033\110"
         SKIP
         "para"
         "essas operacoes."
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_2.
    
    FORM "\033\1073) DO CONTRATO DE INTERMEDIACAO:\033\110 A \033\107Cooperativa"
         "\033\110, na condicao de intermediaria, para o fornecimento do Cartao"
         "de  Credito  do  Sistema"
         SKIP
         "\033\107VISA ou MASTERCARD\033\110,tipo"
         "\033\107DOMESTICO,INTERNACIONAL ou GOLD\033\110  a  seus  associados,"
         " subscreveu  o  contrato  de  prestacao  de  servico  e"
         SKIP
         "disponibilizacao de produtos oferecido pelo"
         "\033\107Banco do Brasil.\033\110"
         SKIP(1)
         "\033\107Paragrafo unico: O(a) Cooperado(a),\033\110 na condicao de"
         "usuario do cartao de  credito,  pelo  presente  instrumento,  declara "
         "conhecer  o"
         SKIP
         "contrato  referido  no  \033\064caput\033\065,  aderindo  e "
         "aceitando  suas  condicoes,  as  quais  se   sujeita,   funcionando"
         "  naquele   contrato"
         SKIP
         "como BENEFICIARIO, assim como declara saber que esta impedido de fazer"
         "qualquer alteracao cadastral diretamente no"
         "\033\107Banco do Brasil.\033\110"
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_3.
       
    FORM "\033\1074) DA SUB-ROGACAO DE DIREITOS:\033\110"
         " A  \033\107Cooperativa\033\110  ficara  sub-rogada  em  todos  os"
         " direitos  do  \033\107Banco  do  Brasil\033\110 ,   perante   o(a)"
         SKIP
         "\033\107Cooperado(a)\033\110,usuario do cartao,sempre que liquidar as"
         "faturas mensais, e ate a liquidacao total do debito deste perante a"
         "mesma."
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_4.
        
    FORM "\033\1075) DOS PROBLEMAS COM O CARTAO:\033\110 O relacionamento do(a)"
         "\033\107Cooperado(a)\033\110, para comunicacao de danificacao, perda,"
         "roubo, furto,  fraude  ou"
         SKIP
         "falsificacao de cartao e outras, sera diretamente com o"
         "\033\107Banco do Brasil\033\110, podendo eventualmente a"
         "\033\107Cooperativa\033\110 servir de intermediaria."
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_5.
    
    FORM "\033\1076) DA REMUNERACAO DOS SERVICOS:\033\110 A remuneracao pelos"
         "servicos disponibilizados sera de inteira  responsabilidade  do(a) "
         "\033\107Cooperado(a)\033\110,"
         SKIP
         "sendo debitados diretamente na fatura do cartao multiplo ou em"
         "conta-corrente."
         SKIP(1)
         "\033\107Paragrafo unico:\033\110 A \033\107COOPERATIVA\033\110 podera"
         "repassar, alem da remuneracao dos  servicos  cobrados  pelo"
         " \033\107Banco do Brasil\033\110,  uma  remuneracao"
         SKIP
         "pelos seus servicos de intermediacao, que tambem sera debitada na conta"
         "do(a) \033\107Cooperado(a)\033\110."     
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_6.
    
    FORM "\033\1077) DOS DEBITOS:\033\110 O(a)"
         "\033\107Cooperado(a)\033\110 e o(s) \033\107Fiador(es)\033\110,"
         "desde logo, em carater irrevogavel e irretratavel, para todos  os"
         "efeitos legais"
         SKIP
         "e contratuais, autoriza(m) desde ja, o debito do valor da fatura mensal"
         "e da utilizacao das  opcoes  debito  e  bancaria  oriunda  da"
         SKIP
         "utilizacao do cartao e demais despesas ou encargos, na data do seu"
         " vencimento,  em  sua(s)  conta(s)  corrente(s)  mantida  junto  a"
         SKIP
         "\033\107Cooperativa\033\110, podendo esta utilizar o saldo credor de"
         "qualquer conta em nome dos mesmos,  aplicacao  financeira  e  creditos"
         " de  seus"
         SKIP
         "titulares, em qualquer das unidades da mesma, efetuando o bloqueio "
         "dos valores,  ate  o  limite  necessario  para  a  liquidacao  ou"
         SKIP
         "amortizacao das obrigacoes assumidas e vencidas no presente contrato,"
         "obrigando-se ainda  o(a)  \033\107Cooperado(a)\033\110"
         " e  o(s)  \033\107Fiador(es)\033\110,  a"
         SKIP
         "sempre manter(em) saldo em sua(s) conta(s)-corrente(s) para a"
         "realizacao dos referidos debitos."
         SKIP(1)
         "\033\107Paragrafo Primeiro:\033\110 O(a) \033\107Cooperado(a)\033\110"
         "podera efetuar saques na rede de caixas eletronicos do "
         "\033\107Banco do Brasil, Banco24Horas\033\110  e caixas"
         SKIP
         "compartilhados ao Banco do Brasil, dentro de limites que a"
         "\033\107Cooperativa\033\110 estabelecer, sendo  que  tais  saques  e "
         "respectivas  tarifas"
         SKIP
         "serao imediatamente debitados de sua conta corrente supra identificada." 
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_7.

    FORM "\033\107Paragrafo Segundo:\033\110 O(a) \033\107Cooperado(a)\033\110"
         "compromete-se a  manter saldo em conta corrente suficiente  para  a "
         "realizacao  dos  pagamentos "
         SKIP
         "agendados nos terminais  eletronicos, declarando-se ciente de que, caso o saldo"
         "da conta for maior que o limite de  debito contratado "
         SKIP
         "para o cartao, prevalecera o limite contratado, sendo este o valor disponivel "
         "para realizacao  de  saques,  pagamentos,  agendamento"
         SKIP
         "de pagamentos e transferencias."
         SKIP(1)
         "\033\107Paragrafo Terceiro:\033\110 Fica a \033\107Cooperativa\033\110"
         "isenta de qualquer  responsabilidade decorrente  da  nao liquidacao do "
         "compromisso na data do"
         SKIP
         "vencimento e no horario  previsto para o processamento, em virtude da nao"
         "observancia do disposto  no paragrafo segundo deste artigo."
         SKIP(1)
         "\033\107Paragrafo Quarto:\033\110 O(a) \033\107Cooperado(a)\033\110"
         "declara-se  ciente   ainda  que, o  comprovante  do  agendamento  de  pagamentos "
         "nos   terminais" 
         SKIP
         "eletronicos nao  garante a  efetiva  liquidacao  da fatura, sendo que  esta  apenas "
         "sera liquidada  quando  observado o  disposto no"
         SKIP
         "Paragrafo Segundo desta Clausula."
         SKIP(1)
         "\033\107Paragrafo Quinto:\033\110 Em caso de ocorrencia de saldo  devedor "
         "em conta corrente, proveniente  de  lancamentos  devidamente  autorizados, "
         SKIP
         "fica a \033\107Cooperativa\033\110 desde  ja  autorizada  a  proceder "
         "ao bloqueio do cartao ora contratado, independente  de  aviso  ou  notificacao"
         SKIP
         "previa ao \033\107Cooperado.\033\110"
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_7_1.
    
    FORM "\033\1078) DOS LIMITES:\033\110 Cabe a"
         "\033\107Cooperativa\033\110, a seu criterio, estabelecer os limites de"
         "credito, debito e bancario do(a) \033\107Cooperado(a)\033\110,  podendo"
         SKIP
         "ajusta-lo ou ate cancela-lo integralmente, de acordo com suas"
         "condicoes gerais de credito  do  mesmo  perante  esta,  podendo  ainda,"
         SKIP
         "reduzi-lo, se o saldo devedor da fatura mensal ou lancamentos a debito"
         "nao for liquidado pelo(a) \033\107Cooperado(a)\033\110."
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_8.
    
    FORM "\033\1079) DO FORNECIMENTO DE EXTRATOS:\033\110 A"
         "\033\107Cooperativa\033\110, na condicao de intermediaria nao tera "
         "qualquer  controle  de  administracao  sobre  o"
         SKIP
         "cartao de creditos, sendo que, inclusive os  extratos  mensais  de"
         "utilizacao  das  contas  sera  de  responsabilidade  exclusiva  do"
         SKIP
         "\033\107Banco do Brasil\033\110 e/ou da Administradora de Cartoes de"
         "Credito."
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_9.
    
    FORM "\033\10710) DO RECEBIMENTO DO CARTAO E SENHA:\033\110 O(a)"
         "Cooperado(a) declara estar ciente de que o  cartao  multiplo,  assim"
         " como  instrucoes  de"
         SKIP
         "desbloqueio e cadastramento de senha, serao remetidos pelo"
         "Banco do Brasil e/ou pela Administradora de Cartoes de Credito"
         "diretamente"
         SKIP
         "ao Cooperado(a), responsabilizando-se integralmente este"
         "pelo desbloqueio e utilizacao do cartao."
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_10.
         
    FORM "\033\10711) DAS GARANTIAS - DA FIANCA:\033\110 Para garantir o"
         "cumprimento das obrigacoes assumidas no presente contrato, comparecem,"
         "igualmente,  na"
         SKIP
         "condicao de \033\107Fiador(es)\033\110, a(s) pessoa(s) e"
         "seu conjuge(s) nominado(s), o(s) qual(is) expressamente declara(m)"
         "que responsabiliza(m)-se,"
         SKIP
         "solidariamente, como principal(is) pagador(es), pelo  cumprimento  de "
         "todas  as  obrigacoes  assumidas  pelo(a)  \033\107Cooperado(a)\033\110 "
         "neste"
         SKIP
         "contrato, renunciando, expressamente, os beneficios de ordem que"
         "trata o art. 827, em conformidade com o art. 828, incisos I e II,  e"
         SKIP
         "art. 838, do Codigo Civil Brasileiro (Lei n. 10.406, de 10/01/2002)."
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_11.
         
         
    FORM "\033\10712) DA GARANTIA ADICIONAL - DA NOTA PROMISSORIA:\033\110"
         "Como garantia adicional, o(a) \033\107Cooperado(a)\033\110"
         "emite(m) Nota Promissoria,  vinculada  ao"
         SKIP
         "Contrato, no valor do limite de credito do cartao, seja para pagamento"
         "unico ou pelo sistema parcelado na forma eleita no comprovante"
         SKIP
         "de venda, igualmente subscrita pelo(s)"
         "\033\107Avalista(s)\033\110,"
         "a(s) qual(is) passa(m) a ser parte integrante do presente."
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_12.
         
    FORM "\033\10713) DO SEGURO:\033\110"
         "Havendo interesse do(a) \033\107Cooperado(a)\033\110, este(a) podera"
         "contratar diretamente com o  \033\107Banco  do  Brasil\033\110 "
         "ou  Corretora  de"
         "Seguros por este indicado, as suas expensas, um seguro sobre o cartao,"
         "denominado Seguro Protecao Ouro."
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_13.
    
    FORM "\033\10714) DA EXIGIBILIDADE:\033\110 O presente instrumento reveste-se"
         "da condicao de titulo executivo extrajudicial,  nos  termos  do"
         "Art.  585  do"
         "C.P.C., reconhecendo as partes, desde ja, a sua liquidez, certeza e"
         "exigibilidade."
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_14.
         
    FORM "\033\10715) DO PRAZO DE VIGENCIA E DAS CONDICOES ESPECIAIS DE"
         "VENCIMENTO:\033\110 O presente contrato vigorara por prazo"
         "indeterminado, sendo  que  a"
         SKIP
         "falta ou insuficiencia de fundos na(s) conta(s)-corrente(s),"
         "impossibilitando o pagamento e liquidacao no vencimento, dos lancamentos"
         SKIP
         "a debito e de quaisquer das faturas do cartao de credito,"
         "independentemente de qualquer notificacao judicial ou extrajudicial,"
         "podera"
         SKIP
         "determinar, a criterio da \033\107Cooperativa\033\110, o vencimento"
         "antecipado do presente contrato, com a cobranca de forma amigavel "
         "e/ou  judicial"
         SKIP
         "dos valores estornados da conta-corrente, mantendo este contrato as suas"
         "caracteristicas de liquidez, certeza e exigibilidade."
         SKIP(1)
         "\033\107Paragrafo unico:\033\110 Sobre o montante da quantia devida e"
         "nao paga, incidirao, alem da correcao monetaria, com base no  INPC/IBGE,"
         " juros"
         SKIP
         "moratorios e compensatorios a base do que preceitua o atr. 406, do"
         "Codigo Civil Brasileiro (Lei n."
         "10.406, de  10/01/2002),  ao  mes,"
         SKIP
         "vigente entre a data da mora ate a data do efetivo pagamento, multa"
         "contratual de 2% (dois por cento), sobre  o  montante  apurado  e"
         SKIP
         "impostos que incidam ou venham a incidir sobre  a  operacao  contratada,"
         " devendo  o(a)  \033\107Cooperado(a)\033\110  e  seus"
         " \033\107Coobrigados\033\110,  efetuar"
         SKIP
         "imediatamente o pagamento do montante do debito apurado, sob pena de"
         "serem demandados judicialmente."
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_15.
         
         
    FORM "\033\10716) DOS EFEITOS DO CONTRATO:\033\110 Este contrato obriga a"
         "\033\107Cooperativa\033\110, o(a) \033\107Cooperado(a)\033\110,  e  o(s)"
         " \033\107Fiador(es)\033\110,  ao  fiel  cumprimento  das"
         SKIP
         "clausulas e condicoes estabelecidas no mesmo, sendo  celebrado  em"
         " carater  irrevogavel  e  irretratavel,  obrigando,  tambem,  seus"
         SKIP
         "herdeiros, cessionarios e sucessores, a qualquer titulo."
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_16.
         
    FORM "\033\10717) DA LIBERACAO DE INFORMACOES AO BANCO CENTRAL:\033\110"
         " O(a) \033\107Cooperado(a)\033\110 e o(s) \033\107Fiador(es)\033\110,"
         "autorizam desde ja a \033\107Cooperativa\033\110 a transmitir"
         SKIP
         "ao Banco Central do Brasil, informacoes inerentes as operacoes do"
         "presente contrato, com intuito de alimentar o  Sistema  Central  de"
         SKIP
         "Risco - SCR daquela instituicao, sendo passivel o seu acesso por outras"
         "instituicoes financeiras."
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_17.
              
    FORM "\033\10718) DO VINCULO COOPERATIVO:\033\110"
         "As partes declaram que o presente instrumento esta tambem vinculado as"
         "disposicoes legais que  regulam  o"
         SKIP
         "cooperativismo, o estatuto social da"
         "\033\107Cooperativa\033\110, as deliberacoes assembleares desta e as"
         " do  seu  Conselho  de  Administracao,  aos"
         SKIP
         "quais o(a) \033\107Cooperado(a)\033\110 livre e espontaneamente aderiu"
         "ao integrar o quadro social da Cooperativa, e cujo teor as  partes "
         "ratificam,"
         SKIP
         "reconhecendo-se nesta operacao a celebracao de um ATO COOPERATIVO."
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_18.
         
    FORM "\033\10719) DO FORO:\033\110 As partes, de comum acordo, elegem o foro"
         "da Comarca do domicilio do(a) \033\107Cooperado(a)\033\110, com exclusao"
         " de  qualquer  outro,"
         SKIP
         "por mais privilegiado que seja, para dirimir quaisquer questoes"
         "resultantes do presente contrato."
         SKIP(1)
         "E assim, por se acharem justos e contratados, assinam o presente"
         "contrato, em 02 (duas) vias de igual teor e forma,  na  presenca  de"
         SKIP
         "duas testemunhas abaixo, que, estando cientes, tambem assinam, para que"
         "produza os devidos e legais efeitos."
         SKIP(1)
         tt-ctr_bb.nmcidadec
         tt-ctr_bb.dsemsctr FORMAT "X(25)"
         "."
         SKIP(3)
         "__________________________________________________"
         "____________________________________________________________"    AT 68
         SKIP
         "\033\107Cooperado(a)\033\110"
         tt-ctr_bb.nmextcop                                                AT 72
         "- Pa "                        
         tt-ctr_bb.cdagenci
         WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 150 NO-ATTR-SPACE FRAME f_topico_19.
         
    FORM "__________________________________________________"
         "__________________________________________________"       AT 80
         SKIP(1)
         "Fiador 1: ________________________________________"       
         "Conjuge Fiador 1: ________________________________"       AT 80
         SKIP(1)
         "CPF: _________________________"
         "CPF: _________________________"                           AT 80
         SKIP(3)
         "__________________________________________________"
         "__________________________________________________"       AT 80
         SKIP(1)
         "Fiador 2: ________________________________________"
         "Conjuge Fiador 2: ________________________________"       AT 80
         SKIP(1)
         "CPF: _________________________"
         "CPF: _________________________"                           AT 80
         SKIP(3)
         "__________________________________________________"
         "__________________________________________________"       AT 80
         SKIP(1)
         "Testemunha 1: ____________________________________"
         "Testemunha 2: ____________________________________"       AT 80
         SKIP(1)
         "CPF/MF: _________________________"
         "CPF/MF: _________________________"                        AT 80
         SKIP(1)
         "CI: _____________________________"
         "CI: _____________________________"                        AT 80
         SKIP(3)
         "__________________________________________________"       AT 80
         SKIP
         "Operador:"                                                AT 80
         tt-ctr_bb.nmoperad FORMAT "X(25)"
         SKIP(1)
         WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 150 NO-ATTR-SPACE FRAME f_topico_20.
    /* instânciando BO */
    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028. 

    IF  NOT VALID-HANDLE(h_b1wgen0028) THEN
        DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO " +
                                  "b1wgen0028.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
        END.
                                 
    RUN impressoes_cartoes IN h_b1wgen0028(INPUT par_cdcooper,
                                           INPUT par_cdagenci, 
                                           INPUT par_nrdcaixa, 
                                           INPUT par_cdoperad, 
                                           INPUT par_nmdatela, 
                                           INPUT par_idorigem, 
                                           INPUT par_nrdconta, 
                                           INPUT par_idseqttl, 
                                           INPUT par_dtmvtolt, 
                                           INPUT par_dtmvtopr,
                                           INPUT par_inproces,
                                           INPUT 7,  /* par_idimpres */
                                           INPUT par_nrctrcrd, 
                                           INPUT par_flgerlog,
                                           INPUT par_flgimpnp, 
                                           INPUT par_cdmotivo,

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
            RETURN "NOK".
        END.

   FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

   UNIX SILENT VALUE("rm /usr/coop/" + crapcop.dsdircop + 
                     "/rl/" + par_nmendter + "* 2> /dev/null").

   ASSIGN par_nmarqimp = "/usr/coop/" + crapcop.dsdircop + 
                         "/rl/" + par_nmendter + STRING(TIME) + ".ex"
          par_nmarqpdf = "/usr/coop/" + crapcop.dsdircop + 
                         "/rl/" + par_nmendter + STRING(TIME) + ".pdf".
   

   OUTPUT STREAM str_1 TO VALUE(par_nmarqimp) PAGED PAGE-SIZE 84.
   
   FIND FIRST tt-ctr_bb NO-LOCK NO-ERROR.  /* Procura na TempTable */
   
   IF NOT AVAIL tt-ctr_bb THEN 
      RETURN "NOK".

   DISPLAY STREAM str_1
           tt-ctr_bb.nmcartao
           WITH FRAME f_titulo.
    
   DISPLAY STREAM str_1
            tt-ctr_bb.nmextcop   tt-ctr_bb.nmrescop   tt-ctr_bb.nrdocnpj
            tt-ctr_bb.dsendcop   tt-ctr_bb.nrendcop   tt-ctr_bb.nmbairroc
            tt-ctr_bb.nmcidadec  tt-ctr_bb.cdufdcop   tt-ctr_bb.nmprimtl
            tt-ctr_bb.nrcpfcgc   tt-ctr_bb.nrdconta   tt-ctr_bb.nrdctitg
            tt-ctr_bb.dsendere   tt-ctr_bb.nrendere   tt-ctr_bb.nmbairro
            tt-ctr_bb.nmcidade   tt-ctr_bb.cdufende   tt-ctr_bb.nrcepend
            WITH FRAME f_topico_1.
                          
    DISPLAY STREAM str_1 WITH FRAME f_topico_2.
    DISPLAY STREAM str_1 WITH FRAME f_topico_3.
    DISPLAY STREAM str_1 WITH FRAME f_topico_4.
    DISPLAY STREAM str_1 WITH FRAME f_topico_5.
    DISPLAY STREAM str_1 WITH FRAME f_topico_6.
    DISPLAY STREAM str_1 WITH FRAME f_topico_7.

    PAGE STREAM str_1.  /* quebra de pagina */
    
    DISPLAY STREAM str_1
            tt-ctr_bb.nmcartao
            WITH FRAME f_titulo.
    
    DISPLAY STREAM str_1 WITH FRAME f_topico_7_1.
            
    DISPLAY STREAM str_1 WITH FRAME f_topico_8.
    DISPLAY STREAM str_1 WITH FRAME f_topico_9.
    DISPLAY STREAM str_1 WITH FRAME f_topico_10.
    DISPLAY STREAM str_1 WITH FRAME f_topico_11.
    DISPLAY STREAM str_1 WITH FRAME f_topico_12.
    DISPLAY STREAM str_1 WITH FRAME f_topico_13.
    DISPLAY STREAM str_1 WITH FRAME f_topico_14.
    DISPLAY STREAM str_1 WITH FRAME f_topico_15.
    DISPLAY STREAM str_1 WITH FRAME f_topico_16.
    DISPLAY STREAM str_1 WITH FRAME f_topico_17.
    DISPLAY STREAM str_1 WITH FRAME f_topico_18.

    PAGE STREAM str_1.  /* quebra de pagina */
    
    DISPLAY STREAM str_1
            tt-ctr_bb.nmcartao
            WITH FRAME f_titulo.
    
    DISPLAY STREAM str_1 
            tt-ctr_bb.nmcidadec
            tt-ctr_bb.dsemsctr
            tt-ctr_bb.nmextcop
            tt-ctr_bb.cdagenci
            WITH FRAME f_topico_19.
            
    PAGE STREAM str_1.  /* quebra de pagina */
    
    DISPLAY STREAM str_1
            tt-ctr_bb.nmcartao
            WITH FRAME f_titulo.
            
    DISPLAY STREAM str_1 tt-ctr_bb.nmoperad     WITH FRAME f_topico_20.
    
    /** Tratamento da impressao da nota promissoria **/        
    IF   NOT par_flgimp2v   THEN
         DO:
             EMPTY TEMP-TABLE tt_dados_promissoria.
             
             CREATE tt_dados_promissoria.
             ASSIGN tt_dados_promissoria.dsemsctr = tt-ctr_bb.dsemsctr
                    tt_dados_promissoria.dsctrcrd = tt-ctr_bb.dsctrcrd
                    tt_dados_promissoria.dsdmoeda = tt-ctr_bb.dsdmoeda
                    tt_dados_promissoria.vllimite = tt-ctr_bb.vllimite
                    tt_dados_promissoria.dsdtmvt1 = tt-ctr_bb.dsdtmvt1
                    tt_dados_promissoria.dsdtmvt2 = tt-ctr_bb.dsdtmvt2
                    tt_dados_promissoria.nmextcop = tt-ctr_bb.nmextcop
                    tt_dados_promissoria.nmrescop = tt-ctr_bb.nmrescop
                    tt_dados_promissoria.dsvlnpr1 = tt-ctr_bb.dsvlnpr1
                    tt_dados_promissoria.dsvlnpr2 = tt-ctr_bb.dsvlnpr2
                    tt_dados_promissoria.nmcidpac = tt-ctr_bb.nmcidpac
                    tt_dados_promissoria.nmprimtl = tt-ctr_bb.nmprimtl
                    tt_dados_promissoria.dscpfcgc = tt-ctr_bb.dscpfcgc
                    tt_dados_promissoria.nrdconta = tt-ctr_bb.nrdconta
                    tt_dados_promissoria.endeass1 = tt-ctr_bb.endeass1
                    tt_dados_promissoria.endeass2 = tt-ctr_bb.endeass2
                    tt_dados_promissoria.nmcidade = tt-ctr_bb.nmcidade
                    tt_dados_promissoria.dsmvtolt = tt-ctr_bb.dsemsdnp.
                    
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
             
             RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT SET h_b1wgen0028.

             RUN gera_impressao_promissoria IN h_b1wgen0028 (INPUT par_cdcooper,
                                                            INPUT  TABLE tt_dados_promissoria,
                                                            OUTPUT TABLE tt-erro).
            
             DELETE PROCEDURE h_b1wgen0028. 
                                          
         END.
    
    /** Fim - Tratamento da impressao da nota promissoria **/
    
    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "".

             DO WHILE TRUE:

                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                     SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                         ASSIGN aux_dscritic = "Handle invalido para BO " +
                                               "b1wgen0024.".
                         LEAVE.
                    END.

                RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT par_nmarqimp,
                                                        INPUT par_nmarqpdf).
                 
                /** Copiar pdf para visualizacao no Ayllos WEB **/
                IF  SEARCH(par_nmarqpdf) = ?  THEN
                    DO:
                         ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                               " a impressao.".
                         LEAVE.                      
                    END.
                 
                RUN envia-arquivo-web 
                    IN h-b1wgen0024 (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT par_nmarqimp,
                                     OUTPUT par_nmarqpdf,
                                     OUTPUT TABLE tt-erro).

                LEAVE.

             END. /** Fim do DO WHILE TRUE **/

             IF  VALID-HANDLE(h-b1wgen0024)  THEN
                 DELETE PROCEDURE h-b1wgen0024.
            
             IF  aux_dscritic <> ""  THEN
                 DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.

                     IF  NOT AVAILABLE tt-erro  THEN
                         RUN gera_erro (INPUT par_cdcooper,
                                        INPUT 0,
                                        INPUT 0,
                                        INPUT 1,            /** Sequencia **/
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).

                     UNIX SILENT VALUE ("rm " + par_nmendter + "* 2>/dev/null").

                     RETURN "NOK".

                 END.

             UNIX SILENT VALUE ("rm " + par_nmendter + "* 2>/dev/null").

        END.                                                                      
                                                      
    RETURN "OK".
              
END PROCEDURE. 


PROCEDURE gera_impressao_promissoria:

    DEF INPUT  PARAM par_cdcooper AS INTE                                NO-UNDO.
    DEF INPUT  PARAM TABLE FOR tt_dados_promissoria_imp.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF        VAR rel_dsqtdava AS CHAR                                  NO-UNDO.
    DEF        VAR aux_nmcooper AS CHAR                                  NO-UNDO.
    DEF        VAR aux_tracoope AS CHAR                                  NO-UNDO.
    DEF        VAR aux_dsciddat AS CHAR                                  NO-UNDO.
    DEF        VAR aux_tamtexto AS INTE                                  NO-UNDO.

    /*** Eder (GATI) 03/06/2009 quarta versao ***/
    FORM SKIP(1)
         "\024\022\033\120" /* reseta impressora */
         "\0330\033x0\033\017"
         "\033\016    NOTA PROMISSORIA VINCULADA AO"
         "\024\022\033\120" /* reseta impressora */
         "\0332\033x0"
         " Vencimento:"
         tt_dados_promissoria_imp.dsmvtolt          FORMAT "x(23)"
         SKIP
         "\0330\033x0\033\017"
         "\033\016     CONTRATO DE CARTAO DE CREDITO"
         "\024\022\033\120" /* reseta impressora */
         SKIP(1)
         "NUMERO"                         AT 7  "\033\016" 
         tt_dados_promissoria_imp.dsctrcrd          FORMAT "x(13)" "\024"
         tt_dados_promissoria_imp.dsdmoeda          FORMAT "x(5)" "\033\016"
         tt_dados_promissoria_imp.vllimite          FORMAT "zzz,zzz,zz9.99" "\033\016"
         SKIP(1)
         "Ao(s)"                          AT 7 
         tt_dados_promissoria_imp.dsdtmvt1          FORMAT "x(68)"      SKIP
         tt_dados_promissoria_imp.dsdtmvt2    AT 7  FORMAT "x(44)" 
         "pagarei por esta unica via de" SKIP
         "\033\016N O T A  P R O M I S S O R I A\024" AT 7 "a" 
         aux_nmcooper                     AT 7  FORMAT "x(74)"
         "ou a sua ordem a quantia de"    AT 7
         tt_dados_promissoria_imp.dsvlnpr1    AT 35 FORMAT "x(46)"      SKIP
         tt_dados_promissoria_imp.dsvlnpr2    AT 7  FORMAT "x(74)"      SKIP
         "em moeda corrente deste pais."  AT 7                      SKIP(1)
         aux_dsciddat                     AT 7  FORMAT "x(50)" SKIP(1)
         /*tt_dados_promissoria_imp.nmcidpac    TO 113  FORMAT "x(33)"
         tt_dados_promissoria_imp.dsemsctr TO 137 FORMAT "x(33)"      SKIP(1)*/
         tt_dados_promissoria_imp.nmprimtl    AT 7  FORMAT "x(50)"      SKIP
         tt_dados_promissoria_imp.dscpfcgc    AT 7  FORMAT "x(40)" 
         "______________________________" AT 50                     SKIP 
         "Conta/dv:"                      AT 7 
         tt_dados_promissoria_imp.nrdconta          FORMAT "zzzz,zzz,9" 
         "Assinatura"                     AT 50                     SKIP(1)
         "Endereco:"                      AT 7                      SKIP
         tt_dados_promissoria_imp.endeass1    AT 7  FORMAT "x(73)"      SKIP
         tt_dados_promissoria_imp.endeass2    AT 7  FORMAT "x(86)"      SKIP(1)
         WITH NO-BOX NO-LABELS DOWN WIDTH 137 FRAME f_promissoria.
    /************************/

    FORM rel_dsqtdava                               AT 7  FORMAT "x(10)" 
         "Conjuge:"                                 AT 56                SKIP(2)
         "\022\033\115"                             AT 7
         "----------------------------------------" 
         "----------------------------------------" AT 59
         tt_dados_promissoria_imp.nmdaval1              AT 08 FORMAT "x(40)"
         tt_dados_promissoria_imp.nmdcjav1              AT 56 FORMAT "x(40)" SKIP
         tt_dados_promissoria_imp.dscpfav1              AT 08 FORMAT "x(40)"
         tt_dados_promissoria_imp.dscfcav1              AT 56 FORMAT "x(40)" SKIP
         tt_dados_promissoria_imp.dsendav1[1]           AT 08 FORMAT "x(40)" SKIP
         tt_dados_promissoria_imp.dsendav1[2]           AT 08 FORMAT "x(40)" SKIP 
         tt_dados_promissoria_imp.dsendav1[3]           AT 08 FORMAT "x(40)" SKIP(3)
         WITH NO-BOX NO-LABELS DOWN WIDTH 137 FRAME f_promis_aval1.

    FORM "----------------------------------------" AT 08
         "----------------------------------------" AT 56
         tt_dados_promissoria_imp.nmdaval2              AT 08 FORMAT "x(40)"
         tt_dados_promissoria_imp.nmdcjav2              AT 56 FORMAT "x(40)" SKIP
         tt_dados_promissoria_imp.dscpfav2              AT 08 FORMAT "x(40)"
         tt_dados_promissoria_imp.dscfcav2              AT 56 FORMAT "x(40)" SKIP
         tt_dados_promissoria_imp.dsendav2[1]           AT 08 FORMAT "x(40)" SKIP
         tt_dados_promissoria_imp.dsendav2[2]           AT 08 FORMAT "x(40)" SKIP
         tt_dados_promissoria_imp.dsendav2[3]           AT 08 FORMAT "x(40)" SKIP(1)
         WITH NO-BOX NO-LABELS DOWN WIDTH 137 FRAME f_promis_aval2.

    FORM SKIP(5)
         WITH NO-BOX WIDTH 137 FRAME f_linhas.

    FIND tt_dados_promissoria_imp NO-ERROR.
    IF   NOT AVAIL tt_dados_promissoria_imp   THEN
         DO:

            ASSIGN aux_cdcritic = 535
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

         END.

    ASSIGN aux_tamtexto = 0
           aux_tracoope = FILL("*",70)
           aux_nmcooper = tt_dados_promissoria_imp.nmextcop + " - " +
                          tt_dados_promissoria_imp.nmrescop.

    IF  LENGTH(aux_nmcooper) > 79 THEN
        ASSIGN aux_tamtexto = 79.
    ELSE
        ASSIGN aux_tamtexto = LENGTH(aux_nmcooper).

    ASSIGN aux_nmcooper = aux_nmcooper + " " + 
                          SUBSTR(aux_tracoope,1,79 - aux_tamtexto)
           aux_dsciddat = TRIM(tt_dados_promissoria_imp.nmcidpac) + ", " + 
                          TRIM(tt_dados_promissoria_imp.dsemsctr).


    PAGE STREAM str_1.

    PUT STREAM str_1 CONTROL "\0330\033x0\022\033\120" NULL.

    DISPLAY STREAM str_1
            tt_dados_promissoria_imp.dsmvtolt   tt_dados_promissoria_imp.dsctrcrd
            tt_dados_promissoria_imp.dsdmoeda   tt_dados_promissoria_imp.vllimite
            tt_dados_promissoria_imp.dsdtmvt1   tt_dados_promissoria_imp.dsdtmvt2 
            aux_nmcooper                        tt_dados_promissoria_imp.dsvlnpr1
            tt_dados_promissoria_imp.dsvlnpr2   
            aux_dsciddat                        tt_dados_promissoria_imp.nmprimtl  
            tt_dados_promissoria_imp.dscpfcgc   tt_dados_promissoria_imp.nrdconta
            tt_dados_promissoria_imp.endeass1   tt_dados_promissoria_imp.endeass2  
            WITH FRAME f_promissoria.

    DOWN STREAM str_1 WITH FRAME f_promissoria.


    IF   tt_dados_promissoria_imp.nmdaval1 <> ""   THEN
         DO:
             IF   tt_dados_promissoria_imp.nmdaval2 <> ""   THEN
                  ASSIGN rel_dsqtdava = "Avalistas:".
             ELSE
                  ASSIGN rel_dsqtdava = "Avalista:".

             DISPLAY STREAM str_1  
                     rel_dsqtdava
                     tt_dados_promissoria_imp.nmdaval1   tt_dados_promissoria_imp.dscpfav1  
                     tt_dados_promissoria_imp.nmdcjav1   tt_dados_promissoria_imp.dscfcav1
                     tt_dados_promissoria_imp.dsendav1[1]
                     tt_dados_promissoria_imp.dsendav1[2]
                     tt_dados_promissoria_imp.dsendav1[3]
                     WITH FRAME f_promis_aval1.
             DOWN STREAM str_1 WITH FRAME f_promis_aval1.
         END.

    IF   tt_dados_promissoria_imp.nmdaval2 <> ""   THEN         
         DO:
             DISPLAY STREAM str_1
                     tt_dados_promissoria_imp.nmdaval2      tt_dados_promissoria_imp.dscpfav2
                     tt_dados_promissoria_imp.nmdcjav2      tt_dados_promissoria_imp.dscfcav2
                     tt_dados_promissoria_imp.dsendav2[1]
                     tt_dados_promissoria_imp.dsendav2[2] 
                     tt_dados_promissoria_imp.dsendav2[3]
                     WITH FRAME f_promis_aval2.
             DOWN STREAM str_1 WITH FRAME f_promis_aval2.
         END.

    VIEW STREAM str_1 FRAME f_linhas.


END PROCEDURE.

PROCEDURE gera_impressao_entrega_carta:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.       
    DEF  INPUT PARAM par_nrctrcrd AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO. 

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF   VAR aux_nmprimtl     AS CHAR                                   NO-UNDO.
    DEF   VAR aux_nmarqimp     AS CHAR                                   NO-UNDO.

    DEF   VAR aux_nmarquiv     AS CHAR                                   NO-UNDO.
    DEF   VAR aux_nmarqpdf     AS CHAR                                   NO-UNDO.

    DEF   VAR aux_nomesoli     AS CHAR FORMAT "x(40)"                    NO-UNDO.

    DEF   VAR h-b1wgen9999     AS HANDLE                                 NO-UNDO.
    DEF   VAR h-b1wgen0024     AS HANDLE                                 NO-UNDO.
                    
    DEFINE VARIABLE aux_desclin1 AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_desclin2 AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    
    DEFINE VARIABLE aux_retor1 AS CHARACTER FORMAT "x(133)"  NO-UNDO.
    DEFINE VARIABLE aux_retor2 AS CHARACTER FORMAT "x(133)"  NO-UNDO.
    DEFINE VARIABLE aux_retor3 AS CHARACTER FORMAT "x(133)"  NO-UNDO.
    DEFINE VARIABLE aux_retor4 AS CHARACTER FORMAT "x(133)"  NO-UNDO.
    DEFINE VARIABLE aux_retor5 AS CHARACTER FORMAT "x(133)"  NO-UNDO.
    DEFINE VARIABLE aux_retor6 AS CHARACTER FORMAT "x(133)"  NO-UNDO.
    DEFINE VARIABLE aux_retor7 AS CHARACTER FORMAT "x(133)"  NO-UNDO.
    DEFINE VARIABLE aux_retor8 AS CHARACTER FORMAT "x(133)"  NO-UNDO.
    DEFINE VARIABLE aux_nrcpfcgc AS CHAR FORMAT "x(15)"      NO-UNDO.

    DEF VAR aux_dsmesref AS CHAR INIT
                         ["Janeiro,Fevereiro,Marco,Abril,Maio,Junho,
                          Julho,Agosto,Setembro,Outubro,Novembro,Dezembro"]
                                        NO-UNDO.   

    DEF VAR aux_dsemsctr AS CHAR        NO-UNDO.

    
    FORM SKIP
         "\033\107 TERMO DE ENTREGA DE CARTAO DE CREDITO \033\110 " AT 48 SKIP(2) 
         aux_retor1
         aux_retor2
         aux_retor3
         aux_retor4
         aux_desclin2 SKIP(1)

         "Titular do Cartao: " tt-termo-entreg-pj.nmtitcrd SKIP
         "CPF: " tt-termo-entreg-pj.nrcpftit  FORMAT "999,999,999,99" SKIP
         "N. do Cartao de Credito: "  tt-termo-entreg-pj.nrcrcard SKIP(2)
         tt-termo-entreg-pj.dsemsctr SKIP(4)
         "__________________________________________________      __________________________________________________" SKIP
         tt-termo-entreg-pj.nome  
         tt-termo-entreg-pj.nmextcop AT 57 SKIP
         aux_nomesoli

        WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_entrega_pj.

        /*  utiliza o handle da bo 028 que ja esta na memoria.*/
        ASSIGN h-b1wgen0028 = SOURCE-PROCEDURE.
    
        IF  NOT VALID-HANDLE(h-b1wgen0028) THEN
            DO:
    
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO " +
                                      "b1wgen0028.".
    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
        
                RETURN "NOK".
        
            END.

        RUN impressoes_cartoes IN h-b1wgen0028( INPUT  par_cdcooper,
                                                INPUT  0,
                                                INPUT  0,
                                                INPUT  par_cdoperad,
                                                INPUT  par_nmdatela,
                                                INPUT  1,
                                                INPUT  par_nrdconta,
                                                INPUT  1,
                                                INPUT  par_dtmvtolt,
                                                INPUT  par_dtmvtopr,
                                                INPUT  par_inproces,
                                                INPUT  9, /* entrega cartao */
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
        
        FIND FIRST tt-termo-entreg-pj NO-LOCK NO-ERROR.

        
        FIND FIRST crapcop WHERE 
                   crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                          par_dsiduser.
    
        UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
     
        ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
               aux_nmarqimp = aux_nmarquiv + ".ex"
               aux_nmarqpdf = aux_nmarquiv + ".pdf".

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

        ASSIGN aux_nrcpfcgc = string(tt-termo-entreg-pj.nrrepent,"99999999999")
               aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
    
                             
        ASSIGN aux_desclin1 = tt-termo-entreg-pj.nome + ", pessoa juridica de direito privado, inscrita no CNPJ sob n. " + string(tt-termo-entreg-pj.cnpj,"zz,zzz,zzz,zzzz,zz") + ", com sede na Rua " +                                                                                                                 
                              tt-termo-entreg-pj.dsendere + ", n. " + string(tt-termo-entreg-pj.nrendere) + ", Bairro " + tt-termo-entreg-pj.nmbairro + ", CEP " + string(tt-termo-entreg-pj.nrcepend,"zz,zzz,zz9") + ", na cidade de " + tt-termo-entreg-pj.nmcidade + ", Estado de " + tt-termo-entreg-pj.cdufende + ", representada" +
                              " neste ato na forma do estabelecido no Contrato Para Utilizacao de Cartao de Credito CECRED/VISA Pessoa Juridica, na pessoa do(a) Sr(a) " + string(tt-termo-entreg-pj.nmrepsol) + ", inscrito no CPF/MF sob n. " + aux_nrcpfcgc + ", declara que neste ato recebeu da Cooperativa " + 
                              string(tt-termo-entreg-pj.nmrescop) + ", Inscrita no CNPJ/MF sob n. " 
               aux_desclin2 = string(tt-termo-entreg-pj.nrdocnpj,"zz,zzz,zzz,zzzz,zz") + ", o cartao de credito empresarial do seguinte portador:"
               
            
               aux_nomesoli =  tt-termo-entreg-pj.nmrepsol.

        RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

        IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT 0,
                               INPUT 0,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                             
                RETURN "NOK".
            END.

        RUN quebra-str IN h-b1wgen9999 ( INPUT aux_desclin1,
                                         INPUT 133, INPUT 133,
                                         INPUT 133, INPUT 133,
                                        OUTPUT aux_retor1,
                                        OUTPUT aux_retor2,
                                        OUTPUT aux_retor3,
                                        OUTPUT aux_retor4).

        DELETE PROCEDURE h-b1wgen9999. 
        
        FIND FIRST crawcrd 
            WHERE crawcrd.cdcooper = par_cdcooper 
              AND crawcrd.nrdconta = par_nrdconta 
              AND crawcrd.nrctrcrd = par_nrctrcrd  NO-LOCK NO-ERROR.


        DISPLAY STREAM str_1
                aux_retor1        
                aux_retor2
                aux_retor3
                aux_retor4
                aux_desclin2
                tt-termo-entreg-pj.nmtitcrd
                tt-termo-entreg-pj.nrcpftit
                tt-termo-entreg-pj.dsemsctr 
                tt-termo-entreg-pj.nrcrcard
                tt-termo-entreg-pj.nome
                tt-termo-entreg-pj.nmextcop
                aux_nomesoli
            WITH FRAME f_entrega_pj.

     OUTPUT STREAM str_1 CLOSE.

     IF  par_idorigem = 5  THEN  /** Ayllos Web **/
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "".

             DO WHILE TRUE:

                 RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                     SET h-b1wgen0024.

                 IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                     DO:
                         ASSIGN aux_dscritic = "Handle invalido para BO " +
                                               "b1wgen0024.".
                         LEAVE.
                     END.

                 RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                         INPUT aux_nmarqpdf).

                 /** Copiar pdf para visualizacao no Ayllos WEB **/
                 IF  SEARCH(aux_nmarqpdf) = ?  THEN
                     DO:
                         ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                               " a impressao.".
                         LEAVE.                      
                     END.

                 UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                    '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                                    ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                                    '/temp/" 2>/dev/null').

                 LEAVE.

             END. /** Fim do DO WHILE TRUE **/

             IF  VALID-HANDLE(h-b1wgen0024)  THEN
                 DELETE PROCEDURE h-b1wgen0024.

             IF  aux_dscritic <> ""  THEN
                 DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.

                     IF  NOT AVAILABLE tt-erro  THEN
                         RUN gera_erro (INPUT par_cdcooper,
                                        INPUT 0,
                                        INPUT 0,
                                        INPUT 1,            /** Sequencia **/
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).

                     UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

                     RETURN "NOK".
                 END.

             UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

        END.                                                                      
                                                      
     ASSIGN par_nmarqimp = aux_nmarqimp
            par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").
            
     RETURN "ok".

END PROCEDURE.

PROCEDURE gera_impressao_emissao_cartao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrcrd AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen9999          AS HANDLE                      NO-UNDO.
    DEF VAR h-b1wgen0024          AS HANDLE                      NO-UNDO.
    DEF VAR aux_nmprimtl          AS CHAR                        NO-UNDO.
    DEF VAR aux_dsrepinc          AS CHAR                        NO-UNDO.
    DEF VAR aux_nmarqimp          AS CHAR                        NO-UNDO.
    DEF VAR aux_nmarquiv          AS CHAR                        NO-UNDO.
    DEF VAR aux_nmarqpdf          AS CHAR                        NO-UNDO.

    DEF VAR aux_dslinhax          AS CHAR                        NO-UNDO.
    DEF VAR aux_dsstring          AS CHAR                        NO-UNDO.
    DEF VAR rel_dslinha1          AS CHAR                        NO-UNDO.
    DEF VAR rel_dslinha2          AS CHAR                        NO-UNDO.
    DEF VAR rel_dslinha3          AS CHAR                        NO-UNDO.
    DEF VAR rel_dslinha4          AS CHAR                        NO-UNDO.
    DEF VAR rel_dslinha5          AS CHAR                        NO-UNDO.
    DEF VAR rel_dslinha6          AS CHAR                        NO-UNDO.
    DEF VAR rel_dslinha7          AS CHAR                        NO-UNDO.
    DEF VAR rel_dslinha8          AS CHAR                        NO-UNDO.
    DEF VAR rel_dsemsprp          AS CHAR                        NO-UNDO.

    FORM "\022\024\033\120\0330\033x0\033\105"  /* Reseta impressora */
         SKIP
         "PROPOSTA PARA EMISSAO DE CARTAO DE CREDITO" 
         SKIP(1)
         "CONTRATO PESSOA JURIDICA" AT 27
         SKIP(1)
         "Numero Da Proposta:\033\120\033\106"      AT 50 par_nrctrcrd FORMAT "zzz,zzz,zz9"    
         SKIP(3)
         "\0330\033x0\033\017"
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_titulo_pj.

    FORM "\033\1071.  DA IDENTIFICACAO:\033\110"
         SKIP
         rel_dslinha1 FORMAT "x(154)"
         SKIP
         rel_dslinha2 FORMAT "x(154)"
         SKIP
         rel_dslinha3 FORMAT "x(154)"
         SKIP
         rel_dslinha4 FORMAT "x(154)"
         SKIP
         rel_dslinha5 FORMAT "x(154)"
         SKIP
         rel_dslinha6 FORMAT "x(154)"
         SKIP(1)
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 154 NO-LABELS NO-BOX FRAME f_topico_1_pj.

    FORM "\033\107DAS DECLARACOES E DO PEDIDO DE EMISSAO DE CARTAO\033\110"
         SKIP
         "a) Declaram as partes, abaixo assinadas, que a \033\107Cooperada\033\110, na pessoa de seus representantes legais, propoe e a \033\107Cooperativa\033\110 aceita que,"
         SKIP
         "nos  termos  do  Contrato  Corporativo para Utilizacao de Cartao de Credito CECRED/VISA, seja fornecido cartao de credito corporativo"
         SKIP
         "para a pessoa abaixo qualificada."
         SKIP
         "b) Declara a \033\107Cooperada\033\110 que se responsabiliza pelas informacoes pertinentes ao portador do cartao, assim como ao pagamento das faturas"
         SKIP
         "pertinentes aos valores utilizados por este, cujos pagamentos se compromete a efetuar ate a data do vencimento;"
         SKIP
         "c) Os valores das faturas deverao ser debitados na conta corrente indicada no contrato;"
         SKIP
         "d) A \033\107Cooperada\033\110 autoriza a emissao de cartao ao beneficiario abaixo:"
         SKIP(1)
         "Nome do representante solicitante:" tt-dados_prp_emiss_ccr.dsrepinc FORMAT "x(40)"
         SKIP
         "Nome da cooperada:" tt-dados_prp_emiss_ccr.nmprimtl FORMAT "x(40)"
         SKIP
         "Titular do cartao:" tt-dados_prp_emiss_ccr.nmtitcrd FORMAT "x(40)"
         SKIP
         "CPF:" tt-dados_prp_emiss_ccr.nrcpftit FORMAT "x(15)"
         SKIP
         "Data de Nascimento:" tt-dados_prp_emiss_ccr.dtnasctl
         SKIP
         "Limite do Cartao:" tt-dados_prp_emiss_ccr.vllimcrd FORMAT "zzz,zz9.99"
         SKIP
         "Dia de vencimento da fatura mensal do cartao:" tt-dados_prp_emiss_ccr.dddebito FORMAT ">9"
         SKIP(2)
         tt-dados_prp_emiss_ccr.dsemsctr FORMAT "X(50)"
         SKIP(3)
         "__________________________________________________"
         "__________________________________________________"       AT 80
         SKIP
         aux_nmprimtl   FORMAT "X(50)"
         tt-dados_prp_emiss_ccr.nmextcop   FORMAT "X(40)"           AT 80                
         SKIP
         aux_dsrepinc   FORMAT "X(40)"
         WITH COLUMN 5 NO-ATTR-SPACE WIDTH 150 NO-LABELS NO-BOX FRAME f_topico_2_pj.

    /*  utiliza o handle da bo 028 que ja esta na memoria.*/
    ASSIGN h-b1wgen0028 = SOURCE-PROCEDURE.

    IF  NOT VALID-HANDLE(h-b1wgen0028) THEN
        DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO " +
                                  "b1wgen0028.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
    
        END.

    RUN impressoes_cartoes IN h-b1wgen0028( INPUT  par_cdcooper,
                                            INPUT  0,
                                            INPUT  0,
                                            INPUT  par_cdoperad,
                                            INPUT  par_nmdatela,
                                            INPUT  1,
                                            INPUT  par_nrdconta,
                                            INPUT  1,
                                            INPUT  par_dtmvtolt,
                                            INPUT  par_dtmvtopr,
                                            INPUT  par_inproces,
                                            INPUT  10, /* Proposta emite cartao Visa Cecred - */
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

    IF  RETURN-VALUE = "NOK" THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
            IF  AVAIL tt-erro THEN
                RETURN "NOK".

        END.

    FIND tt-dados_prp_emiss_ccr NO-ERROR.
    IF  NOT AVAIL tt-dados_prp_emiss_ccr   THEN
        DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Nao foi possivel gerar a impressao.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.

    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                          par_dsiduser.
    
    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
     
    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

    ASSIGN aux_nmprimtl = tt-dados_prp_emiss_ccr.nmprimtl
           aux_dsrepinc = tt-dados_prp_emiss_ccr.dsrepinc.

    DISPLAY STREAM str_1 par_nrctrcrd
            WITH FRAME f_titulo_pj.


    ASSIGN aux_dslinhax  = "1.1. COOPERATIVA: " + tt-dados_prp_emiss_ccr.nmextcop + ", sociedade cooperativa de credito, de responsabilidade limitada," +
                           "regida pela legislacao vigente, normas baixadas pelo Conselho Monetario Nacional, pela regulamentacao estabelecida pelo Banco Central " +
                           "do Brasil e pelo seu estatuto social, arquivado na Junta Comercial do Estado de Santa Catarina, inscrita no CNPJ n. " +
                           tt-dados_prp_emiss_ccr.nrdocnpj + ", estabelecida a " + tt-dados_prp_emiss_ccr.dsendcop + ", n. " + 
                           TRIM(STRING(tt-dados_prp_emiss_ccr.nrendcop,"zzz,zz9")) + ", Bairro " + TRIM(tt-dados_prp_emiss_ccr.nmbairro) + ", " + 
                           TRIM(tt-dados_prp_emiss_ccr.nmcidade) + ", " + tt-dados_prp_emiss_ccr.cdufdcop + ".".


    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                             
             RETURN "NOK".
         END.

    RUN quebra-str IN h-b1wgen9999 ( INPUT aux_dslinhax,
                                     INPUT 133, INPUT 133, 
                                     INPUT 133, INPUT 133, 
                                    OUTPUT rel_dslinha1, 
                                    OUTPUT rel_dslinha2,
                                    OUTPUT rel_dslinha3, 
                                    OUTPUT rel_dslinha4).

    DELETE PROCEDURE h-b1wgen9999.

    ASSIGN aux_dslinhax  = "1.2. COOPERADA: " + tt-dados_prp_emiss_ccr.nmprimtl + ", CNPJ/MF n. " + tt-dados_prp_emiss_ccr.nrcpfcgc + ", Conta corrente: " + 
                            TRIM(STRING(tt-dados_prp_emiss_ccr.nrdconta,"zzzz,zzz,9")) + 
                            ", representada neste ato na forma do " + "estabelecido no Contrato Para Utilizacao de Cartao de Credito CECRED/VISA - Pessoa Juridica.".

   RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                             
             RETURN "NOK".
         END.

    RUN quebra-str IN h-b1wgen9999 ( INPUT aux_dslinhax,
                                     INPUT 133, INPUT 133, 
                                     INPUT 0, INPUT 0, 
                                    OUTPUT rel_dslinha5, 
                                    OUTPUT rel_dslinha6,
                                    OUTPUT rel_dslinha7, 
                                    OUTPUT rel_dslinha8).

    DELETE PROCEDURE h-b1wgen9999.

    ASSIGN rel_dslinha1 = REPLACE(rel_dslinha1,"1.1.","\033\1071.1.")
           rel_dslinha1 = REPLACE(rel_dslinha1,"COOPERATIVA:","COOPERATIVA:\033\110")
           rel_dslinha5 = REPLACE(rel_dslinha5,"1.2.","\033\1071.2.")            
           rel_dslinha5 = REPLACE(rel_dslinha5,"COOPERADA:","COOPERADA:\033\110").


    DISPLAY STREAM str_1
            rel_dslinha1
            rel_dslinha2
            rel_dslinha3
            rel_dslinha4
            rel_dslinha5
            rel_dslinha6
            WITH FRAME f_topico_1_pj.

    DISPLAY STREAM str_1
            tt-dados_prp_emiss_ccr.dsrepinc
            tt-dados_prp_emiss_ccr.nmprimtl
            tt-dados_prp_emiss_ccr.nmtitcrd
            tt-dados_prp_emiss_ccr.nrcpftit
            tt-dados_prp_emiss_ccr.dtnasctl        
            tt-dados_prp_emiss_ccr.vllimcrd
            tt-dados_prp_emiss_ccr.dddebito
            tt-dados_prp_emiss_ccr.dsemsctr
            aux_nmprimtl
            tt-dados_prp_emiss_ccr.nmextcop
            aux_dsrepinc
            WITH FRAME f_topico_2_pj.

    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            DO WHILE TRUE:

                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.
            
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE.
                    END.
                
                RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                        INPUT aux_nmarqpdf).
    
                /** Copiar pdf para visualizacao no Ayllos WEB **/
                IF  SEARCH(aux_nmarqpdf) = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                              " a impressao.".
                        LEAVE.                      
                    END.
                            
                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                   '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                                   ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                                   '/temp/" 2>/dev/null').
   
                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.
    
            IF  aux_dscritic <> ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-erro  THEN
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                                                       
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

                    RETURN "NOK".
                END.

            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
     
        END.                                                                      
                                                      
    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

    RETURN "OK".

END PROCEDURE.

PROCEDURE segunda_via_cartao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nrdconta AS INTE FORMAT "zzzz,zzz,9"       NO-UNDO.    
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrcrd AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.    

    DEF   VAR aux_nmendter     AS CHAR FORMAT "x(20)"                    NO-UNDO.
    DEF   VAR aux_nmarqimp     AS CHAR                                   NO-UNDO.

    DEF   VAR aux_nmarquiv     AS CHAR                                   NO-UNDO.
    DEF   VAR aux_nmarqpdf     AS CHAR                                   NO-UNDO.

    DEF   VAR h-b1wgen9999     AS HANDLE                            NO-UNDO.
    DEF   VAR h-b1wgen0024     AS HANDLE                                 NO-UNDO.

    DEFINE VARIABLE aux_retor1   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor2   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor3   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor4   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor5   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor6   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor7   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor8   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_nrcrcard AS DECI      FORMAT "9999,9999,9999,9999" NO-UNDO.
    DEF   VAR aux_nomesoli       AS CHAR FORMAT "x(40)"       NO-UNDO.
    DEFINE VARIABLE aux_desclin1 AS CHARACTER FORMAT "x(133)" NO-UNDO.
    DEFINE VARIABLE aux_desclin2 AS CHARACTER FORMAT "x(133)" NO-UNDO.
    DEFINE VARIABLE aux_tituloIm AS CHARACTER FORMAT "x(60)" NO-UNDO.
    DEF   VAR aux_nrcpfcgc       AS CHAR FORMAT "x(15)"       NO-UNDO.

    FORM aux_tituloIm AT 46 SKIP(2)
         WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_titulo.
    
    FORM aux_retor1
         aux_retor2
         aux_retor3
         aux_retor5
         aux_retor6 SKIP(1)
         "Conta: " par_nrdconta SKIP
         "Nome Cooperada:" tt-segvia-cartao.nmprimtl  SKIP
         "Nome Portador:" tt-segvia-cartao.nmtitcrd SKIP
         "CPF:" aux_nrcpfcgc SKIP
         "N. do Cartao de Credito:" tt-segvia-cartao.nrcrcard SKIP(2)
         tt-segvia-cartao.dsemsctr SKIP(4)   
         "__________________________________________________      __________________________________________________" SKIP
         tt-segvia-cartao.nome FORMAT "x(50)" 
         tt-segvia-cartao.nmextcop AT 57 SKIP
         tt-segvia-cartao.dsrepcar FORMAT "x(30)"
        WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_2via_cartao_pj.
   
    /*  utiliza o handle da bo 028 que ja esta na memoria.*/
    ASSIGN h-b1wgen0028 = SOURCE-PROCEDURE.

    IF  NOT VALID-HANDLE(h-b1wgen0028) THEN
        DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO " +
                                  "b1wgen0028.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
    
        END.

    RUN impressoes_cartoes IN h-b1wgen0028 ( INPUT  par_cdcooper,
                                             INPUT  0,
                                             INPUT  0,
                                             INPUT  par_cdoperad,
                                             INPUT  par_nmdatela,
                                             INPUT  1,
                                             INPUT  par_nrdconta,
                                             INPUT  1,
                                             INPUT  par_dtmvtolt,
                                             INPUT  01/01/9999, /*glb_dtmvtopr*/
                                             INPUT  1, /*glb_inproces*/
                                             INPUT  11, /* termo segunda via cartao pj */
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

    IF   RETURN-VALUE = "NOK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
             IF   AVAIL tt-erro   THEN
                  DO:
                      MESSAGE tt-erro.dscritic.
                      RETURN "NOK".
                  END.
         END.
    
    FIND tt-segvia-cartao     NO-ERROR.
    IF NOT AVAIL tt-segvia-cartao THEN
         RETURN "NOK".
    
    FIND FIRST crapcop WHERE
               crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                          par_dsiduser.

    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").

    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    ASSIGN aux_nrcpfcgc = string(tt-segvia-cartao.nrrepcar,"99999999999")
           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
    
    ASSIGN aux_desclin1 = tt-segvia-cartao.nome + ", pessoa juridica de direito privado, inscrita no CNPJ sob n. " + string(tt-segvia-cartao.cnpj,"zz,zzz,zzz,zzzz,zz") + ", com sede na Rua " +                                                                                                                 
                          tt-segvia-cartao.dsendere + ", n. " + string(tt-segvia-cartao.nrendere) + ", Bairro " + tt-segvia-cartao.nmbairro + ", CEP " + string(tt-segvia-cartao.nrcepend,"zz,zzz,zz9") + ", na cidade de " + tt-segvia-cartao.nmcidade + ", Estado de " + tt-segvia-cartao.cdufende + ", representada" +
                          " neste ato na forma do estabelecido no Contrato Para Utilizacao de Cartao de Credito CECRED/VISA Pessoa Juridica," 
           aux_nomesoli =  tt-segvia-cartao.nmrepsol.

    ASSIGN aux_tituloIm = "\033\107 SOLICITACAO DE SEGUNDA VIA DE CARTAO DE CREDITO \033\110"
           aux_desclin2 = "na pessoa do(a) Sr(a) " + string(tt-segvia-cartao.dsrepcar) + ", inscrito no CPF/MF sob n. " + aux_nrcpfcgc + ", solicita pela presente, a segunda via de cartao de credito CECRED/VISA, por motivo de " + tt-segvia-cartao.dsmotivo +
                          " para o seguinte portador:".

    ASSIGN aux_nrcpfcgc = string(tt-segvia-cartao.nrcpftit,"99999999999")
           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
     
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                             
           RETURN "NOK".
        END.

    RUN quebra-str IN h-b1wgen9999 ( INPUT aux_desclin1,
                                     INPUT 133, INPUT 133,
                                     INPUT 133, INPUT 0,
                                    OUTPUT aux_retor1,
                                    OUTPUT aux_retor2,
                                    OUTPUT aux_retor3,
                                    OUTPUT aux_retor4).

    DELETE PROCEDURE h-b1wgen9999.
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                             
             RETURN "NOK".
        END.

    RUN quebra-str IN h-b1wgen9999 ( INPUT aux_desclin2,
                                     INPUT 133, INPUT 133,
                                     INPUT 0, INPUT 0,
                                    OUTPUT aux_retor5,
                                    OUTPUT aux_retor6,
                                    OUTPUT aux_retor7,
                                    OUTPUT aux_retor8).


    DELETE PROCEDURE h-b1wgen9999.

    DISPLAY STREAM str_1
                   aux_tituloIm  WITH FRAME f_titulo.
          
    DISPLAY STREAM str_1
                   aux_retor1        
                   aux_retor2
                   aux_retor3
                   aux_retor5
                   aux_retor6
                   par_nrdconta 
                   tt-segvia-cartao.nmprimtl            
                   tt-segvia-cartao.nmtitcrd
                   aux_nrcpfcgc
                   tt-segvia-cartao.nrcrcard
                   tt-segvia-cartao.dsemsctr 
                   tt-segvia-cartao.nome
                   tt-segvia-cartao.nmextcop
                   tt-segvia-cartao.dsrepcar
                   WITH FRAME f_2via_cartao_pj.   

    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            DO WHILE TRUE:

                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.
            
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE.
                    END.
                
                RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                        INPUT aux_nmarqpdf).
    
                /** Copiar pdf para visualizacao no Ayllos WEB **/
                IF  SEARCH(aux_nmarqpdf) = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                              " a impressao.".
                        LEAVE.                      
                    END.
                            
                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                   '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                                   ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                                   '/temp/" 2>/dev/null').
   
                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.
    
            IF  aux_dscritic <> ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-erro  THEN
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                                                       
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

                    RETURN "NOK".
                END.

            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
     
        END.                                                                      
                                                      
    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

END PROCEDURE.

PROCEDURE segunda_via_senha_cartao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nrdconta AS INTE FORMAT "zzzz,zzz,9"       NO-UNDO.    
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrcrd AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.    

    DEF   VAR aux_nmendter     AS CHAR FORMAT "x(20)"                    NO-UNDO.
    DEF   VAR aux_nmarqimp     AS CHAR                                   NO-UNDO.

    DEF   VAR aux_nmarquiv     AS CHAR                                   NO-UNDO.
    DEF   VAR aux_nmarqpdf     AS CHAR                                   NO-UNDO.

    DEF   VAR h-b1wgen9999     AS HANDLE                            NO-UNDO.
    DEF   VAR h-b1wgen0024     AS HANDLE                            NO-UNDO.

    DEFINE VARIABLE aux_retor1   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor2   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor3   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor4   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor5   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor6   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor7   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor8   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_nrcrcard AS DECI      FORMAT "9999,9999,9999,9999" NO-UNDO.
    DEF   VAR aux_nomesoli       AS CHAR FORMAT "x(40)"       NO-UNDO.
    DEFINE VARIABLE aux_desclin1 AS CHARACTER FORMAT "x(133)" NO-UNDO.
    DEFINE VARIABLE aux_desclin2 AS CHARACTER FORMAT "x(133)" NO-UNDO.
    DEFINE VARIABLE aux_tituloIm AS CHARACTER FORMAT "x(60)" NO-UNDO.
    DEF   VAR aux_nrcpfcgc       AS CHAR FORMAT "x(15)"       NO-UNDO.

    FORM aux_tituloIm AT 46 SKIP(2)
         WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_titulo.
    
    FORM aux_retor1
         aux_retor2
         aux_retor3
         aux_retor5
         aux_retor6 SKIP(1)
         "Conta: " par_nrdconta SKIP
         "Nome Cooperada:" tt-segviasen-cartao.nmprimtl  SKIP
         "Nome Portador:" tt-segviasen-cartao.nmtitcrd SKIP
         "CPF:" aux_nrcpfcgc SKIP
         "N. do Cartao de Credito:" tt-segviasen-cartao.nrcrcard SKIP(2)
         tt-segviasen-cartao.dsemsctr SKIP(4)   
         "__________________________________________________      __________________________________________________" SKIP
         tt-segviasen-cartao.nome FORMAT "x(50)" 
         tt-segviasen-cartao.nmextcop AT 57 SKIP
         tt-segviasen-cartao.dsrepsen FORMAT "x(30)"
        WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_2via_senha_cartao_pj.


    /*  utiliza o handle da bo 028 que ja esta na memoria.*/
    ASSIGN h-b1wgen0028 = SOURCE-PROCEDURE.

    IF  NOT VALID-HANDLE(h-b1wgen0028) THEN
        DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO " +
                                  "b1wgen0028.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
    
        END.
   
    RUN impressoes_cartoes IN h-b1wgen0028 ( INPUT  par_cdcooper,
                                             INPUT  0,
                                             INPUT  0,
                                             INPUT  par_cdoperad,
                                             INPUT  par_nmdatela,
                                             INPUT  1,
                                             INPUT  par_nrdconta,
                                             INPUT  1,
                                             INPUT  par_dtmvtolt,
                                             INPUT  01/01/9999, /*glb_dtmvtopr*/
                                             INPUT  1, /*glb_inproces*/
                                             INPUT  12, /* termo segunda via senha cartao pj  */
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

    IF   RETURN-VALUE = "NOK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
             IF   AVAIL tt-erro   THEN
                  DO:
                      MESSAGE tt-erro.dscritic.
                      RETURN "NOK".
                  END.
         END.
    
    FIND tt-segviasen-cartao     NO-ERROR.
    IF NOT AVAIL tt-segviasen-cartao THEN
         RETURN "NOK".
    
    FIND FIRST crapcop WHERE
               crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                          par_dsiduser.

    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").

    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    ASSIGN aux_nrcpfcgc = string(tt-segviasen-cartao.nrrepsen,"99999999999")
           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
    
    ASSIGN aux_desclin1 = tt-segviasen-cartao.nome + ", pessoa juridica de direito privado, inscrita no CNPJ sob n. " + string(tt-segviasen-cartao.cnpj,"zz,zzz,zzz,zzzz,zz") + ", com sede na Rua " +                                                                                                                 
                          tt-segviasen-cartao.dsendere + ", n. " + string(tt-segviasen-cartao.nrendere) + ", Bairro " + tt-segviasen-cartao.nmbairro + ", CEP " + string(tt-segviasen-cartao.nrcepend,"zz,zzz,zz9") + ", na cidade de " + tt-segviasen-cartao.nmcidade + ", Estado de " + tt-segviasen-cartao.cdufende + ", representada" +
                          " neste ato na forma do estabelecido no Contrato Para Utilizacao de Cartao de Credito CECRED/VISA Pessoa Juridica," 
           aux_nomesoli =  tt-segviasen-cartao.nmrepsol.

    ASSIGN aux_tituloIm = "\033\107 SOLICITACAO DE SEGUNDA VIA DE SENHA DE CARTAO DE CREDITO \033\110"
           aux_desclin2 = "na pessoa do(a) Sr(a) " + string(tt-segviasen-cartao.dsrepsen) + ", inscrito no CPF/MF sob n. " + aux_nrcpfcgc + ", solicita pela presente, uma segunda via de senha para o cartao de credito CECRED/VISA, para o seguinte portador:".

    ASSIGN aux_nrcpfcgc = string(tt-segviasen-cartao.nrcpftit,"99999999999")
           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
     
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                             
           RETURN "NOK".
        END.

    RUN quebra-str IN h-b1wgen9999 ( INPUT aux_desclin1,
                                     INPUT 133, INPUT 133,
                                     INPUT 133, INPUT 0,
                                    OUTPUT aux_retor1,
                                    OUTPUT aux_retor2,
                                    OUTPUT aux_retor3,
                                    OUTPUT aux_retor4).

    DELETE PROCEDURE h-b1wgen9999.
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                             
             RETURN "NOK".
        END.

    RUN quebra-str IN h-b1wgen9999 ( INPUT aux_desclin2,
                                     INPUT 133, INPUT 133,
                                     INPUT 0, INPUT 0,
                                    OUTPUT aux_retor5,
                                    OUTPUT aux_retor6,
                                    OUTPUT aux_retor7,
                                    OUTPUT aux_retor8).


    DELETE PROCEDURE h-b1wgen9999.

    DISPLAY STREAM str_1
                   aux_tituloIm  WITH FRAME f_titulo.
          
    DISPLAY STREAM str_1
                   aux_retor1        
                   aux_retor2
                   aux_retor3
                   aux_retor5
                   aux_retor6
                   par_nrdconta 
                   tt-segviasen-cartao.nmprimtl            
                   tt-segviasen-cartao.nmtitcrd
                   aux_nrcpfcgc
                   tt-segviasen-cartao.nrcrcard
                   tt-segviasen-cartao.dsemsctr 
                   tt-segviasen-cartao.nome  
                   tt-segviasen-cartao.nmextcop
                   tt-segviasen-cartao.dsrepsen
                   WITH FRAME f_2via_senha_cartao_pj.   

    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            DO WHILE TRUE:

                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.
            
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE.
                    END.
                
                RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                        INPUT aux_nmarqpdf).
    
                /** Copiar pdf para visualizacao no Ayllos WEB **/
                IF  SEARCH(aux_nmarqpdf) = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                              " a impressao.".
                        LEAVE.                      
                    END.
                            
                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                   '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                                   ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                                   '/temp/" 2>/dev/null').
   
                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.
    
            IF  aux_dscritic <> ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-erro  THEN
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                                                       
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

                    RETURN "NOK".
                END.

            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
     
        END.                                                                      
                                                      
    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

END PROCEDURE.

PROCEDURE termo_cancela_cartao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nrdconta AS INTE FORMAT "zzzz,zzz,9"       NO-UNDO.    
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrcrd AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.    

    DEF   VAR aux_nmendter     AS CHAR FORMAT "x(20)"                    NO-UNDO.
    DEF   VAR aux_nmarqimp     AS CHAR                                   NO-UNDO.

    DEF   VAR aux_nmarquiv     AS CHAR                                   NO-UNDO.
    DEF   VAR aux_nmarqpdf     AS CHAR                                   NO-UNDO.

    DEF   VAR h-b1wgen9999     AS HANDLE                            NO-UNDO.
    DEF   VAR h-b1wgen0024     AS HANDLE                            NO-UNDO.

    DEFINE VARIABLE aux_retor1   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor2   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor3   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor4   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor5   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor6   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor7   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor8   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_nrcrcard AS DECI      FORMAT "9999,9999,9999,9999" NO-UNDO.
    DEF   VAR aux_nomesoli       AS CHAR FORMAT "x(40)"       NO-UNDO.
    DEFINE VARIABLE aux_desclin1 AS CHARACTER FORMAT "x(133)" NO-UNDO.
    DEFINE VARIABLE aux_desclin2 AS CHARACTER FORMAT "x(133)" NO-UNDO.
    DEFINE VARIABLE aux_tituloIm AS CHARACTER FORMAT "x(60)" NO-UNDO.
    DEF   VAR aux_nrcpfcgc       AS CHAR FORMAT "x(15)"       NO-UNDO.

    FORM aux_tituloIm AT 46 SKIP(2)
         WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_titulo.
    
    FORM aux_retor1
         aux_retor2
         aux_retor3
         aux_retor5
         aux_retor6 SKIP(1)
         "Conta: " par_nrdconta SKIP
         "Nome Cooperada:" tt-termocan-cartao.nmprimtl  SKIP
         "Nome Portador:" tt-termocan-cartao.nmtitcrd SKIP
         "CPF:" aux_nrcpfcgc SKIP
         "N. do Cartao de Credito:" tt-termocan-cartao.nrcrcard SKIP(2)
         tt-termocan-cartao.dsemsctr SKIP(4)   
         "__________________________________________________      __________________________________________________" SKIP
         tt-termocan-cartao.nome FORMAT "x(50)"  
         tt-termocan-cartao.nmextcop AT 57 SKIP
         tt-termocan-cartao.dsrepcan FORMAT "x(30)"
        WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_termo_cancela_cartao_pj.
   
    /*  utiliza o handle da bo 028 que ja esta na memoria.*/
    ASSIGN h-b1wgen0028 = SOURCE-PROCEDURE.

    IF  NOT VALID-HANDLE(h-b1wgen0028) THEN
        DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO " +
                                  "b1wgen0028.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
    
        END.

    RUN impressoes_cartoes IN h-b1wgen0028 ( INPUT  par_cdcooper,
                                             INPUT  0,
                                             INPUT  0,
                                             INPUT  par_cdoperad,
                                             INPUT  par_nmdatela,
                                             INPUT  1,
                                             INPUT  par_nrdconta,
                                             INPUT  1,
                                             INPUT  par_dtmvtolt,
                                             INPUT  01/01/9999, /*glb_dtmvtopr*/
                                             INPUT  1, /*glb_inproces*/
                                             INPUT  13, /* Termo cancela cartao PJ */
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

    IF   RETURN-VALUE = "NOK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
             IF   AVAIL tt-erro   THEN
                  DO:
                      MESSAGE tt-erro.dscritic.
                      RETURN "NOK".
                  END.
         END.
    
    FIND tt-termocan-cartao     NO-ERROR.
    IF NOT AVAIL tt-termocan-cartao THEN
         RETURN "NOK".
    
    FIND FIRST crapcop WHERE
               crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                          par_dsiduser.

    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").

    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    ASSIGN aux_nrcpfcgc = string(tt-termocan-cartao.nrrepcan,"99999999999")
           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
    
    ASSIGN aux_desclin1 = tt-termocan-cartao.nome + ", pessoa juridica de direito privado, inscrita no CNPJ sob n. " + string(tt-termocan-cartao.cnpj,"zz,zzz,zzz,zzzz,zz") + ", com sede na Rua " +                                                                                                                 
                          tt-termocan-cartao.dsendere + ", n. " + string(tt-termocan-cartao.nrendere) + ", Bairro " + tt-termocan-cartao.nmbairro + ", CEP " + string(tt-termocan-cartao.nrcepend,"zz,zzz,zz9") + ", na cidade de " + tt-termocan-cartao.nmcidade + ", Estado de " + tt-termocan-cartao.cdufende + ", representada" +
                          " neste ato na forma do estabelecido no Contrato Para Utilizacao de Cartao de Credito CECRED/VISA Pessoa Juridica," 
           aux_nomesoli =  tt-termocan-cartao.nmrepsol.

    ASSIGN aux_tituloIm = "\033\107 TERMO DE CANCELAMENTO DE CARTAO DE CREDITO \033\110"
           aux_desclin2 = "na pessoa do(a) Sr(a) " + string(tt-termocan-cartao.dsrepcan) + ", inscrito no CPF/MF sob n. " + aux_nrcpfcgc + ", solicita pela presente, cancelamento do cartao de credito CECRED/VISA, para o seguinte portador:".

    ASSIGN aux_nrcpfcgc = string(tt-termocan-cartao.nrcpftit,"99999999999")
           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
     
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                             
           RETURN "NOK".
        END.

    RUN quebra-str IN h-b1wgen9999 ( INPUT aux_desclin1,
                                     INPUT 133, INPUT 133,
                                     INPUT 133, INPUT 0,
                                    OUTPUT aux_retor1,
                                    OUTPUT aux_retor2,
                                    OUTPUT aux_retor3,
                                    OUTPUT aux_retor4).

    DELETE PROCEDURE h-b1wgen9999.
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                             
             RETURN "NOK".
        END.

    RUN quebra-str IN h-b1wgen9999 ( INPUT aux_desclin2,
                                     INPUT 133, INPUT 133,
                                     INPUT 0, INPUT 0,
                                    OUTPUT aux_retor5,
                                    OUTPUT aux_retor6,
                                    OUTPUT aux_retor7,
                                    OUTPUT aux_retor8).


    DELETE PROCEDURE h-b1wgen9999.

    DISPLAY STREAM str_1
                   aux_tituloIm  WITH FRAME f_titulo.
          
    DISPLAY STREAM str_1
                   aux_retor1        
                   aux_retor2
                   aux_retor3
                   aux_retor5
                   aux_retor6
                   par_nrdconta 
                   tt-termocan-cartao.nmprimtl            
                   tt-termocan-cartao.nmtitcrd
                   aux_nrcpfcgc
                   tt-termocan-cartao.nrcrcard
                   tt-termocan-cartao.dsemsctr 
                   tt-termocan-cartao.nome   
                   tt-termocan-cartao.nmextcop
                   tt-termocan-cartao.dsrepcan
                   WITH FRAME f_termo_cancela_cartao_pj.   

    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            DO WHILE TRUE:

                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.
            
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE.
                    END.
                
                RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                        INPUT aux_nmarqpdf).
    
                /** Copiar pdf para visualizacao no Ayllos WEB **/
                IF  SEARCH(aux_nmarqpdf) = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                              " a impressao.".
                        LEAVE.                      
                    END.
                            
                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                   '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                                   ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                                   '/temp/" 2>/dev/null').
   
                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.
    
            IF  aux_dscritic <> ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-erro  THEN
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                                                       
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

                    RETURN "NOK".
                END.

            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
     
        END.                                                                      
                                                      
    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

END PROCEDURE.

PROCEDURE altera_limite_pj:
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrcrd AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp  AS CHAR                          NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.    

    DEF   VAR h-b1wgen9999     AS HANDLE                            NO-UNDO.
    DEF   VAR h-b1wgen0024     AS HANDLE                            NO-UNDO.

    DEF   VAR aux_nmendter     AS CHAR FORMAT "x(20)"           NO-UNDO.
    DEF   VAR aux_nmarqimp     AS CHAR                          NO-UNDO.
    DEF   VAR aux_nmarquiv     AS CHAR                          NO-UNDO.
    DEF   VAR aux_nmarqpdf     AS CHAR                          NO-UNDO.

    DEFINE VARIABLE aux_retor1   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor2   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor3   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor4   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor5   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor6   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor7   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor8   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_nrcrcard AS DECI      FORMAT "9999,9999,9999,9999" NO-UNDO.
    DEF   VAR aux_nomesoli       AS CHAR FORMAT "x(40)"       NO-UNDO.
    DEFINE VARIABLE aux_desclin1 AS CHARACTER FORMAT "x(133)" NO-UNDO.
    DEFINE VARIABLE aux_desclin2 AS CHARACTER FORMAT "x(133)" NO-UNDO.
    DEFINE VARIABLE aux_tituloIm AS CHARACTER FORMAT "x(60)"  NO-UNDO.
    DEF   VAR aux_nrcpfcgc       AS CHAR FORMAT "x(15)"       NO-UNDO.

    FORM "\033\107 PEDIDO DE ALTERACAO DE LIMITE DE CARTAO DE CREDITO \033\110" AT 40 SKIP(2) 
         aux_retor1
         aux_retor2
         aux_retor3
         aux_retor4 
         aux_desclin2 SKIP(1)
         "Conta:" par_nrdconta FORMAT "zzzz,zzz,9" SKIP
         "Nome da cooperada:" tt-alt-limite-pj.nmprimtl SKIP
         "Titular do cartao:" tt-alt-limite-pj.nmtitcrd SKIP
         "CPF:" aux_nrcpfcgc SKIP
         "N. do Cartao de Credito:" aux_nrcrcard SKIP
         "Novo limite de credito:" tt-alt-limite-pj.vllimcrd SKIP(2)
         tt-alt-limite-pj.dsemsctr SKIP(4)   
         "__________________________________________________      __________________________________________________" SKIP
         tt-alt-limite-pj.nome  
         tt-alt-limite-pj.nmextcop AT 57 SKIP
         tt-alt-limite-pj.nmrepsol
        WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_altera_pj.
          
    /*  utiliza o handle da bo 028 que ja esta na memoria.*/
    ASSIGN h-b1wgen0028 = SOURCE-PROCEDURE.

    IF  NOT VALID-HANDLE(h-b1wgen0028) THEN
        DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO " +
                                  "b1wgen0028.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
    
        END.
    
    RUN impressoes_cartoes IN h-b1wgen0028( INPUT  par_cdcooper,
                                            INPUT  0,
                                            INPUT  0,
                                            INPUT  par_cdoperad,
                                            INPUT  par_nmdatela,
                                            INPUT  1,
                                            INPUT  par_nrdconta,
                                            INPUT  1,
                                            INPUT  par_dtmvtolt,
                                            INPUT  01/01/9999, /*glb_dtmvtopr*/
                                            INPUT  1, /*glb_inproces*/
                                            INPUT  14, /* Altera limite PJ */
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

    IF   RETURN-VALUE = "NOK"   THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
          IF   AVAIL tt-erro   THEN
                   RETURN "NOK".

      END.

    FIND FIRST tt-alt-limite-pj NO-LOCK NO-ERROR.

    FIND FIRST crapcop WHERE 
               crapcop.cdcooper = tt-alt-limite-pj.cdcooper NO-LOCK NO-ERROR.
    
    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                          par_dsiduser.
    
    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
    
    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    ASSIGN aux_nrcpfcgc = string(tt-alt-limite-pj.nrreplim,"99999999999")
           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
        
    ASSIGN aux_desclin1 = tt-alt-limite-pj.nome + ", pessoa juridica de direito privado, inscrita no CNPJ sob n. " + string(tt-alt-limite-pj.cnpj,"zz,zzz,zzz,zzzz,zz") + ", com sede na Rua " +                                                                                                                 
                           tt-alt-limite-pj.dsendere + ", n. " + string(tt-alt-limite-pj.nrendere) + ", Bairro " + tt-alt-limite-pj.nmbairro + ", CEP " + string(tt-alt-limite-pj.nrcepend,"zz,zzz,zz9") + ", na cidade de " + tt-alt-limite-pj.nmcidade + ", Estado de " + tt-alt-limite-pj.cdufende + ", representada" +
                           " neste ato na forma do estabelecido no Contrato Para Utilizacao de Cartao de Credito CECRED/VISA Pessoa Juridica," +                                                                                                                                 
                           "na pessoa do(a) Sr(a) " + string(tt-alt-limite-pj.nmrepsol) + ", inscrito no CPF/MF sob n. " + aux_nrcpfcgc + ", solicita pela presente, alteracao do limite do cartao de credito CECRED/VISA,"
           aux_desclin2  = "para o seguinte portador:"

           aux_nomesoli =  tt-alt-limite-pj.nmrepsol
           aux_nrcrcard =  tt-alt-limite-pj.nrcrcard.

    ASSIGN aux_nrcpfcgc = STRING(tt-alt-limite-pj.nrcpftit,"99999999999")
           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                             
            RETURN "NOK".
        END.

    RUN quebra-str IN h-b1wgen9999  ( INPUT aux_desclin1,
                                      INPUT 133, INPUT 133,
                                      INPUT 133, INPUT 133,
                                     OUTPUT aux_retor1,
                                     OUTPUT aux_retor2,
                                     OUTPUT aux_retor3,
                                     OUTPUT aux_retor4).

    DELETE PROCEDURE h-b1wgen9999.

    DISPLAY STREAM str_1
                       aux_retor1        
                       aux_retor2
                       aux_retor3
                       aux_retor4
                       aux_desclin2
                       par_nrdconta 
                       tt-alt-limite-pj.nmprimtl            
                       tt-alt-limite-pj.nmtitcrd
                       aux_nrcpfcgc
                       aux_nrcrcard
                       tt-alt-limite-pj.vllimcrd
                       tt-alt-limite-pj.dsemsctr 
                       tt-alt-limite-pj.nome    
                       tt-alt-limite-pj.nmextcop
                       tt-alt-limite-pj.nmrepsol
            WITH FRAME f_altera_pj.

    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            DO WHILE TRUE:

                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.
            
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE.
                    END.
                
                RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                        INPUT aux_nmarqpdf).
    
                /** Copiar pdf para visualizacao no Ayllos WEB **/
                IF  SEARCH(aux_nmarqpdf) = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                              " a impressao.".
                        LEAVE.                      
                    END.
                            
                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                   '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                                   ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                                   '/temp/" 2>/dev/null').
   
                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.
    
            IF  aux_dscritic <> ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-erro  THEN
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                                                       
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

                    RETURN "NOK".
                END.

            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
     
        END.                                                                      
                                                      
    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").
    
END PROCEDURE.

PROCEDURE imprimi_limite_pf:
   
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.  
    DEF  INPUT PARAM par_nrctrcrd AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.    
   
    DEF   VAR h-b1wgen0024     AS HANDLE                            NO-UNDO.

    DEF   VAR aux_nmendter     AS CHAR FORMAT "x(20)"           NO-UNDO.
    DEF   VAR aux_nmarqimp     AS CHAR                          NO-UNDO.
    DEF   VAR aux_contador     AS INTEGER                       NO-UNDO.
    DEF   VAR aux_nmarquiv     AS CHAR                          NO-UNDO.
    DEF   VAR aux_nmarqpdf     AS CHAR                          NO-UNDO.

    FORM "\022\024\033\120"     /* Reseta impressora */
     SKIP
     "\0330\033x0\033\017"
     tt-dados_prp_ccr.nmextcop FORMAT "x(70)"
     SKIP(2)
     "\0330\033x0\033\017"
     "\033\016PROP.ALTERACAO DE LIMITE DE CARTAO DE CREDITO"
     tt-dados_prp_ccr.dsadicio FORMAT "X(35)"
     SKIP(1)
     "\033\016Numero da proposta:" AT 41 
     tt-dados_prp_ccr.nrctrcrd FORMAT "zzz,zzz,zz9"
     "\024\022\033\120"
     SKIP
     WITH NO-BOX COLUMN 1 NO-LABELS WIDTH 125 FRAME f_cooperativa.


    FORM "\0332\033x0"
     SKIP
     "DADOS DO ASSOCIADO"
     SKIP(1)
     "Conta/dv:"         tt-dados_prp_ccr.nrdconta FORMAT "zzzz,zzz,9"
     "Matricula:" AT 29  tt-dados_prp_ccr.nrmatric FORMAT "zzz,zz9"
     "PA"     AT 50  tt-dados_prp_ccr.nmresage FORMAT "X(21)"
     SKIP(1)
     "Nome do(s) titular(es):" tt-dados_prp_ccr.nmprimtl FORMAT "x(34)"
     "Admissao:"  AT 61 tt-dados_prp_ccr.dtadmiss FORMAT "99/99/9999"
     SKIP
     tt-dados_prp_ccr.nmsegntl AT 25 FORMAT "X(40)"
     SKIP
     "Empresa:" tt-dados_prp_ccr.nmresemp         FORMAT "X(33)"
     "Secao:"   AT 46   tt-dados_prp_ccr.nmdsecao FORMAT "X(20)"
     SKIP
     "Telefone/Ramal:"  tt-dados_prp_ccr.nrdofone FORMAT "X(20)"
     SKIP
     "Tipo de conta:" tt-dados_prp_ccr.dstipcta FORMAT "x(20)"
     "Situacao da conta:" AT 38  tt-dados_prp_ccr.dssitdct FORMAT "x(22)"
     SKIP(2)
     tt-dados_prp_ccr.tpcartao FORMAT "x(60)"
     SKIP(1)
     "Titular:"  tt-dados_prp_ccr.nmtitcrd FORMAT "X(40)"
     "CPF:"  AT  62 tt-dados_prp_ccr.nrcpftit FORMAT "999,999,999,99"
     SKIP
     "Parentesco:" tt-dados_prp_ccr.dsparent FORMAT "X(25)"
     SKIP(2)
     "RECIPROCIDADE"
     SKIP(1)
     "Saldo medio do trimestre:" tt-dados_prp_ccr.vlsmdtri 
                                                 FORMAT "zzzzzz,zz9.99"
     "Capital:"  AT 41 tt-dados_prp_ccr.vlcaptal FORMAT "zzzzzz,zz9.99"
     "Plano:"    AT 64 tt-dados_prp_ccr.vlprepla FORMAT "zzz,zz9.99"
     SKIP(1)
     "Aplicacoes:"     tt-dados_prp_ccr.vlaplica FORMAT "zzz,zzz,zz9.99"
     SKIP(2)
     "RENDA MENSAL"
     SKIP(1)
     "Salario:"                  tt-dados_prp_ccr.vlsalari FORMAT "zzzz,zz9.99"
     "Salario do conjuge:" AT 23 tt-dados_prp_ccr.vlsalcon FORMAT "zzzz,zz9.99"
     "Outras rendas:"      AT 55 tt-dados_prp_ccr.vloutras FORMAT "zzzz,zz9.99"
     SKIP
     "Limite de credito:"        tt-dados_prp_ccr.vllimcre FORMAT "zzz,zz9.99"
     "Aluguel:"            AT 61 tt-dados_prp_ccr.vlalugue FORMAT "zzzz,zz9.99"
     SKIP(2)
     "DIVIDA"
     SKIP(1)
     "Saldo devedor de emprestimos:" tt-dados_prp_ccr.vltotemp
     "Prestacoes:"  AT 49 tt-dados_prp_ccr.vltotpre
     SKIP(1)
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_dados.

    FORM  SKIP(1)
      "OUTROS CARTOES"
      SKIP(1)
      WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_outros.

    FORM  SKIP
      tt-outros_cartoes.dsdnomes FORMAT "x(23)"
      tt-outros_cartoes.dstipcrd FORMAT "x(34)"
      tt-outros_cartoes.vllimite FORMAT "zzz,zz9.99"
      tt-outros_cartoes.dssituac FORMAT "x(10)"
      WITH NO-BOX NO-LABELS WIDTH 80 DOWN FRAME f_cartoes.

    FORM SKIP(1)
      "Dia do debito em conta corrente:" tt-dados_prp_ccr.dddebito
      "Conta-mae:" AT 51 tt-dados_prp_ccr.nrctamae FORMAT "9999,9999,9999,9999"
       SKIP(1)
      "Limite Proposto:" tt-dados_prp_ccr.cdlimcrd FORMAT "99999" "-"
      tt-dados_prp_ccr.vllimcrd FORMAT "zzz,zzz,zz9.99"
      SKIP(2)
      "APROVACAO"
      SKIP(2)
      "____________________________________" AT  3
      "____________________________________" AT 44
      SKIP
      "  Operador:" tt-dados_prp_ccr.nmoperad FORMAT "x(26)"
      tt-dados_prp_ccr.nmrecop1 AT 44 FORMAT "x(36)" SKIP
      tt-dados_prp_ccr.nmrecop2 AT 44 FORMAT "x(36)"
      SKIP(1)
      "__________________________________________________" AT 3
      SKIP
      tt-dados_prp_ccr.nmprimtl FORMAT "X(50)" AT 3  
      SKIP(1)
      tt-dados_prp_ccr.nmcidade FORMAT "X(25)" AT 25 "," AT 51
      tt-dados_prp_ccr.dsemprp2 FORMAT "X(25)" AT 53 "." AT 79
      WITH NO-BOX NO-LABELS FRAME f_final.

    FORM SKIP(1)
     "\0330\033x0\033\017" "\033\016" "        "
     SKIP
     "\0330\033x0\033\017"
     "\033\016" tt-dados_prp_ccr.nmextcop FORMAT "x(70)"
     SKIP
     "\0330\033x0\033\017"
     "\033\016" tt-dados_prp_ccr.dslinha1 FORMAT "x(70)"
     SKIP
     "\0330\033x0\033\017"
     "\033\016" tt-dados_prp_ccr.dslinha2 FORMAT "x(70)"
     SKIP
     "\0330\033x0\033\017"
     "\033\016" tt-dados_prp_ccr.dslinha3 FORMAT "x(70)"
     SKIP(6)
     "\0330\033x0\033\017"
     "\033\016" tt-dados_prp_ccr.nmcidade                "," 
                tt-dados_prp_ccr.dsemprp2 FORMAT "X(25)" "."
     SKIP(5)
     "\0330\033x0\033\017"
     "\033\016A" tt-dados_prp_ccr.dsdestin   FORMAT "x(20)" SKIP
     "\0330\033x0\033\017"
     "\033\016A/C" tt-dados_prp_ccr.dscontat FORMAT "x(40)" SKIP(5)
     "\0330\033x0\033\017"
     "\033\016SOLICITAMOS A ALTERACAO NO LIMITE DE CREDITO DO CARTAO ABAIXO:" 
     SKIP(5)
     "\0330\033x0\033\017"
     "\033\016NUMERO DO CARTAO:" tt-dados_prp_ccr.nrcrcard 
                                 FORMAT "9999,9999,9999,9999"
      SKIP(2)
     "\0330\033x0\033\017"
     "\033\016            NOME:" tt-dados_prp_ccr.nmtitcrd FORMAT "X(40)"
     SKIP(2)
     "\0330\033x0\033\017"
     "\033\016     NOVO LIMITE:" tt-dados_prp_ccr.vllimcrd 
                                 FORMAT "zzz,zzz,zz9.99"
     SKIP(5)
     "\0330\033x0\033\017"
     "\033\016ATENCIOSAMENTE" 
     SKIP(5) 
     "\0330\033x0\033\017"
     "\033\016"
     "________________________________________" AT 20 SKIP
     "\0330\033x0\033\017"
     "\033\016"
     tt-dados_prp_ccr.nmrecop1 FORMAT "x(40)" AT 20 SKIP 
     "\0330\033x0\033\017"
     "\033\016"
     tt-dados_prp_ccr.nmrecop2 FORMAT "x(40)" AT 20
     SKIP 
     WITH NO-BOX COLUMN 8 NO-LABELS WIDTH 125 FRAME f_carta.

    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                          par_dsiduser.
    
    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
     
    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) APPEND PAGED PAGE-SIZE 84.

    /*  utiliza o handle da bo 028 que ja esta na memoria.*/
    ASSIGN h-b1wgen0028 = SOURCE-PROCEDURE.

    IF  NOT VALID-HANDLE(h-b1wgen0028) THEN
        DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO " +
                                  "b1wgen0028.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
    
        END.

    RUN impressoes_cartoes IN h-b1wgen0028 ( INPUT  par_cdcooper,
                                             INPUT  0,
                                             INPUT  0,
                                             INPUT  par_cdoperad,
                                             INPUT  par_nmdatela,
                                             INPUT  1,
                                             INPUT  par_nrdconta,
                                             INPUT  1,
                                             INPUT  par_dtmvtolt,
                                             INPUT  par_dtmvtopr,
                                             INPUT  par_inproces,
                                             INPUT  1, /* Contrato e Proposta */
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

    IF   RETURN-VALUE = "NOK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
             IF   AVAIL tt-erro   THEN
                  DO:
                      MESSAGE tt-erro.dscritic.
                      RETURN "NOK".
                  END.
         END.

   FIND FIRST tt-dados_prp_ccr NO-LOCK NO-ERROR.

   DISPLAY STREAM str_1
            "\033\016" + tt-dados_prp_ccr.nmextcop + 
            "\024\022\033\120" @ tt-dados_prp_ccr.nmextcop 
            tt-dados_prp_ccr.dsadicio tt-dados_prp_ccr.nrctrcrd 
            WITH FRAME f_cooperativa.

    DISPLAY STREAM str_1
            tt-dados_prp_ccr.nrdconta   tt-dados_prp_ccr.nrmatric
            tt-dados_prp_ccr.nmresage   tt-dados_prp_ccr.nmprimtl
            tt-dados_prp_ccr.dtadmiss   tt-dados_prp_ccr.nmsegntl
            tt-dados_prp_ccr.nmresemp   tt-dados_prp_ccr.nmdsecao
            tt-dados_prp_ccr.nrdofone   tt-dados_prp_ccr.dstipcta
            tt-dados_prp_ccr.dssitdct   tt-dados_prp_ccr.tpcartao
            tt-dados_prp_ccr.nmtitcrd   tt-dados_prp_ccr.vlaplica
            tt-dados_prp_ccr.nrcpftit   tt-dados_prp_ccr.dsparent
            tt-dados_prp_ccr.vlsmdtri   tt-dados_prp_ccr.vlcaptal
            tt-dados_prp_ccr.vlprepla   tt-dados_prp_ccr.vlsalari
            tt-dados_prp_ccr.vlsalcon   tt-dados_prp_ccr.vloutras
            tt-dados_prp_ccr.vllimcre   tt-dados_prp_ccr.vlalugue
            tt-dados_prp_ccr.vltotemp   tt-dados_prp_ccr.vltotpre
            WITH FRAME f_dados.

    IF   CAN-FIND(FIRST tt-outros_cartoes)   THEN
         DO:
             VIEW STREAM str_1 FRAME f_outros.
             DOWN STREAM str_1 WITH FRAME f_outros.
    
             FOR EACH tt-outros_cartoes:
                 DISPLAY STREAM str_1
                         tt-outros_cartoes.dsdnomes
                         tt-outros_cartoes.dstipcrd
                         tt-outros_cartoes.vllimite
                         tt-outros_cartoes.dssituac
                         WITH FRAME f_cartoes.
    
                 DOWN STREAM str_1 WITH FRAME f_cartoes.
             END.
         END.

    DISPLAY STREAM str_1
            tt-dados_prp_ccr.dddebito   tt-dados_prp_ccr.nrctamae
            tt-dados_prp_ccr.cdlimcrd   tt-dados_prp_ccr.vllimcrd
            tt-dados_prp_ccr.nmoperad   tt-dados_prp_ccr.dsemprp2
            tt-dados_prp_ccr.nmprimtl   tt-dados_prp_ccr.nmcidade
            tt-dados_prp_ccr.nmrecop1   tt-dados_prp_ccr.nmrecop2
            WITH FRAME f_final.

    PAGE STREAM str_1.
    PUT STREAM str_1 CONTROL "\0330\033x0\022\033\115" NULL.

    DISPLAY STREAM str_1 
            tt-dados_prp_ccr.dsemprp2   tt-dados_prp_ccr.dscontat
            tt-dados_prp_ccr.dsdestin   tt-dados_prp_ccr.nmtitcrd 
            tt-dados_prp_ccr.nrcrcard   tt-dados_prp_ccr.vllimcrd
            tt-dados_prp_ccr.dslinha1   tt-dados_prp_ccr.dslinha2
            tt-dados_prp_ccr.dslinha3   tt-dados_prp_ccr.nmcidade
            tt-dados_prp_ccr.nmrecop1   tt-dados_prp_ccr.nmrecop2
            tt-dados_prp_ccr.nmextcop 
            WITH FRAME f_carta.
    
    /** Tratamento da impressao da nota promissoria **/
    EMPTY TEMP-TABLE tt_dados_promissoria.
             
    CREATE tt_dados_promissoria.
    ASSIGN tt_dados_promissoria.dsemsctr = tt-dados_prp_ccr.dsemsprp
           tt_dados_promissoria.dsctrcrd = tt-dados_prp_ccr.dsctrcrd
           tt_dados_promissoria.dsdmoeda = tt-dados_prp_ccr.dsdmoeda
           tt_dados_promissoria.vllimite = tt-dados_prp_ccr.vllimite
           tt_dados_promissoria.dsdtmvt1 = tt-dados_prp_ccr.dsdtmvt1
           tt_dados_promissoria.dsdtmvt2 = tt-dados_prp_ccr.dsdtmvt2
           tt_dados_promissoria.nmextcop = tt-dados_prp_ccr.nmextcop
           tt_dados_promissoria.nmrescop = tt-dados_prp_ccr.nmrecop1
           tt_dados_promissoria.dsvlnpr1 = tt-dados_prp_ccr.dsvlnpr1
           tt_dados_promissoria.dsvlnpr2 = tt-dados_prp_ccr.dsvlnpr2
           tt_dados_promissoria.nmcidpac = tt-dados_prp_ccr.nmcidpac
           tt_dados_promissoria.nmprimtl = tt-dados_prp_ccr.nmprimtl
           tt_dados_promissoria.dscpfcgc = tt-dados_prp_ccr.dscpfcgc
           tt_dados_promissoria.nrdconta = tt-dados_prp_ccr.nrdconta
           tt_dados_promissoria.endeass1 = tt-dados_prp_ccr.endeass1
           tt_dados_promissoria.endeass2 = tt-dados_prp_ccr.endeass2
           tt_dados_promissoria.nmcidade = tt-dados_prp_ccr.nmcidade.
                    
    ASSIGN aux_contador = 1.      
    FOR EACH tt-avais-ctr:
        IF   aux_contador = 1   THEN
             ASSIGN tt_dados_promissoria.nmdaval1    = tt-avais-ctr.nmdavali
                    tt_dados_promissoria.nmdcjav1    = tt-avais-ctr.nmconjug
                    tt_dados_promissoria.dscpfav1    = tt-avais-ctr.cpfavali
                    tt_dados_promissoria.dscfcav1    = tt-avais-ctr.nrcpfcjg
                    tt_dados_promissoria.dsendav1[1] = tt-avais-ctr.dsendav1
                    tt_dados_promissoria.dsendav1[2] = tt-avais-ctr.dsendav2
                    tt_dados_promissoria.dsendav1[3] = tt-avais-ctr.dsendav3
                    aux_contador                     = aux_contador + 1.
        ELSE
             ASSIGN tt_dados_promissoria.nmdaval2    = tt-avais-ctr.nmdavali
                    tt_dados_promissoria.nmdcjav2    = tt-avais-ctr.nmconjug
                    tt_dados_promissoria.dscpfav2    = tt-avais-ctr.cpfavali
                    tt_dados_promissoria.dscfcav2    = tt-avais-ctr.nrcpfcjg
                    tt_dados_promissoria.dsendav2[1] = tt-avais-ctr.dsendav1
                    tt_dados_promissoria.dsendav2[2] = tt-avais-ctr.dsendav2
                    tt_dados_promissoria.dsendav2[3] = tt-avais-ctr.dsendav3.
    END.            
             
    RELEASE tt_dados_promissoria.
    
    RUN gera_impressao_promissoria ( INPUT par_cdcooper,
                                     INPUT TABLE tt_dados_promissoria,
                                    OUTPUT TABLE tt-erro).
    /** Fim - Tratamento da impressao da nota promissoria **/

    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            DO WHILE TRUE:

                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.
            
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE.
                    END.
                
                RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                        INPUT aux_nmarqpdf).
    
                /** Copiar pdf para visualizacao no Ayllos WEB **/
                IF  SEARCH(aux_nmarqpdf) = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                              " a impressao.".
                        LEAVE.                      
                    END.
                            
                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                   '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                                   ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                                   '/temp/" 2>/dev/null').
   
                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.
    
            IF  aux_dscritic <> ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-erro  THEN
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                                                       
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

                    RETURN "NOK".
                END.

            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
     
        END.                                                                      
                                                      
    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

END PROCEDURE.

PROCEDURE imprime_Alt_data_PJ:
    DEF  INPUT PARAM par_cdcooper AS INTE                       NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                       NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                       NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                       NO-UNDO. 
    DEF  INPUT PARAM par_dtmvtolt AS DATE                       NO-UNDO.
    DEF  INPUT PARAM par_nrctrcrd AS INTE                       NO-UNDO.   
    DEF  INPUT PARAM par_nrdconta AS INTE                       NO-UNDO.

    DEF  INPUT PARAM par_dsiduser AS CHAR                       NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                       NO-UNDO. 
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                       NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF   VAR h-b1wgen9999        AS HANDLE                     NO-UNDO.
    DEF   VAR h-b1wgen0024        AS HANDLE                     NO-UNDO.

    DEF   VAR aux_nmendter     AS CHAR FORMAT "x(20)"           NO-UNDO.
    DEF   VAR aux_nmarqimp     AS CHAR                          NO-UNDO.
    DEF   VAR aux_nmarquiv     AS CHAR                          NO-UNDO.
    DEF   VAR aux_nmarqpdf     AS CHAR                          NO-UNDO.

    DEFINE VARIABLE aux_retor1   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor2   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor3   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor4   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor5   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor6   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor7   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor8   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_nrcrcard AS DECI      FORMAT "9999,9999,9999,9999" NO-UNDO.
    DEF   VAR aux_nomesoli       AS CHAR FORMAT "x(40)"       NO-UNDO.
    DEFINE VARIABLE aux_desclin1 AS CHARACTER FORMAT "x(133)" NO-UNDO.
    DEFINE VARIABLE aux_desclin2 AS CHARACTER FORMAT "x(133)" NO-UNDO.
    DEFINE VARIABLE aux_tituloIm AS CHARACTER FORMAT "x(60)"  NO-UNDO.
    DEF   VAR aux_nrcpfcgc       AS CHAR FORMAT "x(15)"       NO-UNDO.

    FORM "\033\107 PEDIDO DE ALTERACAO DE DATA DE VENCIMENTO DE FATURA DE CARTAO \033\110" AT 36 SKIP(2) 
         aux_retor1
         aux_retor2
         aux_retor3
         aux_retor4 
         aux_desclin2 SKIP(1)
  
         "Conta: " par_nrdconta FORMAT "zzzz,zzz,9" SKIP
         "Nome da cooperada:" tt-alt-dtvenc-pj.nmprimtl SKIP
         "Titular do cartao:" tt-alt-dtvenc-pj.nmtitcrd SKIP
         "CPF:" aux_nrcpfcgc SKIP
         "N. do Cartao de Credito:" aux_nrcrcard SKIP
         "Novo dia de vencimento:" tt-alt-dtvenc-pj.dddebito  SKIP(2)
         tt-alt-dtvenc-pj.dsemsctr SKIP(2)   
         "__________________________________________________      __________________________________________________" SKIP
         tt-alt-dtvenc-pj.nome  
         tt-alt-dtvenc-pj.nmextcop AT 57 SKIP
         tt-alt-dtvenc-pj.nmrepsol
        WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_altera_pj.

    /*  utiliza o handle da bo 028 que ja esta na memoria.*/
    ASSIGN h-b1wgen0028 = SOURCE-PROCEDURE.

    IF  NOT VALID-HANDLE(h-b1wgen0028) THEN
        DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO " +
                                  "b1wgen0028.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
    
        END.

    RUN impressoes_cartoes IN h-b1wgen0028 ( INPUT  par_cdcooper,
                                             INPUT  0,
                                             INPUT  0,
                                             INPUT  par_cdoperad,
                                             INPUT  par_nmdatela,
                                             INPUT  1,
                                             INPUT  par_nrdconta,
                                             INPUT  1,
                                             INPUT  par_dtmvtolt,
                                             INPUT  01/01/9999, /*glb_dtmvtopr*/
                                             INPUT  1, /*glb_inproces*/
                                             INPUT  15, /* alt dt vencto cartao PJ  */
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


    IF   RETURN-VALUE = "NOK"   THEN
      DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.
          IF   AVAIL tt-erro   THEN
                   RETURN "NOK".

      END.
    
    FIND FIRST tt-alt-dtvenc-pj NO-LOCK NO-ERROR.

    FIND FIRST crapcop WHERE 
               crapcop.cdcooper = tt-alt-dtvenc-pj.cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                      aux_nmarqimp.
    
    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
    
    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

    FIND FIRST tt-alt-dtvenc-pj.

    ASSIGN aux_nrcpfcgc = string(tt-alt-dtvenc-pj.nrrepven,"99999999999")
           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
            
    ASSIGN aux_desclin1 = tt-alt-dtvenc-pj.nome + ", pessoa juridica de direito privado, inscrita no CNPJ sob n. " + string(tt-alt-dtvenc-pj.cnpj,"zz,zzz,zzz,zzzz,zz") + ", com sede na Rua " +                                                                                                                 
                          tt-alt-dtvenc-pj.dsendere + ", n. " + string(tt-alt-dtvenc-pj.nrendere) + ", Bairro " + tt-alt-dtvenc-pj.nmbairro + ", CEP " + string(tt-alt-dtvenc-pj.nrcepend,"zz,zzz,zz9") + ", na cidade de " + tt-alt-dtvenc-pj.nmcidade + ", Estado de " + tt-alt-dtvenc-pj.cdufende + ", representada" +
                          " neste ato na forma do estabelecido no Contrato Para Utilizacao de Cartao de Credito CECRED/VISA Pessoa Juridica, na pessoa do(a) Sr(a) " + string(tt-alt-dtvenc-pj.nmrepsol) + ", inscrito no CPF/MF sob n. " + aux_nrcpfcgc +
                          ", solicita pela presente, alteracao da data de vencimento da fatura de cartao de credito CECRED/VISA,"

            aux_desclin2 = "para o seguinte portador:"
            
            aux_nomesoli = tt-alt-dtvenc-pj.nmrepsol
            aux_nrcrcard = tt-alt-dtvenc-pj.nrcrcard.

    ASSIGN aux_nrcpfcgc = string(tt-alt-dtvenc-pj.nrcpftit,"99999999999")
           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                             
            RETURN "NOK".
        END.

    RUN quebra-str IN h-b1wgen9999 (INPUT aux_desclin1,
                                    INPUT 133, INPUT 133,
                                    INPUT 133, INPUT 133,
                                   OUTPUT aux_retor1,
                                   OUTPUT aux_retor2,
                                   OUTPUT aux_retor3,
                                   OUTPUT aux_retor4).

    DELETE PROCEDURE h-b1wgen9999.

    DISPLAY STREAM str_1 
                   aux_retor1
                   aux_retor2
                   aux_retor3
                   aux_retor4
                   aux_desclin2
                   par_nrdconta
                   tt-alt-dtvenc-pj.nmprimtl
                   tt-alt-dtvenc-pj.nmtitcrd
                   aux_nrcpfcgc
                   aux_nrcrcard
                   tt-alt-dtvenc-pj.dddebito
                   tt-alt-dtvenc-pj.dsemsctr 
                   tt-alt-dtvenc-pj.nome
                   tt-alt-dtvenc-pj.nmextcop
                   tt-alt-dtvenc-pj.nmrepsol
        WITH FRAME f_altera_pj.
    
    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            DO WHILE TRUE:

                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.
            
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE.
                    END.
                
                RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                        INPUT aux_nmarqpdf).
    
                /** Copiar pdf para visualizacao no Ayllos WEB **/
                IF  SEARCH(aux_nmarqpdf) = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                              " a impressao.".
                        LEAVE.                      
                    END.
                            
                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                   '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                                   ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                                   '/temp/" 2>/dev/null').
   
                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.
    
            IF  aux_dscritic <> ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-erro  THEN
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                                                       
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

                    RETURN "NOK".
                END.

            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
     
        END.                                                                      
                                                      
    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

END PROCEDURE.

PROCEDURE imprime_Alt_data_PF:
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.  
    DEF  INPUT PARAM par_nrctrcrd AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF   VAR h-b1wgen0024     AS HANDLE                            NO-UNDO.

    DEF   VAR aux_nmendter     AS CHAR FORMAT "x(20)"           NO-UNDO.
    DEF   VAR aux_nmarqimp     AS CHAR                          NO-UNDO.
    DEF   VAR aux_nmarquiv     AS CHAR                          NO-UNDO.
    DEF   VAR aux_nmarqpdf     AS CHAR                          NO-UNDO.

    FORM SKIP(3)
     "\0330\033x0\033\017" "\033\016" "        "
     SKIP
     "\0330\033x0\033\017"
     "\033\016" tt-termo_alt_dt_venc.nmextcop FORMAT "x(70)"
     SKIP
     "\0330\033x0\033\017"
     "\033\016" tt-termo_alt_dt_venc.dslinha1 FORMAT "x(70)"
     SKIP
     "\0330\033x0\033\017"
     "\033\016" tt-termo_alt_dt_venc.dslinha2 FORMAT "x(70)"
     SKIP
     "\0330\033x0\033\017"
     "\033\016" tt-termo_alt_dt_venc.dslinha3 FORMAT "x(70)"
     SKIP(6)
     "\0330\033x0\033\017"
     "\033\016" tt-termo_alt_dt_venc.dsemsctr "."
     SKIP(5)
     "\0330\033x0\033\017"
     "\033\016A CECRED"  SKIP
     "\0330\033x0\033\017"
     "\033\016A/C ADMINISTRATIVO/FINANCEIRO"  SKIP(5)
     "\0330\033x0\033\017"
     "\033\016SOLICITAMOS A ALTERACAO DA DATA DE VENCIMENTO DO CARTAO ABAIXO:" 
     SKIP(5)
     "\0330\033x0\033\017"
     "\033\016NUMERO DO CARTAO:"  tt-termo_alt_dt_venc.nrcrcard 
      SKIP(2)
     "\0330\033x0\033\017"
     "\033\016            NOME:"  tt-termo_alt_dt_venc.nmtitcrd 
     SKIP(2)
     "\0330\033x0\033\017"
     "\033\016        NOVA DATA:" tt-termo_alt_dt_venc.dddebito 
     SKIP(5)
     "\0330\033x0\033\017"
     "\033\016ATENCIOSAMENTE" 
     SKIP(5) 
     "\0330\033x0\033\017"
     "\033\016"
     "--------------------------------------------------" AT 20 SKIP
     "\0330\033x0\033\017"
     "\033\016"
     tt-termo_alt_dt_venc.nmprimtl FORMAT "x(50)" AT 20    
     SKIP(5)
     "\0330\033x0\033\017"
     "\033\016"
     "----------------------------------------" AT 20 SKIP
     "\0330\033x0\033\017"
     "\033\016"
     tt-termo_alt_dt_venc.dsoperad FORMAT "x(40)" AT 20 
     SKIP(5)
     "\0330\033x0\033\017"
     "\033\016"
     "----------------------------------------" AT 20 SKIP
     "\0330\033x0\033\017"
     "\033\016"    
     tt-termo_alt_dt_venc.nmrecop1 FORMAT "x(40)" AT 20 SKIP 
     "\0330\033x0\033\017"
     "\033\016"
     tt-termo_alt_dt_venc.nmrecop2 FORMAT "x(40)" AT 20
     SKIP 
     WITH NO-BOX COLUMN 8 NO-LABELS WIDTH 125 FRAME f_carta.

    /*  utiliza o handle da bo 028 que ja esta na memoria.*/
    ASSIGN h-b1wgen0028 = SOURCE-PROCEDURE.

    IF  NOT VALID-HANDLE(h-b1wgen0028) THEN
        DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO " +
                                  "b1wgen0028.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
    
        END.

    RUN impressoes_cartoes IN h-b1wgen0028 ( INPUT par_cdcooper,
                                             INPUT 0, 
                                             INPUT 0, 
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT 1, 
                                             INPUT par_nrdconta,
                                             INPUT 1, 
                                             INPUT par_dtmvtolt,
                                             INPUT par_dtmvtopr,
                                             INPUT par_inproces,
                                             INPUT 8, /* Termo Alteracao Dt Vencimento */
                                             INPUT par_nrctrcrd,
                                             INPUT YES,
                                             INPUT ?, /* (par_flgimpnp) */
                                             INPUT 0, /* (par_cdmotivo) */
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
    
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                          par_dsiduser.
    
    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
     
    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    FIND FIRST tt-termo_alt_dt_venc NO-LOCK NO-ERROR.

    DISPLAY STREAM str_1
            tt-termo_alt_dt_venc.nmextcop   tt-termo_alt_dt_venc.dslinha1
            tt-termo_alt_dt_venc.dslinha2   tt-termo_alt_dt_venc.dslinha3
            tt-termo_alt_dt_venc.dsemsctr   tt-termo_alt_dt_venc.nrcrcard 
            tt-termo_alt_dt_venc.nmtitcrd   tt-termo_alt_dt_venc.dddebito 
            tt-termo_alt_dt_venc.nmprimtl   tt-termo_alt_dt_venc.dsoperad
            tt-termo_alt_dt_venc.nmrecop1   tt-termo_alt_dt_venc.nmrecop2
            WITH FRAME f_carta.

    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            DO WHILE TRUE:

                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.
            
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE.
                    END.
                
                RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                        INPUT aux_nmarqpdf).
    
                /** Copiar pdf para visualizacao no Ayllos WEB **/
                IF  SEARCH(aux_nmarqpdf) = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                              " a impressao.".
                        LEAVE.                      
                    END.
                            
                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                   '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                                   ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                                   '/temp/" 2>/dev/null').
   
                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.
    
            IF  aux_dscritic <> ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-erro  THEN
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                                                       
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

                    RETURN "NOK".
                END.

            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
     
        END.                                                                      
                                                      
    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

END PROCEDURE.

/************************************
    OPCAO ENCERRAMENTO
    
    Termo de Encerramento
*************************************/

PROCEDURE termo_encerra_cartao: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO. 
    DEF  INPUT PARAM par_nrdconta AS INTE FORMAT "zzzz,zzz,9"       NO-UNDO.    
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrcrd AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.    

    DEF   VAR aux_nmendter     AS CHAR FORMAT "x(20)"                    NO-UNDO.
    DEF   VAR aux_nmarqimp     AS CHAR                                   NO-UNDO.

    DEF   VAR aux_nmarquiv     AS CHAR                                   NO-UNDO.
    DEF   VAR aux_nmarqpdf     AS CHAR                                   NO-UNDO.

    DEF   VAR h-b1wgen9999     AS HANDLE                            NO-UNDO.
    DEF   VAR h-b1wgen0024     AS HANDLE                            NO-UNDO.

    DEFINE VARIABLE aux_retor1   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor2   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor3   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor4   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor5   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor6   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor7   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_retor8   AS CHARACTER FORMAT "x(133)"   NO-UNDO.
    DEFINE VARIABLE aux_nrcrcard AS DECI      FORMAT "9999,9999,9999,9999" NO-UNDO.
    DEF   VAR aux_nomesoli       AS CHAR FORMAT "x(40)"       NO-UNDO.
    DEFINE VARIABLE aux_desclin1 AS CHARACTER FORMAT "x(133)" NO-UNDO.
    DEFINE VARIABLE aux_desclin2 AS CHARACTER FORMAT "x(133)" NO-UNDO.
    DEFINE VARIABLE aux_tituloIm AS CHARACTER FORMAT "x(60)" NO-UNDO.
    DEF   VAR aux_nrcpfcgc       AS CHAR FORMAT "x(15)"       NO-UNDO.

    FORM aux_tituloIm AT 46 SKIP(2)
         WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_titulo.
    
    FORM aux_retor1
         aux_retor2
         aux_retor3
         aux_retor5
         aux_retor6 SKIP(1)
         "Conta: " par_nrdconta SKIP
         "Nome Cooperada:" tt-termocan-cartao.nmprimtl  SKIP
         "Nome Portador:" tt-termocan-cartao.nmtitcrd SKIP
         "CPF:" aux_nrcpfcgc SKIP
         "N. do Cartao de Credito:" tt-termocan-cartao.nrcrcard SKIP(2)
         tt-termocan-cartao.dsemsctr SKIP(4)   
         "__________________________________________________      __________________________________________________" SKIP
         tt-termocan-cartao.nome FORMAT "x(50)"  
         tt-termocan-cartao.nmextcop AT 57 SKIP
         tt-termocan-cartao.dsrepcan FORMAT "x(30)"
        WITH NO-BOX NO-LABELS WIDTH 150 FRAME f_termo_encerra_cartao_pj.
   
    /*  utiliza o handle da bo 028 que ja esta na memoria.*/
    ASSIGN h-b1wgen0028 = SOURCE-PROCEDURE.

    IF  NOT VALID-HANDLE(h-b1wgen0028) THEN
        DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO " +
                                  "b1wgen0028.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
    
        END.

    RUN impressoes_cartoes IN h-b1wgen0028 ( INPUT  par_cdcooper,
                                             INPUT  0,
                                             INPUT  0,
                                             INPUT  par_cdoperad,
                                             INPUT  par_nmdatela,
                                             INPUT  1,
                                             INPUT  par_nrdconta,
                                             INPUT  1,
                                             INPUT  par_dtmvtolt,
                                             INPUT  01/01/9999, /*glb_dtmvtopr*/
                                             INPUT  1, /*glb_inproces*/
                                             INPUT  13, /* Termo cancela cartao PJ */
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

    IF   RETURN-VALUE = "NOK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
             IF   AVAIL tt-erro   THEN
                  DO:
                      MESSAGE tt-erro.dscritic.
                      RETURN "NOK".
                  END.
         END.
    
    FIND tt-termocan-cartao     NO-ERROR.
    IF NOT AVAIL tt-termocan-cartao THEN
         RETURN "NOK".
    
    FIND FIRST crapcop WHERE
               crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                          par_dsiduser.

    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").

    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
    
    ASSIGN aux_nrcpfcgc = string(tt-termocan-cartao.nrrepcan,"99999999999")
           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
    
    ASSIGN aux_desclin1 = tt-termocan-cartao.nome + ", pessoa juridica de direito privado, inscrita no CNPJ sob n. " + string(tt-termocan-cartao.cnpj,"zz,zzz,zzz,zzzz,zz") + ", com sede na Rua " +                                                                                                                 
                          tt-termocan-cartao.dsendere + ", n. " + string(tt-termocan-cartao.nrendere) + ", Bairro " + tt-termocan-cartao.nmbairro + ", CEP " + string(tt-termocan-cartao.nrcepend,"zz,zzz,zz9") + ", na cidade de " + tt-termocan-cartao.nmcidade + ", Estado de " + tt-termocan-cartao.cdufende + ", representada" +
                          " neste ato na forma do estabelecido no Contrato Para Utilizacao de Cartao de Credito " + tt-termocan-cartao.nmresadm + " Pessoa Juridica," 
           aux_nomesoli =  tt-termocan-cartao.nmrepsol.

    ASSIGN aux_tituloIm = "\033\107 TERMO DE ENCERRAMENTO DE CARTAO DE CREDITO \033\110"
           aux_desclin2 = "na pessoa do(a) Sr(a) " + string(tt-termocan-cartao.dsrepcan) + ", inscrito no CPF/MF sob n. " + aux_nrcpfcgc + ", solicita pela presente, encerramento do cartao de credito " + tt-termocan-cartao.nmresadm + ", para o seguinte portador:".

    ASSIGN aux_nrcpfcgc = string(tt-termocan-cartao.nrcpftit,"99999999999")
           aux_nrcpfcgc = STRING(aux_nrcpfcgc,"xxx.xxx.xxx-xx").
     
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                             
           RETURN "NOK".
        END.

    RUN quebra-str IN h-b1wgen9999 ( INPUT aux_desclin1,
                                     INPUT 133, INPUT 133,
                                     INPUT 133, INPUT 0,
                                    OUTPUT aux_retor1,
                                    OUTPUT aux_retor2,
                                    OUTPUT aux_retor3,
                                    OUTPUT aux_retor4).

    DELETE PROCEDURE h-b1wgen9999.
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                             
             RETURN "NOK".
        END.

    RUN quebra-str IN h-b1wgen9999 ( INPUT aux_desclin2,
                                     INPUT 133, INPUT 133,
                                     INPUT 0, INPUT 0,
                                    OUTPUT aux_retor5,
                                    OUTPUT aux_retor6,
                                    OUTPUT aux_retor7,
                                    OUTPUT aux_retor8).

    DELETE PROCEDURE h-b1wgen9999.

    DISPLAY STREAM str_1
                   aux_tituloIm  WITH FRAME f_titulo.
          
    DISPLAY STREAM str_1
                   aux_retor1        
                   aux_retor2
                   aux_retor3
                   aux_retor5
                   aux_retor6
                   par_nrdconta 
                   tt-termocan-cartao.nmprimtl            
                   tt-termocan-cartao.nmtitcrd
                   aux_nrcpfcgc
                   tt-termocan-cartao.nrcrcard
                   tt-termocan-cartao.dsemsctr 
                   tt-termocan-cartao.nome   
                   tt-termocan-cartao.nmextcop
                   tt-termocan-cartao.dsrepcan
                   WITH FRAME f_termo_encerra_cartao_pj.   

    OUTPUT STREAM str_1 CLOSE.

    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            DO WHILE TRUE:

                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.
            
                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE.
                    END.
                
                RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                        INPUT aux_nmarqpdf).
    
                /** Copiar pdf para visualizacao no Ayllos WEB **/
                IF  SEARCH(aux_nmarqpdf) = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                              " a impressao.".
                        LEAVE.                      
                    END.
                            
                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                   '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                                   ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                                   '/temp/" 2>/dev/null').
   
                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.
    
            IF  aux_dscritic <> ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-erro  THEN
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                                                       
                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

                    RETURN "NOK".
                END.

            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").
     
        END.                                                                      
                                                      
    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

END PROCEDURE.

/*............................................................................*/

PROCEDURE extrato_bradesco_impressao: 

    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcrcard AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtvctini AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvctfim AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF   VAR aux_nmendter     AS CHAR FORMAT "x(20)"               NO-UNDO.
    DEF   VAR aux_nmarqimp     AS CHAR                              NO-UNDO.

    DEF   VAR aux_nmarquiv     AS CHAR                              NO-UNDO.
    DEF   VAR aux_nmarqpdf     AS CHAR                              NO-UNDO.

    DEF   VAR h-b1wgen9999     AS HANDLE                            NO-UNDO.
    DEF   VAR h-b1wgen0024     AS HANDLE                            NO-UNDO.

    DEFINE VARIABLE aux_retor1   AS CHARACTER FORMAT "x(133)"       NO-UNDO.
    DEFINE VARIABLE aux_retor2   AS CHARACTER FORMAT "x(133)"       NO-UNDO.
    DEFINE VARIABLE aux_retor3   AS CHARACTER FORMAT "x(133)"       NO-UNDO.
    DEFINE VARIABLE aux_retor4   AS CHARACTER FORMAT "x(133)"       NO-UNDO.
    DEFINE VARIABLE aux_retor5   AS CHARACTER FORMAT "x(133)"       NO-UNDO.
    DEFINE VARIABLE aux_retor6   AS CHARACTER FORMAT "x(133)"       NO-UNDO.
    DEFINE VARIABLE aux_retor7   AS CHARACTER FORMAT "x(133)"       NO-UNDO.
    DEFINE VARIABLE aux_retor8   AS CHARACTER FORMAT "x(133)"       NO-UNDO.

    DEF   VAR aux_nomesoli       AS CHAR FORMAT "x(40)"             NO-UNDO.
    DEFINE VARIABLE aux_desclin1 AS CHARACTER FORMAT "x(133)"       NO-UNDO.
    DEFINE VARIABLE aux_desclin2 AS CHARACTER FORMAT "x(133)"       NO-UNDO.
    DEFINE VARIABLE aux_tituloIm AS CHARACTER FORMAT "x(60)"        NO-UNDO.

    
    DEF   VAR aux_nrdconta       AS CHAR FORMAT "x(15)"             NO-UNDO.
    DEF   VAR aux_nrcrcard       AS CHAR FORMAT "x(22)"             NO-UNDO.
    DEF   VAR tel_dtextrat       AS CHAR                            NO-UNDO.
    DEF   VAR rel_vlcrdolr       AS DECI  FORMAT "zzz,zzz,zz9.99"   NO-UNDO.
    DEF   VAR rel_vldbdolr       AS DECI  FORMAT "zzz,zzz,zz9.99"   NO-UNDO.
    DEF   VAR rel_vlcrreal       AS DECI  FORMAT "zzz,zzz,zz9.99"   NO-UNDO.
    DEF   VAR rel_vldbreal       AS DECI  FORMAT "zzz,zzz,zz9.99"   NO-UNDO.

    DEF   VAR tot_vlcrdolr       AS DECI  FORMAT "zzz,zzz,zz9.99"   NO-UNDO.
    DEF   VAR tot_vldbdolr       AS DECI  FORMAT "zzz,zzz,zz9.99"   NO-UNDO.
    DEF   VAR tot_vlcrreal       AS DECI  FORMAT "zzz,zzz,zz9.99"   NO-UNDO.
    DEF   VAR tot_vldbreal       AS DECI  FORMAT "zzz,zzz,zz9.99"   NO-UNDO.
    DEF   VAR tot_vlrsaldo       AS DECI  FORMAT "zzz,zzz,zz9.99"   NO-UNDO.



FORM SKIP(1)
      aux_tituloIm AT 46 SKIP(3)
      WITH NO-BOX NO-LABELS WIDTH 132 FRAME f_titulo.


FORM tt-extrato-cartao.nrdconta LABEL "NR CONTA"                  AT 2    
     tt-extrato-cartao.nmprimtl LABEL "NOME"      FORMAT "x(50)"  AT 42 SKIP 
     aux_nrcrcard               LABEL "NR CARTAO" FORMAT "x(22)"  AT 1
     tt-extrato-cartao.nmtitcrd LABEL "PORTADOR"                  AT 38 SKIP
     tel_dtextrat               LABEL "PERIODO"                   AT 3
     tt-extrato-cartao.vllimite LABEL "LIMITE(R$)"                AT 36 SKIP(2)
    WITH NO-BOX SIDE-LABELS WIDTH 132 FRAME f_infrelatorio.

DEF FRAME  f_titrelatorio
           "DT COMPRA"                                                AT 1
           "DESCRICAO"                                                AT 12
           "CIDADE"                                                   AT 47
           "CREDITO(US$)"                                             AT 72
           "DEBITO(US$)"                                              AT 87
           "CREDITO(R$)"                                              AT 103
           "DEBITO(R$)"                                               AT 118
           WITH SIDE-LABELS WIDTH 132 .

FORM tt-extrato-cartao.dtcompra                                   NO-LABEL     
     tt-extrato-cartao.dsestabe  FORMAT "x(30)"                   NO-LABEL 
     tt-extrato-cartao.nmcidade  FORMAT "x(20)"           AT 47   NO-LABEL 
     rel_vlcrdolr                FORMAT "zzz,zzz,zz9.99"  AT 70   NO-LABEL
     rel_vldbdolr                FORMAT "zzz,zzz,zz9.99"  AT 84   NO-LABEL
     rel_vlcrreal                FORMAT "zzz,zzz,zz9.99"  AT 100  NO-LABEL
     rel_vldbreal                FORMAT "zzz,zzz,zz9.99"  AT 114  NO-LABEL
     WITH DOWN WIDTH 132 FRAME f_detlhextrato CENTERED.      

FORM SKIP 
     "TOTAL:"                                            AT 60 
     tot_vlcrdolr               FORMAT "zzz,zzz,zz9.99"  AT 70    NO-LABEL 
     tot_vldbdolr               FORMAT "zzz,zzz,zz9.99"  AT 84    NO-LABEL 
     tot_vlcrreal               FORMAT "zzz,zzz,zz9.99"  AT 100   NO-LABEL 
     tot_vldbreal               FORMAT "zzz,zzz,zz9.99"  AT 114   NO-LABEL
     SKIP(1) 
     "TOTAL PARA PAGAMENTO:"                             AT 69
     tot_vlrsaldo               FORMAT "-zzz,zzz,zz9.99" AT 91    NO-LABEL
     WITH DOWN WIDTH 132 FRAME f_totvalor CENTERED.



    
    /*  utiliza o handle da bo 028 que ja esta na memoria.*/
    ASSIGN h-b1wgen0028 = SOURCE-PROCEDURE.

    IF  NOT VALID-HANDLE(h-b1wgen0028) THEN
        DO:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO " +
                                  "b1wgen0028.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.


    RUN extrato_cartao_bradesco IN h-b1wgen0028( INPUT par_cdcooper,
                                                 INPUT par_nrdconta,
                                                 INPUT par_nrcrcard,
                                                 INPUT par_dtvctini, /* Variavel dia 01 mes */
                                                 INPUT par_dtvctfim, /* Variavel ult. dia mes  */
                                                OUTPUT TABLE tt-extrato-cartao,
                                                OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE = "NOK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
             IF   AVAIL tt-erro   THEN
                  DO:
                      MESSAGE tt-erro.dscritic.
                      RETURN "NOK".
                  END.
         END.

    FIND FIRST tt-extrato-cartao NO-LOCK NO-ERROR.

    IF NOT AVAIL tt-extrato-cartao THEN DO: 
        MESSAGE "FATURA NAO ENCONTRADA!".
        RETURN  "NOK".
    END.


    FIND FIRST crapcop WHERE
               crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" +
                          par_dsiduser.

    UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").

    ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
           aux_nmarqimp = aux_nmarquiv + ".ex"
           aux_nmarqpdf = aux_nmarquiv + ".pdf"
           tot_vlcrdolr    = 0
           tot_vldbdolr    = 0
           tot_vlcrreal    = 0
           tot_vldbreal    = 0
           tel_dtextrat    = STRING(MONTH(par_dtvctini),"99") + "/" + 
                             STRING(YEAR(par_dtvctini))
           aux_nrcrcard = "****.****.****." + SUBSTR(STRING(par_nrcrcard),LENGTH(STRING(par_nrcrcard)) - 3).

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

    ASSIGN aux_tituloIm = "EXTRATO CARTAO DE CREDITO CECRED VISA".

    /** TITULO **/
    DISPLAY STREAM str_1
                   aux_tituloIm  WITH FRAME f_titulo.


    /** CABECALHO **/
    DISP STREAM str_1 tt-extrato-cartao.nrdconta
                  tt-extrato-cartao.nmprimtl
                  aux_nrcrcard
                  tt-extrato-cartao.vllimite 
                  tt-extrato-cartao.nmtitcrd
                  tel_dtextrat              
                  WITH FRAME f_infrelatorio.
/*                   DOWN WITH FRAME f_infrelatorio. */


    /** TITULO DAS COLUNAS **/
    VIEW STREAM str_1 FRAME f_titrelatorio.


    /** EXIBICAO DOS DADOS DO CARTAO **/
    FOR EACH tt-extrato-cartao NO-LOCK
        BY tt-extrato-cartao.dtcompra:    
    
       IF  tt-extrato-cartao.cdmoedtr = "R$" THEN DO:
           ASSIGN rel_vlcrdolr = 0             
                  rel_vldbdolr = 0 .
           
           IF  tt-extrato-cartao.indebcre = "C" THEN 
               ASSIGN rel_vlcrreal = tt-extrato-cartao.vlcparea
                      rel_vldbreal = 0. 
       
           ELSE
               ASSIGN rel_vlcrreal = 0
                      rel_vldbreal = tt-extrato-cartao.vlcparea.
       END.
       ELSE
            
           IF tt-extrato-cartao.indebcre = "C" THEN 
               ASSIGN rel_vlcrreal = tt-extrato-cartao.vlcparea
                      rel_vldbreal = 0
                      rel_vlcrdolr = tt-extrato-cartao.vlcpaori             
                      rel_vldbdolr = 0.
           ELSE
               ASSIGN rel_vlcrreal = 0
                      rel_vldbreal = tt-extrato-cartao.vlcparea
                      rel_vlcrdolr = 0           
                      rel_vldbdolr = tt-extrato-cartao.vlcpaori.
    
    
        /***Soma dos valores de credito e debito em real e dolar e o Saldo.***/
        ASSIGN tot_vlcrdolr = tot_vlcrdolr + rel_vlcrdolr
               tot_vldbdolr = tot_vldbdolr + rel_vldbdolr
               tot_vlcrreal = tot_vlcrreal + rel_vlcrreal
               tot_vldbreal = tot_vldbreal + rel_vldbreal
               tot_vlrsaldo = tot_vldbreal - tot_vlcrreal
               tt-extrato-cartao.nmcidade  = 
                    SUBSTR(TRIM(tt-extrato-cartao.nmcidade),1,22).
        
        DISP STREAM str_1 tt-extrato-cartao.dtcompra
                          tt-extrato-cartao.dsestabe
                          tt-extrato-cartao.nmcidade
                          rel_vlcrdolr              
                          rel_vldbdolr              
                          rel_vlcrreal              
                          rel_vldbreal 
               WITH FRAME f_detlhextrato.
          DOWN WITH FRAME f_detlhextrato.
    
    END.
    
    DISP STREAM str_1 tot_vlcrdolr 
                      tot_vldbdolr
                      tot_vlcrreal
                      tot_vldbreal 
                      tot_vlrsaldo
           WITH FRAME f_totvalor.
      DOWN WITH FRAME f_totvalor.


    OUTPUT STREAM str_1 CLOSE.


    IF  par_idorigem = 5  THEN  /** Ayllos Web **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            DO WHILE TRUE:

                RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                    SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024.".
                        LEAVE.
                    END.

                RUN gera-pdf-impressao IN h-b1wgen0024 (INPUT aux_nmarqimp,
                                                        INPUT aux_nmarqpdf).

                /** Copiar pdf para visualizacao no Ayllos WEB **/
                IF  SEARCH(aux_nmarqpdf) = ?  THEN
                    DO:
                        ASSIGN aux_dscritic = "Nao foi possivel gerar" +
                                              " a impressao.".
                        LEAVE.
                    END.

                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                   '"scp ' + aux_nmarqpdf + ' scpuser@' + aux_srvintra +
                                   ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                                   '/temp/" 2>/dev/null').

                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.

            IF  aux_dscritic <> ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-erro  THEN
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT 0,
                                       INPUT 0,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                    UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

                    RETURN "NOK".
                END.

            UNIX SILENT VALUE ("rm " + aux_nmarquiv + "* 2>/dev/null").

        END.

    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

END PROCEDURE.

/*............................................................................*/



