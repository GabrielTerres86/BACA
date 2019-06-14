<?php
	/*!
	 * FONTE        : manter_usuario.php
	 * CRIAÇÃO      : Diego Simas (AMcom)
	 * DATA CRIAÇÃO : 26/05/2018
	 * OBJETIVO     : Mantem informações de usuários
	 * --------------
	 * ALTERAÇÕES   : 
	 * --------------
	 */
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");	
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$cddopcao     = (isset($_POST['cddopcao']))     ? $_POST['cddopcao']     : 'C';
	$cdusuario    = (isset($_POST['cdusuario'])) 	? $_POST['cdusuario']    : 0;     
	$senhaNova    = (isset($_POST['senha']))     	? $_POST['senha']        : '';
	$tipo         = (isset($_POST['tipo']))      	? $_POST['tipo']         : 0;
	$vinculo      = (isset($_POST['vinculo']))   	? $_POST['vinculo']      : 0;
	$ativo        = (isset($_POST['ativo']))     	? $_POST['ativo']        : 0;
	$bloqueio     = (isset($_POST['bloqueio'])) 	? $_POST['bloqueio']     : 0;
	$senhaUsuario = (isset($_POST['senhaUsuario'])) ? $_POST['senhaUsuario'] : '';

	$senhaNova = trim($senhaNova);
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") {
	   exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	   exit();
    }

	if(empty($senhaNova) || is_null($senhaNova)){
		$senhaFormatada = $senhaUsuario;
	}else{
		$senhaFormatada = md5($senhaNova);		
	}

	// Monta o xml de requisição
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Dados>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "		<cdusuario>".$cdusuario."</cdusuario>";
	$xml .= "		<senha>".$senhaFormatada."</senha>";
	$xml .= "		<tipo>".$tipo."</tipo>";
	$xml .= "		<vinculo>".$vinculo."</vinculo>";
	$xml .= "		<ativo>".$ativo."</ativo>";
	$xml .= "		<bloqueio>".$bloqueio."</bloqueio>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	$xmlResult = mensageria($xml,"TELA_ATENDA_CVNCDC","MANTER_USUARIOS", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
    
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){
		$msgErro = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		if ($msgErro == "") {
				$msgErro = $xmlObjeto->roottag->tags[0]->cdata;
		}
		exibirErro('error',utf8_encode(str_replace("\"", "",$msgErro)),'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
		exit();
	}
	exibirErro('inform','Dados alterado com sucesso.','Alerta - Aimaro','acessaOpcaoAba(\'U\',3);', false);
?>