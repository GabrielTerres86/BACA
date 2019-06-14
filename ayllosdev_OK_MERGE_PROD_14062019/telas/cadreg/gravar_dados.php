<?
/*!
 * FONTE        : gravar_dados.php					�ltima altera��o: 27/11/2015 
 * CRIA��O      : J�ssica - DB1
 * DATA CRIA��O : 18/09/2015
 * OBJETIVO     : Rotina para gravar dados
 * --------------
 * ALTERA��ES   :  27/11/2015 - Ajuste decorrente a homologa��o de convers�o realizada pela DB1
                               (Adriano). 
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

	$cddopcao = (isset($_POST["cddopcao"])) ? $_POST["cddopcao"] : '';
		
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	// Recebe o POST
	$dsdregio    = (isset($_POST['dsdregio'])) ? $_POST['dsdregio'] : ' '  ;
	$cdopereg    = (isset($_POST['cdopereg'])) ? $_POST['cdopereg'] : ' '  ;
	$dsdemail    = (isset($_POST['dsdemail'])) ? $_POST['dsdemail'] : ' '  ;
	$flgerlog    = 0;	
	$cddregio    = (isset($_POST['cddregio'])) ? $_POST['cddregio'] : ' '  ;
	
	// Monta o xml de requisi��o
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Dados>';		
	$xml .= '		<dsdregio>'.$dsdregio.'</dsdregio>';
	$xml .= '		<cdopereg>'.$cdopereg.'</cdopereg>';	
	$xml .= '		<dsdemail>'.$dsdemail.'</dsdemail>';
	$xml .= '       <dtmvtolt>'.$glbvars["dtmvtolt"].'</dtmvtolt>';
	$xml .= '		<flgerlog>'.$flgerlog.'</flgerlog>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<cddregio>'.$cddregio.'</cddregio>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
		
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML
	$xmlResult = mensageria($xml, "CADREG", "GRAVAREGIONAL", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra cr�tica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		
		$campo = $xmlObjeto->roottag->tags[0]->attributes['NMDCAMPO'];			
								
		if($campo != '' and ($campo != 'dsdregio')){ 
			$retornoAposErro .= '$(\'#cdoperad\',\'#frmConsulta\').addClass(\'campoErro\').habilitaCampo().focus(); $(\'#frmConsulta\').css(\'display\',\'block\'); $(\'#btSalvar\',\'#divBotoes\').show(); $(\'#btVoltar\',\'#divBotoes\').show();';
		}else {
			$retornoAposErro .= '$(\'#dsdregio\',\'#frmConsulta\').addClass(\'campoErro\').habilitaCampo().focus(); $(\'#frmConsulta\').css(\'display\',\'block\'); $(\'#btSalvar\',\'#divBotoes\').show(); $(\'#btVoltar\',\'#divBotoes\').show();';
		}
		
		$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
						
		exibirErro('error',$msgErro,'Alerta - Ayllos',$retornoAposErro,false);
		
	}			

?>