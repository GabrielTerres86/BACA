/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +-----------------------------------+---------------------------------------+
  | Rotina Progress                   | Rotina Oracle PLSQL                   |
  +-----------------------------------+---------------------------------------+
  | procedures/b1wgen0088.p           | PAGA0001                              |
  |   cria-log-cobranca               | PAGA0001.pc_cria_log_cobranca         |
  |   liquidacao-intrabancaria-dda    | DDDA0001.pc_liquidacao_intrabancaria_dda |
  |   p_calc_codigo_barra             | DDDA0001.pc_calc_codigo_barras        |
  |   cria-tt-dda                     | DDDA0001.pc_cria_remessa_dda          |
  |   inst-sustar-baixar              | PAGA0001.pc_inst_sustar_baixar        | 
  |   inst-protestar                  | PAGA0001.pc_inst_protestar            |
  |   inst-pedido-baixa-decurso       | PAGA0001.pc_inst_pedido_baixa_decurso | 
  |   efetua-validacao-recusa-padrao  | PAGA0001.pc_efetua_val_recusa_padrao  |
  |   prep-remessa-banco              | PAGA0001.pc_prep_remessa_banco        |
  |   cria-tab-remessa                | PAGA0001.pc_cria_tab_remessa          |
  |   enviar-tit-protest              | PAGA0001.pc_enviar_tit_protesto       |
  |   inst-titulo-migrado             | PAGA0001.pc_inst_titulo_migrado       | 
  |   verifica-horario-cobranca       | PAGA0001.pc_verifica_horario_cobranca |
  |   verifica-ent-confirmada         | PAGA0001.pc_verifica_ent_confirmada   |
  |   procedimentos-dda-jd            | DDDA0001.pc_procedimentos_dda_jd      |
  |   pi-elimina-remessa              | PAGA0001.pc_elimina_remessa           |
  |   verifica-existencia-instrucao   | PAGA0001.pc_verif_existencia_instruc  |
  |   inst-pedido-baixa               | PAGA0001.pc_inst_pedido_baixa         |            
  +-----------------------------------+---------------------------------------+

  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)

*******************************************************************************/












/*..............................................................................

   Programa: sistema/internet/procedures/b1wgen0088.p
   Autor   : Guilherme/Supero
   Data    : 15/03/2011                        Ultima atualizacao: 26/05/2018

   Dados referentes ao programa:

   Objetivo  : BO para instruções bancárias - Cob. Registrada 

   Alteracoes: 27/05/2011 - Alterado as procedures que utilzam a 
                            procedimentos-dda-jd para validar, depois enviar os 
                            comandos para JD, e apos alterar as infos em nossa
                            base (Guilherme).
                            
               10/06/2011 - ao fazer buffer-copy, o sacador avalista é o próprio 
                            cooperado
                            ** nrinsava = cpf/cnpj do cooperado;
                            ** cdtpinav = tipo pessoa do cooperado;
                            ** nmdavali = nome do cooperado;
                          - deletar procedure persistent
                            (Guilherme).
                            
               14/06/2011 - alterado regra de canc de protesto (Rafael)
               
               17/06/2011 - alterado tipo do parametro par_dtvenco 
                            das procedures cria-tt-dda, procedimentos-jd-dda
                            (Rafael)
                            
               07/07/2011 - Alterado nome da procedure procedimentos-dda-jd_bo89
                            para liquidacao-intrabancaria-dda (Elton).
                            
               14/07/2011 - Incluir inst-pedido-baixa-decurso 
                          - Alterar ordem de chamadas nas procedures da 
                            enviar-tit-protesto para não perder o buffer
                            bcrapcob (Guilherme).
                            
               29/07/2011 - Reposicionar buffer na procedure inst-protestar
                            (Rafael).
                          - Ao realizar buffer-copy, nao copiar dtdbaixa
                            na procedure inst-protestar (Rafael).
                            
               02/08/2011 - Retirado exclusive do find bcrapcob na procedure
                            inst-protestar para nao gerar transacao em todo o 
                            procedimento (Guilherme).
                            
               17/08/2011 - Incluido rotina de exclusao de remessa de titulos
                            do BB quando gerado inst de baixa no mesmo dia.
                            procedure inst-pedido-baixa (Rafael).
                            
               18/08/2011 - Alterado inst-pedido-baixa. Quando usuario 
                            996 - Internet, gerar motivo de baixa 10. (Rafael).
                            
               28/09/2011 - Realizado ajustes na rotina de protesto. (Rafael).
               
               03/10/2011 - Alterado rotina de protesto. Banco rejeita 
                            instrucao quando ocorre o registro no mesmo dia.
                            (Rafael).
                           
               13/10/2011 - Rotina de baixa por decurso de prazo estava com
                            os códigos invertidos (13/09 por 09/13) (Rafael).
                            
               07/11/2011 - Alterado cria-tt-dda e p_calc_codigo_barras p/
                            utilizar data de vencto como parametro. Qdo 
                            prorrogar titulo, alterar tbem codbarras (Rafael).
                            
               08/12/2011 - Cobrar tarifa de protesto somente qdo o operador
                            for o cooperado. (Rafael).
                          - Ao protestar, nao substituir data de emissao do
                            boleto a protestar. (Rafael).
                           
               22/12/2011 - Validação Praça não executante de protesto (Tiago).
               
               11/01/2012 - Antes de executar instrução, verificar se titulo
                            já foi registrado no DDA. (Rafael)
                            
               17/01/2012 - Vlr do abatimento somado ao desconto quando titulo
                            for protestado. (Rafael)
                            
               08/03/2012 - Ajuste nas procedures de registro de titulos no DDA
                            em virtude do novo catalogo de mensagens 3.05
                            da CIP. (Rafael)
                            
               19/04/2012 - Criar vinculo do titulo 085 ao titulo do BB
                            atraves do campo crapcob.cdtitprt. (Lucas)
                            
               09/08/2012 - Verificar se titulo está descontado antes de 
                            comandar instrução (David Kruger).              
                            
               10/12/2012 - Enviar email de solicitacao de instrucao a 
                            cooperativa ref. a titulo migrado. (Rafael)
                            
               18/04/2013 - Projeto Melhorias da Cobranca - Implementar
                            instrucoes de desconto, cancelar desconto e 
                            alteracao de outros dados. (Rafael)
                            
               06/06/2013 - Alterado as procedures gerar-tarifas-cooperado
                            excl-inst-baixa, excl-inst-conc-abatimento, 
                            excl-inst-alt-vencto, excl-inst-protestar, 
                            excl-inst-sustar-baixa, excl-inst-sustar-manter
                            para utilizarem a rotina carrega_dados_tarifa_cobranca
                            da b1wgen0153 para buscar valor tarifa. (Daniel)
                            
               10/06/2013 - Alteração função enviar_email_completo para
                            nova versão (Jean Michel).  
                          - Remover inst protesto de titulos da remessa do dia
                            quando for comandado instr de baixa. (Rafael)
                            
               12/07/2013 - Validar horario de cobranca ao comandar algumas
                            instrucoes quando titulo for BB e instrucao de
                            protesto. (Rafael)
                            
               30/07/2013 - Incluso procedure cria-log-tarifa-cobranca e verificacao
                            na procedure carrega_dados_tarifa_cobranca para geracao
                            de log usando cria-log-tarifa-cobranca. (Daniel)
                            
               05/08/2013 - Comentado criacao da cria-log-tarifa-cobranca (Daniel). 
                            
               27/08/2013 - Alteracao nas procedures inst-pedido-baixa, inst-conc-abatimento
                            inst-canc-abatimento, inst-alt-vencto, inst-conc-desconto,
                            inst-canc-desconto, inst-protestar, inst-sustar-baixar,
                            inst-sustar-manter, inst-alt-outros-dados, inst-cancel-protesto,
                            inst-pedido-baixa-decurso para adequacao Projeto Cobranca, incluso
                            include b1wgen0010tt.i (Daniel).  
                            
               25/09/2013 - Excluido as procedures gerar-tarifas-cooperado
                            excl-inst-baixa, excl-inst-conc-abatimento, 
                            excl-inst-alt-vencto, excl-inst-protestar, 
                            excl-inst-sustar-baixa, excl-inst-sustar-manter (Daniel).
                            
               10/10/2013 - Incluido parametro cdprogra nas procedures da 
                            b1wgen0153 que carregam dados de tarifas (Tiago).
                            
               17/12/2013 - Adicionado VALIDATE para CREATE. (Jorge)
               
               24/12/2013 - Ajuste migracao Acredi->Viacredi. (Rafael)
               
               26/12/2013 - Ajuste processo leitura crapcob para ganho de performace (Daniel).
               
               13/01/2014 - Incluso tratamneto para nao permitir alteracao de vencimento
                            de boletos em cartorio (Daniel).
                            
               04/02/2014 - Ajuste Projeto Novo Fator de Vencimento (Daniel).
               
               26/03/2014 - Ajuste processo sequence crapcob (Daniel).
               
               07/05/2014 - Alterado na procedure inst-alt-vencto, mensagem
                            de retorno ao cooperado para motivo 18. (Fabricio)
               
               05/08/2014 - Alterado inst-alt-vencto para nao permitir alterar 
                            a data de boletos com qualquer situaçao no campo insitcrt
                            (Odirlei - Amcom)
                                                           			             
               02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).    
               
               05/01/2015 - Ajustado efetua-validacao-recusa-padrao para não gerar critica de 
                            titulo descontado caso a situação seja 0 e que ja esteja vencido. 
                            SD237726 (Odirlei-AMcom)
                
               05/01/2015 -  Alterado o e-mail para recebimento das instruções nos boletos  
                             emitidos pela Concredi de suporte@viacredi.coop.br para
                             cobranca@cecred.coop.br (Kelvin - SD 236476)
                            
                03/03/2015 - Conversão da fn_sequence para procedure para não
                             gerar cursores abertos no Oracle. (Dionathan)
                             
                28/04/2015 - Ajustes referente Projeto Cooperativa Emite e Expede
                            (Daniel/Rafael/Reinert)
                
                31/07/2015 - Inclusão de novos motivos (Iniciados com "X, Ex: XA, XB, XC, etc...) nas 
                             situações em que estava gravando ocorrência 26 com motivo em branco
                             Chamado 294197 (Heitor - RKAM)
                             
                03/08/2015 - Ajuste para retirar o caminnho absoluto na chamada
                             dos fontes 
                             (Adriano - SD 314469).
                             
                05/10/2015 - PRJ 210: Adicionado validacao para baixa de boletos de 
                             emprestimo na procedure efetua-validacao-recusa-padrao.
                             (Reinert)

                04/02/2016 - Ajuste Projeto negativação Serasa (Daniel)

                15/02/2016 - Inclusao do parametro conta na chamada da
                             carrega_dados_tarifa_cobranca. (Jaison/Marcos)

               17/06/2016 - Inclusão de campos de controle de vendas - M181 ( Rafael Maciel - RKAM)
               
               08/11/2016 - Considerar periodo de carencia parametrizado na regra de bloqueio de baixa
                            de titulos descontados
                            Heitor (Mouts) - Chamado 527557

	           12/12/2016 - Adicionar LOOP para buscar o numero do convenio de protesto 
			                (Douglas - Chamado 564039)
							
			   16/02/2018 - Ref. História KE00726701-36 - Inclusão de Filtro e Parâmetro por Tipo de Pessoa na TAB052
							(Gustavo Sene - GFT)		
							
			   26/05/2018 - Ajustes referente alteracao da nova marca (P413 - Jonata Mouts).
			   					
..............................................................................*/

{ sistema/generico/includes/b1wgen0087tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0015tt.i }
{ sistema/generico/includes/b1wgen0010tt.i }

{ sistema/generico/includes/var_oracle.i }

DEF   VAR aux_cdoperad AS CHAR                                      NO-UNDO.
DEF   VAR aux_nrremret AS INT                                       NO-UNDO.
DEF   VAR aux_nrseqreg AS INT                                       NO-UNDO.
DEF   VAR aux_cddespec AS CHAR                                      NO-UNDO.

DEF     VAR tar_cdhistor AS INTE                                    NO-UNDO.
DEF     VAR tar_cdhisest AS INTE                                    NO-UNDO.
DEF     VAR tar_vltarifa AS DECI                                    NO-UNDO.
DEF     VAR tar_dtdivulg AS DATE                                    NO-UNDO.
DEF     VAR tar_dtvigenc AS DATE                                    NO-UNDO.
DEF     VAR tar_cdfvlcop AS INTE                                    NO-UNDO.

DEF NEW SHARED VAR glb_nrcalcul AS DECI                             NO-UNDO.
DEF NEW SHARED VAR glb_stsnrcal AS LOGI                             NO-UNDO.

DEF   VAR h-b1wgen0087 AS HANDLE                                    NO-UNDO.
DEF   VAR h-b1wgen9999 AS HANDLE                                    NO-UNDO.
DEF   VAR h-b1wgen0090 AS HANDLE                                    NO-UNDO.
DEF   VAR h-b1wgen0015 AS HANDLE                                    NO-UNDO.

DEF BUFFER bcrapcob FOR crapcob.

/*............................................................................*/

PROCEDURE gera_pedido_remessa:

    DEF  INPUT PARAM par_idtabcob AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.

    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.


    FIND FIRST bcrapcob WHERE ROWID(bcrapcob) = par_idtabcob
         NO-LOCK NO-ERROR.



    RUN prep-remessa-banco( INPUT bcrapcob.cdcooper,
                            INPUT bcrapcob.nrcnvcob,
                            INPUT par_dtmvtolt,
                            INPUT par_cdoperad,
                           OUTPUT aux_nrremret,
                           OUTPUT aux_nrseqreg).

    ASSIGN aux_nrseqreg = aux_nrseqreg + 1.

    RUN cria-tab-remessa( ROWID(bcrapcob),
                          aux_nrremret,
                          aux_nrseqreg,
                          1,
                          "", 
                          ?,
                          0,
                          par_cdoperad,
                          par_dtmvtolt).


END PROCEDURE.

/*............................................................................*/

PROCEDURE prep-remessa-banco:

    DEF  INPUT PARAM par_cdcooper AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM ret_nrremret AS INT                             NO-UNDO.
    DEF OUTPUT PARAM ret_nrseqreg AS INT                             NO-UNDO.

    DEF VAR aux_nmarquiv AS CHAR                                     NO-UNDO.

    /*** Localiza o ultimo CRE desta data ***/
    FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper
                        AND crapcre.nrcnvcob = par_nrcnvcob
                        AND crapcre.dtmvtolt = par_dtmvtolt
                        AND crapcre.intipmvt = 1
                        AND crapcre.flgproce = FALSE
        NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapcre THEN
        DO:
            /***** Localiza ultima sequencia *****/
            FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper
                                AND crapcre.nrcnvcob = par_nrcnvcob
                                AND crapcre.intipmvt = 1
                NO-LOCK NO-ERROR.
            IF  NOT AVAIL crapcre THEN
                ret_nrremret = 1.
            ELSE
                ret_nrremret = crapcre.nrremret + 1.
            
            FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.
            
            ASSIGN aux_nmarquiv = "CBR" + STRING(MONTH(par_dtmvtolt),"99") + 
                                          STRING(DAY(par_dtmvtolt),"99") + 
                                          "_" + STRING(crapcop.cdagectl, "9999") + 
                                          "_" + STRING(par_nrcnvcob, "9999999") +
                                          "_" + STRING(ret_nrremret, "99999") +
                                          ".REM".
            
            CREATE crapcre.
            ASSIGN crapcre.cdcooper = par_cdcooper
                   crapcre.nrcnvcob = par_nrcnvcob
                   crapcre.dtmvtolt = par_dtmvtolt
                   crapcre.nrremret = ret_nrremret
                   crapcre.intipmvt = 1
                   crapcre.nmarquiv = aux_nmarquiv
                   crapcre.flgproce = NO
                   crapcre.cdoperad = par_cdoperad
                   crapcre.dtaltera = par_dtmvtolt
                   crapcre.hrtranfi = TIME.
            VALIDATE crapcre.
            
        END.
    ELSE
        ASSIGN ret_nrremret = crapcre.nrremret.


    FIND LAST craprem WHERE craprem.cdcooper = par_cdcooper
                        AND craprem.nrcnvcob = par_nrcnvcob
                        AND craprem.nrremret = ret_nrremret
        NO-LOCK NO-ERROR.

    IF  AVAIL craprem THEN
        ret_nrseqreg = craprem.nrseqreg.
    ELSE
        ret_nrseqreg = 1.

END PROCEDURE.

/*............................................................................*/

PROCEDURE cria-tab-remessa:

    DEF  INPUT PARAM par_idtabcob AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_nrremret AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrseqreg AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdmotivo AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtdprorr AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_vlabatim AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    
    
    FIND FIRST bcrapcob WHERE ROWID(bcrapcob) = par_idtabcob
         NO-LOCK NO-ERROR.

    IF AVAIL bcrapcob THEN
        DO:
            CREATE craprem.
            ASSIGN craprem.cdcooper = bcrapcob.cdcooper
                   craprem.nrcnvcob = bcrapcob.nrcnvcob
                   craprem.nrdconta = bcrapcob.nrdconta
                   craprem.nrdocmto = bcrapcob.nrdocmto
                   craprem.nrremret = par_nrremret
                   craprem.nrseqreg = par_nrseqreg
                   craprem.cdocorre = par_cdocorre
                   craprem.dtdprorr = par_dtdprorr
                   craprem.cdmotivo = par_cdmotivo
                   craprem.vlabatim = par_vlabatim
                   craprem.cdoperad = par_cdoperad
                   craprem.dtaltera = par_dtmvtolt
                   craprem.hrtransa = TIME.
            VALIDATE craprem.
        END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE cria-tab-prorrogacao:

    DEF  INPUT PARAM par_idtabcob AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_dtvctonv AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dtvctori AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_flgconfi AS LOGI                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    

    FIND FIRST bcrapcob WHERE ROWID(bcrapcob) = par_idtabcob
         NO-LOCK NO-ERROR.

    IF AVAIL bcrapcob THEN
        DO:
            CREATE crapcpr.
            ASSIGN crapcpr.cdcooper = bcrapcob.cdcooper
                   crapcpr.nrcnvcob = bcrapcob.nrcnvcob
                   crapcpr.nrdconta = bcrapcob.nrdconta
                   crapcpr.nrdocmto = bcrapcob.nrdocmto
                 
                   crapcpr.dtvctonv = par_dtvctonv
                   crapcpr.dtvctori = par_dtvctori
                   crapcpr.flgconfi = par_flgconfi
                   crapcpr.cdoperad = par_cdoperad
                   crapcpr.dtaltera = par_dtmvtolt
                   crapcpr.hrtransa = TIME.
            VALIDATE crapcpr.
        END.

END PROCEDURE.

/*............................................................................*/

PROCEDURE cria-log-cobranca:
    
    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_dsmensag AS CHAR                            NO-UNDO.

    FIND FIRST bcrapcob WHERE ROWID(bcrapcob) = par_idtabcob
             NO-LOCK NO-ERROR.

    IF AVAIL bcrapcob THEN
        DO:
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
        END.

END PROCEDURE.



PROCEDURE procedimentos-dda-jd:
/*** EXECUTA OS PROCEDIMENTOS DDA COM JD ***/

    DEFINE INPUT  PARAMETER par_tpoperad AS CHARACTER   NO-UNDO.
    /* (B)aixa (I)nclusao (A)lteracao   */
    DEFINE INPUT  PARAMETER par_tpdbaixa AS CHARACTER   NO-UNDO.
    /*    (0)Liq Interbancaria          */
    /*    (1)Liq Intrabancaria          */
    /*    (2)Solicitacao Cedente        */
    /*    (3)Envio p/ Protesto          */
    /*    (4)Baixa por Decurso de Prazo */
    DEFINE INPUT  PARAMETER par_dtvencto AS DATE        NO-UNDO.
    /*DEFINE INPUT  PARAMETER par_dtvencto AS CHARACTER   NO-UNDO.*/
    /* formato da data AAAAMMDD */
    DEFINE INPUT  PARAMETER par_vldescto AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlabatim AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgdprot AS LOGICAL     NO-UNDO.
    DEFINE OUTPUT PARAMETER ret_dsinserr AS CHARACTER   NO-UNDO.

    /* Cria Temp-Table do DDA - JD */
    RUN cria-tt-dda (INPUT  par_tpoperad,
                     INPUT  par_tpdbaixa,
                     INPUT  par_dtvencto,
                     INPUT  par_vldescto,
                     INPUT  par_vlabatim,
                     INPUT  par_flgdprot,
                    OUTPUT ret_dsinserr).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN RETURN-VALUE.
    
    /* Atualiza COB */
    FIND FIRST tt-remessa-dda NO-LOCK NO-ERROR.

    /* Conexao com a JD */
    RUN sistema/generico/procedures/b1wgen9999.p
        PERSISTENT SET h-b1wgen9999.

    IF  NOT VALID-HANDLE(h-b1wgen9999) THEN
        DO:
            ret_dsinserr = "Handle invalido para BO b1wgen9999.".
            RETURN "NOK".
        END.

    RUN p-conectajddda IN h-b1wgen9999 NO-ERROR.

    IF  ERROR-STATUS:ERROR  OR 
        RETURN-VALUE <> "OK" THEN
        DO:
            DELETE PROCEDURE h-b1wgen9999.
    
            ret_dsinserr = "Erro de conexao DDA.".
    
            IF ERROR-STATUS:ERROR THEN 
               ret_dsinserr = ret_dsinserr + " " + 
                 ERROR-STATUS:GET-MESSAGE(ERROR-STATUS:NUM-MESSAGES).
    
            IF RETURN-VALUE <> "OK" THEN
               ret_dsinserr = ret_dsinserr + " - " + RETURN-VALUE + " - ".
    
            RETURN "NOK".
        END.

    RUN sistema/generico/procedures/b1wgen0087.p PERSISTENT SET h-b1wgen0087.

    IF  NOT VALID-HANDLE(h-b1wgen0087) THEN
        DO:
            RUN p-desconectajddda IN h-b1wgen9999 NO-ERROR.
            DELETE PROCEDURE h-b1wgen9999.
            ASSIGN ret_dsinserr = "Handle invalido para b1wgen0087".
            RETURN "NOK".
        END.
        
    RUN remessa-titulos-dda  IN h-b1wgen0087
                      (INPUT-OUTPUT TABLE tt-remessa-dda,
                             OUTPUT TABLE tt-retorno-dda).

    DELETE PROCEDURE h-b1wgen0087.

    /* Desconecta JD */
    IF  VALID-HANDLE(h-b1wgen9999) THEN
        DO:
            RUN p-desconectajddda IN h-b1wgen9999 NO-ERROR.
            DELETE PROCEDURE h-b1wgen9999.
        END.

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    RETURN "OK".
    
END PROCEDURE.



PROCEDURE cria-tt-dda:
    
    DEFINE INPUT  PARAMETER par_tpoperad AS CHARACTER   NO-UNDO.
    /* (B)aixa (I)nclusao (A)lteracao   */
    DEFINE INPUT  PARAMETER par_tpdbaixa AS CHARACTER   NO-UNDO.
    /*    (0)Liq Interbancaria          */
    /*    (1)Liq Intrabancaria          */
    /*    (2)Solicitacao Cedente        */
    /*    (3)Envio p/ Protesto          */
    /*    (4)Baixa por Decurso de Prazo */
    DEFINE INPUT  PARAMETER par_dtvencto AS DATE        NO-UNDO.
    /*DEFINE INPUT  PARAMETER par_dtvencto AS INTEGER     NO-UNDO.*/
    /* formato da data AAAAMMDD */
    DEFINE INPUT  PARAMETER par_vldescto AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_vlabatim AS DECIMAL     NO-UNDO.
    DEFINE INPUT  PARAMETER par_flgdprot AS LOGICAL     NO-UNDO.
    DEFINE OUTPUT PARAMETER ret_dsinserr AS CHARACTER   NO-UNDO.
    
    DEF VAR aux_cdbarras AS CHAR                                        NO-UNDO.
    DEF VAR aux_dsdjuros AS CHAR                                        NO-UNDO.
    DEF VAR aux_vltarifa LIKE crapcct.vltarifa                          NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                        NO-UNDO.
    DEF VAR aux_dsdinstr AS CHAR                                        NO-UNDO.

    EMPTY TEMP-TABLE tt-remessa-dda.

    /* tt-dados-sacado-blt */
    FIND crapsab WHERE crapsab.cdcooper = bcrapcob.cdcooper AND
                       crapsab.nrdconta = bcrapcob.nrdconta AND
                       crapsab.nrinssac = bcrapcob.nrinssac NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapsab  THEN
        RETURN "NOK".
    

    FIND crapass WHERE crapass.cdcooper = bcrapcob.cdcooper AND
                       crapass.nrdconta = bcrapcob.nrdconta
               NO-LOCK NO-ERROR.

     IF  NOT AVAILABLE crapass  THEN
         RETURN "NOK".

     IF  crapass.inpessoa > 1  THEN
         ASSIGN aux_nmprimtl = REPLACE(crapass.nmprimtl,"&","%26").

     IF  crapass.inpessoa = 1  THEN
         DO:
             FIND crapttl WHERE crapttl.cdcooper = bcrapcob.cdcooper AND
                                crapttl.nrdconta = bcrapcob.nrdconta AND
                                crapttl.idseqttl = bcrapcob.idseqttl
                                NO-LOCK NO-ERROR.

             IF  NOT AVAILABLE crapttl  THEN
                 RETURN "NOK".

             ASSIGN aux_nmprimtl = REPLACE(crapttl.nmextttl,"&","%26").
         END.

    RUN p_calc_codigo_barras(  INPUT par_dtvencto,
                              OUTPUT aux_cdbarras ).

    IF bcrapcob.tpjurmor = 1 THEN
        ASSIGN aux_dsdjuros = "1".
    ELSE 
    IF bcrapcob.tpjurmor = 2 THEN
        ASSIGN aux_dsdjuros = "3".
    ELSE
    IF bcrapcob.tpjurmor = 3 THEN
        ASSIGN aux_dsdjuros = "5".

    CASE bcrapcob.cddespec:
        WHEN 1 THEN ASSIGN aux_cddespec = "02".
        WHEN 2 THEN ASSIGN aux_cddespec = "04".
        WHEN 3 THEN ASSIGN aux_cddespec = "12".
        WHEN 4 THEN ASSIGN aux_cddespec = "21".
        WHEN 5 THEN ASSIGN aux_cddespec = "23".
        WHEN 6 THEN ASSIGN aux_cddespec = "17".
        WHEN 7 THEN ASSIGN aux_cddespec = "99".
    END CASE.

    FIND crapban WHERE crapban.cdbccxlt = bcrapcob.cdbandoc
        NO-LOCK NO-ERROR.

    IF NOT AVAIL crapban THEN
        DO:
            ASSIGN ret_dsinserr = "Parametro nrispbif nao encontrado.".
            RETURN "NOK".
        END.

    ASSIGN aux_dsdinstr = bcrapcob.dsdinstr.

    IF par_flgdprot = FALSE THEN
        DO:
            ASSIGN aux_dsdinstr = REPLACE(aux_dsdinstr, 
                                  "** Servico de protesto sera efetuado " + 
                                  "pelo Banco do Brasil **", "").
        END.

    CREATE tt-remessa-dda.
    ASSIGN tt-remessa-dda.cdlegado = "LEG"
           tt-remessa-dda.nrispbif = crapban.nrispbif
           tt-remessa-dda.idopeleg = NEXT-VALUE(seqcob_idopeleg)
           tt-remessa-dda.idtitleg = STRING(bcrapcob.idtitleg)
           tt-remessa-dda.tpoperad = par_tpoperad
           tt-remessa-dda.tpdbaixa = par_tpdbaixa
           tt-remessa-dda.cdifdced = 085
           tt-remessa-dda.tppesced = (IF crapass.inpessoa = 1 THEN "F" ELSE "J")
           tt-remessa-dda.nrdocced = INT64(crapass.nrcpfcgc)
           tt-remessa-dda.nmdocede = aux_nmprimtl
           tt-remessa-dda.cdageced = crapcop.cdagectl
           tt-remessa-dda.nrctaced = bcrapcob.nrdconta
           tt-remessa-dda.tppesori = (IF crapass.inpessoa = 1 THEN "F" ELSE "J")
           tt-remessa-dda.nrdocori = INT64(crapass.nrcpfcgc)
           tt-remessa-dda.nmdoorig = aux_nmprimtl
           tt-remessa-dda.tppessac = (IF crapsab.cdtpinsc = 1
                                      THEN "F" ELSE "J")
           tt-remessa-dda.nrdocsac = crapsab.nrinssac
           tt-remessa-dda.nmdosaca = REPLACE(crapsab.nmdsacad,"&","%26")
           tt-remessa-dda.dsendsac = REPLACE(crapsab.dsendsac,"&","%26")
           tt-remessa-dda.dscidsac = REPLACE(crapsab.nmcidsac,"&","%26")
           tt-remessa-dda.dsufsaca = crapsab.cdufsaca
           tt-remessa-dda.nrcepsac = crapsab.nrcepsac
           tt-remessa-dda.tpdocava = (IF bcrapcob.cdtpinav = 0 THEN 0
                                      ELSE bcrapcob.cdtpinav)
           tt-remessa-dda.nrdocava = (IF bcrapcob.cdtpinav = 0 THEN ?
                                      ELSE INT64(bcrapcob.nrinsava))
           tt-remessa-dda.nmdoaval = (IF TRIM(bcrapcob.nmdavali) = "" THEN ?
                                      ELSE TRIM(bcrapcob.nmdavali))
           tt-remessa-dda.cdcartei = "1" /* cobranca simples */
           tt-remessa-dda.cddmoeda = "09" /* 9 = Real */
           tt-remessa-dda.dsnosnum = bcrapcob.nrnosnum
           tt-remessa-dda.dscodbar = aux_cdbarras
           tt-remessa-dda.dtvencto = INTE(
                                      STRING(YEAR(par_dtvencto),"9999") +
                                      STRING(MONTH(par_dtvencto), "99") +
                                      STRING(DAY(par_dtvencto), "99"))
           tt-remessa-dda.vlrtitul = bcrapcob.vltitulo
           tt-remessa-dda.nrddocto = STRING(bcrapcob.dsdoccop)
           tt-remessa-dda.cdespeci = aux_cddespec
           tt-remessa-dda.dtemissa = INTE(STRING(YEAR(bcrapcob.dtmvtolt),"9999") +
                                      STRING(MONTH(bcrapcob.dtmvtolt), "99") +
                                      STRING(DAY(bcrapcob.dtmvtolt), "99"))
           tt-remessa-dda.nrdiapro = (IF par_flgdprot = TRUE THEN
                                         bcrapcob.qtdiaprt
                                      ELSE ?)
           tt-remessa-dda.tpdepgto = 3 /* vencto indeterminado */
           tt-remessa-dda.dtlipgto = (IF par_flgdprot = TRUE THEN
                     INTE(STRING(YEAR(par_dtvencto + bcrapcob.qtdiaprt),"9999") +
                          STRING(MONTH(par_dtvencto + bcrapcob.qtdiaprt), "99") + 
                          STRING(DAY(par_dtvencto + bcrapcob.qtdiaprt), "99"))
                     ELSE
                     INTE(STRING(YEAR(par_dtvencto + 15),"9999") +
                          STRING(MONTH(par_dtvencto + 15), "99") + 
                          STRING(DAY(par_dtvencto + 15), "99")))
           tt-remessa-dda.indnegoc = "N"
           tt-remessa-dda.vlrabati =  par_vlabatim 
           tt-remessa-dda.dtdjuros = (IF bcrapcob.vljurdia > 0 THEN
                                      INTE(STRING(YEAR(par_dtvencto + 1),"9999")+
                                           STRING(MONTH(par_dtvencto + 1), "99")+
                                           STRING(DAY(par_dtvencto + 1), "99"))
                                      ELSE ?)
           tt-remessa-dda.dsdjuros = aux_dsdjuros
           tt-remessa-dda.vlrjuros = (IF bcrapcob.vljurdia > 0 THEN
                                      bcrapcob.vljurdia ELSE 0)
           tt-remessa-dda.dtdmulta = (IF bcrapcob.tpdmulta = 3 THEN ?
                                      ELSE
                                      INTE(STRING(YEAR(par_dtvencto + 1),"9999")+
                                      STRING(MONTH(par_dtvencto + 1), "99")+
                                      STRING(DAY(par_dtvencto + 1), "99")))
           tt-remessa-dda.cddmulta = (IF bcrapcob.tpdmulta = 3 THEN "3"
                                      ELSE STRING(bcrapcob.tpdmulta))
           tt-remessa-dda.vlrmulta = (IF bcrapcob.tpdmulta = 3 THEN 0
                                      ELSE bcrapcob.vlrmulta)
           tt-remessa-dda.flgaceit = (IF bcrapcob.flgaceit THEN "S"
                                      ELSE "N")
           tt-remessa-dda.dtddesct = (IF par_vldescto > 0 THEN
                                      INTE(
                                        STRING(YEAR(par_dtvencto),"9999") +
                                        STRING(MONTH(par_dtvencto),"99") +
                                        STRING(DAY(par_dtvencto),"99"))
                                      ELSE ?)
           tt-remessa-dda.cdddesct = (IF par_vldescto > 0 THEN "1" ELSE "0")
           tt-remessa-dda.vlrdesct = par_vldescto
           tt-remessa-dda.dsinstru = aux_dsdinstr
           /* regra nova da CIP - titulos emitidos apos 17/03/2012 sao 
              registrados com tipo de calculo "01" (Rafael) */
           tt-remessa-dda.tpmodcal = (IF bcrapcob.dtmvtolt >= 03/17/2012 THEN 
               "01" ELSE "00")
           /* regra nova da CIP - titulos emitidos apos 17/03/2012 sao 
              registrados Indicador Alteracao Valor "S" (Rafael) */
           tt-remessa-dda.flavvenc = (IF bcrapcob.dtmvtolt >= 03/17/2012 THEN 
               "S" ELSE "L").

    RETURN "OK".
END.



PROCEDURE p_calc_codigo_barras:

    DEF INPUT  PARAM par_dtvencto       AS DATE                          NO-UNDO.
    DEF OUTPUT PARAM par_codbarras      AS CHAR                          NO-UNDO.

    DEF VAR aux                         AS CHAR                          NO-UNDO.
    DEF VAR dtini                       AS DATE INIT "10/07/1997"        NO-UNDO.

    DEF VAR aux_ftvencto                AS INTE                          NO-UNDO.

    IF bcrapcob.dtvencto >= DATE("22/02/2025") THEN
	   aux_ftvencto = (bcrapcob.dtvencto - DATE("22/02/2025")) + 1000.
	ELSE
	   aux_ftvencto = (bcrapcob.dtvencto - dtini).

    ASSIGN aux = STRING(bcrapcob.cdbandoc,"999")
                           + "9" /* moeda */
                           + "1" /* nao alterar - constante */
                           + STRING(aux_ftvencto, "9999")
                           + STRING(bcrapcob.vltitulo * 100, "9999999999")
                           + STRING(bcrapcob.nrcnvcob, "999999")
                           + STRING(bcrapcob.nrnosnum, "99999999999999999")
                           + STRING(bcrapcob.cdcartei, "99")
               glb_nrcalcul = DECI(aux).

    RUN fontes/digcbtit.p.
        ASSIGN par_codbarras = STRING(glb_nrcalcul, 
           "99999999999999999999999999999999999999999999").
        
END PROCEDURE.

/*............................................................................*/

PROCEDURE verifica-existencia-instrucao:

    DEF  INPUT PARAM par_idregcob AS ROWID                          NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.


    FIND FIRST crapcob WHERE ROWID(crapcob) = par_idregcob 
         EXCLUSIVE-LOCK NO-ERROR.

    FOR EACH craprem WHERE craprem.cdcooper = crapcob.cdcooper
                       AND craprem.nrcnvcob = crapcob.nrcnvcob
                       AND craprem.nrdconta = crapcob.nrdconta
                       AND craprem.nrdocmto = crapcob.nrdocmto
                       AND craprem.dtaltera = par_dtmvtolt
                       AND (craprem.cdocorre = 4 OR
                            craprem.cdocorre = 5 OR
                            craprem.cdocorre = 6)
        NO-LOCK:


        FIND FIRST crapoco WHERE crapoco.cdcooper = craprem.cdcooper
                             AND crapoco.cddbanco = 1 /* Apenas quando Bco 1 */
                             AND crapoco.cdocorre = craprem.cdocorre
                             AND crapoco.tpocorre = 1
            NO-LOCK NO-ERROR.

        IF  craprem.cdocorre = 4 THEN
            /* Excluiu abatimento, Zera abatimento */
            ASSIGN crapcob.vlabatim = 0.
        ELSE
        IF  craprem.cdocorre = 6 THEN
            DO:
                /* Excluiu Prorrogacao, volta Vencto anterior */
                FIND LAST crapcpr
                    WHERE crapcpr.cdcooper = craprem.cdcooper
                      AND crapcpr.nrdconta = craprem.nrdconta
                      AND crapcpr.nrdocmto = craprem.nrdocmto
                      AND crapcpr.nrcnvcob = craprem.nrcnvcob
                      AND crapcpr.dtvctonv = craprem.dtdprorr
                    NO-LOCK NO-ERROR.
                
                IF  AVAIL crapcpr THEN
                    ASSIGN crapcob.dtvencto = crapcpr.dtvctori.

            END.

        /*** AQUI LOG de Processo ***/
        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT 'Exclusao Instrucao ' +
                                     TRIM(crapoco.dsocorre)).


        /** Exclui o Instrucao de Remessa **/
        RUN pi-elimina-remessa (INPUT craprem.cdcooper,
                                INPUT craprem.nrdconta,
                                INPUT craprem.nrcnvcob,
                                INPUT craprem.nrdocmto,
                                INPUT craprem.cdocorre,
                                INPUT craprem.dtaltera,
                               OUTPUT ret_dsinserr).

        IF  ret_dsinserr <> "" THEN
            RETURN "NOK".

    END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE inst-pedido-baixa:

    /* 02. Pedido de Baixa */
    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.  
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lat-consolidada. 

    DEF VAR aux_cdmotivo AS CHAR                                    NO-UNDO. 

    DEF VAR aux_cdcritic AS INTE                                    NO-UNDO.
    DEF VAR aux_dscritic AS CHAR                                    NO-UNDO.

    IF NOT AVAIL(crapdat) THEN
        FIND FIRST crapdat WHERE crapdat.cdcooper = par_cdcooper
             NO-LOCK NO-ERROR.

    /* Processo de Validacao Recusas Padrao */
    RUN efetua-validacao-recusa-padrao (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrcnvcob,
                                        INPUT par_nrdocmto,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                        INPUT "02",
                                        INPUT par_nrremass,
                                        OUTPUT ret_dsinserr).

    IF RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
    
    IF bcrapcob.cdbandoc = 085  AND
       bcrapcob.flgregis = TRUE AND 
       bcrapcob.flgcbdda AND 
       bcrapcob.insitpro <= 2 THEN
        DO:
            RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "XA",     /* Motivo */
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Titulo em processo de registro. Favor aguardar".
            RETURN "NOK".
        END.
    
    /***** VALIDACOES PARA RECUSAR ******/
    CASE bcrapcob.incobran:

        WHEN 3 THEN DO:
            IF  bcrapcob.insitcrt <> 5 THEN
                IF bcrapcob.dtdbaixa <> ? THEN
                DO:
                    RUN prepara-retorno-cooperado
                                 (INPUT ROWID(bcrapcob),
                                  INPUT 26,     /* Instrucao Rejeitada */
                                  INPUT "A7",   /* "Titulo ja se encontra na situacaoo Pretendida " */ 
                                  INPUT 0,      /* Valor Tarifa */
                                  INPUT crapcop.cdbcoctl,
                                  INPUT crapcop.cdagectl,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdoperad,
                                  INPUT par_nrremass).

                    ret_dsinserr = "Boleto Baixado - Baixa nao efetuada!".
                    RETURN "NOK".
                END.
        END.

    END CASE.

    /* Verifica se ja existe Pedido de Baixa */
    FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper
                        AND crapcre.nrcnvcob = par_nrcnvcob
                        AND crapcre.dtmvtolt = par_dtmvtolt
                        AND crapcre.intipmvt = 1
                        NO-LOCK NO-ERROR.

    IF  AVAIL crapcre THEN
        DO:
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.cdocorre = 2
                                AND craprem.dtaltera = par_dtmvtolt
                NO-LOCK NO-ERROR.
            IF  AVAIL craprem THEN
                DO:
                    RUN prepara-retorno-cooperado
                                 (INPUT ROWID(bcrapcob),
                                  INPUT 26,  /* Instrucao Rejeitada */
                                  INPUT "XB",  /* Motivo */
                                  INPUT 0,   /* Valor Tarifa */
                                  INPUT crapcop.cdbcoctl,
                                  INPUT crapcop.cdagectl,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdoperad,
                                  INPUT par_nrremass).

                    ret_dsinserr = "Pedido de Baixa ja efetuado - Baixa nao efetuada!".
                    RETURN "NOK".
                END.
        END.
    /***** FIM - VALIDACOES PARA RECUSAR ******/

    IF  bcrapcob.flgcbdda AND
        bcrapcob.cdbandoc = crapcop.cdbcoctl THEN
        DO:
            RUN procedimentos-dda-jd ( INPUT  "B",
                                       INPUT  "2",
                                       INPUT bcrapcob.dtvencto,
                                       INPUT bcrapcob.vldescto,
                                       INPUT bcrapcob.vlabatim,
                                       INPUT bcrapcob.flgdprot,
                                      OUTPUT ret_dsinserr).
        
            IF  RETURN-VALUE <> "OK"  THEN DO:
            
                RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "XC",     /* Motivo */
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

                RETURN "NOK".
            END.
        END.

    /* tratamento para titulos migrados */
    IF  bcrapcob.flgregis = TRUE AND
        bcrapcob.cdbandoc = 001  THEN
        DO:
            FIND crapcco WHERE 
                 crapcco.cdcooper = bcrapcob.cdcooper AND
                 crapcco.nrconven = bcrapcob.nrcnvcob 
                 NO-LOCK NO-ERROR.

            IF  AVAIL crapcco THEN
                DO:
                   IF  CAN-DO("MIGRACAO,INCORPORACAO", crapcco.dsorgarq) THEN
                        DO:
                            RUN inst-titulo-migrado (INPUT "Baixa", 
                                                     INPUT ?, 
                                                     INPUT 0).
                            
                            ret_dsinserr = "Solicitacao de baixa de titulo " + 
                                           "migrado. Aguarde confirmacao no " + 
                                           "proximo dia util.".
                            
                            RETURN "NOK".
                        END.
                END.
        END.

    DO TRANSACTION:
        
        FIND CURRENT bcrapcob EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        FIND LAST tt-remessa-dda NO-LOCK NO-ERROR.
        
        ASSIGN bcrapcob.idopeleg = tt-remessa-dda.idopeleg WHEN AVAIL tt-remessa-dda.
        
        /** Verifica se ja existe instr. Abat. / Canc. Abat. / Alt. Vencto **/                                                       
        RUN verifica-existencia-instrucao ( INPUT ROWID(bcrapcob),
                                            INPUT par_dtmvtolt,
                                            INPUT par_cdoperad,
                                           OUTPUT ret_dsinserr).
        IF  ret_dsinserr <> "" THEN DO:
        
            RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "XD",     /* Motivo */
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

            RETURN "NOK".
        END.

        IF par_cdoperad = "996" THEN DO:
            IF par_nrremass <> 0 THEN
                aux_cdmotivo = "10". /* 10 - Comandada Cliente Arquivo */
            ELSE
                aux_cdmotivo = "11". /* 11 - Comandada Cliente On-line */
        END.
        ELSE
            aux_cdmotivo = "09". /* 09 - Comandada Banco */

        IF  bcrapcob.cdbandoc = 1 THEN
            DO:
                RUN prep-remessa-banco( INPUT bcrapcob.cdcooper,
                                        INPUT bcrapcob.nrcnvcob,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                       OUTPUT aux_nrremret,
                                       OUTPUT aux_nrseqreg).
                
                /* Verifica se ja existe Remessa de titulo no dia */
                FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                    AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                    AND craprem.nrdconta = bcrapcob.nrdconta
                                    AND craprem.nrdocmto = bcrapcob.nrdocmto
                                    AND craprem.nrremret = aux_nrremret
                                    AND craprem.cdocorre = 1
                                    EXCLUSIVE-LOCK NO-ERROR.

                IF  AVAIL craprem THEN
                    DO:
                        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT "Titulo excluido da Remessa BB").
                        
                        /* excluir titulo da remessa BB */
                        DELETE craprem.
                        
                        /* tornar o titulo baixado */
                        ASSIGN bcrapcob.incobran = 3
                               bcrapcob.dtdbaixa = par_dtmvtolt.
                        
                    END.            
                ELSE
                    DO:
                        /* verificar se titulo BB tem confirmacao de entrada */
                        IF  AVAIL bcrapcob THEN
                            DO:
                                IF  bcrapcob.cdbandoc = 001 THEN
                                    DO:
                                        RUN verifica-ent-confirmada 
                                            (OUTPUT ret_dsinserr).
        
                                        IF  RETURN-VALUE = "NOK" THEN
                                            RETURN "NOK".
                                    END.
                            END.

                        IF  bcrapcob.incobran = 0            AND
                            bcrapcob.dtvencto < par_dtmvtolt AND
                           (bcrapcob.insitcrt = 1  OR
                            bcrapcob.insitcrt = 2  OR
                            bcrapcob.insitcrt = 3) THEN
                            DO:
                        
                                aux_nrseqreg = aux_nrseqreg + 1.
                                RUN cria-tab-remessa( ROWID(bcrapcob),
                                   /* nrremret */     aux_nrremret,
                                   /* nrseqreg */     aux_nrseqreg,
                                   /* cdocorre */     10, /* Sustar e Baixar */
                                   /* cdmotivo */     "", 
                                   /* dtdprorr */     ?,
                                   /* vlabatim */     0,
                                   /* cdoperad */     par_cdoperad,
                                   /* dtmvtolt */     par_dtmvtolt).
                                
                            END.
        
                        aux_nrseqreg = aux_nrseqreg + 1.
                        RUN cria-tab-remessa( ROWID(bcrapcob),
                           /* nrremret */     aux_nrremret,
                           /* nrseqreg */     aux_nrseqreg,
                           /* cdocorre */     par_cdocorre, /* 2. Pedido de Baixa */
                           /* cdmotivo */     "", 
                           /* dtdprorr */     ?,
                           /* vlabatim */     0,
                           /* cdoperad */     par_cdoperad,
                           /* dtmvtolt */     par_dtmvtolt).

                    END. /* FIM do IF se existe remessa BB */

                /* Verifica se existe Instr de Protesto no dia */
                FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                    AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                    AND craprem.nrdconta = bcrapcob.nrdconta
                                    AND craprem.nrdocmto = bcrapcob.nrdocmto
                                    AND craprem.nrremret = aux_nrremret
                                    AND craprem.cdocorre = 9 /* protestar */
                                    EXCLUSIVE-LOCK NO-ERROR.

                IF  AVAIL craprem THEN
                    DO:
                        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT "Instr de Protesto excluido da Remessa BB").

                        /* excluir titulo da remessa BB */
                        DELETE craprem.

                        aux_nrseqreg = aux_nrseqreg + 1.
                        RUN cria-tab-remessa( ROWID(bcrapcob),
                           /* nrremret */     aux_nrremret,
                           /* nrseqreg */     aux_nrseqreg,
                           /* cdocorre */     10, /* Sustar e Baixar */
                           /* cdmotivo */     "", 
                           /* dtdprorr */     ?,
                           /* vlabatim */     0,
                           /* cdoperad */     par_cdoperad,
                           /* dtmvtolt */     par_dtmvtolt).

                        aux_nrseqreg = aux_nrseqreg + 1.
                        RUN cria-tab-remessa( ROWID(bcrapcob),
                           /* nrremret */     aux_nrremret,
                           /* nrseqreg */     aux_nrseqreg,
                           /* cdocorre */     par_cdocorre, /* 2. Pedido de Baixa */
                           /* cdmotivo */     "", 
                           /* dtdprorr */     ?,
                           /* vlabatim */     0,
                           /* cdoperad */     par_cdoperad,
                           /* dtmvtolt */     par_dtmvtolt).

                    END. /* FIM do IF se existe Instr de Protesto no dia */
    
            END. /* FIM do IF cdbandoc = 1 */
        ELSE 
            IF  bcrapcob.cdbandoc = crapcop.cdbcoctl THEN 
                DO:
                    ASSIGN bcrapcob.incobran = 3
                           bcrapcob.dtdbaixa = par_dtmvtolt.
                    
                    IF bcrapcob.inemiten = 3 AND 
                       bcrapcob.dtmvtolt = crapdat.dtmvtolt AND 
                       bcrapcob.inemiexp = 1 THEN
                    DO:
                        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                                       INPUT par_cdoperad,
                                       INPUT par_dtmvtolt,
                                       INPUT "Inst Baixa - sem informacao de retorno").
                    END.
                    ELSE DO:
                        RUN prepara-retorno-cooperado
                                         (INPUT ROWID(bcrapcob),
                                          INPUT 9,              /* Baixa */
                                          INPUT aux_cdmotivo,   /* Motivo */
                                          INPUT 0,              /* Valor Tarifa */
                                          INPUT crapcop.cdbcoctl,
                                          INPUT crapcop.cdagectl,
                                          INPUT par_dtmvtolt,
                                          INPUT par_cdoperad,
                                          INPUT par_nrremass).
                    END.
    
                END. /* FIM do IF cdbandoc = 85 */

        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT "Instrucao de Baixa").

        IF bcrapcob.inemiten = 3 AND 
           bcrapcob.dtmvtolt = crapdat.dtmvtolt AND 
           bcrapcob.inemiexp = 1 THEN 
        DO:

            RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                           INPUT par_cdoperad,
                           INPUT par_dtmvtolt,
                           INPUT "Titulo excluido da remessa a PG").

            ASSIGN bcrapcob.inemiexp = 0.

        END.


        IF bcrapcob.cdbandoc = 85 THEN DO:

            /* nao gerar tarifa de baixa qdo boleto Cooperativa/EE
               e nao transmitido para a PG */
            IF  bcrapcob.inemiten = 3 AND 
                bcrapcob.dtmvtolt = crapdat.dtmvtolt AND 
                bcrapcob.inemiexp = 1 THEN DO:

                RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT "Inst Baixa - nao sera cobrado tarifa de baixa").

            END.
            ELSE DO:
                CREATE tt-lat-consolidada.
                ASSIGN tt-lat-consolidada.cdcooper = par_cdcooper
                       tt-lat-consolidada.nrdconta = par_nrdconta
                       tt-lat-consolidada.nrdocmto = par_nrdocmto
                       tt-lat-consolidada.nrcnvcob = par_nrcnvcob
                       tt-lat-consolidada.dsincide = "RET"
                       tt-lat-consolidada.cdocorre = 09             /* 09 - Baixa */
                       tt-lat-consolidada.cdmotivo = aux_cdmotivo   /* Motivo */
                       tt-lat-consolidada.vllanmto = bcrapcob.vltitulo.

            END.

        END.

        /* Caso o CRAPCOB.INSERASA for diferente de 0 (Não negativado) e 3 (Pendente Envio Cancel) e 4 (Pendente Cancel) e 6 (Recusada Serasa) e
        deve-se Cancelar Negaticacao Serasa. */

        IF bcrapcob.inserasa <> 0 AND
           bcrapcob.inserasa <> 3 AND
           bcrapcob.inserasa <> 4 AND
           bcrapcob.inserasa <> 6 THEN
        DO:
            RUN pc_cancelar_neg_serasa (INPUT par_cdcooper,
                                        INPUT par_nrcnvcob,
                                        INPUT par_nrdconta,
                                        INPUT par_nrdocmto,
                                        OUTPUT aux_cdcritic,
                                        OUTPUT aux_dscritic).
        END.
        
        

    END. /* END-TRANSACTION */

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/
/******************************************************************************
     Efetuar a baixa do titulo por decurso de prazo (utilizado no crps538)
******************************************************************************/ 
PROCEDURE inst-pedido-baixa-decurso:

    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lat-consolidada.

    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    FIND FIRST crapcco WHERE crapcco.cdcooper = par_cdcooper
                         AND crapcco.nrconven = par_nrcnvcob
                         NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcco THEN DO:
        ret_dsinserr = "Registro de cobranca nao encontrado".
        RETURN "NOK".
    END.

    FIND FIRST bcrapcob WHERE bcrapcob.cdcooper = par_cdcooper
                          AND bcrapcob.cdbandoc = crapcco.cddbanco
                          AND bcrapcob.nrdctabb = crapcco.nrdctabb
                          AND bcrapcob.nrdconta = par_nrdconta
                          AND bcrapcob.nrcnvcob = par_nrcnvcob
                          AND bcrapcob.nrdocmto = par_nrdocmto
                          NO-LOCK NO-ERROR.

    IF  NOT AVAIL bcrapcob  THEN
        DO:
            ret_dsinserr = "Registro de cobranca nao encontrado".
            RETURN "NOK".
        END.
    
    /***** VALIDACOES PARA RECUSAR ******/
    CASE bcrapcob.incobran:

        WHEN 3 THEN DO:
            IF  bcrapcob.insitcrt <> 5 THEN
                ret_dsinserr = "Boleto Baixado - Baixa nao efetuada!".
            ELSE
                ret_dsinserr = "Boleto Protestado - Baixa nao efetuada!".
            RETURN "NOK".
        END.
        WHEN 5 THEN DO: 
            ret_dsinserr = "Boleto Liquidado - Baixa nao efetuada!".
            RETURN "NOK".
        END.

    END CASE.

    /* Verifica se ja existe Pedido de Baixa */
    FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper
                        AND crapcre.nrcnvcob = par_nrcnvcob
                        AND crapcre.dtmvtolt = par_dtmvtolt
                        AND crapcre.intipmvt = 1
                        NO-LOCK NO-ERROR.

    IF  AVAIL crapcre THEN 
        DO:
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.cdocorre = 2
                                AND craprem.dtaltera = par_dtmvtolt
                NO-LOCK NO-ERROR.

            IF  AVAIL craprem THEN
                DO:
                    ret_dsinserr = "Pedido de Baixa ja efetuado - Baixa nao efetuada!".
                    RETURN "NOK".
                END.
        END.
    /***** FIM - VALIDACOES PARA RECUSAR ******/

    IF  bcrapcob.flgcbdda AND
        bcrapcob.cdbandoc = crapcop.cdbcoctl THEN
        DO:
            RUN procedimentos-dda-jd ( INPUT "B",
                                       INPUT STRING(par_cdocorre),
                                       INPUT bcrapcob.dtvencto,
                                       INPUT bcrapcob.vldescto,
                                       INPUT bcrapcob.vlabatim,
                                       INPUT bcrapcob.flgdprot,
                                      OUTPUT ret_dsinserr).
        
            IF  RETURN-VALUE <> "OK"  THEN
                RETURN "NOK".
        
        END.

    DO TRANSACTION:
        
        FIND CURRENT bcrapcob EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        FIND LAST tt-remessa-dda NO-LOCK NO-ERROR.
        
        ASSIGN bcrapcob.idopeleg = tt-remessa-dda.idopeleg WHEN AVAIL tt-remessa-dda.
        

        /** Verifica se ja existe instr. Abat. / Canc. Abat. / Alt. Vencto **/                                                       
        RUN verifica-existencia-instrucao ( INPUT ROWID(bcrapcob),
                                            INPUT par_dtmvtolt,
                                            INPUT par_cdoperad,
                                           OUTPUT ret_dsinserr).
        IF  ret_dsinserr <> "" THEN
            UNDO, RETURN "NOK".

        IF  bcrapcob.cdbandoc = 1 THEN
            DO:
                RUN prep-remessa-banco( INPUT bcrapcob.cdcooper,
                                        INPUT bcrapcob.nrcnvcob,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                       OUTPUT aux_nrremret,
                                       OUTPUT aux_nrseqreg).
                
                IF  bcrapcob.incobran = 0            AND
                    bcrapcob.dtvencto < par_dtmvtolt AND
                   (bcrapcob.insitcrt = 2  OR
                    bcrapcob.insitcrt = 3) THEN
                    DO:
                        aux_nrseqreg = aux_nrseqreg + 1.
                        RUN cria-tab-remessa( ROWID(bcrapcob),
                           /* nrremret */     aux_nrremret,
                           /* nrseqreg */     aux_nrseqreg,
                           /* cdocorre */     10, /* Sustar e Baixar */
                           /* cdmotivo */     "", 
                           /* dtdprorr */     ?,
                           /* vlabatim */     0,
                           /* cdoperad */     par_cdoperad,
                           /* dtmvtolt */     par_dtmvtolt).
                        
                    END.
                
                aux_nrseqreg = aux_nrseqreg + 1.
                RUN cria-tab-remessa( ROWID(bcrapcob),
                   /* nrremret */     aux_nrremret,
                   /* nrseqreg */     aux_nrseqreg,
                   /* cdocorre */     par_cdocorre, 
                   /* cdmotivo */     "", 
                   /* dtdprorr */     ?,
                   /* vlabatim */     0,
                   /* cdoperad */     par_cdoperad,
                   /* dtmvtolt */     par_dtmvtolt).
                
            END. /* FIM do IF cdbandoc = 1 */
        ELSE 
            IF  bcrapcob.cdbandoc = crapcop.cdbcoctl THEN 
                DO:
                    ASSIGN bcrapcob.incobran = 3
                           bcrapcob.dtdbaixa = par_dtmvtolt.
                    
                    RUN prepara-retorno-cooperado
                                     (INPUT ROWID(bcrapcob),
                                      INPUT 09,     /* Baixa */
                                      INPUT "13",   /* Decurso Prazo */
                                      INPUT 0,      /* Valor Tarifa */
                                      INPUT crapcop.cdbcoctl,
                                      INPUT crapcop.cdagectl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_cdoperad,
                                      INPUT par_nrremass).
    
                END. /* FIM do IF cdbandoc = 85 */

        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT "Instrucao de Baixa - Decurso Prazo").

        IF bcrapcob.cdbandoc = 85 THEN DO:

            /* Gerar registro Tarifa */
            CREATE tt-lat-consolidada.
            ASSIGN tt-lat-consolidada.cdcooper = par_cdcooper
                   tt-lat-consolidada.nrdconta = par_nrdconta
                   tt-lat-consolidada.nrdocmto = par_nrdocmto
                   tt-lat-consolidada.nrcnvcob = par_nrcnvcob
                   tt-lat-consolidada.dsincide = "RET"
                   tt-lat-consolidada.cdocorre = 09    /* 09 - Baixa */
                   tt-lat-consolidada.cdmotivo = "13"  /* 13 - Decurso Prazo */
                   tt-lat-consolidada.vllanmto = bcrapcob.vltitulo.
        END.

    END. /* END-TRANSACTION */

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE inst-conc-abatimento:
    /* 04. Concessao de Abatimento */
    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vlabatim AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lat-consolidada.

    DEF          VAR aux_vltitabr AS DECI                           NO-UNDO.

    /* Processo de Validacao Recusas Padrao */
    RUN efetua-validacao-recusa-padrao (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrcnvcob,
                                        INPUT par_nrdocmto,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                        INPUT "04",
                                        INPUT par_nrremass,
                                        OUTPUT ret_dsinserr).

    IF RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
    

    IF bcrapcob.cdbandoc = 085  AND
       bcrapcob.flgregis = TRUE AND 
       bcrapcob.flgcbdda AND 
       bcrapcob.insitpro <= 2 THEN
        DO:
            RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "XA",     /* Motivo */
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Titulo em processo de registro. Favor aguardar".
            RETURN "NOK".
        END.

    /***** VALIDACOES PARA RECUSAR ******/
    
    /* Verifica se ja existe Pedido de Baixa */
    FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper
                        AND crapcre.nrcnvcob = par_nrcnvcob
                        AND crapcre.dtmvtolt = par_dtmvtolt
                        AND crapcre.intipmvt = 1
                        NO-LOCK NO-ERROR.

    IF  AVAIL crapcre THEN
        DO:
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.cdocorre = 2
                                AND craprem.dtaltera = par_dtmvtolt
                NO-LOCK NO-ERROR.
            IF  AVAIL craprem THEN
                DO:
                    RUN prepara-retorno-cooperado
                                 (INPUT ROWID(bcrapcob),
                                  INPUT 26,     /* Instrucao Rejeitada */
                                  INPUT "XB",     /* Motivo */
                                  INPUT 0,      /* Valor Tarifa */
                                  INPUT crapcop.cdbcoctl,
                                  INPUT crapcop.cdagectl,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdoperad,
                                  INPUT par_nrremass).
                    
                    ret_dsinserr = "Pedido de Baixa ja efetuado - " +
                                   "Abatimento nao efetuado!".
                    RETURN "NOK".
                END.
        END.

    CASE bcrapcob.insitcrt:
        WHEN 1 THEN DO:

            RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "XE",     /* Motivo */
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto c/ Remessa a Cartorio - " + 
                           "Abatimento nao efetuado!".
            RETURN "NOK".
        END.
        WHEN 3 THEN DO: 

            RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "XF",     /* Motivo */
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto Em Cartorio - Abatimento nao efetuado!".
            RETURN "NOK".
        END.

    END CASE.

    aux_vltitabr = bcrapcob.vltitulo - bcrapcob.vldescto - bcrapcob.vlabatim.

    IF  par_vlabatim > aux_vltitabr THEN
        DO:
            RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "34",   /* "Valor do Abatimento Maior ou Igual ao Valor do Titulo" */ 
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Valor de Abatimento superior ao Valor do Boleto - " +
                           "Abatimento nao efetuado!".
            RETURN "NOK".
        END.

    /* Nao permitir conceder abatimento de titulo no convenio de protesto */
    IF (bcrapcob.cdbandoc <> crapcop.cdbcoctl) THEN
        DO:
            FIND FIRST crapcco 
                 WHERE crapcco.cdcooper = bcrapcob.cdcooper
                   AND crapcco.nrconven = bcrapcob.nrcnvcob
                   NO-LOCK NO-ERROR.
        
            IF AVAIL crapcco THEN
               IF crapcco.dsorgarq = "PROTESTO" THEN
                   DO:
                      RUN prepara-retorno-cooperado
                                     (INPUT ROWID(bcrapcob),
                                      INPUT 26,     /* Instrucao Rejeitada */
                                      INPUT "XG",     /* Motivo */
                                      INPUT 0,      /* Valor Tarifa */
                                      INPUT crapcop.cdbcoctl,
                                      INPUT crapcop.cdagectl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_cdoperad,
                                      INPUT par_nrremass). 

                      ret_dsinserr = "Nao e permitido conceder " + 
                          "abatimento de boleto no convenio " + 
                          "protesto - Abatimento nao efetuado!".

                      RETURN "NOK".
                   END.
        END.

    /***** FIM - VALIDACOES PARA RECUSAR ******/

    IF  bcrapcob.flgcbdda AND
        bcrapcob.cdbandoc = crapcop.cdbcoctl  THEN
        DO:
            /* Executa procedimentos do DDA-JD */
            RUN procedimentos-dda-jd ( INPUT "A",
                                       INPUT "",
                                       INPUT bcrapcob.dtvencto,
                                       INPUT bcrapcob.vldescto,
                                       INPUT par_vlabatim,
                                       INPUT bcrapcob.flgdprot,
                                      OUTPUT ret_dsinserr).
    
            IF  RETURN-VALUE <> "OK"  THEN DO:
            
                RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "XC",     /* Motivo */
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

                RETURN "NOK".
            END.
        END.

    /* tratamento para titulos migrados */
    IF  bcrapcob.flgregis = TRUE AND
        bcrapcob.cdbandoc = 001  THEN
        DO:
            FIND crapcco WHERE 
                 crapcco.cdcooper = bcrapcob.cdcooper AND
                 crapcco.nrconven = bcrapcob.nrcnvcob 
                 NO-LOCK NO-ERROR.

            IF  AVAIL crapcco THEN
                DO:
                   IF  CAN-DO("MIGRACAO,INCORPORACAO", crapcco.dsorgarq) THEN
                        DO:
                            RUN inst-titulo-migrado (INPUT "Abatimento", 
                                                     INPUT ?, 
                                                     INPUT par_vlabatim).
                            
                            ret_dsinserr = "Solicitacao de abatimento de titulo " + 
                                           "migrado. Aguarde confirmacao no " + 
                                           "proximo dia util.".
                            RETURN "NOK".
                        END.
                END.
        END.


    DO TRANSACTION:

        FIND CURRENT bcrapcob EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
        FIND LAST tt-remessa-dda NO-LOCK NO-ERROR.

        ASSIGN bcrapcob.vlabatim = par_vlabatim
               bcrapcob.idopeleg = tt-remessa-dda.idopeleg
                                        WHEN AVAIL tt-remessa-dda.
    
        IF  bcrapcob.cdbandoc = 1 THEN
            DO:
                /** Verifica se ha instr. de Canc. Abatim. no dia e elimina **/
                FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                    AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                    AND craprem.nrdconta = bcrapcob.nrdconta
                                    AND craprem.nrdocmto = bcrapcob.nrdocmto
                                    AND craprem.cdocorre = 5
                                    AND craprem.dtaltera = par_dtmvtolt
                    NO-LOCK NO-ERROR.

                IF  AVAIL craprem THEN
                    DO:
                        /*** LOG de Processo ***/
                        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT 'Exclusao Instrucao ' +
                                                     'Cancelamento de Abatimento').
                        
                        /** Exclui o Instrucao de Remessa que ja existe **/
                        RUN pi-elimina-remessa (INPUT craprem.cdcooper,
                                                INPUT craprem.nrdconta,
                                                INPUT craprem.nrcnvcob,
                                                INPUT craprem.nrdocmto,
                                                INPUT craprem.cdocorre,
                                                INPUT craprem.dtaltera,
                                               OUTPUT ret_dsinserr).
                        IF  ret_dsinserr <> "" THEN
                            RETURN "NOK".
                    END.

                /* Verifica se ja existe Instr.Conc.Abatimento e substitui */
                FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                    AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                    AND craprem.nrdconta = bcrapcob.nrdconta
                                    AND craprem.nrdocmto = bcrapcob.nrdocmto
                                    AND craprem.cdocorre = par_cdocorre /* 4. */
                                    AND craprem.dtaltera = par_dtmvtolt
                    NO-LOCK NO-ERROR.

                IF  AVAIL craprem THEN
                    DO:
                        /*** LOG de Processo ***/
                        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT 'Exclusao Instr.Conc.Abatimento ' +
                                                     'Vlr: R$ ' +
                                               TRIM(STRING(craprem.vlabatim,"zzz9.99"))).
                        
                        /** Exclui o Instrucao de Remessa que ja existe **/
                        RUN pi-elimina-remessa (INPUT craprem.cdcooper,
                                                INPUT craprem.nrdconta,
                                                INPUT craprem.nrcnvcob,
                                                INPUT craprem.nrdocmto,
                                                INPUT craprem.cdocorre,
                                                INPUT craprem.dtaltera,
                                               OUTPUT ret_dsinserr).
                        IF  ret_dsinserr <> "" THEN
                            RETURN "NOK".
                        
                    END.

                RUN prep-remessa-banco( INPUT bcrapcob.cdcooper,
                                        INPUT bcrapcob.nrcnvcob,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                       OUTPUT aux_nrremret,
                                       OUTPUT aux_nrseqreg).
        
                aux_nrseqreg = aux_nrseqreg + 1.
                RUN cria-tab-remessa( ROWID(bcrapcob),
                   /* nrremret */     aux_nrremret,
                   /* nrseqreg */     aux_nrseqreg,
                   /* cdocorre */     par_cdocorre, /* 4. Conc. Abatimento */
                   /* cdmotivo */     "", 
                   /* dtdprorr */     ?,
                   /* vlabatim */     par_vlabatim,
                   /* cdoperad */     par_cdoperad,
                   /* dtmvtolt */     par_dtmvtolt).
    
            END. /* FIM do IF cdbandoc = 1 */
        ELSE 
            IF  bcrapcob.cdbandoc = crapcop.cdbcoctl THEN 
                DO:
        
                    RUN prepara-retorno-cooperado
                                     (INPUT ROWID(bcrapcob),
                                      INPUT 12,   /* Conf. Receb. Instr. Abatimento */
                                      INPUT "",   /* Motivo */
                                      INPUT 0,    /* Valor Tarifa */
                                      INPUT crapcop.cdbcoctl,
                                      INPUT crapcop.cdagectl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_cdoperad,
                                      INPUT par_nrremass).
            
                END. /* FIM do IF cdbandoc = 85 */

        /*** LOG de Processo ***/
        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT 'Concessao de Abatimento Vlr: R$ ' +
                                      TRIM(STRING(par_vlabatim,"zzz9.99"))).

        IF bcrapcob.cdbandoc = 85 THEN DO:

            /* Gerar registro Tarifa */
            CREATE tt-lat-consolidada.
            ASSIGN tt-lat-consolidada.cdcooper = par_cdcooper
                   tt-lat-consolidada.nrdconta = par_nrdconta
                   tt-lat-consolidada.nrdocmto = par_nrdocmto
                   tt-lat-consolidada.nrcnvcob = par_nrcnvcob
                   tt-lat-consolidada.dsincide = "RET"
                   tt-lat-consolidada.cdocorre = 12    /* 12 - Conf. Receb. Instr. Abatimento  */
                   tt-lat-consolidada.cdmotivo = ""    /* Motivo */
                   tt-lat-consolidada.vllanmto = bcrapcob.vltitulo.
        END.

    END. /* final da transaction */

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE inst-canc-abatimento:
    /* 05. Cancelar Abatimento */
    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lat-consolidada.

    /* Processo de Validacao Recusas Padrao */
    RUN efetua-validacao-recusa-padrao (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrcnvcob,
                                        INPUT par_nrdocmto,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                        INPUT "05",
                                        INPUT par_nrremass,
                                        OUTPUT ret_dsinserr).

    IF RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    
    IF bcrapcob.cdbandoc = 085  AND
       bcrapcob.flgregis = TRUE AND 
       bcrapcob.flgcbdda AND 
       bcrapcob.insitpro <= 2 THEN
        DO:
            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XA",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Titulo em processo de registro. Favor aguardar".
            RETURN "NOK".
        END.

    /***** VALIDACOES PARA RECUSAR ******/
    
    CASE bcrapcob.insitcrt:
        WHEN 1 THEN DO:

            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XE",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto c/ Remessa a Cartorio - " + 
                           "Canc. Abatim. nao efetuado!".
            RETURN "NOK".
        END.
        WHEN 3 THEN DO: 

            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XF",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto Em Cartorio - Canc. Abatim. nao efetuado!".
            RETURN "NOK".
        END.

    END CASE.

    /* Verifica se ja existe Pedido de Baixa */
    FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper
                        AND crapcre.nrcnvcob = par_nrcnvcob
                        AND crapcre.dtmvtolt = par_dtmvtolt
                        AND crapcre.intipmvt = 1
                        NO-LOCK NO-ERROR.

    IF  AVAIL crapcre THEN
        DO:
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.cdocorre = 2
                                AND craprem.dtaltera = par_dtmvtolt
                                NO-LOCK NO-ERROR.

            IF  AVAIL craprem THEN
                DO:
                    RUN prepara-retorno-cooperado
                    			 (INPUT ROWID(bcrapcob),
                    			  INPUT 26,     /* Instrucao Rejeitada */
                    			  INPUT "XB",     /* Motivo */
                    			  INPUT 0,      /* Valor Tarifa */
                    			  INPUT crapcop.cdbcoctl,
                    			  INPUT crapcop.cdagectl,
                    			  INPUT par_dtmvtolt,
                    			  INPUT par_cdoperad,
                                  INPUT par_nrremass).

                    ret_dsinserr = "Pedido de Baixa ja efetuado - " +
                                   "Canc. Abatim. nao efetuado!".
                    RETURN "NOK".
                END.
        END.

    IF  bcrapcob.vlabatim = 0 THEN
        DO:
            RUN prepara-retorno-cooperado
                			 (INPUT ROWID(bcrapcob),
                			  INPUT 26,     /* Instrucao Rejeitada */
                			  INPUT "A7",   /* "Titulo ja se encontra na situacao Pretendida" */ 
                			  INPUT 0,      /* Valor Tarifa */
                			  INPUT crapcop.cdbcoctl,
                			  INPUT crapcop.cdagectl,
                			  INPUT par_dtmvtolt,
                			  INPUT par_cdoperad,
                              INPUT par_nrremass).

            ret_dsinserr = "Boleto sem Valor de Abatimento - " +
                           "Canc. Abatim. nao efetuado!".
            RETURN "NOK".
        END.
    /***** FIM - VALIDACOES PARA RECUSAR ******/

    IF  bcrapcob.flgcbdda AND
        bcrapcob.cdbandoc = crapcop.cdbcoctl  THEN 
        DO:
            /* Executa procedimentos do DDA-JD */
            RUN procedimentos-dda-jd ( INPUT "A",
                                       INPUT "",
                                       INPUT bcrapcob.dtvencto,
                                       INPUT bcrapcob.vldescto,
                                       INPUT 0,
                                       INPUT bcrapcob.flgdprot,
                                      OUTPUT ret_dsinserr).
        
            IF  RETURN-VALUE <> "OK"  THEN DO:

                RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XC",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).
                RETURN "NOK".
            END.
        END.

    /* tratamento para titulos migrados */
    IF  bcrapcob.flgregis = TRUE AND
        bcrapcob.cdbandoc = 001  THEN
        DO:
            FIND crapcco WHERE 
                 crapcco.cdcooper = bcrapcob.cdcooper AND
                 crapcco.nrconven = bcrapcob.nrcnvcob 
                 NO-LOCK NO-ERROR.

            IF  AVAIL crapcco THEN
                DO:
                    IF  CAN-DO("MIGRACAO,INCORPORACAO", crapcco.dsorgarq) THEN
                        DO:
                            RUN inst-titulo-migrado 
                                (INPUT "Cancelamento de Abatimento", 
                                 INPUT ?, 
                                 INPUT 0).

                            RUN prepara-retorno-cooperado
                            			 (INPUT ROWID(bcrapcob),
                            			  INPUT 26,     /* Instrucao Rejeitada */
                            			  INPUT "XH",     /* Motivo */
                            			  INPUT 0,      /* Valor Tarifa */
                            			  INPUT crapcop.cdbcoctl,
                            			  INPUT crapcop.cdagectl,
                            			  INPUT par_dtmvtolt,
                            			  INPUT par_cdoperad,
                                          INPUT par_nrremass).

                            ret_dsinserr = "Solicitacao de cancelamento de " + 
                                           "abatimento de titulo " + 
                                           "migrado. Aguarde confirmacao no " + 
                                           "proximo dia util.".
                            RETURN "NOK".
                        END.
                END.
        END.


    DO TRANSACTION:

        FIND CURRENT bcrapcob EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        FIND LAST tt-remessa-dda NO-LOCK NO-ERROR.

        ASSIGN bcrapcob.idopeleg = tt-remessa-dda.idopeleg WHEN AVAIL tt-remessa-dda.

        /* Cancela o abatimento concedido anteriormente */
        IF  bcrapcob.vlabatim > 0 THEN
            bcrapcob.vlabatim = 0.
    
        IF  bcrapcob.cdbandoc = 1 THEN 
            DO:
                /* Verifica se tem instrucao de abatimento e exclui */
                FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                    AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                    AND craprem.nrdconta = bcrapcob.nrdconta
                                    AND craprem.nrdocmto = bcrapcob.nrdocmto
                                    AND craprem.cdocorre = 4
                                    AND craprem.dtaltera = par_dtmvtolt
                                    NO-LOCK NO-ERROR.
            
                IF  AVAIL craprem THEN
                    DO:
                        /*** LOG de Processo ***/
                        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT 'Exclusao Instrucao  ' +
                                                     'Concessao de Abatimento').
                        
                        /** Exclui o Instrucao de Remessa que ja existe **/
                        RUN pi-elimina-remessa (INPUT craprem.cdcooper,
                                                INPUT craprem.nrdconta,
                                                INPUT craprem.nrcnvcob,
                                                INPUT craprem.nrdocmto,
                                                INPUT craprem.cdocorre,
                                                INPUT craprem.dtaltera,
                                               OUTPUT ret_dsinserr).
                        
                        IF  ret_dsinserr <> "" THEN
                            RETURN "NOK".
                    END.
            
                /* Verifica se ja existe Instr.Canc.Abatimento e substitui */
                FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                    AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                    AND craprem.nrdconta = bcrapcob.nrdconta
                                    AND craprem.nrdocmto = bcrapcob.nrdocmto
                                    AND craprem.cdocorre = par_cdocorre /* 5. */
                                    AND craprem.dtaltera = par_dtmvtolt
                                    NO-LOCK NO-ERROR.

                IF  AVAIL craprem THEN
                    DO:
                        /*** LOG de Processo ***/
                        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT 'Exclusao Instrucao '+
                                                     'Cancelamento de Abatimento').
                        
                        /** Exclui o Instrucao de Remessa que ja existe **/
                        RUN pi-elimina-remessa (INPUT craprem.cdcooper,
                                                INPUT craprem.nrdconta,
                                                INPUT craprem.nrcnvcob,
                                                INPUT craprem.nrdocmto,
                                                INPUT craprem.cdocorre,
                                                INPUT craprem.dtaltera,
                                               OUTPUT ret_dsinserr).

                        IF  ret_dsinserr <> "" THEN
                            RETURN "NOK".
                        
                    END.
            
                RUN prep-remessa-banco( INPUT bcrapcob.cdcooper,
                                        INPUT bcrapcob.nrcnvcob,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                       OUTPUT aux_nrremret,
                                       OUTPUT aux_nrseqreg).
            
                aux_nrseqreg = aux_nrseqreg + 1.

                RUN cria-tab-remessa( ROWID(bcrapcob),
                   /* nrremret */     aux_nrremret,
                   /* nrseqreg */     aux_nrseqreg,
                   /* cdocorre */     par_cdocorre, /* 5. Canc. Abatimento */
                   /* cdmotivo */     "", 
                   /* dtdprorr */     ?,
                   /* vlabatim */     0,
                   /* cdoperad */     par_cdoperad,
                   /* dtmvtolt */     par_dtmvtolt).
            
            END. /* FIM do IF cdbandoc = 1 */
        ELSE 
            IF  bcrapcob.cdbandoc = crapcop.cdbcoctl THEN 
                DO:
                    RUN prepara-retorno-cooperado
                                     (INPUT ROWID(bcrapcob),
                                      INPUT 13, /* Confirmacao Recebimento Instrucao de Cancelamento Abatimento */
                                      INPUT "", /* Motivo */
                                      INPUT 0,  /* Valor Tarifa */
                                      INPUT crapcop.cdbcoctl,
                                      INPUT crapcop.cdagectl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_cdoperad,
                                      INPUT par_nrremass).
                    
                END. /* FIM do IF cdbandoc = 85 */

        /*** LOG de Processo ***/
        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT "Cancelamento de Abatimento").

        IF bcrapcob.cdbandoc = 85 THEN DO:

            /* Gerar registro Tarifa */
            CREATE tt-lat-consolidada.
            ASSIGN tt-lat-consolidada.cdcooper = par_cdcooper
                   tt-lat-consolidada.nrdconta = par_nrdconta
                   tt-lat-consolidada.nrdocmto = par_nrdocmto
                   tt-lat-consolidada.nrcnvcob = par_nrcnvcob
                   tt-lat-consolidada.dsincide = "RET"
                   tt-lat-consolidada.cdocorre = 13     /* 13 - Confirmacao Recebimento Instrucao de Cancelamento Abatimento */
                   tt-lat-consolidada.cdmotivo = ""     /* Motivo */
                   tt-lat-consolidada.vllanmto = bcrapcob.vltitulo.
        END.

    END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE inst-alt-vencto:
    /* 06. Alteracao do Vencimento */
    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtvencto AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lat-consolidada.

    DEFINE VARIABLE old_dtvencto AS DATE        NO-UNDO.

    /* Processo de Validacao Recusas Padrao */
    RUN efetua-validacao-recusa-padrao (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrcnvcob,
                                        INPUT par_nrdocmto,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                        INPUT "06",         /* Alteracao do Vencimento */
                                        INPUT par_nrremass,
                                        OUTPUT ret_dsinserr).

    IF RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
      
    
    IF bcrapcob.cdbandoc = 085  AND
       bcrapcob.flgregis = TRUE AND 
       bcrapcob.flgcbdda AND 
       bcrapcob.insitpro <= 2 THEN
        DO:
            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XA",     /* Sem Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Titulo em processo de registro. Favor aguardar".
            RETURN "NOK".
        END.

    /***** VALIDACOES PARA RECUSAR ******/
    FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper
                        AND crapcre.nrcnvcob = par_nrcnvcob
                        AND crapcre.dtmvtolt = par_dtmvtolt
                        AND crapcre.intipmvt = 1
                        NO-LOCK NO-ERROR.

    IF  AVAIL crapcre THEN
        DO:
            /* Verifica se ja existe Pedido de Baixa */
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.cdocorre = 2
                                AND craprem.dtaltera = par_dtmvtolt
                                NO-LOCK NO-ERROR.

            IF  AVAIL craprem THEN
                DO:
                    RUN prepara-retorno-cooperado
                    			 (INPUT ROWID(bcrapcob),
                    			  INPUT 26,     /* Instrucao Rejeitada */
                    			  INPUT "XB",     /* Motivo */
                    			  INPUT 0,      /* Valor Tarifa */
                    			  INPUT crapcop.cdbcoctl,
                    			  INPUT crapcop.cdagectl,
                    			  INPUT par_dtmvtolt,
                    			  INPUT par_cdoperad,
                                  INPUT par_nrremass).

                    ret_dsinserr = "Pedido de Baixa ja efetuado - " +
                                   "Alteracao Vencto nao efetuada!".
                    RETURN "NOK".
                END.
        END.

    /* Validar parametro de tela */
    IF  par_dtvencto <= bcrapcob.dtvencto THEN
        DO:
            
            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "16",   /* Data de Vencimento Invalida */  
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Data Vencto inferior ao atual - " +
                           "Alteracao Vencto nao efetuada!".
            RETURN "NOK".
        END.

    /** AQUI - Rever que valor sera esse "120" **/
    IF (par_dtvencto - bcrapcob.dtvencto) > 120 THEN
        DO: 
            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "18",   /* Vencimento Fora do Prazo de Operacao */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Prazo de vencimento superior ao permitido!".

            RETURN "NOK".
        END.

    /* nao permitir alterar vencto de titulo no convenio
       de protesto */
    IF (bcrapcob.cdbandoc <> crapcop.cdbcoctl) THEN
        DO:
            FIND FIRST crapcco 
                 WHERE crapcco.cdcooper = bcrapcob.cdcooper
                   AND crapcco.nrconven = bcrapcob.nrcnvcob
                   NO-LOCK NO-ERROR.
    
            IF AVAIL crapcco THEN
               IF crapcco.dsorgarq = "PROTESTO" THEN
                   DO:
                        RUN prepara-retorno-cooperado
                        			 (INPUT ROWID(bcrapcob),
                        			  INPUT 26,     /* Instrucao Rejeitada */
                        			  INPUT "XG",     /* Motivo */
                        			  INPUT 0,      /* Valor Tarifa */
                        			  INPUT crapcop.cdbcoctl,
                        			  INPUT crapcop.cdagectl,
                        			  INPUT par_dtmvtolt,
                        			  INPUT par_cdoperad,
                                      INPUT par_nrremass).

                        ret_dsinserr = "Nao e permitido alterar " + 
                                       "vencimento do boleto no convenio " + 
                                       "protesto - Alteracao Vencto nao efetuada!".
                        RETURN "NOK".
                   END.
        END.

    IF ( par_dtvencto < bcrapcob.dtmvtolt ) THEN
    DO:
        RUN prepara-retorno-cooperado
                 (INPUT ROWID(bcrapcob),
                  INPUT 26,     /* Instrucao Rejeitada */
                  INPUT "17",   /* "Data de Vencimento Anterior a  Data de Emissão" */ 
                  INPUT 0,      /* Valor Tarifa */
                  INPUT crapcop.cdbcoctl,
                  INPUT crapcop.cdagectl,
                  INPUT par_dtmvtolt,
                  INPUT par_cdoperad,
                  INPUT par_nrremass).

        ret_dsinserr = "Data Vencto anterior a Data de Emissao - " +
                           "Alteracao Vencto nao efetuada!".

        RETURN "NOK".
    END.


    IF bcrapcob.incobran = 0 AND      /* 0 - Em Aberto */
       bcrapcob.insitcrt <> 0 THEN DO: /* Qualquer situaçao diferente de zero */

        RUN prepara-retorno-cooperado
                 (INPUT ROWID(bcrapcob),
                  INPUT 26,     /* Instrucao Rejeitada */
                  INPUT "XI",     /* Sem Motivo   */ 
                  INPUT 0,      /* Valor Tarifa */
                  INPUT crapcop.cdbcoctl,
                  INPUT crapcop.cdagectl,
                  INPUT par_dtmvtolt,
                  INPUT par_cdoperad,
                  INPUT par_nrremass).

        ret_dsinserr = "Titulo com movimentacao cartoraria - " +
                        "Alteracao Vencto nao efetuada!". 

        RETURN "NOK".



    END.

    /***** FIM - VALIDACOES PARA RECUSAR ******/

    IF  bcrapcob.flgcbdda AND
        bcrapcob.cdbandoc = crapcop.cdbcoctl  THEN 
        DO:
            /* Executa procedimentos do DDA-JD */
            RUN procedimentos-dda-jd ( INPUT "A",
                                       INPUT "",
                                       INPUT par_dtvencto,
                                       INPUT bcrapcob.vldescto,
                                       INPUT bcrapcob.vlabatim,
                                       INPUT bcrapcob.flgdprot,
                                      OUTPUT ret_dsinserr).
    
            IF  RETURN-VALUE <> "OK"  THEN DO:

                RUN prepara-retorno-cooperado
                			 (INPUT ROWID(bcrapcob),
                			  INPUT 26,     /* Instrucao Rejeitada */
                			  INPUT "XC",     /* Motivo */
                			  INPUT 0,      /* Valor Tarifa */
                			  INPUT crapcop.cdbcoctl,
                			  INPUT crapcop.cdagectl,
                			  INPUT par_dtmvtolt,
                			  INPUT par_cdoperad,
                              INPUT par_nrremass).
                RETURN "NOK".
            END.
        END.

    /* tratamento para titulos migrados */
    IF  bcrapcob.flgregis = TRUE AND
        bcrapcob.cdbandoc = 001  THEN
        DO:
            FIND crapcco WHERE 
                 crapcco.cdcooper = bcrapcob.cdcooper AND
                 crapcco.nrconven = bcrapcob.nrcnvcob 
                 NO-LOCK NO-ERROR.

            IF  AVAIL crapcco THEN
                DO:
                    IF  CAN-DO("MIGRACAO,INCORPORACAO", crapcco.dsorgarq) THEN
                        DO:
                            RUN inst-titulo-migrado 
                                (INPUT "Alteracao de Vencimento", 
                                 INPUT par_dtvencto, 
                                 INPUT 0).

                            ret_dsinserr = "Solicitacao de baixa de titulo " + 
                                           "migrado. Aguarde confirmacao no " + 
                                           "proximo dia util.".
                            RETURN "NOK".
                        END.
                END.
        END.

    DO TRANSACTION:

        FIND CURRENT bcrapcob EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        FIND LAST tt-remessa-dda NO-LOCK NO-ERROR.

        ASSIGN bcrapcob.idopeleg = tt-remessa-dda.idopeleg
                                   WHEN AVAIL tt-remessa-dda
        /* Altera Dt. Vencimento conforme parametro de tela passado */
               old_dtvencto      = bcrapcob.dtvencto
               bcrapcob.dtvencto = par_dtvencto.

        IF  bcrapcob.cdbandoc = 1 THEN
            DO:
                /* Verifica se ja existe Instrucao de Alteracao de Vencimento */
                FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                    AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                    AND craprem.nrdconta = bcrapcob.nrdconta
                                    AND craprem.nrdocmto = bcrapcob.nrdocmto
                                    AND craprem.cdocorre = par_cdocorre /* 6. */
                                    AND craprem.dtaltera = par_dtmvtolt
                    NO-LOCK NO-ERROR.
        
                IF  AVAIL craprem THEN 
                    DO:
                        /*** LOG de Processo ***/
                        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT 'Exclusao Instr.Alt.Vencto. Data:' +
                                                 STRING(craprem.dtdprorr,"99/99/99")).
            
            
                        /** Exclui o Instrucao de Remessa que ja existe
                            e criar uma nova com o novo Abatimento **/
                        RUN pi-elimina-remessa (INPUT craprem.cdcooper,
                                                INPUT craprem.nrdconta,
                                                INPUT craprem.nrcnvcob,
                                                INPUT craprem.nrdocmto,
                                                INPUT craprem.cdocorre,
                                                INPUT craprem.dtaltera,
                                               OUTPUT ret_dsinserr).
            
                        IF  ret_dsinserr <> "" THEN
                            DO:
                                RETURN "NOK".
                            END.
                    END.


                RUN prep-remessa-banco( INPUT bcrapcob.cdcooper,
                                        INPUT bcrapcob.nrcnvcob,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                       OUTPUT aux_nrremret,
                                       OUTPUT aux_nrseqreg).
        
                IF  bcrapcob.insitcrt = 1 OR
                    bcrapcob.insitcrt = 3 OR
                    bcrapcob.dtvencto <= par_dtmvtolt THEN
                    DO:
                        aux_nrseqreg = aux_nrseqreg + 1.
                        RUN cria-tab-remessa( ROWID(bcrapcob),
                           /* nrremret */     aux_nrremret,
                           /* nrseqreg */     aux_nrseqreg,
                           /* cdocorre */     11, /* Sustar Manter Carteira */
                           /* cdmotivo */     "",
                           /* dtdprorr */     ?,
                           /* vlabatim */     0,
                           /* cdoperad */     par_cdoperad,
                           /* dtmvtolt */     par_dtmvtolt).
                    END.
        
                aux_nrseqreg = aux_nrseqreg + 1.
                RUN cria-tab-remessa( ROWID(bcrapcob),
                   /* nrremret */     aux_nrremret,
                   /* nrseqreg */     aux_nrseqreg,
                   /* cdocorre */     par_cdocorre, /* 6. Alteracao Vencimento */
                   /* cdmotivo */     "", 
                   /* dtdprorr */     par_dtvencto,
                   /* vlabatim */     0,
                   /* cdoperad */     par_cdoperad,
                   /* dtmvtolt */     par_dtmvtolt).
    
            END. /* FIM do IF cdbandoc = 1 */
    
        ELSE 
            IF  bcrapcob.cdbandoc = crapcop.cdbcoctl  THEN 
                DO:
                    RUN prepara-retorno-cooperado
                                     (INPUT ROWID(bcrapcob),
                                      INPUT 14, /* Confirmacao Recebimento Instrucao Alteracao de Vencimento */
                                      INPUT "", /* Motivo */
                                      INPUT 0,  /* Valor Tarifa */
                                      INPUT crapcop.cdbcoctl,
                                      INPUT crapcop.cdagectl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_cdoperad,
                                      INPUT par_nrremass).
    
                END. /* FIM do IF cdbandoc = 85 */
    
        /* Gera registro de Prorrogacao - FlgConfi = FALSE */
        RUN cria-tab-prorrogacao( ROWID(bcrapcob),
               /* dtvctonv */     par_dtvencto,
               /* dtvctori */     old_dtvencto,
               /* flgconfi */     FALSE,
               /* cdoperad */     par_cdoperad,
               /* dtmvtolt */     par_dtmvtolt).

        /*** LOG de Processo ***/
        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT "Alter. Vencto. De " + 
                                     STRING(old_dtvencto,"99/99/99")
                                     + " para " +
                                     STRING(par_dtvencto,"99/99/99")).

        IF bcrapcob.cdbandoc = 85 THEN DO:

            /* Gerar registro Tarifa */
            CREATE tt-lat-consolidada.
            ASSIGN tt-lat-consolidada.cdcooper = par_cdcooper
                   tt-lat-consolidada.nrdconta = par_nrdconta
                   tt-lat-consolidada.nrdocmto = par_nrdocmto
                   tt-lat-consolidada.nrcnvcob = par_nrcnvcob
                   tt-lat-consolidada.dsincide = "RET"
                   tt-lat-consolidada.cdocorre = 14  /* 14 - Confirmacao Recebimento Instrucao Alteracao de Vencimento  */
                   tt-lat-consolidada.cdmotivo = ""  /* Motivo */
                   tt-lat-consolidada.vllanmto = bcrapcob.vltitulo.
        END.

    END. /* final da transacao */

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE inst-protestar:
    /* 09. Protestar */
    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_cdtpinsc LIKE crapcob.cdtpinsc             NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lat-consolidada.

    /* Processo de Validacao Recusas Padrao */
    RUN efetua-validacao-recusa-padrao (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrcnvcob,
                                        INPUT par_nrdocmto,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                        INPUT "09",
                                        INPUT par_nrremass,
                                        OUTPUT ret_dsinserr).

    IF RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    
    IF  bcrapcob.cdbandoc = 085  AND
        bcrapcob.flgregis = TRUE AND 
        bcrapcob.flgcbdda AND 
        bcrapcob.insitpro <= 2 THEN
        DO:
            ret_dsinserr = "Titulo em processo de registro. Favor aguardar".
            RETURN "NOK".
        END.

    /***** VALIDACOES PARA RECUSAR ******/
    
    /** Titulo ainda nao venceu **/
    IF  bcrapcob.dtvencto >= TODAY THEN
         DO:
            RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "39",   /* "Pedido de Protesto Nao Permitido para o Titulo" */ 
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).

            ret_dsinserr = "Boleto a Vencer - Protesto nao efetuado!".
            RETURN "NOK".
         END.

    /** Titulo nao ultrapassou data Instrucao Automatica de Protesto **/
    IF  bcrapcob.flgdprot = TRUE AND
        ((bcrapcob.dtvencto + bcrapcob.qtdiaprt) > TODAY) THEN
        DO:
            RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "39",   /* "Pedido de Protesto Nao Permitido para o Titulo" */ 
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).

            ret_dsinserr = "Boleto nao ultrapassou data de Instr. Autom. de " +
                           "Protesto - Protesto nao efetuado!".
            RETURN "NOK".
        END.


    /* Titulos com Remessa a Cartorio ou Em Cartorio */
    CASE bcrapcob.insitcrt:
        WHEN 1 THEN DO:
            ret_dsinserr = "Boleto c/ instrucao de protesto - " +
                "Aguarde confirmacao do Banco do Brasil - " + 
                "Protesto nao efetuado!".
            RETURN "NOK".
        END.
        WHEN 2 THEN DO:
            ret_dsinserr = "Boleto c/ instrucao de sustacao - " + 
                "Aguarde confirmacao do Banco do Brasil - " +
                "Protesto nao efetuado!".
            RETURN "NOK".
        END.
        WHEN 3 THEN DO: 
            ret_dsinserr = "Boleto Em Cartorio - Protesto nao efetuado!".
            RETURN "NOK".
        END.

    END CASE.

    FIND crapass WHERE crapass.cdcooper = bcrapcob.cdcooper AND
                       crapass.nrdconta = bcrapcob.nrdconta
                       NO-LOCK NO-ERROR.

     IF  NOT AVAILABLE crapass  THEN
         RETURN "NOK".

     /* Se pessoa for fisica, nao protestar */
     IF crapass.inpessoa = 1 THEN
         DO:
            RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "39",   /* "Pedido de Protesto Nao Permitido para o Titulo" */
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).

             ret_dsinserr = "Instrucao nao permitida para Pessoa Fisica".
             RETURN "NOK".
         END.

    /* Verifica se ja existe Instrucao de "Protestar" */
    FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper
                        AND crapcre.nrcnvcob = par_nrcnvcob
                        AND crapcre.dtmvtolt = par_dtmvtolt
                        AND crapcre.intipmvt = 1
                        NO-LOCK NO-ERROR.


    IF  AVAIL crapcre THEN
        DO:
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.cdocorre = 9
                                AND craprem.dtaltera = par_dtmvtolt
                                NO-LOCK NO-ERROR. 

            IF  AVAIL craprem THEN
                DO:
                           
                    ret_dsinserr = "Instrucao de Protesto ja efetuada - " +
                                   "Protesto nao efetuado!".
                    RETURN "NOK".
                END.
        END.

    /* Validar parametro de tela */
    IF  bcrapcob.cddespec <> 1 AND
        bcrapcob.cddespec <> 2 THEN
        DO:
             RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "39",   /* "Pedido de Protesto Nao Permitido para o Titulo" */
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).

            ret_dsinserr = "Especie Docto diferente de DM e DS - " +
                           "Protesto nao efetuado!".
            RETURN "NOK".
        END.

    /*** Validacao Praça não executante de protesto ****/
    FIND crapsab WHERE crapsab.cdcooper = bcrapcob.cdcooper AND
                       crapsab.nrdconta = bcrapcob.nrdconta AND
                       crapsab.nrinssac = bcrapcob.nrinssac NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapsab  THEN
        RETURN "NOK".

    /*Rafael Ferreira (Mouts) - INC0022229
      Conforme informado por Deise Carina Tonn da area de Negócio, esta validaçao nao é mais necessária
      pois agora Todas as cidades podem ter protesto*/
    /*FIND crappnp WHERE crappnp.nmextcid = crapsab.nmcidsac AND
                       crappnp.cduflogr = crapsab.cdufsaca NO-LOCK NO-ERROR.

    IF  AVAILABLE crappnp THEN
        DO:
            RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "39",   /* "Pedido de Protesto Nao Permitido para o Titulo" */
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).

            ret_dsinserr = "Praça não executante de protesto " + 
                           "– Instrução não efetuada".
            RETURN "NOK".
        END.*/

    /* tratamento para titulos migrados */
    IF  bcrapcob.flgregis = TRUE AND
        bcrapcob.cdbandoc = 001  THEN
        DO:
            FIND crapcco WHERE 
                 crapcco.cdcooper = bcrapcob.cdcooper AND
                 crapcco.nrconven = bcrapcob.nrcnvcob 
                 NO-LOCK NO-ERROR.

            IF  AVAIL crapcco THEN
                DO:
                    IF  CAN-DO("MIGRACAO,INCORPORACAO", crapcco.dsorgarq) THEN
                        DO:
                            RUN inst-titulo-migrado (INPUT "Protesto", 
                                                     INPUT ?, 
                                                     INPUT 0).

                            ret_dsinserr = "Solicitacao de protesto de titulo " + 
                                           "migrado. Aguarde confirmacao no " + 
                                           "proximo dia util.".
                            RETURN "NOK".
                        END.
                END.
        END.


    /***** FIM - VALIDACOES PARA RECUSAR ******/

    IF  bcrapcob.cdbandoc = 1 THEN
        DO:
            /*** LOG de Processo ***/
            RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                                   INPUT par_cdoperad,
                                   INPUT par_dtmvtolt,
                                   INPUT "Protestar").
    
    
            RUN prep-remessa-banco( INPUT bcrapcob.cdcooper,
                                    INPUT bcrapcob.nrcnvcob,
                                    INPUT par_dtmvtolt,
                                    INPUT par_cdoperad,
                                   OUTPUT aux_nrremret,
                                   OUTPUT aux_nrseqreg).
    
            aux_nrseqreg = aux_nrseqreg + 1.
            RUN cria-tab-remessa( ROWID(bcrapcob),
               /* nrremret */     aux_nrremret,
               /* nrseqreg */     aux_nrseqreg,
               /* cdocorre */     par_cdocorre, /* 9. Protestar */
               /* cdmotivo */     "", 
               /* dtdprorr */     ?,
               /* vlabatim */     0,
               /* cdoperad */     par_cdoperad,
               /* dtmvtolt */     par_dtmvtolt).

        END. /* FIM do IF cdbandoc = 1 */
    ELSE
        IF  bcrapcob.cdbandoc = 85 THEN
            DO:
                RUN enviar-tit-protesto(INPUT ROWID(bcrapcob),
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                       OUTPUT ret_dsinserr).
        
                IF  ret_dsinserr <> "" THEN
                    DO:
                        RETURN "NOK".
                    END.
        
                RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT par_cdocorre, /* 19 - Confirmação Recebimento Instrução de Protesto */
                          INPUT "",           /* Motivo */
                          INPUT 0,            /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

            END. /* FIM do IF cdbandoc = 85 */
    
    /* Nao efetuar a cobranca da tarifa quando for processo automatico de protesto via crps */
    IF bcrapcob.cdbandoc = 85 AND par_cdoperad <> "1" THEN DO:

        /* Gerar registro Tarifa */
        CREATE tt-lat-consolidada.
        ASSIGN tt-lat-consolidada.cdcooper = par_cdcooper
               tt-lat-consolidada.nrdconta = par_nrdconta
               tt-lat-consolidada.nrdocmto = par_nrdocmto
               tt-lat-consolidada.nrcnvcob = par_nrcnvcob
               tt-lat-consolidada.dsincide = "RET"
               tt-lat-consolidada.cdocorre = 19    /* 19 - Confirmação Recebimento Instrução de Protesto */
               tt-lat-consolidada.cdmotivo = ""    /* Motivo */
               tt-lat-consolidada.vllanmto = bcrapcob.vltitulo.

    END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE enviar-tit-protesto:

    DEF  INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                            NO-UNDO.

    DEF          VAR aux_nrdocmto AS INT                             NO-UNDO.
    DEF          VAR aux_contador AS INT                             NO-UNDO.
    DEF          VAR aux_nrcnvceb AS INTE                            NO-UNDO.
	DEF          VAR aux_nrcebnov AS INTE                            NO-UNDO.

    DEF          VAR aux_ponteiro AS INTE                            NO-UNDO.
    DEF          VAR aux_nrsequen AS INTE                            NO-UNDO.
    DEF          VAR aux_busca    AS CHAR                            NO-UNDO.

    DEF BUFFER bfcrapcob FOR crapcob.


    FIND FIRST bcrapcob WHERE ROWID(bcrapcob) = par_idtabcob
               NO-LOCK NO-ERROR.

    IF  NOT AVAIL bcrapcob  THEN
        DO:
            ret_dsinserr = "Registro de cobranca nao encontrado".
            RETURN "NOK".
        END.

    FIND FIRST crapcop WHERE crapcop.cdcooper = bcrapcob.cdcooper
         NO-LOCK NO-ERROR.

    /* Buscar banco correspondente */
    FIND FIRST crapcco WHERE crapcco.cdcooper = bcrapcob.cdcooper
                         AND crapcco.cddbanco = 1
                         AND crapcco.flgregis = TRUE
                         AND crapcco.flgativo = TRUE
                         AND crapcco.dsorgarq = "PROTESTO"
                         NO-LOCK NO-ERROR.
            
    IF  NOT AVAILABLE crapcco  THEN
        DO:
            ASSIGN ret_dsinserr = "Convenio nao cadastrado ou invalido.". 
            RETURN "NOK".
        END.

    IF  bcrapcob.flgcbdda AND
        bcrapcob.cdbandoc = crapcop.cdbcoctl  THEN
        DO:
            /* Executa procedimentos do DDA-JD */
            RUN procedimentos-dda-jd ( INPUT "B",
                                       INPUT "3",
                                       INPUT bcrapcob.dtvencto,
                                       INPUT bcrapcob.vldescto,
                                       INPUT bcrapcob.vlabatim,
                                       INPUT bcrapcob.flgdprot,
                                      OUTPUT ret_dsinserr).
    
            IF  RETURN-VALUE <> "OK"  THEN
                RETURN "NOK".
    
        END.

    DO TRANSACTION:
        /*
        /* Gerar novo titulo */
        DO aux_contador = 1 TO 10:
    
            FIND LAST bfcrapcob WHERE bfcrapcob.cdcooper = bcrapcob.cdcooper AND
                                      bfcrapcob.nrdconta = bcrapcob.nrdconta AND
                                      bfcrapcob.nrcnvcob = crapcco.nrconven  AND
                                      bfcrapcob.nrdctabb = crapcco.nrdctabb  AND
                                      bfcrapcob.cdbandoc = crapcco.cddbanco
                                      EXCLUSIVE-LOCK NO-WAIT NO-ERROR.
            
            IF  NOT AVAILABLE bfcrapcob  THEN
                DO:
                    IF  LOCKED bfcrapcob  THEN
                        DO:
                            ret_dsinserr = "Ultimo registro de boleto esta " +
                                           "sendo alterado. Tente novamente.".
                            PAUSE 1 NO-MESSAGE.
                            NEXT.
                        END.
                    ELSE 
                        DO:
                            ASSIGN aux_nrdocmto = 1
                                   ret_dsinserr = "".
                            LEAVE.
                        END.
                END.
            ELSE
                ASSIGN aux_nrdocmto = bfcrapcob.nrdocmto + 1
                       ret_dsinserr = "".
    
            LEAVE.
        END.
    
        IF  ret_dsinserr <> "" THEN
            RETURN "NOK".

        RELEASE bfcrapcob NO-ERROR.
        */

        /* A busca so sequencial do nrdocmto sera atraves de sequence no Oracle */
        /* CDCOOPER;NRDCONTA;NRCNVCOB;NRDCTABB;CDBANDOC */
        ASSIGN aux_busca = TRIM(STRING(bcrapcob.cdcooper))   + ";" +
                           TRIM(STRING(bcrapcob.nrdconta))   + ";" +
                           TRIM(STRING(crapcco.nrconven))    + ";" +
                           TRIM(STRING(crapcco.nrdctabb))    + ";" +
                           TRIM(STRING(crapcco.cddbanco)).

        /* Busca a proxima sequencia */
        RUN STORED-PROCEDURE pc_sequence_progress
        aux_handproc = PROC-HANDLE NO-ERROR (INPUT "CRAPCOB"
                                            ,INPUT "NRDOCMTO"
                                            ,INPUT aux_busca
                                            ,INPUT "N"
                                            ,"").
      
        CLOSE STORED-PROC pc_sequence_progress
        aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
                
        ASSIGN aux_nrsequen = INTE(pc_sequence_progress.pr_sequence)
                              WHEN pc_sequence_progress.pr_sequence <> ?.
        
        ASSIGN aux_nrdocmto = aux_nrsequen.

        FIND FIRST bcrapcob WHERE ROWID(bcrapcob) = par_idtabcob
               NO-LOCK NO-ERROR.
    
        /** Procura convenio CEB do cooperado **/
        FIND LAST crapceb WHERE crapceb.cdcooper = bcrapcob.cdcooper AND
                                crapceb.nrdconta = bcrapcob.nrdconta AND
                                crapceb.nrconven = crapcco.nrconven
                                NO-LOCK USE-INDEX crapceb1 NO-ERROR.

        IF  AVAIL crapceb THEN
            aux_nrcnvceb = crapceb.nrcnvceb.
        ELSE
            DO:
                DO aux_nrcebnov = 1 TO 9999:
                
                    FIND FIRST crapceb 
                         WHERE crapceb.cdcooper = bcrapcob.cdcooper
                           AND crapceb.nrconven = crapcco.nrconven
                           AND crapceb.nrcnvceb = aux_nrcebnov
                           NO-LOCK NO-ERROR.
                           
                    IF NOT AVAIL crapceb THEN 
                       DO:
                          ASSIGN aux_nrcnvceb = aux_nrcebnov.
                          LEAVE.
                       END.
                    
                END.

                IF aux_nrcnvceb = 0 THEN
                DO:
                   ret_dsinserr = "Erro: numero CEB excedeu o limite de 9999. " +
				                  "Instrucao de protesto cancelada.".        
                   RETURN "NOK".
                END.
    
                CREATE crapceb.
                ASSIGN crapceb.cdcooper = bcrapcob.cdcooper
                       crapceb.nrdconta = bcrapcob.nrdconta
                       crapceb.nrconven = crapcco.nrconven
                       crapceb.nrcnvceb = aux_nrcnvceb
                       crapceb.dtcadast = par_dtmvtolt
                       crapceb.cdoperad = "1"
                       crapceb.inarqcbr = 0
                       crapceb.cddemail = 0
                       crapceb.flgcruni = NO
                       /* Inicio - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */
                       crapceb.cdopeori = par_cdoperad
                       crapceb.cdageori = 0
                       crapceb.dtinsori = TODAY
                       /* Fim - Alteracoes referentes a M181 - Rafael Maciel (RKAM) */

                       crapceb.insitceb = 1.
                VALIDATE crapceb.
            END.

        FIND CURRENT bcrapcob EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
        
        FIND LAST tt-remessa-dda NO-LOCK NO-ERROR.

        FIND crapass WHERE crapass.cdcooper = bcrapcob.cdcooper AND
                           crapass.nrdconta = bcrapcob.nrdconta
                           NO-LOCK NO-ERROR.

        ASSIGN bcrapcob.idopeleg = tt-remessa-dda.idopeleg WHEN AVAIL tt-remessa-dda
               /* Baixar Titulo original */
               bcrapcob.dtdbaixa = par_dtmvtolt
               bcrapcob.incobran = 3 /* Baixado */
               bcrapcob.insitcrt = 1 /* C/ Instr. de Protesto */
               bcrapcob.cdagepag = crapcop.cdagectl
               bcrapcob.cdbanpag = crapcop.cdbcoctl
               bcrapcob.cdtitprt = STRING(bcrapcob.cdcooper, "999")      + ";" + 
                                   STRING(bcrapcob.nrdconta, "99999999") + ";" + 
                                   STRING(crapcco.nrconven, "99999999") + ";" + 
                                   STRING(aux_nrdocmto, "999999999").
    
        CREATE crapcob.
        BUFFER-COPY bcrapcob 
             EXCEPT bcrapcob.nrdocmto bcrapcob.inemiten bcrapcob.cdbandoc
                    bcrapcob.nrcnvcob bcrapcob.nrdctabb bcrapcob.cdcartei
                    bcrapcob.incobran bcrapcob.cdimpcob
                    bcrapcob.flgimpre bcrapcob.nrnosnum bcrapcob.flgdprot
                    bcrapcob.qtdiaprt bcrapcob.indiaprt bcrapcob.flgregis
                    bcrapcob.nrinsava bcrapcob.cdtpinav bcrapcob.nmdavali
                    bcrapcob.dtdbaixa bcrapcob.flgaceit bcrapcob.vldescto
                    bcrapcob.vlabatim bcrapcob.cdtitprt bcrapcob.flserasa
                    bcrapcob.inserasa bcrapcob.qtdianeg bcrapcob.dtretser
                 TO crapcob
        ASSIGN crapcob.nrinsava = crapass.nrcpfcgc /* sacador avalista */
               crapcob.cdtpinav = crapass.inpessoa /* eh o cooperado */
               crapcob.nmdavali = crapass.nmprimtl
               crapcob.nrdocmto = aux_nrdocmto
               crapcob.inemiten = 1 /* banco emite e expede */
               crapcob.cdbandoc = crapcco.cddbanco
               crapcob.nrcnvcob = crapcco.nrconven
               crapcob.nrdctabb = crapcco.nrdctabb
               crapcob.cdcartei = crapcco.cdcartei
               crapcob.incobran = 0
               crapcob.cdimpcob = 3
               crapcob.flgimpre = TRUE
               crapcob.nrnosnum = STRING(crapcco.nrconven, "9999999") +
                                  STRING(aux_nrcnvceb, "9999") +
                                  STRING(aux_nrdocmto, "999999")
               crapcob.flgdprot = TRUE /* (protestar automático) */
               crapcob.qtdiaprt = 6
               crapcob.indiaprt = 2    /* (dias corridos)        */
               crapcob.insitpro = 0 
               crapcob.flgcbdda = FALSE
               crapcob.flgregis = TRUE
               crapcob.flgaceit = FALSE
               crapcob.vldescto = bcrapcob.vldescto + bcrapcob.vlabatim
               crapcob.cdtitprt = STRING(bcrapcob.cdcooper, "999")      + ";" + 
                                  STRING(bcrapcob.nrdconta, "99999999") + ";" + 
                                  STRING(bcrapcob.nrcnvcob, "99999999") + ";" + 
                                  STRING(bcrapcob.nrdocmto, "999999999").
        VALIDATE crapcob.

        /* gerar pedido de remessa */
        RUN prep-remessa-banco( INPUT crapcob.cdcooper,
                                INPUT crapcob.nrcnvcob,
                                INPUT par_dtmvtolt,
                                INPUT par_cdoperad,
                               OUTPUT aux_nrremret,
                               OUTPUT aux_nrseqreg).

        aux_nrseqreg = aux_nrseqreg + 1.
        RUN cria-tab-remessa( ROWID(crapcob),
           /* nrremret */     aux_nrremret,
           /* nrseqreg */     aux_nrseqreg,
           /* cdocorre */     1, /* Pedido de Remessa */
           /* cdmotivo */     "", 
           /* dtdprorr */     ?,
           /* vlabatim */     0,
           /* cdoperad */     par_cdoperad,
           /* dtmvtolt */     par_dtmvtolt).

        /* reposicionar buffer (Rafael) */
        FIND FIRST bcrapcob WHERE ROWID(bcrapcob) = par_idtabcob
                   NO-LOCK NO-ERROR.

        /*** LOG de Processo Titulo Novo ***/
        RUN cria-log-cobranca (INPUT ROWID(crapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT "Tit Ant: Conv " + STRING(bcrapcob.nrcnvcob) + 
                                     " Docto " + STRING(bcrapcob.nrdocmto)).

        /* reposicionar buffer (Rafael) */
        FIND FIRST bcrapcob WHERE ROWID(bcrapcob) = par_idtabcob
                   NO-LOCK NO-ERROR.
        
        /*** LOG de Processo ***/
        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT "Baixado p/ enviar Protesto").
        
        /*** LOG de Processo Titulo Anterior ***/
        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT "Tit Novo: Conv " + STRING(crapcob.nrcnvcob) + 
                                     " Docto " + STRING(crapcob.nrdocmto)).
    
    END.

    RELEASE crapcob.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE inst-sustar-baixar:
    /* 10. Sustar Protesto e Baixar Titulo */
    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lat-consolidada.

    FIND FIRST crapcco WHERE crapcco.cdcooper = par_cdcooper
                         AND crapcco.nrconven = par_nrcnvcob
                         NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcco THEN DO:
        ret_dsinserr = "Registro de cobranca nao encontrado".
        RETURN "NOK".
    END.


    FIND FIRST bcrapcob WHERE bcrapcob.cdcooper = par_cdcooper
                          AND bcrapcob.cdbandoc = crapcco.cddbanco
                          AND bcrapcob.nrdctabb = crapcco.nrdctabb  
                          AND bcrapcob.nrdconta = par_nrdconta
                          AND bcrapcob.nrcnvcob = par_nrcnvcob
                          AND bcrapcob.nrdocmto = par_nrdocmto
                          NO-LOCK NO-ERROR.

    RUN inst-pedido-baixa (INPUT bcrapcob.cdcooper,
                           INPUT bcrapcob.nrdconta,
                           INPUT bcrapcob.nrcnvcob,
                           INPUT bcrapcob.nrdocmto,
                           INPUT 2, /* Sustar Baixar */
                           INPUT par_dtmvtolt,
                           INPUT par_cdoperad,
                           INPUT par_nrremass,
                          OUTPUT ret_dsinserr,
                          INPUT-OUTPUT TABLE tt-lat-consolidada).

END PROCEDURE.

/*............................................................................*/

PROCEDURE inst-sustar-manter:
    /* 11. Sustar Protesto e Manter Titulo */
    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lat-consolidada.

    /* Processo de Validacao Recusas Padrao */
    RUN efetua-validacao-recusa-padrao (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrcnvcob,
                                        INPUT par_nrdocmto,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                        INPUT "11",
                                        INPUT par_nrremass,
                                        OUTPUT ret_dsinserr).

    IF RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    
    IF  bcrapcob.cdbandoc = 085  AND
        bcrapcob.flgregis = TRUE AND 
        bcrapcob.flgcbdda AND 
        bcrapcob.insitpro <= 2 THEN
        DO:
            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XA",   
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).        

            ret_dsinserr = "Titulo em processo de registro. Favor aguardar".
            RETURN "NOK".
        END.


    /***** VALIDACOES PARA RECUSAR ******/
    
    IF  bcrapcob.incobran = 0 AND
        bcrapcob.insitcrt = 2 THEN
        DO:
            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XJ",   
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto c/ instr. de sustacao - " + 
                           "Aguarde sustacao do Banco do Brasil - " + 
                           "Instr. Sustar nao efetuada!".
            RETURN "NOK".
        END.

    IF  bcrapcob.incobran = 0 AND
        bcrapcob.insitcrt = 4 THEN
        DO:
            RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "A7",   /* "Titulo ja se encontra na situacao Pretendida" */ 
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).

            ret_dsinserr = "Boleto sustado - " + 
                           "Instr. Sustar nao efetuada!".
            RETURN "NOK".
        END.


    /** Titulo ainda nao venceu **/
    IF  bcrapcob.dtvencto >= par_dtmvtolt THEN
        DO:
            RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "41",   /* "Pedido de Cancelamento/Sustacao para Titulos sem Instrucao de Protesto" */ 
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto a Vencer - Instr. Sustar nao efetuada!".
            RETURN "NOK".
        END. 

    /* Titulos sem confirmacao Instrucao de Protesto*/
    FIND FIRST crapret WHERE crapret.cdcooper = bcrapcob.cdcooper AND
                             crapret.nrcnvcob = bcrapcob.nrcnvcob AND
                             crapret.nrdconta = bcrapcob.nrdconta AND
                             crapret.nrdocmto = bcrapcob.nrdocmto AND
                             crapret.cdocorre = 19
                             NO-LOCK NO-ERROR.

    IF NOT AVAIL(crapret) THEN
        DO:
            RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "41",   /* "Pedido de Cancelamento/Sustacao para Titulos sem Instrucao de Protesto" */ 
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).
    
                ret_dsinserr = "Boleto sem Conf Inst. Protesto  - Instr. Sustar nao efetuada!".
                RETURN "NOK".
        END.


    FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper
                        AND crapcre.nrcnvcob = par_nrcnvcob
                        AND crapcre.dtmvtolt = par_dtmvtolt
                        AND crapcre.intipmvt = 1
                        NO-LOCK NO-ERROR.

    IF  AVAIL crapcre THEN
        DO:
            /* Verifica se titulo esta "indo" ao BB */
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.nrremret = crapcre.nrremret
                                AND craprem.cdocorre = 1
                                NO-LOCK NO-ERROR.

            IF  AVAIL craprem THEN 
                DO:
                    FIND FIRST crapcco 
                         WHERE crapcco.cdcooper = bcrapcob.cdcooper
                           AND crapcco.nrconven = bcrapcob.nrcnvcob
                           NO-LOCK NO-ERROR.

                    IF  AVAIL crapcco THEN
                        DO:
                            IF  crapcco.dsorgarq = "PROTESTO" THEN
                                DO:
                                    RUN prepara-retorno-cooperado
                                    			 (INPUT ROWID(bcrapcob),
                                    			  INPUT 26,     /* Instrucao Rejeitada */
                                    			  INPUT "XK",   
                                    			  INPUT 0,      /* Valor Tarifa */
                                    			  INPUT crapcop.cdbcoctl,
                                    			  INPUT crapcop.cdagectl,
                                    			  INPUT par_dtmvtolt,
                                    			  INPUT par_cdoperad,
                                                  INPUT par_nrremass).

                                    ret_dsinserr = "Boleto sera enviado ao " + 
                                                   "convenio protesto Banco do Brasil - " +
                                                   "Instr. Sustar nao efetuada!".
                                    RETURN "NOK".
                                END.
                        END.
                END.

            /* Verifica se ja existe Instrucao de "Protestar" */
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.nrremret = crapcre.nrremret
                                AND craprem.cdocorre = 9
                                NO-LOCK NO-ERROR.

            IF  AVAIL craprem THEN
                DO:
                    RUN prepara-retorno-cooperado
                    			 (INPUT ROWID(bcrapcob),
                    			  INPUT 26,     /* Instrucao Rejeitada */
                    			  INPUT "40",   
                    			  INPUT 0,      /* Valor Tarifa */
                    			  INPUT crapcop.cdbcoctl,
                    			  INPUT crapcop.cdagectl,
                    			  INPUT par_dtmvtolt,
                    			  INPUT par_cdoperad,
                                  INPUT par_nrremass).    

                    ret_dsinserr = "Ja existe Instrucao de Protesto - " +
                                   "Instr. Sustar nao efetuada!".
                    RETURN "NOK".
                END.
    

            /* Verifica se ja existe Instrucao de "Sustar e Manter" */
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.nrremret = crapcre.nrremret
                                AND craprem.cdocorre = par_cdocorre /*11. */
                                NO-LOCK NO-ERROR.

            IF  AVAIL craprem THEN
                DO:
                    RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XL",   
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

                    ret_dsinserr = "Ja existe Instrucao de Sustar/Manter - " +
                                   "Instr. Sustar nao efetuada!".
                    RETURN "NOK".
                END.
        END.

    IF  bcrapcob.cdbandoc = 85 THEN 
        DO:
            RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "XM",   
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto do Banco 085 - " +
                           "Instr. Sustar nao efetuada!".
            RETURN "NOK".
        END.


    /* tratamento para titulos migrados */
    IF  bcrapcob.flgregis = TRUE AND
        bcrapcob.cdbandoc = 001  THEN
        DO:
            FIND crapcco WHERE 
                 crapcco.cdcooper = bcrapcob.cdcooper AND
                 crapcco.nrconven = bcrapcob.nrcnvcob 
                 NO-LOCK NO-ERROR.

            IF  AVAIL crapcco THEN
                DO:
                    IF  CAN-DO("MIGRACAO,INCORPORACAO", crapcco.dsorgarq) THEN
                        DO:
                            RUN inst-titulo-migrado (INPUT "Sustacao", 
                                                     INPUT ?, 
                                                     INPUT 0).

                            ret_dsinserr = "Solicitacao de sustacao de titulo " + 
                                           "migrado. Aguarde confirmacao no " + 
                                           "proximo dia util.".
                            RETURN "NOK".
                        END.
                END.
        END.

    /***** FIM - VALIDACOES PARA RECUSAR ******/

    /*** LOG de Processo ***/
    RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                           INPUT par_cdoperad,
                           INPUT par_dtmvtolt,
                           INPUT "Sustar e Manter").

    IF  bcrapcob.cdbandoc = 1 THEN
        DO:
            /* Registra Instrucao de Sustar e Manter */
            RUN prep-remessa-banco( INPUT bcrapcob.cdcooper,
                                    INPUT bcrapcob.nrcnvcob,
                                    INPUT par_dtmvtolt,
                                    INPUT par_cdoperad,
                                   OUTPUT aux_nrremret,
                                   OUTPUT aux_nrseqreg).
        
            aux_nrseqreg = aux_nrseqreg + 1.
            RUN cria-tab-remessa( ROWID(bcrapcob),
               /* nrremret */     aux_nrremret,
               /* nrseqreg */     aux_nrseqreg,
               /* cdocorre */     par_cdocorre, /* 11. Sustar e Manter */
               /* cdmotivo */     "",
               /* dtdprorr */     ?,
               /* vlabatim */     0,
               /* cdoperad */     par_cdoperad,
               /* dtmvtolt */     par_dtmvtolt).
        END.

    IF bcrapcob.cdbandoc = 85 THEN DO:

        /* Gerar registro Tarifa */
        CREATE tt-lat-consolidada.
        ASSIGN tt-lat-consolidada.cdcooper = par_cdcooper
               tt-lat-consolidada.nrdconta = par_nrdconta
               tt-lat-consolidada.nrdocmto = par_nrdocmto
               tt-lat-consolidada.nrcnvcob = par_nrcnvcob
               tt-lat-consolidada.dsincide = "RET"
               tt-lat-consolidada.cdocorre = 20  /* 20 - Confirmacao de Sustacao ou Cancelamento Protesto */
               tt-lat-consolidada.cdmotivo = ""  /* Motivo */
               tt-lat-consolidada.vllanmto = bcrapcob.vltitulo.
    END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE inst-cancel-protesto:
    /* 41. Cancelar Protesto */
    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lat-consolidada.

    DEF VAR          aux_flgserasa AS LOGI                          NO-UNDO.
    

    /* Processo de Validacao Recusas Padrao */
    RUN efetua-validacao-recusa-padrao (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrcnvcob,
                                        INPUT par_nrdocmto,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                        INPUT "41",
                                        INPUT par_nrremass,
                                        OUTPUT ret_dsinserr).

    IF RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    
    IF  bcrapcob.cdbandoc = 085  AND
        bcrapcob.flgregis = TRUE AND 
        bcrapcob.flgcbdda AND 
        bcrapcob.insitpro <= 2 THEN
        DO:
            RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "XA",   
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Titulo em processo de registro. Favor aguardar".
            RETURN "NOK".
        END.
    
    /* Verificamos se o boleto possui Negativacao no Serasa */
    IF bcrapcob.flserasa = TRUE AND 
       bcrapcob.qtdianeg > 0    THEN
        DO:
            /* Sera tratado como Negativacao Serasa */ 
            ASSIGN aux_flgserasa = TRUE.
        END.
        ELSE 
            DO:
                /* Sera tratado como Protesto */ 
                ASSIGN aux_flgserasa = FALSE.
            END.


    /***** VALIDACOES PARA RECUSAR ******/
    /* Verificamos se o boleto possui Negativacao no Serasa */ 
    IF aux_flgserasa THEN 
        DO:
        
            FIND FIRST crapdat 
                 WHERE crapdat.cdcooper = par_cdcooper
               NO-LOCK NO-ERROR.
        
            /* Verificacoes para recusar Instrucao de Negativacao do Serasa */
            IF crapdat.dtmvtolt >= (bcrapcob.dtvencto + bcrapcob.qtdianeg) THEN
                DO:
                    RUN prepara-retorno-cooperado
                                 (INPUT ROWID(bcrapcob),
                                  INPUT 26,     /* Instrucao Rejeitada */
                                  INPUT "S1",   /* " Titulo ja enviado para negativacao " */ 
                                  INPUT 0,      /* Valor Tarifa */
                                  INPUT crapcop.cdbcoctl,
                                  INPUT crapcop.cdagectl,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdoperad,
                                  INPUT par_nrremass).

                    ret_dsinserr = "Excedido prazo cancelamento da instrucao automatica de negativacao! " +
                                   "Negativacao Serasa nao efetuada!".
                    RETURN "NOK".   
                END.
           
            /* Verificar se foi enviado ao Serasa */
            IF  bcrapcob.inserasa <> 0 THEN
                DO:
                    RUN prepara-retorno-cooperado
                                 (INPUT ROWID(bcrapcob),
                                  INPUT 26,     /* Instrucao Rejeitada */
                                  INPUT "S1",   /* " Titulo ja enviado para negativacao " */ 
                                  INPUT 0,      /* Valor Tarifa */
                                  INPUT crapcop.cdbcoctl,
                                  INPUT crapcop.cdagectl,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdoperad,
                                  INPUT par_nrremass).

                    ret_dsinserr = "Titulo ja enviado para Negativacao. " + 
                                   "Negativacao Serasa nao efetuada!".
                    RETURN "NOK".   
                END.

        END. /* Fim das validacoes de negativacao Serasa */
        ELSE 
            DO:
    /* Titulos sem confirmacao Instrucao de Protesto*/
    FIND FIRST crapret WHERE crapret.cdcooper = bcrapcob.cdcooper AND
                             crapret.nrcnvcob = bcrapcob.nrcnvcob AND
                             crapret.nrdconta = bcrapcob.nrdconta AND
                             crapret.nrdocmto = bcrapcob.nrdocmto AND
                             crapret.cdocorre = 19
                             NO-LOCK NO-ERROR.

    IF AVAIL(crapret) THEN
        DO:
            RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "41",   /* "Pedido de Cancelamento/Sustacao para Titulos sem Instrucao de Protesto" */ 
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).
    
                ret_dsinserr = "Boleto sem Conf Inst. Protesto  - Canc. Protesto nao efetuado!".
                RETURN "NOK".
        END.
    /** Titulo sem Instrucao Automatica de Protesto **/
    IF  bcrapcob.flgdprot = FALSE THEN
        DO:
            RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "A7",   /* " Titulo ja se encontra na situacao Pretendida" */ 
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto sem Instr. Automatca de " +
                           "Protesto - Canc. Protesto nao efetuado!".
            RETURN "NOK".   
        END.

    /* Titulos com Remessa a Cartorio, Sustacao ou Em Cartorio */
    CASE bcrapcob.insitcrt:
        WHEN 1 THEN DO:

            RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "40",   
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto c/ instr. de protesto - " + 
                           "Canc. Protesto nao efetuado!".
            RETURN "NOK".
        END.
        WHEN 2 THEN DO:

            RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "XJ",   
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto c/ instr. de sustacao - " + 
                "Aguarde sustacao do Banco do Brasil - " +
                "Canc. Protesto nao efetuado!".
            RETURN "NOK".
        END.
        WHEN 3 THEN DO: 

            RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "XF",   
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto Em Cartorio - Canc. Protesto nao efetuado!".
            RETURN "NOK".
        END.

        WHEN 4 THEN DO: /* Sustado */

            IF bcrapcob.incobran = 0 THEN /* Em Aberto */
            DO:
                RUN prepara-retorno-cooperado
                                 (INPUT ROWID(bcrapcob),
                                  INPUT 26,     /* Instrucao Rejeitada */
                                  INPUT "A7",   /* "Titulo ja se encontra na situacao Pretendida" */ 
                                  INPUT 0,      /* Valor Tarifa */
                                  INPUT crapcop.cdbcoctl,
                                  INPUT crapcop.cdagectl,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdoperad,
                                  INPUT par_nrremass).

                ret_dsinserr = "Boleto Sustado - Canc. Protesto nao efetuado!".
                RETURN "NOK".
            END.
        END.

    END CASE.

    /* nao permitir cancelamento de protesto no convenio
       de protesto */
    IF (bcrapcob.cdbandoc <> crapcop.cdbcoctl) THEN
        DO: 
            FIND FIRST crapcco 
                 WHERE crapcco.cdcooper = bcrapcob.cdcooper
                   AND crapcco.nrconven = bcrapcob.nrcnvcob
                   NO-LOCK NO-ERROR.
        
            IF AVAIL crapcco THEN
               IF crapcco.dsorgarq = "PROTESTO" THEN
                   DO:
                       RUN prepara-retorno-cooperado
                                     (INPUT ROWID(bcrapcob),
                                      INPUT 26,     /* Instrucao Rejeitada */
                                      INPUT "XG",   
                                      INPUT 0,      /* Valor Tarifa */
                                      INPUT crapcop.cdbcoctl,
                                      INPUT crapcop.cdagectl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_cdoperad,
                                      INPUT par_nrremass). 

                       ret_dsinserr = "Nao e permitido cancelar " + 
                                      "instr. de protesto do boleto no convenio " + 
                                      "protesto - Canc. Protesto nao efetuado!".
                       RETURN "NOK".
                   END.
        END.


    FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper
                        AND crapcre.nrcnvcob = par_nrcnvcob
                        AND crapcre.dtmvtolt = par_dtmvtolt
                        AND crapcre.intipmvt = 1
                        NO-LOCK NO-ERROR.

    IF  AVAIL crapcre THEN 
        DO:
            /* Verifica se ja existe Instrucao de "Protestar" */
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.cdocorre = 9
                                AND craprem.dtaltera = par_dtmvtolt
                                NO-LOCK NO-ERROR.
    
            IF  AVAIL craprem THEN
                DO:
                    RUN prepara-retorno-cooperado
                                 (INPUT ROWID(bcrapcob),
                                  INPUT 26,     /* Instrucao Rejeitada */
                                  INPUT "40",   
                                  INPUT 0,      /* Valor Tarifa */
                                  INPUT crapcop.cdbcoctl,
                                  INPUT crapcop.cdagectl,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdoperad,
                                  INPUT par_nrremass).

                    ret_dsinserr = "Instrucao de Protesto ja efetuada - " +
                                   "Canc. Protesto nao efetuado!".
                    RETURN "NOK".
                END.
    
            /* Verifica se ja existe Instrucao de "Cancelar Protesto" */
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.cdocorre = 31
                                AND craprem.cdmotivo = "9"
                                AND craprem.dtaltera = par_dtmvtolt
                                NO-LOCK NO-ERROR.

            IF  AVAIL craprem THEN 
                DO:
                    RUN prepara-retorno-cooperado
                                 (INPUT ROWID(bcrapcob),
                                  INPUT 26,     /* Instrucao Rejeitada */
                                  INPUT "A7",   
                                  INPUT 0,      /* Valor Tarifa */
                                  INPUT crapcop.cdbcoctl,
                                  INPUT crapcop.cdagectl,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdoperad,
                                  INPUT par_nrremass).

                    ret_dsinserr = "Instrucao de Canc. Protesto ja efetuada - " +
                                   "Canc. Protesto nao efetuado!".
                    RETURN "NOK".
                END.
        END.
            END.
    /***** FIM - VALIDACOES PARA RECUSAR ******/

    /* Verificar se nao eh Serasa */
    IF NOT aux_flgserasa THEN
    DO:
        /* As informacoes de DDA e Titulos Migrados 
           sao apenas para Protesto */ 
    IF  bcrapcob.flgcbdda AND
        bcrapcob.cdbandoc = crapcop.cdbcoctl  THEN 
        DO:
            /* Executa procedimentos do DDA-JD */
            RUN procedimentos-dda-jd ( INPUT "A",
                                       INPUT "",
                                       INPUT bcrapcob.dtvencto,
                                       INPUT bcrapcob.vldescto,
                                       INPUT bcrapcob.vlabatim,
                                       INPUT FALSE,
                                      OUTPUT ret_dsinserr).
    
            IF  RETURN-VALUE <> "OK"  THEN DO:

                RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "XC",   
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

                RETURN "NOK".
            END.
        END.

    /* tratamento para titulos migrados */
    IF  bcrapcob.flgregis = TRUE AND
        bcrapcob.cdbandoc = 001  THEN
        DO:
            FIND crapcco WHERE 
                 crapcco.cdcooper = bcrapcob.cdcooper AND
                 crapcco.nrconven = bcrapcob.nrcnvcob 
                 NO-LOCK NO-ERROR.

            IF  AVAIL crapcco THEN
                DO:
                    IF  CAN-DO("MIGRACAO,INCORPORACAO", crapcco.dsorgarq) THEN
                        DO:
                            RUN inst-titulo-migrado 
                                (INPUT "Cancelamento de Protesto", 
                                 INPUT ?, 
                                 INPUT 0).

                            ret_dsinserr = "Solicitacao de cancelamento de " + 
                                           "protesto de titulo " + 
                                           "migrado. Aguarde confirmacao no " + 
                                           "proximo dia util.".
                            RETURN "NOK".
                        END.
                END.
        END.
    END.

    DO TRANSACTION:
        
        FIND CURRENT bcrapcob EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        FIND LAST tt-remessa-dda NO-LOCK NO-ERROR.
        
        ASSIGN bcrapcob.idopeleg = tt-remessa-dda.idopeleg WHEN AVAIL tt-remessa-dda.

        /* Verificamos se o boleto possui Negativacao no Serasa */ 
        IF aux_flgserasa THEN 
            DO:
                /* removido regra da negativacao serasa  */
                ASSIGN bcrapcob.flserasa = FALSE
                       bcrapcob.qtdianeg = 0.
                       
                /*** LOG de Processo ***/
                RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                                       INPUT par_cdoperad,
                                       INPUT par_dtmvtolt,
                                       INPUT "Cancel. Instrucao Negativacao").
                
                IF  bcrapcob.cdbandoc = crapcop.cdbcoctl THEN 
                    DO:
                
                        RUN prepara-retorno-cooperado
                                         (INPUT ROWID(bcrapcob),
                                          INPUT 94,   /* 94 - Confirmacao de Cancelamento Negativacao Serasa */
                                          INPUT "S4", /* Motivo */
                                          INPUT 0,    /* Valor Tarifa */
                                          INPUT crapcop.cdbcoctl,
                                          INPUT crapcop.cdagectl,
                                          INPUT par_dtmvtolt,
                                          INPUT par_cdoperad,
                                          INPUT par_nrremass).

                        /* Gerar registro Tarifa */
                        CREATE tt-lat-consolidada.
                        ASSIGN tt-lat-consolidada.cdcooper = par_cdcooper
                               tt-lat-consolidada.nrdconta = par_nrdconta
                               tt-lat-consolidada.nrdocmto = par_nrdocmto
                               tt-lat-consolidada.nrcnvcob = par_nrcnvcob
                               tt-lat-consolidada.dsincide = "RET"
                               tt-lat-consolidada.cdocorre = 94   /* 94 - Confirmacao de Cancelamento Negativacao Serasa */
                               tt-lat-consolidada.cdmotivo = "S4" /* Motivo */
                               tt-lat-consolidada.vllanmto = bcrapcob.vltitulo.
            
                    END. /* FIM do IF cdbandoc = 85 */

            END. /* Fim das alteracoes do Serasa */ 
            ELSE
                DO:
        /* removido regra da canc de protesto */
        /* permitir boleto de qualquer IF (Rafael) */
        ASSIGN bcrapcob.flgdprot = FALSE
               bcrapcob.qtdiaprt = 0
               bcrapcob.dsdinstr = 
               REPLACE(bcrapcob.dsdinstr, 
                       "** Servico de protesto sera efetuado " + 
                       "pelo Banco do Brasil **", "").

        /*** LOG de Processo ***/
        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT "Cancel. Instrucao Protesto").
    
        IF bcrapcob.cdbandoc = 1 THEN
        DO:
    
            /* Registra Instrucao Alter Dados / Protesto*/
            RUN prep-remessa-banco( INPUT bcrapcob.cdcooper,
                                    INPUT bcrapcob.nrcnvcob,
                                    INPUT par_dtmvtolt,
                                    INPUT par_cdoperad,
                                   OUTPUT aux_nrremret,
                                   OUTPUT aux_nrseqreg).
        
            aux_nrseqreg = aux_nrseqreg + 1.
            RUN cria-tab-remessa( ROWID(bcrapcob),
               /* nrremret */     aux_nrremret,
               /* nrseqreg */     aux_nrseqreg,
               /* cdocorre */     31,   /* 31. Alteracao de Dados */
               /* cdmotivo */     "9",  /* 9. Protestar */
               /* dtdprorr */     ?,
               /* vlabatim */     0,
               /* cdoperad */     par_cdoperad,
               /* dtmvtolt */     par_dtmvtolt).
        
            aux_nrseqreg = aux_nrseqreg + 1.
            RUN cria-tab-remessa( ROWID(bcrapcob),
               /* nrremret */     aux_nrremret,
               /* nrseqreg */     aux_nrseqreg,
               /* cdocorre */     11, /* 11. Sustar e Manter */
               /* cdmotivo */     "",
               /* dtdprorr */     ?,
               /* vlabatim */     0,
               /* cdoperad */     par_cdoperad,
               /* dtmvtolt */     par_dtmvtolt).

        END.
        ELSE
        DO:

            IF  bcrapcob.cdbandoc = crapcop.cdbcoctl THEN 
            DO:
        
                RUN prepara-retorno-cooperado
                                 (INPUT ROWID(bcrapcob),
                                  INPUT 20,   /* 20 - Confirmacao de Sustacao ou Cancelamento Protesto */
                                  INPUT "",   /* Motivo */
                                  INPUT 0,    /* Valor Tarifa */
                                  INPUT crapcop.cdbcoctl,
                                  INPUT crapcop.cdagectl,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdoperad,
                                  INPUT par_nrremass).

                /* Gerar registro Tarifa */
                CREATE tt-lat-consolidada.
                ASSIGN tt-lat-consolidada.cdcooper = par_cdcooper
                       tt-lat-consolidada.nrdconta = par_nrdconta
                       tt-lat-consolidada.nrdocmto = par_nrdocmto
                       tt-lat-consolidada.nrcnvcob = par_nrcnvcob
                       tt-lat-consolidada.dsincide = "RET"
                       tt-lat-consolidada.cdocorre = 20  /* 20 - Confirmacao de Sustacao ou Cancelamento Protesto */
                       tt-lat-consolidada.cdmotivo = ""  /* Motivo */
                       tt-lat-consolidada.vllanmto = bcrapcob.vltitulo.
    
            END. /* FIM do IF cdbandoc = 85 */
        END.
                END.

    END. /* END-TRANSACTION */

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE inst-alt-outros-dados:
    /* 31. Alterar Dados do Sacado */
    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lat-consolidada.

    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    FIND FIRST crapcco WHERE crapcco.cdcooper = par_cdcooper
                         AND crapcco.nrconven = par_nrcnvcob
                         NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcco THEN DO:
        ret_dsinserr = "Registro de cobranca nao encontrado".
        RETURN "NOK".
    END.

    FIND FIRST bcrapcob WHERE bcrapcob.cdcooper = par_cdcooper
                          AND bcrapcob.cdbandoc = crapcco.cddbanco
                          AND bcrapcob.nrdctabb = crapcco.nrdctabb
                          AND bcrapcob.nrdconta = par_nrdconta
                          AND bcrapcob.nrcnvcob = par_nrcnvcob
                          AND bcrapcob.nrdocmto = par_nrdocmto
                          NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL bcrapcob THEN
        DO:
            ret_dsinserr = "Registro de cobranca nao encontrado".
            RETURN "NOK".
        END.

    /* Titulos BB possuem horario limite de comando da instrucao */
    IF  AVAIL bcrapcob THEN
        DO:
            IF  bcrapcob.cdbandoc = 001 THEN
                DO:
                    RUN verifica-horario-cobranca
                        (INPUT bcrapcob.cdcooper,
                        OUTPUT ret_dsinserr).

                    IF  RETURN-VALUE = "NOK" THEN
                        RETURN "NOK".
                END.
        END.

    /* verificar se titulo BB tem confirmacao de entrada */
    IF  AVAIL bcrapcob THEN
        DO:
            IF  bcrapcob.cdbandoc = 001 THEN
                DO:
                    RUN verifica-ent-confirmada (OUTPUT ret_dsinserr).

                    IF  RETURN-VALUE = "NOK" THEN
                        RETURN "NOK".
                END.
        END.

    IF  bcrapcob.cdbandoc = 085  AND
        bcrapcob.flgregis = TRUE AND 
        bcrapcob.flgcbdda AND 
        bcrapcob.insitpro <= 2 THEN
        DO:
            ret_dsinserr = "Titulo em processo de registro. Favor aguardar".
            RETURN "NOK".
        END.

    /***** VALIDACOES PARA RECUSAR ******/
    CASE bcrapcob.incobran:

        WHEN 3 THEN DO:
            IF  bcrapcob.insitcrt <> 5 THEN
                ret_dsinserr = "Boleto Baixado - Alteracao nao efetuada!".
            ELSE
                ret_dsinserr = "Boleto Protestado - Alteracao nao efetuada!".
            RETURN "NOK".
        END.
        WHEN 5 THEN DO: 
            ret_dsinserr = "Boleto Liquidado - Alteracao nao efetuada!".
            RETURN "NOK".
        END.

    END CASE.

    CASE bcrapcob.insitcrt:
        WHEN 1 THEN DO:
            ret_dsinserr = "Boleto c/ Remessa a Cartorio - " + 
                           "Alteracao nao efetuado!".
            RETURN "NOK".
        END.
        WHEN 3 THEN DO: 
            ret_dsinserr = "Boleto Em Cartorio - Alteracao nao efetuado!".
            RETURN "NOK".
        END.

    END CASE.

    /* Verifica se ja existe Pedido de Baixa */
    FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper
                        AND crapcre.nrcnvcob = par_nrcnvcob
                        AND crapcre.dtmvtolt = par_dtmvtolt
                        AND crapcre.intipmvt = 1
                        NO-LOCK NO-ERROR.

    IF  AVAIL crapcre THEN
        DO:
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.cdocorre = 31
                                AND craprem.dtaltera = par_dtmvtolt
                                NO-LOCK NO-ERROR.

            IF  AVAIL craprem THEN
                DO:
                    ret_dsinserr = "Alteracao ja efetuada!".
                    RETURN "NOK".
                END.
        END.

    /***** FIM - VALIDACOES PARA RECUSAR ******/

    IF  bcrapcob.flgcbdda AND
        bcrapcob.cdbandoc = crapcop.cdbcoctl  THEN 
        DO:
            /* Executa procedimentos do DDA-JD */
            RUN procedimentos-dda-jd ( INPUT "A",
                                       INPUT "",
                                       INPUT bcrapcob.dtvencto, 
                                       INPUT bcrapcob.vldescto,
                                       INPUT bcrapcob.vlabatim,
                                       INPUT bcrapcob.flgdprot,
                                      OUTPUT ret_dsinserr).
        
            IF  RETURN-VALUE <> "OK"  THEN
                RETURN "NOK".
        END.

    /* tratamento para titulos migrados */
    IF  bcrapcob.flgregis = TRUE AND
        bcrapcob.cdbandoc = 001  THEN
        DO:
            FIND crapcco WHERE 
                 crapcco.cdcooper = bcrapcob.cdcooper AND
                 crapcco.nrconven = bcrapcob.nrcnvcob 
                 NO-LOCK NO-ERROR.

            IF  AVAIL crapcco THEN
                DO:
                    IF  CAN-DO("MIGRACAO,INCORPORACAO", crapcco.dsorgarq) THEN
                        DO:
                            RUN inst-titulo-migrado 
                                (INPUT "Alteracao de dados do Pagador", 
                                 INPUT ?, 
                                 INPUT 0).

                            ret_dsinserr = "Solicitacao de alteracao de " + 
                                           "dados do Pagador de titulo " + 
                                           "migrado. Aguarde confirmacao no " + 
                                           "proximo dia util.".
                            RETURN "NOK".
                        END.
                END.
        END.


    DO TRANSACTION:

        FIND CURRENT bcrapcob EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        FIND LAST tt-remessa-dda NO-LOCK NO-ERROR.

        ASSIGN bcrapcob.idopeleg = tt-remessa-dda.idopeleg WHEN AVAIL tt-remessa-dda.
        
        IF  bcrapcob.cdbandoc = 1 THEN 
            DO:
                RUN prep-remessa-banco( INPUT bcrapcob.cdcooper,
                                        INPUT bcrapcob.nrcnvcob,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                       OUTPUT aux_nrremret,
                                       OUTPUT aux_nrseqreg).
            
                aux_nrseqreg = aux_nrseqreg + 1.

                RUN cria-tab-remessa( ROWID(bcrapcob),
                   /* nrremret */     aux_nrremret,
                   /* nrseqreg */     aux_nrseqreg,
                   /* cdocorre */     par_cdocorre, /* 31. Alt.outros dados */
                   /* cdmotivo */     "", 
                   /* dtdprorr */     ?,
                   /* vlabatim */     0,
                   /* cdoperad */     par_cdoperad,
                   /* dtmvtolt */     par_dtmvtolt).
            
            END. /* FIM do IF cdbandoc = 1 */
        ELSE 
            IF  bcrapcob.cdbandoc = crapcop.cdbcoctl THEN 
                DO:
                    RUN prepara-retorno-cooperado
                                     (INPUT ROWID(bcrapcob),
                                      INPUT 27, /* Conf. Alt. Outros Dados */
                                      INPUT "", /* Motivo */
                                      INPUT 0,  /* Valor Tarifa */
                                      INPUT crapcop.cdbcoctl,
                                      INPUT crapcop.cdagectl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_cdoperad,
                                      INPUT par_nrremass).
                    
                END. /* FIM do IF cdbandoc = 85 */

        /*** LOG de Processo ***/
        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT "Alteracao de dados do Pagador").

        IF bcrapcob.cdbandoc = 85 THEN DO:

            /* Gerar registro Tarifa */
            CREATE tt-lat-consolidada.
            ASSIGN tt-lat-consolidada.cdcooper = par_cdcooper
                   tt-lat-consolidada.nrdconta = par_nrdconta
                   tt-lat-consolidada.nrdocmto = par_nrdocmto
                   tt-lat-consolidada.nrcnvcob = par_nrcnvcob
                   tt-lat-consolidada.dsincide = "RET"
                   tt-lat-consolidada.cdocorre = 27  /* 27 - Conf. Alt. Outros Dados     */
                   tt-lat-consolidada.cdmotivo = ""  /* Motivo */
                   tt-lat-consolidada.vllanmto = bcrapcob.vltitulo.

        END.

    END.

    RETURN "OK".

END PROCEDURE.

/*............................................................................*/

PROCEDURE pi-elimina-remessa:
    /* Elimina registro de Instrucao de Remessa da tabela CRAPREM */
    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    FIND FIRST craprem WHERE craprem.cdcooper = par_cdcooper
                         AND craprem.nrcnvcob = par_nrcnvcob
                         AND craprem.nrdconta = par_nrdconta
                         AND craprem.nrdocmto = par_nrdocmto
                         AND craprem.dtaltera = par_dtmvtolt
                         AND craprem.cdocorre = par_cdocorre
                         EXCLUSIVE-LOCK NO-ERROR.

    IF  AVAIL craprem THEN
        DELETE craprem.
    ELSE
        ret_dsinserr = "Problemas na exclusao da Remessa".


END PROCEDURE.

/*............................................................................*/

PROCEDURE liquidacao-intrabancaria-dda:
/*** EXECUTA OS PROCEDIMENTOS DDA COM JD ***/

    /* (B)aixa (I)nclusao (A)lteracao   */
    /*    (0)Liq Interbancaria          */
    /*    (1)Liq Intrabancaria          */
    /*    (2)Solicitacao Cedente        */
    /*    (3)Envio p/ Protesto          */
    /*    (4)Baixa por Decurso de Prazo */
    
    /* formato da data AAAAMMDD */

    DEFINE INPUT  PARAMETER par_cdcooper AS INT         NO-UNDO.
    DEFINE INPUT  PARAMETER par_dtmvtolt AS DATE        NO-UNDO.
    DEFINE INPUT  PARAMETER par_recid    AS INT64       NO-UNDO.
    DEFINE OUTPUT PARAMETER ret_dsinserr AS CHARACTER   NO-UNDO.
        
    DEFINE VAR aux_dscritic AS CHAR                     NO-UNDO.
    
        
    { includes/PLSQL_altera_session_antes_st.i &dboraayl={&scd_dboraayl} }

     RUN STORED-PROCEDURE pc_solicita_crapdda_prog
         aux_handproc = PROC-HANDLE NO-ERROR
            (  INPUT par_cdcooper 
              ,INPUT par_dtmvtolt 
              ,INPUT DECI(par_recid)  /* pr_cobrecid */
              ,OUTPUT "" ).           /* pr_dscritic */ 
           

     CLOSE STORED-PROC pc_solicita_crapdda_prog
           aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.     

     { includes/PLSQL_altera_session_depois_st.i &dboraayl={&scd_dboraayl} } 
     
     ASSIGN  aux_dscritic = ""             
             aux_dscritic = pc_solicita_crapdda_prog.pr_dscritic 
                            WHEN pc_solicita_crapdda_prog.pr_dscritic <> ?.

     IF aux_dscritic <> "" THEN
         DO:
       ASSIGN ret_dsinserr = aux_dscritic.
                    RETURN "NOK".
         END. 

    RETURN "OK".
    
END PROCEDURE.

PROCEDURE inst-titulo-migrado:

    DEF INPUT PARAM par_dsdinstr        AS CHAR             NO-UNDO.
    DEF INPUT PARAM par_dtaltvct        AS DATE             NO-UNDO.
    DEF INPUT PARAM par_vlaltabt        AS DECI             NO-UNDO.

    DEF VAR h-b1wgen0011                AS HANDLE           NO-UNDO.
    DEF VAR aux_conteudo                AS CHAR             NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0011.p
    PERSISTENT SET h-b1wgen0011.

    IF  NOT VALID-HANDLE (h-b1wgen0011)  THEN
        RETURN "NOK".          

    ASSIGN aux_conteudo = "Favor proceder com a instrucao de " + par_dsdinstr + 
                          " no Gerenciador Financeiro para o titulo abaixo: " + 
                          "\n\n". 

    IF  AVAIL crapcco THEN
        DO:
            ASSIGN aux_conteudo = aux_conteudo + 
                                  "Conta BB: " + 
                                  STRING(crapcco.nrdctabb, "zzzz,zzz,9") + "\n".
        END.

    ASSIGN aux_conteudo = aux_conteudo + 
                          "Conta/DV    : " + 
                          STRING(bcrapcob.nrdconta, "zzzz,zzz,9") + "\n" +
                          "Nosso numero: " + bcrapcob.nrnosnum + "\n" + 
                          "Documento   : " + bcrapcob.dsdoccop + "\n" + 
                          "Vencimento  : " + 
                          STRING(bcrapcob.dtvencto, "99/99/9999") + "\n" +
                          "Valor       : " + 
                          STRING(bcrapcob.vltitulo, "zzz,zzz,zz9.99") + "\n\n".

    IF  par_dtaltvct <> ? THEN
        aux_conteudo = aux_conteudo + "\n" + 
                       "Novo vencimento : " + 
                       STRING(par_dtaltvct, "99/99/9999") + "\n\n".

    IF  par_vlaltabt > 0 THEN
        aux_conteudo = aux_conteudo + "\n" + 
                       "Abatimento : " + 
                       STRING(par_vlaltabt, "zzz,zzz,zz9.99") + "\n\n".
    
        RUN enviar_email_completo IN h-b1wgen0011
                    (INPUT bcrapcob.cdcooper,
                     INPUT "b1wgen0088",
                     INPUT "AILOS<ailos@ailos.coop.br>",
                     INPUT "cobranca@ailos.coop.br",
                     INPUT "Solicitacao de instrucao de " + par_dsdinstr,
                     INPUT "",
                     INPUT "",
                     INPUT aux_conteudo,
                     INPUT FALSE).
    
    DELETE PROCEDURE h-b1wgen0011.

    RETURN "OK".

END PROCEDURE.

PROCEDURE inst-conc-desconto:
    /* 07. Concessao de Desconto */
    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vldescto AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lat-consolidada.

    DEF          VAR aux_vltitabr AS DECI                           NO-UNDO.

    /* Processo de Validacao Recusas Padrao */
    RUN efetua-validacao-recusa-padrao (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrcnvcob,
                                        INPUT par_nrdocmto,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                        INPUT "07",
                                        INPUT par_nrremass,
                                        OUTPUT ret_dsinserr).

    IF RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    IF bcrapcob.cdbandoc = 085  AND
       bcrapcob.flgregis = TRUE AND 
       bcrapcob.flgcbdda AND 
       bcrapcob.insitpro <= 2 THEN
        DO:
            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XA",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Titulo em processo de registro. Favor aguardar".
            RETURN "NOK".
        END.

    /***** VALIDACOES PARA RECUSAR ******/
    
    /* Verifica se ja existe Pedido de Baixa */
    FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper
                        AND crapcre.nrcnvcob = par_nrcnvcob
                        AND crapcre.dtmvtolt = par_dtmvtolt
                        AND crapcre.intipmvt = 1
                        NO-LOCK NO-ERROR.

    IF  AVAIL crapcre THEN
        DO:
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.cdocorre = 2
                                AND craprem.dtaltera = par_dtmvtolt
                NO-LOCK NO-ERROR.
            IF  AVAIL craprem THEN
                DO:
                    RUN prepara-retorno-cooperado
                    			 (INPUT ROWID(bcrapcob),
                    			  INPUT 26,     /* Instrucao Rejeitada */
                    			  INPUT "XB",     /* Motivo */
                    			  INPUT 0,      /* Valor Tarifa */
                    			  INPUT crapcop.cdbcoctl,
                    			  INPUT crapcop.cdagectl,
                    			  INPUT par_dtmvtolt,
                    			  INPUT par_cdoperad,
                                  INPUT par_nrremass).

                    ret_dsinserr = "Pedido de Baixa ja efetuado - " +
                                   "Desconto nao efetuado!".
                    RETURN "NOK".
                END.
        END.

    CASE bcrapcob.insitcrt:
        WHEN 1 THEN DO:

            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XE",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto c/ Remessa a Cartorio - " + 
                           "Desconto nao efetuado!".
            RETURN "NOK".
        END.
        WHEN 3 THEN DO: 

            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XF",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto Em Cartorio - Desconto nao efetuado!".
            RETURN "NOK".
        END.

    END CASE.

    aux_vltitabr = bcrapcob.vltitulo - bcrapcob.vldescto - bcrapcob.vlabatim.

    IF  par_vldescto > aux_vltitabr THEN
        DO:
            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "29",   /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Valor de Desconto superior ao Valor do Boleto - " +
                           "Desconto nao efetuado!".
            RETURN "NOK".
        END.

    /* nao permitir conceder abatimento de titulo no convenio
       de protesto */
    IF (bcrapcob.cdbandoc <> crapcop.cdbcoctl) THEN
        DO:
            FIND FIRST crapcco 
                 WHERE crapcco.cdcooper = bcrapcob.cdcooper
                   AND crapcco.nrconven = bcrapcob.nrcnvcob
                   NO-LOCK NO-ERROR.
        
            IF AVAIL crapcco THEN
               IF crapcco.dsorgarq = "PROTESTO" THEN
                   DO:
                      RUN prepara-retorno-cooperado
                			 (INPUT ROWID(bcrapcob),
                			  INPUT 26,     /* Instrucao Rejeitada */
                			  INPUT "XG",     /* Motivo */
                			  INPUT 0,      /* Valor Tarifa */
                			  INPUT crapcop.cdbcoctl,
                			  INPUT crapcop.cdagectl,
                			  INPUT par_dtmvtolt,
                			  INPUT par_cdoperad,
                              INPUT par_nrremass).

                      ret_dsinserr = "Nao e permitido conceder " + 
                                     "desconto de boleto no convenio " + 
                                     "protesto - Desconto nao efetuado!".

                      RETURN "NOK".
                   END.
        END.

    /***** FIM - VALIDACOES PARA RECUSAR ******/

    IF  bcrapcob.flgcbdda AND
        bcrapcob.cdbandoc = crapcop.cdbcoctl  THEN
        DO:
            /* Executa procedimentos do DDA-JD */
            RUN procedimentos-dda-jd ( INPUT "A",
                                       INPUT "",
                                       INPUT bcrapcob.dtvencto,
                                       INPUT par_vldescto,
                                       INPUT bcrapcob.vlabatim,
                                       INPUT bcrapcob.flgdprot,
                                      OUTPUT ret_dsinserr).
    
            IF  RETURN-VALUE <> "OK"  THEN DO:

                RUN prepara-retorno-cooperado
                			 (INPUT ROWID(bcrapcob),
                			  INPUT 26,     /* Instrucao Rejeitada */
                			  INPUT "XC",     /* Motivo */
                			  INPUT 0,      /* Valor Tarifa */
                			  INPUT crapcop.cdbcoctl,
                			  INPUT crapcop.cdagectl,
                			  INPUT par_dtmvtolt,
                			  INPUT par_cdoperad,
                              INPUT par_nrremass).

                RETURN "NOK".
            END.
        END.

    /* tratamento para titulos migrados */
    IF  bcrapcob.flgregis = TRUE AND
        bcrapcob.cdbandoc = 001  THEN
        DO:
            FIND crapcco WHERE 
                 crapcco.cdcooper = bcrapcob.cdcooper AND
                 crapcco.nrconven = bcrapcob.nrcnvcob 
                 NO-LOCK NO-ERROR.

            IF  AVAIL crapcco THEN
                DO:
                    IF  CAN-DO("MIGRACAO,INCORPORACAO", crapcco.dsorgarq) THEN
                        DO:
                            RUN inst-titulo-migrado (INPUT "Desconto", 
                                                     INPUT ?, 
                                                     INPUT par_vldescto).
                                                              

                            ret_dsinserr = "Solicitacao de desconto de titulo " + 
                                           "migrado. Aguarde confirmacao no " + 
                                           "proximo dia util.".
                            RETURN "NOK".
                        END.
                END.
        END.


    DO TRANSACTION:

        FIND CURRENT bcrapcob EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
    
        FIND LAST tt-remessa-dda NO-LOCK NO-ERROR.

        ASSIGN bcrapcob.vldescto = par_vldescto
               bcrapcob.idopeleg = tt-remessa-dda.idopeleg
                                        WHEN AVAIL tt-remessa-dda.
    
        IF  bcrapcob.cdbandoc = 1 THEN
            DO:
                /** Verifica se ha instr. de Canc. Desconto no dia e elimina **/
                FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                    AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                    AND craprem.nrdconta = bcrapcob.nrdconta
                                    AND craprem.nrdocmto = bcrapcob.nrdocmto
                                    AND craprem.cdocorre = 8
                                    AND craprem.dtaltera = par_dtmvtolt
                    NO-LOCK NO-ERROR.

                IF  AVAIL craprem THEN
                    DO:
                        /*** LOG de Processo ***/
                        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT 'Exclusao Instrucao ' +
                                                     'Cancelamento de Desconto').
                        
                        /** Exclui o Instrucao de Remessa que ja existe **/
                        RUN pi-elimina-remessa (INPUT craprem.cdcooper,
                                                INPUT craprem.nrdconta,
                                                INPUT craprem.nrcnvcob,
                                                INPUT craprem.nrdocmto,
                                                INPUT craprem.cdocorre,
                                                INPUT craprem.dtaltera,
                                               OUTPUT ret_dsinserr).
                        IF  ret_dsinserr <> "" THEN
                            RETURN "NOK".
                    END.

                /* Verifica se ja existe Instr.Conc.Desconto e substitui */
                FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                    AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                    AND craprem.nrdconta = bcrapcob.nrdconta
                                    AND craprem.nrdocmto = bcrapcob.nrdocmto
                                    AND craprem.cdocorre = par_cdocorre /* 7. */
                                    AND craprem.dtaltera = par_dtmvtolt
                    NO-LOCK NO-ERROR.

                IF  AVAIL craprem THEN
                    DO:
                        /*** LOG de Processo ***/
                        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT 'Exclusao Instr.Conc.Desconto ' +
                                                     'Vlr: R$ ' +
                                               TRIM(STRING(craprem.vlabatim,"zzz9.99"))).
                        
                        /** Exclui o Instrucao de Remessa que ja existe **/
                        RUN pi-elimina-remessa (INPUT craprem.cdcooper,
                                                INPUT craprem.nrdconta,
                                                INPUT craprem.nrcnvcob,
                                                INPUT craprem.nrdocmto,
                                                INPUT craprem.cdocorre,
                                                INPUT craprem.dtaltera,
                                               OUTPUT ret_dsinserr).
                        IF  ret_dsinserr <> "" THEN
                            RETURN "NOK".
    
                    END.

                RUN prep-remessa-banco( INPUT bcrapcob.cdcooper,
                                        INPUT bcrapcob.nrcnvcob,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                       OUTPUT aux_nrremret,
                                       OUTPUT aux_nrseqreg).
        
                aux_nrseqreg = aux_nrseqreg + 1.
                RUN cria-tab-remessa( ROWID(bcrapcob),
                   /* nrremret */     aux_nrremret,
                   /* nrseqreg */     aux_nrseqreg,
                   /* cdocorre */     par_cdocorre, /* 7. Concessao de Desconto  */
                   /* cdmotivo */     "", 
                   /* dtdprorr */     ?,
                   /* vlabatim */     par_vldescto,
                   /* cdoperad */     par_cdoperad,
                   /* dtmvtolt */     par_dtmvtolt).
    
            END. /* FIM do IF cdbandoc = 1 */
        ELSE 
            IF  bcrapcob.cdbandoc = crapcop.cdbcoctl THEN 
                DO:
                    RUN prepara-retorno-cooperado
                                     (INPUT ROWID(bcrapcob),
                                      INPUT 7,   /* Conf. Receb. Instr. Desconto */
                                      INPUT "",  /* Motivo */
                                      INPUT 0,   /* Valor Tarifa */
                                      INPUT crapcop.cdbcoctl,
                                      INPUT crapcop.cdagectl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_cdoperad,
                                      INPUT par_nrremass).
    
                END. /* FIM do IF cdbandoc = 85 */

        /*** LOG de Processo ***/
        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT 'Concessao de Desconto Vlr: R$ ' +
                                      TRIM(STRING(par_vldescto,"zzzz9.99"))).

        IF bcrapcob.cdbandoc = 85 THEN DO:

            /* Gerar registro Tarifa */
            CREATE tt-lat-consolidada.
            ASSIGN tt-lat-consolidada.cdcooper = par_cdcooper
                   tt-lat-consolidada.nrdconta = par_nrdconta
                   tt-lat-consolidada.nrdocmto = par_nrdocmto
                   tt-lat-consolidada.nrcnvcob = par_nrcnvcob
                   tt-lat-consolidada.dsincide = "RET"
                   tt-lat-consolidada.cdocorre = 07     /* 07 - Conf. Receb. Instr. Desconto */
                   tt-lat-consolidada.cdmotivo = ""     /* Motivo */
                   tt-lat-consolidada.vllanmto = bcrapcob.vltitulo.
        END.

    END. /* final da transaction */

    RETURN "OK".

END PROCEDURE.

PROCEDURE inst-canc-desconto:
    /* 08. Cancelar Desconto */
    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lat-consolidada.

    /* Processo de Validacao Recusas Padrao */
    RUN efetua-validacao-recusa-padrao (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrcnvcob,
                                        INPUT par_nrdocmto,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                        INPUT "08",
                                        INPUT par_nrremass,
                                        OUTPUT ret_dsinserr).

    IF RETURN-VALUE = "NOK" THEN
        RETURN "NOK".
    
    
    IF bcrapcob.cdbandoc = 085  AND
       bcrapcob.flgregis = TRUE AND 
       bcrapcob.flgcbdda AND 
       bcrapcob.insitpro <= 2 THEN
        DO:
            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XA",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Titulo em processo de registro. Favor aguardar".
            RETURN "NOK".
        END.

    /***** VALIDACOES PARA RECUSAR ******/
    
    CASE bcrapcob.insitcrt:
        WHEN 1 THEN DO:
            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XE",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto c/ Remessa a Cartorio - " + 
                           "Canc. Desconto nao efetuado!".
            RETURN "NOK".
        END.
        WHEN 3 THEN DO: 
            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XF",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto Em Cartorio - Canc. Desconto nao efetuado!".
            RETURN "NOK".
        END.

    END CASE.

    /* Verifica se ja existe Pedido de Baixa */
    FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper
                        AND crapcre.nrcnvcob = par_nrcnvcob
                        AND crapcre.dtmvtolt = par_dtmvtolt
                        AND crapcre.intipmvt = 1
                        NO-LOCK NO-ERROR.

    IF  AVAIL crapcre THEN
        DO:
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.cdocorre = 2
                                AND craprem.dtaltera = par_dtmvtolt
                                NO-LOCK NO-ERROR.

            IF  AVAIL craprem THEN
                DO:
                    RUN prepara-retorno-cooperado
                    			 (INPUT ROWID(bcrapcob),
                    			  INPUT 26,     /* Instrucao Rejeitada */
                    			  INPUT "XB",     /* Motivo */
                    			  INPUT 0,      /* Valor Tarifa */
                    			  INPUT crapcop.cdbcoctl,
                    			  INPUT crapcop.cdagectl,
                    			  INPUT par_dtmvtolt,
                    			  INPUT par_cdoperad,
                                  INPUT par_nrremass).

                    ret_dsinserr = "Pedido de Baixa ja efetuado - " +
                                   "Canc. Desconto nao efetuado!".
                    RETURN "NOK".
                END.
        END.

    IF  bcrapcob.vldescto = 0 THEN
        DO:
            RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "A7",   /* "Titulo ja se encontra na situacao Pretendida" */ 
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).

            ret_dsinserr = "Boleto sem Valor de Desconto - " +
                           "Canc. Desconto nao efetuado!".
            RETURN "NOK".
        END.
    /***** FIM - VALIDACOES PARA RECUSAR ******/

    IF  bcrapcob.flgcbdda AND
        bcrapcob.cdbandoc = crapcop.cdbcoctl  THEN 
        DO:
            /* Executa procedimentos do DDA-JD */
            RUN procedimentos-dda-jd ( INPUT "A",
                                       INPUT "",
                                       INPUT bcrapcob.dtvencto,
                                       INPUT 0,
                                       INPUT bcrapcob.vlabatim,
                                       INPUT bcrapcob.flgdprot,
                                      OUTPUT ret_dsinserr).
        
            IF  RETURN-VALUE <> "OK"  THEN DO:

                RUN prepara-retorno-cooperado
                			 (INPUT ROWID(bcrapcob),
                			  INPUT 26,     /* Instrucao Rejeitada */
                			  INPUT "XC",     /* Motivo */
                			  INPUT 0,      /* Valor Tarifa */
                			  INPUT crapcop.cdbcoctl,
                			  INPUT crapcop.cdagectl,
                			  INPUT par_dtmvtolt,
                			  INPUT par_cdoperad,
                              INPUT par_nrremass).

                RETURN "NOK".
            END.
        END.

    /* tratamento para titulos migrados */
    IF  bcrapcob.flgregis = TRUE AND
        bcrapcob.cdbandoc = 001  THEN
        DO:
            FIND crapcco WHERE 
                 crapcco.cdcooper = bcrapcob.cdcooper AND
                 crapcco.nrconven = bcrapcob.nrcnvcob 
                 NO-LOCK NO-ERROR.

            IF  AVAIL crapcco THEN
                DO:
                    IF  CAN-DO("MIGRACAO,INCORPORACAO", crapcco.dsorgarq) THEN
                        DO:
                            RUN inst-titulo-migrado 
                                (INPUT "Cancelamento de Desconto", 
                                 INPUT ?, 
                                 INPUT 0).

                            ret_dsinserr = "Solicitacao de cancelamento de " + 
                                           "desconto de titulo " + 
                                           "migrado. Aguarde confirmacao no " + 
                                           "proximo dia util.".
                            RETURN "NOK".
                        END.
                END.
        END.


    DO TRANSACTION:

        FIND CURRENT bcrapcob EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        FIND LAST tt-remessa-dda NO-LOCK NO-ERROR.

        ASSIGN bcrapcob.idopeleg = tt-remessa-dda.idopeleg WHEN AVAIL tt-remessa-dda.

        /* Cancela o abatimento concedido anteriormente */
        IF  bcrapcob.vldescto > 0 THEN
            bcrapcob.vldescto = 0.
    
        IF  bcrapcob.cdbandoc = 1 THEN 
            DO:
                /* Verifica se tem instrucao de desconto e exclui */
                FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                    AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                    AND craprem.nrdconta = bcrapcob.nrdconta
                                    AND craprem.nrdocmto = bcrapcob.nrdocmto
                                    AND craprem.cdocorre = 7
                                    AND craprem.dtaltera = par_dtmvtolt
                                    NO-LOCK NO-ERROR.
            
                IF  AVAIL craprem THEN
                    DO:
                        /*** LOG de Processo ***/
                        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT 'Exclusao Instrucao  ' +
                                                     'Concessao de Desconto').
                        
                        /** Exclui o Instrucao de Remessa que ja existe **/
                        RUN pi-elimina-remessa (INPUT craprem.cdcooper,
                                                INPUT craprem.nrdconta,
                                                INPUT craprem.nrcnvcob,
                                                INPUT craprem.nrdocmto,
                                                INPUT craprem.cdocorre,
                                                INPUT craprem.dtaltera,
                                               OUTPUT ret_dsinserr).
                        
                        IF  ret_dsinserr <> "" THEN
                            RETURN "NOK".
                    END.
            
                /* Verifica se ja existe Instr.Canc.Desconto e substitui */
                FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                    AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                    AND craprem.nrdconta = bcrapcob.nrdconta
                                    AND craprem.nrdocmto = bcrapcob.nrdocmto
                                    AND craprem.cdocorre = par_cdocorre /* 8. */
                                    AND craprem.dtaltera = par_dtmvtolt
                                    NO-LOCK NO-ERROR.

                IF  AVAIL craprem THEN
                    DO:
                        /*** LOG de Processo ***/
                        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                                               INPUT par_cdoperad,
                                               INPUT par_dtmvtolt,
                                               INPUT 'Exclusao Instrucao '+
                                                     'Cancelamento de Desconto').
                        
                        /** Exclui o Instrucao de Remessa que ja existe **/
                        RUN pi-elimina-remessa (INPUT craprem.cdcooper,
                                                INPUT craprem.nrdconta,
                                                INPUT craprem.nrcnvcob,
                                                INPUT craprem.nrdocmto,
                                                INPUT craprem.cdocorre,
                                                INPUT craprem.dtaltera,
                                               OUTPUT ret_dsinserr).
                        IF  ret_dsinserr <> "" THEN
                            RETURN "NOK".
                        
                    END.
            
                RUN prep-remessa-banco( INPUT bcrapcob.cdcooper,
                                        INPUT bcrapcob.nrcnvcob,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                       OUTPUT aux_nrremret,
                                       OUTPUT aux_nrseqreg).
            
                aux_nrseqreg = aux_nrseqreg + 1.

                RUN cria-tab-remessa( ROWID(bcrapcob),
                   /* nrremret */     aux_nrremret,
                   /* nrseqreg */     aux_nrseqreg,
                   /* cdocorre */     par_cdocorre, /* 08 - Cancelamento de Desconto */
                   /* cdmotivo */     "", 
                   /* dtdprorr */     ?,
                   /* vlabatim */     0,
                   /* cdoperad */     par_cdoperad,
                   /* dtmvtolt */     par_dtmvtolt).
            
            END. /* FIM do IF cdbandoc = 1 */
        ELSE 
            IF  bcrapcob.cdbandoc = crapcop.cdbcoctl THEN 
                DO:
                    RUN prepara-retorno-cooperado
                                     (INPUT ROWID(bcrapcob),
                                      INPUT 8,    /* Confirmacao do Recebimento do Cancelamento do Desconto */
                                      INPUT "",   /* Motivo */
                                      INPUT 0,    /* Valor Tarifa */
                                      INPUT crapcop.cdbcoctl,
                                      INPUT crapcop.cdagectl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_cdoperad,
                                      INPUT par_nrremass).
                    
                END. /* FIM do IF cdbandoc = 85 */

        /*** LOG de Processo ***/
        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT "Cancelamento de Desconto").

        IF bcrapcob.cdbandoc = 85 THEN DO:

            /* Gerar registro Tarifa */
            CREATE tt-lat-consolidada.
            ASSIGN tt-lat-consolidada.cdcooper = par_cdcooper
                   tt-lat-consolidada.nrdconta = par_nrdconta
                   tt-lat-consolidada.nrdocmto = par_nrdocmto
                   tt-lat-consolidada.nrcnvcob = par_nrcnvcob
                   tt-lat-consolidada.dsincide = "RET"
                   tt-lat-consolidada.cdocorre = 08     /* Confirmação do Recebimento do Cancelamento do Desconto  */
                   tt-lat-consolidada.cdmotivo = ""     /* Motivo */
                   tt-lat-consolidada.vllanmto = bcrapcob.vltitulo.
        END.

    END.

    RETURN "OK".

END PROCEDURE.

PROCEDURE verifica-horario-cobranca:

    DEF INPUT  PARAM par_cdcooper       LIKE crapcob.cdcooper       NO-UNDO.
    DEF OUTPUT PARAM par_dscritic       AS CHAR                     NO-UNDO.

    RUN sistema/generico/procedures/b1wgen0015.p
        PERSISTENT SET h-b1wgen0015.

    IF  NOT VALID-HANDLE(h-b1wgen0015) THEN
        DO:
            par_dscritic = "Erro ao inicializar b1wgen0015.".
            RETURN "NOK".
        END.

    RUN horario_operacao IN h-b1wgen0015
        (INPUT par_cdcooper,
         INPUT 90, /* 90 = internetbanking */
         INPUT 3, /* tpoperac = 3 -> cobranca */
         INPUT 0, /* inpessoa */
        OUTPUT par_dscritic,
        OUTPUT TABLE tt-limite).

    IF  RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    FIND FIRST tt-limite NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-limite  THEN
    DO:
        IF  tt-limite.idesthor = 2 THEN /* dentro do limite de horario = 2 */
            DO:
                IF  VALID-HANDLE(h-b1wgen0015) THEN
                    DELETE PROCEDURE h-b1wgen0015.

                RETURN "OK".
            END.

        par_dscritic = "Este tipo de instrucao eh permitido apenas " +
                       "no horario: " + 
                       tt-limite.hrinipag + " ate " + 
                       tt-limite.hrfimpag + ".".

        IF  VALID-HANDLE(h-b1wgen0015) THEN
            DELETE PROCEDURE h-b1wgen0015.

        RETURN "NOK".
    END.             

    IF  VALID-HANDLE(h-b1wgen0015) THEN
        DELETE PROCEDURE h-b1wgen0015.

    RETURN "OK".

END PROCEDURE.

PROCEDURE verifica-ent-confirmada:

    DEF OUTPUT PARAM par_dscritic               AS CHAR                 NO-UNDO.

    /* verificar se titulo BB tem confirmacao de entrada */
    IF  AVAIL bcrapcob THEN
        DO:
            FIND FIRST crapret WHERE 
                       crapret.cdcooper = bcrapcob.cdcooper AND
                       crapret.nrdconta = bcrapcob.nrdconta AND
                       crapret.nrcnvcob = bcrapcob.nrcnvcob AND
                       crapret.nrdocmto = bcrapcob.nrdocmto AND
                       crapret.cdocorre = 2 /* Entrada Confirmada */
                       NO-LOCK NO-ERROR.
            
            IF  NOT AVAIL crapret THEN
                DO:
                    par_dscritic = "Titulo sem confirmacao de " + 
                                   "registro pelo Banco do Brasil.".
                    RETURN "NOK".
                END.
        END.

    RETURN "OK".

END PROCEDURE.


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


PROCEDURE prepara-retorno-cooperado:

    /* Rotina para gravar retorno do cooperado */

    DEF INPUT PARAM par_idtabcob AS ROWID                           NO-UNDO.
    DEF INPUT PARAM par_cdocorre AS INTE                            NO-UNDO.
    DEF INPUT PARAM par_cdmotivo AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_vltarifa AS DECI                            NO-UNDO.
    DEF INPUT PARAM par_cdbcoctl LIKE crapcop.cdbcoctl              NO-UNDO.
    DEF INPUT PARAM par_cdagectl LIKE crapcop.cdagectl              NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                            NO-UNDO.
    DEF INPUT PARAM par_nrremass AS INTE                            NO-UNDO.

    IF  NOT VALID-HANDLE(h-b1wgen0090)  THEN
        RUN sistema/generico/procedures/b1wgen0090.p PERSISTENT SET h-b1wgen0090.

    RUN prep-retorno-cooperado IN h-b1wgen0090
                                     (INPUT par_idtabcob,
                                      INPUT par_cdocorre,
                                      INPUT par_cdmotivo, 
                                      INPUT par_vltarifa,
                                      INPUT par_cdbcoctl,
                                      INPUT par_cdagectl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_cdoperad,
                                      INPUT par_nrremass).
    
    IF VALID-HANDLE(h-b1wgen0090)  THEN
        DELETE PROCEDURE h-b1wgen0090.


END PROCEDURE.


PROCEDURE efetua-validacao-recusa-padrao:

    /* Procedure responsavel em efetuar validacao padrao dos motivos de recusa:
      04 - Codigo de Movimento Nao Permitido para Carteira 
      40 - Titulo com Ordem de Protesto Emitida
      60 - Movimento para Titulo Nao Cadastrado 
      A5 - Registro Rejeitado – Título ja Liquidado */

    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdinstru AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    DEF    VAR       aux_cdacesso AS CHAR                           NO-UNDO.
    DEF    VAR       aux_qtdiacar AS INTE                           NO-UNDO.
    DEF    VAR       aux_dtcalcul AS DATE                           NO-UNDO.

    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    FIND FIRST crapcco WHERE crapcco.cdcooper = par_cdcooper
                         AND crapcco.nrconven = par_nrcnvcob
                         NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcco THEN DO:
        ret_dsinserr = "Registro de cobranca nao encontrado!".
        RETURN "NOK".
    END.

    FIND FIRST bcrapcob WHERE bcrapcob.cdcooper = par_cdcooper
                          AND bcrapcob.cdbandoc = crapcco.cddbanco
                          AND bcrapcob.nrdctabb = crapcco.nrdctabb
                          AND bcrapcob.nrdconta = par_nrdconta
                          AND bcrapcob.nrcnvcob = par_nrcnvcob
                          AND bcrapcob.nrdocmto = par_nrdocmto
                          NO-LOCK NO-ERROR.

    IF  AVAIL bcrapcob THEN
        DO:
        
            IF (bcrapcob.nrctremp > 0) THEN
                DO:
                    IF ( par_cdinstru = "09" ) THEN
                        DO:
                            IF  par_cdoperad = "1" THEN
                                RETURN "OK".

                            /* procurar permissao na crapace */
                            FIND crapace WHERE crapace.cdcooper = par_cdcooper
				                           AND CAPS(crapace.cdoperad) = CAPS(par_cdoperad)
                                           AND CAPS(crapace.nmdatela) = "COBEMP"
					                       AND crapace.idambace = 2     
					                       AND CAPS(crapace.cddopcao) = "B"
                                       NO-LOCK NO-ERROR.
  

                            IF  AVAIL crapace THEN
                                DO:
                                    RETURN "OK".
                                END.
                            ELSE
                                DO:
                                    RUN prepara-retorno-cooperado
                                         (INPUT ROWID(bcrapcob),
                                          INPUT 26,     /* Instrucao Rejeitada */
                                          INPUT "XV",   /* Motivo Operador nao possui permissao para este tipo de instrucao */
                                          INPUT 0,      /* Valor Tarifa */
                                          INPUT crapcop.cdbcoctl,
                                          INPUT crapcop.cdagectl,
                                          INPUT par_dtmvtolt,
                                          INPUT par_cdoperad,
                                          INPUT par_nrremass).
                    
                                    RETURN "NOK".              
                                END.                                                                  
                          
                        END.
                    ELSE
                        DO:
                            RUN prepara-retorno-cooperado
                                 (INPUT ROWID(bcrapcob),
                                  INPUT 26,     /* Instrucao Rejeitada */
                                  INPUT "XV",   /* Motivo Operador nao possui permissao para este tipo de instrucao */
                                  INPUT 0,      /* Valor Tarifa */
                                  INPUT crapcop.cdbcoctl,
                                  INPUT crapcop.cdagectl,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdoperad,
                                  INPUT par_nrremass).
            
                            RETURN "NOK".              
                        END.
                END.
            
            /* ---------------- Validacao Horarios ---------------- */

            IF ( par_cdinstru = "02" ) THEN
            DO:
                /* Titulos BB possuem horario limite de comando da instrucao,
                   exceto para o operador "1" */
                IF  par_cdoperad <> "1" THEN
                    DO:
                        IF  bcrapcob.cdbandoc = 001 THEN
                            DO:
                                RUN verifica-horario-cobranca
                                    (INPUT bcrapcob.cdcooper,
                                    OUTPUT ret_dsinserr).
            
                                IF  RETURN-VALUE = "NOK" THEN
                                DO:
                                    RUN prepara-retorno-cooperado
                                         (INPUT ROWID(bcrapcob),
                                          INPUT 26,     /* Instrucao Rejeitada */
                                          INPUT "XN",     /* Motivo */
                                          INPUT 0,      /* Valor Tarifa */
                                          INPUT crapcop.cdbcoctl,
                                          INPUT crapcop.cdagectl,
                                          INPUT par_dtmvtolt,
                                          INPUT par_cdoperad,
                                          INPUT par_nrremass).
    
                                    RETURN "NOK".
                                END.
                            END.
                    END.
            END.
            ELSE
                IF ( par_cdinstru = "09" ) THEN /* Protestar */
                DO:
                    /* Instrucao de protesto possui horario limite de comando da instrucao 
                       exceto para o operador "1" */

                    IF  par_cdoperad <> "1" THEN
                        DO:
                            RUN verifica-horario-cobranca
                                (INPUT bcrapcob.cdcooper,
                                OUTPUT ret_dsinserr).
                
                            IF  RETURN-VALUE = "NOK" THEN
                            DO:
                                RUN prepara-retorno-cooperado
                                     (INPUT ROWID(bcrapcob),
                                      INPUT 26,     /* Instrucao Rejeitada */
                                      INPUT "XN",     /* Motivo */
                                      INPUT 0,      /* Valor Tarifa */
                                      INPUT crapcop.cdbcoctl,
                                      INPUT crapcop.cdagectl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_cdoperad,
                                      INPUT par_nrremass).

                                RETURN "NOK".
                            END.
                                
                        END.
                END.
                ELSE /* "04", "05", "06", "07", "08", "11", "41" */
                DO: 
                    /* Titulos BB possuem horario limite de comando da instrucao */
                    IF  bcrapcob.cdbandoc = 001 THEN
                        DO:
                            RUN verifica-horario-cobranca
                                (INPUT bcrapcob.cdcooper,
                                OUTPUT ret_dsinserr).
                
                            IF  RETURN-VALUE = "NOK" THEN
                            DO:
                                RUN prepara-retorno-cooperado
                                     (INPUT ROWID(bcrapcob),
                                      INPUT 26,     /* Instrucao Rejeitada */
                                      INPUT "XN",     /* Motivo */
                                      INPUT 0,      /* Valor Tarifa */
                                      INPUT crapcop.cdbcoctl,
                                      INPUT crapcop.cdagectl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_cdoperad,
                                      INPUT par_nrremass).

                                RETURN "NOK".
                            END.
                        END.
                END.
            /* ---------------------------------------------------- */

            /* ----------- Validacao Entrada Confirmada ----------- */

            IF ( par_cdinstru <> "02" ) THEN /* Nao efetua validacao no caso de Pedido de Baixa*/
            DO:
                /* Verificar se Titulo BB tem Confirmacao de Entrada */
                IF  bcrapcob.cdbandoc = 001 THEN
                    DO:
                        RUN verifica-ent-confirmada (OUTPUT ret_dsinserr).
            
                        IF  RETURN-VALUE = "NOK" THEN DO:

                            RUN prepara-retorno-cooperado
                                         (INPUT ROWID(bcrapcob),
                                          INPUT 26,     /* Instrucao Rejeitada */
                                          INPUT "XO",     /* Motivo */
                                          INPUT 0,      /* Valor Tarifa */
                                          INPUT crapcop.cdbcoctl,
                                          INPUT crapcop.cdagectl,
                                          INPUT par_dtmvtolt,
                                          INPUT par_cdoperad,
                                          INPUT par_nrremass).

                            RETURN "NOK".
                        END.
                    END.
            END.

            /* -------------------------------------------------- */



            /* GGS - Inicio */
      			FIND crapass WHERE crapass.cdcooper = bcrapcob.cdcooper AND
      							   crapass.nrdconta = bcrapcob.nrdconta
      							   NO-LOCK NO-ERROR.

      			 IF  NOT AVAILABLE crapass  THEN
      				 RETURN "NOK".
      			

      			IF crapass.inpessoa = 1 THEN /* Pessoa Física */
      			DO:
      			  IF (bcrapcob.flgregis) THEN /* Cobrança com Regisro */
      				aux_cdacesso = "LIMDESCTITCRPF".
            ELSE
      				aux_cdacesso = "LIMDESCTITPF".		  	
      			END.
            ELSE
      			DO:	
      			  IF crapass.inpessoa = 2 THEN /* Pessoa Jurídica */
      			  DO: 	
      				IF (bcrapcob.flgregis) THEN /* Cobrança com Regisro */
      				  aux_cdacesso = "LIMDESCTITCRPJ".
      				ELSE 
      				  aux_cdacesso = "LIMDESCTITPJ".
      			  END.		
      			END.
            /* GGS - Fim */			
			  

            FIND craptab WHERE 
                 craptab.cdcooper = bcrapcob.cdcooper  AND
                 craptab.nmsistem = "CRED"             AND
                 craptab.tptabela = "USUARI"           AND
                 craptab.cdempres = 11                 AND
                 craptab.cdacesso = aux_cdacesso       AND
                 craptab.tpregist = 0
                 NO-LOCK NO-ERROR.

            IF NOT AVAILABLE craptab   THEN
              ASSIGN aux_qtdiacar = 0.
            ELSE
              ASSIGN aux_qtdiacar = INTE(ENTRY(32,craptab.dstextab,";")).

            FIND craptdb WHERE  craptdb.cdcooper = bcrapcob.cdcooper AND
                                craptdb.nrdconta = bcrapcob.nrdconta AND
                                craptdb.cdbandoc = bcrapcob.cdbandoc AND
                                craptdb.nrdctabb = bcrapcob.nrdctabb AND
                                craptdb.nrcnvcob = bcrapcob.nrcnvcob AND
                                craptdb.nrdocmto = bcrapcob.nrdocmto
                                NO-LOCK NO-ERROR.
            IF AVAIL craptdb THEN
            DO:
              ASSIGN aux_dtcalcul = craptdb.dtvencto + aux_qtdiacar.

              DO WHILE TRUE:         
                aux_dtcalcul = aux_dtcalcul + 1.
          
                IF  LOOKUP(STRING(WEEKDAY(aux_dtcalcul)),"1,7") <> 0   THEN
                  NEXT.

                IF  CAN-FIND(crapfer WHERE 
                             crapfer.cdcooper = bcrapcob.cdcooper       AND
                             crapfer.dtferiad = aux_dtcalcul)  THEN
                  NEXT.
          
                LEAVE.
              END.
            END.

            IF AVAIL craptdb AND
            /* e a situação é em estudo e não esta vencido */
            ( (craptdb.insittit = 0 AND aux_dtcalcul >= par_dtmvtolt) OR
              (craptdb.insittit = 4 )) THEN
              DO:
                  RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "04",   /* "Codigo de Movimento Nao Permitido para Carteira" */ 
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).  

                  ret_dsinserr = "Instrucao Rejeitada - Titulo descontado!".
                  RETURN "NOK".
              END.
        END.
    ELSE
        DO:
            RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "60",   /* "Movimento para Titulo Nao Cadastrado" */ 
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).

            ret_dsinserr = "Registro de cobranca nao encontrado!".
            RETURN "NOK".
        END.

    
    CASE bcrapcob.incobran:

        WHEN 3 THEN DO:
            IF  bcrapcob.insitcrt <> 5 THEN
            DO:
                RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "XP",     /* Motivo */
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).

                ret_dsinserr = "Instrucao Rejeitada - Boleto Baixado!".
                RETURN "NOK".
            END.
            ELSE
            DO:
                RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "40",   /* "Titulo com Ordem de Protesto Emitida" */ 
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).
            
                ret_dsinserr = "Instrucao Rejeitada - Boleto Protestado!".
                RETURN "NOK".
            END.
        END.
        WHEN 5 THEN DO: 
            IF bcrapcob.vldpagto > 0 THEN
            DO:
                RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "A5",   /* "Registro Rejeitado – Titulo ja Liquidado" */ 
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).

                ret_dsinserr = "Instrucao Rejeitada - Boleto Liquidado!".
                RETURN "NOK".
            END.
        END.

    END CASE.

    IF ( par_cdinstru <> "02" ) AND /* Baixa                    */
       ( par_cdinstru <> "04" ) AND /* Concessao de Abatimento  */
       ( par_cdinstru <> "05" ) AND /* Cancelar Abatimento      */ 
       ( par_cdinstru <> "31" ) AND /* Alterar Dados do Pagador */
       ( par_cdinstru <> "94" ) THEN
    DO:
        IF bcrapcob.inserasa <> 0 AND
           bcrapcob.inserasa <> 6 THEN
        DO:
            /*
            RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "A5",   /* "Registro Rejeitado – Titulo ja Liquidado" */ 
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).
                              */

            ret_dsinserr = "Instrucao Rejeitada - Boleto esta na Serasa!".
            RETURN "NOK".
        END.
       /* Zimmermann */
    END.
    /* exceto “Baixar”, “Conceder Abatimento”, “Cancelar Abatimento”, “Alterar Dados do Pagador” e “Cancelar Neg Serasa”) */

    RETURN "OK".

END PROCEDURE.



PROCEDURE inst-alt-outros-dados-arq-rem-085:
    /* 31. Alterar Dados do Sacado - Especifico para Arquivo Remessa 085*/
    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS DECI                           NO-UNDO.

    DEF  INPUT PARAM par_nrinssac AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dsendsac AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmbaisac AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrcepsac AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nmcidsac AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdufsaca AS CHAR                           NO-UNDO.

    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lat-consolidada.

    FIND FIRST crapcop WHERE crapcop.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    FIND FIRST crapcco WHERE crapcco.cdcooper = par_cdcooper
                         AND crapcco.nrconven = par_nrcnvcob
                         NO-LOCK NO-ERROR.

    IF NOT AVAIL crapcco THEN DO:
        ret_dsinserr = "Registro de cobranca nao encontrado".
        RETURN "NOK".
    END.

    FIND FIRST bcrapcob WHERE bcrapcob.cdcooper = par_cdcooper
                          AND bcrapcob.cdbandoc = crapcco.cddbanco
                          AND bcrapcob.nrdctabb = crapcco.nrdctabb
                          AND bcrapcob.nrdconta = par_nrdconta
                          AND bcrapcob.nrcnvcob = par_nrcnvcob
                          AND bcrapcob.nrdocmto = par_nrdocmto
                          NO-LOCK NO-ERROR.
    
    IF  NOT AVAIL bcrapcob THEN
        DO:
            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XQ",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Registro de cobranca nao encontrado".
            RETURN "NOK".
        END.

    
    IF  bcrapcob.cdbandoc = 085  AND
        bcrapcob.flgregis = TRUE AND 
        bcrapcob.flgcbdda AND 
        bcrapcob.insitpro <= 2 THEN
        DO:
            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XA",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Titulo em processo de registro. Favor aguardar".
            RETURN "NOK".
        END.

    /***** VALIDACOES PARA RECUSAR ******/
    CASE bcrapcob.incobran:

        WHEN 3 THEN DO:
            IF  bcrapcob.insitcrt <> 5 THEN
                ret_dsinserr = "Boleto Baixado - Alteracao nao efetuada!".
            ELSE
                ret_dsinserr = "Boleto Protestado - Alteracao nao efetuada!".

            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XP",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            RETURN "NOK".
        END.
        WHEN 5 THEN DO: 

            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "A5",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto Liquidado - Alteracao nao efetuada!".
            RETURN "NOK".
        END.

    END CASE.

    CASE bcrapcob.insitcrt:
        WHEN 1 THEN DO:

            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XE",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto c/ Remessa a Cartorio - " + 
                           "Alteracao nao efetuado!".
            RETURN "NOK".
        END.
        WHEN 3 THEN DO: 

            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XF",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto Em Cartorio - Alteracao nao efetuado!".
            RETURN "NOK".
        END.

    END CASE.

    /* Verifica se ja existe Pedido de Baixa */
    FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper
                        AND crapcre.nrcnvcob = par_nrcnvcob
                        AND crapcre.dtmvtolt = par_dtmvtolt
                        AND crapcre.intipmvt = 1
                        NO-LOCK NO-ERROR.

    IF  AVAIL crapcre THEN
        DO:
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.cdocorre = 31
                                AND craprem.dtaltera = par_dtmvtolt
                                NO-LOCK NO-ERROR.

            IF  AVAIL craprem THEN
                DO:
                    RUN prepara-retorno-cooperado
                    			 (INPUT ROWID(bcrapcob),
                    			  INPUT 26,     /* Instrucao Rejeitada */
                    			  INPUT "XR",     /* Motivo */
                    			  INPUT 0,      /* Valor Tarifa */
                    			  INPUT crapcop.cdbcoctl,
                    			  INPUT crapcop.cdagectl,
                    			  INPUT par_dtmvtolt,
                    			  INPUT par_cdoperad,
                                  INPUT par_nrremass).

                    ret_dsinserr = "Alteracao ja efetuada!".
                    RETURN "NOK".
                END.
        END.

    /***** FIM - VALIDACOES PARA RECUSAR ******/

    IF  bcrapcob.flgcbdda AND
        bcrapcob.cdbandoc = crapcop.cdbcoctl  THEN 
        DO:
            /* Executa procedimentos do DDA-JD */
            RUN procedimentos-dda-jd ( INPUT "A",
                                       INPUT "",
                                       INPUT bcrapcob.dtvencto, 
                                       INPUT bcrapcob.vldescto,
                                       INPUT bcrapcob.vlabatim,
                                       INPUT bcrapcob.flgdprot,
                                      OUTPUT ret_dsinserr).
        
            IF  RETURN-VALUE <> "OK"  THEN DO:

                RUN prepara-retorno-cooperado
                			 (INPUT ROWID(bcrapcob),
                			  INPUT 26,     /* Instrucao Rejeitada */
                			  INPUT "XC",     /* Motivo */
                			  INPUT 0,      /* Valor Tarifa */
                			  INPUT crapcop.cdbcoctl,
                			  INPUT crapcop.cdagectl,
                			  INPUT par_dtmvtolt,
                			  INPUT par_cdoperad,
                              INPUT par_nrremass).
                RETURN "NOK".
            END.
        END.

    /*  Verifica se Sacado possui registro */
        FIND crapsab WHERE crapsab.cdcooper = par_cdcooper AND
                           crapsab.nrdconta = par_nrdconta AND
                           crapsab.nrinssac = par_nrinssac NO-LOCK NO-ERROR.


        IF NOT AVAIL(crapsab) THEN DO:

            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XS",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Solicitacao de alteracao de " + 
                           "dados nao efetuada. Pagador nao " + 
                           "encontrado.".
            RETURN "NOK".
        END.



    DO TRANSACTION:
        FIND crapsab WHERE crapsab.cdcooper = par_cdcooper AND
                           crapsab.nrdconta = par_nrdconta AND
                           crapsab.nrinssac = par_nrinssac EXCLUSIVE-LOCK NO-ERROR.

        ASSIGN crapsab.dsendsac = par_dsendsac WHEN par_dsendsac <> crapsab.dsendsac
               crapsab.nrendsac = 0            WHEN par_dsendsac <> crapsab.dsendsac 
               crapsab.nmbaisac = par_nmbaisac WHEN par_nmbaisac <> crapsab.nmbaisac
               crapsab.nrcepsac = par_nrcepsac WHEN par_nrcepsac <> crapsab.nrcepsac 
               crapsab.nmcidsac = par_nmcidsac WHEN par_nmcidsac <> crapsab.nmcidsac
               crapsab.cdufsaca = par_cdufsaca WHEN par_cdufsaca <> crapsab.cdufsaca.

        FIND CURRENT bcrapcob EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        FIND LAST tt-remessa-dda NO-LOCK NO-ERROR.

        ASSIGN bcrapcob.idopeleg = tt-remessa-dda.idopeleg WHEN AVAIL tt-remessa-dda.
        
        IF  bcrapcob.cdbandoc = 1 THEN 
            DO:
                RUN prep-remessa-banco( INPUT bcrapcob.cdcooper,
                                        INPUT bcrapcob.nrcnvcob,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                       OUTPUT aux_nrremret,
                                       OUTPUT aux_nrseqreg).
            
                aux_nrseqreg = aux_nrseqreg + 1.

                RUN cria-tab-remessa( ROWID(bcrapcob),
                   /* nrremret */     aux_nrremret,
                   /* nrseqreg */     aux_nrseqreg,
                   /* cdocorre */     par_cdocorre, /* 31. Alteracao de Outros Dados */
                   /* cdmotivo */     "", 
                   /* dtdprorr */     ?,
                   /* vlabatim */     0,
                   /* cdoperad */     par_cdoperad,
                   /* dtmvtolt */     par_dtmvtolt).
            
            END. /* FIM do IF cdbandoc = 1 */
        ELSE 
            IF  bcrapcob.cdbandoc = crapcop.cdbcoctl THEN 
                DO:
                    RUN prepara-retorno-cooperado
                                     (INPUT ROWID(bcrapcob),
                                      INPUT 27,   /* Conf. Alteracao de Outros Dados */
                                      INPUT "",   /* Motivo */
                                      INPUT 0,    /* Valor Tarifa */
                                      INPUT crapcop.cdbcoctl,
                                      INPUT crapcop.cdagectl,
                                      INPUT par_dtmvtolt,
                                      INPUT par_cdoperad,
                                      INPUT par_nrremass).
                    
                END. /* FIM do IF cdbandoc = 85 */

        

        /*** LOG de Processo ***/
        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                               INPUT par_cdoperad,
                               INPUT par_dtmvtolt,
                               INPUT "Alteracao de dados do Pagador").

        IF bcrapcob.cdbandoc = 85 THEN DO:

            /* Gerar registro Tarifa */
            CREATE tt-lat-consolidada.
            ASSIGN tt-lat-consolidada.cdcooper = par_cdcooper
                   tt-lat-consolidada.nrdconta = par_nrdconta
                   tt-lat-consolidada.nrdocmto = par_nrdocmto
                   tt-lat-consolidada.nrcnvcob = par_nrcnvcob
                   tt-lat-consolidada.dsincide = "RET"
                   tt-lat-consolidada.cdocorre = 27    /* 27 - Conf. Alt. Outros Dados  */
                   tt-lat-consolidada.cdmotivo = ""    /* Motivo */
                   tt-lat-consolidada.vllanmto = bcrapcob.vltitulo.
        END.

    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE inst-protestar-arq-rem-085:
    /* 09. Protestar */
    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_qtdiaprt AS INTE                           NO-UNDO.    
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lat-consolidada.

    /* Processo de Validacao Recusas Padrao */
    RUN efetua-validacao-recusa-padrao (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrcnvcob,
                                        INPUT par_nrdocmto,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                        INPUT "09", /* Protestar */
                                        INPUT par_nrremass,
                                        OUTPUT ret_dsinserr).

    IF RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    
    IF  bcrapcob.cdbandoc = 085  AND
        bcrapcob.flgregis = TRUE AND 
        bcrapcob.flgcbdda AND 
        bcrapcob.insitpro <= 2 THEN
        DO:
            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XA",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Titulo em processo de registro. Favor aguardar".
            RETURN "NOK".
        END.

    /***** VALIDACOES PARA RECUSAR ******/
    
    /** Titulo ainda nao venceu **/
     IF  bcrapcob.dtvencto >= TODAY THEN
         DO:

            RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "39",   /* "Pedido de Protesto Nao Permitido para o Titulo" */ 
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).

            ret_dsinserr = "Boleto a Vencer - Protesto nao efetuado!".
            RETURN "NOK".
         END.

    /** Titulo nao ultrapassou data Instrucao Automatica de Protesto **/
    IF  bcrapcob.flgdprot = TRUE AND
        ((bcrapcob.dtvencto + bcrapcob.qtdiaprt) > TODAY) THEN
        DO:

            RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "39",   /* "Pedido de Protesto Nao Permitido para o Titulo" */ 
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).

            ret_dsinserr = "Boleto nao ultrapassou data de Instr. Autom. de " +
                           "Protesto - Protesto nao efetuado!".
            RETURN "NOK".
        END.


    /* Titulos com Remessa a Cartorio ou Em Cartorio */
    CASE bcrapcob.insitcrt:
        WHEN 1 THEN DO:

            RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 26,     /* Instrucao Rejeitada */
                          INPUT "40",     /* Motivo */
                          INPUT 0,      /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto c/ instrucao de protesto - " +
                "Aguarde confirmacao do Banco do Brasil - " + 
                "Protesto nao efetuado!".
            RETURN "NOK".
        END.
        WHEN 2 THEN DO:

            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XJ",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto c/ instrucao de sustacao - " + 
                "Aguarde confirmacao do Banco do Brasil - " +
                "Protesto nao efetuado!".
            RETURN "NOK".
        END.
        WHEN 3 THEN DO: 

            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XF",     /* Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto Em Cartorio - Protesto nao efetuado!".
            RETURN "NOK".
        END.

    END CASE.

    FIND crapass WHERE crapass.cdcooper = bcrapcob.cdcooper AND
                       crapass.nrdconta = bcrapcob.nrdconta
                       NO-LOCK NO-ERROR.

     IF  NOT AVAILABLE crapass  THEN
         RETURN "NOK".

     /* Se pessoa for fisica, nao protestar */
     IF crapass.inpessoa = 1 THEN
         DO:

            RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "39",   /* "Pedido de Protesto Nao Permitido para o Titulo" */
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).

             ret_dsinserr = "Instrucao nao permitida para Pessoa Fisica".
             RETURN "NOK".
         END.

    /* Verifica se ja existe Instrucao de "Protestar" */
    FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper
                        AND crapcre.nrcnvcob = par_nrcnvcob
                        AND crapcre.dtmvtolt = par_dtmvtolt
                        AND crapcre.intipmvt = 1
                        NO-LOCK NO-ERROR.


    IF  AVAIL crapcre THEN
        DO:
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.cdocorre = 9
                                AND craprem.dtaltera = par_dtmvtolt
                                NO-LOCK NO-ERROR. 

            IF  AVAIL craprem THEN
                DO:
                    RUN prepara-retorno-cooperado
                    			 (INPUT ROWID(bcrapcob),
                    			  INPUT 26,     /* Instrucao Rejeitada */
                    			  INPUT "40",     /* Motivo */
                    			  INPUT 0,      /* Valor Tarifa */
                    			  INPUT crapcop.cdbcoctl,
                    			  INPUT crapcop.cdagectl,
                    			  INPUT par_dtmvtolt,
                    			  INPUT par_cdoperad,
                                  INPUT par_nrremass).
                           
                    ret_dsinserr = "Instrucao de Protesto ja efetuada - " +
                                   "Protesto nao efetuado!".
                    RETURN "NOK".
                END.
        END.

    /* Validar parametro de tela */
    IF  bcrapcob.cddespec <> 1 AND
        bcrapcob.cddespec <> 2 THEN
        DO:

             RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "39",   /* "Pedido de Protesto Nao Permitido para o Titulo" */
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).

            ret_dsinserr = "Especie Docto diferente de DM e DS - " +
                           "Protesto nao efetuado!".
            RETURN "NOK".
        END.

    /*** Validacao Praça não executante de protesto ****/
    FIND crapsab WHERE crapsab.cdcooper = bcrapcob.cdcooper AND
                       crapsab.nrdconta = bcrapcob.nrdconta AND
                       crapsab.nrinssac = bcrapcob.nrinssac NO-LOCK NO-ERROR.

    IF  NOT AVAILABLE crapsab  THEN DO:

        RUN prepara-retorno-cooperado
                     (INPUT ROWID(bcrapcob),
                      INPUT 26,     /* Instrucao Rejeitada */
                      INPUT "",     /* Motivo */
                      INPUT 0,      /* Valor Tarifa */
                      INPUT crapcop.cdbcoctl,
                      INPUT crapcop.cdagectl,
                      INPUT par_dtmvtolt,
                      INPUT par_cdoperad,
                      INPUT par_nrremass).

        RETURN "NOK".
    END.

    /*Rafael Ferreira (Mouts) - INC0022229
      Conforme informado por Deise Carina Tonn da area de Negócio, esta validaçao nao é mais necessária
      pois agora Todas as cidades podem ter protesto*/    
    /*FIND crappnp WHERE crappnp.nmextcid = crapsab.nmcidsac AND
                       crappnp.cduflogr = crapsab.cdufsaca NO-LOCK NO-ERROR.

    IF  AVAILABLE crappnp THEN
        DO:
            RUN prepara-retorno-cooperado
                             (INPUT ROWID(bcrapcob),
                              INPUT 26,     /* Instrucao Rejeitada */
                              INPUT "39",   /* "Pedido de Protesto Nao Permitido para o Titulo" */
                              INPUT 0,      /* Valor Tarifa */
                              INPUT crapcop.cdbcoctl,
                              INPUT crapcop.cdagectl,
                              INPUT par_dtmvtolt,
                              INPUT par_cdoperad,
                              INPUT par_nrremass).

            ret_dsinserr = "Praça não executante de protesto " + 
                           "– Instrução não efetuada".
            RETURN "NOK".
        END.*/

/***** FIM - VALIDACOES PARA RECUSAR ******/
    
        IF  bcrapcob.cdbandoc = 85 THEN
            DO:
                
                FIND CURRENT bcrapcob 
                     EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

                IF  AVAIL bcrapcob THEN
                    DO:
                        ASSIGN bcrapcob.flgdprot = TRUE
                               bcrapcob.qtdiaprt = par_qtdiaprt.
                    END.
                ELSE
                    DO:
                        RUN prepara-retorno-cooperado
                                 (INPUT ROWID(bcrapcob),
                                  INPUT 26,     /* Instrucao Rejeitada */
                                  INPUT "",     /* Motivo */       
                                  INPUT 0,      /* Valor Tarifa */
                                  INPUT crapcop.cdbcoctl,
                                  INPUT crapcop.cdagectl,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdoperad,
                                  INPUT par_nrremass).

                        RETURN "NOK".
                    END.
                
                
                RUN prepara-retorno-cooperado
                         (INPUT ROWID(bcrapcob),
                          INPUT 19,             /* 19 -  Confirmacao Recebimento Instrucao de Protesto */
                          INPUT "",             /* Motivo */
                          INPUT 0,              /* Valor Tarifa */
                          INPUT crapcop.cdbcoctl,
                          INPUT crapcop.cdagectl,
                          INPUT par_dtmvtolt,
                          INPUT par_cdoperad,
                          INPUT par_nrremass).
    
            END. /* FIM do IF cdbandoc = 85 */
    

        /* Gerar registro Tarifa */
        CREATE tt-lat-consolidada.
        ASSIGN tt-lat-consolidada.cdcooper = par_cdcooper
               tt-lat-consolidada.nrdconta = par_nrdconta
               tt-lat-consolidada.nrdocmto = par_nrdocmto
               tt-lat-consolidada.nrcnvcob = par_nrcnvcob
               tt-lat-consolidada.dsincide = "RET"
               tt-lat-consolidada.cdocorre = 19    /* 19 -  Confirmacao Recebimento Instrucao de Protesto  */
               tt-lat-consolidada.cdmotivo = ""    /* Motivo */
               tt-lat-consolidada.vllanmto = bcrapcob.vltitulo.

    RETURN "OK".

END PROCEDURE.

PROCEDURE inst-alt-tipo-emissao-cee:
    /* 90. Alterar tipo de emissao CEE */
    DEF  INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INT                            NO-UNDO.
    DEF  INPUT PARAM par_cdocorre AS DECI                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrremass AS INTE                           NO-UNDO.
    DEF OUTPUT PARAM ret_dsinserr AS CHAR                           NO-UNDO.

    DEF INPUT-OUTPUT PARAM TABLE FOR tt-lat-consolidada.

    DEF VAR old_inemiten AS INTE        NO-UNDO.

    /* Processo de Validacao Recusas Padrao */
    RUN efetua-validacao-recusa-padrao (INPUT par_cdcooper,
                                        INPUT par_nrdconta,
                                        INPUT par_nrcnvcob,
                                        INPUT par_nrdocmto,
                                        INPUT par_dtmvtolt,
                                        INPUT par_cdoperad,
                                        INPUT "90",         /* Alterar tipo de emissao CEE */
                                        INPUT par_nrremass,
                                        OUTPUT ret_dsinserr).

    IF RETURN-VALUE = "NOK" THEN
        RETURN "NOK".

    IF  bcrapcob.cdbandoc = 1 THEN DO:

        RUN prepara-retorno-cooperado
                 (INPUT ROWID(bcrapcob),
                  INPUT 26,     /* Instrucao Rejeitada */
                  INPUT "XT",     /* Sem Motivo */
                  INPUT 0,      /* Valor Tarifa */
                  INPUT crapcop.cdbcoctl,
                  INPUT crapcop.cdagectl,
                  INPUT par_dtmvtolt,
                  INPUT par_cdoperad,
                  INPUT par_nrremass).

        ret_dsinserr = "Nao permitido alterar tipo de emissao de boletos do Banco do Brasil. Instrucao nao realizada.".
        RETURN "NOK".
    END.


    /* Verificar se boleto já está na situação pretendida */
	IF bcrapcob.inemiten = 3 THEN 
    DO: 
          RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "A7",   /* Titulo ja se encontra na situacaoo Pretendida */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Boleto ja e Cooperativa Emite e Expede – Alteracao nao efetuada".
            RETURN "NOK".

    END.

    /* verificar se o cooperado possui modalidade Cooperativa/EE habilitada */
    FIND crapceb WHERE
         crapceb.cdcooper = par_cdcooper AND
         crapceb.nrdconta = par_nrdconta AND
         crapceb.nrconven = par_nrcnvcob
         NO-LOCK NO-ERROR.

    IF  AVAIL(crapceb) AND crapceb.flceeexp = FALSE THEN 
    DO:                
        RUN prepara-retorno-cooperado
                       (INPUT ROWID(bcrapcob),
                        INPUT 26,     /* Instrucao Rejeitada */
                        INPUT "XU",   /* Sem motivo */
                        INPUT 0,      /* Valor Tarifa */
                        INPUT crapcop.cdbcoctl,
                        INPUT crapcop.cdagectl,
                        INPUT par_dtmvtolt,
                        INPUT par_cdoperad,
                        INPUT par_nrremass).

          ret_dsinserr = "Cooperado nao possui modalidade de emissao Cooperativa/EE habilitada – Alteracao nao efetuada".
          RETURN "NOK".
    END.
    
    IF bcrapcob.cdbandoc = 085  AND
       bcrapcob.flgregis = TRUE AND 
       bcrapcob.flgcbdda AND 
       bcrapcob.insitpro <= 2 THEN
        DO:
            RUN prepara-retorno-cooperado
            			 (INPUT ROWID(bcrapcob),
            			  INPUT 26,     /* Instrucao Rejeitada */
            			  INPUT "XA",     /* Sem Motivo */
            			  INPUT 0,      /* Valor Tarifa */
            			  INPUT crapcop.cdbcoctl,
            			  INPUT crapcop.cdagectl,
            			  INPUT par_dtmvtolt,
            			  INPUT par_cdoperad,
                          INPUT par_nrremass).

            ret_dsinserr = "Titulo em processo de registro. Favor aguardar".
            RETURN "NOK".
        END.

    /***** VALIDACOES PARA RECUSAR ******/
    /* Verifica se ja existe alt de tipo de emissao */
    FIND LAST crapcre WHERE crapcre.cdcooper = par_cdcooper
                        AND crapcre.nrcnvcob = par_nrcnvcob
                        AND crapcre.dtmvtolt = par_dtmvtolt
                        AND crapcre.intipmvt = 1
                        NO-LOCK NO-ERROR.

    IF  AVAIL crapcre THEN
        DO:
            /* Verifica se ja existe Pedido de Baixa */
            FIND LAST craprem WHERE craprem.cdcooper = bcrapcob.cdcooper
                                AND craprem.nrcnvcob = bcrapcob.nrcnvcob
                                AND craprem.nrdconta = bcrapcob.nrdconta
                                AND craprem.nrdocmto = bcrapcob.nrdocmto
                                AND craprem.cdocorre = 90
                                AND craprem.dtaltera = par_dtmvtolt
                                NO-LOCK NO-ERROR.

            IF  AVAIL craprem THEN
                DO:
                    RUN prepara-retorno-cooperado
                    			 (INPUT ROWID(bcrapcob),
                    			  INPUT 26,     /* Instrucao Rejeitada */
                    			  INPUT "XR",     /* Motivo */
                    			  INPUT 0,      /* Valor Tarifa */
                    			  INPUT crapcop.cdbcoctl,
                    			  INPUT crapcop.cdagectl,
                    			  INPUT par_dtmvtolt,
                    			  INPUT par_cdoperad,
                                  INPUT par_nrremass).

                    ret_dsinserr = "Alteracao de tipo de emissao ja efetuado - Instrucao nao efetuada!".
                    RETURN "NOK".
                END.
        END.

    /***** FIM - VALIDACOES PARA RECUSAR ******/


    DO TRANSACTION:

        FIND CURRENT bcrapcob EXCLUSIVE-LOCK NO-ERROR NO-WAIT.

        IF  bcrapcob.cdbandoc = crapcop.cdbcoctl  THEN 
            DO:

              ASSIGN bcrapcob.inemiten = 3
                     bcrapcob.inemiexp = 1. /* Pendente de Envio */


                RUN prepara-retorno-cooperado
                                 (INPUT ROWID(bcrapcob),
                                  INPUT 90, /* Alteracao Emissao CCE */
                                  INPUT "", /* Motivo */
                                  INPUT 0,  /* Valor Tarifa */
                                  INPUT crapcop.cdbcoctl,
                                  INPUT crapcop.cdagectl,
                                  INPUT par_dtmvtolt,
                                  INPUT par_cdoperad,
                                  INPUT par_nrremass).

            END. /* FIM do IF cdbandoc = 85 */

        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT "Inst Alt de Emissao CEE").

        RUN cria-log-cobranca (INPUT ROWID(bcrapcob),
                       INPUT par_cdoperad,
                       INPUT par_dtmvtolt,
                       INPUT "Titulo a enviar a PG").

    
        IF bcrapcob.cdbandoc = 85 THEN DO:

            /* Gerar registro Tarifa */
            CREATE tt-lat-consolidada.
            ASSIGN tt-lat-consolidada.cdcooper = par_cdcooper
                   tt-lat-consolidada.nrdconta = par_nrdconta
                   tt-lat-consolidada.nrdocmto = par_nrdocmto
                   tt-lat-consolidada.nrcnvcob = par_nrcnvcob
                   tt-lat-consolidada.dsincide = "RET"
                   tt-lat-consolidada.cdocorre = 90  /* 90 - Inst Alt emissao CEE  */
                   tt-lat-consolidada.cdmotivo = ""  /* Motivo */
                   tt-lat-consolidada.vllanmto = bcrapcob.vltitulo.
        END.

    END. /* final da transacao */

    RETURN "OK".

END PROCEDURE.

PROCEDURE pc_negativa_serasa:

    /* 93 */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INT                            NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    
    
    RUN STORED-PROCEDURE pc_negativa_serasa
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,
                                 INPUT par_nrcnvcob,
                                 INPUT par_nrdconta,
                                 INPUT par_nrdocmto,
                                 INPUT 0,    /* par_nrremass */
                                 INPUT "",   /* par_cdoperad */
                                 OUTPUT 0,   /* pr_cdcritic */
                                 OUTPUT ""). /* pr_dscritic */
    
    CLOSE STORED-PROC pc_negativa_serasa
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN par_cdcritic = 0
           par_dscritic = ""
    
           par_cdcritic = pc_negativa_serasa.pr_cdcritic 
                              WHEN pc_negativa_serasa.pr_cdcritic <> ?
           par_dscritic = pc_negativa_serasa.pr_dscritic
                              WHEN pc_negativa_serasa.pr_dscritic <> ?. 

END PROCEDURE. 


PROCEDURE pc_cancelar_neg_serasa:
    /* 94 */
    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrcnvcob AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdocmto AS INTE                           NO-UNDO.

    DEF OUTPUT PARAM par_cdcritic AS INT                            NO-UNDO.
    DEF OUTPUT PARAM par_dscritic AS CHAR                           NO-UNDO.

    { includes/PLSQL_altera_session_antes.i &dboraayl={&scd_dboraayl} }    
    
    RUN STORED-PROCEDURE pc_cancelar_neg_serasa
        aux_handproc = PROC-HANDLE NO-ERROR
                                (INPUT par_cdcooper,
                                 INPUT par_nrcnvcob,
                                 INPUT par_nrdconta,
                                 INPUT par_nrdocmto,
                                 INPUT 0,    /* par_nrremass */
                                 INPUT "",   /* par_cdoperad */
                                 OUTPUT 0,   /* pr_cdcritic */
                                 OUTPUT ""). /* pr_dscritic */
    
    CLOSE STORED-PROC pc_cancelar_neg_serasa
          aux_statproc = PROC-STATUS WHERE PROC-HANDLE = aux_handproc.
    
    { includes/PLSQL_altera_session_depois.i &dboraayl={&scd_dboraayl} }
    
    ASSIGN par_cdcritic = 0
           par_dscritic = ""
    
           par_cdcritic = pc_cancelar_neg_serasa.pr_cdcritic 
                              WHEN pc_cancelar_neg_serasa.pr_cdcritic <> ?
           par_dscritic = pc_cancelar_neg_serasa.pr_dscritic
                              WHEN pc_cancelar_neg_serasa.pr_dscritic <> ?. 

END PROCEDURE. 


/*............................................................................*/







