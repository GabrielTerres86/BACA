/* .............................................................................

   Programa: includes/var_ldesco.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Edson
   Data    : Marco/2003.                         Ultima atualizacao: 19/09/2008

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Definicao das variaveis e forms da tela LDESCO.

   Alteracoes: 19/09/2008 - Incluir todos os campos em um soh form e criado
                            campo Tipo de Desconto e a sua descricao (Gabriel).
                                                        
............................................................................. */

DEF {1} SHARED VAR tel_cddlinha AS INT     FORMAT "zz9"                 NO-UNDO.
DEF {1} SHARED VAR tel_dsdlinha AS CHAR    FORMAT "x(25)"               NO-UNDO.
DEF {1} SHARED VAR tel_dssitlcr AS CHAR    FORMAT "x(25)"               NO-UNDO.
DEF {1} SHARED VAR tel_indsaldo AS CHAR    FORMAT "x(01)"               NO-UNDO.
DEF {1} SHARED VAR tel_dsdsaldo AS CHAR    FORMAT "x(09)"               NO-UNDO.
DEF {1} SHARED VAR tel_insitlcr AS CHAR    FORMAT "x(01)"               NO-UNDO.
DEF {1} SHARED VAR tel_tpdescto AS CHAR    FORMAT "!"                   NO-UNDO.
DEF {1} SHARED VAR tel_dsdescto AS CHAR    FORMAT "x(15)"               NO-UNDO.

DEF {1} SHARED VAR tel_txjurmor AS DECIMAL FORMAT "zz9.999999"          NO-UNDO.
DEF {1} SHARED VAR tel_txmensal AS DECIMAL FORMAT "zz9.999999"          NO-UNDO.
DEF {1} SHARED VAR tel_txdiaria AS DECIMAL FORMAT "zz9.9999999"         NO-UNDO.
DEF {1} SHARED VAR tel_nrdevias AS INT     FORMAT "9"                   NO-UNDO.
DEF {1} SHARED VAR tel_flgtarif AS LOGICAL                              NO-UNDO.

DEF {1} SHARED VAR ant_txmensal AS DECIMAL DECIMALS 7                   NO-UNDO.

DEF {1} SHARED VAR aux_cddopcao AS CHAR                                 NO-UNDO.
DEF {1} SHARED VAR aux_confirma AS CHAR    FORMAT "x"                   NO-UNDO.

DEF {1} SHARED VAR aux_txbaspre AS DECIMAL                              NO-UNDO.
DEF {1} SHARED VAR aux_txutiliz AS DECIMAL                              NO-UNDO.

DEF {1} SHARED VAR aux_tentaler AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_contalcr AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_contador AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_contalin AS INT                                  NO-UNDO.
DEF {1} SHARED VAR aux_stimeout AS INT                                  NO-UNDO.

DEF {1} SHARED VAR aux_cdlcremp AS INT                                  NO-UNDO.

DEF {1} SHARED VAR aux_flgclear AS LOGICAL INIT TRUE                    NO-UNDO.

DEF {1} SHARED FRAME f_moldura.
DEF {1} SHARED FRAME f_ldesco.
DEF {1} SHARED FRAME f_descricao.

FORM SPACE(1)
     WITH ROW 4 OVERLAY 16 DOWN WIDTH 80 TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT 11 LABEL "Opcao" AUTO-RETURN
     HELP "Informe a opcao desejada (A, B, C, E, I ou L)."
     VALIDATE(CAN-DO("A,B,C,E,I,L",glb_cddopcao),"014 - Opcao errada.")

     tel_cddlinha AT 23 LABEL "Codigo" AUTO-RETURN
     HELP "Informe o codigo da linha de desconto."
     VALIDATE(tel_cddlinha > 0,"363 - Linha nao cadastrada.")
     
     
     tel_tpdescto AT  37 LABEL "Tipo Desconto"
     HELP "Entre com o Tipo de Desconto (C - Cheques, T - Titulos)."
     VALIDATE(CAN-DO("T,C",tel_tpdescto),"Tipo de Desconto invalido.")

     tel_dsdescto AT  53 NO-LABEL

     SKIP(1)
     tel_dsdlinha AT 7 LABEL "Descricao"
     HELP "Informe a descricao da linha de desconto."
     VALIDATE(tel_dsdlinha <> "","375 - O campo deve ser preenchido.")
     
     SKIP(1)
     tel_txjurmor AT  4 LABEL "Taxa de Mora" "%"
     
     tel_nrdevias AT 42 LABEL "Qt. Vias"
     HELP  "Entre com a quantidade vias a serem impressas do contrato."
     VALIDATE(tel_nrdevias > 0,"026 - Quantidade errada.")
     
     SKIP(1)
     tel_txmensal AT  5 LABEL "Taxa Mensal"
     "%"          AT 29
     
     tel_flgtarif AT  44 LABEL "Tarifa" FORMAT "Cobrar/Isentar"
     HELP  "Entre com (C)obrar ou (I)sentar a tarifa para o contrato."
     
     SKIP(1)
     tel_txdiaria AT  5 LABEL "Taxa Diaria"
     "%"          AT 30
     
     tel_dssitlcr AT  42 LABEL "Situacao"
     
     WITH NO-BOX ROW 6 SIDE-LABELS OVERLAY WIDTH 78 CENTERED FRAME f_ldesco.

/* .......................................................................... */
