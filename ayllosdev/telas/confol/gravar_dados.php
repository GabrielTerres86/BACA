<?
/*!
 * FONTE        : gravar_dados.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Rotina para gravar dados
 * --------------
 * ALTERAÇÕES   : 21/10/2015 - Envio da cddopcao conforme a situação (Inserção ou Atualização) (Marcos-Supero)
		
				  23/11/2015 - Ajustado para nao gravar os valores de de tarifa
					           (Andre Santos - SUPERO)

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

	// Recebe o POST
	$rowid       = (isset($_POST['rowid'])) ? $_POST['rowid'] : ' '  ;
	$cdcontar    = (isset($_POST['cdcontar'])) ? $_POST['cdcontar'] : ' '  ;
	$dscontar    = (isset($_POST['dscontar'])) ? $_POST['dscontar'] : ' '  ;

	if ($rowid != ""){
		$cddopcao = "A";
	}else{
		$cddopcao = "I";
	}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}

	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<dtmvtolt>'.$glbvars['dtmvtolt'].'</dtmvtolt>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<cdcontar>'.$cdcontar.'</cdcontar>';
	$xml .= '		<dscontar>'.$dscontar.'</dscontar>';
	$xml .= '		<rowid>'.$rowid.'</rowid>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CONFOL", "GRAVCFP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$campo    = ucfirst($xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO']);
		$retornoAposErro = 'c'.$campo.'.focus();'.'c'.$campo.'.addClass(\'campoErro\');'."blockBackground(parseInt($('#divRotina').css('z-index')));";
		$codErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata;
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		switch ($codErro) {
			case 1:
				$msgErro = "Favor informar outra descri&ccedil;&atilde;o, pois a mesma j&aacute; est&aacute; em uso!";
				break;
			case 2:
				$msgErro = "A descri&ccedil;&atilde;o do conv&ecirc;nio &eacute; obrigat&oacute;ria!";
				break;
			case 9999:
			    $retornoAposErro = "blockBackground(parseInt($('#divRotina').css('z-index')));";
				break;
		}
		
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}

?>