<?php 
	
	//************************************************************************//
	//*** Fonte: busca_relatorio.php                                       ***//
	//*** Autor: Fabrício                                                  ***//
	//*** Data : Janeiro/2012                 Última Alteração:            ***//
	//***                                                                  ***//
	//*** Objetivo  : Buscar os relatorios dos arquivos processados        ***//	
	//***             a partir do dia corrente                             ***//
	//***                                                                  ***//	 
	//*** Alterações: 08/02/2012 - Ajustes Pamcar (Adriano).               ***//
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
	
	// Verifica permiss&atilde;o
	$msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"R");
		
			
	// Monta o xml de requisição
	$xmlRelatorio  = "";
	$xmlRelatorio .= "<Root>";
	$xmlRelatorio .= "	<Cabecalho>";
	$xmlRelatorio .= "		<Bo>b1wgen0119.p</Bo>";
	$xmlRelatorio .= "		<Proc>busca_log_processamento</Proc>";
	$xmlRelatorio .= "	</Cabecalho>";
	$xmlRelatorio .= "	<Dados>";
	$xmlRelatorio .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xmlRelatorio .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xmlRelatorio .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xmlRelatorio .= "		<dtinicio>".$glbvars["dtmvtolt"]."</dtinicio>";
	$xmlRelatorio .= "		<dtfim>".$glbvars["dtmvtolt"]."</dtfim>";
	$xmlRelatorio .= "	</Dados>";
	$xmlRelatorio .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xmlRelatorio);
		
	// Cria objeto para classe de tratamento de XML
	$xmlObjRelatorio = getObjectXML($xmlResult);
	
		
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjRelatorio->roottag->tags[0]->name) == "ERRO") {
		exibeErro($xmlObjRelatorio->roottag->tags[0]->tags[0]->tags[4]->cdata);
	}
	
	$relatorios   = $xmlObjRelatorio->roottag->tags[0]->tags;	
	$qtrelatorios = count($relatorios);
	
	?>
	lstRelatorios = new Array(); // Inicializar lista de relatorios
	<? 
	for ($i = 0; $i < $qtrelatorios; $i++){
		
		$nmarquiv = getByTagName($relatorios[$i]->tags,"NMARQUIV");
			
	?>
		lstRelatorios[<?php echo $i; ?>] = "<?php echo $nmarquiv; ?>";
	<?
	}
	
	echo 'carregaRelatorios();';
	
	echo "$('#divRelatorio').css({'display':'block'});";
		
	// Esconde mensagem de aguardo
	echo 'hideMsgAguardo();';
		 
	
	// Função para exibir erros na tela através de javascript
	function exibeErro($msgErro) { 
		echo 'hideMsgAguardo();';
		echo 'showError("error","'.$msgErro.'","Alerta - Ayllos","estadoInicial()");';
		exit();
	}
	
?>