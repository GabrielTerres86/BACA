 <?php
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Gabriel Capoia - DB1 Informatica
 * DATA CRIAÇÃO : 15/09/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de Representantes/procuradores (Pessoa Física)
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 *							 22/07/2010 - Adicionado a opção de poderes (Jean Michel). 
 *                           03/09/2015 - Reformulacao cadastral (Gabriel-RKAM).
 * 					         13/07/2016 - Correcao da forma de recuperacao das variaveis do array $_POST.SD 479874. Carlos R.
 *							 15/02/2018 - Ajustado problema que não deixava a tela de poderes abrir pois
 *										  havia um FIND retorando mais de um registro. Para solucionar
 *  						              fiz o filtro com a chave correta. (SD 841137 - Kelvin).
 *
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
		
	// Verifica se o número da conta e o titular foram informados
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl']))  exibirErro('error','Par&acirc;metros incorretos.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	
	// Guardo o número da conta e titular em variáveis
	$nrdconta  = ( isset($_POST['nrdconta']) ) ? $_POST['nrdconta'] : 0;
	$idseqttl    = ( isset($_POST['idseqttl']) )   ? $_POST['idseqttl']   : 0;
	$nrcpfcgc  = ( isset($_POST['nrcpfcgc']) )  ? $_POST['nrcpfcgc'] : 0;
	$nrdctato  = ( isset($_POST['nrdctato']) )	 ?  $_POST['nrdctato'] : 0;
	$nrdrowid  = ( isset($_POST['nrdrowid']) )  ?  $_POST['nrdrowid'] : 0;
	$operacao = ( isset($_POST['operacao']) ) ?  $_POST['operacao'] : 'CT';	
		
	// Carrega permissões do operador
	include('../../../includes/carrega_permissoes.php');	
	
	setVarSession("opcoesTela",$opcoesTela);
	
	$flgAlterar   = (in_array('A', $glbvars['opcoesTela']));
	$flgIncluir   = (in_array('I', $glbvars['opcoesTela']));
	$flgExcluir   = (in_array('E', $glbvars['opcoesTela']));
	$flgPoderes   = (in_array('P', $glbvars['opcoesTela']));
		
	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl n&atilde;o foi informada.','Alerta - Aimaro','bloqueiaFundo(divRotina)',false);
		
	// Monta o xml de requisição
	$xml  = '';
	$xml .= '<Root>';
	$xml .= '	<Cabecalho>';
	$xml .= '		<Bo>b1wgen0058.p</Bo>';
	$xml .= '		<Proc>busca_dados</Proc>';
	$xml .= '	</Cabecalho>';
	$xml .= '	<Dados>';
	$xml .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xml .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
	$xml .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
	$xml .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
	$xml .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
	$xml .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
	$xml .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
	$xml .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
	$xml .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';	
	$xml .= '		<cddopcao>'.$cddopcao.'</cddopcao>';	
	$xml .= '		<nrdctato>'.$nrdctato.'</nrdctato>';	
	$xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';	

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML($xmlResult);	
	$registros = $xmlObjeto->roottag->tags[0]->tags;	
				
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {
		if ( $operacao == 'IB' ) { 
			$metodo = 'bloqueiaFundo(divRotina);controlaOperacaoProcuradores(\'TI\');';
		} else {
			$metodo = 'bloqueiaFundo(divRotina);controlaOperacaoProcuradores();';
		}		
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro',$metodo,false);
	}
	
	$estadoCivil = ( isset($registros[0]->tags) ) ? getByTagName($registros[0]->tags,'cdestcvl') : '';
		
	if ( ($nrcpfcgc != '') || ($nrdctato != '') ) {	
		// Monta o xml de requisição
		$xmlBens  = '';
		$xmlBens .= '<Root>';
		$xmlBens .= '	<Cabecalho>';
		$xmlBens .= '		<Bo>b1wgen0058.p</Bo>';
		$xmlBens .= '		<Proc>busca_dados_bens</Proc>';
		$xmlBens .= '	</Cabecalho>';
		$xmlBens .= '	<Dados>';
		$xmlBens .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
		$xmlBens .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
		$xmlBens .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
		$xmlBens .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
		$xmlBens .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
		$xmlBens .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
		$xmlBens .= '		<idseqttl>'.$idseqttl.'</idseqttl>';
		$xmlBens .= '		<nrcpfcgc>'.$nrcpfcgc.'</nrcpfcgc>';
		$xmlBens .= '		<nrdctato>'.$nrdctato.'</nrdctato>';	
		$xmlBens .= '	</Dados>';
		$xmlBens .= '</Root>';	
		
		$xmlResultBens 	= getDataXML($xmlBens);		
		$xmlObjetoBens 	= getObjectXML($xmlResultBens);		
		$regBens 		= $xmlObjetoBens->roottag->tags[0]->tags;		
		
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjetoBens->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Aimaro','bloqueiaFundo(divRotina);controlaOperacaoProcuradores()',false);	
		
		$controle = true;
	}
	
	// Se estiver alterando, chamar o formulario de alteracao
	if ( $operacao != 'CT' && $operacao != 'P') {
		include('formulario_procuradores.php');
	// Se estiver consultando, chamar a tabela que exibe os Representantes/ Procuradores
	} else if ( $operacao == 'CT' ) {
		include('tabela_procuradores.php');
	}else if ( $operacao == 'P' ) {
		include('../../../includes/procuradores/poderes.php');
	}	

	if($controle){ ?>

		<script type="text/javascript">
		
		arrayBens = new Array();
				
		<?for($i=0; $i<count($regBens); $i++) {
			?>		
			var arrayBem<? echo $i; ?> = new Object();
			arrayBem<? echo $i; ?>['dsrelbem'] = '<? echo getByTagName($regBens[$i]->tags,'dsrelbem'); ?>';
			arrayBem<? echo $i; ?>['cdsequen'] = '<? echo getByTagName($regBens[$i]->tags,'cdsequen'); ?>';
			arrayBem<? echo $i; ?>['persemon'] = '<? echo getByTagName($regBens[$i]->tags,'persemon'); ?>';
			arrayBem<? echo $i; ?>['qtprebem'] = '<? echo getByTagName($regBens[$i]->tags,'qtprebem'); ?>';
			arrayBem<? echo $i; ?>['vlprebem'] = '<? echo getByTagName($regBens[$i]->tags,'vlprebem'); ?>';
			arrayBem<? echo $i; ?>['vlrdobem'] = '<? echo getByTagName($regBens[$i]->tags,'vlrdobem'); ?>';
			arrayBens[<? echo $i; ?>] = arrayBem<? echo $i; ?>;
			<?
				}?>
</script>  
 
	<?}?>

<script type="text/javascript">
	
	$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
	
	var operacao 	= '<? echo $operacao;    ?>';
	var estadoCivil = '<? echo $estadoCivil; ?>';
	var dsProfissao = '<? echo ( isset($dsProfissao) ) ? $dsProfissao : ''; ?>';
	var dtmvtolt    = '<? echo $glbvars["dtmvtolt"]; ?>';
	
	// Declara os flags para as opções da Rotina de Procuradores
	var flgAlterar   = "<? echo $flgAlterar;   ?>";	
	var flgIncluir   = "<? echo $flgIncluir;   ?>";	
	var flgExcluir   = "<? echo $flgExcluir;   ?>";	
	var flgPoderes 	 = "<? echo $flgPoderes;   ?>";
			
	// Quando cpf é digitado na inclusão, e cpf não esta cadastrodo no sistema, então
	// salvo o cpf digitado e atribuo no esse valor novamente ao campo apos a busca
	if ( operacao == 'IB' && $('#nrcpfcgc','#frmDadosProcuradores').val()=='' ) {
		$('#nrcpfcgc','#frmDadosProcuradores').val(cpfaux);
	}
	
	// Controla o layout da tela
	controlaLayoutProcuradores( operacao );
	if ( operacao == 'TX'){	controlaOperacaoProcuradores("EV");}
	
</script>