<?
/*!
 * FONTE        : aprova_reprova_dados.php
 * CRIAÇÃO      : Andre Santos - SUPERO
 * DATA CRIAÇÃO : Maio/2015
 * OBJETIVO     : Rotina para gravar Aprovacao e Reprocao de Estouro de folha de pagamento
 * --------------
 * ALTERAÇÕES   : 21/10/2015 - Chamada da validaPermissao conforme tipo da operacao (Marcos-Supero)
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
	$cdempres       = (isset($_POST['cdempres'])) ? $_POST['cdempres'] : ''  ;
	$dtsolest       = (isset($_POST['dtsolest'])) ? $_POST['dtsolest'] : ''  ;
	$dsjustif       = (isset($_POST['dsjustif'])) ? $_POST['dsjustif'] : ''  ;
	$dsmsgeml       = (isset($_POST['dsmsgeml'])) ? $_POST['dsmsgeml'] : ''  ;
	$cdeftpag       = (isset($_POST['cdeftpag'])) ? $_POST['cdeftpag'] : ''  ;
	
	// Montar cddopcao conforme cdeftpag
	if ($cdeftpag == 3){
		$cddopcao = "R";
    }else{
		$cddopcao = "A";
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
	$xml .= '		<dsjustif>'.$dsjustif.'</dsjustif>';
	$xml .= '		<dsmsgeml>'.$dsmsgeml.'</dsmsgeml>';
	$xml .= '		<cdeftpag>'.$cdeftpag.'</cdeftpag>';
	$xml .= '		<cdempres>'.$cdempres.'</cdempres>';
	$xml .= '		<dtsolest>'.$dtsolest.'</dtsolest>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';

	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "ESTFOL", "GRAVPFP", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$campo    = ucfirst($xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO']);
		$retornoAposErro = 'c'.$campo.'.focus();'.'c'.$campo.'.addClass(\'campoErro\');'."blockBackground(parseInt($('#divRotina').css('z-index')));";
		$codErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[3]->cdata;
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
		
		switch ($codErro) {
			case 1:
				$msgErro = "N&atilde;o &eacute; mais poss&iacute;vel aprovar os estouros, o hor&aacute;rio limite definido &eacute; $msgErro.";
				break;
			case 2:
				$msgErro = "Justificativa deve possuir no m&iacute;nimo 40 caracteres!";
				break;
			case 3:
				$msgErro = "Registro nao localizado!";
				break;
			case 4:
			    if($cdeftpag==4){
					$descricao="aprovar o registro.";
				}else
				if($cdeftpag==3){
					$descricao="reprovar o registro.";
				}
				$msgErro = "O Registro est&aacute; com status $msgErro, n&atilde;o ser&aacute; poss&iacute;vel $descricao";
				break;
			case 5:
				$msgErro = "Corpo do e-mail deve possuir no m&iacute;nimo 40 caracteres!";
				break;
			case 6:
				$msgErro = "Este pagamento ser&aacute; debitado em breve, pois houve regulariza&ccedil;&atilde;o de saldo e o Estouro em Conta n&atilde;o &eacute; mais necess&aacute;rio!";
				$retornoAposErro = "encerraRotina(true);buscaPagamento();";
				break;
			case 9999:
			    $retornoAposErro = "blockBackground(parseInt($('#divRotina').css('z-index')));";
				break;
		}

		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
	}
?>