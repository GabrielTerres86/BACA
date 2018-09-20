<?php
	//************************************************************************//
	//*** Fonte: valida_senha_ura.php                                      ***//
	//*** Autor: Lucas Reinert                                             ***//
	//*** Data : Janeiro/2014               Ultima Alteracao: --/--/----   ***//
	//***                                                                  ***//
	//*** Objetivo  : Validar criacao/alteracao da senha de Tele 		   ***//
	//***             Atendimento.                                         ***//
	//***                                                                  ***//	
	//*** Alteracoes: Corrigi o retorno XML e as variaveis vindas do post  ***//
	//***			  SD 479874 (Carlos R.)								   ***//	
	//***                                                                  ***//	
	//************************************************************************//
 
	session_start();
	
	// Includes para controle da session, variaveis globais de controle, biblioteca de funcoes e leitura do xml de retorno
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	
	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();		
	
	// Verifica se operador possui acesso a opcao
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$_POST["cddopcao"])) <> "") {
		exibeErro($msgError);		
	}	
	
	$cddsenha = (isset($_POST['cddsenha'])) ? $_POST['cddsenha'] : '';
	$cddsenh2 = (isset($_POST['cddsenh2'])) ? $_POST['cddsenh2'] : '';
	$frmSenha = (isset($_POST['frmSenha'])) ? $_POST['frmSenha'] : '';
		
	// Monta o xml de requisição
	$xml = '';
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0015.p</Bo>";
	$xml .= "		<Proc>valida_senha_ura</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";		
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cddsenha>".$cddsenha."</cddsenha>";
	$xml .= "		<cddsenh2>".$cddsenh2."</cddsenh2>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
	
	if ( isset($xmlObj->roottag->tags[0]->name) && strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO' ) {
	
		$msgErro  = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Aimaro','$(\'#cddsenh1\',\'#'.$frmSenha.'\').focus();limpaCamposSenha();blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')));',false);		
	}
	
	echo 'criarAlterarSenhaURA();';
?>	