<?
/*!
 * FONTE        : busca_bureaux.php
 * CRIA��O      : Andre Santos - SUPERO
 * DATA CRIA��O : Janeiro/2015
 * OBJETIVO     : Rotina para buscar os dados PRMRBC
 * --------------
 * ALTERA��ES   :
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

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],"C")) <> "") {
		exibeErro($msgError);
	}
	
	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<cdprogra>'.$glbvars['nmdatela'].'</cdprogra>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "LOGRBC", "LISBURX", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["nmoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
	
	$lsBureaux   = $xmlObjeto->roottag->tags[0]->attributes['LISTA'];
	$qtBureaux = $xmlObjeto->roottag->tags[0]->attributes['QTD'];
	
	// Separando os registros
	$arrayBureaux = split(',',$lsBureaux);
	// Monta a TAG option dinamicamente para cada contrato do associado
	for ($i = 0; $i < $qtBureaux; $i++) {
		echo "$('#lstpreme','#frmCab').append('<option value=".str_replace('.',''
		                                                                  ,str_replace('-',''
																		  ,str_replace(' ','',$arrayBureaux[$i]))).">".$arrayBureaux[$i]."</option>');";
	}

	echo "btnVoltar()";
?>