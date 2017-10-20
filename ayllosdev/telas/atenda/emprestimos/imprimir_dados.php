<?php 
	/**************************************************************************
	  Fonte: imprimir_dados.php
	  Autor: André Socoloski - DB1
	  Data : Março/2011                   Última Alteração: 26/06/2015

	  Objetivo  : Carregar dados para impressões dos emprestimos

	  Alterações:  03/09/2014 - Orgaos de protecao ao credito (Jonata-RKAM)

	  11/09/2014 - Projeto Contratos de Empréstimos (Tiago Castro - RKAM)

	  06/05/2015 - Ajuste para impressao das consultas (Gabriel-RKAM). 

	  10/06/2015 - Impressao de contratos nao negociaveis (Gabriel-RKAM).

	  11/06/2014 - Projeto 209 - Ajuste para novo formato XML (Tiago Castro - RKAM)

	  26/06/2015 - Impressao do 'Termo Portabilidade'. (Jaison/Diego - SD: 290027)
    
    16/11/2015 - Foi comentada a tag 'nrctremp'. (Lombardi - Projeto Portabilidade)
	 ************************************************************************* */

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


	if (($msgError = validaPermissao($glbvars["nmdatela"], $glbvars["nmrotina"], "C")) <> "") {
		?><script language="javascript">alert('<?php echo $msgError; ?>');</script><?php
		exit();
	}

	// Verifica se parâmetros necessários foram informados
	if (!isset($_POST["idimpres"]) || !isset($_POST["promsini"])) {
		?><script language="javascript">alert('Par&acirc;metros incorretos.');</script><?php
		exit();
	}

	$nrpagina = $_POST["nrpagina"];
	$idimpres = $_POST["idimpres"];
	$promsini = $_POST["promsini"];
	$flgemail = $_POST["flgemail"];
	$nrdrecid = $_POST["nrdrecid"];
	$nrdconta = $_POST["nrdconta"];
	$nrctremp = $_POST['nrctremp'];
	$nrcpfcgc = $_POST['nrcpfcgc'];

	// Verifica se o número da conta é um inteiro válido
	if (!validaInteiro($nrdconta)) {
		?><script language="javascript">alert('Conta/dv inv&aacute;lida.');</script><?php
		exit();
	}

	$dsiduser = session_id();

	// Verifica se opcao eh contrato ou contrato nao negociavel ou termo de portabilidade
	if ($idimpres == '2' || $idimpres == '8' || $idimpres == '9') {

		$inimpctr = ($idimpres == '2') ? 0 : 1;

		$xml = '';
		$xml .= '<Root>';
		$xml .= '	<Dados>';
		$xml .= '		<cdcooper>' . $glbvars['cdcooper'] . '</cdcooper>';
		$xml .= '		<nrdconta>' . $nrdconta . '</nrdconta>';
		$xml .= '		<nrctremp>' . $nrctremp . '</nrctremp>';
		$xml .= '		<inimpctr>' . $inimpctr . '</inimpctr>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';
	} else {
		// Monta o xml de requisição
		$xml = '';
		$xml .= '<Root>';
		$xml .= '	<Cabecalho>';
		if ($idimpres == '7') {
			$xml .= '		<Bo>b1wgen0191.p</Bo>';
			$xml .= '		<Proc>Imprime_Consulta</Proc>';
		} else {
			$xml .= '		<Bo>b1wgen0002.p</Bo>';
			$xml .= '		<Proc>gera-impressao-empr</Proc>';
		}
		$xml .= '	</Cabecalho>';
		$xml .= '	<Dados>';
		$xml .= '		<cdcooper>' . $glbvars['cdcooper'] . '</cdcooper>';
		$xml .= '		<cdagenci>' . $glbvars['cdagenci'] . '</cdagenci>';
		$xml .= '		<nrdcaixa>' . $glbvars['nrdcaixa'] . '</nrdcaixa>';
		$xml .= '		<cdoperad>' . $glbvars['cdoperad'] . '</cdoperad>';
		$xml .= '		<nmdatela>' . $glbvars['nmdatela'] . '</nmdatela>';
		$xml .= '		<idorigem>' . $glbvars['idorigem'] . '</idorigem>';
		$xml .= '		<dtmvtolt>' . $glbvars['dtmvtolt'] . '</dtmvtolt>';
		$xml .= '		<dtmvtopr>' . $glbvars['dtmvtopr'] . '</dtmvtopr>';
		$xml .= '		<dtcalcul>' . $glbvars['dtmvtolt'] . '</dtcalcul>';
		$xml .= '		<inproces>' . $glbvars['inproces'] . '</inproces>';
		$xml .= '		<nrdconta>' . $nrdconta . '</nrdconta>';
		$xml .= '		<inprodut>1</inprodut>';
		//$xml .= '		<nrctremp>'.$nrctremp.'</nrctremp>';
		$xml .= '		<nrctrato>'.$nrctremp.'</nrctrato>';
		$xml .= '		<recidepr>'.$nrdrecid.'</recidepr>';
		$xml .= '		<idimpres>'.$idimpres.'</idimpres>';
		$xml .= '		<flgemail>'.$flgemail.'</flgemail>';
		$xml .= '		<dsiduser>'.$dsiduser.'</dsiduser>';
		$xml .= '		<promsini>'.$promsini.'</promsini>';
		$xml .= '		<idseqttl>1</idseqttl>';
		$xml .= '		<flgentra>FALSE</flgentra>';
		$xml .= '		<nrpagina>0</nrpagina>';
		$xml .= '		<cdprogra>"ATENDA"</cdprogra>';
		$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
		$xml .= '	</Dados>';
		$xml .= '</Root>';
	}
	// verifica se opcao eh contrato
	if ($idimpres == '23'){
		// Executa script para envio do XML
		$xmlResult = mensageria($xml, "EMPR0003", "IMP_DECUTRECISIOF", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

		// Cria objeto para classe de tratamento de XML
		$xmlObj = simplexml_load_string($xmlResult);

		// Se ocorrer um erro, mostra crítica
		if ($xmlObj->Erro->Registro->dscritic != '') {
			$msgErro = utf8ToHtml($xmlObj->Erro->Registro->dscritic);
			?><script language="javascript">alert('<?php echo $msgErro; ?>');</script><?php
			exit();
		}

		// Obtém nome do arquivo PDF 
		$nmarqpdf = $xmlObj;
	}
	else if ($idimpres == '2' || $idimpres == '8') {
		// Executa script para envio do XML
		$xmlResult = mensageria($xml, "EMPR0003", "IMPCONTR", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

		// Cria objeto para classe de tratamento de XML
		$xmlObj = simplexml_load_string($xmlResult);

		// Se ocorrer um erro, mostra crítica
		if ($xmlObj->Erro->Registro->dscritic != '') {
			$msgErro = utf8ToHtml($xmlObj->Erro->Registro->dscritic);
			?><script language="javascript">alert('<?php echo $msgErro; ?>');</script><?php
			exit();
		}

		// Obtém nome do arquivo PDF 
		$nmarqpdf = $xmlObj;
	} else if ($idimpres == '9') { // Termo de Portabilidade
		// Executa script para envio do XML
		$xmlResult = mensageria($xml, "PORTAB_CRED", "PORTAB_TERMO", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");

		// Cria objeto para classe de tratamento de XML
		$xmlObjDados = getObjectXML($xmlResult);

		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjDados->roottag->tags[0]->name) == "ERRO") {
			$msg = $xmlObjDados->roottag->tags[0]->tags[0]->tags[4]->cdata;
			?><script language="javascript">alert('<?php echo $msg; ?>');</script><?php
			exit();
		}

		// Obtém nome do arquivo PDF copiado do Servidor PROGRESS para o Servidor Web
		$nmarqpdf = $xmlObjDados->roottag->tags[0]->cdata;
	} else {
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
	}

	// Chama função para mostrar PDF do impresso gerado no browser
	visualizaPDF($nmarqpdf);
?>