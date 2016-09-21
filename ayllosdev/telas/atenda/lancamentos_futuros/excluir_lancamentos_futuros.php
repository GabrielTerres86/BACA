<?php
/*!
 * FONTE        : excluir_lancamentos_futuros.php
 * CRIA��O      : DESCONHECIDO
 * DATA CRIA��O : DESCONHECIDO
 * OBJETIVO     : Rotina para exclusao do lancamento futuro.
 * --------------
 * ALTERA��ES   : 31/05/2016 - Inclusao de verificacao de permissao de acesso. (Jaison/James)
 * -------------- 
 */
	session_start();	
	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo metodo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");		
	
    if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"E",false)) <> "") {
        exibeErro($msgError);
	}
	
    // Se parametros necessarios nao foram informados
	if (!isset($_POST["dstabela"]) || !isset($_POST["cdhistor"]) || !isset($_POST["genrecid"])) {
		exibeErro("Par&acirc;metros incorretos.");
	}	
		
	$dstabela = $_POST["dstabela"];
	$cdhistor = $_POST["cdhistor"];
	$genrecid = $_POST["genrecid"];	
	
	// Monta o xml de requisi��o
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "  <Dados>";
	$xml .= "   <dstabela>".$dstabela."</dstabela>";
	$xml .= "   <cdhistor>".$cdhistor."</cdhistor>";
	$xml .= "   <genrecid>".$genrecid."</genrecid>";
	$xml .= "  </Dados>";
	$xml .= "</Root>";		
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "ATENDA", "EXCLAU", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	// Cria objeto para classe de tratamento de XML
	$xmlObj = getObjectXML($xmlResult);
			
	// Se ocorrer um erro, mostra critica
	if(strtoupper($xmlObj->roottag->tags[0]->name) == 'ERRO'){	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		
		exibeErro($msgErro);			
		exit();
	}		
	
	echo 'hideMsgAguardo();';
	echo 'blockBackground(parseInt($("#divRotina").css("z-index")));';
	$msgErro = 'Lancamento excluido com sucesso.';
	echo 'showError("inform","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';	
	echo "acessaOpcaoAba(1,0,0);";
	
	// Funcao para exibir erros na tela atraves de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}		
?>