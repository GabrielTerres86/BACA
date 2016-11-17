/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +------------------------------------+-------------------------------------+
  | Rotina Progress                    | Rotina Oracle PLSQL                 |
  +------------------------------------+-------------------------------------+
  | procedures/b1wgen0045.p	           |        	                         |
  | valor-convenios                    | CONV0001.pc_valor_convenios         |
  | grava_tt_convenio                  | CONV0001.pc_grava_tt_convenio       |
  | popula_tt                          | CONV0001.pc_popula_tt               |
  | grava_tt_convenio_debitos          | CONV0001.pc_gera_tt_convenio_debitos | 
  | seguros-resid-vida                 | SEGU0001.pc_seguros_resid_vida      | 
  | seguros-auto                       | SEGU0001.pc_seguros_auto            |
  | proc_contabiliza                   | SEGU0001.pc_proc_contabiliza        |
  | busca_dados_seg                    | SEGU0001.pc_busca_dados_seg         | 
  | limite-cartao-credito              | CCRD0001.pc_limite_cartao_credito   |
  | beneficios-inss                    | INSS0001.pc_beneficios_inss         |   
  +------------------------------------+-------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/











/*..............................................................................

    Programa: b1wgen0045.p
    Autor   : Guilherme - Precise
    Data    : Outubro/2009                       Ultima Atualizacao: 25/06/2015
           
    Dados referentes ao programa:
                
    Objetivo  : BO para unificacao de funcoes com o CRPS524.
                Programas com funcoes em comum com CRPS524:
                    - CCARBB
                    - CRPS138 relat 115 - Qntde Cooperados
                    - RELINS relat 470 - Beneficios INSS
                    - CRPS483 relat 450 - Inf. de Convenios
                    - RELSEG Op "R" 4 - Inf. de Seguros
    
    Alteracoes: 18/03/2010 - Incluido novo campo para guardar o numero de 
                             cooperados com debito automatico, que tiveram
                             debitos no mes (Elton).
                             
                14/05/2010 - Incluido novo parametro na procedure 
                             valor-convenios com a quantidade de cooperados que
                             tiveram pelo menos um debito automatico no mes,
                             independente do convenio. (Elton).
    
                04/06/2010 - Incluido tratamento para tarifa TAA (Elton).
                
                15/03/2011 - Inclusao dos parametros ret_vlcancel e ret_qtcancel
                             na procedure limite-cartao-credito (Vitor)  
                             
                20/03/2012 - Alterado o parametro aux_qtassdeb para a table
                             crawass na procedure valor-convenios (Adriano).
                             
                25/04/2012 - Incluido novo parametro na procedure 
                             limite-cartao-credito. (David Kruger).
                
                22/06/2012 - Substituido gncoper por crapcop (Tiago). 
                
                05/09/2012 - Alteracao na leitura da situacao de cartoes de 
                             Creditos (David Kruger). 
                             
                22/02/2013 - Incluido novas procedures para utilizacao da tela
                             RELSEG no AYLLOS e WEB (David Kruger).
                             
                21/06/2013 - Contabilizando crawcrd.insitcrd = 7 como "em uso"
                             (Tiago).
                
                12/11/2013 - Nova forma de chamar as agências, de PAC agora 
                             a escrita será PA (Guilherme Gielow)         
                             
                09/12/2013 - Ajuste na criacao da temp-table tt-info-seguros 
                             (David)            
                             
                18/02/2014 - Implementação de impressão em .txt para
                             Relatório Tp. 5 (Lucas).
                             
                30/04/2014  Ajuste gerais em inicia-relatorio. 
                            (Jorge/Guilherme) SD 126151 - RELSEG
                            
                30/05/2014 - Ajuste na forma de deducao de IOF sob o valor
                             do premio. (Chamado 145270) - (Fabricio)
                             
                17/06/2014 - Apenas carregar dados de seguro de vida caso tipo do
                             relatório for menor do que 5 (SD. 168900 - Lunelli)
                             
                03/11/2014 - Alteração da mensagem com critica 77 substituindo pela 
                           b1wgen9999.p procedure acha-lock, que identifica qual 
                           é o usuario que esta prendendo a transaçao. (Vanessa)
                             
                25/06/2015 - Alterar para gravar a variavel aux_dadosusr na aux_dscritic.
                           - Alterado procedure seguros-resid-vida para meolhorar a
                             performace. (Lucas Ranghetti/Thiago Rodrigues #300957 )
                         
..............................................................................*/

/*................................ DEFINICOES ................................*/

{ sistema/generico/includes/b1wgen0045tt.i }
{ sistema/generico/includes/b1wgen0033tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/var_oracle.i }

DEF STREAM str_1.

DEF VAR aux_nrdrowid AS ROWID                                          NO-UNDO.

DEF VAR aux_cdcritic AS INTE                                           NO-UNDO.

DEF VAR aux_dscritic AS CHAR                                           NO-UNDO.
DEF VAR aux_dstransa AS CHAR                                           NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                           NO-UNDO.

/*Convenios*/
DEF  VAR tot_vlfatura         AS DECI                           NO-UNDO.
DEF  VAR tot_vltarifa         AS DECI                           NO-UNDO.
DEF  VAR tot_vlapagar         AS DECI                           NO-UNDO.
DEF  VAR aux_nrseqdig         AS INTE                           NO-UNDO.
DEF  VAR aux_vltarifa         AS DECI                           NO-UNDO.
DEF  VAR aux_vltrfnet         AS DECI                           NO-UNDO.
DEF  VAR aux_vltrftaa         AS DECI                           NO-UNDO.

DEF  VAR aux_cdcooper         AS INTE                           NO-UNDO.
DEF  VAR aux_dataini          AS DATE                           NO-UNDO.
DEF  VAR aux_datafim          AS DATE                           NO-UNDO.
DEF  VAR tot_dbautass         AS INTE                           NO-UNDO.

DEF VAR h-b1wgen0024 AS HANDLE                                  NO-UNDO.
DEF VAR h-b1wgen0033 AS HANDLE                                  NO-UNDO.

DEF VAR aux_dadosusr AS CHAR                                    NO-UNDO.
DEF VAR par_loginusr AS CHAR                                    NO-UNDO.
DEF VAR par_nmusuari AS CHAR                                    NO-UNDO.
DEF VAR par_dsdevice AS CHAR                                    NO-UNDO.
DEF VAR par_dtconnec AS CHAR                                    NO-UNDO.
DEF VAR par_numipusr AS CHAR                                    NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.


DEF TEMP-TABLE w_histor NO-UNDO
    FIELD cdcooper  AS INTE
    FIELD cdhistor  AS INTE.

/*............................ PROCEDURES EXTERNAS ...........................*/
                      
/******************************************************************************/
/**           Procedure para obter limite de Cartao Credito BB               **/
/**           Relacionados: CRPS524 e CCARBB                                 **/
/******************************************************************************/
PROCEDURE limite-cartao-credito:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_bradesbb AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdageini AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagefim AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM ret_vllimcon   AS DECI                         NO-UNDO.
    DEF OUTPUT PARAM ret_vlcreuso   AS DECI                         NO-UNDO.
    DEF OUTPUT PARAM ret_vlsaquso   AS DECI                         NO-UNDO.
    DEF OUTPUT PARAM ret_qtdemuso   AS INTE                         NO-UNDO.
    DEF OUTPUT PARAM ret_vlcresol   AS DECI                         NO-UNDO.
    DEF OUTPUT PARAM ret_vlsaqsol   AS DECI                         NO-UNDO.
    DEF OUTPUT PARAM ret_qtdsolic   AS INTE                         NO-UNDO.
    DEF OUTPUT PARAM ret_qtcartao   AS INTE                         NO-UNDO.
    DEF OUTPUT PARAM ret_valorcre   AS DECI                         NO-UNDO.
    DEF OUTPUT PARAM ret_valordeb   AS DECIMAL                      NO-UNDO.

    DEF OUTPUT PARAM ret_vlcancel   AS DECI                         NO-UNDO.
    DEF OUTPUT PARAM ret_qtcancel   AS INTE                         NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR w-limites.
    DEF OUTPUT PARAM ret_vltotsaq   AS DECI                         NO-UNDO.

    DEF   VAR dec_valorbra   AS DECIMAL                             NO-UNDO.
    DEF   VAR dec_valordbb   AS DECIMAL                             NO-UNDO.
    DEF   VAR dec_debitbra   AS DECIMAL                             NO-UNDO.
    DEF   VAR dec_debitabb   AS DECIMAL                             NO-UNDO.

    ASSIGN ret_vlcreuso = 0
           ret_vllimcon = 0
           ret_vlsaquso = 0
           ret_qtdemuso = 0
           ret_vlcresol = 0
           ret_vlsaqsol = 0
           ret_qtdsolic = 0
           ret_vlcreuso = 0
           ret_valorcre = 0
           ret_valordeb = 0
           ret_vlcancel = 0
           ret_qtcancel = 0
           ret_vltotsaq = 0.

    /** Busca valor de limites de credito e debito Bradesco/BB **/
    FIND craptab WHERE craptab.cdcooper = par_cdcooper AND 
                       craptab.nmsistem = "CRED"       AND 
                       craptab.tptabela = "USUARI"     AND 
                       craptab.cdempres = 11           AND 
                       craptab.cdacesso = "VLCONTRCRD" AND 
                       craptab.tpregist = 0
                       NO-LOCK NO-ERROR.

    CASE par_bradesbb:
        WHEN YES THEN  /* pega vlr credito e deb Bradesco */
              ASSIGN dec_valorbra = DEC(SUBSTRING(craptab.dstextab,1,12))
                     dec_debitbra = DEC(SUBSTRING(craptab.dstextab,27,12))
                     ret_valorcre = dec_valorbra
                     ret_valordeb = dec_debitbra.
        WHEN NO THEN   /* pega vlr cred e debito BB  */
             ASSIGN dec_valordbb = DEC(SUBSTRING(craptab.dstextab,14,12))
                    ret_valorcre = dec_valordbb
                    dec_debitabb = DEC(SUBSTRING(craptab.dstextab,40,12)) 
                    ret_valordeb = dec_debitabb
                    ret_vltotsaq = DEC(SUBSTRING(craptab.dstextab,53,12)). 
    END CASE.
    /** Busca valor de limites de credito e debito Bradesco/BB **/
    

    /** Inicio **/
   FOR EACH crawcrd WHERE  crawcrd.cdcooper  = par_cdcooper
                      AND ((crawcrd.cdadmcrd > 82
                      AND   crawcrd.cdadmcrd < 89
                      AND       par_bradesbb = NO) OR
                          (crawcrd.cdadmcrd  =  3
                      AND       par_bradesbb = YES))
                      AND CAN-DO("0,1,2,3,4,5,7",STRING(crawcrd.insitcrd)) NO-LOCK:       

       IF   par_cddopcao = "V"  THEN
            DO:
                 FIND crapass WHERE crapass.cdcooper    = par_cdcooper
                                AND crapass.nrdconta    = crawcrd.nrdconta
                                AND ((crapass.cdagenci >= par_cdageini
                                AND   crapass.cdagenci <= par_cdagefim)
                                 OR  (crapass.cdagenci  = par_cdageini
                                AND       par_cdageini <> 0)) NO-LOCK NO-ERROR.
                       
                 IF NOT AVAILABLE crapass  THEN
                    NEXT.
            END.
            
       FIND craptlc WHERE craptlc.cdcooper = par_cdcooper
                      AND craptlc.cdadmcrd = crawcrd.cdadmcrd
                      AND craptlc.tpcartao = crawcrd.tpcartao
                      AND craptlc.cdlimcrd = crawcrd.cdlimcrd
                      AND craptlc.dddebito = 0  NO-LOCK NO-ERROR.

       FIND crapass WHERE crapass.cdcooper = par_cdcooper
                      AND crapass.nrdconta = crawcrd.nrdconta
                  NO-LOCK NO-ERROR.

/*............................................................................*/
       IF par_cddopcao = "C"  THEN
            DO:
/*Situacoes: 0-estudo, 1-aprov., 2-solic., 3-liber., 4-em uso, 5-canc., 7-2via*/
                IF crawcrd.insitcrd = 4  THEN
                   DO:
                      ASSIGN ret_vlcreuso = ret_vlcreuso + craptlc.vllimcrd
                             ret_qtdemuso = ret_qtdemuso + 1.

                      IF par_bradesbb   THEN
                         ret_vlsaquso = ret_vlsaquso + (craptlc.vllimcrd / 2).
                      ELSE
                         ret_vlsaquso = ret_vlsaquso + crapass.vllimdeb.
                   END.
                ELSE
                IF crawcrd.insitcrd = 5  THEN
                   DO:
                      ASSIGN ret_vlcancel = ret_vlcancel + craptlc.vllimcrd
                             ret_qtcancel = ret_qtcancel + 1.

                   END.
                ELSE
                IF crawcrd.insitcrd = 7  THEN /*contabilizar como - em uso */
                   DO:
                        ASSIGN ret_vlcreuso = ret_vlcreuso + craptlc.vllimcrd
                               ret_qtdemuso = ret_qtdemuso + 1.
    
                        IF par_bradesbb   THEN
                           ret_vlsaquso = ret_vlsaquso + (craptlc.vllimcrd / 2).
                        ELSE
                           ret_vlsaquso = ret_vlsaquso + crapass.vllimdeb.
                   END.
                ELSE  /* Solicitado */ 
                   DO:
                      ASSIGN ret_vlcresol = ret_vlcresol + craptlc.vllimcrd
                               ret_qtdsolic = ret_qtdsolic + 1.
                      IF par_bradesbb   THEN
                         ret_vlsaqsol = ret_vlsaqsol + (craptlc.vllimcrd / 2).
                      ELSE
                         ret_vlsaqsol = ret_vlsaqsol + crapass.vllimdeb.
                   END.
            END.
       ELSE
           IF  crawcrd.insitcrd <> 5  THEN
               DO:
                   CREATE w-limites.
                   ASSIGN w-limites.cdagenci = crapass.cdagenci
                          w-limites.nrdconta = crawcrd.nrdconta
                          w-limites.cdadmcrd = crawcrd.cdadmcrd
                          w-limites.nrcrcard = crawcrd.nrcrcard
                          w-limites.nmtitcrd = crawcrd.nmtitcrd   
                          w-limites.insitcrd = crawcrd.insitcrd
                          w-limites.vllimcrd = craptlc.vllimcrd
                          w-limites.vllimdeb = crapass.vllimdeb
                          w-limites.dtmvtolt = crawcrd.dtmvtolt
                          w-limites.dtentreg = crawcrd.dtentreg
                          
                          ret_qtcartao = ret_qtcartao + 1.
               END.                                               
    END.          /* Fim do FOR EACH */
    /** FIM **/


    /*P.O.G*/
    FOR EACH crawcrd WHERE crawcrd.cdcooper   = par_cdcooper
                       AND crawcrd.cdadmcrd =  3 
                       AND (crawcrd.insitcrd = 4 /*em uso*/ OR 
                            crawcrd.insitcrd = 7 /*solic 2via*/) NO-LOCK:
       FIND craptlc WHERE craptlc.cdcooper = par_cdcooper
                      AND craptlc.cdadmcrd = crawcrd.cdadmcrd
                      AND craptlc.tpcartao = crawcrd.tpcartao
                      AND craptlc.cdlimcrd = crawcrd.cdlimcrd
                      AND craptlc.dddebito = 0  NO-LOCK NO-ERROR.

            ASSIGN ret_vllimcon = ret_vllimcon + craptlc.vllimcrd. 

    END.  /*FIM FOR EACH*/

    RETURN "OK".

END PROCEDURE.



/******************************************************************************/
/**           Procedure para obter a quantidade de cooperados                **/
/**           Relacionados: CRPS524 e CRPS138 relat 115                      **/
/******************************************************************************/
PROCEDURE quantidade-cooperados:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageini AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagefim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dataini  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_datafim  AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM ret_qtdcoope AS INTE                           NO-UNDO.
    
    /*AVALIAR A NECESSIDADE*/
    /*Quantidade de Cooperados é campo da CRAPGER [qtassoci] 
     nao é calculado... manter da forma que está ?*/

    RETURN "OK".                                                   
    
END PROCEDURE.
/*............................................................................*/


/******************************************************************************/
/**           Procedure para obter valor Beneficios INSS pagos               **/
/**           Relacionados: CRPS524 e RELINS => CONGPR                       **/
/******************************************************************************/
PROCEDURE beneficios-inss:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdageini AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagefim AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dataini  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_datafim  AS DATE                           NO-UNDO.
    
    DEF OUTPUT PARAM ret_geralcre AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM ret_quantger AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_geraldcc AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM ret_quantge2 AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_valorger AS DECI                           NO-UNDO.
    DEF OUTPUT PARAM ret_geralpac AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_arqvazio AS LOGI                           NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-tela-inss.
    DEF OUTPUT PARAM TABLE FOR tt-result-inss.

    EMPTY TEMP-TABLE tt-tela-inss.
    EMPTY TEMP-TABLE tt-result-inss.

    FOR EACH craplbi WHERE craplbi.cdcooper  = par_cdcooper
                       AND craplbi.cdagenci >= par_cdageini
                       AND craplbi.cdagenci <= par_cdagefim
                       AND craplbi.dtdpagto >= par_dataini
                       AND craplbi.dtdpagto <= par_datafim NO-LOCK
                  BREAK BY craplbi.cdagenci
                        BY craplbi.dtdpagto:

       ret_arqvazio = FALSE.

       CREATE tt-tela-inss.

       IF FIRST-OF(craplbi.cdagenci)  THEN DO:
           CREATE tt-result-inss.
           ASSIGN tt-result-inss.cdcooper = craplbi.cdcooper
                  tt-result-inss.cdagenci = craplbi.cdagenci.
       END.

       CASE craplbi.tpmepgto:
           WHEN 1 THEN
                     /*Zera*/
              ASSIGN tt-result-inss.totalcre  =
                               tt-result-inss.totalcre + craplbi.vlliqcre
                     tt-result-inss.quantida  =
                               tt-result-inss.quantida + 1
                     /*mostra se for pac 0*/
                     ret_geralcre  = ret_geralcre + craplbi.vlliqcre
                     ret_quantger  = ret_quantger + 1.
           WHEN 2 THEN
              ASSIGN tt-result-inss.totaldcc  = /*Zera*/
                               tt-result-inss.totaldcc + craplbi.vlliqcre
                     tt-result-inss.quantid2  = /*Zera*/
                               tt-result-inss.quantid2 + 1
                     /*mostra se for pac 0*/
                     ret_geraldcc  = ret_geraldcc + craplbi.vlliqcre
                     ret_quantge2  = ret_quantge2 + 1.
       END CASE.

       ASSIGN tt-result-inss.totalpac =
                        tt-result-inss.totalcre + tt-result-inss.totaldcc
              tt-result-inss.quantpac =
                        tt-result-inss.quantida + tt-result-inss.quantid2
              /*mostra se for pac 0*/
              ret_valorger  = ret_geralcre + ret_geraldcc
              ret_geralpac  = ret_quantger + ret_quantge2.
/*............................................................................*/
       CASE craplbi.tpmepgto:
           WHEN 1 THEN DO:
                /* Busca o registro de pagamento */
                FIND craplpi WHERE craplpi.cdcooper = craplbi.cdcooper
                               AND craplpi.nrbenefi = craplbi.nrbenefi
                               AND craplpi.nrrecben = craplbi.nrrecben
                           NO-LOCK NO-ERROR.
                IF AVAIL craplpi THEN
                   DO:
                      IF craplpi.tppagben = 1   THEN
                         tt-tela-inss.tpmepgto  = "Cartao".
                      ELSE
                         tt-tela-inss.tpmepgto  = "Recibo".

                      tt-tela-inss.vldoipmf = craplpi.vldoipmf.
                   END.

           END.
           WHEN 2 THEN DO:
                ASSIGN tt-tela-inss.tpmepgto = "Conta Corrente"
                       tt-tela-inss.vldoipmf = 0.
           END.
       END CASE.
/*............................................................................*/
       /* Nome do beneficiario NIT */
       FIND crapcbi WHERE crapcbi.cdcooper = par_cdcooper       AND
                          crapcbi.nrrecben = craplbi.nrrecben   AND
                          crapcbi.nrbenefi = 0
                          NO-LOCK NO-ERROR.

       /* Nome do beneficiario NB */
       IF   NOT AVAILABLE crapcbi   THEN
            FIND crapcbi WHERE crapcbi.cdcooper = par_cdcooper       AND
                               crapcbi.nrrecben = 0                  AND
                               crapcbi.nrbenefi = craplbi.nrbenefi
                               NO-LOCK NO-ERROR.

       ASSIGN tt-tela-inss.cdcooper = craplbi.cdcooper
              tt-tela-inss.cdagenci = craplbi.cdagenci
/*               tt-tela-inss.nmagenci = crapage.nmresage */
              tt-tela-inss.dtdpagto = craplbi.dtdpagto
              tt-tela-inss.nrbenefi = craplbi.nrbenefi
              tt-tela-inss.nrrecben = craplbi.nrrecben
              tt-tela-inss.nrdconta = craplbi.nrdconta
              tt-tela-inss.nmrecben = crapcbi.nmrecben
              tt-tela-inss.vllanmto = craplbi.vllanmto
              tt-tela-inss.vlliqcre = craplbi.vlliqcre.
/*............................................................................*/
   END. /* Fim do FOR EACH */ 

   RETURN "OK".                                                   
    
END PROCEDURE.
/*............................................................................*/



/******************************************************************************/
/**           Procedure para obter Informacao de Convenios                   **/
/**           Relacionados: CRPS524 e CRPS483 relat 450                      **/
/******************************************************************************/
PROCEDURE valor-convenios:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dataini  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_datafim  AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR crawass.
    DEF OUTPUT PARAM TABLE FOR tt_convenio.
    EMPTY TEMP-TABLE tt_convenio.

    /* Atribui na global para ser vista pela grava_tt_convenio*/
    ASSIGN aux_cdcooper = par_cdcooper
           aux_dataini  = par_dataini
           aux_datafim  = par_datafim.

    EMPTY TEMP-TABLE crawass. 

/*............................................................................*/
    FOR EACH gncvcop NO-LOCK
       WHERE gncvcop.cdcooper = par_cdcooper
       BREAK BY gncvcop.cdconven:
    
        /*OBS: O FOR EACH abaixo esta correto sem utilizar o cdCooper pois
               neste caso, este campo indica somente qual a cooperativa que
               firmou o convenio com a empresa em questao */
        FOR EACH gnconve NO-LOCK
           WHERE gnconve.cdconven = gncvcop.cdconven
             AND ((gnconve.cdhisdeb > 0 AND gnconve.nmarqdeb <> " ")
              OR  (gnconve.cdhiscxa > 0)),
           FIRST crapcop NO-LOCK
           WHERE crapcop.cdcooper = gnconve.cdcooper:
        
        /* AVALIAR */
/*         glb_dscritic = "Executando Resumo de Convenio Mensal ". */
/*         UNIX SILENT VALUE ("echo " + STRING(TIME,"HH:MM:SS") +  */
/*                            " - " + glb_cdprogra + "' --> '" +   */
/*                            glb_dscritic +                       */
/*                            " >> log/proc_batch.log").           */

            ASSIGN aux_vltarifa = gnconve.vltrfcxa
                   aux_vltrfnet = gnconve.vltrfnet
                   aux_vltrftaa = gnconve.vltrftaa.
                        
            IF   gnconve.cdhiscxa <> 373   THEN /* IPTU Blumenau */
                  RUN grava_tt_convenio.

            /* Somente convenios com debito automatico. Mesmo que rotina CRPS388 */ 
            IF   gnconve.nmarqdeb <> " "   THEN
                 DO:
                     ASSIGN aux_vltarifa = gnconve.vltrfdeb.
    
                     RUN grava_tt_convenio_debitos.
                 END.
        END.  /* for each gnconve */

    END.  /* for each gncvcop */
    
    
/*............................................................................*/
    
END PROCEDURE.


/******************************************************************************/
/**           Procedure chamada pela valor-convenios [exclusiva]             **/
/******************************************************************************/
PROCEDURE grava_tt_convenio.

    DEF VAR aux_dtmvtolt    AS DATE                 NO-UNDO.

    ASSIGN aux_nrseqdig = 0
           tot_vlfatura = 0 
           tot_vltarifa = 0 
           tot_vlapagar = 0. 

    EMPTY TEMP-TABLE cratlft.
    
    DO  aux_dtmvtolt = aux_dataini TO aux_datafim:
    
        FOR EACH craplft WHERE (craplft.cdcooper = aux_cdcooper  AND
                                craplft.dtvencto = aux_dtmvtolt  AND
                                craplft.insitfat = 1             AND
                                craplft.cdhistor = gnconve.cdhiscxa)   OR

                               (craplft.cdcooper = aux_cdcooper  AND
                                craplft.dtvencto = aux_dtmvtolt  AND
                                craplft.insitfat = 2             AND
                                craplft.cdhistor = gnconve.cdhiscxa)
                                NO-LOCK:
            CREATE cratlft.
            ASSIGN cratlft.cdagenci = craplft.cdagenci
                   cratlft.vllanmto = craplft.vllanmto.
        END.    
    END.
    
    FOR EACH cratlft NO-LOCK BREAK BY cratlft.cdagenci:

        ASSIGN aux_nrseqdig = aux_nrseqdig + 1
               tot_vlfatura = tot_vlfatura + cratlft.vllanmto.

        /*** quebra de PAC ******/
        IF   LAST-OF(cratlft.cdagenci)   THEN
             DO:
                 /* alimenta tarifa diferenciada para pac internet */
                 IF   cratlft.cdagenci = 90   THEN
                      tot_vltarifa = aux_nrseqdig * aux_vltrfnet.
                 ELSE /** tarifa para pagamento atraves de TAA **/
                 IF   cratlft.cdagenci = 91   THEN  
                      tot_vltarifa = aux_nrseqdig * aux_vltrftaa.
                 ELSE
                      tot_vltarifa = aux_nrseqdig * aux_vltarifa.
            
                 ASSIGN tot_vlapagar = tot_vlfatura - tot_vltarifa.

                 RUN popula_tt (INPUT 1,
                                INPUT gnconve.cdconven,
                                INPUT cratlft.cdagenci,
                                INPUT aux_nrseqdig,
                                INPUT tot_vlfatura,
                                INPUT tot_vltarifa,
                                INPUT tot_vlapagar,
                                INPUT tot_dbautass).  

                 ASSIGN aux_nrseqdig = 0
                        tot_vlfatura = 0 
                        tot_vltarifa = 0 
                        tot_vlapagar = 0.                      
                   
             END.    /*** quebra de PAC ******/
    END.  /* For each craplft */
    

    RETURN "OK".                                                   
    
END PROCEDURE.
/*............................................................................*/


/******************************************************************************/
/**           Procedure chamada pela valor-convenios [exclusiva]             **/
/******************************************************************************/
PROCEDURE grava_tt_convenio_debitos.

    DEF VAR aux_dtmvtolt    AS DATE                 NO-UNDO.
    
    ASSIGN aux_nrseqdig = 0
           tot_vlfatura = 0 
           tot_vltarifa = 0 
           tot_vlapagar = 0.

    
    EMPTY TEMP-TABLE cratlcm.
    
    DO  aux_dtmvtolt = aux_dataini TO aux_datafim:
    
        FOR EACH craplcm WHERE craplcm.cdcooper = aux_cdcooper       AND
                               craplcm.dtmvtolt = aux_dtmvtolt       AND
                               craplcm.cdhistor = gnconve.cdhisdeb   NO-LOCK
                               USE-INDEX craplcm4:

            CREATE cratlcm.
            ASSIGN cratlcm.nrdconta = craplcm.nrdconta
                   cratlcm.vllanmto = craplcm.vllanmto.
        END.
    END.
    

    FOR EACH  cratlcm NO-LOCK,
        FIRST crapass WHERE crapass.cdcooper = aux_cdcooper       AND
                            crapass.nrdconta = cratlcm.nrdconta   NO-LOCK
                            BREAK BY crapas.cdagenci:

        ASSIGN aux_nrseqdig = aux_nrseqdig + 1
               tot_vlfatura = tot_vlfatura + cratlcm.vllanmto.

        
          
        FIND  cratass WHERE  cratass.nrdconta = crapass.nrdconta 
                             NO-ERROR.
        
        IF   NOT AVAIL cratass THEN
             DO:
                 CREATE cratass.
                 ASSIGN cratass.nrdconta = crapass.nrdconta.
             END.
             
           
        /** Cooperados que possuem pelo menos um debito automatico
            independente do convenio **/
        FIND  crawass WHERE  crawass.nrdconta = crapass.nrdconta 
                             NO-ERROR.
        
        IF   NOT AVAIL crawass THEN
             DO:
                 CREATE crawass.
                 ASSIGN crawass.nrdconta = crapass.nrdconta
                        crawass.cdagenci = crapass.cdagenci.
             END.

        /*** quebra de PAC ******/
        IF   LAST-OF(crapass.cdagenci)   THEN
             DO:
                 ASSIGN tot_vltarifa = aux_nrseqdig * aux_vltarifa
                        tot_vlapagar = tot_vlfatura - tot_vltarifa.

                 FOR EACH cratass:
                     tot_dbautass = tot_dbautass + 1.
                 END.
                        
                 
                 RUN popula_tt (INPUT 2,
                                INPUT gnconve.cdconven,
                                INPUT crapass.cdagenci,
                                INPUT aux_nrseqdig,
                                INPUT tot_vlfatura,
                                INPUT tot_vltarifa,
                                INPUT tot_vlapagar,
                                INPUT tot_dbautass).  

                 ASSIGN aux_nrseqdig = 0
                        tot_vlfatura = 0 
                        tot_vltarifa = 0 
                        tot_vlapagar = 0                      
                        tot_dbautass = 0.
                        
                 EMPTY TEMP-TABLE cratass. 
                   
             END.    /*** quebra de PAC ******/
    END.  /* For each craplcm */


END PROCEDURE.

/******************************************************************************/
/**           Procedure chamada pela valor-convenios [exclusiva]             **/
/******************************************************************************/
PROCEDURE popula_tt.

    /* tipo=> 1 (pago caixa), 2 (debito autom)*/
    DEF INPUT PARAMETER p_tipo     AS INT                           NO-UNDO.
    DEF INPUT PARAMETER p_cdconven LIKE gnconve.cdconven            NO-UNDO.
    DEF INPUT PARAMETER p_cdagenci LIKE craplft.cdagenci            NO-UNDO.
    DEF INPUT PARAMETER p_nrseqdig AS DEC                           NO-UNDO.
    DEF INPUT PARAMETER p_vlfatura AS DEC                           NO-UNDO.
    DEF INPUT PARAMETER p_vltarifa AS DEC                           NO-UNDO.
    DEF INPUT PARAMETER p_vlapagar AS DEC                           NO-UNDO.
    DEF INPUT PARAMETER p_qtdebaut AS INT                           NO-UNDO.

    /* popular Temp-table de Convenio */
    FIND FIRST tt_convenio NO-LOCK WHERE
               tt_convenio.cdconven = p_cdconven AND 
               tt_convenio.cdagenci = p_cdagenci NO-ERROR.
    
    IF   AVAILABLE tt_convenio   THEN
         DO:
             IF   p_tipo = 1   THEN
                  DO:
                      ASSIGN tt_convenio.qtfatura = tt_convenio.qtfatura +
                                                    p_nrseqdig
                             tt_convenio.vlfatura = tt_convenio.vlfatura +
                                                    p_vlfatura
                             tt_convenio.vltarifa = tt_convenio.vltarifa + 
                                                    p_vltarifa
                             tt_convenio.vlapagar = tt_convenio.vlapagar +
                                                    p_vlapagar.
                  END.
             ELSE
                  DO:  
                      ASSIGN tt_convenio.qtdebito = tt_convenio.qtdebito +
                                                    p_nrseqdig
                             tt_convenio.vldebito = tt_convenio.vldebito +
                                                    p_vlfatura
                             tt_convenio.vltardeb = tt_convenio.vltardeb +
                                                    p_vltarifa
                             tt_convenio.vlapadeb = tt_convenio.vlapadeb +
                                                    p_vlapagar.
                             tt_convenio.qtdebaut = tt_convenio.qtdebaut +
                                                    p_qtdebaut.
                  END.
         END.
    ELSE
         DO:
             CREATE tt_convenio.
             ASSIGN tt_convenio.cdagenci = p_cdagenci
                    tt_convenio.cdconven = p_cdconven.

             IF   p_tipo = 1   THEN
                  DO:  
                      ASSIGN tt_convenio.qtfatura = p_nrseqdig
                             tt_convenio.vlfatura = p_vlfatura
                             tt_convenio.vltarifa = p_vltarifa
                             tt_convenio.vlapagar = p_vlapagar.
                  END.
             ELSE
                  DO:          
                      ASSIGN tt_convenio.qtdebito = p_nrseqdig
                             tt_convenio.vldebito = p_vlfatura
                             tt_convenio.vltardeb = p_vltarifa
                             tt_convenio.vlapadeb = p_vlapagar
                             tt_convenio.qtdebaut = p_qtdebaut. 
                  END.
         END.
         
END PROCEDURE.


/******************************************************************************/
/**           Procedure para obter Informacao de Seguros Vida e Residencial  **/
/**           Relacionados: CRPS524 e RELSEG                                 **/
/******************************************************************************/
PROCEDURE seguros-resid-vida:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dataini  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_datafim  AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM TABLE FOR w_histor.

    DEF OUTPUT PARAM TABLE FOR w-seguro.

    DEF VAR aux_tpseguro AS INTE                                    NO-UNDO.
                                                                    
    DEF VAR aux_data AS DATE                                        NO-UNDO.

    DO  aux_data = par_dataini TO par_datafim:

        FOR EACH w_histor WHERE w_histor.cdcooper = par_cdcooper NO-LOCK: 
    
            FOR EACH craplcm WHERE craplcm.cdcooper = par_cdcooper
                               AND craplcm.dtmvtolt = aux_data
                               AND craplcm.cdhistor = w_histor.cdhistor NO-LOCK
                               USE-INDEX craplcm4,
                FIRST crapass WHERE crapass.cdcooper  = craplcm.cdcooper
                                AND crapass.nrdconta  = craplcm.nrdconta 
                                NO-LOCK:

                ASSIGN aux_tpseguro = IF   craplcm.cdhistor = 341  THEN
                                           3   /* Vida */
                                      ELSE
                                          11. /* Residencial */
        
                FIND crapseg WHERE crapseg.cdcooper = par_cdcooper
                               AND crapseg.nrdconta = craplcm.nrdconta
                               AND crapseg.tpseguro = aux_tpseguro
                               AND crapseg.nrctrseg = INT(craplcm.nrdocmto)
                           NO-LOCK NO-ERROR.
        
                IF   NOT AVAILABLE crapseg   THEN
                     NEXT.
        
                /* Se foi escolhido um PAC ... */
                IF par_cdagenci > 0   THEN
                   IF crapass.cdagenci <> par_cdagenci   THEN
                      NEXT.
        
                CREATE w-seguro.
                ASSIGN w-seguro.cdagenci = crapass.cdagenci
                       w-seguro.inpessoa = crapass.inpessoa
                       w-seguro.nrdconta = crapseg.nrdconta
                       w-seguro.vllanmto = craplcm.vllanmto
                       w-seguro.tpplaseg = crapseg.tpplaseg
                       w-seguro.tpseguro = crapseg.tpseguro
                       w-seguro.dtmvtolt = crapseg.dtmvtolt
                       w-seguro.dtcancel = crapseg.dtcancel.
        
            END. /* Fim do FOR EACH craplcm */
        END.
    END.

    RETURN "OK".                                                   
    
END PROCEDURE.
/*............................................................................*/


/******************************************************************************/
/**           Procedure para obter Informacao de Seguros Auto                **/
/**           Relacionados: CRPS524 e RELSEG                                 **/
/******************************************************************************/
PROCEDURE seguros-auto:

    DEF  INPUT PARAM par_cdcooper  AS   INTE                        NO-UNDO.
    DEF  INPUT PARAM par_tpseguro  AS   INTE                        NO-UNDO.
    DEF  INPUT PARAM par_cdsitseg  AS   INTE                        NO-UNDO.
    DEF  INPUT PARAM par_dataini   AS   DATE                        NO-UNDO.
    DEF  INPUT PARAM par_datafim   AS   DATE                        NO-UNDO.
    DEF  INPUT PARAM par_cdagenci  AS   INTE                        NO-UNDO.
    DEF  INPUT PARAM par_vlrapoli  AS   DECI                        NO-UNDO.
    DEF  INPUT PARAM par_vlrdecom1 AS   DECI                        NO-UNDO.
    DEF  INPUT PARAM par_vlrdeiof1 AS   DECI                        NO-UNDO.
    DEF  INPUT PARAM par_vlrdecom2 AS   DECI                        NO-UNDO.
    DEF  INPUT PARAM par_vlrdeiof2 AS   DECI                        NO-UNDO.
    DEF  INPUT PARAM par_vlrdecom3 AS   DECI                        NO-UNDO.
    DEF  INPUT PARAM par_vlrdeiof3 AS   DECI                        NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-info-seguros.

    DEFINE VARIABLE aux_tpseguro   AS   INTE                        NO-UNDO.
    DEF   VAR rel_vlreceit_aut     AS   DECI  FORMAT "z,zzz,zz9.99" NO-UNDO.
    DEF   VAR rel_vlreceit_vid     AS   DECI  FORMAT "z,zzz,zz9.99" NO-UNDO.
    DEF   VAR rel_vlreceit_res     AS   DECI  FORMAT "z,zzz,zz9.99" NO-UNDO.
    DEF   VAR tot_qtseguro_aut     AS   INTE                        NO-UNDO.
    DEF   VAR tot_vllanmto_aut     AS   DECI  FORMAT "z,zzz,zz9.99" NO-UNDO.
    DEF   VAR tot_vlreceit_aut     AS   DECI  FORMAT "z,zzz,zz9.99" NO-UNDO.
    DEF   VAR tot_vlrepass_aut     AS   DECI  FORMAT "z,zzz,zz9.99" NO-UNDO.
    DEF   VAR tot_qtseguro_res     AS   INTE                        NO-UNDO.
    DEF   VAR tot_vllanmto_res     AS   DECI  FORMAT "z,zzz,zz9.99" NO-UNDO.
    DEF   VAR tot_vlreceit_res     AS   DECI  FORMAT "z,zzz,zz9.99" NO-UNDO.
    DEF   VAR tot_vlrepass_res     AS   DECI  FORMAT "z,zzz,zz9.99" NO-UNDO.
    DEF   VAR tot_qtseguro_vid     AS   INTE                        NO-UNDO.
    DEF   VAR tot_vllanmto_vid     AS   DECI  FORMAT "z,zzz,zz9.99" NO-UNDO.
    DEF   VAR tot_vlreceit_vid     AS   DECI  FORMAT "z,zzz,zz9.99" NO-UNDO.
    DEF   VAR tot_vlrepass_vid     AS   DECI  FORMAT "z,zzz,zz9.99" NO-UNDO.
    DEF   VAR tot_qtdnovos     AS   INTE                            NO-UNDO.
    DEF   VAR tot_qtdcance     AS   INTE                            NO-UNDO.

    ASSIGN aux_cdcooper = par_cdcooper
           aux_dataini  = par_dataini
           aux_datafim  = par_datafim.

    EMPTY TEMP-TABLE tt-info-seguros.

    /* Seguros auto  */
    FOR EACH crapseg WHERE crapseg.cdcooper  = par_cdcooper
                       AND crapseg.tpseguro  = par_tpseguro
                       AND crapseg.cdsitseg <> par_cdsitseg
                       AND crapseg.dtmvtolt >= par_dataini
                       AND crapseg.dtmvtolt <= par_datafim  NO-LOCK,
       FIRST crapass WHERE crapass.cdcooper  = par_cdcooper
                       AND crapass.nrdconta  = crapseg.nrdconta NO-LOCK:

        IF   crapseg.lsctrant <> ""   THEN
             NEXT.
        
        /* Se foi selecionado um PAC especifico ... */
        IF par_cdagenci > 0   THEN
           IF par_cdagenci <> crapass.cdagenci   THEN
              NEXT.
                
        CREATE w-seguro.
        ASSIGN w-seguro.cdagenci = crapass.cdagenci
               w-seguro.inpessoa = crapass.inpessoa
               w-seguro.tpseguro = crapseg.tpseguro
               w-seguro.vllanmto = crapseg.vlpremio.
    END.
/*............................................................................*/
    /*  calculando valores seguros*/
    FOR EACH w-seguro NO-LOCK WHERE BREAK BY w-seguro.inpessoa
                                          BY w-seguro.tpseguro
                                          BY w-seguro.cdagenci:

        IF   w-seguro.tpseguro = 2   THEN              /****Seguro Auto ****/
             ASSIGN rel_vlreceit_aut = (w-seguro.vllanmto /
                                       ((par_vlrdeiof1 / 100) + 1)) - 
                                       par_vlrapoli
                    rel_vlreceit_aut = rel_vlreceit_aut * 
                                       (par_vlrdecom1 / 100) NO-ERROR.
        ELSE
        IF CAN-DO("1,11",STRING(w-seguro.tpseguro))  THEN /** Residencia **/
             ASSIGN rel_vlreceit_res = (w-seguro.vllanmto / ((par_vlrdeiof3 /
                                      100) + 1))
                    rel_vlreceit_res = rel_vlreceit_res * (par_vlrdecom3 /
                    100).
        ELSE
        IF   w-seguro.tpseguro = 3   THEN            /**** Seguro Vida ****/
             ASSIGN rel_vlreceit_vid = (w-seguro.vllanmto /
                                       ((par_vlrdeiof2 / 100) + 1))
                    rel_vlreceit_vid = rel_vlreceit_vid *
                                             (par_vlrdecom2 / 100).

        ASSIGN rel_vlreceit_aut = ROUND(rel_vlreceit_aut,2)
               rel_vlreceit_res = ROUND(rel_vlreceit_res,2)
               rel_vlreceit_vid = ROUND(rel_vlreceit_vid,2).

        IF w-seguro.tpseguro = 2   THEN              /****Seguro Auto ****/
            DO: 
                IF rel_vlreceit_aut < 0 OR TRUNCATE(w-seguro.vllanmto,0) <= 0
                OR w-seguro.vllanmto <= par_vlrapoli    THEN
                    ASSIGN rel_vlreceit_aut = 0.

                ASSIGN tot_qtseguro_aut = tot_qtseguro_aut + 1
                       tot_vllanmto_aut = tot_vllanmto_aut + w-seguro.vllanmto
                       tot_vlreceit_aut = tot_vlreceit_aut + rel_vlreceit_aut
                       tot_vlrepass_aut = tot_vlrepass_aut + 
                                     (w-seguro.vllanmto - rel_vlreceit_aut).
            END.
        ELSE
        IF   w-seguro.tpseguro = 3   THEN              /****Seguro Vida ****/
            DO: 
                ASSIGN tot_qtseguro_vid = tot_qtseguro_vid + 1
                       tot_vllanmto_vid = tot_vllanmto_vid + w-seguro.vllanmto
                       tot_vlreceit_vid = tot_vlreceit_vid + rel_vlreceit_vid
                       tot_vlrepass_vid = tot_vlrepass_vid + 
                                    (w-seguro.vllanmto - rel_vlreceit_vid).
            END.
        ELSE
        IF   CAN-DO("1,11",STRING(w-seguro.tpseguro))   THEN /** Residencia **/
            DO:
                ASSIGN tot_qtseguro_res = tot_qtseguro_res + 1
                       tot_vllanmto_res = tot_vllanmto_res + w-seguro.vllanmto
                       tot_vlreceit_res = tot_vlreceit_res + rel_vlreceit_res
                       tot_vlrepass_res = tot_vlrepass_res + 
                                      (w-seguro.vllanmto - rel_vlreceit_res).
            END.

/*............................................................................*/
        IF   LAST-OF(w-seguro.cdagenci)   THEN
             DO:
                 /* Contabiliza seguros novos e cancelados */
                 FIND FIRST tt-info-seguros EXCLUSIVE-LOCK 
                      WHERE tt-info-seguros.tpseguro = w-seguro.tpseguro
                        AND tt-info-seguros.inpessoa = w-seguro.inpessoa
                        AND tt-info-seguros.cdagenci = w-seguro.cdagenci
                   NO-ERROR .
                 IF  NOT AVAILABLE tt-info-seguros THEN
                     DO:
                         CREATE tt-info-seguros.
                         ASSIGN tt-info-seguros.tpseguro = w-seguro.tpseguro
                                tt-info-seguros.cdagenci = w-seguro.cdagenci
                                tt-info-seguros.inpessoa = w-seguro.inpessoa
                                tt-info-seguros.dtrefere = par_datafim.
                     END.
                 ASSIGN tt-info-seguros.qtsegaut = tt-info-seguros.qtsegaut +
                                                   tot_qtseguro_aut
                        tt-info-seguros.vlsegaut = tt-info-seguros.vlsegaut +
                                                   tot_vllanmto_aut
                        tt-info-seguros.vlrecaut = tt-info-seguros.vlrecaut +
                                                   tot_vlreceit_aut
                        tt-info-seguros.vlrepaut = tt-info-seguros.vlrepaut +
                                                   tot_vlrepass_aut
                        tt-info-seguros.qtsegvid = tt-info-seguros.qtsegvid +
                                                   tot_qtseguro_vid
                        tt-info-seguros.vlsegvid = tt-info-seguros.vlsegvid +
                                                   tot_vllanmto_vid
                        tt-info-seguros.vlrecvid = tt-info-seguros.vlrecvid +
                                                   tot_vlreceit_vid
                        tt-info-seguros.vlrepvid = tt-info-seguros.vlrepvid +
                                                   tot_vlrepass_vid
                        tt-info-seguros.qtsegres = tt-info-seguros.qtsegres +
                                                   tot_qtseguro_res
                        tt-info-seguros.vlsegres = tt-info-seguros.vlsegres +
                                                   tot_vllanmto_res
                        tt-info-seguros.vlrecres = tt-info-seguros.vlrecres +
                                                   tot_vlreceit_res
                        tt-info-seguros.vlrepres = tt-info-seguros.vlrepres +
                                                   tot_vlrepass_res.
                 IF w-seguro.tpseguro = 3 THEN        /****Seguro Vida ****/
                     DO: 
                         RUN proc_contabiliza (INPUT 3,
                                               OUTPUT tot_qtdnovos,
                                               OUTPUT tot_qtdcance). 
                         tt-info-seguros.qtincvid = tt-info-seguros.qtincvid +
                                                    tot_qtdnovos.
                         tt-info-seguros.qtexcvid = tt-info-seguros.qtexcvid +
                                                    tot_qtdcance.
                     END.
                 ELSE
                 IF CAN-DO("1,11",STRING(w-seguro.tpseguro)) THEN  
                     DO: 
                         RUN proc_contabiliza (INPUT 11,
                                               OUTPUT tot_qtdnovos,
                                               OUTPUT tot_qtdcance). 
                         tt-info-seguros.qtincres = tt-info-seguros.qtincres +
                                                    tot_qtdnovos.
                         tt-info-seguros.qtexcres = tt-info-seguros.qtexcres +
                                                    tot_qtdcance.
                     END.

                 ASSIGN tot_qtseguro_aut = 0
                        tot_vllanmto_aut = 0
                        tot_vlreceit_aut = 0
                        tot_vlrepass_aut = 0
                        tot_qtseguro_res = 0
                        tot_vllanmto_res = 0
                        tot_vlreceit_res = 0
                        tot_vlrepass_res = 0
                        tot_qtseguro_vid = 0
                        tot_vllanmto_vid = 0
                        tot_vlreceit_vid = 0
                        tot_vlrepass_vid = 0
                        tot_qtdnovos     = 0
                        tot_qtdcance     = 0.
        END.  /* Fim IF LAST-OF(w-seguro.cdagenci)  */

    END.
/*............................................................................*/
    RETURN "OK".                                                   
    
END PROCEDURE.
/*............................................................................*/



/******************************************************************************/
/**           Procedure para obter Informacao de Seguros Auto                **/
/**           Relacionados: CRPS524 e RELSEG                                 **/
/******************************************************************************/
PROCEDURE busca_dados_seg:      /* 1 - AUTO, 2 - VIDA, 3 - RESIDENCIAL */

    DEF INPUT PARAM par_cdcooper AS INTE                NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                NO-UNDO.
    
    DEF OUTPUT PARAM ret_vlrdecom1 AS DECI              NO-UNDO.
    DEF OUTPUT PARAM ret_vlrdecom2 AS DECI              NO-UNDO.
    DEF OUTPUT PARAM ret_vlrdecom3 AS DECI              NO-UNDO.
    DEF OUTPUT PARAM ret_vlrdeiof1 AS DECI              NO-UNDO.
    DEF OUTPUT PARAM ret_vlrdeiof2 AS DECI              NO-UNDO.
    DEF OUTPUT PARAM ret_vlrdeiof3 AS DECI              NO-UNDO.
    DEF OUTPUT PARAM ret_recid1    AS ROWID             NO-UNDO.
    DEF OUTPUT PARAM ret_recid2    AS ROWID             NO-UNDO.
    DEF OUTPUT PARAM ret_recid3    AS ROWID             NO-UNDO.
    DEF OUTPUT PARAM ret_vlrapoli  AS DECI              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE        NO-UNDO.
    DEF VAR aux_cdcritic AS INTE        NO-UNDO.
    DEF VAR aux_dscritic AS CHAR        NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    ASSIGN aux_contador = 0
           aux_cdcritic = 0
           aux_dscritic = "".

    DO aux_contador = 1 TO 3:
    
       FIND craptab WHERE craptab.cdcooper = par_cdcooper
                      AND craptab.nmsistem = "CRED"
                      AND craptab.tptabela = "GENERI"
                      AND craptab.cdempres = 00
                      AND craptab.cdacesso = "TAXASEGURO"
                      AND craptab.tpregist = aux_contador
              NO-LOCK NO-ERROR.
       
       IF NOT AVAILABLE craptab   THEN
          DO:
             ASSIGN aux_cdcritic = 55.
             LEAVE.
          END.

       IF aux_contador = 1 THEN
          ASSIGN ret_vlrdeiof1 = DEC(SUBSTR(craptab.dstextab,1,5))
                 ret_vlrdecom1 = DEC(SUBSTR(craptab.dstextab,6,5))
                 ret_recid1    = ROWID (craptab).

       ELSE
           IF aux_contador = 2 THEN
              ASSIGN ret_vlrdeiof2 = DEC(SUBSTR(craptab.dstextab,1,5))
                     ret_vlrdecom2 = DEC(SUBSTR(craptab.dstextab,6,5))
                     ret_recid2    = ROWID (craptab).

       ELSE
           IF aux_contador = 3 THEN
              ASSIGN ret_vlrdeiof3 = DEC(SUBSTR(craptab.dstextab,1,5))
                     ret_vlrdecom3 = DEC(SUBSTR(craptab.dstextab,6,5))
                     ret_recid3    = ROWID (craptab).

       
       IF craptab.tpregist = 1 THEN
          ret_vlrapoli = DEC(SUBSTR(craptab.dstextab,11,6)).
       
     
       
    END.

    IF aux_cdcritic <> 0 AND 
       aux_dscritic <> "" THEN
       DO:
          RUN gera_erro(INPUT par_cdcooper,
                        INPUT par_cdagenci,
                        INPUT par_nrdcaixa,
                        INPUT 1,            /** Sequencia **/
                        INPUT aux_cdcritic,
                        INPUT-OUTPUT aux_dscritic ).

          RETURN "NOK".

       END.

    RETURN "OK".

END PROCEDURE.  /* Fim da procedure proc_traz_dados */


/******************************************************************************/
/**           Procedure relacionada a Seguros [exclusiva]                    **/
/******************************************************************************/
PROCEDURE proc_contabiliza:
    DEF INPUT  PARAM par_tpseguro AS INTEGER                  NO-UNDO.
    DEF OUTPUT PARAM ret_qtdnovos AS INTEGER                  NO-UNDO.
    DEF OUTPUT PARAM ret_qtdcance AS INTEGER                  NO-UNDO.
    
    /* Quantidade de seguros novos do pac por tipo de seguro .. */
    FOR EACH crapseg WHERE crapseg.cdcooper  = aux_cdcooper      AND
                           crapseg.tpseguro  = par_tpseguro      AND
                           crapseg.dtmvtolt >= aux_dataini       AND
                           crapseg.dtmvtolt <= aux_datafim       NO-LOCK,
        
        FIRST crapass WHERE crapass.cdcooper = aux_cdcooper      AND
                            crapass.nrdconta = crapseg.nrdconta  AND 
                            crapass.cdagenci = w-seguro.cdagenci AND 
                            crapass.inpessoa = w-seguro.inpessoa NO-LOCK:
                           
        ASSIGN ret_qtdnovos = ret_qtdnovos + 1.
                           
    END.
    /* Quantidade de seguros cancelados do pac por tipo de seguro */

    FOR EACH crapseg WHERE crapseg.cdcooper  = aux_cdcooper      AND
                           crapseg.tpseguro  = par_tpseguro      AND
                           crapseg.dtcancel >= aux_dataini       AND
                           crapseg.dtcancel <= aux_datafim       NO-LOCK,
                           
        FIRST crapass WHERE crapass.cdcooper = aux_cdcooper      AND
                            crapass.nrdconta = crapseg.nrdconta  AND 
                            crapass.cdagenci = w-seguro.cdagenci AND 
                            crapass.inpessoa = w-seguro.inpessoa NO-LOCK:
        
        ASSIGN ret_qtdcance = ret_qtdcance + 1.

    END.

END PROCEDURE.

/*****************************************************************************/
/** Procedure que realiza a consulta da tela RELSEG Opcao "A"               **/
/*****************************************************************************/

PROCEDURE proc_traz_dados_exclusivos: /* 1 - AUTO, 2 - VIDA, 3 - RESIDENCIAL */

    DEF INPUT PARAM par_cdcooper AS INTE              NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE              NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE              NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR              NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR              NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE              NO-UNDO.

    DEF OUTPUT PARAM ret_vlrdecom1 AS DECI            NO-UNDO.
    DEF OUTPUT PARAM ret_vlrdecom2 AS DECI            NO-UNDO.
    DEF OUTPUT PARAM ret_vlrdecom3 AS DECI            NO-UNDO.

    DEF OUTPUT PARAM ret_vlrdeiof1 AS DECI            NO-UNDO.
    DEF OUTPUT PARAM ret_vlrdeiof2 AS DECI            NO-UNDO.
    DEF OUTPUT PARAM ret_vlrdeiof3 AS DECI            NO-UNDO.

    DEF OUTPUT PARAM ret_recid1    AS ROWID           NO-UNDO.
    DEF OUTPUT PARAM ret_recid2    AS ROWID           NO-UNDO.
    DEF OUTPUT PARAM ret_recid3    AS ROWID           NO-UNDO.
    DEF OUTPUT PARAM ret_vlrapoli  AS DECI            NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE            NO-UNDO.
    DEF VAR aux_cdcritic AS INTE            NO-UNDO.
    DEF VAR aux_dscritic AS CHAR            NO-UNDO.

    ASSIGN aux_contador = 0
           aux_cdcritic = 0
           aux_dscritic = "".
     
    DO aux_contador = 1 TO 3:
         
       FIND craptab WHERE craptab.cdcooper = par_cdcooper   AND
                          craptab.nmsistem = "CRED"         AND
                          craptab.tptabela = "GENERI"       AND
                          craptab.cdempres = 00             AND
                          craptab.cdacesso = "TAXASEGURO"   AND
                          craptab.tpregist = aux_contador   
                          EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

       IF   NOT AVAILABLE craptab   THEN
            DO:
                IF  LOCKED(craptab)   THEN
                    DO:
                        RUN sistema/generico/procedures/b1wgen9999.p
                        PERSISTENT SET h-b1wgen9999.
                        
                        RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                        					 INPUT "banco",
                        					 INPUT "craptab",
                        					 OUTPUT par_loginusr,
                        					 OUTPUT par_nmusuari,
                        					 OUTPUT par_dsdevice,
                        					 OUTPUT par_dtconnec,
                        					 OUTPUT par_numipusr).
                        
                        DELETE PROCEDURE h-b1wgen9999.
                        
                        ASSIGN aux_dadosusr = 
                        "077 - Tabela sendo alterada p/ outro terminal.".
                        
                        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            aux_dscritic = aux_dadosusr.
                            RUN gera_erro ( INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT 1,            /** Sequencia **/
                                            INPUT aux_cdcritic,
                                            INPUT-OUTPUT aux_dscritic).
                            LEAVE.
                        END.

                        ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                        			  " - " + par_nmusuari + ".".
                        
                        aux_dscritic = "".

                        DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                            aux_dscritic = aux_dadosusr.
                            RUN gera_erro ( INPUT par_cdcooper,
                                            INPUT par_cdagenci,
                                            INPUT par_nrdcaixa,
                                            INPUT 1,            /** Sequencia **/
                                            INPUT aux_cdcritic,
                                            INPUT-OUTPUT aux_dscritic).
                            LEAVE.
                        END.
                        aux_dscritic = "". 
                        NEXT.
                    END.
                ELSE
                    DO:
                        aux_cdcritic = 55. /* Nao Cadastrada */
                        LEAVE.
                    END.

            END.  /* Salva RECID pra futuramente gravar novos dados... */


       IF aux_contador = 1 THEN
          ASSIGN ret_vlrdeiof1 = DEC(SUBSTR(craptab.dstextab,1,5))
                 ret_vlrdecom1 = DEC(SUBSTR(craptab.dstextab,6,5))
                 ret_vlrapoli  = DEC(SUBSTR(craptab.dstextab,11,6))
                 ret_recid1    = ROWID (craptab).

       ELSE
          IF aux_contador = 2 THEN
             ASSIGN ret_vlrdeiof2 = DEC(SUBSTR(craptab.dstextab,1,5))
                    ret_vlrdecom2 = DEC(SUBSTR(craptab.dstextab,6,5))
                    ret_recid2    = ROWID (craptab).

       ELSE
          IF aux_contador = 3 THEN
             ASSIGN ret_vlrdeiof3 = DEC(SUBSTR(craptab.dstextab,1,5))
                    ret_vlrdecom3 = DEC(SUBSTR(craptab.dstextab,6,5))
                    ret_recid3    = ROWID (craptab).
                 

    END. /* Fim da leitura das craptab */

    IF aux_cdcritic <> 0 AND 
       aux_dscritic <> "" THEN
       DO:
          RUN gera_erro ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic ).

          RETURN "NOK".

       END.

    RETURN "OK".

END PROCEDURE. /* Fim da procedure proc_tras_dados_exclusivos */


/*****************************************************************************/
/** Procedure que realiza a gravação da tela RELSEG Opcao "A"               **/
/*****************************************************************************/

PROCEDURE proc_grava_dados: /* 1 - AUTO, 2 - VIDA, 3 - RESIDENCIAL */

    DEF INPUT PARAM par_cdcooper AS INTE              NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE              NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE              NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR              NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR              NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE              NO-UNDO.

    DEF INPUT PARAM par_vlrdecom1 AS DECI             NO-UNDO.
    DEF INPUT PARAM par_vlrdecom2 AS DECI             NO-UNDO.
    DEF INPUT PARAM par_vlrdecom3 AS DECI             NO-UNDO.
    
    DEF INPUT PARAM par_vlrdeiof1 AS DECI             NO-UNDO.
    DEF INPUT PARAM par_vlrdeiof2 AS DECI             NO-UNDO.
    DEF INPUT PARAM par_vlrdeiof3 AS DECI             NO-UNDO.

    DEF INPUT PARAM par_recid1    AS ROWID            NO-UNDO.
    DEF INPUT PARAM par_recid2    AS ROWID            NO-UNDO.
    DEF INPUT PARAM par_recid3    AS ROWID            NO-UNDO.
    
    DEF INPUT PARAM par_vlrapoli AS DECI              NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_contador AS INTE            NO-UNDO.
    DEF VAR aux_cdcritic AS INTE            NO-UNDO.
    DEF VAR aux_dscritic AS CHAR            NO-UNDO.

    ASSIGN aux_contador = 0 
           aux_cdcritic = 0
           aux_dscritic = "".


    DO WHILE TRUE TRANSACTION ON ERROR UNDO, LEAVE 
                              ON ENDKEY UNDO, LEAVE:

       DO aux_contador = 1 TO 10:
                                          /* Seguro Auto */
          FIND craptab WHERE ROWID(craptab) = par_recid1
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                             
          IF  NOT AVAILABLE craptab THEN
              IF LOCKED(craptab)   THEN
                 DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                    
                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                    					 INPUT "banco",
                    					 INPUT "craptab",
                    					 OUTPUT par_loginusr,
                    					 OUTPUT par_nmusuari,
                    					 OUTPUT par_dsdevice,
                    					 OUTPUT par_dtconnec,
                    					 OUTPUT par_numipusr).
                    
                    DELETE PROCEDURE h-b1wgen9999.
                    
                    ASSIGN aux_dadosusr = 
                    "077 - Tabela sendo alterada p/ outro terminal.".
                    
                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        aux_dscritic = aux_dadosusr.
                        RUN gera_erro ( INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1,            /** Sequencia **/
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).
                        LEAVE.
                    END.
                    
                    ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                    			  " - " + par_nmusuari + ".".
                    
                    aux_dscritic = "".

                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        aux_dscritic = aux_dadosusr.
                        RUN gera_erro ( INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1,            /** Sequencia **/
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).
                        LEAVE.
                    END.
                    aux_dscritic = "".
                    NEXT.
                 END.
              ELSE
                 DO:
                   ASSIGN aux_cdcritic = 55. /* Nao Cadastrada */
                   LEAVE.
                 END.

          LEAVE.       

       END. /* Fim do DO ... TO */ 

       IF aux_cdcritic > 0 THEN
          UNDO, LEAVE.
                   
       ASSIGN craptab.dstextab = STRING(par_vlrdeiof1,"99.99") + 
                                 STRING(par_vlrdecom1,"99.99")
              craptab.dstextab = craptab.dstextab + 
                                 STRING(par_vlrapoli,"999.99").


       DO aux_contador = 1 TO 10:
                                            /* Seguro Vida */
          FIND craptab WHERE ROWID(craptab) = par_recid2
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                             
          IF  NOT AVAILABLE craptab THEN
              IF LOCKED(craptab)   THEN
                 DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                    
                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                    					 INPUT "banco",
                    					 INPUT "craptab",
                    					 OUTPUT par_loginusr,
                    					 OUTPUT par_nmusuari,
                    					 OUTPUT par_dsdevice,
                    					 OUTPUT par_dtconnec,
                    					 OUTPUT par_numipusr).
                    
                    DELETE PROCEDURE h-b1wgen9999.
                    
                    ASSIGN aux_dadosusr = 
                    "077 - Tabela sendo alterada p/ outro terminal.".
                    
                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        aux_dscritic = aux_dadosusr.
                        RUN gera_erro ( INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1,            /** Sequencia **/
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).
                        LEAVE.
                    END.
                    
                    ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                    			  " - " + par_nmusuari + ".".
                    
                    aux_dscritic = "".
                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        aux_dscritic = aux_dadosusr.
                        RUN gera_erro ( INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1,            /** Sequencia **/
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).
                        LEAVE.
                    END.
                    aux_dscritic = "". 
                    NEXT.
                 END.
              ELSE
                 DO:
                   ASSIGN aux_cdcritic = 55. /* Nao Cadastrada */
                   LEAVE.
                 END.

          LEAVE.       

       END. /* Fim do DO ... TO */ 

       IF aux_cdcritic > 0 THEN
          UNDO, LEAVE.
                   
       ASSIGN craptab.dstextab = STRING(par_vlrdeiof2,"99.99") + 
                                 STRING(par_vlrdecom2,"99.99").


       DO aux_contador = 1 TO 10:
                                      /* Seguro Residencial */
          FIND craptab WHERE ROWID(craptab) = par_recid3
                             EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
                             
          IF  NOT AVAILABLE craptab THEN
              IF LOCKED(craptab)   THEN
                 DO:
                    RUN sistema/generico/procedures/b1wgen9999.p
                    PERSISTENT SET h-b1wgen9999.
                    
                    RUN acha-lock IN h-b1wgen9999 (INPUT RECID(craptab),
                    					 INPUT "banco",
                    					 INPUT "craptab",
                    					 OUTPUT par_loginusr,
                    					 OUTPUT par_nmusuari,
                    					 OUTPUT par_dsdevice,
                    					 OUTPUT par_dtconnec,
                    					 OUTPUT par_numipusr).
                    
                    DELETE PROCEDURE h-b1wgen9999.
                    
                    ASSIGN aux_dadosusr = 
                    "077 - Tabela sendo alterada p/ outro terminal.".
                    
                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        aux_dscritic = aux_dadosusr.
                        RUN gera_erro ( INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1,            /** Sequencia **/
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).
                        LEAVE.
                    END.
                    
                    ASSIGN aux_dadosusr = "Operador: " + par_loginusr +
                    			  " - " + par_nmusuari + ".".
                    
                    aux_dscritic = "".
                    DO  WHILE TRUE ON ENDKEY UNDO, LEAVE:
                        aux_dscritic = aux_dadosusr.
                        RUN gera_erro ( INPUT par_cdcooper,
                                        INPUT par_cdagenci,
                                        INPUT par_nrdcaixa,
                                        INPUT 1,            /** Sequencia **/
                                        INPUT aux_cdcritic,
                                        INPUT-OUTPUT aux_dscritic).
                        LEAVE.
                    END.
                    aux_dscritic = "".
                    NEXT.
                 END.
              ELSE
                 DO:
                   ASSIGN aux_cdcritic = 55. /* Nao Cadastrada */
                   LEAVE.
                 END.

          LEAVE.       

       END. /* Fim do DO ... TO */ 

       IF aux_cdcritic > 0 THEN
          UNDO, LEAVE.
                   
       ASSIGN craptab.dstextab = STRING(par_vlrdeiof3,"99.99") + 
                                 STRING(par_vlrdecom3,"99.99").

       LEAVE.       

     END. /** Fim do DO TRANSACTION **/

     IF aux_cdcritic <> 0 AND 
        aux_dscritic <> "" THEN
        DO:
          RUN gera_erro ( INPUT par_cdcooper,
                          INPUT par_cdagenci,
                          INPUT par_nrdcaixa,
                          INPUT 1,            /** Sequencia **/
                          INPUT aux_cdcritic,
                          INPUT-OUTPUT aux_dscritic ).
          RETURN "NOK".
        END.

     RETURN "OK".

END PROCEDURE. /* Fim da procedure proc_grava_dados */


/******************************************************************************/
/**   Procedures que geram relatório para tela RELSEG opcao R                **/
/******************************************************************************/

PROCEDURE inicia-relatorio:

    DEF INPUT PARAM par_cdcooper AS INTE              NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE              NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE              NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR              NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR              NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE              NO-UNDO.

    DEF INPUT PARAM par_tprelato AS INTE              NO-UNDO.
    DEF INPUT PARAM par_telcdage AS INTE              NO-UNDO.
    DEF INPUT PARAM par_dtiniper AS DATE              NO-UNDO.
    DEF INPUT PARAM par_dtfimper AS DATE              NO-UNDO.
    DEF INPUT PARAM par_inexprel AS INTE              NO-UNDO.
                     
    DEF OUTPUT PARAM par_nmdcampo AS CHAR             NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR             NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqimp AS CHAR             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_vlrdecom1 AS DECI       NO-UNDO.
    DEF VAR aux_vlrdecom2 AS DECI       NO-UNDO.
    DEF VAR aux_vlrdecom3 AS DECI       NO-UNDO.
    DEF VAR aux_vlrdeiof1 AS DECI       NO-UNDO.
    DEF VAR aux_vlrdeiof2 AS DECI       NO-UNDO.
    DEF VAR aux_vlrdeiof3 AS DECI       NO-UNDO.
    DEF VAR aux_recid1    AS ROWID      NO-UNDO.
    DEF VAR aux_recid2    AS ROWID      NO-UNDO.
    DEF VAR aux_recid3    AS ROWID      NO-UNDO.
    DEF VAR aux_vlrapoli  AS DECI       NO-UNDO.
    DEF VAR aux_cdcritic  AS INTE       NO-UNDO.
    DEF VAR aux_dscritic  AS CHAR       NO-UNDO.
    DEF VAR aux_flgtrans  AS LOG        NO-UNDO.

    ASSIGN aux_vlrdecom1 = 0
           aux_vlrdecom2 = 0
           aux_vlrdecom3 = 0
           aux_vlrdeiof1 = 0
           aux_vlrdeiof2 = 0
           aux_vlrdeiof3 = 0
           aux_vlrapoli  = 0
           aux_cdcritic  = 0
           aux_dscritic  = "".

    EMPTY TEMP-TABLE tt-erro.

    INI_RELATORIO:
    DO ON ERROR UNDO, LEAVE :

       IF MONTH(par_dtiniper) <> MONTH(par_dtfimper)   OR
          YEAR (par_dtiniper) <> YEAR (par_dtfimper)   OR
          par_dtiniper > par_dtfimper THEN
          DO:
              ASSIGN aux_dscritic = "O periodo deve estar no mesmo mes e ano."
                     par_nmdcampo = "dtiniper".

              LEAVE INI_RELATORIO.
  
          END.
       
       RUN busca_dados_seg (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_nmdatela,
                            INPUT par_idorigem,
                            INPUT par_dtmvtolt,
                            OUTPUT aux_vlrdecom1,
                            OUTPUT aux_vlrdecom2,
                            OUTPUT aux_vlrdecom3,
                            OUTPUT aux_vlrdeiof1,
                            OUTPUT aux_vlrdeiof2,
                            OUTPUT aux_vlrdeiof3,
                            OUTPUT aux_recid1,
                            OUTPUT aux_recid2,
                            OUTPUT aux_recid3,
                            OUTPUT aux_vlrapoli,
                            OUTPUT TABLE tt-erro).
       
       IF RETURN-VALUE <> "OK" THEN
          LEAVE INI_RELATORIO.
       
       RUN gera-relatorio (INPUT par_cdcooper,
                           INPUT par_cdagenci,
                           INPUT par_nrdcaixa,
                           INPUT par_cdoperad,
                           INPUT par_nmdatela,
                           INPUT par_idorigem,
                           INPUT par_dtmvtolt,
                           INPUT par_telcdage,
                           INPUT par_dtiniper,
                           INPUT par_dtfimper,
                           INPUT aux_vlrdeiof1, 
                           INPUT aux_vlrdeiof2,
                           INPUT aux_vlrdeiof3,
                           INPUT par_tprelato,
                           INPUT aux_vlrapoli,
                           INPUT aux_vlrdecom1,
                           INPUT aux_vlrdecom2,
                           INPUT aux_vlrdecom3,
                           INPUT par_inexprel,
                           OUTPUT aux_nmarqimp,
                           OUTPUT aux_nmarqpdf,
                           OUTPUT TABLE tt-erro).
       
       IF RETURN-VALUE <> "OK" THEN
          LEAVE INI_RELATORIO.

       ASSIGN aux_flgtrans = TRUE.

    END. /* fim do DO ON ERROR */

    IF aux_flgtrans = FALSE  THEN
       DO:
          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             RUN gera_erro ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,            /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic ).

          RETURN "NOK".

       END.

    RETURN "OK".
    
END PROCEDURE.


PROCEDURE gera-relatorio:
    
    DEF INPUT PARAM par_cdcooper AS INTE              NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE              NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE              NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR              NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR              NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE              NO-UNDO.

    DEF INPUT PARAM par_telcdage  AS INTE             NO-UNDO.
    DEF INPUT PARAM par_dtiniper  AS DATE             NO-UNDO.
    DEF INPUT PARAM par_dtfimper  AS DATE             NO-UNDO.
    DEF INPUT PARAM par_vlrdeiof1 AS DECI             NO-UNDO.
    DEF INPUT PARAM par_vlrdeiof2 AS DECI             NO-UNDO.
    DEF INPUT PARAM par_vlrdeiof3 AS DECI             NO-UNDO.
    DEF INPUT PARAM par_tprelato  AS INTE             NO-UNDO.
    DEF INPUT PARAM par_vlrapoli  AS DECI             NO-UNDO.
    DEF INPUT PARAM par_vlrdecom1 AS DECI             NO-UNDO.
    DEF INPUT PARAM par_vlrdecom2 AS DECI             NO-UNDO.
    DEF INPUT PARAM par_vlrdecom3 AS DECI             NO-UNDO.
    DEF INPUT PARAM par_inexprel  AS INTE             NO-UNDO.

    DEF OUTPUT PARAM aux_nmarqimp AS CHAR             NO-UNDO.
    DEF OUTPUT PARAM aux_nmarqpdf AS CHAR             NO-UNDO.
    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR aux_listahis AS CHAR            NO-UNDO.
    DEF VAR aux_nmarqtxt AS CHAR            NO-UNDO.
    DEF VAR aux_cdrelato AS INTE            NO-UNDO.
    DEF VAR aux_cdcritic AS INTE            NO-UNDO.
    DEF VAR aux_dscritic AS CHAR            NO-UNDO.
    DEF VAR aux_flgtrans AS LOG             NO-UNDO.
   
    /***Cabecalho****/
    DEF VAR rel_nmrescop AS CHAR                           NO-UNDO.
    DEF VAR rel_nmresemp AS CHAR  FORMAT "x(15)"           NO-UNDO.
    DEF VAR rel_nmrelato AS CHAR  FORMAT "x(40)"           NO-UNDO.
    DEF VAR rel_nrmodulo AS INTE  FORMAT     "9"           NO-UNDO.
    DEF VAR rel_nmempres AS CHAR  FORMAT "x(15)"           NO-UNDO.
    DEF VAR rel_nmdestin AS CHAR                           NO-UNDO.
    DEF VAR rel_nmmodulo AS CHAR  FORMAT "x(15)" EXTENT 5  
                                  INIT ["","","","",""]    NO-UNDO.
    
    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".
    
    FIM_RELATORIO:
    DO ON ERROR UNDO, LEAVE :

        /* Seguro AUTO nao vai por lancamento e sim por valor total do seguro */
        FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper 
                                 NO-LOCK  NO-ERROR.
       
        IF  NOT AVAILABLE crapcop  THEN
            DO: 
               ASSIGN aux_cdcritic = 651
                      aux_dscritic = "".
       
               LEAVE FIM_RELATORIO.
            END.
       
        ASSIGN aux_nmarqimp = "/usr/coop/" + crapcop.dsdircop + "/".
       
        CASE par_tprelato:
             
             WHEN   1   THEN   ASSIGN aux_nmarqimp = aux_nmarqimp + "rl/crrl507"
                                      aux_cdrelato = 507.
                       
             WHEN   2   THEN   ASSIGN aux_nmarqimp = aux_nmarqimp + "rl/crrl505"
                                      aux_listahis = "341"
                                      aux_cdrelato = 505.
       
             WHEN   3   THEN   ASSIGN aux_nmarqimp = aux_nmarqimp + "rl/crrl506"
                                      aux_listahis = "175,460,511"
                                      aux_cdrelato = 506.
                                      
             WHEN   4   THEN   ASSIGN aux_nmarqimp = aux_nmarqimp + "rl/crrl508"
                                      aux_listahis = "341,175,460,511"
                                      aux_cdrelato = 508.
       
             WHEN   5   THEN   ASSIGN aux_nmarqimp = aux_nmarqimp + 
                                      "rl/motivos_cancelamento".
       
        END CASE.
               
        IF par_tprelato <> 5 THEN
           DO:
               ASSIGN aux_nmarqimp = aux_nmarqimp + STRING(TIME)  + ".ex".
        
               OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 84.
        
               { sistema/generico/includes/b1cabrel132.i "11" aux_cdrelato}
        
               VIEW STREAM str_1 FRAME f_cabrel132_1.
       
           END.
        ELSE     
           DO:   
              ASSIGN aux_nmarqimp = aux_nmarqimp + STRING(TIME)  + ".ex".

              OUTPUT STREAM str_1 TO VALUE (aux_nmarqimp) PAGED PAGE-SIZE 72.
                   
           END.      

       /* Somente tipo de relatorio que contenha historicos */
       IF  CAN-DO("2,3,4",STRING(par_tprelato)) THEN
           DO:
               EMPTY TEMP-TABLE w_histor.

               /* Gravar historicos em uma temp-table, para utilizar na 
                  procedure seguros-resid-vida, e melhorar a performace */
               IF  par_tprelato = 2 THEN
                   DO:
                      FIND FIRST w_histor WHERE 
                                 w_histor.cdcooper = par_cdcooper AND
                                 w_histor.cdhistor = 341
                                 NO-LOCK NO-ERROR.

                      IF  NOT AVAIL w_histor THEN
                          DO:
                              CREATE w_histor.
                              ASSIGN w_histor.cdcooper = par_cdcooper
                                     w_histor.cdhistor = 341.
                          END.
                   END.
               ELSE
                   IF  par_tprelato = 3 THEN
                       DO:
                          FIND FIRST w_histor WHERE 
                                     w_histor.cdcooper = par_cdcooper AND
                                     w_histor.cdhistor = 175
                                     NO-LOCK NO-ERROR.
    
                          IF  NOT AVAIL w_histor THEN
                              DO:
                                  CREATE w_histor.
                                  ASSIGN w_histor.cdcooper = par_cdcooper
                                         w_histor.cdhistor = 175.
                              END.

                          FIND FIRST w_histor WHERE 
                                     w_histor.cdcooper = par_cdcooper AND
                                     w_histor.cdhistor = 460
                                     NO-LOCK NO-ERROR.

                          IF  NOT AVAIL w_histor THEN
                              DO:
                                  CREATE w_histor.
                                  ASSIGN w_histor.cdcooper = par_cdcooper
                                         w_histor.cdhistor = 460.
                              END.
                          
                          FIND FIRST w_histor WHERE 
                                     w_histor.cdcooper = par_cdcooper AND
                                     w_histor.cdhistor = 511
                                     NO-LOCK NO-ERROR.

                          IF  NOT AVAIL w_histor THEN
                              DO:
                                  CREATE w_histor.
                                  ASSIGN w_histor.cdcooper = par_cdcooper
                                         w_histor.cdhistor = 511.
                              END.                          

                       END.
               ELSE
                   IF  par_tprelato = 4 THEN
                       DO:                            
                          FIND FIRST w_histor WHERE 
                                     w_histor.cdcooper = par_cdcooper AND
                                     w_histor.cdhistor = 175
                                     NO-LOCK NO-ERROR.
    
                          IF  NOT AVAIL w_histor THEN
                              DO:
                                  CREATE w_histor.
                                  ASSIGN w_histor.cdcooper = par_cdcooper
                                         w_histor.cdhistor = 175.
                              END.

                          FIND FIRST w_histor WHERE 
                                     w_histor.cdcooper = par_cdcooper AND
                                     w_histor.cdhistor = 460
                                     NO-LOCK NO-ERROR.

                          IF  NOT AVAIL w_histor THEN
                              DO:
                                  CREATE w_histor.
                                  ASSIGN w_histor.cdcooper = par_cdcooper
                                         w_histor.cdhistor = 460.
                              END.
                          
                          FIND FIRST w_histor WHERE 
                                     w_histor.cdcooper = par_cdcooper AND
                                     w_histor.cdhistor = 511
                                     NO-LOCK NO-ERROR.

                          IF  NOT AVAIL w_histor THEN
                              DO:
                                  CREATE w_histor.
                                  ASSIGN w_histor.cdcooper = par_cdcooper
                                         w_histor.cdhistor = 511.
                              END.

                          FIND FIRST w_histor WHERE 
                                     w_histor.cdcooper = par_cdcooper AND
                                     w_histor.cdhistor = 341
                                     NO-LOCK NO-ERROR.
    
                          IF  NOT AVAIL w_histor THEN
                              DO:
                                  CREATE w_histor.
                                  ASSIGN w_histor.cdcooper = par_cdcooper
                                         w_histor.cdhistor = 341.
                              END.

                       END.

               EMPTY TEMP-TABLE w-seguro.
                
               RUN seguros-resid-vida (INPUT par_cdcooper,
                                       INPUT par_dtiniper,
                                       INPUT par_dtfimper,
                                       INPUT par_telcdage,
                                       INPUT TABLE w_histor,
                                       OUTPUT TABLE w-seguro).
           END. 
	   
        CASE par_tprelato:
       
           WHEN 1 THEN   
              DO:
                 RUN proc_auto(INPUT par_cdcooper,           
                               INPUT par_cdagenci,           
                               INPUT par_nrdcaixa,       
                               INPUT par_cdoperad,          
                               INPUT par_nmdatela,          
                               INPUT par_idorigem,         
                               INPUT par_dtmvtolt,          
                               INPUT par_telcdage,
                               INPUT par_dtiniper,
                               INPUT par_dtfimper,
                               INPUT par_vlrdeiof1,
                               INPUT par_vlrapoli,
                               INPUT par_vlrdecom1,
                               INPUT TABLE w-seguro,
                               OUTPUT TABLE tt-erro).
       
                 IF RETURN-VALUE <> "OK" THEN
                    LEAVE FIM_RELATORIO.

              END.
               
       
           WHEN 2 THEN
              DO:   
                  RUN proc_vida (INPUT par_cdcooper,  
                                 INPUT par_cdagenci,
                                 INPUT par_nrdcaixa,  
                                 INPUT par_cdoperad,  
                                 INPUT par_nmdatela,  
                                 INPUT par_idorigem,  
                                 INPUT par_dtmvtolt,
                                 INPUT par_telcdage,  
                                 INPUT par_dtiniper,
                                 INPUT par_dtfimper,  
                                 INPUT par_vlrdeiof2,
                                 INPUT par_vlrapoli,  
                                 INPUT par_vlrdecom2, 
                                 INPUT TABLE w-seguro,   
                                 OUTPUT TABLE tt-erro).   
       
                  IF RETURN-VALUE <> "OK" THEN
                     LEAVE FIM_RELATORIO.
       
              END.
       
           WHEN 3 THEN
              DO:  
                 RUN proc_residencial(INPUT par_cdcooper,           
                                      INPUT par_cdagenci,           
                                      INPUT par_nrdcaixa,       
                                      INPUT par_cdoperad,          
                                      INPUT par_nmdatela,          
                                      INPUT par_idorigem,       
                                      INPUT par_dtmvtolt,          
                                      INPUT par_telcdage,
                                      INPUT par_dtiniper,
                                      INPUT par_dtfimper,
                                      INPUT par_vlrdeiof3,
                                      INPUT par_vlrapoli,
                                      INPUT par_vlrdecom3,
                                      INPUT TABLE w-seguro,
                                      OUTPUT TABLE tt-erro).
       
                 IF RETURN-VALUE <> "OK" THEN
                    LEAVE FIM_RELATORIO.

              END.
              
           WHEN 4 THEN
              DO: 
                 RUN proc_gerencial (INPUT par_cdcooper,           
                                     INPUT par_cdagenci,           
                                     INPUT par_nrdcaixa,
                                     INPUT par_cdoperad,          
                                     INPUT par_nmdatela,          
                                     INPUT par_idorigem,         
                                     INPUT par_dtmvtolt,          
                                     INPUT par_telcdage,
                                     INPUT par_dtiniper,
                                     INPUT par_dtfimper,
                                     INPUT par_vlrdeiof1,
                                     INPUT par_vlrdeiof2,
                                     INPUT par_vlrdeiof3,
                                     INPUT par_vlrapoli,
                                     INPUT par_vlrdecom1,
                                     INPUT par_vlrdecom2,
                                     INPUT par_vlrdecom3,
                                     INPUT TABLE w-seguro,
                                     OUTPUT TABLE tt-erro).
       
                 IF RETURN-VALUE <> "OK" THEN
                    LEAVE FIM_RELATORIO.
       
              END.
       
           WHEN 5 THEN
              DO: 
                 RUN proc_cancelamento (INPUT par_cdcooper,     
                                        INPUT par_cdagenci,      
                                        INPUT par_nrdcaixa,  
                                        INPUT par_cdoperad,     
                                        INPUT par_dtmvtolt,  
                                        INPUT par_idorigem,  
                                        INPUT par_nmdatela,
                                        INPUT par_telcdage,
                                        INPUT par_dtiniper,  
                                        INPUT par_dtfimper,  
                                        OUTPUT TABLE tt-erro).
       
                 IF RETURN-VALUE <> "OK" THEN
                    LEAVE FIM_RELATORIO.
       
              END.
       
        END CASE.
       
        OUTPUT STREAM str_1 CLOSE.
        
        IF par_idorigem = 5 THEN
           DO:
               IF par_inexprel = 2 THEN /* TXT */
                   DO:
                       FIND crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

                       ASSIGN aux_nmarqtxt = REPLACE(aux_nmarqimp,".ex",".txt")
                              aux_nmarqpdf = REPLACE(ENTRY(NUM-ENTRIES(aux_nmarqimp,"/"),aux_nmarqimp,"/"),".ex",".txt").

                       UNIX SILENT VALUE("ux2dos " + aux_nmarqimp + " >> " + aux_nmarqtxt + " 2>/dev/null").

                       /* Copiar para o servidor */
                       UNIX SILENT VALUE ('sudo /usr/bin/su - scpuser -c ' +
                                          '"scp ' + aux_nmarqtxt + ' scpuser@' + aux_srvintra +
                                          ':/var/www/ayllos/documentos/' + crapcop.dsdircop +
                                          '/temp/" 2>/dev/null').
                            
                       IF SEARCH(aux_nmarqimp) <> ? THEN
                          UNIX SILENT VALUE ("rm " + aux_nmarqimp + "* 2>/dev/null").

                       IF SEARCH(aux_nmarqtxt) <> ? THEN
                          UNIX SILENT VALUE ("rm " + aux_nmarqtxt + "* 2>/dev/null").
                   END.
               ELSE /* PDF */
                   DO:
                       RUN sistema/generico/procedures/b1wgen0024.p PERSISTENT 
                            SET h-b1wgen0024.
                        
                        RUN envia-arquivo-web 
                            IN h-b1wgen0024 (INPUT par_cdcooper,
                                             INPUT par_cdagenci,
                                             INPUT par_nrdcaixa,
                                             INPUT aux_nmarqimp,
                                             OUTPUT aux_nmarqpdf,
                                             OUTPUT TABLE tt-erro).
                        
                        IF  VALID-HANDLE(h-b1wgen0024) THEN
                            DELETE PROCEDURE h-b1wgen0024.
                        
                        IF RETURN-VALUE <> "OK" THEN
                           LEAVE FIM_RELATORIO.
                   END.
           END.

        ASSIGN aux_flgtrans = TRUE.


    END.   /*Fim do DO ON ERROR */
       
    IF aux_flgtrans = FALSE THEN
       DO:
          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             RUN gera_erro ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,            /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic ).

          RETURN "NOK".

       END.
       
    RETURN "OK".
    
END PROCEDURE. /* Fim gera-relatorio */


PROCEDURE proc_auto:

    DEF INPUT PARAM par_cdcooper  AS INTE             NO-UNDO.       
    DEF INPUT PARAM par_cdagenci  AS INTE             NO-UNDO.    
    DEF INPUT PARAM par_nrdcaixa  AS INTE             NO-UNDO.   
    DEF INPUT PARAM par_cdoperad  AS CHAR             NO-UNDO.    
    DEF INPUT PARAM par_nmdatela  AS CHAR             NO-UNDO.    
    DEF INPUT PARAM par_idorigem  AS INTE             NO-UNDO.  
    DEF INPUT PARAM par_dtmvtolt  AS DATE             NO-UNDO.  
                                                                 
    DEF INPUT PARAM par_telcdage  AS INTE             NO-UNDO.    
    DEF INPUT PARAM par_dtiniper  AS DATE             NO-UNDO.    
    DEF INPUT PARAM par_dtfimper  AS DATE             NO-UNDO.       
    DEF INPUT PARAM par_vlrdeiof1 AS DECI             NO-UNDO.       
    DEF INPUT PARAM par_vlrapoli  AS DECI             NO-UNDO.       
    DEF INPUT PARAM par_vlrdecom1 AS DECI             NO-UNDO.     
    DEF INPUT PARAM TABLE FOR w-seguro.                            
    
    DEF OUTPUT PARAM TABLE FOR tt-erro.
    
    
    DEF VAR rel_vlpremio        AS DECIMAL                          NO-UNDO.
    DEF VAR rel_dtcancel        AS DATE                             NO-UNDO.
    DEF VAR rel_dtsubsti        AS DATE                             NO-UNDO. 

    /* Variaveis para gerar o relatorio Receitas Seguros */
    DEF VAR rel_vlreceit AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    DEF VAR rel_vlrepass AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    
    DEF VAR pac_vllanmto AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    DEF VAR pac_vlreceit AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    DEF VAR pac_vlrepass AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    
    DEF VAR tot_qtseguro AS   INTE  FORMAT "   z,zzz,zz9"           NO-UNDO.
    DEF VAR tot_vllanmto AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    DEF VAR tot_vlreceit AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    DEF VAR tot_vlrepass AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.


    FORM w-seguro.nrdconta COLUMN-LABEL "C/C"                       AT 01 
         rel_vlpremio      COLUMN-LABEL "Valor do seguro"           AT 14
         rel_vlreceit      COLUMN-LABEL "Receita"                   AT 32
         rel_vlrepass      COLUMN-LABEL "Repasse Corretora"         AT 47
         w-seguro.dtmvtolt COLUMN-LABEL "Dt.Inclusao"               AT 67
         rel_dtcancel      COLUMN-LABEL "Imp.Cancelamento"          AT 81
         rel_dtsubsti      COLUMN-LABEL "Imp.Substituicao"          AT 100
         WITH WIDTH 132 DOWN FRAME f_auto.

    FORM SKIP(1)
         "TOTAL"       AT 09
         pac_vllanmto  AT 17
         pac_vlreceit  AT 32
         pac_vlrepass  AT 52
         WITH WIDTH 132 SIDE-LABELS NO-LABELS FRAME f_auto_total_pac.

    FORM SKIP(1)
         tot_qtseguro      LABEL "QUANTIDADE SEGURO AUTO "
         SKIP(1)
         tot_vllanmto      LABEL "TOTAL SEGURO           " 
         SKIP(1)
         tot_vlreceit      LABEL "TOTAL RECEITA          "
         SKIP(1)
         tot_vlrepass      LABEL "TOTAL REPASSE CORRETORA"
         SKIP(1)
         WITH SIDE-LABELS WIDTH 132 FRAME f_auto_total_coop.  

    FORM "SEGURO AUTO - De"
         par_dtiniper      FORMAT "99/99/9999"
         "a"
         par_dtfimper      FORMAT "99/99/9999"
         WITH NO-LABEL SIDE-LABELS WIDTH 132 FRAME f_periodo_auto.

    FORM "PA :"
  
        crapage.cdagenci
        " - "
     
        crapage.nmextage
        WITH WIDTH 132 NO-LABELS FRAME f_pac.
    
    FORM "Este relatorio e apenas para fins de acompanhamento."
         "Os valores e prazos expressos nele podem sofrer alteracoes. Em caso"
         "de divergencias esclarecer com a corretora."
         WITH WIDTH 132 FRAME f_aviso_auto.

    /**********
    - Valor receita eh igual ao ((SEGURO TOTAL - IOF%) - APOLICE) * (COMISSAO%)
    - Valor repasse eh igual ao SEGURO TOTAL - RECEITA  
    *********/

    DISPLAY STREAM str_1 par_dtiniper
                         par_dtfimper WITH FRAME f_periodo_auto.

    FOR EACH crapseg WHERE crapseg.cdcooper  = par_cdcooper       AND
                           crapseg.tpseguro  = 2                  AND
                           crapseg.cdsitseg  <> 4                 AND
                           crapseg.dtmvtolt >= par_dtiniper       AND
                           crapseg.dtmvtolt <= par_dtfimper       NO-LOCK,
                           
        FIRST crapass WHERE crapass.cdcooper = par_cdcooper       AND
                            crapass.nrdconta = crapseg.nrdconta   NO-LOCK:
   
        IF   crapseg.lsctrant <> ""   THEN
             NEXT.
        
        IF   par_telcdage > 0  THEN
             IF   crapass.cdagenci <> par_telcdage    THEN
                  NEXT.
   
        CREATE w-seguro.
        ASSIGN w-seguro.cdagenci = crapass.cdagenci
               w-seguro.cdsitseg = crapseg.cdsitseg
               w-seguro.dtmvtolt = crapseg.dtmvtolt
               w-seguro.nrdconta = crapseg.nrdconta 
               w-seguro.vllanmto = crapseg.vlpremio.
        
    END.
        
    
    FOR EACH w-seguro NO-LOCK BREAK BY w-seguro.cdagenci
                                    BY w-seguro.nrdconta:    
        
        IF   FIRST-OF(w-seguro.cdagenci)   THEN
             DO:
                 FIND crapage WHERE crapage.cdcooper = par_cdcooper   AND
                                    crapage.cdagenci = w-seguro.cdagenci  
                                    NO-LOCK NO-ERROR.

                 DISPLAY STREAM str_1 crapage.cdagenci  
                                      crapage.nmextage WITH FRAME f_pac.
             END.
        
        ASSIGN rel_vlpremio =  w-seguro.vllanmto 

               rel_vlreceit = (rel_vlpremio / ((par_vlrdeiof1 / 100) + 1)) -
                               par_vlrapoli

               rel_vlreceit = rel_vlreceit * (par_vlrdecom1 / 100) 
               
               rel_vlreceit = ROUND(rel_vlreceit,2) NO-ERROR.
        
        IF   rel_vlreceit < 0                OR
        
             TRUNCATE(rel_vlpremio,0) <= 0   OR
             
             rel_vlpremio <= par_vlrapoli    THEN
             
             ASSIGN rel_vlreceit = 0.
               
        ASSIGN rel_vlrepass = rel_vlpremio - rel_vlreceit
               rel_dtcancel = IF   w-seguro.cdsitseg = 4   THEN
                                   w-seguro.dtmvtolt
                              ELSE
                                  ?
               rel_dtsubsti = IF   w-seguro.cdsitseg =3 THEN
                                   w-seguro.dtmvtolt
                              ELSE
                                  ?
               pac_vllanmto = pac_vllanmto + rel_vlpremio
               pac_vlreceit = pac_vlreceit + rel_vlreceit
               pac_vlrepass = pac_vlrepass + rel_vlrepass
               tot_qtseguro = tot_qtseguro + 1.
               
        DISPLAY STREAM str_1 w-seguro.nrdconta   
                             rel_vlpremio
                             rel_vlreceit
                             rel_vlrepass       
                             w-seguro.dtmvtolt
                             rel_dtcancel
                             rel_dtsubsti WITH FRAME f_auto.

        DOWN WITH FRAME f_auto.
                                        
        IF   LAST-OF(w-seguro.cdagenci)   THEN
             DO:
                 IF   par_telcdage = 0   THEN

                      DISPLAY STREAM str_1 pac_vllanmto  
                                           pac_vlreceit   
                                           pac_vlrepass 
                                           WITH FRAME f_auto_total_pac.
                          
                 ASSIGN tot_vllanmto = tot_vllanmto + pac_vllanmto
                        tot_vlreceit = tot_vlreceit + pac_vlreceit
                        tot_vlrepass = tot_vlrepass + pac_vlrepass
                        pac_vllanmto = 0  
                        pac_vlreceit = 0  
                        pac_vlrepass = 0.  
             END.

    END. /* Fim relatorio Seguro Auto */

    DISPLAY STREAM str_1 tot_qtseguro
                         tot_vllanmto   
                         tot_vlreceit   
                         tot_vlrepass  WITH FRAME f_auto_total_coop.

    VIEW STREAM str_1 FRAME f_aviso_auto.

    ASSIGN tot_qtseguro = 0
           tot_vllanmto = 0
           tot_vlreceit = 0
           tot_vlrepass = 0.

    RETURN "OK".

END PROCEDURE. /* Fim da procedure proc_auto crrl507 */ 


PROCEDURE proc_vida:  

    DEF INPUT PARAM par_cdcooper AS INTE             NO-UNDO.       
    DEF INPUT PARAM par_cdagenci AS INTE             NO-UNDO.       
    DEF INPUT PARAM par_nrdcaixa AS INTE             NO-UNDO.   
    DEF INPUT PARAM par_cdoperad AS CHAR             NO-UNDO.       
    DEF INPUT PARAM par_nmdatela AS CHAR             NO-UNDO.       
    DEF INPUT PARAM par_idorigem AS INTE             NO-UNDO.     
    DEF INPUT PARAM par_dtmvtolt AS DATE             NO-UNDO.       
   
    DEF INPUT PARAM par_telcdage AS INTE             NO-UNDO.       
    DEF INPUT PARAM par_dtiniper AS DATE             NO-UNDO.       
    DEF INPUT PARAM par_dtfimper AS DATE             NO-UNDO.       
    DEF INPUT PARAM par_vlrdeiof2 AS DECI             NO-UNDO.       
    DEF INPUT PARAM par_vlrapoli AS DECI             NO-UNDO.       
    DEF INPUT PARAM par_vlrdecom2 AS DECI             NO-UNDO.   
    DEF INPUT PARAM TABLE FOR w-seguro.
   
    DEF OUTPUT PARAM TABLE FOR tt-erro.
   
    
    /* Variaveis para gerar o relatorio Receitas Seguros */
    DEF VAR rel_vlreceit AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    DEF VAR rel_vlrepass AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.

    DEF VAR pac_vllanmto AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    DEF VAR pac_vlreceit AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    DEF VAR pac_vlrepass AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.

    DEF VAR tot_qtseguro AS   INTE  FORMAT "   z,zzz,zz9"           NO-UNDO.
    DEF VAR tot_vllanmto AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    DEF VAR tot_vlreceit AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    DEF VAR tot_vlrepass AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.

   
    FORM w-seguro.nrdconta   COLUMN-LABEL "C/C"                   AT 1 
         w-seguro.tpplaseg   COLUMN-LABEL "Plano"                 AT 14
         w-seguro.vllanmto   COLUMN-LABEL "Parcela do seguro"     AT 27
         rel_vlreceit        COLUMN-LABEL "Receita"               AT 47
         rel_vlrepass        COLUMN-LABEL "Repasse Corretora"     AT 62
         w-seguro.dtmvtolt   COLUMN-LABEL "Data inclusao"         AT 82
         WITH DOWN WIDTH 132 FRAME f_vida.

    FORM "TOTAL"                                              AT 22
         pac_vllanmto                                         AT 32
         pac_vlreceit                                         AT 47
         pac_vlrepass                                         AT 67
         WITH WIDTH 132 SIDE-LABELS NO-LABELS FRAME f_pac_total.
         
    FORM SKIP(1)
         tot_qtseguro        LABEL "QUANTIDADE SEGURO VIDA "  
         SKIP(1)
         tot_vllanmto        LABEL "TOTAL DAS PARCELAS     "  
         SKIP(1)
         tot_vlreceit        LABEL "TOTAL RECEITA          "  
         SKIP(1)
         tot_vlrepass        LABEL "TOTAL REPASSE CORRETORA"  
         SKIP(1)
         WITH SIDE-LABEL WIDTH 132 FRAME f_coop_total.

    FORM "PA :"
  
         crapage.cdagenci
         " - "
     
         crapage.nmextage
         WITH WIDTH 132 NO-LABELS FRAME f_pac.

    FORM "SEGURO VIDA - De"
         par_dtiniper        FORMAT "99/99/9999"
         "a"
         par_dtfimper        FORMAT "99/99/9999"
         WITH WIDTH 132 SIDE-LABELS NO-LABELS FRAME f_periodo_vida.
      

    DISPLAY STREAM str_1 par_dtiniper
                         par_dtfimper WITH FRAME f_periodo_vida.
    
    FOR EACH w-seguro WHERE w-seguro.tpseguro = 3
                            NO-LOCK BREAK BY w-seguro.cdagenci
                                          BY w-seguro.nrdconta:

        IF   FIRST-OF(w-seguro.cdagenci)   THEN
             DO:
                 FIND crapage WHERE crapage.cdcooper = par_cdcooper   AND
                                    crapage.cdagenci = w-seguro.cdagenci
                                    NO-LOCK NO-ERROR.

                 DISPLAY STREAM str_1 crapage.cdagenci
                                      crapage.nmextage WITH FRAME f_pac.
             END.

        ASSIGN rel_vlreceit = (w-seguro.vllanmto / ((par_vlrdeiof2 / 100) + 1))
                
               rel_vlreceit = rel_vlreceit * (par_vlrdecom2 / 100)
               
               tot_vlreceit = tot_vlreceit + rel_vlreceit

               rel_vlreceit = ROUND(rel_vlreceit,2)

               rel_vlrepass = w-seguro.vllanmto  - rel_vlreceit

               pac_vllanmto = pac_vllanmto       + w-seguro.vllanmto
               
               pac_vlreceit = pac_vlreceit       + rel_vlreceit 
                              
               pac_vlrepass = pac_vlrepass       + rel_vlrepass
               
               tot_qtseguro = tot_qtseguro       + 1.

        DISPLAY STREAM str_1 w-seguro.nrdconta
                             w-seguro.tpplaseg
                             w-seguro.vllanmto
                             rel_vlreceit
                             rel_vlrepass      
                             w-seguro.dtmvtolt WITH FRAME f_vida.
                         
        DOWN WITH FRAME f_vida.

        IF   LAST-OF(w-seguro.cdagenci)   THEN
             DO:
                 IF   par_telcdage = 0   THEN
                    
                      DISPLAY STREAM str_1 pac_vllanmto
                                           pac_vlreceit
                                           pac_vlrepass WITH FRAME f_pac_total.
                                 
                 ASSIGN tot_vllanmto = tot_vllanmto + pac_vllanmto
                        tot_vlrepass = tot_vlrepass + pac_vlrepass
                        pac_vllanmto = 0
                        pac_vlreceit = 0
                        pac_vlrepass = 0.
             END.
  
    END.   /* Fim do seguro VIDA */

    DISPLAY STREAM str_1 tot_qtseguro
                         tot_vllanmto
                         tot_vlreceit
                         tot_vlrepass WITH FRAME f_coop_total.

    ASSIGN tot_qtseguro = 0
           tot_vllanmto = 0
           tot_vlreceit = 0
           tot_vlrepass = 0.

    RETURN "OK".

END PROCEDURE. /* Fim da procedure proc_vida, crrl505  */


PROCEDURE proc_residencial:

    DEF INPUT PARAM par_cdcooper  AS INTE             NO-UNDO.       
    DEF INPUT PARAM par_cdagenci  AS INTE             NO-UNDO.       
    DEF INPUT PARAM par_nrdcaixa  AS INTE             NO-UNDO.   
    DEF INPUT PARAM par_cdoperad  AS CHAR             NO-UNDO.       
    DEF INPUT PARAM par_nmdatela  AS CHAR             NO-UNDO.       
    DEF INPUT PARAM par_idorigem  AS INTE             NO-UNDO.     
    DEF INPUT PARAM par_dtmvtolt  AS DATE             NO-UNDO.       

    DEF INPUT PARAM par_telcdage  AS INTE             NO-UNDO.       
    DEF INPUT PARAM par_dtiniper  AS DATE             NO-UNDO.       
    DEF INPUT PARAM par_dtfimper  AS DATE             NO-UNDO.       
    DEF INPUT PARAM par_vlrdeiof3 AS DECI             NO-UNDO.       
    DEF INPUT PARAM par_vlrapoli  AS DECI             NO-UNDO.       
    DEF INPUT PARAM par_vlrdecom3 AS DECI             NO-UNDO.   
    DEF INPUT PARAM TABLE FOR w-seguro.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    /* Variaveis para gerar o relatorio Receitas Seguros */
    DEF VAR rel_vlreceit AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    DEF VAR rel_vlrepass AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    
    DEF VAR pac_vllanmto AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    DEF VAR pac_vlreceit AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    DEF VAR pac_vlrepass AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.

    DEF VAR tot_qtseguro AS   INTE  FORMAT "   z,zzz,zz9"           NO-UNDO.
    DEF VAR tot_vllanmto AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    DEF VAR tot_vlreceit AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.
    DEF VAR tot_vlrepass AS   DECI  FORMAT "z,zzz,zz9.99"           NO-UNDO.

    
    FORM w-seguro.nrdconta COLUMN-LABEL "C/C"                  AT 01
         w-seguro.tpplaseg COLUMN-LABEL "Plano"                AT 14
         w-seguro.vllanmto COLUMN-LABEL "Parcela do seguro"    AT 27
         rel_vlreceit      COLUMN-LABEL "Receita"              AT 47
         rel_vlrepass      COLUMN-LABEL "Repasse Corretora"    AT 62
         w-seguro.dtmvtolt COLUMN-LABEL "Data inclusao"        AT 82
         WITH DOWN WIDTH 132 FRAME f_res.
       
    FORM "TOTAL"                                               AT 22
         pac_vllanmto                                          AT 32
         pac_vlreceit                                          AT 47
         pac_vlrepass                                          AT 67
         WITH WIDTH 132 SIDE-LABELS NO-LABELS FRAME f_res_total_pac.
         
    FORM SKIP(1)
         tot_qtseguro      LABEL "QUANTIDADE SEGURO RESIDENCIAL"
         SKIP(1)
         tot_vllanmto      LABEL "TOTAL DAS PARCELAS           "
         SKIP(1)
         tot_vlreceit      LABEL "TOTAL RECEITA                "
         SKIP(1)
         tot_vlrepass      LABEL "TOTAL REPASSE CORRETORA      "
         SKIP(1)
         WITH SIDE-LABELS WIDTH 132 FRAME f_res_total_coop.

    FORM "SEGURO RESIDENCIAL - De"
         par_dtiniper               FORMAT "99/99/9999"
         "a"
         par_dtfimper               FORMAT "99/99/9999"
         WITH WIDTH 132 SIDE-LABELS NO-LABELS FRAME f_periodo_residencial.

    FORM "PA :"
  
         crapage.cdagenci
         " - "
     
         crapage.nmextage
         WITH WIDTH 132 NO-LABELS FRAME f_pac.
         
       
    /****SEGURO RESIDENCIAL*******
    - Valor receita = (Valor da parcela - IOF%)  * COMISSAO%) 
    - Valor repasse =  Valor da parcela -  valor receita 
    ****************************/
    
    DISPLAY STREAM str_1 par_dtiniper
                         par_dtfimper WITH FRAME f_periodo_residencial.

    FOR EACH w-seguro WHERE w-seguro.tpseguro = 11 
                            NO-LOCK BREAK BY w-seguro.cdagenci 
                                          BY w-seguro.nrdconta:
       
        IF   FIRST-OF(w-seguro.cdagenci)   THEN
             DO:
                 FIND crapage WHERE crapage.cdcooper = par_cdcooper   AND
                                    crapage.cdagenci = w-seguro.cdagenci
                                    NO-LOCK NO-ERROR.

                 DISPLAY STREAM str_1 crapage.cdagenci  
                                      crapage.nmextage WITH FRAME f_pac.
             END.
            
        ASSIGN rel_vlreceit = (w-seguro.vllanmto / ((par_vlrdeiof3 / 100) + 1))
                              
               rel_vlreceit = rel_vlreceit * (par_vlrdecom3 / 100)

               tot_vlreceit = tot_vlreceit + rel_vlreceit

               rel_vlreceit = ROUND(rel_vlreceit,2) 

               rel_vlrepass = w-seguro.vllanmto  - rel_vlreceit
                
               pac_vllanmto = pac_vllanmto       + w-seguro.vllanmto

               pac_vlreceit = pac_vlreceit       + rel_vlreceit 
               
               pac_vlrepass = pac_vlrepass       + rel_vlrepass
               
               tot_qtseguro = tot_qtseguro       + 1. 

        DISPLAY STREAM str_1 w-seguro.nrdconta
                             w-seguro.tpplaseg
                             w-seguro.vllanmto
                             rel_vlreceit
                             rel_vlrepass    
                             w-seguro.dtmvtolt WITH FRAME  f_res.
                             
        DOWN WITH FRAME f_res.                      

        IF   LAST-OF(w-seguro.cdagenci)   THEN
             DO:
                 IF  par_telcdage = 0   THEN
                 
                     DISPLAY STREAM str_1 pac_vllanmto   
                                          pac_vlreceit   
                                          pac_vlrepass
                                          WITH FRAME f_res_total_pac.
                         
                 ASSIGN tot_vllanmto = tot_vllanmto + pac_vllanmto
                        tot_vlrepass = tot_vlrepass + pac_vlrepass
                        pac_vllanmto = 0  
                        pac_vlreceit = 0  
                        pac_vlrepass = 0.
             END.
                                        
    END.  /* Fim do seguro Residencial */                                  

    DISPLAY STREAM str_1 tot_qtseguro
                         tot_vllanmto   
                         tot_vlreceit   
                         tot_vlrepass WITH FRAME f_res_total_coop.

    ASSIGN tot_qtseguro = 0
           tot_vllanmto = 0
           tot_vlreceit = 0
           tot_vlrepass = 0.

    RETURN "OK".
    
END PROCEDURE. /* Fim da procedure proc_residencial, crrl506 */


PROCEDURE proc_gerencial:

    DEF INPUT PARAM par_cdcooper  AS INTE             NO-UNDO.         
    DEF INPUT PARAM par_cdagenci  AS INTE             NO-UNDO.        
    DEF INPUT PARAM par_nrdcaixa  AS INTE             NO-UNDO.  
    DEF INPUT PARAM par_cdoperad  AS CHAR             NO-UNDO.   
    DEF INPUT PARAM par_nmdatela  AS CHAR             NO-UNDO.   
    DEF INPUT PARAM par_idorigem  AS INTE             NO-UNDO. 
    DEF INPUT PARAM par_dtmvtolt  AS DATE             NO-UNDO.     
                                                                    
    DEF INPUT PARAM par_telcdage  AS INTE             NO-UNDO.      
    DEF INPUT PARAM par_dtiniper  AS DATE             NO-UNDO.      
    DEF INPUT PARAM par_dtfimper  AS DATE             NO-UNDO.     
    DEF INPUT PARAM par_vlrdeiof1 AS DECI             NO-UNDO.     
    DEF INPUT PARAM par_vlrdeiof2 AS DECI             NO-UNDO.     
    DEF INPUT PARAM par_vlrdeiof3 AS DECI             NO-UNDO.      
    DEF INPUT PARAM par_vlrapoli  AS DECI             NO-UNDO.     
    DEF INPUT PARAM par_vlrdecom1 AS DECI             NO-UNDO.     
    DEF INPUT PARAM par_vlrdecom2 AS DECI             NO-UNDO.     
    DEF INPUT PARAM par_vlrdecom3 AS DECI             NO-UNDO.    
    DEF INPUT PARAM TABLE FOR w-seguro.                           

    DEF OUTPUT PARAM TABLE FOR tt-erro.


    DEF VAR tot_qtseguro AS   INTE  FORMAT "   z,zzz,zz9"   NO-UNDO.
    DEF VAR tot_vllanmto AS   DECI  FORMAT "z,zzz,zz9.99"   NO-UNDO.
    DEF VAR tot_vlreceit AS   DECI  FORMAT "z,zzz,zz9.99"   NO-UNDO.
    DEF VAR tot_vlrepass AS   DECI  FORMAT "z,zzz,zz9.99"   NO-UNDO.
    DEF VAR tot_qtdnovos AS INTEGER FORMAT "   z,zzz,zz9"   NO-UNDO.
    DEF VAR tot_qtdcance AS INTEGER FORMAT "   z,zzz,zz9"   NO-UNDO.

    DEF VAR pac_qtseguro AS   INTE                          NO-UNDO.
    DEF VAR pac_vllanmto AS   DECI  FORMAT "z,zzz,zz9.99"   NO-UNDO.
    DEF VAR pac_vlreceit AS   DECI  FORMAT "z,zzz,zz9.99"   NO-UNDO.
    DEF VAR pac_vlrepass AS   DECI  FORMAT "z,zzz,zz9.99"   NO-UNDO.

    DEF VAR ger_qtseguro AS INTEGER                         NO-UNDO.
    DEF VAR ger_vllanmto AS DECIMAL                         NO-UNDO.
    DEF VAR ger_vlreceit AS DECIMAL                         NO-UNDO.
    DEF VAR ger_vlrepass AS DECIMAL                         NO-UNDO.

    DEFINE VARIABLE aux_qtdnovos AS INTEGER    NO-UNDO.
    DEFINE VARIABLE aux_qtdcance AS INTEGER    NO-UNDO.

 
    FORM tt-info-seguros.cdagenci COLUMN-LABEL "PA "  AT 1                
         pac_qtseguro             COLUMN-LABEL "       Quantidade"    
         pac_vllanmto             COLUMN-LABEL "Total dos seguros"   
         pac_vlreceit             COLUMN-LABEL "Receita"             
         pac_vlrepass             COLUMN-LABEL "Repasse Corretora"   
         WITH WIDTH 132 ATTR-SPACE DOWN FRAME f_gerencial.

    FORM tt-info-seguros.cdagenci COLUMN-LABEL "PA " AT 1                
         pac_qtseguro             COLUMN-LABEL "Seguros debitados"   
         pac_vllanmto             COLUMN-LABEL "Total dos seguros"   
         pac_vlreceit             COLUMN-LABEL "Receita"            
         pac_vlrepass             COLUMN-LABEL "Repasse Corretora" 
         aux_qtdnovos             COLUMN-LABEL "Novos"
         aux_qtdcance             COLUMN-LABEL "Cancelados"
         WITH WIDTH 132 ATTR-SPACE DOWN FRAME f_gerencial2.

    FORM "TOTAL"           AT  1
         tot_qtseguro      AT 11   
         tot_vllanmto      AT 30
         tot_vlreceit      AT 44
         tot_vlrepass      AT 63
         tot_qtdnovos      AT 75
         tot_qtdcance      AT 87
         WITH WIDTH 132 SIDE-LABEL NO-LABELS FRAME f_total_gerencial.

    FORM "As informacoes do Seguro Auto sao apenas para fins de acompanhamento."
         "Os valores e prazos expressos podem sofrer alteracoes. Em caso de"  
         "divergencias esclarecer com a corretora."
         WITH FRAME f_aviso_auto.

    FORM ger_qtseguro    LABEL "QUANTIDADE DE SEGUROS  " FORMAT "   zzz,zzz,zz9"
         SKIP(1)
         ger_vllanmto    LABEL "TOTAL DOS SEGUROS      " FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         ger_vlreceit    LABEL "TOTAL DAS RECEITAS     " FORMAT "zzz,zzz,zz9.99"
         SKIP(1)
         ger_vlrepass    LABEL "TOTAL REPASSE CORRETORA" FORMAT "zzz,zzz,zz9.99"

         WITH SIDE-LABELS WIDTH 132 ATTR-SPACE DOWN FRAME f_tot_gerencial.

    FORM "SEGURO AUTO - De"
          par_dtiniper      FORMAT "99/99/9999"
          "a"
          par_dtfimper      FORMAT "99/99/9999"
          WITH NO-LABEL SIDE-LABELS WIDTH 132 FRAME f_periodo_auto.

    FORM "SEGURO VIDA - De"
          par_dtiniper        FORMAT "99/99/9999"
          "a"
          par_dtfimper        FORMAT "99/99/9999"
          WITH WIDTH 132 SIDE-LABELS NO-LABELS FRAME f_periodo_vida.

    FORM "SEGURO RESIDENCIAL - De"
          par_dtiniper               FORMAT "99/99/9999"
          "a"
          par_dtfimper               FORMAT "99/99/9999"
          WITH WIDTH 132 SIDE-LABELS NO-LABELS FRAME f_periodo_residencial.


/*............................................................................*/
    /* Seguros auto  */
    RUN seguros-auto(INPUT par_cdcooper,
                     INPUT 2,
                     INPUT 4,
                     INPUT par_dtiniper,
                     INPUT par_dtfimper,
                     INPUT par_telcdage,
                     INPUT par_vlrapoli,
                     INPUT par_vlrdecom1,  /* OBS: nao foi possivel receber*/           
                     INPUT par_vlrdeiof1,  /* parametros extent na         */
                     INPUT par_vlrdecom2,  /* procedure, por isso esta     */
                     INPUT par_vlrdeiof2,  /* sendo passado cada campo     */
                     INPUT par_vlrdecom3,
                     INPUT par_vlrdeiof3,
                     OUTPUT TABLE tt-info-seguros).
/*............................................................................*/

/*............................................................................*/
    FOR EACH tt-info-seguros NO-LOCK WHERE BREAK BY tt-info-seguros.tpseguro
                                                 BY tt-info-seguros.cdagenci:

        IF   FIRST-OF(tt-info-seguros.tpseguro)   THEN
             DO:
                 IF   tt-info-seguros.tpseguro = 2   THEN
                      DISPLAY STREAM str_1 par_dtiniper
                                           par_dtfimper 
                                           WITH FRAME f_periodo_auto.
                 ELSE
                 IF   tt-info-seguros.tpseguro = 3   THEN
                      DISPLAY STREAM str_1 par_dtiniper
                                           par_dtfimper
                                           WITH FRAME f_periodo_vida.
                 ELSE
                      DISPLAY STREAM str_1 par_dtiniper
                                           par_dtfimper
                                           WITH FRAME f_periodo_residencial.
             END.

        IF   LAST-OF(tt-info-seguros.cdagenci) THEN
             DO:
                 IF  tt-info-seguros.tpseguro = 2  THEN DO:
                     ASSIGN pac_qtseguro = tt-info-seguros.qtsegaut
                            pac_vllanmto = tt-info-seguros.vlsegaut
                            pac_vlreceit = tt-info-seguros.vlrecaut
                            pac_vlrepass = tt-info-seguros.vlrepaut.

                      DISPLAY STREAM str_1 tt-info-seguros.cdagenci
                                           pac_qtseguro
                                           pac_vllanmto
                                           pac_vlreceit
                                           pac_vlrepass
                          WITH FRAME f_gerencial.
                 END.
/*............................................................................*/
                 ELSE DO:
                      IF tt-info-seguros.tpseguro = 3 THEN
                         ASSIGN pac_qtseguro = tt-info-seguros.qtsegvid
                                pac_vllanmto = tt-info-seguros.vlsegvid
                                pac_vlreceit = tt-info-seguros.vlrecvid
                                pac_vlrepass = tt-info-seguros.vlrepvid
                                aux_qtdnovos = tt-info-seguros.qtincvid
                                aux_qtdcance = tt-info-seguros.qtexcvid.
                      ELSE
                          ASSIGN pac_qtseguro = tt-info-seguros.qtsegres
                                 pac_vllanmto = tt-info-seguros.vlsegres
                                 pac_vlreceit = tt-info-seguros.vlrecres
                                 pac_vlrepass = tt-info-seguros.vlrepres
                                 aux_qtdnovos = tt-info-seguros.qtincres
                                 aux_qtdcance = tt-info-seguros.qtexcres.

                      DISPLAY STREAM str_1 tt-info-seguros.cdagenci
                                           pac_qtseguro
                                           pac_vllanmto
                                           pac_vlreceit
                                           pac_vlrepass
                                           aux_qtdnovos
                                           aux_qtdcance
                          WITH FRAME f_gerencial2.

                      ASSIGN tot_qtdnovos = tot_qtdnovos + 
                                            aux_qtdnovos
                             tot_qtdcance = tot_qtdcance +
                                            aux_qtdcance.
                 END. /* END do ELSE DO:*/
                 
                 DOWN WITH FRAME f_gerencial.
                
                 DOWN WITH FRAME f_gerencial2.
/*............................................................................*/
                 IF tt-info-seguros.tpseguro = 2   THEN
                    ASSIGN tot_qtseguro = tot_qtseguro +
                                          tt-info-seguros.qtsegaut
                           tot_vllanmto = tot_vllanmto +
                                          tt-info-seguros.vlsegaut
                           tot_vlreceit = tot_vlreceit +
                                          tt-info-seguros.vlrecaut
                           tot_vlrepass = tot_vlrepass +
                                          tt-info-seguros.vlrepaut.
                 ELSE
                 IF   tt-info-seguros.tpseguro = 3   THEN
                    ASSIGN tot_qtseguro = tot_qtseguro +
                                          tt-info-seguros.qtsegvid
                           tot_vllanmto = tot_vllanmto +
                                          tt-info-seguros.vlsegvid
                           tot_vlreceit = tot_vlreceit +
                                          tt-info-seguros.vlrecvid
                           tot_vlrepass = tot_vlrepass +
                                          tt-info-seguros.vlrepvid.
                 ELSE
                    ASSIGN tot_qtseguro = tot_qtseguro +
                                          tt-info-seguros.qtsegres
                           tot_vllanmto = tot_vllanmto +
                                          tt-info-seguros.vlsegres
                           tot_vlreceit = tot_vlreceit +
                                          tt-info-seguros.vlrecres
                           tot_vlrepass = tot_vlrepass +
                                          tt-info-seguros.vlrepres.
        END. /* FIM  do IF   LAST-OF(tt-info-seguros.cdagenci) THEN*/

        IF   LAST-OF (tt-info-seguros.tpseguro)    THEN
             DO:
                 IF  par_telcdage = 0  THEN

                     DISPLAY STREAM str_1 tot_qtseguro
                                          tot_vllanmto
                                          tot_vlreceit
                                          tot_vlrepass
                                          tot_qtdnovos
                                          WHEN tt-info-seguros.tpseguro <> 2
                                          tot_qtdcance
                                          WHEN tt-info-seguros.tpseguro <> 2
                                          WITH FRAME f_total_gerencial.

                 IF   tt-info-seguros.tpseguro = 2   THEN
                      VIEW STREAM str_1 FRAME f_aviso_auto.

                 DISPLAY STREAM str_1 SKIP(1). 

                 ASSIGN ger_qtseguro = ger_qtseguro + tot_qtseguro
                        ger_vllanmto = ger_vllanmto + tot_vllanmto
                        ger_vlreceit = ger_vlreceit + tot_vlreceit
                        ger_vlrepass = ger_vlrepass + tot_vlrepass
                        tot_qtseguro = 0
                        tot_vllanmto = 0
                        tot_vlreceit = 0
                        tot_vlrepass = 0
                        tot_qtdnovos = 0
                        tot_qtdcance = 0.
             END.
    END. /* Fim FOR EACH tt-info-seguros */

    DISPLAY STREAM str_1 ger_qtseguro
                         ger_vllanmto
                         ger_vlreceit
                         ger_vlrepass WITH FRAME f_tot_gerencial.

    RETURN "OK".

END PROCEDURE. /* Fim da procedure proc_gerencial crrl508 */


PROCEDURE proc_cancelamento.

    DEF INPUT PARAM par_cdcooper AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INTE                    NO-UNDO. 
    DEF INPUT PARAM par_nmdatela AS CHAR                    NO-UNDO.
    DEF INPUT PARAM par_telcdage AS INTE                    NO-UNDO.
    DEF INPUT PARAM par_dtiniper AS DATE                    NO-UNDO.
    DEF INPUT PARAM par_dtfimper AS DATE                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    DEF VAR par_qtregist AS INTE        NO-UNDO.
    DEF VAR aux_cdcritic AS INTE        NO-UNDO.      
    DEF VAR aux_dscritic AS CHAR        NO-UNDO.
    DEF VAR aux_flgtrans AS LOG         NO-UNDO.


    FORM  crapcop.nmrescop "- MOTIVOS CANCELAMENTO SEGURO RESIDENCIAL"
          WITH NO-LABEL WIDTH 200 FRAME f_seg.

    FORM crapass.cdagenci COLUMN-LABEL "PA"
         crapass.nrdconta COLUMN-LABEL "Conta"
         crapass.nmprimtl COLUMN-LABEL "Cooperado"
         crapseg.dtinivig COLUMN-LABEL "Inicio da Vingencia"
         crapseg.dtfimvig COLUMN-LABEL "Fim da Vingencia"
         crapseg.dtcancel COLUMN-LABEL "Data Cancelamento" 
         tt-mot-can.dsmotcan COLUMN-LABEL "Motivo Cancelamento"
         WITH WIDTH 200 DOWN FRAME f_seg_cancelados.

    ASSIGN aux_cdcritic = 0
           aux_dscritic = "".

    EMPTY TEMP-TABLE tt-erro.


    DO WHILE TRUE ON ERROR UNDO, LEAVE:

       FIND crapcop WHERE crapcop.cdcooper = par_cdcooper
                          NO-LOCK NO-ERROR.
         
       IF NOT AVAIL crapcop THEN
          DO:
             ASSIGN aux_cdcritic = 651.
             LEAVE.
          END.
         
         
       RUN sistema/generico/procedures/b1wgen0033.p 
           PERSISTENT SET h-b1wgen0033.
         
       RUN buscar_motivo_can 
           IN h-b1wgen0033 (INPUT par_cdcooper,
                            INPUT par_cdagenci,
                            INPUT par_nrdcaixa,
                            INPUT par_cdoperad,
                            INPUT par_dtmvtolt,
                            INPUT 0, /* nrdconta */
                            INPUT 0, /* idseqttl */
                            INPUT par_idorigem,
                            INPUT par_nmdatela,
                            INPUT FALSE,
                            INPUT 0,
                            INPUT "",
                            OUTPUT par_qtregist,
                            OUTPUT TABLE tt-mot-can,
                            OUTPUT TABLE tt-erro).
         
        IF VALID-HANDLE(h-b1wgen0033) THEN
            DELETE PROCEDURE h-b1wgen0033.
         
        IF RETURN-VALUE <> "OK" THEN
           LEAVE.
   
        DISP STREAM str_1 crapcop.nmrescop WITH FRAME f_seg. 

        FOR EACH crapass WHERE crapass.cdcooper = par_cdcooper AND
                               (IF par_telcdage <> 0 THEN 
                                   crapass.cdagenci = par_telcdage
                                ELSE
                                   TRUE)                       AND
                               crapass.dtdemiss = ? NO-LOCK,
         
            EACH crapseg WHERE crapseg.cdcooper = crapass.cdcooper AND
                               crapseg.nrdconta = crapass.nrdconta AND
                              (crapseg.tpseguro = 1                OR
                               crapseg.tpseguro = 11)              AND
                               crapseg.cdsitseg = 2                AND 
                               crapseg.dtcancel >= par_dtiniper    AND
                               crapseg.dtcancel <= par_dtfimper  
                               NO-LOCK BREAK BY crapass.cdagenci
                                             BY crapass.nrdconta:
        
            FIND tt-mot-can WHERE tt-mot-can.cdmotcan = crapseg.cdmotcan 
                                  NO-LOCK NO-ERROR.
           
            IF LINE-COUNTER(str_1) = PAGE-SIZE(str_1) THEN
               DO:
                  PAGE STREAM str_1.
                  VIEW STREAM str_1 FRAME f_seg.
               END.

            DISP STREAM str_1 crapass.cdagenci 
                              crapass.nrdconta
                              crapass.nmprimtl
                              crapseg.dtinivig
                              crapseg.dtfimvig
                              crapseg.dtcancel
                              tt-mot-can.dsmotcan WHEN AVAIL tt-mot-can
                              WITH FRAME f_seg_cancelados.
        
                              DOWN WITH FRAME f_seg_cancelados.
         
        END. /* Fim do FOR EACH */

        ASSIGN aux_flgtrans = TRUE.
        LEAVE.

    END. /* Fim do While True */


    IF NOT aux_flgtrans  THEN
       DO:
          IF NOT TEMP-TABLE tt-erro:HAS-RECORDS THEN
             RUN gera_erro ( INPUT par_cdcooper,
                             INPUT par_cdagenci,
                             INPUT par_nrdcaixa,
                             INPUT 1,            /** Sequencia **/
                             INPUT aux_cdcritic,
                             INPUT-OUTPUT aux_dscritic ).
             RETURN "NOK".
       END.

    RETURN "OK".

END PROCEDURE.  /* Fim do relatorio de cancelamentos residenciais */



