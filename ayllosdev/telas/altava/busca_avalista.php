<? 
/*!
 * FONTE        : busca_avalista.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 21/12/2011 
 * OBJETIVO     : Rotina para busca 
 */
?>

<?	
	
	session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$procedure = ''; 
	$retornoAposErro= '';
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],'A')) <> '') {		
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Cabecalho>";
	$xml .= "	    <Bo>b1wgen0126.p</Bo>";
	$xml .= "        <Proc>Busca_Contrato</Proc>";
	$xml .= "  </Cabecalho>";
	$xml .= "  <Dados>";
	$xml .= "       <cdcooper>".$glbvars['cdcooper']."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars['cdagenci']."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars['nrdcaixa']."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars['cdoperad']."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars['nmdatela']."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars['idorigem']."</idorigem>";	
	$xml .= "		<dtmvtolt>".$glbvars['dtmvtolt']."</dtmvtolt>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";	
	$xml .= "		<nrctremp>".$nrctremp."</nrctremp>";	
	$xml .= "  </Dados>";
	$xml .= "</Root>";	

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
		exibirErro('error',$xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$retornoAposErro,false);
	}

	$registro 	= $xmlObj->roottag->tags[0]->tags;
	include('form_avalista.php');

	
?>