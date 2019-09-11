/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
+----------------------------------------+-------------------------------------+
| Rotina Progress                        | Rotina Oracle PLSQL                 |
+----------------------------------------+-------------------------------------+
|sistema/generico/procedures/b1wgen0043.p| RATI0001                            |
|   descricao-operacao                   | RATI0001.fn_busca_descricao_operacao|
|   desativa_rating                      | RATI0001.pc_desativa_rating         |
|   verifica_contrato_rating             | RATI0001.pc_verifica_contrato_rating|
|   ativa_rating                         | RATI0001.pc_ativa_rating            |
|   calcula_endividamento                | RATI0001.pc_calcula_endividamento   |
|   grava_rating_origem                  | RATI0001.pc_grava-rating_origem     |
|   limpa_rating_origem                  | RATI0001.pc_limpa_rating_origem     |
|   muda_situacao_efetivo                | RATI0001.pc_muda_situacao_efetivo   |
|   muda_situacao_proposto               | RATI0001.pc_muda_situacao_proposto  |
|   parametro_valor_rating               | RATI0001.pc_param_valor_rating      |
|   procura_pior_nota                    | RATI0001.pc_procura_pior_nota       |
|   valor_maximo_legal                   | RATI0001.pc_valor_maximo_legal      |
|   calcula-rating                       | RATI0001.pc_calcula_rating          |
|   verifica_criacao                     | RATI0001.pc_verifica_criacao        |
|   calcula_singulares                   | RATI0001.pc_calcula_singulares      |
|   grava_item_rating                    | RATI0001.pc_grava_item_rating       |
|   calcula_rating_fisica                | RATI0001.pc_calcula_rating_fisica   |
|   risco_cooperado_pf                   | RATI0001.pc_risco_cooperado_pf      |
|   criticas_rating_fis                  | RATI0001.pc_criticas_rating_fis     |
|   historico_cooperado                  | RATI0001.pc_historico_cooperado     |
|   nivel_comprometimento                | RATI0001.pc_nivel_comprometimento   |
|   natureza_operacao                    | RATI0001.pc_natureza_operacao       |
|   calcula_rating_juridica              | RATI0001.pc_calcula_rating_juridica |
|   risco_cooperado_pj                   | RATI0001.pc_risco_cooperado_pj      |
|   criticas_rating_jur                  | RATI0001.pc_criticas_rating_jur     |
|   gera-arquivo-impressao-rating        | RATI0001.pc_gera_arq_impress_rating |
|   descricoes_risco                     | RATI0001.pc_descricoes_risco        |
|   valor-operacao                       | RATI0001.fn_valor_operacao          |
|   verifica_efetivacao                  | RATI0001.pc_verifica_efetivacao     |
|   efetivar_rating                      | RATI0001.pc_efetivar_rating         |
|   ratings-cooperado                    | RATI0001.pc_ratings_cooperado       |
|   descricao-situacao                   | RATI0001.fn_descricao_situacao      |
|   verifica_operacoes                   | RATI0001.pc_verifica_operacoes      |  
|   proc_calcula                         | RATI0001.pc_proc_calcula            |
|   verifica_atualizacao                 | RATI0001.pc_verifica_atualizacao    |
|   atualiza_rating                      | RATI0001.pc_atualiza_rating         |
|   valida-itens-rating                  | RATI0001.pc_valida_itens_rating     |
|   verifica_rating                      | RATI0001.pc_verifica_rating         |
|   gera_rating                          | RATI0001.pc_gera_rating             |
|   obtem_emprestimo_risco               | RATI0002.pc_obtem_emprestimo_risco  |
|   grava_rating                         | RATI0001.pc_grava_rating            |
+----------------------------------------+-------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - Daniel Zimmermann    (CECRED)
   - Marcos Martini       (SUPERO)

*******************************************************************************/



/*.............................................................................

  Programa: b1wgen0043.p
  Autor   : Gabriel
  Data    : Setembro/2009                       Ultima Atualizacao: 26/01/2018
                                                                      
  Dados referentes ao programa:
  
  Objetivo  : BO referente ao RATING do cooperado.
  
  Alteracoes:    /  /    - Alterações para Ayllos WEB:
                         - Incluir procedure gera_rating(gera_rating.p) 
                         - Incluir procedure busca_dados_rating
                         - Incluir procedure grava_rating
                           (Guilherme)
  
              24/02/2010 - Procedure para criticas na hora de geracao
                           do Rating.
                         - Deixar o cooperado sem Rating para a central
                           quando ele estiver abaixo do valor legal.
                         - Sempre migrar para o novo Rating , quando criado
                           um novo, independente da nota/risco.
                         - Retirar criticas fixas para cadastro na crapcri.  
                           (Gabriel).
                           
              17/03/2010 - Arrumar data de referencia para o mes passado
                           na procedure de riscos_sem_rating (Gabriel).            
                         - Arrumar critica quando imovel nao cadastrado
                           (Gabriel). 
                           
              16/04/2010 - Adaptar para Ayllos WEB (David).
              
              05/05/2010 - Acerto no item 1.3 (Pessoa fisica) para o devido
                           enquadramento quando aposentados sem um trabalho
                           previo cadastrado.
                           Acerto na hora do calculo do saldo utiliza quando
                           se esta liquidando outros emprestimos.
                           Acerto na procedure desativa_rating para desfazer
                           operacao caso <F4> / <END> (Gabriel).
                           
              20/05/2010 - Implementar a re-ativaçao do Rating.
                         - Implementar a procedure obtem_emprestimo_risco, que
                           trata dos riscos das propostas de emprestimo.
                         - Tratar para nao poder ter estouro de conta na
                           crapris na procedure riscos_sem_rating e os
                           nem contratos de emprestiimo com menos de 6 meses     
                           (Gabriel).
                           
              25/08/2010 - Feito tratamento, Emprestimos/Financiamentos
                           (Adriano).                       
                           
              09/09/2010 - Migracao para a tabela crapprp quando proposta
                           de emprestimo.
                           Retirar procedures nao mais utilizadas (Gabriel).
                          
              26/11/2010 - Quando impressao dos ratings para as propostas,
                           imprimir o rating proposto com a pior nota
                           e maior valor da operacao (Gabriel).
                           
              15/02/2011 - Se a empresa não atender a condição de tempo dos 
                           sócios na empresa com a cláusula
                           CAN-DO ("27,39,44,45,46,48",STRING(crapjur.natjurid));
                           fazer o mesmo tratamento que é feito com o campo
                           crapjur.natjurid para o campo crapjur.dtiniatv.
                           Os anos em que a empresa atua é que deverão ser 
                           encaixados na faixa. (Fabrício)
                           
              01/03/2011 - Alterações nas rotinas de cálculo e classificação
                           dos ratings 
                         - Adaptacoes  para o calculo do Risco Cooperado
                           (Guilherme).
                         
              14/04/2011 - Incluido campo tt-impressao-rating.intopico na
                           procedure gera-arquivo-impressao-rating. (Fabricio)
                           
              14/04/2011 - Incluido a temp-table tt-impressao-risco-tl como
                           parametro de saida da procedure atualiza_rating,
                           para atualizar a crapass no retorna para a tela
                           ATURAT. (Fabricio)
                           
              28/07/2011 - Correcao no calculo do item 1.10 (Gabriel).
              
              11/08/2011 - Alterações p/ Grupo Economico 
                           Parametro dtrefere na obtem_risco
                         - Adaptacao Rating das Singulares (Guilherme).
                         
              04/11/2011 - Rezalizado alteração na procedure valida-itens-rating     
                           para que, quando cdcooper = 3, sejam validados
                           apenas a liquidez e as inf. cadastrais (Adriano). 
                           
              09/11/2011 - Criado a procedure proc_calcula (Adriano).
              
              02/07/2012 - Tratamento do cdoperad "operador" de INTE para CHAR.
                           (Lucas R.)       
                           
              11/10/2012 - Incluido a passagem de um novo parametro na chamada
                           da procedure saldo_utiliza - Projeto GE (Adriano).
                           
              13/03/2013 - Ajuste na procedure obtem_emprestimo_risco para
                           ustilizar o campo crapris.inindris 
                           (risco individual) ao inves do crapris.innivris
                           (risco do grupo) (Adriano).
              13/05/2013 - Alterar regra do rating item 2_1(natureza da
                           operacao)  conforme  chamado 62561 - Rosangela.
              
              10/06/2013 - retirado o tratamento de dia útil do mês anterior
                           pois passou a ser desnecessário. Alterada a condição
                           >= aux_dtrefere p/ = aux_dtrefere (Carlos)
                           
              13/06/2013 - RATING BNDES (Guilherme/Supero)
                 
              16/12/2013 - Manter igualdade com o Oracle na procedure que 
                           procura a pior nota do Rating (Gabriel).
                           
              20/12/2013 - Adicionado validate para as tabelas crapnrc,
                           crapras (Tiago).     
                           
              28/04/2014 - Incluso VALIDATE crapnrc (Daniel)     
              
              25/06/2014 - Ajuste leitura CRAPRIS, incluso parametro na 
                           procedure obtem_risco (Daniel) SoftDesk 137892. 
                           
              19/08/2014 - Projeto Automatização de Consultas em Propostas
                           de Crédito (Jonata-RKAM).
                           
              31/10/2014 - Ajuste na procedure calcula-rating para atualizar
                           o risco do cooperado.(James)
                           
              
              18/11/2014 - Incluido validate apos o assign do campo 
                           crapnrc.flgativo dentro da procedure ativa_rating
                           (Adriano).             
                           
              30/12/2014 - Ajuste na procedure "verifica_atualizacao" para
                           a cooperativa Alto Vale. (James)
                           
              13/01/2015 - Ajuste na procedure "verifica_operacoes". (James)
              
              29/01/2015 - Incluso ajuste na procedure obtem_emprestimo_risco 
                           para considerar Adiantamento a Depositante (Mod 0101)
                           somente se for risco H (9) (Daniel/Irlan) SD 248589
                           
              18/05/2015 - Ajuste na procedure "obtem_emprestimo_risco" para
                           o projeto da cessao de credito. (James)
                           
              26/06/2015 - Ajuste na procedure "obtem_emprestimo_risco" para
                           o projeto de provisao. (James)  

			  03/07/2015 - Projeto 217 Reformula? Cadastral IPP Entrada
                           Ajuste nos codigos de natureza juridica para o
                           existente na receita federal (Tiago Castro - RKAM)           
                           
              27/11/2015 - Alterada data permitida pra recalculo do rating para
                           permitir na data 30/11/2015 apenas (Lucas Lunelli SD 366231)
                           
              16/12/2015 - Alterada na procedure a validacao de outros cargos para 
                           o campos de socio da empresa (Jonathan - RKAM)
                           
              21/12/2015 - Alterada data permitida pra recalculo do rating para
                           permitir na data 22/12 e 23/12/2015 (Lucas Lunelli SD 376733)
                           
              21/12/2015 - Alterada data permitida pra recalculo do rating para
                           permitir na data 29/12 (Lucas Lunelli)
                           
			  03/06/2016 - Alteracao na atribuicao de notas do rating, se for AA, deve
			               assumir a nota referente ao risco A.
						   Chamado 431839 (Andrey - RKAM)

              21/03/2017 - Alterado rotina obtem_emprestimo_risco, para definir menor
                           risco como Risco E aux_innivris = 6.
                           PRJ343 - Cessao de cartao de credito(Odirlei-AMcom)

              25/04/2017 - Alterado rotina pc_obtem_emprestimo_risco para chamada da rotina oracle.
                           PRJ337 - Motor de Credito (Odirlei-Amcom)

              22/06/2017 - Alterado rotina obtem-emprestimo-risco, para retornar menor
                           risco como Risco D aux_innivris = 5.
                           PRJ343 - Cessao de cartao de credito (Anderson)
                           
              25/07/2017 - Alterado para ignorar algumas validacoes para os emprestimos de
                           cessao da fatura de cartao de credito (Anderson).

              11/10/2017 - Liberacao da melhoria 442 (Heitor - Mouts)

              26/01/2018 - PRGJ450 - Criada funcao verificaQualificacao para posicionar o contrato para 
						   pegar a Qualificacao da Operacao (Controle). (Diego Simas - AMcom)
               
			  16/03/2018 - Alterado proc calcula_rating_fisica, caso as variaveis aux_vlsalari e rat_vlsalcje sejam nulas, atribuir 0 a elas. Chamado 830113 Alcemir (Mouts).
              
              16/03/2018 - Ajuste para ignorar validacao valida-item-rating quando for cessao de credito (crps714).
                           Chamado 858710 (Mateus Z / Mouts).		
			  
			  27/03/2018 - Alterado as procedures criticas_rating_fis e criticas_rating_jur para considerar a tabela
                           de proposta de limite de desconto de titulos crawlim na geração da critica 484 (Paulo Penteado GFT)
               
              12/04/2018 - Alterado as procedures calcula_rating_fisica e calcula_rating_juridica para considerar a tabela
                           de proposta de limite de desconto de titulos crawlim na geração da critica 484 (Paulo Penteado GFT)
              
              15/04/2018 - Alterado a procedure verifica_rating para considerar a tabela
                           de proposta de limite de desconto de titulos crawlim na geração da critica 484 (Paulo Penteado GFT)
						   
              12/12/2018 - Alterado mascara do contrato nas procedures gera-arquivo-impressao-rating
                           e efetivar_rating (Andre Clemer - Supero)

              07/05/2019 - Alterado na procedure verifica_rating para o rating antigo ser usado apenas pela central Ailos
                           (Luiz Otávio Olinger Momm - AMCOM)

              16/08/2019 - P450 - Na procedure obtem_emprestimo_risco, incluido pr_nrctremp
                           (Elton - AMCOM)
.............................................................................*/
  
  
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

{ sistema/generico/includes/b1wgen0043tt.i }
{ sistema/generico/includes/b1wgen9999tt.i }
{ sistema/generico/includes/b1wgen0027tt.i }
{ sistema/generico/includes/var_oracle.i }


DEF VAR aux_nrdrowid AS ROWID                                        NO-UNDO.
DEF VAR aux_cdcritic AS INTE                                         NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                         NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                         NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                         NO-UNDO.
DEF VAR aux_dsmesref AS CHAR                                         NO-UNDO.
DEF VAR aux_flgcriar AS LOGI                                         NO-UNDO.
DEF VAR aux_flgefeti AS LOGI                                         NO-UNDO.

/* Variavel para as procedures do rating */
DEF VAR aux_nrseqite AS INTE                                         NO-UNDO.
DEF VAR aux_dsvalite AS CHAR                                         NO-UNDO.
DEF VAR aux_flghisto AS LOGI                                         NO-UNDO.
 
DEF VAR h-b1wgen0002 AS HANDLE                                       NO-UNDO.
DEF VAR h-b1wgen0027 AS HANDLE                                       NO-UNDO.   
DEF VAR h-b1wgen9999 AS HANDLE                                       NO-UNDO.
DEF VAR aux_dadosusr AS CHAR                                         NO-UNDO.
DEF VAR par_loginusr AS CHAR                                         NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                         NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                         NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                         NO-UNDO.
DEF VAR par_numipusr AS CHAR                                         NO-UNDO.

/*Variaveis para gravar informacoes utilizadas no rating*/
DEF VAR rat_dtadmiss AS DATE                                         NO-UNDO.
DEF VAR rat_qtmaxatr AS INTE                                         NO-UNDO.
DEF VAR rat_flgreneg AS INTE                                         NO-UNDO.
DEF VAR rat_dtadmemp AS DATE                                         NO-UNDO.
DEF VAR rat_cdnatocp AS INTE                                         NO-UNDO.
DEF VAR rat_qtresext AS INTE                                         NO-UNDO.
DEF VAR rat_vlnegext AS DECI                                         NO-UNDO.
DEF VAR rat_flgresre AS INTE                                         NO-UNDO.
DEF VAR rat_qtadidep AS INTE                                         NO-UNDO.
DEF VAR rat_qtchqesp AS INTE                                         NO-UNDO.
DEF VAR rat_qtdevalo AS INTE                                         NO-UNDO.
DEF VAR rat_qtdevald AS INTE                                         NO-UNDO.
DEF VAR rat_cdsitres AS INTE                                         NO-UNDO.
DEF VAR rat_vlpreatv AS DECI                                         NO-UNDO.
DEF VAR rat_vlsalari AS DECI                                         NO-UNDO.
DEF VAR rat_vlrendim AS DECI                                         NO-UNDO.
DEF VAR rat_vlsalcje AS DECI                                         NO-UNDO.
DEF VAR rat_vlendivi AS DECI                                         NO-UNDO.
DEF VAR rat_vlbemtit AS DECI                                         NO-UNDO.
DEF VAR rat_flgcjeco AS INTE                                         NO-UNDO.
DEF VAR rat_vlbemcje AS DECI                                         NO-UNDO.
DEF VAR rat_vlsldeve AS DECI                                         NO-UNDO.
DEF VAR rat_vlopeatu AS DECI                                         NO-UNDO.
DEF VAR rat_vlslcota AS DECI                                         NO-UNDO.
DEF VAR rat_cdquaope AS INTE                                         NO-UNDO.
DEF VAR rat_cdtpoper AS INTE                                         NO-UNDO.
DEF VAR rat_cdlincre AS INTE                                         NO-UNDO.
DEF VAR rat_cdmodali AS CHAR                                         NO-UNDO.
DEF VAR rat_cdsubmod AS CHAR                                         NO-UNDO.
DEF VAR rat_cdgarope AS INTE                                         NO-UNDO.
DEF VAR rat_cdliqgar AS INTE                                         NO-UNDO.
DEF VAR rat_qtpreope AS INTE                                         NO-UNDO.
DEF VAR rat_dtfunemp AS DATE                                         NO-UNDO.
DEF VAR rat_cdseteco AS INTE                                         NO-UNDO.
DEF VAR rat_dtprisoc AS DATE                                         NO-UNDO.
DEF VAR rat_prfatcli AS DECI                                         NO-UNDO.
DEF VAR rat_vlmedfat AS DECI                                         NO-UNDO.
DEF VAR rat_vlbemavt AS DECI                                         NO-UNDO.
DEF VAR rat_vlbemsoc AS DECI                                         NO-UNDO.
DEF VAR rat_vlparope AS DECI                                         NO-UNDO.
DEF VAR rat_cdperemp AS INTE                                         NO-UNDO.
DEF VAR rat_dstpoper AS CHAR                                         NO-UNDO.
                               

/* FUNCTION PARA QUALIFICACAO DA OPERACAO ---- CRAPEPR ---------*/
/****************************************************************
 Traz a qualificacao da operacao quando alterada pelo controle
*****************************************************************/
FUNCTION verificaQualificacao RETURNS INTEGER
        (INPUT par_cdcooper AS INTE,
         INPUT par_nrdconta AS INTE,
         INPUT par_nrctremp AS INTE,
         INPUT par_idquapro AS INTE):                                                    

     FOR FIRST crapepr FIELDS(idquaprc) 
   WHERE crapepr.cdcooper = par_cdcooper  AND
         crapepr.nrdconta = par_nrdconta  AND
         crapepr.nrctremp = par_nrctremp NO-LOCK: END.
   IF AVAIL crapepr THEN
       return crapepr.idquaprc.
   else
       return par_idquapro.               
END FUNCTION.
                               
/******************************************************************************
                            PROCEDURES EXTERNAS
******************************************************************************/

/******************************************************************************
     Adaptação do fonte fontes/gera_rating.p para utilização no Ayllos WEB
               Gerar o rating do cooperado e dados de impressao
******************************************************************************/
PROCEDURE gera_rating:
    
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
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgcriar AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-cabrel.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-coop.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-rating.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-risco.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-risco-tl.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-assina.
    DEF OUTPUT PARAM TABLE FOR tt-efetivacao.
    DEF OUTPUT PARAM TABLE FOR tt-ratings.     
    
    DEF VAR aux_flgcalcu AS LOGI                                    NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-cabrel.
    EMPTY TEMP-TABLE tt-impressao-coop.
    EMPTY TEMP-TABLE tt-impressao-rating. 
    EMPTY TEMP-TABLE tt-impressao-risco.
    EMPTY TEMP-TABLE tt-impressao-risco-tl.
    EMPTY TEMP-TABLE tt-impressao-assina.
    EMPTY TEMP-TABLE tt-efetivacao.
    EMPTY TEMP-TABLE tt-ratings.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Gerar rating do cooperado"
		   aux_flghisto = par_flgcriar.
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

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
            
            RETURN "NOK".
        END.
    

    RUN busca_cabrel IN h-b1wgen9999 (INPUT par_cdcooper,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      INPUT par_cdoperad,
                                      INPUT par_nmdatela,
                                      INPUT par_idorigem,
                                      INPUT 367, /** Codigo Relatorio **/
                                      INPUT 0,   /** Conta/dv         **/
                                      INPUT par_dtmvtolt,
                                     OUTPUT TABLE tt-erro,        
                                     OUTPUT TABLE tt-cabrel).
    
    DELETE PROCEDURE h-b1wgen9999.
    
    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            IF  par_flgerlog  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        ASSIGN aux_dscritic = "Nao foi possivel gerar o " +
                                              "rating.".

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
    

    RUN verifica_rating (INPUT par_cdcooper,
                         INPUT par_cdagenci,
                         INPUT par_nrdcaixa,
                         INPUT par_cdoperad,
                         INPUT par_dtmvtolt,
                         INPUT par_nrdconta,
                         INPUT par_nrctrato,
                         INPUT par_tpctrato,
                         INPUT par_idseqttl,
                         INPUT par_idorigem,
                         INPUT par_nmdatela,
                         INPUT par_flgcriar,
                         INPUT FALSE,
                        OUTPUT TABLE tt-erro,
                        OUTPUT aux_flgcalcu).
    

    IF  RETURN-VALUE = "NOK"  THEN
        DO: 
            /*************************************************************/
            /** Retornar critica se nao for limite de credito ou se for **/
            /** limite de credito e estiver tentando imprimir           **/
            /*************************************************************/

            IF  par_tpctrato = 1  AND   /** Limite Credito **/
                par_flgcriar      THEN 
                DO:
                    EMPTY TEMP-TABLE tt-erro.

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
                END.
            ELSE
                DO:
                    IF  par_flgerlog  THEN
                        DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.

                            IF  AVAILABLE tt-erro  THEN
                                ASSIGN aux_dscritic = tt-erro.dscritic.
                            ELSE
                                ASSIGN aux_dscritic = "Nao foi possivel " +
                                                      "gerar o rating.".

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

    RUN calcula-rating (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT par_cdoperad,
                        INPUT par_dtmvtolt,
                        INPUT par_dtmvtopr,
                        INPUT par_inproces, 
                        INPUT par_nrdconta,
                        INPUT par_tpctrato,
                        INPUT par_nrctrato,
                        INPUT par_flgcriar,
                        INPUT aux_flgcalcu,
                        INPUT par_idseqttl,
                        INPUT par_idorigem,
                        INPUT par_nmdatela,
                        INPUT FALSE,
                       OUTPUT TABLE tt-erro,
                       OUTPUT TABLE tt-impressao-coop,
                       OUTPUT TABLE tt-impressao-rating,
                       OUTPUT TABLE tt-impressao-risco,
                       OUTPUT TABLE tt-impressao-risco-tl,
                       OUTPUT TABLE tt-impressao-assina,
                       OUTPUT TABLE tt-efetivacao,
                       OUTPUT TABLE tt-ratings).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            IF  par_flgerlog  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        ASSIGN aux_dscritic = "Nao foi possivel gerar o " +
                                              "rating.".

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

END.

/******************************************************************************
 Gerar o rating das cooperativas singulares
******************************************************************************/
PROCEDURE gera_rating_singulares:
    
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
    DEF  INPUT PARAM par_tpctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgcriar AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-singulares.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-cabrel.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-coop.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-rating.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-risco.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-risco-tl.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-assina.
    DEF OUTPUT PARAM TABLE FOR tt-efetivacao.
    DEF OUTPUT PARAM TABLE FOR tt-ratings.     
    
    DEF VAR aux_flgcalcu AS LOGI                                    NO-UNDO.

    DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-cabrel.
    EMPTY TEMP-TABLE tt-impressao-coop.
    EMPTY TEMP-TABLE tt-impressao-rating. 
    EMPTY TEMP-TABLE tt-impressao-risco.
    EMPTY TEMP-TABLE tt-impressao-risco-tl.
    EMPTY TEMP-TABLE tt-impressao-assina.
    EMPTY TEMP-TABLE tt-efetivacao.
    EMPTY TEMP-TABLE tt-ratings.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Gerar rating da cooperativa singular".

    FOR EACH tt-singulares NO-LOCK:
        CREATE tt-rating-singulares.
        BUFFER-COPY tt-singulares TO tt-rating-singulares.
    END.

    RUN gera_rating (INPUT par_cdcooper,
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
                     INPUT par_tpctrato,
                     INPUT par_nrctrato,
                     INPUT TRUE,
                     INPUT par_flgerlog,
                    OUTPUT TABLE tt-erro,
                    OUTPUT TABLE tt-cabrel,
                    OUTPUT TABLE tt-impressao-coop,
                    OUTPUT TABLE tt-impressao-rating,
                    OUTPUT TABLE tt-impressao-risco,
                    OUTPUT TABLE tt-impressao-risco-tl,
                    OUTPUT TABLE tt-impressao-assina,
                    OUTPUT TABLE tt-efetivacao,
                    OUTPUT TABLE tt-ratings).
    
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

END.

/******************************************************************************
                    Buscar valores do rating do cooperado
                  (Adaptacao valores-rating + itens-rating)
******************************************************************************/
PROCEDURE busca_dados_rating:

    DEF  INPUT PARAM par_cdcooper AS INTE                          NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                          NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                          NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                          NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                          NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                          NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                          NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                          NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                          NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-valores-rating.
    DEF OUTPUT PARAM TABLE FOR tt-itens-topico-rating.
         
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-valores-rating.
    EMPTY TEMP-TABLE tt-itens-topico-rating.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca dados de rating do cooperado".

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
    
            IF   par_flgerlog  THEN
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
    
    CREATE tt-valores-rating. 
    ASSIGN tt-valores-rating.inpessoa = crapass.inpessoa.
    
    IF  crapass.inpessoa = 1  THEN
        DO:
            FIND crapttl WHERE crapttl.cdcooper = par_cdcooper AND
                               crapttl.nrdconta = par_nrdconta AND
                               crapttl.idseqttl = 1            NO-LOCK NO-ERROR.

            IF  AVAILABLE crapttl  THEN
                ASSIGN tt-valores-rating.nrinfcad = crapttl.nrinfcad
                       tt-valores-rating.nrpatlvr = crapttl.nrpatlvr.
        END.
    ELSE
        DO:
            FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                               crapjur.nrdconta = par_nrdconta NO-LOCK NO-ERROR.
               
            IF  AVAILABLE crapjur  THEN
                ASSIGN tt-valores-rating.nrinfcad = crapjur.nrinfcad
                       tt-valores-rating.nrpatlvr = crapjur.nrpatlvr
                       tt-valores-rating.nrperger = crapjur.nrperger.
            
            /* Pegar concentracao faturamento unico cliente */
            FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper AND
                               crapjfn.nrdconta = par_nrdconta NO-LOCK NO-ERROR.

            IF  AVAILABLE crapjfn  THEN
                ASSIGN tt-valores-rating.perfatcl = crapjfn.perfatcl.

        END.
    
    /* Sequencia dos itens e topicos do rating */
    FOR EACH craprad WHERE craprad.cdcooper = par_cdcooper NO-LOCK:

        CREATE tt-itens-topico-rating.
        ASSIGN tt-itens-topico-rating.nrseqite = craprad.nrseqite
               tt-itens-topico-rating.dsseqite = craprad.dsseqite
               tt-itens-topico-rating.nrtopico = craprad.nrtopico
               tt-itens-topico-rating.nritetop = craprad.nritetop.

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


/******************************************************************************
                    Buscar valores do rating
******************************************************************************/
PROCEDURE busca_dados_rating_completo:

    DEF  INPUT PARAM par_cdcooper AS INTE                          NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                          NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                          NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                          NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                          NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                          NO-UNDO.
    DEF  INPUT PARAM par_nrctrrat AS INTE                          NO-UNDO.
    DEF  INPUT PARAM par_tpctrrat AS INTE                          NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                          NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                          NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                          NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-valores-rating.
    DEF OUTPUT PARAM TABLE FOR tt-topicos-rating.
    DEF OUTPUT PARAM TABLE FOR tt-itens-rating.
    DEF OUTPUT PARAM TABLE FOR tt-itens-topico-rating.
         
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-valores-rating.
    EMPTY TEMP-TABLE tt-itens-topico-rating.
    EMPTY TEMP-TABLE tt-topicos-rating.
    EMPTY TEMP-TABLE tt-itens-rating.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Busca dados completos de rating".
    
    /* Buscar as sequencias */
    RUN busca_dados_rating(INPUT par_cdcooper, 
                           INPUT par_cdagenci, 
                           INPUT par_nrdcaixa, 
                           INPUT par_cdoperad, 
                           INPUT par_dtmvtolt, 
                           INPUT par_nrdconta, 
                           INPUT par_idorigem, 
                           INPUT par_idseqttl, 
                           INPUT par_nmdatela, 
                           INPUT FALSE,
                           OUTPUT TABLE tt-erro,
                           OUTPUT TABLE tt-valores-rating,
                           OUTPUT TABLE tt-itens-topico-rating).

    IF  RETURN-VALUE <> "OK" THEN
    DO:
        IF   par_flgerlog  THEN
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

    /* Buscar os topicos */
    FOR  EACH craprat WHERE craprat.cdcooper  = par_cdcooper      AND 
                            craprat.nrtopico >= 0                 AND
                            craprat.flgativo NO-LOCK:
        CREATE tt-topicos-rating.
        ASSIGN tt-topicos-rating.nrtopico = craprat.nrtopico
               tt-topicos-rating.dstopico = craprat.dstopico.
    END.

    /* Buscar os itens */
    FOR EACH tt-topicos-rating NO-LOCK,
        EACH craprai WHERE craprai.cdcooper = par_cdcooper               AND
                           craprai.nrtopico = tt-topicos-rating.nrtopico NO-LOCK:
        CREATE tt-itens-rating.
        ASSIGN tt-itens-rating.nrtopico = craprai.nrtopico
               tt-itens-rating.nrseqite = craprai.nritetop
               tt-itens-rating.dsseqite = craprai.dsitetop.
    END.

    FOR EACH tt-itens-topico-rating EXCLUSIVE-LOCK:
        IF CAN-FIND( crapras WHERE 
                     crapras.cdcooper = par_cdcooper            AND 
                     crapras.nrdconta = par_nrdconta                    AND
                     crapras.nrctrrat = par_nrctrrat                    AND
                     crapras.tpctrrat = par_tpctrrat                    AND
                     crapras.nrtopico = tt-itens-topico-rating.nrtopico AND
                     crapras.nritetop = tt-itens-topico-rating.nritetop AND
                     crapras.nrseqite = tt-itens-topico-rating.nrseqite 
                     NO-LOCK) THEN
        DO:
            ASSIGN tt-itens-topico-rating.selecion = "*".
            END.
        ELSE
            ASSIGN tt-itens-topico-rating.selecion = " ".
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


/******************************************************************************
     Atualizar valores do rating do cooperado e retornar possiveis criticas
******************************************************************************/
PROCEDURE atualiza_valores_rating:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrinfcad AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrpatlvr AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrperger AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_tpctrrat AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctrrat AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Atualizar dados de rating do cooperado".

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
    
            IF   par_flgerlog  THEN
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

            /**********************************************************/
            /** Somente na proposta de limite de credito as criticas **/ 
            /** sao apresentadas na tela.                            **/
            /**********************************************************/

            IF  par_tpctrrat = 1  THEN  /** Limite de Crédito **/
                RETURN "NOK".
            ELSE       
                RETURN "OK".
        END.

    RUN grava_rating (INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT par_cdoperad,
                      INPUT par_dtmvtolt,
                      INPUT par_nrdconta,
                      INPUT crapass.inpessoa,
                      INPUT par_nrinfcad,
                      INPUT par_nrpatlvr,
                      INPUT par_nrperger,
                      INPUT par_idorigem,
                      INPUT par_idseqttl,
                      INPUT par_nmdatela,
                      INPUT FALSE,        
                     OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO: 
            IF  par_flgerlog  THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        ASSIGN aux_dscritic = "Nao foi possivel atualizar o " +
                                              "rating do cooperado.".

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

            /**********************************************************/
            /** Somente na proposta de limite de credito as criticas **/ 
            /** sao apresentadas na tela.                            **/
            /**********************************************************/

            IF  par_tpctrrat = 1  THEN  /** Limite de Crédito **/
                RETURN "NOK".
            ELSE       
                RETURN "OK".
        END.

    RUN lista_criticas (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT par_cdoperad,
                        INPUT par_dtmvtolt,
                        INPUT par_nrdconta,
                        INPUT par_tpctrrat,
                        INPUT par_nrctrrat,
                        INPUT par_idseqttl,
                        INPUT par_idorigem,
                        INPUT par_nmdatela,
                        INPUT par_inproces,
                        INPUT FALSE,
                       OUTPUT TABLE tt-erro).

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            IF  par_flgerlog  THEN
                DO:
                    FIND FIRST tt-erro WHERE tt-erro.cdcritic = 830 
                                             NO-LOCK NO-ERROR.

                    IF  AVAILABLE tt-erro  THEN
                        ASSIGN aux_dscritic = tt-erro.dscritic.
                    ELSE
                        ASSIGN aux_dscritic = "Nao foi possivel atualizar o " +
                                              "rating do cooperado.".

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

            /**********************************************************/
            /** Criticas apresentadas na tela em todas as operacoes. **/
            /**********************************************************/

            RETURN "NOK".
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


/******************************************************************************
                      Gravar dados do rating do cooperado
******************************************************************************/
PROCEDURE grava_rating:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_inpessoa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrinfcad AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrpatlvr AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrperger AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE                                     NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
           aux_dstransa = "Gravar dados de rating do cooperado".
    
    IF  par_inpessoa = 1  THEN
        DO:
            DO aux_contador = 1 TO 10:
        
                FIND crapttl WHERE  crapttl.cdcooper = par_cdcooper     AND
                                    crapttl.nrdconta = par_nrdconta     AND
                                    crapttl.idseqttl = par_idseqttl 
                                    EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                IF  NOT AVAILABLE crapttl   THEN
                    IF  LOCKED crapttl   THEN
                        DO:
                            ASSIGN aux_dscritic = "Registro de titular em " + 
                                                  "uso. Tente novamente.".
                                   aux_cdcritic = 0.                    
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 821.
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
             
            ASSIGN crapttl.nrinfcad = par_nrinfcad
                   crapttl.nrpatlvr = par_nrpatlvr.
        END.
    ELSE
        DO:
            DO  aux_contador = 1 TO 10:
    
                FIND crapjur WHERE crapjur.cdcooper = par_cdcooper AND
                                   crapjur.nrdconta = par_nrdconta 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
                IF  NOT AVAILABLE crapjur   THEN
                    IF  LOCKED crapjur   THEN
                        DO:
                            ASSIGN aux_dscritic = "Registro de titular em " + 
                                                  "uso. Tente novamente.".
                                   aux_cdcritic = 0.                    
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE
                        DO:
                            ASSIGN aux_cdcritic = 564.
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
    
            ASSIGN crapjur.nrinfcad = par_nrinfcad
                   crapjur.nrpatlvr = par_nrpatlvr
                   crapjur.nrperger = par_nrperger.                   
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

/*** FIM DA ADAPTACAO PARA AYLLOS WEB ***/

/******************************************************************************
Procedure para calcular o rating do associado e gravar os registros na
crapras. 
******************************************************************************/
PROCEDURE calcula-rating:

    DEF INPUT  PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT  PARAM par_dtmvtopr AS DATE                            NO-UNDO.
    DEF INPUT  PARAM par_inproces AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_tpctrato AS INTE                            NO-UNDO.  
    DEF INPUT  PARAM par_nrctrato AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_flgcriar AS LOGI                            NO-UNDO.
    DEF INPUT  PARAM par_flgcalcu AS LOGI                            NO-UNDO.
    DEF INPUT  PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF INPUT  PARAM par_flgerlog AS LOGI                            NO-UNDO.
                          
    DEF OUTPUT PARAM TABLE FOR tt-erro.                 
    DEF OUTPUT PARAM TABLE FOR tt-impressao-coop.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-rating.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-risco.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-risco-tl.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-assina. 
    DEF OUTPUT PARAM TABLE FOR tt-efetivacao.
    DEF OUTPUT PARAM TABLE FOR tt-ratings.

           
    DEF VAR          aux_vlutiliz AS DECI                            NO-UNDO.
    DEF VAR          aux_notacoop AS DECI                            NO-UNDO.
    DEF VAR          aux_contador AS INTE                            NO-UNDO.

    DEF VAR          par_flgefeti AS LOGI                            NO-UNDO.
    DEF VAR          aux_flgatuas AS LOGI INIT FALSE                 NO-UNDO.
    DEF VAR          aux_habrat   AS CHAR                            NO-UNDO. /* P450 - Rating */

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-crapras.

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
      RETURN "OK".
    END.
    /* Habilita novo rating */
    
    /* Limpa as outras temp-table na procedure gera-arquivo-impressao-rating */
    
    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Calcular o rating do associado".

    ASSIGN aux_flgatuas = FALSE
           aux_cdcritic = 0
           aux_dscritic = "".
    

    DO WHILE TRUE:
    
       FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                          crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.
                       
       IF   NOT AVAILABLE crapass   THEN
            DO:
                ASSIGN aux_cdcritic = 9.
                LEAVE.
            END.
       
       IF   par_flgcriar   THEN /* Verifica se tem que criar Rating*/
            DO:
                ASSIGN aux_flgatuas = TRUE.

                RUN verifica_criacao (INPUT par_cdcooper,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT par_cdoperad,
                                      INPUT par_dtmvtolt,
                                      INPUT par_dtmvtopr,
                                      INPUT par_inproces,
                                      INPUT par_nrdconta,
                                      INPUT par_tpctrato,
                                      INPUT par_nrctrato,
                                      INPUT par_idseqttl,
                                      INPUT par_idorigem,
                                      INPUT par_nmdatela,
                                      OUTPUT TABLE tt-erro,
                                      OUTPUT par_flgcriar).

                IF   RETURN-VALUE <> "OK" THEN
                     RETURN "NOK".

            END.
    

       IF   par_flgcalcu  THEN /* Calcular RATING */
            DO:
                IF  par_cdcooper = 3  THEN
                DO:  
                    RUN calcula_singulares (INPUT  par_cdcooper,
                                            INPUT  par_cdagenci,
                                            INPUT  par_nrdcaixa,
                                            INPUT  par_cdoperad,
                                            INPUT  par_nmdatela,
                                            INPUT  par_idorigem,
                                            INPUT  par_nrdconta,
                                            INPUT  par_idseqttl,
                                            INPUT  par_dtmvtolt,
                                            INPUT  par_dtmvtopr,
                                            INPUT  par_inproces,
                                            INPUT  par_tpctrato,
                                            INPUT  par_nrctrato,
                                            INPUT  par_flgcriar,
                                            OUTPUT TABLE tt-erro,
                                            OUTPUT aux_vlutiliz).
                    
                END.
                ELSE
                DO:
                    IF   crapass.inpessoa = 1   THEN /* Calculo P. Fisica */          
                         RUN calcula_rating_fisica (INPUT  par_cdcooper,
                                                    INPUT  par_cdagenci,
                                                    INPUT  par_nrdcaixa,
                                                    INPUT  par_cdoperad,
                                                    INPUT  par_nmdatela,
                                                    INPUT  par_idorigem,
                                                    INPUT  par_nrdconta,
                                                    INPUT  par_idseqttl,
                                                    INPUT  par_dtmvtolt,
                                                    INPUT  par_dtmvtopr,
                                                    INPUT  par_inproces,
                                                    INPUT  par_tpctrato,
                                                    INPUT  par_nrctrato,
                                                    INPUT  par_flgcriar,
                                                    OUTPUT TABLE tt-erro,
                                                    OUTPUT aux_vlutiliz).

                    ELSE                          /* Calculo P. Juridica */         
                         RUN calcula_rating_juridica (INPUT  par_cdcooper,
                                                      INPUT  par_cdagenci,
                                                      INPUT  par_nrdcaixa,
                                                      INPUT  par_cdoperad,
                                                      INPUT  par_nmdatela,
                                                      INPUT  par_idorigem,
                                                      INPUT  par_nrdconta,
                                                      INPUT  par_idseqttl,
                                                      INPUT  par_dtmvtolt,
                                                      INPUT  par_dtmvtopr,
                                                      INPUT  par_inproces,
                                                      INPUT  par_tpctrato,
                                                      INPUT  par_nrctrato,
                                                      INPUT  par_flgcriar,
                                                      OUTPUT TABLE tt-erro,
                                                      OUTPUT aux_vlutiliz).
                END.

                IF   RETURN-VALUE <> "OK"   THEN
                     LEAVE.

            END.
           
       /* Traz registros contendo o rating para imprimir */
       RUN gera-arquivo-impressao-rating (INPUT  par_cdcooper,
                                          INPUT  par_cdagenci,
                                          INPUT  par_nrdcaixa,
                                          INPUT  par_cdoperad,
                                          INPUT  par_dtmvtolt,
                                          INPUT  par_nrdconta,
                                          INPUT  par_tpctrato,
                                          INPUT  par_nrctrato,
                                          INPUT  par_flgcriar,
                                          INPUT  par_flgcalcu,
                                          INPUT  par_idseqttl,
                                          INPUT  par_idorigem,
                                          INPUT  par_nmdatela,
                                          INPUT  par_inproces,
                                          INPUT  par_flgerlog,
                                          OUTPUT TABLE tt-erro,
                                          OUTPUT TABLE tt-impressao-coop,
                                          OUTPUT TABLE tt-impressao-rating,
                                          OUTPUT TABLE tt-impressao-risco,
                                          OUTPUT TABLE tt-impressao-risco-tl,
                                          OUTPUT TABLE tt-impressao-assina,
                                          OUTPUT TABLE tt-efetivacao).


       IF   RETURN-VALUE <> "OK"   THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
                
                IF   NOT AVAILABLE tt-erro  THEN
                     aux_dscritic = "Erro na impressao do RATING".
            
                LEAVE. 
            END.

       /* Verifica se atualiza o risco do cooperado */
       IF aux_flgatuas THEN
          DO:
              FIND FIRST tt-impressao-risco-tl NO-LOCK NO-ERROR. 
              IF AVAIL tt-impressao-risco-tl THEN
                 DO:
                     DO TRANSACTION: 

                        DO aux_contador = 1 TO 10:

                           FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                                              crapass.nrdconta = par_nrdconta
                                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                           IF NOT AVAIL crapass THEN
                              IF LOCKED crapass THEN
                                 DO:
                                    aux_cdcritic = 77.
                                    PAUSE 1 NO-MESSAGE.
                                 END.

                           aux_cdcritic = 0.
                           LEAVE.

                        END. /* END DO aux_contador = 1 TO 10: */

                        IF aux_cdcritic <> 0 THEN
                           LEAVE.

                        ASSIGN crapass.inrisctl = tt-impressao-risco-tl.dsdrisco
                               crapass.nrnotatl = tt-impressao-risco-tl.vlrtotal
                               crapass.dtrisctl = par_dtmvtolt.

                     END. /* Fim da TRANSACTION */

                 END. /* END IF AVAIL tt-impressao-risco-tl THEN */

          END. /* END IF aux_flgatuas THEN */

       IF   par_flgcriar   THEN  /* Criar Rating */
            DO:                                    
                FIND FIRST tt-impressao-risco NO-LOCK NO-ERROR. 
                
                IF   NOT AVAIL tt-impressao-risco  THEN
                     DO:
                         aux_dscritic = "Risco da operacao nao encontrado.".
                         LEAVE.
                     END.
                
                FIND FIRST tt-impressao-risco-tl NO-LOCK NO-ERROR. 

                IF   NOT AVAIL tt-impressao-risco-tl  THEN
                     DO:
                         aux_dscritic = "Risco do cooperado nao encontrado.".
                         LEAVE.
                     END.

                DO TRANSACTION: 
                
                    /* Lock Crapnrc */
                    DO aux_contador = 1 TO 10:
                        
                       FIND crapnrc WHERE crapnrc.cdcooper = par_cdcooper  AND
                                          crapnrc.nrdconta = par_nrdconta  AND
                                          crapnrc.nrctrrat = par_nrctrato  AND
                                          crapnrc.tpctrrat = par_tpctrato   
                                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                       IF   NOT AVAILABLE crapnrc   THEN
                            IF   LOCKED crapnrc   THEN
                                 DO:
                                     aux_cdcritic = 77.
                                     PAUSE 1 NO-MESSAGE.
                                     NEXT.
                                 END.
 
                       aux_cdcritic = 0.
                       LEAVE.

                    END.  /* Fim DO ... TO */

                    IF   aux_cdcritic <> 0   THEN
                         LEAVE.

                    IF   NOT AVAIL crapnrc THEN
                         DO:
                             /* Notas do rating por contrato */
                             CREATE crapnrc.
                             ASSIGN crapnrc.cdcooper = par_cdcooper
                                    crapnrc.nrdconta = par_nrdconta
                                    crapnrc.nrctrrat = par_nrctrato
                                    crapnrc.tpctrrat = par_tpctrato
                                    crapnrc.insitrat = 1 /* Proposto */
                                    crapnrc.flgativo = TRUE. /*Operacao ativa */
                         END.
                                  
                    ASSIGN crapnrc.indrisco = tt-impressao-risco.dsdrisco
                           crapnrc.dtmvtolt = par_dtmvtolt
                           crapnrc.cdoperad = par_cdoperad
                           crapnrc.nrnotrat = tt-impressao-risco.vlrtotal
                           crapnrc.vlutlrat = aux_vlutiliz /* Valor utilizado */
                           crapnrc.nrnotatl = tt-impressao-risco-tl.vlrtotal
                           crapnrc.inrisctl = tt-impressao-risco-tl.dsdrisco.
                    VALIDATE crapnrc.       
                                                
                    /* NOVO TRECHO */
                   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                   RUN STORED-PROCEDURE pc_grava_his_crapnrc2
                   aux_handproc = PROC-HANDLE NO-ERROR 
                       ( INPUT par_cdcooper                   /* pr_cdcooper --> Codigo da cooperativa */
                        ,INPUT par_nrdconta                   /* pr_nrdconta --> Numero da conta */
                        ,INPUT par_nrctrato                   /* pr_nrctrrat --> Numero do contrato */
                        ,INPUT par_tpctrato                   /* pr_tpctrrat --> Tipo do contrato */
                        ,INPUT tt-impressao-risco.dsdrisco    /* pr_indrisco --> Indicador de risco */
                        ,INPUT par_dtmvtolt                   /* pr_dtmvtolt --> */
                        ,INPUT par_cdoperad                   /* pr_cdoperad --> */
                        ,INPUT tt-impressao-risco.vlrtotal    /* pr_nrnotrat --> */
                        ,INPUT aux_vlutiliz                   /* pr_vlutlrat --> */
                        ,INPUT tt-impressao-risco-tl.vlrtotal /* pr_nrnotatl --> */
                        ,INPUT tt-impressao-risco-tl.dsdrisco /* pr_inrisctl --> */
                        ,INPUT rat_dtadmiss                   /* pr_dtadmiss --> */
                        ,INPUT rat_qtmaxatr                   /* pr_qtmaxatr --> */
                        ,INPUT rat_flgreneg                   /* pr_flgreneg --> */
                        ,INPUT rat_dtadmemp                   /* pr_dtadmemp --> */
                        ,INPUT rat_cdnatocp                   /* pr_cdnatocp --> */
                        ,INPUT rat_qtresext                   /* pr_qtresext --> */
                        ,INPUT rat_vlnegext                   /* pr_vlnegext --> */
                        ,INPUT rat_flgresre                   /* pr_flgresre --> */
                        ,INPUT rat_qtadidep                   /* pr_qtadidep --> */
                        ,INPUT rat_qtchqesp                   /* pr_qtchqesp --> */
                        ,INPUT rat_qtdevalo                   /* pr_qtdevalo --> */
                        ,INPUT rat_qtdevald                   /* pr_qtdevald --> */
                        ,INPUT rat_cdsitres                   /* pr_cdsitres --> */
                        ,INPUT rat_vlpreatv                   /* pr_vlpreatv --> */
                        ,INPUT rat_vlsalari                   /* pr_vlsalari --> */
                        ,INPUT rat_vlrendim                   /* pr_vlrendim --> */
                        ,INPUT rat_vlsalcje                   /* pr_vlsalcje --> */
                        ,INPUT rat_vlendivi                   /* pr_vlendivi --> */
                        ,INPUT rat_vlbemtit                   /* pr_vlbemtit --> */
                        ,INPUT rat_flgcjeco                   /* pr_flgcjeco --> */
                        ,INPUT rat_vlbemcje                   /* pr_vlbemcje --> */
                        ,INPUT rat_vlsldeve                   /* pr_vlsldeve --> */
                        ,INPUT rat_vlopeatu                   /* pr_vlopeatu --> */
                        ,INPUT rat_vlslcota                   /* pr_vlslcota --> */
                        ,INPUT rat_cdquaope                   /* pr_cdquaope --> */
                        ,INPUT rat_cdtpoper                   /* pr_cdtpoper --> */
                        ,INPUT rat_cdlincre                   /* pr_cdlincre --> */
                        ,INPUT rat_cdmodali                   /* pr_cdmodali --> */
                        ,INPUT rat_cdsubmod                   /* pr_cdsubmod --> */
                        ,INPUT rat_cdgarope                   /* pr_cdgarope --> */
                        ,INPUT rat_cdliqgar                   /* pr_cdliqgar --> */
                        ,INPUT rat_qtpreope                   /* pr_qtpreope --> */
                        ,INPUT rat_dtfunemp                   /* pr_dtfunemp --> */
                        ,INPUT rat_cdseteco                   /* pr_cdseteco --> */
                        ,INPUT rat_dtprisoc                   /* pr_dtprisoc --> */
                        ,INPUT rat_prfatcli                   /* pr_prfatcli --> */
                        ,INPUT rat_vlmedfat                   /* pr_vlmedfat --> */
                        ,INPUT rat_vlbemavt                   /* pr_vlbemavt --> */
                        ,INPUT rat_vlbemsoc                   /* pr_vlbemsoc --> */
                        ,INPUT rat_vlparope                   /* pr_vlparope --> */
                        ,INPUT rat_cdperemp                   /* pr_dstpoper --> */
                        ,INPUT rat_dstpoper                   /* pr_dtadmiss --> */
                        ,OUTPUT 0                             /* pr_cdcritic --> Codigo da critica).     */
                        ,OUTPUT "" ).                         /* pr_dscritic --> Descriçao da critica    */
                        
                   /* Fechar o procedimento para buscarmos o resultado */ 
                   CLOSE STORED-PROC pc_grava_his_crapnrc2
                   aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
            
                   ASSIGN aux_cdcritic = pc_grava_his_crapnrc2.pr_cdcritic
                     WHEN pc_grava_his_crapnrc2.pr_cdcritic <> ?
                          aux_dscritic = pc_grava_his_crapnrc2.pr_dscritic
                     WHEN pc_grava_his_crapnrc2.pr_dscritic <> ?.

                   IF aux_cdcritic > 0 OR aux_dscritic <> '' THEN
                     RETURN "NOK".

                   /* FIM NOVO TRECHO */
                END. /* Fim da TRANSACTION */

                /* Verifica se tem que efetivar */
                RUN verifica_efetivacao (INPUT par_cdcooper,
                                         INPUT 0,
                                         INPUT 0,
                                         INPUT par_cdoperad,
                                         INPUT par_dtmvtolt,
                                         INPUT par_inproces,
                                         INPUT par_nrdconta,
                                         INPUT par_tpctrato,
                                         INPUT par_nrctrato,
                                         INPUT tt-impressao-risco.vlrtotal,
                                         INPUT aux_vlutiliz,
                                         INPUT par_idseqttl,
                                         INPUT par_idorigem,
                                         INPUT par_nmdatela,
                                         OUTPUT TABLE tt-erro,
                                         OUTPUT par_flgefeti).   

                IF   RETURN-VALUE <> "OK" THEN
                     RETURN "NOK".
                             
                IF   par_flgefeti   THEN /* Se tem que efetivar */
                     DO:
                         RUN efetivar_rating (INPUT  par_cdcooper,
                                              INPUT  par_nrdconta,
                                              INPUT  0,
                                              INPUT  0,
                                              INPUT  par_idorigem,
                                              INPUT  par_cdoperad,
                                              INPUT  par_dtmvtolt,
                                              INPUT  aux_vlutiliz,
                                              INPUT  TRUE, /* grava criacao */
                                              INPUT  par_inproces,
                                              OUTPUT TABLE tt-efetivacao,
                                              OUTPUT TABLE tt-ratings). 

                     END. /* Fim efetivacao */
            END.  /* Fim Criacao */
       ELSE
         DO TRANSACTION:
           FIND FIRST tt-impressao-risco NO-LOCK NO-ERROR. 
           IF NOT AVAIL tt-impressao-risco  THEN
             DO:
               aux_dscritic = "Risco da operacao nao encontrado.".
       LEAVE.
             END.

           FIND FIRST tt-impressao-risco-tl NO-LOCK NO-ERROR. 
           IF NOT AVAIL tt-impressao-risco-tl  THEN
             DO:
               aux_dscritic = "Risco do cooperado nao encontrado.".
       LEAVE.
             END.

		   IF aux_flghisto THEN
		     DO:
           /* NOVO TRECHO */
			   { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
           RUN STORED-PROCEDURE pc_grava_his_crapnrc2
				   aux_handproc = PROC-HANDLE NO-ERROR 
					  	 ( INPUT par_cdcooper                   /* pr_cdcooper --> Codigo da cooperativa */
					 		  ,INPUT par_nrdconta                   /* pr_nrdconta --> Numero da conta */
						 	  ,INPUT par_nrctrato                   /* pr_nrctrrat --> Numero do contrato */
							  ,INPUT par_tpctrato                   /* pr_tpctrrat --> Tipo do contrato */
							  ,INPUT tt-impressao-risco.dsdrisco    /* pr_indrisco --> Indicador de risco */
							  ,INPUT par_dtmvtolt                   /* pr_dtmvtolt --> */
							  ,INPUT par_cdoperad                   /* pr_cdoperad --> */
							  ,INPUT tt-impressao-risco.vlrtotal    /* pr_nrnotrat --> */
							  ,INPUT aux_vlutiliz                   /* pr_vlutlrat --> */
							  ,INPUT tt-impressao-risco-tl.vlrtotal /* pr_nrnotatl --> */
							  ,INPUT tt-impressao-risco-tl.dsdrisco /* pr_inrisctl --> */
                ,INPUT rat_dtadmiss                   /* pr_dtadmiss --> */
                ,INPUT rat_qtmaxatr                   /* pr_qtmaxatr --> */
                ,INPUT rat_flgreneg                   /* pr_flgreneg --> */
                ,INPUT rat_dtadmemp                   /* pr_dtadmemp --> */
                ,INPUT rat_cdnatocp                   /* pr_cdnatocp --> */
                ,INPUT rat_qtresext                   /* pr_qtresext --> */
                ,INPUT rat_vlnegext                   /* pr_vlnegext --> */
                ,INPUT rat_flgresre                   /* pr_flgresre --> */
                ,INPUT rat_qtadidep                   /* pr_qtadidep --> */
                ,INPUT rat_qtchqesp                   /* pr_qtchqesp --> */
                ,INPUT rat_qtdevalo                   /* pr_qtdevalo --> */
                ,INPUT rat_qtdevald                   /* pr_qtdevald --> */
                ,INPUT rat_cdsitres                   /* pr_cdsitres --> */
                ,INPUT rat_vlpreatv                   /* pr_vlpreatv --> */
                ,INPUT rat_vlsalari                   /* pr_vlsalari --> */
                ,INPUT rat_vlrendim                   /* pr_vlrendim --> */
                ,INPUT rat_vlsalcje                   /* pr_vlsalcje --> */
                ,INPUT rat_vlendivi                   /* pr_vlendivi --> */
                ,INPUT rat_vlbemtit                   /* pr_vlbemtit --> */
                ,INPUT rat_flgcjeco                   /* pr_flgcjeco --> */
                ,INPUT rat_vlbemcje                   /* pr_vlbemcje --> */
                ,INPUT rat_vlsldeve                   /* pr_vlsldeve --> */
                ,INPUT rat_vlopeatu                   /* pr_vlopeatu --> */
                ,INPUT rat_vlslcota                   /* pr_vlslcota --> */
                ,INPUT rat_cdquaope                   /* pr_cdquaope --> */
                ,INPUT rat_cdtpoper                   /* pr_cdtpoper --> */
                ,INPUT rat_cdlincre                   /* pr_cdlincre --> */
                ,INPUT rat_cdmodali                   /* pr_cdmodali --> */
                ,INPUT rat_cdsubmod                   /* pr_cdsubmod --> */
                ,INPUT rat_cdgarope                   /* pr_cdgarope --> */
                ,INPUT rat_cdliqgar                   /* pr_cdliqgar --> */
                ,INPUT rat_qtpreope                   /* pr_qtpreope --> */
                ,INPUT rat_dtfunemp                   /* pr_dtfunemp --> */
                ,INPUT rat_cdseteco                   /* pr_cdseteco --> */
                ,INPUT rat_dtprisoc                   /* pr_dtprisoc --> */
                ,INPUT rat_prfatcli                   /* pr_prfatcli --> */
                ,INPUT rat_vlmedfat                   /* pr_vlmedfat --> */
                ,INPUT rat_vlbemavt                   /* pr_vlbemavt --> */
                ,INPUT rat_vlbemsoc                   /* pr_vlbemsoc --> */
                ,INPUT rat_vlparope                   /* pr_vlparope --> */
                ,INPUT rat_cdperemp                   /* pr_dstpoper --> */
                ,INPUT rat_dstpoper                   /* pr_dtadmiss --> */
							  ,OUTPUT 0                             /* pr_cdcritic --> Codigo da critica).     */
							  ,OUTPUT "" ).                         /* pr_dscritic --> Descriçao da critica    */

				   /* Fechar o procedimento para buscarmos o resultado */ 
				   CLOSE STORED-PROC pc_grava_his_crapnrc2
					 aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
				   { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

           ASSIGN aux_cdcritic = pc_grava_his_crapnrc2.pr_cdcritic
						 WHEN pc_grava_his_crapnrc2.pr_cdcritic <> ?
					        aux_dscritic = pc_grava_his_crapnrc2.pr_dscritic
						 WHEN pc_grava_his_crapnrc2.pr_dscritic <> ?.

           IF aux_cdcritic > 0 OR aux_dscritic <> '' THEN
				     RETURN "NOK".

           /* FIM NOVO TRECHO */
         
			     /*{ includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
				/* Efetuar a chamada a rotina Oracle */ 
				RUN STORED-PROCEDURE pc_grava_his_crapnrc
				 aux_handproc = PROC-HANDLE NO-ERROR 
							 ( INPUT par_cdcooper                   /* pr_cdcooper --> Codigo da cooperativa */
							  ,INPUT par_nrdconta                   /* pr_nrdconta --> Numero da conta */
							  ,INPUT par_nrctrato                   /* pr_nrctrrat --> Numero do contrato */
							  ,INPUT par_tpctrato                   /* pr_tpctrrat --> Tipo do contrato */
							  ,INPUT tt-impressao-risco.dsdrisco    /* pr_indrisco --> Indicador de risco */
							  ,INPUT par_dtmvtolt                   /* pr_dtmvtolt --> */
							  ,INPUT par_cdoperad                   /* pr_cdoperad --> */
							  ,INPUT tt-impressao-risco.vlrtotal    /* pr_nrnotrat --> */
							  ,INPUT aux_vlutiliz                   /* pr_vlutlrat --> */
							  ,INPUT tt-impressao-risco-tl.vlrtotal /* pr_nrnotatl --> */
							  ,INPUT tt-impressao-risco-tl.dsdrisco /* pr_inrisctl --> */
							  ,OUTPUT 0                             /* pr_cdcritic --> Codigo da critica).     */
							  ,OUTPUT "" ).                         /* pr_dscritic --> Descriçao da critica    */
				/* Fechar o procedimento para buscarmos o resultado */ 
				CLOSE STORED-PROC pc_grava_his_crapnrc
					aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
				{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

				ASSIGN aux_cdcritic = pc_grava_his_crapnrc.pr_cdcritic
										 WHEN pc_grava_his_crapnrc.pr_cdcritic <> ?
					   aux_dscritic = pc_grava_his_crapnrc.pr_dscritic
										 WHEN pc_grava_his_crapnrc.pr_dscritic <> ?.

				IF aux_cdcritic > 0 OR aux_dscritic <> '' THEN
				     RETURN "NOK".*/
		     END.

         END.
       LEAVE.
    END. /* Fim do DO WHILE TRUE para tratamento de criticas */
               
    IF   aux_cdcritic <> 0    OR 
         aux_dscritic <> ""   THEN
         DO:  
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   NOT AVAIL tt-erro THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).

             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  aux_dscritic,
                                      INPUT  aux_dsorigem,
                                      INPUT  aux_dstransa,
                                      INPUT  FALSE,
                                      INPUT  par_idseqttl,
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_nrdrowid).

             IF   par_flgcriar   THEN
                  UNDO, RETURN "NOK".

             RETURN "NOK".
         END.

    IF   par_flgerlog   THEN                                
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

/***************************************************************************
 Validacao dos campos que envolvem <F7> do rating na proposta de emprestimo,
 contratos de cheque especial e descontos
***************************************************************************/

PROCEDURE valida-itens-rating:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.    
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.    
    DEF  INPUT PARAM par_nrgarope AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrinfcad AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrliquid AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrpatlvr AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrperger AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.    
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.
                                                                   
    DEF OUTPUT PARAM TABLE FOR tt-erro.                            
                                                                   
    DEF  VAR         aux_flgvalid AS LOGI                            NO-UNDO.
    DEF  VAR         aux_flgcescr AS LOG INIT FALSE                  NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    /* Carregar flag de cessao de credito */
    IF par_nmdatela = "CRPS714" THEN
       ASSIGN aux_flgcescr = TRUE.       

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Validar itens que compoem o RATING.".

    
    
    DO WHILE TRUE:
 
       FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                          crapass.nrdconta = par_nrdconta
                          NO-LOCK NO-ERROR.

       IF   NOT AVAILABLE crapass THEN
            DO:
                aux_cdcritic = 9.
                LEAVE.
            END.

       /* Para cooperativa 3 somente sera necessario validar o campo Liquidez*/
       IF  par_cdcooper = 3  THEN
           DO:
                /* Validar apenas se nao for cessao de credito */
                 IF  NOT aux_flgcescr THEN
                    DO:
                RUN valida-item-rating (INPUT  par_cdcooper,
                                        INPUT  0,
                                        INPUT  0,
                                        INPUT  par_cdoperad,
                                        INPUT  par_dtmvtolt,
                                        INPUT  3, /*6*/
                                        INPUT  3, /*2*/
                                        INPUT  par_nrinfcad,
                                        INPUT  par_idseqttl,
                                        INPUT  par_idorigem,
                                        INPUT  par_nmdatela,
                                        OUTPUT aux_flgvalid).

                IF   NOT aux_flgvalid   THEN
                     DO:
                         aux_dscritic = "014 - Opcao errada - Informacoes cadastrais.".
                         LEAVE.

                     END.
                    END.

               RUN valida-item-rating (INPUT  par_cdcooper,
                                        INPUT  0,
                                        INPUT  0,
                                        INPUT  par_cdoperad,
                                        INPUT  par_dtmvtolt,
                                        INPUT  4, 
                                        INPUT  3, 
                                        INPUT  par_nrliquid,
                                        INPUT  par_idseqttl,
                                        INPUT  par_idorigem,
                                        INPUT  par_nmdatela,
                                        OUTPUT aux_flgvalid).

                IF   NOT aux_flgvalid   THEN
                     DO:
                         aux_dscritic = 
                            "014 - Opcao errada - Liquidez das garantias.".
                         LEAVE.

                     END.

               LEAVE.
           
           END.

       IF   crapass.inpessoa = 1 THEN
            DO: 
                RUN valida-item-rating (INPUT  par_cdcooper,
                                        INPUT  0,
                                        INPUT  0,
                                        INPUT  par_cdoperad,
                                        INPUT  par_dtmvtolt,
                                        INPUT  2, 
                                        INPUT  2,
                                        INPUT  par_nrgarope,
                                        INPUT  par_idseqttl,
                                        INPUT  par_idorigem,
                                        INPUT  par_nmdatela,
                                        OUTPUT aux_flgvalid).
             
                IF   NOT aux_flgvalid   THEN
                     DO:
                         aux_dscritic = "014 - Opcao errada - Garantia.".
                         LEAVE.
                     END.

                 /* Validar apenas se nao for cessao de credito */
                 IF  NOT aux_flgcescr THEN
                    DO: 
                 RUN valida-item-rating (INPUT  par_cdcooper,
                                         INPUT  0,
                                         INPUT  0,
                                         INPUT  par_cdoperad,
                                         INPUT  par_dtmvtolt,
                                         INPUT  1,
                                         INPUT  4,
                                         INPUT  par_nrinfcad,
                                         INPUT  par_idseqttl,
                                         INPUT  par_idorigem,
                                         INPUT  par_nmdatela,
                                         OUTPUT aux_flgvalid).

                IF   NOT aux_flgvalid   THEN
                     DO:
                         aux_dscritic =
                            "014 - Opcao errada - Informacoes cadastrais.".
                         LEAVE.
                     END.
                    END.

                RUN valida-item-rating (INPUT  par_cdcooper,
                                        INPUT  0,
                                        INPUT  0,
                                        INPUT  par_cdoperad,
                                        INPUT  par_dtmvtolt,
                                        INPUT  2,
                                        INPUT  3,
                                        INPUT  par_nrliquid,
                                        INPUT  par_idseqttl,
                                        INPUT  par_idorigem,
                                        INPUT  par_nmdatela,
                                        OUTPUT aux_flgvalid).
                
                IF   NOT aux_flgvalid   THEN
                     DO:
                         aux_dscritic = 
                            "014 - Opcao errada - Liquidez das garantias.".
                         LEAVE.
                     END.

                 RUN valida-item-rating (INPUT  par_cdcooper,
                                         INPUT  0,
                                         INPUT  0,
                                         INPUT  par_cdoperad,
                                         INPUT  par_dtmvtolt,
                                         INPUT  1, /*3*/
                                         INPUT  8, /*2*/
                                         INPUT  par_nrpatlvr,
                                         INPUT  par_idseqttl,
                                         INPUT  par_idorigem,
                                         INPUT  par_nmdatela,
                                         OUTPUT aux_flgvalid).

                IF   NOT aux_flgvalid   THEN
                     DO:
                         aux_dscritic =
                             "014 - Opcao errada - Patrimonio pessoal livre.".
                         LEAVE.
                     END.

            END. /* Fim itens Pessoa fisica */
       ELSE 
            DO:            
                RUN valida-item-rating (INPUT  par_cdcooper,
                                        INPUT  0,
                                        INPUT  0,
                                        INPUT  par_cdoperad,
                                        INPUT  par_dtmvtolt,
                                        INPUT  4,
                                        INPUT  2,
                                        INPUT  par_nrgarope,
                                        INPUT  par_idseqttl,
                                        INPUT  par_idorigem,
                                        INPUT  par_nmdatela,
                                        OUTPUT aux_flgvalid).

                IF   NOT aux_flgvalid   THEN
                     DO:
                         aux_dscritic = "014 - Opcao errada - Garantia.".
                         LEAVE.
                     END.

                RUN valida-item-rating (INPUT  par_cdcooper,
                                        INPUT  0,
                                        INPUT  0,
                                        INPUT  par_cdoperad,
                                        INPUT  par_dtmvtolt,
                                        INPUT  3,  /*6*/
                                        INPUT  11, /*3*/
                                        INPUT  par_nrperger,
                                        INPUT  par_idseqttl,
                                        INPUT  par_idorigem,
                                        INPUT  par_nmdatela,
                                        OUTPUT aux_flgvalid).

                IF   NOT aux_flgvalid   THEN
                     DO:
                         aux_dscritic = 
                            "014 - Opcao errada - Percepcao geral (Empresa).".
                         LEAVE.
                     END.

                 /* Validar apenas se nao for cessao de credito */
                 IF  NOT aux_flgcescr THEN
                    DO:
                RUN valida-item-rating (INPUT  par_cdcooper,
                                        INPUT  0,
                                        INPUT  0,
                                        INPUT  par_cdoperad,
                                        INPUT  par_dtmvtolt,
                                        INPUT  3, /*6*/
                                        INPUT  3, /*2*/
                                        INPUT  par_nrinfcad,
                                        INPUT  par_idseqttl,
                                        INPUT  par_idorigem,
                                        INPUT  par_nmdatela,
                                        OUTPUT aux_flgvalid).

                IF   NOT aux_flgvalid   THEN
                     DO:
                         aux_dscritic = "014 - Opcao errada - Informacoes cadastrais.".
                         LEAVE.
                     END.
                    END.

                RUN valida-item-rating (INPUT  par_cdcooper,
                                        INPUT  0,
                                        INPUT  0,
                                        INPUT  par_cdoperad,
                                        INPUT  par_dtmvtolt,
                                        INPUT  4, 
                                        INPUT  3, 
                                        INPUT  par_nrliquid,
                                        INPUT  par_idseqttl,
                                        INPUT  par_idorigem,
                                        INPUT  par_nmdatela,
                                        OUTPUT aux_flgvalid).

                IF   NOT aux_flgvalid   THEN
                     DO:
                         aux_dscritic = 
                            "014 - Opcao errada - Liquidez das garantias.".
                         LEAVE.
                     END.

                RUN valida-item-rating (INPUT  par_cdcooper,
                                        INPUT  0,
                                        INPUT  0,
                                        INPUT  par_cdoperad,
                                        INPUT  par_dtmvtolt,
                                        INPUT  3, /*5*/
                                        INPUT  9, /*4*/
                                        INPUT  par_nrpatlvr,
                                        INPUT  par_idseqttl,
                                        INPUT  par_idorigem,
                                        INPUT  par_nmdatela,
                                        OUTPUT aux_flgvalid).
                
                IF   NOT aux_flgvalid   THEN
                     DO:
                         aux_dscritic = "014 - Opcao errada - Patrimonio pessoal livre.".
                         LEAVE.
                     END.
                
            END. /* Fim itens Pessoa Juridica  */

       LEAVE.

    END. /* Fim DO WHILE TRUE */

    IF   aux_dscritic <> ""  OR
         aux_cdcritic <>  0  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
        
            IF   par_flgerlog  THEN
                 RUN proc_gerar_log (INPUT  par_cdcooper,
                                     INPUT  par_cdoperad,
                                     INPUT  aux_dscritic,
                                     INPUT  aux_dsorigem,
                                     INPUT  aux_dstransa,
                                     INPUT  FALSE,
                                     INPUT  par_idseqttl,
                                     INPUT  par_nmdatela,
                                     INPUT  par_nrdconta,
                                     OUTPUT aux_nrdrowid).                  
            RETURN "NOK".
        
         END.

    IF   par_flgerlog   THEN                                
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
               

/***************************************************************************
 Ler o rating do associado e gerar o arquivo correnpondente 
***************************************************************************/

PROCEDURE gera-arquivo-impressao-rating:

    DEF INPUT  PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_nrdcaixa AS INTE                            NO-UNDO.    
    DEF INPUT  PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT  PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT  PARAM par_nrdconta AS INTE                            NO-UNDO. 
    DEF INPUT  PARAM par_tpctrato AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_nrctrato AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_flgcriar AS LOGI                            NO-UNDO.
    DEF INPUT  PARAM par_flgcalcu AS LOGI                            NO-UNDO.
    DEF INPUT  PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF INPUT  PARAM par_inproces AS INTE                            NO-UNDO.
    DEF INPUT  PARAM par_flgerlog AS LOGI                            NO-UNDO.    

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-coop.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-rating.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-risco.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-risco-tl.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-assina. 
    DEF OUTPUT PARAM TABLE FOR tt-efetivacao.
     

    DEF VAR          aux_dspessoa AS CHAR                            NO-UNDO.
    DEF VAR          aux_vlrdnota AS DECI                            NO-UNDO.
    DEF VAR          aux_vlrtotal AS DECI                            NO-UNDO.
    DEF VAR          aux_notacoop AS DECI                            NO-UNDO.
    DEF VAR          aux_contador AS INTE                            NO-UNDO.
    DEF VAR          aux_flgvalid AS LOGI                            NO-UNDO.              
    DEF VAR          aux_dsdopera AS CHAR                            NO-UNDO.
    DEF VAR          aux_vloperac AS DECI                            NO-UNDO.
    DEF VAR          aux_indrisco AS CHAR FORMAT "x(1)"              NO-UNDO.

      
    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-impressao-coop.
    EMPTY TEMP-TABLE tt-impressao-rating.
    EMPTY TEMP-TABLE tt-impressao-assina.
    EMPTY TEMP-TABLE tt-efetivacao.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Gerar o arquivo para impressao do RATING".


    
    DO WHILE TRUE:
       
        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                           crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapass   THEN
             DO: 
                 aux_cdcritic = 9.  
                 LEAVE.
             END.

        FIND crapope WHERE crapope.cdcooper = par_cdcooper   AND
                           crapope.cdoperad = par_cdoperad   NO-LOCK NO-ERROR.
    
        IF   NOT AVAILABLE crapope  THEN
             DO:
                 aux_cdcritic = 67.
                 LEAVE.
             END.

        LEAVE.

    END.

                     
    IF   aux_cdcritic <>   0   OR
         aux_dscritic <> ""   THEN
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

    
                    
    IF   crapass.inpessoa = 1   THEN
         ASSIGN aux_dspessoa = "Pessoa Fisica".
    ELSE
         ASSIGN aux_dspessoa = "Pessoa Juridica".

    /* Tabela com as informacoes do cooperado */
    CREATE tt-impressao-coop.

    ASSIGN tt-impressao-coop.nrdconta = crapass.nrdconta
           tt-impressao-coop.nmprimtl = crapass.nmprimtl
           tt-impressao-coop.dspessoa = aux_dspessoa
           tt-impressao-coop.nrctrrat = par_nrctrato
           tt-impressao-coop.tpctrrat = par_tpctrato.

    RUN descricao-operacao (INPUT par_tpctrato,
                            OUTPUT tt-impressao-coop.dsdopera).

    /* Topicos do rating */
    FOR  EACH craprat WHERE craprat.cdcooper = par_cdcooper       AND
                            craprat.inpessoa = crapass.inpessoa   AND
                            craprat.flgativo = YES                NO-LOCK,
         
         /*Itens do rating*/
         EACH craprai WHERE craprai.cdcooper = craprat.cdcooper   AND
                            craprai.nrtopico = craprat.nrtopico   NO-LOCK,

         /*Descricao do rating */
         EACH craprad WHERE craprad.cdcooper = craprai.cdcooper   AND
                            craprad.nrtopico = craprai.nrtopico   AND
                            craprad.nritetop = craprai.nritetop   NO-LOCK
                            BREAK BY craprat.nrtopico
                                     BY craprai.nritetop
                                        BY craprad.nrseqite:
         
         IF   FIRST-OF(craprat.nrtopico)   THEN /* Descricao do topico */
              DO:
                  CREATE tt-impressao-rating.
                  ASSIGN tt-impressao-rating.intopico = craprat.intopico
                         tt-impressao-rating.nrtopico = craprat.nrtopico
                         tt-impressao-rating.nritetop = 0
                         tt-impressao-rating.nrseqite = 0
                         tt-impressao-rating.dsitetop = craprat.dstopico
                         tt-impressao-rating.dspesoit = "".
              END.

         IF   FIRST-OF(craprai.nritetop)   THEN    /* Itens do rating */
              DO:   
                  CREATE tt-impressao-rating.      
                  ASSIGN tt-impressao-rating.nrtopico = craprat.nrtopico
                         tt-impressao-rating.nritetop = craprai.nritetop
                         tt-impressao-rating.nrseqite = 0
                         tt-impressao-rating.dsitetop = STRING(craprat.nrtopico,"z9") +
                                                        "." +
                                                        STRING(craprai.nritetop,"z9") + 
                                                        " " +
                                                        craprai.dsitetop   
                         tt-impressao-rating.dspesoit = "(" +
                            STRING(craprai.pesoitem,"zz9.99") + " )".
              END.

         IF   par_flgcriar       OR
              NOT par_flgcalcu   THEN
              FIND crapras WHERE crapras.cdcooper = par_cdcooper       AND
                                 crapras.nrdconta = par_nrdconta       AND
                                 crapras.nrctrrat = par_nrctrato       AND
                                 crapras.tpctrrat = par_tpctrato       AND
                                 crapras.nrtopico = craprad.nrtopico   AND
                                 crapras.nritetop = craprad.nritetop   AND
                                 crapras.nrseqite = craprad.nrseqite
                                 NO-LOCK NO-ERROR.
         ELSE
              FIND  tt-crapras WHERE tt-crapras.nrtopico = craprad.nrtopico   AND
                                    tt-crapras.nritetop = craprad.nritetop   AND
                                    tt-crapras.nrseqite = craprad.nrseqite
                                    NO-LOCK NO-ERROR.


         IF   AVAILABLE crapras     OR 
              AVAILABLE tt-crapras  THEN  
              DO: 
                 IF  craprat.intopico = 1  THEN
                     ASSIGN aux_notacoop = aux_notacoop + 
                                           (craprai.pesoitem * craprad.pesosequ).
                     
                 ASSIGN aux_vlrdnota = craprai.pesoitem * craprad.pesosequ.
                      
              END.
         ELSE
              DO:
                  ASSIGN aux_vlrdnota = 0.
                
              END.


         /* Cria somente aqueles que ele pontuou */
         IF   aux_vlrdnota > 0  THEN
              DO:
                  /* Sequencia do rating */
                  CREATE tt-impressao-rating.
                  ASSIGN tt-impressao-rating.nrtopico = craprat.nrtopico
                         tt-impressao-rating.nritetop = craprai.nritetop
                         tt-impressao-rating.nrseqite = craprad.nrseqite
                         tt-impressao-rating.dsitetop = 
                                    TRIM(STRING(craprat.nrtopico,"z9")) + 
                                    "."                            +
                                    TRIM(STRING(craprai.nritetop,"z9")) +
                                    "."                            +
                                    TRIM(STRING(craprad.nrseqite,"z9")) +
                                    " "                                 +
                                    craprad.dsseqite 
                         tt-impressao-rating.dspesoit = 
                             STRING(craprad.pesosequ,"z9.99")
                         
                         tt-impressao-rating.dspesoit = 
                                    tt-impressao-rating.dspesoit   +
                                    "   " + STRING (aux_vlrdnota,"z9.99").
              END.
         
         ASSIGN aux_vlrtotal = aux_vlrtotal + aux_vlrdnota.
                                                                          
    END. /* Fim do calculo do rating  */   
     
            
    /* Obter informacoes como a descricao do risco,  */
    /* Provisao etc .. */
    RUN descricoes_risco (INPUT par_cdcooper,
                          INPUT crapass.inpessoa,
                          INPUT aux_vlrtotal,
                          INPUT aux_notacoop,
                          INPUT 0,
                          OUTPUT TABLE tt-impressao-risco,
                          OUTPUT TABLE tt-impressao-risco-tl).


    ASSIGN aux_dsmesref = "Janeiro,Fevereiro,Marco,Abril,Maio,Junho," +
                          "Julho,Agosto,Setembro,Outubro,Novembro,Dezembro".



    /* Tabela com o operador e responsavel para assinatura **/
    CREATE tt-impressao-assina.
    ASSIGN tt-impressao-assina.dsdedata = STRING(DAY(par_dtmvtolt),"99") + " de " +
                                          ENTRY(MONTH(par_dtmvtolt),aux_dsmesref) +
                                          " de " + STRING(YEAR(par_dtmvtolt)) 
           tt-impressao-assina.nmoperad = crapope.nmoperad
           tt-impressao-assina.dsrespon = "RESPONSAVEL".


    FIND crapnrc WHERE crapnrc.cdcooper = par_cdcooper   AND
                       crapnrc.nrdconta = par_nrdconta   AND
                       crapnrc.tpctrrat = par_tpctrato   AND
                       crapnrc.nrctrrat = par_nrctrato  
                       NO-LOCK NO-ERROR.

    

    IF   AVAIL crapnrc     AND
         crapnrc.flgorige  THEN
         DO:
             /* Achar o efetivo */
             FIND crapnrc WHERE crapnrc.cdcooper = par_cdcooper   AND
                                crapnrc.nrdconta = par_nrdconta   AND
                                crapnrc.insitrat = 2
                                NO-LOCK NO-ERROR.

             RUN descricao-operacao (INPUT crapnrc.tpctrrat,
                                     OUTPUT aux_dsdopera).

             RUN valor-operacao (INPUT  par_cdcooper,
                                 INPUT  par_nrdconta,
                                 INPUT  crapnrc.tpctrrat,
                                 INPUT  crapnrc.nrctrrat,
                                 OUTPUT aux_vloperac).

             IF crapnrc.indrisco = "AA" THEN
                ASSIGN aux_indrisco = "A".
             ELSE
                ASSIGN aux_indrisco = crapnrc.indrisco.

             CREATE tt-efetivacao.
             ASSIGN tt-efetivacao.idseqmen = 2
                    tt-efetivacao.dsdefeti = 
                        "Efetivado para a Central de Risco" +
                        " o risco '" + aux_indrisco  + "' do contrato nº " +
                        TRIM(STRING(crapnrc.nrctrrat,"z,zzz,zzz,zz9"))             +
                        " do " + aux_dsdopera + " no valor de R$ "             +
                        TRIM(STRING(aux_vloperac,"zz,zzz,zz9.99")) + ".".        
                                  
         END.

         
            
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Verificar se o Rating tem que ser criado.
*****************************************************************************/

PROCEDURE verifica_criacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
                                                                 
    DEF OUTPUT PARAM TABLE FOR tt-erro.        
    DEF OUTPUT PARAM par_flgcriar AS LOGI                            NO-UNDO.


    DEF  VAR         par_dsliquid AS CHAR                            NO-UNDO.
    DEF  VAR         par_vlutiliz AS DECI                            NO-UNDO.
    DEF  VAR         aux_vlrating AS DECI                            NO-UNDO.
    DEF  VAR         aux_vlmaxleg AS DECI                            NO-UNDO.
    DEF  VAR         aux_flgbndes AS LOGI                            NO-UNDO.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.

    DO WHILE TRUE:

       IF   par_tpctrato = 90   THEN
            DO:
                FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                                   crawepr.nrdconta = par_nrdconta   AND
                                   crawepr.nrctremp = par_nrctrato
                                   NO-LOCK NO-ERROR.

                IF   AVAIL crawepr   THEN  /* Emprestimos a liquidar  */ 
                     DO: 
                         RUN traz_liquidacoes (INPUT crawepr.nrctrliq,
                                               OUTPUT par_dsliquid).                     END.
                ELSE
                     ASSIGN aux_flgbndes = TRUE.
                     
            END.
       ELSE
             par_dsliquid = "".

       /* Saldo utilizado */
       RUN calcula_endividamento (INPUT  par_cdcooper,
                                  INPUT  par_cdagenci,
                                  INPUT  par_nrdcaixa,
                                  INPUT  par_cdoperad,
                                  INPUT  par_idorigem,
                                  INPUT  par_nrdconta,
                                  INPUT  par_dsliquid, 
                                  INPUT  par_idseqttl,
                                  INPUT  par_dtmvtolt,
                                  INPUT  par_dtmvtopr,
                                  INPUT  par_inproces,
                                  OUTPUT par_vlutiliz).

       IF   RETURN-VALUE <> "OK"   THEN
            RETURN "NOK".

       /* Cadastrado na TAB036 */
       RUN parametro_valor_rating (INPUT  par_cdcooper,
                                   OUTPUT aux_vlrating).
       
       IF  RETURN-VALUE <> "OK" THEN
           LEAVE.

       /* Cadastrado na CADCOP */
       RUN valor_maximo_legal (INPUT  par_cdcooper,
                               OUTPUT aux_vlmaxleg).

       IF   RETURN-VALUE <> "OK" THEN
            LEAVE.

       /* Operacao atual maior/igual  do que */ 
       /* valor Rating ou 5 % PR  */ 
           IF   par_vlutiliz >= aux_vlrating        OR
                par_vlutiliz >= (aux_vlmaxleg / 3)  THEN
            DO: 
                par_flgcriar = TRUE.
            END.
        ELSE /* Se ja existe é porq esta atualizando */
        IF  CAN-FIND (crapnrc WHERE 
                      crapnrc.cdcooper = par_cdcooper   AND
                      crapnrc.nrdconta = par_nrdconta   AND
                      crapnrc.tpctrrat = par_tpctrato   AND
                      crapnrc.nrctrrat = par_nrctrato)  THEN
            DO:
                par_flgcriar = TRUE.
            END.

       LEAVE.

    END.  /* Fim tratamento criticas */

    IF   aux_cdcritic <> 0    AND
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).  
             RETURN "NOK".

         END.
     ELSE DO:
         IF  par_flgcriar = FALSE AND
             aux_flgbndes = TRUE THEN DO:

             ASSIGN aux_cdcritic = 0
                    aux_dscritic = "Valor utilizado pelo cooperado " +
                                    "nao permite efetivacao!".

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).  
             RETURN "NOK".
         END.
     END.

   RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Trata da verificacao da efetivacao do Rating. 
*****************************************************************************/

PROCEDURE verifica_efetivacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrnotrat AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vlutiliz AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
                                                                 
    DEF OUTPUT PARAM TABLE FOR tt-erro.                              
    DEF OUTPUT PARAM par_flgefeti AS LOGI                            NO-UNDO.

    
    DEF  VAR         aux_vlrating AS DECI                            NO-UNDO.
    DEF  VAR         aux_vlmaxleg AS DECI                            NO-UNDO.

    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
           
    EMPTY TEMP-TABLE tt-erro.      

    ASSIGN par_flgefeti = FALSE.

    DO WHILE TRUE:
         
        /* Cadastrado na TAB036 */
       RUN parametro_valor_rating (INPUT  par_cdcooper,
                                   OUTPUT aux_vlrating).
       
       IF  RETURN-VALUE <> "OK" THEN
           LEAVE.

       /* Cadastrado na CADCOP */
       RUN valor_maximo_legal (INPUT  par_cdcooper,
                               OUTPUT aux_vlmaxleg).

       IF   RETURN-VALUE <> "OK" THEN
            LEAVE.

       /* Valor deve estar acima do legal */
       IF   NOT (par_vlutiliz >= aux_vlrating        OR    
                 par_vlutiliz >= (aux_vlmaxleg / 3))  THEN   
            DO:
                LEAVE.
            END.
                                  
       /* Rating efetivo */
       FIND crapnrc WHERE crapnrc.cdcooper = par_cdcooper  AND
                          crapnrc.nrdconta = par_nrdconta  AND
                          crapnrc.insitrat = 2 /* Efetivo */
                          NO-LOCK NO-ERROR.
       
       IF   AVAIL crapnrc   THEN /* Se tem um Rating Efetivado */
            DO:                       
                /*  Se o Rating da operacao atual for
                    pior que o Rating efetivo ... efetiva */
                                           
                IF   crapnrc.nrnotrat < par_nrnotrat THEN
                     DO:   
                         ASSIGN par_flgefeti = TRUE.  /* Efetivar */                                                                                                  
                     END.   

                /* Se o RATING for o antigo , sempre migra para o novo */
                IF   crapnrc.tpctrrat = 0   AND
                     crapnrc.nrctrrat = 0   THEN
                     DO:
                         ASSIGN par_flgefeti = TRUE.
                     END.                    
                     
            END.
       ELSE      /* Nao existe nenhum Rating Efetivo */
            DO:    
                ASSIGN par_flgefeti = TRUE.   /* Efetivar */                                        
            END.
                               
       LEAVE.
       
    END. /* Fim do DO WHILE TRUE , tratamento de Criticas */

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
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


PROCEDURE efetivar_rating:
                                                                    
    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_vlutiliz AS DECI                             NO-UNDO.
    DEF  INPUT PARAM par_flgatual AS LOGI                             NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-efetivacao.
    DEF OUTPUT PARAM TABLE FOR tt-ratings.

    DEF  VAR         par_rowidnrc AS ROWID                            NO-UNDO.
    DEF  VAR         par_indrisco AS CHAR                             NO-UNDO.
    DEF  VAR         aux_nrctrrat AS INTE                             NO-UNDO.
    DEF  VAR         par_dsoperac AS CHAR                             NO-UNDO.
    DEF  VAR         aux_vloperac AS DECI                             NO-UNDO.
    DEF VAR          aux_indrisco AS CHAR FORMAT "x(1)"               NO-UNDO.


    EMPTY TEMP-TABLE tt-efetivacao.
    EMPTY TEMP-TABLE tt-ratings.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
           
    /* Se tiver um Rating efetivo, mudar para proposto */
    RUN muda_situacao_proposto (INPUT par_cdcooper,
                                INPUT par_nrdconta,
                                INPUT par_dtmvtolt,
                                INPUT par_vlutiliz).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /* Procura o Rating proposto de pior nota */
    RUN procura_pior_nota (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           OUTPUT par_indrisco,
                           OUTPUT par_rowidnrc,
                           OUTPUT aux_nrctrrat,
                           OUTPUT par_dsoperac).
        
    /* Efetivar o rating de pior nota */
    RUN muda_situacao_efetivo (INPUT par_rowidnrc,
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT par_vlutiliz,
                               INPUT par_flgatual).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    RUN ratings-cooperado (INPUT par_cdcooper,
                           INPUT 0,  /* Todos os PACS */ 
                           INPUT par_cdoperad,
                           INPUT par_idorigem,
                           INPUT par_dtmvtolt,
                           INPUT ?,
                           INPUT par_nrdconta,
                           INPUT 0,
                           INPUT 0,
                           INPUT ?,
                           INPUT ?,
                           INPUT 0,
                           INPUT par_inproces,
                           OUTPUT TABLE tt-ratings).

    /* Quando esta voltando atras operacao*/
    /* Ele grava como origem aquele q estiver sendo efetivado */
    IF   par_tpctrato = 0   AND
         par_nrctrato = 0   THEN
         RUN grava_rating_origem (INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT par_rowidnrc,
                                  INPUT 0,
                                  INPUT 0).
    ELSE /* Senao grava aquele que realmente originou o efetivo */
         RUN grava_rating_origem (INPUT par_cdcooper,
                                  INPUT par_nrdconta,
                                  INPUT ?,
                                  INPUT par_tpctrato, 
                                  INPUT par_nrctrato).
              
    CREATE tt-efetivacao.                
    ASSIGN tt-efetivacao.idseqmen = 1
           tt-efetivacao.dsdefeti = "Efetivado para a Central de Risco "    +
                                    "o risco " + par_indrisco               + 
                                    " do contrato " +  STRING(aux_nrctrrat) +
                                    "." .       
    /* Rating efetivo */
    FIND tt-ratings WHERE tt-ratings.insitrat = 2 NO-LOCK NO-ERROR.

    IF   AVAIL tt-ratings   THEN
         DO:    
             RUN valor-operacao (INPUT par_cdcooper,
                                 INPUT par_nrdconta,
                                 INPUT tt-ratings.tpctrrat,
                                 INPUT tt-ratings.nrctrrat,
                                 OUTPUT aux_vloperac).

             IF tt-ratings.indrisco = "AA" THEN
                ASSIGN aux_indrisco = "A".
             ELSE
                ASSIGN aux_indrisco = tt-ratings.indrisco.


             CREATE tt-efetivacao.
             ASSIGN tt-efetivacao.idseqmen = 2
                    tt-efetivacao.dsdefeti =
                       "Efetivado para a Central de Risco o risco '" + 
                       aux_indrisco  + "' do contrato nº "    + 
                       TRIM(STRING(tt-ratings.nrctrrat,"z,zzz,zzz,zz9")) + 
                       " do " + tt-ratings.dsdopera                  + 
                       " no valor de R$ "                            + 
                       TRIM(STRING(aux_vloperac,"zz,zzz,zz9.99"))    + ".".

         END.

    RETURN "OK".

END PROCEDURE.


/***************************************************************************
Procedure que traz todas as informacoes de todos os ratings do cooperado.
Usada na ATURAT e na hora de alteracao dos ratings.
***************************************************************************/

PROCEDURE ratings-cooperado:
         
    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrctrrat AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_tpctrrat AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_dtinirat AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_dtfinrat AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_insitrat AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                             NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-ratings.


    DEF  VAR         aux_vloperac AS DECI                             NO-UNDO.
  

    EMPTY TEMP-TABLE tt-ratings.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
           
    FOR EACH crapnrc WHERE crapnrc.cdcooper = par_cdcooper    AND
                           crapnrc.flgativo = YES             AND

                          (crapnrc.nrdconta = par_nrdconta    OR                          
                           par_nrdconta     = 0)              AND
                                                                          
                          (crapnrc.dtmvtolt >= par_dtinirat   OR
                           par_dtinirat      = ?)             AND
                             
                          (crapnrc.dtmvtolt <= par_dtfinrat   OR
                           par_dtfinrat      = ?)             AND
                                                                        
                          (crapnrc.insitrat = par_insitrat    OR
                           par_insitrat     = 0)              NO-LOCK,

        FIRST crapass WHERE crapass.cdcooper = crapnrc.cdcooper   AND
                            crapass.nrdconta = crapnrc.nrdconta   AND
                           (crapass.cdagenci = par_cdagenci OR
                            par_cdagenci     = 0)                 NO-LOCK
                            BY crapnrc.insitrat DESC
                               BY crapnrc.nrnotrat DESC 
                                  BY crapnrc.dtmvtolt:

        RUN valor-operacao (INPUT crapnrc.cdcooper,
                            INPUT crapnrc.nrdconta,
                            INPUT crapnrc.tpctrrat,
                            INPUT crapnrc.nrctrrat,
                            OUTPUT aux_vloperac).

        CREATE tt-ratings. 
        ASSIGN tt-ratings.cdagenci = crapass.cdagenci
               tt-ratings.nrdconta = crapnrc.nrdconta
               tt-ratings.nrctrrat = crapnrc.nrctrrat
               tt-ratings.tpctrrat = crapnrc.tpctrrat
               tt-ratings.indrisco = crapnrc.indrisco
               tt-ratings.dtmvtolt = crapnrc.dtmvtolt            
               tt-ratings.dteftrat = crapnrc.dteftrat
               tt-ratings.cdoperad = crapnrc.cdoperad
               tt-ratings.insitrat = crapnrc.insitrat
               tt-ratings.nrnotrat = crapnrc.nrnotrat
               tt-ratings.nrnotatl = crapnrc.nrnotatl
               tt-ratings.inrisctl = crapnrc.inrisctl
               tt-ratings.vlutlrat = crapnrc.vlutlrat
               tt-ratings.flgorige = crapnrc.flgorige
               tt-ratings.vloperac = aux_vloperac 
                                     WHEN aux_vloperac <> 0.

        RUN descricao-operacao (INPUT  tt-ratings.tpctrrat,
                                OUTPUT tt-ratings.dsdopera).

        RUN descricao-situacao (INPUT  tt-ratings.insitrat,
                                OUTPUT tt-ratings.dsditrat).
                         
    END.  /* Fim das leituras do Rating */    

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Procedure que traz os ratings impressos nas propostas de credito.
******************************************************************************/

PROCEDURE ratings-impressao:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrctrrat AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_tpctrrat AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                             NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-ratings.

    DEF  VAR         bkp_vloperac AS DECI                             NO-UNDO.
    DEF  VAR         aux_vloperac AS DECI                             NO-UNDO.
    DEF  VAR         aux_rowidnrc AS ROWID                            NO-UNDO.

    EMPTY TEMP-TABLE tt-ratings.


    /* Ratings Ativos propostos - Pegar o de nota maior e maior valor */
    FOR EACH crapnrc WHERE crapnrc.cdcooper = par_cdcooper   AND
                           crapnrc.nrdconta = par_nrdconta   AND
                           crapnrc.flgativo = YES            AND
                           crapnrc.insitrat = 1              NO-LOCK
                           BREAK BY crapnrc.nrnotrat DESC:
           
        RUN valor-operacao (INPUT crapnrc.cdcooper,
                            INPUT crapnrc.nrdconta,
                            INPUT crapnrc.tpctrrat,
                            INPUT crapnrc.nrctrrat,
                            OUTPUT aux_vloperac).

        IF   aux_vloperac > bkp_vloperac   THEN
             ASSIGN bkp_vloperac = aux_vloperac
                    aux_rowidnrc = ROWID(crapnrc).

        IF   LAST-OF(crapnrc.nrnotrat)   THEN
             LEAVE.

    END.

    /* Garavar Rating efetivo , da proposta atual e o proposto de pior nota */
    FOR EACH crapnrc WHERE  crapnrc.cdcooper = par_cdcooper   AND
                            crapnrc.nrdconta = par_nrdconta   AND
                            crapnrc.flgativo = YES            NO-LOCK,
        
        FIRST crapass WHERE crapass.cdcooper = crapnrc.cdcooper AND
                            crapass.nrdconta = crapnrc.nrdconta NO-LOCK
                            BY crapnrc.insitrat DESC:

        IF  (crapnrc.insitrat = 2)             OR 
            
            (crapnrc.tpctrrat = par_tpctrrat AND 
             crapnrc.nrctrrat = par_nrctrrat)  OR  
             
            (ROWID(crapnrc) = aux_rowidnrc)    THEN

            DO:
                RUN valor-operacao (INPUT crapnrc.cdcooper,
                                    INPUT crapnrc.nrdconta,
                                    INPUT crapnrc.tpctrrat,
                                    INPUT crapnrc.nrctrrat,
                                   OUTPUT aux_vloperac).
                               
                CREATE tt-ratings. 
                ASSIGN tt-ratings.nrctrrat = crapnrc.nrctrrat
                       tt-ratings.tpctrrat = crapnrc.tpctrrat
                       tt-ratings.indrisco = crapnrc.indrisco
                       tt-ratings.insitrat = crapnrc.insitrat
                       tt-ratings.nrnotrat = crapnrc.nrnotrat
                       tt-ratings.nrnotatl = crapnrc.nrnotatl
                       tt-ratings.vloperac = aux_vloperac 
                                             WHEN aux_vloperac <> 0.

                RUN descricao-operacao (INPUT tt-ratings.tpctrrat,
                                       OUTPUT tt-ratings.dsdopera).
                 
                RUN descricao-situacao (INPUT tt-ratings.insitrat,
                                       OUTPUT tt-ratings.dsditrat).
           
                RUN descricoes_risco (INPUT par_cdcooper,
                                      INPUT crapass.inpessoa,
                                      INPUT tt-ratings.nrnotrat,
                                      INPUT tt-ratings.nrnotatl,
                                      INPUT 0,
                                     OUTPUT TABLE tt-impressao-risco,
                                     OUTPUT TABLE tt-impressao-risco-tl).

                FIND FIRST tt-impressao-risco NO-LOCK NO-ERROR.

                /* Descricao do RISCO (Baixo, alto , medio , etc ... ) */
                IF   AVAIL tt-impressao-risco  THEN
                     ASSIGN tt-ratings.dsdrisco =
                                 tt-impressao-risco.dsparece.              
            END.         
    END.

    /* O registro crapnrc do Rating pode nao existir (proposta de operacao) */
    /* Entao cria ele aqui */

    /* Criar proposta atual , se lançada a operacao nao entra */  
    IF   NOT CAN-FIND (tt-ratings WHERE 
                       tt-ratings.tpctrrat = par_tpctrrat   AND
                       tt-ratings.nrctrrat = par_nrctrrat)   THEN
         DO:
             RUN calcula-rating (INPUT par_cdcooper,
                                 INPUT 0,
                                 INPUT 0,
                                 INPUT par_cdoperad,
                                 INPUT par_dtmvtolt,
                                 INPUT par_dtmvtopr,
                                 INPUT par_inproces,
                                 INPUT par_nrdconta,
                                 INPUT par_tpctrrat,
                                 INPUT par_nrctrrat,
                                 INPUT FALSE,
                                 INPUT TRUE,
                                 INPUT 1,
                                 INPUT par_idorigem,
                                 INPUT "b1wgen0043",
                                 INPUT FALSE,
                                OUTPUT TABLE tt-erro,
                                OUTPUT TABLE tt-impressao-coop,
                                OUTPUT TABLE tt-impressao-rating,
                                OUTPUT TABLE tt-impressao-risco,
                                OUTPUT TABLE tt-impressao-risco-tl,
                                OUTPUT TABLE tt-impressao-assina,
                                OUTPUT TABLE tt-efetivacao,
                                OUTPUT TABLE tt-ratings).
                                          
             IF   RETURN-VALUE <> "OK"   THEN
                  RETURN "OK".

             FIND FIRST tt-impressao-risco NO-LOCK NO-ERROR.

             CREATE tt-ratings.
             ASSIGN tt-ratings.nrdconta = par_nrdconta
                    tt-ratings.nrctrrat = par_nrctrrat
                    tt-ratings.tpctrrat = par_tpctrrat
                    tt-ratings.indrisco = tt-impressao-risco.dsdrisco
                                          WHEN AVAIL tt-impressao-risco
                    tt-ratings.nrnotrat = tt-impressao-risco.vlrtotal
                                          WHEN AVAIL tt-impressao-risco
                    tt-ratings.dsdrisco = tt-impressao-risco.dsparece
                                          WHEN AVAIL tt-impressao-risco.

             RUN descricao-operacao (INPUT  tt-ratings.tpctrrat,
                                     OUTPUT tt-ratings.dsdopera).                           
         END.
            
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Procedure para atualizar ratings efetivos. Se existir algum rating com nota
 pior do que este entao efetiva o de pior nota.                                                                              
*****************************************************************************/

PROCEDURE atualiza_rating:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_rowidnrc AS ROWID                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                             NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.   
    DEF OUTPUT PARAM TABLE FOR tt-efetivacao.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-risco-tl.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Atualizar o Rating do cooperado.".

    DO WHILE TRUE:

        FIND crapnrc WHERE crapnrc.cdcooper = par_cdcooper   AND
                           crapnrc.nrdconta = par_nrdconta   AND
                           crapnrc.insitrat = 2 /* Efetivo */
                           NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE crapnrc   THEN
             DO:
                 aux_cdcritic = 925.
                 LEAVE.
             END.

             
        /* Atualiza rating efetivo atualmente */
        RUN calcula-rating (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT par_dtmvtopr,
                            INPUT par_inproces,
                            INPUT par_nrdconta,
                            INPUT crapnrc.tpctrrat,
                            INPUT crapnrc.nrctrrat,
                            INPUT TRUE,  /* Grava   */
                            INPUT TRUE,  /* Calcula */
                            INPUT par_idseqttl,
                            INPUT par_idorigem,
                            INPUT "b1wgen0043",
                            INPUT par_flgerlog,
                            OUTPUT TABLE tt-erro,
                            OUTPUT TABLE tt-impressao-coop,
                            OUTPUT TABLE tt-impressao-rating,
                            OUTPUT TABLE tt-impressao-risco,
                            OUTPUT TABLE tt-impressao-risco-tl,
                            OUTPUT TABLE tt-impressao-assina,
                            OUTPUT TABLE tt-efetivacao,
                            OUTPUT TABLE tt-ratings).  

        /* Se deu erro , ele ja criou critica, entao retorna */
        IF   RETURN-VALUE <> "OK"   THEN
             RETURN "NOK".

        /* Neste caso, o Rating efetivo se mantem o mesmo */
        IF   ROWID(crapnrc) = par_rowidnrc   THEN
             LEAVE.

        /* Rating a efetivar */
        FIND crapnrc WHERE ROWID (crapnrc) = par_rowidnrc
                                 NO-LOCK NO-ERROR.

        RUN efetivar_rating (INPUT  par_cdcooper,
                             INPUT  par_nrdconta,
                             INPUT  0,
                             INPUT  0,
                             INPUT  par_idorigem,
                             INPUT  par_cdoperad,
                             INPUT  par_dtmvtolt,
                             INPUT  crapnrc.vlutlrat,
                             INPUT  FALSE, /* nao esta atualizando */
                             INPUT  par_inproces,
                             OUTPUT TABLE tt-efetivacao,
                             OUTPUT TABLE tt-ratings).
        LEAVE.

    END.  /* Fim tratamento criticas */

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  aux_dscritic,
                                      INPUT  aux_dsorigem,
                                      INPUT  aux_dstransa,
                                      INPUT  FALSE,
                                      INPUT  par_idseqttl,
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_nrdrowid).            
             RETURN "NOK".

         END.

    IF   par_flgerlog   THEN                                
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



/*****************************************************************************
 Verificar se existe algum rating relacionado a proposta em questao.
 Utilizada para verificar se precisa ser re calculado na hora da impressao.
 Se existir pega os dados da tabela crapnrc senao re calcula.
 Chamar procedure para validar os campos obrigatorios do Rating.
*****************************************************************************/

PROCEDURE verifica_rating:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.    
    DEF  INPUT PARAM par_cdagenci AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrctrrat AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_tpctrrat AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                             NO-UNDO.    
    DEF  INPUT PARAM par_idorigem AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                             NO-UNDO.
    DEF  INPUT PARAM par_flgcriar AS LOGICAL                          NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGICAL                          NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_flgcalcu AS LOGI                             NO-UNDO.

                                                    
    DEF VAR          aux_nrgarope AS INTE                             NO-UNDO.
    DEF VAR          aux_nrinfcad AS INTE                             NO-UNDO.
    DEF VAR          aux_nrliquid AS INTE                             NO-UNDO.
    DEF VAR          aux_nrpatlvr AS INTE                             NO-UNDO.
    DEF VAR          aux_nrperger AS INTE                             NO-UNDO.
    DEF VAR          aux_habrat   AS CHAR                             NO-UNDO. /* P450 - Rating */

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

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
      RETURN "OK".
    END.
    /* Habilita novo rating */

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Verifica se existe Rating para a proposta " +
                              "em questao.".

    par_flgcalcu = NOT CAN-FIND (crapnrc WHERE
                                 crapnrc.cdcooper = par_cdcooper   AND
                                 crapnrc.nrdconta = par_nrdconta   AND
                                 crapnrc.nrctrrat = par_nrctrrat   AND
                                 crapnrc.tpctrrat = par_tpctrrat   NO-LOCK).
    DO WHILE TRUE:
       
       IF   par_tpctrrat = 90   THEN  /* Emprestimo */
            DO:
                FIND crapprp WHERE crapprp.cdcooper = par_cdcooper   AND
                                   crapprp.nrdconta = par_nrdconta   AND
                                   crapprp.tpctrato = par_tpctrrat   AND
                                   crapprp.nrctrato = par_nrctrrat
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAILABLE crapprp  THEN
                     DO:
                         aux_cdcritic = 356.
                         LEAVE.
                     END.

                ASSIGN aux_nrgarope = crapprp.nrgarope
                       aux_nrinfcad = crapprp.nrinfcad
                       aux_nrliquid = crapprp.nrliquid
                       aux_nrpatlvr = crapprp.nrpatlvr
                       aux_nrperger = crapprp.nrperger. 

            END.
       ELSE             /* Descontos / Cheque especial */
            DO:                
                  /* Para limite desconto de titulo */
                  IF   par_tpctrrat = 3   THEN
                       DO:
                           FIND crawlim WHERE crawlim.cdcooper = par_cdcooper   AND
                                              crawlim.nrdconta = par_nrdconta   AND
                                              crawlim.tpctrlim = par_tpctrrat   AND
                                              crawlim.nrctrlim = par_nrctrrat 
                                              NO-LOCK NO-ERROR.

                           IF   NOT AVAILABLE crawlim   THEN
                           DO:                
                				FIND craplim WHERE craplim.cdcooper = par_cdcooper   AND
				                                   craplim.nrdconta = par_nrdconta   AND
				                                   craplim.tpctrlim = par_tpctrrat   AND
				                                   craplim.nrctrlim = par_nrctrrat
                                   				   NO-LOCK NO-ERROR.

                				IF   NOT AVAILABLE craplim   THEN
			                    DO:
			                         aux_cdcritic = 484.
			                         LEAVE.
			                    END.

				                ASSIGN aux_nrgarope = craplim.nrgarope
				                       aux_nrinfcad = craplim.nrinfcad
				                       aux_nrliquid = craplim.nrliquid
				                       aux_nrpatlvr = craplim.nrpatlvr
				                       aux_nrperger = craplim.nrperger.
                           END.

	                            ASSIGN aux_nrgarope = crawlim.nrgarope
	                                   aux_nrinfcad = crawlim.nrinfcad
	                                   aux_nrliquid = crawlim.nrliquid
	                                   aux_nrpatlvr = crawlim.nrpatlvr
	                                   aux_nrperger = crawlim.nrperger.
					   END.
					   ELSE     /* Demais operacoes */
						   DO:
							   FIND craplim WHERE craplim.cdcooper = par_cdcooper   AND
												  craplim.nrdconta = par_nrdconta   AND
												  craplim.tpctrlim = par_tpctrrat   AND
												  craplim.nrctrlim = par_nrctrrat
												  NO-LOCK NO-ERROR.
	
							   IF   NOT AVAILABLE craplim   THEN
									DO:
										aux_cdcritic = 484.
										LEAVE.
									END.
	
							   ASSIGN aux_nrgarope = craplim.nrgarope
									  aux_nrinfcad = craplim.nrinfcad
									  aux_nrliquid = craplim.nrliquid
									  aux_nrpatlvr = craplim.nrpatlvr
									  aux_nrperger = craplim.nrperger.
						   END.
            END.

       RUN valida-itens-rating (INPUT par_cdcooper,
                                INPUT par_cdagenci,
                                INPUT par_nrdcaixa,
                                INPUT par_cdoperad,
                                INPUT par_dtmvtolt,
                                INPUT par_nrdconta,
                                INPUT aux_nrgarope,
                                INPUT aux_nrinfcad,
                                INPUT aux_nrliquid,
                                INPUT aux_nrpatlvr,
                                INPUT aux_nrperger,
                                INPUT par_idseqttl,
                                INPUT par_idorigem,
                                INPUT par_nmdatela,
                                INPUT par_flgerlog,
                                OUTPUT TABLE tt-erro).

       IF   RETURN-VALUE <> "OK"   THEN
            DO:
                EMPTY TEMP-TABLE tt-erro.

                ASSIGN aux_cdcritic = 0
                       aux_dscritic = "Campos obrigatorios para o " +
                                      "Rating nao preenchidos.".
                        
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,            /** Sequencia **/
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).

                IF   par_flgerlog  THEN
                     RUN proc_gerar_log (INPUT  par_cdcooper,
                                         INPUT  par_cdoperad,
                                         INPUT  aux_dscritic,
                                         INPUT  aux_dsorigem,
                                         INPUT  aux_dstransa,
                                         INPUT  FALSE,
                                         INPUT  par_idseqttl,
                                         INPUT  par_nmdatela,
                                         INPUT  par_nrdconta,
                                         OUTPUT aux_nrdrowid).
                RETURN "NOK".
            END.
            
       LEAVE.

    END.    /* Fim do Tratamento de criticas */
      
    IF   aux_cdcritic <> 0    THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,            /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
             
             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  aux_dscritic,
                                      INPUT  aux_dsorigem,
                                      INPUT  aux_dstransa,
                                      INPUT  FALSE,
                                      INPUT  par_idseqttl,
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_nrdrowid).            
             RETURN "NOK".

         END.

    IF   par_flgerlog   THEN                                
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


/******************************************************************************
 Quando excluir uma dada operacao, os Ratings tem que voltar atras.
 Opcao "E" da LANCDC, LANCTR, LANCDC.
******************************************************************************/

PROCEDURE volta-atras-rating:

    DEF  INPUT PARAM par_cdcooper  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrrat  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrat  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inproces  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog  AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    DEF  VAR         aux_rowidnrc  AS ROWID                          NO-UNDO.
    DEF  VAR         aux_contador  AS INTE                           NO-UNDO.
    DEF  VAR         aux_vlrating  AS DECI                           NO-UNDO.
    DEF  VAR         aux_vlmaxleg  AS DECI                           NO-UNDO.
    DEF  VAR         aux_flgratin  AS LOGI                           NO-UNDO.
    DEF  VAR         aux_vlutlrat  AS DECI                           NO-UNDO.
    DEF  VAR         aux_indrisco  AS CHAR                           NO-UNDO.
    DEF  VAR         aux_nrctrrat  AS INTE                           NO-UNDO.
    DEF  VAR         aux_dsoperac  AS CHAR                           NO-UNDO.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Voltar atras Rating do cooperado.".

    EMPTY TEMP-TABLE tt-erro.

    DO aux_contador = 1 TO 10:

        FIND crapnrc WHERE crapnrc.cdcooper = par_cdcooper   AND
                           crapnrc.nrdconta = par_nrdconta   AND
                           crapnrc.tpctrrat = par_tpctrrat   AND
                           crapnrc.nrctrrat = par_nrctrrat 
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAILABLE crapnrc  THEN
             IF  LOCKED crapnrc   THEN
                 DO:
                     aux_cdcritic = 77.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
             ELSE    /* Proposta sem Rating associado  */
                 DO: /* Sao operacoes anteriores a liberacao deste projeto */
                     LEAVE.
                 END.

        DELETE crapnrc.

        /* Excluir itens daquele Rating */
        FOR EACH crapras WHERE crapras.cdcooper = par_cdcooper   AND
                               crapras.nrdconta = par_nrdconta   AND
                               crapras.tpctrrat = par_tpctrrat   AND
                               crapras.nrctrrat = par_nrctrrat   
                               EXCLUSIVE-LOCK:

            DELETE crapras.

        END.

        /* Se tem um Rating efetivo ... */
        aux_flgratin = CAN-FIND(crapnrc WHERE 
                                crapnrc.cdcooper = par_cdcooper  AND
                                crapnrc.nrdconta = par_nrdconta  AND
                                crapnrc.insitrat = 2             NO-LOCK).

        IF   aux_flgratin   THEN /* Se tem Rating efetivo , tem que ter origem */
             DO:
                 FIND crapnrc WHERE crapnrc.cdcooper = par_cdcooper   AND
                                    crapnrc.nrdconta = par_nrdconta   AND
                                    crapnrc.flgorige = TRUE
                                    NO-LOCK NO-ERROR.

                 IF   NOT AVAIL crapnrc   THEN /* Se nao tem origem */
                      DO:
                          FIND crapnrc WHERE crapnrc.cdcooper = par_cdcooper  AND
                                             crapnrc.nrdconta = par_nrdconta  AND
                                             crapnrc.insitrat = 2
                                             NO-LOCK NO-ERROR.

                           RUN  grava_rating_origem (INPUT  par_cdcooper,
                                                     INPUT  par_nrdconta,
                                                     INPUT  ROWID (crapnrc),
                                                     INPUT 0,
                                                     INPUT 0).  
                      END.
             END.
        ELSE      /* Se nao tem Rating efetivo, limpa a origem ... */
             DO:
                 RUN limpa_rating_origem (INPUT par_cdcooper,
                                          INPUT par_nrdconta).
             END.

        /* Verificar se o coop. tem valor utilizado mais q o valor legal */
        /* Neste caso ele procura o rating com pior nota e efetiva */
        
        RUN parametro_valor_rating (INPUT  par_cdcooper,
                                    OUTPUT aux_vlrating).

        IF   RETURN-VALUE <> "OK"   THEN
             LEAVE.
            
        RUN valor_maximo_legal (INPUT par_cdcooper,
                                OUTPUT aux_vlmaxleg).

        IF   RETURN-VALUE <> "OK"   THEN
             LEAVE.   

        RUN calcula_endividamento (INPUT par_cdcooper,
                                   INPUT 0,
                                   INPUT 0,
                                   INPUT par_cdoperad,
                                   INPUT par_idorigem,
                                   INPUT par_nrdconta,
                                   INPUT "",
                                   INPUT par_idseqttl,
                                   INPUT par_dtmvtolt,
                                   INPUT par_dtmvtopr,
                                   INPUT par_inproces,
                                   OUTPUT aux_vlutlrat).

        /* Ja traz tt-erro, dar return NOK */
        IF   RETURN-VALUE <> "OK"   THEN
             RETURN "NOK".
      
        /* Saldo utilizado maior que o legal */
        IF   (aux_vlutlrat >= aux_vlrating   OR
              aux_vlutlrat >= (aux_vlmaxleg / 3))  THEN
             DO:
                 IF   NOT aux_flgratin THEN /* Nao tem Rating efetivo */
                      DO:
                          RUN procura_pior_nota (INPUT  par_cdcooper,
                                                 INPUT  par_nrdconta,
                                                 OUTPUT aux_indrisco,
                                                 OUTPUT aux_rowidnrc,
                                                 OUTPUT aux_nrctrrat,
                                                 OUTPUT aux_dsoperac). 
                         
                          /* Se encontrou um Rating para efetivar */
                          IF   aux_rowidnrc <> ?  THEN
                               DO:    
                                   RUN muda_situacao_efetivo
                                                     (INPUT aux_rowidnrc,
                                                      INPUT par_cdoperad,
                                                      INPUT par_dtmvtolt,
                                                      INPUT aux_vlutlrat,
                                                      INPUT FALSE). /* nao atualiza */

                                   RUN grava_rating_origem (INPUT par_cdcooper,
                                                            INPUT par_nrdconta,
                                                            INPUT aux_rowidnrc,
                                                            INPUT 0, 
                                                            INPUT 0).
                                                                                  
                                   IF   RETURN-VALUE <> "OK"  THEN
                                        LEAVE.                                                 
                               END.
                      END.
             END.
        ELSE          /* Saldo utilizado nao eh maior que o legal */
             DO:
                 IF   aux_flgratin   THEN  /*  Se Contem Rating efetivo */
                      DO:
                          RUN muda_situacao_proposto (INPUT par_cdcooper,
                                                      INPUT par_nrdconta,
                                                      INPUT par_dtmvtolt,
                                                      INPUT aux_vlutlrat).

                          IF  RETURN-VALUE <> "OK"   THEN
                              LEAVE. 
                      END.
             END.

        aux_cdcritic = 0.
        LEAVE.

    END. /* Fim tratamento de criticas */
    
    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,  /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
       
             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  aux_dscritic,
                                      INPUT  aux_dsorigem,
                                      INPUT  aux_dstransa,
                                      INPUT  FALSE,
                                      INPUT  par_idseqttl,
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_nrdrowid).            
             RETURN "NOK".

         END.
      
    IF   par_flgerlog   THEN                                
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


/****************************************************************************** 
Verifica se contrato de Empr. esta liquidado para entao desativar Rating.
Verifica se contrato de Empr. voltou a estar em aberto para re-Ativar Rating.  
******************************************************************************/

PROCEDURE verifica_contrato_rating:
                                            
    DEF  INPUT PARAM par_cdcooper  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrrat  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrat  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inproces  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog  AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".


    DO WHILE TRUE:

        FIND crapnrc WHERE crapnrc.cdcooper = par_cdcooper   AND
                           crapnrc.nrdconta = par_nrdconta   AND
                           crapnrc.tpctrrat = par_tpctrrat   AND
                           crapnrc.nrctrrat = par_nrctrrat
                           NO-LOCK NO-ERROR.

        /* Nao existe Rating para esta Operaçao , nada a fazer ... */
        IF   NOT AVAIL crapnrc   THEN
             LEAVE.

        FIND crapepr WHERE crapepr.cdcooper = par_cdcooper   AND
                           crapepr.nrdconta = par_nrdconta   AND
                           crapepr.nrctremp = par_nrctrrat 
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapepr   THEN /* Contrato nao encontrado */
             DO:
                 aux_cdcritic = 356.
                 LEAVE.
             END.

        IF   crapepr.inliquid = 0   THEN /* Em aberto ... */
             DO:
                 IF   NOT crapnrc.flgativo   THEN /* Desativado */
                      DO:            
                          RUN ativa_rating
                                      (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_cdoperad,
                                       INPUT par_dtmvtolt,
                                       INPUT par_dtmvtopr,
                                       INPUT par_nrdconta,
                                       INPUT par_tpctrrat,
                                       INPUT par_nrctrrat,
                                       INPUT TRUE,
                                       INPUT par_idseqttl,
                                       INPUT par_idorigem,
                                       INPUT par_nmdatela,
                                       INPUT par_inproces,
                                       INPUT par_flgerlog,
                                       OUTPUT TABLE tt-erro).

                          IF   RETURN-VALUE <> "OK"  THEN
                               RETURN "NOK".

                      END.              
             END.
        ELSE                              /* Liquidado */
             DO:
                  IF   crapnrc.flgativo   THEN    /* Ativo */
                       DO:
                           RUN desativa_rating 
                                      (INPUT par_cdcooper,
                                       INPUT par_cdagenci,
                                       INPUT par_nrdcaixa,
                                       INPUT par_cdoperad,
                                       INPUT par_dtmvtolt,
                                       INPUT par_dtmvtopr,
                                       INPUT par_nrdconta,
                                       INPUT par_tpctrrat,
                                       INPUT par_nrctrrat,
                                       INPUT TRUE,
                                       INPUT par_idseqttl,
                                       INPUT par_idorigem,
                                       INPUT par_nmdatela,
                                       INPUT par_inproces,
                                       INPUT par_flgerlog,
                                       OUTPUT TABLE tt-erro). 

                           IF  RETURN-VALUE <> "OK"   THEN
                               RETURN "NOK".                       
                       END.                      
             END.
             
        LEAVE.

    END. /* Fim Tratamento de Criticas */

    IF   aux_cdcritic <> 0   OR
         aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,  /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
       
             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  aux_dscritic,
                                      INPUT  aux_dsorigem,
                                      INPUT  aux_dstransa,
                                      INPUT  FALSE,
                                      INPUT  par_idseqttl,
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_nrdrowid).
         END.

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Desativar Rating. Usada quando emprestimo é liquidado ou limite é cancelado.
*****************************************************************************/

PROCEDURE desativa_rating:

    DEF  INPUT PARAM par_cdcooper  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrrat  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrat  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgefeti  AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inproces  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog  AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF  VAR         aux_vlutiliz  AS DECI                           NO-UNDO.       
    DEF  VAR         aux_vlrating  AS DECI                           NO-UNDO.
    DEF  VAR         aux_vlmaxleg  AS DECI                           NO-UNDO.
    DEF  VAR         aux_indrisco  AS CHAR                           NO-UNDO.
    DEF  VAR         aux_rowidnrc  AS ROWID                          NO-UNDO.
    DEF  VAR         aux_contador  AS INTE                           NO-UNDO.
    DEF  VAR         aux_nrctrrat  AS INTE                           NO-UNDO.
    DEF  VAR         aux_dsoperac  AS CHAR                           NO-UNDO.
    DEF  VAR         aux_flgratin  AS LOGI                           NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Desativar o Rating do cooperado.".

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        DO aux_contador = 1 TO 10:

           FIND crapnrc WHERE crapnrc.cdcooper = par_cdcooper  AND
                              crapnrc.nrdconta = par_nrdconta  AND
                              crapnrc.tpctrrat = par_tpctrrat  AND
                              crapnrc.nrctrrat = par_nrctrrat
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.     

           IF   NOT AVAIL crapnrc   THEN
                IF   LOCKED crapnrc   THEN
                     DO:
                         aux_cdcritic = 77.
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
        
           aux_cdcritic = 0.
           LEAVE.

        END. /* Fim lock do crapnrc */

        IF   aux_cdcritic <> 0  THEN
             LEAVE.

         /* Se existe rating para esta proposta */
        IF   AVAILABLE crapnrc   THEN            
             ASSIGN crapnrc.flgativo = FALSE  /* Nao ativo */
                    crapnrc.insitrat = 1      /* Proposto*/
                    crapnrc.dteftrat = ?      /* Limpa efetivacao */
                    crapnrc.flgorige = FALSE. /* Nao é origem */

        VALIDATE crapnrc.

        /* Verifica se tem um Rating efetivo */ 
        aux_flgratin = CAN-FIND(crapnrc WHERE 
                                crapnrc.cdcooper = par_cdcooper   AND
                                crapnrc.nrdconta = par_nrdconta   AND
                                crapnrc.insitrat = 2              NO-LOCK).

        IF   aux_flgratin  THEN
             DO:
                 /* Tem que ter origem */
                 FIND crapnrc WHERE crapnrc.cdcooper = par_cdcooper   AND
                                    crapnrc.nrdconta = par_nrdconta   AND
                                    crapnrc.flgorige = TRUE         
                                    NO-LOCK NO-ERROR.

                 /* Se nao tiver, cria origem como o efetivo */
                 IF   NOT AVAIL crapnrc THEN
                      DO:
                          FIND crapnrc WHERE crapnrc.cdcooper = par_cdcooper  AND
                                             crapnrc.nrdconta = par_nrdconta  AND
                                             crapnrc.insitrat = 2 
                                             NO-LOCK NO-ERROR.
                
                          RUN grava_rating_origem (INPUT  par_cdcooper,
                                                   INPUT  par_nrdconta,
                                                   INPUT  ROWID (crapnrc),
                                                   INPUT 0,
                                                   INPUT 0).                   
                      END.
             END.
        ELSE
             DO:
                 RUN limpa_rating_origem (INPUT par_cdcooper,
                                          INPUT par_nrdconta).
             END.
          
        /*** Fim Tratamento origem do Rating  ***/


        IF   par_flgefeti   THEN /* Efetiva novo Rating */
             DO:
                 /* Saldo utiliza do cooperado */
                 RUN calcula_endividamento (INPUT  par_cdcooper,
                                            INPUT  par_cdagenci,
                                            INPUT  par_nrdcaixa,
                                            INPUT  par_cdoperad,
                                            INPUT  par_idorigem,
                                            INPUT  par_nrdconta,
                                            INPUT  "",
                                            INPUT  par_idseqttl,
                                            INPUT  par_dtmvtolt,
                                            INPUT  par_dtmvtopr, 
                                            INPUT  par_inproces,
                                            OUTPUT aux_vlutiliz).
               
                 /* Se deu erro, ja veio com a critica, retorna */
                 IF   RETURN-VALUE <> "OK"   THEN
                      RETURN "NOK".
                 
                 /* Cadastrado na TAB036 */
                 RUN parametro_valor_rating (INPUT  par_cdcooper,
                                             OUTPUT aux_vlrating).
                 
                 IF  RETURN-VALUE <> "OK" THEN
                     LEAVE.

                 /* Cadastrado na CADCOP */
                 RUN valor_maximo_legal (INPUT  par_cdcooper,
                                         OUTPUT aux_vlmaxleg).
                 
                 IF   RETURN-VALUE <> "OK" THEN
                      LEAVE.
                 
                 /* Se o cooperado esta utilizando mais do que o valor legal */
                 /* E nao tem Rating */
                 IF  (aux_vlutiliz >= aux_vlrating           OR
                      aux_vlutiliz >= (aux_vlmaxleg / 3))    AND
                      NOT aux_flgratin                       THEN
                      DO:
                          RUN procura_pior_nota (INPUT  par_cdcooper,
                                                 INPUT  par_nrdconta,
                                                 OUTPUT aux_indrisco,
                                                 OUTPUT aux_rowidnrc,
                                                 OUTPUT aux_nrctrrat,
                                                 OUTPUT aux_dsoperac). 
                 
                          /* Existe Rating a efetivar */
                          IF   aux_rowidnrc <> ?   THEN
                               DO:
                                   RUN muda_situacao_efetivo (INPUT aux_rowidnrc,
                                                              INPUT par_cdoperad,
                                                              INPUT par_dtmvtolt,
                                                              INPUT aux_vlutiliz,
                                                              INPUT FALSE). /* nao atualiza */

                                   RUN grava_rating_origem (INPUT par_cdcooper,
                                                            INPUT par_nrdconta,
                                                            INPUT aux_rowidnrc,
                                                            INPUT 0, 
                                                            INPUT 0).
                                     
                                   IF   RETURN-VALUE <> "OK"  THEN
                                        LEAVE.
                               END.                             
                      END.
                 
             END.    /* Fim Efetivar novo Rating */


        /* Esta abaixo do valor legal e tem Rating */
        IF   NOT (aux_vlutiliz >= aux_vlrating          OR
                  aux_vlutiliz >= (aux_vlmaxleg / 3))   AND
             aux_flgratin                               THEN
             DO:
                 /* Nao pode ter Rating, entao deixa proposto */
                 RUN muda_situacao_proposto (INPUT par_cdcooper,
                                             INPUT par_nrdconta,
                                             INPUT par_dtmvtolt,
                                             INPUT aux_vlutiliz).

                 IF  RETURN-VALUE <> "OK"   THEN
                     LEAVE.
             END.

        LEAVE.

    END. /* Fim tratamento critica */

    IF   aux_cdcritic <> 0  OR
         aux_dscritic <> ""  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,  /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
       
             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  aux_dscritic,
                                      INPUT  aux_dsorigem,
                                      INPUT  aux_dstransa,
                                      INPUT  FALSE,
                                      INPUT  par_idseqttl,
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_nrdrowid).            
             RETURN "NOK".         
         END.

    IF   par_flgerlog   THEN                                
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


/******************************************************************************
 Re-ativar o Rating do Contrato de Emprestimo (Estorno de pagamento , exclusao
 de lançamento de pagamento)
******************************************************************************/

PROCEDURE ativa_rating:

    DEF  INPUT PARAM par_cdcooper  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_tpctrrat  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrctrrat  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgefeti  AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inproces  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_flgerlog  AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF   VAR        aux_contador  AS INTE                           NO-UNDO.
    DEF   VAR        aux_flgratin  AS LOGI                           NO-UNDO.
    DEF   VAR        aux_vlrating  AS DECI                           NO-UNDO.
    DEF   VAR        aux_vlutiliz  AS DECI                           NO-UNDO.
    DEF   VAR        aux_vlmaxleg  AS DECI                           NO-UNDO.
    DEF   VAR        aux_indrisco  AS CHAR                           NO-UNDO.
    DEF   VAR        aux_rowidnrc  AS ROWID                          NO-UNDO.
    DEF   VAR        aux_nrctrrat  AS INTE                           NO-UNDO.
    DEF   VAR        aux_dsoperac  AS CHAR                           NO-UNDO.


    DEF   BUFFER     crabnrc       FOR crapnrc.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Ativar o Rating do cooperado.".

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        DO aux_contador = 1 TO 10:

           FIND crapnrc WHERE crapnrc.cdcooper = par_cdcooper  AND
                              crapnrc.nrdconta = par_nrdconta  AND
                              crapnrc.tpctrrat = par_tpctrrat  AND
                              crapnrc.nrctrrat = par_nrctrrat 
                              EXCLUSIVE-LOCK NO-ERROR NO-WAIT.     

           IF   NOT AVAIL crapnrc   THEN
                IF   LOCKED crapnrc   THEN
                     DO:
                         aux_cdcritic = 77.
                         PAUSE 1 NO-MESSAGE.
                         NEXT.
                     END.
        
           aux_cdcritic = 0.
           LEAVE.

        END. /* Fim lock do crapnrc */

        IF   aux_cdcritic <> 0  THEN
             LEAVE.

        /* Se nao existe rating para esta proposta */
        IF   NOT AVAILABLE crapnrc   THEN     
             LEAVE.


        /* Se ja esta Ativo */
        IF   crapnrc.flgativo   THEN
             LEAVE.

        /* Saldo utilizado */
        RUN calcula_endividamento (INPUT  par_cdcooper,
                                   INPUT  par_cdagenci,
                                   INPUT  par_nrdcaixa,
                                   INPUT  par_cdoperad,
                                   INPUT  par_idorigem,
                                   INPUT  par_nrdconta,
                                   INPUT  "", 
                                   INPUT  par_idseqttl,
                                   INPUT  par_dtmvtolt,
                                   INPUT  par_dtmvtopr,
                                   INPUT  par_inproces,
                                   OUTPUT aux_vlutiliz).

        IF   RETURN-VALUE <> "OK"   THEN
             RETURN "NOK".


        /* - Re-ativar 
           - Atualiza Valor Utilizado
           - Verifica se tem Rating efetivo */
        ASSIGN crapnrc.flgativo = TRUE
               crapnrc.vlutlrat = aux_vlutiliz 
               aux_flgratin     = CAN-FIND(crapnrc WHERE 
                                           crapnrc.cdcooper = par_cdcooper   AND
                                           crapnrc.nrdconta = par_nrdconta   AND
                                           crapnrc.insitrat = 2).

        VALIDATE crapnrc.
 
        IF   aux_flgratin   THEN /* Tem Rating Efetivo */
             DO:  
                 /* Pegar Rating Efetivo */
                 FIND crabnrc WHERE crabnrc.cdcooper = par_cdcooper   AND
                                    crabnrc.nrdconta = par_nrdconta   AND
                                    crabnrc.insitrat = 2   
                                    NO-LOCK NO-ERROR.
                
                 /* Nota deste contrato é pior do que nota do Efetivo */
                 IF   crapnrc.nrnotrat > crabnrc.nrnotrat   THEN
                      DO:
                          aux_rowidnrc = ROWID(crapnrc).  

                          /* Volta para Proposto o efetivo atual */
                          RUN muda_situacao_proposto 
                                    (INPUT par_cdcooper,
                                     INPUT par_nrdconta,
                                     INPUT par_dtmvtolt,
                                     INPUT aux_vlutiliz). 

                          IF   RETURN-VALUE <> "OK"   THEN
                               LEAVE.


                          /* Efetivar este contrato (pior nota) */
                          RUN muda_situacao_efetivo
                                    (INPUT aux_rowidnrc,
                                     INPUT par_cdoperad,
                                     INPUT par_dtmvtolt,
                                     INPUT aux_vlutiliz,
                                     INPUT FALSE). /* Nao atualiza */

                          IF   RETURN-VALUE <> "OK"   THEN
                               LEAVE.

                          RUN grava_rating_origem
                                    (INPUT par_cdcooper,
                                     INPUT par_nrdconta,
                                     INPUT aux_rowidnrc,
                                     INPUT 0, 
                                     INPUT 0). 

                          IF   RETURN-VALUE <> "OK"   THEN
                               LEAVE.

                      END.
             END.
        ELSE
             DO:   
                 /* Cadastrado na TAB036 */
                 RUN parametro_valor_rating 
                                    (INPUT  par_cdcooper,
                                     OUTPUT aux_vlrating).
       
                 IF  RETURN-VALUE <> "OK" THEN
                     LEAVE.

                 /* Cadastrado na CADCOP */
                 RUN valor_maximo_legal 
                                    (INPUT  par_cdcooper,
                                     OUTPUT aux_vlmaxleg).
                 
                 IF   RETURN-VALUE <> "OK" THEN
                      LEAVE.
                 
                 /* Operacao atual maior/igual  do que */ 
                 /* valor Rating ou 5 % PR  */ 
                 IF   aux_vlutiliz >= aux_vlrating        OR    
                      aux_vlutiliz >= (aux_vlmaxleg / 3)  THEN   
                      DO: 
                          RUN procura_pior_nota
                                    (INPUT  par_cdcooper,
                                     INPUT  par_nrdconta,
                                     OUTPUT aux_indrisco,
                                     OUTPUT aux_rowidnrc,
                                     OUTPUT aux_nrctrrat,
                                     OUTPUT aux_dsoperac). 
                                                    
                          RUN muda_situacao_efetivo
                                    (INPUT aux_rowidnrc,
                                     INPUT par_cdoperad,
                                     INPUT par_dtmvtolt,
                                     INPUT aux_vlutiliz,
                                     INPUT FALSE). /* nao atualiza*/

                          IF   RETURN-VALUE <> "OK"   THEN
                               LEAVE.
                          
                          RUN grava_rating_origem
                                    (INPUT par_cdcooper,
                                     INPUT par_nrdconta,
                                     INPUT aux_rowidnrc,
                                     INPUT 0, 
                                     INPUT 0).
                                                                                  
                          IF   RETURN-VALUE <> "OK"  THEN
                               LEAVE. 

                      END.
             END.

        LEAVE.

    END. /* Fim DO WHILE TRUE */
        
    IF   aux_dscritic <> ""  OR
         aux_cdcritic <> 0   THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,  /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
       
             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  aux_dscritic,
                                      INPUT  aux_dsorigem,
                                      INPUT  aux_dstransa,
                                      INPUT  FALSE,
                                      INPUT  par_idseqttl,
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_nrdrowid). 

             RETURN "NOK".
         END.

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Procedure para trazer o risco na proposta de emprestimo.
******************************************************************************/
PROCEDURE obtem_emprestimo_risco:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.
    DEF  INPUT PARAM par_cdfinemp AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdlcremp AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctrliq AS INTE EXTENT 10                  NO-UNDO.
    DEF  INPUT PARAM par_dsctrliq AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nrctremp AS INTE                            NO-UNDO.	

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_nivrisco AS CHAR                            NO-UNDO.

    DEF VAR aux_dsctrliq AS CHAR                                     NO-UNDO.
    DEF VAR aux_contador AS INTE                                     NO-UNDO.

    /* Usar contratos enviados */    
    IF TRIM(par_dsctrliq) <> "" AND UPPER(TRIM(par_dsctrliq)) <> "SEM LIQUIDACOES" THEN    
       ASSIGN aux_dsctrliq = par_dsctrliq.  

    /* Percorre todos os contratos enviados */
        DO aux_contador = 1 TO EXTENT(par_nrctrliq):
           IF par_nrctrliq[aux_contador] = 0 THEN
              NEXT.

       IF aux_dsctrliq <> "" THEN
          ASSIGN aux_dsctrliq = aux_dsctrliq + ",".
    
       ASSIGN aux_dsctrliq = aux_dsctrliq + STRING(par_nrctrliq[aux_contador]).
        END.

    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
                            
    /* Efetuar a chamada a rotina Oracle */ 
    RUN STORED-PROCEDURE pc_obtem_emprestimo_risco
     aux_handproc = PROC-HANDLE NO-ERROR 
                 ( INPUT par_cdcooper /* pr_cdcooper --> Codigo da cooperativa */
                  ,INPUT par_cdagenci /* pr_cdagenci --> Codigo de agencia */
                  ,INPUT par_nrdcaixa /* pr_nrdcaixa --> Numero do caixa */
                  ,INPUT par_cdoperad /* pr_cdoperad --> Codigo do operador */
                  ,INPUT par_nrdconta /* pr_nrdconta --> Numero da conta */
                  ,INPUT par_idseqttl /* pr_idseqttl --> Sequencial do titular */
                  ,INPUT par_idorigem /* pr_idorigem --> Identificado de oriem */
                  ,INPUT par_nmdatela /* pr_nmdatela --> Nome da tela */
                  ,INPUT (IF par_flgerlog THEN  "S" ELSE "N") /* pr_flgerlog --> identificador se deve gerar log S-Sim e N-Nao */
                  ,INPUT par_cdfinemp /* pr_cdfinemp --> Finalidade do emprestimo */
                  ,INPUT par_cdlcremp /* pr_cdlcremp --> Linha de credito do emprestimo */
                  ,INPUT aux_dsctrliq /* pr_dsctrliq --> Lista de descriçoes de situaçao dos contratos */
                  ,INPUT par_nrctremp /*             --> Número contrato emprestimo - P450 */
                  /* --------- OUT --------- */
                  ,OUTPUT ""          /* pr_nivrisco --> Retorna nivel do risco  */
                  ,OUTPUT ""          /* pr_dscritic --> Descriçao da critica    */
                  ,OUTPUT 0 ).        /* pr_cdcritic --> Codigo da critica).     */
                                        
    /* Fechar o procedimento para buscarmos o resultado */ 
    CLOSE STORED-PROC pc_obtem_emprestimo_risco
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
                            
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
            

    ASSIGN aux_cdcritic = pc_obtem_emprestimo_risco.pr_cdcritic
                             WHEN pc_obtem_emprestimo_risco.pr_cdcritic <> ?
           aux_dscritic = pc_obtem_emprestimo_risco.pr_dscritic
                             WHEN pc_obtem_emprestimo_risco.pr_dscritic <> ?.
        
    IF aux_cdcritic > 0 OR aux_dscritic <> '' THEN
             DO:
         RUN gera_erro (INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1, /*sequencia*/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic).  

         RETURN "NOK".
              END.
              
    ASSIGN par_nivrisco = pc_obtem_emprestimo_risco.pr_nivrisco
                          WHEN pc_obtem_emprestimo_risco.pr_nivrisco <> ?.

    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Verifica se alguma operacao de Credito esta ativa.
 Limite de credito, descontos e emprestimo.
 Usada para ver se o Rating antigo pode ser desativado.
******************************************************************************/

PROCEDURE verifica_operacoes:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.
                                                              
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM par_flgopera AS LOGI                            NO-UNDO.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Verificar se alguma operacao de credito " +
                              "esta ativa".

    DO WHILE TRUE:

        /* Cooperado nao Encontrado */
        IF   NOT CAN-FIND (crapass WHERE crapass.cdcooper = par_cdcooper  AND
                                         crapass.nrdconta = par_nrdconta) THEN
             
             DO:
                 aux_cdcritic = 9.
                 LEAVE.
             END.
           
        /* Emprestimo em aberto ... */
        IF   CAN-FIND (FIRST crapepr WHERE crapepr.cdcooper = par_cdcooper  AND
                                           crapepr.nrdconta = par_nrdconta  AND
                                           crapepr.inliquid = 0 )           THEN
             DO:
                 ASSIGN par_flgopera = TRUE.
                 LEAVE.
             END.

        /* Limite ou desconto ativo ... */
        IF   CAN-FIND (FIRST craplim WHERE craplim.cdcooper = par_cdcooper   AND
                                           craplim.nrdconta = par_nrdconta   AND
                                           craplim.insitlim = 2  /* Ativo*/  AND

                                         ((craplim.tpctrlim = 3              AND   
                                           craplim.dtfimvig > par_dtmvtolt)  OR

                                          (craplim.tpctrlim = 2)             OR

                                          (craplim.tpctrlim = 1))  NO-LOCK) THEN
             DO:
                 ASSIGN par_flgopera = TRUE.
                 LEAVE.
             END.

        ASSIGN par_flgopera = FALSE. /* Nao possui operacao ativa ... */ 

        LEAVE.

    END. /* Fim tratamento criticas */
    
    IF   aux_cdcritic <> 0  THEN
         DO:
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT 1,  /** Sequencia **/
                            INPUT aux_cdcritic,
                            INPUT-OUTPUT aux_dscritic).
       
             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  aux_dscritic,
                                      INPUT  aux_dsorigem,
                                      INPUT  aux_dstransa,
                                      INPUT  FALSE,
                                      INPUT  par_idseqttl,
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_nrdrowid).   
             RETURN "NOK".
         END.

    IF   par_flgerlog   THEN                                
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

/*****************************************************************************
                                PROCEDURES INTERNAS
*****************************************************************************/

/*****************************************************************************
 Mudar situacao do Rating para efetivo.
*****************************************************************************/

PROCEDURE muda_situacao_efetivo:

    DEF INPUT PARAM par_rowidnrc AS ROWID                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                             NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF INPUT PARAM par_vlutiliz AS DECI                             NO-UNDO.
    DEF INPUT PARAM par_flgatual AS LOGI                             NO-UNDO.

    DEF VAR         aux_contador AS INTE                             NO-UNDO.

     /* Locar registro do Rating a efetivar */
    DO aux_contador = 1 TO 10:

        FIND crapnrc WHERE ROWID (crapnrc) = par_rowidnrc
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT. 

        IF   NOT AVAILABLE crapnrc   THEN
             IF   LOCKED crapnrc   THEN
                  DO:
                      aux_cdcritic = 77.
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO:
                      aux_cdcritic = 55.
                      LEAVE.
                  END.

        aux_cdcritic = 0.
        LEAVE.

    END. /* Fim do DO .. TO */

    IF  aux_cdcritic <> 0  THEN
        RETURN "NOK".

    /* Quando o rating for efetivado, atualizar os 
       dados do cooperado */
    DO aux_contador = 1 TO 10:

        FIND crapass WHERE crapass.cdcooper = crapnrc.cdcooper AND
                           crapass.nrdconta = crapnrc.nrdconta
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT. 

        IF   NOT AVAILABLE crapass   THEN
             IF   LOCKED crapass   THEN
                  DO:
                      aux_cdcritic = 77.
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO:
                      aux_cdcritic = 9.
                      LEAVE.
                  END.

        aux_cdcritic = 0.
        LEAVE.

    END. /* Fim do DO .. TO */

    IF  aux_cdcritic <> 0  THEN
        RETURN "NOK".

    /* Se esta atualizando ou criando */
    IF   par_flgatual THEN
         ASSIGN crapnrc.dtmvtolt = par_dtmvtolt.

    /* Passar o Rating para Efetivo */
    ASSIGN crapnrc.insitrat = 2
           crapnrc.cdoperad = par_cdoperad
           crapnrc.dteftrat = par_dtmvtolt
           crapnrc.vlutlrat = par_vlutiliz
           crapass.dtrisctl = crapnrc.dtmvtolt
           crapass.inrisctl = crapnrc.inrisctl
           crapass.nrnotatl = crapnrc.nrnotatl.

    RETURN "OK".

END PROCEDURE.


/****************************************************************************
 Mudar situacao do Rating para Proposto.
****************************************************************************/

PROCEDURE muda_situacao_proposto:

    DEF INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                             NO-UNDO.
    DEF INPUT PARAM par_vlutiliz AS DECI                             NO-UNDO.


    DEF VAR aux_dtmvtolt         AS DATE                             NO-UNDO.
    DEF VAR aux_contador         AS INTE                             NO-UNDO.

   
    /* Desefetuar atual */
    DO aux_contador = 1 TO 10:

       FIND crapnrc WHERE crapnrc.cdcooper = par_cdcooper   AND
                          crapnrc.nrdconta = par_nrdconta   AND
                          crapnrc.insitrat = 2 /* Efetivo*/
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE crapnrc   THEN
            IF   LOCKED crapnrc THEN
                 DO:
                     aux_cdcritic = 77.
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
              
       aux_cdcritic = 0.
       LEAVE.

    END. /* Fim DO .. TO Locked */

    IF   aux_cdcritic <> 0   THEN
         RETURN "NOK".

    /* Se existir passar para proposto */
    IF   AVAILABLE crapnrc   THEN
         DO: 
             aux_dtmvtolt = ADD-INTERVAL(crapnrc.dtmvtolt,6,"MONTHS").

             /* Se hoje eh maior ou igual a efetivacao + 6 meses */
             /* Ou se é um Rating antigo ... entao DESATIVA */

             IF   par_dtmvtolt >= aux_dtmvtolt  OR 
                  (crapnrc.tpctrrat = 0   AND
                   crapnrc.nrctrrat = 0)  THEN
                  DO:
                      /* Desativa Rating*/  
                      ASSIGN crapnrc.flgativo = FALSE.
                  END.

             /* Muda para proposto e atualiza saldo utilizado  */
             ASSIGN crapnrc.insitrat = 1
                    crapnrc.vlutlrat = par_vlutiliz
                    crapnrc.dteftrat = ?.

             /* Como esta desefetivando , limpa a origem do Rating */
             RUN limpa_rating_origem (INPUT par_cdcooper,
                                      INPUT par_nrdconta).

         END.

    RETURN "OK".

END PROCEDURE.

/*****************************************************************************
 Verificar se o item digitado existe.
*****************************************************************************/

PROCEDURE valida-item-rating:

    DEF  INPUT PARAM par_cdcooper  AS INTE                           NO-UNDO.  
    DEF  INPUT PARAM par_cdagenci  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad  AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrtopico  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nritetop  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrseqite  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idseqttl  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem  AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela  AS CHAR                           NO-UNDO.

    DEF OUTPUT PARAM par_flgvalid  AS LOGI                           NO-UNDO.

   
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    par_flgvalid = CAN-FIND (craprad WHERE 
                             craprad.cdcooper = par_cdcooper   AND
                             craprad.nrtopico = par_nrtopico   AND
                             craprad.nritetop = par_nritetop   AND
                             craprad.nrseqite = par_nrseqite   NO-LOCK).
                             

    RETURN "OK".

END PROCEDURE.


PROCEDURE parametro_valor_rating:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF OUTPUT PARAM par_vlrating AS DECI                             NO-UNDO.


    FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                       craptab.nmsistem = "CRED"         AND
                       craptab.tptabela = "GENERI"       AND
                       craptab.cdempres = 00             AND
                       craptab.cdacesso = "PROVISAOCL"   AND
                       craptab.tpregist = 999
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craptab   THEN
         DO:
             aux_cdcritic = 55.
             RETURN "NOK".
         END.

    ASSIGN par_vlrating = DEC(SUBSTRING(craptab.dstextab,15,11)).

    RETURN "OK".

END PROCEDURE.


PROCEDURE valor_maximo_legal:
   
    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF OUTPUT PARAM par_vlmaxleg AS DECI                             NO-UNDO.


    FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcop  THEN
        DO:
            aux_cdcritic = 651.
            RETURN "NOK".
        END.

    par_vlmaxleg = crapcop.vlmaxleg.

    RETURN "OK".

END PROCEDURE.


PROCEDURE procura_pior_nota:

    DEF  INPUT PARAM par_cdcooper AS INTE                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                             NO-UNDO.
    DEF OUTPUT PARAM par_indrisco AS CHAR                             NO-UNDO.
    DEF OUTPUT PARAM par_rowidnrc AS ROWID                            NO-UNDO.
    DEF OUTPUT PARAM par_nrctrrat AS INTE                             NO-UNDO.
    DEF OUTPUT PARAM par_dsoperac AS CHAR                             NO-UNDO.

    /* Pegar o Rating Proposto com pior nota */
    FOR EACH crapnrc WHERE crapnrc.cdcooper = par_cdcooper     AND
                           crapnrc.flgativo = YES              AND
                           crapnrc.nrdconta = par_nrdconta     AND
                           crapnrc.insitrat = 1 /* Proposto*/  
                           NO-LOCK BREAK BY crapnrc.nrnotrat
                                            BY crapnrc.dtmvtolt DESC:
        
        ASSIGN par_rowidnrc = ROWID (crapnrc)
               par_indrisco = crapnrc.indrisco
               par_nrctrrat = crapnrc.nrctrrat. 

        RUN descricao-operacao (INPUT crapnrc.tpctrrat,
                                OUTPUT par_dsoperac).

    END.

    RETURN "OK".

END PROCEDURE.

/***************************************************************************
Procedure para calular o rating para as pessoas fisicas.
***************************************************************************/

PROCEDURE calcula_rating_fisica:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                            NO-UNDO.        
    DEF  INPUT PARAM par_flgcriar AS LOGI                            NO-UNDO.
 
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM aux_vlutiliz AS DECI                            NO-UNDO.

    /* Variaveis para o calculo do rating */
    DEF VAR aux_anodcoop          AS DECI                            NO-UNDO.
    DEF VAR aux_anodexpe          AS DECI                            NO-UNDO.
    DEF VAR aux_vlendivi          AS DECI                            NO-UNDO.  
    DEF VAR aux_vlendiv2          AS DECI                            NO-UNDO.  
    DEF VAR aux_qtdiaatr          AS INTE                            NO-UNDO.
    DEF VAR aux_qtdiapra          AS INTE                            NO-UNDO.
    DEF VAR aux_vlpresta          AS DECI                            NO-UNDO.
    DEF VAR aux_vltotpre          AS DECI                            NO-UNDO.
    DEF VAR aux_nrctrliq          AS INTE EXTENT 10                  NO-UNDO.
    DEF VAR aux_contador          AS INTE                            NO-UNDO.
    DEF VAR aux_vlsalari          AS DECI                            NO-UNDO.
    DEF VAR aux_dtmvtolt          AS DATE                            NO-UNDO.

    DEF VAR par_dsliquid          AS CHAR                            NO-UNDO.
    DEF VAR aux_idqualif          AS INTE                            NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
    EMPTY TEMP-TABLE tt-ocorren.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    /* Todo o tratamento de criticas (fisica) esta aqui */
    RUN criticas_rating_fis (INPUT par_cdcooper,
                             INPUT par_nrdconta,
                             INPUT par_tpctrato,
                             INPUT par_nrctrato,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE <> "OK"   THEN
        RETURN "NOK".

    FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                       crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

    FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND  
                       crapttl.nrdconta = par_nrdconta   AND
                       crapttl.idseqttl = 1              NO-LOCK NO-ERROR.
                                              
    FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper   AND 
                            crapenc.nrdconta = par_nrdconta   AND
                            crapenc.idseqttl = 1              AND
                            crapenc.tpendass = 10
                            NO-LOCK NO-ERROR.

    /* Para Risco Cooperado o calculo eh diferenciado */
    IF  par_tpctrato <> 0  AND
        par_nrctrato <> 0  THEN
    DO:
             /* REGISTROS NECESSARIOS */
        IF   par_tpctrato = 90   THEN  /* Emprestimo/Financiamento */
             DO:                 
                 FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                                    crawepr.nrdconta = par_nrdconta   AND
                                    crawepr.nrctremp = par_nrctrato 
                                    NO-LOCK NO-ERROR.
    
                 FIND crapprp WHERE crapprp.cdcooper = par_cdcooper   AND
                                    crapprp.nrdconta = par_nrdconta   AND
                                    crapprp.tpctrato = par_tpctrato   AND
                                    crapprp.nrctrato = par_nrctrato
                                    NO-LOCK NO-ERROR.
    
                 IF  AVAIL crawepr THEN
                     FIND craplcr WHERE craplcr.cdcooper = par_cdcooper   AND
                                        craplcr.cdlcremp = crawepr.cdlcremp
                                        NO-LOCK NO-ERROR.                        
             END.
        ELSE
             DO:
                  /* Para limite desconto de titulo */
                  IF   par_tpctrato = 3   THEN
                       DO:
                           FIND crawlim WHERE crawlim.cdcooper = par_cdcooper   AND
                                              crawlim.nrdconta = par_nrdconta   AND
                                              crawlim.tpctrlim = par_tpctrato   AND
                                              crawlim.nrctrlim = par_nrctrato 
                                    NO-LOCK NO-ERROR.
                     
                           IF   NOT AVAILABLE crawlim   THEN
                                DO:
							         FIND craplim WHERE craplim.cdcooper = par_cdcooper   AND
							                            craplim.nrdconta = par_nrdconta   AND
							                            craplim.tpctrlim = par_tpctrato   AND
							                            craplim.nrctrlim = par_nrctrato   
							                            NO-LOCK NO-ERROR.
             					END.
						END.
		                ELSE     /* Demais operacoes */
		                   DO:
		                       FIND craplim WHERE craplim.cdcooper = par_cdcooper   AND
		                                          craplim.nrdconta = par_nrdconta   AND
		                                          craplim.tpctrlim = par_tpctrato   AND
		                                          craplim.nrctrlim = par_nrctrato   
		                                          NO-LOCK NO-ERROR.
		                   END.
             END.
    END.

    /*************************************************************************
     Item 1_1 - Quanto tempo o associado opera com a Cooperativa. Anos exatos 
    *************************************************************************/
   
    ASSIGN aux_anodcoop = (INTERVAL(par_dtmvtolt,crapass.dtadmiss,"DAYS") / 365)
 
           aux_nrseqite = IF   aux_anodcoop > 3    THEN
                               1
                          ELSE
                          IF   aux_anodcoop  >= 1  THEN
                               2
                          ELSE
                               3. 

    ASSIGN aux_dsvalite = STRING(round(aux_anodcoop,2)) + " anos"
           rat_dtadmiss = crapass.dtadmiss.

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  1,
                           INPUT  1,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  aux_dsvalite).
    
    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /************************************************************************* 
     Item 1_2 - Comportamento nas operacoes.    
    *************************************************************************/
    
    /* Do ultimo ano*/
    ASSIGN aux_dtmvtolt = ADD-INTERVAL(par_dtmvtolt, - 1, "YEARS").

    /* Pegar o registro com mais dias de atrasos - Modalidade emprestimo  */
    FOR EACH crapris WHERE crapris.cdcooper  = par_cdcooper   AND    
                           crapris.nrdconta  = par_nrdconta   AND
                           crapris.dtrefere >= aux_dtmvtolt   AND
                           crapris.dtrefere <= par_dtmvtolt - DAY (par_dtmvtolt) AND
                           crapris.inddocto  = 1              AND
                           (crapris.cdmodali = 299 OR crapris.cdmodali = 499) NO-LOCK:
                           
        IF   crapris.qtdiaatr > aux_qtdiaatr   THEN
             ASSIGN aux_qtdiaatr = crapris.qtdiaatr. 
                                                        
    END.
    
    IF   aux_qtdiaatr = 0   THEN 
         DO:
             ASSIGN aux_nrseqite = 1.  /* Sem atrasos  */    
         END.
    ELSE
    IF   aux_qtdiaatr <= 60   THEN
         DO:
             ASSIGN aux_nrseqite = 2.  /* Atraso no maximo 60 dias */
                                       /* Inclusive 0 (zero) dias */ 
         END.
    ELSE
         DO:
             ASSIGN aux_nrseqite = 3.  /* Atraso acima de 60 dias  */
         END.

    IF   par_tpctrato = 90  THEN  /* Emprestimo / Financiamento */
         DO:
             IF  AVAIL crawepr THEN
			     ASSIGN aux_idqualif = DYNAMIC-FUNCTION("verificaQualificacao",
                                            INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT par_nrctrato,
                                            INPUT crawepr.idquapro).

				 IF   aux_idqualif = 3   THEN  /* Renegociacao */
                       ASSIGN aux_nrseqite = 3.
         END.

    ASSIGN aux_dsvalite = STRING(aux_qtdiaatr) + " dias de atraso"
           rat_qtmaxatr = aux_qtdiaatr.
    
    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  1,
                           INPUT  2,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  aux_dsvalite).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".
    
    /************************************************************************* 
     Item 1_3 - Tempo de experiencia na atividade (Emprego).
    *************************************************************************/ 
   
    IF   crapttl.cdnatopc = 8   THEN  /* Aposentado */
         DO:
             ASSIGN aux_nrseqite = 1.
         END.
    ELSE
    IF   crapttl.dtadmemp = ?   THEN  /* Sem experiencia */
         DO:
             ASSIGN aux_nrseqite = 3. /* Considera como ate 1 ano */
         END.
    ELSE     /* Classifica por anos de experiencia */
         DO:
             ASSIGN aux_anodexpe = (INTERVAL(par_dtmvtolt,
                                             crapttl.dtadmemp,"DAYS") / 365) 
            
                    aux_nrseqite = IF   aux_anodexpe >  3   THEN
                                        1
                                   ELSE
                                   IF   aux_anodexpe > 1   THEN
                                        2
                                   ELSE
                                        3.
         END.
    
    ASSIGN aux_dsvalite = STRING(round(aux_anodexpe,2)) + " anos de experiencia"
           rat_dtadmemp = crapttl.dtadmemp
           rat_cdnatocp = crapttl.cdnatopc.

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  1,
                           INPUT  3,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  aux_dsvalite).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /********************************************************************** 
     Item 1_4 - Item Consultas Cadastrais - EXTERNAS (dados da proposta)
    **********************************************************************/
    /* Se ja existe , entao pegar do cadastro */
    IF   CAN-FIND (crapnrc WHERE
                   crapnrc.cdcooper = par_cdcooper   AND
                   crapnrc.nrdconta = par_nrdconta   AND
                   crapnrc.tpctrrat = par_tpctrato   AND
                   crapnrc.nrctrrat = par_nrctrato)  THEN
         DO:
             aux_nrseqite = crapttl.nrinfcad.   
         END.
    ELSE          /* Senao da proposta */
    IF  par_tpctrato <> 0  THEN
         DO:
             IF   par_tpctrato = 90   THEN  /* Emprestimo / Finaciamento */
                  DO:
                      IF  AVAIL crapprp  THEN
                      aux_nrseqite = crapprp.nrinfcad.        
                  END.
             ELSE                          /* Cheque especial / Descontos */ 
                  DO:
                       /* Para limite desconto de titulo */
                       IF   par_tpctrato = 3   THEN
                            DO:
                                IF   AVAIL crawlim   THEN
                                     aux_nrseqite = crawlim.nrinfcad.
                                ELSE
			                      IF  AVAIL craplim  THEN
			                      aux_nrseqite = craplim.nrinfcad.
                            END.
                      ELSE     /* Demais operacoes */
	                  DO:
	                      IF  AVAIL craplim  THEN
	                      aux_nrseqite = craplim.nrinfcad.
	                  END. 
                  END. 
         END.   
  
    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  1,
                           INPUT  4,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  " ").

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".   
    
    /**********************************************************************
     Item 1_5 - Item do Historico do cooperado - Ultimos 12 meses.          
    **********************************************************************/    
      
    RUN historico_cooperado (INPUT  par_cdcooper,
                             INPUT  par_cdagenci,
                             INPUT  par_nrdcaixa,
                             INPUT  par_cdoperad,
                             INPUT  par_dtmvtolt,
                             INPUT  par_nrdconta,                                                           
                             INPUT  par_idorigem,
                             INPUT  par_idseqttl,
                             OUTPUT aux_nrseqite).

    IF   RETURN-VALUE <> "OK" THEN
         RETURN "NOK".

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  1,
                           INPUT  5,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  aux_dsvalite).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /**********************************************************************
     Item 1_6 - Tipo de residencia.
    **********************************************************************/ 
     
    IF AVAIL crapenc THEN
       DO:
          ASSIGN rat_cdsitres = crapenc.incasprp.

    CASE crapenc.incasprp:
        WHEN 1           THEN   aux_nrseqite = 1.      /* Quitado */
        WHEN 2           THEN   aux_nrseqite = 2.    /* Financiado */
        WHEN 4 OR WHEN 5 THEN   aux_nrseqite = 3.  /* Familiar/Cedido */
        WHEN 3           THEN   aux_nrseqite = 4.    /*  Alugado */
              WHEN 0           THEN   aux_nrseqite = 4.    /*  Alugado */

    END CASE. 
       END.
    ELSE
       ASSIGN aux_nrseqite = 4
              rat_cdsitres = 0. /* Alugado */

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  1,
                           INPUT  6,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  " ").
    
    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /********************************************************************
     Item 3_1 - Nivel de comprometimento. (Parcelas versus renda bruta)
     Passou para 1_7
    ********************************************************************/
    IF   par_tpctrato = 90  THEN
         DO:
             IF  AVAIL crawepr THEN DO:
                 ASSIGN aux_vlpresta = crawepr.vlpreemp.
                 
                 /* Contratos que ele esta liquidando */
                 DO aux_contador = 1 TO EXTENT(crawepr.nrctrliq):
            
                     aux_nrctrliq[aux_contador] = 
                         crawepr.nrctrliq[aux_contador].
    
                 END.
             END.
             ELSE /* Operacao BNDES */ 
                 IF   AVAIL crapprp THEN
                      ASSIGN aux_vlpresta = crapprp.vlctrbnd / crapprp.qtparbnd.
         END.
    ELSE
    IF   par_tpctrato = 3   THEN
         DO:
             IF   AVAIL crawlim   THEN
                  ASSIGN aux_vlpresta = crawlim.vllimite
                         aux_nrctrliq = 0.
             ELSE
             IF   AVAIL craplim   THEN
                  ASSIGN aux_vlpresta = craplim.vllimite
                         aux_nrctrliq = 0.
         END.
    ELSE
    IF  par_tpctrato <> 0  THEN
        DO:
            ASSIGN aux_vlpresta = craplim.vllimite
                   aux_nrctrliq = 0.   
        END.
    ELSE
        DO:
            ASSIGN aux_vlpresta = 0
                   aux_nrctrliq = 0.   
        END.

    RUN nivel_comprometimento (INPUT  par_cdcooper,
                               INPUT  par_cdoperad,
                               INPUT  par_idorigem,
                               INPUT  par_nrdconta,
                               INPUT  par_tpctrato,
                               INPUT  par_nrctrato,
                               INPUT  aux_nrctrliq,
                               INPUT  aux_vlpresta,
                               INPUT  par_idseqttl,
                               INPUT  par_dtmvtolt,
                               INPUT  par_inproces,
                               OUTPUT aux_vltotpre).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    ASSIGN rat_vlpreatv = aux_vltotpre
           rat_vlparope = aux_vlpresta
           rat_vlsalari = crapttl.vlsalari
           rat_vlrendim = crapttl.vldrendi[1] + crapttl.vldrendi[2] + crapttl.vldrendi[3] 
                        + crapttl.vldrendi[4] + crapttl.vldrendi[5] + crapttl.vldrendi[6].

    /* Pegar salario do Conjuge */
    FIND crapcje WHERE crapcje.cdcooper = par_cdcooper   AND
                       crapcje.nrdconta = par_nrdconta   AND
                       crapcje.idseqttl = 1 
                       NO-LOCK NO-ERROR.

    IF   AVAIL crapcje   THEN	      	
    
 	    ASSIGN aux_vlsalari = crapcje.vlsalari
               rat_vlsalcje = crapcje.vlsalari.
	  
	IF aux_vlsalari = ? THEN 
	   ASSIGN aux_vlsalari = 0.
	
	IF rat_vlsalcje = ? THEN
	   ASSIGN rat_vlsalcje = 0.

    IF  (crapttl.vlsalari + 
         crapttl.vldrendi[1] + crapttl.vldrendi[2] + 
         crapttl.vldrendi[3] + crapttl.vldrendi[4] + 
         crapttl.vldrendi[5] + crapttl.vldrendi[6] + 
         aux_vlsalari) > 0 THEN
          DO:
    /* Dividir pelo ( salario + rendimentos + Salario conjuge ) */
    ASSIGN aux_vltotpre = aux_vltotpre / 
                          (crapttl.vlsalari + 
                           crapttl.vldrendi[1] + crapttl.vldrendi[2] + 
                           crapttl.vldrendi[3] + crapttl.vldrendi[4] + 
                           crapttl.vldrendi[5] + crapttl.vldrendi[6] + 
                           aux_vlsalari)
           
           aux_nrseqite = IF   aux_vltotpre <=  0.20   THEN /* Ate 20% */
                               1
                          ELSE
                          IF   aux_vltotpre <= 0.30   THEN /* Ate 30 % */
                               2
                          ELSE 
                               3.  /* Mais do que 30 % */ 
            ASSIGN aux_dsvalite = STRING(round((aux_vltotpre * 100),2)) + "% de comprometimento".
          END.
    ELSE
      DO:
          ASSIGN aux_dsvalite = " ".
          ASSIGN aux_nrseqite = 3.  /* Mais do que 30 % */ 
      END.

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  1,
                           INPUT  7,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  aux_dsvalite).  
    
    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /********************************************************************
     Item 3_2 - Patrimonio pessoal livre em relacao ao endividamento.
     Passou para 1_8
    ********************************************************************/
    /* Se ja existe , entao pegar do cadastro */
    IF   CAN-FIND (crapnrc WHERE
                   crapnrc.cdcooper = par_cdcooper   AND
                   crapnrc.nrdconta = par_nrdconta   AND
                   crapnrc.tpctrrat = par_tpctrato   AND
                   crapnrc.nrctrrat = par_nrctrato)  THEN
         DO:
             aux_nrseqite = crapttl.nrpatlvr.   
         END.
    ELSE     /* Senao da proposta */
         DO:
             IF   par_tpctrato = 90   THEN
                  DO:
                      ASSIGN aux_nrseqite = crapprp.nrpatlvr.
                  END.
             ELSE
             IF   par_tpctrato = 3   THEN
                  DO:
                      IF   AVAIL crawlim   THEN
                           aux_nrseqite = crawlim.nrpatlvr.
                      ELSE
                      IF   AVAIL craplim   THEN
                           aux_nrseqite = craplim.nrpatlvr.
                  END.
             ELSE
             IF  par_tpctrato <> 0  THEN
             DO:
                 ASSIGN aux_nrseqite = craplim.nrpatlvr.
             END.        
             ELSE
                 ASSIGN aux_nrseqite = 1.
         END.
     
    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  1,
                           INPUT  8,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  " ").

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".
    
    /********************************************************************
     Item 3_3 - Endividamento total em relacao a renda bruta.
     Passou para 1_9
    ********************************************************************/
    IF   par_tpctrato = 90   THEN
         DO:
             IF  AVAIL crawepr THEN
                 RUN traz_liquidacoes ( INPUT crawepr.nrctrliq,
                                       OUTPUT par_dsliquid).
         END.
    ELSE
         DO:
             par_dsliquid = "".
         END.

    RUN calcula_endividamento (INPUT  par_cdcooper,
                               INPUT  par_cdagenci,
                               INPUT  par_nrdcaixa,
                               INPUT  par_cdoperad,
                               INPUT  par_idorigem,
                               INPUT  par_nrdconta,
                               INPUT  par_dsliquid,
                               INPUT  par_idseqttl,
                               INPUT  par_dtmvtolt,
                               INPUT  par_dtmvtopr, 
                               INPUT  par_inproces,
                               OUTPUT aux_vlutiliz).  

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /* No caso de proposta, somar valor de operacao corrente                
       
       Quando emprestimo ou Cheque especial.   
             
       Desconto de cheque e titulo nao sao considerados              
       
       no saldo_utiliza do cooperado (Valor limite) */

    IF   par_tpctrato = 90  THEN /* Emprestimo / Financiamento */
         DO:
             IF AVAIL crawepr THEN
               ASSIGN rat_vlopeatu = crawepr.vlemprst.
             ELSE
               ASSIGN rat_vlopeatu = crapprp.vlctrbnd.

             IF   NOT CAN-FIND(crapepr WHERE 
                               crapepr.cdcooper = par_cdcooper   AND
                               crapepr.nrdconta = par_nrdconta   AND
                               crapepr.nrctremp = par_nrctrato   NO-LOCK)  THEN

                 IF  AVAIL crawepr THEN
                     ASSIGN aux_vlendivi = crawepr.vlemprst.
                 ELSE
                     ASSIGN aux_vlendivi = crapprp.vlctrbnd.

             IF   crapprp.vltotsfn <> 0   THEN
                  aux_vlendivi = aux_vlendivi + crapprp.vltotsfn.
             ELSE
                  aux_vlendivi = aux_vlendivi + aux_vlutiliz. 

         END.
    ELSE                        /* Desconto / Cheque especial */
    IF  par_tpctrato <> 0  THEN
         DO:
             IF   par_tpctrato = 1    THEN /* Ch. Especial */
                  DO:
                      ASSIGN rat_vlopeatu = craplim.vllimite.
                      
                      IF   craplim.insitlim <> 2  THEN /* Diferente de ativo */
                           ASSIGN aux_vlendivi = craplim.vllimite.
                  END.   

			 IF   AVAIL craplim   THEN
             DO:			 

				 IF   craplim.vltotsfn <> 0  THEN
					  aux_vlendivi = aux_vlendivi + craplim.vltotsfn.
				 ELSE 
					  aux_vlendivi = aux_vlendivi + aux_vlutiliz.  
				 END.
			 
			 IF   AVAIL crawlim   THEN
             DO:			 

				 IF   crawlim.vltotsfn <> 0  THEN
					  aux_vlendivi = aux_vlendivi + crawlim.vltotsfn.
				 ELSE 
					  aux_vlendivi = aux_vlendivi + aux_vlutiliz.  
			 END.

         END.
    ELSE
    DO:
        ASSIGN aux_vlendivi = 0.
    END.

    ASSIGN rat_vlendivi = aux_vlendivi
           rat_vlsldeve = aux_vlendivi.

    IF  (crapttl.vlsalari + 
         crapttl.vldrendi[1] + crapttl.vldrendi[2] + 
         crapttl.vldrendi[3] + crapttl.vldrendi[4] + 
         crapttl.vldrendi[5] + crapttl.vldrendi[6] + 
         aux_vlsalari) > 0 THEN
          DO:
    /* Dividir pelo salario mais os rendimentos */
    ASSIGN aux_vlendivi = (aux_vlendivi / 
                           (crapttl.vlsalari    + crapttl.vldrendi[1] +
                            crapttl.vldrendi[2] + crapttl.vldrendi[3] + 
                            crapttl.vldrendi[4] + crapttl.vldrendi[5] + 
                            crapttl.vldrendi[6] + aux_vlsalari))
    
           aux_nrseqite = IF   aux_vlendivi <= 7   THEN
                               1
                          ELSE
                          IF   aux_vlendivi <= 14   THEN
                               2
                          ELSE
                               3.
            ASSIGN aux_dsvalite = STRING(round(aux_vlendivi,2)) + " vezes a renda bruta".
          END.
    ELSE
      DO:
          ASSIGN aux_dsvalite = " ".
          ASSIGN aux_nrseqite = 3.
      END.

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  1,
                           INPUT  9,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  aux_dsvalite).
 
    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".
    
    /********************************************************************
     Item 3_4 - Total de endividamento na cooperativa.
     Passou 1_10
    ********************************************************************/ 

    FIND crapcot WHERE crapcot.cdcooper = par_cdcooper   AND
                       crapcot.nrdconta = par_nrdconta  
                       NO-LOCK NO-ERROR.

    /* Se esta efetivando, ele ja considera esta operacao. 

       No caso de proposta, somar valor de operacao                 
       Quando emprestimo ou Cheque especial.   
     
       Desconto de cheque e titulo nao sao considerados              
       no saldo_utiliza do cooperado (Valor limite) */

    ASSIGN aux_vlendivi = aux_vlutiliz.

    IF   par_tpctrato = 90   THEN 
         DO:
             IF   NOT CAN-FIND(crapepr WHERE 
                               crapepr.cdcooper = par_cdcooper  AND
                               crapepr.nrdconta = par_nrdconta  AND
                               crapepr.nrctremp = par_nrctrato  NO-LOCK)   THEN

                  IF  AVAIL crawepr THEN
                      ASSIGN aux_vlendivi = aux_vlendivi + crawepr.vlemprst.
                  ELSE
                      ASSIGN aux_vlendivi = aux_vlendivi + crapprp.vlctrbnd.
         END.
    ELSE
    IF   par_tpctrato = 1    THEN
         DO:
             IF   craplim.insitlim <> 2   THEN
                  ASSIGN aux_vlendivi = aux_vlendivi + craplim.vllimite.       
         END.
    ELSE
    IF  par_tpctrato = 0  THEN
        ASSIGN aux_vlendivi = 0.

    ASSIGN rat_vlslcota = crapcot.vldcotas.
  
    IF crapcot.vldcotas > 0 OR 
	    (aux_vlendivi = 0 AND crapcot.vldcotas = 0) THEN
       DO:
    /* aux_vlutiliz vem do saldo utiliza. Dividir pelas cotas */
    ASSIGN aux_vlendiv2 = (aux_vlendivi / crapcot.vldcotas)
        
           /* Se sem endividamento e sem cotas considera como 1 */ 
           aux_nrseqite = IF  (aux_vlendivi = 0 AND crapcot.vldcotas = 0) OR
                              (aux_vlendiv2 <= 4)  THEN
                               1
                          ELSE
                          IF   aux_vlendiv2 <= 8   THEN
                               2
                          ELSE
                          IF   aux_vlendiv2 <= 12   THEN
                               3
                          ELSE 
                               4.
    
         ASSIGN aux_dsvalite = STRING(round(aux_vlendiv2,2)) + " vezes o valor de cotas".
       END.
    ELSE
      DO:
        ASSIGN aux_dsvalite = " ".
        ASSIGN aux_nrseqite = 4.
      END.
    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  1,
                           INPUT  10,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  aux_dsvalite).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /* calculo do risco cooperado nao calcula o topico 2 */
    IF  par_tpctrato = 0  AND
        par_nrctrato = 0  THEN
        RETURN "OK".

    /**********************************************************************
     Item 2_1 - Finalidade da operacao
    **********************************************************************/

    IF   par_tpctrato = 90   THEN  /* Emprestimo / Financiamento */ 
         DO:
             IF  AVAIL crawepr THEN
               DO:
			   
			     ASSIGN aux_idqualif = DYNAMIC-FUNCTION("verificaQualificacao",
                                            INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT par_nrctrato,
                                            INPUT crawepr.idquapro).
			   
			   
                 ASSIGN rat_cdquaope = crawepr.idquapro
                        rat_cdlincre = crawepr.cdlcremp
                        rat_cdmodali = craplcr.cdmodali
                        rat_cdsubmod = craplcr.cdsubmod
                        rat_dstpoper = craplcr.dsoperac.
                 
                 RUN natureza_operacao (INPUT par_tpctrato,
                                        INPUT  aux_idqualif,
                                        INPUT craplcr.dsoperac,
                                        INPUT  par_cdcooper,
                                        INPUT  par_nrctrato,
                                        INPUT  par_nrdconta,
                                        OUTPUT aux_nrseqite).
               END.
             ELSE /* BNDES */
               DO:
                 ASSIGN rat_cdquaope = 1
                        rat_cdlincre = 0
                        rat_cdmodali = ""
                        rat_cdsubmod = ""
                        rat_dstpoper = "FINANCIAMENTO".

                 RUN natureza_operacao (INPUT par_tpctrato,
                                        INPUT 1, /* Normal */
                                        INPUT "FINANCIAMENTO",
                                        INPUT  par_cdcooper,
                                        INPUT  par_nrctrato,
                                        INPUT  par_nrdconta,
                                        OUTPUT aux_nrseqite).
               END.
         END.                       
    ELSE                        /* Cheque especial / Descontos */
         DO:
           ASSIGN rat_cdquaope = 0
                  rat_cdlincre = 0
                  rat_cdmodali = ""
                  rat_cdsubmod = ""
                  rat_dstpoper = IF par_tpctrato = 1 THEN "Limite de Credito" 
                                                     ELSE "Limite de Desconto".

             RUN natureza_operacao (INPUT par_tpctrato,
                                    INPUT 0,
                                    INPUT "",
                                    INPUT  par_cdcooper,
                                    INPUT  par_nrctrato,
                                    INPUT  par_nrdconta,
                                    OUTPUT aux_nrseqite).
         END.

    ASSIGN rat_cdtpoper = par_tpctrato.

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  2,
                           INPUT  1,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  " ").
    
    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /********************************************************************
     Item 2_2 - Garantia da operacao.
    ********************************************************************/

    IF   par_tpctrato = 90   THEN /* Emprestimo / Financiamento */
         DO:
             ASSIGN aux_nrseqite = crapprp.nrgarope
                    rat_flgcjeco = IF crapprp.flgdocje = YES THEN 1 ELSE 0.   
         END.
    ELSE
    IF   par_tpctrato = 3   THEN
         DO:
             IF   AVAIL crawlim   THEN
                  aux_nrseqite = crawlim.nrgarope.
             ELSE
             IF   AVAIL craplim   THEN
                  aux_nrseqite = craplim.nrgarope.
         END.
    ELSE                         /* Cheque especial / Desconto */   
         DO:
             aux_nrseqite = craplim.nrgarope.
         END.

    ASSIGN rat_cdgarope = aux_nrseqite.

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  2,
                           INPUT  2,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  " ").  

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /********************************************************************
     Item 2_3 - Liquidez das garantias.
    ********************************************************************/

    IF   par_tpctrato = 90    THEN  /* Emprestimo / Financiamento */
         DO:
             ASSIGN aux_nrseqite = crapprp.nrliquid.
         END.
    ELSE
    IF   par_tpctrato = 3   THEN
         DO:
             IF   AVAIL crawlim   THEN
                  aux_nrseqite = crawlim.nrliquid.
             ELSE
             IF   AVAIL craplim   THEN
                  aux_nrseqite = craplim.nrliquid.
         END.
    ELSE                           /* Cheque especial / Desconto */   
         DO:
             ASSIGN aux_nrseqite = craplim.nrliquid.
         END.

    ASSIGN rat_cdliqgar = aux_nrseqite.

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  2,
                           INPUT  3,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  " ").   

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /********************************************************************
     Item 2_4 - Prazo da operacao.
    ********************************************************************/
                                  
    IF   par_tpctrato = 90   THEN  /* Emprestimo / Financiamento */
         DO:
             IF  AVAIL crawepr THEN
                 ASSIGN aux_qtdiapra = crawepr.qtpreemp * 30 /* Sempre vezes 30 */
                        rat_qtpreope = crawepr.qtpreemp.
             ELSE /* BNDES */
                 ASSIGN aux_qtdiapra = crapprp.qtparbnd * 30 /* Sempre vezes 30 */
                        rat_qtpreope = crapprp.qtparbnd.
         END.
    ELSE
    IF   par_tpctrato = 3   THEN
         DO:
             IF   AVAIL crawlim   THEN
                  ASSIGN aux_qtdiapra = crawlim.qtdiavig
                         rat_qtpreope = crawlim.qtdiavig / 30.
             ELSE
             IF   AVAIL craplim   THEN
                  ASSIGN aux_qtdiapra = craplim.qtdiavig
                         rat_qtpreope = craplim.qtdiavig / 30.
         END.
    ELSE                          /* Cheque especial / Desconto */  
         DO:
             ASSIGN aux_qtdiapra = craplim.qtdiavig
                    rat_qtpreope = craplim.qtdiavig / 30.
         END.

    ASSIGN aux_nrseqite = IF   aux_qtdiapra <= 720   THEN
                               1
                          ELSE
                          IF   aux_qtdiapra <= 1440  THEN
                               2
                          ELSE
                               3.

    ASSIGN aux_dsvalite = STRING(aux_qtdiapra) + " dias de prazo da operacao".
    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  2,
                           INPUT  4,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  aux_dsvalite).  

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".
    
    RETURN "OK".     

END PROCEDURE.


/******************************************************************************
Procedure para calcular o rating de pessoas juridicas.
Tratamento divido em itens.
******************************************************************************/

PROCEDURE calcula_rating_juridica:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_flgcriar AS LOGI                            NO-UNDO.   

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM aux_vlutiliz AS DECI                            NO-UNDO.
    
    /* Variaveis para o calculo do Rating */
    DEF  VAR         aux_nranoope AS DECI                            NO-UNDO. 
    DEF  VAR         aux_qtdiapra AS INTE                            NO-UNDO.
    DEF  VAR         aux_vlendivi AS DECI                            NO-UNDO.
    DEF  VAR         aux_vlmedfat AS DECI                            NO-UNDO.
    DEF  VAR         aux_vlpresta AS DECI                            NO-UNDO.
    DEF  VAR         aux_vltotpre AS DECI                            NO-UNDO.
    DEF  VAR         aux_qtdiaatr AS INTE                            NO-UNDO.
    DEF  VAR         aux_dtadmsoc AS DATE                            NO-UNDO.
    DEF  VAR         aux_qtanosoc AS DECI                            NO-UNDO.
    DEF  VAR         aux_nrctrliq AS INTE EXTENT 10                  NO-UNDO.
    DEF  VAR         aux_contador AS INTE                            NO-UNDO.
    DEF  VAR         aux_dtmvtolt AS DATE                            NO-UNDO.

    DEF  VAR         par_dsliquid AS CHAR                            NO-UNDO.                         
    DEF  VAR         aux_idqualif AS INTE                            NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    /* Todas as criticas do calculo (juridica) esta aqui */
    RUN criticas_rating_jur (INPUT par_cdcooper,
                             INPUT par_nrdconta,
                             INPUT par_tpctrato,
                             INPUT par_nrctrato,
                             INPUT par_idorigem,
                             INPUT par_dtmvtolt,
                             INPUT 0,
                             INPUT 0,
                             OUTPUT TABLE tt-erro).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /* Registro da empresa */
    FIND crapjur WHERE crapjur.cdcooper = par_cdcooper   AND
                       crapjur.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

    FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper   AND
                       crapjfn.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

    /* Nao utilizado no calculo risco Cooperado */
    IF  par_tpctrato <> 0  AND
        par_nrctrato <> 0  THEN
    DO:
        IF   par_tpctrato = 90   THEN  /* Emprestimo / Financiamento */
             DO: 
                 FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                                    crawepr.nrdconta = par_nrdconta   AND
                                    crawepr.nrctremp = par_nrctrato   
                                    NO-LOCK NO-ERROR.

                 FIND crapprp WHERE crapprp.cdcooper = par_cdcooper   AND
                                    crapprp.nrdconta = par_nrdconta   AND
                                    crapprp.tpctrato = par_tpctrato   AND
                                    crapprp.nrctrato = par_nrctrato
                                    NO-LOCK NO-ERROR.

                 IF  AVAIL crawepr THEN
                     FIND craplcr WHERE craplcr.cdcooper = par_cdcooper   AND
                                        craplcr.cdlcremp = crawepr.cdlcrem
                                NO-LOCK NO-ERROR.
             END.
        ELSE
             DO:
                 IF   par_tpctrato = 3   THEN
                      DO:
                          /* Descontos / Limite rotativo */   
                          FIND crawlim WHERE crawlim.cdcooper = par_cdcooper   AND
                                             crawlim.nrdconta = par_nrdconta   AND
                                             crawlim.tpctrlim = par_tpctrato   AND
                                             crawlim.nrctrlim = par_nrctrato
                                    NO-LOCK NO-ERROR.                                               
                          IF NOT AVAIL(crawlim) THEN
                             DO:
                                 /* Descontos / Limite rotativo */   
                                 FIND craplim WHERE craplim.cdcooper = par_cdcooper   AND
                                                    craplim.nrdconta = par_nrdconta   AND
                                                    craplim.tpctrlim = par_tpctrato   AND
                                                    craplim.nrctrlim = par_nrctrato
                                                    NO-LOCK NO-ERROR.
                             END.
         
                      END.
                 ELSE
                 DO:
                      /* Descontos / Limite rotativo */   
                      FIND craplim WHERE craplim.cdcooper = par_cdcooper   AND
                                         craplim.nrdconta = par_nrdconta   AND
                                         craplim.tpctrlim = par_tpctrato   AND
                                         craplim.nrctrlim = par_nrctrato
                                         NO-LOCK NO-ERROR.
                 END.
             END.
    END.

    /********************************************************************
     Item 6_1 - Tempo de operacao no mercado
     Passou 3_1
    ********************************************************************/

    ASSIGN aux_nranoope = INTERVAL(par_dtmvtolt,crapjur.dtiniatv,"DAYS") / 365
        
           aux_nrseqite = IF   aux_nranoope > 8    THEN
                               1
                          ELSE
                          IF   aux_nranoope >= 5   THEN
                               2
                          ELSE
                          IF   aux_nranoope >= 2   THEN
                               3
                          ELSE
                               4.

    ASSIGN aux_dsvalite = STRING(round(aux_nranoope,2)) + " anos de operacao"
           rat_dtfunemp = crapjur.dtiniatv.

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  3,
                           INPUT  1,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  aux_dsvalite).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /******************************************************************** 
     Item 6_4 - Historico do cooperado 
     Passou 3_2
    ********************************************************************/
         
    RUN historico_cooperado (INPUT  par_cdcooper,
                             INPUT  par_cdagenci,
                             INPUT  par_nrdcaixa,
                             INPUT  par_cdoperad,
                             INPUT  par_dtmvtolt,
                             INPUT  par_nrdconta,
                             INPUT  par_idorigem,
                             INPUT  par_idseqttl,
                             OUTPUT aux_nrseqite).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  3,
                           INPUT  2,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  aux_dsvalite).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".
    
    /******************************************************************** 
    Item 6_2 - Informacoes Cadastrais 
    Passou 3_3
    ********************************************************************/
    
     /* Se ja existe , entao pegar do cadastro */
    IF   CAN-FIND (crapnrc WHERE
                   crapnrc.cdcooper = par_cdcooper   AND
                   crapnrc.nrdconta = par_nrdconta   AND
                   crapnrc.tpctrrat = par_tpctrato   AND
                   crapnrc.nrctrrat = par_nrctrato)  THEN
         DO:
             aux_nrseqite = crapjur.nrinfcad.   
         END.
    ELSE     /* Senao pega do cadastro */
         DO:
             IF   par_tpctrato = 90   THEN
                  DO:
                      IF  AVAIL crapprp  THEN
                      ASSIGN aux_nrseqite = crapprp.nrinfcad.
                  END.
             ELSE
                  DO:
                      IF   par_tpctrato = 3   THEN
                           DO:
                               IF  AVAIL crawlim  THEN
                                   ASSIGN aux_nrseqite = crawlim.nrinfcad.
              
                               IF  AVAIL craplim  THEN
                                   ASSIGN aux_nrseqite = craplim.nrinfcad.
                           END.
                      ELSE
                           IF  AVAIL craplim  THEN
                               ASSIGN aux_nrseqite = craplim.nrinfcad.
                  END.                 
         END.

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  3,
                           INPUT  3,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  " ").

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /********************************************************************
     Item 6_5 - Pontualidade 
     Passou 3_4
    ********************************************************************/

    /* Do ultimo ano */
    ASSIGN aux_dtmvtolt = ADD-INTERVAL(par_dtmvtolt, - 1 , "YEARS").

    FOR EACH crapris WHERE crapris.cdcooper  = par_cdcooper   AND
                           crapris.nrdconta  = par_nrdconta   AND
                           crapris.dtrefere >= aux_dtmvtolt   AND 
                           crapris.dtrefere <= par_dtmvtolt - DAY (par_dtmvtolt) AND 
                           crapris.inddocto  = 1              AND
                           (crapris.cdmodali  = 299 OR crapris.cdmodali = 499) NO-LOCK:
                                                              
        IF   crapris.qtdiaatr > aux_qtdiaatr THEN
             ASSIGN aux_qtdiaatr = crapris.qtdiaatr.

    END.

    ASSIGN aux_nrseqite = IF   aux_qtdiaatr = 0     THEN
                               1
                          ELSE 
                          IF   aux_qtdiaatr <= 16   THEN
                               2
                          ELSE
                          IF   aux_qtdiaatr <= 30   THEN
                               3
                          ELSE
                          IF   aux_qtdiaatr <= 60   THEN
                               4
                          ELSE 
                               5.

    ASSIGN aux_dsvalite = STRING(aux_qtdiaatr) + " dias de atraso"
           rat_qtmaxatr = aux_qtdiaatr.
    
    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  3,
                           INPUT  4,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  aux_dsvalite).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /********************************************************************
     Item 5_3 - Capacidade de geracao de resultados - SET.ECONOMICO
     Passou 3_5
    ********************************************************************/

    CASE crapjur.cdseteco:

       WHEN   0   THEN   ASSIGN   aux_nrseqite = 4. /* Agronegocio*/
       WHEN   1   THEN   ASSIGN   aux_nrseqite = 4. /* Agronegocio*/
       WHEN   2   THEN   ASSIGN   aux_nrseqite = 2. /* Comercio */
       WHEN   3   THEN   ASSIGN   aux_nrseqite = 3. /* Industria */
       WHEN   4   THEN   ASSIGN   aux_nrseqite = 1. /* Servicos */
    
    END CASE.

    ASSIGN rat_cdseteco = crapjur.cdseteco.

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  3,
                           INPUT  5,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  " ").

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /******************************************************************** 
     Item 4_1 - TEMPO DOS SÓCIOS NA EMPRESA
     Passou 3_6
    ********************************************************************/

    /* Pegar o socio mais antigo */
    FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper         AND
                           crapavt.nrdconta = par_nrdconta         AND
                           crapavt.tpctrato = 6 /*Juridica*/       AND
                           CAN-DO("SOCIO/PROPRIETARIO,SOCIO ADMINISTRADOR,DIRETOR/ADMINISTRADOR,SINDICO,ADMINISTRADOR",STRING(crapavt.dsproftl)) NO-LOCK
                           BREAK BY crapavt.dtadmsoc DESC:

        IF   crapavt.dtadmsoc = ?  THEN
             NEXT.

        ASSIGN aux_dtadmsoc = crapavt.dtadmsoc
               rat_dtprisoc = crapavt.dtadmsoc.

    END.

    /* Naturalidades juridicas */
      IF   CAN-DO ("2062,2135,4081,2089",STRING(crapjur.natjurid))   THEN
         DO:
             aux_qtanosoc = INTERVAL (par_dtmvtolt,aux_dtadmsoc,"DAYS") / 365.

             aux_nrseqite = IF   aux_qtanosoc  > 8   THEN
                                 1
                            ELSE
                            IF   aux_qtanosoc >= 5   THEN
                                 2
                            ELSE
                            IF   aux_qtanosoc >= 2   THEN
                                 3
                            ELSE
                                 4.
         END.
    ELSE
         DO:
             aux_qtanosoc = INTERVAL (par_dtmvtolt, crapjur.dtiniatv,"DAYS") / 365.

             ASSIGN aux_nrseqite = IF   aux_qtanosoc > 8 THEN
                                        1
                                   ELSE
                                   IF   aux_qtanosoc >= 5 THEN
                                        2
                                   ELSE
                                   IF   aux_qtanosoc >= 2 THEN
                                        3
                                   ELSE
                                        4.
         
                                        
         END.

    ASSIGN aux_dsvalite = STRING(round(aux_qtanosoc,2)) + " anos dos socios na empresa".
    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  3,
                           INPUT  6,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  aux_dsvalite).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /********************************************************************
     Item_6_6 - Concentracao unico cliente.
     Passou 3_7
    ********************************************************************/

    ASSIGN aux_nrseqite = IF   crapjfn.perfatcl >  80   THEN
                               4
                          ELSE 
                          IF   crapjfn.perfatcl >= 50   THEN
                               3
                          ELSE
                          IF   crapjfn.perfatcl >= 30   THEN
                               2
                          ELSE 
                               1.

    ASSIGN aux_dsvalite = STRING(crapjfn.perfatcl) + "% faturamento unico cliente"
           rat_prfatcli = crapjfn.perfatcl.
    
    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  3,
                           INPUT  7,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  aux_dsvalite).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /******************************************************************** 
     Item 5_1 - Endividamento total SCR versus faturamento medio.
     Passou 3_8
    ********************************************************************/
    
    IF   par_tpctrato = 90   THEN
         DO:
             IF  AVAIL crawepr THEN
                 RUN traz_liquidacoes ( INPUT crawepr.nrctrliq,
                                       OUTPUT par_dsliquid).
         END.
    ELSE
         DO:
             par_dsliquid = "".
         END.

    RUN calcula_endividamento (INPUT  par_cdcooper,
                               INPUT  par_cdagenci,
                               INPUT  par_nrdcaixa,
                               INPUT  par_cdoperad,
                               INPUT  par_idorigem,
                               INPUT  par_nrdconta,
                               INPUT  par_dsliquid,
                               INPUT  par_idseqttl,
                               INPUT  par_dtmvtolt,
                               INPUT  par_dtmvtopr, 
                               INPUT  par_inproces,
                               OUTPUT aux_vlutiliz).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

     /* No caso de proposta, somar valor de operacao                 
        Quando emprestimo ou Cheque especial.   
             
        Desconto de cheque e titulo nao sao considerados              
        no saldo_utiliza do cooperado (Valor limite) */      

    IF   par_tpctrato = 90  THEN /* Emprestimo / Financiamento */
         DO:
             IF AVAIL crawepr THEN
               ASSIGN rat_vlopeatu = crawepr.vlemprst.
             ELSE /*BNDES*/
               ASSIGN rat_vlopeatu = crapprp.vlctrbnd.
                            
             IF   NOT CAN-FIND(crapepr WHERE
                               crapepr.cdcooper = par_cdcooper   AND
                               crapepr.nrdconta = par_nrdconta   AND
                               crapepr.nrctremp = par_nrctrato   NO-LOCK)   THEN
                 IF  AVAIL crawepr THEN
                     ASSIGN aux_vlendivi = crawepr.vlemprst.
                 ELSE /*BNDES*/
                     ASSIGN aux_vlendivi = crapprp.vlctrbnd.

             IF   crapprp.vltotsfn <> 0   THEN
                  ASSIGN aux_vlendivi = aux_vlendivi + crapprp.vltotsfn.
             ELSE 
                  ASSIGN aux_vlendivi = aux_vlendivi + aux_vlutiliz.

         END.
    ELSE                        /* Desconto / Cheque especial */
    IF  par_tpctrato <> 0 THEN
         DO:
             IF   par_tpctrato = 1    THEN /* Cheque especial */
                  DO:
                      ASSIGN rat_vlopeatu = craplim.vllimite.

                      IF   craplim.insitlim <> 2   THEN
                           aux_vlendivi = craplim.vllimite.                      
                  END.

		     IF   par_tpctrato = 3   THEN
				  DO:
					  IF  AVAIL crawlim  THEN
					  DO:
						  IF   crawlim.vltotsfn <> 0   THEN
							  aux_vlendivi = aux_vlendivi + crawlim.vltotsfn.
                          ELSE
                              aux_vlendivi = aux_vlendivi + aux_vlutiliz.
					  END.
					  ELSE
					  DO:
						  IF   craplim.vltotsfn <> 0   THEN
							  aux_vlendivi = aux_vlendivi + craplim.vltotsfn.
						  ELSE
							  aux_vlendivi = aux_vlendivi + aux_vlutiliz.
					  END.
						  
				  END.
			 ELSE		
             DO:
				 IF   craplim.vltotsfn <> 0   THEN
					  aux_vlendivi = aux_vlendivi + craplim.vltotsfn.
				 ELSE
					  aux_vlendivi = aux_vlendivi + aux_vlutiliz.
			 END. 
                 
         END.   
    ELSE
        ASSIGN aux_vlendivi = 0.
    
    ASSIGN rat_vlendivi = aux_vlendivi
           rat_vlsldeve = aux_vlendivi.
    
    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    RUN calcula-faturamento IN h-b1wgen9999 (INPUT  par_cdcooper,
                                             INPUT  par_cdagenci,
                                             INPUT  par_nrdcaixa,
                                             INPUT  par_idorigem,
                                             INPUT  par_nrdconta,
                                             INPUT  par_dtmvtolt,
                                             OUTPUT aux_vlmedfat).
    DELETE PROCEDURE h-b1wgen9999.

    IF aux_vlmedfat > 0 THEN
       DO:
    ASSIGN aux_vlendivi = (aux_vlendivi / aux_vlmedfat)

           aux_nrseqite = IF   aux_vlendivi <= 3   THEN
                               1
                          ELSE
                          IF   aux_vlendivi <= 8   THEN
                               2
                          ELSE
                          IF   aux_vlendivi <= 20  THEN
                               3
                          ELSE
                               4. 
         ASSIGN aux_dsvalite = STRING(round(aux_vlendivi,2)) + " vezes o faturamento".
       END.
    ELSE
      DO:
        ASSIGN aux_dsvalite = " ".
        ASSIGN aux_nrseqite = 4.
      END.
    
    ASSIGN rat_vlmedfat = aux_vlmedfat.
    
    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  3,
                           INPUT  8,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  aux_dsvalite).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /******************************************************************** 
     Item 5_4 - Pat. pessoal dos garant. / socios liv. de onus 
     Passou 3_9
    ********************************************************************/ 

    /* Se ja existe , entao pegar do cadastro */
    IF   CAN-FIND (crapnrc WHERE
                   crapnrc.cdcooper = par_cdcooper   AND
                   crapnrc.nrdconta = par_nrdconta   AND
                   crapnrc.tpctrrat = par_tpctrato   AND
                   crapnrc.nrctrrat = par_nrctrato)  THEN
         DO:
             aux_nrseqite = crapjur.nrpatlvr.   
         END.
    ELSE
         DO:
             IF   par_tpctrato = 90   THEN
                  DO:
                      IF  AVAIL crapprp  THEN
                      aux_nrseqite = crapprp.nrpatlvr.
                  END.
             ELSE
                  DO:
                      IF   par_tpctrato = 3   THEN
                           DO:
                               IF  AVAIL crawlim  THEN
                                   aux_nrseqite = crawlim.nrpatlvr.
                
                               IF  AVAIL craplim  THEN
                                   aux_nrseqite = craplim.nrpatlvr.
                           END.
                      ELSE
                           IF  AVAIL craplim  THEN
                               aux_nrseqite = craplim.nrpatlvr.
                  END.
         END.

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  3,
                           INPUT  9,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  " ").

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".
    
    /********************************************************************
     Item 5_2 - Grau de endividamento. (Parcelas versus faturamento medio) 
     Passou 3_10
    ********************************************************************/

    IF   par_tpctrato = 90   THEN
         DO:
             IF  AVAIL crawepr THEN DO:
                 ASSIGN aux_vlpresta = crawepr.vlpreemp.
                  
                 /* Contratos que ele esta liquidando */
                 DO aux_contador = 1 TO EXTENT (crawepr.nrctrliq):
    
                     ASSIGN aux_nrctrliq[aux_contador] = 
                                crawepr.nrctrliq[aux_contador].
    
                 END.
             END.
             ELSE /* Operacao BNDES */ 
                 IF   AVAIL crapprp THEN
                      ASSIGN aux_vlpresta = crapprp.vlctrbnd / crapprp.qtparbnd.
         END.
    ELSE
    IF  par_tpctrato <> 0  THEN
         DO:
             IF   par_tpctrato = 3   THEN
                  DO:
                      IF  AVAIL crawlim  THEN
                          ASSIGN aux_vlpresta = crawlim.vllimite
                                 aux_nrctrliq = 0. 
          
                      IF  AVAIL craplim  THEN
                          ASSIGN aux_vlpresta = craplim.vllimite
                                 aux_nrctrliq = 0.
                  END.
             ELSE
                  DO:
                      ASSIGN aux_vlpresta = craplim.vllimite
                             aux_nrctrliq = 0. 
                  END.
         END.
    ELSE
    DO:
        ASSIGN aux_vlpresta = 0
               aux_nrctrliq = 0. 
    END.


    RUN nivel_comprometimento (INPUT  par_cdcooper,
                               INPUT  par_cdoperad,
                               INPUT  par_idorigem,
                               INPUT  par_nrdconta,
                               INPUT  par_tpctrato,
                               INPUT  par_nrctrato,
                               INPUT  aux_nrctrliq,
                               INPUT  aux_vlpresta,
                               INPUT  par_idseqttl,
                               INPUT  par_dtmvtolt,
                               INPUT  par_inproces,
                               OUTPUT aux_vltotpre). 

    ASSIGN rat_vlpreatv = aux_vltotpre
           rat_vlparope = aux_vlpresta.

    IF aux_vlmedfat > 0 THEN
       DO:
    /* Divide pelo faturamento medio */
    ASSIGN aux_vltotpre = (aux_vltotpre / aux_vlmedfat)
            
           aux_nrseqite = IF   aux_vltotpre <= 0.07  THEN
                               1
                          ELSE
                          IF   aux_vltotpre <= 0.1   THEN
                               2
                          ELSE
                               3.

         ASSIGN aux_dsvalite = STRING(round(aux_vltotpre * 100,2)) + "% de endividamento".
       END.
    ELSE
      DO:
        ASSIGN aux_dsvalite = " ".
        ASSIGN aux_nrseqite = 3.
      END.
    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  3,
                           INPUT  10,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  aux_dsvalite).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /********************************************************************
     Item 6_3 - Percepcao geral com relacao a empresa.
     Passou 3_11
    ********************************************************************/
    
    /* Se ja existe , entao pegar do cadastro */
    IF   CAN-FIND (crapnrc WHERE
                   crapnrc.cdcooper = par_cdcooper   AND
                   crapnrc.nrdconta = par_nrdconta   AND
                   crapnrc.tpctrrat = par_tpctrato   AND
                   crapnrc.nrctrrat = par_nrctrato)  THEN
         DO:
             aux_nrseqite = crapjur.nrperger.   
         END.
    ELSE     /* Senao da proposta */
         DO:
             IF   par_tpctrato = 90   THEN
                  DO:
                      IF  AVAIL crapprp  THEN
                      ASSIGN aux_nrseqite = crapprp.nrperger.         
                  END.
             ELSE
                  DO:   
                       IF   par_tpctrato = 3   THEN
                            DO:
                                IF  AVAIL crawlim  THEN
                                    ASSIGN aux_nrseqite = crawlim.nrperger.
          
                                IF  AVAIL craplim  THEN
                                    ASSIGN aux_nrseqite = craplim.nrperger.
                            END.
                       ELSE
                            IF  AVAIL craplim  THEN
                                ASSIGN aux_nrseqite = craplim.nrperger.
                  END.                 
         END.

    ASSIGN rat_cdperemp = aux_nrseqite.

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  3,
                           INPUT  11,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  " ").

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /* Para calculo cooperado somente topico 3 */
    IF  par_tpctrato = 0  AND
        par_nrctrato = 0  THEN
        RETURN "OK".

    /********************************************************************
     Item 4_4 - Limite de credito (dados da proposta) 
     Passou 4_1
    ********************************************************************/

    IF   par_tpctrato = 90  THEN /* Emprestimo / Financiamento */
         DO:
             /* Renegociacao / Composicao de divida*/
             IF  AVAIL crawepr THEN DO:
                 ASSIGN rat_cdquaope = crawepr.idquapro
                        rat_cdlincre = crawepr.cdlcremp
                        rat_cdmodali = craplcr.cdmodali
                        rat_cdsubmod = craplcr.cdsubmod
                        rat_dstpoper = craplcr.dsoperac.

                 ASSIGN aux_idqualif = DYNAMIC-FUNCTION("verificaQualificacao",
                                            INPUT par_cdcooper,
                                            INPUT par_nrdconta,
                                            INPUT par_nrctrato,
                                            INPUT crawepr.idquapro). 

				/* IF   crawepr.idquapro > 2 THEN  */
                /* Alterado para quando o controle alterar 
                   a qualificacao da operacao, pegar o do controle 
                */
                 IF   aux_idqualif > 2 THEN
                      ASSIGN aux_nrseqite = 6.
                 ELSE
                     CASE craplcr.dsoperac:
    
                         WHEN "CAPITAL DE GIRO ATE 30 DIAS"
                              THEN aux_nrseqite = 1.
                         WHEN "FINANCIAMENTO"    
                              THEN aux_nrseqite = 2.
                         WHEN "CAPITAL DE GIRO ACIMA 30 DIAS" 
                              THEN aux_nrseqite = 3.
                         WHEN "EMPRESTIMO" 
                              THEN aux_nrseqite = 4.
                     END CASE.
             END.
             ELSE
                 IF  NOT AVAIL craplcr THEN
                   ASSIGN aux_nrseqite = 2
                          rat_cdquaope = 1
                          rat_cdlincre = 0
                          rat_cdmodali = ""
                          rat_cdsubmod = ""
                          rat_dstpoper = "FINANCIAMENTO".
         END.
    ELSE                         /* Limites / Descontos */
         DO:
             ASSIGN rat_cdquaope = 0
                    rat_cdlincre = 0
                    rat_cdmodali = ""
                    rat_cdsubmod = "".

             IF   par_tpctrato = 3   THEN
                  DO:
                      IF  AVAIL crawlim  THEN
                          DO:
                              IF   crawlim.tpctrlim = 1   THEN /* Limite */
                                   ASSIGN aux_nrseqite = 5
                                          rat_dstpoper = "Limite de Credito".
                              ELSE
                                   ASSIGN aux_nrseqite = 2
                                          rat_dstpoper = "Limite de Desconto".
                       
                          END.
                       
                      IF  AVAIL craplim  THEN
                          DO:
                              IF   craplim.tpctrlim = 1   THEN /* Limite */
                                   ASSIGN aux_nrseqite = 5
                                          rat_dstpoper = "Limite de Credito".
                              ELSE
                                   ASSIGN aux_nrseqite = 2
                                          rat_dstpoper = "Limite de Desconto".
                          END.
                  END.    
             ELSE
                  DO:
                      IF   craplim.tpctrlim = 1   THEN /* Limite */
                           ASSIGN aux_nrseqite = 5
                                  rat_dstpoper = "Limite de Credito".
                      ELSE
                           ASSIGN aux_nrseqite = 2
                                  rat_dstpoper = "Limite de Desconto".
                  END.
         END.

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  4,
                           INPUT  1,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  " ").

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".


    /******************************************************************** 
     Item 4_2 - Garantias (Dados da proposta)
    ********************************************************************/

    IF   par_tpctrato = 90   THEN    /* Emprestimo / Financiamento   */
         DO:                  
             ASSIGN aux_nrseqite = crapprp.nrgarope
                    rat_flgcjeco = IF crapprp.flgdocje = YES THEN 1 ELSE 0.
         END.
    ELSE                            /* Descontos / Limite rotativo */
         DO:
             IF   par_tpctrato = 3   THEN
                  DO:
                      IF  AVAIL crawlim  THEN
                          ASSIGN aux_nrseqite = crawlim.nrgarope.    
     
                      IF  AVAIL craplim  THEN
                          ASSIGN aux_nrseqite = craplim.nrgarope.         
                  END.
             ELSE
                  ASSIGN aux_nrseqite = craplim.nrgarope.         
         END.       

    ASSIGN rat_cdgarope = aux_nrseqite.

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  4,
                           INPUT  2,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  " ").

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /******************************************************************** 
     Item 4_3 - Liquidez das garantias (Dados da proposta) 
    ********************************************************************/

    IF   par_tpctrato = 90   THEN   /* Emprestimo / Financiamento   */
         DO:
             ASSIGN aux_nrseqite = crapprp.nrliquid.         
         END.
    ELSE                           /* Descontos / Limite rotativo */ 
         DO:
             IF   par_tpctrato = 3   THEN
                  DO:
                      IF  AVAIL crawlim  THEN
                          ASSIGN aux_nrseqite = crawlim.nrliquid.
              
                      IF  AVAIL craplim  THEN
                          ASSIGN aux_nrseqite = craplim.nrliquid.
                  END.
             ELSE
                  ASSIGN aux_nrseqite = craplim.nrliquid.
         END.

    ASSIGN rat_cdliqgar = aux_nrseqite.

    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  4,
                           INPUT  3,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  " ").

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    /********************************************************************
     Item 4_5 - Prazo da operacao
     Passou 4_4
    ********************************************************************/

    IF   par_tpctrato = 90   THEN /* Emprestimo / Financiamento */
         DO:
             IF  AVAIL crawepr THEN
               ASSIGN aux_qtdiapra = crawepr.qtpreemp * 30  /* Sempre vezes 30 */
                      rat_qtpreope = crawepr.qtpreemp.
             ELSE /* BNDES */
               ASSIGN aux_qtdiapra = crapprp.qtparbnd * 30  /* Sempre vezes 30 */
                      rat_qtpreope = crapprp.qtparbnd.
         END.
    ELSE 
         DO:
             IF   par_tpctrato = 3   THEN
                  DO:
                      IF  AVAIL crawlim  THEN
                          ASSIGN aux_qtdiapra = crawlim.qtdiavig
                                 rat_qtpreope = crawlim.qtdiavig / 30.
          
                      IF  AVAIL craplim  THEN
                          ASSIGN aux_qtdiapra = craplim.qtdiavig
                                 rat_qtpreope = craplim.qtdiavig / 30.
          
                  END.
             ELSE
                  ASSIGN aux_qtdiapra = craplim.qtdiavig
                         rat_qtpreope = craplim.qtdiavig / 30.
         END.

    ASSIGN aux_nrseqite = IF   aux_qtdiapra <= 360   THEN
                               1
                          ELSE
                          IF   aux_qtdiapra <= 720   THEN
                               2
                          ELSE 
                          IF   aux_qtdiapra <= 1440  THEN
                               3
                          ELSE
                               4.

    ASSIGN aux_dsvalite = STRING(aux_qtdiapra) + " dias de prazo da operacao".
    RUN grava_item_rating (INPUT  par_cdcooper,
                           INPUT  par_nrdconta,
                           INPUT  par_tpctrato,
                           INPUT  par_nrctrato,
                           INPUT  4,
                           INPUT  4,
                           INPUT  aux_nrseqite,
                           INPUT  par_flgcriar,
                           INPUT  aux_dsvalite).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

/******************************************************************************
    Procedure para calcular o rating das cooperativas singulares com c/c na
    CECRED
******************************************************************************/
PROCEDURE calcula_singulares:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_flgcriar AS LOGI                            NO-UNDO.   

    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM aux_vlutiliz AS DECI                            NO-UNDO.

    DEF VAR aux_valoruti AS DECI                                     NO-UNDO.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_valoruti = 0.

    FOR EACH tt-rating-singulares NO-LOCK:
     
        /*DISP tt-rating-singulares.*/

        RUN grava_item_rating (INPUT par_cdcooper,
                               INPUT par_nrdconta,
                               INPUT par_tpctrato,
                               INPUT par_nrctrato,
                               INPUT tt-rating-singulares.nrtopico,
                               INPUT tt-rating-singulares.nritetop,
                               INPUT tt-rating-singulares.nrseqite,
                               INPUT par_flgcriar,
                               INPUT " ").

        IF   RETURN-VALUE <> "OK"   THEN
             RETURN "NOK".

    END.

    RUN calcula_endividamento (INPUT  par_cdcooper,
                               INPUT  par_cdagenci,
                               INPUT  par_nrdcaixa,
                               INPUT  par_cdoperad,
                               INPUT  par_idorigem,
                               INPUT  par_nrdconta,
                               INPUT  "", 
                               INPUT  par_idseqttl,
                               INPUT  par_dtmvtolt,
                               INPUT  par_dtmvtopr,
                               INPUT  par_inproces,
                               OUTPUT aux_valoruti).

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".

    ASSIGN aux_vlutiliz = aux_vlutiliz + aux_valoruti.

    RETURN "OK".

END PROCEDURE.

/***************************************************************************
 Usada no final das propostas de operaçoes. Para trazer as criticas
 (se existir) para a geraçao do Rating.
***************************************************************************/

PROCEDURE lista_criticas:
    
    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_tpctrrat AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctrrat AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_flgerlog AS LOGI                            NO-UNDO.
                                                              
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    
    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    IF  par_flgerlog  THEN
        ASSIGN aux_dsorigem = TRIM(ENTRY(par_idorigem,des_dorigens,","))
               aux_dstransa = "Listar criticas do rating do cooperado".

    DO WHILE TRUE:

        FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND    
                           crapass.nrdconta = par_nrdconta
                           NO-LOCK NO-ERROR.

        IF   NOT AVAIL crapass   THEN
             DO:
                 aux_cdcritic = 9.
                 LEAVE.
             END.
           
        IF   crapass.inpessoa = 1   THEN
             RUN criticas_rating_fis (INPUT par_cdcooper,
                                      INPUT par_nrdconta,
                                      INPUT par_tpctrrat,
                                      INPUT par_nrctrrat,
                                      INPUT par_cdagenci,
                                      INPUT par_nrdcaixa,
                                      OUTPUT TABLE tt-erro).
        ELSE
            RUN criticas_rating_jur (INPUT par_cdcooper,
                                     INPUT par_nrdconta,
                                     INPUT par_tpctrrat,
                                     INPUT par_nrctrrat,
                                     INPUT par_idorigem,
                                     INPUT par_dtmvtolt,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     OUTPUT TABLE tt-erro).

        IF   RETURN-VALUE <> "OK"   THEN
             DO:
                 IF   par_flgerlog  THEN
                      RUN proc_gerar_log (INPUT  par_cdcooper,
                                          INPUT  par_cdoperad,
                                          INPUT  aux_dscritic,
                                          INPUT  aux_dsorigem,
                                          INPUT  aux_dstransa,
                                          INPUT  FALSE,
                                          INPUT  par_idseqttl,
                                          INPUT  par_nmdatela,
                                          INPUT  par_nrdconta,
                                          OUTPUT aux_nrdrowid).          
                 RETURN "NOK".
             END.
                 
        LEAVE.

    END. /* Fim tratamento Criticas */

    IF   aux_cdcritic <> 0    OR
         aux_dscritic <> ""   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   NOT AVAIL tt-erro THEN
                  RUN gera_erro (INPUT par_cdcooper,
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,
                                 INPUT 1,            /** Sequencia **/
                                 INPUT aux_cdcritic,
                                 INPUT-OUTPUT aux_dscritic).

             IF   par_flgerlog  THEN
                  RUN proc_gerar_log (INPUT  par_cdcooper,
                                      INPUT  par_cdoperad,
                                      INPUT  aux_dscritic,
                                      INPUT  aux_dsorigem,
                                      INPUT  aux_dstransa,
                                      INPUT  FALSE,
                                      INPUT  par_idseqttl,
                                      INPUT  par_nmdatela,
                                      INPUT  par_nrdconta,
                                      OUTPUT aux_nrdrowid).
             RETURN "NOK".

         END.
    
    IF   par_flgerlog   THEN                                
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


/***************************************************************************
 Tratamento das criticas para o calculo de pessoa fisica.
 Foi desenvolvido para mostrar todas as criticas do calculo.
***************************************************************************/

PROCEDURE criticas_rating_fis:
                               
    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_tpctrrat AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctrrat AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF VAR aux_nrsequen          AS INTE                            NO-UNDO.
    DEF VAR aux_flgcescr          AS LOG INIT FALSE                  NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_nrsequen = 0.

    FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                       crapass.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapass   THEN
         DO:
             aux_nrsequen = aux_nrsequen + 1.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen,  /** Sequencia **/
                            INPUT 9,  /** Socio nao encontrado **/
                            INPUT-OUTPUT aux_dscritic).
         END.

    FIND crapttl WHERE crapttl.cdcooper = par_cdcooper   AND  
                       crapttl.nrdconta = par_nrdconta   AND
                       crapttl.idseqttl = 1              NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE crapttl   THEN
         DO:
             aux_nrsequen = aux_nrsequen + 1.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen,  
                            INPUT 821,
                            INPUT-OUTPUT aux_dscritic).                                   
         END.

    FIND crapcot WHERE crapcot.cdcooper = par_cdcooper   AND
                       crapcot.nrdconta = par_nrdconta  
                       NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapcot   THEN
         DO:
             aux_nrsequen = aux_nrsequen + 1.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, 
                            INPUT 169,
                            INPUT-OUTPUT aux_dscritic).            
         END.

    /* Nao efetuar validacoes quando for calcular soh a nota cooperado */
    IF  par_tpctrrat <> 0  AND
        par_nrctrrat <> 0  THEN
    DO:
        /* Para emprestimos */
        IF   par_tpctrrat = 90   THEN
             DO:
                 FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                                    crawepr.nrdconta = par_nrdconta   AND
                                    crawepr.nrctremp = par_nrctrrat 
                                    NO-LOCK NO-ERROR.
    
                 IF   NOT AVAILABLE crawepr   THEN
                      DO: 
                          FIND crapprp WHERE crapprp.cdcooper = par_cdcooper AND
                                             crapprp.nrdconta = par_nrdconta AND
                                             crapprp.tpctrato = par_tpctrrat AND
                                             crapprp.nrctrato = par_nrctrrat
                                     NO-LOCK NO-ERROR.

                          IF  NOT AVAILABLE crapprp THEN DO:

                              aux_nrsequen = aux_nrsequen + 1.
                             
                              RUN gera_erro (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT aux_nrsequen,
                                             INPUT 356,
                                             INPUT-OUTPUT aux_dscritic).
                          END.

                      END.
                 ELSE 
                      DO:
                          FIND craplcr WHERE craplcr.cdcooper = par_cdcooper AND
                               craplcr.cdlcremp = crawepr.cdlcrem
                               NO-LOCK NO-ERROR.
                                    
                          IF   NOT AVAILABLE craplcr   THEN
                               DO:
                                   aux_nrsequen = aux_nrsequen + 1.
                                 
                                   RUN gera_erro (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT aux_nrsequen,
                                                  INPUT 363,
                                                  INPUT-OUTPUT aux_dscritic).
                               END.  
                               
                          /* Condicao para caso a Finalidade for Cessao de Credito */
                          FOR FIRST crapfin FIELDS(tpfinali)
                                             WHERE crapfin.cdcooper = crawepr.cdcooper AND 
                                                   crapfin.cdfinemp = crawepr.cdfinemp
                                                   NO-LOCK: END.

                          IF AVAIL crapfin AND crapfin.tpfinali = 1 THEN
                             ASSIGN aux_flgcescr = TRUE.
                      END.                   
             END.
        ELSE
             DO:
                  /* Para limite desconto de titulo */
                  IF   par_tpctrrat = 3   THEN
                       DO:
                           FIND crawlim WHERE crawlim.cdcooper = par_cdcooper   AND
                                              crawlim.nrdconta = par_nrdconta   AND
                                              crawlim.tpctrlim = par_tpctrrat   AND
                                              crawlim.nrctrlim = par_nrctrrat 
                                              NO-LOCK NO-ERROR.
                     
                           IF   NOT AVAILABLE crawlim   THEN
                                DO:
                                    FIND craplim WHERE craplim.cdcooper = par_cdcooper   AND
                                                       craplim.nrdconta = par_nrdconta   AND
                                                       craplim.tpctrlim = par_tpctrrat   AND
                                                       craplim.nrctrlim = par_nrctrrat   
                                                       NO-LOCK NO-ERROR.
                     
                                    IF   NOT AVAILABLE craplim   THEN
                                    DO:
                                         aux_nrsequen = aux_nrsequen + 1.
              
                                         RUN gera_erro (INPUT par_cdcooper,
                                                        INPUT par_cdagenci,
                                                        INPUT par_nrdcaixa,
                                                        INPUT aux_nrsequen,
                                                        INPUT 484,
                                                        INPUT-OUTPUT aux_dscritic).
                                    END.
                                END.
                       END.
			      ELSE     /* Demais operacoes */
		             DO:
		                 FIND craplim WHERE craplim.cdcooper = par_cdcooper   AND
		                                    craplim.nrdconta = par_nrdconta   AND
		                                    craplim.tpctrlim = par_tpctrrat   AND
		                                    craplim.nrctrlim = par_nrctrrat   
		                                    NO-LOCK NO-ERROR.
		           
		                 IF   NOT AVAILABLE craplim   THEN
		                      DO:
		                          aux_nrsequen = aux_nrsequen + 1.
		    
		                          RUN gera_erro (INPUT par_cdcooper,
		                                         INPUT par_cdagenci,
		                                         INPUT par_nrdcaixa,
		                                         INPUT aux_nrsequen,
		                                         INPUT 484,
		                                         INPUT-OUTPUT aux_dscritic).
                              END.
                     END.
             END.
    END.

	  /* Nao validaremos os itens a seguir em caso de cessao de credito */
    IF aux_flgcescr THEN
        DO:
          IF CAN-FIND (FIRST tt-erro) THEN
            RETURN "NOK".
          RETURN "OK".
        END.

    IF   crapttl.vlsalari    = 0   AND
         crapttl.vldrendi[1] = 0   AND
         crapttl.vldrendi[2] = 0   AND
         crapttl.vldrendi[3] = 0   AND
         crapttl.vldrendi[4] = 0   AND
         crapttl.vldrendi[5] = 0   AND
         crapttl.vldrendi[6] = 0   THEN
         DO:
             ASSIGN aux_nrsequen = aux_nrsequen + 1.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, 
                            INPUT 246, /* Sem rendimento */
                            INPUT-OUTPUT aux_dscritic). 

             ASSIGN aux_nrsequen = aux_nrsequen + 1.  

              /* Dados cadastrais incompletos */
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, 
                            INPUT 830, /* Dados cadastrais inc. */
                            INPUT-OUTPUT aux_dscritic).  
         END.

    FIND LAST crapenc WHERE crapenc.cdcooper = par_cdcooper   AND 
                            crapenc.nrdconta = par_nrdconta   AND
                            crapenc.idseqttl = 1              AND
                            crapenc.tpendass = 10
                            NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapenc   THEN
         DO:
             aux_nrsequen = aux_nrsequen + 1.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen,
                            INPUT 247, /* Endereco nao cad. */
                            INPUT-OUTPUT aux_dscritic).

              /* Dados cadastrais incompletos */
             IF   NOT CAN-FIND (tt-erro WHERE tt-erro.cdcritic = 830) THEN
                  DO:
                      ASSIGN aux_nrsequen = aux_nrsequen + 1.

                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT aux_nrsequen, 
                                     INPUT 830, 
                                     INPUT-OUTPUT aux_dscritic).               
                  END.
                  
         END.

    IF   AVAIL crapenc   AND
         crapenc.incasprp = 0   THEN /* Cadastrar imovel !! */
         DO:    
             aux_nrsequen = aux_nrsequen + 1.
             
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen,
                            INPUT 926,
                            INPUT-OUTPUT aux_dscritic). 
             
             /* Dados cadastrais incompletos */
             IF   NOT CAN-FIND (tt-erro WHERE tt-erro.cdcritic = 830) THEN
                  DO:
                      ASSIGN aux_nrsequen = aux_nrsequen + 1.

                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT aux_nrsequen, 
                                     INPUT 830, 
                                     INPUT-OUTPUT aux_dscritic).                 
                  END.             
         END.
    
    IF   CAN-FIND (FIRST tt-erro) THEN
         RETURN "NOK".

    RETURN "OK".         

END PROCEDURE.


/***************************************************************************
 Tratamento das criticas para o calculo de pessoa juridica.
 Foi desenvolvido para mostrar todas as criticas do calculo.
***************************************************************************/

PROCEDURE criticas_rating_jur:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_tpctrrat AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctrrat AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF  VAR         aux_nrsequen AS INTE                            NO-UNDO.
    DEF  VAR         aux_vlmedfat AS DECI                            NO-UNDO.
    DEF  VAR         aux_dtadmsoc AS DATE                            NO-UNDO.
    DEF  VAR         aux_flgcescr AS LOG INIT FALSE                  NO-UNDO.


    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_nrsequen = 0.

    /* Nao validar para calculo do Risco cooperado*/
    IF  par_tpctrrat <> 0  AND
        par_nrctrrat <> 0  THEN
    DO:
        IF   par_tpctrrat = 90   THEN  /* Emprestimo / Financiamento */
             DO:
                 FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                                    crawepr.nrdconta = par_nrdconta   AND
                                    crawepr.nrctremp = par_nrctrrat 
                                    NO-LOCK NO-ERROR.
    
                 IF   NOT AVAILABLE crawepr   THEN
                      DO: 
                          FIND crapprp WHERE crapprp.cdcooper = par_cdcooper AND
                                             crapprp.nrdconta = par_nrdconta AND
                                             crapprp.tpctrato = par_tpctrrat AND
                                             crapprp.nrctrato = par_nrctrrat
                                     NO-LOCK NO-ERROR.

                          IF  NOT AVAILABLE crapprp THEN DO:

                              aux_nrsequen = aux_nrsequen + 1.
                             
                              RUN gera_erro (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT aux_nrsequen,
                                             INPUT 356,
                                             INPUT-OUTPUT aux_dscritic).
                          END.

                      END.
                 ELSE 
                      DO:
                          FIND craplcr WHERE 
                               craplcr.cdcooper = par_cdcooper   AND
                               craplcr.cdlcremp = crawepr.cdlcrem
                               NO-LOCK NO-ERROR.
                                    
                          IF   NOT AVAILABLE craplcr   THEN
                               DO:
                                   aux_nrsequen = aux_nrsequen + 1.
                                 
                                   RUN gera_erro (INPUT par_cdcooper,
                                                  INPUT par_cdagenci,
                                                  INPUT par_nrdcaixa,
                                                  INPUT aux_nrsequen,
                                                  INPUT 363,
                                                  INPUT-OUTPUT aux_dscritic).
                               END.                     

						  /* Condicao para caso a Finalidade for Cessao de Credito */
                          FOR FIRST crapfin FIELDS(tpfinali)
                                             WHERE crapfin.cdcooper = crawepr.cdcooper AND 
                                                   crapfin.cdfinemp = crawepr.cdfinemp
                                                   NO-LOCK: END.

                          IF AVAIL crapfin AND crapfin.tpfinali = 1 THEN
                             ASSIGN aux_flgcescr = TRUE.
                      END.                   
             END.
        ELSE
                      DO:
                  /* Para limite desconto de titulo */
                  IF   par_tpctrrat = 3   THEN
                       DO:
                           FIND crawlim WHERE crawlim.cdcooper = par_cdcooper   AND
                                              crawlim.nrdconta = par_nrdconta   AND
                                              crawlim.tpctrlim = par_tpctrrat   AND
                                              crawlim.nrctrlim = par_nrctrrat 
                                              NO-LOCK NO-ERROR.
                     
                           IF   NOT AVAILABLE crawlim   THEN
                                DO:
                                    FIND craplim WHERE craplim.cdcooper = par_cdcooper   AND
                                                       craplim.nrdconta = par_nrdconta   AND
                                                       craplim.tpctrlim = par_tpctrrat   AND
                                                       craplim.nrctrlim = par_nrctrrat   
                                                       NO-LOCK NO-ERROR.
                     
                                    IF   NOT AVAILABLE craplim   THEN
                                    DO:
				                          aux_nrsequen = aux_nrsequen + 1.
				    
				                          RUN gera_erro (INPUT par_cdcooper,
				                                         INPUT par_cdagenci,
				                                         INPUT par_nrdcaixa,
				                                         INPUT aux_nrsequen,
				                                         INPUT 484,
				                                         INPUT-OUTPUT aux_dscritic).
				                    END.
                                END.
                       END.
                 ELSE     /* Demais operacoes */
                       DO:
			                 FIND craplim WHERE craplim.cdcooper = par_cdcooper   AND
			                                    craplim.nrdconta = par_nrdconta   AND
			                                    craplim.tpctrlim = par_tpctrrat   AND
			                                    craplim.nrctrlim = par_nrctrrat   
			                                    NO-LOCK NO-ERROR.
			           
			                 IF   NOT AVAILABLE craplim   THEN
			                      DO:
			                          aux_nrsequen = aux_nrsequen + 1.
			    
			                          RUN gera_erro (INPUT par_cdcooper,
			                                         INPUT par_cdagenci,
			                                         INPUT par_nrdcaixa,
			                                         INPUT aux_nrsequen,
			                                         INPUT 484,
			                                         INPUT-OUTPUT aux_dscritic).
			                      END.                    
                      END.                    
             END.
    END.

	  /* Nao validaremos os itens a seguir em caso de cessao de credito */
    IF aux_flgcescr THEN
        DO:
          IF CAN-FIND (FIRST tt-erro) THEN
         RETURN "NOK".
    RETURN "OK".         
        END.

    /* Registro da empresa */
    FIND crapjur WHERE crapjur.cdcooper = par_cdcooper   AND
                       crapjur.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapjur   THEN
         DO:
             aux_nrsequen = aux_nrsequen + 1.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen,
                            INPUT 331,
                            INPUT-OUTPUT aux_dscritic). 
         END.
    ELSE
    IF   crapjur.cdseteco = 0   THEN  /* Setor economico */
         DO:
             aux_nrsequen = aux_nrsequen + 1.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen,
                            INPUT 879,
                            INPUT-OUTPUT aux_dscritic).   

             aux_nrsequen = aux_nrsequen + 1.

             /* Dados cadastrais */
             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen, 
                            INPUT 830, 
                            INPUT-OUTPUT aux_dscritic).         
         END.

    FIND crapjfn WHERE crapjfn.cdcooper = par_cdcooper   AND
                       crapjfn.nrdconta = par_nrdconta   NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE crapjfn   THEN
         DO:
             aux_nrsequen = aux_nrsequen + 1.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen,
                            INPUT 861, /* S/ dados financeiros */
                            INPUT-OUTPUT aux_dscritic).

             /* Dados cadastrais incompletos */
             IF  NOT CAN-FIND (tt-erro WHERE tt-erro.cdcritic = 830) THEN
                 DO:             
                     ASSIGN aux_nrsequen = aux_nrsequen + 1.
                     
                     RUN gera_erro (INPUT par_cdcooper,
                                    INPUT par_cdagenci,
                                    INPUT par_nrdcaixa,
                                    INPUT aux_nrsequen, 
                                    INPUT 830, 
                                    INPUT-OUTPUT aux_dscritic).   
                 END.  
         END.

        /* Verificar se existem Socios cadastrados */
    IF   NOT CAN-FIND(FIRST crapavt WHERE
                            crapavt.cdcooper = par_cdcooper   AND
                            crapavt.nrdconta = par_nrdconta   AND
                            crapavt.tpctrato = 6              AND
                            CAN-DO("SOCIO/PROPRIETARIO,SOCIO ADMINISTRADOR,DIRETOR/ADMINISTRADOR,SINDICO,ADMINISTRADOR",STRING(crapavt.dsproftl))) THEN
         DO:
             /* Critica para estas naturalidades juridicas */
             IF   CAN-DO ("2062,2135,4081,2089",STRING(crapjur.natjurid))  THEN
                  DO:
                      aux_nrsequen = aux_nrsequen + 1.

                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT aux_nrsequen,
                                     INPUT 917, /* Sem socio/propietario */
                                     INPUT-OUTPUT aux_dscritic). 
                          
                      /* Dados cadastrais incompletos */
                       IF  NOT CAN-FIND (tt-erro WHERE tt-erro.cdcritic = 830) THEN
                           DO:
                               ASSIGN aux_nrsequen = aux_nrsequen + 1.
                  
                               RUN gera_erro (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT aux_nrsequen, 
                                              INPUT 830, 
                                              INPUT-OUTPUT aux_dscritic).     
                               
                           END.                               
                  END.
         END.

    /* Pegar o socio mais antigo */
    FOR EACH crapavt WHERE crapavt.cdcooper = par_cdcooper         AND
                           crapavt.nrdconta = par_nrdconta         AND
                           crapavt.tpctrato = 6 /*Juridica*/       AND
                           CAN-DO("SOCIO/PROPRIETARIO,SOCIO ADMINISTRADOR,DIRETOR/ADMINISTRADOR,SINDICO,ADMINISTRADOR",STRING(crapavt.dsproftl)) NO-LOCK
                           BREAK BY crapavt.dtadmsoc DESC:

        IF   crapavt.dtadmsoc = ?  THEN
             NEXT.

        ASSIGN aux_dtadmsoc = crapavt.dtadmsoc.

    END.

    /* Naturalidades juridicas */
    IF   CAN-DO ("2062,2135,4081,2089",STRING(crapjur.natjurid))   THEN
         DO:
             IF   aux_dtadmsoc = ?  THEN /* Sem data cadastrada */
                  DO:
                      aux_nrsequen = aux_nrsequen + 1.

                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT aux_nrsequen,
                                     INPUT 923, 
                                     INPUT-OUTPUT aux_dscritic). 
                      

                      /* Dados cadastrais incompletos */
                      IF   NOT CAN-FIND (tt-erro WHERE tt-erro.cdcritic = 830) THEN
                           DO:
                               ASSIGN aux_nrsequen = aux_nrsequen + 1.
                  
                               RUN gera_erro (INPUT par_cdcooper,
                                              INPUT par_cdagenci,
                                              INPUT par_nrdcaixa,
                                              INPUT aux_nrsequen, 
                                              INPUT 830, 
                                              INPUT-OUTPUT aux_dscritic).   
                               
                           END.
                  END.
         END.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    RUN calcula-faturamento IN h-b1wgen9999 (INPUT  par_cdcooper,
                                             INPUT  par_cdagenci,
                                             INPUT  par_nrdcaixa,
                                             INPUT  par_idorigem,
                                             INPUT  par_nrdconta,
                                             INPUT  par_dtmvtolt,
                                             OUTPUT aux_vlmedfat).
    DELETE PROCEDURE h-b1wgen9999.

    IF   aux_vlmedfat = 0   THEN
         DO:
             aux_nrsequen = aux_nrsequen + 1.

             RUN gera_erro (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT aux_nrsequen,
                            INPUT 924, 
                            INPUT-OUTPUT aux_dscritic). 

             /* Dados cadastrais incompletos */
             IF   NOT CAN-FIND (tt-erro WHERE tt-erro.cdcritic = 830) THEN
                  DO:
                      ASSIGN aux_nrsequen = aux_nrsequen + 1.
         
                      RUN gera_erro (INPUT par_cdcooper,
                                     INPUT par_cdagenci,
                                     INPUT par_nrdcaixa,
                                     INPUT aux_nrsequen, 
                                     INPUT 830, 
                                     INPUT-OUTPUT aux_dscritic).    

             END.
    END.

    IF   CAN-FIND (FIRST tt-erro) THEN
         RETURN "NOK".

    RETURN "OK".

END PROCEDURE.


/****************************************************************************
 Gravar itens do rating na crapras quando for efetivada a proposta ou em
 temp temp-table quando for somente criada uma proposta.
****************************************************************************/

PROCEDURE grava_item_rating:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrtopico AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nritetop AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrseqite AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_flgcriar AS LOGI                            NO-UNDO.
    DEF  INPUT PARAM par_dsvalite AS CHAR                            NO-UNDO.
                                
    DEF VAR         aux_contador  AS INTE                            NO-UNDO.


    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".


    IF   par_flgcriar   THEN  /* Criar Rating proposto */
         DO TRANSACTION:

             DO aux_contador = 1 TO 10:
             
                FIND crapras WHERE crapras.cdcooper = par_cdcooper   AND
                                   crapras.nrdconta = par_nrdconta   AND
                                   crapras.nrctrrat = par_nrctrato   AND
                                   crapras.tpctrrat = par_tpctrato   AND
                                   crapras.nrtopico = par_nrtopico   AND
                                   crapras.nritetop = par_nritetop                                 
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                
                IF   NOT AVAILABLE crapras   THEN /* Criacao do Rating */
                     DO:
                         IF   LOCKED crapras   THEN
                              DO:          
                                  aux_cdcritic = 77.
                                  PAUSE 2 NO-MESSAGE.
                                  NEXT.
                              END.
                    
                         CREATE crapras.
                         
                         ASSIGN crapras.cdcooper = par_cdcooper
                                crapras.nrdconta = par_nrdconta
                                crapras.nrctrrat = par_nrctrato
                                crapras.tpctrrat = par_tpctrato
                                crapras.nrtopico = par_nrtopico
                                crapras.nritetop = par_nritetop
                                crapras.nrseqite = par_nrseqite
                                crapras.dsvalite = par_dsvalite.
                         VALIDATE crapras.

                     END.
                ELSE                              /* Atualizacao Rating */
                     DO:
                         ASSIGN crapras.nrseqite = par_nrseqite
                                crapras.dsvalite = par_dsvalite.

                     END.

                aux_cdcritic = 0.
                LEAVE.

             END. /* Fim LOCK crapras*/

             IF   aux_cdcritic > 0   THEN
                  RETURN "NOK".
               
         END.  /* Fim Transaction */
    ELSE     /* Temp-table soh para impressao */
         DO TRANSACTION: 
		   IF aux_flghisto THEN
         DO: 
				 { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }
				/* Efetuar a chamada a rotina Oracle */ 
				RUN STORED-PROCEDURE pc_grava_his_crapras
				 aux_handproc = PROC-HANDLE NO-ERROR 
							 ( INPUT par_cdcooper /* pr_cdcooper --> Codigo da cooperativa */
							  ,INPUT par_nrdconta /* pr_nrdconta --> Numero da conta */
							  ,INPUT par_nrctrato /* pr_nrctrrat --> Numero do contrato */
							  ,INPUT par_tpctrato /* pr_tpctrrat --> Tipo do contrato */
							  ,INPUT par_nrtopico /* pr_nrtopico --> Numero do topico */
							  ,INPUT par_nritetop /* pr_nritetop --> Numero item topico */
							  ,INPUT par_nrseqite /* pr_nrseqite --> Numero nota item */
							  ,INPUT par_dsvalite /* pr_dsvalite --> Valor exato item */
							  ,OUTPUT 0           /* pr_cdcritic --> Codigo da critica).     */
							  ,OUTPUT "" ).       /* pr_dscritic --> Descriçao da critica    */
				/* Fechar o procedimento para buscarmos o resultado */ 
				CLOSE STORED-PROC pc_grava_his_crapras
					aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc. 
				{ includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }
				ASSIGN aux_cdcritic = pc_grava_his_crapras.pr_cdcritic
										 WHEN pc_grava_his_crapras.pr_cdcritic <> ?
					   aux_dscritic = pc_grava_his_crapras.pr_dscritic
										 WHEN pc_grava_his_crapras.pr_dscritic <> ?.
				IF aux_cdcritic > 0 OR aux_dscritic <> '' THEN
				  RETURN "NOK".
			 END.
             CREATE tt-crapras.
             ASSIGN tt-crapras.nrtopico = par_nrtopico
                    tt-crapras.nritetop = par_nritetop
                    tt-crapras.nrseqite = par_nrseqite.           
             
         END.
                 
    RETURN "OK".

END PROCEDURE.


/******************************************************************
 Gravar o Rating que deu origem ao efetivo.
******************************************************************/  
PROCEDURE grava_rating_origem:

    DEF  INPUT PARAM par_cdcooper AS INTE                NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                NO-UNDO.
    DEF  INPUT PARAM par_rowidnrc AS ROWID               NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                NO-UNDO.

    DEF  VAR         aux_contador AS INTE                NO-UNDO.


    DO aux_contador = 1 TO 10:
    
        IF   par_rowidnrc <> ? THEN
             FIND crapnrc WHERE ROWID (crapnrc) = par_rowidnrc
                                      EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        ELSE
             FIND crapnrc WHERE crapnrc.cdcooper = par_cdcooper   AND
                                crapnrc.nrdconta = par_nrdconta   AND
                                crapnrc.tpctrrat = par_tpctrato   AND
                                crapnrc.nrctrrat = par_nrctrato
                                EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF   NOT AVAILABLE crapnrc   THEN
             IF   LOCKED crapnrc THEN
                  DO:
                      aux_cdcritic = 77.
                      PAUSE 1 NO-MESSAGE.
                      NEXT.
                  END.
             ELSE
                  DO:
                      aux_cdcritic = 55.
                      LEAVE.
                  END.

        aux_cdcritic = 0.
        LEAVE.

    END. /* FIM do DO WHILE TRUE crapnrc */

    IF   aux_cdcritic <> 0   THEN
         RETURN "NOK".
         
    /* Salvar Origem do Rating efetivo */
    ASSIGN crapnrc.flgorige = TRUE.

    RETURN "OK".

END PROCEDURE.


/***************************************************************
 Limpar campo da origem do Rating.
***************************************************************/

PROCEDURE limpa_rating_origem:

    DEF INPUT PARAM par_cdcooper  AS INTE                NO-UNDO.
    DEF INPUT PARAM par_nrdconta  AS INTE                NO-UNDO.


    FOR EACH crapnrc WHERE crapnrc.cdcooper = par_cdcooper   AND
                           crapnrc.nrdconta = par_nrdconta   
                           EXCLUSIVE-LOCK:

        ASSIGN crapnrc.flgorige = FALSE.

    END.

    RETURN "OK".

END PROCEDURE.

/********************************************************************
 Natureza da operacao Pessoa fisica (2_1).
********************************************************************/

PROCEDURE natureza_operacao:

    DEF  INPUT PARAM par_tpctrato AS INTE                NO-UNDO.
    DEF  INPUT PARAM par_idquapro AS INTE                NO-UNDO.
    DEF  INPUT PARAM par_dsoperac AS CHAR                NO-UNDO.
    DEF  INPUT PARAM par_cdcooper AS INTE                NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                NO-UNDO.

    DEF OUTPUT PARAM par_nrseqite AS INTE                NO-UNDO.


    IF   par_tpctrato = 90   THEN  /* Emprestimo / Financiamento */ 
         DO:
             IF   par_idquapro > 2   THEN  
                  CASE par_idquapro:
                  /* Renegociacao / Composicao de divida / Cessao de Cartao */
                       WHEN 3 OR 
                       WHEN 4 OR   
                       WHEN 5 THEN
                          par_nrseqite = 4.
                  END CASE.
             ELSE
                  DO:
                      IF   par_dsoperac = "FINANCIAMENTO"   THEN
                           ASSIGN par_nrseqite = 1.
                      ELSE
                           ASSIGN par_nrseqite = 2.                           
                  END.                         
         END.                       
    ELSE                            /* Cheque especial / Descontos */
         DO:
             CASE  par_tpctrato:

                WHEN   1   THEN   ASSIGN par_nrseqite = 3. /* Ch.especial */
                WHEN   2   THEN   ASSIGN par_nrseqite = 2. /* Des.cheque  */
                WHEN   3   THEN   ASSIGN par_nrseqite = 2. /* Des.Tit.    */ 

             END CASE.
         END.
    
    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Calcula endividamento total SCR. Itens 3_3 (Fisica) e 5_1 (Juridica). 
*****************************************************************************/

PROCEDURE calcula_endividamento:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dsliquid AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtopr AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM par_vlutiliz AS DECI                            NO-UNDO.
                                                                    

    DEF  VAR         aux_contador AS INTE                            NO-UNDO.
    DEF  VAR         aux_nrctrliq AS CHAR                           NO-UNDO.

    DEF BUFFER b-crawepr FOR crawepr.

    RUN sistema/generico/procedures/b1wgen9999.p PERSISTENT SET h-b1wgen9999.

    IF   NOT VALID-HANDLE(h-b1wgen9999)   THEN
         DO:
             aux_dscritic = "Handle invalido para a BO b1wgen9999.".        
             RETURN "NOK".
         END.
       
    /* Para todos os emprestimos nao liquidados , que estejam */
    /* liquidando outros ... */
    FOR EACH  crapepr WHERE crapepr.cdcooper = par_cdcooper   AND
                            crapepr.nrdconta = par_nrdconta   AND
                            crapepr.inliquid = 0              NO-LOCK,

        FIRST b-crawepr WHERE b-crawepr.cdcooper = crapepr.cdcooper   AND
                              b-crawepr.nrdconta = crapepr.nrdconta   AND
                              b-crawepr.nrctremp = crapepr.nrctremp   NO-LOCK:

        DO aux_contador = 1 TO 10:

            IF   b-crawepr.nrctrliq[aux_contador] = 0   THEN
                 NEXT.

            aux_nrctrliq = STRING(b-crawepr.nrctrliq[aux_contador]).

            /* Se nao existe ainda na lista a liquidar */
            IF   LOOKUP (aux_nrctrliq,par_dsliquid) = 0  THEN
                 par_dsliquid = IF   par_dsliquid = ""   THEN
                                     STRING(b-crawepr.nrctrliq[aux_contador])
                                ELSE 
                                     par_dsliquid + "," +
                                     STRING(b-crawepr.nrctrliq[aux_contador]).
        END.

    END. /* Fim , contratos a liquidar */ 
        
    RUN saldo_utiliza IN h-b1wgen9999 (INPUT  par_cdcooper,
                                       INPUT  par_cdagenci,
                                       INPUT  par_nrdcaixa,
                                       INPUT  par_cdoperad,
                                       INPUT  "b1wgen0043",
                                       INPUT  par_idorigem,
                                       INPUT  par_nrdconta,
                                       INPUT  par_idseqttl,
                                       INPUT  par_dtmvtolt,
                                       INPUT  par_dtmvtopr,
                                       INPUT  par_dsliquid,
                                       INPUT  par_inproces,
                                       INPUT FALSE, /*Consulta por cpf*/
                                       OUTPUT par_vlutiliz,
                                       OUTPUT TABLE tt-erro).       
    DELETE PROCEDURE h-b1wgen9999.
     
    IF   RETURN-VALUE <> "OK"   THEN
         RETURN "NOK".
         
    RETURN "OK".

END PROCEDURE.


/**************************************************************************** 
 Item 3_1 (Pessoa Fisica) e  5_2 (Pessoa juridica) do Rating. 
****************************************************************************/
PROCEDURE nivel_comprometimento:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrctrliq AS INTE EXTENT 10                  NO-UNDO.
    DEF  INPUT PARAM par_vlpreemp AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_inproces AS INTE                            NO-UNDO.

    DEF OUTPUT PARAM par_vltotpre AS DECI                            NO-UNDO.

    /* Variaveis para o saldo devedor do emprestimo b1wgen0002 */
    DEF VAR par_vlsdeved          AS DECI                            NO-UNDO.
    DEF VAR par_qtprecal          AS DECI                            NO-UNDO.

    DEF VAR aux_contador          AS INTE                            NO-UNDO.
    DEF VAR aux_nrctrliq          AS INTE                            NO-UNDO.
    DEF VAR aux_valorpre          AS DECI                            NO-UNDO.

    DEF BUFFER crablim FOR craplim.
    DEF BUFFER crabepr FOR crapepr.


    IF   par_tpctrato = 90   THEN  /* Se emprestimo/ financiamento */
         DO:                    
             RUN sistema/generico/procedures/b1wgen0002.p PERSISTENT SET h-b1wgen0002. 
                    
             IF   NOT VALID-HANDLE (h-b1wgen0002)  THEN
                  DO:
                      aux_dscritic = "Handle invalido para a BO b1wgen0002".
                      RETURN "NOK".
                  END.
             
             /* Trazer o valor de todas as prestacoes de emprestimo */
             RUN saldo-devedor-epr IN h-b1wgen0002 (INPUT  par_cdcooper,
                                                    INPUT  0,
                                                    INPUT  0,
                                                    INPUT  par_cdoperad,
                                                    INPUT  "b1wgen0043",
                                                    INPUT  par_idorigem,
                                                    INPUT  par_nrdconta,
                                                    INPUT  par_idseqttl,
                                                    INPUT  par_dtmvtolt,
                                                    INPUT  ?,
                                                    INPUT  0, /* Todos os emprestimos */
                                                    INPUT  "",
                                                    INPUT  par_inproces,
                                                    INPUT  FALSE,
                                                    OUTPUT par_vlsdeved,
                                                    OUTPUT par_vltotpre,
                                                    OUTPUT par_qtprecal,
                                                    OUTPUT TABLE tt-erro).
             DELETE PROCEDURE h-b1wgen0002.
                          
             IF   RETURN-VALUE <> "OK"   THEN
                  DO:
                      FIND FIRST tt-erro NO-LOCK NO-ERROR.
         
                      IF   AVAILABLE tt-erro   THEN
                           DO:
                               ASSIGN aux_cdcritic = tt-erro.cdcritic.
                           END.
                      ELSE
                           DO:
                               ASSIGN aux_dscritic = "Erro na BO b1wgen0002.".
                           END.
         
                      RETURN "NOK".         
                  END.

             /* BNDES - Emprestimos Ativos */
             FOR EACH crapebn WHERE crapebn.cdcooper = par_cdcooper AND
                                    crapebn.nrdconta = par_nrdconta AND 
                                   (crapebn.insitctr = "N" OR
                                    crapebn.insitctr = "A")         AND
                                    crapebn.vlsdeved > 0 NO-LOCK:
                ASSIGN par_vltotpre = par_vltotpre + crapebn.vlparepr.

             END.

             ASSIGN aux_valorpre = 0.     

             /* Somar todas as parcelas que esta liquidando */
             DO aux_contador = 1 TO 10:

                aux_nrctrliq = par_nrctrliq[aux_contador].

                IF   aux_nrctrliq = 0   THEN
                     NEXT.

                FIND crabepr WHERE crabepr.cdcooper = par_cdcooper AND
                                   crabepr.nrdconta = par_nrdconta AND
                                   crabepr.nrctremp = aux_nrctrliq 
                                   NO-LOCK NO-ERROR.

                IF   NOT AVAIL crabepr   THEN
                     NEXT.

                aux_valorpre = aux_valorpre + crabepr.vlpreemp.

             END.  

             /** BNDES - nao tera tratamento ref. liquidacao de contratos
                         inicialmente */ 


             /* Restar as parcelas pois estes emprestimos estao
                sendo liquidados  */
             ASSIGN par_vltotpre = par_vltotpre - aux_valorpre.
                              

             /* Se esta efetivando ele ja considera a parcela atual */
             /* Senao contabilizar */
             IF   NOT CAN-FIND (crapepr WHERE 
                                crapepr.cdcooper = par_cdcooper  AND
                                crapepr.nrdconta = par_nrdconta  AND
                                crapepr.nrctremp = par_nrctrato  NO-LOCK)  
                     AND
                  NOT CAN-FIND (crapebn WHERE 
                                crapebn.cdcooper = par_cdcooper  AND
                                crapebn.nrdconta = par_nrdconta  AND
                                crapebn.nrctremp = par_nrctrato  NO-LOCK) THEN
                  ASSIGN par_vltotpre = par_vltotpre + par_vlpreemp. /* Somar contrato atual */
       
         
         END.
    ELSE                           /* Se C.especial / desconto  */ 
         DO:                                         
             /* Contabilizar todos os descontos / cheque especial */
             /* Sobre 12, para considerar como parcela            */
             FOR EACH crablim WHERE crablim.cdcooper = par_cdcooper   AND
                                    crablim.nrdconta = par_nrdconta   AND
                                    crablim.insitlim = 2  /* Ativo*/  AND
                                    
                                   ((crablim.tpctrlim = 3             AND   
                                     crablim.dtfimvig > par_dtmvtolt) OR
                  
                                    (crablim.tpctrlim = 2)            OR

                                    (crablim.tpctrlim = 1))           NO-LOCK:
                                                                                              
                 par_vltotpre = par_vltotpre + (crablim.vllimite / 12).   
                              
             END.

             /* Se esta efetivando ele ja considera a parcela atual */
             /* Senao contabilizar */

             FIND crablim WHERE crablim.cdcooper = par_cdcooper   AND
                                crablim.nrdconta = par_nrdconta   AND
                                crablim.tpctrlim = par_tpctrato   AND
                                crablim.nrctrlim = par_nrctrato  
                                NO-LOCK NO-ERROR.

             /* Somar contrato atual */
             IF   AVAILABLE crablim   THEN
                  IF   crablim.insitlim <> 2 THEN
                       ASSIGN par_vltotpre = par_vltotpre + (par_vlpreemp / 12).           
         
         END.

    RETURN "OK".

END PROCEDURE.


/*****************************************************************************
 Verifica o historico do cooperado referente a estouros.
 Item 1_5 de pessoa fisica e 6_4 de pessoa juridica.
******************************************************************************/

PROCEDURE historico_cooperado:

    DEF  INPUT PARAM par_cdcooper AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_idseqttl AS INTE                            NO-UNDO.
                                                                     
    DEF OUTPUT PARAM par_nrseqite AS INTE                            NO-UNDO.
                                                                     
    DEF  VAR         aux_dtiniest AS DATE                            NO-UNDO.
    DEF  VAR         aux_qtdiaatr AS INTE                            NO-UNDO.
    DEF  VAR         aux_qtestour AS INTE                            NO-UNDO.                                                    
    DEF  VAR         aux_qtdiaat2 AS INTE                            NO-UNDO.
    DEF  VAR         aux_qtdiasav AS INTE                            NO-UNDO.


    EMPTY TEMP-TABLE tt-estouros.

    RUN sistema/generico/procedures/b1wgen0027.p PERSISTENT SET h-b1wgen0027.
        
    IF   NOT VALID-HANDLE (h-b1wgen0027)   THEN
         DO:
              aux_dscritic = "Handle invalido para BO b1wgen0027.".
              RETURN "NOK".  
         END.
    
    RUN lista_estouros IN h-b1wgen0027 (INPUT  par_cdcooper,
                                        INPUT  par_cdagenci,
                                        INPUT  par_nrdcaixa,
                                        INPUT  par_cdoperad,
                                        INPUT  par_nrdconta,
                                        INPUT  par_idorigem,
                                        INPUT  par_idseqttl,
                                        INPUT  "b1wgen0043",
                                        OUTPUT TABLE tt-erro,
                                        OUTPUT TABLE tt-estouros).           
    DELETE PROCEDURE h-b1wgen0027.
    
    IF   RETURN-VALUE <> "OK"   THEN
         DO:
             FIND FIRST tt-erro NO-LOCK NO-ERROR.

             IF   AVAILABLE tt-erro   THEN
                  aux_cdcritic = tt-erro.cdcritic.
             ELSE
                  aux_dscritic = "Erro na BO de ocorrencias.".

             RETURN "NOK".
         END.

    /* Data do inicio do estouro a partir de um ano atras */
    ASSIGN aux_dtiniest = ADD-INTERVAL(par_dtmvtolt, - 1,"YEARS")
           rat_qtchqesp = 0
           rat_qtdevalo = 0
           rat_qtdevald = 0.

    FOR EACH tt-estouros WHERE tt-estouros.dtiniest >= aux_dtiniest    AND
                               tt-estouros.cdhisest  = "Estouro"       NO-LOCK:

        ASSIGN aux_qtestour = aux_qtestour + 1       /* Ocorrencias */
               aux_qtdiaatr = tt-estouros.qtdiaest   /* Maior qtd de dias*/
                              WHEN tt-estouros.qtdiaest > aux_qtdiaatr.
                     
    END.

    FOR EACH tt-estouros WHERE tt-estouros.dtiniest >= aux_dtiniest     AND
                               tt-estouros.cdhisest  = "Devolucao Chq." NO-LOCK,
           FIRST crapali WHERE crapali.dsalinea = tt-estouros.dsobserv
                           AND CAN-DO("11,12",STRING(crapali.cdalinea)) NO-LOCK:

      IF crapali.cdalinea = 11 THEN
        rat_qtdevalo = rat_qtdevalo + 1.
      ELSE
        rat_qtdevald = rat_qtdevald + 1.
    END.

    FOR EACH crapsda WHERE crapsda.cdcooper  = par_cdcooper   AND
                           crapsda.nrdconta  = par_nrdconta   AND
                           crapsda.dtmvtolt >= aux_dtiniest   NO-LOCK:

        IF   crapsda.vlsddisp < 0  AND
             crapsda.vlsddisp >= (crapsda.vllimcre * -1)  THEN
             DO:
                 ASSIGN aux_qtdiaat2 = aux_qtdiaat2 + 1
                        rat_qtchqesp = rat_qtchqesp + 1.
             END.
        ELSE
             DO:    
                 IF   aux_qtdiaat2 > aux_qtdiasav   THEN
                      aux_qtdiasav = aux_qtdiaat2.

                 aux_qtdiaat2 = 0. 
             END.
    END.

    IF   aux_qtdiasav = 0   THEN
         aux_qtdiasav = aux_qtdiaat2.

    IF   aux_qtdiaat2 > aux_qtdiasav   THEN
         aux_qtdiasav = aux_qtdiaat2.

    IF   aux_qtestour <= 24    AND      /* Ate 24 estouros  */
         aux_qtdiaatr <= 30    AND   /* com no maximo 30 dias  */
         aux_qtdiasav <= 124   THEN  /* Chq. esp ate 124 dias seguidos*/
         DO:
             ASSIGN par_nrseqite = 1. 
         END.       
    ELSE
    IF   aux_qtdiaatr <= 30    AND  /* No maximo 30 dias */
         aux_qtdiasav <= 249   THEN /* 249 dias de cheque especial */
         DO:
             ASSIGN par_nrseqite = 2.
         END.
    ELSE
         DO:
             ASSIGN par_nrseqite = 3.
         END.
    
    IF  par_nrseqite <> 3  THEN
    DO:
        IF  CAN-FIND(FIRST crapneg WHERE 
                           crapneg.cdcooper = par_cdcooper AND
                           crapneg.cdhisest = 1            AND
                           crapneg.nrdconta = par_nrdconta AND
                           crapneg.dtiniest >= DATE(MONTH(par_dtmvtolt),
                                                    DAY(par_dtmvtolt),
                                                    YEAR(par_dtmvtolt) - 1)
                                                           AND 
                          (crapneg.cdobserv = 11 OR
                           crapneg.cdobserv = 12) NO-LOCK) THEN
            ASSIGN par_nrseqite = 4.
    END.     
    
    ASSIGN aux_dsvalite = STRING(aux_qtestour) + " est., " + STRING(aux_qtdiaatr) + " dias atr., " + STRING(aux_qtdiasav) + " dias ch. esp."
           rat_qtadidep = aux_qtestour.
    
    RETURN "OK".

END PROCEDURE.


/**************************************************************************
 Retorna a descricao do tipo de operacao sendo efetuada.
**************************************************************************/
PROCEDURE descricao-operacao:

    DEF  INPUT PARAM par_tpctrrat AS INTE                          NO-UNDO.
    DEF OUTPUT PARAM par_dsctrrat AS CHAR                          NO-UNDO.

    CASE par_tpctrrat:

        WHEN   1  THEN   ASSIGN par_dsctrrat = "Limite Credito".
        WHEN   2  THEN   ASSIGN par_dsctrrat = "Descto. Cheque".
        WHEN   3  THEN   ASSIGN par_dsctrrat = "Descto. Titulo".
        WHEN   90 THEN   ASSIGN par_dsctrrat = "Emprestimo".

    END CASE.

    RETURN "OK".

END PROCEDURE.


PROCEDURE descricao-situacao:

    DEF  INPUT PARAM par_insitrat AS INTE                          NO-UNDO.
    DEF OUTPUT PARAM par_dsditrat AS CHAR                          NO-UNDO.

    CASE par_insitrat:

        WHEN   1   THEN   ASSIGN par_dsditrat = "Proposto".
        WHEN   2   THEN   ASSIGN par_dsditrat = "Efetivo".

    END CASE.

    RETURN "OK".

END PROCEDURE.


/****************************************************************************
 Obter as descricoes do risco, provisao , etc ...
****************************************************************************/

PROCEDURE descricoes_risco:

    DEF INPUT  PARAM par_cdcooper AS INTE                          NO-UNDO.
    DEF INPUT  PARAM par_inpessoa AS INTE                          NO-UNDO.
    DEF INPUT  PARAM par_nrnotrat AS DECI                          NO-UNDO.
    DEF INPUT  PARAM par_nrnotatl AS DECI                          NO-UNDO.
    DEF INPUT  PARAM par_nivrisco AS INTE                          NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-risco.
    DEF OUTPUT PARAM TABLE FOR tt-impressao-risco-tl.


    DEF VAR          aux_contador AS INTE                            NO-UNDO.
    DEF VAR       cl_aux_dsdrisco AS CHAR                 EXTENT 20  NO-UNDO.
    DEF VAR       cl_aux_percentu AS DECI                 EXTENT 20  NO-UNDO.
    DEF VAR       cl_aux_notadefi AS DECI                 EXTENT 20  NO-UNDO.
    DEF VAR       cl_aux_notatefi AS DECI                 EXTENT 20  NO-UNDO.
    DEF VAR       cl_aux_parecefi AS CHAR                 EXTENT 20  NO-UNDO.
    DEF VAR       cl_aux_notadeju AS DECI                 EXTENT 20  NO-UNDO.
    DEF VAR       cl_aux_notateju AS DECI                 EXTENT 20  NO-UNDO.
    DEF VAR       cl_aux_pareceju AS CHAR                 EXTENT 20  NO-UNDO.
    DEF VAR       cl_percentu_temp AS DECI                           NO-UNDO.
    DEF VAR       tl_percentu_temp AS DECI                           NO-UNDO.

    DEF VAR       tl_aux_dsdrisco AS CHAR                 EXTENT 20  NO-UNDO.
    DEF VAR       tl_aux_percentu AS DECI                 EXTENT 20  NO-UNDO.
    DEF VAR       tl_aux_notadefi AS DECI                 EXTENT 20  NO-UNDO.
    DEF VAR       tl_aux_notatefi AS DECI                 EXTENT 20  NO-UNDO.
    DEF VAR       tl_aux_parecefi AS CHAR                 EXTENT 20  NO-UNDO.
    DEF VAR       tl_aux_notadeju AS DECI                 EXTENT 20  NO-UNDO.
    DEF VAR       tl_aux_notateju AS DECI                 EXTENT 20  NO-UNDO.
    DEF VAR       tl_aux_pareceju AS CHAR                 EXTENT 20  NO-UNDO.

    EMPTY TEMP-TABLE tt-impressao-risco.
    EMPTY TEMP-TABLE tt-impressao-risco-tl.

    
    /* Risco basedo no calculo do rating */
    FOR EACH craptab WHERE craptab.cdcooper = par_cdcooper AND 
                           craptab.nmsistem = "CRED"       AND 
                           craptab.tptabela = "GENERI"     AND 
                           craptab.cdempres = 00           AND
                           craptab.cdacesso = "PROVISAOCL" NO-LOCK:
                                 
        ASSIGN aux_contador = INT(SUBSTR(craptab.dstextab,12,2))
               cl_aux_dsdrisco[aux_contador] = TRIM(SUBSTR(craptab.dstextab,8,3))
               cl_aux_percentu[aux_contador] = DEC(SUBSTR(craptab.dstextab,1,6))
    
               cl_aux_notadefi[aux_contador] = DEC(SUBSTR(craptab.dstextab,27,6))
               cl_aux_notatefi[aux_contador] = DEC(SUBSTR(craptab.dstextab,34,6))
               cl_aux_parecefi[aux_contador] = SUBSTR(craptab.dstextab,41,15)
    
               cl_aux_notadeju[aux_contador] = DEC(SUBSTR(craptab.dstextab,56,6))
               cl_aux_notateju[aux_contador] = DEC(SUBSTR(craptab.dstextab,62,6))
               cl_aux_pareceju[aux_contador] = SUBSTR(craptab.dstextab,70,15).
                         
        IF cl_aux_dsdrisco[aux_contador] = "A"  THEN DO:
            cl_percentu_temp = DEC(SUBSTR(craptab.dstextab,1,6)).
        END.
        ELSE IF cl_aux_dsdrisco[aux_contador] = "AA"  THEN DO:
            cl_aux_percentu[aux_contador] = cl_percentu_temp.
        END.
                         
        IF   (par_inpessoa = 1                                AND 
              par_nrnotrat >= cl_aux_notadefi[aux_contador]   AND   
              par_nrnotrat <= cl_aux_notatefi[aux_contador])  OR

             (par_inpessoa > 1                                AND
              par_nrnotrat >= cl_aux_notadeju[aux_contador]   AND
              par_nrnotrat <= cl_aux_notateju[aux_contador])  OR

             (par_nivrisco <> 0                            AND
              par_nivrisco =  aux_contador)                THEN            
             DO:

                 CREATE tt-impressao-risco.
                 ASSIGN tt-impressao-risco.vlrtotal = par_nrnotrat
                        tt-impressao-risco.dsdrisco = 
                                           cl_aux_dsdrisco[aux_contador]
                        tt-impressao-risco.vlprovis = 
                                           cl_aux_percentu[aux_contador].
                           
                 IF   par_inpessoa = 1   THEN
                      tt-impressao-risco.dsparece = 
                                         cl_aux_parecefi[aux_contador].
                 ELSE
                      tt-impressao-risco.dsparece =
                                         cl_aux_pareceju[aux_contador]. 

                 /* Risco antigo, nao mais utilizado */
                 IF   tt-impressao-risco.dsdrisco = "AA"   THEN
                      ASSIGN tt-impressao-risco.dsdrisco = "A".
                    
             END.
                                                                                        
    END.  /* Fim do FOR EACH risco */

    
    /* Risco basedo no calculo do rating */
    FOR EACH craptab WHERE craptab.cdcooper = par_cdcooper AND 
                           craptab.nmsistem = "CRED"       AND 
                           craptab.tptabela = "GENERI"     AND 
                           craptab.cdempres = 00           AND
                           craptab.cdacesso = "PROVISAOTL" NO-LOCK:
                                 
        ASSIGN aux_contador = INT(SUBSTR(craptab.dstextab,12,2))
               tl_aux_dsdrisco[aux_contador] = TRIM(SUBSTR(craptab.dstextab,8,3))
               tl_aux_percentu[aux_contador] = DEC(SUBSTR(craptab.dstextab,1,6))
    
               tl_aux_notadefi[aux_contador] = DEC(SUBSTR(craptab.dstextab,27,6))
               tl_aux_notatefi[aux_contador] = DEC(SUBSTR(craptab.dstextab,34,6))
               tl_aux_parecefi[aux_contador] = SUBSTR(craptab.dstextab,41,15)
    
               tl_aux_notadeju[aux_contador] = DEC(SUBSTR(craptab.dstextab,56,6))
               tl_aux_notateju[aux_contador] = DEC(SUBSTR(craptab.dstextab,62,6))
               tl_aux_pareceju[aux_contador] = SUBSTR(craptab.dstextab,70,15).
        
        IF tl_aux_dsdrisco[aux_contador] = "A"  THEN DO:
            tl_percentu_temp = DEC(SUBSTR(craptab.dstextab,1,6)).
        END.
        ELSE IF tl_aux_dsdrisco[aux_contador] = "AA"  THEN DO:
            tl_aux_percentu[aux_contador] = tl_percentu_temp.
        END.

        IF   (par_inpessoa = 1                                AND 
              par_nrnotatl >= tl_aux_notadefi[aux_contador]   AND   
              par_nrnotatl <= tl_aux_notatefi[aux_contador])  OR

             (par_inpessoa > 1                                AND
              par_nrnotatl >= tl_aux_notadeju[aux_contador]   AND
              par_nrnotatl <= tl_aux_notateju[aux_contador])  OR

             (par_nivrisco <> 0                            AND
              par_nivrisco =  aux_contador)                THEN            
             DO:
                 CREATE tt-impressao-risco-tl.
                 ASSIGN tt-impressao-risco-tl.vlrtotal = par_nrnotatl
                        tt-impressao-risco-tl.dsdrisco = 
                                           tl_aux_dsdrisco[aux_contador]
                        tt-impressao-risco-tl.vlprovis = 
                                           tl_aux_percentu[aux_contador].
                           
                 IF   par_inpessoa = 1   THEN
                      tt-impressao-risco-tl.dsparece = 
                                         tl_aux_parecefi[aux_contador].
                 ELSE
                      tt-impressao-risco-tl.dsparece =
                                         tl_aux_pareceju[aux_contador]. 

                 /* Risco antigo, nao mais utilizado */
                 IF   tt-impressao-risco-tl.dsdrisco = "AA"   THEN
                      ASSIGN tt-impressao-risco-tl.dsdrisco = "A".
                    
             END.
                                                                                        
    END.  /* Fim do FOR EACH risco */

    
    RETURN "OK".

END PROCEDURE.

/********************************************************************************* 
 Valor da operacao do Rating 
 ********************************************************************************/

PROCEDURE valor-operacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                                 NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                                 NO-UNDO.
    DEF  INPUT PARAM par_tpctrato AS INTE                                 NO-UNDO.
    DEF  INPUT PARAM par_nrctrato AS INTE                                 NO-UNDO.

    DEF OUTPUT PARAM par_vloperac AS DECI                                 NO-UNDO.


    IF   par_tpctrato = 90   THEN
         DO:
             FIND crawepr WHERE crawepr.cdcooper = par_cdcooper   AND
                                crawepr.nrdconta = par_nrdconta   AND
                                crawepr.nrctremp = par_nrctrato
                                NO-LOCK NO-ERROR.

             IF   AVAIL crawepr   THEN
                  ASSIGN par_vloperac = crawepr.vlemprst.
             ELSE DO:
                  FIND crapprp WHERE crapprp.cdcooper = par_cdcooper   AND
                                     crapprp.nrdconta = par_nrdconta   AND
                                     crapprp.tpctrato = par_tpctrato   AND
                                     crapprp.nrctrato = par_nrctrato
                             NO-LOCK NO-ERROR.
                  IF  AVAIL crapprp THEN
                      ASSIGN par_vloperac = crapprp.vlctrbnd.  
                  ELSE
                      RETURN "NOK".
             END.
         END.
    ELSE
         DO:     
             IF   par_tpctrato = 3   THEN
                  DO:
                      FIND crawlim WHERE crawlim.cdcooper = par_cdcooper   AND
                                         crawlim.nrdconta = par_nrdconta   AND
                                         crawlim.tpctrlim = par_tpctrato   AND
                                         crawlim.nrctrlim = par_nrctrato 
                                NO-LOCK NO-ERROR.
                                        
                      IF   NOT AVAILABLE crawlim   THEN
                           DO:
                               FIND craplim WHERE craplim.cdcooper = par_cdcooper   AND
                                                  craplim.nrdconta = par_nrdconta   AND
                                                  craplim.tpctrlim = par_tpctrato   AND
                                                  craplim.nrctrlim = par_nrctrato   
                                                  NO-LOCK NO-ERROR.
                                                 
				               IF   AVAIL craplim   THEN
				                    ASSIGN par_vloperac = craplim.vllimite.
				               ELSE 
				                    RETURN  "NOK".
                           END.
                      ELSE
                           ASSIGN par_vloperac = crawlim.vllimite.
                  END.
             ELSE
                  DO:
                      FIND craplim WHERE craplim.cdcooper = par_cdcooper   AND
                                         craplim.nrdconta = par_nrdconta   AND
                                         craplim.tpctrlim = par_tpctrato   AND
                                         craplim.nrctrlim = par_nrctrato
                                         NO-LOCK NO-ERROR.
                                                 
                      IF   AVAIL craplim   THEN
                           ASSIGN par_vloperac = craplim.vllimite.
                      ELSE 
                           RETURN  "NOK".
                  END.
         END.
   
    RETURN "OK".

END PROCEDURE.


/******************************************************************************
 Procedure para a descricao da qualificacao da Operacao.
******************************************************************************/

PROCEDURE qualificacao-operacao:

    DEF  INPUT PARAM par_cdcooper AS INTE                                NO-UNDO.
    DEF  INPUT PARAM par_idquapro AS INTE                                NO-UNDO.
    DEF OUTPUT PARAM par_dsquapro AS CHAR                                NO-UNDO.
    
    /* Descricao da operacao */        
    CASE par_idquapro:

       WHEN 1   THEN   ASSIGN   par_dsquapro = "Operacao normal". 
       WHEN 2   THEN   ASSIGN   par_dsquapro = "Renovacao de credito". 
       WHEN 3   THEN   ASSIGN   par_dsquapro = "Renegociacao de credito". 
       WHEN 4   THEN   ASSIGN   par_dsquapro = "Composicao da divida".
       WHEN 5   THEN   ASSIGN   par_dsquapro = "Cessao de Cartao".

    END CASE.

    RETURN "OK".

END PROCEDURE.


/****************************************************************
 Trazer os emprestimos que estao sendo liquidados em lista.
*****************************************************************/

PROCEDURE traz_liquidacoes:

    DEF INPUT  PARAM par_nrctrliq AS INTE EXTENT 10                      NO-UNDO.
    DEF OUTPUT PARAM par_dsliquid AS CHAR                                NO-UNDO.

    DEF VAR          aux_contador AS INTE                                NO-UNDO.


    /* Criar a lista com os contratos a liquidar */
    DO aux_contador = 1 TO EXTENT (par_nrctrliq):

        IF   par_nrctrliq[aux_contador] = 0  THEN
             NEXT.

        ASSIGN par_dsliquid = IF   par_dsliquid = ""  THEN
                                   STRING(par_nrctrliq[aux_contador])
                              ELSE
                                   par_dsliquid + "," +
                                   STRING(par_nrctrliq[aux_contador]).

    END.

    RETURN "OK".

END PROCEDURE.


/*...........................................................................*/

PROCEDURE itens_topicos_rating:
    DEF INPUT  PARAM par_cdcooper  AS INT                           NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-itens-topico-rating.
    DEF OUTPUT PARAM TABLE FOR tt-erro.
   

    /* Sequencia dos itens e topicos do rating */
    FOR EACH craprad WHERE craprad.cdcooper = par_cdcooper NO-LOCK:

        CREATE tt-itens-topico-rating.
        ASSIGN tt-itens-topico-rating.nrseqite = craprad.nrseqite
               tt-itens-topico-rating.dsseqite = craprad.dsseqite
               tt-itens-topico-rating.nrtopico = craprad.nrtopico
               tt-itens-topico-rating.nritetop = craprad.nritetop.

    END.

    FIND FIRST tt-itens-topico-rating NO-LOCK NO-ERROR.
    IF  NOT AVAIL tt-itens-topico-rating THEN DO:
        ASSIGN aux_cdcritic = 9
               aux_dscritic = "".
        
        RUN gera_erro (INPUT par_cdcooper,
                       INPUT 1,
                       INPUT 1,
                       INPUT 1,            /** Sequencia **/
                       INPUT aux_cdcritic,
                       INPUT-OUTPUT aux_dscritic).
        RETURN "NOK".
    END.

    RETURN "OK".

END PROCEDURE.
