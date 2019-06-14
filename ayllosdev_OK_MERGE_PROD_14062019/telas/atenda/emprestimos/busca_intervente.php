<? 
/*!
 * FONTE        : busca_intervente.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 10/03/2011 
 * OBJETIVO     : Rotina de busca de intervenientes
 *
 *
 *    ALTERAÇÕES: 29/10/2013 - Ajuste para alimentar o arrayAvalBusca somente se for encontrado algum 
							   interveniente (Adriano).
 *                08/05/2017 - Buscar a nacionalidade com CDNACION. (Jaison/Andrino)
 *                22/10/2018 - Adicionado campo Tipo Natureza e Conta Conjuge. (Mateus Z / Mouts)
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
				
	// Monta o xml de requisição
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0002.p</Bo>";
	$xml .= "		<Proc>consulta-avalista</Proc>";
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
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina); $(\'#nrcpfcgc\', \'#frmIntevAnuente\').focus();',false);
	}
	
	$avalista = $xmlObj->roottag->tags[0]->tags[0]->tags;
	
	if( count($avalista) > 0 ){
	
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
						
		//PRJ 438
		echo 'arrayAvalBusca[\'inpessoa\'] = "'. getByTagName($avalista,'inpessoa').'" ;';
		echo 'arrayAvalBusca[\'nrctacjg\'] = "'. getByTagName($avalista,'nrctacjg').'" ;';				

	}
		
?>