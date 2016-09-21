/* .............................................................................

   Programa: Fontes/crps489.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Novembro/2007                     Ultima atualizacao: 09/09/2013

   Dados referentes ao programa:

   Frequencia: Diario (Solicitacao 86).
   Objetivo  : Listar os valores devidos pelo INSS as cooperativas, referente
               ao pagamento de beneficios diariamente e acumulado mensal.
               Emite relatorio 471.

   Alteracoes: 02/09/2008 - Colocado FIND LAST na busca do pagamento devido a
                            um erro exporadico que aconteceu em 1 PAC, 1 vez e
                            nao foi descoberto (Evandro).
                            
               04/10/2008 - Alteracao do FORMAT dos campos de totais (Henrique).

               09/09/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
............................................................................. */

DEF STREAM str_1.   /*  Para o relatorio  */

{ includes/var_batch.i "NEW" }

/* variaveis para includes/cabrel132_1.i */
DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                       NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5              NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                           NO-UNDO.
DEF VAR rel_nmempres AS CHAR    FORMAT "x(15)"                       NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                                       INIT ["","","","",""]         NO-UNDO.


DEF        VAR rel_dtiniper AS DATE                                  NO-UNDO.
DEF        VAR rel_dtfimper AS DATE                                  NO-UNDO.
DEF        VAR rel_dsmepgto AS CHAR                                  NO-UNDO.
DEF        VAR rel_qtdpagto AS INT              EXTENT 4             NO-UNDO.
DEF        VAR rel_vlliqcre AS DECIMAL          EXTENT 4             NO-UNDO.
DEF        VAR rel_vldoipmf AS DECIMAL          EXTENT 4             NO-UNDO.
DEF        VAR rel_vlareceb AS DECIMAL          EXTENT 4             NO-UNDO.
DEF        VAR rel_vltarifa AS DECIMAL          EXTENT 4             NO-UNDO.
DEF        VAR rel_txareceb AS DECIMAL          EXTENT 4             NO-UNDO.

DEF        VAR aux_tpmepgto AS INT                                   NO-UNDO.
DEF        VAR aux_vltarifa AS DECIMAL                               NO-UNDO.
DEF        VAR aux_flgpione AS LOGICAL                               NO-UNDO.

FORM rel_dsmepgto                AT   5  LABEL "Pagamento"
                                         FORMAT "x(18)"
     rel_qtdpagto[aux_tpmepgto]  AT  27  LABEL "Quant"
                                         FORMAT "zzzz9"
     rel_vlliqcre[aux_tpmepgto]  AT  36  LABEL "Valor Pago"
                                         FORMAT "zzz,zzz,zz9.99"
     rel_vldoipmf[aux_tpmepgto]  AT  54  LABEL "CPMF Recolhido"
                                         FORMAT "zzz,zzz,zz9.99"
     rel_vlareceb[aux_tpmepgto]  AT  72  LABEL "Valor a Receber"
                                         FORMAT "zzz,zzz,zz9.99"
     rel_vltarifa[aux_tpmepgto]  AT  91  LABEL "Valor da Taxa"
                                         FORMAT "zzz,zzz,zz9.99"
     rel_txareceb[aux_tpmepgto]  AT 108  LABEL "Taxa a Receber"
                                         FORMAT "zzz,zzz,zz9.99"
     WITH DOWN NO-BOX NO-LABELS WIDTH 132 FRAME f_totais.
 
ASSIGN glb_cdprogra = "crps489"
       glb_cdcritic = 0.
       
RUN fontes/iniprg.p.

IF   glb_cdcritic > 0 THEN
     QUIT.

/* Valores das taxas a serem recebidas */
FIND craptab WHERE craptab.cdcooper = 0              AND
                   craptab.nmsistem = "CRED"         AND
                   craptab.tptabela = "GENERI"       AND
                   craptab.cdempres = 0              AND
                   craptab.cdacesso = "TARINSBCOB"   AND
                   craptab.tpregist = 0
                   NO-LOCK NO-ERROR.


{ includes/cabrel132_1.i }      /*  Monta cabecalho do relatorio  */

OUTPUT STREAM str_1 TO rl/crrl471.lst PAGED PAGE-SIZE 84.

VIEW STREAM str_1 FRAME f_cabrel132_1.

/* Relatorio diario */
ASSIGN rel_dtiniper = glb_dtmvtolt
       rel_dtfimper = glb_dtmvtolt.
       
PUT STREAM str_1 UNFORMATTED "REFERENCIA: "
                             STRING(rel_dtiniper,"99/99/9999")
                             SKIP(2).

RUN gera_relatorio.
       

/* Relatorio mensal */
IF   MONTH(glb_dtmvtolt) <> MONTH(glb_dtmvtopr)   THEN
     DO:
         ASSIGN rel_dtiniper = glb_dtmvtolt - DAY(glb_dtmvtolt) + 1
                rel_dtfimper = glb_dtmvtolt
                rel_qtdpagto = 0
                rel_vlliqcre = 0
                rel_vldoipmf = 0
                rel_vlareceb = 0
                rel_vltarifa = 0
                rel_txareceb = 0.

         PAGE STREAM str_1.
         
         PUT STREAM str_1 UNFORMATTED "REFERENCIA: "
                                      STRING(rel_dtiniper,"99/99/9999")
                                      " A "
                                      STRING(rel_dtfimper,"99/99/9999")
                                      SKIP(2).

         RUN gera_relatorio.
     END.

OUTPUT STREAM str_1 CLOSE.
                      
ASSIGN glb_nrcopias = 1
       glb_nmarqimp = "rl/crrl471.lst".

RUN fontes/imprim.p.

RUN fontes/fimprg.p.



PROCEDURE gera_relatorio:

    FOR EACH crapage WHERE crapage.cdcooper = glb_cdcooper NO-LOCK:
    
        /* Verifica se eh PA pioneiro */
        IF   crapage.tpagenci = 1   THEN
             aux_flgpione = YES.
        ELSE
             aux_flgpione = NO.


        /* Creditos pagos */
        FOR EACH craplbi WHERE craplbi.cdcooper  = glb_cdcooper       AND
                               craplbi.cdagenci  = crapage.cdagenci   AND
                               craplbi.dtdpagto >= rel_dtiniper       AND
                               craplbi.dtdpagto <= rel_dtfimper       NO-LOCK
                               BREAK BY craplbi.cdagenci:
                       

            /* PA pioneiro */
            IF   aux_flgpione = YES   THEN
                 ASSIGN aux_tpmepgto = 4
                        aux_vltarifa = DEC(SUBSTRING(craptab.dstextab,01,9)).
            ELSE
            /* Recibo ou Cartao */
            IF   craplbi.tpmepgto = 1   THEN
                 DO:
                     /* Busca o pagamento */
                     FIND LAST craplpi WHERE
                               craplpi.cdcooper = craplbi.cdcooper AND
                               craplpi.nrrecben = craplbi.nrrecben AND
                               craplpi.nrbenefi = craplbi.nrbenefi AND
                               craplpi.dtfimper = craplbi.dtfimper AND
                               craplpi.dtiniper = craplbi.dtiniper AND
                               craplpi.nrseqcre = craplbi.nrseqcre
                               NO-LOCK NO-ERROR.
                                
                     /* Pago com Cartao */
                     IF   craplpi.tppagben = 1   THEN
                          ASSIGN aux_tpmepgto = 1
                                 aux_vltarifa =
                                     DEC(SUBSTRING(craptab.dstextab,11,9)).
                     ELSE
                     /* Pago com Recibo */
                     IF   craplpi.tppagben = 2   THEN
                          ASSIGN aux_tpmepgto = 3
                                 aux_vltarifa =
                                     DEC(SUBSTRING(craptab.dstextab,31,9)).
                 END.
            ELSE
            /* Conta Corrente */
            IF   craplbi.tpmepgto = 2   THEN
                 ASSIGN aux_tpmepgto = 2
                        aux_vltarifa = DEC(SUBSTRING(craptab.dstextab,21,9)).
                            
                                
            ASSIGN rel_qtdpagto[aux_tpmepgto] = rel_qtdpagto[aux_tpmepgto] + 1
            
                   rel_vlliqcre[aux_tpmepgto] = rel_vlliqcre[aux_tpmepgto] + 
                                                craplbi.vlliqcre

                   rel_vldoipmf[aux_tpmepgto] = rel_vldoipmf[aux_tpmepgto] +
                                                (craplbi.vllanmto -
                                                 craplbi.vlliqcre)

                   rel_vlareceb[aux_tpmepgto] = rel_vlareceb[aux_tpmepgto] +
                                                craplbi.vllanmto

                   rel_vltarifa[aux_tpmepgto] = aux_vltarifa
                
                   rel_txareceb[aux_tpmepgto] = rel_txareceb[aux_tpmepgto] + 
                                                aux_vltarifa.
        END.
    END.


    DO  aux_tpmepgto = 1 TO 4:

        rel_dsmepgto = IF   aux_tpmepgto = 1   THEN
                            "Cartao"
                       ELSE
                       IF   aux_tpmepgto = 2   THEN
                            "Conta Corrente"
                       ELSE
                       IF   aux_tpmepgto = 3   THEN
                            "Recibo Avulso"
                       ELSE
                       IF   aux_tpmepgto = 4   THEN
                            "PA(s) Pioneiro(s)"
                       ELSE
                            "**Desconhecido**".
 
        DISPLAY STREAM str_1 rel_dsmepgto
                             rel_qtdpagto[aux_tpmepgto]
                             rel_vlliqcre[aux_tpmepgto]
                             rel_vldoipmf[aux_tpmepgto]
                             rel_vlareceb[aux_tpmepgto]
                             rel_vltarifa[aux_tpmepgto]
                             rel_txareceb[aux_tpmepgto]
                             WITH FRAME f_totais.
                         
        DOWN STREAM str_1 WITH FRAME f_totais.
    END.

    /* Total geral */
    DOWN 1 STREAM str_1 WITH FRAME f_totais.

    DISPLAY STREAM str_1 "TOTAL GERAL" @ rel_dsmepgto

                         (rel_qtdpagto[1] +
                          rel_qtdpagto[2] +
                          rel_qtdpagto[3] +
                          rel_qtdpagto[4]) @ rel_qtdpagto[aux_tpmepgto]

                         (rel_vlliqcre[1] +
                          rel_vlliqcre[2] +
                          rel_vlliqcre[3] +
                          rel_vlliqcre[4]) @ rel_vlliqcre[aux_tpmepgto]
                          
                         (rel_vldoipmf[1] +
                          rel_vldoipmf[2] +
                          rel_vldoipmf[3] +
                          rel_vldoipmf[4]) @ rel_vldoipmf[aux_tpmepgto]
                         
                         (rel_vlareceb[1] +
                          rel_vlareceb[2] +
                          rel_vlareceb[3] +
                          rel_vlareceb[4]) @ rel_vlareceb[aux_tpmepgto]

                         (rel_vltarifa[1] +
                          rel_vltarifa[2] +
                          rel_vltarifa[3] +
                          rel_vltarifa[4]) @ rel_vltarifa[aux_tpmepgto]

                         (rel_txareceb[1] +
                          rel_txareceb[2] +
                          rel_txareceb[3] +
                          rel_txareceb[4]) @ rel_txareceb[aux_tpmepgto]

                          WITH FRAME f_totais.
                         
    DOWN STREAM str_1 WITH FRAME f_totais.

END PROCEDURE. /* Fim gera_relatorio */
 
/* .......................................................................... */
