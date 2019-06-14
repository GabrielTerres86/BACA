<? 

	/**************************************************************************
	      Fonte: verifica_agencia.php                                        
	      Autor: Lucas Moreira
	      Data : Novembro/2015                   �ltima Altera��o: --/--/---- 
	                                                                  
	      Objetivo  : Verifica agencia da cooperativa.
	                    
	**************************************************************************/
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, vari�veis globais de controle, e biblioteca de fun��es	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);
		exit();	
	}

	// Verifica se par�metros necess�rios foram informados
	if (!isset($_POST["cdagechq"])) {
		exibeErro('Par&acirc;metros incorretos.');
		exit();
	}	

    // parametros
	$cdagechq = $_POST['cdagechq'];
	
	$dsiduser = session_id();
	
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '		<cdagectl>'.$cdagechq.'</cdagectl>';
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';
	
	// Executa script para envio do XML
	$xmlResult = mensageria($xml, "TARIFA", "VER_AGEN_COP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibeErro($msg);
	}
  
	echo $xmlObjDados->roottag->cdata <> 0 ? "showConfirmacao('Deseja efetuar cobran�a de tarifa?','Confirma&ccedil;&atilde;o - Ayllos','cobraTariva();','consultaCheque();','sim.gif','nao.gif');" : "consultaCheque();";
	
	// Fun��o para exibir erros na tela atrav�s de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro");';
		exit();
	}
?>