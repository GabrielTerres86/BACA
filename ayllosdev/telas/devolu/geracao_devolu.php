<? 
/*! 
 * FONTE        : DEVOLU.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Requisição da tela DEVOLU
 * --------------
 * ALTERAÇÕES   : 19/08/2016 - Ajustes referentes a Melhoria 69 - Devolucao Automatica de Cheques (Lucas Ranghetti #484923)
 * --------------
 *			      09/11/2016 - Remover validação de permissao nas telas secundares (Lucas Ranghetti #544579)
 *
 *				  02/12/2016 - Voltar para o estado inicial caso ocorra erro (Lucas Ranghetti/Elton)
 *                
 *                07/12/2018 - Melhoria no processo de devoluções de cheques.
 *                             Alcemir Mout's (INC0022559).
 *
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
	$cdagedep = (isset($_POST['cdagedep'])) ? $_POST['cdagedep'] : 0  ;
    $cdbandep = (isset($_POST['cdbandep'])) ? $_POST['cdbandep'] : 0  ;
	$nrctadep = (isset($_POST['nrctadep'])) ? $_POST['nrctadep'] : 0  ;

	$retornoAposErro = 'estadoInicial();';

	// Monta o xml dinâmico de acordo com a operação 
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
	$xml .= '		<cdbandep>'.$cdbandep.'</cdbandep>';
	$xml .= '		<cdagedep>'.$cdagedep.'</cdagedep>';
	$xml .= '		<nrctadep>'.$nrctadep.'</nrctadep>';
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
		exibirErro('error',$msgErro,'Alerta - Aimaro',$retornoAposErro,false);
	}
?>