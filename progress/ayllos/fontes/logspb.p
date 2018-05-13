/*..............................................................................

   Programa: Fontes/logspb.p
   Sistema : Conta-Corrente - Cooperativa de Credito 
   Sigla   : CRED
   Autor   : Gabriel
   Data    : Junho/2008.                       Ultima Atualizacao: 09/11/2015
            
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela LOGSPB.
               Visualizacao log das transacoes SPB.

   Alteracoes: 03/11/2009 - Implementacao de melhorias solicitadas (David).
   
               26/04/2010 - Mostrar conta do remetente no browse de mensagens
                            processadas (David).
                            
               26/06/2010 - Ajustar FORMs para receber contas de destino e de
                            origem com tipo alfanumerico (Fernando).
                            
               16/07/2010 - Incluido no log as transacoes rejeitadas (Elton).
               
               19/10/2010 - Incluido informacao de totais de resultados e
                            valores. (Henrique)
                            
               16/04/2012 - Adicionado os campos "Conta/dv" e "Origem".
                            Alterado os campos "Tipo" e "Situacao", para as
                            respectivas descricoes dos itens de cada campo.
                            (Fabricio)
               
               31/07/2012 - Inclusão de novos campos no browse.
                            campos: cdagenci, nrdcaixa, cdoperad.(Lucas R).
               
               14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).
                            
               20/12/2013 - Criada opcao "M" para TEDs migradas 
                            ACREDI >> VIACREDI (Fabricio).
                            
               29/05/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).
                            
               17/11/2014 - Ajuste para a Incormporação da Concredi e Credmilsul 
                            (Vanessa)
                            
               14/04/2015 - Alteração na tela para incluir o campo ISPB no detalhe
                            das mensagens Recebidas e Enviadas SD271603 FDR041 (Vanessa)
                            
               04/08/2015 - Ajustes referentes a Melhoria 85 Gestão de TEDs/TECs 
                            (Lucas Ranghetti)

               18/09/2015 - Adicionado as TEDs migradas VIACREDI >> ALTO VALE 
                           no filtro da opcao "M" (Douglas - Chamado 288683).
                           
               09/11/2015 - Adicionado parametro de entrada inestcri em proc.
                            obtem-log-spb, fixado com 0 ("Não") no ayllos caracter.
                            (Jorge/Andrino)             
.............................................................................*/

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0050tt.i }
  
DEF STREAM str_1.

DEF VAR tel_dtmvtlog AS DATE FORMAT "99/99/9999"                       NO-UNDO.

DEF VAR tel_numedlog AS CHAR FORMAT "x(14)"
               VIEW-AS COMBO-BOX LIST-ITEMS "ENVIADAS",
                                            "RECEBIDAS",
                                            "LOG",
                                            "TODOS"
                                            PFCOLOR 2                NO-UNDO.

DEF VAR tel_lgvisual AS CHAR                 FORMAT "!(1)"             NO-UNDO.
DEF VAR tel_dsimprim AS CHAR INIT "Imprimir" FORMAT "x(8)"             NO-UNDO.
DEF VAR tel_dscancel AS CHAR INIT "Cancelar" FORMAT "x(8)"             NO-UNDO.
DEF VAR tel_cdsitlog AS CHAR FORMAT "x(11)"
               VIEW-AS COMBO-BOX LIST-ITEMS "PROCESSADAS",
                                            "DEVOLVIDAS",
                                            "REJEITADAS",
                                            "TODOS"
                                            PFCOLOR 2                  NO-UNDO.
DEF VAR tel_nrdconta AS INTE FORMAT "zzzz,zzz,9"                       NO-UNDO.
DEF VAR tel_cdorigem AS CHAR FORMAT "x(12)"
               VIEW-AS COMBO-BOX LIST-ITEMS "AYLLOS",
                                            "CAIXA ONLINE",
                                            "INTERNET",
                                            "TODOS"
                                            PFCOLOR 2                  NO-UNDO.
DEF VAR tel_dsmotivo AS CHAR EXTENT 2                                  NO-UNDO.

DEF VAR tel_flgidlog AS LOGI FORMAT "BANCOOB/CECRED"                   NO-UNDO.
DEF VAR tel_vlrdated AS DECIMAL FORMAT "zzz,zzz,zz9.99"                NO-UNDO.
                                                                 
DEF VAR aux_pontilha AS CHAR                                           NO-UNDO.
DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                           NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                           NO-UNDO.
DEF VAR aux_dstitcab AS CHAR                                           NO-UNDO.
DEF VAR aux_dslinlog AS CHAR                                           NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                           NO-UNDO.
DEF VAR aux_dseditor AS CHAR VIEW-AS EDITOR SIZE 270 BY 15 PFCOLOR 0   NO-UNDO.

DEF VAR aux_flgescra AS LOGI                                           NO-UNDO.
DEF VAR aux_flgfirst AS LOGI                                           NO-UNDO.

DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_cdcooper AS INTE                                           NO-UNDO.

DEF VAR par_flgcance AS LOGI                                           NO-UNDO.
DEF VAR par_flgrodar AS LOGI INIT TRUE                                 NO-UNDO.
DEF VAR par_flgfirst AS LOGI INIT TRUE                                 NO-UNDO.

DEF VAR rel_nrmodulo AS INTE FORMAT "9"                                NO-UNDO.
  
DEF VAR rel_nmempres AS CHAR FORMAT "x(15)"                            NO-UNDO.
DEF VAR rel_nmrelato AS CHAR FORMAT "x(40)" EXTENT 5                   NO-UNDO.
DEF VAR rel_nmmodulo AS CHAR FORMAT "x(15)" EXTENT 5
                             INIT ["DEP. A VISTA   ","CAPITAL        ",
                                   "EMPRESTIMOS    ","DIGITACAO      ",
                                   "GENERICO       "]                  NO-UNDO.

DEF VAR tel_cdcooper  AS CHAR FORMAT "x(12)" VIEW-AS COMBO-BOX   
                              INNER-LINES 5 NO-UNDO.
  
DEF VAR h-b1wgen0050 AS HANDLE                                         NO-UNDO.

DEF VAR tel_qtdtotal   AS INT  FORMAT ">>>,>>9"                        NO-UNDO.
DEF VAR tel_vlrtotal   AS DEC  FORMAT "zzz,zzz,zzz,zz9.99"             NO-UNDO.
DEF VAR aux_num_result AS INT                                          NO-UNDO.

DEF VAR aux_numedlog   AS INTE                                         NO-UNDO.
DEF VAR aux_cdsitlog   AS CHAR                                         NO-UNDO.
DEF VAR aux_cdorigem   AS INTE                                         NO-UNDO.

DEF VAR aux_nmarqpdf   AS CHAR                                         NO-UNDO.
DEF VAR aux_cdisprem   AS CHAR FORMAT "99999999"                       NO-UNDO.
DEF VAR aux_cdispdst   AS CHAR FORMAT "99999999"                       NO-UNDO.

DEF QUERY q-log-enviada-ok   FOR tt-logspb-detalhe.
DEF QUERY q-log-recebida-ok  FOR tt-logspb-detalhe.
DEF QUERY q-log-enviada-nok  FOR tt-logspb-detalhe.
DEF QUERY q-log-recebida-nok FOR tt-logspb-detalhe.
DEF QUERY q-log-todos        FOR tt-logspb-detalhe.

DEF QUERY q-log-rejeitada-ok FOR tt-logspb-detalhe. 

DEF BROWSE b-log-enviada-ok QUERY q-log-enviada-ok
    DISP tt-logspb-detalhe.hrtransa LABEL "Hora"      FORMAT "x(8)" 
         tt-logspb-detalhe.nrctarem LABEL "Conta/dv"  FORMAT "xxxxxxx.xxx.xxx-x"
         tt-logspb-detalhe.dsnomrem LABEL "Nome"      FORMAT "x(30)"
         tt-logspb-detalhe.vltransa LABEL "Valor"     FORMAT "zzz,zzz,zz9.99" 
         tt-logspb-detalhe.dsorigem LABEL "Origem"    FORMAT "x(12)"
         tt-logspb-detalhe.cdagenci LABEL "PA"       FORMAT "zz9"
         tt-logspb-detalhe.nrdcaixa LABEL "Caixa"     FORMAT "zz9"
         tt-logspb-detalhe.cdoperad LABEL "Operador"  FORMAT "X(10)"

         WITH 8 DOWN NO-BOX WIDTH 75 CENTERED SCROLLBAR-VERTICAL.

DEF BROWSE b-log-recebida-ok QUERY q-log-recebida-ok
    DISP tt-logspb-detalhe.hrtransa LABEL "Hora"     FORMAT "x(8)" 
         tt-logspb-detalhe.nrctadst LABEL "Conta/dv" FORMAT "xxxxxxx.xxx.xxx-x"
         tt-logspb-detalhe.dsnomrem LABEL "Nome"     FORMAT "x(30)"
         tt-logspb-detalhe.vltransa LABEL "Valor"    FORMAT "zzz,zzz,zz9.99" 
         tt-logspb-detalhe.dsorigem LABEL "Origem"   FORMAT "x(12)"
         tt-logspb-detalhe.cdagenci LABEL "PA"      FORMAT "zz9"
         tt-logspb-detalhe.nrdcaixa LABEL "Caixa"    FORMAT "zz9"
         tt-logspb-detalhe.cdoperad LABEL "Operador" FORMAT "X(10)"
         WITH 8 DOWN NO-BOX WIDTH 75 CENTERED SCROLLBAR-VERTICAL.

DEF BROWSE b-log-enviada-nok QUERY q-log-enviada-nok
    DISP tt-logspb-detalhe.hrtransa LABEL "Hora"     FORMAT "x(8)" 
         tt-logspb-detalhe.nrctarem LABEL "Conta/dv" FORMAT "xxxxxxx.xxx.xxx-x"
         tt-logspb-detalhe.cdbandst LABEL "Banco"    FORMAT "zz9" 
         tt-logspb-detalhe.cdagedst LABEL "Agencia"  FORMAT "zzz9"
         tt-logspb-detalhe.nrctadst LABEL "Conta/dv" FORMAT "xxxxxxx.xxx.xxx-x"
         tt-logspb-detalhe.vltransa LABEL "Valor"    FORMAT "zzz,zzz,zz9.99" 
         tt-logspb-detalhe.dsorigem LABEL "Origem"   FORMAT "x(12)"
         tt-logspb-detalhe.cdagenci LABEL "PA"       FORMAT "zz9"
         tt-logspb-detalhe.nrdcaixa LABEL "Caixa"    FORMAT "zz9"
         tt-logspb-detalhe.cdoperad LABEL "Operador" FORMAT "X(10)"
         WITH 8 DOWN NO-BOX WIDTH 75 CENTERED SCROLLBAR-VERTICAL.

DEF BROWSE b-log-recebida-nok QUERY q-log-recebida-nok
    DISP tt-logspb-detalhe.hrtransa LABEL "Hora"     FORMAT "x(8)"
         tt-logspb-detalhe.cdbanrem LABEL "Banco"    FORMAT "zz9"
         tt-logspb-detalhe.cdagerem LABEL "Agencia"  FORMAT "zzz9"
         tt-logspb-detalhe.nrctarem LABEL "Conta/dv" FORMAT "xxxxxxx.xxx.xxx-x"
         tt-logspb-detalhe.nrctadst LABEL "Conta/dv" FORMAT "xxxxxxx.xxx.xxx-x"
         tt-logspb-detalhe.vltransa LABEL "Valor"    FORMAT "zzz,zzz,zz9.99" 
         tt-logspb-detalhe.dsorigem LABEL "Origem"   FORMAT "x(12)"
         tt-logspb-detalhe.cdagenci LABEL "PA"       FORMAT "zz9"
         tt-logspb-detalhe.nrdcaixa LABEL "Caixa"    FORMAT "zz9"
         tt-logspb-detalhe.cdoperad LABEL "Operador" FORMAT "X(10)"
         WITH 8 DOWN NO-BOX WIDTH 75 CENTERED SCROLLBAR-VERTICAL.

DEF BROWSE b-log-rejeitada-ok QUERY q-log-rejeitada-ok
    DISP tt-logspb-detalhe.hrtransa LABEL "Hora"     FORMAT "x(8)" 
         tt-logspb-detalhe.nrctarem LABEL "Conta/dv" FORMAT "xxxxxxx.xxx.xxx-x"
         tt-logspb-detalhe.cdbandst LABEL "Banco"    FORMAT "zz9"
         tt-logspb-detalhe.cdagedst LABEL "Agencia"  FORMAT "zzz9"
         tt-logspb-detalhe.nrctadst LABEL "Conta/dv" FORMAT "xxxxxxx.xxx.xxx-x"
         tt-logspb-detalhe.vltransa LABEL "Valor"    FORMAT "zzz,zzz,zz9.99" 
         tt-logspb-detalhe.dsorigem LABEL "Origem"   FORMAT "x(12)"
         tt-logspb-detalhe.cdagenci LABEL "PA"       FORMAT "zz9"
         tt-logspb-detalhe.nrdcaixa LABEL "Caixa"    FORMAT "zz9"
         tt-logspb-detalhe.cdoperad LABEL "Operador" FORMAT "X(10)"
         WITH 8 DOWN NO-BOX WIDTH 75 CENTERED SCROLLBAR-VERTICAL.

DEF BROWSE b-log-todos QUERY q-log-todos
    DISP tt-logspb-detalhe.hrtransa LABEL "Hora"     FORMAT "x(8)" 
         tt-logspb-detalhe.nrctarem LABEL "Conta/dv" FORMAT "xxxxxxx.xxx.xxx-x"
         tt-logspb-detalhe.cdbandst LABEL "Banco"    FORMAT "zz9"
         tt-logspb-detalhe.cdagedst LABEL "Agencia"  FORMAT "zzz9"
         tt-logspb-detalhe.nrctadst LABEL "Conta/dv" FORMAT "xxxxxxx.xxx.xxx-x"
         tt-logspb-detalhe.vltransa LABEL "Valor"    FORMAT "zzz,zzz,zz9.99" 
         tt-logspb-detalhe.dsorigem LABEL "Origem"   FORMAT "x(12)"
         tt-logspb-detalhe.cdagenci LABEL "PA"       FORMAT "zz9"
         tt-logspb-detalhe.nrdcaixa LABEL "Caixa"    FORMAT "zz9"
         tt-logspb-detalhe.cdoperad LABEL "Operador" FORMAT "X(10)"
         WITH 8 DOWN NO-BOX WIDTH 75 CENTERED SCROLLBAR-VERTICAL.
                          
FORM WITH ROW 4 OVERLAY SIZE 80 BY 18 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 03 LABEL "Opcao"       AUTO-RETURN
        HELP "Informe a opcao desejada (L,R)" 
     tel_flgidlog AT 14 LABEL "Log"         AUTO-RETURN
        HELP "Informe o log a ser listado (B - BANCOOB / C - CECRED)."
     tel_dtmvtlog AT 29 LABEL "Data do Log" AUTO-RETURN
        HELP "Informe a data de referencia."
     tel_numedlog AT 55 LABEL "Tipo"        AUTO-RETURN
        HELP "Informe o tipo de log."
     SKIP
     tel_cdsitlog AT 03 LABEL "Situacao"    AUTO-RETURN
        HELP "Informe a situacao."
     tel_nrdconta AT 29 LABEL "Conta/dv"    AUTO-RETURN
        HELP "Informe o numero da conta/dv."
     tel_cdorigem AT 55 LABEL "Origem"      AUTO-RETURN
        HELP "Informe a origem."
     tel_vlrdated AT 03 LABEL "Valor"       AUTO-RETURN
        HELP "Informe o Valor"
     WITH ROW 6 COL 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM glb_cddopcao AT 03 LABEL "Opcao"       AUTO-RETURN
        HELP "Informe a opcao desejada (L,R)" 
     tel_dtmvtlog AT 29 LABEL "Data do Log" AUTO-RETURN
        HELP "Informe a data de referencia."
    WITH ROW 6 COL 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao_r.

FORM glb_cddopcao AT 03 LABEL "Opcao"       AUTO-RETURN
      HELP "Informe a opcao desejada (L,R,M)"  
     tel_dtmvtlog AT 29 LABEL "Data do Log" AUTO-RETURN
        HELP "Informe a data de referencia."
     tel_cdcooper AT 03 LABEL "Cooperativa"      AUTO-RETURN
        HELP "Informe a origem."
     WITH ROW 6 COL 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao_m.

FORM SKIP(1)
     b-log-enviada-ok 
     HELP "<ENTER> p/ detalhes, <SETAS> p/ outras inf. ou <END> p/ voltar."
     WITH ROW 6 NO-BOX CENTERED WIDTH 78 OVERLAY FRAME f_log_enviada_ok.

FORM SKIP(1)
     b-log-recebida-ok 
     HELP "<ENTER> p/ detalhes, <SETAS> p/ outras inf. ou <END> p/ voltar."
     WITH ROW 8 NO-BOX CENTERED WIDTH 78 OVERLAY FRAME f_log_recebida_ok.

FORM SKIP(1)
     b-log-enviada-nok 
     HELP "<ENTER> p/ detalhes, <SETAS> p/ outras inf. ou <END> p/ voltar."
     WITH ROW 8 NO-BOX CENTERED WIDTH 78 OVERLAY FRAME f_log_enviada_nok.

FORM SKIP(1)
     b-log-recebida-nok
     HELP "<ENTER> p/ detalhes, <SETAS> p/ outras inf. ou <END> p/ voltar."
     WITH ROW 8 NO-BOX CENTERED WIDTH 78 OVERLAY FRAME f_log_recebida_nok.

FORM SKIP(1)
     b-log-rejeitada-ok
     HELP "<ENTER> p/ detalhes, <SETAS> p/ outras inf. ou <END> p/ voltar."
     WITH ROW 8 NO-BOX CENTERED WIDTH 78 OVERLAY FRAME f_log_rejeitada_ok.
     
FORM SKIP(1)
     b-log-todos    
     HELP "<ENTER> p/ detalhes, <SETAS> p/ outras inf. ou <END> p/ voltar."
     WITH ROW 8 NO-BOX CENTERED WIDTH 78 OVERLAY FRAME f_log_todos.

FORM "    REMETENTE               DESTINATARIO" SKIP
     "----------------- --------------------------------"
     WITH ROW 8 COL 13 NO-BOX OVERLAY FRAME f_cabec_enviada.

FORM "           REMETENTE               DESTINATARIO"
     "------------------------------- ------------------"
     WITH ROW 8 COL 13 NO-BOX OVERLAY FRAME f_cabec_recebida.

FORM SKIP
     "VALOR   :"                AT 03 
     tt-logspb-detalhe.vltransa AT 13 NO-LABEL FORMAT "zzz,zzz,zz9.99"
     SKIP 
     tel_dsmotivo[1]            AT 03 NO-LABEL FORMAT "x(74)"
     SKIP
     tel_dsmotivo[2]            AT 13 NO-LABEL FORMAT "x(20)"
     SKIP(1)
     "REMETENTE"                AT 17
     "DESTINATARIO"             AT 54
     SKIP
     aux_pontilha               AT 03 NO-LABEL FORMAT "x(74)"
     SKIP
     "Banco   :"                AT 03 
     tt-logspb-detalhe.cdbanrem AT 28 NO-LABEL FORMAT "zz9"
     "Banco   :"                AT 42
     tt-logspb-detalhe.cdbandst AT 67 NO-LABEL FORMAT "zz9"
     SKIP
     
     "ISPB    :"                AT 03 
     aux_cdisprem AT 24 NO-LABEL FORMAT "99999999"
     "ISPB    :"                AT 42
     aux_cdispdst AT 62 NO-LABEL FORMAT "99999999"
     SKIP
    
     
     "Agencia :"                AT 03
     tt-logspb-detalhe.cdagerem AT 27 NO-LABEL FORMAT "zzz9"
     "Agencia :"                AT 42
     tt-logspb-detalhe.cdagedst AT 66 NO-LABEL FORMAT "zzz9"
     SKIP
     "Conta/dv:"                AT 03
     tt-logspb-detalhe.nrctarem AT 13 NO-LABEL FORMAT "xxxxxxx.xxx.xxx-x"
     "Conta/dv:"                AT 42
     tt-logspb-detalhe.nrctadst AT 52 NO-LABEL FORMAT "xxxxxxx.xxx.xxx-x"
     SKIP
     "CPF/CNPJ:"                AT 03
     tt-logspb-detalhe.dscpfrem AT 17 NO-LABEL FORMAT "99999999999999"
     "CPF/CNPJ:"                AT 42
     tt-logspb-detalhe.dscpfdst AT 56 NO-LABEL FORMAT "99999999999999"
     SKIP
     "Nome    :"                AT 03
     tt-logspb-detalhe.dsnomrem AT 13 NO-LABEL FORMAT "x(27)"
     "Nome    :"                AT 42
     tt-logspb-detalhe.dsnomdst AT 52 NO-LABEL FORMAT "x(27)"
     SKIP(1)
     WITH ROW 7 NO-BOX SIDE-LABELS NO-LABEL CENTERED WIDTH 78 OVERLAY 
          FRAME f_detalhes.

FORM tel_qtdtotal       FORMAT "zz,zz9"          LABEL "Quantidade Total"
     tel_vlrtotal AT 34 FORMAT "zzz,zzz,zz9.99"  LABEL "Valor Total"
     WITH ROW 20 COLUMN 10 SIDE-LABELS OVERLAY NO-BOX FRAME f_total.
               
DEF FRAME f_editor
    aux_dseditor HELP "Pressione <END>/<F4> para finalizar" 
    WITH SIZE 78 BY 15 ROW 6 COL 2 USE-TEXT NO-BOX NO-LABELS OVERLAY.

ON LEAVE OF tel_flgidlog IN FRAME f_opcao DO:
    
    IF  INPUT tel_flgidlog  THEN  /** LOG BANCOOB **/ 
    DO:
        tel_numedlog:LIST-ITEMS = "TODOS,SUCESSO,ERRO".
        tel_numedlog:SCREEN-VALUE = "TODOS".

        tel_numedlog:HELP IN FRAME f_opcao = "Informe o tipo de log.".
    END.   
    ELSE                         /** LOG CECRED   **/
    DO:
        tel_numedlog:LIST-ITEMS = "ENVIADAS,RECEBIDAS,LOG,TODOS".
        tel_numedlog:SCREEN-VALUE = "ENVIADAS".

        tel_numedlog:HELP IN FRAME f_opcao = "Informe o tipo de log.".
    END.
                   
END.

ON RETURN OF b-log-enviada-ok DO:

    ASSIGN tel_dsmotivo[1] = "DETALHES: " + 
                             tt-logspb-detalhe.dsmotivo
           tel_dsmotivo[2] = "".

    RUN mostra-detalhes.    

END.
                                                                         
ON ENTRY OF b-log-enviada-ok DO:

    ASSIGN tel_vlrtotal = 0
           tel_qtdtotal = 0.

    FOR EACH tt-logspb-detalhe:
        ASSIGN tel_vlrtotal = tel_vlrtotal + tt-logspb-detalhe.vltransa
               tel_qtdtotal = tel_qtdtotal + 1.
    END.

    DISPLAY tel_qtdtotal tel_vlrtotal WITH FRAME f_total. 

END.

ON RETURN OF b-log-recebida-ok DO:

    ASSIGN tel_dsmotivo[1] = "DETALHES:"
           tel_dsmotivo[2] = "".

    RUN mostra-detalhes.    

END.

ON ENTRY OF b-log-recebida-ok DO:

    ASSIGN tel_vlrtotal = 0
           tel_qtdtotal = 0.

    FOR EACH tt-logspb-detalhe:
        ASSIGN tel_vlrtotal = tel_vlrtotal + tt-logspb-detalhe.vltransa
               tel_qtdtotal = tel_qtdtotal + 1.
    END.
        
    DISPLAY tel_qtdtotal tel_vlrtotal WITH FRAME f_total. 
    
END.
             
ON RETURN OF b-log-enviada-nok DO:

    ASSIGN tel_dsmotivo[1] = "MOTIVO  : " + 
                             SUBSTR(tt-logspb-detalhe.dsmotivo,1,64)
           tel_dsmotivo[2] = SUBSTR(tt-logspb-detalhe.dsmotivo,65).

    RUN mostra-detalhes.
    
END.

ON ENTRY OF b-log-enviada-nok DO:

    ASSIGN tel_vlrtotal = 0
           tel_qtdtotal = 0.

    FOR EACH tt-logspb-detalhe:
        ASSIGN tel_vlrtotal = tel_vlrtotal + tt-logspb-detalhe.vltransa
               tel_qtdtotal = tel_qtdtotal + 1.        
    END.
    
    DISPLAY tel_qtdtotal tel_vlrtotal WITH FRAME f_total. 

END.

ON RETURN OF b-log-recebida-nok DO:

    ASSIGN tel_dsmotivo[1] = "MOTIVO  : " + 
                             SUBSTR(tt-logspb-detalhe.dsmotivo,1,64)
           tel_dsmotivo[2] = SUBSTR(tt-logspb-detalhe.dsmotivo,65).

    RUN mostra-detalhes.
    
END.

ON ENTRY OF b-log-recebida-nok DO:

    ASSIGN tel_vlrtotal = 0
           tel_qtdtotal = 0.

    FOR EACH tt-logspb-detalhe:
        ASSIGN tel_vlrtotal = tel_vlrtotal + tt-logspb-detalhe.vltransa
               tel_qtdtotal = tel_qtdtotal + 1.
    END.

    DISPLAY tel_qtdtotal tel_vlrtotal WITH FRAME f_total. 

END.
               
ON RETURN OF b-log-rejeitada-ok DO:

    ASSIGN tel_dsmotivo[1] = "MOTIVO  : " + 
                             SUBSTR(tt-logspb-detalhe.dsmotivo,1,64)
           tel_dsmotivo[2] = SUBSTR(tt-logspb-detalhe.dsmotivo,65).

    RUN mostra-detalhes.
    
END.

ON ENTRY OF b-log-rejeitada-ok DO:

    ASSIGN tel_vlrtotal = 0
           tel_qtdtotal = 0.

    FOR EACH tt-logspb-detalhe:
        ASSIGN tel_vlrtotal = tel_vlrtotal + tt-logspb-detalhe.vltransa
               tel_qtdtotal = tel_qtdtotal + 1.
    END.
    
    DISPLAY tel_qtdtotal tel_vlrtotal WITH FRAME f_total. 

END.

ON RETURN OF b-log-todos DO:

    IF  tt-logspb-detalhe.dstransa = "ENVIADA OK" OR
        tt-logspb-detalhe.dstransa = "RECEBIDA OK" THEN
        ASSIGN tel_dsmotivo[1] = "DETALHES:"
               tel_dsmotivo[2] = "".
    ELSE
        ASSIGN tel_dsmotivo[1] = "MOTIVO  : " + 
                                 SUBSTR(tt-logspb-detalhe.dsmotivo,1,64)
               tel_dsmotivo[2] = SUBSTR(tt-logspb-detalhe.dsmotivo,65).
               
    RUN mostra-detalhes.
    
END.

ON ENTRY OF b-log-todos DO:

    ASSIGN tel_vlrtotal = 0
           tel_qtdtotal = 0.

    FOR EACH tt-logspb-detalhe:
        ASSIGN tel_vlrtotal = tel_vlrtotal + tt-logspb-detalhe.vltransa
               tel_qtdtotal = tel_qtdtotal + 1.
    END.
    
    DISPLAY tel_qtdtotal tel_vlrtotal WITH FRAME f_total. 

END.

ON RETURN OF tel_numedlog DO:
    
    IF INPUT tel_flgidlog OR tel_numedlog:SCREEN-VALUE = "LOG" THEN
        APPLY "F1".
    ELSE
        APPLY "GO".
END.

ON RETURN OF tel_cdsitlog DO:

    APPLY "TAB".
END.

ON RETURN OF tel_cdorigem DO:

    APPLY "TAB".
END.

ON RETURN OF tel_vlrdated DO:

   APPLY "GO".
END.

/*Vanessa*/
ON RETURN OF tel_cdcooper  IN FRAME f_opcao_m
  DO:
     tel_cdcooper = tel_cdcooper:SCREEN-VALUE.
     APPLY "GO".
 END.

RUN fontes/inicia.p.

VIEW FRAME f_moldura.
PAUSE(0).

INPUT THROUGH basename `tty` NO-ECHO.

IMPORT UNFORMATTED aux_nmendter.

INPUT CLOSE.

aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                      aux_nmendter.

ASSIGN glb_cddopcao    = "L"
       glb_cdrelato[1] = 538
       tel_flgidlog    = FALSE
       tel_dtmvtlog    = glb_dtmvtolt
       tel_numedlog    = ""
       tel_cdsitlog    = "PROCESSADAS"
       tel_cdorigem    = "TODOS".

DISPLAY glb_cddopcao tel_flgidlog tel_dtmvtlog tel_numedlog tel_cdsitlog 
        tel_cdorigem tel_vlrdated WITH FRAME f_opcao.
 
DO WHILE TRUE:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        IF CAN-DO("1,2,3,13,16", STRING(glb_cdcooper)) THEN
            ASSIGN glb_cddopcao:HELP IN FRAME f_opcao   = "Informe a opcao desejada (L,R,M)."
                   glb_cddopcao:HELP IN FRAME f_opcao_r = "Informe a opcao desejada (L,R,M).".

        UPDATE glb_cddopcao WITH FRAME f_opcao.
       
        IF CAN-DO("1,2,3,13,16", STRING(glb_cdcooper)) THEN
        DO:
            IF  NOT CAN-DO("L,R,M",glb_cddopcao)  THEN
                DO:
                    ASSIGN glb_cdcritic = 14.
                    RUN fontes/critic.p.
                    ASSIGN glb_cdcritic = 0.
    
                    BELL.
                    MESSAGE glb_dscritic.
    
                    NEXT-PROMPT glb_cddopcao WITH FRAME f_opcao.
                   
                    NEXT.
                END.
        END.
        ELSE
        DO:
            IF  NOT CAN-DO("L,R",glb_cddopcao)  THEN
            DO:
                ASSIGN glb_cdcritic = 14.
                RUN fontes/critic.p.
                ASSIGN glb_cdcritic = 0.
    
                BELL.
                MESSAGE glb_dscritic.
    
                NEXT-PROMPT glb_cddopcao WITH FRAME f_opcao.
                
                NEXT.
            END.
        END.

        IF  glb_cddopcao = "R"  THEN
            DO:
                HIDE FRAME f_opcao.
                HIDE FRAME f_opcao_m.
                UPDATE glb_cddopcao WITH FRAME f_opcao_r.

                ASSIGN tel_flgidlog = FALSE
                       tel_numedlog = ""
                       tel_cdsitlog = "".

                DISPLAY tel_dtmvtlog
                        WITH FRAME f_opcao_r.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_dtmvtlog WITH FRAME f_opcao_r.

                    IF  tel_dtmvtlog = ?  THEN
                        DO:
                            ASSIGN glb_cdcritic = 375.
                            RUN fontes/critic.p.
                            ASSIGN glb_cdcritic = 0.
            
                            BELL.
                            MESSAGE glb_dscritic.
            
                            NEXT.
                        END.

                    LEAVE.

                END. /** Fim do DO WHILE TRUE **/

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    NEXT.
            END.
        ELSE
            IF glb_cddopcao = "L" THEN
            DO: /*opcao "L"*/
                HIDE FRAME f_opcao_m.
                HIDE FRAME f_opcao_r.
                IF  tel_numedlog:SCREEN-VALUE = ""  THEN
                    DO:
                        ASSIGN tel_numedlog = "ENVIADAS".
                               
                        DISPLAY tel_numedlog WITH FRAME f_opcao.
                    END.

                tel_cdsitlog = "PROCESSADAS".                
                     
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:                   
                    
                    UPDATE tel_flgidlog tel_dtmvtlog tel_numedlog
                           WITH FRAME f_opcao.   
                    
                    IF  tel_numedlog:SCREEN-VALUE = "ENVIADAS" THEN
                    DO:
                        tel_cdsitlog:LIST-ITEMS = 
                                        "PROCESSADAS,DEVOLVIDAS,REJEITADAS,TODOS".
                        tel_cdsitlog:SCREEN-VALUE = "PROCESSADAS".
                    END.
                    ELSE
                    IF  tel_numedlog:SCREEN-VALUE = "RECEBIDAS" THEN
                    DO:
                        tel_cdsitlog:LIST-ITEMS = "PROCESSADAS,DEVOLVIDAS,TODOS".
                        tel_cdsitlog:SCREEN-VALUE = "PROCESSADAS".
                    END.
                    ELSE
                    IF  tel_numedlog:SCREEN-VALUE = "TODOS" THEN
                    DO:
                        tel_cdsitlog:LIST-ITEMS = 
                                        "PROCESSADAS,DEVOLVIDAS,TODOS".
                        tel_cdsitlog:SCREEN-VALUE = "PROCESSADAS".
                    END.
                    
                    IF  tel_dtmvtlog = ?  THEN
                        DO:
                            ASSIGN glb_cdcritic = 375.
                            RUN fontes/critic.p.
                            ASSIGN glb_cdcritic = 0.
            
                            BELL.
                            MESSAGE glb_dscritic.
            
                            NEXT-PROMPT tel_dtmvtlog WITH FRAME f_opcao.
                            NEXT.
                        END.                 
                    
                    IF  NOT tel_flgidlog  AND 
                        tel_numedlog:SCREEN-VALUE <> "LOG"  THEN
                        DO:
                            IF  tel_cdsitlog = ""  THEN
                                DO:
                                    ASSIGN tel_cdsitlog = "PROCESSADAS".
                
                                    DISPLAY tel_cdsitlog WITH FRAME f_opcao.
                                END.
                            
                            UPDATE tel_cdsitlog tel_nrdconta tel_cdorigem 
                                   tel_vlrdated
                                   WITH FRAME f_opcao.
                               
                            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                                NEXT.
                        END.
                    ELSE
                        DO:
                            ASSIGN tel_cdsitlog = "".

                            DISPLAY tel_cdsitlog WITH FRAME f_opcao.
                        END.

                    LEAVE.
                
                END. /** Fim do DO WHILE TRUE **/

                IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                    NEXT.
            END.
            ELSE /* opcao 'M'*/
            DO:
                HIDE FRAME f_opcao.
                HIDE FRAME f_opcao_r.
                 UPDATE glb_cddopcao WITH FRAME f_opcao_m.
                ASSIGN tel_dtmvtlog = glb_dtmvtolt.

                UPDATE tel_dtmvtlog WITH FRAME f_opcao_m.
              
                IF glb_cdcooper = 1 THEN
                    ASSIGN tel_cdcooper:LIST-ITEM-PAIRS = "ACREDI,2,CONCREDI,4".
                ELSE  IF glb_cdcooper = 3 THEN
                    ASSIGN tel_cdcooper:LIST-ITEM-PAIRS = "VIACREDI,1,ACREDI,2,CONCREDI,4,CREDMILSUL,15".
                ELSE  IF glb_cdcooper = 13 THEN
                    ASSIGN tel_cdcooper:LIST-ITEM-PAIRS = "CREDMILSUL,15".
                ELSE  IF glb_cdcooper = 16 THEN
                    ASSIGN tel_cdcooper:LIST-ITEM-PAIRS = "VIACREDI,1".
                ELSE ASSIGN aux_cdcooper = glb_cdcooper.
               
                IF glb_cdcooper = 1 OR glb_cdcooper = 3 OR glb_cdcooper = 13 OR glb_cdcooper = 16 THEN
                DO:
                    UPDATE tel_cdcooper WITH FRAME f_opcao_m.
                    ASSIGN aux_cdcooper = INT(tel_cdcooper).
                END.

                IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    NEXT.

                MESSAGE "Aguarde, buscando arquivo ...".

                RUN sistema/generico/procedures/b1wgen0050.p 
                                                   PERSISTENT SET h-b1wgen0050.

                IF NOT VALID-HANDLE(h-b1wgen0050) THEN
                DO:
                    HIDE MESSAGE NO-PAUSE.
                    BELL.
                    MESSAGE "Handle invalido para BO b1wgen0050.".
                    PAUSE 2 NO-MESSAGE.

                    NEXT.
                END.

                RUN obtem-log-teds-migradas IN h-b1wgen0050 
                                            (INPUT aux_cdcooper,
                                             INPUT glb_cdagenci,
                                             INPUT 0,
                                             INPUT tel_dtmvtlog,
                                             INPUT 1, /* idorigem */
                                            OUTPUT aux_nmarqimp,
                                            OUTPUT aux_nmarqpdf,
                                            OUTPUT TABLE tt-erro).

                DELETE PROCEDURE h-b1wgen0050.

                HIDE MESSAGE NO-PAUSE.

                IF RETURN-VALUE = "NOK" THEN
                DO:
                    FIND FIRST tt-erro NO-LOCK NO-ERROR.

                    IF AVAILABLE tt-erro THEN
                        ASSIGN glb_dscritic = tt-erro.dscritic.
                    ELSE
                        ASSIGN glb_dscritic = "Nao foi possivel concluir a " +
                                              "requisicao.".

                    BELL.
                    MESSAGE glb_dscritic.
                    PAUSE 2 NO-MESSAGE.

                    NEXT.
                END.

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    ASSIGN tel_lgvisual = "T".
                    MESSAGE "(T)erminal ou (I)mpressora: " 
                    UPDATE tel_lgvisual. 
                
                    IF NOT CAN-DO("T,I",tel_lgvisual) THEN
                    DO:
                        BELL.
                        MESSAGE "Opcao incorreta.".

                        NEXT.
                    END.

                    LEAVE.

                END. /** Fim do DO WHILE TRUE **/
            
                IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                    NEXT.
            
                IF tel_lgvisual = "T" THEN
                    RUN visualiza_log.
                ELSE
                IF tel_lgvisual = "I" THEN     
                    RUN imprime.
                
                NEXT.
            END.

        LEAVE.

    END. /** Fim do DO WHILE TRUE **/
    
    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
        DO:
            RUN fontes/novatela.p.
                       
            IF  CAPS(glb_nmdatela) <> "TAB050"  THEN
                DO:
                    HIDE FRAME f_logspb.
                    RETURN.
                END.
            ELSE
                NEXT.
        END.

    IF  aux_cddopcao <> glb_cddopcao  THEN
        DO:
            { includes/acesso.i }
            
            aux_cddopcao = glb_cddopcao.
        END.

    RUN sistema/generico/procedures/b1wgen0050.p PERSISTENT SET h-b1wgen0050.

    IF  NOT VALID-HANDLE(h-b1wgen0050)  THEN
        DO:
            BELL.
            MESSAGE "Handle invalido para BO b1wgen0050.".
            PAUSE 2 NO-MESSAGE.

            NEXT.
        END.

    IF glb_cddopcao = "R" THEN
        ASSIGN aux_numedlog = 0.
    ELSE
    IF tel_numedlog:SCREEN-VALUE = "ENVIADAS" THEN
        ASSIGN aux_numedlog = 1.
    ELSE
    IF tel_numedlog:SCREEN-VALUE = "RECEBIDAS" OR
       tel_numedlog:SCREEN-VALUE = "SUCESSO"   THEN
        ASSIGN aux_numedlog = 2.
    ELSE
    IF tel_numedlog:SCREEN-VALUE = "TODOS"    THEN
        ASSIGN aux_numedlog = 4.
    ELSE
        ASSIGN aux_numedlog = 3.

    IF tel_cdsitlog:SCREEN-VALUE = "PROCESSADAS" THEN
        ASSIGN aux_cdsitlog = "P".
    ELSE
    IF tel_cdsitlog:SCREEN-VALUE = "DEVOLVIDAS" THEN
        ASSIGN aux_cdsitlog = "D".
    ELSE
    IF tel_cdsitlog:SCREEN-VALUE = "REJEITADAS" THEN
        ASSIGN aux_cdsitlog = "R".
    ELSE
    IF tel_cdsitlog:SCREEN-VALUE = "TODOS" THEN
        ASSIGN aux_cdsitlog = "T".

    IF tel_cdorigem:SCREEN-VALUE = "AYLLOS" THEN
        ASSIGN aux_cdorigem = 1.
    ELSE
    IF tel_cdorigem:SCREEN-VALUE = "CAIXA ONLINE" THEN
        ASSIGN aux_cdorigem = 2.
    ELSE
    IF tel_cdorigem:SCREEN-VALUE = "INTERNET" THEN
        ASSIGN aux_cdorigem = 3.
    ELSE
        ASSIGN aux_cdorigem = 0. /* TODOS */
    
    HIDE FRAME f_opcao.
        
    RUN obtem-log-spb IN h-b1wgen0050 (INPUT glb_cdcooper,
                                       INPUT 0, 
                                       INPUT 0, 
                                       INPUT glb_cdoperad, 
                                       INPUT glb_nmdatela, 
                                       INPUT aux_cdorigem, 
                                       INPUT tel_flgidlog, 
                                       INPUT tel_dtmvtlog, 
                                       INPUT aux_numedlog, 
                                       INPUT aux_cdsitlog,
                                       INPUT tel_nrdconta,
                                       INPUT 1,
                                       INPUT 99999,
                                       INPUT 1, /* idorigem = 1 Ayllos */
                                       INPUT aux_nmendter,
                                       INPUT 0, /* inestcri */
                                       INPUT tel_vlrdated,
                                      OUTPUT aux_nmarqimp,
                                      OUTPUT aux_nmarqpdf,
                                      OUTPUT TABLE tt-logspb-detalhe,
                                      OUTPUT TABLE tt-logspb-totais,
                                      OUTPUT TABLE tt-erro).

    DELETE PROCEDURE h-b1wgen0050.

    IF  RETURN-VALUE = "NOK"  THEN
        DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.

            IF  AVAILABLE tt-erro  THEN
                ASSIGN glb_dscritic = tt-erro.dscritic.
            ELSE
                ASSIGN glb_dscritic = "Nao foi possivel concluir a " +
                                      "requisicao.".

            BELL.
            MESSAGE glb_dscritic.
            PAUSE 2 NO-MESSAGE.

            NEXT.
        END.

    IF  glb_cddopcao = "R"  THEN
        RUN imprime.

    ELSE
    IF  NOT tel_flgidlog AND tel_numedlog:SCREEN-VALUE <> "LOG"  THEN
        DO: 
            IF  tel_numedlog:SCREEN-VALUE = "ENVIADAS" AND 
                tel_cdsitlog:SCREEN-VALUE = "PROCESSADAS" THEN
                DO:
                    OPEN QUERY q-log-enviada-ok 
                         FOR EACH tt-logspb-detalhe NO-LOCK.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                      UPDATE b-log-enviada-ok WITH FRAME f_log_enviada_ok.
                      LEAVE.                         

                    END. /** Fim do DO WHILE TRUE **/
                        
                    HIDE FRAME f_log_enviada_ok NO-PAUSE.
                    HIDE FRAME f_total          NO-PAUSE.
            
                    CLOSE QUERY q-log-enviada-ok.
                END.                       
            ELSE
            IF tel_numedlog:SCREEN-VALUE = "RECEBIDAS" AND 
                tel_cdsitlog:SCREEN-VALUE = "PROCESSADAS" THEN
                DO:
                    OPEN QUERY q-log-recebida-ok 
                         FOR EACH tt-logspb-detalhe NO-LOCK.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                      UPDATE b-log-recebida-ok WITH FRAME f_log_recebida_ok. 
                      LEAVE.

                    END. /** Fim do DO WHILE TRUE **/
                        
                    HIDE FRAME f_log_recebida_ok NO-PAUSE.
                    HIDE FRAME f_total           NO-PAUSE.
            
                    CLOSE QUERY q-log-recebida-ok.
                END.                       
            ELSE
            IF  tel_numedlog:SCREEN-VALUE = "ENVIADAS" AND 
                tel_cdsitlog:SCREEN-VALUE = "DEVOLVIDAS"  THEN
                DO:
                    OPEN QUERY q-log-enviada-nok 
                         FOR EACH tt-logspb-detalhe NO-LOCK.

                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                      UPDATE b-log-enviada-nok WITH FRAME f_log_enviada_nok.
                      LEAVE.

                    END. /** Fim do DO WHILE TRUE **/
                        
                    HIDE FRAME f_log_enviada_nok NO-PAUSE.
                    HIDE FRAME f_total           NO-PAUSE.
                    
                    CLOSE QUERY q-log-enviada-nok.
                END.
            ELSE
            IF  tel_numedlog:SCREEN-VALUE = "RECEBIDAS" AND
                tel_cdsitlog:SCREEN-VALUE = "DEVOLVIDAS"  THEN
                DO:
                    OPEN QUERY q-log-recebida-nok 
                         FOR EACH tt-logspb-detalhe NO-LOCK.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    
                     UPDATE b-log-recebida-nok WITH FRAME f_log_recebida_nok.
                     LEAVE.

                    END. /** Fim do DO WHILE TRUE **/
                        
                    HIDE FRAME f_log_recebida_nok NO-PAUSE.
                    HIDE FRAME f_total            NO-PAUSE.
                                        
                    CLOSE QUERY q-log-recebida-nok.
                END.
            ELSE
            IF  tel_numedlog:SCREEN-VALUE = "ENVIADAS" AND 
                tel_cdsitlog:SCREEN-VALUE = "REJEITADAS"  THEN
                DO:
                    OPEN QUERY q-log-rejeitada-ok 
                         FOR EACH tt-logspb-detalhe NO-LOCK.

                    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        UPDATE b-log-rejeitada-ok WITH FRAME f_log_rejeitada_ok.                        
                        LEAVE.

                    END. /** Fim do DO WHILE TRUE **/
                        
                    HIDE FRAME f_log_rejeitada_ok NO-PAUSE.
                    HIDE FRAME f_total            NO-PAUSE. 
                               
                    CLOSE QUERY q-log-rejeitada-ok.
                END.                       
             ELSE
             IF /* Situacao + Todos */
                (tel_numedlog:SCREEN-VALUE = "ENVIADAS"  AND 
                 tel_cdsitlog:SCREEN-VALUE = "TODOS")     OR
                (tel_numedlog:SCREEN-VALUE = "RECEBIDAS" AND 
                 tel_cdsitlog:SCREEN-VALUE = "TODOS")     OR
                 /* Todos + Situacao */
                (tel_numedlog:SCREEN-VALUE = "TODOS"       AND 
                 tel_cdsitlog:SCREEN-VALUE = "DEVOLVIDAS")  OR
                (tel_numedlog:SCREEN-VALUE = "TODOS"       AND 
                 tel_cdsitlog:SCREEN-VALUE = "PROCESSADAS") OR
                (tel_numedlog:SCREEN-VALUE = "TODOS"       AND 
                 tel_cdsitlog:SCREEN-VALUE = "REJEITADAS" ) OR
                 /* Todos + Todos */
                (tel_numedlog:SCREEN-VALUE = "TODOS"     AND 
                 tel_cdsitlog:SCREEN-VALUE = "TODOS")   THEN
                 DO:
                     OPEN QUERY q-log-todos
                          FOR EACH tt-logspb-detalhe NO-LOCK.

                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                        UPDATE b-log-todos WITH FRAME f_log_todos.                        
                        LEAVE.

                     END. /** Fim do DO WHILE TRUE **/
                        
                     HIDE FRAME f_log_todos NO-PAUSE.
                     HIDE FRAME f_total            NO-PAUSE. 
                               
                     CLOSE QUERY q-log-todos.
                 END.                       
        END.
    ELSE
        DO:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                ASSIGN tel_lgvisual = "T".

                MESSAGE "(T)erminal ou (I)mpressora: " UPDATE tel_lgvisual. 
                
                IF  NOT CAN-DO("T,I",tel_lgvisual)  THEN
                    DO:
                        BELL.
                        MESSAGE "Opcao incorreta.".

                        NEXT.
                    END.

                LEAVE.

            END. /** Fim do DO WHILE TRUE **/
            
            IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                NEXT.
            
            IF  tel_lgvisual = "T"  THEN
                RUN visualiza_log.
            ELSE
            IF  tel_lgvisual = "I"  THEN     
                RUN imprime.

            UNIX SILENT VALUE ("rm " + aux_nmarqimp + " 2> /dev/null").
        END.
    
END. /** Fim do DO WHILE TRUE **/

/*............................ PROCEDURES INTERNAS ...........................*/

PROCEDURE imprime.

    FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                             NO-LOCK NO-ERROR.

    ASSIGN glb_nrcopias = 1
           glb_nmformul = IF  glb_cddopcao = "R" THEN 
                              "132col" 
                          ELSE 
                          IF glb_cddopcao = "M" THEN
                              "80col"
                          ELSE
                              "234dh".

    { includes/impressao.i }
    
END PROCEDURE.

PROCEDURE visualiza_log.
                                 
    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                                                              
        ENABLE aux_dseditor WITH FRAME f_editor.

        DISPLAY aux_dseditor WITH FRAME f_editor.
        
        ASSIGN aux_dseditor:READ-ONLY IN FRAME f_editor = TRUE.

        IF  aux_dseditor:INSERT-FILE(aux_nmarqimp)  THEN
            DO:
                ASSIGN aux_dseditor:CURSOR-LINE IN FRAME f_editor = 1.
                WAIT-FOR GO OF aux_dseditor IN FRAME f_editor. 
            END.
        ELSE   
            DO:
                BELL.
                MESSAGE "Arquivo nao encontrado".
                LEAVE.
            END.
      
    END. /** Fim do DO WHILE TRUE **/
    
    ASSIGN aux_dseditor:SCREEN-VALUE = "".
    
    CLEAR FRAME f_editor ALL.
    
    HIDE FRAME f_editor NO-PAUSE.

END PROCEDURE.

PROCEDURE mostra-detalhes:    

    ASSIGN aux_pontilha = FILL("-",37) + "  " + FILL("-",37).
    
    IF tt-logspb-detalhe.cdbandst <> 1 AND  tt-logspb-detalhe.cdispdst = 0 THEN
       aux_cdispdst = ''.
    ELSE 
       aux_cdispdst =  string(tt-logspb-detalhe.cdispdst,"99999999").
    
    IF tt-logspb-detalhe.cdbanrem <> 1 AND  tt-logspb-detalhe.cdisprem = 0 THEN
       aux_cdisprem = ''.
    ELSE aux_cdisprem = string(tt-logspb-detalhe.cdisprem,"99999999") .

    DISPLAY tt-logspb-detalhe.vltransa
            tel_dsmotivo               aux_pontilha
            tt-logspb-detalhe.cdbanrem tt-logspb-detalhe.cdagerem
            aux_cdisprem                aux_cdispdst
            tt-logspb-detalhe.nrctarem tt-logspb-detalhe.dsnomrem
            tt-logspb-detalhe.dscpfrem tt-logspb-detalhe.cdbandst
            tt-logspb-detalhe.cdagedst tt-logspb-detalhe.nrctadst
            tt-logspb-detalhe.dsnomdst tt-logspb-detalhe.dscpfdst
            WITH FRAME f_detalhes.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

        PAUSE MESSAGE "Tecle <END>/<F4> para voltar.".
        LEAVE.

    END.

    HIDE FRAME f_detalhes NO-PAUSE.

END PROCEDURE.

/*............................................................................*/

