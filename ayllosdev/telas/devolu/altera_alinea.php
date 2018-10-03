<?
/*! 
 * FONTE        : altera_alinea.php
 * CRIAÇÃO      : Lucas Ranghetti
 * DATA CRIAÇÃO : 12/08/2016
 * OBJETIVO     : Alterar alinea
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */
?>

<?
    session_cache_limiter("private");
    session_start();

	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');

    // Verifica se tela foi chamada pelo método POST
	isPostMethod();

    // Classe para leitura do xml de retorno
	require_once("../../class/xmlfile.php");
	
	// Recebe a operação que está sendo realizada
	$nrctachq = (isset($_POST['nrctachq'])) ? $_POST['nrctachq'] : 0;
	$cdbanchq = (isset($_POST['cdbanchq'])) ? $_POST['cdbanchq'] : 0;
	$cdagechq = (isset($_POST['cdagechq'])) ? $_POST['cdagechq'] : 0;
	$nrdocmto = (isset($_POST['nrdocmto'])) ? $_POST['nrdocmto'] : 0;
	$cdalinea = (isset($_POST['cdalinea'])) ? $_POST['cdalinea'] : 0;
	
	// Monta o xml dinâmico de acordo com a operação
	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0175.p</Bo>';
	$xml .= '		<Proc>altera-alinea</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nrctachq>'.$nrctachq.'</nrctachq>';
	$xml .= '		<cdbanchq>'.$cdbanchq.'</cdbanchq>';
	$xml .= '		<cdagechq>'.$cdagechq.'</cdagechq>';
	$xml .= '		<nrdocmto>'.$nrdocmto.'</nrdocmto>';
	$xml .= '		<cdalinea>'.$cdalinea.'</cdalinea>';
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
		exibirErro('error',$msgErro,'Alerta - Aimaro','',false);
	}
	
	exibirErro('inform','Alinea alterada com sucesso!','Alerta - Aimaro','hideMsgAguardo();BuscaDevolu(1,30);',false);
?>