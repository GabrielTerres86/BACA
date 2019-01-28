<?
/*!
 * FONTE        : imp_impressoes.php
 * CRIA��O      : Gabriel Capoia (DB1)
 * DATA CRIA��O : 12/04/2010 
 * OBJETIVO     : Arquivo de entrada para impress�o da rotina Impress�es da tela de CONTAS
 *
 * ALTERACOES   : 12/07/2012 - Alterado parametro "Attachment" conforme for navegador (Jorge).
 *
 *                01/12/2016 - P341-Automatiza��o BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO n�o utiliza o mesmo (Renato Darosci)
 *
 *                25/04/2018 - Adicionado nova opcao de impresssao Declaracao de FATCA/CRS
 *							   PRJ 414 (Mateus Z - Mouts)
 *				  16/01/2019 - Adicionado chamada para o relatorio Ficha-Proposta (C�ssia de Oliveira - GFT)
 */	 
?>

<?	
	session_cache_limiter('private');
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/dompdf/dompdf_config.inc.php');		
	require_once('../../../class/xmlfile.php');
?>

<?	
	// Recebendo valores da SESS�O
	$cdcooper = $glbvars['cdcooper'];
	$cdagenci = $glbvars['cdagenci'];
	$nrdcaixa = $glbvars['nrdcaixa'];
	$cdoperad = $glbvars['cdoperad'];
	$nmdatela = $glbvars['nmdatela'];
	$idorigem = $glbvars['idorigem'];
	
	// Recebendo valores via POST
	$GLOBALS['tprelato'] = (isset($_POST['tprelato'])) ? $_POST['tprelato'] : '';
	$flgpreen = (isset($_POST['flgpreen'])) ? $_POST['flgpreen'] : '';
	$inpessoa = (isset($_POST['inpessoa'])) ? $_POST['inpessoa'] : '';
	$nrdconta = (isset($_POST['_nrdconta'])) ? $_POST['_nrdconta'] : '';
	$idseqttl = (isset($_POST['_idseqttl'])) ? $_POST['_idseqttl'] : '';
	$GLOBALS['nrcpfcgc'] = (isset($_POST['_nrcpfcgc'])) ? $_POST['_nrcpfcgc'] : '';			
	
	// Inicio - Ficha-proposta - C�sssia de Oliveira (GFT)
	// Fun��o para exibir erros na tela atrav�s de javascript
    function exibeErro($msgErro) { 
	  echo '<script>alert("'.$msgErro.'");</script>';	
	  exit();
    }

	if($GLOBALS['tprelato'] == 'ficha_proposta'){

		// Monta o xml de requisi��o
		$xml  = "";
		$xml .= "<Root>";
		$xml .= "	<Dados>";
		$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
		$xml .= "	</Dados>";
		$xml .= "</Root>";	

		// Executa script para envio do XML
		$xmlResult = mensageria($xml, "CONTAS", "IMPRESSAO_FICHA_PROPOSTA", $glbvars["cdcooper"], $glbvars["cdpactra"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
		// Cria objeto para classe de tratamento de XML
		$xmlObj = simplexml_load_string($xmlResult);
		// Se ocorrer um erro, mostra cr�tica
		if ($xmlObj->Erro->Registro->dscritic != ''){
			exibeErro($xmlObj->Erro->Registro->dscritic);
		}
		// Obt�m nome do arquivo PDF 
		$nmarqpdf = $xmlObj;
		// Chama fun��o para mostrar PDF do impresso gerado no browser
		visualizaPDF($nmarqpdf);	
	}else{
		// Gerando uma chave do formul�rio
		$impchave = $GLOBALS['tprelato'].$nrdconta.$idseqttl;
		setcookie('impchave', $impchave, time()+60 );
		
		// Monta o xml de requisi��o
		$xmlSetPesquisa  = "";
		$xmlSetPesquisa .= "<Root>";
		$xmlSetPesquisa .= "	<Cabecalho>";
		$xmlSetPesquisa .= "		<Bo>b1wgen0063.p</Bo>";
		$xmlSetPesquisa .= "		<Proc>busca_impressao</Proc>";
		$xmlSetPesquisa .= "	</Cabecalho>";
		$xmlSetPesquisa .= "	<Dados>";
		$xmlSetPesquisa .= "        <cdcooper>".$cdcooper."</cdcooper>";
		$xmlSetPesquisa .= "		<cdagenci>".$cdagenci."</cdagenci>";
		$xmlSetPesquisa .= "		<nrdcaixa>".$nrdcaixa."</nrdcaixa>";
		$xmlSetPesquisa .= "		<cdoperad>".$cdoperad."</cdoperad>";
		$xmlSetPesquisa .= "		<nmdatela>".$nmdatela."</nmdatela>";	
		$xmlSetPesquisa .= "		<idorigem>".$idorigem."</idorigem>";	
		$xmlSetPesquisa .= "		<nrdconta>".$nrdconta."</nrdconta>";
		$xmlSetPesquisa .= "		<idseqttl>".$idseqttl."</idseqttl>";
	    $xmlSetPesquisa .= "		<tprelato>".$GLOBALS['tprelato']."</tprelato>";
	    $xmlSetPesquisa .= "		<flgpreen>".$flgpreen."</flgpreen>";
		$xmlSetPesquisa .= "	</Dados>";
		$xmlSetPesquisa .= "</Root>";		
		
		// Pega informa��es retornada do PROGRESS
		$xmlResult  = getDataXML($xmlSetPesquisa);	
		$xmlObjeto  = getObjectXML($xmlResult);		
			
		// Guarda as informa��es em uma vari�vel GLOBAL
		$GLOBALS['xmlObjeto'] = $xmlObjeto;
		
		$navegador = CheckNavigator();
		$tipo = $navegador['navegador'] == 'chrome' ? 0 : 1;
		
		// Definindo par�metro para o m�todo "stream"
		$opcoes['Attachment'	] = $tipo; 
		$opcoes['Accept-Ranges'	] = 0;
		$opcoes['compress'		] = 0;	
		
		$GLOBALS['totalLinha'	] = 69;
		$GLOBALS['numLinha'		] = 0;
		$GLOBALS['numPagina'	] = 1;	
		$GLOBALS['flagRepete'	] = false;	

		// Gera o relat�rio em PDF atrav�s do DOMPDF
		$dompdf = new DOMPDF();	
		
		if($GLOBALS['tprelato'] == 'declaracao_fatca_crs'){
			$dompdf->load_html_file( './imp_'.$GLOBALS['tprelato'].'_html.php' );
		} else {
			if ( $inpessoa == '1' ) {
				$dompdf->load_html_file( './imp_'.$GLOBALS['tprelato'].'_pf_html.php' );
			} else {
				$dompdf->load_html_file( './imp_'.$GLOBALS['tprelato'].'_pj_html.php' );
			}
		}
		
		$dompdf->set_paper('a4');
		$dompdf->render();
		$dompdf->stream('impressoes_'.$impchave.'.pdf', $opcoes );
	}
	// Fim - Ficha-proposta - C�sssia de Oliveira (GFT)
		
?>