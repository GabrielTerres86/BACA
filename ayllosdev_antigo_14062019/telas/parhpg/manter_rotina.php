<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Douglas Quisinski
 * DATA CRIAÇÃO : 15/04/2016
 * OBJETIVO     : Rotina para alteração e inclusão cadastral da tela PARHPG
 * --------------
 * ALTERAÇÕES   : 19/06/2017 - Removida a linha com informações da Devolução VLB.
				               PRJ367 - Compe Sessao Unica (Lombardi)
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
	
	$cddopcao = isset($_POST["cddopcao"]) ? $_POST["cddopcao"] : "";
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao,false)) <> '') {
		exibirErro('error',$msgError,'Alerta - Ayllos','',false);
	}
	
	$cdcooper = isset($_POST["cdcooper"]) ? $_POST["cdcooper"] : ""; // Cooperativa selecionada
	$hrsicatu = isset($_POST["hrsicatu"]) ? $_POST["hrsicatu"] : ""; // Atualizar Horario Pagamento SICREDI "S/N"
	$hrsicini = isset($_POST["hrsicini"]) ? $_POST["hrsicini"] : ""; // Horario de Pagamento SICREDI - Inicial
	$hrsicfim = isset($_POST["hrsicfim"]) ? $_POST["hrsicfim"] : ""; // Horario de Pagamento SICREDI - Final
	$hrtitatu = isset($_POST["hrtitatu"]) ? $_POST["hrtitatu"] : ""; // Atualizar Horario Pagamento TITULOS/FATURAS "S/N"
	$hrtitini = isset($_POST["hrtitini"]) ? $_POST["hrtitini"] : ""; // Horario de Pagamento TITULOS/FATURAS - Inicial
	$hrtitfim = isset($_POST["hrtitfim"]) ? $_POST["hrtitfim"] : ""; // Horario de Pagamento TITULOS/FATURAS - Final
	$hrnetatu = isset($_POST["hrnetatu"]) ? $_POST["hrnetatu"] : ""; // Atualizar Horario Pagamento INTERNET/MOBILE "S/N"
	$hrnetini = isset($_POST["hrnetini"]) ? $_POST["hrnetini"] : ""; // Horario de Pagamento INTERNET/MOBILE - Inicial
	$hrnetfim = isset($_POST["hrnetfim"]) ? $_POST["hrnetfim"] : ""; // Horario de Pagamento INTERNET/MOBILE - Final
	$hrtaaatu = isset($_POST["hrtaaatu"]) ? $_POST["hrtaaatu"] : ""; // Atualizar Horario Pagamento TAA "S/N"
	$hrtaaini = isset($_POST["hrtaaini"]) ? $_POST["hrtaaini"] : ""; // Horario de Pagamento TAA - Inicial
	$hrtaafim = isset($_POST["hrtaafim"]) ? $_POST["hrtaafim"] : ""; // Horario de Pagamento TAA - Final
	$hrgpsatu = isset($_POST["hrgpsatu"]) ? $_POST["hrgpsatu"] : ""; // Atualizar Horario Pagamento GPS "S/N"
	$hrgpsini = isset($_POST["hrgpsini"]) ? $_POST["hrgpsini"] : ""; // Horario de Pagamento GPS - Inicial
	$hrgpsfim = isset($_POST["hrgpsfim"]) ? $_POST["hrgpsfim"] : ""; // Horario de Pagamento GPS - Final
	$hrsiccau = isset($_POST["hrsiccau"]) ? $_POST["hrsiccau"] : ""; // Atualizar Horario Cancelamento do Pagamento SICREDI "S/N"
	$hrsiccan = isset($_POST["hrsiccan"]) ? $_POST["hrsiccan"] : ""; // Horario de Cancelamento de Pagamento SICREDI
	$hrtitcau = isset($_POST["hrtitcau"]) ? $_POST["hrtitcau"] : ""; // Atualizar Horario Cancelamento do Pagamento TITULOS/FATURAS "S/N"
	$hrtitcan = isset($_POST["hrtitcan"]) ? $_POST["hrtitcan"] : ""; // Horario de Cancelamento de Pagamento TITULOS/FATURAS
	$hrnetcau = isset($_POST["hrnetcau"]) ? $_POST["hrnetcau"] : ""; // Atualizar Horario Cancelamento do Pagamento INTERNET/MOBILE "S/N"
	$hrnetcan = isset($_POST["hrnetcan"]) ? $_POST["hrnetcan"] : ""; // Horario de Cancelamento de Pagamento INTERNET/MOBILE
	$hrtaacau = isset($_POST["hrtaacau"]) ? $_POST["hrtaacau"] : ""; // Atualizar Horario Cancelamento do Pagamento TAA "S/N"
	$hrtaacan = isset($_POST["hrtaacan"]) ? $_POST["hrtaacan"] : ""; // Horario de Cancelamento de Pagamento TAA
	$hrdiuatu = isset($_POST["hrdiuatu"]) ? $_POST["hrdiuatu"] : ""; // Atualizar Horario DEVOLUCAO DIURNA "S/N"
	$hrdiuini = isset($_POST["hrdiuini"]) ? $_POST["hrdiuini"] : ""; // Horario de Pagamento DEVOLUCAO DIURNA - Inicial
	$hrdiufim = isset($_POST["hrdiufim"]) ? $_POST["hrdiufim"] : ""; // Horario de Pagamento DEVOLUCAO DIURNA - Final
	$hrnotatu = isset($_POST["hrnotatu"]) ? $_POST["hrnotatu"] : ""; // Atualizar Horario DEVOLUCAO NOTURNA "S/N"
	$hrnotini = isset($_POST["hrnotini"]) ? $_POST["hrnotini"] : ""; // Horario de Pagamento DEVOLUCAO NOTURNA - Inicial
	$hrnotfim = isset($_POST["hrnotfim"]) ? $_POST["hrnotfim"] : ""; // Horario de Pagamento DEVOLUCAO NOTURNA - Final
	
	// MESAGERIA
	
	// Montar o xml de Requisicao
	$xml .= "<Root>";
	$xml .= " <Dados>";
	$xml .= "   <cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "   <cdcooper>".$cdcooper."</cdcooper>";
	$xml .= "   <hrsicatu>".$hrsicatu."</hrsicatu>";
	$xml .= "   <hrsicini>".$hrsicini."</hrsicini>";
	$xml .= "   <hrsicfim>".$hrsicfim."</hrsicfim>";
	$xml .= "   <hrtitatu>".$hrtitatu."</hrtitatu>";
	$xml .= "   <hrtitini>".$hrtitini."</hrtitini>";
	$xml .= "   <hrtitfim>".$hrtitfim."</hrtitfim>";
	$xml .= "   <hrnetatu>".$hrnetatu."</hrnetatu>";
	$xml .= "   <hrnetini>".$hrnetini."</hrnetini>";
	$xml .= "   <hrnetfim>".$hrnetfim."</hrnetfim>";
	$xml .= "   <hrtaaatu>".$hrtaaatu."</hrtaaatu>";
	$xml .= "   <hrtaaini>".$hrtaaini."</hrtaaini>";
	$xml .= "   <hrtaafim>".$hrtaafim."</hrtaafim>";
	$xml .= "   <hrgpsatu>".$hrgpsatu."</hrgpsatu>";
	$xml .= "   <hrgpsini>".$hrgpsini."</hrgpsini>";
	$xml .= "   <hrgpsfim>".$hrgpsfim."</hrgpsfim>";
	$xml .= "   <hrsiccau>".$hrsiccau."</hrsiccau>";
	$xml .= "   <hrsiccan>".$hrsiccan."</hrsiccan>";
	$xml .= "   <hrtitcau>".$hrtitcau."</hrtitcau>";
	$xml .= "   <hrtitcan>".$hrtitcan."</hrtitcan>";
	$xml .= "   <hrnetcau>".$hrnetcau."</hrnetcau>";
	$xml .= "   <hrnetcan>".$hrnetcan."</hrnetcan>";
	$xml .= "   <hrtaacau>".$hrtaacau."</hrtaacau>";
	$xml .= "   <hrtaacan>".$hrtaacan."</hrtaacan>";
	$xml .= "   <hrdiuatu>".$hrdiuatu."</hrdiuatu>";
	$xml .= "   <hrdiuini>".$hrdiuini."</hrdiuini>";
	$xml .= "   <hrdiufim>".$hrdiufim."</hrdiufim>";
	$xml .= "   <hrnotatu>".$hrnotatu."</hrnotatu>";
	$xml .= "   <hrnotini>".$hrnotini."</hrnotini>";
	$xml .= "   <hrnotfim>".$hrnotfim."</hrnotfim>";
	$xml .= " </Dados>";
	$xml .= "</Root>";
	
	$xmlResult = mensageria($xml, "TELA_PARHPG", "ALTERA_HORARIO_PARHPG", $glbvars["cdcooper"], $glbvars["cdagenci"], $glbvars["nrdcaixa"], $glbvars["idorigem"], $glbvars["cdoperad"], "</Root>");
	$xmlObj = getObjectXML($xmlResult);		
		
	//-----------------------------------------------------------------------------------------------
	// Controle de Erros
	//-----------------------------------------------------------------------------------------------
	if(strtoupper($xmlObj->roottag->tags[0]->name == 'ERRO')){	
	
		$msgErro = $xmlObj->roottag->tags[0]->cdata;
		$nmdcampo = $xmlObj->roottag->tags[0]->attributes["NMDCAMPO"];	
		
		if(empty ($nmdcampo)){ 
			$nmdcampo = "hrsicatu";
		}
		
		if($msgErro == null || $msgErro == ''){
			$msgErro = $xmlObj->roottag->tags[0]->tags[0]->tags[4]->cdata;
		}
		exibirErro('error',$msgErro,'Alerta - Ayllos','$(\'input\',\'#frmHorarios\').habilitaCampo(); focaCampoErro(\''.$nmdcampo.'\',\'frmHorarios\');',false);		
	} 
	
	exibirErro('inform','Altera&ccedil;&atilde;o efetuada com sucesso.','Alerta - Ayllos',"estadoInicial();",false);
?>
