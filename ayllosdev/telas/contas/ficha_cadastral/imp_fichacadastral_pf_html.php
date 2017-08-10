<?
/*!
 * FONTE        : imp_fichacadastral_pf_html.php							Última alteração: 20/04/2017
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 06/04/2010 
 * OBJETIVO     : Responsável por buscar as informações que serão apresentadas no PDF da Ficha Cadastral 
 *                da Pessoa Física e montar o HTML.
 *
 * ALTERACOES	: 11/02/2011 - Aumentar formato do campo 'Nome talao' para 40 (Gabriel)	
				
				  05/04/2011 - As informacoes dos contatos na ficha cadastral 
                               a partir da tela contas, nao serao impressos (Adriano). 
							   
				  08/06/2011 - Aumento do formato do campo cidade e bairro (Gabriel).	

				  19/08/2011 - Adicionado campos Apto e Bloco em ENDERECO (Jorge).
				  
				  04/04/2012 - Ajustado tempo de residencia assim como layout
  							   de endereço. (Jorge)
							   
				  25/04/2012 - Incluido a impressão dos procuradores (Adriano).

			      25/04/2013 - Incluir campo cdufnatu no frame (Lucas R.)
				  
				  13/08/2013 - Inlcusao de Poderes (Jean Michel).
				  
				  05/09/2013 - Alteração da sigla PAC para PA (Carlos)
				  
				  03/10/2013 - Alteração p/ exibição de poderes "Em Conjunto" (Jean Michel).
					
				  19/12/2013 - Alterada linha da ficha cadastral de "CPF/CGC" para 
							   "CPF/CNPJ". (Reinert)
							   
				  23/05/2014 - Ajuste para pegar poderes conforme cpf do procurador.
							   (Jorge/Rosangela) - SD 155408
							   
 				  25/11/2014 - Remoção do Endividamento e dos Bens dos representantes por 
                               caracterizar quebra de sigilo bancário (Douglas - Chamado 194831)
							   
				  19/08/2015 - Reformulacao cadastral (Gabriel-RKAM)			   
				
                  05/11/2015 - Inclusão de novo Poder, PRJ. 131 - Ass. Conjunta (Jean Michel)
				  
				  23/12/2015 - Inclusão de impressão de PEP (Carlos)

				  01/12/2016 - Definir a não obrigatoriedade do PEP (Tiago/Thiago SD532690)

				  08/03/2017 - Ajuste para apresentar novas informações para o PEP (Adriano - SD 614408).

				  15/03/2017 - Ajuste para corrigir quebra de página devido aos ajustes realizados
				               para a inclusão de novas informações na declaração PEP
							   (Adriano - SD 614408).
          
                  20/04/2017 - Ajustes realiados:
					           - Retirar o uso de campos removidos da tabela crapass, crapttl, crapjur;
							   - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
			                     crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
							  (Adriano - P339).
 */	 
?>
<?
	require_once('../../../includes/funcoes.php');
	require_once('../../../class/xmlfile.php');
	
	$arrpoder = array(1 => "Emitir Cheques", 2 =>  "Endossar Cheques",  
                    3 => "Autorizar Debitos", 4 => "Requisitar Taloes",
                    5 => "Assinar Contratos de Emprst/Financ",
					6 => "Substabelecer", 7 => "Receber", 8 => "Passar Recibo",
                    9 => "Outros Poderes", 10 => "Assinar Operacao Autoatendimento");
	
	// PEP
	$arrTpExposto = array(1 => "Exerce/Exerceu", 
						  2 => "Relacionamento");
	
	
					
	$xmlObjeto = $GLOBALS['xmlObjeto']; 	
				
	$registros 	  	= $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$telefone	  	= $xmlObjeto->roottag->tags[1]->tags;
	$email  	  	= $xmlObjeto->roottag->tags[2]->tags;
	$pfisica  	  	= $xmlObjeto->roottag->tags[3]->tags[0]->tags;
	$filiacao  	  	= $xmlObjeto->roottag->tags[4]->tags[0]->tags;
	$comercial    	= $xmlObjeto->roottag->tags[5]->tags[0]->tags;
	$bens  		  	= $xmlObjeto->roottag->tags[6]->tags;
	/*$bens_rep	  	= $xmlObjeto->roottag->tags[14]->tags;*/
	$dependentes  	= $xmlObjeto->roottag->tags[7]->tags;
	$contatos     	= $xmlObjeto->roottag->tags[8]->tags;
	$responsaveis 	= $xmlObjeto->roottag->tags[9]->tags;
	$conjuge	  	= $xmlObjeto->roottag->tags[10]->tags[0]->tags;
	$representantes	= $xmlObjeto->roottag->tags[13]->tags;
	$poderes        = $xmlObjeto->roottag->tags[15]->tags;
	
	// Inicializando variáveis
	//$GLOBALS['totalLinha'] 	= 69;
	$GLOBALS['totalLinha'] 	= 69;
	$GLOBALS['numLinha']	= 0;
	$GLOBALS['numPagina'] 	= 1;	
	$GLOBALS['tipo'] = '';
  
    $tprelato = $GLOBALS["tprelato"];
	
    if ($GLOBALS["tprelato"] == "completo") { // Voltar valor do imp_completo_pf_html.php
		$GLOBALS["tprelato"] = "ficha_cadastral";
	}


		
	function escreveTitulo( $str ) {
	    if( $GLOBALS['numLinha'] + 5 > $GLOBALS['totalLinha'] ) {
			
			// Quebro a página e retorno o número de linha atual
			// echo "<p style='page-break-before: always;'>&nbsp;</p>";
			$GLOBALS['numLinha'] = 5;
			$GLOBALS['numPagina']++;
			
			echo "<p>".preencheString('PAG '.$GLOBALS['numPagina'],90,' ','D')."</p>";
			
		} else {
			
			if ( $GLOBALS['tipo'] == 'formulario' && $GLOBALS['flagRepete'] ) {
				switch ($str){
					case 'CONTATOS':
							if ( $GLOBALS['numLinha'] + 11 > $GLOBALS['totalLinha'] ) { $GLOBALS['numLinha'] = 70; escreveTitulo( $str ); return false; }
						break;
					case 'RESPONSAVEL LEGAL':
							if ( $GLOBALS['numLinha'] + 18 > $GLOBALS['totalLinha'] ) { $GLOBALS['numLinha'] = 70; escreveTitulo( $str ); return false;}
						break;
					case 'CONJUGE':
							if ( $GLOBALS['numLinha'] + 15 > $GLOBALS['totalLinha'] ) { $GLOBALS['numLinha'] = 70; escreveTitulo( $str ); return false;}
						break;
					default: break;
				}
			} 
			$GLOBALS['numLinha'] = $GLOBALS['numLinha']+4;
			echo '<br>';
		}
		echo '              '.preencheString('',76,'-').'<br>';
		echo '              '.preencheString($str,76,' ','C').'<br>';
		echo '              '.preencheString('',76,'-').'<br>';
	}
?>
<style type="text/css">
	pre { 
		font-family: monospace, "Courier New", Courier; 
		font-size:9pt;
	}
	p {
		 page-break-before: always;
		 padding: 0px;
		 margin:0px;	
	}
</style>
<?
	echo '<pre>';
	//************************************************************CABECALHO************************************************************
	$linha = preencheString('PAG '.$GLOBALS['numPagina'],76,' ','D');
	escreveLinha( $linha );
	
	escreveLinha( '+--------------------------------------------------------------------------+' );
	
	$linha = '|'.preencheString(getByTagName($registros,'nmextcop'),74).'|';
	escreveLinha( $linha );
	
	$linha = '|'.preencheString('',74).'|';
	escreveLinha( $linha );
	
	$linha = '|CONTA/DV: '.preencheString(getByTagName($registros,'nrdconta'),19);
	$linha .= 'PA: '.preencheString(getByTagName($registros,'dsagenci'),21);
	$linha .= ' MATRICULA: '.preencheString(getByTagName($registros,'nrmatric'),7,' ','D').'|';
	escreveLinha( $linha );
	
	$linha = '|'.preencheString('',74).'|';
	escreveLinha( $linha );
	
	$linha = '|'.preencheString('FICHA CADASTRAL',74,' ','C').'|';
	escreveLinha( $linha );
	
	escreveLinha( '+--------------------------------------------------------------------------+' );
	//**********************************************************IDENTIFICACAO**********************************************************
	
	escreveTitulo('IDENTIFICACAO');
	
	$linha = preencheString(getByTagName($pfisica,'nmextttl'),76,' ','C');
	escreveLinha( $linha );

	$linha = preencheString('Tp.Natureza: '.getByTagName($pfisica,'inpessoa').' - '.getByTagName($pfisica,'dspessoa'),76);
	escreveLinha( $linha );	
	
	$linha = '     C.P.F.: '.preencheString(getByTagName($pfisica,'nrcpfcgc'),37,' ').'Consulta: '.preencheString(getByTagName($pfisica,'dtcnscpf'),17,' ');
	escreveLinha( $linha );

	$linha = preencheString('Situacao: ',60,' ','D');	
	$linha .= preencheString(getByTagName($pfisica,'cdsitcpf').' - '.getByTagName($pfisica,'dssitcpf'),16);	
	escreveLinha( $linha );
	
	$linha = '  Documento: '.preencheString(getByTagName($pfisica,'tpdocttl').' - '.getByTagName($pfisica,'nrdocttl'),20);	
	escreveLinha( $linha );
	$linha = '   Org.Emi.: '.preencheString(getByTagName($pfisica,'cdoedttl'),11);	
	$linha .= 'U.F.: '.preencheString(getByTagName($pfisica,'cdufdttl'),17);	
	$linha .= preencheString('Data Emi.: ',13,' ','D');	
	$linha .= preencheString(getByTagName($pfisica,'dtemdttl'),16);	
	escreveLinha( $linha );
	
	$linha = '   Data Nascimento: '.preencheString(getByTagName($pfisica,'dtnasttl'),34);	
	$linha .= 'Sexo: '.preencheString(getByTagName($pfisica,'cdsexotl'),16);	
	escreveLinha( $linha );
	
	$linha = 'Tipo Nacionalidade: '.preencheString(getByTagName($pfisica,'tpnacion').' - '.getByTagName($pfisica,'restpnac'),25);	
	$linha .= 'Nacionalidade: '.preencheString(getByTagName($pfisica,'dsnacion'),16);	
	escreveLinha( $linha );
	
	$linha = preencheString( '        Natural De: '.getByTagName($pfisica,'dsnatura'),55);	
	$linha .= 'U.F: '.preencheString(getByTagName($pfisica,'cdufnatu'),16);
	escreveLinha( $linha );
	
	$linha = ' Habilitacao Menor: '.preencheString(getByTagName($pfisica,'inhabmen').' '.getByTagName($pfisica,'dshabmen'),22);	
	$linha .= 'Data Emancipacao: '.preencheString(getByTagName($pfisica,'dthabmen'),16);	
	escreveLinha( $linha );
	
	$linha = preencheString('  Relacionamento com o 1 titular: '.getByTagName($pfisica,'cdgraupr').' '.getByTagName($pfisica,'dsgraupr'),76);	
	escreveLinha( $linha );
	
	escreveLinha( '' );
	
	$linha = '      Est.Civil:  '.preencheString(getByTagName($pfisica,'cdestcvl').'-'.getByTagName($pfisica,'dsestcvl'),18);	
	$linha .= ' Escolaridade:  '.preencheString(getByTagName($pfisica,'grescola').' '.getByTagName($pfisica,'dsescola'),25);	
	escreveLinha( $linha );
	
	$linha = ' Curso Superior:  '.preencheString(getByTagName($pfisica,'cdfrmttl').'-'.getByTagName($pfisica,'rsfrmttl'),19);	
	escreveLinha( $linha );
	
	$linha = '  Nome Talao: '.preencheString(getByTagName($pfisica,'nmtalttl'),40);	
	$linha .= ' Qtd. Folhas Talao: '.preencheString(getByTagName($pfisica,'qtfoltal'),18);	
	escreveLinha( $linha );
	
	//***********************************************************FILIACAO***********************************************************
	
	escreveTitulo('FILIACAO');
	
	$linha = preencheString(' Nome da Mae: '.getByTagName($filiacao,'nmmaettl'),76);	
	escreveLinha( $linha );
	
	escreveLinha('');
	
	$linha = preencheString(' Nome do Pai: '.getByTagName($filiacao,'nmpaittl'),76);	
	escreveLinha( $linha );

	//***********************************************************ENDERECO***********************************************************
	
	escreveTitulo('ENDERECO');
	
	$linha = '      Tipo do Imovel: '.preencheString(getByTagName($registros,'incasprp').' - '.getByTagName($registros,'dscasprp'),16);	
	$linha .= 'Valor do Imovel: '.preencheString(number_format(str_replace(',','.',getByTagName($registros,'vlalugue')),2,',','.'),14,' ','D');	
	escreveLinha( $linha );
	
	$linha = 'Inicio de Residencia: '.preencheString(getByTagName($registros,'dtabrres'),15);
	$linha .= 'Tempo Residencia: '.preencheString(getByTagName($registros,'dstemres'),20);
	escreveLinha( $linha );
	
	escreveLinha('');
	
	$linha = '   CEP: '.preencheString(getByTagName($registros,'nrcepend'),15);	
	$linha .= 'Endereco: '.preencheString(getByTagName($registros,'dsendere'),43);	
	escreveLinha( $linha );
	
	$linha = '  Nro.: '.preencheString(getByTagName($registros,'nrendere'),12);	
	$linha .= 'Complemento: '.preencheString(getByTagName($registros,'complend'),43);	
	escreveLinha( $linha );
	
	$linha = ' Apto.: '.preencheString(getByTagName($registros,'nrdoapto'),18);	
	$linha .= 'Bloco: '.preencheString(getByTagName($registros,'cddbloco'),5);	
	escreveLinha( $linha );
	
	$linha = 'Bairro: '.preencheString(getByTagName($registros,'nmbairro'),40);	
	escreveLinha( $linha );
	
	$linha  = 'Cidade: '.preencheString(getByTagName($registros,'nmcidade'),26);		
	$linha .= 'UF: '.preencheString(getByTagName($registros,'cdufende'),4);	
	$linha .= 'Caixa Postal: '.preencheString(getByTagName($registros,'nrcxapst'),6,' ','D');	
	escreveLinha( $linha );
	
	//***********************************************************COMERCIAL***********************************************************
	
	escreveTitulo('COMERCIAL');
	
	$linha = 'Nat.Ocupacao: '.preencheString(getByTagName($comercial,'cdnatopc').' '.getByTagName($comercial,'rsnatocp'),33);	
	$linha .= 'Ocupacao: '.preencheString(getByTagName($comercial,'cdocpttl').' '.getByTagName($comercial,'rsocupa'),18);	
	escreveLinha( $linha );
	
	$linha = 'Tp.Ctr.Trab.: '.preencheString(getByTagName($comercial,'tpcttrab').' '.getByTagName($comercial,'dsctrtab'),62);	
	escreveLinha( $linha );
	
	$linha = '     Empresa: '.preencheString(getByTagName($comercial,'cdempres').' '.getByTagName($comercial,'nmresemp'),22);	
	$linha .= 'Nome empresa: '.preencheString(getByTagName($comercial,'nmextemp'),26);	
	escreveLinha( $linha );
	
	$linha = '    C.N.P.J.: '.preencheString(getByTagName($comercial,'nrcgcemp'),27);	
	escreveLinha( $linha );
	
	$linha = '       Cargo: '.preencheString(getByTagName($comercial,'dsproftl'),21);	
	$linha .= 'Nivel Cargo: '.preencheString(getByTagName($comercial,'cdnvlcgo').' '.getByTagName($comercial,'rsnvlcgo'),28);
	escreveLinha( $linha );
	
	escreveLinha( '' );
	
	$linha = '   CEP: '.preencheString(getByTagName($comercial,'nrcepend'),15);	
	$linha .= 'Endereco: '.preencheString(getByTagName($comercial,'dsendere'),43);	
	escreveLinha( $linha );
	
	$linha = '  Nro.: '.preencheString(getByTagName($comercial,'nrendere'),12);	
	$linha .= 'Complemento: '.preencheString(getByTagName($comercial,'complend'),43);	
	escreveLinha( $linha );
	
	$linha = 'Bairro: '.preencheString(getByTagName($comercial,'nmbairro'),40);
	escreveLinha( $linha );
	
	$linha  = 'Cidade: '.preencheString(getByTagName($comercial,'nmcidade'),26);	
	$linha .= 'UF: '.preencheString(getByTagName($comercial,'cdufende'),4);	
	$linha .= 'Caixa Postal: '.preencheString(getByTagName($comercial,'nrcxapst'),6,' ','D');	
	escreveLinha( $linha );
	
	$linha = ' Turno: '.preencheString(getByTagName($comercial,'cdturnos'),14);	
	$linha .= 'Admissao: '.preencheString(getByTagName($comercial,'dtadmemp'),22);	
	$linha .= 'Rendimento: '.preencheString(number_format(str_replace(',','.',getByTagName($comercial,'vlsalari')),2,',','.'),10,' ','D');
	escreveLinha( $linha );
	
	escreveLinha( '' );
	
	$linha = preencheString('Outros Rendimentos - Origem:',30);	
	$linha .= preencheString(getByTagName($comercial,'tpdrend1').' '.getByTagName($comercial,'dstipre1'),29);	
	$linha .= 'Valor: '.preencheString(number_format(str_replace(',','.',getByTagName($comercial,'vldrend1')),2,',','.'),10,' ','D');
	escreveLinha( $linha );
	
	$linha = preencheString('',30);	
	$linha .= preencheString(getByTagName($comercial,'tpdrend2').' '.getByTagName($comercial,'dstipre2'),29);	
	$linha .= 'Valor: '.preencheString(number_format(str_replace(',','.',getByTagName($comercial,'vldrend2')),2,',','.'),10,' ','D');
	escreveLinha( $linha );
	
	$linha = preencheString('',30);	
	$linha .= preencheString(getByTagName($comercial,'tpdrend3').' '.getByTagName($comercial,'dstipre3'),29);	
	$linha .= 'Valor: '.preencheString(number_format(str_replace(',','.',getByTagName($comercial,'vldrend3')),2,',','.'),10,' ','D');
	escreveLinha( $linha );
	
	$linha = preencheString('',30);	
	$linha .= preencheString(getByTagName($comercial,'tpdrend4').' '.getByTagName($comercial,'dstipre4'),29);	
	$linha .= 'Valor: '.preencheString(number_format(str_replace(',','.',getByTagName($comercial,'vldrend4')),2,',','.'),10,' ','D');
	escreveLinha( $linha );

	
	//***********************************************************BENS***********************************************************
	$GLOBALS['titulo'] = 'BENS';
	escreveTitulo( $GLOBALS['titulo'] );
	
	$GLOBALS['cab'] = preencheString('Descricao do bem',27);	
	$GLOBALS['cab'] .= preencheString('Perc. s/ onus',14);	
	$GLOBALS['cab'] .= preencheString('Parc.',6);
	$GLOBALS['cab'] .= preencheString('Valor Parcela',20);
	$GLOBALS['cab'] .= preencheString('Valor Bem',9);
	escreveLinha( $GLOBALS['cab'] );
	
	$GLOBALS['flagRepete'] = true;
	$GLOBALS['tipo'] = 'tabela';
	
	if ( count($bens) != 0 ){
		foreach( $bens as $dados ){
			$linha = preencheString(getByTagName($dados->tags,'dsrelbem').' ',27);	
			$linha .= preencheString(number_format(str_replace(',','.',getByTagName($dados->tags,'persemon')),2,',','.').'  ',14,' ','D');	
			$linha .= preencheString(getByTagName($dados->tags,'qtprebem').'   ',6,' ','D');	
			$linha .= preencheString(number_format(str_replace(',','.',getByTagName($dados->tags,'vlprebem')),2,',','.').' ',13,' ','D');	
			$linha .= preencheString(number_format(str_replace(',','.',getByTagName($dados->tags,'vlrdobem')),2,',','.'),16,' ','D');	
			escreveLinha( $linha );			
		}
	}
	$GLOBALS['flagRepete'] = false;
	//*********************************************************TELEFONES********************************************************
	
	$GLOBALS['titulo'] = 'TELEFONES';
	escreveTitulo( $GLOBALS['titulo'] );
		
	$cab = preencheString('Operadora',12);	
	$cab .= preencheString(' DDD',6);	
	$cab .= preencheString(' Telefone',9);
	$cab .= preencheString(' Ramal',6);
	$cab .= preencheString(' Identificacao',15);
	$cab .= preencheString(' Setor',9);
	$cab .= preencheString(' Pessoa de Contato',19,' ','D');
	escreveLinha( $cab );
		
	$GLOBALS['flagRepete'] = true;
	$GLOBALS['tipo'] = 'tabela';
	
	if ( count($telefone) != 0 ) {
		foreach( $telefone as $dados ) {
			$linha = preencheString(getByTagName($dados->tags,'dsopetfn').' ',12);	
			$linha .= preencheString(getByTagName($dados->tags,'nrdddtfc').'  ',6,' ','D');	
			$linha .= preencheString(getByTagName($dados->tags,'nrtelefo').' ',9,' ','D');	
			$linha .= preencheString(getByTagName($dados->tags,'nrdramal').' ',6,' ','D');	
			$linha .= preencheString(' '.getByTagName($dados->tags,'tptelefo'),15);	
			$linha .= preencheString(getByTagName($dados->tags,'secpscto'),8,' ','C').' ';	
			$linha .= preencheString(getByTagName($dados->tags,'nmpescto'),19,' ','D');	
			escreveLinha( $linha );	
		}
	}
	$GLOBALS['flagRepete'] = false;
	//**********************************************************E-MAILS*********************************************************
	
	$GLOBALS['titulo'] = 'E-MAILS';
	escreveTitulo( $GLOBALS['titulo'] );
		
	$cab = preencheString('Endereco eletronico',43);	
	$cab .= preencheString(' Setor',9);	
	$cab .= preencheString('   Pessoa de Contato',24);
	escreveLinha( $cab );
	
	$GLOBALS['flagRepete'] = true;
	$GLOBALS['tipo'] = 'tabela';
	
	if ( count($email) != 0 ) {
		foreach( $email as $dados ) {
			$linha = preencheString(getByTagName($dados->tags,'dsdemail').' ',43);	
			$linha .= preencheString(' '.getByTagName($dados->tags,'secpscto'),9);	
			$linha .= preencheString(' '.getByTagName($dados->tags,'nmpescto'),24);	
			escreveLinha( $linha );
		}
	}				
	$GLOBALS['flagRepete'] = false;
	//*********************************************************CONJUGE**********************************************************
	
	if ( getByTagName($conjuge,'nmconjug') != '' ) {
		$GLOBALS['titulo'] = 'CONJUGE';
		$GLOBALS['flagRepete'] = true;
		$GLOBALS['tipo'] = 'formulario';
		escreveTitulo( $GLOBALS['titulo'] );
				
		$linha = ' Conta/DV: '.preencheString(getByTagName($conjuge,'nrctacje'),19);	
		$linha .= 'Nome: '.preencheString(getByTagName($conjuge,'nmconjug'),40);	
		escreveLinha( $linha );
		
		$linha = '   C.P.F.: '.preencheString(getByTagName($conjuge,'nrcpfcje'),36);	
		$linha .= 'Data Nascimento: '.preencheString(getByTagName($conjuge,'dtnasccj'),12);	
		escreveLinha( $linha );
		
		$linha = 'Documento: '.preencheString(getByTagName($conjuge,'tpdoccje').' '.getByTagName($conjuge,'nrdoccje'),15);	
		escreveLinha( $linha );
		$linha  = ' Org.Emi.: '.preencheString(getByTagName($conjuge,'cdoedcje'),7);	
		$linha .= 'U.F.: '.preencheString(getByTagName($conjuge,'cdufdcje'),29);	
		$linha .= 'Data Emi.: '.preencheString(getByTagName($conjuge,'dtemdcje'),12);	
		escreveLinha( $linha );
		
		escreveLinha( '' );
		
		$linha = 'Escolaridade: '.preencheString(getByTagName($conjuge,'gresccje').' '.getByTagName($conjuge,'dsescola'),19);	
		$linha .= 'Curso Superior: '.preencheString(getByTagName($conjuge,'cdfrmttl').' '.getByTagName($conjuge,'rsfrmttl'),27);	
		escreveLinha( $linha );
		
		$linha = 'Nat.Ocupacao: '.preencheString(getByTagName($conjuge,'cdnatopc').' '.getByTagName($conjuge,'rsnatocp'),28);	
		$linha .= 'Ocupacao: '.preencheString(getByTagName($conjuge,'cdocpttl').' '.getByTagName($conjuge,'rsnatocp'),24);	
		escreveLinha( $linha );
		
		escreveLinha( '' );
		
		$linha = 'Tp.Ctr.Trab.: '.preencheString(getByTagName($conjuge,'tpcttrab').' '.getByTagName($conjuge,'dsctrtab'),76);	
		escreveLinha( $linha );
		
		$linha = '     Empresa: '.preencheString(getByTagName($conjuge,'nmextemp'),38);	
		$linha .= 'CNPJ: '.preencheString(getByTagName($conjuge,'nrcpfemp'),18);	
		escreveLinha( $linha );
		
		$linha = '       Cargo: '.preencheString(getByTagName($conjuge,'dsproftl'),31);	
		$linha .= 'Nivel Cargo: '.preencheString(getByTagName($conjuge,'cdnvlcgo').' '.getByTagName($conjuge,'rsnvlcgo'),18);	
		escreveLinha( $linha );
		
		$linha = 'Tel.Comercial: '.preencheString(getByTagName($conjuge,'nrfonemp'),37);	
		$linha .= 'Ramal: '.preencheString(getByTagName($conjuge,'nrramemp'),18);	
		escreveLinha( $linha );
		
		$linha = '        Turno: '.preencheString(getByTagName($conjuge,'cdturnos'),6);	
		$linha .= 'Admissao: '.preencheString(getByTagName($conjuge,'dtadmemp'),15);	
		$linha .= 'Rendimento: '.preencheString(number_format(str_replace(',','.',getByTagName($conjuge,'vlsalari')),2,',','.'),15,' ','D');	
		escreveLinha( $linha );
		
		$GLOBALS['flagRepete'] = false;
	}	
	//******************************************************DEPENDENTES*******************************************************
	
	escreveTitulo('DEPENDENTES');
	
	$cab = preencheString('Nome',40);	
	$cab .= preencheString(' Data Nasc.',16);	
	$cab .= preencheString(' Tipo Dependente',20);
	escreveLinha( $cab );
	
	if ( count($dependentes) != 0 ) {
		foreach( $dependentes as $dados ) {
			$linha = preencheString(getByTagName($dados->tags,'nmdepend'),39).' ';	
			$linha .= preencheString(' '.getByTagName($dados->tags,'dtnascto'),16);	
			$linha .= preencheString(' '.getByTagName($dados->tags,'tpdepend').' - '.getByTagName($dados->tags,'dstextab'),20);	
			escreveLinha( $linha );
		}
	}
	
	//********************************************************CONTATOS********************************************************
    if ($tprelato != "completo" && $tprelato != "ficha_cadastral") {
 	$GLOBALS['flagRepete'] = true;
	$GLOBALS['titulo'] = 'CONTATOS';
	$GLOBALS['tipo'] = 'formulario';
	if ( count($contatos) != 0 ) {
		foreach( $contatos as $contato ) {
						
			escreveTitulo( $GLOBALS['titulo'] );
			
			$linha = ' Conta/DV: '.preencheString(getByTagName($contato->tags,'nrdctato'),19);	
			$linha .= 'Nome: '.preencheString(getByTagName($contato->tags,'nmdavali'),40);	
			escreveLinha( $linha );
			
			escreveLinha( '' );
			
			$linha = '   CEP: '.preencheString(getByTagName($contato->tags,'nrcepend'),15);	
			$linha .= 'Endereco: '.preencheString(getByTagName($contato->tags,'dsendere'),43);	
			escreveLinha( $linha );
			
			$linha = '  Nro.: '.preencheString(getByTagName($contato->tags,'nrendere'),12);	
			$linha .= 'Complemento: '.preencheString(getByTagName($contato->tags,'complend'),43);	
			escreveLinha( $linha );
			
			$linha = 'Bairro: '.preencheString(getByTagName($contato->tags,'nmbairro'),40);
			escreveLinha( $linha );	
	
 	        $linha  = 'Cidade: '.preencheString(getByTagName($contato->tags,'nmcidade'),26);	
			$linha .= 'UF: '.preencheString(getByTagName($contato->tags,'cdufende'),4);	
			$linha .= 'Caixa Postal: '.preencheString(getByTagName($contato->tags,'nrcxapst'),6,' ','D');	
			escreveLinha( $linha );
			
			escreveLinha( '' );
			
			$linha = preencheString('Telefones: '.getByTagName($contato->tags,'nrtelefo'),76);	
			escreveLinha( $linha );
			
			$linha = preencheString('   E_Mail: '.getByTagName($contato->tags,'dsdemail'),76);	
			escreveLinha( $linha );
		}	
	} 
     }
	$GLOBALS['flagRepete'] = false;
	//******************************************************RESPONSAVEL LEGAL*******************************************************
	$GLOBALS['flagRepete'] = true;
	$GLOBALS['titulo'] = 'RESPONSAVEL LEGAL';
	$GLOBALS['tipo'] = 'formulario';
	if ( count($responsaveis) != 0 ) {
		foreach( $responsaveis as $responsavel ) {
			escreveTitulo( $GLOBALS['titulo'] );
			
			$linha = ' Conta/dv: '.preencheString(getByTagName($responsavel->tags,'nrdconta'),22);	
			$linha .= 'C.P.F.: '.preencheString(getByTagName($responsavel->tags,'nrcpfcgc'),36);	
			escreveLinha( $linha );
			
			$linha = '     Nome: '.preencheString(getByTagName($responsavel->tags,'nmrespon'),76);	
			escreveLinha( $linha );
			
			$linha = '  Documento: '.preencheString(getByTagName($responsavel->tags,'tpdeiden').' - '.getByTagName($responsavel->tags,'nridenti'),19);	
			escreveLinha( $linha );
			$linha  = ' Org.Emi.: '.preencheString(getByTagName($responsavel->tags,'dsorgemi'),8);	
			$linha .= 'U.F.: '.preencheString(getByTagName($responsavel->tags,'cdufiden'),22);	
			$linha .= preencheString('Data Emi.: ',12,' ','D');	
			$linha .= preencheString(getByTagName($responsavel->tags,'dtemiden'),22);	
			escreveLinha( $linha );
			
			escreveLinha( '' );
			
			$linha = 'Data Nascimento: '.preencheString(getByTagName($responsavel->tags,'dtnascin'),13);	
			$linha .= 'Sexo: '.preencheString(getByTagName($responsavel->tags,'cddosexo'),4);	
			$linha .= 'Estado Civil: '.preencheString(getByTagName($responsavel->tags,'cdestciv').'-'.getByTagName($responsavel->tags,'dsestciv'),21);
			escreveLinha( $linha );
			
			$linha = '  Nacionalidade: '.preencheString(getByTagName($responsavel->tags,'dsnacion'),76);	
			escreveLinha( $linha );
			
			$linha = preencheString( '     Natural de: '.getByTagName($responsavel->tags,'dsnatura'),76);	
			escreveLinha( $linha );
			
			escreveLinha( '' );
			
			$linha = '   CEP: '.preencheString(getByTagName($responsavel->tags,'cdcepres'),15);	
			$linha .= 'Endereco: '.preencheString(getByTagName($responsavel->tags,'dsendres'),43);	
			escreveLinha( $linha );
			
			$linha = '  Nro.: '.preencheString(getByTagName($responsavel->tags,'nrendres'),12);	
			$linha .= 'Complemento: '.preencheString(getByTagName($responsavel->tags,'dscomres'),43);	
			escreveLinha( $linha );
			
			$linha = 'Bairro: '.preencheString(getByTagName($responsavel->tags,'dsbaires'),40);	
			escreveLinha( $linha );
			
			$linha  = 'Cidade: '.preencheString(getByTagName($responsavel->tags,'dscidres'),26);	
			$linha .= 'UF: '.preencheString(getByTagName($responsavel->tags,'dsdufres'),4);	
			$linha .= 'Caixa Postal: '.preencheString(getByTagName($responsavel->tags,'nrcxpost'),6,' ','D');	
			escreveLinha( $linha );
			
			$linha = preencheString( 'Filiacao: Mae: '.getByTagName($responsavel->tags,'nmmaersp'),76);	
			escreveLinha( $linha );
			
			$linha = preencheString( '          Pai: '.getByTagName($responsavel->tags,'nmpairsp'),76);	
			escreveLinha( $linha );
		}	
	}
	$GLOBALS['flagRepete'] = false;
		
	//****************************************************REPRESENTANTE PROCURADOR****************************************************
	$GLOBALS['flagRepete'] = true;
	$GLOBALS['titulo'] = 'REPRESENTANTE PROCURADOR';
	$GLOBALS['tipo'] = 'formulario';
	
	if ( count($representantes) != 0 ) {
		foreach( $representantes as $representante ) {
			escreveTitulo( $GLOBALS['titulo'] );
		
			$linha = ' Conta/dv: '.preencheString(getByTagName($representante->tags,'nrdctato'),38);	
			$linha .= ' C.P.F.: '.preencheString(getByTagName($representante->tags,'nrcpfcgc'),18);	
			escreveLinha( $linha );
			
			$linha = '     Nome: '.preencheString(getByTagName($representante->tags,'nmdavali'),76);	
			escreveLinha( $linha );
			
			$linha = '  Documento: '.preencheString(getByTagName($representante->tags,'tpdocava').' '.getByTagName($representante->tags,'nrdocava'),18);	
			escreveLinha( $linha );
			$linha  = ' Org.Emi.: '.preencheString(getByTagName($representante->tags,'cdoeddoc'),5);	
			$linha .= ' UF: '.preencheString(getByTagName($representante->tags,'cdufddoc'),2);	
			$linha .= ' Data Emi.: '.preencheString(getByTagName($representante->tags,'dtemddoc'),12);	
			escreveLinha( $linha );
			escreveLinha( '');
						
			$linha = 'Data Nascimento: '.preencheString(getByTagName($representante->tags,'dtnascto'),13);	
			$linha .= 'Responsab. Legal: '.preencheString(getByTagName($representante->tags,'inhabmen'),2);	
			$linha .= preencheString(getByTagName($representante->tags,'dshabmen'),14);	
			
			escreveLinha($linha);
			$linha  = 'Data Emancipacao: '.preencheString(getByTagName($representante->tags,'dthabmen'),16);	
			$linha .= 'Sexo: '.preencheString(getByTagName($representante->tags,'cdsexcto'),7);	
			$linha .= 'Estado Civil: '.preencheString(getByTagName($representante->tags,'dsestcvl'),21);
			escreveLinha( $linha );
								
			$linha = '  Nacionalidade: '.preencheString(getByTagName($representante->tags,'dsnacion'),18);	
			$linha .= ' Natural de: '.preencheString(getByTagName($representante->tags,'dsnatura'),28);	
			escreveLinha( $linha );
			
			escreveLinha( '' );
			
			$linha = '   CEP: '.preencheString(getByTagName($representante->tags,'nrcepend'),10);	
			$linha .= ' End.Residencial: '.preencheString(getByTagName($representante->tags,'dsendere'),40);	
			escreveLinha( $linha );
			
			$linha = '  Nro.: '.preencheString(getByTagName($representante->tags,'nrendere'),14);	
			$linha .= ' Complemento: '.preencheString(getByTagName($representante->tags,'complend'),40);	
			escreveLinha( $linha );
			
			$linha = 'Bairro: '.preencheString(getByTagName($representante->tags,'nmbairro'),40);	
			escreveLinha( $linha );
			
			$linha  = 'Cidade: '.preencheString(getByTagName($representante->tags,'nmcidade'),26);			
			$linha .= ' UF: '.preencheString(getByTagName($representante->tags,'cdufende'),3);	
			$linha .= ' Caixa Postal: '.preencheString(getByTagName($representante->tags,'nrcxapst'),6,' ','D');	
			escreveLinha( $linha );
			
			$linha = preencheString( 'Filiacao: Mae: '.getByTagName($representante->tags,'nmmaecto'),76);	
			escreveLinha( $linha );
			
			$linha = preencheString( '          Pai: '.getByTagName($representante->tags,'nmpaicto'),76);	
			escreveLinha( $linha );
			
			escreveLinha( '' );
			
			/*
			$linha = preencheString( 'Endividamento: '.number_format(str_replace(',','.',getByTagName($representante->tags,'vledvmto')),2,',','.'),76);	
			escreveLinha( $linha );
			*/
			
			$linha = 'Vigencia: '.preencheString(getByTagName($representante->tags,'dtvalida'),19);	
			escreveLinha( $linha );
			
			escreveLinha( '' );
			
			//**********************************************************PODERES*********************************************************//
			
			if ( count($poderes) != 0 ) {
			
				escreveLinha( "PODERES" );
				
				escreveLinha( '' );
				
				$GLOBALS['cab'] = preencheString('Descricao do Poder',56);	
				$GLOBALS['cab'] .= preencheString('Conjunto',13);	
				$GLOBALS['cab'] .= preencheString('Isolado',7);
				
				escreveLinha( $GLOBALS['cab'] );
				
				escreveLinha( '' );
					
				foreach( $poderes as $poder ) {
					
					if((getByTagName($poder->tags,'nrctapro') == getByTagName($representante->tags,'nrdctato')) and
					   (getByTagName($poder->tags,'nrcpfcgc') == getByTagName($representante->tags,'nrcpfcgc'))){
					
						if(getByTagName($poder->tags,'dscpoder') != 9){
						
							$linha = "".
							
							$linha = preencheString($arrpoder[getByTagName($poder->tags,'dscpoder')], 57);
							$linha .= preencheString((getByTagName($poder->tags,'flgconju') == 'yes' ? "SIM" : "NAO"), 13);
							$linha .= preencheString((getByTagName($poder->tags,'flgisola') == 'yes' ? "SIM" : "NAO"), 10);
							
							escreveLinha($linha);
						}else{
							
							$linha9 =  "";

							$arrdspod = explode("#", getByTagName($poder->tags,'dsoutpod'));
							$dscbranc = "              - ";
							//escreveLinha(preencheString($arrpoder[getByTagName($poder->tags,'dscpoder')], 40));
							$linha9 = preencheString($arrpoder[getByTagName($poder->tags,'dscpoder')], 40);
							
							//escreveLinha($dscbranc.$arrdspod[0]);
							$linha9 .= "<br>".$dscbranc.$arrdspod[0]."<br>";
							//escreveLinha($dscbranc.$arrdspod[1]);
							$linha9 .= $dscbranc.$arrdspod[1]."<br>";
							//escreveLinha($dscbranc.$arrdspod[2]);
							$linha9 .= $dscbranc.$arrdspod[2]."<br>";
							//escreveLinha($dscbranc.$arrdspod[3]);
							$linha9 .= $dscbranc.$arrdspod[3]."<br>";
							//escreveLinha($dscbranc.$arrdspod[4]);
							$linha9 .= $dscbranc.$arrdspod[4];
						}				
					}			
				}
				escreveLinha($linha9);
			}
			
			escreveLinha( '' );
			
			//***********************************************************BENS***********************************************************//
			/**  Remover a tag de bens - CHAMADO 194831
			
			escreveLinha( "BENS" );
			
			escreveLinha( '' );
			
			$GLOBALS['cab'] = preencheString('Descricao do bem',27);	
			$GLOBALS['cab'] .= preencheString('Perc. s/ onus',14);	
			$GLOBALS['cab'] .= preencheString('Parc.',6);
			$GLOBALS['cab'] .= preencheString('Valor Parcela',20);
			$GLOBALS['cab'] .= preencheString('Valor Bem',9);
			escreveLinha( $GLOBALS['cab'] );
				
			escreveLinha( '' );
			
			if ( count($bens_rep) != 0 ){
				foreach( $bens_rep as $dados ){
					if (getByTagName($dados->tags,'nrcpfcgc') == getByTagName($representante->tags,'nrcpfcgc') ) {
						$linha = preencheString(getByTagName($dados->tags,'dsrelbem').' ',27);	
						$linha .= preencheString(number_format(str_replace(',','.',getByTagName($dados->tags,'persemon')),2,',','.').'  ',14,' ','D');	
						$linha .= preencheString(getByTagName($dados->tags,'qtprebem').'   ',6,' ','D');	
						$linha .= preencheString(number_format(str_replace(',','.',getByTagName($dados->tags,'vlprebem')),2,',','.').' ',13,' ','D');	
						$linha .= preencheString(number_format(str_replace(',','.',getByTagName($dados->tags,'vlrdobem')),2,',','.'),16,' ','D');	
						escreveLinha( $linha );	
					}	
				}
			}
			escreveLinha( '' );
			
			*/
		}
		
	}
	$GLOBALS['flagRepete'] = false;
	
	escreveLinha( '' );
	escreveLinha( '' );
	
	$linha = preencheString( getByTagName($registros,'dsmvtolt') ,76);	
	escreveLinha( $linha );
	
	if (getByTagName($pfisica,'nmprimtl') != ''){
		escreveLinha( '' );	escreveLinha( '' );
		$linha = preencheString( '________________________________________' ,76);	
		escreveLinha( $linha );
		$linha = preencheString( getByTagName($pfisica,'nmprimtl') ,76);	
		escreveLinha( $linha );
	}
	
	escreveLinha( '' );	escreveLinha( '' );
	$linha = preencheString( '________________________________________' ,76);	
	escreveLinha( $linha );
	$linha = preencheString( getByTagName($registros,'nmprimtl') ,76);	
	escreveLinha( $linha );
	
	escreveLinha( '' );	escreveLinha( '' );escreveLinha( '' );escreveLinha( '' );
	
	$linha = preencheString( 'RESPONSABILIZO-ME PELA EXATIDAO DAS INFORMACOES PRESTADAS, A VISTA DOS ORI-' ,76);	
	escreveLinha( $linha );
	$linha = preencheString( 'GINAIS DO DOCUMENTO DE  IDENTIDADE, DO CPF/CNPJ, E DE OUTROS COMPROBATORIOS' ,76);	
	escreveLinha( $linha );
	$linha = preencheString( 'DOS DEMAIS  ELEMENTOS DE INFORMACAO APRESENTADOS, SOB  PENA DE APLICACAO DO' ,76);	
	escreveLinha( $linha );
	$linha = preencheString( 'DISPOSTO NO ARTIGO 64 DA LEI NUMERO 8.383 DE 30/12/1991.' ,76);	
	escreveLinha( $linha );
	
	escreveLinha( '' );	escreveLinha( '' );escreveLinha( '' );
	
		
	$linha = preencheString( '____/_____/_____  ___________________________  ____________________________' ,76);	
	escreveLinha( $linha );
	
	$linha = preencheString('DATA',16,' ','C');	
	$linha .= '  '.preencheString('GERENTE/COORDENADOR',27,' ','C');	
	$linha .= '  '.preencheString(getByTagName($registros,'dsoperad'),28,' ','C');	
	escreveLinha( $linha );
	
	
	//********************** Pessoa exposta politicamente **********************************
	if ($fichaCadastralComDeclaracaoPEP == true) {	
	
		if (getByTagName($pfisica,'inpolexp') == 1) {
			
			$GLOBALS['numLinha']	= 70;
			pulaLinha(2);
			escreve('               DECLARACAO DE PESSOA EXPOSTA POLITICAMENTE – PEP');
			pulaLinha(3);
			
			if (getByTagName($comercial,'tpexposto') == 1) {
				
				$qtdLinhas = escreveJustificado('    Declaro que eu, ' . getByTagName($comercial,'nmextttl') . ', portador ' . 
				'do CPF ' . getByTagName($pfisica,'nrcpfcgc') . ', titular da conta ' . getByTagName($registros,'nrdconta') . ', sou uma pessoa exposta ' . 
				'politicamente, nos termos dos normativos em vigor.');
				pulaLinha(2);
				$qtdLinhas+= escreveJustificado('    Declaro, ainda, que comunicarei a Cooperativa qualquer alteração da presente condição.');			
				pulaLinha(2);
				escreve('Cargo ou Função: '          . getByTagName($comercial,'dsdocupa'));
				escreve('Data Início do Exercício: ' . getByTagName($comercial,'dtinicio'));			
				escreve('Data Fim do Exercício: '    . getByTagName($comercial,'dttermino'));			
				escreve('Empresa/Órgão Público: '    . getByTagName($comercial,'nmempresa'));			
				
				if(getByTagName($comercial,'nrcnpj_empresa') != "0"){
					escreve('CNPJ: '                     . formatar(getByTagName($comercial,'nrcnpj_empresa'),'cnpj',true));			
				}
				
				pulaLinha(4);
				escreveCidadeData(getByTagName($registros,'dscidade')); // Blumenau, 20 de janeiro de 2016.
				pulaLinha(4);
				escreve('                      ________________________________                      ');
				escreveLinha(preencheString(getByTagName($comercial,'nmextttl'), 76, ' ', 'C'));
				pulaLinha(37 - $qtdLinhas);
				escreveRodape();
			}
			if (getByTagName($comercial,'tpexposto') == 2) {
				//  Declaro que eu, PDTNX UFSMMZRR IV URTPS, portador 
				//do CPF 030.320.949-68, possuo relacionamento com uma pessoa exposta 
				//politicamente, nos termos dos normativos em vigor.
				
				//	Declaro, ainda, que comunicarei a Cooperativa qualquer alteração da 
				//presente condição.
					
				//Nome do Relacionado: CARLOS HENRIQUE WEINHOLD
				//CPF: 030.091.059-24
				//Cargo ou Função: PREFEITO MUNICIPAL
				//Tipo de Relacionamento/Ligação: ASSESSOR (A)
				
				$qtdLinhas = escreveJustificado('    Declaro que eu, ' . getByTagName($comercial,'nmextttl') . ', portador ' . 
				'do CPF ' . getByTagName($pfisica,'nrcpfcgc') . ', titular da conta ' . getByTagName($registros,'nrdconta') . ', possuo relacionamento com ' . 
				'uma pessoa exposta politicamente, nos termos dos normativos em vigor.');
				pulaLinha(2);			
				$qtdLinhas+= escreveJustificado('    Declaro, ainda, que comunicarei a Cooperativa qualquer alteração da presente condição.');
				pulaLinha(2);
				escreve('Nome do Relacionado: ' . getByTagName($comercial,'nmpolitico'));			
				escreve('CPF: ' . formatar(getByTagName($comercial,'nrcpf_politico'),'cpf',true));			
				escreve('Cargo ou Função: ' . getByTagName($comercial,'dsdocupa'));			
				escreve('Empresa: '    . getByTagName($comercial,'nmempresa'));	
				escreve('Tipo de Relacionamento/Ligação: ' . getByTagName($comercial,'dsrelacionamento'));			

				pulaLinha(4);
				escreveCidadeData(getByTagName($registros,'dscidade'));
				pulaLinha(4);
				escreve('                      ________________________________                      ');			
				escreveLinha(preencheString(getByTagName($comercial,'nmextttl'), 76, ' ', 'C'));
				
				pulaLinha(37 - $qtdLinhas);
				escreveRodape();
			}

		}
	}
	//********************** FIM Pessoa exposta politicamente **********************************
	
	
	echo '</pre>';	

	function escreveJustificado($texto) {
		$linhas = justificar($texto, 76);
		foreach ($linhas as $lin) escreveLinha($lin);
		return count($linhas);
	}
	
	function escreveRodape() {
		escreveJustificado('(*) PEP – Consideram-se pessoas expostas politicamente os agentes públicos ' . 
						  'que desempenham ou tenham desempenhado, nos últimos cinco anos, no Brasil ' . 
						  'ou em países, territórios e dependências estrangeiras, cargos, empregos, ou ' . 
						  'funções públicas relevantes, assim como seus representantes, familiares e ' . 
						  'outras pessoas de seu relacionamento próximo, conforme determina a Circular ' . 
						  'Bacen n° 3.461, de 24/07/2009.');
	}
	
	function escreve($linha) {		
	    $linha2 = preencheString($linha,76);
		escreveLinha( $linha2 );		
	}
	
	function escreveCidadeData($cidade) {
		setlocale(LC_TIME, "pt_BR");
		escreve($cidade . ', ' . strftime('%d de %B de %Y.'));
	}	

?>
