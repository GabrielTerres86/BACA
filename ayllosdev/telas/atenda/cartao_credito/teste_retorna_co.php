<?
/*!
 * FONTE        : retorna_co.php
 * CRIAÇÃO      : James Prust Júnior
 * DATA CRIAÇÃO : Junho/2014
 * OBJETIVO     : Confirma troca de senha na CABAL
 * --------------
 * ALTERAÇÕES   :
 * --------------
 */
 	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	/*require_once('../../../includes/controla_secao.php');*/
	require_once('../../../class/xmlfile.php');
	require_once('class_confirma_troca_senha_cabal.php');
	isPostMethod();	

	$sIdentificadorTransacao = $_POST['identificadorTransacao'];
	$sNumeroCartao			 = $_POST['numeroCartao'];	
	
	if ($sIdentificadorTransacao == ""){
		exibirErro('error','Identificador inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina);',false);	
	}
	
	if (!validaInteiro($sNumeroCartao)){
		exibirErro('error','N&uacute;mero do cart&atilde;o inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina);',false);	
	}	
	
	$aParametros = array();
	$aParametros['identificadorDaTransacao'] = $sIdentificadorTransacao;
	$aParametros['panNumeroCartao'] 		 = $sNumeroCartao;
	
	$oConfirmaTrocaSenhaCabal = new ConfirmaTrocaSenhaCabal();
	$oConfirmaTrocaSenhaCabal->confirmarTrocaDeSenha($aParametros);
	
	// Melhorar a mensagem para informar se eh Alteracao de senha ou Confirmacao de senha, pois sera o mesmo
	switch($oConfirmaTrocaSenhaCabal->getCodigoRetorno()){
	
		// Sucesso
		case 0:
			// Gerar o script JSON para utilizar no javascript
			echo "bRetorno = true;";
		break;
	
		default:
			exibirErro('error',$oConfirmaTrocaSenhaCabal->getCodigoRetorno()." - Erro ao alterar senha.",'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
		break;
	}
?>