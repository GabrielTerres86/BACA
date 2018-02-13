/*.............................................................................

   Programa: b1wgen0010i.p                  
   Autor   : Gabriel Capoia - DB1.
   Data    : 19/01/2012                        Ultima atualizacao: 04/02/2016
    
   Dados referentes ao programa:

   Objetivo  : Tratar impressoes da BO 0010.
   
   Alteracoes: 30/11/2012 - Ajuste relatorio 504, passar parametro da coop.
                            ao buscar o cooperado (Rafael).
                            
               13/08/2013 - Nova forma de chamar as agências, alterado para
                         "Posto de Atendimento" (PA). (André Santos - SUPERO)
                         
               29/08/2014 - Ajuste no Relatório “Movimento de cobrança com registro” 
                            (Vanessa)
   
              01/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                           Cedente por Beneficiário e  Sacado por Pagador 
                           Chamado 229313 (Jean Reddiga - RKAM).  
                           
              20/03/2015 - Ajustado na procedure proc_crrl601 o format do campo 
                           cdagenci de "99" para "999" (Daniel)               
                           
              28/04/2015 - Adicionado campo do tipo de emissão nos relatórios
                           600 e 601. (Reinert)
             
             11/05/2015 - Adicionado campo do data de emissão nos relatórios
                           600 e 601. (Kelvin)

             01/06/2015 - Ajustes realizados:
                          - Na validação da data de emissao retroativa
                            para maior que 90 dias ao inves de 30;
                          - Na rotina proc_crrl600 sera apresentados as colunas
                            "Emissao","Documento;
                          - Na rotina proc_crrl601 foi alterado o nome da coluna
                            "Emissao" para "Documento";
                          (Adriano).			   

			04/02/2016 - Ajustes Projeto Negativação Serasa (Daniel)


.............................................................................*/

/*................................ DEFINICOES ...............................*/
{ sistema/generico/includes/b1wgen0010tt.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1cabrelvar.i }
{ sistema/generico/includes/gera_erro.i }
{ sistema/generico/includes/gera_log.i }

DEF STREAM str_1.
DEF STREAM str_2.
DEF STREAM str_3.

DEF VAR aux_cdcritic AS INTE                                        NO-UNDO.
DEF VAR aux_dscritic AS CHAR                                        NO-UNDO.
DEF VAR aux_dsorigem AS CHAR                                        NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                       NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                        NO-UNDO.
DEF VAR aux_contador AS INTE                                        NO-UNDO.
DEF VAR aux_returnvl AS CHAR                                        NO-UNDO.
DEF VAR aux_nrsequen AS INTE                                        NO-UNDO.

DEF VAR h-b1wgen0024 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1wgen0060 AS HANDLE                                      NO-UNDO.
DEF VAR h-b1crapsab  AS HANDLE                                      NO-UNDO.
DEF VAR h-b1crapcob  AS HANDLE                                      NO-UNDO.

DEF VAR ind_qtdebole AS INTE EXTENT 5                               NO-UNDO.
DEF VAR ind_vldebole AS DECI EXTENT 5                               NO-UNDO.
DEF VAR ind_vltarifa AS DECI                                        NO-UNDO.
                                                                    
DEF VAR ger_qtdebole AS INTE EXTENT 5 FORMAT "zzz,zz9"              NO-UNDO.
DEF VAR ger_vldebole AS DECI EXTENT 8 FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF VAR ger_vltarifa AS DECI          FORMAT "zzz,zzz,zzz,zz9.99"   NO-UNDO.
DEF VAR aux_indpagto AS INTE                                        NO-UNDO.
DEF VAR indice       AS INTE                                        NO-UNDO.
DEF VAR aux_inidtmvt AS DATE FORMAT "99/99/9999"                    NO-UNDO.
DEF VAR aux_fimdtmvt AS DATE FORMAT "99/99/9999"                    NO-UNDO.

/* Opção I */

DEF VAR aux_cdacesso AS CHAR                                     NO-UNDO.
DEF VAR aux_cdbancbb AS INTE                                     NO-UNDO.
DEF VAR aux_cdagenci AS INTE                                     NO-UNDO.
DEF VAR aux_cdbccxlt AS INTE                                     NO-UNDO.
DEF VAR aux_nrdolote AS INTE                                     NO-UNDO.
DEF VAR aux_cdhistor AS INTE                                     NO-UNDO.
DEF VAR aux_dsperiod AS CHAR                                     NO-UNDO.
DEF VAR aux_dsmsgerr AS CHAR                                     NO-UNDO.

DEF VAR aux_qtbloque AS INTE                                     NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                     NO-UNDO.
DEF VAR aux_nrbloque AS DECI                                     NO-UNDO.
DEF VAR aux_dtemscob AS DATE                                     NO-UNDO.
DEF VAR aux_nrcnvcob AS INTE                                     NO-UNDO.
DEF VAR aux_nmprimtl AS CHAR                                     NO-UNDO.
DEF VAR aux_nrdctabb AS INTE                                     NO-UNDO.
DEF VAR aux_setlinha AS CHAR    FORMAT "x(243)"                  NO-UNDO.

DEF VAR aux_vltitulo LIKE crapcob.vltitulo                       NO-UNDO.
DEF VAR aux_vldescto LIKE crapcob.vldescto                       NO-UNDO.
DEF VAR aux_cdcartei LIKE crapcob.cdcartei                       NO-UNDO.
DEF VAR aux_dsdinstr LIKE crapcob.dsdinstr                       NO-UNDO.
DEF VAR aux_dtvencto LIKE crapcob.dtvencto                       NO-UNDO.
DEF VAR aux_cddespec LIKE crapcob.cddespec                       NO-UNDO.
DEF VAR aux_cdtpinsc LIKE crapcob.cdtpinsc                       NO-UNDO.
DEF VAR aux_nrinssac LIKE crapcob.nrinssac                       NO-UNDO.
DEF VAR aux_nmdsacad LIKE crapcob.nmdsacad                       NO-UNDO.
DEF VAR aux_dsendsac LIKE crapcob.dsendsac                       NO-UNDO.
DEF VAR aux_nmbaisac LIKE crapcob.nmbaisac                       NO-UNDO.
DEF VAR aux_nrcepsac LIKE crapcob.nrcepsac                       NO-UNDO.
DEF VAR aux_nmcidsac LIKE crapcob.nmcidsac                       NO-UNDO.
DEF VAR aux_cdufsaca LIKE crapcob.cdufsaca                       NO-UNDO.
DEF VAR aux_cdtpinav LIKE crapcob.cdtpinav                       NO-UNDO.
DEF VAR aux_nrinsava LIKE crapcob.nrinsava                       NO-UNDO.
DEF VAR aux_nmdavali LIKE crapcob.nmdavali                       NO-UNDO.
DEF VAR aux_dsdoccop LIKE crapcob.dsdoccop                       NO-UNDO.
DEF VAR aux_cdimpcob LIKE crapcob.cdimpcob                       NO-UNDO.
DEF VAR aux_flgimpre LIKE crapcob.flgimpre                       NO-UNDO.

/******/

FORM "Periodo"
     aux_inidtmvt
     "ate"
     aux_fimdtmvt
     WITH 0 DOWN NO-LABELS FRAME f_periodo_rel.

FORM "Status: Liquidado."
     WITH FRAME f_status_liquidado.

FORM "Status: A vencer/Vencido/Excluido/Baixado/Descontado."
     WITH FRAME f_status_nao_liquidado.

FORM "Qtd"    AT 50
     "Valor"  AT 67
     WITH FRAME f_geral.

FORM "Conta/dv:"
     crapass.nrdconta
     "-" 
     crapass.nmprimtl
     WITH NO-LABELS FRAME f_nome.

FORM aux_nrdconta          FORMAT "zzzz,zzz,9"          LABEL "Conta/DV"
    aux_nmprimtl   AT 15  FORMAT "x(40)"               LABEL "Nome" /*001*/
    aux_nrbloque   AT 60  FORMAT "99999999,999999999"  LABEL "Documento"
    WITH NO-BOX DOWN NO-LABEL WIDTH 80 FRAME f_rel.

FORM aux_setlinha  FORMAT "x(243)"
    WITH FRAME AA WIDTH 243 NO-BOX NO-LABELS.

/*........................... PROCEDURES EXTERNAS ..........................*/

PROCEDURE proc_crrl500:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inidtmvt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_fimdtmvt AS DATE                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-consulta-blt.

    FORM crapass.cdagenci COLUMN-LABEL "PA"
         ind_qtdebole[1]  LABEL "Tot.Boletos"
         ind_vldebole[1]  LABEL "Vl.Tot.Boletos"  FORMAT "zz,zzz,zz9.99"
         ind_qtdebole[2]  LABEL "Qt.Via Compe"
         ind_vldebole[2]  LABEL "Vlr.Via Compe"   FORMAT "zz,zzz,zz9.99"
         ind_qtdebole[3]  LABEL "Qt.Caixa"
         ind_vldebole[3]  LABEL "Vl.Caixa"        FORMAT "zz,zzz,zz9.99"
         ind_qtdebole[4]  LABEL "Qt.Internet"
         ind_vldebole[4]  LABEL "Vl.Internet"     FORMAT "zz,zzz,zz9.99"
         ind_vltarifa     LABEL "Vl.Receita"      FORMAT  "z,zzz,zz9.99"
         WITH DOWN WIDTH 132 FRAME f_liquidados.

    FORM crapass.cdagenci COLUMN-LABEL "PA"
         ind_qtdebole[1]  LABEL "Qt.A vencer"
         ind_vldebole[1]  LABEL "Vl.A vencer"     FORMAT "z,zzz,zz9.99" 
         ind_qtdebole[2]  LABEL "Qt.Vencido"
         ind_vldebole[2]  LABEL "Vl.Vencido"      FORMAT "z,zzz,zz9.99"
         ind_qtdebole[3]  LABEL "Qt.Excluido"
         ind_vldebole[3]  LABEL "Vl.Excluido"     FORMAT "z,zzz,zz9.99"
         ind_qtdebole[4]  LABEL "Qt.Baixado"
         ind_vldebole[4]  LABEL "Vl.Baixado"      FORMAT "z,zzz,zz9.99"
         ind_qtdebole[5]  LABEL "Qt.Desc."
         ind_vldebole[5]  LABEL "Vl.Desc."
         WITH DOWN WIDTH 132 FRAME f_boletos.

    FORM ger_qtdebole[1]  LABEL "Total Geral Boletos Liquidados             "
         ger_vldebole[1]  NO-LABEL
         SKIP(1)
         ger_qtdebole[2]  LABEL "Total Geral Boletos Liquidados via Comp.   "
         ger_vldebole[2]  NO-LABEL
         SKIP(1)
         ger_qtdebole[3]  LABEL "Total Geral Boletos Liquidados via Caixa   "
         ger_vldebole[3]  NO-LABEL
         SKIP(1)
         ger_qtdebole[4]  LABEL "Total Geral Boletos Liquidados via Internet"
         ger_vldebole[4]  NO-LABEL
         SKIP(1)
         "Total Geral Receita                        :"
         ger_vltarifa     NO-LABEL AT 54
         WITH WIDTH 132 SIDE-LABELS FRAME f_liquidados_totais.
 
    FORM ger_qtdebole[1]  LABEL "Total Geral Boletos a Vencer               "
         ger_vldebole[1]  NO-LABEL
         SKIP(1)
         ger_qtdebole[2]  LABEL "Total Geral Boletos Vencidos               "
         ger_vldebole[2]  NO-LABEL
         SKIP(1)
         ger_qtdebole[3]  LABEL "Total Geral Boletos Excluidos              "
         ger_vldebole[3]  NO-LABEL
         SKIP(1)
         ger_qtdebole[4]  LABEL "Total Geral Boletos Baixados               "
         ger_vldebole[4]  NO-LABEL
         SKIP(1)
         ger_qtdebole[5]  LABEL "Total Geral Boletos Descontados            "
         ger_vldebole[5]  NO-LABEL
         WITH WIDTH 132 SIDE-LABELS FRAME f_boletos_totais.
    
    ASSIGN ger_qtdebole = 0
           ger_vldebole = 0
           ger_vltarifa = 0
           aux_inidtmvt = par_inidtmvt
           aux_fimdtmvt = par_fimdtmvt
           .

    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp)  PAGED PAGE-SIZE 84.

    /* Cdempres = 11 , Relatorio 500 em 132 colunas */
    { sistema/generico/includes/cabrel.i "11" "500" "132" }

    DISPLAY STREAM str_1 aux_inidtmvt aux_fimdtmvt WITH FRAME f_periodo_rel.

    VIEW STREAM str_1 FRAME f_status_liquidado.

    FOR EACH tt-consulta-blt WHERE tt-consulta-blt.cdcooper = par_cdcooper AND
                                   tt-consulta-blt.cdsituac = "L"          AND
                                   tt-consulta-blt.dsdpagto <> ""      NO-LOCK,
        FIRST crapass WHERE crapass.cdcooper = par_cdcooper             AND
                            crapass.nrdconta = tt-consulta-blt.nrdconta NO-LOCK
                            BREAK BY crapass.cdagenci:   

        CASE tt-consulta-blt.dsdpagto:
            WHEN "COMPENSACAO"  OR  WHEN "LANCOB"  THEN aux_indpagto = 2.
            WHEN "CAIXA"                           THEN aux_indpagto = 3.
            WHEN "INTERNET"                        THEN aux_indpagto = 4. 
        END CASE.

        ASSIGN ind_qtdebole[1] = ind_qtdebole[1] + 1 /* Boletos por PA */
               ind_vldebole[1] = ind_vldebole[1] + tt-consulta-blt.vldpagto
               ind_qtdebole[aux_indpagto] = ind_qtdebole[aux_indpagto] + 1
               ind_vldebole[aux_indpagto] = ind_vldebole[aux_indpagto] +
                                            tt-consulta-blt.vldpagto
               ind_vltarifa   = ind_vltarifa + tt-consulta-blt.vltarifa.

        IF  tt-consulta-blt.flgdesco = "*" THEN
            ASSIGN ind_qtdebole[5] = ind_qtdebole[5] + 1
                   ind_vldebole[5] = ind_vldebole[5] + tt-consulta-blt.vldpagto.

        IF  LAST-OF(crapass.cdagenci) THEN
            DO:
                DISPLAY STREAM str_1 crapass.cdagenci    
                                     ind_qtdebole[1]    ind_vldebole[1]
                                     ind_qtdebole[2]    ind_vldebole[2]
                                     ind_qtdebole[3]    ind_vldebole[3]
                                     ind_qtdebole[4]    ind_vldebole[4]
                                     ind_vltarifa       WITH FRAME f_liquidados.
                        
                DOWN WITH FRAME f_liquidados.
                
                DO indice = 1 to 4:
                
                    ASSIGN ger_qtdebole[indice] = ger_qtdebole[indice] +
                                                  ind_qtdebole[indice]
                           ger_vldebole[indice] = ger_vldebole[indice] +
                                                  ind_vldebole[indice]
                           ind_qtdebole[indice] = 0
                           ind_vldebole[indice] = 0.
                END.  /* Fim valores gerais */
                       
                ASSIGN ger_vltarifa = ger_vltarifa + ind_vltarifa
                       ind_vltarifa = 0. 

            END.   /* Fim LAST-OF cdagenci */

    END. /* Fim boletos liquidados */

    VIEW STREAM str_1 FRAME f_geral.

    DISPLAY STREAM str_1 ger_qtdebole[1]   ger_vldebole[1]
                         ger_qtdebole[2]   ger_vldebole[2]
                         ger_qtdebole[3]   ger_vldebole[3]
                         ger_qtdebole[4]   ger_vldebole[4]
                         ger_vltarifa      WITH FRAME f_liquidados_totais.

    ASSIGN ger_qtdebole = 0
           ger_vldebole = 0
           ger_vltarifa = 0.

    DISPLAY STREAM str_1 SKIP(1) WITH FRAME f_pula. 

    DISPLAY STREAM str_1 aux_inidtmvt aux_fimdtmvt WITH FRAME f_periodo_rel.

    VIEW STREAM str_1 FRAME f_status_nao_liquidado.

    FOR EACH tt-consulta-blt WHERE tt-consulta-blt.cdcooper  = par_cdcooper AND
                                   tt-consulta-blt.cdsituac <> "L"     NO-LOCK,
        FIRST crapass WHERE crapass.cdcooper = par_cdcooper             AND
                            crapass.nrdconta = tt-consulta-blt.nrdconta NO-LOCK
                            BREAK BY crapass.cdagenci:

        CASE tt-consulta-blt.cdsituac:
            WHEN "A" THEN ASSIGN aux_indpagto = 1. /*  Aberto   */
            WHEN "V" THEN ASSIGN aux_indpagto = 2. /*  Vencido  */
            WHEN "E" THEN ASSIGN aux_indpagto = 3. /*  Excluido */
            WHEN "B" THEN ASSIGN aux_indpagto = 4. /*  Baixado  */
        END CASE.

        IF  aux_indpagto = 1   THEN   /* Em aberto */
            DO:
                IF  tt-consulta-blt.vltitulo = 0 AND
                    tt-consulta-blt.dtdpagto = ? THEN
                    NEXT.
            END.

        ASSIGN ind_qtdebole[aux_indpagto] = ind_qtdebole[aux_indpagto] + 1
               ind_vldebole[aux_indpagto] = ind_vldebole[aux_indpagto] + 
                                            tt-consulta-blt.vltitulo.

        IF  tt-consulta-blt.flgdesco = "*" THEN
            ASSIGN ind_qtdebole[5] = ind_qtdebole[5] + 1
                   ind_vldebole[5] = ind_vldebole[5] + tt-consulta-blt.vltitulo.

        IF  LAST-OF(crapass.cdagenci) THEN
            DO:
                DISPLAY STREAM str_1 crapass.cdagenci
                                     ind_qtdebole[1]    ind_vldebole[1]
                                     ind_qtdebole[2]    ind_vldebole[2]
                                     ind_qtdebole[3]    ind_vldebole[3]
                                     ind_qtdebole[4]    ind_vldebole[4]
                                     ind_qtdebole[5]    ind_vldebole[5] 
                                     WITH FRAME f_boletos.
 
                DOWN WITH FRAME f_boletos.
                
                DO indice = 1 TO 5:

                    ASSIGN ger_qtdebole[indice] = ger_qtdebole[indice] +
                                                  ind_qtdebole[indice]
                           ger_vldebole[indice] = ger_vldebole[indice] +
                                                  ind_vldebole[indice]
                           ind_qtdebole[indice] = 0
                           ind_vldebole[indice] = 0.
                END.   /* Fim valores gerais */
            END.

    END. /* Fim boletos a vencer/vencido/excluido/baixado/descontado */

    VIEW STREAM str_1 FRAME f_geral.

    DISPLAY STREAM str_1 ger_qtdebole[1]  ger_vldebole[1]
                         ger_qtdebole[2]  ger_vldebole[2]
                         ger_qtdebole[3]  ger_vldebole[3]
                         ger_qtdebole[4]  ger_vldebole[4]
                         ger_qtdebole[5]  ger_vldebole[5] 
                         WITH FRAME f_boletos_totais.

    OUTPUT STREAM str_1 CLOSE. 

    RETURN "OK".
   
END PROCEDURE. /* Gestao da carteira de cobranca sem registro - por PA */

PROCEDURE proc_crrl501:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inidtmvt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_fimdtmvt AS DATE                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-consulta-blt.

    FORM crapass.cdagenci COLUMN-LABEL "PA"
         crapass.nrdconta COLUMN-LABEL "C/C"
         ind_qtdebole[1]  LABEL "Tot.Boletos"
         ind_vldebole[1]  LABEL "Vl.Tot.Boletos" FORMAT "zz,zzz,zz9.99"
         ind_qtdebole[2]  LABEL "Qt.Via Compe"
         ind_vldebole[2]  LABEL "Vl.Via Compe"   FORMAT "zz,zzz,zz9.99"
         ind_qtdebole[3]  LABEL "Qt.Caixa"
         ind_vldebole[3]  LABEL "Vl.Caixa"
         ind_qtdebole[4]  LABEL "Qt.Internet"
         ind_vldebole[4]  LABEL "Vl.Internet"
         ind_vltarifa     LABEL "Vl.Receita"
         WITH DOWN WIDTH 132 FRAME f_liquidados.
     
    FORM crapass.cdagenci COLUMN-LABEL "PA"
         crapass.nrdconta COLUMN-LABEL "C/C"
         ind_qtdebole[1]  LABEL "Qt.A venc."
         ind_vldebole[1]  LABEL "Vlr.A vencer" 
         ind_qtdebole[2]  LABEL "Qt.Venc."
         ind_vldebole[2]  LABEL "Vlr.Vencido"  
         ind_qtdebole[3]  LABEL "Qt.Excl."
         ind_vldebole[3]  LABEL "Vlr.Excluido" 
         ind_qtdebole[4]  LABEL "Qt.Baix."
         ind_vldebole[4]  LABEL "Vlr.Baixado"  
         ind_qtdebole[5]  LABEL "Qt.Desc."
         ind_vldebole[5]  LABEL "Vlr.Desc."
         WITH DOWN WIDTH 132 FRAME f_boletos.
    
    FORM ger_qtdebole[1]  LABEL "Total Geral Boletos Liquidados             "
         ger_vldebole[1]  NO-LABEL
         SKIP(1)
         ger_qtdebole[2]  LABEL "Total Geral Boletos Liquidados via Comp.   "
         ger_vldebole[2]  NO-LABEL
         SKIP(1)
         ger_qtdebole[3]  LABEL "Total Geral Boletos Liquidados via Caixa   "
         ger_vldebole[3]  NO-LABEL
         SKIP(1)
         ger_qtdebole[4]  LABEL "Total Geral Boletos Liquidados via Internet"
         ger_vldebole[4]  NO-LABEL
         SKIP(1)
         "Total Geral Receita                        :"
         ger_vltarifa     NO-LABEL AT 54
         WITH WIDTH 132 SIDE-LABELS FRAME f_liquidados_totais.
   
    FORM ger_qtdebole[1]  LABEL "Total Geral Boletos a Vencer               "
         ger_vldebole[1]  NO-LABEL
         SKIP(1)
         ger_qtdebole[2]  LABEL "Total Geral Boletos Vencidos               "
         ger_vldebole[2]  NO-LABEL
         SKIP(1)
         ger_qtdebole[3]  LABEL "Total Geral Boletos Excluidos              "
         ger_vldebole[3]  NO-LABEL
         SKIP(1)
         ger_qtdebole[4]  LABEL "Total Geral Boletos Baixados               "
         ger_vldebole[4]  NO-LABEL
         SKIP(1)
         ger_qtdebole[5]  LABEL "Total Geral Boletos Descontados            "
         ger_vldebole[5]  NO-LABEL
         WITH WIDTH 132 SIDE-LABELS FRAME f_boletos_totais.
    
    ASSIGN ger_qtdebole = 0
           ger_vldebole = 0
           ger_vltarifa = 0
           aux_inidtmvt = par_inidtmvt
           aux_fimdtmvt = par_fimdtmvt.
   
    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 84.
             
    /* Cdempres = 11 , Relatorio 501 em 132 colunas */
    { sistema/generico/includes/cabrel.i "11" "501" "132" }
   
    DISPLAY STREAM str_1 aux_inidtmvt aux_fimdtmvt WITH FRAME f_periodo_rel.

    VIEW STREAM str_1 FRAME f_status_liquidado. 

    IF  par_nrdconta > 0 THEN
        DO:
            FIND crapass WHERE crapass.cdcooper = par_cdcooper   AND
                               crapass.nrdconta = par_nrdconta 
                               NO-LOCK NO-ERROR.
                               
            DISPLAY STREAM str_1 crapass.nrdconta  crapass.nmprimtl 
                                 WITH FRAME f_nome.
        END.

    FOR EACH tt-consulta-blt WHERE tt-consulta-blt.cdcooper  = par_cdcooper AND
                                   tt-consulta-blt.cdsituac  = "L"          AND
                                   tt-consulta-blt.dsdpagto <> ""           AND
                                 ((par_nrdconta > 0                         AND 
                                   tt-consulta-blt.nrdconta = par_nrdconta) OR
                                   par_nrdconta = 0)                   NO-LOCK,
       FIRST crapass WHERE crapass.cdcooper = par_cdcooper             AND
                           crapass.nrdconta = tt-consulta-blt.nrdconta AND
                         ((par_cdagencx > 0                            AND
                           crapass.cdagenci = par_cdagencx)            OR
                           par_cdagencx = 0)                           NO-LOCK
                           BREAK BY crapass.nrdconta:

        CASE tt-consulta-blt.dsdpagto:
            WHEN "COMPENSACAO"  OR  WHEN "LANCOB"  THEN aux_indpagto = 2.
            WHEN "CAIXA"                           THEN aux_indpagto = 3.
            WHEN "INTERNET"                        THEN aux_indpagto = 4.
        END CASE.

        ASSIGN ind_qtdebole[1] = ind_qtdebole[1] + 1 /* Boletos por Conta */
               ind_vldebole[1] = ind_vldebole[1] + tt-consulta-blt.vldpagto
               ind_qtdebole[aux_indpagto] = ind_qtdebole[aux_indpagto] + 1
               ind_vldebole[aux_indpagto] = ind_vldebole[aux_indpagto] +
                                            tt-consulta-blt.vldpagto
               ind_vltarifa   = ind_vltarifa + tt-consulta-blt.vltarifa.

        IF  tt-consulta-blt.flgdesco = "*" THEN
            ASSIGN ind_qtdebole[5] = ind_qtdebole[5] + 1
                   ind_vldebole[5] = ind_vldebole[5] + tt-consulta-blt.vldpagto.

        IF  LAST-OF(crapass.nrdconta) THEN
            DO:
                DISPLAY STREAM str_1 crapass.cdagenci   crapass.nrdconta
                                     ind_qtdebole[1]    ind_vldebole[1]
                                     ind_qtdebole[2]    ind_vldebole[2]
                                     ind_qtdebole[3]    ind_vldebole[3]
                                     ind_qtdebole[4]    ind_vldebole[4]
                                     ind_vltarifa       WITH FRAME f_liquidados.

                DOWN WITH FRAME f_liquidados.
   
                DO indice = 1 to 4:

                    ASSIGN ger_qtdebole[indice] = ger_qtdebole[indice] +
                                                  ind_qtdebole[indice]
                           ger_vldebole[indice] = ger_vldebole[indice] +
                                                  ind_vldebole[indice]
                           ind_qtdebole[indice] = 0
                           ind_vldebole[indice] = 0.
                END.  

                ASSIGN ger_vltarifa = ger_vltarifa + ind_vltarifa
                       ind_vltarifa = 0.
            
            END. /* Fim valores gerais */
    END. /* Fim FOR EACH liquidados */

    VIEW STREAM str_1 FRAME f_geral.

    DISPLAY STREAM str_1 ger_qtdebole[1]   ger_vldebole[1]
                         ger_qtdebole[2]   ger_vldebole[2]
                         ger_qtdebole[3]   ger_vldebole[3]
                         ger_qtdebole[4]   ger_vldebole[4]
                         ger_vltarifa      WITH FRAME f_liquidados_totais.

    ASSIGN ger_qtdebole = 0
           ger_vldebole = 0
           ger_vltarifa = 0.

    DISPLAY STREAM str_1 SKIP(1) WITH FRAME f_pula. 

    DISPLAY STREAM str_1 aux_inidtmvt aux_fimdtmvt WITH FRAME f_periodo_rel.
   
    VIEW STREAM str_1 FRAME f_status_nao_liquidado.
   
    FOR EACH tt-consulta-blt WHERE tt-consulta-blt.cdcooper  = par_cdcooper AND
                                   tt-consulta-blt.cdsituac <> "L"          AND
                                ((par_nrdconta > 0                          AND
                                  tt-consulta-blt.nrdconta = par_nrdconta)  OR
                                  par_nrdconta = 0)                    NO-LOCK,
       FIRST crapass WHERE crapass.cdcooper = par_cdcooper             AND
                           crapass.nrdconta = tt-consulta-blt.nrdconta AND
                         ((par_cdagencx > 0                            AND
                           crapass.cdagenci = par_cdagencx)            OR
                           par_cdagencx = 0)                           NO-LOCK
                           BREAK BY crapass.nrdconta:

        CASE tt-consulta-blt.cdsituac:
            WHEN "A"   THEN   ASSIGN aux_indpagto = 1.   /*  Aberto     */
            WHEN "V"   THEN   ASSIGN aux_indpagto = 2.   /*  Vencido    */
            WHEN "E"   THEN   ASSIGN aux_indpagto = 3.   /*  Excluido   */
            WHEN "B"   THEN   ASSIGN aux_indpagto = 4.   /*  Baixado    */
        END CASE.

        IF  aux_indpagto = 1 THEN  /* Em aberto */
            DO:
                IF  tt-consulta-blt.vltitulo = 0 AND
                    tt-consulta-blt.dtdpagto = ? THEN
                    NEXT.
            END.

        IF  tt-consulta-blt.flgdesco = "*" THEN
            ASSIGN ind_qtdebole[5] = ind_qtdebole[5] + 1
                   ind_vldebole[5] = ind_vldebole[5] + tt-consulta-blt.vltitulo.

        ASSIGN ind_qtdebole[aux_indpagto] = ind_qtdebole[aux_indpagto] + 1
               ind_vldebole[aux_indpagto] = ind_vldebole[aux_indpagto] +
                                            tt-consulta-blt.vltitulo.

        IF  LAST-OF(crapass.nrdconta)  THEN
            DO:
                DISPLAY STREAM str_1 crapass.cdagenci   crapass.nrdconta
                                     ind_qtdebole[1]    ind_vldebole[1]
                                     ind_qtdebole[2]    ind_vldebole[2]
                                     ind_qtdebole[3]    ind_vldebole[3]
                                     ind_qtdebole[4]    ind_vldebole[4]
                                     ind_qtdebole[5]    ind_vldebole[5]
                                     WITH FRAME f_boletos.
                
                DOWN WITH FRAME f_boletos.
                
                DO indice = 1 to 5:

                    ASSIGN ger_qtdebole[indice] = ger_qtdebole[indice] +
                                                  ind_qtdebole[indice]
                           ger_vldebole[indice] = ger_vldebole[indice] +
                                                  ind_vldebole[indice]
                           ind_qtdebole[indice] = 0
                           ind_vldebole[indice] = 0.

                END.  /* Fim valores gerais */ 

            END.    /* Fim LAST-OF nrdconta   */
            
   END. /* Fim for-each nao liquidados */

   VIEW STREAM str_1 FRAME f_geral. 

   DISPLAY STREAM str_1 ger_qtdebole[1]  ger_vldebole[1]
                        ger_qtdebole[2]  ger_vldebole[2]
                        ger_qtdebole[3]  ger_vldebole[3]
                        ger_qtdebole[4]  ger_vldebole[4]
                        ger_qtdebole[5]  ger_vldebole[5]
                        WITH FRAME f_boletos_totais.
         
   OUTPUT STREAM str_1 CLOSE.

   RETURN "OK".
   
END PROCEDURE. /* Gestao da carteira de cobranca s/ registro - por cooperado*/

PROCEDURE proc_crrl502:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_inidtmvt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_fimdtmvt AS DATE                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-consulta-blt.

    FORM crapass.cdagenci COLUMN-LABEL "PA"
         ind_qtdebole[1]  LABEL "Tot.Boletos"
         ind_vldebole[1]  LABEL "Vl.Tot.Boletos"   FORMAT "zz,zzz,zz9.99"
         ind_qtdebole[2]  LABEL "Qt.Internet"
         ind_vldebole[2]  LABEL "Vlr.Internet"     FORMAT "zz,zzz,zz9.99"
         ind_qtdebole[3]  LABEL "Qt.Software"
         ind_vldebole[3]  LABEL "Vl.Software"      FORMAT "zz,zzz,zz9.99"
         ind_qtdebole[4]  LABEL "Qt.Pre-impresso"
         ind_vldebole[4]  LABEL "Vl.Pre-impresso"  FORMAT "zz,zzz,zz9.99"
         WITH DOWN WIDTH 132 FRAME f_crrl502.
    
    FORM "Total Geral Boletos Liquidados"
         SPACE(13)
         ":"
         ger_qtdebole[1]  NO-LABEL 
         ger_vldebole[1]  NO-LABEL
         SKIP(1)
         ger_qtdebole[2]  LABEL "Total Geral Boletos Internet               "
         ger_vldebole[2]  NO-LABEL
         SKIP(1)
         ger_qtdebole[3]  LABEL "Total Geral Boletos Software               "
         ger_vldebole[3]  NO-LABEL
         SKIP(1)                                                             
         ger_qtdebole[4]  LABEL "Total Geral Boletos Pre-Impresso           "
         ger_vldebole[4]  NO-LABEL
         WITH WIDTH 132   SIDE-LABELS FRAME f_crrl502_totais.

    ASSIGN ger_qtdebole    = 0
           ger_vldebole    = 0
           aux_inidtmvt = par_inidtmvt
           aux_fimdtmvt = par_fimdtmvt.
         
    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 84.
              
    /* Cdempres = 11 , Relatorio 502 em 132 colunas */
    { sistema/generico/includes/cabrel.i "11" "502" "132" }
    
    DISPLAY STREAM str_1 aux_inidtmvt aux_fimdtmvt WITH FRAME f_periodo_rel.

    VIEW STREAM str_1 FRAME f_status_liquidado.
  
    FOR EACH tt-consulta-blt WHERE tt-consulta-blt.cdcooper = par_cdcooper  AND 
                                   tt-consulta-blt.cdsituac = "L"       NO-LOCK,
        FIRST crapass WHERE crapass.cdcooper = par_cdcooper             AND
                            crapass.nrdconta = tt-consulta-blt.nrdconta NO-LOCK
                            BREAK BY crapass.cdagenci:

        ASSIGN ind_qtdebole[1] = ind_qtdebole[1] + 1
               ind_vldebole[1] = ind_vldebole[1] + tt-consulta-blt.vldpagto.
  
        IF  tt-consulta-blt.dsorgarq = "INTERNET"                  THEN
            ASSIGN ind_qtdebole[2] = ind_qtdebole[2] + 1
                   ind_vldebole[2] = ind_vldebole[2] + tt-consulta-blt.vldpagto.
        ELSE     
        IF  tt-consulta-blt.dsorgarq = "IMPRESSO PELO SOFTWARE"   THEN
            ASSIGN ind_qtdebole[3] = ind_qtdebole[3] + 1
                   ind_vldebole[3] = ind_vldebole[3] + tt-consulta-blt.vldpagto.
        ELSE
        IF  tt-consulta-blt.dsorgarq = "PRE-IMPRESSO"              THEN
            ASSIGN ind_qtdebole[4] = ind_qtdebole[4] + 1
                   ind_vldebole[4] = ind_vldebole[4] + tt-consulta-blt.vldpagto.
        
        IF  LAST-OF(crapass.cdagenci) THEN
            DO:
                DISPLAY STREAM str_1 crapass.cdagenci
                                     ind_qtdebole[1]    ind_vldebole[1]
                                     ind_qtdebole[2]    ind_vldebole[2]
                                     ind_qtdebole[3]    ind_vldebole[3]
                                     ind_qtdebole[4]    ind_vldebole[4]
                                     WITH FRAME f_crrl502.
  
                DOWN WITH FRAME f_crrl502.

                DO indice = 1 TO 4:

                    ASSIGN ger_qtdebole[indice] = ger_qtdebole[indice] +
                                                  ind_qtdebole[indice]
                           ger_vldebole[indice] = ger_vldebole[indice] +
                                                  ind_vldebole[indice]
                           ind_qtdebole[indice] = 0
                           ind_vldebole[indice] = 0.
                          
                 END.  /* Fim valores gerais */
  
            END. /* Fim LAST-OF do PA */

    END. /* Fim Boletos liquidados  */ 
  
    VIEW STREAM str_1 FRAME f_geral.
        
    DISPLAY STREAM str_1 ger_qtdebole[1]   ger_vldebole[1]
                         ger_qtdebole[2]   ger_vldebole[2]
                         ger_qtdebole[3]   ger_vldebole[3]
                         ger_qtdebole[4]   ger_vldebole[4]
                         WITH FRAME f_crrl502_totais.
  
    OUTPUT STREAM str_1 CLOSE. 

    RETURN "OK".
  
END PROCEDURE. /**** Fim do Relatorio crrl502 ****/ 

PROCEDURE proc_crrl504:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nrdconta AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inidtmvt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_fimdtmvt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inidtdpa AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_fimdtdpa AS DATE                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-consulta-blt.
                     
    FORM par_inidtdpa LABEL "Data de Pagamento"
         "a"
         par_fimdtdpa NO-LABEL
  
         WITH SIDE-LABELS WIDTH 234 FRAME f_data_pagamento. 
     
    FORM tt-consulta-blt.nossonro COLUMN-LABEL "Nosso Numero"
         tt-consulta-blt.dsdoccop COLUMN-LABEL "Documento"     
         tt-consulta-blt.nrcnvcob COLUMN-LABEL "Convenio"
         tt-consulta-blt.dsdpagto COLUMN-LABEL "Forma de Pagto"
         tt-consulta-blt.cdbanpag COLUMN-LABEL "Banco"
         tt-consulta-blt.cdagepag COLUMN-LABEL "Agencia"
         tt-consulta-blt.dtdocmto COLUMN-LABEL "Emissao"       FORMAT "99/99/9999"
         tt-consulta-blt.dtvencto COLUMN-LABEL "Vencimento"    FORMAT "99/99/9999"
         tt-consulta-blt.dtdpagto COLUMN-LABEL "Liquidacao"    FORMAT "99/99/9999"
         tt-consulta-blt.vltitulo COLUMN-LABEL "Vlr.Nominal"  
         tt-consulta-blt.vldpagto COLUMN-LABEL "Vlr.Liquidado" 
         WITH DOWN WIDTH 234 FRAME f_crrl504.
  
    FORM "TOTAL"         AT 01
         ger_qtdebole[1] AT 85 NO-LABEL
         "Boletos(s)"
         ger_vldebole[1] AT 112 NO-LABEL FORMAT "zzz,zzz,zz9.99"
         ger_vldebole[2] AT 127 NO-LABEL FORMAT "zzz,zzz,zz9.99"
         WITH SIDE-LABEL WIDTH 234 FRAME f_tot_crrl504.
  
    ASSIGN ger_qtdebole    = 0
           ger_vldebole    = 0
           aux_inidtmvt = par_inidtmvt
           aux_fimdtmvt = par_fimdtmvt.
    
    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 62.
                            
    /* Cdempres = 11 , Relatorio 504 em 132 colunas */
    /*{ sistema/generico/includes/cabrel.i "11" "504" "132" }*/
    { sistema/generico/includes/b1cabrel234.i "11" "504" }

    FOR FIRST crapass FIELDS(nrdconta nmprimtl)
        WHERE crapass.cdcooper = par_cdcooper AND
              crapass.nrdconta = par_nrdconta NO-LOCK:

         DISPLAY STREAM str_1 crapass.nrdconta crapass.nmprimtl
             WITH FRAME f_nome.

    END.
    
    DISPLAY STREAM str_1 par_inidtdpa par_fimdtdpa WITH FRAME f_data_pagamento.

    FOR EACH tt-consulta-blt WHERE tt-consulta-blt.cdcooper = par_cdcooper AND
                                   tt-consulta-blt.nrdconta = par_nrdconta AND
                                   tt-consulta-blt.cdsituac = "L"
                                   NO-LOCK BY tt-consulta-blt.nrcnvcob
                                              BY tt-consulta-blt.dtdpagto
                                                 BY tt-consulta-blt.nossonro:
      
        DISPLAY STREAM str_1 tt-consulta-blt.nossonro  tt-consulta-blt.dsdoccop
                             tt-consulta-blt.nrcnvcob  tt-consulta-blt.dsdpagto
                             tt-consulta-blt.cdbanpag  tt-consulta-blt.cdagepag
                             tt-consulta-blt.dtdocmto  tt-consulta-blt.dtvencto  
                             tt-consulta-blt.dtdpagto  tt-consulta-blt.vltitulo  
                             tt-consulta-blt.vldpagto
                             WITH FRAME f_crrl504.
                                     
        DOWN WITH FRAME f_crrl504.            
         
        ASSIGN ger_qtdebole[1] = ger_qtdebole[1] + 1
               ger_vldebole[1] = ger_vldebole[1] + tt-consulta-blt.vltitulo
               ger_vldebole[2] = ger_vldebole[2] + tt-consulta-blt.vldpagto.
    END.                               
  
    DISPLAY STREAM str_1 ger_qtdebole[1]   ger_vldebole[1]   ger_vldebole[2]
                         WITH FRAME f_tot_crrl504.   
     
    OUTPUT STREAM str_1 CLOSE.

    RETURN "OK".
    
END PROCEDURE. /* Fim crrl504, relatorio de movimento de liquidacoes */

PROCEDURE proc_crrl600: /* Relat 5 - Cedente */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inidtmvt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_fimdtmvt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_inserasa AS INTE                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-consulta-blt.
    
    DEF VAR tot_qtdebole AS INTE EXTENT 5 FORMAT "zzz,zz9"            NO-UNDO.
    DEF VAR tot_vldebole AS DECI EXTENT 5 FORMAT "zzz,zzz,zzz,zz9.99" NO-UNDO.
    DEF VAR aux_nmprimtl AS CHAR                                      NO-UNDO.
  
    DEF VAR aux_dsserasa AS CHAR                                      NO-UNDO.
  
    FORM par_inidtmvt LABEL "Periodo"
         "a"
         par_fimdtmvt NO-LABEL
         tt-consulta-blt.dssituac LABEL "    Status" FORMAT "x(30)" SKIP
         tt-consulta-blt.cdagenci LABEL "    PA"     FORMAT "zz9"
         tt-consulta-blt.nrdconta LABEL "  C/C"      FORMAT "zzzz,zzz,9"
         " - "
         aux_nmprimtl             NO-LABEL       FORMAT "x(45)"
         WITH SIDE-LABELS WIDTH 234 FRAME f_header_status.
  
    FORM tt-consulta-blt.nrcnvcob COLUMN-LABEL "Convenio"
         tt-consulta-blt.dsdoccop COLUMN-LABEL "N Docto"
         tt-consulta-blt.nrnosnum COLUMN-LABEL "Nosso Numero"
         tt-consulta-blt.dsemiten COLUMN-LABEL "Tp.Emis"
         tt-consulta-blt.dtmvtolt COLUMN-LABEL "Emissao"       FORMAT "99/99/99"
         tt-consulta-blt.dtdocmto COLUMN-LABEL "Documento"     FORMAT "99/99/99"
         tt-consulta-blt.dtvencto COLUMN-LABEL "Vencimento"    FORMAT "99/99/99"
         tt-consulta-blt.dtdpagto COLUMN-LABEL "Dt Pagto"      FORMAT "99/99/99"
         tt-consulta-blt.cdbanpag COLUMN-LABEL "Banco"
         tt-consulta-blt.cdagepag COLUMN-LABEL "Agencia"
         tt-consulta-blt.vltitulo COLUMN-LABEL "Vlr.Nominal"
         tt-consulta-blt.vldescto COLUMN-LABEL "Vlr Desconto"
         tt-consulta-blt.vlabatim COLUMN-LABEL "Vlr Abatim"
         tt-consulta-blt.vlrjuros COLUMN-LABEL "Vlr Juros"
         tt-consulta-blt.vldpagto COLUMN-LABEL "Vlr Pago"
         tt-consulta-blt.dsstacom COLUMN-LABEL "Status"        FORMAT "x(14)"
         WITH DOWN WIDTH 234 FRAME f_crrl600.
  
    FORM "TOTAL"         AT 01
         ger_qtdebole[1] AT 087 NO-LABEL
         "Boleto(s)"
         ger_vldebole[1] AT 115 NO-LABEL FORMAT "zzz,zzz,zz9.99"
         ger_vldebole[2] AT 132 NO-LABEL FORMAT "z,zzz,zz9.99"
         ger_vldebole[3] AT 147 NO-LABEL FORMAT "z,zzz,zz9.99"
         ger_vldebole[4] AT 160 NO-LABEL FORMAT "zzz,zz9.99"
         ger_vldebole[5] AT 171 NO-LABEL FORMAT "zzz,zzz,zz9.99"
         WITH SIDE-LABEL WIDTH 234 FRAME f_tot_crrl600.
  
    FORM "TOTAL GERAL"   AT 01
         tot_qtdebole[1] AT 087 NO-LABEL
         "Boleto(s)"
         tot_vldebole[1] AT 115 NO-LABEL FORMAT "zzz,zzz,zz9.99"
         tot_vldebole[2] AT 132 NO-LABEL FORMAT "z,zzz,zz9.99"
         tot_vldebole[3] AT 147 NO-LABEL FORMAT "z,zzz,zz9.99"
         tot_vldebole[4] AT 160 NO-LABEL FORMAT "zzz,zz9.99"
         tot_vldebole[5] AT 171 NO-LABEL FORMAT "zzz,zzz,zz9.99"
         WITH SIDE-LABEL WIDTH 234 FRAME f_tot_geral_600.
  
    ASSIGN ger_qtdebole    = 0
           ger_vldebole    = 0
           tot_qtdebole    = 0
           tot_vldebole    = 0
           aux_inidtmvt = par_inidtmvt
           aux_fimdtmvt = par_fimdtmvt.
    
    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 62.
  
    { sistema/generico/includes/b1cabrel234.i "11" "600" }
  
    FOR EACH tt-consulta-blt WHERE tt-consulta-blt.cdcooper = par_cdcooper AND
									(IF par_tprelato = 8 THEN
										tt-consulta-blt.cdocorre = 20 ELSE TRUE) AND
                                 ((tt-consulta-blt.cdagenci = par_cdagencx AND
                                               par_cdagencx > 0 )          OR
                                               par_cdagencx = 0)
                                   NO-LOCK 
                          BREAK BY tt-consulta-blt.dssituac
                                BY tt-consulta-blt.dsstacom
                                BY tt-consulta-blt.nrcnvcob
                                BY tt-consulta-blt.dsdoccop:
  
        IF  FIRST-OF(tt-consulta-blt.dssituac) THEN DO:
  
            FIND crapass WHERE crapass.cdcooper = par_cdcooper
                           AND crapass.nrdconta = tt-consulta-blt.nrdconta
                       NO-LOCK NO-ERROR.
                        
            IF   AVAILABLE crapass THEN
                  ASSIGN aux_nmprimtl =  crapass.nmprimtl.
  
            CASE par_inserasa:
              WHEN 1 THEN
                aux_dsserasa = "TODOS".
              WHEN 2 THEN
                aux_dsserasa = "NAO NEGATIVADO".
              WHEN 3 THEN
                aux_dsserasa = "SOL. ENVIADAS".
              WHEN 4 THEN
                aux_dsserasa = "NEGATIVADOS".
              WHEN 5 THEN
                aux_dsserasa = "SOL. COM ERROS".
            END CASE.
            
            DISPLAY STREAM str_1 par_inidtmvt par_fimdtmvt
                                 tt-consulta-blt.dssituac
                                 tt-consulta-blt.cdagenci
                                 tt-consulta-blt.nrdconta
                                 aux_nmprimtl
                              /*   aux_dsserasa */
                WITH FRAME f_header_status.
        END.
  
      
        DISPLAY STREAM str_1 tt-consulta-blt.nrcnvcob tt-consulta-blt.dsdoccop
                             tt-consulta-blt.nrnosnum tt-consulta-blt.dsemiten
                             tt-consulta-blt.dtdocmto tt-consulta-blt.dtmvtolt
                             tt-consulta-blt.dtvencto tt-consulta-blt.dtdpagto
                             tt-consulta-blt.cdbanpag tt-consulta-blt.cdagepag
                             tt-consulta-blt.vltitulo tt-consulta-blt.vldescto
                             tt-consulta-blt.vlabatim tt-consulta-blt.vlrjuros
                             tt-consulta-blt.vldpagto tt-consulta-blt.dsstacom
             WITH FRAME f_crrl600.
        DOWN WITH FRAME f_crrl600.
  
  
        ASSIGN ger_qtdebole[1] = ger_qtdebole[1] + 1
               ger_vldebole[1] = ger_vldebole[1] + tt-consulta-blt.vltitulo
               ger_vldebole[2] = ger_vldebole[2] + tt-consulta-blt.vldescto
               ger_vldebole[3] = ger_vldebole[3] + tt-consulta-blt.vlabatim
               ger_vldebole[4] = ger_vldebole[4] + tt-consulta-blt.vlrjuros
               ger_vldebole[5] = ger_vldebole[5] + IF tt-consulta-blt.vldpagto = ? THEN 0
                                                   ELSE tt-consulta-blt.vldpagto
               tot_qtdebole[1] = tot_qtdebole[1] + 1
               tot_vldebole[1] = tot_vldebole[1] + tt-consulta-blt.vltitulo
               tot_vldebole[2] = tot_vldebole[2] + tt-consulta-blt.vldescto
               tot_vldebole[3] = tot_vldebole[3] + tt-consulta-blt.vlabatim
               tot_vldebole[4] = tot_vldebole[4] + tt-consulta-blt.vlrjuros
               tot_vldebole[5] = tot_vldebole[5] + IF tt-consulta-blt.vldpagto = ? THEN 0
                                                   ELSE tt-consulta-blt.vldpagto.
  
        IF  LAST-OF(tt-consulta-blt.dssituac) THEN DO:
            DISPLAY STREAM str_1 ger_qtdebole[1] ger_vldebole[1] ger_vldebole[2]
                                 ger_vldebole[3] ger_vldebole[4] ger_vldebole[5]
                         WITH FRAME f_tot_crrl600.
            ASSIGN ger_qtdebole = 0
                   ger_vldebole = 0.
        END.
        
    END.                               
  
    DISPLAY STREAM str_1 tot_qtdebole[1] tot_vldebole[1] tot_vldebole[2]
                         tot_vldebole[3] tot_vldebole[4] tot_vldebole[5]
                         WITH FRAME f_tot_geral_600.
     
    OUTPUT STREAM str_1 CLOSE.

    RETURN "OK".

END PROCEDURE. /* Fim crrl600, relatorio de CEDENTE */


PROCEDURE proc_crrl601: /* Relat 6 - Francesa */

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqimp AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdagencx AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_inidtmvt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_fimdtmvt AS DATE                           NO-UNDO.
	DEF  INPUT PARAM par_tprelato AS INTE                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR tt-consulta-blt.

    DEF VAR tot_qtdebole AS INTE EXTENT 8 FORMAT "zzz,zz9"            NO-UNDO.
    DEF VAR tot_vldebole AS DECI EXTENT 8 FORMAT "zzz,zzz,zzz,zz9.99" NO-UNDO.
    DEF VAR aux_vlrjuros LIKE tt-consulta-blt.vlrjuros                NO-UNDO.
    DEF VAR aux_bcoagenc AS CHAR                                      NO-UNDO.
  
    FORM SKIP(1)
         tt-consulta-blt.cdbandoc LABEL "BANCO"
         par_inidtmvt LABEL "      PERIODO"
         "A"
         par_fimdtmvt NO-LABEL
         WITH SIDE-LABELS WIDTH 234 FRAME f_header_banco.
  
  
    FORM SKIP
         tt-consulta-blt.cdocorre LABEL "   -> Ocorrencia" FORMAT "99"
         "-" 
         tt-consulta-blt.dsocorre NO-LABEL FORMAT "x(80)"
         WITH SIDE-LABELS WIDTH 234 FRAME f_header_ocorrencia.
  
  
    FORM tt-consulta-blt.cdagenci COLUMN-LABEL "PA"           FORMAT "999"
         tt-consulta-blt.nrdconta COLUMN-LABEL "Conta"        FORMAT "zzzz,zzz,9"
         tt-consulta-blt.nrcnvcob COLUMN-LABEL "Convenio"     FORMAT "zzzzzz9"
         tt-consulta-blt.nrnosnum COLUMN-LABEL "Nosso Numero" FORMAT "X(17)"
         tt-consulta-blt.dsemiten COLUMN-LABEL "Tp.Emis"      FORMAT "x(5)"
         tt-consulta-blt.dsdoccop COLUMN-LABEL "N Docto"      FORMAT "X(12)"
         tt-consulta-blt.nmdsacad COLUMN-LABEL "Pagador"      FORMAT "x(14)"
         tt-consulta-blt.dtdocmto COLUMN-LABEL "Documento"    FORMAT "99/99/99" 
         tt-consulta-blt.dtvencto COLUMN-LABEL "Vencto"       FORMAT "99/99/99"
         tt-consulta-blt.vltitulo COLUMN-LABEL "Vlr.Boleto"   FORMAT "zzz,zzz,zz9.99"
         tt-consulta-blt.vldescto COLUMN-LABEL "Desconto"     FORMAT "zzz,zz9.99"
         tt-consulta-blt.vlabatim COLUMN-LABEL "Abatim"       FORMAT "zzz,zz9.99"
         aux_vlrjuros             COLUMN-LABEL "Jur/Mul"      FORMAT "z,zzz,zz9.99"
         tt-consulta-blt.vloutdes COLUMN-LABEL "Out Deb"      FORMAT "z,zz9.99"
         tt-consulta-blt.vloutcre COLUMN-LABEL "Out Cred"     FORMAT "z,zz9.99"
         tt-consulta-blt.vldpagto COLUMN-LABEL "Vlr Pago"     FORMAT "zzz,zzz,zz9.99"
         tt-consulta-blt.vltarifa COLUMN-LABEL " Tarifas"      FORMAT "z,zz9.99"
         aux_bcoagenc             COLUMN-LABEL "Bco/Age"      FORMAT "x(08)"
         tt-consulta-blt.dtocorre COLUMN-LABEL "Retorno"     FORMAT "99/99/99"
         tt-consulta-blt.dtcredit COLUMN-LABEL "Dt.Credit"   FORMAT "99/99/99"
         tt-consulta-blt.dsmotivo COLUMN-LABEL "Motivos"      FORMAT "x(23)"
         WITH DOWN WIDTH 245 FRAME f_crrl601.

    FORM tt-consulta-blt.cdagenci COLUMN-LABEL "PA"           FORMAT "999"
         tt-consulta-blt.nrdconta COLUMN-LABEL "Conta"        FORMAT "zzzz,zzz,9"
         tt-consulta-blt.nrcnvcob COLUMN-LABEL "Convenio"     FORMAT "zzzzzz9"
         tt-consulta-blt.nrnosnum COLUMN-LABEL "Nosso Numero" FORMAT "X(17)"
         tt-consulta-blt.dsemiten COLUMN-LABEL "Tp.Emis"      FORMAT "x(5)"
         tt-consulta-blt.dsdoccop COLUMN-LABEL "N Docto"      FORMAT "X(12)"
         tt-consulta-blt.nmdsacad COLUMN-LABEL "Pagador"      FORMAT "x(14)"
         tt-consulta-blt.dtdocmto COLUMN-LABEL "Documento"    FORMAT "99/99/99" 
         tt-consulta-blt.dtvencto COLUMN-LABEL "Vencto"       FORMAT "99/99/99"
         tt-consulta-blt.vltitulo COLUMN-LABEL "Vlr.Boleto"   FORMAT "zzz,zzz,zz9.99"
         tt-consulta-blt.vldescto COLUMN-LABEL "Desconto"     FORMAT "zzz,zz9.99"
         tt-consulta-blt.vlabatim COLUMN-LABEL "Abatim"       FORMAT "zzz,zz9.99"
         aux_vlrjuros             COLUMN-LABEL "Jur/Mul"      FORMAT "z,zzz,zz9.99"
         tt-consulta-blt.vloutdes COLUMN-LABEL "Out Deb"      FORMAT "z,zz9.99"
         tt-consulta-blt.vloutcre COLUMN-LABEL "Out Cred"     FORMAT "z,zz9.99"
         tt-consulta-blt.vldpagto COLUMN-LABEL "Vlr Pago"     FORMAT "zzz,zzz,zz9.99"
         tt-consulta-blt.vltarifa COLUMN-LABEL " Tarifas"     FORMAT "z,zz9.99"
         aux_bcoagenc             COLUMN-LABEL "Bco/Age"      FORMAT "x(08)"
         tt-consulta-blt.dtocorre COLUMN-LABEL "Dt.Pagto"     FORMAT "99/99/99"
         tt-consulta-blt.dtcredit COLUMN-LABEL "Dt.Credit"   FORMAT "99/99/99"
         tt-consulta-blt.dsmotivo COLUMN-LABEL "Motivos"      FORMAT "x(23)"
         WITH DOWN WIDTH 245 FRAME f_crrl601_2.
  
    FORM "TOTAL"         AT 001
         ger_qtdebole[1] AT 80 NO-LABEL FORMAT "zzz,zz9"
         "Boleto(s)"
         ger_vldebole[1] AT 098 NO-LABEL FORMAT "zzz,zzz,zz9.99"
         ger_vldebole[2] AT 113 NO-LABEL FORMAT "zzz,zz9.99"
         ger_vldebole[3] AT 124 NO-LABEL FORMAT "zzz,zz9.99"
         ger_vldebole[4] AT 135 NO-LABEL FORMAT "z,zzz,zz9.99"
         ger_vldebole[5] AT 148 NO-LABEL FORMAT "z,zz9.99"
         ger_vldebole[6] AT 157 NO-LABEL FORMAT "z,zz9.99"
         ger_vldebole[7] AT 166 NO-LABEL FORMAT "zzz,zzz,zz9.99"
         ger_vldebole[8] AT 181 NO-LABEL FORMAT "z,zz9.99"
         WITH SIDE-LABEL WIDTH 234 FRAME f_tot_crrl601.
  
    FORM "TOTAL GERAL"   AT 001
         tot_qtdebole[1] AT 080 NO-LABEL FORMAT "zzz,zz9"
         "Boleto(s)"           
         tot_vldebole[1] AT 098 NO-LABEL FORMAT "zzz,zzz,zz9.99"
         tot_vldebole[2] AT 113 NO-LABEL FORMAT "zzz,zz9.99"    
         tot_vldebole[3] AT 124 NO-LABEL FORMAT "zzz,zz9.99"    
         tot_vldebole[4] AT 135 NO-LABEL FORMAT "z,zzz,zz9.99"    
         tot_vldebole[5] AT 148 NO-LABEL FORMAT "z,zz9.99"    
         tot_vldebole[6] AT 157 NO-LABEL FORMAT "z,zz9.99"    
         tot_vldebole[7] AT 166 NO-LABEL FORMAT "zzz,zzz,zz9.99"
         tot_vldebole[8] AT 181 NO-LABEL FORMAT "z,zz9.99"    
         WITH SIDE-LABEL WIDTH 234 FRAME f_tot_geral_601.
  
    ASSIGN ger_qtdebole    = 0
           ger_vldebole    = 0
           tot_qtdebole    = 0
           tot_vldebole    = 0
           aux_inidtmvt = par_inidtmvt
           aux_fimdtmvt = par_fimdtmvt.
  
    OUTPUT STREAM str_1 TO VALUE (par_nmarqimp) PAGED PAGE-SIZE 62.
  
    { sistema/generico/includes/b1cabrel234.i "11" "601" }
  
    FOR EACH tt-consulta-blt WHERE tt-consulta-blt.cdcooper = par_cdcooper AND
                                 ((tt-consulta-blt.cdagenci = par_cdagencx AND
                                               par_cdagencx > 0 )          OR
                                               par_cdagencx = 0)
                NO-LOCK   BREAK BY tt-consulta-blt.cdbandoc
                                BY tt-consulta-blt.cdocorre
                                BY tt-consulta-blt.nrcnvcob
                                BY tt-consulta-blt.nrdconta
                                BY tt-consulta-blt.nrdocmto:
  
        ASSIGN aux_vlrjuros = tt-consulta-blt.vlrjuros + 
                              tt-consulta-blt.vlrmulta.
  
        IF tt-consulta-blt.cdbanpag <> "" AND
           tt-consulta-blt.cdagepag <> "" THEN
           aux_bcoagenc = TRIM(tt-consulta-blt.cdbanpag) + "/" +
                          TRIM(tt-consulta-blt.cdagepag).
        ELSE
           aux_bcoagenc = tt-consulta-blt.cdbanpag +
                          tt-consulta-blt.cdagepag.
  
        IF  FIRST-OF(tt-consulta-blt.cdbandoc) THEN
            DISPLAY STREAM str_1 tt-consulta-blt.cdbandoc
                                 par_inidtmvt par_fimdtmvt
                WITH FRAME f_header_banco.
  
  
        IF  FIRST-OF(tt-consulta-blt.cdocorre) THEN
            DISPLAY STREAM str_1 tt-consulta-blt.cdocorre
                                 tt-consulta-blt.dsocorre
                WITH FRAME f_header_ocorrencia.
  
       
        IF (INT(tt-consulta-blt.cdocorre) = 6 OR INT(tt-consulta-blt.cdocorre) = 17) THEN
            DO:
                
                  DISPLAY STREAM str_1 tt-consulta-blt.cdagenci tt-consulta-blt.nrdconta
                                 tt-consulta-blt.nrcnvcob tt-consulta-blt.nrnosnum
                                 tt-consulta-blt.dsemiten tt-consulta-blt.dsdoccop 
                                 tt-consulta-blt.nmdsacad tt-consulta-blt.dtdocmto
                                 tt-consulta-blt.dtvencto tt-consulta-blt.vltitulo
                                 tt-consulta-blt.vldescto tt-consulta-blt.vlabatim
                                 aux_vlrjuros             aux_bcoagenc 
                                 tt-consulta-blt.vldpagto tt-consulta-blt.vltarifa
                                 tt-consulta-blt.dsmotivo tt-consulta-blt.dtocorre 
                                 tt-consulta-blt.vloutdes tt-consulta-blt.vloutcre
                                 tt-consulta-blt.dtcredit
                                 
                                             
                 WITH FRAME f_crrl601_2.
                 DOWN WITH FRAME f_crrl601_2.
          END.
        ELSE 
              DISPLAY STREAM str_1 tt-consulta-blt.cdagenci tt-consulta-blt.nrdconta
                             tt-consulta-blt.nrcnvcob tt-consulta-blt.nrnosnum
                             tt-consulta-blt.dsemiten tt-consulta-blt.dsdoccop 
                             tt-consulta-blt.nmdsacad tt-consulta-blt.dtdocmto
                             tt-consulta-blt.dtvencto tt-consulta-blt.vltitulo
                             tt-consulta-blt.vldescto tt-consulta-blt.vlabatim
                             aux_vlrjuros             aux_bcoagenc 
                             tt-consulta-blt.vldpagto tt-consulta-blt.vltarifa
                             tt-consulta-blt.dsmotivo tt-consulta-blt.dtocorre 
                             tt-consulta-blt.vloutdes tt-consulta-blt.vloutcre
                             tt-consulta-blt.dtcredit
                             
                                         
             WITH FRAME f_crrl601.
             DOWN WITH FRAME f_crrl601.
        
       
              
            
       


        ASSIGN ger_qtdebole[1] = ger_qtdebole[1] + 1
               ger_vldebole[1] = ger_vldebole[1] + tt-consulta-blt.vltitulo
               ger_vldebole[2] = ger_vldebole[2] + tt-consulta-blt.vldescto
               ger_vldebole[3] = ger_vldebole[3] + tt-consulta-blt.vlabatim
               ger_vldebole[4] = ger_vldebole[4] + aux_vlrjuros
               ger_vldebole[5] = ger_vldebole[5] + tt-consulta-blt.vloutdes
               ger_vldebole[6] = ger_vldebole[6] + tt-consulta-blt.vloutcre
               ger_vldebole[7] = ger_vldebole[7] + tt-consulta-blt.vldpagto
               ger_vldebole[8] = ger_vldebole[8] + tt-consulta-blt.vltarifa
               tot_qtdebole[1] = tot_qtdebole[1] + 1
               tot_vldebole[1] = tot_vldebole[1] + tt-consulta-blt.vltitulo
               tot_vldebole[2] = tot_vldebole[2] + tt-consulta-blt.vldescto
               tot_vldebole[3] = tot_vldebole[3] + tt-consulta-blt.vlabatim
               tot_vldebole[4] = tot_vldebole[4] + tt-consulta-blt.vlrjuros
               tot_vldebole[5] = tot_vldebole[5] + tt-consulta-blt.vloutdes
               tot_vldebole[6] = tot_vldebole[6] + tt-consulta-blt.vloutcre
               tot_vldebole[7] = tot_vldebole[7] + tt-consulta-blt.vldpagto
               tot_vldebole[8] = tot_vldebole[8] + tt-consulta-blt.vltarifa
               aux_vlrjuros = 0
               aux_bcoagenc = "".
  
        IF  LAST-OF(tt-consulta-blt.cdocorre) THEN DO:
            DISPLAY STREAM str_1 ger_qtdebole[1]   ger_vldebole[1]   ger_vldebole[2]
                                 ger_vldebole[3]   ger_vldebole[4]   ger_vldebole[5]
                                 ger_vldebole[6]   ger_vldebole[7]   ger_vldebole[8]
                         WITH FRAME f_tot_crrl601.
            ASSIGN ger_qtdebole = 0
                   ger_vldebole = 0.
        END.
        
    END.                               
  
    DISPLAY STREAM str_1 tot_qtdebole[1]   tot_vldebole[1]   tot_vldebole[2]
                         tot_vldebole[3]   tot_vldebole[4]   tot_vldebole[5]
                         tot_vldebole[6]   tot_vldebole[7]   tot_vldebole[8]
                         WITH FRAME f_tot_geral_601.
     
    OUTPUT STREAM str_1 CLOSE.

    RETURN "OK".

END PROCEDURE. /* Fim crrl601, Relatorio Francesa C/ Registro */

PROCEDURE integra_arquivo:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_nmarqint AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dsnmarqv AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_vrsarqvs AS LOGI                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR w-arquivos.

    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF  INPUT-OUTPUT PARAM TABLE FOR crawrej.

    DEF BUFFER crabcop FOR crapcop.

    DEF VAR aux_flgfirst AS LOGI                                    NO-UNDO.
    DEF VAR aux_nmfisico AS CHAR                                    NO-UNDO.
    DEF VAR aux_nmarquiv AS CHAR                                    NO-UNDO.
    DEF VAR aux_dsnosnum AS CHAR                                    NO-UNDO.
    DEF VAR aux_flgutceb AS LOGI                                    NO-UNDO.

    FORM par_nmarqint  FORMAT "x(60)" LABEL "ARQUIVO"
        WITH SIDE-LABELS FRAME f_nomearquivo.
    
    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.
        
        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/" +
                              par_dsiduser.

/*         ASSIGN aux_nmendter = "sistema/equipe/db1/rel/cobran_boI_" + par_dsiduser. */

        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        IF  NOT par_vrsarqvs THEN /* Integra um unico arquivo */
            DO:
                CREATE w-arquivos.
                ASSIGN w-arquivos.tparquiv = "*"
                       w-arquivos.dsarquiv = par_nmarqint
                       w-arquivos.flginteg = YES.
            END.

        FOR EACH w-arquivos WHERE w-arquivos.flginteg
                            BREAK BY w-arquivos.flginteg:

            IF  par_vrsarqvs THEN
                ASSIGN par_nmarqint = par_dsnmarqv + "/" + w-arquivos.dsarquiv.
            
            EMPTY TEMP-TABLE crawaux.
    
            ASSIGN  aux_flgfirst = FALSE.

            INPUT STREAM str_3
                 THROUGH VALUE( "ls " + par_nmarqint + " 2> /dev/null") NO-ECHO.

            ASSIGN aux_contador = 0.

            DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:
    
                ASSIGN aux_contador = aux_contador + 1
                       aux_nmfisico = "integra/cobran" +
                                      STRING(par_dtmvtolt,"999999") +
                                      "_" + STRING(aux_contador,"9999").
    
                SET STREAM str_3 aux_nmarquiv FORMAT "x(60)" .
        
                UNIX SILENT VALUE("dos2ux " + aux_nmarquiv + " > " + aux_nmfisico +
                                  " 2> /dev/null").
                
                UNIX SILENT VALUE("quoter " + aux_nmfisico + " > " + aux_nmfisico +
                                  ".q" + " 2> /dev/null").
                
                INPUT STREAM str_2 FROM VALUE(aux_nmfisico + ".q") NO-ECHO.
                
                SET STREAM str_2 aux_setlinha WITH FRAME AA WIDTH 243.
                
                CREATE crawaux.
                ASSIGN crawaux.nrsequen = INT(SUBSTR(aux_setlinha,158,06)) NO-ERROR.
                ASSIGN crawaux.nmarquiv = aux_nmfisico + ".q".
                       aux_flgfirst     = TRUE.
    
                INPUT STREAM str_2 CLOSE.
            
            END.  /*  Fim do DO WHILE TRUE  */
            
            INPUT STREAM str_3 CLOSE.

            IF  NOT aux_flgfirst THEN
                DO:
                    ASSIGN aux_cdcritic = 887
                           aux_nmarqimp = "".
                    LEAVE Imprime.
                END.

            IF  FIRST-OF(w-arquivos.flginteg) THEN
                OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 84.

            PAGE STREAM str_1.
            { sistema/generico/includes/b1cabrel080.i "11" "390" }

            DISPLAY STREAM str_1 par_nmarqint WITH FRAME f_nomearquivo.
    
            ASSIGN aux_qtbloque = 0.
    
            FOR EACH crawaux BY crawaux.nrsequen
                             BY crawaux.nmarquiv:
    
                ASSIGN aux_cdcritic = 0
                       aux_flgfirst = FALSE.

                INPUT STREAM str_3 FROM VALUE(crawaux.nmarquiv) NO-ECHO.
                
                SET STREAM str_3 aux_setlinha WITH FRAME AA WIDTH 243.
        
                IF  SUBSTR(aux_setlinha,08,01) <> "0" THEN
                    ASSIGN aux_cdcritic = 468.
                
                FIND crapcco WHERE
                     crapcco.cdcooper  = par_cdcooper                     AND
                     crapcco.cddbanco  = 1                                AND
                     crapcco.cdagenci  = 1                                AND
                     crapcco.nrdctabb  = INT(SUBSTR(aux_setlinha,59,13))  AND
                     crapcco.nrconven  = INT(SUBSTR(aux_setlinha,33,20))
                     NO-LOCK NO-ERROR.
    
                IF  NOT AVAIL crapcco THEN DO:
                    ASSIGN aux_cdcritic = 563.
                END.
                ELSE DO:
                    ASSIGN aux_cdbancbb = crapcco.cddbanco
                           aux_cdagenci = crapcco.cdagenci
                           aux_cdbccxlt = crapcco.cdbccxlt
                           aux_nrdolote = crapcco.nrdolote
                           aux_cdhistor = crapcco.cdhistor
                           aux_nrdctabb = crapcco.nrdctabb
                           aux_nrcnvcob = crapcco.nrconven
                           aux_flgutceb = crapcco.flgutceb.
                END.

                IF  aux_cdcritic <> 0 THEN
                    DO: 
                        /* apaga arquivo */
                        UNIX SILENT VALUE("rm " + SUBSTRING(crawaux.nmarquiv,1,
                                                  LENGTH(crawaux.nmarquiv) - 2) +
                                          " 2> /dev/null").

                        /* apaga o arquivo QUOTER */
                        UNIX SILENT VALUE("rm -f " + crawaux.nmarquiv +
                                          " 2> /dev/null").

                        IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
                            RUN sistema/generico/procedures/b1wgen0060.p 
                                PERSISTENT SET h-b1wgen0060.
    
                        ASSIGN aux_dscritic = DYNAMIC-FUNCTION("BuscaCritica" IN
                                              h-b1wgen0060, INPUT aux_cdcritic).

                        LEAVE Imprime.
                    END.
        
                ASSIGN aux_contador = 0.
                
                /* Detalhe */
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    SET STREAM str_3 aux_setlinha WITH FRAME AA WIDTH 243.

                    IF  SUBSTR(aux_setlinha,08,01) = "3" THEN
                        DO:
                            IF  SUBSTR(aux_setlinha,14,01) = "P" THEN
                                DO:
                                    IF  aux_flgfirst THEN
                                        RUN p_grava_boleto
                                            ( INPUT par_cdcooper,
                                              INPUT par_dtmvtolt,
                                              INPUT-OUTPUT TABLE crawrej).
                                    ELSE
                                        ASSIGN aux_flgfirst = TRUE.
                                    
                                    ASSIGN aux_dsnosnum = TRIM(SUBSTR(aux_setlinha,38,20))
                                           aux_dsnosnum = LEFT-TRIM(aux_dsnosnum,"0")
                                           aux_cdcartei = INT(SUBSTR(aux_setlinha,58,01))
                                           aux_cddespec = INT(SUBSTR(aux_setlinha,107,2))
                                           aux_vltitulo = DEC(SUBSTR(aux_setlinha,86,15))
                                                           / 100
                                           aux_vldescto = DEC(SUBSTR(aux_setlinha,151,15))
                                                           / 100
                                           aux_dsdoccop = SUBSTR(aux_setlinha,63,15).
                                    
                                    DO WHILE LENGTH(aux_dsnosnum) < 17:
                                        ASSIGN aux_dsnosnum = "0" + aux_dsnosnum.
                                    END.
        
                                    IF  NOT aux_flgutceb THEN
                                         ASSIGN aux_nrdconta =
                                                     INT(SUBSTR(aux_dsnosnum,01,08))
                                                aux_nrbloque =
                                                     DEC(SUBSTR(aux_dsnosnum,09,09)).
                                    ELSE
                                         ASSIGN aux_nrdconta =
                                                     INT(SUBSTR(aux_dsnosnum,08,04))
                                                aux_nrbloque =
                                                     DEC(SUBSTR(aux_dsnosnum,12,06)).

                                    /*Se existe a data de emissao*/      
                                    IF INT(SUBSTRING(aux_setlinha,112,2)) <> 0 THEN
                                        DO:
                                            /*Atribui o valor da data de emissao na variavel*/  
                                            aux_dtemscob = DATE(INT(SUBSTRING(aux_setlinha,112,2)),
                                                                INT(SUBSTRING(aux_setlinha,110,2)),
                                                                INT(SUBSTRING(aux_setlinha,114,4))).
                                            
                                            /*Se a data de documento for superior ao limite 13/10/2049*/
                                            IF aux_dtemscob > DATE("13/10/2049") THEN
                                                DO:
                                                           
                                                    CREATE crawrej.
                                                    ASSIGN crawrej.cdcooper =
                                                                   par_cdcooper
                                                           crawrej.nrdconta =
                                                                   aux_nrdconta
                                                           crawrej.nrdocmto =
                                                                   aux_nrbloque
                                                           crawrej.dscritic = "Data de documento superior " +
                                                                              "ao limite 13/10/2049."
                                                           aux_flgfirst = FALSE.        
                                                    NEXT.
                                                END.
                                            
                                            /*Caso a data retroativa seja maior que 90 dias*/    
                                            IF (TODAY - 90) > aux_dtemscob THEN
                                                DO: 

                                                    CREATE crawrej.
                                                    ASSIGN crawrej.cdcooper =
                                                                   par_cdcooper
                                                           crawrej.nrdconta =
                                                                   aux_nrdconta
                                                           crawrej.nrdocmto =
                                                                   aux_nrbloque
                                                           crawrej.dscritic = "Data retroativa maior que 90 dias."
                                                           aux_flgfirst = FALSE.
                                                   
                                                    NEXT.
                                                END.
                                        END.
                                    ELSE aux_dtemscob = ?.
                                    
                                    /*Se existe a data de vencimento*/
                                    IF INT(SUBSTRING(aux_setlinha,078,2)) <> 0 THEN
                                        DO:
                                            /*Atribui o valor da data de vencimento na variavel*/  
                                            aux_dtvencto = DATE(INT(SUBSTRING(aux_setlinha,080,2)),
                                                                INT(SUBSTRING(aux_setlinha,078,2)),
                                                                INT(SUBSTRING(aux_setlinha,082,4))).
                                            
                                            /*Se existe a data de emissao para pode validar */
                                            IF aux_dtemscob <> ? THEN
                                                DO:
                                                    IF  aux_dtvencto < aux_dtemscob  OR
                                                        aux_dtvencto < TODAY  THEN
                                                        DO:
                                                                   
                                                            CREATE crawrej.
                                                            ASSIGN crawrej.cdcooper =
                                                                           par_cdcooper
                                                                   crawrej.nrdconta =
                                                                           aux_nrdconta
                                                                   crawrej.nrdocmto =
                                                                           aux_nrbloque
                                                                   crawrej.dscritic = "Data de vencimento invalida."
                                                                   aux_flgfirst = FALSE.
                                                            NEXT.
                                                        END.
                                                END.
                                        END.
                                    ELSE aux_dtvencto = ?.

                                END. /* Tipo de  Registro  P */
                            ELSE
                            IF  SUBSTR(aux_setlinha,14,01) = "Q" THEN
                                DO:
                                    ASSIGN aux_cdcritic = 0.
        
                                    /*  Possui convenio CECRED */
                                    IF  aux_flgutceb THEN
                                        DO:
                                            FIND crapceb WHERE
                                                 crapceb.cdcooper = par_cdcooper AND
                                                 crapceb.nrconven = aux_nrcnvcob AND
                                                 crapceb.nrcnvceb = aux_nrdconta 
                                                 USE-INDEX crapceb3 NO-LOCK NO-ERROR.
                                        END.
                                    ELSE
                                        DO:
                                            FIND crapceb WHERE
                                                 crapceb.cdcooper = par_cdcooper AND
                                                 crapceb.nrdconta = aux_nrdconta AND
                                                 crapceb.nrconven = aux_nrcnvcob
                                                 NO-LOCK NO-ERROR.
                                        END.
        
                                    IF  NOT AVAIL crapceb     OR 
                                        crapceb.insitceb <> 1 THEN
                                        DO:
                                            IF  NOT AVAIL crapceb THEN
                                                ASSIGN aux_cdcritic = 563.
                                                
                                            ELSE
                                                ASSIGN aux_cdcritic = 933.
    
                                            IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
                                                RUN sistema/generico/procedures/b1wgen0060.p 
                                                    PERSISTENT SET h-b1wgen0060.
                                                
                                            ASSIGN aux_dscritic = 
                                                 DYNAMIC-FUNCTION("BuscaCritica" IN
                                                 h-b1wgen0060, INPUT aux_cdcritic).
        
                                            /* cria rejeitado */
                                            CREATE crawrej.
                                            ASSIGN crawrej.cdcooper =
                                                           par_cdcooper
                                                   crawrej.nrdconta =
                                                           aux_nrdconta
                                                   crawrej.nrdocmto =
                                                           aux_nrbloque
                                                   crawrej.dscritic =
                                                           aux_dscritic
                                                             + " -  CNV : " +
                                              STRING(aux_nrdconta,"zzzz,zzz,9").
        
                                            NEXT.
                                        END.
                                    ELSE
                                        ASSIGN aux_nrdconta = crapceb.nrdconta.

                                    FIND crapass WHERE
                                         crapass.cdcooper = par_cdcooper AND
                                         crapass.nrdconta = aux_nrdconta
                                         USE-INDEX crapass1 NO-LOCK NO-ERROR.
        
                                    IF  NOT AVAIL crapass THEN
                                        DO:
                                            ASSIGN aux_cdcritic = 9.
    
                                            IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
                                                RUN sistema/generico/procedures/b1wgen0060.p 
                                                    PERSISTENT SET h-b1wgen0060.
                                                
                                            ASSIGN aux_dscritic = 
                                                 DYNAMIC-FUNCTION("BuscaCritica" IN
                                                 h-b1wgen0060, INPUT aux_cdcritic).
        
                                            /* cria rejeitado */
                                            CREATE crawrej.
                                            ASSIGN crawrej.cdcooper = par_cdcooper
                                                   crawrej.nrdconta = aux_nrdconta
                                                   crawrej.nrdocmto = aux_nrbloque
                                                   crawrej.dscritic = aux_dscritic
                                                                   + " -  C/C : " +
                                                  STRING(aux_nrdconta,"zzzz,zzz,9").
                                            NEXT.
                                        END.
                                    ELSE
                                        ASSIGN aux_nmprimtl = crapass.nmprimtl.
        
                                    ASSIGN aux_cdtpinsc = INT(SUBSTR(aux_setlinha,18,01))
                                           aux_nrinssac = DEC(SUBSTR(aux_setlinha,19,15))
                                           aux_nmdsacad = SUBSTR(aux_setlinha,34,40)
                                           aux_dsendsac = SUBSTR(aux_setlinha,74,40)
                                           aux_nmbaisac = SUBSTR(aux_setlinha,114,15)
                                           aux_nrcepsac = INT(SUBSTR(aux_setlinha,129,8))
                                           aux_nmcidsac = SUBSTR(aux_setlinha,137,15)
                                           aux_cdufsaca = SUBSTR(aux_setlinha,152,02)
                                           aux_nmdavali = SUBSTR(aux_setlinha,170,40)
                                           aux_nrinsava = DEC(SUBSTR(aux_setlinha,155,15))
                                           aux_cdtpinav = INT(SUBSTR(aux_setlinha,154,1)).

                                    RUN p_grava_sacado
                                        ( INPUT par_cdcooper,
                                          INPUT par_cdoperad,
                                          INPUT par_dtmvtolt,
                                          INPUT-OUTPUT TABLE crawrej).

                                END.  /*  Tipo de  Registro  Q   */
                            ELSE
                            IF  SUBSTR(aux_setlinha,14,01) = "S"   AND
                                INT(SUBSTR(aux_setlinha,18,1)) = 3 THEN
                                DO:
                                    /*   Concatena instrucoes separadas por _   */
                                    ASSIGN aux_dsdinstr = SUBSTR(aux_setlinha,19,40) +
                                                          "_" +
                                                          SUBSTR(aux_setlinha,59,40) +
                                                          "_" +
                                                          SUBSTR(aux_setlinha,99,40) +
                                                          "_" +
                                                          SUBSTR(aux_setlinha,139,40) +
                                                          "_" +
                                                          SUBSTR(aux_setlinha,179,40).
                                END.  /*  Tipo de  Registro  S   */
        
                        END.  /*   Tipo de Registro 3  */
        
                END.  /*    Fim do While True   */

                IF  aux_flgfirst  AND  aux_cdcritic = 0 THEN
                    RUN p_grava_boleto
                        ( INPUT par_cdcooper,
                          INPUT par_dtmvtolt,
                          INPUT-OUTPUT TABLE crawrej).

                INPUT STREAM str_3 CLOSE.
        
                /* move o arquivo UNIX para o "salvar" */
                UNIX SILENT VALUE("mv -f " + SUBSTRING(crawaux.nmarquiv,1,
                                             LENGTH(crawaux.nmarquiv) - 2) + " salvar").
        
                /* apaga o arquivo QUOTER */
                UNIX SILENT VALUE("rm -f " + crawaux.nmarquiv + " 2> /dev/null").
        
            END.  /*   Fim do for each   */
    
            DISPLAY STREAM str_1 aux_qtbloque LABEL "QTD BOLETOS INTEGRADOS"
                            WITH SIDE-LABELS FRAME f_total.

            IF  LAST-OF(w-arquivos.flginteg) THEN
                OUTPUT STREAM str_1 CLOSE.
                
        END. /* Fim FOR EACH w-arquivos */

        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
                    RUN sistema/generico/procedures/b1wgen0024.p
                        PERSISTENT SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024."
                               aux_nmarqimp = "".
                        LEAVE Imprime.
                    END.

                RUN envia-arquivo-web IN h-b1wgen0024 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT aux_nmarqimp,
                     OUTPUT aux_nmarqpdf,
                     OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Imprime.
            END.

        LEAVE Imprime.

    END. /*Imprime*/

    IF  VALID-HANDLE(h-b1wgen0060) THEN
        DELETE PROCEDURE h-b1wgen0060.

    IF  aux_dscritic <> "" OR aux_cdcritic <> 0 OR
        TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE 
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".

    RETURN aux_returnvl.

END PROCEDURE. /* integra_arquivo */

PROCEDURE relatorio_rejeitado:

    DEF  INPUT PARAM par_cdcooper AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_cdagenci AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nrdcaixa AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_idorigem AS INTE                           NO-UNDO.
    DEF  INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_cdprogra AS CHAR                           NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF  INPUT PARAM par_dsiduser AS CHAR                           NO-UNDO.

    DEF  INPUT PARAM TABLE FOR crawrej.

    DEF  OUTPUT PARAM aux_nmarqimp AS CHAR                          NO-UNDO.
    DEF  OUTPUT PARAM aux_nmarqpdf AS CHAR                          NO-UNDO.

    DEF  OUTPUT PARAM TABLE FOR tt-erro.

    DEF BUFFER crabcop FOR crapcop.

    FORM crawrej.nrdconta        FORMAT "zzzz,zzz,9"          LABEL "Conta/DV"
        aux_nmprimtl     AT 12  FORMAT "x(40)"               LABEL "Nome" /*001*/
        crawrej.nrdocmto AT 53  FORMAT "99999999,999999999"  LABEL "Documento"
        crawrej.dscritic AT 72  FORMAT "x(61)"               LABEL "Descricao"
        WITH NO-BOX DOWN NO-LABEL WIDTH 132 FRAME f_rejeitados.

    Imprime: DO ON ERROR UNDO Imprime, LEAVE Imprime:
        EMPTY TEMP-TABLE tt-erro.

        FOR FIRST crabcop WHERE crabcop.cdcooper = par_cdcooper NO-LOCK: END.

        IF  NOT AVAILABLE crabcop  THEN
            DO: 
                ASSIGN aux_cdcritic = 651
                       aux_dscritic = "".
                LEAVE Imprime.
            END.
        
        ASSIGN aux_nmendter = "/usr/coop/" + crabcop.dsdircop + "/rl/rej" +
                              par_dsiduser.

/*         ASSIGN aux_nmendter = "sistema/equipe/db1/rel/cobran_boR_" + par_dsiduser. */

        UNIX SILENT VALUE("rm " + aux_nmendter + "* 2>/dev/null").
        
        ASSIGN aux_nmendter = aux_nmendter + STRING(TIME)
               aux_nmarqimp = aux_nmendter + ".ex"
               aux_nmarqpdf = aux_nmendter + ".pdf".

        OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGE-SIZE 84.

        /* Cdempres = 11 , Relatorio 415 em 132 colunas */
        { sistema/generico/includes/cabrel.i "11" "415" "132" }

        ASSIGN aux_qtbloque = 0.

        FOR EACH crawrej WHERE crawrej.cdcooper = par_cdcooper 
                               BY crawrej.nrdconta:

            ASSIGN aux_qtbloque = aux_qtbloque + 1.

            FIND crapass WHERE crapass.cdcooper = par_cdcooper AND
                               crapass.nrdconta = crawrej.nrdconta 
                               USE-INDEX crapass1 NO-LOCK NO-ERROR.

            IF  AVAIL crapass THEN
                ASSIGN aux_nmprimtl = crapass.nmprimtl.
            ELSE
                ASSIGN aux_nmprimtl = "".

            DISPLAY STREAM str_1 crawrej.nrdconta aux_nmprimtl
                                 crawrej.nrdocmto crawrej.dscritic
                                 WITH FRAME f_rejeitados.

            DOWN STREAM str_1 WITH FRAME f_rejeitados.
        END.

        DISPLAY STREAM str_1 aux_qtbloque LABEL "QTD BOLETOS REJEITADOS"
           WITH SIDE-LABELS FRAME f_total.

        OUTPUT STREAM str_1 CLOSE.

        IF  par_idorigem = 5  THEN  /** Ayllos Web **/
            DO:
                IF  NOT VALID-HANDLE(h-b1wgen0024) THEN
                    RUN sistema/generico/procedures/b1wgen0024.p
                        PERSISTENT SET h-b1wgen0024.

                IF  NOT VALID-HANDLE(h-b1wgen0024)  THEN
                    DO:
                        ASSIGN aux_dscritic = "Handle invalido para BO " +
                                              "b1wgen0024."
                               aux_nmarqimp = "".
                        LEAVE Imprime.
                    END.

                RUN envia-arquivo-web IN h-b1wgen0024 
                    ( INPUT par_cdcooper,
                      INPUT par_cdagenci,
                      INPUT par_nrdcaixa,
                      INPUT aux_nmarqimp,
                     OUTPUT aux_nmarqpdf,
                     OUTPUT TABLE tt-erro ).

                IF  VALID-HANDLE(h-b1wgen0024)  THEN
                    DELETE PROCEDURE h-b1wgen0024.

                IF  RETURN-VALUE <> "OK" THEN
                    LEAVE Imprime.
            END.

        ASSIGN aux_returnvl = "OK".

        LEAVE Imprime.

    END. /*Imprime*/

    IF  aux_dscritic <> "" OR
        aux_cdcritic <> 0 OR
        TEMP-TABLE tt-erro:HAS-RECORDS
        THEN
        DO:
            ASSIGN aux_returnvl = "NOK".

            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAIL tt-erro THEN
                ASSIGN aux_dscritic = tt-erro.dscritic.
            ELSE 
                RUN gera_erro (INPUT par_cdcooper,
                               INPUT par_cdagenci,
                               INPUT par_nrdcaixa,
                               INPUT 1,
                               INPUT aux_cdcritic,
                               INPUT-OUTPUT aux_dscritic).
        END.
    ELSE
        ASSIGN aux_returnvl = "OK".
    
    RETURN aux_returnvl.

END PROCEDURE. /* relatorio_rejeitado */

PROCEDURE carrega_arquivos:

    DEF  INPUT PARAM par_nmarqint AS CHAR                   NO-UNDO.
    
    DEF OUTPUT PARAM TABLE FOR w-arquivos.
    
    DEF VAR aux_nmarquiv AS CHAR    NO-UNDO.
    DEF VAR aux_tparquiv AS CHAR    NO-UNDO.

    EMPTY TEMP-TABLE tt-arquivos.
    EMPTY TEMP-TABLE w-arquivos.

    /*** Procura arquivos ***/
    ASSIGN aux_nmarquiv = par_nmarqint + "/*"
           aux_tparquiv = "*". 
    
    RUN verifica_arquivos
        ( INPUT aux_nmarquiv,
          INPUT aux_tparquiv,
         OUTPUT TABLE tt-arquivos).

    ASSIGN aux_tparquiv = "".

    FOR EACH tt-arquivos NO-LOCK BREAK BY tt-arquivos.tparquiv:
        CREATE w-arquivos.
        ASSIGN w-arquivos.tparquiv = tt-arquivos.tparquiv
               w-arquivos.dsarquiv = tt-arquivos.dsarquiv
               w-arquivos.flginteg = NO.
    END.

    EMPTY TEMP-TABLE tt-arquivos.

    RETURN.

END PROCEDURE. /* carrega_arquivos */

/*........................... PROCEDURES INTERNAS ..........................*/

PROCEDURE p_grava_sacado.

    DEF  INPUT PARAM par_cdcooper AS INTE                   NO-UNDO.
    DEF  INPUT PARAM par_cdoperad AS CHAR                   NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                   NO-UNDO.

    DEF  INPUT-OUTPUT PARAM TABLE FOR crawrej.

    IF  aux_nrinssac = 0 THEN
        RETURN.

    /*  Pagador possui registro */
    FIND crapsab WHERE crapsab.cdcooper = par_cdcooper AND
                       crapsab.nrdconta = aux_nrdconta AND
                       crapsab.nrinssac = aux_nrinssac NO-LOCK NO-ERROR.

    IF  NOT AVAIL crapsab THEN
        DO:
            EMPTY TEMP-TABLE cratsab.

            CREATE cratsab.
            ASSIGN cratsab.cdcooper = par_cdcooper
                   cratsab.nrdconta = aux_nrdconta
                   cratsab.nmdsacad = aux_nmdsacad
                   cratsab.cdtpinsc = aux_cdtpinsc
                   cratsab.nrinssac = aux_nrinssac
                   cratsab.dsendsac = aux_dsendsac
                   cratsab.nrendsac = 0
                   cratsab.nmbaisac = aux_nmbaisac
                   cratsab.nmcidsac = aux_nmcidsac
                   cratsab.cdufsaca = aux_cdufsaca
                   cratsab.nrcepsac = aux_nrcepsac
                   cratsab.cdoperad = par_cdoperad
                   cratsab.dtmvtolt = par_dtmvtolt.

            IF  NOT VALID-HANDLE(h-b1crapsab) THEN
                RUN sistema/generico/procedures/b1crapsab.p
                    PERSISTENT SET h-b1crapsab.

            IF  VALID-HANDLE(h-b1crapsab) THEN
                DO:
                    ASSIGN aux_dscritic = "".

                    RUN cadastra_sacado IN h-b1crapsab (INPUT TABLE cratsab,
                                                        OUTPUT aux_dscritic).

                    DELETE PROCEDURE h-b1crapsab.
                END.

            IF  aux_dscritic <> "" THEN
                DO:
                    /* cria rejeitado */
                    CREATE crawrej.
                    ASSIGN crawrej.cdcooper = par_cdcooper
                           crawrej.nrdconta = aux_nrdconta
                           crawrej.nrdocmto = aux_nrbloque
                           crawrej.dscritic = aux_dscritic + " -  C/C : " +
                                             STRING(aux_nrdconta,"zzzz,zzz,9").
                    RETURN.
                END.
        END.

    ASSIGN aux_nmdsacad = ""
           aux_dsendsac = ""
           aux_nmbaisac = ""
           aux_nmcidsac = ""
           aux_cdufsaca = ""
           aux_nrcepsac = 0.

    RETURN.
           
END PROCEDURE.

PROCEDURE p_grava_boleto:

    DEF  INPUT PARAM par_cdcooper AS INTE                   NO-UNDO.
    DEF  INPUT PARAM par_dtmvtolt AS DATE                   NO-UNDO.

    DEF  INPUT-OUTPUT PARAM TABLE FOR crawrej.

    DO TRANSACTION:

        EMPTY TEMP-TABLE cratcob.

        CREATE cratcob.
        ASSIGN cratcob.cdcooper = par_cdcooper
               cratcob.dtmvtolt = par_dtmvtolt
               cratcob.incobran = 0
               cratcob.nrdconta = aux_nrdconta
               cratcob.nrdctabb = aux_nrdctabb
               cratcob.cdbandoc = 1
               cratcob.nrdocmto = aux_nrbloque
               cratcob.nrcnvcob = aux_nrcnvcob
               cratcob.dtretcob = aux_dtemscob
               cratcob.dsdoccop = aux_dsdoccop
               cratcob.vltitulo = aux_vltitulo
               cratcob.vldescto = aux_vldescto
               cratcob.dtvencto = aux_dtvencto
               cratcob.cdcartei = aux_cdcartei
               cratcob.cddespec = aux_cddespec
               cratcob.cdtpinsc = aux_cdtpinsc
               cratcob.nrinssac = aux_nrinssac
               cratcob.nmdsacad = aux_nmdsacad
               cratcob.dsendsac = aux_dsendsac
               cratcob.nmbaisac = aux_nmbaisac
               cratcob.nmcidsac = aux_nmcidsac
               cratcob.cdufsaca = aux_cdufsaca
               cratcob.nrcepsac = aux_nrcepsac
               cratcob.nmdavali = aux_nmdavali
               cratcob.nrinsava = aux_nrinsava
               cratcob.cdtpinav = aux_cdtpinav
               cratcob.dsdinstr = aux_dsdinstr
               cratcob.cdimpcob = 2
               cratcob.flgimpre = TRUE.

        IF  NOT VALID-HANDLE(h-b1crapcob) THEN
            RUN sistema/generico/procedures/b1crapcob.p
                PERSISTENT SET h-b1crapcob.

        IF  VALID-HANDLE(h-b1crapcob)   THEN
            DO:
                RUN inclui-registro IN h-b1crapcob (INPUT TABLE cratcob, 
                                                    OUTPUT aux_dscritic).
                DELETE PROCEDURE h-b1crapcob.
            END.

        IF  aux_dscritic <> "" THEN
            DO:
                ASSIGN aux_cdcritic = 588.

                IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
                    RUN sistema/generico/procedures/b1wgen0060.p 
                        PERSISTENT SET h-b1wgen0060.
                    
                ASSIGN aux_dscritic = 
                     DYNAMIC-FUNCTION("BuscaCritica" IN
                     h-b1wgen0060, INPUT aux_cdcritic).

                IF  VALID-HANDLE(h-b1wgen0060) THEN
                    DELETE PROCEDURE h-b1wgen0060.

                /* cria rejeitado */
                CREATE crawrej.
                ASSIGN crawrej.cdcooper = par_cdcooper
                       crawrej.nrdconta = aux_nrdconta
                       crawrej.nrdocmto = aux_nrbloque
                       crawrej.dscritic = aux_dscritic + " -  Boleto : " +
                                          STRING(cratcob.nrdocmto,
                                                 "99999999999999999").
                NEXT.
            END.  
        ELSE       
            ASSIGN aux_qtbloque = aux_qtbloque + 1.

    END. /* Fim do DO TRANSACTON */

    /*   Imprime Relacao Integrados   */ 
    IF  LINE-COUNTER(str_1) > 80  THEN
        DO:
            PAGE STREAM str_1.
            VIEW STREAM str_1 FRAME f_cab.
        END.

    DISPLAY STREAM str_1 aux_nrdconta aux_nmprimtl
                         aux_nrbloque WITH FRAME f_rel.

    DOWN STREAM str_1 WITH FRAME f_rel.

    ASSIGN aux_dsdinstr = "".
           
END PROCEDURE.

PROCEDURE verifica_arquivos:

    DEF  INPUT PARAM aux_nmarquiv AS CHAR                    NO-UNDO.
    DEF  INPUT PARAM aux_tparquiv AS CHAR                    NO-UNDO.

    DEF OUTPUT PARAM TABLE FOR tt-arquivos.
    
    DEF VAR aux_dsdirarq AS CHAR                            NO-UNDO.
    DEF VAR aux_tamarqui AS CHAR                            NO-UNDO.

    ASSIGN aux_dsdirarq = SUBSTR(aux_nmarquiv,1,LENGTH(aux_nmarquiv) - 1).
    /* RAIZ do Diretorio */

    INPUT STREAM str_1 THROUGH VALUE("ls " + aux_nmarquiv + " 2> /dev/null") NO-ECHO.

    DO WHILE TRUE ON ERROR UNDO, LEAVE ON ENDKEY UNDO, LEAVE:

        SET STREAM str_1 aux_nmarquiv FORMAT "x(60)".
       
        /*** Verifica se o arquivo esta vazio e o remove ***/
        INPUT STREAM str_2 THROUGH VALUE("wc -m " + aux_nmarquiv + 
                                         " 2> /dev/null") NO-ECHO.
                                                  
        SET STREAM str_2 aux_tamarqui FORMAT "x(30)".

        IF  INTEGER(SUBSTRING(aux_tamarqui,1,1)) = 0  THEN
            DO:
                INPUT STREAM str_2 CLOSE.
                NEXT.
            END.

        INPUT STREAM str_2 CLOSE.

        DO TRANSACTION:         
           CREATE tt-arquivos.
           ASSIGN tt-arquivos.tparquiv = aux_tparquiv
                  tt-arquivos.dsarquiv = REPLACE(aux_nmarquiv,aux_dsdirarq,"").
        END.

    END.  /*  Fim do DO WHILE TRUE  */

    INPUT STREAM str_1 CLOSE.
    
END PROCEDURE.
/*.............................. FIM PROCEDURES .............................*/


