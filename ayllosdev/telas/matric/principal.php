<?
/*!
 * FONTE        : principal.php
 * CRIAÇÃO      : Rodolpho Telmo (DB1)
 * DATA CRIAÇÃO : 07/06/2010
 * OBJETIVO     : Capturar dados para tela MATRIC
 * --------------
 * ALTERAÇÕES   :
 * 001: [14/02/2011] David   (CECRED): Não acionar BO quando operação for limpeza da tela ($operacao = '')
 * 002: [09/06/2012] Adriano (CECRED): Ajustes referente ao projeto GP - Sócios Menores
 * 003: [28/01/2015] Carlos  (CECRED): #239097 Ajustes para cadastro de Resp. legal 0 menor/maior.
 * 004: [09/07/2015] Gabriel (RKAM)  : Projeto Reformulacao Cadastral.
 * 005: [01/10/2015] Kelvin  (CECRED): Adicionado nova opção "J" para alteração apenas do cpf/cnpj e removido 
									   a possibilidade de alteração pela opção "X", conforme solicitado no 
							           chamado 321572.
 * -------------- 
 */ 
?>

<?	
	session_start();	
	require_once('../../includes/config.php');
	require_once('../../includes/funcoes.php');		
	require_once('../../includes/controla_secao.php');
	require_once('../../class/xmlfile.php');
	isPostMethod();		
	
	// Carrega permissões do operador
	require_once('../../includes/carrega_permissoes.php');		
	
	setVarSession("rotinasTela",$rotinasTela);
	$glbvars['opcoesTela' ] = $opcoesTela;
	
	// Carregas as opções da Rotina de Bens	
	$flgAlterar		= (in_array('A', $glbvars['opcoesTela']));
	$flgConsultar	= (in_array('C', $glbvars['opcoesTela']));	
	$flgIncluir		= (in_array('I', $glbvars['opcoesTela']));
	$flgRelatorio	= (in_array('R', $glbvars['opcoesTela']));
	$flgNome		= (in_array('X', $glbvars['opcoesTela']));
	$flgDesvincula	= (in_array('D', $glbvars['opcoesTela']));	
	$flgCpfCnpj		= (in_array('J', $glbvars['opcoesTela']));	
	
	$nrdconta = (isset($_POST['nrdconta'])) ? $_POST['nrdconta'] : 0  ;
	$operacao = (isset($_POST['operacao'])) ? $_POST['operacao'] : '' ;
	
		
	switch($operacao) {
	
		case ''  : $cddopcao = 'C'; break;
		case 'FC': $cddopcao = 'C'; break;	
		case 'CI': $cddopcao = 'I'; break;			
		case 'CA': $cddopcao = 'A'; break;
		case 'CD': $cddopcao = 'D'; break;		
		case 'CR': $cddopcao = 'R'; break;
		case 'CX': $cddopcao = 'X'; break;
		case 'CJ': $cddopcao = 'J'; break;
		default  : $cddopcao = 'C'; break;
		
	}

	
	// Se conta informada não for um número inteiro válido
	if (!validaInteiro($nrdconta) && $operacao != 'CI') exibirErro('error','Conta/dv inválida.','Alerta - Matric','',false);
	
	if ($operacao != '') {
		// Monta o xml de requisição
		$xmlMatric  = '';
		$xmlMatric .= '<Root>';
		$xmlMatric .= '	<Cabecalho>';
		$xmlMatric .= '		<Bo>b1wgen0052.p</Bo>';
		$xmlMatric .= '		<Proc>busca_dados</Proc>';
		$xmlMatric .= '	</Cabecalho>';
		$xmlMatric .= '	<Dados>';
		$xmlMatric .= '		<cdcooper>'.$glbvars['cdcooper'].'</cdcooper>';
		$xmlMatric .= '		<cdagenci>'.$glbvars['cdagenci'].'</cdagenci>';
		$xmlMatric .= '		<nrdcaixa>'.$glbvars['nrdcaixa'].'</nrdcaixa>';
		$xmlMatric .= '		<cdoperad>'.$glbvars['cdoperad'].'</cdoperad>';
		$xmlMatric .= '		<nmdatela>'.$glbvars['nmdatela'].'</nmdatela>';
		$xmlMatric .= '		<idorigem>'.$glbvars['idorigem'].'</idorigem>';
		$xmlMatric .= '		<dsdepart>'.$glbvars['dsdepart'].'</dsdepart>';		
		$xmlMatric .= '		<nrdconta>'.$nrdconta.'</nrdconta>';
		$xmlMatric .= '		<cddopcao>'.$cddopcao.'</cddopcao>';
		$xmlMatric .= '		<idseqttl>1</idseqttl>';
		$xmlMatric .= '	</Dados>';
		$xmlMatric .= '</Root>';
		
		// Executa script para envio do XML e cria objeto para classe de tratamento de XML
		$xmlResult 	= getDataXML($xmlMatric);
		$xmlObjeto 	= getObjectXML($xmlResult);		

		// Se ocorrer um erro, mostra mensagem
		if (strtoupper($xmlObjeto->roottag->tags[0]->name) == 'ERRO') {	
			$operacao = '';
			$msgErro  = $xmlObjeto->roottag->tags[0]->tags[0]->tags[4]->cdata;			
			$mtdErro  = "showMsgAguardo( 'Aguarde, carregando ...' );setTimeout('estadoInicial()',1);";		
			exibirErro('error',$msgErro,'Alerta - Matric',$mtdErro,false);
		} 
		
		$registro	  = $xmlObjeto->roottag->tags[0]->tags[0]->tags;	
		$operadoras	  = $xmlObjeto->roottag->tags[1]->tags;
		$regFilhos 	  = $xmlObjeto->roottag->tags[2]->tags;
		$bens		  = $xmlObjeto->roottag->tags[3]->tags;
		$alertas      = $xmlObjeto->roottag->tags[4]->tags;
		$responsaveis = $xmlObjeto->roottag->tags[5]->tags;
		$tpPessoa	  = ( getByTagName($registro,'inpessoa') == '' ) ? 1 : getByTagName($registro,'inpessoa');	
		
		$msg = Array();
		
		foreach( $alertas as $alerta){
			$msg[getByTagName($alerta->tags,'cdalerta')] = getByTagName($alerta->tags,'dsalerta');
		}
		
		$strMsg = implode( "|", $msg);
				
		// Monta o array dos itens
		?>
		<script type="text/javascript">
		
			arrayFilhosAvtMatric = new Array();
			
			<? for($i=0; $i<count($regFilhos); $i++) { ?>	
			
				var regFilhoavt<? echo $i; ?> = new Object();
								
				regFilhoavt<? echo $i; ?>['nrdctato'] = '<? echo getByTagName($regFilhos[$i]->tags,'nrdctato'); ?>';
				regFilhoavt<? echo $i; ?>['cddctato'] = '<? echo getByTagName($regFilhos[$i]->tags,'cddctato'); ?>';
				regFilhoavt<? echo $i; ?>['nmdavali'] = '<? echo getByTagName($regFilhos[$i]->tags,'nmdavali'); ?>';
				regFilhoavt<? echo $i; ?>['tpdocava'] = '<? echo getByTagName($regFilhos[$i]->tags,'tpdocava'); ?>';
				regFilhoavt<? echo $i; ?>['nrdocava'] = '<? echo getByTagName($regFilhos[$i]->tags,'nrdocava'); ?>';
				regFilhoavt<? echo $i; ?>['cdoeddoc'] = '<? echo getByTagName($regFilhos[$i]->tags,'cdoeddoc'); ?>';				
				regFilhoavt<? echo $i; ?>['cdufddoc'] = '<? echo getByTagName($regFilhos[$i]->tags,'cdufddoc'); ?>';				
				regFilhoavt<? echo $i; ?>['dtemddoc'] = '<? echo getByTagName($regFilhos[$i]->tags,'dtemddoc'); ?>';				
				regFilhoavt<? echo $i; ?>['dsproftl'] = '<? echo getByTagName($regFilhos[$i]->tags,'dsproftl'); ?>';				
				regFilhoavt<? echo $i; ?>['nrcpfcgc'] = '<? echo getByTagName($regFilhos[$i]->tags,'nrcpfcgc'); ?>';
				regFilhoavt<? echo $i; ?>['cdcpfcgc'] = '<? echo getByTagName($regFilhos[$i]->tags,'cdcpfcgc'); ?>';
				regFilhoavt<? echo $i; ?>['dtvalida'] = '<? echo getByTagName($regFilhos[$i]->tags,'dtvalida'); ?>';				
				regFilhoavt<? echo $i; ?>['nrdrowid'] = '<? echo getByTagName($regFilhos[$i]->tags,'nrdrowid'); ?>';			
				regFilhoavt<? echo $i; ?>['rowidavt'] = '<? echo getByTagName($regFilhos[$i]->tags,'rowidavt'); ?>';			
				regFilhoavt<? echo $i; ?>['dsvalida'] = '<? if(getByTagName($regFilhos[$i]->tags,'dsvalida') == "12/31/9999"){
														   echo "INDETERMI.";
													     }else{
															echo getByTagName($regFilhos[$i]->tags,'dsvalida');
														 }  ?>';		
				regFilhoavt<? echo $i; ?>['dtnascto'] = '<? echo getByTagName($regFilhos[$i]->tags,'dtnascto'); ?>';
				regFilhoavt<? echo $i; ?>['cdsexcto'] = '<? echo getByTagName($regFilhos[$i]->tags,'cdsexcto'); ?>';
				regFilhoavt<? echo $i; ?>['cdestcvl'] = '<? echo getByTagName($regFilhos[$i]->tags,'cdestcvl'); ?>';
				regFilhoavt<? echo $i; ?>['dsestcvl'] = '<? echo getByTagName($regFilhos[$i]->tags,'dsestcvl'); ?>';
				regFilhoavt<? echo $i; ?>['nrdeanos'] = '<? echo getByTagName($regFilhos[$i]->tags,'nrdeanos'); ?>';
				regFilhoavt<? echo $i; ?>['dsnacion'] = '<? echo getByTagName($regFilhos[$i]->tags,'dsnacion'); ?>';
				regFilhoavt<? echo $i; ?>['dsnatura'] = '<? echo getByTagName($regFilhos[$i]->tags,'dsnatura'); ?>';				
				regFilhoavt<? echo $i; ?>['nmmaecto'] = '<? echo getByTagName($regFilhos[$i]->tags,'nmmaecto'); ?>';
				regFilhoavt<? echo $i; ?>['nmpaicto'] = '<? echo getByTagName($regFilhos[$i]->tags,'nmpaicto'); ?>';
				regFilhoavt<? echo $i; ?>['nrcepend'] = '<? echo getByTagName($regFilhos[$i]->tags,'nrcepend'); ?>';
				regFilhoavt<? echo $i; ?>['dsendres.1'] = '<? echo getByTagName($regFilhos[$i]->tags[30]->tags,'dsendres.1'); ?>';
				regFilhoavt<? echo $i; ?>['dsendres.2'] = '<? echo getByTagName($regFilhos[$i]->tags[30]->tags,'dsendres.2'); ?>';
				regFilhoavt<? echo $i; ?>['nrendere'] = '<? echo getByTagName($regFilhos[$i]->tags,'nrendere'); ?>';
				regFilhoavt<? echo $i; ?>['complend'] = '<? echo getByTagName($regFilhos[$i]->tags,'complend'); ?>';
				regFilhoavt<? echo $i; ?>['nmbairro'] = '<? echo getByTagName($regFilhos[$i]->tags,'nmbairro'); ?>';
				regFilhoavt<? echo $i; ?>['nmcidade'] = '<? echo getByTagName($regFilhos[$i]->tags,'nmcidade'); ?>';
				regFilhoavt<? echo $i; ?>['cdufresd'] = '<? echo getByTagName($regFilhos[$i]->tags,'cdufresd'); ?>';
			    regFilhoavt<? echo $i; ?>['dsdrendi.1'] = '<? echo getByTagName($regFilhos[$i]->tags[5]->tags,'dsdrendi.1'); ?>';
			    regFilhoavt<? echo $i; ?>['dsdrendi.2'] = '<? echo getByTagName($regFilhos[$i]->tags[5]->tags,'dsdrendi.2'); ?>';
			    regFilhoavt<? echo $i; ?>['dsdrendi.3'] = '<? echo getByTagName($regFilhos[$i]->tags[5]->tags,'dsdrendi.3'); ?>';
			    regFilhoavt<? echo $i; ?>['dsdrendi.4'] = '<? echo getByTagName($regFilhos[$i]->tags[5]->tags,'dsdrendi.4'); ?>';
			    regFilhoavt<? echo $i; ?>['dsdrendi.5'] = '<? echo getByTagName($regFilhos[$i]->tags[5]->tags,'dsdrendi.5'); ?>';
			    regFilhoavt<? echo $i; ?>['dsdrendi.6'] = '<? echo getByTagName($regFilhos[$i]->tags[5]->tags,'dsdrendi.6'); ?>';
			    regFilhoavt<? echo $i; ?>['dsrelbem.1'] = '<? echo getByTagName($regFilhos[$i]->tags[51]->tags,'dsrelbem.1'); ?>';
				regFilhoavt<? echo $i; ?>['dsrelbem.2'] = '<? echo getByTagName($regFilhos[$i]->tags[51]->tags,'dsrelbem.2'); ?>';
				regFilhoavt<? echo $i; ?>['dsrelbem.3'] = '<? echo getByTagName($regFilhos[$i]->tags[51]->tags,'dsrelbem.3'); ?>';
				regFilhoavt<? echo $i; ?>['dsrelbem.4'] = '<? echo getByTagName($regFilhos[$i]->tags[51]->tags,'dsrelbem.4'); ?>';
				regFilhoavt<? echo $i; ?>['dsrelbem.5'] = '<? echo getByTagName($regFilhos[$i]->tags[51]->tags,'dsrelbem.5'); ?>';
				regFilhoavt<? echo $i; ?>['dsrelbem.6'] = '<? echo getByTagName($regFilhos[$i]->tags[51]->tags,'dsrelbem.6'); ?>';
				regFilhoavt<? echo $i; ?>['persemon.1'] = '<? echo getByTagName($regFilhos[$i]->tags[52]->tags,'persemon.1'); ?>';
				regFilhoavt<? echo $i; ?>['persemon.2'] = '<? echo getByTagName($regFilhos[$i]->tags[52]->tags,'persemon.2'); ?>';
				regFilhoavt<? echo $i; ?>['persemon.3'] = '<? echo getByTagName($regFilhos[$i]->tags[52]->tags,'persemon.3'); ?>';
				regFilhoavt<? echo $i; ?>['persemon.4'] = '<? echo getByTagName($regFilhos[$i]->tags[52]->tags,'persemon.4'); ?>';
				regFilhoavt<? echo $i; ?>['persemon.5'] = '<? echo getByTagName($regFilhos[$i]->tags[52]->tags,'persemon.5'); ?>';
				regFilhoavt<? echo $i; ?>['persemon.6'] = '<? echo getByTagName($regFilhos[$i]->tags[52]->tags,'persemon.6'); ?>';
				regFilhoavt<? echo $i; ?>['qtprebem.1'] = '<? echo getByTagName($regFilhos[$i]->tags[53]->tags,'qtprebem.1'); ?>';
				regFilhoavt<? echo $i; ?>['qtprebem.2'] = '<? echo getByTagName($regFilhos[$i]->tags[53]->tags,'qtprebem.2'); ?>';
				regFilhoavt<? echo $i; ?>['qtprebem.3'] = '<? echo getByTagName($regFilhos[$i]->tags[53]->tags,'qtprebem.3'); ?>';
				regFilhoavt<? echo $i; ?>['qtprebem.4'] = '<? echo getByTagName($regFilhos[$i]->tags[53]->tags,'qtprebem.4'); ?>';
				regFilhoavt<? echo $i; ?>['qtprebem.5'] = '<? echo getByTagName($regFilhos[$i]->tags[53]->tags,'qtprebem.5'); ?>';
				regFilhoavt<? echo $i; ?>['qtprebem.6'] = '<? echo getByTagName($regFilhos[$i]->tags[53]->tags,'qtprebem.6'); ?>';
				regFilhoavt<? echo $i; ?>['vlprebem.1'] = '<? echo getByTagName($regFilhos[$i]->tags[54]->tags,'vlprebem.1'); ?>';
				regFilhoavt<? echo $i; ?>['vlprebem.2'] = '<? echo getByTagName($regFilhos[$i]->tags[54]->tags,'vlprebem.2'); ?>';
				regFilhoavt<? echo $i; ?>['vlprebem.3'] = '<? echo getByTagName($regFilhos[$i]->tags[54]->tags,'vlprebem.3'); ?>';
				regFilhoavt<? echo $i; ?>['vlprebem.4'] = '<? echo getByTagName($regFilhos[$i]->tags[54]->tags,'vlprebem.4'); ?>';
				regFilhoavt<? echo $i; ?>['vlprebem.5'] = '<? echo getByTagName($regFilhos[$i]->tags[54]->tags,'vlprebem.5'); ?>';
				regFilhoavt<? echo $i; ?>['vlprebem.6'] = '<? echo getByTagName($regFilhos[$i]->tags[54]->tags,'vlprebem.6'); ?>';
				regFilhoavt<? echo $i; ?>['vlrdobem.1'] = '<? echo getByTagName($regFilhos[$i]->tags[55]->tags,'vlrdobem.1'); ?>';
				regFilhoavt<? echo $i; ?>['vlrdobem.2'] = '<? echo getByTagName($regFilhos[$i]->tags[55]->tags,'vlrdobem.2'); ?>';
				regFilhoavt<? echo $i; ?>['vlrdobem.3'] = '<? echo getByTagName($regFilhos[$i]->tags[55]->tags,'vlrdobem.3'); ?>';
				regFilhoavt<? echo $i; ?>['vlrdobem.4'] = '<? echo getByTagName($regFilhos[$i]->tags[55]->tags,'vlrdobem.4'); ?>';
				regFilhoavt<? echo $i; ?>['vlrdobem.5'] = '<? echo getByTagName($regFilhos[$i]->tags[55]->tags,'vlrdobem.5'); ?>';
				regFilhoavt<? echo $i; ?>['vlrdobem.6'] = '<? echo getByTagName($regFilhos[$i]->tags[55]->tags,'vlrdobem.6'); ?>';
				regFilhoavt<? echo $i; ?>['nrcxapst'] = '<? echo getByTagName($regFilhos[$i]->tags,'nrcxapst'); ?>'; 
				regFilhoavt<? echo $i; ?>['dtadmsoc'] = '<? echo getByTagName($regFilhos[$i]->tags,'dtadmsoc'); ?>';
				regFilhoavt<? echo $i; ?>['flgdepec'] = '<? echo getByTagName($regFilhos[$i]->tags,'flgdepec'); ?>';
				regFilhoavt<? echo $i; ?>['persocio'] = '<? echo getByTagName($regFilhos[$i]->tags,'persocio'); ?>';
				regFilhoavt<? echo $i; ?>['vledvmto'] = '<? echo getByTagName($regFilhos[$i]->tags,'vledvmto'); ?>';
				regFilhoavt<? echo $i; ?>['inhabmen'] = '<? echo getByTagName($regFilhos[$i]->tags,'inhabmen'); ?>';
				regFilhoavt<? echo $i; ?>['dthabmen'] = '<? echo getByTagName($regFilhos[$i]->tags,'dthabmen'); ?>';
				regFilhoavt<? echo $i; ?>['dshabmen'] = '<? echo getByTagName($regFilhos[$i]->tags,'dshabmen'); ?>';
				regFilhoavt<? echo $i; ?>['nrctremp'] = '<? echo getByTagName($regFilhos[$i]->tags,'nrctremp'); ?>';
				regFilhoavt<? echo $i; ?>['idseqttl'] = '<? echo getByTagName($regFilhos[$i]->tags,'nrctremp'); ?>';
				regFilhoavt<? echo $i; ?>['nrdconta'] = '<? echo getByTagName($regFilhos[$i]->tags,'nrdconta'); ?>';
				regFilhoavt<? echo $i; ?>['vloutren'] = '<? echo getByTagName($regFilhos[$i]->tags,'vloutren'); ?>';
				regFilhoavt<? echo $i; ?>['dsoutren'] = '<? echo getByTagName($regFilhos[$i]->tags,'dsoutren'); ?>';
				regFilhoavt<? echo $i; ?>['cdcooper'] = '<? echo getByTagName($regFilhos[$i]->tags,'cdcooper'); ?>';
				regFilhoavt<? echo $i; ?>['tpctrato'] = '<? echo getByTagName($regFilhos[$i]->tags,'tpctrato'); ?>';
				regFilhoavt<? echo $i; ?>['cddconta'] = '<? echo getByTagName($regFilhos[$i]->tags,'cddconta'); ?>';
				regFilhoavt<? echo $i; ?>['dstipcta'] = '<? echo getByTagName($regFilhos[$i]->tags,'dstipcta'); ?>';
				regFilhoavt<? echo $i; ?>['dtmvtolt'] = '<? echo getByTagName($regFilhos[$i]->tags,'dtmvtolt'); ?>';
				
				regFilhoavt<? echo $i; ?>['deletado'] = false;
				regFilhoavt<? echo $i; ?>['cddopcao'] = '<? echo getByTagName($regFilhos[$i]->tags,'cddopcao'); ?>';
								
				arrayFilhosAvtMatric[<? echo $i; ?>] = regFilhoavt<? echo $i; ?>;
				
			<? } ?>
			
			arrayBensMatric = new Array();
			
			<? for($i=0; $i<count($bens); $i++) { ?>	
			
				var regBens<? echo $i; ?> = new Object();
				
				regBens<? echo $i; ?>['dsrelbem'] = '<? echo getByTagName($bens[$i]->tags,'dsrelbem'); ?>';			
				regBens<? echo $i; ?>['persemon'] = '<? echo getByTagName($bens[$i]->tags,'persemon'); ?>';			
				regBens<? echo $i; ?>['qtprebem'] = '<? echo getByTagName($bens[$i]->tags,'qtprebem'); ?>';			
				regBens<? echo $i; ?>['vlprebem'] = '<? echo getByTagName($bens[$i]->tags,'vlprebem'); ?>';			
				regBens<? echo $i; ?>['cdsequen'] = '<? echo getByTagName($bens[$i]->tags,'cdsequen'); ?>';			
				regBens<? echo $i; ?>['vlrdobem'] = '<? echo getByTagName($bens[$i]->tags,'vlrdobem'); ?>';			
				regBens<? echo $i; ?>['nrdrowid'] = '<? echo getByTagName($bens[$i]->tags,'nrdrowid'); ?>';			
				regBens<? echo $i; ?>['cpfdoben'] = '<? echo getByTagName($bens[$i]->tags,'cpfdoben'); ?>';			
				regBens<? echo $i; ?>['deletado'] = false;				
				regBens<? echo $i; ?>['cddopcao'] = '<? echo getByTagName($bens[$i]->tags,'cddopcao'); ?>';			
								
				arrayBensMatric[<? echo $i; ?>] = regBens<? echo $i; ?>;
				 
			<? } ?>			
			
			arrayFilhos = new Array();

			<? for($i=0; $i<count($responsaveis); $i++) { ?>	
			
				var regResp<? echo $i; ?> = new Object();
				
				regResp<? echo $i; ?>['cdcooper'] = '<? echo getByTagName($responsaveis[$i]->tags,'cdcooper'); ?>';
				regResp<? echo $i; ?>['nrctamen'] = '<? echo getByTagName($responsaveis[$i]->tags,'nrctamen'); ?>';
				regResp<? echo $i; ?>['nrcpfmen'] = '<? echo getByTagName($responsaveis[$i]->tags,'nrcpfmen'); ?>';
				regResp<? echo $i; ?>['idseqmen'] = '<? echo getByTagName($responsaveis[$i]->tags,'idseqmen'); ?>';				
				regResp<? echo $i; ?>['nrdconta'] = '<? echo getByTagName($responsaveis[$i]->tags,'nrdconta'); ?>';				
				regResp<? echo $i; ?>['nrcpfcgc'] = '<? echo getByTagName($responsaveis[$i]->tags,'nrcpfcgc'); ?>';
				regResp<? echo $i; ?>['nmrespon'] = '<? echo getByTagName($responsaveis[$i]->tags,'nmrespon'); ?>';				
				regResp<? echo $i; ?>['nridenti'] = '<? echo getByTagName($responsaveis[$i]->tags,'nridenti'); ?>';				
				regResp<? echo $i; ?>['tpdeiden'] = '<? echo getByTagName($responsaveis[$i]->tags,'tpdeiden'); ?>';				
				regResp<? echo $i; ?>['dsorgemi'] = '<? echo getByTagName($responsaveis[$i]->tags,'dsorgemi'); ?>';				
				regResp<? echo $i; ?>['cdufiden'] = '<? echo getByTagName($responsaveis[$i]->tags,'cdufiden'); ?>';
				regResp<? echo $i; ?>['dtemiden'] = '<? echo getByTagName($responsaveis[$i]->tags,'dtemiden'); ?>';				
				regResp<? echo $i; ?>['dtnascin'] = '<? echo getByTagName($responsaveis[$i]->tags,'dtnascin'); ?>';				
				regResp<? echo $i; ?>['cddosexo'] = '<? echo getByTagName($responsaveis[$i]->tags,'cddosexo'); ?>';			
				regResp<? echo $i; ?>['cdestciv'] = '<? echo getByTagName($responsaveis[$i]->tags,'cdestciv'); ?>';
				regResp<? echo $i; ?>['dsnacion'] = '<? echo getByTagName($responsaveis[$i]->tags,'dsnacion'); ?>';
				regResp<? echo $i; ?>['dsnatura'] = '<? echo getByTagName($responsaveis[$i]->tags,'dsnatura'); ?>';
				regResp<? echo $i; ?>['cdcepres'] = '<? echo getByTagName($responsaveis[$i]->tags,'cdcepres'); ?>';				
				regResp<? echo $i; ?>['dsendres'] = '<? echo getByTagName($responsaveis[$i]->tags,'dsendres'); ?>';				
				regResp<? echo $i; ?>['nrendres'] = '<? echo getByTagName($responsaveis[$i]->tags,'nrendres'); ?>';				
				regResp<? echo $i; ?>['dscomres'] = '<? echo getByTagName($responsaveis[$i]->tags,'dscomres'); ?>';				
				regResp<? echo $i; ?>['dsbaires'] = '<? echo getByTagName($responsaveis[$i]->tags,'dsbaires'); ?>';				
				regResp<? echo $i; ?>['nrcxpost'] = '<? echo getByTagName($responsaveis[$i]->tags,'nrcxpost'); ?>';				
				regResp<? echo $i; ?>['dscidres'] = '<? echo getByTagName($responsaveis[$i]->tags,'dscidres'); ?>';				
				regResp<? echo $i; ?>['dsdufres'] = '<? echo getByTagName($responsaveis[$i]->tags,'dsdufres'); ?>';				
				regResp<? echo $i; ?>['nmpairsp'] = '<? echo getByTagName($responsaveis[$i]->tags,'nmpairsp'); ?>';
				regResp<? echo $i; ?>['nmmaersp'] = '<? echo getByTagName($responsaveis[$i]->tags,'nmmaersp'); ?>';
				regResp<? echo $i; ?>['deletado'] = '<? echo getByTagName($responsaveis[$i]->tags,'deletado'); ?>';
				regResp<? echo $i; ?>['cddopcao'] = '<? echo getByTagName($responsaveis[$i]->tags,'cddopcao'); ?>';
				regResp<? echo $i; ?>['nrdrowid'] = '<? echo getByTagName($responsaveis[$i]->tags,'nrdrowid'); ?>';
				regResp<? echo $i; ?>['cddctato'] = '<? echo getByTagName($responsaveis[$i]->tags,'cddctato'); ?>';
				regResp<? echo $i; ?>['dsestcvl'] = '<? echo getByTagName($responsaveis[$i]->tags,'dsestcvl'); ?>';
				regResp<? echo $i; ?>['dtmvtolt'] = '<? echo getByTagName($responsaveis[$i]->tags,'dtmvtolt'); ?>';

				arrayFilhos[<? echo $i; ?>] = regResp<? echo $i; ?>;

			<? } ?>			
			
			sincronizaArray();
			
		</script>
		<?	
	} else {
		$registro = '';
		$tpPessoa = 1;
		$strMsg   = '';
		?>
			<script type="text/javascript">
			
				arrayFilhosAvtMatric = new Array();
				arrayBensMatric = new Array();
				arrayFilhos     = new Array();
		
			</script>
		<?php
	}
	
	include('form_cabecalho.php');	
	include('form_fisico.php'); 
	include('form_juridico.php');
?>

<div id="divBotoes" style="margin-bottom:10px">

	<a href="#" class="opInicial botao" id="btLimparIni" onclick="estadoInicial(); return false;">Limpar</a>
	<a href="#" class="opInicial botao" id="btProsseguirIni" onclick="consultaInicial(); return false;">Prosseguir</a>

	<a href="#" class="opIncluir botao" id="btVoltarInc" onclick="controlaOperacao('IC'); return false;">Voltar</a>
	<a href="#" class="opIncluir botao" id="btProsseguirInc" onclick="">Prosseguir</a>
											
	<a href="#" class="opPreIncluir botao" id="btVoltarPreInc" onclick="estadoInicial(); return false;">Voltar</a>
	<a href="#" class="opPreIncluir botao" id="btProsseguirPreInc" onclick="">Prosseguir</a>

	<a href="#" class="opAlterar botao" id="btVoltarAlt" onclick="controlaOperacao('AC'); return false;">Cancelar</a>	
	<a href="#" class="opAlterar botao" id="btProsseguirAlt" onclick="">Prosseguir</a>
	<a href="#" class="opAlterar botao" id="btSalvarAlt" onclick="">Concluir</a>

	<a href="#" class="opAltNome botao" id="btVoltarAltNome" onclick="controlaOperacao('XC'); return false;">Cancelar</a>
	<a href="#" class="opAltNome botao" id="btSalvarAltNome" onclick="controlaOperacao('XV'); return false;">Concluir</a>
	
	<a href="#" class="opAltCpfCnpj botao" id="btVoltarAltCpfCnpj" onclick="controlaOperacao('JC'); return false;">Cancelar</a>
	<a href="#" class="opAltCpfCnpj botao" id="btSalvarAltCpfCnpj" onclick="controlaOperacao('JV'); return false;">Concluir</a>
	
	<a href="#" class="opConsultar botao" id="btVoltarCns" onclick="">Voltar</a>
	<a href="#" class="opConsultar botao" id="btProsseguirCns" onclick="">Prosseguir</a>
	
	<a href="#" class="opDesvinc botao" id="btVoltarDesvinc" onclick="controlaOperacao('DC'); return false;">Cancelar</a>
	<a href="#" class="opDesvinc botao" id="btSalvarDesvinc" onclick="controlaOperacao('DV'); return false;">Concluir</a>
	
</div>

<script type='text/javascript'>
	// Alimenta as variáveis globais
	operacao = '<? echo $operacao; ?>';
	nrdconta = '<? echo $nrdconta; ?>';
	tppessoa = '<? echo $tpPessoa; ?>';	
	nrdeanos = '<? echo getByTagName($registro,'nrdeanos'); ?>';
	dtmvtolt = '<? echo $glbvars["dtmvtolt"] ?>';
	cdpactra = '<? echo $glbvars["cdpactra"] ?>';
	
	// Alimenta opções que o operador tem acesso
	flgAlterar		= '<? echo $flgAlterar; 	?>';
	flgConsultar	= '<? echo $flgConsultar; 	?>';
	flgIncluir		= '<? echo $flgIncluir; 	?>';
	flgRelatorio	= '<? echo $flgRelatorio; 	?>';
	flgNome			= '<? echo $flgNome; 		?>';
	flgDesvincula	= '<? echo $flgDesvincula;	?>';
    flgCpfCnpj      = '<? echo $flgCpfCnpj;	    ?>';
	
	strMsg = '<? echo $strMsg; ?>';
	
	controlaLayout();
		
	if (operacao != 'CI') {
		if ( strMsg != '' ){
			exibirMensagens(strMsg,'controlaFoco();');
		}else{
			controlaFoco();	
		}
		
		if (tppessoa == 2) {
			$("#cdcnae","#frmJuridico").trigger("change");	
		}
		
	}
	
</script>
