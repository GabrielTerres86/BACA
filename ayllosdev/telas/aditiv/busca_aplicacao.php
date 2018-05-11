<? 
/*!
 * FONTE        : busca_aplicacao.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 20/10/2011 
 * OBJETIVO     : Rotina para busca das aplicacoes
 * --------------
 * ALTERAÇÕES   : 01/11/2017 - Passagem do tpctrato. (Jaison/Marcos Martini - PRJ404)
 * -------------- 
 */
?>
 
<?
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Guardo os parâmetos do POST em variáveis	
	$cddopcao  = (isset($_POST['cddopcao']))  ? $_POST['cddopcao'] : '';
	$nrdconta  = (isset($_POST['nrdconta']))  ? $_POST['nrdconta'] : 0 ;
	$nrctremp  = (isset($_POST['nrctremp']))  ? $_POST['nrctremp'] : 0 ; 
	$nraditiv  = (isset($_POST['nraditiv']))  ? $_POST['nraditiv'] : 0 ;
	$cdaditiv  = (isset($_POST['cdaditiv']))  ? $_POST['cdaditiv'] : 0 ;
	$tpaplica  = (isset($_POST['tpaplica']))  ? $_POST['tpaplica'] : '';
	$nrctagar  = (isset($_POST['nrctagar']))  ? $_POST['nrctagar'] : 0 ;
	$tpctrato  = (isset($_POST['tpctrato']))  ? $_POST['tpctrato'] : 0 ;
	
	switch ($tpaplica) {
	 case '1': $rgaplica  = (!empty($_POST['tpaplic1']))  ? arrayTipo('1', $_POST['tpaplic1']) : array(); break;
	 case '3': $rgaplica  = (!empty($_POST['tpaplic3']))  ? arrayTipo('3', $_POST['tpaplic3']) : array(); break;
	 case '5': $rgaplica  = (!empty($_POST['tpaplic5']))  ? arrayTipo('5', $_POST['tpaplic5']) : array(); break;
	 case '7': $rgaplica  = (!empty($_POST['tpaplic7']))  ? arrayTipo('7', $_POST['tpaplic7']) : array(); break;
	 case '8': $rgaplica  = (!empty($_POST['tpaplic8']))  ? arrayTipo('8', $_POST['tpaplic8']) : array(); break;
	}
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0115.p</Bo>";
	$xml .= "        <Proc>Busca_Dados</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
	$xml .= '		<inproces>'.$glbvars['inproces'].'</inproces>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';	
	$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';	
	$xml .= '		<dtmvtolx>'.$dtmvtolx.'</dtmvtolx>';	
	$xml .= '		<nraditiv>'.$nraditiv.'</nraditiv>';	
	$xml .= '		<cdaditiv>'.$cdaditiv.'</cdaditiv>';
	$xml .= '		<tpaplica>'.$tpaplica.'</tpaplica>';
	$xml .= '		<nrctagar>'.$nrctagar.'</nrctagar>';
	$xml .= '		<tpctrato>'.$tpctrato.'</tpctrato>';
	$xml .= "  </Dados>";
	$xml .= "</Root>";	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','',false);
	}

	$aplicacao	= $xmlObj->roottag->tags[1]->tags;
	include("tab_aplicacao.php");
	
	function arrayTipo($tpaplica, $contrato) {
		$rgaplica 	= array();
		$contrato 	= trim($contrato);
		$qtcontra	= explode('/', $contrato);
		
		foreach ( $qtcontra as $nraplica ) {
			$i = count($rgaplica);			
			$rgaplica[$i]['tpaplica'] = $tpaplica; 
			$rgaplica[$i]['nraplica'] = $nraplica; 
		}
		return $rgaplica;
	}
		
?>