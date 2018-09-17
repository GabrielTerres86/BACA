<?
/*!
 * FONTE        : imp_fichacadastral_pj_html.php
 * CRIAÇÃO      : Gabriel Santos (DB1)
 * DATA CRIAÇÃO : 06/04/2010 
 * OBJETIVO     : Responsável por montar o HTML.
 * 
 * ALTERACOES   : 11/02/2010 - Aumentar campo 'Nome Talao' para 40 (Gabriel Ramirez).
 *				
 * 				  08/06/2011 - Aumento do formato da cidade e bairro (Gabriel Ramirez).	
 *				  
 *				  19/08/2011 - Adicionado campos de Apto e Bloco (Jorge).
 *
 *				  04/04/2012 - Ajustado tempo de residencia assim como layout
 * 							   de endereço. (Jorge)
 *
 *				  25/04/2012 - Incluido a impressão do(s) Resp. Legal dos procuradores e 
 *							   incluido os campos "%Societ.", "Depend. Econ.", 
 *							   "Resp. Legal", "Data Emancipação" aos procuradores 
 *							   (Adriano).
 *                
 *				  13/08/2013 - Inlcusao de Poderes (Jean Michel).
 *
 *                05/09/2013 - Alteração da sigla PAC para PA (Carlos)
 *					
 *				  03/10/2013 - Alteração p/ exibição de poderes "Em Conjunto" (Jean Michel).
 *
 *				  19/12/2013 - Alterada linha da ficha cadastral de "CPF/CGC" para 
 *							   "CPF/CNPJ". (Reinert)
 *
 *				  23/05/2014 - Ajuste para pegar poderes conforme cpf do procurador.
 *							   (Jorge/Rosangela) - SD 155408
 *
 *				  25/11/2014 - Remoção do Endividamento e dos Bens dos representantes por 
 *                             caracterizar quebra de sigilo bancário (Douglas - Chamado 194831)
 *				
 *				  05/11/2015 - Inclusão de novo Poder, PRJ. 131 - Ass. Conjunta (Jean Michel) 
 * 
 *                13/06/2017 - Ajuste devido ao aumento do formato para os campos crapass.nrdocptl, crapttl.nrdocttl, 
 *			                   crapcje.nrdoccje, crapcrl.nridenti e crapavt.nrdocava
 *							  (Adriano - P339).
 *  			  09/10/2017 - Removendo os campos nrdoapto cddbloco nrcxapst do relatorio. (PRJ339 - Kelvin)
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
					
	$xmlObjeto = $GLOBALS['xmlObjeto']; 	
	
	$registros 	  	= $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$telefone	  	= $xmlObjeto->roottag->tags[1]->tags;
	$email  	  	= $xmlObjeto->roottag->tags[2]->tags;
	$bens  		  	= $xmlObjeto->roottag->tags[6]->tags;
	$identificacao	= $xmlObjeto->roottag->tags[11]->tags[0]->tags;
	$registro     	= $xmlObjeto->roottag->tags[12]->tags[0]->tags;
	$representantes	= $xmlObjeto->roottag->tags[13]->tags;
	/* $bens_rep	  	= $xmlObjeto->roottag->tags[14]->tags; */ 
	$referencias  	= $xmlObjeto->roottag->tags[14]->tags;
	$responsaveis 	= $xmlObjeto->roottag->tags[9]->tags;
	$poderes  		= $xmlObjeto->roottag->tags[15]->tags;
	
	// Inicializando variáveis
	//$GLOBALS['totalLinha'] 	= 69;
	$GLOBALS['totalLinha'] 	= 100000;
	$GLOBALS['numLinha']	= 0;
	$GLOBALS['numPagina'] 	= 1;	
	
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
					case 'REFERENCIAS ( PESSOAIS / COMERCIAIS / BANCARIAS )':
							if ( $GLOBALS['numLinha'] + 11 > $GLOBALS['totalLinha'] ) { $GLOBALS['numLinha'] = 70; escreveTitulo( $str ); return false; }
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
	
	$linha = preencheString('Razao  Social: '.getByTagName($identificacao,'nmprimtl'),76);
	escreveLinha( $linha );
	
	$linha = preencheString('Tipo Natureza: '.getByTagName($identificacao,'inpessoa').' - '.getByTagName($identificacao,'dspessoa'),76);
	escreveLinha( $linha );
	
	$linha = preencheString('Nome Fantasia: '.getByTagName($identificacao,'nmfansia'),76);
	escreveLinha( $linha );	
		
	$linha = '     C.N.P.J.: '.preencheString(getByTagName($identificacao,'nrcpfcgc'),38);
	$linha .= 'Consulta: '.preencheString(getByTagName($identificacao,'dtcnscpf'),12);
	escreveLinha( $linha );
		
	$linha = preencheString('Situacao: ',63,' ','D');	
	$linha .= preencheString(getByTagName($identificacao,'cdsitcpf').' '.getByTagName($identificacao,'dssitcpf'),12);	
	escreveLinha( $linha );
	
	escreveLinha( '' );
	
	$linha = preencheString('Natureza Juridica: '.getByTagName($identificacao,'natjurid').' '.getByTagName($identificacao,'dsnatjur'),76);
	escreveLinha( $linha );
	
	$linha = '     Qtd. Filiais: '.preencheString(getByTagName($identificacao,'qtfilial'),25);
	$linha .= 'Qtd. Funcionarios: '.preencheString(getByTagName($identificacao,'qtfuncio').'    ',12,' ','D');
	escreveLinha( $linha );
	
	$linha = preencheString(' Inicio Atividade: '.getByTagName($identificacao,'dtiniatv'),76);
	escreveLinha( $linha );
	
	$linha = preencheString('  Setor Economico: '.getByTagName($identificacao,'cdseteco').' - '.getByTagName($identificacao,'nmseteco'),76);
	escreveLinha( $linha );
	
	$linha = preencheString('   Ramo Atividade: '.getByTagName($identificacao,'cdrmativ').' - '.getByTagName($identificacao,'dsrmativ'),76);
	escreveLinha( $linha );
	
	escreveLinha( '' );
	
	$linha = preencheString('Endereco na Internet(Site): '.getByTagName($identificacao,'dsendweb'),76);
	escreveLinha( $linha );
			
	$linha = 'Nome Talao: '.preencheString(getByTagName($identificacao,'nmtalttl'),40);	
	$linha .= ' Qtd. Folhas Talao: '.preencheString(getByTagName($identificacao,'qtfoltal'),2);	
	escreveLinha( $linha );
	
	//**********************************************************REGISTRO**********************************************************
	
	escreveTitulo('REGISTRO');
	
	$linha = '    Faturamento Ano: '.preencheString(number_format(str_replace(',','.',getByTagName($registro,'vlfatano')),2,',','.'),22,' ','C');	
	$linha .= ' Capital Realizado: '.preencheString(number_format(str_replace(',','.',getByTagName($registro,'vlcaprea')),2,',','.'),13,' ','D');	
	escreveLinha( $linha );
	
	escreveLinha( '' );
	
	$linha = '           Registro: '.preencheString(getByTagName($registro,'nrregemp'),35);	
	$linha .= ' Data: '.preencheString(getByTagName($registro,'dtregemp'),14);	
	escreveLinha( $linha );
	
	$linha = preencheString('Orgao: ',63,' ','D');	
	$linha .= preencheString(getByTagName($registro,'orregemp'),12);	
	escreveLinha( $linha );
	
	escreveLinha( '' );
	
	$linha = 'Inscricao Municipal: '.preencheString(getByTagName($registro,'nrinsmun'),35);	
	$linha .= ' Data: '.preencheString(getByTagName($registro,'dtinsnum'),14);	
	escreveLinha( $linha );
	
	$linha = ' Inscricao Estadual: '.preencheString(getByTagName($registro,'nrinsest'),26);	
	$linha .= ' Optante REFIS: '.preencheString( getByTagName($registro,'flgrefis') ,14);	
	escreveLinha( $linha );
	
	$linha = 'Concentracao faturamento unico cliente: '.preencheString(number_format(str_replace(',','.',getByTagName($registro,'perfatcl')),2,',','.'),9);	
	$linha .= ' Numero NIRE: '.preencheString(getByTagName($registro,'nrcdnire'),14);	
	escreveLinha( $linha );
	
	//****************************************************REPRESENTANTE PROCURADOR****************************************************
	
	if ( count($representantes) != 0 ) {
		foreach( $representantes as $representante ) {
		
			escreveTitulo('REPRESENTANTE PROCURADOR');
			
			$linha = ' Conta/dv: '.preencheString(formataNumericos('zzz.zzz.zz9',getByTagName($representante->tags,'nrdctato'),'.'),38);	
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

			escreveLinha( '' );
						
			$linha = 'Data Nascimento: '.preencheString(getByTagName($representante->tags,'dtnascto'),15);	
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
			$linha .= ' Cargo: '.preencheString(getByTagName($representante->tags,'dsproftl'),39);
			escreveLinha( $linha );
	
			if(getByTagName($representante->tags,'flgdepec') == 'no'){
				$flgdepec = "NAO";
			}else{
				$flgdepec = "SIM";
			}
			
			$linha = preencheString( '$ Societ.: '.number_format(str_replace(',','.',getByTagName($representante->tags,'persocio')),2,',','.'),30);
			$linha .= 'Depend. Econ.: '.preencheString($flgdepec,3);	
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
					if((getByTagName($poder->tags,'nrctapro') == getByTagName($representante->tags,'nrdctato')) &&
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
						
			//******************************************************RESPONSAVEL LEGAL*******************************************************
			$GLOBALS['tipo'] = 'formulario';
			if ( count($responsaveis) != 0 ) {
				foreach( $responsaveis as $responsavel ) {
				    
					if( (getByTagName($responsavel->tags,'nrctamen') == getByTagName($representante->tags,'nrdctato') && getByTagName($responsavel->tags,'nrctamen') != 0) || 
						(getByTagName($representante->tags,'nrdctato') == 0 &&
						 str_replace('-','',str_replace('.','',getByTagName($responsavel->tags,'nrcpfmen'))) == str_replace('-','',str_replace('.','',getByTagName($representante->tags,'nrcpfcgc'))))){
							
							escreveLinha('RESPONSAVEL LEGAL');
							escreveLinha('');
							
							$linha = ' Conta/dv: '.preencheString(getByTagName($responsavel->tags,'nrdconta'),22);	
							$linha .= 'C.P.F.: '.preencheString(getByTagName($responsavel->tags,'nrcpfcgc'),36);	
							escreveLinha( $linha );
							
							$linha = '     Nome: '.preencheString(getByTagName($responsavel->tags,'nmrespon'),76);	
							escreveLinha( $linha );
							
							$linha = '  Documento: '.preencheString(getByTagName($responsavel->tags,'tpdeiden').' - '.getByTagName($responsavel->tags,'nridenti'),19);	
							$linha .= 'Org.Emi.: '.preencheString(getByTagName($responsavel->tags,'dsorgemi'),8);	
							$linha .= 'U.F.: '.preencheString(getByTagName($responsavel->tags,'cdufiden'),22);	
							escreveLinha( $linha );
							
							$linha = preencheString('Data Emi.: ',55,' ','D');	
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
							escreveLinha( $linha );
							
							$linha = preencheString( 'Filiacao: Mae: '.getByTagName($responsavel->tags,'nmmaersp'),76);	
							escreveLinha( $linha );
							
							$linha = preencheString( '          Pai: '.getByTagName($responsavel->tags,'nmpairsp'),76);	
							escreveLinha( $linha );
					
							escreveLinha( '' );
							
						}
				}	
			}
						
			
		}
		
	}
	
		
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
	
	$linha = 'Bairro: '.preencheString(getByTagName($registros,'nmbairro'),40);	
	escreveLinha( $linha );
	
	$linha  = 'Cidade: '.preencheString(getByTagName($registros,'nmcidade'),26);	
	$linha .= 'UF: '.preencheString(getByTagName($registros,'cdufende'),4);	
	
	escreveLinha( $linha );
	
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
	
	//********************************************************REFERENCIAS********************************************************
	$GLOBALS['flagRepete'] = true;
	$GLOBALS['titulo'] = 'REFERENCIAS ( PESSOAIS / COMERCIAIS / BANCARIAS )';
	$GLOBALS['tipo'] = 'formulario';
	escreveTitulo( $GLOBALS['titulo'] );
	if ( count($referencias) != 0 ) {
		foreach( $referencias as $referencia ) {
						
			
			$linha = ' Conta/DV: '.preencheString(getByTagName($referencia->tags,'nrdctato'),15);	
			$linha .= ' Nome: '.preencheString(getByTagName($referencia->tags,'nmdavali'),44);	
			escreveLinha( $linha );
			
			$linha = ' Empresa: '.preencheString(getByTagName($referencia->tags,'nmextemp'),35);	
			$linha .= ' Banco: '.preencheString(getByTagName($referencia->tags,'cddbanco').' '.getByTagName($referencia->tags,'dsdbanco'),13);	
			$linha .= ' Ag.: '.preencheString(getByTagName($referencia->tags,'cdagenci'),4,' ','D');	
			escreveLinha( $linha );
			
			$linha = preencheString('   Cargo:'.getByTagName($referencia->tags,'dsproftl'),76);	
			escreveLinha( $linha );
			
			escreveLinha( '' );
			
			$linha = '   CEP: '.preencheString(getByTagName($referencia->tags,'nrcepend'),15);	
			$linha .= 'Endereco: '.preencheString(getByTagName($referencia->tags,'dsendere'),43);	
			escreveLinha( $linha );
			
			$linha = '  Nro.: '.preencheString(getByTagName($referencia->tags,'nrendere'),12);	
			$linha .= 'Complemento: '.preencheString(getByTagName($referencia->tags,'complend'),43);	
			escreveLinha( $linha );
			
			$linha = 'Bairro: '.preencheString(getByTagName($referencia->tags,'nmbairro'),40);	
			escreveLinha( $linha );
			
			$linha  = 'Cidade: '.preencheString(getByTagName($referencia->tags,'nmcidade'),26);	
			$linha .= 'UF: '.preencheString(getByTagName($referencia->tags,'cdufende'),4);	
			escreveLinha( $linha );
			
			escreveLinha( '' );
			
			$linha = preencheString('Telefones: '.getByTagName($referencia->tags,'nrtelefo'),76);	
			escreveLinha( $linha );
			
			$linha = preencheString('   E_Mail: '.getByTagName($referencia->tags,'dsdemail'),76);	
			escreveLinha( $linha );
			
			escreveLinha( '' );
		}	
	}
	$GLOBALS['flagRepete'] = false;
	//******************************************************************************************************************************
	escreveLinha( '' );
	escreveLinha( '' );
	
	$linha = preencheString( getByTagName($registros,'dsmvtolt') ,76);	
	escreveLinha( $linha );
		
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
	
	echo '</pre>';
?>