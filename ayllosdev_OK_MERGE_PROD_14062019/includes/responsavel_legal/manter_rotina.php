<? 
/*!
 * FONTE        : manter_bens.php
 * CRIAÇÃO      : Rodolpho Telmo - DB1 Informatica
 * DATA CRIAÇÃO : 09/03/2010 
 * OBJETIVO     : Rotina para validar/incluir/alterar/excluir os dados dos bens da tela de CONTAS
 * ALTERAÇÕES   : 24/04/2012 - Ajustes referente ao projeto GP - Sócios Menores (Adriano).
 *                17/07/2015 - Reformulacao cadastral (Gabriel-RKAM)
 *                25/04/2017 - Alterado campo dsnacion para cdnacion. (Projeto 339 - Odirlei-AMcom)
 *				  28/08/2017 - Alterado tipos de documento para utilizarem CI, CN, 
 *							   CH, RE, PP E CT. (PRJ339 - Reinert)
 *				  25/10/2017 - Removendo campo caixa postal (PRJ339 - Kelvin).
 */
?>
 
<?	
    session_start();
	require_once("../config.php");
	require_once("../funcoes.php");
	require_once("../controla_secao.php");
	require_once("../../class/xmlfile.php");
	isPostMethod();	
	
	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST["operacao_rsp"])) ? $_POST["operacao_rsp"] : "";		
	
	// Guardo os parâmetos do POST em variáveis
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : "";		
	$idseqttl = (isset($_POST["idseqttl"])) ? $_POST["idseqttl"] : "";		
	$nrcpfcto = (isset($_POST["nrcpfcto"])) ? $_POST["nrcpfcto"] : "";      
	$cdoeddoc = (isset($_POST["cdoeddoc"])) ? $_POST["cdoeddoc"] : "";      
	$dtnascto = (isset($_POST["dtnascto"])) ? $_POST["dtnascto"] : "";      
	$dtemddoc = (isset($_POST["dtemddoc"])) ? $_POST["dtemddoc"] : "";      
	$nrdctato = (isset($_POST["nrdctato_rsp"])) ? $_POST["nrdctato_rsp"] : "";      
	$nmdavali = (isset($_POST["nmdavali"])) ? $_POST["nmdavali"] : "";      
	$cdufddoc = (isset($_POST["cdufddoc"])) ? $_POST["cdufddoc"] : "";      
	$tpdocava = (isset($_POST["tpdocava"])) ? $_POST["tpdocava"] : "";      
	$nrdocava = (isset($_POST["nrdocava"])) ? $_POST["nrdocava"] : "";      
	$cdestcvl = (isset($_POST["cdestcvl"])) ? $_POST["cdestcvl"] : "";      
	$cdnacion = (isset($_POST["cdnacion"])) ? $_POST["cdnacion"] : "";      
	$dsnatura = (isset($_POST["dsnatura"])) ? $_POST["dsnatura"] : "";      
	$complend = (isset($_POST["complend"])) ? $_POST["complend"] : "";      
	$nmcidade = (isset($_POST["nmcidade"])) ? $_POST["nmcidade"] : "";      
	$nmbairro = (isset($_POST["nmbairro"])) ? $_POST["nmbairro"] : "";      
	$dsendere = (isset($_POST["dsendere"])) ? $_POST["dsendere"] : "";      
	$cdufende = (isset($_POST["cdufende"])) ? $_POST["cdufende"] : "";      
	$nmpaicto = (isset($_POST["nmpaicto"])) ? $_POST["nmpaicto"] : "";      
	$nmmaecto = (isset($_POST["nmmaecto"])) ? $_POST["nmmaecto"] : "";      
	$nrendere = (isset($_POST["nrendere"])) ? $_POST["nrendere"] : "";      
	$nrcepend = (isset($_POST["nrcepend"])) ? $_POST["nrcepend"] : "";      
	$cdsexcto = (isset($_POST["cdsexcto"])) ? $_POST["cdsexcto"] : "";
	$nrcxapst = 0;
	$nrdrowid = (isset($_POST["nrdrowid_rsp"])) ? $_POST["nrdrowid_rsp"] : "";
	$cpfprocu = (isset($_POST["cpfprocu"])) ? $_POST["cpfprocu"] : "";
	$nmrotina = (isset($_POST["nmrotina"])) ? $_POST["nmrotina"] : "";
	$dtdenasc = (isset($_POST["dtdenasc"])) ? $_POST["dtdenasc"] : "";
	$cdhabmen = (isset($_POST["cdhabmen"])) ? $_POST["cdhabmen"] : "";
	$permalte = (isset($_POST["permalte"])) ? $_POST["permalte"] : "";
	$validadt = (isset($_POST["validadt"])) ? $_POST["validadt"] : "";
	$cdrlcrsp = (isset($_POST["cdrlcrsp"])) ? $_POST["cdrlcrsp"] : ""; 
	$arrayFilhos = (isset($_POST['arrayFilhos'])) ? $_POST['arrayFilhos'] : '';
	
	$arrayRetirada = array('.','-','/','_');
	$nrcpfcto = str_replace($arrayRetirada,'',$nrcpfcto);
	$nrcepend = str_replace($arrayRetirada,'',$nrcepend);
	$nrendere = str_replace($arrayRetirada,'',$nrendere);
	$nrcxapst = str_replace($arrayRetirada,'',$nrcxapst);
	$nrdctato = ($nrdctato == '') ? 0 : str_replace($arrayRetirada,'',$nrdctato);	
	
		
	if(in_array($operacao,array('AV','IV'))) validaDados();
		
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = "";
	switch($operacao) {

		case 'IV': $procedure = 'valida_dados'; $cddopcao = "I"; break;
		case 'AV': $procedure = 'valida_dados'; $cddopcao = "A"; break;
		case 'EV': $procedure = 'valida_dados'; $cddopcao = "E"; break;
		case 'VI': $procedure = 'grava_dados' ; $cddopcao = "I"; break;
		case 'VA': $procedure = 'grava_dados' ; $cddopcao = "A"; break;
		case 'VE': $procedure = 'grava_dados' ; $cddopcao = "E"; break;
		default: return false;
		
	}

	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

	
	// Monta o xml dinâmico de acordo com a operação cdcooper nrdconta nrdctato idseqttl nrcpfcto
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0072.p</Bo>";
	$xml .= "		<Proc>".$procedure."</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "		<cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";
	$xml .= "       <nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "       <idseqttl>".$idseqttl."</idseqttl>";

	/*Para quando o associado e/ou responsavel legal forem correntista, não será passando o número do cpf.*/
	if($nrdctato == 0){
		$xml .= "       <nrcpfcto>".$nrcpfcto."</nrcpfcto>";  
	}else{
		$xml .= "       <nrcpfcto>0</nrcpfcto>";  
	}


	if($nrdconta == 0){
		$xml .= "       <cpfprocu>".$cpfprocu."</cpfprocu>";  
	}else{
		$xml .= "       <cpfprocu>0</cpfprocu>";  
	}

	$xml .= "       <cdoeddoc>".$cdoeddoc."</cdoeddoc>";  
	$xml .= "       <dtnascto>".$dtnascto."</dtnascto>";  
	$xml .= "       <dtemddoc>".$dtemddoc."</dtemddoc>";  
	$xml .= "       <nrdctato>".$nrdctato."</nrdctato>";  
	$xml .= "       <nmdavali>".$nmdavali."</nmdavali>";  
	$xml .= "       <cdufddoc>".$cdufddoc."</cdufddoc>";  
	$xml .= "       <tpdocava>".$tpdocava."</tpdocava>";  
	$xml .= "       <nrdocava>".$nrdocava."</nrdocava>";  
	$xml .= "       <cdestcvl>".$cdestcvl."</cdestcvl>";  
	$xml .= "       <cdnacion>".$cdnacion."</cdnacion>";  
	$xml .= "       <dsnatura>".$dsnatura."</dsnatura>";  
	$xml .= "       <complend>".$complend."</complend>";  
	$xml .= "       <nmcidade>".$nmcidade."</nmcidade>";  
	$xml .= "       <nmbairro>".$nmbairro."</nmbairro>";  
	$xml .= "       <dsendere>".$dsendere."</dsendere>";  
	$xml .= "       <cdufende>".$cdufende."</cdufende>";  
	$xml .= "       <nmpaicto>".$nmpaicto."</nmpaicto>";  
	$xml .= "       <nmmaecto>".$nmmaecto."</nmmaecto>";  
	$xml .= "       <nrendere>".$nrendere."</nrendere>";  
	$xml .= "       <nrcepend>".$nrcepend."</nrcepend>";  
	$xml .= "       <cdsexcto>".$cdsexcto."</cdsexcto>";
	$xml .= "       <nrcxapst>".$nrcxapst."</nrcxapst>";
	$xml .= "       <nrdrowid>".$nrdrowid."</nrdrowid>";
	$xml .= "       <nmrotina>".$nmrotina."</nmrotina>";
	$xml .= "       <cdrlcrsp>".$cdrlcrsp."</cdrlcrsp>";
	
	
	if($validadt == 'true'){
		$xml .= "       <cddopcao>DT</cddopcao>";
	}else{
		$xml .= "       <cddopcao>".$cddopcao."</cddopcao>";
	}
	
	if($procedure == 'valida_dados'){
		
		$xml .= "		<dtdenasc>".$dtdenasc."</dtdenasc>";   
		$xml .= "		<cdhabmen>".$cdhabmen."</cdhabmen>";  
		$xml .= "		<permalte>".$permalte."</permalte>";
					

		/*Resp. Legal*/
		foreach ($arrayFilhos as $key => $value) {
    
			$campospc = "";
			$dadosprc = "";
			$contador = 0;
			
			foreach( $value as $chave => $valor ){
				
				$contador++;
				
				if($contador == 1){
					$campospc .= $chave;
					
				}else{
					$campospc .= "|".$chave;
				}
				
				if($contador == 1){
					$dadosprc .= $valor;
					
				}else{
					$dadosprc .= ";".$valor;
				}
				
			}
			
			$xml .= retornaXmlFilhos( $campospc, $dadosprc, 'RespLegal', 'Responsavel');
			
		}			
					
	}		
		
	$xml .= "	</Dados>";
	$xml .= "</Root>";

	
	// Executa script para envio do XML e cria objeto para classe de tratamento de XML 
	$xmlResult = getDataXML($xml);	
	$xmlObjeto = getObjectXML($xmlResult);

	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
		$metodoErro = ( $operacao == 'EV' || $operacao == 'VE' ) ? 'bloqueiaFundo(divRotina);controlaOperacaoResp()' : 'rollBack();bloqueiaFundo(divRotina);';
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$metodoErro,false);		
	}

	$msg = Array();

	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msgRetorno = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];	
	$msgAlerta  = $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'];

	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;

	$stringArrayMsg = implode( "|", $msg);
			
	//Verificação da revisão Cadastral
	$msgAtCad = $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'];
	$chaveAlt = $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'];
	$tpAtlCad = $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'];	

	if($nmrotina == "Responsavel Legal"){
	
		// Se é Validação
		if( in_array($operacao,array('AV','IV','EV')) ) {

			if( $operacao == 'AV' ) exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Aimaro','controlaOperacaoResp(\'VA\')','bloqueiaFundo(divRotina)',false);		
			if( $operacao == 'IV' ) exibirConfirmacao('Deseja confirmar inclusão?' ,'Confirmação - Aimaro','controlaOperacaoResp(\'VI\')','bloqueiaFundo(divRotina)',false);		
			if( $operacao == 'EV' ) exibirConfirmacao('Deseja confirmar exclusão?' ,'Confirmação - Aimaro','controlaOperacaoResp(\'VE\')','bloqueiaFundo(divRotina);controlaOperacaoResp();',false);


		// Se é Inclusão/Alteração/Exclusão
		} else {		
			
			// Verificar se existe "Verificação de Revisão Cadastral"
			if($msgAtCad!='') {					
				if( $operacao == 'VA' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0071.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoResp(\"\")\')',false);
				if( $operacao == 'VI' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0071.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoResp(\"\")\')',false);
				if( $operacao == 'VE' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0071.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoResp(\"\")\')',false);
			
			// Se não existe necessidade de Revisão Cadastral
			} else {				
				if( $operacao == 'VA' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoResp(\"\")\')';
				if( $operacao == 'VI' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoResp(\"\")\')';
				if( $operacao == 'VE' ) echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacaoResp(\"\")\')';
			}
		} 
	}else{

		 if ( $operacao == 'AV' ) { ?>
			controlaOperacaoResp();
										
		<?}else if ( $operacao == 'IV' ) { ?>
					controlaOperacaoResp();
															
		<?}
	
	}
	
	function validaDados() {
	
		echo '$("input,select","#frmRespLegal").removeClass("campoErro");';		
		
		// Número da conta e o titular são inteiros válidos
		//if ( (!validaInteiro($GLOBALS['nrdctato'])) || ($GLOBALS['nrdctato'] == '' )) exibirErro('error','Conta/dv inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nrdctato\',\'frmRespLegal\')',false);
				
				
		// Número da conta e o titular são inteiros válidos
		if ( (!validaInteiro($GLOBALS['nrcpfcto'])) || ($GLOBALS['nrcpfcto'] == '' ) || ($GLOBALS['nrcpfcto'] == 0 )) exibirErro('error','C.P.F. inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nrcpfcto\',\'frmRespLegal\')',false);
		
		//Campo nome do respon.
		if ($GLOBALS['nmdavali']=='') exibirErro('error','Nome inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nmdavali\',\'frmRespLegal\')',false);
		
		// Data Nascimento
		if (!validaData($GLOBALS['dtnascto'])) exibirErro('error','Data de Nascimento inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'dtnascto\',\'frmRespLegal\')',false);
				
		// Tipo de Documento
		if (!in_array($GLOBALS['tpdocava'],array('CI','CN','CH','RE','PP','CT'))) exibirErro('error','Tipo de Documento inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'tpdocava\',\'frmRespLegal\')',false);
		
		// Numero de Documento
		if ( $GLOBALS['nrdocava'] == '' ) exibirErro('error','Nr. do Documento inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nrdocava\',\'frmRespLegal\')',false);
		
		// Orgão Emissor
		if ( $GLOBALS['cdoeddoc'] == '' ) exibirErro('error','Org&atilde;o Emissor inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdoeddoc\',\'frmRespLegal\')',false);
		
		// UF Emissor
		if ( $GLOBALS['cdufddoc'] == '') exibirErro('error','U.F. Emissor inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdufddoc\',\'frmRespLegal\')',false);		
		
		// Data Emissão
		if (!validaData($GLOBALS['dtemddoc'])) exibirErro('error','Data de Emiss&atilde;o inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'dtemddoc\',\'frmRespLegal\')',false);
		
		// Estado Civil
		if (!validaInteiro($GLOBALS['cdestcvl'])) exibirErro('error','Estado Civil inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdestcvl\',\'frmRespLegal\')',false);
		if ( $GLOBALS['cdestcvl'] == 0 ) exibirErro('error','Estado Civil deve ser diferente de zero.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdestcvl\',\'frmRespLegal\')',false);
		
		// Sexo 
		if ( $GLOBALS['cdsexcto'] == 0 ) exibirErro('error','Selecione o sexo do responsável.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'sexoMas\',\'frmRespLegal\')',false);
						
		// Nacionalidade
		if ( $GLOBALS['cdnacion'] == '' ) exibirErro('error','Nacionalidade inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdnacion\',\'frmRespLegal\')',false);
					
		// Naturalidade
		if ( $GLOBALS['dsnatura' ] == '') exibirErro('error','Naturalidade inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'dsnatura\',\'frmRespLegal\')',false);
		
		//CEP
		if ( !validaInteiro($GLOBALS['nrcepend']) || $GLOBALS['nrcepend'] == "" || $GLOBALS['nrcepend'] == 0 ) exibirErro('error','CEP inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nrcepend\',\'frmRespLegal\')',false);
		
		//End. residencial
		if ( $GLOBALS['dsendere'] == '' ) exibirErro('error','End. residencial inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'dsendere\',\'frmRespLegal\')',false);
		
		//Bairro
		if ( $GLOBALS['nmbairro'] == '') exibirErro('error','Bairro inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nmbairro\',\'frmRespLegal\')',false);
		
		// UF End.
		if ( $GLOBALS['cdufende'] == '' ) exibirErro('error','U.F. inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdufende\',\'frmRespLegal\')',false);		
		
		//Cidade
		if ( $GLOBALS['nmcidade'] == '' ) exibirErro('error','Cidade inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nmcidade\',\'frmRespLegal\')',false);
		
		// Filiação Mãe
		if ( $GLOBALS['nmmaecto'] == '') exibirErro('error','Nome da m&atilde;e inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'nmmaecto\',\'frmRespLegal\')',false);		
	
		// Relacionamento 1. ttl
		if ( $GLOBALS['cdrlcrsp'] == '') exibirErro('error','Relacionamento com Titular inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cdrlcrsp\',\'frmRespLegal\')',false);		

	
	}
?>