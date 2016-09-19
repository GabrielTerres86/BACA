/* ............................................................................

   Programa: fontes/contas_comercial.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Eduardo/Evandro
   Data    : Junho/2006                        Ultima Atualizacao: 24/08/2015
 
   Dados referentes ao programa:
   
   Frequencia: Diario (on-line)
   Objetivo  : Efetuar manutencao dos dados referentes ao Comercial.

   Alteracoes: 22/12/2006 - Nao limpar os dados caso seja empresa 81 (Evandro).
   
               05/01/2007 - Atualizar tambem o campo dtadmemp da crapass
                            (Evandro).
                            
               12/01/2007 - Limpar a empresa se for sem vinculo, colocar em
                            letras maiusculas os campos "tel_nmextemp" e
                            "tel_dsproftl" (Evandro).
                            
               24/01/2007 - Efetuado acerto no campo empresa (Diego).

               14/03/2007 - Atualizar crapepr, crappla e crapavs quando alterar
                            empresa do associado (Julio)
               
               20/03/2007 - Alterado formato dos campos de endereco para serem
                            do mesmo formato dos campos da tabela crapenc
                            (Elton).
               
               26/03/2007 - Incluido campo "Secao" com informacoes da
                            crapttl.dssolida (Elton).

               13/09/2007 - Atualiza contratos da crapepr quando alterado
                            numero do cadastro da empresa do associado (Elton).
               
               08/09/2007 - Utilizar do novo campo crapttl.nmdsecao(Guilherme).
              
               19/02/2008 - Nao atualiza automaticamente campo "Nome empresa"
                            quando for empresa 81 (Empresas Diversas) (Elton).
                            
               20/03/2008 - Alterada descricao do tipo de contrato de trabalho
                            para "2-TEMP/TERCEIRO" (Evandro).
                            
               01/09/2008 - Alteracao CDEMPRES (Kbase).

               24/06/2009 - Extender o rendimento para 4 valores (Gabriel). 
               
               06/07/2009 - Eliminar uso do campo "ttl.dssolida" (Evandro).
               
               26/05/2010 - Adaptar para uso de BO (Jose Luis, DB1).
               
               22/09/2010 - Bloqueio ediçao em conta filha (Gabriel, DB1).
               
               07/04/2011 - Inclusao de CEP integrado. (André - DB1)
               
               10/06/2011 - Ajuste para "empresas diversas" na Acredicoop,
                            codigo deve ser 88 (David).
                            
               17/06/2011 - Incluir campo Politicamente Exposta (Gabriel) 
               
               21/11/2011 - Realizado alteracao para melhorar o acesso a 
                            alteracao do item outros rendimentos (Adriano).
                            
               14/10/2013 - Tratamento para emitir mensagem quando da alteracao
                            para empresa que nao debita cotas capital em folha.
                            (Fabricio)
                            
              07/01/20014 - Ajuste para separar as justificativas. (Jorge)
              
              12/08/2015 - Projeto Reformulacao cadastral
                           Eliminado o campo nmdsecao (Tiago Castro - RKAM).
                           
              24/08/2015 - Reformulacao cadastral (Gabriel-RKAM).             

              17/12/2015 - #350828 Descricao do valor do campo 
                           Pessoa politicamente exposta (Carlos)             

.............................................................................*/

{ sistema/generico/includes/b1wgen0075tt.i }
{ sistema/generico/includes/b1wgen0038tt.i }
{ sistema/generico/includes/b1wgen0059tt.i &BD-GEN=SIM }
{ sistema/generico/includes/var_internet.i }
{ sistema/generico/includes/gera_log.i }
{ sistema/generico/includes/gera_erro.i }
{ includes/var_online.i }
{ includes/var_contas.i }
{ sistema/generico/includes/b1wgenvlog.i &VAR-GERAL=SIM &SESSAO-DESKTOP=SIM }

DEF NEW SHARED VAR shr_cdnatocp LIKE crapttl.cdnatopc             NO-UNDO.
DEF NEW SHARED VAR shr_rsnatocp AS CHAR FORMAT "x(15)"            NO-UNDO.
DEF NEW SHARED VAR shr_ocupacao_pesq AS CHAR FORMAT "x(15)"       NO-UNDO.
DEF NEW SHARED VAR shr_cdocpttl LIKE crapttl.cdocpttl             NO-UNDO.
DEF NEW SHARED VAR shr_rsdocupa AS CHAR FORMAT "x(15)"            NO-UNDO.
DEF NEW SHARED VAR shr_cdnvlcgo LIKE crapttl.cdnvlcgo             NO-UNDO.
DEF NEW SHARED VAR shr_rsnvlcgo AS CHAR FORMAT "x(10)"            NO-UNDO.
DEF NEW SHARED VAR shr_cdempres LIKE crapemp.cdempres             NO-UNDO.
DEF NEW SHARED VAR shr_nmresemp LIKE crapemp.nmresemp             NO-UNDO.

DEF VAR tel_nrendcom AS INTE FORMAT "zzz,zz9"                     NO-UNDO.  
DEF VAR tel_complcom AS CHAR FORMAT "X(40)"                       NO-UNDO.
DEF VAR tel_endrect1 LIKE crapenc.dsendere                        NO-UNDO.
DEF VAR tel_bairoct1 LIKE crapenc.nmbairro                        NO-UNDO.
DEF VAR tel_cepedct1 LIKE crapenc.nrcepend                        NO-UNDO.
DEF VAR tel_cxpotct1 AS INTE FORMAT "zz,zz9"                      NO-UNDO.
DEF VAR tel_cidadct1 LIKE crapenc.nmcidade                        NO-UNDO.
DEF VAR tel_ufresct1 LIKE crapenc.cdufende  FORMAT "x(2)"         NO-UNDO.
DEF VAR tel_cdnatopc LIKE crapttl.cdnatopc                        NO-UNDO.
DEF VAR tel_cdturnos LIKE crapttl.cdturnos                        NO-UNDO.
DEF VAR tel_dsturnos AS CHAR FORMAT "x(11)"                       NO-UNDO.
DEF VAR tel_rsnatocp AS CHAR FORMAT "x(15)"                       NO-UNDO.
DEF VAR tel_cdocpttl LIKE crapttl.cdocpttl                        NO-UNDO.
DEF VAR tel_rsocupa  AS CHAR FORMAT "x(15)"                       NO-UNDO.
DEF VAR tel_tpcttrab LIKE crapttl.tpcttrab                        NO-UNDO.
DEF VAR tel_dsctrtab AS CHAR FORMAT "x(15)"                       NO-UNDO.
DEF VAR tel_nmextemp AS CHAR FORMAT "x(35)"                       NO-UNDO.
DEF VAR tel_nrcpfemp AS CHAR FORMAT "99999999999999"              NO-UNDO.
DEF VAR tel_dsproftl LIKE crapttl.dsproftl                        NO-UNDO.
DEF VAR tel_cdnvlcgo LIKE crapttl.cdnvlcgo                        NO-UNDO.   
DEF VAR tel_rsnvlcgo AS CHAR FORMAT "x(10)"                       NO-UNDO.
DEF VAR tel_dtadmemp LIKE crapttl.dtadmemp                        NO-UNDO.
DEF VAR tel_vlsalari LIKE crapttl.vlsalari                        NO-UNDO.
DEF VAR tel_tpdrendi AS INTE                                      NO-UNDO.
DEF VAR aux_tpdrendi AS INTE                                      NO-UNDO.
DEF VAR aux_tpdrend2 AS INTE                                      NO-UNDO.

DEF VAR tel_tpdrend2 AS INTE                                      NO-UNDO. 
DEF VAR tel_tpdrend3 AS INTE                                      NO-UNDO.
DEF VAR tel_tpdrend4 AS INTE                                      NO-UNDO.

DEF VAR tel_dstipren AS CHAR FORMAT "X(17)"                       NO-UNDO.
DEF VAR aux_dstipren AS CHAR FORMAT "X(17)"                       NO-UNDO.

DEF VAR tel_dstipre2 AS CHAR FORMAT "X(17)"                       NO-UNDO.
DEF VAR tel_dstipre3 AS CHAR FORMAT "X(17)"                       NO-UNDO.
DEF VAR tel_dstipre4 AS CHAR FORMAT "X(17)"                       NO-UNDO.

DEF VAR tel_vldrendi AS DECI                                      NO-UNDO.
DEF VAR aux_vldrendi AS DECI                                      NO-UNDO.
DEF VAR aux_vldrend2 AS DECI                                      NO-UNDO.

DEF VAR tel_vldrend2 AS DECI                                      NO-UNDO.
DEF VAR tel_vldrend3 AS DECI                                      NO-UNDO.
DEF VAR tel_vldrend4 AS DECI                                      NO-UNDO.

DEF VAR tel_cdempres AS INT  FORMAT "zzzz9"                       NO-UNDO.
DEF VAR tel_nmresemp AS CHAR FORMAT "x(13)"                       NO-UNDO.
DEF VAR tel_nrcadast LIKE crapttl.nrcadast                        NO-UNDO.
DEF VAR tel_inpolexp LIKE crapttl.inpolexp                        NO-UNDO.

/* 0 = nao, 1 = sim, 2 = pendente */
DEF VAR tel_dspolexp AS CHAR FORMAT "x(8)"                        NO-UNDO.
DEF VAR tel_lipolexp AS CHAR EXTENT 3 INIT ["Nao",
                                            "Sim",
                                            "Pendente"]           NO-UNDO.

DEF VAR reg_dsdopcao AS CHAR EXTENT 2 INIT ["Alterar",
                                            "Outros Rendimentos"] NO-UNDO.

DEF VAR h-b1wgen0075 AS HANDLE                                    NO-UNDO.
DEF VAR h-b1wgen0059 AS HANDLE                                    NO-UNDO.
DEF VAR h-b1wgen0060 AS HANDLE                                    NO-UNDO.

DEF VAR aux_nmdcampo AS CHAR                                      NO-UNDO.
DEF VAR aux_nrdrowid AS ROWID                                     NO-UNDO.
DEF VAR aux_qtregist AS INTEGER                                   NO-UNDO.
DEF VAR aux_flgsuces AS LOGICAL                                   NO-UNDO.
DEF VAR aux_msgconta AS CHARACTER                                 NO-UNDO.
DEF VAR aux_msgrvcad AS CHAR                                      NO-UNDO.
DEF VAR aux_dsjusren AS CHAR EXTENT 3 FORMAT "x(60)"              NO-UNDO.
DEF VAR aux_dsjusre2 AS CHAR EXTENT 3 FORMAT "x(60)"              NO-UNDO.
DEF VAR aux_dsdopcao AS CHAR EXTENT 3 INIT  ["Alterar",
                                             "Excluir",
                                             "Incluir"]           NO-UNDO.
DEF VAR reg_contador AS INT INIT 1                                NO-UNDO.
DEF VAR reg_cddopcao AS CHAR EXTENT 3 INIT ["A","E","I"]          NO-UNDO.
DEF VAR aux_nrdlinha AS INT                                       NO-UNDO.
DEF VAR tel_dsjusren AS CHAR                                      NO-UNDO.
DEF VAR tel_dsjsure2 AS CHAR                                      NO-UNDO.
DEF VAR aux_dscjusti AS CHAR                                      NO-UNDO.
DEF VAR aux_flgexist AS LOG                                       NO-UNDO.
DEF VAR tel_totrendi AS DEC                                       NO-UNDO.
DEF VAR aux_totregis AS INT                                       NO-UNDO.

DEF VAR aux_cotcance AS CHAR                                      NO-UNDO.

FORM 
    tel_cdnatopc  AT  1  LABEL "Nat.Ocupacao"
    HELP "Informe a natureza de ocupacao ou pressione F7 para listar"
    tel_rsnatocp  AT 18  NO-LABEL
    tel_cdocpttl  AT 34  
    HELP "Informe codigo da ocupacao ou pressione F7 para listar"
    tel_rsocupa          NO-LABEL 
    SKIP
    tel_tpcttrab  AT  1  LABEL "Tp.Ctr.Trab."
    HELP "Contrato de trab.: 1-PERMANENTE, 2-TEMP/TERCEIRO, 3-SEM VINCULO"
    tel_dsctrtab         NO-LABEL
    tel_cdempres  AT 35  LABEL "Empresa"
    HELP "Informe o codigo da empresa ou pressione F7 para listar"
    tel_nmresemp         NO-LABEL 
    SKIP
    tel_nmextemp         LABEL "Nome empresa" 
                         HELP "Informe nome da empresa onde trabalha"
    tel_nrcpfemp         LABEL "C.N.P.J." FORMAT "XX.XXX.XXX/XXXX-XX"
                         HELP "Informe o CNPJ da empresa"
    tel_dsproftl  AT 37  LABEL "Cargo" 
                         HELP "Informe cargo que exerce na empresa" 
    SKIP
    tel_cdnvlcgo  AT  1  LABEL "Nivel Cargo"
    HELP "Informe codigo do nivel do cargo ou pressione F7 para listar"
    tel_rsnvlcgo         NO-LABEL
    tel_nrcadast  AT 34  LABEL "Cad.Emp."
                         HELP "Informe o numero do cadastro/dv do titular" 
    tel_cdturnos  AT  59 LABEL "Turno"  FORMAT "9" AUTO-RETURN
    HELP "Informe o turno que trabalha ou pressione F7 para listar"
    tel_dsturnos         NO-LABEL  

    tel_dspolexp  AT  1  LABEL "Pessoa Politicamente Exposta"
            
    tel_cepedct1  AT  4  LABEL "CEP"  FORMAT "99999,999"
    HELP "Informe o cep do endereco ou pressione F7 para pesquisar"
    tel_endrect1  AT 23  LABEL "Endereco" HELP "Informe o endereco" 
    SKIP
    tel_nrendcom  AT  3  LABEL "Nro." HELP  "Informe o numero do endereco"
    tel_complcom  AT 20  LABEL "Complemento" 
                         HELP  "Informe o complemento do endereco" 
    SKIP
    tel_bairoct1  AT  1  LABEL "Bairro" HELP "Informe o nome do bairro"
    tel_cxpotct1  AT 59  LABEL "Caixa Postal" HELP  "Numero da caixa postal" 

    SKIP
    tel_cidadct1  AT 1  LABEL "Cidade" HELP "Informe o nome da cidade"
    tel_ufresct1  AT 50  LABEL "U.F."   HELP "Informe a Sigla do Estado"
    
    SKIP
    tel_dtadmemp  AT 1  LABEL "Admissao" 
                        HELP "Informe a data de admissao na empresa"
    tel_vlsalari  AT 47 LABEL "Rendimento" FORMAT "zzz,zz9.99"
                        HELP "Informe o valor do rendimento" 
    SKIP
    "Total de Outros Rendimentos:"
    tel_totrendi            NO-LABEL FORMAT "zzz,zz9.99"
    reg_dsdopcao[1]  AT 26  NO-LABEL
    HELP "Pressione ENTER para selecionar / F4 ou END para sair"
    reg_dsdopcao[2]         NO-LABEL FORMAT "x(18)"
    HELP "Pressione ENTER para selecionar / F4 ou END para sair"

    WITH FRAME f_comercial ROW 7 OVERLAY SIDE-LABELS 
    TITLE " COMERCIAL " CENTERED .


FORM SKIP(1)
     SPACE (2)
     "Origem:"     AT 12
     aux_tpdrend2         NO-LABEL       FORMAT "z9"
     "-"
     aux_dstipren         NO-LABEL
     aux_vldrend2         LABEL "Valor"  FORMAT "zzz,zz9.99"
     VALIDATE((INPUT aux_tpdrend2 = 0  AND
               INPUT aux_vldrend2 = 0) OR
              (INPUT aux_tpdrend2 <> 0 AND
               INPUT aux_vldrend2 <> 0),
               "375 - O campo deve ser preenchido.")
     SKIP
     aux_dsjusre2[1]        LABEL "Justificativa" AUTO-RETURN
     aux_dsjusre2[2]  AT 16 NO-LABEL              AUTO-RETURN
     aux_dsjusre2[3]  AT 16 NO-LABEL FORMAT "x(40)"
     SKIP(1)
     WITH OVERLAY ROW 8 WIDTH 78 SIDE-LABELS CENTERED FRAME f_manipula_rendi.

FORM SKIP(8)
     aux_dsjusren[1]        LABEL "Justificativa"
     aux_dsjusren[2]  AT 16 NO-LABEL
     aux_dsjusren[3]  AT 16 NO-LABEL
     SKIP(1)
     aux_dsdopcao[1]  AT 30 NO-LABEL
     aux_dsdopcao[2]        NO-LABEL
     aux_dsdopcao[3]        NO-LABEL
     WITH ROW 7 WIDTH 80 OVERLAY SIDE-LABELS
          TITLE " Outros Rendimentos "  FRAME f_justif.

FORM shr_ocupacao_pesq LABEL "Ocupacao"
     WITH ROW 9 CENTERED OVERLAY SIDE-LABELS TITLE "PESQUISA OCUPACAO"
          FRAME f_pesq_ocupacao.

DEF QUERY q_tipos_rendim FOR tt-rendimentos.

DEF BROWSE b_tipos_rendim QUERY q_tipos_rendim
    DISPLAY tt-rendimentos.dsorigem COLUMN-LABEL "Origem" FORMAT "x(35)"
            tt-rendimentos.vldrendi COLUMN-LABEL "Valor"    
            WITH 4 DOWN NO-BOX.

FORM b_tipos_rendim HELP "Pressione ENTER para selecionar ou F4 para sair"
     WITH WIDTH 52 ROW 8 COLUMN 15 OVERLAY SCROLLBAR-VERTICAL 
          FRAME f_tipos_rendimento.


/* Inclusao de CEP integrado. (André - DB1) */
ON GO, LEAVE OF tel_cepedct1 DO:
    IF  INPUT tel_cepedct1 = 0  THEN
        RUN Limpa_Endereco.

END.

ON RETURN OF tel_cepedct1 DO:

    HIDE MESSAGE NO-PAUSE.

    ASSIGN INPUT tel_cepedct1.

    IF  tel_cepedct1 <> 0  THEN 
        DO:
            RUN fontes/zoom_endereco.p (INPUT tel_cepedct1,
                                        OUTPUT TABLE tt-endereco).
    
            FIND FIRST tt-endereco NO-LOCK NO-ERROR.
    
            IF  AVAIL tt-endereco THEN
                DO:
                    ASSIGN tel_cepedct1 = tt-endereco.nrcepend 
                           tel_endrect1 = tt-endereco.dsendere 
                           tel_bairoct1 = tt-endereco.nmbairro 
                           tel_cidadct1 = tt-endereco.nmcidade 
                           tel_ufresct1 = tt-endereco.cdufende.
                END.
            ELSE 
                DO:
                    IF  KEYFUNCTION(LASTKEY) = "END-ERROR"  THEN
                        RETURN NO-APPLY.
                        
                    MESSAGE "CEP nao cadastrado.".
                    RUN Limpa_Endereco.
                    RETURN NO-APPLY.
                END.
        END.
    ELSE
        RUN Limpa_Endereco.

    DISPLAY tel_cepedct1  tel_endrect1
            tel_bairoct1  tel_cidadct1
            tel_ufresct1 
            WITH FRAME f_comercial.

    NEXT-PROMPT tel_nrendcom WITH FRAME f_comercial.
END.
          
ON LEAVE OF tel_tpcttrab DO:

   ASSIGN INPUT tel_tpcttrab.

   DYNAMIC-FUNCTION("BuscaTpContrTrab" IN h-b1wgen0060,
                    INPUT tel_tpcttrab,
                   OUTPUT tel_dsctrtab,
                   OUTPUT glb_dscritic).

   DISPLAY tel_dsctrtab WITH FRAME f_comercial.
   
   IF  glb_dscritic <> "" THEN
       DO:
          MESSAGE glb_dscritic.
          RETURN NO-APPLY.
       END.

   RUN controla_campos(INPUT INPUT tel_tpcttrab).

   IF   KEYFUNCTION(LASTKEY) <> "CURSOR-UP"     AND
        KEYFUNCTION(LASTKEY) <> "CURSOR-DOWN"   THEN
        RETURN NO-APPLY.
         
END.

ON LEAVE OF tel_cdnatopc DO:

   ASSIGN INPUT tel_cdnatopc.

   /* Nat. Ocupacao */
   DYNAMIC-FUNCTION("BuscaNatOcupacao" IN h-b1wgen0060,
                    INPUT tel_cdnatopc,
                   OUTPUT tel_rsnatocp,
                   OUTPUT glb_dscritic).

   DISPLAY tel_rsnatocp WITH FRAME f_comercial.

   IF  glb_dscritic <> "" THEN
       DO:
          MESSAGE glb_dscritic.
          RETURN NO-APPLY.
       END.
                     
   IF   INPUT tel_cdnatopc = 11   OR    /* SEM REMUNERACAO */
        INPUT tel_cdnatopc = 12   THEN  /* SEM VINCULO */
        DO:
            tel_tpcttrab = 3. /* Sem vinculo */
            
            DISPLAY tel_tpcttrab WITH FRAME f_comercial.
             
            DISABLE tel_tpcttrab WITH FRAME f_comercial.
             
            APPLY "LEAVE" TO tel_tpcttrab IN FRAME f_comercial.
 
            PAUSE 0.
        END.
    ELSE
        DO:
            ENABLE tel_cdnatopc    tel_cdocpttl    tel_tpcttrab  
                   tel_cdempres    tel_nmextemp    tel_nrcpfemp  
                   tel_dsproftl    tel_cdnvlcgo    tel_nrcadast
                   tel_cepedct1    tel_nrendcom    tel_complcom    
                   tel_cxpotct1    tel_cdturnos
                   tel_dtadmemp    tel_vlsalari    
                   WITH FRAME f_comercial.

        END.

END.   

ON LEAVE OF tel_cdocpttl DO:

   ASSIGN INPUT tel_cdocpttl.

   /* ocupacao */
   DYNAMIC-FUNCTION("BuscaOcupacao" IN h-b1wgen0060,
                    INPUT tel_cdocpttl,
                   OUTPUT tel_rsocupa,
                   OUTPUT glb_dscritic).
                     
   DISPLAY tel_rsocupa WITH FRAME f_comercial.

   IF  glb_dscritic <> "" THEN
       DO:
          MESSAGE glb_dscritic.
          RETURN NO-APPLY.
       END.

   PAUSE 0.
    
END.

ON LEAVE OF tel_cdnvlcgo DO:

   ASSIGN INPUT tel_cdnvlcgo.

   DYNAMIC-FUNCTION("BuscaNivelCargo" IN h-b1wgen0060,
                    INPUT tel_cdnvlcgo,
                   OUTPUT tel_rsnvlcgo,
                   OUTPUT glb_dscritic).
                     
   DISPLAY tel_rsnvlcgo WITH FRAME f_comercial.

   IF  glb_dscritic <> "" THEN
       DO:
          MESSAGE glb_dscritic.
          RETURN NO-APPLY.
       END.
END.

ON LEAVE OF tel_cdempres DO:

   ASSIGN INPUT tel_cdempres.

   /* Empresa */
   DYNAMIC-FUNCTION("BuscaEmpresa" IN h-b1wgen0060,
                    INPUT glb_cdcooper,
                    INPUT tel_cdempres,
                   OUTPUT tel_nmresemp,
                   OUTPUT glb_dscritic ).

   IF  glb_dscritic <> "" THEN
       DO:
          MESSAGE glb_dscritic.
          RETURN NO-APPLY.
       END.

   RUN Busca_Dados.

   IF  RETURN-VALUE <> "OK" THEN
       RETURN NO-APPLY.

   RUN Atualiza_Tela.

   /* Empresas diversas */
   IF   (glb_cdcooper = 2 AND tel_cdempres = 88) OR tel_cdempres = 81  THEN
        DO:
            DISPLAY tel_nmresemp 
                    WITH FRAME f_comercial.

            ENABLE tel_nmextemp    tel_nrcpfemp    
                   tel_dsproftl    tel_cdnvlcgo    tel_nrcadast
                   tel_cepedct1    tel_nrendcom    tel_complcom    
                   tel_cxpotct1    tel_cdturnos
                   tel_dtadmemp    tel_vlsalari    
                   WITH FRAME f_comercial.

            NEXT-PROMPT tel_nmextemp WITH FRAME f_comercial.
            RETURN NO-APPLY.
        END.
   ELSE
        DO:
            DISPLAY  tel_nmresemp  tel_nmextemp  tel_nrcpfemp 
                     tel_cepedct1  tel_endrect1  tel_nrendcom
                     tel_complcom  tel_bairoct1  tel_cidadct1
                     tel_ufresct1  tel_cxpotct1
                     WITH FRAME f_comercial.

            DISABLE  tel_nmextemp  tel_nrcpfemp  tel_cepedct1
                     tel_complcom  tel_nrendcom  tel_cxpotct1
                     WITH FRAME f_comercial.
        END.
END.

ON LEAVE OF tel_cdturnos DO:

   ASSIGN INPUT tel_cdturnos.

   /* Turnos */
   DYNAMIC-FUNCTION("BuscaTurnos" IN h-b1wgen0060,
                    INPUT glb_cdcooper,
                    INPUT tel_cdturnos,
                   OUTPUT tel_dsturnos,
                   OUTPUT glb_dscritic ).
                     
   DISPLAY tel_dsturnos WITH FRAME f_comercial.

   IF  glb_dscritic <> "" THEN
       DO:
          MESSAGE glb_dscritic.
          RETURN NO-APPLY.
       END.
END.


ON LEAVE OF aux_tpdrend2 IN FRAME f_manipula_rendi DO:

    ASSIGN INPUT aux_tpdrend2.

    /* tipos de rendimento */
    DYNAMIC-FUNCTION ("BuscaTipoRendimento" IN h-b1wgen0060,
                      INPUT glb_cdcooper,
                      INPUT aux_tpdrend2,
                     OUTPUT aux_dstipren,
                     OUTPUT glb_dscritic ).
    
   DISPLAY aux_dstipren WITH FRAME f_manipula_rendi.
   
   IF  glb_dscritic <> "" AND aux_tpdrend2 <> 0 THEN
       DO:
          MESSAGE glb_dscritic.
          RETURN NO-APPLY.

       END.

END.

ON ENTRY OF b_tipos_rendim IN FRAME f_tipos_rendimento DO:

   IF aux_nrdlinha > 0 THEN
      REPOSITION q_tipos_rendim TO ROW(aux_nrdlinha).

END.


ON RETURN OF aux_dsjusre2[1] IN FRAME f_manipula_rendi DO:

   NEXT-PROMPT aux_dsjusre2[2].

END.

ON RETURN OF aux_dsjusre2[2] IN FRAME f_manipula_rendi DO:

   NEXT-PROMPT aux_dsjusre2[3].

END.


ON ANY-KEY OF b_tipos_rendim IN FRAME f_tipos_rendimento DO:

   HIDE MESSAGE NO-PAUSE.

   IF KEY-FUNCTION(LASTKEY) = "GO" THEN
      RETURN NO-APPLY.

   IF KEY-FUNCTION(LASTKEY) = "CURSOR-RIGHT"   THEN
      DO:
         reg_contador = reg_contador + 1.
    
         IF reg_contador > 3   THEN
            reg_contador = 1.
             
         glb_cddopcao = reg_cddopcao[reg_contador].

      END.
   ELSE        
   IF KEY-FUNCTION(LASTKEY) = "CURSOR-LEFT"   THEN
      DO:
         reg_contador = reg_contador - 1.

         IF reg_contador < 1   THEN
            reg_contador = 3.
              
         glb_cddopcao = reg_cddopcao[reg_contador].

      END.
   ELSE
   IF KEY-FUNCTION(LASTKEY) = "RETURN"   THEN
      DO: 
         IF (glb_cddopcao = "A"                        OR
             glb_cddopcao = "E")                       AND
             NOT TEMP-TABLE tt-rendimentos:HAS-RECORDS THEN
             RETURN NO-APPLY.

         ASSIGN glb_cddopcao = reg_cddopcao[reg_contador]
                aux_tpdrend2 = 0    
                aux_vldrend2 = 0    
                aux_dstipren = ""   
                aux_dsjusre2[1] = ""
                aux_dsjusre2[2] = ""
                aux_dsjusre2[3] = ""
                aux_tpdrend2 = tt-rendimentos.tpdrendi WHEN glb_cddopcao <> "I"
                aux_vldrend2 = tt-rendimentos.vldrendi WHEN glb_cddopcao <> "I"
                aux_dstipren = tt-rendimentos.dsdrendi WHEN glb_cddopcao <> "I"
                aux_dsjusre2[1]:HIDDEN IN FRAME f_manipula_rendi = YES
                aux_dsjusre2[2]:HIDDEN IN FRAME f_manipula_rendi = YES
                aux_dsjusre2[3]:HIDDEN IN FRAME f_manipula_rendi = YES.

         IF glb_cddopcao = "A" THEN 
            FRAME f_manipula_rendi:TITLE = "Alterar".
         ELSE
           IF glb_cddopcao = "E" THEN 
              FRAME f_manipula_rendi:TITLE = "Excluir".
           ELSE
             FRAME f_manipula_rendi:TITLE = "Incluir".


         VIEW FRAME f_manipula_rendi.
                

         DISP aux_tpdrend2 
              aux_vldrend2
              aux_dstipren
              WITH FRAME f_manipula_rendi.
         
         IF glb_cddopcao <> "E" THEN
            DO:
                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                
                   UPDATE aux_tpdrend2
                          aux_vldrend2
                          WITH FRAME f_manipula_rendi
                
                   EDITING:
                           
                      READKEY.
                
                      IF LAST-KEY = KEYCODE("F7") THEN
                         DO:
                            IF FRAME-FIELD = "aux_tpdrend2" THEN
                               DO:
                                  RUN zoom_tipo_rendimento
                                           (INPUT-OUTPUT aux_tpdrend2,
                                            INPUT-OUTPUT aux_dstipren).
                                                     
                                  DISPLAY aux_tpdrend2   
                                          aux_dstipren 
                                          WITH FRAME f_manipula_rendi.
                
                                  NEXT-PROMPT aux_tpdrend2 
                                              WITH FRAME f_manipula_rendi.
                           
                               END.
                
                         END.
                      ELSE 
                        APPLY LASTKEY.
                
                   END.

                   LEAVE.
                
                END.
                
                IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                   DO: 
                      HIDE FRAME f_manipula_rendi NO-PAUSE.
                
                      RETURN.
                
                   END.

                IF aux_tpdrend2 = 6 THEN
                   DO:
                      DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                   
                         ASSIGN aux_dsjusre2[1]:HIDDEN 
                                         IN FRAME f_manipula_rendi = NO
                                aux_dsjusre2[2]:HIDDEN 
                                         IN FRAME f_manipula_rendi = NO
                                aux_dsjusre2[3]:HIDDEN 
                                         IN FRAME f_manipula_rendi = NO.
                      
                         UPDATE aux_dsjusre2[1] 
                                aux_dsjusre2[2] 
                                aux_dsjusre2[3] 
                                WITH FRAME f_manipula_rendi.
                   
                         LEAVE.
                      
                      END.
                      
                      IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
                         DO: 
                            HIDE FRAME f_manipula_rendi NO-PAUSE.
                      
                            RETURN.
                      
                         END. 
                
                   END.

            END.
         ELSE
           ASSIGN aux_tpdrend2 = tt-rendimentos.tpdrendi
                  aux_vldrend2 = tt-rendimentos.vldrendi.

         IF NOT TEMP-TABLE tt-rendimentos:HAS-RECORDS THEN
            ASSIGN aux_tpdrendi = 0
                   aux_vldrendi = 0.
         ELSE
            ASSIGN aux_tpdrendi = tt-rendimentos.tpdrendi
                   aux_vldrendi = tt-rendimentos.vldrendi.

         
         RUN Confirma.
         
         ASSIGN tel_dsjsure2 =  aux_dsjusre2[1] + " " +
                                aux_dsjusre2[2] + " " +
                                aux_dsjusre2[3]
                tel_dsjusren =  aux_dsjusren[1] + " " +
                                aux_dsjusren[2] + " " +
                                aux_dsjusren[3].


         IF aux_confirma = "S" THEN
            DO:   
               RUN Grava_Rendimentos(INPUT glb_cdcooper,    
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
                                     INPUT aux_tpdrendi,
                                     INPUT aux_vldrendi,
                                     INPUT aux_tpdrend2,   
                                     INPUT aux_vldrend2,
                                     INPUT tel_dsjusren,
                                     INPUT tel_dsjsure2).

                
               IF RETURN-VALUE <> "OK" THEN
                  DO: 
                     HIDE FRAME f_manipula_rendi NO-PAUSE.
                     RETURN.
                  
                  END.

               IF  NOT VALID-HANDLE(h-b1wgen0075) THEN
                   RUN sistema/generico/procedures/b1wgen0075.p 
                                   PERSISTENT SET h-b1wgen0075.
            
               RUN Busca_Rendimentos IN h-b1wgen0075(INPUT glb_cdcooper,
                                                     INPUT 0,
                                                     INPUT 0,
                                                     INPUT aux_nrdrowid,
                                                     INPUT 1,
                                                     INPUT 9999999,
                                                     INPUT TRUE,
                                                     OUTPUT aux_totregis,
                                                     OUTPUT aux_flgexist,
                                                     OUTPUT TABLE tt-rendimentos,
                                                     OUTPUT TABLE tt-erro).
            
               IF  VALID-HANDLE(h-b1wgen0075) THEN
                   DELETE OBJECT h-b1wgen0075.
               
               IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
                   DO:
                      FIND FIRST tt-erro NO-ERROR.
                 
                      IF  AVAILABLE tt-erro THEN
                          DO: 
                             MESSAGE tt-erro.dscritic.
                             PAUSE(2) NO-MESSAGE.
                             HIDE MESSAGE NO-PAUSE.
                             NEXT.
            
                          END.
            
                   END.
            
               IF (aux_tpdrend2 <> 6  AND 
                   aux_tpdrendi = 6)  OR
                  (aux_tpdrend2 = 6   AND
                   aux_tpdrendi = 6)  OR 
                  (aux_tpdrendi <> 6  AND
                   aux_tpdrend2 = 6)  THEN
                  DO: 
                     ASSIGN aux_dscjusti = aux_dsjusre2[1] + " " +
                                           aux_dsjusre2[2] + " " +
                                           aux_dsjusre2[3].

                     ASSIGN aux_dsjusren[1] = TRIM(SUBSTR(aux_dscjusti,1,60))         
                            aux_dsjusren[2] = TRIM(SUBSTR(aux_dscjusti,62,60))  
                            aux_dsjusren[3] = TRIM(SUBSTR(aux_dscjusti,123,40)).
                     
                     DISP aux_dsjusren[1]
                          aux_dsjusren[2]
                          aux_dsjusren[3]
                          WITH FRAME f_justif.
                 
                  END.         

               IF aux_flgexist = FALSE THEN
                  MESSAGE "Nenhum rendimento encontrado.".

               OPEN QUERY q_tipos_rendim 
                               FOR EACH tt-rendimentos 
                                        NO-LOCK BY tt-rendimentos.tpdrendi.

            END.

      END.
   ELSE
     RETURN.
            
    HIDE FRAME f_manipula_rendi NO-PAUSE.

   /* Somente para marcar a opcao escolhida */
   CHOOSE FIELD aux_dsdopcao[reg_contador] PAUSE 0 WITH FRAME f_justif.

END.


DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

   ASSIGN glb_cddopcao = "C".

   IF  NOT VALID-HANDLE(h-b1wgen0075) THEN
       RUN sistema/generico/procedures/b1wgen0075.p 
           PERSISTENT SET h-b1wgen0075.

   IF  NOT VALID-HANDLE(h-b1wgen0059) THEN
       RUN sistema/generico/procedures/b1wgen0059.p 
           PERSISTENT SET h-b1wgen0059.

   IF  NOT VALID-HANDLE(h-b1wgen0060) THEN
       RUN sistema/generico/procedures/b1wgen0060.p 
           PERSISTENT SET h-b1wgen0060.

   RUN Busca_Dados.

   IF  RETURN-VALUE <> "OK" THEN
       LEAVE.

   RUN Atualiza_Tela.

   IF  RETURN-VALUE <> "OK" THEN
       LEAVE.
          
   DISPLAY tel_tpcttrab      tel_dsctrtab      tel_cdempres    
           tel_nmresemp      tel_nmextemp      tel_nrcpfemp  
           tel_dspolexp
           tel_dsproftl      tel_cdnvlcgo      tel_rsnvlcgo
           tel_dtadmemp      tel_vlsalari      tel_cdturnos
           tel_cdnatopc      tel_rsnatocp      tel_cdocpttl
           tel_rsocupa       tel_totrendi      tel_cepedct1      
           tel_endrect1      tel_nrendcom      tel_complcom      
           tel_bairoct1      tel_cidadct1      tel_ufresct1      
           tel_cxpotct1      reg_dsdopcao[1]   reg_dsdopcao[2]
           tel_nrcadast      tel_dsturnos
           WITH FRAME f_comercial.
           
   CHOOSE FIELD reg_dsdopcao[1] reg_dsdopcao[2] WITH FRAME f_comercial.
   
   IF FRAME-VALUE = reg_dsdopcao[1] THEN
      DO ON ENDKEY UNDO, NEXT:
          
         IF  aux_msgconta <> "" THEN
               DO:
                  MESSAGE aux_msgconta. 
                  NEXT.
               END.

         ASSIGN glb_nmrotina = "COMERCIAL"
                glb_cddopcao = "A".
                 
         { includes/acesso.i }
         
         DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

            UPDATE tel_cdnatopc    tel_cdocpttl    tel_tpcttrab
                   tel_cdempres    tel_nmextemp    tel_nrcpfemp
                   tel_dsproftl    tel_cdnvlcgo    tel_nrcadast 
                   tel_cepedct1    tel_nrendcom    tel_complcom    
                   tel_cxpotct1    tel_cdturnos
                   tel_dtadmemp    tel_vlsalari    
                   WITH FRAME f_comercial
                   
            EDITING:
                
               READKEY.

               HIDE MESSAGE NO-PAUSE.
                
               IF LASTKEY = KEYCODE("F7")  THEN
                  DO:
                     IF FRAME-FIELD = "tel_cdnatopc" THEN
                        DO:
                           ASSIGN shr_cdnatocp = tel_cdnatopc.
                           
                           RUN fontes/zoom_natureza_ocupacao.p.

                           IF shr_cdnatocp <> 0 THEN
                              DO:
                                 ASSIGN tel_cdnatopc = shr_cdnatocp
                                        tel_rsnatocp = shr_rsnatocp.
                                        
                                 DISPLAY tel_cdnatopc 
                                         tel_rsnatocp
                                         WITH FRAME f_comercial.
                                         
                                 NEXT-PROMPT tel_cdnatopc
                                             WITH FRAME f_comercial.
                              END.

                        END.
                     ELSE
                     IF FRAME-FIELD = "tel_cdocpttl" THEN
                        DO:
                           OCUPACAO_1:
                           DO WHILE TRUE ON ENDKEY UNDO OCUPACAO_1,LEAVE: 

                            ASSIGN shr_ocupacao_pesq = "". 

                            UPDATE shr_ocupacao_pesq
                                   WITH FRAME f_pesq_ocupacao.

                            HIDE FRAME f_pesq_ocupacao.

                            ASSIGN shr_cdocpttl = tel_cdocpttl.

                            RUN fontes/zoom_ocupacao.p.

                            IF shr_cdocpttl <> 0 THEN
                               DO:
                                  ASSIGN tel_cdocpttl = shr_cdocpttl
                                         tel_rsocupa  = shr_rsdocupa.

                                  DISPLAY tel_cdocpttl 
                                          tel_rsocupa
                                          WITH FRAME f_comercial.

                                  NEXT-PROMPT tel_cdocpttl
                                              WITH FRAME f_comercial.

                               END.

                            LEAVE.   

                           END.

                        END.
                     ELSE
                     IF FRAME-FIELD = "tel_cdnvlcgo" THEN
                        DO:
                            ASSIGN shr_cdnvlcgo = tel_cdnvlcgo.

                            RUN fontes/zoom_nivel_cargo.p.

                            IF shr_cdnvlcgo <> 0 THEN
                               DO:
                                  ASSIGN tel_cdnvlcgo = shr_cdnvlcgo
                                         tel_rsnvlcgo = shr_rsnvlcgo.

                                  DISPLAY tel_cdnvlcgo 
                                          tel_rsnvlcgo
                                          WITH FRAME f_comercial.

                                  NEXT-PROMPT tel_cdnvlcgo
                                              WITH FRAME f_comercial.

                               END.

                        END.
                     ELSE
                     IF FRAME-FIELD = "tel_cdempres" THEN
                        DO:
                            ASSIGN shr_cdempres = tel_cdempres.

                            RUN fontes/zoom_empresa.p.

                            IF shr_cdempres <> 0 THEN
                               DO:
                                   ASSIGN tel_cdempres = shr_cdempres
                                          tel_nmresemp = shr_nmresemp.
                                          
                                   DISPLAY tel_cdempres 
                                           tel_nmresemp
                                           WITH FRAME f_comercial.
                               
                                   NEXT-PROMPT tel_cdempres
                                               WITH FRAME f_comercial.

                               END.

                        END.
                     ELSE
                     IF  FRAME-FIELD = "tel_cepedct1"  THEN
                         DO:
                             /* Inclusao de CEP integrado. (André - DB1) */
                             RUN fontes/zoom_endereco.p 
                                                   (INPUT 0,
                                                   OUTPUT TABLE tt-endereco).
                
                             FIND FIRST tt-endereco NO-LOCK NO-ERROR.
                           
                             IF  AVAIL tt-endereco THEN
                                 DO:
                                     ASSIGN tel_cepedct1 = tt-endereco.nrcepend 
                                            tel_endrect1 = tt-endereco.dsendere 
                                            tel_bairoct1 = tt-endereco.nmbairro 
                                            tel_cidadct1 = tt-endereco.nmcidade 
                                            tel_ufresct1 = tt-endereco.cdufende.

                                 END.
                                                       
                             DISPLAY tel_cepedct1    
                                     tel_endrect1
                                     tel_bairoct1
                                     tel_cidadct1
                                     tel_ufresct1
                                     WITH FRAME f_comercial.
                           
                              IF  KEYFUNCTION(LASTKEY) <> "END-ERROR"  THEN
                                  NEXT-PROMPT tel_nrendcom 
                                              WITH FRAME f_comercial.

                         END.
                     ELSE
                     IF  FRAME-FIELD = "tel_cdturnos" THEN
                         DO:
                             RUN zoom_turnos(OUTPUT tel_cdturnos,
                                             OUTPUT tel_dsturnos).
                                                      
                             DISPLAY tel_cdturnos    
                                     tel_dsturnos
                                     WITH FRAME f_comercial.

                             NEXT-PROMPT tel_cdturnos 
                                         WITH FRAME f_comercial.

                         END.

                  END.
               ELSE 
                  APPLY LASTKEY.

               IF GO-PENDING THEN 
                  DO:
                     RUN Valida_Dados.
    
                     IF  RETURN-VALUE <> "OK" THEN
                         DO:
                            /* se ocorreu erro, posiciona no campo correto */
                            {sistema/generico/includes/foco_campo.i 
                                              &VAR-GERAL=SIM 
                                              &NOME-FRAME="f_comercial"
                                              &NOME-CAMPO=aux_nmdcampo }
                                
                         END.

                  END.

            END. /* fim do EDITING */

            RUN controla_campos(INPUT tel_tpcttrab).

            DISABLE ALL WITH FRAME f_comercial.

            RUN Valida_Dados.

            IF RETURN-VALUE <> "OK" THEN
               NEXT.
                 
            LEAVE.

         END.
          
         IF KEY-FUNCTION(LASTKEY) = "END-ERROR"   THEN
            LEAVE.

         RUN Confirma.

         IF aux_confirma = "S" THEN
            DO:
               RUN Grava_Dados.
               
               IF RETURN-VALUE <> "OK" THEN
                  NEXT.

            END.

      END.
   ELSE
     IF FRAME-VALUE = reg_dsdopcao[2] THEN
        DO ON ENDKEY UNDO, NEXT:

           ASSIGN aux_dsjusren[1] = SUBSTR(tel_dsjusren,1,60)
                  aux_dsjusren[2] = TRIM(SUBSTR(tel_dsjusren,62,60))
                  aux_dsjusren[3] = TRIM(SUBSTR(tel_dsjusren,123,40)).
       
           IF  NOT VALID-HANDLE(h-b1wgen0075) THEN
               RUN sistema/generico/procedures/b1wgen0075.p 
                               PERSISTENT SET h-b1wgen0075.

           RUN Busca_Rendimentos IN h-b1wgen0075(INPUT glb_cdcooper,
                                                 INPUT 0,
                                                 INPUT 0,
                                                 INPUT aux_nrdrowid,
                                                 INPUT 1,
                                                 INPUT 9999999,
                                                 INPUT TRUE,
                                                 OUTPUT aux_totregis,
                                                 OUTPUT aux_flgexist,
                                                 OUTPUT TABLE tt-rendimentos,
                                                 OUTPUT TABLE tt-erro).

           IF  VALID-HANDLE(h-b1wgen0075) THEN
               DELETE OBJECT h-b1wgen0075.
           
           IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
               DO:
                  FIND FIRST tt-erro NO-ERROR.
             
                  IF  AVAILABLE tt-erro THEN
                      DO: 
                         MESSAGE tt-erro.dscritic.

                         PAUSE(2) NO-MESSAGE.

                         HIDE MESSAGE NO-PAUSE.

                         NEXT.

                      END.

               END.
        
           DISP aux_dsjusren[1]  
                aux_dsjusren[2] 
                aux_dsjusren[3] 
                aux_dsdopcao[1]
                aux_dsdopcao[2]
                aux_dsdopcao[3]
                WITH FRAME f_justif.

           CHOOSE FIELD aux_dsdopcao[1] 
                        aux_dsdopcao[2] 
                        aux_dsdopcao[3] 
                        PAUSE 0 WITH FRAME f_justif.

           IF aux_flgexist = FALSE THEN
              MESSAGE "Nenhum rendimento encontrado.".
                  
           OPEN QUERY q_tipos_rendim 
                               FOR EACH tt-rendimentos 
                                        NO-LOCK BY tt-rendimentos.tpdrendi.
       
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

              UPDATE b_tipos_rendim 
                     WITH FRAME f_tipos_rendimento.

              LEAVE.
       
           END.

           CLOSE QUERY q_tipos_rendim.

           IF KEYFUNCTION(LAST-KEY) = "END-ERROR" THEN
              DO:
                 HIDE FRAME f_tipos_rendimento 
                 FRAME f_justif 
                 NO-PAUSE.

                 NEXT.
           
              END.

        END.

   IF KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
      aux_confirma <> "S"                  THEN
      NEXT.
   ELSE
      DO:
         aux_flgsuces = YES.
         LEAVE.

      END.

END.

IF  VALID-HANDLE(h-b1wgen0075) THEN
    DELETE OBJECT h-b1wgen0075.
  
IF  VALID-HANDLE(h-b1wgen0059) THEN
    DELETE OBJECT h-b1wgen0059.

IF  VALID-HANDLE(h-b1wgen0060) THEN
    DELETE OBJECT h-b1wgen0060.

IF aux_flgsuces   THEN
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      MESSAGE "Alteracao efetuada com sucesso!".
      PAUSE 2 NO-MESSAGE.
      HIDE MESSAGE NO-PAUSE.
      LEAVE.

   END.

HIDE FRAME f_comercial NO-PAUSE.
HIDE MESSAGE NO-PAUSE.


PROCEDURE Grava_Rendimentos:

    DEF INPUT PARAM par_cdcooper AS INT                            NO-UNDO.
    DEF INPUT PARAM par_cdagenci AS INT                            NO-UNDO.
    DEF INPUT PARAM par_nrdcaixa AS INT                            NO-UNDO.
    DEF INPUT PARAM par_cdoperad AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_nmdatela AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_idorigem AS INT                            NO-UNDO.
    DEF INPUT PARAM par_nrdconta AS INT                            NO-UNDO.
    DEF INPUT PARAM par_idseqttl AS INT                            NO-UNDO.
    DEF INPUT PARAM par_flgerlog AS LOG                            NO-UNDO.
    DEF INPUT PARAM par_cddopcao AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_dtmvtolt AS DATE                           NO-UNDO.
    DEF INPUT PARAM par_tpdrendi AS INT                            NO-UNDO.
    DEF INPUT PARAM par_vldrendi AS DEC                            NO-UNDO.
    DEF INPUT PARAM par_tpdrend2 AS INT                            NO-UNDO.
    DEF INPUT PARAM par_vldrend2 AS DEC                            NO-UNDO.
    DEF INPUT PARAM par_dsjusren AS CHAR                           NO-UNDO.
    DEF INPUT PARAM par_dsjusre2 AS CHAR                           NO-UNDO.

     
    IF  NOT VALID-HANDLE(h-b1wgen0075) THEN
        RUN sistema/generico/procedures/b1wgen0075.p 
                         PERSISTENT SET h-b1wgen0075.
     
    
    RUN Grava_Rendimentos IN h-b1wgen0075 (INPUT par_cdcooper, 
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
                                           INPUT par_tpdrendi,
                                           INPUT par_vldrendi,
                                           INPUT par_tpdrend2,
                                           INPUT par_vldrend2,
                                           INPUT par_dsjusren,
                                           INPUT par_dsjusre2,
                                           OUTPUT aux_tpatlcad, 
                                           OUTPUT aux_msgatcad, 
                                           OUTPUT aux_chavealt, 
                                           OUTPUT aux_msgrvcad, 
                                           OUTPUT TABLE tt-erro). 

    IF VALID-HANDLE(h-b1wgen0075) THEN
       DELETE OBJECT h-b1wgen0075.

    IF RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
       DO:
          FIND FIRST tt-erro NO-ERROR.

          IF  AVAILABLE tt-erro THEN
              DO: 
                 MESSAGE tt-erro.dscritic.
                 PAUSE(2) NO-MESSAGE.
                 HIDE MESSAGE NO-PAUSE.

              END.

          RETURN "NOK".

       END.

    /* verificar se é necessario registrar o crapalt */
    RUN proc_altcad (INPUT "b1wgen0075.p").
    
    IF aux_msgrvcad <> "" THEN
       MESSAGE aux_msgrvcad.

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".


    RETURN "OK".


END PROCEDURE.


PROCEDURE zoom_tipo_rendimento:
    
    DEF INPUT-OUTPUT PARAM par_tpdrendi AS INTE                   NO-UNDO.
    DEF INPUT-OUTPUT PARAM par_dstipren AS CHAR                   NO-UNDO.
    
    DEF QUERY q_rendim FOR tt-tipo-rendi.
    DEF BROWSE b_rendim QUERY q_rendim
        DISPLAY tt-tipo-rendi.tpdrendi COLUMN-LABEL "Codigo"    FORMAT "zz9"
                tt-tipo-rendi.dsdrendi COLUMN-LABEL "Descricao" FORMAT "x(25)"
                WITH 5 DOWN NO-BOX.
                
    FORM b_rendim HELP "Pressione ENTER para selecionar ou F4 para sair"
         WITH ROW 9 CENTERED TITLE "TIPO DE RENDIMENTO" OVERLAY NO-LABELS 
              FRAME f_rendimento.

    EMPTY TEMP-TABLE tt-tipo-rendi.

    RUN busca-tipo-rendi IN h-b1wgen0059
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT "",
          INPUT 99999,
          INPUT 0,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-tipo-rendi ).
              
    ON RETURN OF b_rendim DO:

       IF  AVAILABLE tt-tipo-rendi THEN
           ASSIGN 
                par_tpdrendi = tt-tipo-rendi.tpdrendi
                par_dstipren = tt-tipo-rendi.dsdrendi.

       APPLY "GO".

    END.
    
    OPEN QUERY q_rendim FOR EACH tt-tipo-rendi NO-LOCK.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE b_rendim WITH FRAME f_rendimento.
       LEAVE.

    END.
    
    HIDE FRAME f_rendimento NO-PAUSE.

       
END PROCEDURE.



PROCEDURE zoom_turnos:
    
    DEF OUTPUT PARAM par_cdturnos LIKE crapttl.cdturnos             NO-UNDO.
    DEF OUTPUT PARAM par_dsturnos AS CHAR                           NO-UNDO.
    
    DEF QUERY q_turnos FOR tt-turnos.
    DEF BROWSE b_turnos QUERY q_turnos
        DISPLAY tt-turnos.cdturnos COLUMN-LABEL "Codigo"      FORMAT "zz9"
                tt-turnos.dsturnos COLUMN-LABEL "Descricao"   FORMAT "x(25)"
                WITH 5 DOWN NO-BOX.
                
    FORM b_turnos HELP "Pressione ENTER para selecionar ou F4 para sair"
         WITH ROW 9 CENTERED TITLE "TURNOS" OVERLAY NO-LABELS 
              FRAME f_turnos.
              
    RUN busca-turnos IN h-b1wgen0059
        ( INPUT glb_cdcooper,
          INPUT 0,
          INPUT "",
          INPUT 99999,
          INPUT 0,
         OUTPUT aux_qtregist,
         OUTPUT TABLE tt-turnos ).

    ON RETURN OF b_turnos DO:

        IF  AVAILABLE tt-turnos THEN
            ASSIGN 
                par_cdturnos = tt-turnos.cdturnos
                par_dsturnos = tt-turnos.dsturnos.

       APPLY "GO".
    END.
    
    /* Valor atual */
    ASSIGN par_cdturnos = tel_cdturnos
           par_dsturnos = tel_dsturnos.

    OPEN QUERY q_turnos FOR EACH tt-turnos NO-LOCK.

    DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
       UPDATE b_turnos WITH FRAME f_turnos.
       LEAVE.
    END.
    
    HIDE FRAME f_turnos NO-PAUSE.

       
END PROCEDURE.



PROCEDURE controla_campos:

    DEF INPUT PARAM par_tpdrendi AS INTEGER                     NO-UNDO.
    
    IF   par_tpdrendi = 3   THEN
         DO:
             ASSIGN tel_cdempres = IF glb_cdcooper = 2 THEN 88 ELSE 81       
                    tel_nmresemp = ""       tel_nmextemp = ""       
                    tel_nrcpfemp = ""       
                    tel_dsproftl = ""       tel_cdnvlcgo = 0
                    tel_rsnvlcgo = ""       tel_cepedct1 = 0
                    tel_endrect1 = ""       tel_nrendcom = 0
                    tel_complcom = ""       tel_bairoct1 = ""
                    tel_cidadct1 = ""       tel_ufresct1 = ""
                    tel_cxpotct1 = 0        tel_cdturnos = 0
                    tel_dtadmemp = ?        tel_vlsalari = 0
                    tel_nrcadast = 0.
                                     
             DISPLAY tel_cdempres    tel_nmresemp    tel_nmextemp
                     tel_nrcpfemp    tel_dsproftl    
                     tel_cdnvlcgo
                     tel_rsnvlcgo    tel_cepedct1    tel_endrect1
                     tel_nrendcom    tel_complcom    tel_bairoct1
                     tel_cidadct1    tel_ufresct1    tel_cxpotct1
                     tel_cdturnos    tel_dtadmemp    tel_vlsalari
                     tel_nrcadast
                     WITH FRAME f_comercial.

             DISABLE tel_cdempres    tel_nmresemp    tel_nmextemp
                     tel_nrcpfemp    tel_dsproftl   
                     tel_cdnvlcgo
                     tel_rsnvlcgo    tel_cepedct1    tel_complcom   
                     tel_nrendcom    tel_cxpotct1
                     tel_cdturnos    tel_dtadmemp    tel_vlsalari
                     tel_nrcadast
                     WITH FRAME f_comercial.
                     
             NEXT-PROMPT tel_vlsalari WITH FRAME f_comercial.
         END.
    ELSE
         DO:
             ENABLE tel_cdempres    tel_nmextemp    tel_nrcpfemp
                    tel_dsproftl    tel_cdnvlcgo    
                    tel_nrcadast
                    tel_cepedct1    tel_nrendcom    tel_complcom
                    tel_cxpotct1    tel_cdturnos
                    tel_dtadmemp    tel_vlsalari    
                    WITH FRAME f_comercial.
                    
             NEXT-PROMPT tel_cdempres WITH FRAME f_comercial.            
         END.
            

END PROCEDURE.



PROCEDURE Busca_Dados:

    RUN Busca_Dados IN h-b1wgen0075
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
          INPUT tel_cdempres,
          INPUT tel_cdnatopc,
          INPUT tel_cdocpttl,
          INPUT tel_tpcttrab,
          INPUT "",
          INPUT tel_dsproftl,
          INPUT tel_cdnvlcgo,
          INPUT tel_cdturnos,
          INPUT tel_dtadmemp,
          INPUT tel_vlsalari,
          INPUT tel_nrcadast,
          INPUT tel_tpdrendi,
          INPUT tel_vldrendi,
          INPUT tel_tpdrend2,
          INPUT tel_vldrend2,
          INPUT tel_tpdrend3,
          INPUT tel_vldrend3,
          INPUT tel_tpdrend4,
          INPUT tel_vldrend4,
          INPUT tel_inpolexp,
         OUTPUT aux_msgconta,
         OUTPUT TABLE tt-comercial,
         OUTPUT TABLE tt-erro ) .

    IF  RETURN-VALUE <> "OK" OR TEMP-TABLE tt-erro:HAS-RECORDS THEN
        DO:
           FIND FIRST tt-erro NO-ERROR.

           IF  AVAILABLE tt-erro THEN
               MESSAGE tt-erro.dscritic.

           RETURN "NOK".
        END.

    RETURN "OK".

END.



PROCEDURE Valida_Dados:

    DO WITH FRAME f_comercial:
        ASSIGN 
            INPUT tel_cdnatopc
            INPUT tel_cdocpttl
            INPUT tel_tpcttrab
            INPUT tel_cdempres
            INPUT tel_nmextemp
            INPUT tel_nrcpfemp
            INPUT tel_dsproftl
            INPUT tel_cdnvlcgo
            INPUT tel_nrcadast
            INPUT tel_ufresct1
            INPUT tel_cdturnos
            INPUT tel_dtadmemp
            INPUT tel_vlsalari
            INPUT tel_cepedct1
            INPUT tel_endrect1.
    END.

    ASSIGN aux_nmdcampo = "".
    
    RUN Valida_Dados IN h-b1wgen0075
        ( INPUT glb_cdcooper, 
          INPUT 0,            
          INPUT 0,            
          INPUT glb_cdoperad, 
          INPUT glb_nmdatela, 
          INPUT 1,            
          INPUT tel_nrdconta, 
          INPUT tel_idseqttl, 
          INPUT YES,
          INPUT glb_dtmvtolt,
          INPUT glb_cddopcao,
          INPUT tel_cdnatopc,
          INPUT tel_cdocpttl,
          INPUT tel_tpcttrab,
          INPUT tel_cdempres,
          INPUT tel_nmextemp,
          INPUT tel_nrcpfemp,
          INPUT tel_dsproftl,
          INPUT tel_cdnvlcgo,
          INPUT tel_nrcadast,
          INPUT tel_ufresct1,
          INPUT tel_cdturnos,
          INPUT tel_dtadmemp,
          INPUT tel_vlsalari,
          INPUT tel_tpdrendi,
          INPUT tel_vldrendi,
          INPUT tel_tpdrend2,
          INPUT tel_vldrend2,
          INPUT tel_tpdrend3,
          INPUT tel_vldrend3,
          INPUT tel_tpdrend4,
          INPUT tel_vldrend4,
          INPUT tel_cepedct1,
          INPUT tel_endrect1,
          INPUT tel_inpolexp,
         OUTPUT aux_nmdcampo,
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



PROCEDURE Atualiza_Tela:

    FIND FIRST tt-comercial NO-ERROR.

    IF  AVAILABLE tt-comercial THEN 
        DO:
            ASSIGN
                aux_nrdrowid = tt-comercial.nrdrowid
                tel_cdnatopc = tt-comercial.cdnatopc
                tel_cdocpttl = tt-comercial.cdocpttl
                tel_tpcttrab = tt-comercial.tpcttrab
                tel_cdempres = tt-comercial.cdempres
                tel_nrcpfemp = tt-comercial.nrcpfemp
                tel_nmresemp = tt-comercial.nmresemp
                tel_nmextemp = tt-comercial.nmextemp
                tel_dsproftl = tt-comercial.dsproftl
                tel_cdnvlcgo = tt-comercial.cdnvlcgo
                tel_nrcadast = tt-comercial.nrcadast
                tel_dtadmemp = tt-comercial.dtadmemp
                tel_vlsalari = tt-comercial.vlsalari
                tel_cdturnos = tt-comercial.cdturnos
                tel_rsnatocp = tt-comercial.rsnatocp
                tel_rsocupa  = tt-comercial.rsocupa 
                tel_dsctrtab = tt-comercial.dsctrtab
                tel_rsnvlcgo = tt-comercial.rsnvlcgo
                tel_dsturnos = tt-comercial.dsturnos
                tel_cepedct1 = tt-comercial.cepedct1
                tel_endrect1 = tt-comercial.endrect1
                tel_nrendcom = tt-comercial.nrendcom
                tel_complcom = tt-comercial.complcom
                tel_bairoct1 = tt-comercial.bairoct1
                tel_cidadct1 = tt-comercial.cidadct1
                tel_ufresct1 = tt-comercial.ufresct1
                tel_cxpotct1 = tt-comercial.cxpotct1
                tel_tpdrendi = tt-comercial.tpdrendi[1]
                tel_dstipren = tt-comercial.dsdrendi[1]
                tel_vldrendi = tt-comercial.vldrendi[1]
                tel_tpdrend2 = tt-comercial.tpdrendi[2]
                tel_dstipre2 = tt-comercial.dsdrendi[2]
                tel_vldrend2 = tt-comercial.vldrendi[2]
                tel_tpdrend3 = tt-comercial.tpdrendi[3]
                tel_dstipre3 = tt-comercial.dsdrendi[3]
                tel_vldrend3 = tt-comercial.vldrendi[3]
                tel_tpdrend4 = tt-comercial.tpdrendi[4]
                tel_dstipre4 = tt-comercial.dsdrendi[4]
                tel_vldrend4 = tt-comercial.vldrendi[4]
                tel_dsjusren = tt-comercial.dsjusren
                tel_totrendi = tel_vldrendi + 
                               tel_vldrend2 +
                               tel_vldrend3 +
                               tel_vldrend4
                tel_inpolexp = tt-comercial.inpolexp
                tel_dspolexp = tel_lipolexp[tt-comercial.inpolexp + 1].
        END.
    ELSE
        ASSIGN
            tel_cdnatopc = 0
            tel_cdocpttl = 0
            tel_tpcttrab = 0
            tel_cdempres = 0
            tel_nmresemp = ""
            tel_nmextemp = ""
            tel_nrcpfemp = ""
            tel_dsproftl = ""
            tel_cdnvlcgo = 0
            tel_nrcadast = 0
            tel_dtadmemp = ?
            tel_vlsalari = 0
            tel_cdturnos = 0
            tel_rsnatocp = ""
            tel_rsocupa  = ""
            tel_dsctrtab = ""
            tel_rsnvlcgo = ""
            tel_dsturnos = ""
            tel_cepedct1 = 0
            tel_endrect1 = ""
            tel_nrendcom = 0
            tel_complcom = ""
            tel_bairoct1 = ""
            tel_cidadct1 = ""
            tel_ufresct1 = ""
            tel_cxpotct1 = 0
            tel_tpdrendi = 0
            tel_dstipren = ""
            tel_vldrendi = 0
            tel_tpdrend2 = 0 
            tel_dstipre2 = ""
            tel_vldrend2 = 0 
            tel_tpdrend3 = 0 
            tel_dstipre3 = ""
            tel_vldrend3 = 0 
            tel_tpdrend4 = 0 
            tel_dstipre4 = ""
            tel_vldrend4 = 0
            tel_dsjusren = "".

    RETURN "OK".

END.



PROCEDURE Grava_Dados:

    IF  VALID-HANDLE(h-b1wgen0075) THEN
        DELETE OBJECT h-b1wgen0075.

    IF  NOT VALID-HANDLE(h-b1wgen0075) THEN
        RUN sistema/generico/procedures/b1wgen0075.p 
            PERSISTENT SET h-b1wgen0075.

    RUN Grava_Dados IN h-b1wgen0075
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
          INPUT aux_nrdrowid,
          INPUT tel_cdnatopc,
          INPUT tel_cdocpttl,
          INPUT tel_tpcttrab,
          INPUT tel_cdempres,
          INPUT tel_nmextemp,
          INPUT DEC(REPLACE(REPLACE(tel_nrcpfemp,".",""),"/","")),
          INPUT tel_dsproftl,
          INPUT tel_cdnvlcgo,
          INPUT tel_nrcadast,
          INPUT tel_ufresct1,
          INPUT tel_endrect1,
          INPUT tel_bairoct1,
          INPUT tel_cidadct1,
          INPUT tel_complcom,
          INPUT tel_cepedct1,
          INPUT tel_cxpotct1,
          INPUT tel_cdturnos,
          INPUT tel_dtadmemp,
          INPUT tel_vlsalari,
          INPUT "",
          INPUT tel_nrendcom,
          INPUT tel_tpdrendi,
          INPUT tel_vldrendi,
          INPUT tel_tpdrend2,
          INPUT tel_tpdrend3,
          INPUT tel_tpdrend4,
          INPUT tel_vldrend2,
          INPUT tel_vldrend3,
          INPUT tel_vldrend4,
          INPUT tel_inpolexp,
         OUTPUT aux_tpatlcad,
         OUTPUT aux_msgatcad,
         OUTPUT aux_chavealt,
         OUTPUT aux_msgrvcad,
         OUTPUT aux_cotcance,
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
    /* verificar se é necessario registrar o crapalt */
    RUN proc_altcad (INPUT "b1wgen0075.p").

    DELETE OBJECT h-b1wgen0075.
    
    IF aux_msgrvcad <> "" THEN
       MESSAGE aux_msgrvcad.
    
    IF aux_cotcance <> "" THEN
        MESSAGE aux_cotcance VIEW-AS ALERT-BOX.

    IF  RETURN-VALUE <> "OK" THEN
        RETURN "NOK".

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

    IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
         aux_confirma <> "S"                  THEN
         DO:
             glb_cdcritic = 79.
             RUN fontes/critic.p.
             BELL.
             MESSAGE glb_dscritic.
             glb_cdcritic = 0.
             PAUSE 2 NO-MESSAGE.
             HIDE MESSAGE NO-PAUSE.
             NEXT-PROMPT tel_cdnatopc WITH FRAME f_comercial.
             NEXT.
         END.


END PROCEDURE.



PROCEDURE Limpa_Endereco:

    ASSIGN tel_cepedct1 = 0  
           tel_endrect1 = ""  
           tel_bairoct1 = "" 
           tel_cidadct1 = ""  
           tel_ufresct1 = ""
           tel_nrendcom = 0
           tel_complcom = ""
           tel_cxpotct1 = 0.

    DISPLAY tel_cepedct1
            tel_endrect1
            tel_bairoct1
            tel_cidadct1
            tel_ufresct1
            tel_nrendcom
            tel_complcom 
            tel_cxpotct1 WITH FRAME f_comercial.

END PROCEDURE.
/*...........................................................................*/



