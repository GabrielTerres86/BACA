<?
/*!
 * FONTE        : validar_titular.php
 * CRIA��O      : Jean Michel
 * DATA CRIA��O : Marco/2014
 * OBJETIVO     : Validar Titular p/ novo cart�o - rotina de Cart�o de Cr�dito da tela ATENDA
 * --------------
 * ALTERA��ES   :
 * --------------
 * 000: ----- 
 */
?>

<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$funcaoAposErro = 'bloqueiaFundo(divRotina);';
	
	// Verifica permiss�o
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibirErro('error',$msgError,'Alerta - Ayllos',$funcaoAposErro,false);
	}	
	
	// Verifica se os par�metros necess�rios foram informados
	if (!isset($_POST["nrdconta"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos',$funcaoAposErro,false);
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se n�mero da conta � um inteiro v�lido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos',$funcaoAposErro,false);
	
    // Monta o xml de requisi��o
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>valida_nova_proposta</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlSetCartao .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlSetCartao .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xmlSetCartao .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlSetCartao .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlSetCartao .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xmlSetCartao .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlSetCartao .= "	</Dados>";
	$xmlSetCartao .= "</Root>";

	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlSetCartao);

    // Cria objeto para classe de tratamento de XML
	$xmlObjCartao = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$funcaoAposErro,false);	
	} 	

	// Mostra se Bo retornar mensagem de atualiza��o de cadastro
	$idconfir = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[0]->cdata;
	$dsmensag = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[1]->cdata;
	
	if ($inpessoa <> "1") {		
	
		echo 'habilitaAvalista(true);';
		echo 'hideMsgAguardo();';
		echo 'bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false);';		
		
		// Mostra mensagem de confirma��o para finalizar a opera��o
		echo "showConfirmacao('".(trim($dsmensag) <> "" ? $dsmensag."<br><br>" : "")."Deseja cadastrar a proposta de novo cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Ayllos','cadastrarNovoCartao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');";		
		exit();
		
	} else {
	
		echo '$("#divDadosNovoCartao").css("display","none");';
		echo '$("#divDadosAvalistas").css("display","block");';

		echo 'habilitaAvalista(true);';
		echo 'hideMsgAguardo();';
		echo 'bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false);';

		// Mostra a mensagem de informa��o para verificar atualiza��o cadastral se for adm BB
		if ($idconfir == 1) {
			echo 'showError("inform","'.$dsmensag.'","Alerta - Ayllos","bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false)");';		
		} 	
	}
	
?>