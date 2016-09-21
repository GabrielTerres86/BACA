/* .............................................................................
   Programa: Fontes/Impboletim.p
   Sistema : Conta-Corrente - Cooperativa 
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Fevereiro/2001                   Ultima atualizacao: 30/05/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Rotina para imprimir e ou visualizar o BOLETIM DE CAIXA.

   Alteracoes: 11/05/2001 - Colocar qtde total em outros historicos (Margarete)
   
               30/10/2002 - Imprimir estornos (Margarete)

               07/05/2003 - Tratar DOC/TED on_line (Margarete).
    
               10/09/2004 - Listar documentos transitados via gerenciador
                            financeiro - VIACREDI (Edson).
               
               15/09/2004 - Desprezar autenticacoes estornadas(doctos gerenc)
                            (Mirtes).

               24/09/2004 - Prever Historiocos COBAN/Conta Investimento(Mirtes)

               14/10/2004 - Prever Historico Pagto Emprestimo Caixa(Mirtes)
               
               26/11/2004 - Retirado Visto Tesouraria(Mirtes)

               20/12/2004 - Incluido descricao historicos dif.caixa
                            (701/702/733/734) (Mirtes)

               14/07/2005 - Prever Historiocos GPS(Mirtes)
               
               24/01/2006 - Unificacao dos Bancos - SQLWorks - Andre

               22/03/2006 - Separar titulos Cooperativa- Historico 751(Mirtes)

               06/09/2006 - Alterada a nomenclatura dos vistos de "CAIXA" e
                            "COORDENADOR" para "OPERADOR" e "RESPONSAVEL"
                            (David).

               14/12/2006 - Considerar tplotmov = 32 e historico 561 (Evandro).

               05/04/2007 - Considerar lancamento da LANCHQ (Magui).

               10/05/2007 - Impressao do Coban para Creditextil (Magui).
               
               28/08/2007 - Histor 561 na somava no total de creditos (Magui).

               04/03/2008 - Incluidos lancamentos do BANCOOB-INSS (Evandro).
               
               28/03/2008 - Controle para nao duplicar os lancamentos das guias
                            GPS-BANCOOB (Evandro).
               
               20/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find e for each" da tabela
                            CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
 
               12/08/2008 - Unificacao dos bancos, incluido cdcooper na busca da
                            tabela crabhis(Guilherme).
                            
               23/01/2009 - Alteracao cdempres (Diego).
               
               30/03/2009 - Acerto no FOR EACH craphis estava WHOLE (Guilherme).
               
               05/06/2009 - Incluir agencia na leitura do craplcs (Magui).
               
               14/07/2009 - Alteracao CDOPERAD (Diego).
               
               19/10/2009 - Alteracao Codigo Historico (Kbase).
               
               22/09/2011 - Tratamento para a rotina 66 - Antiga LANCHQ (ZE).
               
               01/02/2012 - Remover aux_dshistor pois esta sendo declarada
                            dentro da var_bcaixa.i (Guilherme).
                            
               05/06/2013 - Adicionados valores de multa e juros ao valor total
                            das faturas, para DARFs (Lucas)
                            
               13/08/2013 - Nova forma de chamar as agências, alterado para
                          "Posto de Atendimento" (PA). (André Santos - SUPERO)
                          
               30/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                                       
............................................................................. */

{ includes/var_online.i }
{ includes/var_bcaixa.i }

DEF BUFFER crabhis FOR craphis.
DEF STREAM str_1.

/* utilizados pelo includes impressao.i */

DEF VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir"        NO-UNDO.
DEF VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar"        NO-UNDO.

DEF VAR par_flgrodar AS LOGI                                         NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                         NO-UNDO.
DEF VAR par_flgcance AS LOGI                                         NO-UNDO.

DEF VAR aux_dsdtraco AS CHAR    INIT "________________"              NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                         NO-UNDO.

DEF VAR rel_nmresage AS CHAR                                         NO-UNDO.
DEF VAR rel_nmrelato AS CHAR    FORMAT "x(40)" EXTENT 5              NO-UNDO.
DEF VAR rel_nmresemp AS CHAR    FORMAT "x(15)"                       NO-UNDO.
DEF VAR rel_nrmodulo AS INT     FORMAT "9"                           NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR    FORMAT "x(15)" EXTENT 5
                        INIT ["DEP. A VISTA   ","CAPITAL        ",
                              "EMPRESTIMOS    ","DIGITACAO      ",
                              "GENERICO       "]                     NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                         NO-UNDO.
DEF VAR aux_contador AS INT                                          NO-UNDO.

DEF VAR aux_deshi717 AS CHAR    FORMAT "X(40)"                       NO-UNDO.
DEF VAR aux_lintrac1 AS CHAR    FORMAT "x(80)"                       NO-UNDO. 
DEF VAR aux_lintrac2 AS CHAR    FORMAT "x(48)"                       NO-UNDO.
DEF VAR aux_lintrac3 AS CHAR    FORMAT "x(80)"                       NO-UNDO.
DEF VAR aux_lintrac4 AS CHAR    FORMAT "x(65)"                       NO-UNDO.
DEF VAR aux_descrctb AS CHAR    FORMAT "x(31)"                       NO-UNDO. 
DEF VAR aux_vlrttctb AS DECI    FORMAT "zzz,zzz,zz9.99-"             NO-UNDO.
DEF VAR aux_vllanmto AS DECIMAL                                      NO-UNDO.
DEF VAR aux_deschist AS CHAR    FORMAT "x(47)"                       NO-UNDO.
DEF VAR aux_vlrtthis AS DECI    FORMAT "zzz,zzz,zz9.99"              NO-UNDO.

DEF VAR aux_vllanchq AS DECIMAL                                      NO-UNDO.
DEF VAR aux_qtlanchq AS INT                                          NO-UNDO.

DEF VAR aux_vlroti14 AS DECIMAL                                      NO-UNDO.
DEF VAR aux_qtroti14 AS INT                                          NO-UNDO.

DEF VAR rel_dsfechad AS CHAR                                         NO-UNDO.

DEF VAR rel_dtmvtolt LIKE crapbcx.dtmvtolt                           NO-UNDO.
DEF VAR rel_cdagenci LIKE crapbcx.cdagenci                           NO-UNDO.
DEF VAR rel_cdopecxa LIKE crapbcx.cdopecxa                           NO-UNDO. 
DEF VAR rel_nmoperad LIKE crapope.nmoperad                           NO-UNDO.
DEF VAR rel_nrdcaixa LIKE crapbcx.nrdcaixa                           NO-UNDO. 
DEF VAR rel_nrdmaqui like crapbcx.nrdmaqui                           NO-UNDO.
DEF VAR rel_nrdlacre like crapbcx.nrdlacre                           NO-UNDO.
DEF VAR rel_vldsdini LIKE crapbcx.vldsdini                           NO-UNDO.
DEF VAR rel_qtautent LIKE crapbcx.qtautent                           NO-UNDO.

DEF VAR tot_qtgerfin AS INT                                          NO-UNDO.
DEF VAR tot_vlgerfin AS DECIMAL                                      NO-UNDO.

DEF VAR aux_flgescra AS LOGICAL                                      NO-UNDO.
DEF VAR aux_flgouthi AS LOGICAL                                      NO-UNDO.
DEF VAR aux_opcimpri AS LOGICAL                                      NO-UNDO.

DEF VAR aux_qtrttctb AS INT                                          NO-UNDO.
DEF VAR aux_nrcoluna AS INT                                          NO-UNDO.

DEF TEMP-TABLE work_estorno                                          NO-UNDO
    FIELD cdagenci LIKE crapbcx.cdagenci
    FIELD nrdcaixa LIKE crapbcx.nrdcaixa
    FIELD nrseqaut LIKE crapaut.nrseqaut
    INDEX estorno AS UNIQUE PRIMARY
          cdagenci
          nrdcaixa
          nrseqaut.

DEF TEMP-TABLE w_empresa                                    NO-UNDO
    FIELD cdempres LIKE crapccs.cdempres
    FIELD qtlanmto AS INT
    FIELD vllanmto LIKE craplcs.vllanmto
    INDEX w_empresa1 cdempres.


FORM HEADER
     "REFERENCIA:" rel_dtmvtolt 
     SKIP(1)
     "PA:" rel_cdagenci FORMAT "ZZ9" "-" rel_nmresage FORMAT "x(18)" SPACE(1)
     "OPERADOR:" rel_cdopecxa FORMAT "x(10)" "-" rel_nmoperad  FORMAT "x(20)" 
     SKIP(1)
     "CAIXA:" rel_nrdcaixa FORMAT "ZZ9" "AUTENTICADORA:" AT 16 rel_nrdmaqui
     FORMAT "ZZ9" "QTD. AUT.:" AT 39 rel_qtautent "LACRE:" AT 61 rel_nrdlacre
     SKIP(1)
     FILL("=",76)  FORMAT "x(76)"
     SKIP(1)
     WITH NO-BOX COLUMN aux_nrcoluna
          NO-LABELS PAGE-TOP WIDTH 76 FRAME f_cabec_boletim.
     
FORM HEADER     
     "SALDO INICIAL" FILL(".",44) FORMAT "x(44)" ":" rel_vldsdini
     SKIP(1)
     FILL("-",76) FORMAT "x(76)"
     SKIP
     "***   E N T R A D A S   ***" AT 26 SKIP
     FILL("-",76) FORMAT "x(76)" SKIP
     "DESCRICAO" AT 1 "CONTABILIDADE   HIST." AT 35 "VALOR R$" AT 68 SKIP
     FILL("-",76) FORMAT "x(76)"
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_inicio_boletim.
 
FORM aux_descrctb FORMAT "x(31)"
     " D" 
     aux_nrctadeb FORMAT "9999"
     "- C"
     aux_nrctacrd FORMAT "9999" 
     aux_cdhistor FORMAT "zzzz9"
     "... :"
     aux_vlrttctb FORMAT "zzz,zzz,zz9.99-"
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_ctb_boletim.

FORM SPACE(2)
     aux_deschist FORMAT "x(41)"
     ":"
     aux_vlrtthis FORMAT "zzz,zzz,zz9.99"
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_his_boletim.

FORM HEADER
     SKIP(1)
     "TOTAL DE CREDITOS" 
     FILL(".",40) FORMAT "x(40)" ":"
     aux_vlrttcrd FORMAT "zzz,zzz,zz9.99-"
     SKIP(1)
     FILL("-",76) FORMAT "x(76)" SKIP
     "***   S A I D A S   ***" AT 29
     FILL("-",76) FORMAT "x(76)" SKIP
     "DESCRICAO" AT 1 "CONTABILIDADE   COD. HIST." AT 26 "VALOR R$" AT 68 SKIP
     FILL("-",76) FORMAT "x(76)"
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_saidas_boletim.

FORM HEADER
     SKIP(1)
     "TOTAL DE DEBITOS"
     FILL(".",41) FORMAT "x(41)" ":"
     aux_vlrttdeb FORMAT "zzz,zzz,zz9.99-"
     SKIP(1)
     FILL("-",76) FORMAT "x(76)" SKIP(1)
     "SALDO FINAL" FILL(".",46) FORMAT "x(46)" ":"
     aux_vldsdfin  FORMAT "zzz,zzz,zz9.99-" SKIP(1)
     FILL("=",76) FORMAT "x(76)"
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_saldo_final.

FORM HEADER
     SKIP(1)
     "***   E S T O R N O S   ***" AT 25
     FILL("-",76) FORMAT "x(76)" SKIP
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_ini_estornos.

FORM SPACE(2)
     crapaut.nrsequen COLUMN-LABEL "Aut"
     aux_dshistor     COLUMN-LABEL "Historico" FORMAT "x(23)"
     crapaut.nrdocmto
     crapaut.vldocmto COLUMN-LABEL "Valor" FORMAT "zzzz,zz9.99"
     crapaut.tpoperac COLUMN-LABEL "PG/RC"
     crapaut.nrseqaut COLUMN-LABEL "Aut.Est"
     WITH NO-BOX COLUMN aux_nrcoluna DOWN WIDTH 76 FRAME f_estornos.

FORM crapaut.nrsequen COLUMN-LABEL "Aut"
     aux_dshistor     COLUMN-LABEL "Historico" FORMAT "x(23)"
     crapaut.nrdocmto
     crapaut.vldocmto COLUMN-LABEL "Valor" FORMAT "zzzz,zz9.99"
     aux_dsdtraco     COLUMN-LABEL "Nr. Pendencia" FORMAT "x(16)"    
     WITH NO-BOX COLUMN aux_nrcoluna DOWN WIDTH 76 FRAME f_gerfin.

FORM HEADER
     SKIP(1)
     FILL("-",76) FORMAT "x(76)" SKIP
     WITH NO-BOX COLUMN aux_nrcoluna DOWN WIDTH 76 FRAME f_fim_estornos.
  
FORM  "VISTOS: " SPACE(47) 
      rel_dsfechad FORMAT "x(21)" NO-LABEL
      SKIP(4)
      "------------------ ------------------"
      "------------------"
      SKIP   
      SPACE(5) "OPERADOR" SPACE(10) "RESPONSAVEL" 
      SPACE(7) "CONTABILIDADE"
      WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_vistos .

FORM aux_deshi717
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_descricao_717.

FORM SKIP(1)
     WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS WIDTH 76 FRAME f_linha_branco.
     
FORM "Aguarde... Gerando Boletim!"
     WITH ROW 14 CENTERED OVERLAY ATTR-SPACE FRAME f_aguarde.

FORM SKIP(1)
     "ATENCAO!   Ligue a impressora e posicione o papel!" AT 3
     SKIP(1)
     tel_dsimprim AT 14
     tel_dscancel AT 29
     SKIP(1)
     WITH ROW 14 COLUMN 14 OVERLAY NO-LABELS WIDTH 56
          TITLE glb_nmformul FRAME f_atencao.

FORM SKIP(1)
     " ATENCAO!    AVISE A INFORMATICA URGENTE " 
     SKIP(1)
     "    HA LANCAMENTOS NOVOS NO CRAPHIS      "          
     SKIP(1)
     WITH ROW 10 OVERLAY NO-LABELS CENTERED FRAME f_novo_histor.

FORM HEADER
    SKIP(1)
    "--------------------------------------------------------------------------~~-" SKIP
    "***   Diferencas Caixa  ***" AT 29
 "---------------------------------------------------------------------------" ~SKIP
    SKIP 
    WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS 
    WIDTH 76 FRAME f_inicio_diferenca  STREAM-IO.

FORM HEADER
    SKIP(1)
 "---------------------------------------------------------------------------" 
    SKIP(1)
    WITH NO-BOX COLUMN aux_nrcoluna NO-LABELS 
    WIDTH 76 FRAME f_fim_diferenca STREAM-IO.

ASSIGN glb_cdprogra    = "bcaixa"
       glb_flgbatch    = FALSE
       glb_nrdevias    = 1
       glb_cdempres    = 11
       glb_cdrelato[1] = 258
       par_flgrodar    = TRUE.
       
FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.

INPUT THROUGH basename `tty` NO-ECHO.

SET aux_nmendter WITH FRAME f_terminal.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").

ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

IF   NOT aux_tipconsu   THEN
     DO:
         { includes/cabrel080_1.i }  /* Monta cabecalho do relatorio */

         aux_nrcoluna = 5.
         
         OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 84.
        
         VIEW STREAM str_1 FRAME f_cabrel080_1.
   
         /*  Configura a impressora para 1/8"  */
         PUT STREAM str_1 CONTROL "\022\024\033\120" NULL.

         PUT STREAM str_1 CONTROL "\0330\033x0" NULL.

      END.
ELSE
      DO:
          aux_nrcoluna = 1.
          
          OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp). /* visualiza nao pode ter
                                                       caracteres de controle */
      END.
      
ASSIGN glb_cdcritic = 0
       aux_vlrttcrd = 0
       aux_vlrttdeb = 0.

FIND crapbcx WHERE RECID(crapbcx) = aux_recidbol NO-LOCK NO-ERROR.
IF   NOT AVAILABLE crapbcx   THEN
     DO:
         ASSIGN glb_cdcritic = 11.
         RUN  fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         RETURN.
     END.

FIND crapage WHERE crapage.cdcooper = glb_cdcooper      AND
                   crapage.cdagenci = crapbcx.cdagenci  NO-LOCK NO-ERROR.
                   
IF   NOT AVAILABLE crapage   THEN
     DO:
         ASSIGN glb_cdcritic = 15.
         RUN  fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         LEAVE.
     END.

FIND crapope WHERE crapope.cdcooper = glb_cdcooper      AND
                   crapope.cdoperad = crapbcx.cdopecxa  NO-LOCK NO-ERROR.
                   
IF   NOT AVAILABLE crapope   THEN
     DO:
         ASSIGN glb_cdcritic = 702.
         RUN  fontes/critic.p.
         BELL.
         MESSAGE glb_dscritic.
         LEAVE.
     END.

ASSIGN rel_dtmvtolt = crapbcx.dtmvtolt 
       rel_cdagenci = crapbcx.cdagenci
       rel_nmresage = crapage.nmresage
       rel_cdopecxa = crapbcx.cdopecxa 
       rel_nmoperad = crapope.nmoperad
       rel_nrdcaixa = crapbcx.nrdcaixa
       rel_nrdmaqui = crapbcx.nrdmaqui
       rel_qtautent = crapbcx.qtautent
       rel_nrdlacre = crapbcx.nrdlacre
       rel_vldsdini = crapbcx.vldsdini
       aux_flgsemhi = no.

VIEW STREAM str_1 FRAME f_cabec_boletim.

VIEW STREAM str_1 FRAME f_inicio_boletim.

FOR EACH craphis WHERE craphis.cdcooper = glb_cdcooper AND
                     ((craphis.tplotmov = 22  OR
                       craphis.tplotmov = 24  OR
                       craphis.tplotmov = 25  OR
                       craphis.tplotmov = 28  OR    /* COBAN */
                       craphis.tplotmov = 29  OR    /* CONTA INVESTIMENTO*/
                       craphis.tplotmov = 30  OR    /* GPS */
                       craphis.tplotmov = 31  OR    /* Recebimento INSS */
                       craphis.tplotmov = 32  OR    /* Conta salario */
                       craphis.tplotmov = 33) OR    /* Receb. INSS-BANCOOB */
                      (craphis.tplotmov = 5   AND    /* Pagto Emprestimo Cx */
                       craphis.cdhistor = 92)) NO-LOCK
                       BREAK BY craphis.indebcre
                                BY craphis.dshistor:                 
    
    ASSIGN aux_flgouthi = NO
    
           aux_vlrttctb = 0
           aux_qtrttctb = 0.
    
    /*FOR EACH w-histor:
        DELETE w-histor.    
    END.*/
    EMPTY TEMP-TABLE w-histor.
    
    IF   craphis.nmestrut = "craplcm"   THEN
         DO:

             FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                                    craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                                    craplot.cdagenci = crapbcx.cdagenci   AND
                                    craplot.cdbccxlt = 11                 AND
                                    craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                                    craplot.cdopecxa = crapbcx.cdopecxa   AND
                                    craplot.tplotmov = 1
                                    NO-LOCK:
 
                 FOR EACH craplcm WHERE craplcm.cdcooper = glb_cdcooper     AND
                                        craplcm.dtmvtolt = craplot.dtmvtolt AND
                                        craplcm.cdagenci = craplot.cdagenci AND
                                        craplcm.cdbccxlt = craplot.cdbccxlt AND
                                        craplcm.nrdolote = craplot.nrdolote   
                                        USE-INDEX craplcm1 NO-LOCK:
                     
                     RUN pi-gera-w-histor 
                            (craplcm.cdhistor,craplcm.vllanmto,"").
                 END.    
             END. /* FOR EACH craplot */ 
         END. /* IF craphis.nmestrut = "craplcm" */
    ELSE
    
    IF   craphis.nmestrut = "craplem"    AND
         craphis.tplotmov <> 5 THEN
         DO:
             FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                                    craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                                    craplot.cdagenci = crapbcx.cdagenci   AND
                                    craplot.cdbccxlt = 11                 AND
                                    craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                                    craplot.cdopecxa = crapbcx.cdopecxa   AND
                                    craplot.tplotmov = 5
                                    NO-LOCK:
 
                 FOR EACH craplem WHERE craplem.cdcooper = glb_cdcooper     AND
                                        craplem.dtmvtolt = craplot.dtmvtolt AND
                                        craplem.cdagenci = craplot.cdagenci AND
                                        craplem.cdbccxlt = craplot.cdbccxlt AND
                                        craplem.nrdolote = craplot.nrdolote
                                        USE-INDEX craplem1 NO-LOCK:
                     
                     RUN pi-gera-w-histor 
                            (craplem.cdhistor,craplem.vllanmto,"").
                 END.    
             END. /* FOR EACH craplot */
         END. /* IF   craphis.nmestrut = "craplem"  */
    ELSE

    IF   craphis.nmestrut = "crapcbb"    AND
         craphis.tplotmov = 31 THEN      
         DO:
            RUN gera_crapcbb_INSS.     
         END.
    ELSE

    IF   craphis.nmestrut = "crapcbb"  THEN 
         DO:
            RUN gera_crapcbb.
         END.
    ELSE 
    
    IF   craphis.nmestrut = "craplpi"  THEN 
         DO:
            RUN gera_craplpi.
         END.
    ELSE 

    IF   craphis.nmestrut = "craplcs"  THEN 
         DO:
            RUN gera_craplcs.
         END.
    ELSE
    
    IF   craphis.nmestrut = "craplgp"  THEN        
         DO:
            /* Verifica qual historico deve rodar conforme cadastro da COOP
               Se tem Credenciamento, deve ser historico 582 senao 458 */
            IF  (crapcop.cdcrdarr  = 0     AND
                 craphis.cdhistor <> 458)        OR
                (crapcop.cdcrdarr <> 0     AND
                 craphis.cdhistor <> 582)        THEN
                 NEXT.
                 
            RUN gera_craplgp.
                    END.
    ELSE 
                  
    IF   craphis.nmestrut = "craplci"  THEN   
         DO:
            RUN gera_craplci.
         END.
    ELSE

    IF  craphis.nmestrut = "craplem"  THEN
        DO:
          RUN gera_craplem.
        END.
    ELSE 
    
    IF   craphis.nmestrut = "craplft"   THEN
         DO:

             FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                                    craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                                    craplot.cdagenci = crapbcx.cdagenci   AND
                                   (craplot.cdbccxlt = 30                 OR
                                    craplot.cdbccxlt = 31                 OR
                                    craplot.cdbccxlt = 11)                AND
                                    craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                                    craplot.cdopecxa = crapbcx.cdopecxa   AND
                                    craplot.tplotmov = 13
                                    NO-LOCK:
 
                 FOR EACH craplft WHERE craplft.cdcooper = glb_cdcooper     AND
                                        craplft.dtmvtolt = craplot.dtmvtolt AND
                                        craplft.cdagenci = craplot.cdagenci AND
                                        craplft.cdbccxlt = craplot.cdbccxlt AND
                                        craplft.nrdolote = craplot.nrdolote
                                        USE-INDEX craplft1 NO-LOCK:

                     ASSIGN aux_vllanmto = (craplft.vllanmto + craplft.vlrmulta + craplft.vlrjuros).
                     
                     RUN pi-gera-w-histor 
                            (craplft.cdhistor,aux_vllanmto,"").
                 END.    
             END. /* FOR EACH craplot  */

             FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                                    craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                                    craplot.cdagenci = crapbcx.cdagenci   AND
                                    craplot.cdbccxlt = 11                 AND
                                    craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                                    craplot.cdopecxa = crapbcx.cdopecxa   AND
                                    craplot.tplotmov = 21
                                    NO-LOCK:
                 
                 FOR EACH craptit WHERE craptit.cdcooper = glb_cdcooper     AND
                                        craptit.dtmvtolt = craplot.dtmvtolt AND
                                        craptit.cdagenci = craplot.cdagenci AND
                                        craptit.cdbccxlt = craplot.cdbccxlt AND
                                        craptit.nrdolote = craplot.nrdolote
                                        USE-INDEX craptit1 NO-LOCK:
                     
                     RUN pi-gera-w-histor (373,craptit.vldpagto,"").
                 END.    
             END. /* FOR EACH craplot */
         END. /* IF   craphis.nmestrut = "craplft" */
    ELSE
    IF   craphis.nmestrut = "craptit"   AND 
         craphis.cdhistor = 713 THEN          /* Titulos outros bancos */
         DO:
             FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                                    craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                                    craplot.cdagenci = crapbcx.cdagenci   AND
                                    craplot.cdbccxlt = 11                 AND
                                    craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                                    craplot.cdopecxa = crapbcx.cdopecxa   AND
                                    craplot.tplotmov = 20
                                    NO-LOCK:
 
                 FOR EACH craptit WHERE craptit.cdcooper = glb_cdcooper     AND
                                        craptit.dtmvtolt = craplot.dtmvtolt AND
                                        craptit.cdagenci = craplot.cdagenci AND
                                        craptit.cdbccxlt = craplot.cdbccxlt AND
                                        craptit.nrdolote = craplot.nrdolote AND
                                        craptit.intitcop = 0
                                        USE-INDEX craptit1 NO-LOCK:
                                        
                     ASSIGN aux_vlrttctb = aux_vlrttctb + craptit.vldpagto
                            aux_qtrttctb = aux_qtrttctb + 1.
                 END.    
             END. /* FOR EACH craplot */
         END. /* IF   craphis.nmestrut = "craptit" */
    ELSE
    IF   craphis.nmestrut = "craptit"   AND 
         craphis.cdhistor = 751 THEN          /* Titulos Cooperativa   */
         DO:
             FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                                    craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                                    craplot.cdagenci = crapbcx.cdagenci   AND
                                    craplot.cdbccxlt = 11                 AND
                                    craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                                    craplot.cdopecxa = crapbcx.cdopecxa   AND
                                    craplot.tplotmov = 20
                                    NO-LOCK:
 
                 FOR EACH craptit WHERE craptit.cdcooper = glb_cdcooper     AND
                                        craptit.dtmvtolt = craplot.dtmvtolt AND
                                        craptit.cdagenci = craplot.cdagenci AND
                                        craptit.cdbccxlt = craplot.cdbccxlt AND
                                        craptit.nrdolote = craplot.nrdolote AND
                                        craptit.intitcop = 1
                                        USE-INDEX craptit1 NO-LOCK:
                                        
                     ASSIGN aux_vlrttctb = aux_vlrttctb + craptit.vldpagto
                            aux_qtrttctb = aux_qtrttctb + 1.
                 END.    
             END. /* FOR EACH craplot */
         END. /* IF   craphis.nmestrut = "craptit" */
  
    ELSE
    IF   craphis.nmestrut = "crapchd"   THEN          /*  Cheques capturados  */
         DO:
             FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                                    craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                                    craplot.cdagenci = crapbcx.cdagenci   AND
                                   (craplot.cdbccxlt = 11                 OR
                                    craplot.cdbccxlt = 500)               AND
                                    craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                                    craplot.cdopecxa = crapbcx.cdopecxa   AND
                                   (craplot.tplotmov = 1                  OR
                                    craplot.tplotmov = 23                 OR
                                    craplot.tplotmov = 29) NO-LOCK:
 
                 FOR EACH crapchd WHERE crapchd.cdcooper = glb_cdcooper     AND
                                        crapchd.dtmvtolt = craplot.dtmvtolt AND
                                        crapchd.cdagenci = craplot.cdagenci AND
                                        crapchd.cdbccxlt = craplot.cdbccxlt AND
                                        crapchd.nrdolote = craplot.nrdolote AND
                                        crapchd.inchqcop = 0
                                        USE-INDEX crapchd3 NO-LOCK:
                               
                     IF   crapchd.cdbccxlt = 500   THEN
                          ASSIGN aux_vlroti14 = aux_vlroti14 + crapchd.vlcheque
                                 aux_qtroti14 = aux_qtroti14 + 1.
                     ELSE
                          DO:
                              IF   crapchd.nrdolote > 30000 AND
                                   crapchd.nrdolote < 30999 THEN
                                   ASSIGN aux_vllanchq = aux_vllanchq + 
                                                         crapchd.vlcheque
                                          aux_qtlanchq = aux_qtlanchq + 1.
                              ELSE
                                   ASSIGN aux_vlrttctb = aux_vlrttctb +
                                                         crapchd.vlcheque
                                          aux_qtrttctb = aux_qtrttctb + 1.
                          END.
                 END.    
             END. /* FOR EACH craplot */
         END. /* IF   craphis.nmestrut = "crapchd" */
    ELSE
    /****** lancamentos extra-sistema *******/
    IF   craphis.nmestrut = "craplcx"   THEN                     
         DO:
             FOR EACH craplcx WHERE craplcx.cdcooper = glb_cdcooper      AND
                                    craplcx.dtmvtolt = crapbcx.dtmvtolt  AND
                                    craplcx.cdagenci = crapbcx.cdagenci  AND
                                    craplcx.nrdcaixa = crapbcx.nrdcaixa  AND
                                    craplcx.cdopecxa = crapbcx.cdopecxa
                                    USE-INDEX craplcx1 NO-LOCK:
                                    
                 IF   craplcx.cdhistor <> craphis.cdhistor THEN
                      NEXT.
                 IF   craphis.indcompl <> 0   THEN     
                      RUN pi-gera-w-histor
                        (craplcx.cdhistor,craplcx.vldocmto,craplcx.dsdcompl).
                 ELSE
                      ASSIGN  aux_vlrttctb      = aux_vlrttctb + 
                                                      craplcx.vldocmto
                              aux_qtrttctb      = aux_qtrttctb + 1.
          
             END. /* FOR EACH craplcx */                  
         END. /* IF   craphis.nmestrut = "craplcx" */
    ELSE
    IF   craphis.nmestrut = "craptvl"   THEN
         DO:                
             FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                                    craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                                    craplot.cdagenci = crapbcx.cdagenci   AND
                                    craplot.cdbccxlt = 11                 AND
                                    craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                                    craplot.cdopecxa = crapbcx.cdopecxa   AND
                                    craplot.tplotmov = craphis.tplotmov
                                    NO-LOCK:
 
                 FOR EACH craptvl WHERE craptvl.cdcooper = glb_cdcooper     AND
                                        craptvl.dtmvtolt = craplot.dtmvtolt AND
                                        craptvl.cdagenci = craplot.cdagenci AND
                                        craptvl.cdbccxlt = craplot.cdbccxlt AND
                                        craptvl.nrdolote = craplot.nrdolote
                                        USE-INDEX craptvl2 NO-LOCK:
                     
                     ASSIGN aux_vlrttctb = aux_vlrttctb + craptvl.vldocrcb
                            aux_qtrttctb = aux_qtrttctb + 1.

                 END.    
             END. /* FOR EACH craplot */
         END. /* IF   craphis.nmestrut = "craptvl" */
    ELSE
         DO:
             ASSIGN aux_flgsemhi = yes.
             VIEW FRAME f_novo_histor.
             PAUSE.
             LEAVE.
         END.
    
    /****** tratamento para os outros tipos de historicos ******/
    IF   LAST-OF(craphis.dshistor)
    AND  craphis.cdhistor <> 717
    AND  craphis.cdhistor <> 561
    AND (aux_vlrttctb <> 0  OR
         aux_vllanchq <> 0  OR
         aux_vlroti14 <> 0) THEN
         DO:
             IF   aux_vllanchq > 0   THEN
                  ASSIGN aux_vlrttdeb = aux_vlrttdeb + aux_vllanchq.
                  
             IF   aux_vlroti14 > 0   THEN
                  ASSIGN aux_vlrttdeb = aux_vlrttdeb + aux_vlroti14.
             
             IF   craphis.indebcre = "C"   THEN      
                  ASSIGN aux_vlrttcrd = aux_vlrttcrd + aux_vlrttctb.
             ELSE
                  ASSIGN aux_vlrttdeb = aux_vlrttdeb + aux_vlrttctb.

             IF   craphis.tpctbcxa = 2   THEN       
                  ASSIGN aux_nrctadeb = crapage.cdcxaage
                         aux_nrctacrd = craphis.nrctacrd.
             ELSE
                  IF   craphis.tpctbcxa = 3   THEN
                       ASSIGN aux_nrctacrd = crapage.cdcxaage
                              aux_nrctadeb = craphis.nrctadeb.
                  ELSE
                       ASSIGN aux_nrctacrd = craphis.nrctacrd
                              aux_nrctadeb = craphis.nrctadeb.
                   
             aux_cdhistor = craphis.cdhstctb.
                          
             IF   aux_vllanchq > 0   THEN
                  DO:    
                      ASSIGN aux_descrctb = TRIM(SUBSTR(craphis.dshistor,1,16))
                                            + "(ROTINA 66)"
                             substr(aux_descrctb,length(aux_descrctb) + 2,
                                 (24 - length(aux_descrctb) - 1)) =
                                 fill(".",24 - length(aux_descrctb) - 1)
     
                      aux_descrctb = SUBSTRING(aux_descrctb,1,24) + "(" +
                                     STRING(aux_qtlanchq, "z,zz9") + ") ".
                      
                      DISPLAY STREAM str_1
                              WITH FRAME f_linha_branco.
                      DOWN STREAM str_1 WITH FRAME f_linha_branco.       
                           
                      DISPLAY STREAM str_1
                              aux_descrctb aux_nrctadeb aux_nrctacrd 
                              aux_cdhistor aux_vllanchq @ aux_vlrttctb
                              WITH FRAME f_ctb_boletim.
                      
                      DOWN STREAM str_1 WITH FRAME f_ctb_boletim.
 
                      IF   NOT aux_tipconsu   AND
                           LINE-COUNTER(str_1) = 80   THEN
                           PAGE STREAM str_1.
                           
                      ASSIGN aux_vllanchq = 0
                             aux_qtlanchq = 0.
                  END.
                  
             IF   aux_vlroti14 > 0   THEN
                  DO:    
                      ASSIGN aux_descrctb = TRIM(SUBSTR(craphis.dshistor,1,16))
                                            + "(ROTINA 14)"
                             substr(aux_descrctb,length(aux_descrctb) + 2,
                                 (24 - length(aux_descrctb) - 1)) =
                                 fill(".",24 - length(aux_descrctb) - 1)
     
                      aux_descrctb = SUBSTRING(aux_descrctb,1,24) + "(" +
                                     STRING(aux_qtroti14, "z,zz9") + ") ".
                      
                      DISPLAY STREAM str_1
                              WITH FRAME f_linha_branco.
                      DOWN STREAM str_1 WITH FRAME f_linha_branco.       
                           
                      DISPLAY STREAM str_1
                              aux_descrctb aux_nrctadeb aux_nrctacrd 
                              aux_cdhistor aux_vlroti14 @ aux_vlrttctb
                              WITH FRAME f_ctb_boletim.
                      
                      DOWN STREAM str_1 WITH FRAME f_ctb_boletim.
 
                      IF   NOT aux_tipconsu   AND
                           LINE-COUNTER(str_1) = 80   THEN
                           PAGE STREAM str_1.
                           
                      ASSIGN aux_vlroti14 = 0
                             aux_qtroti14 = 0.
                  END.
     
             
             ASSIGN aux_descrctb = TRIM(SUBSTRING(craphis.dshistor,1,24))
                    substr(aux_descrctb,length(aux_descrctb) + 2,
                             (24 - length(aux_descrctb) - 1)) =
                                   fill(".",24 - length(aux_descrctb) - 1)
                    aux_descrctb = SUBSTRING(aux_descrctb,1,24) + "(" +
                                        STRING(aux_qtrttctb, "z,zz9") + ") ".
                  
             DISPLAY STREAM str_1
                    WITH FRAME f_linha_branco.

             DOWN STREAM str_1 WITH FRAME f_linha_branco.       
             
             DISPLAY STREAM str_1
                     aux_descrctb aux_nrctadeb aux_nrctacrd 
                     aux_cdhistor aux_vlrttctb
                     WITH FRAME f_ctb_boletim.
             DOWN STREAM str_1 WITH FRAME f_ctb_boletim.
   
             IF   NOT aux_tipconsu
             AND  LINE-COUNTER(str_1) = 80   THEN
                  PAGE STREAM str_1.
     
             IF   aux_flgouthi   THEN
                  DO:
                      FOR EACH w-histor NO-LOCK BY w-histor.cdhistor:
                          ASSIGN aux_deschist = ""
                                 aux_vlrtthis = w-histor.vllanmto.
                          IF   craphis.nmestrut <> "craplcx"   THEN
                               ASSIGN aux_deschist = 
                                      STRING(w-histor.cdhistor,"9999") + "-" +  
                                      STRING(w-histor.dshistor,"x(18)") + "(" +
                                      STRING(w-histor.qtlanmto, "z,zz9") + ") "
                                  substr(aux_deschist,length(aux_deschist) + 2,
                                  (41 - length(aux_deschist) - 1)) =
                                  fill(".",41 - length(aux_deschist) - 1).
                          ELSE
                               ASSIGN aux_deschist = 
                                  substr(w-histor.dsdcompl,1,40) 
                                  substr(aux_deschist,length(aux_deschist) + 2,
                                  (44 - length(aux_deschist) - 1)) =
                                  fill(".",44 - length(aux_deschist) - 1).
                          
                          DISPLAY STREAM str_1
                               aux_deschist aux_vlrtthis 
                               WITH FRAME f_his_boletim.
                          DOWN STREAM str_1 WITH FRAME f_his_boletim.
              
                          IF   NOT aux_tipconsu
                          AND  LINE-COUNTER(str_1) = 80   THEN
                               PAGE STREAM str_1.
                      END.         
                  END.
         END.
    
    /*** tratamento para historico 717-arrecadacoes ******/
    IF   LAST-OF(craphis.dshistor)
    AND  craphis.cdhistor = 717
    AND  aux_vlrttctb <> 0   THEN
         DO:
             
             IF   NOT aux_tipconsu
             AND  LINE-COUNTER(str_1) > 76   THEN
                  PAGE STREAM str_1.

             ASSIGN aux_deshi717 = TRIM(craphis.dshistor) + ":".
             
             DISPLAY STREAM str_1
                    WITH FRAME f_linha_branco.
             DOWN STREAM str_1 WITH FRAME f_linha_branco.       
             
             DISPLAY STREAM str_1 
                     aux_deshi717 
                     WITH FRAME f_descricao_717.
             DOWN STREAM str_1 WITH FRAME f_descricao_717.
             
             FOR EACH w-histor NO-LOCK BY w-histor.cdhistor:

                 FIND crabhis WHERE crabhis.cdcooper = glb_cdcooper AND
                                    crabhis.cdhistor = w-histor.cdhistor
                                                       NO-LOCK NO-ERROR.

                 IF   craphis.indebcre = "C"   THEN      
                      ASSIGN aux_vlrttcrd = aux_vlrttcrd + w-histor.vllanmto.
                 ELSE
                      ASSIGN aux_vlrttdeb = aux_vlrttdeb + w-histor.vllanmto.

                 IF   crabhis.tpctbcxa = 2   THEN       
                      ASSIGN aux_nrctadeb = crapage.cdcxaage
                             aux_nrctacrd = crabhis.nrctacrd.
                 ELSE
                      IF   crabhis.tpctbcxa = 3   THEN
                           ASSIGN aux_nrctacrd = crapage.cdcxaage
                                  aux_nrctadeb = crabhis.nrctadeb.
                      ELSE
                           ASSIGN aux_nrctacrd = crabhis.nrctacrd
                                  aux_nrctadeb = crabhis.nrctadeb.
                 ASSIGN aux_descrctb = ""
                        aux_descrctb = "  " + 
                               STRING(w-histor.cdhistor,"9999") + "-" +  
                               STRING(w-histor.dshistor,"x(18)") + "(" +
                               STRING(w-histor.qtlanmto, "z,zz9") + ") "
                        aux_cdhistor = crabhis.cdhstctb
                        aux_vlrttctb = w-histor.vllanmto.
           
                 DISPLAY STREAM str_1  
                         aux_descrctb aux_nrctadeb aux_nrctacrd 
                         aux_cdhistor aux_vlrttctb
                         WITH FRAME f_ctb_boletim.
                 DOWN STREAM str_1 WITH FRAME f_ctb_boletim.
   
                 IF   NOT aux_tipconsu
                 AND  LINE-COUNTER(str_1) = 80   THEN
                      PAGE STREAM str_1.
     
             END.
         END.    

        IF  LAST-OF(craphis.dshistor)   AND  /* Hist. 561-salario **/
            craphis.cdhistor = 561      AND
           (aux_vlrttctb <> 0           OR
            aux_vllanchq <> 0           OR
            aux_vlroti14 <> 0)          THEN 
            DO:

                
                ASSIGN aux_descrctb = TRIM(SUBSTRING(craphis.dshistor,1,24))
    
                       SUBSTR(aux_descrctb,length(aux_descrctb) + 2,(24 - 
                              length(aux_descrctb) - 1)) =
                                  FILL(".",24 - length(aux_descrctb) - 1)
                       aux_descrctb = SUBSTRING(aux_descrctb,1,24) + "(" +
                                      STRING(aux_qtrttctb, "z,zz9") + ") ".


                
                DISPLAY STREAM str_1 WITH FRAME f_linha_branco.
                
                DISPLAY STREAM str_1
                        aux_descrctb aux_nrctadeb aux_nrctacrd 
                        aux_cdhistor aux_vlrttctb
                        WITH FRAME f_ctb_boletim.
                DOWN STREAM str_1 WITH FRAME f_ctb_boletim.
                
                FOR EACH w_empresa NO-LOCK:
                
                    FIND crapemp WHERE crapemp.cdcooper = glb_cdcooper
                                   AND crapemp.cdempres = w_empresa.cdempres
                                       NO-LOCK.
                    
                    ASSIGN aux_vlrtthis = w_empresa.vllanmto
                           aux_deschist = 
                               STRING(w_empresa.cdempres,"99999")  + "-" +  
                               STRING(crapemp.nmresemp,"x(18)")  + "(" +
                               STRING(w_empresa.qtlanmto, "z,zz9") + ") "
                               SUBSTR(aux_deschist,length(aux_deschist) + 2,
                               (41 - length(aux_deschist) - 1)) =
                               FILL(".",41 - length(aux_deschist) - 1).
                       
                    DISPLAY STREAM str_1 aux_deschist aux_vlrtthis 
                                         WITH FRAME f_his_boletim.

                    DOWN STREAM str_1 WITH FRAME f_his_boletim.
                END.
               
            END. /* IF  LAST-OF(craphis.dshistor)  */   
     
    IF   LAST-OF(craphis.indebcre)   THEN
         DO:
             IF   craphis.indebcre = "C"   THEN      
                  DO:
                      VIEW STREAM str_1 FRAME f_saidas_boletim.

                      IF   NOT aux_tipconsu
                      AND  LINE-COUNTER(str_1) > 80   THEN
                           PAGE STREAM str_1.
                           
                  END.
             ELSE
                  DO:
                     ASSIGN aux_vldsdfin = crapbcx.vldsdini +
                                           aux_vlrttcrd - aux_vlrttdeb.
                     
                     IF   NOT aux_tipconsu
                     AND  LINE-COUNTER(str_1) > 80   THEN
                          PAGE STREAM str_1.
     
                     VIEW STREAM str_1 FRAME f_saldo_final.       

                  END.       
         END.                  
END.

/*FOR EACH work_estorno:
    DELETE work_estorno.
END.*/
EMPTY TEMP-TABLE work_estorno.

FOR EACH crapaut WHERE crapaut.cdcooper = glb_cdcooper       AND
                       crapaut.dtmvtolt = crapbcx.dtmvtolt   AND
                       crapaut.cdagenci = crapbcx.cdagenci   AND 
                       crapaut.nrdcaixa = crapbcx.nrdcaixa   AND
                       crapaut.estorno  = YES                NO-LOCK
                       BREAK BY crapaut.nrsequen:
                       
    IF   FIRST(crapaut.nrsequen)   THEN 
         DO:
             DISPLAY STREAM str_1 WITH FRAME f_ini_estornos.
             DOWN STREAM str_1 WITH FRAME f_ini_estornos.
         END.
             
    FIND craphis WHERE craphis.cdcooper = glb_cdcooper     AND
                       craphis.cdhistor = crapaut.cdhistor NO-LOCK NO-ERROR.
    
    ASSIGN aux_dshistor = STRING(crapaut.cdhistor,"9999") + "-".
    IF   AVAILABLE craphis   THEN  
         ASSIGN aux_dshistor = aux_dshistor + craphis.dshistor.
    ELSE
         ASSIGN aux_dshistor = aux_dshistor + "***************".
    
    DISPLAY STREAM str_1
            crapaut.nrsequen
            aux_dshistor
            crapaut.nrdocmto
            crapaut.vldocmto
            crapaut.tpoperac
            crapaut.nrseqaut
            WITH FRAME f_estornos.
    DOWN STREAM str_1 WITH FRAME f_estornos.
    
    CREATE  work_estorno.
    ASSIGN  work_estorno.cdagenci = crapbcx.cdagenci    
            work_estorno.nrdcaixa = crapbcx.nrdcaixa     
            work_estorno.nrseqaut = crapaut.nrseqaut.

    IF   LAST(crapaut.nrsequen)   THEN
         DO:
             DISPLAY STREAM str_1 WITH FRAME f_fim_estornos.
             DOWN STREAM str_1 WITH FRAME f_fim_estornos.
         END.    
END.                         

/*=== Historicos Dif.Caixa/Recuperacao Caixa(701/702/733/734 ===*/

FOR EACH craplcx WHERE craplcx.cdcooper = glb_cdcooper      AND
                       craplcx.cdagenci = crapbcx.cdagenci  AND
                       craplcx.nrdcaixa = crapbcx.nrdcaixa  AND
                       craplcx.dtmvtolt = crapbcx.dtmvtolt  AND
                      (craplcx.cdhistor = 701                OR
                       craplcx.cdhistor = 702                OR
                       craplcx.cdhistor = 733                OR
                       craplcx.cdhistor = 734)              NO-LOCK
                       BREAK BY craplcx.dtmvtolt
                                BY craplcx.nrautdoc:
                 
    FIND craphis WHERE craphis.cdcooper = glb_cdcooper     AND
                       craphis.cdhistor = craplcx.cdhistor NO-LOCK NO-ERROR. 
    
    ASSIGN aux_dshistor = STRING(craplcx.cdhistor,"9999") + "-".
    IF   AVAILABLE craphis   THEN  
         ASSIGN aux_dshistor = aux_dshistor + craphis.dshistor.
    ELSE
         ASSIGN aux_dshistor = aux_dshistor + "***************".
 
    FIND crapaut WHERE crapaut.cdcooper = glb_cdcooper      AND
                       crapaut.cdagenci = craplcx.cdagenci  AND
                       crapaut.nrdcaixa = craplcx.nrdcaixa  AND
                       crapaut.dtmvtolt = craplcx.dtmvtolt  AND
                       crapaut.nrsequen = craplcx.nrautdoc  NO-LOCK NO-ERROR.

    IF   FIRST-OF(craplcx.dtmvtolt) THEN  
         VIEW STREAM str_1 FRAME f_inicio_diferenca.
             
    DISP STREAM str_1 
         crapaut.nrsequen
         aux_dshistor
         craplcx.nrdocmto @ crapaut.nrdocmto
         craplcx.vldocmto @ crapaut.vldocmto
         crapaut.tpoperac
         crapaut.nrseqaut
         WITH  FRAME f_estornos.
    DOWN STREAM str_1 WITH  FRAME f_estornos.

    IF   LAST-OF(craplcx.dtmvtolt) THEN  
         VIEW STREAM str_1 FRAME f_fim_diferenca.
         
END.

IF   NOT aux_tipconsu   THEN
     DO:
         IF   LINE-COUNTER(str_1) > 72   THEN
              PAGE STREAM str_1.

         IF   crapbcx.cdsitbcx = 2   THEN
              rel_dsfechad = "** BOLETIM FECHADO **".
         ELSE
              rel_dsfechad = " ** BOLETIM ABERTO **".

         DISPLAY STREAM str_1 rel_dsfechad WITH FRAME f_vistos.        
     END.

IF   crapbcx.cdsitbcx = 2  AND 
    (glb_cdcooper     = 1  OR        /* para a Viacredi */
     glb_cdcooper     = 2) THEN      /* para a Creditextil */
     DO:
         /*  Historicos transitados no gerenciador financeiro - Edson */

         FOR EACH crapaut WHERE crapaut.cdcooper = glb_cdcooper       AND
                                crapaut.dtmvtolt = crapbcx.dtmvtolt   AND
                                crapaut.cdagenci = crapbcx.cdagenci   AND
                                crapaut.nrdcaixa = crapbcx.nrdcaixa   AND
                                CAN-DO("707,708,747",STRING(crapaut.cdhistor))
                                NO-LOCK BREAK BY crapaut.nrsequen:
   
             IF   FIRST(crapaut.nrsequen)   THEN 
                  DO:
                      PAGE STREAM str_1.
             
                      DISPLAY STREAM str_1
                          "DOCUMENTOS TRANSITADOS VIA GERENCIADOR FINANCEIRO"
                          SKIP(1)
                          WITH NO-BOX COLUMN aux_nrcoluna
                               NO-LABELS WIDTH 76 FRAME f_cab_gerfin.
                  END.
             
             FIND work_estorno WHERE
                  work_estorno.cdagenci = crapbcx.cdagenci AND
                  work_estorno.nrdcaixa = crapbcx.nrdcaixa AND
                  work_estorno.nrseqaut = crapaut.nrsequen NO-LOCK NO-ERROR.
                  
             IF  NOT AVAIL work_estorno THEN
                 DO:
                                 
                    IF   NOT crapaut.estorno THEN
                         DO:
                             FIND craphis WHERE
                                  craphis.cdcooper = glb_cdcooper AND
                                  craphis.cdhistor = crapaut.cdhistor
                                  NO-LOCK NO-ERROR.
         
                             ASSIGN aux_dshistor = 
                                    STRING(crapaut.cdhistor,"9999") + "-".
         
                             IF  AVAIL craphis   THEN  
                                 ASSIGN aux_dshistor = aux_dshistor + 
                                                       craphis.dshistor.
                             ELSE
                                 ASSIGN aux_dshistor = aux_dshistor + 
                                            "***************".
    
                             ASSIGN tot_qtgerfin = tot_qtgerfin + 1
                                    tot_vlgerfin = tot_vlgerfin +
                                                       crapaut.vldocmto.
                
                             DISPLAY STREAM str_1
                                     crapaut.nrsequen   aux_dshistor
                                     crapaut.nrdocmto   crapaut.vldocmto
                                     aux_dsdtraco
                                     WITH FRAME f_gerfin.

                             DOWN 2 STREAM str_1 WITH FRAME f_gerfin.
                      
                             IF   NOT aux_tipconsu   AND
                                  LINE-COUNTER(str_1) = 80   THEN
                                  DO:
                                      PAGE STREAM str_1.
                       
                                      DISPLAY STREAM str_1
                           "DOCUMENTOS TRANSITADOS VIA GERENCIADOR FINANCEIRO"
                               SKIP(1)
                                       WITH NO-BOX COLUMN aux_nrcoluna
                                       NO-LABELS WIDTH 76 FRAME f_cab_gerfin.
                                  END.
                        END.
                 END.
               
             IF  LAST(crapaut.nrsequen)   THEN
                 DO:
                      DISPLAY STREAM str_1
                          "T O T A I S ===>" AT  1
                          tot_qtgerfin       AT 41 FORMAT "zz,zz9"
                          tot_vlgerfin       AT 48 FORMAT "zzzz,zzz.99"
                          SKIP
                          WITH NO-BOX COLUMN aux_nrcoluna
                               NO-LABELS WIDTH 76 FRAME f_total_gerfin.
                  
                      DISPLAY STREAM str_1 WITH FRAME f_fim_estornos.
                  
                      DOWN STREAM str_1 WITH FRAME f_fim_estornos.
                  END.    
         
         END.  /*  Fim do FOR EACH -- crapaut  */

         IF   NOT aux_tipconsu   THEN
              DO:
                  IF   LINE-COUNTER(str_1) > 72   THEN
                       PAGE STREAM str_1.

                  IF   crapbcx.cdsitbcx = 2   THEN
                       rel_dsfechad = "** BOLETIM FECHADO **".
                  ELSE
                       rel_dsfechad = " ** BOLETIM ABERTO **".

                  DISPLAY STREAM str_1 rel_dsfechad WITH FRAME f_vistos.        
              END.
     END.
     
OUTPUT STREAM str_1 CLOSE.

IF   aux_flgsemhi   THEN
     DO:
         HIDE FRAME f_novo_histor.
         RETURN.
     END.

VIEW FRAME f_aguarde.
PAUSE 3 NO-MESSAGE.
HIDE FRAME f_aguarde NO-PAUSE.

IF   NOT aux_tipconsu   THEN
     DO:
         /*** nao necessario ao programa somente para nao dar erro 
              de compilacao na rotina de impressao ****/
         FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                                  NO-LOCK NO-ERROR.

         { includes/impressao.i }

         HIDE MESSAGE NO-PAUSE.

     END.
RETURN.

PROCEDURE pi-gera-w-histor:
   DEF INPUT PARAM pi_cdhistor LIKE craphis.cdhistor.
   DEF INPUT PARAM pi_vllanmto LIKE craplcm.vllanmto.
   DEF INPUT PARAM pi_dsdcompl LIKE craplcx.dsdcompl.

   FIND crabhis WHERE crabhis.cdcooper = glb_cdcooper AND
                      crabhis.cdhistor = pi_cdhistor  NO-LOCK NO-ERROR.
                     
   IF   NOT AVAILABLE crabhis THEN
        NEXT.
   
   IF   craphis.cdhistor <> 717 /* Arrecadacoes */
   AND  crabhis.indebcre <> craphis.indebcre   THEN
        NEXT.
  
   FIND w-histor WHERE w-histor.cdhistor = pi_cdhistor             AND
                       w-histor.dshistor = TRIM(crabhis.dshistor)  AND
                       w-histor.dsdcompl = TRIM(pi_dsdcompl)       NO-ERROR.
                   
   IF   NOT AVAILABLE w-histor   THEN 
        DO:
            CREATE w-histor.
            ASSIGN w-histor.cdhistor = pi_cdhistor
                   w-histor.dshistor = TRIM(crabhis.dshistor)
                   w-histor.dsdcompl = TRIM(pi_dsdcompl). 
                                 
        END.
                     
   ASSIGN aux_flgouthi      = YES
          
          aux_vlrttctb      = aux_vlrttctb + pi_vllanmto
          aux_qtrttctb      = aux_qtrttctb + 1
          w-histor.qtlanmto = w-histor.qtlanmto + 1
          w-histor.vllanmto = w-histor.vllanmto + pi_vllanmto.
 
END PROCEDURE.

PROCEDURE gera_crapcbb:

    FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                           craplot.cdagenci = crapbcx.cdagenci   AND
                           craplot.cdbccxlt = 11                 AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                           craplot.cdopecxa = crapbcx.cdopecxa   AND
                           craplot.tplotmov = 28                 NO-LOCK:
                           
        FOR EACH crapcbb WHERE crapcbb.cdcooper = glb_cdcooper      AND
                               crapcbb.dtmvtolt = craplot.dtmvtolt  AND
                               crapcbb.cdagenci = craplot.cdagenci  AND
                               crapcbb.cdbccxlt = craplot.cdbccxlt  AND
                               crapcbb.nrdolote = craplot.nrdolote  AND
                               crapcbb.flgrgatv = YES               AND
                               crapcbb.tpdocmto < 3                 NO-LOCK:

            ASSIGN aux_vlrttctb = aux_vlrttctb + crapcbb.valorpag
                                  aux_qtrttctb = aux_qtrttctb + 1.
        END.    
    END.              
END PROCEDURE.

PROCEDURE gera_craplpi:

    FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                           craplot.cdagenci = crapbcx.cdagenci   AND
                           craplot.cdbccxlt = 11                 AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                           craplot.cdopecxa = crapbcx.cdopecxa   AND
                           craplot.tplotmov = 33                 NO-LOCK:
                           
        FOR EACH craplpi WHERE craplpi.cdcooper = craplot.cdcooper   AND
                               craplpi.dtmvtolt = craplot.dtmvtolt   AND
                               craplpi.cdagenci = craplot.cdagenci   AND
                               craplpi.cdbccxlt = craplot.cdbccxlt   AND
                               craplpi.nrdolote = craplot.nrdolote
                               NO-LOCK:
                               
            ASSIGN aux_vlrttctb = aux_vlrttctb + craplpi.vllanmto
                                  aux_qtrttctb = aux_qtrttctb + 1.
        END.    
    END.              
END PROCEDURE.


PROCEDURE gera_crapcbb_INSS:

    FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                           craplot.cdagenci = crapbcx.cdagenci   AND
                           craplot.cdbccxlt = 11                 AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                           craplot.cdopecxa = crapbcx.cdopecxa   AND
                           craplot.tplotmov = 31                 NO-LOCK:
                           
        FOR EACH crapcbb WHERE crapcbb.cdcooper = glb_cdcooper      AND
                               crapcbb.dtmvtolt = craplot.dtmvtolt  AND
                               crapcbb.cdagenci = craplot.cdagenci  AND
                               crapcbb.cdbccxlt = craplot.cdbccxlt  AND
                               crapcbb.nrdolote = craplot.nrdolote  AND
                               crapcbb.tpdocmto = 3                 NO-LOCK:
                 
            ASSIGN aux_vlrttctb = aux_vlrttctb + crapcbb.valorpag
                                  aux_qtrttctb = aux_qtrttctb + 1.
        END.    
    END.              
END PROCEDURE.

PROCEDURE gera_craplgp:
    FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                           craplot.cdagenci = crapbcx.cdagenci   AND
                           craplot.cdbccxlt = 11                 AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                           craplot.cdopecxa = crapbcx.cdopecxa   AND
                           craplot.tplotmov = 30                 NO-LOCK:
                           
        FOR EACH craplgp WHERE craplgp.cdcooper = glb_cdcooper      AND
                               craplgp.dtmvtolt = craplot.dtmvtolt  AND
                               craplgp.cdagenci = craplot.cdagenci  AND
                               craplgp.cdbccxlt = craplot.cdbccxlt  AND
                               craplgp.nrdolote = craplot.nrdolote  NO-LOCK:
                               
            ASSIGN aux_vlrttctb = aux_vlrttctb + craplgp.vlrtotal
                                  aux_qtrttctb = aux_qtrttctb + 1.
        END.    
    END.              
END PROCEDURE.

PROCEDURE gera_craplci:
    FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                           craplot.cdagenci = crapbcx.cdagenci   AND
                           craplot.cdbccxlt = 11                 AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                           craplot.cdopecxa = crapbcx.cdopecxa   AND
                           craplot.tplotmov = 29                 NO-LOCK:
                           
        FOR EACH craplci WHERE craplci.cdcooper = glb_cdcooper      AND
                               craplci.dtmvtolt = craplot.dtmvtolt  AND
                               craplci.cdagenci = craplot.cdagenci  AND
                               craplci.cdbccxlt = craplot.cdbccxlt  AND
                               craplci.nrdolote = craplot.nrdolote  AND   
                               craplci.cdhistor = craphis.cdhistor  NO-LOCK: 
                               
            ASSIGN aux_vlrttctb = aux_vlrttctb + craplci.vllanmto
                                  aux_qtrttctb = aux_qtrttctb + 1.
        END.    
    END.              
END PROCEDURE.

PROCEDURE gera_craplem:
    FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper       AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt   AND
                           craplot.cdagenci = crapbcx.cdagenci   AND
                           craplot.cdbccxlt = 11                 AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa   AND
                           craplot.cdopecxa = crapbcx.cdopecxa   AND
                           craplot.tplotmov = 5                  NO-LOCK:
                           
        FOR EACH craplem WHERE craplem.cdcooper = glb_cdcooper      AND
                               craplem.dtmvtolt = craplot.dtmvtolt  AND
                               craplem.cdagenci = craplot.cdagenci  AND
                               craplem.cdbccxlt = craplot.cdbccxlt  AND
                               craplem.nrdolote = craplot.nrdolote
                               USE-INDEX craplem1 NO-LOCK:
                               
            ASSIGN aux_vlrttctb = aux_vlrttctb + craplem.vllanmto
                                  aux_qtrttctb = aux_qtrttctb + 1.
        END.    
    END.              
END PROCEDURE.

PROCEDURE gera_craplcs:

    DEF VAR aux_qtlanmto AS INT                                     NO-UNDO.
    DEF VAR aux_vllanmto AS DEC                                     NO-UNDO.
    
    EMPTY TEMP-TABLE w_empresa.
    
    FOR EACH craplot WHERE craplot.cdcooper = glb_cdcooper      AND
                           craplot.dtmvtolt = crapbcx.dtmvtolt  AND
                           craplot.cdagenci = crapbcx.cdagenci  AND
                           craplot.cdbccxlt = 11                AND
                           craplot.nrdcaixa = crapbcx.nrdcaixa  AND
                           craplot.cdopecxa = crapbcx.cdopecxa  AND
                           craplot.tplotmov = 32                NO-LOCK:
                           
        FOR EACH  craplcs WHERE craplcs.cdcooper = craplot.cdcooper   AND
                                craplcs.dtmvtolt = craplot.dtmvtolt   AND
                                craplcs.cdagenci = craplot.cdagenci   AND
                                craplcs.cdhistor = 561 /* Cta. Sal */ AND
                                craplcs.nrdolote = craplot.nrdolote   NO-LOCK,
            FIRST crapccs WHERE crapccs.cdcooper = craplcs.cdcooper   AND
                                crapccs.nrdconta = craplcs.nrdconta   NO-LOCK
                                BREAK BY crapccs.cdempres:
            
                   /* Total da empresa */
            ASSIGN aux_qtlanmto = aux_qtlanmto + 1
                   aux_vllanmto = aux_vllanmto + craplcs.vllanmto
                   
                   /* Total do historico */
                   aux_vlrttctb = aux_vlrttctb + craplcs.vllanmto
                   aux_qtrttctb = aux_qtrttctb + 1
                    
                   /* Total de creditos */
                   aux_vlrttcrd = aux_vlrttcrd + craplcs.vllanmto. 
                   
            IF   LAST-OF(crapccs.cdempres)   THEN
                 DO:
                     CREATE w_empresa.
                     ASSIGN w_empresa.cdempres = crapccs.cdempres
                            w_empresa.qtlanmto = aux_qtlanmto
                            w_empresa.vllanmto = aux_vllanmto.
                            
                     ASSIGN aux_qtlanmto = 0
                            aux_vllanmto = 0.
                 END.
        END.    
    END.
    
END PROCEDURE.

/* .......................................................................... */

