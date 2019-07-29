<? 
/*!
 * FONTE        : busca_avalista.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 01/04/2011 
 * OBJETIVO     : Rotina de busca de avalistas
 *
 * 000: [15/07/2014] Incluso novos campos( inpessoa e dtnascto ) na carga array (Daniel).
 * 001: [08/05/2017] Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
 * 002: [22/10/2018] Adicionado campo Conta Conjuge e Renda Conjuge. (Mateus Z / Mouts) 
 
 */	
?>
 
<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : ''; 
	$nrctaava = (isset($_POST['nrctaava'])) ? $_POST['nrctaava'] : ''; 
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : ''; 
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	
	$indxaval = (isset($_POST['indxaval'])) ? $_POST['indxaval'] : 0;
		
	echo 'arrayFiadores.length = 0;';
	echo 'arrayAvalBusca.length = 0;';
		
	// Monta o xml de requisição
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0002.p</Bo>";
	$xml .= "		<Proc>verifica-traz-avalista</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xml .= "		<dtmvtopr>".$glbvars["dtmvtopr"]."</dtmvtopr>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<nrctaava>".$nrctaava."</nrctaava>";
	$xml .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		echo '__last_avalista.lastMessage = "'.$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata.'";'; //bruno - prj 438 - bug 14444
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina); $(\'#nrcpfcgc\', \'#frmDadosAval\').focus();',false);
	}
	
	$avalista = $xmlObj->roottag->tags[0]->tags[0]->tags;
	$fiadores = $xmlObj->roottag->tags[1]->tags;
	$bens 	  = $xmlObj->roottag->tags[2]->tags;
	
	if( count($avalista) == 0 ){
		exibirErro('error','Nenhum avalista terceiro foi encontrado.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	}else if (in_array($operacao,array('AI_DADOS_AVAL','A_DADOS_AVAL','I_DADOS_AVAL','IA_DADOS_AVAL'))){
			
		echo 'arrayAvalBusca.length = 0;';
		
		echo 'arrayAvalBusca[\'nrctaava\'] = "'. getByTagName($avalista,'nrctaava').'" ;';
		echo 'arrayAvalBusca[\'cdnacion\'] = "'. getByTagName($avalista,'cdnacion').'" ;';
		echo 'arrayAvalBusca[\'dsnacion\'] = "'. getByTagName($avalista,'dsnacion').'" ;';
		echo 'arrayAvalBusca[\'tpdocava\'] = "'. getByTagName($avalista,'tpdocava').'" ;';
		echo 'arrayAvalBusca[\'nmconjug\'] = "'. getByTagName($avalista,'nmconjug').'" ;';
		echo 'arrayAvalBusca[\'tpdoccjg\'] = "'. getByTagName($avalista,'tpdoccjg').'" ;';
		echo 'arrayAvalBusca[\'dsendre1\'] = "'. getByTagName($avalista,'dsendre1').'" ;';
		echo 'arrayAvalBusca[\'nrfonres\'] = "'. getByTagName($avalista,'nrfonres').'" ;';
		echo 'arrayAvalBusca[\'nmcidade\'] = "'. getByTagName($avalista,'nmcidade').'" ;';
		echo 'arrayAvalBusca[\'nrcepend\'] = "'. getByTagName($avalista,'nrcepend').'" ;';
		echo 'arrayAvalBusca[\'vlrenmes\'] = "'. getByTagName($avalista,'vlrenmes').'" ;';
		echo 'arrayAvalBusca[\'nmdavali\'] = "'. getByTagName($avalista,'nmdavali').'" ;';
		echo 'arrayAvalBusca[\'nrcpfcgc\'] = "'. getByTagName($avalista,'nrcpfcgc').'" ;';
		echo 'arrayAvalBusca[\'nrdocava\'] = "'. getByTagName($avalista,'nrdocava').'" ;';
		echo 'arrayAvalBusca[\'nrcpfcjg\'] = "'. getByTagName($avalista,'nrcpfcjg').'" ;';
		echo 'arrayAvalBusca[\'nrdoccjg\'] = "'. getByTagName($avalista,'nrdoccjg').'" ;';
		echo 'arrayAvalBusca[\'dsendre2\'] = "'. getByTagName($avalista,'dsendre2').'" ;';
		echo 'arrayAvalBusca[\'dsdemail\'] = "'. getByTagName($avalista,'dsdemail').'" ;';
		echo 'arrayAvalBusca[\'cdufresd\'] = "'. getByTagName($avalista,'cdufresd').'" ;';
		echo 'arrayAvalBusca[\'vledvmto\'] = "'. getByTagName($avalista,'vledvmto').'" ;';
		echo 'arrayAvalBusca[\'nrendere\'] = "'. getByTagName($avalista,'nrendere').'" ;';
		echo 'arrayAvalBusca[\'complend\'] = "'. getByTagName($avalista,'complend').'" ;';
		echo 'arrayAvalBusca[\'nrcxapst\'] = "'. getByTagName($avalista,'nrcxapst').'" ;';
		
		// Daniel
		echo 'arrayAvalBusca[\'inpessoa\'] = "'. getByTagName($avalista,'inpessoa').'" ;';
		echo 'arrayAvalBusca[\'dtnascto\'] = "'. getByTagName($avalista,'dtnascto').'" ;';
		
		// PRJ 438
		echo 'arrayAvalBusca[\'vlrencjg\'] = "'. getByTagName($avalista,'vlrencjg').'" ;';
		echo 'arrayAvalBusca[\'nrctacjg\'] = "'. getByTagName($avalista,'nrctacjg').'" ;';

		echo 'arrayFiadores.length = 0;';
		
		for($i = 0; $i<count($fiadores); $i++){
		
			$identificador = $i.getByTagName($fiadores[$i]->tags,'nrdconta');
													
			echo 'var arrayFiador'.$identificador.' = new Object();';
					
			echo 'arrayFiador'.$identificador.'[\'nrdconta\'] = "'.formataContaDV(getByTagName($fiadores[$i]->tags,'nrdconta')).'";';
			echo 'arrayFiador'.$identificador.'[\'nrctremp\'] = "'.getByTagName($fiadores[$i]->tags,'nrctremp').'";';
			echo 'arrayFiador'.$identificador.'[\'dtmvtolt\'] = "'.getByTagName($fiadores[$i]->tags,'dtmvtolt').'";';
			echo 'arrayFiador'.$identificador.'[\'vlemprst\'] = "'.getByTagName($fiadores[$i]->tags,'vlemprst').'";';
			echo 'arrayFiador'.$identificador.'[\'qtpreemp\'] = "'.getByTagName($fiadores[$i]->tags,'qtpreemp').'";';
			echo 'arrayFiador'.$identificador.'[\'vlpreemp\'] = "'.getByTagName($fiadores[$i]->tags,'vlpreemp').'";';
			echo 'arrayFiador'.$identificador.'[\'vlsdeved\'] = "'.getByTagName($fiadores[$i]->tags,'vlsdeved').'";';
			
			echo 'arrayFiadores['.$i.'] = arrayFiador'.$identificador.';';
				
		}
						
		echo 'arrayBemBusca.length = 0;';

		for($j = 0; $j<count($bens); $j++){
		
			$identificador = $j.getByTagName($bens[$j]->tags,'nrdconta').getByTagName($bens[$j]->tags,'nrcpfcgc');
												
			echo 'var arrayBemAval'.$identificador.' = new Object();';
					
			echo 'arrayBemAval'.$identificador.'[\'cdcooper\'] = "'.getByTagName($bens[$j]->tags,'cdcooper').'";';   
			echo 'arrayBemAval'.$identificador.'[\'nrdconta\'] = "'.getByTagName($bens[$j]->tags,'nrdconta').'";';   
			echo 'arrayBemAval'.$identificador.'[\'idseqttl\'] = "'.getByTagName($bens[$j]->tags,'idseqttl').'";';   
			echo 'arrayBemAval'.$identificador.'[\'dtmvtolt\'] = "'.getByTagName($bens[$j]->tags,'dtmvtolt').'";';   
			echo 'arrayBemAval'.$identificador.'[\'cdoperad\'] = "'.getByTagName($bens[$j]->tags,'cdoperad').'";';   
			echo 'arrayBemAval'.$identificador.'[\'dtaltbem\'] = "'.getByTagName($bens[$j]->tags,'dtaltbem').'";';   
			echo 'arrayBemAval'.$identificador.'[\'idseqbem\'] = "'.getByTagName($bens[$j]->tags,'idseqbem').'";';   
			echo 'arrayBemAval'.$identificador.'[\'dsrelbem\'] = "'.getByTagName($bens[$j]->tags,'dsrelbem').'";';   
			echo 'arrayBemAval'.$identificador.'[\'persemon\'] = "'.getByTagName($bens[$j]->tags,'persemon').'";';   
			echo 'arrayBemAval'.$identificador.'[\'qtprebem\'] = "'.getByTagName($bens[$j]->tags,'qtprebem').'";';   
			echo 'arrayBemAval'.$identificador.'[\'vlrdobem\'] = "'.getByTagName($bens[$j]->tags,'vlrdobem').'";';   
			echo 'arrayBemAval'.$identificador.'[\'vlprebem\'] = "'.getByTagName($bens[$j]->tags,'vlprebem').'";';   
			echo 'arrayBemAval'.$identificador.'[\'nrdrowid\'] = "'.getByTagName($bens[$j]->tags,'nrdrowid').'";';   
			echo 'arrayBemAval'.$identificador.'[\'nrcpfcgc\'] = "'.getByTagName($bens[$j]->tags,'nrcpfcgc').'";';   
								
			echo 'arrayBemBusca['.$j.'] = arrayBemAval'.$identificador.';';
								
		}
		
	}
		
?>
