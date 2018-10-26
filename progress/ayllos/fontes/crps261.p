/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | fontes/crps261.p                | pc_crps261                        |
  +---------------------------------+-----------------------------------+
  
   TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 04/MAR/2015 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.

  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - IRLAN CHEQUER MAIA  (CECRED)
   - MARCOS MARTINI      (SUPERO)

******************************************************************************/

/* ............................................................................

   Programa: Fontes/crps261.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah                 
   Data    : Maio/99                           Ultima atualizacao: 06/08/2018
   

   Dados referentes ao programa:

   Frequencia: Diario (Batch).
   Objetivo  : Atende a solicitacao 040.
               Emitir relatorio dos debitos em conta por banco (211).

   Alteracoes: 19/07/99 - Alterado para chamar a rotina de impressao (Edson).
   
               26/07/99 - Dividir em varios arquivos por pac para ser impresso
                          nas filiais (Odair)

               07/02/2000 - Gerar pedido de impressao (Deborah).

               25/02/2000 - Nao gerar pedido de impressao para o PAC 2 (Edson).
               
               24/05/2000 - Nao gerar pedido de impressao para os PACs 
                            3, 5, 8 e 9 (Deborah).

               03/11/2000 - Alterar nrdolote p/6 posicoes (Margarete/Planner).
               
               29/03/2001 - Alterado para mostrar o numero lote no qual o 
                            lancamento foi criado no craplcm (Edson).
               
               05/04/2001 - Alterado para quebrar o relatorio por historico
                            (Edson).
                            
               29/08/2001 - Incluir o PAC no relatorio (Junior).

               10/09/2001 - Tratar o campo nrdocmto referente ao histor. 040
                            (Ze Eduardo).
                            
               01/04/2002 - Retirar total por historico do relatorio (Junior).
               
               05/04/2002 - Alterado para imprimir somente o relatorio da
                            agencia 1 (Junior).

               05/09/2002 - Quebrar pagina a cada novo lote (Margarete).

               27/10/2003 - Nao listar os cheques do banco/caixa 700 (Desconto
                            de cheques)  (Edson).

               26/02/2006 - Unificacao dos Bancos - SQLWorks - Fernando. 

               08/05/2008 - Ajuste comando FIND(craphis) utilizava FOR p/ acesso
                            (Sidnei - Precise)

               04/06/2008 - Campo dsorigem nas leituras da craplau (David)

               14/07/2009 - incluido no for each a condição - 
                            craplau.dsorigem <> "PG555" - Precise - paulo
                            
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               25/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 
                            
               02/06/2011 - incluido no for each a condição - 
                            craplau.dsorigem <> "TAA" (Evandro).
                            
               03/10/2011 - Ignorado dsorigem = "CARTAOBB" na leitura da
                            craplau. (Fabricio)
                            
               03/06/2013 - Incluido no FOR EACH craplau a condicao -
                            craplau.dsorigem <> "BLOQJUD" (Andre Santos - SUPERO) 
               
               06/11/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (Guilherme Gielow)                         
               06/11/2013 - Alterado totalizador de PAs de 99 para 999. 
                           (Guilherme Gielow)             
                            
               31/03/2014 - incluido nas consultas da craplau
                            craplau.dsorigem <> "DAUT BANCOOB" (Lucas).
                            
               24/03/2015 - Conversão Progress >> Oracle (Jean Michel).

               31/03/2015 - testando. Softdesk #265387 (Carlos)

               28/09/2015 - Incluido nas consultas da craplau
                            craplau.dsorigem <> "CAIXA" (Lombardi).

               20/05/2016 - Incluido nas consultas da craplau
                            craplau.dsorigem <> "TRMULTAJUROS". (Jaison/James)

               02/03/2017 - Incluido nas consultas da craplau 
                            craplau.dsorigem <> "ADIOFJUROS" (Lucas Ranghetti M338.1)

              06/08/2018 - PJ450 - TRatamento do nao pode debitar, crítica de negócio, 
                           após chamada da rotina de geraçao de lançamento em CONTA CORRENTE.
                           Alteração específica neste programa acrescentando o tratamento para a origem
                           BLQPREJU
                           (Renato Cordeiro - AMcom)

********* ATENÇÃO: 28/09/2015 - Esse fonte já teve sua conversão para Oracle iniciada.
                                A conversão seja revista quando retomada.
............................................................................ */

DEF STREAM str_1.   /*  Para relatorio de criticas  */

{ includes/var_batch.i {1} } 

DEF        VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                NO-UNDO.
DEF        VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5       NO-UNDO.

DEF        VAR rel_nrmodulo AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                               INIT ["DEP. A VISTA   ","CAPITAL        ",
                                     "EMPRESTIMOS    ","DIGITACAO      ",
                                     "GENERICO       "]              NO-UNDO.

DEF        VAR rel_dsbccxpg AS CHAR                                  NO-UNDO.
DEF        VAR rel_dshistor AS CHAR                                  NO-UNDO.
DEF        VAR rel_dsobserv AS CHAR                                  NO-UNDO.
DEF        VAR rel_dsdtotal AS CHAR                                  NO-UNDO.
DEF        VAR rel_dsagenci AS CHAR                                  NO-UNDO.
DEF        VAR rel_qtdebito AS INT                                   NO-UNDO.
DEF        VAR rel_vldebito AS DECIMAL                               NO-UNDO.
DEF        VAR rel_dtmvtopg AS DATE                                  NO-UNDO.
DEF        VAR rel_dtdebito AS DATE                                  NO-UNDO.
DEF        VAR rel_ddvencim AS INT                                   NO-UNDO.
DEF        VAR rel_cdagenci AS INT                                   NO-UNDO.
DEF        VAR rel_nrdolote AS INT                                   NO-UNDO.
DEF        VAR rel_qtdeblot AS INT                                   NO-UNDO.
DEF        VAR rel_vldeblot AS DECIMAL                               NO-UNDO.

DEF        VAR bcx_qtdebito AS INT                                   NO-UNDO.
DEF        VAR bcx_vldebito AS DECIMAL                               NO-UNDO.

DEF        VAR age_qtdebito AS INT                                   NO-UNDO.
DEF        VAR age_vldebito AS DECIMAL                               NO-UNDO.

DEF        VAR hst_qtdebito AS INT                                   NO-UNDO.
DEF        VAR hst_vldebito AS DECIMAL                               NO-UNDO.

DEF        VAR aux_flgbanco AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flghisto AS LOGICAL                               NO-UNDO.
DEF        VAR aux_flgagenc AS LOGICAL                               NO-UNDO.
DEF        VAR aux_nrdocmto AS CHAR                                  NO-UNDO.

DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR aux_flgplpag AS LOGICAL                               NO-UNDO.


FORM rel_dsagenci AT 01 LABEL "PA"            FORMAT "x(020)"            
     rel_dtdebito AT 55 LABEL "DATA DO DEBITO" FORMAT "99/99/9999"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS NO-LABELS WIDTH 80 FRAME f_data.

FORM rel_dsbccxpg AT 01 FORMAT "x(15)"      LABEL "BANCO"
     SKIP(1)
     WITH NO-BOX SIDE-LABELS WIDTH 80 FRAME f_banco.

FORM craplau.nrdconta FORMAT "zzzz,zzz,9"       LABEL "CONTA/DV"
     rel_cdagenci     FORMAT "zz9"              LABEL "PA"
     rel_dshistor     FORMAT "x(017)"           LABEL "HISTORICO"
     aux_nrdocmto     FORMAT "x(09)"            LABEL "DOC/FATURA" 
     craplau.nrcrcard FORMAT "zzz,zz9"          LABEL "LOTE"
     craplau.nrseqlan FORMAT "zzzzz9"           LABEL "SEQ."
     craplau.vllanaut FORMAT "zzzz,zzz.99"      LABEL "VALOR "
     rel_ddvencim     FORMAT "z9"               LABEL "DIA"
     rel_dsobserv     FORMAT "x(04)"            LABEL "OBS."
     WITH NO-BOX DOWN NO-LABELS WIDTH 80 FRAME f_debitos.

FORM SKIP(1)
     "TOTAL"      AT 01
     rel_dsdtotal AT 07 FORMAT "x(13)"
     "===>"       AT 28
     rel_qtdebito AT 33 FORMAT "zzz,zz9"
     rel_vldebito AT 53 FORMAT "zzz,zzz,zzz,zz9.99"
     WITH NO-BOX NO-LABELS DOWN WIDTH 80 FRAME f_totais.

FORM SKIP(1)
     "TOTAL DO LOTE NRO."   AT 01
     rel_nrdolote  FORMAT "zzz,zz9"
     "===>"       
     rel_qtdeblot       FORMAT "zzz,zz9"
     rel_vldeblot AT 53 FORMAT "zzz,zzz,zzz,zz9.99"
     WITH NO-BOX NO-LABELS DOWN WIDTH 80 FRAME f_totais_lote.

ASSIGN glb_cdprogra = "crps261".

RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     RETURN.

/*  Verifica se deve rodar ou nao  */
IF   NOT CAN-DO(glb_dsparame,glb_cdprogra)   THEN
     DO:
         glb_infimsol = TRUE.
         RUN fontes/fimprg.p.
         RETURN.
     END.

{ includes/cabrel080_1.i }

rel_dtdebito = glb_dtmvtopr.

FOR EACH craplau WHERE craplau.cdcooper  = glb_cdcooper   AND
                       craplau.dtdebito  = rel_dtdebito   AND
                       craplau.cdbccxlt <> 700            AND
                       craplau.insitlau  = 2              AND
                       craplau.cdhistor <> 21             AND /* CHEQUE PAGO EM CAIXA */
                       craplau.cdhistor <> 26             AND /* CHEQUE SALARIO PAGO EM CAIXA */
                      (craplau.cdagenci <> 1              OR
                      (craplau.cdagenci  = 1              AND 
                       craplau.cdbccxpg <> 11))           AND
                       craplau.dsorigem <> "CAIXA"        AND
                       craplau.dsorigem <> "INTERNET"     AND
                       craplau.dsorigem <> "TAA"          AND
                       craplau.dsorigem <> "PG555"        AND
                       craplau.dsorigem <> "CARTAOBB"     AND
                       craplau.dsorigem <> "BLOQJUD"      AND
                       craplau.dsorigem <> "DAUT BANCOOB" AND
                       craplau.dsorigem <> "TRMULTAJUROS" AND
                       craplau.dsorigem <> "BLQPREJU"     AND
                       craplau.dsorigem <> "ADIOFJUROS",
         crapass WHERE crapass.cdcooper  = glb_cdcooper   AND
                       crapass.nrdconta  = craplau.nrdconta
                       NO-LOCK BREAK BY craplau.cdagenci
                                        BY craplau.cdbccxpg
                                           BY craplau.cdhistor
                                              BY craplau.nrcrcard
                                                 BY crapass.cdagenci
                                                    BY craplau.nrdconta
                                                       BY craplau.nrdocmto:

    ASSIGN aux_flgbanco = FALSE
           aux_flghisto = FALSE
           aux_flgagenc = FALSE.

    IF FIRST-OF(craplau.cdagenci)   THEN
         DO:
             ASSIGN aux_flgbanco = TRUE
                    aux_flgagenc = TRUE
                    aux_nmarqimp = "rl/crrl211_" + 
                                   STRING(craplau.cdagenci,"999") + ".lst".
             
             OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.

             VIEW STREAM str_1 FRAME f_cabrel080_1.
        END.
                
    IF   FIRST-OF(craplau.cdbccxpg)   THEN
         aux_flgbanco = TRUE.

    IF   FIRST-OF(craplau.cdhistor)   THEN
         aux_flghisto = TRUE.
    
    IF   FIRST-OF(craplau.nrcrcard)   THEN
         ASSIGN rel_nrdolote = craplau.nrcrcard
                rel_qtdeblot = 0
                rel_vldeblot = 0.
                
    IF   aux_flgagenc   THEN
         DO:
             FIND crapage WHERE crapage.cdcooper =  glb_cdcooper      AND
                                crapage.cdagenci =  craplau.cdagenci
                                NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE crapage   THEN
                  rel_dsagenci = STRING(craplau.cdagenci,"999") + "-NAO CAD.".
             ELSE
                  rel_dsagenci = crapage.nmresage.
         END.
    
    IF   aux_flgbanco   THEN
         DO:
             ASSIGN aux_flgplpag = NO.
             
             PAGE STREAM str_1.

             FIND crapbcl WHERE crapbcl.cdbccxlt =  craplau.cdbccxpg
                                NO-LOCK NO-ERROR.

             IF   NOT AVAILABLE crapbcl   THEN
                  rel_dsbccxpg = STRING(craplau.cdbccxpg,"999") + "-NAO CAD.".
             ELSE
                  rel_dsbccxpg = crapbcl.nmresbcc.
         END.


    IF   aux_flghisto   THEN
         DO:
             FIND craphis NO-LOCK WHERE
                                   craphis.cdcooper = craplau.cdcooper AND 
                                   craphis.cdhistor = craplau.cdhistor NO-ERROR.
             IF   NOT AVAILABLE craphis   THEN
                  rel_dshistor = STRING(craplau.cdhistor,"9999") + 
                                 "-NAO CADASTRADO".
             ELSE
                  rel_dshistor = STRING(craphis.cdhistor,"9999") + "-" +
                                        craphis.dshistor.
         END.
         
    IF   aux_flgplpag   OR 
         aux_flgbanco   OR
         aux_flgagenc   THEN
         DO:
             IF   aux_flgplpag   THEN
                  PAGE STREAM str_1.
                  
             DISPLAY STREAM str_1 rel_dsagenci rel_dtdebito WITH FRAME f_data.
             DISPLAY STREAM str_1 rel_dsbccxpg WITH FRAME f_banco.
         
             ASSIGN aux_flgplpag = NO.
         END.

    IF   craplau.cdcritic > 0   THEN
         DO:
             glb_cdcritic = craplau.cdcritic.
             RUN fontes/critic.p.
             ASSIGN rel_dsobserv = glb_dscritic
                    glb_cdcritic = 0.
         END.
    ELSE
         rel_dsobserv = "".

    ASSIGN rel_ddvencim = DAY(craplau.dtmvtopg)
           rel_cdagenci = crapass.cdagenci.
    
    IF   LENGTH(STRING(craplau.nrdocmto)) < 10 THEN
         aux_nrdocmto = STRING(craplau.nrdocmto,"zzzzzzzz9").
    ELSE
         aux_nrdocmto = SUBSTR(STRING(craplau.nrdocmto,"99999999999999"),6,9).
    
    DISPLAY STREAM str_1
            craplau.nrdconta rel_cdagenci     aux_nrdocmto     
            craplau.nrseqlan craplau.nrcrcard craplau.vllanaut 
            rel_dshistor     rel_dsobserv     rel_ddvencim
            WITH FRAME f_debitos.

    DOWN STREAM str_1 WITH FRAME f_debitos.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)   THEN
         DO:
             PAGE STREAM str_1.
             DISPLAY STREAM str_1 rel_dsagenci rel_dtdebito WITH FRAME f_data.
             DISPLAY STREAM str_1 rel_dsbccxpg WITH FRAME f_banco.
         END.

    ASSIGN rel_qtdeblot = rel_qtdeblot + 1
           rel_vldeblot = rel_vldeblot + craplau.vllanaut
           
           bcx_qtdebito = bcx_qtdebito + 1
           bcx_vldebito = bcx_vldebito + craplau.vllanaut

           age_qtdebito = age_qtdebito + 1
           age_vldebito = age_vldebito + craplau.vllanaut

           hst_qtdebito = hst_qtdebito + 1
           hst_vldebito = hst_vldebito + craplau.vllanaut

           aux_flgbanco = FALSE
           aux_flgagenc = FALSE
           aux_flghisto = FALSE.

    IF   LAST-OF(craplau.cdhistor)   THEN
         aux_flghisto = TRUE.
    
    IF   LAST-OF(craplau.nrcrcard)   THEN
         DO:
             IF   LINE-COUNTER(str_1) > 83   THEN
                  DO:
                      PAGE STREAM str_1.
                      DISPLAY STREAM str_1 rel_dsagenci
                                           rel_dtdebito WITH FRAME f_data.
                      DISPLAY STREAM str_1
                              rel_dsbccxpg WITH FRAME f_banco.
                  END.

             DISPLAY STREAM str_1
                     rel_nrdolote rel_qtdeblot rel_vldeblot
                     WITH FRAME f_totais_lote.

             DOWN STREAM str_1 WITH FRAME f_totais_lote.

             ASSIGN aux_flgplpag = YES.
         END.
    
    IF   LAST-OF(craplau.cdbccxpg)   THEN
         ASSIGN aux_flgbanco = TRUE
                aux_flghisto = TRUE.

    IF   LAST-OF(craplau.cdagenci)   THEN
         ASSIGN aux_flgbanco = TRUE
                aux_flgagenc = TRUE
                aux_flghisto = TRUE.

    IF   aux_flgbanco   THEN
         DO:
             ASSIGN rel_dsdtotal = rel_dsbccxpg
                    rel_qtdebito = bcx_qtdebito
                    rel_vldebito = bcx_vldebito

                    bcx_qtdebito = 0
                    bcx_vldebito = 0.

             IF   LINE-COUNTER(str_1) > 83   THEN
                  DO:
                      PAGE STREAM str_1.
                      DISPLAY STREAM str_1 rel_dsagenci
                                           rel_dtdebito WITH FRAME f_data.
                      DISPLAY STREAM str_1
                              rel_dsbccxpg WITH FRAME f_banco.
                  END.

             DISPLAY STREAM str_1
                     rel_dsdtotal rel_qtdebito rel_vldebito WITH FRAME f_totais.

             DOWN STREAM str_1 WITH FRAME f_totais.
         END.

    IF   aux_flgagenc   THEN
         DO:
             ASSIGN rel_dsdtotal = rel_dsagenci
                    rel_qtdebito = age_qtdebito
                    rel_vldebito = age_vldebito

                    age_qtdebito = 0
                    age_vldebito = 0.

             IF   LINE-COUNTER(str_1) > 83   THEN
                  DO:
                      PAGE STREAM str_1.
                      DISPLAY STREAM str_1 rel_dsagenci 
                                           rel_dtdebito WITH FRAME f_data.
                      DISPLAY STREAM str_1
                              rel_dsbccxpg WITH FRAME f_banco.
                  END.

             DISPLAY STREAM str_1
                     rel_dsdtotal rel_qtdebito rel_vldebito WITH FRAME f_totais.

             DOWN STREAM str_1 WITH FRAME f_totais.
         
             OUTPUT STREAM str_1 CLOSE.

             ASSIGN glb_nrcopias = 1
                    glb_nmformul = "80col"
                    glb_nmarqimp = aux_nmarqimp.

             IF   craplau.cdagenci = 1   THEN
                  RUN fontes/imprim.p.  
             

                 
         END.

END.  /*  Fim do FOR EACH  --  Leitura dos lancamentos automaticos  */

glb_infimsol = TRUE.

RUN fontes/fimprg.p. 

/* .......................................................................... */

