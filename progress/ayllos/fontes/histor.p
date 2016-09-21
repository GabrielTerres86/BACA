/* .............................................................................
   
   Programa: Fontes/histor.p
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Janeiro/97.                       Ultima atualizacao: 13/08/2013

   Dados referentes ao programa:
   Frequencia: Diario (on-line)
   Objetivo  : Mostrar a tela HISTOR - Consulta de historicos do sistema.

   Alteracoes: 07/06/1999 - Nao mostrar aliquota da CPMF do historico
                            (Deborah).
                            
               10/03/2000 - Mostrar conta a credito e debito contab. (Odair).
               
               07/08/2001 - Montar BROWSE e acrescentar opcoes de :
                            Incluir, Alterar e Consultar. (Eduardo).

               16/09/2002 - Solicitar o indicador de DEBITO/CREDITO (Edson).

               30/03/2004 - Incluido o tipo de contabilizacao por caixa 6
                            (Edson).

               03/06/2004 - Incluido campo Tipo de Lote para Filtrar Pesquisa
                            (Mirtes - Tarefa 722).
               
               16/08/2004 - Incluido tipo de lote 28(COBAN)(Mirtes).
               
               22/09/2004 - Incluido tipo de lote 29(CI) (Mirtes).

               04/07/2005 - Alimentado campo cdcooper da tabela craphis (Diego).

               18/07/2005 - Incluido tplotmov 30(Mirtes)

               31/10/2005 - Criadas opcoes "B" e "O" para listagem de
                            historicos (Diego).

               21/11/2005 - Permitir uso da opcao "B" e "O" (Magui).
              
               30/11/2005 - Colocar em ordem C/D (Magui).

               10/01/2006 - Permitir tipo de lote 31 - INSS(Mirtes).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
              
               11/05/2006 - Incluidos campos ingercre e ingerdeb para as
                            opcoes  "I" e "A" (Diego).

               15/12/2006 - Incluido historico 32(Mirtes)

               22/03/2007 - Permitir uso da tela pelo operador 997 (David).
               
               01/06/2007 - Acerto no display Tipo do Lote do Movimento (Ze).
               
               28/11/2007 - Valor de tarifas diferenciadas p/ ayllos,
                            cash, internet, caixa-online
                          - Bloqueado a Opcao "I" (Guilherme).

               23/01/2008 - Atualizar tarifas na tabelas gnconve (David).

               11/02/2008 - Acertado as "," (virgulas) no CAN-DO para nao
                            desprezar nenhum parametro (Elton);
                          - Usar o campo cdcooper na crapthi e nao alimentar o
                            crampo craphis.vltarifa porque os valores estao na
                            "crapthi" (Evandro).
                            
               20/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "find e for each" da tabela
                            CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               24/04/2009 - Acertar logica de FOR EACH que utiliza OR (David).    
                      
               25/05/2009 - Alteracao CDOPERAD (Kbase).
               
               12/04/2010 - Criar campo "Solicitar Senha" (Gabriel).
               
               04/06/2010 - Incluido novo parametro referente a tarifa TAA na 
                            chamada do programa fontes/histor_g.p (Elton).
                            
               16/02/2010 - Incluidos 2 novos campos "Codigo do Produto" e 
                            "Codigo do agrupamento" nas opcoes (Vitor).   
                            
               08/04/2011 - Implementada a opcao de replicacao de hitoricos
                            para todas as cooperativas cadastradas. (Sergio)
                            
               15/04/2011 - Tratado 'END-ERROR' para o FRAME f_histor_2, após
                            a visualizacao do FRAME f_histor_2_1 e colocado o
                            FRAME f_histor_2_1 como HIDE após sua visualizacao.
                            Gerado LOG para a opcao 'X'. (Fabricio)
                            
               14/06/2011 - Desbloqueado a opcao 'I'. Um novo historico sera
                            incluido a partir de um existente. (Fabricio)
                            
               19/08/2011 - Gerado log da opcao "A" (Adriano).          
               
               22/12/2011 - Nao permitir o historico 1030 na opcao "O"
                            (Gabriel)                                                        
                            
               01/10/2012 - Inclusao do campo dsextrat nas opcoes A,I,X (Lucas R)
               
               13/08/2013 - Nova forma de chamar as agências, alterado para
                          "Posto de Atendimento" (PA). (André Santos - SUPERO)
                          
..............................................................................*/

{ includes/var_online.i }
{ includes/var_cpmf.i } 

{ includes/gg0000.i }

DEF STREAM str_1. 

DEF        VAR rel_nmrelato AS CHAR                                  NO-UNDO.
DEF        VAR rel_nmrescop AS CHAR                                  NO-UNDO.

DEF        VAR tel_cdhstctb LIKE craphis.cdhstctb                    NO-UNDO.
DEF        VAR tel_dsexthst LIKE craphis.dsexthst                    NO-UNDO.
DEF        VAR tel_dshistor LIKE craphis.dshistor                    NO-UNDO.
DEF        VAR tel_inautori LIKE craphis.inautori                    NO-UNDO.
DEF        VAR tel_inavisar LIKE craphis.inavisar                    NO-UNDO. 
DEF        VAR tel_inclasse LIKE craphis.inclasse                    NO-UNDO.
DEF        VAR tel_incremes LIKE craphis.incremes                    NO-UNDO.
DEF        VAR tel_indcompl LIKE craphis.indcompl                    NO-UNDO.
DEF        VAR tel_indebcre LIKE craphis.indebcre                    NO-UNDO.
DEF        VAR tel_indebcta LIKE craphis.indebcta                    NO-UNDO.
DEF        VAR tel_indebfol LIKE craphis.indebfol                    NO-UNDO.
DEF        VAR tel_indoipmf LIKE craphis.indoipmf                    NO-UNDO.
DEF        VAR tel_inhistor LIKE craphis.inhistor                    NO-UNDO.
DEF        VAR tel_nmestrut LIKE craphis.nmestrut                    NO-UNDO.
DEF        VAR tel_nrctacrd LIKE craphis.nrctacrd                    NO-UNDO.
DEF        VAR tel_nrctatrc LIKE craphis.nrctatrc                    NO-UNDO.
DEF        VAR tel_nrctadeb LIKE craphis.nrctadeb                    NO-UNDO.
DEF        VAR tel_nrctatrd LIKE craphis.nrctatrd                    NO-UNDO.
DEF        VAR tel_tpctbccu LIKE craphis.tpctbccu                    NO-UNDO.
DEF        VAR tel_tplotmov LIKE craphis.tplotmov                    NO-UNDO.
DEF        VAR tel_tpctbcxa LIKE craphis.tpctbcxa                    NO-UNDO.
DEF        VAR tel_txdoipmf LIKE craphis.txdoipmf                    NO-UNDO.
DEF        VAR tel_ingercre AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR tel_ingerdeb AS INT     FORMAT "9"                    NO-UNDO.
DEF        VAR tel_flgsenha AS LOGI    FORMAT "Sim/Nao"              NO-UNDO.
DEF        VAR tel_dsextrat LIKE craphis.dsextrat                    NO-UNDO. 

DEF        VAR tel_cdprodut LIKE craphis.cdprodut                    NO-UNDO.
DEF        VAR tel_cdagrupa LIKE craphis.cdagrupa                    NO-UNDO.
DEF        VAR aux_dsprodut AS CHAR  FORMAT "x(40)"                  NO-UNDO.
DEF        VAR aux_dsagrupa AS CHAR  FORMAT "x(40)"                  NO-UNDO.

DEF        VAR tel_cdhistor AS INT     FORMAT "z,zz9"                NO-UNDO.
DEF        VAR tel_cdhistor_novo AS INT FORMAT "z,zz9"               NO-UNDO.
DEF        VAR tel_flgclass AS LOGICAL FORMAT "Codigo/Descricao"     NO-UNDO.
DEF        VAR tel_cddopcao AS CHAR    FORMAT "!"                    NO-UNDO.
DEF        VAR aux_cdhistor AS INT                                   NO-UNDO.
DEF        VAR aux_contador AS INT     FORMAT "99"                   NO-UNDO.
DEF        VAR aux_confirma AS CHAR    FORMAT "!"                    NO-UNDO.

/* Variaveis impressao */
DEF        VAR aux_nmendter AS CHAR    FORMAT "x(20)"                NO-UNDO.
DEF        VAR aux_nmarqimp AS CHAR                                  NO-UNDO.
DEF        VAR par_flgrodar AS LOGICAL                               NO-UNDO. 
DEF        VAR aux_flgescra AS LOGICAL                               NO-UNDO.
DEF        VAR aux_dscomand AS CHAR                                  NO-UNDO.
DEF        VAR par_flgfirst AS LOGICAL      INIT TRUE                NO-UNDO.
DEF        VAR tel_dsimprim AS CHAR    FORMAT "x(8)" INIT "Imprimir" NO-UNDO.
DEF        VAR tel_dscancel AS CHAR    FORMAT "x(8)" INIT "Cancelar" NO-UNDO.
DEF        VAR par_flgcance AS LOGICAL                               NO-UNDO. 

DEF        VAR tel_tplotmov_pesq LIKE craphis.tplotmov               NO-UNDO.

DEF        VAR aux_vltarayl AS DECI FORMAT "zzz,zzz,zz9.99"          NO-UNDO.
DEF        VAR aux_vltarint AS DECI FORMAT "zzz,zzz,zz9.99"          NO-UNDO.
DEF        VAR aux_vltarcxo AS DECI FORMAT "zzz,zzz,zz9.99"          NO-UNDO.
DEF        VAR aux_vltarcsh AS DECI FORMAT "zzz,zzz,zz9.99"          NO-UNDO.


DEF        VAR log_vltarayl LIKE aux_vltarayl                        NO-UNDO. 
DEF        VAR log_vltarcxo LIKE aux_vltarcxo                        NO-UNDO.
DEF        VAR log_vltarint LIKE aux_vltarint                        NO-UNDO.
DEF        VAR log_vltarcsh LIKE aux_vltarcsh                        NO-UNDO.
DEF        VAR log_cdhstctb LIKE tel_cdhstctb                        NO-UNDO.
DEF        VAR log_dsexthst LIKE tel_dsexthst                        NO-UNDO.
DEF        VAR log_dshistor LIKE tel_dshistor                        NO-UNDO.
DEF        VAR log_inautori LIKE tel_inautori                        NO-UNDO.
DEF        VAR log_inavisar LIKE tel_inavisar                        NO-UNDO.
DEF        VAR log_inclasse LIKE tel_inclasse                        NO-UNDO.
DEF        VAR log_incremes LIKE tel_incremes                        NO-UNDO.
DEF        VAR log_indcompl LIKE tel_indcompl                        NO-UNDO.
DEF        VAR log_indebcre LIKE tel_indebcre                        NO-UNDO.
DEF        VAR log_indebcta LIKE tel_indebcta                        NO-UNDO.
DEF        VAR log_indebfol LIKE tel_indebfol                        NO-UNDO.
DEF        VAR log_indoipmf LIKE tel_indoipmf                        NO-UNDO.
DEF        VAR log_inhistor LIKE tel_inhistor                        NO-UNDO.
DEF        VAR log_nmestrut LIKE tel_nmestrut                        NO-UNDO.
DEF        VAR log_nrctacrd LIKE tel_nrctacrd                        NO-UNDO.
DEF        VAR log_nrctatrc LIKE tel_nrctatrc                        NO-UNDO.
DEF        VAR log_nrctadeb LIKE tel_nrctadeb                        NO-UNDO.
DEF        VAR log_nrctatrd LIKE tel_nrctatrd                        NO-UNDO.
DEF        VAR log_tpctbccu LIKE tel_tpctbccu                        NO-UNDO.
DEF        VAR log_tplotmov LIKE tel_tplotmov                        NO-UNDO.
DEF        VAR log_tpctbcxa LIKE tel_tpctbcxa                        NO-UNDO.
DEF        VAR log_txdoipmf LIKE tel_txdoipmf                        NO-UNDO.
DEF        VAR log_ingercre LIKE tel_ingercre                        NO-UNDO.
DEF        VAR log_ingerdeb LIKE tel_ingerdeb                        NO-UNDO.
DEF        VAR log_flgsenha LIKE tel_flgsenha                        NO-UNDO.
DEF        VAR log_cdprodut LIKE tel_cdprodut                        NO-UNDO.
DEF        VAR log_cdagrupa LIKE tel_cdagrupa                        NO-UNDO.
DEF        VAR log_dsextrat LIKE tel_dsextrat                        NO-UNDO.

/* utilizada para replicar o historico para as cooperativas */
DEFINE TEMP-TABLE tt-crapthi NO-UNDO 
    field cdcooper like crapthi.cdcooper
    field cdhistor like crapthi.cdhistor
    field dsorigem like crapthi.dsorigem
    field vltarifa like crapthi.vltarifa.
    
DEF QUERY q_histor FOR craphis. 
                                     
DEF BROWSE b_histor QUERY q_histor 
               DISP craphis.cdhistor COLUMN-LABEL "Codigo"     FORMAT "zzzzzz9"
                    craphis.dshistor COLUMN-LABEL "Descricao"  FORMAT "x(13)"
                    craphis.indebcre COLUMN-LABEL "D/C"        FORMAT " x "
                    craphis.tplotmov COLUMN-LABEL "Lote"       FORMAT "zzzzzz9"
                    tab_txcpmfcc     COLUMN-LABEL "% CPMF"     FORMAT "9.9999"
                    craphis.inavisar COLUMN-LABEL "Aviso"      FORMAT "zzzzzz9"
                    craphis.nrctadeb COLUMN-LABEL "Debita"     FORMAT "zzzzzz9"
                    craphis.nrctacrd COLUMN-LABEL "Credita"    FORMAT "zzzzzz9"
                    WITH 9 DOWN.

DEF FRAME f_historico  
          SKIP(1)
          b_histor   HELP  "Pressione <F4> ou <END> para finalizar" 
          WITH NO-BOX CENTERED OVERLAY ROW 7.

/* Historico Boletim Caixa */
DEF QUERY q_historicos FOR craphis. 
                                     
DEF BROWSE b_historicos QUERY q_historicos 
               DISP craphis.cdhistor COLUMN-LABEL "Codigo"     FORMAT "zzzzzz9"
                    craphis.dshistor COLUMN-LABEL "Descricao"  FORMAT "x(13)"
                    craphis.indebcre COLUMN-LABEL "D/C"        FORMAT " x "
                    WITH 9 DOWN CENTERED TITLE "HISTORICOS BOLETIM CAIXA".

DEF FRAME f_historicos  
          SKIP(1)
          b_historicos   HELP  "Pressione <F4> ou <END> para finalizar" 
          WITH NO-BOX CENTERED OVERLAY ROW 7.
          
/* Historicos validos na tela OUTROS - Programa 56 */
DEF QUERY q_historic FOR craphis. 
                                     
DEF BROWSE b_historic QUERY q_historic 
               DISP craphis.cdhistor COLUMN-LABEL "Codigo"     FORMAT "zzzzzz9"
                    craphis.dshistor COLUMN-LABEL "Descricao"  FORMAT "x(13)"
                    craphis.indebcre COLUMN-LABEL "D/C"        FORMAT " x "
                    WITH 9 DOWN CENTERED TITLE "HIST. VALIDOS NA TELA OUTROS".

DEF FRAME f_historic  
          SKIP(1)
          b_historic   HELP  "Pressione <F4> ou <END> para finalizar" 
          WITH NO-BOX CENTERED OVERLAY ROW 7.


/*produtos e grupos*/
DEF    QUERY q-produtos   FOR crapprd.

DEF    BROWSE b-produtos  QUERY q-produtos
       DISPLAY crapprd.cdprodut LABEL "Cod"
               crapprd.dsprodut LABEL "Descricao"
       WITH 5 DOWN WIDTH 30 COLUMN 35 NO-LABELS TITLE "Produtos" OVERLAY.

FORM b-produtos  
     HELP "Use as SETAS para navegar <F4> para sair."
     WITH ROW 10 NO-LABELS NO-BOX CENTERED OVERLAY 
     FRAME f_browse_prd.

DEF    QUERY q-grupos   FOR crapagr.

DEF    BROWSE b-grupos  QUERY q-grupos
       DISPLAY crapagr.cdagrupa LABEL "Cod"
               crapagr.dsagrupa LABEL "Descricao"
       WITH 5 DOWN WIDTH 30 COLUMN 35 NO-LABELS TITLE "Grupos" OVERLAY.

FORM b-grupos  
     HELP "Use as SETAS para navegar <F4> para sair."
     WITH ROW 10 NO-LABELS NO-BOX CENTERED OVERLAY 
     FRAME f_browse_grp.
  
FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM tel_cddopcao  LABEL "Opcao" AUTO-RETURN 
                   HELP "Entre com a opcao desejada (A, B, C, I, O ou X)" 
                   VALIDATE (tel_cddopcao = "A" OR tel_cddopcao = "B" OR
                             tel_cddopcao = "C" OR tel_cddopcao = "I" OR
                             tel_cddopcao = "O" OR tel_cddopcao = "X", 
                             "014 - Opcao errada.") 
     WITH ROW 6 COLUMN 4 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM tel_flgclass       LABEL "Class.por" AUTO-RETURN
     HELP "Informe o tipo de classificacao: (C)odigo ou (D)escricao."
     WITH ROW 6 COLUMN 15 SIDE-LABELS OVERLAY NO-BOX FRAME f_classifica.

FORM tel_cdhistor       LABEL "Codigo"
                        HELP "Informe o codigo do historico inicial."
     tel_tplotmov_pesq  LABEL "Lote"
     WITH ROW 6 COLUMN 40 SIDE-LABELS NO-BOX OVERLAY FRAME f_codigo.

FORM tel_cdhistor       LABEL "Codigo"
                        HELP "Informe o codigo do historico inicial."
     WITH ROW 6 COLUMN 40 SIDE-LABELS NO-BOX OVERLAY FRAME f_codigo_a.

FORM tel_cdhistor       LABEL "Codigo"
                        HELP "Informe o codigo do historico de referencia."
     tel_cdhistor_novo  LABEL "Novo Codigo"
                        HELP "Informe o codigo do novo historico."
     WITH ROW 6 COLUMN 40 SIDE-LABELS NO-BOX OVERLAY FRAME f_codigo_i.

FORM tel_dshistor       LABEL "Descricao" FORMAT "x(13)"
                        HELP "Informe a descricao do historico inicial."
     tel_tplotmov_pesq  LABEL "Lote"
     WITH ROW 6 COLUMN 40 SIDE-LABELS OVERLAY NO-BOX FRAME f_descricao.

FORM SKIP
     tel_dshistor AT  2    VALIDATE(tel_dshistor <> "","014 - Opcao errada.")
                           FORMAT "x(13)"
     tel_indebcre AT 28    FORMAT "!" LABEL "D/C"
                           VALIDATE(CAN-DO("C,D",tel_indebcre),
                                    "014 - Opcao errada.")
     tel_tplotmov AT 36    VALIDATE(CAN-DO("000,001,002,003,004,005,006,
                                           ,007,008,009,010,011,012,013,
                                           ,014,015,016,017,018,019,020,
                                           ,021,022,023,024,025,028,029,
                                           ,030,031,032,122,124,125",
                                           STRING(tel_tplotmov,"999"))
                                           ,"014 - Opcao errada.")
     tel_inhistor AT 56    LABEL "Ind. Funcao"
                           VALIDATE(CAN-FIND (crapfhs WHERE crapfhs.cdcooper = 
                                                            glb_cdcooper  AND
                                                            crapfhs.inhistor =
                             tel_inhistor),"044 - Funcao deve ser informada.")
     SKIP(1)
     tel_dsexthst AT  2
     SKIP(1)
     tel_dsextrat AT 2 VALIDATE(tel_dsextrat <> "","014 - Opcao errada.")
     SKIP(1)
     tel_nmestrut AT  2
     tel_cdhstctb AT 41 
     SKIP(1)
     tel_indoipmf AT  2    VALIDATE(tel_indoipmf = 0 OR tel_indoipmf = 1 OR 
                                    tel_indoipmf = 2,"014 - Opcao errada.")
     tel_inclasse AT 53
     SKIP(1)
     tel_inautori AT  2    VALIDATE(tel_inautori = 0 OR tel_inautori = 1,
                                    "014 - Opcao errada.")
     tel_inavisar AT 42    VALIDATE(tel_inavisar = 0 OR tel_inavisar = 1,
                                    "014 - Opcao errada.")
     SKIP(1)
     tel_indcompl AT  2    VALIDATE(tel_indcompl = 0 OR tel_indcompl = 1,
                                    "014 - Opcao errada.")
     tel_indebcta AT  44   VALIDATE(tel_indebcta = 0 OR tel_indebcta = 1,
                                    "014 - Opcao errada.")
     WITH ROW 7 CENTERED SIDE-LABELS OVERLAY FRAME f_histor_1.

FORM SKIP(1)
     tel_incremes AT  2    VALIDATE(tel_incremes = 0 OR tel_incremes = 1,
                                    "014 - Opcao errada.")
     tel_tpctbcxa AT 48    VALIDATE(CAN-DO("0,1,2,3,4,5,6",
                             STRING(tel_tpctbcxa,"9")),"014 - Opcao errada.")
     SKIP(1)
     aux_vltarayl AT  2    LABEL "Tarifa"
     tel_tpctbccu AT 38    VALIDATE(tel_tpctbccu = 0 OR tel_tpctbccu = 1,
                                    "014 - Opcao errada.")
     SKIP(1)
     tel_nrctacrd AT  2 
     tel_nrctadeb AT 51 
     SKIP(1)
     tel_ingercre AT  2    LABEL "Gerencial a Credito"
                           VALIDATE(CAN-DO("1,2,3",
                             STRING(tel_ingercre,"9")),"380 - Numero errado.")
                           HELP "Informe  1-Nao, 2-Geral, 3-PA."
     tel_ingerdeb AT 48    LABEL "Gerencial a Debito"
                           VALIDATE(CAN-DO("1,2,3",
                              STRING(tel_ingerdeb,"9")),"380 - Numero errado.")
                           HELP "Informe  1-Nao, 2-Geral, 3-PA."
     SKIP(1)
     tel_nrctatrc AT  2 
     tel_nrctatrd AT 47
     SKIP(1)

     tel_flgsenha AT  2    LABEL "Solicitar Senha"      
                           HELP "Informe se o historico deve solicitar senha."                     

     WITH ROW 7 CENTERED SIDE-LABELS OVERLAY FRAME f_histor_2.
     
FORM SKIP(1)
    aux_vltarayl AT 2 LABEL "1-   AYLLOS"
    SPACE 
    SKIP(1)
    aux_vltarcxo AT 2 LABEL "2-    CAIXA"
    SPACE 
    SKIP(1)
    aux_vltarint AT 2 LABEL "3- INTERNET"
    SPACE 
    SKIP(1)
    aux_vltarcsh AT 2 LABEL "4-     CASH"
    SPACE 
    SKIP(1)
    WITH ROW 9 CENTERED SIDE-LABELS OVERLAY 
    TITLE " Tarifas " FRAME f_histor_2_1.

FORM SKIP(1)
    tel_cdprodut AT 6
    HELP "Informe o codigo do produto ou 'F7' para listar."
    "-" AT 28
    aux_dsprodut AT 30 NO-LABEL
    SKIP(1)
    tel_cdagrupa AT 2
    HELP "Informe o codigo do grupo ou 'F7' para listar."
    "-" AT 28
    aux_dsagrupa AT 30 NO-LABEL
    SKIP(8)
    WITH ROW 7 WIDTH 73 CENTERED SIDE-LABELS OVERLAY FRAME f_histor_3.

FORM HEADER
     rel_nmrescop                   AT   1 FORMAT "x(11)"
     "-"                            AT  13
     rel_nmrelato                   AT  15 FORMAT "x(33)"
     "- "
     "REF."                         AT  51
     glb_dtmvtolt                   AT  57 FORMAT "99/99/9999"
     "HR:"                          AT  72
     STRING(TIME,"HH:MM")           AT  76 FORMAT "x(5)"
     SKIP(2)
WITH PAGE-TOP NO-BOX WIDTH 80 FRAME f_cabrel080_1.

VIEW FRAME f_moldura.

PAUSE(0).

ASSIGN glb_cdcritic = 0
       glb_nmrotina = "".

{ includes/cpmf.i }

/* triggers para produtos/grupos */
ON  RETURN OF b-produtos 
    DO:
        ASSIGN tel_cdprodut = crapprd.cdprodut
               aux_dsprodut = crapprd.dsprodut.

        HIDE BROWSE b-produtos.
        HIDE FRAME f_browse_prd.
               
        DISPLAY tel_cdprodut aux_dsprodut WITH FRAME f_histor_3.
        APPLY "GO".

    END. 

ON  LEAVE OF tel_cdprodut IN FRAME f_histor_3
    DO:  
        FIND crapprd WHERE crapprd.cdprodut = INPUT tel_cdprodut 
                                                   NO-LOCK NO-ERROR.
                
        IF  NOT AVAIL crapprd THEN
            DO:
               MESSAGE "ATENCAO!!! Codigo " +  INPUT tel_cdprodut + 
                       " nao cadastrado!". 

               NEXT-PROMPT tel_cdprodut WITH FRAME f_histor_3.
               RETURN NO-APPLY.
            END.
        ELSE
            DO:
                HIDE MESSAGE.
                ASSIGN  tel_cdprodut = INPUT tel_cdprodut
                        aux_dsprodut = crapprd.dsprodut.
                DISPLAY tel_cdprodut aux_dsprodut WITH FRAME f_histor_3.
            END.
        
    END.

ON  RETURN OF b-grupos 
    DO:
        ASSIGN tel_cdagrupa = crapagr.cdagrupa
               aux_dsagrupa = crapagr.dsagrupa.

        HIDE BROWSE b-grupos.
        HIDE FRAME f_browse_grp.
               
        DISPLAY tel_cdagrupa aux_dsagrupa WITH FRAME f_histor_3.
        APPLY "GO".

    END.

ON  LEAVE, RETURN, GO OF tel_cdagrupa IN FRAME f_histor_3
    DO:
        FIND crapagr WHERE crapagr.cdagrupa = INPUT tel_cdagrupa        
                                                       NO-LOCK NO-ERROR.     
                                                                    
        IF  NOT AVAIL crapagr THEN
            DO:                                              
               MESSAGE "ATENCAO!!! Codigo " +  INPUT tel_cdagrupa + 
                       " nao cadastrado!".                          

               NEXT-PROMPT tel_cdagrupa WITH FRAME f_histor_3.
               RETURN NO-APPLY.                                        
            END. 
        ELSE
            DO:
                HIDE MESSAGE.
                ASSIGN  tel_cdagrupa = INPUT tel_cdagrupa                
                        aux_dsagrupa = crapagr.dsagrupa.
                DISPLAY tel_cdagrupa aux_dsagrupa WITH FRAME f_histor_3.
            END.
            
    END.
 
DO WHILE TRUE:

   ASSIGN tel_cdhistor = 0
          tel_cdhistor_novo = 0
          tel_dshistor = ""
          tel_tplotmov_pesq = 0
          tel_cddopcao = "C".

   HIDE FRAME f_histor_3.
          
   CLEAR FRAME f_opcao.
   
   RUN fontes/inicia.p.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE tel_cddopcao WITH FRAME f_opcao.

      IF   tel_cddopcao <> "B"   AND
           tel_cddopcao <> "O"   AND
           tel_cddopcao <> "C"   THEN
           IF   glb_dsdepart = "TI"                   OR
                glb_dsdepart = "CONTABILIDADE"        OR
                glb_dsdepart = "COORD.ADM/FINANCEIRO" THEN
                .
           ELSE
           IF   glb_cdcooper <> 3   THEN
                DO:
                    BELL.
                    MESSAGE "Apenas CONSULTA esta liberada para esta tela.".
                    NEXT.
                END.

      LEAVE.
      
   END.
      
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN     /*   F4 OU FIM   */
        DO:
            RUN fontes/novatela.p.
            IF   CAPS(glb_nmdatela) <> "HISTOR"   THEN
                 DO:
                     HIDE FRAME f_opcao.
                     HIDE FRAME f_moldura.
                     RETURN.
                 END.
            ELSE
                 NEXT.
        END.

   CASE tel_cddopcao:
        WHEN "A" THEN       /*  Opcao de Alteracao  */
             DO:
                 glb_cddopcao = "A".
                 
                 { includes/acesso.i }

                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_cdhistor                           
                           WITH FRAME f_codigo_a.
                    LEAVE.
      
                 END.             
                    
                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                      DO:
                          HIDE FRAME f_codigo_a.
                          NEXT.
                      END.
                      
                 IF   tel_cdhistor = 0 THEN
                      DO:
                          OPEN QUERY q_histor 
                                     FOR EACH craphis WHERE craphis.cdcooper =
                                                            glb_cdcooper 
                                                      BY craphis.dshistor.
                          ENABLE b_histor WITH FRAME f_historico.

                          WAIT-FOR DEFAULT-ACTION OF DEFAULT-WINDOW.
                          
                          HIDE FRAME f_historico.

                          ASSIGN tel_cdhistor = craphis.cdhistor.
                          DISP tel_cdhistor WITH FRAME f_codigo_a.
                      END.
                 ELSE
                      DO:
                          FIND craphis WHERE 
                                       craphis.cdcooper = glb_cdcooper AND 
                                       craphis.cdhistor = tel_cdhistor
                                       NO-LOCK NO-ERROR.
                                              
                          IF  NOT AVAILABLE craphis THEN
                              DO:
                                  glb_cdcritic = 526.
                                  RUN fontes/critic.p.
                                  BELL.
                                  MESSAGE glb_dscritic.
                                  glb_cdcritic = 0.
                                  PAUSE 5 NO-MESSAGE.
                                  HIDE FRAME f_codigo_a.
                                  NEXT.
                              END.
                      END.
                 
                 RUN p_historico.

                 HIDE FRAME f_codigo.
             END.

        WHEN "C" THEN       /*  Opcao de Consulta  */ 
             DO:
                 glb_cddopcao = "C".

                 { includes/acesso.i }

                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_flgclass WITH FRAME f_classifica.

                     LEAVE.
      
                 END.             
                    
                 IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                      DO:
                          HIDE FRAME f_classifica.
                          NEXT.
                      END.     
                          
                 IF   tel_flgclass THEN                       /*  Codigo  */
                      DO:
                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                             UPDATE tel_cdhistor WITH FRAME f_codigo.

                             DISPLAY tel_tplotmov_pesq  WITH FRAME f_codigo.
                             IF  tel_cdhistor = 0 THEN
                                 UPDATE tel_tplotmov_pesq
                                         WITH FRAME f_codigo.
                             
                             LEAVE.
      
                          END.             
                    
                          IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                               DO:
                                   HIDE FRAME f_codigo.
                                   HIDE FRAME f_classifica.
                                   NEXT.
                               END.
                               
                          IF   tel_cdhistor = 0 THEN
                               DO:
                                   OPEN QUERY q_histor 
                                        FOR EACH craphis WHERE 
                                                 craphis.cdcooper  = 
                                                 glb_cdcooper          AND 
                                                (craphis.tplotmov  = 
                                                 tel_tplotmov_pesq     OR
                                                 tel_tplotmov_pesq = 0)
                                                 BY craphis.cdhistor.

                                   ENABLE b_histor WITH FRAME f_historico.

                                   WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                          
                                   HIDE FRAME f_historico.
                               END.
                          ELSE
                               DO:
                                   OPEN QUERY q_histor 
                                        FOR EACH craphis WHERE
                                            craphis.cdcooper = glb_cdcooper AND 
                                            craphis.cdhistor = tel_cdhistor.
                                   ENABLE b_histor WITH FRAME f_historico.

                                   WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                          
                                   HIDE FRAME f_historico.
                               END.
                          HIDE FRAME f_codigo.
                          HIDE FRAME f_classifica.                      
                      END.
                 ELSE                                        /*  Descricao  */
                      DO:
                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                             UPDATE tel_dshistor
                                    tel_tplotmov_pesq
                                    WITH FRAME f_descricao.
                             LEAVE.
      
                          END.             
                    
                          IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                               DO:
                                   HIDE FRAME f_descricao.
                                   HIDE FRAME f_classifica.
                                   NEXT.
                               END.
                               
                          OPEN QUERY q_histor 
                               FOR EACH craphis WHERE
                                        craphis.cdcooper = glb_cdcooper AND 
                                        craphis.dshistor MATCHES  
                                        "*" + TRIM(tel_dshistor) + "*"  AND
                                      ( tel_tplotmov_pesq = 0 OR
                                        craphis.tplotmov =
                                        tel_tplotmov_pesq)
                                        BY craphis.dshistor.
                          ENABLE b_histor WITH FRAME f_historico.

                          WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                          
                          HIDE FRAME f_historico.
                          HIDE FRAME f_descricao.
                          HIDE FRAME f_classifica.
                      END.
             END. 
                 
        WHEN "I" THEN       /*  Opcao de Inclusao  */ 
             DO:
                 ASSIGN glb_cddopcao = "I".

                 { includes/acesso.i }
                 
                 IF   glb_dsdepart <> "TI"             AND
                      glb_dsdepart <> "COORD.PRODUTOS" AND
                      glb_dsdepart <> "CONTABILIDADE"  THEN
                      IF   glb_cdcooper <> 3   THEN   /*  Edson - 10/09/2004  */
                           DO:
                               MESSAGE "Opcao permitida apenas para a CECRED.".
                               NEXT.
                           END.              
                /* Opcao Bloqueada - Guilherme 28/11/2007 */                 
                /* MESSAGE "Opcao bloqueada.". */
                 DISP tel_cdhistor_novo WITH FRAME f_codigo_i.

                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                    UPDATE tel_cdhistor WITH FRAME f_codigo_i.

                    LEAVE.
                 END.

                 IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 DO:
                    HIDE FRAME f_codigo_i.
                    NEXT.
                 END.
                      
                 IF tel_cdhistor = 0 THEN
                 DO:
                    OPEN QUERY q_histor 
                                    FOR EACH craphis WHERE craphis.cdcooper =
                                                            glb_cdcooper 
                                                      BY craphis.dshistor.
                    ENABLE b_histor WITH FRAME f_historico.

                    WAIT-FOR DEFAULT-ACTION OF DEFAULT-WINDOW.
                          
                    HIDE FRAME f_historico.

                    ASSIGN tel_cdhistor = craphis.cdhistor.
                    DISP tel_cdhistor WITH FRAME f_codigo_i.
                 END.
                 ELSE
                 DO:
                    FIND craphis WHERE craphis.cdcooper = glb_cdcooper AND 
                                       craphis.cdhistor = tel_cdhistor
                                       NO-LOCK NO-ERROR.
                                              
                    IF  NOT AVAILABLE craphis THEN
                    DO:
                        glb_cdcritic = 526.
                        RUN fontes/critic.p.
                        BELL.
                        MESSAGE glb_dscritic.
                        glb_cdcritic = 0.
                        PAUSE 5 NO-MESSAGE.
                        HIDE FRAME f_codigo_i.
                        NEXT.
                    END.
                 END.

                 DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                     UPDATE tel_cdhistor_novo WITH FRAME f_codigo_i.

                     IF tel_cdhistor_novo = 0 THEN
                     DO:
                         MESSAGE "Codigo do historico nao pode ser zero.".
                         PAUSE 5 NO-MESSAGE.
                     END.
                     ELSE    
                     DO:
                        FIND craphis WHERE craphis.cdcooper = glb_cdcooper AND 
                                           craphis.cdhistor = tel_cdhistor_novo
                                                              NO-LOCK NO-ERROR.

                        IF AVAIL craphis THEN
                        DO:
                            MESSAGE "873 - Codigo ja cadastrado.".
                            PAUSE 5 NO-MESSAGE.
                        END.
                        ELSE
                            LEAVE.
                     END.
                 END.

                 IF KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                 DO:
                    HIDE FRAME f_codigo_i.
                    NEXT.
                 END.

                 FIND craphis WHERE craphis.cdcooper = glb_cdcooper AND 
                                    craphis.cdhistor = tel_cdhistor
                                                        NO-LOCK NO-ERROR.

                 RUN p_historico.

                 HIDE FRAME f_codigo_i.
                 
             END.

       WHEN "X" THEN       /*  Opcao de Replicacao de Historico  */ 
            DO:
                glb_cddopcao = "X".

                { includes/acesso.i }

                DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

                    UPDATE tel_cdhistor                           
                           WITH FRAME f_codigo_a.
                    LEAVE.
      
                END.             
                IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   THEN
                     DO:
                        HIDE FRAME f_codigo_a.
                        NEXT.
                     END.

                IF   tel_cdhistor = 0 THEN
                     DO:
                        OPEN QUERY q_histor 
                                   FOR EACH craphis WHERE craphis.cdcooper =
                                                          glb_cdcooper 
                                                    BY craphis.dshistor.
                        ENABLE b_histor WITH FRAME f_historico.

                        WAIT-FOR DEFAULT-ACTION OF DEFAULT-WINDOW.

                        HIDE FRAME f_historico.

                        ASSIGN tel_cdhistor = craphis.cdhistor.
                        DISP tel_cdhistor WITH FRAME f_codigo_a.
                    END.
                ELSE
                    DO:
                        FIND craphis WHERE 
                                     craphis.cdcooper = glb_cdcooper AND 
                                     craphis.cdhistor = tel_cdhistor
                                     NO-LOCK NO-ERROR.

                        IF  NOT AVAILABLE craphis THEN
                            DO:
                                glb_cdcritic = 526.
                                RUN fontes/critic.p.
                                BELL.
                                MESSAGE glb_dscritic.
                                glb_cdcritic = 0.
                                PAUSE 5 NO-MESSAGE.
                                HIDE FRAME f_codigo_a.
                                NEXT.
                            END.
                    END.

                RUN p_historico.
                IF  RETURN-VALUE = "OK" THEN 
                    DO:
                        RUN p_replica_hist.
                        BELL.

                        UNIX SILENT VALUE("echo " + STRING(glb_dtmvtolt, 
                                                             "99/99/9999") +
                                          " " + STRING(TIME, "HH:MM:SS") +
                                          " '-->' " + "Operador " + 
                                          STRING(glb_cdoperad) + " - " +
                                          "Replicou o histórico de código " +
                                          STRING(craphis.cdhistor) +
                                          ". >> log/histor.log").

                        MESSAGE "Replicacao efetuada com sucesso.".
                        PAUSE 5 NO-MESSAGE.
                    END.

                HIDE FRAME f_codigo.
            END.

        WHEN "B" THEN  /* Lista historicos da rotina 56 */
             DO:
                 OPEN QUERY q_historicos 
                      FOR EACH craphis WHERE 
                                       craphis.cdcooper = glb_cdcooper AND 
                                       craphis.cdhistor > 700 AND
                                       craphis.cdhistor < 800 AND
                                       craphis.tplotmov = 22 NO-LOCK 
                                       BY craphis.indebcre
                                          BY craphis.cdhistor.
                 
                 ENABLE b_historicos WITH FRAME f_historicos.

                 WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
           
                 CLOSE QUERY q_historicos.

                 HIDE FRAME f_historicos.
             
                 HIDE MESSAGE NO-PAUSE.
           
                 RUN confirma.
                 
                 IF   aux_confirma = "S"  THEN
                      RUN imprime_historico.
             END. 
        
        WHEN "O"  THEN
             DO:
                 OPEN QUERY q_historic 
                      FOR EACH craphis WHERE 
                                       craphis.cdcooper = glb_cdcooper AND 
                                       craphis.tplotmov = 1 AND
                                      (craphis.tpctbcxa = 2 OR
                                       craphis.tpctbcxa = 3)AND
                                       NOT CAN-DO
                                       ("1,386,3,4,403,404,21,26,22,372,1030",
                                           STRING(craphis.cdhistor)) NO-LOCK
                                           BY craphis.indebcre
                                              BY craphis.cdhistor.
                                        
                 ENABLE b_historic WITH FRAME f_historic. 

                 WAIT-FOR END-ERROR OF DEFAULT-WINDOW.
                 
                 CLOSE QUERY q_historic. 

                 HIDE FRAME f_historic.
             
                 HIDE MESSAGE NO-PAUSE.
           
                 RUN confirma.
                 
                 IF   aux_confirma = "S"  THEN
                      RUN imprime_historic.
             END. 
                 
   END CASE.

END.  /*  Fim do DO WHILE TRUE  */

PROCEDURE p_historico:

ASSIGN aux_vltarayl = 0
       aux_vltarcxo = 0
       aux_vltarint = 0
       aux_vltarcsh = 0.

FOR EACH crapthi WHERE crapthi.cdcooper = glb_cdcooper   AND
                       crapthi.cdhistor = tel_cdhistor   NO-LOCK:
                                                                     
    IF   crapthi.dsorigem = "AYLLOS"   THEN                          
         ASSIGN aux_vltarayl = crapthi.vltarifa                      
                log_vltarayl = crapthi.vltarifa.                     
    ELSE                                                             
    IF   crapthi.dsorigem = "CAIXA"   THEN          
         ASSIGN aux_vltarcxo = crapthi.vltarifa
                log_vltarcxo = crapthi.vltarifa.           
    ELSE                                            
    IF   crapthi.dsorigem = "INTERNET"   THEN
         ASSIGN aux_vltarint = crapthi.vltarifa
                log_vltarint = crapthi.vltarifa.
    ELSE
    IF   crapthi.dsorigem = "CASH"   THEN                
         ASSIGN aux_vltarcsh = crapthi.vltarifa
                log_vltarcsh = crapthi.vltarifa.                
                                                         
END.                                                     
                                                         
DO WHILE TRUE:                                           
   
   IF   tel_cddopcao = "A" OR tel_cddopcao = "X" OR tel_cddopcao = "I" THEN
        DO: /* Alteracao, replicacao ou inclusao */
            ASSIGN aux_cdhistor  =  craphis.cdhistor         
                   tel_cdhstctb  =  craphis.cdhstctb         
                   tel_dsexthst  =  craphis.dsexthst         
                   tel_dshistor  =  craphis.dshistor         
                   tel_inautori  =  craphis.inautori         
                   tel_inavisar  =  craphis.inavisar         
                   tel_inclasse  =  craphis.inclasse         
                   tel_incremes  =  craphis.incremes         
                   tel_indcompl  =  craphis.indcompl         
                   tel_indebcre  =  craphis.indebcre         
                   tel_indebcta  =  craphis.indebcta         
                   tel_indebfol  =  craphis.indebfol         
                   tel_indoipmf  =  craphis.indoipmf         
                   tel_inhistor  =  craphis.inhistor         
                   tel_nmestrut  =  craphis.nmestrut         
                   tel_nrctacrd  =  craphis.nrctacrd         
                   tel_nrctatrc  =  craphis.nrctatrc         
                   tel_nrctadeb  =  craphis.nrctadeb         
                   tel_nrctatrd  =  craphis.nrctatrd         
                   tel_tpctbccu  =  craphis.tpctbccu         
                   tel_tplotmov  =  craphis.tplotmov         
                   tel_tpctbcxa  =  craphis.tpctbcxa         
                   tel_txdoipmf  =  craphis.txdoipmf         
                   tel_ingercre  =  craphis.ingercre         
                   tel_ingerdeb  =  craphis.ingerdeb         
                   tel_flgsenha  =  craphis.flgsenha
                   tel_dsextrat  =  craphis.dsextrat 
                   log_cdhstctb  =  craphis.cdhstctb                                           
                   log_dsexthst  =  craphis.dsexthst
                   log_dshistor  =  craphis.dshistor
                   log_inautori  =  craphis.inautori
                   log_inavisar  =  craphis.inavisar
                   log_inclasse  =  craphis.inclasse
                   log_incremes  =  craphis.incremes
                   log_indcompl  =  craphis.indcompl
                   log_indebcre  =  craphis.indebcre
                   log_indebcta  =  craphis.indebcta
                   log_indebfol  =  craphis.indebfol
                   log_indoipmf  =  craphis.indoipmf
                   log_inhistor  =  craphis.inhistor
                   log_nmestrut  =  craphis.nmestrut
                   log_nrctacrd  =  craphis.nrctacrd
                   log_nrctatrc  =  craphis.nrctatrc
                   log_nrctadeb  =  craphis.nrctadeb
                   log_nrctatrd  =  craphis.nrctatrd
                   log_tpctbccu  =  craphis.tpctbccu                                           
                   log_tplotmov  =  craphis.tplotmov                              
                   log_tpctbcxa  =  craphis.tpctbcxa                              
                   log_txdoipmf  =  craphis.txdoipmf                              
                   log_ingercre  =  craphis.ingercre                              
                   log_ingerdeb  =  craphis.ingerdeb  
                   log_flgsenha  =  craphis.flgsenha
                   log_dsextrat  =  craphis.dsextrat.
                                
            DISPLAY  tel_dshistor   tel_tplotmov     tel_inhistor
                     tel_dsexthst   tel_dsextrat     tel_nmestrut     
                     tel_cdhstctb   tel_indoipmf     tel_inclasse     
                     tel_inautori   tel_inavisar     tel_indcompl   
                     tel_indebcta   tel_indebcre   
                     WITH FRAME f_histor_1.

         END.  /* Fim do IF tel_cddopcao = "A" */  

   /* sergio - sensus */
   IF  tel_cddopcao = "X" THEN 
       DO:           
           DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
        
              aux_confirma = "N".
              glb_cdcritic = 78.
              RUN fontes/critic.p.
              BELL.
              glb_cdcritic = 0.
              MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
              LEAVE.
        
           END.  /*  Fim do DO WHILE TRUE  */

           HIDE FRAME f_histor_1.
           RETURN IF aux_confirma = "N" 
                  THEN "NOK" 
                  ELSE "OK".
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
     
      UPDATE   tel_dshistor   tel_indebcre     tel_tplotmov     tel_inhistor
               tel_dsexthst   tel_dsextrat     tel_nmestrut     tel_cdhstctb
               tel_indoipmf   tel_inclasse     tel_inautori
               tel_inavisar   tel_indcompl     tel_indebcta
               WITH FRAME f_histor_1.
      LEAVE.
      
   END.        

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
        DO:
            HIDE FRAME f_histor_1.
            RETURN. 
        END.
        
   IF   tel_cddopcao = "A" OR tel_cddopcao = "I"  THEN /*Alteracao, inclusao*/
        DO:
            /* Somente o tipo 1 pode ter senha */
            ASSIGN tel_flgsenha = NO WHEN tel_tplotmov <> 1.

            DISPLAY  tel_incremes   tel_tpctbcxa     aux_vltarayl   
                     tel_tpctbccu   tel_nrctacrd     tel_nrctadeb   
                     tel_nrctatrc   tel_nrctatrd     tel_ingercre
                     tel_ingerdeb   tel_flgsenha     WITH FRAME f_histor_2.
        END. 
        
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE: 

      UPDATE   tel_incremes                 
               tel_tpctbcxa                 
               aux_vltarayl                 
               WITH FRAME f_histor_2.       
                                            
      LEAVE.                                
   
   END.

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
        DO:
            HIDE FRAME f_histor_2.
            NEXT. 
        END.
           
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      DISP aux_vltarayl aux_vltarcxo aux_vltarint aux_vltarcsh
           WITH FRAME f_histor_2_1.

      UPDATE  aux_vltarcxo
              aux_vltarint 
              aux_vltarcsh 
              WITH FRAME f_histor_2_1.
              
      LEAVE.
   
   END.

   HIDE FRAME f_histor_2_1.

   /* O campo 'Solicitar Senha' eh soh para Tipo Conta corrente */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      UPDATE   tel_tpctbccu 
               tel_nrctacrd 
               tel_nrctadeb   
               tel_ingercre 
               tel_ingerdeb 
               tel_nrctatrc
               tel_nrctatrd 
               tel_flgsenha WHEN tel_tplotmov = 1 
               WITH FRAME f_histor_2.      
      
      LEAVE.
   
   END.
   /* Fabricio */
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
        DO:
            HIDE FRAME f_histor_2.
            NEXT. 
        END.
   
   /*Produtos e Grupos*/
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      FIND crapprd WHERE crapprd.cdprodut = craphis.cdprodut
                                                NO-LOCK NO-ERROR.
      IF  AVAIL crapprd THEN
          DO:
              ASSIGN tel_cdprodut = craphis.cdprodut        
                     aux_dsprodut = crapprd.dsprodut
                     log_cdprodut = craphis.cdprodut.       
                  /*ver dspdodut */
              DISPLAY aux_dsprodut WITH FRAME f_histor_3.
          
          END.

      FIND crapagr WHERE crapagr.cdagrupa = craphis.cdagrupa
                                                NO-LOCK NO-ERROR.
      IF  AVAIL crapagr THEN
          DO:
              ASSIGN tel_cdagrupa = craphis.cdagrupa
                     aux_dsagrupa = crapagr.dsagrupa
                     log_cdagrupa = craphis.cdagrupa.
                      /*ver dsagrupa*/
              DISPLAY aux_dsagrupa WITH FRAME f_histor_3.
          END.

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
           DO:
               HIDE FRAME f_histor_3.
               NEXT.
           END.
  
      UPDATE tel_cdprodut  
             tel_cdagrupa
             WITH FRAME f_histor_3

      EDITING:
         READKEY.
         IF  FRAME-FIELD = "tel_cdprodut" THEN
             DO:
                 IF  LASTKEY = KEYCODE("F7")  THEN
                     DO:
                       OPEN QUERY q-produtos
                           FOR EACH crapprd NO-LOCK.
                           
                       DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                           UPDATE b-produtos WITH FRAME f_browse_prd.
                           LEAVE.   
                       END.
                 
                       HIDE FRAME f_browse_prd.
                       NEXT.
                 
                     END.
                 ELSE
                     APPLY LASTKEY.
             END.
         ELSE
             IF  FRAME-FIELD = "tel_cdagrupa" THEN
                 DO:
                    IF  LASTKEY = KEYCODE("F7")  THEN
                        DO:
                          OPEN QUERY q-grupos
                              FOR EACH crapagr NO-LOCK.

                          DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
                              UPDATE b-grupos WITH FRAME f_browse_grp.
                              LEAVE.
                          END.

                          HIDE FRAME f_browse_grp.
                          NEXT.

                        END.
                    ELSE
                        APPLY LASTKEY.
                 END.                                                  
      END. /*editing*/

      IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
           DO:
               HIDE FRAME f_histor_3.
               NEXT.
           END.
          
      LEAVE. 
   END.  /*do while true*/

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR" THEN  /* F4 OU FIM */
        DO:
            HIDE FRAME f_histor_3.
            HIDE FRAME f_histor_2_1.
            HIDE FRAME f_histor_2.
            HIDE FRAME f_histor_1.
            NEXT. 
        END.

   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:

      aux_confirma = "N".
      glb_cdcritic = 78.
      RUN fontes/critic.p.
      BELL.
      glb_cdcritic = 0.
      MESSAGE COLOR NORMAL glb_dscritic UPDATE aux_confirma.
      LEAVE.

   END.  /*  Fim do DO WHILE TRUE  */

   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR
        aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 5 NO-MESSAGE.
            HIDE FRAME f_histor_3.
            HIDE FRAME f_histor_2_1.
            HIDE FRAME f_histor_2.
            HIDE FRAME f_histor_1.
            RETURN.
        END.    
 
   DO TRANSACTION ON ERROR UNDO, RETURN:
   
      glb_cdcritic = 0.
      
      IF  tel_cddopcao = "I"  THEN
          DO:
                aux_cdhistor = tel_cdhistor_novo.
                  
                CREATE craphis.
               
          END.
      
      IF  tel_cddopcao = "A" OR tel_cddopcao = "I"  THEN
          DO:
              FIND FIRST crapthi WHERE crapthi.cdcooper = glb_cdcooper   AND
                                       crapthi.cdhistor = aux_cdhistor
                                       NO-LOCK NO-ERROR.
                  
              IF  NOT AVAILABLE crapthi  THEN
                  DO:
                      CREATE crapthi.
                      ASSIGN crapthi.cdcooper = glb_cdcooper
                             crapthi.cdhistor = aux_cdhistor
                             crapthi.dsorigem = "AYLLOS"
                             crapthi.vltarifa = aux_vltarayl.
                                
                      CREATE crapthi.
                      ASSIGN crapthi.cdcooper = glb_cdcooper
                             crapthi.cdhistor = aux_cdhistor
                             crapthi.dsorigem = "CAIXA"
                             crapthi.vltarifa = aux_vltarcxo.
                                       
                      CREATE crapthi.
                      ASSIGN crapthi.cdcooper = glb_cdcooper
                             crapthi.cdhistor = aux_cdhistor
                             crapthi.dsorigem = "INTERNET"
                             crapthi.vltarifa = aux_vltarint.
                                               
                      CREATE crapthi.
                      ASSIGN crapthi.cdcooper = glb_cdcooper
                             crapthi.cdhistor = aux_cdhistor
                             crapthi.dsorigem = "CASH"
                             crapthi.vltarifa = aux_vltarcsh.
                  END.
              ELSE
                  FOR EACH crapthi WHERE crapthi.cdcooper = glb_cdcooper   AND
                                         crapthi.cdhistor = aux_cdhistor 
                                         EXCLUSIVE-LOCK:
                      
                      IF  crapthi.dsorigem = "AYLLOS"  THEN
                          crapthi.vltarifa = aux_vltarayl.
                      ELSE
                      IF  crapthi.dsorigem = "CAIXA"  THEN
                          crapthi.vltarifa = aux_vltarcxo.
                      ELSE
                      IF  crapthi.dsorigem = "INTERNET" THEN
                          crapthi.vltarifa = aux_vltarint.
                      ELSE
                      IF  crapthi.dsorigem = "CASH"  THEN
                          crapthi.vltarifa = aux_vltarcsh.

                  END. /** Fim do FOR EACH crapthi **/
                  
              IF  NOT f_conectagener()  THEN
                  DO:
                      BELL.
                      MESSAGE "Banco generico nao conectado.".
                          
                      PAUSE 5 NO-MESSAGE.
                          
                      UNDO, RETURN.                          
                  END.

              /** Atualiza tarifas na tabela generica de convenios **/
              RUN fontes/histor_g.p (INPUT aux_cdhistor,
                                     INPUT aux_vltarcxo,
                                     INPUT aux_vltarint,
                                     INPUT aux_vltarayl,
                                     INPUT aux_vltarcsh).
                                         
              RUN p_desconectagener.                       
                      
              /** Pega registro do historico para alteracao **/
              IF tel_cddopcao = "A" THEN
              DO:
                  DO aux_contador = 1 TO 10:
              
                      glb_cdcritic = 0.
              
                      FIND craphis WHERE craphis.cdcooper = glb_cdcooper AND 
                                         craphis.cdhistor = aux_cdhistor 
                                         EXCLUSIVE-LOCK NO-ERROR NO-WAIT.
          
                      IF  NOT AVAILABLE craphis  THEN
                      DO:
                          IF LOCKED craphis  THEN
                          DO:
                              glb_cdcritic = 341.
                              PAUSE 1 NO-MESSAGE.
                              NEXT.
                          END.
                          ELSE    
                              glb_cdcritic = 245.
                      END.
                    
                      LEAVE.
                      
                  END. /** Fim do DO ... TO **/
              END.
          END.    
      ELSE
          glb_cdcritic = 14.

      IF  glb_cdcritic <> 0  THEN
          DO:
              RUN fontes/critic.p.
                     
              BELL.
              MESSAGE glb_dscritic.
                      
              glb_cdcritic = 0.
                      
              PAUSE 5 NO-MESSAGE.
                      
              HIDE FRAME f_histor_3.
              HIDE FRAME f_histor_2_1.
              HIDE FRAME f_histor_2.
              HIDE FRAME f_histor_1.
                      
              UNDO, RETURN.
          END.

      ASSIGN craphis.cdcooper  =  glb_cdcooper
             craphis.cdhistor  =  aux_cdhistor
             craphis.cdhstctb  =  tel_cdhstctb
             craphis.dsexthst  =  CAPS(tel_dsexthst)
             craphis.dshistor  =  CAPS(tel_dshistor)
             craphis.inautori  =  tel_inautori
             craphis.inavisar  =  tel_inavisar
             craphis.inclasse  =  tel_inclasse
             craphis.incremes  =  tel_incremes
             craphis.indcompl  =  tel_indcompl
             craphis.indebcta  =  tel_indebcta
             craphis.indebfol  =  0 
             craphis.indoipmf  =  tel_indoipmf
             craphis.inhistor  =  tel_inhistor
             craphis.indebcre  =  tel_indebcre
             craphis.nmestrut  =  TRIM(CAPS(tel_nmestrut))
             craphis.nrctacrd  =  tel_nrctacrd
             craphis.nrctatrc  =  tel_nrctatrc
             craphis.nrctadeb  =  tel_nrctadeb
             craphis.nrctatrd  =  tel_nrctatrd
             craphis.tpctbccu  =  tel_tpctbccu
             craphis.tplotmov  =  tel_tplotmov
             craphis.tpctbcxa  =  tel_tpctbcxa
             craphis.txdoipmf  =  0 
             craphis.ingercre  =  tel_ingercre
             craphis.ingerdeb  =  tel_ingerdeb
             craphis.flgsenha  =  tel_flgsenha
             craphis.cdprodut  =  tel_cdprodut
             craphis.cdagrupa  =  tel_cdagrupa
             craphis.dsextrat  = CAPS(tel_dsextrat ).

      RUN gera_item_log.


   END. /* Fim do DO TRANSACTION */
   
   RELEASE craphis.

   IF   aux_cdhistor > 0    AND
        tel_cddopcao = "I"  THEN
        DO:
            MESSAGE "Operacao realizada com sucesso.".
            PAUSE 3 NO-MESSAGE.
        END.

   HIDE FRAME f_histor_3.
   HIDE FRAME f_histor_2_1.
   HIDE FRAME f_histor_2.
   HIDE FRAME f_histor_1.

   LEAVE.

END.  /*  Fim do DO WHILE TRUE  */

END PROCEDURE.

PROCEDURE confirma:

   /* Confirma */
   DO WHILE TRUE ON ENDKEY UNDO, LEAVE:
      ASSIGN aux_confirma = "N".
             BELL.
             MESSAGE  "Deseja Imprimir" UPDATE aux_confirma.
             LEAVE.
   END.  /*  Fim do DO WHILE TRUE  */
           
   IF   KEYFUNCTION(LASTKEY) = "END-ERROR"   OR   aux_confirma <> "S" THEN
        DO:
            glb_cdcritic = 79.
            RUN fontes/critic.p.
            glb_cdcritic = 0.
            BELL.
            MESSAGE glb_dscritic.
            PAUSE 1 NO-MESSAGE.
        END. /* Mensagem de confirmacao */

END PROCEDURE.

PROCEDURE imprime_historico:

    INPUT THROUGH basename `tty` NO-ECHO.

    SET aux_nmendter WITH FRAME f_terminal.
    
    INPUT CLOSE.           

    UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
    
    ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 82.

    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    
    ASSIGN rel_nmrescop = crapcop.nmrescop
           rel_nmrelato = "HISTORICOS BOLETIM CAIXA".
    
    VIEW STREAM str_1 FRAME f_cabrel080_1.
    
    FOR EACH craphis WHERE craphis.cdcooper = glb_cdcooper AND 
                           craphis.cdhistor > 700 AND
                           craphis.cdhistor < 800 AND
                           craphis.tplotmov = 22 NO-LOCK
                           BY craphis.indebcre
                              BY craphis.cdhistor : 
                           
        FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper
                                 NO-LOCK NO-ERROR.
                           
        DISPLAY STREAM str_1
                       craphis.cdhistor LABEL "Historico"
                       craphis.dshistor LABEL "Descricao" FORMAT "x(30)"
                       craphis.indebcre LABEL "D/C"       FORMAT " x "
                       WITH NO-LABEL CENTERED 
                       TITLE "HISTORICOS BOLETIM CAIXA\n\n".
    
    END.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
         DO:
             PAGE STREAM str_1.
             VIEW STREAM str_1 FRAME f_cabrel080_1.
         END.
            
    OUTPUT STREAM str_1 CLOSE.
    
    ASSIGN glb_nrdevias = 1
           par_flgrodar = TRUE
           glb_nmformul = "80col".
           
    { includes/impressao.i }
    
END PROCEDURE.

PROCEDURE imprime_historic:

    INPUT THROUGH basename `tty` NO-ECHO.

    SET aux_nmendter WITH FRAME f_terminal.
    
    INPUT CLOSE.           

    UNIX SILENT VALUE("rm rl/" + aux_nmendter + "* 2> /dev/null").
    
    ASSIGN aux_nmarqimp = "rl/" + aux_nmendter + STRING(TIME) + ".ex".

    OUTPUT STREAM str_1 TO VALUE(aux_nmarqimp) PAGED PAGE-SIZE 82.

    FIND crapcop WHERE crapcop.cdcooper = glb_cdcooper NO-LOCK NO-ERROR.
    
    ASSIGN rel_nmrescop = crapcop.nmrescop
           rel_nmrelato = "HISTORICOS VALIDOS NA TELA OUTROS".
    
    VIEW STREAM str_1 FRAME f_cabrel080_1.

    FOR EACH craphis WHERE craphis.cdcooper = glb_cdcooper AND 
                           craphis.tplotmov = 1 AND
                          (craphis.tpctbcxa = 2 OR
                           craphis.tpctbcxa = 3) NO-LOCK
                           BY craphis.indebcre
                              BY craphis.cdhistor:
                                        
        IF  craphis.cdhistor = 01  OR /*Crap51- Dep¢sitos com Captura*/
            craphis.cdhistor = 386 OR
            craphis.cdhistor = 03  OR
            craphis.cdhistor = 04  OR
            
            craphis.cdhistor = 403 OR    /* Crap52- Dep¢sitos sem Captura */
            craphis.cdhistor = 404 OR
            
            craphis.cdhistor = 21  OR    /* Crap53 - Pagto de Cheque */
            craphis.cdhistor = 26  OR
                     
            craphis.cdhistor = 22   OR    /* Crap54  - Cheque Avulso */
            craphis.cdhistor = 1030 OR    /* Crap54  - Cheque Avulso (Cartao Mag)*/
              
            craphis.cdhistor = 372 THEN  /* Crap55 - Cheque Liberado */
            NEXT.                       
      
        FIND FIRST crapass WHERE crapass.cdcooper = glb_cdcooper 
                                 NO-LOCK NO-ERROR.
        
        DISPLAY STREAM str_1
                       craphis.cdhistor LABEL "Historico"
                       craphis.dshistor LABEL "Descricao" FORMAT "x(30)"
                       craphis.indebcre LABEL "D/C"       FORMAT " x "
                       WITH NO-LABEL CENTERED 
                       TITLE "HISTORICOS VALIDOS NA TELA OUTROS\n\n".
    
    END.

    IF   LINE-COUNTER(str_1) > PAGE-SIZE(str_1)  THEN
         DO:
             PAGE STREAM str_1.
             VIEW STREAM str_1 FRAME f_cabrel080_1.
         END.
         
    OUTPUT STREAM str_1 CLOSE.
    
    ASSIGN glb_nrdevias = 1
           par_flgrodar = TRUE
           glb_nmformul = "80col".
           
    { includes/impressao.i }
    
END PROCEDURE.

PROCEDURE p_replica_hist:
    /* Objetivo: replicar o historico ja cadastrado para todas as cooperativas*/

    DEFINE BUFFER bf-craphis FOR craphis.
    DEFINE BUFFER bf-crapthi FOR crapthi.

    IF NOT AVAILABLE craphis THEN
        RETURN "NOK".

    DO  ON ERROR UNDO, LEAVE:

        /* copia o historico das taxas */
        EMPTY TEMP-TABLE tt-crapthi.
        FOR EACH crapthi WHERE
                 crapthi.cdcooper = glb_cdcooper AND
                 crapthi.cdhistor = craphis.cdhistor EXCLUSIVE-LOCK:
            CREATE tt-crapthi.
            BUFFER-COPY crapthi TO tt-crapthi.
        END.

        FOR EACH crapcop FIELDS (cdcooper) NO-LOCK:

            IF crapcop.cdcooper = glb_cdcooper THEN
               NEXT.

            FIND bf-craphis WHERE 
                 bf-craphis.cdcooper = crapcop.cdcooper AND 
                 bf-craphis.cdhistor = craphis.cdhistor EXCLUSIVE-LOCK NO-ERROR.
            IF NOT AVAILABLE bf-craphis THEN
               CREATE bf-craphis.

            BUFFER-COPY craphis EXCEPT cdcooper TO bf-craphis
                ASSIGN bf-craphis.cdcooper  = crapcop.cdcooper.

            /* cria o historico das taxas */
            FOR EACH tt-crapthi:
                FIND bf-crapthi WHERE
                     bf-crapthi.cdcooper = crapcop.cdcooper AND
                     bf-crapthi.cdhistor = tt-crapthi.cdhistor AND
                     bf-crapthi.dsorigem = tt-crapthi.dsorigem EXCLUSIVE-LOCK NO-ERROR.
                IF NOT AVAILABLE bf-crapthi THEN 
                   DO:
                        CREATE bf-crapthi.
                        ASSIGN bf-crapthi.cdcooper = crapcop.cdcooper
                               bf-crapthi.cdhistor = tt-crapthi.cdhistor  
                               bf-crapthi.dsorigem = tt-crapthi.dsorigem.

                   END.
                ASSIGN bf-crapthi.vltarifa = tt-crapthi.vltarifa.
            END.
            RELEASE bf-craphis.
        END.
    END.

    RETURN "OK".

END PROCEDURE.


PROCEDURE gera_item_log:

   IF CAPS(tel_dshistor) <> CAPS(log_dshistor) THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Historico",
                    INPUT CAPS(log_dshistor),
                    INPUT CAPS(tel_dshistor)).

   IF tel_indebcre <> log_indebcre THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Indicador de D/C",
                    INPUT log_indebcre,
                    INPUT tel_indebcre).

   IF tel_tplotmov <> log_tplotmov THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Tipo do lote",
                    INPUT STRING(log_tplotmov),
                    INPUT STRING(tel_tplotmov)).

   IF tel_inhistor <> log_inhistor THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Ind. Funcao",
                    INPUT STRING(log_inhistor),
                    INPUT STRING(tel_inhistor)).

   IF tel_dsexthst <> log_dsexthst THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Descricao extensa",
                    INPUT log_dsexthst,
                    INPUT tel_dsexthst).

   IF TRIM(CAPS(tel_nmestrut)) <> TRIM(CAPS(log_nmestrut)) THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Nome da estrutura",
                    INPUT TRIM(CAPS(log_nmestrut)),
                    INPUT TRIM(CAPS(tel_nmestrut))).

   IF tel_cdhstctb <> log_cdhstctb THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Historico contabilidade",
                    INPUT STRING(log_cdhstctb),
                    INPUT STRING(tel_cdhstctb)).

   IF tel_indoipmf <> log_indoipmf THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Indicador de incidencia IPMF",
                    INPUT STRING(log_indoipmf),
                    INPUT STRING(tel_indoipmf)).

   IF tel_inclasse <> log_inclasse THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Classe CPMF",
                    INPUT STRING(log_inclasse),
                    INPUT STRING(tel_inclasse)).

   IF tel_inautori <> log_inautori THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Ind. p/autorizacao debito",
                    INPUT STRING(log_inautori),
                    INPUT STRING(tel_inautori)).

   IF tel_inavisar <> log_inavisar THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Ind. de aviso p/debito",
                    INPUT STRING(log_inavisar),
                    INPUT STRING(tel_inavisar)).

   IF tel_indcompl <> log_indcompl THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Indicador de Complemento",
                    INPUT STRING(log_indcompl),   
                    INPUT STRING(tel_indcompl)).
   
   IF tel_indebcta <> log_indebcta THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Ind. debito em conta",
                    INPUT STRING(log_indebcta),
                    INPUT STRING(tel_indebcta)).

   IF tel_incremes <> log_incremes THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Ind. p/estat. credito do mes",
                    INPUT STRING(log_incremes),
                    INPUT STRING(tel_incremes)).

   IF tel_tpctbcxa <> log_tpctbcxa THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Tipo contab. caixa",
                    INPUT STRING(log_tpctbcxa),
                    INPUT STRING(tel_tpctbcxa)).
       
    IF aux_vltarayl <> log_vltarayl THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Tarifa Ayllos",
                    INPUT STRING(log_vltarayl,"zzz,zzz,zz9.99"),
                    INPUT STRING(aux_vltarayl,"zzz,zzz,zz9.99")).

   IF aux_vltarcxo <> log_vltarcxo THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Tarifa Caixa",
                    INPUT STRING(log_vltarcxo,"zzz,zzz,zz9.99"),
                    INPUT STRING(aux_vltarcxo,"zzz,zzz,zz9.99")).

   IF aux_vltarint <> log_vltarint THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Tarifa Internet",
                    INPUT STRING(log_vltarint,"zzz,zzz,zz9.99"),
                    INPUT STRING(aux_vltarint,"zzz,zzz,zz9.99")).

   IF aux_vltarcsh <> log_vltarcsh THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Tarifa Cash",
                    INPUT STRING(log_vltarcsh,"zzz,zzz,zz9.99"),
                    INPUT STRING(aux_vltarcsh,"zzz,zzz,zz9.99")).

   IF tel_tpctbccu <> log_tpctbccu THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Tipo de contab. centro custo",
                    INPUT STRING(log_tpctbccu),
                    INPUT STRING(tel_tpctbccu)).

   IF tel_nrctacrd <> log_nrctacrd THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Conta a creditar",
                    INPUT STRING(log_nrctacrd),
                    INPUT STRING(tel_nrctacrd)).

   IF tel_nrctadeb <> log_nrctadeb THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Conta a debitar",
                    INPUT STRING(log_nrctadeb),
                    INPUT STRING(tel_nrctadeb)).

   IF tel_ingercre <> log_ingercre THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Gerencial a Credito",
                    INPUT STRING(log_ingercre),
                    INPUT STRING(tel_ingercre)).

   IF tel_ingerdeb <> log_ingerdeb THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Gerencial a Debito",
                    INPUT STRING(log_ingerdeb),
                    INPUT STRING(tel_ingerdeb)).

   IF tel_nrctatrc <> log_nrctatrc THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Conta Tarifa Credito",
                    INPUT STRING(log_nrctatrc),
                    INPUT STRING(tel_nrctatrc)).

   IF tel_nrctatrd <> log_nrctatrd THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Conta Tarifa Debito",
                    INPUT STRING(log_nrctatrd),
                    INPUT STRING(tel_nrctatrd)).

   IF tel_flgsenha <> log_flgsenha THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Solicitar Senha",
                    INPUT (IF log_flgsenha = TRUE THEN
                              "Sim" 
                           ELSE
                              "Nao"), 
                    INPUT (IF tel_flgsenha = TRUE THEN
                              "Sim"
                           ELSE 
                              "Nao")).

   IF tel_cdprodut <> log_cdprodut THEN
       RUN gera_log (INPUT tel_cdhistor,
                     INPUT "Codigo Produto",
                     INPUT STRING(log_cdprodut),
                     INPUT STRING(tel_cdprodut)).

   IF tel_cdagrupa <> log_cdagrupa THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Codigo Agrupamento",
                    INPUT STRING(log_cdagrupa),
                    INPUT STRING(tel_cdagrupa)).

   IF tel_indebfol <> log_indebfol THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Ind. debito em folha",
                    INPUT STRING(log_indebfol),
                    INPUT STRING(tel_indebfol)).

   IF tel_txdoipmf <> log_txdoipmf THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Aliquota do IPMF",
                    INPUT STRING(log_txdoipmf),
                    INPUT STRING(tel_txdoipmf)).

   IF tel_dsextrat  <> log_dsextrat  THEN
      RUN gera_log (INPUT tel_cdhistor,
                    INPUT "Descricao Extrato",
                    INPUT STRING(log_dsextrat),
                    INPUT STRING(tel_dsextrat)).

END PROCEDURE. /* Fim da procedure gera_item_log */


PROCEDURE gera_log:
                       
   DEF INPUT PARAM par_cdhistor AS INT  NO-UNDO.
   DEF INPUT PARAM par_dsdcampo AS CHAR NO-UNDO.
   DEF INPUT PARAM par_vlrantes AS CHAR NO-UNDO.
   DEF INPUT PARAM par_vlrdepoi AS CHAR NO-UNDO.

   UNIX SILENT VALUE("echo "                                       +
                     STRING(TODAY,"99/99/9999") + " "              +
                     STRING(TIME,"HH:MM:SS") + " - "               +
                     "Operador " + glb_cdoperad + " - "            +
                     "Alterou o historico de código "              + 
                     STRING(par_cdhistor) + ". "                   +
                     " Campo " + par_dsdcampo + " de "             +
                     par_vlrantes + " para " + par_vlrdepoi + "."  +
                     " >> log/histor.log").


END PROCEDURE. /* Fim da procedure gera_log */
