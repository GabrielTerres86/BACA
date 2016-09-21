/* ............................................................................

   Programa: fontes/contas_dados.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Evandro
   Data    : Maio/2006                         Ultima Atualizacao: 27/07/2015

   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados referentes a identificacao do
               Associado.

   Alteracoes: 06/12/2006 - Ordem dos campos e carregar os dados se o titular
                            tiver outra conta (Evandro).
                            
               22/12/2006 - Corrigido o HIDE do frame (Evandro).
               
               17/01/2007 - Nao permitir alterar o nome e o cpf para o primeiro
                            titular (Evandro).
                            
               01/02/2007 - Incluida Unidade Federativa "PB" (Diego).
   
               16/02/2007 - Alterado formato do campo crapttl.nrdocttl (Elton).
               
               21/11/2007 - Retirada atribuicao glb_cdcritic = 0 quando nao
                            confirmar a operacao na Procedure opcao_i (Diego).
                            
               23/11/2007 - Alterado para nao permitir a inclusao de titulares
                            com mesmo CPF (Diego).
                            
               20/12/2007 - Busca informacoes existentes de cooperado quando
                            inclui ou atualiza um titular. 
                          - Atualiza ou cria conjuge quando titular for 
                            alterado ou incluido na conta (Elton).
                                                          
               16/01/2008 - Alterado para tratar Companheiro(cdgraupr = 4) da
                            mesma forma que o Conjuge.
                          - Corrigida "inclusao", para criar crapcje sem 
                            informacoes quando cdgraupr <> 1 e 4 e 
                            cdestcvl = 2,3,4,9,11,12 (Diego).

               20/05/2008 - Alterada a chamada das Naturalidades (Evandro).
               
               09/04/2008 - Verificar LOCK para registro da crapass (David).
               
               17/09/2009 - Melhoria na atualizacao dos dados dos demais 
                            titulares na crapass (David).
                            
               16/12/2009 - Eliminado campo crapttl.cdgrpext (Diego).
               
               12/01/2010 - Adaptar p/utilizacao de BO (Jose Luis/DB1) task 119
               
               28/07/2010 - Incluir help para o campo tel_cdgraupr (David).
               
               22/09/2010 - Controle de revisão cadastral para 1º titular em 
               mais de uma conta 'PAI' (Gabriel, DB1).
               
               16/02/2011 - Ajuste devido a alteracao do campo nome (Henrique).
               
               16/04/2012 - Ajuste para a chamada da tela Responsavel Legal.
                            Projeto GP - Socios Menores (Adriano).
                            
               16/10/2012 - Ajustado layout de tela para exibir melhor descição
                            da descrição do estado civil (Daniel).
                                         
               01/04/2013 - Incluido dentro da procedure Grava_Dados o 
                            "PAUSE(3) NO-MESSAGE" no tratamento do
                            RETURN-VALUE após a chamada do Grava_Dados
                            (Adriano).                          
                            
               12/08/2013 - Incluido campo cdufnatu no frame f_dados. (Reinert)
               
               18/10/2013 - Alterado "format" e posiçao do campo "Natural de" 
                            (Daniele). 
               24/01/2014 - Alterado posiçao do campo "U.F" e "Responsab. Legal".
                            (Daniele).
                            
               27/05/2014 - Alterado o LIKE de crapass.cdestcvl para 
                            crapttl.cdestcvl (Douglas - Chamado 131253)
                            
               27/07/2015 - Reformulacao cadastral (Gabriel-RKAM).             
.............................................................................*/

{ sistema/generico/includes/b1wgen0055tt.i}
{ sistema/generico/includes/b1wgen0072tt.i}
{ sistema/generico/includes/var_internet.i}
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF NEW SHARED VAR shr_tpnacion      LIKE crapttl.tpnacion      NO-UNDO.
DEF NEW SHARED VAR shr_restpnac      AS CHAR  FORMAT "x(15)"    NO-UNDO.
DEF NEW SHARED VAR shr_dsnacion      AS CHAR  FORMAT "x(15)"    NO-UNDO.
DEF NEW SHARED VAR shr_cdestcvl      LIKE crapttl.cdestcvl      NO-UNDO.
DEF NEW SHARED VAR shr_dsestcvl      AS CHAR  FORMAT "x(12)"    NO-UNDO.
DEF NEW SHARED VAR shr_grescola      LIKE crapttl.grescola      NO-UNDO.
DEF NEW SHARED VAR shr_dsescola      AS CHAR  FORMAT "x(15)"    NO-UNDO.
DEF NEW SHARED VAR shr_cdfrmttl      LIKE crapttl.cdfrmttl      NO-UNDO.
DEF NEW SHARED VAR shr_rsfrmttl      AS CHAR  FORMAT "x(15)"    NO-UNDO.
DEF NEW SHARED VAR shr_formacao_pesq AS CHAR  FORMAT "x(15)"    NO-UNDO.

DEF VAR tel_restpnac AS CHAR                FORMAT "x(15)"      NO-UNDO.
DEF VAR tel_dssitcpf AS CHAR                FORMAT "x(11)"      NO-UNDO.
DEF VAR tel_inhabmen AS INTE                FORMAT "9"          NO-UNDO.
DEF VAR tel_dthabmen AS DATE                FORMAT "99/99/9999" NO-UNDO.
DEF VAR tel_gresccje LIKE crapttl.grescola                      NO-UNDO.
DEF VAR tel_dsescola AS CHAR                FORMAT "x(15)"      NO-UNDO.
DEF VAR tel_cdfrmttl LIKE crapttl.cdfrmttl                      NO-UNDO.
DEF VAR tel_rsfrmttl AS CHAR                FORMAT "x(15)"      NO-UNDO.
DEF VAR tel_cdnatopc LIKE crapttl.cdnatopc                      NO-UNDO.
DEF VAR tel_rsnatocp AS CHAR                FORMAT "x(15)"      NO-UNDO.
DEF VAR tel_cdocpttl LIKE crapttl.cdocpttl                      NO-UNDO.   
DEF VAR tel_grescola LIKE crapttl.grescola    INIT 0            NO-UNDO.
DEF VAR tel_rsocupa  AS CHAR                FORMAT "x(15)"      NO-UNDO.
DEF VAR tel_tpcttrab LIKE crapttl.tpcttrab                      NO-UNDO.
DEF VAR tel_dsctrtab AS CHAR                FORMAT "x(15)"      NO-UNDO.
DEF VAR tel_nmextemp LIKE crapttl.nmextemp                      NO-UNDO.
DEF VAR tel_nrcpfemp AS CHAR                FORMAT "x(18)"      NO-UNDO.
DEF VAR tel_dsproftl LIKE crapttl.dsproftl                      NO-UNDO.
DEF VAR tel_cdnvlcgo LIKE crapttl.cdnvlcgo                      NO-UNDO.   
DEF VAR tel_rsnvlcgo AS CHAR                FORMAT "x(10)"      NO-UNDO.
DEF VAR tel_nrfonemp LIKE crapttl.nrfonemp                      NO-UNDO.
DEF VAR tel_dtadmemp LIKE crapttl.dtadmemp                      NO-UNDO.
DEF VAR tel_vlsalari LIKE crapttl.vlsalari                      NO-UNDO.
DEF VAR tel_tpdocptl LIKE crapttl.tpdocttl                      NO-UNDO.
DEF VAR tel_nrdocptl LIKE crapttl.nrdocttl                      NO-UNDO.
DEF VAR tel_cdoedptl LIKE crapttl.cdoedttl                      NO-UNDO.
DEF VAR tel_cdufdptl LIKE crapttl.cdufdttl                      NO-UNDO.
DEF VAR tel_dtemdptl LIKE crapttl.dtemdttl                      NO-UNDO.
DEF VAR tel_dshabmen AS CHAR                FORMAT "x(13)"      NO-UNDO.
DEF VAR tel_qtfoltal AS INTEGER             FORMAT "99"         NO-UNDO.

DEF VAR reg_dsdopcao AS CHAR INIT "Alterar" FORMAT "x(07)"      NO-UNDO.

DEF VAR aux_flgsuces AS LOGICAL                                 NO-UNDO.
DEF VAR aux_nmdcampo AS CHAR                                    NO-UNDO.
DEF VAR aux_msgconta AS CHAR                                    NO-UNDO.
DEF VAR aux_msgalert AS CHAR                                    NO-UNDO.
DEF VAR aux_nrctattl AS INTE                                    NO-UNDO.
DEF VAR aux_cdturnos AS INTE                                    NO-UNDO.
DEF VAR aux_nrcpfcgc AS DEC                                     NO-UNDO. 
DEF VAR h-b1wgen0060 AS HANDLE                                  NO-UNDO.
DEF VAR h-b1wgen0055 AS HANDLE                                  NO-UNDO.
DEF VAR h-b1wgen9999 AS HANDLE                                  NO-UNDO.
DEF VAR aux_verrespo AS LOG                                     NO-UNDO.
DEF VAR aux_permalte AS LOG                                     NO-UNDO.

FORM shr_formacao_pesq LABEL "Formacao"
     WITH ROW 9 COLUMN 15 OVERLAY SIDE-LABELS TITLE "PESQUISA FORMACAO"
          FRAME f_pesq_formacao.

FORM tel_cdgraupr LIKE crapttl.cdgraupr 
                  AT  1 LABEL "Relacionamento com o 1 titular"
         HELP "1-Conjuge,2-Pai/Mae,3-Filho(a),4-Companheiro(a),6-Cooperado"
     tel_dsgraupr       NO-LABEL          FORMAT "x(14)"

     tel_nrcpfcgc AT 50 LABEL "C.P.F."    AUTO-RETURN

                        HELP "Informe o CPF do titular" SKIP
     tel_nmextttl LIKE crapttl.nmextttl
                  AT  1 LABEL "Titular"   AUTO-RETURN   FORMAT "x(50)"
     SKIP
     tel_inpessoa LIKE crapttl.inpessoa
                  AT 1 LABEL "Tp.Natureza" "-"
     tel_dspessoa       NO-LABEL

     tel_dtcnscpf LIKE crapttl.dtcnscpf
                  AT 31 LABEL "Consulta"  AUTO-RETURN
                  HELP "Informe a data da consulta do CPF na Receita Federal"

     tel_cdsitcpf LIKE crapttl.cdsitcpf
                  AT 56 LABEL "Situacao"  AUTO-RETURN
         HELP "Informe situacao CPF(1=Reg.,2=Pend.,3=Cancel.,4=Irreg.,5=Susp.)"
     tel_dssitcpf       NO-LABEL SKIP

     tel_tpdocttl LIKE crapttl.tpdocttl
                  AT  1 LABEL "Documento"  AUTO-RETURN
                        HELP "Informe o tipo de documento (CH, CI, CP, CT)"

     tel_nrdocttl LIKE crapttl.nrdocttl
                        NO-LABEL        FORMAT "x(15)"     AUTO-RETURN
                        HELP "Informe o numero do documento"

     tel_cdoedttl LIKE crapttl.cdoedttl
                  AT 31 LABEL "Org.Emi."   AUTO-RETURN
                        HELP "Informe o orgao emissor do documento"

     tel_cdufdttl LIKE crapttl.cdufdttl
                  AT 47 LABEL "UF"       AUTO-RETURN
                  HELP "Informe a Sigla do Estado que emitiu o documento"

     tel_dtemdttl LIKE crapttl.dtemdttl
                  AT 56 LABEL "Data Emi."  AUTO-RETURN
                        HELP "Informe a data de emissao do documento" SKIP(1)

     tel_dtnasttl LIKE crapttl.dtnasttl
                  AT 1  LABEL "Data Nascimento" AUTO-RETURN FORMAT "99/99/9999"
                        HELP "Informe a data de nascimento do cooperado"

     tel_cdsexotl AT 33 LABEL "Sexo"      FORMAT "!"
                        HELP "(M)asculino / (F)eminino"

     tel_tpnacion LIKE crapttl.tpnacion
                  AT 42 LABEL "Tipo Nacionalidade"
             HELP "Informe o tipo de nacionalidade ou pressione F7 para listar"

     tel_restpnac       NO-LABEL SKIP

     tel_dsnacion LIKE crapttl.dsnacion
                  AT 1 LABEL "Nacionalidade"  AUTO-RETURN
             HELP "Informe a nacionalidade ou pressione F7 para listar"

     tel_dsnatura LIKE crapttl.dsnatura
                  AT 33 LABEL  "Natural de"     AUTO-RETURN FORMAT  "X(25)" 
             HELP "Informe a naturalidade ou pressione F7 para listar"

     tel_cdufnatu LIKE crapttl.cdufnatu
                  AT 70 LABEL "UF"     AUTO-RETURN
             HELP "Informe a sigla do estado" SKIP

     tel_inhabmen AT 1  LABEL "Responsab. Legal"
             HELP "(0)-menor/maior (1)-menor emancipado (2)-incapacidade civil"

     tel_dshabmen       NO-LABEL
     tel_dthabmen AT 43 LABEL "Data Emancipacao"
                        HELP "Informe a data de emancipacao" SKIP(1)

     tel_cdestcvl LIKE crapttl.cdestcvl 
                  AT 1  LABEL "Est. Civil" AUTO-RETURN
                  HELP "Informe o Estado Civil ou pressione F7 para listar"

     tel_dsestcvl NO-LABEL          FORMAT "x(28)"
     tel_grescola AT 45 LABEL "Escolaridade"
              HELP "Informe o grau de escolaridade ou pressione F7 para listar"

     tel_dsescola NO-LABEL SKIP
     tel_cdfrmttl AT  1 LABEL "Curso Sup."
                  HELP "Informe o curso superior ou pressione F7 para listar"

     tel_rsfrmttl       NO-LABEL
     SKIP
     tel_nmtalttl LIKE crapttl.nmtalttl
                  AT  1
                  HELP "Informe nome para impressao no talao de cheques"

     tel_qtfoltal LABEL "Qtd. Folhas Talao"
                  HELP "Quantidade de folhas do talao de cheques (10 ou 20)"

     SKIP

     reg_dsdopcao AT 35 NO-LABEL
                  HELP "Pressione ENTER para selecionar / F4 ou END para sair"

     WITH ROW 7 OVERLAY SIDE-LABELS TITLE " IDENTIFICACAO " CENTERED 
          FRAME f_dados.

/* Eventos para atualizacao das descricoes na tela */

ON LEAVE OF tel_cdsitcpf IN FRAME f_dados DO:

   /* Situacao do CPF/CNPJ */
   ASSIGN INPUT tel_cdsitcpf.

   DYNAMIC-FUNCTION("BuscaSituacaoCpf" IN h-b1wgen0060,
                    INPUT tel_cdsitcpf,
                    OUTPUT tel_dssitcpf,
                    OUTPUT glb_dscritic).

   DISPLAY tel_dssitcpf WITH FRAME f_dados.

END.

ON LEAVE OF tel_tpnacion IN FRAME f_dados DO:

   /* Tipo da Nacionalidade */
   ASSIGN INPUT tel_tpnacion.

   IF  NOT DYNAMIC-FUNCTION("BuscaTipoNacion" IN h-b1wgen0060, 
                            INPUT tel_tpnacion,
                            INPUT "restpnac",
                            OUTPUT tel_restpnac,
                            OUTPUT glb_dscritic) THEN
       ASSIGN tel_restpnac = "DESCONHECIDA".
                                       
   DISPLAY tel_restpnac WITH FRAME f_dados.

END.

ON LEAVE OF tel_inhabmen IN FRAME f_dados DO:

   /* Habilitacao */
   ASSIGN INPUT tel_inhabmen.

   DYNAMIC-FUNCTION("BuscaHabilitacao" IN h-b1wgen0060,
                    INPUT tel_inhabmen,
                    OUTPUT tel_dshabmen,
                    OUTPUT glb_dscritic).
   
   DISPLAY tel_dshabmen WITH FRAME f_dados.

   IF tel_inhabmen <> 1 THEN
      DO:
         ASSIGN tel_dthabmen = ?.

         ASSIGN tel_dthabmen:READ-ONLY IN FRAME f_dados = TRUE.

         DISP tel_dthabmen WITH FRAME f_dados.

      END.
   ELSE
      ASSIGN tel_dthabmen:READ-ONLY IN FRAME f_dados = FALSE.

END.


ON LEAVE OF tel_cdgraupr IN FRAME f_dados DO:

   /* Parentesco */
   ASSIGN INPUT tel_cdgraupr.

   DYNAMIC-FUNCTION("BuscaParentesco" IN h-b1wgen0060,
                    INPUT tel_cdgraupr,
                    OUTPUT tel_dsgraupr,
                    OUTPUT glb_dscritic).
                  
   DISPLAY tel_dsgraupr WITH FRAME f_dados.

END.

ON LEAVE OF tel_cdestcvl IN FRAME f_dados DO:

   /* Estado civil */
   ASSIGN INPUT tel_cdestcvl.

   DYNAMIC-FUNCTION("BuscaEstadoCivil" IN h-b1wgen0060,
                    INPUT tel_cdestcvl,
                    INPUT "dsestcvl",
                    OUTPUT tel_dsestcvl,
                    OUTPUT glb_dscritic).
                                       
   DISPLAY tel_dsestcvl 
           WITH FRAME f_dados.

   /* Quando estado civil for "Casado" e idade for menor que 18 anos,
      a pessoa passa automaticamente a ser emancipada.*/
   IF CAN-DO("2,3,4,8,9,11",STRING(tel_cdestcvl)) THEN
      DO: 
         ASSIGN INPUT tel_dtnasttl.

         IF VALID-HANDLE(h-b1wgen9999) THEN
            DELETE OBJECT h-b1wgen9999.
         
         RUN sistema/generico/procedures/b1wgen9999.p
             PERSISTENT SET h-b1wgen9999.
         
         /* validar pela procedure generica do b1wgen9999.p */
         RUN idade IN h-b1wgen9999 ( INPUT tel_dtnasttl,
                                     INPUT glb_dtmvtolt,
                                     OUTPUT aux_nrdeanos,
                                     OUTPUT aux_nrdmeses,
                                     OUTPUT aux_dsdidade ).

         IF VALID-HANDLE(h-b1wgen9999) THEN
            DELETE OBJECT h-b1wgen9999.

         IF aux_nrdeanos < 18 AND
            tel_inhabmen = 0 THEN
            DO:
               ASSIGN tel_inhabmen = 1
                      tel_dthabmen = glb_dtmvtolt.
             
               DYNAMIC-FUNCTION("BuscaHabilitacao" IN h-b1wgen0060,
                                INPUT tel_inhabmen,
                                OUTPUT tel_dshabmen,
                                OUTPUT glb_dscritic).
             
               DISP tel_inhabmen
                    tel_dthabmen
                    tel_dshabmen 
                    WITH FRAME f_dados.

            END.
         
         ASSIGN tel_inhabmen:READ-ONLY IN FRAME f_dados = TRUE
                tel_dthabmen:READ-ONLY IN FRAME f_dados = TRUE
                aux_nrdeanos = 0
                aux_nrdmeses = 0
                aux_dsdidade = "".
         
      END.
   ELSE
      ASSIGN tel_inhabmen:READ-ONLY IN FRAME f_dados = FALSE
             tel_dthabmen:READ-ONLY IN FRAME f_dados = FALSE.


END.

ON LEAVE OF tel_grescola IN FRAME f_dados DO:

   /* Grau escolar */
   ASSIGN INPUT tel_grescola.

   DYNAMIC-FUNCTION("BuscaGrauEscolar" IN h-b1wgen0060,
                    INPUT tel_grescola,
                    OUTPUT tel_dsescola,
                    OUTPUT glb_dscritic).

   DISPLAY tel_dsescola WITH FRAME f_dados.                  

END.

ON LEAVE OF tel_cdfrmttl IN FRAME f_dados DO:

   /* Formacao */
   ASSIGN INPUT tel_cdfrmttl.

   DYNAMIC-FUNCTION("BuscaFormacao" IN h-b1wgen0060,
                    INPUT tel_cdfrmttl,
                    OUTPUT tel_rsfrmttl,
                    OUTPUT glb_dscritic).

   DISPLAY tel_rsfrmttl WITH FRAME f_dados.

END.

ON ENTRY OF tel_nrcpfcgc IN FRAME f_dados DO:

    ASSIGN tel_nrcpfcgc = REPLACE(REPLACE(tel_nrcpfcgc,".",""),"-","").

    DISPLAY tel_nrcpfcgc WITH FRAME f_dados.
END.

/* Nao deixa passar pelo CPF sem ser um numero valido */
ON LEAVE OF tel_nrcpfcgc IN FRAME f_dados DO:

   ASSIGN INPUT tel_nrcpfcgc.

   IF  NOT DYNAMIC-FUNCTION("ValidaCpfCnpj" IN h-b1wgen0060,
                            INPUT tel_nrcpfcgc,
                            OUTPUT glb_dscritic) THEN 
       DO:
           MESSAGE glb_dscritic.
           RETURN NO-APPLY.
       END.

END.

DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   IF  NOT VALID-HANDLE(h-b1wgen0055) THEN
       RUN sistema/generico/procedures/b1wgen0055.p 
           PERSISTENT SET h-b1wgen0055.

   IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
       RUN sistema/generico/procedures/b1wgen0060.p 
           PERSISTENT SET h-b1wgen0060.

   ASSIGN aux_flgsuces = FALSE
          aux_verrespo = FALSE.

   IF  glb_cddopcao = "I" THEN
       DO:
          RUN opcao_i.
          LEAVE.
       END.

   RUN Busca_Dados ( INPUT "C" ).

   IF  RETURN-VALUE <> "OK" THEN
       LEAVE.

   RUN Atualiza_Campos.

   IF  RETURN-VALUE <> "OK" THEN
       LEAVE.
   
   ASSIGN aux_flgsuces = NO.
          
   DISPLAY tel_cdgraupr WHEN tel_idseqttl <> 1  
           tel_nrcpfcgc tel_nmextttl tel_inpessoa 
           tel_dspessoa tel_dtcnscpf tel_cdsitcpf
           tel_dssitcpf tel_tpdocttl tel_nrdocttl
           tel_cdoedttl tel_cdufdttl tel_dtemdttl
           tel_dtnasttl tel_cdsexotl tel_tpnacion
           tel_restpnac tel_dsnacion tel_dsnatura
           tel_cdufnatu
           tel_inhabmen tel_dshabmen tel_dthabmen
           tel_dsgraupr tel_cdestcvl tel_dsestcvl 
           tel_grescola tel_dsescola tel_cdfrmttl 
           tel_rsfrmttl tel_nmtalttl 
           tel_qtfoltal WHEN tel_idseqttl = 1
           reg_dsdopcao
           WITH FRAME f_dados.

   ASSIGN tel_inhabmen:READ-ONLY IN FRAME f_dados = FALSE
          tel_dthabmen:READ-ONLY IN FRAME f_dados = FALSE.

           
   CHOOSE FIELD reg_dsdopcao WITH FRAME f_dados.

   IF FRAME-FIELD = "reg_dsdopcao"   THEN
      BLOCO_01: DO ON ENDKEY UNDO, NEXT:
      
         ASSIGN glb_nmrotina = "IDENTIFICACAO"
                glb_cddopcao = "A".
      
         { includes/acesso.i } 
      
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      
            UPDATE tel_cdgraupr WHEN tel_idseqttl <> 1
                   tel_nrcpfcgc WHEN tel_idseqttl <> 1
                   WITH FRAME f_dados
      
            EDITING:
                READKEY.
                HIDE MESSAGE NO-PAUSE.
      
                APPLY LASTKEY.
                IF  GO-PENDING THEN
                    DO:
                       ASSIGN INPUT tel_cdgraupr
                              INPUT tel_nrcpfcgc.
      
                       RUN Busca_Dados ( INPUT glb_cddopcao ).
      
                       IF  RETURN-VALUE <> "OK" THEN
                           DO:
                              /* se ocorreu erro, posiciona no campo certo */
                              {sistema/generico/includes/foco_campo.i 
                                  &VAR-GERAL=SIM 
                                  &NOME-FRAME="f_dados"
                                  &NOME-CAMPO=aux_nmdcampo }
                           END.

                    END.

            END.
      
            RUN Atualiza_Campos.
      
            IF RETURN-VALUE <> "OK" THEN
               NEXT.
      
            DISPLAY tel_cdgraupr WHEN tel_idseqttl <> 1  
                    tel_nrcpfcgc 
                    tel_nmextttl 
                    tel_inpessoa 
                    tel_dspessoa 
                    tel_dtcnscpf 
                    tel_cdsitcpf
                    tel_dssitcpf 
                    tel_tpdocttl 
                    tel_nrdocttl
                    tel_cdoedttl 
                    tel_cdufdttl 
                    tel_dtemdttl
                    tel_dtnasttl 
                    tel_cdsexotl 
                    tel_tpnacion
                    tel_restpnac 
                    tel_dsnacion 
                    tel_dsnatura
                    tel_cdufnatu
                    tel_inhabmen 
                    tel_dshabmen 
                    tel_dthabmen
                    tel_dsgraupr 
                    tel_cdestcvl 
                    tel_dsestcvl 
                    tel_grescola 
                    tel_dsescola 
                    tel_cdfrmttl 
                    tel_rsfrmttl 
                    tel_nmtalttl 
                    tel_qtfoltal WHEN tel_idseqttl = 1
                    reg_dsdopcao
                    WITH FRAME f_dados.
      
            IF  aux_msgconta <> "" THEN
                LEAVE.
                                         
            DO WHILE TRUE: 
             
               UPDATE tel_nmextttl WHEN tel_idseqttl <> 1
                      tel_dtcnscpf 
                      tel_cdsitcpf 
                      tel_tpdocttl  
                      tel_nrdocttl 
                      tel_cdoedttl 
                      tel_cdufdttl  
                      tel_dtemdttl 
                      tel_dtnasttl 
                      tel_cdsexotl      
                      tel_tpnacion 
                      tel_dsnacion 
                      tel_dsnatura
                      tel_dsnatura
                      tel_cdufnatu
                      tel_inhabmen 
                      tel_dthabmen 
                      tel_cdestcvl 
                      tel_grescola 
                      tel_cdfrmttl 
                      tel_nmtalttl 
                      tel_qtfoltal WHEN tel_idseqttl = 1  
                      WITH FRAME f_dados
      
               EDITING:
                  READKEY.
                  HIDE MESSAGE NO-PAUSE.
                  
                  IF FRAME-FIELD = "tel_cdsexotl" THEN
                     DO:
                        /* So deixa escrever M ou F */
                        IF NOT CAN-DO("GO,RETURN,TAB,BACK-TAB,BACKSPACE,"
                           + "END-ERROR,HELP,CURSOR-UP,CURSOR-DOWN," + 
                             "CURSOR-LEFT,CURSOR-RIGHT,M,F",
                             KEY-FUNCTION(LASTKEY))   THEN
                             MESSAGE "Escolha (M)asculino / (F)eminino".
                        ELSE 
                           DO:
                              IF KEY-FUNCTION(LASTKEY) = "BACKSPACE" THEN
                                 NEXT-PROMPT tel_cdsexotl
                                             WITH FRAME f_dados.
                        
                              HIDE MESSAGE NO-PAUSE.
                              APPLY LASTKEY.
                           END.
                     END.
                  ELSE               
                  IF LASTKEY = KEYCODE("F7") THEN
                     DO:
                        IF FRAME-FIELD = "tel_tpnacion" THEN
                           DO:
                              shr_tpnacion = INPUT tel_tpnacion.
                              RUN fontes/zoom_tipo_nacion.p.
                              IF  shr_tpnacion <> 0  THEN
                                  DO:
                                      ASSIGN tel_tpnacion = shr_tpnacion
                                             tel_restpnac = shr_restpnac.
                        
                                      DISPLAY tel_tpnacion
                                              tel_restpnac
                                              WITH FRAME f_dados.
                                         
                                      NEXT-PROMPT tel_tpnacion
                                                  WITH FRAME f_dados.
                                  END.
                           END.
                        ELSE
                        IF FRAME-FIELD = "tel_dsnacion"  THEN
                           DO:
                              shr_dsnacion = INPUT tel_dsnacion.
                              RUN fontes/nacion.p.
                              IF   shr_dsnacion <> " " THEN
                                   DO:
                                      tel_dsnacion = shr_dsnacion.
                                      DISPLAY tel_dsnacion
                                              WITH FRAME f_dados.
                                       NEXT-PROMPT tel_dsnacion
                                                   WITH FRAME f_dados.
                                   END.
                           END.
                        ELSE
                        IF FRAME-FIELD = "tel_dsnatura" THEN
                           DO:
                              RUN fontes/natura.p (OUTPUT shr_dsnatura).
                              IF  shr_dsnatura <> "" THEN
                                  DO:
                                      tel_dsnatura = shr_dsnatura.
                                      DISPLAY tel_dsnatura
                                              WITH FRAME f_dados.
                                      NEXT-PROMPT tel_dsnatura
                                              WITH FRAME f_dados.
                                  END.
                           END.
                        ELSE
                        IF FRAME-FIELD = "tel_cdestcvl"  THEN
                           DO:
                              shr_cdestcvl = INPUT tel_cdestcvl.
                              RUN fontes/zoom_estcivil.p.
                              IF  shr_cdestcvl <> 0 THEN
                                  DO:
                                     ASSIGN tel_cdestcvl = shr_cdestcvl
                                            tel_dsestcvl = shr_dsestcvl.

                                     DISPLAY tel_cdestcvl
                                             tel_dsestcvl
                                             WITH FRAME f_dados.
                                                
                                     NEXT-PROMPT tel_cdestcvl
                                                 WITH FRAME f_dados.
                                  END.
                           END.
                        ELSE
                        IF FRAME-FIELD = "tel_grescola" THEN
                           DO:
                              ASSIGN shr_grescola = INPUT tel_grescola.
                              RUN fontes/zoom_grau_instrucao.p.
                              IF shr_grescola <> 0 THEN
                                 DO:
                                     ASSIGN tel_grescola = shr_grescola
                                            tel_dsescola = shr_dsescola.

                                     DISPLAY tel_grescola tel_dsescola
                                             WITH FRAME f_dados.
                           
                                     NEXT-PROMPT tel_grescola
                                                 WITH FRAME f_dados.
                                 END.
                           END.
                        ELSE
                        IF FRAME-FIELD = "tel_cdfrmttl" THEN
                           DO:
                              FORMACAO_1:
                              DO WHILE TRUE ON ENDKEY UNDO 
                                 FORMACAO_1, LEAVE:
                        
                                 ASSIGN shr_formacao_pesq = " ".
                                 UPDATE shr_formacao_pesq
                                        WITH FRAME f_pesq_formacao.
                                 HIDE FRAME f_pesq_formacao.
                                 ASSIGN shr_cdfrmttl = tel_cdfrmttl.
                                 RUN fontes/zoom_curso_superior.p.
                                 IF shr_cdfrmttl <> 0 THEN
                                    DO:
                                        ASSIGN tel_cdfrmttl = shr_cdfrmttl
                                               tel_rsfrmttl = shr_rsfrmttl.

                                        DISPLAY tel_cdfrmttl
                                                tel_rsfrmttl
                                                WITH FRAME f_dados.
                                               
                                        NEXT-PROMPT tel_cdfrmttl
                                                    WITH FRAME f_dados.
                                    END.
      
                                 LEAVE. /* FORMACAO_1 */
                              END.
                           END.
                     END. /* fim do F7 */
                  ELSE
                     APPLY LASTKEY.
      
                  IF GO-PENDING THEN
                     DO:               
                        RUN Valida_Dados.
      
                        IF RETURN-VALUE <> "OK" THEN
                           DO: 
                              IF aux_nmdcampo = "dthabmen" THEN
                                 DO:
                                    ASSIGN tel_dthabmen:READ-ONLY IN 
                                           FRAME f_dados = FALSE.
                                    
                                    ASSIGN INPUT tel_dthabmen.

                                 END.
                                     
                              /* se ocorreu erro, posiciona no campo 
                                 correto */
                              {sistema/generico/includes/foco_campo.i 
                                  &NOME-FRAME="f_dados"
                                  &NOME-CAMPO=aux_nmdcampo }

                           END.

                     END.

               END. /* fim EDITING */
               
               LEAVE. 
            
            END. /** Fim do WHILE TRUE **/
            
            LEAVE.
            
         END. /* Fim do WHILE */
      
         DISPLAY tel_nmextttl    
                 tel_tpdocttl    
                 tel_cdoedttl
                 tel_cdufdttl    
                 tel_dsnacion    
                 tel_dsnatura
                 tel_nmtalttl    
                 WITH FRAME f_dados. PAUSE 0.
         
         IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
            UNDO BLOCO_01, LEAVE BLOCO_01.
              
         IF aux_msgconta <> "" THEN 
            MESSAGE aux_msgconta.
         
         IF aux_msgconta = "" THEN
            DO:       
               ASSIGN aux_nrcpfcgc = DEC(tel_nrcpfcgc).
               
               /*Tela Resp. Legal apenas sera chamada para quando, for 
                 primeiro titular */
               IF ((tel_inhabmen = 0   AND
                    aux_nrdeanos < 18) OR 
                    tel_inhabmen = 2)  AND
                    tel_idseqttl = 1   THEN
                  DO:  
                      RUN fontes/contas_responsavel.p (INPUT glb_nmrotina,
                                                       INPUT tel_nrdconta,
                                                       INPUT tel_idseqttl,
                                                       INPUT tel_nrcpfcgc,
                                                       INPUT tel_dtnasttl,
                                                       INPUT tel_inhabmen,
                                                       OUTPUT aux_permalte,
                                                       INPUT-OUTPUT TABLE tt-resp). 
               
                      /*As variaveis abaixo estao sendo alimentadas
                        devido a serem atualizadas dentro do
                        contas_responsavel */
                      ASSIGN glb_cddopcao = "A"
                             glb_nmrotina = "IDENTIFICACAO"
                             tel_nrcpfcgc = STRING(aux_nrcpfcgc)
                             aux_verrespo = TRUE.

                      RUN Valida_Dados.
      
                      IF RETURN-VALUE <> "OK" THEN
                         UNDO BLOCO_01, LEAVE BLOCO_01.
               
                  END.

                  RUN Confirma.
             
             IF aux_confirma = "S" THEN
                DO:
                   RUN Grava_Dados.
                   
                   IF aux_msgalert <> "" THEN
                      MESSAGE aux_msgalert.
          
                   IF RETURN-VALUE <> "OK" THEN
                      DO:
                          ASSIGN aux_confirma = "N".
                          PAUSE 5 NO-MESSAGE.
                          UNDO BLOCO_01, LEAVE BLOCO_01.
    
                      END.
                   ELSE
                       DO:
                          ASSIGN aux_flgsuces = YES.
                          LEAVE BLOCO_01.
    
                       END.
                END.
      
            END.
         
       
         
         
      
      END. /* Fim DO ON ENDKEY */
      
      IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR 
         aux_confirma <> "S"                THEN
         NEXT.

      LEAVE.
       
END.

IF VALID-HANDLE(h-b1wgen0055) THEN
   DELETE OBJECT h-b1wgen0055.

IF VALID-HANDLE(h-b1wgen0060) THEN
   DELETE OBJECT h-b1wgen0060.

IF aux_flgsuces   THEN
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      MESSAGE "Alteracao efetuada com sucesso!".
      PAUSE 2 NO-MESSAGE.
      HIDE MESSAGE NO-PAUSE.
      LEAVE.

  END.

HIDE FRAME f_dados NO-PAUSE.
HIDE MESSAGE NO-PAUSE.

PROCEDURE Busca_Dados:

    DEFINE INPUT  PARAMETER par_cddopcao AS CHARACTER   NO-UNDO.

    DO WITH FRAME f_dados:

        ASSIGN INPUT tel_nrcpfcgc
               INPUT tel_cdgraupr
               tel_nrcpfcgc = REPLACE(REPLACE(tel_nrcpfcgc,".",""),"-","").
    END.


    RUN Busca_Dados IN h-b1wgen0055
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT par_cddopcao,
          INPUT tel_cdgraupr,
          INPUT tel_nrcpfcgc,
         OUTPUT aux_msgconta,
         OUTPUT TABLE tt-dados-fis,
         OUTPUT TABLE tt-erro ) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  RETURN "NOK".
               END.
        END.

    RETURN "OK".

END.

PROCEDURE Valida_Dados:

    DO WITH FRAME f_dados:
        ASSIGN INPUT tel_nrcpfcgc
               INPUT tel_cdgraupr
               INPUT tel_nmextttl
               INPUT tel_dtcnscpf
               INPUT tel_cdsitcpf
               INPUT tel_tpdocttl
               INPUT tel_nrdocttl
               INPUT tel_cdoedttl
               INPUT tel_cdufdttl
               INPUT tel_dtemdttl
               INPUT tel_dtnasttl
               INPUT tel_cdsexotl
               INPUT tel_tpnacion
               INPUT tel_dsnacion
               INPUT tel_dsnatura
               INPUT tel_cdufnatu
               INPUT tel_inhabmen
               INPUT tel_dthabmen
               INPUT tel_cdestcvl
               INPUT tel_grescola
               INPUT tel_cdfrmttl
               INPUT tel_nmtalttl
               INPUT tel_qtfoltal.

    END.

    ASSIGN tel_nrcpfcgc = REPLACE(REPLACE(tel_nrcpfcgc,".",""),"-","").
           

    RUN Valida_Dados IN h-b1wgen0055
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT glb_cddopcao,
          INPUT glb_dtmvtolt,
          INPUT tel_cdgraupr,
          INPUT tel_nrcpfcgc,
          INPUT tel_nmextttl,
          INPUT aux_nrctattl,
          INPUT tel_inpessoa,
          INPUT tel_dtcnscpf,
          INPUT tel_cdsitcpf,
          INPUT tel_tpdocttl,
          INPUT tel_nrdocttl,
          INPUT tel_cdoedttl,
          INPUT tel_cdufdttl,
          INPUT tel_dtemdttl,
          INPUT tel_dtnasttl,
          INPUT (IF tel_cdsexotl = "M" THEN
                    1 
                 ELSE 
                    IF tel_cdsexotl = "F" THEN 
                       2 
                    ELSE 
                       9),
          INPUT tel_tpnacion,
          INPUT tel_dsnacion,
          INPUT tel_dsnatura,
          INPUT tel_cdufnatu,
          INPUT tel_inhabmen,
          INPUT tel_dthabmen,
          INPUT tel_cdestcvl,
          INPUT tel_grescola,
          INPUT tel_cdfrmttl,
          INPUT "",
          INPUT tel_nmtalttl,
          INPUT tel_qtfoltal,
          INPUT aux_verrespo,
          INPUT aux_permalte,
          INPUT TABLE tt-resp,
         OUTPUT aux_nmdcampo,
         OUTPUT TABLE tt-erro,
         OUTPUT aux_nrdeanos,
         OUTPUT aux_nrdmeses,
         OUTPUT aux_dsdidade ) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  PAUSE.
                  HIDE MESSAGE.
                  RETURN "NOK".

               END.
        END.

    RETURN "OK".

END.

PROCEDURE Grava_Dados:
    
    ASSIGN tel_nrcpfcgc = REPLACE(REPLACE(tel_nrcpfcgc,".",""),"-","").

    IF  VALID-HANDLE(h-b1wgen0055) THEN
        DELETE OBJECT h-b1wgen0055.

    RUN sistema/generico/procedures/b1wgen0055.p PERSISTENT SET h-b1wgen0055.
        RUN Grava_Dados IN h-b1wgen0055
        ( INPUT glb_cdcooper,
          INPUT 0,           
          INPUT 0,           
          INPUT glb_cdoperad,
          INPUT glb_nmdatela,
          INPUT 1,           
          INPUT tel_nrdconta,
          INPUT tel_idseqttl,
          INPUT glb_cddopcao,
          INPUT glb_dtmvtolt,
          INPUT YES,
          INPUT tel_cdgraupr,
          INPUT DEC(tel_nrcpfcgc),
          INPUT tel_cdoedttl,
          INPUT tel_dtnasttl,
          INPUT tel_nmtalttl,
          INPUT tel_inhabmen,
          INPUT tel_cdfrmttl,
          INPUT tel_qtfoltal,
          INPUT tel_nmextttl,
          INPUT tel_dtcnscpf,
          INPUT tel_tpdocttl,
          INPUT tel_cdufdttl,
          INPUT (IF tel_cdsexotl = "M" THEN 
                    1 
                 ELSE 
                    2),
          INPUT tel_dsnacion,
          INPUT tel_cdestcvl,
          INPUT tel_grescola,
          INPUT tel_inpessoa,
          INPUT tel_cdsitcpf,
          INPUT tel_nrdocttl,
          INPUT tel_dtemdttl,
          INPUT tel_tpnacion,
          INPUT tel_dsnatura,
          INPUT tel_cdufnatu,
          INPUT tel_dthabmen,
          INPUT "",
          INPUT tel_cdnatopc,
          INPUT tel_cdocpttl,
          INPUT tel_tpcttrab,
          INPUT tel_nmextemp,
          INPUT tel_nrcpfemp,
          INPUT tel_dsproftl,
          INPUT tel_cdnvlcgo,
          INPUT tel_nrfonemp,
          INPUT aux_cdturnos,
          INPUT tel_dtadmemp,
          INPUT tel_vlsalari,
          INPUT TABLE tt-resp,
         OUTPUT aux_msgalert,
         OUTPUT aux_tpatlcad,
         OUTPUT aux_msgatcad,
         OUTPUT aux_chavealt,
         OUTPUT TABLE tt-erro ) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               DO:
                  MESSAGE tt-erro.dscritic.
                  PAUSE(3) NO-MESSAGE.
                  RETURN "NOK".
               END.
        END.

    /* verificar se é necessario registrar o crapalt */
    RUN proc_altcad (INPUT "b1wgen0055.p").

    DELETE OBJECT h-b1wgen0055.

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

    RETURN "OK".

END.

PROCEDURE Atualiza_Campos:

    FIND FIRST tt-dados-fis NO-LOCK NO-ERROR.

    IF  AVAILABLE tt-dados-fis THEN
        DO:
           ASSIGN tel_cdgraupr = tt-dados-fis.cdgraupr
                  tel_dsgraupr = tt-dados-fis.dsgraupr
                  tel_nrcpfcgc = STRING(STRING(tt-dados-fis.nrcpfcgc,
                                        "99999999999"),
                                        "XXX.XXX.XXX-XX")
                  tel_nmextttl = tt-dados-fis.nmextttl
                  tel_inpessoa = tt-dados-fis.inpessoa
                  tel_dspessoa = tt-dados-fis.dspessoa
                  tel_dtcnscpf = tt-dados-fis.dtcnscpf
                  tel_cdsitcpf = tt-dados-fis.cdsitcpf
                  tel_dssitcpf = tt-dados-fis.dssitcpf
                  tel_tpdocttl = tt-dados-fis.tpdocttl
                  tel_nrdocttl = tt-dados-fis.nrdocttl
                  tel_cdoedttl = tt-dados-fis.cdoedttl
                  tel_cdufdttl = tt-dados-fis.cdufdttl
                  tel_dtemdttl = tt-dados-fis.dtemdttl
                  tel_dtnasttl = tt-dados-fis.dtnasttl
                  tel_cdsexotl = IF tt-dados-fis.cdsexotl = 1 THEN "M" ELSE "F"
                  tel_tpnacion = tt-dados-fis.tpnacion
                  tel_restpnac = tt-dados-fis.destpnac
                  tel_dsnacion = tt-dados-fis.dsnacion
                  tel_dsnatura = tt-dados-fis.dsnatura
                  tel_cdufnatu = tt-dados-fis.cdufnatu
                  tel_inhabmen = tt-dados-fis.inhabmen
                  tel_dshabmen = tt-dados-fis.dshabmen
                  tel_dthabmen = tt-dados-fis.dthabmen
                  tel_cdestcvl = tt-dados-fis.cdestcvl
                  tel_dsestcvl = tt-dados-fis.dsestcvl
                  tel_grescola = tt-dados-fis.grescola
                  tel_dsescola = tt-dados-fis.dsescola
                  tel_cdfrmttl = tt-dados-fis.cdfrmttl
                  tel_rsfrmttl = tt-dados-fis.rsfrmttl
                  tel_nmtalttl = tt-dados-fis.nmtalttl
                  tel_qtfoltal = tt-dados-fis.qtfoltal
                  aux_nrctattl = tt-dados-fis.nrctattl
                  
                  tel_cdnatopc = tt-dados-fis.cdnatopc
                  tel_cdocpttl = tt-dados-fis.cdocpttl
                  tel_tpcttrab = tt-dados-fis.tpcttrab
                  tel_nmextemp = tt-dados-fis.nmextemp
                  tel_nrcpfemp = STRING(tt-dados-fis.nrcpfemp)
                  tel_dsproftl = tt-dados-fis.dsproftl
                  tel_cdnvlcgo = tt-dados-fis.cdnvlcgo
                  tel_nrfonemp = tt-dados-fis.nrfonemp
                  aux_cdturnos = tt-dados-fis.cdturnos
                  tel_dtadmemp = tt-dados-fis.dtadmemp
                  tel_vlsalari = tt-dados-fis.vlsalari.
                  

        END.   
    ELSE       
        DO:    
          ASSIGN tel_nmextttl = ""
                 tel_inpessoa = 1
                 tel_dspessoa = ""
                 tel_dtcnscpf = ?
                 tel_cdsitcpf = 0
                 tel_dssitcpf = ""
                 tel_tpdocttl = ""
                 tel_nrdocttl = ""
                 tel_cdoedttl = ""
                 tel_cdufdttl = ""
                 tel_dtemdttl = ?
                 tel_dtnasttl = ?
                 tel_cdsexotl = "M"
                 tel_tpnacion = 0
                 tel_restpnac = ""
                 tel_dsnacion = ""
                 tel_dsnatura = ""
                 tel_cdufnatu = ""
                 tel_inhabmen = 0
                 tel_dshabmen = ""
                 tel_dthabmen = ?
                 tel_cdestcvl = 0
                 tel_dsestcvl = ""
                 tel_grescola = 0
                 tel_dsescola = ""
                 tel_cdfrmttl = 0
                 tel_rsfrmttl = ""
                 tel_nmtalttl = ""
                 tel_qtfoltal = 0
                 aux_nrctattl = 0.

        END.

    RETURN "OK".
               
END.           
               
PROCEDURE Confirma:

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

       ASSIGN aux_confirma = "N"
              glb_cdcritic = 78.
       RUN fontes/critic.p.
       BELL.
       glb_cdcritic = 0.
       MESSAGE COLOR NORMAL glb_dscritic
       UPDATE aux_confirma.
       LEAVE.

    END.  /*  Fim do DO WHILE TRUE  */

    IF KEYFUNCTION(LASTKEY) = "END-ERROR" OR
       aux_confirma <> "S"                THEN
       DO:
           glb_cdcritic = 79.
           RUN fontes/critic.p.
           BELL.
           MESSAGE glb_dscritic.
           PAUSE 2 NO-MESSAGE.
           HIDE MESSAGE NO-PAUSE.
           UNDO, RETURN.

       END.
       
    RETURN "OK".

END PROCEDURE.

PROCEDURE opcao_i:        

   DO ON ENDKEY UNDO, RETURN:
                  
      ASSIGN tel_inpessoa = 1
             tel_dspessoa = "FISICA"
             tel_nrcpfcgc = "0"
             tel_cdsexotl = "M".
              
      DISPLAY tel_inpessoa    
              tel_dspessoa 
              WITH FRAME f_dados.
              
      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
              
         UPDATE tel_cdgraupr WHEN tel_idseqttl <> 1
                tel_nrcpfcgc  
                WITH FRAME f_dados
      
         EDITING:
             READKEY.
             HIDE MESSAGE NO-PAUSE.
      
             APPLY LASTKEY.
             IF  GO-PENDING THEN
                 DO:
                    ASSIGN INPUT tel_cdgraupr
                           INPUT tel_nrcpfcgc.
      
                    RUN Busca_Dados ( INPUT glb_cddopcao ).
      
                    IF  RETURN-VALUE <> "OK" THEN
                        NEXT.
                 END.
         END.
      
         RUN Atualiza_Campos.
      
         IF  RETURN-VALUE <> "OK" THEN
             NEXT.
      
         IF  aux_msgconta <> "" THEN
             DO:
                MESSAGE aux_msgconta.
                LEAVE.
             END.
      
         /* se nao possuir cadastra libera os campos para digitar */
         DO WHILE TRUE: 
         
            UPDATE tel_nmextttl 
                   tel_dtcnscpf 
                   tel_cdsitcpf
                   tel_tpdocttl 
                   tel_nrdocttl 
                   tel_cdoedttl
                   tel_cdufdttl 
                   tel_dtemdttl 
                   tel_dtnasttl
                   tel_cdsexotl 
                   tel_tpnacion 
                   tel_dsnacion
                   tel_dsnatura
                   tel_cdufnatu
                   tel_inhabmen 
                   tel_dthabmen
                   tel_cdestcvl 
                   tel_grescola 
                   tel_cdfrmttl
                   tel_nmtalttl  
                   WITH FRAME f_dados
         
            EDITING:
              READKEY.
              HIDE MESSAGE NO-PAUSE.
         
              IF FRAME-FIELD = "tel_cdsexotl"   THEN
                 DO:
                    /* So deixa escrever M ou F */
                    IF  NOT CAN-DO("GO,RETURN,TAB,BACK-TAB,BACKSPACE," +
                        "END-ERROR,HELP,CURSOR-UP,CURSOR-DOWN," + 
                        "CURSOR-LEFT,CURSOR-RIGHT,M,F",
                        KEY-FUNCTION(LASTKEY)) THEN
                        MESSAGE "Escolha (M)asculino / (F)eminino".
                    ELSE 
                        DO:
                           IF  KEY-FUNCTION(LASTKEY) = "BACKSPACE"  THEN
                               NEXT-PROMPT tel_cdsexotl WITH FRAME f_dados.
                               APPLY LASTKEY.
                        END.
                 END.
              ELSE               
                 IF LASTKEY = KEYCODE("F7") THEN
                    DO:
                       IF FRAME-FIELD = "tel_tpnacion" THEN
                          DO:
                             shr_tpnacion = INPUT tel_tpnacion.
                             RUN fontes/zoom_tipo_nacion.p.
                             IF  shr_tpnacion <> 0  THEN
                                 DO:
                                    ASSIGN tel_tpnacion = shr_tpnacion
                                           tel_restpnac = shr_restpnac.
                          
                                    DISPLAY tel_tpnacion 
                                            tel_restpnac
                                            WITH FRAME f_dados.
                                      
                                    NEXT-PROMPT tel_tpnacion
                                        WITH FRAME f_dados.
                                 END.
                          END.
                       ELSE
                       IF FRAME-FIELD = "tel_dsnacion"  THEN
                          DO:
                             shr_dsnacion = INPUT tel_dsnacion.
                             RUN fontes/nacion.p.
                             IF   shr_dsnacion <> " " THEN
                                  DO:
                                      tel_dsnacion = shr_dsnacion.

                                      DISPLAY tel_dsnacion
                                              WITH FRAME f_dados.

                                      NEXT-PROMPT tel_dsnacion
                                                  WITH FRAME f_dados.
                                  END.
                          END.
                       ELSE
                       IF FRAME-FIELD = "tel_dsnatura" THEN
                          DO:
                             RUN fontes/natura.p (OUTPUT shr_dsnatura).
                             IF  shr_dsnatura <> "" THEN
                                 DO:
                                    tel_dsnatura = shr_dsnatura.

                                    DISPLAY tel_dsnatura
                                            WITH FRAME f_dados.

                                    NEXT-PROMPT tel_dsnatura
                                            WITH FRAME f_dados.
                                 END.
                          END.
                       ELSE
                       IF FRAME-FIELD = "tel_cdestcvl"  THEN
                          DO:
                             shr_cdestcvl = INPUT tel_cdestcvl.
                             RUN fontes/zoom_estcivil.p.
                             IF  shr_cdestcvl <> 0 THEN
                                 DO:
                                    ASSIGN tel_cdestcvl = shr_cdestcvl
                                           tel_dsestcvl = shr_dsestcvl.
      
                                    DISPLAY tel_cdestcvl
                                            tel_dsestcvl
                                            WITH FRAME f_dados.
                                               
                                    NEXT-PROMPT tel_cdestcvl
                                                WITH FRAME f_dados.
                                 END.
                          END.
                       ELSE
                       IF FRAME-FIELD = "tel_grescola" THEN
                          DO:
                             ASSIGN shr_grescola = INPUT tel_grescola.
                             RUN fontes/zoom_grau_instrucao.p.
                             IF shr_grescola <> 0 THEN
                                DO:
                                   ASSIGN  tel_grescola = shr_grescola
                                           tel_dsescola = shr_dsescola.
      
                                   DISPLAY tel_grescola tel_dsescola
                                           WITH FRAME f_dados.
      
                                   NEXT-PROMPT tel_grescola
                                               WITH FRAME f_dados.
                                END.
                          END.
                       ELSE
                       IF FRAME-FIELD = "tel_cdfrmttl" THEN
                          DO:
                             FORMACAO_1:
                             DO WHILE TRUE ON ENDKEY UNDO FORMACAO_1,LEAVE:
      
                                ASSIGN shr_formacao_pesq = " ".
                                UPDATE shr_formacao_pesq
                                       WITH FRAME f_pesq_formacao.
      
                                HIDE FRAME f_pesq_formacao.
                                ASSIGN shr_cdfrmttl = tel_cdfrmttl.
                                RUN fontes/zoom_curso_superior.p.
                                IF shr_cdfrmttl <> 0 THEN
                                   DO:
                                      ASSIGN tel_cdfrmttl = shr_cdfrmttl
                                             tel_rsfrmttl = shr_rsfrmttl.
      
                                      DISPLAY tel_cdfrmttl
                                              tel_rsfrmttl 
                                              WITH FRAME f_dados.
      
                                      NEXT-PROMPT tel_cdfrmttl
                                                  WITH FRAME f_dados.
                                   END.
                                LEAVE.
      
                             END.
                          END.
                    END. /* fim do F7 */
              ELSE     
                 APPLY LASTKEY.
              IF GO-PENDING THEN
                 DO:                
                    RUN Valida_Dados.
      
                    IF  RETURN-VALUE <> "OK" THEN
                        DO: 
                            IF aux_nmdcampo = "dthabmen" THEN
                               DO:
                                  ASSIGN tel_dthabmen:READ-ONLY IN 
                                         FRAME f_dados = FALSE.
                                  
                                  ASSIGN INPUT tel_dthabmen.

                               END.

                            /* se ocorreu erro, posiciona no campo correto */
                            {sistema/generico/includes/foco_campo.i 
                                &VAR-GERAL=SIM 
                                &NOME-FRAME="f_dados"
                                &NOME-CAMPO=aux_nmdcampo }

                        END.
                 END.
            END. /* fim EDITING */
      
            LEAVE.
             
         END. /** Fim WHILE TRUE **/
      
         LEAVE.

      END.
           
      IF KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
         UNDO, RETURN.
      
      DISPLAY tel_cdgraupr WHEN tel_idseqttl <> 1 
              tel_nrcpfcgc 
              tel_nmextttl 
              tel_inpessoa
              tel_dspessoa 
              tel_dtcnscpf 
              tel_cdsitcpf
              tel_dssitcpf 
              tel_tpdocttl 
              tel_nrdocttl
              tel_cdoedttl 
              tel_cdufdttl 
              tel_dtemdttl
              tel_dtnasttl 
              tel_cdsexotl 
              tel_tpnacion
              tel_restpnac 
              tel_dsnacion 
              tel_dsnatura
              tel_cdufnatu
              tel_inhabmen 
              tel_dshabmen 
              tel_dthabmen
              tel_dsgraupr 
              tel_cdestcvl 
              tel_dsestcvl
              tel_grescola 
              tel_dsescola 
              tel_cdfrmttl
              tel_rsfrmttl 
              tel_nmtalttl 
              tel_qtfoltal WHEN tel_idseqttl = 1      
              WITH FRAME f_dados.       
      
      IF aux_msgconta = "" THEN
         DO: 
            ASSIGN aux_nrcpfcgc = DEC(tel_nrcpfcgc).
            
            /*Tela Resp. Legal apenas sera chamada para quando, for 
              primeiro titular */
            IF ((tel_inhabmen = 0   AND 
                 aux_nrdeanos < 18) OR
                 tel_inhabmen = 2)  AND
                 tel_idseqttl = 1   THEN
               DO:  
                   RUN fontes/contas_responsavel.p (INPUT glb_nmrotina,
                                                    INPUT tel_nrdconta,
                                                    INPUT tel_idseqttl,
                                                    INPUT tel_nrcpfcgc,
                                                    INPUT tel_dtnasttl,
                                                    INPUT tel_inhabmen,
                                                    OUTPUT aux_permalte,
                                                    INPUT-OUTPUT TABLE tt-resp). 
            
                   /*As variaveis abaixo estao sendo alimentadas
                     devido a serem atulizadas dentro do
                     contas_responsavel */
                   ASSIGN glb_cddopcao = "I"
                          glb_nmrotina = "IDENTIFICACAO"
                          tel_nrcpfcgc = STRING(aux_nrcpfcgc)
                          aux_verrespo = TRUE.

                   RUN Valida_Dados.
      
                   IF RETURN-VALUE <> "OK" THEN
                      NEXT.
            
               END.
      
         END.
      
      ASSIGN aux_flgsuces = FALSE.
     
      RUN Confirma.
      
      IF aux_confirma = "S" THEN
         DO:
            RUN Grava_Dados.
      
            IF RETURN-VALUE <> "OK" THEN
               UNDO, RETURN.
            ELSE
               ASSIGN aux_flgsuces = YES.

         END.
          
   END. /* fim DO ON ENDKEY */

   RETURN "OK".

END PROCEDURE.
