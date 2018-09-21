<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 23/04/2010 
 * OBJETIVO     : Rotina para validar/incluir/alterar/excluir os dados de BANCO da tela de CONTAS
 *
 * ALTERACOES   : [05/08/2015] Gabriel (RKAM) : Reformulacao Cadastral.
 *
 *                [01/12/2016] Renato (Supero): P341-Automatização BACENJUD - Retirado o envio do
 *                                              parametro do departamento ao invés pois não é 
 *                                              utilizado na BO 
 */
?>
 
<?	
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		

	// Guardo os parâmetos do POST em variáveis
	$operacao = (isset($_POST["operacao"])) ? $_POST["operacao"] : "";	
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : "";			
	$idseqttl = (isset($_POST["idseqttl"])) ? $_POST["idseqttl"] : "";	        
	$cddbanco = (isset($_POST["cddbanco"])) ? $_POST["cddbanco"] : "";	        
	$dstipope = (isset($_POST["dstipope"])) ? $_POST["dstipope"] : "";          
	$vlropera = (isset($_POST["vlropera"])) ? $_POST["vlropera"] : "";          
	$garantia = (isset($_POST["garantia"])) ? $_POST["garantia"] : "";          
	$dsvencto = (isset($_POST["dsvencto"])) ? $_POST["dsvencto"] : "";          
	$nrdlinha = (isset($_POST["nrdlinha"])) ? $_POST["nrdlinha"] : "";	
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';	
	                                                                            
	// Retirando os "." dos valores monetários
	$vlropera = str_replace('.','',$vlropera);
		
	// Se não for informado qual operação, exibir mensagem de erro
	if ($operacao == "") exibirErro('error','O par&acirc;metro operação n&atilde;o foi informado.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	

	if(in_array($operacao,array('AV','IV'))) validaDados();
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = "";
	if( $operacao == 'IV' ) {$procedure = 'valida_dados'; $cddopcao = 'I';}
	if( $operacao == 'AV' ) {$procedure = 'valida_dados'; $cddopcao = 'A';}
	if( $operacao == 'EV' ) {$procedure = 'valida_dados'; $cddopcao = 'E';}
	if( $operacao == 'VI' ) {$procedure = 'grava_dados' ; $cddopcao = 'I';}
	if( $operacao == 'VA' ) {$procedure = 'grava_dados' ; $cddopcao = 'A';}
	if( $operacao == 'VE' ) {$procedure = 'grava_dados' ; $cddopcao = 'E';}
	
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$cddopcao)) <> '') exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
			
	// Monta o xml dinâmico de acordo com a operação
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0067.p</Bo>";
	$xml .= "		<Proc>".$procedure."</Proc>";
	$xml .= "	</Cabecalho>";
	$xml .= "	<Dados>";
	$xml .= "       <cdcooper>".$glbvars["cdcooper"]."</cdcooper>";
	$xml .= "		<cdagenci>".$glbvars["cdagenci"]."</cdagenci>";
	$xml .= "		<nrdcaixa>".$glbvars["nrdcaixa"]."</nrdcaixa>";
	$xml .= "		<cdoperad>".$glbvars["cdoperad"]."</cdoperad>";
	$xml .= "		<nmdatela>".$glbvars["nmdatela"]."</nmdatela>";	
	$xml .= "		<idorigem>".$glbvars["idorigem"]."</idorigem>";	
	$xml .= "		<nrdconta>".$nrdconta."</nrdconta>";
	$xml .= "		<idseqttl>".$idseqttl."</idseqttl>";
	$xml .= "		<cddbanco>".$cddbanco."</cddbanco>";
	$xml .= "		<dstipope>".$dstipope."</dstipope>";
	$xml .= "		<vlropera>".$vlropera."</vlropera>";
	$xml .= "		<garantia>".$garantia."</garantia>";
	$xml .= "		<dsvencto>".$dsvencto."</dsvencto>";
	$xml .= "		<nrdlinha>".$nrdlinha."</nrdlinha>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);
	
	// Se ocorrer um erro, mostra mensagem
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		$metodoErro = ( $operacao == 'EV' || $operacao == 'VE' ) ? 'controlaOperacao();' : 'bloqueiaFundo(divRotina);';
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$metodoErro,false);
	}
	
	$msg = Array();
	
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msgRetorno = $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'];	
	$msgAlerta  = $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'];
	
	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;
	
	$stringArrayMsg = implode( "|", $msg);

	// Verificação da revisão Cadastral
	$msgAtCad = $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'];
	$chaveAlt = $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'];
	$tpAtlCad = $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'];	
	
	// Se é Validação
	if( in_array($operacao,array('AV','IV','EV')) ) {
		if( $operacao == 'AV' ) exibirConfirmacao('Deseja confirmar alteração?','Confirmação - Aimaro','controlaOperacao(\'VA\')','bloqueiaFundo(divRotina)',false);		
		if( $operacao == 'IV' ) exibirConfirmacao('Deseja confirmar inclusão?' ,'Confirmação - Aimaro','controlaOperacao(\'VI\')','bloqueiaFundo(divRotina)',false);		
		if( $operacao == 'EV' ) exibirConfirmacao('Deseja confirmar exclusão?' ,'Confirmação - Aimaro','controlaOperacao(\'VE\')','bloqueiaFundo(divRotina);controlaOperacao();',false);
	
	// Se é Inclusão/Alteração/Exclusão
	} else {		
		
		// Verificar se existe "Verificação de Revisão Cadastral"
		if($msgAtCad!='' && $flgcadas != 'M') {					
			if( $operacao == 'VA' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0067.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);
			if( $operacao == 'VI' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0067.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);
			if( $operacao == 'VE' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0067.p\',\''.$stringArrayMsg.'\')','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);
		
		// Se não existe necessidade de Revisão Cadastral
		} else {				
			if($operacao=='VI') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\');';
		    if($operacao=='VA') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\');';
		    if($operacao=='VE') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\');';
			
		}
	} 
	
	function validaDados() {
	
		// No início das validações, primeiro remove a classe erro de todos os campos
		echo '$("input","#frmDadosBancos").removeClass("campoErro");';
		
		// Número da conta e o titular são inteiros válidos
		if (!validaInteiro($GLOBALS['nrdconta'])) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);				
		if (!validaInteiro($GLOBALS['idseqttl'])) exibirErro('error','Seq. Titular inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	

	
		// Campo desc. do banco
		if ( ($GLOBALS['cddbanco'] < 1) || ($GLOBALS['cddbanco'] == '') ) exibirErro('error','C&oacute;digo do banco inv&aacute;lido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'cddbanco\',\'frmDadosBancos\')',false);
		
		//Campo operação
		if ( $GLOBALS['dstipope'] == "" ) exibirErro('error','Campo Operação deve ser preenchido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'dstipope\',\'frmDadosBancos\')',false);
		
		//Campo Valor
		if ( str_replace(',','.',$GLOBALS['vlropera']) <= 0 ) exibirErro('error','Campo Valor( R$ ) deve ser preenchido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'vlropera\',\'frmDadosBancos\')',false);
				
		//Campo garantia
		if ( $GLOBALS['garantia'] == "" ) exibirErro('error','Campo Garantia deve ser preenchido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'garantia\',\'frmDadosBancos\')',false);
		
		//Campo data vencimento
		if ( !validaData($GLOBALS['dsvencto']) && $GLOBALS['dsvencto'] != 'VARIOS' ) exibirErro('error','Campo Vencimento deve conter uma data válida.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'dsvencto\',\'frmDadosBancos\')',false);
	}		
?>