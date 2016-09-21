/*---------------------------------------------------------------------------*/
/*  pcrap11.p - Rotina p/imprimir o termo de entrega do cartao magnetico     */ 
/*  Objetivo  : Rotina p/imprimir o termo de entrega do cartao magnetico     */
/*              (Antigo fontes/carmag_m.p)                                   */
/*                                                                           */
/*  Alteracoes: 02/03/2006 - Unificacao dos Bancos - SQLWorks - Fernando     */
/*                                                                           */
/*              20/10/2010 - Incluido caminho completo nas referencias do    */
/*                           diretorio spool (Elton).                        */
/*              23/05/2011 - Alterada a leitura da tabela craptab para a     */
/*                           tabela crapope (Isara - RKAM).                  */
/*              30/09/2011 - Alterar diretorio spool para                   */
/*                           /usr/coop/sistema/siscaixa/web/spool (Fernando).*/
/*              24/07/2011 - Alterado para nao mostrar no relatorio o limite */
/*                           e a forma de saque. (James)                     */
/*---------------------------------------------------------------------------*/

DEF STREAM str_1. 

DEF INPUT  PARAM p-cooper       AS CHAR                                NO-UNDO.
DEF INPUT  PARAM p-registro     AS RECID                               NO-UNDO.
DEF INPUT  PARAM p-cod-operador AS CHAR                                NO-UNDO.
DEF INPUT  PARAM p-cod-agencia  AS INTE                                NO-UNDO.
DEF INPUT  PARAM p-nro-caixa    AS INTE                                NO-UNDO.

DEF          VAR aux_nmdafila   AS CHAR                                NO-UNDO.
DEF          VAR i-nro-vias     AS INTE                                NO-UNDO.
DEF          VAR aux_dscomand   AS CHAR                                NO-UNDO.

DEF          VAR aux_nmmesano   AS CHAR EXTENT 12 
                                        INIT ["JANEIRO","FEVEREIRO",
                                              "MARCO","ABRIL","MAIO",
                                              "JUNHO","JULHO","AGOSTO",
                                              "SETEMBRO","OUTUBRO",
                                              "NOVEMBRO","DEZEMBRO"]   NO-UNDO.


DEF          VAR rel_dsrefere   AS CHAR                                NO-UNDO.
DEF          VAR rel_dsmvtolt   AS CHAR                                NO-UNDO.
DEF          VAR rel_dsoperad   AS CHAR                                NO-UNDO.
DEF          VAR rel_dsdnivel   AS CHAR                                NO-UNDO.
DEF          VAR rel_dsparuso   AS CHAR                                NO-UNDO.
DEF          VAR rel_nmoperad   AS CHAR                                NO-UNDO.
DEF          VAR rel_dsdponto   AS CHAR                                NO-UNDO.
DEF          VAR rel_dstitulo   AS CHAR                                NO-UNDO.
DEF          VAR rel_nmrescop   AS CHAR                                NO-UNDO.
DEF          VAR rel_nmextcop   AS CHAR FORMAT "x(50)"                 NO-UNDO.
DEF          VAR rel_nmextcp1   AS CHAR FORMAT "x(29)"                 NO-UNDO.
DEF          VAR rel_nmextcp2   AS CHAR FORMAT "X(21)"                 NO-UNDO.

DEF          VAR aux_nmendter   AS CHAR FORMAT "x(20)"                 NO-UNDO.
DEF          VAR aux_nmarqimp   AS CHAR                                NO-UNDO.

DEF          VAR par_flgfirst   AS LOGI INIT TRUE                      NO-UNDO.
DEF          VAR par_flgrodar   AS LOGI INIT TRUE                      NO-UNDO.
DEF          VAR par_flgcance   AS LOGI                                NO-UNDO.

DEF          VAR tel_dsimprim   AS CHAR FORMAT "x(8)" INIT "Imprimir"  NO-UNDO.
DEF          VAR tel_dscancel   AS CHAR FORMAT "x(8)" INIT "Cancelar"  NO-UNDO.

DEF          VAR aux_flgescra   AS LOGI                                NO-UNDO.

DEF          VAR aux_lsparuso   AS CHAR                                NO-UNDO.
DEF          VAR aux_lsdnivel   AS CHAR                                NO-UNDO.

FORM "Aguarde... Imprimindo a Declaracao de Recebimento!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM rel_dstitulo AT 23 FORMAT "x(45)"
     SKIP(2)
     WITH NO-BOX NO-LABELS WIDTH 80 FRAME f_titulo STREAM-IO.
     
FORM SKIP(1)
     "DECLARACAO DE RECEBIMENTO" AT 27 
     SKIP(4)
     WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 80 FRAME f_declara STREAM-IO.
      
FORM "EU," crapcrm.nmtitcrd FORMAT "x(39)" ", CONTA" 
     crapcrm.nrdconta FORMAT "zzzz,zzz,9" ", DECLARO TER" SKIP
     "RECEBIDO O CARTAO" 
     rel_nmrescop    FORMAT "x(11)"
     ", COM PROPOSITO DE PERMITIR SAQUES "
     "E CONSULTA" SKIP
     "DE SALDOS NOS TERMINAIS DE AUTO-ATENDIMENTO DA" 
     rel_nmextcp1 FORMAT "x(29)" 
     rel_nmextcp2 FORMAT "x(21)" "."
     SKIP(2)
     WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 80 FRAME f_declara_ass STREAM-IO.

FORM "EU," crapcrm.nmtitcrd FORMAT "x(29)" ", OPERADOR" 
     crapcrm.nrdconta FORMAT "zzzz9" ", DECLARO TER  RECEBIDO O" SKIP
     "CARTAO" rel_nmrescop    FORMAT "x(11)"
     ", O QUAL PERMITE ACESSO AO TERMINAL FINANCEIRO PARA  FINS"
     SKIP
     "FUNCIONAIS DE MANUTENCAO E OPERACAO."
     SKIP(2)
     WITH COLUMN 5 NO-BOX NO-LABELS WIDTH 80 FRAME f_declara_ope STREAM-IO.
      
FORM crapcrm.nrcartao FORMAT "9999,9999,9999,9999" LABEL "NUMERO DO CARTAO"
     SKIP(1)
     crapcrm.dtvalcar FORMAT "99/99/9999" LABEL "DATA DE VALIDADE" AT 1
     SKIP(1)
     crapcrm.dtemscar FORMAT "99/99/9999" LABEL "DATA DE EMISSAO" AT 2
     SKIP(2)
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 
     FRAME f_dados_ass STREAM-IO.

FORM crapcrm.nrcartao FORMAT "9999,9999,9999,9999" LABEL "NUMERO DO CARTAO"
     SKIP(1)
     rel_dsdnivel FORMAT "x(20)" LABEL "NIVEL" AT 12
     SKIP(1)
     rel_dsparuso FORMAT "x(20)" LABEL "PARA USO EM" AT 6
     SKIP(1)
     crapcrm.dtvalcar FORMAT "99/99/9999" LABEL "DATA DE VALIDADE" AT 1
     SKIP(1)
     crapcrm.dtemscar FORMAT "99/99/9999" LABEL "DATA DE EMISSAO" AT 2
     SKIP(2)
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 
     FRAME f_dados_ope STREAM-IO.

FORM rel_dsrefere FORMAT "x(35)" NO-LABEL AT 1
     SKIP(3)
     "TITULAR"  AT  1
     "OPERADOR" AT 42
     SKIP(5)
     "------------------------------------" AT  1
     "-----------------------------------"  AT 42
     SKIP
     crapcrm.nmtitcrd FORMAT "x(36)" NO-LABEL AT  1
     rel_nmoperad     FORMAT "x(35)" NO-LABEL AT 42
     SKIP
     rel_dsmvtolt FORMAT "x(30)" NO-LABEL AT 42
     SKIP(3)
 "--(Corte aqui)--------------------------------------------------------------"
     SKIP(3)
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 
     FRAME f_termo STREAM-IO.
     
FORM SKIP
     "DICAS DE UTILIZACAO" AT 30 
     SKIP(3)
     "1) GUARDE SEMPRE EM LUGAR SEGURO E LONGE DE FONTES ELETRO-MAGNETICAS "
     "(IMAS," SKIP
     "   TELEFONES, CAIXAS DE SOM, ETC);"
     SKIP(1)
     "2) NUNCA DIGA A SUA SENHA A NINGUEM"
     rel_dsdponto AT 36 FORMAT "x"
     SKIP(1)
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 
     FRAME f_dicas_1 STREAM-IO.

FORM "3) NAO PECA AJUDA A PESSOAS ESTRANHAS!" SKIP
     "   PROCURE SEMPRE UM POSTO DA" rel_nmrescop    FORMAT "x(11)" "."
     SKIP(2)
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 
     FRAME f_dicas_2 STREAM-IO.

FORM "DADOS DO CARTAO" AT 31
     SKIP(2)
     crapcrm.nrdconta FORMAT "zzzz,zzz,9" LABEL "CONTA" AT 12
     SKIP(1)
     crapcrm.nmtitcrd FORMAT "x(40)"      LABEL "TITULAR" AT 10
     SKIP(1)
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 
     FRAME f_cartao_ass STREAM-IO.

FORM SKIP(1)
     "DADOS DO CARTAO" AT 31
     SKIP(1)
     crapcrm.nrdconta FORMAT "zzzz9" LABEL "OPERADOR" AT  9
     SKIP(1)
     crapcrm.nmtitcrd FORMAT "x(40)" LABEL "TITULAR"  AT 10
     SKIP(1)
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 
     FRAME f_cartao_ope STREAM-IO.

FORM SKIP(2)
     rel_dsoperad AT 9 FORMAT "x(55)" LABEL "OPERADOR"
     WITH COLUMN 5 NO-BOX NO-LABELS SIDE-LABELS WIDTH 80 
     FRAME f_operador STREAM-IO.
     
FIND crapcop WHERE crapcop.nmrescop = p-cooper  NO-LOCK NO-ERROR.
     
FIND FIRST crapdat WHERE crapdat.cdcooper = crapcop.cdcooper NO-LOCK NO-ERROR.

ASSIGN aux_lsparuso = "TERMINAL,CAIXA,TERMINAL + CAIXA," +
                      "RETAGUARDA,CASH + RETAGUARDA"
       
       aux_lsdnivel = "OPERADOR,SUPERVISOR,GERENTE"
       
       rel_dstitulo = "** CARTAO " + CAPS(crapcop.nmrescop) +
                      " - AUTO ATENDIMENTO **"
                      
       rel_nmrescop = CAPS(crapcop.nmrescop)
       rel_nmextcop = crapcop.nmextcop
       rel_nmextcp1 = SUBSTRING(crapcop.nmextcop,1,29)
       rel_nmextcp2 = SUBSTRING(crapcop.nmextcop,30,50).

FIND crapcrm WHERE RECID(crapcrm)   = p-registro        NO-LOCK NO-ERROR.
FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper  AND
                   crapope.cdoperad = p-cod-operador    NO-LOCK NO-ERROR.

ASSIGN rel_dsmvtolt = STRING(crapdat.dtmvtolt,"99/99/9999") + " - " + 
                      STRING(TIME,"HH:MM:SS")
       rel_nmoperad = crapope.nmoperad
       rel_dsoperad = TRIM(crapope.nmoperad) + " - " + rel_dsmvtolt 
       rel_dsrefere = "BLUMENAU, " + STRING(DAY(crapdat.dtmvtolt),"99") + 
                      " DE " +
                      TRIM(aux_nmmesano[MONTH(crapdat.dtmvtolt)]) + " DE " +
                      STRING(YEAR(crapdat.dtmvtolt),"9999") + ".".

HIDE MESSAGE NO-PAUSE.

VIEW FRAME f_aguarde.

PAUSE 3 NO-MESSAGE.

HIDE FRAME f_aguarde NO-PAUSE.

/* Impressora */
ASSIGN aux_nmdafila =  LC(crapope.dsimpres). 

ASSIGN aux_nmarqimp = "/usr/coop/sistema/siscaixa/web/spool/" +  
                      crapcop.dsdircop      +
                      STRING(p-cod-agencia) + 
                      STRING(p-nro-caixa)   +
                      "p1011.txt".  /* Nome Fixo  */

OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
 
PUT STREAM str_1 CONTROL "\022\024\033\120\0330" NULL.
DISPLAY STREAM str_1 rel_dstitulo WITH FRAME f_titulo.

VIEW STREAM str_1 FRAME f_declara.     
     
IF  crapcrm.tptitcar = 9   THEN 
    DO:
        rel_dsdponto = ".".
         
        FIND crapope WHERE crapope.cdcooper = crapcop.cdcooper          AND    
                           crapope.cdoperad = STRING(crapcrm.nrdconta)
                           NO-LOCK NO-ERROR.
                            
        ASSIGN rel_dsparuso = ENTRY(crapope.tpoperad,aux_lsparuso)
               rel_dsdnivel = ENTRY(crapope.nvoperad,aux_lsdnivel).
     
        DISPLAY STREAM str_1
                crapcrm.nmtitcrd  crapcrm.nrdconta  rel_nmrescop
                WITH FRAME f_declara_ope.
      
        DISPLAY STREAM str_1
                crapcrm.nrcartao  rel_dsdnivel 
                rel_dsparuso  crapcrm.dtvalcar
                crapcrm.dtemscar 
                WITH FRAME f_dados_ope.

        DISPLAY STREAM str_1
                rel_dsrefere  crapcrm.nmtitcrd  rel_nmoperad  rel_dsmvtolt
                WITH FRAME f_termo.
      
        VIEW STREAM str_1 FRAME f_titulo.
         
        DISPLAY STREAM str_1 rel_dsdponto WITH FRAME f_dicas_1.
      
        DISPLAY STREAM str_1
                crapcrm.nrdconta  crapcrm.nmtitcrd
                WITH FRAME f_cartao_ope.

        DISPLAY STREAM str_1
                crapcrm.nrcartao  rel_dsdnivel 
                rel_dsparuso  crapcrm.dtvalcar
                crapcrm.dtemscar 
                WITH FRAME f_dados_ope.
    END.
ELSE
    IF  crapcrm.tptitcar = 1   THEN
        DO:
            rel_dsdponto = ";".
 
            /*FIND crapass OF crapcrm NO-LOCK NO-ERROR.*/
            FIND crapass WHERE crapass.cdcooper = crapcop.cdcooper  AND
                               crapass.nrdconta = crapcrm.nrdconta
                               NO-LOCK NO-ERROR.
         
            DISPLAY STREAM str_1
                    crapcrm.nmtitcrd  crapcrm.nrdconta  rel_nmrescop
                    rel_nmextcp1 rel_nmextcp2
                    WITH FRAME f_declara_ass.
      
            DISPLAY STREAM str_1
                    crapcrm.nrcartao  crapcrm.dtvalcar
                    crapcrm.dtemscar 
                    WITH FRAME f_dados_ass.

            DISPLAY STREAM str_1
                    rel_dsrefere  crapcrm.nmtitcrd  rel_nmoperad  rel_dsmvtolt
                    WITH FRAME f_termo.
     
            VIEW STREAM str_1 FRAME f_titulo.
         
            DISPLAY STREAM str_1 rel_dsdponto WITH FRAME f_dicas_1.
  
            DISPLAY STREAM str_1 rel_nmrescop WITH FRAME f_dicas_2.
  
            DISPLAY STREAM str_1
                    crapcrm.nrdconta  crapcrm.nmtitcrd
                    WITH FRAME f_cartao_ass.

            DISPLAY STREAM str_1
                    crapcrm.nrcartao  crapcrm.dtemscar 
                    WITH FRAME f_dados_ass.
        END.

DISPLAY STREAM str_1
        rel_dsoperad WITH FRAME f_operador.

OUTPUT STREAM str_1 CLOSE.
assign i-nro-vias = 1.
aux_dscomand = "lp -d" + aux_nmdafila +
               " -n" + STRING(i-nro-vias) +   
               " -oMTl88 " + aux_nmarqimp +     
               " > /dev/null".

UNIX SILENT VALUE(aux_dscomand).

/* pcrap11.p */

/* .......................................................................... */

