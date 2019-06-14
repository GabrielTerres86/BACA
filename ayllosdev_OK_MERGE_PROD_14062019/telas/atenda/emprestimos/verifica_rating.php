<? 
/*!
 * FONTE        : verifica_rating.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 06/04/2011 
 * OBJETIVO     : Busca as críticas do rating
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 000: [10/11/2011] Alterando rotina para listar o Rating - Marcelo L. Pereira (GATI)
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
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : ''; 
	$tpctrrat = (isset($_POST['tpctrrat'])) ? $_POST['tpctrrat'] : ''; 	
    $nrctremp = (isset($_POST['nrctremp'])) ? $_POST['nrctremp'] : '';
			
	// Monta o xml de requisição
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0043.p</Bo>";
	$xml .= "		<Proc>lista_criticas</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";	
	$xml .= "		<inproces>".$glbvars["inproces"]."</inproces>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<tpctrrat>".$tpctrrat."</tpctrrat>";
	$xml .= "		<nrctrrat>".$nrctremp."</nrctrrat>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjRating = getObjectXML($xmlResult);
	
	$critica = $xmlObjRating->roottag->tags[0]->tags;
		
	if( count($critica)>0 ){
		
		function exibeErro($msgErro) { 
			echo 'hideMsgAguardo();';
			echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
			exit();
		}
		
		include ('rating.php');

	}else{
		?><script type="text/javascript">controlaOperacao('DIV_IMP');</script><?
	}
		
?>