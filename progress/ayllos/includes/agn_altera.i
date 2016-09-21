/* .............................................................................

   Programa: includes/agn_altera.i
   Sistema : Conta-Corrente - Cooperativa de Credito
   Sigla   : CRED
   Autor   : Deborah/Edson
   Data    : Julho/94.                        Ultima atualizacao: 12/08/2015

   Dados referentes ao programa:

   Frequencia: Sempre que for chamada.
   Objetivo  : Fazer a movimentacao dos campos do crapass para as variaveis do
               log de alteracoes.

   Alteracoes: 22/08/97 - Tratar cddsenha (Odair)

               14/10/98 - Tratar campos novos (Deborah). 

               09/11/98 - Tratar bloqueio e prejuizo (Deborah). 

               13/04/1999 - Logar tipo de emissao dos avisos (Deborah). 
               
               06/04/2000 - Tratar 2 proponente (Odair)

               04/10/2001 - Incluir dtcnscpf e cdsitcpf (Margarete).

               15/10/2002 - Incluir inarqcbr e dsdemail (Junior).
               
               20/08/2004 - Incluidas as variaveis para log, das telas
                            MANEXT e EMAIL (Evandro).

               28/12/2004 - Incluido campo log_flgiddep (Evandro).

               13/12/2005 - Incluido campo log_nrdctitg (Diego). 

               21/12/2005 - Incluidas as variaveis para log da tela
                            CADSPC (Diego).
                            
               28/04/2006 - Incluidas variaveis usadas na nova tela MATRIC
                            (Evandro).
               
               29/03/2007 - Alterado variaveis de endereco para receberem
                            informacoes da estrutura crapenc (Elton).
                            
               05/11/2007 - Utilizar nmdsecao a partir da crapttl(Guilherme)
                          - Utilizar cdturnos a partir da crapttl(Gabriel).
                          
               01/09/2008 - Alteracao cdempres (Kbase IT).
               
               25/09/2009 - Retirado atribuicao de campo de grau de 
                            parentesco (cdgraupr) - Sidnei (Precise)
               
               10/12/2009 - Retirado campo inhabmen pois passou pra ttl
                            (Guilherme).
                            
               18/12/2009 - Eliminado campo crapass.cddsenha (Diego).
               
               11/03/2011 - Retirar campo dsdemail e inarqcbr da crapass
                           (Gabriel).
                           
               19/05/2011 - Substituicao do campo crapenc.nranores por 
                            crapenc.dtinires (data que o cooperado passou a
                            residir no endereco informado). Fabricio 
                            
               29/04/2013 - Alterado campo crapass.dsnatura por
                            crapttl.dsnatura (Lucas R.)
                            
               13/08/2013 - Retirar campo crapass.dsnatstl. (Reinert)
               
               30/09/2013 - Removido campo log_nrfonres. (Reinert)

               16/05/2014 - Alterado valor do campo log_vlsalari 
                            de crapass.vlsalari para crapttl.vlsalari
                            (Douglas - Chamado 131253)
                            
               10/06/2014 - (Chamado 117414) Troca do campo crapass.nmconjug 
                            por crapcje.nmconjug
                            (Tiago Castro - RKAM).
                            
               12/08/2015 - Projeto Reformulacao cadastral
                            Eliminado o campo nmdsecao (Tiago Castro - RKAM).

............................................................................. */

/* Variaveis de recadastramento (geram tipo de alteracao 1) */

ASSIGN log_nmprimtl = crapass.nmprimtl
       log_dtnasctl = crapass.dtnasctl
       log_nrcpfcgc = crapass.nrcpfcgc
       log_dsnacion = crapass.dsnacion
       log_cdestcvl = crapass.cdestcvl
       log_dsproftl = crapass.dsproftl
       log_tpdocptl = crapass.tpdocptl
       log_nrdocptl = crapass.nrdocptl
       log_cdsexotl = crapass.cdsexotl
       log_dsfiliac = crapass.dsfiliac
       log_nmconjug = crapcje.nmconjug
       log_nmsegntl = crapass.nmsegntl
       log_tpdocstl = crapass.tpdocstl
       log_nrdocstl = crapass.nrdocstl
       log_dtnasstl = crapass.dtnasstl
       log_dsfilstl = crapass.dsfilstl
       log_nrcpfstl = crapass.nrcpfstl
       log_dtcnscpf = crapass.dtcnscpf
       log_cdsitcpf = crapass.cdsitcpf
       log_nrdctitg = crapass.nrdctitg
       log_nmpaiptl = crapass.nmpaiptl
       log_nmmaeptl = crapass.nmmaeptl.
       
ASSIGN log_cdagenci = crapass.cdagenci
       log_nrcadast = crapass.nrcadast
       log_dtdemiss = crapass.dtdemiss
       log_dtnasccj = crapcje.dtnasccj
       log_dsendcom = crapcje.dsendcom
       log_dtadmemp = crapass.dtadmemp
       log_nrfonemp = crapass.nrfonemp
       log_nrramemp = crapass.nrramemp
       log_nrctacto = crapass.nrctacto
       log_nrctaprp = crapass.nrctaprp
       log_cdtipcta = crapass.cdtipcta
       log_cdsitdct = crapass.cdsitdct
       log_cdsecext = crapass.cdsecext
       log_dtcnsspc = crapass.dtcnsspc
       log_dtdsdspc = crapass.dtdsdspc
       log_inadimpl = crapass.inadimpl
       log_inlbacen = crapass.inlbacen
       log_tpextcta = crapass.tpextcta
       log_tpavsdeb = crapass.tpavsdeb
       log_flgiddep = crapass.flgiddep
       log_cdoedptl = crapass.cdoedptl                    
       log_cdoedstl = crapass.cdoedstl                    
       log_cdoedrsp = crapass.cdoedrsp                    
       log_cdufdptl = crapass.cdufdptl                    
       log_cdufdstl = crapass.cdufdstl                    
       log_cdufdrsp = crapass.cdufdrsp                    
       log_nmrespon = crapass.nmrespon                    
       log_nrcpfrsp = crapass.nrcpfrsp                    
       log_nrdocrsp = crapass.nrdocrsp                    
       log_tpdocrsp = crapass.tpdocrsp                    
       log_dtemdstl = crapass.dtemdstl                    
       log_dtemdptl = crapass.dtemdptl                    
       log_dtemdrsp = crapass.dtemdrsp                    
       log_qtdepend = crapass.qtdepend                    
       log_dsendcol = crapass.dsendcol                    
       log_cdsitdtl = crapass.cdsitdtl.
       
IF   AVAILABLE crapttl   THEN
     ASSIGN log_tpnacion = crapttl.tpnacion
            log_cdocpttl = crapttl.cdocpttl            
            log_cdturnos = crapttl.cdturnos
            log_cdempres = crapttl.cdempres
            log_dsnatura = crapttl.dsnatura
            log_vlsalari = crapttl.vlsalari.
ELSE
     ASSIGN log_cdturnos = 0.
                   
IF   AVAILABLE crapenc   THEN
     ASSIGN log_nrcepend = crapenc.nrcepend
            log_dsendere = crapenc.dsendere
            log_nrendere = crapenc.nrendere
            log_complend = crapenc.complend
            log_nmbairro = crapenc.nmbairro
            log_nmcidade = crapenc.nmcidade
            log_cdufende = crapenc.cdufende
            log_nrcxapst = crapenc.nrcxapst
            log_incasprp = crapenc.incasprp 
            log_vlalugue = crapenc.vlalugue 
            log_dtinires = crapenc.dtinires.

IF   AVAILABLE crapjur   THEN
     ASSIGN log_dtiniatv = crapjur.dtiniatv
            log_natjurid = crapjur.natjurid
            log_nmfansia = crapjur.nmfansia
            log_nrinsest = crapjur.nrinsest
            log_cdrmativ = crapjur.cdrmativ
            log_cdseteco = crapjur.cdseteco.
            
IF   AVAILABLE craptfc   THEN
     ASSIGN log_nrdddtfc = craptfc.nrdddtfc
            log_nrtelefo = craptfc.nrtelefo.

/* Atribuicoes para log da tela MANEXT */       
IF   AVAILABLE crapcex   THEN
     ASSIGN  log_cddemail = crapcex.cddemail
             log_cdperiod = crapcex.cdperiod
             log_cdrefere = crapcex.cdrefere
             log_nmpessoa = crapcex.nmpessoa
             log_tpextrat = crapcex.tpextrat.
                    
/* Atribuicoes para log da tela EMAIL */       
IF   AVAILABLE crapcem   THEN
     ASSIGN  log_codemail = crapcem.cddemail
             log_desemail = crapcem.dsdemail.
                   
/* Atribuicao para log da tela CADSPC */
IF   AVAILABLE crapspc   THEN
     ASSIGN log_dtvencto = crapspc.dtvencto
            log_vldivida = crapspc.vldivida
            log_dtinclus = crapspc.dtinclus
            log_dtdbaixa = crapspc.dtdbaixa
            log_dsoberv1 = crapspc.dsoberva
            log_dsoberv2 = crapspc.dsobsbxa.
                    
/* .......................................................................... */




