/******************************************************************************
                 ATENCAO!    CONVERSAO PROGRESS - ORACLE
            ESTE FONTE ESTA ENVOLVIDO NA MIGRACAO PROGRESS->ORACLE!
  +---------------------------------+-----------------------------------+
  | Rotina Progress                 | Rotina Oracle PLSQL               |
  +---------------------------------+-----------------------------------+
  | includes/gerandb.i              | CONV0001.pc_gerandb               |
  +---------------------------------+-----------------------------------+
  
  TODA E QUALQUER ALTERACAO EFETUADA NESSE FONTE A PARTIR DE 20/NOV/2012 DEVERA
  SER REPASSADA PARA ESTA MESMA ROTINA NO ORACLE, CONFORME DADOS ACIMA.
  
  PARA DETALHES DE COMO PROCEDER, FAVOR ENTRAR EM CONTATO COM AS SEGUINTES
  PESSOAS:
   - GUILHERME STRUBE    (CECRED)
   - MARCOS MARTINI      (SUPERO)
   - GUILHERME BOETTCHER (SUPERO)

******************************************************************************/












/* ..........................................................................

   Programa: Includes/gerandb.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Odair
   Data    : Agosto/98.                        Ultima atualizacao: 16/05/2016

   Dados referentes ao programa:

   Objetivo  : Gerar crapndb para devolucao de debitos automaticos.
   
   ALTERACAO : 24/12/98 - TRATAR BTV. (Odair).
   
               22/03/99 - Tratar dtmvtolt atraves de inproces (Odair)

               25/10/99 - Tratar celular separado de fixo (Odair)

               01/11/2000 - Ajustar o programa para que trabalhem por
                            parametros para o historico 30 (Eduardo).

               24/01/2001 - Tratar hist.371 GLOBAL TELECOM (Margarete/Planner).

               05/04/2001 - Padronizar os procedimentos para qualquer
                            cooperativa. (Ze Eduardo).

               02/01/2003 - Ajustes para a Brasil Telecom (Deborah).

               09/06/2004 - Acessar tabela de convenio generica(Mirtes)

               06/07/2005 - Alimentado campo cdcooper da tabela crapndb (Diego)

               29/08/2006 - Melhorias no codigo fonte para nao precisar
                            mais tratar cada convenmio novo que entrar (Julio).
                            
               04/06/2012 - Tratamento para critica de cancelamento de debito
                            automatico (Elton).
                            
               10/12/2013 - Alteracao referente a integracao Progress X 
                            Dataserver Oracle 
                            Inclusao do VALIDATE ( André Euzébio / SUPERO)  
                            
               23/01/2014 - Ajustes para crapndb gerar registro "F" de 
                            consorcios (Lucas R.)
                            
               18/06/2014 - Incluir ajustes referentes ao debito automatico,
                            alterado fill(" ",76) por craplau.cdseqtel 
                            (Elton/Lucas R.)
                            
               13/08/2014 - Tratamento para SULAMERICA (cdhistor = 1517) para,
                            no retorno da critica, enviarmos o campo de 
                            contrato com 22 posicoes preenchidas, seguido de
                            tres espacos em branco. (Chamado 182918 - Fabricio)
                            
               25/09/2014 - Tratamento para PREVISUL (cdhistor = 1723) para,
                            no retorno da critica, enviarmos o campo de 
                            contrato com 20 posicoes preenchidas, seguido de
                            cinco espacos em branco. 
                            (Chamado 101648 - Fabricio)
                            
               13/11/2014 - Incluir procedure retorna_valor_formatado que
                            ajusta corretamente o formato do registro que
                            deseja. (Lucas R./Elton - Projeto Debito Atutomatico Siscredi)
                            
               14/01/2015 - Correção no preenchimento do nr. do documento na 
					        criação da crapndb (Lunelli)
                            
               10/02/2015 - Criação de crítica '05' quando crítica de limite excedido (967)
                            for recebida (Lunelli - SD. 229251)
               
               24/03/2015 - Criada a function verificaUltDia e chamada sempre
                            que for criado um registro na crapndb ou craplau
                            (SD245218 - Tiago)
                            
               20/07/2015 - Adicionado historicos 834,901,993,1061 TIM Celular,HDI,LIBERTY SEGUROS,
                            PORTO SEGURO, que ja existia  para PREVISUL, no retorno da critica,
                            enviarmos o campo de contrato com 20 posicoes preenchidas, seguido de
                            cinco espacos em branco (Lucas Ranghetti #304790)
                            
               13/08/2015 - Adicioanar tratamento para o convenio MAPFRE VERA CRUZ SEG, referencia 
                            e conta (Lucas Ranghetti #292988 )
                            
               16/05/2016 - Adicionado tratamento para a vivo, historico 453, gravar
                            na crapndb com 11 posicoes (Lucas Ranghetti #448599)
............................................................................ */

FUNCTION verificaUltDia RETURNS DATE
    ( INPUT par_cdcooper AS INTEGER, INPUT par_dtrefere AS   DATE) :

    DEF VAR vr_dtultdia             AS      DATE                NO-UNDO.

    FIND crapdat WHERE crapdat.cdcooper = par_cdcooper NO-LOCK NO-ERROR.

    IF  NOT AVAIL(crapdat) THEN
        DO:
            RETURN par_dtrefere.
        END.

    ASSIGN vr_dtultdia = DATE('31/12/' + STRING(YEAR(crapdat.dtmvtolt),'9999')).

    IF  par_dtrefere = vr_dtultdia THEN
        DO:
            ASSIGN par_dtrefere = par_dtrefere + 1.

            DO WHILE TRUE:
            
                FIND crapfer WHERE crapfer.dtferiad = par_dtrefere 
                               AND crapfer.cdcooper = par_cdcooper
                                   NO-LOCK NO-ERROR.
    
                IF  NOT AVAIL(crapfer)          AND
                   (WEEKDAY(par_dtrefere) <> 1  AND
                    WEEKDAY(par_dtrefere) <> 7) THEN
                    DO:
                       LEAVE.
                    END.
                
                ASSIGN par_dtrefere = par_dtrefere + 1.

            END.
        END.

    RETURN par_dtrefere.
END FUNCTION.


DEF  VAR  aux_cdcritic          AS  CHAR                               NO-UNDO.
DEF  VAR  aux_flgsicre          AS  LOGI INIT FALSE                    NO-UNDO.
DEF  VAR  aux_cdrefere          AS  CHAR                               NO-UNDO.
DEF  VAR  aux_cdempscn          AS  CHAR                               NO-UNDO.

DO:
   IF  (craplau.cdhistor = 1230 OR
        craplau.cdhistor = 1231 OR
        craplau.cdhistor = 1232 OR
        craplau.cdhistor = 1233 OR
        craplau.cdhistor = 1234 OR
        craplau.cdhistor = 1019) THEN
        ASSIGN aux_flgsicre = TRUE. /* historicos do consorcio/debito automatico sicredi */
   
   IF  f_conectagener() THEN 
       DO: 
          ASSIGN aux_cdhistorc = craplau.cdhistor.
          RUN fontes/lotee_1a.p (INPUT  aux_cdhistorc,
                                 OUTPUT aux_cdagencic,
                                 OUTPUT aux_cdcooperativa). 
       END.
   
   IF  aux_cdcooperativa = "8888"   AND
       aux_flgsicre = FALSE         THEN 
       DO:
          ASSIGN glb_cdcritic = 472.
       END.
   ELSE
       DO:      
          IF  craplau.cdhistor = 48 THEN
              ASSIGN aux_cdagencic = "1294".
                   
          IF  aux_cdcooperativa = " " THEN 
              DO:
                  IF  craplau.cdhistor = 1994  OR   /* MAPFRE VERA CRUZ SEG */
                      craplau.cdhistor = 1992  THEN /* MAPFRE VERA CRUZ SEG */
                      ASSIGN aux_nrdcontac = STRING(craplau.nrdconta,
                                                    "99999999999999").
                  ELSE
                      ASSIGN aux_nrdcontac =
                             STRING(craplau.nrdconta,"99999999") +
                                      "    ".
              END.
          ELSE
              ASSIGN aux_nrdcontac =
                     STRING(aux_cdcooperativa,"9999")  +
                     STRING(craplau.nrdconta,"99999999").
          
          CREATE crapndb.
          ASSIGN crapndb.dtmvtolt = IF  glb_inproces = 1 THEN 
                                        verificaUltDia(glb_cdcooper, glb_dtmvtolt)
                                    ELSE
                                        verificaUltDia(glb_cdcooper, glb_dtmvtopr)
                  crapndb.nrdconta = craplau.nrdconta
                  crapndb.cdhistor = craplau.cdhistor
                  crapndb.flgproce = FALSE
                  crapndb.cdcooper = glb_cdcooper
                  crapndb.dstexarq = "F".
          
          IF  craplau.cdhistor = 31   THEN
              ASSIGN crapndb.dstexarq = crapndb.dstexarq + 
                                 STRING(crapatr.cdrefere,"9999999999") + 
                                 "               ".
          ELSE
          IF  craplau.cdhistor = 48   THEN
              ASSIGN crapndb.dstexarq = crapndb.dstexarq +
                                        STRING(crapatr.cdrefere,"99999999") + 
                                        "                 ".
          ELSE
          IF craplau.cdhistor = 1517 THEN /* SULAMERICA */
              ASSIGN crapndb.dstexarq = crapndb.dstexarq +
                          STRING(crapatr.cdrefere,"9999999999999999999999") +
                          "   ".
          ELSE                     
          IF  craplau.cdhistor = 834 OR /* TIM Celular */
              craplau.cdhistor = 901 OR /* HDI */
              craplau.cdhistor = 993 OR /* LIBERTY SEGUROS */
              craplau.cdhistor = 1061 OR /* PORTO SEGURO */
              craplau.cdhistor = 1723 THEN /* PREVISUL */
              ASSIGN crapndb.dstexarq = crapndb.dstexarq +
                          STRING(crapatr.cdrefere,"99999999999999999999") +
                          "     ".
          ELSE
          IF  craplau.cdhistor = 1994  OR   /* MAPFRE VERA CRUZ SEG */
              craplau.cdhistor = 1992  THEN /* MAPFRE VERA CRUZ SEG */
              ASSIGN crapndb.dstexarq = crapndb.dstexarq +
                                        STRING(crapatr.cdrefere)
                                       + FILL(" ",25 - LENGTH(STRING(crapatr.cdrefere))).
          ELSE
          IF  craplau.cdhistor = 453 THEN /* VIVO/TELEFONICA */              
              ASSIGN crapndb.dstexarq = crapndb.dstexarq + 
                           STRING(crapatr.cdrefere,"99999999999") + FILL(" ",14).
          ELSE
              IF  NOT aux_flgsicre THEN 
                  ASSIGN crapndb.dstexarq = crapndb.dstexarq +
                         STRING(crapatr.cdrefere) + 
                         FILL(" ", 25 - LENGTH(STRING(crapatr.cdrefere))).

          IF  glb_cdcritic = 447  THEN
              ASSIGN  aux_cdcritic = "30". /** Sem contrato de débito **/
          ELSE
          IF  glb_cdcritic = 967 THEN /* VALOR LIMITE ULTRAPASSADO */
              ASSIGN aux_cdcritic = "05".
          ELSE
              ASSIGN  aux_cdcritic = "01". /** Insuficiencias de fundos **/
                               
          IF  aux_flgsicre THEN /* consorcio sicredi */
              DO:  
                 IF  craplau.cdhistor = 1019 THEN
                     DO:
                        FIND FIRST crapscn WHERE crapscn.cdempres = craplau.cdempres
                                                 NO-LOCK NO-ERROR.

                        IF  NOT AVAIL crapscn THEN
                            ASSIGN glb_cdcritic = 563.
                        
                        /* Formatar o documento de acordo com informacao da crapscn */
                        RUN retorna_valor_formatado (INPUT crapscn.qtdigito,
                                                     INPUT 25,
                                                     INPUT crapscn.tppreenc,
                                                     INPUT craplau.nrdocmto,
                                                    OUTPUT aux_cdrefere).
                     END.
                 ELSE 
                     ASSIGN aux_cdrefere = STRING(craplau.nrdocmto,"9999999999999999999999") 
                                           + FILL(" ",3).
                 
                 /* formatar codigo da empresa */
                RUN retorna_valor_formatado (INPUT 10, /* max. de digitos na variavel */                                 
                                             INPUT 10, /* quantidade max characteres a completar */ 
                                             INPUT 0,                        
                                             INPUT craplau.cdempres,         
                                            OUTPUT aux_cdempscn).            
                 
                 ASSIGN aux_cdagenci = INTE(SUBSTR(STRING(crapass.cdagenci,
                                                          "999"),2,2)).
                                              
                 ASSIGN crapndb.dstexarq = "F"                            +
                        SUBSTRING(aux_cdrefere,1,25)                      +
                        STRING(crapcop.cdagesic,"9999")                   + 
                        STRING(crapass.nrctacns,"999999")                 +
                        FILL(" ",8)                                       +
                        STRING(YEAR(glb_dtmvtolt),"9999")                 +
                        STRING(MONTH(glb_dtmvtolt),"99")                  +
                        STRING(DAY(glb_dtmvtolt),"99")                    +
                        STRING(craplau.vllanaut * 100,"999999999999999")  +
                        aux_cdcritic + STRING(craplau.cdseqtel,"x(60)")   +
                        FILL(" ",16)                                      +
                        STRING(aux_cdagenci,"99")                         +
                        aux_cdempscn + 
                        "0".       
              END.
          ELSE
              ASSIGN crapndb.dstexarq = crapndb.dstexarq                  +
                                        STRING(aux_cdagencic,"9999")      +
                                        STRING(aux_nrdcontac,"x(14)")     +
                                        STRING(YEAR(glb_dtmvtolt),"9999") +
                                        STRING(MONTH(glb_dtmvtolt),"99")  +
                                        STRING(DAY(glb_dtmvtolt),"99")    +
                                        STRING(craplau.vllanaut * 100,
                                               "999999999999999")         +
                                        aux_cdcritic                      +
                                        STRING(craplau.cdseqtel,"x(80)")  +
                                        "0".
       END.
               
   VALIDATE crapndb. 
       
END.

PROCEDURE retorna_valor_formatado:

    DEF INPUT PARAM par_qtdigito   AS INTE NO-UNDO. /* max. de digitos na variavel */
    DEF INPUT PARAM par_qtdcchar   AS INTE NO-UNDO. /* quantidade de characteres a completar */
    DEF INPUT PARAM par_indposic   AS INTE NO-UNDO. /* 0-esquerda/direita/espacos*/
    DEF INPUT PARAM par_valor      AS CHAR NO-UNDO. /* valor a ser retornado */
    DEF OUTPUT PARAM par_resultado AS CHAR NO-UNDO. /* resultado */
    
    DEF VAR aux_length AS INTE NO-UNDO.
    DEF VAR aux_soma   AS INTE NO-UNDO.
    DEF VAR aux_tpfill AS CHAR NO-UNDO.

    IF  par_indposic = 1 OR par_indposic = 2 THEN
        ASSIGN aux_tpfill = "0".
    ELSE
        ASSIGN aux_tpfill = " ".

    ASSIGN aux_length = LENGTH(TRIM(par_valor))
           aux_soma = par_qtdigito - aux_length.

    CASE par_indposic:
         WHEN 2 THEN
             par_resultado = par_valor + FILL(aux_tpfill,aux_soma).
         WHEN 1 THEN
              par_resultado = FILL(aux_tpfill,aux_soma) + par_valor.
         OTHERWISE
               par_resultado = par_valor + FILL(aux_tpfill,aux_soma).
    END CASE.    

    /* completar com espacos */
    ASSIGN aux_soma = par_qtdcchar - par_qtdigito
           par_resultado = par_resultado + FILL(" ",aux_soma).

END. 
/* ......................................................................... */


