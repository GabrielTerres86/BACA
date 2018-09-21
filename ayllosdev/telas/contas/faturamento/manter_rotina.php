<? 
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 23/04/2010 
 * OBJETIVO     : Rotina para validar/incluir/alterar/excluir os dados de Banco da tela de CONTAS
 * --------------
 * ALTERAÇÕES   : 
 * --------------
 * 001 [07/07/2011] David (CECRED): Ajuste na funcao validaPermissao() para utilizar variavel $cddopcao.
 * 002 [05/08/2015] Reformulacao cadastral (Gabriel-RKAM)
 * 003 [01/12/2016] P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                  pois a BO não utiliza o mesmo (Renato Darosci)
 */
 ?>
 
 <?	
    session_start();
	require_once("../../../includes/config.php");
	require_once("../../../includes/funcoes.php");
	require_once("../../../includes/controla_secao.php");
	require_once("../../../class/xmlfile.php");
	isPostMethod();		

	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST["operacao"])) ? $_POST["operacao"] : "";			
	$nrdconta = (isset($_POST["nrdconta"])) ? $_POST["nrdconta"] : "";			
	$idseqttl = (isset($_POST["idseqttl"])) ? $_POST["idseqttl"] : "";	        
	$anoftbru = (isset($_POST["anoftbru"])) ? $_POST["anoftbru"] : "";	        
	$mesftbru = (isset($_POST["mesftbru"])) ? $_POST["mesftbru"] : "";          
	$vlrftbru = (isset($_POST["vlrftbru"])) ? $_POST["vlrftbru"] : "";          
	$nrposext = (isset($_POST["nrposext"])) ? $_POST["nrposext"] : "";   
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';	
	
	                                                                            
	// Retirando os "." dos valores monetários
	$vlrftbru = str_replace('.','',$vlrftbru);
	
	// Se a operação é de inclusão, limpo o "nrposext"
	$nrposext = (in_array($operacao,array('IV','VI'))) ? "" : $nrposext;
	
	 //exibirErro('error','OP- '.$operacao.' nrdconta= '.$nrdconta.' nrposext= '.$nrposext,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Se não for informado qual operação, exibir mensagem de erro
	if ($operacao == "") exibirErro('error','O par&acirc;metro operação n&atilde;o foi informado.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	

	if(in_array($operacao,array('AV','IV'))) validaDados();
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = "";
	if( $operacao == 'IV' ) {$procedure = 'valida_dados'; $cddopcao = 'I';}
	if( $operacao == 'AV' ) {$procedure = 'valida_dados'; $cddopcao = 'A';}
	if( $operacao == 'VI' ) {$procedure = 'grava_dados' ; $cddopcao = 'I';}
	if( $operacao == 'VA' ) {$procedure = 'grava_dados' ; $cddopcao = 'A';}
	if( $operacao == 'CE' ) {$procedure = 'grava_dados' ; $cddopcao = 'E';}
	
	if (($msgError = validaPermissao($glbvars["nmdatela"],$glbvars["nmrotina"],$cddopcao)) <> "") exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
		
	// Monta o xml dinâmico de acordo com a operação
	$xml  = "";
	$xml .= "<Root>";
	$xml .= "	<Cabecalho>";
	$xml .= "		<Bo>b1wgen0069.p</Bo>";
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
	$xml .= "		<anoftbru>".$anoftbru."</anoftbru>";		
	$xml .= "		<mesftbru>".$mesftbru."</mesftbru>";        
	$xml .= "		<vlrftbru>".$vlrftbru."</vlrftbru>";        
	$xml .= "		<nrposext>".$nrposext."</nrposext>";
	$xml .= "		<cddopcao>".$cddopcao."</cddopcao>";
	$xml .= "	</Dados>";
	$xml .= "</Root>";
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	//exibirErro('error','Op.: '.$operacao,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO") exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
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
	
	//exibirErro('inform','OP- '.$operacao,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	// Se é Validação
	if(in_array($operacao,array('IV','AV'))) {
		
		
		echo 'hideMsgAguardo();';
		if($operacao=='IV') exibirConfirmacao('Deseja confirmar inclusão?' ,'Confirmação - Aimaro','controlaOperacao(\'VI\')','bloqueiaFundo(divRotina)',false);		
		if($operacao=='AV') exibirConfirmacao('Deseja confirmar alteração?' ,'Confirmação - Aimaro','controlaOperacao(\'VA\')','bloqueiaFundo(divRotina)',false);		
		
		
	// Se é Inclusão ou Alteração
	} else {
		
		// Verificar se existe "Verificação de Revisão Cadastral"
		if( $msgAtCad != '' && $flgcadas != 'M' ) {			
			if($operacao=='VI') exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0069.p\',\''.$stringArrayMsg.'\');','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FI\")\')',false);		
			if( $operacao == 'VA' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0069.p\',\''.$stringArrayMsg.'\');','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);		
			if( $operacao == 'VA' ) exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0067.p\',\''.$stringArrayMsg.'\');','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\')',false);
			if($operacao=='CE') exibirConfirmacao($msgAtCad,'Confirmação - Aimaro','revisaoCadastral(\''.$chaveAlt.'\',\''.$tpAtlCad.'\',\'b1wgen0069.p\',\''.$stringArrayMsg.'\');','exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FE\")\')',false);
			
		// Se não existe necessidade de Revisão Cadastral
		} else {	
			
			
			// Chama o controla Operação Finalizando a Inclusão ou Alteração
			
		    if($operacao=='VI') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FI\")\')';
		    if($operacao=='VA') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FA\")\')';
		    if($operacao=='CE') echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"FE\")\')';
			
		}
	} 
	
	function validaDados() {
	
		// No início das validações, primeiro remove a classe erro de todos os campos	
		echo '$("input","#frmDadosFaturamento").removeClass("campoErro");';                  
		                                                                                
		// Número da conta e o titular são inteiros válidos
		if (!validaInteiro($GLOBALS['nrdconta'])) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);				
		if (!validaInteiro($GLOBALS['idseqttl'])) exibirErro('error','Seq. Titular inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	

	
		// Campo desc. do banco
		if ( $GLOBALS['mesftbru'] > 12 || $GLOBALS['mesftbru'] < 1 || $GLOBALS['mesftbru'] == "" ) exibirErro('error','Campo Mês deve conter um mês válido','Alerta - Aimaro','bloqueiaFundo(divRotina,\'mesftbru\',\'frmDadosFaturamento\')',false);
		
		//Campo operação
		if ( $GLOBALS['anoftbru'] == "" || $GLOBALS['anoftbru'] < 1000 ) exibirErro('error','Campo Ano deve ser preenchido com um ano válido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'anoftbru\',\'frmDadosFaturamento\')',false);
		
		//Campo Valor
		if ( str_replace(',','.',$GLOBALS['vlrftbru']) == "" ) exibirErro('error','Campo Valor( R$ ) deve ser preenchido.','Alerta - Aimaro','bloqueiaFundo(divRotina,\'vlrftbru\',\'frmDadosFaturamento\')',false);
		
	}	
	
?>