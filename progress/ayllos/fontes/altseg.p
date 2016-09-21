/* .............................................................................

   Programa: Fontes/altseg.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Marco/2004                       Ultima atualizacao: 03/03/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela ALTSEG(altera tabela craptsg)
               Permitir alterar Valores Premio Seguro(de Vida)  

   Alteracoes: 27/06/2005 - Alterado nome da TEMP-TABLE crawseg para cratseg
                            (Diego).

               25/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.
               
               16/06/2006 - Incluida opcao "I" e acrescentados alguns campos
                            nas opcoes "A" e  "C" (Diego).
                            
               27/06/2006 - Alterado para nao limpar os campos Seguradora e 
                            Tipo de Seguro (Diego).

               31/07/2006 - Liberada somente opcao "C" para cooperativas
                            singulares (David).

               11/09/2006 - Alterado help dos campos da tela (Elton). 

               29/09/2006 - Prever percentual negativo e com 4 decimais(Mirtes)
               
               10/02/2009 - Liberar permissao so pro operador 799 (Gabriel).
               
               11/05/2009 - Alteracao CDOPERAD (Kbase).
               
               24/08/2011 - Implementacao de nova visualizacao de garantias
                            para seguros do tipo 11 - casa (Gati - Oliver)
                            
               13/11/2012 - Retirado DELETE que estava sobrando (David Kruger).
               
               03/10/2012 - Preparação para utilização total de BOs (Gati - Lauro).
               
               27/11/2013 - Adequação de padrões de desenvolvimento e indentação
                            CECRED
               
               08/04/2014 - Ajuste de whole index (Jean Michel).
               
               16/09/2015 - Ajuste para liberacao decorrente as mudancas efetuadas
                            para utilizacao de BO
                            (Adriano).
                            
               03/03/2016 - Liberando acesso para o departamento COORD.PRODUTOS 
                            conforme solicitado no chamado 399940. (Kelvin)
               
............................................................................. */

{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0033tt.i }

DEFINE TEMP-TABLE crawtsg                                          NO-UNDO
       FIELD  tpseguro  LIKE craptsg.tpseguro
       FIELD  tpplaseg  LIKE craptsg.tpplaseg
       FIELD  nrtabela  LIKE craptsg.nrtabela
       FIELD  dsmorada  LIKE craptsg.dsmorada
       FIELD  vlplaseg  LIKE craptsg.vlplaseg
       FIELD  vlatual   AS DEC FORMAT "zz9.99-"
       FIELD  registro    AS RECID.

DEF       VAR aux_confirma AS CHAR    FORMAT "!(1)"                NO-UNDO.
DEF       VAR aux_cddopcao AS CHAR                                 NO-UNDO.


DEF       VAR tel_tpseguro LIKE craptsg.tpseguro                   NO-UNDO.
DEF       VAR tel_cdsegura LIKE craptsg.cdsegura                   NO-UNDO.
DEF       VAR tel_nmsegura LIKE crapcsg.nmsegura                   NO-UNDO.
DEF       VAR tel_ddcancel LIKE craptsg.ddcancel                   NO-UNDO.
DEF       VAR tel_dddcorte LIKE craptsg.dddcorte                   NO-UNDO.
DEF       VAR tel_ddmaxpag LIKE craptsg.ddmaxpag                   NO-UNDO.
DEF       VAR tel_mmpripag LIKE craptsg.mmpripag                   NO-UNDO.
DEF       VAR tel_qtdiacar LIKE craptsg.qtdiacar                   NO-UNDO.
DEF       VAR tel_qtmaxpar LIKE craptsg.qtmaxpar                   NO-UNDO.
DEF       VAR tel_vlplaseg LIKE craptsg.vlplaseg                   NO-UNDO. 
DEF       VAR tel_dsocupac LIKE craptsg.dsocupac                   NO-UNDO.
DEF       VAR tel_dsgarant LIKE craptsg.dsgarant                   NO-UNDO.
DEF       VAR tel_nrtabela LIKE craptsg.nrtabela                   NO-UNDO.
DEF       VAR tel_dsmorada LIKE craptsg.dsmorada                   NO-UNDO.
DEF       VAR tel_vlmorada LIKE craptsg.vlmorada                   NO-UNDO.
DEF       VAR tel_flgunica LIKE craptsg.flgunica                   NO-UNDO.
DEF       VAR tel_tpplaseg AS INT     FORMAT "zz9"                 NO-UNDO.
DEF       VAR tel_flgconsi AS LOG     FORMAT "Sim/Nao"             NO-UNDO.
DEF       VAR tel_cdsitpla AS LOGICAL FORMAT "Ativo/Inativo"       NO-UNDO.
DEF       VAR tel_vlpercen AS DEC     FORMAT "zzz,zz9.9999-"       NO-UNDO.
DEF       VAR tel_datdebit     AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF       VAR tel_datdespr AS DATE FORMAT "99/99/9999"             NO-UNDO.
DEF       VAR aux_qtsegass AS INTE                                 NO-UNDO.
DEF       VAR aux_vltotseg AS DECI                                 NO-UNDO.
DEF       VAR aux_qtregist AS INT                                  NO-UNDO.

DEF       VAR aux_acrescimo AS DEC                                 NO-UNDO.
DEF       VAR aux_flglista  AS LOG    FORMAT "Sim/Nao"             NO-UNDO.
DEF       VAR tel_dsinplse  AS CHAR   FORMAT "x(19)"               NO-UNDO.

DEF       VAR aux_nmarqimp  AS CHAR                                NO-UNDO.
DEF       VAR aux_nmarqpdf  AS CHAR                                NO-UNDO.
DEF       VAR aux_nmdcampo  AS CHAR                                NO-UNDO.
DEF       VAR h-b1wgen0033  AS HANDLE                              NO-UNDO.
                                            
FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  3 FORMAT "!" LABEL "Opcao" AUTO-RETURN
                        HELP "Entre com a opcao desejada (A, C, I, K)"
                        VALIDATE(CAN-DO("A,C,I,K",glb_cddopcao),
                                 "014 - Opcao errada.")
     SKIP(1)
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM tel_cdsegura AT  5 LABEL "Seguradora"
                        HELP "Informe o codigo da seguradora."
                        VALIDATE(CAN-FIND(tt-seguradora NO-LOCK WHERE 
                                          tt-seguradora.cdcooper = glb_cdcooper
                                     AND tt-seguradora.cdsegura = tel_cdsegura),
                                          "556 - Seguradora nao cadastrada.")
     tel_nmsegura       NO-LABEL FORMAT "x(37)"
     SKIP(1)
     tel_tpseguro AT  1 FORMAT "z9" LABEL "Tipo de seguro"
                        VALIDATE (tel_tpseguro = 1 OR tel_tpseguro = 3 OR
                                  tel_tpseguro = 4 OR tel_tpseguro = 11,
                                    "513 - Tipo errado") 
                        HELP "Tipo  3-(Vida), 4-(Prestamista), 11 -(Casa)."
     tel_tpplaseg AT 28 FORMAT "zz9" LABEL "Plano"
                        HELP "Informe o tipo do plano de seguro."
     WITH ROW 6 COLUMN 15 OVERLAY SIDE-LABELS NO-BOX FRAME f_selecao.

FORM tel_tpseguro AT  1 FORMAT "z9" LABEL "Seguro"
                        VALIDATE (tel_tpseguro = 3, "513 - Tipo errado") 
             HELP "Informe o tipo de seguro (3-Vida)."
     tel_tpplaseg AT 15 FORMAT "999" LABEL "Plano"
             HELP "Informe o plano da seguradora ou '0' zero para listar todos."
     tel_nrtabela AT 29 FORMAT "z9" LABEL "Tabela"
             HELP "Informe o numero da tabela ou '0' zero para listar todas."
     tel_vlpercen AT 43 FORMAT "zz9.9999-" LABEL "Perc."
             HELP "Informe o percentual de aumento para o premio do seguro."
                        VALIDATE(tel_vlpercen <> 0,"Valor Errado")
     tel_datdebit     AT 43 FORMAT "99/99/9999" Label "Data Debito"
             HELP "Data debito dos seguros a partir da Data."
     tel_datdespr AT 5 FORMAT "99/99/9999"
             LABEL "Desprezar Contratos (novos) a partir da Data Mvto"
             HELP "Informe ate que data deseja listar os seguros ativos."
     WITH ROW 6 COLUMN 15 OVERLAY SIDE-LABELS NO-BOX FRAME f_selecao_k.

FORM tel_dsmorada AT  3 LABEL "Descricao"                                                       
                        HELP "Entre com a descricao da moradia."
     tel_vlplaseg AT  3 HELP "Entre com o valor do premio." 
     tel_dsocupac AT  3 HELP "Entre com o tipo de ocupacao."
     tel_nrtabela AT  3 HELP "Entre com o numero da tabela."
     tel_vlmorada AT  3 HELP "Entre com o valor da cobertura(maximo) do seguro."
     tel_flgunica AT  3 HELP "Entre com (U)nica ou (M)ensal."
     tel_dsinplse AT 35 NO-LABEL
     tel_flgconsi AT 55 NO-LABEL
                        HELP "Informe (S)im ou (N)ao."
     tel_cdsitpla AT  3 LABEL "Situacao do Plano"
                        HELP "Entre com (A)tivo ou (I)nativo."
     tel_ddcancel AT  3 LABEL "Dia Limite Cancelamento"
                        HELP "DIA 1 - para qualquer dia dentro do mes."
                        VALIDATE((tel_ddcancel <> 0 AND
                                 tel_ddcancel <= 31 AND
                                 tel_tpseguro = 11) OR
                                 tel_tpseguro <> 11, "013 - Data Errada.")
     tel_dddcorte AT 41 LABEL "Dia do corte"
                        HELP "Informe o dia do corte da seguradora."
                        VALIDATE((tel_dddcorte <> 0 AND
                                 tel_dddcorte <= 31 AND
                                 tel_tpseguro = 11) OR
                                 tel_tpseguro <> 11, "013 - Data errada.")
     tel_ddmaxpag AT  3 LABEL "Dia Max. Pagamento"
                  HELP "Informe o dia maximo do mes para pagamento da parcela."
                  VALIDATE((tel_ddmaxpag <> 0 AND
                           tel_ddmaxpag <= 31 AND
                           tel_tpseguro = 11) OR
                           tel_tpseguro <> 11  , "013 - Data errada.")
     tel_mmpripag AT 39 LABEL "Meses carencia"
              HELP "Informe quantidade de meses de carencia para 1o pagamento."
     tel_qtdiacar AT  3 LABEL "Qtd.dias carencia"
              HELP "Informe quantidade de dias de carencia para 1o pagamento."
     tel_qtmaxpar AT 37 LABEL "Qtd.Max.Parcelas"
                        HELP "Informe a quantidade maxima de parcelas."
                        VALIDATE((tel_qtmaxpar <> 0 AND
                                  tel_tpseguro = 11) OR
                                  tel_tpseguro <> 11,
                                 "375 - O campo deve ser preenchido.")
     WITH ROW 10 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_seguro.

FORM tel_dsmorada AT  3 LABEL "Descricao"                                                          
                        HELP "Entre com a descricao da moradia."                                   
     tel_vlplaseg AT  3 HELP "Entre com o valor do premio."                                        
     tel_dsocupac AT  3 HELP "Entre com o tipo de ocupacao."                                       
     tel_nrtabela AT  3 HELP "Entre com o numero da tabela."                                       
     tel_flgunica AT  3 HELP "Entre com (U)nica ou (M)ensal."                                      
     tel_dsinplse AT 35 NO-LABEL                                                                   
     tel_flgconsi AT 55 NO-LABEL                                                                   
                        HELP "Informe (S)im ou (N)ao."                                             
     tel_cdsitpla AT  3 LABEL "Situacao do Plano"                                                  
                        HELP "Entre com (A)tivo ou (I)nativo."                                     
     tel_ddcancel AT  3 LABEL "Dia Limite Cancelamento"                                            
                        HELP "DIA 1 - para qualquer dia dentro do mes."                            
                        VALIDATE((tel_ddcancel <> 0 AND                                            
                                 tel_ddcancel <= 31 AND                                            
                                 tel_tpseguro = 11) OR                                             
                                 tel_tpseguro <> 11, "013 - Data Errada.")                         
     tel_dddcorte AT 41 LABEL "Dia do corte"                                                       
                        HELP "Informe o dia do corte da seguradora."                               
                        VALIDATE((tel_dddcorte <> 0 AND                                            
                                 tel_dddcorte <= 31 AND                                            
                                 tel_tpseguro = 11) OR                                             
                                 tel_tpseguro <> 11, "013 - Data errada.")                         
     tel_ddmaxpag AT  3 LABEL "Dia Max. Pagamento"                                                 
                  HELP "Informe o dia maximo do mes para pagamento da parcela."                    
                  VALIDATE((tel_ddmaxpag <> 0 AND                                                  
                           tel_ddmaxpag <= 31 AND                                                  
                           tel_tpseguro = 11) OR                                                   
                           tel_tpseguro <> 11  , "013 - Data errada.")                             
     tel_mmpripag AT 39 LABEL "Meses carencia"                                                     
              HELP "Informe quantidade de meses de carencia para 1o pagamento."                    
     tel_qtdiacar AT  3 LABEL "Qtd.dias carencia"                                                  
              HELP "Informe quantidade de dias de carencia para 1o pagamento."                     
     tel_qtmaxpar AT 37 LABEL "Qtd.Max.Parcelas"                                                   
                        HELP "Informe a quantidade maxima de parcelas."                            
                        VALIDATE((tel_qtmaxpar <> 0 AND                                            
                                  tel_tpseguro = 11) OR                                            
                                  tel_tpseguro <> 11,                                              
                                 "375 - O campo deve ser preenchido.")                             
     WITH ROW 10 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_seguro_casa.                          
                                                                                                   
FORM aux_flglista    AT 1 LABEL "Emitir Relatorio"
                     HELP "Entre com Sim/Nao "
     WITH ROW 12 COLUMN 12 SIDE-LABELS OVERLAY NO-BOX FRAME f_lista.

DEF QUERY q_craptsg  FOR tt-plano-seg.
                                     
DEF BROWSE b_craptsg  QUERY q_craptsg
    DISP   tt-plano-seg.tpplaseg COLUMN-LABEL 'Plano'
           tt-plano-seg.dsmorada COLUMN-LABEL 'Descricao' FORMAT "x(35)"
           tt-plano-seg.vlplaseg 
           tt-plano-seg.nrtabela 
           WITH 10 DOWN CENTERED NO-BOX.

DEF QUERY q_crapgsg FOR tt-gar-seg.

DEF BROWSE b_crapgsg QUERY q_crapgsg
    DISP   tt-gar-seg.dsgarant FORMAT "x(40)" COLUMN-LABEL "Descricao"
           tt-gar-seg.vlgarant COLUMN-LABEL "Valor"
           tt-gar-seg.dsfranqu FORMAT "x(40)" COLUMN-LABEL "Franquia"
    WITH 8 DOWN WIDTH 78 SCROLLBAR-VERTICAL NO-BOX .

FORM b_crapgsg
    HELP "Use as SETAS para navegar <F4> para sair."
    WITH ROW 10 NO-LABELS NO-BOX CENTERED OVERLAY FRAME f_b_crapgsg.

DEF FRAME f_craptsg_b  
          SKIP(1)
          b_craptsg   HELP  "Pressione <F4> ou <END> p/finalizar" 
          WITH NO-BOX CENTERED OVERLAY ROW 7.

DEF QUERY q_crawtsg  FOR crawtsg. 
                                     
DEF BROWSE b_crawtsg  QUERY q_crawtsg
    DISP   crawtsg.tpplaseg COLUMN-LABEL 'Plano'
           crawtsg.dsmorada COLUMN-LABEL 'Descricao' FORMAT "x(25)"
           crawtsg.vlplaseg COLUMN-LABEL 'Anterior'
           crawtsg.vlatual  COLUMN-LABEL 'Atual'
           crawtsg.nrtabela COLUMN-LABEL 'Tabela'
           WITH 9 DOWN CENTERED NO-BOX.

DEF FRAME f_crawtsg_b  
          SKIP(1)
          b_crawtsg   HELP  "Pressione <F4> ou <END> p/finalizar" 
          WITH NO-BOX CENTERED OVERLAY ROW 8.

DEF QUERY q_cratseg  FOR cratseg. 

DEF BROWSE b_cratseg  QUERY q_cratseg
    DISP   cratseg.tpplaseg COLUMN-LABEL 'Plano'
           cratseg.dtdebito COLUMN-LABEL 'Debito' 
           cratseg.vlpreseg COLUMN-LABEL 'Anterior' FORMAT "zzz9.99"
           cratseg.vlatual  COLUMN-LABEL 'Atual' FORMAT "zzz9.99"
           cratseg.nrdconta COLUMN-LABEL 'Conta' 
           cratseg.dtmvtolt COLUMN-LABEL 'Movto' FORMAT "99/99/9999"
           WITH 8 DOWN CENTERED NO-BOX.

DEF FRAME f_cratseg_b  
          SKIP(1)
          b_cratseg   HELP  "Pressione <F4> ou <END> p/finalizar" 
          WITH NO-BOX CENTERED OVERLAY ROW 9.


/* Browse Seguradoras */
DEF QUERY q_seguradora FOR tt-seguradora.
    
DEF BROWSE b_seguradora QUERY q_seguradora    
    DISPLAY tt-seguradora.cdsegura  COLUMN-LABEL "Cod." 
            tt-seguradora.nmresseg  COLUMN-LABEL "Seguradora"
            WITH 5 DOWN.
            
FORM b_seguradora 
     HELP "Pressione ENTER para selecionar / F4 ou END para sair."
     WITH ROW 5 COLUMN 29 WIDTH 38 OVERLAY NO-BOX FRAME f_seguradora.

/* Retorna Programa */    
ON RETURN OF b_seguradora
   DO:    
      IF AVAIL tt-seguradora THEN 
         DO:
            ASSIGN tel_cdsegura = tt-seguradora.cdsegura
                   tel_nmsegura = tt-seguradora.nmsegura.
           
            DISPLAY tel_cdsegura 
                    tel_nmsegura  
                    WITH FRAME f_selecao.
          
         END. 
    
      APPLY "GO".

   END.

ON LEAVE OF tel_cdsegura IN FRAME f_selecao 
   DO:
      IF NOT VALID-HANDLE(h-b1wgen0033) THEN
         RUN sistema/generico/procedures/b1wgen0033.p 
             PERSISTENT SET h-b1wgen0033.
      
      RUN buscar_seguradora IN h-b1wgen0033 (INPUT glb_cdcooper,
                                             INPUT glb_cdagenci,
                                             INPUT 0 /* glb_nrdcaixa */,
                                             INPUT glb_cdoperad,
                                             INPUT glb_dtmvtolt,
                                             INPUT 0 /* glb_nrdconta */,
                                             INPUT 1 /* par_idseqttl */,
                                             INPUT 1 /* par_idorigem */,
                                             INPUT glb_nmdatela,
                                             INPUT FALSE,
                                             INPUT 0 /* par_tpseguro */,
                                             INPUT 0 /* par_cdsitpsg */,
                                             INPUT INPUT tel_cdsegura,
                                             INPUT "" /* par_nmsegura */,
                                             OUTPUT aux_qtregist,
                                             OUTPUT TABLE tt-seguradora,
                                             OUTPUT TABLE tt-erro).
      
      IF VALID-HANDLE(h-b1wgen0033) THEN
         DELETE PROCEDURE h-b1wgen0033.
      
      IF RETURN-VALUE <> "OK"   THEN
         DO:
            FIND FIRST tt-erro NO-LOCK NO-ERROR.
      
            IF AVAIL tt-erro   THEN
               MESSAGE tt-erro.dscritic.
            ELSE
               MESSAGE "Erro na busca de seguradora.".
            
            PAUSE.
               
            LEAVE.
         END.
      ELSE 
         DO:
            FOR FIRST tt-seguradora 
                WHERE tt-seguradora.cdcooper = glb_cdcooper AND
                      tt-seguradora.cdsegura = tel_cdsegura.
      
                ASSIGN tel_nmsegura = tt-seguradora.nmsegura.
      
                DISPLAY tel_nmsegura WITH FRAME f_selecao.
      
            END.
      
         END.
       
   END.

VIEW FRAME f_moldura.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0.

PAUSE(0).

DO WHILE TRUE:
    
   RUN fontes/inicia.p.

   HIDE FRAME f_seguro.
   CLEAR FRAME f_seguro NO-PAUSE.
   HIDE FRAME f_seguro_casa.
   CLEAR FRAME f_seguro_casa NO-PAUSE.
   HIDE FRAME f_selecao.
   CLEAR FRAME f_selecao NO-PAUSE.
   HIDE FRAME f_selecao_k.
   CLEAR FRAME f_selecao_k NO-PAUSE.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF glb_cdcritic > 0 THEN 
         DO:

            RUN fontes/critic.p.
            BELL.
            MESSAGE glb_dscritic.
            ASSIGN glb_cdcritic = 0.

         END.

      UPDATE glb_cddopcao WITH FRAME f_opcao.

      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN /* F4 OU FIM */ 
      DO:
         RUN fontes/novatela.p.

         IF CAPS(glb_nmdatela) <> "ALTSEG" THEN 
            DO:
               HIDE FRAME f_opcao.
               HIDE FRAME f_seguro.
               HIDE FRAME f_seguro_casa.
               HIDE FRAME f_selecao.
               HIDE FRAME f_selecao_k.
               HIDE FRAME f_moldura.
               RETURN.
            END.
         ELSE 
            NEXT.
      END.

   IF aux_cddopcao <> glb_cddopcao THEN 
      DO:
        { includes/acesso.i }
        ASSIGN aux_cddopcao = glb_cddopcao.

      END.

   /* Cooperativas singulares podem somente consultar */
   IF glb_cddopcao  <> "C" THEN
      IF glb_dsdepart <> "TI"       AND 
         glb_dsdepart <> "PRODUTOS" AND
         glb_dsdepart <> "COORD.PRODUTOS" THEN 
         DO:
            BELL.
            MESSAGE "Sistema liberado somente para Consulta !!!".
            NEXT.
         END.

   IF glb_cddopcao = "I" THEN 
      DO:
         ASSIGN tel_cdsegura = 0
                tel_nmsegura = ""
                tel_tpseguro = 0
                tel_tpplaseg = 0
                tel_cdsitpla = FALSE
                tel_ddcancel = 0
                tel_dddcorte = 0
                tel_ddmaxpag = 0
                tel_dsgarant = ""
                tel_dsmorada = ""
                tel_dsocupac = ""
                tel_flgunica = FALSE
                tel_flgconsi = FALSE
                tel_mmpripag = 0
                tel_nrtabela = 0
                tel_qtdiacar = 0
                tel_qtmaxpar = 0
                tel_tpplaseg = 0
                tel_vlmorada = 0
                tel_vlplaseg = 0.
         
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
             
            UPDATE tel_cdsegura 
                   tel_tpseguro 
                   tel_tpplaseg
                   WITH FRAME f_selecao
         
            EDITING:
         
                READKEY.
         
                IF LASTKEY = KEYCODE("F7") AND
                   FRAME-FIELD = "tel_cdsegura" THEN 
                   DO:
                      IF NOT VALID-HANDLE(h-b1wgen0033) THEN
                         RUN sistema/generico/procedures/b1wgen0033.p 
                             PERSISTENT SET h-b1wgen0033.
                      
                      MESSAGE "Aguarde...Buscando seguradora.".

                      RUN buscar_seguradora IN h-b1wgen0033 
                          (INPUT glb_cdcooper,
                           INPUT glb_cdagenci,
                           INPUT 0 /* glb_nrdcaixa */,
                           INPUT glb_cdoperad,
                           INPUT glb_dtmvtolt,
                           INPUT 0 /* glb_nrdconta */,
                           INPUT 1 /* par_idseqttl */,
                           INPUT 1 /* par_idorigem */,
                           INPUT glb_nmdatela,
                           INPUT FALSE,
                           INPUT 0,
                           INPUT 0,
                           INPUT 0,
                           INPUT "",
                           OUTPUT aux_qtregist,
                           OUTPUT TABLE tt-seguradora,
                           OUTPUT TABLE tt-erro).
                      
                      HIDE MESSAGE NO-PAUSE.

                      IF VALID-HANDLE(h-b1wgen0033) THEN
                         DELETE PROCEDURE h-b1wgen0033.
                      
                      IF RETURN-VALUE <> "OK" THEN
                         DO:
                            FIND FIRST tt-erro NO-LOCK NO-ERROR.

                            IF AVAIL tt-erro   THEN
                               MESSAGE tt-erro.dscritic.
                            ELSE
                               MESSAGE "Erro na busca de seguradora.".
                            
                            PAUSE.
                               
                            LEAVE.
                         END.
                      
                      OPEN QUERY q_seguradora 
                           FOR EACH tt-seguradora 
                               WHERE tt-seguradora.cdcooper = glb_cdcooper
                                      NO-LOCK BY tt-seguradora.cdsegura.
                      
                      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                         UPDATE b_seguradora WITH FRAME f_seguradora.
                         LEAVE.
                      END.
                      
                      HIDE FRAME f_seguradora.
                      NEXT.

                   END.
                ELSE
                   APPLY LASTKEY.
                    
            END.  /*  Fim do EDITING  */
         
            IF tel_tpseguro = 1 THEN 
               DO:
                  ASSIGN glb_cdcritic = 513.
                  RUN fontes/critic.p.
                  MESSAGE glb_dscritic.
                  PAUSE 2 NO-MESSAGE.
                  ASSIGN glb_cdcritic = 0.
                  NEXT-PROMPT tel_tpseguro WITH FRAME f_selecao.
                  NEXT.
               END.
         
            LEAVE. 
         
         END. /* Fim DO WHILE TRUE */
         
         IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
            NEXT.

         DO WHILE TRUE TRANSACTION:
         
            EMPTY TEMP-TABLE tt-plano-seg.
         
            CREATE tt-plano-seg.
            ASSIGN tt-plano-seg.cdcooper = glb_cdcooper  
                   tt-plano-seg.cdsegura = tel_cdsegura  
                   tt-plano-seg.tpplaseg = tel_tpplaseg  
                   tt-plano-seg.tpseguro = tel_tpseguro. 
         
            IF tel_tpseguro = 11 THEN
               ASSIGN tel_dsinplse = "Qtd.Parcelas Fixas:".
            ELSE
               ASSIGN tel_dsinplse = "    Consiste Valor:".
         
            IF tel_tpseguro = 11 THEN 
               DO:
                  DISPLAY tel_dsinplse WITH FRAME f_seguro_casa.
                  
                  ASSIGN tel_flgconsi = YES.
                  
                  UPDATE tel_dsmorada 
                         tel_vlplaseg 
                         tel_dsocupac 
                         tel_nrtabela
                         tel_flgunica 
                         tel_flgconsi 
                         tel_cdsitpla
                         tel_ddcancel 
                         tel_dddcorte 
                         tel_ddmaxpag 
                         tel_mmpripag 
                         tel_qtdiacar 
                         tel_qtmaxpar
                         WITH FRAME f_seguro_casa.
               END.
            ELSE
               DO:
                  DISPLAY tel_dsinplse WITH FRAME f_seguro.
                  
                  UPDATE tel_dsmorada 
                         tel_vlplaseg 
                         tel_dsocupac
                         tel_nrtabela 
                         tel_vlmorada
                         tel_flgunica 
                         tel_flgconsi 
                         tel_cdsitpla
                         tel_ddcancel 
                         tel_dddcorte 
                         tel_ddmaxpag 
                         tel_mmpripag 
                         tel_qtdiacar 
                         tel_qtmaxpar
                         WITH FRAME f_seguro.
               END.
         
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
               ASSIGN aux_confirma = "N"
                      glb_cdcritic = 78.
         
               RUN fontes/critic.p.
               BELL.
               MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
               ASSIGN glb_cdcritic = 0.
               LEAVE.
         
            END.  /*  Fim do DO WHILE TRUE  */
         
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
               aux_confirma <> "S" THEN 
               DO:
                  ASSIGN glb_cdcritic = 79.
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE glb_dscritic.
                  PAUSE 2 NO-MESSAGE.
                  ASSIGN glb_cdcritic = 0.
                  LEAVE.
               END.
         
            IF aux_confirma = "S" THEN 
               DO:
                  ASSIGN tt-plano-seg.cdsitpsg = IF tel_cdsitpla = TRUE THEN
                                                    1 
                                                 ELSE 
                                                    2
                         tt-plano-seg.ddcancel = tel_ddcancel
                         tt-plano-seg.dddcorte = tel_dddcorte
                         tt-plano-seg.ddmaxpag = tel_ddmaxpag
                         tt-plano-seg.dsgarant = tel_dsgarant
                         tt-plano-seg.dsmorada = tel_dsmorada
                         tt-plano-seg.dsocupac = tel_dsocupac
                         tt-plano-seg.flgunica = tel_flgunica
                         tt-plano-seg.inplaseg = IF tel_flgconsi = TRUE THEN 
                                                    1 
                                                 ELSE 
                                                    2
                         tt-plano-seg.mmpripag = tel_mmpripag
                         tt-plano-seg.nrtabela = tel_nrtabela
                         tt-plano-seg.qtdiacar = tel_qtdiacar
                         tt-plano-seg.qtmaxpar = tel_qtmaxpar
                         tt-plano-seg.vlmorada = tel_vlmorada
                         tt-plano-seg.vlplaseg = tel_vlplaseg.
                         
                  IF NOT VALID-HANDLE(h-b1wgen0033) THEN
                     RUN sistema/generico/procedures/b1wgen0033.p 
                         PERSISTENT SET h-b1wgen0033.
                  
                  MESSAGE "Aguarde...Validando plano.".

                  RUN valida_existe_plano_seg IN h-b1wgen0033
                      (INPUT glb_cdcooper,
                       INPUT glb_cdagenci,
                       INPUT 0 /* glb_nrdcaixa */,
                       INPUT glb_cdoperad,
                       INPUT glb_dtmvtolt,
                       INPUT 0 /* glb_nrdconta */,
                       INPUT 1 /* par_idseqttl */,
                       INPUT 1 /* par_idorigem */,
                       INPUT glb_nmdatela,
                       INPUT FALSE,
                       INPUT tt-plano-seg.cdsegura,
                       INPUT tt-plano-seg.tpseguro,
                       INPUT tt-plano-seg.tpplaseg,
                       OUTPUT TABLE tt-erro).
                 
                  HIDE MESSAGE NO-PAUSE.

                  IF RETURN-VALUE <> "OK" THEN
                     DO:
                        IF VALID-HANDLE(h-b1wgen0033) THEN
                           DELETE PROCEDURE h-b1wgen0033.

                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF AVAIL tt-erro   THEN
                           MESSAGE tt-erro.dscritic.
                        ELSE
                           MESSAGE "Erro na validação do Plano.".
                        
                        PAUSE.
                           
                        LEAVE.
                 
                     END.
                  
                   MESSAGE "Aguarde...Atualizando plano.".

                   RUN atualizar_plano_seguro IN h-b1wgen0033 
                      (INPUT glb_cdcooper,
                       INPUT glb_cdagenci,
                       INPUT 0 /* glb_nrdcaixa */,
                       INPUT glb_cdoperad,
                       INPUT glb_dtmvtolt,
                       INPUT 0 /* glb_nrdconta */,
                       INPUT 1 /* par_idseqttl */,
                       INPUT 1 /* par_idorigem */,
                       INPUT glb_nmdatela,
                       INPUT FALSE,
                       INPUT tel_cdsegura,
                       INPUT tt-plano-seg.cdsitpsg,
                       INPUT tt-plano-seg.dsmorada,
                       INPUT tt-plano-seg.ddcancel,
                       INPUT tt-plano-seg.dddcorte,
                       INPUT tt-plano-seg.ddmaxpag,
                       INPUT tt-plano-seg.dsocupac,
                       INPUT tt-plano-seg.flgunica,
                       INPUT tt-plano-seg.inplaseg,
                       INPUT tt-plano-seg.mmpripag,
                       INPUT tt-plano-seg.nrtabela,
                       INPUT tt-plano-seg.qtdiacar,
                       INPUT tt-plano-seg.qtmaxpar,
                       INPUT tt-plano-seg.tpplaseg,
                       INPUT tt-plano-seg.tpseguro,
                       INPUT tt-plano-seg.vlmorada,
                       INPUT tt-plano-seg.vlplaseg,
                       OUTPUT TABLE tt-erro).
                 
                  HIDE MESSAGE NO-PAUSE.

                  IF VALID-HANDLE(h-b1wgen0033) THEN
                     DELETE PROCEDURE h-b1wgen0033.
                 
                  IF RETURN-VALUE <> "OK" THEN
                     DO:
                        FIND FIRST tt-erro NO-LOCK NO-ERROR.

                        IF AVAIL tt-erro   THEN
                           MESSAGE tt-erro.dscritic.
                        ELSE
                           MESSAGE "Erro na atualização de plano seguro.".
                        
                        PAUSE.
                           
                        LEAVE.
                     END.
                 
                  CLEAR FRAME f_seguro.
                  CLEAR FRAME f_seguro_casa.
                  CLEAR FRAME f_selecao.
                  LEAVE.     

               END. 

         END.  /* TRANSACTION */

      END.
   ELSE
   IF glb_cddopcao = "A" THEN 
      DO:
         ASSIGN tel_cdsegura = 0
                tel_tpseguro = 0
                tel_nmsegura = ""
                tel_tpplaseg = 0.
        
         UPDATE tel_cdsegura 
                tel_tpseguro 
                tel_tpplaseg
                WITH FRAME f_selecao
        
         EDITING:
        
             READKEY.
        
             IF LASTKEY = KEYCODE("F7")      AND
                FRAME-FIELD = "tel_cdsegura" THEN 
                DO:
                   IF NOT VALID-HANDLE(h-b1wgen0033) THEN
                      RUN sistema/generico/procedures/b1wgen0033.p 
                          PERSISTENT SET h-b1wgen0033.
        
                   MESSAGE "Aguarde...Buscando seguradora.".

                   RUN buscar_seguradora IN h-b1wgen0033 
                       (INPUT glb_cdcooper,
                        INPUT glb_cdagenci,
                        INPUT 0 /* glb_nrdcaixa */,
                        INPUT glb_cdoperad,
                        INPUT glb_dtmvtolt,
                        INPUT 0 /* glb_nrdconta */,
                        INPUT 1 /* par_idseqttl */,
                        INPUT 1 /* par_idorigem */,
                        INPUT glb_nmdatela,
                        INPUT FALSE,
                        INPUT 0,
                        INPUT 0,
                        INPUT 0,
                        INPUT "",
                        OUTPUT aux_qtregist,
                        OUTPUT TABLE tt-seguradora,
                        OUTPUT TABLE tt-erro).
        
                   HIDE MESSAGE NO-PAUSE.

                   IF VALID-HANDLE(h-b1wgen0033) THEN
                      DELETE PROCEDURE h-b1wgen0033.
        
                   IF RETURN-VALUE <> "OK" THEN
                      DO:
                         FIND FIRST tt-erro NO-LOCK NO-ERROR.

                         IF AVAIL tt-erro   THEN
                            MESSAGE tt-erro.dscritic.
                         ELSE
                            MESSAGE "Erro na atualização de seguradora.".
                         
                         PAUSE.
                            
                         NEXT.
                      END.
        
                   OPEN QUERY q_seguradora 
                         FOR EACH tt-seguradora
                             WHERE tt-seguradora.cdcooper = glb_cdcooper
                                   NO-LOCK BY tt-seguradora.cdsegura.
        
                   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                      UPDATE b_seguradora WITH FRAME f_seguradora.
                      LEAVE.
                   END.
        
                   HIDE FRAME f_seguradora.
                   NEXT.
                END.
             ELSE
                APPLY LASTKEY.
        
         END.  /*  Fim do EDITING  */
        
         DO WHILE TRUE TRANSACTION:
        
            IF NOT VALID-HANDLE(h-b1wgen0033) THEN
               RUN sistema/generico/procedures/b1wgen0033.p 
                   PERSISTENT SET h-b1wgen0033.
        
            MESSAGE "Aguarde...Buscando plano.".

            RUN buscar_plano_seguro IN h-b1wgen0033(INPUT glb_cdcooper,
                                                    INPUT glb_cdagenci,
                                                    INPUT 0 /* glb_nrdcaixa */,
                                                    INPUT glb_cdoperad,
                                                    INPUT glb_dtmvtolt,
                                                    INPUT 0 /* glb_nrdconta */,
                                                    INPUT 1 /* par_idseqttl */,
                                                    INPUT 1 /* par_idorigem */,
                                                    INPUT glb_nmdatela,
                                                    INPUT FALSE,
                                                    INPUT tel_cdsegura,
                                                    INPUT tel_tpseguro,
                                                    INPUT tel_tpplaseg,
                                                    OUTPUT TABLE tt-plano-seg,
                                                    OUTPUT TABLE tt-erro).
        
            HIDE MESSAGE NO-PAUSE.

            IF VALID-HANDLE(h-b1wgen0033) THEN
               DELETE PROCEDURE h-b1wgen0033.
        
            IF RETURN-VALUE <> "OK" THEN
               DO:
                  FIND FIRST tt-erro NO-LOCK NO-ERROR.

                  IF AVAIL tt-erro   THEN
                     MESSAGE tt-erro.dscritic.
                  ELSE
                     MESSAGE "Erro na busca de plano seguro.".
                  
                  PAUSE.
                     
                  LEAVE.
               END.
        
            FIND tt-plano-seg WHERE tt-plano-seg.cdcooper = glb_cdcooper  AND 
                                    tt-plano-seg.cdsegura = tel_cdsegura  AND 
                                    tt-plano-seg.tpseguro = tel_tpseguro  AND 
                                    tt-plano-seg.tpplaseg = tel_tpplaseg 
                                    NO-ERROR.
        
            IF NOT AVAIL tt-plano-seg THEN
               LEAVE.
        
            ASSIGN glb_cdcritic = 0
                   tel_vlplaseg = tt-plano-seg.vlplaseg
                   tel_dsocupac = tt-plano-seg.dsocupac
                   tel_dsgarant = tt-plano-seg.dsgarant
                   tel_nrtabela = tt-plano-seg.nrtabela
                   tel_dsmorada = tt-plano-seg.dsmorada
                   tel_vlmorada = tt-plano-seg.vlmorada
                   tel_flgunica = tt-plano-seg.flgunica
                   tel_flgconsi = IF tt-plano-seg.inplaseg = 1 THEN 
                                     TRUE
                                  ELSE 
                                     FALSE
                   tel_cdsitpla = IF tt-plano-seg.cdsitpsg = 1 THEN 
                                     TRUE
                                  ELSE 
                                     FALSE
                   tel_ddcancel = tt-plano-seg.ddcancel
                   tel_dddcorte = tt-plano-seg.dddcorte
                   tel_ddmaxpag = tt-plano-seg.ddmaxpag
                   tel_mmpripag = tt-plano-seg.mmpripag
                   tel_qtdiacar = tt-plano-seg.qtdiacar
                   tel_qtmaxpar = tt-plano-seg.qtmaxpar.
        
            IF tt-plano-seg.tpseguro = 11 THEN
               ASSIGN tel_dsinplse = "Qtd.Parcelas Fixas:".
            ELSE
               ASSIGN tel_dsinplse = "    Consiste Valor:".
        
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
               IF tt-plano-seg.tpseguro = 11 THEN 
                  DO:
                     DISPLAY tel_dsinplse 
                             WITH FRAME f_seguro_casa.
                     
                     UPDATE tel_dsmorada 
                            tel_vlplaseg 
                            tel_dsocupac 
                            tel_nrtabela
                            tel_flgunica 
                            tel_flgconsi 
                            tel_cdsitpla
                            tel_ddcancel 
                            tel_dddcorte 
                            tel_ddmaxpag
                            tel_mmpripag 
                            tel_qtdiacar 
                            tel_qtmaxpar
                            WITH FRAME f_seguro_casa.

                  END.
               ELSE 
                  DO:
                     DISPLAY tel_dsinplse 
                             WITH FRAME f_seguro.
                     
                     UPDATE tel_dsmorada 
                            tel_vlplaseg 
                            tel_dsocupac 
                            tel_nrtabela 
                            tel_vlmorada
                            tel_flgunica 
                            tel_flgconsi 
                            tel_cdsitpla
                            tel_ddcancel 
                            tel_dddcorte 
                            tel_ddmaxpag
                            tel_mmpripag 
                            tel_qtdiacar 
                            tel_qtmaxpar
                            WITH FRAME f_seguro.

                  END.
        
               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
                  ASSIGN aux_confirma = "N"
                         glb_cdcritic = 78.
        
                  RUN fontes/critic.p.
                  BELL.
                  MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
                  ASSIGN glb_cdcritic = 0.
                  LEAVE.

               END.  /*  Fim do DO WHILE TRUE  */
        
               IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR 
                  aux_confirma <> "S"                THEN 
                  DO:
                     ASSIGN glb_cdcritic = 79.
                     RUN fontes/critic.p.
                     BELL.
                     MESSAGE glb_dscritic.
                     ASSIGN glb_cdcritic = 0.
                     NEXT.
                  END.

               LEAVE.

            END.  /*  Fim do DO WHILE TRUE  */
        
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN 
               LEAVE. 
        
            ASSIGN tt-plano-seg.cdsitpsg = IF tel_cdsitpla = TRUE THEN
                                              1  
                                           ELSE 
                                              2
                   tt-plano-seg.ddcancel = tel_ddcancel
                   tt-plano-seg.dddcorte = tel_dddcorte
                   tt-plano-seg.ddmaxpag = tel_ddmaxpag
                   tt-plano-seg.dsgarant = tel_dsgarant
                   tt-plano-seg.dsmorada = tel_dsmorada
                   tt-plano-seg.dsocupac = tel_dsocupac
                   tt-plano-seg.flgunica = tel_flgunica
                   tt-plano-seg.inplaseg = IF tel_flgconsi = TRUE THEN 
                                              1 
                                           ELSE 
                                              2
                   tt-plano-seg.mmpripag = tel_mmpripag
                   tt-plano-seg.nrtabela = tel_nrtabela
                   tt-plano-seg.qtdiacar = tel_qtdiacar
                   tt-plano-seg.qtmaxpar = tel_qtmaxpar
                   tt-plano-seg.vlmorada = tel_vlmorada
                   tt-plano-seg.vlplaseg = tel_vlplaseg.
        
            IF NOT VALID-HANDLE(h-b1wgen0033) THEN
               RUN sistema/generico/procedures/b1wgen0033.p 
                   PERSISTENT SET h-b1wgen0033.
        
            MESSAGE "Aguarde...Atualizando plano.".

            RUN atualizar_plano_seguro IN h-b1wgen0033 
                (INPUT glb_cdcooper,
                 INPUT glb_cdagenci,
                 INPUT 0 /* glb_nrdcaixa */,
                 INPUT glb_cdoperad,
                 INPUT glb_dtmvtolt,
                 INPUT 0 /* glb_nrdconta */,
                 INPUT 1 /* par_idseqttl */,
                 INPUT 1 /* par_idorigem */,
                 INPUT glb_nmdatela,
                 INPUT FALSE,
                 INPUT tel_cdsegura,
                 INPUT tt-plano-seg.cdsitpsg,
                 INPUT tt-plano-seg.dsmorada,
                 INPUT tt-plano-seg.ddcancel,
                 INPUT tt-plano-seg.dddcorte,
                 INPUT tt-plano-seg.ddmaxpag,
                 INPUT tt-plano-seg.dsocupac,
                 INPUT tt-plano-seg.flgunica,
                 INPUT tt-plano-seg.inplaseg,
                 INPUT tt-plano-seg.mmpripag,
                 INPUT tt-plano-seg.nrtabela,
                 INPUT tt-plano-seg.qtdiacar,
                 INPUT tt-plano-seg.qtmaxpar,
                 INPUT tt-plano-seg.tpplaseg,
                 INPUT tt-plano-seg.tpseguro,
                 INPUT tt-plano-seg.vlmorada,
                 INPUT tt-plano-seg.vlplaseg,
                 OUTPUT TABLE tt-erro).
        
            HIDE MESSAGE NO-PAUSE.

            IF RETURN-VALUE <> "OK" THEN
               DO:
                  IF VALID-HANDLE(h-b1wgen0033) THEN
                     DELETE PROCEDURE h-b1wgen0033.

                  FIND FIRST tt-erro NO-LOCK NO-ERROR.

                  IF AVAIL tt-erro   THEN
                     MESSAGE tt-erro.dscritic.
                  ELSE
                     MESSAGE "Erro na atualização de plano seguro.".
                  
                  PAUSE.
                     
                  LEAVE.
               END.
        
            IF VALID-HANDLE(h-b1wgen0033) THEN
               DELETE PROCEDURE h-b1wgen0033.
        
            LEAVE.
        
         END.  /*  Fim do DO WHILE TRUE  TRANSACTION */

      END.   /* glb-cddopcao = "A" */
   ELSE
   IF glb_cddopcao = "K" THEN 
      DO:
         ASSIGN tel_tpseguro = 0 
                tel_tpplaseg = 0
                tel_nrtabela = 0
                tel_vlpercen = 0
                tel_datdebit = ?
                tel_datdespr =?. 

         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            UPDATE tel_tpseguro 
                  tel_tpplaseg
                  tel_nrtabela
                  tel_vlpercen
                  tel_datdebit 
                  tel_datdespr  
                  WITH FRAME f_selecao_k.

            LEAVE.

         END.

         IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
            NEXT.
        
         RUN gera_atualizacao.

         IF RETURN-VALUE <> "OK" THEN
            NEXT.

      END.
   ELSE
   IF glb_cddopcao = "C" THEN 
      DO:
         ASSIGN tel_cdsegura = 0
                tel_nmsegura = ""
                tel_tpseguro = 0
                tel_tpplaseg = 0.
         
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
            UPDATE tel_cdsegura 
                   tel_tpseguro 
                   tel_tpplaseg 
                   WITH FRAME f_selecao
            
              EDITING:
              
                  READKEY.
              
                  IF LASTKEY = KEYCODE("F7")       AND 
                     FRAME-FIELD = "tel_cdsegura"  THEN 
                     DO:
                        IF NOT VALID-HANDLE(h-b1wgen0033) THEN
                           RUN sistema/generico/procedures/b1wgen0033.p 
                               PERSISTENT SET h-b1wgen0033.
                        
                        MESSAGE "Aguarde...Buscando seguradora.".

                        RUN buscar_seguradora IN h-b1wgen0033
                            (INPUT glb_cdcooper,
                             INPUT glb_cdagenci,
                             INPUT 0 /* glb_nrdcaixa */,
                             INPUT glb_cdoperad,
                             INPUT glb_dtmvtolt,
                             INPUT 0 /* glb_nrdconta */,
                             INPUT 1 /* par_idseqttl */,
                             INPUT 1 /* par_idorigem */,
                             INPUT glb_nmdatela,
                             INPUT FALSE,
                             INPUT 0,
                             INPUT 0,
                             INPUT 0,
                             INPUT "",
                             OUTPUT aux_qtregist,
                             OUTPUT TABLE tt-seguradora,
                             OUTPUT TABLE tt-erro).
                        
                        HIDE MESSAGE NO-PAUSE.

                        IF VALID-HANDLE(h-b1wgen0033) THEN
                           DELETE PROCEDURE h-b1wgen0033.
                        
                        IF RETURN-VALUE <> "OK" THEN
                           DO:
                              FIND FIRST tt-erro NO-LOCK NO-ERROR.
            
                              IF AVAIL tt-erro   THEN
                                 MESSAGE tt-erro.dscritic.
                              ELSE
                                 MESSAGE "Erro na busca de seguradora.".
                              
                              PAUSE.
                                 
                              NEXT.
                           END.
                        
                        OPEN QUERY q_seguradora 
                             FOR EACH tt-seguradora 
                                WHERE tt-seguradora.cdcooper = glb_cdcooper
                                      NO-LOCK BY tt-seguradora.cdsegura.
                        
                        DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                           UPDATE b_seguradora WITH FRAME f_seguradora.
                           LEAVE.
                        END.
                        
                        HIDE FRAME f_seguradora.

                        IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                           NEXT.
                        
                     END.
                  ELSE
                     APPLY LASTKEY.
              
              END.  /*  Fim do EDITING  */

              LEAVE.

         END.

         IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
            NEXT.

         IF tel_tpplaseg = 0 THEN 
            DO: 
               IF NOT VALID-HANDLE(h-b1wgen0033) THEN
                  RUN sistema/generico/procedures/b1wgen0033.p 
                      PERSISTENT SET h-b1wgen0033.

               MESSAGE "Aguarde...Buscando plano.".

               RUN buscar_plano_seguro IN h-b1wgen0033 
                   (INPUT glb_cdcooper,
                    INPUT glb_cdagenci,
                    INPUT 0 /* glb_nrdcaixa */,
                    INPUT glb_cdoperad,
                    INPUT glb_dtmvtolt,
                    INPUT 0 /* glb_nrdconta */,
                    INPUT 1 /* par_idseqttl */,
                    INPUT 1 /* par_idorigem */,
                    INPUT glb_nmdatela,
                    INPUT FALSE,
                    INPUT tel_cdsegura,
                    INPUT tel_tpseguro,
                    INPUT 0,
                    OUTPUT TABLE tt-plano-seg,
                    OUTPUT TABLE tt-erro).
               
               HIDE MESSAGE NO-PAUSE.

               IF VALID-HANDLE(h-b1wgen0033) THEN
                  DELETE PROCEDURE h-b1wgen0033.
               
               IF RETURN-VALUE <> "OK" THEN
                  DO: 
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.

                     IF AVAIL tt-erro   THEN
                        MESSAGE tt-erro.dscritic.
                     ELSE
                        MESSAGE "Erro na busca de plano seguro.".
                     
                     PAUSE.
                        
                     NEXT.
                  END.
                  
               OPEN QUERY q_craptsg 
                    FOR EACH tt-plano-seg 
                        WHERE tt-plano-seg.cdcooper = glb_cdcooper  AND 
                              tt-plano-seg.cdsegura = tel_cdsegura  AND 
                              tt-plano-seg.tpseguro = tel_tpseguro 
                              BY tt-plano-seg.tpseguro
                               BY tt-plano-seg.tpplaseg.
               
               ENABLE b_craptsg WITH FRAME f_craptsg_b.      
               
               WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
               
               HIDE FRAME f_craptsg_b. 
               
               HIDE MESSAGE NO-PAUSE.
         
            END.
         ELSE 
            DO:
               IF NOT VALID-HANDLE(h-b1wgen0033) THEN
                  RUN sistema/generico/procedures/b1wgen0033.p 
                      PERSISTENT SET h-b1wgen0033.
               
               MESSAGE "Aguarde...Buscando plano.".

               RUN buscar_plano_seguro IN h-b1wgen0033 
                   (INPUT glb_cdcooper,
                    INPUT glb_cdagenci,
                    INPUT 0 /* glb_nrdcaixa */,
                    INPUT glb_cdoperad,
                    INPUT glb_dtmvtolt,
                    INPUT 0 /* glb_nrdconta */,
                    INPUT 1 /* par_idseqttl */,
                    INPUT 1 /* par_idorigem */,
                    INPUT glb_nmdatela,
                    INPUT FALSE,
                    INPUT tel_cdsegura,
                    INPUT tel_tpseguro,
                    INPUT tel_tpplaseg,
                    OUTPUT TABLE tt-plano-seg,
                    OUTPUT TABLE tt-erro).

               HIDE MESSAGE NO-PAUSE.

               IF VALID-HANDLE(h-b1wgen0033) THEN
                  DELETE PROCEDURE h-b1wgen0033.
               
               IF RETURN-VALUE <> "OK" THEN
                  DO:
                     FIND FIRST tt-erro NO-LOCK NO-ERROR.

                     IF AVAIL tt-erro   THEN
                        MESSAGE tt-erro.dscritic.
                     ELSE
                        MESSAGE "Erro na busca de plano seguro.".

                     PAUSE.
                        
                     NEXT.
                  END.
               
               FIND tt-plano-seg WHERE 
                    tt-plano-seg.cdcooper = glb_cdcooper  AND 
                    tt-plano-seg.cdsegura = tel_cdsegura  AND 
                    tt-plano-seg.tpseguro = tel_tpseguro  AND 
                    tt-plano-seg.tpplaseg = tel_tpplaseg 
                    NO-ERROR.
               
               ASSIGN tel_vlplaseg = tt-plano-seg.vlplaseg
                      tel_dsocupac = tt-plano-seg.dsocupac
                      tel_dsgarant = tt-plano-seg.dsgarant
                      tel_nrtabela = tt-plano-seg.nrtabela
                      tel_dsmorada = tt-plano-seg.dsmorada
                      tel_vlmorada = tt-plano-seg.vlmorada
                      tel_flgunica = tt-plano-seg.flgunica
                      tel_flgconsi = IF tt-plano-seg.inplaseg = 1 THEN 
                                        TRUE 
                                     ELSE 
                                        FALSE
                      tel_cdsitpla = IF tt-plano-seg.cdsitpsg = 1 THEN 
                                        TRUE 
                                     ELSE 
                                        FALSE
                      tel_ddcancel = tt-plano-seg.ddcancel
                      tel_dddcorte = tt-plano-seg.dddcorte
                      tel_ddmaxpag = tt-plano-seg.ddmaxpag
                      tel_mmpripag = tt-plano-seg.mmpripag
                      tel_qtdiacar = tt-plano-seg.qtdiacar
                      tel_qtmaxpar = tt-plano-seg.qtmaxpar.
                      
               IF tt-plano-seg.tpseguro = 11 THEN 
                  DO:
                     ASSIGN tel_dsinplse = "Qtd.Parcelas Fixas:".
                     
                     DISPLAY tel_vlplaseg 
                             tel_dsocupac
                             tel_nrtabela 
                             tel_dsmorada
                             tel_flgunica 
                             tel_flgconsi 
                             tel_cdsitpla
                             tel_ddcancel 
                             tel_dddcorte 
                             tel_ddmaxpag
                             tel_mmpripag 
                             tel_qtdiacar 
                             tel_qtmaxpar
                             tel_dsinplse
                             WITH FRAME f_seguro_casa.
                     
                     DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 
                        MESSAGE "Pressione ENTER para continuar".
                        PAUSE.
                        LEAVE.
                     END.
                     
                     IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
                        NEXT.
                     
                     HIDE FRAME f_seguro_casa NO-PAUSE.
                     
                     IF NOT VALID-HANDLE(h-b1wgen0033) THEN
                        RUN sistema/generico/procedures/b1wgen0033.p 
                            PERSISTENT SET h-b1wgen0033.
                     
                     MESSAGE "Aguarde...Buscando garantias.".

                     RUN buscar_garantias IN h-b1wgen0033 
                         (INPUT glb_cdcooper,
                          INPUT glb_cdagenci,
                          INPUT 0 /* glb_nrdcaixa */,
                          INPUT glb_cdoperad,
                          INPUT glb_dtmvtolt,
                          INPUT 0 /* glb_nrdconta */,
                          INPUT 1 /* par_idseqttl */,
                          INPUT 1 /* par_idorigem */,
                          INPUT glb_nmdatela,
                          INPUT FALSE,
                          INPUT tt-plano-seg.cdsegura,
                          INPUT tt-plano-seg.tpseguro,
                          INPUT tt-plano-seg.tpplaseg,
                          INPUT 0,
                          OUTPUT TABLE tt-gar-seg,
                          OUTPUT TABLE tt-erro).
                     
                     HIDE MESSAGE NO-PAUSE.

                     IF VALID-HANDLE(h-b1wgen0033) THEN
                        DELETE PROCEDURE h-b1wgen0033.
                     
                     IF RETURN-VALUE <> "OK" THEN
                        DO:
                           FIND FIRST tt-erro NO-LOCK NO-ERROR.
                           
                           IF AVAIL tt-erro   THEN
                              MESSAGE tt-erro.dscritic.
                           ELSE
                              MESSAGE "Erro na busca de garantia.".
                           
                           PAUSE.
                              
                           NEXT.
                        END.
                     
                     OPEN QUERY q_crapgsg FOR EACH tt-gar-seg WHERE 
                         tt-gar-seg.cdcooper = tt-plano-seg.cdcooper AND 
                         tt-gar-seg.cdsegura = tt-plano-seg.cdsegura AND 
                         tt-gar-seg.tpplaseg = tt-plano-seg.tpplaseg AND 
                         tt-gar-seg.tpseguro = tt-plano-seg.tpseguro.
                     
                     ENABLE b_crapgsg WITH FRAME f_b_crapgsg.     

                     WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                     
                     HIDE FRAME f_b_crapgsg. 
                     
                     HIDE MESSAGE NO-PAUSE.

                  END.
               ELSE 
                  DO:
                     ASSIGN tel_dsinplse = "    Consiste Valor:".
                     
                     DISPLAY tel_vlplaseg 
                             tel_dsocupac
                             tel_nrtabela 
                             tel_dsmorada 
                             tel_vlmorada
                             tel_flgunica 
                             tel_flgconsi 
                             tel_cdsitpla
                             tel_ddcancel 
                             tel_dddcorte 
                             tel_ddmaxpag
                             tel_mmpripag   
                             tel_qtdiacar 
                             tel_qtmaxpar
                             tel_dsinplse
                             WITH FRAME f_seguro.

                  END.

            END.
      
      END.

END.  /*  Fim do DO WHILE TRUE  */

PROCEDURE gera_atualizacao:

  EMPTY TEMP-TABLE crawtsg.

  IF NOT VALID-HANDLE(h-b1wgen0033) THEN
     RUN sistema/generico/procedures/b1wgen0033.p
         PERSISTENT SET h-b1wgen0033.
                 
  MESSAGE "Aguarde...Atualizando percentual.".

  RUN pi_atualizar_perc_seg IN h-b1wgen0033(INPUT glb_cdcooper,
                                            INPUT glb_cdagenci,
                                            INPUT 0 /* glb_nrdcaixa */,
                                            INPUT glb_cdoperad,
                                            INPUT glb_dtmvtolt,
                                            INPUT 0 /* glb_nrdconta */,
                                            INPUT 1 /* par_idseqttl */,
                                            INPUT 1 /* par_idorigem */,
                                            input glb_nmdatela,   
                                            input FALSE,
                                            INPUT tel_nrtabela,
                                            INPUT tel_tpseguro, 
                                            INPUT tel_tpplaseg,
                                            INPUT tel_datdespr,
                                            INPUT tel_datdebit,
                                            INPUT tel_vlpercen,
                                            INPUT 9999, /*nrregist*/
                                            INPUT 1, /*nriniseq*/
                                            OUTPUT aux_qtregist,
                                            OUTPUT TABLE cratseg,
                                            OUTPUT TABLE tt-erro).
                                            
  HIDE MESSAGE NO-PAUSE.

  IF RETURN-VALUE <> "OK" THEN
     DO:
        IF VALID-HANDLE(h-b1wgen0033) THEN
           DELETE PROCEDURE h-b1wgen0033.

        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF AVAIL tt-erro   THEN
           MESSAGE tt-erro.dscritic.
        ELSE
           MESSAGE "Erro na atualização de porcentagem do seguro.".
        
        PAUSE.
           
        RETURN "NOK".

     END.

  IF VALID-HANDLE(h-b1wgen0033) THEN
     DELETE PROCEDURE h-b1wgen0033.

  OPEN QUERY q_cratseg FOR EACH cratseg NO-LOCK BY cratseg.tpseguro
                                                 BY cratseg.tpplaseg
                                                  BY cratseg.dtdebito
                                                   BY cratseg.nrdconta
                                                    BY cratseg.nrctrseg.
                                               
  ENABLE b_cratseg WITH FRAME f_cratseg_b.

  WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                       
  HIDE FRAME f_cratseg_b. 
    
  HIDE MESSAGE NO-PAUSE.
      
  ASSIGN aux_flglista = no.

  UPDATE aux_flglista  WITH FRAME f_lista.

  IF aux_flglista = yes THEN
     DO:
        /*----Relatorio Movtos(Seguro)  a serem Atualizados ----*/
        IF NOT VALID-HANDLE(h-b1wgen0033) THEN
           RUN sistema/generico/procedures/b1wgen0033.p
               PERSISTENT SET h-b1wgen0033.
             
         MESSAGE "Aguarde...Gerando relatorio.".

         RUN imprimir_seg_atualizados IN h-b1wgen0033(INPUT glb_cdcooper,
                                                      INPUT glb_cdagenci,
                                                      INPUT 0 /* glb_nrdcaixa */,
                                                      INPUT glb_cdoperad,
                                                      INPUT glb_dtmvtolt,
                                                      INPUT 0 /* glb_nrdconta */,
                                                      INPUT 1 /* par_idseqttl */,
                                                      INPUT 1 /* par_idorigem */,
                                                      INPUT glb_nmdatela,   
                                                      INPUT FALSE,
                                                      INPUT tel_nrtabela,
                                                      INPUT tel_tpseguro, 
                                                      INPUT tel_tpplaseg,
                                                      INPUT tel_datdespr,
                                                      INPUT tel_datdebit,
                                                      INPUT tel_vlpercen,
                                                      OUTPUT aux_nmarqimp,
                                                      OUTPUT aux_nmarqpdf,
                                                      OUTPUT TABLE tt-erro).

         HIDE MESSAGE NO-PAUSE.

         IF VALID-HANDLE(h-b1wgen0033) THEN
            DELETE PROCEDURE h-b1wgen0033.

         IF RETURN-VALUE <> "OK" THEN
            DO:
               FIND FIRST tt-erro NO-LOCK NO-ERROR.

               IF AVAIL tt-erro   THEN
                  MESSAGE tt-erro.dscritic.
               ELSE
                  MESSAGE "Erro na impressao de seguro.".
               
               PAUSE.
                  
               RETURN "NOK".
            END.
            
     END.

  HIDE FRAME f_lista NO-PAUSE.
  
  DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

     ASSIGN aux_confirma = "N"
            glb_cdcritic = 78.
     
     RUN fontes/critic.p.
     
     BELL.

     MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
     
     ASSIGN glb_cdcritic = 0.
     
     LEAVE.

  END.

  IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
     aux_confirma <> "S"                THEN
     DO:
        ASSIGN glb_cdcritic = 79.
        RUN fontes/critic.p.
        BELL.
        MESSAGE glb_dscritic.
        ASSIGN glb_cdcritic = 0.
        NEXT.
     END.

  RUN atualiza_movimentos.

  IF RETURN-VALUE <> "OK" THEN
     RETURN "NOK".
  
  MESSAGE "Movtos atualizados         ".
  MESSAGE "                           ".

  RETURN "OK".

END PROCEDURE.

PROCEDURE atualiza_movimentos:

  IF NOT VALID-HANDLE(h-b1wgen0033) THEN
     RUN sistema/generico/procedures/b1wgen0033.p
         PERSISTENT SET h-b1wgen0033.

  MESSAGE "Aguarde...Atualizando valor.".

  RUN pi_atualizar_valor_seg IN h-b1wgen0033(INPUT glb_cdcooper,
                                             INPUT glb_cdagenci,
                                             INPUT 0 /* glb_nrdcaixa */,
                                             INPUT glb_cdoperad,
                                             INPUT glb_dtmvtolt,
                                             INPUT 0 /* glb_nrdconta */,
                                             INPUT 1 /* par_idseqttl */,
                                             INPUT 1 /* par_idorigem */,
                                             input glb_nmdatela,       
                                             input FALSE,              
                                             INPUT tel_nrtabela,       
                                             INPUT tel_tpseguro,       
                                             INPUT tel_tpplaseg,       
                                             INPUT tel_datdespr,  
                                             INPUT tel_datdebit,           
                                             INPUT tel_vlpercen,       
                                             OUTPUT TABLE tt-erro).
  
  HIDE MESSAGE NO-PAUSE.

  IF VALID-HANDLE(h-b1wgen0033) THEN
     DELETE PROCEDURE h-b1wgen0033.

  IF RETURN-VALUE <> "OK" THEN
     DO:
        FIND FIRST tt-erro NO-LOCK NO-ERROR.

        IF AVAIL tt-erro   THEN
           MESSAGE tt-erro.dscritic.
        ELSE
           MESSAGE "Erro na atualização de valor do seguro.".
        
        PAUSE.
           
        RETURN "NOK".

     END.

  RETURN "OK".

END PROCEDURE.

/* .......................................................................... */
 


