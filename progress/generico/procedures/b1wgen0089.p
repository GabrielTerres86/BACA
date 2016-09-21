/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +----------------------------------+-----------------------------------------+
  | Rotina Progress                  | Rotina Oracle PLSQL                     |
  +----------------------------------+-----------------------------------------+
  | procedures/b1wgen0089.p          | PAGA0001                                |
  |   ent-confirmada                 | PAGA0002.pc_ent_confirmada              |
  |   ent-rejeitada                  | PAGA0002.pc_ent_rejeitada               |
  |   proc-baixa                     | PAGA0002.pc_proc_baixa                  |
  |   proc-conf-instrucao            | PAGA0002.pc_proc_conf_instrucao         |
  |   proc-remessa-cartorio          | PAGA0002.pc_proc_remessa_cartorio       |
  |   proc-retirada-cartorio         | PAGA0002.pc_proc_retirada_cartorio      |
  |   proc-protestado                | PAGA0002.pc_proc_protestado             |
  |   proc-debito-tarifas-custas     | PAGA0002.pc_proc_deb_tarifas_custas     |
  |   proc-retorno-qualquer          | PAGA0002.pc_proc_retorno_qualquer       |
  |   prep-tt-lcm-mot-consolidada    | PAGA0002.pc_prep_lcm_mot_consolidada    | 
  |   proc-liquidacao                | PAGA0001.pc_processa_liquidacao         |
  |   realiza-lancto-cooperado       | PAGA0001.pc_realiza_lancto_cooperado    |
  |   cria-log-cobranca              | PAGA0001.pc_cria_log_cobranca           |
  |   proc-motivos-retorno           | PAGA0001.pc_proc_motivos_retorno        |
  |   prep-tt-lcm-consolidada        | PAGA0001.pc_prep_tt_lcm_consolidada     |
  |   prep-retorno-cooperado         | PAGA0001.pc_prep_retorno_cooperado      |
  |   prepara-retorno-cooperativa    | PAGA0001.pc_prepara_retorno_cooperativa |
  |   grava-retorno                  | PAGA0001.pc_grava_retorno               |
  |   busca-dados-tarifa             | TARI0001.pc_busca_dados_tarifa          |
  |   cria-log-tarifa-cobranca       | TARI0001.pc_cria_log_tarifa_cobranca    |
  |   proc-liquidacao-apos-bx        | PAGA0001.pc_proc_liquid_apos_baixa      |
  +----------------------------------+-----------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/







/*..............................................................................

   Programa: sistema/internet/procedures/b1wgen0089.p
   Autor   : Guilherme/Supero
   Data    : 13/04/2011                        Ultima atualizacao: 26/02/2016

   Dados referentes ao programa:

   Objetivo  : BO para Retorno Instruções bancárias - Cob. Registrada 

   Alteracoes: 02/05/2011 - Incluso procedure prepara-retorno (Guilherme).
               
               16/05/2011 - Acerto na procedure proc-motivos-retorno(Guilherme).
               
               28/06/2011 - Acerto na proc-liquidacao - gerar sempre retorno ao
                            cooperado mesmo que nao ha tarifa de liquidacao
                            (Rafael).
                            
               08/07/2011 - Incluido horario de lancamento na conta do
                            cooperado - hrtransa = TIME (Rafael).
                          - Retirada chamada para procedure procedimentos-dda-jd_bo89
                            dentro da procedure proc-liquidacao (Elton).
                            
               18/07/2011 - Gravado na temp-table de lancamentos, os registros
                            referentes a debitos e creditos, na procedure
                            proc-debito-tarifas-custas. (Fabricio)
                            
               21/07/2011 - Alterado rotina proc-liquidacao:
                            Ajuste na preparacao do retorno ao cooperado
                            Ajuste no lanctos da cob. registrada 085 (Rafael)
                            
               26/07/2011 - Feito tratamento para o campo crapret.cdhistbb,
                            na procedure grava-retorno. (Fabricio)
                            
               27/07/2011 - Removido valor ? dos campos dtdpagto e vldpagto
                            na procedure proc-baixa (Rafael).
                          - Nao cobrar tarifa do cooperado (Rafael).
               
               29/07/2011 - Implementado rotina de inst autom de baixa
                            na procedure proc-conf-instrucao (Rafael).
                            
               30/08/2011 - Incluido cdhistbb = 973 quando cdocorre = 23
                            (973-Custas Cart, 23 = Remessa Cart) (Rafael).
                            
               10/10/2011 - Incluida a procedure prep-tt-lcm-mot-consolidada
                            (Henrique).
                            
               18/10/2011 - Ajustes na rotina autom de baixa. (Rafael).
               
               20/10/2011 - Nao gravar log do titulo quando os motivos da 
                            ent rejeitada forem (00,39,60) (Rafael).
                          - Qdo ent confirmada no convenio protesto, comandar
                            inst de protesto automaticamente (Rafael).
                          - Qdo ocorrer: remessa cartorio e sustacao, e já
                            houver uma inst de baixa em um dia anterior, 
                            comandar inst autom de baixa (Rafael).
                          - Nao mostrar "Deb Tarifas Custas - motivo" nas 
                            ocorrencias com código 28. (Rafael).
                            
               08/11/2011 - Ajuste prep-retorno-cooperado nas procedures:
                            proc-liquidacao e proc-retorno-qualquer (Rafael).
                            
               18/11/2011 - Confirmar sustacao de titulo quando ocorrer
                            custas de sustacao enviada pelo BB. (Rafael)
                            
               06/01/2012 - Adequar historicos BB 966 e 939 somente qdo o
                            valor das tarifas > 0. (Rafael)
                            
               27/02/2012 - Melhoria na rotina de inst autom de baixa. (Rafael)
               
               20/04/2012 - Omitir msg log do titulo qdo entrada rejeitada
                            motivo 38 - Prazo p/ protesto invalido. (Rafael)
                            
               11/05/2012 - Rejeitar titulo quando ocorrer ent-rejeitada de 
                            alguns motivos retornados pelo banco. (Rafel)
                          - Tratamento para liquidacao apos baixa. (Rafael)
                          - nao logar no titulo qdo conf de receb de inst 
                            de protesto/sustacao. Tarefa 44895 (Rafael)
                            
               17/05/2012 - alterado dtaltera na procedure grava-retorno pois
                            o BB esta utilizando data retroativa no arquivo
                            de retorno. (Rafael)
                            
               23/05/2012 - Ajuste na rotina de ent-confirmada referente a 
                            instrucao autom de protesto. (Rafael)
                            
               20/08/2012 - Ajuste da rotina de pagto de títulos quando 
                            descontados. (Rafael)
                            
               14/12/2012 - Tratar postergacao de data em caso de titulos
                            descontados na liquidacao. (Rafael)
                            
               16/01/2013 - Ajuste nas rotinas de lancto consolidado. (Rafael)
               
               03/04/2013 - Ajuste na gravacao do vlr pago nos registros de
                            retorno ao cooperado (Softdesk 51391). (Rafael)
                            
               07/05/2013 - Projeto Melhorias da Cobranca. (Rafael)
               
               03/07/2013 - Ajuste na rotina que realiza-lancto-cooperado ref.
                            ao numero do documento na craplcm. (Rafael)
                            
               05/07/2013 - Incluso var_internet.i , alterado processo de busca
                            valor tarifa para utilizar a rotina carrega_dados_tarifa_cobranca
                            da b1wgen0153, alterado realiza-lancto-cooperado para 
                            efetuar lancamentos utilzando a procedure 
                            cria_lan_auto_tarifa da b1wgen0153. (Daniel) 
                            
               26/09/2013 - Alterado o parametro par_dtmvtolt para crapdat.dtmvtolt
                            na procedure cria_lan_auto_tarifa (Daniel).
 
               10/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).     
                            
               24/10/2013 - Retirado a procedure cria-movto-cartorario e chamadas a
                            mesma (Daniel).
                            
               27/11/2013 - Alterado processo de criacao crapcre para inicar 
                            nrremret com 999999 e nao mais 1 (Daniel).
                            
               28/11/2013 - Retirado rotina de replicacao do retorno dos titulos
                            BB do convenio "PROTESTO" para o convenio dos 
                            titulos 085. (Rafael).
                            
               03/12/2013 - Tratamento especial no controle da numeracao da 
                            tabela crapcre dos titulos da cobranca com
                            registro BB. (Rafael).
                            
               17/12/2013 - Adicionado "VALIDATE <tabela>" apos o CREATE de 
                            registros nas tabelas. (Rafael e Jorge).
                            
               24/03/2014 - Ajuste Oracle tratamento FIND LAST da tabela
                            craplcm (Daniel). 
                            
               22/04/2014 - Ajuste na procedure prepara-retorno-cooperativa para
                            usar sequence atraves do Oracle (Daniel)     

               28/04/2014 - Ajuste sequence na procedure prepara-retorno-cooperativa 
                            (Daniel)  			   
               
               21/08/2014 - Alterar o valor passado para o parametro par_vlrliqui,
                            na chamada da rotina grava-retorno, pois está sendo 
                            gravado o valor incorreto para o campo crapret.vlrliqui 
                            ( SD 183392 - Renato - Supero )
                            
               09/10/2014 - Ajustar cred. de cobranca mesmo para convenios 085
                            inativos. (SD 202683 - Rafael)
                            
               31/10/2014 - Ajuste na procedura ent-confirmada, para antes de 
                            enviar instrução de protesto verificar se o boleto já
                            foi liquidado (SD 197217 Odirlei-Amcom) 
               
               28/11/2014 - Ajustado leitura para verificar se boleto original
                            do boleto protestado ja foi liquidado(Odirlei-Amcom)      
               
               05/01/2015 - Alterado proc-liquidacao para quando deletar registro da tabela 
                            craptdb deletar tbm registros filhos nas tabela crapljt e crapabt
                            SD237726 (Odirlei-AMcom)
                            
               21/01/2015 - Conversão da fn_sequence para procedure para não
                            gerar cursores abertos no Oracle. (Dionathan)

               29/10/2015 - Inclusao indicador estado de crise na: proc-liquidacao,
                            proc-liquidacao-apos-bx, prepara-retorno-cooperativa 
                            e grava-retorno. (Jaison/Andrino)

               15/02/2016 - Inclusao do parametro conta na chamada da
                            carrega_dados_tarifa_cobranca. (Jaison/Marcos)

			   26/02/2016 - Ajuste para utilizar sequence ao alimentar o campo
                            nrremret na criacao do registro craprtc
                            (Adriano - SD 391157)
..............................................................................*/

{ includes/var_cobregis.i } /* Include de Def. Cobranca Registrada */
{ sistema/generico/includes/b1wgen0030tt.i }
{ sistema/generico/includes/var_internet.i } /* tt-erro */

{ sistema/generico/includes/var_oracle.i }


DEF   VAR aux_cdoperad AS CHAR                                      NO-UNDO.
DEF   VAR h-b1wgen0087 AS HANDLE                                    NO-UNDO.
DEF   VAR h-b1wgen0088 AS HANDLE                                    NO-UNDO.
DEF   VAR h-b1wgen0090 AS HANDLE                                    NO-UNDO.
DEF   VAR aux_nrremret AS INT                                       NO-UNDO.
DEF   VAR aux_nrseqreg AS INT                                       NO-UNDO.

DEF BUFFER bcrapcob FOR crapcob.

DEF TEMP-TABLE tt-descontar LIKE tt-titulos.


/*............................................................................*/

PROCEDURE cria-log-cobranca:
    
    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_dsmensag AS CHAR                            NO-UNDO.


    FIND FIRST bcrapcob WHERE ROWID(bcrapcob) = par_idtabcob
         NO-LOCK NO-ERROR.

    CREATE crapcol.
    ASSIGN crapcol.cdcooper = bcrapcob.cdcooper
           crapcol.nrdconta = bcrapcob.nrdconta
           crapcol.nrdocmto = bcrapcob.nrdocmto
           crapcol.nrcnvcob = bcrapcob.nrcnvcob
           crapcol.dslogtit = par_dsmensag
           crapcol.cdoperad = par_cdoperad
           crapcol.dtaltera = TODAY
           crapcol.hrtransa = TIME.
    VALIDATE crapcol.


END PROCEDURE.

/*............................................................................*/

PROCEDURE prep-tt-lcm-mot-consolidada:

    DEF  INPUT PARAM par_idtabcob AS ROWID                     NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS INT                       NO-UNDO.
    DEF  INPUT PARAM par_dsmotivo AS CHAR                      NO-UNDO.
    DEF  INPUT PARAM par_tplancto AS CHAR                      NO-UNDO.
    DEF  INPUT PARAM par_vltarifa AS DECI                      NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INT                       NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                       NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lcm-consolidada.

    DEF          VAR aux_vltarifa AS DECI                      NO-UNDO.
    DEF          VAR aux_cdhistor AS INT                       NO-UNDO.

    DEF          VAR tar_cdhistor AS INTE                      NO-UNDO.
    DEF          VAR tar_cdhisest AS INTE                      NO-UNDO.
    DEF          VAR tar_vltarifa AS DECI                      NO-UNDO.
    DEF          VAR tar_dtdivulg AS DATE                      NO-UNDO.
    DEF          VAR tar_dtvigenc AS DATE                      NO-UNDO.
    DEF          VAR tar_cdfvlcop AS INTE                      NO-UNDO.

    IF  par_tplancto = "T" THEN 
        DO: 
            RUN busca-dados-tarifa(INPUT  bcrapcob.cdcooper,    /* cdcooper */
                                   INPUT  bcrapcob.nrdconta,    /* nrdconta */ 
                                   INPUT  bcrapcob.nrcnvcob,    /* nrconven */ 
                                   INPUT  "RET",                /* dsincide */
                                   INPUT  par_cdocorre,         /* cdocorre */
                                   INPUT  par_dsmotivo,         /* cdmotivo */
                                   INPUT  ROWID(bcrapcob),
                                   INPUT  1,                    /* flaputar - Sim */
                                   OUTPUT tar_cdhistor,         /* cdhistor */
                                   OUTPUT tar_cdhisest,         /* cdhisest */
                                   OUTPUT tar_vltarifa,         /* vltarifa */
                                   OUTPUT tar_dtdivulg,         /* dtdivulg */
                                   OUTPUT tar_dtvigenc,         /* dtvigenc */
                                   OUTPUT tar_cdfvlcop,         /* cdfvlcop */
                                   OUTPUT TABLE tt-erro).
            

            IF  RETURN-VALUE = "OK"   THEN
                ASSIGN aux_vltarifa = tar_vltarifa
                       aux_cdhistor = tar_cdhistor.
            ELSE
                ASSIGN aux_vltarifa = 0
                       aux_cdhistor = 0.

        END. 

    IF  aux_vltarifa > 0 THEN DO:

        FIND FIRST tt-lcm-consolidada 
             WHERE tt-lcm-consolidada.cdcooper = bcrapcob.cdcooper
               AND tt-lcm-consolidada.nrdconta = bcrapcob.nrdconta
               AND tt-lcm-consolidada.nrconven = bcrapcob.nrcnvcob
               AND tt-lcm-consolidada.cdocorre = par_cdocorre
               AND tt-lcm-consolidada.cdhistor = aux_cdhistor
            EXCLUSIVE-LOCK NO-ERROR.

        IF  NOT AVAIL tt-lcm-consolidada THEN DO:

            CREATE tt-lcm-consolidada.
            ASSIGN tt-lcm-consolidada.cdcooper = bcrapcob.cdcooper
                   tt-lcm-consolidada.nrdconta = bcrapcob.nrdconta
                   tt-lcm-consolidada.nrconven = bcrapcob.nrcnvcob
                   tt-lcm-consolidada.cdocorre = par_cdocorre
                   tt-lcm-consolidada.cdhistor = aux_cdhistor
                   tt-lcm-consolidada.vllancto = aux_vltarifa
                   tt-lcm-consolidada.tplancto = par_tplancto
                   tt-lcm-consolidada.qtdregis = 1
                   tt-lcm-consolidada.cdfvlcop = tar_cdfvlcop.
        END.
        ELSE
            ASSIGN tt-lcm-consolidada.vllancto = tt-lcm-consolidada.vllancto +
                                                 aux_vltarifa
                   tt-lcm-consolidada.qtdregis = tt-lcm-consolidada.qtdregis +
                                                 1.

    END.


END PROCEDURE. /*FIM prep-tt-lcm-mot-consolidada */

PROCEDURE prep-tt-lcm-consolidada:

    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_tplancto AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_vltarifa AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS INT                             NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                             NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lcm-consolidada.

    DEF          VAR aux_vltarifa AS DECI                            NO-UNDO.
    DEF          VAR aux_cdhistor AS INT                             NO-UNDO.

    DEF          VAR tar_cdhistor AS INTE                            NO-UNDO.
    DEF          VAR tar_cdhisest AS INTE                            NO-UNDO.
    DEF          VAR tar_vltarifa AS DECI                            NO-UNDO.
    DEF          VAR tar_dtdivulg AS DATE                            NO-UNDO.
    DEF          VAR tar_dtvigenc AS DATE                            NO-UNDO.
    DEF          VAR tar_cdfvlcop AS INTE                            NO-UNDO.
    

    FIND FIRST bcrapcob WHERE ROWID(bcrapcob) = par_idtabcob
         NO-LOCK NO-ERROR.


    IF  par_tplancto = "T" THEN DO: 

        RUN busca-dados-tarifa(INPUT  bcrapcob.cdcooper,    /* cdcooper */
                               INPUT  bcrapcob.nrdconta,    /* nrdconta */ 
                               INPUT  bcrapcob.nrcnvcob,    /* nrconven */ 
                               INPUT  "RET",                /* dsincide */
                               INPUT  par_cdocorre,         /* cdocorre */
                               INPUT  0,                    /* cdmotivo */
                               INPUT  ROWID(bcrapcob),
                               INPUT  1,                    /* flaputar - Sim */
                               OUTPUT tar_cdhistor,         /* cdhistor */
                               OUTPUT tar_cdhisest,         /* cdhisest */
                               OUTPUT tar_vltarifa,         /* vltarifa */
                               OUTPUT tar_dtdivulg,         /* dtdivulg */
                               OUTPUT tar_dtvigenc,         /* dtvigenc */
                               OUTPUT tar_cdfvlcop,         /* cdfvlcop */
                               OUTPUT TABLE tt-erro).

        IF  RETURN-VALUE = "OK"   THEN
            ASSIGN aux_vltarifa = tar_vltarifa
                   aux_cdhistor = tar_cdhistor.
        ELSE
            ASSIGN aux_vltarifa = 0
                   aux_cdhistor = 0.

    END.
    ELSE
    IF  par_tplancto = "L" THEN DO:
        FIND FIRST crapcco WHERE crapcco.cdcooper = bcrapcob.cdcooper 
                             AND crapcco.nrconven = bcrapcob.nrcnvcob 
            NO-LOCK NO-ERROR.
    
        IF  NOT AVAIL crapcco THEN
            ASSIGN aux_vltarifa = 0
                   aux_cdhistor = 0.
        ELSE
            ASSIGN aux_vltarifa = par_vltarifa 
                   aux_cdhistor = IF par_cdhistor = 0 THEN
                                      crapcco.cdhistor
                                  ELSE
                                      par_cdhistor.
    END.
    ELSE  /* "C" - Tarifas Cartorarias */
        ASSIGN aux_vltarifa = par_vltarifa 
               aux_cdhistor = par_cdhistor.


    IF  aux_vltarifa > 0 THEN DO:

        FIND FIRST tt-lcm-consolidada 
             WHERE tt-lcm-consolidada.cdcooper = bcrapcob.cdcooper
               AND tt-lcm-consolidada.nrdconta = bcrapcob.nrdconta
               AND tt-lcm-consolidada.nrconven = bcrapcob.nrcnvcob
               AND tt-lcm-consolidada.cdocorre = par_cdocorre
               AND tt-lcm-consolidada.cdhistor = aux_cdhistor
            EXCLUSIVE-LOCK NO-ERROR.
    
        IF  NOT AVAIL tt-lcm-consolidada THEN DO:
    
            CREATE tt-lcm-consolidada.
            ASSIGN tt-lcm-consolidada.cdcooper = bcrapcob.cdcooper
                   tt-lcm-consolidada.nrdconta = bcrapcob.nrdconta
                   tt-lcm-consolidada.nrconven = bcrapcob.nrcnvcob
                   tt-lcm-consolidada.cdocorre = par_cdocorre
                   tt-lcm-consolidada.cdhistor = aux_cdhistor
                   tt-lcm-consolidada.vllancto = aux_vltarifa
                   tt-lcm-consolidada.tplancto = par_tplancto
                   tt-lcm-consolidada.qtdregis = 1
                   tt-lcm-consolidada.cdfvlcop = tar_cdfvlcop.
        END.
        ELSE
            ASSIGN tt-lcm-consolidada.vllancto = tt-lcm-consolidada.vllancto +
                                                 aux_vltarifa
                   tt-lcm-consolidada.qtdregis = tt-lcm-consolidada.qtdregis +
                                                 1.

    END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE prep-retorno-cooperado:

    DEF  INPUT PARAM par_idregcob AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dsmotivo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM ret_nrremret AS INT                            NO-UNDO.

    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarqcre AS CHAR                                    NO-UNDO.

    DEF VAR aux_nrremrtc AS INT                                     NO-UNDO.
    DEF VAR aux_nrremcre AS INT                                     NO-UNDO.
    DEF VAR aux_nrseqreg AS INT                                     NO-UNDO.
    DEF VAR aux_vltarifa AS DECI                                    NO-UNDO.

    DEF BUFFER bcrapcco FOR crapcco.


    FIND FIRST bcrapcob WHERE ROWID(bcrapcob) = par_idregcob
         NO-LOCK NO-ERROR.


  
    ASSIGN aux_nmarquiv = "cobret" + STRING(MONTH(par_dtmvtolt),"99") + 
                                     STRING(DAY(par_dtmvtolt),"99").


    /*** Localiza o ultimo RTC desta data ***/
    FIND LAST craprtc WHERE craprtc.cdcooper = bcrapcob.cdcooper
                        AND craprtc.nrcnvcob = bcrapcob.nrcnvcob
                        AND craprtc.nrdconta = bcrapcob.nrdconta
                        AND craprtc.dtmvtolt = par_dtmvtolt
                        AND craprtc.intipmvt = 2 /* (2=retorno) */
        NO-LOCK NO-ERROR.

    IF NOT AVAIL craprtc THEN DO:
        
        { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

        /* Busca a proxima sequencia do campo crapldt.nrsequen */
        RUN STORED-PROCEDURE pc_sequence_progress
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPRTC"
                                            ,INPUT "NRREMRET"
                                            ,INPUT STRING(bcrapcob.cdcooper) + ";" +
                                                   STRING(bcrapcob.nrdconta) + ";" +
                                                   STRING(bcrapcob.nrcnvcob) + ";2"                                                   
                                            ,INPUT "N"
                                            ,"").

        CLOSE STORED-PROC pc_sequence_progress
              aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.

        { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} }

        ASSIGN aux_nrremrtc = INTE(pc_sequence_progress.pr_sequence)
                              WHEN pc_sequence_progress.pr_sequence <> ?.

        CREATE craprtc.
        ASSIGN craprtc.cdcooper = bcrapcob.cdcooper
               craprtc.nrdconta = bcrapcob.nrdconta
               craprtc.nrcnvcob = bcrapcob.nrcnvcob               
               craprtc.dtmvtolt = par_dtmvtolt
               craprtc.nrremret = aux_nrremrtc
               craprtc.nmarquiv = aux_nmarquiv
               craprtc.flgproce = NO
               craprtc.dtdenvio = ?
               craprtc.qtreglot = 1
               craprtc.cdoperad = par_cdoperad
               craprtc.dtaltera = par_dtmvtolt
               craprtc.hrtransa = TIME
               craprtc.intipmvt = 2.
        VALIDATE craprtc.
    END.

    ASSIGN ret_nrremret = craprtc.nrremret.


END PROCEDURE.

/*............................................................................*/

PROCEDURE proc-motivos-retorno:

    DEF  INPUT PARAM par_idtabcob AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dsmotivo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                            NO-UNDO.

    DEF          VAR aux_contador AS INT                            NO-UNDO.
    DEF          VAR aux_cdposini AS INT   INIT 1                   NO-UNDO.
    DEF          VAR aux_cdmotivo AS CHAR                           NO-UNDO.
    DEF          VAR aux_dsmotivo AS CHAR                           NO-UNDO.
    DEF          VAR aux_cdnrmoti AS INT   INIT 0                   NO-UNDO.

   

    FIND FIRST bcrapcob WHERE ROWID(bcrapcob) = par_idtabcob
         NO-LOCK NO-ERROR.


    /* buscar ocorrencia */
    FIND FIRST crapoco WHERE crapoco.cdcooper = bcrapcob.cdcooper 
                         AND crapoco.cddbanco = bcrapcob.cdbandoc
                         AND crapoco.cdocorre = par_cdocorre
                         AND crapoco.tpocorre = 2 /* Retorno */
        NO-LOCK NO-ERROR.

    IF  AVAIL crapoco THEN DO:
        
        DO  aux_contador = 1 TO 5:
    
            ASSIGN aux_cdmotivo = TRIM(SUBSTR(par_dsmotivo,aux_cdposini, 2))
                   aux_cdposini = aux_cdposini + 2
                   aux_dsmotivo = "".

            IF aux_cdmotivo = "" THEN NEXT.
    
            ASSIGN aux_cdnrmoti = aux_cdnrmoti + 1.

            /* nao logar no titulo, entrada rejeitada e motivos 38,39,00,60 */
            IF par_cdocorre = 3 AND
               CAN-DO("38,39,00,60", TRIM(aux_cdmotivo)) THEN NEXT.
    
            /* buscar os motivos da ocorrencia */
            FIND FIRST crapmot WHERE crapmot.cdcooper = bcrapcob.cdcooper
                                 AND crapmot.cddbanco = bcrapcob.cdbandoc
                                 AND crapmot.cdocorre = par_cdocorre
                                 AND crapmot.tpocorre = 2 /* Mot. do retorno */
                                 AND crapmot.cdmotivo = aux_cdmotivo
                NO-LOCK NO-ERROR.
    
            IF  AVAIL crapmot THEN DO:
                aux_dsmotivo = (IF par_cdocorre <> 28 THEN crapoco.dsocorre ELSE "") +
                               IF crapmot.dsmotivo <> "" THEN
                                   (IF par_cdocorre = 28 THEN 
                                       crapmot.dsmotivo
                                    ELSE 
                                       " - " + crapmot.dsmotivo)
                               ELSE
                                   "".
            END.
            ELSE DO:
                IF par_cdocorre <> 3 THEN
                   ASSIGN aux_dsmotivo = crapoco.dsocorre.
                ELSE
                   NEXT.
            END.

            
            RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT aux_dsmotivo ).
    
        END. /* END do DO 1 TO 5 */

        IF  aux_cdnrmoti = 0 THEN
            aux_dsmotivo = crapoco.dsocorre.

    END.

    IF  aux_cdnrmoti = 0 AND aux_dsmotivo <> "" THEN DO:

        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT aux_dsmotivo ).

    END.
    

    IF ret_cdcritic <> 0 THEN RETURN "NOK".

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/


PROCEDURE ent-confirmada:
    /** Retorno = 02 - Entrada Confirmada **/
    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.
    DEF  INPUT PARAM par_nrnosnum AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_cdbcocob AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_cdagecob AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dsmotivo AS CHAR                            NO-UNDO.

    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM ret_nrremret AS INT                             NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                             NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lcm-consolidada.
    
    DEF BUFFER b-crapcob FOR crapcob.

    ASSIGN ret_cdcritic = 0.

    FIND FIRST crapcob WHERE ROWID(crapcob) = par_idtabcob
         EXCLUSIVE-LOCK NO-ERROR.


    /** Atualiza crapcob */
    ASSIGN crapcob.nrnosnum = par_nrnosnum
           crapcob.cdbanpag = par_cdbcocob
           crapcob.cdagepag = par_cdagecob.


    /* Gerar motivos de ocorrencia  */  
    RUN proc-motivos-retorno (INPUT ROWID(crapcob),
                              INPUT par_cdocorre,
                              INPUT par_dsmotivo,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                             OUTPUT ret_cdcritic).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".

    /* se titulo baixado ou pago, entao solicitar baixa */
    IF  crapcob.incobran = 3 OR
        crapcob.incobran = 5 THEN
        DO:

            FIND crapdat WHERE crapdat.cdcooper = crapcob.cdcooper 
                 NO-LOCK NO-ERROR.

            RUN sistema/generico/procedures/b1wgen0088.p 
                PERSISTENT SET h-b1wgen0088.
    
            IF NOT VALID-HANDLE(h-b1wgen0088) THEN RETURN "NOK".

            /* prepara remessa para o banco */
            RUN prep-remessa-banco IN h-b1wgen0088
                ( INPUT crapcob.cdcooper,
                  INPUT crapcob.nrcnvcob,
                  INPUT crapdat.dtmvtopr,
                  INPUT par_cdoperad,
                  OUTPUT aux_nrremret,
                  OUTPUT aux_nrseqreg).
    
            ASSIGN aux_nrseqreg = aux_nrseqreg + 1.
    
            /* cria registro de pedido de baixa ao banco */
            RUN cria-tab-remessa IN h-b1wgen0088
                ( INPUT ROWID(crapcob),
                  INPUT aux_nrremret,
                  INPUT aux_nrseqreg,
                  INPUT 2, /* baixar */ 
                  INPUT "", 
                  INPUT ?,
                  INPUT 0,
                  INPUT par_cdoperad,
                  INPUT par_dtmvtolt).
    
            IF  VALID-HANDLE(h-b1wgen0088) THEN
                DELETE PROCEDURE h-b1wgen0088.
    
            RUN cria-log-cobranca (INPUT ROWID(crapcob),
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT "Ent confirmada indevida. " + 
                                         " Bx solicitada" ).

            /* ent confirmada indevida */
            ASSIGN ret_cdcritic = 955.

            RETURN "NOK".
        END.
    
    /* Gerar dados para tt-lcm-consolidada */
    RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                 INPUT par_cdocorre, /* 2.Entr. Confirm.*/
                                 INPUT "T", /* tplancto = "T" Tarifa */
                                 INPUT 0,   /* vlTarifa */
                                 INPUT 0,   /* cdHistor */
                                OUTPUT ret_cdcritic,
                                 INPUT-OUTPUT TABLE tt-lcm-consolidada).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".


    /* Preparar Lote de Retorno Cooperado */
    RUN prep-retorno-cooperado( INPUT ROWID(crapcob),
                                INPUT par_cdocorre,
                                INPUT "",
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad,
                               OUTPUT ret_nrremret).

    /* Verificar se bolteto de cobranca original 
         ja esta liquidado */
    FIND FIRST b-crapcob 
         WHERE b-crapcob.cdcooper = INT(ENTRY(1,crapcob.cdtitprt,";"))
           AND b-crapcob.nrcnvcob = INT(ENTRY(3,crapcob.cdtitprt,";"))
           AND b-crapcob.nrdconta = INT(ENTRY(2,crapcob.cdtitprt,";"))
           AND b-crapcob.nrdocmto = INT(ENTRY(4,crapcob.cdtitprt,";"))
           AND b-crapcob.cdbandoc = 85
           AND b-crapcob.incobran = 5
           NO-LOCK NO-ERROR.
    
    
    FIND FIRST crapcco WHERE crapcco.cdcooper = crapcob.cdcooper
                         AND crapcco.nrconven = crapcob.nrcnvcob
                         AND crapcco.dsorgarq = "PROTESTO"
                         AND crapcco.cddbanco = 001
                         AND crapcco.flgregis = TRUE
                         NO-LOCK NO-ERROR.

    /* se convenio do BB for "PROTESTO", entao gerar 
       inst automatica de protesto */
    IF AVAIL crapcco AND 
       /* somente gerar protesto se ainda nao foi liquidado */
       NOT AVAIL b-crapcob THEN
    DO:
        RUN sistema/generico/procedures/b1wgen0088.p PERSISTENT SET h-b1wgen0088.

        IF NOT VALID-HANDLE(h-b1wgen0088) THEN RETURN "NOK".

        FIND crapdat WHERE crapdat.cdcooper = crapcob.cdcooper NO-LOCK NO-ERROR.

        /* verificar movimento de remessa do dia */
        FIND LAST crapcre WHERE crapcre.cdcooper = crapcob.cdcooper
                            AND crapcre.nrcnvcob = crapcob.nrcnvcob
                            AND crapcre.intipmvt = 1
                            AND crapcre.flgproce = FALSE
                            NO-LOCK NO-ERROR.

        IF AVAIL crapcre THEN
        DO: 
           /* verificar se existe alguma instrucao de baixa */
           FIND LAST craprem WHERE craprem.cdcooper = crapcre.cdcooper
                               AND craprem.nrcnvcob = crapcre.nrcnvcob
                               AND craprem.nrremret = crapcre.nrremret
                               AND craprem.nrdconta = crapcob.nrdconta
                               AND craprem.nrdocmto = crapcob.nrdocmto
                               AND craprem.cdocorre = 2
                               NO-LOCK NO-ERROR.
        END.

        /* se nao houver instrucao de baixa, entao comandar protesto */
        IF NOT AVAIL craprem THEN
        DO:
            /* prepara remessa para o banco */
            RUN prep-remessa-banco IN h-b1wgen0088
                ( INPUT crapcob.cdcooper,
                  INPUT crapcob.nrcnvcob,
                  INPUT crapdat.dtmvtopr,
                  INPUT par_cdoperad,
                  OUTPUT aux_nrremret,
                  OUTPUT aux_nrseqreg).
    
            ASSIGN aux_nrseqreg = aux_nrseqreg + 1.
    
            /* cria registro de pedido de baixa ao banco */
            RUN cria-tab-remessa IN h-b1wgen0088
                ( INPUT ROWID(crapcob),
                  INPUT aux_nrremret,
                  INPUT aux_nrseqreg,
                  INPUT 9, /* protestar */ 
                  INPUT "", 
                  INPUT ?,
                  INPUT 0,
                  INPUT par_cdoperad,
                  INPUT par_dtmvtolt).
    
            DELETE PROCEDURE h-b1wgen0088.
    
            RUN cria-log-cobranca (INPUT ROWID(crapcob),
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT "Inst Autom de Protesto" ).
        END. /* IF NOT AVAIL craprem */
    END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE ent-rejeitada:
    /** Retorno = 03 - Entrada Rejeitada **/
    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.

    DEF  INPUT PARAM par_cdocorre AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dsmotivo AS CHAR                            NO-UNDO.

    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM ret_nrremret AS INT                             NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                             NO-UNDO.

    DEF          VAR aux_rejeitar AS LOGICAL  INIT FALSE             NO-UNDO.
    DEF          VAR aux_contador AS INT                             NO-UNDO.
    DEF          VAR aux_cdposini AS INT      INIT 1                 NO-UNDO.
    DEF          VAR aux_cdmotivo AS CHAR                            NO-UNDO.

    /* nao gravar log no título para os motivos abaixo */
    IF CAN-DO("39,00,60", TRIM(par_dsmotivo)) OR
       TRIM(par_dsmotivo) = "" THEN
    DO: 
        /* 39 = pedido de protesto nao permitido p/ o titulo
         * 60 = Movto para titulo nao cadastrado
         * 00 = nao cadastrado
         * "" = sem motivo */
        RETURN "OK".
    END.

    FIND FIRST crapcob WHERE ROWID(crapcob) = par_idtabcob
         EXCLUSIVE-LOCK NO-ERROR.

    /*  Rejeitar título quando motivo for
        '48' = CEP Inválido    
        '52' = Unidade da Federação Inválida
        '16' = Data de Vencimento Inválida 
        '17' = Data de Vencimento Anterior a  Data de Emissão
        '24' = Data da Emissão Inválida 
        '25' = Data da Emissão Posterior a Data de Entrada 
        '51' = CEP incompatível com a Unidade da Federação 
    */

    DO  aux_contador = 1 TO 5:

        ASSIGN aux_cdmotivo = TRIM(SUBSTR(par_dsmotivo,aux_cdposini, 2))
               aux_cdposini = aux_cdposini + 2.

        IF aux_cdmotivo = "" THEN NEXT.

        IF CAN-DO("48,52,16,17,24,25,51", aux_cdmotivo) THEN
           ASSIGN aux_rejeitar = TRUE.

    END.
     
    IF aux_rejeitar THEN
       ASSIGN crapcob.incobran = 4. /* rejeitado */

    /* Gerar motivos de ocorrencia  */  
    RUN proc-motivos-retorno (INPUT ROWID(crapcob),
                              INPUT par_cdocorre,
                              INPUT par_dsmotivo,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                             OUTPUT ret_cdcritic).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".


    /* Preparar Lote de Retorno Cooperado */
    RUN prep-retorno-cooperado( INPUT ROWID(crapcob),
                                INPUT par_cdocorre,
                                INPUT "",
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad,
                               OUTPUT ret_nrremret).
    
    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE proc-liquidacao:
    /** Retorno = 06 - Liquidacao **/
    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.
    /** Parametros de Dados dos Arquivos **/
    DEF  INPUT PARAM par_nrnosnum AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_cdbanpag AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_cdagepag AS INT                             NO-UNDO.

    DEF  INPUT PARAM par_vltitulo AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vlliquid AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vlrpagto AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vlabatim AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vldescto AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vlrjuros AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vloutdeb AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vloutcre AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_dtocorre AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_dtcredit AS DATE                            NO-UNDO.
    
    DEF  INPUT PARAM par_cdocorre AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dsmotivo AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_indpagto AS INTE                            NO-UNDO.
    /* 0-COMPE 1-Caixa On-Line 3-Internet 4-TAA */
    DEF  INPUT PARAM par_inestcri AS INTE                            NO-UNDO.

    DEF OUTPUT PARAM ret_nrremret AS INT                             NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                             NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lcm-consolidada.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-descontar.
    
    DEFINE VARIABLE aux_cdhistor  AS INTEGER                         NO-UNDO.
    DEFINE VARIABLE ret_dsinserr  AS CHAR                            NO-UNDO.
    DEFINE VARIABLE flg_feriafds  AS LOGICAL                         NO-UNDO.
    DEFINE VARIABLE aux_flgdesct  AS LOGICAL INIT FALSE              NO-UNDO.
    DEFINE VARIABLE aux_dtprvenc  AS DATE                            NO-UNDO.

    FIND FIRST crapcob WHERE ROWID(crapcob) = par_idtabcob
         EXCLUSIVE-LOCK NO-ERROR.

    FIND crapcop WHERE crapcop.cdcooper = crapcob.cdcooper 
                       NO-LOCK NO-ERROR.

    /* Gerar motivos de ocorrencia  */  
    RUN proc-motivos-retorno (INPUT ROWID(crapcob),
                              INPUT par_cdocorre,
                              INPUT par_dsmotivo,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                             OUTPUT ret_cdcritic).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".

    /* Gerar dados para tt-lcm-consolidada */
    RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                 INPUT par_cdocorre, /* 6.Liquidacao */
                                 INPUT "T", /* tplancto = "T" Tarifa */
                                 INPUT 0,   /* vlTarifa */
                                 INPUT 0,   /* cdHistor */
                                OUTPUT ret_cdcritic,
                                 INPUT-OUTPUT TABLE tt-lcm-consolidada).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".


    IF par_indpagto = 0 THEN
        aux_cdhistor = 0.
    ELSE
        aux_cdhistor = 987.

    /* buscar titulo descontado - EM ESTUDO */
    FIND LAST craptdb WHERE craptdb.cdcooper = crapcob.cdcooper   AND
                       craptdb.nrdconta = crapcob.nrdconta   AND
                       craptdb.cdbandoc = crapcob.cdbandoc   AND
                       craptdb.nrdctabb = crapcob.nrdctabb   AND
                       craptdb.nrcnvcob = crapcob.nrcnvcob   AND
                       craptdb.nrdocmto = crapcob.nrdocmto   AND
                       craptdb.insittit = 0
                       EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

    IF  AVAIL craptdb THEN
        DO:
            /* Quando é eliminado o registro da craptdb, é necessario eliminar registros filhos
               nas tabelas crapljt e crapabt*/
            /* Excluir registro crapljt*/
            FOR EACH crapljt
            WHERE crapljt.cdcooper = craptdb.cdcooper
              AND crapljt.cdbandoc = craptdb.cdbandoc
              AND crapljt.nrdctabb = craptdb.nrdctabb
              AND crapljt.nrcnvcob = craptdb.nrcnvcob
              AND crapljt.nrdconta = craptdb.nrdconta
              AND crapljt.nrdocmto = craptdb.nrdocmto
              AND crapljt.NRBORDER = craptdb.nrborder
              EXCLUSIVE-LOCK:

              DELETE crapljt.
              RELEASE crapljt.
            END.
        
            /*Excluir registro crapabt */
            FOR EACH crapabt
               WHERE crapabt.cdcooper = craptdb.cdcooper
                 AND crapabt.cdbandoc = craptdb.cdbandoc
                 AND crapabt.nrdctabb = craptdb.nrdctabb
                 AND crapabt.nrcnvcob = craptdb.nrcnvcob
                 AND crapabt.nrdconta = craptdb.nrdconta
                 AND crapabt.nrdocmto = craptdb.nrdocmto
                 AND crapabt.NRBORDER = craptdb.nrborder
                 EXCLUSIVE-LOCK:

              DELETE crapabt.
              RELEASE crapabt.
            END.

            DELETE craptdb.
            RELEASE craptdb.
        
        END.  

    /* buscar titulo descontado */
    FIND LAST craptdb WHERE craptdb.cdcooper = crapcob.cdcooper   AND
                       craptdb.nrdconta = crapcob.nrdconta   AND
                       craptdb.cdbandoc = crapcob.cdbandoc   AND
                       craptdb.nrdctabb = crapcob.nrdctabb   AND
                       craptdb.nrcnvcob = crapcob.nrcnvcob   AND
                       craptdb.nrdocmto = crapcob.nrdocmto   AND
                       craptdb.insittit = 4
                       NO-LOCK NO-ERROR.

    IF   AVAILABLE craptdb  THEN 
         DO:
            IF  CAN-DO("1,7",STRING(WEEKDAY(craptdb.dtvencto)))   OR
                CAN-FIND(crapfer WHERE crapfer.cdcooper = craptdb.cdcooper AND
                                       crapfer.dtferiad = craptdb.dtvencto) THEN
                flg_feriafds = TRUE.
            ELSE
                flg_feriafds = FALSE.
  
            /* POSTERGACAO DA DATA */
            IF  craptdb.dtvencto < par_dtmvtolt AND                
                NOT flg_feriafds THEN 
                    aux_flgdesct = FALSE.
                ELSE
                    aux_flgdesct = TRUE.

            IF  aux_flgdesct THEN
                DO:
                    /* 1o Dia util apos o vencto */
                    aux_dtprvenc = craptdb.dtvencto + 1.
                    DO  WHILE TRUE:
    
                        IF   WEEKDAY(aux_dtprvenc) = 1   OR
                             WEEKDAY(aux_dtprvenc) = 7   THEN
                             DO:
                                aux_dtprvenc = aux_dtprvenc + 1.
                                NEXT.
                             END.
    
                        FIND crapfer WHERE 
                             crapfer.cdcooper = craptdb.cdcooper   AND
                             crapfer.dtferiad = aux_dtprvenc
                             NO-LOCK NO-ERROR.
    
                        IF   AVAILABLE crapfer   THEN
                             DO:
                                aux_dtprvenc = aux_dtprvenc + 1.
                                NEXT.
                             END.
    
                        LEAVE.
                    END.  /*  Fim do DO WHILE TRUE  */
    
                    /*
                        Fazer a baixa de desconto de titulo somente se for
                        no 1o. dia util apos o vencimento
                        caso contrario da NEXT.
                    */
                    IF  flg_feriafds AND    /* venceu em feriado/fds */
                        craptdb.dtvencto <= par_dtmvtolt AND 
                        par_dtmvtolt <> aux_dtprvenc  THEN
                        ASSIGN aux_flgdesct = FALSE.
                END.                

             IF  aux_flgdesct THEN
                 DO:
                     /* Grava titulos com desconto para efetuar baixa no
                        final do processo */
                     CREATE tt-descontar.
                     BUFFER-COPY craptdb EXCEPT vltitulo TO tt-descontar
                     ASSIGN tt-descontar.flgregis = crapcob.flgregis
                            tt-descontar.vltitulo = par_vlrpagto.
    
                     RELEASE tt-descontar.
                 END.
         END.
     
    IF  aux_flgdesct = FALSE THEN
        /* Gerar dados para tt-lcm-consolidada */
        RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                     INPUT par_cdocorre, /* 6.Liquidacao */
                                     INPUT "L", /* tplancto = "L" Liquidacao */
                                     INPUT par_vlrpagto,
                                     INPUT aux_cdhistor,   /* cdHistor */
                                    OUTPUT ret_cdcritic,
                                     INPUT-OUTPUT TABLE tt-lcm-consolidada).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".

    /* Alterar situacao do Titulo */
    ASSIGN crapcob.incobran = 5 /* Liquidado/Pago */
           crapcob.dtdpagto = par_dtocorre
           crapcob.vldpagto = par_vlrpagto
           crapcob.cdagepag = par_cdagepag
           crapcob.cdbanpag = par_cdbanpag
           crapcob.indpagto = par_indpagto
           crapcob.vljurpag = par_vlrjuros 
           crapcob.vloutdeb = par_vloutdeb
           crapcob.vloutcre = par_vloutcre.


    /* Preparar Lote de Retorno Cooperado */
    RUN prep-retorno-cooperado( INPUT ROWID(crapcob),
                                INPUT 6,
                                INPUT "",
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad,
                               OUTPUT ret_nrremret).

    IF  crapcob.cdbandoc = crapcop.cdbcoctl  THEN
    DO:        

        RUN prepara-retorno-cooperativa(
                    INPUT ROWID(crapcob),
                    INPUT par_dtmvtolt,
                    INPUT par_dtocorre,
                    INPUT par_cdoperad,
                    INPUT par_vlabatim,
                    INPUT par_vldescto,
                    INPUT par_vlrjuros,
                    INPUT par_vlrpagto,
                    INPUT ret_nrremret,
                    INPUT par_dsmotivo,
                    INPUT par_cdocorre,
                    INPUT par_inestcri).
    END.            

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE proc-baixa:
    /** Retorno = 09 - Baixa **/
    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.

    DEF  INPUT PARAM par_cdbanpag AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_cdagepag AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dtocorre AS DATE                            NO-UNDO.
    
    DEF  INPUT PARAM par_cdocorre AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dsmotivo AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM ret_nrremret AS INT                             NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                             NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lcm-consolidada.

    

    FIND FIRST crapcob WHERE ROWID(crapcob) = par_idtabcob
         EXCLUSIVE-LOCK NO-ERROR.


    /* Gerar motivos de ocorrencia  */  
    RUN proc-motivos-retorno (INPUT ROWID(crapcob),
                              INPUT par_cdocorre,
                              INPUT par_dsmotivo,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                             OUTPUT ret_cdcritic).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".


    ASSIGN crapcob.incobran = 3 /* Baixado */
           crapcob.cdagepag = par_cdagepag
           crapcob.cdbanpag = par_cdbanpag
           crapcob.dtdbaixa = par_dtmvtolt
           crapcob.indpagto = 0. /* compensação - COMPE */

    IF  TRIM(par_dsmotivo) = "14" THEN
        ASSIGN crapcob.insitcrt = 5
               crapcob.dtsitcrt = par_dtmvtolt.

    /* Gerar dados para tt-lcm-consolidada */
    RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                 INPUT par_cdocorre, /* 9.Baixa */
                                 INPUT "T", /* tplancto = "T" Tarifa */
                                 INPUT 0,   /* vlTarifa */
                                 INPUT 0,   /* cdHistor */
                                OUTPUT ret_cdcritic,
                                 INPUT-OUTPUT TABLE tt-lcm-consolidada).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".


    /* Preparar Lote de Retorno Cooperado */
    RUN prep-retorno-cooperado( INPUT ROWID(crapcob),
                                INPUT par_cdocorre,
                                INPUT "",
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad,
                               OUTPUT ret_nrremret).

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE proc-conf-instrucao:
    /** Retorno = 12, 13, 14, 19, 20 **/
    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.

    DEF  INPUT PARAM par_dtocorre AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dsmotivo AS CHAR                            NO-UNDO.

    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM ret_nrremret AS INT                             NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                             NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lcm-consolidada.

    DEF          VAR aux_insitcrt AS INT                             NO-UNDO.
    DEF          VAR aux_nrremret AS INT                             NO-UNDO.
    DEF          VAR aux_nrseqreg AS INT                             NO-UNDO.

    FIND FIRST crapcob WHERE ROWID(crapcob) = par_idtabcob
         EXCLUSIVE-LOCK NO-ERROR.                                            

    /* Gerar motivos de ocorrencia  */  
    /* nao logar no titulo qdo conf de receb de inst de protesto/sustacao */
    IF NOT CAN-DO("19,20", STRING(par_cdocorre)) THEN
        RUN proc-motivos-retorno (INPUT ROWID(crapcob),
                                  INPUT par_cdocorre,
                                  INPUT par_dsmotivo,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdoperad,
                                 OUTPUT ret_cdcritic).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".


    /* Gerar dados para tt-lcm-consolidada */
    RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                 INPUT par_cdocorre, /* 12,13,14,19,20 */
                                 INPUT "T", /* tplancto = "T" Tarifa */
                                 INPUT 0,   /* vlTarifa */
                                 INPUT 0,   /* cdHistor */
                                OUTPUT ret_cdcritic,
                                 INPUT-OUTPUT TABLE tt-lcm-consolidada).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".



    CASE par_cdocorre:

        WHEN 19 THEN DO:
            
            ASSIGN crapcob.insitcrt = 1 /* com instrução de protesto */
                   crapcob.dtsitcrt = par_dtocorre.

            RUN cria-log-cobranca (INPUT ROWID(crapcob),
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT "Aguardando entrada em cartorio pelo BB" ).

        END.

        WHEN 20 THEN DO:
            
            ASSIGN crapcob.insitcrt = 2 /* conf inst sustacao */
                   crapcob.dtsitcrt = par_dtocorre.

            RUN cria-log-cobranca (INPUT ROWID(crapcob),
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT "Aguardando sustacao pelo BB" ).


            /* verificar se foi solicitado inst de baixa */
            FIND LAST craprem WHERE craprem.cdcooper = crapcob.cdcooper
                                AND craprem.nrcnvcob = crapcob.nrcnvcob
                                AND craprem.nrdconta = crapcob.nrdconta
                                AND craprem.nrdocmto = crapcob.nrdocmto
                                AND (craprem.cdocorre = 2 OR
                                     craprem.cdocorre = 10)
                                AND craprem.dtaltera <= par_dtmvtolt
                                NO-LOCK NO-ERROR.

            /* se existir, comandar automaticamente a baixa do banco */
            IF AVAIL craprem THEN DO:

                RUN sistema/generico/procedures/b1wgen0088.p PERSISTENT SET h-b1wgen0088.

                IF NOT VALID-HANDLE(h-b1wgen0088) THEN RETURN "NOK".

                FIND crapdat WHERE crapdat.cdcooper = crapcob.cdcooper NO-LOCK NO-ERROR.

                /* prepara remessa para o banco */
                RUN prep-remessa-banco IN h-b1wgen0088
                    ( INPUT crapcob.cdcooper,
                      INPUT crapcob.nrcnvcob,
                      INPUT crapdat.dtmvtopr,
                      INPUT par_cdoperad,
                      OUTPUT aux_nrremret,
                      OUTPUT aux_nrseqreg).

                ASSIGN aux_nrseqreg = aux_nrseqreg + 1.

                /* cria registro de pedido de baixa ao banco */
                RUN cria-tab-remessa IN h-b1wgen0088
                    ( INPUT ROWID(crapcob),
   /* nrremret */     INPUT aux_nrremret,
   /* nrseqreg */     INPUT aux_nrseqreg,
   /* cdocorre */     INPUT 2, 
   /* cdmotivo */     INPUT "", 
   /* dtdprorr */     INPUT ?,
   /* vlabatim */     INPUT 0,
   /* cdoperad */     INPUT par_cdoperad,
   /* dtmvtolt */     INPUT par_dtmvtolt).

                ASSIGN aux_nrseqreg = aux_nrseqreg + 1.

                /* cria registro de sustacao do banco */
                RUN cria-tab-remessa IN h-b1wgen0088
                    ( INPUT ROWID(crapcob),
   /* nrremret */     INPUT aux_nrremret,
   /* nrseqreg */     INPUT aux_nrseqreg,
   /* cdocorre */     INPUT 11, 
   /* cdmotivo */     INPUT "", 
   /* dtdprorr */     INPUT ?,
   /* vlabatim */     INPUT 0,
   /* cdoperad */     INPUT par_cdoperad,
   /* dtmvtolt */     INPUT par_dtmvtolt).

                DELETE PROCEDURE h-b1wgen0088.

                RUN cria-log-cobranca (INPUT ROWID(crapcob),
                                       INPUT par_cdoperad,
                                       INPUT par_dtmvtolt,
                                       INPUT "Inst Autom de Baixa" ).

            END.


        END.

    END CASE.

    /* Preparar Lote de Retorno Cooperado */
    RUN prep-retorno-cooperado( INPUT ROWID(crapcob),
                                INPUT par_cdocorre,
                                INPUT "",
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad,
                               OUTPUT ret_nrremret).

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE proc-liquidacao-apos-bx:
    /** Retorno = 17 - Liquidacao após baixa **/
    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.
    /** Parametros de Dados dos Arquivos **/
    DEF  INPUT PARAM par_nrnosnum AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_cdbanpag AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_cdagepag AS INT                             NO-UNDO.

    DEF  INPUT PARAM par_vltitulo AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vlliquid AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vlrpagto AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vlabatim AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vldescto AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vlrjuros AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vloutdeb AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vloutcre AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_dtocorre AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_dtcredit AS DATE                            NO-UNDO.
    
    DEF  INPUT PARAM par_cdocorre AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dsmotivo AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_indpagto AS INTE                            NO-UNDO.
    DEF  INPUT PARAM par_inestcri AS INTE                            NO-UNDO.
    DEF OUTPUT PARAM ret_nrremret AS INT                             NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                             NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lcm-consolidada.

    DEFINE VARIABLE aux_cdhistor  AS INTEGER                         NO-UNDO.
    
    FIND FIRST crapcob WHERE ROWID(crapcob) = par_idtabcob
         EXCLUSIVE-LOCK NO-ERROR.

    FIND crapcop WHERE crapcop.cdcooper = crapcob.cdcooper 
                       NO-LOCK NO-ERROR.

    /* Gerar motivos de ocorrencia  */  
    RUN proc-motivos-retorno (INPUT ROWID(crapcob),
                              INPUT par_cdocorre,
                              INPUT par_dsmotivo,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                             OUTPUT ret_cdcritic).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".

    /* Gerar dados para tt-lcm-consolidada */
    RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                 INPUT par_cdocorre, /* 17.Liq. Pos Bx */
                                 INPUT "T", /* tplancto = "T" Tarifa */
                                 INPUT 0,   /* vlTarifa */
                                 INPUT 0,   /* cdHistor */
                                OUTPUT ret_cdcritic,
                                 INPUT-OUTPUT TABLE tt-lcm-consolidada).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".

    /* Alterar situacao do Titulo */
    IF crapcob.incobran <> 5 THEN
       ASSIGN crapcob.incobran = 5 /* Liquidado/Pago */
              crapcob.dtdpagto = par_dtocorre
              crapcob.vldpagto = par_vlrpagto
              crapcob.cdagepag = par_cdagepag
              crapcob.cdbanpag = par_cdbanpag
              crapcob.indpagto = par_indpagto
              crapcob.vljurpag = par_vlrjuros 
              crapcob.vloutdeb = par_vloutdeb
              crapcob.vloutcre = par_vloutcre.

    /* Preparar Lote de Retorno Cooperado */
    RUN prep-retorno-cooperado( INPUT ROWID(crapcob),
                                INPUT par_cdocorre,
                                INPUT "",
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad,
                               OUTPUT ret_nrremret).

    IF crapcob.cdbandoc = 1 /* BB */ THEN
       aux_cdhistor = 1088. /* D-1257 e C-4112 (contab) */

    IF crapcob.cdbandoc = 85 /* CECRED */ THEN
       aux_cdhistor = 1089. /* D-1455 e C-4112 (contab) */

    /* Gerar dados para tt-lcm-consolidada */
    RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                 INPUT par_cdocorre, /* 17.Liq. Pos Bx */
                                 INPUT "L", /* tplancto = "L" Liquidacao */
                                 INPUT par_vlrpagto,
                                 INPUT aux_cdhistor,   /* cdHistor */
                                OUTPUT ret_cdcritic,
                                 INPUT-OUTPUT TABLE tt-lcm-consolidada).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".

    /* Preparar Lote de Retorno Cooperado */
    RUN prep-retorno-cooperado( INPUT ROWID(crapcob),
                                INPUT 17,
                                INPUT "",
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad,
                               OUTPUT ret_nrremret).

    IF  crapcob.cdbandoc = crapcop.cdbcoctl  THEN
    DO:        

        RUN prepara-retorno-cooperativa(
                    INPUT ROWID(crapcob),
                    INPUT par_dtmvtolt,
                    INPUT par_dtocorre,
                    INPUT par_cdoperad,
                    INPUT par_vlabatim,
                    INPUT par_vldescto,
                    INPUT par_vlrjuros,
                    INPUT par_vlrpagto,
                    INPUT ret_nrremret,
                    INPUT par_dsmotivo,
                    INPUT par_cdocorre,
                    INPUT par_inestcri).
    END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE proc-remessa-cartorio:
    /** Retorno = 23 - Remessa a cartório **/
    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.

    DEF  INPUT PARAM par_dtocorre AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_vltarifa AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS DECI                            NO-UNDO.

    DEF  INPUT PARAM par_cdocorre AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dsmotivo AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM ret_nrremret AS INT                             NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                             NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lcm-consolidada.

    DEF          VAR aux_insitcrt AS INT                             NO-UNDO.



    FIND FIRST crapcob WHERE ROWID(crapcob) = par_idtabcob
         EXCLUSIVE-LOCK NO-ERROR.


    /* Gerar motivos de ocorrencia  */  
    RUN proc-motivos-retorno (INPUT ROWID(crapcob),
                              INPUT par_cdocorre,
                              INPUT par_dsmotivo,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                             OUTPUT ret_cdcritic).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".


    /* Nao cobrar tarifa do cooperado (Rafael) */
    /*IF  par_vltarifa > 0 THEN DO:

        /* Gerar dados para tt-lcm-consolidada */
        RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                     INPUT par_cdocorre, /* 23. Remes. Cart. */
                                     INPUT "C", /* tplancto = "C" Cartorio */
                                     INPUT par_vltarifa, /* vlTarifa */
                                     INPUT par_cdhistor, /* cdHistor */
                                    OUTPUT ret_cdcritic,
                                     INPUT-OUTPUT TABLE tt-lcm-consolidada).
    
        IF  ret_cdcritic <> 0 THEN
            RETURN "NOK".

    END.*/

    /* Gerar dados para tt-lcm-consolidada */
    RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                 INPUT par_cdocorre, /* 23. Remes. Cart. */
                                 INPUT "T", /* tplancto = "T" Tarifa */
                                 INPUT 0,  /* vlTarifa */
                                 INPUT 0,  /* cdHistor */
                                OUTPUT ret_cdcritic,
                                 INPUT-OUTPUT TABLE tt-lcm-consolidada).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".


    ASSIGN crapcob.insitcrt = 3 /* com remessa a cartório */
           crapcob.dtsitcrt = par_dtocorre.


    /* Preparar Lote de Retorno Cooperado */
    RUN prep-retorno-cooperado( INPUT ROWID(crapcob),
                                INPUT par_cdocorre,
                                INPUT "",
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad,
                               OUTPUT ret_nrremret).

    /* verificar se foi solicitado inst de baixa */
    FIND LAST craprem WHERE craprem.cdcooper = crapcob.cdcooper
                        AND craprem.nrcnvcob = crapcob.nrcnvcob
                        AND craprem.nrdconta = crapcob.nrdconta
                        AND craprem.nrdocmto = crapcob.nrdocmto
                        AND (craprem.cdocorre = 2 OR
                             craprem.cdocorre = 10)
                        AND craprem.dtaltera <= par_dtmvtolt
                        NO-LOCK NO-ERROR.

    /* se existir, comandar automaticamente a baixa do banco */
    IF AVAIL craprem THEN DO:

        RUN sistema/generico/procedures/b1wgen0088.p PERSISTENT SET h-b1wgen0088.

        IF NOT VALID-HANDLE(h-b1wgen0088) THEN RETURN "NOK".

        FIND crapdat WHERE crapdat.cdcooper = crapcob.cdcooper NO-LOCK NO-ERROR.

        /* prepara remessa para o banco */
        RUN prep-remessa-banco IN h-b1wgen0088
            ( INPUT crapcob.cdcooper,
              INPUT crapcob.nrcnvcob,
              INPUT crapdat.dtmvtopr,
              INPUT par_cdoperad,
              OUTPUT aux_nrremret,
              OUTPUT aux_nrseqreg).

        ASSIGN aux_nrseqreg = aux_nrseqreg + 1.

        /* cria registro de pedido de baixa ao banco */
        RUN cria-tab-remessa IN h-b1wgen0088
            ( INPUT ROWID(crapcob),
              INPUT aux_nrremret,
              INPUT aux_nrseqreg,
              INPUT 2, 
              INPUT "", 
              INPUT ?,
              INPUT 0,
              INPUT par_cdoperad,
              INPUT par_dtmvtolt).

        ASSIGN aux_nrseqreg = aux_nrseqreg + 1.

        /* cria registro de sustacao ao banco */
        RUN cria-tab-remessa IN h-b1wgen0088
            ( INPUT ROWID(crapcob),
              INPUT aux_nrremret,
              INPUT aux_nrseqreg,
              INPUT 11, 
              INPUT "", 
              INPUT ?,
              INPUT 0,
              INPUT par_cdoperad,
              INPUT par_dtmvtolt).

        DELETE PROCEDURE h-b1wgen0088.

        RUN cria-log-cobranca (INPUT ROWID(crapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT "Inst Autom de Baixa" ).

    END.


    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE proc-retirada-cartorio:
    /** Retorno = 24 - Retirada de cartório e manutenção em carteira **/
    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.

    DEF  INPUT PARAM par_dtocorre AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_vltarifa AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS DECI                            NO-UNDO.

    DEF  INPUT PARAM par_cdocorre AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dsmotivo AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.

    DEF OUTPUT PARAM ret_nrremret AS INT                             NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                             NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lcm-consolidada.



    FIND FIRST crapcob WHERE ROWID(crapcob) = par_idtabcob
         EXCLUSIVE-LOCK NO-ERROR.


    /* Gerar motivos de ocorrencia  */  
    RUN proc-motivos-retorno (INPUT ROWID(crapcob),
                              INPUT par_cdocorre,
                              INPUT par_dsmotivo,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                             OUTPUT ret_cdcritic).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".


    /* Gerar dados para tt-lcm-consolidada */
    RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                 INPUT par_cdocorre, /* 24. Retir. Cartor. */
                                 INPUT "T", /* tplancto = "T" Tarifa */
                                 INPUT 0,  /* vlTarifa */
                                 INPUT 0,  /* cdHistor */
                                OUTPUT ret_cdcritic,
                                 INPUT-OUTPUT TABLE tt-lcm-consolidada).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".


    ASSIGN crapcob.insitcrt = 4 /* sustado */
           crapcob.dtsitcrt = par_dtocorre.


    IF  par_vltarifa > 0 THEN DO:
        /* Gerar dados para tt-lcm-consolidada */
        RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                     INPUT par_cdocorre, /* 24. Retir. Cartor. */
                                     INPUT "C", /* tplancto = "C" Cartorio */
                                     INPUT par_vltarifa, /* vlTarifa */
                                     INPUT par_cdhistor,
                                    OUTPUT ret_cdcritic,
                                     INPUT-OUTPUT TABLE tt-lcm-consolidada).
    
        IF  ret_cdcritic <> 0 THEN
            RETURN "NOK".

    END.


    /* Preparar Lote de Retorno Cooperado */
    RUN prep-retorno-cooperado( INPUT ROWID(crapcob),
                                INPUT par_cdocorre,
                                INPUT "",
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad,
                               OUTPUT ret_nrremret).

    /* verificar se foi solicitado inst de baixa */
    FIND LAST craprem WHERE craprem.cdcooper = crapcob.cdcooper
                        AND craprem.nrcnvcob = crapcob.nrcnvcob
                        AND craprem.nrdconta = crapcob.nrdconta
                        AND craprem.nrdocmto = crapcob.nrdocmto
                        AND (craprem.cdocorre = 2 OR
                             craprem.cdocorre = 10)
                        AND craprem.dtaltera <= par_dtmvtolt
                        NO-LOCK NO-ERROR.

    /* se existir, comandar automaticamente a baixa do banco */
    IF AVAIL craprem THEN DO:

        RUN sistema/generico/procedures/b1wgen0088.p PERSISTENT SET h-b1wgen0088.

        IF NOT VALID-HANDLE(h-b1wgen0088) THEN RETURN "NOK".

        FIND crapdat WHERE crapdat.cdcooper = crapcob.cdcooper NO-LOCK NO-ERROR.

        /* prepara remessa para o banco */
        RUN prep-remessa-banco IN h-b1wgen0088
            ( INPUT crapcob.cdcooper,
              INPUT crapcob.nrcnvcob,
              INPUT crapdat.dtmvtopr,
              INPUT par_cdoperad,
              OUTPUT aux_nrremret,
              OUTPUT aux_nrseqreg).

        ASSIGN aux_nrseqreg = aux_nrseqreg + 1.

        /* cria registro de pedido de baixa ao banco */
        RUN cria-tab-remessa IN h-b1wgen0088
            ( INPUT ROWID(crapcob),
              INPUT aux_nrremret,
              INPUT aux_nrseqreg,
              INPUT 2, 
              INPUT "", 
              INPUT ?,
              INPUT 0,
              INPUT par_cdoperad,
              INPUT par_dtmvtolt).

        ASSIGN aux_nrseqreg = aux_nrseqreg + 1.

        /* cria registro de sustacao ao banco */
        RUN cria-tab-remessa IN h-b1wgen0088
            ( INPUT ROWID(crapcob),
              INPUT aux_nrremret,
              INPUT aux_nrseqreg,
              INPUT 11, 
              INPUT "", 
              INPUT ?,
              INPUT 0,
              INPUT par_cdoperad,
              INPUT par_dtmvtolt).

        DELETE PROCEDURE h-b1wgen0088.

        RUN cria-log-cobranca (INPUT ROWID(crapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT "Inst Autom de Baixa" ).
    END.


    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE proc-protestado:
    /** Retorno = 25 - Protestado e Baixado **/
    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.

    DEF  INPUT PARAM par_cdbanpag AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_cdagepag AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_vltarifa AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_cdhistor AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_dtocorre AS DATE                            NO-UNDO.

    DEF  INPUT PARAM par_cdocorre AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dsmotivo AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM ret_nrremret AS INT                             NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                             NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lcm-consolidada.



    FIND FIRST crapcob WHERE ROWID(crapcob) = par_idtabcob
         EXCLUSIVE-LOCK NO-ERROR.


    /* Gerar motivos de ocorrencia  */  
    RUN proc-motivos-retorno (INPUT ROWID(crapcob),
                              INPUT par_cdocorre,
                              INPUT par_dsmotivo,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                             OUTPUT ret_cdcritic).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".


    /* Gerar dados para tt-lcm-consolidada */
    RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                 INPUT par_cdocorre, /* 25. Protesto */
                                 INPUT "T", /* tplancto = "T" Tarifa */
                                 INPUT 0,  /* vlTarifa */
                                 INPUT 0,  /* cdHistor */
                                OUTPUT ret_cdcritic,
                                 INPUT-OUTPUT TABLE tt-lcm-consolidada).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".


    IF  par_vltarifa > 0 THEN DO:
        /* Gerar dados para tt-lcm-consolidada */
        RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                     INPUT par_cdocorre, /* 25. Protesto */
                                     INPUT "C", /* tplancto = "C" Cartorio */
                                     INPUT par_vltarifa, /* vlTarifa */
                                     INPUT par_cdhistor,
                                    OUTPUT ret_cdcritic,
                                     INPUT-OUTPUT TABLE tt-lcm-consolidada).
    
        IF  ret_cdcritic <> 0 THEN
            RETURN "NOK".

    END.

    ASSIGN crapcob.insitcrt = 5  /* protestado */
           crapcob.incobran = 3  /* Baixado */
           crapcob.dtsitcrt = par_dtocorre
           crapcob.dtdbaixa = par_dtocorre
           crapcob.indpagto = 0 /* compensação - COMPE */
           crapcob.cdagepag = par_cdagepag
           crapcob.cdbanpag = par_cdbanpag.



    /* Preparar Lote de Retorno Cooperado */
    RUN prep-retorno-cooperado( INPUT ROWID(crapcob),
                                INPUT par_cdocorre,
                                INPUT "",
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad,
                               OUTPUT ret_nrremret).

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE proc-debito-tarifas-custas:
    /** Retorno = 28 - Debito de tarifas/custas **/
    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.
    
    DEF  INPUT PARAM par_cdbanpag AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_cdagepag AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_vloutcre AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vloutdeb AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vltarifa AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_dtocorre AS DATE                            NO-UNDO.

    DEF  INPUT PARAM par_cdocorre AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dsmotivo AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM ret_nrremret AS INT                             NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                             NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lcm-consolidada.

    DEF          VAR aux_cdhistor AS INT                             NO-UNDO.


    FIND FIRST crapcob WHERE ROWID(crapcob) = par_idtabcob
         EXCLUSIVE-LOCK NO-ERROR.


    /* Gerar motivos de ocorrencia  */  
    RUN proc-motivos-retorno (INPUT ROWID(crapcob),
                              INPUT par_cdocorre,
                              INPUT par_dsmotivo,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                             OUTPUT ret_cdcritic).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".


   
    IF par_vloutcre > 0 THEN
    DO:
        RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                     INPUT par_cdocorre, /* 28. Deb Tarif Cust */
                                     INPUT "L", /* tplancto = "C" Cartorio */
                                     INPUT par_vloutcre, /* vlTarifa */
                                     INPUT 0,
                                    OUTPUT ret_cdcritic,
                                     INPUT-OUTPUT TABLE tt-lcm-consolidada).

        IF  ret_cdcritic <> 0 THEN
            RETURN "NOK".

    END.

    IF  par_vloutdeb > 0 THEN 
    DO:
        IF TRIM(par_dsmotivo) = "02" THEN /* 02 - Manutencao de Titulo Vencido */
             RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                         INPUT par_cdocorre, /* 28. Deb Tarif Cust */
                                         INPUT "T", /* tplancto = "T" Tarifa       */
                                         INPUT par_vloutdeb, /* vlTarifa */
                                         INPUT aux_cdhistor,
                                        OUTPUT ret_cdcritic,
                                         INPUT-OUTPUT TABLE tt-lcm-consolidada).
        ELSE
            /* Gerar dados para tt-lcm-consolidada */
            RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                         INPUT par_cdocorre, /* 28. Deb Tarif Cust */
                                         INPUT "C", /* tplancto = "C" Cartorio */
                                         INPUT par_vloutdeb, /* vlTarifa */
                                         INPUT 972,
                                        OUTPUT ret_cdcritic,
                                         INPUT-OUTPUT TABLE tt-lcm-consolidada).

        /* confirmar sustacao de titulo quando houver
           custas de sustacao enviada pelo BB */
        IF TRIM(par_dsmotivo) = "09" THEN
        DO:
            ASSIGN crapcob.insitcrt = 4 /* sustado */
                   crapcob.dtsitcrt = par_dtocorre.

            RUN cria-log-cobranca (INPUT ROWID(crapcob),
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT "Sustacao confirmada em " + 
                                         STRING(par_dtocorre, "99/99/9999") ).

        END.
    
        IF  ret_cdcritic <> 0 THEN
            RETURN "NOK".

    END.

    IF par_vltarifa > 0 THEN
    DO:
        /*RUN prep-tt-lcm-consolidada( INPUT ROWID(crapcob),
                                     INPUT par_cdocorre, /* 28. Deb Tarif Cust */
                                     INPUT "T", /* tplancto = "C" Cartorio */
                                     INPUT par_vltarifa, /* vlTarifa */
                                     INPUT 0,
                                    OUTPUT ret_cdcritic,
                                     INPUT-OUTPUT TABLE tt-lcm-consolidada).*/

        /* quando cdocorre = 28, cobrar os motivos da ocorrencia */
        RUN prep-tt-lcm-mot-consolidada(INPUT ROWID(crapcob),
                                        INPUT par_cdocorre, /* 28. Deb Tarif Cust */
                                        INPUT par_dsmotivo, 
                                        INPUT "T", /* tplancto = "C" Cartorio */
                                        INPUT par_vltarifa, /* vlTarifa */
                                        INPUT 0,
                                        OUTPUT ret_cdcritic,
                                        INPUT-OUTPUT TABLE tt-lcm-consolidada).
        
        IF  ret_cdcritic <> 0 THEN
            RETURN "NOK".
    END.

    /* Preparar Lote de Retorno Cooperado */
    RUN prep-retorno-cooperado( INPUT ROWID(crapcob),
                                INPUT par_cdocorre,
                                INPUT "",
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad,
                               OUTPUT ret_nrremret).

        /* verificar se foi solicitado inst de baixa */
    FIND LAST craprem WHERE craprem.cdcooper = crapcob.cdcooper
                        AND craprem.nrcnvcob = crapcob.nrcnvcob
                        AND craprem.nrdconta = crapcob.nrdconta
                        AND craprem.nrdocmto = crapcob.nrdocmto
                        AND (craprem.cdocorre = 2 OR
                             craprem.cdocorre = 10)
                        AND craprem.dtaltera <= par_dtmvtolt
                        NO-LOCK NO-ERROR.

    /* se existir, comandar automaticamente a baixa do banco */
    IF AVAIL craprem THEN DO:

        RUN sistema/generico/procedures/b1wgen0088.p PERSISTENT SET h-b1wgen0088.

        IF NOT VALID-HANDLE(h-b1wgen0088) THEN RETURN "NOK".

        FIND crapdat WHERE crapdat.cdcooper = crapcob.cdcooper NO-LOCK NO-ERROR.

        /* prepara remessa para o banco */
        RUN prep-remessa-banco IN h-b1wgen0088
            ( INPUT crapcob.cdcooper,
              INPUT crapcob.nrcnvcob,
              INPUT crapdat.dtmvtopr,
              INPUT par_cdoperad,
              OUTPUT aux_nrremret,
              OUTPUT aux_nrseqreg).

        ASSIGN aux_nrseqreg = aux_nrseqreg + 1.

        /* cria registro de pedido de baixa ao banco */
        RUN cria-tab-remessa IN h-b1wgen0088
            ( INPUT ROWID(crapcob),
              INPUT aux_nrremret,
              INPUT aux_nrseqreg,
              INPUT 2, 
              INPUT "", 
              INPUT ?,
              INPUT 0,
              INPUT par_cdoperad,
              INPUT par_dtmvtolt).

        ASSIGN aux_nrseqreg = aux_nrseqreg + 1.

        /* cria registro de sustacao ao banco */
        RUN cria-tab-remessa IN h-b1wgen0088
            ( INPUT ROWID(crapcob),
              INPUT aux_nrremret,
              INPUT aux_nrseqreg,
              INPUT 11, 
              INPUT "", 
              INPUT ?,
              INPUT 0,
              INPUT par_cdoperad,
              INPUT par_dtmvtolt).

        DELETE PROCEDURE h-b1wgen0088.

        RUN cria-log-cobranca (INPUT ROWID(crapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT "Inst Autom de Baixa" ).

    END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE proc-retorno-qualquer:
    /** Retorno = Retorno Qualquer **/
    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.

    DEF  INPUT PARAM par_dtocorre AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dsmotivo AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM ret_nrremret AS INT                             NO-UNDO.
    DEF OUTPUT PARAM ret_cdcritic AS INT                             NO-UNDO.
    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lcm-consolidada.


    FIND FIRST crapcob WHERE ROWID(crapcob) = par_idtabcob
         EXCLUSIVE-LOCK NO-ERROR.


    /* Gerar motivos de ocorrencia  */  
    RUN proc-motivos-retorno (INPUT ROWID(crapcob),
                              INPUT par_cdocorre,
                              INPUT par_dsmotivo,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                             OUTPUT ret_cdcritic).

    IF  ret_cdcritic <> 0 THEN
        RETURN "NOK".

    /* Preparar Lote de Retorno Cooperado */
    RUN prep-retorno-cooperado( INPUT ROWID(crapcob),
                                INPUT par_cdocorre,
                                INPUT "",
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad,
                               OUTPUT ret_nrremret).

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE grava-retorno:

    DEF  INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_nrnosnum AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dsmotivo AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_nrremret AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrseqreg AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_cdbcorec AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_cdagerec AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_cdbcocor AS INT                             NO-UNDO.

    DEF  INPUT PARAM par_nrretcoo AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dtcredit AS DATE                            NO-UNDO.

    DEF  INPUT PARAM par_vlabatim AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vldescto AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vljurmul AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vloutcre AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vloutdes AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vlrliqui AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vlrpagto AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_vltarifa AS DECI    /* VlTarCus */          NO-UNDO.
    DEF  INPUT PARAM par_vltitulo AS DECI                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_dtocorre AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_inestcri AS INTE                            NO-UNDO.

    DEF          VAR aux_vltarass AS DECI                            NO-UNDO.

    DEF          VAR h-b1wgen0153 AS HANDLE                          NO-UNDO.

    DEF          VAR tar_cdhistor AS INTE                            NO-UNDO.
    DEF          VAR tar_cdhisest AS INTE                            NO-UNDO.
    DEF          VAR tar_vltarifa AS DECI                            NO-UNDO.
    DEF          VAR tar_dtdivulg AS DATE                            NO-UNDO.
    DEF          VAR tar_dtvigenc AS DATE                            NO-UNDO.
    DEF          VAR tar_cdfvlcop AS INTE                            NO-UNDO.
    DEF          VAR aux_inpessoa AS INTE                            NO-UNDO.

    DEF          VAR aux_nrretcoo LIKE crapret.nrretcoo              NO-UNDO.
    DEF          VAR aux_nrremret LIKE crapret.nrremret              NO-UNDO.
    DEF          VAR aux_dsmotivo AS CHAR                            NO-UNDO.
    DEF          VAR aux_cdtitprt LIKE crapcob.cdtitprt              NO-UNDO.
    DEF          VAR aux_nrseqreg LIKE crapret.nrseqreg              NO-UNDO.

    DEF BUFFER b-crapcob FOR crapcob.

    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper
                         AND crapass.nrdconta = par_nrdconta
                         NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapass THEN
        /* Caso nao encontre associado, assume como pessoa juridica*/
        ASSIGN aux_inpessoa = 2.
    ELSE
        ASSIGN aux_inpessoa = crapass.inpessoa.

    IF  NOT VALID-HANDLE(h-b1wgen0153) THEN
        RUN sistema/generico/procedures/b1wgen0153.p 
            PERSISTENT SET h-b1wgen0153.

    IF par_cdocorre <> 28 THEN
        aux_dsmotivo = "".
    ELSE
        aux_dsmotivo = par_dsmotivo.

    RUN carrega_dados_tarifa_cobranca IN
          h-b1wgen0153(INPUT  par_cdcooper,         /* cdcooper */
                       INPUT  par_nrdconta,         /* nrdconta */
                       INPUT  par_nrcnvcob,         /* nrconven */ 
                       INPUT  "RET",                /* dsincide */
                       INPUT  par_cdocorre,         /* cdocorre */
                       INPUT  aux_dsmotivo,         /* cdmotivo */
                       INPUT  aux_inpessoa,         /* inpessoa */
                       INPUT  1,                    /* vllanmto */
                       INPUT  "",                   /* cdprogra */
					   INPUT  0,                    /* flaputar - Nao */
                       OUTPUT tar_cdhistor,         /* cdhistor */
                       OUTPUT tar_cdhisest,         /* cdhisest */
                       OUTPUT tar_vltarifa,         /* vltarifa */
                       OUTPUT tar_dtdivulg,         /* dtdivulg */
                       OUTPUT tar_dtvigenc,         /* dtvigenc */
                       OUTPUT tar_cdfvlcop,         /* cdfvlcop */
                       OUTPUT TABLE tt-erro).
    
    IF  RETURN-VALUE = "OK"   THEN
        ASSIGN aux_vltarass = tar_vltarifa.
    ELSE
        ASSIGN aux_vltarass = 0.

    DELETE PROCEDURE h-b1wgen0153.

    FIND FIRST crapcco WHERE crapcco.cdcooper = par_cdcooper
                         AND crapcco.nrconven = par_nrcnvcob
                         AND crapcco.cddbanco = 1
                         NO-LOCK NO-ERROR.

    CREATE crapret.
    ASSIGN crapret.cdcooper = par_cdcooper /* CHAVE */
           crapret.nrcnvcob = par_nrcnvcob /* CHAVE */
           crapret.nrremret = par_nrremret /* CHAVE */
           crapret.nrseqreg = par_nrseqreg /* CHAVE */
           crapret.nrdconta = par_nrdconta
           crapret.nrdocmto = par_nrdocmto
           crapret.nrnosnum = par_nrnosnum
           crapret.cdocorre = par_cdocorre
           crapret.cdmotivo = par_dsmotivo
           crapret.nrretcoo = par_nrretcoo
           crapret.dtcredit = par_dtcredit
           crapret.cdbcorec = par_cdbcorec
           crapret.cdagerec = par_cdagerec
           crapret.cdbcocor = par_cdbcocor
           crapret.dtocorre = par_dtocorre
           crapret.vlabatim = par_vlabatim
           crapret.vldescto = par_vldescto
           crapret.vljurmul = par_vljurmul
           crapret.vloutcre = par_vloutcre
           crapret.vloutdes = par_vloutdes
           crapret.vlrliqui = par_vlrliqui
           crapret.vlrpagto = par_vlrpagto
           crapret.vltarcus = par_vltarifa
           crapret.vltarass = aux_vltarass
           crapret.vltitulo = par_vltitulo
           crapret.cdoperad = par_cdoperad
           crapret.inestcri = par_inestcri
           crapret.dtaltera = (IF par_dtmvtolt < par_dtocorre THEN
                                  par_dtocorre 
                               ELSE 
                                  par_dtmvtolt)
           crapret.hrtransa = TIME
           crapret.cdhistbb = IF AVAIL crapcco THEN
                                  IF par_cdocorre = 2 THEN
                                      936
                                  ELSE
                                  IF (par_cdocorre = 6 OR par_cdocorre = 17) AND
                                     (par_vltarifa > 0 OR par_vloutdes > 0) THEN
                                      966
                                  ELSE
                                  IF par_cdocorre = 19 AND 
                                     (par_vltarifa > 0 OR par_vloutdes > 0) THEN
                                      939
                                  ELSE
                                  IF par_cdocorre = 20 OR 
                                     par_cdocorre = 24 THEN
                                      940
                                  ELSE
                                  IF par_cdocorre = 09 AND 
                                     par_dsmotivo <> "14" THEN
                                      937
                                  ELSE
                                  IF par_cdocorre = 28 AND
                                     par_dsmotivo = "02" THEN
                                      938
                                  ELSE
                                  IF CAN-DO("07,08,12,13,14,27,29,42,43",
                                            STRING(par_cdocorre, "99")) THEN
                                      965
                                  ELSE
                                  IF par_cdocorre = 09 AND
                                     par_dsmotivo = "14" THEN
                                      973
                                  ELSE
                                  IF par_cdocorre = 28 AND
                                     par_dsmotivo <> "02" THEN
                                      973
                                  ELSE
                                  IF par_cdocorre = 23 THEN
                                     973
                                  ELSE
                                      0
                              ELSE
                                 0.
    VALIDATE crapret.

    RETURN "OK".

END PROCEDURE.

PROCEDURE prepara-retorno-cooperativa-085:

    DEFINE  INPUT PARAM par_cdcooper LIKE crapcop.cdcooper   NO-UNDO.
    DEFINE  INPUT PARAM par_nrcnvcob LIKE crapcob.nrcnvcob   NO-UNDO.
    DEFINE  INPUT PARAM par_dtmvtolt LIKE crapdat.dtmvtolt   NO-UNDO.
    DEFINE  INPUT PARAM par_cdoperad LIKE crapope.cdoperad   NO-UNDO.
    DEFINE OUTPUT PARAM par_nrremret LIKE crapcre.nrremret   NO-UNDO.

    DEF VAR aux_nrremret LIKE crapcre.nrremret               NO-UNDO.

    DEF BUFFER b-crapcco FOR crapcco.
    DEF BUFFER b-crapcre FOR crapcre.

    ASSIGN aux_nrremret = 0.

    FIND b-crapcco WHERE 
         b-crapcco.cdcooper = par_cdcooper AND
         b-crapcco.nrconven = par_nrcnvcob AND
         b-crapcco.cddbanco = 085
         NO-LOCK NO-ERROR.

    IF  NOT AVAIL(b-crapcco) THEN RETURN "NOK".

    /* buscar o ultimo movimento de retorno do convenio do dia */
    FIND LAST b-crapcre WHERE 
              b-crapcre.cdcooper = par_cdcooper AND
              b-crapcre.nrcnvcob = par_nrcnvcob AND
              b-crapcre.dtmvtolt = par_dtmvtolt AND
              b-crapcre.intipmvt = 2 /* retorno */
              NO-LOCK NO-ERROR.

    IF  NOT AVAIL b-crapcre  THEN
    DO:
        FIND LAST b-crapcre WHERE 
                  b-crapcre.cdcooper = par_cdcooper AND
                  b-crapcre.nrcnvcob = par_nrcnvcob AND
                  b-crapcre.dtmvtolt <> ?           AND
                  b-crapcre.intipmvt = 2 /* retorno */
                  NO-LOCK NO-ERROR.

        IF  AVAIL b-crapcre THEN
            ASSIGN aux_nrremret = b-crapcre.nrremret + 1. 
        ELSE
            ASSIGN aux_nrremret = 999999.          
  
        CREATE b-crapcre.
        ASSIGN b-crapcre.cdcooper = par_cdcooper
               b-crapcre.nrcnvcob = par_nrcnvcob
               b-crapcre.dtmvtolt = par_dtmvtolt
               b-crapcre.nrremret = aux_nrremret
               b-crapcre.intipmvt = 2 /* retorno */
               b-crapcre.nmarquiv = "ret085_" +
                                  STRING(DAY(par_dtmvtolt),"99") +
                                  STRING(MONTH(par_dtmvtolt),"99") +
                                  "_" +
                                  STRING(par_nrcnvcob,"999999")
               b-crapcre.flgproce = FALSE
               b-crapcre.cdoperad = par_cdoperad
               b-crapcre.dtaltera = par_dtmvtolt.
        VALIDATE b-crapcre.
    END.
    ELSE
        aux_nrremret = b-crapcre.nrremret.

    ASSIGN par_nrremret = aux_nrremret.

    RETURN "OK".


END PROCEDURE.

/*............................................................................*/

PROCEDURE prepara-retorno-cooperativa:

    DEFINE INPUT  PARAMETER par_idtabcob AS ROWID       NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtocorre AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdoperad AS CHARACTER   NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlabatim AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vldescto AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vljurmul AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlrpagto AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_nrretcoo AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdmotivo AS CHAR        NO-UNDO.
    DEFINE INPUT  PARAMETER par_cdocorre AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_inestcri AS INT         NO-UNDO.

    DEFINE VARIABLE aux_nrremret AS INTEGER     NO-UNDO.
    DEFINE VARIABLE aux_nrseqreg AS INTEGER     NO-UNDO.

    DEFINE VARIABLE aux_nrsequen AS INTE                NO-UNDO.
    DEFINE VARIABLE aux_busca    AS CHAR                NO-UNDO.

    FIND FIRST crapcob WHERE ROWID(crapcob) = par_idtabcob 
         NO-LOCK NO-ERROR.
    
    /* buscar o ultimo movimento de retorno do convenio do dia */
    FIND LAST crapcre WHERE crapcre.cdcooper = crapcob.cdcooper AND
                            crapcre.nrcnvcob = crapcob.nrcnvcob AND
                            crapcre.dtmvtolt = par_dtmvtolt      AND
                            crapcre.intipmvt = 2 /* retorno */
                            NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcre  THEN
    DO:
        /* tratamento especial para titulos cobranca com registro BB */
        IF  crapcob.cdbandoc = 1 THEN DO:
            FIND LAST crapcre WHERE  
                      crapcre.cdcooper = crapcob.cdcooper AND
                      crapcre.nrcnvcob = crapcob.nrcnvcob AND
                      crapcre.nrremret > 999999            AND
                      crapcre.intipmvt = 2 /* retorno */
                      NO-LOCK NO-ERROR.

            /* numeracao BB quando gerado pelo sistema, comecar 
               a partir de 999999 para nao confundir com o numero 
               de controle do arquivo de retorno BB */
            IF  NOT AVAIL crapcre THEN
                ASSIGN aux_nrremret = 999999.
            ELSE
                ASSIGN aux_nrremret = crapcre.nrremret + 1. 
        END.
        ELSE DO:
            FIND LAST crapcre WHERE 
                      crapcre.cdcooper = crapcob.cdcooper AND
                      crapcre.nrcnvcob = crapcob.nrcnvcob AND
                      crapcre.intipmvt = 2 /* retorno */
                      NO-LOCK NO-ERROR.

            IF  NOT AVAIL crapcre THEN
                ASSIGN aux_nrremret = 1.
            ELSE
                ASSIGN aux_nrremret = crapcre.nrremret + 1. 
        END.

  
        CREATE crapcre.
        ASSIGN crapcre.cdcooper = crapcob.cdcooper
               crapcre.nrcnvcob = crapcob.nrcnvcob
               crapcre.dtmvtolt = par_dtmvtolt
               crapcre.nrremret = aux_nrremret
               crapcre.intipmvt = 2 /* retorno */
               crapcre.nmarquiv = "ret085_" +
                                  STRING(DAY(par_dtmvtolt),"99") +
                                  STRING(MONTH(par_dtmvtolt),"99") +
                                  "_" +
                                  STRING(crapcob.nrcnvcob,"999999")
               crapcre.flgproce = FALSE
               crapcre.cdoperad = par_cdoperad
               crapcre.dtaltera = par_dtmvtolt.
        VALIDATE crapcre.
    END.
    ELSE
        ASSIGN aux_nrremret = crapcre.nrremret.
/*
    FIND LAST crapret WHERE crapret.cdcooper = crapcob.cdcooper AND 
                            crapret.nrcnvcob = crapcob.nrcnvcob AND
                            crapret.nrremret = aux_nrremret
                            NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapret  THEN
        ASSIGN aux_nrseqreg = 1.
    ELSE
        ASSIGN aux_nrseqreg = crapret.nrseqreg + 1.
*/
    /* A busca do sequencial do nrseqreg sera atraves de sequence no Oracle */
    /* CDCOOPER;NRCNVCOB;NRREMRET */
    ASSIGN aux_busca = TRIM(STRING(crapcob.cdcooper))   + ";" +
                       TRIM(STRING(crapcob.nrcnvcob))   + ";" +
                       TRIM(STRING(aux_nrremret)).

    /* Busca a proxima sequencia do campo CRAPRET.NRSEQREG */
	RUN STORED-PROCEDURE pc_sequence_progress
	aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPRET"
										,INPUT "NRSEQREG"
										,INPUT aux_busca
										,INPUT "N"
										,"").
	
	CLOSE STORED-PROC pc_sequence_progress
	aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
			  
	ASSIGN aux_nrsequen = INTE(pc_sequence_progress.pr_sequence)
						  WHEN pc_sequence_progress.pr_sequence <> ?.

    RUN grava-retorno(INPUT crapcob.cdcooper,
                      INPUT crapcob.nrcnvcob,
                      INPUT crapcob.nrdconta,
                      INPUT crapcob.nrdocmto,
                      INPUT crapcob.nrnosnum, /* nrnosnum */
                      INPUT par_cdocorre,  /* cdocorre 6 ou 17 */ 
                      INPUT par_cdmotivo, 
                      INPUT aux_nrremret,
                      INPUT aux_nrsequen,
                      INPUT crapcop.cdbcoctl,
                      INPUT crapcop.cdagectl,
                      INPUT 0,   /* cdbcocor */
                      INPUT par_nrretcoo,   /* nrretcco */
                      INPUT ?, /*   dtcredit */
                      INPUT par_vlabatim,
                      INPUT par_vldescto,
                      INPUT par_vljurmul,
                      INPUT 0,  /* vloutcre */
                      INPUT 0,  /* vloutdes */
                      INPUT par_vlrpagto,   /* SD 183392 */
                      INPUT par_vlrpagto,
                      INPUT 0, /* vltarcus */
                      INPUT crapcob.vltitulo,
                      INPUT par_cdoperad,
                      INPUT par_dtmvtolt,
                      INPUT par_dtmvtolt,
                      INPUT par_inestcri).

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE realiza-lancto-cooperado:
    /*************************************************************************
        Objetivo: Criar registros de LCM na conta do cooperado.
                  Apenas 1 lancamento por historico.
    *************************************************************************/
    DEF INPUT PARAM par_cdcooper AS INTE                               NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                               NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INT                                NO-UNDO.
    DEF INPUT PARAM par_cdbccxlt AS INT                                NO-UNDO.
    DEF INPUT PARAM par_nrdolote AS INT                                NO-UNDO.
    DEF INPUT PARAM par_cdpesqbb AS CHAR                               NO-UNDO.
    DEF INPUT PARAM TABLE FOR tt-lcm-consolidada.

    DEF         VAR aux_nrdocmto LIKE craprej.nrdocmto                 NO-UNDO.
    DEF         VAR aux_intseque AS INTE INIT 1                        NO-UNDO.
    DEF         VAR in99         AS INTE INIT 0                        NO-UNDO.
    
    DEF         VAR h-b1wgen0153 AS HANDLE                             NO-UNDO. 
    
    IF NOT VALID-HANDLE(h-b1wgen0153) THEN
            RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.
    
    FOR EACH tt-lcm-consolidada  WHERE
             tt-lcm-consolidada.nrconven = INT(par_cdpesqbb)
        NO-LOCK
          BY tt-lcm-consolidada.tplancto
          BY tt-lcm-consolidada.nrdconta:

        IF tt-lcm-consolidada.tplancto <> "T" THEN /* Tarifa */
        DO:
        
            ASSIGN in99 = 0.
    
            DO WHILE TRUE:
    
                ASSIGN in99 = in99 + 1.
    
                FIND craplot WHERE craplot.cdcooper = par_cdcooper AND
                                   craplot.dtmvtolt = par_dtmvtolt AND
                                   craplot.cdagenci = par_cdagenci AND
                                   craplot.cdbccxlt = par_cdbccxlt AND
                                   craplot.nrdolote = par_nrdolote
                                   EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                IF   NOT AVAILABLE craplot   THEN
                     IF   LOCKED craplot   THEN
                          DO:
                              IF  in99 <= 10 THEN
                                  DO:
                                      PAUSE 1 NO-MESSAGE.
                                      NEXT.
                                  END.
                              ELSE
                                  RETURN "NOK".
                          END.
                     ELSE
                          DO:
                              CREATE craplot.
                              ASSIGN craplot.cdcooper = par_cdcooper
                                     craplot.dtmvtolt = par_dtmvtolt
                                     craplot.cdagenci = par_cdagenci
                                     craplot.cdbccxlt = par_cdbccxlt
                                     craplot.nrdolote = par_nrdolote
                                     craplot.tplotmov = 1.
                              VALIDATE craplot.
                          END.
                LEAVE.
            END.  /*  Fim do DO WHILE TRUE  */
            
            IF  tt-lcm-consolidada.nrconven > 0 THEN
                ASSIGN aux_nrdocmto = tt-lcm-consolidada.nrconven.
            ELSE
                ASSIGN aux_nrdocmto = 1.
    
            ASSIGN aux_intseque = 1.
    
            DO WHILE TRUE:
    
                FIND craplcm WHERE
                     craplcm.cdcooper = craplot.cdcooper  AND
                     craplcm.dtmvtolt = craplot.dtmvtolt  AND
                     craplcm.cdagenci = craplot.cdagenci  AND
                     craplcm.cdbccxlt = craplot.cdbccxlt  AND
                     craplcm.nrdolote = craplot.nrdolote  AND
                     craplcm.nrdctabb = tt-lcm-consolidada.nrdconta AND
                     craplcm.nrdocmto = aux_nrdocmto
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
                IF  AVAILABLE craplcm THEN 
                    DO:
                        ASSIGN aux_intseque = aux_intseque + 1
                               aux_nrdocmto = 
                                  DECI(STRING(tt-lcm-consolidada.nrconven) + 
                                       STRING(aux_intseque,"9999"))
                                  NO-ERROR.
    
                        IF  aux_intseque > 9999 THEN
                            ASSIGN aux_nrdocmto = aux_intseque.
    
                        NEXT.
                    END.
                ELSE
                    LEAVE.
            END.

            CREATE craplcm.
            ASSIGN craplcm.dtmvtolt = craplot.dtmvtolt
                   craplcm.cdagenci = craplot.cdagenci
                   craplcm.cdbccxlt = craplot.cdbccxlt
                   craplcm.nrdolote = craplot.nrdolote
                   craplcm.nrdconta = tt-lcm-consolidada.nrdconta
                   craplcm.nrdctabb = tt-lcm-consolidada.nrdconta
                   craplcm.nrdctitg = STRING(tt-lcm-consolidada.nrdconta,"99999999")
                   craplcm.nrdocmto = aux_nrdocmto
                   craplcm.cdhistor = tt-lcm-consolidada.cdhistor
                   craplcm.nrseqdig = craplot.nrseqdig + 1
                   craplcm.vllanmto = tt-lcm-consolidada.vllancto
                   craplcm.cdpesqbb = par_cdpesqbb
                   craplcm.cdcooper = tt-lcm-consolidada.cdcooper
                   craplcm.hrtransa = TIME 

                   craplot.qtinfoln = craplot.qtinfoln + 1
                   craplot.qtcompln = craplot.qtcompln + 1
                   craplot.vlinfodb = craplot.vlinfodb + tt-lcm-consolidada.vllancto
                   craplot.vlcompdb = craplot.vlcompdb + tt-lcm-consolidada.vllancto
                   craplot.nrseqdig = craplcm.nrseqdig.
            VALIDATE craplcm.
        END.
        ELSE
        DO:    

            FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper
                                    NO-ERROR NO-WAIT.

            IF NOT AVAIL crapdat THEN
                NEXT.

            RUN cria_lan_auto_tarifa IN h-b1wgen0153
                               (INPUT par_cdcooper,
                                INPUT tt-lcm-consolidada.nrdconta,            
                                INPUT crapdat.dtmvtolt,
                                INPUT tt-lcm-consolidada.cdhistor, 
                                INPUT tt-lcm-consolidada.vllancto,
                                INPUT "1",                                              /* cdoperad */
                                INPUT 1,                                                /* cdagenci */
                                INPUT par_cdbccxlt,                                     /* cdbccxlt */         
                                INPUT par_nrdolote,                                     /* nrdolote */        
                                INPUT 1,                                                /* tpdolote */         
                                INPUT 0,                                                /* nrdocmto */
                                INPUT tt-lcm-consolidada.nrdconta,                      /* nrdconta */
                                INPUT STRING(tt-lcm-consolidada.nrdconta,"99999999"),   /* nrdctitg */
                                INPUT "",                                               /* cdpesqbb */
                                INPUT 0,                                                /* cdbanchq */
                                INPUT 0,                                                /* cdagechq */
                                INPUT 0,                                                /* nrctachq */
                                INPUT FALSE,                                            /* flgaviso */
                                INPUT 0,                                                /* tpdaviso */
                                INPUT tt-lcm-consolidada.cdfvlcop,                      /* cdfvlcop */
                                INPUT crapdat.inproces,                                 /* inproces */
                                OUTPUT TABLE tt-erro).
    
            IF  RETURN-VALUE = "NOK"  THEN
            DO:
                FIND FIRST tt-erro NO-LOCK NO-ERROR.
        
                IF AVAIL tt-erro THEN  
        DO:                                  
                    CREATE crapcol.
                    ASSIGN crapcol.cdcooper = par_cdcooper
                           crapcol.nrdconta = tt-lcm-consolidada.nrdconta
                           crapcol.nrdocmto = 0
                           crapcol.nrcnvcob = tt-lcm-consolidada.nrconven
                           crapcol.dslogtit = tt-erro.dscritic
                           crapcol.cdoperad = "TARIFA"
                           crapcol.dtaltera = TODAY
                           crapcol.hrtransa = TIME.
                    VALIDATE crapcol.
                END.
                
                NEXT.
            END.

        END.


    END. /* FIM do FOR EACH tt-lcm-consolidada */

    IF VALID-HANDLE(h-b1wgen0153) THEN
        DELETE PROCEDURE h-b1wgen0153.

    RETURN "OK". 

END PROCEDURE.


PROCEDURE busca-dados-tarifa:

    DEF INPUT  PARAM par_cdcooper       LIKE crapcob.cdcooper       NO-UNDO.
    DEF INPUT  PARAM par_nrdconta       LIKE crapass.nrdconta       NO-UNDO.
    DEF INPUT  PARAM par_nrcnvcob       AS INTE                     NO-UNDO.
    DEF INPUT  PARAM par_dsincide       AS CHAR                     NO-UNDO.
    DEF INPUT  PARAM par_cdocorre       AS INTE                     NO-UNDO.
    DEF INPUT  PARAM par_cdmotivo       AS CHAR                     NO-UNDO.
    DEF INPUT  PARAM par_idtabcob       AS ROWID                    NO-UNDO.
    DEF INPUT  PARAM par_flaputar       AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM par_cdhistor       AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM par_cdhisest       AS INTE                     NO-UNDO.
    DEF OUTPUT PARAM par_vltarifa       AS DECI                     NO-UNDO.
    DEF OUTPUT PARAM par_dtdivulg       AS DATE                     NO-UNDO.
    DEF OUTPUT PARAM par_dtvigenc       AS DATE                     NO-UNDO.
    DEF OUTPUT PARAM par_cdfvlcop       AS INTE                     NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-erro.

    
    DEF VAR aux_inpessoa        AS INTE                             NO-UNDO.

    DEF VAR h-b1wgen0153        AS HANDLE                           NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.


    /* Assume como padrao pessoa juridica*/
    ASSIGN aux_inpessoa = 2.

    FIND FIRST crapass WHERE crapass.cdcooper = par_cdcooper
                         AND crapass.nrdconta = par_nrdconta
                         NO-LOCK NO-ERROR.

    IF  AVAIL crapass THEN
        ASSIGN aux_inpessoa = crapass.inpessoa.

    IF  NOT VALID-HANDLE(h-b1wgen0153) THEN
        RUN sistema/generico/procedures/b1wgen0153.p PERSISTENT SET h-b1wgen0153.

    ASSIGN par_vltarifa = 0
           par_cdhistor = 0
           par_cdfvlcop = 0.

    /* Busca informacoes tarifa */
    RUN carrega_dados_tarifa_cobranca IN h-b1wgen0153
                      (INPUT  par_cdcooper,         /* cdcooper */
                       INPUT  par_nrdconta,         /* nrdconta */
                       INPUT  par_nrcnvcob,         /* nrconven */ 
                       INPUT  par_dsincide,         /* dsincide REM/RET */ 
                       INPUT  par_cdocorre,         /* cdocorre */
                       INPUT  par_cdmotivo,         /* cdmotivo */
                       INPUT  aux_inpessoa,         /* inpessoa */
                       INPUT  1,                    /* vllanmto */
                       INPUT  "",                   /* cdprogra */
					   INPUT  par_flaputar,         /* flaputar */
                       OUTPUT par_cdhistor,         /* cdhistor */
                       OUTPUT par_cdhisest,         /* cdhisest */
                       OUTPUT par_vltarifa,         /* vltarifa */
                       OUTPUT par_dtdivulg,         /* dtdivulg */
                       OUTPUT par_dtvigenc,         /* dtvigenc */
                       OUTPUT par_cdfvlcop,         /* cdfvlcop */
                       OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0153)  THEN
        DELETE PROCEDURE h-b1wgen0153.

    IF RETURN-VALUE = "NOK" THEN
    DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.
    
        IF AVAIL tt-erro THEN 	
            RUN cria-log-tarifa-cobranca(INPUT par_idtabcob,
                                         INPUT tt-erro.dscritic).
    END.

END.


PROCEDURE cria-log-tarifa-cobranca:
    
    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.
    DEF  INPUT PARAM par_dsmensag AS CHAR                            NO-UNDO.

    DEF BUFFER crabcob FOR crapcob.

    FIND FIRST crabcob WHERE ROWID(crabcob) = par_idtabcob
             NO-LOCK NO-ERROR.

    IF AVAIL bcrapcob THEN
        DO:
            CREATE crapcol.
            ASSIGN crapcol.cdcooper = crabcob.cdcooper
                   crapcol.nrdconta = crabcob.nrdconta
                   crapcol.nrdocmto = crabcob.nrdocmto
                   crapcol.nrcnvcob = crabcob.nrcnvcob
                   crapcol.dslogtit = par_dsmensag
                   crapcol.cdoperad = "TARIFA"
                   crapcol.dtaltera = TODAY
                   crapcol.hrtransa = TIME.
            VALIDATE crapcol.
        END.

END PROCEDURE.

/*............................................................................*/






