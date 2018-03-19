<?php

/* !
 * FONTE        : manter_rotina.php
 * CRIACAO      : Luis Fernando - (GFT)
 * DATA CRIACAO : 16/03/2018
 * OBJETIVO     : Rotinas de ajax para a tela CADPCP
 * --------------
 */
session_start();	
require_once('../../includes/config.php');
require_once('../../includes/funcoes.php');		
require_once('../../includes/controla_secao.php');
require_once('../../class/xmlfile.php');
isPostMethod();	

$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
$nrinssac = (isset($_POST['nrinssac'])) ? $_POST['nrinssac'] : '';
$vlpercen = (isset($_POST['vlpercen'])) ? $_POST['vlpercen'] : '';
$form = (isset($_POST['frmOpcao'])) ? $_POST['frmOpcao'] : '';
$operacao = $_POST['operacao'];

switch ($operacao){
	case 'BA':
		if (!validaInteiro($nrdconta) || $nrdconta == 0) exibirErro('error','Informe o número da conta.','Alerta - Ayllos','$(\'#nrdconta\', \'#'.$form.'\').focus()',false);
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		$xmlResult = mensageria($xml, "TELA_CADPCP", "CADPCP_BUSCA_CONTA", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto 	= getObjectXML($xmlResult);		

		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
			$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
			exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#nrdconta\', \'#'.$form.'\').focus()',false);
		} 
			
		$nmprimtl	= getByTagname($xmlObjeto->roottag->tags[0]->tags,'nmprimtl');

		echo "$('#nmprimtl', '#$form').val('$nmprimtl');";
		echo "controlaOpcao();";
	break;
	case 'BP':
		if (!validaInteiro($nrdconta) || $nrdconta == 0) exibirErro('error','Informe o número da conta.','Alerta - Ayllos','$(\'#nrdconta\', \'#'.$form.'\').focus()',false);
		if (!validaInteiro($nrinssac) || $nrinssac == 0) exibirErro('error','Informe o número do CPF/CNPJ.','Alerta - Ayllos','$(\'#nrinssac\', \'#'.$form.'\').focus()',false);
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<nrinssac>".$nrinssac."</nrinssac>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		$xmlResult = mensageria($xml, "TELA_CADPCP", "CADPCP_OBTER_PAGADOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto 	= getObjectXML($xmlResult);		

		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
			$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
			exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#nrinssac\', \'#'.$form.'\').val(\'\').focus()',false);
		} 
			
		$nmdsacad	= getByTagname($xmlObjeto->roottag->tags[0]->tags,'nmdsacad');
		$vlpercen	= getByTagname($xmlObjeto->roottag->tags[0]->tags,'vlpercen');

		echo "$('#nmdsacad', '#$form').val('$nmdsacad');";
		echo "$('#vlpercen', '#$form').val('$vlpercen');";
		echo "controlaOpcao();";
	break;
	case 'AP':
		if (!validaInteiro($nrdconta) || $nrdconta == 0) exibirErro('error','Informe o número da conta.','Alerta - Ayllos','$(\'#nrdconta\', \'#'.$form.'\').focus()',false);
		if (!validaInteiro($nrinssac) || $nrinssac == 0) exibirErro('error','Informe o número do CPF/CNPJ.','Alerta - Ayllos','$(\'#nrinssac\', \'#'.$form.'\').focus()',false);
		if (!validaInteiro($vlpercen) || $vlpercen == 0) exibirErro('error','Informe o número do CPF/CNPJ.','Alerta - Ayllos','$(\'#vlpercen\', \'#'.$form.'\').focus()',false);
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<nrinssac>".$nrinssac."</nrinssac>";
		$xml .= "		<vlpercen>".$vlpercen."</vlpercen>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";
		$xmlResult = mensageria($xml, "TELA_CADPCP", "CADPCP_ALTERAR_PAGADOR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		$xmlObjeto 	= getObjectXML($xmlResult);		

		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
			$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
			exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'#vlpercen\', \'#'.$form.'\').val(\'\').focus()',false);
		} 

		echo "$('#nmdsacad', '#$form').val('');";
		echo "$('#vlpercen', '#$form').val('');";
        echo "showError('inform','Altera&ccedil;&atilde;o realizada com sucesso','Alerta - Ayllos','estadoInicial();')";

	break;
	default:
			exibirErro('error','Selecione a operacao','Alerta - Ayllos','',false);
	break;
}