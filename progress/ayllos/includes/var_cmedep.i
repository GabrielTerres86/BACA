/* .............................................................................

   Programa: Includes/var_cmedep.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Margarete
   Data    : 04/08/2003.                  Ultima atualizacao: 17/01/2014

   Dados referentes ao programa:

   Frequencia: Diario (on-line)
   Objetivo  : Criar variaveis e forms para a tela CMEDEP.

   Alteracoes: 30/09/2003 - Nao registrar acima de R$ 100.000 quando pessoa
                            juridica (Margarete).

               27/01/2005 - Modificados os termos "Agencia" ou "Ag" por "PAC"
                            (Evandro).

               27/01/2006 - Unificacao dos Bancos - SQLWorks - Fernando
               
               26/04/2011 - Alterado a validacao do cdbccxlt atraves do crapban 
                            para crapbcl (Adriano). 
                            
               27/04/2011 - Aumentar os formatos do campo cidade (Gabriel).  
               
               20/05/2011 - Retirar campo 'Registrar' (Gabriel).
               
               16/09/2011 - Retirar tipo de pessoa, obrigar a ser tipo
                            fisica (Gabriel).         
                            
               03/11/2011 - Convertar para BO (Gabriel).    
               
               06/03/2012 - Adicionada a var 'tel_nrctnome'  (Lucas).
               
               18/07/2012 - Adicionado campo tel_nrdconta. (Jorge)
               
               09/08/2013 - Modificado o termo "PAC" para "PA" (Douglas).                   
               
               17/01/2014 - Alterado cdcritic ao nao encontrar PA para "962 - PA
                            nao cadastrado.". (Reinert)
                                                               
............................................................................. */

/* DEF VAR tel_nrdconta AS CHAR FORMAT "x(22)"                           NO-UNDO.*/

/* Variaveis para impressao */
DEF VAR tel_dsimprim AS CHAR  FORMAT "x(8)" INIT "Imprimir"           NO-UNDO.
DEF VAR tel_dscancel AS CHAR  FORMAT "x(8)" INIT "Cancelar"           NO-UNDO.
DEF VAR aux_flgescra AS LOGI                                          NO-UNDO.
DEF VAR aux_dscomand AS CHAR                                          NO-UNDO.
DEF VAR aux_nmarqimp AS CHAR                                          NO-UNDO.
DEF VAR aux_nmendter AS CHAR                                          NO-UNDO.
DEF VAR par_flgrodar AS LOGI                                          NO-UNDO.
DEF VAR par_flgfirst AS LOGI                                          NO-UNDO.
DEF VAR par_flgcance AS LOGI                                          NO-UNDO.
DEF VAR tel_nrctnome AS CHAR                                          NO-UNDO.
DEF VAR tel_nrdconta AS INT   FORMAT "zzzz,zz9,9"                     NO-UNDO.

/* Variaveis de retorno */                                            
DEF VAR par_nmdcampo AS CHAR                                          NO-UNDO.
DEF VAR par_nmarqimp AS CHAR                                          NO-UNDO.
DEF VAR par_nmarqpdf AS CHAR                                          NO-UNDO.
                                                                                                                                                                                                                
DEF VAR h-b1wgen0104 AS HANDLE                                        NO-UNDO.



FORM SPACE(1) WITH ROW 4 OVERLAY 16 DOWN WIDTH 80
                   TITLE glb_tldatela FRAME f_moldura.

FORM glb_cddopcao AT  2 LABEL "Opcao" AUTO-RETURN
                        HELP "Informe a opcao desejada (A, C, ou I)"
                        VALIDATE(CAN-DO("A,C,I",glb_cddopcao),
                                 "014 - Opcao errada.")

     tel_dtmvtolt AT 14 LABEL "Data"
     tel_cdagenci AT 37 LABEL "PA" AUTO-RETURN
                        HELP "Entre com o codigo do PA."
                        VALIDATE(CAN-FIND (crapage WHERE 
                                           crapage.cdcooper = glb_cdcooper AND                                              crapage.cdagenci = tel_cdagenci),
                                           "962 - PA nao cadastrado.")

     tel_cdbccxlt AT 47 LABEL "Banco/Caixa" AUTO-RETURN
                        HELP "Entre com o codigo do Banco/Caixa."
                        VALIDATE(CAN-FIND (crapbcl WHERE 
                                           crapbcl.cdbccxlt = tel_cdbccxlt),
                                           "057 - Banco nao cadastrado.")

     tel_nrdolote AT 65 LABEL "Lote" AUTO-RETURN
                        HELP "Entre com o numero do lote."
                        VALIDATE(tel_nrdolote > 0,
                                "058 - Numero do lote errado.")
     
     WITH ROW 6 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_opcao.
     
FORM tel_nrdocmto  AT 12     LABEL "Docmto"
                        HELP "Informe o numero do documento do deposito."
                        VALIDATE(tel_nrdocmto <> 0,
                                 "375 - O campo deve ser preenchido.")
     tel_nrdconta  AT 32     LABEL "Conta/Dv"
                        HELP "Informe o numero da conta."
                        VALIDATE(tel_nrdconta <> 0,
                                 "375 - O campo deve ser preenchido.")
     tel_nrctnome              NO-LABEL         FORMAT "x(18)"
     tt-crapcme.nrseqaut       LABEL "Aut"      FORMAT "zz,zz9" AT 15
     tt-crapcme.vllanmto       LABEL "Valor"    AT 35
     "-------------------------------- DEPOSITANTE ---------------------------------"
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
     SPACE(8)   
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
     tt-crapcme.cdufdrcb LABEL "        UF"
                  HELP "Entre com o estado do depositante."
                  VALIDATE(tt-crapcme.cdufdrcb <> "",
                           "375 - O campo deve ser preenchido.")
     SKIP(1)  
     tt-crapcme.flinfdst LABEL "Informacoes prestadas pelo cooperado"
                  HELP "Informe se a origem dos recursos vai ser prenchida."
     SKIP(1) 
     tt-crapcme.recursos LABEL "Recursos" 
                  HELP "Entre com a origem dos recursos."
                  VALIDATE(tt-crapcme.recursos <> "",
                           "375 - O campo deve ser preenchido.")
     SKIP(3)
     
     WITH ROW 7 COLUMN 2 OVERLAY SIDE-LABELS NO-BOX FRAME f_cmedep.

/* .......................................................................... */

