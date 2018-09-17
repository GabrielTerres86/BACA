 <?php

	//************************************************************************//
	//*** Fonte: retorna_feriados.php                                
	//*** Autor: Tiago                                                     
	//*** Data : Abril/2012                  Ultima Alteracao:21/07/2016  
	//***
	//*** Objetivo  : Trazer todos os feriados a de ate 1 ano a frente da data de movimentacao do sistema (Tiago)
	//***                                                                  
	//*** Alteracoes: 21/07/2016 Correcoes na forma de recuperar parametros $_POST e tratar o retorno do XML. SD 479874. (Carlos R).               								
	//***                                        					       
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, vari&aacute;veis globais de controle, e biblioteca de fun&ccedil;&otilde;es	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m&eacute;todo POST
	isPostMethod();
	
	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");
	
	$cdcooper = ( isset($_POST["cdcooper"]) ) ? $_POST["cdcooper"] : 0;
	$dtmvtolt		= ( isset($_POST["dtmvtolt"])	) ? $_POST["dtmvtolt"] : '';
	
	// Fun&ccedil;&atilde;o para exibir erros na tela atrav&eacute;s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","blockBackground(parseInt($(\'#divRotina\').css(\'z-index\')))");';
		exit();
	}	
	
	// Monta o xml de requisição
	$xmlGetFeriados  = "";
	$xmlGetFeriados .= "<Root>";
	$xmlGetFeriados .= "	<Cabecalho>";
	$xmlGetFeriados .= "		<Bo>b1wgen0097.p</Bo>";
	$xmlGetFeriados .= "		<Proc>busca-feriados</Proc>";
	$xmlGetFeriados .= "	</Cabecalho>";
	$xmlGetFeriados .= "	<Dados>";
	$xmlGetFeriados .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlGetFeriados .= "		<dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlGetFeriados .= "	</Dados>";
	$xmlGetFeriados .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlGetFeriados);
	
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjFeriados = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjFeriados->roottag->tags[0]->name) && strtoupper($xmlObjFeriados->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjFeriados->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$feriados   = $xmlObjFeriados->roottag->tags[0]->tags;				
	$feriados_count = count($feriados);		
	
	for ($i = 0; $i < $feriados_count; $i++){		
		$dtferiad = $xmlObjFeriados->roottag->tags[0]->tags[$i]->tags[0]->cdata;	
		$dtfomart = substr($dtferiad,-4) . "/" . substr($dtferiad,3,2) . "/" . substr($dtferiad,0,2);
		
		
		echo "arrayFeriados[$i] = '$dtfomart';";					
	}		
	
?>