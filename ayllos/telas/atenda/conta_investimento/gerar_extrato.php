<?php


	//************************************************************************//
	//*** Fonte: gerar_extrato.php                                         ***//
	//*** Autor: David                                                     ***//
	//*** Data : Outubro/2007                 Ultima Alteracao: 05/10/2012 ***//
	//***                                                                  ***//
	//*** Objetivo  : Imprimir extrato da Conta Investimento               ***//
	//***                                                                  ***//	 
	//*** Alteracoes: 12/07/2012 - Alterado parametro de $pdf->Output,     ***//  
	//***   					   Condicao para  Navegador Chrome (Jorge).
	//***
	//***			  05/10/2012 - Alterado modo de impressao para validar ***//
    //***  						   na b012 (Lucas R.).                     ***//
	//************************************************************************//
	
	session_cache_limiter("private");
	session_start();
	
	// Includes para controle da session, variáveis globais de controle, e biblioteca de funções	
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");		
	require_once("../../../includes/controla_secao.php");
	
	// Verifica se tela foi chamada pelo método POST
	isPostMethod();	

	// Classe para leitura do xml de retorno
	require_once("../../../class/xmlfile.php");


	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"I")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();	
	}
	
	// Verifica se parâmetros necessários foram informados
	if (!isset($_POST['nrdconta']) || 
		!isset($_POST['dtiniper']) ||
		!isset($_POST['dtfimper'])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}	

	$nrdconta = $_POST["nrdconta"];
	
	// Verifica se número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}	
	
	// Recebe as variaveis
	$nrdconta = $_POST['nrdconta'];
	$dtrefere = isset($_POST["dtiniper"]) && validaData($_POST["dtiniper"]) ? $_POST["dtiniper"] : $glbvars["dtmvtolt"];
	$dtreffim = isset($_POST["dtfimper"]) && validaData($_POST["dtfimper"]) ? $_POST["dtfimper"] : $glbvars["dtmvtolt"];
	$dsiduser = session_id();	
    
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0112.p</Bo>';
	$xml .= '		<Proc>Gera_Impressao</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>'; 
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<dtmvtopr>'.$glbvars['dtmvtopr'].'</dtmvtopr>';
	$xml .= '		<cdprogra>'.$glbvars['nmdatela'].'</cdprogra>';
	$xml .= '		<inproces>'.$glbvars['inproces'].'</inproces>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
	$xml .= '		<flgrodar>yes</flgrodar>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>1</idseqttl>';
	$xml .= '		<tpextrat>7</tpextrat>';  // Tipos Extrato
	$xml .= '		<dtrefere>'.$dtrefere.'</dtrefere>';
	$xml .= '		<dtreffim>'.$dtreffim.'</dtreffim>';
	$xml .= '		<flgtarif>no</flgtarif>';
	$xml .= '		<inrelext>0</inrelext>';
	$xml .= '		<inselext>0</inselext>';
  	$xml .= '		<nrctremp>0</nrctremp>';
	$xml .= '		<nraplica>0</nraplica>';
	$xml .= '		<nranoref>0</nranoref>';
    $xml .= '		<flgerlog>yes</flgerlog>';
	$xml .= '	</Dados>';                                  
	$xml .= '</Root>';

	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);

	// Cria objeto para classe de tratamento de XML
	$xmlObjDados = getObjectXML($xmlResult);

    // Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
		$msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
		?><script language="javascript">alert('<?php echo $msg; ?>');window.close();</script><?php
		exit();
	} 

	// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
	$nmarqpdf = $xmlObjDados->roottag->tags[0]->attributes["NMARQPDF"];

	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);

?>

