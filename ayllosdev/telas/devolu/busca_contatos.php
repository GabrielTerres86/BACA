<?
/*!
 * FONTE        : busca_contatos.php
 * CRIA��O      : Lucas Ranghetti
 * DATA CRIA��O : 03/08/2016
 * OBJETIVO     : Buscar contatos do cooperado
 * --------------
 * ALTERA��ES   :
 * --------------
 */
?>

<?
    session_cache_limiter("private");
    session_start();

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');

    // Verifica se tela foi chamada pelo m�todo POST
	isPostMethod();

    // Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Recebe a opera��o que est� sendo realizada
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0;
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Monta o xml din�mico de acordo com a opera��o
	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0175.p</Bo>';
	$xml .= '		<Proc>busca-telefone-email</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

    // ----------------------------------------------------------------------------------------------------------------------------------
	// Controle de Erros
	// ----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos','',false);
	}
	
	$telefones = $xmlObjeto->roottag->tags[0]->tags;
	$emails    = $xmlObjeto->roottag->tags[1]->tags;
	
	include('tab_contatos.php');
?>