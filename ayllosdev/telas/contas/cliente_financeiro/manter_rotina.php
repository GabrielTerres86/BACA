<?php
/*!
 * FONTE        : manter_rotina.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 31/03/2010 
 * OBJETIVO     : Rotina para validar/alterar/excluir os dados da aba Dados da rotina CLIENTE FINANCEIRO da tela de CONTAS
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001 [07/07/2011] David (CECRED)        : Ajuste na funcao validaPermissao() para utilizar opcao @.
 * 002 [14/06/2016] Kelvin (CECRED) 	  : Removendo validação de permissão para corrigir problema no chamado 468177.
 * 003 [01/12/2016] Renato Darosci(Supero): Alterado para passar como parametro o código do departamento ao invés da descrição.
 */
 
    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	// Recebe a operação que está sendo realizada
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	
	// Guardo os parâmetos do POST em variáveis nrseqdig
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrcpfcgc = (isset($_POST['nrcpfcgc'])) ? $_POST['nrcpfcgc'] : '';
	$tpregist = (isset($_POST['tpregist'])) ? $_POST['tpregist'] : '';
	$nrseqdig = (isset($_POST['nrseqdig'])) ? $_POST['nrseqdig'] : '';
	$cddbanco = (isset($_POST['cddbanco'])) ? $_POST['cddbanco'] : '';
	$cdageban = (isset($_POST['cdageban'])) ? $_POST['cdageban'] : '';
	$dtabtcct = (isset($_POST['dtabtcct'])) ? $_POST['dtabtcct'] : '';
	$nrdctasf = (isset($_POST['nrdctasf'])) ? $_POST['nrdctasf'] : '';
	$dgdconta = (isset($_POST['dgdconta'])) ? $_POST['dgdconta'] : '';
	$dtmvtolt = (isset($_POST['dtmvtolt'])) ? $_POST['dtmvtolt'] : '';
	$dtmvtosf = (isset($_POST['dtmvtosf'])) ? $_POST['dtmvtosf'] : '';
	$hrtransa = (isset($_POST['hrtransa'])) ? $_POST['hrtransa'] : '';
	$flgenvio = (isset($_POST['flgenvio'])) ? $_POST['flgenvio'] : '';
	$dtdenvio = (isset($_POST['dtdenvio'])) ? $_POST['dtdenvio'] : '';
	$insitcta = (isset($_POST['insitcta'])) ? $_POST['insitcta'] : '';
	$cdmotdem = (isset($_POST['cdmotdem'])) ? $_POST['cdmotdem'] : '';
	$dtdemiss = (isset($_POST['dtdemiss'])) ? $_POST['dtdemiss'] : '';
	$nminsfin = (isset($_POST['nminsfin'])) ? $_POST['nminsfin'] : '';
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '';
	$desopcao = $tpregist;

	// Retirando alguns caracteres do cpf e cnpj                                                    
	$arrayRetirada = array('.','-','/','_');                                                        
	$nrcpfcgc = str_replace($arrayRetirada,'',$nrcpfcgc);                                           
	                                                                                                
	if(in_array($operacao,array('VA','VD','VE'))) validaDados($operacao);								    
	                                                                                                
	// Dependendo da operação, chamo uma procedure diferente                                        
	$procedure = '';                                                                                
	if(in_array($operacao,array('VA')))        {$procedure = 'valida_dados'; $cddopcao = 'A';}        
	if(in_array($operacao,array('VD','VE')))   {$procedure = 'valida_dados'; $cddopcao = 'I';}                      
	if(in_array($operacao,array('VED','VEE'))) {$procedure = 'valida_dados'; $cddopcao = 'E';}                      
	if(in_array($operacao,array('ID','IE')))   {$procedure = 'grava_dados' ; $cddopcao = 'I';}
	if(in_array($operacao,array('AD'))) 	   {$procedure = 'grava_dados' ; $cddopcao = 'A';}
	if(in_array($operacao,array('ED','EE')))   {$procedure = 'exclui_dados'; $cddopcao = 'E';}
	
	// Monta o xml dinâmico de acordo com a operação 
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0061.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';           
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';           
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';           
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';           
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';           
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';           
	$xml .= '		<cddepart>'.$glbvars['cddepart'].'</cddepart>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';                       
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';	                   
	$xml .= '       <nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';                       
	$xml .= '       <tpregist>'.$tpregist.'</tpregist>';                       
	$xml .= '       <nrseqdig>'.$nrseqdig.'</nrseqdig>';                       
	$xml .= '       <cddbanco>'.$cddbanco.'</cddbanco>';                       
	$xml .= '       <cdageban>'.$cdageban.'</cdageban>';                       
	$xml .= '       <cddopcao>'.$cddopcao.'</cddopcao>';                       
	$xml .= '       <desopcao>'.$desopcao.'</desopcao>';                       
	$xml .= '       <dtabtcct>'.$dtabtcct.'</dtabtcct>';                       
	$xml .= '       <nrdctasf>'.$nrdctasf.'</nrdctasf>';                       
	$xml .= '       <dgdconta>'.$dgdconta.'</dgdconta>';                                           
	$xml .= '       <dtmvtolt>'.$dtmvtolt.'</dtmvtolt>';
	$xml .= '       <dtmvtosf>'.$dtmvtosf.'</dtmvtosf>';
	$xml .= '       <hrtransa>'.$hrtransa.'</hrtransa>';
	$xml .= '       <flgenvio>'.$flgenvio.'</flgenvio>';
	$xml .= '       <dtdenvio>'.$dtdenvio.'</dtdenvio>';
	$xml .= '       <insitcta>'.$insitcta.'</insitcta>';
	$xml .= '       <cdmotdem>'.$cdmotdem.'</cdmotdem>';
	$xml .= '       <dtdemiss>'.$dtdemiss.'</dtdemiss>';
	$xml .= '       <nminsfin>'.$nminsfin.'</nminsfin>';
	$xml .= '       <nrdrowid>'.$nrdrowid.'</nrdrowid>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
		
	$xmlResult = getDataXML($xml);	
	$xmlObjeto = getObjectXML($xmlResult);
	
	// exibirErro('error',$xmlObjeto->roottag->tags[0]->name,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	$msg = Array();
	
	// Se não retornou erro, então pegar a mensagem de retorno do Progress na variável msgRetorno, para ser utilizada posteriormente
	$msgRetorno = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGRETOR']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGRETOR'] : '';
	$msgAlerta   = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'] : '';
	
	if ($msgRetorno!='') $msg[] = $msgRetorno;
	if ($msgAlerta!='' ) $msg[] = $msgAlerta;
	
	$stringArrayMsg = implode( "|", $msg);
	
	// Verificação da revisão Cadastral
	$msgAtCad = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGATCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGATCAD'] : '';
	$chaveAlt    = ( isset($xmlObjeto->roottag->tags[0]->attributes['CHAVEALT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['CHAVEALT'] : ''; 
	$tpAtlCad    = ( isset($xmlObjeto->roottag->tags[0]->attributes['TPATLCAD']) ) ? $xmlObjeto->roottag->tags[0]->attributes['TPATLCAD'] : '';
	
	// Se é Validação
	if(in_array($operacao,array('VA','VD','VE','VEE','VED'))) {
		
		echo 'hideMsgAguardo();';
		if($operacao=='VA' ) echo "showConfirmacao('Deseja confirmar altera&ccedil;&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao(\'AD\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');";
		if($operacao=='VD' ) echo "showConfirmacao('Deseja confirmar inclus&atilde;o?'        ,'Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao(\'ID\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');";
		if($operacao=='VE' ) echo "showConfirmacao('Deseja confirmar inclus&atilde;o?'        ,'Confirma&ccedil;&atilde;o - Ayllos','controlaOperacao(\'IE\')','bloqueiaFundo(divRotina)','sim.gif','nao.gif');";
		if($operacao=='VED') echo "showConfirmacao('Deseja confirmar exclus&atilde;o?'        ,'Confirma&ccedil;&atilde;o - Ayllos','manterRotina(\'ED\')','controlaOperacao()','sim.gif','nao.gif');";
		if($operacao=='VEE') echo "showConfirmacao('Deseja confirmar exclus&atilde;o?'        ,'Confirma&ccedil;&atilde;o - Ayllos','manterRotina(\'EE\')','controlaOperacao()','sim.gif','nao.gif');";
		
	}else{
		echo 'exibirMensagens(\''.$stringArrayMsg.'\',\'controlaOperacao(\"\")\');';
	}
	
	function validaDados($op) {
		if($op == 'VA' || $op == 'VD'){
			// No início das validações, primeiro remove a classe erro de todos os campos
			echo '$("input,select","#formDadosSistFinanc").removeClass("campoErro");';
			
			// Data Abertura
			if ( !validaData( $GLOBALS['dtabtcct'] )) exibirErro('error','Data de abertura inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dtabtcct\',\'formDadosSistFinanc\')',false);
			
			// Cod. do banco
			if ( $GLOBALS['cddbanco'] == '' || !validaInteiro($GLOBALS['cddbanco']) ) exibirErro('error','C&oacute;digo do banco inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cddbanco\',\'formDadosSistFinanc\')',false);
			
			// Cod. da agencia
			if ( $GLOBALS['cdageban'] == '' || !validaInteiro($GLOBALS['cdageban']) ) exibirErro('error','C&oacute;digo da ag&ecirc;ncia inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdageban\',\'formDadosSistFinanc\')',false);
			
			// Número da conta
			if ( !validaInteiro($GLOBALS['nrdctasf']) ) exibirErro('error','N&uacute;mero da conta inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nrdctasf\',\'formDadosSistFinanc\')',false);
			
			//Dig. verificador
			if ( $GLOBALS['dgdconta'] == '' ) exibirErro('error','DV inv&aacute;lido.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'dgdconta\',\'formDadosSistFinanc\')',false);
			
			// Inst. Financeira
			if ( $GLOBALS['cddbanco'] == 0 ) { if ( $GLOBALS['nminsfin'] =='' ) exibirErro('error','Nome Titular deve ser informado.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'nminsfin\',\'formDadosSistFinanc\')',false);}
			
		}else if ($op == 'VE' ){
			// No início das validações, primeiro remove a classe erro de todos os campos
			echo '$("input,select","#formEmissaoSistFinanc").removeClass("campoErro");';
			
			// Cod. do banco
			if ( $GLOBALS['cddbanco'] == '' || !validaInteiro($GLOBALS['cddbanco']) || $GLOBALS['cddbanco'] == 0 ) exibirErro('error','C&oacute;digo do banco inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cddbanco\',\'formEmissaoSistFinanc\')',false);
			
			// Cod. da agencia
			if ( $GLOBALS['cdageban'] == '' || !validaInteiro($GLOBALS['cdageban']) || $GLOBALS['cdageban'] == 0 ) exibirErro('error','C&oacute;digo da ag&ecirc;ncia inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina,\'cdageban\',\'formEmissaoSistFinanc\')',false);
		}
	}	
?>