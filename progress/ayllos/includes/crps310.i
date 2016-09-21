/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | includes/crps310.i              | pc_crps310_i                      |
  +---------------------------------+-----------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO)

*******************************************************************************/



/* ............................................................................


   Programa: Includes/crps310.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Margarete
   Data    : Maio/2001                       Ultima atualizacao: 03/11/2014

   Dados referentes ao programa:

   Objetivo  : Gerar arquivo com saldo devedor dos emprestimos - Risco.
                                      
   Alteracoes: 06/10/2008 - Adaptacao para Desconto de Titulos (David).
   
               20/10/2008 - Incluir prejuizo de +48M ate 60M (Magui).

               27/10/2008 - Novo comunicado controlando preju +48M (Magui).
               
               26/01/2009 - Atualizar valores de saldo devedor de emprestimo e
                            quantidade de parcelas pagas quando rodar na 
                            semanal (Diego).

               16/02/2009 - Atualizacao risco crapass(somente mensal)(Mirtes)  
                          
               10/03/2009 - Considerar titulos que vencem na data atual tambem
                            para risco de desconto de titulos(Guilherme).
                            
               15/04/2009 - Nao considerar titulos que foram pagos pela COMPE na
                            data atual no RISCO pois somente serao lancados na
                            contabilidade com D+1(Guilherme/Evandro).
                            
               21/05/2009 - Considerar em risco titulos que vencem em 
                            glb_dtmvtolt (Guilherme);
                            Alimentar as variaveis de contrato e data de inicio
                            para o desconto de titulos (Evandro).

               24/06/2009 - Considerar o vlrestit do mes de titulos que foram 
                            pagos antecipados para risco de desconto de 
                            titulos(Guilherme).

               31/07/2009 - Quando aux_vldivida > 0 e crapsld.dtrisclq <> ?, 
                            atribuir ao crapris.qtdiaatr 21 - dias de atraso
                            (Fernando).

               20/08/2009 - Atribuir a matricula no contrato ao inves da c/c
                            em modalidado 0299 e origem = 1 (Evandro).

               09/09/2009 - Nao considerar a data de vencimento nos titulos em
                            aberto porque a liquidacao esta rodando antes no
                            processo batch (Evandro).
                            
               03/12/2009 - Retirar campos da crapass relacionados ao
                            rating/risco, passados para a crapnrc (Gabriel).
                            
               10/06/2010 - Tratamento para pagamento feito atraves de TAA 
                            "crapcob.indpagto = 4" (Elton).
                            
               19/08/2010 - Verifica a data em que o cooperado entrou no risco,
                            crapris.dtdrisco (Elton).
                            
               23/08/2010 - Feito tratamento de Emprestimos (0299),
                            Financiamento (0499) (Adriano).        
                            
               06/09/2010 - Novo modo de calculo do crapris.vldiv (Guilherme).
               
               05/10/2010 - Atualiza campo crapris.dtdrisco na procedure 
                            efetua_arrasto (Elton).
                                                  
               09/11/2010 - Alterado campo qtdade parcela para dec(Mirtes) 

               02/02/2011 - Voltado qtdade(aux_qtprecal_retorno)
                            parcela para inte. Impacto na
                            provisao das coopes e muito grande. (Magui).
           
               23/03/2011 - Modalide 0201 sempre risco Rating(Dentro do limite
                            contratado). Apenas sera considerado em CL   
                            utilizacao superior ao contratado - risco H
                            Tarefa 38937(Mirtes)
               
               11/11/2011 - Ajuste na procedure calcula_codigo_vencimento, 
                            tratar exceção: emprestimos com valor total 
                            das parcelas menor que valor do emprestimo 
                            contratado (Irlan).
                            
               05/03/2012 - Correção para nao considerar os contratos em 
                            prejuízo no calculo dos vencimentos. Calculo
                            já é feito em outra parte do código.(Irlan)
                            
               03/04/2012 - Atualiza a data do risco sem considerar o valor do 
                            arrasto (Elton).
                            
               04/04/2012 - Alimentar o campo crapris.qtdriclq quando 
                            modalidade for 0101 Adiant.Depos. (Irlan)
                            
               19/04/2012 - Utilizar glb_dtmvtolt ao inves de usar aux_dtrefere
                            na leitura dos cheques descontados. (Rafael)
                            
               30/05/2012 - Alimentar campo crapris.vljura60 (Gabriel). 
               
               18/06/2012 - Quando conta for lancada pra prejuizo (innivris = 10)
                            nao alterar data do risco (Elton).
                            
               21/08/2012 - Tratar emprestimo pre-fixados (Gabriel).             
               
               10/10/2012 - Criar novo crapris.cdorigem = 5 referente ao 
                            desc. títulos - cob. registrada (Rafael).
                            
               05/12/2012 - Ajuste na gravação dos juros para que nao
                            ultrapasse o valor da divida (Tiago).     
                            
               20/12/2012 - Onde eh realizado a gravacao/atualizacao do campo 
                            crapris.innivris sera tambem feito para o campo
                            crapris.inindris - Projeto GE (Adriano).
                            
               21/01/2013 - Incluida procedure cria_saida_operacao. (Tiago)
               
               22/01/2013 - Incluir novo parametro cdorigem na procedure
                            verifica_motivo_saida (Lucas R.).
                            
               06/02/2013 - Ajustado processo cria_saida_operacao, incluso tratamento
                            para situacoes onde modalidade e alterada de 0299 para 0499
                            e de 0499 para 0299. (Daniel).
                            
               27/02/2013 - Ajuste no campo de valores de vencimentos (Gabriel).             
                                    
               04/04/2013 - Ajuste de parametros na funcao que calcula a qtde 
                            de dias de atraso (Gabriel).         
                            
               10/04/2013 - Retirar codigo repetido (Gabriel).                                                   
               
               12/04/2013 - Ajuste na rotina cria_saida_operacao para incrementar
                            o campo nrseqctr a partir da consulta feita na
                            temp-table tt-crapris e nao na crapris, nos registros
                            com indocto = 2.
                            
               15/05/2013 - Incluido ordenacao na consulta dos borderos de
                            desconto de cheque para igualar resultado no Oracle.
                            (Irlan)
                            
               24/05/2013 - Ajuste na gravacao do vljura60 (Gabriel).
               
               04/06/2013 - Incluída a ordenação por nrdconta e nrctremp na
                            PROCEDURE cria_saida_operacao (Carlos).
               
               10/06/2013 - Leitura das operacoes de emprestimos com o
                            BNDES (crapebn). (Fabricio)
                            
               07/08/2013 - Para emprestimos com o BNDES, alimentado variavel
                            'aux_nivel' de acordo com a presenca de valores
                            nos campos de creditos em prejuizo ou vencidos.
                            (Fabricio)
                            
               27/08/2013 - Alteração na gravação do valor da divida para 
                            emprestimos pre-fixados.
                            (ris.vldivida e vri.vldivida) (Irlan).
                            
               03/09/2013 - Alterar ordenacao de listagem da crapris para 
                            garantir igualdade com o Oracle (Gabriel).              
                            
               13/09/2013 - Nao considerar titulos descontados 085 pagos 
                            via compe no calculo do risco (Rafael).
                            
               10/09/2013 - Alteracoes:
                            - Retirado a chamada, a procedure e variaveis 
                              usadas referente a procedure cria_saida_operacao
                              para que a mesma, seja tratada no fonte crps660.p
                            - Retirado a procedure verifica_motivo_saida para
                              ser tratada no fonte crps660.p   
                            (Adriano).
                            
               01/11/2013 - Inicializada variavel aux_dias em lista_tipo_1.
                            (Irlan)    
                            
               12/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)
                            
               03/02/2014 - Remover a chamada da procedure "saldo_epr.p".
                            (James)
                            
               03/11/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
............................................................................. */

{ sistema/generico/includes/var_internet.i  }
{ sistema/generico/includes/b1wgen0084att.i }

DEF   VAR rel_nmempres       AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF   VAR rel_nmrelato       AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF   VAR rel_nrmodulo       AS INT     FORMAT "9"                    NO-UNDO.
DEF   VAR rel_nmmodulo       AS CHAR    FORMAT "x(15)" EXTENT 5
                                        INIT ["DEP. A VISTA   ",
                                              "CAPITAL        ",
                                              "EMPRESTIMOS    ",
                                              "DIGITACAO      ",
                                              "GENERICO       "]      NO-UNDO.

DEF   VAR aux_vlsdeved       AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF   VAR aux_vlsdeved_atual AS DECIMAL FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF   VAR aux_nivel          AS INTE    LABEL "Nivel"                 NO-UNDO.
DEF   VAR aux_nivel_atraso   AS INTE    LABEL "Nivel"                 NO-UNDO.
DEF   VAR aux_dias           AS INTE    LABEL "Dias"                  NO-UNDO.
DEF   VAR aux_meses          AS INT                                   NO-UNDO.
DEF   VAR aux_vlvencer180    AS DECIMAL                               NO-UNDO.
DEF   VAR aux_vlvencer360    AS DECIMAL                               NO-UNDO.
DEF   VAR aux_vlcalcul       AS DECIMAL                               NO-UNDO.
DEF   VAR aux_vlatraso       AS DECIMAL                               NO-UNDO.
DEF   VAR aux_vlvencer       AS DECIMAL                               NO-UNDO.
DEF   VAR aux_vlpresta       AS DECIMAL                               NO-UNDO.
DEF   VAR aux_vlsddisp       AS DECIMAL                               NO-UNDO.
DEF   VAR aux_vlutiliz       AS DECIMAL                               NO-UNDO.
DEF   VAR aux_dtrefere       AS DATE                                  NO-UNDO.
DEF   VAR aux_qtdiaatr       AS INTEGER FORMAT "-99999999"            NO-UNDO.
DEF   VAR aux_vlrpagos       LIKE crapepr.vlprejuz                    NO-UNDO.

DEF   VAR aux_novo_vencto    LIKE crapvri.cdvencto                    NO-UNDO.
DEF   VAR aux_qtddsdev       AS INT                                   NO-UNDO.
DEF   VAR aux_qtdrisco       AS INT                                   NO-UNDO.

DEF STREAM str_1. /* Para relatorio crrl349 */

DEF   VAR aux_nmarqimp       AS CHAR    INIT "rl/crrl349.lst"         NO-UNDO.
DEF   VAR aux_dtinicio       AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF   VAR aux_dtfinal        AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF   VAR aux_indocc         AS INTEGER                               NO-UNDO.
DEF   VAR aux_indmes         AS INTEGER                               NO-UNDO.
DEF   VAR aux_indano         AS INTEGER                               NO-UNDO.

DEF   VAR aux_qtdprazo       AS INT                                   NO-UNDO.
DEF   VAR aux_contador       AS INT                                   NO-UNDO.
DEF   VAR aux_vldrisco       AS DECIMAL                               NO-UNDO.
  
DEF   VAR aux_vldeschq       AS DECIMAL                               NO-UNDO.
DEF   VAR aux_vldes180       AS DECIMAL                               NO-UNDO.
DEF   VAR aux_vldes360       AS DECIMAL                               NO-UNDO.
DEF   VAR aux_vldes999       AS DECIMAL                               NO-UNDO.

DEF   VAR aux_vldestit       AS DECIMAL                               NO-UNDO.
DEF   VAR aux_vltit180       AS DECIMAL                               NO-UNDO.
DEF   VAR aux_vltit360       AS DECIMAL                               NO-UNDO.
DEF   VAR aux_vltit999       AS DECIMAL                               NO-UNDO.
                                    
DEF   VAR aux_dtfimvig       AS DATE                                  NO-UNDO.
DEF   VAR aux_nrctrlim       AS INTE    FORMAT "zzzzzzz9"             NO-UNDO.
DEF   VAR aux_vllimcre       AS DEC                                   NO-UNDO.
DEF   VAR aux_vlbloque       AS DEC                                   NO-UNDO.
DEF   VAR aux_vldivida       AS DEC                                   NO-UNDO.
DEF   VAR aux_vlsrisco       AS DEC                                   NO-UNDO.
DEF   VAR aux_diaavenc       AS INT     FORMAT "9999" EXTENT 11       NO-UNDO.
DEF   VAR aux_vlavence       AS DEC     EXTENT 11                     NO-UNDO.

DEF   VAR aux_diavenci       AS INT     FORMAT "9999" EXTENT 12       NO-UNDO.
DEF   VAR aux_vlvencid       AS DEC     EXTENT 12                     NO-UNDO.


DEF   VAR aux_vlvenc180      AS DEC                                   NO-UNDO.
DEF   VAR aux_vlvenc360      AS DEC                                   NO-UNDO.
DEF   VAR aux_vlvenc999      AS DEC                                   NO-UNDO.
                                        
DEF   VAR aux_vldivi060      AS DEC                                   NO-UNDO.
DEF   VAR aux_vldivi180      AS DEC                                   NO-UNDO.
DEF   VAR aux_vldivi360      AS DEC                                   NO-UNDO.
DEF   VAR aux_vldivi999      AS DEC                                   NO-UNDO.
                        
DEF   VAR aux_vlprjano       AS DEC                                   NO-UNDO.
DEF   VAR aux_vlprjaan       AS DEC                                   NO-UNDO.
DEF   VAR aux_vlprjant       AS DEC                                   NO-UNDO.

DEF   VAR aux_diasvenc       AS INTE                                  NO-UNDO.
DEF   VAR aux_cdvencto       AS INTE                                  NO-UNDO. 
DEF   VAR aux_nrseqctr       AS INTE                                  NO-UNDO.
DEF   VAR aux_dtinictr       AS DATE                                  NO-UNDO.
DEF   VAR aux_dtfimmes       AS DATE                                  NO-UNDO.

DEF   VAR aux_rsvec180       AS DEC     FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF   VAR aux_rsvec360       AS DEC     FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF   VAR aux_rsvec999       AS DEC     FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF   VAR aux_rsdiv060       AS DEC     FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF   VAR aux_rsdiv180       AS DEC     FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF   VAR aux_rsdiv360       AS DEC     FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF   VAR aux_rsdiv999       AS DEC     FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF   VAR aux_rsprjano       AS DEC     FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF   VAR aux_rsprjaan       AS DEC     FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.
DEF   VAR aux_rsprjant       AS DEC     FORMAT "zzz,zzz,zz9.99-"      NO-UNDO.

DEF   VAR aux_innivris       LIKE crapris.innivris                    NO-UNDO.
DEF   VAR aux_qtmesdec       AS INTE                                  NO-UNDO.

DEF   VAR aux_valor_auxiliar AS DEC                                   NO-UNDO.
DEF   VAR aux_risco_rating   AS INTE    FORMAT "99"                   NO-UNDO.
DEF   VAR aux_risco_char     AS CHAR    FORMAT "x(02)"                NO-UNDO.
DEF   VAR aux_risco_num      AS INTE    FORMAT "99"                   NO-UNDO.
DEF   VAR aux_qtdiapre       AS INTE                                  NO-UNDO.
DEF   VAR aux_tpoperac       AS CHAR                                  NO-UNDO.

DEF   VAR aux_dadosusr AS CHAR                                        NO-UNDO.
DEF   VAR par_loginusr AS CHAR                                        NO-UNDO.
DEF   VAR par_nmusuari AS CHAR                                        NO-UNDO.
DEF   VAR par_dsdevice AS CHAR                                        NO-UNDO.
DEF   VAR par_dtconnec AS CHAR                                        NO-UNDO.
DEF   VAR par_numipusr AS CHAR                                        NO-UNDO.
DEF   VAR h-b1wgen9999 AS HANDLE                                      NO-UNDO.

/*** Mirtes e esse campo que deve ser alterado para dec, lembrar de
     compilar os programas crps310.p e crps515.p ***/
DEF   VAR aux_qtprecal_retorno AS INTE                                NO-UNDO. 
/*****************************************************/

DEF   VAR aux_vldivida_acum  AS DECI                                  NO-UNDO. 
DEF   VAR aux_totjur60       AS DECI                                  NO-UNDO. 

DEF   VAR h-b1wgen0084a      AS HANDLE                                NO-UNDO.


DEF  BUFFER crabris   FOR crapris.
DEF  BUFFER crabass   FOR crapass.
DEF  BUFFER b-crapvri FOR crapvri.
DEF  BUFFER b-crapris FOR crapris.

DEF TEMP-TABLE tt-vencto                                              NO-UNDO
    FIELD cdvencto LIKE crapvri.cdvencto
    FIELD dias     AS INTE.

FORM  crapris.nrdconta  LABEL "Conta"
      crapris.cdmodali  LABEL "Mod."
      crapris.nrctremp  LABEL "Contrato"
      crapris.innivori  LABEL "Risco Ant."
      crapris.innivris  LABEL "Risco Atual"
      crapvri.cdvencto  LABEL "Vencto Ant"
      aux_novo_vencto   LABEL "Vencto Atual"
      crapvri.vldivida  LABEL "Valor"
      WITH NO-BOX NO-LABEL DOWN WIDTH 132 FRAME f_preju_risco.

ASSIGN aux_diaavenc[1]  =  30
       aux_diaavenc[2]  =  60
       aux_diaavenc[3]  =  90
       aux_diaavenc[4]  =  180
       aux_diaavenc[5]  =  360
       aux_diaavenc[6]  =  720
       aux_diaavenc[7]  =  1080
       aux_diaavenc[8]  =  1440
       aux_diaavenc[9]  =  1800
       aux_diaavenc[10] =  5400
       aux_diaavenc[11] =  9999.

ASSIGN aux_diavenci[1]  =  14
       aux_diavenci[2]  =  30
       aux_diavenci[3]  =  60
       aux_diavenci[4]  =  90
       aux_diavenci[5]  =  120
       aux_diavenci[6]  =  150
       aux_diavenci[7]  =  180
       aux_diavenci[8]  =  240
       aux_diavenci[9]  =  300
       aux_diavenci[10] =  360 
       aux_diavenci[11] =  540
       aux_diavenci[12] =  9999.


/* Busca dados da cooperativa */

FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

IF   NOT AVAILABLE crapcop THEN
     DO:
         glb_cdcritic = 651.
         RUN fontes/critic.p.
         MESSAGE glb_dscritic.
         RETURN.
     END.


FIND craptab WHERE craptab.cdcooper = glb_cdcooper  AND
                   craptab.nmsistem = "CRED"        AND
                   craptab.tptabela = "USUARI"      AND
                   craptab.cdempres = 0             AND
                   craptab.cdacesso = "DIASCREDLQ"  AND
                   craptab.tpregist = 0             NO-LOCK NO-ERROR.

IF   NOT AVAILABLE craptab   THEN
     DO:
         glb_cdcritic = 210.
         RUN fontes/critic.p.
         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + " - " +
                           glb_cdprogra + "' --> '" + glb_dscritic  +
                           " >> log/proc_batch.log").
         RETURN.
     END.
ELSE
     ASSIGN aux_qtddsdev = INT(SUBSTR(craptab.dstextab,1,3))
            aux_qtdrisco = INT(SUBSTR(craptab.dstextab,5,3)).


ASSIGN aux_dtfimmes = ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4) -
                        DAY(DATE(MONTH(glb_dtmvtolt),28, 
                        YEAR(glb_dtmvtolt)) + 4)).

IF   glb_cdprogra = "crps310"  THEN
     ASSIGN aux_dtrefere = 
                ((DATE(MONTH(glb_dtmvtolt),28,YEAR(glb_dtmvtolt)) + 4) -
                       DAY(DATE(MONTH(glb_dtmvtolt),28,
                           YEAR(glb_dtmvtolt)) + 4)).  
ELSE  
     ASSIGN aux_dtrefere = glb_dtmvtolt.  /* Semanal */    

/*  Rosangela  teste GE 
     aux_dtrefere = 12/31/2012. */   
     
RUN sistema/generico/procedures/b1wgen0084a.p PERSISTENT SET h-b1wgen0084a.

TRANS_1:                                   
FOR EACH crapass WHERE crapass.cdcooper = glb_cdcooper  AND
                       crapass.nrdconta > glb_nrctares NO-LOCK,
    FIRST crapsld NO-LOCK WHERE                   
          crapsld.cdcooper = crapass.cdcooper AND
          crapsld.nrdconta = crapass.nrdconta             
                       TRANSACTION ON ERROR UNDO TRANS_1, RETURN:

    /* Rating efetivo */
    FIND crapnrc WHERE crapnrc.cdcooper = glb_cdcooper      AND
                       crapnrc.nrdconta = crapass.nrdconta  AND
                       crapnrc.insitrat = 2  
                       NO-LOCK NO-ERROR.
                            
    ASSIGN aux_risco_rating = 2.

    IF  AVAILABLE crapnrc   THEN 
        DO:
            IF   crapnrc.indrisco <> ""   THEN
                 DO:
                     ASSIGN aux_risco_char = crapnrc.indrisco.

                     RUN converte_risco_alfa.
                 
                     ASSIGN aux_risco_rating = aux_risco_num.
                 END.       
        END.
        
    /* Calcula divida de conta corrente */
     
    aux_vlutiliz = 0.
      
    ASSIGN aux_nrseqctr = 0.       
    
    /*---------------Risco   Conta Corrente ------------------------*/
    aux_vlsddisp = crapsld.vlsddisp + crapsld.vlsdchsl.

    /*--  Gerar Informacoes Docto 3020 */
    IF  aux_vlsddisp < 0  THEN
        DO:                  
          ASSIGN aux_dtfimvig = glb_dtmvtolt
                 aux_nrctrlim = crapass.nrdconta
                 aux_vllimcre = 0
                 aux_vlbloque = crapsld.vlsdbloq + crapsld.vlsdblpr +
                                crapsld.vlsdblfp
                 aux_vlsrisco = 0
                 aux_vldivida = 0 
                 aux_dtinictr = crapass.dtadmiss. /*glb_dtmvtolt.*/
          
          IF   crapass.vllimcre <> 0   THEN    
               DO:
                  ASSIGN aux_vllimcre = crapass.vllimcre.
                  FIND LAST craplim WHERE 
                            craplim.cdcooper = glb_cdcooper         AND
                            craplim.nrdconta = crapsld.nrdconta     AND
                            craplim.tpctrlim = 1                    AND
                            craplim.insitlim = 2 
                            USE-INDEX craplim2 NO-LOCK NO-ERROR.
                            
                  IF  AVAILABLE craplim   THEN
                      DO:
                          FIND craplrt WHERE 
                                       craplrt.cdcooper = glb_cdcooper      AND
                                       craplrt.cddlinha = craplim.cddlinha  
                                       NO-LOCK NO-ERROR.
                       
                          IF   NOT AVAILABLE craplrt THEN
                               DO:
                                   glb_cdcritic = 363.
                                   RUN fontes/critic.p.
                                   UNIX SILENT VALUE("echo " +
                                             STRING(TIME,"HH:MM:SS") + " - " +
                                             glb_cdprogra + "' --> '" +
                                             glb_dscritic + " CONTA = " +
                                             STRING(crapsld.nrdconta) +
                                             " >> log/proc_batch.log").
                                   DELETE PROCEDURE h-b1wgen0084a.
                                   UNDO TRANS_1, RETURN.
                               END.
                          ELSE
                               DO:
                                   ASSIGN aux_dtfimvig = craplim.dtinivig
                                          aux_nrctrlim = craplim.nrctrlim 
                                          aux_dtinictr = craplim.dtinivig.
                          
                                   DO WHILE aux_dtfimvig < glb_dtmvtolt:
                                      ASSIGN aux_dtfimvig = aux_dtfimvig + 
                                                            craplrt.qtdiavig.
                                   END.
                               END.    
                      END.                  
               END.

           ASSIGN aux_vldivida = aux_vlsddisp * -1.

           IF  aux_vldivida > 0 AND
               aux_vllimcre > 0 THEN
               DO:

                  IF  aux_vldivida < aux_vllimcre THEN
                      ASSIGN aux_vlsrisco = aux_vldivida
                             aux_vldivida = 0.
                  ELSE           
                      ASSIGN aux_vlsrisco = aux_vllimcre
                             aux_vldivida = aux_vldivida - aux_vllimcre.
                        
                  CREATE crapris.
                  ASSIGN crapris.nrdconta = crapass.nrdconta
                         crapris.dtrefere = aux_dtrefere
                         crapris.innivris = aux_risco_rating
                         crapris.inindris = aux_risco_rating
                         crapris.nrcpfcgc = crapass.nrcpfcgc
                         crapris.inpessoa = crapass.inpessoa
                         crapris.vldivida = aux_vlsrisco
                         crapris.inddocto = 1     /* Docto 3020 */
                         crapris.cdmodali = 0201 /* Cheque Especial */
                         crapris.nrctremp = aux_nrctrlim 
                         crapris.dtinictr = aux_dtinictr
                         crapris.cdorigem = 1   /* Conta */
                         crapris.cdagenci = crapass.cdagenci 
                         crapris.cdcooper = glb_cdcooper.
                  
                  ASSIGN aux_diasvenc = aux_dtfimvig - glb_dtmvtolt.            
                  
                  ASSIGN aux_nrseqctr     = aux_nrseqctr + 1 
                         crapris.nrseqctr = aux_nrseqctr.

                  VALIDATE crapris.

                  RUN calcula_codigo_vencimento.
                      
                  RUN grava_crapvri.

                  RUN grava_crapris_3010.     /* Docto 3010 */  
               END. 
                
           IF  aux_vldivida > 0  AND
               aux_vlbloque > 0 THEN 
               DO:
                   IF  aux_vldivida < aux_vlbloque THEN
                       ASSIGN aux_vlsrisco = aux_vldivida
                              aux_vldivida = 0.
                   ELSE           
                       ASSIGN aux_vlsrisco = aux_vlbloque
                              aux_vldivida = aux_vldivida - aux_vlbloque.
                         
                   CREATE crapris.
                   ASSIGN crapris.nrdconta = crapass.nrdconta
                          crapris.dtrefere = aux_dtrefere
                          crapris.innivris = IF crapsld.dtrisclq <> ? THEN
                                                9
                                             ELSE 
                                                aux_risco_rating /* 2 */
                          crapris.inindris = IF crapsld.dtrisclq <> ? THEN
                                                9
                                             ELSE 
                                                aux_risco_rating /* 2 */
                          crapris.nrcpfcgc = crapass.nrcpfcgc
                          crapris.inpessoa = crapass.inpessoa
                          crapris.vldivida = aux_vlsrisco
                          crapris.inddocto = 1     /* Docto 3020 */
                          crapris.cdmodali = 0299 /* Outros Emprestimos */
                          crapris.nrctremp = crapass.nrmatric /*aux_nrctrlim*/
                          crapris.dtinictr = crapass.dtadmiss /*aux_dtinictr*/
                          crapris.cdorigem = 1  /* Conta */
                          crapris.cdagenci = crapass.cdagenci 
                          crapris.cdcooper = glb_cdcooper.
                   /*-- Bloqueados assumir 15 dias a vencer ---*/
                   ASSIGN aux_dtfimvig = glb_dtmvtolt + 15. 
                  
                   ASSIGN aux_diasvenc = (aux_dtfimvig - glb_dtmvtolt).

                   ASSIGN aux_nrseqctr     = aux_nrseqctr + 1 
                          crapris.nrseqctr = aux_nrseqctr.
                   VALIDATE crapris.

                   RUN calcula_codigo_vencimento.
                       
                   RUN grava_crapvri.
                      
                   RUN grava_crapris_3010.   /* Docto 3010 */   
               END.
                
           IF  aux_vldivida > 0 THEN
               DO:
                  ASSIGN aux_vlsrisco = aux_vldivida.
                        
                  CREATE crapris.
                  ASSIGN crapris.nrdconta = crapass.nrdconta
                         crapris.dtrefere = aux_dtrefere
                         crapris.innivris = IF crapsld.dtrisclq <> ? THEN
                                               9
                                            ELSE
                                               aux_risco_rating /* 2 */
                         crapris.inindris = IF crapsld.dtrisclq <> ? THEN 
                                               9
                                            ELSE
                                               aux_risco_rating /* 2 */
                         crapris.nrcpfcgc = crapass.nrcpfcgc
                         crapris.inpessoa = crapass.inpessoa
                         crapris.qtdiaatr = IF crapsld.dtrisclq <> ? THEN 
                                               21 
                                            ELSE 0
                         crapris.vldivida = aux_vlsrisco
                         crapris.inddocto = 1     /* Docto 3020 */
                         crapris.cdmodali = 0101  /* Adiant.Depositante */
                         crapris.nrctremp = crapass.nrdconta /*aux_nrctrlim*/ 
                         crapris.dtinictr = crapass.dtadmiss /*aux_dtinictr*/ 
                         crapris.cdorigem = 1  /* Conta */
                         crapris.cdagenci = crapass.cdagenci 
                         crapris.cdcooper = glb_cdcooper.
                   /*--   Vencidos               ---*/
                   IF  crapsld.dtrisclq <> ? THEN
                       ASSIGN aux_dtfimvig = crapsld.dtrisclq - 
                                             aux_qtdrisco. 
                   ELSE
                       ASSIGN aux_dtfimvig = glb_dtmvtolt.

                   ASSIGN aux_diasvenc = (aux_dtfimvig - glb_dtmvtolt) - 1
                          crapris.qtdriclq = ABSOLUTE(aux_diasvenc). 

                   ASSIGN aux_nrseqctr     = aux_nrseqctr + 1
                          crapris.nrseqctr = aux_nrseqctr.

                   VALIDATE crapris. 

                   RUN calcula_codigo_vencimento.
                       
                   RUN grava_crapvri.

                   RUN grava_crapris_3010. /* Docto 3010 */   
                   
               END. 
    
    END.
    
    ASSIGN aux_vlsdeved = 0
           aux_tpoperac = "EMPREST".

    FOR EACH crapepr WHERE crapepr.cdcooper = glb_cdcooper      AND  
                           crapepr.nrdconta = crapass.nrdconta  AND
                          (crapepr.inliquid = 0 OR   /*Ativo*/
                           crapepr.inprejuz = 1)     /*Prejuizo*/
                           NO-LOCK:

        IF   crapepr.tpemprst = 0  THEN  
             RUN lista_tipo_0.          /* Risco Emprestimos Price */
        ELSE
             RUN lista_tipo_1.          /* Emprestimos Pre fixados */
            
    END.

    ASSIGN aux_tpoperac = "".

    /*------- Risco do desconto de cheques ------------------------ */
    ASSIGN aux_vldeschq = 0
           aux_vldes180 = 0
           aux_vldes360 = 0
           aux_vldes999 = 0.

    ASSIGN aux_contador = 1.
    DO  WHILE aux_contador LE 11:
        ASSIGN aux_vlavence[aux_contador] = 0
               aux_contador               = aux_contador + 1.
    END.    
                                         
    FOR EACH crapbdc WHERE 
             crapbdc.cdcooper  = glb_cdcooper       AND
             crapbdc.nrdconta  = crapass.nrdconta   AND
             crapbdc.insitbdc  = 3                  AND /*  Liberado  */
             crapbdc.dtlibbdc <= aux_dtrefere       NO-LOCK
          by crapbdc.cdcooper
          by crapbdc.nrdconta
          by crapbdc.dtmvtolt:
   
        /*  Calculo do juros sobre o desconto do cheque ..................... */
                              
        ASSIGN aux_nrctrlim = crapbdc.nrctrlim 
               aux_dtinictr = crapbdc.dtlibbdc

               aux_vldrisco = 0
               aux_cdvencto = 0.         
        
        FOR EACH crapcdb WHERE crapcdb.cdcooper = glb_cdcooper      AND
                               crapcdb.nrborder = crapbdc.nrborder  AND
                               crapcdb.dtlibera > glb_dtmvtolt
                               USE-INDEX crapcdb7 NO-LOCK:
             
            IF   crapcdb.dtdevolu <> ?   THEN
                 IF   crapcdb.dtdevolu <= aux_dtrefere   THEN
                      NEXT.
                                          
            ASSIGN aux_vldrisco = crapcdb.vlliquid
                   aux_qtdprazo = crapcdb.dtlibera - crapcdb.dtlibbdc.

            FOR EACH crapljd WHERE crapljd.cdcooper = glb_cdcooper          AND
                                   crapljd.nrdconta = crapcdb.nrdconta      AND
                                   crapljd.nrborder = crapcdb.nrborder      AND
                                   crapljd.dtmvtolt = crapcdb.dtlibbdc      AND
                                   crapljd.dtrefere < (aux_dtfimmes + 1)    AND
                                   crapljd.cdcmpchq = crapcdb.cdcmpchq      AND
                                   crapljd.cdbanchq = crapcdb.cdbanchq      AND
                                   crapljd.cdagechq = crapcdb.cdagechq      AND
                                   crapljd.nrctachq = crapcdb.nrctachq      AND
                                   crapljd.nrcheque = crapcdb.nrcheque
                                   NO-LOCK: 
             
                aux_vldrisco = aux_vldrisco + crapljd.vldjuros.

            END.  /*  Fim do FOR EACH crapljd  */
   
            aux_vldeschq = aux_vldeschq + aux_vldrisco.
               
            IF   aux_qtdprazo <= 180   THEN
                 aux_vldes180  = aux_vldes180 + aux_vldrisco.
            ELSE
            IF   aux_qtdprazo <= 360   THEN
                 aux_vldes360  = aux_vldes360 + aux_vldrisco.
            ELSE
                 aux_vldes999  = aux_vldes999 + aux_vldrisco.

            /*--- Verifica codigo vencimento documento 3020 --*/
            
            IF  aux_qtdprazo <= 30 THEN         /* Creditos a Vencer */
                aux_vlavence[1]  = aux_vlavence[1] + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 60 THEN
                aux_vlavence[2]  = aux_vlavence[2] + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 90 THEN
                aux_vlavence[3]  = aux_vlavence[3] + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 180 THEN
                aux_vlavence[4]  = aux_vlavence[4] + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 360 THEN
                aux_vlavence[5]  = aux_vlavence[5] + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 720 THEN
                aux_vlavence[6]  = aux_vlavence[6] + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 1080 THEN
                aux_vlavence[7]  = aux_vlavence[7] + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 1440 THEN
                aux_vlavence[8]  = aux_vlavence[8] + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 1800 THEN
                aux_vlavence[9]  = aux_vlavence[9]  + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 5400 THEN
                aux_vlavence[10] =  aux_vlavence[10] + aux_vldrisco.
            ELSE
                aux_vlavence[11]  = aux_vlavence[11]  + aux_vldrisco.
            /*-----------------*/        
        
        END.  /*  Fim do FOR EACH crapcdb  */

    END.  /*  Fim do FOR EACH  --  Leitura do crapbdc  */
    
    IF   aux_vldeschq > 0   THEN
         DO: 
             CREATE crapris.
             ASSIGN crapris.nrdconta = crapass.nrdconta
                    crapris.dtrefere = aux_dtrefere
                    crapris.innivris = aux_risco_rating /* 2 */ /* Risco A */
                    crapris.inindris = aux_risco_rating /* 2 */ /* Risco A */
                    crapris.qtdiaatr = 0
                    crapris.nrcpfcgc = crapass.nrcpfcgc
                    crapris.inpessoa = crapass.inpessoa
                    crapris.vldivida = aux_vldeschq
                    crapris.vlvec180 = aux_vldes180 
                    crapris.vlvec360 = aux_vldes360
                    crapris.vlvec999 = aux_vldes999
                    crapris.vldiv060 = 0
                    crapris.vldiv180 = 0
                    crapris.vldiv360 = 0
                    crapris.vldiv999 = 0
                    crapris.vlprjano = 0
                    crapris.vlprjaan = 0 
                    crapris.vlprjant = 0
                    crapris.vlprjm60 = 0
                    crapris.cdcooper = glb_cdcooper.
             VALIDATE crapris.
         END.
        
    /*--  Gerar Informacoes Docto 3020 */
    IF  aux_vldeschq > 0  THEN
        DO:
           CREATE crapris.
           ASSIGN crapris.nrdconta = crapass.nrdconta
                  crapris.dtrefere = aux_dtrefere
                  crapris.innivris = aux_risco_rating /* 2*/  /*  Risco A  */
                  crapris.inindris = aux_risco_rating /* 2*/ /* Risco A */
                  crapris.nrcpfcgc = crapass.nrcpfcgc
                  crapris.inpessoa = crapass.inpessoa
                  crapris.vldivida = aux_vldeschq
                  crapris.inddocto = 1     /* Docto 3020 */
                  crapris.cdmodali = 0302  /* Desconto Cheques */
                  crapris.nrctremp = aux_nrctrlim 
                  crapris.dtinictr = aux_dtinictr
                  crapris.cdorigem = 2  /* Desconto Cheques */
                  crapris.cdagenci = crapass.cdagenci 
                  crapris.cdcooper = glb_cdcooper.

           ASSIGN aux_nrseqctr     = aux_nrseqctr + 1
                  crapris.nrseqctr = aux_nrseqctr.
           VALIDATE crapris.

           ASSIGN aux_contador = 1.          
           DO  WHILE aux_contador LE 11:
               IF  aux_vlavence[aux_contador] > 0 THEN
                   DO:
                      ASSIGN aux_vlsrisco = aux_vlavence[aux_contador]
                             aux_diasvenc = aux_diaavenc[aux_contador].
 
                      RUN calcula_codigo_vencimento.
                          
                      RUN grava_crapvri.   
                   END.
                         
               ASSIGN aux_contador = aux_contador + 1.
           END.     
 
        END.
        
    /*------- Risco do desconto de titulos - cob. sem registro ---- */
    ASSIGN aux_vldestit = 0
           aux_vltit180 = 0
           aux_vltit360 = 0
           aux_vltit999 = 0.

    ASSIGN aux_contador = 1.
    DO  WHILE aux_contador LE 11:
        ASSIGN aux_vlavence[aux_contador] = 0
               aux_contador               = aux_contador + 1.
    END.        
             
    /* Esta busca deve obrigatoriamente ser igual ao relatorio 
       494 e 495 que sao gerados pelo fontes/crps518.p 
       os comentarios sobre a busca estao la */
    /* Considerar em risco titulos que vencem em glb_dtmvtolt */    
    FOR EACH crapbdt WHERE 
            (crapbdt.cdcooper  = glb_cdcooper       AND
             crapbdt.nrdconta  = crapass.nrdconta   AND
             crapbdt.insitbdt  = 3                  AND /*  Liberado  */
             crapbdt.dtlibbdt <= aux_dtrefere)
             OR
            (crapbdt.cdcooper  = glb_cdcooper       AND
             crapbdt.nrdconta  = crapass.nrdconta   AND
             crapbdt.insitbdt  = 4) NO-LOCK, /*  Liquidado */
        EACH craptdb WHERE 
            (craptdb.cdcooper = glb_cdcooper     AND
             craptdb.nrdconta = crapbdt.nrdconta AND
             craptdb.nrborder = crapbdt.nrborder AND
             craptdb.insittit = 4)
             OR
            (craptdb.cdcooper = glb_cdcooper     AND
             craptdb.nrdconta = crapbdt.nrdconta AND
             craptdb.nrborder = crapbdt.nrborder AND
             craptdb.insittit = 2                AND
             craptdb.dtdpagto = glb_dtmvtolt) NO-LOCK,
        EACH crapcob WHERE 
             crapcob.cdcooper = glb_cdcooper     AND
             crapcob.cdbandoc = craptdb.cdbandoc AND
             crapcob.nrdctabb = craptdb.nrdctabb AND
             crapcob.nrcnvcob = craptdb.nrcnvcob AND
             crapcob.nrdconta = craptdb.nrdconta AND
             crapcob.nrdocmto = craptdb.nrdocmto AND
             crapcob.flgregis = FALSE NO-LOCK: 

            /*  Calculo do juros sobre o desconto do titulo ............. */

            ASSIGN aux_nrctrlim = crapbdt.nrctrlim
                   aux_dtinictr = crapbdt.dtlibbdt
                                   
                   aux_vldrisco = 0
                   aux_cdvencto = 0.
            
            /*FIND crapcob WHERE crapcob.cdcooper = glb_cdcooper     AND
                               crapcob.cdbandoc = craptdb.cdbandoc AND
                               crapcob.nrdctabb = craptdb.nrdctabb AND
                               crapcob.nrcnvcob = craptdb.nrcnvcob AND
                               crapcob.nrdconta = craptdb.nrdconta AND
                               crapcob.nrdocmto = craptdb.nrdocmto 
                               NO-LOCK NO-ERROR.*/
                               
            IF   NOT AVAILABLE crapcob   THEN
                 DO:
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                       " - " +
                                       glb_cdprogra + "' --> '" + 
                                       "'Titulo em desconto nao encontrado" +
                                       " no " +
                                       "crapcob - ROWID(craptdb) = " +
                                       STRING(ROWID(craptdb)) +
                                       "' >> log/proc_batch.log").
                     NEXT.
                 END.
            
            /* 
                Se foi pago via CAIXA, InternetBank ou TAA
                Nao considera em risco, pois ja esta pago o dinheiro ja entrou
                para a cooperativa 
            */
            IF  craptdb.insittit = 2  AND
               (crapcob.indpagto = 1  OR
                crapcob.indpagto = 3  OR
                crapcob.indpagto = 4  OR  /** TAA **/
                (crapcob.indpagto = 0 AND crapcob.cdbandoc = 085)) THEN

                NEXT.
            
            ASSIGN aux_vldrisco = craptdb.vlliquid
                   aux_qtdprazo = craptdb.dtvencto - craptdb.dtlibbdt.

            /* 
                Se foi pago antecipado ele soma os juros restituidos como risco
                tambem pois o titulo ainda eh considerado em risco  para a 
                contabilidade
            */
            IF  craptdb.insittit = 2            AND
                craptdb.dtdpagto = glb_dtmvtolt AND
                craptdb.dtvencto > glb_dtmvtolt THEN
                FOR EACH crapljt WHERE 
                         crapljt.cdcooper = glb_cdcooper     AND
                         crapljt.nrdconta = craptdb.nrdconta AND
                         crapljt.nrborder = craptdb.nrborder AND
                         crapljt.dtmvtolt = craptdb.dtlibbdt AND
                         crapljt.dtrefere > aux_dtfimmes     AND
                         crapljt.cdbandoc = craptdb.cdbandoc AND
                         crapljt.nrdctabb = craptdb.nrdctabb AND
                         crapljt.nrcnvcob = craptdb.nrcnvcob AND
                         crapljt.nrdocmto = craptdb.nrdocmto
                         NO-LOCK: 
             
                    aux_vldrisco = aux_vldrisco + crapljt.vlrestit.

                END.  /*  Fim do FOR EACH crapljd  */
            
            FOR EACH crapljt WHERE crapljt.cdcooper = glb_cdcooper          AND
                                   crapljt.nrdconta = craptdb.nrdconta      AND
                                   crapljt.nrborder = craptdb.nrborder      AND
                                   crapljt.dtmvtolt = craptdb.dtlibbdt      AND
                                   crapljt.dtrefere < (aux_dtfimmes + 1)    AND
                                   crapljt.cdbandoc = craptdb.cdbandoc      AND
                                   crapljt.nrdctabb = craptdb.nrdctabb      AND
                                   crapljt.nrcnvcob = craptdb.nrcnvcob      AND
                                   crapljt.nrdocmto = craptdb.nrdocmto
                                   NO-LOCK: 
             
                aux_vldrisco = aux_vldrisco + 
                               crapljt.vldjuros +
                               crapljt.vlrestit.

            END.  /*  Fim do FOR EACH crapljd  */
   
            aux_vldestit = aux_vldestit + aux_vldrisco.
               
            IF   aux_qtdprazo <= 180   THEN
                 aux_vltit180  = aux_vltit180 + aux_vldrisco.
            ELSE
            IF   aux_qtdprazo <= 360   THEN
                 aux_vltit360  = aux_vltit360 + aux_vldrisco.
            ELSE
                 aux_vltit999  = aux_vltit999 + aux_vldrisco.

            /*--- Verifica codigo vencimento documento 3020 --*/
            
            IF  aux_qtdprazo <= 30 THEN         /* Creditos a Vencer */
                aux_vlavence[1]  = aux_vlavence[1] + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 60 THEN
                aux_vlavence[2]  = aux_vlavence[2] + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 90 THEN
                aux_vlavence[3]  = aux_vlavence[3] + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 180 THEN
                aux_vlavence[4]  = aux_vlavence[4] + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 360 THEN
                aux_vlavence[5]  = aux_vlavence[5] + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 720 THEN
                aux_vlavence[6]  = aux_vlavence[6] + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 1080 THEN
                aux_vlavence[7]  = aux_vlavence[7] + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 1440 THEN
                aux_vlavence[8]  = aux_vlavence[8] + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 1800 THEN
                aux_vlavence[9]  = aux_vlavence[9]  + aux_vldrisco.
            ELSE
            IF  aux_qtdprazo <= 5400 THEN
                aux_vlavence[10] =  aux_vlavence[10] + aux_vldrisco.
            ELSE
                aux_vlavence[11]  = aux_vlavence[11]  + aux_vldrisco.
            /*-----------------*/        
        
    END.  /*  Fim do FOR EACH  --  Leitura do crapbdt e craptdb */
    
    IF   aux_vldestit > 0   THEN
         DO:
             CREATE crapris.
             ASSIGN crapris.nrdconta = crapass.nrdconta
                    crapris.dtrefere = aux_dtrefere
                    crapris.innivris = aux_risco_rating /* 2 */ /* Risco A */
                    crapris.inindris = aux_risco_rating /* 2 */ /* Risco A */
                    crapris.qtdiaatr = 0
                    crapris.nrcpfcgc = crapass.nrcpfcgc
                    crapris.inpessoa = crapass.inpessoa
                    crapris.vldivida = aux_vldestit
                    crapris.vlvec180 = aux_vltit180 
                    crapris.vlvec360 = aux_vltit360
                    crapris.vlvec999 = aux_vltit999
                    crapris.vldiv060 = 0
                    crapris.vldiv180 = 0
                    crapris.vldiv360 = 0
                    crapris.vldiv999 = 0
                    crapris.vlprjano = 0
                    crapris.vlprjaan = 0
                    crapris.vlprjant = 0
                    crapris.vlprjm60 = 0 
                    crapris.cdcooper = glb_cdcooper.
             VALIDATE crapris.
         END.

    /*--  Gerar Informacoes Docto 3020 */
    IF  aux_vldestit > 0  THEN
        DO:
           CREATE crapris.
           ASSIGN crapris.nrdconta = crapass.nrdconta
                  crapris.dtrefere = aux_dtrefere
                  crapris.innivris = aux_risco_rating /* 2*/  /*  Risco A  */
                  crapris.inindris = aux_risco_rating /* 2*/  /*  Risco A  */
                  crapris.nrcpfcgc = crapass.nrcpfcgc
                  crapris.inpessoa = crapass.inpessoa
                  crapris.vldivida = aux_vldestit
                  crapris.inddocto = 1     /* Docto 3020 */
                  crapris.cdmodali = 0301  /* Desconto Duplicatas */
                  crapris.nrctremp = aux_nrctrlim 
                  crapris.dtinictr = aux_dtinictr
                  crapris.cdorigem = 4  /* Desconto Titulos - cob. sem reg */
                  crapris.cdagenci = crapass.cdagenci 
                  crapris.cdcooper = glb_cdcooper.

           ASSIGN aux_nrseqctr     = aux_nrseqctr + 1
                  crapris.nrseqctr = aux_nrseqctr.
           VALIDATE crapris.

           ASSIGN aux_contador = 1.          
           DO  WHILE aux_contador LE 11:
               IF  aux_vlavence[aux_contador] > 0 THEN
                   DO:
                      ASSIGN aux_vlsrisco = aux_vlavence[aux_contador]
                             aux_diasvenc = aux_diaavenc[aux_contador].
 
                      RUN calcula_codigo_vencimento.
                          
                      RUN grava_crapvri.   
                   END.
                         
               ASSIGN aux_contador = aux_contador + 1.
           END.     
 
        END.    

        /*------- Risco do desconto de titulos - cob. com registro ---- */
        ASSIGN aux_vldestit = 0
               aux_vltit180 = 0
               aux_vltit360 = 0
               aux_vltit999 = 0.

        ASSIGN aux_contador = 1.
        DO  WHILE aux_contador LE 11:
            ASSIGN aux_vlavence[aux_contador] = 0
                   aux_contador               = aux_contador + 1.
        END.        

        /* Esta busca deve obrigatoriamente ser igual ao relatorio 
           494 e 495 que sao gerados pelo fontes/crps518.p 
           os comentarios sobre a busca estao la */
        /* Considerar em risco titulos que vencem em glb_dtmvtolt */    
        FOR EACH crapbdt WHERE 
                (crapbdt.cdcooper  = glb_cdcooper       AND
                 crapbdt.nrdconta  = crapass.nrdconta   AND
                 crapbdt.insitbdt  = 3                  AND /*  Liberado  */
                 crapbdt.dtlibbdt <= aux_dtrefere)
                 OR
                (crapbdt.cdcooper  = glb_cdcooper       AND
                 crapbdt.nrdconta  = crapass.nrdconta   AND
                 crapbdt.insitbdt  = 4) NO-LOCK, /*  Liquidado */
            EACH craptdb WHERE 
                (craptdb.cdcooper = glb_cdcooper     AND
                 craptdb.nrdconta = crapbdt.nrdconta AND
                 craptdb.nrborder = crapbdt.nrborder AND
                 craptdb.insittit = 4)
                 OR
                (craptdb.cdcooper = glb_cdcooper     AND
                 craptdb.nrdconta = crapbdt.nrdconta AND
                 craptdb.nrborder = crapbdt.nrborder AND
                 craptdb.insittit = 2                AND
                 craptdb.dtdpagto = glb_dtmvtolt) NO-LOCK,
            EACH crapcob WHERE 
                 crapcob.cdcooper = glb_cdcooper     AND
                 crapcob.cdbandoc = craptdb.cdbandoc AND
                 crapcob.nrdctabb = craptdb.nrdctabb AND
                 crapcob.nrcnvcob = craptdb.nrcnvcob AND
                 crapcob.nrdconta = craptdb.nrdconta AND
                 crapcob.nrdocmto = craptdb.nrdocmto AND
                 crapcob.flgregis = TRUE NO-LOCK: 

                /*  Calculo do juros sobre o desconto do titulo ............. */

                ASSIGN aux_nrctrlim = crapbdt.nrctrlim
                       aux_dtinictr = crapbdt.dtlibbdt

                       aux_vldrisco = 0
                       aux_cdvencto = 0.

                /*FIND crapcob WHERE crapcob.cdcooper = glb_cdcooper     AND
                                   crapcob.cdbandoc = craptdb.cdbandoc AND
                                   crapcob.nrdctabb = craptdb.nrdctabb AND
                                   crapcob.nrcnvcob = craptdb.nrcnvcob AND
                                   crapcob.nrdconta = craptdb.nrdconta AND
                                   crapcob.nrdocmto = craptdb.nrdocmto 
                                   NO-LOCK NO-ERROR.*/

                IF   NOT AVAILABLE crapcob   THEN
                     DO:
                         UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") + 
                                           " - " +
                                           glb_cdprogra + "' --> '" + 
                                           "'Titulo em desconto nao encontrado" +
                                           " no " +
                                           "crapcob - ROWID(craptdb) = " +
                                           STRING(ROWID(craptdb)) +
                                           "' >> log/proc_batch.log").
                         NEXT.
                     END.

                /* 
                    Se foi pago via CAIXA, InternetBank, TAA ou compe 085
                    Nao considera em risco, pois ja esta pago o dinheiro ja entrou
                    para a cooperativa 
                */
                IF  craptdb.insittit = 2  AND
                   (crapcob.indpagto = 1  OR
                    crapcob.indpagto = 3  OR
                    crapcob.indpagto = 4  OR  /** TAA **/
                    (crapcob.indpagto = 0 AND crapcob.cdbandoc = 085)) THEN
                    NEXT.

                ASSIGN aux_vldrisco = craptdb.vlliquid
                       aux_qtdprazo = craptdb.dtvencto - craptdb.dtlibbdt.

                /* 
                    Se foi pago antecipado ele soma os juros restituidos como risco
                    tambem pois o titulo ainda eh considerado em risco  para a 
                    contabilidade
                */
                IF  craptdb.insittit = 2            AND
                    craptdb.dtdpagto = glb_dtmvtolt AND
                    craptdb.dtvencto > glb_dtmvtolt THEN
                    FOR EACH crapljt WHERE 
                             crapljt.cdcooper = glb_cdcooper     AND
                             crapljt.nrdconta = craptdb.nrdconta AND
                             crapljt.nrborder = craptdb.nrborder AND
                             crapljt.dtmvtolt = craptdb.dtlibbdt AND
                             crapljt.dtrefere > aux_dtfimmes     AND
                             crapljt.cdbandoc = craptdb.cdbandoc AND
                             crapljt.nrdctabb = craptdb.nrdctabb AND
                             crapljt.nrcnvcob = craptdb.nrcnvcob AND
                             crapljt.nrdocmto = craptdb.nrdocmto
                             NO-LOCK: 

                        aux_vldrisco = aux_vldrisco + crapljt.vlrestit.

                    END.  /*  Fim do FOR EACH crapljd  */

                FOR EACH crapljt WHERE crapljt.cdcooper = glb_cdcooper          AND
                                       crapljt.nrdconta = craptdb.nrdconta      AND
                                       crapljt.nrborder = craptdb.nrborder      AND
                                       crapljt.dtmvtolt = craptdb.dtlibbdt      AND
                                       crapljt.dtrefere < (aux_dtfimmes + 1)    AND
                                       crapljt.cdbandoc = craptdb.cdbandoc      AND
                                       crapljt.nrdctabb = craptdb.nrdctabb      AND
                                       crapljt.nrcnvcob = craptdb.nrcnvcob      AND
                                       crapljt.nrdocmto = craptdb.nrdocmto
                                       NO-LOCK: 

                    aux_vldrisco = aux_vldrisco + 
                                   crapljt.vldjuros +
                                   crapljt.vlrestit.

                END.  /*  Fim do FOR EACH crapljd  */

                aux_vldestit = aux_vldestit + aux_vldrisco.

                IF   aux_qtdprazo <= 180   THEN
                     aux_vltit180  = aux_vltit180 + aux_vldrisco.
                ELSE
                IF   aux_qtdprazo <= 360   THEN
                     aux_vltit360  = aux_vltit360 + aux_vldrisco.
                ELSE
                     aux_vltit999  = aux_vltit999 + aux_vldrisco.

                /*--- Verifica codigo vencimento documento 3020 --*/

                IF  aux_qtdprazo <= 30 THEN         /* Creditos a Vencer */
                    aux_vlavence[1]  = aux_vlavence[1] + aux_vldrisco.
                ELSE
                IF  aux_qtdprazo <= 60 THEN
                    aux_vlavence[2]  = aux_vlavence[2] + aux_vldrisco.
                ELSE
                IF  aux_qtdprazo <= 90 THEN
                    aux_vlavence[3]  = aux_vlavence[3] + aux_vldrisco.
                ELSE
                IF  aux_qtdprazo <= 180 THEN
                    aux_vlavence[4]  = aux_vlavence[4] + aux_vldrisco.
                ELSE
                IF  aux_qtdprazo <= 360 THEN
                    aux_vlavence[5]  = aux_vlavence[5] + aux_vldrisco.
                ELSE
                IF  aux_qtdprazo <= 720 THEN
                    aux_vlavence[6]  = aux_vlavence[6] + aux_vldrisco.
                ELSE
                IF  aux_qtdprazo <= 1080 THEN
                    aux_vlavence[7]  = aux_vlavence[7] + aux_vldrisco.
                ELSE
                IF  aux_qtdprazo <= 1440 THEN
                    aux_vlavence[8]  = aux_vlavence[8] + aux_vldrisco.
                ELSE
                IF  aux_qtdprazo <= 1800 THEN
                    aux_vlavence[9]  = aux_vlavence[9]  + aux_vldrisco.
                ELSE
                IF  aux_qtdprazo <= 5400 THEN
                    aux_vlavence[10] =  aux_vlavence[10] + aux_vldrisco.
                ELSE
                    aux_vlavence[11]  = aux_vlavence[11]  + aux_vldrisco.
                /*-----------------*/        

        END.  /*  Fim do FOR EACH  --  Leitura do crapbdt e craptdb */

        IF   aux_vldestit > 0   THEN
             DO:
                 CREATE crapris.
                 ASSIGN crapris.nrdconta = crapass.nrdconta
                        crapris.dtrefere = aux_dtrefere
                        crapris.innivris = aux_risco_rating /* 2 */ /* Risco A */
                        crapris.inindris = aux_risco_rating /* 2 */ /* Risco A */
                        crapris.qtdiaatr = 0
                        crapris.nrcpfcgc = crapass.nrcpfcgc
                        crapris.inpessoa = crapass.inpessoa
                        crapris.vldivida = aux_vldestit
                        crapris.vlvec180 = aux_vltit180 
                        crapris.vlvec360 = aux_vltit360
                        crapris.vlvec999 = aux_vltit999
                        crapris.vldiv060 = 0
                        crapris.vldiv180 = 0
                        crapris.vldiv360 = 0
                        crapris.vldiv999 = 0
                        crapris.vlprjano = 0
                        crapris.vlprjaan = 0
                        crapris.vlprjant = 0
                        crapris.vlprjm60 = 0 
                        crapris.cdcooper = glb_cdcooper.
                 VALIDATE crapris.
             END.

        /*--  Gerar Informacoes Docto 3020 */
        IF  aux_vldestit > 0  THEN
            DO:
               CREATE crapris.
               ASSIGN crapris.nrdconta = crapass.nrdconta
                      crapris.dtrefere = aux_dtrefere
                      crapris.innivris = aux_risco_rating /* 2*/  /*  Risco A  */
                      crapris.inindris = aux_risco_rating /* 2*/  /*  Risco A  */
                      crapris.nrcpfcgc = crapass.nrcpfcgc
                      crapris.inpessoa = crapass.inpessoa
                      crapris.vldivida = aux_vldestit
                      crapris.inddocto = 1     /* Docto 3020 */
                      crapris.cdmodali = 0301  /* Desconto Duplicatas */
                      crapris.nrctremp = aux_nrctrlim 
                      crapris.dtinictr = aux_dtinictr
                      crapris.cdorigem = 5  /* Desconto Titulos - cob. reg */
                      crapris.cdagenci = crapass.cdagenci 
                      crapris.cdcooper = glb_cdcooper.

               ASSIGN aux_nrseqctr     = aux_nrseqctr + 1
                      crapris.nrseqctr = aux_nrseqctr.
               VALIDATE crapris.

               ASSIGN aux_contador = 1.          
               DO  WHILE aux_contador LE 11:
                   IF  aux_vlavence[aux_contador] > 0 THEN
                       DO:
                          ASSIGN aux_vlsrisco = aux_vlavence[aux_contador]
                                 aux_diasvenc = aux_diaavenc[aux_contador].

                          RUN calcula_codigo_vencimento.

                          RUN grava_crapvri.   
                       END.

                   ASSIGN aux_contador = aux_contador + 1.
               END.     

            END.    

        FOR EACH crapebn WHERE crapebn.cdcooper = glb_cdcooper      AND
                               crapebn.nrdconta = crapass.nrdconta  AND
                              (crapebn.insitctr = "N" OR  /*Normal*/
                               crapebn.insitctr = "A" OR  /*Atrasado*/
                               crapebn.insitctr = "P")    /*Prejuizo*/
                               NO-LOCK:

            IF crapebn.insitctr = "A" OR crapebn.insitctr = "P" THEN
            DO:
                
                ASSIGN /* Qtd. dias em atraso */
                       aux_dias  = glb_dtmvtolt - crapebn.dtppvenc

                       aux_nivel = IF (crapebn.vlprac48 <> 0 OR
                                       crapebn.vlprej48 <> 0 OR
                                       crapebn.vlprej12 <> 0) THEN
                                       10
                                   ELSE
                                   IF (crapebn.vlvac540 <> 0 OR
                                       crapebn.vlven540 <> 0 OR
                                       crapebn.vlven360 <> 0 OR
                                       crapebn.vlven300 <> 0 OR
                                       crapebn.vlven240 <> 0) THEN
                                       9
                                   ELSE
                                   IF crapebn.vlven180 <> 0 THEN
                                       8
                                   ELSE
                                   IF crapebn.vlven150 <> 0 THEN
                                       7
                                   ELSE
                                   IF crapebn.vlven120 <> 0 THEN
                                       6
                                   ELSE
                                   IF crapebn.vlvenc90 <> 0 THEN
                                       5
                                   ELSE
                                   IF crapebn.vlvenc60 <> 0 THEN
                                       4
                                   ELSE
                                   IF crapebn.vlvenc30 <> 0 THEN
                                       3
                                   ELSE
                                   IF crapebn.vlvenc14 <> 0 THEN
                                       2
                                   ELSE
                                       1.
            END.
            ELSE
                ASSIGN aux_dias  = 0
                       aux_nivel = aux_risco_rating.


            CREATE crapris.
            ASSIGN crapris.cdcooper = glb_cdcooper
                   crapris.nrdconta = crapebn.nrdconta
                   crapris.inddocto = 1 
                   crapris.dtrefere = aux_dtrefere
                   crapris.cdmodali = 0499 /* financiamento */
                   crapris.inpessoa = crapass.inpessoa
                   crapris.nrcpfcgc = crapass.nrcpfcgc
                   crapris.nrctremp = crapebn.nrctremp  
                   crapris.dtinictr = crapebn.dtinictr
                   crapris.cdorigem = 3 /* emprestimos */
                   crapris.cdagenci = crapass.cdagenci
                   
                   /* Saldo devedor */
                   crapris.vldivida = crapebn.vlsdeved
                   
                   /* Divida a vencer */
                   crapris.vlvec180 = crapebn.vlaat180
                   crapris.vlvec360 = crapebn.vlaat180 + crapebn.vlave360 
                   crapris.vlvec999 = crapebn.vlasu360
                   
                   /* Divida vencida */
                   crapris.vldiv060 = crapebn.vlveat60
                   crapris.vldiv180 = crapebn.vlveat60 + crapebn.vlvenc61
                   crapris.vldiv360 = crapebn.vlveat60 + crapebn.vlvenc61 + 
                                      crapebn.vlven181
                   crapris.vldiv999 = crapebn.vlvsu360
                   
                   /* Ainda nao gravamos para o BNDES
                      crapris.vljura60 = 0 */ 
                   
                   /* Prejuizo */ 
                   crapris.vlprjano = crapebn.vlprej12
                   crapris.vlprjaan = crapebn.vlprej48
                   crapris.vlprjant = crapebn.vlprac48
                   crapris.vlprjm60 = 0
                   
                   crapris.innivris = aux_nivel
                   crapris.inindris = aux_nivel
                   crapris.qtdiaatr = aux_dias.

            ASSIGN aux_nrseqctr = aux_nrseqctr + 1
                   crapris.nrseqctr = aux_nrseqctr.
            VALIDATE crapris.

            RUN calcula_codigo_vencimento_bndes. /* e grava crapvri */

        END.

    /*-----------------  Cria registro de restart  -------------------*/
    
    DO WHILE TRUE:

       FIND crapres WHERE crapres.cdcooper = glb_cdcooper   AND
                          crapres.cdprogra = glb_cdprogra
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE crapres   THEN
            IF   LOCKED crapres   THEN
                 DO:
                     PAUSE 1 NO-MESSAGE.
                     NEXT.
                 END.
            ELSE
                 DO:
                     glb_cdcritic = 151.
                     RUN fontes/critic.p.
                     UNIX SILENT VALUE("echo " + STRING(TIME,"HH:MM:SS") +
                                       " - " + glb_cdprogra + "' --> '" +
                                       glb_dscritic + " >> log/proc_batch.log").
                     DELETE PROCEDURE h-b1wgen0084a.
                     UNDO TRANS_1, RETURN.
                 END.

       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    crapres.nrdconta = crapass.nrdconta.
    
END.  /*  Fim do FOR EACH e da transacao  */

DELETE PROCEDURE h-b1wgen0084a.

{ includes/cabrel132_1.i }

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 62.             

VIEW STREAM str_1 FRAME f_cabrel132_1.

RUN efetua_arrasto.    /* Assumir Menor Risco - Doctos 3020 e 3030 */

OUTPUT STREAM str_1 CLOSE.

ASSIGN glb_nrcopias = 1
       glb_nmformul = "132col"
       glb_nmarqimp = aux_nmarqimp.

RUN fontes/imprim.p.  

RUN calcula_juros_emp_60dias.




/*---- Procedures Internas --------*/

PROCEDURE lista_tipo_0:

    /*---------------------------------------
    aux_dias = se negativo - pagou antecipado 
               se positivo - esta em atraso 
    ---------------------------------------*/  
                 
    ASSIGN aux_qtmesdec = crapepr.qtmesdec.
           aux_qtdiapre = crapepr.qtpreemp * 30.      

    IF  crapepr.dtdpagto <> ? THEN  /* Verifica final  mes(dia nao util) */
        DO:
            IF  (DAY(crapepr.dtdpagto) >   DAY(glb_dtmvtolt)    AND
               MONTH(crapepr.dtdpagto) = MONTH(glb_dtmvtolt)    AND
                YEAR(crapepr.dtdpagto) =  YEAR(glb_dtmvtolt))    OR

               (MONTH(glb_dtmvtolt) = MONTH(glb_dtmvtopr) AND /*proc.semanal*/
                crapepr.dtdpagto > glb_dtmvtolt)  THEN
                
                DO:                                                     
                    ASSIGN  aux_qtmesdec = aux_qtmesdec - 1.
                END.
        END.    

    IF   (MONTH(glb_dtmvtolt) = MONTH(glb_dtmvtopr)) THEN
          DO: 
              /* Saldo calculado pelo crps616.p e crps665.p */
              ASSIGN aux_vlsdeved         = crapepr.vlsdevat
                     aux_qtprecal_retorno = crapepr.qtlcalat
                     aux_qtprecal_retorno = aux_qtprecal_retorno +
                                            crapepr.qtprecal     
                     aux_vlsdeved_atual   = aux_vlsdeved.
          END.
    ELSE     
         ASSIGN aux_qtprecal_retorno = crapepr.qtprecal
                aux_vlsdeved_atual   = crapepr.vlsdeved.
                
           
    aux_dias = ((aux_qtmesdec - aux_qtprecal_retorno) * 30).
  
    
    aux_nivel = IF   aux_dias <= 0   THEN
                     2 
                ELSE
                IF   aux_dias < 15   THEN
                     2
                ELSE
                IF   aux_dias <= 30   THEN
                     3
                ELSE 
                IF   aux_dias <= 60   THEN
                     4
                ELSE
                IF   aux_dias <= 90   THEN
                     5
                ELSE
                IF   aux_dias <= 120   THEN
                     6
                ELSE
                IF   aux_dias <= 150   THEN
                     7
                ELSE
                IF   aux_dias <= 180   THEN
                     8
                ELSE
                     9.

    ASSIGN aux_nivel_atraso = aux_nivel.
    
    FIND crawepr WHERE crawepr.cdcooper = glb_cdcooper      AND
                       crawepr.nrdconta = crapepr.nrdconta  AND
                       crawepr.nrctremp = crapepr.nrctremp  NO-LOCK NO-ERROR.
                       
    IF  AVAIL crawepr   THEN 
        DO:
            IF  crawepr.dsnivris = " " THEN
                ASSIGN aux_nivel = 2.
            ELSE    
            IF  crawepr.dsnivris = "AA" THEN
                ASSIGN aux_nivel = 1.
            ELSE
            IF  crawepr.dsnivris = "A" THEN
                ASSIGN aux_nivel = 2.
            ELSE
            IF  crawepr.dsnivris = "B" THEN
                ASSIGN aux_nivel = 3.
            ELSE
            IF  crawepr.dsnivris = "C" THEN
                ASSIGN aux_nivel = 4.
            ELSE
            IF  crawepr.dsnivris = "D" THEN
                ASSIGN aux_nivel = 5.
            ELSE
            IF  crawepr.dsnivris = "E" THEN
                ASSIGN aux_nivel = 6.
            ELSE
            IF  crawepr.dsnivris = "F" THEN
                ASSIGN aux_nivel = 7.
            ELSE
            IF  crawepr.dsnivris = "G" THEN
                ASSIGN aux_nivel = 8.
            ELSE
                ASSIGN aux_nivel = 9.

            /* Rating efetuado depois do emprestimo */
            IF  aux_risco_rating <> 0 THEN
                DO:
                    IF   AVAILABLE crapnrc   THEN
                         DO:       
                             IF  crapnrc.dtmvtolt >=  crapepr.dtmvtolt THEN  
                                 ASSIGN aux_nivel = aux_risco_rating.
                         END.
                END.          
         
        END.
    
      /* Se emprestimo tiver nivel maior que o atraso....*/
      IF  aux_nivel_atraso > aux_nivel THEN 
          ASSIGN aux_nivel = aux_nivel_atraso.

      ASSIGN aux_vlrpagos = 0.
      
      IF   crapepr.inprejuz = 1   THEN
           DO:
               ASSIGN aux_nivel = 9.
                          
               FOR EACH craplem WHERE craplem.cdcooper  = glb_cdcooper     AND
                                      craplem.nrdconta  = crapepr.nrdconta AND
                                      craplem.dtmvtolt <= aux_dtrefere     AND
                                     (craplem.cdhistor  = 382              OR
                                      craplem.cdhistor  = 383)         NO-LOCK:
                                  
                   IF  craplem.nrctremp = crapepr.nrctremp THEN
                       ASSIGN aux_vlrpagos = aux_vlrpagos + craplem.vllanmto.
               END.
      
               IF   aux_vlrpagos >= crapepr.vlprejuz  OR
                    crapepr.vlsdprej = 0  /* 13/05/2003 */ THEN
                    LEAVE. 
            END.
           
      ASSIGN aux_qtdiaatr =  (aux_qtmesdec - aux_qtprecal_retorno) * 30.

      IF  aux_risco_rating <> 0         AND
          aux_risco_rating > aux_nivel THEN
          ASSIGN aux_nivel = aux_risco_rating.
      
     IF  aux_risco_rating <> 0 AND   /* Rating efetuado depois do emprestimo*/
         aux_dias <=  0        THEN  /* Em dia */
         DO:
             IF   AVAILABLE crapnrc   THEN
                  DO:          
                      IF   crapnrc.dtmvtolt >=  crapepr.dtmvtolt THEN     
                           ASSIGN aux_nivel = aux_risco_rating.

                  END.
         END.
      
      CREATE crapris. 
      ASSIGN crapris.nrdconta = crapass.nrdconta 
             crapris.dtrefere = aux_dtrefere
             crapris.nrcpfcgc = crapass.nrcpfcgc
             crapris.inpessoa = crapass.inpessoa 
             crapris.vldivida = aux_vlsdeved_atual +
                               (crapepr.vlprejuz - aux_vlrpagos)
             crapris.qtdiaatr = IF   aux_qtdiaatr < 0  THEN 0
                                ELSE aux_qtdiaatr
             crapris.innivris = aux_nivel
             crapris.inindris = aux_nivel
             aux_vlsdeved     = aux_vlsdeved_atual  
             crapris.cdcooper = glb_cdcooper.
      VALIDATE crapris.
      
      ASSIGN  aux_vlpresta = crapepr.vlpreemp. 

              aux_vlatraso = TRUNC(crapepr.vlpreemp * (aux_qtmesdec - 
                                                 aux_qtprecal_retorno),2).

      IF   aux_vlatraso > aux_vlsdeved   THEN
           aux_vlatraso = aux_vlsdeved.

      IF  aux_dias > 0 THEN
          DO:  
             /* Se o numero de prestacoes faltantes for <= 1 e esta em atraso 
                a mais de 60 dias
                Obs.: Esta sendo feito desta forma, pois na atual forma de 
                      calculo ha problema para emprestimos em que o valor do 
                      atraso eh menor que o dobro da parcela e esta vencido a 
                      mais de 60 dias (demanda bacen, reversao da receita 60d)
                      Esta situacao sera corrigida quando o novo sistema
                      de emprestimo entrar em vigor.
             */         
             IF  crapepr.qtpreemp - crapepr.qtprepag <= 2  AND
                 crapepr.qtpreemp - crapepr.qtprepag >  0  AND
                 crapris.qtdiaatr > 60 THEN
             DO:
                 IF  crapris.qtdiaatr < 180  THEN
                     crapris.vldiv180 = aux_vlatraso.
                 ELSE
                 IF  crapris.qtdiaatr < 360  THEN
                     crapris.vldiv360 = aux_vlatraso.
                 ELSE
                     crapris.vldiv999 = aux_vlatraso.
             END.
             ELSE
             DO:
             IF  aux_vlatraso <= aux_vlpresta * 2  THEN
                 DO:
                    ASSIGN crapris.vldiv060 = aux_vlatraso  /* 60 dias */
                           aux_vlatraso     = 0.
                 END.
             ELSE
                 DO:
                    ASSIGN crapris.vldiv060 =  aux_vlpresta * 2  
                           aux_vlatraso     = aux_vlatraso - (aux_vlpresta * 2).
                 END.
             
             IF  aux_vlatraso > 0 THEN                     /* 180 dias */
                 DO:
                   IF  aux_vlatraso <=  aux_vlpresta * 4 THEN
                       DO:
                          ASSIGN crapris.vldiv180 = aux_vlatraso
                                 aux_vlatraso     = 0.
                       END.
                  ELSE
                       DO:
                          ASSIGN crapris.vldiv180 = aux_vlpresta * 4
                                 aux_vlatraso     = aux_vlatraso -
                                                 (aux_vlpresta * 4).
                       END.
                 END.
                                                          /* 360 dias */
             IF  aux_vlatraso > 0 THEN
                 DO:
                   IF  aux_vlatraso <=  aux_vlpresta * 12 THEN
                       DO:
                          ASSIGN crapris.vldiv360 = aux_vlatraso
                                 aux_vlatraso     = 0.
                       END.
                  ELSE
                       DO:
                          ASSIGN crapris.vldiv360 = aux_vlpresta * 12
                                 aux_vlatraso     = aux_vlatraso -
                                                 (aux_vlpresta * 12).
                       END.
                END.

             IF  aux_vlatraso > 0 THEN
                 DO:
                    assign crapris.vldiv999 =  aux_vlatraso. 
                 END.
             END.
             
          END.                     

      aux_vlvencer = aux_vlsdeved    - crapris.vlvec180 - crapris.vldiv060 - 
                     crapris.vldiv180 - crapris.vldiv360 - crapris.vldiv999.
               
      IF   aux_vlvencer > 0   THEN
           DO:
               aux_vlvencer180 = crapepr.vlpreemp * 6 .
               IF   aux_vlvencer180 > aux_vlvencer THEN
                    ASSIGN crapris.vlvec180 = crapris.vlvec180 + aux_vlvencer
                           aux_vlvencer    = 0.
               ELSE
                    ASSIGN crapris.vlvec180 = crapris.vlvec180 + 
                                                      aux_vlvencer180
                           aux_vlvencer     = aux_vlvencer - aux_vlvencer180.
           END.

      IF   aux_vlvencer > 0   THEN
           DO:
               aux_vlvencer360 = crapepr.vlpreemp * 6 .
               IF   aux_vlvencer360 > aux_vlvencer   THEN
                    ASSIGN crapris.vlvec360 = aux_vlvencer
                           aux_vlvencer     = 0.
               ELSE
                    ASSIGN crapris.vlvec360 = aux_vlvencer360
                           aux_vlvencer     = aux_vlvencer - aux_vlvencer360.
           END.

      IF   aux_vlvencer > 0   THEN
           ASSIGN crapris.vlvec999 = aux_vlvencer.
                  aux_vlvencer     = 0.

      IF  crapepr.vlprejuz > 0 THEN
          DO:
              ASSIGN aux_indmes = MONTH(glb_dtmvtolt)
                     aux_indano =  YEAR(glb_dtmvtolt).

              IF   aux_indmes = MONTH(crapepr.dtprejuz)   AND
                   aux_indano =  YEAR(crapepr.dtprejuz)   THEN
                   ASSIGN aux_indocc = 1.
              ELSE    
                   DO aux_indocc = 2 TO 49:
      
                      ASSIGN aux_indmes = aux_indmes - 1.
                      IF  aux_indmes = 0 THEN
                          ASSIGN aux_indmes = 12
                                 aux_indano = aux_indano - 1.
                      IF  aux_indmes = MONTH(crapepr.dtprejuz)
                      AND aux_indano =  YEAR(crapepr.dtprejuz) then
                          LEAVE.
    
                   END.
             
              IF   aux_indocc <= 12   THEN
                   crapris.vlprjano = crapepr.vlprejuz - aux_vlrpagos.
              ELSE
                   IF   aux_indocc >= 13   AND
                        aux_indocc <= 48   THEN
                        crapris.vlprjaan = crapepr.vlprejuz - aux_vlrpagos.
                   ELSE
                   IF   aux_indocc >= 49   THEN
                        crapris.vlprjant = crapepr.vlprejuz - aux_vlrpagos.
 
          END.
      
      /* DOCTO 3010 PERMANECE COM RISCO H */      
      IF  crapris.vlprjano <> 0  OR
          crapris.vlprjaan <> 0  OR
          crapris.vlprjant <> 0  THEN
          ASSIGN  crapris.innivris = 9
                  crapris.inindris = 9
                  aux_nivel = 10.
          
      ASSIGN aux_valor_auxiliar = crapris.vldivida - crapris.vlprjm60.
      /* Nao gravar se divida for somente prejuizo mais de 60 meses */
      IF  aux_valor_auxiliar > 0  THEN
          DO:
             
             ASSIGN  aux_vlvenc180  = crapris.vlvec180
                     aux_vlvenc360  = crapris.vlvec360.
                     aux_vlvenc999  = crapris.vlvec999.

             ASSIGN  aux_vldivi060  = crapris.vldiv060
                     aux_vldivi180  = crapris.vldiv180
                     aux_vldivi360  = crapris.vldiv360
                     aux_vldivi999  = crapris.vldiv999.

             ASSIGN  aux_vlprjano   = crapris.vlprjano
                     aux_vlprjaan   = crapris.vlprjaan
                     aux_vlprjant   = crapris.vlprjant.
                 
             IF  aux_nivel     = 10 AND  /* Se tenho prejuizo - somente prej. */
                (aux_vlvenc180 > 0  OR
                 aux_vlvenc360 > 0  OR
                 aux_vlvenc999 > 0  OR
                 aux_vldivi060 > 0  OR
                 aux_vldivi180 > 0  OR
                 aux_vldivi360 > 0  OR
                 aux_vldivi999 > 0) THEN 
                 DO:
                    IF  aux_vlprjano > 0 THEN 
                        ASSIGN aux_vlprjano = 
                               aux_vlprjano  +
                               aux_vlvenc180 +
                               aux_vlvenc360 +
                               aux_vlvenc999 +
                               aux_vldivi060 +
                               aux_vldivi180 +
                               aux_vldivi360 +
                               aux_vldivi999.
                    ELSE  
                    IF  aux_vlprjaan > 0   THEN         
                        ASSIGN aux_vlprjaan = 
                               aux_vlprjaan  +
                               aux_vlvenc180 +
                               aux_vlvenc360 +
                               aux_vlvenc999 +
                               aux_vldivi060 +
                               aux_vldivi180 +
                               aux_vldivi360 +
                               aux_vldivi999.
                    ELSE
                        ASSIGN aux_vlprjant = 
                               aux_vlprjant  +
                               aux_vlvenc180 +
                               aux_vlvenc360 +
                               aux_vlvenc999 +
                               aux_vldivi060 +
                               aux_vldivi180 +
                               aux_vldivi360 +
                               aux_vldivi999.
                  
                   ASSIGN aux_vlvenc180 = 0 
                          aux_vlvenc360 = 0 
                          aux_vlvenc999 = 0 
                          aux_vldivi060 = 0 
                          aux_vldivi180 = 0
                          aux_vldivi360 = 0 
                          aux_vldivi999 = 0. 
                END.
                  
             ASSIGN aux_valor_auxiliar = aux_vlvenc180 +
                                         aux_vlvenc360 +
                                         aux_vlvenc999 +
                                         aux_vldivi060 +
                                         aux_vldivi180 +
                                         aux_vldivi360 +
                                         aux_vldivi999 +
                                         aux_vlprjano  +             
                                         aux_vlprjaan  +
                                         aux_vlprjant.             
        
             ASSIGN aux_nrctrlim = crapepr.nrctremp 
                    aux_dtinictr = crapepr.dtmvtolt.
              
             /*--  Gerar Informacoes Docto 3020(Buffer) ----*/
             
             FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
                                craplcr.cdlcremp = crapepr.cdlcremp
                                NO-LOCK NO-ERROR.
             
             IF AVAIL craplcr THEN
             DO:
                 CREATE crapris.
                 ASSIGN crapris.nrdconta = crapass.nrdconta
                        crapris.dtrefere = aux_dtrefere
                        crapris.innivris = aux_nivel
                        crapris.inindris = aux_nivel
                        crapris.nrcpfcgc = crapass.nrcpfcgc
                        crapris.inpessoa = crapass.inpessoa
                        crapris.qtdiaatr = IF   aux_qtdiaatr < 0  THEN 0
                                           ELSE aux_qtdiaatr
                        crapris.vldivida = aux_valor_auxiliar
                        crapris.inddocto = 1     /* Docto 3020  */
                        crapris.cdmodali = IF craplcr.dsoperac =
                                                           "FINANCIAMENTO"
                                           THEN 0499
                                           ELSE 0299 
                                            /* Emprestimos/Financiamentos */
                        crapris.nrctremp = aux_nrctrlim 
                        crapris.dtinictr = aux_dtinictr 
                        crapris.cdorigem = 3  /* Emprestimos/Financiamentos */
                        crapris.cdagenci = crapass.cdagenci   
                        crapris.cdcooper = glb_cdcooper.
                 
                 ASSIGN aux_nrseqctr     = aux_nrseqctr + 1 
                        crapris.nrseqctr = aux_nrseqctr.
                 VALIDATE crapris.

             END.
          
          END.
       ELSE
          DO:
             ASSIGN  aux_vlvenc180 = 0
                     aux_vlvenc360 = 0 
                     aux_vlvenc999 = 0            
                     aux_vldivi060 = 0 
                     aux_vldivi180 = 0 
                     aux_vldivi360 = 0 
                     aux_vldivi999 = 0 
                     aux_vlprjano  = 0
                     aux_vlprjaan  = 0
                     aux_vlprjant  = 0.
          END.
      ASSIGN aux_contador = 1.
      DO  WHILE  aux_contador LE 11:
          ASSIGN aux_vlavence[aux_contador] = 0
                 aux_contador               = aux_contador + 1.
      END.        

      ASSIGN aux_contador = 1.
      DO  WHILE  aux_contador LE 12:
          ASSIGN aux_vlvencid[aux_contador] = 0
                 aux_contador               = aux_contador + 1.
      END.        

      IF  aux_vlvenc180 > 0 OR
          aux_vlvenc360 > 0 OR
          aux_vlvenc999 > 0 THEN           

          RUN  gera_avencer.
          
      /* Se o numero de prestacoes faltantes for <= 1 e esta em 
         atraso a mais de 60 dias
         Obs.: 
            Esta sendo feito desta forma, pois na atual forma de 
            calculo ha problema para emprestimos em que o valor do 
            atraso eh menor que o dobro da parcela e esta vencido a 
            mais de 60 dias (demanda bacen, reversao da receita 60d)
            Esta situacao sera corrigida quando o novo sistema
            de emprestimo entrar em vigor.
      */

     IF   crapepr.inprejuz <> 1                    AND
          crapepr.qtpreemp - crapepr.qtprepag <= 1 AND
          crapepr.qtpreemp - crapepr.qtprepag > 0  AND
          crapris.qtdiaatr > 60  THEN
      DO:
          ASSIGN aux_vlsrisco = aux_valor_auxiliar        /*aux_vlatraso*/
                 aux_diasvenc = crapris.qtdiaatr * -1.
          
          RUN calcula_codigo_vencimento.
                         
          RUN grava_crapvri.  
      END.
      ELSE
      DO:
          IF  aux_vldivi060 > 0 OR
              aux_vldivi180 > 0 OR
              aux_vldivi360 > 0 OR
              aux_vldivi999 > 0 THEN 
              RUN gera_vencidos.
    
          ASSIGN aux_contador = 1.          
          DO  WHILE aux_contador LE 11:
              IF  aux_vlavence[aux_contador] > 0 THEN
                  DO:
                     ASSIGN aux_vlsrisco  = aux_vlavence[aux_contador]
                            aux_diasvenc  = aux_diaavenc[aux_contador].
                     RUN calcula_codigo_vencimento.
                         
                     RUN grava_crapvri.  
                        
                  END.       
                             
               ASSIGN aux_contador = aux_contador + 1.
           END.     
        
          ASSIGN aux_contador = 1.          
          DO  WHILE aux_contador LE 12:
              IF  aux_vlvencid[aux_contador] > 0 THEN  
                  DO:
                     ASSIGN aux_vlsrisco = aux_vlvencid[aux_contador]
                            aux_diasvenc = (aux_diavenci[aux_contador] * -1).
     
                     RUN calcula_codigo_vencimento.
                     
                     RUN grava_crapvri.  
                        
                  END.       
                             
               ASSIGN aux_contador = aux_contador + 1.
          END.     
      END.
      IF  aux_vlprjano  > 0  THEN 
          DO:
             ASSIGN aux_cdvencto = 310
                    aux_vlsrisco = aux_vlprjano.  
             RUN grava_crapvri.                            
          END. 
          
          
      IF  aux_vlprjaan  > 0  THEN
          DO:
             ASSIGN aux_cdvencto = 320
                    aux_vlsrisco = aux_vlprjaan. 
              RUN grava_crapvri.                          
          END. 

     
      IF  aux_vlprjant  > 0  THEN
          DO:
             ASSIGN aux_cdvencto = 330
                    aux_vlsrisco = aux_vlprjant. 
              RUN grava_crapvri.                          
          END. 

END PROCEDURE.

PROCEDURE lista_tipo_1:
    /*
    RUN busca_pagamentos_parcelas IN h-b1wgen0084a
                                    (INPUT glb_cdcooper, 
                                     INPUT 0, 
                                     INPUT 0, 
                                     INPUT glb_cdoperad, 
                                     INPUT glb_nmdatela, 
                                     INPUT 1, 
                                     INPUT crapepr.nrdconta, 
                                     INPUT 1, 
                                     INPUT glb_dtmvtolt, 
                                     INPUT FALSE, 
                                     INPUT crapepr.nrctremp, 
                                     INPUT glb_dtmvtoan,
                                     INPUT 0, /* Todas */
                                    OUTPUT TABLE tt-erro,
                                    OUTPUT TABLE tt-pagamentos-parcelas,
                                    OUTPUT TABLE tt-calculado). 

    IF   RETURN-VALUE <> "OK"   THEN
         RETURN.

    FIND FIRST tt-calculado NO-LOCK NO-ERROR.
    */
    FIND craplcr WHERE craplcr.cdcooper = glb_cdcooper AND
                       craplcr.cdlcremp = crapepr.cdlcremp
                       NO-LOCK NO-ERROR.

    CREATE crapris.
    ASSIGN aux_nrseqctr = aux_nrseqctr + 1 
           
           crapris.cdcooper = glb_cdcooper
           crapris.nrdconta = crapepr.nrdconta
           crapris.inddocto = 1
           crapris.dtrefere = aux_dtrefere
           crapris.cdmodali = IF   craplcr.dsoperac = "FINANCIAMENTO"    THEN 
                                   0499
                              ELSE 
                                   0299 
           crapris.inpessoa = crapass.inpessoa
           crapris.nrcpfcgc = crapass.nrcpfcgc
           crapris.nrctremp = crapepr.nrctremp
           crapris.nrseqctr = aux_nrseqctr
           crapris.dtinictr = crapepr.dtmvtolt
           crapris.cdorigem = 3
           crapris.cdagenci = crapass.cdagenci.
           /*
           crapris.vlprjano = 0
           crapris.vlprjaan = 0
           crapris.vlprjant = 0
           crapris.vlprjm60 = 0.
           */
    VALIDATE crapris.

    ASSIGN aux_dias  = 0
           aux_nivel = 2.

    /* Parcela com mais atraso */
    FIND FIRST crappep WHERE crappep.cdcooper = glb_cdcooper       AND
                             crappep.nrdconta = crapepr.nrdconta   AND
                             crappep.nrctremp = crapepr.nrctremp   AND
                             crappep.inliquid = 0                  AND
                             crappep.dtvencto <= glb_dtmvtoan  
                             NO-LOCK NO-ERROR.

    IF   AVAIL crappep   THEN
         DO:
             ASSIGN aux_dias  = glb_dtmvtolt - crappep.dtvencto
                    aux_nivel = IF   aux_dias <= 0   THEN
                                     2 
                                ELSE
                                IF   aux_dias < 15   THEN
                                     2
                                ELSE
                                IF   aux_dias <= 30   THEN
                                     3
                                ELSE 
                                IF   aux_dias <= 60   THEN
                                     4
                                ELSE
                                IF   aux_dias <= 90   THEN
                                     5
                                ELSE
                                IF   aux_dias <= 120   THEN
                                     6
                                ELSE
                                IF   aux_dias <= 150   THEN
                                     7
                                ELSE
                                IF   aux_dias <= 180   THEN
                                     8
                                ELSE
                                     9.

             ASSIGN crapris.innivris = aux_nivel
                    crapris.inindris = aux_nivel
                    crapris.qtdiaatr = aux_dias.

         END.
    ELSE
         DO:
             ASSIGN crapris.innivris = 2
                    crapris.inindris = 2
                    crapris.qtdiaatr = 0.
         END.
    
    /* ********************************************* */
    /* calculo dos Juros em atraso a mais de 59 dias */
    /* ********************************************* */

     aux_totjur60 = 0.
     
     /* Calcular somente na mensal******************* */
     IF  MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr) THEN
     DO:
         IF  aux_dias >= 60 THEN  /* Calcular o valor dos juros a mais de 60 dias */
             DO:
                  FOR EACH craplem NO-LOCK WHERE craplem.cdcooper = glb_cdcooper     AND
                                                 craplem.nrdconta = crapepr.nrdconta AND
                                                 craplem.nrctremp = crapepr.nrctremp AND
                                                (craplem.cdhistor = 1037 OR
                                                 craplem.cdhistor = 1038)            AND
                                                 craplem.dtmvtolt > glb_dtmvtolt - (aux_dias - 59):
                    aux_totjur60 = aux_totjur60 + craplem.vllanmto.
                END.
             END.
         ASSIGN crapris.vljura60 = aux_totjur60.
     END.
    /* ********************************************* */


    aux_vldivida_acum = 0.
    
    FOR EACH crappep WHERE crappep.cdcooper = glb_cdcooper       AND
                           crappep.nrdconta = crapepr.nrdconta   AND
                           crappep.nrctremp = crapepr.nrctremp   AND
                           crappep.inliquid = 0                  NO-LOCK
                 BREAK BY crappep.nrparepr:
        
        aux_vldivida_acum = aux_vldivida_acum + crappep.vlsdvatu.
        
        aux_vlsrisco = crappep.vlsdvatu.
        
        /* Somente na mensal */
        IF  MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr) THEN
            DO:
                IF  LAST (crappep.nrparepr) THEN
                    DO:
                        IF  crapepr.vlsdeved <> aux_vldivida_acum THEN
                            aux_vlsrisco = (crapepr.vlsdeved - aux_vldivida_acum) + 
                                                              crappep.vlsdvatu.
                    END.
            END.

        /* Diferenca de dias entre a data de vencimento e hoje */
        ASSIGN aux_diasvenc = crappep.dtvencto - glb_dtmvtolt
               aux_qtdiapre = aux_diasvenc
               aux_vlsrisco = aux_vlsrisco. 

        RUN calcula_codigo_vencimento.
                     
        RUN grava_crapvri.
        
        IF   aux_diasvenc >= 0   THEN /* Valores a vencer */ 
             DO:
                 IF   aux_diasvenc <= 180    THEN
                      ASSIGN crapris.vlvec180 = crapris.vlvec180 + 
                                                aux_vlsrisco. 
                 ELSE
                 IF   aux_diasvenc <= 360    THEN
                      ASSIGN crapris.vlvec360 = crapris.vlvec360 + 
                                                aux_vlsrisco. 
                 ELSE
                      ASSIGN crapris.vlvec999 = crapris.vlvec999 + 
                                                aux_vlsrisco. 
             END.
        ELSE                          /* Valores ja vencidos */
             DO:
                 ASSIGN aux_diasvenc = aux_diasvenc * -1. 

                 IF   aux_diasvenc <=  60   THEN
                      ASSIGN crapris.vldiv060 = crapris.vldiv060 + 
                                                aux_vlsrisco. 
                 ELSE
                 IF   aux_diasvenc <= 180   THEN
                      ASSIGN crapris.vldiv180 = crapris.vldiv180 + 
                                                aux_vlsrisco. 
                 ELSE
                 IF   aux_diasvenc <= 360   THEN
                      ASSIGN crapris.vldiv360 = crapris.vldiv360 + 
                                                aux_vlsrisco. 
                 ELSE
                      ASSIGN crapris.vldiv999 = crapris.vldiv999 +
                                                aux_vlsrisco. 
             END.
    END.
    
    /* Atualiza o valor da dívida na crapris. */
    IF  MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr) THEN 
        /* Se mensal, o emprestimo está atualizado. */
        ASSIGN crapris.vldivida = crapepr.vlsdeved.
    ELSE
        ASSIGN crapris.vldivida = aux_vldivida_acum.


END PROCEDURE.


PROCEDURE calcula_codigo_vencimento:

      ASSIGN aux_cdvencto = 0.
      
      IF  aux_diasvenc >= 0  THEN          /* Creditos a vencer */
          DO:     
             IF  aux_diasvenc <= 30 THEN
                 ASSIGN aux_cdvencto = 110.
             ELSE
             IF  aux_diasvenc <= 60 THEN
                 IF  aux_qtdiapre <= 30 AND aux_tpoperac = "EMPREST" THEN
                     ASSIGN aux_cdvencto = 110.
                 ELSE
                     ASSIGN aux_cdvencto = 120.
             ELSE
             IF  aux_diasvenc <= 90 THEN
                 IF  aux_qtdiapre <= 60 AND aux_tpoperac = "EMPREST" THEN
                     ASSIGN aux_cdvencto = 120.
                 ELSE    
                     ASSIGN aux_cdvencto = 130.
             ELSE
             IF  aux_diasvenc <= 180 THEN
                 IF  aux_qtdiapre <= 90 AND aux_tpoperac = "EMPREST" THEN
                     ASSIGN aux_cdvencto = 130.
                 ELSE    
                     ASSIGN aux_cdvencto = 140.
             ELSE
             IF  aux_diasvenc <= 360 THEN
                 IF  aux_qtdiapre <= 180 AND aux_tpoperac = "EMPREST" THEN
                     ASSIGN aux_cdvencto = 140.
                 ELSE     
                     ASSIGN aux_cdvencto = 150.
             ELSE
             IF  aux_diasvenc <= 720 THEN
                 IF  aux_qtdiapre <= 360 AND aux_tpoperac = "EMPREST" THEN
                     ASSIGN aux_cdvencto = 150.
                 ELSE    
                     ASSIGN aux_cdvencto = 160.
             ELSE
             IF  aux_diasvenc <= 1080 THEN
                 IF  aux_qtdiapre <= 720 AND aux_tpoperac = "EMPREST" THEN
                     ASSIGN aux_cdvencto = 160.
                 ELSE    
                     ASSIGN aux_cdvencto = 165.
             ELSE
             IF  aux_diasvenc <= 1440 THEN
                 IF  aux_qtdiapre <= 1080 AND aux_tpoperac = "EMPREST" THEN
                     ASSIGN aux_cdvencto = 165.
                 ELSE
                     ASSIGN aux_cdvencto = 170.
             ELSE    
             IF  aux_diasvenc <= 1800 THEN
                 IF  aux_qtdiapre <= 1440 AND aux_tpoperac = "EMPREST" THEN
                     ASSIGN aux_cdvencto = 170.
                 ELSE
                     ASSIGN aux_cdvencto = 175.
             ELSE
             IF  aux_diasvenc <= 5400 THEN
                 IF  aux_qtdiapre <= 1800 AND aux_tpoperac = "EMPREST" THEN
                     ASSIGN aux_cdvencto = 175.
                 ELSE
                     ASSIGN aux_cdvencto = 180.
             ELSE
                 IF  aux_qtdiapre <= 5400 AND aux_tpoperac = "EMPREST" THEN
                     ASSIGN aux_cdvencto = 180.
                 ELSE 
                     ASSIGN aux_cdvencto = 190.
            
          END.
      ELSE
          DO:                                   /* Creditos Vencidos */
             ASSIGN aux_diasvenc = aux_diasvenc * -1.
             IF  aux_diasvenc <= 14 THEN
                 ASSIGN aux_cdvencto = 205.
             ELSE
             IF  aux_diasvenc <= 30 THEN
                 ASSIGN aux_cdvencto = 210.
             ELSE
             IF  aux_diasvenc <= 60 THEN
                 ASSIGN aux_cdvencto = 220.
             ELSE
             IF  aux_diasvenc <= 90 THEN
                 ASSIGN aux_cdvencto = 230.
             ELSE
             IF  aux_diasvenc <= 120 THEN
                 ASSIGN aux_cdvencto = 240.
             ELSE
             IF  aux_diasvenc <= 150 THEN
                 ASSIGN aux_cdvencto = 245.
             ELSE
             IF  aux_diasvenc <= 180 THEN
                 ASSIGN aux_cdvencto = 250.
             ELSE
             IF  aux_diasvenc <= 240 THEN
                 ASSIGN aux_cdvencto = 255.
             ELSE    
             IF  aux_diasvenc <= 300 THEN
                 ASSIGN aux_cdvencto = 260.
             ELSE
             IF  aux_diasvenc <= 360 THEN
                 ASSIGN aux_cdvencto = 270.
             ELSE
             IF  aux_diasvenc <= 540 THEN
                 ASSIGN aux_cdvencto = 280.
             ELSE
                 ASSIGN aux_cdvencto = 290.
          END.       
END PROCEDURE.    

PROCEDURE calcula_codigo_vencimento_bndes:

    IF   crapebn.vlaven30 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 110
                    aux_vlsrisco = crapebn.vlaven30.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlaven60 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 120
                    aux_vlsrisco = crapebn.vlaven60.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlaven90 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 130
                    aux_vlsrisco = crapebn.vlaven90.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlave180 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 140
                    aux_vlsrisco = crapebn.vlave180.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlave360 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 150
                    aux_vlsrisco = crapebn.vlave360.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlave720 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 160
                    aux_vlsrisco = crapebn.vlave720.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlav1080 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 165
                    aux_vlsrisco = crapebn.vlav1080.
                  
             RUN grava_crapvri.
         END.

    IF   crapebn.vlav1440 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 170
                    aux_vlsrisco = crapebn.vlav1440.
                   
             RUN grava_crapvri.
         END.

    IF   crapebn.vlav1800 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 175
                    aux_vlsrisco = crapebn.vlav1800.
             
             RUN grava_crapvri.
         END.

    IF   crapebn.vlav5400 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 180
                    aux_vlsrisco = crapebn.vlav5400.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlaa5400 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 190
                    aux_vlsrisco = crapebn.vlaa5400.
             
             RUN grava_crapvri.
         END.    

    IF   crapebn.vlvenc14 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 205
                    aux_vlsrisco = crapebn.vlvenc14.
                 
             RUN grava_crapvri.
         END.

    IF   crapebn.vlvenc30 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 210
                    aux_vlsrisco = crapebn.vlvenc30.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlvenc60 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 220
                    aux_vlsrisco = crapebn.vlvenc60.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlvenc90 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 230
                    aux_vlsrisco = crapebn.vlvenc90.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlven120 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 240
                    aux_vlsrisco = crapebn.vlven120.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlven150 > 0 THEN
         DO: 
             ASSIGN aux_cdvencto = 245
                    aux_vlsrisco = crapebn.vlven150.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlven180 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 250
                    aux_vlsrisco = crapebn.vlven180.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlven240 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 255
                    aux_vlsrisco = crapebn.vlven240.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlven300 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 260
                    aux_vlsrisco = crapebn.vlven300.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlven360 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 270
                    aux_vlsrisco = crapebn.vlven360.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlven540 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 280
                    aux_vlsrisco = crapebn.vlven540.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlvac540 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 290
                    aux_vlsrisco = crapebn.vlvac540.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlprej12 > 0 THEN
         DO: 
             ASSIGN aux_cdvencto = 310
                    aux_vlsrisco = crapebn.vlprej12.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlprej48 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 320
                    aux_vlsrisco = crapebn.vlprej48.
                    
             RUN grava_crapvri.
         END.

    IF   crapebn.vlprac48 > 0 THEN
         DO:
             ASSIGN aux_cdvencto = 330
                    aux_vlsrisco = crapebn.vlprac48.
                    
             RUN grava_crapvri.
         END.

END PROCEDURE.
    
PROCEDURE grava_crapvri:
   
     FIND crapvri WHERE crapvri.cdcooper = glb_cdcooper      AND
                        crapvri.dtrefere = crapris.dtrefere  AND
                        crapvri.nrdconta = crapris.nrdconta  AND
                        crapvri.innivris = crapris.innivris  AND
                        crapvri.cdmodali = crapris.cdmodali  AND
                        crapvri.nrctremp = crapris.nrctremp  AND
                        crapvri.nrseqctr = aux_nrseqctr      AND
                        crapvri.cdvencto = aux_cdvencto
                        EXCLUSIVE-LOCK NO-ERROR.
     IF  NOT AVAIL crapvri THEN
         DO:
            CREATE crapvri.
            ASSIGN crapvri.nrdconta = crapris.nrdconta
                   crapvri.dtrefere = crapris.dtrefere
                   crapvri.innivris = crapris.innivris
                   crapvri.cdmodali = crapris.cdmodali
                   crapvri.cdvencto = aux_cdvencto
                   crapvri.vldivida = aux_vlsrisco
                   crapvri.nrctremp = crapris.nrctremp
                   crapvri.nrseqctr = aux_nrseqctr 
                   crapvri.cdcooper = glb_cdcooper.
            VALIDATE crapvri.
         END. 
     ELSE
         ASSIGN crapvri.vldivida = crapvri.vldivida + aux_vlsrisco.
         
         
END PROCEDURE.

PROCEDURE gera_avencer:

    DEF VAR aux_vencer030  AS DEC NO-UNDO.
    DEF VAR aux_vencer060  AS DEC NO-UNDO.
    DEF VAR aux_vencer090  AS DEC NO-UNDO.
    DEF VAR aux_vencer180  AS DEC NO-UNDO.
    DEF VAR aux_vencer360  AS DEC NO-UNDO.
    DEF VAR aux_vencer720  AS DEC NO-UNDO.
    DEF VAR aux_vencer1080 AS DEC NO-UNDO.
    DEF VAR aux_vencer1440 AS DEC NO-UNDO.
    DEF VAR aux_vencer1800 AS DEC NO-UNDO.
    DEF VAR aux_vencer5400 AS DEC NO-UNDO.
    DEF VAR aux_vencer9999 AS DEC NO-UNDO.


     IF   aux_vlvenc180   > 0 THEN
          DO:
             IF  aux_vlvenc180 < crapepr.vlpreemp  THEN
                 ASSIGN aux_vlavence[1] =  aux_vlvenc180
                        aux_vlvenc180   = 0.
             ELSE                                 
                 ASSIGN aux_vlavence[1]  = crapepr.vlpreemp
                        aux_vlvenc180   =  aux_vlvenc180 - aux_vlavence[1].
          END.

      IF  aux_vlvenc180   > 0 THEN
          DO:
             IF  aux_vlvenc180 < crapepr.vlpreemp   THEN
                 ASSIGN aux_vlavence[2] = aux_vlvenc180
                        aux_vlvenc180   = 0.
             ELSE
                 ASSIGN aux_vlavence[2] = crapepr.vlpreemp 
                        aux_vlvenc180   = aux_vlvenc180 - aux_vlavence[2].
          END.
             
      IF  aux_vlvenc180   > 0 THEN
          DO:
             IF  aux_vlvenc180 < crapepr.vlpreemp   THEN
                 ASSIGN aux_vlavence[3] =  aux_vlvenc180
                        aux_vlvenc180   = 0.
             ELSE
                 ASSIGN aux_vlavence[3] = crapepr.vlpreemp
                        aux_vlvenc180   = aux_vlvenc180 - aux_vlavence[3].
          END.

      IF  aux_vlvenc180   > 0 THEN 
          ASSIGN  aux_vlavence[4] =  aux_vlvenc180.
            
      IF  aux_vlvenc360   > 0 THEN 
          ASSIGN aux_vlavence[5] =  aux_vlvenc360.
 
      IF  aux_vlvenc999 > 0 THEN
          DO:
             IF  aux_vlvenc999 < (crapepr.vlpreemp * 12) THEN
                 ASSIGN aux_vlavence[6]  = aux_vlvenc999
                        aux_vlvenc999    = 0.
             ELSE
                 ASSIGN aux_vlavence[6]  = crapepr.vlpreemp * 12
                        aux_vlvenc999    = aux_vlvenc999 - aux_vlavence[6].
          END.

      IF  aux_vlvenc999 > 0 THEN
          DO:
             IF  aux_vlvenc999 < (crapepr.vlpreemp * 12) THEN
                 ASSIGN aux_vlavence[7] = aux_vlvenc999
                        aux_vlvenc999   = 0.
             ELSE
                 ASSIGN aux_vlavence[7]  = crapepr.vlpreemp * 12
                        aux_vlvenc999   =  aux_vlvenc999 - aux_vlavence[7].
          END.
      
      IF  aux_vlvenc999 > 0 THEN
          DO:
             IF  aux_vlvenc999 < (crapepr.vlpreemp * 12) THEN
                 ASSIGN aux_vlavence[8] = aux_vlvenc999
                        aux_vlvenc999   = 0.
             ELSE
                 ASSIGN aux_vlavence[8] = crapepr.vlpreemp * 12
                        aux_vlvenc999   =  aux_vlvenc999 - aux_vlavence[8].
          END.

      IF  aux_vlvenc999 > 0 THEN
          DO:
             IF  aux_vlvenc999 < (crapepr.vlpreemp * 12) THEN
                 ASSIGN aux_vlavence[9] = aux_vlvenc999
                        aux_vlvenc999   = 0.
             ELSE
                 ASSIGN aux_vlavence[9] = crapepr.vlpreemp * 12
                        aux_vlvenc999   =  aux_vlvenc999 - aux_vlavence[9].
          END.
                                                                        
      IF  aux_vlvenc999 > 0 THEN
          DO:
            IF  aux_vlvenc999 < (crapepr.vlpreemp * 120) THEN
                ASSIGN aux_vlavence[10] = aux_vlvenc999
                       aux_vlvenc999    = 0.
            ELSE
                ASSIGN aux_vlavence[10] = crapepr.vlpreemp * 120
                       aux_vlvenc999    = aux_vlvenc999 - aux_vlavence[10].
          END.
      IF  aux_vlvenc999 > 0 THEN
          ASSIGN aux_vlavence[11] = aux_vlvenc999.

END PROCEDURE.

PROCEDURE gera_vencidos:
                                                                  
    DEF VAR aux_divid015  AS DEC NO-UNDO.
    DEF VAR aux_divid030  AS DEC NO-UNDO.
    DEF VAR aux_divid060  AS DEC NO-UNDO.
    DEF VAR aux_divid090  AS DEC NO-UNDO.
    DEF VAR aux_divid120  AS DEC NO-UNDO.
    DEF VAR aux_divid150  AS DEC NO-UNDO.
    DEF VAR aux_divid180  AS DEC NO-UNDO.
    DEF VAR aux_divid240  AS DEC NO-UNDO.
    DEF VAR aux_divid300  AS DEC NO-UNDO.
    DEF VAR aux_divid360  AS DEC NO-UNDO.
    DEF VAR aux_divid540  AS DEC NO-UNDO.
    DEF VAR aux_divid9999 AS DEC NO-UNDO.

      IF  aux_vldivi180 = 0 THEN
          DO:
      
             IF  aux_vldivi060    > 0    AND
                 crapris.qtdiaatr <= 14 THEN
                 DO:
                   IF  aux_vldivi060  < crapepr.vlpreemp  THEN
                       ASSIGN aux_vlvencid[1] = aux_vldivi060    /* 15 dias */
                              aux_vldivi060   = 0.
                   ELSE
                       ASSIGN aux_vlvencid[1] = crapepr.vlpreemp
                              aux_vldivi060 =  aux_vldivi060 - aux_vlvencid[1].
                 END.

             IF  aux_vldivi060   > 0  AND
                 crapris.qtdiaatr <= 30 THEN
                 DO:
                   IF  aux_vldivi060  < crapepr.vlpreemp   THEN
                       ASSIGN aux_vlvencid[2] = aux_vldivi060   /* 30 dias */
                              aux_vldivi060   = 0.
                   ELSE
                       ASSIGN aux_vlvencid[2] = crapepr.vlpreemp 
                              aux_vldivi060   = aux_vldivi060 - aux_vlvencid[2].
                 END.
          
             IF  aux_vldivi060   > 0 THEN 
                 ASSIGN aux_vlvencid[3] = aux_vldivi060.  /* 60 dias */
          END.
      ELSE
          DO:
             IF  aux_vldivi060   > 0 THEN
                 DO:
                   IF  aux_vldivi060  < crapepr.vlpreemp   THEN
                       ASSIGN aux_vlvencid[3] = aux_vldivi060 /* 60 dias */   
                              aux_vldivi060    = 0.
                   ELSE
                       ASSIGN aux_vlvencid[3]  = crapepr.vlpreemp 
                              aux_vldivi060 = aux_vldivi060 - aux_vlvencid[3].
                 END.
          
             IF  aux_vldivi060   > 0 THEN
                 DO:
                    IF  aux_vldivi060  < crapepr.vlpreemp   THEN
                        ASSIGN aux_vlvencid[2] = aux_vldivi060  /* 30 dias */ 
                               aux_vldivi060   = 0.
                    ELSE
                        ASSIGN aux_vlvencid[2]  = crapepr.vlpreemp 
                               aux_vldivi060 = aux_vldivi060 - aux_vlvencid[2].
                 END.
          
             IF  aux_vldivi060   > 0 THEN 
                 ASSIGN aux_vlvencid[1]  = aux_vldivi060.      /* 15 dias */
  
          END.
 
      IF  aux_vldivi180   > 0 THEN
          DO:
            IF  aux_vldivi180  < crapepr.vlpreemp   THEN
                ASSIGN aux_vlvencid[4]  = aux_vldivi180      /* 90 dias */
                       aux_vldivi180    = 0.
            ELSE
                ASSIGN aux_vlvencid[4]  = crapepr.vlpreemp 
                       aux_vldivi180    = aux_vldivi180 - aux_vlvencid[4].
          END.
 
      IF  aux_vldivi180   > 0 THEN
          DO:
             IF  aux_vldivi180  < crapepr.vlpreemp   THEN
                 ASSIGN aux_vlvencid[5]  = aux_vldivi180      /* 120 dias */
                        aux_vldivi180    = 0.
             ELSE
                 ASSIGN aux_vlvencid[5]  = crapepr.vlpreemp 
                        aux_vldivi180    = aux_vldivi180 - aux_vlvencid[5].
          END.

      IF  aux_vldivi180   > 0 THEN
          DO:
             IF  aux_vldivi180  < crapepr.vlpreemp   THEN
                 ASSIGN aux_vlvencid[6]  = aux_vldivi180       /* 150 dias */
                        aux_vldivi180    = 0.
             ELSE
                 ASSIGN aux_vlvencid[6]  = crapepr.vlpreemp 
                        aux_vldivi180    = aux_vldivi180 - aux_vlvencid[6].
          END.
 
      IF  aux_vldivi180   > 0 THEN                            /* 180 dias */
          ASSIGN aux_vlvencid[7]   = aux_vldivi180.  
      
      IF  aux_vldivi360   > 0 THEN
          DO:
             IF  aux_vldivi360  < (crapepr.vlpreemp * 2)  THEN
                 ASSIGN aux_vlvencid[8] = aux_vldivi360         /* 240 dias */
                        aux_vldivi360   = 0.
             ELSE
                 ASSIGN aux_vlvencid[8] = crapepr.vlpreemp * 2 
                        aux_vldivi360   = aux_vldivi360 - aux_vlvencid[8].
          END.

      IF  aux_vldivi360   > 0 THEN
          DO:
            IF  aux_vldivi360  < (crapepr.vlpreemp * 2) THEN    /* 300 dias */
                ASSIGN aux_vlvencid[9]  = aux_vldivi360   
                       aux_vldivi360    = 0.
            ELSE
                ASSIGN aux_vlvencid[9]  = crapepr.vlpreemp  * 2
                       aux_vldivi360    = aux_vldivi360 - aux_vlvencid[9].
          END.
 
      IF  aux_vldivi360   > 0 THEN 
          ASSIGN aux_vlvencid[10] = aux_vldivi360.               /* 360 dias */
     
      IF  aux_vldivi999   > 0 THEN 
          DO:
             IF  aux_vldivi999  < (crapepr.vlpreemp * 6) THEN
                 ASSIGN aux_vlvencid[11]  = aux_vldivi999       /* 540 dias */
                        aux_vldivi999     = 0.
             ELSE
                 ASSIGN aux_vlvencid[11]  = (crapepr.vlpreemp * 6)
                        aux_vldivi999     = aux_vldivi999 - aux_vlvencid[11].
          END.
 
      IF  aux_vldivi999 > 0 THEN
          ASSIGN aux_vlvencid[12] = aux_vldivi999.
          
END PROCEDURE.

PROCEDURE grava_crapris_3010:

     ASSIGN aux_rsvec180 = 0 
            aux_rsvec360 = 0
            aux_rsvec999 = 0
            aux_rsdiv060 = 0 
            aux_rsdiv180 = 0
            aux_rsdiv360 = 0
            aux_rsdiv999 = 0 
            aux_rsprjano = 0 
            aux_rsprjaan = 0
            aux_rsprjant = 0.

    IF  crapvri.cdvencto  >= 110 AND
        crapvri.cdvencto  <= 140 THEN
        ASSIGN aux_rsvec180 = crapvri.vldivida.
    ELSE
    IF  crapvri.cdvencto  = 150 THEN
        ASSIGN aux_rsvec360 =  crapvri.vldivida.
    ELSE
    IF  crapvri.cdvencto   > 150 AND
        crapvri.cdvencto  <= 199 THEN
        ASSIGN aux_rsvec999 = crapvri.vldivida.
    ELSE
    IF  crapvri.cdvencto  >= 205 AND
        crapvri.cdvencto  <= 220 THEN
        ASSIGN aux_rsdiv060 =  crapvri.vldivida.
    ELSE
    IF  crapvri.cdvencto  >= 230 AND
        crapvri.cdvencto  <= 250 THEN
        ASSIGN aux_rsdiv180 =  crapvri.vldivida.
    ELSE
    IF  crapvri.cdvencto  >= 255 AND
        crapvri.cdvencto  <= 270 THEN
        ASSIGN aux_rsdiv360 =  crapvri.vldivida.
    ELSE
    IF  crapvri.cdvencto  >= 280 AND
        crapvri.cdvencto  <= 290 THEN
        ASSIGN aux_rsdiv999 =  crapvri.vldivida.
    ELSE
    IF  crapvri.cdvencto = 310 THEN
        ASSIGN aux_rsprjano  = crapvri.vldivida.
    ELSE
    IF  crapvri.cdvencto = 320 THEN
        ASSIGN aux_rsprjaan  = crapvri.vldivida.
    ELSE
        ASSIGN aux_rsprjant = crapvri.vldivida.
 
    IF  crapsld.dtrisclq <> ? THEN
        ASSIGN aux_innivris = 9.
    ELSE
        ASSIGN aux_innivris = 2.
        
    FIND crapris WHERE crapris.cdcooper = glb_cdcooper      AND
                       crapris.dtrefere = aux_dtrefere      AND
                       crapris.nrdconta = crapass.nrdconta  AND
                       crapris.innivris = aux_innivris      AND  
                       crapris.inddocto = 0
                       EXCLUSIVE-LOCK NO-ERROR.
         
    IF  NOT AVAIL crapris THEN
        DO:
           CREATE crapris.
           ASSIGN crapris.nrdconta = crapass.nrdconta
                  crapris.dtrefere = aux_dtrefere
                  crapris.innivris = aux_innivris
                  crapris.inindris = aux_innivris
                  crapris.qtdiaatr = 0
                  crapris.nrcpfcgc = crapass.nrcpfcgc
                  crapris.inpessoa = crapass.inpessoa  
                  crapris.cdcooper = glb_cdcooper.
           VALIDATE crapris.
        END.

    ASSIGN crapris.vldivida = crapris.vldivida + crapvri.vldivida 
           crapris.vlvec180 = crapris.vlvec180 + aux_rsvec180
           crapris.vlvec360 = crapris.vlvec360 + aux_rsvec360
           crapris.vlvec999 = crapris.vlvec999 + aux_rsvec999
           crapris.vldiv060 = crapris.vldiv060 + aux_rsdiv060
           crapris.vldiv180 = crapris.vldiv180 + aux_rsdiv180
           crapris.vldiv360 = crapris.vldiv360 + aux_rsdiv360
           crapris.vldiv999 = crapris.vldiv999 + aux_rsdiv999
           crapris.vlprjano = crapris.vlprjano + aux_rsprjano
           crapris.vlprjaan = crapris.vlprjaan + aux_rsprjaan
           crapris.vlprjant = crapris.vlprjant + aux_rsprjant.
    
    IF  crapris.vlprjano <> 0 OR     /* Se prejuizo, obrigatorio risco H */
        crapris.vlprjaan <> 0 OR
        crapris.vlprjant <> 0 OR
        crapris.vlprjm60 <> 0 THEN
        ASSIGN crapris.innivris = 9
               crapris.inindris = 9.
    
END PROCEDURE.

PROCEDURE efetua_arrasto:
    
    DEF VAR aux_dtdrisco    AS  DATE                               NO-UNDO.

    FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper  AND
                           crapris.dtrefere = aux_dtrefere  EXCLUSIVE-LOCK:
                           
        ASSIGN crapris.innivori = crapris.innivris.

        /***** Verifica a Data do Risco *****/  
        FIND LAST crabris WHERE  crabris.cdcooper = crapris.cdcooper AND
                                  crabris.nrdconta = crapris.nrdconta AND
                                  crabris.dtrefere < aux_dtrefere     AND
                                  crabris.inddocto = 1                
                                  NO-LOCK NO-ERROR.
        
        IF  AVAIL crabris THEN
            DO: 
                IF  crabris.dtrefere <> glb_dtultdma     OR 
                   (crabris.innivris <> crapris.innivris AND  
                    crapris.innivris <> 10)              THEN
                    ASSIGN crapris.dtdrisco = aux_dtrefere.
                ELSE
                    ASSIGN crapris.dtdrisco = crabris.dtdrisco.
            END.
        ELSE 
            ASSIGN crapris.dtdrisco = aux_dtrefere.    
                
        RUN atualiza_risco_crapass.   /* Atualizar todos */ 
    END.
    
    FOR EACH crapris WHERE 
             crapris.cdcooper = glb_cdcooper    AND
             crapris.dtrefere = aux_dtrefere    AND
             crapris.inddocto = 1               AND    /* Doctos 3020/3030 */ 
             crapris.vldivida > aux_vlr_arrasto   
             BREAK BY crapris.nrdconta
                      BY crapris.innivris desc:
    
        IF   FIRST-OF(crapris.nrdconta) THEN      
             DO:
                ASSIGN aux_innivris = crapris.innivris  /* Nivel mais alto */ 
                       aux_dtdrisco = crapris.dtdrisco.
             END.

       IF  aux_innivris     =  10 AND
           crapris.innivris <> 10 THEN
           ASSIGN crapris.innivris = 9   /* Nao jogar p/prejuizo, prov.100 */
                  crapris.inindris = 9.
       ELSE
           ASSIGN crapris.innivris = aux_innivris
                  crapris.inindris = aux_innivris.
                                                        
       ASSIGN crapris.dtdrisco = aux_dtdrisco.

       IF  FIRST-OF(crapris.nrdconta) THEN
           DO:    
              RUN atualiza_risco_crapass.  
           END.
              
       FOR EACH crapvri WHERE crapvri.cdcooper = glb_cdcooper       AND
                              crapvri.nrdconta  = crapris.nrdconta  AND
                              crapvri.dtrefere  = crapris.dtrefere  AND
                              crapvri.innivris  = crapris.innivori  AND
                              crapvri.cdmodali  = crapris.cdmodali  AND
                              crapvri.nrctremp  = crapris.nrctremp  AND 
                              crapvri.nrseqctr  = crapris.nrseqctr 
                              EXCLUSIVE-LOCK    :

           IF  crapvri.cdvencto <> 310  AND   /* Prejuizo 12 meses */
               crapvri.cdvencto <> 320  AND   /* Prejuizo +12M ate 48M */
               crapvri.cdvencto <> 330  AND   /* Prejuizo +48M ate 60M*/
               crapvri.innivris <> 10   AND  
               crapris.innivris  = 10   THEN   /* Sera prejuizo */
               DO:
            
                  IF  crapvri.cdvencto <= 150   OR  /* Vencer - 360 dias */
                     (crapvri.cdvencto >= 205   AND  /* Vencidos  - 360 dias */
                      crapvri.cdvencto <= 270)  THEN
                      ASSIGN aux_novo_vencto = 310.   /* Prej. 12 meses */
                  ELSE
                  IF  (crapvri.cdvencto >= 160  AND
                       crapvri.cdvencto <= 170) OR
                       crapvri.cdvencto = 280   THEN 
                       ASSIGN aux_novo_vencto = 320. /* Prej. +12M ate 48m*/                     ELSE
                      ASSIGN aux_novo_vencto = 330. /* Prej. +48M */  
                   RUN lista_novos_prejuizos.
            
                  ASSIGN crapvri.cdvencto = aux_novo_vencto.
            END.       
           
           ASSIGN crapvri.innivris = crapris.innivris.
       END.
    
    END.
            
    /* Efetuar arrasto - DOCTO 3010 */  
    FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper  AND
                           crapris.dtrefere = aux_dtrefere  AND
                           crapris.inddocto = 1             AND
                           crapris.innivris < 10            NO-LOCK:
 
        FOR EACH crabris WHERE crabris.cdcooper = glb_cdcooper      AND
                               crabris.dtrefere = crapris.dtrefere  AND
                               crabris.nrdconta = crapris.nrdconta 
                               EXCLUSIVE-LOCK:
                               
            IF   crabris.inddocto = 0 THEN 
                 DO:
                    IF  crapris.innivris > crabris.innivris THEN
                        ASSIGN crabris.innivris = crapris.innivris
                               crabris.inindris = crapris.inindris.
                 END.
        END.
    END.    
   /*-----------------------------------------*/
    
    FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper  AND
                           crapris.dtrefere = aux_dtrefere  AND
                           crapris.inddocto = 1             AND
                           crapris.cdorigem = 3             AND
                           (crapris.cdmodali = 0299 OR 
                            crapris.cdmodali = 0499) : 
                            /* Contratos de Emprestimo/Financiamento*/
        
        FIND crawepr WHERE crawepr.cdcooper = glb_cdcooper      AND
                           crawepr.nrdconta = crapris.nrdconta  AND
                           crawepr.nrctremp = crapris.nrctremp  
                           EXCLUSIVE-LOCK NO-ERROR.
                           
        IF  AVAIL crawepr THEN
            DO:
               IF  crapris.innivris = 1 THEN
                   ASSIGN crawepr.dsnivcal = "AA".
               ELSE
               IF  crapris.innivris = 2 THEN
                   ASSIGN crawepr.dsnivcal = "A".
               ELSE
               IF  crapris.innivris = 3 THEN
                   ASSIGN crawepr.dsnivcal = "B".
               ELSE
               IF  crapris.innivris = 4 THEN
                   ASSIGN crawepr.dsnivcal = "C".
               ELSE
               IF  crapris.innivris = 5 THEN
                   ASSIGN crawepr.dsnivcal = "D".
               ELSE
               IF  crapris.innivris = 6 THEN
                   ASSIGN crawepr.dsnivcal = "E".
               ELSE
               IF  crapris.innivris = 7 THEN
                   ASSIGN crawepr.dsnivcal = "F".
               ELSE
               IF  crapris.innivris = 8 THEN
                   ASSIGN crawepr.dsnivcal = "G".
               ELSE
               IF  crapris.innivris = 9 THEN
                   ASSIGN crawepr.dsnivcal = "H".
               ELSE             
               IF  crapris.innivris = 10 THEN
                   ASSIGN crawepr.dsnivcal = "HH".
            END.   
        
        RELEASE crawepr.
        
    END.   /* for each */

END PROCEDURE.

PROCEDURE lista_novos_prejuizos:
   
    DISP STREAM str_1
                crapris.nrdconta
                crapris.cdmodali
                crapris.nrctremp
                crapris.innivori
                crapris.innivris
                crapvri.cdvencto
                aux_novo_vencto
                crapvri.vldivida
                WITH FRAME f_preju_risco.
    DOWN STREAM str_1 WITH FRAME f_preju_risco.

END PROCEDURE.

PROCEDURE converte_risco_alfa:

    IF  aux_risco_char = "AA" THEN
        ASSIGN aux_risco_num = 1.
    ELSE
    IF  aux_risco_char = "A" THEN
        ASSIGN aux_risco_num = 2.
    ELSE 
    IF  aux_risco_char = "B" THEN
        ASSIGN aux_risco_num = 3.
    ELSE
    IF  aux_risco_char = "C" THEN
        ASSIGN aux_risco_num = 4.
    ELSE
    IF  aux_risco_char = "D" THEN
        ASSIGN aux_risco_num = 5.
    ELSE
    IF  aux_risco_char = "E" THEN
        ASSIGN aux_risco_num = 6.
    ELSE
    IF  aux_risco_char = "F" THEN
        ASSIGN aux_risco_num = 7.
    ELSE
    IF  aux_risco_char = "G" THEN
        ASSIGN aux_risco_num = 8.
    ELSE
    IF  aux_risco_char = "H" THEN
        ASSIGN aux_risco_num = 9.
    ELSE
    IF  aux_risco_char = "HH" THEN
        ASSIGN aux_risco_num = 10.
    
END PROCEDURE.    

PROCEDURE atualiza_risco_crapass:

     IF  glb_cdprogra = 'crps310' THEN 
         DO:
            FIND crabass WHERE 
                 crabass.cdcooper = glb_cdcooper     AND
                 crabass.nrdconta = crapris.nrdconta 
                 EXCLUSIVE-LOCK NO-ERROR.
                        
            IF  AVAIL crabass THEN
                DO:
                   IF  crapris.innivris = 1 THEN
                       ASSIGN crabass.dsnivris = "AA".
                   ELSE
                   IF  crapris.innivris = 2 THEN
                       ASSIGN crabass.dsnivris = "A".
                   ELSE
                   IF  crapris.innivris = 3 THEN
                       ASSIGN crabass.dsnivris = "B".
                   ELSE
                   IF  crapris.innivris = 4 THEN
                       ASSIGN crabass.dsnivris = "C".
                   ELSE
                   IF  crapris.innivris = 5 THEN
                       ASSIGN crabass.dsnivris = "D".
                   ELSE
                   IF  crapris.innivris = 6 THEN
                       ASSIGN crabass.dsnivris = "E".
                   ELSE
                   IF  crapris.innivris = 7 THEN
                       ASSIGN crabass.dsnivris = "F".
                   ELSE
                   IF  crapris.innivris = 8 THEN
                       ASSIGN crabass.dsnivris = "G".
                   ELSE
                   IF  crapris.innivris = 9 THEN
                       ASSIGN crabass.dsnivris = "H".
                   ELSE             
                   IF  crapris.innivris = 10 THEN
                       ASSIGN crabass.dsnivris = "HH".
                END.   
            RELEASE crabass.
         END.

END PROCEDURE.

PROCEDURE calcula_juros_emp_60dias:

    DEF VAR aux_vldjdmes AS DECI                                     NO-UNDO.
    DEF VAR aux_diascalc AS INTE                                     NO-UNDO.
    DEF VAR aux_dtinicio AS DATE                                     NO-UNDO.

    
    EMPTY TEMP-TABLE tt-vencto.
    
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 230
           tt-vencto.dias     = 90.
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 240
           tt-vencto.dias     = 120.
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 245
           tt-vencto.dias     = 150.
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 250
           tt-vencto.dias     = 180.
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 255
           tt-vencto.dias     = 240.
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 260
           tt-vencto.dias     = 300.
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 270
           tt-vencto.dias     = 360.
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 280
           tt-vencto.dias     = 540.
    CREATE tt-vencto.
    ASSIGN tt-vencto.cdvencto = 290
           tt-vencto.dias     = 540.

    FOR EACH crapris WHERE crapris.cdcooper = glb_cdcooper AND
                           crapris.dtrefere = aux_dtrefere AND 
                           crapris.inddocto = 1            AND    
                          (crapris.cdmodali = 299 OR /* Empr.  */
                           crapris.cdmodali = 499)   /* Financ.*/    
                           NO-LOCK,      

        FIRST crapepr WHERE crapepr.cdcooper = crapris.cdcooper AND
                            crapepr.nrdconta = crapris.nrdconta AND
                            crapepr.nrctremp = crapris.nrctremp AND
                            crapepr.tpemprst = 0 
                            NO-LOCK BREAK BY crapris.nrdconta
                                             BY crapris.nrctremp
                                                BY crapris.nrseqctr:

        FIND LAST crapvri WHERE crapvri.cdcooper  = crapris.cdcooper AND
                                crapvri.nrdconta  = crapris.nrdconta AND
                                crapvri.dtrefere  = crapris.dtrefere AND
                                crapvri.innivris  = crapris.innivris AND
                                crapvri.cdmodali  = crapris.cdmodali AND
                                crapvri.nrctremp  = crapris.nrctremp AND 
                                crapvri.nrseqctr  = crapris.nrseqctr AND 
                                crapvri.cdvencto >= 230              AND
                                crapvri.cdvencto <= 290 
                                NO-LOCK NO-ERROR.
    
        IF   NOT AVAIL crapvri  THEN
             NEXT.

        IF   crapris.cdmodali = 299   THEN
             ASSIGN aux_dtinicio = 08/01/2010.
        ELSE
             ASSIGN aux_dtinicio = 10/01/2011.

        FIND tt-vencto WHERE tt-vencto.cdvencto = crapvri.cdvencto
                             NO-LOCK NO-ERROR.

        /*  calculo de dias para acima de 540 dias - codigo 290 */
        IF  crapvri.cdvencto = 290  THEN
            DO:
                ASSIGN aux_diascalc = crapris.qtdiaatr - 60.
             END.
        ELSE
        IF  tt-vencto.dias < crapris.qtdiaatr  THEN
            DO:
                ASSIGN aux_diascalc = tt-vencto.dias - 60.
            END.
        ELSE
            DO:
                ASSIGN aux_diascalc = crapris.qtdiaatr - 60.
            END.
              
        ASSIGN aux_vldjdmes = 0.
        
        /* Buscar os registros de emprestimos a partir da data calculada e que
           esta data seja maior que a de inicio da reversao - 01/08/2010 */
        FOR EACH craplem WHERE craplem.cdcooper = crapris.cdcooper   AND
                               craplem.nrdconta = crapris.nrdconta   AND
                               craplem.dtmvtolt >= aux_dtrefere - aux_diascalc
                               AND            
                               craplem.dtmvtolt >= aux_dtinicio      AND
                               craplem.dtmvtolt <= aux_dtrefere           
                               AND                        
                               craplem.cdhistor = 98                 AND
                               craplem.nrdocmto = crapris.nrctremp   NO-LOCK:
                               
            ASSIGN aux_vldjdmes = aux_vldjdmes + craplem.vllanmto.

        END.                            
                                        
        RUN normaliza_jurosa60(INPUT crapris.cdcooper,
                               INPUT crapris.nrdconta,
                               INPUT crapris.dtrefere,
                               INPUT crapris.innivris,
                               INPUT crapris.cdmodali,  
                               INPUT crapris.nrctremp,    
                               INPUT crapris.nrseqctr,
                               INPUT-OUTPUT aux_vldjdmes).


        RUN grava-juros-mes (INPUT ROWID(crapris),
                             INPUT aux_vldjdmes).

        IF   RETURN-VALUE <> "OK"   THEN
             RETURN "NOK".

    END.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE grava-juros-mes:
    
    DEF INPUT PARAM par_nrdrowid AS ROWID                            NO-UNDO.
    DEF INPUT PARAM par_vldjdmes AS DECI                             NO-UNDO.
    
    DEF VAR aux_contador AS INTE                                     NO-UNDO.
    
    
    DO aux_contador = 1 TO 10:
    
        FIND crapris WHERE ROWID(crapris) = par_nrdrowid       
                           EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
        IF   NOT AVAIL crapris   THEN
             IF   LOCKED crapris   THEN
                  DO:
                       RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                        
                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(crapris),
                        					 INPUT "banco",
                        					 INPUT "crapris",
                        					 OUTPUT par_loginusr,
                        					 OUTPUT par_nmusuari,
                        					 OUTPUT par_dsdevice,
                        					 OUTPUT par_dtconnec,
                        					 OUTPUT par_numipusr).
                        
                        DELETE PROCEDURE h-b1wgen9999.
                        
                        ASSIGN aux_dadosusr = 
                        "077 - Tabela sendo alterada p/ outro terminal.".
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 3 NO-MESSAGE.
                        LEAVE.
                        END.
                        
                        ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                        			  " - " + par_nmusuari + ".".
                        
                        HIDE MESSAGE NO-PAUSE.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        MESSAGE aux_dadosusr.
                        PAUSE 5 NO-MESSAGE.
                        LEAVE.
                        END.
                      NEXT.
                  END.
             ELSE
                  DO:
                      ASSIGN glb_cdcritic = 55.
                      LEAVE.
                  END.
                  
        glb_cdcritic = 0.
        LEAVE.
        
    END.

    IF   glb_cdcritic <> 0   THEN
         RETURN "NOK".

    ASSIGN crapris.vljura60 = par_vldjdmes.  

    RETURN "OK".
END PROCEDURE.

PROCEDURE normaliza_jurosa60:
                                                                        
    DEF INPUT PARAM par_cdcooper    LIKE    crapris.cdcooper    NO-UNDO.
    DEF INPUT PARAM par_nrdconta    LIKE    crapris.nrdconta    NO-UNDO.
    DEF INPUT PARAM par_dtrefere    LIKE    crapris.dtrefere    NO-UNDO.
    DEF INPUT PARAM par_innivris    LIKE    crapris.innivris    NO-UNDO.
    DEF INPUT PARAM par_cdmodali    LIKE    crapris.cdmodali    NO-UNDO.
    DEF INPUT PARAM par_nrctremp    LIKE    crapris.nrctremp    NO-UNDO.
    DEF INPUT PARAM par_nrseqctr    LIKE    crapris.nrseqctr    NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vldjuros AS  DECI                NO-UNDO.


    DEF VAR aux_vldiva60    AS  DECI    INITIAL 0               NO-UNDO.


    FOR EACH b-crapvri WHERE b-crapvri.cdcooper  = par_cdcooper AND
                             b-crapvri.nrdconta  = par_nrdconta AND
                             b-crapvri.dtrefere  = par_dtrefere AND
                             b-crapvri.innivris  = par_innivris AND
                             b-crapvri.cdmodali  = par_cdmodali AND
                             b-crapvri.nrctremp  = par_nrctremp AND 
                             b-crapvri.nrseqctr  = par_nrseqctr AND 
                             b-crapvri.cdvencto >= 230          AND
                             b-crapvri.cdvencto <= 290     NO-LOCK:
    
        ASSIGN aux_vldiva60 = aux_vldiva60 + b-crapvri.vldivida.
    END.

    IF  par_vldjuros >= aux_vldiva60 THEN
        DO:
            IF  (par_vldjuros - aux_vldiva60) > 1 AND aux_vldiva60 > 1 THEN
                ASSIGN par_vldjuros = aux_vldiva60 - 1.
            ELSE
                ASSIGN par_vldjuros = aux_vldiva60 - 0.1.
        END.


    RETURN "OK".
END PROCEDURE.



