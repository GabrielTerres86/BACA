/* .............................................................................

   Programa: includes/var_altera.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Julho/94.                       Ultima atualizacao: 24/04/2017

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Trazer as variaveis necessarias para a rotina de manutencao do
               log de alteracoes.

   Alteracoes: 03/07/97 - Alterado para tratar o tipo de extrato (Deborah).

               22/08/97 - Tratar cddsenha (Odair)

               14/10/98 - Tratar campos novos (Deborah).

               09/11/98 - Logar bloqueio e prejuizo (Deborah).

               13/04/1999 - Logar tipo de emissao dos avisos (Deborah).

               06/04/2000 - Logar tipo 2 proponente (Odair).
               
               12/09/2000 - Variaveis para log da Mantal. (Margarete/Planner)
                
               04/10/2001 - Incluir dtcnscpf e cdsitcpf (Margarete). 
               
               15/10/2002 - Incluir inarqcbr e dsdemail (Junior).
               
               20/08/2004 - Incluidas as variaveis para log, das telas
                            MANEXT e EMAIL (Evandro).

               03/09/2004 - Tratar conta integracao (Margarete).
               
               28/12/2004 - Incluido campo log_flgiddep (Evandro).

               13/12/2005 - Incluido campo log_nrdctitg (Diego). 

               21/12/2005 - Incluidas as variaveis para log da tela
                            CADSPC (Diego).
                            
               28/04/2006 - Incluidas variaveis usadas na nova tela MATRIC
                            (Evandro).

               29/03/2007 - Alterado formato das variaveis de endereco para
                            para serem baseadas na estrutura crapenc (Elton).
                            
               05/11/2007 - LIKE do log_nmdsecao alterado p/ crapttl(Guilherme).
                             
               22/02/2008 - LIKE do log_cdturnos alterado p/ crapttl(Gabriel).
               
               01/09/2008 - Alteracao cdempres (Kbase IT).

               05/08/2009 - Trocado campo cdgraupr da crapass para crapttl.
                            Paulo - Precise.
                            
               10/12/2009 - Alterado inhabmen da crapass p/ crapttl(Guilherme).
               
               11/03/2011 - Retirar campo dsdemail e inarqcbr da crapass
                            (Gabriel).
                            
               20/05/2011 - Substituicao do campo crapenc.nranores por 
                            crapenc.dtinires (data que o cooperado passou a
                            residir no endereco informado). Fabricio

               29/04/2013 - Alterado onde tinha campo crapass.dsnatura por
                            crapttl.dsnatura e retirar o campo 
                            crapass.dsnatstl (Lucas R.).
                            
               30/09/2013 - Removido campo log_nrfonres. (Reinert)

               16/05/2014 - Alterado o LIKE do campo log_vlsalari 
                           (Douglas - Chamado 131253)
                           
               10/06/2014 - (Chamado 117414) - Troca do campo crapass.nmconjug por crapcje.nmconjug
                            (Tiago Castro - RKAM).
                            
               07/08/2014 - Alterado o LIKE do campo log_cdestcvl de crapass.cdestcvl para crapttl.cdestcvl
                           (Douglas - Chamado 131253)
                           
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).

               19/04/2017 - Alteraçao DSNACION pelo campo CDNACION.
                           PRJ339 - CRM (Odirlei-AMcom)
                           
			   24/04/2017 - Ajuste para retirar o uso de campos removidos da tabela
			                crapass, crapttl, crapjur 
							(Adriano - P339).

               17/07/2017 - Alteraçao CDOEDTTL pelo campo IDORGEXP.
                           PRJ339 - CRM (Odirlei-AMcom)              
............................................................................. */

/* Variaveis genericas da rotina */

DEF        VAR log_tpaltera AS INT                                   NO-UNDO.
DEF        VAR log_nmdcampo AS CHAR                                  NO-UNDO.
DEF        VAR log_confirma AS CHAR    FORMAT "x"                    NO-UNDO.
DEF        VAR log_flgrecad AS LOGICAL                               NO-UNDO.
DEF        VAR log_qtletras AS INTEGER                               NO-UNDO.
DEF        VAR log_qtlinhas AS INTEGER                               NO-UNDO.
DEF        VAR log_flgctitg LIKE crapalt.flgctitg                    NO-UNDO.
DEF        VAR aux_cdgraupr LIKE crapttl.cdgraupr                    NO-UNDO.
DEF        VAR aux_inhabmen LIKE crapttl.cdgraupr                    NO-UNDO.

/* Variaveis de recadastramento (geram tipo de alteracao 1) */

DEF        VAR log_nmprimtl LIKE crapass.nmprimtl                    NO-UNDO.
DEF        VAR log_dtnasctl LIKE crapass.dtnasctl                    NO-UNDO.
DEF        VAR log_nrcpfcgc LIKE crapass.nrcpfcgc                    NO-UNDO.
DEF        VAR log_cdnacion LIKE crapnac.cdnacion                    NO-UNDO.
DEF        VAR log_dsnacion LIKE crapnac.dsnacion                    NO-UNDO.
DEF        VAR log_cdestcvl LIKE crapttl.cdestcvl                    NO-UNDO.
DEF        VAR log_dsproftl LIKE crapass.dsproftl                    NO-UNDO.
DEF        VAR log_tpdocptl LIKE crapass.tpdocptl                    NO-UNDO.
DEF        VAR log_nrdocptl LIKE crapass.nrdocptl                    NO-UNDO.
DEF        VAR log_cdsexotl LIKE crapass.cdsexotl                    NO-UNDO.
DEF        VAR log_dsfiliac LIKE crapass.dsfiliac                    NO-UNDO.
DEF        VAR log_nmconjug LIKE crapcje.nmconjug                    NO-UNDO.
DEF        VAR log_dtcnscpf LIKE crapass.dtcnscpf                    NO-UNDO.
DEF        VAR log_cdsitcpf LIKE crapass.cdsitcpf                    NO-UNDO.
DEF        VAR log_nrdctitg LIKE crapass.nrdctitg                    NO-UNDO.
DEF        VAR log_nmpaiptl LIKE crapass.nmpaiptl                    NO-UNDO.
DEF        VAR log_nmmaeptl LIKE crapass.nmmaeptl                    NO-UNDO.

DEF        VAR log_tpnacion LIKE crapttl.tpnacion                    NO-UNDO.
DEF        VAR log_cdocpttl LIKE crapttl.cdocpttl                    NO-UNDO.
DEF        VAR log_dsnatura LIKE crapttl.dsnatura                    NO-UNDO.

/* Endereco */
DEF        VAR log_nrcepend LIKE crapenc.nrcepend                    NO-UNDO.
DEF        VAR log_dsendere LIKE crapenc.dsendere                    NO-UNDO.
DEF        VAR log_nrendere LIKE crapenc.nrendere                    NO-UNDO.
DEF        VAR log_complend LIKE crapenc.complend                    NO-UNDO.
DEF        VAR log_nmbairro LIKE crapenc.nmbairro                    NO-UNDO.
DEF        VAR log_nmcidade LIKE crapenc.nmcidade                    NO-UNDO.
DEF        VAR log_cdufende LIKE crapenc.cdufende                    NO-UNDO.
DEF        VAR log_nrcxapst LIKE crapenc.nrcxapst                    NO-UNDO.
DEF        VAR log_incasprp LIKE crapenc.incasprp                    NO-UNDO.
DEF        VAR log_vlalugue LIKE crapenc.vlalugue                    NO-UNDO.
DEF        VAR log_dtinires LIKE crapenc.dtinires                    NO-UNDO.


/* Dados de pessoa juridica */
DEF        VAR log_dtiniatv LIKE crapjur.dtiniatv                    NO-UNDO.
DEF        VAR log_natjurid LIKE crapjur.natjurid                    NO-UNDO.
DEF        VAR log_nmfansia LIKE crapjur.nmfansia                    NO-UNDO.
DEF        VAR log_nrinsest LIKE crapjur.nrinsest                    NO-UNDO.
DEF        VAR log_cdrmativ LIKE crapjur.cdrmativ                    NO-UNDO.
DEF        VAR log_cdseteco LIKE crapjur.cdseteco                    NO-UNDO.

/* Telefone */
DEF        VAR log_nrdddtfc LIKE craptfc.nrdddtfc                    NO-UNDO.
DEF        VAR log_nrtelefo LIKE craptfc.nrtelefo                    NO-UNDO.
                                                                    
/* Variaveis de manutencao do log (geram tipo de alteracao 2) */

DEF        VAR log_cdagenci LIKE crapass.cdagenci                    NO-UNDO.
DEF        VAR log_cdempres LIKE crapttl.cdempres                    NO-UNDO.
DEF        VAR log_nrcadast LIKE crapass.nrcadast                    NO-UNDO.
DEF        VAR log_dtdemiss LIKE crapass.dtdemiss                    NO-UNDO.
DEF        VAR log_dtnasccj LIKE crapcje.dtnasccj                    NO-UNDO.
DEF        VAR log_dsendcom LIKE crapcje.dsendcom                    NO-UNDO.
DEF        VAR log_dtadmemp LIKE crapass.dtadmemp                    NO-UNDO.
DEF        VAR log_cdturnos LIKE crapttl.cdturnos                    NO-UNDO.
DEF        VAR log_nrramemp LIKE crapass.nrramemp                    NO-UNDO.
DEF        VAR log_nrctacto LIKE crapass.nrctacto                    NO-UNDO.
DEF        VAR log_nrctaprp LIKE crapass.nrctaprp                    NO-UNDO.
DEF        VAR log_cdtipcta LIKE crapass.cdtipcta                    NO-UNDO.
DEF        VAR log_cdsitdct LIKE crapass.cdsitdct                    NO-UNDO.
DEF        VAR log_cdsecext LIKE crapass.cdsecext                    NO-UNDO.
DEF        VAR log_cdgraupr LIKE crapttl.cdgraupr                    NO-UNDO.
DEF        VAR log_dtcnsspc LIKE crapass.dtcnsspc                    NO-UNDO.
DEF        VAR log_dtdsdspc LIKE crapass.dtdsdspc                    NO-UNDO.
DEF        VAR log_inadimpl LIKE crapass.inadimpl                    NO-UNDO.
DEF        VAR log_inlbacen LIKE crapass.inlbacen                    NO-UNDO.
DEF        VAR log_tpextcta LIKE crapass.tpextcta                    NO-UNDO.
DEF        VAR log_cddsenha LIKE crapsnh.cddsenha                    NO-UNDO.
DEF        VAR log_cdoedptl AS CHARACTER                             NO-UNDO.
DEF        VAR log_cdufdptl LIKE crapass.cdufdptl                    NO-UNDO.
DEF        VAR log_inhabmen LIKE crapttl.inhabmen                    NO-UNDO.
DEF        VAR log_dtemdptl LIKE crapass.dtemdptl                    NO-UNDO.
DEF        VAR log_vlsalari LIKE crapttl.vlsalari                    NO-UNDO.
DEF        VAR log_cdsitdtl LIKE crapass.cdsitdtl                    NO-UNDO.
DEF        VAR log_tpavsdeb LIKE crapass.tpavsdeb                    NO-UNDO.
DEF        VAR log_cddopcao AS CHAR    FORMAT "!(1)"                 NO-UNDO.
DEF        VAR log_nrdctabb LIKE crapass.nrdconta                    NO-UNDO.
DEF        VAR log_nrdocmto LIKE crapcst.nrcheque                    NO-UNDO.
DEF        VAR log_desopcao AS CHARACTER  FORMAT "x(11)"             NO-UNDO.
DEF        VAR log_flgiddep LIKE crapass.flgiddep                    NO-UNDO.

/* variaveis de log da tela MANEXT */ 
DEF        VAR log_cddemail LIKE crapcex.cddemail                    NO-UNDO.
DEF        VAR log_cdperiod LIKE crapcex.cdperiod                    NO-UNDO.
DEF        VAR log_cdrefere LIKE crapcex.cdrefere                    NO-UNDO.
DEF        VAR log_nmpessoa LIKE crapcex.nmpessoa                    NO-UNDO.
DEF        VAR log_tpextrat LIKE crapcex.tpextrat                    NO-UNDO.

/* variaveis de log da tela EMAIL */
DEF        VAR log_codemail LIKE crapcem.cddemail                    NO-UNDO.
DEF        VAR log_desemail LIKE crapcem.dsdemail                    NO-UNDO.

/* variaveis de log da tela CADSPC */
DEF        VAR log_dtvencto LIKE crapspc.dtvencto                    NO-UNDO.
DEF        VAR log_vldivida LIKE crapspc.vldivida                    NO-UNDO.
DEF        VAR log_dtinclus LIKE crapspc.dtinclus                    NO-UNDO.
DEF        VAR log_dtdbaixa LIKE crapspc.dtdbaixa                    NO-UNDO.
DEF        VAR log_dsoberv1 LIKE crapspc.dsoberva                    NO-UNDO.
DEF        VAR log_dsoberv2 LIKE crapspc.dsobsbxa                    NO-UNDO.


/* .......................................................................... */




