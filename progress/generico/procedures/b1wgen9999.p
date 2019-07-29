/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------------+---------------------------------+
  | Rotina Progress                          | Rotina Oracle PLSQL             |
  +------------------------------------------+---------------------------------+
  | sistema/generico/procedures/b1wgen9999.p |                                 |
  |   dig_fun                                | GENE0005.fn_calc_digito         |
  |   obtem_risco                            | RATI0001.pc_obtem_risco         |
  |   saldo_utiliza                          | GENE0005.pc_saldo_utiliza       |
  |   valida-cpf                             | GENE0005.pc_valida_cpf_cnpj     |
  |   valida-cnpj                            | GENE0005.pc_valida_cpf_cnpj     |
  |   valida-cpf-cnpj                        | GENE0005.pc_valida_cpf_cnpj     |
  |   idade                                  | CADA0001.pc_busca_idade         |
  |   p-conectajddda                         | Nao necessário                  |
  |   p-desconectajddda                      | Nao necessário                  | 
  |   acha-lock                              | GENE0001.pc_acha_lock           |
  |   busca_cabrel                           | EXTR0002.pc_busca_cabrel        |
  |   calcula-faturamento                    | CADA0001.pc_calcula_faturamento |
  +------------------------------------------+---------------------------------+
   
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - Daniel Zimmermann    (CECRED)
   - Marcos Martini       (SUPERO)
   
*******************************************************************************/


/*..............................................................................

    Programa  : b1wgen9999.p
    Autor     : Guilherme/David
    Data      : Marco/2008                    Ultima Atualizacao: 18/11/2017.
    
    Dados referentes ao programa:

    Objetivo  : BO ref. TODOS OS PROCEDIMENTOS GENERICOS.

    Alteracoes: 20/06/2008 - Incluir procedures para envio de propostas de 
                             emprestimos no formato PDF (David).
                           - Incluir procedure busca_cabrel (Guilherme).
                           
                31/07/2008 - Incluir PAC no assunto do email com PDF (David).
                
                18/08/2008 - Incluir procedure busca_iof (Guilherme).
                
                28/08/2008 - EMPTY TEMP-TABLEs - consulta avalista 
                                               - valida avalistas. (Guilherme)
                           - Verificar se o usuario foi cx_online, ura,
                             progrid, internet ou autorizador, entao nao
                             conectar e desconectar do generico (Julio)
                             
                26/09/2008 - Identificacao do banco de dados antes da
                             referencia a cada VST (Julio)
                             
                14/10/2008 - Contabliizar o desconto de titulos para o saldo
                             devedor (Gabriel).
                           - Incluir procedure critica_numero_lote (Guilherme).
                           
                29/01/2009 - Na procedure consulta-avalista, nao validar a
                             idade para pessoa juridica (Evandro).
                             
                20/02/2009 - Incluir procedure quebra-str(Guilherme).  

                17/04/2009 - Alimentar nrfonres e dsdemail na lista_avalistas
                             (Guilherme).

                27/05/2009 - Tratamento para avalistas de emprestimos na
                             procedure lista_avalistas (David).
                           - Incluir procedure obtem_risco (David).
                           - Alterar mtpdf.pl por gnupdf.pl (David).  

                01/09/2009 - Correcao na procedure verificar_atualizacao_rating
                             (David).
                05/09/2009 - Alterado campo cdgraupr da crapass para a crapttl
                             Paulo - Precise.
                             
                02/10/2009 - Aumento do numero dos lotes: 3200 e 3300 (Diego).
                
                30/10/2009 - Incluir procedure calcula-faturamento.
                             Retirar procedure verificar_atualizacao_rating 
                             nao mais necessaria. Projeto Rating (Gabriel).
                           - Alterar inhabmen da crapass para crapttl(Guilherme)
                           
                05/01/2010 - Incluir procedure acha-lock (David).
                
                21/06/2010 - Passar a procedure que trata dos envios dos
                             contratos por e-mail para a BO 0024 (Gabriel).
                             
                29/07/2010 - Incluir campo de nacionalidade na lista_avalistas
                             (Gabriel).
                           - Retornar o digito calculado mesmo que haja erro
                             na procedure "dig_fun" conforme ja era no fonte
                             que deu origem a procedure (Evandro).
                             
                23/11/2010 - Incluir usuario "ayllos" para condicao de conexao
                             e desconexao ao banco generico (David).
                             
                20/12/2010 - Ordenar os avalistas de acordo com o cadastramento
                             (Guilherme).                     
                             
                11/01/2011 - Nao permitir avalista com o mesmo CPF que o 
                             contratante (Gabriel)                     
                             
                14/03/2011 - Substituir dsdemail da ass para a crapcem
                             (Gabriel)        
                             
                22/03/2011 - Incluidas procedures p-conectajddda e 
                             p-desconectajddda (Fernando).
                             
                23/03/2011 - Incluido lote 10115 na procedure 
                             critica_numero_lote  (Adriano).
                             
                14/04/2011 - Alteraçoes devido a CEP integrado. Campos
                             nrendere, complend e nrcxapst nos procedimentos
                             consulta-avalista, atualiza_tabela_avalistas,
                             cria-tabelas-avalistas, valida-avalistas. 
                             (André - DB1)  
                             
                16/06/2011 - Inclusao do procedimento retirado de numtal.p    
                
                15/07/2011 - Ajustada funcao conectagener e desconectagener
                             para sempre retornar OK - Unificaçao Gener
                             (Fernando).
                             
                11/08/2011 - Retornar dtrefere na obtem_risco - GE (Guilherme)
                
                28/11/2011 - Ajuste para passagem do parametro "dsjusren" na 
                             procedure grava-dados-cadastro (Adriano).
                             
                09/03/2012 - Adicionar a critica_numero_lote os novos lotes
                             do novo emprestimo (Oscar).
                             
                10/05/2012 - Incluído ordenaçao pelo rowid na busca da tabela 
                             crapavt na procedure lista_avalistas 
                             (Guilherme Maba).
                             
                08/08/2012 - Retirado da rotina saldo_utiliza o endividamento
                             do cartao de credito - Rosangela
                             
                04/10/2012 - Arrumar tratamento dos bens dos avalistas
                             cooperados (Gabriel).      
                             
                11/10/2012 - Incluido o parametro tpdecons na procedure 
                             saldo_utiliza e ajustado o "FOR EACH crapass"
                             para buscar tanto pelo CPF quanto pela Conta.
                             PS.: Esta alteracao nao foi realizada no fonte 
                             saldo_utiliza (Adriano).
                             
               15/010/2012 - Alterada procedure valida-cpf-cnpj, comentado 
                             condicao que invalidava numero 9571 (BB) . (Jorge)
                             
               28/12/2012 - Incluso parametro par_cdoperad nas procedure 
                            cria-tabelas-avalistas, atualiza_tabela_avalistas e
                             na chamada para a grava-dados-cadastro (Daniel).  
                             
               13/02/2013 - Ajuste na padronizaçao de conexao do DataServer DDA
                            por solicitacao do Fernando Klock. (Rafael)
                            
               29/04/2013 - Incluido a chamada da procedure alerta_fraude dentro
                            da procedure cria-tabelas-avalistas (Adriano).
                            
               11/06/2013 - Rating BNDES (Guilherme/Supero)
               
               12/07/2013 - Instanciacao da b1wgen0002 antes da leitura da
                            crapass com crapepr, na procedure saldo_utiliza.
                            (Fabricio)
                            
               21/08/2013 - Nova procedure listal-consulta-cheques para
                            para retornar as cooperativas e serem usadas para filtro
                            na nova tela web LISTAL. (André E. / Supero)
                            
               01/10/2013 - Alterado para nao receber o telefone da crapas e 
                            sim da craptfc.(Reinert)
                            
               10/12/2013 - Incluir VALIDATE crapavl, crapavt (Lucas R.)
               
               19/12/2013 - Alterado atribuicoes de variaves de "CGC/C.G.C." 
                            para "CNPJ". (Reinert)
                            
               03/02/2014 - Ignorados os registros com crapreq.qtreqtal = ?, 
                            procedure listal-consulta-cheques (Carlos)
                            
               06/02/2014 - Retirar conexao e desconexao do DDA (Gabriel).
               
               30/05/2014 - Incluir par_nrdolote = 6651 na procedure
                            critica_numero_lote - Softdesk 147220 (Lucas R.)
                            
               10/06/2014 - Troca do campo crapass.nmconjug por crapcje.nmconjug
                            (Chamado 117414) - (Tiago Castro - RKAM).
                            
               24/06/2014 - Adicionado o parametro par_dsoperac nas
                            procedures cria-tabelas-avalistas e 
                            atualiza_tabela_avalistas. 
                            (Chamado 166383) - (Fabricio)
                            
               01/07/2014 - Incluso novo parametro na procedure obtem_risco e ajustado
                            leitura crapris (Daniel).  
                            
               14/07/2014 - Incluso novos parametros inpessoa e dtnascto (Daniel) 
                
               26/05/2014 - Adicionado verificacao de registro na tabela crapavl
                            antes de dar create, adicionado parametro de entrada
                            cdagenci e nrdcaixa e saida tt-erro em proc. 
                            cria-tabelas-avalistas.
                            (Jorge/Gielow) - SD 156112       
                            
               11/08/2014 - Incluido tratamento na procedure 
                            critica_numero_lote para os lotes:
                             * 8500: Credito de nova aplicacao
                             * 8501: Debito de nova aplicacao
                             * 8502: Debito de resgate de aplicacao
                             * 8503: Credito de resgate de aplicacao
                             * 8504: Debito de vencimento de aplicacao
                             * 8505: Credito de vencimento de aplicacao
                             * 8506: Credito de provisao de aplicacao.
                             (Reinert)

               21/08/2014 - Ajustar a busca das informações do conjuge.
                            (Douglas - Chamado 191852)
                            
               25/08/2014 - Incluir o lote 6650 para que chame a critica 261
                            (Daniele).
                            
               10/09/2014 - Ajustar a busca das informações do conjuge para quando
                            possuir o numero da conta, pesquisar na crapttl e apenas
                            quando não existir buscar da crapcje. Carregar o CPF do
                            conjuge. (Douglas - Chamado 193317)
                            
               11/09/2014 - Incluir o lote 50001, 50002 e 50003 na 
                            procedure critica_numero_lote. (James). 
                            
               29/09/2014 - Retirar condicao IF  par_vlnumero > 100 AND 
                            par_tpextens = "P"  THEN para usar para o CET
                            (Lucas R./Gielow - Projeto CET)
                            
               01/10/2014 - Incluir novo lote 6400 na procedure 
                            critica_numero_lote (Lucas R. - #205006)
                            
               13/02/2015 - Incluido lote 7050 na procedure
                            critica_numero_lote.
                            (Chamado 229249 # PRJ Melhoria) - (Fabricio)
                            
               09/06/2015 - Consultas automatizadas (Gabriel-RKAM)
               
               23/06/2015 - Ajuste para apresentar o CPF do avalista e conjuge
                            corretamente. (Jorge/Gielow) - SD 290885
                            
               13/08/2015 - Ajuste no calculo do risco na procedure obtem_risco. (James)
               
               25/08/2015 - Ajuste na procedure lista_avalistas pois estava passando 
                            o cpf/cnpj em lugares indevidos, conforme relatado no chamado
                            314472. (Kelvin)
                            
               06/10/2015 - Ajuste para deletar crapavl corretamente em 
                            atualiza_tabela_avalistas. (Jorge/Gielow) - SD 335318
                            
               08/10/2015 - Alterar a procedure idade para chamar a rotina do Oracle
                            (Lucas Ranghetti #340156)
                            
               26/09/2016 - Incluir lotes da M211 para nao exclusao (Jonata-RKAM)

			   18/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

                            
               19/04/2017 - Alteraçao DSNACION pelo campo CDNACION.
                            PRJ339 - CRM (Odirlei-AMcom) 
                            
               18/07/2017 - Incluir o lote 650003 e 650004 na procedure 
                            critica_numero_lote. (Jaison/James - PRJ298)

			         30/08/2017 - Ajuste para incluir o lote 7600
					                 (Adriano - SD 746815).
                            
               13/09/2017 - #706145 Rotina acha-lock limpada pois a mesma faz
                            buscas em tabelas exclusivamente progress, que não 
                            são utilizadas no oracle, podendo causar lentidão
                            quando requisitada por programas que tratam LOCK
                            (Carlos)
                            
               16/10/2017 - Ajsutes ao carregar DSNACION.
                            PRJ339 - CRM (Odirlei-AMcom)               
                            
               20/10/2017 - Criada procedure busca_iof_simples_nacional 
                             (Diogo - MoutS - Projeto 410 - RF 43 a 46)             

		       18/11/2017 - Inclusao dos lotes refernte a devolucao de capital (Jonata - RKAM P364).

               24/10/2017 - Alterado rotina consulta-avalista para chamar rotina pc_ret_dados_pessoa_prog
                            para buscar os dados quando informado CPF/CNPJ, para busca no Cadastro unificado.
                            PRJ339-CRM (Odirlei-AMcom)             
                            
			   28/03/2018 - Alterado a procedure lista_avalistas para ler a tabela de proposta de limite de desconto 
                      de titulos CRAWLIM para pegar os avalista caso ainda não exista o contrato CRAPLIM (Paulo Penteado GFT)
           
               06/12/2018 - Ajuste na busca de enderecos para nao utilizar a sequencia 1 fixa.
                            PRB0040414 - Heitor (Mouts)
           
               14/05/2019 - Ajuste na valida-avalistas para na verificacao de CPF de associado considerar apenas contas com situacao
                            1, 5 e 9, contas fora dessas situacoes nao serao consideradas de associado. PRJ 438 - Mateus Z (Mouts)

               25/06/2019 - Efetuado tratamento na rotina lista_avalistas e consulta_avalista quando o DDD for NULL.
                            (Rubens Lima - Mout's) - PRJ438 - SPRINT 13
           
.............................................................................*/

{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/b1wgen0056tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF VAR aux_cdcritic AS INTE                               NO-UNDO.
DEF VAR aux_cdgraupr AS INTE                               NO-UNDO.
DEF VAR aux_dscritic AS CHAR                               NO-UNDO.
DEF VAR aux_containi AS INT                                NO-UNDO.
DEF VAR aux_contafim AS INT                                NO-UNDO.
DEF VAR aux_nrocolun AS INT                                NO-UNDO.
DEF VAR aux_contalet AS INT                                NO-UNDO.
                                                     
DEF VAR h-b1wgen0024 AS HANDLE                             NO-UNDO.

PROCEDURE p-conectagener:

    /**********************************************************************/
    /** Procedure para efetuar conexao com o banco de dados generico     **/
    /** Baseado no programa includes/gg0000.i                            **/
    /**********************************************************************/
    
    RETURN "OK".

END.


PROCEDURE p-conectajddda:

    /**********************************************************************/
    /**    Procedure para efetuar conexao com o banco de dados jddda     **/
    /**********************************************************************/


    RETURN "OK".
END.

PROCEDURE p-desconectagener:

    /**********************************************************************/
    /** Procedure para desfazer conexao com o banco de dados generico    **/
    /** Baseado no programa includes/gg0000.i                            **/
    /**********************************************************************/
        
    RETURN "OK".
    
END.

PROCEDURE p-desconectajddda:

    /**********************************************************************/
    /** Procedure para desfazer conexao com o banco de dados jddda       **/
    /**********************************************************************/

    RETURN "OK".
    
END.

PROCEDURE idade:

    /**********************************************************************/
    /** Procedure para calcular idade do associado                       **/
    /** Baseado no programa fontes/idade.p                               **/
    /**********************************************************************/

    DEF  INPUT PARAM par_dtnasctl AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM par_nrdeanos AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_nrdmeses AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM par_dsdidade AS CHAR                           NO-UNDO.

    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.
      
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_busca_idade 
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT par_dtnasctl, /* Data de Nascimento */
                          INPUT par_dtmvtolt, /* Data de Movimento */
                          INPUT 1,         /* Flag progress/oracle */
                         OUTPUT 0,            /* par_nrdeanos */
                         OUTPUT 0,            /* par_nrdmeses */
                         OUTPUT "",           /* par_dsdidade */
                         OUTPUT "").          /* pr_des_erro */

    CLOSE STORED-PROC pc_busca_idade 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN par_nrdeanos = 0
           par_nrdmeses = 0
           par_dsdidade = ""
           aux_dscritic = ""
           par_nrdeanos = pc_busca_idade.pr_nrdeanos 
                          WHEN pc_busca_idade.pr_nrdeanos <> ?
           par_nrdmeses = pc_busca_idade.pr_nrdmeses 
                          WHEN pc_busca_idade.pr_nrdmeses <> ?
           par_dsdidade = pc_busca_idade.pr_dsdidade 
                          WHEN pc_busca_idade.pr_dsdidade <> ?
           aux_dscritic = pc_busca_idade.pr_des_erro
                          WHEN pc_busca_idade.pr_des_erro <> ?.

    IF  aux_dscritic <> "" THEN
        RETURN "NOK".
    
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE dig_fun:

    /**********************************************************************/
    /** Procedure para calcular digito verificador do numero da conta    **/
    /** Baseado no programa fontes/digfun.p                              **/
    /**********************************************************************/
 
    DEF        INPUT PARAM par_cdcooper AS CHAR                     NO-UNDO.
    DEF        INPUT PARAM par_cdagenci AS INTE                     NO-UNDO.
    DEF        INPUT PARAM par_nrdcaixa AS INTE                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_nrdconta AS DECI FORMAT ">>>>>>>>>>>>>9"
                                                                    NO-UNDO.
    DEF       OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF  VAR aux_nrdigito AS INTE INIT 0                            NO-UNDO.
    DEF  VAR aux_nrposica AS INTE INIT 0                            NO-UNDO.
    DEF  VAR aux_vlrdpeso AS INTE INIT 9                            NO-UNDO.
    DEF  VAR aux_vlcalcul AS INTE INIT 0                            NO-UNDO.
    DEF  VAR aux_vldresto AS INTE INIT 0                            NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    /* Identifica conta do convenio com a Caixa (CEF)  -  Concredi */
    IF  par_nrdconta = 030035008  THEN
        RETURN "OK".

    ASSIGN aux_cdcritic = 0.

    IF  LENGTH(STRING(par_nrdconta)) < 2  THEN 
        DO:
            ASSIGN aux_cdcritic = 8
                   aux_dscritic = "". 

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        
                 
            RETURN "NOK".
        END.

    DO aux_nrposica = (LENGTH(STRING(par_nrdconta)) - 1) TO 1 BY -1:
 
        ASSIGN aux_vlcalcul = aux_vlcalcul + (INTE(SUBSTR(STRING(par_nrdconta),
                                              aux_nrposica,1)) * aux_vlrdpeso)
               aux_vlrdpeso = aux_vlrdpeso - 1.
 
        IF  aux_vlrdpeso = 1  THEN
            ASSIGN aux_vlrdpeso = 9.
    
    END.  

    ASSIGN aux_vldresto = aux_vlcalcul MODULO 11.

    IF  aux_vldresto > 9  THEN
        ASSIGN aux_nrdigito = 0.
    ELSE
        ASSIGN aux_nrdigito = aux_vldresto.

    IF  (INTE(SUBSTR(STRING(par_nrdconta),
              LENGTH(STRING(par_nrdconta)),1))) <> aux_nrdigito  THEN 
        DO:
            ASSIGN aux_cdcritic = 8
                   aux_dscritic = ""
                   /* gera a critica mas devolve o digito correto calculado */
                   par_nrdconta = DECI(SUBSTR(STRING(par_nrdconta),1,
                                       LENGTH(STRING(par_nrdconta)) - 1) +
                                       STRING(aux_nrdigito)).

            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).        
                            
            RETURN "NOK".                
        END.

    ASSIGN par_nrdconta = DECI(SUBSTR(STRING(par_nrdconta),1,
                               LENGTH(STRING(par_nrdconta)) - 1) +
                               STRING(aux_nrdigito)).
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE saldo_utiliza:

/******************************************************************************/
/** Procedure para calcular o valor utilizado (credito) do associado         **/
/** Baseado no programa fontes/saldo_utiliza.p                               **/
/** Compoe o valor utilizado:                                                **/
/** - saldo devedor dos emprestimos ate o dia                                **/
/** - cheques do desconto de cheques que ainda nao foram compensados         **/
/** - limite de cheque especial do cooperado, total contratado               **/
/** - estouro da conta                                                       **/
/** - titulos do desconto de titulos ainda em aberto                         **/
/**                                                                          **/
/** Em caso de alteracao, efetuar tambem no programa fontes/saldo_utiliza.p  **/
/******************************************************************************/

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
    DEF  INPUT PARAM par_dsctrliq AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpdecons AS LOG                            NO-UNDO.
    /* par_tpdecons => FALSE - Realiza a consulta do endividamento por cpf
                    => TRUE  - Realiza a consulta do endividamento por conta */

    DEF OUTPUT PARAM par_vlutiliz AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_nrcpfcgc AS DECI                                    NO-UNDO.
    DEF VAR aux_vldevepr AS DECI                                    NO-UNDO.
    DEF VAR aux_vldevchq AS DECI                                    NO-UNDO.
    DEF VAR aux_vldevtit AS DECI                                    NO-UNDO.
    DEF VAR aux_vldevcta AS DECI                                    NO-UNDO.
    DEF VAR aux_vldevcar AS DECI                                    NO-UNDO.
    DEF VAR aux_vldevlim AS DECI                                    NO-UNDO.
    DEF VAR aux_vlsdeved AS DECI                                    NO-UNDO.
    DEF VAR aux_vltotpre AS DECI                                    NO-UNDO.
    
    DEF VAR aux_despreza AS LOGI                                    NO-UNDO.
    
    DEF VAR aux_contaliq AS INTE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    
    DEF VAR aux_qtprecal LIKE crapepr.qtprecal                      NO-UNDO.

    DEF VAR h-b1wgen0002 AS HANDLE                                  NO-UNDO.
    
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
                                               
            RETURN "NOK".

        END.    

    ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc
           aux_contaliq = IF  par_dsctrliq <> "Sem liquidacoes"  THEN
                              NUM-ENTRIES(par_dsctrliq)
                          ELSE
                              0
           aux_vldevepr = 0
           aux_vldevcar = 0
           aux_vldevchq = 0
           aux_vldevtit = 0
           aux_vldevlim = 0
           aux_vldevcta = 0
           aux_vlsdeved = 0.
    
    RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002.

    IF  NOT VALID-HANDLE(h-b1wgen0002)  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Handle invalido para BO b1wgen0002.".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".        
        END.
           
    
    FOR EACH crapass WHERE (par_tpdecons = FALSE              AND 
                            crapass.cdcooper = par_cdcooper   AND
                            crapass.nrcpfcgc = aux_nrcpfcgc   AND
                            crapass.dtelimin = ?            ) OR
                           (crapass.cdcooper = par_cdcooper   AND
                            crapass.nrdconta = par_nrdconta   AND
                            crapass.dtelimin = ?)
                            NO-LOCK:
        
        FOR EACH crapepr WHERE crapepr.cdcooper = par_cdcooper     AND
                               crapepr.nrdconta = crapass.nrdconta AND 
                               crapepr.inliquid = 0               
                               NO-LOCK:
             
            ASSIGN aux_despreza = FALSE.
      
            DO aux_contador = 1 TO aux_contaliq:

                IF  crapepr.nrctremp = 
                    INTE(ENTRY(aux_contador,par_dsctrliq))  THEN
                    DO:
                        ASSIGN aux_despreza = TRUE.
                        LEAVE.

                    END.
    
            END.  /** Fim do DO .. TO **/
               
            IF  aux_despreza  THEN
                NEXT.
                                                                  
            ASSIGN aux_vlsdeved = 0.
              
            RUN saldo-devedor-epr IN h-b1wgen0002 (INPUT par_cdcooper,
                                                   INPUT par_cdagenci,
                                                   INPUT par_nrdcaixa,
                                                   INPUT par_cdoperad,
                                                   INPUT par_nmdatela,
                                                   INPUT par_idorigem,
                                                   INPUT crapepr.nrdconta,
                                                   INPUT par_idseqttl,
                                                   INPUT par_dtmvtolt,
                                                   INPUT par_dtmvtopr,
                                                   INPUT crapepr.nrctremp,
                                                   INPUT "B1WGEN0001",
                                                   INPUT par_inproces,
                                                   INPUT FALSE,
                                                  OUTPUT aux_vlsdeved,
                                                  OUTPUT aux_vltotpre,
                                                  OUTPUT aux_qtprecal,
                                                  OUTPUT TABLE tt-erro).
            
             
            IF  RETURN-VALUE = "NOK"  THEN
            DO:
                DELETE PROCEDURE h-b1wgen0002.
                RETURN "NOK".
            END.
            
            IF  aux_vlsdeved < 0  THEN
                ASSIGN aux_vlsdeved = 0.
                    
            ASSIGN aux_vldevepr = aux_vldevepr + aux_vlsdeved.  
    
        END.  /** Fim do FOR EACH crapepr **/
        

        /* BNDES - Emprestimos Ativos */
        FOR EACH crapebn WHERE crapebn.cdcooper = par_cdcooper     AND
                               crapebn.nrdconta = crapass.nrdconta AND 
                              (crapebn.insitctr = "N" OR
                               crapebn.insitctr = "A") NO-LOCK:

            ASSIGN aux_vldevepr = aux_vldevepr + crapebn.vlsdeved.

        END.


        /* Conforme politica de credito, o limite do cartao nao pode ser
        utilizado para composicao da divida.
        
        FOR EACH crawcrd WHERE crawcrd.cdcooper = par_cdcooper     AND
                               crawcrd.nrdconta = crapass.nrdconta AND        
                               crawcrd.insitcrd = 4                NO-LOCK:
                              
            FIND craptlc WHERE craptlc.cdcooper = par_cdcooper     AND
                               craptlc.cdadmcrd = crawcrd.cdadmcrd AND
                               craptlc.tpcartao = crawcrd.tpcartao AND
                               craptlc.cdlimcrd = crawcrd.cdlimcrd AND
                               craptlc.dddebito = 0           
                               NO-LOCK NO-ERROR.
                             
            IF  AVAILABLE craptlc  THEN
                ASSIGN aux_vldevcar = aux_vldevcar + craptlc.vllimcrd.

        END. /** Fim do FOR EACH crawcrd **/  */

        FOR EACH crapcdb WHERE crapcdb.cdcooper = par_cdcooper     AND
                               crapcdb.nrdconta = crapass.nrdconta AND
                               crapcdb.insitchq = 2                AND
                               crapcdb.dtlibera > par_dtmvtolt     NO-LOCK:
    
            ASSIGN aux_vldevchq = aux_vldevchq + crapcdb.vlcheque.
        
        END. /** Fim do FOR EACH crapcdb **/
           
        FOR EACH craptdb WHERE (craptdb.cdcooper = par_cdcooper     AND
                                craptdb.insittit = 4                AND
                                craptdb.nrdconta = crapass.nrdconta)
                               OR
                               (craptdb.cdcooper = par_cdcooper     AND
                                craptdb.insittit = 2                AND
                                craptdb.nrdconta = crapass.nrdconta AND
                                craptdb.dtdpagto = par_dtmvtolt)    NO-LOCK:
                               
            ASSIGN aux_vldevtit = aux_vldevtit + craptdb.vltitulo.
                  
        END. /** Fim do FOR EACH craptdb **/                       

        FIND crapsld WHERE crapsld.cdcooper = par_cdcooper     AND
                           crapsld.nrdconta = crapass.nrdconta NO-LOCK NO-ERROR.
 
        IF  NOT AVAILABLE crapsld  THEN
            DO:
                ASSIGN aux_cdcritic = 10
                       aux_dscritic = "".
                   
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                DELETE PROCEDURE h-b1wgen0002.
                                               
                RETURN "NOK".
            END.    

        ASSIGN aux_vldevlim = aux_vldevlim + crapass.vllimcre
               aux_vlsdeved = crapsld.vlsddisp.
                
        IF  aux_vlsdeved > 0  THEN
            ASSIGN aux_vlsdeved = 0.

        IF  aux_vlsdeved < 0  THEN
            DO:
                ASSIGN aux_vlsdeved = aux_vlsdeved * -1.
                                     
                IF  aux_vlsdeved > crapass.vllimcre  THEN
                    ASSIGN aux_vlsdeved = aux_vlsdeved - crapass.vllimcre.
                ELSE
                    ASSIGN aux_vlsdeved = 0.
            END. 
                 
        ASSIGN aux_vldevcta = aux_vldevcta + aux_vlsdeved.


    END. /** Fim do FOR EACH crapass **/
    
    DELETE PROCEDURE h-b1wgen0002.
    
    ASSIGN par_vlutiliz = aux_vldevepr + aux_vldevchq + aux_vldevlim +
                          aux_vldevcar + aux_vldevcta + aux_vldevtit.


    RETURN "OK".

END PROCEDURE.


PROCEDURE obtem_risco:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.

    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_nivrisco AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dtrefere AS DATE                           NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                    NO-UNDO.    
    DEF VAR aux_vlarrast AS DECI                                    NO-UNDO.
    DEF VAR aux_dsdrisco AS CHAR EXTENT 20                          NO-UNDO.
    DEF VAR aux_dtultdma AS DATE                                    NO-UNDO.
    DEF VAR aux_innivris AS INTE                                    NO-UNDO.

    /* Ultimo dia do mes passado */
    ASSIGN aux_dtultdma = par_dtmvtolt - DAY(par_dtmvtolt).
    
    FOR EACH craptab WHERE craptab.cdcooper = par_cdcooper AND 
                           craptab.nmsistem = "CRED"       AND 
                           craptab.tptabela = "GENERI"     AND 
                           craptab.cdempres = 00           AND
                           craptab.cdacesso = "PROVISAOCL" NO-LOCK:
                                       
        ASSIGN aux_contador               = INTE(SUBSTR(craptab.dstextab,12,2))
               aux_dsdrisco[aux_contador] = TRIM(SUBSTR(craptab.dstextab,8,3)). 
    
    END. /** Fim do FOR EACH craptab **/

    /** Alimentar variavel para nao ser preciso criar registro na PROVISAOCL **/
    ASSIGN aux_innivris     = 2
           aux_dsdrisco[10] = "H".

    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND 
                       craptab.nmsistem = "CRED"       AND
                       craptab.tptabela = "USUARI"     AND
                       craptab.cdempres = 11           AND
                       craptab.cdacesso = "RISCOBACEN" AND
                       craptab.tpregist = 000          NO-LOCK NO-ERROR.

    IF  AVAILABLE craptab  THEN
        ASSIGN aux_vlarrast = DECI(SUBSTR(craptab.dstextab,3,9)).

    /** Valor Arrasto **/
    FIND LAST crapris WHERE crapris.cdcooper = par_cdcooper AND 
                            crapris.nrdconta = par_nrdconta AND
                            crapris.inddocto = 1            AND 
                            crapris.vldivida > aux_vlarrast AND 
                            crapris.dtrefere <= aux_dtultdma NO-LOCK NO-ERROR.
                            
    IF  AVAILABLE crapris  THEN
        ASSIGN aux_innivris = crapris.innivris.
    ELSE
      DO:
          FIND LAST crapris WHERE crapris.cdcooper = par_cdcooper AND 
                                  crapris.nrdconta = par_nrdconta AND
                                  crapris.inddocto = 1            AND
                                  crapris.dtrefere <= aux_dtultdma 
                                  NO-LOCK NO-ERROR.

          /* Quando possuir operacao em Prejuizo, o risco da central sera H */
          IF AVAIL crapris AND crapris.innivris = 10 THEN
             ASSIGN aux_innivris = crapris.innivris.
             
      END.

    IF  AVAILABLE crapris  THEN
        DO:
            ASSIGN par_nivrisco = aux_dsdrisco[aux_innivris]
                   par_dtrefere = crapris.dtrefere.

            IF  par_nivrisco = "AA"  THEN
                ASSIGN par_nivrisco = ""   /** Contratos Antigos **/
                       par_dtrefere = ?.
        END.

    RETURN "OK".
    
END PROCEDURE.


PROCEDURE lista_avalistas: 

    /**********************************************************************/
    /** Procedure para listar avalistas de contratos                     **/
    /** Baseado no programa fontes/limite_c.p                            **/
    /**********************************************************************/

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaav1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaav2 AS INTE                           NO-UNDO.
    DEF VAR aux_vlmedfat AS DECI                                    NO-UNDO. /*PRJ438 - Sprint 5*/
    
    DEF OUTPUT PARAM TABLE FOR tt-dados-avais.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR aux_nrdocava AS CHAR                                    NO-UNDO.
    DEF VAR aux_vledvmto AS DECI                                    NO-UNDO.
    DEF VAR aux_vlrenmes AS DECI                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_tpctrato AS INTE                                    NO-UNDO.
	DEF VAR aux_nrcpfcgc LIKE crapttl.nrcpfcgc					    NO-UNDO.
	DEF VAR aux_vlrencjg AS DECI                                    NO-UNDO.
	DEF VAR aux_nrctacjg AS INTE                                    NO-UNDO.
    
    /* Nome do conjuge */
    DEF VAR aux_nmconjug AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfcjg LIKE crapcje.nrcpfcjg                      NO-UNDO.
    
    DEF VAR aux_stsnrcal AS LOGICAL                                 NO-UNDO.
    DEF VAR avt_inpessoa AS INTEGER                                 NO-UNDO.

    DEF VAR aux_nrctaav1 AS INTE                                    NO-UNDO.
    DEF VAR aux_nrctaav2 AS INTE                                    NO-UNDO.

    IF  par_tpctrato = 8  OR /* DSC TIT */
        par_tpctrato = 2  OR /* DSC CHQ */
        par_tpctrato = 3  THEN /* LIM CRED */
    DO:
        IF  par_tpctrato = 8  THEN
            ASSIGN aux_tpctrato = 3.
        ELSE
        IF  par_tpctrato = 2  THEN
            ASSIGN aux_tpctrato =  2.
        ELSE
        IF  par_tpctrato = 3  THEN
            ASSIGN aux_tpctrato = 1.

        FIND craplim WHERE craplim.cdcooper = par_cdcooper AND
                           craplim.nrdconta = par_nrdconta AND
                           craplim.nrctrlim = par_nrctrato AND
                           craplim.tpctrlim = aux_tpctrato NO-LOCK NO-ERROR.

        IF  NOT AVAIL craplim  THEN
        DO:
            FIND crawlim WHERE crawlim.cdcooper = par_cdcooper AND
                               crawlim.nrdconta = par_nrdconta AND
                               crawlim.nrctrlim = par_nrctrato AND
                               crawlim.tpctrlim = aux_tpctrato NO-LOCK NO-ERROR.

            IF  NOT AVAIL crawlim  THEN
            DO:
            ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Registro de limite ou de proposta nao encontrado." +
                                  STRING(par_cdcooper) +
                STRING(par_nrdconta) +
                STRING(par_nrctrato) +
                STRING(par_tpctrato).
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".
        END.
            ELSE
                ASSIGN aux_nrctaav1 = crawlim.nrctaav1
                       aux_nrctaav2 = crawlim.nrctaav2.
        END.
        ELSE
            ASSIGN aux_nrctaav1 = craplim.nrctaav1
                   aux_nrctaav2 = craplim.nrctaav2.
        
        IF  aux_nrctaav1 > 0  THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = aux_nrctaav1 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapass THEN
                    DO:
                        ASSIGN aux_cdcritic = 9
                               aux_dscritic = "".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        RETURN "NOK".
                    END.

                FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper     AND
                                   crapenc.nrdconta = crapass.nrdconta AND
                                   crapenc.idseqttl = 1
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapenc THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Endereco nao cadastrado.".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        RETURN "NOK".
                    END.

                IF  crapass.inpessoa = 1  THEN  
                    ASSIGN aux_nrdocava = "C.P.F. " +
                                          STRING(STRING(crapass.nrcpfcgc,
                                          "99999999999"),"xxx.xxx.xxx-xx").
                ELSE
                    ASSIGN aux_nrdocava = "CNPJ " +
                                          STRING(STRING(crapass.nrcpfcgc,
                                          "99999999999999"),"xx.xxx.xxx/xxxx-xx").
                ASSIGN aux_cdgraupr = 0
                       aux_vlrenmes = 0
					   aux_nrcpfcgc = 0.

                IF   crapass.inpessoa = 1 THEN
                     DO:
                        FIND crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                           crapttl.nrdconta = crapass.nrdconta AND
                                           crapttl.idseqttl = 2 
                                           NO-LOCK NO-ERROR.

                        IF   AVAIL crapttl THEN 
                             ASSIGN aux_cdgraupr = crapttl.cdgraupr
							        aux_nrcpfcgc = crapttl.nrcpfcgc.

                        FIND crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                           crapttl.nrdconta = crapass.nrdconta AND
                                           crapttl.idseqttl = 1 
                                           NO-LOCK NO-ERROR.

                        IF   AVAIL crapttl THEN
                             aux_vlrenmes = crapttl.vlsalari     + 
                                            crapttl.vldrendi[1]  + 
                                            crapttl.vldrendi[2]  +
                                            crapttl.vldrendi[3]  +
                                            crapttl.vldrendi[4]  +
                                            crapttl.vldrendi[5]  +
                                            crapttl.vldrendi[6]. 
                     END.

                IF   crapass.inpessoa = 2 THEN /*Faturamento Avalista PJ*/
                     DO:
                         RUN calcula-faturamento (INPUT  par_cdcooper,
                                                  INPUT  par_cdagenci,
                                                  INPUT  par_nrdcaixa,
                                                  INPUT  par_idorigem,
                                                  INPUT  crapass.nrdconta, /*Conta avalista*/
                                                  INPUT  "",
                                                  OUTPUT aux_vlmedfat).
				            
                         ASSIGN aux_vlrenmes = aux_vlmedfat.
                     END.      

               ASSIGN aux_vledvmto = 0. 

                /* endevidamento do aval cooperado */
                FOR EACH crapsdv WHERE crapsdv.cdcooper = par_cdcooper       AND
                                       crapsdv.nrdconta = crapass.nrdconta   AND
                                       CAN-DO("1,2,3,6",STRING(crapsdv.tpdsaldo))
                                       NO-LOCK:

                    ASSIGN aux_vledvmto = aux_vledvmto + crapsdv.vldsaldo. 

                END. 

                FIND FIRST crapcem WHERE crapcem.cdcooper = par_cdcooper     AND
                                         crapcem.nrdconta = crapass.nrdconta AND
                                         crapcem.idseqttl = 1 
                                         NO-LOCK NO-ERROR.

                FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                                  WHERE craptfc.cdcooper = par_cdcooper     AND
                                        craptfc.nrdconta = crapass.nrdconta AND
                                        craptfc.idseqttl = 1 
                                  NO-LOCK:
                END.
                
                /* Limpar o nome do conjuge */
                ASSIGN aux_nmconjug = ""
                       aux_nrcpfcjg = 0
					   aux_nrctacjg = 0
					   aux_vlrencjg = 0.

                FIND  crapcje WHERE crapcje.cdcooper = par_cdcooper AND 
                                    crapcje.nrdconta = crapass.nrdconta AND 
                                    crapcje.idseqttl = 1 USE-INDEX crapcje1 NO-ERROR.
                
                IF AVAIL crapcje THEN
                DO:
                    /* Validar se o numero da conta do conjuge é maior que zero
                       busca as informações do nome do primeiro titular da conta de conjuge*/
                    IF crapcje.nrctacje > 0 THEN
                    DO:
                       FIND crapttl WHERE crapttl.cdcooper = crapcje.cdcooper
                                      AND crapttl.nrdconta = crapcje.nrctacje
                                      AND crapttl.idseqttl = 1
                                    NO-LOCK NO-ERROR.
                       /* Se possuir titular carrega o nome */
                       IF AVAIL crapttl THEN
                           ASSIGN aux_nmconjug = crapttl.nmextttl
                                  aux_nrcpfcjg = crapttl.nrcpfcgc
								  aux_nrctacjg = crapttl.nrdconta
								  aux_vlrencjg = crapttl.vlsalari     + 
                                              crapttl.vldrendi[1]  + 
                                              crapttl.vldrendi[2]  +
                                              crapttl.vldrendi[3]  +
                                              crapttl.vldrendi[4]  +
                                              crapttl.vldrendi[5]  +
                                              crapttl.vldrendi[6].

                    END.
                    ELSE
                        /* Se o numero da conta não é maior que zero carrega o nome da crapcje */
                        ASSIGN aux_nmconjug = crapcje.nmconjug
                               aux_nrcpfcjg = crapcje.nrcpfcjg
							   aux_nrctacjg = crapcje.nrctacje
							   aux_vlrencjg = crapcje.vlsalari.
                END.

                /* Buscar nacionalidade */
                IF crapass.cdnacion > 0 THEN
                DO:
                  FIND FIRST crapnac
                       WHERE crapnac.cdnacion = crapass.cdnacion
                       NO-LOCK NO-ERROR.              
                END.

                CREATE tt-dados-avais.
                ASSIGN aux_contador            = aux_contador + 1
                       tt-dados-avais.nrctaava = crapass.nrdconta
                       tt-dados-avais.nmdavali = crapass.nmprimtl
                       tt-dados-avais.nrcpfcgc = crapass.nrcpfcgc
                       tt-dados-avais.nrdocava = aux_nrdocava
                       tt-dados-avais.tpdocava = ""
                       tt-dados-avais.nmconjug = aux_nmconjug
                       tt-dados-avais.nrcpfcjg = aux_nrcpfcjg
                       tt-dados-avais.nrdoccjg = IF aux_cdgraupr = 1 THEN 
                                                    "C.P.F. " +
                                                    STRING(STRING(aux_nrcpfcgc,
                                                    "99999999999"),"xxx.xxx.xxx-xx")
                                                 ELSE 
                                                    ""                              
                       tt-dados-avais.tpdoccjg = ""
                       tt-dados-avais.nrfonres = IF craptfc.nrdddtfc <> ? THEN STRING(craptfc.nrdddtfc) + STRING(craptfc.nrtelefo) 
                                                 ELSE
                                                 STRING("00") + STRING(craptfc.nrtelefo)
                                                 WHEN AVAIL craptfc
                       tt-dados-avais.dsdemail = crapcem.dsdemail
                                                 WHEN AVAIL crapcem
                       tt-dados-avais.dsendre1 = TRIM(crapenc.dsendere)
                       tt-dados-avais.dsendre2 = TRIM(crapenc.nmbairro)
                       tt-dados-avais.nmcidade = TRIM(crapenc.nmcidade)
                       tt-dados-avais.cdufresd = TRIM(crapenc.cdufende)
                       tt-dados-avais.nrcepend = crapenc.nrcepend
                       tt-dados-avais.dsnacion = crapnac.dsnacion WHEN AVAIL crapnac
                       tt-dados-avais.vledvmto = aux_vledvmto
                       tt-dados-avais.vlrenmes = aux_vlrenmes
                       tt-dados-avais.idavalis = aux_contador
                       tt-dados-avais.nrendere = crapenc.nrendere
                       tt-dados-avais.complend = crapenc.complend
                       tt-dados-avais.nrcxapst = crapenc.nrcxapst
                       tt-dados-avais.inpessoa = crapass.inpessoa
                       tt-dados-avais.dtnascto = crapass.dtnasctl
					   tt-dados-avais.vlrencjg = aux_vlrencjg
					   tt-dados-avais.nrctacjg = aux_nrctacjg.

            END.
        
        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND 
                               crapavt.tpctrato = par_tpctrato AND 
                               crapavt.nrdconta = par_nrdconta AND
                               crapavt.nrctremp = par_nrctrato NO-LOCK BY ROWID(crapavt):
            
            
            /* Buscar nacionalidade */
            IF  crapavt.cdnacion > 0 THEN
            DO:
              FIND FIRST crapnac
                   WHERE crapnac.cdnacion = crapavt.cdnacion
                   NO-LOCK NO-ERROR.  			
            END. 

            CREATE tt-dados-avais.
            ASSIGN aux_contador            = aux_contador + 1
                   tt-dados-avais.nrctaava = 0
                   tt-dados-avais.nmdavali = crapavt.nmdavali 
                   tt-dados-avais.nrcpfcgc = crapavt.nrcpfcgc
                   tt-dados-avais.tpdocava = crapavt.tpdocava
                   tt-dados-avais.nrdocava = crapavt.nrdocava
                   tt-dados-avais.nmconjug = crapavt.nmconjug
                   tt-dados-avais.nrcpfcjg = crapavt.nrcpfcjg
                   tt-dados-avais.tpdoccjg = crapavt.tpdoccjg 
                   tt-dados-avais.nrdoccjg = IF crapavt.nrcpfcjg > 0 THEN 
                                                "C.P.F. " +
                                                STRING(STRING(crapavt.nrcpfcjg,
                                                "99999999999"),"xxx.xxx.xxx-xx")
                                             ELSE 
                                                crapavt.nrdoccjg
                   tt-dados-avais.dsendre1 = crapavt.dsendres[1]
                   tt-dados-avais.dsendre2 = crapavt.dsendres[2]
                   tt-dados-avais.nrfonres = crapavt.nrfonres
                   tt-dados-avais.dsdemail = crapavt.dsdemail
                   tt-dados-avais.nmcidade = crapavt.nmcidade
                   tt-dados-avais.cdufresd = crapavt.cdufresd
                   tt-dados-avais.nrcepend = crapavt.nrcepend
                   tt-dados-avais.cdnacion = crapavt.cdnacion	
                   tt-dados-avais.dsnacion = crapnac.dsnacion WHEN AVAIL crapnac
                   tt-dados-avais.vledvmto = crapavt.vledvmto
                   tt-dados-avais.vlrenmes = crapavt.vlrenmes
                   tt-dados-avais.idavalis = aux_contador
                   tt-dados-avais.nrendere = crapavt.nrendere
                   tt-dados-avais.complend = crapavt.complend
                   tt-dados-avais.nrcxapst = crapavt.nrcxapst
                   tt-dados-avais.inpessoa = crapavt.inpessoa
                   tt-dados-avais.dtnascto = crapavt.dtnascto
				   tt-dados-avais.vlrencjg = crapavt.vlrencjg
				   tt-dados-avais.nrctacjg = 0.

        END. /** Fim do FOR EACH crapavt **/

        ASSIGN aux_cdgraupr = 0
		       aux_nrcpfcgc = 0.

        IF  aux_nrctaav2 > 0  THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = aux_nrctaav2 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapass THEN
                    DO:
                        ASSIGN aux_cdcritic = 9
                               aux_dscritic = "".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        RETURN "NOK".
                    END.

                FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper     AND
                                   crapenc.nrdconta = crapass.nrdconta AND
                                   crapenc.idseqttl = 1
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapenc THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Endereco nao cadastrado.".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        RETURN "NOK".
                    END.

                ASSIGN aux_vledvmto = 0. 

                /* endevidamento do aval cooperado */
                FOR EACH crapsdv WHERE crapsdv.cdcooper = par_cdcooper       AND
                                       crapsdv.nrdconta = crapass.nrdconta   AND
                                       CAN-DO("1,2,3,6",STRING(crapsdv.tpdsaldo))
                                       NO-LOCK:

                    ASSIGN aux_vledvmto = aux_vledvmto + crapsdv.vldsaldo. 

                END. 

                IF  crapass.inpessoa = 1  THEN
                    ASSIGN aux_nrdocava = "C.P.F. " +
                                          STRING(STRING(crapass.nrcpfcgc,
                                          "99999999999"),"xxx.xxx.xxx-xx").
                ELSE
                    ASSIGN aux_nrdocava = "CNPJ " +
                                          STRING(STRING(crapass.nrcpfcgc,
                                          "99999999999999"),"xx.xxx.xxx/xxxx-xx").

                ASSIGN aux_vlrenmes = 0.

                IF  crapass.inpessoa = 1 THEN
                DO:
                    FIND crapttl WHERE crapttl.cdcooper = crapass.cdcooper AND
                                       crapttl.nrdconta = crapass.nrdconta AND
                                       crapttl.idseqttl = 2 
                                       NO-LOCK NO-ERROR.

                    IF   AVAIL crapttl THEN 
                         ASSIGN aux_cdgraupr = crapttl.cdgraupr
						        aux_nrcpfcgc = crapttl.nrcpfcgc.

                    FIND crapttl WHERE crapttl.cdcooper = crapass.cdcooper AND
                                       crapttl.nrdconta = crapass.nrdconta AND
                                       crapttl.idseqttl = 1 
                                       NO-LOCK NO-ERROR.

                    IF   AVAIL crapttl THEN
                         aux_vlrenmes = crapttl.vlsalari     + 
                                        crapttl.vldrendi[1]  + 
                                        crapttl.vldrendi[2]  +
                                        crapttl.vldrendi[3]  +
                                        crapttl.vldrendi[4]  +
                                        crapttl.vldrendi[5]  +
                                        crapttl.vldrendi[6]. 
                END.

                IF   crapass.inpessoa = 2 THEN /*Faturamento Avalista PJ*/
                    DO:
                        RUN calcula-faturamento (INPUT  par_cdcooper,
                                                 INPUT  par_cdagenci,
                                                 INPUT  par_nrdcaixa,
                                                 INPUT  par_idorigem,
                                                 INPUT  crapass.nrdconta, /*Conta avalista*/
                                                 INPUT  "",
                                                 OUTPUT aux_vlmedfat).
				            
                        ASSIGN aux_vlrenmes = aux_vlmedfat.
                    END.

                FIND FIRST crapcem WHERE crapcem.cdcooper = par_cdcooper     AND
                                         crapcem.nrdconta = crapass.nrdconta AND
                                         crapcem.idseqttl = 1 
                                         NO-LOCK NO-ERROR.

                FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                                  WHERE craptfc.cdcooper = par_cdcooper     AND
                                        craptfc.nrdconta = crapass.nrdconta AND
                                        craptfc.idseqttl = 1 
                                  NO-LOCK:
                END.
                
                /* Limpar o nome do conjuge */
                ASSIGN aux_nmconjug = ""
                       aux_nrcpfcjg = 0
					   aux_nrctacjg = 0
					   aux_vlrencjg = 0.

                FIND  crapcje WHERE crapcje.cdcooper = par_cdcooper AND 
                                    crapcje.nrdconta = crapass.nrdconta AND 
                                    crapcje.idseqttl = 1 USE-INDEX crapcje1 NO-ERROR.
                
                IF AVAIL crapcje THEN
                DO:
                    /* Validar se o numero da conta do conjuge é maior que zero
                       busca as informações do nome do primeiro titular da conta de conjuge*/
                    IF crapcje.nrctacje > 0 THEN
                    DO:
                       FIND crapttl WHERE crapttl.cdcooper = crapcje.cdcooper
                                      AND crapttl.nrdconta = crapcje.nrctacje
                                      AND crapttl.idseqttl = 1
                                    NO-LOCK NO-ERROR.
                       /* Se possuir titular carrega o nome */
                       IF AVAIL crapttl THEN
                           ASSIGN aux_nmconjug = crapttl.nmextttl
                                  aux_nrcpfcjg = crapttl.nrcpfcgc
								  aux_nrctacjg = crapttl.nrdconta
								  aux_vlrencjg = crapttl.vlsalari     + 
                                              crapttl.vldrendi[1]  + 
                                              crapttl.vldrendi[2]  +
                                              crapttl.vldrendi[3]  +
                                              crapttl.vldrendi[4]  +
                                              crapttl.vldrendi[5]  +
                                              crapttl.vldrendi[6].

                    END.
                    ELSE
                        /* Se o numero da conta não é maior que zero carrega o nome da crapcje */
                        ASSIGN aux_nmconjug = crapcje.nmconjug
                               aux_nrcpfcjg = crapcje.nrcpfcjg
							   aux_nrctacjg = crapcje.nrctacje
							   aux_vlrencjg = crapcje.vlsalari.
                END.

                /* Buscar nacionalidade */
                IF crapass.cdnacion > 0 THEN
                DO:
                  FIND FIRST crapnac
                       WHERE crapnac.cdnacion = crapass.cdnacion
                       NO-LOCK NO-ERROR.  
                END. 
                 
                CREATE tt-dados-avais.
                ASSIGN aux_contador            = aux_contador + 1
                       tt-dados-avais.nrctaava = crapass.nrdconta
                       tt-dados-avais.nmdavali = crapass.nmprimtl
                       tt-dados-avais.nrcpfcgc = crapass.nrcpfcgc
                       tt-dados-avais.nrdocava = aux_nrdocava
                       tt-dados-avais.tpdocava = ""
                       tt-dados-avais.nmconjug = aux_nmconjug
                       tt-dados-avais.nrcpfcjg = aux_nrcpfcjg
                       tt-dados-avais.nrdoccjg = IF aux_cdgraupr = 1 THEN 
                                                    "C.P.F. " +
                                                    STRING(STRING(aux_nrcpfcgc,
                                                    "99999999999"),"xxx.xxx.xxx-xx")
                                                 ELSE 
                                                    ""
                       tt-dados-avais.tpdoccjg = ""
                       tt-dados-avais.nrfonres = IF craptfc.nrdddtfc <> ? THEN STRING(craptfc.nrdddtfc) + STRING(craptfc.nrtelefo) 
                                                 ELSE
                                                 STRING("00") + STRING(craptfc.nrtelefo)
                                                 WHEN AVAIL craptfc
                       tt-dados-avais.dsdemail = crapcem.dsdemail
                                                 WHEN AVAIL crapcem               
                       tt-dados-avais.dsendre1 = TRIM(crapenc.dsendere)
                       tt-dados-avais.dsendre2 = TRIM(crapenc.nmbairro)
                       tt-dados-avais.nmcidade = TRIM(crapenc.nmcidade)
                       tt-dados-avais.cdufresd = TRIM(crapenc.cdufende)
                       tt-dados-avais.nrcepend = crapenc.nrcepend
                       tt-dados-avais.cdnacion = crapass.cdnacion 
                       tt-dados-avais.dsnacion = crapnac.dsnacion WHEN AVAIL crapnac
                       tt-dados-avais.vledvmto = aux_vledvmto
                       tt-dados-avais.vlrenmes = aux_vlrenmes
                       tt-dados-avais.idavalis = aux_contador
                       tt-dados-avais.nrendere = crapenc.nrendere
                       tt-dados-avais.complend = crapenc.complend
                       tt-dados-avais.nrcxapst = crapenc.nrcxapst
                       tt-dados-avais.inpessoa = crapass.inpessoa
                       tt-dados-avais.dtnascto = crapass.dtnasctl
					   tt-dados-avais.vlrencjg = aux_vlrencjg
					   tt-dados-avais.nrctacjg = aux_nrctacjg.
            END.


    END.
    ELSE
    IF  par_tpctrato = 1  THEN /* EMPRESTIMO */
    DO: 
        FIND crawepr WHERE crawepr.cdcooper = par_cdcooper AND
                           crawepr.nrdconta = par_nrdconta AND
                           crawepr.nrctremp = par_nrctrato NO-LOCK NO-ERROR.

        IF  NOT AVAIL crawepr  THEN
        DO:
            ASSIGN aux_cdcritic = 0
                   aux_dscritic = "Registro de emprestimo nao encontrado.".
            
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT 1,            /** Sequencia **/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).

            RETURN "NOK".

        END.

        IF  crawepr.nrctaav1 > 0  THEN
            DO: 
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = crawepr.nrctaav1 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapass THEN
                    DO:
                        ASSIGN aux_cdcritic = 9
                               aux_dscritic = "".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        RETURN "NOK".
                    END.

                FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper     AND
                                   crapenc.nrdconta = crapass.nrdconta AND
                                   crapenc.idseqttl = 1
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapenc THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Endereco nao cadastrado.".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        RETURN "NOK".
                    END.

                ASSIGN aux_cdgraupr = 0
                       aux_vlrenmes = 0
					   aux_nrcpfcgc = 0.

                IF   crapass.inpessoa = 1 THEN
                     DO:
                        FIND crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                           crapttl.nrdconta = crapass.nrdconta AND
                                           crapttl.idseqttl = 2 
                                           NO-LOCK NO-ERROR.

                        IF   AVAIL crapttl THEN 
                             ASSIGN aux_cdgraupr = crapttl.cdgraupr
							        aux_nrcpfcgc = crapttl.nrcpfcgc.

                        FIND crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                           crapttl.nrdconta = crapass.nrdconta AND
                                           crapttl.idseqttl = 1 
                                           NO-LOCK NO-ERROR.

                        IF   AVAIL crapttl THEN
                             aux_vlrenmes = crapttl.vlsalari     + 
                                            crapttl.vldrendi[1]  + 
                                            crapttl.vldrendi[2]  +
                                            crapttl.vldrendi[3]  +
                                            crapttl.vldrendi[4]  +
                                            crapttl.vldrendi[5]  +
                                            crapttl.vldrendi[6]. 
                     END.

               ASSIGN aux_vledvmto = 0. 

                IF   crapass.inpessoa = 2 THEN /*Faturamento Avalista PJ - BUG14453*/
                    DO:
                    RUN calcula-faturamento (INPUT  par_cdcooper,
                                             INPUT  par_cdagenci,
                                             INPUT  par_nrdcaixa,
                                             INPUT  par_idorigem,
                                             INPUT  crapass.nrdconta, /*Conta avalista*/
                                             INPUT  "",
                                             OUTPUT aux_vlmedfat).
				     
					 ASSIGN aux_vlrenmes = aux_vlmedfat.
                    END.

                /* endevidamento do aval cooperado */
                FOR EACH crapsdv WHERE crapsdv.cdcooper = par_cdcooper       AND
                                       crapsdv.nrdconta = crapass.nrdconta   AND
                                       CAN-DO("1,2,3,6",STRING(crapsdv.tpdsaldo))
                                       NO-LOCK:

                    ASSIGN aux_vledvmto = aux_vledvmto + crapsdv.vldsaldo. 

                END. 

                FIND FIRST crapcem WHERE crapcem.cdcooper = par_cdcooper     AND
                                         crapcem.nrdconta = crapass.nrdconta AND
                                         crapcem.idseqttl = 1 
                                         NO-LOCK NO-ERROR.

                FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                                  WHERE craptfc.cdcooper = par_cdcooper     AND
                                        craptfc.nrdconta = crapass.nrdconta AND
                                        craptfc.idseqttl = 1 
                                  NO-LOCK:
                END.
                
                /* Limpar nome do conjuge */
                ASSIGN aux_nmconjug = ""
                       aux_nrcpfcjg = 0
					   aux_nrctacjg = 0
					   aux_vlrencjg = 0.

                FIND  crapcje WHERE crapcje.cdcooper = par_cdcooper AND 
                                    crapcje.nrdconta = crapass.nrdconta AND 
                                    crapcje.idseqttl = 1 USE-INDEX crapcje1 NO-ERROR.
                
                IF AVAIL crapcje THEN
                DO:
                    /* Validar se o numero da conta do conjuge é maior que zero
                       busca as informações do nome do primeiro titular da conta de conjuge*/
                    IF crapcje.nrctacje > 0 THEN
                    DO:
                       FIND crapttl WHERE crapttl.cdcooper = crapcje.cdcooper
                                      AND crapttl.nrdconta = crapcje.nrctacje
                                      AND crapttl.idseqttl = 1
                                    NO-LOCK NO-ERROR.
                       /* Se possuir titular carrega o nome */
                       IF AVAIL crapttl THEN
                           ASSIGN aux_nmconjug = crapttl.nmextttl
                                  aux_nrcpfcjg = crapttl.nrcpfcgc
								  aux_nrctacjg = crapttl.nrdconta
								  aux_vlrencjg = crapttl.vlsalari     + 
                                              crapttl.vldrendi[1]  + 
                                              crapttl.vldrendi[2]  +
                                              crapttl.vldrendi[3]  +
                                              crapttl.vldrendi[4]  +
                                              crapttl.vldrendi[5]  +
                                              crapttl.vldrendi[6].								  

                    END.
                    ELSE
                        /* Se o numero da conta não é maior que zero carrega o nome da crapcje */
                        ASSIGN aux_nmconjug = crapcje.nmconjug
                               aux_nrcpfcjg = crapcje.nrcpfcjg
							   aux_nrctacjg = crapcje.nrctacje
							   aux_vlrencjg = crapcje.vlsalari.
                END.
                          
                /* Buscar nacionalidade */
                IF crapass.cdnacion > 0 THEN
                DO:
                  FIND FIRST crapnac
                       WHERE crapnac.cdnacion = crapass.cdnacion
                       NO-LOCK NO-ERROR. 
                END.
                
                CREATE tt-dados-avais.
                ASSIGN aux_contador            = aux_contador + 1
                       tt-dados-avais.nrctaava = crapass.nrdconta
                       tt-dados-avais.nmdavali = crapass.nmprimtl
                       tt-dados-avais.nrcpfcgc = crapass.nrcpfcgc
                       tt-dados-avais.nrdocava = aux_nrdocava
                       tt-dados-avais.tpdocava = ""
                       tt-dados-avais.nmconjug = aux_nmconjug
                       tt-dados-avais.nrcpfcjg = aux_nrcpfcjg
                       tt-dados-avais.nrdoccjg = IF aux_cdgraupr = 1 THEN 
                                                    "C.P.F. " +
                                                    STRING(STRING(aux_nrcpfcgc,
                                                    "99999999999"),"xxx.xxx.xxx-xx")
                                                 ELSE 
                                                    ""
                       tt-dados-avais.tpdoccjg = ""
                       tt-dados-avais.nrfonres = IF craptfc.nrdddtfc <> ? THEN STRING(craptfc.nrdddtfc) + STRING(craptfc.nrtelefo) 
                                                 ELSE
                                                 STRING("00") + STRING(craptfc.nrtelefo)
                                                 WHEN AVAIL craptfc
                       tt-dados-avais.dsdemail = crapcem.dsdemail
                                                   WHEN AVAIL crapcem
                       tt-dados-avais.dsendre1 = TRIM(crapenc.dsendere)
                       tt-dados-avais.dsendre2 = TRIM(crapenc.nmbairro)
                       tt-dados-avais.nmcidade = TRIM(crapenc.nmcidade)
                       tt-dados-avais.cdufresd = TRIM(crapenc.cdufende)
                       tt-dados-avais.nrcepend = crapenc.nrcepend
                       tt-dados-avais.cdnacion = crapass.cdnacion 
                       tt-dados-avais.dsnacion = crapnac.dsnacion
                                                 WHEN AVAIL crapnac 
                       tt-dados-avais.vledvmto = aux_vledvmto
                       tt-dados-avais.vlrenmes = aux_vlrenmes
                       tt-dados-avais.idavalis = aux_contador
                       tt-dados-avais.nrendere = crapenc.nrendere
                       tt-dados-avais.complend = crapenc.complend
                       tt-dados-avais.nrcxapst = crapenc.nrcxapst
                       tt-dados-avais.inpessoa = crapass.inpessoa
                       tt-dados-avais.dtnascto = crapass.dtnasctl
					   tt-dados-avais.vlrencjg = aux_vlrencjg
					   tt-dados-avais.nrctacjg = aux_nrctacjg.

            END.
        
        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND 
                               crapavt.tpctrato = par_tpctrato AND 
                               crapavt.nrdconta = par_nrdconta AND
                               crapavt.nrctremp = par_nrctrato NO-LOCK BY ROWID(crapavt):

            IF crapavt.cdnacion > 0 THEN
            DO:
              /* Buscar nacionalidade */
              FIND FIRST crapnac
                   WHERE crapnac.cdnacion = crapavt.cdnacion
                   NO-LOCK NO-ERROR. 
            END. 
            CREATE tt-dados-avais.
            ASSIGN aux_contador            = aux_contador + 1
                   tt-dados-avais.nrctaava = 0
                   tt-dados-avais.nmdavali = crapavt.nmdavali 
                   tt-dados-avais.nrcpfcgc = crapavt.nrcpfcgc
                   tt-dados-avais.tpdocava = crapavt.tpdocava
                   tt-dados-avais.nrdocava = crapavt.nrdocava
                   tt-dados-avais.nmconjug = crapavt.nmconjug
                   tt-dados-avais.nrcpfcjg = crapavt.nrcpfcjg
                   tt-dados-avais.tpdoccjg = crapavt.tpdoccjg 
                   tt-dados-avais.nrdoccjg = IF crapavt.nrcpfcjg > 0 THEN 
                                                "C.P.F. " +
                                                STRING(STRING(crapavt.nrcpfcjg,
                                                "99999999999"),"xxx.xxx.xxx-xx")
                                             ELSE 
                                                crapavt.nrdoccjg
                   tt-dados-avais.dsendre1 = crapavt.dsendres[1]
                   tt-dados-avais.dsendre2 = crapavt.dsendres[2]
                   tt-dados-avais.nrfonres = crapavt.nrfonres
                   tt-dados-avais.dsdemail = crapavt.dsdemail
                   tt-dados-avais.nmcidade = crapavt.nmcidade
                   tt-dados-avais.cdufresd = crapavt.cdufresd
                   tt-dados-avais.nrcepend = crapavt.nrcepend
                   tt-dados-avais.cdnacion = crapavt.cdnacion
                   tt-dados-avais.dsnacion = crapnac.dsnacion
                                             WHEN AVAIL crapnac
                   tt-dados-avais.vledvmto = crapavt.vledvmto
                   tt-dados-avais.vlrenmes = crapavt.vlrenmes
                   tt-dados-avais.idavalis = aux_contador
                   tt-dados-avais.nrendere = crapavt.nrendere
                   tt-dados-avais.complend = crapavt.complend
                   tt-dados-avais.nrcxapst = crapavt.nrcxapst
                   tt-dados-avais.inpessoa = crapavt.inpessoa
                   tt-dados-avais.dtnascto = crapavt.dtnascto
				   tt-dados-avais.vlrencjg = crapavt.vlrencjg
				   tt-dados-avais.nrctacjg = 0.
        
        END. /** Fim do FOR EACH crapavt **/
        
        /* emprestimos que nao possuam avalistas na crapavt */
        IF  NOT CAN-FIND(FIRST tt-dados-avais)  THEN
        DO:
            FIND crawepr WHERE crawepr.cdcooper = par_cdcooper AND
                               crawepr.nrdconta = par_nrdconta AND
                               crawepr.nrctremp = par_nrctrato 
                               NO-LOCK NO-ERROR.
                               
            IF  NOT AVAILABLE crawepr THEN
                DO:
                    ASSIGN aux_cdcritic = 356
                           aux_dscritic = "".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                                       
                    RETURN "NOK".
                END.
                
            IF  crawepr.nrctaav1 = 0 AND crawepr.nmdaval1 <> " "  THEN
                DO:        
                    CREATE tt-dados-avais.
                    ASSIGN aux_contador     = aux_contador + 1
                           tt-dados-avais.nrctaava = crawepr.nrctaav1
                           tt-dados-avais.nmdavali = crawepr.nmdaval1
                           tt-dados-avais.nrdocava = crawepr.dscpfav1
                           tt-dados-avais.dsendre1 = crawepr.dsendav1[1]
                           tt-dados-avais.dsendre2 = crawepr.dsendav1[2]
                           tt-dados-avais.nmconjug = crawepr.nmcjgav1
                           tt-dados-avais.nrdoccjg = crawepr.dscfcav1
                           tt-dados-avais.idavalis = aux_contador.
                END.
                
            IF  crawepr.nrctaav2 = 0 AND crawepr.nmdaval2 <> " "  THEN
                DO:                                          
                    CREATE tt-dados-avais.
                    ASSIGN aux_contador            = aux_contador + 1
                           tt-dados-avais.nrctaava = crawepr.nrctaav2
                           tt-dados-avais.nmdavali = crawepr.nmdaval2
                           tt-dados-avais.nrdocava = crawepr.dscpfav2
                           tt-dados-avais.dsendre1 = crawepr.dsendav2[1]
                           tt-dados-avais.dsendre2 = crawepr.dsendav2[2]
                           tt-dados-avais.nmconjug = crawepr.nmcjgav2
                           tt-dados-avais.nrdoccjg = crawepr.dscfcav2
                           tt-dados-avais.idavalis = aux_contador.  
                END.      
        END.

        IF  crawepr.nrctaav2 > 0  THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = crawepr.nrctaav2 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapass THEN
                    DO:
                        ASSIGN aux_cdcritic = 9
                               aux_dscritic = "".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        RETURN "NOK".
                    END.

                FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper     AND
                                   crapenc.nrdconta = crapass.nrdconta AND
                                   crapenc.idseqttl = 1
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapenc THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Endereco nao cadastrado.".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        RETURN "NOK".
                    END.

                ASSIGN aux_vledvmto = 0. 

                /* endevidamento do aval cooperado */
                FOR EACH crapsdv WHERE crapsdv.cdcooper = par_cdcooper       AND
                                       crapsdv.nrdconta = crapass.nrdconta   AND
                                       CAN-DO("1,2,3,6",STRING(crapsdv.tpdsaldo))
                                       NO-LOCK:

                    ASSIGN aux_vledvmto = aux_vledvmto + crapsdv.vldsaldo. 

                END. 

                ASSIGN aux_cdgraupr = 0
                       aux_vlrenmes = 0
					   aux_nrcpfcgc = 0.

                IF  crapass.inpessoa = 1  THEN
                   DO:
                    ASSIGN aux_nrdocava = "C.P.F. " +
                                          STRING(STRING(crapass.nrcpfcgc,
                                          "99999999999"),"xxx.xxx.xxx-xx").

                      FIND crapttl WHERE crapttl.cdcooper = crapass.cdcooper AND
                                         crapttl.nrdconta = crapass.nrdconta AND
                                         crapttl.idseqttl = 2 
                                         NO-LOCK NO-ERROR.

                      IF AVAIL crapttl THEN 
                         ASSIGN aux_cdgraupr = crapttl.cdgraupr
						        aux_nrcpfcgc = crapttl.nrcpfcgc.

                FIND crapttl WHERE crapttl.cdcooper = crapass.cdcooper  AND
                                   crapttl.nrdconta = crapass.nrdconta  AND
                                   crapttl.idseqttl = 1
                                   NO-LOCK NO-ERROR.

                IF   AVAIL crapttl    THEN
                     ASSIGN aux_vlrenmes = crapttl.vlsalari     + 
                                           crapttl.vldrendi[1]  + 
                                           crapttl.vldrendi[2]  +
                                           crapttl.vldrendi[3]  +
                                           crapttl.vldrendi[4]  +
                                           crapttl.vldrendi[5]  +
                                           crapttl.vldrendi[6]. 

			       END.
			    ELSE
			  	   ASSIGN aux_nrdocava = "CNPJ " +
                                          STRING(STRING(crapass.nrcpfcgc,
                                          "99999999999999"),"xx.xxx.xxx/xxxx-xx").				   
                   
                FIND FIRST crapcem WHERE crapcem.cdcooper = par_cdcooper     AND
                                         crapcem.nrdconta = crapass.nrdconta AND
                                         crapcem.idseqttl = 1 
                                         NO-LOCK NO-ERROR.

                FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                                  WHERE craptfc.cdcooper = par_cdcooper     AND
                                        craptfc.nrdconta = crapass.nrdconta AND
                                        craptfc.idseqttl = 1 
                                  NO-LOCK:
                END.
                
                IF   crapass.inpessoa = 2 THEN /*Faturamento Avalista PJ - BUG14453*/
                    DO:
                    RUN calcula-faturamento (INPUT  par_cdcooper,
                                             INPUT  par_cdagenci,
                                             INPUT  par_nrdcaixa,
                                             INPUT  par_idorigem,
                                             INPUT  crapass.nrdconta, /*Conta avalista*/
                                             INPUT  "",
                                             OUTPUT aux_vlmedfat).
				     
					 ASSIGN aux_vlrenmes = aux_vlmedfat.
                    END.
                
                /* Limpar nome do conjuge */
                ASSIGN aux_nmconjug = "" 
                       aux_nrcpfcjg = 0
					   aux_nrctacjg = 0
					   aux_vlrencjg = 0.

                FIND  crapcje WHERE crapcje.cdcooper = par_cdcooper AND 
                                    crapcje.nrdconta = crapass.nrdconta AND 
                                    crapcje.idseqttl = 1 USE-INDEX crapcje1 NO-ERROR.
                
                IF AVAIL crapcje THEN
                DO:
                    /* Validar se o numero da conta do conjuge é maior que zero
                       busca as informações do nome do primeiro titular da conta de conjuge*/
                    IF crapcje.nrctacje > 0 THEN
                    DO:
                       FIND crapttl WHERE crapttl.cdcooper = crapcje.cdcooper
                                      AND crapttl.nrdconta = crapcje.nrctacje
                                      AND crapttl.idseqttl = 1
                                    NO-LOCK NO-ERROR.
                       /* Se possuir titular carrega o nome */
                       IF AVAIL crapttl THEN
                           ASSIGN aux_nmconjug = crapttl.nmextttl
                                  aux_nrcpfcjg = crapttl.nrcpfcgc
								  aux_nrcpfcjg = crapttl.nrcpfcgc
								  aux_nrctacjg = crapttl.nrdconta
                                  aux_vlrencjg = crapttl.vlsalari     + 
                                              crapttl.vldrendi[1]  + 
                                              crapttl.vldrendi[2]  +
                                              crapttl.vldrendi[3]  +
                                              crapttl.vldrendi[4]  +
                                              crapttl.vldrendi[5]  +
                                              crapttl.vldrendi[6].

                    END.
                    ELSE
                        /* Se o numero da conta não é maior que zero carrega o nome da crapcje */
                        ASSIGN aux_nmconjug = crapcje.nmconjug
                               aux_nrcpfcjg = crapcje.nrcpfcjg
							   aux_vlrencjg = crapcje.vlsalari
							   aux_nrctacjg = crapcje.nrctacje.
                END.
                         
                IF crapass.cdnacion > 0 THEN         
                DO:
                  /* Buscar nacionalidade */
                  FIND FIRST crapnac
                       WHERE crapnac.cdnacion = crapass.cdnacion
                       NO-LOCK NO-ERROR.
                END.          
                
                CREATE tt-dados-avais.
                ASSIGN aux_contador            = aux_contador + 1
                       tt-dados-avais.nrctaava = crapass.nrdconta
                       tt-dados-avais.nmdavali = crapass.nmprimtl
                       tt-dados-avais.nrcpfcgc = crapass.nrcpfcgc
                       tt-dados-avais.nrdocava = aux_nrdocava
                       tt-dados-avais.tpdocava = ""
                       tt-dados-avais.nmconjug = aux_nmconjug
                       tt-dados-avais.nrcpfcjg = aux_nrcpfcjg
                       tt-dados-avais.nrdoccjg = IF aux_cdgraupr = 1 THEN 
                                                    "C.P.F. " +
                                                    STRING(STRING(aux_nrcpfcgc,
                                                    "99999999999"),"xxx.xxx.xxx-xx")
                                                 ELSE 
                                                    ""
                       tt-dados-avais.tpdoccjg = ""
                       tt-dados-avais.nrfonres = STRING(craptfc.nrdddtfc) +
                                                 STRING(craptfc.nrtelefo)
                                                 WHEN AVAIL craptfc
                       tt-dados-avais.dsdemail = crapcem.dsdemail
                                                      WHEN AVAIL crapcem
                       tt-dados-avais.dsendre1 = TRIM(crapenc.dsendere)
                       tt-dados-avais.dsendre2 = TRIM(crapenc.nmbairro)
                       tt-dados-avais.nmcidade = TRIM(crapenc.nmcidade)
                       tt-dados-avais.cdufresd = TRIM(crapenc.cdufende)
                       tt-dados-avais.nrcepend = crapenc.nrcepend
                       tt-dados-avais.cdnacion = crapass.cdnacion
                       tt-dados-avais.dsnacion = crapnac.dsnacion
                                                 WHEN AVAIL crapnac
                       tt-dados-avais.vledvmto = aux_vledvmto
                       tt-dados-avais.vlrenmes = aux_vlrenmes
                       tt-dados-avais.idavalis = aux_contador
                       tt-dados-avais.nrendere = crapenc.nrendere
                       tt-dados-avais.complend = crapenc.complend
                       tt-dados-avais.nrcxapst = crapenc.nrcxapst
                       tt-dados-avais.inpessoa = crapass.inpessoa
                       tt-dados-avais.dtnascto = crapass.dtnasctl
					   tt-dados-avais.vlrencjg = aux_vlrencjg
					   tt-dados-avais.nrctacjg = aux_nrctacjg.

            END.


    END.
    ELSE
    IF  par_tpctrato = 4  THEN /* CARTAO CRED */
    DO:
        FIND crawcrd WHERE crawcrd.cdcooper = par_cdcooper AND
                           crawcrd.nrdconta = par_nrdconta AND
                           crawcrd.nrctrcrd = par_nrctrato
                           NO-LOCK NO-ERROR.

        IF  NOT AVAIL crawcrd  THEN
        DO:
            /* Se nao encontrar crawcrd, tratar craphcj */
            FIND craphcj WHERE craphcj.cdcooper = par_cdcooper AND
                               craphcj.nrdconta = par_nrdconta AND
                               craphcj.nrctrhcj = par_nrctrato
                               NO-LOCK NO-ERROR.
            IF  AVAIL craphcj  THEN
            DO:
                IF  craphcj.nrctaav1 > 0  THEN
                    DO:
                        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                           crapass.nrdconta = craphcj.nrctaav1
                                           NO-LOCK NO-ERROR.

                        IF  NOT AVAILABLE crapass THEN
                            DO:
                                ASSIGN aux_cdcritic = 9
                                       aux_dscritic = "".

                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,            /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).

                                RETURN "NOK".
                            END.

                        FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper     AND
                                           crapenc.nrdconta = crapass.nrdconta AND
                                           crapenc.idseqttl = 1
                                           NO-LOCK NO-ERROR.

                        IF  NOT AVAILABLE crapenc THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Endereco nao cadastrado.".

                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,            /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).

                                RETURN "NOK".
                            END.

                        IF  crapass.inpessoa = 1  THEN
                            ASSIGN aux_nrdocava = "C.P.F. " +
                                                  STRING(STRING(crapass.nrcpfcgc,
                                                  "99999999999"),"xxx.xxx.xxx-xx").
                        ELSE
                            ASSIGN aux_nrdocava = "CNPJ " +
                                                  STRING(STRING(crapass.nrcpfcgc,
                                                  "99999999999999"),"xx.xxx.xxx/xxxx-xx").
                        ASSIGN aux_cdgraupr = 0
                               aux_vlrenmes = 0
							   aux_nrcpfcgc = 0.

                        IF   crapass.inpessoa = 1 THEN
                             DO:
                                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                                   crapttl.nrdconta = crapass.nrdconta AND
                                                   crapttl.idseqttl = 2 
                                                   NO-LOCK NO-ERROR.

                                IF   AVAIL crapttl THEN 
                                     ASSIGN aux_cdgraupr = crapttl.cdgraupr
									        aux_nrcpfcgc = crapttl.nrcpfcgc.

                                FIND crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                                   crapttl.nrdconta = crapass.nrdconta AND
                                                   crapttl.idseqttl = 1 
                                                   NO-LOCK NO-ERROR.

                                IF   AVAIL crapttl THEN
                                     aux_vlrenmes = crapttl.vlsalari     + 
                                                    crapttl.vldrendi[1]  + 
                                                    crapttl.vldrendi[2]  +
                                                    crapttl.vldrendi[3]  +
                                                    crapttl.vldrendi[4]  +
                                                    crapttl.vldrendi[5]  +
                                                    crapttl.vldrendi[6]. 
                             END.

                        ASSIGN aux_vledvmto = 0. 

                        /* endevidamento do aval cooperado */
                        FOR EACH crapsdv WHERE crapsdv.cdcooper = par_cdcooper       AND
                                               crapsdv.nrdconta = crapass.nrdconta   AND
                                               CAN-DO("1,2,3,6",STRING(crapsdv.tpdsaldo))
                                               NO-LOCK:

                            ASSIGN aux_vledvmto = aux_vledvmto + crapsdv.vldsaldo. 

                        END. 

                        FIND FIRST crapcem WHERE 
                                   crapcem.cdcooper = par_cdcooper     AND
                                   crapcem.nrdconta = crapass.nrdconta AND
                                   crapcem.idseqttl = 1 
                                   NO-LOCK NO-ERROR.

                        FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                                  WHERE craptfc.cdcooper = par_cdcooper     AND
                                        craptfc.nrdconta = crapass.nrdconta AND
                                        craptfc.idseqttl = 1 
                                  NO-LOCK:
                        END.
                        
                        /* Limpar nome do conjuge */
                        ASSIGN aux_nmconjug = ""
                               aux_nrcpfcjg = 0
							   aux_nrctacjg = 0
							   aux_vlrencjg = 0.

                        FIND  crapcje WHERE crapcje.cdcooper = par_cdcooper AND 
                                            crapcje.nrdconta = crapass.nrdconta AND 
                                            crapcje.idseqttl = 1 USE-INDEX crapcje1 NO-ERROR.
                        
                        IF AVAIL crapcje THEN
                        DO:
                            /* Validar se o numero da conta do conjuge é maior que zero
                               busca as informações do nome do primeiro titular da conta de conjuge*/
                            IF crapcje.nrctacje > 0 THEN
                            DO:
                               FIND crapttl WHERE crapttl.cdcooper = crapcje.cdcooper
                                              AND crapttl.nrdconta = crapcje.nrctacje
                                              AND crapttl.idseqttl = 1
                                            NO-LOCK NO-ERROR.
                               /* Se possuir titular carrega o nome */
                               IF AVAIL crapttl THEN
                                   ASSIGN aux_nmconjug = crapttl.nmextttl
                                          aux_nrcpfcjg = crapttl.nrcpfcgc
										  aux_nrctacjg = crapttl.nrdconta
                                          aux_vlrencjg = crapttl.vlsalari     + 
                                              crapttl.vldrendi[1]  + 
                                              crapttl.vldrendi[2]  +
                                              crapttl.vldrendi[3]  +
                                              crapttl.vldrendi[4]  +
                                              crapttl.vldrendi[5]  +
                                              crapttl.vldrendi[6].										  
        
                            END.
                            ELSE
                                /* Se o numero da conta não é maior que zero carrega o nome da crapcje */
                                ASSIGN aux_nmconjug = crapcje.nmconjug
                                       aux_nrcpfcjg = crapcje.nrcpfcjg
									   aux_nrctacjg = crapcje.nrctacje
									   aux_vlrencjg = crapcje.vlsalari.
                        END.
                                  
                        IF crapass.cdnacion > 0 THEN
                        DO:
                          /* Buscar nacionalidade */
                          FIND FIRST crapnac
                               WHERE crapnac.cdnacion = crapass.cdnacion
                               NO-LOCK NO-ERROR.                               
                        END.  
                        
                        CREATE tt-dados-avais.
                        ASSIGN aux_contador            = aux_contador + 1
                               tt-dados-avais.nrctaava = crapass.nrdconta
                               tt-dados-avais.nmdavali = crapass.nmprimtl
                               tt-dados-avais.nrcpfcgc = crapass.nrcpfcgc
                               tt-dados-avais.nrdocava = aux_nrdocava
                               tt-dados-avais.tpdocava = ""
                               tt-dados-avais.nmconjug = aux_nmconjug
                               tt-dados-avais.nrcpfcjg = aux_nrcpfcjg
                               tt-dados-avais.nrdoccjg = IF aux_cdgraupr = 1 THEN 
                                                            "C.P.F. " +
                                                            STRING(STRING(aux_nrcpfcgc,
                                                            "99999999999"),"xxx.xxx.xxx-xx")
                                                         ELSE 
                                                            ""
                               tt-dados-avais.tpdoccjg = ""
                               tt-dados-avais.nrfonres = STRING(craptfc.nrdddtfc) +
                                                         STRING(craptfc.nrtelefo)
                                                         WHEN AVAIL craptfc
                               tt-dados-avais.dsdemail = crapcem.dsdemail
                                                           WHEN AVAIL crapcem        
                               tt-dados-avais.dsendre1 = TRIM(crapenc.dsendere)
                               tt-dados-avais.dsendre2 = TRIM(crapenc.nmbairro)
                               tt-dados-avais.nmcidade = TRIM(crapenc.nmcidade)
                               tt-dados-avais.cdufresd = TRIM(crapenc.cdufende)
                               tt-dados-avais.nrcepend = crapenc.nrcepend
                               tt-dados-avais.cdnacion = crapass.cdnacion
                               tt-dados-avais.dsnacion = crapnac.dsnacion
                                                           WHEN AVAIL crapnac        
                               tt-dados-avais.vledvmto = aux_vledvmto
                               tt-dados-avais.vlrenmes = aux_vlrenmes
                               tt-dados-avais.idavalis = aux_contador
                               tt-dados-avais.nrendere = crapenc.nrendere
                               tt-dados-avais.complend = crapenc.complend
                               tt-dados-avais.nrcxapst = crapenc.nrcxapst
							   tt-dados-avais.vlrencjg = aux_vlrencjg
							   tt-dados-avais.nrctacjg = aux_nrctacjg.

                    END.
      
                FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND 
                                       crapavt.tpctrato = par_tpctrato AND 
                                       crapavt.nrdconta = par_nrdconta AND
                                       crapavt.nrctremp = par_nrctrato NO-LOCK BY ROWID(crapavt):
                    
                    IF crapavt.cdnacion > 0 THEN
                    DO:
                      /* Buscar nacionalidade */
                      FIND FIRST crapnac
                           WHERE crapnac.cdnacion = crapavt.cdnacion
                           NO-LOCK NO-ERROR.
                    END.

                    CREATE tt-dados-avais.
                    ASSIGN aux_contador            = aux_contador + 1
                           tt-dados-avais.nrctaava = 0
                           tt-dados-avais.nmdavali = crapavt.nmdavali 
                           tt-dados-avais.nrcpfcgc = crapavt.nrcpfcgc
                           tt-dados-avais.tpdocava = crapavt.tpdocava
                           tt-dados-avais.nrdocava = crapavt.nrdocava
                           tt-dados-avais.nmconjug = crapavt.nmconjug
                           tt-dados-avais.nrcpfcjg = crapavt.nrcpfcjg
                           tt-dados-avais.tpdoccjg = crapavt.tpdoccjg 
                           tt-dados-avais.nrdoccjg = IF crapavt.nrcpfcjg > 0 THEN 
                                                        "C.P.F. " +
                                                        STRING(STRING(crapavt.nrcpfcjg,
                                                        "99999999999"),"xxx.xxx.xxx-xx")
                                                     ELSE 
                                                        crapavt.nrdoccjg
                           tt-dados-avais.dsendre1 = crapavt.dsendres[1]
                           tt-dados-avais.dsendre2 = crapavt.dsendres[2]
                           tt-dados-avais.nrfonres = crapavt.nrfonres
                           tt-dados-avais.dsdemail = crapavt.dsdemail
                           tt-dados-avais.nmcidade = crapavt.nmcidade
                           tt-dados-avais.cdufresd = crapavt.cdufresd
                           tt-dados-avais.nrcepend = crapavt.nrcepend
                           tt-dados-avais.cdnacion = crapavt.cdnacion
                           tt-dados-avais.dsnacion = crapnac.dsnacion
                                                     WHEN AVAIL crapnac  
                           tt-dados-avais.vledvmto = crapavt.vledvmto
                           tt-dados-avais.vlrenmes = crapavt.vlrenmes
                           tt-dados-avais.idavalis = aux_contador
                           tt-dados-avais.nrendere = crapavt.nrendere
                           tt-dados-avais.complend = crapavt.complend
                           tt-dados-avais.nrcxapst = crapavt.nrcxapst
						   tt-dados-avais.vlrencjg = crapavt.vlrencjg
						   tt-dados-avais.nrctacjg = 0.

                END. /** Fim do FOR EACH crapavt **/

                IF  craphcj.nrctaav2 > 0  THEN
                    DO:
                        FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                           crapass.nrdconta = craphcj.nrctaav2
                                           NO-LOCK NO-ERROR.

                        IF  NOT AVAILABLE crapass THEN
                            DO:
                                ASSIGN aux_cdcritic = 9
                                       aux_dscritic = "".

                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,            /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).

                                RETURN "NOK".
                            END.

                        FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper     AND
                                           crapenc.nrdconta = crapass.nrdconta AND
                                           crapenc.idseqttl = 1
                                           NO-LOCK NO-ERROR.

                        IF  NOT AVAILABLE crapenc THEN
                            DO:
                                ASSIGN aux_cdcritic = 0
                                       aux_dscritic = "Endereco nao cadastrado.".

                                RUN gera_erro (INPUT par_cdcooper,
                                               INPUT par_cdagenci,
                                               INPUT par_nrdcaixa,
                                               INPUT 1,            /** Sequencia **/
                                               INPUT aux_cdcritic,
                                               INPUT-OUTPUT aux_dscritic).

                                RETURN "NOK".
                            END.

                        ASSIGN aux_vledvmto = 0. 

                        /* endevidamento do aval cooperado */
                        FOR EACH crapsdv WHERE crapsdv.cdcooper = par_cdcooper       AND
                                               crapsdv.nrdconta = crapass.nrdconta   AND
                                               CAN-DO("1,2,3,6",STRING(crapsdv.tpdsaldo))
                                               NO-LOCK:

                            ASSIGN aux_vledvmto = aux_vledvmto + crapsdv.vldsaldo. 

                        END. 

                        ASSIGN aux_cdgraupr = 0
							   aux_vlrenmes = 0
							   aux_nrcpfcgc = 0.

                        IF  crapass.inpessoa = 1  THEN
						   DO:
                            ASSIGN aux_nrdocava = "C.P.F. " +
                                                  STRING(STRING(crapass.nrcpfcgc,
                                                  "99999999999"),"xxx.xxx.xxx-xx").

							  FIND crapttl WHERE crapttl.cdcooper = crapass.cdcooper AND
												 crapttl.nrdconta = crapass.nrdconta AND
												 crapttl.idseqttl = 2 
												 NO-LOCK NO-ERROR.

							  IF AVAIL crapttl THEN 
								 ASSIGN aux_cdgraupr = crapttl.cdgraupr
										aux_nrcpfcgc = crapttl.nrcpfcgc.

                        FIND crapttl WHERE crapttl.cdcooper = crapass.cdcooper  AND
                                           crapttl.nrdconta = crapass.nrdconta  AND
                                           crapttl.idseqttl = 1
                                           NO-LOCK NO-ERROR.

                        IF   AVAIL crapttl    THEN
                             ASSIGN aux_vlrenmes = crapttl.vlsalari     + 
                                                   crapttl.vldrendi[1]  + 
                                                   crapttl.vldrendi[2]  +
                                                   crapttl.vldrendi[3]  +
                                                   crapttl.vldrendi[4]  +
                                                   crapttl.vldrendi[5]  +
                                                   crapttl.vldrendi[6]. 

						   END.
						ELSE
			  			   ASSIGN aux_nrdocava = "CNPJ " +
												  STRING(STRING(crapass.nrcpfcgc,
												  "99999999999999"),"xx.xxx.xxx/xxxx-xx").	


                        FIND FIRST crapcem WHERE
                                   crapcem.cdcooper = par_cdcooper     AND
                                   crapcem.nrdconta = crapass.nrdconta AND
                                   crapcem.idseqttl = 1 
                                   NO-LOCK NO-ERROR.

                        FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                                  WHERE craptfc.cdcooper = par_cdcooper     AND
                                        craptfc.nrdconta = crapass.nrdconta AND
                                        craptfc.idseqttl = 1 
                                  NO-LOCK:
                        END.
                        
                        /* Limpar nome do conjuge */
                        ASSIGN aux_nmconjug = ""
                               aux_nrcpfcjg = 0
							   aux_nrctacjg = 0
							   aux_vlrencjg = 0.

                        FIND  crapcje WHERE crapcje.cdcooper = par_cdcooper AND 
                                            crapcje.nrdconta = crapass.nrdconta AND 
                                            crapcje.idseqttl = 1 USE-INDEX crapcje1 NO-ERROR.
                        
                        IF AVAIL crapcje THEN
                        DO:
                            /* Validar se o numero da conta do conjuge é maior que zero
                               busca as informações do nome do primeiro titular da conta de conjuge*/
                            IF crapcje.nrctacje > 0 THEN
                            DO:
                               FIND crapttl WHERE crapttl.cdcooper = crapcje.cdcooper
                                              AND crapttl.nrdconta = crapcje.nrctacje
                                              AND crapttl.idseqttl = 1
                                            NO-LOCK NO-ERROR.
                               /* Se possuir titular carrega o nome */
                               IF AVAIL crapttl THEN
                                   ASSIGN aux_nmconjug = crapttl.nmextttl
                                          aux_nrcpfcjg = crapttl.nrcpfcgc
										  aux_nrctacjg = crapttl.nrdconta
                                          aux_vlrencjg = crapttl.vlsalari     + 
                                              crapttl.vldrendi[1]  + 
                                              crapttl.vldrendi[2]  +
                                              crapttl.vldrendi[3]  +
                                              crapttl.vldrendi[4]  +
                                              crapttl.vldrendi[5]  +
                                              crapttl.vldrendi[6].										  
        
                            END.
                            ELSE
                                /* Se o numero da conta não é maior que zero carrega o nome da crapcje */
                                ASSIGN aux_nmconjug = crapcje.nmconjug
                                       aux_nrcpfcjg = crapcje.nrcpfcjg
									   aux_nrctacjg = crapcje.nrctacje
									   aux_vlrencjg = crapcje.vlsalari.
                        END.
                                  
                        IF crapavt.cdnacion > 0 THEN
                        DO:
                          /* Buscar nacionalidade */
                          FIND FIRST crapnac
                               WHERE crapnac.cdnacion = crapavt.cdnacion
                               NO-LOCK NO-ERROR.
                               
                        END.
   
                        CREATE tt-dados-avais.
                        ASSIGN aux_contador            = aux_contador + 1
                               tt-dados-avais.nrctaava = crapass.nrdconta
                               tt-dados-avais.nmdavali = crapass.nmprimtl
                               tt-dados-avais.nrcpfcgc = crapass.nrcpfcgc
                               tt-dados-avais.nrdocava = aux_nrdocava
                               tt-dados-avais.tpdocava = ""
                               tt-dados-avais.nmconjug = aux_nmconjug
                               tt-dados-avais.nrcpfcjg = aux_nrcpfcjg
                               tt-dados-avais.nrdoccjg = IF aux_cdgraupr = 1 THEN 
                                                            "C.P.F. " +
                                                            STRING(STRING(aux_nrcpfcgc,
                                                            "99999999999"),"xxx.xxx.xxx-xx")
                                                         ELSE 
                                                            ""
                               tt-dados-avais.tpdoccjg = ""
                               tt-dados-avais.nrfonres = STRING(craptfc.nrdddtfc) +
                                                         STRING(craptfc.nrtelefo)
                                                         WHEN AVAIL craptfc
                               tt-dados-avais.dsdemail = crapcem.dsdemail
                                                           WHEN AVAIL crapcem
                               tt-dados-avais.dsendre1 = TRIM(crapenc.dsendere)
                               tt-dados-avais.dsendre2 = TRIM(crapenc.nmbairro)
                               tt-dados-avais.nmcidade = TRIM(crapenc.nmcidade)
                               tt-dados-avais.cdufresd = TRIM(crapenc.cdufende)
                               tt-dados-avais.nrcepend = crapenc.nrcepend
                               tt-dados-avais.cdnacion = crapass.cdnacion
                               tt-dados-avais.dsnacion = crapnac.dsnacion 
                                                         WHEN AVAIL crapnac 
                               tt-dados-avais.vledvmto = aux_vledvmto
                               tt-dados-avais.vlrenmes = aux_vlrenmes
                               tt-dados-avais.idavalis = aux_contador
                               tt-dados-avais.nrendere = crapenc.nrendere
                               tt-dados-avais.complend = crapenc.complend
                               tt-dados-avais.nrcxapst = crapenc.nrcxapst
							   tt-dados-avais.vlrencjg = aux_vlrencjg
							   tt-dados-avais.nrctacjg = aux_nrctacjg.
                    END.

                RETURN "OK".
            END.
            ELSE
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Registro de cartao nao encontrado.".

                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                RETURN "NOK".
            END.
        END.
        
        IF  crawcrd.nrctaav1 > 0  THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = crawcrd.nrctaav1 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapass THEN
                    DO:
                        ASSIGN aux_cdcritic = 9
                               aux_dscritic = "".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        RETURN "NOK".
                    END.

                FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper     AND
                                   crapenc.nrdconta = crapass.nrdconta AND
                                   crapenc.idseqttl = 1
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapenc THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Endereco nao cadastrado.".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        RETURN "NOK".
                    END.

                IF  crapass.inpessoa = 1  THEN
                    ASSIGN aux_nrdocava = "C.P.F. " +
                                          STRING(STRING(crapass.nrcpfcgc,
                                          "99999999999"),"xxx.xxx.xxx-xx").
                ELSE
                    ASSIGN aux_nrdocava = "CNPJ " +
                                          STRING(STRING(crapass.nrcpfcgc,
                                          "99999999999999"),"xx.xxx.xxx/xxxx-xx").
                ASSIGN aux_cdgraupr = 0
                       aux_vlrenmes = 0
					   aux_nrcpfcgc = 0.

                IF   crapass.inpessoa = 1 THEN
                     DO:
                        FIND crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                           crapttl.nrdconta = crapass.nrdconta AND
                                           crapttl.idseqttl = 2 
                                           NO-LOCK NO-ERROR.

                        IF   AVAIL crapttl THEN 
                             ASSIGN aux_cdgraupr = crapttl.cdgraupr
							        aux_nrcpfcgc = crapttl.nrcpfcgc.

                        FIND crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                           crapttl.nrdconta = crapass.nrdconta AND
                                           crapttl.idseqttl = 1 
                                           NO-LOCK NO-ERROR.

                        IF   AVAIL crapttl THEN
                             aux_vlrenmes = crapttl.vlsalari     + 
                                            crapttl.vldrendi[1]  + 
                                            crapttl.vldrendi[2]  +
                                            crapttl.vldrendi[3]  +
                                            crapttl.vldrendi[4]  +
                                            crapttl.vldrendi[5]  +
                                            crapttl.vldrendi[6]. 
                     END.

                ASSIGN aux_vledvmto = 0. 

                /* endevidamento do aval cooperado */
                FOR EACH crapsdv WHERE crapsdv.cdcooper = par_cdcooper       AND
                                       crapsdv.nrdconta = crapass.nrdconta   AND
                                       CAN-DO("1,2,3,6",STRING(crapsdv.tpdsaldo))
                                       NO-LOCK:

                    ASSIGN aux_vledvmto = aux_vledvmto + crapsdv.vldsaldo. 

                END. 

                FIND FIRST crapcem WHERE
                           crapcem.cdcooper = par_cdcooper     AND
                           crapcem.nrdconta = crapass.nrdconta AND
                           crapcem.idseqttl = 1 
                           NO-LOCK NO-ERROR.

                FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                                  WHERE craptfc.cdcooper = par_cdcooper     AND
                                        craptfc.nrdconta = crapass.nrdconta AND
                                        craptfc.idseqttl = 1 
                                  NO-LOCK:
                END.
                                
                /* Limpar nome do conjuge */
                ASSIGN aux_nmconjug = ""
                       aux_nrcpfcjg = 0
					   aux_nrctacjg = 0
					   aux_vlrencjg = 0.

                FIND  crapcje WHERE crapcje.cdcooper = par_cdcooper AND 
                                    crapcje.nrdconta = crapass.nrdconta AND 
                                    crapcje.idseqttl = 1 USE-INDEX crapcje1 NO-ERROR.

                IF AVAIL crapcje THEN
                DO:
                    /* Validar se o numero da conta do conjuge é maior que zero
                       busca as informações do nome do primeiro titular da conta de conjuge*/
                    IF crapcje.nrctacje > 0 THEN
                    DO:
                       FIND crapttl WHERE crapttl.cdcooper = crapcje.cdcooper
                                      AND crapttl.nrdconta = crapcje.nrctacje
                                      AND crapttl.idseqttl = 1
                                    NO-LOCK NO-ERROR.
                       /* Se possuir titular carrega o nome */
                       IF AVAIL crapttl THEN
                           ASSIGN aux_nmconjug = crapttl.nmextttl
                                  aux_nrcpfcjg = crapttl.nrcpfcgc
								  aux_nrctacjg = crapttl.nrdconta
								  aux_vlrencjg = crapttl.vlsalari     + 
                                              crapttl.vldrendi[1]  + 
                                              crapttl.vldrendi[2]  +
                                              crapttl.vldrendi[3]  +
                                              crapttl.vldrendi[4]  +
                                              crapttl.vldrendi[5]  +
                                              crapttl.vldrendi[6].

                    END.
                    ELSE
                        /* Se o numero da conta não é maior que zero carrega o nome da crapcje */
                        ASSIGN aux_nmconjug = crapcje.nmconjug
                               aux_nrcpfcjg = crapcje.nrcpfcjg
							   aux_nrctacjg = crapcje.nrctacje
							   aux_vlrencjg = crapcje.vlsalari.
                END.
                                
                IF crapass.cdnacion > 0 THEN
                DO:
                  /* Buscar nacionalidade */
                  FIND FIRST crapnac
                       WHERE crapnac.cdnacion = crapass.cdnacion
                       NO-LOCK NO-ERROR.
                END.

                CREATE tt-dados-avais.
                ASSIGN aux_contador            = aux_contador + 1
                       tt-dados-avais.nrctaava = crapass.nrdconta
                       tt-dados-avais.nmdavali = crapass.nmprimtl
                       tt-dados-avais.nrcpfcgc = crapass.nrcpfcgc
                       tt-dados-avais.nrdocava = aux_nrdocava
                       tt-dados-avais.tpdocava = ""
                       tt-dados-avais.nmconjug = aux_nmconjug
                       tt-dados-avais.nrcpfcjg = aux_nrcpfcjg
                       tt-dados-avais.nrdoccjg = IF aux_cdgraupr = 1 THEN 
                                                    "C.P.F. " +
                                                    STRING(STRING(aux_nrcpfcgc,
                                                    "99999999999"),"xxx.xxx.xxx-xx")
                                                 ELSE 
                                                    ""
                       tt-dados-avais.tpdoccjg = ""
                       tt-dados-avais.nrfonres = STRING(craptfc.nrdddtfc) +
                                                 STRING(craptfc.nrtelefo)
                                                 WHEN AVAIL craptfc
                       tt-dados-avais.dsdemail = crapcem.dsdemail
                                                 WHEN AVAIL crapcem              
                       tt-dados-avais.dsendre1 = TRIM(crapenc.dsendere)
                       tt-dados-avais.dsendre2 = TRIM(crapenc.nmbairro)
                       tt-dados-avais.nmcidade = TRIM(crapenc.nmcidade)
                       tt-dados-avais.cdufresd = TRIM(crapenc.cdufende)
                       tt-dados-avais.nrcepend = crapenc.nrcepend
                       tt-dados-avais.cdnacion = crapass.cdnacion
                       tt-dados-avais.dsnacion = crapnac.dsnacion
                                                 WHEN AVAIL crapnac                
                       tt-dados-avais.vledvmto = aux_vledvmto
                       tt-dados-avais.vlrenmes = aux_vlrenmes
                       tt-dados-avais.idavalis = aux_contador
                       tt-dados-avais.nrendere = crapenc.nrendere
                       tt-dados-avais.complend = crapenc.complend
                       tt-dados-avais.nrcxapst = crapenc.nrcxapst
					   tt-dados-avais.vlrencjg = aux_vlrencjg
					   tt-dados-avais.nrctacjg = aux_nrctacjg.

            END.
     
        FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper AND 
                               crapavt.tpctrato = par_tpctrato AND 
                               crapavt.nrdconta = par_nrdconta AND
                               crapavt.nrctremp = par_nrctrato NO-LOCK BY ROWID(crapavt):
            
            IF crapavt.cdnacion > 0 THEN
            DO:
              /* Buscar nacionalidade */
              FIND FIRST crapnac
                   WHERE crapnac.cdnacion = crapavt.cdnacion
                   NO-LOCK NO-ERROR.            
            END. 
            
            CREATE tt-dados-avais.
            ASSIGN aux_contador            = aux_contador + 1
                   tt-dados-avais.nrctaava = 0
                   tt-dados-avais.nmdavali = crapavt.nmdavali 
                   tt-dados-avais.nrcpfcgc = crapavt.nrcpfcgc
                   tt-dados-avais.tpdocava = crapavt.tpdocava
                   tt-dados-avais.nrdocava = crapavt.nrdocava
                   tt-dados-avais.nmconjug = crapavt.nmconjug
                   tt-dados-avais.nrcpfcjg = crapavt.nrcpfcjg
                   tt-dados-avais.tpdoccjg = crapavt.tpdoccjg 
                   tt-dados-avais.nrdoccjg = IF crapavt.nrcpfcjg > 0 THEN 
                                                "C.P.F. " +
                                                STRING(STRING(crapavt.nrcpfcjg,
                                                "99999999999"),"xxx.xxx.xxx-xx")
                                             ELSE 
                                                crapavt.nrdoccjg
                   tt-dados-avais.dsendre1 = crapavt.dsendres[1]
                   tt-dados-avais.dsendre2 = crapavt.dsendres[2]
                   tt-dados-avais.nrfonres = crapavt.nrfonres
                   tt-dados-avais.dsdemail = crapavt.dsdemail
                   tt-dados-avais.nmcidade = crapavt.nmcidade
                   tt-dados-avais.cdufresd = crapavt.cdufresd
                   tt-dados-avais.nrcepend = crapavt.nrcepend
                   tt-dados-avais.cdnacion = crapavt.cdnacion
                   tt-dados-avais.dsnacion = crapnac.dsnacion
                                             WHEN avail crapnac
                   tt-dados-avais.vledvmto = crapavt.vledvmto
                   tt-dados-avais.vlrenmes = crapavt.vlrenmes
                   tt-dados-avais.idavalis = aux_contador
                   tt-dados-avais.nrendere = crapavt.nrendere
                   tt-dados-avais.complend = crapavt.complend
                   tt-dados-avais.nrcxapst = crapavt.nrcxapst
				   tt-dados-avais.vlrencjg = crapavt.vlrencjg
				   tt-dados-avais.nrctacjg = 0.

        END. /** Fim do FOR EACH crapavt **/
        
        IF  crawcrd.nrctaav2 > 0  THEN
            DO:
                FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                   crapass.nrdconta = crawcrd.nrctaav2 
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapass THEN
                    DO:
                        ASSIGN aux_cdcritic = 9
                               aux_dscritic = "".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        RETURN "NOK".
                    END.

                FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper     AND
                                   crapenc.nrdconta = crapass.nrdconta AND
                                   crapenc.idseqttl = 1
                                   NO-LOCK NO-ERROR.

                IF  NOT AVAILABLE crapenc THEN
                    DO:
                        ASSIGN aux_cdcritic = 0
                               aux_dscritic = "Endereco nao cadastrado.".

                        RUN gera_erro (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT 1,            /** Sequencia **/
                                       INPUT aux_cdcritic,
                                       INPUT-OUTPUT aux_dscritic).

                        RETURN "NOK".
                    END.

                ASSIGN aux_vledvmto = 0. 

                /* endevidamento do aval cooperado */
                FOR EACH crapsdv WHERE crapsdv.cdcooper = par_cdcooper       AND
                                       crapsdv.nrdconta = crapass.nrdconta   AND
                                       CAN-DO("1,2,3,6",STRING(crapsdv.tpdsaldo))
                                       NO-LOCK:

                    ASSIGN aux_vledvmto = aux_vledvmto + crapsdv.vldsaldo. 

                END. 

                ASSIGN aux_cdgraupr = 0
                       aux_vlrenmes = 0
					   aux_nrcpfcgc = 0.

                IF  crapass.inpessoa = 1  THEN
                   DO:
                    ASSIGN aux_nrdocava = "C.P.F. " +
                                          STRING(STRING(crapass.nrcpfcgc,
                                          "99999999999"),"xxx.xxx.xxx-xx").

                      FIND crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                         crapttl.nrdconta = crapass.nrdconta AND
                                         crapttl.idseqttl = 2 
                                         NO-LOCK NO-ERROR.

                      IF AVAIL crapttl THEN 
                         ASSIGN aux_cdgraupr = crapttl.cdgraupr
						        aux_nrcpfcgc = crapttl.nrcpfcgc.
                
                      FIND crapttl WHERE crapttl.cdcooper = par_cdcooper     AND
                                   crapttl.nrdconta = crapass.nrdconta AND
                                   crapttl.idseqttl = 1 
                                   NO-LOCK NO-ERROR.

                IF   AVAIL crapttl THEN
                     aux_vlrenmes = crapttl.vlsalari     + 
                                    crapttl.vldrendi[1]  + 
                                    crapttl.vldrendi[2]  +
                                    crapttl.vldrendi[3]  +
                                    crapttl.vldrendi[4]  +
                                    crapttl.vldrendi[5]  +
                                    crapttl.vldrendi[6]. 
                   END.
				ELSE
				   ASSIGN aux_nrdocava = "CNPJ " +
                                          STRING(STRING(crapass.nrcpfcgc,
                                          "99999999999999"),"xx.xxx.xxx/xxxx-xx").

                FIND FIRST crapcem WHERE
                           crapcem.cdcooper = par_cdcooper     AND
                           crapcem.nrdconta = crapass.nrdconta AND
                           crapcem.idseqttl = 1 
                           NO-LOCK NO-ERROR.

                FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                                  WHERE craptfc.cdcooper = par_cdcooper     AND
                                        craptfc.nrdconta = crapass.nrdconta AND
                                        craptfc.idseqttl = 1 
                                  NO-LOCK:
                END.
                
                
                /* Limpar nome do conjuge */
                ASSIGN aux_nmconjug = ""
                       aux_nrcpfcjg = 0
					   aux_nrctacjg = 0
					   aux_vlrencjg = 0.

                FIND  crapcje WHERE crapcje.cdcooper = par_cdcooper AND 
                                    crapcje.nrdconta = crapass.nrdconta AND 
                                    crapcje.idseqttl = 1 USE-INDEX crapcje1 NO-ERROR.

                IF AVAIL crapcje THEN
                DO:
                    /* Validar se o numero da conta do conjuge é maior que zero
                       busca as informações do nome do primeiro titular da conta de conjuge*/
                    IF crapcje.nrctacje > 0 THEN
                    DO:
                       FIND crapttl WHERE crapttl.cdcooper = crapcje.cdcooper
                                      AND crapttl.nrdconta = crapcje.nrctacje
                                      AND crapttl.idseqttl = 1
                                    NO-LOCK NO-ERROR.
                       /* Se possuir titular carrega o nome */
                       IF AVAIL crapttl THEN
                           ASSIGN aux_nmconjug = crapttl.nmextttl
                                  aux_nrcpfcjg = crapttl.nrcpfcgc
								  aux_nrctacjg = crapttl.nrdconta
                                  aux_vlrencjg = crapttl.vlsalari     + 
                                              crapttl.vldrendi[1]  + 
                                              crapttl.vldrendi[2]  +
                                              crapttl.vldrendi[3]  +
                                              crapttl.vldrendi[4]  +
                                              crapttl.vldrendi[5]  +
                                              crapttl.vldrendi[6].								  

                    END.
                    ELSE
                        /* Se o numero da conta não é maior que zero carrega o nome da crapcje */
                        ASSIGN aux_nmconjug = crapcje.nmconjug
                               aux_nrcpfcjg = crapcje.nrcpfcjg
							   aux_nrctacjg = crapcje.nrctacje
							   aux_vlrencjg = crapcje.vlsalari.
                END.

                /* Buscar nacionalidade */
                IF  crapass.cdnacion > 0 THEN
                DO:
                  FIND FIRST crapnac
                       WHERE crapnac.cdnacion = crapass.cdnacion
                     NO-LOCK NO-ERROR.
                END.
                
                CREATE tt-dados-avais.
                ASSIGN aux_contador            = aux_contador + 1
                       tt-dados-avais.nrctaava = crapass.nrdconta
                       tt-dados-avais.nmdavali = crapass.nmprimtl
                       tt-dados-avais.nrcpfcgc = crapass.nrcpfcgc
                       tt-dados-avais.nrdocava = aux_nrdocava
                       tt-dados-avais.tpdocava = ""
                       tt-dados-avais.nmconjug = aux_nmconjug
                       tt-dados-avais.nrcpfcjg = aux_nrcpfcjg
                       tt-dados-avais.nrdoccjg = IF aux_cdgraupr = 1 THEN 
                                                    "C.P.F. " +
                                                    STRING(STRING(aux_nrcpfcgc,
                                                    "99999999999"),"xxx.xxx.xxx-xx")
                                                 ELSE 
                                                    ""
                       tt-dados-avais.tpdoccjg = ""
                       tt-dados-avais.nrfonres = STRING(craptfc.nrdddtfc) +
                                                 STRING(craptfc.nrtelefo)
                                                 WHEN AVAIL craptfc
                       tt-dados-avais.dsdemail = crapcem.dsdemail
                                                    WHEN AVAIL crapcem
                       tt-dados-avais.dsendre1 = TRIM(crapenc.dsendere)
                       tt-dados-avais.dsendre2 = TRIM(crapenc.nmbairro)
                       tt-dados-avais.nmcidade = TRIM(crapenc.nmcidade)
                       tt-dados-avais.cdufresd = TRIM(crapenc.cdufende)
                       tt-dados-avais.nrcepend = crapenc.nrcepend
                       tt-dados-avais.cdnacion = crapass.cdnacion
                       tt-dados-avais.dsnacion = crapnac.dsnacion
                                                 WHEN AVAIL crapnac
                       tt-dados-avais.vledvmto = aux_vledvmto
                       tt-dados-avais.vlrenmes = aux_vlrenmes
                       tt-dados-avais.idavalis = aux_contador
                       tt-dados-avais.nrendere = crapenc.nrendere
                       tt-dados-avais.complend = crapenc.complend
                       tt-dados-avais.nrcxapst = crapenc.nrcxapst
					   tt-dados-avais.vlrencjg = aux_vlrencjg
					   tt-dados-avais.nrctacjg = aux_nrctacjg.

            END.

    END.
    ELSE
    DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Tipo de contrato inexistente. Tipo " + 
                              STRING(par_nrctrato,"999").

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

PROCEDURE consulta-avalista:

    /**********************************************************************/
    /** Procedure para consultar dados do avalista informado             **/
    /** Baseado no programa fontes/limite_inp.p                          **/
    /**********************************************************************/

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctaava AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfcgc AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-dados-avais.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF VAR h-b1wgen0001 AS HANDLE                                  NO-UNDO.
    
    DEF VAR aux_nrdeanos AS INTE                                    NO-UNDO.
    DEF VAR aux_nrdmeses AS INTE                                    NO-UNDO.
     
    DEF VAR aux_nrdocava AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsdidade AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlrenmes AS DECI                                    NO-UNDO.
    DEF VAR aux_vledvmto AS DECI                                    NO-UNDO.
    DEF VAR aux_inhabmen LIKE crapttl.inhabmen                      NO-UNDO.
	DEF VAR aux_nrcpfcgc LIKE crapttl.nrcpfcgc				        NO-UNDO.
	DEF VAR aux_vlrencjg AS DECI                                    NO-UNDO.
	DEF VAR aux_nrctacjg AS INTE                                    NO-UNDO.
    
    DEF VAR aux_nmconjug AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrcpfcjg LIKE crapcje.nrcpfcjg                      NO-UNDO.
    DEF VAR aux_stsnrcal AS LOGICAL                                 NO-UNDO.
    DEF VAR avt_inpessoa AS INTEGER                                 NO-UNDO.
    DEF VAR aux_nmdavali AS CHAR                                    NO-UNDO.
	DEF VAR aux_vlmedfat AS DECI                                    NO-UNDO. /*PRJ438 - Sprint 5*/

    /* Variaveis para o XML */ 
    DEF VAR xDoc          AS HANDLE                                 NO-UNDO.   
    DEF VAR xRoot         AS HANDLE                                 NO-UNDO.  
    DEF VAR xRoot2        AS HANDLE                                 NO-UNDO.  
    DEF VAR xField        AS HANDLE                                 NO-UNDO. 
    DEF VAR xText         AS HANDLE                                 NO-UNDO. 
    DEF VAR aux_cont_raiz AS INTEGER                                NO-UNDO. 
    DEF VAR aux_cont      AS INTEGER                                NO-UNDO. 
    DEF VAR ponteiro_xml  AS MEMPTR                                 NO-UNDO. 
    DEF VAR xml_req       AS LONGCHAR                               NO-UNDO. 


    EMPTY TEMP-TABLE tt-dados-avais.
    EMPTY TEMP-TABLE tt-erro.
    
    IF  par_nrctaava > 0  THEN
        DO: 
            IF  par_nrctaava = par_nrdconta  THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Conta do avalista deve ser " +
                                          "diferente do CONTRATANTE.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    
                    RETURN "NOK".
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

            RUN ver_cadastro IN h-b1wgen0001 (INPUT par_cdcooper,
                                              INPUT par_nrctaava,
                                              INPUT par_cdagenci, 
                                              INPUT par_nrdcaixa,
                                              INPUT par_dtmvtolt,
                                              INPUT par_idorigem, 
                                             OUTPUT TABLE tt-erro).

            DELETE PROCEDURE h-b1wgen0001.
    
            IF  RETURN-VALUE = "NOK"  THEN
                RETURN "NOK".
                
            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND 
                               crapass.nrdconta = par_nrctaava NO-LOCK NO-ERROR.

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
                    RETURN "NOK".
                END.

            IF  crapass.inpessoa = 3  THEN
                DO:
                    ASSIGN aux_cdcritic = 808
                           aux_dscritic = "".
                   
                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".       
                END.
            ELSE
            IF  crapass.inpessoa = 1   THEN
                DO:
                    ASSIGN aux_inhabmen = 0.
                    
                    RUN idade (INPUT crapass.dtnasctl,
                               INPUT par_dtmvtolt, 
                              OUTPUT aux_nrdeanos,
                              OUTPUT aux_nrdmeses, 
                              OUTPUT aux_dsdidade).

                    IF  RETURN-VALUE = "NOK"  THEN
                        DO:
                            ASSIGN aux_cdcritic = 0
                                   aux_dscritic = aux_dsdidade.
                   
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,         /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                            RETURN "NOK".
                        END.
                    
                    FIND crapttl WHERE crapttl.cdcooper = crapass.cdcooper AND
                                       crapttl.nrdconta = crapass.nrdconta AND
                                       crapttl.idseqttl = 2 
                                       NO-LOCK NO-ERROR.

                    IF   AVAIL crapttl THEN 
                         ASSIGN aux_cdgraupr = crapttl.cdgraupr
						        aux_nrcpfcgc = crapttl.nrcpfcgc.

                    FIND crapttl WHERE crapttl.cdcooper = crapass.cdcooper AND
                                       crapttl.nrdconta = crapass.nrdconta AND
                                       crapttl.idseqttl = 1
                                       NO-LOCK NO-ERROR.
                    
                    IF  AVAIL crapttl  THEN
                        ASSIGN aux_inhabmen = crapttl.inhabmen
                               aux_vlrenmes = crapttl.vlsalari     + 
                                              crapttl.vldrendi[1]  + 
                                              crapttl.vldrendi[2]  +
                                              crapttl.vldrendi[3]  +
                                              crapttl.vldrendi[4]  +
                                              crapttl.vldrendi[5]  +
                                              crapttl.vldrendi[6]. 
                    
                    IF  aux_nrdeanos < 18 AND aux_inhabmen = 0  THEN
                        DO:
                            ASSIGN aux_cdcritic = 585
                                   aux_dscritic = "".
                   
                            RUN gera_erro (INPUT par_cdcooper,
                                           INPUT par_cdagenci,
                                           INPUT par_nrdcaixa,
                                           INPUT 1,         /** Sequencia **/
                                           INPUT aux_cdcritic,
                                           INPUT-OUTPUT aux_dscritic).
                            RETURN "NOK".
                        END.
                END.
			ELSE
			IF  crapass.inpessoa = 2 THEN /*PRJ438 - Sprint 5*/
                DO:
	
				    RUN calcula-faturamento (INPUT  par_cdcooper,
                                             INPUT  par_cdagenci,
                                             INPUT  par_nrdcaixa,
                                             INPUT  par_idorigem,
                                             INPUT  par_nrctaava, /*Conta avalista*/
                                             INPUT  par_dtmvtolt,
                                             OUTPUT aux_vlmedfat).
				     
					 ASSIGN aux_vlrenmes = aux_vlmedfat.
				END.
                
            FIND FIRST crapenc WHERE crapenc.cdcooper = par_cdcooper AND
                               crapenc.nrdconta = par_nrctaava AND
                               crapenc.idseqttl = 1
							   NO-LOCK NO-ERROR.
     
            IF  NOT AVAILABLE crapenc THEN
                DO:
                    ASSIGN aux_cdcritic = 0
                           aux_dscritic = "Endereco nao cadastrado.".

                    RUN gera_erro (INPUT par_cdcooper,
                                   INPUT par_cdagenci,
                                   INPUT par_nrdcaixa,
                                   INPUT 1,            /** Sequencia **/
                                   INPUT aux_cdcritic,
                                   INPUT-OUTPUT aux_dscritic).
                    RETURN "NOK".
                END.

            IF  crapass.inpessoa = 1  THEN
                ASSIGN aux_nrdocava = "C.P.F. " +
                                      STRING(STRING(crapass.nrcpfcgc,
                                      "99999999999"),"xxx.xxx.xxx-xx").
            ELSE
                ASSIGN aux_nrdocava = "CNPJ " +
                                      STRING(STRING(crapass.nrcpfcgc,
                                      "99999999999999"),"xx.xxx.xxx/xxxx-xx").

            /* endevidamento do aval cooperado */
            FOR EACH crapsdv WHERE crapsdv.cdcooper = par_cdcooper   AND
                                   crapsdv.nrdconta = par_nrctaava   AND
                                   CAN-DO("1,2,3,6",STRING(crapsdv.tpdsaldo))
                                   NO-LOCK:
            
                ASSIGN aux_vledvmto = aux_vledvmto + crapsdv.vldsaldo. 
                                     
            END. 

            FIND FIRST crapcem WHERE crapcem.cdcooper = par_cdcooper     AND
                                     crapcem.nrdconta = crapass.nrdconta AND
                                     crapcem.idseqttl = 1 
                                     NO-LOCK NO-ERROR.
            
            FOR FIRST craptfc FIELDS(nrdddtfc nrtelefo)
                                  WHERE craptfc.cdcooper = par_cdcooper     AND
                                        craptfc.nrdconta = crapass.nrdconta AND
                                        craptfc.idseqttl = 1 
                                  NO-LOCK:
            END.

            /* Limpar nome do conjuge */
            ASSIGN aux_nmconjug = ""
                   aux_nrcpfcjg = 0
				   aux_vlrencjg = 0
				   aux_nrctacjg = 0.

            FIND  crapcje WHERE crapcje.cdcooper = par_cdcooper AND 
                                crapcje.nrdconta = crapass.nrdconta AND 
                                crapcje.idseqttl = 1 USE-INDEX crapcje1 NO-ERROR.

            IF AVAIL crapcje THEN
            DO:
                /* Validar se o numero da conta do conjuge é maior que zero
                   busca as informações do nome do primeiro titular da conta de conjuge*/
                IF crapcje.nrctacje > 0 THEN
                DO:
                   FIND crapttl WHERE crapttl.cdcooper = crapcje.cdcooper
                                  AND crapttl.nrdconta = crapcje.nrctacje
                                  AND crapttl.idseqttl = 1
                                NO-LOCK NO-ERROR.
                   /* Se possuir titular carrega o nome */
                   IF AVAIL crapttl THEN
                       ASSIGN aux_nmconjug = crapttl.nmextttl
                              aux_nrcpfcjg = crapttl.nrcpfcgc
							  aux_nrctacjg = crapttl.nrdconta
							  aux_vlrencjg = crapttl.vlsalari     + 
                                              crapttl.vldrendi[1]  + 
                                              crapttl.vldrendi[2]  +
                                              crapttl.vldrendi[3]  +
                                              crapttl.vldrendi[4]  +
                                              crapttl.vldrendi[5]  +
                                              crapttl.vldrendi[6].
                END.
                ELSE
                    /* Se o numero da conta não é maior que zero carrega o nome da crapcje */
                    ASSIGN aux_nmconjug = crapcje.nmconjug
                           aux_nrcpfcjg = crapcje.nrcpfcjg
						   aux_vlrencjg = crapcje.vlsalari
						   aux_nrctacjg = crapcje.nrctacje.
            END.

            IF crapass.cdnacion > 0 THEN
            DO:
              /* Buscar nacionalidade */
              FIND FIRST crapnac
                   WHERE crapnac.cdnacion = crapass.cdnacion
                   NO-LOCK NO-ERROR.
            END.
            
            CREATE tt-dados-avais.
            ASSIGN tt-dados-avais.nrctaava = par_nrctaava
                   tt-dados-avais.nmdavali = crapass.nmprimtl
                   tt-dados-avais.nrcpfcgc = crapass.nrcpfcgc 
                   tt-dados-avais.nrdocava = crapass.nrdocptl
                   tt-dados-avais.tpdocava = crapass.tpdocptl
                   tt-dados-avais.nmconjug = aux_nmconjug
                   tt-dados-avais.nrcpfcjg = aux_nrcpfcjg
                   tt-dados-avais.nrdoccjg = IF aux_cdgraupr = 1 THEN 
                                              "C.P.F. " +
                                              STRING(STRING(aux_nrcpfcgc,
                                              "99999999999"),"xxx.xxx.xxx-xx")
                                             ELSE 
                                             ""
                   tt-dados-avais.tpdoccjg = ""
                   tt-dados-avais.nrfonres = IF craptfc.nrdddtfc <> ? THEN STRING(craptfc.nrdddtfc) + STRING(craptfc.nrtelefo) 
                                             ELSE
                                             STRING("00") + STRING(craptfc.nrtelefo)
                                             WHEN AVAIL craptfc
                   tt-dados-avais.dsdemail = crapcem.dsdemail
                                                WHEN AVAIL crapcem   
                   tt-dados-avais.dsendre1 = TRIM(crapenc.dsendere)                   
                   tt-dados-avais.dsendre2 = TRIM(crapenc.nmbairro)
                   tt-dados-avais.nmcidade = TRIM(crapenc.nmcidade)
                   tt-dados-avais.cdufresd = TRIM(crapenc.cdufende)
                   tt-dados-avais.nrcepend = crapenc.nrcepend
                   tt-dados-avais.cdnacion = crapass.cdnacion
                   tt-dados-avais.dsnacion = crapnac.dsnacion
                                             WHEN AVAIL crapnac   
                   tt-dados-avais.vlrenmes = aux_vlrenmes
                   tt-dados-avais.vledvmto = aux_vledvmto
                   tt-dados-avais.nrendere = crapenc.nrendere
                   tt-dados-avais.nrcxapst = crapenc.nrcxapst                 
                   tt-dados-avais.complend = TRIM(crapenc.complend)
                   tt-dados-avais.inpessoa = crapass.inpessoa
                   tt-dados-avais.dtnascto = crapass.dtnasctl
				   tt-dados-avais.vlrencjg = aux_vlrencjg
				   tt-dados-avais.nrctacjg = aux_nrctacjg.
        END.                
    ELSE
    IF  par_nrcpfcgc > 0  THEN
        DO:  
  
       
            /* Odirlei PRJ339 - CRM */
            /* Chamar rotina para buscar dados da pessoa para utilizaçao como avalista */
            { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }
            RUN STORED-PROCEDURE pc_ret_dados_pessoa_prog 
                  aux_handproc = PROC-HANDLE NO-ERROR
                                   (  INPUT par_nrcpfcgc  /* pr_nrcpfcgc   */
                                     ,OUTPUT ""   /* pr_dsxmlret */                                        
                                     ,OUTPUT ""). /* pr_dscritic */
              
              IF  ERROR-STATUS:ERROR  THEN DO:
                  DO  aux_qterrora = 1 TO ERROR-STATUS:NUM-MESSAGES:
                      ASSIGN aux_msgerora = aux_msgerora + 
                                            ERROR-STATUS:GET-MESSAGE(aux_qterrora) + " ".
                    END.
                    
                ASSIGN aux_dscritic = "pc_ret_dados_pessoa_prog --> "  +
                                        "Erro ao executar Stored Procedure: " +
                                        aux_msgerora.
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,         /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).
                  RETURN "NOK".
                  
              END. 

            CLOSE STORED-PROC pc_ret_dados_pessoa_prog 
                    aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
            { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
              
            /*Leitura do XML de retorno da proc e criacao dos registros na temptable
             para visualizacao dos registros na tela */

            /* Buscar o XML na tabela de retorno da procedure Progress */ 
            ASSIGN xml_req = pc_ret_dados_pessoa_prog.pr_dsxmlret.
           
           
           

            /* Efetuar a leitura do XML*/ 
            SET-SIZE(ponteiro_xml) = LENGTH(xml_req) + 1. 
            PUT-STRING(ponteiro_xml,1) = xml_req. 

            /* Inicializando objetos para leitura do XML */ 
            CREATE X-DOCUMENT xDoc.    /* Vai conter o XML completo */ 
            CREATE X-NODEREF  xRoot.   /* Vai conter a tag DADOS em diante */ 
            CREATE X-NODEREF  xRoot2.  /* Vai conter a tag INF em diante */ 
            CREATE X-NODEREF  xField.  /* Vai conter os campos dentro da tag INF */ 
            CREATE X-NODEREF  xText.   /* Vai conter o texto que existe dentro da tag xField */ 

            IF ponteiro_xml <> ? THEN
                DO:
                    xDoc:LOAD("MEMPTR",ponteiro_xml,FALSE). 
                    xDoc:GET-DOCUMENT-ELEMENT(xRoot).

                    DO aux_cont_raiz = 1 TO xRoot:NUM-CHILDREN: 

                        xRoot:GET-CHILD(xRoot2,aux_cont_raiz).
                     
                        IF xRoot2:SUBTYPE <> "ELEMENT" THEN 
                            NEXT. 

                        IF xRoot2:NUM-CHILDREN > 0 THEN
                    DO:
                    CREATE tt-dados-avais.
                          ASSIGN tt-dados-avais.nrcpfcgc = par_nrcpfcgc.
                END.    
                        
                        DO aux_cont = 1 TO xRoot2:NUM-CHILDREN:

                            xRoot2:GET-CHILD(xField,aux_cont).
                            
                            IF xField:SUBTYPE <> "ELEMENT" THEN 
                                NEXT. 

                            xField:GET-CHILD(xText,1) NO-ERROR.
                            
                            ASSIGN tt-dados-avais.nmdavali = xText:NODE-VALUE WHEN xField:NAME = "nmpessoa" NO-ERROR. 
                            ASSIGN tt-dados-avais.tpdocava = xText:NODE-VALUE WHEN xField:NAME = "tpdocume" NO-ERROR. 
                            ASSIGN tt-dados-avais.nrdocava = xText:NODE-VALUE WHEN xField:NAME = "nrdocume" NO-ERROR.
                            ASSIGN tt-dados-avais.nmconjug = xText:NODE-VALUE WHEN xField:NAME = "nmconjug" NO-ERROR. 
                            ASSIGN tt-dados-avais.nrcpfcjg = DECI(xText:NODE-VALUE) WHEN xField:NAME = "nrcpfcjg" NO-ERROR.                            
                            ASSIGN tt-dados-avais.tpdoccjg = xText:NODE-VALUE WHEN xField:NAME = "tpdoccjg" NO-ERROR. 
                            ASSIGN tt-dados-avais.nrdoccjg = xText:NODE-VALUE WHEN xField:NAME = "nrdoccjg" NO-ERROR. 
                            ASSIGN tt-dados-avais.dsendre1 = xText:NODE-VALUE WHEN xField:NAME = "dsendre1" NO-ERROR. 
                            ASSIGN tt-dados-avais.dsendre2 = xText:NODE-VALUE WHEN xField:NAME = "dsbairro" NO-ERROR. 
                            ASSIGN tt-dados-avais.nrfonres = xText:NODE-VALUE WHEN xField:NAME = "nrfonres" NO-ERROR. 
                            ASSIGN tt-dados-avais.dsdemail = xText:NODE-VALUE WHEN xField:NAME = "dsdemail" NO-ERROR. 
                            ASSIGN tt-dados-avais.nmcidade = xText:NODE-VALUE WHEN xField:NAME = "nmcidade" NO-ERROR. 
                            ASSIGN tt-dados-avais.cdufresd = xText:NODE-VALUE WHEN xField:NAME = "cdufresd" NO-ERROR. 
                            ASSIGN tt-dados-avais.nrcepend = DECI(xText:NODE-VALUE) WHEN xField:NAME = "nrcepend" NO-ERROR. 
                            ASSIGN tt-dados-avais.dsnacion = xText:NODE-VALUE WHEN xField:NAME = "dsnacion" NO-ERROR. 
                            ASSIGN tt-dados-avais.vledvmto = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vledvmto" NO-ERROR. 
                            ASSIGN tt-dados-avais.vlrenmes = DECI(xText:NODE-VALUE) WHEN xField:NAME = "vlrenmes" NO-ERROR.    
                            ASSIGN tt-dados-avais.complend = xText:NODE-VALUE WHEN xField:NAME = "complend" NO-ERROR. 
                            ASSIGN tt-dados-avais.nrendere = DECI(xText:NODE-VALUE) WHEN xField:NAME = "nrendere" NO-ERROR.                                 
                            ASSIGN tt-dados-avais.inpessoa = INT(xText:NODE-VALUE) WHEN xField:NAME = "inpessoa" NO-ERROR.  
                            ASSIGN tt-dados-avais.dtnascto = DATE(xText:NODE-VALUE) WHEN xField:NAME = "dtnascto" NO-ERROR.  
                            ASSIGN tt-dados-avais.cdnacion = INT(xText:NODE-VALUE) WHEN xField:NAME = "cdnacion" NO-ERROR.
                                   
                END.

                    END.
                    
                    SET-SIZE(ponteiro_xml) = 0. 

                END.    

            /*Elimina os objetos criados*/
            DELETE OBJECT xDoc. 
            DELETE OBJECT xRoot. 
            DELETE OBJECT xRoot2. 
            DELETE OBJECT xField. 
            DELETE OBJECT xText.
                  
             
        END.
    
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE valida-avalistas:

    /**********************************************************************/
    /** Procedure para validar dados dos avalistas informados            **/
    /** Baseado no programa fontes/limite_inp.p                          **/
    /**********************************************************************/

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    /** ------------------- Parametros do 1 avalista ------------------- **/
    DEF  INPUT PARAM par_nrctaav1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdaval1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepen1 AS INTE                           NO-UNDO.
    /** ------------------- Parametros do 2 avalista ------------------- **/
    DEF  INPUT PARAM par_nrctaav2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdaval2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepen2 AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_nmdcampo AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_stsnrcal AS LOGI                                    NO-UNDO.
    DEF VAR aux_nrcpfcgc AS DECI                                    NO-UNDO.
    DEF VAR aux_nrdocnp1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdocnp2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_nrdocnp3 AS CHAR                                    NO-UNDO.
    DEF VAR aux_inpessoa AS INTE                                    NO-UNDO.
    DEF VAR avt_inpessoa AS INTE                                    NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    DO WHILE TRUE:

       FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                          crapass.nrdconta = par_nrdconta  
                          NO-LOCK NO-ERROR.

       IF   NOT AVAIL crapass   THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE.
            END.

       /* CPF do cooperado e inpessoa  */
       ASSIGN aux_nrcpfcgc = crapass.nrcpfcgc
              aux_inpessoa = crapass.inpessoa
              aux_nrdocnp1 = STRING(aux_nrcpfcgc,"99999999999999")
              aux_nrdocnp1 = SUBSTR(aux_nrdocnp1,1,8). 
            
       
       IF  par_nrctaav1 > 0             AND  /* Contas iguais dos avais */
           par_nrctaav2 > 0             AND
           par_nrctaav1 = par_nrctaav2  THEN
           DO:
               ASSIGN aux_dscritic = "A conta/dv dos avalistas devem ser " +
                                     "diferentes."
                      par_nmdcampo = "nrctaava".                                
               LEAVE.
           END.

       IF  par_nrctaav1 = 0  THEN /* Primeiro avalista terceiro */
           DO:
               IF  par_nrcpfav1 = 0 AND par_nmdaval1 <> ""  THEN
                   DO:
                       ASSIGN aux_dscritic = "Informe o CPF do 1o avalista."
                              par_nmdcampo = "nrcpfcgc".                                   
                       LEAVE.
                   END.
               
               IF  par_nrcpfav1 > 0 AND par_nmdaval1 = ""  THEN
                   DO:
                       ASSIGN aux_dscritic = "Informe o nome do 1o avalista."
                              par_nmdcampo = "nmdavali".                                 
                       LEAVE.
                   END.
               
               IF  par_ende1av1 = "" AND par_nmdaval1 <> ""  THEN
                   DO:
                       ASSIGN aux_dscritic = "Informe o endereco do 1o avalista."
                              par_nmdcampo = "dsendre1".                      
                       LEAVE.
                   END.
           END.
       ELSE             /* Primeiro avalista cooperado */
           DO:
               FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                  crapass.nrdconta = par_nrctaav1   
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAIL crapass  THEN
                    DO:
                        ASSIGN aux_cdcritic = 9
                               par_nmdcampo = "nrctaava".
                        LEAVE.
                    END.

                /* CPF do cooperado é igual ao do aval */
                IF   crapass.nrcpfcgc = aux_nrcpfcgc   THEN
                     DO:
                         ASSIGN aux_dscritic = "CPF do avalista deve ser " +
                                               "diferente do CONTRATANTE."
                                par_nmdcampo = "nrctaava".
                         LEAVE.
                     END. 

                /* Atribuir CPF ao 1 aval */
                ASSIGN par_nrcpfav1 = crapass.nrcpfcgc.

           END.

       IF  par_nrctaav2 = 0  THEN /* Segundo avalista terceiro */
           DO:
               IF  par_nrcpfav2 = 0 AND par_nmdaval2 <> ""  THEN
                   DO:
                       ASSIGN aux_dscritic = "Informe o CPF do 2o avalista."
                              par_nmdcampo = "nrcpfcgc".                               
                       LEAVE.
                   END.

               IF  par_nrcpfav2 > 0 AND par_nmdaval2 = ""  THEN
                   DO:
                        ASSIGN aux_dscritic = "Informe o nome do 2o avalista."
                               par_nmdcampo = "nmdavali".                                 
                        LEAVE.
                    END.

               IF  par_ende1av2 = "" AND par_nmdaval2 <> ""  THEN
                   DO:
                       ASSIGN aux_dscritic = "Informe o endereco do 2o avalista."
                              par_nmdcampo = "dsendre1".                  
                       LEAVE.
                   END.
           END.
       ELSE                 /* Segundo avalista cooperado */
           DO:
               FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                                  crapass.nrdconta = par_nrctaav2   
                                  NO-LOCK NO-ERROR.

               IF   NOT AVAIL crapass   THEN
                    DO:
                        ASSIGN aux_cdcritic = 9
                               par_nmdcampo = "nrctaava".
                        LEAVE.
                    END.

               IF   crapass.nrcpfcgc = aux_nrcpfcgc   THEN
                    DO:
                        ASSIGN aux_dscritic = "CPF do avalista deve ser " +
                                              "diferente do CONTRATANTE."
                               par_nmdcampo = "nrctaava".
                        LEAVE.
                    END.

               /* Atribuir CPF ao segundo aval */
               ASSIGN par_nrcpfav2 = crapass.nrcpfcgc. 
           END.

       IF  par_nrcpfav1 > 0  THEN /* Validar CPF do 1 aval */
           DO:
               RUN valida-cpf-cnpj (INPUT par_nrcpfav1,
                                   OUTPUT aux_stsnrcal,
                                   OUTPUT avt_inpessoa).
                                
               IF  NOT aux_stsnrcal  THEN
                   DO:
                       ASSIGN aux_dscritic = "CPF do 1o avalista com erro."
                              par_nmdcampo = "nrcpfcgc".
                       LEAVE.
                   END.
           END.

       /* Validar CEP do primeiro avalista */
       IF  par_nrctaav1 = 0 AND par_nrcepen1 <> 0  THEN
           DO:
               IF  NOT CAN-FIND(FIRST crapdne 
                                WHERE crapdne.nrceplog = par_nrcepen1)
                   THEN
                   DO:
                       ASSIGN aux_dscritic = "CEP nao cadastrado."
                              par_nmdcampo = "nrcepend".
                       LEAVE.
                   END.

               IF  par_ende1av1 = ""  THEN
                   DO:
                       ASSIGN aux_dscritic = "Endereco deve ser informado."
                              par_nmdcampo = "nrcepend".
                       LEAVE.
                   END.

               IF  NOT CAN-FIND(FIRST crapdne 
                                WHERE crapdne.nrceplog = par_nrcepen1  
                                  AND (TRIM(par_ende1av1) MATCHES 
                                      ("*" + TRIM(crapdne.nmextlog) + "*")
                                   OR TRIM(par_ende1av1) MATCHES
                                      ("*" + TRIM(crapdne.nmreslog) + "*"))) THEN
                   DO:
                       ASSIGN aux_dscritic = "Endereco nao pertence ao CEP."
                              par_nmdcampo = "par_nrcepen".
                       LEAVE.
                   END.
           END.

       /* Validar CEP do segundo avalista */
       IF  par_nrctaav2 = 0 AND par_nrcepen2 <> 0  THEN
           DO:
               IF  NOT CAN-FIND(FIRST crapdne 
                                WHERE crapdne.nrceplog = par_nrcepen2)
                   THEN
                   DO:
                       ASSIGN aux_dscritic = "CEP nao cadastrado."
                              par_nmdcampo = "nrcepend".
                       LEAVE.
                   END.
               IF  par_ende1av2 = ""  THEN
                   DO:
                       ASSIGN aux_dscritic = "Endereco deve ser informado."
                              par_nmdcampo = "nrcepend".
                       LEAVE.
                   END.

               IF  NOT CAN-FIND(FIRST crapdne 
                                WHERE crapdne.nrceplog = par_nrcepen2  
                                  AND (TRIM(par_ende1av2) MATCHES 
                                      ("*" + TRIM(crapdne.nmextlog) + "*")
                                   OR TRIM(par_ende1av2) MATCHES
                                      ("*" + TRIM(crapdne.nmreslog) + "*"))) THEN
                   DO:
                   
                       ASSIGN aux_dscritic = "Endereco nao pertence ao CEP."
                              par_nmdcampo = "nrcepend".
                       LEAVE.
                   END.
           END.

       /* Se avalista pessoa juridicas */
       IF   avt_inpessoa > 1  AND
            par_nrcpfav1 > 0  THEN
            DO:            
                /* Oito primeiros digitos nao podem ser iguais */
                ASSIGN aux_nrdocnp2 = STRING(par_nrcpfav1,"99999999999999")
                       aux_nrdocnp2 = SUBSTR(aux_nrdocnp2,1,8). 

                /* Se cooperado p. juridica */
                IF   aux_inpessoa > 1              AND
                     aux_nrdocnp1 = aux_nrdocnp2   THEN
                     DO:
                         ASSIGN aux_dscritic = "CNPJ do avalista deve ser " +
                                               "diferente do CONTRATANTE."
                                par_nmdcampo = "nrctaava".
                         LEAVE.
                     END.
            END.
 
       IF  par_cpfcjav1 > 0  THEN /* Validar CPF do conjuge do 1 aval */
           DO:
               RUN valida-cpf-cnpj (INPUT par_cpfcjav1,
                                   OUTPUT aux_stsnrcal,
                                   OUTPUT avt_inpessoa).
                                   
               IF  NOT aux_stsnrcal  THEN
                   DO:
                       ASSIGN aux_dscritic = "CPF do conjuge do 1o avalista " +
                                             "com erro."
                              par_nmdcampo = "nrcpfcjg".
                       LEAVE.
                   END.
           END.

       IF  par_nrcpfav2 > 0  THEN /* Validar CPF do 2 aval */
           DO:
               RUN valida-cpf-cnpj (INPUT par_nrcpfav2,
                                   OUTPUT aux_stsnrcal,
                                   OUTPUT avt_inpessoa).
                                   
               IF  NOT aux_stsnrcal  THEN
                   DO:
                       ASSIGN aux_dscritic = "CPF do 2o avalista com erro."
                              par_nmdcampo = "nrcpfcgc".
                       LEAVE.
                   END.
           END.
       
       /* Se avalista p. juridica */
       IF   avt_inpessoa > 1   AND
            par_nrcpfav2 > 0   THEN
            DO:
                /* Primeiros 8 digitos nao podem ser iguais */
                ASSIGN aux_nrdocnp3 = STRING(par_nrcpfav2,"99999999999999")
                       aux_nrdocnp3 = SUBSTR(aux_nrdocnp3,1,8). 

                /* Se cooperado p. juridica */
                IF   aux_inpessoa > 1              AND
                     aux_nrdocnp1 = aux_nrdocnp3   THEN
                     DO:
                         ASSIGN aux_dscritic = "CNPJ do avalista deve ser " +
                                               "diferente do CONTRATANTE."
                                par_nmdcampo = "nrctaava".
                         LEAVE.
                     END.
            END.

       /* Os dois avalistas com os 8 primeiros digitos iguais da CNPJ */
       IF   aux_nrdocnp2 <> ""            AND
            aux_nrdocnp3 <> ""            AND 
            aux_nrdocnp2 = aux_nrdocnp3   THEN
            DO:    
                ASSIGN aux_dscritic = 
                           "CNPJ dos avalistas devem ser diferentes."
                       par_nmdcampo = "nrctaava".
                LEAVE.
            END.

       IF  par_cpfcjav2 > 0  THEN /* Validar CPF do conjuge do 2 aval */
           DO:
               RUN valida-cpf-cnpj (INPUT par_cpfcjav2,
                                   OUTPUT aux_stsnrcal,
                                   OUTPUT avt_inpessoa).
                                   
               IF  NOT aux_stsnrcal  THEN
                   DO:
                       ASSIGN aux_dscritic = "CPF do conjuge do 2o avalista " +
                                             "com erro."
                              par_nmdcampo = "nrcpfcjg".
                       LEAVE.       
                   END.
           END.

       IF  par_nrcpfav1 > 0             AND /* Ambos CPF iguais */
           par_nrcpfav2 > 0             AND
           par_nrcpfav1 = par_nrcpfav2  THEN
           DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "CPF dos avalistas devem ser diferentes."
                      par_nmdcampo = "nrcpfcgc".                         
              LEAVE.
           END.

       IF  par_nrcpfav1 > 0 AND par_nrctaav1 = 0  THEN
           DO:
               FIND LAST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                       crapass.nrcpfcgc = par_nrcpfav1 AND
                                       crapass.dtdemiss = ? AND
                                       (crapass.cdsitdct = 1 OR
                                        crapass.cdsitdct = 5 OR
                                        crapass.cdsitdct = 9)
                                       NO-LOCK NO-ERROR.
       
               IF  AVAILABLE crapass  THEN
                   DO:
                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = "CPF de associado, informe a conta " +
                                             "do 1o avalista."
                              par_nmdcampo = "nrctaava".                  
                       LEAVE.
                   END.
           END.

       IF  par_nrcpfav2 > 0 AND par_nrctaav2 = 0  THEN
           DO:
               FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper AND
                                        crapass.nrcpfcgc = par_nrcpfav2 AND
                                        crapass.dtdemiss = ? AND
                                       (crapass.cdsitdct = 1 OR
                                        crapass.cdsitdct = 5 OR
                                        crapass.cdsitdct = 9)
                                        NO-LOCK NO-ERROR.
       
               IF  AVAILABLE crapass  THEN
                   DO:
                       ASSIGN aux_cdcritic = 0
                              aux_dscritic = "CPF de associado, informe a conta " +
                                             "do 2o avalista."
                              par_nmdcampo = "nrctaava".                                  
                       LEAVE.
                   END.
           END.

       LEAVE.

    END. /* Fim tratamento de criticas */

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1, /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE cria-tabelas-avalistas.

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsoperac AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    /** ------------------- Parametros do 1 avalista ------------------- **/
    DEF  INPUT PARAM par_nrctaav1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdaval1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdocav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tdccjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_doccjav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende2av1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrfonav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_emailav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidav1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufava1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepav1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacio1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vledvmt1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlrenme1 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrender1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complen1 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaps1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpesso1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasct1 AS DATE                           NO-UNDO.
	DEF  INPUT PARAM par_vlrecjg1 AS DECI                           NO-UNDO.

    /** ------------------- Parametros do 2 avalista ------------------- **/
    DEF  INPUT PARAM par_nrctaav2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdaval2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcpfav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tpdocav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsdocav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmdcjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cpfcjav2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_tdccjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_doccjav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende1av2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_ende2av2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrfonav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_emailav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmcidav2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufava2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepav2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdnacio2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_vledvmt2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_vlrenme2 AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrender2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_complen2 AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcxaps2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpesso2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtnasct2 AS DATE                           NO-UNDO.
	DEF  INPUT PARAM par_vlrecjg2 AS DECI                           NO-UNDO.

    DEF  INPUT PARAM par_dsdbeavt AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR         aux_contador AS INTE                           NO-UNDO.
    DEF  VAR         aux_dsdregis AS CHAR                           NO-UNDO.
    DEF  VAR         aux_dsdbeav1 AS CHAR                           NO-UNDO.
    DEF  VAR         aux_dsdbeav2 AS CHAR                           NO-UNDO.
    DEF  VAR         aux_dsrotina AS CHAR                           NO-UNDO.
    DEF  VAR         aux_stsnrcal AS LOG                            NO-UNDO.
    DEF  VAR         aux_inpessoa AS INT                            NO-UNDO.
    DEF  VAR         h-b1wgen0024 AS HANDLE                         NO-UNDO.
    DEF  VAR         h-b1wgen0110 AS HANDLE                         NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_dsrotina = ""
           aux_dscritic = ""
           aux_cdcritic = 0
           aux_stsnrcal = FALSE
           aux_inpessoa = 0.

    EMPTY TEMP-TABLE tt-crapbem.

    IF  par_nrctaav1 > 0    THEN 
        DO:
            IF CAN-FIND(FIRST crapavl WHERE crapavl.cdcooper = par_cdcooper
                                        AND crapavl.nrdconta = par_nrctaav1 
                                        AND crapavl.nrctravd = par_nrctrato
                                        AND crapavl.tpctrato = par_tpctrato
                                        NO-LOCK) THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "O contrato " + STRING(par_nrctrato) +
                                      " do limite de credito da conta "    +
                                      "avalista " + STRING(par_nrctaav1)   +
                                      " ja existe.".
    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                                           
                RETURN "NOK".
            END.
            ELSE
            DO:
                CREATE crapavl.  
                ASSIGN crapavl.cdcooper = par_cdcooper
                       crapavl.tpctrato = par_tpctrato
                       crapavl.nrdconta = par_nrctaav1
                       crapavl.nrctravd = par_nrctrato
                       crapavl.nrctaavd = par_nrdconta.

                VALIDATE crapavl.
            END.
        END.
         
    IF  par_nrctaav2 > 0   THEN 
        DO:
            IF CAN-FIND(FIRST crapavl WHERE crapavl.cdcooper = par_cdcooper
                                        AND crapavl.nrdconta = par_nrctaav2 
                                        AND crapavl.nrctravd = par_nrctrato
                                        AND crapavl.tpctrato = par_tpctrato
                                        NO-LOCK) THEN
            DO:
                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "O contrato " + STRING(par_nrctrato) +
                                      " do limite de credito da conta "    +
                                      "avalista " + STRING(par_nrctaav2)   +
                                      " ja existe.".
    
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
                                                           
                RETURN "NOK".
            END.
            ELSE
            DO:
                CREATE crapavl.  
                ASSIGN crapavl.cdcooper = par_cdcooper
                       crapavl.tpctrato = par_tpctrato
                       crapavl.nrdconta = par_nrctaav2
                       crapavl.nrctravd = par_nrctrato
                       crapavl.nrctaavd = par_nrdconta.
    
                VALIDATE crapavl.
            END.
        END.

    DO aux_contador = 1 TO NUM-ENTRIES(par_dsdbeavt,"|") :

        ASSIGN aux_dsdregis = ENTRY(aux_contador,par_dsdbeavt,"|").

        CREATE tt-crapbem.
        ASSIGN tt-crapbem.nrdconta = INTE(ENTRY(1,aux_dsdregis,";"))
               tt-crapbem.nrcpfcgc = DECI(ENTRY(2,aux_dsdregis,";"))  
               tt-crapbem.dsrelbem = ENTRY(3,aux_dsdregis,";")
               tt-crapbem.persemon = DECI(ENTRY(4,aux_dsdregis,";"))
               tt-crapbem.qtprebem = INTE(ENTRY(5,aux_dsdregis,";"))  
               tt-crapbem.vlprebem = DECI(ENTRY(6,aux_dsdregis,";")) 
               tt-crapbem.vlrdobem = DECI(ENTRY(7,aux_dsdregis,";"))
               tt-crapbem.idseqbem = INTE(ENTRY(8,aux_dsdregis,";")).

        /* Se aval 1 cooperado, guardar os bens dele */
        IF   par_nrctaav1 > 0                     AND 
             tt-crapbem.nrdconta = par_nrctaav1   THEN
             ASSIGN aux_dsdbeav1 = IF   aux_dsdbeav1 = ""   THEN 
                                        aux_dsdregis
                                   ELSE
                                        aux_dsdbeav1 + "|" + aux_dsdregis. 

        /* Se aval 2 cooperado, guardar os bens dele */
        IF   par_nrctaav2 > 0   AND 
             tt-crapbem.nrdconta = par_nrctaav2   THEN
             ASSIGN aux_dsdbeav2 = IF   aux_dsdbeav2 = ""   THEN
                                        aux_dsdregis
                                  ELSE
                                        aux_dsdbeav2 + "|" + aux_dsdregis.

    END.          
    
    /* Se tem algum avalista cooperado, cadastrar os novos bens dele */
    IF   par_nrctaav1 <> 0   OR
         par_nrctaav2 <> 0   THEN
         DO:
             RUN sistema/generico/procedures/b1wgen0024.p
                                  PERSISTEN SET h-b1wgen0024.
                                 
             /* Nao gravar os dados que sao  especificos de pessoa fisica */
             /* ou juridica. Só os bens. */
             IF    par_nrctaav1 <> 0   THEN
                   RUN grava-dados-cadastro IN h-b1wgen0024
                                               (INPUT par_cdcooper,
                                                INPUT 0,  /* PAC   */
                                                INPUT 0,  /* Caixa */
                                                INPUT par_cdoperad, /* Ope   */
                                                INPUT par_dsoperac, /*Operacao*/
                                                INPUT par_idorigem, 
                                                INPUT par_nrctaav1,
                                                INPUT 1, /* Tit.*/
                                                INPUT par_dtmvtolt,
                                                INPUT 0,   
                                                INPUT aux_dsdbeav1,
                                                INPUT "",  /* Estes      */
                                                INPUT 0,   /* parametros */
                                                INPUT 0,
                                                INPUT 0,   /* nao serao  */
                                                INPUT "",  /* gravados   */
                                                INPUT 0,
                                                INPUT "",
                                                INPUT "",
                                                OUTPUT TABLE tt-erro). 

             IF    par_nrctaav2 <> 0   THEN
                   RUN grava-dados-cadastro IN h-b1wgen0024
                                               (INPUT par_cdcooper,
                                                INPUT 0,  /* PAC */
                                                INPUT 0,  /* Caixa*/
                                                INPUT par_cdoperad, /* Ope*/
                                                INPUT par_dsoperac, /* Operacao*/
                                                INPUT par_idorigem,
                                                INPUT par_nrctaav2,
                                                INPUT 1, /* Tit.*/
                                                INPUT par_dtmvtolt,
                                                INPUT 0,   
                                                INPUT aux_dsdbeav2,
                                                INPUT "",
                                                INPUT 0,
                                                INPUT 0,
                                                INPUT 0,
                                                INPUT "",
                                                INPUT 0,
                                                INPUT "",
                                                INPUT "",
                                                OUTPUT TABLE tt-erro).        
             DELETE PROCEDURE h-b1wgen0024.    
      
         END.
    
    IF  par_nrctaav1 = 0 AND par_nmdaval1 <> ""  THEN
        DO:

            CREATE crapavt.
            ASSIGN crapavt.cdcooper    = par_cdcooper
                   crapavt.dtmvtolt    = par_dtmvtolt
                   crapavt.tpctrato    = par_tpctrato 
                   crapavt.nrctremp    = par_nrctrato
                   crapavt.nrdconta    = par_nrdconta                   
                   crapavt.nmdavali    = CAPS(par_nmdaval1)
                   crapavt.nrcpfcgc    = par_nrcpfav1
                   crapavt.tpdocava    = CAPS(par_tpdocav1)
                   crapavt.nrdocava    = CAPS(par_dsdocav1)
                   crapavt.nmconjug    = CAPS(par_nmdcjav1)
                   crapavt.nrcpfcjg    = par_cpfcjav1
                   crapavt.tpdoccjg    = CAPS(par_tdccjav1)
                   crapavt.nrdoccjg    = CAPS(par_doccjav1)
                   crapavt.dsendres[1] = CAPS(par_ende1av1)
                   crapavt.dsendres[2] = CAPS(par_ende2av1)
                   crapavt.nrfonres    = CAPS(par_nrfonav1)
                   crapavt.dsdemail    = par_emailav1
                   crapavt.nmcidade    = CAPS(par_nmcidav1)
                   crapavt.cdufresd    = CAPS(par_cdufava1)
                   crapavt.nrcepend    = par_nrcepav1
                   crapavt.cdnacion    = par_cdnacio1
                   crapavt.vledvmto    = par_vledvmt1
                   crapavt.vlrenmes    = par_vlrenme1
                   crapavt.nrendere    = par_nrender1
                   crapavt.complend    = CAPS(par_complen1)
                   crapavt.nrcxapst    = par_nrcxaps1
                   crapavt.inpessoa    = par_inpesso1
                   crapavt.dtnascto    = par_dtnasct1
				   crapavt.vlrencjg    = par_vlrecjg1
                   aux_contador        = 0.

            VALIDATE crapavt.

            /* Bens do aval */
            FOR EACH tt-crapbem WHERE
                     tt-crapbem.nrcpfcgc = par_nrcpfav1 NO-LOCK:

                ASSIGN aux_contador = aux_contador + 1.

                IF   aux_contador > 6   THEN
                     LEAVE.

                ASSIGN crapavt.dsrelbem[aux_contador] = tt-crapbem.dsrelbem
                       crapavt.persemon[aux_contador] = tt-crapbem.persemon
                       crapavt.qtprebem[aux_contador] = tt-crapbem.qtprebem
                       crapavt.vlprebem[aux_contador] = tt-crapbem.vlprebem
                       crapavt.vlrdobem[aux_contador] = tt-crapbem.vlrdobem.
            END.

        END.
    
    IF  par_nrctaav2 = 0 AND par_nmdaval2 <> ""  THEN
        DO:
            CREATE crapavt.
            ASSIGN crapavt.cdcooper    = par_cdcooper
                   crapavt.dtmvtolt    = par_dtmvtolt
                   crapavt.tpctrato    = par_tpctrato 
                   crapavt.nrctremp    = par_nrctrato
                   crapavt.nrdconta    = par_nrdconta                   
                   crapavt.nmdavali    = CAPS(par_nmdaval2)
                   crapavt.nrcpfcgc    = par_nrcpfav2
                   crapavt.tpdocava    = CAPS(par_tpdocav2)
                   crapavt.nrdocava    = CAPS(par_dsdocav2)
                   crapavt.nmconjug    = CAPS(par_nmdcjav2)
                   crapavt.nrcpfcjg    = par_cpfcjav2
                   crapavt.tpdoccjg    = CAPS(par_tdccjav2)
                   crapavt.nrdoccjg    = CAPS(par_doccjav2)
                   crapavt.dsendres[1] = CAPS(par_ende1av2)
                   crapavt.dsendres[2] = CAPS(par_ende2av2)
                   crapavt.nrfonres    = CAPS(par_nrfonav2)
                   crapavt.dsdemail    = par_emailav2
                   crapavt.nmcidade    = CAPS(par_nmcidav2)
                   crapavt.cdufresd    = CAPS(par_cdufava2)
                   crapavt.nrcepend    = par_nrcepav2
                   crapavt.cdnacion    = par_cdnacio2
                   crapavt.vledvmto    = par_vledvmt2
                   crapavt.vlrenmes    = par_vlrenme2
                   crapavt.nrendere    = par_nrender2        
                   crapavt.complend    = CAPS(par_complen2) 
                   crapavt.nrcxapst    = par_nrcxaps2     
                   crapavt.inpessoa    = par_inpesso2
                   crapavt.dtnascto    = par_dtnasct2
				   crapavt.vlrencjg    = par_vlrecjg2
                   aux_contador         = 0.

            VALIDATE crapavt.

            /* Bens do aval*/
            FOR EACH tt-crapbem WHERE 
                     tt-crapbem.nrcpfcgc = par_nrcpfav2 NO-LOCK:

                ASSIGN aux_contador = aux_contador + 1.

                IF   aux_contador > 6   THEN
                     LEAVE.

                ASSIGN crapavt.dsrelbem[aux_contador] = tt-crapbem.dsrelbem
                       crapavt.persemon[aux_contador] = tt-crapbem.persemon
                       crapavt.qtprebem[aux_contador] = tt-crapbem.qtprebem
                       crapavt.vlprebem[aux_contador] = tt-crapbem.vlprebem
                       crapavt.vlrdobem[aux_contador] = tt-crapbem.vlrdobem.

            END.

        END.

    IF (par_nrctaav1 = 0     AND 
        par_nmdaval1 <> "" ) OR 
        par_nrctaav1 > 0     THEN 
       DO:
          RUN valida-cpf-cnpj(INPUT par_nrcpfav1,
                              OUTPUT aux_stsnrcal,
                              OUTPUT aux_inpessoa).

          IF NOT aux_stsnrcal  THEN
             RETURN "NOK".

          /*Monta a mensagem da rotina para envio no e-mail*/
          ASSIGN aux_dsrotina = "Inclusao/alteracao "                      +
                                "do avalista conta "                       +
                                STRING(par_nrctaav1,"zzzz,zzz,9")          +
                                " - CPF/CNPJ "                             +
                               (IF aux_inpessoa = 1 THEN 
                                   STRING((STRING(par_nrcpfav1,
                                         "99999999999")),"xxx.xxx.xxx-xx")
                                 ELSE
                                    STRING((STRING(par_nrcpfav1,
                                            "99999999999999")),
                                            "xx.xxx.xxx/xxxx-xx" ))        +
                                " na conta "                               +
                                STRING(par_nrdconta,"zzzz,zzz,9").
          
          IF NOT VALID-HANDLE(h-b1wgen0110) THEN
             RUN sistema/generico/procedures/b1wgen0110.p 
                 PERSISTENT SET h-b1wgen0110.
          
          /*Verifica se o primeiro avalista esta no cadastro restritivo. Se 
            estiver, sera enviado um e-mail informando a situacao*/
          RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                            INPUT 0, /*cdagenci*/
                                            INPUT 0, /*nrdcaixa*/
                                            INPUT par_cdoperad,
                                            INPUT "", /*nmdatela*/
                                            INPUT par_dtmvtolt,
                                            INPUT par_idorigem,
                                            INPUT par_nrcpfav1,
                                            INPUT par_nrctaav1,
                                            INPUT 1, /*idseqttl*/
                                            INPUT FALSE, /*nao bloq. operacao*/
                                            INPUT 32, /*cdoperac*/
                                            INPUT aux_dsrotina,
                                            OUTPUT TABLE tt-erro).
          
          IF VALID-HANDLE(h-b1wgen0110) THEN
             DELETE PROCEDURE(h-b1wgen0110).

       END.


    IF (par_nrctaav2 = 0     AND 
        par_nmdaval2 <> "" ) OR
        par_nrctaav2 > 0     THEN
       DO:
          RUN valida-cpf-cnpj(INPUT par_nrcpfav2,
                              OUTPUT aux_stsnrcal,
                              OUTPUT aux_inpessoa).

          IF NOT aux_stsnrcal  THEN
             RETURN "NOK".

          /*Monta a mensagem da rotina para envio no e-mail*/
          ASSIGN aux_dsrotina = "Inclusao/alteracao "                      +
                                "do avalista conta "                       +
                                STRING(par_nrctaav2,"zzzz,zzz,9")          +
                                " - CPF/CNPJ "                             +
                               (IF aux_inpessoa = 1 THEN 
                                   STRING((STRING(par_nrcpfav2,
                                         "99999999999")),"xxx.xxx.xxx-xx")
                                 ELSE
                                    STRING((STRING(par_nrcpfav2,
                                            "99999999999999")),
                                            "xx.xxx.xxx/xxxx-xx" ))        +
                                " na conta "                               +
                                STRING(par_nrdconta,"zzzz,zzz,9").
          

          IF NOT VALID-HANDLE(h-b1wgen0110) THEN
             RUN sistema/generico/procedures/b1wgen0110.p 
                 PERSISTENT SET h-b1wgen0110.

          /*Verifica se o segundo avalista esta no cadastro restritivo. Se 
            estiver, sera enviado um e-mail informando a situacao*/
          RUN alerta_fraude IN h-b1wgen0110(INPUT par_cdcooper,
                                            INPUT 0, /*cdagenci*/
                                            INPUT 0, /*nrdcaixa*/
                                            INPUT par_cdoperad,
                                            INPUT "", /*nmdatela*/
                                            INPUT par_dtmvtolt,
                                            INPUT par_idorigem,
                                            INPUT par_nrcpfav2,
                                            INPUT par_nrctaav2,
                                            INPUT 1, /*idseqttl*/
                                            INPUT FALSE, /*nao bloq. operacao*/
                                            INPUT 32, /*cdoperac*/
                                            INPUT aux_dsrotina,
                                            OUTPUT TABLE tt-erro).
          
          IF VALID-HANDLE(h-b1wgen0110) THEN
             DELETE PROCEDURE(h-b1wgen0110).

       END.
    
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE atualiza_tabela_avalistas:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dsoperac AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.   
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.   
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    /** ------------------- Parametros do 1 avalista ------------------- **/   
    DEF  INPUT PARAM par_nrctaav1 AS INTE                           NO-UNDO.     
    DEF  INPUT PARAM par_nmdaval1 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_nrcpfav1 AS DECI                           NO-UNDO.    
    DEF  INPUT PARAM par_tpdocav1 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_dsdocav1 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_nmdcjav1 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_cpfcjav1 AS DECI                           NO-UNDO.    
    DEF  INPUT PARAM par_tdccjav1 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_doccjav1 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_ende1av1 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_ende2av1 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_nrfonav1 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_emailav1 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_nmcidav1 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_cdufava1 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_nrcepav1 AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_cdnacio1 AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_vledvmt1 AS DECI                           NO-UNDO.    
    DEF  INPUT PARAM par_vlrenme1 AS DECI                           NO-UNDO.    
    DEF  INPUT PARAM par_nrender1 AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_complen1 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_nrcxaps1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpesso1 AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_dtnasct1 AS DATE                           NO-UNDO.
	DEF  INPUT PARAM par_vlrecjg1 AS DECI                           NO-UNDO.
    /** ------------------- Parametros do 2 avalista ------------------- **/   
    DEF  INPUT PARAM par_nrctaav2 AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_nmdaval2 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_nrcpfav2 AS DECI                           NO-UNDO.    
    DEF  INPUT PARAM par_tpdocav2 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_dsdocav2 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_nmdcjav2 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_cpfcjav2 AS DECI                           NO-UNDO.    
    DEF  INPUT PARAM par_tdccjav2 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_doccjav2 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_ende1av2 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_ende2av2 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_nrfonav2 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_emailav2 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_nmcidav2 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_cdufava2 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_nrcepav2 AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_cdnacio2 AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_vledvmt2 AS DECI                           NO-UNDO.    
    DEF  INPUT PARAM par_vlrenme2 AS DECI                           NO-UNDO.    
    DEF  INPUT PARAM par_nrender2 AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_complen2 AS CHAR                           NO-UNDO.    
    DEF  INPUT PARAM par_nrcxaps2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inpesso2 AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_dtnasct2 AS DATE                           NO-UNDO.
	DEF  INPUT PARAM par_vlrecjg2 AS DECI                           NO-UNDO.

    DEF  INPUT PARAM par_dsdbeavt AS CHAR                           NO-UNDO.  

    FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper  AND
                           crapavt.tpctrato = par_tpctrato  AND
                           crapavt.nrdconta = par_nrdconta  AND
                           crapavt.nrctremp = par_nrctrato   
                           EXCLUSIVE-LOCK:
        DELETE crapavt.
    END.
     
    FOR EACH crapavl WHERE crapavl.cdcooper = par_cdcooper  AND
                           crapavl.nrctaavd = par_nrdconta  AND
                           crapavl.tpctrato = par_tpctrato  AND
                           crapavl.nrctravd = par_nrctrato   
                           EXCLUSIVE-LOCK:
        DELETE crapavl.
    END.

    RUN cria-tabelas-avalistas (INPUT par_cdcooper,
                                INPUT par_cdoperad,
                                INPUT par_idorigem,
                                INPUT par_dsoperac,
                                INPUT par_nrdconta,
                                INPUT par_dtmvtolt,
                                INPUT par_tpctrato,
                                INPUT par_nrctrato,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                /* 1 avalista */
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
                                INPUT par_cdnacio1,
                                INPUT par_vledvmt1,
                                INPUT par_vlrenme1,
                                INPUT par_nrender1,
                                INPUT par_complen1,
                                INPUT par_nrcxaps1,
                                INPUT par_inpesso1,
                                INPUT par_dtnasct1,
								INPUT par_vlrecjg1,

                                /* 2 avalista */
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
                                INPUT par_cdnacio2,
                                INPUT par_vledvmt2,
                                INPUT par_vlrenme2,
                                INPUT par_nrender2,
                                INPUT par_complen2,
                                INPUT par_nrcxaps2,
                                INPUT par_inpesso2,
                                INPUT par_dtnasct2,
								INPUT par_vlrecjg2,
                                INPUT par_dsdbeavt,
                               OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
    
    RETURN "OK".

END PROCEDURE.

PROCEDURE valor-extenso:

    /**********************************************************************/
    /** Procedure para converter valores no seu respectivo extenso       **/
    /** Baseado no programa fontes/extenso.p                             **/
    /**********************************************************************/

    DEF  INPUT PARAM par_vlnumero AS DECI DECIMALS 6                NO-UNDO.
    DEF  INPUT PARAM par_qtlinha1 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_qtlinha2 AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpextens AS CHAR                           NO-UNDO.
    
    DEF OUTPUT PARAM par_dslinha1 AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dslinha2 AS CHAR                           NO-UNDO.

    DEF VAR aux_dslinhas AS CHAR EXTENT 2                           NO-UNDO.
    DEF VAR aux_vlextens AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsextuni AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsextdz1 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsextdz2 AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsextcen AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlinteir AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlconver AS CHAR EXTENT 5                           NO-UNDO.
    DEF VAR aux_vlint001 AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlint002 AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlint003 AS CHAR                                    NO-UNDO.
    DEF VAR aux_vlint004 AS CHAR                                    NO-UNDO.
    DEF VAR hlp_dsextens AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsvsobra AS CHAR                                    NO-UNDO.
 
    DEF VAR aux_ingrandz AS INTE                                    NO-UNDO.
    DEF VAR aux_vlposatu AS INTE                                    NO-UNDO.
    DEF VAR aux_vlposant AS INTE                                    NO-UNDO.
    DEF VAR aux_caracter AS INTE                                    NO-UNDO.
    DEF VAR aux_contador AS INTE                                    NO-UNDO.
    DEF VAR aux_vldecima AS INTE                                    NO-UNDO.
    DEF VAR aux_qtlinhas AS INTE EXTENT 2                           NO-UNDO.
    DEF VAR aux_inlinhas AS INTE                                    NO-UNDO.
 
    DEF VAR flg_doisbran AS LOGI                                    NO-UNDO.
    
    IF  NOT CAN-DO("P,M,I",par_tpextens)  THEN
        DO:
            ASSIGN par_dslinha1 = "TIPO DE PARAMETRO ERRADO".
            RETURN "NOK".
        END.

    IF  par_vlnumero = 0 AND par_tpextens = "P"  THEN
        DO:
            ASSIGN par_dslinha1 = "SEM INDICE PERCENTUAL".
            RETURN "NOK".
        END.

    IF  par_vlnumero = 0 AND par_tpextens = "I"  THEN
        DO:
            ASSIGN par_dslinha1 = "ZERO".
            RETURN "NOK".
        END.

    IF  par_vlnumero = 0               OR
        par_vlnumero > 99999999999.99  THEN
        DO:
            ASSIGN par_dslinha1 = "VALOR ZERADO OU MUITO GRANDE PARA GERAR O " +
                                  "EXTENSO".
            RETURN "NOK".
        END.

    IF  INTE(SUBSTR(STRING(par_vlnumero,"999999999999.99"),14,02)) > 0  AND
        par_tpextens = "I"                                              THEN
        DO:
            ASSIGN par_dslinha1 = "VALOR COM DECIMAIS, NAO COMPATIVEL COM " +
                                  "NUMEROS INTEIROS".
            RETURN "NOK".
        END.

   /*  Lucas R. comentado para usar no calculo do cet dos limites de credito
    IF  par_vlnumero > 100 AND par_tpextens = "P"  THEN
        DO:
            ASSIGN par_dslinha1 = "INDICE PERCENTUAL ACIMA DO LIMITE".
            RETURN "NOK".
        END. */

    ASSIGN aux_dsextuni = "UM ,DOIS ,TRES ,QUATRO ,CINCO ,SEIS ,SETE ,OITO ," +
                          "NOVE "
           aux_dsextdz1 = "DEZ ,VINTE ,TRINTA ,QUARENTA ,CINQUENTA ,SESSENTA " +
                          ",SETENTA ,OITENTA ,NOVENTA "
           aux_dsextdz2 = "DEZ ,ONZE ,DOZE ,TREZE ,QUATORZE ,QUINZE ," +
                          "DEZESSEIS ,DEZESSETE ,DEZOITO ,DEZENOVE "
           aux_dsextcen = "CENTO ,DUZENTOS ,TREZENTOS ,QUATROCENTOS ," +
                          "QUINHENTOS ,SEISCENTOS ,SETECENTOS ,OITOCENTOS " +
                          ",NOVECENTOS "
           aux_vlinteir = SUBSTR(STRING(par_vlnumero,"999999999999.99"),01,12)
           aux_vldecima = INTE(SUBSTR(STRING(par_vlnumero,"999999999999.99"),
                                      14,02))
           aux_vlextens = ""
           aux_vlconver[1] = SUBSTR(STRING(par_vlnumero,"999999999999.99"),
                                    01,03)
           aux_vlconver[2] = SUBSTR(STRING(par_vlnumero,"999999999999.99"),
                                    04,03)
           aux_vlconver[3] = SUBSTR(STRING(par_vlnumero,"999999999999.99"),
                                    07,03)
           aux_vlconver[4] = SUBSTR(STRING(par_vlnumero,"999999999999.99"),
                                    10,03)
           aux_vlconver[5] = "0" +  
                             SUBSTR(STRING(par_vlnumero,"999999999999.99"),
                                    14,02)
           aux_qtlinhas[1] = par_qtlinha1
           aux_qtlinhas[2] = par_qtlinha2.

    DO aux_ingrandz = 1 TO 5:

        ASSIGN aux_vlint001 = SUBSTR(aux_vlconver[aux_ingrandz],1,1)
               aux_vlint002 = SUBSTR(aux_vlconver[aux_ingrandz],2,1)
               aux_vlint003 = SUBSTR(aux_vlconver[aux_ingrandz],3,1)
               aux_vlint004 = SUBSTR(aux_vlconver[aux_ingrandz],2,2).

        IF  INTE(aux_vlint001) > 0  THEN
            DO:
                IF  aux_vlint001 = "1" AND aux_vlint004 = "00"  THEN
                    aux_vlextens = aux_vlextens + "CEM ".
                ELSE
                    aux_vlextens = aux_vlextens +
                                   ENTRY(INTE(aux_vlint001),aux_dsextcen).
            END.
            
        IF  INTE(aux_vlint004) >= 10 AND INTE(aux_vlint004) <= 19  THEN
            DO:
                IF  aux_ingrandz = 5 AND aux_vlextens <> ""  THEN
                    aux_vlextens = aux_vlextens + "E " +
                                   IF  par_tpextens = "P"   AND 
                                       aux_vlint004 = "10"  THEN
                                       ""
                                   ELSE
                                       ENTRY(INTE(aux_vlint004) - 9,
                                             aux_dsextdz2).
                ELSE
                    aux_vlextens = aux_vlextens + 
                                  (IF  aux_vlint001 <> "0"  THEN
                                       "E " 
                                   ELSE 
                                       "") +
                                   IF  par_tpextens = "P"   AND
                                       aux_vlint004 = "10"  THEN 
                                       "" 
                                   ELSE
                                       ENTRY(INTE(aux_vlint004) - 9,
                                             aux_dsextdz2).
            END. 

        IF  INTE(aux_vlint002) >= 2  THEN
            DO:
                IF  aux_ingrandz = 5 AND aux_vlextens <> ""  THEN
                    aux_vlextens = aux_vlextens + "E " +
                                  (IF  par_tpextens = "P"                   AND
                                       CAN-DO("10,20,30,40,50,60,70,80,90",
                                              aux_vlint004)                 THEN
                                       ""
                                   ELSE
                                       ENTRY(INTE(aux_vlint002),aux_dsextdz1)).
                ELSE
                    aux_vlextens = aux_vlextens +
                                  (IF  aux_vlint001 <> "0"  THEN  
                                       "E " 
                                   ELSE 
                                       "") +
                                  (IF  par_tpextens = "P"    AND
                                       CAN-DO("10,20,30,40,50,60,70,80,90",
                                              aux_vlint004)  AND
                                      (aux_vlint002 = "0"    OR 
                                       aux_vlextens = "")    THEN
                                       "" 
                                   ELSE
                                       ENTRY(INTE(aux_vlint002),aux_dsextdz1)).
            END.  

        IF  CAN-DO("10,20,30,40,50,60,70,80,90",aux_vlint004)  AND
            par_tpextens = "P"                                 THEN
            aux_vlextens = aux_vlextens + 
                          (IF  aux_ingrandz = 5  THEN
                               ENTRY(INTE(SUBSTR(aux_vlint004,1,1)),
                                     aux_dsextuni)
                           ELSE  
                               ENTRY(INTE(SUBSTR(aux_vlint004,1,1)),
                                     aux_dsextdz1)).

        IF  INTE(aux_vlint003) > 0    AND
           (INTE(aux_vlint004) < 10   OR
            INTE(aux_vlint004) > 19)  THEN
            DO:
                IF  aux_ingrandz = 5 AND aux_vlextens <> ""  THEN
                    aux_vlextens = aux_vlextens + "E " +
                                   ENTRY(INTE(aux_vlint003),aux_dsextuni).
                ELSE
                    aux_vlextens = aux_vlextens + 
                                  (IF (aux_vlint001 <> "0"   OR
                                       aux_vlint002 <> "0")  THEN
                                       "E " 
                                   ELSE 
                                       "") +
                                   ENTRY(INTE(aux_vlint003),aux_dsextuni).
            END.
            
        IF  aux_ingrandz = 1  THEN /** Grandeza 1 - para o bilhao **/
            DO:
                IF  INTE(aux_vlconver[aux_ingrandz]) > 0  THEN
                    aux_vlextens = aux_vlextens +
                                   IF  INTE(aux_vlconver[aux_ingrandz]) > 1 THEN
                                       "BILHOES, " ELSE "BILHAO, ".
            END.
        ELSE
        IF  aux_ingrandz = 2  THEN /** Grandeza 2 - para o milhao **/
            DO:
                IF  INTE(aux_vlconver[aux_ingrandz]) > 0  THEN
                    aux_vlextens = aux_vlextens +
                                   IF  INTE(aux_vlconver[aux_ingrandz]) > 1 THEN
                                       "MILHOES, " ELSE "MILHAO, ".
            END.
        ELSE
        IF  aux_ingrandz = 3  THEN /** Grandeza 3 - para o milhar **/
            DO:
                IF  INTE(aux_vlconver[aux_ingrandz]) > 0  THEN
                    aux_vlextens = aux_vlextens +
                                   IF  INTE(aux_vlconver[aux_ingrandz]) > 0 THEN
                                       "MIL, " ELSE "".
            END.
        ELSE
        IF  aux_ingrandz = 4  THEN /** Grandeza 4 - para a centena **/
            DO:
                IF  DECI(aux_vlinteir) > 0  THEN
                    DO:
                        IF  DECI(aux_vlinteir) = 1  THEN
                            aux_vlextens = aux_vlextens +
                                           IF  par_tpextens = "M"  THEN
                                               "REAL "
                                           ELSE
                                           IF  par_tpextens = "P"  AND
                                               aux_vldecima > 0    THEN
                                               "INTEIRO "
                                           ELSE
                                           IF  par_tpextens = "P"  AND
                                               aux_vldecima = 0    THEN
                                               "POR CENTO "
                                           ELSE 
                                               "".
                        ELSE
                            aux_vlextens = aux_vlextens +
                                           IF  par_tpextens = "M"  THEN
                                               "REAIS "
                                           ELSE
                                           IF  par_tpextens = "P"  AND
                                               aux_vldecima > 0    THEN
                                               "INTEIROS "
                                           ELSE
                                           IF  par_tpextens = "P"  AND
                                               aux_vldecima = 0    THEN
                                               "POR CENTO "
                                           ELSE 
                                               "".
                    END.
            END.
        ELSE
        IF  aux_ingrandz = 5  THEN /** Grandeza 5 - para o centavo **/
            IF  INTE(aux_vlint004) > 0  THEN
                aux_vlextens = aux_vlextens +
                               IF  par_tpextens = "M"         AND
                                   INTE(aux_vlint004) > 1  THEN
                                   "CENTAVOS"
                               ELSE
                               IF  par_tpextens = "M"         AND
                                   INTE(aux_vlint004) = 1  THEN
                                   "CENTAVO"
                               ELSE
                               IF  par_tpextens = "P"                 AND
                                   SUBSTR(STRING(aux_vldecima,"99"),
                                   1,2) = "10"                        THEN
                                   "DECIMO POR CENTO"
                               ELSE
                               IF  par_tpextens = "P"                 AND
                                   SUBSTR(STRING(aux_vldecima,"99"),
                                   2,1) = "0"                         THEN
                                   "DECIMOS POR CENTO"
                               ELSE
                               IF  par_tpextens = "P"                 AND
                                   SUBSTR(STRING(aux_vldecima,"99"),
                                   1,2) = "01"                        THEN
                                   "CENTESIMO POR CENTO"
                               ELSE
                               IF  par_tpextens = "P" AND aux_vldecima > 1  THEN
                                   "CENTESIMOS POR CENTO"
                               ELSE 
                                   "".

    END. /** Fim do DO .. TO **/

    ASSIGN aux_inlinhas = 1.

    DO WHILE TRUE:
     
        ASSIGN aux_dsvsobra = aux_vlextens.

        IF  LENGTH(aux_vlextens) <= aux_qtlinhas[aux_inlinhas]  THEN
            ASSIGN aux_dslinhas[aux_inlinhas] = aux_vlextens
                   aux_dsvsobra               = "".
        ELSE
            DO:
                ASSIGN aux_dslinhas[aux_inlinhas] = SUBSTR(aux_vlextens,1,
                                                    par_qtlinha1 + 1) + "."
                       aux_vlposatu = R-INDEX(aux_dslinhas[aux_inlinhas]," ")
                       aux_vlposant = R-INDEX(aux_dslinhas[aux_inlinhas],"-").

                IF  aux_vlposatu  > aux_qtlinhas[aux_inlinhas]  THEN
                    aux_vlposant = 0.

                IF  aux_vlposatu > aux_vlposant  THEN
                    aux_caracter = aux_vlposatu.
                ELSE
                    aux_caracter = aux_vlposant.

                ASSIGN aux_dslinhas[aux_inlinhas] = SUBSTR(aux_vlextens,1,
                                                           aux_caracter)
                       aux_dsvsobra = SUBSTR(aux_vlextens,aux_caracter + 1).
            END.

        ASSIGN aux_dslinhas[aux_inlinhas] = TRIM(aux_dslinhas[aux_inlinhas])
               aux_contador = 1.

        DO WHILE aux_contador < LENGTH(aux_dslinhas[aux_inlinhas]):

            IF  SUBSTR(aux_dslinhas[aux_inlinhas],aux_contador,1) = ","  AND
                SUBSTR(aux_dslinhas[aux_inlinhas],
                       aux_contador + 2,5) = "REAIS"                     THEN
                DO:
                    hlp_dsextens = SUBSTR(aux_dslinhas[aux_inlinhas],
                                          aux_contador + 1,
                                          LENGTH(aux_dslinhas[aux_inlinhas]) - 
                                                 aux_contador).
           
                    IF  SUBSTR(aux_dslinhas[aux_inlinhas],
                        aux_contador - 1,1) = "L"           THEN
                        aux_dslinhas[aux_inlinhas] =                                             SUBSTR(aux_dslinhas[aux_inlinhas],
                                             1,aux_contador - 1) + hlp_dsextens.
                    ELSE
                        aux_dslinhas[aux_inlinhas] = 
                                             SUBSTR(aux_dslinhas[aux_inlinhas],
                                             1,aux_contador - 1) + " DE" + 
                                             hlp_dsextens.

                    LEAVE.

                END. 

            aux_contador = aux_contador + 1.

        END. /** Fim do DO WHILE **/ 

        ASSIGN flg_doisbran = FALSE
               aux_contador = 1.

        DO WHILE LENGTH(aux_dslinhas[aux_inlinhas]) < aux_qtlinhas[aux_inlinhas]
           AND NOT flg_doisbran AND LENGTH(aux_dsvsobra) > 0:

            DO WHILE aux_contador < LENGTH(aux_dslinhas[aux_inlinhas]):

                IF  SUBSTR(aux_dslinhas[aux_inlinhas],aux_contador,1) = " " AND
                    SUBSTR(aux_dslinhas[aux_inlinhas],aux_contador - 
                           1,2) <> "  "                                     THEN

                    DO:
                        ASSIGN hlp_dsextens = SUBSTR(aux_dslinhas[aux_inlinhas],
                                           aux_contador,
                                           LENGTH(aux_dslinhas[aux_inlinhas]) -
                                           aux_contador + 1)
                               aux_dslinhas[aux_inlinhas] =
                                           SUBSTR(aux_dslinhas[aux_inlinhas],
                                                  1,aux_contador) +
                                           hlp_dsextens
                               aux_contador = aux_contador + 2.

                        LEAVE.
                    END.
                ELSE
                IF  SUBSTR(aux_dslinhas[aux_inlinhas],aux_contador,1) = " " AND
                    SUBSTR(aux_dslinhas[aux_inlinhas],aux_contador - 1,
                           1) = " "                                         THEN
                    aux_contador = aux_contador + 2.

                aux_contador = aux_contador + 1.

            END. /** Fim do DO WHILE **/

            IF  aux_contador >= LENGTH(aux_dslinhas[aux_inlinhas])  THEN
                flg_doisbran = TRUE.

        END. /** Fim do DO WHILE **/

        IF  par_tpextens = "M"                     AND
            LENGTH(aux_dslinhas[aux_inlinhas]) <> 
            aux_qtlinhas[aux_inlinhas]             THEN
            aux_dslinhas[aux_inlinhas] = aux_dslinhas[aux_inlinhas] +
                                         FILL("*",aux_qtlinhas[aux_inlinhas] - 
                                         LENGTH(aux_dslinhas[aux_inlinhas])).
        
        IF  LENGTH(aux_dsvsobra) > 0  AND 
            aux_inlinhas = 1          THEN
            DO:
                ASSIGN aux_inlinhas = 2
                       aux_vlextens = aux_dsvsobra.
                NEXT.
            END.

        LEAVE.
        
    END.

    ASSIGN par_dslinha1 = aux_dslinhas[1]
           par_dslinha2 = IF  aux_inlinhas = 1 AND par_tpextens = "M"  THEN
                              FILL("*",par_qtlinha2)
                          ELSE
                              aux_dslinhas[2].

    RETURN "OK".
                           
END PROCEDURE.

PROCEDURE divide-nome-coop:
  
    /***********************************************************************/
    /** Procedure para dividir nome da cooperativa em duas strings        **/
    /***********************************************************************/  
      
    DEF  INPUT PARAM par_nmextcop AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_nmrecop1 AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmrecop2 AS CHAR                           NO-UNDO.

    DEF VAR aux_qtpalavr AS INTE                                    NO-UNDO.
    DEF VAR aux_contapal AS INTE                                    NO-UNDO.

    ASSIGN aux_qtpalavr = NUM-ENTRIES(TRIM(par_nmextcop)," ") / 2.

    DO aux_contapal = 1 TO NUM-ENTRIES(TRIM(par_nmextcop)," "):
      
        IF  aux_contapal <= aux_qtpalavr  THEN
            ASSIGN par_nmrecop1 = par_nmrecop1 +
                                 (IF  TRIM(par_nmrecop1) = ""  THEN 
                                      "" 
                                  ELSE 
                                      " ") +
                                  ENTRY(aux_contapal,par_nmextcop," ").
        ELSE
            ASSIGN par_nmrecop2 = par_nmrecop2 +
                                 (IF  TRIM(par_nmrecop2) = ""  THEN
                                      "" 
                                  ELSE 
                                      " ") + 
                                  ENTRY(aux_contapal,par_nmextcop," ").

    END. /** Fim do DO ... TO **/ 

    ASSIGN par_nmrecop1 = FILL(" ",20 - INTE(LENGTH(par_nmrecop1) / 2)) +
                          par_nmrecop1
           par_nmrecop2 = FILL(" ",20 - INTE(LENGTH(par_nmrecop2) / 2)) +
                          par_nmrecop2.

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE valida-cpf-cnpj:

    /**********************************************************************/
    /** Procedure para validar numero de CPF ou CNPJ                     **/
    /** Baseado no programa fontes/cpfcgc.p                              **/
    /**********************************************************************/

    DEF  INPUT PARAM par_nrcalcul AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_stsnrcal AS LOGI                           NO-UNDO.
    DEF OUTPUT PARAM par_inpessoa AS INTE                           NO-UNDO.

    ASSIGN par_stsnrcal = FALSE
           par_inpessoa = 1.

    /* 9571 = Banco do Brasil, estava sendo invalidado em cadastro de sacado
       retirado dia 15/10/2012 
    
    IF  par_nrcalcul = 9571  THEN
        DO:
            ASSIGN par_stsnrcal = FALSE
                   par_inpessoa = 1. /** Valor Default **/
            
            RETURN "OK".
        END.
    */
    IF  LENGTH(STRING(par_nrcalcul)) > 11  THEN
        DO:
            par_inpessoa = 2.
            
            RUN valida-cnpj (INPUT par_nrcalcul,
                            OUTPUT par_stsnrcal).
        END.
    ELSE
        DO:
            RUN valida-cpf (INPUT par_nrcalcul,
                           OUTPUT par_stsnrcal).

            IF  NOT par_stsnrcal  THEN
                DO:
                    RUN valida-cnpj (INPUT par_nrcalcul,
                                    OUTPUT par_stsnrcal).

                    IF  par_stsnrcal  THEN
                        par_inpessoa = 2.
                END.
            ELSE
                par_inpessoa = 1.
        END.
    
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE valida-cnpj:

    /**********************************************************************/
    /** Procedure para validar numero de CNPJ                            **/
    /** Baseado no programa fontes/cgcfun.p                              **/
    /**********************************************************************/

    DEF  INPUT PARAM par_nrcalcul AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_stsnrcal AS LOGI                           NO-UNDO.

    DEF VAR aux_nrdigito AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_nrposica AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_vlrdpeso AS INTE INIT 2                             NO-UNDO.
    DEF VAR aux_vlcalcul AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_vldresto AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_vlresult AS INTE INIT 0                             NO-UNDO.

    IF  LENGTH(STRING(par_nrcalcul)) < 3  THEN
        DO:
            ASSIGN par_stsnrcal = FALSE.
            RETURN "OK".
        END.

    ASSIGN aux_vlcalcul = INTE(SUBSTR(STRING(par_nrcalcul,">>>>>>>>>>>>>9"),
                                      1,1)) * 2
           aux_vlresult = INTE(SUBSTR(STRING(par_nrcalcul,">>>>>>>>>>>>>9"),
                                      2,1)) +
                          INTE(SUBSTR(STRING(par_nrcalcul,">>>>>>>>>>>>>9"),
                                      4,1)) +
                          INTE(SUBSTR(STRING(par_nrcalcul,">>>>>>>>>>>>>9"),
                                      6,1)) +
                          INTE(SUBSTR(STRING(aux_vlcalcul),1,1)) +
                          INTE(SUBSTR(STRING(aux_vlcalcul),2,1))
           aux_vlcalcul = INTE(SUBSTR(STRING(par_nrcalcul,">>>>>>>>>>>>>9"),
                                      3,1)) * 2
           aux_vlresult = aux_vlresult + 
                          INTE(SUBSTR(STRING(aux_vlcalcul),1,1)) +
                          INTE(SUBSTR(STRING(aux_vlcalcul),2,1))
           aux_vlcalcul = INTE(SUBSTR(STRING(par_nrcalcul,">>>>>>>>>>>>>9"),
                                      5,1)) * 2
           aux_vlresult = aux_vlresult +
                          INTE(SUBSTR(STRING(aux_vlcalcul),1,1)) +
                          INTE(SUBSTR(STRING(aux_vlcalcul),2,1))
           aux_vlcalcul = INTE(SUBSTR(STRING(par_nrcalcul,">>>>>>>>>>>>>9"),
                                      7,1)) * 2
           aux_vlresult = aux_vlresult +
                          INTE(SUBSTR(STRING(aux_vlcalcul),1,1)) +
                          INTE(SUBSTR(STRING(aux_vlcalcul),2,1))
           aux_vldresto = aux_vlresult MODULO 10.

    IF  aux_vldresto = 0  THEN
        ASSIGN aux_nrdigito = aux_vldresto.
    ELSE
        ASSIGN aux_nrdigito = 10 - aux_vldresto.

    ASSIGN aux_vlcalcul = 0.

    DO aux_nrposica = (LENGTH(STRING(par_nrcalcul)) - 2) TO 1 BY -1:
    
        ASSIGN aux_vlcalcul = aux_vlcalcul + (INTE(SUBSTR(STRING(par_nrcalcul),
                                              aux_nrposica,1)) * aux_vlrdpeso)
               aux_vlrdpeso = aux_vlrdpeso + 1.

        IF  aux_vlrdpeso > 9  THEN
            ASSIGN aux_vlrdpeso = 2.

    END. /** Fim do DO ... TO **/

    ASSIGN aux_vldresto = aux_vlcalcul MODULO 11.

    IF  aux_vldresto < 2  THEN
        ASSIGN aux_nrdigito = 0.
    ELSE
        ASSIGN aux_nrdigito = 11 - aux_vldresto.

    IF  (INTE(SUBSTR(STRING(par_nrcalcul),
              LENGTH(STRING(par_nrcalcul)) - 1,1))) <> aux_nrdigito  THEN
        DO:
            ASSIGN par_stsnrcal = FALSE.
            RETURN "OK".
        END.

    ASSIGN aux_vlrdpeso = 2
           aux_nrposica = 0
           aux_vlcalcul = 0.

    DO aux_nrposica = (LENGTH(STRING(par_nrcalcul)) - 1) TO 1 BY -1:

        ASSIGN aux_vlcalcul = aux_vlcalcul + (INTE(SUBSTR(STRING(par_nrcalcul),
                                              aux_nrposica,1)) * aux_vlrdpeso)
               aux_vlrdpeso = aux_vlrdpeso + 1.

        IF  aux_vlrdpeso > 9  THEN
            ASSIGN aux_vlrdpeso = 2.

    END. /** Fim do DO ... TO **/

    ASSIGN aux_vldresto = aux_vlcalcul MODULO 11.

    IF  aux_vldresto < 2  THEN
        ASSIGN aux_nrdigito = 0.
    ELSE
        ASSIGN aux_nrdigito = 11 - aux_vldresto.

    IF  (INTE(SUBSTR(STRING(par_nrcalcul),
              LENGTH(STRING(par_nrcalcul)),1))) <> aux_nrdigito  THEN
        ASSIGN par_stsnrcal = FALSE.
    ELSE
        ASSIGN par_stsnrcal = TRUE.    
    
    RETURN "OK".
    
END PROCEDURE.

PROCEDURE valida-cpf:

    /**********************************************************************/
    /** Procedure para validar numero de CPF                             **/
    /** Baseado no programa fontes/cpffun.p                              **/
    /**********************************************************************/

    DEF  INPUT PARAM par_nrcalcul AS DECI                           NO-UNDO.
    
    DEF OUTPUT PARAM par_stsnrcal AS LOGI                           NO-UNDO.

    DEF VAR aux_nrdigito AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_nrposica AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_vlrdpeso AS INTE INIT 2                             NO-UNDO.
    DEF VAR aux_vlcalcul AS INTE INIT 0                             NO-UNDO.
    DEF VAR aux_vldresto AS INTE INIT 0                             NO-UNDO.

    IF  LENGTH(STRING(par_nrcalcul)) < 5  OR
        CAN-DO("11111111111,22222222222,33333333333,44444444444,55555555555," +
               "66666666666,77777777777,88888888888,99999999999",
               STRING(par_nrcalcul))      THEN
        DO:
            ASSIGN par_stsnrcal = FALSE.
            RETURN "OK".
        END.

    ASSIGN aux_vlrdpeso = 9
           aux_nrposica = 0
           aux_vlcalcul = 0.

    DO aux_nrposica = (LENGTH(STRING(par_nrcalcul)) - 2) TO 1 BY -1:

        ASSIGN aux_vlcalcul = aux_vlcalcul + (INTE(SUBSTR(STRING(par_nrcalcul),
                                              aux_nrposica,1)) * aux_vlrdpeso)
               aux_vlrdpeso = aux_vlrdpeso - 1.

    END. /** Fim do DO ... TO **/

    ASSIGN aux_vldresto = aux_vlcalcul MODULO 11.

    IF  aux_vldresto = 10  THEN
        ASSIGN aux_nrdigito = 0.
    ELSE
        ASSIGN aux_nrdigito = aux_vldresto.

    ASSIGN aux_vlrdpeso = 8
           aux_nrposica = 0
           aux_vlcalcul = aux_nrdigito * 9.

    DO aux_nrposica = (LENGTH(STRING(par_nrcalcul)) - 2) TO 1 BY -1:

        ASSIGN aux_vlcalcul = aux_vlcalcul + (INTE(SUBSTR(STRING(par_nrcalcul),
                                              aux_nrposica,1)) * aux_vlrdpeso)
               aux_vlrdpeso = aux_vlrdpeso - 1.

    END. /** Fim do DO ... TO **/

    ASSIGN aux_vldresto = aux_vlcalcul MODULO 11.

    IF  aux_vldresto = 10  THEN
        ASSIGN aux_nrdigito = aux_nrdigito * 10.      
    ELSE
        ASSIGN aux_nrdigito = (aux_nrdigito * 10) + aux_vldresto.

    IF  (INTE(SUBSTR(STRING(par_nrcalcul),
              LENGTH(STRING(par_nrcalcul)) - 1,2))) <> aux_nrdigito  THEN
        ASSIGN par_stsnrcal = FALSE.
    ELSE
        ASSIGN par_stsnrcal = TRUE.
    
    RETURN "OK".
    
END PROCEDURE.


/*****************************************************************************/
/*          Buscar dados do cabecalho de um determinado relatorio            */
/*****************************************************************************/

PROCEDURE busca_cabrel:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdrelato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-cabrel.
    
    DEF VAR aux_nrmodulo LIKE craprel.nrmodulo.
    DEF VAR aux_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-cabrel.
    
    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcop THEN
         DO:
             ASSIGN aux_cdcritic = 651
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
                                                       
             RETURN "NOK".

         END.    
    
    CREATE tt-cabrel.
    ASSIGN tt-cabrel.nmrescop = crapcop.nmrescop.

    FIND craprel WHERE craprel.cdcooper = par_cdcooper AND 
                       craprel.cdrelato = par_cdrelato NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craprel   THEN
         ASSIGN tt-cabrel.nmrelato = FILL("?",40)
                tt-cabrel.nmdestin = ""
                aux_nrmodulo = 5.
    ELSE
         ASSIGN tt-cabrel.nmrelato = craprel.nmrelato
                tt-cabrel.nmdestin = "DESTINO: " + CAPS(craprel.nmdestin)
                aux_nrmodulo = craprel.nrmodulo.
    
    FIND crapprg WHERE crapprg.cdcooper = par_cdcooper AND
                       crapprg.cdprogra = par_cdprogra NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapprg THEN
         DO:
             ASSIGN aux_cdcritic = 145
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
                                                       
             RETURN "NOK".             
         END.

    IF   crapprg.nrsolici = 50   THEN /* TELAS */
         ASSIGN tt-cabrel.progerad = "TEL".
    ELSE
         ASSIGN tt-cabrel.progerad = 
                    STRING(SUBSTRING(STRING(par_cdprogra,"x(07)"),5,3)).
         
    ASSIGN tt-cabrel.dtmvtref = par_dtmvtolt
           tt-cabrel.nmmodulo = aux_nmmodulo[aux_nrmodulo]
           tt-cabrel.cdrelato = par_cdrelato
           tt-cabrel.dtmvtolt = aux_datdodia
           tt-cabrel.dshoraat = STRING(TIME,"HH:MM").

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/*             Buscar dados sobre IOF - baseado no includes/iof.i            */
/*****************************************************************************/
PROCEDURE busca_iof:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-iof.
    
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-iof.
    
    /*  Tabela com a taxa do IOF */
    FIND craptab WHERE craptab.cdcooper = par_cdcooper       AND
                       craptab.nmsistem = "CRED"             AND
                       craptab.tptabela = "USUARI"           AND
                       craptab.cdempres = 11                 AND
                       craptab.cdacesso = "VLIOFOPFIN"       AND
                       craptab.tpregist = 1
                       USE-INDEX craptab1 NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
             ASSIGN aux_cdcritic = 915
                    aux_dscritic = "".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
                                                       
             RETURN "NOK".
         END.
 
    CREATE tt-iof.
    ASSIGN tt-iof.dtiniiof = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                                  INT(SUBSTRING(craptab.dstextab,1,2)),
                                  INT(SUBSTRING(craptab.dstextab,7,4)))
           tt-iof.dtfimiof = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                                  INT(SUBSTRING(craptab.dstextab,12,2)),
                                  INT(SUBSTRING(craptab.dstextab,18,4)))
           tt-iof.txccdiof = IF par_dtmvtolt >= tt-iof.dtiniiof AND
                                par_dtmvtolt <= tt-iof.dtfimiof THEN
                                DECIMAL(SUBSTR(craptab.dstextab,23,14))
                             ELSE 0.
END PROCEDURE.
/*****************************************************************************/
/*                 Buscar dados sobre IOF - Simples Nacional                 */
/*****************************************************************************/
PROCEDURE busca_iof_simples_nacional:
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdacesso AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-iof-sn.
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-iof-sn.
    /*  Tabela com a taxa do IOF */
    FIND craptab WHERE craptab.cdcooper = par_cdcooper       AND
                       craptab.nmsistem = "CRED"             AND
                       craptab.tptabela = "USUARI"           AND
                       craptab.cdempres = 11                 AND
                       craptab.cdacesso = par_cdacesso       AND
                       craptab.tpregist = 1
                       USE-INDEX craptab1 NO-LOCK NO-ERROR.
    IF   NOT AVAILABLE craptab   THEN
         DO:
             ASSIGN aux_cdcritic = 915
                    aux_dscritic = "".
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             RETURN "NOK".
         END.
    CREATE tt-iof-sn.
    ASSIGN tt-iof-sn.dtiniiof = DATE(INT(SUBSTRING(craptab.dstextab,4,2)),
                                  INT(SUBSTRING(craptab.dstextab,1,2)),
                                  INT(SUBSTRING(craptab.dstextab,7,4)))
           tt-iof-sn.dtfimiof = DATE(INT(SUBSTRING(craptab.dstextab,15,2)),
                                  INT(SUBSTRING(craptab.dstextab,12,2)),
                                  INT(SUBSTRING(craptab.dstextab,18,4)))
           tt-iof-sn.txccdiof = IF par_dtmvtolt >= tt-iof.dtiniiof AND
                                par_dtmvtolt <= tt-iof.dtfimiof THEN
                                DECIMAL(SUBSTR(craptab.dstextab,23,14))
                             ELSE 0.

END PROCEDURE.


/*****************************************************************************/
/*             Criticar numeros de lote utilizados pelo sistema              */
/*****************************************************************************/
PROCEDURE critica_numero_lote: 

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdolote AS INTE                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    EMPTY TEMP-TABLE tt-erro.

    IF  (par_nrdolote > 1350   AND   /* CMC-7 e Codigo de Barras */
         par_nrdolote < 1450)  OR
         par_nrdolote = 2701   OR    /* Reajuste do limite de credito */
        (par_nrdolote > 320000 AND   /* Cash Dispenser */
         par_nrdolote < 330000) OR 
        (par_nrdolote > 3200   AND   /* Cash Dispenser */
         par_nrdolote < 3300)  OR 
         par_nrdolote = 4154   OR    /* Lote de debito de seguro de vida */
         par_nrdolote = 4500   OR    /* Lote de liberacao de custodia  */
         par_nrdolote = 4501   OR    /* Lote de liberacao de cheq. descontos  */
         par_nrdolote = 4600   OR    /* Lote de liberacao de titulos  */
         par_nrdolote = 4650   OR    /* Lote de devolucao de cheques  */
        (par_nrdolote > 5010   AND
         par_nrdolote < 6000)  OR    /* Creditos de emprestimos */
        (par_nrdolote > 6599   AND   /* Integracao telesc/samae/etc  */
         par_nrdolote < 6626)  OR
         par_nrdolote = 7000   OR    /* Transferencia de conta-corrente */
        (par_nrdolote > 7000   AND   /* Compensacao do Banco do Brasil */
         par_nrdolote < 7010)  OR
        (par_nrdolote > 7010   AND   /* Compensacao Bancoob */
         par_nrdolote < 7020)  OR
        (par_nrdolote > 7020   AND   /* Compensacao Caixa */
         par_nrdolote < 7030)  OR
        (par_nrdolote > 7099   AND   /* Transf. de cheque salario p/vala */
         par_nrdolote < 7200)  OR
         par_nrdolote = 7200   OR    /* Baixa de saldo de c/c dos demitidos */
		 par_nrdolote = 7600   OR    /* Lote devolucao contra-ordem */
         par_nrdolote = 8001   OR    /* Capital Inicial */
         par_nrdolote = 8002   OR    /* Transferencia de capital */
         par_nrdolote = 8003   OR    /* Correcao monetaria */
         par_nrdolote = 8004   OR    /* Credito de juros sobre capital */
         par_nrdolote = 8005   OR    /* Para credito de RETORNO E CMI */
         par_nrdolote = 8006   OR    /* Baixa de saldo de capital dos dem. */
         par_nrdolote = 8007   OR    /* Ajuste de C.M. na final do trimestre */
         par_nrdolote = 8008   OR    /* Transferencia de Conta(TELA TRANSF)*/
         par_nrdolote = 8350   OR    /* Sobras de emprestimos */
         par_nrdolote = 8351   OR    /* Sobras de emprestimos no c/c */
         par_nrdolote = 8360   OR    /* Juros de emprestimos */
         par_nrdolote = 8361   OR    /* Juros sobre prejuizos */
         par_nrdolote = 8370   OR    /* Abono de emprestimos */
         par_nrdolote = 8380   OR    /* Rendimento de Aplicacoes RDCA */
         par_nrdolote = 8381   OR    /* Rendimento Ref Resgates RDCA */
         par_nrdolote = 8382   OR    /* Rendimento Ref Resgates RDCA */
         par_nrdolote = 8383   OR    /* Provisao Mensal de Rendim. RPP */
         par_nrdolote = 8384   OR    /* Rendimento e credito no RPP */
         par_nrdolote = 8390   OR    /* Resgate de Aplicacoes RDCA */
         par_nrdolote = 8391   OR    /* Perdas nos Resgates RDCA  */
         par_nrdolote = 8450   OR    /* Multa e juros de conta-corrente */
         par_nrdolote = 8451   OR    /* Devolucoes automat. por contra-ordem */
         par_nrdolote = 8452   OR    /* Tarifas  */
         par_nrdolote = 8453   OR    /* Liquidacao de Emprestimos */
         par_nrdolote = 8454   OR    /* Debito de plano em conta-corrente */
         par_nrdolote = 8455   OR    /* Credito de planos de capital */
         par_nrdolote = 8456   OR    /* C/C Cr. emp. e Db. liquidacao */
         par_nrdolote = 8457   OR    /* C/C Db. Prest. Emprestimo */
         par_nrdolote = 8458   OR    /* C/C Deb. Plano saude Bradesco Hering */
         par_nrdolote = 8459   OR    /* Debitos Credicard */
         par_nrdolote = 8460   OR    /* I.P.M.F. */
         par_nrdolote = 8461   OR    /* Abono C.P.M.F */
         par_nrdolote = 8462   OR    /* Debito em conta de convenios */
         par_nrdolote = 8463   OR    /* Lancamentos de cobranca */
         par_nrdolote = 8464   OR    /* Credito capital ref debito em conta */
         par_nrdolote = 8470   OR    /* Debitos ref. Aplicacoes Financeiras */
         par_nrdolote = 8473   OR    /* Debitos ref.Aplic. RDCA e RPP */
         par_nrdolote = 8474   OR    /* Creditos ref.Aplic. RDCA e RPP */
         par_nrdolote = 8475   OR    /* Transf. emprestimos para conta adm  */
         par_nrdolote = 8476   OR    /* Base CPMF cobertura de saldo devedor */
         par_nrdolote = 8477   OR    /* Para credito de desconto de cheques  */
        (par_nrdolote > 600000 AND   /* Novo empréstimo */
         par_nrdolote < 650000)OR    /* Novo empréstimo */
        (par_nrdolote > 8010   AND   /* Creditos de planos de capital */
         par_nrdolote < 8999)  OR      
         par_nrdolote > 9010   OR    /* Creditos de pagamento */
         par_nrdolote = 10115  OR    /* Cadastramento das devoluçoes de TED's */
         par_nrdolote = 50001  OR    /* Crédito no valor contratado em conta */
         par_nrdolote = 50002  OR    /* IOF credito pre-aprovado */
         par_nrdolote = 50003  OR    /* Tarifa do pre-aprovado */
         par_nrdolote = 6651   OR    /* Debitos nao efetuados no processo noturno */
         par_nrdolote = 6650   OR    /* Numero do lote reservado para o sistema.*/
         par_nrdolote = 6400   OR    /* Agendamento de debito automatico */
  		   par_nrdolote = 8500   OR    /* Credito de nova aplicacao            */
         par_nrdolote = 8501   OR    /* Debito de nova aplicacao             */
         par_nrdolote = 8502   OR    /* Debito de resgate de aplicacao       */
         par_nrdolote = 8503   OR    /* Credito de resgate de aplicacao      */
         par_nrdolote = 8504   OR    /* Debito de vencimento de aplicacao    */
         par_nrdolote = 8505   OR    /* Credito de vencimento de aplicacao   */
         par_nrdolote = 8506   OR    /* Credito de provisão de aplicacao     */
         par_nrdolote = 6651   OR    /* Debitos nao efetuados no processo noturno (e efetuados pela DEBCON) */
         par_nrdolote = 7050   OR    /* Debitos automaticos nao efetuados no processo noturno (apenas convenios CECRED; efetuados pela DEBNET).*/
         par_nrdolote = 650001 OR	 /* Acordos do CYBER */
		 par_nrdolote = 650002 OR    /* Acordos do CYBER */
		 par_nrdolote = 10119  OR    /* Lote devolução - Melhoria 69 */
		(par_nrdolote >= 8482   AND  /* TEDS Sicredi */
         par_nrdolote <= 8486)  OR
		 par_nrdolote = 650003 OR    /* Pagamento de contrato do Price Pos-Fixado */
         par_nrdolote = 650004 OR	 /* Pagamento de contrato do Price Pos-Fixado */
		(par_nrdolote >= 600038 AND     /*Devolucao de capital*/      
         par_nrdolote <= 600043)  OR
         par_nrdolote = 650005 OR   /* REPASSE CDC COMPARTILHADO */
         par_nrdolote = 650006 OR   /* RENOVACAO DE TARIFA CONVENIO CDC */
         par_nrdolote = 650007 OR   /* ADESAO DE TARIFA CONVENIO CDC */ 
         par_nrdolote = 650008 THEN /* REPASSE CDC COMPARTILHADO CECRED X COOPERATIVAS */   
		 
         DO:
             ASSIGN aux_cdcritic = 261
                    aux_dscritic = "".

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

/*************************************************
    Procedures para procedure quebra-str
**************************************************/    
PROCEDURE quebra-str:
DEF INPUT  PARAMETER aux_dsstring  AS CHAR                 NO-UNDO.

DEF INPUT  PARAMETER par_qtcolun1  AS INT                  NO-UNDO.
DEF INPUT  PARAMETER par_qtcolun2  AS INT                  NO-UNDO.
DEF INPUT  PARAMETER par_qtcolun3  AS INT                  NO-UNDO.
DEF INPUT  PARAMETER par_qtcolun4  AS INT                  NO-UNDO.

DEF OUTPUT PARAMETER aux_dslinha1  AS CHAR                 NO-UNDO.
DEF OUTPUT PARAMETER aux_dslinha2  AS CHAR                 NO-UNDO.
DEF OUTPUT PARAMETER aux_dslinha3  AS CHAR                 NO-UNDO.
DEF OUTPUT PARAMETER aux_dslinha4  AS CHAR                 NO-UNDO.
                                                  
ASSIGN aux_containi = 0
       aux_contafim = 0
       aux_nrocolun = 0
       aux_contalet = 0.
       
RUN Conta_Fim (INPUT par_qtcolun1, INPUT aux_dsstring).
aux_dslinha1 = TRIM(SUBSTR(aux_dsstring, aux_containi, aux_nrocolun + 1)).
RUN Justifica (INPUT aux_dslinha1, INPUT par_qtcolun1, OUTPUT aux_dslinha1).

RUN Conta_Fim (INPUT par_qtcolun2, INPUT aux_dsstring).
aux_dslinha2 = TRIM(SUBSTR(aux_dsstring, aux_containi, aux_nrocolun + 1)).
RUN Justifica (INPUT aux_dslinha2, INPUT par_qtcolun2, OUTPUT aux_dslinha2).

RUN Conta_Fim (INPUT par_qtcolun3, INPUT aux_dsstring).
aux_dslinha3 = TRIM(SUBSTR(aux_dsstring, aux_containi, aux_nrocolun + 1)).
RUN Justifica (INPUT aux_dslinha3, INPUT par_qtcolun3, OUTPUT aux_dslinha3).

RUN Conta_Fim (INPUT par_qtcolun4, INPUT aux_dsstring).
aux_dslinha4 = TRIM(SUBSTR(aux_dsstring, aux_containi, aux_nrocolun + 1)).
RUN Justifica (INPUT aux_dslinha4, INPUT par_qtcolun4, OUTPUT aux_dslinha4).

END PROCEDURE.

PROCEDURE Conta_Fim:

   DEF INPUT PARAMETER par_qtcoluna AS INT  NO-UNDO.                 
   DEF INPUT PARAMETER par_dsstring AS CHAR NO-UNDO.

   ASSIGN aux_containi = aux_contafim + 1
          aux_contafim = aux_containi + par_qtcoluna.

   DO WHILE (aux_contafim > 0) AND
            (SUBSTR(par_dsstring, aux_contafim, 1) <> " "):
            aux_contafim = aux_contafim - 1.
   END.

   aux_nrocolun = aux_contafim - aux_containi.

END.

PROCEDURE Justifica:
    
   DEF INPUT  PARAMETER aux_linhaatu   AS CHAR                    NO-UNDO.
   DEF INPUT  PARAMETER aux_qtdcolun   AS INT                     NO-UNDO.
   DEF OUTPUT PARAMETER aux_linharet   AS CHAR                    NO-UNDO.
   DEF        VAR       aux_espacobr   AS CHAR INITIAL " "        NO-UNDO.

   aux_contalet = aux_nrocolun - 1.

   IF   LENGTH(TRIM(aux_linhaatu)) > 0 THEN
        DO:
            DO WHILE (LENGTH(TRIM(aux_linhaatu)) < aux_qtdcolun) AND 
                 (aux_contalet > 0) AND 
                 (LENGTH(TRIM(aux_linhaatu)) > aux_qtdcolun / 2):
               
               IF   SUBSTR(TRIM(aux_linhaatu), aux_contalet, 1) = 
                                                           aux_espacobr THEN
                    DO:
                        aux_linhaatu = TRIM(SUBSTR(aux_linhaatu, 1, 
                                                       aux_contalet) +
                                   " " + SUBSTR(aux_linhaatu, aux_contalet + 1, 
                                   aux_qtdcolun - aux_contalet)). 
                    END.                 
         
               IF   aux_contalet > 1 THEN
                    aux_contalet = aux_contalet - 1.         
               ELSE
                    DO:
                        ASSIGN aux_contalet = aux_qtdcolun
                               aux_espacobr = aux_espacobr + " ".
                    END.
      
            END.  /*  Fim do DO WHILE  */
        END.

   aux_linharet = aux_linhaatu.

END.
/******************************************
    Final das procedures p/ quebra_str
*******************************************/    


/************************************************************************
 Procedure para calcular o faturamento medio mensal das pessoas juridicas.
************************************************************************/

PROCEDURE calcula-faturamento:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.

    DEF OUTPUT PARAM par_vlmedfat AS DECI                           NO-UNDO.

    DEF VAR          aux_contador AS INTE                           NO-UNDO.
    DEF VAR          aux_numermes AS INTE                           NO-UNDO.
    DEF VAR          aux_valormes AS DECI                           NO-UNDO.


    FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper   AND
                       crapjfn.nrdconta = par_nrdconta   
                       NO-LOCK NO-ERROR.

    IF   NOT AVAIL crapjfn   THEN
         DO:
             aux_dscritic = "Registro de dados financeiros do " +
                            "cooperado nao encontrado".
                                            
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,     /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).

             RETURN "NOK".

         END.

    DO aux_contador = 1 TO 12:

        IF   crapjfn.mesftbru[aux_contador] = 0   THEN
             NEXT.

        ASSIGN aux_numermes = aux_numermes + 1
               aux_valormes = aux_valormes + crapjfn.vlrftbru[aux_contador]. 

    END.

    IF   aux_numermes > 0   THEN
         ASSIGN par_vlmedfat = aux_valormes / aux_numermes.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************/
/** Procedure para retornar dados do usuario que esta prendendo registro de  **/
/** determinada tabela. Baseada em fontes/acha_lock.p                        **/
/******************************************************************************/
PROCEDURE acha-lock:

    DEF  INPUT PARAM par_nrdrecid AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdbanco AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmtabela AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_loginusr AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_nmusuari AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dsdevice AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM par_dtconnec AS CHAR                           NO-UNDO. 
    DEF OUTPUT PARAM par_numipusr AS CHAR                           NO-UNDO.

    DEF VAR aux_dsretcmd AS CHAR                                    NO-UNDO.
    DEF VAR aux_dscomand AS CHAR                                    NO-UNDO.

    RETURN "OK".

END PROCEDURE.

PROCEDURE Critica_Nome:

    DEF INPUT  PARAMETER par_nmdentra AS CHAR  NO-UNDO.

    DEF OUTPUT PARAMETER par_cdcritic AS INTE  NO-UNDO.

    DEF VAR aux_contador AS INT                NO-UNDO.
    DEF var aux_nmabrevi AS CHAR               NO-UNDO.
    DEF VAR aux_qtletini AS INTE               NO-UNDO.

    ASSIGN aux_nmabrevi = TRIM(par_nmdentra)
           aux_qtletini = LENGTH(aux_nmabrevi)
           par_cdcritic = 0.
        
    DO  aux_contador = 1 TO LENGTH(aux_nmabrevi):

        IF   SUBSTR(aux_nmabrevi,aux_contador,1) <> ""    AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "A"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "B"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "C"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "D"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "E"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "F"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "G"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "H"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "I"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "J"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "K"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "L"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "M"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "N"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "O"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "P"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "Q"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "R"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "S"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "T"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "U"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "V"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "X"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "W"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "Y"   AND
             SUBSTR(aux_nmabrevi,aux_contador,1) <> "Z"   THEN
             DO:
                 par_cdcritic = 835.
                 LEAVE.
             END.
    END.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/** Procedure para converter strings abreviando-as para o numero pedido     **/
/** Versao original: fontes/abreviar.p                                      **/
/*****************************************************************************/
PROCEDURE Abrevia_Nome:

    DEF INPUT  PARAMETER par_nmdentra AS CHAR  NO-UNDO.
    DEF INPUT  PARAMETER par_qtletras AS INT   NO-UNDO.

    DEF OUTPUT PARAMETER glb_nmabrevi AS CHAR  NO-UNDO.

    DEF VAR aux_contador AS INT                    NO-UNDO.
    DEF VAR aux_dsdletra AS CHAR                   NO-UNDO.

    DEF VAR aux_palavras AS CHAR EXTENT 99         NO-UNDO.
    DEF VAR aux_qtdnomes AS INT                    NO-UNDO.
    DEF VAR aux_qtletini AS INT                    NO-UNDO.
    DEF VAR aux_eliminar AS LOGICAL                NO-UNDO.
    DEF VAR aux_lssufixo AS CHAR                   NO-UNDO.
    DEF VAR aux_lsprfixo AS CHAR                   NO-UNDO.

    ASSIGN glb_nmabrevi = TRIM(par_nmdentra)
           aux_eliminar = FALSE
           aux_lssufixo = "FILHO,NETO,SOBRINHO,JUNIOR,JR."
           aux_lsprfixo = "E/OU".

    DO WHILE TRUE:

        aux_qtletini = LENGTH(glb_nmabrevi).

        IF  aux_qtletini <= par_qtletras THEN
            LEAVE.

        ASSIGN aux_palavras = ""
               aux_qtdnomes = 1.

            /* Separa os nomes */

        DO aux_contador = 1 TO LENGTH(glb_nmabrevi):

           aux_dsdletra = SUBSTR(glb_nmabrevi,aux_contador,1).

           IF   aux_dsdletra <> " " THEN
                aux_palavras[aux_qtdnomes] = aux_palavras[aux_qtdnomes] +
                                             aux_dsdletra.
           ELSE
                aux_qtdnomes = aux_qtdnomes + 1.

        END.

        IF  CAN-DO(aux_lsprfixo,TRIM(aux_palavras[1])) THEN
            DO:
               aux_palavras[1] = aux_palavras[1] + " " + aux_palavras[2].

               DO  aux_contador = 2 TO aux_qtdnomes:

                   aux_palavras[aux_contador] = aux_palavras[aux_contador + 1].

               END.       

               ASSIGN aux_palavras[aux_qtdnomes] = ""
                      aux_qtdnomes = aux_qtdnomes - 1.

            END.

        IF  CAN-DO(aux_lssufixo,TRIM(aux_palavras[aux_qtdnomes])) THEN
            DO:

               IF   aux_palavras[aux_qtdnomes] = "JUNIOR" THEN
                    aux_palavras[aux_qtdnomes] = "JR.".

               ASSIGN aux_palavras[aux_qtdnomes - 1] =
                          aux_palavras[aux_qtdnomes - 1] + " " +
                          aux_palavras[aux_qtdnomes]

               aux_palavras[aux_qtdnomes] = ""
               aux_qtdnomes = aux_qtdnomes - 1.

            END.

        glb_nmabrevi = "".

        DO aux_contador = 1 TO aux_qtdnomes.

           glb_nmabrevi = glb_nmabrevi + (IF   aux_contador <> 1
                                         THEN " "
                                         ELSE "")
                                         + aux_palavras[aux_contador].

        END.

        IF   aux_qtdnomes < 3 THEN
             LEAVE.

        ASSIGN glb_nmabrevi = aux_palavras[1]
               aux_contador = 2.

        DO WHILE TRUE:

           IF  LENGTH(aux_palavras[aux_contador]) > 2 THEN
               DO:
                  glb_nmabrevi = glb_nmabrevi + " " +
                                 SUBSTR(aux_palavras[aux_contador],1,1) + ".".
                  LEAVE.
               END.
           ELSE
               IF  aux_eliminar THEN
                   aux_eliminar = FALSE.
               ELSE
                   glb_nmabrevi = glb_nmabrevi + " " +
                                  aux_palavras[aux_contador].

           aux_contador = aux_contador + 1.

           IF  aux_contador >= aux_qtdnomes  THEN
               DO:
                   aux_contador = aux_contador - 1.
                   LEAVE.
               END.

        END.

        DO aux_contador = (aux_contador + 1) TO aux_qtdnomes.

           glb_nmabrevi = glb_nmabrevi + " "  + aux_palavras[aux_contador].

        END.

        IF  aux_qtletini = LENGTH(glb_nmabrevi) THEN
            IF   aux_qtdnomes > 2 THEN
                 aux_eliminar = TRUE.
            ELSE
                 LEAVE.

    END.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************/
/**  Calcular a partir do numero do cheque o numero do talao e a posicao    **/
/**         do cheque dentro do mesmo.                                      **/
/**  Versao original: fontes/numtal.p                                       **/
/*****************************************************************************/
PROCEDURE num-tal:

    DEFINE  INPUT PARAM par_nrcalcul AS DECI                           NO-UNDO.
    DEFINE  INPUT PARAM par_nrfolhas AS INTE                           NO-UNDO.
    DEFINE OUTPUT PARAM par_nrtalchq AS INTE                           NO-UNDO.
    DEFINE OUTPUT PARAM par_nrposchq AS INTE                           NO-UNDO.
                                                
    DEF VAR aux_calculo  AS INT                                        NO-UNDO.
    DEF VAR aux_resto    AS INT                                        NO-UNDO.

    IF  par_nrfolhas = 0   THEN
        par_nrfolhas = 20.
    
    ASSIGN aux_calculo  = TRUNCATE(INTEGER(SUBSTRING(STRING(par_nrcalcul,
                                           "zzzzzzz9"),1,7)) / par_nrfolhas,0)
    
           aux_resto    = INTEGER(SUBSTRING(STRING(par_nrcalcul,
                                            "zzzzzzz9"),1,7)) MOD par_nrfolhas
    
           par_nrtalchq = IF aux_resto = 0 THEN aux_calculo  ELSE aux_calculo + 1
    
           par_nrposchq = IF aux_resto = 0 THEN par_nrfolhas ELSE aux_resto.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE listal-consulta-cheques:
    
    DEF INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_cdcoptel LIKE crapcop.cdcooper                 NO-UNDO.
    DEF INPUT PARAM par_insitreq LIKE crapreq.insitreq                 NO-UNDO.
    DEF INPUT PARAM par_tprequis LIKE crapreq.tprequis                 NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                               NO-UNDO.
    DEF INPUT PARAM par_dtinicio LIKE crapreq.dtmvtolt                 NO-UNDO.
    DEF INPUT PARAM par_dttermin LIKE crapreq.dtmvtolt                 NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-listal.

    DEF VAR aux_qtdreqtal AS INTE FORMAT "zzz"                         NO-UNDO.
    DEF VAR aux_qtdflsa4  AS INTE FORMAT "zzz"                         NO-UNDO.

    
    IF  NOT CAN-DO("T,I",par_cddopcao) THEN DO:
        ASSIGN aux_cdcritic = 14 
               aux_dscritic = "".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    IF  par_cdcoptel <> 0 THEN DO:
        FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcoptel
                              NO-LOCK NO-ERROR.

         IF NOT AVAIL crapcop THEN DO:
            ASSIGN aux_cdcritic = 0 
                   aux_dscritic = "Cooperativa nao encontrada.".
    
            RUN gera_erro (INPUT par_cdcooper,
                           INPUT 0,
                           INPUT 0,
                           INPUT 1, /*sequencia*/
                           INPUT aux_cdcritic,
                           INPUT-OUTPUT aux_dscritic).
    
            RETURN "NOK".
         END.
    END.

    IF  NOT CAN-DO("1,2,3",STRING(par_insitreq)) THEN DO:
        ASSIGN aux_cdcritic = 0 
               aux_dscritic = "Situacao de requisicao invalida.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    IF  NOT CAN-DO("2,3,5,8",STRING(par_tprequis)) THEN DO:
        ASSIGN aux_cdcritic = 0 
               aux_dscritic = "Tipo de requisicao invalida.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.
    
   

    IF  par_dtinicio = ? THEN DO:
        ASSIGN aux_cdcritic = 0
               aux_dscritic = "Data de inicio nao informada.".

        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 0,
                       INPUT 0,
                       INPUT 1, /*sequencia*/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).

        RETURN "NOK".
    END.

    IF  par_dttermin = ? THEN DO:
       ASSIGN aux_cdcritic = 0 
              aux_dscritic = "Data de termino nao informada.".

       RUN gera_erro (INPUT par_cdcooper,
                      INPUT 0,
                      INPUT 0,
                      INPUT 1, /*sequencia*/
                      INPUT aux_cdcritic,
                      INPUT-OUTPUT aux_dscritic).

       RETURN "NOK".
   END.

   IF  par_dtinicio > par_dttermin THEN DO:
          ASSIGN aux_cdcritic = 0 
                 aux_dscritic = "Data de inicio maior que a de termino.".

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT 0,
                         INPUT 0,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".
   END.
   
  /* IF  (par_dttermin - par_dtinicio) > 120 THEN DO:
          ASSIGN aux_cdcritic = 0 
                 aux_dscritic = "Periodo informado supera 120 dias.".

          RUN gera_erro (INPUT par_cdcooper,
                         INPUT 0,
                         INPUT 0,
                         INPUT 1, /*sequencia*/
                         INPUT aux_cdcritic,
                         INPUT-OUTPUT aux_dscritic).

          RETURN "NOK".
   END.*/
     
   IF  par_cdcoptel = 0 THEN DO:

       FOR EACH crapcop NO-LOCK
          WHERE crapcop.cdcooper <> 3
             BY crapcop.nmrescop:
                   
            ASSIGN aux_qtdreqtal = 0
                   aux_qtdflsa4  = 0. 
                   
           CREATE tt-listal.
           ASSIGN tt-listal.cdcooper = crapcop.cdcooper 
                  tt-listal.nmrescop = crapcop.nmrescop.

           FOR EACH  crapreq NO-LOCK 
               WHERE crapreq.cdcooper = crapcop.cdcooper
                 AND crapreq.insitreq = par_insitreq
                 AND crapreq.tprequis = par_tprequis
                 AND crapreq.dtmvtolt >= par_dtinicio
                 AND crapreq.dtmvtolt <= par_dttermin
               BREAK BY crapreq.cdcooper:

               IF crapreq.qtreqtal = ? THEN
               NEXT.

               ASSIGN aux_qtdreqtal = aux_qtdreqtal + crapreq.qtreqtal.

               IF  crapreq.tprequis = 5 THEN
                   IF aux_qtdreqtal <> 0 THEN
                       aux_qtdflsa4 = aux_qtdreqtal / 4.
                   ELSE
                      aux_qtdflsa4 = 0.
               ELSE 
                   aux_qtdflsa4 = 0.

               IF  LAST-OF(crapreq.cdcooper) THEN DO:
                   ASSIGN tt-listal.qtfolhas = aux_qtdreqtal
                          tt-listal.qtdflsa4 = aux_qtdflsa4. 
               END.
           END.
        END.
    END.
    ELSE DO:
       CREATE tt-listal.
       ASSIGN tt-listal.cdcooper = crapcop.cdcooper 
              tt-listal.nmrescop = crapcop.nmrescop.

       ASSIGN aux_qtdreqtal = 0
              aux_qtdflsa4  = 0.

        FOR EACH  crapreq NO-LOCK 
            WHERE crapreq.cdcooper = par_cdcoptel
              AND crapreq.insitreq = par_insitreq
              AND crapreq.tprequis = par_tprequis
              AND crapreq.dtmvtolt >= par_dtinicio
              AND crapreq.dtmvtolt <= par_dttermin            
            BREAK BY crapreq.cdcooper:
 
              ASSIGN aux_qtdreqtal = aux_qtdreqtal + crapreq.qtreqtal.

              IF  crapreq.tprequis = 5 THEN
                  IF aux_qtdreqtal <> 0 THEN
                     aux_qtdflsa4 = aux_qtdreqtal / 4.
                  ELSE
                     aux_qtdflsa4 = 0.
              ELSE 
                  aux_qtdflsa4 = 0.

              IF  LAST-OF(crapreq.cdcooper) THEN DO:
                  ASSIGN tt-listal.qtfolhas = aux_qtdreqtal
                         tt-listal.qtdflsa4 = aux_qtdflsa4. 
              END.
        END.
   END.

   RETURN "OK".
END PROCEDURE.

PROCEDURE listal-gera-relatorio:

    DEF  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper                NO-UNDO.
    DEF  INPUT PARAM par_cdcoptel LIKE crapcop.cdcooper                NO-UNDO.
    DEF  INPUT PARAM par_insitreq LIKE crapreq.insitreq                NO-UNDO.
    DEF  INPUT PARAM par_tprequis LIKE crapreq.tprequis                NO-UNDO.
    DEF  INPUT PARAM par_dtinicio LIKE crapreq.dtmvtolt                NO-UNDO.
    DEF  INPUT PARAM par_dttermin LIKE crapreq.dtmvtolt                NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                              NO-UNDO.
    DEF  INPUT PARAM TABLE FOR tt-listal.

    DEF OUTPUT PARAM ret_nmarqimp AS CHAR FORMAT "X(30)"               NO-UNDO.
    DEF OUTPUT PARAM ret_nmarqpdf AS CHAR FORMAT "X(50)"               NO-UNDO.

    DEF VAR aux_dscooper AS CHAR FORMAT "X(30)"                        NO-UNDO.
    DEF VAR aux_dssitreq AS CHAR FORMAT "X(30)"                        NO-UNDO.
    DEF VAR aux_dstipreq AS CHAR FORMAT "X(30)"                        NO-UNDO.

    DEF VAR aux_dsdircop AS CHAR FORMAT "X(30)"                        NO-UNDO.

    DEF VAR aux_totflhas AS INTE                                       NO-UNDO.
    DEF VAR aux_totflha4 AS INTE                                       NO-UNDO.

    FORM SKIP(1)
         "LISTA TOTAL DE TALOES SOLICITADOS"      AT 13
         SKIP(3)
         "PARAMETROS DE PESQUISA"                 AT  6  SKIP(1)
         aux_dscooper LABEL "COOPERATIVA"         AT 14  SKIP
         aux_dssitreq LABEL "SITUACAO REQUISICAO" AT  6  SKIP
         aux_dstipreq LABEL "TIPO REQUISICAO"     AT 10  SKIP
         par_dtinicio LABEL "DATA INICIO"         AT 14
         "A"                                      AT 38
         par_dttermin NO-LABEL                    AT 40
         SKIP(3)
     WITH ROW 4 OVERLAY SIDE-LABELS NO-LABELS WIDTH 80 FRAME f_param.
     
    FORM tt-listal.nmrescop LABEL "COOPERATIVA" FORMAT "x(18)"
         tt-listal.qtfolhas LABEL "QTDE FOLHAS" FORMAT "zzz,zz9"
         tt-listal.qtdflsa4 LABEL "QTD FLS A4"  FORMAT "zzz,zz9"  SKIP
    WITH ROW 16 COL 1 CENTERED DOWN 
         OVERLAY NO-LABELS WIDTH 70 NO-BOX FRAME f_dados_com.

    FORM tt-listal.nmrescop LABEL "COOPERATIVA" FORMAT "x(18)"
         tt-listal.qtfolhas LABEL "QTDE FOLHAS" FORMAT "zzz,zz9"
    WITH ROW 14 COL 1 CENTERED DOWN 
         OVERLAY NO-LABELS WIDTH 70 NO-BOX FRAME f_dados_sem.
        
    
    FORM SKIP(1)
         "------------------ ----------- ----------"    SKIP
         "TOTAL GERAL" 
         aux_totflhas NO-LABEL FORMAT "z,zzz,zz9" AT 22
         aux_totflha4 NO-LABEL FORMAT "z,zzz,zz9" AT 33 SKIP
         "------------------ ----------- ----------"    SKIP
         WITH COL 1 CENTERED DOWN 
         OVERLAY NO-LABELS WIDTH 70 NO-BOX FRAME f_total_com.

    FORM SKIP(1)
         "------------------ -----------" SKIP
         "TOTAL GERAL"
         aux_totflhas NO-LABEL FORMAT "z,zzz,zz9" AT 22 SKIP
         "------------------ -----------" SKIP
         WITH COL 1 CENTERED DOWN 
         OVERLAY NO-LABELS WIDTH 70 NO-BOX FRAME f_total_sem.

    IF  par_cdcoptel = 0 THEN
        ASSIGN aux_dscooper = "  0 - TODAS COOPERATIVAS".
    ELSE DO:
        FIND FIRST crapcop 
             WHERE crapcop.cdcooper = par_cdcoptel NO-LOCK NO-ERROR.

        ASSIGN aux_dscooper = STRING(crapcop.cdcooper,"z9") + " - " +
                              CAPS(crapcop.nmrescop).
    END.
    
    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper
                          NO-LOCK NO-ERROR.

    ASSIGN aux_dsdircop = "/usr/coop/" + crapcop.dsdircop +
                          "/rl/"
           ret_nmarqimp = aux_dsdircop + "listal.lst"
           ret_nmarqpdf = aux_dsdircop + "listal.ex".

    CASE par_insitreq:
        WHEN 1 THEN ASSIGN aux_dssitreq = "NAO EXECUTADO".
        WHEN 2 THEN ASSIGN aux_dssitreq = "EXECUTADO".
        WHEN 3 THEN ASSIGN aux_dssitreq = "REJEITADO".
    END.
    
    CASE par_tprequis:
        WHEN 2 THEN ASSIGN aux_dstipreq = "TB".
        WHEN 3 THEN ASSIGN aux_dstipreq = "FORMULARIO CONTINUO".
        WHEN 5 THEN ASSIGN aux_dstipreq = "AVULSO A4".
        WHEN 8 THEN ASSIGN aux_dstipreq = "BLOQUETO PRE-IMPRESSO".
    END.

    OUTPUT STREAM str_1 TO VALUE (ret_nmarqimp).
    
    DISP STREAM str_1 aux_dscooper  
                      aux_dssitreq
                      aux_dstipreq
                      par_dtinicio
                      par_dttermin
                 WITH FRAME f_param.

    FOR EACH tt-listal NO-LOCK
          BY tt-listal.qtfolhas DESC
          BY tt-listal.nmrescop:

        ASSIGN aux_totflhas = aux_totflhas + tt-listal.qtfolhas
               aux_totflha4 = aux_totflha4 + tt-listal.qtdflsa4.
    
        IF  par_tprequis = 5 THEN DO:
            DISP STREAM str_1 
                 tt-listal.nmrescop
                 tt-listal.qtfolhas
                 tt-listal.qtdflsa4
                 WITH FRAME f_dados_com.
            DOWN WITH FRAME f_dados_com.
           
        END.
        ELSE DO:
            DISP STREAM str_1 
                 tt-listal.nmrescop
                 tt-listal.qtfolhas
                 WITH FRAME f_dados_sem.
            DOWN WITH FRAME f_dados_sem.
        END.
    END.

    IF  par_tprequis = 5 THEN DO:
        DISP STREAM str_1
             aux_totflhas
             aux_totflha4
             WITH FRAME f_total_com.
        DOWN WITH FRAME f_total_com.
    END.
    ELSE DO:
        DISP STREAM str_1
             aux_totflhas
             WITH FRAME f_total_sem.
        DOWN WITH FRAME f_total_sem.
    END.

    OUTPUT STREAM str_1 CLOSE.
    
    IF  par_idorigem = 5 THEN DO: /* Ayllos Web */

        UNIX SILENT VALUE("cp " + ret_nmarqimp + " " + ret_nmarqpdf +
                          " 2> /dev/null").
    
        RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT
                SET h-b1wgen0024.
    
        IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
            DO:
               ASSIGN aux_cdcritic = 0
                      aux_dscritic = "Handle invalido para BO " +
                                     "b1wgen0024.".
      
               RUN gera_erro (INPUT par_cdcooper,
                              INPUT 0,
                              INPUT 0,
                              INPUT 1, /*sequencia*/
                              INPUT aux_cdcritic,
                              INPUT-OUTPUT aux_dscritic).
    
               RETURN "NOK".
            END.
            
        RUN envia-arquivo-web IN h-b1wgen0024 ( INPUT par_cdcooper,
                                                INPUT 1, /* cdagenci */
                                                INPUT 1, /* nrdcaixa */
                                                INPUT ret_nmarqpdf,
                                                OUTPUT ret_nmarqpdf,
                                                OUTPUT TABLE tt-erro ).

       
        IF  VALID-HANDLE(h-b1wgen0024)  THEN
            DELETE PROCEDURE h-b1wgen0024.
    
        IF  RETURN-VALUE <> "OK"   THEN
            RETURN "NOK".

    END.
    
   
END.

PROCEDURE consulta-cooperativas:
    
    DEF OUTPUT PARAM TABLE FOR tt-cooper.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-cooper.
    EMPTY TEMP-TABLE tt-erro.

    FOR EACH crapcop NO-LOCK
       WHERE crapcop.cdcooper <> 3
          BY crapcop.nmrescop:

        CREATE tt-cooper.
        ASSIGN tt-cooper.cdcooper = crapcop.cdcooper
               tt-cooper.nmrescop = CAPS(crapcop.nmrescop).
    END.

    RETURN "OK".

END PROCEDURE.


