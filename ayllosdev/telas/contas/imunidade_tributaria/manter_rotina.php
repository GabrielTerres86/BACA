<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Lucas R. (CECRED)
 * DATA CRIAÇÃO : Julho/2013
 * OBJETIVO     : Rotina de imunidade tributaria da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 20/09/2013 - Corrigindo os campos cddentid e cdsitcad
					   	  	   para exibir os dados que vem da base e mostrar corretamente
					 		   na tela (André Santos/ SUPERO)
 *							  
 *                28/09/2015 - Reformulacao cadastral (Gabriel-RKAM).				 
 * --------------
 *
 */	
?>

<?	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	$nrcpfcgc = $_POST["nrcpfcgc"];
	$cdsitcad		= (isset($_POST['cdsitcad'])) ? $_POST['cdsitcad'] : 99 ;
    $cddentid		= (isset($_POST['cddentid'])) ? $_POST['cddentid'] : 99 ;
	$flgContinuar   = $_POST['flgContinuar'];
	$flgcadas       = $_POST['flgcadas'];
    	
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0159.p</Bo>";					
	$xml .= "		<Proc>gravar-imunidade</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<nrcpfcgc>".$nrcpfcgc."</nrcpfcgc>";
	$xml .= "		<cdsitcad>".$cdsitcad."</cdsitcad>";
	$xml .= "		<cddentid>".$cddentid."</cddentid>";
	$xml .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObject = getObjectXML($xmlResult);
			
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
	} else {
		
		$metodo = ($flgcadas == 'M' || $flgContinuar == 'true') ? 'proximaRotina();' : 'hideMsgAguardo();bloqueiaFundo(divRotina);';
		
		echo 'showError("inform","Operação efetuada com sucesso.","Informação - Contas","' . $metodo . '");';
	}
	
	function exibeErro($msgErro) {
		echo 'showError("error"," '.$msgErro.'","Alerta - Contas","$(\'#cddentid\',\'#frmImunidade\').focus();hideMsgAguardo();bloqueiaFundo(divRotina);");';
		exit();	
	}
	
?>
