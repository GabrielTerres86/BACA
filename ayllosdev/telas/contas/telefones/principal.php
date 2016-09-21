<?php 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 19/04/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de TELEFONES da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 *							  04/08/2015 - Reformulacao Cadastral (Gabriel-RKAM).
 *						      14/07/2016 - Correcao da forma de recuperacao da dados do XML.SD 479874. Carlos R.
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '' ;
	
	$op = ( $cddopcao == 'C' ) ? '@' : $cddopcao ;
	
	
	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op,false)) <> '') {
		$metodo =  ($flgcadas == 'M') ? 'proximaRotina();' : 'encerraRotina(false);';
		exibirErro('error',$msgError,'Alerta - Ayllos',$metodo,false);	
	}
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Parâmetros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);	

	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');

	setVarSession("opcoesTela",$opcoesTela);

	// Carregas as opções da Rotina de Bens
	$flgAlterar   = (in_array('A', $glbvars['opcoesTela']));
	$flgExcluir   = (in_array('E', $glbvars['opcoesTela']));
	$flgIncluir   = (in_array('I', $glbvars['opcoesTela']));	
	
	$nrdconta  = ( isset($_POST['nrdconta']) )  ? $_POST['nrdconta'] : 0;
	$idseqttl	= ( isset($_POST['idseqttl']) )    ? $_POST['idseqttl'] : 0;
	$inpessoa = ( isset($_POST['inpessoa']) ) ? $_POST['inpessoa'] : 0;
	$operacao = (isset($_POST['operacao']) )  ? $_POST['operacao'] : '';
	$nrdrowid  = (isset($_POST['nrdrowid']) )    ? $_POST['nrdrowid'] : '';
			
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl inválida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);	
	
	$procedure = (in_array($operacao,array('TA','TX','TI','CF'))) ? 'obtem-dados-gerenciar-telefone' : 'obtem-telefone-cooperado';
		
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0070.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<dsdepart>'.$glbvars['dsdepart'].'</dsdepart>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
    $xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';	
    $xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);	
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){ 
		if( $cddopcao == 'I' ){
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaOperacao(\'TI\')',false);
		}else{
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);
		}
	}
	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	$msgAlert  = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) : '';

	//Verifico se conta é titular em outra conta. Se atributo vier preenchido, muda operação para 'SC' => Somente Consulta
	$msgConta = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGCONTA']) ) ? trim($xmlObjeto->roottag->tags[0]->attributes['MSGCONTA']) : '';
	if( $msgConta != '' ) {
		$operacao = ( $operacao != 'CF' ) ? 'SC' : $operacao ;
	}
	
?>
<script type="text/javascript">
	$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
</script> 
<?php
	$sugestao = '';
	$cdopetfn = 0;
	// Se estiver Alterando/Incluindo/Excluindo, chamar o FORMULARIO
	if(in_array($operacao,array('TA','TI','TX','CF'))) {
		
		$registro = $xmlObjeto->roottag->tags[1]->tags[0]->tags;		
		$cdopetfn = getByTagName($registro,'cdopetfn');
		if ( $operacao == 'TI' ){
			$sugestao = '';
			$ArraySugestao = Array();
			$regs = $xmlObjeto->roottag->tags[1]->tags;
			foreach ( $regs as $reg ) { 
				if ( getByTagName($reg->tags,'nrfonass') != '' ) 
					$ArraySugestao[] = getByTagName($reg->tags,'nrfonass'); 
			}
			
			$sugestao = 'Telefones: '.implode( "/", $ArraySugestao);
		}
		
		include('formulario_telefones.php');	
	
	// Se estiver consultando, chamar a TABELA
	} else if(in_array($operacao,array('AT','IT','ET','FI','FA','FE','SC',''))) {
		include('tabela_telefones.php');
	}
?>
<script type="text/javascript">
	var sugestao = '<? echo $sugestao; ?>';
	var msgAlert = '<? echo $msgAlert; ?>';
	var msgConta = '<? echo $msgConta; ?>';
	var operacao = '<? echo $operacao; ?>';
			
	cdopetfn = '<? echo $cdopetfn; ?>';
	
	if (inpessoa == 1) {
		var flgAlterar   = '<? echo $flgAlterar;   ?>';
		var flgExcluir   = '<? echo $flgExcluir;   ?>';
		var flgIncluir   = '<? echo $flgIncluir;   ?>';	
		var flgcadas     = '<? echo $flgcadas;     ?>';		
	}
	
	controlaLayout(operacao);
	
	if ( msgConta != '' && operacao == 'SC' ){
		showError('inform',msgConta,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFoco(\''+operacao+'\');'); 
	}else if ( msgAlert != ''   ){ 
		showError('inform',msgAlert,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFoco(\''+operacao+'\');'); 
	}
	if ( operacao == 'TX' ){ controlaOperacao('EV'); }
</script>
