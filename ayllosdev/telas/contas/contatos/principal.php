<?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Gabriel Capoia (DB1)
 * DATA CRIAÇÃO : 11/04/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de CONTATOS da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 *                02/09/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *                13/07/2016 - Correcao da forma de recuperacao das variaveis do array $_POST e retorno XML. SD 479874. Carlos R.
 *                01/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
 */

	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	$cddopcao = ( isset($_POST['cddopcao']) ) ? $_POST['cddopcao'] : 'C';	
	$op           = ( $cddopcao == '' ) ? '@'  : $cddopcao;	
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op)) <> '') exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);	
	
	// Verifica se o número da conta foi informado
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Parâmetros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);

	$nrdconta  = ( isset($_POST['nrdconta']) ) ? $_POST['nrdconta'] : 0;
	$idseqttl    = ( isset($_POST['idseqttl']) ) ? $_POST['idseqttl'] : 0;
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : 'CT';
	$nrdrowid  = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '';
	$nrdctato  = (isset($_POST['nrdctato'])) ? $_POST['nrdctato'] : '';
		
	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');	
	
	setVarSession("opcoesTela",$opcoesTela);
	
	$qtOpcoesTela = count($opcoesTela);

	// Carregas as opções da Rotina de Bens
	$flgAlterar   = (in_array('A', $glbvars['opcoesTela']));
	$flgConsultar = (in_array('C', $glbvars['opcoesTela']));
	$flgExcluir   = (in_array('E', $glbvars['opcoesTela']));
	$flgIncluir   = (in_array('I', $glbvars['opcoesTela']));			
		
	if ( $operacao == 'TI' ) { 
		include('formulario_contatos.php'); 
		?>
		<script type="text/javascript">
			var operacao = '<? echo $operacao; ?>';
			controlaLayoutContatos(operacao);
		</script>
		<?php
		exit(); 
	}
	
	// Retirando alguns caracteres
	$arrayRetirada = array('.','-','/','_');
	$nrdctato = str_replace($arrayRetirada,'',$nrdctato);	
	
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Aimaro','bloqueiaFundo(divRotina)');
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl inválida.','Alerta - Aimaro','bloqueiaFundo(divRotina)');	
		
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0073.p</Bo>';
	$xml .= '		<Proc>busca_dados</Proc>';
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
    $xml .= '		<nrdctato>'.$nrdctato.'</nrdctato>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);	
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){ 
		switch($operacao) {
			case 'TB': $metodo = 'bloqueiaFundo(divRotina);controlaFocoContatos(\'TB\');'; break;
			case 'TI': $metodo = 'bloqueiaFundo(divRotina);controlaFocoContatos(\'TI\');'; break;
			default  : $metodo = 'bloqueiaFundo(divRotina);'; break;
		}
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$metodo,false);
	}

	$registros = $xmlObjeto->roottag->tags[0]->tags;
	$msgAlert  = ( isset($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) ) ? trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']) : '';
	
?>
<script type="text/javascript">
	$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
</script> 
<?	
		
	// Se estiver Alterando/Incluindo/Consultando, chamar o formulario de alteracao
	if(in_array($operacao,array('TA','TI','TC','TB','TX'))) {
		$registro = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
		include('formulario_contatos.php');	
	
	// Se estiver consultando, chamar a tabela que exibe os bens
	} else if(in_array($operacao,array('CT','AT','IT','TE','FI','FA','FE',''))) {
		include('tabela_contatos.php');
	}
?>
<script type="text/javascript">
	var msgAlert     = '<? echo $msgAlert; ?>';
	var operacao     = '<? echo $operacao; ?>';
	var flgAlterar   = '<? echo $flgAlterar;   ?>';
	var flgExcluir   = '<? echo $flgExcluir;   ?>';
	var flgIncluir   = '<? echo $flgIncluir;   ?>';	
		
	controlaLayoutContatos(operacao);
	if ( msgAlert != '' ) { 
		showError('inform',msgAlert,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFocoContatos(operacao);');
	}
	if ( operacao == 'TX' ){ controlaOperacaoContatos('TE'); }
</script>