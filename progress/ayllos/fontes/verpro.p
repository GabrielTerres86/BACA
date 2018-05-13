/* ............................................................................

   Programa: Fontes/verpro.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme       
   Data    : Novembro/2007                       Ultima alteracao: 09/04/2015
     
   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Mostrar tela para visualizacao de protocolos gerados.
   
   Atualizacoes: 08/04/2008 - Incluido codigo de barras e linha digitada no
                              browser e no detalhe dos protocolos que sejam
                              pagamentos (Elton). 
                              
                 30/04/2008 - Adequacao da TEMP-TABLE tt-cratpro em relacao a BO
                              que lista os protocolos (Evandro).

                 01/08/2008 - Incluir campo nrseqaut na TEMP-TABLE tt-cratpro 
                              (David).
                              
                 27/08/2009 - Alteracoes do Projeto de Transferencia para
                              Credito de Salario (David).
                              
                 18/05/2010 - Incluido o tipo 5-Dep.TAA (Evandro)
                 
                 09/06/2010 - Incluido opcao de impressao (Gati - Daniel).
                 
                 12/07/2010 - Enquadramento de frames (Gati - Daniel).
                 
                 05/08/2011 - Ler o protocolo e apresentar em tela (Gabriel).
                 
                 22/09/2011 - Incluir tratamento cdtippro = 7 (Gabriel).
                              
                 06/10/2011 - Adicionado campos de Preposto e Operador em
                              protocolos 1,2 e 4, alterado modo de passagem 
                              dos parametros (Jorge).
               
               27/10/2011 - Adaptado para uso de BO (Rogerius Militao - DB1).
               
               01/05/2012 - Ajuste Projeto TED Internet (David).
               
               28/02/2013 - Incluso paginacao tela web (Daniel).
               
               02/05/2013 - Transferencia Intercooperativa (Gabriel).
               
               11/07/2013 - Alteração ordem dos campos de Cooperativa e 
                            Conta Destino (Lucas).
                            
               25/04/2014 - Ajustes referente ao projeto de captacao
                            (Adriano). 
               
               03/06/2014 - Concatena o numero do servidor no endereco do
                            terminal (Tiago-RKAM).            
                                                    
               02/10/2014 - Ajustes referente a inclusao do protocolo do 
                            tipo 12 - Resgate de aplicacoes
                            (Adriano).
                            
               02/10/2014 - #123392 Mostrar protocolo de rdcpre sem a
                            "taxa minima" (Carlos)
                             
               04/11/2014 - Ajustar os campos do protocolo de Aplicacao Pos e Pre
                            (Douglas - Chamado 123392)
                            
               09/04/2015 - Incluido nome do produto junto com o nr da aplicacao 
                            quando for novos produtos de captacao. (Reinert)
                            
               22/04/2015 - Inclusão do campo ISPB SD271603 FDR041 (Vanessa)
               
               16/09/2015 - Ajustes para carregamento do tipo de protocolo 13(GPS) 
                            Projeto GPS (Carlos Rafael Tanholi)
............................................................................ */
                    
{ includes/var_online.i }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/b1wgen0122tt.i }

DEF VAR h-b1wgen0122 AS HANDLE                                         NO-UNDO.

DEF VAR tel_nrdconta AS INTE FORMAT "zzzz,zzz,9"                       NO-UNDO.
DEF VAR tel_nmprimtl AS CHAR FORMAT "x(40)"                            NO-UNDO.
DEF VAR tel_dataini  AS DATE FORMAT "99/99/9999"                       NO-UNDO.
DEF VAR tel_datafin  AS DATE FORMAT "99/99/9999"                       NO-UNDO.
DEF VAR tel_cdtippro AS INTE FORMAT "99"                               NO-UNDO.
DEF VAR tel_dstippro AS CHAR FORMAT "x(15)"                            NO-UNDO.

DEF VAR aux_cddopcao AS CHAR                                           NO-UNDO.
DEF VAR aux_nrdconta AS INTE                                           NO-UNDO.                                                                       

DEF VAR aux_label    AS CHAR                                           NO-UNDO.
DEF VAR aux_label2   AS CHAR                                           NO-UNDO.
DEF VAR aux_valor    AS CHAR                                           NO-UNDO.
DEF VAR aux_auxiliar AS CHAR FORMAT "x(45)"                            NO-UNDO.
DEF VAR aux_dstippro AS CHAR                                           NO-UNDO.

DEF VAR tel_cdbarras AS CHAR FORMAT "x(65)"                            NO-UNDO.
DEF VAR tel_lndigita AS CHAR FORMAT "x(73)"                            NO-UNDO.
DEF VAR tel_terminal AS CHAR FORMAT "x(60)"                            NO-UNDO.
DEF VAR aux_confirma AS CHAR FORMAT "!(1)" INITIAL "N"                 NO-UNDO.

/* Variaveis Impressao */    
DEF VAR tel_dsimprim AS CHAR FORMAT "x(8)" INIT "Imprimir"             NO-UNDO.
DEF VAR tel_dscancel AS CHAR FORMAT "x(8)" INIT "Cancelar"             NO-UNDO.
DEF VAR aux_contador AS INTE                                           NO-UNDO.
DEF VAR aux_prepost AS CHAR FORMAT "x(60)"                             NO-UNDO.

DEF VAR aux_auxiliar2 AS CHAR                                          NO-UNDO.
DEF VAR aux_auxiliar3 AS CHAR FORMAT "x(30)"                           NO-UNDO.
DEF VAR aux_auxiliar4 AS CHAR                                          NO-UNDO.
                                                        
DEF VAR aux_dscabeca AS CHAR EXTENT 2                                  NO-UNDO.
DEF VAR aux_dsddados AS CHAR EXTENT 16                                 NO-UNDO.

DEF VAR aux_qtregist AS INTE                                           NO-UNDO. 
DEF VAR aux_dsispbif AS CHAR                                           NO-UNDO.
FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_nrdconta AT  2 LABEL "Conta/DV" AUTO-RETURN
                        HELP "Informe o numero da conta do cooperado."
     tel_nmprimtl AT 25 LABEL "Titular" FORMAT "x(40)"
     SKIP
     tel_dataini  AT 2  LABEL "Data inicial"
                  HELP "Informe a data inicial"
     tel_datafin  AT 27 LABEL "Data final"
                  HELP "Informe a data final"

     tel_cdtippro AT 52 LABEL "Tipo" AUTO-RETURN
                        HELP "Informe o tipo do protocolo ou F7 p/ listar."
     "-"
     tel_dstippro AT 62 NO-LABEL
     WITH ROW 6 COLUMN 2 OVERLAY NO-BOX SIDE-LABELS FRAME f_param_pro.

FORM aux_dsddados[1]   AT 1                                      SKIP
     aux_dsddados[2]   AT 1                                      SKIP
     aux_dsddados[3]   AT 1                                      SKIP
     aux_dsddados[4]   AT 1                                      SKIP
     aux_dsddados[5]   AT 1                                      SKIP
     aux_dsddados[6]   AT 1                                      SKIP
     aux_dsddados[7]   AT 1                                      SKIP
     aux_dsddados[8]   AT 1                                      SKIP
     aux_dsddados[9]   AT 1                                      SKIP
     aux_dsddados[10]  AT 1                                      SKIP
     aux_dsddados[11]  AT 1                                      SKIP
     aux_dsddados[12]  AT 1                                      SKIP
     aux_dsddados[13]  AT 1                                      SKIP
     aux_dsddados[14]  AT 1                                      SKIP
     WITH ROW 05 COLUMN 2 OVERLAY WIDTH 78 NO-LABELS 
     TITLE " Detalhes do Protocolo " FRAME f_cratproi.

/* Form para rdcpre */
FORM aux_dsddados[1]   AT 1                                      SKIP
     aux_dsddados[2]   AT 1                                      SKIP
     aux_dsddados[3]   AT 1                                      SKIP
     aux_dsddados[4]   AT 1                                      SKIP
     aux_dsddados[5]   AT 1                                      SKIP
     aux_dsddados[6]   AT 1                                      SKIP
     aux_dsddados[7]   AT 1                                      SKIP
     aux_dsddados[8]   AT 1                                      SKIP
     aux_dsddados[9]   AT 1                                      SKIP
     aux_dsddados[10]  AT 1                                      SKIP
     aux_dsddados[11]  AT 1                                      SKIP
     aux_dsddados[12]  AT 1                                      SKIP
     aux_dsddados[13]  AT 1                                      SKIP
     WITH ROW 06 COLUMN 2 OVERLAY WIDTH 78 NO-LABELS 
     TITLE " Detalhes do Protocolo " FRAME f_cratproi_rdcpre.

/* protocolo GPS */
FORM " "                                                         SKIP
     aux_prepost       AT 1                                      SKIP
     " "                                                         SKIP
     aux_dsddados[1]   AT 1                                      SKIP
     aux_dsddados[2]   AT 1                                      SKIP
     aux_dsddados[3]   AT 1                                      SKIP
     aux_dsddados[4]   AT 1                                      SKIP
     aux_dsddados[5]   AT 1                                      SKIP
     aux_dsddados[6]   AT 1                                      SKIP
     aux_dsddados[7]   AT 1                                      SKIP
     aux_dsddados[8]   AT 1                                      SKIP
     aux_dsddados[9]   AT 1                                      SKIP
     aux_dsddados[10]  AT 1                                      SKIP
     aux_dsddados[11]  AT 1                                      SKIP
     aux_dsddados[12]  AT 1                                      SKIP
     aux_dsddados[13]  AT 1                                      SKIP
     aux_dsddados[14]  AT 1                                      SKIP
     aux_dsddados[15]  AT 1                                      SKIP
     aux_dsddados[16]  AT 1                                      
     WITH ROW 05 COLUMN 2 OVERLAY WIDTH 100 NO-LABELS 
     TITLE "Detalhes do Protocolo GPS" FRAME f_cratproi_gps.

DEF  QUERY  q_lista  FOR tt-tipo.
DEF  BROWSE b_lista  QUERY q_lista
     DISPLAY tt-tipo.cdtippro  FORMAT "99" NO-LABEL 
             tt-tipo.dstippro  FORMAT "x(15)" NO-LABEL
             WITH 8 DOWN WIDTH 21 NO-LABELS OVERLAY.
               
FORM b_lista  HELP "Use ENTER para selecionar ou F4 para sair"
     WITH NO-BOX ROW 8 COLUMN 59 OVERLAY FRAME f_lista.               

DEF QUERY q_cratpro FOR tt-cratpro. 
 
DEF BROWSE b_cratpro QUERY q_cratpro 
    DISP tt-cratpro.dttransa    COLUMN-LABEL "Transacao"    FORMAT "99/99/9999"
         STRING(tt-cratpro.hrautent,"HH:MM:SS")
                                COLUMN-LABEL "Hora"         FORMAT "x(08)"
         tt-cratpro.vldocmto    COLUMN-LABEL "Valor"        FORMAT "zzz,zz9.99"
         tt-cratpro.dsprotoc    COLUMN-LABEL "Protocolo"    FORMAT "x(67)"
         tt-cratpro.dsinform[1] COLUMN-LABEL "Tipo"         FORMAT "x(20)"
         WITH 6 DOWN WIDTH 78 TITLE " Protocolos " SCROLLBAR-VERTICAL.

DEF FRAME f_cratpro
          b_cratpro  
    HELP "Pressione <ENTER> p/ detalhes ou <SETAS> p/ outras informacoes "
    WITH NO-BOX CENTERED OVERLAY ROW 8.

DEF FRAME f_linhas
          tel_cdbarras       SKIP
          tel_lndigita AT  2 SKIP
          tel_terminal AT 14
          WITH ROW 18 COL 3 OVERLAY NO-LABEL NO-BOX.

ON RETURN OF b_lista
    DO:
        ASSIGN tel_cdtippro = tt-tipo.cdtippro
               tel_dstippro = tt-tipo.dstippro.

        DISPLAY tel_cdtippro
                tel_dstippro
                WITH FRAME f_param_pro.
        
        APPLY "GO".
    END.

    
ON VALUE-CHANGED, ENTRY OF b_cratpro IN FRAME f_cratpro 
    DO:  
        ASSIGN tel_cdbarras = tt-cratpro.cdbarras
               tel_lndigita = tt-cratpro.lndigita
               tel_terminal = tt-cratpro.terminax. 
        
        DISPLAY tel_cdbarras 
                tel_lndigita  
                tel_terminal
                WITH FRAME f_linhas.
    END.

ON ENTER OF b_cratpro IN FRAME f_cratpro
   DO:                       
      IF NOT AVAILABLE tt-cratpro   THEN
         RETURN NO-APPLY.

      DISABLE b_cratpro WITH FRAME f_cratpro.
      HIDE FRAME f_cratpro.
      HIDE FRAME f_linhas.

      ASSIGN aux_label = TRIM(ENTRY(2,tt-cratpro.dsinform[2],"#"))
             aux_auxiliar = ""
             aux_dsddados = "".

      IF tt-cratpro.cdtippro = 3 THEN
         DO:
            IF tt-cratpro.flgpagto   THEN
               ASSIGN aux_auxiliar = STRING(tt-cratpro.nrdocmto) + 
                           "              Tipo: Debito em folha".
            ELSE
               ASSIGN aux_auxiliar = STRING(tt-cratpro.nrdocmto) + 
                                    "              Tipo: Debito em conta".
         END.
      ELSE
        IF tt-cratpro.cdtippro <> 9  THEN
           ASSIGN aux_auxiliar = TRIM(ENTRY(2,aux_label,":")).

      ASSIGN aux_valor = TRIM(STRING(tt-cratpro.vldocmto,"zzz,zz9.99")).
      
      IF tt-cratpro.cdtippro = 1 OR tt-cratpro.cdtippro = 4 THEN
         ASSIGN aux_auxiliar2 = string(tt-cratpro.nrdocmto)
                aux_auxiliar3 = string(tt-cratpro.nrseqaut).
      
      IF tt-cratpro.cdtippro = 2 OR tt-cratpro.cdtippro = 6 THEN
         ASSIGN aux_auxiliar2 = string(tt-cratpro.nrdocmto)
                aux_auxiliar3 = tt-cratpro.dscedent
                aux_auxiliar4 = string(tt-cratpro.nrseqaut).

      IF tt-cratpro.cdtippro = 3 OR tt-cratpro.cdtippro = 5 THEN
         DO:
            ASSIGN aux_auxiliar2 = ""
                   aux_auxiliar3 = "".

            IF tt-cratpro.cdtippro = 5  THEN
               ASSIGN tel_cdbarras = "       " +
                                     ENTRY(1,tt-cratpro.dsinform[3],"#").
         END.

      IF  tt-cratpro.cdtippro = 9 THEN DO:

            ASSIGN aux_dsddados = ""
                   aux_contador = 0
                   aux_dsispbif = "".

            IF TRIM(tt-cratpro.nmprepos) <> "" THEN
               ASSIGN aux_dsddados[1] = 
                      "           Preposto: " + tt-cratpro.nmprepos
                      aux_contador = 1.

            IF TRIM(tt-cratpro.nmoperad) <> "" THEN
               ASSIGN aux_dsddados[1 + aux_contador] =
                      "           Operador: " + tt-cratpro.nmoperad
                      aux_contador = aux_contador + 1.
          
            IF NUM-ENTRIES(tt-cratpro.dsinform[2],"#") = 5 THEN
            DO: 
                 ASSIGN aux_dsispbif = STRING(int(TRIM(ENTRY(5,tt-cratpro.dsinform[2],"#"))),"99999999").
                 IF trim(substring(tt-cratpro.dsdbanco,1,r-index(tt-cratpro.dsdbanco,"-") - 1)) <> '001' AND aux_dsispbif = '00000000' THEN
                    aux_dsispbif = "".
                 ELSE
                    aux_dsispbif = aux_dsispbif.
            END.
            ELSE
            DO: /*Tratamento de comprovantes antigos para o Banco do Brasil*/
                 IF trim(substring(tt-cratpro.dsdbanco,1,r-index(tt-cratpro.dsdbanco,"-") - 1)) = '001' AND aux_dsispbif = '' THEN
                    aux_dsispbif = "00000000".
            END.
             
            
            ASSIGN aux_dsddados[1 + aux_contador] = 
                               "   Banco Favorecido: " + tt-cratpro.dsdbanco
                   aux_contador = aux_contador + 1
                   aux_dsddados[1 + aux_contador] = 
                               "    ISPB Favorecido: " + STRING(aux_dsispbif,"99999999")
                                                       
                   aux_contador = aux_contador + 1
                   aux_dsddados[1 + aux_contador] = 
                               " Agencia Favorecido: " + tt-cratpro.dsageban
                   aux_contador = aux_contador + 1
                   aux_dsddados[1 + aux_contador] = 
                               "   Conta Favorecido: " + tt-cratpro.nrctafav
                   aux_contador = aux_contador + 1
                   aux_dsddados[1 + aux_contador] = 
                               "    Nome Favorecido: " + tt-cratpro.nmfavore
                   aux_contador = aux_contador + 1.

            IF LENGTH(tt-cratpro.nrcpffav) = 18  THEN
               ASSIGN aux_dsddados[1 + aux_contador] = 
                      "    CNPJ Favorecido: " + tt-cratpro.nrcpffav
                      aux_contador = aux_contador + 1.
            ELSE
               ASSIGN aux_dsddados[1 + aux_contador] = 
                      "     CPF Favorecido: " + tt-cratpro.nrcpffav
                      aux_contador = aux_contador + 1.

            ASSIGN aux_dsddados[1 + aux_contador] = 
                               "         Finalidade: " + tt-cratpro.dsfinali
                   aux_contador = aux_contador + 1.

            IF tt-cratpro.dstransf <> ""  THEN
               ASSIGN aux_dsddados[1 + aux_contador] = 
                              "  Cod.Identificador: " + tt-cratpro.dstransf
                      aux_contador = aux_contador + 1.

            ASSIGN aux_dsddados[1 + aux_contador] = 
                               "Data/Hora Transacao: " +
                               STRING(tt-cratpro.dttransa,"99/99/9999") +
                               " - " + 
                               STRING(tt-cratpro.hrautent,"HH:MM:SS")
                   aux_contador = aux_contador + 1
                   aux_dsddados[1 + aux_contador] =
                               "              Valor: " + STRING(aux_valor)
                   aux_contador = aux_contador + 1
                   aux_dsddados[1 + aux_contador] = 
                               "          Protocolo: " +
                               STRING(tt-cratpro.dsprotoc)
                   aux_contador = aux_contador + 1
                   aux_dsddados[1 + aux_contador] = 
                                           "      Nr. Documento: " + 
                               STRING(tt-cratpro.nrdocmto)
                   aux_contador = aux_contador + 1
                               aux_dsddados[1 + aux_contador] =
                                                "  Seq. Autenticacao: " + 
                               STRING(tt-cratpro.nrseqaut)
                   aux_contador = aux_contador + 1.
               

            DISP aux_dsddados FORMAT "x(86)" WITH FRAME f_cratproi.

            RUN fontes/confirma.p(INPUT "Imprimir o Protocolo ? (S)im/(N)ao:",
                                  OUTPUT aux_confirma).

            HIDE MESSAGE NO-PAUSE.
    
            IF aux_confirma = "S" THEN 
               RUN Gera_Impressao.
            
            WAIT "END-ERROR" OF DEFAULT-WINDOW.
            
            HIDE FRAME f_cratproi.
            HIDE MESSAGE NO-PAUSE.
            
            ENABLE b_cratpro WITH FRAME f_cratpro.

      END.
      ELSE
      IF tt-cratpro.cdtippro = 1 OR 
         tt-cratpro.cdtippro = 2 OR
         tt-cratpro.cdtippro = 4 OR 
         tt-cratpro.cdtippro = 6 THEN
         DO:
            IF tt-cratpro.cdtippro = 1 OR 
               tt-cratpro.cdtippro = 4 THEN 
               DO:
                  ASSIGN aux_dsddados = ""
                         aux_contador = 0.

                  IF TRIM(tt-cratpro.nmprepos) <> "" THEN
                     ASSIGN aux_dsddados[1] = 
                            "           Preposto: " + tt-cratpro.nmprepos
                            aux_contador = 1.

                  IF TRIM(tt-cratpro.nmoperad) <> "" THEN
                     ASSIGN aux_dsddados[1 + aux_contador] =
                            "           Operador: " + tt-cratpro.nmoperad
                            aux_contador = aux_contador + 1.

                  IF tt-cratpro.dsageban <> "" THEN
                     ASSIGN aux_dsddados[1 + aux_contador] = 
                            "Cooperativa Destino: " + tt-cratpro.dsageban
                            aux_contador = aux_contador + 1.

                  ASSIGN aux_dsddados[1 + aux_contador] = 
                         "   Conta/dv Destino: " + STRING(aux_auxiliar)
                         aux_contador = aux_contador + 1. 

                  ASSIGN aux_dsddados[1 + aux_contador] = 
                         "     Data Transacao: " +
                          STRING(tt-cratpro.dttransa,"99/99/9999")
                         aux_dsddados[2 + aux_contador] = 
                         "               Hora: " +
                         STRING(tt-cratpro.hrautent,"HH:MM:SS")
                         aux_dsddados[3 + aux_contador] = 
                         "  Dt. Transferencia: " +
                         STRING(tt-cratpro.dtmvtolt,"99/99/9999")
                         aux_dsddados[4 + aux_contador] =
                         "              Valor: " + STRING(aux_valor)
                         aux_dsddados[5 + aux_contador] = 
                         "          Protocolo: " +
                         STRING(tt-cratpro.dsprotoc).

                  IF TRIM(tel_cdbarras) <> "" THEN
                     ASSIGN aux_dsddados[6 + aux_contador] =
                                               "   " + tel_cdbarras 
                            aux_contador = aux_contador + 1.
                  
                  IF TRIM(tel_lndigita) <> "" THEN
                     ASSIGN aux_dsddados[6 + aux_contador] = 
                                            "    " + tel_lndigita 
                            aux_contador = aux_contador + 1.
                  
                  ASSIGN aux_dsddados[6 + aux_contador] = 
                                     "      Nr. Documento: " + aux_auxiliar2
                         aux_dsddados[7 + aux_contador] =
                                     "  Seq. Autenticacao: " + aux_auxiliar3.

                  DISP aux_dsddados FORMAT "x(76)" WITH FRAME f_cratproi.

               END.
            ELSE
               DO: 
                  IF TRIM(ENTRY(1,aux_label,":")) = "Banco" THEN
                     DO:
                        ASSIGN aux_dsddados = ""
                               aux_contador = 0.

                        IF TRIM(tt-cratpro.nmprepos) <> "" THEN
                           ASSIGN aux_dsddados[1] = 
                                          "           Preposto: " +
                                          tt-cratpro.nmprepos
                                  aux_contador = 1.

                        IF TRIM(tt-cratpro.nmoperad) <> "" THEN
                           ASSIGN aux_dsddados[1 + aux_contador] =
                                             "           Operador: " + 
                                             tt-cratpro.nmoperad
                                  aux_contador = aux_contador + 1.

                        ASSIGN aux_dsddados[1 + aux_contador] = 
                                 "              Banco: " + aux_auxiliar
                               aux_dsddados[2 + aux_contador] = 
                                "            Cedente: " + aux_auxiliar3
                               aux_dsddados[3 + aux_contador] = 
                       "     Data Transacao: " + STRING(tt-cratpro.dttransa,"99/99/9999")
                              + "      Hora: " + STRING(tt-cratpro.hrautent,"HH:MM:SS") 
                                aux_dsddados[4 + aux_contador] = 
                       "     Data Pagamento: " + STRING(tt-cratpro.dtmvtolt,"99/99/9999")
                                aux_dsddados[5 + aux_contador] =
                       "              Valor: " + STRING(aux_valor)
                                aux_dsddados[6 + aux_contador] = 
                       "          Protocolo: " + STRING(tt-cratpro.dsprotoc).
                        IF TRIM(tel_cdbarras) <> "" THEN
                           ASSIGN aux_dsddados[7 + aux_contador] =
                                              "   " + tel_cdbarras 
                                  aux_contador = aux_contador + 1.
                        
                        IF TRIM(tel_lndigita) <> "" THEN
                           ASSIGN aux_dsddados[7 + aux_contador] = 
                                              "    " + tel_lndigita 
                                  aux_contador = aux_contador + 1.
                        
                        ASSIGN aux_dsddados[7 + aux_contador] = 
                                      "      Nr. Documento: " + aux_auxiliar2
                               aux_dsddados[8 + aux_contador] =
                                      "  Seq. Autenticacao: " + aux_auxiliar4.
      

                        DISP aux_dsddados FORMAT "x(76)" WITH FRAME f_cratproi.

                     END.
                  ELSE
                     DO:
                        ASSIGN aux_dsddados = ""
                               aux_contador = 0.

                        IF TRIM(tt-cratpro.nmprepos) <> "" THEN
                           ASSIGN aux_dsddados[1] = 
                                        "           Preposto: " + 
                                        tt-cratpro.nmprepos
                                  aux_contador = 1.

                        IF TRIM(tt-cratpro.nmoperad) <> "" THEN
                            ASSIGN aux_dsddados[1 + aux_contador] =
                                          "           Operador: " + 
                                          tt-cratpro.nmoperad
                                   aux_contador = aux_contador + 1.

                        ASSIGN aux_dsddados[1 + aux_contador] = 
                        "           " + TRIM(ENTRY(1,aux_label,":")) + ": " 
                                      + aux_auxiliar
                                 aux_dsddados[2 + aux_contador] = 
                        "     Data Transacao: " + STRING(tt-cratpro.dttransa,"99/99/9999")
                                 aux_dsddados[3 + aux_contador] =
                        "               Hora: " + 
                                       STRING(tt-cratpro.hrautent,"HH:MM:SS")
                                 aux_dsddados[4 + aux_contador] = 
                        "     Data Pagamento: " + STRING(tt-cratpro.dtmvtolt,"99/99/9999")
                                 aux_dsddados[5 + aux_contador] =
                        "              Valor: " + STRING(aux_valor)
                                 aux_dsddados[6 + aux_contador] = 
                        "          Protocolo: " + STRING(tt-cratpro.dsprotoc).
                        IF TRIM(tel_cdbarras) <> "" THEN
                           ASSIGN aux_dsddados[7 + aux_contador] =
                                              "   " + tel_cdbarras 
                                  aux_contador = aux_contador + 1.
                        
                        IF TRIM(tel_lndigita) <> "" THEN
                           ASSIGN aux_dsddados[7 + aux_contador] = 
                                           "    " + tel_lndigita 
                                  aux_contador = aux_contador + 1.
                        
                        ASSIGN aux_dsddados[7 + aux_contador] = 
                                       "      Nr. Documento: " +
                                       aux_auxiliar2
                               aux_dsddados[8 + aux_contador] =
                                       "  Seq. Autenticacao: " + 
                                       aux_auxiliar4.

                        DISP aux_dsddados FORMAT "x(76)" WITH FRAME f_cratproi.

                     END.

               END.
        
            RUN fontes/confirma.p (INPUT "Imprimir o Protocolo ? (S)im/(N)ao:",
                                  OUTPUT aux_confirma).
            
            HIDE MESSAGE NO-PAUSE.
            
            IF aux_confirma = "S" THEN 
               DO:
                  RUN Gera_Impressao.
               END.
            
            WAIT "END-ERROR" OF DEFAULT-WINDOW.
            
            HIDE FRAME f_cratproi.
            HIDE MESSAGE NO-PAUSE.
            
            ENABLE b_cratpro WITH FRAME f_cratpro.

         END.
      ELSE
      IF tt-cratpro.cdtippro = 10 THEN /*Aplicacao*/
         DO:
            ASSIGN aux_contador = 0
                   aux_label2 = "        " + TRIM(ENTRY(1,aux_label,":")).

            IF TRIM(tt-cratpro.nmprepos) <> "" THEN
               ASSIGN aux_dsddados[1] = 
                      "             Preposto: " + tt-cratpro.nmprepos
                      aux_contador = 1.
            IF TRIM(tt-cratpro.nmoperad) <> "" THEN
               ASSIGN aux_dsddados[1 + aux_contador] =
                      "             Operador: " + tt-cratpro.nmoperad
                      aux_contador = aux_contador + 1.                 
               
            ASSIGN aux_dsddados[1 + aux_contador] = 
                   "     " + aux_label2 + ": " + aux_auxiliar
                   aux_dsddados[2 + aux_contador] = 
                           "          Solicitante: " + TRIM(ENTRY(1,tt-cratpro.dsinform[2],"#"))
                   aux_dsddados[3 + aux_contador] = 
                           "    Data da aplicacao: " + TRIM(ENTRY(2,ENTRY(1,tt-cratpro.dsinform[3],"#"),":"))
                   aux_dsddados[4 + aux_contador] =
                           "    Hora da Aplicacao: " + 
                                 STRING(tt-cratpro.hrautent,"HH:MM:SS")
                   aux_dsddados[5 + aux_contador] =
                           "  Numero da Aplicacao: " + 
                                 TRIM(ENTRY(2,ENTRY(2,tt-cratpro.dsinform[3],"#"),":"))
                   aux_dsddados[5 + aux_contador] = IF NUM-ENTRIES(tt-cratpro.dsinform[3],"#") >= 12 THEN
                                                      IF TRIM(ENTRY(11,tt-cratpro.dsinform[3],"#")) = "N" THEN
                                                        aux_dsddados[5 + aux_contador] + " - " + TRIM(ENTRY(12,tt-cratpro.dsinform[3],"#"))
                                                      ELSE
                                                        aux_dsddados[5 + aux_contador]                                                           
                                                    ELSE
                                                      aux_dsddados[5 + aux_contador]
                   aux_dsddados[6 + aux_contador] =
                   "                Valor: " + STRING(aux_valor)
                   aux_dsddados[7 + aux_contador] =
                   "      Taxa Contratada: " + TRIM(ENTRY(2,ENTRY(3,tt-cratpro.dsinform[3],"#"),":")).

            IF tt-cratpro.dsinform[1] = "Aplicacao Pos"  OR 
               TRIM(ENTRY(11,tt-cratpro.dsinform[3],"#")) = "N" THEN
            /* 8 (rdcpos) ou novos produtos de captacao */
            DO:
                ASSIGN aux_dsddados[8 + aux_contador] =
                       "          Taxa Minima: " + TRIM(ENTRY(2,ENTRY(4,tt-cratpro.dsinform[3],"#"),":"))
                       aux_dsddados[9 + aux_contador] =
                       "           Vencimento: " + TRIM(ENTRY(2,ENTRY(5,tt-cratpro.dsinform[3],"#"),":"))
                       aux_dsddados[10 + aux_contador] =
                       "             Carencia: " + TRIM(ENTRY(2,ENTRY(6,tt-cratpro.dsinform[3],"#"),":"))
                       aux_dsddados[11 + aux_contador] =
                       "     Data da Carencia: " + TRIM(ENTRY(2,ENTRY(7,tt-cratpro.dsinform[3],"#"),":"))
                       aux_dsddados[12 + aux_contador] = 
                       "            Protocolo: " + STRING(tt-cratpro.dsprotoc)
                       aux_dsddados[13 + aux_contador] =
                       "    Seq. Autenticacao: " + STRING(tt-cratpro.nrseqaut).
            END.            
            ELSE 
            /* 7 (rdcpre)*/
            DO:
                ASSIGN aux_dsddados[8 + aux_contador] =
                       "      Taxa no Periodo: " + TRIM(ENTRY(2,ENTRY(11,tt-cratpro.dsinform[3],"#"),":"))
                       aux_dsddados[9 + aux_contador] =
                       "           Vencimento: " + TRIM(ENTRY(2,ENTRY(4,tt-cratpro.dsinform[3],"#"),":"))
                       aux_dsddados[10 + aux_contador] =
                       "             Carencia: " + TRIM(ENTRY(2,ENTRY(5,tt-cratpro.dsinform[3],"#"),":"))
                       aux_dsddados[11 + aux_contador] =
                       "     Data da Carencia: " + TRIM(ENTRY(2,ENTRY(6,tt-cratpro.dsinform[3],"#"),":"))
                       aux_dsddados[12 + aux_contador] = 
                       "            Protocolo: " + STRING(tt-cratpro.dsprotoc)
                       aux_dsddados[13 + aux_contador] =
                       "    Seq. Autenticacao: " + STRING(tt-cratpro.nrseqaut).
            END.
         
            DISP aux_dsddados FORMAT "x(76)" WITH FRAME f_cratproi.
            
           
            RUN fontes/confirma.p (INPUT "Imprimir o Protocolo ? (S)im/(N)ao:",
                                  OUTPUT aux_confirma).
           
            HIDE MESSAGE NO-PAUSE.
           
            IF aux_confirma = "S" THEN 
               DO:
                  RUN Gera_Impressao.
               END.
            
            WAIT "END-ERROR" OF DEFAULT-WINDOW.
            
            HIDE FRAME f_cratproi.
            HIDE MESSAGE NO-PAUSE.
            
            ENABLE b_cratpro WITH FRAME f_cratpro.

         END.
      ELSE
      IF tt-cratpro.cdtippro = 12 THEN /*Resgate de aplicacao*/
          DO:
             ASSIGN aux_contador = 0
                    aux_label2 = "        " + TRIM(ENTRY(1,aux_label,":")).
      
             IF TRIM(tt-cratpro.nmprepos) <> "" THEN
                ASSIGN aux_dsddados[1] = 
                       "             Preposto: " + tt-cratpro.nmprepos
                       aux_contador = 1.
             IF TRIM(tt-cratpro.nmoperad) <> "" THEN
                ASSIGN aux_dsddados[1 + aux_contador] =
                       "             Operador: " + tt-cratpro.nmoperad
                       aux_contador = aux_contador + 1.
                  
             ASSIGN aux_dsddados[1 + aux_contador] = 
                    "     " + aux_label2 + ": " + aux_auxiliar
                    aux_dsddados[2 + aux_contador] = 
                            "          Solicitante: " + TRIM(ENTRY(1,tt-cratpro.dsinform[2],"#"))
                    aux_dsddados[3 + aux_contador] = 
                            "      Data do Resgate: " + TRIM(ENTRY(2,ENTRY(1,tt-cratpro.dsinform[3],"#"),":"))
                    aux_dsddados[4 + aux_contador] =
                            "      Hora do Resgate: " + 
                                  STRING(tt-cratpro.hrautent,"HH:MM:SS")
                    aux_dsddados[5 + aux_contador] =
                            "  Numero da Aplicacao: " + 
                                  TRIM(ENTRY(2,ENTRY(2,tt-cratpro.dsinform[3],"#"),":"))
                    aux_dsddados[6 + aux_contador] =
                            "          Valor Bruto: " + TRIM(ENTRY(2,ENTRY(5,tt-cratpro.dsinform[3],"#"),":"))
                    aux_dsddados[7 + aux_contador] =
                            "                 IRRF: " + TRIM(ENTRY(2,ENTRY(3,tt-cratpro.dsinform[3],"#"),":"))
                    aux_dsddados[8 + aux_contador] = 
                    "                      (Imposto de Renda Retido na Fonte)"
                    aux_dsddados[9 + aux_contador] =
                            "        Aliquota IRRF: " + TRIM(ENTRY(2,ENTRY(4,tt-cratpro.dsinform[3],"#"),":"))
                    aux_dsddados[10 + aux_contador] =
                            "        Valor Liquido: " + STRING(aux_valor)
                    aux_dsddados[11 + aux_contador] = 
                    "            Protocolo: " + STRING(tt-cratpro.dsprotoc)
                    aux_dsddados[12 + aux_contador] =
                    "    Seq. Autenticacao: " + STRING(tt-cratpro.nrseqaut).
      
          
             DISP aux_dsddados FORMAT "x(76)" WITH FRAME f_cratproi. 
            
             RUN fontes/confirma.p (INPUT "Imprimir o Protocolo ? (S)im/(N)ao:",
                                   OUTPUT aux_confirma).
            
             HIDE MESSAGE NO-PAUSE.
            
             IF aux_confirma = "S" THEN 
                DO:
                   RUN Gera_Impressao.
                END.
             
             WAIT "END-ERROR" OF DEFAULT-WINDOW.
             
             HIDE FRAME f_cratproi.
             HIDE MESSAGE NO-PAUSE.
             
             ENABLE b_cratpro WITH FRAME f_cratpro.
      
          END.
      ELSE
      IF tt-cratpro.cdtippro = 13 THEN /*GPS (Previdência Social*/
          DO:

            /* recupera a quantidade de registros */
            aux_qtregist = NUM-ENTRIES(tt-cratpro.dsinform[3], "#").
            
            IF aux_qtregist > 0 THEN
            DO:

                /* carrega variavel com informacoes para o raltorio */
                aux_auxiliar3 = tt-cratpro.dsinform[3].

                aux_prepost = "                      Preposto: " + STRING(tt-cratpro.nmprepos).

                DO aux_contador = 1 TO aux_qtregist:
                
                    /* monta os campos com as informacoes */
                    aux_dsddados[aux_contador] = ENTRY(aux_contador,tt-cratpro.dsinform[3],"#").
                    /* monta alinhamento dos campos com 30 espacos */
                    aux_dsddados[aux_contador] = fill(" ", 30 - length(ENTRY(1, aux_dsddados[aux_contador],":"))) + aux_dsddados[aux_contador].
    
                END.
    
                aux_dsddados[aux_qtregist + 1]  = "                Data Transacao: " + STRING(tt-cratpro.dttransa,"99/99/9999") + "  Hora: " + STRING(tt-cratpro.hrautent,"HH:MM:SS").
                aux_dsddados[aux_qtregist + 2]  = "           Numero do Documento: " + STRING(tt-cratpro.nrdocmto,"zzzzzzzzzz").
                aux_dsddados[aux_qtregist + 3]  = "           Seq da Autenticacao: " + STRING(tt-cratpro.nrseqaut,"zzzzzzzzzz").
                aux_dsddados[aux_qtregist + 4]  = "       Autenticação Eletrônica: " + STRING(tt-cratpro.dsprotoc).
    
                /* Gera informacoes em tela */
                DISP aux_prepost aux_dsddados FORMAT "x(96)" WITH FRAME f_cratproi_gps. 
                
                RUN fontes/confirma.p (INPUT "Imprimir o Protocolo ? (S)im/(N)ao:",
                                      OUTPUT aux_confirma).
                
                HIDE MESSAGE NO-PAUSE.
                
                IF aux_confirma = "S" THEN 
                DO:
                   RUN Gera_Impressao.  /* imprime */
                END.
                
                WAIT "END-ERROR" OF DEFAULT-WINDOW.
                
                HIDE FRAME f_cratproi_gps.
                HIDE MESSAGE NO-PAUSE.

            END.

            ENABLE b_cratpro WITH FRAME f_cratpro.
    
          END.
      ELSE 
         DO:
            ASSIGN aux_contador = 0.
           
            IF tt-cratpro.cdtippro = 3   THEN
               ASSIGN aux_label2 = "    Nr. do Plano".
            ELSE
               ASSIGN aux_label2 = TRIM(ENTRY(1,aux_label,":")).
         
            IF TRIM(tt-cratpro.nmprepos) <> "" THEN
               ASSIGN aux_dsddados[1] = 
                      "           Preposto: " + tt-cratpro.nmprepos
                      aux_contador = 1.
            IF TRIM(tt-cratpro.nmoperad) <> "" THEN
               ASSIGN aux_dsddados[1 + aux_contador] =
                      "           Operador: " + tt-cratpro.nmoperad
                      aux_contador = aux_contador + 1.
                 
            ASSIGN aux_dsddados[1 + aux_contador] = 
                   "   " + aux_label2 + ": " + aux_auxiliar
                   aux_dsddados[2 + aux_contador] = 
                   "               Data: " + STRING(tt-cratpro.dttransa,"99/99/9999")
                   aux_dsddados[3 + aux_contador] =
                   "               Hora: " + 
                                 STRING(tt-cratpro.hrautent,"HH:MM:SS")
                   aux_dsddados[4 + aux_contador] = 
                   "     Data Movimento: " + STRING(tt-cratpro.dtmvtolt,"99/99/9999")
                   aux_dsddados[5 + aux_contador] =
                   "              Valor: " + STRING(aux_valor)
                   aux_dsddados[6 + aux_contador] = 
                   "          Protocolo: " + STRING(tt-cratpro.dsprotoc).
         
            IF TRIM(tel_cdbarras) <> "" THEN
               ASSIGN aux_dsddados[7 + aux_contador] =
                      "   " + tel_cdbarras 
                      aux_contador = aux_contador + 1.
               
            IF TRIM(tel_lndigita) <> "" THEN
               ASSIGN aux_dsddados[7 + aux_contador] = 
                      "    " + tel_lndigita 
                      aux_contador = aux_contador + 1.
         
            DISP aux_dsddados FORMAT "x(76)" WITH FRAME f_cratproi. 
           
            RUN fontes/confirma.p (INPUT "Imprimir o Protocolo ? (S)im/(N)ao:",
                                  OUTPUT aux_confirma).
           
            HIDE MESSAGE NO-PAUSE.
           
            IF aux_confirma = "S" THEN 
               DO:
                  RUN Gera_Impressao.
               END.
            
            WAIT "END-ERROR" OF DEFAULT-WINDOW.
            
            HIDE FRAME f_cratproi.
            HIDE MESSAGE NO-PAUSE.
            
            ENABLE b_cratpro WITH FRAME f_cratpro.

      END.
      
      APPLY "ENTRY" TO b_cratpro IN FRAME f_cratpro.
      
      HIDE FRAME f_nmdafila NO-PAUSE.
       
   END.

VIEW FRAME f_moldura.

PAUSE(0).

/* Usado para criticar acesso aos operadadores */
ASSIGN glb_cdcritic = 0
       glb_cddopcao = "C" 
       aux_dstippro = "Todos|Transferencia|Pagamento|Capital|" +
                      "Credito de Salario|Deposito TAA|Pagamento TAA|" + 
                      "Arquivo Remessa Cobranca||TED|Aplicacao" +
                      "||Resgate de Aplicacao|GPS (Previdência Social)".  

EMPTY TEMP-TABLE tt-tipo.

DO aux_contador = 0 TO 13:

    IF  ENTRY(aux_contador + 1,aux_dstippro,"|") = ""  THEN
        NEXT.

    CREATE tt-tipo.
    ASSIGN tt-tipo.cdtippro = aux_contador
           tt-tipo.dstippro = ENTRY(aux_contador + 1,aux_dstippro,"|").

END.                                              

DO WHILE TRUE:

   RUN fontes/inicia.p.

   ASSIGN tel_dataini = glb_dtmvtolt
          tel_datafin = glb_dtmvtolt.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      IF   glb_cdcritic > 0   THEN
           DO:
               RUN fontes/critic.p.
               BELL.
               MESSAGE glb_dscritic.
               glb_cdcritic = 0.
           END.

      HIDE tel_nmprimtl IN FRAME f_param_pro.
      
      ASSIGN tel_cdtippro = 0.
      
      UPDATE tel_nrdconta 
             WITH FRAME f_param_pro
      EDITING:
          READKEY.
          IF  FRAME-FIELD = "tel_nrdconta"   AND
              LASTKEY = KEYCODE("F7")        THEN
              DO: 
                  RUN fontes/zoom_associados.p (INPUT  glb_cdcooper,
                                                OUTPUT aux_nrdconta).

                  IF  aux_nrdconta > 0   THEN
                      DO:
                          ASSIGN tel_nrdconta = aux_nrdconta.
                          DISPLAY tel_nrdconta WITH FRAME f_param_pro.
                          PAUSE 0.
                          APPLY "RETURN".
                      END.
              END.
          ELSE
              APPLY LASTKEY.

      END.  /*  Fim do EDITING  */
      
      IF   aux_cddopcao <> glb_cddopcao   THEN
           DO:
               { includes/acesso.i }
               aux_cddopcao = glb_cddopcao.
           END. 

      RUN Busca_Dados.
        
      IF  RETURN-VALUE <> "OK" THEN
          NEXT.

      DISPLAY tel_nmprimtl
              WITH FRAME f_param_pro.

      UPDATE tel_dataini  
             tel_datafin 
             WITH FRAME f_param_pro.

      UPDATE tel_cdtippro WITH FRAME f_param_pro
          EDITING:
               READKEY.
               IF   LASTKEY = KEYCODE("F7")   AND
                    FRAME-FIELD = "tel_cdtippro"   THEN
                    DO:
                       HIDE MESSAGE.
                       OPEN QUERY q_lista 
                       FOR EACH tt-tipo NO-LOCK.

                       IF   NUM-RESULTS("q_lista") = 0   THEN
                            MESSAGE "Protocolo(s) nao encontrado(s).".
                       ELSE
                            DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                               UPDATE b_lista WITH FRAME f_lista.
                               LEAVE.
                            END.
                           
                       HIDE FRAME f_lista.
                       NEXT.
                    END.
               APPLY LASTKEY.
               
          END. /* fim do UPDATE EDITING */
      
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
         
         RUN Busca_Protocolos.

         IF  RETURN-VALUE <> "OK" THEN
             DO:
                 HIDE tel_nmprimtl IN FRAME f_param_pro.
                 HIDE tel_dstippro IN FRAME f_param_pro.
                 LEAVE.
             END.

         OPEN QUERY q_cratpro 
         FOR EACH tt-cratpro NO-LOCK BY tt-cratpro.dttransa DESC
                                  BY tt-cratpro.hrautent DESC.
         
         FIND FIRST tt-tipo WHERE tt-tipo.cdtippro = tel_cdtippro
                                  NO-LOCK NO-ERROR.
         
         ASSIGN tel_dstippro = tt-tipo.dstippro.
         
         DISPLAY tel_dstippro
                 WITH FRAME f_param_pro.
         
         ENABLE b_cratpro WITH FRAME f_cratpro.
         WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                                      
         HIDE FRAME f_cratpro.
         HIDE FRAME f_linhas. 
         HIDE tel_dstippro IN FRAME f_param_pro.
         
         HIDE MESSAGE NO-PAUSE.
         
         LEAVE.

      END.  /*  Fim do DO WHILE TRUE  */
   
   END.  /*  Fim do DO WHILE TRUE  */

   
   IF  KEYFUNCTION(LASTKEY) = "END-ERROR" THEN     /*   F4 OU FIM   */
       DO:
           RUN fontes/novatela.p.

           IF   CAPS(glb_nmdatela) <> "VERPRO"  THEN
                DO:
                    HIDE FRAME f_param_pro.
                    HIDE FRAME f_moldura.
                    
                    RETURN.
                END.
           ELSE
                NEXT.
       END.
END.

/* .......................................................................... */

PROCEDURE Busca_Dados:

    DEF VAR aux_nmprimtl AS CHAR                              NO-UNDO.

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0122) THEN
        RUN sistema/generico/procedures/b1wgen0122.p
            PERSISTENT SET h-b1wgen0122.

    RUN Busca_Dados IN h-b1wgen0122
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,           
          INPUT tel_nrdconta,
          INPUT YES,
         OUTPUT aux_nmprimtl,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0122) THEN
        DELETE OBJECT h-b1wgen0122.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.

    ASSIGN tel_nmprimtl = aux_nmprimtl.

    RETURN "OK".

END PROCEDURE. /* Busca_Dados */


PROCEDURE Busca_Protocolos:

    EMPTY TEMP-TABLE tt-erro.

    IF  NOT VALID-HANDLE(h-b1wgen0122) THEN
        RUN sistema/generico/procedures/b1wgen0122.p
            PERSISTENT SET h-b1wgen0122.

    RUN Busca_Protocolos IN h-b1wgen0122
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,           
          INPUT tel_nrdconta,
          INPUT tel_dataini,  
          INPUT tel_datafin,  
          INPUT tel_cdtippro, 
          INPUT YES,
          INPUT 0,
          INPUT 0,
          OUTPUT aux_qtregist,
         OUTPUT TABLE tt-cratpro,
         OUTPUT TABLE tt-erro).

    IF  VALID-HANDLE(h-b1wgen0122) THEN
        DELETE OBJECT h-b1wgen0122.

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
            FIND FIRST tt-erro NO-ERROR.

            IF  AVAILABLE tt-erro THEN
                MESSAGE tt-erro.dscritic.

            RETURN "NOK".  
        END.

    RETURN "OK".

END PROCEDURE. /* Busca_Protocolos */


PROCEDURE Gera_Impressao:

     DEF   VAR aux_flgescra AS LOGICAL                                   NO-UNDO.
     DEF   VAR aux_dscomand AS CHAR                                      NO-UNDO.
     DEF   VAR aux_nmarqpdf AS CHAR                                      NO-UNDO.
     DEF   VAR aux_nmarqimp AS CHAR                                      NO-UNDO.    
     DEF   VAR aux_nmendter AS CHAR       FORMAT "x(20)"                 NO-UNDO.
     DEF   VAR aux_nminfoif AS CHAR                                      NO-UNDO.   

     DEF   VAR par_flgcance AS LOGICAL                                   NO-UNDO.
     DEF   VAR par_flgrodar AS LOGICAL    INIT TRUE                      NO-UNDO.
     DEF   VAR par_flgfirst AS LOGICAL    INIT TRUE                      NO-UNDO.

     EMPTY TEMP-TABLE tt-erro.

     INPUT THROUGH basename `tty` NO-ECHO.
       SET aux_nmendter WITH FRAME f_terminal.
     INPUT CLOSE.

     aux_nmendter = substr(glb_hostname,length(glb_hostname) - 1) +
                           aux_nmendter.

     IF  NOT VALID-HANDLE(h-b1wgen0122) THEN
         RUN sistema/generico/procedures/b1wgen0122.p
             PERSISTENT SET h-b1wgen0122.
     
      IF tt-cratpro.cdtippro = 9 AND NUM-ENTRIES(tt-cratpro.dsinform[2],"#") > 4 THEN /* Se for TED Inclui o ISPB na descricao do banco para mostrar na impressão*/
         aux_nminfoif = tt-cratpro.dsdbanco + "#" + STRING(INT(TRIM(ENTRY(5,tt-cratpro.dsinform[2],"#"))),"99999999").
      ELSE IF trim(substring(tt-cratpro.dsdbanco,1,r-index(tt-cratpro.dsdbanco,"-") - 1)) = '001' THEN
         aux_nminfoif = tt-cratpro.dsdbanco + "#00000000" .
      ELSE 
         aux_nminfoif = tt-cratpro.dsdbanco + "#" .


     RUN Gera_Impressao IN h-b1wgen0122
         ( INPUT glb_cdcooper,
           INPUT glb_cdagenci,
           INPUT 0,
           INPUT glb_cdoperad,
           INPUT glb_nmdatela,
           INPUT 1,
           INPUT aux_nmendter,
           INPUT tel_nrdconta,
           INPUT tel_nmprimtl,
           INPUT tt-cratpro.cdtippro,
           INPUT tt-cratpro.nrdocmto,
           INPUT tt-cratpro.nrseqaut,
           INPUT tt-cratpro.nmprepos,
           INPUT tt-cratpro.nmoperad,
           INPUT tt-cratpro.dttransa,
           INPUT tt-cratpro.hrautent,
           INPUT tt-cratpro.dtmvtolt,
           INPUT tt-cratpro.dsprotoc,
           INPUT tel_cdbarras,
           INPUT tel_lndigita,
           INPUT aux_label,
           INPUT aux_label2,
           INPUT aux_valor,
           INPUT aux_auxiliar,
           INPUT aux_auxiliar2,
           INPUT aux_auxiliar3,
           INPUT aux_auxiliar4,
           INPUT aux_nminfoif,
           INPUT tt-cratpro.dsageban,
           INPUT tt-cratpro.nrctafav,
           INPUT tt-cratpro.nmfavore,
           INPUT tt-cratpro.nrcpffav,
           INPUT tt-cratpro.dsfinali,
           INPUT tt-cratpro.dstransf,
           INPUT YES,
           INPUT tt-cratpro.dsinform,
          OUTPUT aux_nmarqimp, 
          OUTPUT aux_nmarqpdf,
          OUTPUT TABLE tt-erro).
         
     IF  VALID-HANDLE(h-b1wgen0122) THEN
         DELETE OBJECT h-b1wgen0122.

     IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
          DO:
              HIDE MESSAGE NO-PAUSE.

              FIND FIRST tt-erro NO-ERROR.

              IF  AVAILABLE tt-erro THEN
                  MESSAGE tt-erro.dscritic.

              RETURN "NOK".  
          END.
     ELSE
         DO:
            /* Utilizado somente para includes de impressao */
            FIND FIRST crapass WHERE
                     crapass.cdcooper = glb_cdcooper
                     NO-LOCK NO-ERROR.

            { includes/impressao.i }
         END.
        
      RETURN "OK".                  

END PROCEDURE.
