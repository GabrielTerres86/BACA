<?
/*!
 * FONTE        : IMUNE.php
 * CRIAÇÃO      : André Santos / SUPERO
 * DATA CRIAÇÃO : 23/08/2013
 * OBJETIVO     : Requisição Consulta da tela IMUNE
 * --------------
 * ALTERAÇÕES   : 30/10/2013 - Incluir campo $cddopcao (Lucas R.)
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

	// Inicializa
	$retornoAposErro = '';

	// Recebe a operação que está sendo realizada
	$nrcpfcgc		 = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : 0  ;
	$cddopcao        = $_POST['cddopcao'];
	
	$retornoAposErro = 'focaCampoErro(\'nrcpfcgc\', \'frmCab\');';
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml dinâmico de acordo com a operação
	$xml = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0159.p</Bo>';
	$xml .= '		<Proc>consulta-imunidade</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
//	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

    // Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

    /*$arquivo = fopen('arquivo_xml','w');
    fwrite($arquivo,$xmlResult);
    fclose($arquivo);*/

    // ----------------------------------------------------------------------------------------------------------------------------------
	// Controle de Erros
	// ----------------------------------------------------------------------------------------------------------------------------------
	if ( strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO" ) {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

    $associado = $xmlObjeto->roottag->tags[0]->tags;
    $imunidade = $xmlObjeto->roottag->tags[1]->tags;

    include('tab_imune.php');

?>