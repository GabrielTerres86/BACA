<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Gabriel Santos (DB1)
 * DATA CRIAÇÃO : Março/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de CLIENTE FINANCEIRO da tela de CONTAS 
 * --------------
 * ALTERAÇÕES   :
 * --------------
 * 001 [29/03/2010] Rodolpho Telmo (DB1)  : Controle de Abas
 * 002 [20/12/2010] Gabriel Capoia (DB1   : Adicionado chamada validaPermissao
 * 003 [07/07/2011] David (CECRED)        : Ajuste na funcao validaPermissao() para utilizar a opcao @.
 * 004 [05/08/2015] Gabriel (RKAM)        : Reformulacao cadastral. 
 * 005 [14/06/2016] Kelvin (CECRED) 	  : Removendo validação de permissão para corrigir problema no chamado 468177.
 * 006 [14/07/2016] Carlos R. (CECRED)    : Correcao na validacao de dados retornados via XML. SD 479874.
 * 007 [01/12/2016] Renato Darosci(Supero): Alterado para passar como parametro o código do departamento ao invés da descrição. 
 */
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : 'TD';
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';
	
	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];
	
	switch ($operacao) {	
		case 'FI': $cddopcao = 'I'; break;
		case 'FE': $cddopcao = 'I'; break;
		case 'TD': $cddopcao = 'C'; break;
		case 'TE': $cddopcao = 'C'; break;
		case 'FD': $cddopcao = 'A'; break;
		default  : $cddopcao = 'C'; break;
	}	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','fechaRotina(divRotina)',false);
	
	
	// Guardo os parâmetos do POST em variáveis	
	$nrdconta = $_POST['nrdconta'] == '' ?  0   : $_POST['nrdconta'];
	$idseqttl = $_POST['idseqttl'] == '' ?  0   : $_POST['idseqttl'];
	$tpregist = $_POST['tpregist'] == '' ?  1   : $_POST['tpregist'];
	$nrseqdig = $_POST['nrseqdig'] == '' ?  0   : $_POST['nrseqdig'];
	$opcaotel = ( isset($_POST['opcaotel']) ) ?  $_POST['opcaotel'] : 0;

	
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '';	
		
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','fechaRotina(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl n&atilde;o foi informada.','Alerta - Aimaro','fechaRotina(divRotina)',false);	
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0061.p</Bo>';
	$xml .= '		<Proc>busca_dados</Proc>';
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
	$xml .= '		<nrseqdig>'.$nrseqdig.'</nrseqdig>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<tpregist>'.$tpregist.'</tpregist>';
	$xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult  = getDataXML($xml);	
	$xmlObjeto  = getObjectXML($xmlResult);	
	$cliente 	= $xmlObjeto->roottag->tags[0]->tags[0]->tags;
	$registros 	= $xmlObjeto->roottag->tags[1]->tags;
	
	$inpessoa   = getByTagName($cliente,'inpessoa');
	
	// Se ocorrer um erro, mostra crítica
	if (isset($xmlObjeto->roottag->tags[0]->name) && strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') 
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
	
	// Se não retornou erro, então pegar a mensagem de alerta do Progress na variável msgAlerta, para ser utilizada posteriormente
	$msgAlert = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? $xmlObjeto->roottag->tags[0]->attributes['MSGALERT'] : '';

?>
<script type="text/javascript">
	$('#divConteudoCliente').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
</script> 
<div id="divClienteFinanceiro">	
	
	<form name="frmCabClienteFinanceiro" id="frmCabClienteFinanceiro" class="formulario">		
		<label for="nrcpfcgc" class="rotulo rotulo-80">C.P.F./C.N.P.J.:</label>
		<? $tipo = ( $inpessoa == 1 ) ? 'cpf' : 'cnpj'; ?>
		<input name="nrcpfcgc" id="nrcpfcgc" type="text" value="<? echo formatar(getByTagName($cliente,'nrcpfcgc'),$tipo) ?>" />
		
		<label for="inpessoa">Tp. Natureza:</label>
		<? $tpNatureza = ( $inpessoa == 1 ) ? '1 - F&iacute;sica' : '2 - Jur&iacute;dica'; ?>
		<input name="inpessoa" id="inpessoa" type="text" class="alphanum" value="<? echo $tpNatureza; ?>" />
		<br />
		
		<label for="nmextttl" class="rotulo rotulo-80">Nome Titular:</label>
		<input name="nmextttl" id="nmextttl" type="text" class="alphanum" value="<? echo getByTagName($cliente,'nmextttl') ?>" />
		<br style="clear:both" />
	</form>
	
	<div id="divConteudoClienteFinanc">		
	<?
		if ($operacao == 'TD'){	include("tabela_dados.php");}
		else if ($operacao == 'TE'){ include("tabela_emissao.php");}
		else if ($operacao == 'FD' || $operacao == 'FI' ){ include("formulario_dados.php");}
		else if ($operacao == 'FE'){ include("formulario_emissao.php"); }
	?>	
	</div>
	
</div>

<script type='text/javascript'>
	var msgAlert = '<? echo $msgAlert; ?>';
	var operacao = '<? echo $operacao; ?>';	
	var tpregist = '<? echo $tpregist; ?>';	
	
	if (inpessoa == 1) {
		var flgcadas = '<? echo $flgcadas; ?>';
	}
	
	
	controlaLayout( operacao );	
	if ( msgAlert != '' ) { 
		showError('inform',msgAlert,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFoco(operacao);');
	}else{
		controlaFoco(operacao);
	}	
</script>