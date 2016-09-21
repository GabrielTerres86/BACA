/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-------------------------------------+--------------------------------------+
  | Rotina Progress                     | Rotina Oracle PLSQL                  |
  +-------------------------------------+--------------------------------------+
  | b1wgen0004.p                        | APLI0001                             |   
  | b1wgen0004.provisao_rdc_pos_var     | APLI0001.pc_provisao_rdc_pos_var     |
  | b1wgen0004.provisao_rdc_pos         | APLI0001.pc_provisao_rdc_pos         |
  | b1wgen0004.calctx_poupanca          | APLI0001.pc_calctx_poupanca          |
  | b1wgen0004.extrato_rdc              | APLI0001.pc_extrato_rdc              |
  | b1wgen0004.saldo_rdc_pre            | APLI0001.pc_saldo_rdc_pre            |
  | b1wgen0004.saldo_rdc_pos            | APLI0001.pc_saldo_rdc_pos            |
  | b1wgen0004.saldo_rgt_rdc_pos        | APLI0001.pc_saldo_rgt_rdc_pos        |
  | b1wgen0004.provisao_rdc_pre         | APLI0001.pc_provisao_rdc_pre         |
  | b1wgen0004.acumula_aplicacoes       | APLI0001.pc_acumula_aplicacoes       |
  | b1wgen0004.ajuste_provisao_rdc_pre  | APLI0001.pc_ajuste_provisao_rdc_pre  |
  | b1wgen0004.valor_original_resgatado | APLI0001.pc_valor_original_resgatado |
  | b1wgen0004.rendi_apl_pos_com_resgate| APLI0001.pc_rendi_apl_pos_com_resgate|
  | b1wgen0004.consulta_aplicacoes      | APLI0001.pc_consulta_aplicacoes      |
  | b1wgen0004.saldo-resg-rdca          | APLI0002.pc_saldo_resg_rdca          |
  +-------------------------------------+--------------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/

/*** No RDCPOS, quando provisionar e pagar rendimentos a taxa maxima, esta
     comparando a taxa CDI com a taxa POUPANCA e pagando o que for maior.
     Confirmar com a Tavares a seguinte decisao: usar a poupanca do mes
     anterior. Se sim, ver como proceder quando nao existir o dia. Por
     exemplo 31/06. Procurar rotina que calcule datas para tras. 
     Lembrando que craplap.txaplica = taxa maxima e
                   craplap.txaplmes = taxa minima ***/
/*..............................................................................
    
   Programa: b1wgen0004.p                  
   Autora  : Junior.
   Data    : 12/09/2005                        Ultima atualizacao: 19/12/2014

   Dados referentes ao programa:

   Objetivo  : BO CONSULTA SALDO E EXTRATO DE APLICACOES
               Baseada no programa fontes/impextrda.p.

   Alteracoes:  19/05/2006 - Incluido codigo da cooperativa nas leituras das
                             tebelas (Diego).

                02/10/2006 - Inclusao da variavel aux_vlajtsld (David).
                
                23/05/2007 - Inclusao das rotinas e variaveis para a modalidade
                             de aplicacoes RDC (Evandro).

                04/09/2007 - Melhor leitura do craplap no extrato_rdc (Magui).

                05/09/2007 - Definicoes de temp-tables para include (David).

                10/09/2007 - Utilizar craprda.qtdiauti para carencia nas 
                             aplicacoes RDC (David).
                
                01/10/2007 - Trabalhar com 4 casas na provisao RDCPOS E
                             RDCPRE (Magui).
                             
                09/10/2007 - Incluida procedure provisao_rdc_pos_var (Diego);
                           - Incluidas variaveis rd2_lshistor e rd2_contador
                             para a melhoria de performance (Evandro).
                             
                25/10/2007 - Inclusao da procedures acumula_aplicacoes (Magui).
                 
                26/11/2007 - Procedure saldo_rdc_pos nao esta atualizando
                             o percentual de imposto de renda (Magui).

                07/01/2008 - Acerto no uso das faixas de IR na procedure 
                             consulta-aplicacoes (David).
                             
                07/01/2008 - Calculo de dias em carencia no rdcpos 
                             com erro (Magui).

                18/01/2007 - Ajustes, resgate negativo (Magui).

                15/02/2008 - Resgate total da Cecred nao estava colocando
                             rendimento (Magui).

                01/03/2008 - Nova formula de calculo rdcpos (Magui).

                03/06/2008 - Incluir cdcooper nos FIND's da craphis (David).
                
                04/07/2008 - provisao_rdc_pos_var usar dtfimper com
                             glb_dtmvtopr, d + 1 (Magui).

                07/08/2008 - Taxa do rendi rdcpre com 8 casas (Magui).
                
                19/09/2008 - Ajustes na maneira de pegar o % de IRRF para
                             o RDCPRE e o RDCPOS (Magui).

                04/12/2008 - Correcao no calculo para acumulo de aplicacoes,
                             nao somar quando tiver resgate agendando (David).
                
                08/01/2009 - Quando RDCPRE para calcular carencia usa-se
                             craprda.qtdiapl (Magui).

                25/05/2009 - Alteracao CDOPERAD (Kbase).

                10/07/2009 - Se taxa RDCPOS for menor que a POUPANCA,
                             usar POUPANCA (Magui).
                             
                12/08/2009 - Na procedure acumula_aplicacoes, alterar o parame-
                             tro p-txaplmes para receber crapftx.perapltx
                             somente para RDCPRE (Fernando).
                          
                17/08/2009 - Alteradas as procedures saldo_rdc_pos, 
                             rendi_apl_pos_com_resgate e provisao_rdc_pos para
                             utilizar a taxa da poupanca quando a taxa RDCPOS
                             for menor (Fernando).
                             
                23/09/2009 - Alteradas as procedures saldo_rdc_pos,
                             rendi_apl_pos_com_resgate e provisao_rdc_pos para
                             criticar caso nao encontre a crapmfx (Fernando).
                             
                09/10/2009 - Implementacao para rotina APLICACOES (David).
                
                12/08/2010 - Ajustada procedure acumula_aplicacoes para nao 
                             estourar variaveis do tipo extent (Elton).
                             
                06/10/2010 - Adaptacao da tela LANRDC na BO (David).
                             
                30/10/2010 - No RDCPOS, calculos com a taxa maxima e minimas
                             iguais (Magui).
                             
                26/11/2010 - Ajuste no cancelamento de resgate on-line (David).
                
                30/11/2010 - Foram retiradas algumas procedures desta BO
                             e colocadas na nova BO b1wgen0081.p (Adriano).   
                             (Adriano).

                17/12/2010 - Incluir his 923 e 924 no extrato_rdc,
                             sobreposicao (Magui).

                21/12/2010 - Carregar carrencia na tt-saldo-rdca (David).

                01/08/2011 - Carregar cdoperad, qtdiaapl e qtdiauti na 
                             tt-saldo-rdca ( Gabriel - DB1 ).

                13/09/2011 - Alterado a leitura da tabela craprda para tela
                             impres ( Gabriel - DB1 ).

                23/12/2011 - Obter aplicacoes resgatadas ou sem saldo para tela 
                             ADITIV na procedure consulta-aplicacoes (David) 

                19/03/2012 - Colocado RETURN "OK" nas procedures:
                             - provisao_rdc_pos
                             - provisao_rdc_pre
                             - provisao_rdc_pos_var
                             - rendi_apl_pos_com_resgate
                             - valor_original_resgatado
                             - extrato_rdc
                             Usado EMPTY TEMP-TABLE para limpar as tabelas das 
                             procedures:
                             - saldo_rdc_pos
                             - saldo_rgt_rdc_pos
                             - provisao_rdc_pos_var
                             - rendi_apl_pos_com_resgate
                             - valor_original_resgatado
                             - extrato_rdc
                             - provisao_rdc_pos
                             - acumula_aplicacoes
                             - consulta-aplicacoes
                             - saldo_rdc_pre
                             - provisao_rdc_pre
                             - ajuste_provisao_rdc_pre
                             (Adriano).

                21/08/2012 - consulta-aplicacoes: Inclusao do dsAplic no ELSE
                             do p-origem 1,5 
                           - Retirado "IMPRES" da validacao do p-cdprogra
                             (Guilherme/Supero)
                             
                11/12/2012 - Incluir historicos de migracao (Ze).
                
                27/02/2013 - Ajuste na remuneracao de RDCPOS com taxa 
                             de poupanca (David).  
                             
                19/07/2013 - Ordenacao para o projeto PLSQL (Guilherme).
                
                21/08/2013 - Tratamento para Imunidade Tributaria (Ze).
                
                28/08/2013 - Alterada a procedure 'consulta-aplicacoes' para
                             trazer nome do produto conforme nova regra (Lucas).
                             
                24/10/2013 - Ajuste no tratamento Imund. Tributaria (Ze).
                
                29/10/2013 - Incluir validação de handle na chamada da 
                             b1wgen0159 (Lucas R.).
                              
                27/11/2013 - Alterar posicao do TRUNCATE no calculo da variavel
                             par_vlbasrgt, procedure valor_original_resgatado
                             (David).
                
                13/02/2014 - Ajuste p/ calculo de rendimento de poupanca conforme
                             nova regra (Jean Michel).
                
                24/06/2014 - Retirada leitura da craptab e incluida data de
                             liberacao do projeto novo indexador de poupanca
                             fixa - 01/07/2014 (Jean Michel).
                             
                 17/07/2014 - Ajuste feito na procedure acumula_aplicacoes para
                              os novos produtos de captação. (Jean Michel)
                              
                 26/08/2014 - Substituido as 2 chamadas da procedure
                              consulta-aplicacoes pela procedure 
                              obtem-dados-aplicacoes da BO b1wgen0081.p.
                              (Jean Michel)
                              
                 19/12/2014 - Retirar procedure acumula_aplicacoes (David).
                              
.............................................................................*/
 
{ sistema/generico/includes/b1wgen0001tt.i }                                   
{ sistema/generico/includes/b1wgen0004tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }
           
DEFINE VARIABLE h-b1wgen05         AS HANDLE  NO-UNDO.
DEFINE VARIABLE h-b1wgen0159        AS HANDLE  NO-UNDO.

DEF BUFFER crablap5 FOR craplap.
             
DEF VAR aux_sequen   AS INTE NO-UNDO.
DEF VAR i-cod-erro   AS INTE NO-UNDO.
DEF VAR c-dsc-erro   AS CHAR NO-UNDO.
 
DEF        VAR aux_txmespop AS DECIMAL DECIMALS 6   NO-UNDO.
DEF        VAR aux_txdiapop AS DECIMAL DECIMALS 6   NO-UNDO. 
DEF        VAR aux_dsmsgerr AS CHAR                                  NO-UNDO. 
DEF        VAR aux_sldresga AS DECIMAL                               NO-UNDO.
DEF        VAR aux_ttrenrgt AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlrenrgt AS DECIMAL DECIMALS 8      
          /*  like craprda.vlsdrdca Magui em 27/09/2007 */ NO-UNDO.
DEF        VAR aux_ajtirrgt AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlrentot AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlrendim AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vldperda AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlsdrdca AS DECIMAL DECIMALS 8                    NO-UNDO.

DEF        VAR aux_vlsdrdat AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlsdresg AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlprovis AS DECIMAL DECIMALS 8                    NO-UNDO.
  
DEF        VAR aux_vlajuste AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vllan117 AS DECIMAL                               NO-UNDO.
DEF        VAR aux_txaplica AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_txaplmes AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_txapllap AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlrdirrf AS DECIMAL                               NO-UNDO.
DEF        VAR aux_perirrgt AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlrrgtot AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlirftot AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlrendmm AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlrvtfim AS DECIMAL                               NO-UNDO.
DEF        VAR aux_occ      AS INTE                                  NO-UNDO.

DEF        VAR aux_dtcalajt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR aux_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR aux_dtdolote AS DATE                                  NO-UNDO.
DEF        VAR aux_dtultdia AS DATE                                  NO-UNDO.
DEF        VAR aux_dtrefere AS DATE                                  NO-UNDO.
DEF        VAR aux_dtinitax AS DATE                                  NO-UNDO.
DEF        VAR aux_dtfimtax AS DATE                                  NO-UNDO.
DEF        VAR aux_dtinipop AS DATE                                  NO-UNDO. 

DEF        VAR aux_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR aux_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR aux_nrdolote AS INT                                   NO-UNDO.
DEF        VAR aux_cdhistor AS INT                                   NO-UNDO.
DEF        VAR aux_vlajtsld AS DEC                                   NO-UNDO.
  
DEF        VAR aux_flglanca AS LOGICAL                               NO-UNDO.
DEF        VAR aux_vlabcpmf AS DECIMAL                               NO-UNDO.
DEF        VAR aux_flgncalc AS LOGICAL                               NO-UNDO.
DEF        VAR aux_sldcaren AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR dup_vlsdrdca AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR dup_dtcalcul AS DATE                                  NO-UNDO.
DEF        VAR dup_dtmvtolt AS DATE                                  NO-UNDO.
DEF        VAR dup_vlrentot AS DECIMAL DECIMALS 8                    NO-UNDO.


DEF        VAR aux_vlrgtper AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlrenper AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_renrgper AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_nrctaapl AS INTEGER FORMAT "zzzz,zzz,9"           NO-UNDO.
DEF        VAR aux_nraplres AS INTEGER FORMAT "zzz,zz9"              NO-UNDO.
DEF        VAR aux_vlsldapl AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_sldpresg AS DECIMAL DECIMALS 8                    NO-UNDO.

DEF        VAR aux_dtregapl AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR aux_ttajtlct AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_ttpercrg AS DECIMAL                               NO-UNDO.
DEF        VAR aux_trergtaj AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_perirtab AS DECIMAL     EXTENT 99                 NO-UNDO.
DEF        VAR aux_indebcre AS CHAR                                  NO-UNDO.
DEF        VAR aux_vlsldrdc AS DECI                                  NO-UNDO.

DEF        VAR aux_lsoperad AS CHAR                                  NO-UNDO.
DEF        VAR aux_listahis AS CHAR                                  NO-UNDO.
DEF        VAR aux_dshistor AS CHAR                                  NO-UNDO.
DEF        VAR aux_vlstotal AS DECIMAL                               NO-UNDO.
DEF        VAR aux_dsaplica AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgslneg AS LOGICAL                               NO-UNDO.
DEF        VAR aux_vlrenacu AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_vlslajir AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_pcajsren AS DECIMAL                               NO-UNDO.
DEF        VAR aux_nrmeses  AS INTEGER                               NO-UNDO.
DEF        VAR aux_nrdias   AS INTEGER                               NO-UNDO.
DEF        VAR aux_perirapl AS DECIMAL                               NO-UNDO.
DEF        VAR aux_vlrenreg AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_dtiniapl AS DATE FORMAT "99/99/9999"              NO-UNDO.
DEF        VAR aux_cdhisren LIKE craplap.cdhistor                    NO-UNDO.
DEF        VAR aux_cdhisajt LIKE craplap.cdhistor                    NO-UNDO.
DEF        VAR aux_vldajtir AS DECIMAL DECIMALS 8                    NO-UNDO. 
DEF        VAR aux_sldrgttt AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR aux_flgimune AS LOGICAL                               NO-UNDO.


DEF        VAR rd2_vlrentot AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_vlrendim AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_vlsdrdca AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_vlprovis AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_vlajuste AS DECIMAL                               NO-UNDO.
DEF        VAR rd2_vllan178 AS DECIMAL                               NO-UNDO.
DEF        VAR rd2_vllan180 AS DECIMAL                               NO-UNDO.
DEF        VAR rd2_txaplica AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_txaplmes AS DECIMAL DECIMALS 8                    NO-UNDO.
DEF        VAR rd2_dtcalcul AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_dtmvtolt AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_dtdolote AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_dtultdia AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_dtrefere AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_dtrefant AS DATE    FORMAT "99/99/9999"           NO-UNDO.
DEF        VAR rd2_cdagenci AS INT     INIT 1                        NO-UNDO.
DEF        VAR rd2_cdbccxlt AS INT     INIT 100                      NO-UNDO.
DEF        VAR rd2_nrdolote AS INT                                   NO-UNDO.
DEF        VAR rd2_cdhistor AS INT                                   NO-UNDO.
DEF        VAR rd2_nrdiacal AS INT                                   NO-UNDO.
DEF        VAR rd2_nrdiames AS INT                                   NO-UNDO.
DEF        VAR rd2_flgentra AS LOGICAL                               NO-UNDO.
DEF        VAR rd2_lshistor AS CHAR                                  NO-UNDO.
DEF        VAR rd2_contador AS INT                                   NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                           NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

/*** Carrega tabela de percentuais de IRRF ***/
DEF VAR aux_qtdfaxir AS INTE        FORMAT "z9"         NO-UNDO.
DEF VAR aux_qtmestab AS INTE        EXTENT 99           NO-UNDO. 
DEF VAR aux_cartaxas AS INTE                            NO-UNDO.
DEF VAR aux_vllidtab AS CHAR                            NO-UNDO.
DEF VAR aux_qtdiatab AS INTE        EXTENT 99           NO-UNDO.

DEF VAR aux_flgbo159 AS LOG                             NO-UNDO.

/** Tabelas para registro de log **/
DEF TEMP-TABLE tt-aplicacao-ant NO-UNDO
    FIELD cdagenci LIKE craprda.cdagenci
    FIELD cdbccxlt LIKE craprda.cdbccxlt
    FIELD nrdolote LIKE craprda.nrdolote
    FIELD nrseqdig LIKE craplap.nrseqdig
    FIELD tpaplica LIKE craprda.tpaplica
    FIELD nraplica LIKE craprda.nraplica
    FIELD vlaplica LIKE craprda.vlaplica
    FIELD qtdiaapl LIKE craprda.qtdiaapl
    FIELD dtvencto LIKE craprda.dtvencto
    FIELD qtdiauti LIKE craprda.qtdiauti
    FIELD txaplica LIKE craplap.txaplica
    FIELD txaplmes LIKE craplap.txaplmes
    FIELD flgdebci LIKE craprda.flgdebci.
DEF TEMP-TABLE tt-aplicacao-new NO-UNDO LIKE tt-aplicacao-ant.



/*............................................................................*/


PROCEDURE consulta-aplicacoes.

    DEF INPUT  PARAM p-cdcooper      AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-cod-agencia   AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-nro-caixa     AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-cod-operador  AS CHAR                        NO-UNDO.  
    DEF INPUT  PARAM p-nro-conta     AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-nro-aplicacao AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-tip-aplicacao AS INTE                        NO-UNDO.
    DEF INPUT  PARAM p-data-inicio   AS DATE                        NO-UNDO.
    DEF INPUT  PARAM p-data-fim      AS DATE                        NO-UNDO.
    DEF INPUT  PARAM p-cdprogra      AS CHAR                        NO-UNDO.    
    DEF INPUT  PARAM p-origem        AS INTE                        NO-UNDO.
                                       
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    DEF OUTPUT PARAM TABLE FOR tt-saldo-rdca.
    
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

    RUN STORED-PROCEDURE pc_consulta_aplicacoes_wt 
        aux_handproc = PROC-HANDLE NO-ERROR
                         (INPUT p-cdcooper, 
                          INPUT p-cod-agencia,   
                          INPUT p-nro-caixa,     
                          INPUT p-nro-conta,     
                          INPUT p-nro-aplicacao, 
                          INPUT p-tip-aplicacao, 
                          INPUT p-data-inicio,   
                          INPUT p-data-fim,      
                          INPUT p-cdprogra,      
                          INPUT p-origem,        
                          OUTPUT 0,               
                          OUTPUT "").
    
    CLOSE STORED-PROC pc_consulta_aplicacoes_wt 
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = ""
           aux_cdcritic = pc_consulta_aplicacoes_wt.pr_cdcritic 
                          WHEN pc_consulta_aplicacoes_wt.pr_cdcritic <> ?
           aux_dscritic = pc_consulta_aplicacoes_wt.pr_dscritic 
                          WHEN pc_consulta_aplicacoes_wt.pr_dscritic <> ?.
        
    IF  aux_cdcritic <> 0   OR
        aux_dscritic <> ""  THEN
    DO:
        CREATE tt-erro.
        ASSIGN tt-erro.cdcritic = aux_cdcritic
               tt-erro.dscritic = aux_dscritic.
        
        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        RETURN "NOK".
        
    END.
    EMPTY TEMP-TABLE tt-saldo-rdca.
    
    { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

    FOR EACH wt_saldo_rdca NO-LOCK:

        CREATE tt-saldo-rdca.
        ASSIGN
        tt-saldo-rdca.dtmvtolt = wt_saldo_rdca.dtmvtolt
        tt-saldo-rdca.nraplica = wt_saldo_rdca.nraplica
        tt-saldo-rdca.dshistor = wt_saldo_rdca.dshistor
        tt-saldo-rdca.nrdocmto = wt_saldo_rdca.nrdocmto
        tt-saldo-rdca.dtvencto = wt_saldo_rdca.dtvencto
        tt-saldo-rdca.indebcre = wt_saldo_rdca.indebcre
        tt-saldo-rdca.vllanmto = wt_saldo_rdca.vllanmto
        tt-saldo-rdca.sldresga = wt_saldo_rdca.sldresga
        tt-saldo-rdca.vlsdrdad = wt_saldo_rdca.vlsdrdad
        tt-saldo-rdca.cddresga = wt_saldo_rdca.cddresga
        tt-saldo-rdca.dtresgat = wt_saldo_rdca.dtresgat
        tt-saldo-rdca.dssitapl = wt_saldo_rdca.dssitapl
        tt-saldo-rdca.txaplmax = wt_saldo_rdca.txaplmax
        tt-saldo-rdca.txaplmin = wt_saldo_rdca.txaplmin
        tt-saldo-rdca.qtdiacar = wt_saldo_rdca.qtdiacar
        tt-saldo-rdca.cdoperad = wt_saldo_rdca.cdoperad
        tt-saldo-rdca.qtdiaapl = wt_saldo_rdca.qtdiaapl
        tt-saldo-rdca.qtdiauti = wt_saldo_rdca.qtdiauti
        tt-saldo-rdca.dsaplica = wt_saldo_rdca.dsaplica
        tt-saldo-rdca.tpaplrdc = wt_saldo_rdca.tpaplrdc
        tt-saldo-rdca.tpaplica = wt_saldo_rdca.tpaplica
        tt-saldo-rdca.vlaplica = wt_saldo_rdca.vlaplica.

    END.
    
    RETURN "OK".

END PROCEDURE.


PROCEDURE saldo-resg-rdca:

    DEF  INPUT PARAM p-cdcooper      AS INTE                        NO-UNDO.
    DEF  INPUT PARAM p-cod-agencia   AS INTE                        NO-UNDO.
    DEF  INPUT PARAM p-nro-caixa     AS INTE                        NO-UNDO.
    DEF  INPUT PARAM p-nro-conta     AS INTE                        NO-UNDO.
    DEF  INPUT PARAM p-nro-aplicacao AS INTE                        NO-UNDO.
    DEF  INPUT PARAM p-cdprogra      AS CHAR                        NO-UNDO.
           
    DEF OUTPUT PARAM p-vlsdrdca      AS DECI DECIMALS 8             NO-UNDO.
    DEF OUTPUT PARAM p-sldpresg      AS DECI DECIMALS 8             NO-UNDO.
                                           
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    EMPTY TEMP-TABLE tt-erro.    

    ASSIGN aux_vllidtab = ""
           aux_qtdfaxir = 0
           aux_qtmestab = 0
           aux_perirtab = 0
           aux_sequen   = 0.
       
    FIND crapcop WHERE crapcop.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
   
    IF  NOT AVAILABLE crapcop  THEN
        DO:
            ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END.
        
    FIND FIRST crapdat WHERE crapdat.cdcooper = p-cdcooper NO-LOCK NO-ERROR.
   
    IF  NOT AVAILABLE crapdat  THEN
        DO:
            ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END. 
 
    FIND craptab WHERE craptab.cdcooper = p-cdcooper   AND
                       craptab.nmsistem = "CRED"       AND   
                       craptab.cdempres = 0            AND
                       craptab.tptabela = "CONFIG"     AND   
                       craptab.cdacesso = "PERCIRRDCA" AND
                       craptab.tpregist = 0            NO-LOCK NO-ERROR.
                   
    DO aux_cartaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):

        ASSIGN aux_vllidtab = ENTRY(aux_cartaxas,craptab.dstextab,";")
               aux_qtdfaxir = aux_qtdfaxir + 1
               aux_qtmestab[aux_qtdfaxir] = DECI(ENTRY(1,aux_vllidtab,"#"))
               aux_perirtab[aux_qtdfaxir] = DECI(ENTRY(2,aux_vllidtab,"#")).
    
    END.

    FIND craprda WHERE craprda.cdcooper = p-cdcooper      AND
                       craprda.nrdconta = p-nro-conta     AND
                       craprda.nraplica = p-nro-aplicacao NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE craprda  THEN
        DO:
            ASSIGN i-cod-erro = 426 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END.
        
    IF  craprda.tpaplica = 3  THEN
        DO:  
            { sistema/generico/includes/b1wgen0004.i } 
        END.
    ELSE
    IF  craprda.tpaplica = 5  THEN
        DO: 
            { sistema/generico/includes/b1wgen0004a.i }
        END.
            
    ASSIGN p-vlsdrdca = aux_vlsdrdca
           p-sldpresg = aux_sldpresg.
    
    RETURN "OK".

END PROCEDURE.


/* =========================================================================
   ================ ROTINAS PARA AS APLICACOES RDC - PRE/POS ===============
   ========================================================================= */

PROCEDURE saldo_rdc_pre:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/




    /* Rotina de calculo do saldo das aplicacoes RDC PRE para resgate
       enxergando as novas aliquotas de imposto de renda.
       Retorna o saldo para resgate no dia do vencimento.
       Se resgatado antes nao recebe nada, saldo em craprda.vlsdrdca.
               
       Observacao: Se a conta e o numero da aplicacao estiverem ZERADOS, o
                   programa fara uma simulacao da aplicacao.
                   O saldo sera o mesmo do craprda.vlsdrdca enquanto a
                   aplicacao estiver em carencia */

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt          NO-UNDO.
    DEF        INPUT PARAM par_dtiniper LIKE craprda.dtiniper          NO-UNDO.
    DEF        INPUT PARAM par_dtfimper LIKE craprda.dtfimper          NO-UNDO.
    DEF        INPUT PARAM par_txaplica AS DEC DECIMALS 8              NO-UNDO.
    DEF        INPUT PARAM par_flggrvir AS LOGICAL                     NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_vlsdrdca AS DECIMAL DECIMALS 4
               /*LIKE craprda.vlsdrdca*/          NO-UNDO.
    DEF       OUTPUT PARAM par_vlrdirrf LIKE craplap.vllanmto          NO-UNDO.
    DEF       OUTPUT PARAM par_perirrgt AS DEC DECIMALS 2              NO-UNDO.
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.
    
    ASSIGN aux_pcajsren = 0       
           aux_nrmeses  = 0
           aux_nrdias   = 0  
           aux_perirapl = 0
           aux_vlrenacu = 0
           aux_vlrentot = 0
           aux_qtdfaxir = 0
           par_vlrdirrf = 0.
     
    EMPTY TEMP-TABLE tt-erro.
 
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE crapdat  THEN
        DO:
            ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END. 
 
     FIND craptab WHERE craptab.nmsistem = "CRED"        AND   
                       craptab.cdempres = 0              AND
                       craptab.tptabela = "CONFIG"       AND   
                       craptab.cdacesso = "PERCIRFRDC"   AND
                       craptab.tpregist = 0              AND
                       craptab.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.
                   
    DO aux_cartaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):
       ASSIGN aux_vllidtab = ENTRY(aux_cartaxas,craptab.dstextab,";")
              aux_qtdfaxir = aux_qtdfaxir + 1
              aux_qtdiatab[aux_qtdfaxir] = DECIMAL(ENTRY(1,aux_vllidtab,"#"))
              aux_perirtab[aux_qtdfaxir] = DECIMAL(ENTRY(2,aux_vllidtab,"#")).
    END.                 

    /* Calcula o saldo de uma aplicacao existente */
    IF   par_nrctaapl <> 0   AND
         par_nraplres <> 0   THEN
         DO:      
             FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                                craprda.nrdconta = par_nrctaapl   AND
                                craprda.nraplica = par_nraplres
                                NO-LOCK NO-ERROR.
                   
             IF   NOT AVAILABLE craprda   THEN                   
                  DO:     
                      ASSIGN i-cod-erro = 426
                             c-dsc-erro = " ".
           
                      {sistema/generico/includes/b1wgen0001.i}

                      RETURN "NOK".
                  END.
         
             /*** Verifica se aplicacao esta em carencia ***/
             IF   craprda.dtvencto >= crapdat.dtmvtolt   AND
                  craprda.dtvencto <= crapdat.dtmvtopr   THEN
                  .
             ELSE     
             IF   par_dtmvtolt - craprda.dtmvtolt < craprda.qtdiaapl   THEN
                  DO:
                      ASSIGN par_vlsdrdca = craprda.vlsdrdca.
                      RETURN "OK".
                  END.
         
             /*** Buscar as taxas contratas ***/
             FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper       AND
                                      craplap.nrdconta = craprda.nrdconta   AND
                                      craplap.nraplica = craprda.nraplica   AND
                                      craplap.dtmvtolt = craprda.dtmvtolt   
                                      NO-LOCK NO-ERROR.
        
             IF   NOT AVAILABLE craplap   THEN  
                  DO:                       
                      ASSIGN i-cod-erro = 90
                             c-dsc-erro = " ".
           
                      {sistema/generico/includes/b1wgen0001.i}

                      RETURN "NOK".
                  END.

             ASSIGN par_txaplica = TRUNCATE(craplap.txaplica / 100,8)
                    par_dtiniper = craprda.dtmvtolt
                    par_dtfimper = craprda.dtvencto
                    par_vlsdrdca = craprda.vlsdrdca.
         END.

    ASSIGN aux_nrdias = par_dtfimper - par_dtiniper.
    IF   aux_nrdias = ?   OR
         aux_nrdias = 0   THEN                   
         DO: 
             ASSIGN i-cod-erro = 840
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}
 
             RETURN "NOK".
         END.
    DO aux_occ = aux_qtdfaxir TO 1 BY -1:
       IF   aux_nrdias > aux_qtdiatab[aux_occ]   THEN
            DO:
                ASSIGN aux_perirapl = aux_perirtab[aux_occ].
                LEAVE.
            END.
    END.        

    IF   aux_perirapl = 0   THEN          
         ASSIGN aux_perirapl = aux_perirtab[4].
    
    IF   aux_perirapl  = 0   AND  
         par_cdcooper <> 3   THEN
         DO:
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
          END.

    DO WHILE par_dtiniper < par_dtfimper:

       DO WHILE TRUE:

          IF   CAN-DO("1,7",STRING(WEEKDAY(par_dtiniper)))    OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                      crapfer.dtferiad = par_dtiniper)   THEN
               DO:
                   par_dtiniper = par_dtiniper + 1.
                   NEXT.
               END.
           
               LEAVE.
       END.  /*  Fim do DO WHILE TRUE  */
   
       IF   par_dtiniper >= par_dtfimper   THEN
            LEAVE.

       ASSIGN aux_vlrendim = TRUNCATE(par_vlsdrdca * par_txaplica,8)
              par_vlsdrdca = par_vlsdrdca + aux_vlrendim 
              aux_vlrentot = aux_vlrentot + aux_vlrendim
              par_dtiniper = par_dtiniper + 1.

    END.  /*  Fim do DO WHILE  */
    
    ASSIGN aux_vlrentot = ROUND(aux_vlrentot,2)
           par_vlsdrdca = ROUND(par_vlsdrdca,2)
           par_perirrgt = aux_perirapl.
    
    IF  NOT aux_flgbo159 THEN
        RUN sistema/generico/procedures/b1wgen0159.p 
            PERSISTENT SET h-b1wgen0159.
        
        
    RUN verifica-imunidade-tributaria IN h-b1wgen0159(
                                      INPUT par_cdcooper,
                                      INPUT par_nrctaapl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_flggrvir,
                                      INPUT 5,
                                      INPUT TRUNC((aux_vlrentot * 
                                                   aux_perirapl / 100),2),
                                      OUTPUT aux_flgimune,
                                      OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0159) AND NOT aux_flgbo159 THEN
        DELETE PROCEDURE h-b1wgen0159.
    
    IF   aux_flgimune THEN
         ASSIGN aux_vlsldapl = ROUND(par_vlsdrdca,2)
                par_vlrdirrf = 0.
    ELSE
         ASSIGN aux_vlsldapl = ROUND(par_vlsdrdca - 
                               TRUNC((aux_vlrentot * aux_perirapl / 100),2),2)
                par_vlrdirrf = TRUNC((aux_vlrentot * aux_perirapl / 100),2).
                

    RETURN "OK".

END PROCEDURE. /* Fim saldo_rdc_pre */


PROCEDURE provisao_rdc_pre:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/


    /* Rotina de calculo da provisao no final do mes e no vencimento. */

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_dtiniper LIKE craprda.dtiniper          NO-UNDO.
    DEF        INPUT PARAM par_dtfimper LIKE craprda.dtfimper          NO-UNDO.
    DEF       OUTPUT PARAM par_vlsdrdca AS DEC DECIMALS 4
             /*LIKE craprda.vlsdrdca Magui em 08/10/2007*/             NO-UNDO.
    DEF       OUTPUT PARAM par_vlrentot AS DEC DECIMALS 4
             /*LIKE craprda.vlsdrdca Magui em 08/10/2007*/             NO-UNDO.
    DEF       OUTPUT PARAM par_vllctprv LIKE craplap.vllanmto          NO-UNDO.
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.

    ASSIGN par_vllctprv = 0
           aux_vlrendim = 0
           par_vlsdrdca = 0
           par_vlrentot = 0.
        
    EMPTY TEMP-TABLE tt-erro.

    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                   
    IF   NOT AVAILABLE craprda   THEN                   
         DO: 
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}                    
                                                                        
             RETURN "NOK".                                               
         END.
                                              
    /*** Buscas as taxas contratadas ***/
    FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper       AND
                             craplap.nrdconta = craprda.nrdconta   AND
                             craplap.nraplica = craprda.nraplica   AND
                             craplap.dtmvtolt = craprda.dtmvtolt   
                             NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craplap   THEN  
         DO:                                 
             ASSIGN i-cod-erro = 90
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    ASSIGN aux_txaplica = craplap.txaplica / 100.

    FOR EACH craplap WHERE craplap.cdcooper = par_cdcooper       AND
                           craplap.nrdconta = craprda.nrdconta   AND 
                           craplap.nraplica = craprda.nraplica   AND
                          (craplap.cdhistor = 474                OR /* AJT+ */
                           craplap.cdhistor = 463)                  /* AJT- */
                           NO-LOCK:

        IF  craplap.cdhistor = 474  THEN /* AJT+ */
            ASSIGN par_vllctprv = par_vllctprv + craplap.vllanmto.
        ELSE
        IF  craplap.cdhistor = 463  THEN /* AJT- */
            ASSIGN par_vllctprv = par_vllctprv - craplap.vllanmto.
    END.

    ASSIGN par_vlsdrdca = craprda.vlsdrdca + par_vllctprv.

    DO WHILE par_dtiniper < par_dtfimper:
   
       DO WHILE TRUE:
        
          IF   CAN-DO("1,7",STRING(WEEKDAY(par_dtiniper)))               OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper    AND
                                      crapfer.dtferiad = par_dtiniper)   THEN
               DO:
                   par_dtiniper = par_dtiniper + 1.
                   NEXT.
               END.    
      
          LEAVE.
   
       END.  /*  Fim do DO WHILE TRUE  */
 
       IF   par_dtiniper >= par_dtfimper   THEN
            LEAVE.
        
       ASSIGN aux_vlrendim = TRUNCATE(par_vlsdrdca * aux_txaplica,8)
              par_vlsdrdca = par_vlsdrdca + aux_vlrendim 
              par_vlrentot = par_vlrentot + aux_vlrendim
              par_dtiniper = par_dtiniper + 1.

    END.  /*  Fim do DO WHILE  */

    ASSIGN par_vlrentot = ROUND(par_vlrentot,2)
           par_vlsdrdca = ROUND(par_vlsdrdca,2).

    RETURN "OK".
                  
END PROCEDURE. /* Fim provisao_rdc_pre */


PROCEDURE ajuste_provisao_rdc_pre:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/


    /* Rotina de calculo do ajuste da provisao a estornar nos casos de resgate
       antes do vencimento.

       Observacoes: Para se saber o quanto de rendimento esta sendo resgatado
                    se calculo o quanto esse resgate rendeu ate a ultima pro
                    visao */

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_vllanmto LIKE craplap.vllanmto          NO-UNDO.
    DEF       OUTPUT PARAM par_vlestprv LIKE craplap.vllanmto          NO-UNDO.
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    DEF                VAR aux_vllctprv LIKE craplap.vllanmto          NO-UNDO.
    DEF                VAR aux_pcajtprv AS DEC DECIMALS 2              NO-UNDO.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.
    
    ASSIGN aux_vllctprv = 0
           aux_pcajtprv = 0
           par_vlestprv = 0.

    EMPTY TEMP-TABLE tt-erro.

    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                   
    IF   NOT AVAILABLE craprda   THEN                   
         DO: 
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.
    
    ASSIGN aux_dtmvtolt = craprda.dtmvtolt
           aux_dtultdia = craprda.dtatslmx.
                  
    IF   aux_dtultdia <> ?   THEN
         DO:
             IF   par_vllanmto <> craprda.vlsdrdca   THEN
                  DO:
                      /*** Buscas as taxas contratadas ***/
                      FIND FIRST craplap
                           WHERE craplap.cdcooper = par_cdcooper       AND
                                 craplap.nrdconta = craprda.nrdconta   AND
                                 craplap.nraplica = craprda.nraplica   AND
                                 craplap.dtmvtolt = craprda.dtmvtolt   
                                 NO-LOCK NO-ERROR.
                      IF   NOT AVAILABLE craplap   THEN  
                           DO:                      
                               ASSIGN i-cod-erro = 90
                                      c-dsc-erro = " ".
           
                             {sistema/generico/includes/b1wgen0001.i}

                               RETURN "NOK".
                           END.

                      ASSIGN aux_txaplica = craplap.txaplica / 100.
 
                      DO WHILE aux_dtmvtolt < aux_dtultdia:
                         DO WHILE TRUE:
                            IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtmvtolt))) OR
                                 CAN-FIND(crapfer WHERE crapfer.cdcooper = 
                                                                par_cdcooper AND
                                           crapfer.dtferiad = aux_dtmvtolt) THEN
                                 DO:
                                     aux_dtmvtolt = aux_dtmvtolt + 1.
                                     NEXT.
                                 END.
                            LEAVE.
                         END.  /*  Fim do DO WHILE TRUE  */
                         IF   aux_dtmvtolt >= aux_dtultdia   THEN
                              LEAVE.
                     
                         ASSIGN aux_vlrendim = 
                                    TRUNCATE(par_vllanmto * aux_txaplica,8)
                                par_vllanmto = par_vllanmto + aux_vlrendim 
                                par_vlestprv = par_vlestprv + aux_vlrendim
                                aux_dtmvtolt = aux_dtmvtolt + 1.
                      END.  /*  Fim do DO WHILE  */
                      ASSIGN par_vlestprv = ROUND(par_vlestprv,2).
                  END.
             ELSE
                  /*** quando resgate total reverter todas as provisoes ***/
                  FOR EACH craplap WHERE craplap.cdcooper = par_cdcooper AND
                                     craplap.nrdconta = craprda.nrdconta AND 
                                     craplap.nraplica = craprda.nraplica AND
                                    (craplap.cdhistor = 474  OR  /* AJT+ */
                                     craplap.cdhistor = 463) /* AJT- */
                                     NO-LOCK:
                      IF   craplap.cdhistor = 474   THEN /* AJT+ */
                           ASSIGN par_vlestprv = 
                                      par_vlestprv + craplap.vllanmto.
                      ELSE
                           IF   craplap.cdhistor = 463   THEN /* AJT- */
                                ASSIGN par_vlestprv = 
                                           par_vlestprv - craplap.vllanmto.
                  END.
         END.                       
END PROCEDURE. /* Fim ajuste_provisao_rdc_pre */


PROCEDURE saldo_rdc_pos:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/



    /* Rotina de calculo do saldo das aplicacoes RDC POS enxergando as novas
       aliquotas de imposto de renda. Retorna o saldo ate a data.
       
       Observacao: O saldo sera craprda.vlsdrdca sera craprda.vlaplica -
                   resgate trazidos a valor presente */
    
    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_dtmvtolt LIKE craprda.dtmvtolt          NO-UNDO.
    DEF        INPUT PARAM par_dtcalsld LIKE craprda.dtmvtolt          NO-UNDO.
    DEF        INPUT PARAM par_flantven AS LOGICAL                     NO-UNDO.
    DEF        INPUT PARAM par_flggrvir AS LOGICAL                     NO-UNDO.
    DEF       OUTPUT PARAM par_vlsdrdca AS DEC DECIMALS 4
                   /*LIKE craprda.vlsdrdca Magui em 01/10/2007*/       NO-UNDO.
    DEF       OUTPUT PARAM par_vlrentot AS DEC DECIMALS 4
                   /*LIKE craprda.vlsdrdca Magui em 01/10/2007*/       NO-UNDO.
    DEF       OUTPUT PARAM par_vlrdirrf LIKE craplap.vllanmto          NO-UNDO.
    DEF       OUTPUT PARAM par_perirrgt AS DEC DECIMALS 2              NO-UNDO.
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    DEF                VAR aux_dtiniper LIKE craprda.dtiniper          NO-UNDO.
    DEF                VAR aux_dtfimper LIKE craprda.dtfimper          NO-UNDO.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.

    /* Variaveis para novo calculo de poupanca */
    DEF                VAR aux_datlibpr  AS DATE                       NO-UNDO.

    ASSIGN aux_pcajsren = 0       
           aux_nrmeses  = 0
           aux_nrdias   = 0  
           aux_perirapl = 0
           aux_vlrenacu = 0
           par_vlrdirrf = 0
           aux_vlrentot = 0
           aux_qtdfaxir = 0.
    
    EMPTY TEMP-TABLE tt-erro.
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE crapdat  THEN
        DO:
            ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END. 
    
    FIND craptab WHERE craptab.nmsistem = "CRED"         AND   
                       craptab.cdempres = 0              AND
                       craptab.tptabela = "CONFIG"       AND   
                       craptab.cdacesso = "PERCIRFRDC"   AND
                       craptab.tpregist = 0              AND
                       craptab.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.
                   
    DO aux_cartaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):
       ASSIGN aux_vllidtab = ENTRY(aux_cartaxas,craptab.dstextab,";")
              aux_qtdfaxir = aux_qtdfaxir + 1
              aux_qtdiatab[aux_qtdfaxir] = DECIMAL(ENTRY(1,aux_vllidtab,"#"))
              aux_perirtab[aux_qtdfaxir] = DECIMAL(ENTRY(2,aux_vllidtab,"#")).
    END.                 
                                      
    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                   
    IF   NOT AVAILABLE craprda   THEN                   
         DO: 
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.
    
    ASSIGN aux_nrdias = craprda.dtvencto - craprda.dtmvtolt.
    IF   aux_nrdias = ?   OR
         aux_nrdias = 0   THEN                   
         DO: 
             ASSIGN i-cod-erro = 840
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.
    
    DO aux_occ = aux_qtdfaxir TO 1 BY -1:
       IF   aux_nrdias > aux_qtdiatab[aux_occ]   THEN
            DO:
                ASSIGN aux_perirapl = aux_perirtab[aux_occ].
                LEAVE.
            END.
    END.        
     
    IF   aux_perirapl = 0   THEN          
         ASSIGN aux_perirapl = aux_perirtab[4].
    
    IF   aux_perirapl = 0   AND  
         par_cdcooper <> 3 THEN
         DO:
             ASSIGN i-cod-erro = 180
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
          END.
         
    ASSIGN aux_dtfimper = par_dtcalsld
           par_vlsdrdca = craprda.vlsdrdca
           par_perirrgt = aux_perirapl.

    /*** Verifica se aplicacao esta em carencia ***/
    IF   craprda.dtvencto >= crapdat.dtmvtolt   AND
         craprda.dtvencto <= crapdat.dtmvtopr   THEN
         .
    ELSE     
    IF   par_dtmvtolt - craprda.dtmvtolt < craprda.qtdiauti   THEN
         DO:
             ASSIGN par_vlsdrdca = craprda.vlsdrdca.
             RETURN "OK".
         END.

    IF   par_flantven = YES   THEN  /* TAXA MINIMA */
         ASSIGN par_vlsdrdca = craprda.vlsltxmm
                aux_dtiniper = craprda.dtatslmm.
    ELSE
         ASSIGN par_vlsdrdca  = craprda.vlsltxmx
                aux_dtiniper = craprda.dtatslmx.

    /*** Buscar as taxas contratas ***/
    FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper       AND
                             craplap.nrdconta = craprda.nrdconta   AND
                             craplap.nraplica = craprda.nraplica   AND
                             craplap.dtmvtolt = craprda.dtmvtolt 
                             USE-INDEX craplap5 NO-LOCK NO-ERROR.
     
    IF   NOT AVAILABLE craplap   THEN  
         DO:                       
             ASSIGN i-cod-erro = 90
                    c-dsc-erro = " ".
             
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.      
     
    /* Data de fim e inicio da utilizacao da taxa de poupanca.
       Utiliza-se essa data quando o rendimento da aplicacao for menor que
       a poupanca, a cooperativa opta por usar ou nao. */
    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "USUARI"      AND
                       craptab.cdempres = 11            AND
                       craptab.cdacesso = "MXRENDIPOS"  AND
                       craptab.tpregist = 1 NO-LOCK NO-ERROR.
                                    
    IF   NOT AVAILABLE craptab   THEN
         ASSIGN aux_dtinitax = 01/01/9999
                aux_dtfimtax = 01/01/9999.
    ELSE
         ASSIGN aux_dtinitax = DATE(ENTRY(1,craptab.dstextab,";"))
                aux_dtfimtax = DATE(ENTRY(2,craptab.dstextab,";")).
     
    /* Data de liberacao do projeto novo indexador de poupanca */
    ASSIGN aux_datlibpr = 07/01/2014.

    DO WHILE aux_dtiniper < aux_dtfimper:
       DO WHILE TRUE:
          IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtiniper)))    OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                      crapfer.dtferiad = aux_dtiniper)   THEN
               DO:     
                   aux_dtiniper = aux_dtiniper + 1.
                   NEXT.                                  END.
               
          LEAVE.
       END.  /*  Fim do DO WHILE TRUE  */
       
       IF   aux_dtiniper >= aux_dtfimper   THEN
            LEAVE.
        
       FIND crapmfx WHERE crapmfx.cdcooper = par_cdcooper   AND
                          crapmfx.dtmvtolt = aux_dtiniper   AND
                          crapmfx.tpmoefix = 6 NO-LOCK NO-ERROR. /* CDI ANO */
       
       IF   NOT AVAILABLE crapmfx   THEN  
            DO: 
                ASSIGN i-cod-erro = 211
                       c-dsc-erro = " ".
           
                {sistema/generico/includes/b1wgen0001.i}

                RETURN "NOK".
            END.
        
       ASSIGN aux_txaplmes = 
                     (EXP((1 + crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100.
                     
       /* Calcula o saldo com a taxa minina se for antes do vencimento */
       IF   par_flantven = YES   AND
            craplap.txaplica <> craplap.txaplmes   THEN           
            aux_txaplica = 
                ROUND((aux_txaplmes * craplap.txaplmes / 100 ) / 100 ,8).
       ELSE 
            DO:           
                aux_txaplica =
                    ROUND((aux_txaplmes * craplap.txaplica / 100 ) / 100 ,8).

                IF   aux_dtiniper > aux_dtinitax     AND 
                     craprda.dtmvtolt < aux_dtfimtax THEN
                     DO:  
                        /* Usar poupanca de um mes atras */
                        aux_dtinipop = DATE(MONTH(aux_dtiniper) - 1,
                                          DAY(aux_dtiniper),YEAR(aux_dtiniper)) 
                                             NO-ERROR.

                        IF   ERROR-STATUS:ERROR   THEN
                             /* Tratar anos anteriores */
                             IF   MONTH(aux_dtiniper) = 1   THEN
                                  aux_dtinipop = aux_dtiniper - 31.
                             ELSE
                                 /* Caso nao exista a data, pegar primeiro 
                                    dia do mes */
                                  aux_dtinipop = DATE(MONTH(aux_dtiniper),01,
                                                          YEAR(aux_dtiniper)).
                        

                        /********************************************************************/
                        /** Em Maio de 2012 o novo calculo foi liberado para utilizacao,   **/
                        /** portanto aplicacoes cadastradas a partir desta data poderiam   **/
                        /** ser remuneradas conforme a nova regra, porem, em nosso sistema **/
                        /** vamos calcular o rendimento desta aplicacao com base na nova   **/
                        /** regra somente a partir da data de liberacao do projeto de novo **/
                        /** indexador de poupanca, pois o passado anterior a liberacao ja  **/
                        /** foi remunerado e contabilizado.                                 **/
                        /********************************************************************/


                        IF craprda.dtmvtolt >= 05/04/2012 AND
                           aux_dtiniper >= aux_datlibpr THEN

                            FIND crapmfx WHERE 
                                 crapmfx.cdcooper = par_cdcooper AND
                                 crapmfx.dtmvtolt = aux_dtinipop AND
                                 crapmfx.tpmoefix = 20 NO-LOCK NO-ERROR.  
                        ELSE
                            FIND crapmfx WHERE 
                                 crapmfx.cdcooper = par_cdcooper AND
                                 crapmfx.dtmvtolt = aux_dtinipop AND
                                 crapmfx.tpmoefix = 8 NO-LOCK NO-ERROR.  


                        IF   NOT AVAILABLE crapmfx   THEN
                             DO:    
                                ASSIGN i-cod-erro = 211
                                       c-dsc-erro = " ".

                                {sistema/generico/includes/b1wgen0001.i}
                                
                                RETURN "NOK".
                             END.
                        
                        FIND FIRST craptrd WHERE 
                                   craptrd.cdcooper = par_cdcooper AND
                                   craptrd.dtiniper = aux_dtinipop
                                   NO-LOCK NO-ERROR.
                                               
                        RUN calctx_poupanca (INPUT  par_cdcooper,
                                             INPUT  craptrd.qtdiaute,
                                             INPUT  crapmfx.vlmoefix,
                                             OUTPUT aux_txmespop,
                                             OUTPUT aux_txdiapop).  
              
                        IF   aux_txaplica < aux_txdiapop / 100   THEN
                             ASSIGN aux_txaplica = aux_txdiapop / 100. 
                     END.
            END.          
       
       ASSIGN aux_vlrendim = TRUNCATE(par_vlsdrdca * aux_txaplica,8)
              par_vlsdrdca = par_vlsdrdca + aux_vlrendim 
              aux_vlrentot = aux_vlrentot + aux_vlrendim
              aux_dtiniper = aux_dtiniper + 1.

    END.  /*  Fim do DO WHILE  */

    ASSIGN aux_vlrentot = ROUND(aux_vlrentot,2)
           par_vlrentot = aux_vlrentot
           par_vlsdrdca = ROUND(par_vlsdrdca,2)
           par_perirrgt = aux_perirapl.
    
    IF  NOT aux_flgbo159 THEN
        RUN sistema/generico/procedures/b1wgen0159.p
            PERSISTENT SET h-b1wgen0159.
        
        
    RUN verifica-imunidade-tributaria IN h-b1wgen0159(
                                      INPUT par_cdcooper,
                                      INPUT par_nrctaapl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_flggrvir,
                                      INPUT 5,
                                      INPUT TRUNC((aux_vlrentot * 
                                                   aux_perirapl / 100),2),
                                      OUTPUT aux_flgimune,
                                      OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0159) AND NOT aux_flgbo159 THEN
        DELETE PROCEDURE h-b1wgen0159.
    
    IF   aux_flgimune THEN
         ASSIGN aux_vlsldapl = ROUND(par_vlsdrdca,2)
                par_vlrdirrf = 0.
    ELSE
         ASSIGN aux_vlsldapl = ROUND(par_vlsdrdca - 
                               TRUNC((aux_vlrentot * aux_perirapl / 100),2),2)
                par_vlrdirrf = TRUNC((aux_vlrentot * aux_perirapl / 100),2).

    RETURN "OK".
    
END PROCEDURE. /* Fim saldo_rdc_pos */


PROCEDURE saldo_rgt_rdc_pos:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/

    /* Rotina de calculo do saldo das aplicacoes RDC POS para resgate 
       enxergando as novas aliquotas de imposto de renda.
       Retorna o saldo para resgate no dia solicitado.
       
       Observacoes: Saldo sera craprda.vlsdrdca sera craprda.vlaplica menos
                    os resgates a valor presente */

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_dtmvtolt LIKE craprda.dtmvtolt          NO-UNDO.
    DEF        INPUT PARAM par_dtaplrgt LIKE craprda.dtmvtolt          NO-UNDO.
    DEF        INPUT PARAM par_vlsdorgt LIKE craprda.vlsdrdca          NO-UNDO.
    DEF        INPUT PARAM par_flggrvir AS LOGICAL                     NO-UNDO.
    DEF       OUTPUT PARAM par_vlsddrgt LIKE craprda.vlsdrdca          NO-UNDO.
    /* par_vlsddrgt = valor do resgate total sem irrf ou o solicitado */
    DEF       OUTPUT PARAM par_vlrenrgt LIKE craprda.vlsdrdca          NO-UNDO.
    /* par_vlrenrgt = rendimento total a ser pago quando resgate total ou
                      o rendimento do esta sendo solicitado */
    DEF       OUTPUT PARAM par_vlrdirrf LIKE craplap.vllanmto          NO-UNDO.
    /* par_vlrdirrf = irrf do que foi solicitado */
    DEF       OUTPUT PARAM par_perirrgt AS DEC DECIMALS 2              NO-UNDO.
    /* par_perirrgt = percentual de aliquota para calculo do irrf */
    DEF       OUTPUT PARAM par_vlrgttot AS DEC DECIMALS 2              NO-UNDO.
    /* par_vlrgttot = resgate para zerar a aplicacao */
    DEF       OUTPUT PARAM par_vlirftot AS DEC DECIMALS 2              NO-UNDO.
    /* par_vlirftot = irrf para finalizar a aplicacao */
    DEF       OUTPUT PARAM par_vlrendmm AS DEC DECIMALS 2              NO-UNDO.
    /* par_vlrendmm = rendimento da ultima provisao ate a data do resgate */
    DEF       OUTPUT PARAM par_vlrvtfim LIKE craplap.vllanmto          NO-UNDO.
    /* par_vlrvtfim = quanta provisao reverter para zerar a aplicacao */
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    DEF                VAR aux_dtiniper LIKE craprda.dtiniper          NO-UNDO.
    DEF                VAR aux_dtfimper LIKE craprda.dtfimper          NO-UNDO.
    DEF                VAR aux_txaplrgt AS DEC DECIMALS 8              NO-UNDO.
    DEF                VAR aux_perirrgt AS DEC DECIMALS 2              NO-UNDO.
    DEF                VAR aux_vlrenmlt AS DEC DECIMALS 8              NO-UNDO.
    DEF                VAR aux_vlrgtsol LIKE craprda.vlsdrdca          NO-UNDO.
    DEF                VAR aux_vlrnttmm LIKE craplap.vlrendmm          NO-UNDO.
    DEF                VAR aux_vlrenpgt LIKE craplap.vllanmto          NO-UNDO.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.

    /* Variaveis para novo calculo de poupanca */
    DEF                VAR aux_datlibpr  AS DATE                       NO-UNDO.

    DEF BUFFER crablap FOR craplap.
    
    ASSIGN aux_vlrgtsol = 0     aux_nrmeses  = 0
           aux_nrdias   = 0     aux_perirapl = 0
           aux_vlrenacu = 0     aux_vlrenmlt = 0
           par_vlsddrgt = 0     par_vlrenrgt = 0 
           par_vlrdirrf = 0     par_perirrgt = 0
           par_vlrgttot = 0     par_vlirftot = 0
           par_vlrendmm = 0     par_vlrvtfim = 0
           aux_qtdfaxir = 0.

    EMPTY TEMP-TABLE tt-erro.

    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE crapdat  THEN
        DO:
            ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END. 
 
    FIND craptab WHERE craptab.nmsistem = "CRED"         AND   
                       craptab.cdempres = 0              AND
                       craptab.tptabela = "CONFIG"       AND   
                       craptab.cdacesso = "PERCIRFRDC"   AND
                       craptab.tpregist = 0              AND
                       craptab.cdcooper = par_cdcooper
                       NO-LOCK NO-ERROR.
                   
    DO aux_cartaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):
       ASSIGN aux_vllidtab = ENTRY(aux_cartaxas,craptab.dstextab,";")
              aux_qtdfaxir = aux_qtdfaxir + 1
              aux_qtdiatab[aux_qtdfaxir] = DECIMAL(ENTRY(1,aux_vllidtab,"#"))
              aux_perirtab[aux_qtdfaxir] = DECIMAL(ENTRY(2,aux_vllidtab,"#")).
    END.                 
    
    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                   
    IF   NOT AVAILABLE craprda   THEN                   
         DO: 
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    ASSIGN aux_dtiniper = craprda.dtmvtolt
           aux_dtfimper = par_dtaplrgt
           aux_vlrgtsol = par_vlsdorgt.
    
    IF   aux_vlrgtsol = 0   THEN
         ASSIGN aux_vlrgtsol = craprda.vlsltxmm
                aux_dtiniper = craprda.dtatslmm. 
    /*** Preciso do que ja foi provisionado e estornada para zerar a 
         aplicacao se resgate total ***/
    FOR EACH crablap WHERE  crablap.cdcooper = par_cdcooper
                       AND  crablap.nrdconta = craprda.nrdconta
                       AND  crablap.nraplica = craprda.nraplica
                       AND (crablap.cdhistor = 529 OR
                            crablap.cdhistor = 531 OR
                            crablap.cdhistor = 532) NO-LOCK:
        
        IF   crablap.cdhistor = 529   THEN  /*provisao*/
             ASSIGN aux_vlrnttmm = aux_vlrnttmm + crablap.vlrendmm
                    par_vlrvtfim = par_vlrvtfim + crablap.vllanmto.
        ELSE
             IF  crablap.cdhistor = 532 THEN /*rendimento cred*/
                 ASSIGN aux_vlrenpgt = aux_vlrenpgt + crablap.vllanmto.
             ELSE
                 ASSIGN par_vlrvtfim = par_vlrvtfim - crablap.vllanmto
                        aux_vlrnttmm = aux_vlrnttmm - crablap.vlrendmm.
    END.                     
    
    /*** Verifica se aplicacao esta em carencia ***/
    IF   par_dtaplrgt - craprda.dtmvtolt < craprda.qtdiauti   THEN
         DO:
             ASSIGN par_vlsddrgt = craprda.vlsdrdca
                    par_vlrgttot = craprda.vlsdrdca
                    par_vlrendmm = aux_vlrnttmm.
             RETURN "OK".
         END.

    /*** Buscar as taxas contratas ***/
    FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper       AND
                             craplap.nrdconta = craprda.nrdconta   AND
                             craplap.nraplica = craprda.nraplica   AND
                             craplap.dtmvtolt = craprda.dtmvtolt   
                             USE-INDEX craplap5 NO-LOCK NO-ERROR.
    IF   NOT AVAILABLE craplap   THEN  
         DO:                       
             ASSIGN i-cod-erro = 90
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    /*** Retorna percentual do imposto de renda a ser cobrado no resgate ***/
    IF   craplap.txaplmes <> 0   AND
         par_dtaplrgt     <> ?   THEN
         DO:
             ASSIGN aux_nrdias = par_dtaplrgt - craprda.dtmvtolt.
             IF   aux_nrdias = ?   OR
                  aux_nrdias = 0   THEN                   
                  DO: 
                      ASSIGN i-cod-erro = 840
                             c-dsc-erro = " ".
           
                      {sistema/generico/includes/b1wgen0001.i}

                      RETURN "NOK".
                  END.

             DO aux_occ = aux_qtdfaxir TO 1 BY -1:
                IF   aux_nrdias > aux_qtdiatab[aux_occ]   THEN
                     DO:
                        ASSIGN aux_perirrgt = aux_perirtab[aux_occ].
                        LEAVE.
                     END.
             END.        
             
             IF   aux_perirrgt = 0   THEN          
                  ASSIGN aux_perirrgt = aux_perirtab[4].

             IF   aux_perirrgt = 0   AND  
                  par_cdcooper <> 3 THEN
                  DO:
                      ASSIGN i-cod-erro = 180
                             c-dsc-erro = " ".
           
                      {sistema/generico/includes/b1wgen0001.i}

                      RETURN "NOK".
                  END.
         END.

    /* Data de fim e inicio da utilizacao da taxa de poupanca.
       Utiliza-se essa data quando o rendimento da aplicacao for menor que
       a poupanca, a cooperativa opta por usar ou nao. */
    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "USUARI"      AND
                       craptab.cdempres = 11            AND
                       craptab.cdacesso = "MXRENDIPOS"  AND
                       craptab.tpregist = 1 NO-LOCK NO-ERROR.
                                    
    IF   NOT AVAILABLE craptab   THEN
         ASSIGN aux_dtinitax = 01/01/9999
                aux_dtfimtax = 01/01/9999.
    ELSE
         ASSIGN aux_dtinitax = DATE(ENTRY(1,craptab.dstextab,";"))
                aux_dtfimtax = DATE(ENTRY(2,craptab.dstextab,";")).

    /* Data de liberacao do projeto novo indexador de poupanca */
    ASSIGN aux_datlibpr = 07/01/2014.
               
    DO WHILE aux_dtiniper < aux_dtfimper:
       DO WHILE TRUE:
          IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtiniper)))    OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                      crapfer.dtferiad = aux_dtiniper)   THEN
               DO:
                   aux_dtiniper = aux_dtiniper + 1.
                   NEXT.
               END.

          LEAVE.
       END.  /*  Fim do DO WHILE TRUE  */
   
       IF   aux_dtiniper >= aux_dtfimper   THEN
            LEAVE.
        
       FIND crapmfx WHERE crapmfx.cdcooper = par_cdcooper   AND
                          crapmfx.dtmvtolt = aux_dtiniper   AND
                          crapmfx.tpmoefix = 6 NO-LOCK NO-ERROR. /* CDI ANO */

       IF   NOT AVAILABLE crapmfx   THEN  
            DO:                        
                ASSIGN i-cod-erro = 211
                       c-dsc-erro = " ".
           
                {sistema/generico/includes/b1wgen0001.i}

                RETURN "NOK".
            END.

       ASSIGN aux_txaplmes = 
                 (EXP((1 + crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100.
       IF   craplap.txaplica <> craplap.txaplmes   THEN          
            aux_txaplrgt = 
                  ROUND(((aux_txaplmes * craplap.txaplmes / 100) / 100),8).
       ELSE
            DO:
                aux_txaplrgt =
                    ROUND((aux_txaplmes * craplap.txaplica / 100 ) / 100 ,8).

                IF   aux_dtiniper > aux_dtinitax     AND 
                     craprda.dtmvtolt < aux_dtfimtax THEN
                     DO:       
                        /* Usar poupanca de um mes atras */
                        aux_dtinipop = DATE(MONTH(aux_dtiniper) - 1,
                                          DAY(aux_dtiniper),YEAR(aux_dtiniper)) 
                                             NO-ERROR.

                        IF   ERROR-STATUS:ERROR   THEN
                             /* Tratar anos anteriores */
                             IF   MONTH(aux_dtiniper) = 1   THEN
                                  aux_dtinipop = aux_dtiniper - 31.
                             ELSE
                                 /* Caso nao exista a data, pegar primeiro 
                                    dia do mes */
                                  aux_dtinipop = DATE(MONTH(aux_dtiniper),01,
                                                          YEAR(aux_dtiniper)).

                        /********************************************************************/
                        /** Em Maio de 2012 o novo calculo foi liberado para utilizacao,   **/
                        /** portanto aplicacoes cadastradas a partir desta data poderiam   **/
                        /** ser remuneradas conforme a nova regra, porem, em nosso sistema **/
                        /** vamos calcular o rendimento desta aplicacao com base na nova   **/
                        /** regra somente a partir da data de liberacao do projeto de novo **/
                        /** indexador de poupanca, pois o passado anterior a liberacao ja  **/
                        /** foi remunerado e contabilizado.                                 **/
                        /********************************************************************/

                        IF  craprda.dtmvtolt >= 05/04/2012  AND
                            aux_dtiniper >= aux_datlibpr    THEN
                            FIND crapmfx WHERE 
                                 crapmfx.cdcooper = par_cdcooper AND
                                 crapmfx.dtmvtolt = aux_dtinipop AND
                                 crapmfx.tpmoefix = 20 NO-LOCK NO-ERROR.  
                        ELSE
                            FIND crapmfx WHERE 
                                 crapmfx.cdcooper = par_cdcooper AND
                                 crapmfx.dtmvtolt = aux_dtinipop AND
                                 crapmfx.tpmoefix = 8 NO-LOCK NO-ERROR.  
                        
                        IF   NOT AVAILABLE crapmfx   THEN
                             DO:                       
                                ASSIGN i-cod-erro = 211
                                       c-dsc-erro = " ".

                                {sistema/generico/includes/b1wgen0001.i}
                                
                                RETURN "NOK".
                             END.
                        
                        FIND FIRST craptrd WHERE 
                                   craptrd.cdcooper = par_cdcooper AND
                                   craptrd.dtiniper = aux_dtinipop
                                   NO-LOCK NO-ERROR.
                                               
                        RUN calctx_poupanca (INPUT  par_cdcooper,
                                             INPUT  craptrd.qtdiaute,
                                             INPUT  crapmfx.vlmoefix,
                                             OUTPUT aux_txmespop,
                                             OUTPUT aux_txdiapop).  
              
                        IF  aux_txaplrgt < aux_txdiapop / 100   THEN
                            ASSIGN aux_txaplrgt = aux_txdiapop / 100. 
                     END.
            END.
       
       ASSIGN aux_vlrenrgt = TRUNCATE(aux_vlrgtsol * aux_txaplrgt,8)
              aux_vlrgtsol = aux_vlrgtsol + aux_vlrenrgt 
              aux_vlrenmlt = aux_vlrenmlt + aux_vlrenrgt
              aux_dtiniper = aux_dtiniper + 1.
       
    END.  /*  Fim do DO WHILE  */

    ASSIGN aux_vlrenmlt = /*ROUND*/ TRUNCATE(aux_vlrenmlt,2)
           par_vlrenrgt = aux_vlrenmlt
           aux_vlrgtsol = ROUND(aux_vlrgtsol,2)
           par_vlrdirrf = TRUNCATE((par_vlrenrgt * aux_perirrgt / 100),2)
           par_perirrgt = aux_perirrgt.
    
    RUN sistema/generico/procedures/b1wgen0159.p
                            PERSISTENT SET h-b1wgen0159.

    RUN verifica-imunidade-tributaria IN h-b1wgen0159(INPUT par_cdcooper,
                                                      INPUT par_nrctaapl,
                                                      INPUT par_dtmvtolt,
                                                      INPUT par_flggrvir,
                                                      INPUT 5,
                                                      INPUT TRUNC((par_vlrenrgt * 
                                                                   par_perirrgt / 100),2),
                                                      OUTPUT aux_flgimune,
                                                      OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen0159.
    
    IF   aux_flgimune THEN
         ASSIGN par_vlrdirrf = 0.
    
    IF   par_vlsdorgt <> 0  THEN /* resgate parcial */  
         DO:       
             ASSIGN par_vlsddrgt = par_vlsdorgt.
             RETURN "OK".
         END.

    /*** Quando resgate total precisamos descobrir o quanto falta pagar de 
         rendimento e de irrf ***/
    ASSIGN par_vlsddrgt = aux_vlrgtsol. /* falta descontar o irrf */ 

    /*** Busca todos os rendimentos que foram calculados quando houve um       
         lancamento 529 a taxa minima. E os rendimentos ja pagos ***/
    ASSIGN par_vlrendmm = par_vlrenrgt
                    /* no caso de resgate total, o rendimento calculado acima e 
                       so da ultima provisao ate a data do resgate */
           aux_vlrnttmm = (craprda.vlsltxmm - craprda.vlsdrdca) + par_vlrenrgt
           par_vlrenrgt = aux_vlrnttmm. 
           
    IF   aux_flgimune THEN
         ASSIGN par_vlrgttot = ROUND(par_vlsddrgt,2).
    ELSE
         ASSIGN par_vlrgttot = ROUND(par_vlsddrgt -
                               TRUNC((par_vlrenrgt * par_perirrgt / 100),2),2).

    RETURN "OK".
                
END PROCEDURE. /* Fim saldo_rgt_rdc_pos */


PROCEDURE provisao_rdc_pos_var.
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/

    /***** Rotina para calcular quanto a rdcpos valera na 
           data do vencimento para calculo do var *****/

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF       OUTPUT PARAM par_vlsdrdca AS DEC DECIMALS 4
                     /*LIKE craprda.vlsdrdca Magui em 28/09/2007*/     NO-UNDO.
    DEF       OUTPUT PARAM par_vlrentot AS DEC DECIMALS 4
                     /*LIKE craprda.vlsdrdca Magui em 28/09/2007*/     NO-UNDO.
    
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.
    DEF                VAR aux_dtiniper  AS DATE   FORMAT "99/99/9999" NO-UNDO.
    DEF                VAR aux_dtfimper  AS DATE   FORMAT "99/99/9999" NO-UNDO.
    DEF                VAR aux_vlmoefix  LIKE crapmfx.vlmoefix         NO-UNDO.
    
    ASSIGN aux_dtcalcul = ?
           par_vlsdrdca = 0
           aux_vlrendim = 0
           par_vlrentot = 0.

    EMPTY TEMP-TABLE tt-erro.

    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    IF  NOT AVAILABLE crapdat  THEN
        DO:
            ASSIGN i-cod-erro = 1 
                   c-dsc-erro = " ".
           
            { sistema/generico/includes/b1wgen0001.i }

            RETURN "NOK".
        END. 
 
    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                   
    IF   NOT AVAILABLE craprda   THEN                   
         DO: 
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    /*** Buscas as taxas contratadas ***/
    FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper       AND
                             craplap.nrdconta = craprda.nrdconta   AND
                             craplap.nraplica = craprda.nraplica   AND
                             craplap.dtmvtolt = craprda.dtmvtolt   
                             NO-LOCK NO-ERROR.
                                                           
    IF   NOT AVAILABLE craplap   THEN  
         DO:                       
             ASSIGN i-cod-erro = 90 
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    ASSIGN par_vlsdrdca = craprda.vlsltxmx
           aux_dtiniper = craprda.dtatslmx
           aux_dtfimper = crapdat.dtmvtopr 
           aux_vlmoefix = 0.

    DO WHILE aux_dtiniper < aux_dtfimper:

       DO WHILE TRUE:
        
          IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtiniper)))    OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                      crapfer.dtferiad = aux_dtiniper)   THEN
               DO:
                   aux_dtiniper = aux_dtiniper + 1.
                   NEXT.
               END.
   
          LEAVE.
   
       END.  /*  Fim do DO WHILE TRUE  */
   
       IF   aux_dtiniper >= aux_dtfimper   THEN
            LEAVE.
        
       IF   aux_dtiniper <= crapdat.dtmvtolt   THEN
            DO:
                FIND crapmfx WHERE crapmfx.cdcooper = par_cdcooper   AND
                                   crapmfx.dtmvtolt = aux_dtiniper   AND
                                   crapmfx.tpmoefix = 6 NO-LOCK NO-ERROR.
                                   /* CDI ANO */
                IF   AVAILABLE crapmfx   THEN  
                     ASSIGN aux_vlmoefix = crapmfx.vlmoefix.
            END.
            
       ASSIGN aux_txaplmes = 
                 (EXP((1 + aux_vlmoefix / 100),(1 / 252)) - 1) * 100
                 
              aux_txaplica =
                 ROUND((aux_txaplmes * craplap.txaplica / 100 ) / 100 ,8).
                               
       ASSIGN aux_vlrendim = TRUNCATE(par_vlsdrdca * aux_txaplica,8)
              par_vlsdrdca = par_vlsdrdca + aux_vlrendim 
              par_vlrentot = par_vlrentot + aux_vlrendim
              aux_dtiniper = aux_dtiniper + 1.
   
    END.  /*  Fim do DO WHILE  */

    ASSIGN par_vlrentot = ROUND(par_vlrentot,2)
           par_vlsdrdca = ROUND(par_vlsdrdca,2).

    RETURN "OK".
 
END PROCEDURE. /* Fim provisao_rdc_pos_var */


PROCEDURE rendi_apl_pos_com_resgate:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/

 /*** Calcula quanto o que esta sendo resgatado rendeu ate a data ***/  

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_dtaplrgt LIKE craprda.dtmvtolt          NO-UNDO.
    DEF        INPUT PARAM par_vlsdrdca AS DEC DECIMALS 8              NO-UNDO.
    DEF        INPUT PARAM par_flantven AS LOGICAL                     NO-UNDO.
    DEF       OUTPUT PARAM par_vlrenrgt LIKE craprda.vlsdrdca          NO-UNDO.
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    DEF                VAR aux_dtiniper LIKE craprda.dtiniper          NO-UNDO.
    DEF                VAR aux_dtfimper LIKE craprda.dtfimper          NO-UNDO.
    DEF                VAR aux_txaplrgt AS DEC DECIMALS 8              NO-UNDO.
    DEF                VAR aux_perirrgt AS DEC DECIMALS 2              NO-UNDO.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.

    /* Variaveis para novo calculo de poupanca */
    DEF                VAR aux_datlibpr  AS DATE                       NO-UNDO.

    ASSIGN aux_pcajsren = 0       
           aux_vlrenacu = 0
           aux_vlrentot = 0.
        
    EMPTY TEMP-TABLE tt-erro.
    
    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                   
    IF   NOT AVAILABLE craprda   THEN                   
         DO: 
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    ASSIGN aux_dtiniper = craprda.dtmvtolt
           aux_dtfimper = par_dtaplrgt.

    /*** Buscar as taxas contratas ***/
    FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper       AND
                             craplap.nrdconta = craprda.nrdconta   AND
                             craplap.nraplica = craprda.nraplica   AND
                             craplap.dtmvtolt = craprda.dtmvtolt   
                             NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craplap   THEN  
         DO:                      
             ASSIGN i-cod-erro = 90
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    /* Data de fim e inicio da utilizacao da taxa de poupanca.
       Utiliza-se essa data quando o rendimento da aplicacao for menor que
       a poupanca, a cooperativa opta por usar ou nao. */
    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "USUARI"      AND
                       craptab.cdempres = 11            AND
                       craptab.cdacesso = "MXRENDIPOS"  AND
                       craptab.tpregist = 1 NO-LOCK NO-ERROR.
                                   
    IF   NOT AVAILABLE craptab   THEN
         ASSIGN aux_dtinitax = 01/01/9999
                aux_dtfimtax = 01/01/9999.
    ELSE
         ASSIGN aux_dtinitax = DATE(ENTRY(1,craptab.dstextab,";"))
                aux_dtfimtax = DATE(ENTRY(2,craptab.dstextab,";")).
    
    /* Data de liberacao do projeto novo indexador de poupanca */
    ASSIGN aux_datlibpr = 07/01/2014.        

    DO WHILE aux_dtiniper < aux_dtfimper:
       DO WHILE TRUE:
          IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtiniper)))    OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                      crapfer.dtferiad = aux_dtiniper)   THEN
               DO:
                   aux_dtiniper = aux_dtiniper + 1.
                   NEXT.
               END.

          LEAVE.
       END.  /*  Fim do DO WHILE TRUE  */
   
       IF   aux_dtiniper >= aux_dtfimper   THEN
            LEAVE.
        
       FIND crapmfx WHERE crapmfx.cdcooper = par_cdcooper   AND
                          crapmfx.dtmvtolt = aux_dtiniper   AND
                          crapmfx.tpmoefix = 6 NO-LOCK NO-ERROR. /* CDI ANO */

       IF   NOT AVAILABLE crapmfx   THEN  
            DO:
                
                                       
                ASSIGN i-cod-erro = 211
                       c-dsc-erro = " ".
           
                {sistema/generico/includes/b1wgen0001.i}

                RETURN "NOK".
            END.

       ASSIGN aux_txaplmes = 
                 (EXP((1 + crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100.
         
       IF   par_flantven = YES   AND
            craplap.txaplica <> craplap.txaplmes   THEN /* taxa minima */
            ASSIGN aux_txaplrgt = 
                      ROUND(((aux_txaplmes * craplap.txaplmes / 100) / 100),8).
       ELSE 
            DO:     
                ASSIGN aux_txaplrgt = 
                       ROUND(((aux_txaplmes * craplap.txaplica / 100) / 100),8).
                
                IF   aux_dtiniper > aux_dtinitax     AND 
                     craprda.dtmvtolt < aux_dtfimtax THEN
                     DO:
                        /* Usar poupanca de um mes atras */
                        aux_dtinipop = DATE(MONTH(aux_dtiniper) - 1,
                                          DAY(aux_dtiniper),YEAR(aux_dtiniper)) 
                                            NO-ERROR.

                        IF   ERROR-STATUS:ERROR   THEN
                             /* Tratar anos anteriores */
                             IF   MONTH(aux_dtiniper) = 1   THEN
                                  aux_dtinipop = aux_dtiniper - 31.
                             ELSE
                                 /* Caso nao exista a data, pegar primeiro 
                                    dia do mes */  
                                  aux_dtinipop = DATE(MONTH(aux_dtiniper),01,
                                                          YEAR(aux_dtiniper)).

                        /********************************************************************/
                        /** Em Maio de 2012 o novo calculo foi liberado para utilizacao,   **/
                        /** portanto aplicacoes cadastradas a partir desta data poderiam   **/
                        /** ser remuneradas conforme a nova regra, porem, em nosso sistema **/
                        /** vamos calcular o rendimento desta aplicacao com base na nova   **/
                        /** regra somente a partir da data de liberacao do projeto de novo **/
                        /** indexador de poupanca, pois o passado anterior a liberacao ja  **/
                        /** foi remunerado e contabilizado.                                 **/
                        /********************************************************************/
                        
                        
                        IF craprda.dtmvtolt >= 05/04/2012 AND
                           aux_dtiniper >= aux_datlibpr THEN
                        
                                FIND crapmfx WHERE 
                                         crapmfx.cdcooper = par_cdcooper AND
                                         crapmfx.dtmvtolt = aux_dtinipop AND
                                         crapmfx.tpmoefix = 20 NO-LOCK NO-ERROR.  
                        ELSE
                                FIND crapmfx WHERE 
                                         crapmfx.cdcooper = par_cdcooper AND
                                         crapmfx.dtmvtolt = aux_dtinipop AND
                                         crapmfx.tpmoefix = 8 NO-LOCK NO-ERROR.
                        
                        IF   NOT AVAILABLE crapmfx   THEN
                             DO:    
                                ASSIGN i-cod-erro = 211
                                       c-dsc-erro = " ".

                                {sistema/generico/includes/b1wgen0001.i}
                
                                RETURN "NOK".
                             END.
                        
                        FIND FIRST craptrd WHERE 
                                   craptrd.cdcooper = par_cdcooper AND
                                   craptrd.dtiniper = aux_dtinipop
                                   NO-LOCK NO-ERROR.
                        
                        RUN calctx_poupanca (INPUT  par_cdcooper,
                                             INPUT  craptrd.qtdiaute,
                                             INPUT  crapmfx.vlmoefix,
                                             OUTPUT aux_txmespop,
                                             OUTPUT aux_txdiapop).
                        
                        IF   aux_txaplrgt < aux_txdiapop / 100   THEN
                             ASSIGN aux_txaplrgt = aux_txdiapop / 100.
                     END.
            END.
              
       ASSIGN aux_vlrenrgt = TRUNCATE(par_vlsdrdca * aux_txaplrgt,8)
              par_vlsdrdca = par_vlsdrdca + aux_vlrenrgt 
              aux_vlrentot = aux_vlrentot + aux_vlrenrgt
              aux_dtiniper = aux_dtiniper + 1.
       
    END.  /*  Fim do DO WHILE  */

    ASSIGN aux_vlrentot = ROUND(aux_vlrentot,2)
           par_vlrenrgt = aux_vlrentot
           par_vlsdrdca = ROUND(par_vlsdrdca,2).

    RETURN "OK".

                   
END PROCEDURE. /* Fim rendi_apl_pos_com_resgate */


PROCEDURE valor_original_resgatado:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/

 /*** Calcula quanto o que esta sendo resgatado representa do total ***/  

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_dtaplrgt LIKE craprda.dtmvtolt          NO-UNDO.
    DEF        INPUT PARAM par_vlsdrdca AS DEC DECIMALS 8              NO-UNDO.
    DEF        INPUT PARAM par_perirrgt AS DEC DECIMALS 2              NO-UNDO.
    DEF       OUTPUT PARAM par_vlbasrgt AS DEC DECIMALS 6              NO-UNDO.
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    DEF                VAR aux_dtiniper LIKE craprda.dtiniper          NO-UNDO.
    DEF                VAR aux_dtfimper LIKE craprda.dtfimper          NO-UNDO.
    DEF                VAR aux_txaplrgt AS DEC DECIMALS 8              NO-UNDO.
    DEF                VAR aux_txaplcum AS DEC DECIMALS 8              NO-UNDO.
    DEF                VAR aux_percirrf AS DEC DECIMALS 4              NO-UNDO.
    
    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.

    /* Variaveis para novo calculo de poupanca */
    DEF                VAR aux_datlibpr  AS DATE                       NO-UNDO.

    ASSIGN aux_txaplcum = 0
           par_vlbasrgt = par_vlsdrdca
           aux_percirrf = par_perirrgt / 100.
        
    EMPTY TEMP-TABLE tt-erro.

    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                   
    IF   NOT AVAILABLE craprda   THEN                   
         DO: 
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    ASSIGN aux_dtiniper = craprda.dtmvtolt
           aux_dtfimper = par_dtaplrgt.

    /*** Buscar as taxas contratas ***/
    FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper       AND
                             craplap.nrdconta = craprda.nrdconta   AND
                             craplap.nraplica = craprda.nraplica   AND
                             craplap.dtmvtolt = craprda.dtmvtolt   
                             NO-LOCK NO-ERROR.

    IF   NOT AVAILABLE craplap   THEN  
         DO:                       
             ASSIGN i-cod-erro = 90
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.
    /* Data de fim e inicio da utilizacao da taxa de poupanca.
       Utiliza-se essa data quando o rendimento da aplicacao for menor que
       a poupanca, a cooperativa opta por usar ou nao. */
    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "USUARI"      AND
                       craptab.cdempres = 11            AND
                       craptab.cdacesso = "MXRENDIPOS"  AND
                       craptab.tpregist = 1 NO-LOCK NO-ERROR.
                                   
    IF   NOT AVAILABLE craptab   THEN
         ASSIGN aux_dtinitax = 01/01/9999
                aux_dtfimtax = 01/01/9999.
    ELSE
         ASSIGN aux_dtinitax = DATE(ENTRY(1,craptab.dstextab,";"))
                aux_dtfimtax = DATE(ENTRY(2,craptab.dstextab,";")).

    /* Data de liberacao do projeto novo indexador de poupanca */
    ASSIGN aux_datlibpr = 07/01/2014.

    /*** Buscar o acumulado das taxas ***/
    DO WHILE aux_dtiniper < aux_dtfimper:
       DO WHILE TRUE:
          IF   CAN-DO("1,7",STRING(WEEKDAY(aux_dtiniper)))    OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                      crapfer.dtferiad = aux_dtiniper)   THEN
               DO:
                   aux_dtiniper = aux_dtiniper + 1.
                   NEXT.
               END.

          LEAVE.
       END.  /*  Fim do DO WHILE TRUE  */
   
       IF   aux_dtiniper >= aux_dtfimper   THEN
            LEAVE.
        
       FIND crapmfx WHERE crapmfx.cdcooper = par_cdcooper   AND
                          crapmfx.dtmvtolt = aux_dtiniper   AND
                          crapmfx.tpmoefix = 6 NO-LOCK NO-ERROR. /* CDI ANO */
       
       IF   NOT AVAILABLE crapmfx   THEN  
            DO:
                
                                       
                ASSIGN i-cod-erro = 211
                       c-dsc-erro = " ".
           
                {sistema/generico/includes/b1wgen0001.i}

                RETURN "NOK".
            END.

       ASSIGN aux_txaplmes = 
                 (EXP((1 + crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100.
         
       /*** Como e resgate antes do vencimento sempre taxa minima ***/
       IF   craplap.txaplica <> craplap.txaplmes   THEN 
             ASSIGN aux_txaplrgt = 
                      ROUND((aux_txaplmes * craplap.txaplmes / 100),8).
       ELSE
            DO:
                ASSIGN aux_txaplrgt = 
                       ROUND((aux_txaplmes * craplap.txaplica / 100),8).

                IF   aux_dtiniper > aux_dtinitax     AND 
                     craprda.dtmvtolt < aux_dtfimtax THEN
                     DO:
                        /* Usar poupanca de um mes atras */
                        aux_dtinipop = DATE(MONTH(aux_dtiniper) - 1,
                                          DAY(aux_dtiniper),YEAR(aux_dtiniper)) 
                                            NO-ERROR.

                        IF   ERROR-STATUS:ERROR   THEN
                             /* Tratar anos anteriores */
                             IF   MONTH(aux_dtiniper) = 1   THEN
                                  aux_dtinipop = aux_dtiniper - 31.
                             ELSE
                                 /* Caso nao exista a data, pegar primeiro 
                                    dia do mes */  
                                  aux_dtinipop = DATE(MONTH(aux_dtiniper),01,
                                                          YEAR(aux_dtiniper)).
                        
                        /********************************************************************/
                        /** Em Maio de 2012 o novo calculo foi liberado para utilizacao,   **/
                        /** portanto aplicacoes cadastradas a partir desta data poderiam   **/
                        /** ser remuneradas conforme a nova regra, porem, em nosso sistema **/
                        /** vamos calcular o rendimento desta aplicacao com base na nova   **/
                        /** regra somente a partir da data de liberacao do projeto de novo **/
                        /** indexador de poupanca, pois o passado anterior a liberacao ja  **/
                        /** foi remunerado e contabilizado.                                 **/
                        /********************************************************************/
                        
                        
                        IF craprda.dtmvtolt >= 05/04/2012 AND
                           aux_dtiniper >= aux_datlibpr THEN
                        
                                FIND crapmfx WHERE 
                                         crapmfx.cdcooper = par_cdcooper AND
                                         crapmfx.dtmvtolt = aux_dtinipop AND
                                         crapmfx.tpmoefix = 20 NO-LOCK NO-ERROR.  
                        ELSE
                                FIND crapmfx WHERE 
                                         crapmfx.cdcooper = par_cdcooper AND
                                         crapmfx.dtmvtolt = aux_dtinipop AND
                                         crapmfx.tpmoefix = 8 NO-LOCK NO-ERROR.
                        
                        IF   NOT AVAILABLE crapmfx   THEN
                             DO:    
                                ASSIGN i-cod-erro = 211
                                       c-dsc-erro = " ".

                                {sistema/generico/includes/b1wgen0001.i}
                
                                RETURN "NOK".
                             END.
                        
                        FIND FIRST craptrd WHERE 
                                   craptrd.cdcooper = par_cdcooper AND
                                   craptrd.dtiniper = aux_dtinipop
                                   NO-LOCK NO-ERROR.
                        
                        RUN calctx_poupanca (INPUT  par_cdcooper,
                                             INPUT  craptrd.qtdiaute,
                                             INPUT  crapmfx.vlmoefix,
                                             OUTPUT aux_txmespop,
                                             OUTPUT aux_txdiapop).
                        
                        IF   aux_txaplrgt < aux_txdiapop   THEN
                             ASSIGN aux_txaplrgt = aux_txdiapop.
                     END.
            END.
       
       /*** Magui acumulando taxas ***/           
       IF   aux_txaplcum = 0   THEN
            ASSIGN aux_txaplcum = aux_txaplrgt.
       ELSE
            ASSIGN aux_txaplcum = ((aux_txaplcum / 100 + 1) *
                                   (aux_txaplrgt / 100 + 1) - 1) * 100.
       
       ASSIGN aux_dtiniper = aux_dtiniper + 1.

    END.  /*  Fim do DO WHILE  */
                
    RUN sistema/generico/procedures/b1wgen0159.p
                            PERSISTENT SET h-b1wgen0159.

    RUN verifica-imunidade-tributaria IN h-b1wgen0159(INPUT par_cdcooper,
                                                      INPUT par_nrctaapl,
                                                      INPUT TODAY,
                                                      INPUT FALSE,
                                                      INPUT 0,
                                                      INPUT 0,
                                                      OUTPUT aux_flgimune,
                                                      OUTPUT TABLE tt-erro).
    DELETE PROCEDURE h-b1wgen0159.
    
    IF  aux_flgimune  THEN    
        ASSIGN par_vlbasrgt = TRUNCATE((par_vlbasrgt / 
               (1 + ( TRUNCATE(aux_txaplcum,6) / 100))),2).
                /**par_vlbasrgt = TRUNCATE(par_vlbasrgt,2). 27/11/2013 **/
    ELSE
        ASSIGN par_vlbasrgt = TRUNCATE((par_vlbasrgt / 
               (1 + ( TRUNCATE(aux_txaplcum,6) / 100 * (1 - aux_percirrf)))),2).
               /**par_vlbasrgt = TRUNCATE(par_vlbasrgt,2). 27/11/2013 **/
    
    RETURN "OK".

END PROCEDURE. /* Fim valor_original_resgatado */



PROCEDURE extrato_rdc:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_dtiniper LIKE craprda.dtiniper          NO-UNDO.
    DEF        INPUT PARAM par_dtfimper LIKE craprda.dtfimper          NO-UNDO.
    DEF       OUTPUT PARAM TABLE FOR tt-erro.
    DEF       OUTPUT PARAM TABLE FOR tt-extr-rdc.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.
    DEF                VAR aux_dtiniimu  AS DATE                       NO-UNDO.
    DEF                VAR aux_dtfimimu  AS DATE                       NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.
 
    EMPTY TEMP-TABLE tt-extr-rdc.

     
    ASSIGN aux_sequen = 0.
    
    FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
    
    IF   NOT AVAILABLE crapdat   THEN
         DO:
             ASSIGN i-cod-erro = 1 
                    c-dsc-erro = " ".
           
             { sistema/generico/includes/b1wgen0001.i }

             RETURN "NOK".
         END.
         
    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND 
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                       
    IF   NOT AVAILABLE craprda   THEN
         DO:
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             { sistema/generico/includes/b1wgen0001.i }

             RETURN "NOK".
         END.
     
    
    RUN sistema/generico/procedures/b1wgen0159.p
                                 PERSISTENT SET h-b1wgen0159.

    RUN verifica-periodo-imune IN h-b1wgen0159(INPUT par_cdcooper,
                                               INPUT par_nrctaapl,
                                               OUTPUT aux_flgimune,
                                               OUTPUT aux_dtiniimu,
                                               OUTPUT aux_dtfimimu,
                                               OUTPUT TABLE tt-erro).
    
    DELETE PROCEDURE h-b1wgen0159.

         
    /* Lista de historicos que serao listados */
    ASSIGN aux_listahis = "527,528,529,530,531,533,534,532,472,473,474,475," +
                          "463,478,475,476,477,121,923,924,1111,1112,1113,1114" 
           aux_vlstotal = 0.

    FOR EACH craplap WHERE craplap.cdcooper = par_cdcooper                 AND
                           craplap.nrdconta = par_nrctaapl                 AND
                           craplap.nraplica = par_nraplres                 AND
                           CAN-DO(aux_listahis,STRING(craplap.cdhistor))   AND
                          (craplap.dtmvtolt >= par_dtiniper   OR
                           par_dtiniper      = ?)                          AND
                          (craplap.dtmvtolt <= par_dtfimper   OR
                           par_dtfimper      = ?)
                           NO-LOCK BY craplap.dtmvtolt
                                   BY craplap.cdhistor:

        FIND craphis WHERE craphis.cdcooper = par_cdcooper     AND
                           craphis.cdhistor = craplap.cdhistor NO-LOCK NO-ERROR.

        IF   NOT AVAILABLE craphis   THEN
             DO:
                 ASSIGN i-cod-erro = 80 
                        c-dsc-erro = " ".
           
                 { sistema/generico/includes/b1wgen0001.i }

                 RETURN "NOK".
             END.

        IF   aux_flgimune THEN
             DO:
                  IF  (craplap.cdhistor = 475             OR
                       craplap.cdhistor = 532)            AND
                       craplap.dtmvtolt >= aux_dtiniimu   AND
                      (aux_dtfimimu      = ?              OR
                      (aux_dtfimimu     <> ?              AND
                       craplap.dtmvtolt <= aux_dtfimimu)) THEN
                       aux_dshistor = STRING(craphis.cdhistor,"999") + "-" + 
                                      craphis.dshistor + "*".
                  ELSE
                       aux_dshistor = STRING(craphis.cdhistor,"999") + "-" + 
                                      craphis.dshistor.
             END.
        ELSE
             aux_dshistor = STRING(craphis.cdhistor,"999") + "-" + craphis.dshistor.
        
        IF   NOT CAN-DO("999",STRING(craphis.cdhistor))   THEN
             DO:
                  IF   craphis.indebcre = "C"   THEN
                       aux_vlstotal = aux_vlstotal + craplap.vllanmto.
                  ELSE
                  IF   craphis.indebcre = "D"   THEN
                       aux_vlstotal = aux_vlstotal - craplap.vllanmto.
                  ELSE
                       DO:
                          ASSIGN i-cod-erro = 83
                                 c-dsc-erro = " ".
           
                          { sistema/generico/includes/b1wgen0001.i }

                          RETURN "NOK".
                       END.
             END.

        CREATE tt-extr-rdc.
        ASSIGN tt-extr-rdc.dtmvtolt = craplap.dtmvtolt
               tt-extr-rdc.cdagenci = craplap.cdagenci
               tt-extr-rdc.cdbccxlt = craplap.cdbccxlt
               tt-extr-rdc.nrdolote = craplap.nrdolote
               tt-extr-rdc.cdhistor = craplap.cdhistor
               tt-extr-rdc.dshistor = aux_dshistor
               tt-extr-rdc.nrdocmto = craplap.nrdocmto
               tt-extr-rdc.indebcre = craphis.indebcre
               tt-extr-rdc.vllanmto = craplap.vllanmto
               tt-extr-rdc.vlsdlsap = aux_vlstotal
               tt-extr-rdc.txaplica = IF craplap.txaplica < 0 THEN 0
                                      ELSE craplap.txaplica
               tt-extr-rdc.vlpvlrgt = IF  craplap.cdhistor = 534  THEN
                                          craplap.vlpvlrgt
                                      ELSE
                                          0.
         
    END.  /*  Fim do FOR EACH -- Leitura dos lancamentos  */

    RETURN "OK".
 
END PROCEDURE. /* Fim extrato_rdc */



PROCEDURE provisao_rdc_pos:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/

    /* Rotina de calculo da provisao no final do mes e no vencimento. */

    DEF        INPUT PARAM par_cdcooper LIKE crapcop.cdcooper          NO-UNDO.
    DEF        INPUT PARAM par_nrctaapl LIKE craprda.nrdconta          NO-UNDO.
    DEF        INPUT PARAM par_nraplres LIKE craprda.nraplica          NO-UNDO.
    DEF        INPUT PARAM par_dtiniper LIKE craprda.dtiniper          NO-UNDO.
    DEF        INPUT PARAM par_dtfimper LIKE craprda.dtfimper          NO-UNDO.
    DEF        INPUT PARAM par_flantven AS LOGICAL                     NO-UNDO.
    DEF       OUTPUT PARAM par_vlsdrdca AS DEC DECIMALS 4
                     /*LIKE craprda.vlsdrdca Magui em 28/09/2007*/     NO-UNDO.
    DEF       OUTPUT PARAM par_vlrentot AS DEC DECIMALS 4
                     /*LIKE craprda.vlsdrdca Magui em 28/09/2007*/     NO-UNDO.
    
    DEF       OUTPUT PARAM TABLE FOR tt-erro.

    /* Variaveis para a include de erros - valores fixos usados na internet */
    DEF                VAR p-cod-agencia AS INTE   INIT 1              NO-UNDO.
    DEF                VAR p-nro-caixa   AS INTE   INIT 999            NO-UNDO.
     
    /* Variaveis para novo calculo de poupanca */
    DEF                VAR aux_datlibpr  AS DATE                       NO-UNDO.

    ASSIGN aux_dtcalcul = ?
           par_vlsdrdca = 0
           aux_vlrendim = 0
           par_vlrentot = 0.

    EMPTY TEMP-TABLE tt-erro.

    FIND craprda WHERE craprda.cdcooper = par_cdcooper   AND
                       craprda.nrdconta = par_nrctaapl   AND
                       craprda.nraplica = par_nraplres   NO-LOCK NO-ERROR.
                   
    IF   NOT AVAILABLE craprda   THEN                   
         DO: 
             ASSIGN i-cod-erro = 426
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    /*** Buscas as taxas contratadas ***/
    FIND FIRST craplap WHERE craplap.cdcooper = par_cdcooper       AND
                             craplap.nrdconta = craprda.nrdconta   AND
                             craplap.nraplica = craprda.nraplica   AND
                             craplap.dtmvtolt = craprda.dtmvtolt   
                             NO-LOCK NO-ERROR.
                                                           
    IF   NOT AVAILABLE craplap   THEN  
         DO:                       
             ASSIGN i-cod-erro = 90 
                    c-dsc-erro = " ".
           
             {sistema/generico/includes/b1wgen0001.i}

             RETURN "NOK".
         END.

    IF   par_flantven = YES   THEN /* TAXA MINIMA */
         ASSIGN par_vlsdrdca = craprda.vlsltxmm.
    ELSE     
         ASSIGN par_vlsdrdca = craprda.vlsltxmx.

    /* Data de fim e inicio da utilizacao da taxa de poupanca.
       Utiliza-se essa data quando o rendimento da aplicacao for menor que
       a poupanca, a cooperativa opta por usar ou nao. */
    FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                       craptab.nmsistem = "CRED"        AND
                       craptab.tptabela = "USUARI"      AND
                       craptab.cdempres = 11            AND
                       craptab.cdacesso = "MXRENDIPOS"  AND
                       craptab.tpregist = 1 NO-LOCK NO-ERROR.
                                    
    IF   NOT AVAILABLE craptab   THEN
         ASSIGN aux_dtinitax = 01/01/9999
                aux_dtfimtax = 01/01/9999.
    ELSE
         ASSIGN aux_dtinitax = DATE(ENTRY(1,craptab.dstextab,";"))
                aux_dtfimtax = DATE(ENTRY(2,craptab.dstextab,";")).
 
    /* Data de liberacao do projeto novo indexador de poupanca */
    ASSIGN aux_datlibpr = 07/01/2014.

    DO WHILE par_dtiniper < par_dtfimper:

       DO WHILE TRUE:
        
          IF   CAN-DO("1,7",STRING(WEEKDAY(par_dtiniper)))    OR
               CAN-FIND(crapfer WHERE crapfer.cdcooper = par_cdcooper AND
                                      crapfer.dtferiad = par_dtiniper)   THEN
               DO:
                   par_dtiniper = par_dtiniper + 1.
                   NEXT.
               END.
   
          LEAVE.
   
       END.  /*  Fim do DO WHILE TRUE  */
   
       IF   par_dtiniper >= par_dtfimper   THEN
            LEAVE.
        
       FIND crapmfx WHERE crapmfx.cdcooper = par_cdcooper   AND
                          crapmfx.dtmvtolt = par_dtiniper   AND
                          crapmfx.tpmoefix = 6 NO-LOCK NO-ERROR. /* CDI ANO */
       
       IF   NOT AVAILABLE crapmfx   THEN  
            DO:
                
                                       
                ASSIGN i-cod-erro = 211
                       c-dsc-erro = " ".
           
                {sistema/generico/includes/b1wgen0001.i}

                RETURN "NOK".
            END.

       ASSIGN aux_txaplmes = 
                 (EXP((1 + crapmfx.vlmoefix / 100),(1 / 252)) - 1) * 100.
                 
       /* Calcula o saldo com a taxa minina se for antes do vencimento */
       IF   par_flantven = YES   AND
            craplap.txaplica <> craplap.txaplmes   THEN                     
            aux_txaplica = 
                ROUND((aux_txaplmes * craplap.txaplmes / 100 ) / 100 ,8).
       ELSE 
            DO:      
                aux_txaplica =
                    ROUND((aux_txaplmes * craplap.txaplica / 100 ) / 100 ,8).
                
                IF   par_dtiniper > aux_dtinitax     AND
                     craprda.dtmvtolt < aux_dtfimtax THEN
                     DO:
                        /* Usar poupanca de um mes atras */
                        aux_dtinipop = DATE(MONTH(par_dtiniper) - 1,
                                          DAY(par_dtiniper),YEAR(par_dtiniper)) 
                                             NO-ERROR.

                        IF   ERROR-STATUS:ERROR   THEN
                             /* Tratar anos anteriores */
                             IF   MONTH(par_dtiniper) = 1   THEN
                                  aux_dtinipop = par_dtiniper - 31.
                             ELSE
                                 /* Caso nao exista a data, pegar primeiro 
                                    dia do mes */
                                  aux_dtinipop = DATE(MONTH(par_dtiniper),01,
                                                          YEAR(par_dtiniper)).

                        /********************************************************************/
                        /** Em Maio de 2012 o novo calculo foi liberado para utilizacao,   **/
                        /** portanto aplicacoes cadastradas a partir desta data poderiam   **/
                        /** ser remuneradas conforme a nova regra, porem, em nosso sistema **/
                        /** vamos calcular o rendimento desta aplicacao com base na nova   **/
                        /** regra somente a partir da data de liberacao do projeto de novo **/
                        /** indexador de poupanca, pois o passado anterior a liberacao ja  **/
                        /** foi remunerado e contabilizado.                                 **/
                        /********************************************************************/
                        
                        
                        IF craprda.dtmvtolt >= 05/04/2012 AND
                           par_dtiniper >= aux_datlibpr THEN
                        
                                FIND crapmfx WHERE 
                                         crapmfx.cdcooper = par_cdcooper AND
                                         crapmfx.dtmvtolt = aux_dtinipop AND
                                         crapmfx.tpmoefix = 20 NO-LOCK NO-ERROR.  
                        ELSE
                                FIND crapmfx WHERE 
                                         crapmfx.cdcooper = par_cdcooper AND
                                         crapmfx.dtmvtolt = aux_dtinipop AND
                                         crapmfx.tpmoefix = 8 NO-LOCK NO-ERROR. 
              
                        IF   NOT AVAILABLE crapmfx   THEN
                             DO:                       
                                ASSIGN i-cod-erro = 211
                                       c-dsc-erro = " ".
                                    
                                {sistema/generico/includes/b1wgen0001.i}

                                RETURN "NOK".
                             END.
                        
                        FIND FIRST craptrd WHERE 
                                   craptrd.cdcooper = par_cdcooper AND
                                   craptrd.dtiniper = aux_dtinipop
                                   NO-LOCK NO-ERROR.

                        RUN calctx_poupanca (INPUT  par_cdcooper,
                                             INPUT  craptrd.qtdiaute,
                                             INPUT  crapmfx.vlmoefix,
                                             OUTPUT aux_txmespop,
                                             OUTPUT aux_txdiapop).

                        IF   aux_txaplica < aux_txdiapop / 100   then
                             ASSIGN aux_txaplica = aux_txdiapop / 100.
                     END.
            END.          
                  
       ASSIGN aux_vlrendim = TRUNCATE(par_vlsdrdca * aux_txaplica,8)
              par_vlsdrdca = par_vlsdrdca + aux_vlrendim 
              par_vlrentot = par_vlrentot + aux_vlrendim
              par_dtiniper = par_dtiniper + 1.
   
    END.  /*  Fim do DO WHILE  */

    ASSIGN par_vlrentot = ROUND(par_vlrentot,4)
           par_vlsdrdca = ROUND(par_vlsdrdca,4).

    RETURN "OK".
 
END PROCEDURE. /* Fim provisao_rdc_pos */

PROCEDURE calctx_poupanca:
/******************************************************************************
                 ATENCAO - PROCEDURE MIGRADA PARA O ORACLE
                VERIFIQUE COMENTARIOS NO INICIO DESSE FONTE
******************************************************************************/


 DEF INPUT  PARAMETER par_cdcooper AS INTE                 NO-UNDO.
 DEF INPUT  PARAMETER par_qtdiaute AS INTE                 NO-UNDO.
 DEF INPUT  PARAMETER par_vlmoefix LIKE crapmfx.vlmoefix   NO-UNDO.
 DEF OUTPUT PARAMETER par_txmespop AS DECIMAL DECIMALS 6   NO-UNDO.
 DEF OUTPUT PARAMETER par_txdiapop AS DECIMAL DECIMALS 6   NO-UNDO.
 
 ASSIGN aux_qtdfaxir = 0.

 FIND craptab WHERE craptab.cdcooper = par_cdcooper  AND
                    craptab.nmsistem = "CRED"        AND
                    craptab.cdempres = 0             AND
                    craptab.tptabela = "CONFIG"      AND
                    craptab.cdacesso = "PERCIRRDCA"  AND
                    craptab.tpregist = 0             NO-LOCK NO-ERROR.

 DO aux_cartaxas = 1 TO NUM-ENTRIES(craptab.dstextab,";"):
    ASSIGN aux_vllidtab = ENTRY(aux_cartaxas,craptab.dstextab,";")
           aux_qtdfaxir = aux_qtdfaxir + 1
           aux_qtmestab[aux_qtdfaxir] = DECIMAL(ENTRY(1,aux_vllidtab,"#"))
           aux_perirtab[aux_qtdfaxir] = DECIMAL(ENTRY(2,aux_vllidtab,"#")).
 END. /* Fim do DO TO */
 
 ASSIGN par_txmespop = ROUND(par_vlmoefix / (1 - (aux_perirtab[1] / 100)),6)
        par_txdiapop = ROUND(((EXP(1 + (par_txmespop / 100),
                                        1 / par_qtdiaute) - 1) * 100),6).

END PROCEDURE.

PROCEDURE controla_imunidade:
    
    DEF INPUT PARAM par_flginsta AS LOG                              NO-UNDO.
    DEF INPUT PARAM par_flgdelet AS LOG                              NO-UNDO.
    DEF INPUT PARAM par_cdprogra AS CHAR                             NO-UNDO.
    
    
    IF  par_flginsta THEN
        DO:
            ASSIGN aux_flgbo159 = TRUE.

            RUN sistema/generico/procedures/b1wgen0159.p 
                PERSISTENT SET h-b1wgen0159.
                        
            IF   NOT VALID-HANDLE(h-b1wgen0159) THEN
                 DO: 
                     UNIX SILENT VALUE("echo " + 
                                        STRING(TIME,"HH:MM:SS") +
                                        " - " + par_cdprogra + "' --> '" +
                                        "Handle Invalido para BO b1wgen0159" +
                                        " >> log/proc_batch.log").
                     RETURN "NOK".
                     
                 END.

        END.

    IF  par_flgdelet THEN
        DO:
            ASSIGN aux_flgbo159 = FALSE.
            DELETE PROCEDURE h-b1wgen0159.
        END.
        

END.

/*.......................................................................... */
 
