/* .............................................................................

   Programa: Includes/var_cmesaq.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : 04/08/2003.                     Ultima atualizacao: 09/08/2013 

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criar variaveis e forms para a tela CMESAQ.

   Alteracoes: 30/09/2003 - Nao registrar acima de R$ 100.000 quando pessoa
                            juridica (Margarete).

               27/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               25/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               04/05/2010 - Adicionadas variveis para tratamento da rotina 20
                            na cmesaq (impressão de movimentação em espécie)
                            (Fernando).   
                            
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano).              
                            
               27/04/2011 - Aumentar os formatos dos campos 'Cidade' (Gabriel).            
                                                         
               20/05/2011 - Retirar campo Registrar (Gabriel)      
               
               16/09/2011 - Retirar campo 'Pessoa' , obrigar tipo Fisica.
                            Incluir campo 'Valor sendo levado'. (Gabriel)    
                                                                           
               04/10/2011 - Se conta nao informada no DOC ou TED da erro
                            de associado nao cadastrado (Magui).
                            
               17/11/2011 - Converter para BO (Gabriel).  
                          - Ajuste para a transferencia Intercooperativa.
                            (Gabriel).
                            
               22/02/2012 - Criadas vars 'tel_nrctnome' e 'tel_nrdconta' para
                            evitar registros duplicados validando a conta. (Lucas)
                            
               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).
                          
............................................................................. */

/* Variaveis para impressao */
DEF VAR tel_dsimprim AS CHAR  FORMAT "x(8)" INIT "Imprimir"           NO-UNDO.
DEF VAR tel_dscancel AS CHAR  FORMAT "x(8)" INIT "Cancelar"           NO-UNDO.
DEF VAR tel_nrctnome AS CHAR                                          NO-UNDO.
DEF VAR tel_nrdconta AS INT   FORMAT "zzzz,zz9,9"                     NO-UNDO.

DEF VAR aux_flgescra AS LOGI                                          NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                          NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                          NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                          NO-UNDO.
DEF VAR aux_contador AS INTE                                          NO-UNDO.
DEF VAR par_flgrodar AS LOGI                                          NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                          NO-UNDO.
DEF VAR par_flgcance AS LOGI                                          NO-UNDO.

/* Variaveis de retorno */                                            
DEF VAR par_nmdcampo AS CHAR                                NO-UNDO.
DEF VAR par_nmarqimp AS CHAR                                NO-UNDO.
DEF VAR par_nmarqpdf AS CHAR                                NO-UNDO.

DEF VAR h-b1wgen0104 AS HANDLE                              NO-UNDO.


FORM SPACE(1) WITH ROW 4 OVERLAY 16 DOWN WIDTH 80
                   TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, ou I)"
                        VALIDATE(CAN-DO("A,C,I",glb_cddopcao),
                                 "014 - Opcao errada.")

     tel_dtmvtolt AT 14 LABEL "Data"

     tel_tpdocmto AT 33 LABEL "Tp. Docmto"     
  HELP "Informe 0- Outros, 1-DOC C, 2-DOC D, 3- TED, 4 – DEP. INTERCOOP."
                        VALIDATE(tel_tpdocmto <= 4,
                                 "Tipo de documento incorreto.")
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.
  
FORM tel_cdagenci AT 15 LABEL "PA"   AUTO-RETURN
                        HELP "Entre com o codigo do PA."
                        VALIDATE(tel_cdagenci <> 0,
                                 "375 - O campo deve ser preenchido.")

     tel_nrdcaixa AT 25 LABEL "Caixa" AUTO-RETURN FORMAT "zz9"
                        HELP "Entre com o numero do caixa."
                        VALIDATE(tel_nrdcaixa <> 0,
                                 "375 - O campo deve ser preenchido.")

     tel_cdopecxa AT 37 LABEL "Operador"  AUTO-RETURN
                        HELP "Entre com o Operador."
                        VALIDATE(tel_cdopecxa  <> "",
                                "375 - O campo deve ser preenchido.")

     tel_nrdocmto AT 59 LABEL "Docmto" 
                        HELP "Informe o numero do documento do deposito."
                        VALIDATE(tel_nrdocmto <> 0,
                                 "375 - O campo deve ser preenchido.")
     WITH ROW 7 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao_2.

FORM tel_cdagenci AT 15 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o codigo do PA."
                        VALIDATE(tel_cdagenci <> 0,
                                 "375 - O campo deve ser preenchido.")

     tel_cdbccxlt AT 25 LABEL "Banco/Caixa" AUTO-RETURN
                        HELP "Entre com o codigo do Banco/Caixa."
                        VALIDATE(tel_cdbccxlt <> 0,
                                "375 - O campo deve ser preenchido.")
                                
     tel_nrdolote AT 43 LABEL "Lote" AUTO-RETURN
                        HELP "Entre com o numero do lote."
                        VALIDATE(tel_nrdolote <> 0,
                                "375 - O campo deve ser preenchido.")

     tel_nrdocmto AT 58 LABEL "Docmto" 
                        HELP "Informe o numero do documento do deposito."
                        VALIDATE(tel_nrdocmto <> 0,
                                 "375 - O campo deve ser preenchido.")

     WITH ROW 7 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao_3.

FORM tel_cdagenci AT 15 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o codigo do PA."
                        VALIDATE(tel_cdagenci <> 0,
                                 "375 - O campo deve ser preenchido.")

     tel_cdbccxlt AT 25 LABEL "Banco/Caixa" AUTO-RETURN
                        HELP "Entre com o codigo do Banco/Caixa."
                        VALIDATE(tel_cdbccxlt <> 0,
                                "375 - O campo deve ser preenchido.")
                                
     tel_nrdolote AT 43 LABEL "Lote" AUTO-RETURN
                        HELP "Entre com o numero do lote."
                        VALIDATE(tel_nrdolote <> 0,
                                "375 - O campo deve ser preenchido.")

     tel_nrdocmto AT 58 LABEL "Docmto" 
                        HELP "Informe o numero do documento do deposito."
                        VALIDATE(tel_nrdocmto <> 0,
                                 "375 - O campo deve ser preenchido.")

     tel_nrdconta LABEL "Conta/Dv"    AT 50

     WITH ROW 7 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao_0.

FORM tt-crapcme.nrseqaut LABEL "Aut"               FORMAT "zz,zz9" AT 04
     tt-crapcme.vllanmto LABEL "Valor"       AT 16 
     tel_nrctnome        LABEL "Conta/Dv"    AT 50 FORMAT "x(18)"
     SKIP
     "---------------------------------- SACADOR -----------------------------------"
     SKIP
     tt-crapcme.nrccdrcb LABEL "Conta/Dv"   
                  HELP "Informe o numero da conta, se associado."
     tt-crapcme.nmpesrcb LABEL "Nome"   
                  HELP "Entre com o nome completo do depositante." 
                  VALIDATE(tt-crapcme.nmpesrcb <> "",
                           "375 - O campo deve ser preenchido.")
     SKIP   
     tt-crapcme.cpfcgrcb LABEL "CPF" FORMAT "x(21)"
                  HELP "Entre com o CPF do depositante."
                  VALIDATE(tt-crapcme.cpfcgrcb <> "",
                           "375 - O campo deve ser preenchido.")
     tt-crapcme.nridercb LABEL "Nr.Ide"
                  HELP "Entre com o numero da identidade do depositante."
     tt-crapcme.dtnasrcb LABEL "Nasc"
                  HELP "Entre com a data de nascimento do depositante."
     SKIP      
     tt-crapcme.desenrcb LABEL "Endereco"
                  HELP "Entre com o endereco do depositante."
                  VALIDATE(tt-crapcme.desenrcb <> ?,
                           "375 - O campo deve ser preenchido.")

     SKIP  
     tt-crapcme.nmcidrcb LABEL "Cidade" FORMAT "x(25)"
                  HELP "Entre com a cidade do depositante."
                  VALIDATE(tt-crapcme.nmcidrcb <> "",
                           "375 - O campo deve ser preenchido.")        
     tt-crapcme.nrceprcb LABEL "    CEP"
                  HELP "Entre com o CEP do depositante."
                  VALIDATE(tt-crapcme.nrceprcb <> 0,
                           "375 - O campo deve ser preenchido.")

     tt-crapcme.cdufdrcb LABEL "UF"
                  HELP "Entre com o estado do depositante."
                  VALIDATE(tt-crapcme.cdufdrcb <> "",
                           "375 - O campo deve ser preenchido.")         
     SKIP(1)
     tt-crapcme.flinfdst LABEL "Inf. prestadas pelo cooperado"
                  HELP "Informar se o destino dos recursos vai ser prenchido."

     SKIP(1)  
     tt-crapcme.dstrecur LABEL "Destino" 
                  HELP "Entre com o destino dos recursos."
                  VALIDATE(tt-crapcme.dstrecur <> "",
                           "375 - O campo deve ser preenchido.")                        
     SKIP(1)

     WITH ROW 8 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_cmesaq.
     
FORM tt-crapcme.dsdopera LABEL "Valor sendo levado (Total/Parcial)"
                              FORMAT "!(1)"
       VALIDATE(tt-crapcme.dsdopera = "T" OR
                tt-crapcme.dsdopera = "P", "014 - Opcao errada." )
       HELP 
       "Informe se o valor que esta sendo levado é (T)otal ou (P)arcial." 
     SPACE(2)       
     tt-crapcme.vlretesp LABEL "Valor"
       HELP 
       "Informe o valor em dinheiro que esta sendo levado do PA."
    WITH ROW 19 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_cmesaq_2.


/* .......................................................................... */

