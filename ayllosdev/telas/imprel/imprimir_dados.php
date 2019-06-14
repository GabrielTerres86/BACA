<?
/*!
 * FONTE        : imprimir_dados.php
 * CRIAÇÃO      : Rogérius Militão (DB1)
 * DATA CRIAÇÃO : 24/08/2011
 * OBJETIVO     : Carregar dados para impressões do IMPREL	
 * --------------
 * ALTERAÇÕES   : 21/03/2019 - Adicionado do campo periodo para o relatorio 219. 
 *                             Acelera - Reapresentacao automática de cheques (Lombardi).  
 *                
 *                25/04/2019 - Ajuste para impressao do relatório crrl530.
 *                             Acelera - Reapresentacao automatica de cheques (Lombardi).
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

	// Verifica se parâmetros necessários foram informados
	if (!isset($_POST["cddopcao"]) || 
		!isset($_POST["nrdrelat"]) ||
		!isset($_POST["cdagenca"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	
	
	// Recebe as variaveis
	$cddopcao 	= $_POST['cddopcao'];
	$nrdrelat 	= $_POST['nrdrelat'];
	$cdagenca 	= $_POST['cdagenca'];
	$cdperiod 	= $_POST['cdperiod'];
	
	switch ($nrdrelat) {
    case 13: // 13 -> 219-Devolucoes do Dia
        $dsiduser = 'crrl219_' . session_id();
        break;
    case 34: // 34 -> 530-Relaçao de Cheque Devolvidos
        $dsiduser = 'crrl530_' . session_id();
        break;
    default:
        $dsiduser = session_id();
	}

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0109.p</Bo>';
	$xml .= '		<Proc>Gera_Impressao</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<nrdrelat>'.$nrdrelat.'</nrdrelat>';
	$xml .= '		<cdagenca>'.$cdagenca.'</cdagenca>';
	$xml .= '		<cdperiod>'.$cdperiod.'</cdperiod>';
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);
	
		// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
		exit();
	} 
	
	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjDados->roottag->tags[0]->attributes["NMARQPDF"];
	
	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);

?>