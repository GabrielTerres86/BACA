/* ............................................................................

   Programa: Fontes/pesqti.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autora  : Mirtes
   Data    : Fevereiro/2004                      Ultima alteracao: 05/10/2015

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar dados do titulo a partir de uma data e valor informados
   
   Alteracoes: 26/11/2004 - Exibir maiores informacoes dos titulos (Evandro).
        
               31/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               13/09/2006 - Inclusao da consulta de faturas (Elton).
               
               23/07/2007 - Acusava erro de progress quando vl da fatura/titulo
                            era maior do que havia em registro(Guilherme).

               25/02/2008 - Inclusao de consulta por PAC e mostrar numero da
                            conta do cooperado (Gabriel).
                            
               20/10/2010 - Inclusao cdcoptfn (COOPERATIVA), cdagectl (PAC) e 
                            nrterfin (TAA) (Vitor).
                            
               16/02/2011 - Incluido campo para mostrar somatoria das faturas 
                            e lancamentos do dia (Adriano).              
                            
               10/05/2011 - Incluido campo craptit.flgpgdda na visualizacao
                            dos detalhes do titulo (Henrique).      
                            
               16/08/2011 - Realizado alteracoes para disponibilizacao desta
                            tela no ayllos web (Adriano).      
                            
               06/08/2012 - Criada Listagem de historicos
                          - Exibir Vl do Conv. com a Foz e Sit. da Fatura
                          - Implementada Opção A (Lucas).     
                          
               18/04/2013 - Tratamento para consulta de faturas de Conv.
                            SICREDI (Lucas).
                            
               29/05/2013 - Exibição ordenada por valor da fatura (Lucas).
               
               14/08/2013 - Nova forma de chamar as agências, de PAC agora 
                            a escrita será PA (André Euzébio - Supero).  
                            
               12/06/2014 - Alteração para exibir detalhes de DARFs 
                            arrecadadas na Rot. 41 (SD. 75897 Lunelli)

               16/12/2014 - #203812 Para as faturas (Cecred e Sicredi) no lugar 
                            da descrição do Banco Destino e o nome do banco, 
                            apresentar: Convênio e Nome do convênio (Carlos)
                            
               23/06/2015 - Ajusta para realizar a alteracao de faturas
                            corretamente (Adriano).             
               
               24/08/2015 - Inserido campo origem de pagamento nos detalhes
                            de fatura e titulo e aumentado o format do campo
                            tel_vlrtotal (melhoria 21 Tiago/Fabricio).
                            
               05/10/2015 - Correcoes na consulta de faturas 
                           (#339463 Tiago/Fabricio).
............................................................................ */

{ sistema/generico/includes/var_internet.i } 
{ sistema/generico/includes/b1wgen0101tt.i }
{ includes/var_online.i }


DEF        VAR tel_cdagenci LIKE      crapass.cdagenci               NO-UNDO.
DEF        VAR tel_vldpagto AS DEC    FORMAT "zzz,zz9.99"            NO-UNDO.
DEF        VAR tel_dtdpagto AS DATE   FORMAT "99/99/9999"            NO-UNDO.
DEF        VAR aux_cddopcao AS CHAR                                  NO-UNDO.
DEF        VAR tel_tpdpagto AS CHAR   FORMAT "!(1)"                  NO-UNDO.
DEF        VAR tel_vlrtotal AS DEC    FORMAT "zzz,zzz,zzz,zz9.99"    NO-UNDO.
DEF        VAR aux_confirma AS CHAR   FORMAT "!"                     NO-UNDO.
DEF        VAR aux_qtregist AS INT                                   NO-UNDO.
DEF        VAR tel_qtntotal AS INT    FORMAT "zz,zz9"                NO-UNDO.
DEF        VAR tel_cdhistor AS INT    FORMAT "zzzz9"                 NO-UNDO.

DEF        VAR tel_flgcnvsi AS LOGI   FORMAT "Sim/Nao" INIT FALSE    NO-UNDO.
DEF        VAR tel_cdempcon AS INTE   FORMAT "zzz9"                  NO-UNDO.
DEF        VAR tel_cdsegmto AS INTE   FORMAT "zzzzzzzz9"             NO-UNDO.

DEF        VAR tel_dscodbar AS CHAR                                  NO-UNDO.
DEF        VAR tel_insitfat AS CHAR                                  NO-UNDO.
DEF        VAR dscptdoc     AS CHAR                                  NO-UNDO.

DEF        VAR h-b1wgen0101 AS HANDLE                                NO-UNDO.

DEF QUERY q_pesqti     FOR tt-dados-pesqti.
DEF QUERY q_historicos FOR tt-historicos.
DEF QUERY bconvenios-q FOR tt-empr-conve.
                                     
DEF BROWSE b_pesqti QUERY q_pesqti 
    DISPLAY tt-dados-pesqti.cdagenci COLUMN-LABEL "PA" 
                                     FORMAT "zz9"
            tt-dados-pesqti.vldpagto COLUMN-LABEL "Valor" 
                                     FORMAT "zzz,zzz,zzz,zz9.99"
            tt-dados-pesqti.nmoperad COLUMN-LABEL "Operador" 
                                     FORMAT "x(25)"
            tt-dados-pesqti.nrdolote COLUMN-LABEL "Lote"
                                     FORMAT "zzz,zz9"
            WITH 3 DOWN.

DEF BROWSE bconvenios-b QUERY bconvenios-q
      DISP SPACE(2)
           nmextcon                     COLUMN-LABEL "Nome Convenio"
           SPACE(1)
           cdempcon                     COLUMN-LABEL "Codigo"
           SPACE(1)
           cdsegmto                     COLUMN-LABEL "Segmento"
           SPACE(1)
           WITH 9 DOWN OVERLAY NO-BOX.  

DEF BROWSE b_historicos QUERY q_historicos
    DISP tt-historicos.cdhiscxa     COLUMN-LABEL "Cod"
         tt-historicos.nmempres     COLUMN-LABEL "Convenio"
         WITH 9 DOWN OVERLAY TITLE "Historicos".

FORM b_historicos HELP "Use as SETAS para navegar." SKIP
     WITH NO-BOX CENTERED OVERLAY ROW 8 FRAME f_historicos. 

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C ou A)."
                        VALIDATE(CAN-DO("C,A",glb_cddopcao),
                                 "014 - Opcao errada.")
     WITH ROW 6 COLUMN 2 SIDE-LABELS OVERLAY NO-BOX FRAME f_opcao.

DEF FRAME f_pesqti  
          b_pesqti   HELP  "Pressione <F4> ou <END> p/finalizar"
          WITH NO-BOX CENTERED OVERLAY ROW 8.

FORM tel_tpdpagto LABEL "Tipo Pagto"
                  VALIDATE (CAN-DO("F,T",tel_tpdpagto), "Tipo errado.")
                  HELP 'Informe "T" p/consultar TITULOS ou "F" p/consultar FATURAS.'
     tel_flgcnvsi LABEL "Sicredi"
                  HELP  "Informe se as faturas são de Cnv. SICREDI." 
     tel_dtdpagto LABEL "Data"
                  HELP  "Informe a data de referencia do movimento." 
     SPACE(2)
     WITH ROW 6 COLUMN 14 SIDE-LABELS OVERLAY NO-BOX FRAME f_tipo_pagto.
     
FORM tel_cdagenci       LABEL "PA"
                        HELP  "Informe o numero do PA ou 0 para todos."
     tel_cdhistor       LABEL "Hist."
                        HELP  "Informe o numero do Historico ou F7 p/ listar."
     tel_cdempcon       LABEL "Empresa"
                        HELP  "Informe o numero da Empresa ou F7 p/ listar."
     tel_cdsegmto       LABEL "Segmto"
                        HELP  "Informe o numero do Segmento."
     tel_vldpagto       LABEL " Valor"
                        HELP "Informe o valor a ser pesquisado(maior ou igual)."
     WITH ROW 7 COLUMN 4 SIDE-LABELS OVERLAY NO-BOX FRAME f_refere.

DEF FRAME f_emp_convenioc
          bconvenios-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7 VIEW-AS DIALOG-BOX.
     
FORM tel_qtntotal LABEL "Qtd."  AT 8
     tel_vlrtotal LABEL "Total" AT 22
     tt-dados-pesqti.vlconfoz LABEL "Valor Foz" AT 45
     WITH NO-BOX SIDE-LABELS ROW 15 COLUMN 3 OVERLAY FRAME f_soma.

FORM tt-dados-pesqti.dspactaa AT 40 LABEL "COOPERATIVA/PA/TAA" FORMAT "x(14)"
     SKIP
     tt-dados-pesqti.nrautdoc LABEL "Autenticacao " FORMAT "zzz,zz9"
     SPACE(6)
     tt-dados-pesqti.nrdocmto LABEL "Docto" FORMAT "zzz,zzz,zz9"  
     SPACE(11)
     tt-dados-pesqti.flgpgdda LABEL "Pago DDA" FORMAT "SIM/NAO"
     SKIP
     tt-dados-pesqti.cdbandst LABEL "Banco Destin." FORMAT "zz9"
     "-"
     tt-dados-pesqti.nmextbcc NO-LABEL FORMAT "x(35)"
     tt-dados-pesqti.nrdconta LABEL "Conta/dv"  FORMAT "zzzz,zzz,z"
     SKIP
     tt-dados-pesqti.dscodbar LABEL "Cod.de Barras" FORMAT "x(44)"
     SKIP
     tt-dados-pesqti.dscptdoc LABEL "Origem Pagto." FORMAT "x(30)"
     WITH NO-BOX SIDE-LABELS ROW 16 COLUMN 3 OVERLAY FRAME f_detalhes_titulos.

FORM tt-dados-pesqti.dspactaa AT 40 LABEL "COOPERATIVA/PA/TAA" FORMAT "x(14)"
     SKIP
     tt-dados-pesqti.nrautdoc LABEL "Autenticacao" FORMAT "zzz,zz9" AT 2
     tt-dados-pesqti.nrdocmto LABEL "Seq" 
                              FORMAT "zz,zzz,zzz,zzz,zzz,zzz,zzz,zzz,zzz,zzz,zzz,zzz,zz9"
     SKIP
     tt-dados-pesqti.nmempres FORMAT "x(35)" AT 6
     tt-dados-pesqti.nrdconta LABEL "Conta/dv"  FORMAT "zzzz,zzz,z"
     SKIP
     tel_dscodbar LABEL "Cod.de Barras" FORMAT "x(44)" AT 1
     tel_insitfat             LABEL "Enviado" FORMAT "X(3)"
     SKIP
     tt-dados-pesqti.dscptdoc LABEL "Origem Pagto." FORMAT "x(30)"
     WITH NO-BOX SIDE-LABELS ROW 16 COLUMN 2 OVERLAY FRAME f_detalhes_faturas. 

FORM tt-dados-pesqti.dtapurac AT 3 LABEL "Periodo de apuracao"
     SPACE(11)
     tt-dados-pesqti.nrcpfcgc LABEL "CPF/CNPJ"
     SKIP
     tt-dados-pesqti.cdtribut AT 3 LABEL "Cod. Receita  "
     SPACE(20)
     tt-dados-pesqti.nrrefere LABEL "Referencia"
     SKIP
     tt-dados-pesqti.dtlimite AT 3 LABEL "Dt. Vencimento"
     SKIP
     tt-dados-pesqti.vllanmto AT 3 LABEL "Vlr. Principal"
     SPACE(6)
     tt-dados-pesqti.vlrmulta LABEL "Vlr. Multa"
     SKIP
     tt-dados-pesqti.vlrjuros AT 3 LABEL "Valor Juros   "
     SPACE(10)
     tt-dados-pesqti.vlrtotal LABEL "Vlr. Total"
     SKIP
     tt-dados-pesqti.vlrecbru AT 3 LABEL "Receita Bruta Acumulada"
     SPACE(3)
     tt-dados-pesqti.vlpercen LABEL "Percentual"
     WITH SIDE-LABELS ROW 10 COLUMN 2 WIDTH 78 OVERLAY TITLE "Detalhes da guia" 
     FRAME f_detalhes_darf_41.

ON END-ERROR OF bconvenios-b DO:

    DISABLE bconvenios-b WITH FRAME f_emp_convenioc.
    CLOSE QUERY bconvenios-q.
    HIDE FRAME f_emp_convenioc.

END.

ON  VALUE-CHANGED OF tel_insitfat IN FRAME f_detalhes_faturas
    DO:
        IF  FRAME-VALUE = "n" OR
            FRAME-VALUE = "N" THEN
            ASSIGN tel_insitfat = "NAO".
          
        IF  FRAME-VALUE = "s" OR 
            FRAME-VALUE = "S" THEN
            ASSIGN tel_insitfat = "SIM".
          
        DISPLAY tel_insitfat WITH FRAME f_detalhes_faturas.

        NEXT-PROMPT tel_insitfat WITH FRAME f_detalhes_faturas.

    END.

ON ITERATION-CHANGED OF b_pesqti DO:  

   IF  tel_tpdpagto = "T"  THEN
       DO:
           tt-dados-pesqti.dspactaa:VISIBLE 
                           IN FRAME f_detalhes_titulos = FALSE.  

           IF  tt-dados-pesqti.dspactaa = "" THEN
               DO:  
                   DISPLAY tt-dados-pesqti.nmextbcc
                           tt-dados-pesqti.cdbandst
                           tt-dados-pesqti.dscodbar
                           tt-dados-pesqti.nrautdoc
                           tt-dados-pesqti.nrdocmto
                           tt-dados-pesqti.flgpgdda
                           tt-dados-pesqti.nrdconta
                           tt-dados-pesqti.dscptdoc
                           WITH FRAME f_detalhes_titulos.
               END.
           ELSE
               DO:
                   tt-dados-pesqti.dspactaa:VISIBLE 
                                   IN FRAME f_detalhes_titulos = TRUE.
       
                   DISPLAY tt-dados-pesqti.dspactaa
                           tt-dados-pesqti.nmextbcc
                           tt-dados-pesqti.cdbandst
                           tt-dados-pesqti.dscodbar
                           tt-dados-pesqti.nrautdoc
                           tt-dados-pesqti.nrdocmto
                           tt-dados-pesqti.flgpgdda
                           tt-dados-pesqti.nrdconta
                           tt-dados-pesqti.dscptdoc
                           WITH FRAME f_detalhes_titulos.
               END.
       END.
   ELSE
       DO:
           HIDE MESSAGE NO-PAUSE.

           IF  LENGTH(tt-dados-pesqti.dscodbar) = 0 THEN
               MESSAGE "<ENTER> para detalhes da guia de DARF".
       
           ASSIGN tel_insitfat = IF tt-dados-pesqti.insitfat = 1 THEN "NAO" 
                                 ELSE "SIM"
                  tel_dscodbar = tt-dados-pesqti.dscodbar.


           tt-dados-pesqti.dspactaa:VISIBLE 
                         IN FRAME f_detalhes_faturas = FALSE.  


           IF  tt-dados-pesqti.dspactaa = "" THEN
               DO:
                   IF tt-dados-pesqti.vlconfoz:VISIBLE IN FRAME f_soma = TRUE THEN
                       DISPLAY tt-dados-pesqti.vlconfoz WITH FRAME f_soma.
               
                   DISPLAY tt-dados-pesqti.nmempres
                           tel_dscodbar
                           tt-dados-pesqti.nrautdoc
                           tt-dados-pesqti.nrdocmto
                           tt-dados-pesqti.nrdconta
                           tel_insitfat
                           tt-dados-pesqti.dscptdoc
                           WITH FRAME f_detalhes_faturas.
               END.
           ELSE
               DO:
                   tt-dados-pesqti.dspactaa:VISIBLE 
                                   IN FRAME f_detalhes_faturas = TRUE.  

                   IF tt-dados-pesqti.vlconfoz:VISIBLE = TRUE THEN
                       DISPLAY tt-dados-pesqti.vlconfoz WITH FRAME f_soma.

                   DISPLAY tt-dados-pesqti.dspactaa
                           tt-dados-pesqti.nmempres
                           tel_dscodbar
                           tt-dados-pesqti.nrautdoc
                           tt-dados-pesqti.nrdocmto
                           tt-dados-pesqti.nrdconta
                           tel_insitfat
                           tt-dados-pesqti.dscptdoc
                           WITH FRAME f_detalhes_faturas.
               END.
       END.
END.

/*

ON RETURN OF tel_dscodbar IN FRAME f_detalhes_faturas
   DO:
      ASSIGN tel_dscodbar.

      IF LENGTH(tel_dscodbar) < 44 THEN
         DO:
            MESSAGE "Codigo de barras invalido.".
            RETURN NO-APPLY.
         END.

   END. */

ON RETURN OF b_pesqti IN FRAME f_pesqti
   DO:
      IF glb_cddopcao = "A"                     AND 
         TEMP-TABLE tt-dados-pesqti:HAS-RECORDS THEN
         DO:
            ASSIGN tel_insitfat = IF tt-dados-pesqti.insitfat = 1 THEN
                                     "NAO"
                                  ELSE 
                                     "SIM"
                   tel_dscodbar = tt-dados-pesqti.dscodbar.
           
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
            
               UPDATE tel_dscodbar 
                      tel_insitfat 
                      WITH FRAME f_detalhes_faturas.

               LEAVE.
           
            END.
           
            IF KEYFUNCTION(LASTKEY) = "END-ERROR" THEN
               DO:
                  ASSIGN tel_insitfat = IF tt-dados-pesqti.insitfat = 1 THEN
                                           "NAO"
                                        ELSE 
                                           "SIM"
                         tel_dscodbar = tt-dados-pesqti.dscodbar.

                  DISP tel_dscodbar 
                       tel_insitfat 
                       WITH FRAME f_detalhes_faturas.

                  RETURN NO-APPLY.

               END.
            ELSE 
               DO:
                  ASSIGN aux_confirma = "N".
                  
                  RUN fontes/confirma.p (INPUT  "",
                                         OUTPUT aux_confirma).
                      
                  IF aux_confirma = "S" THEN 
                     DO:
                        IF NOT VALID-HANDLE(h-b1wgen0101) THEN
                           RUN sistema/generico/procedures/b1wgen0101.p
                                          PERSISTENT SET h-b1wgen0101.
                        
                        RUN grava-dados-fatura 
                              IN h-b1wgen0101 (INPUT glb_cdcooper,
                                               INPUT glb_dtmvtolt,
                                               INPUT glb_cdagenci,
                                               INPUT 0,
                                               INPUT glb_cdoperad,
                                               INPUT tt-dados-pesqti.cdagenci,
                                               INPUT tel_dtdpagto,
                                               INPUT tt-dados-pesqti.nrdocmto,
                                               INPUT tt-dados-pesqti.nrdolote,
                                               INPUT tt-dados-pesqti.cdbandst, 
                                               INPUT tel_dscodbar,
                                               INPUT IF tel_insitfat = "SIM" THEN 2
                                                     ELSE 1,
                                               OUTPUT TABLE tt-erro).

                        IF VALID-HANDLE(h-b1wgen0101) THEN
                           DELETE PROCEDURE h-b1wgen0101.
                  
                        IF RETURN-VALUE <> "OK"   THEN
                           DO:
                              FIND FIRST tt-erro NO-LOCK NO-ERROR.
                          
                              IF AVAIL tt-erro   THEN
                                 MESSAGE tt-erro.dscritic.
                              ELSE
                                 MESSAGE "Erro na gravacao das alteracoes.".
                  
                              ASSIGN tel_insitfat = IF tt-dados-pesqti.insitfat = 1 THEN
                                                       "NAO"
                                                    ELSE 
                                                       "SIM"
                                     tel_dscodbar = tt-dados-pesqti.dscodbar.
                              
                              DISP tel_dscodbar 
                                   tel_insitfat 
                                   WITH FRAME f_detalhes_faturas.

                              PAUSE 3 NO-MESSAGE.

                              RETURN NO-APPLY.
                              
                           END.
                  
                        APPLY "GO".
                        
                     END.
                  ELSE
                     DO:
                        ASSIGN tel_insitfat = IF tt-dados-pesqti.insitfat = 1 THEN
                                                 "NAO"
                                              ELSE 
                                                 "SIM"
                               tel_dscodbar = tt-dados-pesqti.dscodbar.
                        
                        DISP tel_dscodbar 
                             tel_insitfat 
                             WITH FRAME f_detalhes_faturas.

                     END.

               END.
           
            RETURN NO-APPLY.
          
         END.
      ELSE
         IF glb_cddopcao = "C" AND
            tel_tpdpagto = "F" AND
            tel_flgcnvsi       THEN
            DO:    
               IF LENGTH(tt-dados-pesqti.dscodbar) = 0 THEN
                  DO:
                     HIDE MESSAGE NO-PAUSE.

                     HIDE FRAME f_pesqti.

                     DO WHILE TRUE ON END-KEY UNDO, LEAVE:

                        DISPLAY tt-dados-pesqti.dtapurac
                                tt-dados-pesqti.nrcpfcgc
                                tt-dados-pesqti.cdtribut
                                tt-dados-pesqti.nrrefere
                                tt-dados-pesqti.dtlimite
                                tt-dados-pesqti.vllanmto
                                tt-dados-pesqti.vlrmulta
                                tt-dados-pesqti.vlrjuros
                                tt-dados-pesqti.vlrtotal
                                tt-dados-pesqti.vlrecbru 
                                tt-dados-pesqti.vlpercen 
                                WITH FRAME f_detalhes_darf_41.

                        PAUSE MESSAGE "Pressione F4 ou END para sair.".

                     END.

                     VIEW FRAME f_pesqti.

                     IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                        DO:
                           HIDE FRAME f_detalhes_darf_41 NO-PAUSE.
                           APPLY "NEXT".
                        END.

                  END.
                
            END.

   END.

tt-dados-pesqti.vlconfoz:VISIBLE IN FRAME f_soma = FALSE.
tel_flgcnvsi:VISIBLE IN FRAME f_tipo_pagto = FALSE.

ASSIGN glb_cddopcao = "C"
       glb_cdcritic = 0
       tel_tpdpagto = "T"
       tel_dtdpagto = glb_dtmvtolt
       tel_cdagenci = 0
       tel_vldpagto = 0.

VIEW FRAME f_moldura. 
PAUSE(0).

DO WHILE TRUE:

   RUN fontes/inicia.p.
  
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      HIDE FRAME f_tipo_pagto NO-PAUSE.
  
      IF glb_cdcritic > 0   THEN
         DO:
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
         END.

      HIDE FRAME f_refere NO-PAUSE.
      UPDATE glb_cddopcao  WITH FRAME f_opcao.
      LEAVE.
  
   END.  /*  Fim do DO WHILE TRUE  */
  
   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
      DO:
          RUN fontes/novatela.p.
  
          IF CAPS(glb_nmdatela) <> "PESQTI"  THEN
             DO:
                 HIDE FRAME f_refere.
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

   atualiza_tpdpagto:
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      CLEAR FRAME f_refere.
      HIDE FRAME f_refere NO-PAUSE.

      tel_flgcnvsi:VISIBLE IN FRAME f_tipo_pagto = FALSE.

      ASSIGN tel_dtdpagto = glb_dtmvtolt
             tel_cdagenci = 0
             tel_vldpagto = 0
             tel_flgcnvsi = FALSE.

      tel_cdempcon:VISIBLE IN FRAME f_refere = FALSE.
      tel_cdsegmto:VISIBLE IN FRAME f_refere = FALSE.

      tel_cdhistor:VISIBLE IN FRAME f_refere = FALSE.
      tt-dados-pesqti.vlconfoz:VISIBLE IN FRAME f_soma = FALSE.  

      tel_dtdpagto:LABEL =  "Data".      
      b_pesqti:HELP = "Pressione <F4> ou <END> p/finalizar".

      IF glb_cddopcao = "A"   THEN
         DO:
            ASSIGN tel_tpdpagto = "F".
            b_pesqti:HELP = "Use SETAS para selecionar e ENTER para editar".

            DISPLAY tel_tpdpagto WITH FRAME f_tipo_pagto.                
         END.
      ELSE
         UPDATE tel_tpdpagto
                WITH FRAME f_tipo_pagto.

      HIDE FRAME f_refere NO-PAUSE.
      
      ASSIGN tel_vlrtotal = 0
             tel_qtntotal = 0.
             
      IF tel_tpdpagto = "T"   THEN
         DO:
             UPDATE tel_dtdpagto
                    WITH FRAME f_tipo_pagto.

             UPDATE tel_cdagenci
                    tel_vldpagto WITH FRAME f_refere.

             IF NOT VALID-HANDLE(h-b1wgen0101) THEN
                RUN sistema/generico/procedures/b1wgen0101.p 
                               PERSISTENT SET h-b1wgen0101.
         
             MESSAGE "Consultando informacoes.Aguarde...".

             RUN consulta_titulos 
                  IN h-b1wgen0101 (INPUT glb_cdcooper,
                                   INPUT glb_dtmvtolt,
                                   INPUT tel_dtdpagto,
                                   INPUT tel_vldpagto,
                                   INPUT tel_cdagenci,
                                   INPUT FALSE,
                                   INPUT 0,
                                   INPUT 0,
                                   OUTPUT tel_qtntotal,
                                   OUTPUT tel_vlrtotal,
                                   OUTPUT TABLE tt-dados-pesqti).
              
             HIDE MESSAGE NO-PAUSE.
             
             IF VALID-HANDLE(h-b1wgen0101) THEN
                DELETE PROCEDURE h-b1wgen0101.
         
             IF RETURN-VALUE <> "OK"   THEN
                DO: 
                   FIND FIRST tt-erro NO-LOCK NO-ERROR.
               
                   IF AVAIL tt-erro   THEN
                      MESSAGE tt-erro.dscritic.
                   ELSE
                      MESSAGE "Erro na consulta dos titulos.".
               
                   NEXT.

                END.
                      
             FIND FIRST tt-dados-pesqti NO-LOCK NO-ERROR.
         
             IF NOT AVAIL tt-dados-pesqti THEN
                DO:
                    MESSAGE "Nenhum titulo foi encontrado.".
                    PAUSE 3 NO-MESSAGE.
                    NEXT.
                END.
                        
             OPEN QUERY q_pesqti
                  FOR EACH tt-dados-pesqti NO-LOCK.

             ON RETURN OF b_pesqti IN FRAME f_pesqti
                DO:
                    APPLY LASTKEY.
                END.
             
             ENABLE b_pesqti WITH FRAME f_pesqti.

             APPLY "ITERATION-CHANGED" TO b_pesqti.
             PAUSE 0 NO-MESSAGE.
             DISP tel_vlrtotal tel_qtntotal WITH FRAME f_soma.

             WAIT-FOR END-ERROR OF DEFAULT-WINDOW. 

         END.     
      ELSE
      IF tel_tpdpagto = "F" THEN
         DO:
            ASSIGN tel_cdhistor = 0
                   tel_cdempcon = 0
                   tel_cdsegmto = 0
                   tel_qtntotal = 0.

            UPDATE tel_flgcnvsi
                   tel_dtdpagto
                   WITH FRAME f_tipo_pagto.

            tel_dtdpagto:LABEL = "Data".
            tel_cdhistor:VISIBLE IN FRAME f_refere = TRUE.
            tel_flgcnvsi:VISIBLE IN FRAME f_tipo_pagto = TRUE.

            /* Adquire os historicos e convenios disponíveis */
            IF NOT VALID-HANDLE(h-b1wgen0101) THEN
               RUN sistema/generico/procedures/b1wgen0101.p
                             PERSISTENT SET h-b1wgen0101.
       
            RUN lista-historicos IN h-b1wgen0101(INPUT 0,
                                                 INPUT "",
                                                 INPUT 999,
                                                 INPUT 0,
                                                 OUTPUT aux_qtregist,
                                                 OUTPUT TABLE tt-historicos).

            IF tel_flgcnvsi THEN
               DO:
                   tel_cdempcon:VISIBLE IN FRAME f_refere = TRUE.
                   tel_cdsegmto:VISIBLE IN FRAME f_refere = TRUE.
                   tel_cdhistor:VISIBLE IN FRAME f_refere = FALSE.

                   RUN lista-empresas-conv 
                       IN h-b1wgen0101 (INPUT glb_cdcooper,
                                        INPUT 0,
                                        INPUT 0,
                                        INPUT "",
                                        INPUT 999,
                                        INPUT 0,
                                        OUTPUT aux_qtregist,
                                        OUTPUT TABLE tt-empr-conve).

               END.

            IF VALID-HANDLE(h-b1wgen0101) THEN
               DELETE PROCEDURE h-b1wgen0101.

            UPDATE tel_cdagenci WITH FRAME f_refere.

            IF NOT tel_flgcnvsi THEN
               hist:
               DO WHILE TRUE:
               
                  IF KEYFUNCTION(LASTKEY) = "END-ERROR" AND
                     FRAME-FIELD = "b_historicos"       THEN
                     NEXT-PROMPT tel_cdhistor WITH FRAME f_refere.
                  
                  UPDATE tel_cdhistor
                         VALIDATE (CAN-FIND (tt-historicos WHERE tt-historicos.cdhiscxa = tel_cdhistor NO-LOCK) OR
                                   tel_cdhistor = 0, "093 - Historico errado.")
                         WITH FRAME f_refere
                     EDITING:    
               
                        HIDE FRAME f_historicos NO-PAUSE.
                                                             
                        READKEY.
                     
                        IF LASTKEY =  KEYCODE("F7") AND     
                           FRAME-FIELD = "tel_cdhistor" THEN    
                           DO:                            
                               OPEN QUERY q_historicos 
                                    FOR EACH tt-historicos NO-LOCK.
                     
                               ON RETURN OF b_historicos
                                  DO:                     
                                     IF TEMP-TABLE tt-historicos:HAS-RECORDS THEN
                                        DO:
                                           ASSIGN  tel_cdhistor = tt-historicos.cdhiscxa.
                                           DISPLAY tel_cdhistor WITH FRAME f_refere.
                                        END.
                                       
                                     APPLY "GO". 
                                  END.
                     
                               DO WHILE TRUE ON ENDKEY UNDO, NEXT hist:
                     
                                  UPDATE b_historicos WITH FRAME f_historicos.
                                  HIDE FRAME f_historicos NO-PAUSE.
                                  LEAVE.
                             
                               END.

                           END.
                     
                        ON RETURN OF tt-historicos.cdhiscxa 
                           DO:
                              FIND tt-historicos WHERE tt-historicos.cdhiscxa = INTEGER(FRAME-VALUE)
                                                       NO-LOCK NO-ERROR NO-WAIT.
                     
                              IF AVAIL tt-historicos THEN
                                 DO:
                                     ASSIGN  tel_cdhistor = tt-historicos.cdhiscxa.
                                     DISPLAY tel_cdhistor WITH FRAME f_refere.
                                 END. 

                           END.
               
                        APPLY LASTKEY.
                         
                     END.  /*  Fim do EDITING  */

                  LEAVE.

               END.
            ELSE
               cdempres:
               DO WHILE TRUE:
                  /* Pede campos de Cd. Empresa e Cd. Segmto */
                  UPDATE tel_cdempcon
                         VALIDATE (CAN-FIND (FIRST tt-empr-conve WHERE tt-empr-conve.cdempcon = INPUT tel_cdempcon NO-LOCK) OR
                                   INPUT tel_cdempcon = 0, "Cod. da Empresa incorreta.")
                         tel_cdsegmto
                         VALIDATE (CAN-FIND (FIRST tt-empr-conve NO-LOCK WHERE tt-empr-conve.cdsegmto = INPUT tel_cdsegmto     AND
                                                                               IF (INPUT tel_cdempcon > 0) THEN
                                                                                  tt-empr-conve.cdempcon = INPUT tel_cdempcon
                                                                               ELSE TRUE ) OR
                                   CAN-FIND (FIRST tt-empr-conve NO-LOCK WHERE tt-empr-conve.cdempcon = INPUT tel_cdempcon     AND
                                                                               IF (INPUT tel_cdsegmto > 0) THEN
                                                                                  tt-empr-conve.cdsegmto = INPUT tel_cdsegmto
                                                                               ELSE TRUE ) OR
                                   INPUT tel_cdsegmto = 0,
                                           "Cod. do Segmento incorreto.") WITH FRAME f_refere
                  EDITING:
                
                     READKEY.

                     IF LASTKEY =  KEYCODE("F7")     AND     
                        FRAME-FIELD = "tel_cdempcon" THEN
                        DO:
                           OPEN QUERY bconvenios-q FOR EACH tt-empr-conve 
                                                            NO-LOCK.                     

                           DO WHILE TRUE ON ENDKEY UNDO, NEXT cdempres:
               
                              ENABLE bconvenios-b WITH FRAME f_emp_convenioc.
                              WAIT-FOR RETURN OF bconvenios-b.
                              LEAVE.
               
                           END.
                
                           DISABLE bconvenios-b WITH FRAME f_emp_convenioc.
                          
                           ASSIGN tel_cdempcon = tt-empr-conve.cdempcon
                                  tel_cdsegmto = tt-empr-conve.cdsegmto.
                          
                           DISPLAY tel_cdempcon
                                   tel_cdsegmto WITH FRAME f_refere.
                            
                           CLOSE QUERY bconvenios-q.
                           HIDE FRAME f_emp_convenioc. 

                        END.
                         
                     APPLY LASTKEY.
                      
                  END.  /*  Fim do EDITING  */

                  LEAVE.

               END.

            UPDATE tel_vldpagto WITH FRAME f_refere.

            consulta_faturas:
            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

               IF tel_cdhistor = 963 /* FOZ */ THEN
                  tt-dados-pesqti.vlconfoz:VISIBLE IN FRAME f_soma = TRUE.
               
               IF NOT VALID-HANDLE(h-b1wgen0101)  THEN
                  RUN sistema/generico/procedures/b1wgen0101.p
                                PERSISTENT SET h-b1wgen0101.

               MESSAGE "Consultando informacoes. Aguarde...".

               RUN consulta_faturas 
                     IN h-b1wgen0101 (INPUT glb_cdcooper,
                                      INPUT glb_dtmvtolt,
                                      INPUT 0,
                                      INPUT tel_dtdpagto,
                                      INPUT tel_vldpagto,
                                      INPUT tel_cdagenci,
                                      INPUT tel_cdhistor,
                                      INPUT FALSE,
                                      INPUT 0,
                                      INPUT 0,
                                      INPUT tel_cdempcon,
                                      INPUT tel_cdsegmto,
                                      INPUT tel_flgcnvsi,
                                      OUTPUT tel_qtntotal,
                                      OUTPUT tel_vlrtotal,
                                      OUTPUT TABLE tt-dados-pesqti,
                                      OUTPUT TABLE tt-erro).
               
               HIDE MESSAGE NO-PAUSE.

               IF VALID-HANDLE(h-b1wgen0101) THEN
                  DELETE PROCEDURE h-b1wgen0101.
               
               IF RETURN-VALUE <> "OK"   THEN
                  DO:
                      FIND FIRST tt-erro NO-LOCK NO-ERROR.
                  
                      IF  AVAIL tt-erro   THEN
                          MESSAGE tt-erro.dscritic.
                      ELSE
                          MESSAGE "Erro na consulta das faturas.".

                      NEXT atualiza_tpdpagto.
                  END.
               
               FIND FIRST tt-dados-pesqti NO-LOCK NO-ERROR.
               
               IF NOT AVAIL tt-dados-pesqti THEN
                  DO:
                      MESSAGE "Nenhuma fatura foi encontrada.".
                  END.

               IF NOT TEMP-TABLE tt-dados-pesqti:HAS-RECORDS THEN
                  NEXT atualiza_tpdpagto.

               DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
          
                  OPEN QUERY q_pesqti FOR EACH tt-dados-pesqti 
                                      NO-LOCK BY tt-dados-pesqti.vldpagto.                            
                  APPLY "ITERATION-CHANGED" TO b_pesqti.
                  PAUSE 0 NO-MESSAGE.
                  DISP tel_vlrtotal tel_qtntotal WITH FRAME f_soma.
                  
                  UPDATE b_pesqti 
                         WITH FRAME f_pesqti.
                      
                  LEAVE. 
               
               END.

               IF KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN 
                  IF tt-dados-pesqti.vlrmulta:VISIBLE IN FRAME f_detalhes_darf_41 = TRUE THEN
                     HIDE FRAME f_detalhes_darf_41.
                  ELSE
                     LEAVE consulta_faturas.

            END.
         END.  
      
      HIDE FRAME f_pesqti.
      HIDE FRAME f_detalhes_titulos.
      HIDE FRAME f_detalhes_faturas.
      HIDE FRAME f_detalhes_darf_41.
      HIDE FRAME f_soma.       
      
      HIDE MESSAGE NO-PAUSE.
 
   END. /*  Fim do DO WHILE TRUE  */

END.  /*  Fim do DO WHILE TRUE  */

/*............................................................................*/
