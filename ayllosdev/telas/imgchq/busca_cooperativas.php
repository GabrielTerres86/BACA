<?php 
	
	//************************************************************************//
	//*** Fonte: busca_cooperativas.php                                    ***//
	//*** Autor: Fabrício                                                  ***//
	//*** Data : Junho/2012                   Última Alteração:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Buscar cooperativas do Sistema CECRED.               ***//
	//***            (exceto Cecred)								       ***//	
	//***                                                                  ***//	 
	//*** Alterações: 										     	       ***//
	//***                          									       ***//
	//***															       ***//
	//***             													   ***//
	//***                          									       ***//
	//************************************************************************//
	
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
	
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"@")) <> "") {
		exibeErro($msgError);		
	}
	
	// Monta o xml de requisição
	$xmlCooperativas  = "";
	$xmlCooperativas .= "<Root>";
	$xmlCooperativas .= "	<Cabecalho>";
	$xmlCooperativas .= "		<Bo>b1wgen0119.p</Bo>";
	$xmlCooperativas .= "		<Proc>busca_cooperativas</Proc>";
	$xmlCooperativas .= "	</Cabecalho>";
	$xmlCooperativas .= "	<Dados>";
	$xmlCooperativas .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlCooperativas .= "	</Dados>";
	$xmlCooperativas .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlCooperativas);
		
				
	// Cria objeto para classe de tratamento de XML
	$xmlObjCooperativas = getObjectXML($xmlResult);
		
			
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjCooperativas->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjCooperativas->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$cooperativas   = $xmlObjCooperativas->roottag->tags[0]->tags;	
	$qtCooperativas = count($cooperativas);
	
	?>
	lstCooperativas = new Array(); // Inicializar lista de cooperativas
	<? 
	for ($i = 0; $i < $qtCooperativas; $i++){
		
		$cdcooper = getByTagName($cooperativas[$i]->tags,"CODCOOPE");
		$nmrescop = getByTagName($cooperativas[$i]->tags,"NMRESCOP");
			
	?>
		objCooper = new Object();
		objCooper.cdcooper = "<?php echo $cdcooper; ?>";
		objCooper.nmrescop = "<?php echo $nmrescop; ?>";
		lstCooperativas[<?php echo $i; ?>] = objCooper;
		
	<?
	}
		
	echo 'carregaCooperativas("'.$qtCooperativas.'");';
	
	echo '$("#divConsultaImagem").css({"display":"block"});';
		 
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Aimaro","estadoInicial()");';
		exit();
	}
	
?>