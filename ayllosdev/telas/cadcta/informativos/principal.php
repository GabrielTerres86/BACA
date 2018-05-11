<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 19/04/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de INFORMATIVOS da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 *                11/09/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *                14/07/2016 - Correcao no carregamento de variaveis para o Javascript. SD 479874. Carlos R.
 *
 *                02/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
 */

    session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');
	require_once('../../../class/xmlfile.php');
	isPostMethod();	
	
	$cddopcao = (isset($_POST['cddopcao'])) ? $_POST['cddopcao'] : 'C';
	$flgcadas = (isset($_POST['flgcadas'])) ? $_POST['flgcadas'] : '';	

	$glbvars["nmrotina"] = (isset($_POST['nmrotina'])) ? $_POST['nmrotina'] : $glbvars["nmrotina"];
	
	$op = ( $cddopcao = 'C' ) ? '@' : $cddopcao ;
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op,false)) <> '') {
		$metodo =  ($flgcadas == 'M') ? 'proximaRotina();' : 'encerraRotina(false);';
		exibirErro('error',$msgError,'Alerta - Ayllos',$metodo,false);
	}
	
	// Verifica se o número da conta e o titular foram informados
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Parâmetros incorretos.','Alerta - Ayllos','fechaRotina(divRotina)',false);
	
	
	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');
	
	setVarSession("opcoesTela",$opcoesTela);
	
	// Carregas as opções da Rotina de Bens
	$flgIncluir  = (in_array('I', $glbvars['opcoesTela']));	
	$flgExcluir  = (in_array('E', $glbvars['opcoesTela']));	
	
	// Guardo os parâmetos do POST em variáveis
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : '';
	$idseqttl = (isset($_POST['idseqttl'])) ? $_POST['idseqttl'] : '';
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '';	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';	
	$cdrelato = (isset($_POST['cdrelato'])) ? $_POST['cdrelato'] : '';	
	$cdprogra = (isset($_POST['cdprogra'])) ? $_POST['cdprogra'] : '';	
	$cddfrenv = (isset($_POST['cddfrenv'])) ? $_POST['cddfrenv'] : '';	
	$cdperiod = (isset($_POST['cdperiod'])) ? $_POST['cdperiod'] : '';	
	
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Ayllos','fechaRotina(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl não foi informada.','Alerta - Ayllos','fechaRotina(divRotina)',false);
	
	
	if ( $operacao == 'BI' || $operacao == 'CI' ) {
		$procedure = 'busca_relatorios';
		$bo = 'b1wgen0059.p';
	}else{
		$procedure = 'busca_dados';
		$bo = 'b1wgen0064.p' ;
	}
	
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0064.p</Bo>';
	$xml .= '		<Proc>'.$procedure.'</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '       <cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';	
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';	
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
	$xml .= '		<cdrelato>'.$cdrelato.'</cdrelato>';
	$xml .= '		<cdprogra>'.$cdprogra.'</cdprogra>';
	$xml .= '		<cddfrenv>'.$cddfrenv.'</cddfrenv>';
	$xml .= '		<cdperiod>'.$cdperiod.'</cdperiod>';
	$xml .= '		<nriniseq>1</nriniseq>';
	$xml .= '		<nrregist>9999</nrregist>';
	$xml .= '	</Dados>';
	$xml .= '</Root>';	
	
	// Executa script para envio do XML
	$xmlResult = getDataXML($xml);
	
	// Cria objeto para classe de tratamento de XML
	$xmlObjeto = getObjectXML($xmlResult);
	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);',false);	
	
	// Se não retornou erro, então pegar a mensagem de alerta do Progress na variável msgAlert, para ser utilizada posteriormente
	$msgAlert = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) : '';
	
	if ( $operacao == 'BI' ){
		
		include('tabela_tipo_informativos.php');
		
	// Se estiver Incluindo, chama formulario
	} else if( in_array($operacao,array('CA','CX','CI','TC','FA','FI')) )  { 
		
		$registro = $registros[0]->tags;
		
		$cdrelato = getByTagName($registro,'cdrelato'); 
		$cddfrenv = getByTagName($registro,'cddfrenv'); 
		$cdperiod = getByTagName($registro,'cdperiod'); 
		$cdseqinc = getByTagName($registro,'cdseqinc'); 
		$cdprogra = getByTagName($registro,'cdprogra'); 
		
		include('formulario_informativos.php'); 
		
	// Se estiver consultando, chamar a tabela 
	/*} else if( in_array($operacao,array('IC','AC','FI','FA','FE','','EC')) ) { 
	
		include('tabela_informativos.php'); 
		*/
	}
?>	
<script type="text/javascript">		
	var msgAlert = '<? echo $msgAlert; ?>';
	var operacao = '<? echo $operacao; ?>';

	if (inpessoa == 1) {	
		var flgIncluir  = "<? echo $flgIncluir; ?>";
		var flgExcluir  = "<? echo $flgExcluir; ?>";
		var flgcadas    = "<? echo $flgcadas;   ?>";
	}
	
	cdrelato = '<?php echo ( isset($cdrelato) ) ? $cdrelato : ''; ?>';	
	cddfrenv = '<?php echo ( isset($cddfrenv) ) ? $cddfrenv : ''; ?>';	
	cdperiod = '<?php echo ( isset($cdperiod) ) ? $cdperiod : ''; ?>';	
	cdseqinc = '<?php echo ( isset($cdseqinc) ) ? $cdseqinc : ''; ?>';	
	cdprogra = '<?php echo ( isset($cdprogra) ) ? $cdprogra : ''; ?>';	
	
	controlaLayout(operacao);
	
	if ( msgAlert != '' ) { 
		showError('inform',msgAlert,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaFoco(operacao);');
	}else{
		controlaFoco(operacao);
	}
	if ( operacao == 'CX' ){ controlaOperacao('CE'); }
</script>
