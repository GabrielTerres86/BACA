<?
/*!
 * FONTE        : imprimir_dados.php
 * CRIAÇÃO      : Gabriel Santos (DB1)
 * DATA CRIAÇÃO : 11/01/2013
 * OBJETIVO     : Carregar dados para impressões da PESQDP	
 * --------------
 * ALTERAÇÕES   : 27/06/2014 - Incluido opção "D". (Reinert)
 * -------------- 
 */ 
?>

<?

	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../includes/config.php");
	require_once("../../includes/funcoes.php");		
	require_once("../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");


	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}	
		
	$cddopcao	= (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : '' ;
	
	$procedure 	= '';
		
	if ($cddopcao == "R"){
		// Verifica se parâmetros necessários foram informados
		
		if (!isset($_POST["cdbccxlt"]) || 
			!isset($_POST["dtmvtini"]) ||
			!isset($_POST["dtmvtfim"])) {			
			?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
			exit();
		}
		
		$procedure 	= 'Gera_Relatorio';
	}else{
	
		if (!isset($_POST["dtdevolu"])) {
			?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
			exit();
		}
		
		$procedure 	= 'Gera_Relatorio_Devolvidos';
	}
	
	// Recebe as variaveis
	$cdbccxlt 	= $_POST['cdbccxlt'];
	$dtmvtini 	= $_POST['dtmvtini'];
	$dtmvtfim 	= $_POST['dtmvtfim'];
	$tpdsaida 	= $_POST['tpdsaida'];
	$dsiduser 	= $_POST['dsiduser'];
	$dtdevolu 	= $_POST['dtdevolu'];		
	
	if( $tpdsaida != "T"){		
		$dsiduser 	= session_id();	
	}
		
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0144.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<cdbccxlt>'.$cdbccxlt.'</cdbccxlt>';
	$xml .= '		<dtmvtini>'.$dtmvtini.'</dtmvtini>';
	$xml .= '		<dtmvtfim>'.$dtmvtfim.'</dtmvtfim>';
	$xml .= '		<tpdsaida>'.$tpdsaida.'</tpdsaida>';
	$xml .= '		<dtdevolu>'.$dtdevolu.'</dtdevolu>';
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);
	
	
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == 'ERRO') {	
		$msgErro	= $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
	
		if( $tpdsaida == "T"){
			$mtdErro = " $('#".$nmdcampo."','#frmConsulta').focus();"; 		
			exibirErro('error',$msgErro,'Alerta - Ayllos',$mtdErro,false);				
		}else{
			?><script language="javascript">alert('<?php echo $msgErro; ?>');</script><?php
			exit();
		}		
	} 
	
	
	if( $tpdsaida != "T"){
		// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
		$nmarqpdf = $xmlObjDados->roottag->tags[0]->attributes["NMARQPDF"];
		
		// Chama função para mostrar PDF do impresso gerado no browser
		visualizaPDF($nmarqpdf);
	}	
	
?>