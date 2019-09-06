/* ............................................................................
 
   Programa: b1wgen0009.p
   Autor   : Guilherme
   Data    : Marco/2009                     Última atualizacao: 10/06/2018
   
   Dados referentes ao programa:

   Objetivo  : BO de Desconto de Cheques

   Alteracoes: 01/06/2009 - Acerto no numero do lote na liberacao do
                            bordero (Guilherme).
                            
               30/07/2009 - Acerto na hora de criar o crapljt por causa do 
                            escopo da transacao, estava criando crapljt sem 
                            liberar o bordero sendo assim duplicava os 
                            registros (Guilherme).                            
                            
               06/08/2009 - Mudanca de LOG para operacoes (Guilherme).
               
               10/12/2009 - Projeto Rating. Inclusao de novos campos.
                            Retirado o tratamento de atualizacao do
                            Rating (Gabriel).
                          - Substituida as variaveis vlopescr por vltotsfn 
                            (Elton).             
                            
               01/04/2010 - Novos parametros para procedure consulta-poupanca
                            da BO b1wgen0006 (David);
                          - Incluida nova procedure busca_desconto_cheques 
                            (Elton).  
                            
               11/06/2010 - Adaptacao para RATING no Ayllos Web (David).
               
               23/06/2010 - Incluir campos de envio a sede e recid
                            na procedure que busca os limites (Gabriel).
                            
               28/06/2010 - Nao descontar titulos do pac 5 da CREDITEXTIL
                            Migracao de pac de cooperativas (Guilherme).
                            
               01/09/2010 - Incluir parametros na chamada da procedure que
                            atualiza os avalistas e na que cria (Gabriel)
                            
               21/09/2010 - Incluir procedure para gerar impressao da proposta
                            e contrato para limite do desconto (David).
                            
               28/10/2010 - Incluidos parametros flgativo e nrctrhcj na
                            procedure lista_cartoes (Diego).
                            
               16/11/2010 - Incluida a palavra "CADIN" na proposta de                              
                            limite do desconto (Vitor).
                            
               22/11/2010 - Ajuste nas mensagens de confirmacao para liberacao
                            de bordero (David).
                            
               25/11/2010 - Inclusao temporariamente do parametro flgliber
                            (Transferencia do PAC5 Acredi) (Irlan)
                            
               02/12/2010 - Trocada a procedure que cuida da impressao dos
                            ratings (Gabriel).   
                            
               04/01/2010 - Alterado texto da clausula 5.1 do contrato 
                           (Henrique).       
                           
               16/02/2011 - Ajustes devido alteracao do campo nome (Henrique).
               
               05/04/2011 - Correcao em leituras de tabelas (crapass/tt-risco) 
                            na analise de borderos (David).
                            
               26/04/2011 - Inclusao de parametros nrendere, complend, nrcxapst
                            para CEP integrado em: efetua_inclusao_limite
                            e efetua_alteracao_limite. (André - DB1)
                            
               24/05/2011 - Ajuste na impressao dos avalistas, utilizando os
                            novos parametros da alteracao acima (David).             
                            
               30/05/2011 - Alteracao no format do campo 
                            tt-dados_nota_pro_chq.dsendco2. (Fabricio)
                            
               04/07/2011 - Ajuste para sempre dar o UNDO caso ocorra algum
                            erro (Gabriel).   
                            
               21/07/2011 - Nao gerar a proposta quando a impressao for completa 
                            (Isara - RKAM)                                
                            
               14/09/2011 - Corrigido a procedure efetua_liber_anali_bordero
                            para nao validar cheques vindos de custodia
                            (Adriano).
                            
               28/10/2011 - Adicionado na procedure busca_dados_limite_incluir,
                            a chamada da procedure 
                            valida_percentual_societario. (Fabricio)
                            
               21/11/2011 - Colocado em comentario temporariamente a chamada
                            da procedure valida_percentual_societario. 
                            (Fabricio)
                            
               19/03/2012 - Adicionada área para uso da Digitalizaçao (Lucas).                  
                            
               25/04/2012 - Busca do dado flgdigit (Tiago).   
               
               28/05/2012 - Alterado busca na crapcdb para utilizar indice
                            crapcdb7. Ganho significativo na busca em 
                            teste de desempenho (Guilherme Maba). 
                            
               04/07/2012 - Tratamento do cdoperad "operador" de INTE para CHAR.
                             (Lucas R.)  
                             
               11/10/2012 - Incluido a passagem de um novo paramentro na chamada
                            da procedure saldo_utiliza - Projeto GE (Adriano).
                            
               16/11/2012 - Ajustes: 
                            - Alterado as procedures valida_proposta_dados,
                              efetua_liber_anali_bordero;
                            - Incluido a procedure lista-linhas-desc-chq e a 
                              funcao linha-desc-chq 
                            - Ajustado de alinhamento nos forms f_pro_edl,
                              f_dividas na procedure gera-impressao-limite
                            (Lucas R.).
                            
               28/12/2012 - Incluso a passagem do parametro par_cdoperad nas 
                            procedures cria-tabelas-avalistas e 
                            atualiza_tabela_avalistas (Daniel).
                            
               13/02/2013 - Alteraçoes para o Projeto GED - Fase 2 (Lucas).

               21/03/2013 - Ajustes realizados 
                            - Incluido a chamada da procedure alerta_fraude
                              dentro das procedures efetua_liber_anali_bordero,
                              valida_proposta_dados, busca_dados_limite_altera,
                              busca_dados_limite_incluir;
                            - Inserido uma quebra de pagina antes de mostrar o 
                              frame de "Historico dos Ratings" na procedure 
                              gera-impressao-limite (Adriano).

               01/04/2013 - Removido par_nrdconta da procedure 
                            lista-linhas-desc-chq (Lucas R.)

               04/04/2013 - Incluir Verificaçao de idade na procedure 
                            busca_dados_limite_incluir (Lucas R.).  

               15/04/2013 - Alterado parametro da tt-emprestimo para
                            INPUT-OUTPUT (Daniele).

               25/06/2013 - RATING BNDES - Gravar campo dtmvtolt crapprp
                            (Guilherme/Supero)
                            
               26/08/2013 - Alterado para nao usar mais informaçoes de telefone 
                            da tabela CRAPASS para usar a CRAPTFC (Daniele).
               
               03/09/2013 - Tratamento para Imunidade Tributaria (Ze). 
               
               06/11/2013 - Adicionado procedure calc_qtd_dias_uteis. (Fabricio)
               
               18/12/2013 - Adicionado validate para as tabelas crapjfn,
                            craplim, crapprp,  crapljd, craplot, craplcm,
                            crapabc (Tiago).
                            
               24/04/2014 - Adicionado param. de paginacao em procedure
                            obtem-dados-emprestimos em BO 0002.(Jorge)
                            
               24/06/2014 - Adicionado o parametro par_dsoperac 
                            (com valor 'DESCONTO CHEQUE') 'a chamada das
                            procedures cria-tabelas-avalistas e 
                            atualiza_tabela_avalistas. 
                            (Chamado 166383) - (Fabricio)
                            
            06/06/2014 - Adicionado novos parametros nas procedures
                         atualiza_tabela_avalistas e cria-tabelas-avalistas
                         (Daniel/Thiago)                
                         
            23/06/2014 - Exclusao da criacao da temp table tt-ge-deschq 
                         sera utilizado a temp table tt-grupo na include b1wgen0138tt. 
                         (Tiago Castro - RKAM)
                         
            28/07/2014 - adicionado parametro de saida em chamada da
                         proc. cria-tabelas-avalistas.
                         (Jorge/Gielow) - SD 156112             
                         
            25/08/2014 - Incluir ajustes referentes ao Projeto CET 
                         (Lucas Ranghetti/ Gielow)
                         
            08/09/2014 - Alterado crapcop.nmcidade para crapage.nmcidade
                         estava buscando a cidade da sede. (SD 163504 Lucas R.)
                         
            06/11/2014 - Alterado parametro passado na chamada das procedures
                         cria-tabelas-avalistas e atualiza_tabela_avalistas;
                         de: 'DESCONTO CHEQUE' para: 'DESC.CHEQUE'.
                         Motivo: Possibilidade de erro ao tentar gravar
                         registro de log (craplgm). (Fabricio)
                         
            09/12/2014 - Adicionado validaçao no FIND da efetua_liber_anali_bordero 
                         para nao permitir alteraçao simultaneas da situaçao do 
                         bordero. Ajustado FORMAT para adicionar o numero do border 
                         na craplcm.cdpesqbb. (Douglas - Chamado 225249)
                         
            17/12/2014 - Alterado a procedure valida_proposta_dados para
                         qdo for validar linha de credito verificar se
                         está ativa, pois estava deixando incluir 
                         proposta com linha bloqueada
                         SD 234036 (Tiago/Rosangela).

            21/01/2015 - Substituicao da chamada da procedure consulta-aplicacoes
                         da BO b1wgen0004 pela procedure obtem-dados-aplicacoes
                         da BO b1wgen0081.Também foi adicionado o procedimento
                         pc_busca_saldos_aplicacoes da package APLI0005.
                         (Carlos Rafael Tanholi - Projeto Captacao)

            22/01/2015 - Alterado o formato do campo nrctremp para 8 
                         caracters (Kelvin - 233714)

            30/03/2015 - Foi adicionado filtros a mais na procedure busca_cheques_bordero
                         no momento de buscar os dados do emitente. SD - 269063 (Kelvin)

            11/05/2015 - Alterado para apresentar mensagem ao realizar inclusao
                         de proposta de novo limite de desconto de cheque para
                         menores nao emancipados. (Reinert)

            19/06/2015 - Ajuste para passar o numero do cpf do conjuge do avalista
                         corretamente. (Jorge/Gielow) - SD 290885

            12/08/2015 - Projeto Reformulacao cadastral
                         Eliminado o campo nmdsecao (Tiago Castro - RKAM).

            26/08/2015 - Ajuste na passagem de cpf/cnpj em lugares indevidos, 
                         conforme relatado no chamado 314472. (Kelvin).

            13/10/2015 - Ajuste na tipagem do vllimite que estava como int 
                         e foi passando para decimal. SD 325240 (Kelvin).

            27/11/2015 - #356857 Alteracao na rotina de liberacao de borderos 
                         de desconto de cheques (efetua_liber_anali_bordero) 
                         para que grave o lote 19000 + numero do PA do operador 
                         ao inves do lote 8452 no que diz respeito ao IOF (Carlos)

            18/12/2015 - Criada procedure para edição de número do contrato de limite 
                         (Lunelli - SD 360072 [M175])

            17/06/2016 - Inclusão de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)

            20/06/2016 - Criacao dos parametros inconfi6, cdopcoan e cdopcolb na
                         efetua_liber_anali_bordero. Inclusao de funcionamento
                         de pedir senha do coordenador. (Jaison/James)

           25/10/2016 - Verificar CNAE restrito Melhoria 310 (Tiago/Thiago)

           05/09/2016 - Criacao do campo perrenov na tt-desconto_cheques.
                        Projeto 300. (Lombardi)

           07/11/2016 - Ajuste na procedure imprime_cet para enviar novos parametros (Daniel)

           09/09/2016 - Criacao do campo insitblq na tt-desconto_cheques.
                        Projeto 300. (Lombardi)
                            
           12/09/2016 - Criacao do campo insitlim na tt-limite_chq.
                        Projeto 300. (Lombardi)

           23/09/2016 - Alterado busca_parametros_dscchq para leitura
                        da nova TAB de desconto segmentada por tipo de pessoa.
                        PRJ-300 - Desconto de cheque(Odirlei-AMcom)
          
           09/11/2016 - Alterado campo crapabc.nrseqdig para crapabc.cdocorre.
                        PRJ-300 - Desconto de cheque(Odirlei-AMcom)
                          
           12/05/2017 - Passagem de 0 para a nacionalidade. (Jaison/Andrino)

           26/05/2017 - Alterado efetua_inclusao_limite para gerar o numero do 
                       contrato de limite.  PRJ-300 - Desconto de cheque(Odirlei-AMcom)

           30/05/2017 - Criacao dos campos qtdaprov e vlraprov na tt-bordero_chq
                        Projeto 300. (Lombardi)

           02/06/2017 - Ajuste para resgatar cheque custodiado no dia de hj
                        quando excluir bordero.
                        PRJ300 - Desconto de cheque(Odirlei-AMcom)

           12/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
                        crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
                        (Adriano - P339).  
                        
           14/07/2017 - na exclusao do bordero, gerar registro de LOG - Jean (Mout´s)

           17/07/2017 - Ajustes na geraçao do registro de LOG na exclusao do bordero
                        Projeto 300. (Lombardi)

           29/07/2017 - Desenvolvimento da melhoria 364 - Grupo Economico Novo. (Mauro)
           
           04/10/2017 - Chamar a verificacao de revisao cadastral apenas para inclusao
                        de novo limite. (Chamado 768648) - (Fabricio)

           20/10/2017 - Projeto 410 - Ajustado cálculo do IOF na liberação do borderô
                        (Diogo - MoutS)

           11/12/2017 - P404 - Inclusao de Garantia de Cobertura das Operaçoes de Crédito (Augusto / Marcos (Supero))

           26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).

           19/09/2018 - Utilizar a funçao fn_sequence para gerar o nrseqdig (Jonata - Mouts PRB0040066).

           14/05/2019 - Adicionado pc_atualiza_contrato_rating para alteracao do numero do contrato/proposta
                        P450 - Luiz Otavio Olinger Momm (AMCOM).

           23/05/2019 - Adicionado pc_retorna_inf_rating retornar o Rating das propostas e bordero
                        P450 - Luiz Otavio Olinger Momm (AMCOM).
............................................................................. */

{ sistema/generico/includes/b1wgen0001tt.i }
{ sistema/generico/includes/b1wgen0002tt.i }
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/b1wgen0006tt.i }
{ sistema/generico/includes/b1wgen0009tt.i }
{ sistema/generico/includes/b1wgen0021tt.i }
{ sistema/generico/includes/b1wgen0028tt.i }
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/b1wgen0138tt.i }
{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }

{ sistema/generico/includes/var_internet.i "NEW"}
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

{ sistema/generico/includes/var_oracle.i }
{ sistema/ayllos/includes/var_online.i NEW }

DEFINE STREAM str_dscchq.

DEF STREAM str_1. 
DEF STREAM str_2.
DEF STREAM str_3.

DEFINE VARIABLE aux_cdcritic AS INTEGER     NO-UNDO.
DEFINE VARIABLE aux_dscritic AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_dstransa AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_dsorigem AS CHARACTER   NO-UNDO.
DEFINE VARIABLE aux_nrdrowid AS ROWID       NO-UNDO.

DEFINE VARIABLE const_txiofpf AS DECIMAL DECIMALS 4 INITIAL 0.0082  NO-UNDO.
DEFINE VARIABLE const_txiofpj AS DECIMAL DECIMALS 4 INITIAL 0.0041  NO-UNDO.

DEF VAR vr_xml                 AS LONGCHAR                      NO-UNDO.
DEF VAR vr_des_inrisco_rat_inc AS CHAR                          NO-UNDO.
DEF VAR vr_inpontos_rat_inc    AS INTEGER                       NO-UNDO.
DEF VAR vr_innivel_rat_inc     AS CHAR                          NO-UNDO.
DEF VAR vr_insegmento_rat_inc  AS CHAR                          NO-UNDO.
DEF VAR vr_vlr                 AS INTEGER                       NO-UNDO.
DEF VAR vr_qtdreg              AS INTEGER                       NO-UNDO.
DEF VAR vr_nrctro_out          AS INTEGER                       NO-UNDO.
DEF VAR vr_tpctrato_out        AS INTEGER                       NO-UNDO.
   
/* Informacoes com os Ratings do Cooperado */
DEF TEMP-TABLE tt-ratings-novo  NO-UNDO
    FIELD cdagenci AS INTE
    FIELD nrdconta AS INTE
    FIELD nrctrrat AS INTE
    FIELD tpctrrat AS INTE
    FIELD indrisco AS CHAR
    FIELD dtmvtolt AS DATE
    FIELD dteftrat AS DATE
    FIELD cdoperad AS CHAR
    FIELD insitrat AS INTE
    FIELD dsditrat AS CHAR
    FIELD nrnotrat AS DECI
    FIELD vlutlrat AS DECI
    FIELD vloperac AS DECI
    FIELD dsdopera AS CHAR
    FIELD dsdrisco AS CHAR
    FIELD flgorige AS LOGI
    FIELD inrisctl AS CHAR
    FIELD nrnotatl AS DECI
    FIELD dtrefere AS DATE
    FIELD des_inrisco_rat_inc AS CHAR       
    FIELD inpontos_rat_inc AS INTE
    FIELD innivel_rat_inc AS CHAR
    FIELD insegmento_rat_inc AS CHAR.

/* Informacoes dos campos de rating do cooperado */
DEF TEMP-TABLE tt-valores-rating-novo   NO-UNDO
    FIELD nrinfcad AS INTE 
    FIELD nrpatlvr AS INTE 
    FIELD nrperger AS INTE
    FIELD vltotsfn AS DECI
    FIELD perfatcl LIKE crapjfn.perfatcl
    FIELD nrgarope AS INTE
    FIELD nrliquid AS INTE
    FIELD inpessoa AS INTE.
    

FUNCTION linha-desc-chq RETURNS LOGICAL
        (INPUT par_cdcooper AS INT,
         INPUT par_cdagenci AS INT,                    
         INPUT par_nrdcaixa AS INT,                    
         INPUT par_cdoperad AS CHAR,                    
         INPUT par_dtmvtolt AS DATE,                    
         INPUT par_nrdconta AS INT,                    
         INPUT par_cddlinha AS INT,                    
         OUTPUT TABLE FOR tt-linhas-desc-chq) FORWARD.

/*****************************************************************************/
/*                          Buscar dados de risco                            */
/*****************************************************************************/
PROCEDURE busca_dados_risco:

    DEFINE INPUT PARAMETER par_cdcooper AS INTE    NO-UNDO.
    
    DEFINE OUTPUT  PARAMETER TABLE FOR tt-risco.
    
    EMPTY TEMP-TABLE tt-risco.
    
    FOR EACH craptab WHERE craptab.cdcooper = par_cdcooper   AND
                           craptab.nmsistem = "CRED"         AND 
                           craptab.tptabela = "GENERI"       AND 
                           craptab.cdempres = 00             AND
                           craptab.cdacesso = "PROVISAOCL"   NO-LOCK:
        
         CREATE tt-risco.
         ASSIGN tt-risco.contador = INT(SUBSTR(craptab.dstextab,12,2))
                tt-risco.dsdrisco = TRIM(SUBSTR(craptab.dstextab,8,3)).
          
        IF  craptab.tpregist = 999 THEN  /* Vlr obrigatorio informar risco */
            DO:
                CREATE tt-risco.
                ASSIGN tt-risco.vlrrisco = DEC(SUBSTR(craptab.dstextab,15,11))
                       tt-risco.diaratin = INT(SUBSTR(craptab.dstextab,87,3)).
            END.

    END.
    
    RETURN "OK".

END PROCEDURE.


/******************************************************************************
            Buscar parametros gerais de desconto de cheque - TAB019         
******************************************************************************/
PROCEDURE busca_parametros_dscchq:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO. 
    DEFINE INPUT  PARAMETER par_inpessoa AS INTEGER     NO-UNDO.      

    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dados_dscchq.
    
    DEFINE VAR aux_cdacesso AS CHAR                     NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados_dscchq.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF par_inpessoa = 1 THEN
      DO:
         ASSIGN aux_cdacesso = "LIMDESCONTPF".
      END.
    ELSE
      DO: 
         ASSIGN aux_cdacesso = "LIMDESCONTPJ".
      END.
      
    FIND craptab WHERE craptab.cdcooper = par_cdcooper    AND
                       craptab.nmsistem = "CRED"          AND
                       craptab.tptabela = "USUARI"        AND
                       craptab.cdempres = 11              AND
                       craptab.cdacesso = aux_cdacesso    AND
                       craptab.tpregist = 0 NO-LOCK NO-ERROR.

    IF  AVAIL craptab THEN
    DO:
       /** Buscar regra para renovaçao **/
       FIND FIRST craprli 
            WHERE craprli.cdcooper = par_cdcooper
              AND craprli.tplimite = 2
              AND craprli.inpessoa = par_inpessoa
               NO-LOCK NO-ERROR.
       
    
       CREATE tt-dados_dscchq.
       /*ASSIGN tt-dados_dscchq.vllimite = DECIMAL(SUBSTRING(craptab.dstextab,01,12))
              tt-dados_dscchq.qtdiavig = INTEGER(SUBSTRING(craptab.dstextab,14,04))
              tt-dados_dscchq.qtrenova = DECIMAL(SUBSTRING(craptab.dstextab,19,02))
              tt-dados_dscchq.qtprzmin = DECIMAL(SUBSTRING(craptab.dstextab,22,03))
              tt-dados_dscchq.qtprzmax = DECIMAL(SUBSTRING(craptab.dstextab,26,03))
              tt-dados_dscchq.pcdmulta = DECIMAL(SUBSTRING(craptab.dstextab,30,10))
              tt-dados_dscchq.vlconchq = DECIMAL(SUBSTRING(craptab.dstextab,41,12))
              tt-dados_dscchq.vlmaxemi = DECIMAL(SUBSTRING(craptab.dstextab,54,12))
              tt-dados_dscchq.pcchqloc = DECIMAL(SUBSTRING(craptab.dstextab,67,03))
              tt-dados_dscchq.pcchqemi = DECIMAL(SUBSTRING(craptab.dstextab,71,03))
              tt-dados_dscchq.qtdiasoc = INTEGER(SUBSTRING(craptab.dstextab,75,03))
              tt-dados_dscchq.qtdevchq = INTEGER(SUBSTRING(craptab.dstextab,79,03))
              tt-dados_dscchq.pctolera = INTEGER(SUBSTRING(craptab.dstextab,83,03)).
         */     
              
       ASSIGN tt-dados_dscchq.vllimite = DECIMAL(ENTRY(1,craptab.dstextab," "))
              tt-dados_dscchq.qtdiavig = INTEGER(ENTRY(3,craptab.dstextab," ")) 

              tt-dados_dscchq.qtrenova = craprli.qtmaxren
              
              tt-dados_dscchq.qtprzmin = DECIMAL(ENTRY( 4,craptab.dstextab," "))
              tt-dados_dscchq.qtprzmax = DECIMAL(ENTRY( 5,craptab.dstextab," "))
              tt-dados_dscchq.pcdmulta = DECIMAL(ENTRY( 7,craptab.dstextab," "))
              tt-dados_dscchq.vlconchq = DECIMAL(ENTRY( 8,craptab.dstextab," "))
              tt-dados_dscchq.vlmaxemi = DECIMAL(ENTRY( 9,craptab.dstextab," "))
              tt-dados_dscchq.pcchqloc = DECIMAL(ENTRY(11,craptab.dstextab," "))
              tt-dados_dscchq.pcchqemi = DECIMAL(ENTRY(12,craptab.dstextab," "))
              tt-dados_dscchq.qtdiasoc = INTEGER(ENTRY(13,craptab.dstextab," "))
              tt-dados_dscchq.qtdevchq = INTEGER(ENTRY(14,craptab.dstextab," "))
              tt-dados_dscchq.pctolera = INTEGER(ENTRY(15,craptab.dstextab," ")).
    END.
    ELSE
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Registro de parâmetros de desconto de cheques nao encontrado.".

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

/****************************************************************************
            Buscar dados de desconto de cheques de um cooperado          
*****************************************************************************/
PROCEDURE busca_dados_dscchq:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO. 
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL     NO-UNDO.

    DEFINE OUTPUT PARAM TABLE FOR tt-erro.
    DEFINE OUTPUT PARAM TABLE FOR tt-desconto_cheques.

    DEFINE VARIABLE h-b1wgen0001 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_nrctrlim AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_dtinivig AS DATE        NO-UNDO.
    DEFINE VARIABLE aux_qtdiavig AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_vllimite AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_qtrenova AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_perrenov AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_insitblq AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_dsdlinha AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_vlutiliz AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_qtutiliz AS INTEGER     NO-UNDO.
    DEFINE VARIABLE opcao        AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_vldscchq AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_qtdscchq AS INTEGER     NO-UNDO.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Buscar dados de desconto de cheques".

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-desconto_cheques.
    
    RUN sistema/generico/procedures/b1wgen0001.p
        PERSISTENT SET h-b1wgen0001.

    IF  VALID-HANDLE(h-b1wgen0001)  THEN
    DO:
        RUN ver_capital IN h-b1wgen0001(INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 0, /* vllanmto*/
                                        INPUT par_dtmvtolt,
                                        INPUT "b1wgen0009",
                                        INPUT par_idorigem, 
                                        OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE = "NOK"  THEN
        DO:
            IF  par_flgerlog  THEN
            DO:
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
            
            END.             
            
            DELETE PROCEDURE h-b1wgen0001.
            RETURN "NOK".
            
        END.
                DELETE PROCEDURE h-b1wgen0001.
            END.

    FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper   AND
                             craplim.nrdconta = par_nrdconta   AND
                             craplim.tpctrlim = 2              AND
                             craplim.insitlim = 2  /* ATIVO */ NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craplim  THEN 
    DO:
        ASSIGN aux_nrctrlim = 0
               aux_dtinivig = ?
               aux_qtdiavig = 0
               aux_vllimite = 0
               aux_qtrenova = 0
               aux_perrenov = 0
               aux_insitblq = 0
               aux_dsdlinha = ""
               aux_vlutiliz = 0
               aux_qtutiliz = 0
               opcao        = 2.
    END.                                              
    ELSE
    DO:
        FIND crapldc WHERE crapldc.cdcooper = par_cdcooper     AND
                           crapldc.cddlinha = craplim.cddlinha AND
                           crapldc.tpdescto = 2
                           NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapldc   THEN
             aux_dsdlinha = STRING(craplim.cddlinha) + " - " + "NAO CADASTRADA".
        ELSE
             aux_dsdlinha = STRING(crapldc.cddlinha) + " - " + crapldc.dsdlinha.

        ASSIGN aux_nrctrlim = craplim.nrctrlim
               aux_dtinivig = craplim.dtinivig
               aux_qtdiavig = craplim.qtdiavig
               aux_vllimite = craplim.vllimite
               aux_qtrenova = craplim.qtrenova
               aux_perrenov = IF (craplim.dtfimvig < par_dtmvtolt) THEN 1 ELSE 0
               aux_insitblq = craplim.insitblq
               opcao        = 1.
    END.

    FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper   AND
                           crapcdb.nrdconta = par_nrdconta   AND
                           crapcdb.insitchq = 2              AND
                           crapcdb.dtlibera > par_dtmvtolt   NO-LOCK:
    
        ASSIGN aux_vldscchq = aux_vldscchq + crapcdb.vlcheque
               aux_qtdscchq = aux_qtdscchq + 1.
    
    END.
 
    CREATE tt-desconto_cheques.
    ASSIGN tt-desconto_cheques.nrctrlim = aux_nrctrlim
           tt-desconto_cheques.dtinivig = aux_dtinivig
           tt-desconto_cheques.qtdiavig = aux_qtdiavig 
           tt-desconto_cheques.vllimite = aux_vllimite
           tt-desconto_cheques.qtrenova = aux_qtrenova
           tt-desconto_cheques.perrenov = aux_perrenov
           tt-desconto_cheques.insitblq = aux_insitblq
           tt-desconto_cheques.dsdlinha = aux_dsdlinha
           tt-desconto_cheques.vldscchq = aux_vldscchq
           tt-desconto_cheques.qtdscchq = aux_qtdscchq
           tt-desconto_cheques.cddopcao = opcao.
    
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
                           
    END.

    RETURN "OK".

END PROCEDURE.

/****************************************************************************
    Buscar dados de um limite de desconto de cheques COMPLETO - opcao "I" 
****************************************************************************/
PROCEDURE busca_dados_limite_incluir:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO. 
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_inconfir AS INTE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL     NO-UNDO.
    
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-risco.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dados_dscchq.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-msg-confirma.
    
    DEFINE VARIABLE aux_regalias AS CHARACTER       NO-UNDO.
    DEFINE VARIABLE h-b1wgen0001 AS HANDLE          NO-UNDO.
    DEFINE VARIABLE h-b1wgen0058 AS HANDLE          NO-UNDO.
    DEFINE VARIABLE h-b1wgen0110 AS HANDLE          NO-UNDO.
    DEF VAR         h-b1wgen9999 AS HANDLE          NO-UNDO.
    DEF VAR         aux_nrdeanos AS INTE            NO-UNDO.
    DEF VAR         aux_nrdmeses AS INTE            NO-UNDO.
    DEF VAR         aux_dsdidade AS CHAR            NO-UNDO.
    DEF VAR         aux_dsoperac AS CHAR            NO-UNDO.
    DEF VAR         aux_flgrestrito AS INTE         NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-risco.
    EMPTY TEMP-TABLE tt-dados_dscchq.
    EMPTY TEMP-TABLE tt-msg-confirma.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Buscar dados para incluir limite de desconto " +
                              "de cheque".

    /*RUN sistema/generico/procedures/b1wgen0058.p PERSISTENT SET h-b1wgen0058.

    RUN valida_percentual_societario IN h-b1wgen0058 (INPUT par_cdcooper,
                                                      INPUT par_nrdconta,
                                                      OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0058.

    IF RETURN-VALUE <> "OK" THEN
        RETURN "NOK".*/

    RUN sistema/generico/procedures/b1wgen0001.p
        PERSISTENT SET h-b1wgen0001.

    IF  VALID-HANDLE(h-b1wgen0001)  THEN
    DO:
        RUN ver_cadastro IN h-b1wgen0001(INPUT par_cdcooper,
                                         INPUT par_nrdconta,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_dtmvtolt,
                                         INPUT par_idorigem,
                                        OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE = "NOK"  THEN
        DO:
            IF  par_flgerlog  THEN
            DO:
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

            END.             
                    
            DELETE PROCEDURE h-b1wgen0001.
            RETURN "NOK".
        END.
        DELETE PROCEDURE h-b1wgen0001.
    END.

    /* rotina para buscar o crapttl.inhabmen */
    FIND FIRST crapttl WHERE crapttl.cdcooper = par_cdcooper   AND
                             crapttl.nrdconta = par_nrdconta   AND
                             crapttl.idseqttl = 1
                             NO-LOCK NO-ERROR.
    IF  AVAIL crapttl THEN
        DO:
                  
            IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
                RUN sistema/generico/procedures/b1wgen9999.p 
                    PERSISTENT SET h-b1wgen9999.
           
            /*  Rotina que retorna a idade do cooperado */
            RUN idade IN h-b1wgen9999(INPUT crapttl.dtnasttl,
                                      INPUT par_dtmvtolt,
                                      OUTPUT aux_nrdeanos,
                                      OUTPUT aux_nrdmeses,
                                      OUTPUT aux_dsdidade).
           
            IF  VALID-HANDLE(h-b1wgen9999) THEN
                DELETE PROCEDURE h-b1wgen9999.
           
            IF  par_inconfir = 1     AND
                aux_nrdeanos >= 16   AND 
                aux_nrdeanos <  18   AND 
                crapttl.inhabmen = 0 THEN 
                DO:                    
                    CREATE tt-msg-confirma.                   
                    ASSIGN tt-msg-confirma.inconfir = par_inconfir + 1
                           tt-msg-confirma.dsmensag = "Atencao! Cooperado menor de idade. Deseja continuar?".

                    RETURN "OK".
                END.

            IF  aux_nrdeanos < 16 THEN 
                DO:
                   ASSIGN aux_cdcritic = 0
                          aux_dscritic = "Cooperado menor de idade, nao e " +
                                         "possivel realizar a operacao.".
           
                   RUN gera_erro (INPUT par_cdcooper,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  INPUT 1,            /** Sequencia **/
                                  INPUT aux_cdcritic,
                                  INPUT-OUTPUT aux_dscritic).
                
                   IF  par_flgerlog  THEN
                       DO:
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
                   
                       END.
                   
                       RETURN "NOK".
                   
                END.
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF NOT AVAIL(crapass)  THEN
       DO:
           ASSIGN aux_cdcritic = 9
                  aux_dscritic = "".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           IF par_flgerlog  THEN
              DO:
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
              
              END.
     
           RETURN "NOK".        

       END.
    
   /*Se tem cnae verificar se e um cnae restrito*/
   IF  crapass.cdclcnae > 0 THEN
       DO:

            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

            /* Busca a se o CNAE eh restrito */
            RUN STORED-PROCEDURE pc_valida_cnae_restrito
            aux_handproc = PROC-HANDLE NO-ERROR (INPUT crapass.cdclcnae
                                                ,0).

            CLOSE STORED-PROC pc_valida_cnae_restrito
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

            ASSIGN aux_flgrestrito = INTE(pc_valida_cnae_restrito.pr_flgrestrito)
                                        WHEN pc_valida_cnae_restrito.pr_flgrestrito <> ?.

            IF  aux_flgrestrito = 1 THEN
                DO:
                  CREATE tt-msg-confirma.
                  ASSIGN tt-msg-confirma.inconfir = par_inconfir + 1
                         tt-msg-confirma.dsmensag = "CNAE restrito, conforme previsto na Política de Responsabilidade <br> Socioambiental do Sistema AILOS. Necessário apresentar Licença Regulatória.<br><br>Deseja continuar?".
                END.

        END.

    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p
           PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de incluir a proposta de limite de " + 
                          "descontos de cheques na conta "                +
                          STRING(crapass.nrdconta,"zzzz,zzz,9")           +
                          " - CPF/CNPJ "                                  +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),"xx.xxx.xxx/xxxx-xx")).

    /*Verifica se o titular em questao esta no cadastro restritivo. Se estiver,
      sera enviado um e-mail informando a situacao*/
    RUN alerta_fraude IN h-b1wgen0110
                        (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT par_cdoperad,
                         INPUT par_nmdatela,
                         INPUT par_dtmvtolt,
                         INPUT par_idorigem,
                         INPUT crapass.nrcpfcgc,
                         INPUT crapass.nrdconta, 
                         INPUT par_idseqttl,
                         INPUT TRUE, /*bloqueia operacao*/
                         INPUT 4, /*cdoperac*/
                         INPUT aux_dsoperac,
                         OUTPUT TABLE tt-erro).

    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).

    IF RETURN-VALUE <> "OK"  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF NOT AVAIL tt-erro THEN
              DO:
                 ASSIGN aux_cdcritic = 0
                        aux_dscritic = "Nao foi possivel verificar o " +
                                       "cadastro restritivo.".
                        
                 RUN gera_erro (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT 1,            /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic).

              END.
           ELSE
              ASSIGN aux_dscritic = tt-erro.dscritic.

           IF par_flgerlog  THEN
              DO:
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
              
              END.
     
           RETURN "NOK".

       END.
    
    RUN busca_parametros_dscchq (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_idorigem,
                                 INPUT crapass.inpessoa,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dados_dscchq).

    IF  RETURN-VALUE = "NOK" THEN
    DO:
        IF  par_flgerlog  THEN
        DO:
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
            
        END. 
        
        RETURN "NOK".
    END.

    FIND FIRST tt-dados_dscchq NO-LOCK NO-ERROR.           
            
    IF tt-dados_dscchq.qtdiasoc > 0  THEN
       DO:
           FIND craptab WHERE craptab.cdcooper = par_cdcooper AND
                              craptab.nmsistem = "CRED"       AND
                              craptab.tptabela = "USUARI"     AND
                              craptab.cdempres = 11           AND
                              craptab.cdacesso = "LIBPRAZEMP" AND
                              craptab.tpregist = 001          
                              NO-LOCK NO-ERROR.
       
           IF AVAILABLE craptab  THEN
              ASSIGN aux_regalias = craptab.dstextab.
       
           IF tt-dados_dscchq.qtdiasoc > (par_dtmvtolt - crapass.dtmvtolt) AND
              NOT CAN-DO(aux_regalias,STRING(crapass.nrdconta)) THEN
           DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Tempo mínimo de filiacao abaixo do "  + 
                                    "parâmetro, tempo mínino "             +
                                    STRING(tt-dados_dscchq.qtdiasoc)       + 
                                    IF tt-dados_dscchq.qtdiasoc > 1  THEN
                                       " dias."
                                    ELSE
                                       " dia.".
       
              RUN gera_erro (INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,            /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic).        
       
              IF par_flgerlog  THEN
                 DO:
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
                 
                 END.
       
              RETURN "NOK".

           END.
       
       END.

    RUN busca_dados_risco (INPUT par_cdcooper,
                           OUTPUT TABLE tt-risco). 

    IF par_flgerlog  THEN
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
                              
       END.    

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*     Validar dados informados da proposta de limite novo ou alteracao      */
/*****************************************************************************/
PROCEDURE valida_proposta_dados:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctrlim AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtopr AS DATE        NO-UNDO.    
    DEFINE INPUT  PARAMETER par_inproces AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_diaratin AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vllimite AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtrating AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlrrisco AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddopcao AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddlinha AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_inconfir AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_inconfi2 AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_inconfi4 AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_inconfi5 AS INTE        NO-UNDO. 
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL     NO-UNDO.
    
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-msg-confirma.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-grupo. 

    DEFINE VARIABLE aux_vlr_maxleg   AS DECIMAL    NO-UNDO.
    DEFINE VARIABLE aux_vlr_maxutl   AS DECIMAL    NO-UNDO.
    DEFINE VARIABLE aux_vlr_minscr   AS DECIMAL    NO-UNDO.
    DEFINE VARIABLE aux_vlr_excedido AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE aux_vlutiliz     AS DECIMAL    NO-UNDO.
    DEFINE VARIABLE aux_contador     AS INTEGER    NO-UNDO.
    DEFINE VARIABLE aux_valor        AS DECIMAL    NO-UNDO.
    DEFINE VARIABLE aux_recid        AS RECID      NO-UNDO.
    DEFINE VARIABLE h-b1wgen9999     AS HANDLE     NO-UNDO.
    DEFINE VARIABLE h-b1wgen0138     AS HANDLE     NO-UNDO.
    DEFINE VARIABLE h-b1wgen0110     AS HANDLE     NO-UNDO.
    DEFINE VARIABLE aux_nrdgrupo     AS INTEGER    NO-UNDO.
    DEFINE VARIABLE aux_gergrupo     AS CHAR       NO-UNDO.
    DEFINE VARIABLE aux_dsdrisgp     AS CHAR       NO-UNDO.
    DEFINE VARIABLE aux_pertengp     AS LOG        NO-UNDO.
    DEFINE VARIABLE aux_dsdrisco     AS CHAR       NO-UNDO.
    DEFINE VARIABLE aux_dsoperac     AS CHAR       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-msg-confirma.
    EMPTY TEMP-TABLE tt-grupo.
    
    ASSIGN aux_dscritic     = ""
           aux_cdcritic     = 0
           aux_vlr_excedido = NO
           aux_vlr_maxleg   = 0
           aux_vlr_maxutl   = 0
           aux_vlr_minscr   = 0.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF NOT AVAIL(crapass)  THEN
       DO:
           ASSIGN aux_cdcritic = 9
                  aux_dscritic = "".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           IF par_flgerlog  THEN
              DO:
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
              
              END.
     
           RETURN "NOK".        

       END.

    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p
           PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    IF par_cddopcao = "A" THEN
       ASSIGN aux_dsoperac = "Tentativa de alterar a proposta de limite de "  +
                             "descontos de cheques na conta "                 +
                             STRING(crapass.nrdconta,"zzzz,zzz,9")            +
                             " - CPF/CNPJ "                                   +
                            (IF crapass.inpessoa = 1 THEN
                                STRING((STRING(crapass.nrcpfcgc,
                                        "99999999999")),"xxx.xxx.xxx-xx")
                             ELSE
                                STRING((STRING(crapass.nrcpfcgc,
                                        "99999999999999")),
                                        "xx.xxx.xxx/xxxx-xx")).
    ELSE
       ASSIGN aux_dsoperac = "Tentativa de incluir novo limite de descontos " +
                             "de cheques na conta "                           +
                             STRING(crapass.nrdconta,"zzzz,zzz,9")            +
                             " - CPF/CNPJ "                                   +
                            (IF crapass.inpessoa = 1 THEN
                                STRING((STRING(crapass.nrcpfcgc,
                                        "99999999999")),"xxx.xxx.xxx-xx")
                             ELSE
                                STRING((STRING(crapass.nrcpfcgc,
                                        "99999999999999")),
                                        "xx.xxx.xxx/xxxx-xx")).

    /*Verifica se o associado esta no cadastro restritivo. Se estiver,
      sera enviado um e-mail informando a situacao*/
    RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_dtmvtolt,
                                      INPUT par_idorigem,
                                      INPUT crapass.nrcpfcgc,
                                      INPUT crapass.nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT (IF par_cddopcao = "A" THEN 
                                                3 /*cdoperac*/
                                             ELSE
                                                4), /*cdoperac*/
                                      INPUT aux_dsoperac,
                                      OUTPUT TABLE tt-erro).
    
    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).

    IF RETURN-VALUE <> "OK" THEN
       DO:
          FIND FIRST tt-erro NO-LOCK NO-ERROR.

          IF NOT AVAIL tt-erro THEN
             DO:
                ASSIGN aux_dscritic = "Nao foi possivel verificar o " + 
                                      "cadastro restritivo.".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1, /*sequencia*/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

             END.
          ELSE 
             ASSIGN aux_dscritic = tt-erro.dscritic.

          IF par_flgerlog  THEN
             DO:
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
             
             END.

          RETURN "NOK".

       END.

    
    IF par_flgerlog  THEN
       DO:
           ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

           IF par_cddopcao = "A"  THEN
              ASSIGN aux_dstransa = "Validar dados proposta p/ alterar " +
                                     "limite desconto cheques".
           ELSE
              IF par_cddopcao = "I"  THEN
                 ASSIGN aux_dstransa = "Validar dados proposta p/ incluir " +
                                       "limite desconto cheques".

       END.

    RUN busca_parametros_dscchq (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_idorigem,
                                 INPUT crapass.inpessoa,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dados_dscchq).

    IF RETURN-VALUE = "NOK" THEN
       DO:
           IF par_flgerlog  THEN
              DO:
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
              
              END.
           
           RETURN "NOK".
       
       END.
        
    IF par_vllimite > tt-dados_dscchq.vllimite  THEN
       DO:
          ASSIGN aux_cdcritic = 0 
                 aux_dscritic = "Limite maximo por contrato excedido, " + 
                                "valor maximo R$ " + 
                             STRING(tt-dados_dscchq.vllimite,"zzz,zzz,zz9.99") + 
                             ".".
                 
          RUN gera_erro (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT 1,            /** Sequencia **/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).
          
          IF par_flgerlog  THEN
             DO:
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
             
             END.
       
          RETURN "NOK".

       END.
   
    FIND crapldc WHERE crapldc.cdcooper = par_cdcooper   AND
                       crapldc.cddlinha = par_cddlinha   AND
                       crapldc.tpdescto = 2              AND
                       crapldc.flgstlcr = TRUE /*ATIVA*/
                       NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE crapldc  THEN
       DO:
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = "Linha de desconto nao cadastrada.".
                  
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
            
           IF par_flgerlog  THEN
              DO:
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
              
              END.
           
           RETURN "NOK".    
       
       END.    
       
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF AVAIL crapcop THEN
       ASSIGN aux_vlr_maxleg = crapcop.vlmaxleg
              aux_vlr_maxutl = crapcop.vlmaxutl
              aux_vlr_minscr = crapcop.vlcnsscr.
    
    IF NOT VALID-HANDLE(h-b1wgen0138) THEN
       RUN sistema/generico/procedures/b1wgen0138.p
           PERSISTENT SET h-b1wgen0138.

    
    ASSIGN aux_pertengp = DYNAMIC-FUNCTION("busca_grupo" IN h-b1wgen0138,
                                                         INPUT par_cdcooper,
                                                         INPUT par_nrdconta,
                                                         OUTPUT aux_nrdgrupo,
                                                         OUTPUT aux_gergrupo,
                                                         OUTPUT aux_dsdrisgp).
    
    
    IF par_inconfi5 = 30 THEN
       DO:
          IF aux_gergrupo <> "" THEN
             DO:
                CREATE tt-msg-confirma.
                
                ASSIGN tt-msg-confirma.inconfir = par_inconfi5 + 1
                       tt-msg-confirma.dsmensag = aux_gergrupo + " Confirma?".
    
                IF VALID-HANDLE(h-b1wgen0138) THEN
                   DELETE OBJECT(h-b1wgen0138).
                            
                RETURN "OK".
    
             END.
    
       END.
      
    IF aux_pertengp THEN
       DO:
          RUN calc_endivid_grupo IN h-b1wgen0138
                                   (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT par_cdoperad,
                                    INPUT par_dtmvtolt,
                                    INPUT par_nmdatela,
                                    INPUT par_idorigem,
                                    INPUT aux_nrdgrupo,
                                    INPUT TRUE, /*Consulta por conta*/
                                    OUTPUT aux_dsdrisco,
                                    OUTPUT aux_vlutiliz,
                                    OUTPUT TABLE tt-grupo,
                                    OUTPUT TABLE tt-erro).

          IF VALID-HANDLE(h-b1wgen0138) THEN
             DELETE OBJECT(h-b1wgen0138).

          IF RETURN-VALUE <> "OK" THEN
             RETURN "NOK".

          IF par_inconfi2 > 10  THEN
             DO:
                IF aux_vlr_maxutl > 0  THEN
                   DO:
                      IF par_vllimite > aux_vlutiliz THEN
                         ASSIGN aux_valor = par_vllimite.       
                      ELSE
                         ASSIGN aux_valor = aux_vlutiliz.

                      IF par_inconfi2 = 11 THEN
                         DO:
                            IF aux_valor > aux_vlr_maxutl THEN
                               DO:
                                  CREATE tt-msg-confirma.

                                  ASSIGN tt-msg-confirma.inconfir = 
                                                          par_inconfi2 + 1
                                         tt-msg-confirma.dsmensag = 
                                         "Vlrs(Utl) Excedidos(Utiliz. " +
                                         TRIM(STRING(aux_vlutiliz,
                                         "zzz,zzz,zz9.99")) + 
                                         " Excedido " + 
                                         TRIM(STRING((aux_valor 
                                         - aux_vlr_maxutl),
                                         "zzz,zzz,zz9.99")) 
                                         + ")Confirma? ".
       
                                  RETURN "OK".

                                END.      

                         END.
                    
                      IF par_inconfi2 = 12 AND
                         (aux_valor > aux_vlr_maxleg)  THEN
                         DO:
                             CREATE tt-msg-confirma.

                             ASSIGN tt-msg-confirma.inconfir = 19
                                    tt-msg-confirma.dsmensag = 
                                    "Vlr(Legal) Excedido(Utiliz. " + 
                                    TRIM(STRING(aux_vlutiliz,
                                    "zzz,zzz,zz9.99")) +
                                    " Excedido " + 
                                    TRIM(STRING((aux_valor
                                    - aux_vlr_maxleg),"zzz,zzz,zz9.99")) 
                                    + ") ".
                               
                            ASSIGN aux_dscritic = "" 
                                   aux_cdcritic = 79.
                             
                             RUN gera_erro (INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT 1,     /** Sequencia **/
                                            INPUT aux_cdcritic,
                                            INPUT-OUTPUT aux_dscritic). 

                             RETURN "NOK".

                         END.

                   END.

             END.
           
           IF par_inconfi4 = 71  THEN
              DO:
                 IF aux_valor >  aux_vlr_minscr  THEN
                    DO:
                        CREATE tt-msg-confirma.

                        ASSIGN tt-msg-confirma.inconfir = par_inconfi4 + 1
                               tt-msg-confirma.dsmensag = "Efetue consulta " +
                                                          "no SCR.".

                    END.

              END.

       END.
    ELSE /* NAO E DO GRUPO */
       DO:
          IF VALID-HANDLE(h-b1wgen0138) THEN
              DELETE OBJECT(h-b1wgen0138).

          RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
              SET h-b1wgen9999.
              
          IF NOT VALID-HANDLE(h-b1wgen9999)  THEN
             DO:
                 ASSIGN aux_cdcritic = 0
                        aux_dscritic = "Handle invalido para BO b1wgen9999.".
                        
                 RUN gera_erro (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT 1,            /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic).
                                            
                 IF par_flgerlog  THEN
                    DO:
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
             
                    END.        
                 
                 RETURN "NOK".

             END.            
       
          RUN saldo_utiliza IN h-b1wgen9999 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT par_dtmvtolt,
                                             INPUT par_dtmvtopr,
                                             INPUT "",
                                             INPUT par_inproces,
                                             INPUT FALSE, /*Consulta por cpf*/
                                             OUTPUT aux_vlutiliz,
                                             OUTPUT TABLE tt-erro).
       
          DELETE PROCEDURE h-b1wgen9999.
          
          IF RETURN-VALUE = "NOK"  THEN
             DO:
                IF par_flgerlog  THEN
                   DO:
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
                   END.
                RETURN "NOK".
             END.

          IF par_inconfi2 > 10  THEN
             DO:
                IF  aux_vlr_maxutl > 0  THEN
                DO:
                    IF par_vllimite > aux_vlutiliz THEN
                       ASSIGN aux_valor = par_vllimite.
                    ELSE
                       ASSIGN aux_valor = aux_vlutiliz.

                    IF par_inconfi2 = 11 THEN
                       DO:
                          IF aux_valor > aux_vlr_maxutl THEN
                             DO:
                                 CREATE tt-msg-confirma.

                                 ASSIGN tt-msg-confirma.inconfir = 
                                                        par_inconfi2 + 1
                                        tt-msg-confirma.dsmensag = "Vlrs(Utl) Excedidos(Utiliz. " +
                                              TRIM(STRING(aux_vlutiliz,"zzz,zzz,zz9.99")) + " Excedido " + 
                                              TRIM(STRING((aux_valor - aux_vlr_maxutl),"zzz,zzz,zz9.99")) + ")Confirma? ".
                                 RETURN "OK".
                              END.
                       END.

                    IF par_inconfi2 = 12             AND
                       (aux_valor > aux_vlr_maxleg)  THEN
                       DO:
                           CREATE tt-msg-confirma.

                           ASSIGN tt-msg-confirma.inconfir = 19
                                  tt-msg-confirma.dsmensag = 
                                  "Vlr(Legal) Excedido(Utiliz. " + 
                                  TRIM(STRING(aux_vlutiliz,
                                  "zzz,zzz,zz9.99")) +
                                  " Excedido " + 
                                  TRIM(STRING((aux_valor
                                  - aux_vlr_maxleg),"zzz,zzz,zz9.99")) 
                                  + ") ".
                             
                           ASSIGN aux_dscritic = "" 
                                  aux_cdcritic = 79.
                           
                           RUN gera_erro (INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT 1,     /** Sequencia **/
                                          INPUT aux_cdcritic,
                                          INPUT-OUTPUT aux_dscritic). 

                           RETURN "NOK".
                       END.

                END.
             END.

          IF par_inconfi4 = 71  THEN
             DO:
                IF aux_valor >  aux_vlr_minscr  THEN
                   DO:
                      CREATE tt-msg-confirma.
                      ASSIGN tt-msg-confirma.inconfir = par_inconfi4 + 1
                             tt-msg-confirma.dsmensag = "Efetue consulta no SCR.".
                   END.
             END.
       END.

    IF par_cddopcao = "I"  THEN
       DO:
           IF  CAN-FIND(craplim WHERE craplim.cdcooper = par_cdcooper   AND
                                      craplim.nrdconta = par_nrdconta   AND
                                      craplim.nrctrlim = par_nrctrlim   AND
                                      craplim.tpctrlim = 2) THEN
           DO:
               ASSIGN aux_dscritic = "Proposta de limite ja existe."
                      aux_cdcritic = 0.
               
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,     /** Sequencia **/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
               
               IF  par_flgerlog  THEN
               DO:
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
               END.
               RETURN "NOK".
           END.
    
           IF  CAN-FIND(crapprp WHERE crapprp.cdcooper = par_cdcooper   AND
                                      crapprp.nrdconta = par_nrdconta   AND
                                      crapprp.nrctrato = par_nrctrlim   AND
                                      crapprp.tpctrato = 2) THEN
           DO:
               ASSIGN aux_dscritic = "Registro de proposta ja existe."
                      aux_cdcritic = 0.
               
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,     /** Sequencia **/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
               
               IF  par_flgerlog  THEN
               DO:
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
               END.
               RETURN "NOK".
           END.
       END.
       
    IF par_flgerlog  THEN
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
       END.
    RETURN "OK".

END PROCEDURE.

/***************************************************************************
           Validar numero de contrato informado e tabela avl              
***************************************************************************/
PROCEDURE valida_nrctrato_avl:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.    
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctrlim AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_antnrctr AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctaav1 AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctaav2 AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL     NO-UNDO.
    
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Validar numero de contrato informado e " +
                              "avalistas".
    
    IF  par_nrctaav1 > 0 THEN
    DO:
        IF  CAN-FIND(crapavl WHERE 
                     crapavl.cdcooper = par_cdcooper AND
                     crapavl.nrdconta = par_nrctaav1 AND
                     crapavl.nrctravd = par_nrctrlim AND
                     crapavl.tpctrato = 2) THEN         
        DO:
            ASSIGN aux_cdcritic = 390
                   aux_dscritic = "".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            IF  par_flgerlog  THEN
            DO:
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
       
            END.
            
            RETURN "NOK".

        END.
    END.
                  
    IF  par_nrctaav2 > 0 THEN
    DO:
        IF  CAN-FIND(crapavl WHERE 
                     crapavl.cdcooper = par_cdcooper AND
                     crapavl.nrdconta = par_nrctaav2 AND
                     crapavl.nrctravd = par_nrctrlim AND
                     crapavl.tpctrato = 2)  THEN
        DO:                         
        
            ASSIGN aux_cdcritic = 390
                   aux_dscritic = "".
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
            DO:
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
       
            END.                    
            
            RETURN "NOK".                    

        END.
    END.

    IF  par_nrctrlim <> par_antnrctr  THEN
    DO:
        ASSIGN aux_cdcritic = 301
               aux_dscritic = "".
               
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        IF  par_flgerlog  THEN
        DO:
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
   
        END.

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
                           
    END. 
            
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
       Efetuar a inclusao de uma novo limite de desconto de cheques        
*****************************************************************************/
PROCEDURE efetua_inclusao_limite:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_vllimite AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsramati AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlmedchq AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlfatura AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vloutras AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlsalari AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlsalcon AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdbens1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdbens2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddlinha AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsobserv AS CHARACTER   NO-UNDO.   
    DEFINE INPUT  PARAMETER par_qtdiavig AS INTEGER     NO-UNDO. 
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    /** ------------------- Parametros do 1 avalista ------------------- **/
    DEFINE INPUT  PARAMETER par_nrctaav1 AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdaval1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcpfav1 AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpdocav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdocav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdcjav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cpfcjav1 AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_tdccjav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_doccjav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_ende1av1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_ende2av1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrfonav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_emailav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmcidav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdufava1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcepav1 AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrender1 AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_complen1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcxaps1 AS INTEGER     NO-UNDO.
    /** -------------------- Parametros do 2 avalista ------------------- **/
    DEFINE INPUT  PARAMETER par_nrctaav2 AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdaval2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcpfav2 AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpdocav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdocav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdcjav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cpfcjav2 AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_tdccjav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_doccjav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_ende1av2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_ende2av2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrfonav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_emailav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmcidav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdufava2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcepav2 AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrender2 AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_complen2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcxaps2 AS INTEGER     NO-UNDO.
    /** ----------------------------- Rating ---------------------------- **/
    DEFINE INPUT  PARAMETER par_nrgarope AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrinfcad AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrliquid AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrpatlvr AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vltotsfn AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_perfatcl AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrperger AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idcobope AS INTEGER     NO-UNDO.
    
    DEFINE OUTPUT PARAMETER par_nrctrlim AS INTEGER     NO-UNDO.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAM TABLE FOR tt-msg-confirma.
        
    DEFINE VARIABLE h-b1wgen0021 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE aux_contador AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_flgderro AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE aux_lscontas AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_nrctrlim AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrseqcar AS INTEGER     NO-UNDO.
    DEF VAR aux_mensagens    AS CHAR            NO-UNDO.    
    DEF VAR aux_dsfrase      AS CHAR            NO-UNDO. /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
    DEF VAR aux_dsdlinha     AS CHAR            NO-UNDO. /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Efetuar inclusao de limite de desconto " +
                              "de cheque".

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF NOT AVAIL(crapass)  THEN
       DO:
           ASSIGN aux_cdcritic = 9
                  aux_dscritic = "".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
                          
           IF par_flgerlog  THEN
              DO:
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
              
              END.
     
           RETURN "NOK".        

       END.
       
    RUN busca_parametros_dscchq (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_idorigem,
                                 INPUT crapass.inpessoa,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dados_dscchq).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
    
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
      

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para h-b1wgen9999.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            IF  par_flgerlog  THEN
            DO:
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
       
            END.

            RETURN "NOK".
        END.


    TRANS_INCLUI:    
    DO  TRANSACTION ON ERROR UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI:
    
        DO WHILE TRUE:
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

          /* Busca a proxima sequencia do campo crapldt.nrsequen */
          RUN STORED-PROCEDURE pc_sequence_progress
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLIM"
                                              ,INPUT "NRCTRLIM"
                                              ,STRING(par_cdcooper) + ";" + "2" /* tpctrlim */
                                              ,INPUT "N"
                                              ,"").

          CLOSE STORED-PROC pc_sequence_progress
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

          ASSIGN aux_nrseqcar = INTE(pc_sequence_progress.pr_sequence)
                                WHEN pc_sequence_progress.pr_sequence <> ?.
          
          ASSIGN aux_nrctrlim = aux_nrseqcar.
                            
          
          
          FIND FIRST craplim 
               WHERE craplim.cdcooper = par_cdcooper
                 AND craplim.tpctrlim = 2
                 AND craplim.nrctrlim = aux_nrctrlim
                 NO-LOCK NO-ERROR.
          IF NOT AVAILABLE craplim THEN       
          DO:
            LEAVE.
          END.
                 
        END.       
        
        ASSIGN par_nrctrlim = aux_nrctrlim.
    
        RUN cria-tabelas-avalistas IN h-b1wgen9999 (INPUT par_cdcooper,
                                                    INPUT par_cdoperad,
                                                    INPUT par_idorigem,
                                                    INPUT "DESC.CHEQUE",
                                                    INPUT par_nrdconta,
                                                    INPUT par_dtmvtolt,
                                                    INPUT 2, /* Tipo Contrato */
                                                    INPUT par_nrctrlim,
                                                    INPUT par_cdagenci,
                                                    INPUT par_nrdcaixa,
                                                    /** 1o avalista **/
                                                    INPUT par_nrctaav1,
                                                    INPUT par_nmdaval1,
                                                    INPUT par_nrcpfav1,
                                                    INPUT par_tpdocav1,
                                                    INPUT par_dsdocav1,
                                                    INPUT par_nmdcjav1,
                                                    INPUT par_cpfcjav1, 
                                                    INPUT par_tdccjav1,
                                                    INPUT par_doccjav1,
                                                    INPUT par_ende1av1,
                                                    INPUT par_ende2av1,
                                                    INPUT par_nrfonav1,
                                                    INPUT par_emailav1,
                                                    INPUT par_nmcidav1,
                                                    INPUT par_cdufava1,
                                                    INPUT par_nrcepav1,
                                                    INPUT 0,
                                                    INPUT 0,
                                                    INPUT 0,
                                                    INPUT par_nrender1,
                                                    INPUT par_complen1,
                                                    INPUT par_nrcxaps1,
                                                    INPUT 0,            /* inpessoa 1o avail */
                                                    INPUT ?,            /* dtnascto 1o avail */
                                                    INPUT 0, /* par_vlrecjg1 */
                                                    /** 2o avalista **/
                                                    INPUT par_nrctaav2,
                                                    INPUT par_nmdaval2, 
                                                    INPUT par_nrcpfav2,
                                                    INPUT par_tpdocav2,
                                                    INPUT par_dsdocav2, 
                                                    INPUT par_nmdcjav2, 
                                                    INPUT par_cpfcjav2,
                                                    INPUT par_tdccjav2,
                                                    INPUT par_doccjav2,
                                                    INPUT par_ende1av2,
                                                    INPUT par_ende2av2,
                                                    INPUT par_nrfonav2,
                                                    INPUT par_emailav2, 
                                                    INPUT par_nmcidav2, 
                                                    INPUT par_cdufava2, 
                                                    INPUT par_nrcepav2,
                                                    INPUT 0,
                                                    INPUT 0,
                                                    INPUT 0,
                                                    INPUT par_nrender2,
                                                    INPUT par_complen2,
                                                    INPUT par_nrcxaps2,
                                                    INPUT 0,            /* inpessoa 2o avail */
                                                    INPUT ?,            /* dtnascto 2o avail */
                                                    INPUT 0, /* par_vlrecjg2 */
                                                    INPUT "",
                                                   OUTPUT TABLE tt-erro).
        
        DELETE PROCEDURE h-b1wgen9999.
        
        IF RETURN-VALUE = "NOK" THEN
        DO:
            aux_flgderro = TRUE.
            UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.
        END.

        RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT
            SET h-b1wgen0021.

        IF  VALID-HANDLE(h-b1wgen0021)  THEN
            DO:
                RUN obtem-saldo-cotas IN h-b1wgen0021 
                                              (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nmdatela,
                                               INPUT par_idorigem,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                               OUTPUT TABLE tt-saldo-cotas,
                                               OUTPUT TABLE tt-erro). 
        
                DELETE PROCEDURE h-b1wgen0021.

                IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    aux_flgderro = TRUE.
                    
                    UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.

                END.
            
            END.
        ELSE
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para h-b1wgen0021.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                               
                aux_flgderro = TRUE.
                
                UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.
            END.

        FIND FIRST tt-saldo-cotas NO-LOCK NO-ERROR.
        IF  NOT AVAIL tt-saldo-cotas THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Registro de cotas nao encontrado.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                               
                aux_flgderro = TRUE.
                
                UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.                
            END.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
            
        IF   crapass.inpessoa <> 1   THEN
             DO:
                 DO aux_contador = 1 TO 10:
     
                    FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper  AND
                                       crapjfn.nrdconta = par_nrdconta  
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                   
                    IF   NOT AVAILABLE crapjfn   THEN
                         IF  LOCKED crapjfn   THEN
                             DO:
                                ASSIGN aux_cdcritic = 72.
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                             END.
                         ELSE
                             DO:
                                CREATE crapjfn.
                                ASSIGN crapjfn.cdcooper = par_cdcooper
                                       crapjfn.nrdconta = par_nrdconta.                                       
                             END.

                    ASSIGN crapjfn.perfatcl = par_perfatcl
                           aux_cdcritic = 0.

                    VALIDATE crapjfn.

                    LEAVE.

                 END.  /* Fim do DO TO */

                 IF   aux_cdcritic > 0   THEN
                      DO:
                          ASSIGN aux_dscritic = "".
                          
                          RUN gera_erro (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT 1,            /** Sequencia **/
                                         INPUT aux_cdcritic,
                                         INPUT-OUTPUT aux_dscritic).
                                      
                          aux_flgderro = TRUE.
                           
                          UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.
                      END.             
             END.
        
        /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
        IF par_cdagenci = 0 THEN
          ASSIGN par_cdagenci = glb_cdagenci.
        /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */

        CREATE craplim.

        ASSIGN craplim.nrdconta    = par_nrdconta
               craplim.tpctrlim    = 2 /* Desconto de cheque */
               craplim.nrctrlim    = par_nrctrlim
               craplim.dtpropos    = par_dtmvtolt
               /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               craplim.cdopeori = par_cdoperad
               craplim.cdageori = par_cdagenci
               craplim.dtinsori = TODAY
               /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               craplim.insitlim    = 1
               craplim.cddlinha    = par_cddlinha
               craplim.qtdiavig    = par_qtdiavig
               craplim.cdoperad    = par_cdoperad
               craplim.cdmotcan    = 0
               craplim.vllimite    = par_vllimite
               craplim.inbaslim    = IF par_vllimite > 
                                        tt-saldo-cotas.vlsldcap THEN
                                        2
                                     ELSE  
                                        1
               craplim.nrgarope    = par_nrgarope
               craplim.nrinfcad    = par_nrinfcad
               craplim.nrliquid    = par_nrliquid
               craplim.nrpatlvr    = par_nrpatlvr
               craplim.vltotsfn    = par_vltotsfn
               craplim.nrperger    = par_nrperger
               
               craplim.flgimpnp    = TRUE
               craplim.nrctaav1    = par_nrctaav1
               craplim.nrctaav2    = par_nrctaav2
                                            
               craplim.qtrenctr    = tt-dados_dscchq.qtrenova

               craplim.dsendav1[1] = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende1av1) + " " +
                                         STRING(par_nrender1)
               craplim.dsendav1[2] = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende2av1) + " - " + 
                                         CAPS(par_nmcidav1) + " - " +
                                         STRING(par_nrcepav1,"99999,999") +
                                         " - " + CAPS(par_cdufava1)
               craplim.dsendav2[1] = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende1av2) + " " +
                                         STRING(par_nrender2)
               craplim.dsendav2[2] = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende2av2) + " - " + 
                                         CAPS(par_nmcidav2) + " - " +
                                         STRING(par_nrcepav2,"99999,999") +
                                         " - " + CAPS(par_cdufava2)
               craplim.nmdaval1    = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_nmdaval1)
               craplim.nmdaval2    = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE    
                                         CAPS(par_nmdaval2)
               craplim.dscpfav1    = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         par_dsdocav1
               craplim.dscpfav2    = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         par_dsdocav2
               craplim.nmcjgav1    = CAPS(par_nmdcjav1)
               craplim.nmcjgav2    = CAPS(par_nmdcjav2)
               craplim.dscfcav1    = CAPS(par_doccjav1)
               craplim.dscfcav2    = CAPS(par_doccjav2)
               craplim.cdcooper    = par_cdcooper
               craplim.idcobope    = par_idcobope
               craplim.idcobefe    = par_idcobope.
        VALIDATE craplim.

        FIND FIRST crapprp WHERE crapprp.cdcooper = par_cdcooper     AND
                                 crapprp.nrdconta = par_nrdconta     AND
                                 crapprp.tpctrato = 2                AND
                                 crapprp.nrctrato = craplim.nrctrlim
                                 NO-LOCK NO-ERROR.

        IF  AVAILABLE crapprp  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Registro de proposta ja existe.".
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                aux_flgderro = TRUE.
                
                UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.
            END.               
               
        CREATE crapprp.
        ASSIGN crapprp.nrdconta = par_nrdconta
               crapprp.nrctrato = par_nrctrlim
               crapprp.tpctrato = 2 /* Dscto Cheque */
               crapprp.dsramati = CAPS(par_dsramati)
               crapprp.vlmedchq = par_vlmedchq
               crapprp.vlfatura = par_vlfatura
               crapprp.vloutras = par_vloutras
               crapprp.vlsalari = par_vlsalari
               crapprp.vlsalcon = par_vlsalcon
               crapprp.dsdebens = STRING(par_dsdbens1,"x(60)") + 
                                  STRING(par_dsdbens2,"x(60)")
               crapprp.dsobserv[1] = CAPS(par_dsobserv)
               crapprp.dsobserv[2] = ""
               crapprp.dsobserv[3] = ""
               crapprp.cdcooper    = par_cdcooper
               crapprp.dtmvtolt    = par_dtmvtolt.
        VALIDATE crapprp.

        /* Verificar se a conta pertence ao grupo economico novo */ 
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_obtem_mensagem_grp_econ_prg
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper
                                              ,INPUT par_nrdconta
                                              ,""
                                              ,0
                                              ,"").

        CLOSE STORED-PROC pc_obtem_mensagem_grp_econ_prg
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_cdcritic  = 0
               aux_dscritic  = ""
               aux_cdcritic  = INT(pc_obtem_mensagem_grp_econ_prg.pr_cdcritic) WHEN pc_obtem_mensagem_grp_econ_prg.pr_cdcritic <> ?
               aux_dscritic  = pc_obtem_mensagem_grp_econ_prg.pr_dscritic WHEN pc_obtem_mensagem_grp_econ_prg.pr_dscritic <> ?
               aux_mensagens = pc_obtem_mensagem_grp_econ_prg.pr_mensagens WHEN pc_obtem_mensagem_grp_econ_prg.pr_mensagens <> ?.
                        
        IF aux_cdcritic > 0 THEN
           DO:
               RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                ASSIGN aux_flgderro = TRUE.                
                UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.
           END.
        ELSE IF aux_dscritic <> ? AND aux_dscritic <> "" THEN
          DO:
              RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

              ASSIGN aux_flgderro = TRUE.
              UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.
          END.
                      
        IF aux_mensagens <> ? AND aux_mensagens <> "" THEN
           DO:
               CREATE tt-msg-confirma.
               ASSIGN tt-msg-confirma.inconfir = 1
                      tt-msg-confirma.dsmensag = aux_mensagens.
           END.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_vincula_cobertura_operacao
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT 0
                                              ,INPUT par_idcobope
                                              ,INPUT par_nrctrlim
                                              ,"").

        CLOSE STORED-PROC pc_vincula_cobertura_operacao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic  = ""
               aux_dscritic  = pc_vincula_cobertura_operacao.pr_dscritic 
               WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.
                        
        IF aux_dscritic <> "" THEN
           DO:
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,            /** Sequencia **/
                              INPUT 0,
                              INPUT-OUTPUT aux_dscritic).

                ASSIGN aux_flgderro = TRUE.                
                UNDO TRANS_INCLUI, LEAVE TRANS_INCLUI.
           END.

    END. /* Final da TRANSACAO */
    
    IF  aux_flgderro  THEN
    DO:
        IF  par_flgerlog  THEN
        DO:
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

            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT par_nrctrlim).

        END.

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
      /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
        /** Numero de Contrato do Limite **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Contrato",
                                 INPUT "",
                                 INPUT TRIM(STRING(par_nrctrlim, "zzz,zzz,zz9"))).
        /** Valor do Limite **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Vl.Limite de Crédito", /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
                                 INPUT "",
                                 INPUT TRIM(STRING(craplim.vllimite, "zzz,zzz,zz9.99"))).
        /** Data Alteracao do Limite **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Data de Contrataçao",  /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
                                 INPUT "",
                                 INPUT STRING(par_dtmvtolt, "99/99/9999")).
        /** Linha de crédito **/
        FIND crapldc WHERE crapldc.cdcooper = par_cdcooper     AND
                           crapldc.cddlinha = par_cddlinha AND
                           crapldc.tpdescto = 2
                           NO-LOCK NO-ERROR.
                           
        IF   NOT AVAILABLE crapldc   THEN
             aux_dsdlinha = STRING(par_cddlinha) + " - " + "NAO CADASTRADA".
        ELSE
             aux_dsdlinha = STRING(par_cddlinha) + " - " + crapldc.dsdlinha.
        //
        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                 INPUT "Linha de Crédito",  /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
                                INPUT "",
                                 INPUT STRING(aux_dsdlinha)).
        /** Prazo de Vigencia **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Prazo de Vigencia (dias)",
                                 INPUT "",
                                 INPUT STRING(craplim.qtdiavig)).
        /** Periodicidade da Capitalizaçao **/
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Periodic.da Capitalizaçao",
                                 INPUT "",
                                 INPUT STRING("MENSAL")).
        /** Custo Efetivo Total (CET) **/
        { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
        RUN STORED-PROCEDURE pc_busca_cet_limite
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_nrctrlim,
                                            OUTPUT "",  /* DSFRASE */
                                            OUTPUT 0,   /* Codigo da crítica */
                                            OUTPUT ""). /* Descriçao da crítica */
        CLOSE STORED-PROC pc_busca_cet_limite
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
        { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
        ASSIGN aux_dsfrase  = ""
               aux_cdcritic = 0
               aux_dscritic = ""
               aux_dsfrase  = pc_busca_cet_limite.pr_dsfrase 
                              WHEN pc_busca_cet_limite.pr_dsfrase <> ?
               aux_cdcritic = pc_busca_cet_limite.pr_cdcritic 
                              WHEN pc_busca_cet_limite.pr_cdcritic <> ?
               aux_dscritic = pc_busca_cet_limite.pr_dscritic
                              WHEN pc_busca_cet_limite.pr_dscritic <> ?.
        IF aux_cdcritic > 0 OR aux_dscritic <> ""  THEN
           aux_dsfrase  = "Erro ao buscar o CET".
        RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                 INPUT "Custo Efetivo Total (CET)",
                                 INPUT "",
                                 INPUT STRING(aux_dsfrase)).
      /* Fim Pj470 - SM2 */
        
    END.    
    
    RETURN "OK".
    
END PROCEDURE.

/****************************************************************************
            Buscar limite de uma conta informada por parâmetro          
*****************************************************************************/
PROCEDURE busca_limites:

    DEFINE INPUT PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE VAR             aux_habrat   AS CHAR        NO-UNDO. /* P450 - Rating */
    
    DEFINE OUTPUT PARAMETER TABLE FOR tt-limite_chq.

    EMPTY TEMP-TABLE tt-limite_chq.

    FIND FIRST crapprm WHERE crapprm.nmsistem = 'CRED' AND
                             crapprm.cdacesso = 'HABILITA_RATING_NOVO' AND
                             crapprm.cdcooper = par_cdcooper
                             NO-LOCK NO-ERROR.

    ASSIGN aux_habrat = 'N'.
    IF AVAIL crapprm THEN DO:
      ASSIGN aux_habrat = crapprm.dsvlrprm.
    END.

    FOR EACH craplim WHERE craplim.cdcooper = par_cdcooper  AND
                           craplim.nrdconta = par_nrdconta  AND
                           craplim.tpctrlim = 2             NO-LOCK:

        FIND crapprp WHERE crapprp.cdcooper = craplim.cdcooper   AND
                           crapprp.nrdconta = craplim.nrdconta   AND
                           crapprp.tpctrato = craplim.tpctrlim   AND
                           crapprp.nrctrato = craplim.nrctrlim
                           NO-LOCK NO-ERROR.

        CREATE tt-limite_chq.
        ASSIGN tt-limite_chq.dtpropos = craplim.dtpropos
               tt-limite_chq.dtinivig = craplim.dtinivig
               tt-limite_chq.nrctrlim = craplim.nrctrlim
               tt-limite_chq.vllimite = craplim.vllimite
               tt-limite_chq.qtdiavig = craplim.qtdiavig
               tt-limite_chq.cddlinha = craplim.cddlinha
               tt-limite_chq.dssitlim = (IF craplim.insitlim = 1 THEN
                                            "EM ESTUDO"
                                         ELSE 
                                         IF craplim.insitlim = 2 THEN
                                            "ATIVO"
                                         ELSE
                                         IF craplim.insitlim = 3 THEN
                                            "CANCELADO"
                                         ELSE 
                                            "DIFERENTE")
              tt-limite_chq.nrdrecid  = RECID (craplim)
              tt-limite_chq.flgenvio = IF   AVAIL  crapprp  THEN
                                            IF   crapprp.flgenvio   THEN
                                                 "SIM"
                                            ELSE
                                                 "NAO"
                                       ELSE
                                            "NAO"
              tt-limite_chq.insitlim = craplim.insitlim
              tt-limite_chq.idcobope = craplim.idcobope.
              /* ***** inicio P450  ****/
              /* Habilita novo rating */
              IF aux_habrat = 'S' AND par_cdcooper <> 3 THEN DO:
                { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

                /* Efetuar a chamada a rotina Oracle da RATI0003, para buscar os ratings das propostas */
                RUN STORED-PROCEDURE pc_retorna_inf_rating
                  aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, 
                                                       INPUT par_nrdconta,
                                                       INPUT 2,
                                                       INPUT craplim.nrctrlim, 
                                                       OUTPUT 0,           /* pr_insituacao_rating */
                                                       OUTPUT "",          /* pr_inorigem_rating */
                                                       OUTPUT "",          /* pr_inrisco_rating_autom */
                                                       OUTPUT 0,           /* pr_cdcritic */
                                                       OUTPUT "").         /* pr_dscritic */

                /* Fechar o procedimento para buscarmos o resultado */ 
                CLOSE STORED-PROC pc_retorna_inf_rating
                  aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

                { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

                ASSIGN aux_cdcritic               = 0
                        aux_dscritic               = ""
                        tt-limite_chq.inrisrat     = ""
                        tt-limite_chq.origerat     = ""
                        aux_cdcritic               = INT(pc_retorna_inf_rating.pr_cdcritic) 
                                                     WHEN pc_retorna_inf_rating.pr_cdcritic <> ?
                        aux_dscritic               = pc_retorna_inf_rating.pr_dscritic
                                                     WHEN pc_retorna_inf_rating.pr_dscritic <> ?
                        tt-limite_chq.inrisrat     = pc_retorna_inf_rating.pr_inrisco_rating_autom
                                                     WHEN pc_retorna_inf_rating.pr_inrisco_rating_autom <> ?
                        tt-limite_chq.origerat     = pc_retorna_inf_rating.pr_inorigem_rating
                                                     WHEN pc_retorna_inf_rating.pr_inrisco_rating_autom <> ?.
              END.
	      /* Habilita novo rating */
              /* ***** fim P450  ****/

    END.  /*  Fim da leitura do craplim  */
    
    RETURN "OK".

END PROCEDURE.

/****************************************************************************
        Buscar dados de um determinado limite de desconto de cheques        
****************************************************************************/
PROCEDURE busca_dados_limite:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO. 
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctrlim AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddopcao AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL     NO-UNDO.
    
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dscchq_dados_limite.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dados_dscchq.

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE NO-UNDO.
    DEFINE VARIABLE aux_cdtipdoc AS INTEGER             NO-UNDO.

    DEF VAR aux_txcetano AS DECI                        NO-UNDO.
    DEF VAR aux_txcetmes AS DECI                        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dscchq_dados_limite.
    EMPTY TEMP-TABLE tt-dados_dscchq.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Buscar dados de limite de desconto de cheque".
    
    FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                             craplim.nrdconta = par_nrdconta AND
                             craplim.tpctrlim = 2            AND
                             craplim.nrctrlim = par_nrctrlim NO-LOCK NO-ERROR.
         
    IF  NOT AVAILABLE craplim   THEN 
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Registro de limites nao encontrado.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        
        IF  par_flgerlog  THEN
        DO:
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

        END.             
        
        
        RETURN "NOK".
    END.
 
    IF  par_cddopcao = "X"  THEN        
    DO:
        IF  craplim.insitlim <> 2   THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "O contrato DEVE estar ATIVO.".
                  
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            IF  par_flgerlog  THEN
            DO:
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
                
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrctrlim",
                                        INPUT "",
                                        INPUT par_nrctrlim).

            END.             
            
            RETURN "NOK".
       END.
    END.
    ELSE
    IF  par_cddopcao = "A"  THEN
    DO:
        IF  craplim.insitlim <> 1   THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "E possivel alterar contratos somente com a situacao EM ESTUDO.".
                  
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                          
            IF  par_flgerlog  THEN
            DO:
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
                
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrctrlim",
                                        INPUT "",
                                        INPUT par_nrctrlim).

            END.             
            
            RETURN "NOK".                    
        END.
    END.
    ELSE
    IF  par_cddopcao = "E"  THEN
    DO:
        IF  craplim.insitlim <> 1   THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "O contrato DEVE estar em ESTUDO.".
                  
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                          
            IF  par_flgerlog  THEN
            DO:
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
                
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrctrlim",
                                        INPUT "",
                                        INPUT par_nrctrlim).

            END.             
            
            RETURN "NOK".
        END.
    END.

    FIND crapprp WHERE crapprp.cdcooper = par_cdcooper       AND
                       crapprp.nrdconta = craplim.nrdconta   AND
                       crapprp.nrctrato = craplim.nrctrlim   AND
                       crapprp.tpctrato = 2 
                       NO-LOCK NO-ERROR.    
                   
    IF  NOT AVAILABLE crapprp   THEN                                   
        DO:
            ASSIGN aux_cdcritic = 0.
                   aux_dscritic = "Registro de proposta de desconto de cheque nao encontrada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
            DO:
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
                
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrctrlim",
                                        INPUT "",
                                        INPUT par_nrctrlim).

            END.             
            
            RETURN "NOK".            
        END.    
    
    FIND crapldc WHERE crapldc.cdcooper = par_cdcooper       AND
                       crapldc.cddlinha = craplim.cddlinha   AND
                       crapldc.tpdescto = 2 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapldc  THEN 
        DO:
            ASSIGN aux_cdcritic = 0.
                   aux_dscritic = "Regisro de linha de desconto nao encontrada.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
            DO:
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
                
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrctrlim",
                                        INPUT "",
                                        INPUT par_nrctrlim).

            END.             
            
            RETURN "NOK".
        END.
        
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
    
    IF NOT AVAILABLE crapass  THEN
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
         DO:
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
             
             RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                     INPUT "nrctrlim",
                                     INPUT "",
                                     INPUT par_nrctrlim).

         END.             
         
         RETURN "NOK".
      END.
    
    RUN busca_parametros_dscchq (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_idorigem,
                                 INPUT crapass.inpessoa,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dados_dscchq).

    IF  RETURN-VALUE = "NOK" THEN
    DO:
        IF  par_flgerlog  THEN
        DO:
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
        
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT par_nrctrlim).
        
        
        END.

        RETURN "NOK".

    END.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND         
                       craptab.nmsistem = "CRED"        AND         
                       craptab.tptabela = "GENERI"      AND         
                       craptab.cdempres = 00            AND         
                       craptab.cdacesso = "DIGITALIZA"  AND
                       craptab.tpregist = 1 
                       NO-LOCK NO-ERROR.

    
    ASSIGN aux_cdtipdoc = INTE(ENTRY(3,craptab.dstextab,";")).


    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass THEN
        RETURN "NOK".
    
    /* Chamar rorina para calculo do cet */
    RUN calcula_cet_limites( INPUT par_cdcooper,
                             INPUT par_dtmvtolt,
                             INPUT "atenda",
                             INPUT INT(par_nrdconta),
                             INPUT INT(crapass.inpessoa),
                             INPUT 1, /* p-cdusolcr */
                             INPUT INT(crapldc.cddlinha),
                             INPUT 2, /*1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit*/
                             INPUT INT(craplim.nrctrlim),
                             INPUT (IF craplim.dtinivig <> ? THEN
                                       craplim.dtinivig
                                    ELSE par_dtmvtolt),
                             INPUT INT(craplim.qtdiavig),
                             INPUT DEC(craplim.vllimite),
                             INPUT DEC(crapldc.txmensal),
                            OUTPUT aux_txcetano, 
                            OUTPUT aux_txcetmes,
                            OUTPUT aux_dscritic ).
    
    IF  RETURN-VALUE <> "OK" THEN
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

    FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper AND
                       crapjfn.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
    
    FIND FIRST tt-dados_dscchq NO-LOCK NO-ERROR.
        

    CREATE tt-dscchq_dados_limite.  
    ASSIGN tt-dscchq_dados_limite.txdmulta = tt-dados_dscchq.pcdmulta
           tt-dscchq_dados_limite.codlinha = crapldc.cddlinha
           tt-dscchq_dados_limite.dsdlinha = crapldc.dsdlinha
           tt-dscchq_dados_limite.txjurmor = crapldc.txjurmor 
           tt-dscchq_dados_limite.dsramati = crapprp.dsramati
           tt-dscchq_dados_limite.vlmedchq = crapprp.vlmedchq
           tt-dscchq_dados_limite.vlfatura = crapprp.vlfatura
           tt-dscchq_dados_limite.vloutras = crapprp.vloutras
           tt-dscchq_dados_limite.vlsalari = crapprp.vlsalari
           tt-dscchq_dados_limite.vlsalcon = crapprp.vlsalcon
           tt-dscchq_dados_limite.dsdbens1 = SUBSTRING(crapprp.dsdebens,01,060)
           tt-dscchq_dados_limite.dsdbens2 = SUBSTRING(crapprp.dsdebens,61,120)
           tt-dscchq_dados_limite.dsobserv = crapprp.dsobserv[1]
           tt-dscchq_dados_limite.insitlim = craplim.insitlim
           tt-dscchq_dados_limite.nrctrlim = craplim.nrctrlim
           tt-dscchq_dados_limite.vllimite = craplim.vllimite
           tt-dscchq_dados_limite.qtdiavig = craplim.qtdiavig
           tt-dscchq_dados_limite.cddlinha = craplim.cddlinha
           tt-dscchq_dados_limite.dtcancel = craplim.dtcancel
           tt-dscchq_dados_limite.nrctaav1 = craplim.nrctaav1
           tt-dscchq_dados_limite.nrctaav2 = craplim.nrctaav2
           tt-dscchq_dados_limite.nrgarope = craplim.nrgarope
           tt-dscchq_dados_limite.nrinfcad = craplim.nrinfcad
           tt-dscchq_dados_limite.nrliquid = craplim.nrliquid
           tt-dscchq_dados_limite.nrpatlvr = craplim.nrpatlvr
           tt-dscchq_dados_limite.nrperger = craplim.nrperger
           tt-dscchq_dados_limite.vltotsfn = craplim.vltotsfn
           /* faturamento unico cliente - RATING do limite */
           tt-dscchq_dados_limite.perfatcl = 
                           crapjfn.perfatcl WHEN AVAILABLE crapjfn
           tt-dscchq_dados_limite.flgdigit = craplim.flgdigit
           tt-dscchq_dados_limite.cdtipdoc = aux_cdtipdoc
           tt-dscchq_dados_limite.dtinivig = craplim.dtinivig
           tt-dscchq_dados_limite.txcetano = aux_txcetano
           tt-dscchq_dados_limite.txcetmes = aux_txcetmes
           tt-dscchq_dados_limite.idcobope = craplim.idcobope.
    
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
                               
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT par_nrctrlim).    
            
        END.
    
    RETURN "OK".

END PROCEDURE.

/****************************************************************************
            Efetuar a exclusao de um limite de desconto de cheques            
****************************************************************************/
PROCEDURE efetua_exclusao_limite:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO. 
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctrlim AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL     NO-UNDO.
    
    DEFINE OUTPUT PARAM TABLE FOR tt-erro.
    
    DEFINE VARIABLE aux_contador AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_flgderro AS LOGICAL     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Efetuar exclusao de limite de desconto de " +
                              "cheque".
    
    TRANS_EXCLUSAO:
    DO TRANSACTION ON ERROR UNDO TRANS_EXCLUSAO, LEAVE TRANS_EXCLUSAO:

        DO aux_contador = 1 TO 10:
    
            FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                                     craplim.nrdconta = par_nrdconta AND
                                     craplim.tpctrlim = 2            AND
                                     craplim.nrctrlim = par_nrctrlim 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
         
            IF  NOT AVAILABLE craplim  THEN 
            DO:
                IF  LOCKED craplim  THEN
                DO:
                   aux_dscritic = "Registro de cheques sendo alterado. Tente Novamente.".
                   PAUSE 1 NO-MESSAGE.
                   NEXT.
                END.
                ELSE
                DO:            
                    ASSIGN aux_dscritic = "Registro de limites nao encontrado.".
                    LEAVE.
                END.
            END.
            
            ASSIGN aux_dscritic = "".
            LEAVE.
            
        END. /* Final do DO .. TO */    
        
        IF  aux_dscritic <> ""  THEN
        DO:
            ASSIGN aux_cdcritic = 0.
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                           
            ASSIGN aux_flgderro = TRUE. 
            
            UNDO TRANS_EXCLUSAO, LEAVE TRANS_EXCLUSAO.  
        END.
        
        IF  craplim.insitlim <> 1   THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "O contrato DEVE estar em ESTUDO.".
                      
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                              
            ASSIGN aux_flgderro = TRUE.

            UNDO TRANS_EXCLUSAO, LEAVE TRANS_EXCLUSAO.
        END.
        
        DO aux_contador = 1 TO 10:
    
            FIND crapprp WHERE crapprp.cdcooper = par_cdcooper       AND
                               crapprp.nrdconta = craplim.nrdconta   AND
                               crapprp.nrctrato = craplim.nrctrlim   AND
                               crapprp.tpctrato = 2
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                              
            IF  NOT AVAILABLE crapprp  THEN 
            DO:
                IF  LOCKED crapprp  THEN
                DO:
                   aux_dscritic = "Registro de propostas sendo alterado. Tente Novamente.".
                   PAUSE 1 NO-MESSAGE.
                   NEXT.
                END.
                ELSE
                DO:
                   aux_dscritic = "Registro de propostas nao encontrado.".
                   LEAVE.
                END.
            END.
            
            aux_dscritic = "".
            LEAVE.
        END. /* Final do DO .. TO */
    
        IF  aux_dscritic <> ""  THEN
        DO:
            ASSIGN aux_cdcritic = 0.
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                           
            aux_flgderro = TRUE.
            
            UNDO TRANS_EXCLUSAO, LEAVE TRANS_EXCLUSAO.  
        END.        

        FIND crapmcr WHERE crapmcr.cdcooper = par_cdcooper       AND
                           crapmcr.nrdconta = craplim.nrdconta   AND
                           crapmcr.nrcontra = craplim.nrctrlim   AND
                           crapmcr.tpctrmif = 2                  AND
                           crapmcr.tpctrlim = craplim.tpctrlim
                           EXCLUSIVE-LOCK NO-ERROR.
     
        IF  AVAILABLE crapmcr  THEN
            crapmcr.dtdbaixa = par_dtmvtolt.
        ELSE
        IF  craplim.dtinivig >= 09/01/2003  THEN
        DO:
            ASSIGN aux_cdcritic = 765
                   aux_dscritic = "".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                           
            ASSIGN aux_flgderro = TRUE.
            
            UNDO TRANS_EXCLUSAO, LEAVE TRANS_EXCLUSAO.
        END.
            
        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper       AND
                               crapavt.tpctrato = 2                  AND
                               crapavt.nrdconta = craplim.nrdconta   AND
                               crapavt.nrctremp = craplim.nrctrlim   
                               EXCLUSIVE-LOCK:
           DELETE crapavt.
        END.
   
        IF  craplim.nrctaav1 <> 0 THEN
        DO:
             FOR EACH crapavl WHERE 
                      crapavl.cdcooper = par_cdcooper       AND
                      crapavl.nrdconta = craplim.nrctaav1   AND
                      crapavl.nrctravd = craplim.nrctrlim   AND
                      crapavl.tpctrato = 2                  EXCLUSIVE-LOCK:
                 DELETE crapavl.
             END.
        END.
  
        IF  craplim.nrctaav2 <> 0 THEN
        DO:
             FOR EACH crapavl WHERE 
                      crapavl.cdcooper = par_cdcooper       AND
                      crapavl.nrdconta = craplim.nrctaav2   AND
                      crapavl.nrctravd = craplim.nrctrlim   AND
                      crapavl.tpctrato = 2                  EXCLUSIVE-LOCK:
                 DELETE crapavl.
             END.
        END.

        /* Desfaz a vinculaçao da garantia com a proposta */
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_vincula_cobertura_operacao
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT craplim.idcobope
                                              ,INPUT 0
                                              ,INPUT 0
                                              ,"").

        CLOSE STORED-PROC pc_vincula_cobertura_operacao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic  = ""
               aux_dscritic  = pc_vincula_cobertura_operacao.pr_dscritic
                WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.
                        
        IF aux_dscritic <> "" THEN
           DO:
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,            /** Sequencia **/
                              INPUT 0,
                              INPUT-OUTPUT aux_dscritic).

                ASSIGN aux_flgderro = TRUE.                
                UNDO TRANS_EXCLUSAO, LEAVE TRANS_EXCLUSAO.
           END.  

        DELETE craplim.
        DELETE crapprp.
           
    END. /* Final da transacao */
    
    IF  aux_flgderro  THEN
    DO:
        IF  par_flgerlog  THEN
        DO:
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

            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT par_nrctrlim).

        END.

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
                           
        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                INPUT "nrctrlim",
                                INPUT "",
                                INPUT par_nrctrlim).    
        
    END.
    
    RETURN "OK".

END PROCEDURE.

/****************************************************************************
          Efetuar o cancelamento de um limite de desconto de cheques        
****************************************************************************/
PROCEDURE efetua_cancelamento_limite:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO. 
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtopr AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_inproces AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctrlim AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL     NO-UNDO.

    DEFINE OUTPUT PARAM TABLE FOR tt-erro.
    
    DEFINE VARIABLE aux_contador AS INTEGER        NO-UNDO.
    DEFINE VARIABLE aux_flgtrans AS LOGICAL        NO-UNDO.
    DEFINE VARIABLE h-b1wgen0043 AS HANDLE         NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_flgtrans = FALSE.

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Efetuar cancelamente de limite de desconto " +
                              "de cheque".
    
    TRANS_CANCELAMENTO:
    DO TRANSACTION ON ERROR UNDO TRANS_CANCELAMENTO, LEAVE TRANS_CANCELAMENTO:
        
        DO aux_contador = 1 TO 10:
    
            ASSIGN aux_dscritic = "".

            FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                                     craplim.nrdconta = par_nrdconta AND
                                     craplim.tpctrlim = 2            AND
                                     craplim.nrctrlim = par_nrctrlim 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
         
            IF  NOT AVAILABLE craplim  THEN
                DO:
                    IF  LOCKED craplim  THEN
                        DO:
                            aux_dscritic = "Registro de limite sendo " +
                                           "alterado. Tente Novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        aux_dscritic = "Registro de limites nao encontrado.".
                END.
            
            LEAVE.
            
        END. /* Final do DO .. TO */    
    
        IF  aux_dscritic <> ""  THEN
            DO:
                ASSIGN aux_cdcritic = 0.
                
                UNDO TRANS_CANCELAMENTO, LEAVE TRANS_CANCELAMENTO.  
            END.
    
        IF  craplim.insitlim <> 2  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "O contrato DEVE estar ATIVO.".
                      
                UNDO TRANS_CANCELAMENTO, LEAVE TRANS_CANCELAMENTO.
            END.
        
        /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
        IF par_cdagenci = 0 THEN
          ASSIGN par_cdagenci = glb_cdagenci.
        /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */

        ASSIGN craplim.insitlim = 3
               craplim.dtcancel = par_dtmvtolt
               /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               craplim.cdopeexc = par_cdoperad
               craplim.cdageexc = par_cdagenci
               craplim.dtinsexc = TODAY
               /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
               craplim.cdopecan = par_cdoperad.

               
         /* Efetuar o desbloqueio de possíveis coberturas vinculadas ao mesmo */
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_bloq_desbloq_cob_operacao
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT "ATENDA"
                                              ,INPUT craplim.idcobope
                                              ,INPUT "D"
                                              ,INPUT par_cdoperad
                                              ,INPUT ""
                                              ,INPUT 0
                                              ,INPUT "S"
                                              ,"").

        CLOSE STORED-PROC pc_bloq_desbloq_cob_operacao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic  = ""
               aux_dscritic  = pc_bloq_desbloq_cob_operacao.pr_dscritic WHEN pc_obtem_mensagem_grp_econ_prg.pr_dscritic <> ?.
                        
        IF aux_dscritic <> "" THEN
           DO:
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,            /** Sequencia **/
                              INPUT 0,
                              INPUT-OUTPUT aux_dscritic).

                UNDO TRANS_CANCELAMENTO, LEAVE TRANS_CANCELAMENTO.
           END.


        RUN sistema/generico/procedures/b1wgen0043.p 
            PERSISTENT SET h-b1wgen0043.

        IF  NOT VALID-HANDLE(h-b1wgen0043)  THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Handle invalido para BO b1wgen0043.".
                          
                UNDO TRANS_CANCELAMENTO, LEAVE TRANS_CANCELAMENTO.
            END.

        RUN desativa_rating IN h-b1wgen0043 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_dtmvtolt,
                                             INPUT par_dtmvtopr,
                                             INPUT par_nrdconta,
                                             INPUT 2, /** Descto. Chq **/
                                             INPUT par_nrctrlim,
                                             INPUT TRUE,
                                             INPUT par_idseqttl,
                                             INPUT par_idorigem,
                                             INPUT par_nmdatela,
                                             INPUT par_inproces,
                                             INPUT FALSE,
                                            OUTPUT TABLE tt-erro).
                                        
        DELETE PROCEDURE h-b1wgen0043.

        IF  RETURN-VALUE = "NOK"  THEN
            UNDO TRANS_CANCELAMENTO, LEAVE TRANS_CANCELAMENTO.
          
       FIND CURRENT craplim NO-LOCK.

       RELEASE craplim.

       ASSIGN aux_flgtrans = TRUE.
           
    END. /* Final da transacao */
    
    IF  NOT aux_flgtrans  THEN
        DO:
            IF  aux_cdcritic = 0 AND aux_dscritic= ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        DO:
                            ASSIGN aux_dscritic = "Nao foi possivel cancelar " +
                                                  "o limite.".

                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,          /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                        END.
                END.
            ELSE
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,          /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
                DO:
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

                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "nrctrlim",
                                            INPUT "",
                                            INPUT par_nrctrlim).
                END.                                    

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
                               
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT par_nrctrlim).    
        END.    
    
    RETURN "OK".

END PROCEDURE.

/****************************************************************************
    Buscar dados de um limite de desconto de cheque COMPLETO - opcao "C" 
****************************************************************************/
PROCEDURE busca_dados_limite_consulta:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO. 
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctrlim AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL     NO-UNDO.
    
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dscchq_dados_limite.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dados-avais.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dados_dscchq.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dscchq_dados_limite.
    EMPTY TEMP-TABLE tt-dados-avais.
    EMPTY TEMP-TABLE tt-dados_dscchq.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Consultar dados de limite de desconto de " +
                              "cheques".
    
    DEFINE VARIABLE h-b1wgen9999 AS HANDLE NO-UNDO.

    RUN busca_dados_limite (INPUT par_cdcooper,
                            INPUT par_cdagenci, 
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_idorigem,
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,  
                            INPUT par_nmdatela,
                            INPUT par_nrctrlim,
                            INPUT "C",
                            INPUT FALSE,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-dscchq_dados_limite,
                            OUTPUT TABLE tt-dados_dscchq).
    
    IF  RETURN-VALUE = "NOK"  THEN
    DO:
        IF  par_flgerlog  THEN
        DO:
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
        
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT par_nrctrlim).
        
        
        END.

        RETURN "NOK".
    
    END.
    
    FIND FIRST tt-dscchq_dados_limite NO-LOCK NO-ERROR.
    IF  NOT AVAIL tt-dscchq_dados_limite  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Dados de limite de desconto de cheque nao encontrados.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            IF  par_flgerlog  THEN
            DO:
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

                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrctrlim",
                                        INPUT "",
                                        INPUT par_nrctrlim).


            END.
            
            RETURN "NOK".            
        END.
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
        SET h-b1wgen9999.                                     

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen9999.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            IF  par_flgerlog  THEN
            DO:
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

                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrctrlim",
                                        INPUT "",
                                        INPUT par_nrctrlim).


            END.
            
            RETURN "NOK".

        END.
        
    RUN lista_avalistas IN h-b1wgen9999 (INPUT par_cdcooper,  
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nmdatela,
                                         INPUT par_idorigem,
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT 2, /** Tipo do contrato **/
                                         INPUT par_nrctrlim,    
                                         INPUT tt-dscchq_dados_limite.nrctaav1,
                                         INPUT tt-dscchq_dados_limite.nrctaav2,
                                        OUTPUT TABLE tt-dados-avais,
                                        OUTPUT TABLE tt-erro).      
                                          
    DELETE PROCEDURE h-b1wgen9999.
    
    IF  RETURN-VALUE = "NOK"  THEN
    DO:
        IF  par_flgerlog  THEN
        DO:
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
        
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT par_nrctrlim).
        
        END.
        
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
                           
        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                INPUT "nrctrlim",
                                INPUT "",
                                INPUT par_nrctrlim).    
        
    END.    
    
    RETURN "OK".

END PROCEDURE.

/****************************************************************************
    Buscar dados de um limite de desconto de cheques COMPLETO - opcao "A" 
****************************************************************************/
PROCEDURE busca_dados_limite_altera:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO. 
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctrlim AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL     NO-UNDO.
    
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dscchq_dados_limite.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dados-avais.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-risco.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dados_dscchq.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dscchq_dados_limite.
    EMPTY TEMP-TABLE tt-dados-avais.
    EMPTY TEMP-TABLE tt-risco.
    EMPTY TEMP-TABLE tt-dados_dscchq.
    
    DEFINE VARIABLE aux_dsoperac AS CHAR        NO-UNDO.
    DEFINE VARIABLE h-b1wgen9999 AS HANDLE      NO-UNDO.
    DEFINE VARIABLE h-b1wgen0110 AS HANDLE      NO-UNDO.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Buscar dados para alterar limite de " +
                              "desconto de cheque".
    
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta 
                       NO-LOCK NO-ERROR.
                       
    IF NOT AVAIL(crapass)  THEN
       DO:
           ASSIGN aux_cdcritic = 9
                  aux_dscritic = "".

           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).

           IF par_flgerlog  THEN
              DO:
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
              
                  RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                          INPUT "nrctrlim",
                                          INPUT "",
                                          INPUT par_nrctrlim).
              
              END.
     
           RETURN "NOK".        

       END.
    
    IF NOT VALID-HANDLE(h-b1wgen0110) THEN
       RUN sistema/generico/procedures/b1wgen0110.p
           PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de alterar a proposta de limite de " + 
                          "descontos de cheques na conta "                +
                          STRING(crapass.nrdconta,"zzzz,zzz,9")           +
                          " - CPF/CNPJ "                                  +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),
                                     "xx.xxx.xxx/xxxx-xx")).

    /*Verifica se o titular em questao esta no cadastro restritivo. Se estiver,
      sera enviado um e-mail informando a situacao*/
    RUN alerta_fraude IN h-b1wgen0110
                        (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT par_cdoperad,
                         INPUT par_nmdatela,
                         INPUT par_dtmvtolt,
                         INPUT par_idorigem,
                         INPUT crapass.nrcpfcgc,
                         INPUT crapass.nrdconta, 
                         INPUT par_idseqttl,
                         INPUT TRUE, /*bloqueia operacao*/
                         INPUT 3, /*cdoperac*/
                         INPUT aux_dsoperac,
                         OUTPUT TABLE tt-erro).

    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).

    IF RETURN-VALUE <> "OK"  THEN
       DO:
           FIND FIRST tt-erro NO-LOCK NO-ERROR.

           IF NOT AVAIL tt-erro THEN
              DO:
                 ASSIGN aux_cdcritic = 0
                        aux_dscritic = "Nao foi possivel verificar o " +
                                       "cadastro restritivo.".
                        
                 RUN gera_erro (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT 1,            /** Sequencia **/
                                INPUT aux_cdcritic,
                                INPUT-OUTPUT aux_dscritic).

              END.
           ELSE
              ASSIGN aux_dscritic = tt-erro.dscritic.

           IF par_flgerlog  THEN
              DO:
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
              
                  RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                          INPUT "nrctrlim",
                                          INPUT "",
                                          INPUT par_nrctrlim).
              
              END.
     
           RETURN "NOK".

       END.


    RUN busca_dados_limite (INPUT par_cdcooper,
                            INPUT par_cdagenci, 
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_idorigem,
                            INPUT par_nrdconta,
                            INPUT par_idseqttl,  
                            INPUT par_nmdatela,
                            INPUT par_nrctrlim,
                            INPUT "A",
                            INPUT FALSE,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-dscchq_dados_limite,
                            OUTPUT TABLE tt-dados_dscchq).
    
    IF  RETURN-VALUE = "NOK"  THEN
    DO:
        IF  par_flgerlog  THEN
        DO:
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
        
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT par_nrctrlim).
        
        END.

        RETURN "NOK".
    END.
        
    
    FIND FIRST tt-dscchq_dados_limite NO-LOCK NO-ERROR.
    
    IF NOT AVAIL tt-dscchq_dados_limite  THEN
       DO:
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = "Dados de limite nao encontrados.".
                  
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
                                      
           IF par_flgerlog  THEN
              DO:
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
          
                  RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                          INPUT "nrctrlim",
                                          INPUT "",
                                          INPUT par_nrctrlim).
          
              END.
              
           RETURN "NOK".

       END.
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
        SET h-b1wgen9999.                                     

    IF NOT VALID-HANDLE(h-b1wgen9999)  THEN
       DO:
           ASSIGN aux_cdcritic = 0
                  aux_dscritic = "Handle invalido para BO b1wgen9999.".
                  
           RUN gera_erro (INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic).
           
           IF par_flgerlog  THEN
              DO:
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
              
                  RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                          INPUT "nrctrlim",
                                          INPUT "",
                                          INPUT par_nrctrlim).
              
              END.
                                      
           
           RETURN "NOK".
       
       END.
           
    RUN lista_avalistas IN h-b1wgen9999 (INPUT par_cdcooper,  
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nmdatela,
                                         INPUT par_idorigem,
                                         INPUT par_nrdconta,
                                         INPUT par_idseqttl,
                                         INPUT 2, /** Tipo do contrato **/
                                         INPUT par_nrctrlim,    
                                         INPUT tt-dscchq_dados_limite.nrctaav1,
                                         INPUT tt-dscchq_dados_limite.nrctaav2,
                                        OUTPUT TABLE tt-dados-avais,
                                        OUTPUT TABLE tt-erro).        
    
    DELETE PROCEDURE h-b1wgen9999.
    
    IF RETURN-VALUE = "NOK"  THEN
       DO:
           IF par_flgerlog  THEN
              DO:
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
              
                  RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                          INPUT "nrctrlim",
                                          INPUT "",
                                          INPUT par_nrctrlim).
              
              END.
     
           RETURN "NOK".
       END.

    RUN busca_dados_risco (INPUT par_cdcooper,
                           OUTPUT TABLE tt-risco).    
    
    IF par_flgerlog  THEN
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
                              
           RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                   INPUT "nrctrlim",
                                   INPUT "",
                                   INPUT par_nrctrlim).    
           
       END.        
    
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
   Atualizar tabela de avalistas e os dados da proposta de limite de dsc chq
*****************************************************************************/
PROCEDURE efetua_alteracao_limite:
    
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_vllimite AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsramati AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlmedchq AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlfatura AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vloutras AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlsalari AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlsalcon AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdbens1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdbens2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctrlim AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddlinha AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsobserv AS CHARACTER   NO-UNDO.    
    /** ------------------- Parametros do 1 avalista ------------------- **/
    DEFINE INPUT  PARAMETER par_nrctaav1 AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdaval1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcpfav1 AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpdocav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdocav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdcjav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cpfcjav1 AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_tdccjav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_doccjav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_ende1av1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_ende2av1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrfonav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_emailav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmcidav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdufava1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcepav1 AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrender1 AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_complen1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcxaps1 AS INTEGER     NO-UNDO.
    /** ------------------- Parametros do 2 avalista ------------------- **/
    DEFINE INPUT  PARAMETER par_nrctaav2 AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdaval2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcpfav2 AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_tpdocav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdocav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdcjav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cpfcjav2 AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_tdccjav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_doccjav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_ende1av2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_ende2av2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrfonav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_emailav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmcidav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdufava2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcepav2 AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrender2 AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_complen2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcxaps2 AS INTEGER     NO-UNDO.
    /** ----------------------------- Rating ---------------------------- **/
    DEFINE INPUT  PARAMETER par_nrgarope AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrinfcad AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrliquid AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrpatlvr AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vltotsfn AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_perfatcl AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrperger AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idcobope AS INTEGER     NO-UNDO.
    
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    
    DEFINE VARIABLE h-b1wgen0021 AS HANDLE  NO-UNDO.
    DEFINE VARIABLE h-b1wgen9999 AS HANDLE  NO-UNDO.
    DEFINE VARIABLE aux_contador AS INTEGER    NO-UNDO.
    DEFINE VARIABLE aux_flgderro AS LOGICAL    NO-UNDO.
    DEFINE VARIABLE aux_dsdlinha_old AS CHARACTER NO-UNDO. /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
    DEFINE VARIABLE aux_dsdlinha     AS CHARACTER NO-UNDO. /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
    DEFINE VARIABLE aux_dsfrase      AS CHARACTER NO-UNDO. /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
    
    DEFINE VARIABLE var_vllimite AS DECIMAL      NO-UNDO.
    DEFINE VARIABLE var_dsramati AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE var_vlmedchq AS DECIMAL      NO-UNDO.
    DEFINE VARIABLE var_vlfatura AS DECIMAL      NO-UNDO.
    DEFINE VARIABLE var_vloutras AS DECIMAL      NO-UNDO.
    DEFINE VARIABLE var_vlsalari AS DECIMAL      NO-UNDO.
    DEFINE VARIABLE var_vlsalcon AS DECIMAL      NO-UNDO.
    DEFINE VARIABLE var_dsdbens1 AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE var_dsdbens2 AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE var_nrctrlim AS INTEGER      NO-UNDO.
    DEFINE VARIABLE var_cddlinha AS INTEGER      NO-UNDO.
    DEFINE VARIABLE var_dsobserv AS CHARACTER    NO-UNDO.    
    /** ------------------- Parametros do 1 avalista ------------------- **/
    DEFINE VARIABLE var_nrctaav1 AS INTEGER      NO-UNDO.
    DEFINE VARIABLE var_nmdaval1 AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE var_dsdocav1 AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE var_nmdcjav1 AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE var_doccjav1 AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE var_ende1av1 AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE var_ende2av1 AS CHARACTER    NO-UNDO.
    /** ------------------- Parametros do 2 avalista ------------------- **/
    DEFINE VARIABLE var_nrctaav2 AS INTEGER      NO-UNDO.
    DEFINE VARIABLE var_nmdaval2 AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE var_dsdocav2 AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE var_nmdcjav2 AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE var_doccjav2 AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE var_ende1av2 AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE var_ende2av2 AS CHARACTER    NO-UNDO.
    /**----------- OLD - RATING -----------**/    
    DEFINE VARIABLE var_nrgarope LIKE craplim.nrgarope.
    DEFINE VARIABLE var_nrinfcad LIKE craplim.nrinfcad.
    DEFINE VARIABLE var_nrliquid LIKE craplim.nrliquid.
    DEFINE VARIABLE var_nrpatlvr LIKE craplim.nrpatlvr.
    DEFINE VARIABLE var_nrperger LIKE craplim.nrperger.
    DEFINE VARIABLE var_vltotsfn LIKE craplim.vltotsfn.
    DEFINE VARIABLE var_perfatcl LIKE crapjfn.perfatcl.
    
    DEFINE VARIABLE aux_habrat   AS CHAR         NO-UNDO. /* P450 - Rating */ 
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Efetuar alteracao de limite de desconto de " +
                              "cheque".
    
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
      

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Handle invalido para h-b1wgen9999.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        
        IF  par_flgerlog  THEN
        DO:
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
        
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT par_nrctrlim).
        
        END.

        RETURN "NOK".
    END.

    TRANS_ALTERA:    
    DO  TRANSACTION ON ERROR UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA:
    
        RUN atualiza_tabela_avalistas IN h-b1wgen9999 
                                 (INPUT par_cdcooper,
                                  INPUT par_cdoperad,
                                  INPUT par_idorigem,
                                  INPUT "DESC.CHEQUE",
                                  INPUT par_nrdconta, 
                                  INPUT par_dtmvtolt, 
                                  INPUT 2, /*tpctrato*/
                                  INPUT par_nrctrlim,
                                  INPUT par_cdagenci,
                                  INPUT par_nrdcaixa,
                                  /** 1 avalista **/
                                  INPUT par_nrctaav1, 
                                  INPUT par_nmdaval1, 
                                  INPUT par_nrcpfav1, 
                                  INPUT par_tpdocav1, 
                                  INPUT par_dsdocav1,
                                  INPUT par_nmdcjav1,
                                  INPUT par_cpfcjav1,
                                  INPUT par_tdccjav1, 
                                  INPUT par_doccjav1, 
                                  INPUT par_ende1av1, 
                                  INPUT par_ende2av1, 
                                  INPUT par_nrfonav1, 
                                  INPUT par_emailav1, 
                                  INPUT par_nmcidav1, 
                                  INPUT par_cdufava1, 
                                  INPUT par_nrcepav1, 
                                  INPUT 0, /* nacionalidade*/
                                  INPUT 0, /* endividamento */
                                  INPUT 0, /* renda mensal */
                                  INPUT par_nrender1,
                                  INPUT par_complen1,
                                  INPUT par_nrcxaps1,
                                  INPUT 0, /* inpessoa 1o aval */
                                  INPUT ?, /* dtnascto 1o aval */
                                  INPUT 0, /* par_vlrecjg1 */

                                  /** 2 avalista **/
                                  INPUT par_nrctaav2, 
                                  INPUT par_nmdaval2, 
                                  INPUT par_nrcpfav2, 
                                  INPUT par_tpdocav2, 
                                  INPUT par_dsdocav2, 
                                  INPUT par_nmdcjav2, 
                                  INPUT par_cpfcjav2, 
                                  INPUT par_tdccjav2, 
                                  INPUT par_doccjav2, 
                                  INPUT par_ende1av2, 
                                  INPUT par_ende2av2, 
                                  INPUT par_nrfonav2, 
                                  INPUT par_emailav2, 
                                  INPUT par_nmcidav2, 
                                  INPUT par_cdufava2, 
                                  INPUT par_nrcepav2,
                                  INPUT 0,  /* nacionalidade */
                                  INPUT 0,  /* Endividamento */
                                  INPUT 0,
                                  INPUT par_nrender2,
                                  INPUT par_complen2,
                                  INPUT par_nrcxaps2,
                                  INPUT 0, /* inpessoa 2o aval */
                                  INPUT ?, /* dtnascto 2o aval */
                                  INPUT 0, /* par_vlrecjg2 */
                                  INPUT ""). /* Renda mensal */
                        
        DELETE PROCEDURE h-b1wgen9999.
        
        DO  aux_contador = 1 TO 10:
            
            FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper AND
                                     craplim.nrdconta = par_nrdconta AND
                                     craplim.tpctrlim = 2            AND
                                     craplim.nrctrlim = par_nrctrlim 
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
         
            IF  NOT AVAILABLE craplim   THEN 
            DO:
                IF  LOCKED craplim   THEN
                DO:
                   aux_dscritic = "Registro de limite sendo alterado. Tente Novamente.".
                   PAUSE 1 NO-MESSAGE.
                   NEXT.
                END.
                ELSE
                DO:            
                    ASSIGN aux_dscritic = "Registro de limites nao encontrado.".
                    LEAVE.
                END.
            END.
            
            ASSIGN aux_dscritic = "".
            LEAVE.

        END. /* Final do DO .. TO */    
    
        IF  aux_dscritic <> ""  THEN
        DO:
            ASSIGN aux_cdcritic = 0.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            aux_flgderro = TRUE.
            
            UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA.  
        END.

        RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT
            SET h-b1wgen0021.

        IF  VALID-HANDLE(h-b1wgen0021)  THEN
        DO:
            RUN obtem-saldo-cotas IN h-b1wgen0021 
                                          (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT par_nrdconta,
                                           INPUT par_idseqttl,
                                           OUTPUT TABLE tt-saldo-cotas,
                                           OUTPUT TABLE tt-erro). 
    
            DELETE PROCEDURE h-b1wgen0021.

            IF  RETURN-VALUE = "NOK"  THEN
            DO:
                aux_flgderro = TRUE.
                
                UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA.
            END.
        END.
        ELSE
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para h-b1wgen0021.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            aux_flgderro = TRUE.
            
            UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA.
        END.

        FIND FIRST tt-saldo-cotas NO-LOCK NO-ERROR.
        IF  NOT AVAIL tt-saldo-cotas THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de cotas nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            aux_flgderro = TRUE.
            
            UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA.                
        END.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
    
        IF   crapass.inpessoa <> 1   THEN
             DO:
                DO aux_contador = 1 TO 10:
    
                   FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper  AND
                                      crapjfn.nrdconta = par_nrdconta  
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                   IF   NOT AVAILABLE crapjfn   THEN
                        IF  LOCKED crapjfn   THEN
                            DO:
                               ASSIGN aux_cdcritic = 72.
                               PAUSE 1 NO-MESSAGE.
                               NEXT.
                            END.
                        ELSE
                            DO:
                               CREATE crapjfn.
                               ASSIGN crapjfn.cdcooper = par_cdcooper
                                      crapjfn.nrdconta = par_nrdconta.
                            END.

                   ASSIGN var_perfatcl     = crapjfn.perfatcl
                          crapjfn.perfatcl = par_perfatcl
                          aux_cdcritic     = 0 .
                   VALIDATE crapjfn.

                   LEAVE.

                END. /* Fim do DO TO */

                IF   aux_cdcritic > 0   THEN
                     DO:
                         ASSIGN aux_dscritic = "".
                    
                         RUN gera_erro (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1, /** Sequencia **/
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).
                                        
                         ASSIGN aux_flgderro = TRUE.
                         
                         UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA.
                     END.
                  
             END. 
    
        ASSIGN var_vllimite = craplim.vllimite
               var_nrctrlim = craplim.nrctrlim
               var_cddlinha = craplim.cddlinha
               craplim.dtpropos = par_dtmvtolt
               craplim.insitlim = 1
               craplim.cddlinha = par_cddlinha
               craplim.cdoperad = par_cdoperad
               craplim.cdmotcan = 0
               craplim.vllimite = par_vllimite
               craplim.inbaslim = IF  par_vllimite > 
                                      tt-saldo-cotas.vlsldcap  THEN 2
                                  ELSE 1
               craplim.flgimpnp = TRUE
               var_nrgarope = craplim.nrgarope
               var_nrinfcad = craplim.nrinfcad
               var_nrliquid = craplim.nrliquid
               var_nrpatlvr = craplim.nrpatlvr
               var_nrperger = craplim.nrperger
               var_vltotsfn = craplim.vltotsfn
               craplim.nrgarope = par_nrgarope
               craplim.nrinfcad = par_nrinfcad
               craplim.nrliquid = par_nrliquid
               craplim.nrpatlvr = par_nrpatlvr
               craplim.nrperger = par_nrperger
               craplim.vltotsfn = par_vltotsfn
               var_nrctaav1 = craplim.nrctaav1
               var_nmdaval1 = craplim.nmdaval1 
               var_dsdocav1 = craplim.dscpfav1
               var_nmdcjav1 = craplim.nmcjgav1
               var_doccjav1 = craplim.dscfcav1
               var_ende1av1 = craplim.dsendav1[1]
               var_ende2av1 = craplim.dsendav1[2]
               var_nrctaav2 = craplim.nrctaav2
               var_nmdaval2 = craplim.nmdaval2 
               var_dsdocav2 = craplim.dscpfav2
               var_nmdcjav2 = craplim.nmcjgav2
               var_doccjav2 = craplim.dscfcav1
               var_ende1av2 = craplim.dsendav2[1]
               var_ende2av2 = craplim.dsendav2[2]
               craplim.nrctaav1 = par_nrctaav1
               craplim.nrctaav2 = par_nrctaav2
               craplim.dsendav1[1] = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE 
                                         CAPS(par_ende1av1) + " " +
                                         STRING(par_nrender1)
               craplim.dsendav1[2] = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende2av1) + " - " + 
                                         CAPS(par_nmcidav1) + " - " +
                                         STRING(par_nrcepav1,"99999,999") +
                                         " - " + CAPS(par_cdufava1)
               craplim.dsendav2[1] = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende1av2) + " " +
                                         STRING(par_nrender2)
               craplim.dsendav2[2] = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         CAPS(par_ende2av2) + " - " + 
                                         CAPS(par_nmcidav2) + " - " +
                                         STRING(par_nrcepav2,"99999,999") +
                                         " - " + CAPS(par_cdufava2)
               craplim.nmdaval1    = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         par_nmdaval1
               craplim.nmdaval2    = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE    
                                         par_nmdaval2
               craplim.dscpfav1    = IF  par_nrctaav1 <> 0  THEN
                                         ""
                                     ELSE
                                         par_dsdocav1
               craplim.dscpfav2    = IF  par_nrctaav2 <> 0  THEN
                                         ""
                                     ELSE
                                         par_dsdocav2
               craplim.nmcjgav1    = par_nmdcjav1
               craplim.nmcjgav2    = par_nmdcjav2
               craplim.dscfcav1    = par_doccjav1
               craplim.dscfcav2    = par_doccjav2
               craplim.idcobope    = par_idcobope
               craplim.idcobefe    = par_idcobope.

        DO aux_contador = 1 TO 10:
        
            FIND FIRST crapprp WHERE crapprp.cdcooper = par_cdcooper     AND
                                     crapprp.nrdconta = par_nrdconta     AND
                                     crapprp.tpctrato = 2                AND
                                     crapprp.nrctrato = craplim.nrctrlim
                                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAILABLE crapprp  THEN
                DO:
                    IF  LOCKED crapprp  THEN
                        DO:
                            aux_dscritic = "Registro de proposta esta sendo alterado. Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            aux_dscritic = "Registro de proposta nao encontrado.".
                            LEAVE.               
                        END.
                END.

            aux_dscritic = "".
            LEAVE.
            
        END. /** Fim do DO ... TO **/ 
                   
        IF  aux_dscritic <> ""  THEN    
            DO:
                ASSIGN aux_cdcritic = 0.
                
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                       
                aux_flgderro = TRUE.

                UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA.
            END.        
        
        ASSIGN var_dsramati = crapprp.dsramati
               var_vlmedchq = crapprp.vlmedchq
               var_vlfatura = crapprp.vlfatura
               var_vloutras = crapprp.vloutras
               var_vlsalari = crapprp.vlsalari
               var_vlsalcon = crapprp.vlsalcon
               var_dsdbens1 = SUBSTRING(crapprp.dsdebens,1,60)
               var_dsdbens2 = SUBSTRING(crapprp.dsdebens,61,60)
               var_dsobserv = crapprp.dsobserv[1]   
               crapprp.dsramati = CAPS(par_dsramati)
               crapprp.vlmedchq = par_vlmedchq
               crapprp.vlfatura = par_vlfatura
               crapprp.vloutras = par_vloutras
               crapprp.vlsalari = par_vlsalari
               crapprp.vlsalcon = par_vlsalcon
               crapprp.dsdebens = STRING(par_dsdbens1,"x(60)") +
                                  STRING(par_dsdbens2,"x(60)")
               crapprp.dsobserv[1] = CAPS(par_dsobserv)
               crapprp.dsobserv[2] = ""
               crapprp.dsobserv[3] = "".
        

        /* Verificar se a conta pertence ao grupo economico novo */        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_vincula_cobertura_operacao
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT 0
                                              ,INPUT par_idcobope
                                              ,INPUT craplim.nrctrlim
                                              ,"").

        CLOSE STORED-PROC pc_vincula_cobertura_operacao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic  = ""
               aux_dscritic  = pc_vincula_cobertura_operacao.pr_dscritic 
               WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.
                        
        IF aux_dscritic <> "" THEN
           DO:
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,            /** Sequencia **/
                              INPUT 0,
                              INPUT-OUTPUT aux_dscritic).

                ASSIGN aux_flgderro = TRUE.                
                UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA.
           END.  
        
        FIND CURRENT craplim NO-LOCK.
        RELEASE craplim.
        FIND CURRENT crapprp NO-LOCK.
        RELEASE crapprp.

        IF  AVAILABLE crapjfn  THEN
            DO:
                FIND CURRENT crapjfn NO-LOCK NO-ERROR.
                RELEASE crapjfn.
            END.

        FIND FIRST crapprm WHERE crapprm.nmsistem = 'CRED' AND
                                 crapprm.cdacesso = 'HABILITA_RATING_NOVO' AND
                                 crapprm.cdcooper = par_cdcooper
                                 NO-LOCK NO-ERROR.
       
        ASSIGN aux_habrat = 'N'.
        IF AVAIL crapprm THEN DO:
          ASSIGN aux_habrat = crapprm.dsvlrprm.
        END.
       
        /* Habilita novo rating */
        IF aux_habrat = 'S' AND par_cdcooper <> 3 THEN DO:
       
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
            
          /* Efetuar a chamada da rotina Oracle, para limpar as informacoes do rating -P450 Rating */
          RUN STORED-PROCEDURE pc_grava_rating_operacao
            aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT par_cdcooper
                              ,INPUT par_nrdconta
                              ,INPUT 2            /* Tipo Contrato */
                              ,INPUT par_nrctrlim
                              ,INPUT ?
                              ,INPUT ?             /* null para pr_ntrataut */
                              ,INPUT par_dtmvtolt  /* pr_dtrating */
                              ,INPUT 0             /* pr_strating => 0 -- Nao Enviado */
                              ,INPUT 0             /* pr_orrating =>  */
                              ,INPUT par_cdoperad
                              ,INPUT ?             /* null para pr_dtrataut */
                              ,INPUT ?             /* null pr_innivel_rating */
                              ,INPUT ?
                              ,INPUT ?             /* pr_inpontos_rating     */
                              ,INPUT ?             /* pr_insegmento_rating   */
                              ,INPUT ?             /* pr_inrisco_rat_inc     */
                              ,INPUT ?             /* pr_innivel_rat_inc     */
                              ,INPUT ?             /* pr_inpontos_rat_inc    */
                              ,INPUT ?             /* pr_insegmento_rat_inc  */
                              ,INPUT ?             /* pr_efetivacao_rating   */
                              ,INPUT par_cdoperad  /* pr_cdoperad*/
                              ,INPUT par_dtmvtolt
                              ,INPUT par_vllimite
                              ,INPUT ? /*sugerido*/
                              ,INPUT "" /*Justif*/
                              ,INPUT ?
                              ,OUTPUT 0            /* pr_cdcritic */
                              ,OUTPUT "").         /* pr_dscritic */

              /* Fechar o procedimento para buscarmos o resultado */ 
              CLOSE STORED-PROC pc_grava_rating_operacao
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

              ASSIGN aux_cdcritic  = 0
                     aux_dscritic  = ""
                     aux_cdcritic = pc_grava_rating_operacao.pr_cdcritic
                                       WHEN pc_grava_rating_operacao.pr_cdcritic <> ?
                     aux_dscritic = pc_grava_rating_operacao.pr_dscritic
                                       WHEN pc_grava_rating_operacao.pr_dscritic <> ?.
              IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                DO:
                  ASSIGN aux_flgderro = TRUE.                
                  UNDO TRANS_ALTERA, LEAVE TRANS_ALTERA.
                END.
        END.
	/* Habilita novo rating */
           
    END. /* Final da transacao */

    IF  aux_flgderro  THEN
    DO:
        IF  par_flgerlog  THEN
        DO:
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

            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT par_nrctrlim).

        END.

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
                           
        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                INPUT "Contrato", /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
                                INPUT "",
                                INPUT par_nrctrlim).    
        
        
        IF  var_vllimite <> par_vllimite  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "Vl.Limite de Crédito", /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
                                    INPUT TRIM(STRING(var_vllimite, "zzz,zzz,zz9.99")),
                                    INPUT TRIM(STRING(par_vllimite, "zzz,zzz,zz9.99"))).    
        END.
        
        IF  var_dsramati <> par_dsramati  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "dsramati",
                                    INPUT var_dsramati,
                                    INPUT par_dsramati).    
        END.
        
        IF  var_vlmedchq <> par_vlmedchq  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "vlmedchq",
                                    INPUT TRIM(STRING(var_vlmedchq, "zzz,zzz,zz9.99")),
                                    INPUT TRIM(STRING(par_vlmedchq, "zzz,zzz,zz9.99"))).    
        END.


        IF  var_vlfatura <> par_vlfatura  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "vlfatura",
                                    INPUT TRIM(STRING(var_vlfatura, "zzz,zzz,zz9.99")),
                                    INPUT TRIM(STRING(par_vlfatura, "zzz,zzz,zz9.99"))).    
        END.
        
        IF  var_vloutras <> par_vloutras  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "vloutras",
                                    INPUT TRIM(STRING(var_vloutras, "zzz,zzz,zz9.99")),
                                    INPUT TRIM(STRING(par_vloutras, "zzz,zzz,zz9.99"))).    
        END.

        IF  var_vlsalari <> par_vlsalari  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "vlsalari",
                                    INPUT TRIM(STRING(var_vlsalari, "zzz,zzz,zz9.99")),
                                    INPUT TRIM(STRING(par_vlsalari, "zzz,zzz,zz9.99"))).    
        END.
        
        IF  var_vlsalcon <> par_vlsalcon  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "vlsalcon",
                                    INPUT TRIM(STRING(var_vlsalcon, "zzz,zzz,zz9.99")),
                                    INPUT TRIM(STRING(par_vlsalcon, "zzz,zzz,zz9.99"))).    
        END.
        
        IF  var_dsdbens1 <> par_dsdbens1  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "dsdbens1",
                                    INPUT var_dsdbens1,
                                    INPUT par_dsdbens1).    
        END.
        
        IF  var_dsdbens2 <> par_dsdbens2  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "dsdbens2",
                                    INPUT var_dsdbens2,
                                    INPUT par_dsdbens2).    
        END.
        
        IF  var_nrctrlim <> par_nrctrlim  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "Contrato", /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
                                    INPUT var_nrctrlim,
                                    INPUT par_nrctrlim).    
        END.
        
        IF  var_cddlinha <> par_cddlinha  THEN
        DO:
          /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
          FIND crapldc WHERE crapldc.cdcooper = par_cdcooper     AND
                             crapldc.cddlinha = var_cddlinha AND
                             crapldc.tpdescto = 2
                             NO-LOCK NO-ERROR.

          IF   NOT AVAILABLE crapldc   THEN
               aux_dsdlinha_old = STRING(var_cddlinha) + " - " + "NAO CADASTRADA".
          ELSE
               aux_dsdlinha_old = STRING(var_cddlinha) + " - " + crapldc.dsdlinha.
          //
          FIND crapldc WHERE crapldc.cdcooper = par_cdcooper     AND
                             crapldc.cddlinha = par_cddlinha AND
                             crapldc.tpdescto = 2
                             NO-LOCK NO-ERROR.

          IF   NOT AVAILABLE crapldc   THEN
               aux_dsdlinha = STRING(par_cddlinha) + " - " + "NAO CADASTRADA".
          ELSE
               aux_dsdlinha = STRING(par_cddlinha) + " - " + crapldc.dsdlinha.
          /* Fim Pj470 - SM2 */
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "Linha de Crédito",
                                    INPUT aux_dsdlinha_old,
                                    INPUT aux_dsdlinha).    
        END.
        
        IF  var_dsobserv <> par_dsobserv  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "dsobserv",
                                    INPUT var_dsobserv,
                                    INPUT par_dsobserv).    
        END.
        
        IF  var_nrctaav1 <> par_nrctaav1  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctaav1",
                                    INPUT var_nrctaav1,
                                    INPUT par_nrctaav1).    
        END.
        
        IF  var_nmdaval1 <> par_nmdaval1  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nmdaval1",
                                    INPUT var_nmdaval1,
                                    INPUT par_nmdaval1).    
        END.
        
        IF  var_dsdocav1 <> par_dsdocav1  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "dsdocav1",
                                    INPUT var_dsdocav1,
                                    INPUT par_dsdocav1).    
        END.
        
        IF  var_nmdcjav1 <> par_nmdcjav1  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nmdcjav1",
                                    INPUT var_nmdcjav1,
                                    INPUT par_nmdcjav1).    
        END.
        
        IF  var_doccjav1 <> par_doccjav1  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "doccjav1",
                                    INPUT var_doccjav1,
                                    INPUT par_doccjav1).    
        END.
        
        IF  var_ende1av1 <> par_ende1av1
        AND (var_ende1av1 <> " 0" OR par_ende1av1 <> " ") /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
        THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "ende1av1",
                                    INPUT var_ende1av1,
                                    INPUT par_ende1av1).    
        END.
        
        IF  var_ende2av1 <> par_ende2av1
        AND (var_ende2av1 <> " -  - 00000.000 - " OR par_ende2av1 <> " ") /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
        THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "ende2av1",
                                    INPUT var_ende2av1,
                                    INPUT par_ende2av1).    
        END.
        
        IF  var_nrctaav2 <> par_nrctaav2  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctaav2",
                                    INPUT var_nrctaav2,
                                    INPUT par_nrctaav2).    
        END.
        
        IF  var_nmdaval2 <> par_nmdaval2  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nmdaval2",
                                    INPUT var_nmdaval2,
                                    INPUT par_nmdaval2).
        END.
        
        IF  var_dsdocav2 <> par_dsdocav2  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "dsdocav2",
                                    INPUT var_dsdocav2,
                                    INPUT par_dsdocav2).    
        END.
        
        IF  var_nmdcjav2 <> par_nmdcjav2  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nmdcjav2",
                                    INPUT var_nmdcjav2,
                                    INPUT par_nmdcjav2).    
        END.
        
        IF  var_doccjav2 <> par_doccjav2  THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "doccjav2",
                                    INPUT var_doccjav2,
                                    INPUT par_doccjav2).    
        END.
        
        IF  var_ende1av2 <> par_ende1av2
        AND (var_ende1av2 <> " 0" OR par_ende1av2 <> " ") /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
        THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "ende1av2",
                                    INPUT var_ende1av2,
                                    INPUT par_ende1av2).    
        END.
        
        IF  var_ende2av2 <> par_ende2av2
        AND (var_ende2av2 <> " -  - 00000.000 - " OR par_ende2av2 <> " ") /* Pj470 - SM2 -- MArcelo Telles Coelho -- Mouts */
        THEN
        DO:
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "ende2av2",
                                    INPUT var_ende2av2,
                                    INPUT par_ende2av2).    

        END.

        IF   var_nrinfcad <> par_nrinfcad   THEN
             RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                     INPUT "informacoes cadastrais",
                                     INPUT var_nrinfcad,
                                     INPUT par_nrinfcad).
                 
        IF   var_nrliquid <> par_nrliquid   THEN
             RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                     INPUT "liquidez das garantias",
                                     INPUT var_nrliquid,
                                     INPUT par_nrliquid).
           
        IF   var_nrpatlvr <> par_nrpatlvr   THEN
             RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                     INPUT "patrimonio pessoal livre",
                                     INPUT var_nrpatlvr,
                                     INPUT par_nrpatlvr).
                          
        IF   var_nrperger <> par_nrperger   THEN
             RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                     INPUT "percepcao geral (empresa)",
                                     INPUT var_nrperger,
                                     INPUT par_nrperger).
        
        IF   var_vltotsfn <> par_vltotsfn   THEN
             RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                     INPUT "valor total SFN",
                                     INPUT var_vltotsfn,
                                     INPUT par_vltotsfn).   
        
        IF   var_nrgarope <> par_nrgarope   THEN
             RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                     INPUT "garantia",
                                     INPUT var_nrgarope,
                                     INPUT par_nrgarope).
        
        IF   var_perfatcl <> par_perfatcl   THEN
             RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                     INPUT "percentual faturamento",
                                     INPUT var_perfatcl,
                                     INPUT par_perfatcl).
    END.

    RETURN "OK".
   
END PROCEDURE.


/******************************************************************************/
/**           Procedure para gerar impressoes do limite de credito           **/
/******************************************************************************/
PROCEDURE gera-impressao-limite:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagecxa AS INTE  /** PA Operador   **/   NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE  /** Nr. Caixa      **/   NO-UNDO.
    DEF  INPUT PARAM par_cdopecxa AS CHAR  /** Operador Caixa **/   NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idimpres AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_flgemail AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR rel_nrdconta AS INT                                     NO-UNDO.
    DEF VAR rel_nmdavali AS CHAR                                    NO-UNDO.
    DEF VAR rel_nmconjug AS CHAR                                    NO-UNDO.
    DEF VAR rel_nrdocava AS CHAR                                    NO-UNDO.
    DEF VAR rel_nrdoccjg AS CHAR                                    NO-UNDO.
    DEF VAR rel_dsendre1 AS CHAR                                    NO-UNDO.
    DEF VAR rel_dsendre2 AS CHAR                                    NO-UNDO.

    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqimp AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqpdf AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmdoarqv AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfcgc AS CHAR                                    NO-UNDO.

    DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0043 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen0138 AS HANDLE                                  NO-UNDO.
    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    DEF VAR aux_nrdgrupo AS INTE                                    NO-UNDO.
    DEF VAR aux_tpdocged AS INTE                                    NO-UNDO.
    DEF VAR aux_gergrupo AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdrisgp AS CHAR                                    NO-UNDO.
    DEF VAR aux_pertengp AS LOG                                     NO-UNDO.
    DEF VAR aux_dsdrisco AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlendivi AS DEC                                     NO-UNDO.
    DEF VAR aux_dscetan1 AS CHAR FORMAT "x(80)"                     NO-UNDO.
    DEF VAR aux_dscetan2 AS CHAR FORMAT "x(80)"                     NO-UNDO.
    DEF VAR aux_habrat   AS CHAR                                    NO-UNDO. /* P450 - Rating */

    FIND FIRST crapprm WHERE crapprm.nmsistem = 'CRED' AND
                             crapprm.cdacesso = 'HABILITA_RATING_NOVO' AND
                             crapprm.cdcooper = par_cdcooper
                             NO-LOCK NO-ERROR.

    ASSIGN aux_habrat = 'N'.
    IF AVAIL crapprm THEN DO:
      ASSIGN aux_habrat = crapprm.dsvlrprm.
    END.

    /** FORM's para Proposta de Limite de Descontos de Cheques **/
    FORM tt-proposta_limite_chq.nmextcop FORMAT "x(50)"
         SKIP(1)
         "\033\016 PROPOSTA DE LIMITE DE DESCONTO DE CHEQUES \024"
         "PARA USO DA DIGITALIZACAO" AT 62
         SKIP(1)
         rel_nrdconta                    FORMAT "zzzz,zzz,9" AT 65
         tt-proposta_limite_chq.nrctrlim FORMAT "z,zzz,zz9"  AT 78
         aux_tpdocged                    FORMAT "zz9"        AT 90
         SKIP(1)
         "\033\105\ DADOS DO ASSOCIADO \033\106"
         SKIP(1)
         "Conta/dv: \033\016" tt-proposta_limite_chq.nrdconta FORMAT "zzzz,zzz,9" "\024"
         "Matricula:"  AT 34 tt-proposta_limite_chq.nrmatric FORMAT "zzz,zz9"
         "PA:"       AT 60 tt-proposta_limite_chq.dsagenci FORMAT "x(25)" 
         SKIP(1)
         "Nome    :"         tt-proposta_limite_chq.nmprimtl FORMAT "x(50)"
         "Adm COOP:"   AT 76 tt-proposta_limite_chq.dtadmiss FORMAT "99/99/9999"
         SKIP
         "CPF/CNPJ:"         tt-proposta_limite_chq.nrcpfcgc FORMAT "x(18)" 
         SKIP(1)
         "Empresa :"         tt-proposta_limite_chq.nmempres FORMAT "x(35)"
         "Adm empr:"   AT 76 tt-proposta_limite_chq.dtadmemp FORMAT "99/99/9999"
         SKIP(1)
         "Fone/Ramal:" AT 42 tt-proposta_limite_chq.telefone FORMAT "X(30)"    
         SKIP(1)
         "Tipo de Conta:"    tt-proposta_limite_chq.dstipcta FORMAT "x(25)"
         "Situacao da Conta:" AT 67 tt-proposta_limite_chq.dssitdct FORMAT "x(10)"
         SKIP(1)
         "Ramo de Atividade:" tt-proposta_limite_chq.dsramati FORMAT "x(40)"
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_pro_dados.

    FORM "\033\105 RECIPROCIDADE \033\106"
         "Saldo Medio do Trimestre:" AT 20 tt-proposta_limite_chq.vlsmdtri FORMAT "zzz,zzz,zz9.99"
         "Capital:"                  AT 77 tt-proposta_limite_chq.vlcaptal FORMAT "zzz,zzz,zz9.99-"
         SKIP(1)
         "Plano:"                          tt-proposta_limite_chq.vlprepla FORMAT "zzz,zzz,zz9.99"
         "Aplicacoes:"               AT 70 tt-proposta_limite_chq.vlaplica FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "\033\105 RENDA MENSAL \033\106"
         "Salario:"                  AT 31 tt-proposta_limite_chq.vlsalari FORMAT "zzz,zzz,zz9.99"
         "Salario do Conjuge:"       AT 66 tt-proposta_limite_chq.vlsalcon FORMAT "zzz,zzz,zz9.99" 
         SKIP
         "Faturamento Mensal:"       AT 16 tt-proposta_limite_chq.vlfatura FORMAT "zzz,zzz,zz9.99"
         "Outras:"                   AT 74 tt-proposta_limite_chq.vloutras FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "\033\105 LIMITES \033\106"
         "Cheque Especial:"          AT 16 tt-proposta_limite_chq.vllimcre FORMAT "zzz,zzz,zz9.99"
         "Cartoes de Credito:"       AT 66 tt-proposta_limite_chq.vltotccr FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "\033\105 BENS:\033\106"
         tt-proposta_limite_chq.dsdeben1 AT 13 FORMAT "x(60)"  SKIP
         tt-proposta_limite_chq.dsdeben2 AT 09 FORMAT "x(60)"
         SKIP(1)
         "\033\105 LIMITE PROPOSTO \033\106"
         SKIP
         "    Contrato           Valor   Linha de desconto"
         "Valor Medio do Cheque" AT 66
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 130 FRAME f_pro_rec.

    FORM tt-proposta_limite_chq.nrctrlim FORMAT "z,zzz,zz9" AT 4
         tt-proposta_limite_chq.vllimpro FORMAT "zzzz,zzz,zz9.99" " "
         tt-proposta_limite_chq.dsdlinha FORMAT "x(40)"   
         tt-proposta_limite_chq.vlmedchq FORMAT "zzz,zzz,zz9.99" 
         WITH NO-BOX NO-LABELS WIDTH 130 DOWN FRAME f_lim_pro.

    FORM SKIP(2)
         "\033\105 ENDIVIDAMENTO NA COOPERATIVA DE CREDITO EM"
         tt-proposta_limite_chq.dtcalcul FORMAT "99/99/9999" "\033\106"     
         SKIP(1)
         " Contrato  Saldo Devedor"
         "Prestacoes"       AT 39
         "Linha de Credito" AT 50
         "Finalidade"       AT 80
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_pro_ed1.
                                                                      
    FORM tt-emprsts.nrctremp AT 01 FORMAT "zz,zzz,zz9"
         tt-emprsts.vlsdeved AT 12 FORMAT "zzz,zzz,zz9.99"
         tt-emprsts.dspreapg AT 27 FORMAT "x(11)"
         tt-emprsts.vlpreemp AT 39 FORMAT "zzzz,zz9.99"
         "\033\017"
         tt-emprsts.dslcremp AT 53 FORMAT "x(30)"
         tt-emprsts.dsfinemp AT 83 FORMAT "x(28)"
         "\022\033\115"
         WITH NO-BOX NO-LABELS DOWN WIDTH 120 FRAME f_dividas.

    FORM "--------------            ------------" AT 11
         SKIP
         tt-proposta_limite_chq.vlsdeved AT 11 FORMAT "zzz,zzz,zz9.99"
         tt-proposta_limite_chq.vlpreemp AT 37 FORMAT "zzzzz,zz9.99"
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_tot_div.

    FORM SKIP(1)
         "\033\105 SEM ENDIVIDAMENTO NA COOPERATIVA DE CREDITO \033\106" SKIP(2)
         WITH NO-BOX WIDTH 96 FRAME f_sem_divida.

    FORM SKIP
         "\033\105 TOTAL OP.CREDITO: \033\106"
         tt-proposta_limite_chq.vlutiliz FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         "AUTORIZO A CONSULTA DE MINHAS INFORMACOES CADASTRAIS"
         "NOS SERVICOS DE PROTECAO AO CREDITO" AT 54 
         "(SPC, SERASA, CADIN, ...) ALEM DO CADASTRO DA CENTRAL"
         "DE RISCO DO BANCO CENTRAL DO BRASIL." AT 55
         SKIP(2)
         "\033\105 OBSERVACOES: \033\106"
         SKIP(1)
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_autorizo.

    FORM tt-proposta_limite_chq.dsobser1 AT 01 FORMAT "x(94)"
         SKIP
         tt-proposta_limite_chq.dsobser2 AT 01 FORMAT "x(94)"
         SKIP
         tt-proposta_limite_chq.dsobser3 AT 01 FORMAT "x(94)"
         SKIP
         tt-proposta_limite_chq.dsobser4 AT 01 FORMAT "x(94)"
         WITH NO-BOX NO-LABELS WIDTH 120 DOWN FRAME f_observac.

    FORM SKIP(1)
         "CONSULTADO  SPC  EM ____/____/________"
         SKIP(1)
         "CENTRAL DE RISCO EM ____/____/________"
         "SITUACAO: _______________ VISTO: _______________" AT 48
         SKIP(1)
         "\033\105A P R O V A C A O\033\106"
         SKIP(3)
         "___________________________________________" AT 04
         "________________________________________" AT 56 SKIP
         tt-proposta_limite_chq.nmprimtl AT 04 FORMAT "x(50)"
         "Operador:" AT 56 tt-proposta_limite_chq.nmoperad FORMAT "x(30)"
         SKIP(3)
         "___________________________________________" AT 04
         tt-proposta_limite_chq.nmcidade "," AT 60 
         tt-proposta_limite_chq.ddmvtolt FORMAT "99"   "de" 
         tt-proposta_limite_chq.dsmesref FORMAT "x(9)" "de"
         tt-proposta_limite_chq.aamvtolt FORMAT "9999" SKIP
         tt-proposta_limite_chq.nmresco1 FORMAT "x(40)" AT 04 SKIP
         tt-proposta_limite_chq.nmresco2 FORMAT "x(40)" AT 04
         WITH NO-BOX NO-LABELS WIDTH 96 FRAME f_aprovacao.

    FORM "Risco da Proposta:"                                       AT 01
        SKIP(1)
        tt-ratings-novo.dsdopera LABEL "Operacao"                FORMAT "x(15)"      AT 01
        SKIP(1)
        tt-ratings-novo.nrctrrat LABEL "Contrato"                FORMAT "zz,zzz,zz9" AT 01
        tt-ratings-novo.inpontos_rat_inc LABEL "   Pontuacao"    FORMAT "99999"       
        tt-ratings-novo.des_inrisco_rat_inc LABEL "   Nota"      FORMAT "x(2)"        /*ex. A*/
        tt-ratings-novo.innivel_rat_inc LABEL "   Risco"         FORMAT "x(6)"        /*ex. Risco BAIXO*/
        SKIP(1)
	tt-ratings-novo.insegmento_rat_inc LABEL "Segmento"      FORMAT "x(30)"
        WITH SIDE-LABEL WIDTH 120 FRAME f_rating_atual_novo.
        
    FORM SKIP(2)
         "Risco da Proposta:"                                    AT 01
         SKIP(1)                                    
         tt-ratings.dsdopera LABEL "Operacao" FORMAT "x(15)"     AT 01
         tt-ratings.nrctrrat LABEL "Contrato" FORMAT "z,zzz,zz9" AT 26
         tt-ratings.indrisco LABEL "Risco"    FORMAT "x(2)"      AT 49
         tt-ratings.nrnotrat LABEL "Nota"     FORMAT "zz9.99"    AT 61
         tt-ratings.dsdrisco NO-LABEL         FORMAT "x(20)"     AT 76
         WITH SIDE-LABEL WIDTH 120 FRAME f_rating_atual.
    
    FORM "Historico dos Ratings" AT 01
         WITH FRAME f_historico_rating_1.   
                                                                                   
    FORM tt-ratings.dsdopera LABEL "Operacao"       FORMAT "x(18)"   AT 01       
         tt-ratings.nrctrrat LABEL "Contrato"       FORMAT "z,zzz,zz9"        
         tt-ratings.indrisco LABEL "Risco"          FORMAT "x(2)"           
         tt-ratings.nrnotrat LABEL "Nota"           FORMAT "zz9.99"         
         tt-ratings.vloperac LABEL "Valor Operacao" FORMAT "zzz,zzz,zz9.99"   
         tt-ratings.dsditrat LABEL "Situacao"       FORMAT "x(15)"
         WITH DOWN WIDTH 120 FRAME f_historico_rating_2.

    /** FORM's para Contrato de Limite de Descontos de Cheques **/
    FORM "\022\024\033\115\0330\033x0" WITH NO-BOX NO-LABELS FRAME f_config.
         
    FORM "\033\016 CONTRATO DE DESCONTO DE CHEQUES PRE-DATADOS \024\033\106" 
         SKIP
         "\033\016E GARANTIA REAL \024\033\106"  AT 20
         "\033\105No:" tt-contrato_limite_chq.nrctrlim FORMAT "z,zzz,zz9" "\033\106"
         SKIP(1)
         "\033\016 FOLHA DE ROSTO \024\033\106" AT 29
         SKIP(1)
         WITH COLUMN 10 NO-BOX NO-LABELS WIDTH 137 FRAME f_cooperativa.

    FORM "\033\1051.DA IDENTIFICACAO:\033\106"
         SKIP(1)
         "\033\1051.1 COOPERATIVA:\033\106"
         tt-contrato_limite_chq.nmextcop FORMAT "x(50)" 
         "    -   PA:" tt-contrato_limite_chq.cdagenci FORMAT "999" 
         SKIP
         tt-contrato_limite_chq.dslinha1 FORMAT "x(69)" AT 18 SKIP
         tt-contrato_limite_chq.dslinha2 FORMAT "x(69)" AT 18 SKIP
         tt-contrato_limite_chq.dslinha3 FORMAT "x(69)" AT 18 SKIP
         tt-contrato_limite_chq.dslinha4 FORMAT "x(69)" AT 18 SKIP     
         "\033\1051.2 COOPERADO(A):\033\106"
         tt-contrato_limite_chq.nmprimt1 FORMAT "x(39)" 
         ", CONTA CORRENTE:"
         tt-contrato_limite_chq.nrdconta FORMAT "zzzz,zzz,9"
         SKIP
         "CPF/CNPJ:" AT 19 tt-contrato_limite_chq.nrcpfcgc FORMAT "x(18)" 
         tt-contrato_limite_chq.txnrdcid FORMAT "x(25)" AT 55
         SKIP(1)
         "\033\1052. DO VALOR DO LIMITE DE DESCONTO:\033\106"
         SKIP(1)
         "2.1. Valor:" tt-contrato_limite_chq.dsdmoeda FORMAT "x(4)"
         tt-contrato_limite_chq.vllimite FORMAT "zz,zzz,zz9.99"
         tt-contrato_limite_chq.dslimit1 FORMAT "x(55)"
         SKIP
         tt-contrato_limite_chq.dslimit2 FORMAT "x(74)" AT 13
         SKIP(1)
         "\033\1053. DA LINHA DE DESCONTO DOS CHEQUES PRE-DATADOS:\033\106"
         SKIP(1)
         "3.1. Linha de Desconto:"
         tt-contrato_limite_chq.dsdlinha FORMAT "x(35)" 
         SKIP(1)
         "\033\1054. DO PRAZO DE VIGENCIA DO CONTRATO:\033\106"
         SKIP(1)
         "4.1. Prazo de vigencia do contrato:" tt-contrato_limite_chq.qtdiavig FORMAT "zzz9"
         tt-contrato_limite_chq.txqtdvi1 FORMAT "x(36)"
         SKIP(1)
         "\033\1055. DOS ENCARGOS FINANCEIROS:\033\106"
         SKIP(1)
         "5.1. Juros de Mora:\033\105" tt-contrato_limite_chq.dsjurmo1 FORMAT "x(66)" "\033\106"
         SKIP
         "\033\105" tt-contrato_limite_chq.dsjurmo2 FORMAT "x(66)" AT 8 "\033\106"
         SKIP(1)
         "5.2. Multa por inadimplencia:"
         "\033\105" tt-contrato_limite_chq.txdmulta FORMAT "x(11)%"
         tt-contrato_limite_chq.txmulex1 FORMAT "x(36)" "\033\106"
         SKIP
         "\033\105" tt-contrato_limite_chq.txmulex2 FORMAT "x(80)" AT 31 "\033\106"
         SKIP
         "5.3. Custo Efetivo Total (CET) da operacao:\033\105" aux_dscetan1 FORMAT "x(80)"
         SKIP 
         "    " aux_dscetan2 FORMAT "x(80)" 
         SKIP 
         "     conforme planilha demonstrativa de calculo."
         SKIP(1)
         "5.4. Os encargos  de desconto  serao apurados  na forma do "     
         "estabelecimento  no item 4" SKIP
         "     (quatro) das CONDICOES GERAIS."
         SKIP(1)
         "\033\1056. DA DECLARACAO INERENTE A FOLHA DE ROSTO:\033\106"
         SKIP(1)
         "   O(A) COOPERADO(A)  declara  ter  ciencia  dos  encargos  e  despesas  incluidos  na"
         SKIP
         "   operacao que integram o CET, expresso na forma  de taxa percentual  anual  indicada"
         SKIP
         "   no item 5.3.  da  presente Folha de Rosto e  item 4.1. da planilha demonstrativa de" 
         SKIP
         "   calculo, recebida no momento da contratacao."
         SKIP(1)
         "   Declaram as partes, abaixo assinadas, que a presente Folha de Rosto"
         "e' parte  inte-" SKIP                                                 
         "   grante das CONDICOES GERAIS do Contrato de Desconto de Cheques"             
         "Pre-Datados e Garan-" SKIP
         "   tia Real, cujas  condicoes  aceitam, outorgam e prometem cumprir."
         SKIP(1)
         tt-contrato_limite_chq.nmcidade FORMAT "x(46)"
         WITH COLUMN 10 NO-BOX NO-LABELS WIDTH 137 FRAME f_introducao.
                                                                      
    FORM SKIP(4)
         "----------------------------------------"
         "--------------------------------" AT 54 
         SKIP
         tt-contrato_limite_chq.nmprimt2 FORMAT "x(50)"
         tt-contrato_limite_chq.nmresco1 FORMAT "x(34)" AT 50
         tt-contrato_limite_chq.nmresco2 FORMAT "x(34)" AT 50
         SKIP(3)
         "----------------------------------------"
         "----------------------------------------" AT 46
         SKIP
         "Fiador 1:"
         "Conjuge Fiador 1:" AT 46
         SKIP
         tt-contrato_limite_chq.nmdaval1 FORMAT "x(40)"
         tt-contrato_limite_chq.nmdcjav1 FORMAT "x(40)" AT 46
         SKIP
         tt-contrato_limite_chq.dscpfav1 FORMAT "x(40)"
         tt-contrato_limite_chq.dscfcav1 FORMAT "x(40)" AT 46
         SKIP(4)
         "----------------------------------------"
         "----------------------------------------" AT 46
         SKIP
         "Fiador 2:"
         "Conjuge Fiador 2:" AT 46
         SKIP
         tt-contrato_limite_chq.nmdaval2 FORMAT "x(40)"
         tt-contrato_limite_chq.nmdcjav2 FORMAT "x(40)" AT 46
         SKIP
         tt-contrato_limite_chq.dscpfav2 FORMAT "x(40)"
         tt-contrato_limite_chq.dscfcav2 FORMAT "x(40)" AT 46
         SKIP(4)
         "----------------------------------------"
         "----------------------------------------" AT 46
         SKIP
         "TESTEMUNHA: ____________________________"
         "TESTEMUNHA: ____________________________" AT 46
         SKIP
         "CPF:____________________________________"
         "CPF:____________________________________" AT 46
         SKIP     
         "CI:_____________________________________"
         "CI:_____________________________________" AT 46
         SKIP(3)
         "----------------------------------------" AT 46
         SKIP
         "Operador:" AT 46 "\017" tt-contrato_limite_chq.nmoperad FORMAT "x(40)" "\022"
         SKIP
         "--> \033\105PARA USO DA DIGITACAO\033\106"
         "<----------------------------------------------------------\033\120"
         SKIP(1)
         "      CONTA/DV  CONTRATO      PRESTACAO     1o. FIADOR     2o. FIADOR"
         SKIP
         "\033\105"
         SKIP
         tt-contrato_limite_chq.nrdconta FORMAT "zzzz,zzz,9" AT 05
         tt-contrato_limite_chq.nrctrlim FORMAT "z,zzz,zz9"
         tt-contrato_limite_chq.vllimite FORMAT "zzz,zzz,zz9.99"
         " [___________]  [___________]\033\106" 
         WITH COLUMN 10 NO-BOX NO-LABELS WIDTH 137 FRAME f_final.

    /** FORM's para Nota Promissoria de Limite de Descontos de Cheques **/
    FORM SKIP(1)
         "\022\024\033\120" 
         "\0330\033x0\033\017"
         "\033\016    NOTA PROMISSORIA VINCULADA"
         "\0332\033x0"
         SKIP
         "\0330\033x0\033\017"
         "\033\016     AO CONTRATO DE DESCONTO DE"
         "\022\024\033\120" 
         "\0332\033x0"
         "     Vencimento:" 
         tt-dados_nota_pro_chq.ddmvtolt FORMAT "99"   "de"
         tt-dados_nota_pro_chq.dsmesref FORMAT "x(9)" "de"
         tt-dados_nota_pro_chq.aamvtolt FORMAT "9999"
         SKIP
         "\0330\033x0\033\017"
         "\033\016     CHEQUES"
         "\022\024\033\120" 
         SKIP(1)
         "NUMERO" AT 07 "\033\016" tt-dados_nota_pro_chq.dsctremp FORMAT "x(13)" "\024"
         tt-dados_nota_pro_chq.dsdmoeda FORMAT "x(5)" "\033\016"
         tt-dados_nota_pro_chq.vlpreemp FORMAT "zzz,zzz,zz9.99" "\033\016"
         SKIP
         "Ao(s)" AT 07 tt-dados_nota_pro_chq.dsmvtol1 FORMAT "x(68)" SKIP
         tt-dados_nota_pro_chq.dsmvtol2   AT 07 FORMAT "x(44)" "pagarei por esta unica via de" SKIP
         "\033\016N O T A  P R O M I S S O R I A\024" AT 07 "a" 
         tt-dados_nota_pro_chq.nmrescop         FORMAT "x(11)" SKIP
         tt-dados_nota_pro_chq.nmextcop   AT 07 FORMAT "x(50)" 
         tt-dados_nota_pro_chq.nrdocnpj   AT 58 FORMAT "x(23)"
         "ou a sua ordem a quantia de"    AT 07
         tt-dados_nota_pro_chq.dspremp1   AT 35 FORMAT "x(46)" SKIP
         tt-dados_nota_pro_chq.dspremp2   AT 07 FORMAT "x(74)" SKIP
         "em moeda corrente deste pais."  AT 07 SKIP(1)
         tt-dados_nota_pro_chq.nmcidpac   AT 07 FORMAT "x(33)"
         tt-dados_nota_pro_chq.dsemsnot   AT 48 FORMAT "x(33)"
         SKIP(1)
         tt-dados_nota_pro_chq.nmprimtl   AT 07 FORMAT "x(50)"
         SKIP
         tt-dados_nota_pro_chq.dscpfcgc   AT 07 FORMAT "x(40)" 
         "______________________________" AT 50
         SKIP
         "Conta/dv:"  AT 07 tt-dados_nota_pro_chq.nrdconta FORMAT "zzzz,zzz,9" 
         "Assinatura" AT 50
         SKIP
         "Endereco:"  AT 07 SKIP
         tt-dados_nota_pro_chq.dsendco1 AT 07 FORMAT "x(73)" SKIP
         tt-dados_nota_pro_chq.dsendco2 AT 07 FORMAT "x(73)" SKIP 
         tt-dados_nota_pro_chq.dsendco3 AT 07 FORMAT "x(73)" SKIP(1)
         WITH NO-BOX NO-LABELS DOWN WIDTH 137 FRAME f_notapromissoria.

    FORM tt-dados_nota_pro_chq.dsqtdava AT 07 FORMAT "x(10)" 
         "Conjuge:"     AT 47 SKIP
         "\022\033\115" AT 06
         WITH NO-BOX NO-LABELS DOWN WIDTH 137 FRAME f_cab_promis_aval.

    FORM SKIP(2)
         "----------------------------------------" AT 08
         "----------------------------------------" AT 56
         tt-dados-avais.nmdavali AT 08 FORMAT "x(40)"
         tt-dados-avais.nmconjug AT 56 FORMAT "x(40)"
         SKIP
         aux_nrcpfcgc            AT 08 FORMAT "x(40)"
         tt-dados-avais.nrdoccjg AT 56 FORMAT "x(40)"
         SKIP                             
         tt-dados-avais.dsendre1 AT 08 FORMAT "x(40)"
         SKIP
         tt-dados-avais.dsendre2 AT 08 FORMAT "x(40)"
         SKIP
         tt-dados-avais.dsendre3 AT 08 FORMAT "x(40)"
         SKIP(3)
         WITH NO-BOX NO-LABELS DOWN WIDTH 137 FRAME f_promis_aval.
                
    FORM SKIP(5)
         WITH NO-BOX WIDTH 137 FRAME f_linhas.

    FORM "Grupo Economico:" AT 01
        SKIP(1)
        WITH FRAME f_grupo_1.
        
   FORM tt-grupo.cdagenci COLUMN-LABEL "PA" 
        tt-grupo.nrctasoc COLUMN-LABEL "Conta"
        tt-grupo.vlendivi COLUMN-LABEL "Endividamento" FORMAT "zzz,zzz,zz9.99"
        tt-grupo.dsdrisco COLUMN-LABEL "Risco"
        WITH DOWN WIDTH 120 NO-BOX FRAME f_grupo.

   FORM SKIP(1) 
        aux_dsdrisco LABEL "Risco do Grupo"
        SKIP
        aux_vlendivi LABEL "Endividamento do Grupo"
        WITH NO-LABEL SIDE-LABEL WIDTH 120 NO-BOX FRAME f_grupo_2.
    
    EMPTY TEMP-TABLE tt-erro.

    IF  par_flgerlog  THEN
        DO: 
            ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

            IF  par_idimpres = 1  THEN
                aux_dstransa = "Gerar impressao da proposta e contrato do " +
                               "limite de desconto de cheques".
            ELSE
            IF  par_idimpres = 2  THEN
                aux_dstransa = "Gerar impressao do contrato do limite de " +
                               "desconto de cheques".
            ELSE
            IF  par_idimpres = 3  THEN
                aux_dstransa = "Gerar impressao da proposta do limite de " +
                               "desconto de cheques".
            ELSE
            IF  par_idimpres = 4  THEN
                aux_dstransa = "Gerar impressao da nota promissoria do " +
                               "limite de desconto de cheques".
            ELSE
            IF  par_idimpres = 9  THEN
                aux_dstransa = "Gerar impressao de demonstracao do cet".
        END.

    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN aux_cdcritic = 651
                   aux_dscritic = "".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagecxa,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdopecxa,
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

    
    RUN busca_dados_impressao_dscchq (INPUT par_cdcooper,
                                      INPUT par_cdagecxa,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdopecxa,
                                      INPUT par_nmdatela,
                                      INPUT par_idorigem,
                                      INPUT par_nrdconta,
                                      INPUT par_idseqttl,    
                                      INPUT par_dtmvtolt,
                                      INPUT par_dtmvtopr,
                                      INPUT par_inproces,
                                      INPUT par_idimpres,
                                      INPUT par_nrctrlim,
                                      INPUT 0,  /** Bordero **/
                                      INPUT FALSE,
                                      INPUT 1,  /** Limite  **/
                                     OUTPUT TABLE tt-erro,
                                     OUTPUT TABLE tt-emprsts,
                                     OUTPUT TABLE tt-proposta_limite_chq,
                                     OUTPUT TABLE tt-contrato_limite_chq,        
                                     OUTPUT TABLE tt-dados-avais,
                                     OUTPUT TABLE tt-dados_nota_pro_chq,
                                     OUTPUT TABLE tt-proposta_bordero_dscchq,
                                     OUTPUT TABLE tt-dados_chqs_bordero,
                                     OUTPUT TABLE tt-chqs_do_bordero,
                                     OUTPUT TABLE tt-dscchq_bordero_restricoes).

    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel gerar a impressao.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,           /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.

            IF  par_flgerlog  THEN
                RUN proc_gerar_log (INPUT par_cdcooper,
                                    INPUT par_cdopecxa,
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

    /* Se nao for impressao do cet gera arquivo normal */
    IF  par_idimpres <> 9 THEN
        DO: 
            ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                                  par_dsiduser.
             
            UNIX SILENT VALUE("rm " + aux_nmarquiv + "* 2>/dev/null").
        
            ASSIGN aux_nmarquiv = aux_nmarquiv + STRING(TIME)
                   aux_nmarqimp = aux_nmarquiv + ".ex"
                   aux_nmarqpdf = aux_nmarquiv + ".pdf".
        
            FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND         
                               craptab.nmsistem = "CRED"         AND         
                               craptab.tptabela = "GENERI"       AND         
                               craptab.cdempres = 00             AND         
                               craptab.cdacesso = "DIGITALIZA"   AND
                               craptab.tpregist = 1  /* Limite de Desc. de Cheque. (GED) */
                               NO-LOCK NO-ERROR NO-WAIT.
                
            IF  AVAIL craptab THEN
                ASSIGN aux_tpdocged = INT(ENTRY(3,craptab.dstextab,";")).
            
            OUTPUT STREAM str_dscchq TO VALUE(aux_nmarqimp) APPEND PAGED PAGE-SIZE 87.
        END.

    IF  par_idimpres = 9 THEN /*** CET ***/
        DO:
            FIND FIRST tt-contrato_limite_chq NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-contrato_limite_chq  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel gerar a impressao.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
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

            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta 
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapass THEN
                RETURN "NOK".

            FIND crapldc WHERE crapldc.cdcooper = par_cdcooper AND
                               crapldc.cddlinha = tt-dscchq_dados_limite.codlinha AND
                               crapldc.tpdescto = 2
                               NO-LOCK NO-ERROR.
        
            IF  NOT AVAIL crapldc THEN
                RETURN "NOK".
            
            /* Chamar rorina de impressao do contrato do cet */
            RUN imprime_cet( INPUT par_cdcooper,
                             INPUT par_dtmvtolt,
                             INPUT "ATENDA",
                             INPUT INT(tt-contrato_limite_chq.nrdconta),
                             INPUT INT(crapass.inpessoa),
                             INPUT 1, /* p-cdusolcr */
                             INPUT INT(tt-dscchq_dados_limite.codlinha),
                             INPUT 2, /*1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit*/
                             INPUT INT(tt-contrato_limite_chq.nrctrlim),
                             INPUT (IF tt-dscchq_dados_limite.dtinivig <> ? THEN
                                       tt-dscchq_dados_limite.dtinivig
                                    ELSE par_dtmvtolt),
                             INPUT INT(tt-contrato_limite_chq.qtdiavig),
                             INPUT DEC(tt-contrato_limite_chq.vllimite),
                             INPUT DEC(crapldc.txmensal),
                            OUTPUT aux_nmdoarqv, 
                            OUTPUT aux_dscritic ).
            
            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
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
            ELSE
                ASSIGN aux_nmarquiv = "/usr/coop/" + crapcop.dsdircop + 
                                      "/rl/" + aux_nmdoarqv
                       aux_nmarqimp = aux_nmarquiv + ".ex"  
                       aux_nmarqpdf = aux_nmarquiv + ".pdf". 
        END.

    IF  par_idimpres = 3  THEN  /** PROPOSTA **/
        DO:               
            FIND FIRST tt-proposta_limite_chq NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-proposta_limite_chq  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel gerar a impressao.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
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

            RUN sistema/generico/procedures/b1wgen0043.p PERSISTENT 
                SET h-b1wgen0043.
    
            IF  NOT VALID-HANDLE(h-b1wgen0043)  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Handle invalido para BO b1wgen0043.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
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

            RUN ratings-impressao IN h-b1wgen0043 (INPUT par_cdcooper,
                                                   INPUT 0, /** Todos PA's **/
                                                   INPUT par_cdopecxa,
                                                   INPUT par_idorigem, 
                                                   INPUT par_dtmvtolt,
                                                   INPUT par_dtmvtopr,
                                                   INPUT par_nrdconta,
                                                   INPUT par_nrctrlim,
                                                   INPUT 2, 
                                                   INPUT par_inproces,
                                                  OUTPUT TABLE tt-ratings).
  
            DELETE PROCEDURE h-b1wgen0043.
            
            ASSIGN  rel_nrdconta = tt-proposta_limite_chq.nrdconta.
                    
                    
                   

            PAGE STREAM str_dscchq.

            PUT STREAM str_dscchq CONTROL "\0330\033x0\022\033\115" NULL.
        
            DISPLAY STREAM str_dscchq
                tt-proposta_limite_chq.nrdconta  tt-proposta_limite_chq.nrmatric
                tt-proposta_limite_chq.dsagenci  tt-proposta_limite_chq.nmprimtl
                tt-proposta_limite_chq.dtadmemp  tt-proposta_limite_chq.nmempres
                tt-proposta_limite_chq.telefone     
                tt-proposta_limite_chq.nrcpfcgc  tt-proposta_limite_chq.dstipcta
                tt-proposta_limite_chq.dssitdct  tt-proposta_limite_chq.dtadmiss
                tt-proposta_limite_chq.nmextcop  tt-proposta_limite_chq.dsramati
                tt-proposta_limite_chq.nrctrlim  FORMAT "z,zzz,zz9"  
                aux_tpdocged                     FORMAT "zz9"
                rel_nrdconta                     FORMAT "zzzz,zzz,9"
                WITH FRAME f_pro_dados.
            
            DISPLAY STREAM str_dscchq
                tt-proposta_limite_chq.vlsmdtri  tt-proposta_limite_chq.vlcaptal
                tt-proposta_limite_chq.vlprepla  tt-proposta_limite_chq.vlsalari
                tt-proposta_limite_chq.vlsalcon  tt-proposta_limite_chq.vloutras
                tt-proposta_limite_chq.vllimcre  tt-proposta_limite_chq.vltotccr
                tt-proposta_limite_chq.vlaplica  tt-proposta_limite_chq.dsdeben1
                tt-proposta_limite_chq.dsdeben2  tt-proposta_limite_chq.vlfatura
                WITH FRAME f_pro_rec.
        
            DISPLAY STREAM str_dscchq 
                tt-proposta_limite_chq.nrctrlim  tt-proposta_limite_chq.vllimpro
                tt-proposta_limite_chq.dsdlinha  tt-proposta_limite_chq.vlmedchq
                WITH FRAME f_lim_pro.
        
            DOWN STREAM str_dscchq WITH FRAME f_lim_pro.
        
            IF  CAN-FIND(FIRST tt-emprsts NO-LOCK)  THEN
                DO:
                    DISPLAY STREAM str_dscchq tt-proposta_limite_chq.dtcalcul 
                                   WITH FRAME f_pro_ed1.
        
                    FOR EACH tt-emprsts WHERE tt-emprsts.vlsdeved > 0 NO-LOCK:
        
                        DISPLAY STREAM str_dscchq
                                tt-emprsts.nrctremp  tt-emprsts.vlsdeved
                                tt-emprsts.dspreapg  tt-emprsts.vlpreemp
                                tt-emprsts.dslcremp  tt-emprsts.dsfinemp
                                WITH FRAME f_dividas.
        
                        DOWN STREAM str_dscchq WITH FRAME f_dividas.
        
                    END. /** Fim do FOR EACH tt-emprsts **/
        
                    DISPLAY STREAM str_dscchq tt-proposta_limite_chq.vlsdeved  
                                              tt-proposta_limite_chq.vlpreemp 
                                              WITH FRAME f_tot_div.
                END.
            ELSE
                VIEW STREAM str_dscchq FRAME f_sem_divida.
        
            DISPLAY STREAM str_dscchq tt-proposta_limite_chq.vlutiliz
                                      WITH FRAME f_autorizo.
        
            DISPLAY STREAM str_dscchq 
                tt-proposta_limite_chq.dsobser1  tt-proposta_limite_chq.dsobser2
                tt-proposta_limite_chq.dsobser3  tt-proposta_limite_chq.dsobser4
                WITH FRAME f_observac.
                            
            DOWN STREAM str_dscchq WITH FRAME f_observac.        
         
            DISPLAY STREAM str_dscchq 
                tt-proposta_limite_chq.nmprimtl  tt-proposta_limite_chq.nmoperad
                tt-proposta_limite_chq.nmcidade  tt-proposta_limite_chq.ddmvtolt
                tt-proposta_limite_chq.dsmesref  tt-proposta_limite_chq.aamvtolt
                tt-proposta_limite_chq.nmresco1  tt-proposta_limite_chq.nmresco2
                WITH FRAME f_aprovacao.

            PAGE STREAM str_dscchq.

            PUT STREAM str_dscchq CONTROL "\0330\033x0\022\033\115" NULL.

            /* Habilita novo rating */
            IF aux_habrat = 'S' AND par_cdcooper <> 3 THEN DO:

              /*RATING NOVO*/
              ASSIGN vr_des_inrisco_rat_inc = ""       
                     vr_inpontos_rat_inc    = 0
                     vr_innivel_rat_inc     = ""
                     vr_insegmento_rat_inc  = ""
                     vr_vlr                 = 0
                     vr_qtdreg              = 0
                     vr_nrctro_out          = 0
                     vr_tpctrato_out        = 0.
                   
              ASSIGN aux_dscritic = "".
              ASSIGN aux_cdcritic = 0.
            
              EMPTY TEMP-TABLE tt-ratings-novo.
            
              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                        
              RUN STORED-PROCEDURE pc_busca_dados_rating_inclusao
                  aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper      /*COOPERATIVA */
                                                      ,INPUT par_nrdconta /*tt-proposta_limite_chq.nrdconta  CONTA  */
                                                      ,INPUT par_nrctrlim /*tt-proposta_limite_chq.nrctrlim NUM CONTRATO DA CONTA*/
                                                      ,INPUT 2                /*TIPO CONTRATO DA CONTA*/
                                                      ,OUTPUT "" /*pr_des_inrisco_rat_inc - Nivel de Rating da Inclusao da Proposta*/
                                                      ,OUTPUT 0  /*pr_inpontos_rat_inc    - Pontuacao do Rating retornada do Motor no momento da Inclusao*/
                                                      ,OUTPUT "" /*pr_innivel_rat_inc     - Nivel de Risco do Rating Inclusao (1-Baixo/2-Medio/3-Alto)*/
                                                      ,OUTPUT "" /*pr_insegmento_rat_inc   - qual Garantia foi utilizada para calculo Rating na Inclusao*/
                                                      ,OUTPUT 0                /*pr_vlr  crapepr.vlemprst*/
                                                      ,OUTPUT 0                /*pr_qtdreg QTDE REG.*/
                                                      ,OUTPUT 0                /*pr_nrctro_out CONTRATO DA CONTA*/
                                                      ,OUTPUT 0                /*pr_tpctrato_out TIPO CONTRATO DA CONTA*/
                                                      ,OUTPUT ""               /*Arquivo de retorno do XML*/
                                                      ,OUTPUT 0                /*pr_cdcritic  */
                                                      ,OUTPUT "").             /*Descricao da critica*/
                                                      
               CLOSE STORED-PROC pc_busca_dados_rating_inclusao
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                   
               { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
            
               ASSIGN vr_xml = pc_busca_dados_rating_inclusao.pr_retxml_clob
                             WHEN pc_busca_dados_rating_inclusao.pr_retxml_clob <> ?.
               ASSIGN aux_cdcritic = pc_busca_dados_rating_inclusao.pr_cdcritic
                             WHEN pc_busca_dados_rating_inclusao.pr_cdcritic <> ?.
               ASSIGN aux_dscritic = pc_busca_dados_rating_inclusao.pr_dscritic
                             WHEN pc_busca_dados_rating_inclusao.pr_dscritic <> ?.
               ASSIGN vr_des_inrisco_rat_inc = pc_busca_dados_rating_inclusao.pr_des_inrisco_rat_inc 
                             WHEN pc_busca_dados_rating_inclusao.pr_des_inrisco_rat_inc <> ? .
               ASSIGN vr_inpontos_rat_inc = pc_busca_dados_rating_inclusao.pr_inpontos_rat_inc 
                             WHEN pc_busca_dados_rating_inclusao.pr_inpontos_rat_inc <> ? .
               ASSIGN vr_innivel_rat_inc = pc_busca_dados_rating_inclusao.pr_innivel_rat_inc 
                             WHEN pc_busca_dados_rating_inclusao.pr_innivel_rat_inc <> ? .
               ASSIGN vr_insegmento_rat_inc = pc_busca_dados_rating_inclusao.pr_insegmento_rat_inc 
                             WHEN pc_busca_dados_rating_inclusao.pr_insegmento_rat_inc <> ? .
               ASSIGN vr_vlr = pc_busca_dados_rating_inclusao.pr_vlr 
                             WHEN pc_busca_dados_rating_inclusao.pr_vlr <> ? .
               ASSIGN vr_qtdreg = pc_busca_dados_rating_inclusao.pr_qtdreg 
                             WHEN pc_busca_dados_rating_inclusao.pr_qtdreg <> ? .
               ASSIGN vr_nrctro_out = pc_busca_dados_rating_inclusao.pr_nrctro_out 
                             WHEN pc_busca_dados_rating_inclusao.pr_nrctro_out<> ? .
               ASSIGN vr_tpctrato_out = pc_busca_dados_rating_inclusao.pr_tpctrato_out 
                             WHEN pc_busca_dados_rating_inclusao.pr_tpctrato_out <> ? .

               CREATE tt-ratings-novo.  
               ASSIGN tt-ratings-novo.nrctrrat = vr_nrctro_out
                      tt-ratings-novo.tpctrrat = vr_tpctrato_out
                      tt-ratings-novo.vloperac = vr_vlr
                      tt-ratings-novo.dsdopera = "Desconto Cheque"
                      tt-ratings-novo.innivel_rat_inc = vr_innivel_rat_inc   
                      tt-ratings-novo.des_inrisco_rat_inc = vr_des_inrisco_rat_inc  /*Nota Rating */
                      tt-ratings-novo.inpontos_rat_inc = vr_inpontos_rat_inc
                      tt-ratings-novo.insegmento_rat_inc = vr_insegmento_rat_inc.
		      
               FIND tt-ratings-novo WHERE 
                    tt-ratings-novo.tpctrrat = 2   AND
                    tt-ratings-novo.nrctrrat = tt-proposta_limite_chq.nrctrlim NO-LOCK NO-ERROR.
        
               IF   ((AVAIL tt-ratings-novo) AND
                     (tt-ratings-novo.des_inrisco_rat_inc <> ? AND tt-ratings-novo.innivel_rat_inc <> ?)) THEN
               DO:
                   DISPLAY STREAM str_dscchq 
                        tt-ratings-novo.dsdopera 
                        tt-ratings-novo.nrctrrat 
                        tt-ratings-novo.inpontos_rat_inc 
                        tt-ratings-novo.des_inrisco_rat_inc 
                        tt-ratings-novo.innivel_rat_inc 
                        tt-ratings-novo.insegmento_rat_inc
                    WITH FRAME f_rating_atual_novo.   

               END.
            END.
            /* Habilita novo rating */
            ELSE DO:
	     
              FIND tt-ratings WHERE 
                   tt-ratings.tpctrrat = 2                               AND
                   tt-ratings.nrctrrat = tt-proposta_limite_chq.nrctrlim
                   NO-LOCK NO-ERROR.
        
              IF  AVAIL tt-ratings   THEN
                  DISPLAY STREAM str_dscchq 
                      tt-ratings.dsdopera  tt-ratings.nrctrrat
                      tt-ratings.indrisco  tt-ratings.nrnotrat
                      tt-ratings.dsdrisco  WITH FRAME f_rating_atual. 

              IF  CAN-FIND(FIRST tt-ratings WHERE NOT 
                     (tt-ratings.tpctrrat = 2  AND
                      tt-ratings.nrctrrat = tt-proposta_limite_chq.nrctrlim)) THEN
                  VIEW STREAM str_dscchq FRAME f_historico_rating_1.
        
              /** Todos os outros ratings de operacoes ainda em aberto **/
              FOR EACH tt-ratings WHERE 
                  NOT (tt-ratings.tpctrrat = 2                 AND
                       tt-ratings.nrctrrat = craplim.nrctrlim) NO-LOCK
                       BY tt-ratings.insitrat DESC
                       BY tt-ratings.nrnotrat DESC:
        
                  DISPLAY STREAM str_dscchq 
                      tt-ratings.dsdopera  tt-ratings.nrctrrat
                      tt-ratings.indrisco  tt-ratings.nrnotrat
                      tt-ratings.vloperac  tt-ratings.dsditrat
                      WITH FRAME f_historico_rating_2.
        
                  DOWN WITH FRAME f_historico_rating_2.
        
              END. /** Fim do FOR EACH tt-ratings **/
            END.
        
            IF NOT VALID-HANDLE(h-b1wgen0138) THEN
               RUN sistema/generico/procedures/b1wgen0138.p
                   PERSISTENT SET h-b1wgen0138.
                       
            IF DYNAMIC-FUNCTION("busca_grupo" IN h-b1wgen0138,
                                           INPUT par_cdcooper, 
                                           INPUT rel_nrdconta, 
                                          OUTPUT aux_nrdgrupo,
                                          OUTPUT aux_gergrupo,
                                          OUTPUT aux_dsdrisgp) THEN
               DO:          
                 /* Procedure responsavel para calcular o endividamento do grupo */
                  RUN calc_endivid_grupo IN h-b1wgen0138
                                               (INPUT par_cdcooper,
                                                INPUT par_cdagecxa,
                                                INPUT par_nrdcaixa, 
                                                INPUT par_cdopecxa, 
                                                INPUT par_dtmvtolt, 
                                                INPUT par_nmdatela, 
                                                INPUT par_idorigem, 
                                                INPUT aux_nrdgrupo, 
                                                INPUT TRUE, /*Consulta por conta*/
                                               OUTPUT aux_dsdrisco, 
                                               OUTPUT aux_vlendivi,
                                               OUTPUT TABLE tt-grupo, 
                                               OUTPUT TABLE tt-erro).

                  IF VALID-HANDLE(h-b1wgen0138) THEN
                     DELETE OBJECT h-b1wgen0138.  
                   
                  IF RETURN-VALUE <> "OK" THEN
                     RETURN "NOK".

                  IF TEMP-TABLE tt-grupo:HAS-RECORDS THEN
                     DO: 
                        VIEW STREAM str_dscchq FRAME f_grupo_1.
                             
                        FOR EACH tt-grupo NO-LOCK BY tt-grupo.cdagenci:
                       
                            DISP STREAM str_dscchq tt-grupo.cdagenci
                                                   tt-grupo.nrctasoc
                                                   tt-grupo.vlendivi
                                                   tt-grupo.dsdrisco
                                                   WITH FRAME f_grupo.
                        
                            DOWN WITH FRAME f_grupo.
                        
                        END.                  
                        
                        DISP STREAM str_dscchq aux_dsdrisco 
                                               aux_vlendivi
                                               WITH FRAME f_grupo_2.

                     END.

               END.

            IF VALID-HANDLE(h-b1wgen0138) THEN
               DELETE OBJECT h-b1wgen0138.

        END.
    
    IF  par_idimpres = 1  OR    /** COMPLETA **/
        par_idimpres = 2  THEN  /** CONTRATO **/
        DO:
            FIND FIRST tt-contrato_limite_chq NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-contrato_limite_chq  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel gerar a impressao.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
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

            RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT
                SET h-b1wgen9999.

            /*  calculo do cet por extenso ................................ */
            RUN valor-extenso IN h-b1wgen9999 
                             (INPUT tt-dscchq_dados_limite.txcetano, 
                              INPUT 29, 
                              INPUT 80, 
                              INPUT "P",
                              OUTPUT aux_dscetan1, 
                              OUTPUT aux_dscetan2).

            ASSIGN aux_dscetan1 = STRING(tt-dscchq_dados_limite.txcetano,"zz9.99") + 
                                  " % (" + LC(aux_dscetan1).

            IF   LENGTH(TRIM(aux_dscetan2)) = 0   THEN
                 ASSIGN aux_dscetan1 = aux_dscetan1 + ")" 
                        aux_dscetan2 = "ao ano; (" +
                                       STRING(tt-dscchq_dados_limite.txcetmes,"zz9.99") +
                                       " % ao mes), ".
            ELSE
                 ASSIGN aux_dscetan1 = aux_dscetan1 
                        aux_dscetan2 = TRIM(LC(aux_dscetan2)) + ") ao ano; (" +
                                       STRING(tt-dscchq_dados_limite.txcetmes,"zz9.99") +
                                       " % ao mes), ".

            PAGE STREAM str_dscchq.

            VIEW STREAM str_dscchq FRAME f_config.

            DISPLAY STREAM str_dscchq tt-contrato_limite_chq.nrctrlim 
                                      WITH FRAME f_cooperativa.

            DISPLAY STREAM str_dscchq
                tt-contrato_limite_chq.nmextcop  tt-contrato_limite_chq.cdagenci
                tt-contrato_limite_chq.dslinha1  tt-contrato_limite_chq.dslinha2
                tt-contrato_limite_chq.dslinha3  tt-contrato_limite_chq.dslinha4
                tt-contrato_limite_chq.nmprimt1  tt-contrato_limite_chq.nrdconta
                tt-contrato_limite_chq.nrcpfcgc  tt-contrato_limite_chq.txnrdcid
                tt-contrato_limite_chq.dsdmoeda  tt-contrato_limite_chq.vllimite
                tt-contrato_limite_chq.dslimit1  tt-contrato_limite_chq.dslimit2
                tt-contrato_limite_chq.dsdlinha  tt-contrato_limite_chq.qtdiavig
                tt-contrato_limite_chq.txqtdvi1  tt-contrato_limite_chq.dsjurmo1
                tt-contrato_limite_chq.dsjurmo2  tt-contrato_limite_chq.txdmulta
                tt-contrato_limite_chq.txmulex1  tt-contrato_limite_chq.txmulex2
                tt-contrato_limite_chq.nmcidade  aux_dscetan1 aux_dscetan2
                WITH FRAME f_introducao.
        
            DISPLAY STREAM str_dscchq
                tt-contrato_limite_chq.nmprimt2  tt-contrato_limite_chq.nmresco1
                tt-contrato_limite_chq.nmresco2  tt-contrato_limite_chq.nmdaval1
                tt-contrato_limite_chq.nmdcjav1  tt-contrato_limite_chq.dscpfav1
                tt-contrato_limite_chq.dscfcav1  tt-contrato_limite_chq.nmdaval2
                tt-contrato_limite_chq.nmdcjav2  tt-contrato_limite_chq.dscpfav2
                tt-contrato_limite_chq.dscfcav2  tt-contrato_limite_chq.nmoperad
                tt-contrato_limite_chq.nrdconta  tt-contrato_limite_chq.nrctrlim
                tt-contrato_limite_chq.vllimite 
                WITH FRAME f_final.

            /*** GERAR IMPRESSAO CET ***/
            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = par_nrdconta 
                               NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapass THEN
                RETURN "NOK".

            FIND crapldc WHERE crapldc.cdcooper = par_cdcooper       AND
                               crapldc.cddlinha = tt-dscchq_dados_limite.codlinha AND
                               crapldc.tpdescto = 2
                               NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE crapldc  THEN
                RETURN "NOK".

            /* Chamar rorina de impressao do contrato do cet */
            RUN imprime_cet( INPUT par_cdcooper,
                             INPUT par_dtmvtolt,
                             INPUT "ATENDA",
                             INPUT INT(tt-contrato_limite_chq.nrdconta),
                             INPUT INT(crapass.inpessoa),
                             INPUT 1, /* p-cdusolcr */
                             INPUT INT(tt-dscchq_dados_limite.codlinha),
                             INPUT 2, /*1-Chq Esp./ 2-Desc Chq./ 3-Desc Tit*/
                             INPUT INT(tt-contrato_limite_chq.nrctrlim),
                             INPUT (IF tt-dscchq_dados_limite.dtinivig <> ? THEN
                                       tt-dscchq_dados_limite.dtinivig
                                    ELSE par_dtmvtolt),
                             INPUT INT(tt-contrato_limite_chq.qtdiavig), 
                             INPUT DEC(tt-contrato_limite_chq.vllimite),
                             INPUT DEC(crapldc.txmensal),
                            OUTPUT aux_nmdoarqv, 
                            OUTPUT aux_dscritic ).

            IF  RETURN-VALUE <> "OK" THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
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
        END.

    
    IF  par_idimpres = 1  OR    /** COMPLETA    **/
        par_idimpres = 4  THEN  /** PROMISSORIA **/
        DO:
            FIND FIRST tt-dados_nota_pro_chq NO-LOCK NO-ERROR.

            IF  NOT AVAILABLE tt-dados_nota_pro_chq  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Nao foi possivel gerar a impressao.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagecxa,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
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

            PAGE STREAM str_dscchq.
        
            PUT STREAM str_dscchq CONTROL "\0330\033x0\033\022\033\120" NULL.

            DISPLAY STREAM str_dscchq
                tt-dados_nota_pro_chq.nmrescop  tt-dados_nota_pro_chq.nmextcop
                tt-dados_nota_pro_chq.nrdocnpj  tt-dados_nota_pro_chq.ddmvtolt
                tt-dados_nota_pro_chq.dsmesref  tt-dados_nota_pro_chq.aamvtolt
                tt-dados_nota_pro_chq.dsctremp  tt-dados_nota_pro_chq.dsdmoeda
                tt-dados_nota_pro_chq.vlpreemp  tt-dados_nota_pro_chq.dsmvtol1
                tt-dados_nota_pro_chq.dsmvtol2  tt-dados_nota_pro_chq.dspremp1
                tt-dados_nota_pro_chq.dspremp2  tt-dados_nota_pro_chq.nmprimtl
                tt-dados_nota_pro_chq.dscpfcgc  tt-dados_nota_pro_chq.nrdconta
                tt-dados_nota_pro_chq.dsendco1  tt-dados_nota_pro_chq.dsendco2
                tt-dados_nota_pro_chq.dsendco3  tt-dados_nota_pro_chq.nmcidpac
                tt-dados_nota_pro_chq.dsemsnot
                WITH FRAME f_notapromissoria.
         
            DOWN STREAM str_dscchq WITH FRAME f_notapromissoria.
                         
            IF  CAN-FIND(FIRST tt-dados-avais NO-LOCK)  THEN
                DISPLAY STREAM str_dscchq tt-dados_nota_pro_chq.dsqtdava
                               WITH FRAME f_cab_promis_aval.

            

            FOR EACH tt-dados-avais NO-LOCK BY tt-dados-avais.idavalis:
                
                ASSIGN aux_nrcpfcgc = IF tt-dados-avais.nrcpfcgc > 0 THEN
                                          "C.P.F. " + 
                                          STRING(STRING(tt-dados-avais.nrcpfcgc,
                                          "99999999999"),"xxx.xxx.xxx-xx")
                                      ELSE
                                          FILL("_",40).
                                   
                DISPLAY STREAM str_dscchq
                    tt-dados-avais.nmdavali  tt-dados-avais.nmconjug  
                    aux_nrcpfcgc             tt-dados-avais.nrdoccjg
                    tt-dados-avais.dsendre1  tt-dados-avais.dsendre2
                    tt-dados-avais.dsendre3
                    WITH FRAME f_promis_aval.
                     
                DOWN STREAM str_dscchq WITH FRAME f_promis_aval.

            END. /** Fim do FOR EACH tt-dados-avais **/
                      
            VIEW STREAM str_dscchq FRAME f_linhas.
        END.

    IF  par_idimpres <> 9 THEN
        DO: 
            OUTPUT STREAM str_dscchq CLOSE.

            IF  par_idimpres = 1  OR   /** Completa **/
                par_idimpres = 2  THEN /** Contrato **/
                RUN junta_arquivos(INPUT crapcop.dsdircop,
                                   INPUT aux_nmarquiv + ".ex", /*contratos */
                                   INPUT "/usr/coop/" + crapcop.dsdircop + 
                                         "/rl/" + aux_nmdoarqv + ".ex", /* cet */
                                  OUTPUT aux_nmarqimp,
                                  OUTPUT aux_nmarqpdf).
        END.

    
    IF  par_flgemail      OR    /** Enviar proposta via e-mail **/
        par_idorigem = 5  THEN  /** Ayllos Web **/
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
                IF  par_idorigem = 5  THEN
                    DO:
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
                    END.
    
                /** Enviar proposta para o PA Sede via e-mail **/
                IF  par_flgemail  THEN
                    DO:
                        RUN executa-envio-email IN h-b1wgen0024 
                                               (INPUT par_cdcooper, 
                                                INPUT par_cdagecxa, 
                                                INPUT par_nrdcaixa, 
                                                INPUT par_cdopecxa, 
                                                INPUT par_nmdatela, 
                                                INPUT par_idorigem, 
                                                INPUT par_dtmvtolt, 
                                                INPUT 518, 
                                                INPUT aux_nmarqimp, 
                                                INPUT aux_nmarqpdf,
                                                INPUT par_nrdconta, 
                                                INPUT 2, 
                                                INPUT par_nrctrlim, 
                                               OUTPUT TABLE tt-erro).
    
                        IF  RETURN-VALUE = "NOK"  THEN
                            DO:
                                FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
                                IF  AVAILABLE tt-erro  THEN
                                    ASSIGN aux_dscritic = tt-erro.dscritic.
                                ELSE
                                    ASSIGN aux_dscritic = "Nao foi possivel " +
                                                          "gerar a impressao.".
    
                                LEAVE.
                            END.
                    END.

                LEAVE.

            END. /** Fim do DO WHILE TRUE **/

            IF  VALID-HANDLE(h-b1wgen0024)  THEN
                DELETE PROCEDURE h-b1wgen0024.
    
            IF  aux_dscritic <> ""  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  NOT AVAILABLE tt-erro  THEN
                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagecxa,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).
                                               
                    IF  par_flgerlog  THEN
                        RUN proc_gerar_log (INPUT par_cdcooper,
                                            INPUT par_cdopecxa,
                                            INPUT aux_dscritic,
                                            INPUT aux_dsorigem,
                                            INPUT aux_dstransa,
                                            INPUT FALSE,
                                            INPUT par_idseqttl,
                                            INPUT par_nmdatela,
                                            INPUT par_nrdconta,
                                           OUTPUT aux_nrdrowid). 
                        
                    IF  aux_nmarquiv <> "" THEN
                        UNIX SILENT VALUE ("rm " + aux_nmarquiv + " 2>/dev/null").

                    RETURN "NOK".
                END.

            IF  par_idorigem = 5  THEN
                DO:
                    IF  aux_nmarquiv <> "" THEN
                        UNIX SILENT VALUE ("rm " + aux_nmarquiv + " 2>/dev/null").

                    /* Remover arquivo gerado do cet */
                    IF  aux_nmdoarqv <> "" THEN
                        UNIX SILENT VALUE ("rm " + "/usr/coop/" + crapcop.dsdircop + "/rl/" + 
                                           TRIM(aux_nmdoarqv) + " 2>/dev/null").
                END.
            ELSE
                UNIX SILENT VALUE ("rm " + aux_nmarqpdf + " 2>/dev/null").
        END.
    
    ASSIGN par_nmarqimp = aux_nmarqimp
           par_nmarqpdf = ENTRY(NUM-ENTRIES(aux_nmarqpdf,"/"),aux_nmarqpdf,"/").

    IF  par_flgerlog  THEN 
        RUN proc_gerar_log (INPUT par_cdcooper,
                            INPUT par_cdopecxa,
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


/*****************************************************************************
      Buscar dados para montar contratos etc para desconto de cheques      
*****************************************************************************/
PROCEDURE busca_dados_impressao_dscchq:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.    
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtopr AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_inproces AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idimpres AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctrlim AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrborder AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_limorbor AS INTEGER     NO-UNDO.
    
    /* 1 - LIMITE 2 - BORDERO */
    
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-emprsts.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-proposta_limite_chq.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-contrato_limite_chq.        
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dados-avais.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dados_nota_pro_chq.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-proposta_bordero_dscchq.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dados_chqs_bordero.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-chqs_do_bordero.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dscchq_bordero_restricoes.
    

    DEFINE VARIABLE aux_dsmesref     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_nmcidade     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_nrcpfcgc     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_cdempres     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_dsdtraco     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_nmempres     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_nmprimtl     AS CHARACTER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE rel_nrdconta     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE rel_telefone     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_txdiaria     AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE rel_txdanual     AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE rel_txmensal     AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE rel_ddmvtolt     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE rel_aamvtolt     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE rel_dsmesref     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_nmextcop     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_qtdbolet     AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_totbolet     AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE rel_vlmedbol     AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE h-b1wgen0030     AS HANDLE      NO-UNDO.    
    DEFINE VARIABLE h-b1wgen9999     AS HANDLE      NO-UNDO.
    DEFINE VARIABLE rel_nmrescop     AS CHARACTER EXTENT 2 NO-UNDO.    
    DEFINE VARIABLE aux_par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_par_dsctrliq AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE aux_par_vlutiliz AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE rel_txnrdcid     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_vllimchq     AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE rel_dsdlinha     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_nmdaval1     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_dscpfav1     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_nmdcjav1     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_dscfcav1     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_dsendav1     AS CHARACTER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE rel_nmdaval2     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_dscpfav2     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_nmdcjav2     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_dscfcav2     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_dsendav2     AS CHARACTER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE tel_dtcalcul     AS DATE        NO-UNDO.
    DEFINE VARIABLE rel_dslimite     AS CHARACTER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE aux_dslinhax     AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_dslinhax     AS CHARACTER EXTENT 4 NO-UNDO.
    DEFINE VARIABLE rel_dsobserv     AS CHARACTER EXTENT 4 NO-UNDO.
    DEFINE VARIABLE rel_txqtdvig     AS CHARACTER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE rel_txjurmor     AS DECIMAL      NO-UNDO.
    DEFINE VARIABLE rel_dsjurmor     AS CHARACTER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE rel_txdmulta     AS DECIMAL      NO-UNDO.
    DEFINE VARIABLE rel_txmulext     AS CHARACTER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE rel_dsdmoeda     AS CHARACTER EXTENT 2 INIT "R$" NO-UNDO.
    DEFINE VARIABLE aux_dsemsnot     AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE rel_nmoperad     AS CHARACTER    NO-UNDO.
    DEFINE VARIABLE rel_vlborchq     AS DECIMAL      NO-UNDO.
    DEFINE VARIABLE rel_qtborchq     AS INTEGER      NO-UNDO.
    DEFINE VARIABLE rel_dsopecoo     AS CHARACTER    NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-emprsts.
    EMPTY TEMP-TABLE tt-proposta_limite_chq.
    EMPTY TEMP-TABLE tt-contrato_limite_chq.        
    EMPTY TEMP-TABLE tt-dados-avais.
    EMPTY TEMP-TABLE tt-dados_nota_pro_chq.
    EMPTY TEMP-TABLE tt-proposta_bordero_dscchq.
    EMPTY TEMP-TABLE tt-dados_chqs_bordero.
    EMPTY TEMP-TABLE tt-chqs_do_bordero.
    EMPTY TEMP-TABLE tt-dscchq_bordero_restricoes.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    IF  par_flgerlog  THEN
    DO:
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

        IF  par_idimpres = 1  THEN
            ASSIGN aux_dstransa = "Carregar dados para impressao completa de " +
                                  "limite de desconto de cheque".
        ELSE
        IF  par_idimpres = 2  THEN
            ASSIGN aux_dstransa = "Carregar dados para impressao do contrato " +
                                  "de limite de desconto de cheque".
        ELSE
        IF  par_idimpres = 3  THEN
            ASSIGN aux_dstransa = "Carregar dados para impressao da proposta " +
                                  "de limite de desconto de cheque".
        ELSE
        IF  par_idimpres = 4  THEN
            ASSIGN aux_dstransa = "Carregar dados para impressao da nota " +
                                  "promissória de limite de desconto de cheque".
        ELSE
        IF  par_idimpres = 5  THEN
            ASSIGN aux_dstransa = "Carregar dados para impressao completa " +
                                  "de bordero de desconto de cheque".
        ELSE
        IF  par_idimpres = 6  THEN
            ASSIGN aux_dstransa = "Carregar dados para impressao da proposta " +
                                  "de bordero de desconto de cheques".
        ELSE
        IF  par_idimpres = 7  THEN
            ASSIGN aux_dstransa = "Carregar dados para impressao dos cheques " +
                                  "de bordero de desconto de cheques".
        ELSE
        IF  par_idimpres = 9  THEN
            aux_dstransa = "Gerar impressao de demonstracao do cet".
        ELSE
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Tipo de impressao invalida."
                   aux_dstransa = "Carregar dados para impressao".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            IF  par_flgerlog  THEN
            DO:
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
            
            END.
                                  
            RETURN "NOK".
        END.
    END.

    
    /*  Busca dados da cooperativa  */
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapcop  THEN
    DO:
        ASSIGN aux_cdcritic = 651
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        IF  par_flgerlog  THEN
        DO:
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
                               
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT par_nrctrlim).
            
            IF  par_limorbor = 2  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrborder",
                                        INPUT "",
                                        INPUT par_nrborder).
        
        END.
        
        RETURN "NOK".                
    END.
        
    
    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapope  THEN
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
        DO:
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
                               
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT par_nrctrlim).
            
            IF  par_limorbor = 2  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrborder",
                                        INPUT "",
                                        INPUT par_nrborder).                             
        END.            
        
        RETURN "NOK".
    END.        

    ASSIGN aux_dsmesref = "Janeiro,Fevereiro,Marco,Abril,Maio,Junho," +
                          "Julho,Agosto,Setembro,Outubro,Novembro,Dezembro"
           aux_dsemsnot = SUBSTR(crapcop.nmcidade,1,15) + "," +
                          STRING(DAY(par_dtmvtolt),"99") + " de " +
                          ENTRY(MONTH(par_dtmvtolt),aux_dsmesref) +
                          " de " +
                          STRING(YEAR(par_dtmvtolt),"9999")           
           rel_dsmesref = ENTRY(MONTH(par_dtmvtolt),aux_dsmesref) 
           aux_dsdtraco = FILL("-",132)
           aux_nmcidade = TRIM(crapcop.nmcidade)
           rel_nmoperad = TRIM(crapope.nmoperad).

    /* Dados do associado */
    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta  
                       NO-LOCK NO-ERROR.

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
            DO:
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
            
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrctrlim",
                                        INPUT "",
                                        INPUT par_nrctrlim).
            
                IF  par_limorbor = 2  THEN
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "nrborder",
                                            INPUT "",
                                            INPUT par_nrborder).
            
            END.
            
        RETURN "NOK".
    END.


    IF  crapass.inpessoa = 1  THEN
    DO:
        ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999")
               rel_nrcpfcgc = STRING(rel_nrcpfcgc,"    xxx.xxx.xxx-xx").
           
        FIND crapttl WHERE 
             crapttl.cdcooper = par_cdcooper       AND
             crapttl.nrdconta = crapass.nrdconta   AND
             crapttl.idseqttl = 1 NO-LOCK NO-ERROR.

       

        IF  AVAIL crapttl  THEN
            ASSIGN aux_cdempres = crapttl.cdempres.
    END.
    ELSE
    DO:
        ASSIGN rel_nrcpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
               rel_nrcpfcgc = STRING(rel_nrcpfcgc,
                                     "xx.xxx.xxx/xxxx-xx").
            
        FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                           crapjur.nrdconta = crapass.nrdconta
                           NO-LOCK NO-ERROR.

        IF  AVAIL crapjur  THEN
            ASSIGN aux_cdempres = crapjur.cdempres.
    END.
        
    
    /* Dados da Empresa */
    FIND crapemp WHERE crapemp.cdcooper = par_cdcooper AND
                       crapemp.cdempres = aux_cdempres   
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapemp   THEN
        rel_nmempres = STRING(aux_cdempres,"99999") + " - NAO CADASTRADA.".
    ELSE
        rel_nmempres = STRING(aux_cdempres,"99999") + " - " + crapemp.nmresemp.  

         
    FIND FIRST craptfc WHERE 
               craptfc.cdcooper = par_cdcooper     AND
               craptfc.nrdconta = crapass.nrdconta  
               NO-LOCK NO-ERROR.  

      
    IF AVAIL craptfc THEN
    ASSIGN rel_telefone  = STRING(craptfc.nrdddtfc) + 
                           STRING(craptfc.nrtelefo).

               

    
    ASSIGN rel_nmprimtl = crapass.nmprimtl
           rel_nrdconta = crapass.nrdconta
           rel_nrcpfcgc = TRIM(rel_nrcpfcgc).






  RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.
    
    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Handle invalido para h-b1wgen9999.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        IF  par_flgerlog  THEN
        DO:
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
        
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT par_nrctrlim).
                                    
            IF  par_limorbor = 2  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrborder",
                                        INPUT "",
                                        INPUT par_nrborder).

        END.
        
        RETURN "NOK".                
    END.
  
    
    RUN divide-nome-coop IN h-b1wgen9999 (INPUT crapcop.nmextcop,
                                         OUTPUT rel_nmrescop[1],
                                         OUTPUT rel_nmrescop[2]).

    RUN busca_dados_limite_consulta (INPUT par_cdcooper,
                                     INPUT par_cdagenci, 
                                     INPUT par_nrdcaixa, 
                                     INPUT par_cdoperad,
                                     INPUT par_dtmvtolt,
                                     INPUT par_idorigem, 
                                     INPUT par_nrdconta,
                                     INPUT par_idseqttl, 
                                     INPUT par_nmdatela,
                                     INPUT par_nrctrlim,
                                     INPUT FALSE,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-dscchq_dados_limite,
                                    OUTPUT TABLE tt-dados-avais,
                                    OUTPUT TABLE tt-dados_dscchq).

    IF  RETURN-VALUE = "NOK"  THEN
    DO:
        DELETE PROCEDURE h-b1wgen9999.

        IF  par_flgerlog  THEN
        DO:
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
        
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT par_nrctrlim).

            IF  par_limorbor = 2  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrborder",
                                        INPUT "",
                                        INPUT par_nrborder).
        
        END.
    
        RETURN "NOK".
    END.    
                
    
    FIND tt-dscchq_dados_limite NO-LOCK NO-ERROR.

    IF  NOT AVAIL tt-dscchq_dados_limite  THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Registro de limite nao encontrado.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        DELETE PROCEDURE h-b1wgen9999.

        IF  par_flgerlog  THEN
        DO:
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
        
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT par_nrctrlim).

            IF  par_limorbor = 2  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrborder",
                                        INPUT "",
                                        INPUT par_nrborder).                   
        
        END.            
        
        RETURN "NOK".                
    END.

    
    RUN sistema/generico/procedures/b1wgen0030.p PERSISTENT SET h-b1wgen0030.

    IF  NOT VALID-HANDLE(h-b1wgen0030) THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Handle invalido para h-b1wgen0030.".
    
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
    
        IF  par_flgerlog  THEN
        DO:
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
    
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrctrlim",
                                    INPUT "",
                                    INPUT par_nrctrlim).

            IF  par_limorbor = 2  THEN
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrborder",
                                        INPUT "",
                                        INPUT par_nrborder).
    
        END.
        DELETE PROCEDURE h-b1wgen9999.
        RETURN "NOK".                
    END.

    RUN busca_total_descontos IN h-b1wgen0030 (INPUT par_cdcooper,
                                               INPUT par_cdagenci, 
                                               INPUT par_nrdcaixa, 
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl, 
                                               INPUT par_idorigem,
                                               INPUT par_nmdatela,
                                               INPUT FALSE, /* LOG */
                                               OUTPUT TABLE tt-tot_descontos). 

    DELETE PROCEDURE h-b1wgen0030.

    /* Limite de desconto de cheque */
    IF  par_limorbor = 1 THEN
    DO:
        FIND tt-dados_dscchq NO-LOCK NO-ERROR.

        IF  NOT AVAIL tt-dados_dscchq  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de limite craptab nao encontrado.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            IF  par_flgerlog  THEN
            DO:
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
    
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrctrlim",
                                        INPUT "",
                                        INPUT par_nrctrlim).
                                        
            END.            
        
            DELETE PROCEDURE h-b1wgen9999.
            RETURN "NOK".
        END.                
          
        ASSIGN aux_par_nrdconta = crapass.nrdconta
               aux_par_dsctrliq = ""
               aux_par_vlutiliz = 0.

        RUN saldo_utiliza IN h-b1wgen9999 (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nmdatela,
                                           INPUT par_idorigem,
                                           INPUT aux_par_nrdconta,
                                           INPUT par_idseqttl,
                                           INPUT par_dtmvtolt,
                                           INPUT par_dtmvtopr,
                                           INPUT aux_par_dsctrliq,
                                           INPUT par_inproces,
                                           INPUT FALSE, /*Consulta por cpf*/
                                          OUTPUT aux_par_vlutiliz,
                                          OUTPUT TABLE tt-erro).
        
        IF  RETURN-VALUE = "NOK"  THEN
        DO:
            IF  par_flgerlog  THEN
            DO:
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
    
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrctrlim",
                                        INPUT "",
                                        INPUT par_nrctrlim).
                                        
            END.                
            
            DELETE PROCEDURE h-b1wgen9999.
            
            RETURN "NOK".
        END.
        
        IF   LENGTH(TRIM(crapass.tpdocptl)) > 0   THEN
             rel_txnrdcid = crapass.tpdocptl + ": " + SUBSTR(TRIM(crapass.nrdocptl),1,15).
        ELSE 
             rel_txnrdcid = "".  

        FIND FIRST tt-tot_descontos NO-LOCK NO-ERROR.

        /*  Limite de desconto de cheque  */ 
        ASSIGN rel_vllimchq = tt-tot_descontos.vllimchq. 

        /* Linha de Desconto */ 
        ASSIGN rel_dsdlinha = STRING(tt-dscchq_dados_limite.codlinha,"999")
                              + " - " + tt-dscchq_dados_limite.dsdlinha.

        /* Dados do 1o Avalista  */
        FIND FIRST tt-dados-avais NO-LOCK NO-ERROR.

        IF  AVAIL tt-dados-avais  THEN
            ASSIGN rel_nmdaval1    = IF  tt-dados-avais.nmdavali = ""
                                         THEN FILL("_",40)
                                         ELSE
                                         tt-dados-avais.nmdavali
                   rel_dscpfav1    = IF  tt-dados-avais.nrcpfcgc > 0 THEN
                                         "C.P.F. " +
                                         STRING(STRING(tt-dados-avais.nrcpfcgc,
                                         "99999999999"),"xxx.xxx.xxx-xx")                 
                                     ELSE IF  tt-dados-avais.nrdocava = "" THEN
                                         FILL("_",40)
                                     ELSE tt-dados-avais.nrdocava
                   rel_nmdcjav1    = IF  tt-dados-avais.nmconjug = ""  THEN
                                         FILL("_",40)
                                     ELSE tt-dados-avais.nmconjug
                   rel_dscfcav1    = IF tt-dados-avais.nrcpfcjg > 0 THEN
                                        "C.P.F. " +
                                        STRING(STRING(tt-dados-avais.nrcpfcjg,
                                        "99999999999"),"xxx.xxx.xxx-xx")                 
                                     ELSE IF  tt-dados-avais.nrdoccjg = ""  THEN
                                         FILL("_",40)
                                     ELSE tt-dados-avais.nrdoccjg
                   rel_dsendav1[1] = tt-dados-avais.dsendre1
                   rel_dsendav1[2] = tt-dados-avais.dsendre2.
        ELSE
            ASSIGN rel_nmdaval1 = FILL("_",40)
                   rel_dscpfav1 = FILL("_",40)
                   rel_nmdcjav1 = FILL("_",40)
                   rel_dscfcav1 = FILL("_",40).

        /* Dados do 2o Avalista  */
        FIND NEXT tt-dados-avais NO-LOCK NO-ERROR.

        IF   AVAIL tt-dados-avais  THEN
             ASSIGN rel_nmdaval2    = IF   tt-dados-avais.nmdavali = ""
                                           THEN FILL("_",40)
                                      ELSE tt-dados-avais.nmdavali
                    rel_dscpfav2    = IF   tt-dados-avais.nrcpfcgc > 0 THEN
                                           "C.P.F. " +
                                           STRING(STRING(tt-dados-avais.nrcpfcgc,
                                           "99999999999"),"xxx.xxx.xxx-xx")
                                      ELSE IF tt-dados-avais.nrdocava = "" THEN
                                           FILL("_",40)
                                      ELSE tt-dados-avais.nrdocava
                    rel_nmdcjav2    = IF   tt-dados-avais.nmconjug = ""  THEN 
                                           FILL("_",40)
                                      ELSE tt-dados-avais.nmconjug
                    rel_dscfcav2    = IF   tt-dados-avais.nrcpfcjg > 0 THEN
                                           "C.P.F. " +
                                           STRING(STRING(tt-dados-avais.nrcpfcjg,
                                           "99999999999"),"xxx.xxx.xxx-xx")                 
                                      ELSE IF tt-dados-avais.nrdoccjg = ""  THEN
                                           FILL("_",40)
                                      ELSE tt-dados-avais.nrdoccjg
                    rel_dsendav2[1] = tt-dados-avais.dsendre1
                    rel_dsendav2[2] = tt-dados-avais.dsendre2.         
        ELSE
             ASSIGN rel_nmdaval2 = FILL("_",40)
                    rel_dscpfav2 = FILL("_",40)
                    rel_nmdcjav2 = FILL("_",40)
                    rel_dscfcav2 = FILL("_",40).

        IF   tel_dtcalcul = ?   THEN
             tel_dtcalcul = par_dtmvtolt.

        /*  Valor do limite .......................................... */
        RUN valor-extenso IN h-b1wgen9999 
                          (INPUT tt-dscchq_dados_limite.vllimite, 
                           INPUT 53, 
                           INPUT 70, 
                           INPUT "M", 
                           OUTPUT rel_dslimite[1], 
                           OUTPUT rel_dslimite[2]).

        ASSIGN rel_dslimite[1] = "(" + LC(rel_dslimite[1]).

        IF   LENGTH(TRIM(rel_dslimite[2])) = 0   THEN
             ASSIGN rel_dslimite[1] = rel_dslimite[1] + ")" + FILL("*",31)
                    rel_dslimite[2] = "".
        ELSE
             ASSIGN rel_dslimite[1] = rel_dslimite[1] + FILL("*",31)
                    rel_dslimite[2] = LC(rel_dslimite[2]) + ")".

        ASSIGN aux_dslinhax = "Inscrita no CNPJ " + 
                              STRING(STRING(crapcop.nrdocnpj,
                                            "99999999999999"),
                              "xx.xxx.xxx/xxxx-xx") + ", Inscricao " + 
                              "Estadual Isenta, estabelecida na " +  
                              crapcop.dsendcop + ", Nr. " + 
                              STRING(crapcop.nrendcop) +
                              ", Bairro " + crapcop.nmbairro + ", " +
                              aux_nmcidade + ", " + crapcop.cdufdcop.
                  
        RUN quebra-str IN h-b1wgen9999 
                                (INPUT aux_dslinhax, 
                                 INPUT 69, INPUT 69, 
                                 INPUT 69, INPUT 69, 
                                 OUTPUT rel_dslinhax[1], 
                                 OUTPUT rel_dslinhax[2],
                                 OUTPUT rel_dslinhax[3], 
                                 OUTPUT rel_dslinhax[4]).

        /*  Quantidade de dias para vigencia.................... */
        RUN valor-extenso IN h-b1wgen9999
                             (INPUT tt-dscchq_dados_limite.qtdiavig, 
                              INPUT 31, 
                              INPUT 0, 
                              INPUT "I", 
                             OUTPUT rel_txqtdvig[1], 
                             OUTPUT rel_txqtdvig[2]).

        ASSIGN rel_txqtdvig[1] = "(" + LC(rel_txqtdvig[1]) + ") dias.".

        /*  Taxa de juros de mora ............................. */
        ASSIGN rel_txjurmor = ROUND((EXP(1 + 
                 (tt-dscchq_dados_limite.txjurmor / 100),12) - 1) * 100,2).

        RUN valor-extenso IN h-b1wgen9999 
                             (INPUT rel_txjurmor, 
                              INPUT 52, 
                              INPUT 37, 
                              INPUT "P",
                              OUTPUT rel_dsjurmor[1], 
                              OUTPUT rel_dsjurmor[2]).

       ASSIGN rel_dsjurmor[1] = STRING(rel_txjurmor,"999.999999") + "% (" +
                                 LC(rel_dsjurmor[1]).

        IF  LENGTH(TRIM(rel_dsjurmor[2])) = 0   THEN
             ASSIGN rel_dsjurmor[1] = rel_dsjurmor[1] + ")" + FILL("*",32)
                    rel_dsjurmor[2] = "ao ano; (" +
                                  STRING(tt-dscchq_dados_limite.txjurmor,
                                         "999.999999") + 
                                         " % a.m., capitalizados mensalmente)".
        ELSE
             ASSIGN rel_dsjurmor[1] = rel_dsjurmor[1] + FILL("*",32)
                    rel_dsjurmor[2] = LC(rel_dsjurmor[2]) + " ao ano); (" +
                                  STRING(tt-dscchq_dados_limite.txjurmor,
                                             "999.999999") + 
                                             " % a.m., capitalizados mensalmente)".

        ASSIGN rel_txdmulta = tt-dados_dscchq.pcdmulta.

        /*  Taxa de multa por extenso ................................ */
        RUN valor-extenso IN h-b1wgen9999 
                             (INPUT rel_txdmulta, 
                              INPUT 36, 
                              INPUT 50, 
                              INPUT "P",
                              OUTPUT rel_txmulext[1], 
                              OUTPUT rel_txmulext[2]).

        ASSIGN rel_txmulext[1] = "(" + LC(rel_txmulext[1]).

        IF   LENGTH(TRIM(rel_txmulext[2])) = 0   THEN
             ASSIGN rel_txmulext[1] = rel_txmulext[1] + ")" 
                    rel_txmulext[2] = "".
        ELSE
             ASSIGN rel_txmulext[1] = rel_txmulext[1] 
                    rel_txmulext[2] = LC(rel_txmulext[2]) + ")".
                    
        /* Trata Observacoes */ 
        RUN quebra-str IN h-b1wgen9999 
                        (INPUT tt-dscchq_dados_limite.dsobserv, 
                         INPUT 94, 
                         INPUT 94,
                         INPUT 94,
                         INPUT 94,        
                         OUTPUT rel_dsobserv[1], 
                         OUTPUT rel_dsobserv[2],
                         OUTPUT rel_dsobserv[3],
                         OUTPUT rel_dsobserv[4]).                        
    END.
    ELSE
    /* Bordero de desconto de cheque */
    IF  par_limorbor = 2  THEN    
    DO: 
        RUN busca_dados_bordero (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_idorigem,
                                 INPUT par_nrdconta,
                                 INPUT par_idseqttl,
                                 INPUT par_nmdatela,
                                 INPUT par_nrborder,
                                 INPUT "M",
                                 INPUT FALSE,
                                 OUTPUT TABLE tt-erro,
                                 OUTPUT TABLE tt-dscchq_dados_bordero).
        
        IF  RETURN-VALUE = "NOK"  THEN
        DO:
            IF  par_flgerlog  THEN
            DO:
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
    
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrctrlim",
                                        INPUT "",
                                        INPUT par_nrctrlim).
                
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrborder",
                                        INPUT "",
                                        INPUT par_nrborder).
    
            END.                    

            DELETE PROCEDURE h-b1wgen9999.
            RETURN "NOK".

        END.    
          
        RUN busca_cheques_bordero (INPUT par_cdcooper,
                                   INPUT par_dtmvtolt,
                                   INPUT par_nrborder,
                                   INPUT par_nrdconta,
                                  OUTPUT TABLE tt-chqs_do_bordero,
                                  OUTPUT TABLE tt-dscchq_bordero_restricoes).
                                
        FIND FIRST tt-dscchq_dados_bordero NO-LOCK NO-ERROR.
     
        RUN busca_dados_limite (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa, 
                                INPUT par_cdoperad,
                                INPUT par_dtmvtolt,
                                INPUT par_idorigem, 
                                INPUT par_nrdconta,
                                INPUT par_idseqttl, 
                                INPUT par_nmdatela,
                                INPUT tt-dscchq_dados_bordero.nrctrlim,
                                INPUT "M", 
                                INPUT FALSE,
                                OUTPUT TABLE tt-erro,
                                OUTPUT TABLE tt-dscchq_dados_limite,
                                OUTPUT TABLE tt-dados_dscchq).

        IF  RETURN-VALUE = "NOK"  THEN                        
        DO:
            IF  par_flgerlog  THEN
            DO:
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
    
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrctrlim",
                                        INPUT "",
                                        INPUT par_nrctrlim).
                
                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrborder",
                                        INPUT "",
                                        INPUT par_nrborder).
    
            END.                
            DELETE PROCEDURE h-b1wgen9999.
            RETURN "NOK".
        END.    
        
        FIND FIRST tt-tot_descontos NO-LOCK NO-ERROR.
        
        ASSIGN rel_vlborchq = 0
               rel_qtborchq = 0.
        
        FOR EACH tt-chqs_do_bordero NO-LOCK:
            
            ASSIGN rel_vlborchq = rel_vlborchq + tt-chqs_do_bordero.vlcheque
                   rel_qtborchq = rel_qtborchq + 1.
        END.
        
        ASSIGN rel_txdiaria = ROUND((EXP(1 + 
                                   (tt-dscchq_dados_bordero.txmensal / 100),
                                    1 / 30) - 1) * 100,7)
               rel_txdanual = ROUND((EXP(1 + 
                                  (tt-dscchq_dados_bordero.txmensal / 100),
                                   12) - 1) * 100,6)
               rel_txmensal = tt-dscchq_dados_bordero.txmensal
               rel_ddmvtolt = DAY(par_dtmvtolt)
               rel_aamvtolt = YEAR(par_dtmvtolt)
               rel_nmextcop = TRIM(crapcop.nmextcop)
               rel_dsopecoo = tt-dscchq_dados_bordero.dsopecoo.

    END.

    DELETE PROCEDURE h-b1wgen9999.
    
    FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                       crapage.cdagenci = crapass.cdagenci NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapage THEN
        RETURN "NOK".

    IF  par_idimpres = 1  THEN /* Limite - COMPLETA */
    DO:

        RUN carrega_dados_proposta_limite
                                  (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT par_dtmvtopr,
                                   INPUT par_nrdconta,
                                   INPUT par_idorigem,
                                   INPUT par_idseqttl,
                                   INPUT par_nmdatela,
                                   INPUT par_inproces,
                                   INPUT TRIM(crapcop.nmextcop),
                                   INPUT rel_vllimchq,
                                   INPUT tt-tot_descontos.vllimtit,
                                   INPUT rel_nmempres,
                                   INPUT rel_dsdlinha,
                                   INPUT aux_par_vlutiliz,
                                   INPUT rel_dsobserv[1],
                                   INPUT rel_dsobserv[2],
                                   INPUT rel_dsobserv[3],
                                   INPUT rel_dsobserv[4],
                                   INPUT rel_dsmesref,
                                   INPUT TRIM(crapcop.nmcidade),
                                   INPUT TRIM(crapcop.nmrescop),
                                   INPUT rel_telefone,
                                   INPUT tt-dscchq_dados_limite.dsdbens1,
                                   INPUT tt-dscchq_dados_limite.dsdbens2,
                                   INPUT tt-dscchq_dados_limite.vlsalari,
                                   INPUT tt-dscchq_dados_limite.vlsalcon,
                                   INPUT tt-dscchq_dados_limite.vloutras,
                                   INPUT tt-dscchq_dados_limite.nrctrlim,
                                   INPUT tt-dscchq_dados_limite.vllimite,
                                   INPUT tt-dscchq_dados_limite.dsramati,
                                   INPUT tt-dscchq_dados_limite.vlfatura,
                                   INPUT tt-dscchq_dados_limite.vlmedchq,
                                   INPUT rel_nmoperad,
                                   INPUT rel_nmrescop[1],
                                   INPUT rel_nmrescop[2],
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-emprsts,
                                  OUTPUT TABLE tt-proposta_limite_chq).
   
        IF  RETURN-VALUE = "NOK"  THEN
        DO:
            IF  par_flgerlog  THEN
            DO:
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

                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrctrlim",
                                        INPUT "",
                                        INPUT par_nrctrlim).    
            END.
                                                  
            RETURN "NOK".
        END.
            
        RUN carrega_dados_contrato_limite
                                     (INPUT crapage.nmcidade,
                                      INPUT crapcop.cdufdcop,
                                      INPUT tt-dscchq_dados_limite.nrctrlim,
                                      INPUT crapcop.nmextcop,
                                      INPUT crapass.cdagenci,
                                      INPUT rel_dslinhax[1],
                                      INPUT rel_dslinhax[2],
                                      INPUT rel_dslinhax[3],
                                      INPUT rel_dslinhax[4],
                                      INPUT rel_nmprimtl[1],
                                      INPUT rel_nmprimtl[2],
                                      INPUT rel_nrdconta,
                                      INPUT rel_nrcpfcgc,
                                      INPUT rel_txnrdcid,
                                      INPUT rel_dsdmoeda[1],
                                      INPUT tt-dscchq_dados_limite.vllimite,
                                      INPUT rel_dslimite[1],
                                      INPUT rel_dslimite[2],
                                      INPUT rel_dsdlinha,
                                      INPUT tt-dscchq_dados_limite.qtdiavig,
                                      INPUT rel_txqtdvig[1],
                                      INPUT rel_txqtdvig[2],
                                      INPUT rel_dsjurmor[1],
                                      INPUT rel_dsjurmor[2],
                                      INPUT rel_txdmulta,
                                      INPUT rel_txmulext[1],
                                      INPUT rel_txmulext[2],
                                      INPUT rel_nmrescop[1],
                                      INPUT rel_nmrescop[2],
                                      INPUT rel_nmdaval1,
                                      INPUT rel_nmdcjav1,
                                      INPUT rel_dscpfav1,
                                      INPUT rel_dscfcav1,
                                      INPUT rel_nmdaval2,
                                      INPUT rel_nmdcjav2,
                                      INPUT rel_dscpfav2,
                                      INPUT rel_dscfcav2,
                                      INPUT rel_nmoperad,
                                      OUTPUT TABLE tt-contrato_limite).

        RUN carrega_dados_nota_promissoria  
                                  (INPUT par_cdcooper,
                                   INPUT crapass.cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_nrdconta,
                                   INPUT rel_nrcpfcgc,
                                   INPUT par_nrctrlim,
                                   INPUT tt-dscchq_dados_limite.vllimite,
                                   INPUT par_dtmvtolt,
                                   INPUT aux_dsmesref,
                                   INPUT aux_dsemsnot,
                                   INPUT rel_dsmesref,
                                   INPUT TRIM(crapcop.nmrescop),
                                   INPUT TRIM(crapcop.nmextcop),
                                   INPUT TRIM(STRING(crapcop.nrdocnpj)),
                                   INPUT rel_dsdmoeda[1],
                                   INPUT crapass.nmprimtl,
                                  INPUT-OUTPUT TABLE tt-dados-avais,
                                  OUTPUT TABLE tt-dados_nota_pro_chq,
                                  OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE = "NOK"  THEN
        DO:
            IF  par_flgerlog  THEN
            DO:
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

                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrctrlim",
                                        INPUT "",
                                        INPUT par_nrctrlim).    
            END.
                                                  
            RETURN "NOK".
        END.
        
    END.
    ELSE
    IF  par_idimpres = 2  THEN /** Impressao CONTRATO LIMITE **/
    DO: 
        RUN carrega_dados_contrato_limite
                                     (INPUT crapage.nmcidade,
                                      INPUT crapcop.cdufdcop,
                                      INPUT tt-dscchq_dados_limite.nrctrlim,
                                      INPUT crapcop.nmextcop,
                                      INPUT crapass.cdagenci,
                                      INPUT rel_dslinhax[1],
                                      INPUT rel_dslinhax[2],
                                      INPUT rel_dslinhax[3],
                                      INPUT rel_dslinhax[4],
                                      INPUT rel_nmprimtl[1],
                                      INPUT rel_nmprimtl[2],
                                      INPUT rel_nrdconta,
                                      INPUT rel_nrcpfcgc,
                                      INPUT rel_txnrdcid,
                                      INPUT rel_dsdmoeda[1],
                                      INPUT tt-dscchq_dados_limite.vllimite,
                                      INPUT rel_dslimite[1],
                                      INPUT rel_dslimite[2],
                                      INPUT rel_dsdlinha,
                                      INPUT tt-dscchq_dados_limite.qtdiavig,
                                      INPUT rel_txqtdvig[1],
                                      INPUT rel_txqtdvig[2],
                                      INPUT rel_dsjurmor[1],
                                      INPUT rel_dsjurmor[2],
                                      INPUT rel_txdmulta,
                                      INPUT rel_txmulext[1],
                                      INPUT rel_txmulext[2],
                                      INPUT rel_nmrescop[1],
                                      INPUT rel_nmrescop[2],
                                      INPUT rel_nmdaval1,
                                      INPUT rel_nmdcjav1,
                                      INPUT rel_dscpfav1,
                                      INPUT rel_dscfcav1,
                                      INPUT rel_nmdaval2,
                                      INPUT rel_nmdcjav2,
                                      INPUT rel_dscpfav2,
                                      INPUT rel_dscfcav2,
                                      INPUT rel_nmoperad,
                                      OUTPUT TABLE tt-contrato_limite).
    END.
    ELSE
    IF  par_idimpres = 3  THEN /** Impressao PROPOSTA **/
    DO: 
        RUN carrega_dados_proposta_limite
                                  (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT par_dtmvtopr,
                                   INPUT par_nrdconta,
                                   INPUT par_idorigem,
                                   INPUT par_idseqttl,
                                   INPUT par_nmdatela,
                                   INPUT par_inproces,
                                   INPUT TRIM(crapcop.nmextcop),
                                   INPUT rel_vllimchq,
                                   INPUT tt-tot_descontos.vllimtit,
                                   INPUT rel_nmempres,
                                   INPUT rel_dsdlinha,
                                   INPUT aux_par_vlutiliz,
                                   INPUT rel_dsobserv[1],
                                   INPUT rel_dsobserv[2],
                                   INPUT rel_dsobserv[3],
                                   INPUT rel_dsobserv[4],
                                   INPUT rel_dsmesref,
                                   INPUT TRIM(crapcop.nmcidade),
                                   INPUT TRIM(crapcop.nmrescop),
                                   INPUT rel_telefone,
                                   INPUT tt-dscchq_dados_limite.dsdbens1,
                                   INPUT tt-dscchq_dados_limite.dsdbens2,
                                   INPUT tt-dscchq_dados_limite.vlsalari,
                                   INPUT tt-dscchq_dados_limite.vlsalcon,
                                   INPUT tt-dscchq_dados_limite.vloutras,
                                   INPUT tt-dscchq_dados_limite.nrctrlim,
                                   INPUT tt-dscchq_dados_limite.vllimite,
                                   INPUT tt-dscchq_dados_limite.dsramati,
                                   INPUT tt-dscchq_dados_limite.vlfatura,
                                   INPUT tt-dscchq_dados_limite.vlmedchq,
                                   INPUT rel_nmoperad,
                                   INPUT rel_nmrescop[1],
                                   INPUT rel_nmrescop[2],
                                  OUTPUT TABLE tt-erro,
                                  OUTPUT TABLE tt-emprsts,
                                  OUTPUT TABLE tt-proposta_limite_chq).
    
        IF  RETURN-VALUE = "NOK"  THEN
            DO:
                IF  par_flgerlog  THEN
                    DO:
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

                        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                INPUT "nrctrlim",
                                                INPUT "",
                                                INPUT par_nrctrlim).    
                    END.
                                                      
                RETURN "NOK".
            END.
    END.
    ELSE
    IF  par_idimpres = 4  THEN /** Impressao Nota Promissoria **/
    DO:           
        RUN carrega_dados_nota_promissoria  
                                  (INPUT par_cdcooper,
                                   INPUT crapass.cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT par_nrdconta,
                                   INPUT rel_nrcpfcgc,
                                   INPUT par_nrctrlim,
                                   INPUT tt-dscchq_dados_limite.vllimite,
                                   INPUT par_dtmvtolt,
                                   INPUT aux_dsmesref,
                                   INPUT aux_dsemsnot,
                                   INPUT rel_dsmesref,
                                   INPUT TRIM(crapcop.nmrescop),
                                   INPUT TRIM(crapcop.nmextcop),
                                   INPUT TRIM(STRING(crapcop.nrdocnpj)),
                                   INPUT rel_dsdmoeda[1],
                                   INPUT crapass.nmprimtl,
                                  INPUT-OUTPUT TABLE tt-dados-avais,
                                  OUTPUT TABLE tt-dados_nota_pro_chq,
                                  OUTPUT TABLE tt-erro).
                                  
        IF  RETURN-VALUE = "NOK"  THEN
        DO:
            IF  par_flgerlog  THEN
            DO:
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

                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrctrlim",
                                        INPUT "",
                                        INPUT par_nrctrlim).    
            END.
                                              
            RETURN "NOK".
        END.
    END.
    ELSE
    IF  par_idimpres = 5  THEN /** Impressao Bordero Completa **/
    DO:   
        RUN carrega_dados_proposta_bordero 
                              (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nrdconta,
                               INPUT par_dtmvtolt,
                               INPUT par_dtmvtopr,
                               INPUT par_idorigem,
                               INPUT par_idseqttl,
                               INPUT par_nmdatela,
                               INPUT par_inproces,
                               INPUT rel_telefone,
                               INPUT tt-dscchq_dados_limite.dsdbens1,
                               INPUT tt-dscchq_dados_limite.dsdbens2,
                               INPUT tt-dscchq_dados_limite.vlsalari,
                               INPUT tt-dscchq_dados_limite.vlsalcon,
                               INPUT tt-dscchq_dados_limite.vloutras,
                               INPUT par_nrctrlim,
                               INPUT par_nrborder,
                               INPUT tt-dscchq_dados_limite.vllimite,
                               INPUT rel_dsobserv[1],
                               INPUT rel_dsobserv[2],
                               INPUT rel_dsobserv[3],
                               INPUT rel_dsobserv[4],
                               INPUT tt-tot_descontos.vllimchq,
                               INPUT tt-tot_descontos.vllimtit,
                               INPUT rel_nmempres,
                               INPUT TRIM(crapcop.nmextcop),
                               INPUT tt-dscchq_dados_limite.dsramati,
                               INPUT tt-dscchq_dados_limite.vlfatura,
                               INPUT rel_dsmesref,
                               INPUT TRIM(crapcop.nmrescop),
                               INPUT TRIM(crapcop.nmcidade),
                               INPUT rel_qtborchq,
                               INPUT rel_vlborchq,
                              OUTPUT TABLE tt-proposta_bordero_dscchq,
                              OUTPUT TABLE tt-emprsts,
                              OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE = "NOK"  THEN
        DO:
            IF  par_flgerlog  THEN
            DO:
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

                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrborder",
                                        INPUT "",
                                        INPUT par_nrborder).    
            END.
                                              
            RETURN "NOK".
        END.

        RUN carrega_dados_bordero_cheques
                       (INPUT par_cdcooper, 
                        INPUT crapass.cdagenci, 
                        INPUT par_nrdconta, 
                        INPUT par_dtmvtolt, 
                        INPUT par_nrctrlim, 
                        INPUT par_nrborder,
                        INPUT rel_txdiaria,
                        INPUT rel_txmensal,
                        INPUT rel_txdanual,
                        INPUT tt-dscchq_dados_limite.vllimite,
                        INPUT rel_ddmvtolt,
                        INPUT rel_dsmesref,
                        INPUT rel_aamvtolt,
                        INPUT crapass.nmprimtl,
                        INPUT rel_nmrescop[1],
                        INPUT rel_nmrescop[2],
                        INPUT TRIM(crapcop.nmcidade),
                        INPUT rel_nmoperad,
                        INPUT rel_dsopecoo,
                        OUTPUT TABLE tt-dados_chqs_bordero,
                       OUTPUT TABLE tt-chqs_do_bordero,
                       OUTPUT TABLE tt-dscchq_bordero_restricoes).
        
    END.
    ELSE
    IF  par_idimpres = 6  THEN /** Impressao Proposta de bordero **/
    DO:       
        RUN carrega_dados_proposta_bordero 
                              (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT par_cdoperad,
                               INPUT par_nrdconta,
                               INPUT par_dtmvtolt,
                               INPUT par_dtmvtopr,
                               INPUT par_idorigem,
                               INPUT par_idseqttl,
                               INPUT par_nmdatela,
                               INPUT par_inproces,
                               INPUT rel_telefone,
                               INPUT tt-dscchq_dados_limite.dsdbens1,
                               INPUT tt-dscchq_dados_limite.dsdbens2,
                               INPUT tt-dscchq_dados_limite.vlsalari,
                               INPUT tt-dscchq_dados_limite.vlsalcon,
                               INPUT tt-dscchq_dados_limite.vloutras,
                               INPUT par_nrctrlim,
                               INPUT par_nrborder,
                               INPUT tt-dscchq_dados_limite.vllimite,
                               INPUT rel_dsobserv[1],
                               INPUT rel_dsobserv[2],
                               INPUT rel_dsobserv[3],
                               INPUT rel_dsobserv[4],
                               INPUT tt-tot_descontos.vllimchq,
                               INPUT tt-tot_descontos.vllimtit,
                               INPUT rel_nmempres,
                               INPUT TRIM(crapcop.nmextcop),
                               INPUT tt-dscchq_dados_limite.dsramati,
                               INPUT tt-dscchq_dados_limite.vlfatura,
                               INPUT rel_dsmesref,
                               INPUT TRIM(crapcop.nmrescop),
                               INPUT TRIM(crapcop.nmcidade),
                               INPUT rel_qtborchq,
                               INPUT rel_vlborchq,                                                             
                               OUTPUT TABLE tt-proposta_bordero_dscchq,
                              OUTPUT TABLE tt-emprsts,
                              OUTPUT TABLE tt-erro).
                                  
        IF  RETURN-VALUE = "NOK"  THEN
        DO:
            IF  par_flgerlog  THEN
            DO:
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

                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrborder",
                                        INPUT "",
                                        INPUT par_nrborder).    
            END.
                                                  
            RETURN "NOK".
        END.
    END.        
    ELSE
    IF  par_idimpres = 7  THEN /** Impressao dos cheques do bordero **/
    DO: 
        RUN carrega_dados_bordero_cheques
                       (INPUT par_cdcooper, 
                        INPUT crapass.cdagenci, 
                        INPUT par_nrdconta, 
                        INPUT par_dtmvtolt, 
                        INPUT par_nrctrlim, 
                        INPUT par_nrborder,
                        INPUT rel_txdiaria,
                        INPUT rel_txmensal,
                        INPUT rel_txdanual,
                        INPUT tt-dscchq_dados_limite.vllimite,
                        INPUT rel_ddmvtolt,
                        INPUT rel_dsmesref,
                        INPUT rel_aamvtolt,
                        INPUT crapass.nmprimtl,
                        INPUT rel_nmrescop[1],
                        INPUT rel_nmrescop[2],
                        INPUT TRIM(crapcop.nmcidade),
                        INPUT rel_nmoperad,
                        INPUT rel_dsopecoo,
                       OUTPUT TABLE tt-dados_chqs_bordero,
                       OUTPUT TABLE tt-chqs_do_bordero,
                       OUTPUT TABLE tt-dscchq_bordero_restricoes).

        IF  RETURN-VALUE = "NOK"  THEN
        DO:
            IF  par_flgerlog  THEN
            DO:
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

                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrborder",
                                        INPUT "",
                                        INPUT par_nrborder).    
            END.
                                              
            RETURN "NOK".
        END.
    END.
    ELSE
    IF  par_idimpres = 9 THEN /* CET */
    DO:
        RUN carrega_dados_contrato_limite (INPUT crapage.nmcidade,
                                           INPUT crapcop.cdufdcop,
                                           INPUT tt-dscchq_dados_limite.nrctrlim,
                                           INPUT crapcop.nmextcop,
                                           INPUT crapass.cdagenci,
                                           INPUT rel_dslinhax[1],
                                           INPUT rel_dslinhax[2],
                                           INPUT rel_dslinhax[3],
                                           INPUT rel_dslinhax[4],
                                           INPUT rel_nmprimtl[1],
                                           INPUT rel_nmprimtl[2],
                                           INPUT rel_nrdconta,
                                           INPUT rel_nrcpfcgc,
                                           INPUT rel_txnrdcid,
                                           INPUT rel_dsdmoeda[1],
                                           INPUT tt-dscchq_dados_limite.vllimite,
                                           INPUT rel_dslimite[1],
                                           INPUT rel_dslimite[2],
                                           INPUT rel_dsdlinha,
                                           INPUT tt-dscchq_dados_limite.qtdiavig,
                                           INPUT rel_txqtdvig[1],
                                           INPUT rel_txqtdvig[2],
                                           INPUT rel_dsjurmor[1],
                                           INPUT rel_dsjurmor[2],
                                           INPUT rel_txdmulta,
                                           INPUT rel_txmulext[1],
                                           INPUT rel_txmulext[2],
                                           INPUT rel_nmrescop[1],
                                           INPUT rel_nmrescop[2],
                                           INPUT rel_nmdaval1,
                                           INPUT rel_nmdcjav1,
                                           INPUT rel_dscpfav1,
                                           INPUT rel_dscfcav1,
                                           INPUT rel_nmdaval2,
                                           INPUT rel_nmdcjav2,
                                           INPUT rel_dscpfav2,
                                           INPUT rel_dscfcav2,
                                           INPUT rel_nmoperad,
                                           OUTPUT TABLE tt-contrato_limite).

        IF  RETURN-VALUE <> "OK"  THEN
            DO:
                IF  par_flgerlog  THEN
                    DO:
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
        
                        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                                INPUT "nrctrlim",
                                                INPUT "",
                                                INPUT par_nrctrlim).    
                    END.
                RETURN "NOK".
            END.
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
                  
        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                INPUT "nrctrlim",
                                INPUT "",
                                INPUT par_nrctrlim).

        IF  par_limorbor = 2  THEN
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrborder",
                                    INPUT "",
                                    INPUT par_nrborder).
    
    END.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
          Carrega dados para a impressao da proposta de bordero            
*****************************************************************************/
PROCEDURE carrega_dados_proposta_bordero:
                                                       
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtopr AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_inproces AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_telefone AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdeben1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdeben2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlsalari AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlsalcon AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vloutras AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctrlim AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrborder AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vllimpro AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsobser1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsobser2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsobser3 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsobser4 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_vllimchq AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vllimtit AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmempres AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmextcop AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsramati AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlfatura AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsmesref AS CHARACTER   NO-UNDO. 
    DEFINE INPUT  PARAMETER par_nmrescop AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmcidade AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_qtborchq AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlborchq AS DECIMAL     NO-UNDO.

    DEFINE OUTPUT PARAMETER TABLE FOR tt-proposta_bordero_dscchq.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-emprsts.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.

    DEFINE VARIABLE h-b1wgen0001 AS HANDLE              NO-UNDO.
    DEFINE VARIABLE h-b1wgen0002 AS HANDLE              NO-UNDO.
    DEFINE VARIABLE h-b1wgen0004 AS HANDLE              NO-UNDO.
    DEFINE VARIABLE h-b1wgen0006 AS HANDLE              NO-UNDO.
    DEFINE VARIABLE h-b1wgen0021 AS HANDLE              NO-UNDO.
    DEFINE VARIABLE h-b1wgen0028 AS HANDLE              NO-UNDO.    
    DEFINE VARIABLE rel_dsagenci AS CHARACTER           NO-UNDO.
    DEFINE VARIABLE rel_vlaplica AS DECIMAL             NO-UNDO.
    DEFINE VARIABLE aux_vltotccr AS DECIMAL             NO-UNDO.
    DEFINE VARIABLE aux_dstipcta AS CHARACTER           NO-UNDO.
    DEFINE VARIABLE aux_dssitdct AS CHARACTER           NO-UNDO.
    DEFINE VARIABLE aux_vlsmdtri AS DECIMAL             NO-UNDO.
    DEFINE VARIABLE tot_vlsdeved AS DECIMAL             NO-UNDO.
    DEFINE VARIABLE tot_vlpreemp AS DECIMAL             NO-UNDO.
    DEFINE VARIABLE aux_vlcaptal AS DECIMAL             NO-UNDO.
    DEFINE VARIABLE aux_vlprepla AS DECIMAL             NO-UNDO.
    DEFINE VARIABLE aux_vlsdrdpp AS DECIMAL DECIMALS 8  NO-UNDO.
    DEFINE VARIABLE rel_vlmeddsc AS DECIMAL             NO-UNDO.
    DEFINE VARIABLE rel_vlslddsc AS DECIMAL             NO-UNDO.
    DEFINE VARIABLE rel_qtdscsld AS DECIMAL             NO-UNDO.
    DEFINE VARIABLE rel_vlmaxdsc AS DECIMAL             NO-UNDO.
    DEFINE VARIABLE aux_flgativo AS LOG                 NO-UNDO.
    DEFINE VARIABLE aux_nrctrhcj AS INT                 NO-UNDO.
    DEFINE VARIABLE aux_flgliber AS LOG                 NO-UNDO.
    DEFINE VARIABLE rel_cdagenci AS INT                 NO-UNDO.
    DEFINE VARIABLE aux_qtregist AS INT                 NO-UNDO.      
    DEFINE VARIABLE aux_vlsldrgt AS DEC                 NO-UNDO.
    DEFINE VARIABLE aux_vlsldtot AS DEC                 NO-UNDO.
    DEFINE VARIABLE aux_vlsldapl AS DEC                 NO-UNDO.
    DEFINE VARIABLE h-b1wgen0081 AS HANDLE              NO-UNDO.  

    DEF VAR aux_dtassele AS DATE                        NO-UNDO. /* Data assinatura eletronica */
    DEF VAR aux_dsvlrprm AS CHAR                        NO-UNDO. /* Data de corte */

    EMPTY TEMP-TABLE tt-proposta_bordero_dscchq.
    EMPTY TEMP-TABLE tt-emprsts.
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    FIND crapage WHERE crapage.cdcooper = par_cdcooper      AND
                       crapage.cdagenci = crapass.cdagenci  NO-LOCK NO-ERROR. 
    
    IF   NOT AVAILABLE crapage   THEN
         ASSIGN rel_dsagenci = STRING(crapass.cdagenci,"999") + 
                               " - NAO CADASTRADO"
                rel_cdagenci = crapass.cdagenci.
    ELSE     
         ASSIGN rel_dsagenci = STRING(crapage.cdagenci,"999") + " - " 
                               + crapage.nmresage
                rel_cdagenci = crapass.cdagenci.
         
	/** Saldo das aplicacoes **/
	RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT
		SET h-b1wgen0081.        
   
	IF  VALID-HANDLE(h-b1wgen0081)  THEN
		DO:
			ASSIGN aux_vlsldtot = 0.

			
			RUN obtem-dados-aplicacoes IN h-b1wgen0081
									  (INPUT par_cdcooper,
									   INPUT par_cdagenci,
									   INPUT 1,
									   INPUT 1,
									   INPUT par_nmdatela,
									   INPUT 1,
									   INPUT par_nrdconta,
									   INPUT 1,
									   INPUT 0,
									   INPUT par_nmdatela,
									   INPUT FALSE,
									   INPUT ?,
									   INPUT ?,
									   OUTPUT rel_vlaplica,
									   OUTPUT TABLE tt-saldo-rdca,
									   OUTPUT TABLE tt-erro).
		
			IF  RETURN-VALUE = "NOK"  THEN
				DO:
					DELETE PROCEDURE h-b1wgen0081.
					
					FIND FIRST tt-erro NO-LOCK NO-ERROR.
				 
					IF  AVAILABLE tt-erro  THEN
						MESSAGE tt-erro.dscritic.
					ELSE
						MESSAGE "Erro nos dados das aplicacoes.".
		
					NEXT.
				END.

			DELETE PROCEDURE h-b1wgen0081.
		END.
	 
	   DO TRANSACTION ON ERROR UNDO, RETRY:
		 /*Busca Saldo Novas Aplicacoes*/
		 
		 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
		  RUN STORED-PROCEDURE pc_busca_saldo_aplicacoes
			aux_handproc = PROC-HANDLE NO-ERROR
									(INPUT par_cdcooper, /* Código da Cooperativa */
									 INPUT '1',            /* Código do Operador */
									 INPUT par_nmdatela, /* Nome da Tela */
									 INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
									 INPUT par_nrdconta, /* Número da Conta */
									 INPUT 1,            /* Titular da Conta */
									 INPUT 0,            /* Número da Aplicaçao / Parâmetro Opcional */
									 INPUT par_dtmvtolt, /* Data de Movimento */
									 INPUT 0,            /* Código do Produto */
									 INPUT 1,            /* Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas) */
									 INPUT 0,            /* Identificador de Log (0 – Nao / 1 – Sim) */
									OUTPUT 0,            /* Saldo Total da Aplicaçao */
									OUTPUT 0,            /* Saldo Total para Resgate */
									OUTPUT 0,            /* Código da crítica */
									OUTPUT "").          /* Descriçao da crítica */
		  
		  CLOSE STORED-PROC pc_busca_saldo_aplicacoes
				aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
		  
		  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

		  ASSIGN aux_cdcritic = 0
				 aux_dscritic = ""
				 aux_vlsldtot = 0
				 aux_vlsldrgt = 0
				 aux_cdcritic = pc_busca_saldo_aplicacoes.pr_cdcritic 
								 WHEN pc_busca_saldo_aplicacoes.pr_cdcritic <> ?
				 aux_dscritic = pc_busca_saldo_aplicacoes.pr_dscritic
								 WHEN pc_busca_saldo_aplicacoes.pr_dscritic <> ?
				 aux_vlsldtot = pc_busca_saldo_aplicacoes.pr_vlsldtot
								 WHEN pc_busca_saldo_aplicacoes.pr_vlsldtot <> ?
				 aux_vlsldrgt = pc_busca_saldo_aplicacoes.pr_vlsldrgt
								 WHEN pc_busca_saldo_aplicacoes.pr_vlsldrgt <> ?.

		  IF aux_cdcritic <> 0   OR
			 aux_dscritic <> ""  THEN
			 DO:
				 IF aux_dscritic = "" THEN
					DO:
					   FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
										  NO-LOCK NO-ERROR.
		
					   IF AVAIL crapcri THEN
						  ASSIGN aux_dscritic = crapcri.dscritic.
		
					END.
		
				 CREATE tt-erro.
		
				 ASSIGN tt-erro.cdcritic = aux_cdcritic
						tt-erro.dscritic = aux_dscritic.
		  
				 RETURN "NOK".
								
			 END.
											  
		 ASSIGN rel_vlaplica = aux_vlsldrgt + rel_vlaplica.
	 END.
	 /*Fim Busca Saldo Novas Aplicacoes*/


    /** Saldo de poupanca programada **/
    RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT 
        SET h-b1wgen0006.

    IF  VALID-HANDLE(h-b1wgen0006)  THEN
        DO:                      
            RUN consulta-poupanca IN h-b1wgen0006 (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_cdoperad,
                                                   INPUT par_nmdatela,
                                                   INPUT par_idorigem,
                                                   INPUT par_nrdconta,
                                                   INPUT par_idseqttl,
                                                   INPUT 0,
                                                   INPUT par_dtmvtolt,
                                                   INPUT par_dtmvtopr,
                                                   INPUT par_inproces,
                                                   INPUT par_nmdatela,
                                                   INPUT FALSE,
                                                  OUTPUT aux_vlsdrdpp,
                                                  OUTPUT TABLE tt-erro,
                                                  OUTPUT TABLE tt-dados-rpp). 
                                  
            DELETE PROCEDURE h-b1wgen0006.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
                    RETURN "NOK".
                END.

            ASSIGN rel_vlaplica = rel_vlaplica + aux_vlsdrdpp.
        END.
    
    /* Totaliza os limites de cartao de credito */
    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT 
        SET h-b1wgen0028.
     
    IF  VALID-HANDLE(h-b1wgen0028)  THEN
        DO:
            RUN lista_cartoes IN h-b1wgen0028 (INPUT par_cdcooper, 
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nrdconta,
                                               INPUT par_idorigem,
                                               INPUT par_idseqttl,
                                               INPUT par_nmdatela,
                                               INPUT FALSE,
                                               OUTPUT aux_flgativo,
                                               OUTPUT aux_nrctrhcj,
                                               OUTPUT aux_flgliber,
                                               OUTPUT aux_dtassele,
                                               OUTPUT aux_dsvlrprm,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-cartoes,
                                              OUTPUT TABLE tt-lim_total).

            DELETE PROCEDURE h-b1wgen0028.
            
            IF  RETURN-VALUE = "NOK"  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.
             
                    RETURN "NOK".
                END.
                
            FIND FIRST tt-lim_total NO-LOCK NO-ERROR.
            IF  AVAIL tt-lim_total  THEN
                aux_vltotccr = tt-lim_total.vltotccr.
        END.
        
    RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT
        SET h-b1wgen0001.
        
    IF  NOT VALID-HANDLE(h-b1wgen0001)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0001.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.

    RUN obtem-cabecalho IN h-b1wgen0001 (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nrdconta,
                                         INPUT "",
                                         INPUT par_dtmvtolt,
                                         INPUT par_dtmvtolt,
                                         INPUT par_idorigem,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-cabec).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen0001.
            RETURN "NOK".
        END.

    RUN carrega_medias IN h-b1wgen0001 (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nrdconta,
                                        INPUT par_dtmvtolt,
                                        INPUT par_idorigem,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT FALSE, /** NAO GERAR LOG **/
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-medias,
                                       OUTPUT TABLE tt-comp_medias).

    DELETE PROCEDURE h-b1wgen0001.
        
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
    FIND FIRST tt-cabec NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-cabec  THEN
        ASSIGN aux_dstipcta = tt-cabec.dstipcta
               aux_dssitdct = tt-cabec.dssitdct.
        
    FIND FIRST tt-comp_medias NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-comp_medias  THEN
        ASSIGN aux_vlsmdtri = tt-comp_medias.vlsmdtri.

    RUN sistema/generico/procedures/b1wgen0002.p 
        PERSISTENT SET h-b1wgen0002.
        
    IF   NOT VALID-HANDLE(h-b1wgen0002)   THEN
         DO:
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Handle invalido para h-b1wgen0002.".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).        
                              
             RETURN "NOK".    
         END.
         
    RUN obtem-dados-emprestimos IN h-b1wgen0002 (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT par_nrdconta,
                                                 INPUT par_idseqttl,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_dtmvtopr,
                                                 INPUT ?,
                                                 INPUT 0,
                                                 INPUT "b1wgen0009",
                                                 INPUT par_inproces,
                                                 INPUT FALSE,
                                                 INPUT FALSE, /*par_flgcondc*/
                                                 INPUT 0, /** nriniseq **/
                                                 INPUT 0, /** nrregist **/
                                                OUTPUT aux_qtregist,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-dados-epr).
     
    DELETE PROCEDURE h-b1wgen0002.
    
    IF   RETURN-VALUE = "NOK" THEN
         RETURN "NOK".    
    
    FOR EACH tt-dados-epr WHERE tt-dados-epr.vlsdeved <> 0 NO-LOCK:

        CREATE tt-emprsts. 
        ASSIGN tt-emprsts.nrctremp = tt-dados-epr.nrctremp
               tt-emprsts.vlsdeved = tt-dados-epr.vlsdeved
               tt-emprsts.vlemprst = tt-dados-epr.vlemprst
               tt-emprsts.dspreapg = tt-dados-epr.dspreapg
               tt-emprsts.vlpreemp = tt-dados-epr.vlpreemp
               tt-emprsts.dslcremp = tt-dados-epr.dslcremp
               tt-emprsts.dsfinemp = tt-dados-epr.dsfinemp
               tot_vlsdeved = tot_vlsdeved + tt-dados-epr.vlsdeved
               tot_vlpreemp = tot_vlpreemp + tt-dados-epr.vlpreemp.            
    END.
        
    RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT
        SET h-b1wgen0021.
        
    IF  NOT VALID-HANDLE(h-b1wgen0021)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0021.".
                   
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
                                       
            RETURN "NOK".
        END.

    RUN obtem_dados_capital IN h-b1wgen0021 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT par_dtmvtolt,
                                             INPUT FALSE, /** NAO GERAR LOG **/
                                            OUTPUT TABLE tt-dados-capital,
                                            OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0021.
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".    
        
    FIND FIRST tt-dados-capital NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-dados-capital  THEN
        ASSIGN aux_vlcaptal = tt-dados-capital.vlcaptal
               aux_vlprepla = tt-dados-capital.vlprepla.

    /**** Verificacao do saldo atual do desconto de cheques ****/
    ASSIGN rel_vlslddsc = 0
           rel_qtdscsld = 0
           rel_vlmaxdsc = 0.
    
    FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper  AND
                           crapcdb.nrdconta = par_nrdconta  AND
                           crapcdb.dtlibera > par_dtmvtolt  AND
                           crapcdb.insitchq = 2             NO-LOCK
                           USE-INDEX crapcdb2:
    
        ASSIGN rel_vlslddsc = rel_vlslddsc + crapcdb.vlcheque
               rel_qtdscsld = rel_qtdscsld + 1
               rel_vlmaxdsc = IF crapcdb.vlcheque > rel_vlmaxdsc THEN
                                 crapcdb.vlcheque
                              ELSE
                                 rel_vlmaxdsc.
           
    END.  /*  Fim do FOR EACH crapcdb  */

    CREATE tt-proposta_bordero_dscchq.
    ASSIGN tt-proposta_bordero_dscchq.dsagenci = rel_dsagenci
           tt-proposta_bordero_dscchq.vlaplica = rel_vlaplica
           tt-proposta_bordero_dscchq.vltotccr = aux_vltotccr
           tt-proposta_bordero_dscchq.telefone = par_telefone
           tt-proposta_bordero_dscchq.dstipcta = aux_dstipcta
           tt-proposta_bordero_dscchq.vlsmdtri = aux_vlsmdtri
           tt-proposta_bordero_dscchq.vlcaptal = aux_vlcaptal
           tt-proposta_bordero_dscchq.vlprepla = aux_vlprepla
           tt-proposta_bordero_dscchq.dsdeben1 = par_dsdeben1
           tt-proposta_bordero_dscchq.dsdeben2 = par_dsdeben2
           tt-proposta_bordero_dscchq.vlsalari = par_vlsalari
           tt-proposta_bordero_dscchq.vlsalcon = par_vlsalcon
           tt-proposta_bordero_dscchq.vloutras = par_vloutras
           tt-proposta_bordero_dscchq.ddmvtolt = DAY(par_dtmvtolt)
           tt-proposta_bordero_dscchq.aamvtolt = YEAR(par_dtmvtolt)
           tt-proposta_bordero_dscchq.nrctrlim = par_nrctrlim
           tt-proposta_bordero_dscchq.vllimpro = par_vllimpro
           tt-proposta_bordero_dscchq.nrdconta = par_nrdconta
           tt-proposta_bordero_dscchq.nrmatric = tt-cabec.nrmatric
           tt-proposta_bordero_dscchq.nmprimtl = tt-cabec.nmprimtl
           tt-proposta_bordero_dscchq.dtadmemp = tt-cabec.dtadmemp
           tt-proposta_bordero_dscchq.nmempres = par_nmempres
           tt-proposta_bordero_dscchq.nrcpfcgc = tt-cabec.nrcpfcgc
           tt-proposta_bordero_dscchq.dssitdct = aux_dssitdct
           tt-proposta_bordero_dscchq.dtadmiss = tt-cabec.dtadmiss
           tt-proposta_bordero_dscchq.nmextcop = par_nmextcop
           tt-proposta_bordero_dscchq.dsramati = par_dsramati
           tt-proposta_bordero_dscchq.vllimcre = tt-cabec.vllimcre
           tt-proposta_bordero_dscchq.vllimchq = par_vllimchq
           tt-proposta_bordero_dscchq.vllimtit = par_vllimtit
           tt-proposta_bordero_dscchq.vlfatura = par_vlfatura
           tt-proposta_bordero_dscchq.vlsdeved = tot_vlsdeved
           tt-proposta_bordero_dscchq.vlpreemp = tot_vlpreemp
           tt-proposta_bordero_dscchq.dtcalcul = par_dtmvtolt
           tt-proposta_bordero_dscchq.dsobser1 = par_dsobser1
           tt-proposta_bordero_dscchq.dsobser2 = par_dsobser2
           tt-proposta_bordero_dscchq.dsobser3 = par_dsobser3
           tt-proposta_bordero_dscchq.dsobser4 = par_dsobser4
           tt-proposta_bordero_dscchq.dsmesref = par_dsmesref
           tt-proposta_bordero_dscchq.nmcidade = par_nmcidade
           tt-proposta_bordero_dscchq.nmrescop = par_nmrescop
           tt-proposta_bordero_dscchq.vlmaxdsc = rel_vlmaxdsc
           tt-proposta_bordero_dscchq.qtdscsld = rel_qtdscsld
           tt-proposta_bordero_dscchq.vlslddsc = rel_vlslddsc
           tt-proposta_bordero_dscchq.qtborchq = par_qtborchq
           tt-proposta_bordero_dscchq.vlborchq = par_vlborchq
           tt-proposta_bordero_dscchq.cdagenci = rel_cdagenci
           tt-proposta_bordero_dscchq.nrborder = par_nrborder.

    RETURN "OK".    
    
END PROCEDURE.

/*****************************************************************************
          Carregas dados para efetuar a impressao da nota promissoria      
*****************************************************************************/
PROCEDURE carrega_dados_nota_promissoria:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcpfcgc AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctrlim AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vllimite AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsmesre2 AS CHARACTER   NO-UNDO. 
    DEFINE INPUT  PARAMETER par_dsemsnot AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsmesref AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmrescop AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmextcop AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdocnpj AS CHARACTER   NO-UNDO. 
    DEFINE INPUT  PARAMETER par_dsdmoeda AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmprimtl AS CHARACTER   NO-UNDO.

    DEFINE INPUT-OUTPUT PARAMETER TABLE FOR tt-dados-avais.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dados_nota_pro_chq.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    
    DEFINE VARIABLE h-b1wgen9999 AS HANDLE             NO-UNDO.
    DEFINE VARIABLE rel_dsqtdava AS CHARACTER          NO-UNDO.
    DEFINE VARIABLE aux_dsextens AS CHARACTER          NO-UNDO.   
    DEFINE VARIABLE aux_dsbranco AS CHARACTER          NO-UNDO.
    DEFINE VARIABLE rel_dsmvtolt AS CHARACTER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE rel_dspreemp AS CHARACTER EXTENT 2 NO-UNDO.
    DEFINE VARIABLE aux_nmcidpac AS CHARACTER          NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dados_nota_pro_chq.

    /* Dados do 1o Avalista  */
    FIND tt-dados-avais WHERE tt-dados-avais.idavalis = 1 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF   AVAIL tt-dados-avais  THEN
         ASSIGN tt-dados-avais.dsendre1 = IF TRIM(tt-dados-avais.dsendre1) = ""
                                          THEN FILL("_",40)
                                          ELSE 
                                          IF tt-dados-avais.nrendere > 0 
                                          THEN SUBSTR(tt-dados-avais.dsendre1,
                                                      1,32) + " " +
                                            TRIM(STRING(tt-dados-avais.nrendere,
                                                        "zzz,zz9"))
                                          ELSE tt-dados-avais.dsendre1
                                     
                tt-dados-avais.dsendre2 = IF TRIM(tt-dados-avais.dsendre2) = ""
                                          THEN FILL("_",40)
                                          ELSE tt-dados-avais.dsendre2
                                               
                tt-dados-avais.dsendre3 = IF tt-dados-avais.nrcepend = 0  AND
                                             tt-dados-avais.nmcidade = "" AND
                                             tt-dados-avais.cdufresd = "" 
                                          THEN FILL("_",40)
                                          ELSE STRING(tt-dados-avais.nrcepend,
                                                      "99999,999") + " - " +
                                               tt-dados-avais.nmcidade + "/" +
                                               tt-dados-avais.cdufresd

                tt-dados-avais.nmdavali = IF TRIM(tt-dados-avais.nmdavali) = ""
                                          THEN FILL("_",40)
                                          ELSE tt-dados-avais.nmdavali

                tt-dados-avais.nrdocava = IF   TRIM(tt-dados-avais.nrdocava) = ""
                                               THEN FILL("_",40)
                                          ELSE tt-dados-avais.nrdocava

                tt-dados-avais.nrdocava = IF tt-dados-avais.nrctaava > 0 THEN
                                             tt-dados-avais.nrdocava + " - " +
                                             TRIM(STRING(tt-dados-avais.nrctaava,
                                                           "zzzz,zzz,9"))
                                          ELSE tt-dados-avais.nrdocava

                tt-dados-avais.nmconjug = IF TRIM(tt-dados-avais.nmconjug) = ""
                                          THEN FILL("_",40)
                                          ELSE tt-dados-avais.nmconjug

                tt-dados-avais.nrdoccjg = IF tt-dados-avais.nrcpfcjg > 0 THEN
                                             "C.P.F. " +
                                             STRING(STRING(tt-dados-avais.nrcpfcjg,
                                             "99999999999"),"xxx.xxx.xxx-xx")                 
                                          ELSE IF  tt-dados-avais.nrdoccjg = ""  THEN
                                             FILL("_",40)
                                          ELSE tt-dados-avais.nrdoccjg.
    ELSE
    DO:
        CREATE tt-dados-avais.
        ASSIGN tt-dados-avais.idavalis = 1
               tt-dados-avais.dsendre1 = FILL("_",40)
               tt-dados-avais.dsendre2 = FILL("_",40)
               tt-dados-avais.dsendre3 = FILL("_",40)
               tt-dados-avais.nmdavali = FILL("_",40)
               tt-dados-avais.nrdocava = FILL("_",40)
               tt-dados-avais.nmconjug = FILL("_",40)
               tt-dados-avais.nrdoccjg = FILL("_",40).
    END.                    

    ASSIGN rel_dsqtdava = "Avalista:".

    /* Dados do 2o Avalista  */
    FIND tt-dados-avais WHERE tt-dados-avais.idavalis = 2
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF   AVAIL tt-dados-avais  THEN
         ASSIGN tt-dados-avais.dsendre1 = IF TRIM(tt-dados-avais.dsendre1) = ""
                                          THEN FILL("_",40)
                                          ELSE 
                                          IF tt-dados-avais.nrendere > 0 
                                          THEN SUBSTR(tt-dados-avais.dsendre1,
                                                      1,32) + " " +
                                            TRIM(STRING(tt-dados-avais.nrendere,
                                                        "zzz,zz9"))
                                          ELSE tt-dados-avais.dsendre1
                                     
                tt-dados-avais.dsendre2 = IF TRIM(tt-dados-avais.dsendre2) = ""
                                          THEN FILL("_",40)
                                          ELSE tt-dados-avais.dsendre2
                                               
                tt-dados-avais.dsendre3 = IF tt-dados-avais.nrcepend = 0  AND
                                             tt-dados-avais.nmcidade = "" AND
                                             tt-dados-avais.cdufresd = "" 
                                          THEN FILL("_",40)
                                          ELSE STRING(tt-dados-avais.nrcepend,
                                                      "99999,999") + " - " +
                                               tt-dados-avais.nmcidade + "/" +
                                               tt-dados-avais.cdufresd

                tt-dados-avais.nmdavali = IF TRIM(tt-dados-avais.nmdavali) = ""
                                          THEN FILL("_",40)
                                          ELSE tt-dados-avais.nmdavali

                tt-dados-avais.nrdocava = IF   tt-dados-avais.nrcpfcgc > 0 THEN
                                               "C.P.F. " +
                                               STRING(STRING(tt-dados-avais.nrcpfcgc,
                                               "99999999999"),"xxx.xxx.xxx-xx")                 
                                          ELSE IF TRIM(tt-dados-avais.nrdocava) = ""
                                               THEN FILL("_",40)
                                          ELSE tt-dados-avais.nrdocava

                tt-dados-avais.nrdocava = IF tt-dados-avais.nrctaava > 0 THEN
                                             tt-dados-avais.nrdocava + " - " +
                                             TRIM(STRING(tt-dados-avais.nrctaava,
                                                           "zzzz,zzz,9"))
                                          ELSE tt-dados-avais.nrdocava

                tt-dados-avais.nmconjug = IF TRIM(tt-dados-avais.nmconjug) = ""
                                          THEN FILL("_",40)
                                          ELSE tt-dados-avais.nmconjug

                tt-dados-avais.nrdoccjg = IF tt-dados-avais.nrcpfcjg > 0 THEN
                                             "C.P.F. " +
                                             STRING(STRING(tt-dados-avais.nrcpfcjg,
                                             "99999999999"),"xxx.xxx.xxx-xx")                 
                                          ELSE IF  tt-dados-avais.nrdoccjg = ""  THEN
                                             FILL("_",40)
                                          ELSE tt-dados-avais.nrdoccjg
                rel_dsqtdava = "Avalistas:".
    ELSE
    DO:
        CREATE tt-dados-avais.
        ASSIGN tt-dados-avais.idavalis = 2
               tt-dados-avais.dsendre1 = FILL("_",40)
               tt-dados-avais.dsendre2 = FILL("_",40)
               tt-dados-avais.dsendre3 = FILL("_",40)
               tt-dados-avais.nmdavali = FILL("_",40)
               tt-dados-avais.nrdocava = FILL("_",40)
               tt-dados-avais.nmconjug = FILL("_",40)
               tt-dados-avais.nrdoccjg = FILL("_",40).
    END.                   

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
    DO: 
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Handle invalido para h-b1wgen9999.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".            
    END.

    IF   LENGTH(par_dsemsnot) < 33   THEN
         ASSIGN par_dsemsnot = FILL(" ",33 - LENGTH(par_dsemsnot)) +
                               par_dsemsnot.    
    FIND crapenc WHERE 
         crapenc.cdcooper = par_cdcooper      AND
         crapenc.nrdconta = crapass.nrdconta  AND
         crapenc.idseqttl = 1                 AND
         crapenc.cdseqinc = 1 NO-LOCK NO-ERROR.

    IF  DAY(par_dtmvtolt) > 1  THEN
    DO:
        RUN valor-extenso IN h-b1wgen9999 (INPUT DAY(par_dtmvtolt), 
                                           INPUT 50,
                                           INPUT 50, 
                                           INPUT "I",
                                          OUTPUT aux_dsextens, 
                                          OUTPUT aux_dsbranco).

        IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen9999.
    
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = aux_dsextens.
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".       
        END.

        ASSIGN aux_dsextens = aux_dsextens + " DIAS DO MES DE " +
                              CAPS(ENTRY(MONTH(par_dtmvtolt),par_dsmesre2)) 
                              + " DE ".  

        RUN valor-extenso IN h-b1wgen9999 (INPUT YEAR(par_dtmvtolt),
                                           INPUT 68 - LENGTH(aux_dsextens),
                                           INPUT 44, 
                                           INPUT "I",
                                          OUTPUT rel_dsmvtolt[1], 
                                          OUTPUT rel_dsmvtolt[2]).

        IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen9999.
    
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = rel_dsmvtolt[1].
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".       
        END.

        ASSIGN rel_dsmvtolt[1] = aux_dsextens + rel_dsmvtolt[1]
               rel_dsmvtolt[1] = rel_dsmvtolt[1] + 
                                  FILL("*",78 - LENGTH(rel_dsmvtolt[1]))
               rel_dsmvtolt[2] = rel_dsmvtolt[2] + 
                                  FILL("*",8 - LENGTH(rel_dsmvtolt[2])).
    END.
    ELSE
    DO:            
        ASSIGN aux_dsextens = "PRIMEIRO DIA DO MES DE " +
                              CAPS(ENTRY(MONTH(par_dtmvtolt),par_dsmesre2))
                              + " DE ".

        RUN valor-extenso IN h-b1wgen9999 (INPUT YEAR(par_dtmvtolt),
                                           INPUT 68 - LENGTH(aux_dsextens),
                                           INPUT 44, 
                                           INPUT "I",
                                          OUTPUT rel_dsmvtolt[1], 
                                          OUTPUT rel_dsmvtolt[2]).

        IF  RETURN-VALUE = "NOK"  THEN
        DO:
            DELETE PROCEDURE h-b1wgen9999.
    
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = rel_dsmvtolt[1].
           
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".       
        END.

        ASSIGN rel_dsmvtolt[1] = aux_dsextens + rel_dsmvtolt[1]
               rel_dsmvtolt[1] = rel_dsmvtolt[1] + 
                                  FILL("*",78 - LENGTH(rel_dsmvtolt[1]))
               rel_dsmvtolt[2] = rel_dsmvtolt[2] + 
                                  FILL("*",8 - LENGTH(rel_dsmvtolt[2])).
    END.

    RUN valor-extenso IN h-b1wgen9999 
                     (INPUT par_vllimite, 
                      INPUT 45, 
                      INPUT 73, 
                      INPUT "M", 
                     OUTPUT rel_dspreemp[1], 
                     OUTPUT rel_dspreemp[2]).    
    
    ASSIGN rel_dspreemp[1] = "(" + rel_dspreemp[1]
           rel_dspreemp[2] = rel_dspreemp[2] + ")".
    
    FIND crapage WHERE crapage.cdcooper = par_cdcooper AND
                       crapage.cdagenci = par_cdagenci NO-LOCK NO-ERROR.
    
    IF  NOT AVAILABLE crapage  THEN
        aux_nmcidpac = "Pagavel em ____________________". 
    ELSE     
        aux_nmcidpac = "Pagavel em " + crapage.nmcidade.    

    CREATE tt-dados_nota_pro_chq.
    ASSIGN tt-dados_nota_pro_chq.ddmvtolt = DAY(par_dtmvtolt)
           tt-dados_nota_pro_chq.aamvtolt = YEAR(par_dtmvtolt)
           tt-dados_nota_pro_chq.vlpreemp = par_vllimite
           tt-dados_nota_pro_chq.dsctremp = STRING(par_nrctrlim,"z,zzz,zz9") +
                                        "/001"
           tt-dados_nota_pro_chq.dscpfcgc =  IF crapass.inpessoa = 1 THEN
                                            "C.P.F. " + TRIM(par_nrcpfcgc)
                                         ELSE
                                            "CNPJ " + TRIM(par_nrcpfcgc)
           tt-dados_nota_pro_chq.dsendco1 = crapenc.dsendere + " " +
                                        TRIM(STRING(crapenc.nrendere,"zzz,zzz"))
           tt-dados_nota_pro_chq.dsendco2 = TRIM(crapenc.nmbairro)
           tt-dados_nota_pro_chq.dsendco3 = STRING(crapenc.nrcepend,"99999,999")
                                            + " - " + TRIM(crapenc.nmcidade) 
                                            + "/" + crapenc.cdufende
           tt-dados_nota_pro_chq.dsmesref = par_dsmesref
           tt-dados_nota_pro_chq.dsemsnot = par_dsemsnot
           tt-dados_nota_pro_chq.dtvencto = par_dtmvtolt
           tt-dados_nota_pro_chq.dsemsnot = par_dsemsnot
           tt-dados_nota_pro_chq.dsextens = aux_dsextens
           tt-dados_nota_pro_chq.dsbranco = aux_dsbranco
           tt-dados_nota_pro_chq.dsmvtol1 = rel_dsmvtolt[1]
           tt-dados_nota_pro_chq.dsmvtol2 = rel_dsmvtolt[2]
           tt-dados_nota_pro_chq.dspremp1 = rel_dspreemp[1]
           tt-dados_nota_pro_chq.dspremp2 = rel_dspreemp[2]
           tt-dados_nota_pro_chq.nmrescop = par_nmrescop
           tt-dados_nota_pro_chq.nmextcop = par_nmextcop
           tt-dados_nota_pro_chq.nrdocnpj = STRING(STRING(par_nrdocnpj,
                                        "99999999999999"),"xx.xxx.xxx/xxxx-xx")
           tt-dados_nota_pro_chq.dsdmoeda = par_dsdmoeda
           tt-dados_nota_pro_chq.nmprimtl = par_nmprimtl
           tt-dados_nota_pro_chq.nrdconta = par_nrdconta
           tt-dados_nota_pro_chq.nmcidpac = aux_nmcidpac
           tt-dados_nota_pro_chq.dsqtdava = rel_dsqtdava.
                       
    RETURN "OK".
    
END PROCEDURE.

/*****************************************************************************
              Carrega dados para a proposta de limite                      
*****************************************************************************/
PROCEDURE carrega_dados_proposta_limite:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER    NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER    NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER    NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE       NO-UNDO.    
    DEFINE INPUT  PARAMETER par_dtmvtopr AS DATE       NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER    NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER    NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER    NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_inproces AS INTEGER    NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmextcop AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_vllimchq AS DECIMAL    NO-UNDO.
    DEFINE INPUT  PARAMETER par_vllimtit AS DECIMAL    NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmempres AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdlinha AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlutiliz AS DECIMAL    NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsobser1 AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsobser2 AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsobser3 AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsobser4 AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsmesref AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmcidade AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmrescop AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_telefone AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdeben1 AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdeben2 AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlsalari AS DECIMAL    NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlsalcon AS DECIMAL    NO-UNDO.
    DEFINE INPUT  PARAMETER par_vloutras AS DECIMAL    NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctrlim AS INTEGER    NO-UNDO.
    DEFINE INPUT  PARAMETER par_vllimpro AS DECIMAL    NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsramati AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlfatura AS DECIMAL    NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlmedchq AS DECIMAL    NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmoperad AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmresco1 AS CHARACTER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmresco2 AS CHARACTER  NO-UNDO.
    
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-emprsts.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-proposta_limite_chq.
    
    DEFINE VARIABLE h-b1wgen0001 AS HANDLE             NO-UNDO.
    DEFINE VARIABLE h-b1wgen0002 AS HANDLE             NO-UNDO.
    DEFINE VARIABLE h-b1wgen0004 AS HANDLE             NO-UNDO.
    DEFINE VARIABLE h-b1wgen0006 AS HANDLE             NO-UNDO.
    DEFINE VARIABLE h-b1wgen0021 AS HANDLE             NO-UNDO.
    DEFINE VARIABLE h-b1wgen0028 AS HANDLE             NO-UNDO.
    DEFINE VARIABLE rel_dsagenci AS CHARACTER          NO-UNDO.
    DEFINE VARIABLE rel_vlaplica AS DECIMAL            NO-UNDO.
    DEFINE VARIABLE aux_vltotccr AS DECIMAL            NO-UNDO.
    DEFINE VARIABLE aux_dstipcta AS CHARACTER          NO-UNDO.
    DEFINE VARIABLE aux_dssitdct AS CHARACTER          NO-UNDO.
    DEFINE VARIABLE aux_vlsmdtri AS DECIMAL            NO-UNDO.
    DEFINE VARIABLE aux_vltotemp AS DECIMAL            NO-UNDO.
    DEFINE VARIABLE aux_vltotpre AS DECIMAL            NO-UNDO.
    DEFINE VARIABLE aux_qtprecal AS INTEGER            NO-UNDO.
    DEFINE VARIABLE aux_vlcaptal AS DECIMAL            NO-UNDO.
    DEFINE VARIABLE aux_vlprepla AS DECIMAL            NO-UNDO.
    DEFINE VARIABLE aux_vlsdrdpp AS DECIMAL DECIMALS 8 NO-UNDO.
    DEFINE VARIABLE tot_vlsdeved AS DECIMAL            NO-UNDO.
    DEFINE VARIABLE tot_vlpreemp AS DECIMAL            NO-UNDO.
    DEFINE VARIABLE aux_flgativo AS LOG                NO-UNDO.
    DEFINE VARIABLE aux_nrctrhcj AS INT                NO-UNDO.
    DEFINE VARIABLE aux_flgliber AS INT                NO-UNDO.
    DEFINE VARIABLE aux_qtregist AS INT                NO-UNDO.
    DEF VAR h-b1wgen0081 AS HANDLE                     NO-UNDO.    
    DEF VAR aux_vlsldrgt AS DEC                        NO-UNDO.
    DEF VAR aux_vlsldtot AS DEC                        NO-UNDO.
    DEF VAR aux_vlsldapl AS DEC                        NO-UNDO.    

    DEF VAR aux_dtassele AS DATE                       NO-UNDO. /* Data assinatura eletronica */
    DEF VAR aux_dsvlrprm AS CHAR                       NO-UNDO. /* Data de corte */

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-emprsts.
    EMPTY TEMP-TABLE tt-proposta_limite_chq.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
           
    FIND crapage WHERE crapage.cdcooper = par_cdcooper       AND
                       crapage.cdagenci = crapass.cdagenci   NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapage   THEN
         ASSIGN rel_dsagenci = TRIM(STRING(crapass.cdagenci,"zz9")) + 
                               " - NAO CADASTRADA".
    ELSE
         ASSIGN rel_dsagenci = TRIM(STRING(crapass.cdagenci,"zz9")) + " - " +
                               crapage.nmresage.

	/** Saldo das aplicacoes **/
	RUN sistema/generico/procedures/b1wgen0081.p PERSISTENT
		SET h-b1wgen0081.        
   
	IF  VALID-HANDLE(h-b1wgen0081)  THEN
		DO:
			ASSIGN aux_vlsldtot = 0.

			
			RUN obtem-dados-aplicacoes IN h-b1wgen0081
									  (INPUT par_cdcooper,
									   INPUT par_cdagenci,
									   INPUT 1,
									   INPUT 1,
									   INPUT par_nmdatela,
									   INPUT 1,
									   INPUT par_nrdconta,
									   INPUT 1,
									   INPUT 0,
									   INPUT par_nmdatela,
									   INPUT FALSE,
									   INPUT ?,
									   INPUT ?,
									   OUTPUT rel_vlaplica,
									   OUTPUT TABLE tt-saldo-rdca,
									   OUTPUT TABLE tt-erro).
		
			IF  RETURN-VALUE = "NOK"  THEN
				DO:
					DELETE PROCEDURE h-b1wgen0081.
					
					FIND FIRST tt-erro NO-LOCK NO-ERROR.
				 
					IF  AVAILABLE tt-erro  THEN
						MESSAGE tt-erro.dscritic.
					ELSE
						MESSAGE "Erro nos dados das aplicacoes.".
		
					NEXT.
				END.

			DELETE PROCEDURE h-b1wgen0081.
		END.
	 
	   DO TRANSACTION ON ERROR UNDO, RETRY:
		 /*Busca Saldo Novas Aplicacoes*/
		 
		 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }    
		  RUN STORED-PROCEDURE pc_busca_saldo_aplicacoes
			aux_handproc = PROC-HANDLE NO-ERROR
									(INPUT par_cdcooper, /* Código da Cooperativa */
									 INPUT '1',            /* Código do Operador */
									 INPUT par_nmdatela, /* Nome da Tela */
									 INPUT 1,            /* Identificador de Origem (1 - AYLLOS / 2 - CAIXA / 3 - INTERNET / 4 - TAA / 5 - AYLLOS WEB / 6 - URA */
									 INPUT par_nrdconta, /* Número da Conta */
									 INPUT 1,            /* Titular da Conta */
									 INPUT 0,            /* Número da Aplicaçao / Parâmetro Opcional */
									 INPUT par_dtmvtolt, /* Data de Movimento */
									 INPUT 0,            /* Código do Produto */
									 INPUT 1,            /* Identificador de Bloqueio de Resgate (1 – Todas / 2 – Bloqueadas / 3 – Desbloqueadas) */
									 INPUT 0,            /* Identificador de Log (0 – Nao / 1 – Sim) */
									OUTPUT 0,            /* Saldo Total da Aplicaçao */
									OUTPUT 0,            /* Saldo Total para Resgate */
									OUTPUT 0,            /* Código da crítica */
									OUTPUT "").          /* Descriçao da crítica */
		  
		  CLOSE STORED-PROC pc_busca_saldo_aplicacoes
				aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
		  
		  { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

		  ASSIGN aux_cdcritic = 0
				 aux_dscritic = ""
				 aux_vlsldtot = 0
				 aux_vlsldrgt = 0
				 aux_cdcritic = pc_busca_saldo_aplicacoes.pr_cdcritic 
								 WHEN pc_busca_saldo_aplicacoes.pr_cdcritic <> ?
				 aux_dscritic = pc_busca_saldo_aplicacoes.pr_dscritic
								 WHEN pc_busca_saldo_aplicacoes.pr_dscritic <> ?
				 aux_vlsldtot = pc_busca_saldo_aplicacoes.pr_vlsldtot
								 WHEN pc_busca_saldo_aplicacoes.pr_vlsldtot <> ?
				 aux_vlsldrgt = pc_busca_saldo_aplicacoes.pr_vlsldrgt
								 WHEN pc_busca_saldo_aplicacoes.pr_vlsldrgt <> ?.

		  IF aux_cdcritic <> 0   OR
			 aux_dscritic <> ""  THEN
			 DO:
				 IF aux_dscritic = "" THEN
					DO:
					   FIND crapcri WHERE crapcri.cdcritic = aux_cdcritic
										  NO-LOCK NO-ERROR.
		
					   IF AVAIL crapcri THEN
						  ASSIGN aux_dscritic = crapcri.dscritic.
		
					END.
		
				 CREATE tt-erro.
		
				 ASSIGN tt-erro.cdcritic = aux_cdcritic
						tt-erro.dscritic = aux_dscritic.
		  
				 RETURN "NOK".
								
			 END.
											  
		 ASSIGN rel_vlaplica = aux_vlsldrgt + rel_vlaplica.
	 END.
	 /*Fim Busca Saldo Novas Aplicacoes*/

    
    /** Saldo de poupanca programada **/
    RUN sistema/generico/procedures/b1wgen0006.p PERSISTENT 
        SET h-b1wgen0006.

    IF  VALID-HANDLE(h-b1wgen0006)  THEN
    DO:                      
        RUN consulta-poupanca IN h-b1wgen0006 (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT par_cdoperad,
                                               INPUT par_nmdatela,
                                               INPUT par_idorigem,
                                               INPUT par_nrdconta,
                                               INPUT par_idseqttl,
                                               INPUT 0,
                                               INPUT par_dtmvtolt,
                                               INPUT par_dtmvtopr,
                                               INPUT par_inproces,
                                               INPUT par_nmdatela,
                                               INPUT FALSE, 
                                              OUTPUT aux_vlsdrdpp,
                                              OUTPUT TABLE tt-erro,
                                              OUTPUT TABLE tt-dados-rpp). 
                               
        DELETE PROCEDURE h-b1wgen0006.
        
        IF  RETURN-VALUE = "NOK"  THEN
            RETURN "NOK".
    
        ASSIGN rel_vlaplica = rel_vlaplica + aux_vlsdrdpp.
    END.
    
    /* Totaliza os limites de cartao de credito */
    RUN sistema/generico/procedures/b1wgen0028.p PERSISTENT 
        SET h-b1wgen0028.
     
    IF  VALID-HANDLE(h-b1wgen0028)  THEN
    DO:
        RUN lista_cartoes IN h-b1wgen0028 (INPUT par_cdcooper, 
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT par_cdoperad,
                                           INPUT par_nrdconta,
                                           INPUT par_idorigem,
                                           INPUT par_idseqttl,
                                           INPUT par_nmdatela,
                                           INPUT FALSE,
                                           OUTPUT aux_flgativo,
                                           OUTPUT aux_nrctrhcj,
                                           OUTPUT aux_flgliber,
                                           OUTPUT aux_dtassele,
                                           OUTPUT aux_dsvlrprm,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-cartoes,
                                          OUTPUT TABLE tt-lim_total).

        DELETE PROCEDURE h-b1wgen0028.
        
        IF  RETURN-VALUE = "NOK"  THEN
            RETURN "NOK".
            
        FIND FIRST tt-lim_total NO-LOCK NO-ERROR.
        IF  AVAIL tt-lim_total  THEN
            aux_vltotccr = tt-lim_total.vltotccr.
    END.
        
    RUN sistema/generico/procedures/b1wgen0001.p PERSISTENT
        SET h-b1wgen0001.
        
    IF  NOT VALID-HANDLE(h-b1wgen0001)  THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Handle invalido para BO b1wgen0001.".
               
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
                                   
        RETURN "NOK".
    END.

    RUN obtem-cabecalho IN h-b1wgen0001 (INPUT par_cdcooper,
                                         INPUT par_cdagenci,
                                         INPUT par_nrdcaixa,
                                         INPUT par_cdoperad,
                                         INPUT par_nrdconta,
                                         INPUT "",
                                         INPUT par_dtmvtolt,
                                         INPUT par_dtmvtolt,
                                         INPUT par_idorigem,
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-cabec).

    IF  RETURN-VALUE = "NOK"  THEN
    DO:
        DELETE PROCEDURE h-b1wgen0001.
        RETURN "NOK".
    END.

    RUN carrega_medias IN h-b1wgen0001 (INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT par_cdoperad,
                                        INPUT par_nrdconta,
                                        INPUT par_dtmvtolt,
                                        INPUT par_idorigem,
                                        INPUT par_idseqttl,
                                        INPUT par_nmdatela,
                                        INPUT FALSE, /** NAO GERAR LOG **/
                                       OUTPUT TABLE tt-erro,
                                       OUTPUT TABLE tt-medias,
                                       OUTPUT TABLE tt-comp_medias).

    DELETE PROCEDURE h-b1wgen0001.
        
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".
    
    FIND FIRST tt-cabec NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-cabec  THEN
        ASSIGN aux_dstipcta = tt-cabec.dstipcta
               aux_dssitdct = tt-cabec.dssitdct.
        
    FIND FIRST tt-comp_medias NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-comp_medias  THEN
        ASSIGN aux_vlsmdtri = tt-comp_medias.vlsmdtri.

    RUN sistema/generico/procedures/b1wgen0002.p 
        PERSISTENT SET h-b1wgen0002.
        
    IF  NOT VALID-HANDLE(h-b1wgen0002)   THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Handle invalido para h-b1wgen0002.".
   
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).        
                         
        RETURN "NOK".    
    END.
         
    RUN obtem-dados-emprestimos IN h-b1wgen0002 (INPUT par_cdcooper,
                                                 INPUT par_cdagenci,
                                                 INPUT par_nrdcaixa,
                                                 INPUT par_cdoperad,
                                                 INPUT par_nmdatela,
                                                 INPUT par_idorigem,
                                                 INPUT par_nrdconta,
                                                 INPUT par_idseqttl,
                                                 INPUT par_dtmvtolt,
                                                 INPUT par_dtmvtopr,
                                                 INPUT ?,
                                                 INPUT 0,
                                                 INPUT "b1wgen0009",
                                                 INPUT par_inproces,
                                                 INPUT FALSE,
                                                 INPUT FALSE, /*par_flgcondc*/
                                                 INPUT 0, /** nriniseq **/
                                                 INPUT 0, /** nrregist **/
                                                OUTPUT aux_qtregist,
                                                OUTPUT TABLE tt-erro,
                                                OUTPUT TABLE tt-dados-epr).
     
    DELETE PROCEDURE h-b1wgen0002.
    
    IF   RETURN-VALUE = "NOK" THEN
         RETURN "NOK".    
    
    FOR EACH tt-dados-epr WHERE tt-dados-epr.vlsdeved <> 0 NO-LOCK:

        CREATE tt-emprsts. 
        ASSIGN tt-emprsts.nrctremp = tt-dados-epr.nrctremp
               tt-emprsts.vlsdeved = tt-dados-epr.vlsdeved
               tt-emprsts.vlemprst = tt-dados-epr.vlemprst
               tt-emprsts.dspreapg = tt-dados-epr.dspreapg
               tt-emprsts.vlpreemp = tt-dados-epr.vlpreemp
               tt-emprsts.dslcremp = tt-dados-epr.dslcremp
               tt-emprsts.dsfinemp = tt-dados-epr.dsfinemp
               tot_vlsdeved = tot_vlsdeved + tt-dados-epr.vlsdeved
               tot_vlpreemp = tot_vlpreemp + tt-dados-epr.vlpreemp.            
    END.
        
    RUN sistema/generico/procedures/b1wgen0021.p PERSISTENT
        SET h-b1wgen0021.
        
    IF  NOT VALID-HANDLE(h-b1wgen0021)  THEN
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Handle invalido para BO b1wgen0021.".
               
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
                                   
        RETURN "NOK".
    END.

    RUN obtem_dados_capital IN h-b1wgen0021 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT par_cdoperad,
                                             INPUT par_nmdatela,
                                             INPUT par_idorigem,
                                             INPUT par_nrdconta,
                                             INPUT par_idseqttl,
                                             INPUT par_dtmvtolt,
                                             INPUT FALSE, /** NAO GERAR LOG **/
                                            OUTPUT TABLE tt-dados-capital,
                                            OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0021.
    
    IF  RETURN-VALUE = "NOK"  THEN
        RETURN "NOK".    
        
    FIND FIRST tt-dados-capital NO-LOCK NO-ERROR.
    
    IF  AVAILABLE tt-dados-capital  THEN
        ASSIGN aux_vlcaptal = tt-dados-capital.vlcaptal
               aux_vlprepla = tt-dados-capital.vlprepla.
    

    CREATE tt-proposta_limite_chq.
    ASSIGN tt-proposta_limite_chq.dsagenci = rel_dsagenci
           tt-proposta_limite_chq.vlaplica = rel_vlaplica
           tt-proposta_limite_chq.vltotccr = aux_vltotccr
           tt-proposta_limite_chq.telefone = par_telefone  
           tt-proposta_limite_chq.dstipcta = aux_dstipcta
           tt-proposta_limite_chq.vlsmdtri = aux_vlsmdtri
           tt-proposta_limite_chq.vlcaptal = aux_vlcaptal
           tt-proposta_limite_chq.vlprepla = aux_vlprepla
           tt-proposta_limite_chq.dsdeben1 = par_dsdeben1
           tt-proposta_limite_chq.dsdeben2 = par_dsdeben2
           tt-proposta_limite_chq.vlsalari = par_vlsalari
           tt-proposta_limite_chq.vlsalcon = par_vlsalcon
           tt-proposta_limite_chq.vloutras = par_vloutras
           tt-proposta_limite_chq.ddmvtolt = DAY(par_dtmvtolt)
           tt-proposta_limite_chq.aamvtolt = YEAR(par_dtmvtolt)
           tt-proposta_limite_chq.nrctrlim = par_nrctrlim
           tt-proposta_limite_chq.vllimpro = par_vllimpro
           tt-proposta_limite_chq.nrdconta = par_nrdconta
           tt-proposta_limite_chq.nrmatric = tt-cabec.nrmatric
           tt-proposta_limite_chq.nmprimtl = tt-cabec.nmprimtl
           tt-proposta_limite_chq.dtadmemp = tt-cabec.dtadmemp
           tt-proposta_limite_chq.nmempres = par_nmempres
           tt-proposta_limite_chq.nrcpfcgc = tt-cabec.nrcpfcgc
           tt-proposta_limite_chq.dssitdct = aux_dssitdct
           tt-proposta_limite_chq.dtadmiss = tt-cabec.dtadmiss
           tt-proposta_limite_chq.nmextcop = par_nmextcop
           tt-proposta_limite_chq.dsramati = par_dsramati
           tt-proposta_limite_chq.vllimcre = tt-cabec.vllimcre
           tt-proposta_limite_chq.vllimchq = par_vllimchq
           tt-proposta_limite_chq.vllimtit = par_vllimtit
           tt-proposta_limite_chq.vlfatura = par_vlfatura
           tt-proposta_limite_chq.vlmedchq = par_vlmedchq
           tt-proposta_limite_chq.dsdlinha = par_dsdlinha
           tt-proposta_limite_chq.vlsdeved = tot_vlsdeved
           tt-proposta_limite_chq.vlpreemp = tot_vlpreemp
           tt-proposta_limite_chq.dtcalcul = par_dtmvtolt
           tt-proposta_limite_chq.vlutiliz = par_vlutiliz
           tt-proposta_limite_chq.dsobser1 = par_dsobser1
           tt-proposta_limite_chq.dsobser2 = par_dsobser2
           tt-proposta_limite_chq.dsobser3 = par_dsobser3
           tt-proposta_limite_chq.dsobser4 = par_dsobser4
           tt-proposta_limite_chq.dsmesref = par_dsmesref
           tt-proposta_limite_chq.nmcidade = par_nmcidade
           tt-proposta_limite_chq.nmrescop = par_nmrescop
           tt-proposta_limite_chq.nmresco1 = par_nmresco1
           tt-proposta_limite_chq.nmresco2 = par_nmresco2
           tt-proposta_limite_chq.nmoperad = par_nmoperad.

    RETURN "OK".







END PROCEDURE.

/*****************************************************************************
              Carrega dados para impressao do contrato de limite           
*****************************************************************************/
PROCEDURE carrega_dados_contrato_limite:

    DEFINE INPUT  PARAMETER par_nmcidade AS CHARACTER   NO-UNDO.    
    DEFINE INPUT  PARAMETER par_cdufdcop AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrctrlim AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmextcop AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dslinha1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dslinha2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dslinha3 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dslinha4 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmprimt1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmprimt2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrcpfcgc AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_txnrdcid AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdmoeda AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_vllimite AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dslimit1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dslimit2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsdlinha AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_qtdiavig AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_txqtdvi1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_txqtdvi2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsjurmo1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dsjurmo2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_txdmulta AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_txmulex1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_txmulex2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmresco1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmresco2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdaval1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdcjav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dscpfav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dscfcav1 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdaval2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdcjav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dscpfav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dscfcav2 AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmoperad AS CHARACTER   NO-UNDO.


    DEFINE OUTPUT PARAMETER TABLE FOR tt-contrato_limite_chq.

    EMPTY TEMP-TABLE tt-contrato_limite_chq.

    CREATE tt-contrato_limite_chq.
    ASSIGN tt-contrato_limite_chq.nmcidade = SUBSTR(par_nmcidade,1,15) + " " + par_cdufdcop + ",___________________________"
           tt-contrato_limite_chq.nrctrlim = par_nrctrlim
           tt-contrato_limite_chq.nmextcop = par_nmextcop 
           tt-contrato_limite_chq.cdagenci = par_cdagenci
           tt-contrato_limite_chq.dslinha1 = par_dslinha1
           tt-contrato_limite_chq.dslinha2 = par_dslinha2
           tt-contrato_limite_chq.dslinha3 = par_dslinha3
           tt-contrato_limite_chq.dslinha4 = par_dslinha4
           tt-contrato_limite_chq.nmprimt1 = par_nmprimt1
           tt-contrato_limite_chq.nmprimt2 = par_nmprimt2
           tt-contrato_limite_chq.nrdconta = par_nrdconta
           tt-contrato_limite_chq.nrcpfcgc = par_nrcpfcgc
           tt-contrato_limite_chq.txnrdcid = par_txnrdcid
           tt-contrato_limite_chq.dsdmoeda = par_dsdmoeda
           tt-contrato_limite_chq.vllimite = par_vllimite
           tt-contrato_limite_chq.dslimit1 = par_dslimit1
           tt-contrato_limite_chq.dslimit2 = par_dslimit2
           tt-contrato_limite_chq.dsdlinha = par_dsdlinha
           tt-contrato_limite_chq.qtdiavig = par_qtdiavig
           tt-contrato_limite_chq.txqtdvi1 = par_txqtdvi1
           tt-contrato_limite_chq.txqtdvi2 = par_txqtdvi2
           tt-contrato_limite_chq.dsjurmo1 = par_dsjurmo1
           tt-contrato_limite_chq.dsjurmo2 = par_dsjurmo2
           tt-contrato_limite_chq.txdmulta = STRING(par_txdmulta,"zz9.9999999")
           tt-contrato_limite_chq.txmulex1 = par_txmulex1
           tt-contrato_limite_chq.txmulex2 = par_txmulex2
           tt-contrato_limite_chq.nmresco1 = par_nmresco1
           tt-contrato_limite_chq.nmresco2 = par_nmresco2
           tt-contrato_limite_chq.nmdaval1 = par_nmdaval1
           tt-contrato_limite_chq.nmdcjav1 = par_nmdcjav1
           tt-contrato_limite_chq.dscpfav1 = par_dscpfav1
           tt-contrato_limite_chq.dscfcav1 = par_dscfcav1
           tt-contrato_limite_chq.nmdaval2 = par_nmdaval2
           tt-contrato_limite_chq.nmdcjav2 = par_nmdcjav2
           tt-contrato_limite_chq.dscpfav2 = par_dscpfav2
           tt-contrato_limite_chq.dscfcav2 = par_dscfcav2
           tt-contrato_limite_chq.nmoperad = par_nmoperad.

    RETURN "OK".           

END PROCEDURE.


/****************************************************************************
                  Buscar borderos de uma conta informada                  
****************************************************************************/
PROCEDURE busca_borderos:
    
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL     NO-UNDO.
    
    DEFINE OUTPUT PARAMETER TABLE FOR tt-bordero_chq.

    DEFINE VARIABLE aux_flglibch AS LOGICAL     NO-UNDO.
    DEFINE VARIABLE aux_qtcompln AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_vlcompcr AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_qtdaprov AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_vlraprov AS DECIMAL     NO-UNDO.
    DEFINE VARIABLE aux_flcusthj AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_habrat   AS CHAR        NO-UNDO. /* P450 - Rating */
    
    
    EMPTY TEMP-TABLE tt-bordero_chq.

    FOR EACH crapbdc WHERE crapbdc.cdcooper = par_cdcooper   AND
                           crapbdc.nrdconta = par_nrdconta   NO-LOCK
                           BY crapbdc.nrborder DESCENDING:
    
        IF  crapbdc.dtlibbdc <> ?   THEN
            IF  (crapbdc.dtlibbdc < par_dtmvtolt - 90 )   THEN  /* 180 - 150 */
                DO:
                    ASSIGN aux_flglibch = NO.
                   
                    IF  crapbdc.nrdconta <> 85448  THEN
                        
                        FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper       AND
                                               crapcdb.nrdconta = crapbdc.nrdconta   AND
                                               crapcdb.nrborder = crapbdc.nrborder   AND
                                               crapcdb.dtlibera > par_dtmvtolt       NO-LOCK
                                               USE-INDEX crapcdb7:
                 
                            ASSIGN aux_flglibch = YES.
                            LEAVE.
                        END.
                        
                    IF  NOT aux_flglibch  THEN  
                       NEXT. 
                END.
    
        ASSIGN aux_vlraprov = 0
               aux_qtdaprov = 0.
        
        FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper       AND
                               crapcdb.nrdconta = crapbdc.nrdconta   AND
                               crapcdb.nrborder = crapbdc.nrborder   AND
                               crapcdb.insitana = 1 NO-LOCK:
          
          ASSIGN aux_vlraprov = aux_vlraprov + crapcdb.vlcheque
                 aux_qtdaprov = aux_qtdaprov + 1.
          
        END.
        
        FIND craplot WHERE craplot.cdcooper = par_cdcooper       AND
                           craplot.dtmvtolt = crapbdc.dtmvtolt   AND
                           craplot.cdagenci = crapbdc.cdagenci   AND
                           craplot.cdbccxlt = crapbdc.cdbccxlt   AND
                           craplot.nrdolote = crapbdc.nrdolote   NO-LOCK NO-ERROR.
                           
        IF   NOT AVAILABLE craplot   THEN
             ASSIGN aux_qtcompln = 0
                    aux_vlcompcr = 0.
        ELSE
             ASSIGN aux_qtcompln = craplot.qtcompln
                    aux_vlcompcr = craplot.vlcompcr.
    
    
        ASSIGN aux_flcusthj = 0.
        IF crapbdc.insitbdc = 1 OR
           crapbdc.insitbdc = 2 THEN
          DO:   
            /* Verificar se no bordero existe cheques custodiados hoje */
            FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper     
                               AND crapcdb.nrdconta = crapbdc.nrdconta   
                               AND crapcdb.nrborder = crapbdc.nrborder  NO-LOCK,
                EACH crapcst WHERE crapcst.cdcooper = crapcdb.cdcooper
                               AND crapcst.nrdconta = crapcdb.nrdconta
                               AND crapcst.nrborder = crapcdb.nrborder
                               AND crapcst.cdcmpchq = crapcdb.cdcmpchq
                               AND crapcst.cdbanchq = crapcdb.cdbanchq
                               AND crapcst.cdagechq = crapcdb.cdagechq
                               AND crapcst.nrcheque = crapcdb.nrcheque
                               AND crapcst.nrctachq = crapcdb.nrctachq
                               AND crapcst.dtmvtolt = par_dtmvtolt      NO-LOCK:
          
              ASSIGN aux_flcusthj = 1.
              LEAVE.
          
            END.
          END.

        CREATE tt-bordero_chq.
        ASSIGN tt-bordero_chq.dtmvtolt = crapbdc.dtmvtolt
               tt-bordero_chq.nrborder = crapbdc.nrborder
               tt-bordero_chq.nrctrlim = crapbdc.nrctrlim
               tt-bordero_chq.qtcompln = aux_qtcompln 
               tt-bordero_chq.vlcompcr = aux_vlcompcr
               tt-bordero_chq.dssitbdc = IF crapbdc.dtrejeit <> ? THEN
                                            "REJEITADO"
                                         ELSE
                                         IF crapbdc.insitbdc = 1 THEN
                                            "EM ESTUDO"
                                         ELSE 
                                         IF crapbdc.insitbdc = 2 THEN
                                            "ANALISE"
                                         ELSE 
                                         IF crapbdc.insitbdc = 3 THEN
                                            "LIBERADO"
                                         ELSE
                                            STRING(crapbdc.insitbdc) + "DEVOLVIDO"
               tt-bordero_chq.nrdolote = crapbdc.nrdolote
               tt-bordero_chq.dtlibbdc = crapbdc.dtlibbdc
               tt-bordero_chq.qtdaprov = aux_qtdaprov
               tt-bordero_chq.vlraprov = aux_vlraprov
               tt-bordero_chq.flcusthj = aux_flcusthj.

        /* ***** inicio P450  ****/
        FIND FIRST crapprm WHERE crapprm.nmsistem = 'CRED' AND
                                 crapprm.cdacesso = 'HABILITA_RATING_NOVO' AND
                                 crapprm.cdcooper = par_cdcooper
                                 NO-LOCK NO-ERROR.

        ASSIGN aux_habrat = 'N'.
          IF AVAIL crapprm THEN DO:
            ASSIGN aux_habrat = crapprm.dsvlrprm.
          END.

         /* Habilita novo rating */
         IF aux_habrat = 'S' AND par_cdcooper <> 3 THEN DO:

           { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

           /* Efetuar a chamada a rotina Oracle da RATI0003, para buscar os ratings das propostas */
           RUN STORED-PROCEDURE pc_retorna_inf_rating
             aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper, 
                                                  INPUT par_nrdconta,
                                                  INPUT 92,
                                                  INPUT crapbdc.nrborder, 
                                                  OUTPUT 0,           /* pr_insituacao_rating */
                                                  OUTPUT "",          /* pr_inorigem_rating */
                                                  OUTPUT "",          /* pr_inrisco_rating_autom */
                                                  OUTPUT 0,           /* pr_cdcritic */
                                                  OUTPUT "").         /* pr_dscritic */

           /* Fechar o procedimento para buscarmos o resultado */ 
           CLOSE STORED-PROC pc_retorna_inf_rating
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

           { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

           ASSIGN aux_cdcritic               = 0
                  aux_dscritic               = ""
                  tt-bordero_chq.inrisrat    = ""
                  tt-bordero_chq.origerat    = ""
                  aux_cdcritic               = INT(pc_retorna_inf_rating.pr_cdcritic) 
                                               WHEN pc_retorna_inf_rating.pr_cdcritic <> ?
                  aux_dscritic               = pc_retorna_inf_rating.pr_dscritic
                                               WHEN pc_retorna_inf_rating.pr_dscritic <> ?
                  tt-bordero_chq.inrisrat    = pc_retorna_inf_rating.pr_inrisco_rating_autom
                                               WHEN pc_retorna_inf_rating.pr_inrisco_rating_autom <> ?
                  tt-bordero_chq.origerat    = pc_retorna_inf_rating.pr_inorigem_rating
                                               WHEN pc_retorna_inf_rating.pr_inrisco_rating_autom <> ?.
         END.
         /* Habilita novo rating */
         /* ***** fim P450  ****/
    
    END.  /*  Fim da leitura do crapbdc  */

    RETURN "OK".
END PROCEDURE. 

/*****************************************************************************
                  Buscar dados de um determinado bordero                   
*****************************************************************************/
PROCEDURE busca_dados_bordero:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO. 
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrborder AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddopcao AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL     NO-UNDO.
    
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dscchq_dados_bordero.
    
    DEFINE VARIABLE aux_cdtipdoc AS INTEGER             NO-UNDO.
    DEFINE VARIABLE aux_cdopecoo AS CHARACTER           NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-dscchq_dados_bordero.
                         
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        DO:
            ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).

            IF  par_cddopcao = "C"  THEN
                aux_dstransa = "Carregar dados para consulta de bordero de " +
                               "desconto de cheque".
            ELSE
            IF  par_cddopcao = "I"  THEN
                aux_dstransa = "Carregar dados para inclusao de bordero de " +
                               "desconto de cheque".
            ELSE
            IF  par_cddopcao = "L"  THEN
                aux_dstransa = "Carregar dados para liberacao do bordero de " +
                               "desconto de cheque".
            ELSE
            IF  par_cddopcao = "N"  THEN
                aux_dstransa = "Carregar dados para analise do bordero de " +
                               "desconto de cheque".
            ELSE
            IF  par_cddopcao = "E"  THEN
                aux_dstransa = "Carregar dados para exclusao do bordero de " +
                               "desconto de cheque".
            ELSE
            IF  par_cddopcao = "M"  THEN
                aux_dstransa = "Carregar dados para impressao do bordero de " +
                               "desconto de cheque".
            ELSE
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Opcao invalida.".
                       
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                           
                IF  par_flgerlog  THEN
                DO:
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
                    
                    RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                            INPUT "nrborder",
                                            INPUT "",
                                            INPUT par_nrborder).
                
                END.
                                      
                RETURN "NOK".
            END.
        END.
    
    
    FIND crapbdc WHERE crapbdc.cdcooper = par_cdcooper AND
                       crapbdc.nrborder = par_nrborder NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapbdc  THEN
    DO:
        ASSIGN aux_cdcritic = 0.
               aux_dscritic = "Registro de bordero nao encontrado.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).            
        
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

        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                INPUT "nrborder",
                                INPUT "",
                                INPUT par_nrborder).
        
        RETURN "NOK".
    END.
        
    IF  par_cddopcao = "N"  OR
        par_cddopcao = "E"  THEN
    DO:  
        IF  crapbdc.insitbdc > 2   THEN
        DO:
            ASSIGN aux_cdcritic = 0.
                   aux_dscritic = "O bordero deve estar na situacao EM ESTUDO ou ANALISE.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
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
            
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrborder",
                                    INPUT "",
                                    INPUT par_nrborder).
         
            RETURN "NOK".                    
        END.
    END.
    ELSE
    IF  par_cddopcao = "L"  THEN
    DO:
        IF  crapbdc.insitbdc <> 2  THEN
        DO:
            ASSIGN aux_cdcritic = 0.
                   aux_dscritic = "O bordero deve estar na situacao ANALISADO.".
  
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
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
            
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrborder",
                                    INPUT "",
                                    INPUT par_nrborder).
        
            RETURN "NOK".                
        END.
    END.
    ELSE
    IF  par_cddopcao = "I"  THEN
    DO:  
    IF  crapbdc.insitbdc = 1  THEN  /* EM ESTUDO */ 
        DO:
            ASSIGN aux_cdcritic = 0.
                   aux_dscritic = "O bordero deve estar na situacao ANALISE ou LIBERADO.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
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
            
            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrborder",
                                    INPUT "",
                                    INPUT par_nrborder).

            RETURN "NOK".                    
        END.
    END.
    
    FIND crapldc WHERE crapldc.cdcooper = par_cdcooper       AND
                       crapldc.cddlinha = crapbdc.cddlinha   AND
                       crapldc.tpdescto = 2
                       NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapldc  THEN
    DO:
        ASSIGN aux_cdcritic = 0.
               aux_dscritic = "Regisro de linha de desconto nao encontrada.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT par_cdagenci,
                       INPUT par_nrdcaixa,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        
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

        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                INPUT "nrborder",
                                INPUT "",
                                INPUT par_nrborder).

        RETURN "NOK".
    END.

    /* Documentos computados ......................................... */
    FIND craplot WHERE craplot.cdcooper = par_cdcooper       AND
                       craplot.dtmvtolt = crapbdc.dtmvtolt   AND
                       craplot.cdagenci = crapbdc.cdagenci   AND
                       craplot.cdbccxlt = crapbdc.cdbccxlt   AND
                       craplot.nrdolote = crapbdc.nrdolote   NO-LOCK NO-ERROR.
                       
    IF  NOT AVAILABLE craplot  THEN
    DO:
       ASSIGN aux_cdcritic = 0
              aux_dscritic = "Registro de lote nao encontrado.".

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT 1,            /** Sequencia **/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).
       
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

       RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                               INPUT "nrborder",
                               INPUT "",
                               INPUT par_nrborder).
                      
       RETURN "NOK".
    END.
        
    IF  par_cddopcao = "L" OR par_cddopcao = "N"  THEN
    DO:
        IF  craplot.qtinfoln <> craplot.qtcompln   OR
            craplot.vlinfodb <> craplot.vlcompdb   OR
            craplot.vlinfocr <> craplot.vlcompcr   THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "O lote do bordero nao esta fechado.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                
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

                RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                        INPUT "nrborder",
                                        INPUT "",
                                        INPUT par_nrborder).
                
                RETURN "NOK".
            END.
    END.

    CREATE tt-dscchq_dados_bordero.
    /* Operadores ............................................... */
    FIND crapope WHERE crapope.cdcooper = par_cdcooper      AND
                       crapope.cdoperad = crapbdc.cdoperad  NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapope  THEN
        ASSIGN tt-dscchq_dados_bordero.dsopedig = STRING(crapbdc.cdoperad) + "- NAO CADASTRADO".
    ELSE
        ASSIGN tt-dscchq_dados_bordero.dsopedig = ENTRY(1,crapope.nmoperad," ").

    IF  crapbdc.dtlibbdc <> ?  THEN             /*  Quem liberou  */
    DO:
        FIND crapope WHERE crapope.cdcooper = par_cdcooper     AND
                           crapope.cdoperad = crapbdc.cdopelib
                           NO-LOCK NO-ERROR.

        IF  NOT AVAILABLE crapope  THEN
            ASSIGN tt-dscchq_dados_bordero.dsopelib = STRING(crapbdc.cdopelib) + "- NAO CADASTRADO".
        ELSE
            ASSIGN tt-dscchq_dados_bordero.dsopelib = ENTRY(1,crapope.nmoperad," ").
    END.

    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND         
                   craptab.nmsistem = "CRED"        AND         
                   craptab.tptabela = "GENERI"      AND         
                   craptab.cdempres = 00            AND         
                   craptab.cdacesso = "DIGITALIZA"  AND
                   craptab.tpregist = 2 
                   NO-LOCK NO-ERROR.                          

    ASSIGN aux_cdtipdoc = INTE(ENTRY(3,craptab.dstextab,";")).

    ASSIGN tt-dscchq_dados_bordero.nrborder = crapbdc.nrborder
           tt-dscchq_dados_bordero.nrctrlim = crapbdc.nrctrlim
           tt-dscchq_dados_bordero.insitbdc = crapbdc.insitbdc
           tt-dscchq_dados_bordero.txmensal = crapbdc.txmensal
           tt-dscchq_dados_bordero.dtlibbdc = crapbdc.dtlibbdc
           tt-dscchq_dados_bordero.txdiaria = crapldc.txdiaria
           tt-dscchq_dados_bordero.txjurmor = crapldc.txjurmor
           tt-dscchq_dados_bordero.qtcheque = craplot.qtcompln
           tt-dscchq_dados_bordero.vlcheque = craplot.vlcompcr
           tt-dscchq_dados_bordero.dspesqui = STRING(crapbdc.dtmvtolt,"99/99/9999") + "-" +
                                              STRING(crapbdc.cdagenci,"999")        + "-" +
                                              STRING(crapbdc.cdbccxlt,"999")        + "-" +
                                              STRING(crapbdc.nrdolote,"999999")     + "-" +
                                              STRING(crapbdc.hrtransa,"HH:MM:SS")
           tt-dscchq_dados_bordero.dsdlinha = STRING(crapbdc.cddlinha,"999") + "-" + crapldc.dsdlinha
           tt-dscchq_dados_bordero.flgdigit = crapbdc.flgdigit
           tt-dscchq_dados_bordero.cdtipdoc = aux_cdtipdoc

           tt-dscchq_dados_bordero.dsopecoo = ""
           aux_cdopecoo = "".

    /* Verifica se tem operador coordenador de liberacao ou analise */
    IF crapbdc.cdopcolb <> " " THEN
    DO:
       ASSIGN aux_cdopecoo = crapbdc.cdopcolb.
    END.
    ELSE
    DO:
       IF crapbdc.cdopcoan <> " " THEN
       DO:
          ASSIGN aux_cdopecoo = crapbdc.cdopcoan.
       END.
    END.

    IF aux_cdopecoo <> "" THEN
    DO:
       FIND crapope WHERE crapope.cdcooper = par_cdcooper  AND
                          crapope.cdoperad = aux_cdopecoo  NO-LOCK NO-ERROR.
       IF  AVAILABLE crapope  THEN
           ASSIGN tt-dscchq_dados_bordero.dsopecoo = aux_cdopecoo + " - " + crapope.nmoperad.
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
                           
        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                INPUT "nrborder",
                                INPUT "",
                                INPUT par_nrborder).
    END.    
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
        Buscar cheques de um determinado bordero a partir da crapcdb       
*****************************************************************************/
PROCEDURE busca_cheques_bordero:
                                          
    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrborder AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.

    DEFINE OUTPUT PARAMETER TABLE FOR tt-chqs_do_bordero.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-dscchq_bordero_restricoes.

    DEFINE VARIABLE rel_dscpfcgc AS CHARACTER   NO-UNDO.
    DEFINE VARIABLE rel_nmcheque AS CHARACTER   NO-UNDO.
    
    EMPTY TEMP-TABLE tt-dscchq_bordero_restricoes.
    EMPTY TEMP-TABLE tt-chqs_do_bordero.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper   AND
                           crapcdb.nrborder = par_nrborder   AND
                           crapcdb.nrdconta = par_nrdconta   NO-LOCK
                              USE-INDEX crapcdb7
                                      BY crapcdb.dtlibera 
                                         BY crapcdb.cdbanchq
                                            BY crapcdb.cdagechq
                                               BY crapcdb.nrctachq 
                                                  BY crapcdb.nrcheque:
        IF crapcdb.cdbanchq = 85 THEN
          DO:
            FIND FIRST crapcop WHERE crapcop.cdagectl = crapcdb.cdagechq NO-LOCK NO-ERROR.
            
            IF  NOT AVAILABLE crapcop  THEN
              ASSIGN rel_dscpfcgc = "NAO CADASTRADO"
                     rel_nmcheque = "NAO CADASTRADO".
            ELSE
              DO:
                FIND FIRST crapass WHERE crapass.cdcooper = crapcop.cdcooper AND
                                         crapass.nrdconta = crapcdb.nrctachq 
                                         NO-LOCK NO-ERROR.
             
                IF  NOT AVAILABLE crapass  THEN
                    ASSIGN rel_dscpfcgc = "NAO CADASTRADO"
                           rel_nmcheque = "NAO CADASTRADO".
                ELSE
                  DO:
                      IF  crapass.inpessoa = 1  THEN
                        DO:
                            FIND FIRST crapttl WHERE crapttl.cdcooper = crapcop.cdcooper AND
                                                     crapttl.nrdconta = crapcdb.nrctachq
                                                     NO-LOCK NO-ERROR.
                            
                            ASSIGN rel_nmcheque = TRIM(crapttl.nmtalttl)
                                   rel_dscpfcgc = STRING(crapttl.nrcpfcgc,"99999999999")
                                   rel_dscpfcgc = STRING(rel_dscpfcgc,"xxx.xxx.xxx-xx").
                        END.
                      ELSE 
                        DO:
                            FIND FIRST crapjur WHERE crapjur.cdcooper = crapcop.cdcooper AND
                                                     crapjur.nrdconta = crapcdb.nrctachq
                                                     NO-LOCK NO-ERROR.
                            
                            ASSIGN rel_nmcheque = TRIM(crapjur.nmtalttl)
                                   rel_dscpfcgc = STRING(crapass.nrcpfcgc,"99999999999999")
                                   rel_dscpfcgc = STRING(rel_dscpfcgc,"xx.xxx.xxx/xxxx-xx").
                        END.
                  END.
              END.
          END.
        ELSE
          DO:
        FIND FIRST crapcec WHERE crapcec.cdcooper = par_cdcooper     AND
                                 crapcec.cdcmpchq = crapcdb.cdcmpchq AND
                                 crapcec.cdbanchq = crapcdb.cdbanchq AND
                                 crapcec.cdagechq = crapcdb.cdagechq AND
                                 crapcec.nrctachq = crapcdb.nrctachq AND
                                 crapcec.nrcpfcgc = crapcdb.nrcpfcgc     
                                 NO-LOCK NO-ERROR.
     
        IF  NOT AVAILABLE crapcec  THEN
            ASSIGN rel_dscpfcgc = "NAO CADASTRADO"
                   rel_nmcheque = "NAO CADASTRADO".
        ELSE
        DO:
            ASSIGN rel_nmcheque = (IF  crapcec.nrdconta > 0 THEN 
                                       "(" + TRIM(STRING(
                                       crapcec.nrdconta,"zzzz,zzz,9")) + ")"
                                   ELSE 
                                       "") + 
                                  TRIM(crapcec.nmcheque).
            IF  LENGTH(STRING(crapcec.nrcpfcgc)) > 11  THEN
                ASSIGN rel_dscpfcgc = STRING(crapcec.nrcpfcgc,"99999999999999")
                       rel_dscpfcgc = STRING(rel_dscpfcgc,"xx.xxx.xxx/xxxx-xx").
            ELSE 
                ASSIGN rel_dscpfcgc = STRING(crapcec.nrcpfcgc,"99999999999")
                       rel_dscpfcgc = STRING(rel_dscpfcgc,"xxx.xxx.xxx-xx").

        END.
        END.
       
        CREATE tt-chqs_do_bordero.
        ASSIGN tt-chqs_do_bordero.cdcmpchq = crapcdb.cdcmpchq
               tt-chqs_do_bordero.cdbanchq = crapcdb.cdbanchq
               tt-chqs_do_bordero.cdagechq = crapcdb.cdagechq
               tt-chqs_do_bordero.nrddigc1 = crapcdb.nrddigc1 
               tt-chqs_do_bordero.nrctachq = crapcdb.nrctachq
               tt-chqs_do_bordero.nrddigc2 = crapcdb.nrddigc2
               tt-chqs_do_bordero.nrcheque = crapcdb.nrcheque
               tt-chqs_do_bordero.nrddigc3 = crapcdb.nrddigc3
               tt-chqs_do_bordero.vlcheque = crapcdb.vlcheque
               tt-chqs_do_bordero.dscpfcgc = rel_dscpfcgc
               tt-chqs_do_bordero.dtlibera = crapcdb.dtlibera
               tt-chqs_do_bordero.nmcheque = rel_nmcheque
               tt-chqs_do_bordero.vlliquid = crapcdb.vlliquid
               tt-chqs_do_bordero.dtlibbdc = crapcdb.dtlibbdc
               tt-chqs_do_bordero.dtmvtolt = par_dtmvtolt.
    
        /*  Leitura das restricoes para o cheque  */
        FOR EACH crapabc WHERE crapabc.cdcooper = par_cdcooper       AND
                               crapabc.nrborder = par_nrborder       AND
                               crapabc.cdagechq = crapcdb.cdagechq   AND
                               crapabc.cdbanchq = crapcdb.cdbanchq   AND
                               crapabc.cdcmpchq = crapcdb.cdcmpchq   AND
                               crapabc.nrctachq = crapcdb.nrctachq   AND
                               crapabc.nrcheque = crapcdb.nrcheque   NO-LOCK:
    
            CREATE tt-dscchq_bordero_restricoes.
            ASSIGN tt-dscchq_bordero_restricoes.nrborder = crapcdb.nrborder
                   tt-dscchq_bordero_restricoes.nrcheque = crapcdb.nrcheque
                   tt-dscchq_bordero_restricoes.dsrestri = crapabc.dsrestri
                   tt-dscchq_bordero_restricoes.tprestri = 1
                   tt-dscchq_bordero_restricoes.flaprcoo = crapabc.flaprcoo
                   tt-dscchq_bordero_restricoes.dsdetres = crapabc.dsdetres.
            
        END.  /*  Fim do FOR EACH -- Leitura das restricoes  */
    
    END.  /*  Fim do FOR EACH  */                       

    /*  Restricoes GERAIS ....................................................... */
    FOR EACH crapabc WHERE crapabc.cdcooper = par_cdcooper   AND
                           crapabc.nrborder = par_nrborder   AND
                           crapabc.cdcmpchq = 888            AND
                           crapabc.cdagechq = 8888           AND
                           crapabc.cdbanchq = 888            AND
                           crapabc.nrctachq = 8888888888     AND
                           crapabc.nrcheque = 888888         NO-LOCK:
    
        CREATE tt-dscchq_bordero_restricoes.
        ASSIGN tt-dscchq_bordero_restricoes.nrborder = par_nrborder
               tt-dscchq_bordero_restricoes.nrcheque = 888888
               tt-dscchq_bordero_restricoes.dsrestri = crapabc.dsrestri
               tt-dscchq_bordero_restricoes.tprestri = 2
               tt-dscchq_bordero_restricoes.flaprcoo = crapabc.flaprcoo
               tt-dscchq_bordero_restricoes.dsdetres = crapabc.dsdetres.
    
    END.  /*  Fim do FOR EACH -- Leitura das restricoes GERAIS  */
               
    RETURN "OK".

END PROCEDURE.

/****************************************************************************
                             Excluir bordero                              
****************************************************************************/
PROCEDURE efetua_exclusao_bordero:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER     NO-UNDO. 
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrborder AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgelote AS LOGICAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_flresghj AS INTEGER     NO-UNDO.
    
    DEFINE OUTPUT PARAMETER TABLE FOR tt-erro.
    
    DEFINE VARIABLE aux_nrdocmto AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_contador AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_contado2 AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_flgderro AS LOGICAL     NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Efetuar exclusao de bordero de desconto " +
                              "de cheque.".
           
    TRANS_EXCLUSAO:
    DO TRANSACTION ON ERROR UNDO TRANS_EXCLUSAO, LEAVE TRANS_EXCLUSAO:
    

        /* Verificar se esta marcado para resgatar os cheques custodiados no dia de hoje */
        IF par_flresghj = 1 THEN
          DO: 
                        
            { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

            /* Resgatar cheques custodiados hoje */
            RUN STORED-PROCEDURE pc_resgata_cheques_cust_hj
            aux_handproc = PROC-HANDLE NO-ERROR ( INPUT  par_cdcooper
                                                 ,INPUT  par_cdagenci
                                                 ,INPUT  par_nrdconta
                                                 ,INPUT  par_nrborder
                                                 ,INPUT  par_cdoperad
                                                 ,INPUT  0 /* pr_flreprov -> apenas nao aprovados (1-sim,0-nao)*/
                                                 ,OUTPUT 0
                                                 ,OUTPUT "").
 
            CLOSE STORED-PROC pc_resgata_cheques_cust_hj
            aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

            { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
          
          
            ASSIGN aux_cdcritic = INTE(pc_resgata_cheques_cust_hj.pr_cdcritic)
                                  WHEN pc_resgata_cheques_cust_hj.pr_cdcritic <> ?.
          
            ASSIGN aux_dscritic = pc_resgata_cheques_cust_hj.pr_dscritic
                                  WHEN pc_resgata_cheques_cust_hj.pr_dscritic <> ?.
                                            
            IF  aux_dscritic <> "" OR aux_cdcritic > 0 THEN
                DO:
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).

                    aux_flgderro = TRUE.
                    
                    UNDO TRANS_EXCLUSAO, LEAVE TRANS_EXCLUSAO.
                END.
          
          
          END.	
        
        /*Atualizar o numero do borderô do cheque para zero*/
        FOR EACH crapdcc EXCLUSIVE-LOCK
           WHERE crapdcc.cdcooper = par_cdcooper
             AND crapdcc.nrdconta = par_nrdconta
             AND crapdcc.nrborder = par_nrborder
             AND CAN-DO ('1,3', STRING(crapdcc.intipmvt))
             AND crapdcc.cdtipmvt = 1:
          
          ASSIGN crapdcc.nrborder = 0.
        END.
        
        /*Se o cheque estiver em custódia (crapcst), atualizar o numero do borderô para zero*/
        FOR EACH crapcst EXCLUSIVE-LOCK
           WHERE crapcst.cdcooper = par_cdcooper
             AND crapcst.nrdconta = par_nrdconta
             AND crapcst.nrborder = par_nrborder
             AND CAN-DO ('0,2', STRING(crapcst.insitchq)):
          
          ASSIGN crapcst.nrborder = 0.
        END.
        
        /* Apagar registro do cálculo de juros do cheque no borderô; */
        FOR EACH crapljd EXCLUSIVE-LOCK
           WHERE crapljd.cdcooper = par_cdcooper
             AND crapljd.nrdconta = par_nrdconta
             AND crapljd.nrborder = par_nrborder:
             
          DELETE crapljd.
        END.
        
        DO aux_contador = 1 TO 10:
         
            FIND crapbdc WHERE crapbdc.cdcooper = par_cdcooper   AND
                               crapbdc.nrborder = par_nrborder 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
      
            IF  NOT AVAILABLE crapbdc  THEN
                IF  LOCKED crapbdc  THEN
                DO:
                    ASSIGN aux_dscritic = "Registro de bordero em uso. Tente novamente.".
                           aux_cdcritic = 0.                    
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                END.
                ELSE
                DO:
                    ASSIGN aux_dscritic = "Registro de bordero nao encontrado."
                           aux_cdcritic = 0.
                    LEAVE.
                END.
                  
            IF crapbdc.dtrejeit <> ? THEN
            DO:
                ASSIGN aux_dscritic = "Operacao nao permitida. Bordero Rejeitado."
                       aux_cdcritic = 0.
                LEAVE.
            END.
            
            IF  crapbdc.insitbdc > 2  THEN 
            DO:
                ASSIGN aux_dscritic = "Bordero ja LIBERADO."
                       aux_cdcritic = 0.
                LEAVE.
            END.

            aux_dscritic = "".
            LEAVE.

        END. /* Final do DO .. TO */    
    
        IF  aux_dscritic <> ""  THEN
        DO:
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            
            aux_flgderro = TRUE.

            UNDO TRANS_EXCLUSAO, LEAVE TRANS_EXCLUSAO.

        END.

        /*  Exclusao dos cheques do bordero ......................................... */
        FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper      AND 
                               crapcdb.nrborder = crapbdc.nrborder  AND
                               crapcdb.nrdconta = crapbdc.nrdconta  EXCLUSIVE-LOCK
                               USE-INDEX crapcdb7:
            
            IF  crapcdb.inchqcop = 1  THEN
                DO:
                    aux_nrdocmto = INT(STRING(crapcdb.nrcheque,"999999") + STRING(crapcdb.nrddigc3,"9")).
                
                    DO aux_contador = 1 TO 10:
                
                        FIND craplau WHERE craplau.cdcooper = par_cdcooper       AND
                                           craplau.dtmvtolt = crapcdb.dtmvtolt   AND
                                           craplau.cdagenci = crapcdb.cdagenci   AND
                                           craplau.cdbccxlt = crapcdb.cdbccxlt   AND
                                           craplau.nrdolote = crapcdb.nrdolote   AND
                                   DECIMAL(craplau.nrdctabb) = crapcdb.nrctachq  AND
                                           craplau.nrdocmto = aux_nrdocmto
                                           USE-INDEX craplau1 EXCLUSIVE-LOCK 
                                           NO-ERROR NO-WAIT.
                        
                        IF  NOT AVAILABLE craplau  THEN
                            IF   LOCKED craplau  THEN
                                 DO:
                                     PAUSE 2 NO-MESSAGE.
                                     NEXT.
                                 END.                          
                        LEAVE.
                
                    END.  /*  Fim do DO TO  */
                
                    IF  AVAILABLE craplau  THEN
                        DELETE craplau.
                    END.
    
            DELETE crapcdb.                   
                           
            ASSIGN aux_contado2 = aux_contado2 + 1. /* Quantidade de Cheques excluidos - Jean (MOut´S)*/
            
        END.  /*  Fim do FOR EACH crapcdb  */
        
        /*  Exclusao das restricoes dos cheques do bordero ............... */
        FOR EACH crapabc WHERE crapabc.cdcooper = par_cdcooper      AND
                               crapabc.nrborder = crapbdc.nrborder  EXCLUSIVE-LOCK:

            DELETE crapabc.

        END.  /*  Fim do FOR EACH crapabc  */

        IF  par_flgelote  THEN
        DO:
            DO  aux_contador = 1 TO 10:

                FIND craplot WHERE craplot.cdcooper = par_cdcooper     AND
                                   craplot.dtmvtolt = crapbdc.dtmvtolt AND
                                   craplot.cdagenci = crapbdc.cdagenci AND
                                   craplot.cdbccxlt = crapbdc.cdbccxlt AND
                                   craplot.nrdolote = crapbdc.nrdolote
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                   
                IF  NOT AVAILABLE craplot   THEN
                DO:
                    IF  LOCKED craplot   THEN
                    DO:
                    ASSIGN aux_dscritic = "Registro de lote esta em uso. Tente novamente.".
                    PAUSE 1 NO-MESSAGE.
                    NEXT.
                    END.
                END.

                aux_dscritic = "".
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

                    aux_flgderro = TRUE.
                    
                    UNDO TRANS_EXCLUSAO, LEAVE TRANS_EXCLUSAO.
                END.
        
            DELETE craplot.
        
        END.
        /* Exclui o bordero */
        DELETE crapbdc.
    
    END. /* Final da transacao */
    
    IF  aux_flgderro  THEN
    DO:
        IF  par_flgerlog THEN
        DO:
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

            RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                    INPUT "nrborder",
                                    INPUT "",
                                    INPUT par_nrborder).
        END.
        
        RETURN "NOK".
    END.
    
   /* IF  par_flgerlog  THEN|
    DO: */
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
                           
        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                INPUT "Nr bordero",
                                INPUT "",
                                INPUT par_nrborder).
                                
        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                INPUT "Operador",
                                INPUT "",
                                INPUT par_cdoperad).
                                
        RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                INPUT "Quantidade de cheques",
                                INPUT "",
                                INPUT STRING(aux_contado2,"999999")).
   /* END. */    
    
    RETURN "OK".

END PROCEDURE.

/****************************************************************************/
/*                  Efetuar Analise ou liberacao do bordero                 */
/****************************************************************************/
PROCEDURE efetua_liber_anali_bordero:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER         NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdagenci AS INTEGER         NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdcaixa AS INTEGER         NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER       NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdopcoan AS CHARACTER       NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdopcolb AS CHARACTER       NO-UNDO.
    DEFINE INPUT  PARAMETER par_nmdatela AS CHARACTER       NO-UNDO.
    DEFINE INPUT  PARAMETER par_idorigem AS INTEGER         NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER         NO-UNDO.
    DEFINE INPUT  PARAMETER par_idseqttl AS INTEGER         NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE            NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtopr AS DATE            NO-UNDO.
    DEFINE INPUT  PARAMETER par_inproces AS INTEGER         NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrborder AS INTEGER         NO-UNDO.
    DEFINE INPUT  PARAMETER par_cddopcao AS CHARACTER       NO-UNDO.
    DEFINE INPUT  PARAMETER par_inconfir AS INTEGER         NO-UNDO.
    DEFINE INPUT  PARAMETER par_inconfi2 AS INTEGER         NO-UNDO.
    DEFINE INPUT  PARAMETER par_inconfi3 AS INTEGER         NO-UNDO.
    DEFINE INPUT  PARAMETER par_inconfi4 AS INTEGER         NO-UNDO.
    DEFINE INPUT  PARAMETER par_inconfi5 AS INTEGER         NO-UNDO.
    DEFINE INPUT  PARAMETER par_inconfi6 AS INTEGER         NO-UNDO.
    DEFINE INPUT-OUTPUT  PARAMETER par_indrestr AS INTEGER  NO-UNDO.
    DEFINE INPUT-OUTPUT  PARAMETER par_indentra AS INTEGER  NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgerlog AS LOGICAL         NO-UNDO.
    
    DEFINE OUTPUT  PARAMETER TABLE FOR tt-erro.
    DEFINE OUTPUT  PARAMETER TABLE FOR tt-risco.
    DEFINE OUTPUT  PARAMETER TABLE FOR tt-msg-confirma.
    DEFINE OUTPUT PARAMETER TABLE FOR tt-grupo. 

    DEFINE VARIABLE aux_vltotcdb AS DECIMAL NO-UNDO.
    DEFINE VARIABLE tab_vllimite AS DECIMAL NO-UNDO.
    DEFINE VARIABLE tab_qtdiavig AS INTEGER NO-UNDO.
    DEFINE VARIABLE tab_qtrenova AS DECIMAL NO-UNDO.
    DEFINE VARIABLE tab_qtprzmin AS DECIMAL NO-UNDO.
    DEFINE VARIABLE tab_qtprzmax AS DECIMAL NO-UNDO.
    DEFINE VARIABLE tab_txdmulta AS DECIMAL NO-UNDO.
    DEFINE VARIABLE tab_vlconchq AS DECIMAL NO-UNDO.
    DEFINE VARIABLE tab_vlmaxemi AS DECIMAL NO-UNDO.
    DEFINE VARIABLE tab_pcchqemi AS DECIMAL NO-UNDO.
    DEFINE VARIABLE tab_qtdevchq AS INTEGER NO-UNDO.
    DEFINE VARIABLE tab_pctolera AS INTEGER NO-UNDO.
    DEFINE VARIABLE tab_pcchqloc AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_contamsg AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_contareg AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_contador AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_vlr_maxleg   AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_vlr_maxutl   AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_vlr_minscr   AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_vlr_excedido AS LOGICAL NO-UNDO.
    DEFINE VARIABLE aux_vlutiliz AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_diaratin AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_vlrmaior AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_recid    AS RECID   NO-UNDO.
    DEFINE VARIABLE aux_dtmvtolt AS DATE    NO-UNDO.
    DEFINE VARIABLE aux_txdiaria AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_vlborder AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_qtdprazo AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_vlcheque AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_dtperiod AS DATE    NO-UNDO.
    DEFINE VARIABLE aux_vldjuros AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_vljurper AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_dtrefjur AS DATE    NO-UNDO.
    DEFINE VARIABLE aux_contado1 AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_qtcmploc AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_qtcmpnac AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_qtdevchq AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_vltotemi AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_qttotemi AS INTEGER NO-UNDO.
    DEFINE VARIABLE flg_trocapac AS LOGICAL NO-UNDO.
    DEFINE VARIABLE aux_nrdgrupo AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_gergrupo AS CHAR    NO-UNDO.
    DEFINE VARIABLE aux_dsdrisgp AS CHAR    NO-UNDO.
    DEFINE VARIABLE aux_pertengp AS LOG     NO-UNDO.
    DEFINE VARIABLE aux_dsdrisco AS CHAR    NO-UNDO.
    DEFINE VARIABLE aux_dsoperac AS CHAR    NO-UNDO.
    DEFINE VARIABLE aux_flgimune AS INTEGER NO-UNDO.

    DEFINE VARIABLE aux_flpedsen AS LOGICAL INIT "N"                 NO-UNDO.
    DEFINE VARIABLE aux_nrsequen AS INTE                             NO-UNDO.

    DEF VAR aux_cdpactra LIKE crapope.cdpactra                       NO-UNDO.

    DEFINE VARIABLE h-b1wgen9999 AS HANDLE  NO-UNDO.
    DEFINE VARIABLE h-b1wgen0138 AS HANDLE  NO-UNDO.   
    DEFINE VARIABLE h-b1wgen0110 AS HANDLE  NO-UNDO.
    DEFINE VARIABLE h-b1wgen0159 AS HANDLE  NO-UNDO.
    
    DEFINE BUFFER crabcdb  FOR crapcdb.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-risco.
    EMPTY TEMP-TABLE tt-msg-confirma.
    
    DEFINE VARIABLE aux_qtdiaiof AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_periofop AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_vliofcal AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_vltotiof AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_inpessoa AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_vltotaliofsn AS DECIMAL NO-UNDO.
    
    DEFINE VARIABLE aux_natjurid AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_tpregtrb AS INTEGER NO-UNDO.
    DEFINE VARIABLE aux_vltotiofpri AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_vltotiofadi AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_vltotiofcpl AS DECIMAL NO-UNDO.
    DEFINE VARIABLE aux_vltotoperac AS DECIMAL NO-UNDO.
    
    ASSIGN aux_dscritic = ""
           aux_cdcritic = 0.
    
    /* Pega o PA de trabalho do operador para compor o numero do lote 
      (19000 + crapope.cdpactra) */
    FIND crapope WHERE crapope.cdcooper = par_cdcooper AND
                       crapope.cdoperad = par_cdoperad 
                       NO-LOCK NO-ERROR.

    IF AVAIL crapope THEN
        ASSIGN aux_cdpactra = crapope.cdpactra.
    ELSE
        ASSIGN aux_cdpactra = 0.

    TRANS_LIBERA:
    DO TRANSACTION ON ERROR UNDO TRANS_LIBERA, LEAVE TRANS_LIBERA:

       IF par_flgerlog  THEN
          DO:
              ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,",")).
              IF par_cddopcao = "N"  THEN
                 ASSIGN aux_dstransa = "Efetuar analise de bordero de " +
                                       "desconto de cheque".
              ELSE
                 IF par_cddopcao = "L"  THEN
                    ASSIGN aux_dstransa = "Efetuar liberacao de bordero " +
                                          "de desconto de cheque".
          END.
                                
       FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                          crapass.nrdconta = par_nrdconta 
                          NO-LOCK NO-ERROR.
   
       IF NOT AVAILABLE crapass  THEN
          DO:
              ASSIGN aux_cdcritic = 9
                     aux_dscritic = "".
          
              UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
               
          END.

       ASSIGN aux_inpessoa = crapass.inpessoa.


       /* Busca dados da pessoa jurídica */
       FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                          crapjur.nrdconta = par_nrdconta 
                          NO-LOCK NO-ERROR.
       IF  NOT AVAIL(crapjur)  THEN
          DO:
            ASSIGN aux_natjurid = 0.
            ASSIGN aux_tpregtrb = 0.
          END.
        ELSE
          DO:
            ASSIGN aux_natjurid = crapjur.natjurid.
            ASSIGN aux_tpregtrb = crapjur.tpregtrb.
          END.
        


       DO aux_contador = 1 TO 10:
    
          FIND crapbdc WHERE crapbdc.cdcooper = par_cdcooper   AND
                             crapbdc.nrborder = par_nrborder 
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
         
          IF NOT AVAILABLE crapbdc   THEN
             IF LOCKED crapbdc   THEN
                DO:
                    ASSIGN aux_dscritic = "Registro de bordero em uso. " + 
                                          "Tente novamente."
                           aux_cdcritic = 0.
                    PAUSE 1 NO-MESSAGE.
                    NEXT.

                END.
             ELSE
                DO:
                    ASSIGN aux_dscritic = "Registro de bordero nao encontrado."
                           aux_cdcritic = 0.
                    LEAVE.

                END.
                    
             IF  par_cddopcao = "N" AND crapbdc.insitbdc > 2  THEN
                 DO:
                     ASSIGN aux_cdcritic = 0.
                            aux_dscritic = "O bordero deve estar na situacao " +
                                           "EM ESTUDO ou ANALISADO.".
                     LEAVE.
                 END.
            
             IF  par_cddopcao = "L" AND crapbdc.insitbdc <> 2  THEN
                 DO:
                     ASSIGN aux_cdcritic = 0.
                            aux_dscritic = "O bordero deve estar na situacao " +
                                           "ANALISADO.".   
                     LEAVE.                      
                 END.
             
             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "".
          LEAVE.
    
       END. /* Final do DO .. TO */    


       IF aux_dscritic <> ""  THEN
          DO:  
              UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
          END.    
    
       RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

       IF NOT VALID-HANDLE(h-b1wgen9999)  THEN
          DO: 
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Handle invalido para h-b1wgen9999.".
       
              UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.             
          END.

       RUN busca_iof IN h-b1wgen9999 (INPUT par_cdcooper,
                                      INPUT 0, /* agenci */
                                      INPUT 0, /* caixa  */
                                      INPUT par_dtmvtolt,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-iof).
                                  
       RUN busca_iof_simples_nacional IN h-b1wgen9999 (INPUT par_cdcooper,
                                      INPUT 0, /* agenci */
                                      INPUT 0, /* caixa  */
                                      INPUT par_dtmvtolt,
                                      INPUT 'VLIOFOPSN',
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT TABLE tt-iof-sn).
       DELETE PROCEDURE h-b1wgen9999.
    
       IF RETURN-VALUE = "NOK"  THEN
          DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
             IF AVAIL tt-erro  THEN
                DO:
                    UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                END.
             ELSE
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Registro da tabela de IOF nao " + 
                                          "encontrada.".
                
                    UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                END.

          END.
        

       FIND FIRST tt-iof NO-LOCK NO-ERROR.
        
       FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper  AND
                                craplim.nrdconta = par_nrdconta  AND
                                craplim.tpctrlim = 2             AND
                                craplim.insitlim = 2             
                                NO-LOCK NO-ERROR.
     
       IF NOT AVAILABLE craplim  THEN 
          DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Registro de limites nao encontrado.".
          
              UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.

          END.
    
       ASSIGN aux_dtmvtolt = par_dtmvtolt
              aux_vltotcdb = 0.
       
       RUN busca_dados_risco (INPUT par_cdcooper,
                              OUTPUT TABLE tt-risco).
       
       FIND FIRST tt-risco WHERE tt-risco.diaratin <> 0 NO-LOCK NO-ERROR.
       
       IF AVAILABLE tt-risco  THEN
          ASSIGN aux_dtmvtolt = (aux_dtmvtolt - tt-risco.diaratin). /* 180 dias */

       FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper       AND
                              crapcdb.nrdconta = crapbdc.nrdconta   AND
                              crapcdb.insitchq = 2                  AND
                              crapcdb.dtlibera > par_dtmvtolt      
                              NO-LOCK:
      
           ASSIGN aux_vltotcdb = aux_vltotcdb + crapcdb.vlcheque.
      
       END.  /*  Fim do FOR EACH  -- crapcdb  */
    

       RUN busca_parametros_dscchq (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT par_cdoperad,
                                    INPUT par_dtmvtolt,
                                    INPUT par_idorigem,
                                    INPUT crapass.inpessoa,
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-dados_dscchq).
      
       IF RETURN-VALUE = "NOK" THEN
          DO:
              UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
          END.

       /* Validar migracao de PA de Cooperativa */
       ASSIGN flg_trocapac = FALSE.
       
       FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper       AND
                              crapcdb.nrborder = crapbdc.nrborder   AND
                              crapcdb.nrdconta = crapbdc.nrdconta 
                              NO-LOCK:
                                  
           IF crapcdb.dtlibera > 12/31/2010  THEN
              DO:
                  ASSIGN flg_trocapac = TRUE.    
                  LEAVE.
              END.
       
       END.                               

       IF flg_trocapac          AND
          crapass.cdcooper = 2  AND
          crapass.cdagenci = 5  THEN
          DO:
              ASSIGN aux_cdcritic = 0
                     aux_dscritic = "Bordero possui cheque com vencto " +
                                    "superior a 31/12/2010.".
             
              UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
          END. 

       ASSIGN tab_vllimite = tt-dados_dscchq.vllimite
              tab_qtdiavig = tt-dados_dscchq.qtdiavig
              tab_qtrenova = tt-dados_dscchq.qtrenova
              tab_qtprzmin = tt-dados_dscchq.qtprzmin
              tab_qtprzmax = tt-dados_dscchq.qtprzmax
              tab_txdmulta = tt-dados_dscchq.pcdmulta
              tab_vlconchq = tt-dados_dscchq.vlconchq
              tab_vlmaxemi = tt-dados_dscchq.vlmaxemi
              tab_pcchqemi = tt-dados_dscchq.pcchqemi
              tab_pctolera = tt-dados_dscchq.pctolera
              tab_pcchqloc = tt-dados_dscchq.pcchqloc
              tab_qtdevchq = tt-dados_dscchq.qtdevchq
              aux_contamsg = 0
              aux_contareg = 0.

       
       /*  Leitura dos cheques do bordero a ser analisado ......................  */
       FOR EACH crabcdb WHERE crabcdb.cdcooper = par_cdcooper       AND
                              crabcdb.nrborder = crapbdc.nrborder   AND
                              crabcdb.nrdconta = crapbdc.nrdconta   AND
                              crabcdb.dtdevolu = ?                 
                              NO-LOCK BY crabcdb.nrseqdig:

          IF crabcdb.cdcmpchq = 16   THEN             /*  COMPE local  */
             ASSIGN aux_qtcmploc = aux_qtcmploc + 1.
          ELSE                             
             ASSIGN aux_qtcmpnac = aux_qtcmpnac + 1.  /*  COMPE nacional  */
          
          /**proc_devol_emitente**/
          ASSIGN aux_qtdevchq = 0.

          FOR EACH crapcec WHERE crapcec.cdcooper = par_cdcooper       AND
                                 crapcec.nrcpfcgc = crabcdb.nrcpfcgc   
                                 NO-LOCK:
              
              ASSIGN aux_qtdevchq = aux_qtdevchq + crapcec.qtchqdev.
          
          END.
          /**proc_devol_emitente**/
          
          /**proc_maximo_emitente**/
          ASSIGN aux_vltotemi = 0
                 aux_qttotemi = 0.
                                            /*  Nao valida para os cheques  */
          IF crabcdb.nrcpfcgc <> 0   THEN   /*  que vieram da custodia  */           
             DO:
                FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper     AND
                                       crapcdb.nrcpfcgc = crabcdb.nrcpfcgc AND
                                       crapcdb.insitchq = 0                
                                       NO-LOCK USE-INDEX crapcdb8:
                
                    IF CAN-FIND(tt-abc_dscchq WHERE tt-abc_dscchq.nrrecabc = RECID(crapcdb)) THEN
                       NEXT.               /*  Verifica se ja foi analisado  */
                
                    ASSIGN aux_vltotemi = aux_vltotemi + crapcdb.vlcheque
                           aux_qttotemi = aux_qttotemi + 1.
                
                END.  /*  Fim do FOR EACH  -- crapcdb  */
                
                IF aux_vltotemi > tab_vlmaxemi   THEN
                   DO:
                      DO aux_contador = 1 TO 10:
                
                         FIND crapabc WHERE crapabc.nrborder = crapbdc.nrborder   AND
                                            crapabc.cdcooper = par_cdcooper       AND
                                            crapabc.cdagechq = crabcdb.cdagechq   AND
                                            crapabc.cdbanchq = crabcdb.cdbanchq   AND
                                            crapabc.cdcmpchq = crabcdb.cdcmpchq   AND
                                            crapabc.nrctachq = crabcdb.nrctachq   AND
                                            crapabc.nrcheque = crabcdb.nrcheque   AND
                                            crapabc.cdocorre = 1
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                         
                         IF NOT AVAILABLE crapabc  THEN
                            DO:
                               IF  LOCKED crapabc  THEN
                                   DO:
                                       PAUSE 1 NO-MESSAGE.
                                       ASSIGN aux_cdcritic = 341.
                                       NEXT.
                                   END.
                               ELSE
                                   DO:
                                      CREATE crapabc.
                                      ASSIGN crapabc.nrborder = crapbdc.nrborder
                                             crapabc.cdcmpchq = crabcdb.cdcmpchq
                                             crapabc.cdagechq = crabcdb.cdagechq
                                             crapabc.cdbanchq = crabcdb.cdbanchq
                                             crapabc.nrctachq = crabcdb.nrctachq
                                             crapabc.nrcheque = crabcdb.nrcheque
                                             crapabc.cdocorre = 1
                                             crapabc.cdcooper = par_cdcooper.
                                   END.           
                            END.
                   
                         ASSIGN aux_cdcritic = 0.  
                         LEAVE.
                
                      END. /* Fim do DO ... TO */
                
                      IF  aux_cdcritic > 0  THEN
                          DO:
                              UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.          
                          END.        
                
                      ASSIGN crapabc.cdoperad = par_cdoperad
                             crapabc.dsrestri = "Valor maximo permitido por emitente excedido."
                             crapabc.dsdetres = "Qtde: " + STRING(aux_qttotemi,"zz9") + ". Valor: " + STRING(aux_vltotemi,"zzzzz,zz9.99")
                             crapabc.nrdconta = crabcdb.nrdconta
                             crapabc.nrcpfcgc = crabcdb.nrcpfcgc
                             crapabc.flaprcoo = TRUE
                      
                             aux_flpedsen     = TRUE
                             par_indrestr     = 1.

                      VALIDATE crapabc.
                   END.     
                ELSE
                   DO:
                      DO aux_contador = 1 TO 10:
                      
                         FIND crapabc WHERE crapabc.nrborder = crapbdc.nrborder   AND
                                            crapabc.cdcooper = par_cdcooper       AND
                                            crapabc.cdagechq = crabcdb.cdagechq   AND
                                            crapabc.cdbanchq = crabcdb.cdbanchq   AND
                                            crapabc.cdcmpchq = crabcdb.cdcmpchq   AND
                                            crapabc.nrctachq = crabcdb.nrctachq   AND
                                            crapabc.nrcheque = crabcdb.nrcheque   AND
                                            crapabc.cdocorre = 1
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                      
                         IF AVAILABLE crapabc  THEN
                            DELETE crapabc.
                         ELSE
                           IF LOCKED crapabc  THEN
                              DO:
                                  ASSIGN aux_cdcritic = 341.
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT.
                              END.
                             
                         ASSIGN aux_cdcritic = 0.
                         LEAVE.
                      
                      END.  /*  Fim do DO WHILE TRUE  */
                
                      IF aux_cdcritic > 0  THEN
                         DO:     
                             UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                         END.        
                   END.
                
                /*-----  Quantidade de Cheques Devolvidos ----------*/
                IF aux_qtdevchq  > tab_qtdevchq THEN
                   DO:
                      DO aux_contador = 1 TO 10:
                      
                         FIND crapabc WHERE crapabc.cdcooper = par_cdcooper       AND
                                            crapabc.nrborder = crapbdc.nrborder   AND
                                            crapabc.cdagechq = crabcdb.cdagechq   AND
                                            crapabc.cdbanchq = crabcdb.cdbanchq   AND
                                            crapabc.cdcmpchq = crabcdb.cdcmpchq   AND
                                            crapabc.nrctachq = crabcdb.nrctachq   AND
                                            crapabc.nrcheque = crabcdb.nrcheque   AND
                                            crapabc.cdocorre = 6
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                         IF NOT AVAILABLE crapabc  THEN
                            DO:
                               IF LOCKED crapabc  THEN
                                  DO:
                                      ASSIGN aux_cdcritic = 341.
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT.
                                  END.
                               ELSE
                                  DO:
                                     CREATE crapabc.

                                     ASSIGN crapabc.nrborder = crapbdc.nrborder
                                            crapabc.cdcmpchq = crabcdb.cdcmpchq
                                            crapabc.cdagechq = crabcdb.cdagechq
                                            crapabc.cdbanchq = crabcdb.cdbanchq
                                            crapabc.nrctachq = crabcdb.nrctachq
                                            crapabc.nrcheque = crabcdb.nrcheque
                                            crapabc.cdocorre = 6
                                            crapabc.cdcooper = par_cdcooper.
                                  END.           

                            END.
                
                         ASSIGN aux_cdcritic = 0.     
                         LEAVE.
                       
                      END. /* Fim do DO ... TO */
                
                      IF aux_cdcritic > 0  THEN
                         DO:
                             UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                         END.        
                
                      ASSIGN crapabc.cdoperad = par_cdoperad
                             crapabc.dsrestri = "Quantidade maxima de cheques devolvidos por emitente excedida"
                             crapabc.dsdetres = STRING(aux_qtdevchq)
                             crapabc.nrcheque = crabcdb.nrcheque
                             crapabc.nrdconta = crabcdb.nrdconta
                             crapabc.nrcpfcgc = crabcdb.nrcpfcgc
                             crapabc.flaprcoo = TRUE
                      
                             aux_flpedsen     = TRUE
                             par_indrestr     = 1.

                      VALIDATE crapabc.
                   END.      
                ELSE
                   DO:
                      DO aux_contador = 1 TO 10:
                      
                         FIND crapabc WHERE crapabc.cdcooper = par_cdcooper       AND
                                            crapabc.nrborder = crapbdc.nrborder   AND
                                            crapabc.cdagechq = crabcdb.cdagechq   AND
                                            crapabc.cdbanchq = crabcdb.cdbanchq   AND
                                            crapabc.cdcmpchq = crabcdb.cdcmpchq   AND
                                            crapabc.nrctachq = crabcdb.nrctachq   AND
                                            crapabc.nrcheque = crabcdb.nrcheque   AND
                                            crapabc.cdocorre = 6
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                      
                         IF AVAILABLE crapabc  THEN
                            DELETE crapabc.
                         ELSE
                            IF LOCKED crapabc  THEN
                               DO:
                                   ASSIGN aux_cdcritic = 341.
                                   PAUSE 1 NO-MESSAGE.
                                   NEXT.
                               END.
                      
                         ASSIGN aux_cdcritic = 0.
                         LEAVE.
                      
                      END. /* Fim do DO ... TO */
                
                      IF aux_cdcritic > 0  THEN
                         DO:
                             UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                         END.        

                   END.
                /*-------------------------------------------------------------*/
                 
                IF ((aux_vltotemi / craplim.vllimite) * 100) > tab_pcchqemi THEN
                   DO:
                      DO aux_contador = 1 TO 10:
                 
                         FIND crapabc WHERE crapabc.cdcooper = par_cdcooper       AND
                                            crapabc.nrborder = crapbdc.nrborder   AND
                                            crapabc.cdagechq = crabcdb.cdagechq   AND
                                            crapabc.cdbanchq = crabcdb.cdbanchq   AND
                                            crapabc.cdcmpchq = crabcdb.cdcmpchq   AND
                                            crapabc.nrctachq = crabcdb.nrctachq   AND
                                            crapabc.nrcheque = crabcdb.nrcheque   AND
                                            crapabc.cdocorre = 2
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                         
                         IF NOT AVAILABLE crapabc   THEN
                            DO:
                               IF LOCKED crapabc   THEN
                                  DO:
                                      ASSIGN aux_cdcritic = 341.
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT.
                                  END.
                               ELSE
                                  DO:
                                     CREATE crapabc.
                                     ASSIGN crapabc.nrborder = crapbdc.nrborder
                                            crapabc.cdcmpchq = crabcdb.cdcmpchq
                                            crapabc.cdagechq = crabcdb.cdagechq
                                            crapabc.cdbanchq = crabcdb.cdbanchq
                                            crapabc.nrctachq = crabcdb.nrctachq
                                            crapabc.nrcheque = crabcdb.nrcheque
                                            crapabc.cdocorre = 2
                                            crapabc.cdcooper = par_cdcooper.
                                  END.

                            END.

                         ASSIGN aux_cdcritic = 0.
                         LEAVE.
                   
                      END. /* Fim do DO ... TO */
                
                      IF aux_cdcritic > 0  THEN
                         DO:  
                             UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                         END.

                      ASSIGN crapabc.cdoperad = par_cdoperad
                             crapabc.dsrestri = "Percentual de cheques do " + 
                                                "emitente excedido no contrato."
                             crapabc.nrcheque = crabcdb.nrcheque
                             crapabc.nrdconta = crabcdb.nrdconta
                             crapabc.nrcpfcgc = crabcdb.nrcpfcgc
                             par_indrestr     = 1.

                      VALIDATE crapabc.
                   END.
                ELSE
                   DO:
                      DO aux_contador = 1 TO 10:
                
                         FIND crapabc WHERE crapabc.cdcooper = par_cdcooper       AND
                                            crapabc.nrborder = crapbdc.nrborder   AND
                                            crapabc.cdagechq = crabcdb.cdagechq   AND
                                            crapabc.cdbanchq = crabcdb.cdbanchq   AND
                                            crapabc.cdcmpchq = crabcdb.cdcmpchq   AND
                                            crapabc.nrctachq = crabcdb.nrctachq   AND
                                            crapabc.nrcheque = crabcdb.nrcheque   AND
                                            crapabc.cdocorre = 2
                                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       
                         IF AVAILABLE crapabc  THEN
                            DELETE crapabc.
                         ELSE
                           IF LOCKED crapabc   THEN
                              DO:
                                  ASSIGN aux_cdcritic = 341.
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT.
                              END.
                           
                         ASSIGN aux_cdcritic = 0.
                         LEAVE.
                       
                      END. /* Fim do DO ... TO */
                
                      IF aux_cdcritic > 0  THEN
                         DO:
                             UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                         END.

                   END.
             
             END.
          /**proc_maximo_emitente**/
          
          /**proc_maximo_contrato**/
          ASSIGN aux_vltotcdb = aux_vltotcdb + crabcdb.vlcheque.

          IF aux_vltotcdb > (craplim.vllimite * (1 + (tab_pctolera / 100))) THEN
             DO:
                DO aux_contador = 1 TO 10:

                   FIND crapabc WHERE crapabc.cdcooper = par_cdcooper       AND
                                      crapabc.nrborder = crapbdc.nrborder   AND
                                      crapabc.cdagechq = crabcdb.cdagechq   AND
                                      crapabc.cdbanchq = crabcdb.cdbanchq   AND
                                      crapabc.cdcmpchq = crabcdb.cdcmpchq   AND
                                      crapabc.nrctachq = crabcdb.nrctachq   AND
                                      crapabc.nrcheque = crabcdb.nrcheque   AND
                                      crapabc.cdocorre = 3
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                   
                   IF NOT AVAILABLE crapabc  THEN
                      DO:
                         IF LOCKED crapabc  THEN
                            DO:
                                ASSIGN aux_cdcritic = 341.
                                PAUSE 1 NO-MESSAGE.
                                NEXT.
                            END.
                         ELSE
                            DO:
                                CREATE crapabc.

                                ASSIGN crapabc.nrborder = crapbdc.nrborder
                                       crapabc.cdcmpchq = crabcdb.cdcmpchq
                                       crapabc.cdagechq = crabcdb.cdagechq
                                       crapabc.cdbanchq = crabcdb.cdbanchq
                                       crapabc.nrctachq = crabcdb.nrctachq
                                       crapabc.nrcheque = crabcdb.nrcheque
                                       crapabc.cdocorre = 3
                                       crapabc.cdcooper = par_cdcooper.
                            END.

                      END.
            
                   ASSIGN aux_cdcritic = 0.
                   LEAVE.
            
                END. /* Fim do DO ... TO */

                IF aux_cdcritic > 0  THEN
                   DO:
                       UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                   END.        

                ASSIGN crapabc.cdoperad = par_cdoperad
                       crapabc.dsrestri = "Valor maximo por contrato excedido."
                       crapabc.nrcheque = crabcdb.nrcheque
                       crapabc.nrdconta = crabcdb.nrdconta
                       crapabc.nrcpfcgc = crabcdb.nrcpfcgc
                
                       par_indrestr     = 1
                       par_indentra     = 0.

                VALIDATE crapabc.
             END.
          ELSE
             DO:
                DO aux_contador = 1 TO 10:
                
                   FIND crapabc WHERE crapabc.cdcooper = par_cdcooper     AND
                                      crapabc.nrborder = crapbdc.nrborder AND
                                      crapabc.cdagechq = crabcdb.cdagechq AND
                                      crapabc.cdbanchq = crabcdb.cdbanchq AND
                                      crapabc.cdcmpchq = crabcdb.cdcmpchq AND
                                      crapabc.nrctachq = crabcdb.nrctachq AND
                                      crapabc.nrcheque = crabcdb.nrcheque AND
                                      crapabc.cdocorre = 3
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                 
                   IF AVAILABLE crapabc  THEN
                      DELETE crapabc.
                   ELSE
                     IF LOCKED crapabc  THEN
                        DO:
                            ASSIGN aux_cdcritic = 341.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                 
                   ASSIGN aux_cdcritic = 0.
                   LEAVE.
                
                END. /* Fim do DO ... TO */

                IF aux_cdcritic > 0  THEN
                   DO:
                       UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                   END.

             END.
        
          /**proc_maximo_contrato**/

          /**proc_consulta_cheque**/
          IF crabcdb.vlcheque >= tab_vlconchq   THEN
             DO:
                DO aux_contador = 1 TO 10:
             
                   FIND crapabc WHERE crapabc.cdcooper = par_cdcooper       AND
                                      crapabc.nrborder = crapbdc.nrborder   AND
                                      crapabc.cdagechq = crabcdb.cdagechq   AND
                                      crapabc.cdbanchq = crabcdb.cdbanchq   AND
                                      crapabc.cdcmpchq = crabcdb.cdcmpchq   AND
                                      crapabc.nrctachq = crabcdb.nrctachq   AND
                                      crapabc.nrcheque = crabcdb.nrcheque   AND
                                      crapabc.cdocorre = 4
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                   
                   IF NOT AVAILABLE crapabc  THEN
                      DO:
                          IF LOCKED crapabc  THEN
                             DO:
                                 ASSIGN aux_cdcritic = 341.
                                 PAUSE 1 NO-MESSAGE.
                                 NEXT.
                             END.
                          ELSE
                             DO:
                                CREATE crapabc.

                                ASSIGN crapabc.nrborder = crapbdc.nrborder
                                       crapabc.cdcmpchq = crabcdb.cdcmpchq
                                       crapabc.cdagechq = crabcdb.cdagechq
                                       crapabc.cdbanchq = crabcdb.cdbanchq
                                       crapabc.nrctachq = crabcdb.nrctachq
                                       crapabc.nrcheque = crabcdb.nrcheque
                                       crapabc.cdocorre = 4
                                       crapabc.cdcooper = par_cdcooper.
                             END.           
                      END.
             
                   ASSIGN aux_cdcritic = 0.     
                   LEAVE.
             
                END. /* Fim do DO ... TO */

                IF aux_cdcritic > 0  THEN
                   DO:
                       UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                   END.

                ASSIGN crapabc.cdoperad = par_cdoperad
                       crapabc.dsrestri = "Consultar o cheque."
                       crapabc.nrcheque = crabcdb.nrcheque
                       crapabc.nrdconta = crabcdb.nrdconta
                       crapabc.nrcpfcgc = crabcdb.nrcpfcgc
                    
                       par_indrestr     = 1.

                VALIDATE crapabc.

             END.
          ELSE
             DO:
                DO aux_contador = 1 TO 10:
                 
                   FIND crapabc WHERE crapabc.cdcooper = par_cdcooper     AND
                                      crapabc.nrborder = crapbdc.nrborder AND
                                      crapabc.cdagechq = crabcdb.cdagechq AND
                                      crapabc.cdbanchq = crabcdb.cdbanchq AND
                                      crapabc.cdcmpchq = crabcdb.cdcmpchq AND
                                      crapabc.nrctachq = crabcdb.nrctachq AND
                                      crapabc.nrcheque = crabcdb.nrcheque AND
                                      crapabc.cdocorre = 4
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                 
                   IF AVAILABLE crapabc  THEN
                      DELETE crapabc.
                   ELSE
                     IF LOCKED crapabc  THEN
                        DO:
                            ASSIGN aux_cdcritic = 341.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                 
                   ASSIGN aux_cdcritic = 0.       
                   LEAVE.
             
                END. /* Fim do DO ... TO */

                IF aux_cdcritic > 0  THEN
                   DO:
                       UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                   END.

             END.

           /**proc_consulta_cheque**/

           /**proc_liberacao**/

           IF crabcdb.dtlibera <= (par_dtmvtolt + tab_qtprzmin)      OR
              crabcdb.dtlibera >= (par_dtmvtolt + tab_qtprzmax)      OR
              crabcdb.dtlibera >= (craplim.dtinivig +
                                  (craplim.qtdiavig * tab_qtrenova)) THEN
              DO:
                 DO aux_contador = 1 TO 10:
                 
                    FIND crapabc WHERE crapabc.cdcooper = par_cdcooper     AND
                                       crapabc.nrborder = crapbdc.nrborder AND
                                       crapabc.cdagechq = crabcdb.cdagechq AND
                                       crapabc.cdbanchq = crabcdb.cdbanchq AND
                                       crapabc.cdcmpchq = crabcdb.cdcmpchq AND
                                       crapabc.nrctachq = crabcdb.nrctachq AND
                                       crapabc.nrcheque = crabcdb.nrcheque AND
                                       crapabc.cdocorre = 5
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                  
                    IF NOT AVAILABLE crapabc   THEN
                       DO:
                           IF LOCKED crapabc   THEN
                              DO:
                                  ASSIGN aux_cdcritic = 341.
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT.
                              END.
                           ELSE
                              DO:
                                  CREATE crapabc.

                                  ASSIGN crapabc.nrborder = crapbdc.nrborder
                                         crapabc.cdcmpchq = crabcdb.cdcmpchq
                                         crapabc.cdagechq = crabcdb.cdagechq
                                         crapabc.cdbanchq = crabcdb.cdbanchq
                                         crapabc.nrctachq = crabcdb.nrctachq
                                         crapabc.nrcheque = crabcdb.nrcheque
                                         crapabc.cdocorre = 5
                                         crapabc.cdcooper = par_cdcooper.
                              END.

                       END.
             
                    ASSIGN aux_cdcritic = 0. 
                    LEAVE.
                                    
                 END. /* Fim do DO ... TO */
    
                 IF aux_cdcritic > 0  THEN
                    DO:
                        UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                    END.
               
                 ASSIGN crapabc.cdoperad = par_cdoperad
                        crapabc.dsrestri = "Data de liberacao fora dos limites."
                        crapabc.nrcheque = crabcdb.nrcheque
                        crapabc.nrdconta = crabcdb.nrdconta
                        crapabc.nrcpfcgc = crabcdb.nrcpfcgc
                      
                        par_indrestr     = 1.

                 VALIDATE crapabc.

              END.
           ELSE
              DO:
                 DO aux_contador = 1 TO 10:
                 
                    FIND crapabc WHERE crapabc.cdcooper = par_cdcooper     AND
                                       crapabc.nrborder = crapbdc.nrborder AND
                                       crapabc.cdagechq = crabcdb.cdagechq AND
                                       crapabc.cdbanchq = crabcdb.cdbanchq AND
                                       crapabc.cdcmpchq = crabcdb.cdcmpchq AND
                                       crapabc.nrctachq = crabcdb.nrctachq AND
                                       crapabc.nrcheque = crabcdb.nrcheque AND
                                       crapabc.cdocorre = 5
                                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                 
                    IF AVAILABLE crapabc  THEN
                       DELETE crapabc.
                    ELSE
                       IF LOCKED crapabc  THEN
                          DO:
                              ASSIGN aux_cdcritic = 341.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                       
                    ASSIGN aux_cdcritic = 0.
                    LEAVE.
                                         
                 END. /* Fim do DO ... TO */
            
                 IF aux_cdcritic > 0  THEN
                    DO:
                        UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                    END.
              END.

           /**proc_liberacao**/

           /**proc_consulta_spc**/
           FOR EACH crapass WHERE crapass.cdcooper = par_cdcooper      AND
                                  crapass.nrcpfcgc = crabcdb.nrcpfcgc  AND
                                  crapass.dtdemiss = ?                 
                                  NO-LOCK:
                                
               IF crapass.inadimpl = 1   THEN
                  DO:
                     DO aux_contador = 1 TO 10:

                        FIND crapabc 
                             WHERE crapabc.cdcooper = par_cdcooper      AND
                                   crapabc.nrborder = crapbdc.nrborder  AND
                                   crapabc.cdagechq = crabcdb.cdagechq  AND
                                   crapabc.cdbanchq = crabcdb.cdbanchq  AND
                                   crapabc.cdcmpchq = crabcdb.cdcmpchq  AND
                                   crapabc.nrctachq = crabcdb.nrctachq  AND
                                   crapabc.nrcheque = crabcdb.nrcheque  AND
                                   crapabc.cdocorre = 7
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                  
                        IF NOT AVAILABLE crapabc   THEN
                           DO:
                              IF LOCKED crapabc   THEN
                                 DO:
                                     ASSIGN aux_cdcritic = 341.
                                     PAUSE 1 NO-MESSAGE.
                                     NEXT.
                                 END.
                              ELSE
                                 DO:
                                     CREATE crapabc.

                                     ASSIGN crapabc.nrborder = crapbdc.nrborder
                                            crapabc.cdcmpchq = crabcdb.cdcmpchq
                                            crapabc.cdagechq = crabcdb.cdagechq
                                            crapabc.cdbanchq = crabcdb.cdbanchq
                                            crapabc.nrctachq = crabcdb.nrctachq
                                            crapabc.nrcheque = crabcdb.nrcheque
                                            crapabc.cdocorre = 7
                                            crapabc.cdcooper = par_cdcooper.
                                 END.

                           END.
                  
                        ASSIGN aux_cdcritic = 0.
                        LEAVE.
                  
                     END. /* Fim do DO ... TO */

                     IF aux_cdcritic > 0  THEN
                        DO:
                            UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                        END.

                     ASSIGN crapabc.cdoperad = par_cdoperad
                            crapabc.dsrestri = "CPF consta no SPC"
                            crapabc.nrcheque = crabcdb.nrcheque
                            crapabc.nrdconta = crabcdb.nrdconta
                            crapabc.nrcpfcgc = crabcdb.nrcpfcgc
                          
                            par_indrestr     = 1.

                     VALIDATE crapabc.

                  END.
               ELSE
                  DO:
                     DO aux_contador = 1 TO 10:
                     
                        FIND crapabc 
                             WHERE crapabc.cdcooper = par_cdcooper      AND
                                   crapabc.nrborder = crapbdc.nrborder  AND
                                   crapabc.cdagechq = crabcdb.cdagechq  AND
                                   crapabc.cdbanchq = crabcdb.cdbanchq  AND
                                   crapabc.cdcmpchq = crabcdb.cdcmpchq  AND
                                   crapabc.nrctachq = crabcdb.nrctachq  AND
                                   crapabc.nrcheque = crabcdb.nrcheque  AND
                                   crapabc.cdocorre = 7
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                       
                        IF AVAILABLE crapabc   THEN
                           DELETE crapabc.
                        ELSE
                           IF LOCKED crapabc   THEN
                              DO:
                                  ASSIGN aux_cdcritic = 341.
                                  PAUSE 1 NO-MESSAGE.
                                  NEXT.
                              END.
                       
                        ASSIGN aux_cdcritic = 0.
                       
                        LEAVE.
                       
                     END. /* Fim do DO ... TO */

                     IF aux_cdcritic > 0  THEN
                        DO:
                            UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                        END.
                  END.

           END.

           /**proc_consulta_spc**/

           CREATE tt-abc_dscchq.
           ASSIGN tt-abc_dscchq.nrrecabc = RECID(crabcdb).
           
           IF crabcdb.dtlibera <= par_dtmvtolt   THEN
              DO:
                 ASSIGN aux_cdcritic = 0
                        aux_dscritic = "Ha cheques com data de liberacao " + 
                                       "igual ou inferior a data do movimento.".
             
                 UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.      

              END.        

       END.  /*  Fim do FOR EACH crabcdb  */
    

       IF ((aux_qtcmploc / (aux_qtcmploc + aux_qtcmpnac)) * 100) < tab_pcchqloc THEN
          DO:
             DO aux_contador = 1 TO 10:

                FIND crapabc WHERE crapabc.cdcooper = par_cdcooper       AND
                                   crapabc.nrborder = crapbdc.nrborder   AND
                                   crapabc.cdcmpchq = 888                AND
                                   crapabc.cdagechq = 8888               AND
                                   crapabc.cdbanchq = 888                AND
                                   crapabc.nrctachq = 8888888888         AND
                                   crapabc.nrcheque = 888888             AND
                                   crapabc.cdocorre = 88
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
         
                IF NOT AVAILABLE crapabc   THEN
                   DO:
                       IF LOCKED crapabc   THEN
                          DO:
                              PAUSE 1 NO-MESSAGE.
                              ASSIGN aux_cdcritic = 341.
                              NEXT.
                          END.
                       ELSE
                          DO:
                              CREATE crapabc.

                              ASSIGN crapabc.nrborder = crapbdc.nrborder
                                     crapabc.cdcmpchq = 888   
                                     crapabc.cdagechq = 8888
                                     crapabc.cdbanchq = 888
                                     crapabc.nrctachq = 8888888888
                                     crapabc.nrcheque = 888888
                                     crapabc.cdocorre = 88
                                     crapabc.cdcooper = par_cdcooper.
                          END.

                   END.
         
                ASSIGN aux_cdcritic = 0.
                LEAVE.
         
             END. /* Fim do DO ... TO */

             IF aux_cdcritic > 0  THEN
                DO:
                    UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                END.

             ASSIGN crapabc.cdoperad = par_cdoperad
                    crapabc.dsrestri = "COMPE local com volume de " +
                                       "cheques inferior ao permitido."
                    crapabc.nrdconta = 88888888
                    crapabc.nrcpfcgc = 99999999999999
             
                    par_indrestr     = 1.

             VALIDATE crapabc.

          END.
       ELSE
          DO:
             DO aux_contador = 1 TO 10:

                FIND crapabc WHERE crapabc.cdcooper = par_cdcooper       AND
                                   crapabc.nrborder = crapbdc.nrborder   AND
                                   crapabc.cdcmpchq = 888                AND
                                   crapabc.cdagechq = 8888               AND
                                   crapabc.cdbanchq = 888                AND
                                   crapabc.nrctachq = 8888888888         AND
                                   crapabc.nrcheque = 888888             AND
                                   crapabc.cdocorre = 88
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                IF AVAILABLE crapabc   THEN
                   DELETE crapabc.
                ELSE
                   IF LOCKED crapabc   THEN
                      DO:
                         PAUSE 1 NO-MESSAGE.
                         ASSIGN aux_cdcritic = 341.
                         NEXT.
                      END.
                
                ASSIGN aux_cdcritic = 0.         
                LEAVE.
         
             END. /* Fim do DO ... TO */

             IF aux_cdcritic > 0  THEN
                DO:
                    UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.                 
                END.

          END.
    
       /* Se possui restricoes executa o bloco */
       IF  par_indrestr = 1    AND 
          (par_cddopcao = "N"  OR
           par_cddopcao = "L") THEN
           DO:
              /****************************************/
              ASSIGN aux_vlr_excedido = NO
                     aux_vlr_maxleg = 0
                     aux_vlr_maxutl = 0
                     aux_vlr_minscr = 0.
              
              FIND crapcop WHERE crapcop.cdcooper = par_cdcooper 
                                 NO-LOCK NO-ERROR.
              
              IF AVAIL crapcop THEN
                 ASSIGN aux_vlr_maxleg = crapcop.vlmaxleg
                        aux_vlr_maxutl = crapcop.vlmaxutl
                        aux_vlr_minscr = crapcop.vlcnsscr.
              
              
              IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                 RUN sistema/generico/procedures/b1wgen0138.p
                     PERSISTENT SET h-b1wgen0138.
         
              ASSIGN aux_pertengp = DYNAMIC-FUNCTION ("busca_grupo" 
                                                       IN h-b1wgen0138,
                                                       INPUT par_cdcooper,
                                                       INPUT par_nrdconta,
                                                       OUTPUT aux_nrdgrupo,
                                                       OUTPUT aux_gergrupo,
                                                       OUTPUT aux_dsdrisgp).
              
              IF VALID-HANDLE(h-b1wgen0138) THEN
                 DELETE OBJECT h-b1wgen0138.


              IF par_inconfi5 = 30 THEN
                 DO:
                    IF aux_gergrupo <> "" THEN
                       DO:
                          CREATE tt-msg-confirma.
                          
                          ASSIGN tt-msg-confirma.inconfir = par_inconfi5 + 1
                                 tt-msg-confirma.dsmensag = aux_gergrupo + 
                                                            " Confirma?".
              
                          RETURN "OK".
              
                       END.
                  END.


              IF aux_pertengp THEN
                 DO:
                    IF NOT VALID-HANDLE(h-b1wgen0138) THEN
                       RUN sistema/generico/procedures/b1wgen0138.p
                           PERSISTENT SET h-b1wgen0138.

                    /* Procedure responsavel por calcular o endividamento 
                       do grupo */
                    RUN calc_endivid_grupo IN h-b1wgen0138
                                                (INPUT par_cdcooper,
                                                 INPUT par_cdagenci, 
                                                 INPUT par_nrdcaixa, 
                                                 INPUT par_cdoperad, 
                                                 INPUT par_dtmvtolt, 
                                                 INPUT par_nmdatela, 
                                                 INPUT par_idorigem, 
                                                 INPUT aux_nrdgrupo, 
                                                 INPUT TRUE, /*Cons. por conta*/
                                                OUTPUT aux_dsdrisco, 
                                                OUTPUT aux_vlutiliz,
                                                OUTPUT TABLE tt-grupo, 
                                                OUTPUT TABLE tt-erro).
             
                    IF VALID-HANDLE(h-b1wgen0138) THEN
                       DELETE OBJECT h-b1wgen0138.
                    
                    IF RETURN-VALUE <> "OK" THEN
                       RETURN "NOK".
                    
                    IF par_inconfi2 > 10  AND
                       par_inconfi3 = 21  THEN
                       IF aux_vlr_maxutl > 0  THEN
                          DO:
                             ASSIGN aux_vlrmaior = 0. 
                          
                             IF par_inconfi2 = 11 THEN
                                DO:
                                   IF (aux_vlutiliz + aux_vlrmaior) > 
                                                   aux_vlr_maxutl THEN
                                   DO:
                                      CREATE tt-msg-confirma.

                                      ASSIGN tt-msg-confirma.inconfir = 
                                                              par_inconfi2 + 1
                                             tt-msg-confirma.dsmensag = 
                                                "Vlrs(Utl) Excedidos (Utiliz. " +
                                                TRIM(STRING(aux_vlutiliz,
                                                            "zzz,zzz,zz9.99"))  + 
                                                " Excedido " +
                                                TRIM(STRING((aux_vlutiliz + 
                                                             aux_vlrmaior - 
                                                             aux_vlr_maxutl),
                                                             "zzz,zzz,zz9.99")) +
                                                ").Confirma? ".
                    
                                      RETURN "OK".
                    
                                   END.    

                                END.
                            
                             IF par_inconfi2 = 12 AND ((aux_vlutiliz + 
                                             aux_vlrmaior) > aux_vlr_maxleg) THEN
                                DO: 
                                   CREATE tt-msg-confirma.

                                   ASSIGN tt-msg-confirma.inconfir = 19
                                          tt-msg-confirma.dsmensag = 
                                          "Vlr(Legal) Excedido (Utiliz. " + 
                                          TRIM(STRING(aux_vlutiliz,
                                          "zzz,zzz,zz9.99")) 
                                          + " Excedido " + 
                                          TRIM(STRING((aux_vlutiliz + aux_vlrmaior 
                                          - aux_vlr_maxleg),"zzz,zzz,zz9.99")) 
                                          + ").". 
                    
                                   ASSIGN aux_dscritic = "". 
                                          aux_cdcritic = 79.
                    
                                   RUN gera_erro (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT 1,     /** Sequencia **/
                                                  INPUT aux_cdcritic,
                                                  INPUT-OUTPUT aux_dscritic).
                    
                                   RETURN "NOK".

                                END.

                          END.
                               
                    IF par_inconfi4 = 71  THEN
                       DO:
                          IF (aux_vlutiliz + aux_vlrmaior) > aux_vlr_minscr THEN
                             DO:
                                 CREATE tt-msg-confirma.
                    
                                 ASSIGN tt-msg-confirma.inconfir = par_inconfi4 + 1
                                        tt-msg-confirma.dsmensag = "Efetue consulta no SCR.".
                    
                                 RETURN "OK".
                    
                             END.
                       END.
    
                 END.
              ELSE 
                 DO:
                    IF NOT VALID-HANDLE(h-b1wgen9999) THEN
                       RUN sistema/generico/procedures/b1wgen9999.p 
                           PERSISTENT SET h-b1wgen9999.
                    
                    IF  NOT VALID-HANDLE(h-b1wgen9999)  THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = "Handle invalido para BO " + 
                                                  "b1wgen9999.".
                           
                            UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.                                           
                        END.            
           
                    RUN saldo_utiliza IN h-b1wgen9999 (INPUT par_cdcooper,
                                                       INPUT par_cdagenci,
                                                       INPUT par_nrdcaixa,
                                                       INPUT par_cdoperad,
                                                       INPUT par_nmdatela,
                                                       INPUT par_idorigem,
                                                       INPUT par_nrdconta,
                                                       INPUT par_idseqttl,
                                                       INPUT par_dtmvtolt,
                                                       INPUT par_dtmvtopr,
                                                       INPUT "",
                                                       INPUT par_inproces,
                                                       INPUT FALSE, /*Consulta por cpf*/
                                                      OUTPUT aux_vlutiliz,
                                                      OUTPUT TABLE tt-erro).
                                              
                    IF VALID-HANDLE(h-b1wgen9999) THEN
                       DELETE OBJECT h-b1wgen9999.
         
                    IF RETURN-VALUE = "NOK"  THEN
                       DO:
                           UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.            
                       END.
                    
                    IF par_inconfi2 > 10  AND
                       par_inconfi3 = 21  THEN
                       IF aux_vlr_maxutl > 0  THEN
                          DO:
                             ASSIGN aux_vlrmaior = 0. 
                          
                             IF par_inconfi2 = 11 THEN
                                DO:
                                   IF (aux_vlutiliz + aux_vlrmaior) > aux_vlr_maxutl THEN
                                   DO:
                                      CREATE tt-msg-confirma.

                                      ASSIGN tt-msg-confirma.inconfir = 
                                                              par_inconfi2 + 1
                                             tt-msg-confirma.dsmensag = 
                                             "Vlrs(Utl) Excedidos (Utiliz. " +
                                              TRIM(STRING(aux_vlutiliz,
                                              "zzz,zzz,zz9.99")) +
                                              " Excedido " +
                                              TRIM(STRING((aux_vlutiliz + 
                                              aux_vlrmaior - aux_vlr_maxutl)
                                              ,"zzz,zzz,zz9.99")) + 
                                              ").Confirma? ".

                                      RETURN "OK".

                                   END.      

                                END.
                          
                             IF par_inconfi2 = 12 AND ((aux_vlutiliz + 
                                        aux_vlrmaior) > aux_vlr_maxleg) THEN
                                DO:
                                    CREATE tt-msg-confirma.

                                    ASSIGN tt-msg-confirma.inconfir = 19
                                           tt-msg-confirma.dsmensag = 
                                           "Vlr(Legal) Excedido (Utiliz. " + 
                                           TRIM(STRING(aux_vlutiliz,
                                           "zzz,zzz,zz9.99")) 
                                           + " Excedido " + 
                                           TRIM(STRING((aux_vlutiliz + aux_vlrmaior 
                                           - aux_vlr_maxleg),"zzz,zzz,zz9.99")) 
                                           + ").". 
                                 
                                    ASSIGN aux_dscritic = "". 
                                           aux_cdcritic = 79.
                                 
                                    RUN gera_erro (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT 1,     /** Sequencia **/
                                                   INPUT aux_cdcritic,
                                                   INPUT-OUTPUT aux_dscritic).
                                 
                                    RETURN "NOK".    

                                END.

                          END.
              
                    IF par_inconfi4 = 71  THEN
                       DO:
                          IF (aux_vlutiliz + aux_vlrmaior) >  aux_vlr_minscr  THEN
                              DO:
                                 CREATE tt-msg-confirma.

                                 ASSIGN tt-msg-confirma.inconfir = par_inconfi4 + 1
                                        tt-msg-confirma.dsmensag = "Efetue consulta no SCR.".

                                 RETURN "OK".

                              END.

                       END.

                 END.

             END.
       
       IF par_cddopcao <> "N"  THEN
          DO:
             IF par_indrestr = 1  AND
                par_indentra = 1  THEN
                DO:
                    IF  par_inconfi3 = 21  THEN
                    DO:
                        CREATE tt-msg-confirma.

                        ASSIGN tt-msg-confirma.inconfir = par_inconfi3 + 1
                               tt-msg-confirma.dsmensag = "Ha RESTRICOES no " +
                                                          "bordero, liberar " +
                                                          "mesmo assim?".

                        RETURN "OK".       

                    END.

                END.
             ELSE
             IF par_indentra = 0  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Valor maximo por contrato " + 
                                          "excedido. Liberacao nao permitida.".
                
                    UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.                

                END.

          END.

       IF aux_flpedsen THEN
          DO:
              IF par_inconfi6 = 51 THEN
                 DO:
                      CREATE tt-msg-confirma.
                      ASSIGN tt-msg-confirma.inconfir = par_inconfi6 + 1.
                      RETURN "OK".
                 END.
                 
          END.

       IF par_cddopcao = "N" THEN
          DO:
              crapbdc.insitbdc = 2. /*  Analisado  */
              crapbdc.cdopcoan = par_cdopcoan. /* Operador Coordenador analise */
          END.  

       IF par_cddopcao = "L"  THEN
          DO:
             /*  Liberacao do bordero ........................................ */
             DO aux_contador = 1 TO 10:
                FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                                   craplot.dtmvtolt = par_dtmvtolt   AND
                                   craplot.cdagenci = 1              AND
                                   craplot.cdbccxlt = 100            AND
                                   craplot.nrdolote = 8477
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                IF NOT AVAILABLE craplot   THEN
                   DO:
                       IF LOCKED craplot   THEN
                          DO:                           
                              PAUSE 1 NO-MESSAGE.
                              ASSIGN aux_cdcritic = 341.
                              NEXT.
                          END.
                       ELSE
                          DO:
                              CREATE craplot.

                              ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                     craplot.cdagenci = 1
                                     craplot.cdbccxlt = 100
                                     craplot.nrdolote = 8477
                                     craplot.tplotmov = 1
                                     craplot.cdoperad = par_cdoperad
                                     craplot.cdhistor = 270
                                     craplot.cdcooper = par_cdcooper.
                          END.

                   END.
                
                ASSIGN aux_cdcritic = 0.             
                LEAVE.
             
             END. /* Fim do DO ... TO */
        
             IF aux_cdcritic > 0  THEN
                DO:
                    ASSIGN aux_dscritic = "".
                    
                    UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.

                END.

          END.
 
       /* Liberacao dos titulos */
        ASSIGN aux_vltotoperac = 0.
        FOR EACH crabcdb WHERE crabcdb.cdcooper = par_cdcooper       AND
                              crabcdb.nrborder = crapbdc.nrborder   AND
                              crabcdb.nrdconta = crapbdc.nrdconta
                               NO-LOCK:
          ASSIGN aux_vltotoperac = aux_vltotoperac + crabcdb.vlliquid.
        END.
 
       /*  Calculo do juros sobre o desconto do cheque ......................;... */
       ASSIGN aux_txdiaria = ROUND((EXP(1 + (crapbdc.txmensal / 100), 1 / 30) - 1),7)
              aux_vlborder = 0
              aux_contamsg = 0
              aux_contareg = 0
              aux_vltotiof = 0
              aux_vltotiofpri = 0
              aux_vltotiofadi = 0
              aux_vltotiofcpl = 0
              aux_vltotoperac = 0.

       FOR EACH crabcdb WHERE crabcdb.cdcooper = par_cdcooper       AND
                              crabcdb.nrborder = crapbdc.nrborder   AND
                              crabcdb.nrdconta = crapbdc.nrdconta   
                              NO-LOCK USE-INDEX crapcdb7:
                               
           DO aux_contador = 1 TO 10:
           
              FIND crapcdb WHERE RECID(crapcdb) = RECID(crabcdb)
                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
              
              IF NOT AVAILABLE crapcdb  THEN
                 DO:
                    IF LOCKED crapcdb  THEN
                       DO:
                           ASSIGN aux_cdcritic = 341.
                           PAUSE 1 NO-MESSAGE.
                           NEXT.
                       END.
                    ELSE
                       DO:
                          ASSIGN aux_dscritic = "Cheque do bordero nao " + 
                                                "encontrado.".
                       
                          UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.    

                       END.

                 END.
              
              ASSIGN aux_cdcritic = 0.
              LEAVE.
           
           END.
        
           IF aux_cdcritic > 0  THEN
              DO:
                  ASSIGN aux_dscritic = "".
                  
                  UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.

              END.
           
           ASSIGN aux_qtdprazo = crapcdb.dtlibera - par_dtmvtolt
                  aux_vlcheque = crapcdb.vlcheque
                  aux_dtperiod = par_dtmvtolt
                  aux_vldjuros = 0
                  aux_vljurper = 0.
 
           IF par_cddopcao = "L" AND
              par_idorigem = 1   THEN
              DO: 
                  ASSIGN aux_contamsg = aux_contamsg + 1
                         aux_contareg = aux_contareg + 1.
                 
                  IF aux_contamsg > 10  THEN
                     DO:
                         HIDE MESSAGE NO-PAUSE.
                         MESSAGE "Liberando registro" aux_contareg "...".
                         ASSIGN aux_contamsg = 0.

                     END.

              END.
        
           DO aux_contador = 1 TO aux_qtdprazo:
           
              ASSIGN aux_vldjuros = ROUND(aux_vlcheque * aux_txdiaria,2)
                     aux_vlcheque = aux_vlcheque + aux_vldjuros
                     
                     aux_dtperiod = aux_dtperiod + 1
                     
                     aux_dtrefjur = ((DATE(MONTH(aux_dtperiod),28,
                                     YEAR(aux_dtperiod)) + 4) -
                                     DAY(DATE(MONTH(aux_dtperiod),28,
                                               YEAR(aux_dtperiod)) + 4)).
            
              DO aux_contado1 = 1 TO 10: 
              
                 FIND tt-ljd_dscchq 
                      WHERE tt-ljd_dscchq.nrdconta = crapcdb.nrdconta   AND
                            tt-ljd_dscchq.nrborder = crapcdb.nrborder   AND
                            tt-ljd_dscchq.dtmvtolt = par_dtmvtolt       AND
                            tt-ljd_dscchq.dtrefere = aux_dtrefjur       AND
                            tt-ljd_dscchq.cdcmpchq = crapcdb.cdcmpchq   AND
                            tt-ljd_dscchq.cdbanchq = crapcdb.cdbanchq   AND
                            tt-ljd_dscchq.cdagechq = crapcdb.cdagechq   AND
                            tt-ljd_dscchq.nrctachq = crapcdb.nrctachq   AND
                            tt-ljd_dscchq.nrcheque = crapcdb.nrcheque
                            EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                                 
                 IF NOT AVAILABLE tt-ljd_dscchq   THEN
                    DO:
                       IF LOCKED tt-ljd_dscchq   THEN
                          DO:
                              ASSIGN aux_cdcritic = 341.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                       ELSE
                          DO:
                             CREATE tt-ljd_dscchq.

                             ASSIGN tt-ljd_dscchq.nrdconta = crapcdb.nrdconta
                                    tt-ljd_dscchq.nrborder = crapcdb.nrborder
                                    tt-ljd_dscchq.dtmvtolt = par_dtmvtolt
                                    tt-ljd_dscchq.dtrefere = aux_dtrefjur    
                                    tt-ljd_dscchq.cdcmpchq = crapcdb.cdcmpchq   
                                    tt-ljd_dscchq.cdbanchq = crapcdb.cdbanchq   
                                    tt-ljd_dscchq.cdagechq = crapcdb.cdagechq   
                                    tt-ljd_dscchq.nrctachq = crapcdb.nrctachq   
                                    tt-ljd_dscchq.nrcheque = crapcdb.nrcheque.

                          END.

                    END.
                      
                 ASSIGN aux_cdcritic = 0.                    
                 LEAVE. 
              
              END. /* Fim do DO ... TO */
             
              IF aux_cdcritic > 0  THEN
                 DO:
                     ASSIGN aux_dscritic = "".
                 
                     UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                 END.
                   
              ASSIGN tt-ljd_dscchq.vldjuros = tt-ljd_dscchq.vldjuros + 
                                              aux_vldjuros.
            
           END. /* Fim do DO .. TO */
 
           ASSIGN aux_vldjuros     = aux_vlcheque - crapcdb.vlcheque
                  crapcdb.dtlibbdc = IF par_cddopcao = "L" 
                                        THEN par_dtmvtolt
                                        ELSE ?
                  crapcdb.vlliquid = crapcdb.vlcheque - aux_vldjuros
                  crapcdb.insitchq = IF par_cddopcao = "N"   
                                        THEN crapcdb.insitchq
                                        ELSE 2 /*  Processado  */
                  aux_vlborder     = aux_vlborder + crapcdb.vlliquid.
                           
           /* Daniel */
           IF par_cddopcao = "L" THEN 
           DO:
              
             /* Projeto 410 - Novo IOF */
             ASSIGN aux_qtdiaiof = crapcdb.dtlibera - par_dtmvtolt.

              { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
              RUN STORED-PROCEDURE pc_calcula_valor_iof
              aux_handproc = PROC-HANDLE NO-ERROR (INPUT 3                      /* Tipo do Produto (1-> Emprestimo, 2-> Desconto Titulo, 3-> Desconto Cheque, 4-> Limite de Credito, 5-> Adiantamento Depositante) */
                                                  ,INPUT 1                      /* Tipo da Operacao (1-> Calculo IOF/Atraso, 2-> Calculo Pagamento em Atraso) */
                                                  ,INPUT par_cdcooper           /* Código da cooperativa */
                                                  ,INPUT crapbdc.nrdconta       /* Número da conta */
                                                  ,INPUT aux_inpessoa           /* Tipo de Pessoa */
                                                  ,INPUT aux_natjurid           /* Natureza Juridica */
                                                  ,INPUT aux_tpregtrb           /* Tipo de Regime Tributario */
                                                  ,INPUT par_dtmvtolt           /* Data do movimento para busca na tabela de IOF */
                                                  ,INPUT aux_qtdiaiof           /* Qde dias em atraso (cálculo IOF atraso) */
                                                  ,INPUT crapcdb.vlliquid       /* Valor liquido da operaçao */
                                                  ,INPUT aux_vltotoperac        /* Valor total da operaçao */
                                                  ,INPUT 0                      /* Valor da taxa de IOF complementar */
                                                  ,OUTPUT 0                     /* Retorno do valor do IOF principal */
                                                  ,OUTPUT 0                     /* Retorno do valor do IOF adicional */
                                                  ,OUTPUT 0                     /* Retorno do valor do IOF complementar */
                                                  ,OUTPUT 0                     /* Valor da taxa de IOF principal */
                                                  ,OUTPUT 0
                                                  ,OUTPUT "").                  /* Critica */
              /* Fechar o procedimento para buscarmos o resultado */ 
              CLOSE STORED-PROC pc_calcula_valor_iof
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
              /* Se retornou erro */
              ASSIGN aux_dscritic = ""
                     aux_dscritic = pc_calcula_valor_iof.pr_dscritic WHEN pc_calcula_valor_iof.pr_dscritic <> ?.
              IF aux_dscritic <> "" THEN
                UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
              /* Soma IOF principal */
              IF pc_calcula_valor_iof.pr_vliofpri <> ? THEN
                DO:
                  ASSIGN aux_vltotiofpri = aux_vltotiofpri + ROUND(DECI(pc_calcula_valor_iof.pr_vliofpri),2).
                END.
              /* Soma IOF adicional */
              IF pc_calcula_valor_iof.pr_vliofadi <> ? THEN
                DO:
                  ASSIGN aux_vltotiofadi = aux_vltotiofadi + ROUND(DECI(pc_calcula_valor_iof.pr_vliofadi),2).
                END.
              /* Soma IOF complementar */
              IF pc_calcula_valor_iof.pr_vliofcpl <> ? THEN
                DO:
                  ASSIGN aux_vltotiofcpl = aux_vltotiofcpl + ROUND(DECI(pc_calcula_valor_iof.pr_vliofcpl),2).
                END.
             
              /* Soma IOF complementar */
              IF pc_calcula_valor_iof.pr_flgimune <> ? THEN
                  DO:
                  ASSIGN aux_flgimune = pc_calcula_valor_iof.pr_flgimune.
           END.

           END. /* IF par_cddopcao = "L"  THEN */

       END.  /*  Fim do FOR EACH crapcdb  */

       ASSIGN aux_vltotiof = aux_vltotiofpri + aux_vltotiofadi.


       IF par_cddopcao = "L"  THEN
          DO:            

             IF aux_vlborder <= 0   THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "O valor liquido ficou negativo " + 
                                          "ou zerado.".
                  
                    UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.                      
               END.

             /*  Verifica se o lancamento ja existe */
             FIND craplcm WHERE craplcm.dtmvtolt = craplot.dtmvtolt   AND
                                craplcm.cdagenci = craplot.cdagenci   AND
                                craplcm.cdbccxlt = craplot.cdbccxlt   AND
                                craplcm.nrdolote = craplot.nrdolote   AND
                                craplcm.nrdctabb = crapbdc.nrdconta   AND
                                craplcm.nrdocmto = crapbdc.nrborder   AND
                                craplcm.cdcooper = par_cdcooper       
                                NO-LOCK NO-ERROR.

             IF  NOT AVAILABLE craplcm   THEN
                 DO:
                    /* Busca a proxima sequencia do campo crapmat.nrseqcar */
                    RUN STORED-PROCEDURE pc_sequence_progress
                    aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPLOT"
                                                        ,INPUT "NRSEQDIG"
                                                        ,INPUT STRING(par_cdcooper) + ";" + 
                                                               STRING(craplot.dtmvtolt,"99/99/9999") + ";" + 
                                                               STRING(craplot.cdagenci) + ";" +
                                                               STRING(craplot.cdbccxlt) + ";" + 
                                                               STRING(craplot.nrdolote)
                                                        ,INPUT "N"
                                                        ,"").
                                                                                            
                    CLOSE STORED-PROC pc_sequence_progress
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                                  
                    ASSIGN aux_nrsequen = INTE(pc_sequence_progress.pr_sequence)
                                           WHEN pc_sequence_progress.pr_sequence <> ?.
                                           
                    /* Cria lancamento da conta do associado */
                    CREATE craplcm.
                    ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt 
                           craplcm.cdagenci = craplot.cdagenci
                           craplcm.cdbccxlt = craplot.cdbccxlt 
                           craplcm.nrdolote = craplot.nrdolote
                           craplcm.nrdconta = crapbdc.nrdconta
                           craplcm.nrdocmto = crapbdc.nrborder
                           craplcm.vllanmto = aux_vlborder
                           craplcm.cdhistor = 270
                           craplcm.nrseqdig = aux_nrsequen
                           craplcm.nrdctabb = crapbdc.nrdconta
                           craplcm.nrdctitg = STRING(crapbdc.nrdconta,"99999999")
                           craplcm.nrautdoc = 0
                           craplcm.cdcooper = par_cdcooper
                           craplcm.cdpesqbb = "Desconto do bordero " + STRING(crapbdc.nrborder,"zzz,zzz,zz9")
                           craplot.nrseqdig = aux_nrsequen
                           craplot.qtinfoln = craplot.qtinfoln + 1
                           craplot.qtcompln = craplot.qtcompln + 1
                           craplot.vlinfocr = craplot.vlinfocr + craplcm.vllanmto
                           craplot.vlcompcr = craplot.vlcompcr + craplcm.vllanmto.
                    
                    VALIDATE craplot.
                    VALIDATE craplcm.

                    RUN buscar_valor_iof_simples_nacional(INPUT aux_vlborder,
                                                          INPUT par_cdcooper,
                                                          INPUT par_nrdconta,
                                                          INPUT TABLE tt-iof,
                                                          INPUT TABLE tt-iof-sn,
                                                          OUTPUT aux_vltotaliofsn).
                    aux_vltotiof = aux_vltotiof + aux_vltotaliofsn.
                    RUN sistema/generico/procedures/b1wgen0159.p
                            PERSISTENT SET h-b1wgen0159.

                    RUN verifica-imunidade-tributaria IN h-b1wgen0159(
                                                 INPUT par_cdcooper,
                                                 INPUT crapbdc.nrdconta,
                                                 INPUT par_dtmvtolt,
                                                 INPUT TRUE,
                                                 INPUT 3,
                                                 INPUT ROUND(aux_vltotiof, 2),
                                                OUTPUT aux_flgimune,
                                                OUTPUT TABLE tt-erro).
                                                
                    DELETE PROCEDURE h-b1wgen0159.

                    /*  Cobranca do IOF de desconto  */
                    IF  aux_flgimune <= 0  AND
                        tt-iof.txccdiof > 0 THEN         
                       DO:
                          DO aux_contador = 1 TO 10:

                             FIND craplot WHERE craplot.cdcooper = par_cdcooper   AND
                                                craplot.dtmvtolt = par_dtmvtolt   AND
                                                craplot.cdagenci = 1              AND
                                                craplot.cdbccxlt = 100            AND
                                                craplot.nrdolote = 19000 + aux_cdpactra
                                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                            
                             IF NOT AVAILABLE craplot   THEN
                                DO:
                                   IF LOCKED craplot   THEN
                                      DO:
                                         ASSIGN aux_dscritic = "Registro de "  +
                                                               "lote para IOF" +
                                                               " esta em uso." +
                                                               " Tente "       +
                                                               "novamente.".
                                         PAUSE 1 NO-MESSAGE.
                                         NEXT.

                                      END.
                                   ELSE
                                      DO:
                                         CREATE craplot.
                                         ASSIGN craplot.dtmvtolt = par_dtmvtolt
                                                craplot.cdagenci = 1
                                                craplot.cdbccxlt = 100
                                                craplot.nrdolote = 19000 + aux_cdpactra
                                                craplot.tplotmov = 1
                                                craplot.cdcooper = par_cdcooper.
                                      END.
                                END.

                             ASSIGN aux_dscritic = "".
                             LEAVE.
                             
                          END.  /*  Fim do DO .. TO  */

                          IF aux_dscritic <> ""   THEN
                             DO:
                                 ASSIGN aux_cdcritic = 0.
                          
                                 UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                             END.                                               

                          CREATE craplcm.

                          ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                                 craplcm.cdagenci = craplot.cdagenci
                                 craplcm.cdbccxlt = craplot.cdbccxlt
                                 craplcm.nrdolote = craplot.nrdolote
                                 craplcm.nrdconta = crapbdc.nrdconta
                                 craplcm.nrdctabb = crapbdc.nrdconta
                                 craplcm.nrdctitg = STRING(crapbdc.nrdconta,"99999999")
                                 craplcm.nrdocmto = crapbdc.nrborder
                                 craplcm.cdhistor = 324
                                 craplcm.nrseqdig = craplot.nrseqdig + 1
                                 craplcm.cdpesqbb = STRING(aux_vlborder,"999,999,999.99")
                                 craplcm.vllanmto = ROUND( ( ROUND(aux_vlborder * tt-iof.txccdiof,2) + aux_vltotiof ),2) 
                                 craplcm.cdcooper = par_cdcooper
                                 craplot.vlinfodb = craplot.vlinfodb + craplcm.vllanmto
                                 craplot.vlcompdb = craplot.vlcompdb + craplcm.vllanmto
                                 craplot.qtinfoln = craplot.qtinfoln + 1
                                 craplot.qtcompln = craplot.qtcompln + 1
                                 craplot.nrseqdig = craplot.nrseqdig + 1.

                          VALIDATE craplot.
                          VALIDATE craplcm.

                          /* Projeto 410 - Novo IOF */
                          ASSIGN aux_dscritic = "".
                          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} } 
                          RUN STORED-PROCEDURE pc_insere_iof                  
                          aux_handproc = PROC-HANDLE NO-ERROR (INPUT par_cdcooper           /* Codigo da Cooperativa */ 
                                                              ,INPUT crapbdc.nrdconta       /* Numero da Conta Corrente */
                                                              ,INPUT par_dtmvtolt           /* Data de Movimento */
                                                              ,INPUT 3                      /* Tipo de Produto */
                                                              ,INPUT crapbdc.nrborder       /* Numero do Contrato */
                                                              ,INPUT ?                   /* Chave: Id dos Lancamentos Futuros */
                                                              ,INPUT craplot.dtmvtolt       /* Chave: Data de Movimento Lancamento */
                                                              ,INPUT craplot.cdagenci       /* Chave: Agencia do Lancamento */
                                                              ,INPUT craplot.cdbccxlt       /* Chave: Caixa do Lancamento */
                                                              ,INPUT craplot.nrdolote       /* Chave: Lote do Lancamento */
                                                              ,INPUT craplot.nrseqdig + 1   /* Chave: Sequencia do Lancamento */
                                                              ,INPUT ROUND(aux_vltotiofpri, 2)  /* Valor do IOF Principal */
                                                              ,INPUT ROUND(aux_vltotiofadi, 2)  /* Valor do IOF Adicional */
                                                              ,INPUT ROUND(aux_vltotiofcpl, 2)  /* Valor do IOF Complementar */
                                                              ,INPUT aux_flgimune
                                                              ,OUTPUT 0                     /* Código da Crítica */
                                                              ,OUTPUT "").
                          /* Fechar o procedimento para buscarmos o resultado */ 
                          CLOSE STORED-PROC pc_insere_iof
                          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                          { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
                          /* Se retornou erro */
                          ASSIGN aux_dscritic = pc_insere_iof.pr_dscritic WHEN pc_insere_iof.pr_dscritic <> ?.
                          IF  aux_dscritic <> "" THEN          
                            UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                          

                          /* Atualiza IOF pago e base de calculo no crapcot */
                          DO  aux_contador = 1 TO 10:
                             
                              FIND crapcot WHERE crapcot.cdcooper = par_cdcooper     AND
                                                 crapcot.nrdconta = crapbdc.nrdconta 
                                                 EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                             
                              IF NOT AVAILABLE crapcot   THEN
                                 DO:
                                    IF LOCKED crapcot   THEN
                                       DO:
                                          ASSIGN aux_dscritic = "Registro de " +
                                                         "cotas para IOF "     +
                                                         "esta em uso. Tente " +
                                                         "novamente.".
                                           PAUSE 1 NO-MESSAGE.
                                           NEXT.
                                       END.
                                    ELSE
                                       DO:
                                          ASSIGN aux_dscritic = "Registro crapcot nao encontrado.~ ".
                                      
                                          UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.                        
                                       END.    
                                    
                                 END.
                             
                              ASSIGN aux_dscritic = "".
                              LEAVE.
                          
                          END.  /*  Fim do DO .. TO  */
               
                          IF aux_dscritic <> ""   THEN
                             DO:
                                 ASSIGN aux_cdcritic = 0.
                          
                                 UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                             END.                

                          ASSIGN crapcot.vliofapl = crapcot.vliofapl + 
                                                    craplcm.vllanmto
                                 crapcot.vlbsiapl = crapcot.vlbsiapl + 
                                                    aux_vlborder.
                           
                       END.

                 END.

             ASSIGN crapbdc.insitbdc = 3 /*  Liberado  */
                   /* INICIO - dados para o BI em caso de cancelamento - MACIEL (RKAM) */
                   crapbdc.cdopeori = par_cdoperad 
                   crapbdc.cdageori = par_cdagenci
                   crapbdc.dtinsori = TODAY
                   /* FIM - dados para o BI em caso de cancelamento - MACIEL (RKAM) */
                    crapbdc.dtlibbdc = par_dtmvtolt
                    crapbdc.cdopelib = par_cdoperad
                    crapbdc.cdopcolb = par_cdopcolb. /* Operador Coordenador liberacao */
            
             FOR EACH tt-ljd_dscchq:
                     
                 CREATE crapljd.

                 ASSIGN crapljd.nrdconta = tt-ljd_dscchq.nrdconta
                        crapljd.nrborder = tt-ljd_dscchq.nrborder
                        crapljd.dtmvtolt = tt-ljd_dscchq.dtmvtolt
                        crapljd.dtrefere = tt-ljd_dscchq.dtrefere
                        crapljd.nrcheque = tt-ljd_dscchq.nrcheque
                        crapljd.cdcmpchq = tt-ljd_dscchq.cdcmpchq   
                        crapljd.cdbanchq = tt-ljd_dscchq.cdbanchq   
                        crapljd.cdagechq = tt-ljd_dscchq.cdagechq   
                        crapljd.nrctachq = tt-ljd_dscchq.nrctachq
                        crapljd.vldjuros = tt-ljd_dscchq.vldjuros
                        crapljd.vlrestit = tt-ljd_dscchq.vlrestit
                        crapljd.cdcooper = par_cdcooper.

                 VALIDATE crapljd.

                 DELETE tt-ljd_dscchq.       
                     
             END.  /*  Fim do FOR EACH tt-ljd_dscchq  */      

          END.
       
        IF par_cddopcao = "N"   THEN
           DO:
               CREATE tt-msg-confirma.
               ASSIGN tt-msg-confirma.inconfir = 88.
                      tt-msg-confirma.dsmensag = "Bordero analisado "  +
                                                 IF par_indrestr = 1 THEN 
                                                    "COM restricoes!!!"
                                                 ELSE "SEM restricoes!!!".
           END.
        ELSE 
        IF  par_indentra = 1   THEN
            DO:
                CREATE tt-msg-confirma.
                ASSIGN tt-msg-confirma.inconfir = 88
                       tt-msg-confirma.dsmensag = "Bordero liberado " +
                                                  (IF par_indrestr = 1 THEN
                                                      "COM restricoes!"
                                                   ELSE "SEM restricoes!") 
                                                   + " Valor liquido de R$ "  +
                                                   TRIM(STRING(aux_vlborder,
                                                           "zzz,zzz,zz9.99")). 
            END.

        FIND CURRENT crapbdc NO-LOCK.  
        
        RELEASE crapbdc.
        RELEASE craplot.
        RELEASE craplcm.
        RELEASE crapcdb.
        RELEASE crapljd.
        RELEASE crapabc.

        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                           crapass.nrdconta = par_nrdconta 
                           NO-LOCK NO-ERROR.
    
        IF  NOT AVAILABLE crapass  THEN
            DO:
                ASSIGN aux_cdcritic = 9
                       aux_dscritic = "".
            
               UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
                 
            END.

        IF NOT VALID-HANDLE(h-b1wgen0110) THEN
           RUN sistema/generico/procedures/b1wgen0110.p
               PERSISTENT SET h-b1wgen0110.

        /*Monta a mensagem da operacao para envio no e-mail*/
        ASSIGN aux_dsoperac = "Tentativa de liberar/analisar borderos de " + 
                              "descontos de cheques na conta "             +
                              STRING(crapass.nrdconta,"zzzz,zzz,9")        +
                              " - CPF/CNPJ "                               +
                             (IF crapass.inpessoa = 1 THEN
                                 STRING((STRING(crapass.nrcpfcgc,
                                         "99999999999")),"xxx.xxx.xxx-xx")
                              ELSE
                                 STRING((STRING(crapass.nrcpfcgc,
                                               "99999999999999")),
                                               "xx.xxx.xxx/xxxx-xx")).
        
        /*Verifica se o associado esta no cadastro restritivo. Se estiver,
          sera enviado um e-mail informando a situacao*/
        RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                          INPUT par_cdagenci,
                                          INPUT par_nrdcaixa,
                                          INPUT par_cdoperad,
                                          INPUT par_nmdatela,
                                          INPUT par_dtmvtolt,
                                          INPUT par_idorigem,
                                          INPUT crapass.nrcpfcgc, 
                                          INPUT crapass.nrdconta, 
                                          INPUT par_idseqttl,
                                          INPUT TRUE, /*bloqueia operacao*/
                                          INPUT 1, /*cdoperac*/
                                          INPUT aux_dsoperac,
                                          OUTPUT TABLE tt-erro).
        
        
        IF VALID-HANDLE(h-b1wgen0110) THEN
           DELETE PROCEDURE(h-b1wgen0110).
        
        IF RETURN-VALUE <> "OK" THEN
           DO:
              IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                 DO:
                    ASSIGN aux_dscritic = "Nao foi possivel verificar o " + 
                                          "cadastro restritivo.".
                    
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
        
                 END.
        
              UNDO TRANS_LIBERA , LEAVE TRANS_LIBERA.
        
           END.
        
    
    END. /* Fim TRANSACAO */
    
    IF aux_cdcritic <> 0  OR
       aux_dscritic <> "" OR 
       (TEMP-TABLE tt-erro:HAS-RECORDS) THEN
       DO:
           IF NOT TEMP-TABLE tt-erro:HAS-RECORDS   THEN
              DO:
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
              END.
               
           IF par_flgerlog  THEN
              DO:
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
              
                  RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                          INPUT "nrborder",
                                          INPUT "",
                                          INPUT par_nrborder).
              END.
          
           RETURN "NOK".

       END.

    IF par_flgerlog  THEN
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
                              
           RUN proc_gerar_log_item(INPUT aux_nrdrowid,
                                   INPUT "nrborder",
                                   INPUT "",
                                   INPUT par_nrborder).
       END.    
    
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
                Carrega dados com os cheques do bordero                    
*****************************************************************************/
PROCEDURE carrega_dados_bordero_cheques:

    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_nrctrlim AS INTE NO-UNDO. 
    DEF INPUT PARAM par_nrborder AS INTE NO-UNDO.
    DEF INPUT PARAM par_txdiaria AS DECI NO-UNDO.
    DEF INPUT PARAM par_txmensal AS DECI NO-UNDO.
    DEF INPUT PARAM par_txdanual AS DECI NO-UNDO.
    DEF INPUT PARAM par_vllimite AS DECI NO-UNDO.
    DEF INPUT PARAM par_ddmvtolt AS INTE NO-UNDO.
    DEF INPUT PARAM par_dsmesref AS CHAR NO-UNDO.
    DEF INPUT PARAM par_aamvtolt AS INTE NO-UNDO.
    DEF INPUT PARAM par_nmprimtl AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmresco1 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmresco2 AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmcidade AS CHAR NO-UNDO.
    DEF INPUT PARAM par_nmoperad AS CHAR NO-UNDO.
    DEF INPUT PARAM par_dsopecoo AS CHAR NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-dados_chqs_bordero.
    DEF OUTPUT PARAM TABLE FOR tt-chqs_do_bordero.
    DEF OUTPUT PARAM TABLE FOR tt-dscchq_bordero_restricoes.
    
    EMPTY TEMP-TABLE tt-dados_chqs_bordero.
    EMPTY TEMP-TABLE tt-chqs_do_bordero.
    EMPTY TEMP-TABLE tt-dscchq_bordero_restricoes.
    
    RUN busca_cheques_bordero (INPUT par_cdcooper,
                               INPUT par_dtmvtolt,
                               INPUT par_nrborder,
                               INPUT par_nrdconta,
                               OUTPUT TABLE tt-chqs_do_bordero,
                               OUTPUT TABLE tt-dscchq_bordero_restricoes).    

    CREATE tt-dados_chqs_bordero.
    ASSIGN tt-dados_chqs_bordero.nrdconta = par_nrdconta
           tt-dados_chqs_bordero.cdagenci = par_cdagenci
           tt-dados_chqs_bordero.nrctrlim = par_nrctrlim
           tt-dados_chqs_bordero.nrborder = par_nrborder
           tt-dados_chqs_bordero.txdiaria = par_txdiaria
           tt-dados_chqs_bordero.txmensal = par_txmensal
           tt-dados_chqs_bordero.txdanual = par_txdanual
           tt-dados_chqs_bordero.vllimite = par_vllimite
           tt-dados_chqs_bordero.ddmvtolt = par_ddmvtolt
           tt-dados_chqs_bordero.dsmesref = par_dsmesref
           tt-dados_chqs_bordero.aamvtolt = par_aamvtolt
           tt-dados_chqs_bordero.nmprimtl = par_nmprimtl
           tt-dados_chqs_bordero.nmresco1 = par_nmresco1
           tt-dados_chqs_bordero.nmresco2 = par_nmresco2
           tt-dados_chqs_bordero.nmcidade = par_nmcidade
           tt-dados_chqs_bordero.nmoperad = par_nmoperad
           tt-dados_chqs_bordero.dsopecoo = par_dsopecoo.
    
    RETURN "OK".    

END PROCEDURE.


PROCEDURE busca_desconto_cheques:
    /*************************************************************************
        Objetivo: Buscar os contratos de emprestimos de cheques por linha de
                  credito - tela LISEPR
    *************************************************************************/
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtinicio AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dttermin AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-emprestimo.
  
    FOR EACH craplim WHERE 
             craplim.cdcooper  = par_cdcooper                        AND
             craplim.dtpropos >= par_dtinicio                        AND
             craplim.dtpropos <= par_dttermin                        AND  
             craplim.tpctrlim  = 2                                   AND
             craplim.insitlim  = 2  /* ATIVO */                      AND
            (craplim.cddlinha  = par_cdlcremp OR par_cdlcremp = 0)   NO-LOCK,
       FIRST crapass WHERE                                           
             crapass.cdcooper  = par_cdcooper                        AND
             crapass.nrdconta  = craplim.nrdconta                    AND
            (crapass.cdagenci  = par_cdagenci OR par_cdagenci = 0)   NO-LOCK
             BREAK BY crapass.cdagenci
                   BY crapass.nrdconta
                   BY craplim.nrctrlim:
                                     
        CREATE tt-emprestimo.
        ASSIGN tt-emprestimo.cdagenci = crapass.cdagenci
               tt-emprestimo.nrdconta = craplim.nrdconta
               tt-emprestimo.nmprimtl = crapass.nmprimtl
               tt-emprestimo.nrctremp = craplim.nrctrlim
               tt-emprestimo.dtmvtolt = craplim.dtinivig
               tt-emprestimo.vlemprst = craplim.vllimite 
               tt-emprestimo.cdlcremp = craplim.cddlinha
               tt-emprestimo.dtmvtprp = craplim.dtpropos
               tt-emprestimo.diaprmed = (craplim.dtinivig - craplim.dtpropos)
               tt-emprestimo.dsorigem = "cheques".

        FOR EACH crapcdb WHERE 
                 crapcdb.cdcooper = craplim.cdcooper   AND
                 crapcdb.nrdconta = craplim.nrdconta   AND
                 crapcdb.insitchq = 2 AND
                 crapcdb.dtlibera > par_dtmvtolt NO-LOCK:  
                 
            ASSIGN tt-emprestimo.vlsdeved = tt-emprestimo.vlsdeved + 
                                            crapcdb.vlcheque.
        END.
       
    END. /* FOR EACH craplim */

    RETURN "OK".

END PROCEDURE. /* Fim */

/*****************************************************************************/
/*             Funcao para encontrar Linha de Desconto de cheque             */
/*****************************************************************************/
FUNCTION linha-desc-chq RETURNS LOGICAL
        (INPUT par_cdcooper AS INT,
         INPUT par_cdagenci AS INT,                    
         INPUT par_nrdcaixa AS INT,                    
         INPUT par_cdoperad AS CHAR,                    
         INPUT par_dtmvtolt AS DATE,                    
         INPUT par_nrdconta AS INT,                    
         INPUT par_cddlinha AS INT,                    
         OUTPUT TABLE FOR tt-linhas-desc-chq):

    EMPTY TEMP-TABLE tt-linhas-desc-chq.

    FIND FIRST crapldc WHERE crapldc.cdcooper = par_cdcooper  AND
                             crapldc.tpdescto = 2             AND
                             crapldc.cddlinha = par_cddlinha 
                             NO-LOCK NO-ERROR.

    IF AVAIL crapldc THEN
       DO:
          CREATE tt-linhas-desc-chq.

          ASSIGN tt-linhas-desc-chq.cddlinha = crapldc.cddlinha
                 tt-linhas-desc-chq.dsdlinha = crapldc.dsdlinha
                 tt-linhas-desc-chq.txmensal = crapldc.txmensal.
                   
       END.
               
    RETURN TRUE.

END FUNCTION.

/*****************************************************************************/
/*             Rotina para listar linhas de desconto de cheques              */
/*****************************************************************************/
PROCEDURE lista-linhas-desc-chq:

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_cddlinha AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrregist AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nriniseq AS INTE                    NO-UNDO.

    DEF OUTPUT PARAM par_qtregist AS INTE                   NO-UNDO.     
    DEF OUTPUT PARAM TABLE FOR tt-linhas_desc.

    DEF VAR aux_nrregist AS INT.

    EMPTY TEMP-TABLE tt-linhas_desc.

    ASSIGN aux_nrregist = par_nrregist.

    FOR EACH crapldc WHERE crapldc.cdcooper = par_cdcooper     AND
                           crapldc.tpdescto = 2                AND
                           crapldc.flgstlcr = TRUE /*ATIVA*/   AND 
                          (IF par_cddlinha <> 0 THEN
                              crapldc.cddlinha = par_cddlinha 
                           ELSE 
                              TRUE) 
                           NO-LOCK BREAK BY crapldc.cddlinha:

        IF  FIRST-OF(crapldc.cddlinha) THEN
            DO:
                ASSIGN par_qtregist = par_qtregist + 1.

                    /* controles da paginaçao */
                IF  (par_qtregist < par_nriniseq) OR
                    (par_qtregist > (par_nriniseq + par_nrregist)) THEN
                    NEXT.

                IF  aux_nrregist >= 1 THEN
                DO:
                    CREATE tt-linhas_desc.
                    ASSIGN tt-linhas_desc.cddlinha = crapldc.cddlinha
                           tt-linhas_desc.dsdlinha = crapldc.dsdlinha
                           tt-linhas_desc.txmensal = crapldc.txmensal.
                    
                END.
                
                ASSIGN aux_nrregist = aux_nrregist - 1.

            END.
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE ver_capital:

    DEF INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INT                             NO-UNDO.
    DEF INPUT PARAM par_vllanmto AS DEC                             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR h-b1wgen0001 AS HANDLE                                  NO-UNDO.

    
    IF NOT VALID-HANDLE(h-b1wgen0001) THEN
       RUN sistema/generico/procedures/b1wgen0001.p
           PERSISTENT SET h-b1wgen0001.

    RUN ver_capital IN h-b1wgen0001(INPUT par_cdcooper,
                                    INPUT par_nrdconta,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT par_vllanmto,
                                    INPUT par_dtmvtolt,
                                    INPUT par_nmdatela,
                                    INPUT par_idorigem, 
                                    OUTPUT TABLE tt-erro).

    IF VALID-HANDLE(h-b1wgen0001) THEN
       DELETE OBJECT h-b1wgen0001.

    IF RETURN-VALUE <> "OK" THEN
       RETURN "NOK".

    
    RETURN "OK".


END PROCEDURE.

PROCEDURE calc_qtd_dias_uteis:

    DEF INPUT PARAM par_dtmvtolt AS DATE NO-UNDO.
    DEF INPUT PARAM par_data     AS DATE NO-UNDO.

    DEF OUTPUT PARAM par_qtdias  AS INTE NO-UNDO.

    /* Calcular qtd de dias uteis entre par_dtmvtolt(data atual) e par_data */
    /* Hoje eh considerado D-0 */
       
    DEF VAR tmp_dias     AS INTE INIT -1 NO-UNDO.
    DEF VAR tmp_dtrefere AS DATE         NO-UNDO.

    ASSIGN tmp_dtrefere = par_dtmvtolt.
       
    DO  WHILE TRUE:

        IF   WEEKDAY(tmp_dtrefere) = 1   OR
             WEEKDAY(tmp_dtrefere) = 7   THEN
             DO:
                tmp_dtrefere = tmp_dtrefere + 1.
                NEXT.
             END.
                                    
        FIND crapfer WHERE crapfer.cdcooper = crapcop.cdcooper AND
                           crapfer.dtferiad = tmp_dtrefere
                           NO-LOCK NO-ERROR.
                                                            
        IF   AVAILABLE crapfer   THEN
             DO:
                tmp_dtrefere = tmp_dtrefere + 1.
                NEXT.
             END.

        ASSIGN tmp_dias = tmp_dias + 1        
               tmp_dtrefere = tmp_dtrefere + 1.
             
        IF par_data >= tmp_dtrefere THEN 
           NEXT.     

        LEAVE.
        
    END.  /*  Fim do DO WHILE TRUE  */
    
    ASSIGN par_qtdias = tmp_dias.

END PROCEDURE.

PROCEDURE imprime_cet:
    
    DEF INPUT PARAM p-cdcooper AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtmvtolt AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-cdprogra AS CHAR                                 NO-UNDO.
    DEF INPUT PARAM p-nrdconta AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-inpessoa AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdusolcr AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdlcremp AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-tpctrlim AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-nrctrlim AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtinivig AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-qtdiavig AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-vlemprst AS DECI                                 NO-UNDO.
    DEF INPUT PARAM p-txmensal AS DECI                                 NO-UNDO.

    DEF OUTPUT PARAM par_nmdoarqv AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                              NO-UNDO.

    DEF VAR aux_dscritic AS CHAR NO-UNDO.
    DEF VAR aux_cdcritic AS INTE NO-UNDO.    

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_imprime_limites_cet 
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-cdcooper, /* Cooperativa */
                          INPUT p-dtmvtolt, /* Data Movimento */
                          INPUT p-cdprogra, /* Programa chamador */
                          INPUT p-nrdconta, /* Conta/dv          */
                          INPUT p-inpessoa, /* Indicativo de pessoa */
                          INPUT p-cdusolcr, /* Codigo de uso da linha de credito */
                          INPUT p-cdlcremp, /* Linha de credio */
                          INPUT p-tpctrlim, /* Tipo da operacao  */
                          INPUT p-nrctrlim, /* Contrato          */
                          INPUT p-dtinivig, /* Data liberacao  */
                          INPUT p-qtdiavig, /* Dias de vigencia */                                     
                          INPUT p-vlemprst, /* Valor emprestado */
                          INPUT p-txmensal, /* Taxa mensal/crapldc.txmensal */
                          INPUT 0,          /* 0 - false pr_flretxml*/
                         OUTPUT "",
                         OUTPUT "", 
                         OUTPUT 0,
                         OUTPUT "").

    CLOSE STORED-PROC pc_imprime_limites_cet 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_nmdoarqv = ""
           par_nmdoarqv = pc_imprime_limites_cet.pr_nmarqimp
                          WHEN pc_imprime_limites_cet.pr_nmarqimp <> ? 
           aux_cdcritic = pc_imprime_limites_cet.pr_cdcritic 
                          WHEN pc_imprime_limites_cet.pr_cdcritic <> ?
           aux_dscritic = pc_imprime_limites_cet.pr_dscritic 
                          WHEN pc_imprime_limites_cet.pr_dscritic <> ?.
        
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:                                    
            ASSIGN par_dscritic = aux_dscritic.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE junta_arquivos:

    DEF  INPUT PARAM par_dsdircop AS CHAR                              NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR FORMAT "x(70)"               NO-UNDO.
    DEF  INPUT PARAM par_nmarqcet AS CHAR FORMAT "x(70)"               NO-UNDO.

    DEF OUTPUT PARAM par_nmarquiv AS CHAR                              NO-UNDO.
    DEF OUTPUT PARAM par_nmarqpdf AS CHAR                              NO-UNDO.

    DEF VAR aux_dsarqimp AS CHAR                                       NO-UNDO.
    DEF VAR aux_setlinha AS CHAR                                       NO-UNDO.
    DEF VAR aux_time     AS CHAR                                       NO-UNDO.

    ASSIGN aux_time = STRING(TIME)
           par_nmarquiv = "/usr/coop/" + par_dsdircop + "/rl/" + aux_time + ".ex"
           par_nmarqpdf = "/usr/coop/" + par_dsdircop + "/rl/" + aux_time + ".pdf".

    OUTPUT STREAM str_3 TO VALUE(par_nmarquiv) APPEND PAGED PAGE-SIZE 140.

    /* para contrato e completa */
    INPUT STREAM str_1
          THROUGH VALUE( "ls " + par_nmarqimp + " 2> /dev/null") NO-ECHO.

    DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

         SET STREAM str_1 par_nmarqimp.

         INPUT STREAM str_2 FROM VALUE(par_nmarqimp) NO-ECHO.

         DO  WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

             IMPORT STREAM str_2 UNFORMATTED aux_setlinha.
             
             PUT STREAM str_3 aux_setlinha FORMAT "x(100)" SKIP.
         END.    

         INPUT STREAM str_2 CLOSE.
         
    END.

    INPUT STREAM str_1 CLOSE.
    
    PAGE STREAM str_3.            
    PUT STREAM str_3 CHR(2).  /* inicio do texto chr(2) */

    /* para o cet */
    INPUT STREAM str_1
          THROUGH VALUE( "ls " + par_nmarqcet + " 2> /dev/null") NO-ECHO.

    DO  WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

         SET STREAM str_1 par_nmarqcet.

         INPUT STREAM str_2 FROM VALUE(par_nmarqcet) NO-ECHO.

         DO  WHILE TRUE TRANSACTION ON ENDKEY UNDO, LEAVE:

             IMPORT STREAM str_2 UNFORMATTED aux_setlinha.

             PUT STREAM str_3 aux_setlinha FORMAT "x(100)" SKIP.
             
         END.

         INPUT STREAM str_2 CLOSE.
    END.

    INPUT STREAM str_1 CLOSE.

    OUTPUT STREAM str_3 CLOSE.
END.

PROCEDURE calcula_cet_limites:
    
    DEF INPUT PARAM p-cdcooper AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtmvtolt AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-cdprogra AS CHAR                                 NO-UNDO.
    DEF INPUT PARAM p-nrdconta AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-inpessoa AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdusolcr AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-cdlcremp AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-tpctrlim AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-nrctrlim AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-dtinivig AS DATE                                 NO-UNDO.
    DEF INPUT PARAM p-qtdiavig AS INTE                                 NO-UNDO.
    DEF INPUT PARAM p-vlemprst AS DECI                                 NO-UNDO.
    DEF INPUT PARAM p-txmensal AS DECI                                 NO-UNDO.

    DEF OUTPUT PARAM par_txcetano AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM par_txcetmes AS DECI                              NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                              NO-UNDO.

    DEF VAR aux_dscritic AS CHAR NO-UNDO.
    DEF VAR aux_cdcritic AS INTE NO-UNDO.    

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_calculo_cet_limites
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-cdcooper, /* Cooperativa */
                          INPUT p-dtmvtolt, /* Data Movimento */
                          INPUT p-cdprogra, /* Programa chamador */
                          INPUT p-nrdconta, /* Conta/dv          */
                          INPUT p-inpessoa, /* Indicativo de pessoa */
                          INPUT p-cdusolcr, /* Codigo de uso da linha de credito */
                          INPUT p-cdlcremp, /* Linha de credio */
                          INPUT p-tpctrlim, /* Tipo da operacao  */
                          INPUT p-nrctrlim, /* Contrato          */
                          INPUT p-dtinivig, /* Data liberacao  */
                          INPUT p-qtdiavig, /* Dias de vigencia */                                     
                          INPUT p-vlemprst, /* Valor emprestado */
                          INPUT p-txmensal, /* Taxa mensal/crapldc.txmensal */
                         OUTPUT 0, 
                         OUTPUT 0, 
                         OUTPUT 0,
                         OUTPUT "").

    CLOSE STORED-PROC pc_calculo_cet_limites
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           par_txcetano = 0
           par_txcetmes = 0
           par_txcetano = pc_calculo_cet_limites.pr_txcetano
                          WHEN pc_calculo_cet_limites.pr_txcetano <> ? 
           par_txcetmes = pc_calculo_cet_limites.pr_txcetmes
                          WHEN pc_calculo_cet_limites.pr_txcetmes <> ? 
           aux_cdcritic = pc_calculo_cet_limites.pr_cdcritic 
                          WHEN pc_calculo_cet_limites.pr_cdcritic <> ?
           aux_dscritic = pc_calculo_cet_limites.pr_dscritic 
                          WHEN pc_calculo_cet_limites.pr_dscritic <> ?.
        
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
        DO:                                    
            ASSIGN par_dscritic = aux_dscritic.

            RETURN "NOK".
        END.

    RETURN "OK".

END PROCEDURE.

/***************************************************************************
 Procedure para alterar o numero da proposta de limite de desc de cheque.
 Opcao de Alterar na rotina Descontos da tela ATENDA. 
***************************************************************************/
PROCEDURE altera-numero-proposta-limite:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrant AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrlim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR     aux_contador     AS INTE                           NO-UNDO.
    DEF  VAR     aux_dsoperac     AS CHAR                           NO-UNDO.
    DEF  VAR     aux_nrctrlim     AS INTE                           NO-UNDO.
    DEF  VAR     h-b1wgen0110     AS HANDLE                         NO-UNDO.
    DEF  VAR     aux_habrat       AS CHAR                           NO-UNDO. /* P450 - Rating */

    DEF  BUFFER  crabavt          FOR crapavt.
    DEF  BUFFER  crabavl          FOR crapavl.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Alterar o numero da proposta de limite desconto de cheques".

    IF  par_nrctrlim <= 0 THEN
        DO:
            ASSIGN aux_dscritic = "Numero da proposta deve ser diferente de zero.".

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
        END.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                       crapass.nrdconta = par_nrdconta
                       NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass THEN
        DO:
            ASSIGN aux_cdcritic = 9.

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
            RETURN "NOK".
       END.

    IF  NOT VALID-HANDLE(h-b1wgen0110) THEN
        RUN sistema/generico/procedures/b1wgen0110.p PERSISTENT SET h-b1wgen0110.

    /*Monta a mensagem da operacao para envio no e-mail*/
    ASSIGN aux_dsoperac = "Tentativa de alterar o numero da proposta "  +
                          "de limite de desconto de cheques na conta " +
                          STRING(crapass.nrdconta,"zzzz,zzz,9")            +
                          " - CPF/CNPJ "                                   +
                         (IF crapass.inpessoa = 1 THEN
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999")),"xxx.xxx.xxx-xx")
                          ELSE
                             STRING((STRING(crapass.nrcpfcgc,
                                     "99999999999999")),"xx.xxx.xxx/xxxx-xx")).

    /*Verifica se o associado esta no cadastro restritivo*/
    RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_dtmvtolt,
                                      INPUT par_idorigem,
                                      INPUT crapass.nrcpfcgc,
                                      INPUT crapass.nrdconta,
                                      INPUT par_idseqttl,
                                      INPUT TRUE, /*bloqueia operacao*/
                                      INPUT 11, /*cdoperac*/
                                      INPUT aux_dsoperac,
                                      OUTPUT TABLE tt-erro).

    IF VALID-HANDLE(h-b1wgen0110) THEN
       DELETE PROCEDURE(h-b1wgen0110).

    IF  RETURN-VALUE <> "OK" THEN
        DO:
            IF  NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
                DO:
                    ASSIGN aux_dscritic = "Nao foi possivel verificar o " +
                                      "cadastro restritivo.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1, /*sequencia*/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                END.

            RETURN "NOK".
        END.

    DO TRANSACTION WHILE TRUE:

        /* Verifica se ja existe contrato com o numero informado */
        FIND FIRST craplim WHERE craplim.cdcooper = par_cdcooper     AND
                                 craplim.nrdconta = par_nrdconta     AND
                                 craplim.tpctrlim = 2 /* Desc.Chq */ AND
                                 craplim.nrctrlim = par_nrctrlim
                                 NO-LOCK NO-ERROR.

        IF   AVAIL craplim   THEN
             DO:
                 aux_dscritic =
                     "Numero da proposta de limite de desconto de cheques ja existente.".
                 LEAVE.
             END.

        /* Encontra contrato atual */
        FIND craplim WHERE craplim.cdcooper =  par_cdcooper     AND
                           craplim.nrdconta =  par_nrdconta     AND
                           craplim.tpctrlim =  2 /* Desc.Chq */ AND
                           craplim.nrctrlim =  par_nrctrant     
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL craplim   THEN
             DO:
                aux_dscritic = "Proposta de limite nao existente.".
                LEAVE.
             END.

        /* Verifica se o contrato atual ja foi efetivado. */
        IF   craplim.insitlim <> 1   THEN
             DO:
                aux_dscritic = "Proposta de limite ja efetivada.".
                LEAVE.
             END.

        FIND FIRST crapprp WHERE crapprp.cdcooper = par_cdcooper  AND
                                 crapprp.nrdconta = par_nrdconta  AND
                                 crapprp.nrctrato = par_nrctrlim  AND
                                 crapprp.tpctrato = 2 /* Desc.Chq */
                                 NO-LOCK NO-ERROR.

        IF   AVAIL crapprp   THEN
             DO:
                aux_dscritic =
                     "Numero de proposta de limite ja existente.".
                 LEAVE.
             END.


        DO aux_contador = 1 TO 10:

            FIND craplim WHERE craplim.cdcooper =  par_cdcooper     AND
                               craplim.nrdconta =  par_nrdconta     AND
                               craplim.tpctrlim =  2 /* Desc.Chq */ AND
                               craplim.nrctrlim =  par_nrctrant 
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

            IF  NOT AVAIL craplim  THEN
                IF  LOCKED craplim THEN
                    DO:
                        aux_cdcritic = 341.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        aux_cdcritic = 535.
                        LEAVE.
                    END.

            aux_cdcritic = 0.
            LEAVE.

        END. /* DO TO */

        IF  aux_cdcritic <> 0 OR
            aux_dscritic <> ""  THEN
            UNDO, LEAVE.

        /* Mudar o numero do contrato */
        ASSIGN aux_nrctrlim     = craplim.nrctrlim
               craplim.nrctrlim = par_nrctrlim.

        /* Avalistas terceiros, intervenientes anuentes */
        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper       AND
                               crapavt.tpctrato = 2 /* Desc.Chq */   AND
                               crapavt.nrdconta = par_nrdconta       AND
                               crapavt.nrctremp = par_nrctrant       NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabavt WHERE crabavt.cdcooper = crapavt.cdcooper   AND
                                   crabavt.nrdconta = crapavt.nrdconta   AND
                                   crabavt.tpctrato = crapavt.tpctrato   AND
                                   crabavt.nrctremp = crapavt.nrctremp   AND
                                   crabavt.nrcpfcgc = crapavt.nrcpfcgc
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL crabavt  THEN
                    IF  LOCKED crabavt THEN
                        DO:
                            aux_cdcritic = 77.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            aux_cdcritic = 869.
                            LEAVE.
                        END.

                aux_cdcritic = 0.
                LEAVE.
            END. /* TO DO */

            IF  aux_cdcritic <> 0   THEN
                LEAVE.

            /* Atualizar numero contrato */
            ASSIGN crabavt.nrctremp = par_nrctrlim.

        END.

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.

        /* Avalistas cooperados */
        FOR EACH crapavl WHERE crapavl.cdcooper = par_cdcooper     AND
                               crapavl.nrctaavd = par_nrdconta     AND
                               crapavl.nrctravd = par_nrctrant     AND
                               crapavl.tpctrato = 2 /* Desc.Chq */ NO-LOCK:

            DO aux_contador = 1 TO 10:

                FIND crabavl WHERE crabavl.cdcooper = crapavl.cdcooper   AND
                                   crabavl.nrdconta = crapavl.nrdconta   AND
                                   crabavl.nrctravd = crapavl.nrctravd   AND
                                   crabavl.tpctrato = crapavl.tpctrato
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  NOT AVAIL crabavl  THEN
                    IF  LOCKED crabavl THEN
                        DO:
                            aux_cdcritic = 77.
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            aux_cdcritic = 869.
                            LEAVE.
                        END.

                aux_cdcritic = 0.
                LEAVE.
            END. /* TO DO */

            IF   aux_cdcritic <> 0   THEN
                 LEAVE.

            /* Mudar o numero do contrato */
            ASSIGN crabavl.nrctravd = par_nrctrlim.
        END.

        IF   aux_cdcritic <> 0  OR
             aux_dscritic <> "" THEN
             UNDO, LEAVE.

        /* Proposta */
        DO aux_contador = 1 TO 10:

            FIND crapprp WHERE crapprp.cdcooper = par_cdcooper      AND
                               crapprp.nrdconta = par_nrdconta      AND
                               crapprp.tpctrato = 2 /* Desc.Chq */  AND
                               crapprp.nrctrato = par_nrctrant
                               EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
            IF  NOT AVAIL crapprp  THEN
                IF  LOCKED crapprp THEN
                    DO:
                        aux_cdcritic = 341.
                        PAUSE 1 NO-MESSAGE.
                        NEXT.
                    END.
                ELSE
                    DO:
                        aux_cdcritic = 535.
                        LEAVE.
                    END.

            aux_cdcritic = 0.
            LEAVE.
        END. /* TO DO */

        IF  aux_cdcritic <> 0   THEN
            UNDO, LEAVE.

        FIND FIRST crapprm WHERE crapprm.nmsistem = 'CRED' AND
                                 crapprm.cdacesso = 'HABILITA_RATING_NOVO' AND
                                 crapprm.cdcooper = par_cdcooper
                                 NO-LOCK NO-ERROR.
       
        ASSIGN aux_habrat = 'N'.
        IF AVAIL crapprm THEN DO:
          ASSIGN aux_habrat = crapprm.dsvlrprm.
        END.
       
        /* Habilita novo rating */
        IF aux_habrat = 'S' AND par_cdcooper <> 3 THEN DO:
       
          { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

          /* Efetuar a chamada da rotina Oracle, altera contrato no rating -P450 Rating */
          RUN STORED-PROCEDURE pc_atualiza_contrato_rating
            aux_handproc = PROC-HANDLE NO-ERROR
                              (INPUT par_cdcooper
                              ,INPUT par_nrdconta
                              ,INPUT 2            /* Limite de Desconto de Cheque */
                              ,INPUT crapprp.nrctrato
                              ,INPUT par_nrctrlim
                              ,OUTPUT 0            /* pr_cdcritic */
                              ,OUTPUT "").         /* pr_dscritic */  


              /* Fechar o procedimento para buscarmos o resultado */ 
              CLOSE STORED-PROC pc_atualiza_contrato_rating
                      aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 

              { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 

              ASSIGN aux_cdcritic  = 0
                     aux_dscritic  = ""
                     aux_cdcritic = pc_atualiza_contrato_rating.pr_cdcritic
                                       WHEN pc_atualiza_contrato_rating.pr_cdcritic <> ?
                     aux_dscritic = pc_atualiza_contrato_rating.pr_dscritic
                                       WHEN pc_atualiza_contrato_rating.pr_dscritic <> ?.
              IF aux_cdcritic > 0 OR aux_dscritic <> "" THEN
                DO:
                  UNDO, LEAVE.
                END.
        END.
        /* Efetuar a chamada da rotina Oracle, altera contrato no rating -P450 Rating */
        /* Novo numero de contrato */
        ASSIGN crapprp.nrctrato = par_nrctrlim.

        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        RUN STORED-PROCEDURE pc_vincula_cobertura_operacao 
          aux_handproc = PROC-HANDLE NO-ERROR (INPUT 0
                                              ,INPUT craplim.idcobope
                                              ,INPUT par_nrctrlim
                                              ,"").

        CLOSE STORED-PROC pc_vincula_cobertura_operacao
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_dscritic  = ""
               aux_dscritic  = pc_vincula_cobertura_operacao.pr_dscritic
               WHEN pc_vincula_cobertura_operacao.pr_dscritic <> ?.
        IF aux_dscritic <> "" THEN
           DO:
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT par_cdagenci,
                              INPUT par_nrdcaixa,
                              INPUT 1,            /** Sequencia **/
                              INPUT 0,
                              INPUT-OUTPUT aux_dscritic).

                UNDO, LEAVE.
           END.

        LEAVE.

    END. /* Fim TRANSACTION , tratamento criticas */

    IF  aux_cdcritic <> 0    OR
        aux_dscritic <> ""   THEN
        DO:
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

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

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

            IF  aux_nrctrlim <> par_nrctrlim THEN
                RUN proc_gerar_log_item (INPUT aux_nrdrowid,
                                         INPUT "nrctrlim",
                                         INPUT aux_nrctrlim,
                                         INPUT par_nrctrlim).
        END.
        
    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
    Buscar cheques com suas restricoes liberada/analisada pelo coordenador
*****************************************************************************/
PROCEDURE busca_restricoes_coordenador:

    DEFINE INPUT  PARAMETER par_cdcooper AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrborder AS INTEGER     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrdconta AS INTEGER     NO-UNDO.

    DEFINE OUTPUT PARAMETER TABLE FOR tt-dscchq_bordero_restricoes.

    EMPTY TEMP-TABLE tt-dscchq_bordero_restricoes.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    FOR EACH crapabc WHERE crapabc.cdcooper = par_cdcooper  AND
                           crapabc.nrborder = par_nrborder  AND
                           crapabc.nrdconta = par_nrdconta  AND
                           crapabc.flaprcoo = TRUE          NO-LOCK:

        CREATE tt-dscchq_bordero_restricoes.
        ASSIGN tt-dscchq_bordero_restricoes.nrcheque = crapabc.nrcheque
               tt-dscchq_bordero_restricoes.dsrestri = crapabc.dsrestri
               tt-dscchq_bordero_restricoes.dsdetres = crapabc.dsdetres.

    END.

    RETURN "OK".

END PROCEDURE.
/* .......................................................................... */


/*****************************************************************************
                Busca o valor do IOF para simples nacional                    
*****************************************************************************/
PROCEDURE buscar_valor_iof_simples_nacional:
    DEF INPUT PARAM par_vlborder AS DECI NO-UNDO.
    DEF INPUT PARAM par_cdcooper AS INTE NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE NO-UNDO.
    DEF INPUT PARAM TABLE FOR tt-iof.
    DEF INPUT PARAM TABLE FOR tt-iof-sn.
    DEF OUTPUT PARAM aux_vltotaliofsn AS DECI NO-UNDO.
    /* Projeto 410 - RF 43 a 46:
     - Se o valor do borderô for maior que 30K, usa a seguinte regra:
        -> Para pessoa jurídica, taxa do IOF para simples nacional = 0.0041
        -> Para pessoa física, taxa do IOF para simples nacional = 0.0082
     - Se o valor do borderô for até 30K (inclusive), busca a taxa que estiver 
       cadastrada. */
    IF par_vlborder <= 30000 THEN
      DO:
        FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                           crapjur.nrdconta = par_nrdconta       
                           NO-LOCK NO-ERROR.
        IF AVAILABLE crapjur AND (crapjur.idimpdsn = 1 OR crapjur.idimpdsn = 2) THEN
          DO:
            /* Calcula o IOF normal e com base no resultado, calcula o IOF do SN */
            ASSIGN aux_vltotaliofsn = par_vlborder + (ROUND(par_vlborder * tt-iof.txccdiof, 2)).
            ASSIGN aux_vltotaliofsn = ROUND(aux_vltotaliofsn * tt-iof-sn.txccdiof, 2).
          END.
        ELSE
          DO:
            ASSIGN aux_vltotaliofsn = 0.
          END.
        RELEASE crapjur.
      END.
    ELSE
      DO:
        FIND crapass WHERE crapass.cdcooper = par_cdcooper  AND
                           crapass.nrdconta = par_nrdconta       
                           NO-LOCK NO-ERROR.
        IF AVAILABLE crapass THEN
          DO:
            IF crapass.inpessoa = 1 THEN /* Pessoa física */
              DO:                
                /* Calcula o IOF normal e com base no resultado, calcula o IOF do SN */
                ASSIGN aux_vltotaliofsn = par_vlborder + (ROUND(par_vlborder * tt-iof.txccdiof, 2)).
                ASSIGN aux_vltotaliofsn = ROUND(aux_vltotaliofsn * const_txiofpf, 2).
              END.
            ELSE  /* Pessoa jurídica */
              DO:
                /* Verifica se o associado é cooperativa. Se for, taxa iof simples nacional deve ser zero */
                FIND crapjur WHERE crapjur.cdcooper = par_cdcooper  AND
                                   crapjur.nrdconta = par_nrdconta       
                                   NO-LOCK NO-ERROR.
                IF AVAILABLE crapjur AND (crapjur.natjurid = 2143) THEN /* 2143 = Coopertativa */
                  DO:
                    ASSIGN aux_vltotaliofsn = 0.
                  END.
                ELSE
                  DO:
                    /* Calcula o IOF normal e com base no resultado, calcula o IOF do SN */
                    ASSIGN aux_vltotaliofsn = par_vlborder + (ROUND(par_vlborder * tt-iof.txccdiof, 2)).
                    ASSIGN aux_vltotaliofsn = ROUND(aux_vltotaliofsn * const_txiofpj, 2).
                  END.
                RELEASE crapjur.
              END.
          END.
        ELSE
          ASSIGN aux_vltotaliofsn = 0.
        RELEASE crapass.        
      END.
    RETURN "OK".
END PROCEDURE.
