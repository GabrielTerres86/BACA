/* ............................................................................

   Programa: Fontes/concbb.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Agosto/2004                         Ultima alteracao: 28/08/2013

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Conciliacao Correspondente Bancario

   Alteracoes:  23/03/2005 - Inclusao opcao "D" - Carta Restituicao Credito 
                             Banco Brasil(Mirtes)
                             
                12/12/2005 - Tratar tipo docto 3 - Recebto INSS(Mirtes)

                26/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
                
                09/10/2006 - Efetuado acerto na inicializacao das variaveis
                             "tel_qtinss" e "tel_vlinss" na consulta (Diego).
                 
                14/04/2009 - Adicionado campo "finalizado" - crapcbb.flgrgatv 
                             (Fernando).
                             
                11/08/2011 - Adaptado para uso de BO (Gabriel Capoia - DB1)
                
                24/05/2012 - Inclusão de tratamento para DELETE de handle preso
                             BO b1wgen0108.p (Lucas R.)
                
                28/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).             
............................................................................ */
{ sistema/generico/includes/b1wgen0108tt.i }
{ sistema/generico/includes/var_internet.i }
{ includes/var_online.i }

DEF        VAR tel_dtmvtolt AS DATE   FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR tel_cdagenci AS INT    FORMAT "zz9"                   NO-UNDO.
DEF        VAR tel_nrdcaixa LIKE      crapcbb.nrdcaixa               NO-UNDO.
DEF        VAR tel_qttitrec AS DECI   FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_vltitrec AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_qttitliq AS DECI   FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_vltitliq AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_qttitcan AS DECI   FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_vltitcan AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_qtfatrec AS DECI   FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_vlfatrec AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_qtfatliq AS DECI   FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_vlfatliq AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_qtinss   AS DECI   FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_vlinss   AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_qtfatcan AS DECI   FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_vlfatcan AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_qtdinhei AS DECI   FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_vldinhei AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_qtcheque AS DECI   FORMAT "zzz,zz9"               NO-UNDO.
DEF        VAR tel_vlcheque AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.

DEF        VAR tel_valorpag AS DECI   FORMAT "zzz,zzz,zz9.99"        NO-UNDO.
DEF        VAR tel_inss     AS LOG    FORMAT "SIM/NAO"               NO-UNDO.

DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.
DEF        VAR r-registro   AS ROWID                                 NO-UNDO.
DEF        VAR h-b1wgen0108 AS HANDLE                                NO-UNDO.
DEF        VAR aux_qtregist AS INTE                                  NO-UNDO.


FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                   HELP "Informe a opcao desejada (C, D, R, V ou T)."
                   VALIDATE(CAN-DO("C,D,R,V,T",glb_cddopcao),
                                 "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_concbb.

FORM tel_dtmvtolt AT 1 LABEL "Referencia" 
                       HELP "Entre com a data de referencia do movimento."
     tel_cdagenci      LABEL "    PA"
                 HELP "Entre com o numero do PA ou 0 para todos os PA's."
     tel_nrdcaixa      LABEL "Caixa"
                 HELP "Entre com o numero do Caixa  ou 0 para todos os Caixa"
     tel_valorpag      LABEL "Valor"
                 HELP "Entre com o valor do documento"
     tel_inss          LABEL "INSS"
     WITH ROW 6 COLUMN 20 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere_d.

FORM tel_dtmvtolt AT 1 LABEL "Referencia" 
                       HELP "Entre com a data de referencia do movimento."
     tel_cdagenci      LABEL "    PA"
                 HELP "Entre com o numero do PA ou 0 para todos os PA's."
     tel_nrdcaixa      LABEL "Caixa"
                 HELP "Entre com o numero do Caixa  ou 0 para todos os Caixa"
     tel_inss          LABEL "INSS"
     WITH ROW 6 COLUMN 20 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere.

FORM "Qtd.               Valor" AT 36 
     SKIP
     tel_qttitrec AT 12 FORMAT "zzz,zz9" LABEL  "Titulos  Recebidos"
     tel_vltitrec AT 46 FORMAT "zzzzzz,zzz,zz9.99" NO-LABEL

     tel_qttitliq AT 12 FORMAT "zzz,zz9-" LABEL "Titulos Liquidados"
     tel_vltitliq AT 46 FORMAT "zzzzzz,zzz,zz9.99-" NO-LABEL
     
     tel_qttitcan AT 12 FORMAT "zzz,zz9-" LABEL "Titulos Cancelados"
     tel_vltitcan AT 46 FORMAT "zzzzzz,zzz,zz9.99-" NO-LABEL
     
     tel_qtfatrec AT 12 FORMAT "zzz,zz9" LABEL  "Faturas  Recebidas"
     tel_vlfatrec AT 46 FORMAT "zzzzzz,zzz,zz9.99" NO-LABEL

     tel_qtfatliq AT 12 FORMAT "zzz,zz9-" LABEL "Faturas Liquidadas"
     tel_vlfatliq AT 46 FORMAT "zzzzzz,zzz,zz9.99-" NO-LABEL
     
     tel_qtfatcan AT 12 FORMAT "zzz,zz9-" LABEL "Faturas Canceladas"
     tel_vlfatcan AT 46 FORMAT "zzzzzz,zzz,zz9.99-" NO-LABEL
     SKIP(1)
     tel_qtinss   AT 12 FORMAT "zzz,zz9-" LABEL "Qtd.INSS          "
     tel_vlinss   AT 46 FORMAT "zzzzzz,zzz,zz9.99-" NO-LABEL
     SKIP(1)
     tel_qtdinhei AT 12 FORMAT "zzz,zz9" LABEL  "Pago  Dinheiro"             
     tel_vldinhei AT 46 FORMAT "zzzzzz,zzz,zz9.99" NO-LABEL
     tel_qtcheque AT 12 FORMAT "zzz,zz9" LABEL  "Pago    Cheque"             
     tel_vlcheque AT 46 FORMAT "zzzzzz,zzz,zz9.99" NO-LABEL
     WITH ROW 8 COLUMN 10 NO-BOX OVERLAY SIDE-LABELS FRAME f_total.

FORM "(C) - Consultar" SKIP
     "(D) - Impressao Solicitacao de Restituicao" SKIP
     "(R) - Relatorio" SKIP
     "(V) - Visualizar os lotes" SKIP
     "(T) - Tratar arquivo de conciliacao" SKIP
     WITH SIZE 50 BY 10 CENTERED OVERLAY ROW 8 
     TITLE "Escolha uma das opcoes abaixo:" FRAME f_helpopcao.
     
FORM tt-movimentos.cdbarras           LABEL "Cod. barras "
     tt-movimentos.dsdocmto   AT 69 NO-LABEL 
     SKIP
     tt-movimentos.dsdocmc7           LABEL "CMC-7       "
     tt-movimentos.valordoc   AT 55
     SKIP
     tt-movimentos.vldescto   
     tt-movimentos.valorpag   AT 50
     SKIP
     tt-movimentos.dtvencto           LABEL "Vencimento  "
     tt-movimentos.nrautdoc   AT 29   LABEL "Autent."
     tt-movimentos.flgrgatv   AT 50   LABEL "Finalizado"
     WITH ROW 17 WIDTH 76 CENTERED NO-BOX SIDE-LABELS OVERLAY
     FRAME f_dados_concbbs.

DEF QUERY q_crapcbb FOR tt-movimentos.
                                     
DEF BROWSE b_crapcbb QUERY q_crapcbb 
    DISP tt-movimentos.cdagenci COLUMN-LABEL "PA"
         tt-movimentos.nrdcaixa COLUMN-LABEL "Caixa"
         tt-movimentos.nmoperad COLUMN-LABEL "Operador"   FORMAT "x(20)"
         tt-movimentos.cdbccxlt COLUMN-LABEL "Bc/Cx"
         tt-movimentos.nrdolote COLUMN-LABEL "Lote"
         tt-movimentos.valordoc COLUMN-LABEL "Vlr.Doc   " FORMAT "zzz,zz9.99"
         tt-movimentos.valorpag COLUMN-LABEL "Vlr.Pago  " FORMAT "zzz,zz9.99"
         tt-movimentos.flgrgatv COLUMN-LABEL "Atv" FORMAT "SIM/NAO"
         WITH 5 DOWN.

DEF FRAME f_concbbs  
          SKIP(1)
          b_crapcbb  
    HELP  "Pressione <F4>ou<END> p/finalizar - ENTER(OPCAO D) p/impressao " 
          WITH NO-BOX CENTERED OVERLAY ROW 7.

ON VALUE-CHANGED OF b_crapcbb
   DO:
       DISPLAY tt-movimentos.cdbarras  tt-movimentos.dsdocmto
               tt-movimentos.dsdocmc7  tt-movimentos.valordoc
               tt-movimentos.vldescto  tt-movimentos.valorpag  
               tt-movimentos.dtvencto  tt-movimentos.flgrgatv  
               tt-movimentos.nrautdoc  WITH FRAME f_dados_concbbs.
   END.

ON RETURN OF b_crapcbb
    DO:
        IF  glb_cddopcao = "D"   THEN
            DO:
                           
                ASSIGN aux_confirma = "N".
               
                MESSAGE COLOR NORMAL "Deseja realmente selecionar este Docto?"
          
                UPDATE aux_confirma.
                                        
                IF  CAPS(aux_confirma) = "S"   THEN
                    DO:
                      
                        IF  AVAIL tt-movimentos   THEN
                            DO:
                               ASSIGN r-registro = tt-movimentos.nrdrowid.
                               RUN fontes/concbb_r.p
                                       (INPUT tel_dtmvtolt, 
                                        INPUT tel_cdagenci,
                                        INPUT tel_nrdcaixa,
                                        INPUT tel_inss,
                                        INPUT r-registro).
                            END.
                        
                    END.

                HIDE FRAME f_atencao NO-PAUSE.
                HIDE MESSAGE NO-PAUSE.
                MESSAGE "Pressione <ENTER> p/Selecionar!".                    
            END.
    END.  

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       tel_dtmvtolt = glb_dtmvtolt.


VIEW FRAME f_moldura.
PAUSE(0).
   
DO WHILE TRUE:

    RUN fontes/inicia.p.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
        VIEW FRAME f_helpopcao.
        PAUSE(0).

        UPDATE glb_cddopcao  WITH FRAME f_concbb.
       
        HIDE FRAME f_helpopcao NO-PAUSE.    
        LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.

            IF  CAPS(glb_nmdatela) <> "CONCBB"  THEN
                DO:
                    HIDE FRAME f_concbb.
                    HIDE FRAME f_total.
                    HIDE FRAME f_refere.
                    HIDE FRAME f_moldura.
                    
                    RETURN.
                END.
                

            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao THEN
        DO:
            { includes/acesso.i }
            ASSIGN aux_cddopcao = glb_cddopcao.
        END.

    IF  glb_cddopcao = "V"   THEN
        DO:
            HIDE FRAME f_refere.
            HIDE FRAME f_total.
  
            UPDATE tel_dtmvtolt 
                   tel_cdagenci 
                   tel_nrdcaixa
                   tel_inss
                   WITH FRAME f_refere.

            RUN Busca_Dados.

        END.
    ELSE
    IF  glb_cddopcao = "D"   THEN
        DO:
            HIDE FRAME f_refere.
            HIDE FRAME f_refere_d.
            HIDE FRAME f_total.
  
            ASSIGN tel_inss = NO.
            DISPLAY tel_inss WITH FRAME f_refere_d. 
            UPDATE tel_dtmvtolt 
                   tel_cdagenci 
                   tel_nrdcaixa                      
                   tel_valorpag  WITH FRAME f_refere_d.

            RUN Busca_Dados.

        END.
    ELSE
    IF  glb_cddopcao = "C"   THEN
        DO:
            ASSIGN tel_dtmvtolt = glb_dtmvtolt
                   tel_cdagenci = 0
                   tel_nrdcaixa = 0.
            
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                VIEW FRAME f_moldura.
                VIEW FRAME f_concbb.
                   
                UPDATE tel_dtmvtolt 
                       tel_cdagenci 
                       tel_nrdcaixa 
                       tel_inss WITH FRAME f_refere.

                RUN Busca_Dados.

                ASSIGN aux_confirma = "N".

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    IF  tel_qtdinhei = 0 AND  
                        tel_qtcheque = 0 AND 
                        tel_qtinss   = 0 THEN
                        LEAVE.
                                   
                    MESSAGE COLOR NORMAL
                          "Deseja listar os LOTES referentes a pesquisa(S/N)?:"
                          UPDATE aux_confirma.
     
                    LEAVE.
                         
                END. /* fim do DO WHILE */
                            
                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
                    aux_confirma <> "S" THEN
                    NEXT.

                ASSIGN r-registro = ?.
                RUN fontes/concbb_r.p (INPUT tel_dtmvtolt, 
                                       INPUT tel_cdagenci, 
                                       INPUT tel_nrdcaixa,
                                       INPUT tel_inss,   
                                       INPUT r-registro).
            END. /*  Fim do DO WHILE TRUE  */
            
        END.
    ELSE
    IF  glb_cddopcao = "R"   THEN  /*  Relatorio  */
        DO:
            HIDE FRAME f_refere.
            HIDE FRAME f_total.

            ASSIGN tel_dtmvtolt = glb_dtmvtolt
                   tel_cdagenci = 0 
                   tel_nrdcaixa = 0.
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                VIEW FRAME f_moldura.
                VIEW FRAME f_concbb.
               
                UPDATE tel_dtmvtolt
                       tel_cdagenci 
                       tel_nrdcaixa
                       tel_inss   WITH FRAME f_refere.

                ASSIGN r-registro = ?.
              
                RUN fontes/concbb_r.p (INPUT tel_dtmvtolt, 
                                       INPUT tel_cdagenci,
                                       INPUT tel_nrdcaixa,
                                       INPUT tel_inss,
                                       INPUT r-registro).
            END.  /*  Fim do DO WHILE TRUE  */
         
        END.
    ELSE
    IF  glb_cddopcao = "T"   THEN    /* Retorno Arq.Conciliacao */
        DO:
            HIDE FRAME f_refere.
            HIDE FRAME f_total.

            ASSIGN tel_dtmvtolt = glb_dtmvtolt
                   tel_cdagenci = 0 
                   tel_nrdcaixa = 0.
                   
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
                UPDATE tel_dtmvtolt
                       tel_cdagenci 
                       tel_nrdcaixa WITH FRAME f_refere.
               
                RUN fontes/concbb_t.p ( INPUT tel_dtmvtolt,
                                        INPUT tel_cdagenci, 
                                        INPUT tel_nrdcaixa).
            END.  /*  Fim do DO WHILE TRUE  */
         
            HIDE FRAME f_refere.
        END.
        
END.  /*  Fim do DO WHILE TRUE  */

IF  VALID-HANDLE(h-b1wgen0108) THEN
    DELETE OBJECT h-b1wgen0108.
   
/* ........................................................................  */

PROCEDURE Busca_Dados:
    
    EMPTY TEMP-TABLE tt-concbb.
    EMPTY TEMP-TABLE tt-movimentos.
    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0108) THEN
        RUN sistema/generico/procedures/b1wgen0108.p
            PERSISTENT SET h-b1wgen0108.

    RUN Busca_Dados IN h-b1wgen0108
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT 0,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tel_dtmvtolt,
          INPUT tel_cdagenci,
          INPUT tel_nrdcaixa,
          INPUT tel_inss,
          INPUT tel_valorpag,
          INPUT 999999999,
          INPUT 1,
          INPUT YES,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-concbb,
         OUTPUT TABLE tt-movimentos,
         OUTPUT TABLE tt-erro).
    
    IF  VALID-HANDLE(h-b1wgen0108) THEN
        DELETE PROCEDURE h-b1wgen0108.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.
                   
            RETURN "NOK".  
        END.

    IF  glb_cddopcao = "C" THEN
        DO:
            FIND FIRST tt-concbb NO-ERROR.

            IF  AVAIL tt-concbb THEN
                ASSIGN tel_qttitrec = tt-concbb.qttitrec          
                       tel_vltitrec = tt-concbb.vltitrec
                       tel_qttitliq = tt-concbb.qttitliq
                       tel_vltitliq = tt-concbb.vltitliq
                       tel_qttitcan = tt-concbb.qttitcan
                       tel_vltitcan = tt-concbb.vltitcan
                       tel_qtfatrec = tt-concbb.qtfatrec
                       tel_vlfatrec = tt-concbb.vlfatrec
                       tel_qtfatliq = tt-concbb.qtfatliq
                       tel_vlfatliq = tt-concbb.vlfatliq
                       tel_qtinss   = tt-concbb.qtinss  
                       tel_vlinss   = tt-concbb.vlinss  
                       tel_qtfatcan = tt-concbb.qtfatcan
                       tel_vlfatcan = tt-concbb.vlfatcan
                       tel_qtdinhei = tt-concbb.qtdinhei
                       tel_vldinhei = tt-concbb.vldinhei
                       tel_qtcheque = tt-concbb.qtcheque
                       tel_vlcheque = tt-concbb.vlcheque.
            ELSE
                ASSIGN tel_qttitrec = 0        
                       tel_vltitrec = 0
                       tel_qttitliq = 0
                       tel_vltitliq = 0
                       tel_qttitcan = 0
                       tel_vltitcan = 0
                       tel_qtfatrec = 0
                       tel_vlfatrec = 0
                       tel_qtfatliq = 0
                       tel_vlfatliq = 0
                       tel_qtinss   = 0
                       tel_vlinss   = 0
                       tel_qtfatcan = 0
                       tel_vlfatcan = 0
                       tel_qtdinhei = 0
                       tel_vldinhei = 0
                       tel_qtcheque = 0
                       tel_vlcheque = 0.

            DISPLAY tel_qttitrec tel_vltitrec tel_qttitliq tel_vltitliq
                    tel_qttitcan tel_vltitcan tel_qtfatrec tel_vlfatrec
                    tel_qtfatliq tel_vlfatliq tel_qtinss   tel_vlinss
                    tel_qtfatcan tel_vlfatcan tel_qtdinhei tel_vldinhei 
                    tel_qtcheque tel_vlcheque WITH FRAME f_total.
            
        END.
    ELSE
        IF  CAN-DO("V,D",glb_cddopcao) THEN
            DO:
                OPEN QUERY q_crapcbb FOR EACH tt-movimentos NO-LOCK.

                ENABLE b_crapcbb WITH FRAME f_concbbs.
    
                IF  AVAILABLE tt-movimentos THEN
                    DO:
                        DISPLAY tt-movimentos.cdbarras  tt-movimentos.dsdocmto
                                tt-movimentos.dsdocmc7  tt-movimentos.valordoc
                                tt-movimentos.vldescto  tt-movimentos.valorpag
                                tt-movimentos.dtvencto  tt-movimentos.flgrgatv
                                tt-movimentos.nrautdoc  
                                WITH FRAME f_dados_concbbs.
                    END.


                WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
           
                HIDE FRAME f_concbbs.
                HIDE FRAME f_dados_concbbs.
                 
                HIDE MESSAGE NO-PAUSE.
            END.

    RETURN "OK".

END PROCEDURE. /* Busca_Dados */

/* ....................................................................... */
