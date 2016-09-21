/* ..........................................................................

   Programa: includes/var_bcaixa.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete/Planner
   Data    : Fevereiro/2001                  Ultima atualizacao: 18/02/2015

   Dados referentes ao programa:

   Frequencia: Diario (On-line)
   Objetivo  : Criar as variaveis compartilhadas para o on_line.

   Alteracoes: 20/12/2002 - Implementar a visualizacao da fita de caixa (Edson)
   
               22/08/2003 - Nao deixar fechar se nao houve o registro
                            das movimentacoes em especie (Margarete).

               06/10/2004 - Diferenca de caixa so coordenador (Margarete).

               24/01/2006 - Unificacao dos Bancos - SQLWorks - Luciane.

               26/03/2007 - Apontar diferenca entre o boletim e a fita de caixa
                            mesmo com o caixa aberto (Magui).
                            
               09/06/2008 - Incluído a chave de acesso (craphis.cdcooper = 
                            glb_cdcooper) no "CAN-FIND" da tabela CRAPHIS. 
                          - Kbase IT Solutions - Paulo Ricardo Maciel.
                          
               14/07/2009 - Alteracao CDOPERAD (Diego).
               
               23/11/2009 - Alteracao Codigo Historico (Kbase).
               
               15/04/2011 - Variaveis e evento para a opcao T - Consulta de 
                            saldo na tela (GATI - Diego)
                            
               31/10/2011 - Chamada da include da BO 120.(Gabriel Capoia - DB1)
               19/12/2011 - Incluido BROWSE no lugar do campo EDITOR na parte de 
                            gera fita caixa (Tiago)
                            
               19/04/2013 - Incluir novo frame f_caicof para opcao T (Lucas R).
               
               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).
               
               28/08/2013 - Criado o campo dtrefere para a opcao T (Carlos)
               
               18/02/2015 - Incluir opcao TOTAL na variavel tel_tpcaicof 
                            (Lucas R. #245838)
............................................................................ */
                                                    
{ sistema/generico/includes/b1wgen0120tt.i }          

DEF {1} SHARED VAR ant_nrdlacre AS INT     FORMAT "z,zzz,zz9"          NO-UNDO.
DEF {1} SHARED VAR aux_nrseqdig AS INT                                 NO-UNDO.
DEF {1} SHARED VAR aux_vldsdfin LIKE crapbcx.vldsdfin                  NO-UNDO.
DEF {1} SHARED VAR aux_sdfinbol LIKE crapbcx.vldsdfin                  NO-UNDO.
DEF {1} SHARED VAR aux_recidbol AS RECID                               NO-UNDO.
DEF {1} SHARED VAR aux_tipconsu AS LOGI FORMAT "Visualizar/Imprimir"   NO-UNDO.
DEF {1} SHARED VAR aux_nmarqimp AS CHAR                                NO-UNDO.

DEF {1} SHARED VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"         NO-UNDO.
DEF {1} SHARED VAR tel_cdagenci AS INT     FORMAT "zz9"                NO-UNDO.
DEF {1} SHARED VAR tel_nrdcaixa AS INT     FORMAT "zz9"                NO-UNDO.
DEF {1} SHARED VAR tel_dtrefere AS DATE    FORMAT "99/99/9999"         NO-UNDO.

DEF {1} SHARED VAR tel_cdopecxa AS CHAR    FORMAT "x(10)"              NO-UNDO.
DEF {1} SHARED VAR tel_nrdmaqui AS INT     FORMAT "zz9"                NO-UNDO.
DEF {1} SHARED VAR tel_qtautent AS INT     FORMAT "z,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_nrdlacre AS INT     FORMAT "z,zzz,zz9"          NO-UNDO.
DEF {1} SHARED VAR tel_vldsdini AS DECIMAL FORMAT "zzz,zzz,zz9.99-"    NO-UNDO.
DEF {1} SHARED VAR tel_vldentra AS DECIMAL FORMAT "zzz,zzz,zz9.99"     NO-UNDO.
DEF {1} SHARED VAR tel_vldsaida AS DECIMAL FORMAT "zzz,zzz,zz9.99"     NO-UNDO.
DEF {1} SHARED VAR tel_vldsdfin AS DECIMAL FORMAT "zzz,zzz,zz9.99-"    NO-UNDO.
DEF {1} SHARED VAR tel_visualiz AS CHAR    FORMAT "x(10)" INIT "Visualizar"
                                                                       NO-UNDO.
DEF {1} SHARED VAR tel_imprimir AS CHAR    FORMAT "x(08)" INIT "Imprimir"  
                                                                       NO-UNDO.
                                                                       
DEF {1} SHARED VAR tel_cdhistor AS INT     FORMAT "9999"               NO-UNDO.
DEF {1} SHARED VAR tel_dsdcompl AS CHAR    FORMAT "x(30)"              NO-UNDO.
DEF {1} SHARED VAR tel_nrdocmto AS INT     FORMAT "zzz,zz9"            NO-UNDO.
DEF {1} SHARED VAR tel_vldocmto AS DEC     FORMAT "zzz,zzz,zz9.99"     NO-UNDO.
DEF {1} SHARED VAR tel_nrseqdig AS INT     FORMAT "zz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_altlacto AS CHAR    FORMAT "x(07)"        
                                   INIT "Alterar"                      NO-UNDO.
DEF {1} SHARED VAR tel_conlacto AS CHAR    FORMAT "x(09)"   
                                   INIT "Consultar"                    NO-UNDO.

DEF {1} SHARED VAR tel_exclacto AS CHAR    FORMAT "x(07)"             
                                   INIT "Excluir"                      NO-UNDO.
DEF {1} SHARED VAR tel_inclacto AS CHAR    FORMAT "x(07)"             
                                   INIT "Incluir"                      NO-UNDO.

DEF {1} SHARED VAR aux_vlrttcrd AS DECI    FORMAT "zzz,zzz,zz9.99-"    NO-UNDO.
DEF {1} SHARED VAR aux_vlrttdeb AS DECI    FORMAT "zzz,zzz,zz9.99-"    NO-UNDO.
DEF {1} SHARED VAR aux_flgsemhi AS LOG                                 NO-UNDO.
DEF {1} SHARED VAR aux_dshistor AS CHAR                                NO-UNDO.

DEF            VAR aux_cddopcao AS CHAR                                NO-UNDO.
DEF            VAR aux_flgretor AS LOG                                 NO-UNDO.
DEF            VAR aux_confirma AS LOGICAL FORMAT "Sim/Nao"            NO-UNDO.
DEF            VAR aux_flgfecha AS LOGICAL FORMAT "Sim/Nao"            NO-UNDO.
DEF            VAR aux_flgreabr AS LOGICAL FORMAT "Sim/Nao"            NO-UNDO.
DEF            VAR aux_flgdocto AS LOGICAL FORMAT "Sim/Nao"            NO-UNDO.
DEF            VAR aux_vlrcalcu AS DECIMAL FORMAT "zzz,zzz,zz9.99-"    NO-UNDO.
DEF            VAR aux_vlrdifer AS DECIMAL FORMAT "zzz,zzz,zz9.99-"    NO-UNDO.
DEF            VAR aux_mensagem AS CHAR    FORMAT "x(50)"              NO-UNDO.
DEF            VAR aux_nrctadeb AS INTE    FORMAT "9999"               NO-UNDO.
DEF            VAR aux_nrctacrd AS INTE    FORMAT "9999"               NO-UNDO.
DEF            VAR aux_cdhistor AS INTE    FORMAT "9999"               NO-UNDO.
DEF            VAR aux_vlctrmve AS DEC                                 NO-UNDO.
DEF            VAR aux_setlinha AS CHAR                                NO-UNDO.
DEF            VAR aux_nrsequen AS INT     INITIAL 0                   NO-UNDO.
DEF            STREAM str_2.

DEF            VAR aux_tpimprim AS LOGICAL FORMAT "T/I"    NO-UNDO.

DEF {1} SHARED VAR aut_flgsenha AS LOGICAL                             NO-UNDO.
DEF {1} SHARED VAR aut_cdoperad AS CHAR                                NO-UNDO.

/* variaveis para mostrar saldo em tela - funcao "T" */          
DEF            VAR tot_saldot   AS DECIMAL FORMAT "zzz,zzz,zz9.99-"  
                                           LABEL "TOTAL"               NO-UNDO.
DEF            VAR h-b1wgen0096 AS HANDLE                              NO-UNDO.
DEF            VAR h-b1wgen0120 AS HANDLE                              NO-UNDO.

DEF            VAR tel_tpcaicof AS CHAR FORMAT "x(5)"
                   VIEW-AS COMBO-BOX LIST-ITEMS "CAIXA",
                                                "COFRE",
                                                "TOTAL"
                                                PFCOLOR 2              NO-UNDO.
DEF            VAR tel_cddopcao AS CHAR FORMAT "x(1)"                  NO-UNDO.

DEF BUFFER crabbcx FOR crapbcx.
DEF BUFFER crabope FOR crapope.

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C, F, I, K, L, S ou T)"
                        VALIDATE (glb_cddopcao = "C" OR 
                                  glb_cddopcao = "F" OR
                                  glb_cddopcao = "I" OR
                                  glb_cddopcao = "K" OR
                                  glb_cddopcao = "L" OR
                                  glb_cddopcao = "S" OR 
                                  glb_cddopcao = "T" ,"014 - Opcao errada.")

     tel_dtmvtolt AT 14 LABEL "Data"
                                  
     tel_cdagenci AT 33 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o codigo do Posto de Atendimento."

     tel_nrdcaixa AT 44 LABEL "Caixa" AUTO-RETURN
                        HELP "Entre com o numero do Caixa."

     tel_cdopecxa AT 57 LABEL "Operador" AUTO-RETURN
                        HELP "Entre com o codigo do operador."
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM tel_cddopcao AT 2 LABEL "Opcao" AUTO-RETURN 

     tel_tpcaicof AT 14 LABEL "Tipo" AUTO-RETURN
                        HELP "Informe o Caixa/Cofre/Total."
     tel_cdagenci AT 33 LABEL "PA"
                        HELP "Entre com o codigo do Posto de Atendimento."
     tel_dtrefere AT 44 LABEL "Data"
                        HELP "Entre com a data de referencia."
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_caicof.

FORM tel_nrdmaqui AT 5  LABEL "Autenticadora"
                        HELP "Entre com o numero da autenticadora"
     tel_qtautent AT 27 LABEL "Qtd. Autenticacoes"
                        HELP "Entre com a quantidade de autenticacoes."
     tel_nrdlacre AT 55 LABEL "Lacre"
                        HELP "Entre com o numero do lacre"

     SKIP(1)
     tel_vldsdini AT 22 LABEL "Saldo Inicial"
                        HELP "Entre com o valor do saldo inicial" 
     SKIP(1)
     tel_vldentra AT 14 LABEL "Entradas/Recebimentos"
     tel_vldsaida AT 18 LABEL "Saidas/Pagamentos"
     
     SKIP(1)
     tel_vldsdfin AT 24 LABEL "Saldo Final"
                        HELP "Entre com o valor do saldo final"
     WITH ROW 8 COLUMN 2 OVERLAY NO-LABELS SIDE-LABELS NO-BOX FRAME f_bcaixa.

FORM WITH ROW 7 OVERLAY 13 DOWN WIDTH 78 CENTERED
                TITLE " Lancamentos Extra-Sistema " FRAME f_moldura_extra.

FORM WITH ROW 7 OVERLAY 13 DOWN WIDTH 78 CENTERED
                TITLE " Lancamentos Especiais " FRAME f_moldura_especial.

FORM tel_cdhistor AT 3  LABEL "Historico"
                        HELP "Entre com o codigo do historico"
     " - "
     aux_dshistor    FORMAT "X(29)"
     "- D" 
     aux_nrctadeb FORMAT "9999"
     "- C"
     aux_nrctacrd FORMAT "9999" 
     aux_cdhistor FORMAT "zzzz9"
     SKIP(1)
     tel_dsdcompl  LABEL "Complemento"
                       HELP "Entre com o complemento do historico"
     SKIP(1)                  
     tel_nrdocmto AT 3 LABEL "Documento"
                        HELP "Entre com o numero do documento."
     SKIP(1)                            
     tel_vldocmto AT 7 LABEL "Valor"
                        HELP "Entre com o valor do documento."

     SKIP(1)
     tel_nrseqdig AT 3 LABEL "Sequencia"
                        HELP "Entre com a sequencia do lancamento." 
     SKIP(2)
     tel_altlacto AT 16 
     SPACE(3)
     tel_conlacto       
     SPACE(3)
     tel_exclacto       
     SPACE(3)
     tel_inclacto       
     WITH ROW 9 OVERLAY NO-LABELS SIDE-LABELS COLUMN 4 NO-BOX FRAME f_extra.

DEF TEMP-TABLE w-histor NO-UNDO
    FIELD cdhistor LIKE craphis.cdhistor
    FIELD dshistor AS CHARACTER FORMAT "x(18)"
    FIELD dsdcompl AS CHARACTER FORMAT "x(50)"
    FIELD qtlanmto AS INTEGER
    FIELD vllanmto LIKE craplcm.vllanmto.
    
DEF TEMP-TABLE tt-linhfita NO-UNDO
    FIELD nrsequen AS INT     FORMAT "zzzz9"
    FIELD deslinha AS CHAR    FORMAT "x(128)"
    FIELD brancos  AS CHAR    FORMAT "x(1)"
    INDEX tt-linhfita1 nrsequen. 

DEF QUERY  q-linhfita FOR tt-linhfita.
DEF BROWSE b-linhfita QUERY q-linhfita
      DISP tt-linhfita.deslinha NO-LABEL 
           tt-linhfita.brancos  NO-LABEL
      WITH 15 DOWN WIDTH 76 OVERLAY NO-BOX SCROLLBAR-VERTICAL.

DEF QUERY  bcaixa-q FOR tt-boletimcx.

DEF BROWSE bcaixa-b QUERY bcaixa-q
      DISP tt-boletimcx.cdopecxa COLUMN-LABEL "Operador"
           tt-boletimcx.dshrabtb COLUMN-LABEL "Abertura"
           tt-boletimcx.dshrfecb COLUMN-LABEL "Fechamento"
           tt-boletimcx.vldsdini
           tt-boletimcx.vldsdfin
           WITH 8 DOWN OVERLAY.    

DEF BUTTON btn-visualiz LABEL "Visualizar".
DEF BUTTON btn-boletim  LABEL "Boletim".
DEF BUTTON btn-fitacx   LABEL "Fita de Caixa".
DEF BUTTON btn-impraber LABEL "Impr.Abertura".
DEF BUTTON btn-imprbole LABEL "Impr.Boletim".
DEF BUTTON btn-impfitcx LABEL "Impr.Fita Cx".
DEF BUTTON btn-impdepos LABEL "Impr.Deposito/Saque".
DEF BUTTON btn-sair     LABEL "Sair".
    
DEF FRAME f_boletim
          bcaixa-b HELP "Use <TAB> para navegar" SKIP 
          SPACE(10)
          btn-visualiz HELP "Use <TAB> para navegar" 
          SPACE(2)
          btn-impraber HELP "Use <TAB> para navegar"
          SPACE(2)
          btn-imprbole HELP "Use <TAB> para navegar" SKIP
          SPACE(13)
          btn-impfitcx HELP "Use <TAB> para navegar"
          SPACE(2)
          btn-impdepos HELP "Use <TAB> para navegar"
          SPACE(2)
          btn-sair HELP "Use <TAB> para navegar"
          WITH NO-BOX CENTERED OVERLAY ROW 7.

DEF FRAME f_visualizar
          SPACE(10)
          btn-boletim
          SPACE(3)
          btn-fitacx
          SPACE(10)
          WITH NO-BOX CENTERED OVERLAY ROW 12.

/**********************************************/

/* variaveis para a opcao visualizar */
DEF BUTTON btn-ok     LABEL "Sair".
DEF VAR edi_boletim   AS CHAR VIEW-AS EDITOR SIZE 80 BY 15
                     /* SCROLLBAR-VERTICAL  */ PFCOLOR 0.     

DEF FRAME fra_boletim 
    edi_boletim  HELP "Pressione <F4> ou <END> para finalizar" 
    WITH SIZE 76 BY 15 ROW 6 COLUMN 3 USE-TEXT NO-BOX NO-LABELS OVERLAY.

DEF VAR edi_fitacx    AS CHAR VIEW-AS EDITOR SIZE 132 BY 15
                     /* SCROLLBAR-VERTICAL  */ PFCOLOR 0.     

DEF FRAME fra_fitacx 
    edi_fitacx  HELP "Pressione <F4> ou <END> para finalizar" 
    WITH SIZE 76 BY 15 ROW 6 COLUMN 3 USE-TEXT NO-BOX NO-LABELS OVERLAY.

DEF FRAME fra_linhfita
    b-linhfita  HELP "Pressione <F4> ou <END> para finalizar" 
   WITH ROW 6 COLUMN 3 NO-BOX NO-LABELS OVERLAY.

/* variaveis para mostrar a consulta dos lancamentos */          
DEF QUERY  bcraplcx-q FOR tt-lanctos.

DEF BROWSE bcraplcx-b QUERY bcraplcx-q
      DISP tt-lanctos.cdhistor FORMAT "z999"  COLUMN-LABEL "His."
           tt-lanctos.dshistor FORMAT "x(24)" COLUMN-LABEL "Descricao"
           tt-lanctos.dsdcompl FORMAT "x(12)" COLUMN-LABEL "Complemento"
           tt-lanctos.nrdocmto                COLUMN-LABEL "Docto"
           tt-lanctos.vldocmto                COLUMN-LABEL "Valor"
           tt-lanctos.nrseqdig                COLUMN-LABEL "Seq"
           WITH 11 DOWN OVERLAY.

DEF FRAME f_lancamentos
          bcraplcx-b HELP "Pressione <F4> ou <END> para finalizar" 
          SKIP(1)
          WITH NO-BOX CENTERED OVERLAY ROW 7.
/* .......................................................................... */


