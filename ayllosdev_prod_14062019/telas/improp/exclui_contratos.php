<?

    /***********************************************************************
	
	  Fonte: exclui_contratos.php                                               
	  Autor: Gabriel                                                  
	  Data : Novembro/2010                       Última Alteração: 		   
	                                                                   
	  Objetivo  : Excluir os contratos selecionados da tela Improp.              
	                                                                 
	  Alterações: 	  
	
	
	
	***********************************************************************/

	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");	
	require_once("../../includes/controla_secao.php");

	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	
		
	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	$nomedarq = $_POST["nomedarq"];
	
	$xmlExcluiContratos  = "";
	$xmlExcluiContratos .= "<Root>";
	$xmlExcluiContratos .= " <Cabecalho>";
	$xmlExcluiContratos .= "   <Bo>b1wgen0024.p</Bo>";
	$xmlExcluiContratos .= "   <Proc>deleta-contratos</Proc>";
	$xmlExcluiContratos .= " </Cabecalho>";
	$xmlExcluiContratos .= " <Dados>";
    $xmlExcluiContratos .= "   <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlExcluiContratos .= "   <cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlExcluiContratos .= "   <nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlExcluiContratos .= "   <cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xmlExcluiContratos .= "   <nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xmlExcluiContratos .= "   <idorigem>5</idorigem>";
	$xmlExcluiContratos .= "   <dtmvtolt>".$glbvars["dtmvtolt"]."</dtmvtolt>";
	$xmlExcluiContratos .= "   <nomedarq>".$nomedarq."</nomedarq>";
    $xmlExcluiContratos .= " </Dados>";
    $xmlExcluiContratos .= "</Root>";	
	
	// Executa script para envio do XML
	
	$xmlResult = getDataXML($xmlExcluiContratos);
	
	$xmlObjCarregaContratos = getObjectXML($xmlResult);
	
	// Esconder a mensagem que carrega contratos 
	echo 'hideMsgAguardo();';
		
	// Voltar a tela Principal 
    echo 'voltar()';	
	
?>