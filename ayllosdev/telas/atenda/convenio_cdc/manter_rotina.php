<? 
/*!
 * FONTE        : mater_rotina.php
 * CRIAÇÃO      : Andre Santos (SUPERO)
 * DATA CRIAÇÃO : Janeiro/2015
 * OBJETIVO     : Mostrar opcao Principal da rotina de Convenio CDC da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */	
?>
<?	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");	
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$flgativo = (isset($_POST['flgativo'])) ? $_POST['flgativo'] : '';
	$dtcnvcdc = (isset($_POST['dtcnvcdc'])) ? $_POST['dtcnvcdc'] : '';
    	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],'A')) <> "") 
	   exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
		
	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0194.p</Bo>";					
	$xml .= "		<Proc>pc-alterar-convenios</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= "		<flgativo>".$flgativo."</flgativo>";
	$xml .= "		<dtcnvcdc>".$dtcnvcdc."</dtcnvcdc>";
	$xml .= "		<cddopcao>A</cddopcao>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObject = getObjectXML($xmlResult);
			
	if (strtoupper($xmlObject->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObject->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	function exibeErro($msgErro) {
		echo 'showError("error"," '.$msgErro.'","Alerta - Contas","$(\'#flgrenli\',\'#frmConvenioCdc\').focus();hideMsgAguardo();bloqueiaFundo(divRotina);");';
	}
?>
