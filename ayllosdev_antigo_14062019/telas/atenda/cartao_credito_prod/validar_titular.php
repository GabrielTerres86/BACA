<?
/*!
 * FONTE        : validar_titular.php
 * CRIAÇÃO      : Jean Michel
 * DATA CRIAÇÃO : Marco/2014
 * OBJETIVO     : Validar Titular p/ novo cartão - rotina de Cartão de Crédito da tela ATENDA
 * --------------
 * ALTERAÇÕES   :
 * --------------
          17/06/2016 - M181 - Alterar o CDAGENCI para          
                      passar o CDPACTRA (Rafael Maciel - RKAM) 
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
	
	// Verifica permissão
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"N")) <> "") {
		exibirErro('error',$msgError,'Alerta - Aimaro',$funcaoAposErro,false);
	}	
	
	// Verifica se os parâmetros necessários foram informados
	if (!isset($_POST["nrdconta"])) {
		exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro',$funcaoAposErro,false);
	}	

	$nrdconta = $_POST["nrdconta"];

	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro',$funcaoAposErro,false);
	
    // Monta o xml de requisição
	$xmlSetCartao  = "";
	$xmlSetCartao .= "<Root>";
	$xmlSetCartao .= "	<Cabecalho>";
	$xmlSetCartao .= "		<Bo>b1wgen0028.p</Bo>";
	$xmlSetCartao .= "		<Proc>valida_nova_proposta</Proc>";
	$xmlSetCartao .= "	</Cabecalho>";
	$xmlSetCartao .= "	<Dados>";
	$xmlSetCartao .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlSetCartao .= "		<cdagenci>".$glbvars["cdpactra"]."</cdagenci>";
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

	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCartao->roottag->tags[0]->name) == "ERRO") {
		exibirErro('error',$xmlObjCartao->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$funcaoAposErro,false);	
	} 	

	// Mostra se Bo retornar mensagem de atualização de cadastro
	$idconfir = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[0]->cdata;
	$dsmensag = $xmlObjCartao->roottag->tags[0]->tags[0]->tags[1]->cdata;
	
	if ($inpessoa <> "1") {		
	
		echo 'habilitaAvalista(true);';
		echo 'hideMsgAguardo();';
		echo 'bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false);';		
		
		// Mostra mensagem de confirmação para finalizar a operação
		echo "showConfirmacao('".(trim($dsmensag) <> "" ? $dsmensag."<br><br>" : "")."Deseja cadastrar a proposta de novo cart&atilde;o de cr&eacute;dito?','Confirma&ccedil;&atilde;o - Aimaro','cadastrarNovoCartao()','bloqueiaFundo(divRotina)','sim.gif','nao.gif');";		
		exit();
		
	} else {
	
		echo '$("#divDadosNovoCartao").css("display","none");';
		echo '$("#divDadosAvalistas").css("display","block");';

		echo 'habilitaAvalista(true);';
		echo 'hideMsgAguardo();';
		echo 'bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false);';

		// Mostra a mensagem de informação para verificar atualização cadastral se for adm BB
		if ($idconfir == 1) {
			echo 'showError("inform","'.$dsmensag.'","Alerta - Aimaro","bloqueiaFundo(divRotina,\'nrctaav1\',\'frmNovoCartao\',false)");';		
		} 	
	}
	
?>