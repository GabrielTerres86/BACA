/*.............................................................................

    Programa  : sistema/generico/procedures/b1wgen0038.p
    Autor     : David
    Data      : Janeiro/2009                  Ultima Atualizacao: 02/04/2019
    
    Dados referentes ao programa:

    Objetivo  : BO referente ao modulo Meu Cadastro da Conta On-Line e
                rotina ENDERECO da tela CONTAS.

    Alteracoes: 31/03/2010 - Adaptacao para tela CONTAS (David).
    
                22/09/2010 -  Adicionado tratamento para conta 'pai' 
                              ou 'filha' (Gabriel - DB1).
                              
                20/12/2010 -  Adicionado parametros na chamada do procedure
                              Replica_Dados para tratamento do log e  erros
                              da validação na replicação (Gabriel - DB1).
                              
                07/04/2011 - Inclusão de Busca Endereço - CEP integrado.
                             Validacao de CEP. (André - DB1)
                             
                28/04/2011 - Inclusão do procedimento trata-inicio-resid.
                             Alteracao do valida-endereco, alterar-endereco.
                             Passado parametro dtinires no lugar do antigo
                             nranores. (André - DB1)
                    
                15/06/2011 - Adicionado verificacao de endereco com a base
                             dos correios em obtem-atualizacao-endereco 
                             (Jorge).      
                             
                24/06/2011 - Utilizar campo crapdat.dtmvtolt na procedure 
                             trata-inicio-resid 
                           - Ajustes na validacao de novo registro crapdne 
                             (David).
                             
                01/07/2011 - Includos parametros nas procedures validar-endereco
                             e alterar-endereco (Henrique).
                           - Gravar alteracoes dos campos nrdoapto cddbloco na
                             tabela do banco (Henrique).
                           - Ajuste na procedure de busca utilizada no zoom de 
                             enderecos (David).
                             
                27/07/2011 - Ajuste no log caddne.log (David). 
                
                28/07/2011 - Adicionado verificacao se tipo de logradouro esta
                             contido em logradouro em valida-endereco-cep.
                           - Funcao ValidaStringEndereco melhorada (Jorge)
                           
                12/12/2011 - Adicionado procedures referentes a endereços e 
                             importacao/gravacao de arquivos dos correios
                             (Henrique - Jorge).
                             
                04/01/2012 - Tratamento de arquivos de CEP: CPC, UNID_OPER e 
                             GRANDE_USUARIO. (Rafael)
                             
                04/04/2012 - Adicionado idorigem na chamada da proc. 
                             busca-endereco e trata-busca-endereco (Jorge)
                
                04/06/2012 - Projeto Adaptação de Fontes - Substituição da função 
                             CONTAINS pela MATCHES (Lucas R.).            
                             
                10/06/2013 - Alterado pesquisa na crapdne devido ao excesso de
                             leituras - MATCHES para CONTAINS. (Rafael)
                             
                09/08/2013 - Gravação de registro na crapdoc quando houver
                             alteração de endereco (Jean Michel).
                             
                29/11/2013 - refeito alteração de 04/06/2012 (Guilherme).
                     
                20/01/2014 - Alteração na gravação de registro na crapdoc
                             quando houver alteração de endereco (Jean Michel).
                             
                13/02/2014 - Incluido a chamada da procedure 
                             "atualiza_data_manutencao_cadastro" dentro da
                             procedure "alterar-endereco". (Reinert)        
                             
                05/03/2014 - Incluso VALIDATE (Daniel).                      
                
                16/04/2014 - Retirado validacao antes da criacao da crapdoc 
                             dos par_incasprp, par_vlalugue, par_complend, 
                             par_nrdoapto,par_cddbloco, par_nrcxapst na 
                             procedure alterar-endereco (Lucas R)    
                             
                30/07/2014 - Truncar nome extenso do logradouro na importacao
                             de enderecos (David).
                             
                14/07/2015 - Reformulacao cadastral (Gabriel-RKAM).
                
                25/01/2016 - Melhoria 147 - Adicionar Campos e Aprovacao de 
				             Transferencia entre PAs (Heitor - RKAM)
                             
				23/06/2016 - Ajustes na procedure grava-importacao para qdo
				             houver algum erro na importacao devolver uma
							 mensagem amigavel (Tiago SD427693).             
               
			    07/12/2016 - P341-Automatização BACENJUD - Alterar o uso da descrição do
                             departamento passando a considerar o código (Renato Darosci)      
               
               17/01/2017 - Adicionado chamada a procedure de replicacao do 
                            endereco para o CDC. (Reinert Prj 289)		

                11/08/2017 - Incluído o número do cpf ou cnpj na tabela crapdoc.
                             Projeto 339 - CRM. (Lombardi)
                            
				16/08/2017 - Ajuste realizado para que ao informar cep 0 no endereço do tipo (13,14)
							 e exista registro na crapenc, deletamos o mesmo. (Kelvin/Andrino)
                            
               22/09/2017 - Adicionar tratamento para caso o inpessoa for juridico gravar 
                            o idseqttl como zero (Luacas Ranghetti #756813)
               
               05/10/2017 - Alterado rotina alterar-endereco-viainternetbank
                            para garantir que nao crie 2 enc com tipo 12. 
							              PRJ339 -CRM (Odirlei-AMcom).	
                            
               13/02/2018 - Ajustes na geraçao de pendencia de digitalizaçao.
                             PRJ366 - tipo de conta (Odirlei-AMcom)             

			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

               02/04/2019 - PRB0040682 - Correcao na rotina alterar-endereco-viainternetbank para receber numero 
                            de logradouro com mais do que 9 posicoes para entao tratar o valor
                            recebido da rotina 45 (Andreatta-Mouts)

.............................................................................*/


/*................................ DEFINICOES ...............................*/

{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-BO=SIM }
{ sistema/generico/includes/b1wgen0168tt.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.
DEF STREAM str_2.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_nrdindex AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_firststr AS CHAR                                           NO-UNDO.

DEF TEMP-TABLE tt-crapenc-old NO-UNDO LIKE crapenc.
DEF TEMP-TABLE tt-crapenc-new NO-UNDO LIKE crapenc.

/** Temp-Tables para procedure de consulta de enderecos (zoom) **/
DEF TEMP-TABLE tt-crapdne     NO-UNDO LIKE crapdne
    FIELD nrdrowid AS ROWID
    INDEX tt-crapdne1 idoricad nmextlog.
DEF TEMP-TABLE tt-crapdne-log NO-UNDO LIKE crapdne
    INDEX tt-crapdne-log1 AS WORD-INDEX nmextcid
    INDEX tt-crapdne-log2 cduflogr.
DEF TEMP-TABLE tt-crapdne-cid NO-UNDO LIKE crapdne
    INDEX tt-crapdne-cid1 cduflogr.

FUNCTION BuscaDescricaoImovel 
         RETURNS CHAR (INPUT par_incasprp AS INTE) FORWARD.

FUNCTION ValidaStringEndereco
         RETURNS LOGI (INPUT par_dsstrenc AS CHAR,
                       INPUT par_nmdcampo AS CHAR,
                      OUTPUT par_dscritic AS CHAR) FORWARD.

FUNCTION ValidaUF RETURNS LOGI (INPUT par_cdufende AS CHAR) FORWARD.


/*............................ PROCEDURES EXTERNAS ...........................*/


               /** PROCEDURES PARA UTILIZACAO NO INTERNETBANK **/               


/******************************************************************************/
/**       Procedure para obter enderecos para alteração no InternetBank      **/
/******************************************************************************/
PROCEDURE obtem-enderecos-viainternetbank: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-endereco-cooperado.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-endereco-cooperado.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter enderecos do cooperado".

    IF  par_idorigem <> 3  THEN  /** InternetBank **/
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Sistema solicitante invalido.".
               
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
     
            RETURN "NOK".
        END.

    /** Dados Residenciais - Temporario **/
    FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                            crapenc.nrdconta = par_nrdconta AND
                            crapenc.idseqttl = par_idseqttl AND
                            crapenc.tpendass = 12 
                            NO-LOCK NO-ERROR.
            
    IF  NOT AVAILABLE crapenc  THEN
        /** Dados Residenciais **/
        FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                                crapenc.nrdconta = par_nrdconta AND
                                crapenc.idseqttl = par_idseqttl AND
                                crapenc.tpendass = 10 
                                NO-LOCK NO-ERROR.

    IF  AVAILABLE crapenc  THEN
        RUN grava-endereco ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT TRUE ).

    /** Dados Comerciais **/
    FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                            crapenc.nrdconta = par_nrdconta AND
                            crapenc.idseqttl = par_idseqttl AND
                            crapenc.tpendass = 9
                            NO-LOCK NO-ERROR.
                                                                                    
    IF  AVAILABLE crapenc  THEN
        RUN grava-endereco ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT FALSE ).      

    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN "OK".
                                                                             
END PROCEDURE.


/******************************************************************************/
/**   Procedure para alteracao dos enderecos do cooperado via InternetBank   **/
/******************************************************************************/
PROCEDURE alterar-endereco-viainternetbank: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgtpenc AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrendere AS INT64                          NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complend AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdoapto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddbloco AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdseqinc AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpendass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_dsendere AS CHAR                                    NO-UNDO.
    DEF VAR aux_complend AS CHAR                                    NO-UNDO.
    DEF VAR aux_cddbloco AS CHAR                                    NO-UNDO. 
    DEF VAR aux_nmbairro AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmcidade AS CHAR                                    NO-UNDO.
    DEF VAR aux_cdufende AS CHAR                                    NO-UNDO.

    DEF VAR aux_nrdoapto AS INTE                                    NO-UNDO. 
    DEF VAR aux_nrendere AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcepend AS INTE                                    NO-UNDO.
    DEF VAR aux_nrcxapst AS INTE                                    NO-UNDO.
    DEF VAR aux_cdseqinc AS INTE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alteracao de Endereco " + 
                         (IF  par_flgtpenc  THEN
                              "Residencial"
                          ELSE
                              "Comercial")
           aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    TRANS_ENDERECO:
    
    DO TRANSACTION ON ERROR  UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO
                   ON ENDKEY UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO:

        IF  par_idorigem <> 3  THEN /** InternetBank **/
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Sistema solicitante invalido.".

                UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.
            END.
    
        /* Nao permitir logradou com mais do que 9 posicoes */
        IF  LENGTH(par_nrendere) > 9 THEN 
            DO:
				ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Numero invalido!".

                UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.
            END.          
       
 
        IF  par_flgtpenc  THEN /** Residencial **/
            DO:
                IF  par_tpendass <> 12  THEN
                    DO:
                        FIND LAST crapenc WHERE 
                                  crapenc.cdcooper = par_cdcooper AND
                                  crapenc.nrdconta = par_nrdconta AND
                                  crapenc.idseqttl = par_idseqttl AND
                                  crapenc.tpendass = 10 /** Residencial **/
                                  NO-LOCK NO-ERROR.

                        IF  NOT AVAILABLE crapenc  THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Endereco residencial " +
                                                      "nao cadastrado.".

                                UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.
                            END.
                            
                        IF  crapenc.nrcepend <> par_nrcepend  OR
                            crapenc.dsendere <> par_dsendere  OR
                            crapenc.nrendere <> par_nrendere  OR
                            crapenc.complend <> par_complend  OR
                            crapenc.nrdoapto <> par_nrdoapto  OR
                            crapenc.cddbloco <> par_cddbloco  OR
                            crapenc.nmbairro <> par_nmbairro  OR
                            crapenc.nmcidade <> par_nmcidade  OR
                            crapenc.cdufende <> par_cdufende  OR
                            crapenc.nrcxapst <> par_nrcxapst  THEN
                            DO:
                                FIND LAST crapenc WHERE 
                                          crapenc.cdcooper = par_cdcooper AND
                                          crapenc.nrdconta = par_nrdconta AND
                                          crapenc.idseqttl = par_idseqttl AND
                                          crapenc.tpendass = 12           
                                          NO-LOCK NO-ERROR.
                                       
                                IF  AVAILABLE crapenc  THEN
                                    DO:
                                      IF crapenc.dsendere = par_dsendere AND
                                         crapenc.nrendere = par_nrendere THEN
                                        DO:
                                    
                                        ASSIGN aux_cdcritic = 0
                                               aux_dscritic = "Endereco ja " +
                                                              "cadastrado para "
                                                              + "o titular.".

                                        UNDO TRANS_ENDERECO, 
                                        LEAVE TRANS_ENDERECO.
                                    END.

                                        /* Caso ja exista o tipo de endereco 
                                           deve atualizar o registro */
                                        
                                        DO aux_contador = 1 TO 10:
        
                                          ASSIGN aux_cdcritic = 0
                                                 aux_dscritic = "".
                                                 
                                FIND LAST crapenc WHERE 
                                            crapenc.cdcooper = par_cdcooper AND
                                            crapenc.nrdconta = par_nrdconta AND
                                            crapenc.idseqttl = par_idseqttl AND
                                            crapenc.tpendass = 12  
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.  
                                            
                                          IF  NOT AVAILABLE crapenc  THEN
                                          DO:
                                              IF  LOCKED crapenc  THEN
                                                  DO:
                                                      ASSIGN aux_dscritic = "Registro " +
                                                             "do endereco esta sendo " +
                                                             "alterado. Tente novamente.".
                                                      PAUSE 1 NO-MESSAGE.
                                                      NEXT.
                                                  END.
                                              ELSE    
                                                  ASSIGN aux_dscritic = "Endereco para " +
                                                         "cooperado nao cadastrado.".
                                          END.
                          
                                          LEAVE.  
                                          
                                          
                                        END. /** Fim do DO ... TO **/
                     
                                        IF  aux_dscritic <> ""  THEN
                                            UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.
                                            
                                        ASSIGN crapenc.dsendere = CAPS(par_dsendere)
                                               crapenc.nrendere = par_nrendere
                                               crapenc.cdufende = CAPS(par_cdufende)
                                               crapenc.nmbairro = CAPS(par_nmbairro)
                                               crapenc.nmcidade = CAPS(par_nmcidade)
                                               crapenc.complend = CAPS(par_complend)
                                               crapenc.nrdoapto = par_nrdoapto
                                               crapenc.cddbloco = CAPS(par_cddbloco)
                                               crapenc.nrcepend = par_nrcepend
                                               crapenc.nrcxapst = par_nrcxapst
                                               crapenc.idorigem = 1. /** Alteracao pelo InternetBank sera feita pelo cooperado **/    
                                            

                                    END.
                                /* Senao irá criar */    
                                ELSE 
                                DO:
                                FIND LAST crapenc WHERE 
                                          crapenc.cdcooper = par_cdcooper AND
                                          crapenc.nrdconta = par_nrdconta AND
                                          crapenc.idseqttl = par_idseqttl   
                                          NO-LOCK NO-ERROR.
                            
                                par_cdseqinc = IF  AVAILABLE crapenc  THEN 
                                                   crapenc.cdseqinc + 1
                                               ELSE 
                                                   1.
                                CREATE crapenc.
                                ASSIGN crapenc.cdcooper = par_cdcooper
                                       crapenc.nrdconta = par_nrdconta
                                       crapenc.idseqttl = par_idseqttl
                                       crapenc.cdseqinc = par_cdseqinc
                                       crapenc.dsendere = CAPS(par_dsendere)
                                       crapenc.nrendere = par_nrendere
                                       crapenc.tpendass = 12 /** Correspond. **/
                                       crapenc.cdufende = CAPS(par_cdufende)
                                       crapenc.nmbairro = CAPS(par_nmbairro)
                                       crapenc.nmcidade = CAPS(par_nmcidade)
                                       crapenc.complend = CAPS(par_complend)
                                       crapenc.nrdoapto = par_nrdoapto
                                       crapenc.cddbloco = CAPS(par_cddbloco)
                                       crapenc.nrcepend = par_nrcepend
                                       crapenc.nrcxapst = par_nrcxapst
                                       crapenc.idorigem = 1. /** Alteracao pelo InternetBank sera feita pelo cooperado **/
                                VALIDATE crapenc.
                            END.
                            END.
                        ELSE
                            ASSIGN par_flgerlog = FALSE.
                    END.
                ELSE
                    DO:
                        FIND LAST crapenc WHERE 
                                  crapenc.cdcooper  = par_cdcooper AND
                                  crapenc.nrdconta  = par_nrdconta AND
                                  crapenc.idseqttl  = par_idseqttl AND
                                  crapenc.tpendass  = par_tpendass AND
                                  crapenc.dsendere  = par_dsendere AND
                                  crapenc.nrendere  = par_nrendere AND
                                  crapenc.cdseqinc <> par_cdseqinc
                                  NO-LOCK NO-ERROR.
                                       
                        IF  AVAILABLE crapenc  THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Endereco ja cadastrado "
                                                      + "para o titular.".
                                
                                UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.
                            END.
                        
                        DO aux_contador = 1 TO 10:
        
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "".
                   
                            FIND crapenc WHERE 
                                 crapenc.cdcooper = par_cdcooper AND
                                 crapenc.nrdconta = par_nrdconta AND
                                 crapenc.idseqttl = par_idseqttl AND
                                 crapenc.cdseqinc = par_cdseqinc 
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                            IF  NOT AVAILABLE crapenc  THEN
                                DO:
                                    IF  LOCKED crapenc  THEN
                                        DO:
                                            ASSIGN aux_dscritic = "Registro " +
                                                   "do endereco esta sendo " +
                                                   "alterado. Tente novamente.".
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                    ELSE    
                                        ASSIGN aux_dscritic = "Endereco para " +
                                               "cooperado nao cadastrado.".
                                END.
                
                            LEAVE.
                   
                        END. /** Fim do DO ... TO **/
                     
                        IF  aux_dscritic <> ""  THEN
                            UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.

                        ASSIGN aux_dsendere     = crapenc.dsendere
                               aux_nrendere     = crapenc.nrendere
                               aux_nrcepend     = crapenc.nrcepend
                               aux_complend     = crapenc.complend
                               aux_nrdoapto     = crapenc.nrdoapto 
                               aux_cddbloco     = crapenc.cddbloco 
                               aux_nmbairro     = crapenc.nmbairro
                               aux_nmcidade     = crapenc.nmcidade
                               aux_cdufende     = crapenc.cdufende
                               aux_nrcxapst     = crapenc.nrcxapst
                               crapenc.dsendere = par_dsendere
                               crapenc.nrendere = par_nrendere
                               crapenc.nrcepend = par_nrcepend
                               crapenc.complend = par_complend
                               crapenc.nrdoapto = par_nrdoapto
                               crapenc.cddbloco = par_cddbloco
                               crapenc.nmbairro = par_nmbairro
                               crapenc.nmcidade = par_nmcidade
                               crapenc.cdufende = par_cdufende
                               crapenc.nrcxapst = par_nrcxapst
                               crapenc.idorigem = 1. /** Alteracao no InternetBank sera efetuada pelo cooperado **/
                    END.
            END.
        ELSE
            DO:
                IF  par_cdseqinc = 0  THEN
                    DO:
                        FIND LAST crapenc WHERE 
                                  crapenc.cdcooper = par_cdcooper AND
                                  crapenc.nrdconta = par_nrdconta AND
                                  crapenc.idseqttl = par_idseqttl   
                                  NO-LOCK NO-ERROR.
                            
                        ASSIGN par_cdseqinc = IF  AVAILABLE crapenc  THEN 
                                                  crapenc.cdseqinc + 1
                                              ELSE 
                                                  1.
                                                  
                        CREATE crapenc.
                        ASSIGN crapenc.cdcooper = par_cdcooper
                               crapenc.nrdconta = par_nrdconta
                               crapenc.idseqttl = par_idseqttl
                               crapenc.cdseqinc = par_cdseqinc
                               crapenc.dsendere = CAPS(par_dsendere)
                               crapenc.nrendere = par_nrendere
                               crapenc.tpendass = 9 /** Comercial **/
                               crapenc.cdufende = CAPS(par_cdufende)
                               crapenc.nmbairro = CAPS(par_nmbairro)
                               crapenc.nmcidade = CAPS(par_nmcidade)
                               crapenc.complend = CAPS(par_complend)
                               crapenc.nrdoapto = par_nrdoapto      
                               crapenc.cddbloco = CAPS(par_cddbloco)
                               crapenc.nrcepend = par_nrcepend
                               crapenc.nrcxapst = par_nrcxapst
                               crapenc.idorigem = 1. /** Alteracao no InternetBank sera realizada pelo cooperado **/
                        VALIDATE crapenc.
                    END.
                ELSE
                    DO:
                        DO aux_contador = 1 TO 10:
        
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "".
                   
                            FIND crapenc WHERE 
                                 crapenc.cdcooper = par_cdcooper AND
                                 crapenc.nrdconta = par_nrdconta AND
                                 crapenc.idseqttl = par_idseqttl AND
                                 crapenc.cdseqinc = par_cdseqinc 
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                            IF  NOT AVAILABLE crapenc  THEN
                                DO:
                                    IF  LOCKED crapenc  THEN
                                        DO:
                                            ASSIGN aux_dscritic = "Registro " +
                                                   "do endereco esta sendo " +
                                                   "alterado. Tente novamente.".
                                            PAUSE 1 NO-MESSAGE.
                                            NEXT.
                                        END.
                                    ELSE    
                                        ASSIGN aux_dscritic = "Endereco para " +
                                               "cooperado nao cadastrado.".
                                END.
                
                            LEAVE.
                   
                        END. /** Fim do DO ... TO **/
                     
                        IF  aux_dscritic <> ""  THEN
                            UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.

                        ASSIGN aux_dsendere     = crapenc.dsendere
                               aux_nrendere     = crapenc.nrendere
                               aux_nrcepend     = crapenc.nrcepend
                               aux_complend     = crapenc.complend
                               aux_nrdoapto     = crapenc.nrdoapto         
                               aux_cddbloco     = crapenc.cddbloco
                               aux_nmbairro     = crapenc.nmbairro
                               aux_nmcidade     = crapenc.nmcidade
                               aux_cdufende     = crapenc.cdufende
                               aux_nrcxapst     = crapenc.nrcxapst
                               crapenc.dsendere = par_dsendere
                               crapenc.nrendere = par_nrendere
                               crapenc.nrcepend = par_nrcepend
                               crapenc.complend = par_complend
                               crapenc.nrdoapto = par_nrdoapto      
                               crapenc.cddbloco = par_cddbloco
                               crapenc.nmbairro = par_nmbairro
                               crapenc.nmcidade = par_nmcidade
                               crapenc.cdufende = par_cdufende
                               crapenc.nrcxapst = par_nrcxapst
                               crapenc.idorigem = 1. /** Alteracao no InternetBank sera realizada pelo cooperado **/
                    END.
            END.

        FIND CURRENT crapenc NO-LOCK NO-ERROR.
         
        ASSIGN aux_flgtrans = TRUE.
    
    END. /** Fim do DO TRANSACTION - TRANS_ENDERECO **/
                              
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel concluir a requisicao.".
               
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
     
            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN 
        DO:
            RUN proc_gerar_log (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl,
                                INPUT par_nmdatela,
                                INPUT par_nrdconta,
                               OUTPUT aux_nrdrowid).
                
            IF  aux_nrcepend <> par_nrcepend  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "CEP",
                                         INPUT STRING(aux_nrcepend),
                                         INPUT STRING(par_nrcepend)).
                                         
            IF  aux_dsendere <> par_dsendere  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Endereco",
                                         INPUT aux_dsendere,
                                         INPUT par_dsendere).
                                                                      
            IF  aux_nrendere <> par_nrendere  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Numero",
                                         INPUT STRING(aux_nrendere),
                                         INPUT STRING(par_nrendere)).
                                                                               
            IF  aux_complend <> par_complend  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Complemento",
                                         INPUT aux_complend,
                                         INPUT par_complend).
                                                 
            IF  aux_nmbairro <> par_nmbairro  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Bairro",
                                         INPUT aux_nmbairro,
                                         INPUT par_nmbairro).
                                                                              
            IF  aux_nmcidade <> par_nmcidade  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Cidade",
                                         INPUT aux_nmcidade,
                                         INPUT par_nmcidade).
                                         
            IF  aux_cdufende <> par_cdufende  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "UF",
                                         INPUT aux_cdufende,
                                         INPUT par_cdufende).
                                                                          
            IF  aux_nrcxapst <> par_nrcxapst  THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "Caixa-Postal",
                                         INPUT STRING(aux_nrcxapst),
                                         INPUT STRING(par_nrcxapst)).
                                          
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Sequencia",
                                     INPUT "0",
                                     INPUT STRING(par_cdseqinc)).
                                     
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "Tipo",
                                     INPUT "0",
                                     INPUT STRING(par_tpendass)).
        END.

    RETURN "OK".            

END PROCEDURE.


      /** PROCEDURES PARA UTILIZACAO NA ROTINA ENDERECO DA TELA CONTAS **/      


/******************************************************************************/
/**               Procedure para obter enderecos do cooperado                **/
/******************************************************************************/
PROCEDURE obtem-endereco: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_msgconta AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_inpessoa AS INTE                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-endereco-cooperado.

    DEF VAR aux_nrdconta AS INTE                                    NO-UNDO.
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-endereco-cooperado.
 
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter endereco do cooperado".

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapass  THEN
        DO:
            ASSIGN aux_cdcritic = 9
                   aux_dscritic = "".
               
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
     
            RETURN "NOK".
        END.

    ASSIGN par_inpessoa = crapass.inpessoa.

    IF  crapass.inpessoa = 1  THEN 
        DO:
            FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta AND
                               crapttl.idseqttl = par_idseqttl NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crapttl  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Titular nao cadastrado.".
                       
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
        
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
             
                    RETURN "NOK".
                END.

            /** Endereco Pessoa Fisica - Residencial **/
            FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                                    crapenc.nrdconta = par_nrdconta AND
                                    crapenc.idseqttl = par_idseqttl AND
                                    crapenc.tpendass = 10 
                                    NO-LOCK NO-ERROR.
            
            /********************************************************/
            /** Se for 2o. titular e nao tem endereco cadastrado e **/
            /** o parentesco for 1-CONJUGE ou 3-FILHO(A) traz o    **/
            /** endereco do 1o. titular como sugestao              **/
            /********************************************************/
            IF  NOT AVAILABLE crapenc  AND
                crapttl.idseqttl > 1   AND
               (crapttl.cdgraupr = 1   OR
                crapttl.cdgraupr = 3)  THEN
                FIND LAST crapenc WHERE 
                          crapenc.cdcooper = par_cdcooper AND
                          crapenc.nrdconta = par_nrdconta AND
                          crapenc.idseqttl = 1            AND
                          crapenc.tpendass = 10 
                          NO-LOCK NO-ERROR.

            IF  AVAILABLE crapenc  THEN
                RUN grava-endereco ( INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT TRUE ).
                                     
        END.
    ELSE
        DO:
            /** Endereco Pessoa Juridica - Comercial **/
            FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                                    crapenc.nrdconta = par_nrdconta AND
                                    crapenc.idseqttl = 1            AND
                                    crapenc.cdseqinc = 1            AND
                                    crapenc.tpendass = 9 
                                    NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crapenc  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Registro de enderecos nao " +
                                          "encontrado! Impossivel continuar!".
                       
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
        
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdoperad,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid).
                                 
                    RETURN "NOK".
                END.

            RUN grava-endereco ( INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT FALSE ).
        END.

    /* Endereco correspondencia */
    FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                            crapenc.nrdconta = par_nrdconta AND
                            crapenc.idseqttl = par_idseqttl AND
                            crapenc.tpendass = 13
                            NO-LOCK NO-ERROR.
                                                                                    
    IF  AVAILABLE crapenc  THEN
        RUN grava-endereco ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT FALSE ).

    /* Endereco complementar */
    FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                            crapenc.nrdconta = par_nrdconta AND
                            crapenc.idseqttl = par_idseqttl AND
                            crapenc.tpendass = 14
                            NO-LOCK NO-ERROR.
                                                                                    
    IF  AVAILABLE crapenc  THEN
        RUN grava-endereco ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT FALSE ).       
        
    /*Alteração: Busca CPF do cooperado e procura por contar filhas. 
    (Gabriel - DB1)*/
    FOR FIRST crapttl FIELDS (nrcpfcgc)
                       WHERE crapttl.cdcooper = par_cdcooper AND 
                             crapttl.nrdconta = par_nrdconta AND 
                             crapttl.idseqttl = par_idseqttl NO-LOCK: 
    END.
    
    IF  AVAILABLE crapttl  THEN
        DO:
            /* Rotina para controle/replicacao entre contas */
            IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                RUN sistema/generico/procedures/b1wgen0077.p 
                    PERSISTENT SET h-b1wgen0077.
           
            RUN Busca_Conta IN h-b1wgen0077
                ( INPUT par_cdcooper,
                  INPUT par_nrdconta,
                  INPUT crapttl.nrcpfcgc,
                  INPUT par_idseqttl,
                 OUTPUT aux_nrdconta,
                 OUTPUT par_msgconta,
                 OUTPUT aux_cdcritic,
                 OUTPUT aux_dscritic ).

            IF  VALID-HANDLE(h-b1wgen0077) THEN
                DELETE OBJECT h-b1wgen0077.
        END.
    
    IF  par_flgerlog  THEN
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdoperad,
                            INPUT "",
                            INPUT aux_dsorigem,
                            INPUT aux_dstransa,
                            INPUT TRUE,
                            INPUT par_idseqttl,
                            INPUT par_nmdatela,
                            INPUT par_nrdconta,
                           OUTPUT aux_nrdrowid).

    RETURN "OK".
                                                                             
END PROCEDURE.


/******************************************************************************/
/**     Procedure para obter endereco que foi atualizado no InternetBank     **/
/******************************************************************************/
PROCEDURE obtem-atualizacao-endereco:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-endereco-cooperado.
    DEF OUTPUT PARAM TABLE FOR tt-msg-endereco.    
    
    EMPTY TEMP-TABLE tt-endereco-cooperado.
    EMPTY TEMP-TABLE tt-msg-endereco.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Obter atualizacao de endereco".
    
    /** Dados Residencias - Temporario **/
    FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                            crapenc.nrdconta = par_nrdconta AND
                            crapenc.idseqttl = par_idseqttl AND
                            crapenc.tpendass = 12           NO-LOCK NO-ERROR.

    IF  AVAILABLE crapenc  THEN
    DO:
        RUN grava-endereco ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT TRUE ).
        
        IF  NOT CAN-FIND(FIRST crapdne 
                         WHERE crapdne.nrceplog = crapenc.nrcepend)  OR 
            NOT CAN-FIND(FIRST crapdne
                         WHERE crapdne.nrceplog = crapenc.nrcepend  
                           AND (TRIM(crapenc.dsendere) MATCHES 
                               ("*" + TRIM(crapdne.nmextlog) + "*")
                            OR TRIM(crapenc.dsendere) MATCHES
                               ("*" + TRIM(crapdne.nmreslog) + "*"))) THEN
            DO:
                CREATE tt-msg-endereco.
                ASSIGN tt-msg-endereco.dsmsagem = 
                       "Endereco INTERNET nao encontrado na base dos Correios".
            END.  
    END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**   Procedure para excluir/confirmar endereco atualizado no InternetBank   **/
/******************************************************************************/
PROCEDURE gerenciar-atualizacao-endereco:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
 
    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF BUFFER crabenc  FOR crapenc.
    DEF BUFFER crabenc2 FOR crapenc.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.

    DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapenc-old.
    EMPTY TEMP-TABLE tt-crapenc-new.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = IF  par_cddopcao = "A"  THEN 
                              "Atualizar endereco do cooperado (InternetBank)"
                          ELSE
                              "Excluir atualizacao de endereco (InternetBank)"
           aux_flgtrans = FALSE
           aux_cdcritic = 0
           aux_dscritic = "".

    TRANS_ENDERECO:

    DO TRANSACTION ON ERROR  UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO
                   ON ENDKEY UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".

                UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.
            END.

        IF  crapass.inpessoa > 1  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Operacao nao permitida para pessoa " +
                                      "juridica.".

                UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.
            END.
                           
        FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                           crapttl.nrdconta = par_nrdconta AND
                           crapttl.idseqttl = par_idseqttl NO-LOCK NO-ERROR.
                       
        IF  NOT AVAILABLE crapttl  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Titular nao cadastrado.".
               
                UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.
            END.

        DO aux_contador = 1 TO 10:

            /** Dados Residencias **/
            FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                                    crapenc.nrdconta = par_nrdconta AND
                                    crapenc.idseqttl = par_idseqttl AND
                                    crapenc.tpendass = 10           
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapenc  THEN
                DO:
                    IF  LOCKED crapenc  THEN
                        DO:
                            IF  aux_contador = 10  THEN
                                DO:
                                    FIND LAST crapenc WHERE 
                                         crapenc.cdcooper = par_cdcooper AND
                                         crapenc.nrdconta = par_nrdconta AND
                                         crapenc.idseqttl = par_idseqttl AND
                                         crapenc.tpendass = 10 
                                         NO-LOCK NO-ERROR.
                                    
                                    RUN critica-lock (INPUT RECID(crapenc),
                                                      INPUT "banco",
                                                      INPUT "crapenc",
                                                      INPUT par_idorigem).
                                    LEAVE.
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                        END.
                    ELSE
                        ASSIGN aux_dscritic = "Endereco nao cadastrado.".
                END.

            LEAVE.

        END. /** Fim do DO ... TO **/

        IF  aux_dscritic <> ""  THEN
            UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.

        DO aux_contador = 1 TO 10:

            /** Dados Residencias - Temporario **/
            FIND LAST crabenc WHERE crabenc.cdcooper = par_cdcooper AND
                                    crabenc.nrdconta = par_nrdconta AND
                                    crabenc.idseqttl = par_idseqttl AND
                                    crabenc.tpendass = 12           
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crabenc  THEN
                DO:
                    IF  LOCKED crabenc  THEN
                        DO:
                            IF  aux_contador = 10  THEN
                                DO:
                                    FIND LAST crabenc WHERE 
                                         crabenc.cdcooper = par_cdcooper AND
                                         crabenc.nrdconta = par_nrdconta AND
                                         crabenc.idseqttl = par_idseqttl AND
                                         crabenc.tpendass = 12 
                                         NO-LOCK NO-ERROR.
                                    
                                    RUN critica-lock (INPUT RECID(crabenc),
                                                      INPUT "banco",
                                                      INPUT "crapenc",
                                                      INPUT par_idorigem).
                                    LEAVE.
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                        END.
                    ELSE
                        ASSIGN aux_dscritic = "Endereco nao cadastrado.".
                END.

            LEAVE.

        END. /** Fim do DO ... TO **/

        IF  aux_dscritic <> ""  THEN
            UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.

        FIND LAST crabenc2 WHERE crabenc2.cdcooper  = par_cdcooper     AND
                                 crabenc2.nrdconta  = par_nrdconta     AND
                                 crabenc2.idseqttl  = par_idseqttl     AND
                                 crabenc2.tpendass  = crapenc.tpendass AND
                                 crabenc2.dsendere  = crabenc.dsendere AND
                                 crabenc2.nrendere  = crabenc.nrendere AND
                                 crabenc2.cdseqinc <> crapenc.cdseqinc
                                 NO-LOCK NO-ERROR.
                                       
        IF  AVAILABLE crabenc2  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Endereco ja cadastrado para o titular.".

                UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.
            END.

        IF  par_flgerlog             AND 
            par_nmdatela = "CONTAS"  THEN
            DO:
                { sistema/generico/includes/b1wgenalog.i }
            END.

        CREATE tt-crapenc-old.
        BUFFER-COPY crapenc TO tt-crapenc-old.

        /** Atualizar novo endereco **/
        IF  par_cddopcao = "A"  THEN
            DO:
                ASSIGN crapenc.dsendere = crabenc.dsendere
                       crapenc.nrendere = crabenc.nrendere
                       crapenc.nrcepend = crabenc.nrcepend
                       crapenc.complend = crabenc.complend
                       crapenc.nrdoapto = crabenc.nrdoapto
                       crapenc.cddbloco = crabenc.cddbloco
                       crapenc.nmbairro = crabenc.nmbairro
                       crapenc.nmcidade = crabenc.nmcidade
                       crapenc.cdufende = crabenc.cdufende
                       crapenc.nrcxapst = crabenc.nrcxapst
                       crapenc.idorigem = crabenc.idorigem.

                CREATE tt-crapenc-new.
                BUFFER-COPY crapenc TO tt-crapenc-new.
            END.

        DELETE crabenc.

        /** Indica que endereco foi cadastrado via InternetBank **/
        ASSIGN log_flencnet = TRUE.

        IF  par_flgerlog             AND 
            par_nmdatela = "CONTAS"  THEN
            DO:
                { sistema/generico/includes/b1wgenllog.i }
            END.
        
        FIND CURRENT crapenc NO-LOCK NO-ERROR.
        
        /* Realiza a replicacao dos dados para as 
        contas relacionadas ao coop. (Gabriel - DB1 )*/
        IF  par_idseqttl = 1 AND par_nmdatela = "CONTAS" THEN 
            DO:
               IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                   RUN sistema/generico/procedures/b1wgen0077.p 
                       PERSISTENT SET h-b1wgen0077.
               
               RUN Replica_Dados IN h-b1wgen0077
                   ( INPUT par_cdcooper,
                     INPUT par_cdagenci,
                     INPUT par_nrdcaixa,
                     INPUT par_cdoperad,
                     INPUT par_nmdatela,
                     INPUT par_idorigem,
                     INPUT par_nrdconta,
                     INPUT par_idseqttl,
                     INPUT "ENDERECO",
                     INPUT par_dtmvtolt,
                     INPUT FALSE, /*par_flgerlog*/
                    OUTPUT aux_cdcritic,
                    OUTPUT aux_dscritic,
                    OUTPUT TABLE tt-erro ) NO-ERROR.

               IF  VALID-HANDLE(h-b1wgen0077) THEN
                   DELETE OBJECT h-b1wgen0077.
    
               IF  RETURN-VALUE <> "OK" THEN
                   UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.
            END.

        ASSIGN aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANS_ENDERECO **/

    IF  VALID-HANDLE(h-b1wgen0077) THEN
        DELETE OBJECT h-b1wgen0077.

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                ASSIGN aux_dscritic = "Nao foi possivel " + 
                                     (IF  par_cddopcao = "A"  THEN 
                                          "atualizar"
                                      ELSE
                                          "excluir") +
                                      " o endereco.".
                                      
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
     
            RETURN "NOK".
        END.
    
    IF  par_flgerlog  THEN
        RUN proc_gerar_log_tab (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl, 
                                INPUT par_nmdatela, 
                                INPUT par_nrdconta, 
                                INPUT TRUE,
                                INPUT BUFFER tt-crapenc-old:HANDLE,
                                INPUT BUFFER tt-crapenc-new:HANDLE).
        
    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**                Procedure para validar endereco do cooperado              **/
/******************************************************************************/
PROCEDURE validar-endereco: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_incasprp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinires AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlalugue AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrendere AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complend AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdoapto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddbloco AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpendass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgrepli AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgerror AS LOGI                                    NO-UNDO.
    DEF VAR aux_dttest   AS DATE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Validar endereco do cooperado"
           aux_flgerror = TRUE
           aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:

        IF  par_tpendass = 9    OR 
            par_tpendass = 10   THEN
            DO:
                IF  par_incasprp < 1  OR 
                    par_incasprp > 5  THEN
                    DO:
                        ASSIGN aux_dscritic = "Indicador de imovel invalido.".
                        LEAVE.
                    END.
     
                IF  par_nrcepend = 0  THEN
                    DO: 
                       ASSIGN aux_dscritic = "CEP deve ser informado.".
                       LEAVE.
                    END.
            END.
        ELSE
            DO:
                IF   par_nrcepend = 0   THEN
                     DO:
                         ASSIGN aux_flgerror = FALSE.
                         LEAVE.
                     END.
            END.

        IF  NOT par_flgrepli AND 
            NOT CAN-FIND(FIRST crapdne 
                         WHERE crapdne.nrceplog = par_nrcepend)  THEN
            DO:
                ASSIGN aux_dscritic = "CEP nao cadastrado.".
                LEAVE.
            END.

        IF  par_dsendere = ""  THEN
            DO: 
                ASSIGN aux_dscritic = "Endereco deve ser informado.".
                LEAVE.
            END.

        IF  NOT par_flgrepli AND 
            NOT CAN-FIND(FIRST crapdne
                         WHERE crapdne.nrceplog = par_nrcepend  
                           AND (TRIM(par_dsendere) MATCHES 
                               ("*" + TRIM(crapdne.nmextlog) + "*")
                            OR TRIM(par_dsendere) MATCHES
                               ("*" + TRIM(crapdne.nmreslog) + "*"))) THEN
            DO:
                ASSIGN aux_dscritic = "Endereco nao pertence ao CEP.".
                LEAVE.
            END.
            
        IF  NOT ValidaStringEndereco (INPUT par_dsendere,
                                      INPUT "Endereco",
                                     OUTPUT aux_dscritic)  THEN
            LEAVE.

        IF  NOT ValidaStringEndereco (INPUT par_complend,
                                      INPUT "Complemento",
                                     OUTPUT aux_dscritic)  THEN
            LEAVE.

        IF  par_nmbairro = ""  THEN
            DO: 
                ASSIGN aux_dscritic = "Bairro deve ser informado.".
                LEAVE.
            END.

        IF  NOT ValidaStringEndereco (INPUT par_nmbairro,
                                      INPUT "Bairro",
                                     OUTPUT aux_dscritic)  THEN
            LEAVE.

        IF  par_nmcidade = ""  THEN
            DO: 
                ASSIGN aux_dscritic = "Cidade deve ser informado.".
                LEAVE.
            END.

        IF  NOT ValidaStringEndereco (INPUT par_nmcidade,
                                      INPUT "Cidade",
                                     OUTPUT aux_dscritic)  THEN
            LEAVE.

        IF  NOT ValidaUF(INPUT par_cdufende)  THEN
            DO: 
                ASSIGN aux_dscritic = "Unidade de federacao errada.".
                LEAVE.
            END.

        IF  par_tpendass = 9    OR
            par_tpendass = 10   THEN
            DO:
                IF  par_dtinires = "" THEN
                    DO:
                        ASSIGN aux_dscritic = "Inicio de residencia deve ser informado.".
                        LEAVE.
                    END.
                
                ASSIGN aux_dttest = DATE(INTE(SUBSTR(par_dtinires,1,2)),1,
                                         INTE(SUBSTR(par_dtinires,4,4))) NO-ERROR.
                
                IF  aux_dttest > TODAY  THEN
                    DO:
                        ASSIGN aux_dscritic = 
                        "Data invalida. Data e maior que mes atual.".
                        LEAVE.
                    END.
                
                IF  ERROR-STATUS:ERROR    OR
                    SUBSTR(par_dtinires,3,1) <> "/"  THEN
                    DO:
                        ASSIGN aux_dscritic = 
                            "Data invalida. Formato correto 'mm/aaaa'.".
                        LEAVE.
                    END.
            END.
            
        ASSIGN aux_flgerror = FALSE.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  aux_flgerror  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                   
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
     
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/**                Procedure para alterar endereco do cooperado              **/
/******************************************************************************/
PROCEDURE alterar-endereco: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_incasprp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinires AS CHAR  /* Formato 99/9999 */    NO-UNDO.
    DEF  INPUT PARAM par_vlalugue AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrendere AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepend AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complend AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdoapto AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cddbloco AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmbairro AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxapst AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtprebem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vlprebem AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpendass AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_idorigee AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_msgalert AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_tpatlcad AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM log_msgatcad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM log_chavealt AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_msgrvcad AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_msgalert AS CHAR                                    NO-UNDO.

    DEF VAR aux_cdseqinc AS INTE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_tpendass AS INTE                                    NO-UNDO.
    DEF VAR aux_tpatlcad AS INTE                                    NO-UNDO.
    DEF VAR aux_msgatcad AS CHAR                                    NO-UNDO.
    DEF VAR aux_chavealt AS CHAR                                    NO-UNDO.
    DEF VAR aux_msgrvcad AS CHAR                                    NO-UNDO.
    DEF VAR aux_persemon AS DECI                                    NO-UNDO.
    DEF VAR aux_nrcpfcgc AS DECI                                    NO-UNDO.
    DEF VAR aux_idseqttl AS INT                                     NO-UNDO.    

    DEF VAR h-b1wgen0056 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0077 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0168 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0137 AS HANDLE                                  NO-UNDO.
    DEFINE BUFFER bcrapttl FOR crapttl.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapenc-old.
    EMPTY TEMP-TABLE tt-crapenc-new.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alterar endereco do cooperado"
           aux_flgtrans = FALSE
           aux_cdcritic = 0
           aux_dscritic = "".

    TRANS_ENDERECO:
    
    DO TRANSACTION ON ERROR  UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO
                   ON ENDKEY UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".

                UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.
            END.
        
        IF   crapass.inpessoa = 1 THEN DO:
            FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta AND 
                               crapttl.idseqttl = par_idseqttl NO-LOCK NO-ERROR.
            IF  NOT AVAILABLE crapttl  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Titular nao cadastrado.".

                    UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.
                END.
            
            ASSIGN aux_nrcpfcgc = crapttl.nrcpfcgc
                   aux_idseqttl = par_idseqttl.
          END.
        ELSE 
            ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc
                   aux_idseqttl = 0.
        
        ASSIGN aux_tpendass = IF   par_tpendass <> 0    THEN 
                                   par_tpendass
                              ELSE 
                              IF   crapass.inpessoa = 1 THEN 
                                   10 
                              ELSE 
                                   9.

                                        
        DO aux_contador = 1 TO 10:
                    
            /** Dados Residencias **/
            FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                                    crapenc.nrdconta = par_nrdconta AND
                                    crapenc.idseqttl = par_idseqttl AND
                                    crapenc.tpendass = aux_tpendass
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapenc  THEN
                DO:
                    IF  LOCKED crapenc  THEN
                        DO:
                            IF  aux_contador = 10  THEN
                                DO:
                                    FIND LAST crapenc WHERE 
                                         crapenc.cdcooper = par_cdcooper AND
                                         crapenc.nrdconta = par_nrdconta AND
                                         crapenc.idseqttl = par_idseqttl AND
                                         crapenc.tpendass = aux_tpendass 
                                         NO-LOCK NO-ERROR.
                                    
                                    RUN critica-lock (INPUT RECID(crapenc),
                                                      INPUT "banco",
                                                      INPUT "crapenc",
                                                      INPUT par_idorigem).
                                    LEAVE.
                                END.
                            ELSE
                                DO:
                                    PAUSE 1 NO-MESSAGE.
                                    NEXT.
                                END.
                        END.
                    ELSE
                        DO:
                           IF   (aux_tpendass = 13   OR 
                                 aux_tpendass = 14)  AND
                                 par_nrcepend = 0    THEN
                                 DO:
                                     ASSIGN par_msgalert = 
                            "Verifique se o item BENS deve ser atualizado."
                                            aux_flgtrans = TRUE.
                                     LEAVE TRANS_ENDERECO.
                                 END.

                           /** Obtem sequencial para criar endereco **/
                           FIND LAST crapenc WHERE 
                                crapenc.cdcooper = par_cdcooper AND
                                crapenc.nrdconta = par_nrdconta AND
                                crapenc.idseqttl = par_idseqttl 
                                NO-LOCK NO-ERROR. 
                                                    
                           IF  NOT AVAILABLE crapenc THEN
                               ASSIGN aux_cdseqinc = 1.
                            ELSE 
                               ASSIGN aux_cdseqinc = crapenc.cdseqinc + 
                                                     1.

                           CREATE crapenc.
                           ASSIGN crapenc.cdcooper = par_cdcooper
                                  crapenc.nrdconta = par_nrdconta
                                  crapenc.idseqttl = par_idseqttl
                                  crapenc.cdseqinc = aux_cdseqinc
                                  crapenc.tpendass = aux_tpendass
                                  crapenc.idorigem = par_idorigee.
                           VALIDATE crapenc.
                        END.
                END.
			ELSE
			   DO:
			   
			      IF (aux_tpendass = 13   OR 
					 aux_tpendass = 14)  AND
					 par_nrcepend = 0    THEN
				     DO:
					    
						DELETE crapenc.
						
					    aux_flgtrans = TRUE.
						LEAVE TRANS_ENDERECO.
				     END.	
			   
                END.

            LEAVE.

        END. /** Fim do DO ... TO **/
        
        IF  aux_dscritic <> ""  THEN
            UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.
        
        FIND FIRST crapbem WHERE crapbem.cdcooper = par_cdcooper AND
                                 crapbem.nrdconta = par_nrdconta AND
                                 crapbem.idseqttl = par_idseqttl AND
                                 crapbem.dsrelbem = "CASA PROPRIA"  
                                 NO-LOCK NO-ERROR.

        /** Bem Financiado ou Quitado **/
        IF  CAN-DO("1,2",STRING(par_incasprp))  AND 
            NOT AVAILABLE crapbem               THEN 
            DO:                          
                RUN sistema/generico/procedures/b1wgen0056.p 
                    PERSISTENT SET h-b1wgen0056.

                IF   par_vlalugue > 0  THEN
                     aux_persemon = 100 - (((par_vlprebem * par_qtprebem) * 100) / par_vlalugue).
                ELSE
                    aux_persemon = 0.

                                    
                RUN inclui-registro IN h-b1wgen0056 (INPUT par_cdcooper,
                                                     INPUT par_cdagenci,
                                                     INPUT par_nrdcaixa,
                                                     INPUT par_nrdconta,
                                                     INPUT par_idseqttl,
                                                     INPUT par_cdoperad,
                                                     INPUT par_nmdatela,
                                                     INPUT par_idorigem,
                                                     INPUT FALSE,
                                                     INPUT "CASA PROPRIA",
                                                     INPUT ?,
                                                     INPUT par_dtmvtolt,
                                                     INPUT "I",
                                                     INPUT aux_persemon, /*par_persemon*/
                                                     INPUT par_qtprebem,
                                                     INPUT par_vlprebem,
                                                     INPUT IF par_vlalugue > 0
                                                           THEN /*par_vlrdobem*/
                                                               par_vlalugue
                                                           ELSE
                                                               1,
                                                    OUTPUT aux_msgalert,
                                                    OUTPUT aux_tpatlcad,
                                                    OUTPUT aux_msgatcad,
                                                    OUTPUT aux_chavealt,
                                                    OUTPUT aux_msgrvcad,
                                                    OUTPUT TABLE tt-erro).

                DELETE PROCEDURE h-b1wgen0056.
                
                IF  RETURN-VALUE = "NOK"  THEN
                    UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.
            END.
        ELSE
        IF   CAN-DO("1,2",STRING(par_incasprp))   AND  /* Quitado/Financiado*/
             AVAIL crapbem                        THEN
             DO:
                 RUN sistema/generico/procedures/b1wgen0056.p 
                    PERSISTENT SET h-b1wgen0056.

                IF   par_vlalugue > 0  THEN
                     aux_persemon = 100 - (((par_vlprebem * par_qtprebem) * 100) / par_vlalugue).
                ELSE
                    aux_persemon = 0.
                                    
                RUN altera-registro IN h-b1wgen0056 (INPUT par_cdcooper,
                                                     INPUT par_cdagenci,
                                                     INPUT par_nrdcaixa,
                                                     INPUT par_nrdconta,
                                                     INPUT par_idseqttl,
                                                     INPUT par_cdoperad,
                                                     INPUT par_nmdatela,
                                                     INPUT par_idorigem,
                                                     INPUT FALSE,
                                                     INPUT ROWID(crapbem),
                                                     INPUT crapbem.dsrelbem,
                                                     INPUT par_dtmvtolt,
                                                     INPUT par_dtmvtolt,
                                                     INPUT "A",
                                                     INPUT aux_persemon,
                                                     INPUT par_qtprebem,
                                                     INPUT par_vlprebem,
                                                     INPUT par_vlalugue,
                                                     INPUT crapbem.idseqbem,
                                                    OUTPUT aux_msgalert,
                                                    OUTPUT aux_tpatlcad,
                                                    OUTPUT aux_msgatcad,
                                                    OUTPUT aux_chavealt,
                                                    OUTPUT aux_msgrvcad,
                                                    OUTPUT TABLE tt-erro).

                DELETE PROCEDURE h-b1wgen0056.

                IF  RETURN-VALUE = "NOK"  THEN
                    UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.

             END.

        IF  par_nmdatela = "CONTAS"  AND
            par_flgerlog             THEN
            DO:
               { sistema/generico/includes/b1wgenalog.i }
            END.

        /* Verificar se eh o ende. residencial da PF ou comercial da PJ */
        IF  (crapass.inpessoa = 1  AND par_tpendass = 10) OR 
            (crapass.inpessoa <> 1 AND par_tpendass = 9) THEN 
            DO:
          IF  crapenc.dsendere <> par_dsendere OR
              crapenc.nrendere <> par_nrendere OR
              crapenc.nrcepend <> par_nrcepend OR
              crapenc.nmcidade <> par_nmcidade OR
              crapenc.nmbairro <> par_nmbairro OR
              crapenc.cdufende <> par_cdufende THEN
              DO:
                  IF NOT VALID-HANDLE(h-b1wgen0137) THEN
                    RUN sistema/generico/procedures/b1wgen0137.p 
                        PERSISTENT SET h-b1wgen0137.
    
                    RUN gera_pend_digitalizacao IN h-b1wgen0137                    
                              ( INPUT par_cdcooper,
                                INPUT par_nrdconta,
                                INPUT aux_idseqttl,
                                INPUT aux_nrcpfcgc,
                                INPUT par_dtmvtolt,
                                INPUT "3",
                                INPUT par_cdoperad,
                               OUTPUT aux_cdcritic,
                               OUTPUT aux_dscritic).
                                            
                    IF  VALID-HANDLE(h-b1wgen0137) THEN
                      DELETE OBJECT h-b1wgen0137.
                    /* Rotina nao gerava critica
                    IF RETURN-VALUE <> "OK" THEN*/

                END.
            END.
        CREATE tt-crapenc-old.
        BUFFER-COPY crapenc TO tt-crapenc-old.
        
        IF   par_tpendass = 9    OR   
             par_tpendass = 10   THEN
             ASSIGN crapenc.incasprp = par_incasprp
                    crapenc.vlalugue = par_vlalugue.

        ASSIGN crapenc.dsendere = CAPS(par_dsendere)
               crapenc.nrendere = par_nrendere
               crapenc.complend = CAPS(par_complend)
               crapenc.nrdoapto = par_nrdoapto   
               crapenc.cddbloco = CAPS(par_cddbloco)
               crapenc.nrcxapst = par_nrcxapst
               crapenc.nrcepend = par_nrcepend
               crapenc.nmcidade = CAPS(par_nmcidade)
               crapenc.nmbairro = CAPS(par_nmbairro)
               crapenc.cdufende = CAPS(par_cdufende)
               crapenc.idorigem = par_idorigee.

        IF  par_dtinires <> "" AND 
           (par_tpendass = 9   OR   par_tpendass = 10)   THEN
            ASSIGN crapenc.dtinires = DATE(INTE(SUBSTR(par_dtinires,1,2)),1,
                                       INTE(SUBSTR(par_dtinires,4,4))).

        CREATE tt-crapenc-new.
        BUFFER-COPY crapenc TO tt-crapenc-new.

        IF  par_nmdatela = "CONTAS"  THEN 
            DO:    
               IF  par_flgerlog  THEN 
                   DO:
                       { sistema/generico/includes/b1wgenllog.i }
                   END.
               
               /* Realiza a replicacao dos dados para as 
               contas relacionadas ao coop. (Gabriel - DB1 )*/
               IF  par_idseqttl = 1 THEN 
                   DO:
                      IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                          RUN sistema/generico/procedures/b1wgen0077.p 
                              PERSISTENT SET h-b1wgen0077.
                      
                      RUN Replica_Dados IN h-b1wgen0077
                          ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_nmdatela,
                            INPUT par_idorigem,
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,
                            INPUT "ENDERECO",
                            INPUT par_dtmvtolt,
                            INPUT FALSE, /*par_flgerlog*/
                           OUTPUT aux_cdcritic,
                           OUTPUT aux_dscritic,
                           OUTPUT TABLE tt-erro ) NO-ERROR.

                      IF  VALID-HANDLE(h-b1wgen0077) THEN
                          DELETE OBJECT h-b1wgen0077.
            
                      IF  RETURN-VALUE <> "OK" THEN
                          UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.
                      
                      FIND FIRST bcrapttl
                           WHERE bcrapttl.cdcooper = par_cdcooper AND
                                 bcrapttl.nrdconta = par_nrdconta AND
                                 bcrapttl.idseqttl = par_idseqttl NO-ERROR.
                      
                      IF AVAILABLE bcrapttl THEN DO:

                          IF  NOT VALID-HANDLE(h-b1wgen0077) THEN
                              RUN sistema/generico/procedures/b1wgen0077.p 
                                  PERSISTENT SET h-b1wgen0077.

                          RUN Revisao_Cadastral IN h-b1wgen0077
                            ( INPUT par_cdcooper,
                              INPUT bcrapttl.nrcpfcgc,
                              INPUT par_nrdconta,
                             OUTPUT par_msgrvcad ).
                          
                          IF  VALID-HANDLE(h-b1wgen0077) THEN
                              DELETE OBJECT h-b1wgen0077.

                      END.
                      

                   END.

                   /* INICIO - Atualizar os dados da tabela crapcyb (CYBER) */
                   IF NOT VALID-HANDLE(h-b1wgen0168) THEN
                      RUN sistema/generico/procedures/b1wgen0168.p
                          PERSISTENT SET h-b1wgen0168.
                                
                   EMPTY TEMP-TABLE tt-crapcyb.
                  
                   CREATE tt-crapcyb.
                   ASSIGN tt-crapcyb.cdcooper = par_cdcooper
                          tt-crapcyb.nrdconta = par_nrdconta
                          tt-crapcyb.dtmancad = par_dtmvtolt.
                  
                   RUN atualiza_data_manutencao_cadastro
                       IN h-b1wgen0168(INPUT TABLE tt-crapcyb,
                                       OUTPUT aux_cdcritic,
                                       OUTPUT aux_dscritic).
                                
                   IF VALID-HANDLE(h-b1wgen0168) THEN
                      DELETE PROCEDURE(h-b1wgen0168).
                  
                   IF RETURN-VALUE <> "OK" THEN
                      UNDO TRANS_ENDERECO, LEAVE TRANS_ENDERECO.
                   /* FIM - Atualizar os dados da tabela crapcyb */

            END.

        FIND CURRENT crapenc NO-LOCK NO-ERROR.

        /* Quando for primeiro titular, vamos ver ser o cooperado eh 
           um conveniado CDC. Caso positivo, vamos replicar os dados
           alterados de endereco para as tabelas do CDC. */
        IF par_idseqttl = 1 THEN 
          DO:
        FOR FIRST crapcdr WHERE crapcdr.cdcooper = crapenc.cdcooper
                            AND crapcdr.nrdconta = crapenc.nrdconta
                            AND crapcdr.flgconve = TRUE NO-LOCK:

          IF aux_tpendass = 9 THEN
            DO:
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
              
              RUN STORED-PROCEDURE pc_replica_cdc
                aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                                    ,INPUT par_nrdconta
                                                    ,INPUT par_cdoperad
                                                    ,INPUT par_idorigem
                                                    ,INPUT par_nmdatela
                                                    ,INPUT 1
                                                    ,INPUT 0
                                                    ,INPUT 0
                                                    ,INPUT 0
                                                    ,0
                                                    ,"").

              CLOSE STORED-PROC pc_replica_cdc
                        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

              ASSIGN aux_cdcritic = 0
                     aux_dscritic = ""
                     aux_cdcritic = pc_replica_cdc.pr_cdcritic 
                                      WHEN pc_replica_cdc.pr_cdcritic <> ?
                     aux_dscritic = pc_replica_cdc.pr_dscritic 
                                      WHEN pc_replica_cdc.pr_dscritic <> ?.
                                                                            
              IF aux_cdcritic <> 0 OR aux_dscritic <> "" THEN
                DO:
                  ASSIGN par_msgalert = "Nao foi possivel replicar os dados para o CDC."
                                      + " Entre em contato com a equipe do CDC da Ailos."
                         aux_flgtrans = TRUE.
                  LEAVE TRANS_ENDERECO.
                END.

            END.
                            
        END.
          END.

        ASSIGN par_msgalert = "Verifique se o item BENS deve ser atualizado."
               aux_flgtrans = TRUE.

    END. /** Fim do DO TRANSACTION - TRANS_ENDERECO **/
    
    IF  VALID-HANDLE(h-b1wgen0077) THEN
        DELETE OBJECT h-b1wgen0077.

    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        DO:
                            ASSIGN aux_dscritic = "Nao foi possivel alterar " + 
                                                  "o endereco.".

                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,            /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                        END.
                END.
            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                      
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdoperad,
                                    INPUT aux_dscritic,
                                    INPUT aux_dsorigem,
                                    INPUT aux_dstransa,
                                    INPUT FALSE,
                                    INPUT par_idseqttl,
                                    INPUT par_nmdatela,
                                    INPUT par_nrdconta,
                                   OUTPUT aux_nrdrowid).
     
            RETURN "NOK".
        END.
    
    IF  par_flgerlog  THEN 
        RUN proc_gerar_log_tab (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT "",
                                INPUT aux_dsorigem,
                                INPUT aux_dstransa,
                                INPUT TRUE,
                                INPUT par_idseqttl, 
                                INPUT par_nmdatela, 
                                INPUT par_nrdconta, 
                                INPUT TRUE,
                                INPUT BUFFER tt-crapenc-old:HANDLE,
                                INPUT BUFFER tt-crapenc-new:HANDLE).

    RETURN "OK".

END PROCEDURE.


/*............................ PROCEDURES INTERNAS ...........................*/


PROCEDURE grava-endereco:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgtpenc AS LOGI                           NO-UNDO.

    DEF VAR aux_nranores AS CHAR                                    NO-UNDO.
    DEF VAR aux_qtprebem AS INTE                                    NO-UNDO.
    DEF VAR aux_vlprebem AS DECI                                    NO-UNDO.

    FIND FIRST crapbem WHERE crapbem.cdcooper = crapenc.cdcooper   AND
                             crapbem.nrdconta = crapenc.nrdconta   AND
                             crapbem.idseqttl = crapenc.idseqttl   AND
                             crapbem.dsrelbem = "CASA PROPRIA"
                             NO-LOCK NO-ERROR.

    IF   AVAIL crapbem    THEN
         ASSIGN aux_qtprebem = crapbem.qtprebem
                aux_vlprebem = crapbem.vlprebem.

    CREATE tt-endereco-cooperado.
    ASSIGN tt-endereco-cooperado.flgtpenc = par_flgtpenc
           tt-endereco-cooperado.incasprp = crapenc.incasprp
           tt-endereco-cooperado.dscasprp = IF  crapenc.incasprp = 1  THEN 
                                                "QUITADO"
                                            ELSE
                                            IF  crapenc.incasprp = 2  THEN 
                                                "FINANCI"
                                            ELSE
                                            IF  crapenc.incasprp = 3  THEN 
                                                "ALUGADO"
                                            ELSE
                                            IF  crapenc.incasprp = 4  THEN 
                                                "FAMILIA"
                                            ELSE
                                            IF  crapenc.incasprp = 5  THEN 
                                                "CEDIDO"
                                            ELSE 
                                                ""
           tt-endereco-cooperado.vlalugue = crapenc.vlalugue
           tt-endereco-cooperado.nrcepend = crapenc.nrcepend
           tt-endereco-cooperado.dsendere = crapenc.dsendere
           tt-endereco-cooperado.nrendere = crapenc.nrendere
           tt-endereco-cooperado.complend = crapenc.complend
           tt-endereco-cooperado.nrdoapto = crapenc.nrdoapto
           tt-endereco-cooperado.cddbloco = crapenc.cddbloco
           tt-endereco-cooperado.nmbairro = crapenc.nmbairro
           tt-endereco-cooperado.nmcidade = crapenc.nmcidade
           tt-endereco-cooperado.cdufende = crapenc.cdufende
           tt-endereco-cooperado.nrcxapst = crapenc.nrcxapst
           tt-endereco-cooperado.cdseqinc = crapenc.cdseqinc
           tt-endereco-cooperado.tpendass = crapenc.tpendass
           tt-endereco-cooperado.qtprebem = aux_qtprebem
           tt-endereco-cooperado.vlprebem = aux_vlprebem
           tt-endereco-cooperado.idorigem = crapenc.idorigem.

    IF  crapenc.dtinires <> ?  THEN
        DO:
            ASSIGN tt-endereco-cooperado.dtinires = 
                                SUBSTR(STRING(crapenc.dtinires,"99/99/9999"),4).

            RUN trata-inicio-resid  ( INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT tt-endereco-cooperado.dtinires,
                                     OUTPUT aux_nranores,
                                     OUTPUT TABLE tt-erro ).

            IF  CAN-FIND(FIRST tt-erro) THEN
                ASSIGN tt-endereco-cooperado.nranores = "".
            ELSE
                ASSIGN tt-endereco-cooperado.nranores = aux_nranores.
                    
        END.

END PROCEDURE.


PROCEDURE critica-lock:

    DEF  INPUT PARAM par_nrdrecid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdbanco AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmtabela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_loginusr AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmusuari AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdevice AS CHAR                                    NO-UNDO.
    DEF VAR aux_dtconnec AS CHAR                                    NO-UNDO.
    DEF VAR aux_numipusr AS CHAR                                    NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "Registro sendo alterado em outro terminal (" + 
                          par_nmtabela + ").".

    IF  par_idorigem = 3  THEN  /** InternetBank **/
        RETURN.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        RETURN.
        
    RUN acha-lock IN h-b1wgen9999 (INPUT par_nrdrecid,
                                   INPUT par_nmdbanco,
                                   INPUT par_nmtabela,
                                  OUTPUT aux_loginusr,
                                  OUTPUT aux_nmusuari,
                                  OUTPUT aux_dsdevice,
                                  OUTPUT aux_dtconnec, 
                                  OUTPUT aux_numipusr).

    DELETE PROCEDURE h-b1wgen9999.

    ASSIGN aux_dscritic = aux_dscritic + " Operador: " + 
                          aux_loginusr + " - " + aux_nmusuari.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE gravar-endereco-cep:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                             NO-UNDO.
    
    DEF  INPUT PARAM par_nrceplog AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cduflogr AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_dstiplog AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmextlog AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmreslog AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmextbai AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmresbai AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmextcid AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmrescid AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_dscmplog AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                            NO-UNDO. 
    DEF  INPUT PARAM par_flgalter AS LOGI                             NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = IF par_flgalter THEN 
                            "Altera endereco CEP"
                          ELSE
                            "Grava endereco CEP"
           aux_dscritic = ""
           aux_cdcritic = 0.

    ASSIGN par_cduflogr = CAPS(TRIM(par_cduflogr))
           par_dscmplog = CAPS(TRIM(par_dscmplog))
           par_dstiplog = CAPS(TRIM(par_dstiplog))
           par_nmextbai = CAPS(TRIM(par_nmextbai))
           par_nmextcid = CAPS(TRIM(par_nmextcid))
           par_nmextlog = CAPS(TRIM(par_nmextlog))
           par_nmresbai = CAPS(TRIM(par_nmresbai))
           par_nmrescid = SUBSTRING(CAPS(TRIM(par_nmrescid)),1,25)
           par_nmreslog = CAPS(TRIM(par_nmreslog)).

    IF  par_flgalter THEN
        DO:
            TRANS_END:

            DO TRANSACTION ON ENDKEY UNDO TRANS_END, LEAVE TRANS_END 
                           ON ERROR  UNDO TRANS_END, LEAVE TRANS_END:

                DO aux_contador = 1 TO 10:
                    
                    FIND crapdne WHERE ROWID(crapdne) = par_nrdrowid 
                                       EXCLUSIVE-LOCK NO-ERROR.
                
                    IF  NOT AVAIL crapdne THEN
                        DO:
                            IF  LOCKED crapdne THEN
                                DO:
                                    ASSIGN aux_cdcritic = 77.
                                    NEXT.
                                END.
                            ELSE
                                DO:
                                    ASSIGN aux_dscritic = "Falha ao atualizar o" 
                                                          + " endereco.".
                                    LEAVE.
                                END.
                        END.
                    
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = ""
                           crapdne.cduflogr = par_cduflogr
                           crapdne.dscmplog = par_dscmplog
                           crapdne.dstiplog = par_dstiplog
                           crapdne.nmextbai = par_nmextbai
                           crapdne.nmextcid = par_nmextcid
                           crapdne.nmextlog = par_nmextlog
                           crapdne.nmresbai = par_nmresbai
                           crapdne.nmrescid = par_nmrescid
                           crapdne.nmreslog = par_nmreslog.
                
                    LEAVE.
                
                END. /*  FIM do DO ... TO  */
            END. /* FIM DO TRANSACTION */
        END.
    ELSE
    DO:
        Grava: DO TRANSACTION
            ON ERROR  UNDO Grava, LEAVE Grava
            ON QUIT   UNDO Grava, LEAVE Grava
            ON STOP   UNDO Grava, LEAVE Grava
            ON ENDKEY UNDO Grava, LEAVE Grava:
        
            CREATE crapdne.
            ASSIGN crapdne.cduflogr = par_cduflogr
                   crapdne.dscmplog = par_dscmplog
                   crapdne.dstiplog = par_dstiplog
                   crapdne.nmextbai = par_nmextbai
                   crapdne.nmextcid = par_nmextcid
                   crapdne.nmextlog = par_nmextlog
                   crapdne.nmresbai = par_nmresbai
                   crapdne.nmrescid = par_nmrescid
                   crapdne.nmreslog = par_nmreslog
                   crapdne.nrceplog = par_nrceplog
                   crapdne.idtipdne = 1
                   crapdne.idoricad = 2 NO-ERROR.
            VALIDATE crapdne.
        
            IF  ERROR-STATUS:ERROR THEN
                ASSIGN aux_dscritic = ERROR-STATUS:GET-MESSAGE(1).
        
            LEAVE Grava.
        END.
        
        RELEASE crapdne.
    END.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 THEN
        DO:
            RUN gera_erro ( INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,           
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic ).

            RETURN "NOK".
        END.

    IF  par_flgerlog  THEN
        RUN gera_log_cad ( INPUT par_cdcooper,
                           INPUT par_dtmvtolt,
                           INPUT par_cdoperad,
                           INPUT par_nrceplog,
                           INPUT par_cduflogr,
                           INPUT par_dstiplog,
                           INPUT par_nmextlog,
                           INPUT par_nmreslog,
                           INPUT par_nmextbai,
                           INPUT par_nmresbai,
                           INPUT par_nmextcid,
                           INPUT par_nmrescid,
                           INPUT par_dscmplog ).

    RETURN "OK".

END PROCEDURE.


PROCEDURE gera_log_cad:
    
    DEF INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_nrceplog AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_cduflogr AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_dstiplog AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_nmextlog AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_nmreslog AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_nmextbai AS CHAR                             NO-UNDO. 
    DEF INPUT PARAM par_nmresbai AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_nmextcid AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_nmrescid AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_dscmplog AS CHAR                             NO-UNDO.

    /* Gera log no diretorio da Cecred pois a tabela de enderecos eh
       unificada, ou seja, nao utiliza cdcooper na chave             */

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
                            
    UNIX SILENT
         VALUE('echo "' + STRING(par_dtmvtolt, "99/99/9999")    +
              ' ' + STRING(TIME,"HH:MM:SS") + ' --> '           +
              'Coop.Oper. '  + crapcop.nmrescop        + ' - '  +
              'Operador '    + par_cdoperad            + ' - '  +
              'CEP '         + STRING(par_nrceplog)    + ' - '  +
              'Tipo Log. '   + STRING(par_dstiplog)    + ' - '  +
              'Nome Ext. '   + STRING(par_nmextlog)    + ' - '  +
              'Nome Res. '   + STRING(par_nmreslog)    + ' - '  +
              'Compl. '      + STRING(par_dscmplog)    + ' - '  +
              'Bairro Ext. ' + STRING(par_nmextbai)    + ' - '  +
              'Bairro Res. ' + STRING(par_nmresbai)    + ' - '  +
              'Cidade Ext. ' + STRING(par_nmextcid)    + ' - '  +
              'Cidade Res. ' + STRING(par_nmrescid)    + ' - '  +
              'UF '          + STRING(par_cduflogr)    + '.'  +
              '" >> /usr/coop/cecred/log/caddne.log').

END. 


PROCEDURE valida-endereco-cep:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nrceplog AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cduflogr AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_dstiplog AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmextlog AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmreslog AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmextbai AS CHAR                             NO-UNDO. 
    DEF  INPUT PARAM par_nmresbai AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmextcid AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nmrescid AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_dscmplog AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                            NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_flgerror AS LOGI                                      NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_flgerror = TRUE
           aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:

        IF  par_nrdrowid <> ?  THEN
            DO:
                FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                                   crapope.cdoperad = par_cdoperad 
                                   NO-LOCK NO-ERROR.
        
                IF  NOT CAN-DO("20,18",STRING(crapope.cddepart))  THEN
                    DO:
                        ASSIGN aux_cdcritic = 036 
                               par_nmdcampo = "nrceplog".
                        LEAVE.
                    END.
            END.

        IF  par_nrceplog = 0  THEN
            DO: 
                ASSIGN aux_dscritic = "CEP deve ser informado."
                       par_nmdcampo = "nrceplog".
                LEAVE.
            END.

        IF  par_cduflogr = ""  THEN
            DO: 
                ASSIGN aux_dscritic = "Sigla do Estado deve ser informada."
                       par_nmdcampo = "cduflogr".
                LEAVE.
            END.
    
        IF  NOT ValidaUF(INPUT par_cduflogr) THEN
            DO:
                ASSIGN aux_dscritic = "Sigla do Estado incorreta."
                       par_nmdcampo = "cduflogr".
                LEAVE.
            END.

        IF  par_dstiplog = ""  THEN
            DO: 
                ASSIGN aux_dscritic = "Tipo Logradouro deve ser informado."
                       par_nmdcampo = "dstiplog".
                LEAVE.
            END.
        
        IF  NOT ValidaStringEndereco (INPUT par_dstiplog,
                                      INPUT "Tipo Logradouro",
                                     OUTPUT aux_dscritic) THEN
            DO:
                ASSIGN aux_dscritic = "Tipo de logradouro invalido."
                       par_nmdcampo = "dstiplog".
                LEAVE.
            END.

        IF  NOT CAN-FIND(FIRST crapdne WHERE 
                               crapdne.dstiplog = par_dstiplog AND 
                               crapdne.idoricad = 1            NO-LOCK)  THEN
            DO:
                ASSIGN aux_dscritic = "Tipo de Logradouro invalido."
                       par_nmdcampo = "dstiplog".
                LEAVE.
            END.

        ASSIGN par_nmreslog = TRIM(par_nmreslog).

        IF  par_nmreslog = ""  THEN
            DO: 
                ASSIGN aux_dscritic = "Logradouro resumido deve ser informado."
                       par_nmdcampo = "nmreslog".
                LEAVE.
            END.

        IF  REPLACE(par_nmreslog,".","") = ""  OR 
            LENGTH(par_nmreslog) <= 2          THEN
            DO:
                ASSIGN aux_dscritic = "Logradouro resumido invalido."
                       par_nmdcampo = "nmreslog".
                LEAVE.
            END.

        IF  NOT ValidaStringEndereco (INPUT par_nmreslog,
                                      INPUT "Logradouro resumido",
                                     OUTPUT aux_dscritic) THEN
            DO:
                ASSIGN par_nmdcampo = "nmreslog".
                LEAVE.
            END.

        IF  par_nmextlog = ""  THEN
            DO: 
                ASSIGN aux_dscritic = "Logradouro extenso deve ser informado."
                       par_nmdcampo = "nmextlog".
                LEAVE.
            END.
    
        IF  NOT ValidaStringEndereco (INPUT par_nmextlog,
                                      INPUT "Logradouro extenso",
                                     OUTPUT aux_dscritic) THEN
            DO:
                ASSIGN par_nmdcampo = "nmextlog".
                LEAVE.
            END.

        ASSIGN par_dstiplog = TRIM(par_dstiplog)
               par_nmextlog = TRIM(par_nmextlog).

        IF par_nmextlog BEGINS par_dstiplog THEN
            DO: 
                ASSIGN aux_dscritic = 
                                "Tipo de logradouro " + CAPS(par_dstiplog) + 
                                " deve ser informado somente no " + 
                                "proprio campo.".
                       par_nmdcampo = "nmreslog".
                LEAVE.
            END.

        IF  NOT ValidaStringEndereco (INPUT par_dscmplog,
                                      INPUT "Complemento Logradouro",
                                     OUTPUT aux_dscritic) THEN
            DO:
                ASSIGN par_nmdcampo = "dscmplog".
                LEAVE.
            END.
        
        IF  par_nmresbai = ""  THEN
            DO: 
                ASSIGN aux_dscritic = "Bairro resumido deve ser informado."
                       par_nmdcampo = "nmresbai".
                LEAVE.
            END.
    
        IF  NOT ValidaStringEndereco (INPUT par_nmresbai,
                                      INPUT "Bairro resumido",
                                     OUTPUT aux_dscritic) THEN
            DO:
                ASSIGN par_nmdcampo = "nmresbai".
                LEAVE.
            END.

        IF  par_nmextbai = ""  THEN
            DO: 
                ASSIGN aux_dscritic = "Bairro Extenso deve ser informado."
                       par_nmdcampo = "nmextbai".
                LEAVE.
            END.
    
        IF  NOT ValidaStringEndereco (INPUT par_nmextbai,
                                      INPUT "Bairro Extenso",
                                     OUTPUT aux_dscritic) THEN
            DO:
                ASSIGN par_nmdcampo = "nmextbai".
                LEAVE.
            END.

        IF  par_nmrescid = ""  THEN
            DO: 
                ASSIGN aux_dscritic = "Cidade resumida deve ser informado."
                       par_nmdcampo = "nmrescid".
                LEAVE.
            END.
    
        IF  NOT ValidaStringEndereco (INPUT par_nmrescid,
                                      INPUT "Cidade resumido",
                                     OUTPUT aux_dscritic) THEN
            DO:
                ASSIGN par_nmdcampo = "nmrescid".
                LEAVE.
            END.

        FIND FIRST crapdne WHERE crapdne.idoricad = 1   AND
                                 crapdne.nmextcid = par_nmrescid
                                 NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapdne    THEN
             DO:
                 ASSIGN aux_dscritic = "Cidade nao cadastrada.".
                        par_nmdcampo = "nmrescid".
                 LEAVE.
             END.

        FIND FIRST crapdne WHERE crapdne.idoricad = 1              AND
                                 crapdne.nmextcid = par_nmrescid   AND
                                 crapdne.cduflogr = par_cduflogr
                                 NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapdne   THEN
             DO:
                 ASSIGN aux_dscritic = "U.F nao pertence a cidade informada."
                        par_nmdcampo = "cduflogr".
                 LEAVE.
             END.

        IF  par_nmextcid = ""  THEN
            DO: 
                ASSIGN aux_dscritic = "Cidade Extensa deve ser informado."
                       par_nmdcampo = "nmextcid".
                LEAVE.
            END.
    
        IF  NOT ValidaStringEndereco (INPUT par_nmextcid,
                                      INPUT "Cidade Extenso",
                                     OUTPUT aux_dscritic) THEN
            DO:
                ASSIGN par_nmdcampo = "nmextcid".
                LEAVE.
            END.

        FIND FIRST crapdne WHERE 
                   crapdne.nrceplog = par_nrceplog        AND
                   crapdne.cduflogr = TRIM(par_cduflogr)  AND

                 ((crapdne.nmextlog = TRIM(par_nmextlog)  AND
                   crapdne.nmextbai = TRIM(par_nmextbai)  AND
                   crapdne.nmextcid = TRIM(par_nmextcid)) 
                   OR
                  (crapdne.nmreslog = TRIM(par_nmreslog)  AND
                   crapdne.nmresbai = TRIM(par_nmresbai)  AND
                   crapdne.nmrescid = TRIM(par_nmrescid))) NO-LOCK NO-ERROR.

        IF  AVAILABLE crapdne AND
           (par_nrdrowid = ? OR par_nrdrowid <> ROWID(crapdne)) THEN
            DO:
                ASSIGN aux_dscritic = "Endereco ja cadastrado."
                       par_nmdcampo = "nrceplog".
                LEAVE.
            END.

        ASSIGN aux_flgerror = FALSE.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/

    IF  aux_flgerror  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
     
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.



PROCEDURE busca-endereco:
    /* Pesquisa para ENDERECO */
    
    DEF  INPUT PARAM par_nrceplog AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsendere AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidade AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufende AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_qtregist AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-endereco.

    Ende: DO ON ERROR UNDO, LEAVE:

        EMPTY TEMP-TABLE tt-endereco.
        EMPTY TEMP-TABLE tt-crapdne.
        EMPTY TEMP-TABLE tt-crapdne-log.
        EMPTY TEMP-TABLE tt-crapdne-cid.

        ASSIGN par_dsendere = TRIM(par_dsendere)
               par_nmcidade = TRIM(par_nmcidade).

        IF  par_nrceplog <> 0  THEN
            DO:
                FOR EACH crapdne WHERE crapdne.nrceplog = par_nrceplog NO-LOCK:
                    
                    /* Carregar caixa postais somente para InternetBank */ 
                    IF  par_idorigem <> 3      AND 
                        crapdne.idtipdne <> 1  THEN
                        NEXT.
                    
                    CREATE tt-crapdne.
                    BUFFER-COPY crapdne TO tt-crapdne.
                    ASSIGN tt-crapdne.nrdrowid = ROWID(crapdne).

                    /* Nao ordenar por origem no InternetBank */
                    IF  par_idorigem = 3  THEN
                        ASSIGN tt-crapdne.idoricad = 0.
                    
                END.

                FOR EACH tt-crapdne NO-LOCK:

                    RUN trata-busca-endereco
                               ( INPUT tt-crapdne.nrceplog,
                                 INPUT tt-crapdne.cduflogr,
                                 INPUT tt-crapdne.dscmplog,
                                 INPUT tt-crapdne.nmextbai,
                                 INPUT tt-crapdne.nmresbai,
                                 INPUT tt-crapdne.nmextlog,
                                 INPUT tt-crapdne.nmreslog,
                                 INPUT tt-crapdne.dstiplog,
                                 INPUT tt-crapdne.nmextcid,
                                 INPUT tt-crapdne.nmrescid,
                                 INPUT tt-crapdne.idoricad,
                                 INPUT par_nrregist,
                                 INPUT par_nriniseq,
                                 INPUT tt-crapdne.nrdrowid,
                                 INPUT par_idorigem,
                                 INPUT-OUTPUT par_qtregist,
                                 OUTPUT TABLE tt-endereco ).

                END.
            END.
        ELSE
            DO:
                IF  par_dsendere <> ""  THEN
                    DO:
                        FOR EACH crapdne WHERE 
                                 crapdne.nmextlog MATCHES("*" + par_dsendere + "*")
                                 NO-LOCK:

                            IF  par_idorigem <> 3      AND 
                                crapdne.idtipdne <> 1  THEN
                                NEXT.
            
                            IF  par_nmcidade = ""  AND 
                                par_cdufende = ""  THEN
                                DO:
                                    CREATE tt-crapdne.
                                    BUFFER-COPY crapdne TO tt-crapdne.
                                    ASSIGN tt-crapdne.nrdrowid = ROWID(crapdne).

                                    /* Nao ordenar por origem no InternetBank */
                                    IF  par_idorigem = 3  THEN
                                        ASSIGN tt-crapdne.idoricad = 0.
                                END.
                            ELSE
                                DO:
                                    CREATE tt-crapdne-log.
                                    BUFFER-COPY crapdne TO tt-crapdne-log.
                                END.

                        END.
            
                        IF  NOT CAN-FIND(FIRST tt-crapdne)      AND 
                            NOT CAN-FIND(FIRST tt-crapdne-log)  THEN
                            LEAVE Ende.
                    END.

                IF  par_nmcidade <> ""  THEN
                    DO:
                        IF  par_dsendere <> ""  THEN
                            DO:
                                FOR EACH tt-crapdne-log WHERE 
                                         tt-crapdne-log.nmextcid 
                                                MATCHES("*" + par_nmcidade + "*") 
                                                NO-LOCK:
            
                                    IF  par_cdufende = ""  THEN
                                        DO:
                                            CREATE tt-crapdne.
                                            BUFFER-COPY tt-crapdne-log 
                                                     TO tt-crapdne.

                                            /* Nao ordenar origem na Internet */
                                            IF  par_idorigem = 3  THEN
                                                ASSIGN tt-crapdne.idoricad = 0.
                                        END.
                                    ELSE
                                        DO:
                                            CREATE tt-crapdne-cid.
                                            BUFFER-COPY tt-crapdne-log 
                                                     TO tt-crapdne-cid.
                                        END.
                                    
                                END.
            
                                IF  NOT CAN-FIND(FIRST tt-crapdne)      AND 
                                    NOT CAN-FIND(FIRST tt-crapdne-cid)  THEN
                                    LEAVE Ende.
                            END.
                        ELSE
                            DO:
                                FOR EACH crapdne WHERE 
                                         crapdne.nmextcid 
                                             MATCHES("*" + par_nmcidade + "*")
                                             NO-LOCK:   
            
                                    IF  par_idorigem <> 3      AND 
                                        crapdne.idtipdne <> 1  THEN
                                        NEXT.

                                    IF  par_cdufende = ""  THEN
                                        DO:
                                            CREATE tt-crapdne.
                                            BUFFER-COPY crapdne TO tt-crapdne.
                                            ASSIGN tt-crapdne.nrdrowid = ROWID(crapdne).

                                            /* Nao ordenar origem na Internet */
                                            IF  par_idorigem = 3  THEN
                                                ASSIGN tt-crapdne.idoricad = 0.
                                        END.
                                    ELSE
                                        DO:
                                            CREATE tt-crapdne-cid.
                                            BUFFER-COPY crapdne 
                                                     TO tt-crapdne-cid.        
                                        END.            
            
                                END.
            
                                IF  NOT CAN-FIND(FIRST tt-crapdne)      AND 
                                    NOT CAN-FIND(FIRST tt-crapdne-cid)  THEN
                                    LEAVE Ende.
                            END.
                    END.

                IF  par_cdufende <> ""  THEN
                    DO:
                        IF  par_nmcidade <> ""  THEN
                            DO:
                                FOR EACH tt-crapdne-cid WHERE 
                                         tt-crapdne-cid.cduflogr = par_cdufende 
                                         NO-LOCK:
            
                                    CREATE tt-crapdne.
                                    BUFFER-COPY tt-crapdne-cid TO tt-crapdne.  

                                    /* Nao ordenar origem na Internet */
                                    IF  par_idorigem = 3  THEN
                                        ASSIGN tt-crapdne.idoricad = 0.
            
                                END.
            
                                IF  NOT CAN-FIND(FIRST tt-crapdne)  THEN
                                    LEAVE Ende.
                            END.
                        ELSE
                        IF  par_dsendere <> ""  THEN
                            DO:
                                FOR EACH tt-crapdne-log WHERE 
                                         tt-crapdne-log.cduflogr = par_cdufende 
                                         NO-LOCK:
            
                                    CREATE tt-crapdne.
                                    BUFFER-COPY tt-crapdne-log TO tt-crapdne.

                                    /* Nao ordenar origem na Internet */
                                    IF  par_idorigem = 3  THEN
                                        ASSIGN tt-crapdne.idoricad = 0.
            
                                END.
            
                                IF  NOT CAN-FIND(FIRST tt-crapdne)  THEN
                                    LEAVE Ende.
                            END.
                        ELSE
                            DO:
                                FOR EACH crapdne WHERE 
                                         crapdne.cduflogr = par_cdufende NO-LOCK:
            
                                    IF  par_idorigem <> 3      AND 
                                        crapdne.idtipdne <> 1  THEN
                                        NEXT.

                                    CREATE tt-crapdne.
                                    BUFFER-COPY crapdne TO tt-crapdne.
                                    ASSIGN tt-crapdne.nrdrowid = ROWID(crapdne).

                                    /* Nao ordenar origem na Internet */
                                    IF  par_idorigem = 3  THEN
                                        ASSIGN tt-crapdne.idoricad = 0.
            
                                END.
            
                                IF  NOT CAN-FIND(FIRST tt-crapdne)  THEN
                                    LEAVE Ende.
                            END.
                    END.
                
                FOR EACH tt-crapdne NO-LOCK:
                    
                    RUN trata-busca-endereco
                               ( INPUT tt-crapdne.nrceplog,
                                 INPUT tt-crapdne.cduflogr,
                                 INPUT tt-crapdne.dscmplog,
                                 INPUT tt-crapdne.nmextbai,
                                 INPUT tt-crapdne.nmresbai,
                                 INPUT tt-crapdne.nmextlog,
                                 INPUT tt-crapdne.nmreslog,
                                 INPUT tt-crapdne.dstiplog,
                                 INPUT tt-crapdne.nmextcid,
                                 INPUT tt-crapdne.nmrescid,
                                 INPUT tt-crapdne.idoricad,
                                 INPUT par_nrregist,
                                 INPUT par_nriniseq,
                                 INPUT tt-crapdne.nrdrowid,
                                 INPUT par_idorigem,
                                 INPUT-OUTPUT par_qtregist,
                                 OUTPUT TABLE tt-endereco ).

                END.
            END.

        LEAVE Ende.

    END.

    RETURN "OK".
                
END PROCEDURE.


PROCEDURE trata-busca-endereco:

    DEF  INPUT PARAM par_nrceplog AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cduflogr AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dscmplog AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmextbai AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmresbai AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmextlog AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmreslog AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dstiplog AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmextcid AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmrescid AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idoricad AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrregist AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nriniseq AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM par_qtregist AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-endereco. 

    DEF VAR aux_dsendere          AS CHAR                           NO-UNDO.
    DEF VAR aux_dsender2          AS CHAR                           NO-UNDO.
    DEF VAR aux_dscmpend          AS CHAR                           NO-UNDO.
    
    ASSIGN par_qtregist = par_qtregist + 1.
    
    /* controles da paginação */
    IF  par_qtregist < par_nriniseq  OR
        par_qtregist >= (par_nriniseq + par_nrregist) THEN
        NEXT.
    
    IF  par_nrregist > 0 THEN
        DO: 
            IF  par_nmextlog BEGINS par_dstiplog  THEN
                ASSIGN aux_dsendere = par_nmextlog.
            ELSE
                ASSIGN aux_dsendere = 
                    (IF TRIM(par_dstiplog) <> "" THEN 
                        par_dstiplog + " " ELSE "") + 
                     par_nmextlog.
                       
            IF  LENGTH(aux_dsendere) > 40  THEN
                ASSIGN aux_dsendere = par_nmreslog.

            ASSIGN aux_dsender2 = IF LENGTH(par_nmextlog) > 40 THEN
                                     par_nmreslog
                                  ELSE
                                     par_nmextlog
                   aux_dscmpend = TRIM(par_dscmplog).
            
            IF  SUBSTR(TRIM(aux_dscmpend),1,1) = "-"  THEN
                ASSIGN aux_dscmpend = TRIM(SUBSTR(aux_dscmpend,2)).
                 
            CREATE tt-endereco.
            ASSIGN tt-endereco.nrcepend = par_nrceplog
                   tt-endereco.dsendere = aux_dsendere 
                   tt-endereco.dsender2 = aux_dsender2 
                   tt-endereco.dscmpend = aux_dscmpend
                   tt-endereco.dsendcmp = 
                                 (IF  TRIM(par_dscmplog) <> "" THEN 
                                     aux_dsendere + " " + 
                                     TRIM(par_dscmplog)
                                 ELSE
                                     aux_dsendere)
                   tt-endereco.cdufende = par_cduflogr
                   tt-endereco.dstiplog = par_dstiplog
                   tt-endereco.idoricad = par_idoricad
                   tt-endereco.nrdrowid = par_nrdrowid.
                   
            IF  LENGTH(par_nmextbai) <= 40  THEN
                ASSIGN tt-endereco.nmbairro = par_nmextbai.
            ELSE
                ASSIGN tt-endereco.nmbairro = par_nmresbai.
                
            /*IF  LENGTH(par_nmextcid) <= 25  THEN*/
                ASSIGN tt-endereco.nmcidade = par_nmextcid.
            /*ELSE
                ASSIGN tt-endereco.nmcidade = par_nmrescid. */

            IF  par_idoricad = 1  THEN
                ASSIGN tt-endereco.dsoricad = "ENDERECO OBTIDO NOS CORREIOS".
            ELSE
                ASSIGN tt-endereco.dsoricad = "ENDERECO CADASTRADO VIA AIMARO".
        END.

    ASSIGN par_nrregist = par_nrregist - 1
           aux_dscmpend = ""
           aux_dsendere = "".

END PROCEDURE.


PROCEDURE trata-inicio-resid:

    DEF  INPUT PARAM par_cdcooper AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                              NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                              NO-UNDO.
    
    DEF INPUT  PARAM par_dtinires AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nranores AS CHAR                              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_dttest AS DATE INIT ?                                  NO-UNDO.
    DEF VAR aux_tmpano AS INTE INIT 0                                  NO-UNDO.
    DEF VAR aux_tmpmes AS INTE INIT 0                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:          

        FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapdat  THEN
            DO:
                ASSIGN aux_dscritic = "Registro de data nao encontrado.".
                LEAVE.
            END.

        ASSIGN aux_dttest = 
          DATE(INTE(SUBSTR(par_dtinires,1,2)),1,INTE(SUBSTR(par_dtinires,4,4)))
          NO-ERROR.

        IF  aux_dttest > crapdat.dtmvtolt  THEN
            DO:
                ASSIGN aux_dscritic = 
                                  "Data invalida. Data e maior que mes atual.".
                LEAVE.
            END.

        IF  ERROR-STATUS:ERROR    OR
            SUBSTR(par_dtinires,3,1) <> "/"  THEN
            DO:
                ASSIGN aux_dscritic = 
                                  "Data invalida. Formato correto 'mm/aaaa'.".
                LEAVE.
            END.
    
        IF  MONTH(aux_dttest) <= MONTH(crapdat.dtmvtolt)  THEN 
            ASSIGN aux_tmpano = YEAR(crapdat.dtmvtolt) - YEAR(aux_dttest)
                   aux_tmpmes = MONTH(crapdat.dtmvtolt) - MONTH(aux_dttest).
        ELSE
            ASSIGN aux_tmpano = YEAR(crapdat.dtmvtolt) - YEAR(aux_dttest) - 1
                   aux_tmpmes = MONTH(crapdat.dtmvtolt) - MONTH(aux_dttest) + 12.

        IF  aux_tmpano = 1  THEN
            ASSIGN par_nranores = STRING(aux_tmpano) + " ano".
        ELSE
        IF  aux_tmpano > 1  THEN
            ASSIGN par_nranores = STRING(aux_tmpano) + " anos".
            
        IF  par_nranores <> "" AND aux_tmpmes > 0  THEN
            ASSIGN par_nranores = par_nranores + " e ".
            
        IF  aux_tmpmes = 1  THEN
            ASSIGN par_nranores = par_nranores + STRING(aux_tmpmes) + " mes".
        ELSE
        IF  aux_tmpmes > 1  THEN
            ASSIGN par_nranores = par_nranores + STRING(aux_tmpmes) + " meses".

        LEAVE.

    END.
        
    IF  aux_dscritic <> ""  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
     
            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE exclui-endereco-ayllos:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdrowid AS ROWID                          NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_flgtrans AS LOGI                                    NO-UNDO.

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Deletar endereco gerado pelo Aimaro.".

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    EMPTY TEMP-TABLE tt-erro.

    TRANS_END: 

    DO TRANSACTION ON ENDKEY UNDO TRANS_END, LEAVE TRANS_END
                   ON ERROR  UNDO TRANS_END, LEAVE TRANS_END:

        FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                           crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.

        IF  NOT CAN-DO("20,18",STRING(crapope.cddepart))  THEN
            DO:
                ASSIGN aux_cdcritic = 036 
                       aux_dscritic = "".

                UNDO TRANS_END, LEAVE TRANS_END.
            END.

        DO aux_contador = 1 TO 10:

            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "".

            FIND crapdne WHERE ROWID(crapdne) = par_nrdrowid
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAIL crapdne THEN
                DO:
                    IF  LOCKED crapdne THEN
                        DO:
                            /* USADO POR OUTRO USUARIO */
                            ASSIGN aux_cdcritic = 77.
                            NEXT.
                        END.
                    ELSE
                        ASSIGN aux_dscritic = "Endereco nao encontrado".
                END.
            ELSE
                LEAVE.

        END. /* FIM do DO .. TO */

        IF  aux_cdcritic > 0 OR aux_dscritic <> "" THEN
            UNDO TRANS_END, LEAVE TRANS_END.

        DELETE crapdne.

        ASSIGN aux_flgtrans = TRUE.
        
    END. /* DO TRANSACTION */

    IF  NOT aux_flgtrans THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic = "" THEN
                ASSIGN aux_dscritic = "Nao foi possivel excluir o endereco.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /* Sequencia */
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog THEN
                DO:
                    RUN proc_gerar_log(INPUT par_cdcooper,
                                       INPUT par_cdoperad,
                                       INPUT aux_dscritic,
                                       INPUT aux_dsorigem,
                                       INPUT aux_dstransa,
                                       INPUT FALSE,
                                       INPUT par_idseqttl,
                                       INPUT par_nmdatela,
                                       INPUT par_nrdconta,
                                      OUTPUT aux_nrdrowid).

                    RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                             INPUT "nrceplog",
                                             INPUT "",
                                             INPUT STRING(aux_nrdrowid)).

                END.

            RETURN "NOK".
        END.
    
    IF  par_flgerlog THEN
        DO:
            RUN proc_gerar_log(INPUT par_cdcooper,
                               INPUT par_cdoperad,
                               INPUT aux_dscritic,
                               INPUT aux_dsorigem,
                               INPUT aux_dstransa,
                               INPUT FALSE,
                               INPUT par_idseqttl,
                               INPUT par_nmdatela,
                               INPUT par_nrdconta,
                              OUTPUT aux_nrdrowid).
    
            RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                     INPUT "nrceplog",
                                     INPUT "",
                                     INPUT STRING(aux_nrdrowid)).
    
        END.

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE copia_arquivos_correios:
    
    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-arquivos.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_arquivos    AS CHAR                                 NO-UNDO.
    DEF VAR aux_destinos    AS CHAR                                 NO-UNDO.
    DEF VAR aux_nmarquiv    AS CHAR                                 NO-UNDO.
    DEF VAR aux_comandux    AS CHAR                                 NO-UNDO.
    DEF VAR aux_contador    AS INTE                                 NO-UNDO.    

    EMPTY TEMP-TABLE tt-arquivos.
    EMPTY TEMP-TABLE tt-erro.

    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.

    IF  NOT CAN-DO("20,18",STRING(crapope.cddepart))  THEN
        DO:
            ASSIGN aux_cdcritic = 036
                   aux_dscritic = "".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /* Sequencia */
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            RETURN "NOK".
        END.
            
    ASSIGN aux_arquivos = "/micros/cecred/correios/"
           aux_destinos = ":/var/www/ayllos/telas/caddne/arquivos/".

    INPUT STREAM str_1 THROUGH VALUE ("ls " + aux_arquivos + 
                                      " 2> /dev/null") NO-ECHO.

    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
        SET STREAM str_1 aux_nmarquiv FORMAT "x(70)".
        IF  aux_nmarquiv = "LOG_BAIRRO.TXT"      OR 
            aux_nmarquiv = "LOG_LOCALIDADE.TXT"  THEN
            NEXT.
        ASSIGN aux_contador = aux_contador + 1.
    END.
    

    INPUT STREAM str_1 THROUGH VALUE ("ls " + aux_arquivos + 
                                      " 2> /dev/null") NO-ECHO.

    IF  aux_contador = 0 THEN
        DO:
            DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                SET STREAM str_1 aux_nmarquiv FORMAT "x(70)".
                ASSIGN aux_comandux = 'mv ' + aux_arquivos + aux_nmarquiv + 
                                      ' /usr/coop/cecred/salvar/' + 
                                      aux_nmarquiv + '.' + STRING(TIME) + 
                                      ' 2> /dev/null'.
                UNIX SILENT VALUE (aux_comandux).
            END.
        END.
    ELSE
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                SET STREAM str_1 aux_nmarquiv FORMAT "x(70)".
                CREATE tt-arquivos.
                ASSIGN tt-arquivos.nmarquiv = aux_nmarquiv.
                UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                   '"scp ' + aux_arquivos + aux_nmarquiv + 
                                   ' scpuser@' + aux_srvintra + aux_destinos + 
                                   ' 2> /dev/null').
            END.
        END.

    RETURN "OK".

END PROCEDURE.



PROCEDURE grava-importacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.    
    DEF  INPUT PARAM par_cduflogr AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_arquivos    AS CHAR                                 NO-UNDO.
    DEF VAR aux_setarqui    AS CHAR                                 NO-UNDO.
    DEF VAR aux_setlinha    AS CHAR                                 NO-UNDO.
    DEF VAR aux_comandux    AS CHAR                                 NO-UNDO.
    DEF VAR aux_flgtrans    AS LOGI                                 NO-UNDO.
    DEF VAR aux_logradou    AS CHAR                                 NO-UNDO.
    DEF VAR aux_idtipdne    AS INTE                                 NO-UNDO.
    /* aux_idtipdne -> 1 = ESTADOS 
                       2 = GRANDE USUARIO
                       3 = UNID OPER
                       4 = CPC */

    /*Variaveis que receberam o conteudo do arquivo para que possa ser tratado erro*/
	DEF VAR aux_nrceplog	LIKE crapdne.nrceplog					NO-UNDO.
    DEF VAR aux_cduflogr	LIKE crapdne.cduflogr					NO-UNDO.
    DEF VAR aux_nmextlog	LIKE crapdne.nmextlog					NO-UNDO.
    DEF VAR aux_nmreslog	LIKE crapdne.nmreslog					NO-UNDO.
    DEF VAR aux_dscmplog	LIKE crapdne.dscmplog					NO-UNDO.
    DEF VAR aux_dstiplog	LIKE crapdne.dstiplog					NO-UNDO.
    DEF VAR aux_nmextbai	LIKE crapdne.nmextbai					NO-UNDO.
    DEF VAR aux_nmresbai	LIKE crapdne.nmresbai					NO-UNDO.
    DEF VAR aux_nmextcid	LIKE crapdne.nmextcid					NO-UNDO.
    DEF VAR aux_nmrescid	LIKE crapdne.nmrescid					NO-UNDO.

	DEF VAR aux_flgerros    AS   LOGICAL                            NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /* Sequencia */
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    UNIX SILENT
         VALUE('echo "' + STRING(par_dtmvtolt, "99/99/9999")    +
              ' ' + STRING(TIME,"HH:MM:SS") + ' --> '           +
              ' Importando arquivos de endereco dos correios '  +
              ' - Estado: ' + par_cduflogr                    +
              ' - Operador: ' + par_cdoperad                    +
              ' - Tela: ' + par_nmdatela                        +
              '" >> /usr/coop/cecred/log/caddne.log').
    
    /* Apaga registros do estado em questao oriundos dos correios */
    ASSIGN aux_flgtrans = FALSE.                

    IF par_cduflogr = "UNID_OPER" OR 
       par_cduflogr = "CPC" OR 
       par_cduflogr = "GRANDE_USUARIO" THEN
    DO:
       IF par_cduflogr = "UNID_OPER" THEN 
          ASSIGN aux_idtipdne = 3.

       IF par_cduflogr = "CPC" THEN
          ASSIGN aux_idtipdne = 4.
       
       IF par_cduflogr = "GRANDE_USUARIO" THEN
          ASSIGN aux_idtipdne = 2.
       
       DELECAO:
            FOR EACH crapdne WHERE crapdne.idtipdne = aux_idtipdne
                               AND crapdne.idoricad = 1   EXCLUSIVE-LOCK 
                TRANSACTION ON ERROR  UNDO DELECAO, LEAVE DELECAO
                            ON ENDKEY UNDO DELECAO, LEAVE DELECAO:
                DELETE crapdne.               
            END.

            ASSIGN aux_flgtrans = TRUE.
    END.
    ELSE DO:
        ASSIGN aux_idtipdne = 1.
    
        DELECAO:
           FOR EACH crapdne WHERE crapdne.cduflogr = par_cduflogr 
                              AND crapdne.idtipdne = aux_idtipdne
                              AND crapdne.idoricad = 1   EXCLUSIVE-LOCK 
               TRANSACTION ON ERROR  UNDO DELECAO, LEAVE DELECAO
                           ON ENDKEY UNDO DELECAO, LEAVE DELECAO:
              DELETE crapdne.               
         END.

         ASSIGN aux_flgtrans = TRUE.

    END. /* Fim do DO WHILE TRUE */
    
    IF  NOT aux_flgtrans  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Erro na limpeza do estado '" +
                                  par_cduflogr + "'.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /* Sequencia */
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
    
    LOOP_IMPORTACAO:
    DO WHILE TRUE:
            
        /* Alimentar estado com os registros oriundos dos correios */
        ASSIGN aux_arquivos = "/usr/coop/" + crapcop.dsdircop + "/upload/"
               aux_flgtrans = FALSE.
    
        INPUT STREAM str_1 THROUGH VALUE ("ls " + aux_arquivos            + 
                                          STRING(par_cdcooper,"999")      + 
                                          ".0." + par_cduflogr + "_*.TXT" +
                                          " 2> /dev/null") NO-ECHO.
        
        ARQUIVOS:
        DO WHILE TRUE ON  ERROR UNDO ARQUIVOS, LEAVE LOOP_IMPORTACAO 
                      ON ENDKEY UNDO ARQUIVOS, LEAVE ARQUIVOS:
            
            IMPORT STREAM str_1 UNFORMATTED aux_setarqui.

            UNIX SILENT VALUE ("echo " + aux_setarqui + 
                               " >> /usr/coop/cecred/log/caddne.log").
    
            INPUT STREAM str_2 FROM VALUE(aux_setarqui) NO-ECHO.
          
            ASSIGN aux_flgerros = FALSE.

            LINHAS:
            DO WHILE TRUE TRANSACTION 
                          ON ERROR  UNDO LINHAS, LEAVE LOOP_IMPORTACAO 
                          ON ENDKEY UNDO LINHAS, LEAVE LINHAS:
    
                IMPORT STREAM str_2 UNFORMATTED aux_setlinha.
    
                IF TRIM(aux_setlinha) = "" THEN NEXT.

                /* 
                CEP@UF@NOME RUA@RESUMIDO RUA@COMPLEMENTO@TIPO@BAIRRO@BAIRRO RESUMIDO@CIDADE@CIDADE RESUMIDO
                89041590@SC@Arthur Rabe@R Arthur Rabe@@Rua@Agua Verde@A Verde@Blumenau@Blumenau
                */
                

				/****** TRATAMENTO DE ERROS PARA OS ENTRY **********************/
                ASSIGN aux_nrceplog = INTE(ENTRY(1,aux_setlinha,"@")) NO-ERROR.
				IF ERROR-STATUS:ERROR THEN
				   DO:
				     aux_flgerros = TRUE.
				     UNDO LINHAS.
				   END.

                ASSIGN aux_cduflogr = CAPS(ENTRY(2,aux_setlinha,"@")) NO-ERROR.
				IF ERROR-STATUS:ERROR THEN
				   DO:
				     aux_flgerros = TRUE.
				     UNDO LINHAS.
				   END.

                ASSIGN aux_nmextlog = SUBSTR(CAPS(ENTRY(3,aux_setlinha,"@")),1,70) NO-ERROR.
				IF ERROR-STATUS:ERROR THEN
				   DO:
				     aux_flgerros = TRUE.
				     UNDO LINHAS.
				   END.

                ASSIGN aux_nmreslog = CAPS(ENTRY(4,aux_setlinha,"@")) NO-ERROR.
				IF ERROR-STATUS:ERROR THEN
				   DO:
				     aux_flgerros = TRUE.
				     UNDO LINHAS.
				   END.

                ASSIGN aux_dscmplog = CAPS(ENTRY(5,aux_setlinha,"@")) NO-ERROR.
				IF ERROR-STATUS:ERROR THEN
				   DO:
				     aux_flgerros = TRUE.
				     UNDO LINHAS.
				   END.

                ASSIGN aux_dstiplog = CAPS(ENTRY(6,aux_setlinha,"@")) NO-ERROR.
				IF ERROR-STATUS:ERROR THEN
				   DO:
				     aux_flgerros = TRUE.
				     UNDO LINHAS.
				   END.

                ASSIGN aux_nmextbai = CAPS(ENTRY(7,aux_setlinha,"@")) NO-ERROR.
				IF ERROR-STATUS:ERROR THEN
				   DO:
				     aux_flgerros = TRUE.
				     UNDO LINHAS.
				   END.

                ASSIGN aux_nmresbai = CAPS(ENTRY(8,aux_setlinha,"@")) NO-ERROR.
				IF ERROR-STATUS:ERROR THEN
				   DO:
				     aux_flgerros = TRUE.
				     UNDO LINHAS.
				   END.

                ASSIGN aux_nmextcid = CAPS(ENTRY(9,aux_setlinha,"@")) NO-ERROR.
				IF ERROR-STATUS:ERROR THEN
				   DO:
				     aux_flgerros = TRUE.
				     UNDO LINHAS.
				   END.

                ASSIGN aux_nmrescid = CAPS(ENTRY(10,aux_setlinha,"@")) NO-ERROR.
				IF ERROR-STATUS:ERROR THEN
				   DO:
				     aux_flgerros = TRUE.
				     UNDO LINHAS.
				   END.

				/****** TRATAMENTO DE ERROS PARA OS ENTRY **********************/

                
                CREATE crapdne.
                ASSIGN crapdne.nrceplog = aux_nrceplog
                       crapdne.cduflogr = aux_cduflogr
                       crapdne.nmextlog = aux_nmextlog
                       crapdne.nmreslog = aux_nmreslog
                       crapdne.dscmplog = aux_dscmplog
                       crapdne.dstiplog = aux_dstiplog
                       crapdne.nmextbai = aux_nmextbai
                       crapdne.nmresbai = aux_nmresbai
                       crapdne.nmextcid = aux_nmextcid
                       crapdne.nmrescid = aux_nmrescid
                       crapdne.idtipdne = aux_idtipdne 
                       crapdne.idoricad = 1. /* 1 = correios, 2 = ayllos */
                VALIDATE crapdne.
                
            END.
            
            INPUT STREAM str_2 CLOSE.
    
            /* remove arquivo de transicao em pasta upload */
            ASSIGN aux_comandux = 'rm ' + aux_setarqui + ' 2> /dev/null'.
    
            UNIX SILENT VALUE (aux_comandux). 
    
        END.
                                      
        INPUT STREAM str_1 CLOSE.

		IF aux_flgerros THEN
		   ASSIGN aux_flgtrans = FALSE.
	    ELSE
        ASSIGN aux_flgtrans = TRUE.

        LEAVE.

    END. /* Fim do DO WHILE TRUE */

    IF  NOT aux_flgtrans THEN
        DO: 
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Erro na importacao do estado '" + 
                                  par_cduflogr + "'.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /* Sequencia */
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.

    IF par_cduflogr = "UNID_OPER" OR 
       par_cduflogr = "CPC" OR 
       par_cduflogr = "GRANDE_USUARIO" THEN
       ASSIGN aux_logradou = "LOG_" + par_cduflogr.
    ELSE
       ASSIGN aux_logradou = "LOG_LOGRADOURO_" + par_cduflogr.

    
    /* mover o arquivo original para pasta salvar, do estado correspondente */
    ASSIGN aux_comandux = 'cp /micros/cecred/correios/' + aux_logradou +
                          '.TXT ' + '/usr/coop/' + crapcop.dsdircop + 
                          '/salvar/' + aux_logradou + '.TXT.' + 
                          STRING(TIME) + ' 2>/dev/null'.

    UNIX SILENT VALUE(aux_comandux).

    ASSIGN aux_comandux = 'rm /micros/cecred/correios/' + aux_logradou + 
                          '.TXT 2>/dev/null'.

    UNIX SILENT VALUE(aux_comandux).

    RETURN "OK".

END PROCEDURE. /* FIM grava-importacao */

    

/*................................ FUNCTIONS .................................*/


FUNCTION BuscaDescricaImovel 
         RETURNS CHAR (INPUT par_incasprp AS INTE):

    CASE par_incasprp:
        WHEN 1 THEN RETURN "QUITADO".
        WHEN 2 THEN RETURN "FINANCIADO".
        WHEN 3 THEN RETURN "ALUGADO".
        WHEN 4 THEN RETURN "FAMILIA".
        WHEN 5 THEN RETURN "CEDIDO".
        OTHERWISE RETURN "".
    END CASE.

END FUNCTION.


FUNCTION ValidaStringEndereco 
         RETURNS LOGI (INPUT par_dsstrenc AS CHAR,
                       INPUT par_nmdcampo AS CHAR,
                      OUTPUT par_dscritic AS CHAR):

    DEF VAR i AS INTE                                                NO-UNDO.
    DEF VAR aux_qtdarray AS INTE INIT   27                           NO-UNDO.
    DEF VAR aux_naopermi AS CHAR EXTENT 27  INIT["~\","|","<",">",";","/","?",
                                                 "[" ,"]","!","@","#","$","%",
                                                 "&" ,"*","_","+","=","~{","~}",
                                                 "~~","~^","~`","~´","~"","~'"] 
                                            NO-UNDO.
    
    DO i = 1 TO aux_qtdarray:
       IF INDEX(par_dsstrenc, aux_naopermi[i]) > 0 THEN
          DO:
                ASSIGN par_dscritic =  "Caracter " + aux_naopermi[i] + " nao " +
                                       "permitido em " + par_nmdcampo + ".".
                RETURN FALSE.
            END.
    END.
    
    RETURN TRUE.

END FUNCTION.


FUNCTION ValidaUF RETURN LOGI (INPUT par_cdufende AS CHAR):

    RETURN CAN-DO("AC,AL,AP,AM,BA,CE,DF,ES,GO,MA,MT,MS,MG,PA,PB,PR,PE,PI,RJ," +
                  "RN,RS,RO,RR,SC,SP,SE,TO",par_cdufende).

END FUNCTION.


/*............................................................................*/

