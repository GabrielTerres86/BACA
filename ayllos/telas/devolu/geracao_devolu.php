<? 
/*! 
 * FONTE        : DEVOLU.php
 * CRIA��O      : Andre Santos - SUPERO
 * DATA CRIA��O : 25/09/2013
 * OBJETIVO     : Requisi��o da tela DEVOLU
 * --------------
 * ALTERA��ES   : 19/08/2016 - Ajustes referentes a Melhoria 69 - Devolucao Automatica de Cheques (Lucas Ranghetti #484923)
 * --------------
 *			      09/11/2016 - Remover valida��o de permissao nas telas secundares (Lucas Ranghetti #544579)
 *
 *				  02/12/2016 - Voltar para o estado inicial caso ocorra erro (Lucas Ranghetti/Elton)
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
    
	// Inicializa
	$retornoAposErro = '';
    
    $cdcooper = (isset($_POST['cdcooper'])) ? $_POST['cdcooper'] : 0  ;
    $banco = (isset($_POST['banco'])) ? $_POST['banco'] : 0  ;
    $nrdrecid = (isset($_POST['nrdrecid'])) ? $_POST['nrdrecid'] : 0  ;
    $nrdctitg = (isset($_POST['nrdctitg'])) ? $_POST['nrdctitg'] : 0  ;
	$vllanmto = (isset($_POST['vllanmto'])) ? $_POST['vllanmto'] : 0  ;
	$cdalinea = (isset($_POST['cdalinea'])) ? $_POST['cdalinea'] : 0  ;
	$cdagechq = (isset($_POST['cdagechq'])) ? $_POST['cdagechq'] : 0  ;
    $nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
    $nrctachq = (isset($_POST['nrctachq'])) ? $_POST['nrctachq'] : 0  ;
	$nrdocmto = (isset($_POST['nrdocmto'])) ? $_POST['nrdocmto'] : 0  ;
    $flag = (isset($_POST['flag'])) ? $_POST['flag'] : 0  ;
	$camposDc = (isset($_POST['camposDc']))  ? $_POST['camposDc']  : '' ;
	$dadosDc  = (isset($_POST['dadosDc']))   ? $_POST['dadosDc']   : '' ;

	$retornoAposErro = 'estadoInicial();';

	// Monta o xml din�mico de acordo com a opera��o 
	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0175.p</Bo>';
	$xml .= '		<Proc>geracao-devolu</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
    $xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
    $xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
    $xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<cdcooper>'.$cdcooper.'</cdcooper>';
	$xml .= '		<banco>'.$banco.'</banco>';
	$xml .= '		<nrdrecid>'.$nrdrecid.'</nrdrecid>';
	$xml .= '		<nrdctitg>'.$nrdctitg.'</nrdctitg>';
	$xml .= '		<vllanmto>'.$vllanmto.'</vllanmto>';
	$xml .= '		<cdalinea>'.$cdalinea.'</cdalinea>';
	$xml .= '		<cdagechq>'.$cdagechq.'</cdagechq>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<nrctachq>'.$nrctachq.'</nrctachq>';
	$xml .= '		<nrdocmto>'.$nrdocmto.'</nrdocmto>';
	$xml .= '		<flag>'.$flag.'</flag>';
	$xml .= 		retornaXmlFilhos( $camposDc, $dadosDc, 'Desmarcar', 'Itens');
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
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
?>