<?
/*!
 * FONTE        : DEVOLU.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : 25/09/2013
 * OBJETIVO     : Rotina para manter validar senha do operador
 * --------------
 * ALTERAÇÕES   :
 *
 * --------------
 */
?>

<?
    session_start();
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();

	// Varivel de controle do caracter
	$operauto	= (isset($_POST['operauto'])) ? $_POST['operauto'] : '' ;
	$codsenha 	= (isset($_POST['codsenha'])) ? $_POST['codsenha'] : '' ;

    $retornoAposErro = 'focaCampoErro(\'codsenha\', \'frmSenhaCoord\',false,\'divRotina\');';

	// Monta o xml dinâmico de acordo com a operação
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0000.p</Bo>';
	$xml .= '		<Proc>valida-senha-coordenador</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>0</nrdconta>';
	$xml .= '		<idseqttl>0</idseqttl>';
	$xml .= '		<nvopelib>2</nvopelib>';
	$xml .= '		<cdopelib>'.$operauto.'</cdopelib>';
	$xml .= '		<cddsenha>'.$codsenha.'</cddsenha>';
	$xml .= '		<flgerlog>no</flgerlog>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);

	//----------------------------------------------------------------------------------------------------------------------------------
	// Controle de Erros
	//----------------------------------------------------------------------------------------------------------------------------------
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") {
		$msgErro	= $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
?>