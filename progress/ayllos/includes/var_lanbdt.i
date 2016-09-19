/* .............................................................................

   Programa: Includes/var_lanbdt.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Guilherme
   Data    : Setembro/2008.                  Ultima atualizacao: 10/03/2016

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criar variaveis e forms para a tela lanbdt.

   Alteracoes: 30/06/2009 - Incluida opcao "A" (Guilherme).
    
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 
                            
               09/07/2012 - Inclusão da variável 'tel_tpcobran' 
                            para armazenar Tipo de Cobrança 
                          - Inclusão do frame f_lanbdt_e para a
                            exclusão do Borderô inteiro (Lucas).
                            
               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).
               
               16/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)

               02/12/2014 - De acordo com a circula 3.656 do Banco Central, substituir nomenclaturas 
                            Cedente por Beneficiário e  Sacado por Pagador 
                            Chamado 229313 (Jean Reddiga - RKAM).    
                            
               11/05/2015 - #278936 Inclusao de filtro por nome do pagador
                            (Carlos)

			   10/03/2016 - Adicionado mais uma posicao para a coluna de boleto
							e removido um da coluna de pagador para resolver o problema
							relatado no chamado 404099 (Kelvin).
                           
............................................................................. */

DEF {1} SHARED VAR tel_dtmvtolt AS DATE    FORMAT "99/99/9999"          NO-UNDO.
DEF {1} SHARED VAR tel_cdagenci AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_cdbccxlt AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_nrdolote AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_qtinfoln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_vlinfodb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_vlinfocr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_qtcompln AS INT     FORMAT "zz,zz9"              NO-UNDO.
DEF {1} SHARED VAR tel_vlcompdb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_vlcompcr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99"  NO-UNDO.
DEF {1} SHARED VAR tel_qtdifeln AS INT     FORMAT "zz,zz9-"             NO-UNDO.
DEF {1} SHARED VAR tel_vldifedb AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_vldifecr AS DECIMAL FORMAT "zzz,zzz,zzz,zz9.99-" NO-UNDO.
DEF {1} SHARED VAR tel_nmdopaga AS CHAR    FORMAT "x(27)"               NO-UNDO.

DEF {1} SHARED VAR tel_nrborder AS INT     FORMAT "zzz,zz9"             NO-UNDO.
DEF {1} SHARED VAR tel_nrcustod AS INT     FORMAT "zzzz,zzz,9"          NO-UNDO.
DEF {1} SHARED VAR tel_nmcustod AS CHAR    FORMAT "x(33)"               NO-UNDO.
DEF {1} SHARED VAR aux_cddopcao AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR tel_tpcobran AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_tpcobran AS CHAR                                 NO-UNDO.

DEF {1} SHARED VAR aux_confirma AS CHAR    FORMAT "!(1)"                NO-UNDO.

DEF {1} SHARED VAR aux_contador AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdconta AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdctabb AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_nrdocmto AS INT                                  NO-UNDO.

DEF {1} SHARED VAR tab_qtdiamin AS INT                                  NO-UNDO.
DEF {1} SHARED VAR tab_qtdiamax AS INT                                  NO-UNDO.
DEF {1} SHARED VAR tab_qtrenova AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_ultlinha AS INT                                  NO-UNDO.

DEF {1} SHARED FRAME f_lanbdt.

FORM SPACE(1) WITH ROW 4 OVERLAY 16 DOWN WIDTH 80
                   TITLE glb_tldatela FRAME f_moldura.

DEF QUERY q_browse FOR tt-titulos.

DEF BROWSE b_browse QUERY q_browse
    DISPLAY tt-titulos.nrcnvcob COLUMN-LABEL "Convenio"
            tt-titulos.nrdocmto COLUMN-LABEL "Boleto"     FORMAT "zzzzzzz9" 
            tt-titulos.dsdoccop COLUMN-LABEL "Nro.Doc."   FORMAT "x(14)"
            tt-titulos.nmdsacad COLUMN-LABEL "Pagador"    FORMAT "x(17)"
            tt-titulos.dtvencto COLUMN-LABEL "Dt.Vencto"
            tt-titulos.vltitulo COLUMN-LABEL "Vlr.Titulo" FORMAT "zzz,zz9.99"
            tt-titulos.nrinssac COLUMN-LABEL "CPF/CNPJ"   
            tt-titulos.dssittit COLUMN-LABEL "Situacao"
            WITH 5 DOWN NO-BOX WITH WIDTH 76.      

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                  HELP "Informe a opcao desejada (A, C, E, I ou R)"
                        VALIDATE(CAN-DO("A,C,E,I,R",glb_cddopcao),
                                 "014 - Opcao errada.")

     tel_dtmvtolt AT 12 LABEL "Data"
     tel_cdagenci AT 31 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o codigo do PA."
                        VALIDATE(CAN-FIND(crapage WHERE 
                                          crapage.cdcooper = glb_cdcooper AND
                                          crapage.cdagenci = tel_cdagenci),
                                          "962 - PA nao cadastrado.")

     tel_cdbccxlt AT 47 LABEL "Banco/Caixa" AUTO-RETURN
                        HELP "Entre com o codigo do Banco/Caixa."
                        VALIDATE(CAN-FIND(crapbcl WHERE 
                                          crapbcl.cdbccxlt = tel_cdbccxlt),
                                          "057 - Banco nao cadastrado.")

     tel_nrdolote AT 65 LABEL "Lote" AUTO-RETURN
                        HELP "Entre com o numero do lote."
                        VALIDATE(tel_nrdolote > 0,
                                "058 - Numero do lote errado.")
     SKIP
     tel_qtinfoln AT  2 LABEL "Informado:Qtd"
     tel_vlinfodb AT 24 LABEL "Debito"
     tel_vlinfocr AT 51 LABEL "Credito"
     SKIP
     tel_qtcompln AT  2 LABEL "Computado:Qtd"
     tel_vlcompdb AT 24 LABEL "Debito"
     tel_vlcompcr AT 51 LABEL "Credito"
     SKIP
     tel_qtdifeln AT  2 LABEL "Diferenca:Qtd"
     tel_vldifedb AT 24 LABEL "Debito"
     tel_vldifecr AT 51 LABEL "Credito"
     SKIP(1)
     tel_nrcustod AT  2 LABEL "Conta/dv"   
                        HELP "Entre com a conta do associado."
                        VALIDATE(tel_nrcustod > 0,
                                 "127 - Conta errada.")
     "-" tel_nmcustod AT 25 NO-LABEL

     tel_nrborder AT 59 LABEL "Bordero" FORMAT "zzzz,zzz,9"
     SKIP
     tel_tpcobran AT 2 LABEL "Tipo de cobranca"
                        FORMAT "X(12)"
                        VALIDATE(CAN-DO("SEM REGISTRO,REGISTRADA,TODOS",tel_tpcobran),
                                "014 - Opcao errada.")

     tel_nmdopaga AT 33 LABEL "Nome do pagador" 

     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_lanbdt.

DEF FRAME f_browse
          b_browse 
    HELP "Utilize as <SETAS> p/ navegar."
    WITH CENTERED OVERLAY ROW 13.
    
FORM "Deseja excluir o bordero inteiro? " AT 5
     aux_confirma AT 40 NO-LABEL
     WITH ROW 11 COLUMN 17 OVERLAY WIDTH 45 SIDE-LABELS FRAME f_lanbdt_e.

/* ......................................................................... */


