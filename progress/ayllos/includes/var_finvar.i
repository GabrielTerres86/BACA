/* ..........................................................................

   Programa: Includes/var_finvar.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : Novembro/2003                   Ultima atualizacao:  03/01/2008

   Dados referentes ao programa:

   Frequencia: Diario (On-line)
   Objetivo  : Criar as variaveis compartilhadas para o on_line.

   Alteracoes: 04/06/2004 - Incluir campo total dos valores (Ze Eduardo).
               28/02/2005 - Incluido opcao "T"(Mirtes).

               24/01/2006 - Unificacao dos bancos - SQLWorks - Luciane.

               06/02/2006 - Incluida opcao NO-UNDO na TEMP-TABLE workapl
                            SQLWorks - Fernando.

               03/01/2008 - Permitir lancamentos em 31/12/2007 (Magui).
............................................................................. */

DEF {1} SHARED VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"         NO-UNDO.
DEF {1} SHARED VAR tel_dtduplic AS DATE    FORMAT "99/99/9999"         NO-UNDO.

DEF {1} SHARED VAR tel_nrsequen AS INT     FORMAT "zz9"                NO-UNDO.
DEF {1} SHARED VAR tel_cdbccxlt AS INT     FORMAT "zzz9"               NO-UNDO.
DEF {1} SHARED VAR tel_descapli AS CHAR    FORMAT "x(30)"              NO-UNDO.
DEF {1} SHARED VAR tel_dtdpagto AS DATE    FORMAT "99/99/9999"         NO-UNDO.
DEF {1} SHARED VAR tel_vllanmto AS DEC     FORMAT "zzz,zzz,zz9.99"     NO-UNDO.
DEF {1} SHARED VAR tel_txaplica LIKE craptxr.txaplica                  NO-UNDO.

DEF {1} SHARED VAR tel_altlacto AS CHAR    FORMAT "x(07)"        
                                   INIT "Alterar"                      NO-UNDO.
DEF {1} SHARED VAR tel_conlacto AS CHAR    FORMAT "x(09)"   
                                   INIT "Consultar"                    NO-UNDO.

DEF {1} SHARED VAR tel_exclacto AS CHAR    FORMAT "x(07)"             
                                   INIT "Excluir"                      NO-UNDO.
DEF {1} SHARED VAR tel_inclacto AS CHAR    FORMAT "x(07)"             
                                   INIT "Incluir"                      NO-UNDO.

DEF {1} SHARED VAR tel_totvlmto AS DECIMAL                             NO-UNDO.

DEF            VAR aux_cddopcao AS CHAR                                NO-UNDO.
DEF            VAR aux_flgretor AS LOG                                 NO-UNDO.
DEF            VAR aux_confirma AS LOGICAL FORMAT "Sim/Nao"            NO-UNDO.
DEF            VAR aux_mensagem AS CHAR    FORMAT "x(50)"              NO-UNDO.
DEF            VAR aux_flgfecha AS LOG     FORMAT "S/N"                NO-UNDO.
DEF            VAR aux_cancllan AS CHAR    FORMAT "!"                  NO-UNDO.
DEF            VAR aux_flgalter AS LOG                                 NO-UNDO.
DEF            VAR aux_txprodia AS DEC DECIMALS 6                      NO-UNDO.
DEF            VAR aux_vllanmto AS DEC                                 NO-UNDO.
DEF            VAR aux_vlrjuros AS DEC                                 NO-UNDO.
DEF            VAR aux_vltotjur AS DEC                                 NO-UNDO.
DEF            VAR aux_qtdedias AS INTE                                NO-UNDO.
DEF            VAR aux_dtcalcul AS DATE                                NO-UNDO.

DEF BUFFER crabvar FOR crapvar.

DEF TEMP-TABLE workapl                                                 NO-UNDO 
    FIELD nrsequen AS INTE
    FIELD cdbccxlt AS INTE
    FIELD descapli AS CHAR
    FIELD dtmvtolt AS DATE
    FIELD dtdpagto AS DATE
    FIELD vllanmto AS DEC FORMAT "zzz,zzz,zz9.99"
    FIELD txaplica LIKE craptxr.txaplica
    INDEX ch-workapl AS UNIQUE PRIMARY
          dtmvtolt
          nrsequen.

FORM SPACE(1) WITH ROW 4 COLUMN 1 OVERLAY 16 DOWN WIDTH 80
                      TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (C, D, F, L ou T)"
                        VALIDATE (glb_cddopcao = "C" OR 
                                  glb_cddopcao = "F" OR
                                  glb_cddopcao = "D" OR
                                  glb_cddopcao = "L" OR
                                  glb_cddopcao = "T","014 - Opcao errada.")

     tel_dtmvtolt AT 17 LABEL "Data"
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.

FORM tel_dtduplic AT 1  LABEL "Copiar da Data"
                        HELP "Informe para qual dia sera feita a copia"
     WITH ROW 6 COLUMN 37 OVERLAY SIDE-LABELS NO-BOX FRAME f_copiardata.
                             
FORM tel_totvlmto AT 1 FORMAT "zzzz,zzz,zzz,zz9.99" LABEL "Total"
     WITH ROW 6 COLUMN 37 OVERLAY SIDE-LABELS NO-BOX FRAME f_valortotal.

     
FORM WITH ROW 7 OVERLAY 13 DOWN WIDTH 78 CENTERED
                TITLE " APLICACAOES FINANCEIRAS " FRAME f_moldura_extra.

FORM WITH ROW 7 OVERLAY 13 DOWN WIDTH 78 CENTERED
                TITLE " APLICACOES FINANCEIRAS " FRAME f_moldura_especial.

FORM tel_nrsequen AT 3  LABEL "Sequencia"
                        HELP "Entre com a sequencia do lancamento." 
     SKIP(1)
     tel_cdbccxlt AT 3  LABEL "    Banco"
                        HELP "Entre com o codigo do banco"
                        VALIDATE (tel_cdbccxlt <> 0,
                                  "375 - O campo deve ser informado")
     tel_descapli AT 3  LABEL "Aplicacao"
                        HELP "Entre com o tipo de aplicacao"
                        VALIDATE(tel_descapli <> "",
                                 "375 - O campo deve ser informado")
     SKIP(1)
     tel_dtdpagto AT 2  LABEL "Vencimento"
                        HELP "Entre com a data de vencimento da aplicacao."
                        VALIDATE(tel_dtdpagto > tel_dtmvtolt AND
                                 NOT CAN-DO("1,7",
                                     STRING(WEEKDAY(tel_dtdpagto))) AND
                                 NOT CAN-FIND(crapfer WHERE 
                                        crapfer.cdcooper = glb_cdcooper AND
                                        crapfer.dtferiad = tel_dtdpagto AND
                                        crapfer.dtferiad <> 12/31/2007),
                                 "013 - Data errada.")
     tel_vllanmto AT 3  LABEL "    Valor"
                        HELP "Entre com o valor do documento."
                        VALIDATE(tel_vllanmto <> 0,
                                 "091 - Valor do lancamento errado") 
     SKIP(1)
     tel_txaplica AT 3  LABEL "     Taxa"
                        HELP "Entre com o valor da taxa."
     SKIP(2)      
     tel_altlacto AT 16 
     SPACE(3)
     tel_conlacto       
     SPACE(3)
     tel_exclacto       
     SPACE(3)
     tel_inclacto       
     WITH ROW 9 OVERLAY NO-LABELS SIDE-LABELS COLUMN 4 NO-BOX FRAME f_aplicacao.


FORM tel_nrsequen AT 3  LABEL "Sequencia"
                        HELP "Entre com a sequencia do lancamento." 
     SKIP(1)
     tel_cdbccxlt AT 3  LABEL "    Banco"
                        HELP "Entre com o codigo do banco"
                        VALIDATE (tel_cdbccxlt <> 0,
                                  "375 - O campo deve ser informado")
     tel_descapli AT 3  LABEL "Aplicacao"
                        HELP "Entre com o tipo de aplicacao"
                        VALIDATE(tel_descapli <> "",
                                 "375 - O campo deve ser informado")
     SKIP(1)
     tel_dtdpagto AT 3  LABEL "Vecimento"
                        HELP "Entre com a data de vencimento da aplicacao."
                        VALIDATE(tel_dtdpagto > tel_dtmvtolt AND
                                 NOT CAN-DO("1,7",
                                     STRING(WEEKDAY(tel_dtdpagto))) AND
                                 NOT CAN-FIND(crapfer WHERE 
                                        crapfer.cdcooper = glb_cdcooper AND
                                        crapfer.dtferiad = tel_dtdpagto AND
                                        crapfer.dtferiad <> 12/31/2007),
                                 "013 - Data errada.")
     tel_vllanmto AT 3  LABEL "    Valor"
                        HELP "Entre com o valor do documento."
                        VALIDATE(tel_vllanmto <> 0,
                                 "091 - Valor do lancamento errado") 
     SKIP(1)
     tel_txaplica AT 3  LABEL "     Taxa"
                        HELP "Entre com o valor da taxa."
     SKIP(2)                   
     WITH ROW 9 OVERLAY NO-LABELS SIDE-LABELS CENTERED 
          FRAME f_manutencao.

/* variaveis para mostrar os lancamentos a alterar */          
DEF QUERY  bworkapla-q FOR workapl. 
DEF BROWSE bworkapla-b QUERY bworkapla-q
      DISP nrsequen                            COLUMN-LABEL "Seq"
           cdbccxlt        FORMAT "zzz9"       COLUMN-LABEL "Banco"
           descapli        FORMAT "x(18)"      COLUMN-LABEL "Aplicacao"
           dtdpagto        FORMAT "99/99/9999" COLUMN-LABEL "Vencto"
           vllanmto                            COLUMN-LABEL "Valor"
           txaplica                            COLUMN-LABEL "Taxa"
           WITH 11 DOWN OVERLAY.    

DEF BUTTON btn-alterar  LABEL "Alterar".
DEF BUTTON btn-excluir  LABEL "Excluir".
DEF BUTTON btn-sair1    LABEL "Sair".
DEF BUTTON btn-sair2    LABEL "Sair".    

DEF FRAME f_alterar
          bworkapla-b HELP "Use <TAB> para navegar" SKIP 
          SPACE(1)
          btn-alterar HELP "Use <TAB> para navegar" 
          SPACE(1)
          btn-sair1 HELP "Use <TAB> para navegar"
          WITH NO-BOX CENTERED OVERLAY ROW 7.

/***************************************************/

/* tela para mostrar os lancamentos a excluir */
DEF QUERY  bworkaple-q FOR workapl. 
DEF BROWSE bworkaple-b QUERY bworkaple-q
      DISP nrsequen                            COLUMN-LABEL "Seq"
           cdbccxlt        FORMAT "zzz9"       COLUMN-LABEL "Banco"
           descapli        FORMAT "x(18)"      COLUMN-LABEL "Aplicacao"
           dtdpagto        FORMAT "99/99/9999" COLUMN-LABEL "Vencto"
           vllanmto                            COLUMN-LABEL "Valor"
           txaplica                            COLUMN-LABEL "Taxa"
           WITH 11 DOWN OVERLAY.    

DEF FRAME f_excluir
          bworkaple-b HELP "Use <TAB> para navegar" SKIP 
          SPACE(1)
          btn-excluir HELP "Use <TAB> para navegar" 
          SPACE(1)
          btn-sair2 HELP "Use <TAB> para navegar"
          WITH NO-BOX CENTERED OVERLAY ROW 7.
/***********************************************/

/* tela para mostrar os lancamentos a consultar */
DEF QUERY  bworkaplc-q FOR workapl. 
DEF BROWSE bworkaplc-b QUERY bworkaplc-q
      DISP nrsequen                            COLUMN-LABEL "Seq"
           cdbccxlt        FORMAT "zzz9"       COLUMN-LABEL "Banco"
           descapli        FORMAT "x(18)"      COLUMN-LABEL "Aplicacao"
           dtdpagto        FORMAT "99/99/9999" COLUMN-LABEL "Vencto"
           vllanmto                            COLUMN-LABEL "Valor"
           txaplica                            COLUMN-LABEL "Taxa"
           WITH 11 DOWN OVERLAY.    

DEF FRAME f_consultar
          bworkaplc-b HELP "Use <TAB> para navegar" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7.
/***********************************************/

/* variaveis para mostrar a consulta da tela principal */          
 
DEF QUERY  blistafin-q FOR workapl.
DEF BROWSE blistafin-b QUERY blistafin-q
     DISP nrsequen                            COLUMN-LABEL "Seq"
          cdbccxlt        FORMAT "zzz9"       COLUMN-LABEL "Banco"
          descapli        FORMAT "x(18)"      COLUMN-LABEL "Aplicacao"
          dtdpagto        FORMAT "99/99/9999" COLUMN-LABEL "Vencto"
          vllanmto                            COLUMN-LABEL "Valor"
          txaplica                            COLUMN-LABEL "Taxa"
          WITH 10 DOWN OVERLAY.    

DEF FRAME f_listafinc
          blistafin-b HELP "Use as SETAS para navegar e <F4> para sair" SKIP 
          WITH NO-BOX CENTERED OVERLAY ROW 7.
/**********************************************/

/* .......................................................................... */

