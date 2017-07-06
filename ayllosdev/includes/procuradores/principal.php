<? 
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Alexandre Scola - DB1 Informatica
 * DATA CRIAÇÃO : 09/03/2010 
 * OBJETIVO     : Mostrar opcao Principal da rotina de Representantes/procuradores da tela de CONTAS
 *
 * ALTERACOES   : 20/12/2010 - Adicionado chamada validaPermissao (Gabriel - DB1). 
 *                25/11/2011 - Se ocorrer erro no retorno da procedure busca_perc_socio, guarda a critica
 *                             para verifica-la mais tarde. (Fabricio)
 *				  04/06/2012 - Ajustes referente ao projeto GP - Sócios Menores (Adriano).
 *
 *				  04/07/2013 - Inclusão da operação de referente a poderes (Jean Michel).
 *
 *                19/02/2015 - Incluir tratamento para representante com cartão, conforme SD 251759 ( Renato - Supero )
 *
 *                04/08/2015 - Reformulacao cadastral (Gabriel-RKAM).
 *					
 *				  23/11/2016 - Ajuste realizado para remover os caracteres invalidos no momento
 *							   da exclusao do procurador. (SD 557425 Kelvin)	
 *
 *                25/04/2017 - Alterado campo dsnacion para cdnacion. (Projeto 339 - Odirlei-AMcom)
 */
?> 
<?
    session_start();
	
	require_once('../config.php');
	require_once('../funcoes.php');
	require_once('../controla_secao.php');	
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	$cddopcao_proc = $_POST['cddopcao_proc'] == '' ? 'C'  : $_POST['cddopcao_proc'];
	
	
	$op = $cddopcao_proc;
	
	// Verifica permissões de acessa a tela
	if (($msgError = validaPermissao($glbvars['nmdatela'],$glbvars['nmrotina'],$op)) <> '') exibirErro('error',$msgError,'Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
		
	// Verifica se o número da conta e o titular foram informados
	if (!isset($_POST['nrdconta']) || !isset($_POST['idseqttl']))  exibirErro('error','Par&acirc;metros incorretos.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	
	// Guardo o número da conta e titular em variáveis
	$nrdconta 	   = $_POST['nrdconta'] == ''      ? 0    : $_POST['nrdconta'];
	$idseqttl 	   = $_POST['idseqttl'] == '' 	   ? 0    : $_POST['idseqttl'];
	$nrcpfcgc_proc = $_POST['nrcpfcgc_proc'] == '' ? 0    : $_POST['nrcpfcgc_proc'];
	$nrdctato 	   = $_POST['nrdctato'] == ''      ? 0    : $_POST['nrdctato'];	
	$nrdrowid 	   = $_POST['nrdrowid'] == ''      ? 0    : $_POST['nrdrowid'];	
	$operacao_proc = $_POST['operacao_proc'] == '' ? 'CT' : $_POST['operacao_proc'];
	$nmdatela      = $_POST['nmdatela'] == ''      ? ''   : $_POST['nmdatela'];
	$nmrotina      = $_POST['nmrotina'] == ''      ? ''   : $_POST['nmrotina'];
	$aux_operacao  = $_POST['aux_operacao'] == ''  ? ''   : $_POST['aux_operacao'];
	$flgcadas      = (!isset($_POST['flgcadas'])) ? ''    : $_POST['flgcadas'];		

	// Verifica se o número da conta e o titular são inteiros válidos
	if (!validaInteiro($nrdconta)) exibirErro('error','Conta/dv inv&aacute;lida.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
	if (!validaInteiro($idseqttl)) exibirErro('error','Seq.Ttl n&atilde;o foi informada.','Alerta - Ayllos','bloqueiaFundo(divRotina)',false);
		
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
	$xml .= '		<idseqttl>0</idseqttl>';
	$xml .= '		<nrcpfcgc>'.$nrcpfcgc_proc.'</nrcpfcgc>';	
	$xml .= '		<cddopcao>'.$cddopcao_proc.'</cddopcao>';	
	$xml .= '		<nrdctato>'.$nrdctato.'</nrdctato>';	
	$xml .= '		<nrdrowid>'.$nrdrowid.'</nrdrowid>';	
	$xml .= '	</Dados>';
	$xml .= '</Root>';	

	$xmlResult = getDataXML($xml);
	$xmlObjeto = getObjectXML(removeCaracteresInvalidos($xmlResult));	
	$registros = $xmlObjeto->roottag->tags[0]->tags;	
			
	// Se ocorrer um erro, mostra crítica
	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {

		if ( $operacao_proc == 'IB' ) { 
			$metodo = 'bloqueiaFundo(divRotina);controlaOperacaoProc(\'TI\');';
		} else {
			$metodo = 'bloqueiaFundo(divRotina);controlaOperacaoProc();';
		}		
		
		exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos',$metodo,false);
		
	}
	
	$estadoCivil = getByTagName($registros[0]->tags,'cdestcvl');
	$dsProfissao = getByTagName($registros[0]->tags,'dsproftl');
	
	if ( $nrcpfcgc_proc != '' || $nrdctato != '' ) {

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
		$xmlBens .= '		<idseqttl>0</idseqttl>';
		$xmlBens .= '		<nrcpfcgc>'.$nrcpfcgc_proc.'</nrcpfcgc>';
		$xmlBens .= '		<nrdctato>'.$nrdctato.'</nrdctato>';	
		$xmlBens .= '	</Dados>';
		$xmlBens .= '</Root>';	
		
		$xmlResultBens 	= getDataXML($xmlBens);		
		$xmlObjetoBens 	= getObjectXML(removeCaracteresInvalidos($xmlResultBens));		
		$regBens 		= $xmlObjetoBens->roottag->tags[0]->tags;		
		
		// Se ocorrer um erro, mostra crítica
		if (strtoupper($xmlObjetoBens->roottag->tags[0]->name) == 'ERRO') exibirErro('error',$xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata,'Alerta - Ayllos','bloqueiaFundo(divRotina);controlaOperacaoProc()',false);	
		
		?>
		<script type="text/javascript">

		arrayBens = new Array();
				
		<?for($i=0; $i<count($regBens); $i++) {?>		
		
			var arrayBem<? echo $i; ?> = new Object();
			
			arrayBem<? echo $i; ?>['dsrelbem'] = '<? echo getByTagName($regBens[$i]->tags,'dsrelbem'); ?>';
			arrayBem<? echo $i; ?>['cdsequen'] = '<? echo getByTagName($regBens[$i]->tags,'cdsequen'); ?>';
			arrayBem<? echo $i; ?>['persemon'] = '<? echo getByTagName($regBens[$i]->tags,'persemon'); ?>';
			arrayBem<? echo $i; ?>['qtprebem'] = '<? echo getByTagName($regBens[$i]->tags,'qtprebem'); ?>';
			arrayBem<? echo $i; ?>['vlprebem'] = '<? echo getByTagName($regBens[$i]->tags,'vlprebem'); ?>';
			arrayBem<? echo $i; ?>['vlrdobem'] = '<? echo getByTagName($regBens[$i]->tags,'vlrdobem'); ?>';	
			arrayBem<? echo $i; ?>['nrdrowid'] = '<? echo getByTagName($regBens[$i]->tags,'nrdrowid'); ?>';			
			arrayBem<? echo $i; ?>['cpfdoben'] = '<? echo getByTagName($regBens[$i]->tags,'cpfdoben'); ?>';			
			arrayBem<? echo $i; ?>['deletado'] = '<? echo getByTagName($regBens[$i]->tags,'deletado'); ?>';		
			arrayBem<? echo $i; ?>['cddopcao'] = '<? echo getByTagName($regBens[$i]->tags,'cddopcao'); ?>';	
			arrayBens[<? echo $i; ?>] = arrayBem<? echo $i; ?>;
						
		<?}?>
		</script>
		
		<?
	}

	// Monta o xml de requisição
	$xmlPerSocio  = '';
	$xmlPerSocio .= '<Root>';
	$xmlPerSocio .= '	<Cabecalho>';
	$xmlPerSocio .= '		<Bo>b1wgen0058.p</Bo>';
	$xmlPerSocio .= '		<Proc>busca_perc_socio</Proc>';
	$xmlPerSocio .= '	</Cabecalho>';
	$xmlPerSocio .= '	<Dados>';
	$xmlPerSocio .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
	$xmlPerSocio .= '		<dsproftl>'.$dsProfissao.'</dsproftl>';
	$xmlPerSocio .= '		<persocio>'.getByTagName($registros[0]->tags,'persocio').'</persocio>';
	$xmlPerSocio .= '	</Dados>';
	$xmlPerSocio .= '</Root>';	

	$xmlResult = getDataXML($xmlPerSocio);
	$xmlObjeto = getObjectXML(removeCaracteresInvalidos($xmlResult));	

	$dscritic = "";	

	if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO')
		$dscritic = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;
					
	$vlpersocio = $xmlObjeto->roottag->tags[0]->attributes["PERSOCIO"];			
	
	if($nmrotina == "MATRIC"  && 
	   $idseqttl == 2         && 
	   $operacao_proc != "CT" &&
	   $operacao_proc != "I"  &&
	   $operacao_proc != "IB"){
		
		?>
		<script type="text/javascript">
			sincronizaArrayProc();
			carregaDadosProc();				
		</script>  
		
		<?
	
	}else{
			
		$frm_nrdconta = getByTagName($registros[0]->tags,'nrdconta');
		$frm_nrdctato = getByTagName($registros[0]->tags,'nrdctato');
		$frm_nrcpfcgc = getByTagName($registros[0]->tags,'nrcpfcgc');
		$frm_nmdavali = getByTagName($registros[0]->tags,'nmdavali');
		$frm_dtnascto = getByTagName($registros[0]->tags,'dtnascto');
		$frm_inhabmen = getByTagName($registros[0]->tags,'inhabmen');
		$frm_dthabmen = getByTagName($registros[0]->tags,'dthabmen');
		$frm_tpdocava = getByTagName($registros[0]->tags,'tpdocava');
		$frm_nrdocava = getByTagName($registros[0]->tags,'nrdocava');
		$frm_cdoeddoc = getByTagName($registros[0]->tags,'cdoeddoc');
		$frm_cdufddoc = getByTagName($registros[0]->tags,'cdufddoc');
		$frm_dtemddoc = getByTagName($registros[0]->tags,'dtemddoc');
		$frm_cdestcvl = getByTagName($registros[0]->tags,'cdestcvl');
		$frm_cdsexcto = getByTagName($registros[0]->tags,'cdsexcto');
		$frm_dsnacion = getByTagName($registros[0]->tags,'dsnacion');
        $frm_cdnacion = getByTagName($registros[0]->tags,'cdnacion');
		$frm_dsnatura = getByTagName($registros[0]->tags,'dsnatura');
		$frm_nrcepend = getByTagName($registros[0]->tags,'nrcepend');
		$frm_dsendres = getByTagName($registros[0]->tags[30]->tags,'dsendres.1');
		$frm_nrendere = getByTagName($registros[0]->tags,'nrendere');
		$frm_complend = getByTagName($registros[0]->tags,'complend');
		$frm_nrcxapst = getByTagName($registros[0]->tags,'nrcxapst'); 
		$frm_nmbairro = getByTagName($registros[0]->tags,'nmbairro');
		$frm_cdufresd = getByTagName($registros[0]->tags,'cdufresd');
		$frm_nmcidade = getByTagName($registros[0]->tags,'nmcidade');
		$frm_nmmaecto = getByTagName($registros[0]->tags,'nmmaecto');
		$frm_nmpaicto = getByTagName($registros[0]->tags,'nmpaicto');
		$frm_vledvmto = getByTagName($registros[0]->tags,'vledvmto');
		$frm_dsrelbem = $registros[0]->tags[51]->tags[0]->cdata;
		$frm_dtvalida = getByTagName($registros[0]->tags,'dtvalida');
		$frm_dsproftl = getByTagName($registros[0]->tags,'dsproftl');
		$frm_dtadmsoc = getByTagName($registros[0]->tags,'dtadmsoc');
		$frm_persocio = getByTagName($registros[0]->tags,'persocio');
		$frm_flgdepec = getByTagName($registros[0]->tags,'flgdepec');
		$frm_vloutren = getByTagName($registros[0]->tags,'vloutren');
		$frm_dsoutren = getByTagName($registros[0]->tags,'dsoutren');
		$frm_nrctremp = getByTagName($registros[0]->tags,'nrctremp');
		$frm_fltemcrd = getByTagName($registros[0]->tags,'fltemcrd');
		
		$estadoCivil = $frm_cdestcvl;
		$dsProfissao = $frm_dsproftl;
	    
		?>
		<script type="text/javascript">
			
			if( '<? echo $operacao_proc;?>' ==  'IB'){
							
				nrctremp = ('<? echo $frm_nrdctato;?>' != '') ? '<? echo $frm_nrctremp;?>' : 0;
				
			}
			
		</script>  
		
		<?
	}
	
?>

<script type="text/javascript">
	
	$('#divConteudoOpcao').css({'-moz-opacity':'0','filter':'alpha(opacity=0)','opacity':'0'});
			
</script>  
 
<?
	
	// Se estiver alterando, chamar o formulario de alteracao
	if ( $operacao_proc != 'CT'  && $operacao_proc != 'P') {
		include('formulario_procuradores.php');			
		
	// Se estiver consultando, chamar a tabela que exibe os Representantes/ Procuradores
	}else if($operacao_proc == 'P'){
		include('poderes.php');
	}else if( ($operacao_proc == 'CT' ) ) {
			include('tabela_procuradores.php');
		
	}	
	
		
?>	
<script type="text/javascript">
	
	var ope 	  = '<? echo $operacao_proc;?>';
	var dscritica = '<? echo $dscritic;    ?>';
	var dtmvtolt  = '<? echo $glbvars["dtmvtolt"]; ?>';
	
	if(nmrotina == "MATRIC" 				&& 
	   idseqttl == 2        				&& 
	   '<? echo $operacao_proc; ?>' != "CT" &&
	   '<? echo $operacao_proc; ?>' != "I"  &&
	   '<? echo $operacao_proc; ?>' != "IB"){
	   
		var estadoCivil = arrayFilhosAvtMatric[indarray_proc]['cdestcvl'];
		var dsProfissao = arrayFilhosAvtMatric[indarray_proc]['dsproftl'];
		var vlpercsocio = arrayFilhosAvtMatric[indarray_proc]['persocio'];
		
		nrdeanos_proc = arrayFilhosAvtMatric[indarray_proc]['nrdeanos'];
		
	}else{
		var estadoCivil = '<? echo $estadoCivil; ?>';
		var dsProfissao = '<? echo $dsProfissao; ?>';
		var vlpercsocio = '<? echo $vlpersocio;  ?>';
		
		nrdeanos_proc = '<? echo getByTagName($registros[0]->tags,'nrdeanos'); ?>';
		
	}
	
	// Quando cpf é digitado na inclusão, e cpf não esta cadastrodo no sistema, então
	// salvo o cpf digitado e atribuo no esse valor novamente ao campo apos a busca
	if ( ope == 'IB' && $('#nrcpfcgc','#frmDadosProcuradores').val()=='' ) {
		$('#nrcpfcgc','#frmDadosProcuradores').val(cpfaux);
	}
	
	// Controla o layout da tela
	controlaLayoutProc( ope );
						
	if ( ope == 'TX'){	
		if( '<? echo $nmrotina; ?>' == 'MATRIC' &&
			'<? echo $idseqttl; ?>' == 2){
				showConfirmacao('Deseja confirmar exclus&atilde;o?','Confirma&ccedil;&atilde;o - Ayllos','controlaArrayProc(\'EV\');','bloqueiaFundo(divRotina); controlaOperacaoProc();','sim.gif','nao.gif');		
			}else{
				controlaOperacaoProc('EV'); 
			}
	}
	
</script>
