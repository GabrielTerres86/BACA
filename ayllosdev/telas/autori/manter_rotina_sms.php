<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 14/05/2011 
 * OBJETIVO     : Rotina para manter as operações da tela AUTORI
 * --------------
 * ALTERAÇÕES   : 19/05/2014 - Ajustes referentes ao Projeto debito Automatico
 * --------------			   Softdesk 148330 (Lucas R.)
 *
 *				  29/07/2015 - Incluir validação para variavel $mtdErro limpar o dshistor caso 
 *							   historico for zerado (Lucas Ranghetti #311450).
 * 
 *                15/10/2015 - Reformulacao cadastral (Gabriel-RKAM).
 */
?> 

<?	
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
		
	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '' ;
	
	$nrdddtfc = (isset($_POST['nrdddtfc'])) ? $_POST['nrdddtfc'] : '' ;
	$nrtelefo = (isset($_POST['nrtelefo'])) ? $_POST['nrtelefo'] : '' ;
	
	// Dependendo da operação, chamo uma procedure diferente
	$cddopcao = 'S';
	$procedure 	= '';
	$mtdErro	= '';
	switch($operacao) {
		case 'S1': $procedure = 'BUSCA_FONE_SMS_DEBAUT';
		           $mtdErro = 'unblockBackground();';
				   break;
		case 'S2': $procedure = 'MANTEM_FONE_SMS_DEBAUT';
		           $mtdErro = 'unblockBackground();';
				   break;
		case 'S3': $procedure = 'EXCLUI_FONE_SMS_DEBAUT';
		           $mtdErro = 'unblockBackground();';
				   break;
		default:   $mtdErro   = 'controlaOperacao(\'\');'; return false;
	}

	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Autori','',false);
	}
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "   <nrdddtfc>".$nrdddtfc."</nrdddtfc>";
	$xml .= "   <nrtelefo>".$nrtelefo."</nrtelefo>";
	$xml .= "   <flgacsms>1</flgacsms>"; // Fixo 1  - Evia SMS
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	// Chamada mensageria
    $xmlResult = mensageria($xml, "AUTORI", $procedure, $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	//----------------------------------------------------------------------------------------------------------------------------------	
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {	
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		$nmdcampo	= $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];
		if ( !empty($nmdcampo) ) { 
			$mtdErro = "$('#".$nmdcampo."','#frmSms').focus();";
		}
		exibirErro('error',$msgErro,'Alerta - Aimaro',$mtdErro,false);
	}
	
	$registro = $xmlObjeto->roottag->tags[0]->tags;
	
    switch($operacao) {
		case 'S2':
			echo "hideMsgAguardo();";
			echo 'showError("inform","Telefone cadastrado com sucesso.","Notifica&ccedil;&atilde;o - Aimaro","controlaOperacao(\'\');");';		
			break;
		case 'S3': 
			echo "hideMsgAguardo();";
			echo 'showError("inform","Telefone excluido com sucesso.","Notifica&ccedil;&atilde;o - Aimaro","controlaOperacao(\'\');");';		
			break;
	}
?>