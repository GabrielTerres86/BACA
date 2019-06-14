<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 28/04/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de REFERÊNCIAS da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 *
 *                05/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
 * 
 *                02/12/2016 - P341-Automatização BACENJUD - Removido passagem do departamento como parametros
 *                             pois a BO não utiliza o mesmo (Renato Darosci)
 */
?>
<?
	session_start();
	require_once('../../../includes/config.php');
	require_once('../../../includes/funcoes.php');
	require_once('../../../includes/controla_secao.php');	
	require_once('../../../class/xmlfile.php');
	isPostMethod();		
	
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '';
	
	// Dependendo da operação, chamo uma procedure diferente
	$procedure = '';
	switch($operacao) {
		case 'CA': 
			$procedure = 'consultar-dados-contato'; 
			$cddopcao  = 'A';	
			break;
		case 'CC': 
			$procedure = 'consultar-dados-contato'; 
			$cddopcao  = 'C';	
			break;		
		case 'TE': 
			$procedure = 'consultar-dados-contato'; 
			$cddopcao  = 'E';	
			break;			
		case 'CB': 
			$procedure = 'consultar-dados-cooperado-contato'; 
			$cddopcao  = 'C';	
			break;		
		default:
			$procedure = 'obtem-contatos'; 
			$cddopcao  = '';	
			break;
	}
	
	$op = ( $cddopcao == '' ) ? 'C' : $cddopcao ; 
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op)) <> '') exibirErro('error',$msgError,'Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl'])) exibirErro('error','Parâmetros incorretos.','Alerta - Aimaro','fechaRotina(divRotina);',false);

	$nrdconta = $_POST['nrdconta'] == ''? 0 : $_POST['nrdconta'];
	$idseqttl = $_POST['idseqttl'] == ''? 0 : $_POST['idseqttl'];	
	$nrdrowid = (isset($_POST['nrdrowid'])) ? $_POST['nrdrowid'] : '';
	$nrdctato = (isset($_POST['nrdctato'])) ? $_POST['nrdctato'] : '';
	$flgcadas = (!isset($_POST['flgcadas'])) ? '' : $_POST['flgcadas'];
	
	// Retirando alguns caracteres
	$arrayRetirada = array('.','-','/','_');
	$nrdctato = str_replace($arrayRetirada,'',$nrdctato);	
	
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inválida.','Alerta - Aimaro','fechaRotina(divRotina);',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl inválida.','Alerta - Aimaro','fechaRotina(divRotina);',false);
			
	if ( $operacao == 'CI' ) { 
		include('formulario_referencias.php'); 
		?>
		<script type="text/javascript">
			var operacao = '<? echo $operacao; ?>';
			controlaLayout(operacao);
		</script>
		<?
		exit(); 
	}
	
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0049.p</Bo>';
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
    $xml .= '		<nrdctato>'.$nrdctato.'</nrdctato>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';
	
	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);	
	
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == "ERRO"){ 
		if( $cddopcao == 'I' ){
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
		}else if ( $operacao == 'CC' || $operacao == '' ){
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','fechaRotina(divRotina);',false);
		}else{
			exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);',false);
		}
	}
	
	$registros = $xmlObjeto->roottag->tags[0]->tags;
	$msgAlert  = trim($xmlObjeto->roottag->tags[0]->attributes['MSGALERT']);		
?>
<script type="text/javascript">
	$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
</script> 
<?	
	// Se estiver Alterando/Incluindo/Consultando, chamar o formulario de alteracao
	if(in_array($operacao,array('CI','CA','CC','CB','TE'))) {
		$registro = $xmlObjeto->roottag->tags[0]->tags[0]->tags;
		include('formulario_referencias.php');	
	
	// Se estiver consultando, chamar a tabela que exibe os bens
	} else if(in_array($operacao,array('AC','IC','FI','FA','FE','CE',''))) {
		include('tabela_referencias.php');
	}
?>
<script type="text/javascript">
	var msgAlert = '<? echo $msgAlert; ?>';
	var operacao = '<? echo $operacao; ?>';
		
	controlaLayout(operacao);
	if ( msgAlert != '' ) { 
		showError('inform',msgAlert,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaFoco(operacao);');
	}
	if ( operacao == 'TE' ){ controlaOperacao('CE'); }
</script>